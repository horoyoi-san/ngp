-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\AllParallel.lua
-- Decompiled from: 00384_AllParallel.lua_00d16b0d796b.luajit

C_GuideBT_AllParallel = DefClass("C_GuideBT_AllParallel", C_GuideBT_AllParallel, C_GuideBT_CompositeBase)
local M = C_GuideBT_AllParallel

M.OnCreate = function(self)
	self.curState = gGuideNodeState.Running
end

M.OnTick = function(self)
	self.curState = gGuideNodeState.Success

	for i = 1, self.childCount do
		local child = self.children[i]

		if child == nil then
			local state = child.DoTick(child)

			if state ~= gGuideNodeState.Failure then
				self.curState = gGuideNodeState.Failure

				return state
			end

			if state ~= gGuideNodeState.Running then
				self.curState = gGuideNodeState.Running
			end
		end
	end

	return self.curState
end
