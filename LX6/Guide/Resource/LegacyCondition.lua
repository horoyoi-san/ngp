-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\LegacyCondition.lua
-- Decompiled from: 00486_LegacyCondition.lua_adf8633468cc.luajit

C_GuideBT_LegacyCondition = DefClass("C_GuideBT_LegacyCondition", C_GuideBT_LegacyCondition, C_GuideBT_ResourceBase)
local M = C_GuideBT_LegacyCondition

M.Eval = function(self)
	self.result = gGFCondition:CheckCondition(self.condition) and true or false
	self.output.val = self.result
end

M.GetDebugLabel = function(self)
	return self.result
end
