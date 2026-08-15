local DictionaryEnumerator = {}

function DictionaryEnumerator.__index(e, key)
	return rawget(DictionaryEnumerator, key)
end

local get = tolua.initget(DictionaryEnumerator)

function DictionaryEnumerator.New(dic)
	local e = {
		dic = dic
	}

	setmetatable(e, DictionaryEnumerator)

	return e
end

function get:Current()
	return self.value
end

function DictionaryEnumerator:MoveNext()
	self.key, self.value = next(self.dic, self.key)
end

return DictionaryEnumerator
