-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Decorator\If.lua
-- Decompiled from: 00391_If.lua_ea9432ca32f2.luajit

C_GuideBT_If = DefClass("C_GuideBT_If", C_GuideBT_If, C_GuideBT_DecoratorBase)
local M = C_GuideBT_If

M.OnTick = function(self)
	if not self.condition then
		if not self.isErrored then
			print_error("Node If missing condition", gNewGuideMgr:GetCurrentGuideStatus())

			self.isErrored = true
		end

		return gGuideNodeState.Failure
	end

	self.result = self.condition:Eval()

	if self.result then
		if self.GetChild(self) then
			return self:GetChild():DoTick()
		else
			return gGuideNodeState.Success
		end
	end

	return gGuideNodeState.Failure
end

M.GetDebugLabel = function(self)
	return self.result
end
