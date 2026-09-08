-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DLCdownloadPanelStore.lua
-- Decompiled from: 01878_DLCdownloadPanelStore.lua_0cffb1ccbc40.luajit

local MessageConfig = LTConfig.MessageConfig
C_DLCdownloadPanelStore = DefClass("C_DLCdownloadPanelStore", C_DLCdownloadPanelStore, C_StoreGroup)
GroupName2Class.DLCdownloadPanelStore = C_DLCdownloadPanelStore
local M = C_DLCdownloadPanelStore
local PKG_TYPE_CTRL = {
	["nfBMo*> "] = 0,
	[",\\xcck#\\xfd,\\x99s\\x95w\\x9e\\x82"] = 2,
	[",\\xcck'\\xf12\\x92`\\x95y\\x82\\x8f"] = 1
}
local PKG_STATUS_CTRL = {
	["SQ~"] = 4,
	["\\x88\\x9e(\\x9bF\\xca"] = 3,
	["\\xbbT\\xb2`\\xfd\\x84\\x9e"] = 1,
	["\\xee\\xfa=)7\n\\xd6"] = 0,
	["}\\x8f\\x97\\x9c\\x93"] = 2,
	["\\x88\\x99 \\x88A\\xd0"] = 5
}
local MAIN_STATE_CTRL = {
	["a\\x81\\x85\\x86\\x98"] = 0,
	["\\xf0\\xf5+:?\t\\xd4"] = 1
}
local TaskStatus2PkgStatusCtrl = {
	[AssetsPipeline.Enums.EnumTaskStatus.Waiting] = PKG_STATUS_CTRL.WAITING,
	[AssetsPipeline.Enums.EnumTaskStatus.Loading] = PKG_STATUS_CTRL.DOWNLOADING,
	[AssetsPipeline.Enums.EnumTaskStatus.Paused] = PKG_STATUS_CTRL.PAUSE,
	[AssetsPipeline.Enums.EnumTaskStatus.Canceling] = PKG_STATUS_CTRL.IDLE,
	[AssetsPipeline.Enums.EnumTaskStatus.Loaded] = PKG_STATUS_CTRL.COMPLETE
}
local ANIM_MAIN_SWITCH = "S_Vx_DLCdownloadPanel_Switch"
local ANIM_ROOT_SWITCH = "S_Vx_DLCdownloadPanel_DLC_Switch"
local ANIM_TAB_SELECT = "S_Vx_DLC_TabTemplate_slc"

M.ctor = function(self)
	self.msg = {
		[gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED] = self.CreateAction(self, self.OnDlcDownloadProgressChanged)
	}
	self._lastProgressLogTime = 0
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.confirmBtn.luaInvalidClick = self.CreateAction(self, self.OnInvalidClickConfirmBtn)
	self.bindData.unInstallBtn.luaClick = self.CreateAction(self, self.OnClickUninstallBtn)
	self.bindData.packageList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPackageItem)
	self.bindData.packageList.luaSelectedChanged = self.CreateAction(self, self.OnSelectPackageItem)
	self.bindData.allowDataBtn.luaSelectChanged = self.CreateAction(self, self.OnSwitchAllowDataBtn)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnSelectTabItem)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderTabItem)
	self.mgr = gDlcDownLoadMgr
	self.dlcList = nil

	self.RegisterMessageEvents(self, self.msg)

	self.tabType = C_DLCDownLoadMgr.DLC_TAB_TYPE.MASTER
	self.isSkippedTabAnim = false
	self.mode = 0
end

M.OnShow = function(self, panelId, data)
	if not self.mgr:IsGlobalDLCTypeValid() then
		print_error("[DLCdownloadPanelStore] 当前模式不支持分包下载，不应该打开分包下载界面")
	end

	self.mode = data and data.mode or 0

	self:RefreshMainState()
	self:RefreshTab()

	self.bindData.checkBoxSelectedCtrl = self.mgr:CheckUseCarrierDataNetWork() and 1 or 0
	self.bindData.rewardItemIconId = LTConfig.PackageConfig.BundlesDownloadReward
	self.bindData.rewardText = LTConfig.PackageConfig.BundlesDownloadRewardTips
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end

