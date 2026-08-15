C_GuideBT_DecoratorBase = DefClass("C_GuideBT_DecoratorBase", C_GuideBT_DecoratorBase, C_GuideBT_CompositeBase)
local M = C_GuideBT_DecoratorBase

function M:GetChild()
	return self.children[1]
end
