C_GuideBT_BehaviourBase = DefClass("C_GuideBT_BehaviourBase", C_GuideBT_BehaviourBase, C_GuideBT_NodeBase)
local M = C_GuideBT_BehaviourBase

function M:OnTick()
	return gGuideNodeState.Success
end

function M:DoTick()
	local state = self:OnTick()
	self.cachedState = state

	if state == gGuideNodeState.Running or state == gGuideNodeState.Match then
		self.tree:RunNode(self)
	end

	return state
end

function M:OnEnterRunning()
	return
end

function M:Run()
	return
end

function M:OnExitRunning()
	return
end
