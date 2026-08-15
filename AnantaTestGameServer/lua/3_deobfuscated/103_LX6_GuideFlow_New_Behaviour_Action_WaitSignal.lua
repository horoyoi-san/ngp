C_GuideBT_WaitSignal = DefClass("C_GuideBT_WaitSignal", C_GuideBT_WaitSignal, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitSignal

function M:OnTick()
	if gNewGuideMgr:TryConsumeSignal(EGuideSignal[self.signal]) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
