-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\AddCounter.lua
-- Decompiled from: 00399_AddCounter.lua_d8e85630595a.luajit

C_GuideBT_AddCounter = DefClass("C_GuideBT_AddCounter", C_GuideBT_AddCounter, C_GuideBT_ActionBase)
local M = C_GuideBT_AddCounter

M.OnTick = function(self)
	local counterKey = self.counterKey:Eval()
	local value = self.value:Eval()

	if string.is_null_or_empty(counterKey) then
		print_error("@huangzhecong AddCounter没有设置counterKey,guideId =", self.tree.guideId)

		return gGuideNodeState.Failure
	end

	if not value then
		print_error("@huangzhecong AddCounter没有设置value,guideId =", self.tree.guideId, "counterKey =", counterKey)

		return gGuideNodeState.Failure
	end

	if value ~= 0 then
		print_error("@huangzhecong AddCounter的value为0没有意义,检查是否漏填,guideId =", self.tree.guideId, "counterKey =", counterKey)

		return gGuideNodeState.Success
	end

	local counterValue = self.tree:AddCounterValue(counterKey, value)

	print_debug("AddCounter设置counterKey =", counterKey, "addValue =", value, "resultValue =", counterValue, "guideId =", self.tree.guideId)

	return gGuideNodeState.Success
end
