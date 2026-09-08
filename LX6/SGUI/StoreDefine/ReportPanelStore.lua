-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ReportPanelStore.lua
-- Decompiled from: 00904_ReportPanelStore.lua_dea04b3342ee.luajit

C_ReportPanelStore = DefClass("C_ReportPanelStore", C_ReportPanelStore, C_StoreGroup)
GroupName2Class.ReportPanelStore = C_ReportPanelStore
local M = C_ReportPanelStore

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderListItem)
	self.bindData.commitBtn.luaClick = self.CreateAction(self, self.OnCommitBtnClick)
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, self.OnCancelBtnClick)
end

M.OnShow = function(self, panelId, data)
	self.instance = {
		panelId = panelId,
		data = data
	}

	if not string.is_null_or_empty(data.name) then
		self.bindData.name = data.name
	else
		slot4 = gFriendManager
		self.bindData.name = slot4:GetPlayerRealName(data.pid)
		slot3 = gFriendManager

		slot3:GetPlayerRealName(data.pid, function (name)
			self.bindData.name = name
		end)
	end

	self.RefreshList(self, data)
end

M.RefreshList = function(self, data)
	local matterList = data.matterList

	if table.isNilOrEmpty(matterList) and data.systemId and data.useSystemId ~= nil then
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

M.OnRenderListItem = function(self, btn, csIndex)
	local index = csIndex + 1
	local store = self.GetStoreByWidget(self, btn)
	local data = self.instance.matterList[index]
	local cfg = LTConfig.InformMatterConfig.GetConfig(data)
	store.title = cfg.Name
end

M.OnCommitBtnClick = function(self)
	local selectedCsIndex = self.bindData.list.selectedIndex
	local matterId = self.instance.matterList[selectedCsIndex + 1]

	if matterId ~= nil then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SelectReportTypeHint)

		return
	end

	local text = self.bindData.inputField.text

	if self.instance.data.extraData then
		local json = require("cjson/json")
		local extraDataText = json.encode(self.instance.data.extraData)
		text = extraDataText .. "\n---\n" .. text
	end

	slot4 = gClientToGameDelegate

	slot4:AskReport(self.instance.data.pid, {
		matterId
	}, text).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ReportSuccess)
		else
			gDisplayMessageMgr:ShowServerMessage(err)
		end

		self:ClosePanel()
	end
end

M.OnCancelBtnClick = function(self)
	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.instance.panelId)
end

M.OnDestroy = function(self)
	self.instance = nil
end
