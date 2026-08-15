local ColorUtils = LX6.Utils.ColorUtils
local ProfileManager = LX6.Engine.ProfileManager
local Screen = UnityEngine.Screen
local PlayerPrefs = UnityEngine.PlayerPrefs
local ShezhiPanelConfig = LTConfig.ShezhiPanelConfig
local LayerConstants = LX6.Constants.LayerConstants
local TransformationConfig = LTConfig.TransformationConfig
local bit = require("bit")
local math = math
local sqrt = math.sqrt
local sin = math.sin
local cos = math.cos
local halfDegToRad = 0.5 * Mathf.Deg2Rad
local UXVector3 = UX.Game.UXVector3
local uxVector3Tmp = UXVector3.New(0, 0, 0)
local M = {
	OnInit = function (self)
		self.CLICK_TIME = 1
	end,
	ShallowCopy = function (self, orig)
		local orig_type = type(orig)
		local copy = nil

		if orig_type == "table" then
			copy = {}

			for orig_key, orig_value in pairs(orig) do
				copy[orig_key] = orig_value
			end
		else
			copy = orig
		end

		return copy
	end,
	Merge = function (self, ta, tb)
		for k, v in pairs(tb) do
			ta[k] = v
		end
	end,
	MergeArray = function (self, to, from)
		if table.isNilOrEmpty(from) or to == nil then
			return
		end

		for _, v in pairs(from) do
			table.insert(to, v)
		end
	end,
	IsTableEmpty = function (self, t)
		return t == nil or next(t) == nil
	end,
	IsNumber = function (self, num)
		if num == nil then
			return false
		end

		return math.floor(num) == num
	end,
	LogDuration = function (self, str)
		local now = UnityEngine.Time.unscaledTime

		if self.lastTime then
			local during = now - self.lastTime

			UnityEngine.Debug.Log("lua duration " .. str .. " " .. during)
		end

		self.lastTime = now
	end,
	Round = function (self, num)
		return math.floor(num + 0.5)
	end,
	Trim = function (self, str)
		if type(str) == "string" then
			return str:gsub("%s+", "")
		else
			return str
		end
	end,
	IsFloatEqual = function (self, a, b, esp)
		esp = esp or 0.0001
		a = a or 0
		local e = a - b

		if math.abs(e) < esp then
			return true
		else
			return false
		end
	end,
	Magnitude = function (self, x, y, z)
		if x == 0 and y == 0 and z == 0 then
			return 0
		end

		return sqrt(x * x + y * y + z * z)
	end,
	MagnitudeVector2 = function (self, x, y)
		if x == 0 and y == 0 then
			return 0
		end

		return sqrt(x * x + y * y)
	end,
	IsPositionEqual = function (self, a, b, esp)
		return self:IsFloatEqual(a.x, b.x, esp) and self:IsFloatEqual(a.y, b.y, esp) and self:IsFloatEqual(a.z, b.z, esp)
	end,
	IsXYZEqualPosition = function (self, x, y, z, b)
		return self:IsFloatEqual(x, b.x) and self:IsFloatEqual(y, b.y) and self:IsFloatEqual(z, b.z)
	end,
	IsPositionZero = function (self, a)
		if a == nil then
			return true
		end

		return self:IsFloatEqual(a.x, 0) and self:IsFloatEqual(a.y, 0) and self:IsFloatEqual(a.z, 0)
	end,
	IsVector2Zero = function (self, a)
		if a == nil then
			return true
		end

		return self:IsFloatEqual(a.x, 0) and self:IsFloatEqual(a.y, 0)
	end,
	IsUXPositionZero = function (self, a)
		if a == nil then
			return true
		end

		return self:IsFloatEqual(a.X, 0) and self:IsFloatEqual(a.Y, 0) and self:IsFloatEqual(a.Z, 0)
	end,
	IsUXPositionNaN = function (self, a)
		if a == nil then
			return true
		end

		uxVector3Tmp.X = a.X
		uxVector3Tmp.Y = a.Y
		uxVector3Tmp.Z = a.Z

		return uxVector3Tmp.IsNaN
	end,
	IsTouchPositionEqual = function (self, a, b, touchEsp)
		return self:IsFloatEqual(a.x, b.x, touchEsp) and self:IsFloatEqual(a.y, b.y, touchEsp)
	end,
	IsFloatGreaterEqual = function (self, a, b, esp)
		if esp == nil then
			esp = 0.0001
		end

		return a - b >= -esp
	end,
	IsVector3LessEqual = function (self, a, x, y, z)
		return a.x - x <= 0.0001 and a.y - y <= 0.0001 and a.z - z <= 0.0001
	end,
	IsVector3Equal = function (self, a, x, y, z)
		return Mathf.Abs(a.x - x) <= 0.0001 and Mathf.Abs(a.y - y) <= 0.0001 and Mathf.Abs(a.z - z) <= 0.0001
	end,
	RotateVector3Around = function (self, point, pivot, angles)
		return Quaternion.Euler(angles) * (point - pivot) + pivot
	end,
	CalCos = function (self, p, p1, p2, byY)
		local v1x = p1.x - p.x
		local v1y = nil

		if byY then
			v1y = p1.y - p.y
		else
			v1y = p1.z - p.z
		end

		local v2x = p2.x - p.x
		local v2y = nil

		if byY then
			v2y = p2.y - p.y
		else
			v2y = p2.z - p.z
		end

		local cos = (v1x * v2x + v1y * v2y) / (sqrt(v1x * v1x + v1y * v1y) * sqrt(v2x * v2x + v2y * v2y))

		return cos
	end,
	RotateVector2 = function (self, x, y, angle)
		local radian = angle / 180 * math.pi
		local cosR = math.cos(radian)
		local sinR = math.sin(radian)
		local x1 = x * cosR - y * sinR
		local y1 = x * sinR + y * cosR

		return x1, y1
	end,
	CalcIntersection = function (self, a, b, c, d)
		local area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x)
		local area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x)

		if area_abc * area_abd >= 0 then
			return nil
		end

		local area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x)
		local area_cdb = area_cda + area_abc - area_abd

		if area_cda * area_cdb >= 0 then
			return nil
		end

		local t = area_cda / (area_abd - area_abc)
		local dx = t * (b.x - a.x)
		local dy = t * (b.y - a.y)

		return Vector2.New(a.x + dx, a.y + dy)
	end,
	GetTouchPosition = function (self, touchID)
		local pos = nil

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			if touchID ~= nil then
				pos = gCS.LuaUtils.GetTouchPosition(touchID)
			else
				pos = gCS.LuaUtils.GetFirstTouchPosition()
			end

			pos = Vector3.New(pos.x, pos.y, 0)
		else
			pos = gCS.LuaUtils.GetCursorPosition()
		end

		return pos
	end,
	GetTouchPositionXY = function (self, touchID)
		local pos = nil

		if not gCS.LuaUtils.IsNonMobileAdaptive() then
			if touchID ~= nil then
				pos = gCS.LuaUtils.GetTouchPosition(touchID)
			else
				pos = gCS.LuaUtils.GetFirstTouchPosition()
			end
		else
			pos = gCS.LuaUtils.GetCursorPosition()
		end

		return pos.x, pos.y
	end,
	ScreenToUIPosition = function (self, screenPos)
		return gCS.LuaUtils.ScreenPointToUINoRay(screenPos.x, screenPos.y)
	end
}
local vec = Vector3.zero
local edgeOffset = {
	{
		0,
		0
	},
	{
		0,
		0
	},
	{
		0,
		0
	},
	{
		0,
		0
	}
}
local screenPos = Vector3.zero

