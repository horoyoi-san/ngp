local EaseType = DG.Tweening.Ease
local Mgr = gVolleyballGameMgr
local MoveReason = Mgr.MoveReason
local MoveType = {
	TweenPhysical = 3,
	TweenMove = 1,
	TweenJump = 2,
	None = 0
}
C_Volleyball = DefClass("C_Volleyball", C_Volleyball)
local M = C_Volleyball

function M:ctor(go, gameInstance)
	self.gameInstance = gameInstance
	self.rigidbody = nil
	self.gameObject = go
	self.transform = go.transform
	self.CSListener = nil
	self.localDestination = nil
	self.isMoving = false
	self.totalMoveDuration = nil
	self.curMoveDuration = nil
	self.curProgress = nil
	self.curMoveReason = MoveReason.None
	self.targetCharacter = nil
	self.jumpSequence = nil
end

function M:Init()
	self.rigidbody = self.gameObject:GetComponent(typeof(UnityEngine.Rigidbody))
	self.CSListener = self.transform:GetOrAddComponent(typeof(L18.VolleyballGame.VolleyballListener))

	function self.CSListener.luaTriggerEnter(other)
		self:OnTriggerEnter(other)
	end
end

function M:OnTriggerEnter(other)
	if other.name == "GroundBox" then
		self.gameInstance:BallTouchGround(self.transform.localPosition)
	end
end

function M:ResetPosAndVel()
	self.transform:DOKill()
	self:SwitchPhysics(false)

	self.transform.localPosition = Vector3.zero
end

function M:SwitchPhysics(enable)
	self.rigidbody.isKinematic = not enable
	self.rigidbody.velocity = Vector3.zero
end

function M:SetLocalVelocity(vel)
	self.rigidbody.velocity = self.gameInstance.rootNodeTrans:TransformDirection(vel)
end

function M:SetMoveData(target, moveReason)
	self.targetCharacter = target
	self.curMoveReason = moveReason

	for _, char in pairs(self.gameInstance.allCharacters) do
		char:OnTargetChange(target)
	end

	for _, controller in pairs(self.gameInstance.allControllers) do
		controller:OnTargetChange(target)
	end
end

function M:SmashMove(targetPos, speed)
	self:SwitchPhysics(false)

	self.localDestination = targetPos
	local selfLocalPos = self.transform.localPosition
	local distance = Vector3.Distance(selfLocalPos, targetPos)
	local duration = distance / speed
	local localDir = Mgr:Vec3DirOfAToB(selfLocalPos, targetPos)
	local localVel = localDir * speed
	self.jumpSequence = nil

	self.transform:DOLocalMove(targetPos, duration):OnComplete(function ()
		self:SwitchPhysics(true)
		self:SetLocalVelocity(localVel)
	end)
end

function M:NormalJumpByDuration(targetPos, jumpPower, duration, callback)
	local selfPos = self.transform.localPosition
	local horDist = Vector2.Distance(Mgr:ToVector2XZ(selfPos), Mgr:ToVector2XZ(targetPos))
	local horDir = Mgr:ToVector2XZ(Mgr:Vec3DirOfAToB(selfPos, targetPos))
	local horSpeed = self.gameInstance.ReflectHorFactor * horDist / duration
	local verSpeed = jumpPower * self.gameInstance.ReflectVerFactor
	local localVel = Vector3.New(horDir.x * horSpeed, -verSpeed, horDir.y * horSpeed)

	self:Jump(targetPos, jumpPower, duration, function ()
		self:SwitchPhysics(true)
		self:SetLocalVelocity(localVel)

		if callback then
			callback()
		end
	end)
end

function M:Jump(targetPos, jumpPower, duration, callback)
	self.transform:DOKill()
	self:SwitchPhysics(false)

	self.localDestination = targetPos
	local sequence = self.transform:DOLocalJump(targetPos, jumpPower, 1, duration):SetEase(EaseType.Linear)

	sequence:OnComplete(function ()
		if callback then
			callback()
		end
	end)

	self.jumpSequence = sequence
end

function M:MatchToPoint(point, duration)
	self:SetMoveData(nil, MoveReason.Match)
	self.transform:DOKill()
	self:SwitchPhysics(false)

	return self.transform:DOLocalMove(point, duration):SetEase(EaseType.Linear)
end

function M:CanBeHit()
	if self.jumpSequence == nil then
		return true
	end

	local curTime = self.jumpSequence:Elapsed(false)
	local totalTime = self.jumpSequence:Duration(false)
	local ratio = curTime / totalTime

	return ratio >= 0.4
end

function M:OnDestroy()
	self.transform:DOKill()
end
