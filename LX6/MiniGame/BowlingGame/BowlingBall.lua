-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingBall.lua
-- Decompiled from: 00639_BowlingBall.lua_c6061341a3fc.luajit

gBowlingBall = DefClass("BowlingBall", gBowlingBall)
local BowlingBall = gBowlingBall
local BowlingBallUtils = require("LX6/MiniGame/BowlingGame/BowlingBallUtils")

BowlingBall.ctor = function(self, args)
	self.sceneItemId = args.sceneItemId
	self.gameObject = args.gameObject
	self.ballType = args.ballType
	self.transform = self.gameObject.transform
	self.rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))
	self.sideForce = 0
	self.slipLen = 0
	self.createTime = Time.time
	self.sceneItemHold = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(args.sceneItemId)
	gBowlingGameManager.gameInstance.doNotDisableBallId = self.sceneItemId
	self.ballDropSoundPlayed = false
	self.game = args.game

	self:NotifySceneItemUpdate()
	gLuaClient:RegisterDynamicUpdate("gBowlingBall", self)
end

BowlingBall.Destroy = function(self)
	if self.hasDestroy then
		return
	end

	self.DoAfterSettle(self)

	if self.game.camera then
		self.game.camera:StopFollow()
	end

	gLuaClient:UnregisterDynamicUpdate("gBowlingBall")
	self:StopRigidbody()

	gBowlingGameManager.gameInstance.doNotDisableBallId = nil

	gBowlingGameManager:Return(self.ballType, self.gameObject)

	if gClientUtils.NotNil(self.rigidbody) then
		self.rigidbody.interpolation = UnityEngine.RigidbodyInterpolation.None
	end

	self.hasDestroy = true
end

BowlingBall.OnUpdate = function(self)
	local playerTrans = (gCS.MyPlayerManager.PlayerUnit or {}).PlayerObj

	if playerTrans ~= nil then
		return
	end

	if gClientUtils.IsNil(self.transform) then
		print_error("BowlingBall:OnUpdate() self.transform is nil")
		self.Destroy(self)

		return
	end

	local sqrMagnitude = (playerTrans.position - self.transform.position).sqrMagnitude
	local safeDistance = 30

	if sqrMagnitude <= safeDistance * safeDistance then
		self.Destroy(self)

		return
	end
end

BowlingBall.NotifySceneItemUpdate = function(self)
	if self.sceneItemHold then
		self.sceneItemHold:SyncScale(Vector3.one)
	end
end

BowlingBall.StopRigidbody = function(self)
	if gClientUtils.NotNil(self.rigidbody) then
		self.rigidbody.velocity = Vector3.zero
		self.rigidbody.angularVelocity = Vector3.zero
	end
end

BowlingBall.UpdateSideForceEffect = function(self)
	if self.rigidbody and self.sideForce == 0 then
		local forward = self.rigidbody.velocity.normalized
		local right = Vector3.Cross(Vector3.up, forward)
		local sideForceVector = right * self.sideForce

		self.rigidbody:AddForce(sideForceVector, UnityEngine.ForceMode.Acceleration)
	end
end

BowlingBall.EnablePhysics = function(self, enable, setMass)
	local rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))

	if gClientUtils.NotNil(rigidbody) then
		if setMass then
			rigidbody.mass = setMass
		end

		rigidbody.isKinematic = not enable
		rigidbody.detectCollisions = enable
	else
		print_error("BowlingBall:EnablePhysics() rigidbody is nil")

		return
	end

	local colliders = self.gameObject:GetComponents(typeof(UnityEngine.Collider))

	for i = 0, colliders.Length - 1 do
		colliders[i].enabled = enable
	end
end

BowlingBall.AddForce = function(self, force, forceMode)
	if self.IsRigidbodyInvalid(self) then
		return
	end

	forceMode = forceMode or UnityEngine.ForceMode.Impulse
	local worldForce = self.transform:TransformDirection(force)

	self.rigidbody:AddForce(worldForce, forceMode)
end

