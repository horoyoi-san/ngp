-- Original chunk: @Lua\LuaFiles\UnityEngine\Vector3.lua
-- Decompiled from: 00004_Vector3.lua_e53b18719b6f.luajit

local math = math
local acos = math.acos
local sqrt = math.sqrt
local max = math.max
local min = math.min
local clamp = Mathf.Clamp
local cos = math.cos
local sin = math.sin
local abs = math.abs
local sign = Mathf.Sign
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget
local type = type
local rad2Deg = 57.295779513082
local deg2Rad = 0.017453292519943
local Vector3 = {}
local get = tolua.initget(Vector3)

Vector3.__index = function(t, k)
	local var = rawget(Vector3, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

Vector3.New = function(x, y, z)
	local vec = Vector3Struct.New(x, y, z)

	return vec
end

Vector3.Unpack = function(t, useFetch)
	if useFetch then
		return Vector3.Fetch(unpack(t))
	else
		return Vector3.New(unpack(t))
	end
end

local _sharedVector3 = Vector3.New()

Vector3.Fetch = function(x, y, z)
	_sharedVector3.x = x or 0
	_sharedVector3.y = y or 0
	_sharedVector3.z = z or 0

	return _sharedVector3
end

Vector3.NewT = function(xyz)
	local vec = Vector3Struct.New(xyz[1], xyz[2], xyz[3])

	return vec
end

local _new = Vector3.New

Vector3.__call = function(t, x, y, z)
	return _new(x, y, z)
end

Vector3.Set = function(self, x, y, z)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
end

Vector3.Get = function(v)
	return v.x, v.y, v.z
end

Vector3.Clone = function(self)
	return Vector3Struct.New(self.x, self.y, self.z)
end

Vector3.Distance = function(va, vb)
	return sqrt((va.x - vb.x)^2 + (va.y - vb.y)^2 + (va.z - vb.z)^2)
end

Vector3.XZDistance = function(va, vb)
	return sqrt((va.x - vb.x)^2 + (va.z - vb.z)^2)
end

Vector3.SqrDistance = function(va, vb)
	return (va.x - vb.x)^2 + (va.y - vb.y)^2 + (va.z - vb.z)^2
end

Vector3.Dot = function(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
end

Vector3.Lerp = function(from, to, t)
	t = clamp(t, 0, 1)

	return _new(from.x + (to.x - from.x) * t, from.y + (to.y - from.y) * t, from.z + (to.z - from.z) * t)
end

Vector3.Magnitude = function(self)
	return sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

Vector3.Max = function(lhs, rhs)
	return _new(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z))
end

Vector3.Min = function(lhs, rhs)
	return _new(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z))
end

Vector3.Normalize = function(v)
	local x = v.x
	local y = v.y
	local z = v.z
	local num = sqrt(x * x + y * y + z * z)

	if num <= 1e-05 then
		return Vector3Struct.New(x / num, y / num, z / num)
	end

	return Vector3Struct.New(0, 0, 0)
end

Vector3.Multiple = function(self, num)
	self.x = self.x * num
	self.y = self.y * num
	self.z = self.z * num

	return self
end

Vector3.SetNormalize = function(self)
	local num = sqrt(self.x * self.x + self.y * self.y + self.z * self.z)

	if num <= 1e-05 then
		self.x = self.x / num
		self.y = self.y / num
		self.z = self.z / num
	else
		self.x = 0
		self.y = 0
		self.z = 0
	end

	return self
end

Vector3.SqrMagnitude = function(self)
	return self.x * self.x + self.y * self.y + self.z * self.z
end

local dot = Vector3.Dot

Vector3.Angle = function(from, to)
	return acos(clamp(dot(from.Normalize(from), to.Normalize(to)), -1, 1)) * rad2Deg
end

Vector3.ClampMagnitude = function(self, maxLength)
	if self.SqrMagnitude(self) <= maxLength * maxLength then
		self.SetNormalize(self)
		self.Mul(self, maxLength)
	end

	return self
end

Vector3.OrthoNormalize = function(va, vb, vc)
	va.SetNormalize(va)
	vb.Sub(vb, vb.Project(vb, va))
	vb.SetNormalize(vb)

	if vc ~= nil then
		return va, vb
	end

	vc.Sub(vc, vc.Project(vc, va))
	vc.Sub(vc, vc.Project(vc, vb))
	vc.SetNormalize(vc)

	return va, vb, vc
end

