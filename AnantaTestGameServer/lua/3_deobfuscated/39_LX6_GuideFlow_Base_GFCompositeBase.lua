C_GFCompositeBase = DefClass("C_GFCompositeBase", C_GFCompositeBase, C_GFNodeBase)
local C_GFCompositeBase = C_GFCompositeBase

function C_GFCompositeBase:ctor(id, isMonitor)
	self.mChilds = {}
	self.mNodeName = "C_GFCompositeBase"
end

function C_GFCompositeBase:AddChild(...)
	local childs = {
		...
	}

	for k, v in ipairs(childs) do
		if self:HasNode(v) then
			print_error("C_GFCompositeBase:AddChild(): node ", v:GetNodeName(), v:GetId(), "has exist.")

			return
		end

		table.insert(self.mChilds, v)
	end
end

function C_GFCompositeBase:RemoveChild(node)
	local hasNode, index = self:HasNode(node)

	if hasNode then
		table.remove(self.mChilds, index)
	end
end

function C_GFCompositeBase:HasNode(node)
	for k, v in ipairs(self.mChilds) do
		if v == node then
			return true, k
		end
	end

	return false, -1
end

function C_GFCompositeBase:OnUpdateForce()
	for k, v in pairs(self.mChilds) do
		v:OnUpdateForce()
	end
end

function C_GFCompositeBase:SetTree(tree)
	self.mBTree = tree

	for k, v in pairs(self.mChilds) do
		v:SetTree(tree)
	end
end

function C_GFCompositeBase:RefreshDebugInfo()
	C_GFCompositeBase.base.RefreshDebugInfo(self)

	for k, v in pairs(self.mChilds) do
		v:RefreshDebugInfo()
	end
end

function C_GFCompositeBase:PrintCurrentRunningState()
	C_GFCompositeBase.base.PrintCurrentRunningState(self)

	for k, v in pairs(self.mChilds) do
		v:PrintCurrentRunningState()
	end
end

return C_GFCompositeBase
