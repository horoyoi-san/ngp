-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TimeWheelScrollV2Store.lua
-- Decompiled from: 01368_TimeWheelScrollV2Store.lua_75cbca503da3.luajit

C_TimeWheelScrollV2Store = DefClass("C_TimeWheelScrollV2Store", C_TimeWheelScrollV2Store, C_StoreGroup)
GroupName2Class.TimeWheelScrollV2Store = C_TimeWheelScrollV2Store
local M = C_TimeWheelScrollV2Store
local Const = gClientConst
local Time = Time
local Vector3 = Vector3
local DOTween = DOTween
local Ease = DG.Tweening.Ease

local print = function(...)
	print_debug("[TimeWheelScrollV2Store] ", ...)
end

local TEMPLATE_HEIGHT = 300
local config = {
	["jW\\xae\\x87\\xbaپ\\x97\\xbc-\\xa69"] = 1,
	["\\xea\\xca%\\xfb\\xe8Iǁ\\xe3\\x974-"] = 20,
	["oV\\xae\\x87\\xbaپ\\x97\\xbc-\\xa69"] = 1,
	["\\x8bxu"] = 1,
	["\\xea\\xcb%\\xfb\\xe8Iǁ\\xe3\\x974-"] = 5,
	["jV\\xae\\x87\\xbaپ\\x97\\xbc-\\xa69"] = 1,
	["\n\\xb2k;\\xd5\\xe4i\\xaeC\\xa2\\xa5"] = 1,
	["+z\\xf3v\\x9d\\xf9\\xbd=\\xe7\\xe6\\xef{\\xf5"] = 0.75,
	h0Ease = Ease.OutCubic,
	h1ShortEase = Ease.InOutQuad,
	h1Tween1Ease = Ease.Linear,
	h1Tween2Ease = Ease.OutQuart,
	m0Tween1Ease = Ease.Linear,
	m0Tween2Ease = Ease.OutQuart,
	m0ShortEase = Ease.InOutQuad,
	m1Tween1Ease = Ease.Linear,
	m1Tween2Ease = Ease.OutQuart
}

M.StartWheel = function(self, startTime, endTime, duration, initOnly)
	self.CleanUp(self)

	local instance = {
		events = {}
	}
	self.instance = instance
	startTime = math.floor(startTime / 60) * 60
	instance.currentVal = startTime
	instance.animDuration = duration
	instance.startRealTime = Time.time
	local bindData = self.bindData
	local startMinute = math.floor(startTime / 60) % 60
	instance.startMinute = startMinute
	local startHour = math.floor(startTime / 60 / 60)
	instance.startHour = startHour
	local totalSecond = (endTime + Const.SECONDS_PER_DAY - startTime) % Const.SECONDS_PER_DAY
	local totalMinute = math.floor(totalSecond / 60)
	instance.totalMinute = totalMinute
	instance.endVal = startTime + totalSecond

	if not initOnly then
		if totalMinute < 0 then
			return
		end

		if totalMinute >= 10 then
			self.StartWheel(self, endTime, endTime, 0, true)

			return
		end
	end

	instance.h0MoveRoot = bindData.h0Grid.parent
	instance.h1MoveRoot = bindData.h1Grid.parent
	instance.m0MoveRoot = bindData.m0Grid.parent
	instance.m1ShakeRoot = bindData.m1Grid.parent
	instance.m1MoveRoot = instance.m1ShakeRoot.parent
	instance.timeScale = duration / totalMinute
	local m1Tween1Minute = totalMinute - config.m1Tween2Minute
	local m1Tween1Duration = m1Tween1Minute * instance.timeScale
	local m1Tween2Duration = config.m1Tween2Duration
	local m1StartPosY = startMinute % 10 * TEMPLATE_HEIGHT
	local m1Tween1PosY = m1StartPosY + m1Tween1Minute * TEMPLATE_HEIGHT
	local m1Tween2PosY = m1Tween1PosY + config.m1Tween2Minute * TEMPLATE_HEIGHT
	instance.m1MoveRoot.anchoredPosition = Vector3.Fetch(0, m1StartPosY, 0)
	bindData.m1Grid.anchoredPosition = Vector3.zero

	if not initOnly then
		self.PlayInitialTweens(self, m1Tween1PosY, m1Tween2PosY, m1Tween1Duration, m1Tween2Duration)
	end

	local m0StartPosY = math.floor(startMinute / 10) * TEMPLATE_HEIGHT
	instance.m0MoveRoot.anchoredPosition = Vector3.Fetch(0, m0StartPosY, 0)
	bindData.m0Grid.anchoredPosition = Vector3.zero
	local h1StartPosY = startHour * TEMPLATE_HEIGHT
	instance.h1MoveRoot.anchoredPosition = Vector3.Fetch(0, h1StartPosY, 0)
	bindData.h1Grid.anchoredPosition = Vector3.zero
	local h0StartPosY = math.floor(startHour / 10) * TEMPLATE_HEIGHT
	instance.h0MoveRoot.anchoredPosition = Vector3.Fetch(0, h0StartPosY, 0)
	bindData.h0Grid.anchoredPosition = Vector3.zero
