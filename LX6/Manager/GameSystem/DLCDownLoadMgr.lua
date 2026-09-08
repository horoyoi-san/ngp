-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\DLCDownLoadMgr.lua
-- Decompiled from: 02219_DLCDownLoadMgr.lua_4ae812eb9199.luajit

local dlcDownloadManager = GameApp.Update.DLCDownloadManager
local BundleConfig = LTConfig.PackageBundlesConfig
local EPatchStatus = AssetsPipeline.Enums.EnumDlcPatchStatus
local MessageConfig = LTConfig.MessageConfig
local PackageConfig = LTConfig.PackageConfig
local ProfileManager = LX6.Engine.ProfileManager
local languageProfile = ProfileManager.languageProfile
local StaticProps = {
	DLC_TAB_TYPE = {
		["fXL`-8="] = 2,
		["1i\\xa2\\xba\\xa6s"] = 0,
		["Y\rO~"] = 1
	},
	DOWNLOAD_PRIORITY = {
		["2\\xe2K/\\xe2\\xa5g\\xa8D\\xa3\\xa2"] = 4,
		["2\\xe2K/\\xe2\\xa5u\\xa9_\\xa2\\xb2"] = 6,
		["כ\\xef#\\xe3ٍ\\xee\\x8d.,"] = 5
	}
}
local PROGRESS_STORE_STATUS = {
	["\\xbbT\\xb2`\\xfd\\x84\\x9e"] = 0,
	["}\\x8f\\x97\\x9c\\x93"] = 1
}
local ANIM_DOWNLOAD_LOOP = "S_Vx_DLCpackageDownloadProgress_Download"
C_DLCDownLoadMgr = DefClass("C_DLCDownLoadMgr", C_DLCDownLoadMgr, nil, StaticProps)
local M = C_DLCDownLoadMgr

M.ctor = function(self)
	self.enableDebug = false
	self.needPopup = true
	self.downloadCache = {}
	self.taskId2CfgId = {}
	self.cfgId2TaskId = {}
	self.checkingCfgIds = {}
	self.dlcCfgDict = {}
	self.dlcCfgIdList = {}
	self.dlcName2CfgId = {}
	self.cfgId2DlcNames = {}
	self.cfgId2PrimaryName = {}
	self.allMandatoryCfgIdList = {}
	self.constMandatoryCfgIdList = {}
	self.mandatoryVoiceCfgId = nil

	for i = 0, BundleConfig.count - 1 do
		local dlcCfg = BundleConfig.LoadAt(i)
		local dlcNames = self:_GetCfgDlcNames(dlcCfg)
		self.dlcCfgDict[dlcCfg.Id] = dlcCfg

		table.insert(self.dlcCfgIdList, dlcCfg.Id)

		self.cfgId2DlcNames[dlcCfg.Id] = dlcNames
		self.cfgId2PrimaryName[dlcCfg.Id] = dlcNames[1]

		for _, name in ipairs(dlcNames) do
			self.dlcName2CfgId[name] = dlcCfg.Id
		end

		if dlcCfg.Type == M.DLC_TAB_TYPE.MASTER and dlcCfg.DefaultRequireDownload then
			table.insert(self.constMandatoryCfgIdList, dlcCfg.Id)
		end
	end

	self:RefreshMandatoryDLCList()
end

M.OnInit = function(self)
	dlcDownloadManager.onPatchDownloadFailed = self:CreateAction(self.OnPatchDownloadFailed)
	dlcDownloadManager.onPatchDownloadSuccess = self:CreateAction(self.OnPatchDownloadSuccess)
	dlcDownloadManager.onPatchDownloadFinishCancel = self:CreateAction(self.OnPatchDownloadFinishCancel)
	dlcDownloadManager.onPatchDownloadProgress = self:CreateAction(self.OnPatchDownloadProgress)
	dlcDownloadManager.onPatchDownloadPaused = self:CreateAction(self.OnPatchDownloadPaused)
	dlcDownloadManager.onPatchDeleteSuccess = self:CreateAction(self.OnPatchDeleteSuccess)
	dlcDownloadManager.onPatchDeleteFailed = self:CreateAction(self.OnPatchDeleteFailed)
	dlcDownloadManager.onPatchDeleteProgress = self:CreateAction(self.OnPatchDeleteProgress)
	dlcDownloadManager.onPatchDeleteCancel = self:CreateAction(self.OnPatchDeleteCancel)
	dlcDownloadManager.onNetworkStateChanged = self:CreateAction(self.OnNetworkStateChanged)
