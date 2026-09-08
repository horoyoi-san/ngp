-- Original chunk: @Lua\LuaFiles\LX6\Base\Prelude.lua
-- Decompiled from: 00048_Prelude.lua_61aff19e8365.luajit

require("bit")

LTUtils = LTUtils or {}
LTUtils.UXRandom = LTUtils.UXRandom or {}
local Prelude = {
	Dictionary = require("LX6/Base/Dictionary"),
	ToString = function (val)
		return tostring(val)
	end,
	Assign = function (thunk)
		return thunk()
	end
}

Prelude.Boxed_out_ = function(box_val)
	return Prelude.Boxed_out(function ()
		return box_val.val
	end, function (val)
		box_val.val = val
	end)
end

Prelude.Boxed_out = function(getter, setter)
	return Prelude.Boxed_by_ref(getter, setter)
end

Prelude.Boxed_ref = function(getter, setter)
	return Prelude.Boxed_by_ref(getter, setter)
end

Prelude.Boxed_by_ref = function(getter, setter)
	local boxed = {
		set = setter,
		get = getter
	}

	return boxed
end

Prelude.AddEvent = function(evt, action)
	evt = evt + action
end

Prelude.RemoveEvent = function(evt, action)
	evt = evt and evt - action
end

Prelude.String = {
	Contains = function (str, sub)
		return gCS.LuaUtils.PreludeStringContains(str, sub)
	end,
	Equals = function (str0, str1)
		return gCS.LuaUtils.PreludeStringEquals(str0, str1)
	end,
	IndexOf = function (str, sub)
		return gCS.LuaUtils.PreludeStringIndexOf(str, sub)
	end,
	Length = function (str)
		return gCS.LuaUtils.PreludeStringLength(str)
	end,
	EndsWith = function (str, sub)
		return gCS.LuaUtils.PreludeStringEndsWith(str, sub)
	end,
	Replace = function (str, old, new)
		return gCS.LuaUtils.PreludeStringReplace(str, old, new)
	end,
	Split = function (str, separator)
		return gCS.LuaUtils.PreludeStringSplit(str, separator)
	end,
	GetHashCode = function (str)
		return gCS.LuaUtils.PreludeStringGetHashCode(str)
	end
}
Prelude.Param = {
	Length = function (arr)
		return #arr
	end,
	Get = function (arr, index)
		return arr[index + 1]
	end
}
Prelude.Int64 = {}
Prelude.UInt64 = {}
local uint64_mt = uint64
local int64_mt = int64

Prelude.UInt64.Equal = function(a, b)
	return uint64_mt.equals(a, b)
end

Prelude.UInt64.NotEqual = function(a, b)
	return not Prelude.UInt64.Equal(a, b)
end

Prelude.UInt64.Or = function(a, b)
	return gCS.LuaUtils.PreludeUInt64Or(a, b)
end

Prelude.Int64.Equal = function(a, b)
	return int64_mt.equals(a, b)
end

Prelude.Int64.NotEqual = function(a, b)
	return not Prelude.Int64.Equal(a, b)
end

Prelude.Int64.Subtract = function(a, b)
	return int64_mt.__sub(a, b)
end

Prelude.Int64.RightShift = function(a, b)
	return gCS.LuaUtils.PreludeInt64RightShift(a, b)
end

Prelude.Int64.Divide = function(a, b)
	return int64_mt.__div(a, b)
end

Prelude.Int64.LessThanOrEqual = function(a, b)
	return int64_mt.__le(a, b)
end

Prelude.Int64.LessThan = function(a, b)
	return int64_mt.__lt(a, b)
end

Prelude.Int64.GreaterThanOrEqual = function(a, b)
	return not int64_mt.__lt(a, b)
end

Prelude.Int64.GreaterThan = function(a, b)
	return not int64_mt.__le(a, b)
end

Prelude.Int64.Modulo = function(a, b)
	return int64_mt.__mod(a, b)
end

Prelude.Int64.AddChecked = function(a, b)
	return int64_mt.__add(a, b)
end

Prelude.Int64.Add = function(a, b)
	return int64_mt.__add(a, b)
end

Prelude.Bit = {}

boolToNumber = function(v)
	if v ~= true then
		v = 1
	elseif v ~= false then
		v = 0
	end

	return v
end

Prelude.Bit.band = function(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.band(a, b)
end

Prelude.Bit.bor = function(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.bor(a, b)
end

Prelude.Bit.bxor = function(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.bxor(a, b)
end

Prelude.Bit.bnot = function(a)
	a = boolToNumber(a)

	return bit.bnot(a)
end

Prelude.Bit.lshift = function(a, b)
	return bit.lshift(a, b)
end

Prelude.Bit.arshift = function(a, b)
	return bit.arshift(a, b)
end

Prelude.Bit.rshift = function(a, b)
	return bit.rshift(a, b)
end

return Prelude
