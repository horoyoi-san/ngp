C_GuideBT_GameTimeData = DefClass("C_GuideBT_GameTimeData", C_GuideBT_GameTimeData, C_GuideBT_ResourceBase)
local M = C_GuideBT_GameTimeData

function M:Eval()
	self.seconds:SetValue(Time.time)
end
