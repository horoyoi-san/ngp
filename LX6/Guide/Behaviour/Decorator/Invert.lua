-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Decorator\Invert.lua
-- Decompiled from: 00392_Invert.lua_d42c082c276d.luajit

C_GuideBT_Invert = DefClass("C_GuideBT_Invert", C_GuideBT_Invert, C_GuideBT_DecoratorBase)
local M = C_GuideBT_Invert

M.OnTick = function(self)
	local child = self.GetChild(self)

	if not child then
		return gGuideNodeState.Failure
	end

	local state = child.DoTick(child)

	if state ~= gGuideNodeState.Success then
		return gGuideNodeState.Failure
	elseif state ~= gGuideNodeState.Failure then
		return gGuideNodeState.Success
	else
		return state
	end
end
