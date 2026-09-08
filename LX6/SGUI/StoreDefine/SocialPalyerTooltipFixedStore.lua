-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialPalyerTooltipFixedStore.lua
-- Decompiled from: 01286_SocialPalyerTooltipFixedStore.lua_daf09603c312.luajit

C_SocialPalyerTooltipFixedStore = DefClass("C_SocialPalyerTooltipFixedStore", C_SocialPalyerTooltipFixedStore, C_StoreGroup)
GroupName2Class.SocialPalyerTooltipFixedStore = C_SocialPalyerTooltipFixedStore
local M = C_SocialPalyerTooltipFixedStore

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnShow = function(self, panelId, data)
	self.pid = data
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore")

	store:SetData(self.pid)
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.SOCIAL_PLAYER_TOOLTIP)
end
