-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MultiverseInitialPanelStore.lua
-- Decompiled from: 01049_MultiverseInitialPanelStore.lua_7da8be7ae04d.luajit

local MultiverseMainPanelConfig = LTConfig.MultiverseMainPanelConfig
local MultiverseMetaConfig = LTConfig.MultiverseMultiverseMetaConfig
local TabConfig = LTConfig.MultiverseTabConfig
local MessageConfig = LTConfig.MessageConfig
local ClientConsts = gClientConst
local DOWNLOAD_TYPE_CTRL = {
	[",i\\xa4\\xbd\\xa6e"] = 0,
	["\\xe8\\xee1(7\n\\xd6"] = 3,
	["\\xbbT\\xb2`\\xfd\\x84\\x9e"] = 1,
	["SQ~"] = 2
}
local DOWNLOAD_TYPE_PRIORITY = {
	[DOWNLOAD_TYPE_CTRL.IDLE] = 0,
	[DOWNLOAD_TYPE_CTRL.PAUSED] = 1,
	[DOWNLOAD_TYPE_CTRL.QUEUING] = 2,
	[DOWNLOAD_TYPE_CTRL.DOWNLOADING] = 3
}
C_MultiverseInitialPanelStore = DefClass("C_MultiverseInitialPanelStore", C_MultiverseInitialPanelStore, C_StoreGroup)
GroupName2Class.MultiverseInitialPanelStore = C_MultiverseInitialPanelStore
local M = C_MultiverseInitialPanelStore

M.ctor = function(self)
	self.mgr = gMultiverseMgr
	self.dlcMgr = gDlcDownLoadMgr
end

