C_GuideBT_WaitSignalV1 = DefClass("C_GuideBT_WaitSignalV1", C_GuideBT_WaitSignalV1, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitSignalV1

function M:OnTick()
	if gNewGuideMgr:TryConsumeSignal(self.signal) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
