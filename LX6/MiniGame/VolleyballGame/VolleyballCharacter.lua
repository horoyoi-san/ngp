-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\VolleyballGame\VolleyballCharacter.lua
-- Decompiled from: 00632_VolleyballCharacter.lua_1f0a8097951e.luajit

local Mgr = gVolleyballGameMgr
local CharacterState = Mgr.CharacterState
local Team = Mgr.Team
local MoveReason = Mgr.MoveReason
local QTELevel = Mgr.QTELevel
C_VolleyballCharacter = DefClass("C_VolleyballCharacter", C_VolleyballCharacter)
local M = C_VolleyballCharacter
local Direction = {
	["\\xa7\\xa5\\xa7\\xa2"] = 3,
	["X#~P"] = 2,
	["V'{O"] = 1,
	["k\\xbc\\xad\\xa1\\xa2"] = 0
}
local DistLevel = {
	["\\xa8it"] = 3,
	["1M\\x95\\x87\\x96L"] = 2,
	["|Oڒ\\x82:\\xb9\n\\xce\\xed"] = 4,
	["T'|I"] = 1
}

M.ctor = function(self, go, gameInstance)
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

M.Init = function(self)
	self.opTeam = self.curTeam ~= Team.My and Team.Op or Team.My
	self.nearCheckRange = {
		[".I\\x95\\x87\\x96R"] = 1,
		HeightRange = Vector2.New(0.3, 1.6)
	}
	self.mediumCheckRange = {
		[".I\\x95\\x87\\x96R"] = 2.5,
		HeightRange = Vector2.New(0.3, 1.6)
	}
	self.farCheckRange = {
		[".I\\x95\\x87\\x96R"] = 3,
		HeightRange = Vector2.New(0, 0.3)
	}
	self.forceFailCheckRange = {
		[".I\\x95\\x87\\x96R"] = 3.5,
		HeightRange = Vector2.New(0, 1.6)
	}

	self:InitReferences()
	self:InitPivots()
	self:RegisterEvents()
end

M.RegisterEvents = function(self)
	self.fixedUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

	FixedUpdateBeat:AddListener(self.fixedUpdateHandler)
end

M.UnRegisterEvents = function(self)
	FixedUpdateBeat:RemoveListener(self.fixedUpdateHandler)
end

M.InitReferences = function(self)
	local gameInstance = self.gameInstance

	for _, char in pairs(gameInstance.teamChars[self.curTeam]) do
		if char == self then
			self.teammate = char

			break
		end
	end

	self.opTeamMembers = gameInstance.teamChars[self.opTeam]
	self.camMgr = gameInstance.camMgr
	self.theBall = gameInstance.theBall
end

M.InitPivots = function(self)
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

M.SwitchCharacterState = function(self, newState)
	if self.curState ~= newState then
		return
	end

	self.controller:OnCharacterStateChange(self.curState, newState)
	self:OnCharacterStateChange(self.curState, newState)

	self.curState = newState
end

M.OnTargetChange = function(self, target)
	self.debugTarget:SetActive(target ~= self)
end

M.OnCharacterStateChange = function(self, from, to)
	if from ~= CharacterState.Free then
		self.canMove = false
		self.canAutoSmash = false
	elseif from ~= CharacterState.Match then
		self.LookForward(self, self.rotTime)
	end

	if to ~= CharacterState.None then
		self.canMove = false
		self.canHitAction = false
		self.inputHorDir = Vector2.zero

		self.MatchMoveAnim(self, Vector2.zero)
	elseif to ~= CharacterState.Free then
		self.transform:DOKill()
		self.rootMotion:SwitchRootMotion(false)

		self.canHitAction = true
		self.canMove = true

		self:LookForward(self.rotTime)
	elseif to ~= CharacterState.PreLaunch then
		self.AttachBallTToHand(self, self.theBall)

		self.canHitAction = true
		self.launchCo = nil
	elseif to ~= CharacterState.SmashQTE or to ~= CharacterState.LaunchQTE or to ~= CharacterState.Match then
		self.canHitAction = false
	end
end

M.FixedUpdate = function(self)
	if not self.gameObject.activeSelf then
		return
	end

	self.Move(self)
	self.AutoSmashCheck(self)
end

M.Move = function(self)
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

