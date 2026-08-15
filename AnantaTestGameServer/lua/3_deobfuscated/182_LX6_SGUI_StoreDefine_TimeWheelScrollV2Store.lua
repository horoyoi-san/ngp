C_TimeWheelScrollV2Store = DefClass("C_TimeWheelScrollV2Store", C_TimeWheelScrollV2Store, C_StoreGroup)
GroupName2Class.TimeWheelScrollV2Store = C_TimeWheelScrollV2Store
local M = C_TimeWheelScrollV2Store
local Const = gClientConst
local Time = Time
local Vector3 = Vector3
local DOTween = DOTween
local Ease = DG.Tweening.Ease

local function print(...)
	print_debug("[TimeWheelScrollV2Store] ", ...)
end

local TEMPLATE_HEIGHT = 300
local HALF_TEMPLATE_HEIGHT = TEMPLATE_HEIGHT / 2
local config = {
	m0Tween2Duration = 1,
	m0Tween2Minute = 20,
	h1Tween2Duration = 1,
	eps = 1,
	m1Tween2Minute = 5,
	m1Tween2Duration = 1,
	h1Tween2Hours = 1,
	h0TweenDuration = 0.75,
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

function M:StartWheel(startTime, endTime, duration, initOnly)
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
		self:PlayInitialTweens(m1Tween1PosY, m1Tween2PosY, m1Tween1Duration, m1Tween2Duration)
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

function M:PlayInitialTweens(m1Tween1PosY, m1Tween2PosY, m1Tween1Duration, m1Tween2Duration)
	local m1Tween1 = self.instance.m1MoveRoot:DOLocalMoveY(m1Tween1PosY, m1Tween1Duration):SetEase(config.m1Tween1Ease)
	local m1Tween2 = self.instance.m1MoveRoot:DOLocalMoveY(m1Tween2PosY, m1Tween2Duration):SetEase(config.m1Tween2Ease)
	self.instance.endRealTime = self.instance.startRealTime + m1Tween1Duration + m1Tween2Duration

	if self.instance.m1Sequence then
		print("kill m1Sequence")
		self.instance.m1Sequence:Kill()
	end

	self.instance.m1Sequence = DOTween.Sequence()

	self.instance.m1Sequence:Append(m1Tween1)
	self.instance.m1Sequence:Append(m1Tween2)
	self.instance.m1Sequence:OnUpdate(self:CreateAction(self.OnM1Update))
	self.instance.m1Sequence:OnComplete(function ()
		self.instance.m1Sequence = nil
	end)

	if self.instance.animDuration > 1 then
		self.instance.m1Shake = self.instance.m1ShakeRoot:DOShakePosition(self.instance.animDuration - 1, Vector3.Fetch(0, 80, 0), 80)
	end

	self:RegisterDefaultEvents()
end

function M:AddEvent(elapsedMinutes, handler)
	if not self.instance.events[elapsedMinutes] then
		self.instance.events[elapsedMinutes] = {}
	end

	table.insert(self.instance.events[elapsedMinutes], handler)
end

function M:RegisterDefaultEvents()
	self:AddEvent(10 - self.instance.startMinute % 10, self:CreateAction(self.PlayM0Tween))
	self:AddEvent(60 - self.instance.startMinute, self:CreateAction(self.PlayH1Tween))

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
		return startHour < nextHour
	end)

	for i = nextPlayH0TweenAtHourIndex, #playH0TweenAtHour do
		local elapsedMinutes = 60 * (playH0TweenAtHour[i] - startHour) - self.instance.startMinute

		if self.instance.totalMinute < elapsedMinutes then
			break
		end

		elapsedMinutes = elapsedMinutes - 10

		self:AddEvent(elapsedMinutes, self:CreateActionWithArgs(self.PlayH0Tween, h0Digits[i]))
	end
end

function M:OnM1Update()
	local m1MoveRootPos = self.instance.m1MoveRoot.anchoredPosition
	local m1GridPos = self.bindData.m1Grid.anchoredPosition
	local m1Length = TEMPLATE_HEIGHT * 10

	while m1Length < m1MoveRootPos.y + m1GridPos.y + config.eps do
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
		if time <= elapsedMinutes then
			for _, handler in ipairs(handlers) do
				handler(elapsedMinutes)
			end

			self.instance.events[time] = nil
		end
	end
end

