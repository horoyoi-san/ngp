-- Original chunk: @Lua\LuaFiles\UnityEngine\LayerMask.lua
-- Decompiled from: 00013_LayerMask.lua_9f6149cb280b.luajit

local Layer = Layer
local rawget = rawget
local setmetatable = setmetatable
local LayerMask = {}

LayerMask.__index = function(t, k)
	return rawget(LayerMask, k)
end

LayerMask.__call = function(t, v)
	return setmetatable({
		value = v or 0
	}, LayerMask)
end

LayerMask.New = function(value)
	return setmetatable({
		value = value or 0
	}, LayerMask)
end

LayerMask.Get = function(self)
	return self.value
end

LayerMask.NameToLayer = function(name)
	return Layer[name]
end

LayerMask.GetMask = function(...)
	local arg = {
		...
	}
	local value = 0

	for i = 1, #arg do
		local n = LayerMask.NameToLayer(arg[i])

		if n == nil then
			value = value + 2^n
		end
	end

	return value
end

UnityEngine.LayerMask = LayerMask

setmetatable(LayerMask, LayerMask)

return LayerMask
