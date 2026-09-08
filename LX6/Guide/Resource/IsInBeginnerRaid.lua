-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\IsInBeginnerRaid.lua
-- Decompiled from: 00482_IsInBeginnerRaid.lua_da372217514f.luajit

C_GuideBT_IsInBeginnerRaid = DefClass("C_GuideBT_IsInBeginnerRaid", C_GuideBT_IsInBeginnerRaid, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsInBeginnerRaid

M.Eval = function(self)
	self.output.val = gUIUtils:IsInXinShouRaid()
end