function M:PlayM0Tween()
	if self.instance.m0TweenActive then
		return
	end

	self.instance.m0TweenActive = true
	local currentTime = Time.time
	local remainTime = self.instance.endRealTime - currentTime
	local m0StartPosY = self.instance.m0MoveRoot.anchoredPosition.y
	local m0TotalMinute = (math.floor((self.instance.startMinute + self.instance.totalMinute) / 10) - math.floor(self.instance.startMinute / 10)) * 10

	if m0TotalMinute < config.m0Tween2Minute then
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
	local m0Tween1 = self.instance.m0MoveRoot:DOLocalMoveY(m0Tween1PosY, m0Tween1Duration):SetEase(config.m0Tween1Ease)

	self.instance.m0Sequence:Append(m0Tween1)
	self.instance.m0Sequence:AppendCallback(function ()
		self.instance.m0Tween1Active = false
	end)

	local m0Tween2 = self.instance.m0MoveRoot:DOLocalMoveY(m0Tween2PosY, m0Tween2Duration):SetEase(config.m0Tween2Ease)

	self.instance.m0Sequence:Append(m0Tween2)
	self.instance.m0Sequence:OnUpdate(self:CreateAction(self.OnM0Update))
	self.instance.m0Sequence:OnComplete(function ()
		self.instance.m0Sequence = nil
	end)
end

function M:OnM0Update()
	local m0MoveRootPos = self.instance.m0MoveRoot.anchoredPosition
	local m0GridPos = self.bindData.m0Grid.anchoredPosition
	local m0Length = TEMPLATE_HEIGHT * 6

	if m0Length < m0MoveRootPos.y + m0GridPos.y + config.eps then
		m0GridPos.y = m0GridPos.y - m0Length
		self.bindData.m0Grid.anchoredPosition = m0GridPos
	end
end

function M:PlayH0Tween(startVal)
	local h0StartPosY = startVal * TEMPLATE_HEIGHT
	local h0TargetPosY = h0StartPosY + TEMPLATE_HEIGHT

	if self.instance.h0Tweener then
		print("kill h0Tweener")
		self.instance.h0Tweener:Kill()
	end

	self.instance.h0MoveRoot.anchoredPosition = Vector3.Fetch(0, h0StartPosY, 0)
	self.instance.h0Tweener = self.instance.h0MoveRoot:DOLocalMoveY(h0TargetPosY, config.h0TweenDuration):SetEase(config.h0Ease)

	self.instance.h0Tweener:OnComplete(function ()
		self.instance.h0Tweener = nil
	end)
end

function M:PlayH1Tween()
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

	if h1Tween1Hour > 0 then
		self.instance.h1Tween1Active = true
		local h1Tween1 = self.instance.h1MoveRoot:DOLocalMoveY(h1Tween1PosY, h1Tween1Duration):SetEase(config.h1Tween1Ease)

		self.instance.h1Sequence:Append(h1Tween1)
		self.instance.h1Sequence:AppendCallback(function ()
			self.instance.h1Tween1Active = false
		end)
	end

	local h1Tween2 = self.instance.h1MoveRoot:DOLocalMoveY(h1Tween2PosY, h1Tween2Duration):SetEase(config.h1Tween2Ease)

	self.instance.h1Sequence:Append(h1Tween2)
	self.instance.h1Sequence:OnUpdate(self:CreateAction(self.OnH1Update))
	self.instance.h1Sequence:OnComplete(function ()
		self.instance.h1Sequence = nil
	end)
end

function M:OnH1Update()
	local h1MoveRootPos = self.instance.h1MoveRoot.anchoredPosition
	local h1GridPos = self.bindData.h1Grid.anchoredPosition
	local h1Length = TEMPLATE_HEIGHT * 24

	if h1Length < h1MoveRootPos.y + h1GridPos.y then
		h1GridPos.y = h1GridPos.y - h1Length
		self.bindData.h1Grid.anchoredPosition = h1GridPos
	end
end

function M:OnDestroy()
	if self.instance == nil then
		return
	end

	self:TryKillTweener(self.instance.m0Sequence)
	self:TryKillTweener(self.instance.m1Sequence)
	self:TryKillTweener(self.instance.m1Shake)
	self:TryKillTweener(self.instance.h0Tweener)
	self:TryKillTweener(self.instance.h1Sequence)

	self.instance = nil
end

function M:TryKillTweener(tweener)
	if tweener then
		tweener:Kill()
	end
end
