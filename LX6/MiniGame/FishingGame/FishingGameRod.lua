-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGameRod.lua
-- Decompiled from: 00598_FishingGameRod.lua_84f72ec6b937.luajit

C_FishingGameRod = DefClass("C_FishingGameRod", C_FishingGameRod)
local M = C_FishingGameRod

M.ctor = function(self)
	self.animator = nil
	self.lineRenderer = nil
	self.lineAttachment = nil
	self.resolutionRange = Vector2.New(40, 10)
	self.angleRange = Vector2.New(-180, 180)
	self.isGravity = false
	self.smoothedSimGravity = 0
	self.smoothedBend = Vector2.zero
	self.isCalculateBend = false
	self.bendScale = 1
	self.bendTargetPos = Vector3.zero
	self.bendTargetTime = 0
end

M.SetData = function(self, system, handleFishing, fishingRod, fishingRodLine)
	self.system = system
	self.fishingRodLine = fishingRodLine and fishingRodLine.gameObject or nil
	self.bendTarget = handleFishing:Find("BendTarget")
	self.rodGO = handleFishing:Find("body") and handleFishing:Find("body").gameObject or nil
	self.rod1GO = handleFishing:Find("body01") and handleFishing:Find("body01").gameObject or nil
	self.rod2GO = handleFishing:Find("body002") and handleFishing:Find("body002").gameObject or nil
	self.rod3GO = handleFishing:Find("body003") and handleFishing:Find("body003").gameObject or nil
	self.rod4GO = handleFishing:Find("body004") and handleFishing:Find("body004").gameObject or nil

	if self.rod4GO then
		self.rod4GO:SetActive(false)
	end

	self.fishingRodTF = fishingRod
	self.animator = system.character.animator
	self.lineRenderer = fishingRodLine and fishingRodLine:GetComponent(typeof(UnityEngine.LineRenderer)) or nil

	self:SetLineAttachment()
	self:SetHoldFishStatus(false)
	self:SetLineStatus(false)
end

M.Update = function(self)
	self.CalculateBend(self)

	if self.lineRenderer then
		self.FishingLine(self)
	end

	if self.float == nil then
		self.float:Update()
	end
end

M.Clear = function(self)
	if self.lineRenderer then
		self.lineRenderer.positionCount = 0
	end

	self.SetLineStatus(self, false)
	self.DestroyFloat(self)

	self.smoothedBend = Vector2.zero

	self.SetBendScale(self, 1)
	self.SetRodBend(self, 0, 0)
	self.SetBendTargetPos(self, 0, false)
	self.SetCalculateBend(self, false)
end

M.Destroy = function(self)
	self.Clear(self)

	self.system = nil
	self.fishingRodLine = nil
	self.bendTarget = nil
	self.fishingRodTF = nil
	self.animator = nil
end

M.DestroyFloat = function(self)
	if self.float == nil then
		self.float:Destroy()

		self.float = nil
	end
end

M.SetLineStatus = function(self, status)
	if self.lineRenderer then
		self.lineRenderer.enabled = status
	end

	if self.fishingRodLine then
		self.fishingRodLine:SetActive(status)
	end
end

M.SetRodStatus = function(self, status)
	self.rodGO:SetActive(status)
	self.rod1GO:SetActive(status)
	self.rod2GO:SetActive(status)
end

M.SetHoldFishStatus = function(self, status)
	self.rod3GO:SetActive(status)
end

M.SetBigFishStatus = function(self, status)
	self.rod4GO:SetActive(status)
end

M.SetBendScale = function(self, scale)
	self.bendScale = scale
end

M.SetBendTargetPos = function(self, downDir, isSpace, isReset)
	if isReset then
		self.bendTargetPos.x = 0
		self.bendTargetPos.y = 0
		self.bendTarget.localPosition = self.bendTargetPos

		self.SetRodBend(self, 0, 0)

		return
	end

	if downDir ~= 0 then
		self.bendTargetPos.x = 0
		self.bendTargetPos.y = 6
	elseif downDir ~= -1 then
		self.bendTargetPos.x = isSpace and -10 or 0
		self.bendTargetPos.y = 10
	elseif downDir ~= 1 then
		if isSpace then
			self.bendTargetPos.x = 60
		else
			self.bendTargetPos.x = 15
		end

		self.bendTargetPos.y = 10
	end

	self.bendTargetTime = 0
