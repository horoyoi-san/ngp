local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFActionBase = DefClass("C_GFActionBase", C_GFActionBase, C_GFNodeBase)
local C_GFActionBase = C_GFActionBase

function C_GFActionBase:ctor(id, isMonitor)
	self.mNodeType = gGFConstant.NodeType.Action
	self.mNodeName = "C_GFActionBase"
end

return C_GFActionBase
