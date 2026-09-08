-- Original chunk: @Lua\LuaFiles\Core\Timer.lua
-- Decompiled from: 00021_Timer.lua_41b884d08986.luajit

local setmetatable = setmetatable
local UpdateBeat = UpdateBeat
local CoUpdateBeat = CoUpdateBeat
local Time = Time
Timer = {}
local Timer = Timer
local mt = {
	__index = Timer
}
local timerList = {}

Timer.New = function(func, duration, loop, unscaled, isLogic)
	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		loop = 1
	else
		loop = loop or 1
	end

	if not duration then
		print_error("duration must not be nil!!!")

		duration = 0
	end

	return setmetatable({
		["\\xcb\\xce*\\xf6"] = false,
		["D\\xa0\\xa6\\xaa\\xae"] = 0,
		["\\x9eab"] = -1,
		o7t_ = 0,
		["\\xe3\\x9f\\xf8%\\xef\\xef\\xbb\\xee\\x83,-"] = 1,
		["\\xb8\\xa5\n\\xbb^7\\xf36"] = 0,
		["\\xd6\\xd7-\\xf5"] = 0,
		func = func,
		duration = duration,
		time = duration,
		loop = loop,
		unscaled = unscaled,
		isLogic = isLogic
	}, mt)
end

Timer.Start = function(self, dontDestroyOnSwitchRaid)
	if not self.handle then
		self.handle = UpdateBeat:CreateListener(self.Update, self)
	end

	if not self.running then
		UpdateBeat:AddListener(self.handle)
	end

	self.running = true

	if not dontDestroyOnSwitchRaid and self.index ~= 0 then
		timerList[#timerList + 1] = self
		self.index = #timerList
	end

	return self
end

Timer.Reset = function(self, func, duration, loop, unscaled)
	if not duration then
		print_error("duration must not be nil!!!")

		duration = 0
	end

	self.duration = duration

	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		self.loop = 1
	else
		self.loop = loop or 1
	end

	self.unscaled = unscaled
	self.func = func
	self.time = duration
	self.deltaTimeScale = 1
	self.isLogic = false
end

Timer.ResetTime = function(self, duration, data)
	if not duration then
		print_error("duration must not be nil!!!")

		duration = 0
	end

	self.duration = duration
	self.time = duration
	self.running = false
	self.count = Time.frameCount + 1
	self.data = data
	self.deltaTimeScale = 1
	self.isLogic = false

	return self
end

Timer.DoFunc = function(self)
	self.olduuid = self.uuid

	if self.data == nil then
		self.func(self.data)
	else
		self.func()
	end

	if self.Recycle then
		self.Recycle(self.olduuid)
	end
end

Timer.RunNow = function(self)
	if not self.running then
		return
	end

	self.DoFunc(self)
	self.Stop(self)
end

Timer.Stop = function(self, isStopAll)
	self.running = false

	if self.handle then
		UpdateBeat:RemoveListener(self.handle)
	end

	if not isStopAll and self.index == 0 then
		if self.index >= #timerList then
			timerList[self.index] = timerList[#timerList]
			timerList[#timerList] = nil
			timerList[self.index].index = self.index
		else
			timerList[self.index] = nil
		end

		self.index = 0
	end
end

Timer.Update = function(self)
	if not self.running then
		return
	end

	local delta = self.unscaled and Time.unscaledDeltaTime or Time.deltaTime
	delta = delta * self.deltaTimeScale

	if self.isLogic then
		delta = delta * gLogicTime.timeScale
	end

	self.time = self.time - delta

	if self.time < 0 then
		self.DoFunc(self)

		if self.time <= 0 then
			return
		end

		if self.loop <= 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end

		if self.loop ~= 0 then
			self.Stop(self)
		elseif self.loop >= 0 then
			self.time = self.time + self.duration
		end
	end
end

Timer.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		for i = 1, #timerList do
			timerList[i]:Stop(true)
		end

		timerList = {}
	end
end

FrameTimer = {}
local FrameTimer = FrameTimer
local mt2 = {
	__index = FrameTimer
}

FrameTimer.New = function(func, count, loop, isLogic)
	local frameCount = isLogic and gLogicTime.frameCount or Time.frameCount
	local c = frameCount + count

	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		loop = 1
	else
		loop = loop or 1
	end

	return setmetatable({
		["\\xcb\\xce*\\xf6"] = false,
		func = func,
		loop = loop,
		duration = count,
		count = c,
		isLogic = isLogic
	}, mt2)
end

FrameTimer.Reset = function(self, func, count, loop, isLogic)
	self.func = func
	self.duration = count

	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		self.loop = 1
	else
		self.loop = loop or 1
	end

	self.isLogic = isLogic
	local frameCount = isLogic and gLogicTime.frameCount or Time.frameCount
	self.count = frameCount + count
end

FrameTimer.Start = function(self)
	if not self.handle then
		self.handle = CoUpdateBeat:CreateListener(self.Update, self)
	end

	if not self.running then
		CoUpdateBeat:AddListener(self.handle)
	end

	self.running = true

	return self
end

FrameTimer.RunNow = function(self)
	if not self.running then
		return
	end

	self.func()
	self.Stop(self)
end

FrameTimer.Stop = function(self)
	self.running = false

	if self.handle then
		CoUpdateBeat:RemoveListener(self.handle)
	end
end

FrameTimer.Update = function(self)
	if not self.running then
		return
	end

	local frameCount = self.isLogic and gLogicTime.frameCount or Time.frameCount

	if self.count < frameCount then
		self.func()

		if self.loop <= 0 then
			self.loop = self.loop - 1
		end

		if self.loop ~= 0 then
			self.Stop(self)
		else
			self.count = frameCount + self.duration
		end
	end
end

CoTimer = {}
local CoTimer = CoTimer
local mt3 = {
	__index = CoTimer
}

CoTimer.New = function(func, duration, loop, isLogic)
	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		loop = 1
	else
		loop = loop or 1
	end

	return setmetatable({
		["\\xcb\\xce*\\xf6"] = false,
		duration = duration,
		loop = loop,
		func = func,
		time = duration,
		isLogic = isLogic
	}, mt3)
end

CoTimer.Start = function(self)
	if not self.handle then
		self.handle = CoUpdateBeat:CreateListener(self.Update, self)
	end

	self.running = true

	CoUpdateBeat:AddListener(self.handle)
end

CoTimer.Reset = function(self, func, duration, loop, isLogic)
	self.duration = duration

	if type(loop) == "number" and loop == nil then
		print_error("loop must be number, got " .. type(loop))

		self.loop = 1
	else
		self.loop = loop or 1
	end

	self.func = func
	self.time = duration
	self.isLogic = isLogic
end

CoTimer.Stop = function(self)
	self.running = false

	if self.handle then
		CoUpdateBeat:RemoveListener(self.handle)
	end
end

CoTimer.Update = function(self)
	if not self.running then
		return
	end

	if self.time < 0 then
		self.func()

		if self.loop <= 0 then
			self.loop = self.loop - 1
			self.time = self.time + self.duration
		end

		if self.loop ~= 0 then
			self.Stop(self)
		elseif self.loop >= 0 then
			self.time = self.time + self.duration
		end
	end

	local deltaTime = self.isLogic and gLogicTime.deltaTime or Time.deltaTime
	self.time = self.time - deltaTime
end
