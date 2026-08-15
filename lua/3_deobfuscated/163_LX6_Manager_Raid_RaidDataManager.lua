local DataSet = require("LX6/DataBind/DataSet")
local RaidConfig = LTConfig.RaidConfig
local GameConfig = LTConfig.GameConfig
local M = DataSet.New({
	HasReward = false,
	OpenDoorTime = 0,
	hostPid = 0,
	isRaidFailed = false,
	LastRaidId = 0,
	RaidInstanceId = 0,
	pvpGameEnd = false,
	LifeLeft = 0,
	realInVisiable = false,
	raidEndTime = -1,
	ActivityId = 0,
	autoHideRange = 0,
	reviveTime = 0,
	DisableZoom = false,
	mingyuejiThroneScore = 0,
	RaidId = 0,
	fallOffTime = -1,
	Rewarded = false,
	isAudience = false,
	StartTime = 0,
	RaidState = UX.Game.RaidProgressState.Prepare,
	WinCamp = UX.Game.UnitCamp.Unknown,
	OldPvpWeeklyTaskInfo = {},
	CampRanks = {},
	BattleData = {},
	activityMatchInfo = {
		StartTime = 0,
		MatchType = 0
	}
})

function M:OnEnterScene(enterInfo)
	local lastRaidId = self.RaidId

	self:Clear()

	self.RaidId = enterInfo.RaidId
	self.RaidInstanceId = enterInfo.InstanceId
	self.ActivityId = enterInfo.ActivityId
	self.LastRaidId = lastRaidId
	local raidCfg = RaidConfig.GetConfig(self.RaidId)

	if not raidCfg then
		print_error("副本信息在配表RaidConfig里查不到！！！RaidId = ", self.RaidId)
	end

	if raidCfg.AutoHideRange > 0 then
		self.autoHideRange = raidCfg.AutoHideRange
	end

	self.DisableZoom = false

	if GameConfig.SpecialFallRaid then
		for i = 1, #GameConfig.SpecialFallRaid do
			if GameConfig.SpecialFallRaid[i].RaidId == self.RaidId then
				self.fallOffTime = GameConfig.SpecialFallRaid[i].Time

				break
			end
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:Clear()
end

function M:Clear()
	self.LastRaidId = self.RaidId
	self.RaidId = 0
	self.RaidInstanceId = 0
	self.ActivityId = 0
	self.StartTime = 0
	self.RaidState = UX.Game.RaidProgressState.Prepare
	self.WinCamp = UX.Game.UnitCamp.Unknown
	self.CampRanks = {}
	self.BattleData = {}
	self.RewardInfo = nil
	self.OptionalDrop = nil
	self.autoHideRange = 0
	self.fallOffTime = -1
	self.hostName = nil
	self.hostPid = 0
	self.isAudience = false
	self.isRaidFailed = false
	self.mingyuejiThroneScore = 0
	self.openFreePaoku = false
	self.pvpGameEnd = false
	self.reviveTime = 0
	self.raidEndTime = -1
	self.raidSoloScore = nil
	self.realInVisiable = false
	self.HasReward = false
	self.Rewarded = false
	self.DisableZoom = false
	self.raidTargetCounterDict = nil
end

function M:UpdateRaidState(raidInstanceId, raidState)
	if self.RaidInstanceId ~= raidInstanceId then
		return
	end

	self.RaidState = raidState

	gMessageManager:SendMessage(gEventConstants.RAID_STATE_CHANGE, raidState)
end

function M:UpdateRaidStartTime(raidInstanceId, startTime)
	if self.RaidInstanceId ~= raidInstanceId then
		return
	end

	self.StartTime = startTime
end

function M:UpdateRaidRewardInfo(raidInstanceId, reward)
	if self.RaidInstanceId ~= raidInstanceId then
		return
	end

	self.RewardInfo = reward
end

function M:CanJumpInCurRaid()
	return true
end

function M:SetAllTarget(targetCounter)
	self.raidTargetCounterDict = targetCounter

	if gLuaUIMgr.raidTaskPanel then
		gLuaUIMgr.raidTaskPanel.RefreshRaidTarget()
	end
end

function M:UpdateOneTarget(targetId, counter)
	if self.raidTargetCounterDict == nil then
		self.raidTargetCounterDict = {}
	end

	self.raidTargetCounterDict[targetId] = counter

	if gLuaUIMgr.raidTaskPanel then
		gLuaUIMgr.raidTaskPanel.RefreshRaidTarget()
	end
end

function M:CheckShowSideBar()
	local raidCfg = RaidConfig.GetConfig(self.RaidId)
	local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	local openMainPhoneType = raidTypeCfg and raidTypeCfg.CanOpenMainCube or 1

	return openMainPhoneType == 2
end

gRaidDataManager = M
