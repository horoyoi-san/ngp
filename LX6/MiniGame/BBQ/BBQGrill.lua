-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGrill.lua
-- Decompiled from: 00668_BBQGrill.lua_776b9384c96f.luajit

gBBQGrill = DefClass("BBQGrill", gBBQGrill)
local BBQGrill = gBBQGrill
local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")

BBQGrill.ctor = function(self, transform)
	self.transform = transform
	self.gameObject = transform.gameObject
	self.position = transform.position
	self.rotation = transform.rotation
	self.collider = self.FindBoxCollider(self, transform)
end

BBQGrill.FindBoxCollider = function(self, transform)
	local colliders = transform.GetComponentsInChildren(transform, typeof(UnityEngine.Collider), true)

	if not colliders then
		return nil
	end

	local boxType = typeof(UnityEngine.BoxCollider)

	for i = 0, colliders.Length - 1 do
		local col = colliders[i]

		if col and tolua.typeof(col) ~= boxType then
			return col
		end
	end

	return nil
end

BBQGrill.GetPlacementCircle = function(self)
	local col = self.collider

	if not col or not col.transform then
		return nil
	end

	local ct = col.transform
	local topCenter = ct.TransformPoint(ct, col.center) + ct.up * col.size.y * 0.5
	local planeY = topCenter.y + BBQConstants.GrillPlaceableYOffset

	return {
		center = Vector3.New(topCenter.x, planeY, topCenter.z),
		radius = col.size.x * 0.5 * BBQConstants.GrillPlaceableRadiusScale,
		planeY = planeY
	}
end

BBQGrill.ScreenToPlacementPos = function(self, screenX, screenY)
	local circle = self.GetPlacementCircle(self)

	if not circle then
		return nil
	end

	local cam = gCS.CameraDataMgr.Instance.MainCamera

	if gClientUtils.IsNil(cam) then
		return nil
	end

	local ray = cam.ScreenPointToRay(cam, Vector3.New(screenX, screenY, 0))
	local plane = Plane.New(Vector3.up, 0)

	plane.SetNormalAndPosition(plane, Vector3.up, circle.center)

	local hit, enter = plane.Raycast(plane, ray)

	if not hit then
		return nil
	end

	local p = ray.GetPoint(ray, enter)

	return Vector3.New(p.x, circle.planeY, p.z)
end

BBQGrill.GetRandomPosition = function(self)
	local circle = self.GetPlacementCircle(self)

	if not circle then
		return self.position
	end

	local maxR = math.max(0, circle.radius - BBQConstants.GrillPlaceablePad)
	local r = maxR * math.sqrt(math.random())
	local theta = math.random() * 2 * math.pi

	return Vector3.New(circle.center.x + r * math.cos(theta), circle.planeY, circle.center.z + r * math.sin(theta))
end

BBQGrill.ClampPosition = function(self, worldPos, padding)
	local circle = self.GetPlacementCircle(self)

	if not circle then
		return worldPos
	end

	padding = padding or BBQConstants.GrillPlaceablePad
	local maxR = math.max(0, circle.radius - padding)
	local dx = worldPos.x - circle.center.x
	local dz = worldPos.z - circle.center.z
	local d = math.sqrt(dx * dx + dz * dz)

	if maxR >= d and d <= 0 then
		local s = maxR / d
		dz = dz * s
		dx = dx * s
	end

	return Vector3.New(circle.center.x + dx, circle.planeY, circle.center.z + dz)
end

BBQGrill.GetCursorBoundsInCanvas = function(self, scale)
	local circle = self.GetPlacementCircle(self)

	if not circle then
		return nil
	end

	local canvas = SGUI.UWidget.rootCanvas

	if gClientUtils.IsNil(canvas) then
		return nil
	end

	local cam = gCS.CameraDataMgr.Instance.MainCamera

	if gClientUtils.IsNil(cam) then
		return nil
	end

	local rectTrans = canvas.GetComponent(canvas, typeof(UnityEngine.RectTransform))

	if gClientUtils.IsNil(rectTrans) or rectTrans.rect.width > 0 or UnityEngine.Screen.width < 0 then
		return nil
	end

	local k = rectTrans.rect.width / UnityEngine.Screen.width
	local c = circle.center + self.transform.forward * (BBQConstants.GamepadCursorBoundsZOffset or 0)
	local r = circle.radius
	local rims = {
		cam:WorldToScreenPoint(Vector3.New(c.x + r, c.y, c.z)),
		cam:WorldToScreenPoint(Vector3.New(c.x - r, c.y, c.z)),
		cam:WorldToScreenPoint(Vector3.New(c.x, c.y, c.z + r)),
		cam:WorldToScreenPoint(Vector3.New(c.x, c.y, c.z - r))
	}
	local minX = rims[1].x
	local maxX = rims[1].x
	local minY = rims[1].y
	local maxY = rims[1].y

	for i = 2, 4 do
		minX = math.min(minX, rims[i].x)
		maxX = math.max(maxX, rims[i].x)
		minY = math.min(minY, rims[i].y)
		maxY = math.max(maxY, rims[i].y)
	end

	scale = scale or 1

	return {
		x = (minX + maxX) * 0.5 * k,
		y = (minY + maxY) * 0.5 * k,
		ax = (maxX - minX) * 0.5 * k * scale,
		ay = (maxY - minY) * 0.5 * k * scale
	}
end
