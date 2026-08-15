local HashSetEnumerator = {}

function HashSetEnumerator.__index(e, key)
	return rawget(HashSetEnumerator, key)
end

local get = tolua.initget(HashSetEnumerator)

function HashSetEnumerator.New(dic)
	local e = {
		dic = dic
	}

	setmetatable(e, HashSetEnumerator)

	return e
end

function get:Current()
	return self.key
end

function HashSetEnumerator:MoveNext()
	self.key, self.value = next(self.dic, self.key)
end

return HashSetEnumerator
