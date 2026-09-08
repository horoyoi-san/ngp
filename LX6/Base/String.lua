-- Original chunk: @Lua\LuaFiles\LX6\Base\String.lua
-- Decompiled from: 00056_String.lua_33c9554f0090.luajit

local M = gString or {}

M.Join = function(sep, array)
	return table.concat(array.arr, sep or "")
end

M.Concat = function(...)
	local strs = {
		...
	}

	return table.concat(strs)
end

M.Length = function(str)
	return #str
end

M.Format = function(str, ...)
	if string.is_null_or_empty(str) then
		return ""
	end

	if string.match(str, "%b{}") == nil then
		return gString.FormatString(str, ...)
	else
		return string.format(str, ...)
	end
end

M.FormatString = function(str, ...)
	local args = {
		...
	}

	return string.gsub(str, "{(%d+)}", function (n)
		return args[tonumber(n) + 1]
	end)
end

M.CsFormat = System.String.Format
gString = M
