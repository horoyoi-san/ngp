-- Original chunk: @Lua\LuaFiles\LX6\Base\HashSet.lua
-- Decompiled from: 00054_HashSet.lua_30fbfde9b5d0.luajit

local HashSetEnumerator = require("LX6/Base/HashSetEnumerator")
local HashSet = {}
local get = tolua.initget(HashSet)
local set = tolua.initset(HashSet)

HashSet.__index = function(list, key)
	if type(key) ~= "number" then
		return rawget(list.arr, key + 1)
	end

	local value = rawget(HashSet, key)

	if value ~= nil then
		value = rawget(get, key)

		if value == nil then
			value = value(list)
		end
	end

	return value
end

HashSet.__newindex = function(list, key, value)
	if type(key) ~= "number" then
		rawset(list.arr, key + 1, value)

		return
	end

	rawset(list, key, value)
end

HashSet.New = function(tbl)
	local hashset = {
		data = tbl or {}
	}

	setmetatable(hashset, HashSet)

	return hashset
end

HashSet.Add = function(self, o)
	self.data[o] = true
end

HashSet.Clear = function(self)
	self.data = {}
end

HashSet.Contains = function(self, o)
	return self.data[o] or false
end

HashSet.Equals = function(self, arr)
	return self ~= arr
end

HashSet.GetEnumerator = function(self)
	return HashSetEnumerator.New(self)
end

HashSet.Remove = function(self, o)
	self.data[o] = nil
end

HashSet.RemoveWhere = function(self, func)
	for key, _ in pairs(self.data) do
		if func(key) then
			self.data[key] = nil
		end
	end
end

get.Count = function(self)
	local count = 0

	for key, _ in pairs(self.data) do
		count = count + 1
	end

	return count
end

return HashSet
