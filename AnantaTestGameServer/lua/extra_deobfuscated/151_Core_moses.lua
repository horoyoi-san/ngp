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

local function f_max(a, b)
	return b < a
end

local function f_min(a, b)
	return a < b
end

local function count(t)
	local i = 0

	for k, v in pairs(t) do
		i = i + 1
	end

	return i
end

local function extract(list, comp, transform, ...)
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

local function partgen(t, n, f, pad)
	for i = 0, #t, n do
		local s = M.slice(t, i + 1, i + n)

		if #s > 0 then
			while n > #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local function partgen2(t, n, f, pad)
	for i = 0, #t, n - 1 do
		local s = M.slice(t, i + 1, i + n)

		if #s > 0 and i + 1 < #t then
			while n > #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local function partgen3(t, n, f, pad)
	for i = 0, #t do
		local s = M.slice(t, i + 1, i + n)

		if #s > 0 and i + n <= #t then
			while n > #s and pad do
				s[#s + 1] = pad
			end

			f(s)
		end
	end
end

local function permgen(t, n, f)
	if n == 0 then
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

local function signum(a)
	return a >= 0 and 1 or -1
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

function M.operator.unm(a)
	return -a
end

M.operator.neg = M.operator.unm

function M.operator.floordiv(a, b)
	return floor(a / b)
end

function M.operator.intdiv(a, b)
	return a >= 0 and floor(a / b) or ceil(a / b)
end

function M.operator.eq(a, b)
	return a == b
end

function M.operator.neq(a, b)
	return a ~= b
end

function M.operator.lt(a, b)
	return a < b
end

function M.operator.gt(a, b)
	return b < a
end

function M.operator.le(a, b)
	return a <= b
end

function M.operator.ge(a, b)
	return b <= a
end

function M.operator.land(a, b)
	return a and b
end

function M.operator.lor(a, b)
	return a or b
end

function M.operator.lnot(a)
	return not a
end

function M.operator.concat(a, b)
	return a .. b
end

function M.operator.length(a)
	return #a
end

M.operator.len = M.operator.length

function M.clear(t)
	for k in pairs(t) do
		t[k] = nil
	end

	return t
end

function M.each(t, f)
	for index, value in pairs(t) do
		f(value, index)
	end
end

function M.eachi(t, f)
	local lkeys = M.sort(M.select(M.keys(t), M.isInteger))

	for k, key in ipairs(lkeys) do
		f(t[key], key)
	end
end

function M.at(t, ...)
	local values = {}

	for i, key in ipairs({
		...
	}) do
		values[#values + 1] = t[key]
	end

	return values
end

function M.adjust(t, key, f)
	if t[key] == nil then
		error("key not existing in table")
	end

	local _t = M.clone(t)
	_t[key] = type(f) == "function" and f(_t[key]) or f

	return _t
end

function M.count(t, val)
	if val == nil then
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

function M.countf(t, f)
	local count = 0

	for k, v in pairs(t) do
		if f(v, k) then
			count = count + 1
		end
	end

	return count
end

function M.allEqual(t, comp)
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

function M.cycle(t, n)
	n = n or 1

	if n <= 0 then
		return M.noop
	end

	local k, fk = nil
	local i = 0

	while true do
		return function ()
			k = k and next(t, k) or next(t)
			fk = not fk and k or fk

			if n then
				i = k == fk and i + 1 or i

				if n < i then
					return
				end
			end

			return t[k], k
		end
	end
end

function M.map(t, f)
	local _t = {}

	for index, value in pairs(t) do
		local k = index
		local kv, v = f(value, index)
		_t[v and kv or k] = v or kv
	end

	return _t
end

function M.mapi(t, f)
	local _t = {}

	for index, value in ipairs(t) do
		local k = index
		local kv, v = f(value, index)
		_t[v and kv or k] = v or kv
	end

	return _t
end

function M.reduce(t, f, state)
	for k, value in pairs(t) do
		if state == nil then
			state = value
		else
			state = f(state, value)
		end
	end

	return state
end

function M.best(t, f)
	local _, state = next(t)

	for k, value in pairs(t) do
		state = state == nil and value or f(state, value) and state or value
	end

	return state
end

function M.reduceBy(t, f, pred, state)
	return M.reduce(M.select(t, pred), f, state)
end

function M.reduceRight(t, f, state)
	return M.reduce(M.reverse(t), f, state)
end

function M.mapReduce(t, f, state)
	local _t = {}

	for i, value in pairs(t) do
		_t[i] = not state and value or f(state, value)
		state = _t[i]
	end

	return _t
end

function M.mapReduceRight(t, f, state)
	return M.mapReduce(M.reverse(t), f, state)
end

function M.include(t, value)
	local _iter = type(value) == "function" and value or M.isEqual

	for k, v in pairs(t) do
		if _iter(v, value) then
			return true
		end
	end

	return false
end

function M.detect(t, value)
	local _iter = type(value) == "function" and value or M.isEqual

	for key, arg in pairs(t) do
		if _iter(arg, value) then
			return key
		end
	end
end

function M.where(t, props)
	local r = M.select(t, function (v)
		for key in pairs(props) do
			if v[key] ~= props[key] then
				return false
			end
		end

		return true
	end)

	return #r > 0 and r or nil
end

function M.findWhere(t, props)
	local index = M.detect(t, function (v)
		for key in pairs(props) do
			if props[key] ~= v[key] then
				return false
			end
		end

		return true
	end)

	return index and t[index]
end

function M.select(t, f)
	local _t = {}

	for index, value in pairs(t) do
		if f(value, index) then
			_t[#_t + 1] = value
		end
	end

	return _t
end

function M.reject(t, f)
	local _t = {}

	for index, value in pairs(t) do
		if not f(value, index) then
			_t[#_t + 1] = value
		end
	end

	return _t
end

function M.all(t, f)
	for index, value in pairs(t) do
		if not f(value, index) then
			return false
		end
	end

	return true
end

function M.invoke(t, method)
	return M.map(t, function (v, k)
		if type(v) == "table" then
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

function M.pluck(t, key)
	local _t = {}

	for k, v in pairs(t) do
		if v[key] then
			_t[#_t + 1] = v[key]
		end
	end

	return _t
end

function M.max(t, transform)
	return extract(t, f_max, transform)
end

function M.min(t, transform)
	return extract(t, f_min, transform)
end

function M.same(a, b)
	return M.all(a, function (v)
		return M.include(b, v)
	end) and M.all(b, function (v)
		return M.include(a, v)
	end)
end

function M.sort(t, comp)
	t_sort(t, comp)

	return t
end

function M.sortedk(t, comp)
	local keys = M.keys(t)

	t_sort(keys, comp)

	local i = 0

	return function ()
		i = i + 1

		return keys[i], t[keys[i]]
	end
end

function M.sortedv(t, comp)
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

function M.sortBy(t, transform, comp)
	local f = transform or M.identity

	if type(transform) == "string" then
		function f(t)
			return t[transform]
		end
	end

	comp = comp or f_min

	t_sort(t, function (a, b)
		return comp(f(a), f(b))
	end)

	return t
end

function M.groupBy(t, iter)
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

function M.countBy(t, iter)
	local stats = {}

	for i, v in pairs(t) do
		local key = iter(v, i)
		stats[key] = (stats[key] or 0) + 1
	end

	return stats
end

function M.size(...)
	local args = {
		...
	}
	local arg1 = args[1]

	return type(arg1) == "table" and count(args[1]) or count(args)
end

function M.containsKeys(t, other)
	for key in pairs(other) do
		if not t[key] then
			return false
		end
	end

	return true
end

function M.sameKeys(tA, tB)
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

function M.sample(array, n, seed)
	n = n or 1

	if n == 0 then
		return {}
	end

	if n == 1 then
		if seed then
			randomseed(seed)
		end

		return {
			array[random(1, #array)]
		}
	end

	return M.slice(M.shuffle(array, seed), 1, n)
end

function M.sampleProb(array, prob, seed)
	if seed then
		randomseed(seed)
	end

	local t = {}

	for k, v in ipairs(array) do
		if random() < prob then
			t[#t + 1] = v
		end
	end

	return t
end

function M.nsorted(array, n, comp)
	comp = comp or f_min
	n = n or 1
	local values = {}
	local count = 0

	for k, v in M.sortedv(array, comp) do
		if count < n then
			count = count + 1
			values[count] = v
		end
	end

	return values
end

function M.shuffle(array, seed)
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

function M.pack(...)
	return {
		...
	}
end

function M.find(array, value, from)
	for i = from or 1, #array do
		if M.isEqual(array[i], value) then
			return i
		end
	end
end

function M.reverse(array)
	local _array = {}

	for i = #array, 1, -1 do
		_array[#_array + 1] = array[i]
	end

	return _array
end

function M.fill(array, value, i, j)
	j = j or M.size(array)

	for i = i or 1, j do
		array[i] = value
	end

	return array
end

function M.zeros(n)
	return M.fill({}, 0, 1, n)
end

function M.ones(n)
	return M.fill({}, 1, 1, n)
end

function M.vector(value, n)
	return M.fill({}, value, 1, n)
end

function M.selectWhile(array, f)
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

function M.dropWhile(array, f)
	local _i = nil

	for i, v in ipairs(array) do
		if not f(v, i) then
			_i = i

			break
		end
	end

	if _i == nil then
		return {}
	end

	return M.rest(array, _i)
end

function M.sortedIndex(array, value, comp, sort)
	local _comp = comp or f_min

	if sort == true then
		t_sort(array, _comp)
	end

	for i = 1, #array do
		if not _comp(array[i], value) then
			return i
		end
	end

	return #array + 1
end

function M.indexOf(array, value)
	for k = 1, #array do
		if array[k] == value then
			return k
		end
	end
end

function M.lastIndexOf(array, value)
	local key = M.indexOf(M.reverse(array), value)

	if key then
		return #array - key + 1
	end
end

function M.findIndex(array, pred)
	for k = 1, #array do
		if pred(array[k], k) then
			return k
		end
	end
end

function M.findLastIndex(array, pred)
	local key = M.findIndex(M.reverse(array), pred)

	if key then
		return #array - key + 1
	end
end

function M.addTop(array, ...)
	for k, v in ipairs({
		...
	}) do
		t_insert(array, 1, v)
	end

	return array
end

function M.prepend(array, ...)
	return M.append({
		...
	}, array)
end

function M.push(array, ...)
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

function M.shift(array, n)
	n = min(n or 1, #array)
	local ret = {}

	for i = 1, n do
		local retValue = array[1]
		ret[#ret + 1] = retValue

		t_remove(array, 1)
	end

	return unpack(ret)
end

function M.unshift(array, n)
	n = min(n or 1, #array)
	local ret = {}

	for i = 1, n do
		local retValue = array[#array]
		ret[#ret + 1] = retValue

		t_remove(array)
	end

	return unpack(ret)
end

function M.pull(array, ...)
	local values = {
		...
	}

	for i = #array, 1, -1 do
		local remval = false

		for k, rmValue in ipairs(values) do
			if remval == false and M.isEqual(array[i], rmValue) then
				t_remove(array, i)

				remval = true
			end
		end
	end

	return array
end

function M.removeRange(array, start, finish)
	start = start or 1
	finish = finish or #array

	if start > finish then
		error("start cannot be greater than finish.")
	end

	for i = finish, start, -1 do
		t_remove(array, i)
	end

	return array
end

function M.chunk(array, f)
	local ch = {}
	local ck = 0
	local prev, val = nil
	f = f or M.identity

	for k, v in ipairs(array) do
		val = f(v, k)

		if val ~= prev then
			ck = ck + 1
		end

		if prev == nil then
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

function M.slice(array, start, finish)
	local t = {}

	for k = start or 1, finish or #array do
		t[#t + 1] = array[k]
	end

	return t
end

function M.first(array, n)
	n = n or 1
	local t = {}

	for k = 1, n do
		t[k] = array[k]
	end

	return t
end

function M.initial(array, n)
	local l = #array
	n = n and l - min(n, l) or l - 1
	local t = {}

	for k = 1, n do
		t[k] = array[k]
	end

	return t
end

function M.last(array, n)
	local l = #array
	n = n and l - min(n - 1, l - 1) or 2
	local t = {}

	for k = n, l do
		t[#t + 1] = array[k]
	end

	return t
end

function M.rest(array, index)
	local t = {}

	for k = index or 1, #array do
		t[#t + 1] = array[k]
	end

	return t
end

function M.nth(array, index)
	return array[index]
end

function M.compact(array)
	local t = {}

	for k, v in pairs(array) do
		if v then
			t[#t + 1] = v
		end
	end

	return t
end

function M.flatten(array, shallow)
	shallow = shallow or false
	local new_flattened = nil
	local _flat = {}

	for key, value in ipairs(array) do
		if type(value) == "table" then
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

function M.difference(array, array2)
	if not array2 then
		return M.clone(array)
	end

	return M.select(array, function (value)
		return not M.include(array2, value)
	end)
end

function M.union(...)
	return M.unique(M.flatten({
		...
	}))
end

function M.intersection(...)
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

function M.disjoint(...)
	return #M.intersection(...) == 0
end

function M.symmetricDifference(array, array2)
	return M.difference(M.union(array, array2), M.intersection(array, array2))
end

function M.unique(array)
	local ret = {}

	for i = 1, #array do
		if not M.find(ret, array[i]) then
			ret[#ret + 1] = array[i]
		end
	end

	return ret
end

function M.isunique(array)
	return #array == #M.unique(array)
end

function M.duplicates(array)
	local dict = M.invert(array)
	local dups = {}

	for k, v in ipairs(array) do
		if dict[v] ~= k and not M.find(dups, v) then
			dups[#dups + 1] = v
		end
	end

	return dups
end

function M.zip(...)
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
			if array[i] ~= nil then
				_ans[i][#_ans[i] + 1] = array[i]
			end
		end
	end

	return _ans
end

function M.zipWith(f, ...)
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

function M.append(array, other)
	local t = {}

	for i, v in ipairs(array) do
		t[i] = v
	end

	for i, v in ipairs(other) do
		t[#t + 1] = v
	end

	return t
end

function M.interleave(...)
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

function M.interpose(array, value)
	for k = #array, 2, -1 do
		t_insert(array, k, value)
	end

	return array
end

function M.range(from, to, step)
	if from == nil and to == nil and step == nil then
		return {}
	elseif from ~= nil and to == nil and step == nil then
		step = signum(from)
		to = from
		from = signum(from)
	elseif from ~= nil and to ~= nil and step == nil then
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

function M.rep(value, n)
	local ret = {}

	for i = 1, n do
		ret[i] = value
	end

	return ret
end

function M.powerset(array)
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

function M.partition(array, n, pad)
	if n <= 0 then
		return
	end

	return wrap(function ()
		partgen(array, n or 1, yield, pad)
	end)
end

function M.overlapping(array, n, pad)
	if n <= 1 then
		return
	end

	return wrap(function ()
		partgen2(array, n or 2, yield, pad)
	end)
end

function M.aperture(array, n)
	if n <= 1 then
		return
	end

	return wrap(function ()
		partgen3(array, n or 2, yield)
	end)
end

function M.pairwise(array)
	return M.aperture(array, 2)
end

function M.permutation(array)
	return wrap(function ()
		permgen(array, #array, yield)
	end)
end

function M.concat(array, sep, i, j)
	return t_concat(M.map(array, tostring), sep, i, j)
end

function M.xprod(array, array2)
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

function M.xpairs(value, array)
	local xpairs = {}

	for k, v in ipairs(array) do
		xpairs[k] = {
			value,
			v
		}
	end

	return xpairs
end

function M.xpairsRight(value, array)
	local xpairs = {}

	for k, v in ipairs(array) do
		xpairs[k] = {
			v,
			value
		}
	end

	return xpairs
end

function M.sum(array)
	local s = 0

	for k, v in ipairs(array) do
		s = s + v
	end

	return s
end

function M.product(array)
	local p = 1

	for k, v in ipairs(array) do
		p = p * v
	end

	return p
end

function M.mean(array)
	return M.sum(array) / #array
end

function M.median(array)
	local t = M.sort(M.clone(array))
	local n = #t

	if n == 0 then
		return
	elseif n == 1 then
		return t[1]
	end

	local mid = ceil(n / 2)

	return n % 2 == 0 and (t[mid] + t[mid + 1]) / 2 or t[mid]
end

function M.noop()
	return
end

function M.identity(value)
	return value
end

function M.call(f, ...)
	return f(...)
end

function M.constant(value)
	return function ()
		return value
	end
end

function M.applySpec(specs)
	return function (...)
		local spec = {}

		for i, f in pairs(specs) do
			spec[i] = f(...)
		end

		return spec
	end
end

function M.thread(value, ...)
	local state = value
	local arg = {
		...
	}

	for k, t in ipairs(arg) do
		if type(t) == "function" then
			state = t(state)
		elseif type(t) == "table" then
			local f = t[1]

			t_remove(t, 1)

			state = M.reduce(t, f, state)
		end
	end

	return state
end

function M.threadRight(value, ...)
	local state = value
	local arg = {
		...
	}

	for k, t in ipairs(arg) do
		if type(t) == "function" then
			state = t(state)
		elseif type(t) == "table" then
			local f = t[1]

			t_remove(t, 1)
			t_insert(t, state)

			state = M.reduce(t, f)
		end
	end

	return state
end

function M.dispatch(...)
	local funcs = {
		...
	}

	return function (...)
		for k, f in ipairs(funcs) do
			local r = {
				f(...)
			}

			if #r > 0 then
				return unpack(r)
			end
		end
	end
end

function M.memoize(f)
	local _cache = setmetatable({}, {
		__mode = "kv"
	})

	return function (key)
		if _cache[key] == nil then
			_cache[key] = f(key)
		end

		return _cache[key]
	end
end

function M.unfold(f, seed)
	local t = {}
	local result = nil

	while true do
		result, seed = f(seed)

		if result ~= nil then
			t[#t + 1] = result
		else
			break
		end
	end

	return t
end

function M.once(f)
	local _internal = 0
	local _args = {}

	return function (...)
		_internal = _internal + 1

		if _internal <= 1 then
			_args = {
				...
			}
		end

		return f(unpack(_args))
	end
end

function M.before(f, count)
	local _internal = 0
	local _args = {}

	return function (...)
		_internal = _internal + 1

		if _internal <= count then
			_args = {
				...
			}
		end

		return f(unpack(_args))
	end
end

function M.after(f, count)
	local _limit = count
	local _internal = 0

	return function (...)
		_internal = _internal + 1

		if _limit <= _internal then
			return f(...)
		end
	end
end

function M.compose(...)
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

function M.pipe(value, ...)
	return M.compose(...)(value)
end

function M.complement(f)
	return function (...)
		return not f(...)
	end
end

function M.juxtapose(value, ...)
	local res = {}

	for i, func in ipairs({
		...
	}) do
		res[i] = func(value)
	end

	return unpack(res)
end

function M.wrap(f, wrapper)
	return function (...)
		return wrapper(f, ...)
	end
end

function M.times(iter, n)
	local results = {}

	for i = 1, n or 1 do
		results[i] = iter(i)
	end

	return results
end

function M.bind(f, v)
	return function (...)
		return f(v, ...)
	end
end

function M.bind2(f, v)
	return function (t, ...)
		return f(t, v, ...)
	end
end

function M.bindn(f, ...)
	local args = {
		...
	}

	return function (...)
		return f(unpack(M.append(args, {
			...
		})))
	end
end

function M.bindall(obj, ...)
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

function M.cond(conds)
	return function (...)
		for k, condset in ipairs(conds) do
			if condset[1](...) then
				return condset[2](...)
			end
		end
	end
end

function M.both(...)
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

function M.either(...)
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

function M.neither(...)
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

function M.uniqueId(template)
	unique_id_counter = unique_id_counter + 1

	if template then
		if type(template) == "string" then
			return template:format(unique_id_counter)
		elseif type(template) == "function" then
			return template(unique_id_counter)
		end
	end

	return unique_id_counter
end

function M.iterator(f, value, n)
	local cnt = 0

	return function ()
		cnt = cnt + 1

		if n and n < cnt then
			return
		end

		value = f(value)

		return value
	end
end

function M.skip(iter, n)
	for i = 1, n or 1 do
		if iter() == nil then
			return
		end
	end

	return iter
end

function M.tabulate(...)
	local r = {}

	for v in ... do
		r[#r + 1] = v
	end

	return r
end

function M.iterlen(...)
	local l = 0

	for v in ... do
		l = l + 1
	end

	return l
end

function M.castArray(value)
	return type(value) ~= "table" and {
		value
	} or value
end

function M.flip(f)
	return function (...)
		return f(unpack(M.reverse({
			...
		})))
	end
end

function M.nthArg(n)
	return function (...)
		local args = {
			...
		}

		return args[n < 0 and #args + n + 1 or n]
	end
end

function M.unary(f)
	return function (...)
		local args = {
			...
		}

		return f(args[1])
	end
end

function M.ary(f, n)
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

function M.noarg(f)
	return function ()
		return f()
	end
end

function M.rearg(f, indexes)
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

function M.over(...)
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

function M.overEvery(...)
	local f = M.over(...)

	return function (...)
		return M.reduce(f(...), function (state, v)
			return state and v
		end)
	end
end

function M.overSome(...)
	local f = M.over(...)

	return function (...)
		return M.reduce(f(...), function (state, v)
			return state or v
		end)
	end
end

function M.overArgs(f, ...)
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

function M.converge(f, g, h)
	return function (...)
		return f(g(...), h(...))
	end
end

function M.partial(f, ...)
	local partial_args = {
		...
	}

	return function (...)
		local n_args = {
			...
		}
		local f_args = {}

		for k, v in ipairs(partial_args) do
			f_args[k] = v == "_" and M.shift(n_args) or v
		end

		return f(unpack(M.append(f_args, n_args)))
	end
end

function M.partialRight(f, ...)
	local partial_args = {
		...
	}

	return function (...)
		local n_args = {
			...
		}
		local f_args = {}

		for k = 1, #partial_args do
			f_args[k] = partial_args[k] == "_" and M.shift(n_args) or partial_args[k]
		end

		return f(unpack(M.append(n_args, f_args)))
	end
end

function M.curry(f, n_args)
	n_args = n_args or 2
	local _args = {}

	local function scurry(v)
		if n_args == 1 then
			return f(v)
		end

		if v ~= nil then
			_args[#_args + 1] = v
		end

		if #_args < n_args then
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

function M.time(f, ...)
	local stime = clock()
	local r = {
		f(...)
	}

	return clock() - stime, unpack(r)
end

function M.keys(obj)
	local keys = {}

	for key in pairs(obj) do
		keys[#keys + 1] = key
	end

	return keys
end

function M.values(obj)
	local values = {}

	for key, value in pairs(obj) do
		values[#values + 1] = value
	end

	return values
end

function M.path(obj, ...)
	local value = obj
	local path = {
		...
	}

	for i, p in ipairs(path) do
		if value[p] == nil then
			return
		end

		value = value[p]
	end

	return value
end

function M.spreadPath(obj, ...)
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

function M.flattenPath(obj, ...)
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

function M.kvpairs(obj)
	local t = {}

	for k, v in pairs(obj) do
		t[#t + 1] = {
			k,
			v
		}
	end

	return t
end

function M.toObj(kvpairs)
	local obj = {}

	for k, v in ipairs(kvpairs) do
		obj[v[1]] = v[2]
	end

	return obj
end

function M.invert(obj)
	local _ret = {}

	for k, v in pairs(obj) do
		_ret[v] = k
	end

	return _ret
end

function M.property(key)
	return function (obj)
		return obj[key]
	end
end

function M.propertyOf(obj)
	return function (key)
		return obj[key]
	end
end

function M.toBoolean(value)
	return not not value
end

function M.extend(destObj, ...)
	local sources = {
		...
	}

	for k, source in ipairs(sources) do
		if type(source) == "table" then
			for key, value in pairs(source) do
				destObj[key] = value
			end
		end
	end

	return destObj
end

function M.functions(obj, recurseMt)
	obj = obj or M
	local _methods = {}

	for key, value in pairs(obj) do
		if type(value) == "function" then
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

function M.clone(obj, shallow)
	if type(obj) ~= "table" then
		return obj
	end

	local _obj = {}

	for i, v in pairs(obj) do
		if type(v) == "table" then
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

function M.tap(obj, f)
	f(obj)

	return obj
end

function M.has(obj, key)
	return obj[key] ~= nil
end

function M.pick(obj, ...)
	local whitelist = M.flatten({
		...
	})
	local _picked = {}

	for key, property in pairs(whitelist) do
		if obj[property] ~= nil then
			_picked[property] = obj[property]
		end
	end

	return _picked
end

function M.omit(obj, ...)
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

function M.template(obj, template)
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

function M.isEqual(objA, objB, useMt)
	local typeObjA = type(objA)
	local typeObjB = type(objB)

	if typeObjA ~= typeObjB then
		return false
	end

	if typeObjA ~= "table" then
		return objA == objB
	end

	local mtA = getmetatable(objA)
	local mtB = getmetatable(objB)

	if useMt and (mtA or mtB) and (mtA.__eq or mtB.__eq) then
		return mtA.__eq(objA, objB) or mtB.__eq(objB, objA) or objA == objB
	end

	if M.size(objA) ~= M.size(objB) then
		return false
	end

	local vB = nil

	for i, vA in pairs(objA) do
		vB = objB[i]

		if vB == nil or not M.isEqual(vA, vB, useMt) then
			return false
		end
	end

	for i in pairs(objB) do
		if objA[i] == nil then
			return false
		end
	end

	return true
end

function M.result(obj, method)
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

function M.isTable(t)
	return type(t) == "table"
end

function M.isCallable(obj)
	return type(obj) == "function" or type(obj) == "table" and getmetatable(obj) and getmetatable(obj).__call ~= nil or false
end

function M.isArray(obj)
	if type(obj) ~= "table" then
		return false
	end

	local i = 0

	for k in pairs(obj) do
		i = i + 1

		if obj[i] == nil then
			return false
		end
	end

	return true
end

function M.isIterable(obj)
	return M.toBoolean(pcall(pairs, obj))
end

function M.type(obj)
	local tp = type(obj)

	if tp == "userdata" then
		local mt = getmetatable(obj)
		local stdout = io and io.stdout or nil

		if stdout ~= nil and mt == getmetatable(stdout) then
			return "file"
		end
	end

	return tp
end

function M.isEmpty(obj)
	if obj == nil then
		return true
	end

	if type(obj) == "string" then
		return #obj == 0
	end

	if type(obj) == "table" then
		return next(obj) == nil
	end

	return true
end

function M.isString(obj)
	return type(obj) == "string"
end

function M.isFunction(obj)
	return type(obj) == "function"
end

function M.isNil(obj)
	return obj == nil
end

function M.isNumber(obj)
	return type(obj) == "number"
end

function M.isNaN(obj)
	return type(obj) == "number" and obj ~= obj
end

function M.isFinite(obj)
	if type(obj) ~= "number" then
		return false
	end

	return obj > -huge and obj < huge
end

function M.isBoolean(obj)
	return type(obj) == "boolean"
end

function M.isInteger(obj)
	return type(obj) == "number" and floor(obj) == obj
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

local function new(value)
	return setmetatable({
		_wrapped = true,
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

function Moses.chain(value)
	return new(value)
end

function Moses:value()
	return self._value
end

f.value = Moses.value
f.chain = Moses.chain

for fname, fct in pairs(M) do
	if fname ~= "operator" then
		f[fname] = function (v, ...)
			local wrapped = type(v) == "table" and rawget(v, "_wrapped") or false

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

function f.import(context, noConflict)
	context = context or _ENV or _G
	local funcs = M.functions()

	for k, fname in ipairs(funcs) do
		if rawget(context, fname) ~= nil then
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
