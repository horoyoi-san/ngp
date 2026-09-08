-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\CheckParkourState.lua
-- Decompiled from: 00465_CheckParkourState.lua_6d955db62c20.luajit

C_GuideBT_CheckParkourState = DefClass("C_GuideBT_CheckParkourState", C_GuideBT_CheckParkourState, C_GuideBT_ResourceBase)
local M = C_GuideBT_CheckParkourState

M.Eval = function(self)
	self.output.val = gCS.PaoKuManager.ParkourStateLua ~= self.state
end
