local Tween = require("LX6/Utils/Tween")
local UnitStateConfig = LTConfig.UnitStateConfig
local EffectConfig = LTConfig.EffectConfig
local EntityType = UX.Game.EntityType
local UnitModelManager = LX6.Units.UnitModelManager
local M = gUnitStateMgr or {}

function M:onInit()
	self.funcCached = {}
end

function M:OnBeforeSwitchScene(switchType)
	table.clear(self.funcCached)
end

function M:SetInFightState(pid, value)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit.IsMe then
		gPlayerManager.main.bindData.isInFightState = value
	end
end

function M:OnEnterFightState(pid)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit then
		return
	end

	if cs_unit.IsMe then
		gPlayerManager.main.bindData.isInFightState = true

		gMainMenuMgr:SetState(UnitStateConfig.FightS, true)
		gMessageManager:SendMessage(gEventConstants.PLAYER_FIGHT_STATUS_CHANGE, true)
	elseif cs_unit.ClientData.Type == UX.Game.EntityType.Enemy then
		gHackManager:TryRemoveHackEffectForUnit(cs_unit)
	end

	cs_unit.InFight = true
	local unitDataSet = gDataSetManager:GetUnitData(pid)

	if unitDataSet then
		unitDataSet.isFightState = true
	end

	gLockTargetMgr.currentFightStateShowNormalLockEffect = false

	if cs_unit.ClientData.Type == UX.Game.EntityType.Player then
		gUnitStateMgr:SetInFightState(pid, true)
	end

	if cs_unit.IsMe then
		gCS.BattleManager.CheckUnitBattleLookAtIK_CS()
	end
end

function M:OnLeaveFightState(pid)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit then
		return
	end

	cs_unit.InFight = false
	local unitDataSet = gDataSetManager:GetUnitData(pid)

	if unitDataSet then
		unitDataSet.isFightState = false
	end

	if cs_unit.ClientData.Type == EntityType.Player then
		gUnitStateMgr:SetInFightState(pid, false)
	end

	cs_unit.attackStateTime = 0

	if cs_unit.IsMe then
		gCS.BattleManager.CheckUnitBattleLookAtIK_CS()
	end

	if cs_unit.isMySpirit and not gBattleSpiritMgr:IsFightSpiritAllFightS() then
		gPlayerManager.main.bindData.isInFightState = false

		gMainMenuMgr:SetState(UnitStateConfig.FightS, false)
		gMessageManager:SendMessage(gEventConstants.PLAYER_FIGHT_STATUS_CHANGE, false)
	end
end

function M:OnLeaveClimbState(pid)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit then
		return
	end

	if not cs_unit.IsMe then
		gUnitStateMgr:LeaveClimbAction(cs_unit, true)
	end

	gCS.EffectMgr:StopEffectForUnit(pid, EffectConfig.PaokuClimbEffect)
end

function M:LeaveClimbAction(cs_unit, force)
	if force or gCS.UnitStateMgr:HasState(cs_unit, UnitStateConfig.ClimbState) then
		gCS.PaoKuManager.LeaveClimbing(cs_unit)
		cs_unit:ResetActionGroupId(false, true)
		ActionManager.StopInteractiveAction(cs_unit)
	end
end

function M:OnLeaveFlatten(pid)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit then
		return
	end

	local duration = 0.5
	local timer = nil
	local scale = cs_unit.MeshRoot.localScale
	local scaleOffset = Vector3.one - scale
	local tweenObj = {
		t = 0
	}
	local tween = Tween.new(duration, tweenObj, {
		t = 1
	}, "outQuint")
	timer = Timer.New(function ()
		tween:update(Time.deltaTime)

		if tweenObj.t >= 1 then
			timer:Stop()
		end

		if not cs_unit.IsDead then
			cs_unit.MeshRoot.localScale = scaleOffset * tweenObj.t + scale
		end
	end, 0, -1):Start()
end

function M:OnStateChangeNoInteractive(pid)
	return
end