M.DefineAllVariables = function(self)
	self.verseLists = {}
	self.tabList = {}
	self.currentVerseCfg = nil
	self.forbidClose = false
	self.frontPageData = {}
	self.subVerseIdMap = {}
	self.inEnterMultiverse = false
	self.downloadPartStore = nil
	self.gameProgressPartStore = nil
	self.currentBundleIds = {}
	self.raidMetaCfg = {}
	self.currentTaskLineInfo = nil
	self.verseHasPendingDownload = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.pageEnum = {
		["\\xad;/+G\\xad@\\xde2\\xfa\\xeb"] = 1,
		["\\xad;/+G\\xad@\\xde2\\xfa\\xea"] = 2,
		["\\xad;/+G\\xad@\\xde2\\xfa\\xe8"] = 0
	}
	self.isPublishEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isLockedCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isInGameCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isGameProgressCtrlEnum = {
		["hw\\xa1r\\\\xa0\\xfd@xm_"] = 1,
		["\\xaf\\xbe\\xa5f1\\xff7"] = 0,
		["t-s^"] = 2
	}
	self.isLastEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isPlayingEnum = {
		["\\xbc!2-}\\x93U\\xe9;\\xab\\xa0"] = 1,
		["\\x87\\xb0\\xbfZ2\\xff*"] = 0
	}
	self.downloadingStatusCtrlEnum = {
		["\\xf6\\xd5*\\xf6"] = 1,
		["\\x8d\\xb8\\xa2y6\\xfb7"] = 0,
		["~\\xba\\xa3\\xbd\\xa2"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.pageEnum = nil
	self.isPublishEnum = nil
	self.isLockedCtrlEnum = nil
	self.isInGameCtrlEnum = nil
	self.isGameProgressCtrlEnum = nil
	self.isLastEnum = nil
	self.isPlayingEnum = nil
	self.downloadingStatusCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:InitDownloadPart()
	self:InitGameProgressPart()

	self.forbidClose = data and data.forbidClose or false
	self.tabList = self.mgr:GetTabList()

	self:OnChangeTabIndex(0)

	self.bindData.isPublish = gCS.LuaUtils.IsPublish and self.isPublishEnum._true or self.isPublishEnum._false

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, self.bindData.page, nil, self:CreateAction(self.OnChangeTab))
	self.mgr:AskMultiverseStatus()
end

M.OnClose = function(self)
	self.forbidClose = false
	self.currentVerseCfg = nil
	self.currentBundleIds = {}
	self.currentTaskLineInfo = nil
	self.verseHasPendingDownload = {}
end

M.RefreshFrontPage = function(self)
	self.subVerseIdMap = self:GetSubVerseIdMap()
	self.verseLists = self:FilterRootVerseList(self.mgr:GetSortedVerseList())

	self.bindData.gameModuleList:SetSimpleList(#self.verseLists)

	if #self.verseLists <= 0 then
		local index = 1

		if self.currentVerseCfg then
			for i, verse in ipairs(self.verseLists) do
				if verse.id ~= self.currentVerseCfg.Id then
					index = i

					break
				end
			end
		end

		self:SelectVerse(index)
		self.bindData.gameModuleList:SelectItem(index - 1, true)
	end
end

M.GetSubVerseIdMap = function(self)
	local ret = {}

	for i = 0, MultiverseMainPanelConfig.count - 1 do
		local cfg = MultiverseMainPanelConfig.LoadAt(i)
		local subVerse = cfg and cfg.SubVerse

		if subVerse then
			for _, id in ipairs(subVerse) do
				if id and id <= 0 then
					ret[id] = true
				end
			end
		end
	end

	return ret
end

M.IsVerseOrSubVerse = function(self, verseId, targetId)
	if verseId ~= targetId then
		return true
	end

	local cfg = MultiverseMainPanelConfig.GetConfig(verseId)
	local subVerse = cfg and cfg.SubVerse

	if subVerse then
		for _, id in ipairs(subVerse) do
			if id ~= targetId then
				return true
			end
		end
	end

	return false
end

M.FilterRootVerseList = function(self, verseList)
	local ret = {}

	for _, verseData in ipairs(verseList) do
		if not self.subVerseIdMap[verseData.id] then
			table.insert(ret, verseData)
		end
	end

	return ret
end

M.GetSubVerseList = function(self, cfg)
	local ret = {}
	local subVerse = cfg and cfg.SubVerse

	if not subVerse then
		return ret
	end

	for _, id in ipairs(subVerse) do
		local subCfg = id and MultiverseMainPanelConfig.GetConfig(id)

		if subCfg then
			table.insert(ret, subCfg)
		end
	end

	return ret
end

M.SelectVerse = function(self, index)
	local verseId = self.verseLists[index] and self.verseLists[index].id or 0
	local cfg = MultiverseMainPanelConfig.GetConfig(verseId)

	if not cfg then
		return
	end

	self.currentVerseCfg = cfg

	self.bindData.background:SetUrlWithCallback(gUIUtils:GetSguiImagePath(cfg.Image), nil)

	self.bindData.promotionTitle = cfg.Name
	self.bindData.promotionDesc = cfg.Des or ""
	self.bindData.isLockedCtrl = ClientConsts.BOOL2CTL[not self.mgr:CheckVerse(verseId)]
	self.bindData.lockTitleLabel = cfg.UnlockConditionStr
	self.bindData.isInGameCtrl = ClientConsts.BOOL2CTL[gSceneDataMgr.CurrentRaidId == 0 and self.mgr.curVerse ~= cfg.Id]

	self:RefreshDownloadPart(cfg)

	local tag, tagLabel = self.mgr:GetVerseTag(cfg.Tags)

	self.bindData.tagList:SetSimpleList(0)

	if tag and tag > 0 then
		self.bindData.tagList:AddSimpleLabel(tag, tagLabel or "")
		self.bindData.tagList:RefreshList()
	end
end

M.OnMultiverseStatusChange = function(self)
	local data = self.tabList[self.bindData.page + 1]

	if data and data.id ~= TabConfig.Play then
		self.RefreshFrontPage(self)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.MULTIVERSE_STATE_CHANGE] = self.CreateAction(self, self.OnMultiverseStatusChange),
		[gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED] = self.CreateAction(self, self.OnDlcDownloadProgressChanged),
		[gEventConstants.TASK_STATE_CHANGED] = self.CreateAction(self, self.OnTaskStateChanged)
	}
end

