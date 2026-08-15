local ListEnumerator = {}
local get = tolua.initget(ListEnumerator)

function ListEnumerator.__index(e, key)
	local v = rawget(get, key)

	if v then
		return v(e)
	end

	return rawget(ListEnumerator, key)
end

function ListEnumerator.New(list)
	local e = {
		i = 0,
		list = list
	}

	setmetatable(e, ListEnumerator)

	return e
end

function get:Current()
	return self.list.arr[self.i]
end

function ListEnumerator:MoveNext()
	self.i = self.i + 1

	return self.i <= self.list.Count
end

return ListEnumerator
