local Mgr = gVolleyballGameMgr
local CharacterState = Mgr.CharacterState
local Team = Mgr.Team
local MoveReason = Mgr.MoveReason
local QTELevel = Mgr.QTELevel
C_VolleyballCharacter = DefClass("C_VolleyballCharacter", C_VolleyballCharacter)
local M = C_VolleyballCharacter
local Direction = {
	Right = 3,
	Back = 2,
	Left = 1,
	Front = 0
}
local DistLevel = {
	Far = 3,
	Medium = 2,
	OutOfRange = 4,
	Near = 1
}

function M:ctor(go, gameInstance)
	self.gameObject = go
	self.transform = go.transform
	self.controller = nil
	self.animator = nil
	self.rootMotion = nil
	self.pivotSet = nil
	self.frontHitPivot = nil
	self.backHitPivot = nil
	self.leftHitPivot = nil
	self.rightHitPivot = nil
	self.launchHitPivot = nil
	self.defenceHitPivot = nil
	self.passHitPivot = nil
	self.passDunHitPivot = nil
	self.launchHandPivot = nil
	self.rebornPivot = nil
	self.gameInstance = gameInstance
	self.teammate = nil
	self.opTeamMembers = {}
	self.theBall = nil
	self.camMgr = nil
	self.fixedUpdateHandler = nil
	self.isPlayer = false
	self.canHitAction = false
	self.canMove = false
	self.canSetQTELevel = false
	self.haveSetQTELevel = false
	self.canAutoSmash = false
	self.isSmashQTE = false
	self.curState = nil
	self.rotTime = 0.4
	self.curTeam = nil
	self.opTeam = nil
	self.moveSpeed = 4
	self.inputHorDir = Vector2.zero
	self.farCheckRange = {}
	self.mediumCheckRange = {}
	self.nearCheckRange = {}
	self.forceFailCheckRange = {}
	self.selectPointWeight = 0.5
	self.randomRadius = 1.5
	self.kickBackJumpPower = 2.5
	self.kickBackJumpTime = 1.5
	self.passJumpPower = 2.5
	self.passJumpTime = 2
	self.spSmashSpeed = 25
	self.lateSmashSpeed = 10
	self.smashMiddlePower = 1.2
	self.smashMiddleTime = 0.6
	self.qteStartTime = nil
	self.qteConfirmTime = nil
	self.curQTELevel = nil
	self.launchCo = nil
	self.smashCo = nil
	self.delayFreeCo = nil
	self.debugSphere = nil
	self.debugTarget = nil
end

function M:Init()
	self.opTeam = self.curTeam == Team.My and Team.Op or Team.My
	self.nearCheckRange = {
		Radius = 1,
		HeightRange = Vector2.New(0.3, 1.6)
	}
	self.mediumCheckRange = {
		Radius = 2.5,
		HeightRange = Vector2.New(0.3, 1.6)
	}
	self.farCheckRange = {
		Radius = 3,
		HeightRange = Vector2.New(0, 0.3)
	}
	self.forceFailCheckRange = {
		Radius = 3.5,
		HeightRange = Vector2.New(0, 1.6)
	}

	self:InitReferences()
	self:InitPivots()
	self:RegisterEvents()
end

function M:RegisterEvents()
	self.fixedUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

	FixedUpdateBeat:AddListener(self.fixedUpdateHandler)
end

function M:UnRegisterEvents()
	FixedUpdateBeat:RemoveListener(self.fixedUpdateHandler)
end

function M:InitReferences()
	local gameInstance = self.gameInstance

	for _, char in pairs(gameInstance.teamChars[self.curTeam]) do
		if char ~= self then
			self.teammate = char

			break
		end
	end

	self.opTeamMembers = gameInstance.teamChars[self.opTeam]
	self.camMgr = gameInstance.camMgr
	self.theBall = gameInstance.theBall
end

function M:InitPivots()
	self.frontHitPivot = self.pivotSet:Find("FrontHitPivot")
	self.backHitPivot = self.pivotSet:Find("BackHitPivot")
	self.leftHitPivot = self.pivotSet:Find("LeftHitPivot")
	self.rightHitPivot = self.pivotSet:Find("RightHitPivot")
	self.launchHitPivot = self.pivotSet:Find("LaunchHitPivot")
	self.defenceHitPivot = self.pivotSet:Find("DefenceHitPivot")
	self.passHitPivot = self.pivotSet:Find("PassHitPivot")
	self.passDunHitPivot = self.pivotSet:Find("PassDunHitPivot")
	self.debugTarget = self.pivotSet:Find("DebugTarget").gameObject
