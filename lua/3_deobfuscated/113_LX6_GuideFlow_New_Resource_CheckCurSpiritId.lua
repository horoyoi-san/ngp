C_GuideBT_CheckCurSpiritId = DefClass("C_GuideBT_CheckCurSpiritId", C_GuideBT_CheckCurSpiritId, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckCurSpiritId

function M:Eval()
	self.output.val = self.curSpiritId == gSpiritManager:GetCurFirstSpiritTid()
end
