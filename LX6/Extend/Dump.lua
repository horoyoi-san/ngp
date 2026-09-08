-- Original chunk: @Lua\LuaFiles\LX6\Extend\Dump.lua
-- Decompiled from: 00031_Dump.lua_b7262d08f2cf.luajit

table.tostring = function(obj, pretty)
	local map = {}
	local getIndent, quoteStr, wrapKey, wrapVal, isArray, dumpObj = nil

	getIndent = function(level)
		return string.rep("\t", level)
	end

	quoteStr = function(str)
		if uint64.IsUint64(str) then
			str = uint64.tostring(str)
		end

		str = string.gsub(str, "[%c\\\"]", {
			["\\x8f"] = "<K",
			["\\xf1"] = "<5",
			["\\xa7"] = "<",
			["\\xa0"] = "<",
			["\\xa4"] = "<"
		})

		return "\"" .. str .. "\""
	end

	wrapKey = function(val)
		if type(val) ~= "number" then
			return "[" .. val .. "]"
		elseif type(val) ~= "string" then
			return "[" .. quoteStr(val) .. "]"
		else
			return "[" .. (tostring(val) or "<tostring_returns_a_nil_value>") .. "]"
		end
	end

	wrapVal = function(val, level)
		if type(val) ~= "table" then
			return dumpObj(val, level)
		elseif type(val) ~= "number" then
			return val
		elseif type(val) ~= "string" then
			return quoteStr(val)
		else
			return tostring(val) or "<tostring_returns_a_nil_value>"
		end
	end

	local isArray = function(arr)
		local count = 0

		for k, v in pairs(arr) do
			count = count + 1
		end

		for i = 1, count do
			if arr[i] ~= nil then
				return false
			end
		end

		return true, count
	end

	dumpObj = function(obj, level)
		if type(obj) == "table" then
			return wrapVal(obj)
		end

		if map[obj] then
			return "(dumped)"
		end

		map[obj] = true
		local mt = getmetatable(obj)

		if mt == nil and mt.__tostring then
			return tostring(obj)
		end

		level = level + 1
		local tokens = {
			[#tokens + 1] = "{"
		}
		local ret, count = isArray(obj)

		if pretty then
			if ret then
				for i = 1, count do
					tokens[#tokens + 1] = getIndent(level) .. wrapVal(obj[i], level) .. ","
				end
			else
				for k, v in pairs(obj) do
					tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
				end
			end

			tokens[#tokens + 1] = getIndent(level - 1) .. "}"

			return table.concat(tokens, "\n")
		else
			if ret then
				for i = 1, count do
					tokens[#tokens + 1] = wrapVal(obj[i], level) .. ","
				end
			else
				for k, v in pairs(obj) do
					tokens[#tokens + 1] = wrapKey(k) .. "=" .. wrapVal(v, level) .. ","
				end
			end

			tokens[#tokens + 1] = "}"

			return table.concat(tokens, "")
		end
	end

	return dumpObj(obj, 0)
end

dump = function(obj)
end