end

M.PlayInitialTweens = function(self, m1Tween1PosY, m1Tween2PosY, m1Tween1Duration, m1Tween2Duration)
	local m1Tween1 = self.instance.m1MoveRoot:DOLocalMoveY(m1Tween1PosY, m1Tween1Duration):SetEase(config.m1Tween1Ease)
	local m1Tween2 = self.instance.m1MoveRoot:DOLocalMoveY(m1Tween2PosY, m1Tween2Duration):SetEase(config.m1Tween2Ease)
	self.instance.endRealTime = self.instance.startRealTime + m1Tween1Duration + m1Tween2Duration

	if self.instance.m1Sequence then
		print("kill m1Sequence")
		self.instance.m1Sequence:Kill()
	end

	self.instance.m1Sequence = DOTween.Sequence()
	slot7 = self.instance.m1Sequence

	slot7:Append(m1Tween1)

	slot7 = self.instance.m1Sequence

	slot7:Append(m1Tween2)

	slot7 = self.instance.m1Sequence

	slot7:OnUpdate(self:CreateAction(self.OnM1Update))

	slot7 = self.instance.m1Sequence

	slot7:OnComplete(function ()
		self.instance.m1Sequence = nil
	end)

	if self.instance.animDuration <= 1 then
		self.instance.m1Shake = self.instance.m1ShakeRoot:DOShakePosition(self.instance.animDuration - 1, Vector3.Fetch(0, 80, 0), 80)
	end

	self.RegisterDefaultEvents(self)
end

M.AddEvent = function(self, elapsedMinutes, handler)
	if not self.instance.events[elapsedMinutes] then
		self.instance.events[elapsedMinutes] = {}
	end

	table.insert(self.instance.events[elapsedMinutes], handler)
end

M.RegisterDefaultEvents = function(self)
	self.AddEvent(self, 10 - self.instance.startMinute % 10, self.CreateAction(self, self.PlayM0Tween))
	self.AddEvent(self, 60 - self.instance.startMinute, self.CreateAction(self, self.PlayH1Tween))

	local startHour = self.instance.startHour
	local playH0TweenAtHour = {
		10,
		20,
		24,
		34,
		44,
		48
	}
	local h0Digits = {
		0,
		1,
		2,
		0,
		1,
		2
	}
	local _, nextPlayH0TweenAtHourIndex = array.find_if(playH0TweenAtHour, function (nextHour)
		return startHour <= nextHour
	end)

	for i = nextPlayH0TweenAtHourIndex, #playH0TweenAtHour do
		local elapsedMinutes = 60 * (playH0TweenAtHour[i] - startHour) - self.instance.startMinute

		if self.instance.totalMinute >= elapsedMinutes then
			break
		end

		elapsedMinutes = elapsedMinutes - 10

		self.AddEvent(self, elapsedMinutes, self.CreateActionWithArgs(self, self.PlayH0Tween, h0Digits[i]))
	end
end

