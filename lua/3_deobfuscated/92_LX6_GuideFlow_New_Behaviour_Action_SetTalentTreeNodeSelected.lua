C_GuideBT_SetTalentTreeNodeSelected = DefClass("C_GuideBT_SetTalentTreeNodeSelected", C_GuideBT_SetTalentTreeNodeSelected, C_GuideBT_ActionBase)
local M = C_GuideBT_SetTalentTreeNodeSelected

function M:OnTick()
	if self.profileId then
		gMessageManager:SendMessage(gEventConstants.SELECTED_TALENT_ID, self.profileId)

		return gGuideNodeState.Success
	else
		print_error("@C_GuideBT_SetTalentTreeNodeSelected profileId is nil")

		return gGuideNodeState.Failure
	end
end
