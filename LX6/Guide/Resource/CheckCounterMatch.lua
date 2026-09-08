-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckCounterMatch.lua
-- Decompiled from: 00460_CheckCounterMatch.lua_13e911a180a9.luajit

C_GuideBT_CheckCounterMatch = DefClass("C_GuideBT_CheckCounterMatch", C_GuideBT_CheckCounterMatch, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckCounterMatch

M.Eval = function(self)
	local counterKey = self.counterKey:Eval()
	local matchValue = self.matchValue:Eval()

	if string.is_null_or_empty(counterKey) then
		print_error("@GuideBT CheckCounterMatch没有设置counterKey, guideId =", self.tree.guideId)

		self.output.val = false

		return
	end

	if not matchValue then
		print_error("@GuideBT CheckCounterMatch没有设置matchValue, guideId =", self.tree.guideId)

		self.output.val = false

		return
	end

	local counterDic = self:GetCounterDic()
	local counterValue = counterDic[counterKey] or 0
	self.output.val = counterValue ~= matchValue
end
