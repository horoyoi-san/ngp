-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialSettingsPanelStore.lua
-- Decompiled from: 01289_SocialSettingsPanelStore.lua_d24233ef5fed.luajit

C_SocialSettingsPanelStore = DefClass("C_SocialSettingsPanelStore", C_SocialSettingsPanelStore, C_StoreGroup)
GroupName2Class.SocialSettingsPanelStore = C_SocialSettingsPanelStore
local M = C_SocialSettingsPanelStore

M.ctor = function(self)
	self.args = nil
end

M.OnAwake = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabListRenderItem")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnTabListItemClick")
	self.bindData.btnClose.luaClick = self.CreateAction(self, "OnClose")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
end

M.OnEnable = function(self)
end

M.SetData = function(self, args)
	self.args = args
	self.tabRects = {}

	for i = 0, LTConfig.FriendsSettingTabConfig.count - 1 do
		local cfg = LTConfig.FriendsSettingTabConfig.LoadAt(i)
		local tabrect = {
			id = cfg.Id,
			name = cfg.TabName,
			icon = cfg.TabIcon or 0,
			tabIdx = cfg.TabRectIndex or 0
		}

		if tabrect.tabIdx <= 0 then
			table.insert(self.tabRects, tabrect)
		end
	end

	self.RefreshPanel(self)
end

M.RefreshPanel = function(self)
	self.bindData.tabList:SetSimpleList(#self.tabRects)
	self:OnTabListItemClick(_, 0)
end

M.OnTabListItemClick = function(self, btn, index)
	local data = self.tabRects[index + 1]

	if data then
		self.bindData.tabRect.selectedIndex = data.tabIdx - 1
	end
end

M.OnTabListRenderItem = function(self, btn, index)
	local data = self.tabRects[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not data then
		return
	end

	store.title = data.name

	if data.icon and data.icon <= 0 then
		store.Commit(store, "icon", data.icon, COMMIT_FORCE)
	end

	if data.iconSelected and data.iconSelected <= 0 then
		store.Commit(store, "iconSelected", data.iconSelected, COMMIT_FORCE)
	end
end

M.OnRenderTab = function(self, _, widget)
	local group = gStoreManager:GetStoreGroup(widget.Store)

	if group then
		if self.args then
			group.SetData(group, self.args)

			self.args = nil

			return
		end

		group.SetData(group)
	end
end

M.OnClose = function(self)
	local store = gStoreManager:GetStoreGroup("SocialChatHomePanelStore")

	if store then
		store.OpenSettingPage(store)
	end
end

M.OnDisable = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
