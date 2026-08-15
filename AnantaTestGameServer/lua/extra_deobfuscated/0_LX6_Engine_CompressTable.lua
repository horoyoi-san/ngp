local module = {
	MetaTableMap = {}
}
local rawget = rawget
local rawset = rawset
local DefaultBaseTable = {
	__index = function (obj, key)
		if not rawget(obj, "default") then
			return nil
		end

		return rawget(obj.default, key)
	end,
	__newindex = function (obj, key, val)
		if not obj.default then
			rawset(obj, "default", {})
		end

		rawset(obj.default, key, val)
	end
}

function module.CreateMetaTable(name)
	local cache = module.MetaTableMap[name]

	if cache then
		return cache
	end

	local mt = {}

	setmetatable(mt, DefaultBaseTable)
	rawset(mt, "__index", function (obj, key)
		return rawget(mt.default, key)
	end)

	module.MetaTableMap[name] = mt

	return mt
end

return module