function M:TransformationScreenPoint(worldPos, offset)
	local x = 0
	local y = 0
	local z = 0
	x, y, z = gCS.LuaUtils.WorldToScreenPoint(worldPos, x, y, z)

	screenPos:Set(x, y, z)

	if screenPos.x > 0 and screenPos.y > 0 and screenPos.x < Screen.width / 2 and screenPos.y < Screen.height / 2 then
		return screenPos
	end

	if screenPos.z < 0 then
		screenPos.x = -screenPos.x
		screenPos.y = 0
	end

	vec:Set(Screen.width / 2, Screen.height / 2, 0)

	local screenEdgePos, edge = self:SegmentIntersectScreen(vec, screenPos)
	offset = offset or 0
	edgeOffset[1][1] = offset
	edgeOffset[2][2] = -offset
	edgeOffset[3][1] = -offset
	edgeOffset[4][2] = offset

	if screenEdgePos then
		screenEdgePos.x = screenEdgePos.x + edgeOffset[edge][1]
		screenEdgePos.y = screenEdgePos.y + edgeOffset[edge][2]
	end

	return screenEdgePos or screenPos, edge
end

local leftTop = Vector3.New(0, Screen.height, 0)
local leftDown = Vector3.zero
local rightTop = Vector3.New(Screen.width, Screen.height, 0)
local rightDown = Vector3.New(Screen.width, 0, 0)
local screenSeg = {
	{
		leftDown,
		leftTop
	},
	{
		leftTop,
		rightTop
	},
	{
		rightTop,
		rightDown
	},
	{
		rightDown,
		leftDown
	}
}

