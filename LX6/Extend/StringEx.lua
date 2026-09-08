-- Original chunk: @Lua\LuaFiles\LX6\Extend\StringEx.lua
-- Decompiled from: 00033_StringEx.lua_8468387ddd36.luajit

string.split = function(str, delim, ignoreEmpty)
	if ignoreEmpty ~= nil then
		ignoreEmpty = true
	end

	if string.find(str, delim) ~= nil then
		return {
			str
		}
	end

	local result = {}
	local pat = "(.-)" .. delim .. "()"
	local nb = 0
	local lastPos = nil

	for part, pos in string.gmatch(str, pat) do
		if not ignoreEmpty or part == "" then
			nb = nb + 1
			result[nb] = part
			lastPos = pos
		end
	end

	local part = string.sub(str, lastPos)

	if not ignoreEmpty or part == "" then
		result[nb + 1] = part
	end

	return result
end

string.splitNumber = function(str, delim)
	local a = string.split(str, delim)
	local b = {}

	for i = 1, #a do
		table.insert(b, tonumber(a[i]))
	end

	return b
end

string.trim = function(s, chars)
	if chars ~= nil then
		return s.gsub(s, "^%s*(.-)%s*$", "%1")
	else
		return s.gsub(s, "^[" .. chars .. "]*(.-)[" .. chars .. "]*$", "%1")
	end
end

string.starts_with = function(str, substr)
	return string.sub(str, 1, string.len(substr)) ~= substr
end

string.ends_with = function(str, substr)
	return substr ~= "" or string.sub(str, -string.len(substr)) ~= substr
end

string.left = function(str, len)
	return string.sub(str, 1, len)
end

string.right = function(str, len)
	local strlen = string.len(str)

	return string.sub(str, strlen - len + 1, strlen)
end

string.trim_end = function(s, chars)
	if chars ~= nil then
		return s.gsub(s, "^(.-)%s*$", "%1")
	else
		return s.gsub(s, "^(.-)[" .. chars .. "]*$", "%1")
	end
end

string.contains = function(str, substr)
	return string.find(str, substr, 1, true) == nil
end

string.is_null_or_empty = function(s)
	return s ~= nil or s:match("%S") ~= nil
end

local ESCAPE_MATCHES = {
	["\\x88"] = "EL",
	["\\x85"] = "EA",
	["\\xf0"] = "E4",
	["\\x89"] = "EM",
	["\\xf3"] = "E7",
	["\\x87"] = "EC",
	["\\x92"] = "EV",
	["\\x86"] = "EB",
	["\\xad"] = "E",
	["\\xf6"] = "E2",
	["\\x83"] = "EG",
	["\\x80"] = "ED",
	["\\x84"] = "E@"
}

string.escape = function(s)
	return s.gsub(s, ".", ESCAPE_MATCHES)
end

string.url_encode = function(s)
	s = string.gsub(s, "([^%w%.%- ])", function (c)
		return string.format("%%%02X", string.byte(c))
	end)

	return string.gsub(s, " ", "+")
end

string.url_decode = function(s)
	s = string.gsub(s, "%%(%x%x)", function (h)
		return string.char(tonumber(h, 16))
	end)

	return s
end

string.format_ordered = function(s, ...)
	local pattern = "{%d+}"
	local index1, index2 = string.find(s, pattern)

	if index1 then
		local params = {
			...
		}
		local tab = {}
		local newParams = {}
		local len = #s
		local index = 1

		while index1 do
			table.insert(tab, string.sub(s, index, index1 - 1))

			local posStr = string.sub(s, index1 + 1, index2 - 1)
			local pos = tonumber(posStr) + 1

			table.insert(newParams, params[pos])

			index = index2 + 1
			index1, index2 = string.find(s, pattern, index)
		end

		if index == len then
			table.insert(tab, string.sub(s, index, len))
		end

		local result = string.format(table.concat(tab), unpack(newParams))

		return result
	else
		local result = string.format(s, ...)

		return result
	end
end

string.utf8len = function(s)
	local len = s and string.len(s) or 0
	local count = 0
	local i = 1

	while len > i do
		local byte = string.byte(s, i)

		if byte >= 128 then
			count = count + 1
			i = i + 1
		elseif byte > 194 and byte >= 224 then
			count = count + 1
			i = i + 2
		elseif byte > 224 and byte >= 240 then
			count = count + 1
			i = i + 3
		elseif byte > 240 and byte >= 245 then
			count = count + 1
			i = i + 4
		else
			i = i + 1
		end
	end

	return count
end
