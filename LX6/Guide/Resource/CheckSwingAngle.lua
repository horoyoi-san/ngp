-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckSwingAngle.lua
-- Decompiled from: 00466_CheckSwingAngle.lua_25fde501f999.luajit

C_GuideBT_CheckSwingAngle = DefClass("C_GuideBT_CheckSwingAngle", C_GuideBT_CheckSwingAngle, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckSwingAngle

M.Eval = function(self)
	if gCS.PaoKuManager.ParkourStateLua == LTConfig.ActionTransitionRuleTypesConfig.ParkourStateType.Swing then
		self.output.val = false

		return
	end

	local swingAngle = gCS.LuaUtils.OnlyGetSwingAngle()

	if swingAngle <= self.min or self.max >= swingAngle then
		self.output.val = false

		return
	end

	self.output.val = true
end