end

M.RefreshMandatoryDLCList = function(self)
	self.allMandatoryCfgIdList = {}

	for i, v in ipairs(self.constMandatoryCfgIdList) do
		table.insert(self.allMandatoryCfgIdList, v)
	end

	if self.mandatoryVoiceCfgId then
		table.insert(self.allMandatoryCfgIdList, self.mandatoryVoiceCfgId)
	end
end

M.OnPatchDeleteSuccess = function(self, patchName)
	self:Log("OnPatchDeleteSuccess", patchName)
	gDisplayMessageMgr:ShowMessage(MessageConfig.PackageDeleteSucess)
	self:_OnDLCInfoChange()
end

M.OnPatchDeleteFailed = function(self, patchName)
	self:Log("OnPatchDeleteFailed", patchName)
	self:_OnDLCInfoChange()
end

M.OnPatchDownloadFailed = function(self, patchName, webState)
	self:Log("OnPatchDownloadFailed", patchName, webState)

	local cfgId = self:GetCfgIdByDlcName(patchName)

	if cfgId then
		self.checkingCfgIds[cfgId] = nil
	end

	self:_OnDLCInfoChange()
end

M.OnPatchDownloadSuccess = function(self, patchName)
	self:Log("OnPatchDownloadSuccess", patchName)

	local cfgId = self:GetCfgIdByDlcName(patchName)

	if cfgId then
		self.checkingCfgIds[cfgId] = nil
	end

	self:_OnDLCInfoChange()
end

M.OnPatchDownloadFinishCancel = function(self, patchName)
	self:Log("OnPatchDownloadFinishCancel", patchName)

	if self:IsMandatoryDLC(patchName) then
		print_error("必下资源不应该被取消下载", patchName)
	end

	local cfgId = self:GetCfgIdByDlcName(patchName)

	if not cfgId then
		return
	end

	self.checkingCfgIds[cfgId] = nil
	local task = self:GetDLCDownloadTask(patchName)

	if task then
		local currentSize = self:ToNum(task.downloadedBytes)
		local totalSize = self:ToNum(task.totalBytes)

		self:UpdateDownloadCache(cfgId, currentSize, totalSize, 0, true)
	end
end

M.OnPatchDownloadProgress = function(self, taskId, currentSize, totalSize, speed)
	self:Log("OnPatchDownloadProgress", taskId, currentSize, totalSize, speed)

	local cfgId = self.taskId2CfgId[taskId]

	if not cfgId then
		cfgId = self:_FindCfgIdByTaskId(taskId)

		print_error("未命中下载任务缓存，尝试通过taskId查找cfgId", taskId, cfgId)
	end

	if not cfgId then
		print_error("尝试通过taskId查找cfgId失败，无法更新下载进度", taskId)

		return
	end

	self.checkingCfgIds[cfgId] = nil

	self:UpdateDownloadCache(cfgId, currentSize, totalSize, speed, true)
end

M.OnPatchDownloadPaused = function(self, taskId)
	self:Log("OnPatchDownloadPaused", taskId)

	local cfgId = self.taskId2CfgId[taskId]
	cfgId = cfgId or self:_FindCfgIdByTaskId(taskId)

	if not cfgId then
		return
	end

	self.checkingCfgIds[cfgId] = nil
	local task = self:GetConfigDownloadTask(cfgId)

	if task and task.taskId == taskId then
		task = nil
	end

	local cache = self.downloadCache[cfgId]
	local currentSize = cache and self:ToNum(cache.currentSize) or 0
	local totalSize = cache and self:ToNum(cache.totalSize) or nil

	if task then
		currentSize = self:ToNum(task.downloadedBytes)
		totalSize = totalSize or self:ToNum(task.totalBytes)
	end

	if not totalSize then
		local pendingCurrent, pendingTotal = self:_CalcPendingSize(cfgId)
		currentSize = currentSize <= 0 and currentSize or pendingCurrent
		totalSize = pendingTotal
	end

	self:UpdateDownloadCache(cfgId, currentSize, totalSize, 0, true)
	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED)
end

M.OnPatchDeleteProgress = function(self, patchName, currentSize, totalSize)
	self:Log("OnPatchDeleteProgress", patchName, currentSize, totalSize)
end

