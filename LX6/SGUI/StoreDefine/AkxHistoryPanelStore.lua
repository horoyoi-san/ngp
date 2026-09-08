-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\AkxHistoryPanelStore.lua
-- Decompiled from: 01603_AkxHistoryPanelStore.lua_ffd4848cb269.luajit

C_AkxHistoryPanelStore = DefClass("C_AkxHistoryPanelStore", C_AkxHistoryPanelStore, C_StoreGroup)
GroupName2Class.AkxHistoryPanelStore = C_AkxHistoryPanelStore
local M = C_AkxHistoryPanelStore

M.ctor = function(self)
	self.sessions = {}
	self.selectedIdx = nil
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnClickListItem)
	self.bindData.btnClear.luaClick = self.CreateAction(self, self.ClearAll)
	self.bindData.btnClose.luaClick = self.CreateAction(self, self.Close)
	self.bindData.btnClose2.luaClick = self.CreateAction(self, self.Close)
end

M.RefreshPanel = function(self, selectedSessionid)
	self.LoadSessions(self)

	self.selectedIdx = nil

	for idx, session in ipairs(self.sessions) do
		if selectedSessionid ~= session.id then
			self.selectedIdx = idx
		end
	end

	self.bindData.list:SetSimpleList(#self.sessions)

	if self.selectedIdx then
		self.bindData.list:SelectItem(self.selectedIdx)
	end
end

M.LoadSessions = function(self)
	local sessions = gAkxManager:GetSessions()
	self.sessions = {}

	for i, s in pairs(sessions) do
		local session = s

		table.insert(self.sessions, {
			id = session.id,
			title = session.title,
			create_time = session.create_time
		})
	end

	table.sort(self.sessions, function (a, b)
		return b.create_time <= a.create_time
	end)
end

M.OnEnable = function(self)
	self.InitEvent(self)
	self.RefreshPanel(self)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.AKX_SESSION_UPDATED] = self.CreateAction(self, self.OnSessionUpdated)
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
end

M.OnSimpleRenderListItem = function(self, item, index)
	index = index + 1
	local session = self.sessions[index]
	local store = gStoreManager:GetStoreGroup(item.Store):GetStoreByWidget(item)

	if store and session and store.title and session.title then
		if store.title and store.title then
			store.title.text = session.title
		end

		if store.btnDelete then
			store.btnDelete.luaClick = self.CreateActionWithArgs(self, self.OnClickListItemDelete, index)
		end
	end
end

M.OnClickListItem = function(self, _, index)
	index = index + 1
	local session = self.sessions[index]
	local homeStore = self._GetAkxHomePanelStore(self)

	if session and homeStore then
		homeStore.RefreshPanel(homeStore, {
			sessionid = session.id
		})
		homeStore.PlayTabSwitchAnim(homeStore, LTConfig.AkashaTabConfig.TypeType.Home, LTConfig.AkashaTabConfig.TypeType.Chat)
		self.Close(self)
	end
end

M.OnClickListItemDelete = function(self, index)
	local session = self.sessions[index]

	if not session then
		return
	end

	if not session.id then
		return
	end

	gAkxManager:RemoveSession(session.id)
end

M.OnSessionUpdated = function(self, _, data)
	local sessionid = nil

	if data and data.created and data.sessionid then
		sessionid = data.sessionid
	end

	if not sessionid then
		local page = self.sessions[self.currTabIdx]

		if page and page.sessionid then
			sessionid = page.sessionid

			if not gAkxManager:GetSession(sessionid) then
				sessionid = nil
			end
		end
	end

	self.RefreshPanel(self, sessionid)
end

M.ClearAll = function(self)
	gAkxManager:RemoveAllSession()

	self.selectedIdx = nil
end

M.Close = function(self)
	local store = self._GetAkxHomePanelStore(self)

	store.ToggleHistoryPanel(store)
end

M._GetAkxHomePanelStore = function(self)
	local name = "AkxHomeStore"
	local store = gStoreManager:GetStoreGroup(name)

	return store
end

M.OnActiveDeviceChange = function(self, device)
end