M.RegisterWidget = function(self)
	self.bindData.settingsBtn.luaClick = self.CreateAction(self, self.OnClickSettingsBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.accountBtn.luaClick = self.CreateAction(self, self.OnClickAccountBtn)

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	end

	self.bindData.gameModuleList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderGameModuleListItem)
	self.bindData.gameModuleList.luaSelectedChanged = self.CreateAction(self, self.OnGameModuleListSelectedChanged)
end

M.InitGameProgressPart = function(self)
	if not self.bindData.gameProgressPart then
		return
	end

	self.gameProgressPartStore = gStoreManager:GetStoreGroup(self.bindData.gameProgressPart.Store):GetStoreByWidget(self.bindData.gameProgressPart)

	if not self.gameProgressPartStore then
		print_error("[MultiverseInitialPanelStore] 无法获取 gameProgressPart Store")

		return
	end

	self.gameProgressPartStore.replayBtn.luaClick = self.CreateAction(self, self.OnClickGameReplayBtn)
end

M.GetVerseMetaConfig = function(self, cfg)
	local raidId = cfg and cfg.OpenWorldRaid

	if not raidId or raidId ~= 0 then
		return nil
	end

	if self.raidMetaCfg[raidId] == nil then
		return self.raidMetaCfg[raidId] or nil
	end

	local metaCfg = false

	for i = 0, MultiverseMetaConfig.count - 1 do
		local candidate = MultiverseMetaConfig.LoadAt(i)

		if candidate and candidate.OpenWorldRaid ~= raidId then
			metaCfg = candidate

			break
		end
	end

	self.raidMetaCfg[raidId] = metaCfg

	return metaCfg or nil
end

M.RefreshGameProgressPart = function(self, cfg)
	cfg = cfg or self.currentVerseCfg
	local metaCfg = self:GetVerseMetaConfig(cfg)
	local firstTaskId = metaCfg and metaCfg.FirstEnterTask
	local taskLineInfo = firstTaskId and firstTaskId <= 0 and gTaskNodeManager:GetTaskLineByTask(firstTaskId) or nil
	self.currentTaskLineInfo = taskLineInfo
	local completedCount = 0
	local totalCount = taskLineInfo and #taskLineInfo.TaskList or 0

	if taskLineInfo then
		for _, taskId in ipairs(taskLineInfo.TaskList) do
			if gTaskManager:GetTaskState(taskId) ~= UX.Game.TaskState.Submited then
				completedCount = completedCount + 1
			end
		end
	end

	local isTaskLineFinished = taskLineInfo and gTaskNodeManager:IsTaskLineFinish(taskLineInfo) or false
	local progressValue = isTaskLineFinished and 1 or totalCount <= 0 and completedCount / totalCount or 0
	local store = self.gameProgressPartStore

	if not store then
		return
	end

	if store.progress then
		store.progress:ProgressToValue(progressValue)
	end

	store.replayBtn.interactable = isTaskLineFinished

	store.replayBtn:SetActive(isTaskLineFinished)
end

M.OnClickGameReplayBtn = function(self)
	local taskLineInfo = self.currentTaskLineInfo

	if not taskLineInfo or not gTaskNodeManager:IsTaskLineFinish(taskLineInfo) then
		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskReAcceptTaskFailGroup(taskLineInfo.StartTask).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnTaskStateChanged = function(self)
	if self.currentVerseCfg then
		self.RefreshGameProgressPart(self)
	end
end

M.InitDownloadPart = function(self)
	if not self.bindData.downloadPart then
		return
	end

	self.downloadPartStore = gStoreManager:GetStoreGroup(self.bindData.downloadPart.Store):GetStoreByWidget(self.bindData.downloadPart)

	if not self.downloadPartStore then
		print_error("[MultiverseInitialPanelStore] 无法获取 downloadPart Store")

		return
	end

	local store = self.downloadPartStore
	store.beginDownloadBtn.luaClick = self.CreateAction(self, self.OnClickBeginDownloadBtn)
	store.cancelBtn.luaClick = self.CreateAction(self, self.OnClickDownloadCancelBtn)
	store.topBtn.luaClick = self.CreateAction(self, self.OnClickDownloadTopBtn)
	store.pauseBtn.luaClick = self.CreateAction(self, self.OnClickDownloadPauseBtn)
	store.recoverBtn.luaClick = self.CreateAction(self, self.OnClickDownloadRecoverBtn)
	store.downloadBtn.luaClick = self.CreateAction(self, self.OnClickDownloadManageBtn)
	store.downloadProgress.onGetValueText = self.CreateAction(self, self.FormatDownloadSize)
