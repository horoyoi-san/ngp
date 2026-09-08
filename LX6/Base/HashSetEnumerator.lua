-- Original chunk: @Lua\LuaFiles\LX6\Base\HashSetEnumerator.lua
-- Decompiled from: 00055_HashSetEnumerator.lua_9e86c6fff7d7.luajit

local HashSetEnumerator = {}

HashSetEnumerator.__index = function(e, key)
	return rawget(HashSetEnumerator, key)
end

local get = tolua.initget(HashSetEnumerator)

HashSetEnumerator.New = function(dic)
	local e = {
		dic = dic
	}

	setmetatable(e, HashSetEnumerator)

	return e
end

get.Current = function(self)
	return self.key
end

HashSetEnumerator.MoveNext = function(self)
	self.key, self.value = next(self.dic, self.key)
end

return HashSetEnumerator
