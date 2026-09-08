-- Original chunk: @Lua\LuaFiles\LX6\Manager\LogicTime.lua
-- Decompiled from: 00274_LogicTime.lua_99f80ca20ba5.luajit

local Time = Time
local M = {
	["WNal}="] = 1,
	["zx\\xbftM\\xbe\\xf7C^ssI"] = 0,
	["n+p^"] = 0,
	["\\xe1\\x93\t\\xe95\\xe3\\xfe\\x89ً--"] = 0,
	["UHϰ\\x81+\\xb7\\xc7\\xfc"] = 0,
	["a\\xf24\\xef(;*\\xc7E%\\xd9_\\x8d8K\\xcb\\xe3"] = 0,
	["GB`}O*="] = 0,
	nonNpcUnit = {},
	OnInit = function (self)
		self.InitTime(self)
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
