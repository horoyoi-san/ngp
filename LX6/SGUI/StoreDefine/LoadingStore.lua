-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LoadingStore.lua
-- Decompiled from: 01786_LoadingStore.lua_2e29080cc5b9.luajit

C_LoadingStore = DefClass("C_LoadingStore", C_LoadingStore, C_StoreGroup)
GroupName2Class.LoadingStore = C_LoadingStore
local M = C_LoadingStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
	self.DEFINE_LogOutClearProxy = false
	self.bindUIType = {
		["\\xfd\\xde(\\xe5"] = 0,
		["&!\\xe7x\\xac\\xe55\\xa6<\\xef\\xe6\\xef{\\xf5"] = 1,
		["]y\\xaexX\\x9e\\xfdFnspK"] = 7,
		["W\\x88\\x95\\x9dб\\xc60\\x850\\xb68"] = 3,
		["2(\\x91㸷鴿\\x86\\xc9\\xce=Ǟ)\\x91\\xe5"] = 2,
		["J\\x96\\xa0\\xb3ݩ\\xc0)\\x850\\xb68"] = 5,
		["Mz\\xadtG\\x9e\\xfdFnspK"] = 4,
		["<>\\xbb\\xf2+#p1\\x981*ٰ\\x9a2\\x9d\\x9eǉ"] = 6
	}

	self:InitProgressVar()
	gLoadingManager:SetLoadingPanel(self)
end

M.OnAwake = function(self)
	self.panelId = gPanelId.PVP_LOADING_PANEL
	self.loadingTextId = 0
	self.showFullScreenMask = false
	self.targetData = nil
	self.sameImageEffectUUId = 0
	self.loadingType = nil
end

M.OnDestroy = function(self)
	gLoadingManager:SetLoadingPanel(nil)
end

M.OnShow = function(self, panelId, paramsDic)
	self:ShowFullScreenMask()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.LoadingPanel)
	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(true, gPanelId.PVP_LOADING_PANEL)

	self.loadingTextId = 0

	self:ResetProgress()

	self.targetData = self:ParseLoadingParamsDicToTable(paramsDic)
	local loadingType = self.targetData.loadingType
	local isPreLoading = self.targetData.isPreLoading

	gCS.LoadingPanelManager:OnLoadingPanelShow(loadingType, isPreLoading)

	local loadingMode = self.targetData.loadingMode

	gResourceManager:EnterLoadingMode(loadingMode)
	self:ChangeLoadingPanelShowType(loadingType)
end

M.OnDisable = function(self)
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.LoadingPanel)
	gLuaDataManager.guiMgr:SetUICameraEnabled(true)
	gResourceManager:EnterLoadingMode(3)

	if LX6.Utils.ComponentHolder.TimelineCamera ~= nil then
		gCS.CameraDataMgr.MainCameraEnabled = true
	end

	gSoundMgr:OnLeaveStateArea("LoadingUI")

	if self.loadingTextId and self.loadingTextId <= 0 then
		gLoadingManager:RefreshDataOpenLoadingFinish(self.loadingTextId)
	end

	self.loadingTextId = 0

	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.PVP_LOADING_PANEL)
end

M.OnClose = function(self)
	self:OnDisable()
	gCS.LoadingPanelManager:OnLoadingPanelClose()
	self:StopSameImageScreenEffect()

	self.targetData = nil
end

