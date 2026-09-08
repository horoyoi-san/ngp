-- Original chunk: @Lua\LuaFiles\LX6\Utils\RewindDebugUtils.lua
-- Decompiled from: 00171_RewindDebugUtils.lua_2011abec0312.luajit

local M = {
	["\\x96':{\\x92S\\xdd>\\xa4\\xbe"] = false
}

M.SetRecording = function(self, value)
	self.isRecording = value

	print("gRewindDebugUtils.SetRecording", value)
end

gRewindDebugUtils = M
