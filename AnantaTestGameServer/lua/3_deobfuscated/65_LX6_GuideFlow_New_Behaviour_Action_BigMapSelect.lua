C_GuideBT_BigMapSelect = DefClass("C_GuideBT_BigMapSelect", C_GuideBT_BigMapSelect, C_GuideBT_ActionBase)
local M = C_GuideBT_BigMapSelect

function M:DoTick()
	if gBigMapHelper:TrySelectOnBigMapByGpsId(self.gpsId) then
		return gGuideNodeState.Success
	else
		return gGuideNodeState.Running
	end
end
