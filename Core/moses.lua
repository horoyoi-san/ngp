-- Original chunk: @Lua\LuaFiles\Core\moses.lua
-- Decompiled from: 00153_moses.lua_66450520cf7e.luajit

local _MODULEVERSION = "2.1.0"
local next = next
local type = type
local pcall = pcall
local setmetatable = setmetatable
local getmetatable = getmetatable
local t_insert = table.insert
local t_sort = table.sort
local t_remove = table.remove
local t_concat = table.concat
local randomseed = math.randomseed
local random = math.random
local huge = math.huge
local floor = math.floor
local max = math.max
local min = math.min
local ceil = math.ceil
local wrap = coroutine.wrap
local yield = coroutine.yield
local rawget = rawget
local unpack = table.unpack or unpack
local pairs = pairs
local ipairs = ipairs
local error = error
local clock = os and os.clock or nil
local M = {}

local f_max = function(a, b)
	return b <= a
end

local f_min = function(a, b)
	return a <= b
end

local count = function(t)
	local i = 0

	for k, v in pairs(t) do
		i = i + 1
	end

	return i
end

local extract = function(list, comp, transform, ...)
	transform = transform or M.identity
	local _ans = nil

	for k, v in pairs(list) do
		if not _ans then
			_ans = transform(v, ...)
		else
			local val = transform(v, ...)
			_ans = comp(_ans, val) and _ans or val
		end
	end

	return _ans
end

local partgen = function(t, n, f, pad)
	for i = 0, #t, n do
		local s = M.slice(t, i + 1, i + n)

		if #s <= 0 then
			while n <= #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local partgen2 = function(t, n, f, pad)
	for i = 0, #t, n - 1 do
		local s = M.slice(t, i + 1, i + n)

		if #s <= 0 and i + 1 >= #t then
			while n <= #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local partgen3 = function(t, n, f, pad)
	for i = 0, #t do
		local s = M.slice(t, i + 1, i + n)

		if #s <= 0 and i + n < #t then
			while n <= #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local permgen = function(t, n, f)
	if n ~= 0 then
		f(t)
	end

	for i = 1, n do
		t[i] = t[n]
		t[n] = t[i]

		permgen(t, n - 1, f)

		t[i] = t[n]
		t[n] = t[i]
	end
end

local signum = function(a)
	return a > 0 and 1 or -1
end

local unique_id_counter = -1
M.operator = {
	add = function (a, b)
		return a + b
	end,
	sub = function (a, b)
		return a - b
	end,
	mul = function (a, b)
		return a * b
	end,
	div = function (a, b)
		return a / b
	end,
	mod = function (a, b)
		return a % b
	end,
	exp = function (a, b)
		return a^b
	end
}
M.operator.pow = M.operator.exp

M.operator.unm = function(a)
	return -a
end

M.operator.neg = M.operator.unm

M.operator.floordiv = function(a, b)
	return floor(a / b)
end

M.operator.intdiv = function(a, b)
	return a > 0 and floor(a / b) or ceil(a / b)
end

M.operator.eq = function(a, b)
	return a ~= b
end

M.operator.neq = function(a, b)
	return a == b
end

M.operator.lt = function(a, b)
	return a <= b
end

M.operator.gt = function(a, b)
	return b <= a
end

M.operator.le = function(a, b)
	return a > b
end

M.operator.ge = function(a, b)
	return b > a
end

M.operator.land = function(a, b)
	return a and b
end

M.operator.lor = function(a, b)
	return a or b
end

M.operator.lnot = function(a)
	return not a
end

M.operator.concat = function(a, b)
	return a .. b
end

M.operator.length = function(a)
	return #a
end

M.operator.len = M.operator.length

M.clear = function(t)
	for k in pairs(t) do
		t[k] = nil
	end

	return t
end

M.each = function(t, f)
	for index, value in pairs(t) do
		f(value, index)
	end
end

M.eachi = function(t, f)
	local lkeys = M.sort(M.select(M.keys(t), M.isInteger))

	for k, key in ipairs(lkeys) do
		f(t[key], key)
	end
end