M.ChangeLoadingPanelShowType = function(self, loadingStorePanelShowType)
	gSoundMgr:OnLeaveStateArea("LoadingUI")

	if self.loadingType ~= gLoadingStorePanelShowType.SameImageTransparent and loadingStorePanelShowType == gLoadingStorePanelShowType.SameImageTransparent then
		self.StopSameImageScreenEffect(self)
	end

	local isSoundTeleport = true
	local loadingType = loadingStorePanelShowType

	if loadingType ~= gLoadingStorePanelShowType.Default then
		self.ShowDefault(self, self.targetData.textInfo)
	elseif loadingType ~= gLoadingStorePanelShowType.BlackTransition then
		self.ShowBlackTransition(self, self.targetData.textInfo)
	elseif loadingType ~= gLoadingStorePanelShowType.TransparentLoading then
		isSoundTeleport = false

		self.ShowTransparentLoading(self)
	elseif loadingType ~= gLoadingStorePanelShowType.SameImageTransparent then
		isSoundTeleport = false

		self.ShowSameImageTransparent(self)
	elseif loadingType ~= gLoadingStorePanelShowType.PureBlackLoading then
		self.ShowPureBlackLoading(self)
	elseif loadingType ~= gLoadingStorePanelShowType.BlackLoading then
		self.ShowBlackLoading(self)
	elseif loadingType ~= gLoadingStorePanelShowType.MulPlayerLoading then
		self.ShowMulPlayerLoading(self, self.targetData)
	elseif loadingType ~= gLoadingStorePanelShowType.ShortReconnectLoading then
		self.ShowShortReconnectLoading(self)
	elseif loadingType ~= gLoadingStorePanelShowType.RobotLoading then
		self.ShowRobotLoading(self, self.targetData.summonType)
	else
		self.ShowDefault(self)
	end

	if isSoundTeleport then
		gSoundMgr:OnEnterStateArea("LoadingUI", {
			gSoundMgr.GameStateGroup.GamePlay_Mix.StateName
		}, {
			gSoundMgr.GameStateGroup.GamePlay_Mix.Teleporting
		}, gSoundMgr.GameStatePriority.Loading)
	end
end

M.CheckMaskLoadingTypeCamEnabled = function(self)
	if gLoadingManager:GetSwitcherVal(0) then
		return true
	end

	return false
end

M.ShowDefault = function(self, textInfo)
	gCS.CameraDataMgr.MainCameraEnabled = self.CheckMaskLoadingTypeCamEnabled(self)
	self.bindData.loadingType = self.bindUIType.Default
	self.loadingType = gLoadingStorePanelShowType.Default

	if table.isNilOrEmpty(textInfo) then
		self.bindData.default_ShowGuideText = BOOL2CTL[false]
	else
		self.loadingTextId = textInfo.loadingTextId or 0

		if string.is_null_or_empty(textInfo.text) then
			self.bindData.default_ShowGuideText = BOOL2CTL[false]
		else
			self.bindData.default_ShowGuideText = BOOL2CTL[true]
			self.bindData.default_Text = textInfo.text
		end
	end
end

M.ShowBlackTransition = function(self, textInfo)
	gCS.CameraDataMgr.MainCameraEnabled = self.CheckMaskLoadingTypeCamEnabled(self)
	self.bindData.loadingType = self.bindUIType.BlackTransition
	self.loadingType = gLoadingStorePanelShowType.BlackTransition

	if table.isNilOrEmpty(textInfo) then
		self.bindData.blackTransition_ShowText = BOOL2CTL[false]
	elseif string.is_null_or_empty(textInfo.text) then
		self.bindData.blackTransition_ShowText = BOOL2CTL[false]
	else
		self.bindData.blackTransition_ShowText = BOOL2CTL[true]
		self.bindData.blackTransition_Text = textInfo.text
	end
end

M.ShowTransparentLoading = function(self)
	gCS.CameraDataMgr.MainCameraEnabled = true
	self.bindData.loadingType = self.bindUIType.TransparentLoading
	self.loadingType = gLoadingStorePanelShowType.TransparentLoading
end

M.ShowSameImageTransparent = function(self)
	gCS.CameraDataMgr.MainCameraEnabled = true
	self.bindData.loadingType = self.bindUIType.TransparentLoading
	self.loadingType = gLoadingStorePanelShowType.SameImageTransparent

	self.StartSameImageScreenEffect(self)
end

M.StartSameImageScreenEffect = function(self)
	if self.sameImageEffectUUId and self.sameImageEffectUUId == 0 then
		return
	end

	local effectId = LTConfig.LoadingConfig.SwitchSceneSameImageEff
	self.sameImageEffectUUId = gCS.EffectMgr:PlayEffect(effectId, LX6.Effect.EffectPlayTag.UI)
end

M.StopSameImageScreenEffect = function(self)
	if not self.sameImageEffectUUId or self.sameImageEffectUUId ~= 0 then
		return
	end

	gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.sameImageEffectUUId)

	self.sameImageEffectUUId = 0
