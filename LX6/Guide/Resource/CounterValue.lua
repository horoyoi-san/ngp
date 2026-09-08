-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CounterValue.lua
-- Decompiled from: 00470_CounterValue.lua_7948df14df74.luajit

C_GuideBT_CounterValue = DefClass("C_GuideBT_CounterValue", C_GuideBT_CounterValue, C_GuideBT_ResourceBase)
local M = C_GuideBT_CounterValue

M.Eval = function(self)
	local counterKey = self.counterKey:Eval()

	if string.is_null_or_empty(counterKey) then
		print_error("@GuideBT CounterValue没有设置counterKey, guideId =", self.tree.guideId)

		self.output.val = 0

		return
	end

	local counterDic = self:GetCounterDic()
	self.output.val = counterDic[counterKey] or 0
end
