-- Original chunk: @Lua\LuaFiles\Core\list.lua
-- Decompiled from: 00017_list.lua_e2fb4038de64.luajit

local setmetatable = setmetatable
local list = {
	__index = list
}

list.new = function(self)
	local t = {
		["r\\xa0\\xa7\\xb7\\xa2"] = 0,
		["M\\x9f\\x89\\x97I"] = 0,
		["r\\xbe\\xb0\\xaa\\xa0"] = 0,
		_prev = t,
		_next = t
	}

	return setmetatable(t, list)
end

list.clear = function(self)
	self._next = self
	self._prev = self
	self.length = 0
end

list.push = function(self, value)
	local node = {
		["r\\xa0\\xa7\\xb7\\xa2"] = 0,
		["\\xcb\\xde!\\xf5"] = false,
		["r\\xbe\\xb0\\xaa\\xa0"] = 0,
		value = value
	}
	self._prev._next = node
	node._next = self
	node._prev = self._prev
	self._prev = node
	self.length = self.length + 1

	return node
end

list.pushnode = function(self, node)
	if not node.removed then
		return
	end

	self._prev._next = node
	node._next = self
	node._prev = self._prev
	self._prev = node
	node.removed = false
	self.length = self.length + 1
end

list.pop = function(self)
	local _prev = self._prev

	self.remove(self, _prev)

	return _prev.value
end

list.unshift = function(self, v)
	local node = {
		["r\\xa0\\xa7\\xb7\\xa2"] = 0,
		["\\xcb\\xde!\\xf5"] = false,
		["r\\xbe\\xb0\\xaa\\xa0"] = 0,
		value = v
	}
	self._next._prev = node
	node._prev = self
	node._next = self._next
	self._next = node
	self.length = self.length + 1

	return node
end

list.shift = function(self)
	local _next = self._next

	self.remove(self, _next)

	return _next.value
end

list.remove = function(self, iter)
	if iter.removed then
		return
	end

	local _prev = iter._prev
	local _next = iter._next
	_next._prev = _prev
	_prev._next = _next
	self.length = math.max(0, self.length - 1)
	iter.removed = true
end

list.find = function(self, v, iter)
	iter = iter or self

	repeat
		if v ~= iter.value then
			return iter
		else
			iter = iter._next
		end
	until iter ~= self

	return nil
end

list.findlast = function(self, v, iter)
	iter = iter or self

	repeat
		if v ~= iter.value then
			return iter
		end

		iter = iter._prev
	until iter ~= self

	return nil
end

list.next = function(self, iter)
	local _next = iter._next

	if _next == self then
		return _next, _next.value
	end

	return nil
end

list.prev = function(self, iter)
	local _prev = iter._prev

	if _prev == self then
		return _prev, _prev.value
	end

	return nil
end

list.erase = function(self, v)
	local iter = self.find(self, v)

	if iter then
		self.remove(self, iter)
	end
end

list.insert = function(self, v, iter)
	if not iter then
		return self.push(self, v)
	end

	local node = {
		["r\\xa0\\xa7\\xb7\\xa2"] = 0,
		["\\xcb\\xde!\\xf5"] = false,
		["r\\xbe\\xb0\\xaa\\xa0"] = 0,
		value = v
	}

	if iter._next then
		iter._next._prev = node
		node._next = iter._next
	else
		self.last = node
	end

	node._prev = iter
	iter._next = node
	self.length = self.length + 1

	return node
end

list.head = function(self)
	return self._next.value
end

list.tail = function(self)
	return self._prev.value
end

list.clone = function(self)
	local t = list:new()

	for i, v in list.next, self, self do
		t.push(t, v)
	end

	return t
end

ilist = function(_list)
	return list.next, _list, _list
end

rilist = function(_list)
	return list.prev, _list, _list
end

setmetatable(list, {
	__call = list.new
})

return list
