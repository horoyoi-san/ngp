local CommonGuideText = require("LX6.GuideFlow.New.CommonGuideText")
EGuideUIResType = {
	CommonGuideText = 1
}
gGuideUICustomCondition = {
	[EGuideUICustomCondition.CanLingMainLevelUp] = function ()
		if not gLuaUIMgr.lingLevelUpPanel then
			return false
		end

		return gLuaUIMgr.lingLevelUpPanel.CheckCanLevelUp()
	end
}
gNewGuideMgr = gNewGuideMgr or {}
local M = gNewGuideMgr
local guideMgrSharp = LX6.Guide.GuideManager
M.tmp_DisableBehaviourLimitAreaUpdate = false

function M:OnInit()
	self.tmp_DisableBehaviourLimitAreaUpdate = false

	self:InitGuideUI()

	if self.eventHandler then
		gMessageManager:UnregisterEventHandlers(self.eventHandler)
	end

	self.eventHandler = {
		[gEventConstants.ON_ACTIVE_DEVICE_CHANGED] = function ()
			self:OnControlSchemeChange()
		end,
		[gEventConstants.LANGUAGE_CHANGE] = function ()
			self:OnLanguageChange()
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandler)

	self.panelIdToUGuide = {}
	self.registeredUGuideCount = 0
	self.isRegisteredPanelShowStateChange = false
	self.globalPauseUUID = nil
	self.preLoadResourcesDic = {}
	self.isPanelStateDirty = false
	self.isNeedRefreshUGuides = false
	self.panelCheckUpdateHandler = nil
	self.patchBTCreatorDic = self.patchBTCreatorDic or {}
end

function M:Tmp_DisableBehaviourLimitAreaUpdate()
	self.tmp_TriggerCount = self.tmp_TriggerCount or 0
	self.tmp_TriggerCount = self.tmp_TriggerCount + 1
	self.tmp_DisableBehaviourLimitAreaUpdate = true
end

function M:Tmp_EnableBehaviourLimitAreaUpdate()
	self.tmp_TriggerCount = self.tmp_TriggerCount or 0
	self.tmp_TriggerCount = self.tmp_TriggerCount - 1

	if self.tmp_TriggerCount <= 0 then
		self.tmp_TriggerCount = 0
		self.tmp_DisableBehaviourLimitAreaUpdate = false
	end
end

function M:OnUpdate()
	if self.activeGuideBT and self.activeGuideBT.finishByBT then
		self:StopGuide(true)
	end

	if self.activeGuideBT then
		self.activeGuideBT:DoTick()
	end

	if self.activeGuideBT and self.activeGuideBT.finishByBT then
		self:StopGuide(true)
	end
end

function M:HasGuide(guideId)
	if gGameManager.Env.isEditor or not self.registerTable then
		self:ReloadRegisterTable()
	end

	if self.registerTable[guideId] then
		return true
	else
		return false
	end
end

function M:ReloadRegisterTable()
	local data = dofile("LuaGen/GuideFlow/Register/NewGuideRegister")
	self.registerTable = {}

	for _, guideData in ipairs(data) do
		local guideId = guideData.guideId
		local counter = guideData.counter

		if not self.registerTable[guideId] then
			self.registerTable[guideId] = {}
		end

		self.registerTable[guideId][counter] = true
	end
end

