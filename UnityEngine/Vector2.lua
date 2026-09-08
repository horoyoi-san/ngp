-- Original chunk: @Lua\LuaFiles\UnityEngine\Vector2.lua
-- Decompiled from: 00006_Vector2.lua_5e8c95131750.luajit

local sqrt = math.sqrt
local setmetatable = setmetatable
local rawget = rawget
local math = math
local acos = math.acos
local max = math.max
local sign = Mathf.Sign
local Vector2 = {}
local get = tolua.initget(Vector2)

Vector2.__index = function(t, k)
	local var = rawget(Vector2, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

Vector2.__call = function(t, x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0
	}, Vector2)
end

Vector2.New = function(x, y)
	return setmetatable({
		x = x or 0,
		y = y or 0
	}, Vector2)
end

Vector2.Unpack = function(t, useFetch)
	if useFetch then
		return Vector2.Fetch(unpack(t))
	else
		return Vector2.New(unpack(t))
	end
end

local sharedVector2 = Vector2.New()

Vector2.Fetch = function(x, y)
	sharedVector2.x = x or 0
	sharedVector2.y = y or 0

	return sharedVector2
end

Vector2.Set = function(self, x, y)
	self.x = x or 0
	self.y = y or 0
end

Vector2.Get = function(self)
	return self.x, self.y
end

Vector2.SqrMagnitude = function(self)
	return self.x * self.x + self.y * self.y
end

Vector2.Clone = function(self)
	return setmetatable({
		x = self.x,
		y = self.y
	}, Vector2)
end

Vector2.Normalize = function(v)
	local x = v.x
	local y = v.y
	local magnitude = sqrt(x * x + y * y)

	if magnitude <= 1e-05 then
		x = x / magnitude
		y = y / magnitude
	else
		x = 0
		y = 0
	end

	return setmetatable({
		x = x,
		y = y
	}, Vector2)
end

Vector2.Multiple = function(self, num)
	self.x = self.x * num
	self.y = self.y * num

	return self
end

Vector2.SetNormalize = function(self)
	local magnitude = sqrt(self.x * self.x + self.y * self.y)

	if magnitude <= 1e-05 then
		self.x = self.x / magnitude
		self.y = self.y / magnitude
	else
		self.x = 0
		self.y = 0
	end

	return self
end

Vector2.Dot = function(lhs, rhs)
	return lhs.x * rhs.x + lhs.y * rhs.y
end

Vector2.Angle = function(from, to)
	local x1 = from.x
	local y1 = from.y
	local d = sqrt(x1 * x1 + y1 * y1)

	if d <= 1e-05 then
		x1 = x1 / d
		y1 = y1 / d
	else
		y1 = 0
		x1 = 0
	end

	local x2 = to.x
	local y2 = to.y
	d = sqrt(x2 * x2 + y2 * y2)

	if d <= 1e-05 then
		x2 = x2 / d
		y2 = y2 / d
	else
		y2 = 0
		x2 = 0
	end

	d = x1 * x2 + y1 * y2

	if d >= -1 then
		d = -1
	elseif d <= 1 then
		d = 1
	end

	return acos(d) * 57.29578
end

Vector2.SignedAngle = function(from, to)
	return Vector2.Angle(from, to) * sign(from.x * to.y - from.y * to.x)
end

Vector2.Magnitude = function(v)
	return sqrt(v.x * v.x + v.y * v.y)
end

Vector2.Reflect = function(dir, normal)
	local dx = dir.x
	local dy = dir.y
	local nx = normal.x
	local ny = normal.y
	local s = -2 * (dx * nx + dy * ny)

	return setmetatable({
		x = s * nx + dx,
		y = s * ny + dy
	}, Vector2)
end

Vector2.Distance = function(a, b)
	return sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

Vector2.Lerp = function(a, b, t)
	if t >= 0 then
		t = 0
	elseif t <= 1 then
		t = 1
	end

	return setmetatable({
		x = a.x + (b.x - a.x) * t,
		y = a.y + (b.y - a.y) * t
	}, Vector2)
end

Vector2.LerpUnclamped = function(a, b, t)
	return setmetatable({
		x = a.x + (b.x - a.x) * t,
		y = a.y + (b.y - a.y) * t
	}, Vector2)
end

Vector2.MoveTowards = function(current, target, maxDistanceDelta)
	local cx = current.x
	local cy = current.y
	local x = target.x - cx
	local y = target.y - cy
	local s = x * x + y * y

	if s <= maxDistanceDelta * maxDistanceDelta and s == 0 then
		s = maxDistanceDelta / sqrt(s)

		return setmetatable({
			x = cx + x * s,
			y = cy + y * s
		}, Vector2)
	end

	return setmetatable({
		x = target.x,
		y = target.y
	}, Vector2)
