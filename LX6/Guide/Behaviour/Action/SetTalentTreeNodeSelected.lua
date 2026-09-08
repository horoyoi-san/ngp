-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetTalentTreeNodeSelected.lua
-- Decompiled from: 00430_SetTalentTreeNodeSelected.lua_c61214d9affb.luajit

C_GuideBT_SetTalentTreeNodeSelected = DefClass("C_GuideBT_SetTalentTreeNodeSelected", C_GuideBT_SetTalentTreeNodeSelected, C_GuideBT_ActionBase)
local M = C_GuideBT_SetTalentTreeNodeSelected

M.OnTick = function(self)
	if self.talentId then
		gMessageManager:SendMessage(gEventConstants.SELECTED_TALENT_ID, self.talentId)

		return gGuideNodeState.Success
	else
		print_error("@C_GuideBT_SetTalentTreeNodeSelected talentId is nil")

		return gGuideNodeState.Failure
	end
end
