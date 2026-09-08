-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\ActionBase.lua
-- Decompiled from: 00378_ActionBase.lua_a313e0e04a75.luajit

C_GuideBT_ActionBase = DefClass("C_GuideBT_ActionBase", C_GuideBT_ActionBase, C_GuideBT_BehaviourBase)
local M = C_GuideBT_ActionBase

M.AddEvent = function(self, name, node)
	if not name or name ~= "" then
		return
	end

	local proxy = self[name]

	if not proxy or not proxy.SetTarget then
		proxy = C_GuideBT_EventProxy.new()
		self[name] = proxy
	end

	proxy.SetTarget(proxy, node)
end

M.Invoke = function(self)
	if not self.tree then
		return
	end

	self.DoTick(self)
end
