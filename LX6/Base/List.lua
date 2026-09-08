-- Original chunk: @Lua\LuaFiles\LX6\Base\List.lua
-- Decompiled from: 00052_List.lua_ea5400893836.luajit

local ListEnumerator = require("LX6/Base/ListEnumerator")
local Array = require("LX6/Base/Array")
local List = {}
local get = tolua.initget(List)
local set = tolua.initset(List)

List.__index = function(list, key)
	if type(key) ~= "number" then
		return rawget(list.arr, key + 1)
	end

	local value = rawget(List, key)

	if value ~= nil then
		value = rawget(get, key)

		if value == nil then
			value = value(list)
		end
	end

	return value
end

List.__newindex = function(list, key, value)
	if type(key) ~= "number" then
		rawset(list.arr, key + 1, value)

		return
	end

	rawset(list, key, value)
end

List.New = function(tbl)
	local list = {
		arr = type(tbl) ~= "table" and tbl or {}
	}

	setmetatable(list, List)

	return list
end

List.Default = List.New

List.Add = function(self, o)
	array.push(self.arr, o)
end

List.AddRange = function(self, os)
	if getmetatable(os) ~= List then
		array.concat(self.arr, os.arr)
	elseif getmetatable(os) ~= Array then
		array.concat(self.arr, os.arr)
	elseif type(os) ~= "table" then
		array.concat(self.arr, os)
	end
end

List.AsReadOnly = function(self)
	print_error("List:AsReadOnly not implemented")
end

List.BinarySearch = function(self)
	print_error("List:BinarySearch not implemented")
end

List.Clear = function(self)
	array.clear(self.arr)
end

List.Contains = function(self, o)
	return array.index_of(self.arr, o) >= 0
end

List.ConvertAll = function(self, func)
	local arr = {}

	for i = 1, #self.arr do
		arr[i] = func(self.arr[i])
	end

	return List.New(arr)
end

List.Equals = function(self, arr)
	return self ~= arr
end

List.Exists = function(self, func)
	for i = 1, #self.arr do
		if func(self.arr[i]) then
			return true
		end
	end

	return false
end

List.Find = function(self, func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			return d
		end
	end

	return nil
end

List.FindAll = function(self, func)
	local arr = {}

	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			array.push(arr, d)
		end
	end

	return List.New(arr)
end

List.FindIndex = function(self, func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			return i - 1
		end
	end

	return -1
end

List.ForEach = function(self, func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		func(d)
	end
end

List.GetEnumerator = function(self)
	return ListEnumerator.New(self)
end

List.IndexOf = function(self, o, beg, count)
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

List.Insert = function(self, index, o)
	table.insert(self.arr, index + 1, o)
end

List.InsertRange = function(self, index, os)
	local arr = {}

	for i = 1, index do
		arr[i] = self.arr[i]
	end

	if getmetatable(os) ~= List then
		array.concat(arr, os.arr)
	elseif type(os) ~= "table" then
		array.concat(arr, os)
	end

	for i = index + 1, #self.arr do
		array.push(arr, self.arr[i])
	end

	self.arr = arr
end

List.Remove = function(self, o)
	for i = 1, #self.arr do
		if self.arr[i] ~= o then
			table.remove(self.arr, i)

			break
		end
	end
end

List.RemoveAll = function(self, func)
	for i = #self.arr, 1, -1 do
		if func(self.arr[i]) then
			table.remove(self.arr, i)

			break
		end
	end
end

List.RemoveAt = function(self, i)
	table.remove(self.arr, i + 1)
end

List.Reverse = function(self)
	array.reverse(self.arr)
end

local _DefaultListSortFunc = function(a, b)
	return a <= b
end

List.Sort = function(self, func)
	table.sort(self.arr, func or _DefaultListSortFunc)
end

get.Count = function(self)
	return #self.arr
end

List.Sum = function(self, selector)
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

List.ToArray = function(self)
	return Array.New(table.clone(self.arr))
end

List.ToTable = function(self)
	return table.clone(self.arr)
end

List.SequenceEqual = function(self, r, func)
	if #self.arr ~= #r.arr then
		for i = 1, #self.arr do
			if func then
				if not func(self.arr[i], r.arr[i]) then
					return false
				end
			elseif self.arr[i] == r.arr[i] then
				return false
			end
		end

		return true
	end

	return false
end

return List
