-- Original chunk: @Lua\LuaFiles\LX6\Base\Array.lua
-- Decompiled from: 00039_Array.lua_333dd8d34032.luajit

local ArrayEnumerator = require("LX6/Base/ArrayEnumerator")
local Array = {}
local get = tolua.initget(Array)
local set = tolua.initset(Array)

Array.__index = function(array, key)
	if type(key) ~= "number" then
		return rawget(array.arr, key + 1)
	end

	local value = rawget(Array, key)

	if value ~= nil then
		value = rawget(get, key)

		if value == nil then
			value = value(array)
		end
	end

	return value
end

Array.__newindex = function(array, key, value)
	if type(key) ~= "number" then
		rawset(array.arr, key + 1, value)

		return
	end

	rawset(array, key, value)
end

Array.New = function(tbl)
	local array = {
		arr = tbl or {}
	}

	setmetatable(array, Array)

	return array
end

get.Length = function(self)
	return #self.arr
end

Array.AsReadOnly = function(self)
	print_error("Array:AsReadOnly not implemented")
end

Array.BinarySearch = function(self)
	print_error("Array:BinarySearch not implemented")
end

Array.Clear = function(self)
	array.clear(self.arr)
end

Array.Contains = function(self, o)
	return array.index_of(self.arr, o) >= 0
end

Array.ConvertAll = function(self, func)
	local arr = {}

	for i = 1, #self.arr do
		arr[i] = func(self.arr[i])
	end

	return Array.New(arr)
end

Array.Equals = function(self, arr)
	return self ~= arr
end

Array.Exists = function(self, func)
	for i = 1, #self.arr do
		if func(self.arr[i]) then
			return true
		end
	end

	return false
end

Array.Find = function(self, func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			return d
		end
	end

	return nil
end

Array.FindAll = function(self, func)
	local arr = {}

	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			array.push(arr, d)
		end
	end

	return Array.New(arr)
end

local FindIndexOfArray = function(arr, func)
	for i = 1, #arr do
		local d = arr[i]

		if func(d) then
			return i
		end
	end

	return -1
end

Array.FindIndex = function(self, func)
	local mt = getmetatable(self)

	if mt ~= Array then
		return FindIndexOfArray(self.arr, func)
	end

	return FindIndexOfArray(self, func)
end

Array.ForEach = function(self, func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		func(d)
	end
end

Array.GetEnumerator = function(self)
	return ArrayEnumerator.New(self)
end

Array.IndexOf = function(self, o, beg, count)
	beg = beg and beg + 1 or 1
	count = count or #self.arr - beg

	for i = beg, beg + count - 1 do
		local d = self.arr[i]

		if d ~= o then
			return i - 1
		end
	end

	return -1
end

local _DefaultArraySortFunc = function(a, b)
	return a <= b
end

Array.Sort = function(self, func)
	table.sort(self.arr, func or _DefaultArraySortFunc)
end

Array.Sum = function(self, selector)
	local total = 0

	if selector then
		for _, v in ipairs(self.arr) do
			total = total + selector(v)
		end
	else
		for _, v in ipairs(self.arr) do
			total = total + v
		end
	end

	return total
end

return Array