BowlingBall.AddTorque = function(self, torque, forceMode)
	if self.IsRigidbodyInvalid(self) then
		return
	end

	forceMode = forceMode or UnityEngine.ForceMode.Force
	local worldTorque = self.transform:TransformDirection(torque)

	self.rigidbody:AddTorque(worldTorque, forceMode)
end

BowlingBall.SetAngularVelocity = function(self, angularVelocity)
	if self.IsRigidbodyInvalid(self) then
		return
	end

	local currentAngularVelocity = self.rigidbody.angularVelocity
	self.rigidbody.angularVelocity = currentAngularVelocity + angularVelocity
end

BowlingBall.SetAngularVelocityDirect = function(self, angularVelocity)
	if self.IsRigidbodyInvalid(self) then
		return
	end

	self.rigidbody.angularVelocity = angularVelocity
end

BowlingBall.SetSideForce = function(self, force, slip)
	self.sideForce = force
	self.slipLen = slip
end

BowlingBall.DoAfterSettle = function(self)
	if self.settled then
		return false
	end

	self.settled = true

	BowlingBallUtils:SetColliderSound(self.sceneItemId, 0)

	local currentGame = self.game

	currentGame:StopSound(currentGame.ballRollSound)

	currentGame.ballRollSound = nil

	return true
end

BowlingBall.UpdateAndCheckSettle = function(self)
	local rb = self.rigidbody
	local hasRigidbody = gClientUtils.NotNil(rb)

	if hasRigidbody and self.game.ballRollSound == nil and self.game.ballRollSound == 0 then
		self.game:SetSoundRTPCValue(self.game.ballRollSound, gSoundMgr.RTPCGroup.ObjectVelocity, rb.velocity.magnitude)
	end

	if self.hasDestroy or self.settled then
		return true
	end

	if not hasRigidbody then
		return self.DoAfterSettle(self)
	end

	local curZ = self.transform.localPosition.z
	local curY = self.transform.localPosition.y

	if curZ >= -self.slipLen then
		self.UpdateSideForceEffect(self)
	end

	if BowlingBallUtils:IsInBackPitZone(curY, nil) then
		if not self.ballDropSoundPlayed then
			self.PlayDropSound(self)
		end

		self.SetSideForce(self, 0, 0)

		return self.DoAfterSettle(self)
	end

	if BowlingBallUtils:IsInEndCameraZone(curZ) then
		self.game:SetEndVCamActive(true)
	end

	if BowlingBallUtils:IsInBackPitZone(nil, curZ) then
		if not self.ballDropSoundPlayed and rb.velocity.sqrMagnitude <= 0.5 then
			self.PlayDropSound(self)
		end

		self.SetSideForce(self, 0, 0)

		return self.DoAfterSettle(self)
	end

	if BowlingBallUtils:IsBallStopped(rb) then
		return self.DoAfterSettle(self)
	end

	if Time.time <= self.createTime + LTConfig.PoiGameConfig.BowlingShootingTimeOut then
		self.ShowBowlingShootTimeOutMessage(self)

		return self.DoAfterSettle(self)
	end

	return false
end

BowlingBall.PlayDropSound = function(self)
	self.game:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallDropPit)

	self.ballDropSoundPlayed = true
end

BowlingBall.IsRigidbodyInvalid = function(self)
	if self.rigidbody ~= nil then
		return true
	end

	if gCS.LuaUtils.IsNull(self.rigidbody) then
		local rigidbodyNew = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))

		if rigidbodyNew then
			self.rigidbody = rigidbodyNew

			return false
		else
			print_error("BowlingBall:IsRigidbodyInvalid rigidbody is destroyed", gClientUtils.NotNil(self.gameObject) and self.gameObject.name)

			self.rigidbody = nil

			return true
		end
	end

	return false
end

BowlingBall.ShowBowlingShootTimeOutMessage = function(self)
	local cfg = LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.BowlingShootTimeOut)

	gDisplayMessageMgr:MsgEnqueue(cfg.Content, cfg.HideMessageAfter)
end
