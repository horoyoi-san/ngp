C_GuideBT_CompositeBase = DefClass("C_GuideBT_CompositeBase", C_GuideBT_CompositeBase, C_GuideBT_BehaviourBase)
local M = C_GuideBT_CompositeBase

function M:ctor()
	self.children = {}
	self.childCount = 0
end

function M:AddChild(child)
	self.childCount = self.childCount + 1
	self.children[self.childCount] = child
end

function M:CompressChildren()
	local j = 1

	for i = 1, self.childCount do
		if self.children[i] then
			self.children[j] = self.children[i]
			j = j + 1
		end
	end
end
