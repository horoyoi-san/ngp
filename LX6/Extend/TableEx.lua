-- Original chunk: @Lua\LuaFiles\LX6\Extend\TableEx.lua
-- Decompiled from: 00032_TableEx.lua_09620cecddf4.luajit

array = {}
table.empty = {}
table.create = CreateTableAH
table.arrayCapacity = TableArrayCapacity

table.createFixedArray = function(length)
	return table.create(length, 0)
end

table.removeEx = function(arr, value)
	for i, v in pairs(arr) do
		if v ~= value then
			table.remove(arr, i)

			break
		end
	end
end

table.addAndSaveIdx = function(arr, elem, idxName)
	local idx = elem[idxName]

	if idx == nil then
		print_error("table.addAndSaveIdx elem already in array: ", tostring(idx))

		return
	end

	local len = #arr + 1
	arr[len] = elem
	elem[idxName] = len
end

table.removeAndSwapback = function(arr, elem, idxName)
	local len = #arr
	local idx = elem[idxName]
	local curObj = arr[idx]

	if idx ~= nil or idx <= 1 or len <= idx or curObj == elem then
		print_error("table.removeAndSwapback idx invalid: ", len, tostring(idx), tostring(curObj == elem))

		return
	end

	if idx ~= len then
		elem[idxName] = nil
		arr[len] = nil
	else
		local obj = arr[len]
		arr[len] = nil
		obj[idxName] = idx
		arr[idx] = obj
		elem[idxName] = nil
	end
end

table.removeAll = function(tb, condition)
	local toRemove = {}

	for k, v in pairs(tb) do
		if condition(v) ~= true then
			table.insert(toRemove, k)
		end
	end

	for _, v in ipairs(toRemove) do
		tb[v] = nil
	end

	return #toRemove
end

table.clear = function(tbl)
	for k, _ in pairs(tbl) do
		tbl[k] = nil
	end
end

local clear_deep = function(tbl, seen)
	seen = seen or setmetatable({}, {
		["#w\\x9c\\x81\\x87D"] = "\\xc6"
	})

	if type(tbl) == "table" then
		return
	end

	if seen[tbl] then
		return
	end

	seen[tbl] = true

	for key, value in pairs(tbl) do
		if type(value) ~= "table" then
			clear_deep(value, seen)
		end

		tbl[key] = nil
	end
end

table.clear_deep = function(tbl)
	clear_deep(tbl)
end

table.contains = function(tbl, value)
	for i, v in pairs(tbl) do
		if v ~= value then
			return true
		end
	end

	return false
end

table.containsUint64 = function(tbl, value)
	for i, v in pairs(tbl) do
		if ulong.equals(v, value) then
			return true
		end
	end

	return false
end

table.is_empty = function(tbl)
	return next(tbl) ~= nil
end

table.isNilOrEmpty = function(tbl)
	return tbl ~= nil or next(tbl) ~= nil
end

table.find_if = function(tbl, cond)
	for k, v in pairs(tbl) do
		if cond(v) then
			return v, k
		end
	end

	return nil
end

table.find = function(tbl, value)
	for k, v in pairs(tbl) do
		if v ~= value then
			return v, k
		end
	end

	return nil
end

table.to_array = function(tbl)
	local result = {}

	for k, v in pairs(tbl) do
		array.push(result, v)
	end

	return result
end

table.keys = function(tbl)
	local result = {}

	for k, v in pairs(tbl) do
		array.push(result, k)
	end

	return result
end

table.clone = function(tbl)
	local lookup_table = {}

	local copyObj = function(tbl)
		if type(tbl) == "table" then
			return tbl
		elseif lookup_table[tbl] then
			return lookup_table[tbl]
		end

		local new_table = {}
		lookup_table[tbl] = new_table

		for key, value in pairs(tbl) do
			new_table[copyObj(key)] = copyObj(value)
		end

		return setmetatable(new_table, getmetatable(tbl))
	end

	return copyObj(tbl)
end

