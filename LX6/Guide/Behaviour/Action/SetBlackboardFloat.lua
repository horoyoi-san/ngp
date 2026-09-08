-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetBlackboardFloat.lua
-- Decompiled from: 00427_SetBlackboardFloat.lua_4f7b541f2390.luajit

C_GuideBT_SetBlackboardFloat = DefClass("C_GuideBT_SetBlackboardFloat", C_GuideBT_SetBlackboardFloat, C_GuideBT_ActionBase)
local M = C_GuideBT_SetBlackboardFloat

M.OnTick = function(self)
	if self.key then
		local val = self.value:Eval()
		self:GetBlackboard()[self.key] = val
	end

	return gGuideNodeState.Success
end
