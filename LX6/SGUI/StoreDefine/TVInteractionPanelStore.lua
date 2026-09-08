-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TVInteractionPanelStore.lua
-- Decompiled from: 01174_TVInteractionPanelStore.lua_93a23125ebf2.luajit

C_TVInteractionPanelStore = DefClass("C_TVInteractionPanelStore", C_TVInteractionPanelStore, C_StoreGroup)
GroupName2Class.TVInteractionPanelStore = C_TVInteractionPanelStore
local M = C_TVInteractionPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "PlayChangeTVState", gHomeInteractionManager)
	self.bindData.openBtn.luaClick = self.CreateAction(self, "PlayChangeTVState", gHomeInteractionManager)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "PlayExitTV", gHomeInteractionManager)
	self.bindData.tabBtn.luaClick = self.CreateAction(self, "PlayChangeTV", gHomeInteractionManager)
end

M.OnShow = function(self, panelId, data)
	gHomeInteractionManager:RegisterStore(self)
	self:RefreshInteraction()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.RefreshInteraction = function(self)
	self.bindData.inAction = 0
	self.bindData.isOpen = gHomeInteractionManager.tvState and 1 or 0
end