M.OnPatchDeleteCancel = function(self, patchName)
	self:Log("OnPatchDeleteCancel", patchName)

	local cfgId = self:GetCfgIdByDlcName(patchName)

	if not cfgId then
		return
	end

	local currentSize, totalSize = self:_CalcPendingSize(cfgId)

	self:UpdateDownloadCache(cfgId, currentSize, totalSize, 0, false)
end

M.OnPatchMoveToTop = function(self, patchName)
	self:Log("OnPatchMoveToTop", patchName)
	self:_OnDLCInfoChange(true)
end

M.OnNetworkStateChanged = function(self, fromWifi, toWifi, wasDownloading, allowCellular, wasPausedByNetwork)
	if toWifi then
		if allowCellular then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NetworkSwitchedToWifiResuming)
		elseif wasPausedByNetwork then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NetworkSwitchedToWifiResuming)
		end
	elseif allowCellular then
		if wasDownloading then
			gDisplayMessageMgr:ShowMessage(MessageConfig.NetworkSwitchedToCellularResumed)
		end
	elseif wasDownloading then
		gDisplayMessageMgr:ShowMessage(MessageConfig.NetworkSwitchedToCellularPaused)
	end
end

M.OnSyncNeededBundles = function(self, raid, mode, bundles)
	local names = {}

	for _, id in pairs(bundles) do
		local dlcCfg = BundleConfig.GetConfig(id)

		if not dlcCfg then
			print_error("同步需要的DLC资源配置不存在", id)
		else
			local dlcNames = self:GetCfgDlcNames(dlcCfg.Id)

			if not dlcNames or #dlcNames ~= 0 then
				print_error("同步需要的DLC资源不存在", dlcCfg.Id)
			elseif self:IsConfigPatched(dlcCfg.Id) then
				print_error("同步需要的DLC资源已经下载完成了，没有及时推送", dlcCfg.Id)
			else
				table.insert(names, dlcCfg and dlcCfg.Name or tostring(id))
			end
		end
	end

	local nameMessage = table.concat(names, ",") or ""

	gDisplayMessageMgr:ShowMessage(MessageConfig.PackageNeedDownloadNotice, function ()
		self:ShowPanel(1, false)
	end, nil, nameMessage)
end

M.ShowPanel = function(self, mode, needNotice)
	if needNotice then
		gDisplayMessageMgr:ShowMessage(MessageConfig.RequireDownloadNotice)
	end

	gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL, {
		mode = mode
	})
end

M.StartDownloadMandatoryDLC = function(self)
	if not self:HasDLC() then
		print_debug("没有DLC资源需要下载")

		return
	end

	local isAllDownloaded = true

	for i, cfgId in ipairs(self.allMandatoryCfgIdList) do
		if not self:IsConfigPatched(cfgId) then
			local primaryName = self:GetPrimaryDlcNameByCfgId(cfgId)

			if not primaryName then
				print_error("必下资源配置没有DLC名称", cfgId)
			else
				self:AskDownloadDLC(primaryName)
			end

			isAllDownloaded = false
		end
	end

	if isAllDownloaded then
		self.needPopup = false
	end
end

M.OnStartUp = function(self)
	if LX6.Engine.ProfileManager.isFirstStartUp then
		gPanelManager:CheckShow(gPanelId.INITIALIZATION_PANEL)
	else
		gDlcDownLoadMgr:RefreshMandatoryVoiceDLCName()
		gLoginManager:OpenMainPanel()
	end
end

M.RefreshMandatoryVoiceDLCName = function(self)
	local index = languageProfile.voiceLanguage

	self:SetMandatoryVoiceDLCByIndex(index, false)

	if not self:IsAllMandatoryDownloaded() then
		self:EnterDownloadPanelByNetwork(0, true)
	end
end

M.IsVoiceDLCReady = function(self, index)
	if not self:HasDLC() then
		return true
	end

	if not index then
		print_error("语音包索引不能为空")

		return false
	end

	local isOk, dlcName = self:TryGetVoiceDLCNameByIndex(index)

	if not isOk then
		print_error("没有获取到语音对应的DLC包名称", index)

		return false
	end

	local vo = self:GetDlcVo(dlcName)
	local cfgId = self:GetCfgIdByDlcName(dlcName)

	if cfgId and self:IsConfigPatched(cfgId) then
		return true
	end

	if vo and vo.patchStatus ~= EPatchStatus.Patched then
		return true
	end

	return false
end

M.ShowVoiceDLCDownloadMessage = function(self)
	gDisplayMessageMgr:ShowMessage(MessageConfig.VoicePackageDownloadPrompt, function ()
		self:ShowPanel(1, false)
	end)
