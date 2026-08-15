gBowlingCamera = DefClass("BowlingCamera", gBowlingCamera)
local BowlingCamera = gBowlingCamera
local Config = require("LX6/MiniGame/BowlingGame/BowlingConfig").Launcher
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")

function BowlingCamera:ctor()
	return
end

function BowlingCamera:Destroy()
	self:StopFollow()

	self.camera = nil
	self.virtualCamera = nil
	self.target = nil
	self.lastTargetPos = nil
	self.velocityPosition = nil
	self.currentVelocity = nil
end

function BowlingCamera:InitCamera(cam, virtualCamera)
	self.camera = cam
	self.virtualCamera = virtualCamera

	virtualCamera.gameObject:SetActive(true)

	self.defaultPosition = self.camera.transform.position
	self.defaultRotation = self.camera.transform.rotation
	self.followDistance = Vector3.New(Config.fCamPosOffset.x, Config.fCamPosOffset.y, Config.fCamPosOffset.z)
	self.followSpeed = 5
	self.damping = 0.1
	self.smoothTime = 0.1
	self.positionLerpSpeed = 4
	self.rotationLerpSpeed = 5
	self.baseFollowSpeed = 4
	self.speedMultiplier = 0.8
	self.minFollowSpeed = 2
	self.maxFollowSpeed = 10
	self.velocityPosition = Vector3.zero
	self.currentVelocity = Vector3.zero
	self.lastTargetPos = nil
	self.isFollowing = false
	self.target = nil
	self.minDistance = 4
	self.maxDistance = 8
	self.heightOffset = 2
	self.lookAhead = 2
	self.rotationSpeed = 3
	self.smoothFollow = true
	self.minHeight = 1
	self.maxHeight = 6
	self.boundaryLeft = -5
	self.boundaryRight = 5
end

function BowlingCamera:StartFollow(ball)
	self.target = ball

	self:StartFollowImpl(ball.transform)

	if gBowlingGameManager:IsOnlineGame() then
		self:BroadcastBallFollow(ball)
	end
end

function BowlingCamera:StartFollowFromSync(ballGo)
	self:StartFollowImpl(ballGo.transform)
	gBowlingGameManager.currentGame.timelineManager:ControlCameraPriority(false)
end

function BowlingCamera:StartFollowImpl(transform)
	self.virtualCamera.transform.position = gCS.CameraDataMgr.MainCamera.transform.position
	self.virtualCamera.Follow = transform
	self.virtualCamera.LookAt = transform
	self.isFollowing = true
	self.lastTargetPos = nil
end

function BowlingCamera:StopFollow(fromSync, calledByResetCamera)
	if not fromSync and not calledByResetCamera then
		self:BroadcastStopFollow()
	end

	if gClientUtils.NotNil(self.virtualCamera) then
		self.virtualCamera.Follow = nil
		self.virtualCamera.LookAt = nil
	end

	self.isFollowing = false
	self.target = nil
end

function BowlingCamera:ResetCamera(fromSync)
	if not fromSync and gBowlingGameManager:IsOnlineGame() then
		self:BroadcastBallStop()
	end

	if self.camera then
		self.camera.transform.position = self.defaultPosition
		self.camera.transform.rotation = self.defaultRotation
	end

	self:StopFollow(fromSync, true)
end

function BowlingCamera:SetCameraTrans(pos, rot)
	if self.camera then
		self.camera.transform.position = pos
		self.camera.transform.rotation = rot
	end
end

function BowlingCamera:UpdateCameraTransform()
	if not self.isFollowing or not self.target then
		return
	end

	if not gClientUtils.NotNil(self.target) then
		self.isFollowing = false
		self.target = nil

		return
	end

	local transform = self.target.transform

	if not gClientUtils.NotNil(transform) then
		self.isFollowing = false
		self.target = nil

		return
	end

	local targetPos = transform.localPosition
	local targetRb = self.target:GetComponent(typeof(UnityEngine.Rigidbody))
	local targetVelocity = targetRb.velocity
	local ballSpeed = targetVelocity.magnitude
	local dynamicSpeed = math.min(self.maxFollowSpeed, math.max(self.minFollowSpeed, self.baseFollowSpeed + ballSpeed * self.speedMultiplier))
	local smoothedTargetPos = self:SmoothPosition(targetPos)
	local desiredPosition = smoothedTargetPos + Vector3.New(0, self.followDistance.y, self.followDistance.z)
	self.camera.transform.localPosition = Vector3.Lerp(self.camera.transform.localPosition, desiredPosition, Time.deltaTime * dynamicSpeed)

	if ballSpeed > 0.1 then
		local lookRotation = Quaternion.Euler(Config.fCamRot.x, Config.fCamRot.y, Config.fCamRot.z)
		self.camera.transform.localRotation = Quaternion.Slerp(self.camera.transform.localRotation, lookRotation, Time.deltaTime * dynamicSpeed)
	end
end

function BowlingCamera:SmoothPosition(targetPos)
	if not self.lastTargetPos then
		self.lastTargetPos = targetPos

		return targetPos
	end

	local distance = Vector3.Distance(self.lastTargetPos, targetPos)

	if distance < 0.001 then
		return self.lastTargetPos
	end

	local smoothedPos = Vector3.Lerp(self.lastTargetPos, targetPos, Time.deltaTime * self.baseFollowSpeed)
	self.lastTargetPos = smoothedPos

	return smoothedPos
end

function BowlingCamera:BroadcastBallFollow(ball)
	local ballSceneItemId = ball.sceneItemId

	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.BallCameraFollow, {
		ulong.tonum2(ballSceneItemId)
	})
end

function BowlingCamera:BroadcastBallStop()
	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.ResetCamera)
end

function BowlingCamera:BroadcastStopFollow()
	gBowlingGameManager:BroadcastBowlingClientInfo(BowlingConstants.SyncDataType.BallCameraStopFollow)
end

function BowlingCamera:AddShake(intensity, duration)
	self.shakeIntensity = intensity
	self.shakeDuration = duration
	self.shakeStartTime = Time.time

	if self.shakeDuration > 0 then
		local elapsed = Time.time - self.shakeStartTime

		if elapsed < self.shakeDuration then
			local strength = self.shakeIntensity * (1 - elapsed / self.shakeDuration)
			local offset = Vector3.New(UnityEngine.Random.Range(-1, 1), UnityEngine.Random.Range(-1, 1), 0) * strength
			self.camera.transform.localPosition = self.camera.transform.localPosition + offset
		end
	end
end
