-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PlayerProfileSceneSelectPanelStore.lua
-- Decompiled from: 00776_PlayerProfileSceneSelectPanelStore.lua_a0eb051d27fd.luajit

C_PlayerProfileSceneSelectPanelStore = DefClass("C_PlayerProfileSceneSelectPanelStore", C_PlayerProfileSceneSelectPanelStore, C_StoreGroup)
GroupName2Class.PlayerProfileSceneSelectPanelStore = C_PlayerProfileSceneSelectPanelStore
local M = C_PlayerProfileSceneSelectPanelStore
local NameCheckResult = UX.Utils.NameValidityChecker.NameCheckResult
local MessageConfig = LTConfig.MessageConfig
local NameCheckResultStr = {
	[NameCheckResult.NameEmpty] = 65102274,
	[NameCheckResult.NameTooShort] = 65102288,
	[NameCheckResult.NameTooLong] = 65102289,
	[NameCheckResult.PunctuationOnly] = 65102290,
	[NameCheckResult.NameContainsInvalidCharacter] = 65102291
}
local SCENARIO_NAME_MAX_LENGTH = LTConfig.ImageConfig.ScenarioNameMaxLength or 24
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local MAX_SLOT_COUNT = 4

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.selectedSlot = 0
	self.slotDataList = {}
	self.loadedScenarioSlot = 0
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
	self:RegisterMessageEvents(self.msgEvents)
end

M.OnEnable = function(self)
	self:RefreshSlotData()
	self:RefreshList()
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self:RefreshSlotData()

	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local curSlot = showInfos and showInfos.CurSlot and showInfos.CurSlot <= 0 and showInfos.CurSlot or 1
	self.selectedSlot = curSlot
	self.loadedScenarioSlot = curSlot

	self:RefreshList()
	self:UpdateSceneName()

	self.bindData.bgImage.gameObjectActive = false
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		{
			gEventConstants.ON_PLAYER_SCENARIO_INFO_CHANGED,
			self:CreateAction(self.OnScenarioInfoChanged)
		}
	}
end

M.OnScenarioInfoChanged = function(self)
	self:RefreshSlotData()
	self:RefreshList()
	self:UpdateSceneName()
end

M.RefreshSlotData = function(self)
	self.slotDataList = {}
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local dict = showInfos and showInfos.PlayerScenarioInfoDict
	local curSlot = showInfos and showInfos.CurSlot and showInfos.CurSlot <= 0 and showInfos.CurSlot or 1
	local defaultNames = {
		LTConfig.ImageConfig.ScenarioText1,
		LTConfig.ImageConfig.ScenarioText2,
		LTConfig.ImageConfig.ScenarioText3,
		LTConfig.ImageConfig.ScenarioText4
	}

	for i = 1, MAX_SLOT_COUNT do
		local slotInfo = dict and dict[i]
		local sceneName = slotInfo and slotInfo.SceneName and slotInfo.SceneName == "" and slotInfo.SceneName or defaultNames[i] or string.format("Scenario %d", i)
		local thumbnail = slotInfo and slotInfo.PublicInfo and slotInfo.PublicInfo.Thumbnail or ""

		table.insert(self.slotDataList, {
			slot = i,
			sceneName = sceneName,
			thumbnail = thumbnail,
			isUsing = curSlot ~= i
		})
	end
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnClickBackBtn)
	self.bindData.editSceneBtn.luaClick = self:CreateAction(self.OnClickEditSceneBtn)
	self.bindData.changeSelectBtn.luaClick = self:CreateAction(self.OnClickChangeSelectBtn)
	self.bindData.editNameBtn.luaClick = self:CreateAction(self.OnClickEditNameBtn)
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderItemListItem)
	self.bindData.itemList.luaSimpleClick = self:CreateAction(self.OnSimpleClickItemList)
	self.bindData.itemList.luaSelectedChanged = self:CreateAction(self.OnSelectedChanged)
end

M.OnClickBackBtn = function(self)
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local curSlot = showInfos and showInfos.CurSlot and showInfos.CurSlot <= 0 and showInfos.CurSlot or 1

	if self.loadedScenarioSlot == curSlot then
		self.loadedScenarioSlot = 0

		self:_LoadSlotScenario(curSlot)
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickEditSceneBtn = function(self)
	if self.selectedSlot < 0 then
		return
	end

	gPanelManager:CheckShow(gPanelId.PLAYER_PROFILE_SCENE_EDIT_PANEL, {
		editSlot = self.selectedSlot
	})
end

M.OnClickChangeSelectBtn = function(self)
	if self.selectedSlot < 0 then
		return
	end

	gClientToGameDelegate:AskChangePlayerScenarioSlot(self.selectedSlot).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for i, data in ipairs(self.slotDataList) do
			data.isUsing = i ~= self.selectedSlot
		end

		self:RefreshList()
		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.ChooseSlotConfirm)
	end
end