end

function M:SwitchCharacterState(newState)
	if self.curState == newState then
		return
	end

	self.controller:OnCharacterStateChange(self.curState, newState)
	self:OnCharacterStateChange(self.curState, newState)

	self.curState = newState
end

function M:OnTargetChange(target)
	self.debugTarget:SetActive(target == self)
end

function M:OnCharacterStateChange(from, to)
	if from == CharacterState.Free then
		self.canMove = false
		self.canAutoSmash = false
	elseif from == CharacterState.Match then
		self:LookForward(self.rotTime)
	end

	if to == CharacterState.None then
		self.canMove = false
		self.canHitAction = false
		self.inputHorDir = Vector2.zero

		self:MatchMoveAnim(Vector2.zero)
	elseif to == CharacterState.Free then
		self.transform:DOKill()
		self.rootMotion:SwitchRootMotion(false)

		self.canHitAction = true
		self.canMove = true

		self:LookForward(self.rotTime)
	elseif to == CharacterState.PreLaunch then
		self:AttachBallTToHand(self.theBall)

		self.canHitAction = true
		self.launchCo = nil
	elseif to == CharacterState.SmashQTE or to == CharacterState.LaunchQTE or to == CharacterState.Match then
		self.canHitAction = false
	end
end

function M:FixedUpdate()
	if not self.gameObject.activeSelf then
		return
	end

	self:Move()
	self:AutoSmashCheck()
end

function M:Move()
	if not self.canMove then
		return
	end

	self:MatchMoveAnim(self.inputHorDir)

	local dir = Mgr:ToVector3(self.inputHorDir)
	local modifyValue = self.moveSpeed * Time.fixedDeltaTime
	local modifyPos = self.transform.localPosition + dir * modifyValue
	modifyPos = self:ClampLocalPosByTeam(modifyPos, self.curTeam)

	self.transform:SetLocalPosition(modifyPos)
end

function M:AutoSmashCheck()
	if not self.canAutoSmash or self.curState ~= CharacterState.Free then
		return
	end

	local ballAnim = self.theBall.jumpSequence
	local animTotalTime = ballAnim:Duration(false)
	local animCurTime = ballAnim:Elapsed(false)
	local moveRatio = (animCurTime - animTotalTime + self.gameInstance.smashAnimHitTime) / self.gameInstance.smashAnimJumpTime
	local curDist = Vector2.Distance(Mgr:ToVector2XZ(self.transform.localPosition), Mgr:ToVector2XZ(self.theBall.localDestination))
	local totalDist = self.gameInstance.smashMoveDistance
	local distRatio = (totalDist - curDist) / totalDist

	if moveRatio >= 0 and moveRatio <= 1 and moveRatio > distRatio - self.gameInstance.koushaCheckRange and moveRatio < distRatio + self.gameInstance.koushaCheckRange then
		self:TrySmash(moveRatio * self.gameInstance.smashAnimJumpTime / self.gameInstance.smashAnimTotalTime)
	end
end

function M:SetInputByWorldSpace(inputValue)
	local modifyValue = self.gameInstance.rootNodeTrans:InverseTransformDirection(Mgr:ToVector3(inputValue))
	self.inputHorDir = Mgr:ToVector2XZ(modifyValue)
end

function M:SetInputByLocalSpace(inputValue)
	self.inputHorDir = inputValue
end

function M:OnNextRoundStart()
	self:ResetPosAtRebornPos()
	self:SwitchCharacterState(CharacterState.Free)
	self.animator:SetTrigger("round_start")
	self:LookForward(self.rotTime)
	self.rootMotion:SwitchRootMotion(false)
end

function M:OnSettlement()
	if self.delayFreeCo then
		coroutine.stop(self.delayFreeCo)

		self.delayFreeCo = nil
	end

	self:SwitchCharacterState(CharacterState.None)
end

function M:SwitchToPreLaunchState()
	self:ResetPosAtRebornPos()
	self:SwitchCharacterState(CharacterState.PreLaunch)
	self.camMgr:SwitchCameraByTeam(self.curTeam)
end

function M:OnDestroy()
	self.transform:DOKill()
	self:UnRegisterEvents()
end