M.AutoSmashCheck = function(self)
	if not self.canAutoSmash or self.curState == CharacterState.Free then
		return
	end

	local ballAnim = self.theBall.jumpSequence
	local animTotalTime = ballAnim:Duration(false)
	local animCurTime = ballAnim:Elapsed(false)
	local moveRatio = (animCurTime - animTotalTime + self.gameInstance.smashAnimHitTime) / self.gameInstance.smashAnimJumpTime
	local curDist = Vector2.Distance(Mgr:ToVector2XZ(self.transform.localPosition), Mgr:ToVector2XZ(self.theBall.localDestination))
	local totalDist = self.gameInstance.smashMoveDistance
	local distRatio = (totalDist - curDist) / totalDist

	if moveRatio > 0 and moveRatio < 1 and moveRatio <= distRatio - self.gameInstance.koushaCheckRange and moveRatio >= distRatio + self.gameInstance.koushaCheckRange then
		self.TrySmash(self, moveRatio * self.gameInstance.smashAnimJumpTime / self.gameInstance.smashAnimTotalTime)
	end
end

M.SetInputByWorldSpace = function(self, inputValue)
	local modifyValue = self.gameInstance.rootNodeTrans:InverseTransformDirection(Mgr:ToVector3(inputValue))
	self.inputHorDir = Mgr:ToVector2XZ(modifyValue)
end

M.SetInputByLocalSpace = function(self, inputValue)
	self.inputHorDir = inputValue
end

M.OnNextRoundStart = function(self)
	self:ResetPosAtRebornPos()
	self:SwitchCharacterState(CharacterState.Free)
	self.animator:SetTrigger("round_start")
	self:LookForward(self.rotTime)
	self.rootMotion:SwitchRootMotion(false)
end

M.OnSettlement = function(self)
	if self.delayFreeCo then
		coroutine.stop(self.delayFreeCo)

		self.delayFreeCo = nil
	end

	self.SwitchCharacterState(self, CharacterState.None)
end

M.SwitchToPreLaunchState = function(self)
	self:ResetPosAtRebornPos()
	self:SwitchCharacterState(CharacterState.PreLaunch)
	self.camMgr:SwitchCameraByTeam(self.curTeam)
end

M.OnDestroy = function(self)
	self.transform:DOKill()
	self:UnRegisterEvents()
end

M.HitBall = function(self, ball, targetPos, jumpPower, jumpTime)
	ball.NormalJumpByDuration(ball, targetPos, self.kickBackJumpPower, self.kickBackJumpTime)
end

M.MatchBallWaitHit = function(self, ball, hitPos, targetPos, needRot, matchTime, freeTime, finishCb)
	self.canMove = false
	local hitLocalPos = self.RootInverseTransformPoint(self, hitPos)
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

	slot16 = self.transform

	slot16:DOLocalMove(selfTargetPos, matchTime)

	slot16 = ball:MatchToPoint(ballTargetPos, matchTime)

	slot16:OnComplete(function ()
		if finishCb then
			finishCb()
		end

		self:DelayFree(freeTime)
	end)
end

M.TrySmash = function(self, ratio)
	if self.canHitAction then
		self.isSmashQTE = true
		local ballEnd = self.theBall.localDestination
		local lookPos = Vector3.New(ballEnd.x, self.transform.localPosition.y, ballEnd.z)

		self.transform:LookAt(self.gameInstance.rootNodeTrans:TransformDirection(lookPos))
		self.animator:Play("kousha", 0, ratio)

		self.smashCo = coroutine.start(self.SmashCo, self, self.theBall, ratio * self.gameInstance.smashAnimTotalTime, self.gameInstance.smashAnimJumpTime, self.gameInstance.smashAnimHitTime, self.gameInstance.smashAnimTotalTime)
	end
end

M.TryPassBall = function(self)
	if not self.canHitAction or self.gameInstance.curPossession == self.curTeam or not self.gameObject.activeSelf then
		return false
	end

	if self.theBall.curMoveReason ~= MoveReason.SPSmash then
		if self.CheckIsInRange(self, self.theBall.transform, self.forceFailCheckRange) then
			self.PassFail(self, self.theBall)

			return true
		end

		return false
	end

	if not self.theBall:CanBeHit() then
		return false
	end

	if self.theBall.targetCharacter ~= self and self.CheckIsInRange(self, self.theBall.transform, self.nearCheckRange) then
		self.PassBall(self, self.theBall)

		return true
	elseif self.theBall.targetCharacter ~= self and self.CheckIsInRange(self, self.theBall.transform, self.mediumCheckRange) then
		self.PassBall(self, self.theBall)

		return true
	elseif self.CheckIsInRange(self, self.theBall.transform, self.farCheckRange) then
		self.PassFail(self, self.theBall)

		return true
	end