M.RefreshMainState = function(self)
	self.bindData.typeCtrl = self.mode

	if self.mode ~= MAIN_STATE_CTRL.LOGIN then
		local canPlay = self.mgr:IsAllMandatoryDownloaded()
		self.bindData.confirmBtn.interactable = canPlay
	elseif self.mode ~= MAIN_STATE_CTRL.IN_GAME then
		self.RefreshDownloadedSize(self)

		self.bindData.unInstallBtn.interactable = false
	end
end

M.RefreshDownloadedSize = function(self)
	local downloadedSize, removableSize = self.mgr:GetDownloadedSizeInfo()
	self.bindData.totalSizeInfoLabel = downloadedSize
	self.bindData.uninstallAbleInfoLabel = removableSize
end

M.RefreshTab = function(self)
	local tabList = {}

	for i, v in ipairs(LTConfig.PackageConfig.BundlesDownloadTabLabel) do
		local tab = {
			type = i,
			title = v
		}

		table.insert(tabList, tab)
	end

	self.tabList = tabList

	self.bindData.tabList:SetSimpleList(#tabList)
	self.bindData.tabList:SelectItem(0)
end

M.RefreshPackageList = function(self, type)
	self.tabType = type or self.tabType
	local allDlc = self.mgr:GetDLCList()
	local dlcList = {}

	for i, v in pairs(allDlc) do
		if v.type ~= self.tabType then
			table.insert(dlcList, v)
		end
	end

	table.sort(dlcList, self:CreateAction(self.PackageSorter))

	self.dlcList = dlcList

	self.bindData.packageList:SetSimpleList(#dlcList)

	if #dlcList <= 0 then
		self.bindData.packageList:SelectItem(0)
	end
end

M.OnRenderTabItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.tabList[index + 1]
	store.titleText = data.title
end

M.OnSelectTabItem = function(self, uList)
	local index = uList.selectedIndex
	local data = self.tabList[index + 1]

	self.RefreshPackageList(self, data.type)

	if not self.isSkippedTabAnim then
		self.isSkippedTabAnim = true
	else
		if self.bindData.mainAnim then
			self.bindData.mainAnim:Play(ANIM_MAIN_SWITCH)
		end

		local isSuccess, btn = uList.TryGetChildAt(uList, index, _)

		if isSuccess and btn then
			local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

			if store and store.mainAnim then
				store.mainAnim:Play(ANIM_TAB_SELECT)
			end
		end
	end
end

M.OnRenderPackageItem = function(self, btn, index)
	local data = self.dlcList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfgId = data.cfgId
	local primaryName = data.name
	local cfg = self.mgr.dlcCfgDict[cfgId]
	local task = self.mgr:GetConfigDownloadTask(cfgId)
	local currentSize, totalSize, speed = self.mgr:GetConfigSizeInfo(cfgId)

	if not cfg then
		print_warn("[DLCdownloadPanel] 没有找到dlc数据，cfgId = " .. tostring(cfgId))

		return
	end

	if self.mgr:IsMandatoryDLC(primaryName) then
		store.typeCtrl = PKG_TYPE_CTRL.MANDATORY
	elseif cfg.DefaultRriorityDownload then
		store.typeCtrl = PKG_TYPE_CTRL.NOT_MANDATORY
	else
		store.typeCtrl = PKG_TYPE_CTRL.NOT_IMPORTANT
	end

	store.packageNameLabel = cfg.Name
	store.backgroundIconId = cfg.BtnImageId
	store.downloadBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemDownloadBtn, primaryName)
	store.uninstallBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemUninstallBtn, primaryName)
	store.beginBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemBeginBtn, primaryName)
	store.pauseBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemPauseBtn, primaryName)
	store.downloadFirstBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemDownloadFirstBtn, primaryName)
	store.cancelBtn.luaClick = self:CreateActionWithArgs(self.OnClickPackageItemCancelBtn, primaryName)
	store.statusCtrl = self:_GetPackageStatusCtrl(cfgId, task)
	store.downloadSize = self.mgr:ByteToSize(currentSize)
	store.totalSize = self.mgr:ByteToSize(totalSize)

	self:_ApplyProgress(store, currentSize, totalSize)

	if speed then
		store.speedLabel = self.mgr:ByteToSize(speed) .. "/s"
	else
		store.speedLabel = ""
	end

	store.leftTimeText = self._CalcLeftTimeText(self, currentSize, totalSize, speed)
