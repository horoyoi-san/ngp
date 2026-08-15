local M = gSwitchSpiritManager or {}

function M:SetEnable(enable)
	self.enable = enable
end

M.newUnit = nil
M.oldUnit = nil
M.ChangeMySpiritData = {
	oldPid = ulong.zero,
	newPid = ulong.zero
}

function M:BeforeSwitchSpirit(oldUnitPid)
	self.isMotoState = gCS.MyPlayerManager.isMotorRider

	gCS.BaseUnitModuleUtils.LeaveMotoState(gCS.MyPlayerManager.PlayerUnit, true)
	gCS.MindPowerMgr:BreakAll()
end

function M:BeforeSetChangeUnit(spiritUnitPid, noClearold)
	local cs_spiritUnit = gCS.SceneDataMgr.GetUnit(spiritUnitPid)
	local cs_oldUnit = gCS.MyPlayerManager.PlayerUnit

	gSwitchSpiritManager:BeforeSwitchSpirit(cs_oldUnit.Pid)

	if cs_oldUnit then
		local dataSet = gDataSetManager:GetUnitData(cs_oldUnit.Pid)

		if dataSet then
			dataSet.isMe = false
		end
	end

	gCS.MyPlayerManager.SetCurControlSpiritPid(cs_spiritUnit.Pid, noClearold)

	local dataSet = gDataSetManager:GetUnitData(spiritUnitPid)

	if dataSet then
		dataSet.isMe = true
	end

	gDataSetManager:ReBindMyUnit(spiritUnitPid)
	gMessageManager:SendMessage(gEventConstants.CHANGE_MY_UNIT, spiritUnitPid)

	self.ChangeMySpiritData.oldPid = cs_oldUnit.Pid
	self.ChangeMySpiritData.newPid = cs_spiritUnit.Pid

	gMessageManager:SendMessage(gEventConstants.CHANGE_MY_UNIT2, self.ChangeMySpiritData)
end

gSwitchSpiritManager = M
