C_GuideBT_BigMapFocusV1 = DefClass("C_GuideBT_BigMapFocusV1", C_GuideBT_BigMapFocusV1, C_GuideBT_ActionBase)
local M = C_GuideBT_BigMapFocusV1

function M:DoTick()
	if gBigMapHelper:TryFocusOnBigMapByGpsId(self.gpsId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
