-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\FieldProxy.lua
-- Decompiled from: 00375_FieldProxy.lua_8ef751bbf662.luajit

C_GuideBT_FieldProxy = DefClass("C_GuideBT_FieldProxy", C_GuideBT_FieldProxy)
local M = C_GuideBT_FieldProxy

M.ctor = function(self)
end

M.Eval = function(self)
	if self.resProxy then
		return self.resProxy:Eval()
	end

	return self.val
end