function M:OnStateAddNoMindPower(pid)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if cs_unit and cs_unit.IsMe then
		gCS.MindPowerMgr:BreakAll()
		gMainMenuMgr:SetState(UnitStateConfig.NoMindPower, true)
	end
end

function M:EnterOrLeaveFreeBuilding(enable)
	gPlayerManager.main.bindData.isFreeClimbing = enable

	gCS.ParkourStateModule.SetClientState(LTConfig.ParkourStateConfig.ClimbWall01, enable)

	if enable and gCS.MyPlayerManager.PlayerUnit ~= nil then
		gCS.LuaUtils.TouchGround(gCS.MyPlayerManager.PlayerUnit, true, false)
	end
end

function M:ResetMyStateAndClearMove(forceChangeGroup, stopReason)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	gClientUtils:ClearPaoKuState(false, forceChangeGroup)
	gCS.FeiSuoCrouchManager.LeaveFeiSuoCrouch(true)
	gCS.MotionFlagManager.SetIsInRush(gCS.MyPlayerManager.PlayerUnit, false)

	if stopReason == nil then
		stopReason = gLuaFightConstants.SkillStop_Reason.None
	end

	gCS.ActionManager.ClearSkillState(gCS.MyPlayerManager.PlayerUnit, 0, stopReason)
	gCS.LuaUtils.TouchGround(gCS.MyPlayerManager.PlayerUnit, true, true)
	gUnitOperateManager:ResetParam()

	if forceChangeGroup then
		gCS.MyPlayerManager.PlayerUnit.State.ActionGroupId = gLuaFightConstants.ACTION_GROUP_01

		gCS.BattleManager.SetBattleActionGroupId(gCS.MyPlayerManager.PlayerUnit, gLuaFightConstants.ACTION_GROUP_01)
	else
		gCS.MyPlayerManager.PlayerUnit:ResetActionGroupId(false, true)
	end

	if stopReason ~= gLuaFightConstants.SkillStop_Reason.TimelineEnd then
		gCS.LogicStateMachineManager.HandleAutoIdle(gCS.MyPlayerManager.PlayerUnit)
	end
end

function M:LeaveInvisibleState(pid)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit then
		local invisiable = gCS.UnitStateMgr:HasState(unit, UnitStateConfig.InvisibleS)
		local invisibleToAll = gCS.UnitStateMgr:HasState(unit, UnitStateConfig.InvisibleToAll)

		if not invisibleToAll then
			unit.InvisibleToAll = false
		end

		if not invisiable and not invisibleToAll then
			unit.Invisible = false
		end
	end
end

function M:CSEnterOrLeaveSwing(enable)
	gUnitOperateManager.isJumpSwing = enable
	gPlayerManager.main.bindData.isSwing = enable
end

function M:DoEnterIdleSpeed(rideStopAction, playPlayerStopAction, forcePlayIdleAction)
	local csunit = gCS.MyPlayerManager.PlayerUnit

	if gCS.BattleManager.openCSSkillRuntime and gCS.MyPlayerManager.PlayerUnit and gCS.SkillHelper:CheckDoEnterIdleSpeed(gCS.MyPlayerManager.PlayerUnit.Pid) then
		csunit:SetFacing(csunit.WorldEulerY)

		return
	end

	if gClientUtils.CheckMainPhoneIsShowing() then
		return
	end

	if not playPlayerStopAction and not rideStopAction then
		csunit:StopMove(true)

		if forcePlayIdleAction then
			csunit.State.ActionGroupId = 1

			gCS.BattleManager.SetBattleActionGroupId(csunit, gLuaFightConstants.ACTION_GROUP_01)
			gCS.LogicStateMachineManager.DoEnterIdle(gCS.MyPlayerManager.PlayerUnit)
		end
	elseif gLuaDataManager.keyUpNotCheck == nil or gLuaDataManager.keyUpNotCheck == false then
		local r = gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

		if r then
			csunit:StopMove(false)
		end
	end
end

gUnitStateMgr = M

return M
