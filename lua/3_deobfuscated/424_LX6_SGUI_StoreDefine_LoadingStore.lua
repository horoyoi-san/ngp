C_LoadingStore = DefClass("C_LoadingStore", C_LoadingStore, C_StoreGroup)
GroupName2Class.LoadingStore = C_LoadingStore
local M = C_LoadingStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local json = require("cjson/json")

function M:ctor()
	self.DEFINE_LogOutClearProxy = false

	self:InitProgressVar()
end

function M:OnAwake()
	self.panelId = gPanelId.PVP_LOADING_PANEL
	self.loadingTextId = 0
	self.showFullScreenMask = false
	self.targetData = nil

	gLoadingManager:SetLoadingPanel(self)
end

function M:OnDestroy()
	gLoadingManager:SetLoadingPanel(nil)
end

function M:OnShow(panelId, paramsDic)
	self:ShowFullScreenMask()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.LoadingPanel)
	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(true, gPanelId.PVP_LOADING_PANEL)
	gMessageManager:SendMessage(gEventConstants.LOADING_PANEL_OPENED)

	self.loadingTextId = 0

	self:ResetProgress()

	self.targetData = self:ParseLoadingParamsDicToTable(paramsDic)
	local loadingType = self.targetData.loadingType
	local isPreLoading = self.targetData.isPreLoading

	gCS.LoadingPanelManager:OnLoadingPanelShow(loadingType, isPreLoading)

	if not string.is_null_or_empty(self.targetData.loadingResModeParamsStr) then
		gResourceManager:EnterLoadingMode(false)
	else
		gResourceManager:EnterLoadingMode(true)
	end

	local isSoundTeleport = true

	if loadingType == gLoadingStorePanelShowType.Default then
		self:ShowDefault(self.targetData.textInfo)
	elseif loadingType == gLoadingStorePanelShowType.BlackTransition then
		self:ShowBlackTransition(self.targetData.textInfo)
	elseif loadingType == gLoadingStorePanelShowType.TransparentLoading then
		isSoundTeleport = false

		self:ShowTransparentLoading()
	elseif loadingType == gLoadingStorePanelShowType.PureBlackLoading then
		self:ShowPureBlackLoading()
	elseif loadingType == gLoadingStorePanelShowType.BlackLoading then
		self:ShowBlackLoading()
	elseif loadingType == gLoadingStorePanelShowType.MulPlayerLoading then
		self:ShowMulPlayerLoading(self.targetData)
	elseif loadingType == gLoadingStorePanelShowType.ShortReconnectLoading then
		self:ShowShortReconnectLoading()
	elseif loadingType == gLoadingStorePanelShowType.RobotLoading then
		self:ShowRobotLoading()
	else
		self:ShowDefault()
	end

	if isSoundTeleport then
		gSoundMgr:OnEnterStateArea("LoadingUI", {
			gSoundMgr.GameStateGroup.GamePlay_Mix.StateName
		}, {
			gSoundMgr.GameStateGroup.GamePlay_Mix.Teleporting
		}, gSoundMgr.GameStatePriority.Loading)
	end
end

function M:OnDisable()
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.LoadingPanel)
	gCS.LoadingPanelManager:OnLoadingPanelClose()
	gLuaDataManager.guiMgr:SetUICameraEnabled(true)
	gResourceManager:EnterLoadingMode(false)

	if LX6.Utils.ComponentHolder.TimelineCamera == nil then
		gCS.CameraDataMgr.MainCameraEnabled = true
	end

	gSoundMgr:OnLeaveStateArea("LoadingUI")
	gLoadingManager:RefreshDataOpenLoadingFinish(self.loadingTextId)

	self.loadingTextId = 0

	LX6.GUI.GuiMgr.Instance:SetShowScenePanel(false, gPanelId.PVP_LOADING_PANEL)
	gMessageManager:SendMessage(gEventConstants.LOADING_PANEL_CLOSED)
end

function M:OnClose()
	self:OnDisable()

	self.targetData = nil
end

function M:ShowDefault(textInfo)
	gCS.CameraDataMgr.MainCameraEnabled = false
	self.bindData.loadingType = gLoadingStorePanelShowType.Default

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

function M:ShowBlackTransition(textInfo)
	gCS.CameraDataMgr.MainCameraEnabled = false
	self.bindData.loadingType = gLoadingStorePanelShowType.BlackTransition

	if table.isNilOrEmpty(textInfo) then
		self.bindData.blackTransition_ShowText = BOOL2CTL[false]
	elseif string.is_null_or_empty(textInfo.text) then
		self.bindData.blackTransition_ShowText = BOOL2CTL[false]
	else
		self.bindData.blackTransition_ShowText = BOOL2CTL[true]
		self.bindData.blackTransition_Text = textInfo.text
	end
end

function M:ShowTransparentLoading()
	self.bindData.loadingType = gLoadingStorePanelShowType.TransparentLoading
end

function M:ShowPureBlackLoading()
	gCS.CameraDataMgr.MainCameraEnabled = false
	local color = Color.New(0, 0, 0)
	self.bindData.loadingType = gLoadingStorePanelShowType.PureBlackLoading
	self.bindData.pureBlack_Color = color
