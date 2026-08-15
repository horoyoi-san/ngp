local PaokuLimitType = LX6.PaoKu.PaokuLimitType
local FightLimitType = LX6.PaoKu.FightLimitType
local M = gPaokuLimitManager or {}
M.triggerDisableBattleDic = {}
M.triggerDisableParkourDic = {}
M.allLimit = 99
M.allFightLimit = 6
M.limitIndexName = {
	"蓄力跳",
	"空中冲刺",
	"悬崖大小跳以及没有找到点的下翻跳",
	"飞索结尾跳出",
	"摆荡",
	"机车加速",
	"跳跃",
	"冲刺",
	"爬墙",
	"飞索",
	"摩托",
	"翻越障碍",
	"慢速爬墙",
	"蹲伏跳出",
	"墙面上蹬出墙",
	[99.0] = "禁用所有"
}
M.fightLimitIndexName = {
	"闪避",
	"普攻",
	"E技能",
	"战灵大招",
	"念力",
	"禁用所有",
	"切人技"
}

function M:SetTriggerDisableSkillByPid(index, value, pid)
	if not self.triggerDisableBattleDic[pid] then
		self.triggerDisableBattleDic[pid] = {}
	end

	self.triggerDisableBattleDic[pid][index] = value

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then
		gCoreHudUIManager:OnRefreshTriggerDisable(index, value == 1 and true or false)
	end
end

function M:ClearTriggerDisableSkillByPid(pid)
	if self.triggerDisableBattleDic[pid] then
		table.clear(self.triggerDisableBattleDic[pid])
	end

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then
		gCoreHudUIManager:ClearTriggerDisableSkill()
	end
end

function M:SetTriggerDisableParkourByPid(index, value, pid)
	if not self.triggerDisableParkourDic[pid] then
		self.triggerDisableParkourDic[pid] = {}
	end

	self.triggerDisableParkourDic[pid][index] = value

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then
		gMainMenuMgr:SetTriggerDisableParkour()
	end
end

function M:ClearTriggerDisableParkourByPid(pid)
	if self.triggerDisableParkourDic[pid] then
		table.clear(self.triggerDisableParkourDic[pid])
	end

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid == pid then
		gMainMenuMgr:SetTriggerDisableParkour()
	end
end

function M:ClearAllLimit(pid)
	self:ClearTriggerDisableSkillByPid(pid)
	self:ClearTriggerDisableParkourByPid(pid)
end

function M:CheckNeedLimit(index, pid)
	pid = pid or gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid or 0

	if self.triggerDisableParkourDic[pid] and index > 0 and (self.triggerDisableParkourDic[pid][index] and self.triggerDisableParkourDic[pid][index] == 1 or self.triggerDisableParkourDic[pid][self.allLimit] and self.triggerDisableParkourDic[pid][self.allLimit] == 1) then
		return true
	end

	return false
end

function M:CheckFightNeedLimit(index, pid)
	pid = pid or gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid or 0

	if self.triggerDisableBattleDic[pid] and index > 0 and (self.triggerDisableBattleDic[pid][index] and self.triggerDisableBattleDic[pid][index] == 1 or self.triggerDisableBattleDic[pid][self.allFightLimit] and self.triggerDisableBattleDic[pid][self.allFightLimit] == 1) then
		return true
	end

	return false
end

function M:CheckInDisableRushArea(pid)
	return self:CheckNeedLimit(PaokuLimitType.rush, pid) or self:CheckNeedLimit(PaokuLimitType.limitWalkCrouch, pid)
end

function M:CheckInDisableMoto(pid)
	return self:CheckNeedLimit(PaokuLimitType.moto, pid)
end

function M:CheckInDisableJump(pid)
	return self:CheckNeedLimit(PaokuLimitType.jump, pid)
end

function M:CheckInDisableOffWall(pid)
	return self:CheckNeedLimit(PaokuLimitType.LimitClimbJump, pid)
end

local inDisableFightArea = nil

function M:InDisableFightArea(pid)
	inDisableFightArea = self:CheckFightNeedLimit(FightLimitType.MindPower, pid)

	return inDisableFightArea
end

function M:GetLimitDataPaoKu(pid)
	pid = pid or gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid or 0
	local str = ""

	if self.triggerDisableParkourDic[pid] then
		for index, value in pairs(self.triggerDisableParkourDic[pid]) do
			if self.limitIndexName[index] then
				str = str .. self.limitIndexName[index] .. ","
			else
				str = str .. index .. ","
			end
		end
	end

	return str
end

function M:GetLimitDataFight(pid)
	pid = pid or gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.Pid or 0
	local str = ""

	if self.triggerDisableBattleDic[pid] then
		for index, value in pairs(self.triggerDisableBattleDic[pid]) do
			if self.fightLimitIndexName[index] then
				str = str .. self.fightLimitIndexName[index] .. ","
			else
				str = str .. index .. ","
			end
		end
	end

	return str
end

gPaokuLimitManager = M
