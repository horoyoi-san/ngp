-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\FirstAgentClaimableRewardGuideId.lua
-- Decompiled from: 00473_FirstAgentClaimableRewardGuideId.lua_1db470ac62b6.luajit

C_GuideBT_FirstAgentClaimableRewardGuideId = DefClass("C_GuideBT_FirstAgentClaimableRewardGuideId", C_GuideBT_FirstAgentClaimableRewardGuideId, C_GuideBT_ResourceBase)
local M = C_GuideBT_FirstAgentClaimableRewardGuideId

M.Eval = function(self)
	local guideId = self.profileId and gAgentTrustManager:GetFirstClaimableRewardGuideId(self.profileId)

	if guideId then
		local proxy = self.guideKey or self.guideId

		if proxy then
			proxy.val = guideId
		end
	else
		print_error("未获取到正确的角色图鉴首个可领奖励guideId，profileId:", self.profileId)
	end
end