end

M.PassBall = function(self, ball)
	self.SwitchCharacterState(self, CharacterState.Match)

	local hitPivot = nil

	if ball.transform.localPosition.y >= 1 then
		self.animator:SetTrigger("pass_dun")

		hitPivot = self.passDunHitPivot
	else
		self.animator:SetTrigger("pass")

		hitPivot = self.passHitPivot
	end

	local dist = math.abs(self.teammate.transform.localPosition.z)
	local isSmash = dist <= self.gameInstance.passKoushaCheckDistance
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

M.PassFail = function(self, ball)
	self:SwitchCharacterState(CharacterState.Match)

	slot2 = self.animator

	slot2:SetTrigger("jieqiu_front_fail")

	local matchPos = self.transform.localPosition * self.gameInstance.failMovePointWeight + ball.localDestination * (1 - self.gameInstance.failMovePointWeight)
	matchPos = self:ClampLocalPosByTeam(matchPos, self.curTeam)
	matchPos.y = self.transform.localPosition.y
	slot3 = self.transform
	slot3 = slot3:DOLocalMove(matchPos, self.gameInstance.passFailMatchTime)

	slot3:OnComplete(function ()
		self:DelayFree(self.gameInstance.passFailFreeTime)
	end)
end

M.TryKickBackBall = function(self)
	if not self.canHitAction or self.gameInstance.curPossession == self.curTeam or not self.gameObject.activeSelf then
		return false
	end

	if self.GetHorDist(self) >= self.gameInstance.defenceEnterDistance and (self.theBall.targetCharacter ~= nil and self.theBall.curMoveReason ~= MoveReason.SPSmash or self.theBall.targetCharacter ~= self and self.theBall.curMoveReason ~= MoveReason.Smash) then
		self.Defence(self, self.theBall)

		return true
	end

	local direction = self.GetDirectionOfPos(self, self.theBall.transform.position)

	if self.theBall.curMoveReason ~= MoveReason.SPSmash then
		if self.CheckIsInRange(self, self.theBall.transform, self.forceFailCheckRange) then
			self.KickBackFail(self, self.theBall, direction)

			return true
		end

		return false
	end

	if not self.theBall:CanBeHit() then
		return false
	end

	if self.theBall.targetCharacter ~= self and self.CheckIsInRange(self, self.theBall.transform, self.nearCheckRange) then
		self.KickBackNormalBall(self, self.theBall, direction)

		return true
	elseif self.theBall.targetCharacter ~= self and self.CheckIsInRange(self, self.theBall.transform, self.mediumCheckRange) then
		self.KickBackNormalBall(self, self.theBall, direction)

		return true
	elseif self.CheckIsInRange(self, self.theBall.transform, self.farCheckRange) then
		self.KickBackFail(self, self.theBall, direction)

		return true
	end
end

M.Defence = function(self, ball)
	self:SwitchCharacterState(CharacterState.Match)
	self.animator:SetTrigger("defence")
	coroutine.start(self.DefenceCo, self, ball, self.gameInstance.defenceCheckStartTime, self.gameInstance.defenceCheckEndTIme, self.gameInstance.defenceDelayFreeTime)
end

M.KickBackFail = function(self, ball, direction)
	self.SwitchCharacterState(self, CharacterState.Match)

	if direction ~= Direction.Front or direction ~= Direction.Back then
		self.animator:SetTrigger("jieqiu_front_fail")
	elseif direction ~= Direction.Left then
		self.animator:SetTrigger("jieqiu_left_fail")
	else
		self.animator:SetTrigger("jieqiu_right_fail")
	end

	local targetPos = self.transform.position * self.gameInstance.failMovePointWeight + ball.localDestination * (1 - self.gameInstance.failMovePointWeight)
	targetPos = self:ClampLocalPosByTeam(targetPos, self.curTeam)
	targetPos.y = self.transform.localPosition.y
	slot4 = self.transform
	slot4 = slot4:DOLocalMove(targetPos, self.gameInstance.kickBackFailMatchTime)

	slot4:OnComplete(function ()
		self:DelayFree(self.gameInstance.kickBackFailFreeTime)
	end)
end

