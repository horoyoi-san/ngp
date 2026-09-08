-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\Sequence.lua
-- Decompiled from: 00390_Sequence.lua_8baada525fb0.luajit

C_GuideBT_Sequence = DefClass("C_GuideBT_Sequence", C_GuideBT_Sequence, C_GuideBT_CompositeBase)
local M = C_GuideBT_Sequence

M.OnTick = function(self)
	local startIndex = nil

	if self.reactive or not self.runningIndex then
		startIndex = 1
	else
		startIndex = self.runningIndex
	end

	self.runningIndex = 1

	for i = startIndex, self.childCount do
		local child = self.children[i]

		if child ~= nil then
			-- Nothing
		else
			local state = child.DoTick(child)

			if state ~= gGuideNodeState.Running then
				self.runningIndex = i

				return gGuideNodeState.Running
			elseif state ~= gGuideNodeState.Failure then
				return gGuideNodeState.Failure
			end
		end
	end

	return gGuideNodeState.Success
end

M.OnExitRunning = function(self)
	M.base.OnExitRunning(self)

	if self.autoResetStep then
		self.runningIndex = nil
	end
end
