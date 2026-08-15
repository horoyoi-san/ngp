C_GuideBT_Pow = DefClass("C_GuideBT_Pow", C_GuideBT_Pow, C_GuideBT_ResourceBase)
local M = C_GuideBT_Pow

function M:Eval()
	self.output.val = Mathf.Pow(self.baseValue:Eval(), self.exponent:Eval())
end
