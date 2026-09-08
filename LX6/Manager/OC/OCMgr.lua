-- Original chunk: @Lua\LuaFiles\LX6\Manager\OC\OCMgr.lua
-- Decompiled from: 02257_OCMgr.lua_0887d0b59748.luajit

local GameObject = UnityEngine.GameObject
local OCApi = L50.OC.OCBridge
local OriginalCharacterTabConfig = LTConfig.OriginalCharacterTabConfig
local Consts = gClientConst
local UNavigationMgr = SGUI.UNavigationMgr
local OCConfig = LTConfig.OriginalCharacterConfig
local ChatSettingsConfig = LTConfig.OriginalCharacterChatSettingsConfig
local OCTemplateConfig = LTConfig.OriginalCharacterTemplateConfig
local PersonalityLabelConfig = LTConfig.OriginalCharacterPersonalityLabelConfig
local MessageConfig = LTConfig.MessageConfig
local StaticProps = {}
C_OCMgr = DefClass("C_OCMgr", C_OCMgr, nil, StaticProps)
local M = C_OCMgr

dofile("LX6/Manager/OC/OCMgr_data")
dofile("LX6/Manager/OC/OCMgr_FrontCreate")
dofile("LX6/Manager/OC/OCMgr_Voice")
dofile("LX6/Manager/OC/OCMgr_Chat")
dofile("LX6/Manager/OC/OCMgr_Finish")
dofile("LX6/Manager/OC/OCMgr_Test")
dofile("LX6/Manager/OC/OCMgr_Grandpa")

M.ctor = function(self)
	self.api = OCApi

	self:Clear()
end

M.OnInit = function(self)
	self:InitData()
	gMessageManager:AddMessageListener(gEventConstants.PHOTO_TEXTURE_GENERATED, self:CreateAction(self.OnTakePhoto))
	gMessageManager:AddMessageListener(gEventConstants.OC_CHAT_SESSION_CHANGE, self:CreateAction(self.OnSessionChange))
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:InitData()
	self:Clear()
end

M.Clear = function(self)
	self.ocInfo = {}
	self.npcId = ulong.zero
	self.mineVoiceList = {}
	self.keepSceneHandleId = nil

	self:InitGrandpaData()
end

M.InitData = function(self)
	self.currentAgentId = 0
	self.csUnit = nil
	self.editUnitReady = false
	self.waitPhoto = false
	self.pendingCameraTabIndex = nil

	self:OnInitData()
	self:OnInitTabData()
end

M.Log = function(self, ...)
	print_notice("[C_OCMgr]", ...)
end

M.OnStart = function(self)
	self:InitData()
	self:CreateScene()
end

M.OnEnd = function(self)
	self:DestoryScene()
	self:DestoryModel()
	self:ClearMeikaGrandpaMode()
end

M.OnInitOCInfo = function(self, ocInfo)
	self.ocInfo = ocInfo

	if not ocInfo then
		return
	end

	if ocInfo.OCMeccaGrandpaInfo then
		self:OnSyncGrandpaInfo(ocInfo.OCMeccaGrandpaInfo)
	end

	if ocInfo.MemoryInfo and ocInfo.MemoryInfo.MemorySetDataDict then
		for memorySetId, setData in pairs(ocInfo.MemoryInfo.MemorySetDataDict) do
			if setData then
				local newEntries = {}

				if setData.MemoryEntryDict then
					for _, entry in pairs(setData.MemoryEntryDict) do
						table.insert(newEntries, entry)
					end
				end

				local change = {
					MemorySetId = memorySetId,
					NewEntries = newEntries,
					ProgressPercent = setData.RecoveredMemoryWeight
				}

				self:OnSyncMemoryChange(change)
			end
		end
	end
end

M.OnFinish = function(self, callback)
	self:CreateUnitInWorld()
	self:LoadEndTimeLine(callback)
end

M.SetWeather = function(self, isOpen)
	gCS.GuiUtils.SetXuWeiWeatherState(isOpen, OCConfig.SceneWeatherIndex or 19)
end

M.CreateScene = function(self)
	self:SetWeather(true)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.PauseManager.Instance:ProessUIModelShow(true)
	self:LoadScenePrefab()
	gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.OCEdit)
end

M.DestoryScene = function(self)
	self:ClearScenePrefab()
	self:SetWeather(false)
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.OCEdit)
end

M.LoadScenePrefab = function(self)
	local path = OCConfig.ScenePath
	self.scenePrefabOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset then
			return
		end

		local scenePrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)

		scenePrefab.gameObject.transform:SetLocalPosition(Vector3.New(0, -500, 0))
		scenePrefab.gameObject.transform:SetLocalScale(1)

		scenePrefab.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.scenePrefab = scenePrefab

		self:OnSceneReady()
	end)