function M:SegmentIntersectScreen(a, b)
	local width = Screen.width
	local height = Screen.height
	leftTop.y = height
	rightTop.x = width
	rightTop.y = height
	rightDown.x = width

	for k, v in pairs(screenSeg) do
		local intersectPoint = self:SegmentsIntersect(a, b, v[1], v[2])

		if intersectPoint then
			return intersectPoint, k
		end
	end

	return nil
end

local segmentsIntersectPoint = Vector3.zero

function M:SegmentsIntersect(a, b, c, d)
	local area_abc = (a.x - c.x) * (b.y - c.y) - (a.y - c.y) * (b.x - c.x)
	local area_abd = (a.x - d.x) * (b.y - d.y) - (a.y - d.y) * (b.x - d.x)

	if area_abc * area_abd >= 0 then
		return nil
	end

	local area_cda = (c.x - a.x) * (d.y - a.y) - (c.y - a.y) * (d.x - a.x)
	local area_cdb = area_cda + area_abc - area_abd

	if area_cda * area_cdb >= 0 then
		return nil
	end

	local t = area_cda / (area_abd - area_abc)
	local dx = t * (b.x - a.x)
	local dy = t * (b.y - a.y)

	segmentsIntersectPoint:Set(a.x + dx, a.y + dy, 0)

	return segmentsIntersectPoint
end

function M:IsRayRight(a, b, c)
	return (c.x - a.x) * (b.y - a.y) - (c.y - a.y) * (b.x - a.x) >= 0
end

function M:GetCurrentUIRootWidthHeight()
	if SGUI.UWidget.canvasScaler == nil then
		return 0, 0
	end

	local screenWidth = Screen.width
	local screenHeight = Screen.height
	local uiRootHeight = SGUI.UWidget.canvasScaler.referenceResolution.x
	local uiRootWidth = SGUI.UWidget.canvasScaler.referenceResolution.y
	local screenRatio = screenWidth / screenHeight
	local uiRatio = uiRootWidth / uiRootHeight
	local scale, currentWidth, currentHeight = nil

	if uiRatio < screenRatio then
		scale = screenHeight / uiRootHeight
		currentHeight = uiRootHeight
		currentWidth = uiRootHeight * screenRatio
	else
		scale = screenWidth / uiRootWidth
		currentWidth = uiRootWidth
		currentHeight = uiRootWidth / screenRatio
	end

	return currentWidth, currentHeight
end

function M:IsContain(list, item)
	for i = 1, #list do
		if list[i] == item then
			return true
		end
	end

	return false
end