end

M.SetMandatoryVoiceDLCByIndex = function(self, index, needDownload)
	local isOk, dlcName = self:TryGetVoiceDLCNameByIndex(index)

	if not isOk then
		print_error("没有获取到语音对应的DLC包名称", index)

		return
	end

	self:SetMandatoryVoiceDLCByName(dlcName)

	if needDownload then
		self:StartDownloadMandatoryDLC()
	end
end

M.SetMandatoryVoiceDLCByName = function(self, dlcName)
	print_debug("设置必下语音包资源", dlcName)

	local cfgId = self:GetCfgIdByDlcName(dlcName)

	if not cfgId then
		print_error("找不到语音包对应配置", dlcName)

		return
	end

	self.mandatoryVoiceCfgId = cfgId

	self:RefreshMandatoryDLCList()
end

M.TryGetVoiceDLCNameByIndex = function(self, index)
	if not index then
		print_error("语音包索引不能为空")

		return false, ""
	end

	local dlcId = PackageConfig.DefaultVoicePackage[index]

	if not dlcId or dlcId ~= 0 then
		print_error("没有对应语音包资源", index)

		return false, ""
	end

	local dlcCfg = BundleConfig.GetConfig(dlcId)

	if not dlcCfg then
		print_error("找不到对应语音包资源配置", dlcId)

		return false, ""
	end

	local primaryName = self:GetPrimaryDlcNameByCfgId(dlcCfg.Id)

	if not primaryName then
		print_error("语音包配置没有DLC名称", dlcCfg.Id)

		return false, ""
	end

	return true, primaryName
end

M.DefaultEnterGame = function(self)
	gLinkManager:OnChangeLinkMode(UX.Game.LinkMode.None)
	gLoginManager:OnLogin()
end

M.GetDLCPriority = function(self, dlcName)
	local cfg = self:GetCfgByDlcName(dlcName)

	return cfg and cfg.DefaultOrder or 1000000000
end

M.RefreshDLCProgressStore = function(self, btn)
	if not btn then
		print_error("btn不能为空")

		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		print_error("无法通过btn获取store")

		return
	end

	local progress = self:GetTotalDownloadProgress()
	store.progressText = string.format("%d%%", math.floor(progress * 100))
	store.statusCtrl = self:IsAnyDLCDownloading() and PROGRESS_STORE_STATUS.DOWNLOADING or PROGRESS_STORE_STATUS.PAUSE
	store.mainAnim = store.mainAnim or btn:GetComponentInChildren(typeof(UnityEngine.Animation))

	if store.mainAnim then
		if store.statusCtrl ~= PROGRESS_STORE_STATUS.DOWNLOADING then
			if not store.mainAnim:IsPlaying(ANIM_DOWNLOAD_LOOP) then
				store.mainAnim:Play(ANIM_DOWNLOAD_LOOP)
			end
		else
			store.mainAnim:Stop()
		end
	end
end

M.GetTotalDownloadProgress = function(self)
	if not self:HasDLC() then
		return 1
	end

	local totalSize, currentSize, lines = self:_CalcSelectedDlcSizes()
	local progress = totalSize ~= 0 and 1 or currentSize / totalSize

	if self.enableDebug then
		self:Log(string.format([[
Selected DLC Sizes:
Total=%s
Loaded=%s
Progress=%.2f%%
Details:
%s]], self:ByteToSize(totalSize), self:ByteToSize(currentSize), progress * 100, table.concat(lines, "\n")))
	end

	progress = Mathf.Clamp(progress, 0, 1)

	return progress
end

M._CalcSelectedDlcSizes = function(self)
	local totalSize = 0
	local currentSize = 0
	local lines = self.enableDebug and {} or nil
	local dlcList = self:GetDLCList()

	for i = 1, #dlcList do
		local cfgId = dlcList[i].cfgId
		local task = self:GetConfigDownloadTask(cfgId)
		local hasCache = self:HasConfigCache(cfgId)
		local selectedByInfo = hasCache or task == nil
		local selectedByPatch = self:IsConfigPatched(cfgId)

		if selectedByInfo or selectedByPatch then
			local dlcCurrent, dlcTotal = self:GetConfigSizeInfo(cfgId)
			totalSize = totalSize + self:ToNum(dlcTotal)
			currentSize = currentSize + self:ToNum(dlcCurrent)

			if lines then
				local state = "unknown"

				if selectedByPatch then
					state = "patched"
				elseif task then
					if task.taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Loading then
						state = "downloading"
					elseif task.taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Paused then
						state = "pause"
					elseif task.taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Loaded then
						state = "downloaded"
					elseif task.taskStatus ~= AssetsPipeline.Enums.EnumTaskStatus.Waiting then
						state = "waiting"
					else
						state = tostring(task.taskStatus)
					end
				elseif hasCache then
					state = "cached"
				end

				table.insert(lines, string.format("%s | %s / %s | state=%s", self:GetPrimaryDlcNameByCfgId(cfgId) or tostring(cfgId), self:ByteToSize(dlcCurrent), self:ByteToSize(dlcTotal), state))
			end
		end
	end

	return totalSize, currentSize, lines