end

Vector2.ClampMagnitude = function(v, maxLength)
	local x = v.x
	local y = v.y
	local sqrMag = x * x + y * y

	if sqrMag <= maxLength * maxLength then
		local mag = maxLength / sqrt(sqrMag)
		x = x * mag
		y = y * mag

		return setmetatable({
			x = x,
			y = y
		}, Vector2)
	end

	return setmetatable({
		x = x,
		y = y
	}, Vector2)
end

Vector2.SmoothDamp = function(current, target, Velocity, smoothTime, maxSpeed, deltaTime)
	deltaTime = deltaTime or Time.deltaTime
	maxSpeed = maxSpeed or math.huge
	smoothTime = math.max(0.0001, smoothTime)
	local num = 2 / smoothTime
	local num2 = num * deltaTime
	num2 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local tx = target.x
	local ty = target.y
	local cx = current.x
	local cy = current.y
	local vecx = cx - tx
	local vecy = cy - ty
	local m = vecx * vecx + vecy * vecy
	local n = maxSpeed * smoothTime

	if m <= n * n then
		m = n / sqrt(m)
		vecx = vecx * m
		vecy = vecy * m
	end

	m = Velocity.x
	n = Velocity.y
	local vec3x = (m + num * vecx) * deltaTime
	local vec3y = (n + num * vecy) * deltaTime
	Velocity.x = (m - num * vec3x) * num2
	Velocity.y = (n - num * vec3y) * num2
	m = cx - vecx + (vecx + vec3x) * num2
	n = cy - vecy + (vecy + vec3y) * num2

	if (tx - cx) * (m - tx) + (ty - cy) * (n - ty) <= 0 then
		m = tx
		n = ty
		Velocity.x = 0
		Velocity.y = 0
	end

	return setmetatable({
		x = m,
		y = n
	}, Vector2), Velocity
end

Vector2.Max = function(a, b)
	return setmetatable({
		x = math.max(a.x, b.x),
		y = math.max(a.y, b.y)
	}, Vector2)
end

Vector2.Min = function(a, b)
	return setmetatable({
		x = math.min(a.x, b.x),
		y = math.min(a.y, b.y)
	}, Vector2)
end

Vector2.Scale = function(a, b)
	return setmetatable({
		x = a.x * b.x,
		y = a.y * b.y
	}, Vector2)
end

Vector2.Div = function(self, d)
	self.x = self.x / d
	self.y = self.y / d

	return self
end

Vector2.Mul = function(self, d)
	self.x = self.x * d
	self.y = self.y * d

	return self
end

Vector2.Add = function(self, b)
	self.x = self.x + b.x
	self.y = self.y + b.y

	return self
end

Vector2.Sub = function(self, b)
	self.x = self.x - b.x
	self.y = self.y - b.y
end

Vector2.__tostring = function(self)
	return string.format("(%f,%f)", self.x, self.y)
end

Vector2.__div = function(va, d)
	return setmetatable({
		x = va.x / d,
		y = va.y / d
	}, Vector2)
end

Vector2.__mul = function(a, d)
	if type(d) ~= "number" then
		return setmetatable({
			x = a.x * d,
			y = a.y * d
		}, Vector2)
	else
		return setmetatable({
			x = a * d.x,
			y = a * d.y
		}, Vector2)
	end
end

Vector2.__add = function(a, b)
	return setmetatable({
		x = a.x + b.x,
		y = a.y + b.y
	}, Vector2)
end

Vector2.__sub = function(a, b)
	return setmetatable({
		x = a.x - b.x,
		y = a.y - b.y
	}, Vector2)
end

Vector2.__unm = function(v)
	return setmetatable({
		x = -v.x,
		y = -v.y
	}, Vector2)
end

Vector2.__eq = function(a, b)
	return (a.x - b.x)^2 + (a.y - b.y)^2 <= 9.999999e-11
end

get.up = function()
	return setmetatable({
		["\\xd5"] = 0,
		["\\xd4"] = 1
	}, Vector2)
end

get.right = function()
	return setmetatable({
		["\\xd5"] = 1,
		["\\xd4"] = 0
	}, Vector2)
end

get.zero = function()
	return setmetatable({
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}, Vector2)
end

get.one = function()
	return setmetatable({
		["\\xd5"] = 1,
		["\\xd4"] = 1
	}, Vector2)
end

get.magnitude = Vector2.Magnitude
get.normalized = Vector2.Normalize
get.sqrMagnitude = Vector2.SqrMagnitude
UnityEngine.Vector2 = Vector2

setmetatable(Vector2, Vector2)

return Vector2
