-- Original chunk: @Lua\LuaFiles\LX6\Base\ArrayEnumerator.lua
-- Decompiled from: 00040_ArrayEnumerator.lua_43276c9192fb.luajit

local ArrayEnumerator = {}

ArrayEnumerator.__index = function(e, key)
	return rawget(ArrayEnumerator, key)
end

local get = tolua.initget(ArrayEnumerator)

ArrayEnumerator.New = function(list)
	local e = {
		["\\xc4"] = -1,
		list = list
	}

	setmetatable(e, ArrayEnumerator)

	return e
end

get.Current = function(self)
	return self.list[self.i]
end

ArrayEnumerator.MoveNext = function(self)
	self.i = self.i + 1
end

return ArrayEnumerator
