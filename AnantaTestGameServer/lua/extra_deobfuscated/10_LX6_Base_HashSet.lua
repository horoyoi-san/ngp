local HashSetEnumerator = require("LX6/Base/HashSetEnumerator")
local HashSet = {}
local get = tolua.initget(HashSet)
local set = tolua.initset(HashSet)

function HashSet.__index(list, key)
	if type(key) == "number" then
		return rawget(list.arr, key + 1)
	end

	local value = rawget(HashSet, key)

	if value == nil then
		value = rawget(get, key)

		if value ~= nil then
			value = value(list)
		end
	end

	return value
end

function HashSet.__newindex(list, key, value)
	if type(key) == "number" then
		rawset(list.arr, key + 1, value)

		return
	end

	rawset(list, key, value)
end

function HashSet.New(tbl)
	local hashset = {
		data = tbl or {}
	}

	setmetatable(hashset, HashSet)

	return hashset
end

function HashSet:Add(o)
	self.data[o] = true
end

function HashSet:Clear()
	self.data = {}
end

function HashSet:Contains(o)
	return self.data[o] or false
end

function HashSet:Equals(arr)
	return self == arr
end

function HashSet:GetEnumerator()
	return HashSetEnumerator.New(self)
end

function HashSet:Remove(o)
	self.data[o] = nil
end

function HashSet:RemoveWhere(func)
	for key, _ in pairs(self.data) do
		if func(key) then
			self.data[key] = nil
		end
	end
end

function get:Count()
	local count = 0

	for key, _ in pairs(self.data) do
		count = count + 1
	end

	return count
end

return HashSet
