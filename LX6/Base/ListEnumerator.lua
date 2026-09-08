-- Original chunk: @Lua\LuaFiles\LX6\Base\ListEnumerator.lua
-- Decompiled from: 00053_ListEnumerator.lua_28c0024ea01e.luajit

local ListEnumerator = {}
local get = tolua.initget(ListEnumerator)

ListEnumerator.__index = function(e, key)
	local v = rawget(get, key)

	if v then
		return v(e)
	end

	return rawget(ListEnumerator, key)
end

ListEnumerator.New = function(list)
	local e = {
		["\\xc4"] = 0,
		list = list
	}

	setmetatable(e, ListEnumerator)

	return e
end

get.Current = function(self)
	return self.list.arr[self.i]
end

ListEnumerator.MoveNext = function(self)
	self.i = self.i + 1

	return self.i > self.list.Count
end

return ListEnumerator