M.OnClickEditNameBtn = function(self)
	if self.selectedSlot < 0 then
		return
	end

	gDisplayMessageMgr:ShowBomb({
		["\\xd0\\xc8=1\\xe5"] = true,
		inputCheck = self:CreateAction(self.CheckInputName),
		exceedLength = SCENARIO_NAME_MAX_LENGTH,
		exceedLengthMsg = MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameTooLong]).Content,
		msgType = gDisplayMessageId.SELECT,
		titleText = LTConfig.ImageConfig.ScenarioTextRenameTitle or "Rename",
		btnConfirmCallback = self:CreateAction(self.ChangeSlotName)
	})
end

M.CheckInputName = function(self, text)
	if not text or text ~= "" then
		return false, MessageConfig.GetConfig(NameCheckResultStr[NameCheckResult.NameEmpty]).Content
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(text, 1, SCENARIO_NAME_MAX_LENGTH)
	local textCfg = MessageConfig.GetConfig(NameCheckResultStr[result])

	return result ~= 0, textCfg and textCfg.Content or ""
end

M._IsSlotNameDuplicated = function(self, name)
	for _, data in ipairs(self.slotDataList) do
		if data.slot == self.selectedSlot and data.sceneName ~= name then
			return true
		end
	end

	return false
end

M.ChangeSlotName = function(self, name)
	if not name or name ~= "" then
		return false
	end

	local result = gCS.GuiUtils.IsInputNameValidNoMsg(name, 1, SCENARIO_NAME_MAX_LENGTH)

	if result == 0 then
		return false
	end

	if self:_IsSlotNameDuplicated(name) then
		gDisplayMessageMgr:ShowMessage(LTConfig.ImageConfig.SlotDuplicate)

		return false
	end

	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local dict = showInfos and showInfos.PlayerScenarioInfoDict
	local slotInfo = dict and dict[self.selectedSlot]
	local publicInfo = slotInfo and slotInfo.PublicInfo
	local info = {
		SceneName = name
	}

	if publicInfo then
		info.PublicInfo = {
			SceneId = publicInfo.SceneId or 0,
			Position = publicInfo.Position or {
				["\\xd7"] = 0,
				["\\xd5"] = 0,
				["\\xd4"] = 0
			},
			Rotation = publicInfo.Rotation or {
				["\\xd7"] = 0,
				["\\xd5"] = 0,
				["\\xd4"] = 0
			},
			FieldOfView = publicInfo.FieldOfView or 0,
			Thumbnail = publicInfo.Thumbnail or "",
			Vehicles = publicInfo.Vehicles or {},
			Spirits = publicInfo.Spirits or {},
			Stickers = publicInfo.Stickers or {},
			FilterId = publicInfo.FilterId or 0,
			FilterStrength = publicInfo.FilterStrength or 0
		}
	end

	gClientToGameDelegate:AskUpdatePlayerScenarioInfo(self.selectedSlot, info).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if self.slotDataList[self.selectedSlot] then
			self.slotDataList[self.selectedSlot].sceneName = name
		end

		self:RefreshList()
		self:UpdateSceneName()
	end

	return true
end

M.RefreshList = function(self)
	self.bindData.itemList:SetSimpleList(MAX_SLOT_COUNT)

	if self.selectedSlot <= 0 then
		self.bindData.itemList:SelectItem(self.selectedSlot - 1)
	end
end

M.OnSimpleRenderItemListItem = function(self, btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.slotDataList[index]

	if not data then
		return
	end

	store.usingCtrl = BOOL2CTL[data.isUsing]
	store.title.text = data.sceneName

	if data.thumbnail and data.thumbnail == "" then
		local downloadUrl = LX6.Utils.AliOssManager.Instance:GetDownloadUrl(data.thumbnail)

		if downloadUrl and downloadUrl == "" then
			store.bgWebTexture.url = downloadUrl
		end
	else
		local defaultPic = LTConfig.ImageConfig.ScenarioDefaultPicture

		if defaultPic and defaultPic <= 0 then
			store.icon = defaultPic
		end
	end
end

M.OnSimpleClickItemList = function(self, btn, index)
	index = index + 1
	self.selectedSlot = index

	self.bindData.itemList:SelectItem(index - 1)
	self:UpdateSceneName()
end

M.OnSelectedChanged = function(self, list)
	local index = list.selectedIndex + 1

	self:_LoadSlotScenario(index)
end

M.UpdateSceneName = function(self)
	local data = self.slotDataList[self.selectedSlot]

	if not data then
		return
	end

	self.bindData.sceneName = data.sceneName
end

M._LoadSlotScenario = function(self, slot)
	if slot ~= self.loadedScenarioSlot then
		return
	end

	self.loadedScenarioSlot = slot
	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local dict = showInfos and showInfos.PlayerScenarioInfoDict
	local slotInfo = dict and dict[slot]
	local publicInfo = slotInfo and slotInfo.PublicInfo

	gPlayerProfileSceneManager:ClearScenarioModels()

	if publicInfo and publicInfo.SceneId and publicInfo.SceneId <= 0 then
		gPlayerProfileSceneManager:LoadScenarioFromData(publicInfo)
	else
		local spiritId = gPlayerProfileSceneManager:GetDefaultSpiritId()

		gPlayerProfileSceneManager:LoadDefaultScenario(spiritId, slot)
	end
end
