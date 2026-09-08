-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\VolleyballGame\Volleyball.lua
-- Decompiled from: 00630_Volleyball.lua_d6dbd64bc989.luajit

local EaseType = DG.Tweening.Ease
local Mgr = gVolleyballGameMgr
local MoveReason = Mgr.MoveReason
C_Volleyball = DefClass("C_Volleyball", C_Volleyball)
local M = C_Volleyball

M.ctor = function(self, go, gameInstance)
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

M.Init = function(self)
	slot1 = self.gameObject
	self.rigidbody = slot1:GetComponent(typeof(UnityEngine.Rigidbody))
	slot1 = self.transform
	self.CSListener = slot1:GetOrAddComponent(typeof(L18.VolleyballGame.VolleyballListener))

	self.CSListener.luaTriggerEnter = function(other)
		self:OnTriggerEnter(other)
	end
end

M.OnTriggerEnter = function(self, other)
	if other.name ~= "GroundBox" then
		self.gameInstance:BallTouchGround(self.transform.localPosition)
	end
end

M.ResetPosAndVel = function(self)
	self.transform:DOKill()
	self:SwitchPhysics(false)

	self.transform.localPosition = Vector3.zero
end

M.SwitchPhysics = function(self, enable)
	self.rigidbody.isKinematic = not enable
	self.rigidbody.velocity = Vector3.zero
end

M.SetLocalVelocity = function(self, vel)
	self.rigidbody.velocity = self.gameInstance.rootNodeTrans:TransformDirection(vel)
end

M.SetMoveData = function(self, target, moveReason)
	self.targetCharacter = target
	self.curMoveReason = moveReason

	for _, char in pairs(self.gameInstance.allCharacters) do
		char.OnTargetChange(char, target)
	end

	for _, controller in pairs(self.gameInstance.allControllers) do
		controller.OnTargetChange(controller, target)
	end
end

M.SmashMove = function(self, targetPos, speed)
	self:SwitchPhysics(false)

	self.localDestination = targetPos
	local selfLocalPos = self.transform.localPosition
	local distance = Vector3.Distance(selfLocalPos, targetPos)
	local duration = distance / speed
	slot6 = Mgr
	local localDir = slot6:Vec3DirOfAToB(selfLocalPos, targetPos)
	local localVel = localDir * speed
	self.jumpSequence = nil
	slot8 = self.transform
	slot8 = slot8:DOLocalMove(targetPos, duration)

	slot8:OnComplete(function ()
		self:SwitchPhysics(true)
		self:SetLocalVelocity(localVel)
	end)
end

M.NormalJumpByDuration = function(self, targetPos, jumpPower, duration, callback)
	local selfPos = self.transform.localPosition
	slot8 = Mgr
	slot9 = Mgr
	local horDist = Vector2.Distance(slot8:ToVector2XZ(selfPos), slot9:ToVector2XZ(targetPos))
	slot7 = Mgr
	slot10 = Mgr
	local horDir = slot7:ToVector2XZ(slot10:Vec3DirOfAToB(selfPos, targetPos))
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

M.Jump = function(self, targetPos, jumpPower, duration, callback)
	slot5 = self.transform

	slot5:DOKill()
	self:SwitchPhysics(false)

	self.localDestination = targetPos
	slot5 = self.transform
	slot5 = slot5:DOLocalJump(targetPos, jumpPower, 1, duration)
	local sequence = slot5:SetEase(EaseType.Linear)

	sequence:OnComplete(function ()
		if callback then
			callback()
		end
	end)

	self.jumpSequence = sequence
end

M.MatchToPoint = function(self, point, duration)
	self:SetMoveData(nil, MoveReason.Match)
	self.transform:DOKill()
	self:SwitchPhysics(false)

	return self.transform:DOLocalMove(point, duration):SetEase(EaseType.Linear)
end

M.CanBeHit = function(self)
	if self.jumpSequence ~= nil then
		return true
	end

	local curTime = self.jumpSequence:Elapsed(false)
	local totalTime = self.jumpSequence:Duration(false)
	local ratio = curTime / totalTime

	return ratio < 0.4
end

M.OnDestroy = function(self)
	self.transform:DOKill()
end
