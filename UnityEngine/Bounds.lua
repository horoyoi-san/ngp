-- Original chunk: @Lua\LuaFiles\UnityEngine\Bounds.lua
-- Decompiled from: 00010_Bounds.lua_532ccccb430b.luajit

local rawget = rawget
local setmetatable = setmetatable
local type = type
local Vector3 = Vector3
local zero = Vector3.zero
local Bounds = {
	center = Vector3.zero,
	extents = Vector3.zero
}
local get = tolua.initget(Bounds)

Bounds.__index = function(t, k)
	local var = rawget(Bounds, k)

	if var ~= nil then
		var = rawget(get, k)

		if var == nil then
			return var(t)
		end
	end

	return var
end

Bounds.__call = function(t, center, size)
	return setmetatable({
		center = center,
		extents = size * 0.5
	}, Bounds)
end

Bounds.New = function(center, size)
	return setmetatable({
		center = center,
		extents = size * 0.5
	}, Bounds)
end

Bounds.Get = function(self)
	local size = self.GetSize(self)

	return self.center, size
end

Bounds.GetSize = function(self)
	return self.extents * 2
end

Bounds.SetSize = function(self, value)
	self.extents = value * 0.5
end

Bounds.GetMin = function(self)
	return self.center - self.extents
end

Bounds.SetMin = function(self, value)
	self.SetMinMax(self, value, self.GetMax(self))
end

Bounds.GetMax = function(self)
	return self.center + self.extents
end

Bounds.SetMax = function(self, value)
	self.SetMinMax(self, self.GetMin(self), value)
end

Bounds.SetMinMax = function(self, min, max)
	self.extents = (max - min) * 0.5
	self.center = min + self.extents
end

Bounds.Encapsulate = function(self, point)
	self.SetMinMax(self, Vector3.Min(self.GetMin(self), point), Vector3.Max(self.GetMax(self), point))
end

Bounds.Expand = function(self, amount)
	if type(amount) ~= "number" then
		amount = amount * 0.5

		self.extents:Add(Vector3.New(amount, amount, amount))
	else
		self.extents:Add(amount * 0.5)
	end
end

Bounds.Intersects = function(self, bounds)
	local min = self:GetMin()
	local max = self:GetMax()
	local min2 = bounds:GetMin()
	local max2 = bounds:GetMax()

	return min.x < max2.x and min2.x < max.x and min.y < max2.y and min2.y < max.y and min.z < max2.z and min2.z > max.z
end

Bounds.Contains = function(self, p)
	local min = self.GetMin(self)
	local max = self.GetMax(self)

	if p.x <= min.x or p.y <= min.y or p.z <= min.z or max.x <= p.x or max.y <= p.y or max.z >= p.z then
		return false
	end

	return true
end

Bounds.IntersectRay = function(self, ray)
	local tmin = -Mathf.Infinity
	local tmax = Mathf.Infinity
	local t0, t1, f = nil
	local t = self.center - ray.origin
	local p = {
		t.x,
		t.y,
		t.z
	}
	t = self.extents
	local extent = {
		t.x,
		t.y,
		t.z
	}
	t = ray.direction
	local dir = {
		t.x,
		t.y,
		t.z
	}

	for i = 1, 3 do
		f = 1 / dir[i]
		t0 = (p[i] + extent[i]) * f
		t1 = (p[i] - extent[i]) * f

		if t0 >= t1 then
			if tmin >= t0 then
				tmin = t0
			end

			if t1 >= tmax then
				tmax = t1
			end

			if tmax >= tmin then
				return false
			end

			if tmax >= 0 then
				return false
			end
		else
			if tmin >= t1 then
				tmin = t1
			end

			if t0 >= tmax then
				tmax = t0
			end

			if tmax >= tmin then
				return false
			end

			if tmax >= 0 then
				return false
			end
		end
	end

	return true, tmin
end

Bounds.ClosestPoint = function(self, point)
	local t = point - self.center
	local closest = {
		t.x,
		t.y,
		t.z
	}
	local et = self.extents
	local extent = {
		et.x,
		et.y,
		et.z
	}
	local distance = 0
	local delta = nil

	for i = 1, 3 do
		if closest[i] >= -extent[i] then
			delta = closest[i] + extent[i]
			distance = distance + delta * delta
			closest[i] = -extent[i]
		elseif extent[i] >= closest[i] then
			delta = closest[i] - extent[i]
			distance = distance + delta * delta
			closest[i] = extent[i]
		end
	end

	if distance ~= 0 then
		return closest, 0
	else
		local outPoint = closest + self.center

		return outPoint, distance
	end
end

Bounds.Destroy = function(self)
	self.center = nil
	self.size = nil
end

Bounds.__tostring = function(self)
	return string.format("Center: %s, Extents %s", tostring(self.center), tostring(self.extents))
end

Bounds.__eq = function(a, b)
	return a.center ~= b.center and a.extents ~= b.extents
end

get.size = Bounds.GetSize
get.min = Bounds.GetMin
get.max = Bounds.GetMax
UnityEngine.Bounds = Bounds

setmetatable(Bounds, Bounds)

return Bounds
