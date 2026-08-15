C_GuideBT_FirstAgentClaimableRewardGuideId = DefClass("C_GuideBT_FirstAgentClaimableRewardGuideId", C_GuideBT_FirstAgentClaimableRewardGuideId, C_GuideBT_ResourceBase)
local M = C_GuideBT_FirstAgentClaimableRewardGuideId

function M:Eval()
	local guideId = self.profileId and gAgentTrustManager:GetFirstClaimableRewardGuideId(self.profileId)

	if guideId then
		self.guideId.val = guideId
	else
		print_error("未获取到正确的角色图鉴首个可领奖励guideId，profileId:", self.profileId)
	end
end
