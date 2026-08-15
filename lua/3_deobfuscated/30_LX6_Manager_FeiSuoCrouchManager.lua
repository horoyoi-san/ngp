local UnitStateConfig = LTConfig.UnitStateConfig
local HackingConfig = LTConfig.HackingConfig
local FeisuoLineType = LX6.Share.FeisuoLineType
local M = gFeiSuoCrouchManager or {}
M.EdgeStartPoint = Vector3.zero
M.EdgeEndPoint = Vector3.zero
M.EdgeId = -1
M.OtherNearEdgeStartPoint = Vector3.zero
M.OtherNearEdgeEndPoint = Vector3.zero
M.OtherNearEdgeId = -1
M.lastCheckObstacleInCrouchUnitPos = Vector3.zero
M.lastCheckObstacleInCrouchUnitEulerY = 999
M.forwardHasObstacleInCrouch = false
M.crouchTargetDirection = Vector3.zero
M.lastCrouchTargetIsVertical = false
M.changeCrouchDirectionTime = 0
M.modifyAssassinationDirection = true
M.isTaskCrouch = false
M.FeiSuoCrouchType = {
	switchLineMoveTo = 8,
	rotateAndLeave = 4,
	rotateToCamera = 9,
	rotate = 2,
	leave = 5,
	moveAndEnterAdsorbPos = 6,
	switchLineNoChangeAction = 11,
	switchLineCloseTo = 7,
	resetRailingLerp = 10,
	enter = 1,
	rotate2 = 3
}
M.HideUI = false
M.debugFeisuoClick = false

function M:OnInit()
	self.EdgeStartPoint = Vector3.zero
	self.EdgeEndPoint = Vector3.zero
	self.EdgeId = -1
	self.hasAddGps = false
	self.modifyAssassinationDirection = true
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:ClearData()

	if gPlayerManager.main.bindData.isFeiSuoCrouch then
		self:LeaveFeiSuoCrouch()
	end
end

function M:ClearData()
	self:OnInit()
end

function M:SetIsFeiSuoCrouch(isFeiSuoCrouch)
	if gPlayerManager.main.bindData.isFeiSuoCrouch ~= isFeiSuoCrouch then
		gMainMenuMgr:SetRefreshAssassinate()
	end

	gPlayerManager.main.bindData.isFeiSuoCrouch = isFeiSuoCrouch
end

function M:FeisuoButtonClicked()
	if self.debugFeisuoClick == true then
		print_debug("FeisuoButtonClicked")
	end

	if gGadgetManager:OnTryFeiSuo() then
		if self.debugFeisuoClick == true then
			print_debug("FeisuoButtonClicked OnTryFeiSuo return")
		end

		return
	end

	if gFeisuoAssassMgr.InteractionInfo and ulong.Greater(gFeisuoAssassMgr.InteractionInfo.LockEnemyId, 0) and not gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.FeiSuoCrouch) then
		gCS.BattleManager.ForceUnitFeiSuoAttack(gFeisuoAssassMgr.InteractionInfo.LockEnemyId)
		gMessageManager:SendMessage(gEventConstants.FEISUO_UNIT_TARGET_CLICKED, {
			pid = gFeisuoAssassMgr.InteractionInfo.LockEnemyId
		})
	end

	local curTime = gLuaDataManager.serverTime
	local endTime = 0

	if curTime < endTime then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900046).Text)

		if self.debugFeisuoClick == true then
			print_debug("FeisuoButtonClicked serverTime return", curTime, endTime)
		end

		return
	end

	if gTaskManager.taskFeiSuo.hasTaskFeiSuo then
		gTaskManager:TryHandleCurrentTaskFeiSuo()

		if self.debugFeisuoClick == true then
			print_debug("FeisuoButtonClicked hasTaskFeiSuo return")
		end

		return
	end

	if self.debugFeisuoClick == true then
		print_debug("FeisuoButtonClicked select", gFeisuoUIUpdateMgr.selectFeisuoInfo.select)
	end

	if gFeisuoUIUpdateMgr.selectFeisuoInfo.select then
		local targetPos = gFeisuoUIUpdateMgr.selectFeisuoInfo.pos
		local feisuoType = 0

		if gFeisuoUIUpdateMgr.selectFeisuoInfo.pointCanMove then
			feisuoType = gLuaFightConstants.FeisuoType_Task
		end

		gFeiSuoCrouchManager:PlayFeisuoActionRotation(gCS.MyPlayerManager.PlayerUnitId, targetPos, nil, feisuoType)
	end