end

M.ShowPureBlackLoading = function(self)
	gCS.CameraDataMgr.MainCameraEnabled = self.CheckMaskLoadingTypeCamEnabled(self)
	local color = Color.New(0, 0, 0)
	self.bindData.loadingType = self.bindUIType.PureBlackLoading
	self.loadingType = gLoadingStorePanelShowType.PureBlackLoading
	self.bindData.pureBlack_Color = color
end

M.ShowBlackLoading = function(self)
	gCS.CameraDataMgr.MainCameraEnabled = self.CheckMaskLoadingTypeCamEnabled(self)
	self.bindData.loadingType = self.bindUIType.BlackLoading
	self.loadingType = gLoadingStorePanelShowType.BlackLoading
end

M.ShowMulPlayerLoading = function(self, loadingData)
	gCS.CameraDataMgr.MainCameraEnabled = self:CheckMaskLoadingTypeCamEnabled()
	self.bindData.loadingType = self.bindUIType.MulPlayerLoading
	self.loadingType = gLoadingStorePanelShowType.MulPlayerLoading
	local hasMultiPlayerInfo = loadingData and loadingData.hasLinkPlayerInfo or false
	self.bindData.multiPlayerShow = hasMultiPlayerInfo and 0 or 1

	if hasMultiPlayerInfo then
		self.bindData.multiPlayerList.luaSimpleRenderItem = self.CreateAction(self, self.OnMultiPlayerRenderItem)

		self.RefreshLinkPlayerInfoView(self)
	end
end

M.ShowShortReconnectLoading = function(self)
	gCS.CameraDataMgr.MainCameraEnabled = true
	self.bindData.loadingType = self.bindUIType.ShortReconnectLoading
	self.loadingType = gLoadingStorePanelShowType.ShortReconnectLoading
end

M.ShowRobotLoading = function(self, summonType)
	gCS.CameraDataMgr.MainCameraEnabled = self.CheckMaskLoadingTypeCamEnabled(self)
	self.bindData.loadingType = self.bindUIType.RobotLoading
	self.loadingType = gLoadingStorePanelShowType.RobotLoading
	self.progressSpeedStandard = 10
	self.progressSpeed = self.progressSpeedStandard
	local robotIcon = 28003438

	if summonType ~= LTConfig.SummonConfig.TypeType.UAV then
		robotIcon = 28003440
	elseif summonType ~= LTConfig.SummonConfig.TypeType.Dog then
		robotIcon = 28001432
	elseif summonType ~= LTConfig.SummonConfig.TypeType.SpiderBot then
		robotIcon = 28003439
	end

	local cfg = LTConfig.SguiImageConfig.GetConfig(robotIcon)

	if cfg then
		local url = cfg.ImgPath
		self.bindData.robotIconActive = false
		slot5 = self.bindData.robotIcon

		slot5:SetUrlWithCallback(url, function ()
			if self.bindData then
				self.bindData.robotIconActive = true
			end
		end)
	end
end

M.ShowFullScreenMask = function(self)
	self.bindData.showFullScreenMask = BOOL2CTL[self.showFullScreenMask]
end

M.OnMultiPlayerRenderItem = function(self, btn, index)
	if not self.targetData or not self.targetData.linkPlayerInfoList or #self.targetData.linkPlayerInfoList ~= 0 then
		return
	end

	local linkPlayerInfoList = self.targetData.linkPlayerInfoList
	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
	local data = linkPlayerInfoList[index + 1]
	local userInfo = store.userInfo

	if userInfo then
		userInfo.pid = data.pid
		userInfo.useCache = true
	end
end

