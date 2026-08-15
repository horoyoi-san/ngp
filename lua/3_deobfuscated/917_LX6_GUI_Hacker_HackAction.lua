local HackScriptFunc = require("LX6/GUI/Hacker/HackScriptFunc")
local HackAction = {}
local this = HackAction

function HackAction.RunCode(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

function HackAction.RunFunc(code, data)
	HackScriptFunc.SettingData = nil
	HackScriptFunc.SettingData = data
	local status, err = this.RunCode(code, HackScriptFunc)

	if not status then
		print_error("HackAction.RunFunc ", code, "Failed: ", err)
	end
end

return HackAction