function M:TableToString(tbl)
	if not tbl then
		return tostring(tbl)
	end

	local result = "{"

	for k, v in pairs(tbl) do
		if type(k) == "string" then
			result = result .. "[\"" .. k .. "\"]" .. "="
		end

		if type(v) == "table" then
			result = result .. self:TableToString(v)
		elseif type(v) == "boolean" then
			result = result .. tostring(v)
		elseif type(v) == "number" then
			result = result .. v
		else
			result = result .. "\"" .. v .. "\""
		end

		result = result .. ","
	end

	if result ~= "" then
		result = result:sub(1, result:len() - 1)
	end

	return result .. "}"
end

function M:StringToTable(str)
	if not str or type(str) ~= "string" then
		return nil
	end

	if str == "nil" then
		return nil
	end

	if str:sub(1, 1) ~= "{" or str:sub(-1) ~= "}" then
		return nil
	end

	local code = "return " .. str
	local func, errorMsg = load(code)

	if not func then
		print("Failed to convert string to table: " .. (errorMsg or "Unknown error"))

		return nil
	end

	local success, result = pcall(func)

	if not success then
		print("Failed to execute string conversion: " .. (result or "Unknown error"))

		return nil
	end

	return result
end

function M:FormatAngle180(angle)
	angle = angle % 360

	if angle > 180 then
		angle = angle - 360
	elseif angle < -180 then
		angle = angle + 360
	end

	return angle
end

function M:FormatAngle(angle)
	local x = angle / 360

	return (x - Mathf.Floor(x)) * 360
end

function M:GetAngleYByDirection(direction)
	return Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg
end

function M:GetAngleYByDirectionUX3(direction)
	return Mathf.Atan2(direction.X, direction.Z) * Mathf.Rad2Deg
end

function M:GetAngleYByDirectionV2(direction)
	return Mathf.Atan2(direction.x, direction.y) * Mathf.Rad2Deg
end

function M:GetAngleYByDirectionXZ(x, z)
	return Mathf.Atan2(x, z) * Mathf.Rad2Deg
end

function M:GetXZByAngleY(angleY)
	return Mathf.Sin(Mathf.Deg2Rad * angleY), Mathf.Cos(Mathf.Deg2Rad * angleY)
end

function M:GetXZDistance(pos1, pos2)
	return sqrt((pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.z - pos2.z) * (pos1.z - pos2.z))
end

function M:GetXZDisByVelocity(velocity)
	return sqrt(velocity.x * velocity.x + velocity.z * velocity.z)
end

function M:GetXZDistance4Param(x1, z1, x2, z2)
	return sqrt((x1 - x2) * (x1 - x2) + (z1 - z2) * (z1 - z2))
end

function M:GetSqrXZDistance(pos1, pos2)
	return (pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.z - pos2.z) * (pos1.z - pos2.z)
end

function M:GetSqrXYDistance(pos1, pos2)
	return (pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.y - pos2.y) * (pos1.y - pos2.y)
end

function M:GetSqrXYZDistance(pos1, pos2)
	return (pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.y - pos2.y) * (pos1.y - pos2.y) + (pos1.z - pos2.z) * (pos1.z - pos2.z)
end

function M:GetFloatXYZDistance(x1, y1, z1, x2, y2, z2)
	return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2))
end

function M:SqrDistanceXZ(x1, z1, x2, z2)
	local x = x2 - x1
	local z = z2 - z1

	return x * x + z * z
end

function M:SqrDistanceXYZ(x1, y1, z1, x2, y2, z2)
	local x = x2 - x1
	local z = z2 - z1
	local y = y2 - y1

	return x * x + z * z + y * y
end

function M:SqrDistance(pos1, pos2)
	local x = pos2.x - pos1.x
	local z = pos2.z - pos1.z
	local y = pos2.y - pos1.y

	return x * x + z * z + y * y
end

function M:DistanceXY(x1, y1, x2, y2)
	return sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function M:GetDistance(pos1, pos2)
	return sqrt((pos1.x - pos2.x) * (pos1.x - pos2.x) + (pos1.y - pos2.y) * (pos1.y - pos2.y) + (pos1.z - pos2.z) * (pos1.z - pos2.z))
