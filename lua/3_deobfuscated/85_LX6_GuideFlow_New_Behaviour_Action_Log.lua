C_GuideBT_Log = DefClass("C_GuideBT_Log", C_GuideBT_Log, C_GuideBT_ActionBase)
local M = C_GuideBT_Log

function M:OnTick()
	print_notice(self.message)

	return gGuideNodeState.Success
end
