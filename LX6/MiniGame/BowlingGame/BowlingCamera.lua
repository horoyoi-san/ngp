-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingCamera.lua
-- Decompiled from: 00643_BowlingCamera.lua_abe242b5642b.luajit

gBowlingCamera = DefClass("BowlingCamera", gBowlingCamera)
local BowlingCamera = gBowlingCamera

BowlingCamera.ctor = function(self, game)
	self.game = game
end

BowlingCamera.Destroy = function(self)
	self.StopFollow(self)

	self.camera = nil
	self.virtualCamera = nil
end

BowlingCamera.InitCamera = function(self, cam, virtualCamera)
	self.camera = cam
	self.virtualCamera = virtualCamera

	virtualCamera.gameObject:SetActive(true)

	self.defaultPosition = self.camera.transform.position
	self.defaultRotation = self.camera.transform.rotation
end

BowlingCamera.StartFollow = function(self, ball)
	self.StartFollowImpl(self, ball.transform)
end

BowlingCamera.StartFollowFromSync = function(self, ballGo)
	self:StartFollowImpl(ballGo.transform)
	self.game.timelineManager:ControlCameraPriority(false)
end

BowlingCamera.StartFollowImpl = function(self, transform)
	self.virtualCamera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.virtualCamera.Follow = transform
	self.virtualCamera.LookAt = transform
end

BowlingCamera.StopFollow = function(self)
	if gClientUtils.NotNil(self.virtualCamera) then
		self.virtualCamera.Follow = nil
		self.virtualCamera.LookAt = nil
	end
end

BowlingCamera.ResetCamera = function(self)
	if self.camera then
		self.camera.transform.position = self.defaultPosition
		self.camera.transform.rotation = self.defaultRotation
	end

	self.StopFollow(self)
end