M.KickBackNormalBall = function(self, ball, direction)
	local opChar = self:GetRandomOpMember()

	self:SwitchCharacterState(CharacterState.Match)

	local targetPos = Mgr:GetRandomPosNearPos(opChar.transform.localPosition, self.randomRadius)
	targetPos = self:ClampLocalPosByTeam(targetPos, opChar.curTeam)
	local hitPivot, matchTime, freeTime = nil

	if direction ~= Direction.Front or direction ~= Direction.Back then
		self.animator:SetTrigger("jieqiu_front_success")

		hitPivot = self.frontHitPivot
		matchTime = self.gameInstance.kickBackFrontMatchTime
		freeTime = self.gameInstance.kickBackFrontFreeTime
	elseif direction ~= Direction.Left then
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

	self.MatchBallWaitHit(self, ball, hitPivot.position, targetPos, false, matchTime, freeTime, function ()
		self:HitBall(ball, targetPos, self.kickBackJumpPower, self.kickBackJumpTime)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
		ball:SetMoveData(opChar, MoveReason.KickBack)
		self.gameInstance:ChangePossession(self.opTeam)
	end)
end

M.TryLaunch = function(self)
	if self.canHitAction and self.launchCo ~= nil then
		self.isSmashQTE = false

		self.rootMotion:SwitchRootMotion(true)
		self.animator:SetTrigger("launch")

		self.launchCo = coroutine.start(self.LaunchCo, self, self.theBall, self.gameInstance.launchTossTime, self.gameInstance.launchHitTime, self.gameInstance.launchTotalTime)
	end

	return true
end

M.LaunchCo = function(self, ball, tossTime, hitTime, totalTime)
	local time1 = tossTime
	local time2 = hitTime - tossTime
	local time3 = totalTime - hitTime
	self.canSetQTELevel = false
	self.haveSetQTELevel = false

	self.SwitchCharacterState(self, CharacterState.LaunchQTE)

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