M.RefreshLinkPlayerInfoView = function(self)
	if not self.targetData or not self.targetData.linkPlayerInfoList or #self.targetData.linkPlayerInfoList ~= 0 then
		return
	end

	self.bindData.multiPlayerList:SetSimpleList(#self.targetData.linkPlayerInfoList)
end

M.UpdateMultiPlayerLoadRate = function(self, pid, rate)
	if not self.targetData or not self.targetData.hasLinkPlayerInfo then
		return
	end

	for _, playerInfo in ipairs(self.targetData.linkPlayerInfoList) do
		if playerInfo.pid ~= pid then
			playerInfo.loadingProgress = rate

			break
		end
	end
end

M.CheckShowMultiSelfLoaded = function(self)
	local selfLoadedProgress = 90

	if selfLoadedProgress < self.progress and not self.multiShowTip then
		self.multiShowTip = true
		self.bindData.multiShowTip = true
	end
end

M.ResetProgress = function(self)
	self.InitProgressVar(self)

	self.bindData.multiShowTip = false
	self.multiShowTip = false
	self.bindData.multiPlayer_Progress = "0%"
	self.bindData.multiPlayer_Progress2 = "0%"
	self.bindData.robot_fillAmount = 0
	self.bindData.multiFillAmount = 0
end

M.InitProgressVar = function(self)
	self.progress = 0
	self.progressSpeedStandard = 1
	self.progressSpeed = self.progressSpeedStandard
	self.progressReached = true
	self.progressLimit = 0
end

M.SetProgressLimit = function(self, val)
	if val < self.progressLimit then
		return
	end

	if val ~= 100 then
		self.progress = 100
		self.progressSpeed = self.progressSpeedStandard
		self.bindData.multiPlayer_Progress = tostring(math.floor(self.progress)) .. "%"
		self.bindData.multiPlayer_Progress2 = tostring(math.floor(self.progress)) .. "%"
		self.bindData.robot_fillAmount = 1
		self.bindData.multiFillAmount = 1
	elseif self.progressReached then
		self.progressSpeed = self.progressSpeedStandard
	else
		self.progressSpeed = self.progressSpeedStandard * 10
	end

	self.progressLimit = val
end

M.OnUpdate = function(self)
	if not self.progress or not self.progressLimit then
		return
	end

	if self.progressLimit < self.progress then
		self.progressReached = true
	else
		self.progressReached = false
		self.progress = self.progress + self.progressSpeed * gLogicTime.unscaledDeltaTime

		if self.progressLimit >= self.progress then
			self.progress = self.progressLimit
		end

		self.bindData.multiPlayer_Progress = tostring(math.floor(self.progress)) .. "%"
		self.bindData.multiPlayer_Progress2 = tostring(math.floor(self.progress)) .. "%"
		self.bindData.robot_fillAmount = self.progress / 100
		self.bindData.multiFillAmount = self.progress / 100
	end

	self.CheckShowMultiSelfLoaded(self)
end

M.ParseLoadingParamsDicToTable = function(self, paramsDic)
	local paramsTable = paramsDic and paramsDic:ToTable()
	local loadingData = {
		loadingType = paramsTable and paramsTable.loadingType or gLoadingStorePanelShowType.Default,
		isPreLoading = paramsTable and paramsTable.isPreLoading or false
	}
	local textInfo = {
		loadingTextId = paramsTable and paramsTable.loadingTextId or 0,
		text = paramsTable and paramsTable.loadingText
	}
	loadingData.textInfo = textInfo
	loadingData.linkGameType = paramsTable and paramsTable.linkGameType or 0
	loadingData.loadingMode = paramsTable and paramsTable.loadingMode or 0
	loadingData.summonType = paramsTable and paramsTable.summonType
	local linkPlayerInfoList = paramsTable and paramsTable.linkPlayerInfoList
	loadingData.hasLinkPlayerInfo = false
	loadingData.linkPlayerInfoList = {}
	local playerPIds = {}

	if linkPlayerInfoList then
		local linkPlayerInfoArr = linkPlayerInfoList.ToTable(linkPlayerInfoList)
		loadingData.hasLinkPlayerInfo = true

		for i = 1, #linkPlayerInfoArr do
			local v = linkPlayerInfoArr[i]
			local linkPlayerInfoTable = {
				pid = v.pid,
				loadingProgress = v.loadingProgress
			}

			table.insert(playerPIds, v.pid)
			table.insert(loadingData.linkPlayerInfoList, linkPlayerInfoTable)
		end
	end

	slot7 = gFriendManager

	slot7:GetSimplePlayerInfoByPidList(playerPIds, function (datas)
		if table.isNilOrEmpty(datas) then
			loadingData.hasLinkPlayerInfo = false
		end
	end, false)

	return loadingData
end
