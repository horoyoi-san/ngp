C_GuideBT_FullScreenGuideRes = DefClass("C_GuideBT_FullScreenGuideRes", C_GuideBT_FullScreenGuideRes, C_GuideBT_ResourceBase)
local M = C_GuideBT_FullScreenGuideRes

function M:Eval()
	local val = {
		title = self.title,
		textureId = self.textureId,
		videoId = self.videoId,
		textId = self.textId,
		controllerId = self.controllerId,
		mobileId = self.mobileId
	}

	self.output:SetImmutable(val)
end
