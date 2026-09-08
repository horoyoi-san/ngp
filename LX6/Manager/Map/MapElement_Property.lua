-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapElement_Property.lua
-- Decompiled from: 00189_MapElement_Property.lua_589e33ff0c15.luajit

local M = MapElement

local GenModelMetatable = function()
	local meta = {}

	meta.__index = function(t, k)
		local element = t.__elem

		return element._GetProp(element, t, k)
	end

	meta.__newindex = function(t, k, v)
		local element = t.__elem

		element._SetProp(element, t, k, v)
	end

	return meta
end

M.__mDataMT = GenModelMetatable()

M._GetProp = function(self, t, k)
	local v = rawget(t, k)

	if v == nil then
		return v
	end

	local bindData = rawget(t, "__data")

	return rawget(bindData, k)
end

M._SetProp = function(self, t, k, v)
	local bindData = rawget(t, "__data")

	if rawget(bindData, k) ~= v then
		return
	end

	rawset(bindData, k, v)

	local elem = rawget(t, "__elem")

	elem._SetDirty(elem)
end