end

M.OnSelectPackageItem = function(self, ulist)
	local index = ulist.selectedIndex
	local data = self.dlcList[index + 1]

	if not data then
		print_error("[DLCdownloadPanel] 选择的DLC数据不存在，index= " .. tostring(index))

		return
	end

	local cfgId = data.cfgId
	local cfg = self.mgr.dlcCfgDict[cfgId]

	if not cfg then
		print_error("[DLCdownloadPanel] 没有找到dlc配置数据，cfgId= " .. tostring(cfgId))

		return
	end

	self.RefreshTooltip(self, cfg)

	if self.bindData.rootAnim then
		self.bindData.rootAnim:Play(ANIM_ROOT_SWITCH)
	end
end

M.OnClickPackageItemDownloadBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击下载", name)
	end

	local cfgId = self.mgr:GetCfgIdByDlcName(name)

	if cfgId and self.mgr:IsConfigPatched(cfgId) then
		print_error("[DLCdownloadPanel] 该DLC已经下载完成，不能重复下载，name = " .. name)

		return
	end

	self._TryConfirmAllowMobile(self, function ()
		self.mgr:AskDownloadDLC(name)
		self.bindData.packageList:RefreshLogicList()
	end)
end

M.OnClickPackageItemUninstallBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击卸载", name)
	end

	slot2 = gDisplayMessageMgr

	slot2:ShowMessage(MessageConfig.PackageDeleteConfirm, function ()
		self.mgr:AskDeleteDLC(name)
	end, nil)
end

M.OnClickPackageItemBeginBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击开始/继续", name)
	end

	self._TryConfirmAllowMobile(self, function ()
		local task = self.mgr:GetDLCDownloadTask(name)

		if task then
			self.mgr:AskContinueDLC(name)
		else
			self.mgr:AskDownloadDLC(name)
		end

		self.bindData.packageList:RefreshLogicList()
	end)
end

M.OnClickPackageItemPauseBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击暂停", name)
	end

	self.mgr:AskPauseDownloadDLC(name)
end

M.OnClickPackageItemDownloadFirstBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击置顶", name)
	end

	self._TryConfirmAllowMobile(self, function ()
		self.mgr:AskDownloadFirstDLC(name)
	end)
end

M.OnClickPackageItemCancelBtn = function(self, name)
	if self.mgr.enableDebug then
		print_notice("[DLCdownloadPanel] 点击取消下载", name)
	end

	slot2 = gDisplayMessageMgr

	slot2:ShowMessage(MessageConfig.PackageCancelDownloadConfirm, function ()
		self.mgr:AskCancelDownloadDLC(name)
	end, nil)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(gPanelId.DLC_DOWNLOAD_PANEL)

	if self.mode ~= MAIN_STATE_CTRL.LOGIN then
		gLoginManager:CheckMainPanelShowingOpen()
	end
end

M.OnClickConfirmBtn = function(self)
	self.mgr:DefaultEnterGame()
end

M.OnInvalidClickConfirmBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.RequireDownloadNotice, function ()
		self.mgr:AskDeleteAllDLC()
	end, nil)
end

M.OnClickUninstallBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.AllPackageDeleteConfirm, function ()
		self.mgr:AskDeleteAllDLC()
	end, nil)
end

M.OnSwitchAllowDataBtn = function(self, value)
	print_notice("[DLCdownloadPanel] 切换允许使用移动网络下载", value)

	local current = self.mgr:CheckUseCarrierDataNetWork()

	if current then
		self.mgr:SetUseCarrierDataNetWork(false)

		self.bindData.checkBoxSelectedCtrl = 0

		print_notice("[DLCdownloadPanel] 关闭允许使用移动网络下载")
	else
		slot3 = self.mgr

		slot3:PromptAllowMobileDownload(function ()
			self.bindData.checkBoxSelectedCtrl = 1

			print_notice("[DLCdownloadPanel] 允许使用移动网络下载")
		end, function ()
			self.bindData.checkBoxSelectedCtrl = 0

			print_notice("[DLCdownloadPanel] 取消允许使用移动网络下载")
		end)
	end
