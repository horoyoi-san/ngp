C_GuideBT_NodeBase = DefClass("C_GuideBT_NodeBase", C_GuideBT_NodeBase)
local M = C_GuideBT_NodeBase

function M:OnCreate()
	return
end

function M:GetBlackboard()
	return self.tree.blackboard
end
