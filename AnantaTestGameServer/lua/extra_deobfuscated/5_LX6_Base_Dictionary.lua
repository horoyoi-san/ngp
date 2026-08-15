local DictionaryEnumerator = require("LX6/Base/DictionaryEnumerator")
local Array = require("LX6/Base/Array")
local Dictionary = {}
local get = tolua.initget(Dictionary)
local set = tolua.initset(Dictionary)

function Dictionary.__index(dic, key)
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

function Dictionary.__newindex(dic, key, value)
	rawset(dic.dic, key, value)
end

local function _InnerNew(tbl)
	if not tbl then
		return {}
	end

	local len = #tbl
	local count = table.count(tbl)

	if len == count then
		local result = {}

		for _, pair in ipairs(tbl) do
			result[pair[1]] = pair[2]
		end

		return result
	else
		return table.clone(tbl)
	end
end

function Dictionary.New(tbl)
	local list = {
		dic = _InnerNew(tbl)
	}

	setmetatable(list, Dictionary)

	return list
end

function Dictionary:Add(k, v)
	self.dic[k] = v
end

function Dictionary:Clear()
	table.clear(self.dic)
end

function Dictionary:ContainsKey(k)
	return self.dic[k] ~= nil
end

function Dictionary:ContainsValue(v)
	for _, vv in pairs(self.dic) do
		if vv == v then
			return true
		end
	end

	return false
end

function Dictionary:GetEnumerator()
	return DictionaryEnumerator.New(self)
end

function Dictionary:Equals(dic)
	return self == dic
end

function Dictionary:Remove(k)
	self.dic[k] = nil
end

function Dictionary:TryGetValue(k, v)
	return
end

function get:Count()
	return table.count(self.dic)
end

function get:Values()
	return Array.New(table.to_array(self.dic))
end

return Dictionary