end

M._TryConfirmAllowMobile = function(self, onConfirm)
	if not self.mgr:NeedPromptAllowMobile() then
		if onConfirm then
			onConfirm()
		end

		return
	end

	slot2 = self.mgr

	slot2:PromptAllowMobileDownload(function ()
		self.bindData.checkBoxSelectedCtrl = 1

		if onConfirm then
			onConfirm()
		end
	end, function ()
		self.bindData.checkBoxSelectedCtrl = 0
	end)
end

M.RefreshTooltip = function(self, cfg)
	self.bindData.nameLabel = cfg.Name
	self.bindData.introLabel = cfg.Description
	self.bindData.backgroundIconId = cfg.BGImageId
end

M.OnDlcDownloadProgressChanged = function(self, eventId, param)
	if self.mgr.enableDebug then
		local now = Time.realtimeSinceStartup

		if now - (self._lastProgressLogTime or 0) > 0.5 then
			self._lastProgressLogTime = now

			print_notice("[DLCdownloadPanel] 收到进度刷新", string.format("%.3f", now))
		end
	end

	self.bindData.packageList:RefreshLogicList()
	self:RefreshMainState()
end

M._CalcLeftTimeText = function(self, currentSize, totalSize, speed)
	local speedNum = self.mgr:ToNum(speed)

	if not speedNum or speedNum < 0 then
		return ""
	end

	local remaining = self.mgr:ToNum(totalSize) - self.mgr:ToNum(currentSize)

	if remaining < 0 then
		return ""
	end

	local totalSeconds = math.floor(remaining / speedNum)
	local totalMinutes = math.floor(totalSeconds / 60)
	local s = totalSeconds % 60

	if totalMinutes <= 0 then
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900064).Text, totalMinutes, s)
	else
		return gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900066).Text, s)
	end
end

M._ApplyProgress = function(self, store, currentSize, totalSize)
	if not store or not store.progress then
		return
	end

	local maxValue = self.mgr:ToNum(totalSize)
	local currentValue = self.mgr:ToNum(currentSize)

	if maxValue < 0 then
		maxValue = 1
	end

	if currentValue >= 0 then
		currentValue = 0
	elseif maxValue >= currentValue then
		currentValue = maxValue
	end

	store.progress.maxValue = maxValue

	store.progress:ProgressToValue(maxValue - currentValue, 0, 0)
end

M._GetPackageStatusCtrl = function(self, cfgId, task)
	if not cfgId then
		return PKG_STATUS_CTRL.IDLE
	end

	if self.mgr:IsConfigPatched(cfgId) then
		return PKG_STATUS_CTRL.COMPLETE
	end

	if self.mgr:IsConfigWaitDeleted(cfgId) then
		return PKG_STATUS_CTRL.IDLE
	end

	if self.mgr.checkingCfgIds[cfgId] and not task then
		return PKG_STATUS_CTRL.CHECKING
	end

	if task then
		if task.isDone then
			return PKG_STATUS_CTRL.COMPLETE
		elseif task.isDownloading then
			return PKG_STATUS_CTRL.DOWNLOADING
		elseif task.taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Loading and not task.isDownloading then
			return PKG_STATUS_CTRL.WAITING
		else
			local pkgStatus = TaskStatus2PkgStatusCtrl[task.taskStatus]

			if pkgStatus then
				return pkgStatus
			else
				print_error("[DLCdownloadPanel] 未知的下载任务状态，cfgId = " .. tostring(cfgId) .. ", taskStatus = " .. tostring(task.taskStatus))

				return PKG_STATUS_CTRL.IDLE
			end
		end
	end

	return PKG_STATUS_CTRL.IDLE
end

M.PackageSorter = function(self, a, b)
	local am = self.mgr:IsMandatoryDLC(a.name)
	local bm = self.mgr:IsMandatoryDLC(b.name)
	local ap = self.mgr:GetDLCPriority(a.name)
	local bp = self.mgr:GetDLCPriority(b.name)

	if am == bm then
		return am
	end

	return ap <= bp
end