end

M.GetVerseBundleIds = function(self, cfg)
	local metaCfg = self.GetVerseMetaConfig(self, cfg)
	local bundleIds = {}

	if metaCfg then
		slot4 = ipairs
		slot6 = metaCfg.BundleIds or {}

		for _, bundleId in slot4(slot6) do
			table.insert(bundleIds, bundleId)
		end
	end

	return bundleIds
end

M.GetConfigDownloadTypeCtrl = function(self, cfgId)
	local task = self.dlcMgr:GetConfigDownloadTask(cfgId)

	if not task then
		return self.dlcMgr.checkingCfgIds[cfgId] and DOWNLOAD_TYPE_CTRL.QUEUING or DOWNLOAD_TYPE_CTRL.IDLE
	end

	local taskStatus = task.taskStatus

	if task.isDownloading or taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Loading then
		return DOWNLOAD_TYPE_CTRL.DOWNLOADING
	elseif taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Paused then
		return DOWNLOAD_TYPE_CTRL.PAUSED
	end

	return DOWNLOAD_TYPE_CTRL.QUEUING
end

M.CollectVerseDownloadInfo = function(self, cfg)
	local info = {
		["^\\xbe\\xa7\\xaa\\xb2"] = 0,
		["\\x9c!2-}\\x93U\\xea>\\xb0\\xbc"] = 0,
		["[[ݍ\\x81\\xbc\r\\xc7\\xef"] = false,
		["WHxhB-="] = 0,
		bundleIds = self:GetVerseBundleIds(cfg),
		downloadTypeCtrl = DOWNLOAD_TYPE_CTRL.IDLE
	}
	local dlcAvailable = self.dlcMgr:IsGlobalDLCTypeValid()
	slot4 = ipairs
	slot6 = dlcAvailable and info.bundleIds or {}

	for _, cfgId in slot4(slot6) do
		if not self.dlcMgr:IsConfigPatched(cfgId) then
			info.hasPending = true
			local cfgCurrent, cfgTotal, cfgSpeed = self.dlcMgr:GetConfigSizeInfo(cfgId)
			info.currentSize = info.currentSize + self.dlcMgr:ToNum(cfgCurrent)
			info.totalSize = info.totalSize + self.dlcMgr:ToNum(cfgTotal)
			info.speed = info.speed + self.dlcMgr:ToNum(cfgSpeed)
			local downloadTypeCtrl = self:GetConfigDownloadTypeCtrl(cfgId)

			if DOWNLOAD_TYPE_PRIORITY[info.downloadTypeCtrl] >= DOWNLOAD_TYPE_PRIORITY[downloadTypeCtrl] then
				info.downloadTypeCtrl = downloadTypeCtrl
			end
		end
	end

	return info
end

M.GetVerseDownloadInfo = function(self, cfg)
	local info = self.CollectVerseDownloadInfo(self, cfg)
	local status = nil

	if not info.hasPending then
		status = self.downloadingStatusCtrlEnum.Finished
	elseif info.downloadTypeCtrl ~= DOWNLOAD_TYPE_CTRL.DOWNLOADING or info.downloadTypeCtrl ~= DOWNLOAD_TYPE_CTRL.QUEUING then
		status = self.downloadingStatusCtrlEnum.Ongoing
	else
		status = self.downloadingStatusCtrlEnum.Start
	end

	return status, info.currentSize, info.totalSize
end

