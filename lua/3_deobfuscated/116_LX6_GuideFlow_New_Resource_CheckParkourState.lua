C_GuideBT_CheckParkourState = DefClass("C_GuideBT_CheckParkourState", C_GuideBT_CheckParkourState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckParkourState

function M:Eval()
	self.output.val = gCS.PaoKuManager.ParkourStateLua == self.state
end
