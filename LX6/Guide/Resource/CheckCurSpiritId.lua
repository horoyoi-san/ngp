-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckCurSpiritId.lua
-- Decompiled from: 00461_CheckCurSpiritId.lua_3484c7daefd6.luajit

C_GuideBT_CheckCurSpiritId = DefClass("C_GuideBT_CheckCurSpiritId", C_GuideBT_CheckCurSpiritId, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckCurSpiritId

M.Eval = function(self)
	self.output.val = self.curSpiritId ~= gSpiritManager:GetCurFirstSpiritTid()
end
