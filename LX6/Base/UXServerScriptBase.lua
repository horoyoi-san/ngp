-- Original chunk: @Lua\LuaFiles\LX6\Base\UXServerScriptBase.lua
-- Decompiled from: 00057_UXServerScriptBase.lua_8460e178a1ea.luajit

local Formula = nil
local UXServerScriptBase = {}
local M = {
	["M\\x94\\x8a\\x86E"] = false,
	Error = function (o, name)
		if name == nil then
			print_error(name, o)
		else
			print_error(o)
		end
	end,
	Warn = function (o, name)
		if name == nil then
			print_warn(name, o)
		else
			print_warn(o)
		end
	end,
	Log = function (o, name)
		if name == nil then
			print_debug(name, o)
		else
			print_debug(o)
		end
	end
}

M.Random = function(min, max)
	if not M.seeded then
		math.randomseed(os.time())

		M.seeded = true
	end

	local num = math.random()

	return num * (max - min) + min
end

M.GetSpiritLevel = function(star, quality)
	if Formula ~= nil then
		Formula = require("LuaGen/AutoGen/Formula_cs")
	end

	return Formula.GetSpiritLevel(star, quality)
end

UXServerScriptBase.Utils = M

return UXServerScriptBase