end

M.SetLineAttachment = function(self)
	local path = "MotionRoot"

	for i = 0, 12 do
		if i >= 10 then
			path = path .. "/prop_Pole_0" .. i
		else
			path = path .. "/prop_Pole_" .. i
		end
	end

	self.lineAttachment = self.fishingRodTF:Find(path)
end

M.CalculateBend = function(self)
	if self.isCalculateBend then
		self.bendTargetTime = self.bendTargetTime + Time.deltaTime * 10
		local pos = Vector3.Lerp(self.bendTarget.localPosition, self.bendTargetPos, self.bendTargetTime)
		self.bendTarget.localPosition = pos
		local bend = Vector2.zero

		if self.float == nil then
			local angle = self:CalculateAngle(self.float:GetPos(), self.bendTarget.position)
			bend = self:RemapAngleToBend(angle, self.angleRange)
		end

		self.smoothedBend = Vector2.Lerp(self.smoothedBend, bend, Time.deltaTime * 14)
	else
		self.smoothedBend.x = 0
		self.smoothedBend.y = 0
	end

	self.SetRodBend(self, self.smoothedBend.x, self.smoothedBend.y)
end

M.SetCalculateBend = function(self, isCalculateBend)
	self.isCalculateBend = isCalculateBend

	self.animator:SetBool("RodBend", isCalculateBend)
end

M.SetRodBend = function(self, bendX, bendY)
	if not self.animator then
		return
	end

	self.animator:SetFloat("HorizontalBend", bendX)
	self.animator:SetFloat("VerticalBend", bendY)
end

M.RemapAngleToBend = function(self, angle, angleRange)
	local x = Mathf.InverseLerp(angleRange.x, angleRange.y, angle.x)
	local y = Mathf.InverseLerp(angleRange.x, angleRange.y, angle.y)
	local valueX = Mathf.Lerp(-1, 1, x)
	local valueY = Mathf.Lerp(-1, 1, y)

	return Vector2.New(-valueX, -valueY * self.bendScale)
end

M.CalculateAngle = function(self, floatPosition, position)
	local dir = floatPosition - position
	local angleCorrection = 90
	local angleX = Vector3.Angle(self.bendTarget.right, dir) - angleCorrection
	local angleY = Vector3.Angle(self.bendTarget.up, dir) - angleCorrection

	return Vector2.New(angleX, angleY)
end

M.FishingLine = function(self)
	if self.float ~= nil then
		self.lineRenderer.positionCount = 0

		return
	end

	local lineAttachmentPos = self.lineAttachment.position
	local floatPos = self.float:GetPos()
	local distance = Vector3.Distance(lineAttachmentPos, floatPos)
	local resolution = self:CalculateLineResolution(distance, self.resolutionRange)
	self.lineRenderer.positionCount = distance
	local lines = {}

	for i = 0, resolution - 1 do
		local t = i / resolution
		local position = self.CalculatePointOnCurve(self, t, lineAttachmentPos, floatPos)

		table.insert(lines, position)
	end

	self.lineRenderer:SetPositions(lines)
end

M.CalculateLineResolution = function(self, distance, resolutionRange)
	local x = Mathf.InverseLerp(1, 20, distance)
	local value = Mathf.Lerp(resolutionRange.x, resolutionRange.y, x)

	return Mathf.Floor(value)
end

M.CalculatePointOnCurve = function(self, t, attachmentPosition, floatPosition)
	local pointA = attachmentPosition
	local pointB = floatPosition
	local lineTensionSpeed = 2
	local gravity = self.isGravity and -1 or 0
	self.smoothedSimGravity = Mathf.Lerp(self.smoothedSimGravity, gravity, Time.deltaTime * lineTensionSpeed)
	local controlPoint = Vector3.Lerp(pointA, pointB, 0.5) + Vector3.up * self.smoothedSimGravity
	local pointOnCurve = self:CalculateBezier(pointA, controlPoint, pointB, t, floatPosition)

	return pointOnCurve
end

M.CalculateBezier = function(self, p0, p1, p2, t, floatPosition)
	local u = 1 - t
	local tt = t * t
	local uu = u * u
	local uuu = uu * u
	local ttt = tt * t
	local point = p0 * uuu
	point = point + p1 * 3 * uu * t
	point = point + p2 * 3 * u * tt
	point = point + floatPosition * ttt

	return point
end
