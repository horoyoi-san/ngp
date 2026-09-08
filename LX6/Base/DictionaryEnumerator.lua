-- Original chunk: @Lua\LuaFiles\LX6\Base\DictionaryEnumerator.lua
-- Decompiled from: 00050_DictionaryEnumerator.lua_42b65e875aff.luajit

local DictionaryEnumerator = {}

DictionaryEnumerator.__index = function(e, key)
	return rawget(DictionaryEnumerator, key)
end

local get = tolua.initget(DictionaryEnumerator)

DictionaryEnumerator.New = function(dic)
	local e = {
		dic = dic
	}

	setmetatable(e, DictionaryEnumerator)

	return e
end

get.Current = function(self)
	return self.value
end

DictionaryEnumerator.MoveNext = function(self)
	self.key, self.value = next(self.dic, self.key)
end

return DictionaryEnumerator
