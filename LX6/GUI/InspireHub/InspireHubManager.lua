-- Original chunk: @Lua\LuaFiles\LX6\GUI\InspireHub\InspireHubManager.lua
-- Decompiled from: 00246_InspireHubManager.lua_d495a411c17f.luajit

local M = gInspireHubManager or {}

M.GetSeasonId = function(self)
	return self.CommonSeasonInfo and self.CommonSeasonInfo.CfgId
end

M.IsUnlock = function(self)
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.InspireHub)
end

M.GetGamePlayInfo = function(self, trialId)
	local seasonInfo = self.SeasonInfo or {}
	local gameplayDict = seasonInfo.GameplayDict or {}

	return gameplayDict[trialId]
end

M.RefreshPageData = function(self, storeName)
	local panelStore = gStoreManager:GetStoreGroup(storeName)

	if panelStore.STATE_EnableOnce then
		panelStore:RefreshPageData()
	end
end

M.SyncCompetitionSeasonChallengeUnlock = function(self, incrementFinishTemplateIdList)
	self:RefreshPageData("TrialPanelStore")
end

M.SyncCompetitionSeasonGameplayUnlock = function(self, incrementFinishTemplateIdList)
	self:RefreshPageData("InspireSeasonTabStore")
end

M.SyncInspireHubGameplayUnlock = function(self, incrementFinishTemplateIdList)
	self:RefreshPageData("InspireMainTabStore")
end

M.SyncPlayerCompetitionSeason = function(self, seasonInfo)
	seasonInfo = seasonInfo or {}
	self.CommonSeasonInfo = seasonInfo.CommonSeasonInfo
	self.SeasonInfo = seasonInfo.SeasonInfo
end

M.SyncPlayerUpdateCompetitionSeasonData = function(self, seasonInfo)
	self.SeasonInfo = seasonInfo
end

M.GetTimeCountDownStr = function(self)
	local seasonInfo = self.CommonSeasonInfo

	if seasonInfo ~= nil then
		print_error("未找到赛季信息！")

		return ""
	end

	local currentTime = gInspireHubUtils.GetCurrentServerTime()
	local startTime = seasonInfo.StartTime
	local endTime = seasonInfo.EndTime

	if currentTime >= startTime then
		return LTConfig.InspireHubConfig.UICountDownTime_NotStarted
	elseif endTime >= currentTime then
		return LTConfig.InspireHubConfig.UICountDownTime_Ended
	else
		local time = endTime - currentTime
		local days = math.floor(time / 86400)
		local hours = math.floor(time % 86400 / 3600)

		return gString.Format(LTConfig.InspireHubConfig.UICountDownTime_Format, days, hours)
	end
end

M.HasTakenReward = function(self, rewardId)
	return table.contains((self.SeasonInfo or {}).AwardList, rewardId)
end

M.TakeCompetitionSeasonOverallRankReward = function(self, rewardId, callback)
	if self:HasTakenReward(rewardId) then
		return
	end

	if self.t_waitTakeOverallRankRewardCallback then
		return
	end

	self.t_waitTakeOverallRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonOverallRankReward(rewardId).Callback = function (err)
		self.t_waitTakeOverallRankRewardCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			table.insert(self.SeasonInfo.AwardList, rewardId)
			callback()
		end
	end
end

M.TakeCompetitionSeasonHighestRankReward = function(self, rewardId, callback)
	if self:HasTakenReward(rewardId) then
		return
	end

	if self.t_waitTakeHighestRankRewardCallback then
		return
	end

	self.t_waitTakeHighestRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonHighestRankReward(rewardId).Callback = function (err)
		self.t_waitTakeHighestRankRewardCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			table.insert(self.SeasonInfo.AwardList, rewardId)
			callback()
		end
	end
end

M.TakeAllRewards = function(self, callback)
	if self.t_waitTakeAllRankRewardCallback then
		return
	end

	self.t_waitTakeAllRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonAllRankRewards().Callback = function (err)
		self.t_waitTakeAllRankRewardCallback = nil

		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			callback()
		end
	end
end

gInspireHubManager = M

return gInspireHubManager
