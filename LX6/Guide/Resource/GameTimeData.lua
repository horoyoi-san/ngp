-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\GameTimeData.lua
-- Decompiled from: 00477_GameTimeData.lua_612e121e05a2.luajit

C_GuideBT_GameTimeData = DefClass("C_GuideBT_GameTimeData", C_GuideBT_GameTimeData, C_GuideBT_ResourceBase)
local M = C_GuideBT_GameTimeData

M.Eval = function(self)
	self.seconds:SetValue(Time.time)
end