end

M.ClearScenePrefab = function(self)
	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		GameObject.Destroy(self.scenePrefab)

		self.scenePrefab = nil
	end
end

M.OnSceneReady = function(self)
	gPanelManager:CheckShow(gPanelId.OC_MAINPAGE)
end

M.CreateModel = function(self)
	self.pos = Vector3.New(0, -500, 0)
	self.eulerAngle = 180
	self.editUnitReady = false

	self:DestoryModel()

	local bodyType = self:GetBodyType()
	self.csUnit = L50.L50App.Scene.OCManager:CreateEditUnit(bodyType, self.pos, self.eulerAngle, function (baseUnit)
		if not baseUnit then
			return
		end

		self.csUnit = baseUnit
		self.editUnitReady = true
		baseUnit.forbidAetherAI = true

		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.OCEdit)
		self:AppPendingCamera()
		self:PlayGreetingAndIdle()
	end)

	if not self.csUnit then
		return
	end

	self.csUnit.forbidAetherAI = true
end

M.SwitchModel = function(self)
	if not self.csUnit then
		return
	end

	self.editUnitReady = false
	local bodyType = self:GetBodyType()
	self.csUnit = L50.L50App.Scene.OCManager:CreateEditUnit(bodyType, self.pos, self.eulerAngle, function (baseUnit)
		if not baseUnit then
			return
		end

		self.csUnit = baseUnit
		self.editUnitReady = true
		baseUnit.forbidAetherAI = true

		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.OCEdit)
		self:AppPendingCamera()
	end)
end

M.SwitchTemplateModel = function(self, templateId)
	self.editUnitReady = false

	L50.L50App.Scene.OCManager:CreateEditTemplateUnit(templateId, self.pos, self.eulerAngle, function (baseUnit)
		if not baseUnit then
			return
		end

		self.csUnit = baseUnit
		self.editUnitReady = true
		baseUnit.forbidAetherAI = true

		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.OCEdit)
		self:AppPendingCamera()
		self:PlayGreetingAndIdle()
	end)
end

M.PlayGreetingAndIdle = function(self)
	if not self.csUnit or not self.editUnitReady then
		return
	end

	local now = gCS.TimeManager:GetClientMilliSeconds()
	local cdMs = (OCConfig.GreetingCD or 2) * 1000

	if self.lastGreetingTime and cdMs <= now - self.lastGreetingTime then
		return
	end

	self.lastGreetingTime = now
	local cfg = OCTemplateConfig.GetConfig(self.currentTemplateId)

	local playRecommendVoice = function(speechId)
		if not speechId then
			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)
		self:PlayAIVoice(speechId, speechId, nil)
	end

	local recommendItem = nil
	slot6 = ipairs
	slot8 = self.officialVoiceList or {}

	for _, v in slot6(slot8) do
		if v.index ~= -1 then
			recommendItem = v

			break
		end
	end

	if recommendItem then
		playRecommendVoice(recommendItem.speechId)
	else
		self:GetRecommendVoice(function (speechId)
			playRecommendVoice(speechId)
		end)
	end

	if not cfg then
		gCS.AnimControllerManager.PlayAction(self.csUnit, 1001, 1, 9999, 0, -1, false, nil, 0)

		return
	end

	local idleActionType = cfg.Idle and cfg.Idle <= 0 and cfg.Idle or 1001
	local idleActionGroup = 1
	local greetingActionType = cfg.GreetingGesture

	local playIdle = function()
		gCS.AnimControllerManager.PlayAction(self.csUnit, idleActionType, idleActionGroup, 9999, 0, -1, false, nil, 0)
	end

	if greetingActionType and greetingActionType <= 0 then
		gCS.AnimControllerManager.PlayAction(self.csUnit, greetingActionType, 1, 0, 0, -1, true, playIdle, 0)
	else
		playIdle()
	end
end

M.DestoryModel = function(self)
	self.editUnitReady = false

	if not self.csUnit then
		return
	end

	L50.L50App.Scene.OCManager:DestroyEditUnit()
end

M.RefreshCamera = function(self, tabIndex)
	self.pendingCameraTabIndex = tabIndex
	local cfg = OriginalCharacterTabConfig.GetConfig(tabIndex + 1)

	if not cfg then
		return
	end

	gMessageManager:SendMessage(gEventConstants.OC_CAMERA_TYPE, cfg.CameraId)
end

M.AppPendingCamera = function(self)
	if self.pendingCameraTabIndex == nil then
		self:RefreshCamera(self.pendingCameraTabIndex)
	end
end

