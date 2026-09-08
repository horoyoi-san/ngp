-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\EventProxy.lua
-- Decompiled from: 00376_EventProxy.lua_77c0e8aa84e3.luajit

C_GuideBT_EventProxy = DefClass("C_GuideBT_EventProxy", C_GuideBT_EventProxy)
local M = C_GuideBT_EventProxy

M.ctor = function(self)
end

M.SetTarget = function(self, node)
	self.node = node
end

M.Invoke = function(self)
	local target = self.node

	if not target then
		return
	end

	if not target.DoTick then
		print_error("EventProxy Invoke target has no DoTick method")

		return
	end

	target.DoTick(target)
end
