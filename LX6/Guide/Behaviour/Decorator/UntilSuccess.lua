-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Decorator\UntilSuccess.lua
-- Decompiled from: 00394_UntilSuccess.lua_626f0c816ed1.luajit

C_GuideBT_UntilSuccess = DefClass("C_GuideBT_UntilSuccess", C_GuideBT_UntilSuccess, C_GuideBT_DecoratorBase)
local M = C_GuideBT_UntilSuccess

M.OnTick = function(self)
	local child = self.GetChild(self)

	if not child then
		return gGuideNodeState.Failure
	end

	local state = child.DoTick(child)

	if state ~= gGuideNodeState.Success then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