M.OnM1Update = function(self)
	local m1MoveRootPos = self.instance.m1MoveRoot.anchoredPosition
	local m1GridPos = self.bindData.m1Grid.anchoredPosition
	local m1Length = TEMPLATE_HEIGHT * 10

	while m1Length >= m1MoveRootPos.y + m1GridPos.y + config.eps do
		m1GridPos.y = m1GridPos.y - m1Length
		self.bindData.m1Grid.anchoredPosition = m1GridPos
	end

	local doShake = false

	if doShake then
		m1MoveRootPos.y = m1MoveRootPos.y + (math.random() - 0.5) * TEMPLATE_HEIGHT
		self.instance.m1MoveRoot.anchoredPosition = m1MoveRootPos
	end

	local totalM1PosY = m1MoveRootPos.y
	local elapsedMinutes = math.floor((totalM1PosY - self.instance.startMinute % 10 * TEMPLATE_HEIGHT + config.eps) / TEMPLATE_HEIGHT)

	for time, handlers in pairs(self.instance.events) do
		if time < elapsedMinutes then
			for _, handler in ipairs(handlers) do
				handler(elapsedMinutes)
			end

			self.instance.events[time] = nil
		end
	end
end

M.PlayM0Tween = function(self)
	if self.instance.m0TweenActive then
		return
	end

	self.instance.m0TweenActive = true
	local currentTime = Time.time
	local remainTime = self.instance.endRealTime - currentTime
	local m0StartPosY = self.instance.m0MoveRoot.anchoredPosition.y
	local m0TotalMinute = (math.floor((self.instance.startMinute + self.instance.totalMinute) / 10) - math.floor(self.instance.startMinute / 10)) * 10

	if m0TotalMinute >= config.m0Tween2Minute then
		local m0TargetPosY = m0StartPosY + TEMPLATE_HEIGHT

		self.instance.m0MoveRoot:DOLocalMoveY(m0TargetPosY, config.m0Tween2Duration):SetEase(config.m0ShortEase)

		return
	end

	local m0Tween2Minute = config.m0Tween2Minute
	local m0Tween1Minute = m0TotalMinute - m0Tween2Minute
	local m0Tween2Duration = config.m0Tween2Duration
	local m0Tween1Duration = remainTime - m0Tween2Duration
	local m0Tween1PosY = m0StartPosY + math.floor(m0Tween1Minute / 10) * TEMPLATE_HEIGHT
	local m0Tween2PosY = m0Tween1PosY + math.floor(m0Tween2Minute / 10) * TEMPLATE_HEIGHT

	self:TryKillTweener(self.instance.m0Sequence)

	self.instance.m0Sequence = DOTween.Sequence()
	self.instance.m0Tween1Active = true
	slot11 = self.instance.m0MoveRoot
	slot11 = slot11:DOLocalMoveY(m0Tween1PosY, m0Tween1Duration)
	local m0Tween1 = slot11:SetEase(config.m0Tween1Ease)
	slot12 = self.instance.m0Sequence

	slot12:Append(m0Tween1)

	slot12 = self.instance.m0Sequence

	slot12:AppendCallback(function ()
		self.instance.m0Tween1Active = false
	end)

	slot12 = self.instance.m0MoveRoot
	slot12 = slot12:DOLocalMoveY(m0Tween2PosY, m0Tween2Duration)
	local m0Tween2 = slot12:SetEase(config.m0Tween2Ease)
	slot13 = self.instance.m0Sequence

	slot13:Append(m0Tween2)

	slot13 = self.instance.m0Sequence

	slot13:OnUpdate(self:CreateAction(self.OnM0Update))

	slot13 = self.instance.m0Sequence

	slot13:OnComplete(function ()
		self.instance.m0Sequence = nil
	end)
end

M.OnM0Update = function(self)
	local m0MoveRootPos = self.instance.m0MoveRoot.anchoredPosition
	local m0GridPos = self.bindData.m0Grid.anchoredPosition
	local m0Length = TEMPLATE_HEIGHT * 6

	if m0Length >= m0MoveRootPos.y + m0GridPos.y + config.eps then
		m0GridPos.y = m0GridPos.y - m0Length
		self.bindData.m0Grid.anchoredPosition = m0GridPos
	end
end