function M:HitBall(ball, targetPos, jumpPower, jumpTime)
	ball:NormalJumpByDuration(targetPos, self.kickBackJumpPower, self.kickBackJumpTime)
end

function M:MatchBallWaitHit(ball, hitPos, targetPos, needRot, matchTime, freeTime, finishCb)
	self.canMove = false
	local hitLocalPos = self:RootInverseTransformPoint(hitPos)
	local selfPos = self.transform.localPosition
	local ballPos = ball.transform.localPosition
	local ballEndPos = ball.localDestination
	local ballWeightPos = ballPos * (1 - self.selectPointWeight) + ballEndPos * self.selectPointWeight
	local ballTargetPos = Vector3.New(ballWeightPos.x, hitLocalPos.y, ballWeightPos.z)
	local hitOffset = hitLocalPos - selfPos
	local selfTargetPos = nil

	if needRot then
		local hitOffsetDist = Vector2.Magnitude(Mgr:ToVector2XZ(hitOffset))
		local hitPivotForward = Mgr:Vec3HorDirOfAToB(ballTargetPos, targetPos)
		selfTargetPos = Mgr:NewVec3SetY(ballTargetPos, selfPos.y) - hitPivotForward * hitOffsetDist

		self:LocalLookAtPos(targetPos - (selfTargetPos - selfPos), self.rotTime)
	else
		local selfMatchPos = ballTargetPos - hitOffset
		selfTargetPos = Vector3.New(selfMatchPos.x, selfPos.y, selfMatchPos.z)
	end

	self.transform:DOLocalMove(selfTargetPos, matchTime)
	ball:MatchToPoint(ballTargetPos, matchTime):OnComplete(function ()
		if finishCb then
			finishCb()
		end

		self:DelayFree(freeTime)
	end)
end

function M:TrySmash(ratio)
	if self.canHitAction then
		self.isSmashQTE = true
		local ballEnd = self.theBall.localDestination
		local lookPos = Vector3.New(ballEnd.x, self.transform.localPosition.y, ballEnd.z)

		self.transform:LookAt(self.gameInstance.rootNodeTrans:TransformDirection(lookPos))
		self.animator:Play("kousha", 0, ratio)

		self.smashCo = coroutine.start(self.SmashCo, self, self.theBall, ratio * self.gameInstance.smashAnimTotalTime, self.gameInstance.smashAnimJumpTime, self.gameInstance.smashAnimHitTime, self.gameInstance.smashAnimTotalTime)
	end
end

function M:TryPassBall()
	if not self.canHitAction or self.gameInstance.curPossession ~= self.curTeam or not self.gameObject.activeSelf then
		return false
	end

	if self.theBall.curMoveReason == MoveReason.SPSmash then
		if self:CheckIsInRange(self.theBall.transform, self.forceFailCheckRange) then
			self:PassFail(self.theBall)

			return true
		end

		return false
	end

	if not self.theBall:CanBeHit() then
		return false
	end

	if self.theBall.targetCharacter == self and self:CheckIsInRange(self.theBall.transform, self.nearCheckRange) then
		self:PassBall(self.theBall)

		return true
	elseif self.theBall.targetCharacter == self and self:CheckIsInRange(self.theBall.transform, self.mediumCheckRange) then
		self:PassBall(self.theBall)

		return true
	elseif self:CheckIsInRange(self.theBall.transform, self.farCheckRange) then
		self:PassFail(self.theBall)

		return true
	end
end

function M:PassBall(ball)
	self:SwitchCharacterState(CharacterState.Match)

	local hitPivot = nil

	if ball.transform.localPosition.y < 1 then
		self.animator:SetTrigger("pass_dun")

		hitPivot = self.passDunHitPivot
	else
		self.animator:SetTrigger("pass")

		hitPivot = self.passHitPivot
	end

	local dist = math.abs(self.teammate.transform.localPosition.z)
	local isSmash = dist < self.gameInstance.passKoushaCheckDistance
	local targetPos = isSmash and self:GetPassSmashTargetPos() or Mgr:GetRandomPosNearPos(self.teammate.transform.localPosition, self.randomRadius)
	targetPos = self:ClampLocalPosByTeam(targetPos, self.curTeam)

	self:MatchBallWaitHit(ball, hitPivot.position, targetPos, true, self.gameInstance.passMatchTime, self.gameInstance.passFreeTime, function ()
		self:HitBall(ball, targetPos, self.passJumpPower, self.passJumpTime)
		ball:SetMoveData(self.teammate, MoveReason.Pass)
		self.gameInstance:ChangePossession(self.curTeam)

		if isSmash then
			self.teammate.canAutoSmash = true
		end
	end)