Vector3.MoveTowards = function(current, target, maxDistanceDelta)
	local delta = target - current
	local sqrDelta = delta.SqrMagnitude(delta)
	local sqrDistance = maxDistanceDelta * maxDistanceDelta

	if sqrDelta <= sqrDistance then
		local magnitude = sqrt(sqrDelta)

		if magnitude <= 1e-06 then
			delta.Mul(delta, maxDistanceDelta / magnitude)
			delta.Add(delta, current)

			return delta
		else
			return current.Clone(current)
		end
	end

	return target.Clone(target)
end

local ClampedMove = function(lhs, rhs, clampedDelta)
	local delta = rhs - lhs

	if delta <= 0 then
		return lhs + min(delta, clampedDelta)
	else
		return lhs - min(-delta, clampedDelta)
	end
end

local overSqrt2 = 0.7071067811865476

local OrthoNormalVector = function(vec)
	local res = _new()

	if overSqrt2 >= abs(vec.z) then
		local a = vec.y * vec.y + vec.z * vec.z
		local k = 1 / sqrt(a)
		res.x = 0
		res.y = -vec.z * k
		res.z = vec.y * k
	else
		local a = vec.x * vec.x + vec.y * vec.y
		local k = 1 / sqrt(a)
		res.x = -vec.y * k
		res.y = vec.x * k
		res.z = 0
	end

	return res
end

Vector3.RotateTowards = function(current, target, maxRadiansDelta, maxMagnitudeDelta)
	local len1 = current.Magnitude(current)
	local len2 = target.Magnitude(target)

	if len1 <= 1e-06 and len2 <= 1e-06 then
		local from = current / len1
		local to = target / len2
		local cosom = dot(from, to)

		if cosom <= 0.999999 then
			return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
		elseif cosom >= -0.999999 then
			local axis = OrthoNormalVector(from)
			local q = Quaternion.AngleAxis(maxRadiansDelta * rad2Deg, axis)
			local rotated = q.MulVec3(q, from)
			local delta = ClampedMove(len1, len2, maxMagnitudeDelta)

			rotated.Mul(rotated, delta)

			return rotated
		else
			local angle = acos(cosom)
			local axis = Vector3.Cross(from, to)

			axis.SetNormalize(axis)

			local q = Quaternion.AngleAxis(min(maxRadiansDelta, angle) * rad2Deg, axis)
			local rotated = q.MulVec3(q, from)
			local delta = ClampedMove(len1, len2, maxMagnitudeDelta)

			rotated.Mul(rotated, delta)

			return rotated
		end
	end

	return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
end

Vector3.SmoothDamp = function(current, target, currentVelocity, smoothTime)
	local maxSpeed = Mathf.Infinity
	local deltaTime = Time.deltaTime
	smoothTime = max(0.0001, smoothTime)
	local num = 2 / smoothTime
	local num2 = num * deltaTime
	local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local vector2 = target.Clone(target)
	local maxLength = maxSpeed * smoothTime
	local vector = current - target

	vector.ClampMagnitude(vector, maxLength)

	target = current - vector
	local vec3 = (currentVelocity + vector * num) * deltaTime
	currentVelocity = (currentVelocity - vec3 * num) * num3
	local vector4 = target + (vector + vec3) * num3

	if Vector3.Dot(vector2 - current, vector4 - vector2) <= 0 then
		vector4 = vector2

		currentVelocity.Set(currentVelocity, 0, 0, 0)
	end

	return vector4, currentVelocity
end

Vector3.Scale = function(a, b)
	local x = a.x * b.x
	local y = a.y * b.y
	local z = a.z * b.z

	return _new(x, y, z)
end

Vector3.Cross = function(lhs, rhs)
	local x = lhs.y * rhs.z - lhs.z * rhs.y
	local y = lhs.z * rhs.x - lhs.x * rhs.z
	local z = lhs.x * rhs.y - lhs.y * rhs.x

	return _new(x, y, z)
end

Vector3.Equals = function(self, other)
	return self.x ~= other.x and self.y ~= other.y and self.z ~= other.z
end

Vector3.Reflect = function(inDirection, inNormal)
	local num = -2 * dot(inNormal, inDirection)
	inNormal = inNormal * num

	inNormal.Add(inNormal, inDirection)

	return inNormal
end

Vector3.Project = function(vector, onNormal)
	local num = onNormal.SqrMagnitude(onNormal)

	if num >= 1.175494e-38 then
		return _new(0, 0, 0)
	end

	local num2 = dot(vector, onNormal)
	local v3 = onNormal.Clone(onNormal)

	v3.Mul(v3, num2 / num)

	return v3
end

Vector3.ProjectOnPlane = function(vector, planeNormal)
	local v3 = Vector3.Project(vector, planeNormal)

	v3.Mul(v3, -1)
	v3.Add(v3, vector)

	return v3
end