M.LaunchHit = function(self, ball, level)
	ball.transform:DOKill()

	local targetPos, opChar = nil

	Mgr:PrintDebug(self.transform.name .. " process " .. (self.isSmashQTE and "Smash" or "Launch"), "Level=", level)

	if level ~= QTELevel.Early then
		ball.SwitchPhysics(ball, true)
		ball.SetMoveData(ball, nil, MoveReason.FailSmash)
	elseif level ~= QTELevel.Normal then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)
		opChar = self:GetOpCharNearPos(targetPos)

		ball:NormalJumpByDuration(targetPos, self.smashMiddlePower, self.smashMiddleTime)
		ball:SetMoveData(opChar, MoveReason.Smash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	elseif level ~= QTELevel.Perfect then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)

		ball:SmashMove(targetPos, self.spSmashSpeed)
		ball:SetMoveData(self:GetOpCharNearPos(targetPos), MoveReason.SPSmash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	elseif level ~= QTELevel.Late then
		local forward = self.GetForwardVec(self)

		ball.SwitchPhysics(ball, true)
		ball.SetMoveData(ball, nil, MoveReason.FailSmash)
		ball.SetLocalVelocity(ball, Vector3.Normalize(forward + Vector3.down) * self.lateSmashSpeed)
	elseif level ~= QTELevel.Fake then
		targetPos = self:GetQTEPosByLevel(level)
		targetPos = self:ClampLocalPosByTeam(targetPos, self.opTeam)

		ball:SmashMove(targetPos, 9)
		ball:SetMoveData(nil, MoveReason.Smash)
		self.gameInstance:ChangePossession(self.opTeam)
		self.camMgr:SwitchCameraByTeam(self.opTeam)
	end
end

M.TryQTEConfirm = function(self)
	local deltaTime = Time.time - self.qteStartTime
	local level = self.CalcQTELevel(self, self.isSmashQTE, deltaTime)

	self.SetQTELevel(self, level)

	return true
end

M.TryQTEFake = function(self)
	if self.isSmashQTE then
		self.SetQTELevel(self, QTELevel.Fake)
	else
		Mgr:PrintError("Smash Error")
	end

	return true
end

M.SmashCo = function(self, ball, curTime, jumpTime, hitTime, totalTime)
	local time1 = jumpTime - curTime
	local time2 = hitTime - jumpTime
	local time3 = totalTime - hitTime
	self.canSetQTELevel = false
	self.haveSetQTELevel = false

	self.SwitchCharacterState(self, CharacterState.SmashQTE)

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

	self.LookForward(self, self.rotTime)
	coroutine.wait(time2)
	self.SetQTELevel(self, QTELevel.Late)
	self.LaunchHit(self, ball, self.curQTELevel)
	self.DelayFree(self, time3)
end

M.DefenceCo = function(self, ball, checkOpenTime, checkCloseTime, totalTime)
	local time1 = checkOpenTime
	local time2 = checkCloseTime - checkOpenTime
	local time3 = totalTime - checkCloseTime

	coroutine.wait(time1)

	local timer = time2
	local hitFlag = false
	local dist = 0

	while timer <= 0 do
		if hitFlag then
			break
		end

		dist = Vector3.Distance(self.defenceHitPivot.position, ball.transform.position)

		if dist >= self.gameInstance.defenceCheckDistance and ball.curMoveReason ~= MoveReason.Smash then
			hitFlag = true

			self.DefenceHit(self, ball)
		end

		coroutine.wait(0.05)

		timer = timer - 0.05
	end

	if timer <= 0 then
		coroutine.wait(timer)
	end

	self.SwitchCharacterState(self, CharacterState.Match)
	self.DelayFree(self, time3)
end

M.DefenceHit = function(self, ball)
	local targetPos = self:GetQTEPosByLevel(QTELevel.Fake)

	self:HitBall(ball, targetPos)
	ball:SetMoveData(self:GetOpCharNearPos(targetPos), MoveReason.KickBack)
	self.gameInstance:ChangePossession(self.opTeam)
	self.camMgr:SwitchCameraByTeam(self.opTeam)
end

M.ResetPosAtRebornPos = function(self)
	self.transform.position = self.rebornPivot.position
end

M.DelayFree = function(self, time)
	if time >= 0 then
		Mgr:PrintError("delay time error")

		return
	end

	if self.delayFreeCo then
		coroutine.stop(self.delayFreeCo)
	end

	if time ~= 0 then
		self.SwitchCharacterState(self, CharacterState.Free)

		return
	end

	self.delayFreeCo = coroutine.start(Mgr.TimerCo, nil, time, function ()
		self:SwitchCharacterState(CharacterState.Free)
	end)
end

M.SetQTELevel = function(self, level, isForce)
	if self.canSetQTELevel and not self.haveSetQTELevel or isForce then
		self.haveSetQTELevel = true
		self.curQTELevel = level
	end
end

M.AttachBallTToHand = function(self, ball)
	local ballTrans = ball.transform
	ballTrans.parent = self.launchHandPivot
	ballTrans.localPosition = Vector3.New(0, 0, 0)
end

M.SetRandomCloseUpTrigger = function(self)
	local trigger = "closeup_" .. math.random(0, 2)

	self.animator:SetTrigger(trigger)
end

M.MatchMoveAnim = function(self, horDir)
	local xValue = 0
	local yValue = 0

	if horDir == Vector2.zero then
		local relativePos = self.transform:InverseTransformPoint(self.transform.position + Mgr:ToVector3(horDir))
		xValue = relativePos.x
		yValue = relativePos.z
	end

	self.animator:SetFloat("X", xValue)
	self.animator:SetFloat("Y", yValue)
end

M.CheckIsInRange = function(self, otherTrans, checkRange)
	local selfPos = self.transform.localPosition
	local otherPos = otherTrans.localPosition
	local horDist = Vector2.Distance(Mgr:ToVector2XZ(selfPos), Mgr:ToVector2XZ(otherPos))
	local otherHeight = otherPos.y

	return checkRange.HeightRange.x < otherHeight and otherHeight < checkRange.HeightRange.y and horDist <= checkRange.Radius
end

M.GetDirectionOfPos = function(self, targetPos)
	local intervalRad = 0.785
	local selfForward = self.transform.forward
	local selfRad = math.atan(selfForward.z, selfForward.x)
	local posOffset = targetPos - self.transform.position
	local posRad = math.atan(posOffset.z, posOffset.x)
	local offsetRad = posRad - selfRad

	if offsetRad >= -intervalRad then
		offsetRad = offsetRad + 6.28
	end

	if offsetRad <= -intervalRad and offsetRad >= intervalRad then
		return Direction.Front
	elseif intervalRad >= offsetRad and offsetRad >= 3 * intervalRad then
		return Direction.Left
	elseif offsetRad <= 3 * intervalRad and offsetRad >= 5 * intervalRad then
		return Direction.Back
	else
		return Direction.Right
	end
end

M.GetRandomOpMember = function(self)
	return self.opTeamMembers[math.random(#self.opTeamMembers)]
end

M.GetOpCharNearPos = function(self, pos)
	local result = self.opTeamMembers[0]
	local dist = 0
	local minDist = 1000

	for _, member in pairs(self.opTeamMembers) do
		dist = Vector2.Distance(Mgr:ToVector2XZ(member.transform.localPosition), pos)

		if dist >= minDist then
			minDist = dist
			result = member
		end
	end

	return result
end

M.GetPassSmashTargetPos = function(self)
	local x = self.teammate.transform.localPosition.x
	local y = self.gameInstance.koushaHeight
	local z = self.gameInstance.koushaDistance * (self.curTeam ~= Team.My and -1 or 1)

	return Vector3.New(x, y, z)
end

M.GetQTEPosByLevel = function(self, qteLevel)
	if qteLevel ~= QTELevel.Normal then
		return Vector3.New(math.random(-1, 1) * self.gameInstance.koushaMiddleRandomRange, 0, self.gameInstance.koushaMiddleDistance * (self.curTeam ~= Team.My and 1 or -1))
	elseif qteLevel ~= QTELevel.Perfect then
		return Vector3.New(math.random(-1, 1) * self.gameInstance.koushaPerfectRandomRange, 0, self.gameInstance.koushaPerfectDistance * (self.curTeam ~= Team.My and 1 or -1))
	elseif qteLevel ~= QTELevel.Fake then
		return Vector3.New(self.transform.localPosition.x + math.random(-1, 1) * self.gameInstance.koushaFakeRandomRange, 0, self.gameInstance.koushaFakeDistance * (self.curTeam ~= Team.My and 1 or -1))
	else
		Mgr:PrintError("Invalid QTELevel=" .. qteLevel)
	end
end

M.CalcQTELevel = function(self, isSmash, deltaTime)
	if isSmash then
		if deltaTime >= self.gameInstance.smashQTEEarlyTime then
			return QTELevel.Early
		elseif deltaTime >= self.gameInstance.smashQTENormalTime then
			return QTELevel.Normal
		elseif deltaTime >= self.gameInstance.smashQTEPerfectTime then
			return QTELevel.Perfect
		else
			return QTELevel.Late
		end
	elseif deltaTime >= self.gameInstance.launchQTEEarlyTime then
		return QTELevel.Early
	elseif deltaTime >= self.gameInstance.launchQTENormalTime then
		return QTELevel.Normal
	elseif deltaTime >= self.gameInstance.launchQTEPerfectTime then
		return QTELevel.Perfect
	else
		return QTELevel.Late
	end
end

M.GetForwardVec = function(self)
	return self.gameInstance.rootNodeTrans.forward * (self.curTeam ~= Team.My and 1 or -1)
end

M.GetLocalForwardVec = function(self)
	return Vector3.New(0, 0, 1) * (self.curTeam ~= Team.My and 1 or -1)
end

M.GetHorDist = function(self)
	return math.abs(self.transform.localPosition.z)
end

M.ClampLocalPosByTeam = function(self, pos, team)
	pos = Mgr:ClampXZByRect(pos, self.gameInstance:GetRectByTeam(team))

	return pos
end

M.RootInverseTransformPoint = function(self, pos)
	return self.gameInstance.rootNodeTrans:InverseTransformPoint(pos)
end

M.LookForward = function(self, time)
	self.transform:DOLookAt(self.transform.position + self:GetForwardVec(), time)
end

M.LookAtTeammate = function(self, time)
	self.LookAtPos(self, self.teammate.transform.position, time)
end

M.LookAtPos = function(self, pos, time)
	local lookPos = Vector3.New(pos.x, self.transform.position.y, pos.z)

	self.transform:DOLookAt(lookPos, time)
end

M.LocalLookAtPos = function(self, pos, time)
	self:LookAtPos(self.gameInstance.rootNodeTrans:TransformPoint(pos), time)
end

M.CalcHitPos = function(self, radian, originPos)
	local x = originPos.x
	local y = originPos.y
	local z = originPos.z
	local sin = math.sin(radian)
	local cos = math.cos(radian)

	return Vector3.New(cos * x + sin * z, y, -sin * x + cos * z)
end
