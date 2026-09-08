-- Original chunk: @Lua\LuaFiles\LX6\Manager\SwitchSpiritManager.lua
-- Decompiled from: 00689_SwitchSpiritManager.lua_35ca6141aed5.luajit

local M = gSwitchSpiritManager or {}

M.SetEnable = function(self, enable)
	self.enable = enable
end

M.newUnit = nil
M.oldUnit = nil
M.ChangeMySpiritData = {
	oldPid = ulong.zero,
	newPid = ulong.zero
}

M.BeforeSwitchSpirit = function(self, oldUnit)
	gClientUtils:ClearPaoKuState()
	gCS.MindPowerMgr:BreakAll()
end

M.BeforeSetChangeUnit = function(self, spiritUnitPid, noClearold, isAgentSwitch)
	local cs_spiritUnit = gCS.SceneDataMgr.GetUnit(spiritUnitPid)
	local oldPid = 0
	local cs_oldUnit = gCS.MyPlayerManager.PlayerUnit

	gSwitchSpiritManager:BeforeSwitchSpirit(cs_oldUnit)

	if cs_oldUnit then
		local dataSet = gDataSetManager:GetUnitData(cs_oldUnit.Pid)

		if dataSet then
			dataSet.isMe = false
		end

		oldPid = cs_oldUnit.Pid
	end

	gCS.MyPlayerManager.SetCurControlSpiritPid(cs_spiritUnit.Pid, noClearold, isAgentSwitch)

	local dataSet = gDataSetManager:GetUnitData(spiritUnitPid)

	if dataSet then
		dataSet.isMe = true
	end

	gDataSetManager:ReBindMyUnit(spiritUnitPid)
	gMessageManager:SendMessage(gEventConstants.CHANGE_MY_UNIT, spiritUnitPid)

	self.ChangeMySpiritData.oldPid = oldPid
	self.ChangeMySpiritData.newPid = cs_spiritUnit.Pid

	gMessageManager:SendMessage(gEventConstants.CHANGE_MY_UNIT2, self.ChangeMySpiritData)
end

gSwitchSpiritManager = M
