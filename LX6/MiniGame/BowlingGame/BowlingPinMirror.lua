-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingPinMirror.lua
-- Decompiled from: 00660_BowlingPinMirror.lua_d3f40351447d.luajit

gBowlingPinMirror = DefClass("BowlingPinMirror", gBowlingPinMirror)
local BowlingPinMirror = gBowlingPinMirror

BowlingPinMirror.ctor = function(self, game)
	self.game = game
end

BowlingPinMirror.StartObserve = function(self)
	self:StopObserve()

	self.active = true
	self.startTime = Time.time
	self.updateTimer = FrameTimer.New(self:CreateAction(self.Update), 1, -1):Start()
end

BowlingPinMirror.TryPlayPinDropSound = function(self, pin)
	if pin ~= nil or pin.hasDestroy or pin.pinDropSoundPlayed then
		return
	end

	if gClientUtils.IsNil(pin.transform) then
		return
	end

	local localPosition = pin.transform.localPosition

	if localPosition.y <= 0 or localPosition.z >= -19.5 then
		self.game:PlaySound(LTConfig.PoiGameConfig.BowlingSound_PinDropPit)

		pin.pinDropSoundPlayed = true
	end
end

BowlingPinMirror.Update = function(self)
	if not self.active then
		return
	end

	local pinSetter = self.game and self.game.pinSetter

	if pinSetter ~= nil or table.isNilOrEmpty(pinSetter.pinList) then
		if Time.time <= (self.startTime or 0) + 1 then
			self.StopObserve(self)
		end

		return
	end

	local hasActivePin = false

	for _, pin in ipairs(pinSetter.pinList) do
		if pin and not pin.hasDestroy then
			hasActivePin = true

			self.TryPlayPinDropSound(self, pin)
			pin.TryMirrorRecycle(pin)
		end
	end

	if not hasActivePin or Time.time <= (self.startTime or 0) + 12 then
		self.StopObserve(self)
	end
end

BowlingPinMirror.StopObserve = function(self)
	if self.updateTimer then
		self.updateTimer:Stop()

		self.updateTimer = nil
	end

	self.active = false
	self.startTime = nil
end

BowlingPinMirror.Destroy = function(self)
	self.StopObserve(self)

	self.game = nil
end

return BowlingPinMirror
