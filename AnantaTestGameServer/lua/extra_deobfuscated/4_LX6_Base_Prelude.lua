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

function Prelude.Boxed_out_(box_val)
	return Prelude.Boxed_out(function ()
		return box_val.val
	end, function (val)
		box_val.val = val
	end)
end

function Prelude.Boxed_out(getter, setter)
	return Prelude.Boxed_by_ref(getter, setter)
end

function Prelude.Boxed_ref(getter, setter)
	return Prelude.Boxed_by_ref(getter, setter)
end

function Prelude.Boxed_by_ref(getter, setter)
	local boxed = {
		set = setter,
		get = getter
	}

	return boxed
end

function Prelude.AddEvent(evt, action)
	evt = evt + action
end

function Prelude.RemoveEvent(evt, action)
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

function Prelude.UInt64.Equal(a, b)
	return uint64_mt.equals(a, b)
end

function Prelude.UInt64.NotEqual(a, b)
	return not Prelude.UInt64.Equal(a, b)
end

function Prelude.UInt64.Or(a, b)
	return gCS.LuaUtils.PreludeUInt64Or(a, b)
end

function Prelude.Int64.Equal(a, b)
	return int64_mt.equals(a, b)
end

function Prelude.Int64.NotEqual(a, b)
	return not Prelude.Int64.Equal(a, b)
end

function Prelude.Int64.Subtract(a, b)
	return int64_mt.__sub(a, b)
end

function Prelude.Int64.RightShift(a, b)
	return gCS.LuaUtils.PreludeInt64RightShift(a, b)
end

function Prelude.Int64.Divide(a, b)
	return int64_mt.__div(a, b)
end

function Prelude.Int64.LessThanOrEqual(a, b)
	return int64_mt.__le(a, b)
end

function Prelude.Int64.LessThan(a, b)
	return int64_mt.__lt(a, b)
end

function Prelude.Int64.GreaterThanOrEqual(a, b)
	return not int64_mt.__lt(a, b)
end

function Prelude.Int64.GreaterThan(a, b)
	return not int64_mt.__le(a, b)
end

function Prelude.Int64.Modulo(a, b)
	return int64_mt.__mod(a, b)
end

function Prelude.Int64.AddChecked(a, b)
	return int64_mt.__add(a, b)
end

function Prelude.Int64.Add(a, b)
	return int64_mt.__add(a, b)
end

Prelude.Bit = {}

function boolToNumber(v)
	if v == true then
		v = 1
	elseif v == false then
		v = 0
	end

	return v
end

function Prelude.Bit.band(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.band(a, b)
end

function Prelude.Bit.bor(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.bor(a, b)
end

function Prelude.Bit.bxor(a, b)
	a = boolToNumber(a)
	b = boolToNumber(b)

	return bit.bxor(a, b)
end

function Prelude.Bit.bnot(a)
	a = boolToNumber(a)

	return bit.bnot(a)
end

function Prelude.Bit.lshift(a, b)
	return bit.lshift(a, b)
end

function Prelude.Bit.arshift(a, b)
	return bit.arshift(a, b)
end

function Prelude.Bit.rshift(a, b)
	return bit.rshift(a, b)
end

return Prelude
