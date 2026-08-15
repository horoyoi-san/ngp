local dlcDownloadManager = GameApp.Update.DLCDownloadManager
local VirtualPackageMgr = LX6.GUI.Download.VirtualPackageMgr
local DlcConfig = LTConfig.DlcConfig
local StaticProps = {
	FINISH_STATE = {
		DELETED = -1,
		DOWNLOADING = 0,
		DOWNLOADED = 1
	}
}
C_DLCDownLoadMgr = DefClass("C_DLCDownLoadMgr", C_DLCDownLoadMgr, nil, StaticProps)
local M = C_DLCDownLoadMgr

function M:ctor()
	self.downloadInfo = {}
	self.dlcInfoDict = {}

	for i = 0, DlcConfig.count - 1 do
		local dlcCfg = DlcConfig.LoadAt(i)
		self.dlcInfoDict[dlcCfg.Name] = dlcCfg
	end

	local dlcList = self:GetDLCList()
	self.hasDLC = #dlcList > 0
end

function M:OnInit()
	dlcDownloadManager.onPatchDownloadFailed = self:CreateAction(self.OnPatchDownloadFailed)
	dlcDownloadManager.onPatchDonwloadSuccess = self:CreateAction(self.OnPatchDownloadSuccess)
	dlcDownloadManager.onPatchDownloadFinishCancel = self:CreateAction(self.OnPatchDownloadFinishCancel)
	dlcDownloadManager.onPatchDownloadProgress = self:CreateAction(self.OnPatchDownloadProgress)
	dlcDownloadManager.onPatchDeleteSuccess = self:CreateAction(self.OnPatchDeleteSuccess)
	dlcDownloadManager.onPatchDeleteFailed = self:CreateAction(self.OnPatchDeleteFailed)
	dlcDownloadManager.onPatchDeleteProgress = self:CreateAction(self.OnPatchDeleteProgress)
end

function M:AddDelgate(delegate, func)
	if delegate then
		delegate = delegate + func
	else
		delegate = func
	end
end

function M:Log(...)
	print_warn("[C_DLCDownLoadMgr]", ...)
end

function M:OnPatchDeleteSuccess(patchName)
	self:Log("OnPatchDeleteSuccess", patchName)

	local vo = self:GetDlcVo(patchName)
	local downloadInfo = {
		speed = 0,
		patchName = patchName,
		currentSize = vo.bytesLoaded,
		totalSize = vo.bytesTotal,
		isFinish = C_DLCDownLoadMgr.FINISH_STATE.DELETED
	}

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED, downloadInfo)

	self.downloadInfo[patchName] = downloadInfo
end

function M:OnPatchDeleteFailed(patchName)
	self:Log("OnPatchDeleteFailed", patchName)

	local vo = self:GetDlcVo(patchName)
	local downloadInfo = {
		speed = 0,
		patchName = patchName,
		currentSize = vo.bytesLoaded,
		totalSize = vo.bytesTotal,
		isFinish = C_DLCDownLoadMgr.FINISH_STATE.DELETED
	}

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED, downloadInfo)

	self.downloadInfo[patchName] = downloadInfo
end

function M:OnPatchDownloadFailed(patchName, webState)
	self:Log("OnPatchDownloadFailed", patchName, webState)

	local vo = self:GetDlcVo(patchName)
	local downloadInfo = {
		speed = 0,
		patchName = patchName,
		currentSize = vo.bytesLoaded,
		totalSize = vo.bytesTotal,
		isFinish = C_DLCDownLoadMgr.FINISH_STATE.DOWNLOADED
	}

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED, downloadInfo)

	self.downloadInfo[patchName] = downloadInfo
end

function M:OnPatchDownloadSuccess(patchName)
	self:Log("OnPatchDownloadSuccess", patchName)

	local vo = self:GetDlcVo(patchName)
	local downloadInfo = {
		speed = 0,
		patchName = patchName,
		currentSize = vo.bytesLoaded,
		totalSize = vo.bytesTotal,
		isFinish = C_DLCDownLoadMgr.FINISH_STATE.DOWNLOADED
	}

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED, downloadInfo)

	self.downloadInfo[patchName] = downloadInfo
end

function M:OnPatchDownloadFinishCancel(patchName)
	self:Log("OnPatchDownloadFinishCancel", patchName)
end

function M:OnPatchDownloadProgress(patchName, currentSize, totalSize, speed)
	self:Log("OnPatchDownloadProgress", patchName, currentSize, totalSize, speed)

	local vo = self:GetDlcVo(patchName)
	local downloadInfo = {
		patchName = patchName,
		currentSize = currentSize,
		totalSize = vo.bytesTotal,
		isFinish = C_DLCDownLoadMgr.FINISH_STATE.DOWNLOADING,
		speed = speed
	}

	gMessageManager:SendMessage(gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED, downloadInfo)

	self.downloadInfo[patchName] = downloadInfo
end

function M:OnPatchDeleteProgress(patchName, currentSize, totalSize)
	self:Log("OnPatchDeleteProgress", patchName, currentSize, totalSize)
end

function M:ByteToSize(byte)
	return gCS.LuaUtils.ByteToStr(byte)
end

function M:CheckUseCarrierDataNetWork()
	return VirtualPackageMgr.UseCarrierDataNetwork
end

function M:SetUseCarrierDataNetWork(use)
	VirtualPackageMgr.UseCarrierDataNetwork = use
end

function M:GetDLCList()
	local dlcList = dlcDownloadManager.GetDLCList():ToTable()
	local ret = {}

	for i = 1, #dlcList do
		local name = dlcList[i]
		local cfg = self.dlcInfoDict[name]

		if cfg and cfg.IsShow then
			local ele = {
				index = i,
				name = dlcList[i]
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

function M:QueryDLCState(dlcname)
	return dlcDownloadManager.GetDlcPatchStatus(dlcname)
end

function M:QueryDLCSize(dlcname)
	return dlcDownloadManager.DLCPatchBytesTotal(dlcname)
end

function M:GetDlcVo(dlcname)
	return dlcDownloadManager.DLCPatchGetVo(dlcname)
end

function M:AskDownloadDLC(dlcname)
	dlcDownloadManager.StartDownLoadDLCPatch(dlcname)
end

function M:AskDeleteDLC(dlcname)
	dlcDownloadManager.DeleteDownLoadDLCPatch(dlcname)
end

gDlcDownLoadMgr = gDlcDownLoadMgr or C_DLCDownLoadMgr.new()
