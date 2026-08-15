local ListEnumerator = require("LX6/Base/ListEnumerator")
local Array = require("LX6/Base/Array")
local List = {}
local get = tolua.initget(List)
local set = tolua.initset(List)

function List.__index(list, key)
	if type(key) == "number" then
		return rawget(list.arr, key + 1)
	end

	local value = rawget(List, key)

	if value == nil then
		value = rawget(get, key)

		if value ~= nil then
			value = value(list)
		end
	end

	return value
end

function List.__newindex(list, key, value)
	if type(key) == "number" then
		rawset(list.arr, key + 1, value)

		return
	end

	rawset(list, key, value)
end

function List.New(tbl)
	local list = {
		arr = type(tbl) == "table" and tbl or {}
	}

	setmetatable(list, List)

	return list
end

List.Default = List.New

function List:Add(o)
	array.push(self.arr, o)
end

function List:AddRange(os)
	if getmetatable(os) == List then
		array.concat(self.arr, os.arr)
	elseif getmetatable(os) == Array then
		array.concat(self.arr, os.arr)
	elseif type(os) == "table" then
		array.concat(self.arr, os)
	end
end

function List:AsReadOnly()
	print_error("List:AsReadOnly not implemented")
end

function List:BinarySearch()
	print_error("List:BinarySearch not implemented")
end

function List:Clear()
	array.clear(self.arr)
end

function List:Contains(o)
	return array.index_of(self.arr, o) > 0
end

function List:ConvertAll(func)
	local arr = {}

	for i = 1, #self.arr do
		arr[i] = func(self.arr[i])
	end

	return List.New(arr)
end

function List:Equals(arr)
	return self == arr
end

function List:Exists(func)
	for i = 1, #self.arr do
		if func(self.arr[i]) then
			return true
		end
	end

	return false
end

function List:Find(func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			return d
		end
	end

	return nil
end

function List:FindAll(func)
	local arr = {}

	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			array.push(arr, d)
		end
	end

	return List.New(arr)
end

function List:FindIndex(func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		if func(d) then
			return i - 1
		end
	end

	return -1
end

function List:ForEach(func)
	for i = 1, #self.arr do
		local d = self.arr[i]

		func(d)
	end
end

function List:GetEnumerator()
	return ListEnumerator.New(self)
end

function List:IndexOf(o, beg, count)
	beg = beg and beg + 1 or 1
	count = count or #self.arr - beg

	for i = beg, beg + count - 1 do
		local d = self.arr[i]

		if d == o then
			return i - 1
		end
	end

	return -1
end

function List:Insert(index, o)
	table.insert(self.arr, index + 1, o)
end

function List:InsertRange(index, os)
	local arr = {}

	for i = 1, index do
		arr[i] = self.arr[i]
	end

	if getmetatable(os) == List then
		array.concat(arr, os.arr)
	elseif type(os) == "table" then
		array.concat(arr, os)
	end

	for i = index + 1, #self.arr do
		array.push(arr, self.arr[i])
	end

	self.arr = arr
end

function List:Remove(o)
	for i = 1, #self.arr do
		if self.arr[i] == o then
			table.remove(self.arr, i)

			break
		end
	end
end

function List:RemoveAll(func)
	for i = #self.arr, 1, -1 do
		if func(self.arr[i]) then
			table.remove(self.arr, i)

			break
		end
	end
end

function List:RemoveAt(i)
	table.remove(self.arr, i + 1)
end

function List:Reverse()
	array.reverse(self.arr)
end

local function _DefaultListSortFunc(a, b)
	return a < b
end

function List:Sort(func)
	table.sort(self.arr, func or _DefaultListSortFunc)
end

function get:Count()
	return #self.arr
end

function List:Sum(selector)
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

function List:ToArray()
	return Array.New(table.clone(self.arr))
end

function List:ToTable()
	return table.clone(self.arr)
end

function List:SequenceEqual(r, func)
	if #self.arr == #r.arr then
		for i = 1, #self.arr do
			if func then
				if not func(self.arr[i], r.arr[i]) then
					return false
				end
			elseif self.arr[i] ~= r.arr[i] then
				return false
			end
		end

		return true
	end

	return false
end

return List
