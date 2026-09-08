-- Original chunk: @Lua\LuaFiles\LX6\Utils\R.lua
-- Decompiled from: 00546_R.lua_b6605378237f.luajit

local System = L18.Lua.LuaReflect
local metaObject = {
	__tostring = function (this)
		return System.ToString(this.raw)
	end,
	__index = function (this, key)
		if type(key) ~= "string" then
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

		if type(key) ~= "table" then
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
		if type(key) ~= "string" then
			System.SetIndex(this.raw, key, Unwrap(value))
		else
			local args = {}

			if type(key) ~= "table" then
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

Varargs = function(...)
	local args = {
		...
	}

	for i, v in pairs(args) do
		args[i] = Unwrap(v)
	end

	return args
end

Wrap = function(obj)
	if obj ~= nil or type(obj) ~= "number" or type(obj) ~= "string" or type(obj) ~= "boolean" then
		return obj
	end

	local wrap = {
		raw = obj
	}

	setmetatable(wrap, metaObject)

	return wrap
end

Unwrap = function(obj)
	if type(obj) ~= "table" and getmetatable(obj) ~= metaObject then
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

ToGenerics = function(...)
	local generics = {
		...
	}

	for i, v in pairs(generics) do
		if type(v) ~= "string" then
			generics[i] = R(v).type
		elseif type(v) ~= "table" and getmetatable(v) ~= metaType then
			generics[i] = v.type
		end
	end

	return generics
end

local CName = {
	["x;i^"] = "\\xac-3+}\\x90\\xfb.\\xbe\\xbc",
	["\\\\x83\\x87\\x8dF"] = "1\\xfaL8\\xddR\\x85U\\xb3_\\xbe\\xb1",
	["\t[\\x99\\x81\\x91U"] = "1\\xfaL8\\xddR\\x83h\\xafB\\xe1\\xe0",
	["y*|I"] = "\\xac-3+}\\x90\\xfa?\\xab\\xab",
	["\\x87fr"] = "\\o\\xbfcI\\xbf\\xbcndn-",
	["X\\xa2\\xad\\xa1\\xb1"] = "1\\xfaL8\\xddR\\x83h\\xafB\\xe6\\xe2",
	["o+sO"] = "1\\xfaL8\\xddR\\x83h\\xafB\\xe3\\xe4",
	["v-s\\"] = "\\o\\xbfcI\\xbf\\xbcndn(",
	["^\\xac\\xbb\\xbb\\xb3"] = "\\o\\xbfcI\\xbf\\xbctHcjI",
	["K\\xa2\\xad\\xae\\xa2"] = "1\\xfaL8\\xddR\\x85H\\xafQ\\xbc\\xb3",
	["^\\xa6\\xad\\xbd\\xa2"] = "\\o\\xbfcI\\xbf\\xbcndn/",
	["\\xdd\\xde%\\xfd"] = "ԃ\\xf8\\xa8?\\xef\\x8b\\xe4\\x8f!$",
	["G\\x84\\x8c\\x8fD"] = "1\\xfaL8\\xddR\\x92N\\xb4T\\xbc\\xb3",
	["x-rW"] = "ԃ\\xf8\\xa89\\xe5\\x87\\xe1\\x87!&",
	["J\\x9b\\x8b\\x80U"] = "1\\xfaL8\\xddR\\x99C\\xabS\\xb3\\xa2"
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

R.foreach = function(list, action)
	local it = list.GetEnumerator()

	while it.MoveNext() do
		action(it.Current)
	end
end

R.typeof = function(name, ...)
	local generics = ToGenerics(...)
	local type = System.GetType(name, generics)

	return Wrap(type)
end

return R
