C_GuideBT_PrimaryParallel = DefClass("C_GuideBT_PrimaryParallel", C_GuideBT_PrimaryParallel, C_GuideBT_CompositeBase)
local M = C_GuideBT_PrimaryParallel

function M:OnCreate()
	self._dones = {}
end

function M:OnTick()
	local main = self.children[1]

	if not main then
		return gGuideNodeState.Failure
	end

	local mainState = main:DoTick()

	if mainState == gGuideNodeState.Running then
		for i = 2, self.childCount do
			local child = self.children[i]

			if child and not self._dones[i] then
				local state = child:DoTick()

				if state ~= gGuideNodeState.Running then
					self._dones[i] = true
				end
			end
		end
	end

	return mainState
end

function M:OnExitRunning()
	if self._dones then
		table.clear(self._dones)
	end
end