end

function M:FeisuoJumpClicked()
	gCS.FeisuoModuleMgr.SetIsFeiSuoLargeJump(gCS.MyPlayerManager.PlayerUnit, true)
end

function M:CSLeaveFeisuo()
	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.FeiSuo01, false)
	gCS.BattleManager.ClearFeiSuoAttack()

	gPlayerManager.main.bindData.isInFeisuo = false
end

function M:CrouchTargetChange(direction, isVertical)
	if isVertical then
		if self.lastCrouchTargetIsVertical == isVertical and gUtils:IsPositionEqual(self.crouchTargetDirection, direction) then
			return
		end

		gCS.TransitionMgr.changeCrouchDirectionTime = gLogicTime.time
		self.changeCrouchDirectionTime = gLogicTime.time
	else
		self.changeCrouchDirectionTime = 0
		gCS.TransitionMgr.changeCrouchDirectionTime = 0
	end

	self.lastCrouchTargetIsVertical = isVertical
	self.crouchTargetDirection = direction
	self.crouchTargetIsVertical = isVertical
end

function M:LeaveHengLiangTime()
	return self.changeCrouchDirectionTime > 0 and HackingConfig.LeaveHLtime < gLogicTime.time - self.changeCrouchDirectionTime
end

function M:SetIsMovingLine(enable)
	self.isMovingLine = enable
end

function M:PlayFeisuoActionRotation(pid, targetPos, dynamicTr, feisuoType, banMove, isPoint)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)
	feisuoType = feisuoType or 0
	banMove = banMove or false
	isPoint = isPoint or banMove
	local isTask = feisuoType == gLuaFightConstants.FeisuoType_Task

	if cs_unit and not gCS.BattleManager.HasHitState(cs_unit) and targetPos ~= nil and not gUtils:IsPositionEqual(Vector3.null, targetPos) then
		local isFeisuoLeft = gCS.FeiSuoCrouchManager.RefreshFeisuoLeft(targetPos)
		gCS.TransitionMgr.feisuoIndex = feisuoType
		local csIsTask = false

		if isTask and not banMove then
			csIsTask = true
		end

		gCS.FeisuoModuleMgr.SetFeisuoTargetPos(cs_unit, targetPos.x, targetPos.y, targetPos.z, dynamicTr, isFeisuoLeft, csIsTask, feisuoType, gCS.BattleManager.GetFeiSuoAttackLockEnemyId(), isTask and gDialogScriptFunc.taskFeisuoMover or nil)

		local ok = gCS.LuaUtils.CheckSwitchAction(true, true, true, 0)

		if ok and isTask then
			if banMove then
				gCS.FeiSuoCrouchManager.SetTaskFeisuoInfo(targetPos, isPoint)
			else
				gCS.FeiSuoCrouchManager.SetTaskFeisuoInfo(targetPos, isPoint)
			end
		end

		gDialogScriptFunc.taskFeisuoMover = nil

		return ok
	end

	return false
end

function M:PlayFeisuoActionRotationByCShape(pid, x, y, z, dynamicTr, feisuoType, banMove)
	local targetPos = Vector3.New(x, y, z)
	local ok = self:PlayFeisuoActionRotation(pid, targetPos, nil, feisuoType, banMove)

	return ok
end

gFeiSuoCrouchManager = M

return gFeiSuoCrouchManager
