C_GuideBT_GuideText = DefClass("C_GuideBT_GuideText", C_GuideBT_GuideText, C_GuideBT_ResourceBase)
local M = C_GuideBT_GuideText

function M:Eval()
	local val = {
		text = self.text,
		textId = self.textId,
		controllerId = self.controllerId,
		mobileId = self.mobileId,
		dualSenseId = self.dualSenseId
	}

	self.output:SetImmutable(val)
end
