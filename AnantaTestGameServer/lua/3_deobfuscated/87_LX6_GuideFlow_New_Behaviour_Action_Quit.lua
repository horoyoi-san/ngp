C_GuideBT_Quit = DefClass("C_GuideBT_Quit", C_GuideBT_Quit, C_GuideBT_ActionBase)
local M = C_GuideBT_Quit

function M:OnTick()
	self.tree:PerformQuit()

	return gGuideNodeState.Success
end
