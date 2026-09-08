-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DartInfoStore.lua
-- Decompiled from: 01514_DartInfoStore.lua_8ba94d6b8bb7.luajit

C_DartInfoStore = DefClass("C_DartInfoStore", C_DartInfoStore, C_StoreGroup)
GroupName2Class.DartInfoStore = C_DartInfoStore
local M = C_DartInfoStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.BtnExit.luaClick = self.CreateAction(self, "OnExitBtn")
end

M.OnExitBtn = function(self)
	gPanelManager:Close(gPanelId.S_DART_INFO)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end
