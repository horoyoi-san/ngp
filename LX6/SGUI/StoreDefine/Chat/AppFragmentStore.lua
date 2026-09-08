-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\AppFragmentStore.lua
-- Decompiled from: 01270_AppFragmentStore.lua_0afebb09e9c4.luajit

C_AppFragmentStore = DefClass("C_AppFragmentStore", C_AppFragmentStore, C_StoreGroup)
local M = C_AppFragmentStore

M.OnShow = function(self, tabIndex, args)
end

M.OnPause = function(self)
end

M.OnResume = function(self)
end

M.OnClose = function(self)
end

M.HandleExit = function(self)
	return false
end

M._ShowFragment = function(self, args, tabIndex, activity)
	self.activity = activity

	self.OnShow(self, tabIndex, args)
end
