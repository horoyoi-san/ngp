-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingBallMirror.lua
-- Decompiled from: 00659_BowlingBallMirror.lua_862f463fb7ec.luajit

gBowlingBallMirror = DefClass("BowlingBallMirror", gBowlingBallMirror)
local BowlingBallMirror = gBowlingBallMirror
local BowlingBallUtils = require("LX6/MiniGame/BowlingGame/BowlingBallUtils")

BowlingBallMirror.ctor = function(self, game)
	self.game = game
end

BowlingBallMirror.StartObserve = function(self, sceneItemId, forcePercentage)
	if sceneItemId ~= nil then
		return
	end

	if self.active and self.sceneItemId ~= sceneItemId then
		return
	end

	self:StopObserve(true)

	self.active = true
	self.sceneItemId = sceneItemId
	self.startTime = Time.time
	self.hasStartedFollow = false
	self.hasReachedEndCamera = false
	self.hasPlayedDropSound = false
	local ballGo = BowlingBallUtils:GetSceneItemGo(self.sceneItemId)
	self.transform = ballGo and ballGo.transform
	self.lastObservedPosition = self.transform and self.transform.position or nil
	self.lastObservedTime = Time.time
	self.rollSoundId = self.game:StartBallLaunchEffects(sceneItemId, forcePercentage, self, function ()
		return self.active and self.sceneItemId ~= sceneItemId
	end)

	self.game:SetEndVCamActive(false)

	self.updateTimer = FrameTimer.New(self:CreateAction(self.Update), 1, -1):Start()
end

BowlingBallMirror.CalculateObservedVelocity = function(self, currentPosition, currentTime)
	local velocity = 0

	if self.lastObservedPosition == nil and self.lastObservedTime == nil then
		local deltaTime = currentTime - self.lastObservedTime

		if deltaTime <= 0 then
			velocity = (currentPosition - self.lastObservedPosition).magnitude / deltaTime
		end
	end

	self.lastObservedPosition = currentPosition
	self.lastObservedTime = currentTime

	return velocity
end

BowlingBallMirror.Update = function(self)
	if not self.active or self.sceneItemId ~= nil then
		return
	end

	local ballGo = BowlingBallUtils:GetSceneItemGo(self.sceneItemId)

	if gClientUtils.IsNil(ballGo) then
		if Time.time <= (self.startTime or 0) + 2 then
			self.StopObserve(self, false)
		end

		return
	end

	if not self.hasStartedFollow then
		self.game.camera:StartFollowFromSync(ballGo)

		self.hasStartedFollow = true
	end

	local transform = ballGo.transform

	if gClientUtils.IsNil(transform) then
		self.StopObserve(self, false)

		return
	end

	local currentTime = Time.time
	local velocity = self.CalculateObservedVelocity(self, transform.position, currentTime)

	if self.rollSoundId and self.rollSoundId == 0 then
		self.game:SetSoundRTPCValue(self.rollSoundId, gSoundMgr.RTPCGroup.ObjectVelocity, velocity)
	end

	local sceneTransform = self.game.ballLauncher.sceneNode.transform
	local localPosition = sceneTransform.InverseTransformPoint(sceneTransform, transform.position)
	local curY = localPosition.y
	local curZ = localPosition.z

	if not self.hasReachedEndCamera and BowlingBallUtils:IsInEndCameraZone(curZ) then
		self.game:SetEndVCamActive(true)

		self.hasReachedEndCamera = true
	end

	if BowlingBallUtils:IsInBackPitZone(curY, curZ) then
		if not self.hasPlayedDropSound then
			self.game:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallDropPit)

			self.hasPlayedDropSound = true
		end

		self.StopObserve(self, false)

		return
	end

	if Time.time <= (self.startTime or 0) + 15 then
		self.StopObserve(self, false)
	end
end

BowlingBallMirror.StopObserve = function(self, closeEndVCam)
	if self.updateTimer then
		self.updateTimer:Stop()

		self.updateTimer = nil
	end

	if self.sceneItemId == nil then
		BowlingBallUtils:SetColliderSound(self.sceneItemId, 0)
	end

	if self.rollSoundId and self.rollSoundId == 0 then
		self.game:StopSound(self.rollSoundId)
	end

	if closeEndVCam then
		self.game:SetEndVCamActive(false)
	end

	if self.hasStartedFollow then
		self.game.camera:StopFollow()
	end

	self.active = false
	self.sceneItemId = nil
	self.startTime = nil
	self.hasStartedFollow = false
	self.hasReachedEndCamera = false
	self.hasPlayedDropSound = false
	self.rollSoundId = nil
	self.lastObservedPosition = nil
	self.lastObservedTime = nil
end

BowlingBallMirror.Destroy = function(self)
	self.StopObserve(self, true)

	self.game = nil
end

return BowlingBallMirror
