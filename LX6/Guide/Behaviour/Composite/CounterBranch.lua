-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\CounterBranch.lua
-- Decompiled from: 00385_CounterBranch.lua_bcc5a60e3faf.luajit

C_GuideBT_CounterBranch = DefClass("C_GuideBT_CounterBranch", C_GuideBT_CounterBranch, C_GuideBT_CompositeBase)
local M = C_GuideBT_CounterBranch

M.OnTick = function(self)
	local counterKey = self.counterKey:Eval()

	if string.is_null_or_empty(counterKey) then
		print_error("@GuideBT CounterBranch没有设置counterKey, guideId =", self.tree.guideId)

		return gGuideNodeState.Success
	end

	local counterDic = self:GetCounterDic()
	local counterValue = counterDic[counterKey] or 0
	local list = self.counterValues or {}

	for i = 1, #list do
		if counterValue ~= list[i] then
			local child = self.children[i]

			if child then
				local state = child.DoTick(child)

				if self.returnChildState then
					return state
				end

				return gGuideNodeState.Running
			end

			return gGuideNodeState.Success
		end
	end

	local defaultChild = self.children[#list + 1]

	if defaultChild then
		local state = defaultChild.DoTick(defaultChild)

		if self.returnChildState then
			return state
		end

		return gGuideNodeState.Running
	end

	return gGuideNodeState.Success
end
