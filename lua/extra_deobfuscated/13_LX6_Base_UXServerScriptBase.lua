local Formula = nil
local UXServerScriptBase = {}
local M = {
	seeded = false,
	Error = function (o, name)
		if name ~= nil then
			print_error(name, o)
		else
			print_error(o)
		end
	end,
	Warn = function (o, name)
		if name ~= nil then
			print_warn(name, o)
		else
			print_warn(o)
		end
	end,
	Log = function (o, name)
		if name ~= nil then
			print_debug(name, o)
		else
			print_debug(o)
		end
	end
}

function M.Random(min, max)
	if not M.seeded then
		math.randomseed(os.time())

		M.seeded = true
	end

	local num = math.random()

	return num * (max - min) + min
end

function M.GetSpiritLevel(star, quality)
	if Formula == nil then
		Formula = require("LuaGen/AutoGen/Formula_cs")
	end

	return Formula.GetSpiritLevel(star, quality)
end

UXServerScriptBase.Utils = M

return UXServerScriptBase