end

M.GetDownloadedSizeInfo = function(self)
	local downloadedSize = ulong.zero
	local removableSize = ulong.zero
	local dlcList = self:GetDLCList()

	for i = 1, #dlcList do
		local dlcNames = dlcList[i].dlcNames
		slot9 = ipairs
		slot11 = dlcNames or {}

		for _, dlcName in slot9(slot11) do
			local vo = self:GetDlcVo(dlcName)

			if vo and vo.patchStatus ~= EPatchStatus.Patched then
				downloadedSize = ulong.add(downloadedSize, vo.bytesTotal)

				if not self:IsMandatoryDLC(dlcName) then
					removableSize = ulong.add(removableSize, vo.bytesLoaded)
				end
			end
		end
	end

	return self:ByteToSize(downloadedSize), self:ByteToSize(removableSize)
end

M.ByteToSize = function(self, byte)
	return gCS.LuaUtils.ByteToStr(byte)
end

M.CheckUseCarrierDataNetWork = function(self)
	return dlcDownloadManager.GetUseCarrierDataNetwork()
end

M.SetUseCarrierDataNetWork = function(self, use)
	dlcDownloadManager.SetUseCarrierDataNetwork(use)
end

M.NeedPromptAllowMobile = function(self)
	return not self:CheckUseCarrierDataNetWork() and not gCS.LuaUtils.IsUsingWifi()
end

M.PromptAllowMobileDownload = function(self, onConfirm, onCancel)
	print_notice("提示用户是否允许使用移动网络下载DLC资源")
	gDisplayMessageMgr:ShowMessage(MessageConfig.PromptAllowMobileDownload, function ()
		self:SetUseCarrierDataNetWork(true)

		if onConfirm then
			onConfirm()
		end
	end, function ()
		self:SetUseCarrierDataNetWork(false)

		if onCancel then
			onCancel()
		end
	end)
end

M.EnterDownloadPanelByNetwork = function(self, mode, autoStart)
	if self:IsAllMandatoryDownloaded() then
		self.needPopup = false

		return
	end

	local showPanel = function()
		gPanelManager:CheckShow(gPanelId.DLC_DOWNLOAD_PANEL, {
			mode = mode
		})
	end

	if gCS.LuaUtils.IsUsingWifi() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.RequireDownloadNotice)

		if autoStart then
			self:StartDownloadMandatoryDLC()
		end

		showPanel()
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.PromptConfirmNonWifiDownload, function ()
			self:SetUseCarrierDataNetWork(true)

			if autoStart then
				self:StartDownloadMandatoryDLC()
			end

			showPanel()
		end, function ()
			showPanel()
		end)
	end
end

M.IsMandatoryDLC = function(self, dlcName)
	local cfgId = self:GetCfgIdByDlcName(dlcName)

	if not cfgId then
		return false
	end

	for i, v in ipairs(self.allMandatoryCfgIdList) do
		if v ~= cfgId then
			return true
		end
	end

	return false
end

M.IsAllMandatoryDownloaded = function(self)
	if not self:HasDLC() then
		return true
	end

	for i, cfgId in ipairs(self.allMandatoryCfgIdList) do
		if not self:IsConfigPatched(cfgId) then
			return false
		end
	end

	return true
end

M.IsShowDLC = function(self, cfg)
	if not cfg then
		return false
	end

	if cfg.Type ~= M.DLC_TAB_TYPE.MASTER then
		return false
	end

	return true
end

