C_GuideBT_CheckSwingAngle = DefClass("C_GuideBT_CheckSwingAngle", C_GuideBT_CheckSwingAngle, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckSwingAngle

function M:Eval()
	if gCS.PaoKuManager.ParkourStateLua ~= LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Swing then
		self.output.val = false

		return
	end

	local swingAngle = gCS.LuaUtils.OnlyGetSwingAngle()

	if swingAngle < self.min or self.max < swingAngle then
		self.output.val = false

		return
	end

	self.output.val = true
end