end

function M:PassFail(ball)
	self:SwitchCharacterState(CharacterState.Match)
	self.animator:SetTrigger("jieqiu_front_fail")

	local matchPos = self.transform.localPosition * self.gameInstance.failMovePointWeight + ball.localDestination * (1 - self.gameInstance.failMovePointWeight)
	matchPos = self:ClampLocalPosByTeam(matchPos, self.curTeam)
	matchPos.y = self.transform.localPosition.y

	self.transform:DOLocalMove(matchPos, self.gameInstance.passFailMatchTime):OnComplete(function ()
		self:DelayFree(self.gameInstance.passFailFreeTime)
	end)
end

function M:TryKickBackBall()
	if not self.canHitAction or self.gameInstance.curPossession ~= self.curTeam or not self.gameObject.activeSelf then
		return false
	end

	if self:GetHorDist() < self.gameInstance.defenceEnterDistance and (self.theBall.targetCharacter == nil and self.theBall.curMoveReason == MoveReason.SPSmash or self.theBall.targetCharacter == self and self.theBall.curMoveReason == MoveReason.Smash) then
		self:Defence(self.theBall)

		return true
	end

	local direction = self:GetDirectionOfPos(self.theBall.transform.position)

	if self.theBall.curMoveReason == MoveReason.SPSmash then
		if self:CheckIsInRange(self.theBall.transform, self.forceFailCheckRange) then
			self:KickBackFail(self.theBall, direction)

			return true
		end

		return false
	end

	if not self.theBall:CanBeHit() then
		return false
	end

	if self.theBall.targetCharacter == self and self:CheckIsInRange(self.theBall.transform, self.nearCheckRange) then
		self:KickBackNormalBall(self.theBall, direction)

		return true
	elseif self.theBall.targetCharacter == self and self:CheckIsInRange(self.theBall.transform, self.mediumCheckRange) then
		self:KickBackNormalBall(self.theBall, direction)

		return true
	elseif self:CheckIsInRange(self.theBall.transform, self.farCheckRange) then
		self:KickBackFail(self.theBall, direction)

		return true
	end
end

function M:Defence(ball)
	self:SwitchCharacterState(CharacterState.Match)
	self.animator:SetTrigger("defence")
	coroutine.start(self.DefenceCo, self, ball, self.gameInstance.defenceCheckStartTime, self.gameInstance.defenceCheckEndTIme, self.gameInstance.defenceDelayFreeTime)
end

function M:KickBackFail(ball, direction)
	self:SwitchCharacterState(CharacterState.Match)

	if direction == Direction.Front or direction == Direction.Back then
		self.animator:SetTrigger("jieqiu_front_fail")
	elseif direction == Direction.Left then
		self.animator:SetTrigger("jieqiu_left_fail")
	else
		self.animator:SetTrigger("jieqiu_right_fail")
	end

	local targetPos = self.transform.position * self.gameInstance.failMovePointWeight + ball.localDestination * (1 - self.gameInstance.failMovePointWeight)
	targetPos = self:ClampLocalPosByTeam(targetPos, self.curTeam)
	targetPos.y = self.transform.localPosition.y

	self.transform:DOLocalMove(targetPos, self.gameInstance.kickBackFailMatchTime):OnComplete(function ()
		self:DelayFree(self.gameInstance.kickBackFailFreeTime)
	end)
end

function M:KickBackNormalBall(ball, direction)
	local opChar = self:GetRandomOpMember()

	self:SwitchCharacterState(CharacterState.Match)

	local targetPos = Mgr:GetRandomPosNearPos(opChar.transform.localPosition, self.randomRadius)
	targetPos = self:ClampLocalPosByTeam(targetPos, opChar.curTeam)
	local hitPivot, matchTime, freeTime = nil

	if direction == Direction.Front or direction == Direction.Back then
		self.animator:SetTrigger("jieqiu_front_success")

		hitPivot = self.frontHitPivot
		matchTime = self.gameInstance.kickBackFrontMatchTime
		freeTime = self.gameInstance.kickBackFrontFreeTime
	elseif direction == Direction.Left then
		self.animator:SetTrigger("jieqiu_left_success")

		hitPivot = self.leftHitPivot
		matchTime = self.gameInstance.kickBackSideMatchTime
		freeTime = self.gameInstance.kickBackSideFreeTime
	else
		self.animator:SetTrigger("jieqiu_right_success")

		hitPivot = self.rightHitPivot
		matchTime = self.gameInstance.kickBackSideMatchTime
		freeTime = self.gameInstance.kickBackSideFreeTime
	end

	self:MatchBallWaitHit(ball, hitPivot.position, targetPos, false, matchTime, freeTime, function ()
		self:HitBall(ball, targetPos, self.kickBackJumpPower, self.kickBackJumpTime)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
		ball:SetMoveData(opChar, MoveReason.KickBack)
		self.gameInstance:ChangePossession(self.opTeam)
	end)
