C_GuideBT_IsUGuideEnabled = DefClass("C_GuideBT_IsUGuideEnabled", C_GuideBT_IsUGuideEnabled, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsUGuideEnabled

function M:Eval()
	self.output.val = SGUI.GuideMgr.IsUGuideEnabled(self.guideId)
end
