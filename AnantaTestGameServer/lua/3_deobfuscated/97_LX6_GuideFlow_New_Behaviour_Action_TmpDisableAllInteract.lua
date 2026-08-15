C_GuideBT_TmpDisableAllInteract = DefClass("C_GuideBT_TmpDisableAllInteract", C_GuideBT_TmpDisableAllInteract, C_GuideBT_ActionBase)
local M = C_GuideBT_TmpDisableAllInteract

function M:OnTick()
	return gGuideNodeState.Running
end

function M:OnEnterRunning()
	gNewGuideMgr:Tmp_DisableBehaviourLimitAreaUpdate()

	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allLimit, true)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 1, true)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 2, true)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 3, true)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 4, true)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 7, true)
end

function M:OnExitRunning()
	gNewGuideMgr:Tmp_EnableBehaviourLimitAreaUpdate()

	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	gCS.BattleManager.SetLimitIndex(gCS.MyPlayerManager.PlayerUnit, gPaokuLimitManager.allLimit, false)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 1, false)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 2, false)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 3, false)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 4, false)
	gCS.BattleManager.SetFightLimitIndex(gCS.MyPlayerManager.PlayerUnit, 7, false)
end