M.UpdateDownloadCache = function(self, cfgId, currentSize, totalSize, speed, noSync)
	if type(cfgId) == "number" then
		cfgId = self:GetCfgIdByDlcName(cfgId)

		if not cfgId then
			return
		end

		currentSize, totalSize = self:_CalcPendingSize(cfgId)
	end

	local downloadCache = {
		cfgId = cfgId,
		currentSize = currentSize,
		totalSize = totalSize,
		speed = speed or 0
	}
	self.downloadCache[cfgId] = downloadCache

	self:_OnDLCInfoChange(noSync)

	if self.needPopup and self:IsAllMandatoryDownloaded() then
		self.needPopup = false

		gDisplayMessageMgr:ShowMessage(MessageConfig.RequireDownloadCompleteConfirm, function ()
			self:DefaultEnterGame()
		end, nil)
	end
end

M._OnDLCInfoChange = function(self, noSync)
	if not noSync then
		if not self:HasDLC() then
			print_error("没有DLC资源需要同步,但是触发了DLC下载逻辑")
		else
			local bundleIds = {}

			for cfgId, cfg in pairs(self.dlcCfgDict) do
				if self:IsConfigPatched(cfgId) then
					table.insert(bundleIds, cfg.Id)
				end
			end

			gClientToGameDelegate:SyncBundles(bundleIds)
		end
	end

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED)
end

M._BindTaskToCfg = function(self, cfgId, dlcName)
	if not cfgId or not dlcName then
		return
	end

	local task = self:GetDLCDownloadTask(dlcName)

	if task then
		local taskId = task.taskId
		self.taskId2CfgId[taskId] = cfgId
		self.cfgId2TaskId[cfgId] = taskId
	end
end

M._FindCfgIdByTaskId = function(self, taskId)
	local cfgId = self.taskId2CfgId[taskId]

	if cfgId then
		return cfgId
	end

	for _, id in ipairs(self.dlcCfgIdList) do
		local task = self:GetConfigDownloadTask(id)

		if task and task.taskId ~= taskId then
			self.taskId2CfgId[taskId] = id
			self.cfgId2TaskId[id] = taskId

			return id
		end
	end

	return nil
end

M._CalcPendingSize = function(self, cfgId)
	local totalSize = 0
	local currentSize = 0
	local dlcNames = self:GetCfgDlcNames(cfgId)

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if vo and vo.patchStatus == EPatchStatus.Patched then
			totalSize = totalSize + self:ToNum(vo.bytesTotal)
			currentSize = currentSize + self:ToNum(vo.bytesLoaded)
		end
	end

	return currentSize, totalSize
end

