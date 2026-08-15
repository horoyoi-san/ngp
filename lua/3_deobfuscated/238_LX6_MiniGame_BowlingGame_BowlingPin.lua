gBowlingPin = DefClass("BowlingPin", gBowlingPin)
local BowlingPin = gBowlingPin

function BowlingPin:ctor(args)
	self.gameObject = args.gameObject
	self.index = args.index
	self.transform = self.gameObject.transform
	self.centerY = args.centerY
	self.rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))
	self.isKnockedDown = false
	self.score = 0
	self.tolerance = 0.01
	self.pinDropSoundPlayed = false

	self:RegisterUpdate()
end

function BowlingPin:OnUpdate()
	local playerTrans = (gCS.MyPlayerManager.PlayerUnit or {}).PlayerObj

	if playerTrans == nil or gClientUtils.IsNil(self.transform) then
		self:Destroy()

		return
	end

	if not self.pinDropSoundPlayed then
		local curY = self.transform.localPosition.y
		local curZ = self.transform.localPosition.z

		if curY < 0 or curZ < -19.5 then
			gBowlingGameManager.currentGame:PlaySound(LTConfig.PoiGameConfig.BowlingSound_PinDropPit)

			self.pinDropSoundPlayed = true
		end
	end

	local sqrMagnitude = (playerTrans.position - self.transform.position).sqrMagnitude
	local safeDistance = 25

	if sqrMagnitude > safeDistance * safeDistance then
		self.isKnockedDown = true

		self:Destroy()

		return
	end
end

function BowlingPin:RegisterUpdate()
	self.updateHandler = UpdateBeat:CreateListener(self.OnUpdate, self)

	UpdateBeat:AddListener(self.updateHandler)
end

function BowlingPin:UnRegisterUpdate()
	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

function BowlingPin:Destroy()
	self:UnRegisterUpdate()

	if gClientUtils.NotNil(self.gameObject) then
		self.gameObject.transform:DOKill()
	end

	self.gameObject = gBowlingGameManager:Return(gBowlingGameManager.sceneItemType.Pin, self.gameObject)
	self.hasDestroy = true
end

function BowlingPin:CheckKnockedDown()
	if self.isKnockedDown then
		return true
	end

	if self.hasDestroy or gClientUtils.IsNil(self.transform) then
		return false
	end

	local upVector = self.transform.up
	local angle = Vector3.Angle(upVector, Vector3.up)
	self.isKnockedDown = angle > 30 or self.transform.localPosition.y < self.centerY - self.tolerance

	return self.isKnockedDown
end

function BowlingPin:Reset()
	self.transform.localPosition = self.initialPosition
	self.transform.localRotation = Quaternion.identity
	self.rigidbody.velocity = Vector3.zero
	self.rigidbody.angularVelocity = Vector3.zero
	self.isKnockedDown = false
end
