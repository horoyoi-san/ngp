-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\Selector.lua
-- Decompiled from: 00389_Selector.lua_e77331f66d76.luajit

C_GuideBT_Selector = DefClass("C_GuideBT_Selector", C_GuideBT_Selector, C_GuideBT_CompositeBase)
local M = C_GuideBT_Selector

M.OnTick = function(self)
	local startIndex = nil

	if self.reactive or not self.runningIndex then
		startIndex = 1
	else
		startIndex = self.runningIndex
	end

	for i = startIndex, self.childCount do
		local child = self.children[i]

		if child ~= nil then
			-- Nothing
		else
			local state = child.DoTick(child)

			if state ~= gGuideNodeState.Running then
				self.runningIndex = i

				return gGuideNodeState.Running
			elseif state ~= gGuideNodeState.Success then
				return gGuideNodeState.Success
			end
		end
	end

	return gGuideNodeState.Failure
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self.autoResetStep then
		self.runningIndex = nil
	end
end
