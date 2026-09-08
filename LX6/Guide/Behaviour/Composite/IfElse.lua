-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Composite\IfElse.lua
-- Decompiled from: 00387_IfElse.lua_1db0f983c70e.luajit

C_GuideBT_IfElse = DefClass("C_GuideBT_IfElse", C_GuideBT_IfElse, C_GuideBT_CompositeBase)
local M = C_GuideBT_IfElse

M.OnTick = function(self)
	if not self.condition then
		if not self.isErrored then
			print_error("Node IfElse missing condition", gNewGuideMgr:GetCurrentGuideStatus())

			self.isErrored = true
		end

		return gGuideNodeState.Failure
	end

	self.result = self.condition:Eval()

	if self.result then
		if self.children[1] then
			return self.children[1]:DoTick()
		else
			return gGuideNodeState.Success
		end
	elseif self.children[2] then
		return self.children[2]:DoTick()
	else
		return gGuideNodeState.Success
	end
end

M.GetDebugLabel = function(self)
	return self.result
end
