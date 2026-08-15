C_GuideBT_AllParallel = DefClass("C_GuideBT_AllParallel", C_GuideBT_AllParallel, C_GuideBT_CompositeBase)
local M = C_GuideBT_AllParallel

function M:OnCreate()
	self.curState = gGuideNodeState.Running
end

function M:OnTick()
	if self.curState == gGuideNodeState.Failure then
		return self.curState
	end

	self.curState = gGuideNodeState.Success

	for i = 1, self.childCount do
		local child = self.children[i]

		if child ~= nil then
			local state = child:DoTick()

			if state == gGuideNodeState.Failure then
				self.curState = gGuideNodeState.Failure

				return state
			end

			if state == gGuideNodeState.Running then
				self.curState = gGuideNodeState.Running
			end
		end
	end

	return self.curState
end
