C_ReportPanelStore = DefClass("C_ReportPanelStore", C_ReportPanelStore, C_StoreGroup)
GroupName2Class.ReportPanelStore = C_ReportPanelStore
local M = C_ReportPanelStore

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderListItem)
	self.bindData.commitBtn.luaClick = self:CreateAction(self.OnCommitBtnClick)
	self.bindData.cancelBtn.luaClick = self:CreateAction(self.OnCancelBtnClick)
end

function M:OnShow(panelId, data)
	self.instance = {
		panelId = panelId,
		data = data
	}
	self.bindData.name = gFriendManager:GetPlayerRealName(data.pid)

	gFriendManager:GetPlayerRealName(data.pid, function (name)
		self.bindData.name = name
	end)
	self:RefreshList(data)
end

function M:RefreshList(data)
	local matterList = data.matterList

	if table.isNilOrEmpty(matterList) and data.systemId and data.useSystemId == nil then
		data.useSystemId = gReportManager:FindInformUseSystemConfigId(data.systemId)
	end

	if table.isNilOrEmpty(matterList) and data.useSystemId then
		local cfg = LTConfig.InformUseSystemConfig.GetConfig(data.useSystemId)
		matterList = cfg.Type
	end

	if table.isNilOrEmpty(matterList) then
		matterList = LTConfig.InformConfig.DefaultMatter
	end

	self.instance.matterList = matterList

	self.bindData.list:SetSimpleList(#matterList)
end

function M:OnRenderListItem(btn, csIndex)
	local index = csIndex + 1
	local store = self:GetStoreByWidget(btn)
	local data = self.instance.matterList[index]
	local cfg = LTConfig.InformMatterConfig.GetConfig(data)
	store.title = cfg.Name
end

function M:OnCommitBtnClick()
	local selectedCsIndex = self.bindData.list.selectedIndex
	local matterId = self.instance.matterList[selectedCsIndex + 1]

	if matterId == nil then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SelectReportTypeHint)

		return
	end

	local text = self.bindData.inputField.text

	gClientToGameDelegate:AskReport(self.instance.data.pid, {
		matterId
	}, text).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ReportSuccess)
		else
			gDisplayMessageMgr:ShowServerMessage(err)
		end

		self:ClosePanel()
	end
end

function M:OnCancelBtnClick()
	self:ClosePanel()
end

function M:ClosePanel()
	gPanelManager:Close(self.instance.panelId)
end

function M:OnDestroy()
	self.instance = nil
end