M.PlayH0Tween = function(self, startVal)
	local h0StartPosY = startVal * TEMPLATE_HEIGHT
	local h0TargetPosY = h0StartPosY + TEMPLATE_HEIGHT

	if self.instance.h0Tweener then
		print("kill h0Tweener")
		self.instance.h0Tweener:Kill()
	end

	self.instance.h0MoveRoot.anchoredPosition = Vector3.Fetch(0, h0StartPosY, 0)
	slot5 = self.instance.h0MoveRoot
	slot5 = slot5:DOLocalMoveY(h0TargetPosY, config.h0TweenDuration)
	self.instance.h0Tweener = slot5:SetEase(config.h0Ease)
	slot4 = self.instance.h0Tweener

	slot4:OnComplete(function ()
		self.instance.h0Tweener = nil
	end)
end

M.PlayH1Tween = function(self)
	if self.instance.h1TweenActive then
		return
	end

	self.instance.h1TweenActive = true
	local currentTime = Time.time
	local remainTime = self.instance.endRealTime - currentTime
	local h1StartPosY = self.instance.h1MoveRoot.anchoredPosition.y
	local h1DeltaHour = math.floor((self.instance.startMinute + self.instance.totalMinute) / 60)
	local h1Tween2Hour = config.h1Tween2Hours
	local h1Tween1Hour = h1DeltaHour - h1Tween2Hour
	local h1Tween2Duration = config.h1Tween2Duration
	local h1Tween1Duration = remainTime - h1Tween2Duration
	local h1Tween1PosY = h1StartPosY + h1Tween1Hour * TEMPLATE_HEIGHT
	local h1Tween2PosY = h1Tween1PosY + h1Tween2Hour * TEMPLATE_HEIGHT

	if self.instance.h1Sequence then
		print("kill h1Sequence")
		self.instance.h1Sequence:Kill()
	end

	self.instance.h1Sequence = DOTween.Sequence()

	if h1Tween1Hour <= 0 then
		self.instance.h1Tween1Active = true
		slot11 = self.instance.h1MoveRoot
		slot11 = slot11:DOLocalMoveY(h1Tween1PosY, h1Tween1Duration)
		local h1Tween1 = slot11:SetEase(config.h1Tween1Ease)
		slot12 = self.instance.h1Sequence

		slot12:Append(h1Tween1)

		slot12 = self.instance.h1Sequence

		slot12:AppendCallback(function ()
			self.instance.h1Tween1Active = false
		end)
	end

	slot11 = self.instance.h1MoveRoot
	slot11 = slot11:DOLocalMoveY(h1Tween2PosY, h1Tween2Duration)
	local h1Tween2 = slot11:SetEase(config.h1Tween2Ease)
	slot12 = self.instance.h1Sequence

	slot12:Append(h1Tween2)

	slot12 = self.instance.h1Sequence

	slot12:OnUpdate(self:CreateAction(self.OnH1Update))

	slot12 = self.instance.h1Sequence

	slot12:OnComplete(function ()
		self.instance.h1Sequence = nil
	end)
end

M.OnH1Update = function(self)
	local h1MoveRootPos = self.instance.h1MoveRoot.anchoredPosition
	local h1GridPos = self.bindData.h1Grid.anchoredPosition
	local h1Length = TEMPLATE_HEIGHT * 24

	if h1Length >= h1MoveRootPos.y + h1GridPos.y then
		h1GridPos.y = h1GridPos.y - h1Length
		self.bindData.h1Grid.anchoredPosition = h1GridPos
	end
end

M.OnDestroy = function(self)
	self.CleanUp(self)
end

M.CleanUp = function(self)
	if self.instance ~= nil then
		return
	end

	self.TryKillTweener(self, self.instance.m0Sequence)
	self.TryKillTweener(self, self.instance.m1Sequence)
	self.TryKillTweener(self, self.instance.m1Shake)
	self.TryKillTweener(self, self.instance.h0Tweener)
	self.TryKillTweener(self, self.instance.h1Sequence)

	self.instance = nil
end

M.TryKillTweener = function(self, tweener)
	if tweener then
		tweener.Kill(tweener)
	end
end
