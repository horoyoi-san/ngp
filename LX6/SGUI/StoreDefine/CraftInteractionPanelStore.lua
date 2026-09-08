-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CraftInteractionPanelStore.lua
-- Decompiled from: 01503_CraftInteractionPanelStore.lua_c3ba2fb63755.luajit

C_CraftInteractionPanelStore = DefClass("C_CraftInteractionPanelStore", C_CraftInteractionPanelStore, C_StoreGroup)
GroupName2Class.CraftInteractionPanelStore = C_CraftInteractionPanelStore
local M = C_CraftInteractionPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnLongPress")
	self.bindData.exitBtn.luaLongPress = self.CreateAction(self, "OnExitBtnLongPress")
end

M.OnShow = function(self, panelId, data)
end

M.OnExitBtnLongPress = function(self)
	gProduceManager:UnRegisterMachine()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end