M.OpenCreatePanel = function(self)
	gPanelManager:CheckShow(gPanelId.OC_CREATE_MAIN_PANEL)
end

M.OpenMeikaMainPanel = function(self, npcPid, entryIntent)
	self.isMeikaGrandpa = true

	self:RefreshOfficialVoiceList()
	self:SyncChatSettingsWithGrandpa()

	self.grandpaEntryIntent = entryIntent or "chat"

	if self.grandpaEntryIntent ~= "chat" and not self:HasGrandpa() then
		self:EnsurePresetGrandpaOCId(function (ok)
			if ok then
				self:SyncChatSettingsWithGrandpa()
			end
		end)
	end

	gPanelManager:CheckShow(gPanelId.OC_MK_MAIN, {
		npcPid = npcPid
	})
end

M.OpenGrandpaCreate = function(self, npcPid)
	self:OpenMeikaMainPanel(npcPid, "create")
end

M.OpenGrandpaMemory = function(self, npcPid)
	self:OpenMeikaMainPanel(npcPid, "memory")
end

M.OpenMainPanel = function(self, ocId)
	if ocId then
		self.npcId = ocId

		self:OnStart()
	else
		gClientToGameDelegate:AskOCPreGenerateOCId().Callback = function (err, ocId)
			if err ~= MessageConfig.Ok and ocId then
				self:OpenMainPanel(ocId)
			else
				self:Log("[OpenMainPanel] AskOCPreGenerateOCId failed, err=" .. tostring(err))
			end
		end

		return
	end

	self:ClearMeikaGrandpaMode()
end

M.RequestNewOCId = function(self, callback)
	gClientToGameDelegate:AskOCPreGenerateOCId().Callback = function (err, ocId)
		if err ~= MessageConfig.Ok and ocId then
			print_debug("[OC] RequestNewOCId success, new OCId:", ulong.tostring(ocId))

			self.npcId = ocId

			self:Log("[RequestNewOCId] new OCId:", ulong.tostring(ocId))

			if callback then
				callback(true)
			end
		else
			self:Log("[RequestNewOCId] failed, err=" .. tostring(err))

			if callback then
				callback(false)
			end
		end
	end
end

M.OnInitTabData = function(self)
	self.prevTabDict = {}
	self.nextTabDict = {}

	for i = 0, OriginalCharacterTabConfig.count - 1 do
		local cfg = OriginalCharacterTabConfig.LoadAt(i)
		self.nextTabDict[cfg.Id] = cfg.NextPage
		self.prevTabDict[cfg.Id] = cfg.PrevPage
	end
end

M.GetPrevTabIndex = function(self, index)
	return self.prevTabDict[index + 1] or OriginalCharacterTabConfig.Front
end

M.GetNextTabIndex = function(self, index)
	return self.nextTabDict[index + 1] or OriginalCharacterTabConfig.Front
end

M.RenderInputBox = function(self, btn, parentNavi, setAction, defaultValueStr)
	if not btn then
		return
	end

	local defaultValue = self.chatSettings[defaultValueStr] or ""
	local cfg = ChatSettingsConfig.GetConfig(ChatSettingsConfig[defaultValueStr])

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store:Commit("inputLabel", defaultValue, COMMIT_IMMEDIATELY)

	store.nameLabel = cfg.Title
	store.iconId = cfg.Icon
	local action = self:CreateAction(cfg.DataSetAction)

	local endEdit = function()
		local text = store.input.text
		store.inputLabel = text
		store.isEdit = Consts.BOOL2CTL[string.is_null_or_empty(text)]

		if action then
			action(text)
		end

		if setAction then
			setAction(text)
		end
	end

	if store.input then
		store.input.text = defaultValue
		store.input.luaEndEdit = endEdit

		store.input.onActivateAction = function()
			UNavigationMgr.Inst.CurrentActiveArea = store.inputNavigationArea
		end

		store.input.onDeActivateAction = function()
			UNavigationMgr.Inst.CurrentActiveArea = parentNavi
		end
	end

	if store.editBtn then
		store.editBtn.luaClick = function()
			store.input.text = store.inputLabel
			store.isEdit = Consts.BOOL2CTL[true]

			print_debug("[OC] RenderInputBox editBtn.luaClick", store.inputLabel, store.input.text)
		end
	end

	if store.confirmBtn then
		store.confirmBtn.luaClick = function()
			endEdit()
		end
	end

	if string.is_null_or_empty(defaultValue) then
		store.isEdit = Consts.BOOL2CTL[true]
	end
end

