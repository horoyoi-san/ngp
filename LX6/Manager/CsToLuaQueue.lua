-- Original chunk: @Lua\LuaFiles\LX6\Manager\CsToLuaQueue.lua
-- Decompiled from: 02282_CsToLuaQueue.lua_01f4f91dcdba.luajit

local module = gCsToLuaQueue or {}
local msgmap = {}
module.msgmap = msgmap

module.CacheString = function(name, msgId)
	msgmap[msgId] = name
end

module.Invoke = function(tableId, methodId, ...)
	local tableName = msgmap[tableId]
	local methodName = msgmap[methodId]
	local luaTable = _G[tableName]

	if luaTable then
		local fun = luaTable[methodName]

		if not fun then
			print_error("Invoke Failed!! method:", methodName, " not exist in table:", tableName, "tableId:", tableId, "methodId:", methodId)

			return
		end

		return fun(luaTable, ...)
	else
		print_error("Invoke Failed!! table:", tableName, "not exist! missing require?")
	end
end

module.InvokeTable = function(luaTable, methodId, instanceCall, ...)
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

module.SetVar = function(tableId, value, ...)
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

module.GetVar = function(tableId, ...)
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