end

function M:GetDistanceWithXYZ(x, y, z, pos)
	return sqrt((x - pos.x) * (x - pos.x) + (y - pos.y) * (y - pos.y) + (z - pos.z) * (z - pos.z))
end

function M:CreateVector3(uxVector3)
	return Vector3.New(uxVector3.X, uxVector3.Y, uxVector3.Z)
end

function M:GetVector3Direction(startpos, endpos)
	return Vector3.New(endpos.x - startpos.x, endpos.y - startpos.y, endpos.z - startpos.z)
end

function M:GetVector3XYZ(value)
	if value == nil then
		return nil, nil, nil
	end

	return value.x, value.y, value.z
end

function M:Vector3Set(value, x, y, z)
	if value ~= nil and x ~= nil and y ~= nil and z ~= nil then
		value.x = x
		value.y = y
		value.z = z
	else
		print_error("Vector3Set is nil")
	end

	return value
end

function M:Vector2Set(value, x, y)
	if value ~= nil and x ~= nil and y ~= nil then
		value.x = x
		value.y = y
	else
		print_error("Vector2Set is nil")
	end

	return value
end

function M:Vector3Copy(value, other)
	if value ~= nil and other ~= nil then
		value.x = other.x
		value.y = other.y
		value.z = other.z
	else
		print_error("Vector3Copy is nil")
	end

	return value
end

function M:Vector2Copy(value, other)
	if value ~= nil and other ~= nil then
		value.x = other.x
		value.y = other.y
	else
		print_error("Vector2Copy is nil")
	end

	return value
end

function M:SetNormalize(pos)
	local num = sqrt(pos.x * pos.x + pos.y * pos.y + pos.z * pos.z)

	if num > 1e-05 then
		pos.x = pos.x / num
		pos.y = pos.y / num
		pos.z = pos.z / num
	else
		pos.x = 0
		pos.y = 0
		pos.z = 0
	end

	return pos
end

function M:Vector3Sub(value, va, vb)
	if va == nil or vb == nil or value == nil then
		print_error("Vector3Sub is nil", va, vb, value)

		return
	end

	value.x = va.x - vb.x
	value.y = va.y - vb.y
	value.z = va.z - vb.z

	return value
end

function M:Vector3Subxyz(value, vb, x, y, z)
	if vb == nil or value == nil then
		print_error("Vector3Sub is nil", vb, value)

		return
	end

	value.x = x - vb.x
	value.y = y - vb.y
	value.z = z - vb.z

	return value
end

function M:Vector3AddXYZ(value, va, x, y, z)
	if va == nil or x == nil or value == nil then
		print_error("Vector3Add is nil", va, x, value)

		return
	end

	value.x = va.x + x
	value.y = va.y + y
	value.z = va.z + z

	return value
end

function M:Vector3Add(value, va, vb)
	if va == nil or vb == nil or value == nil then
		print_error("Vector3Add is nil", va, vb, value)

		return
	end

	value.x = va.x + vb.x
	value.y = va.y + vb.y
	value.z = va.z + vb.z

	return value
end

function M:Vector3MulVector(value, va, vb)
	if va == nil or vb == nil or value == nil then
		print_error("Vector3MulNumber is nil", va, vb, value)

		return
	end

	value.x = va.x * vb
	value.y = va.y * vb
	value.z = va.z * vb
end

function M:Vector3MulNumber(value, va)
	if va == nil or va == nil or value == nil then
		print_error("Vector3MulNumber is nil", va, value)

		return
	end

	value.x = value.x * va
	value.y = value.y * va
	value.z = value.z * va

	return value
end

function M:Vector3DivNumber(value, va)
	if va == nil or va == nil or value == nil then
		print_error("Vector3MulNumber is nil", va, value)

		return
	end

	value.x = value.x / va
	value.y = value.y / va
	value.z = value.z / va

	return value
end

