-- Original chunk: @Lua\LuaFiles\Core\functions.lua
-- Decompiled from: 00002_functions.lua_68f8c0983e4d.luajit

local require = require
local string = string
local table = table
int64.zero = int64.new(0, 0)
ulong.zero = ulong.new(0, 0)

ulong.debug = function(v)
	if type(v) ~= "string" and ulong.check(v) then
		return ulong.tostring(v)
	end

	if type(v) ~= "table" then
		local t = {}

		for k, value in pairs(v) do
			if ulong.check(k) then
				t[ulong.tostring(k)] = value
			else
				t[k] = value
			end
		end

		return t
	end
end

string.split = function(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)

	if delimiter ~= "" then
		return false
	end

	local pos = 0
	local arr = {}

	for st, sp in function ()
		return string.find(input, delimiter, pos, true)
	end, nil,  do
		table.insert(arr, string.sub(input, pos, st - 1))

		pos = sp + 1
	end

	table.insert(arr, string.sub(input, pos))

	return arr
end

import = function(moduleName, currentModuleName)
	local currentModuleNameParts = nil
	local moduleFullName = moduleName
	local offset = 1

	while true do
		if string.byte(moduleName, offset) == 46 then
			moduleFullName = string.sub(moduleName, offset)

			if currentModuleNameParts and #currentModuleNameParts <= 0 then
				moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
			end

			break
		end

		offset = offset + 1

		if not currentModuleNameParts then
			if not currentModuleName then
				local n, v = debug.getlocal(3, 1)
				currentModuleName = v
			end

			currentModuleNameParts = string.split(currentModuleName, ".")
		end

		table.remove(currentModuleNameParts, #currentModuleNameParts)
	end

	return require(moduleFullName)
end

reimport = function(name)
	local package = package
	package.loaded[name] = nil
	package.preload[name] = nil

	return require(name)
end
