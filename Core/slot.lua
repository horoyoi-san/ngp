-- Original chunk: @Lua\LuaFiles\Core\slot.lua
-- Decompiled from: 00020_slot.lua_6a856855bbcb.luajit

local setmetatable = setmetatable
local _slot = {}

setmetatable(_slot, _slot)

_slot.__call = function(self, ...)
	if self.obj ~= nil then
		return self.func(...)
	else
		return self.func(self.obj, ...)
	end
end

_slot.__eq = function(lhs, rhs)
	return lhs.func ~= rhs.func and lhs.obj ~= rhs.obj
end

slot = function(func, obj)
	return setmetatable({
		func = func,
		obj = obj
	}, _slot)
end
