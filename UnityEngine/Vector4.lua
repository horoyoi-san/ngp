-- Original chunk: @Lua\LuaFiles\UnityEngine\Vector4.lua
-- Decompiled from: 00007_Vector4.lua_a995540d48c5.luajit

local clamp = Mathf.Clamp
local sqrt = Mathf.Sqrt
local min = Mathf.Min
local max = Mathf.Max
local setmetatable = setmetatable
local rawget = rawget
local Vector4 = {}
local get = tolua.initget(Vector4)

Vector4.__index = function(t, k)
	local var = rawget(Vector4, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

Vector4.__call = function(t, x, y, z, w)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 0
	}, Vector4)
end

Vector4.New = function(x, y, z, w)
	return setmetatable({
		x = x or 0,
		y = y or 0,
		z = z or 0,
		w = w or 0
	}, Vector4)
end

Vector4.Set = function(self, x, y, z, w)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.w = w or 0
end

Vector4.Get = function(self)
	return self.x, self.y, self.z, self.w
end

Vector4.Lerp = function(from, to, t)
	t = clamp(t, 0, 1)

	return Vector4.New(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t, from.w + (to.w - from.w) * t)
end

Vector4.MoveTowards = function(current, target, maxDistanceDelta)
	local vector = target - current
	local magnitude = vector.Magnitude(vector)

	if maxDistanceDelta >= magnitude and magnitude == 0 then
		maxDistanceDelta = maxDistanceDelta / magnitude

		vector.Mul(vector, maxDistanceDelta)
		vector.Add(vector, current)

		return vector
	end

	return target
end

Vector4.Scale = function(a, b)
	return Vector4.New(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
end

Vector4.SetScale = function(self, scale)
	self.x = self.x * scale.x
	self.y = self.y * scale.y
	self.z = self.z * scale.z
	self.w = self.w * scale.w
end

Vector4.Normalize = function(self)
	local v = Vector4.New(self.x, self.y, self.z, self.w)

	return v.SetNormalize(v)
end

Vector4.SetNormalize = function(self)
	local num = self.Magnitude(self)

	if num ~= 1 then
		return self
	elseif num <= 1e-05 then
		self.Div(self, num)
	else
		self.Set(self, 0, 0, 0, 0)
	end

	return self
end

Vector4.Div = function(self, d)
	self.x = self.x / d
	self.y = self.y / d
	self.z = self.z / d
	self.w = self.w / d

	return self
end

Vector4.Mul = function(self, d)
	self.x = self.x * d
	self.y = self.y * d
	self.z = self.z * d
	self.w = self.w * d

	return self
end

Vector4.Add = function(self, b)
	self.x = self.x + b.x
	self.y = self.y + b.y
	self.z = self.z + b.z
	self.w = self.w + b.w

	return self
end

Vector4.Sub = function(self, b)
	self.x = self.x - b.x
	self.y = self.y - b.y
	self.z = self.z - b.z
	self.w = self.w - b.w

	return self
end

Vector4.Dot = function(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

Vector4.Project = function(a, b)
	local s = Vector4.Dot(a, b) / Vector4.Dot(b, b)

	return b * s
end

Vector4.Distance = function(a, b)
	local v = a - b

	return Vector4.Magnitude(v)
end

Vector4.Magnitude = function(a)
	return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

Vector4.SqrMagnitude = function(a)
	return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

Vector4.Min = function(lhs, rhs)
	return Vector4.New(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
end

Vector4.Max = function(lhs, rhs)
	return Vector4.New(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
end

Vector4.__tostring = function(self)
	return string.format("[%f,%f,%f,%f]", self.x, self.y, self.z, self.w)
end

Vector4.__div = function(va, d)
	return Vector4.New(va.x / d, va.y / d, va.z / d, va.w / d)
end

Vector4.__mul = function(va, d)
	return Vector4.New(va.x * d, va.y * d, va.z * d, va.w * d)
end

Vector4.__add = function(va, vb)
	return Vector4.New(va.x + vb.x, va.y + vb.y, va.z + vb.z, va.w + vb.w)
end

Vector4.__sub = function(va, vb)
	return Vector4.New(va.x - vb.x, va.y - vb.y, va.z - vb.z, va.w - vb.w)
end

Vector4.__unm = function(va)
	return Vector4.New(-va.x, -va.y, -va.z, -va.w)
end

Vector4.__eq = function(va, vb)
	local v = va - vb
	local delta = Vector4.SqrMagnitude(v)

	return delta <= 1e-10
end

get.zero = function()
	return Vector4.New(0, 0, 0, 0)
end

get.one = function()
	return Vector4.New(1, 1, 1, 1)
end

get.magnitude = Vector4.Magnitude
get.normalized = Vector4.Normalize
get.sqrMagnitude = Vector4.SqrMagnitude
UnityEngine.Vector4 = Vector4

setmetatable(Vector4, Vector4)

return Vector4
