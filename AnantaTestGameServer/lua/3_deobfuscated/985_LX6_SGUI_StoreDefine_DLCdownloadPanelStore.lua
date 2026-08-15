C_DLCdownloadPanelStore = DefClass("C_DLCdownloadPanelStore", C_DLCdownloadPanelStore, C_StoreGroup)
GroupName2Class.DLCdownloadPanelStore = C_DLCdownloadPanelStore
local M = C_DLCdownloadPanelStore
local STATE = {
	COMPLETE = 3,
	DOWNLOADING = 1,
	WAITING = 0,
	PAUSE = 2,
	UNINSTALL = 4
}

function M:ctor()
	self.msg = {
		[gEventConstants.DLC_DOWN_LOAD_PROGRESS_CHANGED] = self:CreateAction(self.OnDlcDownloadProgressChanged)
	}
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.packageList.luaSimpleRenderItem = self:CreateAction(self.OnRenderPackageItem)
	self.bindData.packageList.luaSimpleClick = self:CreateAction(self.OnClickPackageItem)
	self.mgr = gDlcDownLoadMgr
	self.dlcList = {}

	self:RegisterMessageEvents(self.msg)
end

function M:OnShow(panelId, data)
	self.dlcList = self.mgr:GetDLCList()

	self.bindData.packageList:SetSimpleList(#self.dlcList)
end

function M:OnClose()
	self:ClearMessageEvents()
end

function M:OnRenderPackageItem(btn, index)
	local data = self.dlcList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local vo = self.mgr:GetDlcVo(data.name)
	local cfg = self.mgr.dlcInfoDict[data.name]

	if not vo or not cfg then
		print_warn("[DLCdownloadPanel] 没有找到dlc数据，name = " .. data.name)

		return
	end

	store.packageNameLabel = cfg.DisplayName
	store.downloadSize = self.mgr:ByteToSize(vo.bytesLoaded)
	store.totalSize = self.mgr:ByteToSize(vo.bytesTotal)
	store.status = vo.patchStatus == 2 and STATE.UNINSTALL or STATE.WAITING
	local info = self.mgr.downloadInfo[data.name]

	if info then
		self:_RefreshDownLoadProgress(info, store)
	end

	store.progress:SetActiveQuickly(false)
end

function M:OnClickPackageItem(btn, index)
	local data = self.dlcList[index + 1]
	local vo = self.mgr:GetDlcVo(data.name)

	if vo.patchStatus == 2 then
		self.mgr:AskDeleteDLC(data.name)
	else
		self.mgr:AskDownloadDLC(data.name)
	end
end

function M:OnClickBackBtn()
	gPanelManager:Close(gPanelId.DLC_DOWNLOAD_PANEL)
end

function M:OnDlcDownloadProgressChanged(eventId, param)
	self.bindData.packageList:RefreshLogicList()
end

function M:_RefreshDownLoadProgress(param, store)
	if param.isFinish == -1 then
		store.status = STATE.WAITING
	elseif param.isFinish == 0 then
		store.status = param.currentSize == param.totalSize and STATE.UNINSTALL or STATE.DOWNLOADING
		store.downloadSize = self.mgr:ByteToSize(param.currentSize)
		store.totalSize = self.mgr:ByteToSize(param.totalSize)
		store.speedLabel = self.mgr:ByteToSize(param.speed) .. "/s"
	elseif param.isFinish == 1 then
		store.status = STATE.UNINSTALL
	end
end