end

function M:TryLaunch()
	if self.canHitAction and self.launchCo == nil then
		self.isSmashQTE = false

		self.rootMotion:SwitchRootMotion(true)
		self.animator:SetTrigger("launch")

		self.launchCo = coroutine.start(self.LaunchCo, self, self.theBall, self.gameInstance.launchTossTime, self.gameInstance.launchHitTime, self.gameInstance.launchTotalTime)
	end

	return true
end

function M:LaunchCo(ball, tossTime, hitTime, totalTime)
	local time1 = tossTime
	local time2 = hitTime - tossTime
	local time3 = totalTime - hitTime
	self.canSetQTELevel = false
	self.haveSetQTELevel = false

	self:SwitchCharacterState(CharacterState.LaunchQTE)

	if self.isPlayer then
		self.gameInstance.playerController.gamePanel:ChangeButtonInteractable(false)
	end

	coroutine.wait(time1)

	if self.isPlayer then
		self.gameInstance.playerController.gamePanel:ChangeButtonInteractable(true)
	end

	self.qteStartTime = Time.time
	self.canSetQTELevel = true
	local targetPos = self:RootInverseTransformPoint(self.launchHitPivot.position)

	ball.transform:SetParent(self.gameInstance.rootNodeTrans)
	ball:Jump(targetPos, self.gameInstance.launchTossPower, time2)
	coroutine.wait(time2)
	self:SetQTELevel(QTELevel.Late)
	self:LaunchHit(ball, self.curQTELevel)
	self:DelayFree(time3)
end

