-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterDailyStore.lua
-- Decompiled from: 01721_HotCenterDailyStore.lua_e993f04ce30e.luajit

C_HotCenterDailyStore = DefClass("C_HotCenterDailyStore", C_HotCenterDailyStore, C_StoreGroup)
GroupName2Class.HotCenterDailyStore = C_HotCenterDailyStore
local M = C_HotCenterDailyStore

local ShowStorePanelByWidget = function(widget, data)
	if not widget or not widget.Store then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget and storeGroup:GetStoreByWidget(widget)

	if store and store.ShowPanel then
		store.ShowPanel(store, data)

		return
	end

	if storeGroup.ShowPanel then
		storeGroup.ShowPanel(storeGroup, data)
	end
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.rankListData = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	self.bindData.rankItemList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRankItem")
	self.bindData.rankItemList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderRankItem")
end

M.ShowPanel = function(self, data)
	self.rankListData = data and data.rankList or {}
	self.bindData.title = data and data.title or ""

	self.bindData.rankItemList:SetSimpleList(#self.rankListData)
end

M.OnSimpleRenderRankItem = function(self, btn, index)
	local data = self.rankListData[index + 1]

	if not data then
		return
	end

	ShowStorePanelByWidget(btn, data)
end
