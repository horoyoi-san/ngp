local SettingsScriptFunc = require("LX6/GUI/Setting/SettingsScriptFunc")
local SettingsAction = {}
local this = SettingsAction

function SettingsAction.RunCode(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

function SettingsAction.RunFunc(code, data)
	if string.is_null_or_empty(code) then
		return true
	end

	SettingsScriptFunc.SettingData = nil
	SettingsScriptFunc.SettingData = data
	local status, err = this.RunCode(code, SettingsScriptFunc)

	if not status then
		print_error("SettingsAction.RunFunc ", code, "Failed: ", err)

		return false
	end

	return status
end

function SettingsAction.CheckFunc(code, data)
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