function M:LaunchHit(ball, level)
	ball.transform:DOKill()

	local targetPos, opChar = nil

	Mgr:PrintDebug(self.transform.name .. " process " .. (self.isSmashQTE and "Smash" or "Launch"), "Level=", level)

	if level == QTELevel.Early then
		ball:SwitchPhysics(true)
		ball:SetMoveData(nil, MoveReason.FailSmash)
	elseif level == QTELevel.Normal then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)
		opChar = self:GetOpCharNearPos(targetPos)

		ball:NormalJumpByDuration(targetPos, self.smashMiddlePower, self.smashMiddleTime)
		ball:SetMoveData(opChar, MoveReason.Smash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	elseif level == QTELevel.Perfect then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)

		ball:SmashMove(targetPos, self.spSmashSpeed)
		ball:SetMoveData(self:GetOpCharNearPos(targetPos), MoveReason.SPSmash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	elseif level == QTELevel.Late then
		local forward = self:GetForwardVec()

		ball:SwitchPhysics(true)
		ball:SetMoveData(nil, MoveReason.FailSmash)
		ball:SetLocalVelocity(Vector3.Normalize(forward + Vector3.down) * self.lateSmashSpeed)
	elseif level == QTELevel.Fake then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)

		ball:SmashMove(targetPos, 9)
		ball:SetMoveData(nil, MoveReason.Smash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	end
end

function M:TryQTEConfirm()
	local deltaTime = Time.time - self.qteStartTime
	local level = self:CalcQTELevel(self.isSmashQTE, deltaTime)

	self:SetQTELevel(level)

	return true
end

function M:TryQTEFake()
	if self.isSmashQTE then
		self:SetQTELevel(QTELevel.Fake)
	else
		Mgr:PrintError("Smash Error")
	end

	return true
end

function M:SmashCo(ball, curTime, jumpTime, hitTime, totalTime)
	local time1 = jumpTime - curTime
	local time2 = hitTime - jumpTime
	local time3 = totalTime - hitTime
	self.canSetQTELevel = false
	self.haveSetQTELevel = false

	self:SwitchCharacterState(CharacterState.SmashQTE)

	if self.isPlayer then
		self.gameInstance.playerController.gamePanel:ChangeButtonInteractable(false)
	end

	local targetPos = ball.localDestination
	targetPos.y = 0

	self.transform:DOLocalMove(targetPos, time1 + time2)
	coroutine.wait(time1)

	if self.isPlayer then
		self.gameInstance.playerController.gamePanel:ChangeButtonInteractable(true)
	end

	self.qteStartTime = Time.time
	self.canSetQTELevel = true

	self:LookForward(self.rotTime)
	coroutine.wait(time2)
	self:SetQTELevel(QTELevel.Late)
	self:LaunchHit(ball, self.curQTELevel)
	self:DelayFree(time3)
end

function M:DefenceCo(ball, checkOpenTime, checkCloseTime, totalTime)
	local time1 = checkOpenTime
	local time2 = checkCloseTime - checkOpenTime
	local time3 = totalTime - checkCloseTime

	coroutine.wait(time1)

	local timer = time2
	local hitFlag = false
	local dist = 0

	while timer > 0 do
		if hitFlag then
			break
		end

		dist = Vector3.Distance(self.defenceHitPivot.position, ball.transform.position)

		if dist < self.gameInstance.defenceCheckDistance and ball.curMoveReason == MoveReason.Smash then
			hitFlag = true

			self:DefenceHit(ball)
		end

		coroutine.wait(0.05)

		timer = timer - 0.05
	end

	if timer > 0 then
		coroutine.wait(timer)
	end

	self:SwitchCharacterState(CharacterState.Match)
	self:DelayFree(time3)
end

function M:DefenceHit(ball)
	local targetPos = self:GetQTEPosByLevel(QTELevel.Fake)

	self:HitBall(ball, targetPos)
	ball:SetMoveData(self:GetOpCharNearPos(targetPos), MoveReason.KickBack)
	self.gameInstance:ChangePossession(self.opTeam)
	self.camMgr:SwitchCameraByTeam(self.opTeam)
end

function M:ResetPosAtRebornPos()
	self.transform.position = self.rebornPivot.position
end

function M:DelayFree(time)
	if time < 0 then
		Mgr:PrintError("delay time error")

		return
	end

	if self.delayFreeCo then
		coroutine.stop(self.delayFreeCo)
	end

	if time == 0 then
		self:SwitchCharacterState(CharacterState.Free)

		return
	end

	self.delayFreeCo = coroutine.start(Mgr.TimerCo, nil, time, function ()
		self:SwitchCharacterState(CharacterState.Free)
	end)
end

function M:SetQTELevel(level, isForce)
	if self.canSetQTELevel and not self.haveSetQTELevel or isForce then
		self.haveSetQTELevel = true
		self.curQTELevel = level
	end
end

function M:AttachBallTToHand(ball)
	local ballTrans = ball.transform
	ballTrans.parent = self.launchHandPivot
	ballTrans.localPosition = Vector3.New(0, 0, 0)
end

function M:SetRandomCloseUpTrigger()
	local trigger = "closeup_" .. math.random(0, 2)

	self.animator:SetTrigger(trigger)
end

function M:MatchMoveAnim(horDir)
	local xValue = 0
	local yValue = 0

	if horDir ~= Vector2.zero then
		local relativePos = self.transform:InverseTransformPoint(self.transform.position + Mgr:ToVector3(horDir))
		xValue = relativePos.x
		yValue = relativePos.z
	end

	self.animator:SetFloat("X", xValue)
	self.animator:SetFloat("Y", yValue)
end

function M:CheckIsInRange(otherTrans, checkRange)
	local selfPos = self.transform.localPosition
	local otherPos = otherTrans.localPosition
	local horDist = Vector2.Distance(Mgr:ToVector2XZ(selfPos), Mgr:ToVector2XZ(otherPos))
	local otherHeight = otherPos.y

	return checkRange.HeightRange.x <= otherHeight and otherHeight <= checkRange.HeightRange.y and horDist < checkRange.Radius
end

function M:GetDirectionOfPos(targetPos)
	local intervalRad = 0.785
	local selfForward = self.transform.forward
	local selfRad = math.atan(selfForward.z, selfForward.x)
	local posOffset = targetPos - self.transform.position
	local posRad = math.atan(posOffset.z, posOffset.x)
	local offsetRad = posRad - selfRad

	if offsetRad < -intervalRad then
		offsetRad = offsetRad + 6.28
	end

	if offsetRad > -intervalRad and offsetRad < intervalRad then
		return Direction.Front
	elseif intervalRad < offsetRad and offsetRad < 3 * intervalRad then
		return Direction.Left
	elseif offsetRad > 3 * intervalRad and offsetRad < 5 * intervalRad then
		return Direction.Back
	else
		return Direction.Right
	end
end

function M:GetRandomOpMember()
	return self.opTeamMembers[math.random(#self.opTeamMembers)]
end

function M:GetOpCharNearPos(pos)
	local result = self.opTeamMembers[0]
	local dist = 0
	local minDist = 1000

	for _, member in pairs(self.opTeamMembers) do
		dist = Vector2.Distance(Mgr:ToVector2XZ(member.transform.localPosition), pos)

		if dist < minDist then
			minDist = dist
			result = member
		end
	end

	return result
end

function M:GetPassSmashTargetPos()
	local x = self.teammate.transform.localPosition.x
	local y = self.gameInstance.koushaHeight
	local z = self.gameInstance.koushaDistance * (self.curTeam == Team.My and -1 or 1)

	return Vector3.New(x, y, z)
end

function M:GetQTEPosByLevel(qteLevel)
	if qteLevel == QTELevel.Normal then
		return Vector3.New(math.random(-1, 1) * self.gameInstance.koushaMiddleRandomRange, 0, self.gameInstance.koushaMiddleDistance * (self.curTeam == Team.My and 1 or -1))
	elseif qteLevel == QTELevel.Perfect then
		return Vector3.New(math.random(-1, 1) * self.gameInstance.koushaPerfectRandomRange, 0, self.gameInstance.koushaPerfectDistance * (self.curTeam == Team.My and 1 or -1))
	elseif qteLevel == QTELevel.Fake then
		return Vector3.New(self.transform.localPosition.x + math.random(-1, 1) * self.gameInstance.koushaFakeRandomRange, 0, self.gameInstance.koushaFakeDistance * (self.curTeam == Team.My and 1 or -1))
	else
		Mgr:PrintError("Invalid QTELevel=" .. qteLevel)
	end
end

function M:CalcQTELevel(isSmash, deltaTime)
	if isSmash then
		if deltaTime < self.gameInstance.smashQTEEarlyTime then
			return QTELevel.Early
		elseif deltaTime < self.gameInstance.smashQTENormalTime then
			return QTELevel.Normal
		elseif deltaTime < self.gameInstance.smashQTEPerfectTime then
			return QTELevel.Perfect
		else
			return QTELevel.Late
		end
	elseif deltaTime < self.gameInstance.launchQTEEarlyTime then
		return QTELevel.Early
	elseif deltaTime < self.gameInstance.launchQTENormalTime then
		return QTELevel.Normal
	elseif deltaTime < self.gameInstance.launchQTEPerfectTime then
		return QTELevel.Perfect
	else
		return QTELevel.Late
	end
end

function M:GetForwardVec()
	return self.gameInstance.rootNodeTrans.forward * (self.curTeam == Team.My and 1 or -1)
end

function M:GetLocalForwardVec()
	return Vector3.New(0, 0, 1) * (self.curTeam == Team.My and 1 or -1)
end

function M:GetHorDist()
	return math.abs(self.transform.localPosition.z)
end

function M:ClampLocalPosByTeam(pos, team)
	pos = Mgr:ClampXZByRect(pos, self.gameInstance:GetRectByTeam(team))

	return pos
end

function M:RootInverseTransformPoint(pos)
	return self.gameInstance.rootNodeTrans:InverseTransformPoint(pos)
end

function M:LookForward(time)
	self.transform:DOLookAt(self.transform.position + self:GetForwardVec(), time)
end

function M:LookAtTeammate(time)
	self:LookAtPos(self.teammate.transform.position, time)
end

function M:LookAtPos(pos, time)
	local lookPos = Vector3.New(pos.x, self.transform.position.y, pos.z)

	self.transform:DOLookAt(lookPos, time)
end

function M:LocalLookAtPos(pos, time)
	self:LookAtPos(self.gameInstance.rootNodeTrans:TransformPoint(pos), time)
end

function M:CalcHitPos(radian, originPos)
	local x = originPos.x
	local y = originPos.y
	local z = originPos.z
	local sin = math.sin(radian)
	local cos = math.cos(radian)

	return Vector3.New(cos * x + sin * z, y, -sin * x + cos * z)
end
