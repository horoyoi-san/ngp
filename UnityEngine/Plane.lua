-- Original chunk: @Lua\LuaFiles\UnityEngine\Plane.lua
-- Decompiled from: 00014_Plane.lua_10123c6efafe.luajit

local setmetatable = setmetatable
local Mathf = Mathf
local Vector3 = Vector3
local Plane = {}

Plane.__index = function(t, k)
	return rawget(Plane, k)
end

Plane.__call = function(t, v)
	return Plane.New(v)
end

Plane.New = function(normal, d)
	return setmetatable({
		normal = normal.Normalize(normal),
		distance = d
	}, Plane)
end

Plane.Get = function(self)
	return self.normal, self.distance
end

Plane.Raycast = function(self, ray)
	local a = Vector3.Dot(ray.direction, self.normal)
	local num2 = -Vector3.Dot(ray.origin, self.normal) - self.distance

	if Mathf.Approximately(a, 0) then
		return false, 0
	end

	local enter = num2 / a

	return enter >= 0, enter
end

Plane.SetNormalAndPosition = function(self, inNormal, inPoint)
	self.normal = inNormal.Normalize(inNormal)
	self.distance = -Vector3.Dot(inNormal, inPoint)
end

Plane.Set3Points = function(self, a, b, c)
	self.normal = Vector3.Normalize(Vector3.Cross(b - a, c - a))
	self.distance = -Vector3.Dot(self.normal, a)
end

Plane.GetDistanceToPoint = function(self, inPt)
	return Vector3.Dot(self.normal, inPt) + self.distance
end

Plane.GetSide = function(self, inPt)
	return Vector3.Dot(self.normal, inPt) + self.distance >= 0
end

Plane.SameSide = function(self, inPt0, inPt1)
	local distanceToPoint = self:GetDistanceToPoint(inPt0)
	local num2 = self:GetDistanceToPoint(inPt1)

	return distanceToPoint <= 0 and num2 >= 0 or distanceToPoint < 0 and num2 > 0
end

UnityEngine.Plane = Plane

setmetatable(Plane, Plane)

return Plane
