C_TimeWheelScrollStore = DefClass("C_TimeWheelScrollStore", C_TimeWheelScrollStore, C_StoreGroup)
GroupName2Class.TimeWheelScrollStore = C_TimeWheelScrollStore
local M = C_TimeWheelScrollStore
local TEMPLATE_HEIGHT = 250

function M:StartWheel(startTime, endTime, duration)
	self:InitModel(startTime, endTime, duration)
	self:InitView()
end

function M:InitModel(startTime, endTime, duration)
	local totalSecond = (endTime + gClientConst.SECONDS_PER_DAY - startTime) % gClientConst.SECONDS_PER_DAY
	local totalMinute = math.floor((endTime + gClientConst.SECONDS_PER_DAY - startTime) % gClientConst.SECONDS_PER_DAY / 60)
	self.timePass = 0
	self.duration = duration or 0.5
	self.timePassSpeed = totalSecond / duration
	self.m1RotateSpeed = math.max(totalMinute * TEMPLATE_HEIGHT / duration, 800)
	self.m0RotateSpeed = math.max(self.m1RotateSpeed / 9, 500)
	self.h1RotateSpeed = self.m0RotateSpeed
	self.h0RotateSpeed = self.m0RotateSpeed
	self.currentTime = startTime
	self.endTime = endTime
end

function M:InitView()
	local startHour = math.floor(self.currentTime / gClientConst.SECONDS_PER_HOUR)
	local startMinute = math.floor(self.currentTime / gClientConst.SECONDS_PER_MINUTE % gClientConst.SECONDS_PER_MINUTE)

	self:SetGirdPositionByTime(startHour, startMinute)
end

function M:SetGirdPositionByTime(startHour, startMinute)
	local h0 = math.floor(startHour / 10)
	local h1 = startHour % 10
	local m0 = math.floor(startMinute / 10)
	local m1 = startMinute % 10
	local h0Transform = self.bindData.h0Transform
	local h1Transform = self.bindData.h1Transform
	local m0Transform = self.bindData.m0Transform
	local m1Transform = self.bindData.m1Transform
	h0Transform.anchoredPosition = Vector3.Fetch(0, h0 * TEMPLATE_HEIGHT, 0)
	h1Transform.anchoredPosition = Vector3.Fetch(0, h1 * TEMPLATE_HEIGHT, 0)
	m0Transform.anchoredPosition = Vector3.Fetch(0, m0 * TEMPLATE_HEIGHT, 0)
	m1Transform.anchoredPosition = Vector3.Fetch(0, m1 * TEMPLATE_HEIGHT, 0)
	self.lastH0 = h0
	self.lastH1 = h1
	self.lastM0 = m0
	self.lastM1 = m1
	self.isStart = true
end

function M:MoveNode(transform, count, targetNum, speed)
	if targetNum == 0 then
		targetNum = count
	end

	local tarY = math.min(transform.localPosition.y + Time.deltaTime * speed, targetNum * TEMPLATE_HEIGHT)

	if tarY >= targetNum * TEMPLATE_HEIGHT and targetNum == count then
		transform.anchoredPosition = Vector3.New(0, 0, 0)
	else
		transform.anchoredPosition = Vector3.New(0, tarY, 0)
	end

	return math.floor(transform.anchoredPosition.y / TEMPLATE_HEIGHT)
end

function M:OnUpdate()
	if self.isStart then
		self.timePass = self.timePass or 0
		self.timePass = self.timePass + Time.deltaTime

		if self.duration <= self.timePass then
			self.currentTime = self.endTime
		else
			self.currentTime = (self.currentTime + self.timePassSpeed * Time.deltaTime) % gClientConst.SECONDS_PER_DAY
		end

		local hour = math.floor(self.currentTime / gClientConst.SECONDS_PER_HOUR) % gClientConst.DAY_HOUR
		local minute = math.floor(self.currentTime / gClientConst.SECONDS_PER_MINUTE % gClientConst.SECONDS_PER_MINUTE)
		local h0 = math.floor(hour / 10)
		local h1 = hour % 10
		local m0 = math.floor(minute / 10)
		local m1 = minute % 10

		if h0 ~= self.lastH0 then
			self.lastH0 = self:MoveNode(self.bindData.h0Transform, 4, h0, self.h0RotateSpeed)
		end

		if h1 ~= self.lastH1 then
			local count = 10

			if h0 == 0 and h1 == 0 or h0 == 2 then
				count = 5
				self.bindData.h1_4Value = 0
			else
				self.bindData.h1_4Value = 4
			end

			self.lastH1 = self:MoveNode(self.bindData.h1Transform, count, h1, self.h1RotateSpeed)
		end

		if m0 ~= self.lastM0 then
			self.lastM0 = self:MoveNode(self.bindData.m0Transform, 7, m0, self.m0RotateSpeed)
		end

		if m1 ~= self.lastM1 then
			self.lastM1 = self:MoveNode(self.bindData.m1Transform, 10, m1, self.m1RotateSpeed)
		end

		gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.UIGameTime, hour * 60 + minute)
	end
end

function M:OnDestroy()
	self.isStart = nil
end
