local System = L18.Lua.LuaReflect
local metaObject = {
	__tostring = function (this)
		return System.ToString(this.raw)
	end,
	__index = function (this, key)
		if type(key) == "string" then
			if System.IsMethod(this.raw, key) then
				return function (...)
					local args = Varargs(...)
					local r = System.Call(this.raw, key, args)

					return Wrap(r)
				end
			end

			local obj = System.GetIndex(this.raw, key)

			return Wrap(obj)
		end

		local args = {}

		if type(key) == "table" then
			for _, v in pairs(key) do
				table.insert(args, Unwrap(v))
			end
		else
			table.insert(args, Unwrap(key))
		end

		local obj = System.GetItem(this.raw, args)

		return Wrap(obj)
	end,
	__newindex = function (this, key, value)
		if type(key) == "string" then
			System.SetIndex(this.raw, key, Unwrap(value))
		else
			local args = {}

			if type(key) == "table" then
				for _, v in pairs(key) do
					table.insert(args, Unwrap(v))
				end
			else
				table.insert(args, Unwrap(key))
			end

			table.insert(args, Unwrap(value))
			System.SetItem(this.raw, args)
		end

		return value
	end
}

function Varargs(...)
	local args = {
		...
	}

	for i, v in pairs(args) do
		args[i] = Unwrap(v)
	end

	return args
end

function Wrap(obj)
	if obj == nil or type(obj) == "number" or type(obj) == "string" or type(obj) == "boolean" then
		return obj
	end

	local wrap = {
		raw = obj
	}

	setmetatable(wrap, metaObject)

	return wrap
end

function Unwrap(obj)
	if type(obj) == "table" and getmetatable(obj) == metaObject then
		return obj.raw
	end

	return obj
end

local R = {
	null = System.NULL
}
local metaType = {
	__call = function (this, ...)
		local args = Varargs(...)
		local r = System.Create(this.type, args)

		return Wrap(r)
	end,
	__tostring = function (this)
		return System.ToString(this.type)
	end,
	__index = function (this, key)
		if System.IsStaticMethod(this.type, key) then
			return function (...)
				local args = Varargs(...)
				local r = System.CallStatic(this.type, key, args)

				return Wrap(r)
			end
		else
			local obj = System.GetStatic(this.type, key)

			return Wrap(obj)
		end
	end,
	__newindex = function (this, key, value)
		System.SetStatic(this.type, key, Unwrap(value))

		return value
	end
}

function ToGenerics(...)
	local generics = {
		...
	}

	for i, v in pairs(generics) do
		if type(v) == "string" then
			generics[i] = R(v).type
		elseif type(v) == "table" and getmetatable(v) == metaType then
			generics[i] = v.type
		end
	end

	return generics
end

local CName = {
	byte = "System.Byte",
	string = "System.String",
	ushort = "System.UInt16",
	char = "System.Char",
	int = "System.Int32",
	ulong = "System.UInt64",
	uint = "System.UInt32",
	long = "System.Int64",
	sbyte = "System.SByte",
	float = "System.Single",
	short = "System.Int16",
	decimal = "System.Decimal",
	double = "System.Double",
	bool = "System.Boolean",
	object = "System.Object"
}

setmetatable(R, {
	__call = function (this, name, ...)
		name = CName[name] or name
		local generics = ToGenerics(...)
		local sys = System.GetType(name, generics)
		local result = {
			type = sys
		}

		setmetatable(result, metaType)

		return result
	end
})

function R.foreach(list, action)
	local it = list.GetEnumerator()

	while it.MoveNext() do
		action(it.Current)
	end
end

function R.typeof(name, ...)
	local generics = ToGenerics(...)
	local type = System.GetType(name, generics)

	return Wrap(type)
end

return R