function M:Vector3Lerp(value, from, to, t)
	value.x = Mathf.Lerp(from.x, to.x, t)
	value.y = Mathf.Lerp(from.y, to.y, t)
	value.z = Mathf.Lerp(from.z, to.z, t)
end

function M:AngleAxis(quan, angle, normAxis)
	angle = angle * halfDegToRad
	local s = sin(angle)
	quan.w = cos(angle)
	quan.x = normAxis.x * s
	quan.y = normAxis.y * s
	quan.z = normAxis.z * s

	return quan
end

function M:QuatMulVec3(vec, Quat, point)
	local x = point.x
	local y = point.y
	local z = point.z
	local num = Quat.x * 2
	local num2 = Quat.y * 2
	local num3 = Quat.z * 2
	local num4 = Quat.x * num
	local num5 = Quat.y * num2
	local num6 = Quat.z * num3
	local num7 = Quat.x * num2
	local num8 = Quat.x * num3
	local num9 = Quat.y * num3
	local num10 = Quat.w * num
	local num11 = Quat.w * num2
	local num12 = Quat.w * num3
	vec.x = (1 - (num5 + num6)) * x + (num7 - num12) * y + (num8 + num11) * z
	vec.y = (num7 + num12) * x + (1 - (num4 + num6)) * y + (num9 - num10) * z
	vec.z = (num8 - num11) * x + (num9 + num10) * y + (1 - (num4 + num5)) * z

	return vec
end

function M:GetTransformPosition(vec, trans)
	local x, y, z = trans:GetPositionXYZ(0, 0, 0)

	vec:Set(x, y, z)
end

function M:GetTransformForward(vec, trans)
	local x, y, z = trans:GetForwardXYZ(0, 0, 0)

	vec:Set(x, y, z)
end

function M:IsActionSetConfigKey(actionKey)
	return actionKey >= 104857601
end

function M:GetActionKey(k1, k2, k3)
	if k3 == nil or k3 == 0 then
		if k1 <= 0 then
			return 0
		end

		if k2 < 0 then
			print_error("获取动作ID出错 动作组为负数！")
		end

		return k1 * 1000 + k2
	end

	return bit.bor(bit.bor(bit.lshift(k1, 24), bit.lshift(k2, 16)), k3)
end

function M:UnpackActionID(actionKey)
	if self:IsActionSetConfigKey(actionKey) then
		local actionSet = 0
		local behavior = 0
		actionSet = bit.band(bit.rshift(actionKey, 20), 4095)
		behavior = bit.band(actionKey, 1048575)

		return actionSet, behavior, true
	else
		local type = 0
		local group = 0

		if actionKey <= 0 then
			return type, group
		end

		type = math.floor(actionKey / 1000)
		group = actionKey % 1000

		return type, group, false
	end
end

function M:IsInInterval(stamp1, stamp2, interval)
	local duration = tonumber(tostring(stamp1 - stamp2))
	duration = math.abs(duration / 1000)

	return duration < interval
end

function M:GetAngleForActionType(type)
	if type == gLuaFightConstants.Run_Left_ActionType then
		return true, 270
	elseif type == gLuaFightConstants.Run_Right_ActionType then
		return true, 90
	elseif type == gLuaFightConstants.ACTION_RUN_01 or type == gLuaFightConstants.ACTION_WALK_01 or type == gLuaFightConstants.ACTION_RUSH_01 then
		return true, 0
	elseif type == gLuaFightConstants.Run_BackWard_ActionType then
		return true, 180
	end

	return false, 0
end

function M:AccelerateGetY(sy, ey, height, per, magicNum)
	if magicNum == nil then
		magicNum = 4
	end

	local a = -height * magicNum
	local b = -a
	local c = 0
	local y = Mathf.Lerp(sy, ey, per) + a * per * per + b * per + c

	return y
end

function M:AccelerateGetYOnStableMaxY(sy, ey, height, per)
	local h = ey - sy
	local H = ey - sy + height
	local b = 2 * H + 2 * math.sqrt(H * H - H * h)
	local a = h - b
	local y = a * per * per + b * per + sy

	return y
