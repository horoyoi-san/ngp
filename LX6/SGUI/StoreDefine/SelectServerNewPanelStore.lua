-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SelectServerNewPanelStore.lua
-- Decompiled from: 00882_SelectServerNewPanelStore.lua_ba5c079cec7c.luajit

local MessageConfig = LTConfig.MessageConfig
C_SelectServerNewPanelStore = DefClass("C_SelectServerNewPanelStore", C_SelectServerNewPanelStore, C_StoreGroup)
GroupName2Class.SelectServerNewPanelStore = C_SelectServerNewPanelStore
local M = C_SelectServerNewPanelStore

M.ctor = function(self)
	self.servers = {}
	self.forceSelect = false
end

M.OnAwake = function(self)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnTabListSelectedChange)
	self.bindData.contentList.luaSimpleClick = self.CreateAction(self, self.OnContentListClick)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.filterField.luaValueChanged = self.CreateAction(self, "OnFilterFieldValueChanged")
	self.filter = ""
	self.mgr = gLoginManager
end

local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local TAB = {
	["4\\xb3\\x8a͈\\x9e\\xad\\xf9\\xdd\\xe3\\xa8\\xba\\xd0"] = 0
}

M.OnShow = function(self, panelId, data)
	if data == nil then
		self.forceSelect = data.forceSelect
		self.bindData.showBackBtn = BOOL2CTL[not self.forceSelect]
	end

	self.servers = self.mgr.availableServerList

	self.BuildTabs(self)
end

M.BuildTabs = function(self)
	self.tabs, self.serverSessionNameMap = self.mgr:BuildServerMap()

	self.bindData.tabList:InitSimpleList()

	for i = 1, #self.tabs do
		self.bindData.tabList:AddSimpleLabel(0, self.tabs[i].label)
	end

	self.bindData.tabList:RefreshList()
	self.bindData.tabList:SelectItem(TAB.RECOMMENDED_SERVER)
end

M.OnTabListSelectedChange = function(self, uList)
	self.RefreshServer(self, uList.selectedIndex + 1)
end

M.OnFilterFieldValueChanged = function(self)
	self.filter = string.lower(self.bindData.filterField.text)

	self.RefreshServer(self, self.bindData.tabList.selectedIndex + 1)
end

M.RefreshServer = function(self, index)
	local session = self.tabs[index].label
	local servers = self.serverSessionNameMap[session]
	self.serverList = {}

	if not table.isNilOrEmpty(servers) then
		for i = 1, #servers do
			local server = servers[i]
			local servData = {
				id = server[1],
				label = server[2].Name,
				isConsistent = self.mgr:CheckVersion(server[2]),
				status = server[2].Status
			}

			if string.is_null_or_empty(self.filter) or string.find(string.lower(servData.label), self.filter) then
				if servData.isConsistent then
					table.insert(self.serverList, 1, servData)
				else
					table.insert(self.serverList, servData)
				end
			end
		end
	end

	self.bindData.contentList:InitSimpleList()

	for i = 1, #self.serverList do
		self.bindData.contentList:AddSimpleLabel(0, self.serverList[i].label)
	end

	self.bindData.contentList:RefreshList()
end

M.LoginToServer = function(self, index)
	local server = self.servers[index]

	gLoginManager:OnChangeServer(server)
	gPanelManager:Close(gPanelId.SELECT_SERVER_NEW)
end

M.OnContentListClick = function(self, btn, index)
	local data = self.serverList[index + 1]
	local index = data.id

	if self.servers[index].Status <= 0 then
		self.LoginToServer(self, index)
	else
		slot5 = gDisplayMessageMgr

		slot5:ShowMessage(MessageConfig.LoginMaintain, function ()
			self:LoginToServer(index)
		end)
	end
end

M.OnBackBtnClick = function(self)
	if self.forceSelect then
		return
	end

	gPanelManager:Close(gPanelId.SELECT_SERVER_NEW)
end

M.OnClose = function(self)
end
