-- Original chunk: @Lua\LuaFiles\LX6\GUI\Hacker\HackAction.lua
-- Decompiled from: 01693_HackAction.lua_4dbad021682f.luajit

local HackScriptFunc = require("LX6/GUI/Hacker/HackScriptFunc")
local HackAction = {}
local this = HackAction

HackAction.RunCode = function(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

HackAction.RunFunc = function(code, data)
	HackScriptFunc.SettingData = nil
	HackScriptFunc.SettingData = data
	local status, err = this.RunCode(code, HackScriptFunc)

	if not status then
		print_error("HackAction.RunFunc ", code, "Failed: ", err)
	end
end

return HackAction