function M:AddPatch(guideId, counterId, bt)
	if not guideId or not counterId then
		print_error("AddPatch guideId or counterId is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	if not self.patchBTCreatorDic[guideId] then
		self.patchBTCreatorDic[guideId] = {}
	end

	if not bt then
		print_error("AddPatch bt is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	if not bt.Create then
		print_error("AddPatch bt.Create is nil, guideId=", guideId, " counterId=", counterId)

		return
	end

	self.patchBTCreatorDic[guideId][counterId] = bt

	print_notice("AddPatch success, guideId=", guideId, " counterId=", counterId)
end

function M:RemovePatch(guideId, counterId)
	if self.patchBTCreatorDic[guideId] then
		if counterId then
			if self.patchBTCreatorDic[guideId][counterId] then
				self.patchBTCreatorDic[guideId][counterId] = nil

				print_notice("RemovePatch success, guideId=", guideId, " counterId=", counterId)
			else
				print_warn("RemovePatch fail, not found patch, guideId=", guideId, " counterId=", counterId)
			end
		else
			self.patchBTCreatorDic[guideId] = nil

			print_notice("RemovePatch allCounter success, guideId=", guideId)
		end
	else
		print_warn("RemovePatch fail, not found patch, guideId=", guideId)
	end
end

function M:PreLoadGuide(guideId)
	if self.preLoadResourcesDic[guideId] then
		return
	end

	print_notice("[NewGuideMgr]预载引导资源, guideId=" .. guideId)

	local counterId = 1
	local btCreator = nil
	local patch = self.patchBTCreatorDic[guideId] and self.patchBTCreatorDic[guideId][counterId]

	if patch then
		btCreator = patch

		print_notice("PreLoadGuide use patch, guideId=", guideId, " counterId=", counterId)
	else
		local path = "LuaGen/GuideFlow/GuideBT/GuideBT_" .. guideId .. "_" .. counterId
		local ok, res = xpcall(dofile, tolua.traceback, path)

		if not ok then
			print_error("@huangzhecong: [NewGuide]: PreLoadGuide, 引导lua文件不存在", guideId, counterId, res)

			return
		end

		btCreator = res
	end

	local bt = btCreator.Create()
	bt.guideId = guideId
	bt.counterId = counterId
	local opList = self:_InternalPreLoadGuide(bt)

	if opList then
		self.preLoadResourcesDic[guideId] = opList
	end
end

function M:UnPreLoadGuide(guideId)
	local opList = self.preLoadResourcesDic[guideId]

	if opList then
		print_notice("[NewGuideMgr]释放预载资源, guideId=" .. guideId)

		for _, loadOp in pairs(opList) do
			if loadOp then
				gResourceManager:UnloadAssetLoadOp(loadOp)
			end
		end

		self.preLoadResourcesDic[guideId] = nil
	end
end

function M:_InternalPreLoadGuide(bt)
	if not bt.allResNode then
		print_warn("需要预加载的引导是老版本，请重新导出，guideId=", bt.guideId)

		return nil
	end

	local textList = {}
	local imageSet = {}
	local opList = {}

	for name, node in pairs(bt.allResNode) do
		if string.starts_with(name, "res_GuideText") then
			self:PreLoadGuideTextById(node.textId, textList, imageSet)
			self:PreLoadGuideTextById(node.controllerId, textList, imageSet)
			self:PreLoadGuideTextById(node.dualSenseId, textList, imageSet)
			self:PreLoadGuideTextById(node.mobileId, textList, imageSet)
		end
	end

	local combineStr = table.concat(textList)

	print_notice("[NewGuideMgr]预载字符" .. combineStr)
	SGUI.SDF.SDFAsyncFontAssetManager.CacheCharactersAddRefByFontName("MiSans-Medium_SDF", combineStr)

	for image, _ in pairs(imageSet) do
		local isSuccess, data = SGUI.UIConfig.instance:TryGetIconData(image, nil)

		if isSuccess then
			if not data or not data.url or data.url == "" then
				print_error("[NewGuideMgr]PreLoadGuideTextById get imagePath fail,data=", image)
			else
				local loadOp = gCS.LuaUtils.LoadSpriteAssetWithCallBack(data.url, function ()
					print_notice("[NewGuideMgr]预载图片Sprite完成" .. data.url)
				end, LX6.Engine.ResourceManager.LOAD_PRIORITY.PRIORITY_LEVEL4)

				table.insert(opList, loadOp)
				print_notice("[NewGuideMgr]开始预载图片Sprite" .. data.url)
			end
		else
			print_error("[NewGuideMgr]PreLoadGuideTextById get iconData fail,iconName=", image)
		end
	end

	return opList
end

function M:PreLoadGuideTextById(id, textList, imageSet)
	if not id then
		return
	end

	if id == 0 then
		return
	end

	local str = self:GetGuideTextById(id)

	if str ~= "" then
		local richText = gGuideGlyph:GetRichTextByGuideStrV1(str, imageSet)

		table.insert(textList, richText)
	end
end

function M:GetGuideTextById(id)
	local cfg = LTConfig.GuideGuideTextConfig.GetConfig(id)

	if not cfg then
		print_error("GetGuideTextById cfg is nil,id=", id)

		return ""
	end

	return cfg.Text
end

function M:ActiveGuide(guideId, counterId)
	local btCreator = nil
	local patch = self.patchBTCreatorDic[guideId] and self.patchBTCreatorDic[guideId][counterId]

	if patch then
		btCreator = patch

		print_notice("ActiveGuide use patch, guideId=", guideId, " counterId=", counterId)
	else
		local path = "LuaGen/GuideFlow/GuideBT/GuideBT_" .. guideId .. "_" .. counterId
		local ok, res = xpcall(dofile, tolua.traceback, path)

		if not ok then
			print_error("@huangzhecong: [NewGuide]: ActiveGuide, 引导lua文件不存在", guideId, counterId, res)

			return
		end

		btCreator = res
	end

	local bt = btCreator.Create()
	bt.guideId = guideId
	bt.counterId = counterId

	if not self.preLoadResourcesDic[guideId] then
		print_notice("[NewGuideMgr]ActiveGuide预载引导资源, guideId=" .. guideId)

		local opList = self:_InternalPreLoadGuide(bt)

		if opList then
			self.preLoadResourcesDic[guideId] = opList
		end
	end

	self.activeGuideBT = bt

	self:OnUpdate()
end

function M:GmActiveGuideFromCreator(btCreator)
	self:StopGuide()

	local bt = btCreator.Create()
	self.activeGuideBT = bt

	gGFManager:RefreshDynamicUpdate()
end

function M:StopGuide(finishByBT)
	if self.activeGuideBT then
		local guideId = self.activeGuideBT.guideId
		local counterId = self.activeGuideBT.counterId

		self.activeGuideBT:Exit()

		self.activeGuideBT = nil

		if self.enableDebug then
			self:UpdateDebugInfo({
				stop = true
			})
		end

		if not guideId then
			return
		end

		print_debug("[GuideFlow]: StopGuide", guideId, counterId)
		self:UnPreLoadGuide(guideId)

		if finishByBT then
			gMessageManager:SendMessage(gEventConstants.GUIDE_FLOW_FINISH, {
				guideId = guideId,
				counterId = counterId
			})
			self:TryRequestNextGuideCounter(guideId, counterId)
		end
	end

	gGFManager:RefreshDynamicUpdate()
end

function M:TryRequestNextGuideCounter(guideId, counter)
	local cfg = LTConfig.GuideGuideGroupConfig.GetConfig(guideId)

	if not cfg then
		return
	end

	if counter < cfg.GroupNum then
		if not self.ClientDebug then
			print_notice("GF Debug => AskDoGuide 请求触发下一个引导, GuideId=", guideId, " CounterId=", counter + 1, Time.time, Time.frameCount)

			gClientToGameDelegate:AskDoGuide(guideId, counter + 1).Callback = function (err)
				print_notice("GF Debug => AskDoGuide CallBack, GuideId=", guideId, " CounterId=", counter + 1, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)

				if err == LTConfig.MessageConfig.Ok then
					self:ActiveGuide(guideId, counter + 1)
				end
			end
		end
	elseif cfg.GroupNum == counter and not self.ClientDebug then
		print_notice("GF Debug => AskFinishGuide 请求结束引导, GuideId=", guideId, Time.time, Time.frameCount)

		gClientToGameDelegate:AskFinishGuide(guideId, true).Callback = function (err)
			print_notice("GF Debug => AskFinishGuide CallBack, GuideId=", guideId, "err=", gCS.Error.GetNameById(err), Time.time, Time.frameCount)
		end
	end
end

function M:NotifySignal(signal, liveTime)
	liveTime = liveTime or 0
	self.signals = self.signals or {}
	local signalInfo = self.signals[signal]

	if not signalInfo then
		signalInfo = {}
		self.signals[signal] = signalInfo
		signalInfo.fadeTime = Time.time + liveTime
	else
		local newFadeTime = Time.time + liveTime

		if signalInfo.fadeTime < newFadeTime then
			signalInfo.fadeTime = newFadeTime
		end
	end
end

function M:ClearSignal(signal)
	if self.signals and self.signals[signal] then
		self.signals[signal].fadeTime = 0
	end
end

function M:TryConsumeSignal(signal, rollbackTime)
	rollbackTime = rollbackTime or 1

	if self.signals then
		local curSignal = self.signals[signal]

		if curSignal then
			local cutoffTime = Time.time - rollbackTime

			if cutoffTime <= curSignal.fadeTime then
				curSignal.fadeTime = 0

				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function M:InitGuideUI()
	self.GuideUIResDef = {
		[EGuideUIResType.CommonGuideText] = {
			resName = "CommonGuideText",
			resPath = "Assets/Res/SGUI/Common/Guide/GuideText/S_FloatingGuideText.prefab",
			unique = true,
			meta = {
				__index = CommonGuideText
			}
		}
	}
	self._guideUIs = {}
	self._delayReleaseTimer = {}

	for resType, resDef in pairs(self.GuideUIResDef) do
		self._guideUIs[resType] = {}

		guideMgrSharp.RegisterCustomGuideUIResource(resType, resDef.resName, resDef.resPath)
	end
end

function M:OnControlSchemeChange()
	for resType, resMap in pairs(self._guideUIs) do
		for instanceId, guideUI in pairs(resMap) do
			if guideUI.OnControlSchemeChange then
				guideUI:OnControlSchemeChange()
			end
		end
	end
end

function M:OnLanguageChange()
	for resType, resMap in pairs(self._guideUIs) do
		for instanceId, guideUI in pairs(resMap) do
			if guideUI.OnLanguageChange then
				guideUI:OnLanguageChange()
			end
		end
	end
end

function M:TryGetCustomGuideUI(resType)
	local success, instanceId, root = guideMgrSharp.TryGetCustomGuideUI(resType, nil, nil)

	if not success then
		return false, nil
	end

	local resCfg = self.GuideUIResDef[resType]
	local resTypeContainer = self._guideUIs[resType]

	if resCfg.unique and next(resTypeContainer) then
		local lastGuideUI = resTypeContainer[next(resTypeContainer)]

		self:ReleaseCustomGuideUI(lastGuideUI)
	end

	local guideUI = setmetatable({}, self.GuideUIResDef[resType].meta)
	guideUI.rootWidget = root
	guideUI.instanceId = instanceId
	guideUI.resType = resType

	guideUI:OnInit()

	self._guideUIs[resType][instanceId] = guideUI

	return true, guideUI
end

function M:ReleaseCustomGuideUI(guideUI, delay)
	if guideUI then
		local instanceId = guideUI.instanceId

		if self._delayReleaseTimer[instanceId] then
			self._delayReleaseTimer[instanceId]:Stop()

			self._delayReleaseTimer[instanceId] = nil
		end

		if delay and delay > 0 then
			self._delayReleaseTimer[instanceId] = Timer.New(function ()
				self:ReleaseCustomGuideUI(guideUI)
			end, delay):Start()

			return
		end

		self._guideUIs[guideUI.resType][instanceId] = nil

		guideUI:OnDispose()
		guideMgrSharp.ReleaseCustomGuideUIInstance(guideUI.resType, guideUI.instanceId)
	end
end

function M:EnableDebug(enable)
	self.enableDebug = enable
end

function M:UpdateDebugInfo(debugInfo)
	if debugInfo ~= nil then
		gMessageManager:SendMessage(gEventConstants.ON_GF_DEBUG_INFO_CHANGE, debugInfo)
	end
end

function M:GetDebugInfo()
	return self.debugInfo
end

function M:ResolveOpenUGuide(uGuide)
	local panelId = uGuide.panelId

	if not panelId or panelId == 0 then
		return
	end

	if not self.panelIdToUGuide[panelId] then
		self.panelIdToUGuide[panelId] = {}
	end

	if not table.contains(self.panelIdToUGuide[panelId], uGuide) then
		table.insert(self.panelIdToUGuide[panelId], uGuide)

		self.registeredUGuideCount = self.registeredUGuideCount + 1

		self:RefreshPanelShowStateRegister()
	end
end

function M:ResolveDestroyUsedUGuide(uGuide)
	return
end

function M:ResolveCloseUGuide(uGuide)
	local panelId = uGuide.panelId

	if not panelId or panelId == 0 then
		return
	end

	if not self.panelIdToUGuide[panelId] then
		return
	end

	for i, uGuideInList in ipairs(self.panelIdToUGuide[panelId]) do
		if uGuideInList == uGuide then
			table.remove(self.panelIdToUGuide[panelId], i)

			self.registeredUGuideCount = self.registeredUGuideCount - 1

			self:RefreshPanelShowStateRegister()

			return
		end
	end
end

function M:RefreshPanelShowStateRegister()
	if self.registeredUGuideCount > 0 then
		if not self.isRegisteredPanelShowStateChange then
			gMessageManager:AddMessageListener(gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self.PanelShowStateChangeHandler)
			gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_SHOW, self.PanelShowStateChangeHandler)
			gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelShowStateChangeHandler)

			if self.panelCheckUpdateHandler then
				print_error("RefreshPanelShowStateChangeHandler UpdateBeat重复注册")
				UpdateBeat:RemoveListener(self.panelCheckUpdateHandler)
			else
				self.panelCheckUpdateHandler = UpdateBeat:CreateListener(self.PanelCheckUpdate, self)

				UpdateBeat:AddListener(self.panelCheckUpdateHandler)
			end

			self:SetPanelStateDirty()

			self.isRegisteredPanelShowStateChange = true
		end
	elseif self.isRegisteredPanelShowStateChange then
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_UI_SHOWSTATE_CHANGE, self.PanelShowStateChangeHandler)
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_SHOW, self.PanelShowStateChangeHandler)
		gMessageManager:RemoveMessageListener(gEventConstants.PANEL_ON_CLOSE, self.PanelShowStateChangeHandler)

		if self.panelCheckUpdateHandler then
			UpdateBeat:RemoveListener(self.panelCheckUpdateHandler)

			self.panelCheckUpdateHandler = nil
		else
			print_error("RefreshPanelShowStateChangeHandler UpdateBeat移除失败")
		end

		self.isRegisteredPanelShowStateChange = false
	end
