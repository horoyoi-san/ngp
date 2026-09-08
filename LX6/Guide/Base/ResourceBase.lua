-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\ResourceBase.lua
-- Decompiled from: 00381_ResourceBase.lua_daa7012b4299.luajit

C_GuideBT_ResourceBase = DefClass("C_GuideBT_ResourceBase", C_GuideBT_ResourceBase, C_GuideBT_NodeBase)
local M = C_GuideBT_ResourceBase

M.OnCreate = function(self)
end

M.AddOutput = function(self, fieldName)
	local outputResProxy = C_GuideBT_ResProxy.NewProxy()
	self[fieldName] = outputResProxy
	outputResProxy.res = self
end

M.Eval = function(self)
end
