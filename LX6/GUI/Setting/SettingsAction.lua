-- Original chunk: @Lua\LuaFiles\LX6\GUI\Setting\SettingsAction.lua
-- Decompiled from: 00888_SettingsAction.lua_edc57cceba06.luajit

local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
local SettingsAction = {}
local this = SettingsAction

SettingsAction.RunCode = function(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local isOk, result = xpcall(f, tolua.traceback)

		return isOk, result
	end

	return false
end

SettingsAction.RunFunc = function(code, data)
	if string.is_null_or_empty(code) then
		return true
	end

	SettingsScriptFunc.SettingData = nil
	SettingsScriptFunc.SettingData = data
	local isOk, result = this.RunCode(code, SettingsScriptFunc)

	SettingsScriptFunc.SetServerValue(data)

	if not isOk then
		print_error("SettingsAction.RunFunc ", code, "Failed: ", result)

		return false
	end

	return result == false
end

SettingsAction.RunProfileFunc = function(code, data)
	if string.is_null_or_empty(code) then
		return true
	end

	SettingsScriptFunc.SettingData = data
	local isOk, result = this.RunCode(code, SettingsScriptFunc)

	if not isOk then
		print_error("SettingsAction.RunProfileFunc ", code, "Failed: ", result)

		return false
	end

	return result == false
end

SettingsAction.CheckFunc = function(code, data)
	if string.is_null_or_empty(code) then
		return true
	end

	local func = SettingsScriptFunc[code]

	if func then
		return func(data)
	end

	return true
end

return SettingsAction
