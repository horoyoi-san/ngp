C_GuideBT_IsInBeginnerRaid = DefClass("C_GuideBT_IsInBeginnerRaid", C_GuideBT_IsInBeginnerRaid, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsInBeginnerRaid

function M:Eval()
	self.output.val = gUIUtils:IsInXinShouRaid()
end