end

function M:SetPanelStateDirty()
	self.isPanelStateDirty = true
end

function M:RefreshUGuides()
	for panelId, uGuideList in pairs(self.panelIdToUGuide) do
		if not uGuideList then
			return
		end

		local visible = gPanelManager:IsPanelVisible(panelId)

		for _, uGuide in ipairs(uGuideList) do
			if visible then
				uGuide:SetDisplayElementState(true)
			else
				uGuide:SetDisplayElementState(false)
			end
		end
	end
end

function M.PanelShowStateChangeHandler(_, _)
	gNewGuideMgr:SetPanelStateDirty()
end

function M:PanelCheckUpdate()
	if gNewGuideMgr.isNeedRefreshUGuide then
		gNewGuideMgr.isNeedRefreshUGuide = false

		gNewGuideMgr:RefreshUGuides()
	end

	if gNewGuideMgr.isPanelStateDirty then
		gNewGuideMgr.isPanelStateDirty = false
		gNewGuideMgr.isNeedRefreshUGuide = true
	end
end

function M:RemoveTimeScale()
	if gNewGuideMgr.globalPauseUUID then
		gCS.PauseManager.Instance:RemoveGlobalPause(gNewGuideMgr.globalPauseUUID)
		gCS.PauseManager.Instance:UpdateGlobalPause()

		gNewGuideMgr.globalPauseUUID = nil
	end
end
