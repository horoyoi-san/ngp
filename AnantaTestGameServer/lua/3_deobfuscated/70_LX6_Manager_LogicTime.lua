local Time = Time
local M = {
	timeScale = 1,
	unscaledTime = 0,
	time = 0,
	fixedDeltaTime = 0,
	frameCount = 0,
	unscaledDeltaTime = 0,
	deltaTime = 0,
	nonNpcUnit = {},
	OnInit = function (self)
		self:InitTime()
	end,
	OnUpdate = function (self, time, timescale, gLogicDeltaTime, unscaledTime, unscaledDeltaTime, defaultTime, defaultUnscaledTime, defaultFrameCount, engineDeltaTime)
		Time:SetTime(defaultTime, defaultUnscaledTime, defaultFrameCount)

		self.deltaTime = gLogicDeltaTime
		self.time = time
		self.timeScale = timescale
		self.unscaledTime = unscaledTime
		self.unscaledDeltaTime = unscaledDeltaTime
		self.frameCount = defaultFrameCount
	end,
	OnFixedUpdate = function (self, fixedDeltaTime, defaultFixedDeltaTime)
		Time:SetFixedDelta(defaultFixedDeltaTime)

		self.fixedDeltaTime = fixedDeltaTime
	end,
	InitTime = function (self)
		self.timeScale = Time.timeScale
		self.deltaTime = Time.deltaTime
		self.time = Time.time
		self.unscaledDeltaTime = Time.unscaledDeltaTime
		self.unscaledTime = Time.unscaledTime
		self.fixedDeltaTime = Time.fixedDeltaTime
		self.frameCount = Time.frameCount
	end
}
gLogicTime = M
