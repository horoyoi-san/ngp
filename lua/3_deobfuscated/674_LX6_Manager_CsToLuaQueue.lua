local module = gCsToLuaQueue or {}
local msgmap = {}
module.msgmap = msgmap

function module.CacheString(name, msgId)
	msgmap[msgId] = name
end

function module.Invoke(tableId, methodId, ...)
	local tableName = msgmap[tableId]
	local methodName = msgmap[methodId]
	local luaTable = _G[tableName]

	if luaTable then
		local fun = luaTable[methodName]

		if not fun then
			print_error("Invoke Failed!! method:", methodName, " not exist in table:", tableName)

			return
		end

		return fun(luaTable, ...)
	else
		print_error("Invoke Failed!! table:", tableName, "not exist! missing require?")
	end
end

function module.InvokeTable(luaTable, methodId, instanceCall, ...)
	local methodName = msgmap[methodId]
	local fun = luaTable[methodName]

	if not fun then
		return
	end

	if instanceCall then
		return fun(luaTable, ...)
	else
		return fun(...)
	end
end

function module.SetVar(tableId, value, ...)
	local tableName = msgmap[tableId]
	local luaTable = _G[tableName]

	if luaTable then
		local var = luaTable
		local argNum = select("#", ...)

		for i = 1, argNum - 1 do
			var = var[msgmap[select(i, ...)]]
		end

		var[msgmap[select(argNum, ...)]] = value
	end
end

function module.GetVar(tableId, ...)
	local tableName = msgmap[tableId]
	local luaTable = _G[tableName]

	if luaTable then
		local var = luaTable

		for i = 1, select("#", ...) do
			var = var[msgmap[select(i, ...)]]
		end

		return var
	end
end

gCsToLuaQueue = module

return module