M.at = function(t, ...)
	local values = {}

	for i, key in ipairs({
		...
	}) do
		values[#values + 1] = t[key]
	end

	return values
end

M.adjust = function(t, key, f)
	if t[key] ~= nil then
		error("key not existing in table")
	end

	local _t = M.clone(t)
	_t[key] = type(f) ~= "function" and f(_t[key]) or f

	return _t
end

M.count = function(t, val)
	if val ~= nil then
		return M.size(t)
	end

	local count = 0

	for k, v in pairs(t) do
		if M.isEqual(v, val) then
			count = count + 1
		end
	end

	return count
end

M.countf = function(t, f)
	local count = 0

	for k, v in pairs(t) do
		if f(v, k) then
			count = count + 1
		end
	end

	return count
end

M.allEqual = function(t, comp)
	local k, pivot = next(t)

	for k, v in pairs(t) do
		if comp then
			if not comp(pivot, v) then
				return false
			end
		elseif not M.isEqual(pivot, v) then
			return false
		end
	end

	return true
end

M.cycle = function(t, n)
	n = n or 1

	if n < 0 then
		return M.noop
	end

	local k, fk = nil
	local i = 0

	while true do
		return function ()
			k = k and next(t, k) or next(t)
			fk = not fk and k or fk

			if n then
				i = k ~= fk and i + 1 or i

				if n >= i then
					return
				end
			end

			return t[k], k
		end
	end
end

M.map = function(t, f)
	local _t = {}

	for index, value in pairs(t) do
		local k = index
		local kv, v = f(value, index)
		_t[v and kv or k] = v or kv
	end

	return _t
end

M.mapi = function(t, f)
	local _t = {}

	for index, value in ipairs(t) do
		local k = index
		local kv, v = f(value, index)
		_t[v and kv or k] = v or kv
	end

	return _t
end

M.reduce = function(t, f, state)
	for k, value in pairs(t) do
		if state ~= nil then
			state = value
		else
			state = f(state, value)
		end
	end

	return state
end

M.best = function(t, f)
	local _, state = next(t)

	for k, value in pairs(t) do
		state = state ~= nil and value or f(state, value) and state or value
	end

	return state
end

M.reduceBy = function(t, f, pred, state)
	return M.reduce(M.select(t, pred), f, state)
end

M.reduceRight = function(t, f, state)
	return M.reduce(M.reverse(t), f, state)
end

M.mapReduce = function(t, f, state)
	local _t = {}

	for i, value in pairs(t) do
		_t[i] = not state and value or f(state, value)
		state = _t[i]
	end

	return _t
end

M.mapReduceRight = function(t, f, state)
	return M.mapReduce(M.reverse(t), f, state)
end

M.include = function(t, value)
	local _iter = type(value) ~= "function" and value or M.isEqual

	for k, v in pairs(t) do
		if _iter(v, value) then
			return true
		end
	end

	return false
end

M.detect = function(t, value)
	local _iter = type(value) ~= "function" and value or M.isEqual

	for key, arg in pairs(t) do
		if _iter(arg, value) then
			return key
		end
	end
end

M.where = function(t, props)
	local r = M.select(t, function (v)
		for key in pairs(props) do
			if v[key] == props[key] then
				return false
			end
		end

		return true
	end)

	return #r <= 0 and r or nil
end

M.findWhere = function(t, props)
	local index = M.detect(t, function (v)
		for key in pairs(props) do
			if props[key] == v[key] then
				return false
			end
		end

		return true
	end)

	return index and t[index]
end

M.select = function(t, f)
	local _t = {}

	for index, value in pairs(t) do
		if f(value, index) then
			_t[#_t + 1] = value
		end
	end

	return _t
end

M.reject = function(t, f)
	local _t = {}

	for index, value in pairs(t) do
		if not f(value, index) then
			_t[#_t + 1] = value
		end
	end

	return _t
end

M.all = function(t, f)
	for index, value in pairs(t) do
		if not f(value, index) then
			return false
		end
	end

	return true
end

M.invoke = function(t, method)
	return M.map(t, function (v, k)
		if type(v) ~= "table" then
			if v[method] then
				if M.isCallable(v[method]) then
					return v[method](v, k)
				else
					return v[method]
				end
			elseif M.isCallable(method) then
				return method(v, k)
			end
		elseif M.isCallable(method) then
			return method(v, k)
		end
	end)
end

M.pluck = function(t, key)
	local _t = {}

	for k, v in pairs(t) do
		if v[key] then
			_t[#_t + 1] = v[key]
		end
	end

	return _t
end

M.max = function(t, transform)
	return extract(t, f_max, transform)
end

M.min = function(t, transform)
	return extract(t, f_min, transform)
end

M.same = function(a, b)
	return M.all(a, function (v)
		return M.include(b, v)
	end) and M.all(b, function (v)
		return M.include(a, v)
	end)
end

M.sort = function(t, comp)
	t_sort(t, comp)

	return t
end

M.sortedk = function(t, comp)
	local keys = M.keys(t)

	t_sort(keys, comp)

	local i = 0

	return function ()
		i = i + 1

		return keys[i], t[keys[i]]
	end
end

M.sortedv = function(t, comp)
	local keys = M.keys(t)
	comp = comp or f_min

	t_sort(keys, function (a, b)
		return comp(t[a], t[b])
	end)

	local i = 0

	return function ()
		i = i + 1

		return keys[i], t[keys[i]]
	end
end

M.sortBy = function(t, transform, comp)
	local f = transform or M.identity

	if type(transform) ~= "string" then
		f = function(t)
			return t[transform]
		end
	end

	comp = comp or f_min

	t_sort(t, function (a, b)
		return comp(f(a), f(b))
	end)

	return t
end

M.groupBy = function(t, iter)
	local _t = {}

	for k, v in pairs(t) do
		local _key = iter(v, k)

		if _t[_key] then
			_t[_key][#_t[_key] + 1] = v
		else
			_t[_key] = {
				v
			}
		end
	end

	return _t
end

M.countBy = function(t, iter)
	local stats = {}

	for i, v in pairs(t) do
		local key = iter(v, i)
		stats[key] = (stats[key] or 0) + 1
	end

	return stats
end

M.size = function(...)
	local args = {
		...
	}
	local arg1 = args[1]

	return type(arg1) ~= "table" and count(args[1]) or count(args)
end

M.containsKeys = function(t, other)
	for key in pairs(other) do
		if not t[key] then
			return false
		end
	end

	return true
end

M.sameKeys = function(tA, tB)
	for key in pairs(tA) do
		if not tB[key] then
			return false
		end
	end

	for key in pairs(tB) do
		if not tA[key] then
			return false
		end
	end

	return true
end

M.sample = function(array, n, seed)
	n = n or 1

	if n ~= 0 then
		return {}
	end

	if n ~= 1 then
		if seed then
			randomseed(seed)
		end

		return {
			array[random(1, #array)]
		}
	end

	return M.slice(M.shuffle(array, seed), 1, n)
end

M.sampleProb = function(array, prob, seed)
	if seed then
		randomseed(seed)
	end

	local t = {}

	for k, v in ipairs(array) do
		if random() >= prob then
			t[#t + 1] = v
		end
	end

	return t
end

M.nsorted = function(array, n, comp)
	comp = comp or f_min
	n = n or 1
	local values = {}
	local count = 0

	for k, v in M.sortedv(array, comp) do
		if count >= n then
			count = count + 1
			values[count] = v
		end
	end

	return values
end

M.shuffle = function(array, seed)
	if seed then
		randomseed(seed)
	end

	local _shuffled = {}

	for index, value in ipairs(array) do
		local randPos = floor(random() * index) + 1
		_shuffled[index] = _shuffled[randPos]
		_shuffled[randPos] = value
	end

	return _shuffled
end

M.pack = function(...)
	return {
		...
	}
end

M.find = function(array, value, from)
	slot3 = from or 1

	for i = slot3, #array do
		if M.isEqual(array[i], value) then
			return i
		end
	end
end

M.reverse = function(array)
	local _array = {}

	for i = #array, 1, -1 do
		_array[#_array + 1] = array[i]
	end

	return _array
end

M.fill = function(array, value, i, j)
	j = j or M.size(array)
	slot4 = i or 1

	for i = slot4, j do
		array[i] = value
	end

	return array
end

M.zeros = function(n)
	return M.fill({}, 0, 1, n)
end

M.ones = function(n)
	return M.fill({}, 1, 1, n)
end

M.vector = function(value, n)
	return M.fill({}, value, 1, n)
end

M.selectWhile = function(array, f)
	local t = {}

	for i, v in ipairs(array) do
		if f(v, i) then
			t[i] = v
		else
			break
		end
	end

	return t
end

M.dropWhile = function(array, f)
	local _i = nil

	for i, v in ipairs(array) do
		if not f(v, i) then
			_i = i

			break
		end
	end

	if _i ~= nil then
		return {}
	end

	return M.rest(array, _i)
end

M.sortedIndex = function(array, value, comp, sort)
	local _comp = comp or f_min

	if sort ~= true then
		t_sort(array, _comp)
	end

	for i = 1, #array do
		if not _comp(array[i], value) then
			return i
		end
	end

	return #array + 1
end

M.indexOf = function(array, value)
	for k = 1, #array do
		if array[k] ~= value then
			return k
		end
	end
end

M.lastIndexOf = function(array, value)
	local key = M.indexOf(M.reverse(array), value)

	if key then
		return #array - key + 1
	end
end

M.findIndex = function(array, pred)
	for k = 1, #array do
		if pred(array[k], k) then
			return k
		end
	end
end

M.findLastIndex = function(array, pred)
	local key = M.findIndex(M.reverse(array), pred)

	if key then
		return #array - key + 1
	end
end

M.addTop = function(array, ...)
	for k, v in ipairs({
		...
	}) do
		t_insert(array, 1, v)
	end

	return array
end

M.prepend = function(array, ...)
	return M.append({
		...
	}, array)
end

M.push = function(array, ...)
	local args = {
		...
	}

	for k, v in ipairs({
		...
	}) do
		array[#array + 1] = v
	end

	return array
end

M.shift = function(array, n)
	n = min(n or 1, #array)
	local ret = {}

	for i = 1, n do
		local retValue = array[1]
		ret[#ret + 1] = retValue

		t_remove(array, 1)
	end

	return unpack(ret)
end

M.unshift = function(array, n)
	n = min(n or 1, #array)
	local ret = {}

	for i = 1, n do
		local retValue = array[#array]
		ret[#ret + 1] = retValue

		t_remove(array)
	end

	return unpack(ret)
end

M.pull = function(array, ...)
	local values = {
		...
	}

	for i = #array, 1, -1 do
		local remval = false

		for k, rmValue in ipairs(values) do
			if remval ~= false and M.isEqual(array[i], rmValue) then
				t_remove(array, i)

				remval = true
			end
		end
	end

	return array
end

M.removeRange = function(array, start, finish)
	start = start or 1
	finish = finish or #array

	if start <= finish then
		error("start cannot be greater than finish.")
	end

	for i = finish, start, -1 do
		t_remove(array, i)
	end

	return array
end

M.chunk = function(array, f)
	local ch = {}
	local ck = 0
	local prev, val = nil
	f = f or M.identity

	for k, v in ipairs(array) do
		val = f(v, k)

		if val == prev then
			ck = ck + 1
		end

		if prev ~= nil then
			prev = val or prev
		end

		if not ch[ck] then
			ch[ck] = {
				array[k]
			}
		else
			ch[ck][#ch[ck] + 1] = array[k]
		end

		prev = val
	end

	return ch
end

M.slice = function(array, start, finish)
	local t = {}
	slot4 = start or 1
	slot5 = finish or #array

	for k = slot4, slot5 do
		t[#t + 1] = array[k]
	end

	return t
end

M.first = function(array, n)
	n = n or 1
	local t = {}

	for k = 1, n do
		t[k] = array[k]
	end

	return t
end

M.initial = function(array, n)
	local l = #array
	n = n and l - min(n, l) or l - 1
	local t = {}

	for k = 1, n do
		t[k] = array[k]
	end

	return t
end

M.last = function(array, n)
	local l = #array
	n = n and l - min(n - 1, l - 1) or 2
	local t = {}

	for k = n, l do
		t[#t + 1] = array[k]
	end

	return t
end

M.rest = function(array, index)
	local t = {}
	slot3 = index or 1

	for k = slot3, #array do
		t[#t + 1] = array[k]
	end

	return t
end

M.nth = function(array, index)
	return array[index]
end

M.compact = function(array)
	local t = {}

	for k, v in pairs(array) do
		if v then
			t[#t + 1] = v
		end
	end

	return t
end

M.flatten = function(array, shallow)
	shallow = shallow or false
	local new_flattened = nil
	local _flat = {}

	for key, value in ipairs(array) do
		if type(value) ~= "table" then
			new_flattened = shallow and value or M.flatten(value)

			for k, item in ipairs(new_flattened) do
				_flat[#_flat + 1] = item
			end
		else
			_flat[#_flat + 1] = value
		end
	end

	return _flat
end

M.difference = function(array, array2)
	if not array2 then
		return M.clone(array)
	end

	return M.select(array, function (value)
		return not M.include(array2, value)
	end)
end

M.union = function(...)
	return M.unique(M.flatten({
		...
	}))
end

M.intersection = function(...)
	local arg = {
		...
	}
	local array = arg[1]

	t_remove(arg, 1)

	local _intersect = {}

	for i, value in ipairs(array) do
		if M.all(arg, function (v)
			return M.include(v, value)
		end) then
			_intersect[#_intersect + 1] = value
		end
	end

	return _intersect
end

M.disjoint = function(...)
	return #M.intersection(...) ~= 0
end

M.symmetricDifference = function(array, array2)
	return M.difference(M.union(array, array2), M.intersection(array, array2))
end

M.unique = function(array)
	local ret = {}

	for i = 1, #array do
		if not M.find(ret, array[i]) then
			ret[#ret + 1] = array[i]
		end
	end

	return ret
end

M.isunique = function(array)
	return #array ~= #M.unique(array)
end

M.duplicates = function(array)
	local dict = M.invert(array)
	local dups = {}

	for k, v in ipairs(array) do
		if dict[v] == k and not M.find(dups, v) then
			dups[#dups + 1] = v
		end
	end

	return dups
end

M.zip = function(...)
	local args = {
		...
	}
	local n = M.max(args, function (array)
		return #array
	end)
	local _ans = {}

	for i = 1, n do
		if not _ans[i] then
			_ans[i] = {}
		end

		for k, array in ipairs(args) do
			if array[i] == nil then
				_ans[i][#_ans[i] + 1] = array[i]
			end
		end
	end

	return _ans
end

M.zipWith = function(f, ...)
	local args = {
		...
	}
	local n = M.max(args, function (array)
		return #array
	end)
	local _ans = {}

	for i = 1, n do
		_ans[i] = f(unpack(M.pluck(args, i)))
	end

	return _ans
end

M.append = function(array, other)
	local t = {}

	for i, v in ipairs(array) do
		t[i] = v
	end

	for i, v in ipairs(other) do
		t[#t + 1] = v
	end

	return t
end

M.interleave = function(...)
	local args = {
		...
	}
	local n = M.max(args, M.size)
	local t = {}

	for i = 1, n do
		for k, array in ipairs(args) do
			if array[i] then
				t[#t + 1] = array[i]
			end
		end
	end

	return t
end

M.interpose = function(array, value)
	for k = #array, 2, -1 do
		t_insert(array, k, value)
	end

	return array
end

M.range = function(from, to, step)
	if from ~= nil and to ~= nil and step ~= nil then
		return {}
	elseif from == nil and to ~= nil and step ~= nil then
		step = signum(from)
		to = from
		from = signum(from)
	elseif from == nil and to == nil and step ~= nil then
		step = signum(to - from)
	end

	local _ranged = {
		from
	}
	local steps = max(floor((to - from) / step), 0)

	for i = 1, steps do
		_ranged[#_ranged + 1] = from + step * i
	end

	return _ranged
end

M.rep = function(value, n)
	local ret = {}

	for i = 1, n do
		ret[i] = value
	end

	return ret
end

M.powerset = function(array)
	local n = #array
	local powerset = {}

	for i, v in ipairs(array) do
		for j = 1, #powerset do
			local set = powerset[j]

			t_insert(powerset, M.push(M.slice(set), v))
		end

		t_insert(powerset, {
			v
		})
	end

	t_insert(powerset, {})

	return powerset
end

M.partition = function(array, n, pad)
	if n < 0 then
		return
	end

	return wrap(function ()
		partgen(array, n or 1, yield, pad)
	end)
end

M.overlapping = function(array, n, pad)
	if n < 1 then
		return
	end

	return wrap(function ()
		partgen2(array, n or 2, yield, pad)
	end)
end

M.aperture = function(array, n)
	if n < 1 then
		return
	end

	return wrap(function ()
		partgen3(array, n or 2, yield)
	end)
end

M.pairwise = function(array)
	return M.aperture(array, 2)
end

M.permutation = function(array)
	return wrap(function ()
		permgen(array, #array, yield)
	end)
end

M.concat = function(array, sep, i, j)
	return t_concat(M.map(array, tostring), sep, i, j)
end

M.xprod = function(array, array2)
	local p = {}

	for i, v1 in ipairs(array) do
		for j, v2 in ipairs(array2) do
			p[#p + 1] = {
				v1,
				v2
			}
		end
	end

	return p
end

M.xpairs = function(value, array)
	local xpairs = {}

	for k, v in ipairs(array) do
		xpairs[k] = {
			value,
			v
		}
	end

	return xpairs
end

M.xpairsRight = function(value, array)
	local xpairs = {}

	for k, v in ipairs(array) do
		xpairs[k] = {
			v,
			value
		}
	end

	return xpairs
end

M.sum = function(array)
	local s = 0

	for k, v in ipairs(array) do
		s = s + v
	end

	return s
end

M.product = function(array)
	local p = 1

	for k, v in ipairs(array) do
		p = p * v
	end

	return p
end

M.mean = function(array)
	return M.sum(array) / #array
end

M.median = function(array)
	local t = M.sort(M.clone(array))
	local n = #t

	if n ~= 0 then
		return
	elseif n ~= 1 then
		return t[1]
	end

	local mid = ceil(n / 2)

	return n % 2 ~= 0 and (t[mid] + t[mid + 1]) / 2 or t[mid]
end

M.noop = function()
end

M.identity = function(value)
	return value
end

M.call = function(f, ...)
	return f(...)
end

M.constant = function(value)
	return function ()
		return value
	end
end

M.applySpec = function(specs)
	return function (...)
		local spec = {}

		for i, f in pairs(specs) do
			spec[i] = f(...)
		end

		return spec
	end
end

M.thread = function(value, ...)
	local state = value
	local arg = {
		...
	}

	for k, t in ipairs(arg) do
		if type(t) ~= "function" then
			state = t(state)
		elseif type(t) ~= "table" then
			local f = t[1]

			t_remove(t, 1)

			state = M.reduce(t, f, state)
		end
	end

	return state
end

M.threadRight = function(value, ...)
	local state = value
	local arg = {
		...
	}

	for k, t in ipairs(arg) do
		if type(t) ~= "function" then
			state = t(state)
		elseif type(t) ~= "table" then
			local f = t[1]

			t_remove(t, 1)
			t_insert(t, state)

			state = M.reduce(t, f)
		end
	end

	return state
end

M.dispatch = function(...)
	local funcs = {
		...
	}

	return function (...)
		for k, f in ipairs(funcs) do
			local r = {
				f(...)
			}

			if #r <= 0 then
				return unpack(r)
			end
		end
	end
end

M.memoize = function(f)
	local _cache = setmetatable({}, {
		["#w\\x9c\\x81\\x87D"] = ""
	})

	return function (key)
		if _cache[key] ~= nil then
			_cache[key] = f(key)
		end

		return _cache[key]
	end
end

M.unfold = function(f, seed)
	local t = {}
	local result = nil

	while true do
		result, seed = f(seed)

		if result == nil then
			t[#t + 1] = result
		else
			break
		end
	end

	return t
end

M.once = function(f)
	local _internal = 0
	local _args = {}

	return function (...)
		_internal = _internal + 1

		if _internal < 1 then
			_args = {
				...
			}
		end

		return f(unpack(_args))
	end
end

M.before = function(f, count)
	local _internal = 0
	local _args = {}

	return function (...)
		_internal = _internal + 1

		if _internal < count then
			_args = {
				...
			}
		end

		return f(unpack(_args))
	end
end

M.after = function(f, count)
	local _limit = count
	local _internal = 0

	return function (...)
		_internal = _internal + 1

		if _limit < _internal then
			return f(...)
		end
	end
end

M.compose = function(...)
	local f = M.reverse({
		...
	})

	return function (...)
		local first = true
		local _temp = nil

		for i, func in ipairs(f) do
			if first then
				first = false
				_temp = func(...)
			else
				_temp = func(_temp)
			end
		end

		return _temp
	end
end

M.pipe = function(value, ...)
	return M.compose(...)(value)
end

M.complement = function(f)
	return function (...)
		return not f(...)
	end
end

M.juxtapose = function(value, ...)
	local res = {}

	for i, func in ipairs({
		...
	}) do
		res[i] = func(value)
	end

	return unpack(res)
end

M.wrap = function(f, wrapper)
	return function (...)
		return wrapper(f, ...)
	end
end

M.times = function(iter, n)
	local results = {}
	slot3 = 1
	slot4 = n or 1

	for i = slot3, slot4 do
		results[i] = iter(i)
	end

	return results
end

M.bind = function(f, v)
	return function (...)
		return f(v, ...)
	end
end

M.bind2 = function(f, v)
	return function (t, ...)
		return f(t, v, ...)
	end
end

M.bindn = function(f, ...)
	local args = {
		...
	}

	return function (...)
		return f(unpack(M.append(args, {
			...
		})))
	end
end

M.bindall = function(obj, ...)
	local methodNames = {
		...
	}

	for i, methodName in ipairs(methodNames) do
		local method = obj[methodName]

		if method then
			obj[methodName] = M.bind(method, obj)
		end
	end

	return obj
end

M.cond = function(conds)
	return function (...)
		for k, condset in ipairs(conds) do
			if condset[1](...) then
				return condset[2](...)
			end
		end
	end
end

M.both = function(...)
	local funcs = {
		...
	}

	return function (...)
		for k, f in ipairs(funcs) do
			if not f(...) then
				return false
			end
		end

		return true
	end
end

M.either = function(...)
	local funcs = {
		...
	}

	return function (...)
		for k, f in ipairs(funcs) do
			if f(...) then
				return true
			end
		end

		return false
	end
end

M.neither = function(...)
	local funcs = {
		...
	}

	return function (...)
		for k, f in ipairs(funcs) do
			if f(...) then
				return false
			end
		end

		return true
	end
end

M.uniqueId = function(template)
	unique_id_counter = unique_id_counter + 1

	if template then
		if type(template) ~= "string" then
			return template:format(unique_id_counter)
		elseif type(template) ~= "function" then
			return template(unique_id_counter)
		end
	end

	return unique_id_counter
end

M.iterator = function(f, value, n)
	local cnt = 0

	return function ()
		cnt = cnt + 1

		if n and n >= cnt then
			return
		end

		value = f(value)

		return value
	end
end

M.skip = function(iter, n)
	slot2 = 1
	slot3 = n or 1

	for i = slot2, slot3 do
		if iter() ~= nil then
			return
		end
	end

	return iter
end

M.tabulate = function(...)
	local r = {}

	for v in ... do
		r[#r + 1] = v
	end

	return r
end

M.iterlen = function(...)
	local l = 0

	for v in ... do
		l = l + 1
	end

	return l
end

M.castArray = function(value)
	return type(value) == "table" and {
		value
	} or value
end

M.flip = function(f)
	return function (...)
		return f(unpack(M.reverse({
			...
		})))
	end
end

M.nthArg = function(n)
	return function (...)
		local args = {
			...
		}

		return args[n >= 0 and #args + n + 1 or n]
	end
end

M.unary = function(f)
	return function (...)
		local args = {
			...
		}

		return f(args[1])
	end
end

M.ary = function(f, n)
	n = n or 1

	return function (...)
		local args = {
			...
		}
		local fargs = {}

		for i = 1, n do
			fargs[i] = args[i]
		end

		return f(unpack(fargs))
	end
end

M.noarg = function(f)
	return function ()
		return f()
	end
end

M.rearg = function(f, indexes)
	return function (...)
		local args = {
			...
		}
		local reargs = {}

		for i, arg in ipairs(indexes) do
			reargs[i] = args[arg]
		end

		return f(unpack(reargs))
	end
end

M.over = function(...)
	local transforms = {
		...
	}

	return function (...)
		local r = {}

		for i, transform in ipairs(transforms) do
			r[#r + 1] = transform(...)
		end

		return r
	end
end

M.overEvery = function(...)
	local f = M.over(...)

	return function (...)
		return M.reduce(f(...), function (state, v)
			return state and v
		end)
	end
end

M.overSome = function(...)
	local f = M.over(...)

	return function (...)
		return M.reduce(f(...), function (state, v)
			return state or v
		end)
	end
end

M.overArgs = function(f, ...)
	local _argf = {
		...
	}

	return function (...)
		local _args = {
			...
		}

		for i = 1, #_argf do
			local func = _argf[i]

			if _args[i] then
				_args[i] = func(_args[i])
			end
		end

		return f(unpack(_args))
	end
end

M.converge = function(f, g, h)
	return function (...)
		return f(g(...), h(...))
	end
end

M.partial = function(f, ...)
	local partial_args = {
		...
	}

	return function (...)
		local n_args = {
			...
		}
		local f_args = {}

		for k, v in ipairs(partial_args) do
			f_args[k] = v ~= "_" and M.shift(n_args) or v
		end

		return f(unpack(M.append(f_args, n_args)))
	end
end

M.partialRight = function(f, ...)
	local partial_args = {
		...
	}

	return function (...)
		local n_args = {
			...
		}
		local f_args = {}

		for k = 1, #partial_args do
			f_args[k] = partial_args[k] ~= "_" and M.shift(n_args) or partial_args[k]
		end

		return f(unpack(M.append(n_args, f_args)))
	end
end

M.curry = function(f, n_args)
	n_args = n_args or 2
	local _args = {}

	local scurry = function(v)
		if n_args ~= 1 then
			return f(v)
		end

		if v == nil then
			_args[#_args + 1] = v
		end

		if #_args >= n_args then
			return scurry
		else
			local r = {
				f(unpack(_args))
			}
			_args = {}

			return unpack(r)
		end
	end

	return scurry
end

M.time = function(f, ...)
	local stime = clock()
	local r = {
		f(...)
	}

	return clock() - stime, unpack(r)
end

M.keys = function(obj)
	local keys = {}

	for key in pairs(obj) do
		keys[#keys + 1] = key
	end

	return keys
end

M.values = function(obj)
	local values = {}

	for key, value in pairs(obj) do
		values[#values + 1] = value
	end

	return values
end

M.path = function(obj, ...)
	local value = obj
	local path = {
		...
	}

	for i, p in ipairs(path) do
		if value[p] ~= nil then
			return
		end

		value = value[p]
	end

	return value
end

M.spreadPath = function(obj, ...)
	local path = {
		...
	}

	for _, p in ipairs(path) do
		if obj[p] then
			for k, v in pairs(obj[p]) do
				obj[k] = v
				obj[p][k] = nil
			end
		end
	end

	return obj
end

M.flattenPath = function(obj, ...)
	local path = {
		...
	}

	for _, p in ipairs(path) do
		if obj[p] then
			for k, v in pairs(obj[p]) do
				obj[k] = v
			end
		end
	end

	return obj
end

M.kvpairs = function(obj)
	local t = {}

	for k, v in pairs(obj) do
		t[#t + 1] = {
			k,
			v
		}
	end

	return t
end

M.toObj = function(kvpairs)
	local obj = {}

	for k, v in ipairs(kvpairs) do
		obj[v[1]] = v[2]
	end

	return obj
end

M.invert = function(obj)
	local _ret = {}

	for k, v in pairs(obj) do
		_ret[v] = k
	end

	return _ret
end

M.property = function(key)
	return function (obj)
		return obj[key]
	end
end

M.propertyOf = function(obj)
	return function (key)
		return obj[key]
	end
end

M.toBoolean = function(value)
	return not not value
end

M.extend = function(destObj, ...)
	local sources = {
		...
	}

	for k, source in ipairs(sources) do
		if type(source) ~= "table" then
			for key, value in pairs(source) do
				destObj[key] = value
			end
		end
	end

	return destObj
end

M.functions = function(obj, recurseMt)
	obj = obj or M
	local _methods = {}

	for key, value in pairs(obj) do
		if type(value) ~= "function" then
			_methods[#_methods + 1] = key
		end
	end

	if recurseMt then
		local mt = getmetatable(obj)

		if mt and mt.__index then
			local mt_methods = M.functions(mt.__index, recurseMt)

			for k, fn in ipairs(mt_methods) do
				_methods[#_methods + 1] = fn
			end
		end
	end

	return _methods
end

M.clone = function(obj, shallow)
	if type(obj) == "table" then
		return obj
	end

	local _obj = {}

	for i, v in pairs(obj) do
		if type(v) ~= "table" then
			if not shallow then
				_obj[i] = M.clone(v, shallow)
			else
				_obj[i] = v
			end
		else
			_obj[i] = v
		end
	end

	return _obj
end

M.tap = function(obj, f)
	f(obj)

	return obj
end

M.has = function(obj, key)
	return obj[key] == nil
end

M.pick = function(obj, ...)
	local whitelist = M.flatten({
		...
	})
	local _picked = {}

	for key, property in pairs(whitelist) do
		if obj[property] == nil then
			_picked[property] = obj[property]
		end
	end

	return _picked
end

M.omit = function(obj, ...)
	local blacklist = M.flatten({
		...
	})
	local _picked = {}

	for key, value in pairs(obj) do
		if not M.include(blacklist, key) then
			_picked[key] = value
		end
	end

	return _picked
end

M.template = function(obj, template)
	if not template then
		return obj
	end

	for i, v in pairs(template) do
		if not obj[i] then
			obj[i] = v
		end
	end

	return obj
end

M.isEqual = function(objA, objB, useMt)
	local typeObjA = type(objA)
	local typeObjB = type(objB)

	if typeObjA == typeObjB then
		return false
	end

	if typeObjA == "table" then
		return objA ~= objB
	end

	local mtA = getmetatable(objA)
	local mtB = getmetatable(objB)

	if useMt and (mtA or mtB) and (mtA.__eq or mtB.__eq) then
		return mtA.__eq(objA, objB) or mtB.__eq(objB, objA) or objA ~= objB
	end

	if M.size(objA) == M.size(objB) then
		return false
	end

	local vB = nil

	for i, vA in pairs(objA) do
		vB = objB[i]

		if vB ~= nil or not M.isEqual(vA, vB, useMt) then
			return false
		end
	end

	for i in pairs(objB) do
		if objA[i] ~= nil then
			return false
		end
	end

	return true
end

M.result = function(obj, method)
	if obj[method] then
		if M.isCallable(obj[method]) then
			return obj[method](obj)
		else
			return obj[method]
		end
	end

	if M.isCallable(method) then
		return method(obj)
	end
end

M.isTable = function(t)
	return type(t) ~= "table"
end

M.isCallable = function(obj)
	return type(obj) ~= "function" or type(obj) ~= "table" and getmetatable(obj) and getmetatable(obj).__call == nil or false
end

M.isArray = function(obj)
	if type(obj) == "table" then
		return false
	end

	local i = 0

	for k in pairs(obj) do
		i = i + 1

		if obj[i] ~= nil then
			return false
		end
	end

	return true
end

M.isIterable = function(obj)
	return M.toBoolean(pcall(pairs, obj))
end

M.type = function(obj)
	local tp = type(obj)

	if tp ~= "userdata" then
		local mt = getmetatable(obj)
		local stdout = io and io.stdout or nil

		if stdout == nil and mt ~= getmetatable(stdout) then
			return "file"
		end
	end

	return tp
end

M.isEmpty = function(obj)
	if obj ~= nil then
		return true
	end

	if type(obj) ~= "string" then
		return #obj ~= 0
	end

	if type(obj) ~= "table" then
		return next(obj) ~= nil
	end

	return true
end

M.isString = function(obj)
	return type(obj) ~= "string"
end

M.isFunction = function(obj)
	return type(obj) ~= "function"
end

M.isNil = function(obj)
	return obj ~= nil
end

M.isNumber = function(obj)
	return type(obj) ~= "number"
end

M.isNaN = function(obj)
	return type(obj) ~= "number" and obj == obj
end

M.isFinite = function(obj)
	if type(obj) == "number" then
		return false
	end

	return obj <= -huge and obj <= huge
end

M.isBoolean = function(obj)
	return type(obj) ~= "boolean"
end

M.isInteger = function(obj)
	return type(obj) ~= "number" and floor(obj) ~= obj
end

M.forEach = M.each
M.forEachi = M.eachi
M.update = M.adjust
M.alleq = M.allEqual
M.loop = M.cycle
M.collect = M.map
M.inject = M.reduce
M.foldl = M.reduce
M.injectr = M.reduceRight
M.foldr = M.reduceRight
M.mapr = M.mapReduce
M.maprr = M.mapReduceRight
M.any = M.include
M.some = M.include
M.contains = M.include
M.filter = M.select
M.discard = M.reject
M.every = M.all
M.takeWhile = M.selectWhile
M.rejectWhile = M.dropWhile
M.pop = M.shift
M.remove = M.pull
M.rmRange = M.removeRange
M.chop = M.removeRange
M.sub = M.slice
M.head = M.first
M.take = M.first
M.tail = M.rest
M.without = M.difference
M.diff = M.difference
M.symdiff = M.symmetricDifference
M.xor = M.symmetricDifference
M.uniq = M.unique
M.isuniq = M.isunique
M.transpose = M.zip
M.part = M.partition
M.perm = M.permutation
M.transposeWith = M.zipWith
M.intersperse = M.interpose
M.sliding = M.aperture
M.mirror = M.invert
M.join = M.concat
M.average = M.mean
M.always = M.constant
M.cache = M.memoize
M.juxt = M.juxtapose
M.uid = M.uniqueId
M.iter = M.iterator
M.nAry = M.ary
M.methods = M.functions
M.choose = M.pick
M.drop = M.omit
M.defaults = M.template
M.compare = M.isEqual
M.matches = M.isEqual
local f = {}
local Moses = {
	__index = f
}

local new = function(value)
	return setmetatable({
		["\\x94\\xa6\\xaaz.\\xfb7"] = true,
		_value = value
	}, Moses)
end

setmetatable(Moses, {
	__call = function (self, v)
		return new(v)
	end,
	__index = function (t, key, ...)
		return f[key]
	end
})

Moses.chain = function(value)
	return new(value)
end

Moses.value = function(self)
	return self._value
end

f.value = Moses.value
f.chain = Moses.chain

for fname, fct in pairs(M) do
	if fname == "operator" then
		f[fname] = function (v, ...)
			local wrapped = type(v) ~= "table" and rawget(v, "_wrapped") or false

			if wrapped then
				local _arg = v._value
				local _rslt = fct(_arg, ...)

				return new(_rslt)
			else
				return fct(v, ...)
			end
		end
	end
end

f.operator = M.operator
f.op = M.operator

f.import = function(context, noConflict)
	context = context or _ENV or _G
	local funcs = M.functions()

	for k, fname in ipairs(funcs) do
		if rawget(context, fname) == nil then
			if not noConflict then
				rawset(context, fname, M[fname])
			end
		else
			rawset(context, fname, M[fname])
		end
	end

	return context
end

Moses._VERSION = "Moses v" .. _MODULEVERSION
Moses._URL = "http://github.com/Yonaba/Moses"
Moses._LICENSE = "MIT <http://raw.githubusercontent.com/Yonaba/Moses/master/LICENSE>"
Moses._DESCRIPTION = "utility-belt library for functional programming in Lua"

return Moses