end

function M:ShowBlackLoading()
	gCS.CameraDataMgr.MainCameraEnabled = false
	self.bindData.loadingType = gLoadingStorePanelShowType.BlackLoading
end

function M:ShowMulPlayerLoading(loadingData)
	gCS.CameraDataMgr.MainCameraEnabled = false
	self.bindData.loadingType = gLoadingStorePanelShowType.MulPlayerLoading
	local hasMultiPlayerInfo = loadingData and loadingData.hasLinkPlayerInfo or false
	self.bindData.multiPlayerShow = hasMultiPlayerInfo and 0 or 1

	if hasMultiPlayerInfo then
		self.bindData.multiPlayerList.luaSimpleRenderItem = self:CreateAction(self.OnMultiPlayerRenderItem)

		self:RefreshLinkPlayerInfoView()
	end
end

function M:ShowShortReconnectLoading()
	self.bindData.loadingType = gLoadingStorePanelShowType.ShortReconnectLoading
end

function M:ShowRobotLoading()
	self.bindData.loadingType = gLoadingStorePanelShowType.RobotLoading
	self.progressSpeedStandard = 10
	self.progressSpeed = self.progressSpeedStandard
end

function M:ShowFullScreenMask()
	self.bindData.showFullScreenMask = BOOL2CTL[self.showFullScreenMask]
end

function M:OnMultiPlayerRenderItem(btn, index)
	if not self.targetData or not self.targetData.linkPlayerInfoList or #self.targetData.linkPlayerInfoList == 0 then
		return
	end

	local linkPlayerInfoList = self.targetData.linkPlayerInfoList
	local storeName = btn.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
	local data = linkPlayerInfoList[index + 1]
	store.useCache = true
	store.pid = data.pid
	store.IsLoading = data.loadingProgress >= 1 and 1 or 0
end

function M:RefreshLinkPlayerInfoView()
	if not self.targetData or not self.targetData.linkPlayerInfoList or #self.targetData.linkPlayerInfoList == 0 then
		return
	end

	self.bindData.multiPlayerList:SetSimpleList(#self.targetData.linkPlayerInfoList)
end

function M:UpdateMultiPlayerLoadRate(pid, rate)
	if not self.targetData or not self.targetData.hasLinkPlayerInfo then
		return
	end

	for _, playerInfo in ipairs(self.targetData.linkPlayerInfoList) do
		if playerInfo.pid == pid then
			playerInfo.loadingProgress = rate

			break
		end
	end

	self:RefreshLinkPlayerInfoView()
end

function M:ResetProgress()
	self:InitProgressVar()

	self.bindData.multiPlayer_Progress = "0%"
	self.bindData.robot_fillAmount = 0
end

function M:InitProgressVar()
	self.progress = 0
	self.progressSpeedStandard = 1
	self.progressSpeed = self.progressSpeedStandard
	self.progressReached = true
	self.progressLimit = 0
end

function M:SetProgressLimit(val)
	if val <= self.progressLimit then
		return
	end

	if val == 100 then
		self.progress = 100
		self.progressSpeed = self.progressSpeedStandard
		self.bindData.multiPlayer_Progress = tostring(math.floor(self.progress)) .. "%"
		self.bindData.robot_fillAmount = 1
	elseif self.progressReached then
		self.progressSpeed = self.progressSpeedStandard
	else
		self.progressSpeed = self.progressSpeedStandard * 10
	end

	self.progressLimit = val
end

function M:OnUpdate()
	if not self.progress or not self.progressLimit then
		return
	end

	if self.progressLimit <= self.progress then
		self.progressReached = true
	else
		self.progressReached = false
		self.progress = self.progress + self.progressSpeed * gLogicTime.unscaledDeltaTime

		if self.progressLimit < self.progress then
			self.progress = self.progressLimit
		end

		self.bindData.multiPlayer_Progress = tostring(math.floor(self.progress)) .. "%"
		self.bindData.robot_fillAmount = self.progress / 100
	end
end

function M:NotifyLoadingSceneLoaded()
	if not self.targetData or not self.targetData.hasLinkPlayerInfo then
		return
	end

	self:UpdateMultiPlayerLoadRate(gCS.MyPlayerManager.PlayerUnit.Pid, 1)
end

function M:SetFullScreenMaskActive(active)
	self.showFullScreenMask = active

	self:ShowFullScreenMask()
end

function M:ParseLoadingParamsDicToTable(paramsDic)
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
	local linkPlayerInfoList = paramsTable and paramsTable.linkPlayerInfoList
	loadingData.hasLinkPlayerInfo = false
	loadingData.linkPlayerInfoList = {}
	local playerPIds = {}

	if linkPlayerInfoList then
		local linkPlayerInfoArr = linkPlayerInfoList:ToTable()
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

	gFriendManager:GetSimplePlayerInfoByPidList(playerPIds, function (datas)
		if table.isNilOrEmpty(datas) then
			loadingData.hasLinkPlayerInfo = false
		end
	end, false)

	return loadingData
end
