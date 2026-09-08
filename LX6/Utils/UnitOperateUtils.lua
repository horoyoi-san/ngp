-- Original chunk: @Lua\LuaFiles\LX6\Utils\UnitOperateUtils.lua
-- Decompiled from: 00677_UnitOperateUtils.lua_90eedde9df30.luajit

local M = gUnitOperateUtils or {}
M.OperateType = {
	["\\xf2\\xde\r93\\xff"] = 1,
	["f\\xab\\xbb\\x9a\\xa6"] = 2
}

M.DoOperateFunc = function(type, unit)
	M.OperateFunc[type](unit)
end

M.JumpKeyDownFunc = function(unit)
	if gUnitOperateManager.isPressingJumpDown then
		return
	end

	if not gRaidDataManager:CanJumpInCurRaid() then
		return
	end

	gUnitOperateManager.isPressingJumpDown = true
	gCS.TransitionMgr.isPressingJumpDown = true

	M.DoJump(unit)
end

M.DoJump = function(unit)
	if unit then
		gCS.JumpModuleMgr.JumpKeyDown(unit)

		gUnitOperateManager.jumpKeyDownStartTime = Time.time
		gUnitOperateManager.isJumpKeyDown = true
		gCS.TransitionMgr.isJumpKeyDown = true

		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.JumpPress)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.JumpPress)

		if unit.IsMe then
			gCS.BaseUnitModuleUtils.CheckIsPedalOutWalling(gCS.MyPlayerManager.PlayerUnit)

			local r = gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

			if not r then
				gCS.SaveActionManager.Instance:CheckSaveAction(gCS.MyPlayerManager.PlayerUnit, gBattleMgr.SaveActionType.Jump)
			end
		end

		gUnitOperateManager.isJumpKeyDown = false
		gCS.TransitionMgr.isJumpKeyDown = false
	end
end

M.JumpKeyUpFunc = function(unit)
	unit = gCS.MyPlayerManager.PlayerUnit

	if unit then
		gCS.LogicStateMachineManager.Send3CEvent(unit, LTConfig.ABPCCCEventConfig.JumpRelease)
		gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(unit.Pid, LTConfig.ABPCCCEventConfig.JumpRelease)
		gCS.JumpModuleMgr.JumpKeyUp(unit)

		gUnitOperateManager.jumpKeyDownStartTime = 0
		gUnitOperateManager.isPressingJumpDown = false
		gCS.TransitionMgr.isPressingJumpDown = false
		gUnitOperateManager.isJumpKeyUp = true
		gCS.TransitionMgr.isJumpKeyUp = true

		gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

		gUnitOperateManager.isJumpKeyUp = false
		gCS.TransitionMgr.isJumpKeyUp = false
	end
end

M.LostFocusJumpKeyUpFunc = function(unit)
	if gUnitOperateManager.isPressingJumpDown then
		M.JumpKeyUpFunc(unit)
	end
end

M.OperateFunc = {
	[M.OperateType.KeyDown] = M.JumpKeyDownFunc,
	[M.OperateType.KeyUp] = M.JumpKeyUpFunc
}
gUnitOperateUtils = M

return gUnitOperateUtils
