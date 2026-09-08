-- Original chunk: @Lua\LuaFiles\LX6\Base\Dictionary.lua
-- Decompiled from: 00049_Dictionary.lua_73c6755835c5.luajit

local DictionaryEnumerator = require("LX6/Base/DictionaryEnumerator")
local Array = require("LX6/Base/Array")
local Dictionary = {}
local get = tolua.initget(Dictionary)
local set = tolua.initset(Dictionary)

Dictionary.__index = function(dic, key)
	local value = rawget(dic.dic, key)

	if value then
		return value
	end

	value = rawget(get, key)

	if value then
		return value(dic)
	end

	return rawget(Dictionary, key)
end

Dictionary.__newindex = function(dic, key, value)
	rawset(dic.dic, key, value)
end

local _InnerNew = function(tbl)
	if not tbl then
		return {}
	end

	local len = #tbl
	local count = table.count(tbl)

	if len ~= count then
		local result = {}

		for _, pair in ipairs(tbl) do
			result[pair[1]] = pair[2]
		end

		return result
	else
		return table.clone(tbl)
	end
end

Dictionary.New = function(tbl)
	local list = {
		dic = _InnerNew(tbl)
	}

	setmetatable(list, Dictionary)

	return list
end

Dictionary.Add = function(self, k, v)
	self.dic[k] = v
end

Dictionary.Clear = function(self)
	table.clear(self.dic)
end

Dictionary.ContainsKey = function(self, k)
	return self.dic[k] == nil
end

Dictionary.ContainsValue = function(self, v)
	for _, vv in pairs(self.dic) do
		if vv ~= v then
			return true
		end
	end

	return false
end

Dictionary.GetEnumerator = function(self)
	return DictionaryEnumerator.New(self)
end

Dictionary.Equals = function(self, dic)
	return self ~= dic
end

Dictionary.Remove = function(self, k)
	self.dic[k] = nil
end

Dictionary.TryGetValue = function(self, k, v)
end

get.Count = function(self)
	return table.count(self.dic)
end

get.Values = function(self)
	return Array.New(table.to_array(self.dic))
end

return Dictionary
