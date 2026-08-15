local M = gInspireHubManager or {}

function M:GetSeasonId()
	return self.CommonSeasonInfo and self.CommonSeasonInfo.CfgId
end

function M:IsUnlock()
	return gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.InspireHub)
end

function M:GetGamePlayInfo(trialId)
	local seasonInfo = self.SeasonInfo or {}
	local gameplayDict = seasonInfo.GameplayDict or {}

	return gameplayDict[trialId]
end

function M:RefreshPageData(storeName)
	local panelStore = gStoreManager:GetStoreGroup(storeName)

	if panelStore.STATE_EnableOnce then
		panelStore:RefreshPageData()
	end
end

function M:SyncCompetitionSeasonChallengeUnlock(incrementFinishTemplateIdList)
	self:RefreshPageData("TrialPanelStore")
end

function M:SyncCompetitionSeasonGameplayUnlock(incrementFinishTemplateIdList)
	self:RefreshPageData("InspireSeasonTabStore")
end

function M:SyncInspireHubGameplayUnlock(incrementFinishTemplateIdList)
	self:RefreshPageData("InspireMainTabStore")
end

function M:SyncPlayerCompetitionSeason(seasonInfo)
	seasonInfo = seasonInfo or {}
	self.CommonSeasonInfo = seasonInfo.CommonSeasonInfo
	self.SeasonInfo = seasonInfo.SeasonInfo
end

function M:SyncPlayerUpdateCompetitionSeasonData(seasonInfo)
	self.SeasonInfo = seasonInfo
end

function M:GetTimeCountDownStr()
	local seasonInfo = self.CommonSeasonInfo

	if seasonInfo == nil then
		print_error("未找到赛季信息！")

		return ""
	end

	local currentTime = gInspireHubUtils.GetCurrentServerTime()
	local startTime = seasonInfo.StartTime
	local endTime = seasonInfo.EndTime

	if currentTime < startTime then
		return LTConfig.InspireHubConfig.UICountDownTime_NotStarted
	elseif endTime < currentTime then
		return LTConfig.InspireHubConfig.UICountDownTime_Ended
	else
		local time = endTime - currentTime
		local days = math.floor(time / 86400)
		local hours = math.floor(time % 86400 / 3600)

		return gString.Format(LTConfig.InspireHubConfig.UICountDownTime_Format, days, hours)
	end
end

function M:HasTakenReward(rewardId)
	return table.contains((self.SeasonInfo or {}).AwardList, rewardId)
end

function M:TakeCompetitionSeasonOverallRankReward(rewardId, callback)
	if self:HasTakenReward(rewardId) then
		return
	end

	if self.t_waitTakeOverallRankRewardCallback then
		return
	end

	self.t_waitTakeOverallRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonOverallRankReward(rewardId).Callback = function (err)
		self.t_waitTakeOverallRankRewardCallback = nil

		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			table.insert(self.SeasonInfo.AwardList, rewardId)
			callback()
		end
	end
end

function M:TakeCompetitionSeasonHighestRankReward(rewardId, callback)
	if self:HasTakenReward(rewardId) then
		return
	end

	if self.t_waitTakeHighestRankRewardCallback then
		return
	end

	self.t_waitTakeHighestRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonHighestRankReward(rewardId).Callback = function (err)
		self.t_waitTakeHighestRankRewardCallback = nil

		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			table.insert(self.SeasonInfo.AwardList, rewardId)
			callback()
		end
	end
end

function M:TakeAllRewards(callback)
	if self.t_waitTakeAllRankRewardCallback then
		return
	end

	self.t_waitTakeAllRankRewardCallback = true

	gClientToGameDelegate:AskTakeCompetitionSeasonAllRankRewards().Callback = function (err)
		self.t_waitTakeAllRankRewardCallback = nil

		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			callback()
		end
	end
end

gInspireHubManager = M

return gInspireHubManager