M.InitPersonalityTagTooltip = function(self, widget, ownerStore, tagIndex)
	if not widget then
		return
	end

	widget.luaRenderTooltip = function(btn, tooltipWidget)
		self:OnRenderPersonalityTagTooltip(btn, tooltipWidget, ownerStore)
	end

	local labels = self.personalityAndStory.labels or {}

	if labels[tagIndex] then
		widget:SetEnabledTooltip(false)
	else
		widget:SetEnabledTooltip(true)
	end
end

M.OnRenderPersonalityTagTooltip = function(self, btn, widget, ownerStore)
	local store = gStoreManager:GetStoreGroup("OCTabWindowListTemplate"):GetStoreByWidget(widget)

	if not store then
		return
	end

	self.currentTooltipBtn = btn
	self.currentTooltipOwner = ownerStore
	local currentLabels = self.personalityAndStory.labels or {}
	local idToLabelName = {}
	local allConfigs = {}

	for i = 0, PersonalityLabelConfig.count - 1 do
		local cfg = PersonalityLabelConfig.LoadAt(i)

		if cfg then
			table.insert(allConfigs, cfg)

			idToLabelName[cfg.Id] = cfg.Labels
		end
	end

	local labelRepelsMap = {}

	for _, cfg in ipairs(allConfigs) do
		if cfg.ConflictLabel then
			for _, conflictId in pairs(cfg.ConflictLabel) do
				local conflictName = idToLabelName[conflictId]

				if conflictName then
					if not labelRepelsMap[cfg.Labels] then
						labelRepelsMap[cfg.Labels] = {}
					end

					labelRepelsMap[cfg.Labels][conflictName] = true
				end
			end
		end
	end

	local ownedRepels = {}

	for _, myLabelName in ipairs(currentLabels) do
		local repels = labelRepelsMap[myLabelName]

		if repels then
			for targetName, _ in pairs(repels) do
				ownedRepels[targetName] = true
			end
		end
	end

	local validItems = {}

	for _, config in ipairs(allConfigs) do
		local labelName = config.Labels
		local isHidden = false

		for _, curName in ipairs(currentLabels) do
			if curName ~= labelName then
				isHidden = true

				break
			end
		end

		if not isHidden and ownedRepels[labelName] then
			isHidden = true
		end

		if not isHidden then
			local myConflicts = labelRepelsMap[labelName]

			if myConflicts then
				for _, curName in ipairs(currentLabels) do
					if myConflicts[curName] then
						isHidden = true

						break
					end
				end
			end
		end

		if not isHidden then
			table.insert(validItems, config)
		end
	end

	self.tooltipData = validItems

	store.list.luaSimpleRenderItem = function(itemBtn, index)
		self:OnRenderPersonalityTagTooltipItem(itemBtn, index)
	end

	store.list:SetSimpleList(#validItems)

	store.input.luaEndEdit = function(text, enter)
		if enter then
			self:OnEndEditPersonalityTagTooltip(store.input)
		end
	end
end

M.OnRenderPersonalityTagTooltipItem = function(self, btn, index)
	local data = self.tooltipData and self.tooltipData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.delCtrl = 1
		store.text = data.Labels

		btn.luaClick = function()
			self:OnClickAddPersonalityTagFromTooltip(data.Labels)
		end
	end
end

M.OnClickAddPersonalityTagFromTooltip = function(self, label)
	if not label then
		return
	end

	local labels = self.personalityAndStory.labels

	if not labels then
		self.personalityAndStory.labels = {}
		labels = self.personalityAndStory.labels
	end

	if #labels > 3 then
		return
	end

	if self.currentTooltipOwner and self.currentTooltipOwner.PushSnapshot then
		self.currentTooltipOwner:PushSnapshot()
	end

	self:AddPersonalityLabel(label)

	if self.currentTooltipBtn then
		self.currentTooltipBtn:CloseTooltip()
	end

	if self.currentTooltipOwner and self.currentTooltipOwner.RefreshTags then
		self.currentTooltipOwner:RefreshTags()
	end
end

M.OnEndEditPersonalityTagTooltip = function(self, input)
	if not input or string.is_null_or_empty(input.text) then
		return
	end

	local labels = self.personalityAndStory.labels

	if not labels then
		self.personalityAndStory.labels = {}
		labels = self.personalityAndStory.labels
	end

	if #labels > 3 then
		return
	end

	if self.currentTooltipOwner and self.currentTooltipOwner.PushSnapshot then
		self.currentTooltipOwner:PushSnapshot()
	end

	self:AddPersonalityLabel(input.text)

	if self.currentTooltipBtn then
		self.currentTooltipBtn:CloseTooltip()
	end

	if self.currentTooltipOwner and self.currentTooltipOwner.RefreshTags then
		self.currentTooltipOwner:RefreshTags()
	end
end

gOCMgr = gOCMgr or C_OCMgr.new()
