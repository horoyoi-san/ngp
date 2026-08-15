gBowlingBall = DefClass("BowlingBall", gBowlingBall)
local BowlingBall = gBowlingBall

function BowlingBall:ctor(args)
	self.sceneItemId = args.sceneItemId
	self.gameObject = args.gameObject
	self.ballType = args.ballType
	self.transform = self.gameObject.transform
	self.rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))
	self.sideForce = 0
	self.slipLen = 0
	self.createTime = Time.time
	self.sceneItemHold = gCS.SceneItemMgr:GetSceneItemHold(args.sceneItemId)
	gBowlingGameManager.doNotDisableBallId = self.sceneItemId
	self.ballDropSoundPlayed = false
	self.game = gBowlingGameManager.currentGame

	self:NotifySceneItemUpdate()
	gLuaClient:RegisterDynamicUpdate("gBowlingBall", self)
end

function BowlingBall:Destroy()
	if self.hasDestroy then
		return
	end

	self:DoAfterSettle()

	if (gBowlingGameManager.currentGame or {}).camera then
		gBowlingGameManager.currentGame.camera:StopFollow(false, false)
	end

	gLuaClient:UnregisterDynamicUpdate("gBowlingBall")
	self:StopRigidbody()

	gBowlingGameManager.doNotDisableBallId = nil

	gBowlingGameManager:Return(self.ballType, self.gameObject)

	self.hasDestroy = true
end

function BowlingBall:OnUpdate()
	local playerTrans = (gCS.MyPlayerManager.PlayerUnit or {}).PlayerObj

	if playerTrans == nil then
		return
	end

	if gClientUtils.IsNil(self.transform) then
		print_error("BowlingBall:OnUpdate() self.transform is nil")

		return
	end

	local sqrMagnitude = (playerTrans.position - self.transform.position).sqrMagnitude
	local safeDistance = 30

	if sqrMagnitude > safeDistance * safeDistance then
		self:Destroy()

		return
	end
end

function BowlingBall:NotifySceneItemUpdate()
	if self.sceneItemHold then
		self.sceneItemHold:SyncScale(Vector3.one)
	end
end

function BowlingBall:StopRigidbody()
	if gClientUtils.NotNil(self.rigidbody) then
		self.rigidbody.velocity = Vector3.zero
		self.rigidbody.angularVelocity = Vector3.zero
	end
end

function BowlingBall:UpdateSideForceEffect()
	if self.rigidbody and self.sideForce ~= 0 then
		local forward = self.rigidbody.velocity.normalized
		local right = Vector3.Cross(Vector3.up, forward)
		local sideForceVector = right * self.sideForce

		self.rigidbody:AddForce(sideForceVector, UnityEngine.ForceMode.Acceleration)
	end
end

function BowlingBall:EnablePhysics(enable, setMass)
	self.physicsEnabled = enable
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

function BowlingBall:AddForce(force, forceMode)
	if self:IsRigidbodyInvalid() then
		return
	end

	forceMode = forceMode or UnityEngine.ForceMode.Impulse
	local worldForce = self.transform:TransformDirection(force)

	self.rigidbody:AddForce(worldForce, forceMode)
end

function BowlingBall:AddTorque(torque, forceMode)
	if self:IsRigidbodyInvalid() then
		return
	end

	forceMode = forceMode or UnityEngine.ForceMode.Force
	local worldTorque = self.transform:TransformDirection(torque)

	self.rigidbody:AddTorque(worldTorque, forceMode)
end

function BowlingBall:AddForceAndSpin(force, spinDirection, spinPower)
	if self:IsRigidbodyInvalid() then
		return
	end

	local worldForce = self.transform:TransformDirection(force)

	self:AddForce(worldForce, UnityEngine.ForceMode.Impulse)

	if spinDirection ~= 0 and spinPower > 0 then
		local torque = Vector3.forward * spinDirection * spinPower

		self:AddTorque(torque, UnityEngine.ForceMode.Force)
	end
end

function BowlingBall:SetVelocity(velocity)
	if self:IsRigidbodyInvalid() then
		return
	end

	self.rigidbody.velocity = velocity
end

function BowlingBall:SetAngularVelocity(angularVelocity)
	if self:IsRigidbodyInvalid() then
		return
	end

	local currentAngularVelocity = self.rigidbody.angularVelocity
	self.rigidbody.angularVelocity = currentAngularVelocity + angularVelocity
end

function BowlingBall:SetAngularVelocityDirect(angularVelocity)
	if self:IsRigidbodyInvalid() then
		return
	end

	self.rigidbody.angularVelocity = angularVelocity
end

function BowlingBall:AddAcceleration(acceleration)
	if self:IsRigidbodyInvalid() then
		return
	end

	self.rigidbody:AddForce(acceleration, UnityEngine.ForceMode.Acceleration)
end

function BowlingBall:SetSideForce(force, slip)
	self.sideForce = force
	self.slipLen = slip
end

function BowlingBall:DoAfterSettle()
	if self.settled then
		return false
	end

	self.settled = true

	gBowlingGameManager.currentGame:StopSound(gBowlingGameManager.currentGame.ballRollSound)

	return true
end

function BowlingBall:UpdateAndCheckSettle()
	local rb = self.rigidbody
	local hasRigidbody = gClientUtils.NotNil(rb)

	if hasRigidbody then
		local velocity = rb.velocity.magnitude

		self.game:SetSoundRTPCValue(self.game.ballRollSound, gSoundMgr.RTPCGroup.ObjectVelocity, velocity)
	end

	if self.hasDestroy or self.settled then
		return true
	end

	if not hasRigidbody then
		return self:DoAfterSettle()
	end

	local curZ = self.transform.localPosition.z
	local curY = self.transform.localPosition.y

	if curZ < -self.slipLen then
		self:UpdateSideForceEffect()
	end

	if curY < 0 then
		if not self.ballDropSoundPlayed then
			self:PlayDropSound()
		end

		self:SetSideForce(0, 0)

		return self:DoAfterSettle()
	end

	if curZ < -19.5 then
		if not self.ballDropSoundPlayed and rb.velocity.sqrMagnitude > 0.5 then
			self:PlayDropSound()
		end

		self:SetSideForce(0, 0)

		return self:DoAfterSettle()
	end

	if rb.velocity.sqrMagnitude < 0.05 and rb.angularVelocity.sqrMagnitude < 1 then
		return self:DoAfterSettle()
	end

	if Time.time > self.createTime + 15 then
		return self:DoAfterSettle()
	end

	return false
end

function BowlingBall:PlayDropSound()
	self.game:PlaySound(LTConfig.PoiGameConfig.BowlingSound_BallDropPit)

	self.ballDropSoundPlayed = true
end

function BowlingBall:IsRigidbodyInvalid()
	if self.rigidbody == nil then
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