end

function M:IsInGuide()
	return true
end

function M:ResetHideJobUiInTransformation(id, isShow)
	local cfg = TransformationConfig.GetConfig(id)

	if cfg ~= nil then
		isShow = not cfg.HideJobUi and isShow
	end

	return isShow
end

function M:ResetHideJuejiUIInTransformation(id, isShow)
	local cfg = TransformationConfig.GetConfig(id)

	if cfg ~= nil then
		isShow = not cfg.HideJueJi and isShow
	end

	return isShow
end

function M:CanShowJumpBtnInTransformation(id)
	local isShow = true
	local cfg = TransformationConfig.GetConfig(id)

	if cfg then
		isShow = not cfg.HideJumpButton
	end

	return isShow
end

function M:FormatTime(mTime)
	return gString.Format("%d:%02d", math.floor(mTime / 60), math.floor(mTime % 60))
end

function M:FormatTime2(mTime)
	return gString.Format("%2d:%02d", math.floor(mTime / 60), math.floor(mTime % 60))
end

function M:HexToColor(colorStr)
	local str = colorStr

	if string.len(colorStr) == 10 then
		str = string.sub(colorStr, 3, 10)
	end

	if string.len(str) ~= 8 then
		print_error("[HexToColor]", colorStr, " 颜色数据长度不对 ")

		return ColorUtils.HexToColor(colorStr)
	end

	return Color.NewByStr(str)
end

function M:GetSpecialDescription(desc, isHide)
	if desc == nil then
		return ""
	end

	local repl = ""

	if isHide then
		repl = "%1"
	end

	local matchPattern = "#(.+)#"
	local matchPattern1 = "\n#(.+)#"
	local match = string.match(desc, matchPattern1)
	local result = ""

	if match ~= nil and match ~= "" then
		result = string.gsub(desc, matchPattern1, repl)
	else
		result = string.gsub(desc, matchPattern, repl)
	end

	return result
end

function M:HasArrayIntersection(array1, array2)
	for k, v in pairs(array1) do
		if table.contains(array2, v) then
			return true
		end
	end

	return false
end

function M:GetAngle(from, to)
	local dir = Vector3.Cross(from, to)

	if dir.y > 0 then
		return Vector3.Angle(from, to)
	else
		return -Vector3.Angle(from, to)
	end
end

function M:SetPlayerPrefsInt(key, value)
	PlayerPrefs.SetInt(tostring(gPlayerManager.infoLogin.bindData.pid) .. key, value)
end

function M:GetPlayerPrefsInt(key, default)
	return PlayerPrefs.GetInt(tostring(gPlayerManager.infoLogin.bindData.pid) .. key, default or 0)
end

function M:SavePlayerPrefs()
	PlayerPrefs.Save()
end

function M:StringToBoolean(str)
	if type(str) == "string" then
		local str = string.lower(str)
		local bool = false

		if str == "true" then
			bool = true
		end

		return bool
	end

	return str
end

function M:InitLanguage()
	local index = ProfileManager.languageProfile.textLanguage
	local lang = ShezhiPanelConfig.LanguagesDisplay[index]
	local curLang = LTConfig.TableGetLanguage()

	if curLang ~= lang then
		LTConfig.TableSetLanguage(lang)
		LTConfig.ChangeLang()
		gMessageManager:SendMessage(gEventConstants.LANGUAGE_CHANGE, lang)
	end
end

M.vectorCacheList = {}

function M:GetVector(x, y, z)
	local t = table.remove(self.vectorCacheList)

	if t ~= nil then
		t.x = x
		t.y = y
		t.z = z

		return t
	else
		if x == nil then
			return Vector3.New(0, 0, 0)
		end

		return Vector3.New(x, y, z)
	end
end

function M:AddVector(data)
	if data ~= nil then
		table.insert(self.vectorCacheList, data)
	end
end

