-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\SetCounter.lua
-- Decompiled from: 00428_SetCounter.lua_cbf3b2dda06f.luajit

C_GuideBT_SetCounter = DefClass("C_GuideBT_SetCounter", C_GuideBT_SetCounter, C_GuideBT_ActionBase)
local M = C_GuideBT_SetCounter

M.OnTick = function(self)
	local counterKey = self.counterKey:Eval()
	local value = self.value:Eval()

	if string.is_null_or_empty(counterKey) then
		print_error("@huangzhecong SetCounter没有设置counterKey,guideId =", self.tree.guideId)

		return gGuideNodeState.Failure
	end

	if not value then
		print_error("SetCounter没有设置value,guideId =", self.tree.guideId, "counterKey =", counterKey)

		return gGuideNodeState.Failure
	end

	self.tree:SetCounterValue(counterKey, value)
	print_debug("SetCounter设置counterKey =", counterKey, "value =", value, "guideId =", self.tree.guideId)

	return gGuideNodeState.Success
end