M.RefreshDownloadPart = function(self, cfg)
	cfg = cfg or self.currentVerseCfg
	local info = self:CollectVerseDownloadInfo(cfg)
	self.currentBundleIds = info.bundleIds

	if cfg then
		self.verseHasPendingDownload[cfg.Id] = info.hasPending
	end

	self.RefreshGameProgressPart(self, cfg)

	if info.hasPending then
		self.bindData.isGameProgressCtrl = self.isGameProgressCtrlEnum.download
	elseif self.currentTaskLineInfo then
		self.bindData.isGameProgressCtrl = self.isGameProgressCtrlEnum.gameprogress
	else
		self.bindData.isGameProgressCtrl = self.isGameProgressCtrlEnum.none
	end

	local store = self.downloadPartStore

	if not store then
		return
	end

	store.newModulesCtrl = ClientConsts.BOOL2CTL[info.hasPending]
	store.downloadTypeCtrl = info.downloadTypeCtrl
	store.totalSize = self.dlcMgr:ByteToSize(info.totalSize)
	store.speedLabel = info.speed <= 0 and self.dlcMgr:ByteToSize(info.speed) .. "/s" or ""
	store.remainTimeLabel = self:CalcDownloadRemainTime(info.currentSize, info.totalSize, info.speed)

	self:ApplyDownloadProgress(store.downloadProgress, info.currentSize, info.totalSize)
end

M.ForEachPendingBundle = function(self, action, needTask)
	for _, cfgId in ipairs(self.currentBundleIds) do
		if not self.dlcMgr:IsConfigPatched(cfgId) then
			local task = self.dlcMgr:GetConfigDownloadTask(cfgId)

			if not needTask or task then
				local dlcName = self.dlcMgr:GetPrimaryDlcNameByCfgId(cfgId)

				if dlcName then
					action(dlcName, task, cfgId)
				end
			end
		end
	end
end

M.TryConfirmAllowMobile = function(self, onConfirm)
	if not self.dlcMgr:NeedPromptAllowMobile() then
		onConfirm()

		return
	end

	self.dlcMgr:PromptAllowMobileDownload(onConfirm)
end

M.OnClickBeginDownloadBtn = function(self)
	self.TryConfirmAllowMobile(self, function ()
		self:ForEachPendingBundle(function (dlcName, task)
			if not task then
				self.dlcMgr:AskDownloadDLC(dlcName)
			end
		end, false)
		self:RefreshDownloadPart()
	end)
end

M.OnClickDownloadCancelBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.PackageCancelDownloadConfirm, function ()
		slot0 = self

		slot0:ForEachPendingBundle(function (dlcName)
			self.dlcMgr:AskCancelDownloadDLC(dlcName)
		end, true)
	end, nil)
end

M.OnClickDownloadTopBtn = function(self)
	self.TryConfirmAllowMobile(self, function ()
		slot0 = self

		slot0:ForEachPendingBundle(function (dlcName)
			self.dlcMgr:AskDownloadFirstDLC(dlcName)
		end, true)
	end)
end

M.OnClickDownloadPauseBtn = function(self)
	self.ForEachPendingBundle(self, function (dlcName)
		self.dlcMgr:AskPauseDownloadDLC(dlcName)
	end, true)
end

M.OnClickDownloadRecoverBtn = function(self)
	self.TryConfirmAllowMobile(self, function ()
		slot0 = self

		slot0:ForEachPendingBundle(function (dlcName)
			self.dlcMgr:AskContinueDLC(dlcName)
		end, true)
	end)
end

M.OnClickDownloadManageBtn = function(self)
	self.dlcMgr:ShowPanel(1, false)
end

M.OnDlcDownloadProgressChanged = function(self)
	local completedVerseCfgs = {}

	for verseId, hadPendingDownload in pairs(self.verseHasPendingDownload) do
		if hadPendingDownload then
			local cfg = MultiverseMainPanelConfig.GetConfig(verseId)

			if not cfg then
				self.verseHasPendingDownload[verseId] = nil
			else
				local status = self:GetVerseDownloadInfo(cfg)
				local hasPendingDownload = status == self.downloadingStatusCtrlEnum.Finished
				self.verseHasPendingDownload[verseId] = hasPendingDownload

				if not hasPendingDownload then
					table.insert(completedVerseCfgs, cfg)
				end
			end
		end
	end

	if self.currentVerseCfg then
		self.RefreshDownloadPart(self)
	end

	for _, cfg in ipairs(completedVerseCfgs) do
		self.bindData.downLoadName = cfg.Name

		self.rootWidget:InvokeCallback(EInvokeTime.Custom1)
	end

	self.RefreshGameModuleDownloadStatus(self)
