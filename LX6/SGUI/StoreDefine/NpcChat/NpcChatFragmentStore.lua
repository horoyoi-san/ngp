-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatFragmentStore.lua
-- Decompiled from: 01231_NpcChatFragmentStore.lua_b2bf1e5ac141.luajit

C_NpcChatFragmentStore = DefClass("C_NpcChatFragmentStore", C_NpcChatFragmentStore, C_StoreGroup)
local M = C_NpcChatFragmentStore

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