function M:GetShootPoint(offset, min, max, ignoreTrigger, isFireShoot)
	ignoreTrigger = ignoreTrigger or false
	local mainCamera = gCS.CameraDataMgr.MainCamera
	local tmpVector = self:GetVector(0, 0, 0)
	local startPt = mainCamera.transform.position + mainCamera.transform.forward * offset
	local hit = false
	local point = nil

	if isFireShoot then
		hit, point = gCS.LuaUtils.GetFirePoint(startPt, mainCamera.transform.forward, max, LayerConstants.bulletAimAllLayer, tmpVector, ignoreTrigger)
	else
		hit, point = gCS.LuaUtils.GetHitPoint(startPt, mainCamera.transform.forward, max, LayerConstants.bulletAimAllLayer, tmpVector, ignoreTrigger)
	end

	if hit then
		local distance = gUtils:GetDistance(point, mainCamera.transform.position)

		if distance < min then
			point = mainCamera.transform.position + mainCamera.transform.forward * min
		end
	else
		point = mainCamera.transform.position + mainCamera.transform.forward * max
	end

	self:AddVector(tmpVector)

	return point, hit
end

function M:RandomShuffle(arr)
	for i = #arr, 2, -1 do
		local j = math.random(1, i)
		arr[j] = arr[i]
		arr[i] = arr[j]
	end
end

function M:RandomPick(num, arr, notClone)
	if not notClone then
		arr = table.clone(arr)
	end

	local result = {}
	local length = #arr

	for i = 1, num do
		local index = math.random(length - i + 1)
		result[i] = arr[index]
		arr[index] = arr[length - i + 1]
	end

	return result
end

function M:WrapStaticLifecycle(ins)
	function ins.Awake(...)
		if type(ins._Awake) == "function" then
			ins:_Awake(...)
		end
	end

	function ins.OnShow(...)
		if type(ins._OnShow) == "function" then
			ins:_OnShow(...)
		end
	end

	function ins.OnClose(...)
		if type(ins._OnClose) == "function" then
			ins:_OnClose(...)
		end
	end

	function ins.OnDestroy(...)
		if type(ins._OnDestroy) == "function" then
			ins:_OnDestroy(...)
		end
	end

	return ins
end

function M:Vector3ToUX(v)
	if not v then
		return UXVector3.Zero
	end

	return UXVector3.New(v.x, v.y, v.z)
end

function M:SetCameraView(unit, cfg, bindVCam)
	local trans = unit.PlayerObj
	local pos = trans:TransformPoint(cfg.PositionX, cfg.PositionY, cfg.PositionZ)
	local rot = Quaternion.Euler(trans.eulerAngles.x + cfg.RotationX, trans.eulerAngles.y + cfg.RotationY, trans.eulerAngles.z + cfg.RotationZ)
	bindVCam.transform.position = pos
	bindVCam.transform.rotation = rot

	gCS.LuaUtils.SetVCameraFOV(bindVCam, cfg.CameraFov)
end

function M:SetFixCameraView(unit, cfg, camera)
	local trans = unit.PlayerObj
	local pos = trans:TransformPoint(cfg.PositionX, cfg.PositionY, cfg.PositionZ)
	local euler = Vector3.New(trans.eulerAngles.x + cfg.RotationX, trans.eulerAngles.y + cfg.RotationY, trans.eulerAngles.z + cfg.RotationZ)

	gCS.CameraDataMgr.cinemachineManager:SetFixCameraData(camera.gameObject, pos, euler, cfg.CameraFov)
end

function M.GetConsoleDebugInfoForUnit(pid, text)
	if text == nil then
		text = tostring(pid)
	end

	return gString.Format("<a search=\"unit\" id=\"%d\">%s</a>", pid, text)
end

function M.GetConsoleDebugInfoForVehicle(vehicleId, text)
	if text == nil then
		text = tostring(vehicleId)
	end

	return gString.Format("<a search=\"vehicle\" id=\"%d\">%s</a>", vehicleId, text)
end

gUtils = M