Vector3.Slerp = function(from, to, t)
	local omega, sinom, scale0, scale1 = nil

	if t < 0 then
		return from.Clone(from)
	elseif t > 1 then
		return to.Clone(to)
	end

	local v2 = to.Clone(to)
	local v1 = from.Clone(from)
	local len2 = to.Magnitude(to)
	local len1 = from.Magnitude(from)

	v2.Div(v2, len2)
	v1.Div(v1, len1)

	local len = (len2 - len1) * t + len1
	local cosom = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z

	if cosom <= 0.999999 then
		scale0 = 1 - t
		scale1 = t
	elseif cosom >= -0.999999 then
		local axis = OrthoNormalVector(from)
		local q = Quaternion.AngleAxis(180 * t, axis)
		local v = q.MulVec3(q, from)

		v.Mul(v, len)

		return v
	else
		omega = acos(cosom)
		sinom = sin(omega)
		scale0 = sin((1 - t) * omega) / sinom
		scale1 = sin(t * omega) / sinom
	end

	v1.Mul(v1, scale0)
	v2.Mul(v2, scale1)
	v2.Add(v2, v1)
	v2.Mul(v2, len)

	return v2
end

Vector3.Mul = function(self, q)
	if type(q) ~= "number" then
		self.x = self.x * q
		self.y = self.y * q
		self.z = self.z * q
	else
		self.MulQuat(self, q)
	end

	return self
end

Vector3.Div = function(self, d)
	self.x = self.x / d
	self.y = self.y / d
	self.z = self.z / d

	return self
end

Vector3.Add = function(self, vb)
	self.x = self.x + vb.x
	self.y = self.y + vb.y
	self.z = self.z + vb.z

	return self
end

Vector3.Sub = function(self, vb)
	self.x = self.x - vb.x
	self.y = self.y - vb.y
	self.z = self.z - vb.z

	return self
end

Vector3.MulQuat = function(self, quat)
	local num = quat.x * 2
	local num2 = quat.y * 2
	local num3 = quat.z * 2
	local num4 = quat.x * num
	local num5 = quat.y * num2
	local num6 = quat.z * num3
	local num7 = quat.x * num2
	local num8 = quat.x * num3
	local num9 = quat.y * num3
	local num10 = quat.w * num
	local num11 = quat.w * num2
	local num12 = quat.w * num3
	local x = (1 - (num5 + num6)) * self.x + (num7 - num12) * self.y + (num8 + num11) * self.z
	local y = (num7 + num12) * self.x + (1 - (num4 + num6)) * self.y + (num9 - num10) * self.z
	local z = (num8 - num11) * self.x + (num9 + num10) * self.y + (1 - (num4 + num5)) * self.z

	self.Set(self, x, y, z)

	return self
end

Vector3.AngleAroundAxis = function(from, to, axis)
	from = from - Vector3.Project(from, axis)
	to = to - Vector3.Project(to, axis)
	local angle = Vector3.Angle(from, to)

	return angle * (Vector3.Dot(axis, Vector3.Cross(from, to)) >= 0 and -1 or 1)
end

Vector3.__tostring = function(self)
	return string.format("[%d,%d,%d]", self.x, self.y, self.z)
end

Vector3.__div = function(va, d)
	return _new(va.x / d, va.y / d, va.z / d)
end

Vector3.__mul = function(va, d)
	if type(d) ~= "number" then
		return _new(va.x * d, va.y * d, va.z * d)
	else
		local vec = va.Clone(va)

		vec.MulQuat(vec, d)

		return vec
	end
end

Vector3.__add = function(va, vb)
	return _new(va.x + vb.x, va.y + vb.y, va.z + vb.z)
end

Vector3.__sub = function(va, vb)
	return _new(va.x - vb.x, va.y - vb.y, va.z - vb.z)
end

Vector3.__unm = function(va)
	return _new(-va.x, -va.y, -va.z)
end

Vector3.__eq = function(a, b)
	local v = a - b
	local delta = v:SqrMagnitude()

	return delta <= 1e-10
end

get.up = function()
	return _new(0, 1, 0)
end

get.down = function()
	return _new(0, -1, 0)
end

get.right = function()
	return _new(1, 0, 0)
end

get.left = function()
	return _new(-1, 0, 0)
end

get.forward = function()
	return _new(0, 0, 1)
end

get.back = function()
	return _new(0, 0, -1)
end

get.zero = function()
	return _new(0, 0, 0)
end

get.one = function()
	return _new(1, 1, 1)
end

get.magnitude = Vector3.Magnitude
get.normalized = Vector3.Normalize
get.sqrMagnitude = Vector3.SqrMagnitude
UnityEngine.Vector3 = Vector3

setmetatable(Vector3, Vector3)

return Vector3