M.GetDLCList = function(self)
	local ret = {}

	for i, cfgId in ipairs(self.dlcCfgIdList) do
		local cfg = self.dlcCfgDict[cfgId]
		local dlcNames = self.cfgId2DlcNames[cfgId]
		local primaryName = self.cfgId2PrimaryName[cfgId]

		if cfg and primaryName and self:IsShowDLC(cfg) then
			local ele = {
				index = i,
				name = primaryName,
				cfgId = cfgId,
				dlcNames = dlcNames,
				type = cfg.Type
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.HasDLC = function(self)
	if gCS.LuaUtils.IsPSPlatform() then
		return false
	end

	if not self:IsGlobalDLCTypeValid() then
		return false
	end

	local csDLcList = dlcDownloadManager.GetDLCList():ToTable()

	if not csDLcList or #csDLcList ~= 0 then
		return false
	end

	local dlcList = self:GetDLCList()

	return #dlcList >= 0
end

M.GetDlcVo = function(self, dlcName)
	if not self:IsGlobalDLCTypeValid() then
		print_error("当前模式不应该调用GetDlcVo，看看堆栈", dlcName)

		return nil
	end

	return dlcDownloadManager.DLCPatchGetVo(dlcName)
end

M.GetDLCDownloadTask = function(self, dlcName)
	return dlcDownloadManager.DlcPatchGetDownloadTask(dlcName)
end

M.AskCheckDLCDeleted = function(self, dlcName)
	return dlcDownloadManager.CheckDeleteDLCPatch(dlcName)
end

M.AskDownloadDLC = function(self, dlcName)
	local cfgId = self:GetCfgIdByDlcName(dlcName)

	if not cfgId then
		print_error("找不到DLC对应配置", dlcName)

		return
	end

	local dlcNames = self:GetCfgDlcNames(cfgId)

	if not dlcNames or #dlcNames ~= 0 then
		print_error("配置没有DLC名称", cfgId)

		return
	end

	self.checkingCfgIds[cfgId] = true
	local csNameList = gCS.LuaUtils.CreateStringList()

	for _, name in ipairs(dlcNames) do
		csNameList:Add(name)
	end

	if self:IsMandatoryDLC(dlcName) then
		dlcDownloadManager.StartDownLoadDLCPatch(csNameList, M.DOWNLOAD_PRIORITY.PatchResFirst)
	else
		dlcDownloadManager.StartDownLoadDLCPatch(csNameList, M.DOWNLOAD_PRIORITY.PatchResThird)
	end

	self:_BindTaskToCfg(cfgId, dlcName)

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if vo then
			self:UpdateDownloadCache(name, vo.bytesLoaded, vo.bytesTotal, 0, true)
		end
	end

	self:_OnDLCInfoChange()
end

M.AskContinueDLC = function(self, dlcName)
	return dlcDownloadManager.ContinueDownloadDLCPatch(dlcName)
end

M.AskDownloadFirstDLC = function(self, dlcName)
	if not dlcDownloadManager.CheckDownloadingDLCPatch(dlcName) then
		self:AskDownloadDLC(dlcName)
	end

	if dlcDownloadManager.CheckDownloadingDLCPatch(dlcName) then
		dlcDownloadManager.MoveDlcDownloadToTop(dlcName)
	else
		print_error("dlcName=", dlcName, " 不在下载列表中，无法置顶")

		return
	end

	self:OnPatchMoveToTop(dlcName)
end

M.AskCancelDownloadDLC = function(self, dlcName)
	if self:IsMandatoryDLC(dlcName) then
		print_error("必下资源不能取消下载")

		return
	end

	local cfgId = self:GetCfgIdByDlcName(dlcName)
	local dlcNames = self:GetCfgDlcNames(cfgId)

	if not dlcNames or #dlcNames ~= 0 then
		return
	end

	for _, name in ipairs(dlcNames) do
		dlcDownloadManager.CancelAndDeleteDLCPatch(name)
	end
end

M.AskPauseDownloadDLC = function(self, dlcName)
	local task = self:GetDLCDownloadTask(dlcName)

	if not task then
		print_error("dlcName=", dlcName, " 不在下载队列中，无法暂停")

		return
	end

	if task.isDone or task.taskStatus == AssetsPipeline.Enums.EnumTaskStatus.Loading and task.taskStatus == AssetsPipeline.Enums.EnumTaskStatus.Waiting then
		print_warn("dlcName=", dlcName, " 状态不对，无法暂停", task.taskStatus)

		return
	end

	dlcDownloadManager.PauseDownloadDLCPatch(dlcName)
end

M.AskDeleteDLC = function(self, dlcName)
	if self:IsMandatoryDLC(dlcName) then
		print_error("必下资源不能删除")

		return
	end

	local cfgId = self:GetCfgIdByDlcName(dlcName)
	local dlcNames = self:GetCfgDlcNames(cfgId)

	if not dlcNames or #dlcNames ~= 0 then
		return
	end

	for _, name in ipairs(dlcNames) do
		dlcDownloadManager.DeleteDownLoadDLCPatch(name)
	end
end

M.AskDeleteAllDLC = function(self)
	local dlcList = self:GetDLCList()

	for i = 1, #dlcList do
		local dlcNames = dlcList[i].dlcNames
		slot7 = ipairs
		slot9 = dlcNames or {}

		for _, dlcName in slot7(slot9) do
			local vo = self:GetDlcVo(dlcName)

			if vo and not self:IsMandatoryDLC(dlcName) and vo.patchStatus ~= EPatchStatus.Patched then
				dlcDownloadManager.DeleteDownLoadDLCPatch(dlcName)
			end
		end
	end
end

M.IsAnyDLCDownloading = function(self)
	return dlcDownloadManager.CheckAnyDLCLoading()
end

M.IsAnyDLCTaskExist = function(self)
	return dlcDownloadManager.CheckAnyDLCDownloading()
end

M.AskPrintDownloadQueue = function(self)
	dlcDownloadManager.PrintDownloadQueue()
end

M.IsShowProgressBtn = function(self, ignorePriority)
	if not self:IsGlobalDLCTypeValid() then
		return false
	end

	if self:IsAnyDLCTaskExist() then
		return true
	end

	local dlcList = self:GetDLCList()

	if not dlcList or #dlcList ~= 0 then
		return false
	end

	for i = 1, #dlcList do
		local cfgId = dlcList[i].cfgId
		local cfg = self.dlcCfgDict[cfgId]

		if not cfg then
			print_error("无法获取DLC信息", cfgId)
		else
			if cfg.DefaultRequireDownload and not self:IsConfigPatched(cfgId) then
				return true
			end

			if not ignorePriority and cfg.DefaultRriorityDownload and not self:IsConfigPatched(cfgId) then
				return true
			end
		end
	end

	return false
end

M._GetCfgDlcNames = function(self, cfg)
	local names = {}

	if not cfg then
		return names
	end

	local resourceName = cfg.ResourceName

	if not resourceName then
		return names
	end

	for _, name in ipairs(resourceName) do
		if name == nil and name == "" then
			table.insert(names, name)
		end
	end

	return names
end

M.GetCfgIdByDlcName = function(self, dlcName)
	return self.dlcName2CfgId[dlcName]
end

M.GetCfgByDlcName = function(self, dlcName)
	local cfgId = self:GetCfgIdByDlcName(dlcName)

	if not cfgId then
		return nil
	end

	return self.dlcCfgDict[cfgId]
end

M.GetCfgDlcNames = function(self, cfgId)
	return self.cfgId2DlcNames[cfgId] or {}
end

M.GetPrimaryDlcNameByCfgId = function(self, cfgId)
	return self.cfgId2PrimaryName[cfgId]
end

M.IsConfigPatched = function(self, cfgId)
	if not self:IsGlobalDLCTypeValid() then
		return true
	end

	local dlcNames = self:GetCfgDlcNames(cfgId)

	if not dlcNames or #dlcNames ~= 0 then
		return false
	end

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if not vo or vo.patchStatus == EPatchStatus.Patched then
			return false
		end
	end

	return true
end

M.IsConfigWaitDeleted = function(self, cfgId)
	local dlcNames = self:GetCfgDlcNames(cfgId)

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if vo and (vo.patchStatus ~= EPatchStatus.WaitDeleted or vo.patchStatus ~= EPatchStatus.WaitDeletedAndPatched) then
			return true
		end
	end

	return false
end

M.HasConfigCache = function(self, cfgId)
	return self.downloadCache[cfgId] == nil
end

M.GetConfigDownloadTask = function(self, cfgId)
	local dlcNames = self:GetCfgDlcNames(cfgId)

	for _, name in ipairs(dlcNames) do
		local task = self:GetDLCDownloadTask(name)

		if task then
			return task
		end
	end

	return nil
end

M.GetConfigSizeInfo = function(self, cfgId)
	local dlcNames = self:GetCfgDlcNames(cfgId)
	local patchedTotal = 0
	local patchedCurrent = 0

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if vo and vo.patchStatus ~= EPatchStatus.Patched then
			patchedTotal = patchedTotal + self:ToNum(vo.bytesTotal)
			patchedCurrent = patchedCurrent + self:ToNum(vo.bytesLoaded)
		end
	end

	local cache = self.downloadCache[cfgId]

	if cache then
		local currentSize = patchedCurrent + self:ToNum(cache.currentSize)
		local totalSize = patchedTotal + self:ToNum(cache.totalSize)
		local speed = self:ToNum(cache.speed)

		return currentSize, totalSize, speed
	end

	local task = self:GetConfigDownloadTask(cfgId)

	if task then
		local currentSize = patchedCurrent + self:ToNum(task.downloadedBytes)
		local totalSize = patchedTotal + self:ToNum(task.totalBytes)
		local speed = self:ToNum(task.speed)

		return currentSize, totalSize, speed
	end

	local totalSize = 0
	local currentSize = 0

	for _, name in ipairs(dlcNames) do
		local vo = self:GetDlcVo(name)

		if vo then
			totalSize = totalSize + self:ToNum(vo.bytesTotal)
			currentSize = currentSize + self:ToNum(vo.bytesLoaded)
		end
	end

	return currentSize, totalSize, 0
end

M.IsGlobalDLCTypeValid = function(self)
	return dlcDownloadManager.GetGlobalDlcType() == AssetsPipeline.Enums.EnumDlcType.None
end

M.Log = function(self, ...)
	print_warn("[C_DLCDownLoadMgr]", ...)
end

M.ToNum = function(self, v)
	if v ~= nil then
		return 0
	end

	if type(v) ~= "number" then
		return v
	end

	local low, high = ulong.tonum2(v)
	low = low or 0
	high = high or 0

	return low + high * 4294967296.0
end

gDlcDownLoadMgr = gDlcDownLoadMgr or C_DLCDownLoadMgr.new()