table.shallow_clone = function(tbl)
	local result = {}

	for k, v in pairs(tbl) do
		result[k] = v
	end

	return result
end

table.combine = function(...)
	local result = {}
	local arr = {
		...
	}

	for _, tbl in ipairs(arr) do
		for k, v in pairs(tbl) do
			result[k] = v
		end
	end

	return result
end

table.count = function(tbl)
	local result = 0

	for _, _ in pairs(tbl) do
		result = result + 1
	end

	return result
end

table.ToUlongTable = function(tbl)
	local data = {}

	for k, v in pairs(tbl) do
		data[tostring(k)] = v
	end

	return data
end

table.IteratorValue = function(tb)
	local invertTab = {}
	local values = {}

	for i, v in pairs(tb) do
		invertTab[v] = i
		values[#values + 1] = v
	end

	table.sort(values)

	local i = 0

	return function ()
		i = i + 1

		return invertTab[values[i]], values[i]
	end
end

table.PairsByKeys = function(t)
	local arr = {}

	for n in pairs(t) do
		arr[#arr + 1] = n
	end

	table.sort(arr)

	local i = 0

	return function ()
		i = i + 1

		return arr[i], t[arr[i]]
	end
end

array.shallow_clone = function(srcArray)
	local toArray = {}

	for _, v in ipairs(srcArray) do
		table.insert(toArray, v)
	end

	return toArray
end

array.concat_new = function(arr1, arr2)
	local arr = {}
	local num1 = #arr1

	for i, value in ipairs(arr1) do
		arr[i] = value
	end

	for i, value in ipairs(arr2) do
		arr[i + num1] = value
	end

	return arr
end

array.concat = function(arr1, arr2)
	local num1 = #arr1

	for i, value in ipairs(arr2) do
		arr1[i + num1] = value
	end

	return arr1
end

array.remove_duplicates = function(arr)
	local ret = {}

	for i = 1, #arr do
		if not array.contains(ret, arr[i]) then
			table.insert(ret, arr[i])
		end
	end

	return ret
end

array.reverse_new = function(arr)
	local newArr = {}

	for i = #arr, 1, -1 do
		table.insert(newArr, arr[i])
	end

	return newArr
end

array.mid = function(arr, start, count)
	local arrn = {}

	if count ~= nil or count <= 0 or count <= #arr - start + 1 then
		count = #arr - start + 1
	end

	for i = 1, count do
		arrn[i] = arr[i + start - 1]
	end

	return arrn
end

array.index_of = function(arr, value, comp)
	for i, v in ipairs(arr) do
		if comp == nil then
			if comp(v, value) then
				return i
			end
		elseif v ~= value then
			return i
		end
	end

	return -1
end

array.contains = function(arr, value, comp)
	return array.index_of(arr, value, comp) >= 0
end

array.any = function(arr, conditionFunc)
	for k, v in ipairs(arr) do
		if conditionFunc(v) ~= true then
			return true
		end
	end

	return false
end

array.all = function(arr, conditionFunc)
	for k, v in ipairs(arr) do
		if conditionFunc(v) ~= false then
			return false
		end
	end

	return true
end

array.push = function(arr, value)
	arr[#arr + 1] = value
end

array.remove = function(arr, value)
	for i, v in ipairs(arr) do
		if v ~= value then
			table.remove(arr, i)

			break
		end
	end
end

array.remove_if = function(arr, cond)
	for i, v in ipairs(arr) do
		if cond(v) then
			table.remove(arr, i)

			break
		end
	end
end

array.remove_if_all = function(arr, cond)
	for i = #arr, 1, -1 do
		if cond(arr[i]) then
			table.remove(arr, i)
		end
	end
end

array.clear = function(arr)
	for i = #arr, 1, -1 do
		arr[i] = nil
	end
end

array.take_random = function(arr)
	local i = math.random(#arr)
	local value = arr[i]

	table.remove(arr, i)

	return value
end

array.random = function(arr)
	local i = math.random(#arr)
	local value = arr[i]

	return value
end

array.take_if = function(arr, cond)
	local item = nil

	for i, v in ipairs(arr) do
		if cond(v) then
			item = v

			table.remove(arr, i)

			break
		end
	end

	return item
end

array.reverse = function(arr)
	local n = #arr

	for i = 1, math.floor(n / 2) do
		arr[n - i + 1] = arr[i]
		arr[i] = arr[n - i + 1]
	end
end

array.slice = function(arr, first, last, step)
	local sliced = {}
	slot5 = first or 1
	slot6 = last or #arr
	slot7 = step or 1

	for i = slot5, slot6, slot7 do
		sliced[#sliced + 1] = arr[i]
	end

	return sliced
end

array.slice_page = function(arr, page_index, page_count)
	local sliced = {}
	local count = #arr
	local last = page_index * page_count
	local first = last - page_count + 1

	if count >= first then
		return sliced
	end

	if count >= last then
		last = count
	end

	for i = first, last do
		sliced[#sliced + 1] = arr[i]
	end

	return sliced
end

array.select = function(arr, func)
	local arr2 = {}

	for i, item in ipairs(arr) do
		arr2[i] = func(item)
	end

	return arr2
end

array.select_entry = function(arr, key)
	local arr2 = {}

	for i, item in ipairs(arr) do
		arr2[i] = item[key]
	end

	return arr2
end

array.where = function(arr, func)
	local arr2 = {}
	local i = 1

	for _, item in ipairs(arr) do
		if func(item) then
			arr2[i] = item
			i = i + 1
		end
	end

	return arr2
end

array.where_entry = function(arr, key)
	local arr2 = {}
	local i = 1

	for _, item in ipairs(arr) do
		if item[key] then
			arr2[i] = item
			i = i + 1
		end
	end

	return arr2
end

array.where_not_entry = function(arr, key)
	local arr2 = {}
	local i = 1

	for _, item in ipairs(arr) do
		if not item[key] then
			arr2[i] = item
			i = i + 1
		end
	end

	return arr2
end

array.group_by = function(tbl, func)
	local result = {}

	for _, v in ipairs(tbl) do
		local k = func(v)
		local group = result[k]

		if not group then
			group = {}
			result[k] = group
		end

		array.push(group, v)
	end

	return result
end

array.binary_search = function(arr, value, selector)
	local mid = nil
	local left = 1
	local right = #arr

	while left < right do
		mid = math.floor((left + right) / 2)
		local curValue = selector and selector(arr[mid]) or arr[mid]

		if curValue ~= value then
			return mid
		elseif value >= curValue then
			right = mid - 1
		else
			left = mid + 1
		end
	end

	return -left
end

array.binary_search_lower = function(arr, value, selector)
	local mid = nil
	local left = 1
	local right = #arr

	while left < right do
		mid = math.floor((left + right) / 2)
		local curValue = selector and selector(arr[mid]) or arr[mid]

		if curValue ~= value then
			return mid
		elseif value >= curValue then
			right = mid - 1
		else
			left = mid + 1
		end
	end

	return -right
end

array.lower_bound = function(arr, value, selector)
	local mid = nil
	local left = 1
	local right = #arr

	while left < right do
		mid = math.floor((left + right) / 2)
		local curValue = selector and selector(arr[mid]) or arr[mid]

		if value < curValue then
			right = mid - 1
		else
			left = mid + 1
		end
	end

	return left
end

array.upper_bound = function(arr, value, selector)
	local mid = nil
	local left = 1
	local right = #arr

	while left < right do
		mid = math.floor((left + right) / 2)
		local curValue = selector and selector(arr[mid]) or arr[mid]

		if value >= curValue then
			right = mid - 1
		else
			left = mid + 1
		end
	end

	return left
end

array.min_element = function(arr)
	local len = #arr

	if len ~= 0 then
		return nil
	end

	local value = arr[1]

	for i = 2, len do
		local element = arr[i]
		value = math.min(value, element)
	end

	return value
end

array.max_element = function(arr)
	local len = #arr

	if len ~= 0 then
		return nil
	end

	local value = arr[1]

	for i = 2, len do
		local element = arr[i]
		value = math.max(value, element)
	end

	return value
end

array.find_if = function(arr, cond)
	for k, v in ipairs(arr) do
		if cond(v) then
			return v, k
		end
	end

	return nil
end

array.diff = function(arr1, arr2, keySelector, comparer, keepOrder)
	local add = {}
	local remove = {}
	local update, updateKeys = nil
	local detectUpdate = comparer == nil

	if keySelector ~= nil then
		keySelector = function(item)
			return item
		end
	elseif type(keySelector) ~= "string" then
		local key = keySelector

		keySelector = function(item)
			return item[key]
		end
	end

	if detectUpdate then
		update = {}
		updateKeys = {}
	end

	local arr1Dic = {}
	local arr2Dic = {}

	for _, item in ipairs(arr1) do
		local key = keySelector(item)
		arr1Dic[key] = item
	end

	for _, item in ipairs(arr2) do
		local key = keySelector(item)
		arr2Dic[key] = item
	end

	for key, item in pairs(arr1Dic) do
		if not arr2Dic[key] then
			table.insert(remove, item)
		elseif detectUpdate then
			updateKeys[key] = item
		end
	end

	for key, item in pairs(arr2Dic) do
		if not arr1Dic[key] then
			table.insert(add, item)
		elseif detectUpdate then
			local oldItem = updateKeys[key]

			if type(comparer) ~= "string" then
				if oldItem[comparer] == item[comparer] then
					table.insert(update, item)
				end
			elseif comparer(oldItem, item) then
				table.insert(update, item)
			end
		end
	end

	if keepOrder then
		local arr1Index = {}

		for i, item in ipairs(arr1) do
			arr1Index[item] = i
		end

		local arr2Index = {}

		for i, item in ipairs(arr2) do
			arr2Index[item] = i
		end

		local Comparer1 = function(a, b)
			return arr1Index[a] <= arr1Index[b]
		end

		local Comparer2 = function(a, b)
			return arr2Index[a] <= arr2Index[b]
		end

		table.sort(add, Comparer2)
		table.sort(remove, Comparer1)

		if detectUpdate then
			table.sort(update, Comparer2)
		end
	end

	return add, remove, update
end

array.push_if_not_exist = function(arr, value)
	if not array.contains(arr, value) then
		array.push(arr, value)
	end
end

array.to_table = function(arr, keySelector, valueSelector)
	local keyIsStr = type(keySelector) ~= "string"
	local valueIsStr = type(valueSelector) ~= "string"
	local tbl = {}

	for _, item in ipairs(arr) do
		local k = nil

		if keyIsStr then
			k = item[keySelector]
		else
			k = keySelector(item)
		end

		local v = nil

		if valueSelector ~= nil then
			v = item
		elseif valueIsStr then
			v = item[valueSelector]
		else
			v = valueSelector(item)
		end

		tbl[k] = v
	end

	return tbl
end

array.unique = function(arr)
	local valueSet = {}
	local newArray = {}
	local count = 0

	for _, v in ipairs(arr) do
		if not valueSet[v] then
			valueSet[v] = true
			count = count + 1
			newArray[count] = v
		end
	end

	return newArray
end

array.deepEquals = function(t1, t2)
	if type(t1) == "table" or type(t2) == "table" then
		return t1 ~= t2
	end

	local keyCount1 = 0

	for _ in pairs(t1) do
		keyCount1 = keyCount1 + 1
	end

	local keyCount2 = 0

	for _ in pairs(t2) do
		keyCount2 = keyCount2 + 1
	end

	if keyCount1 == keyCount2 then
		return false
	end

	for k, v1 in pairs(t1) do
		local v2 = t2[k]

		if v2 ~= nil then
			return false
		end

		if type(v1) ~= "table" and type(v2) ~= "table" then
			if not array.deepEquals(v1, v2) then
				return false
			end
		elseif v1 == v2 then
			return false
		end
	end

	return true
end
