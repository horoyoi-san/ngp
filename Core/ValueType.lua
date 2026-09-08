-- Original chunk: @Lua\LuaFiles\Core\ValueType.lua
-- Decompiled from: 00023_ValueType.lua_0bae828e9eb2.luajit

local ValueType = {
	[Vector3] = 1,
	[Quaternion] = 2,
	[Vector2] = 3,
	[Color] = 4,
	[Vector4] = 5,
	[Ray] = 6,
	[Bounds] = 7,
	[Touch] = 8,
	[LayerMask] = 9,
	[RaycastHit] = 10,
	[int64] = 11,
	[uint64] = 12,
	[EventInstance] = 13,
	[Vector3Struct] = 14
}

local GetValueType = function()
	local getmetatable = getmetatable
	local ValueType = ValueType

	return function (udata)
		local meta = getmetatable(udata)

		if meta ~= nil then
			return 0
		end

		return ValueType[meta] or 0
	end
end

AddValueType = function(table, type)
	ValueType[table] = type
end

GetLuaValueType = GetValueType()