end

M.RefreshGameModuleDownloadStatus = function(self)
	for i = 1, #self.verseLists do
		self.bindData.gameModuleList:RefreshElement(i - 1)
	end
end

M.CalcDownloadRemainTime = function(self, currentSize, totalSize, speed)
	if speed < 0 then
		return ""
	end

	local remaining = totalSize - currentSize

	if remaining < 0 then
		return ""
	end

	local totalSeconds = math.floor(remaining / speed)
	local minutes = math.floor(totalSeconds / 60)
	local seconds = totalSeconds % 60

	if minutes <= 0 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900064).Text, minutes, seconds)
	end

	return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900066).Text, seconds)
end

M.FormatDownloadSize = function(self, value)
	return self.dlcMgr:ByteToSize(value)
end

M.ApplyDownloadProgress = function(self, progress, currentSize, totalSize)
	if not progress then
		return
	end

	local maxValue = math.max(totalSize, 1)
	local currentValue = math.max(0, math.min(currentSize, maxValue))
	progress.maxValue = maxValue

	progress.ProgressToValue(progress, currentValue, 0, 0)
end

M.OnClickSettingsBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_SETTINGS_PANEL)
end

M.OnClickAccountBtn = function(self)
	gLoginManager:DoKickToLogin(nil, , true)
	gCS.LoginManager:OpenUserCenter()
end

M.OnClickConfirmBtn = function(self)
	if not self.currentVerseCfg then
		return
	end

	local subVerseList = self.GetSubVerseList(self, self.currentVerseCfg)

	if #subVerseList <= 0 then
		gPanelManager:CheckShow(gPanelId.MULTIVERSE_WINDOW_PANEL, {
			verseList = subVerseList
		})

		return
	end

	if self.currentVerseCfg.Id ~= self.mgr.curVerse then
		gPanelManager:Close(self.m_Id)

		return
	end

	if self.inEnterMultiverse then
		return
	end

	self.inEnterMultiverse = true

	self.mgr:AskEnterMultiverse(self.currentVerseCfg.Id, self.currentVerseCfg.LinkMode)
end

M.OnClickBackBtn = function(self)
	if self.forbidClose then
		return
	end

	if not self.mgr:CheckIsInSelectVerse() then
		gPanelManager:Close(self.m_Id)

		return
	end

	slot1 = gLoginManager

	slot1:OnQuitInSetting(function ()
		gPanelManager:Close(self.m_Id)
	end)
end

M.OnSimpleRenderGameModuleListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local verseData = self.verseLists[index + 1]

	if not verseData then
		return
	end

	local id = verseData.id
	local cfg = verseData.cfg
	store.isLast = ClientConsts.BOOL2CTL[self:IsVerseOrSubVerse(id, self.mgr.lastVerse)]
	store.isPlaying = ClientConsts.BOOL2CTL[self:IsVerseOrSubVerse(id, self.mgr.curVerse)]
	store.titleLabel = cfg.Name
	store.background = cfg.SmallImg
	store.isDisableCtrl = ClientConsts.BOOL2CTL[not self.mgr:CheckVerse(id)]
	local status, currentSize, totalSize = self:GetVerseDownloadInfo(cfg)
	store.downloadingStatusCtrl = status

	self:ApplyDownloadProgress(store.downloadprogress, currentSize, totalSize)
end

M.OnGameModuleListSelectedChanged = function(self, uList)
	self.SelectVerse(self, uList.selectedIndex + 1)
end

M.OnChangeTab = function(self, uList, isSub)
	self.OnChangeTabIndex(self, uList.selectedIndex)
end

M.OnChangeTabIndex = function(self, index)
	local data = self.tabList[index + 1]
	self.bindData.page = index

	if not data then
		return
	end

	if data.id ~= TabConfig.Play then
		self.RefreshFrontPage(self)
	end
end
