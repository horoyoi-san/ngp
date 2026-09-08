-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\PrimaryParallel.lua
-- Decompiled from: 00388_PrimaryParallel.lua_2c6ec349817d.luajit

C_GuideBT_PrimaryParallel = DefClass("C_GuideBT_PrimaryParallel", C_GuideBT_PrimaryParallel, C_GuideBT_CompositeBase)
local M = C_GuideBT_PrimaryParallel

M.OnCreate = function(self)
	self._dones = {}
end

M.OnTick = function(self)
	local main = self.children[1]

	if not main then
		return gGuideNodeState.Failure
	end

	local mainState = main.DoTick(main)

	if mainState ~= gGuideNodeState.Running then
		for i = 2, self.childCount do
			local child = self.children[i]

			if child and not self._dones[i] then
				local state = child.DoTick(child)

				if state == gGuideNodeState.Running then
					self._dones[i] = true
				end
			end
		end
	end

	return mainState
end

M.OnExitRunning = function(self)
	if self._dones then
		table.clear(self._dones)
	end
end
