-- Original chunk: @Lua\LuaFiles\LX6\Manager\SeasonLog\OnlineSeasonProgressMgr.lua
-- Decompiled from: 02280_OnlineSeasonProgressMgr.lua_92eed19dd37b.luajit

local SeasonConfig = LTConfig.OnlineSeasonProgressSeasonConfig
local SchemeConfig = LTConfig.OnlineSeasonProgressSchemeConfig
local PhaseConfig = LTConfig.OnlineSeasonProgressPhaseConfig
local PrimaryTasksConfig = LTConfig.OnlineSeasonProgressPrimaryTasksConfig
local UpgradeRewardConfig = LTConfig.OnlineSeasonProgressUpgradeRewardConfig
local MessageConfig = LTConfig.MessageConfig
local RedDotMgr = SGUI.RedDotMgr
local SeasonTaskState = {
	["0G\\x92\\x85\\x86E"] = 0,
	["`HayB<"] = 3,
	["\\x9e\\xbf\t\\xa4i5\\xfb7"] = 1,
	["\\xfa\\xd7!\\xf5"] = 4,
	["zT\\xfe\\xaf\\x8b\\xaa\\xda\\xfb"] = 2
}

if not gOnlineSeasonProgressMgr then
	local M = {
		["\\x8c1!,w\\x93m\\xdc!\\xaf\\xb5"] = 0,
		["0/!\\xf7|\\x96\\xc4 \\xa9=\\xf2\\xc6\\xefy\\xfe"] = 0,
		[" ?2\\xf6v\\x96\\xe3\\xad.\\xf5\\xfd\\xe8]\\xff"] = 0,
		["n\\xa9\\x95\\xbeϿ\\xcb\\xa73\\xb1\t3"] = false,
		["\\xf4\\x9f\\xff\\xd6\t\\xe5\\x8f\\xff\\x873;"] = 0,
		["\\xf4\\x9f\\xff\\xd5\\xe2\\x8d\\xe0\\x87\t,"] = 0,
		["\\xe6^?\\xde9\\xb8E\\x95_\\xbd\\xb3"] = 0,
		claimedLevelRewards = {},
		taskStates = {},
		_inProgressTaskList = {}
	}
end

M.SeasonTaskState = SeasonTaskState

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.ONLINE_SEASON_PROGRESS_FULL_SYNC, M.OnFullSync)
	gMessageManager:AddMessageListener(gEventConstants.ONLINE_SEASON_PROGRESS_STATE_CHANGED, M.OnStateChanged)
	gMessageManager:AddMessageListener(gEventConstants.ONLINE_SEASON_CHANGED, M.OnSeasonChanged)
end

M.OnBeforeSwitchScene = function(self, switchType)
end

M.ParseLoginData = function(self, info)
	if not info then
		return
	end

	self.currentSeasonId = info.CurrentSeasonId or 0
	self.isSeasonUnlocked = info.IsSeasonUnlocked or false
	self.seasonProgress = info.SeasonProgress or 0
	self.seasonLevel = info.SeasonLevel or 0
	self.claimedLevelRewards = info.ClaimedLevelRewards or {}
	self.taskStates = info.TaskStates or {}
	self.extraTaskStates = info.ExtraTaskStates or {}

	self:_InvalidateCache()
	self:_RefreshInProgressTaskList()
	self:_InitSeasonConfigFromId(self.currentSeasonId)
	self:RefreshRedDot()
end

M.OnFullSync = function(eventId, data)
	if not data then
		return
	end

	M:ParseLoginData(data)
end

M.OnSeasonChanged = function(eventId, info)
	if not info then
		return
	end

	M.currentSeasonId = info.SeasonId or 0
	M.seasonSchemeId = info.SchemeId or 0
	M.seasonStartTime = info.StartTime or 0
	M.seasonEndTime = info.EndTime or 0

	M:_InvalidateCache()
	M:_InitSeasonConfigFromId(M.currentSeasonId)
	M:RefreshRedDot()
end

M.OnStateChanged = function(eventId, delta)
	if not delta then
		return
	end

	local oldClaimedLevelRewards = M.claimedLevelRewards
	local oldLevel = M.seasonLevel

	if delta.SeasonProgress == nil then
		M.seasonProgress = delta.SeasonProgress
	end

	if delta.SeasonLevel == nil then
		M.seasonLevel = delta.SeasonLevel
	end

	if delta.IsSeasonUnlocked == nil then
		M.isSeasonUnlocked = delta.IsSeasonUnlocked

		M:_RefreshInProgressTaskList()
	end

	if delta.ChangedTaskStates then
		for taskId, newState in pairs(delta.ChangedTaskStates) do
			M.taskStates[taskId] = newState
		end

		M:_RefreshInProgressTaskList()
	end

	if delta.ChangedExtraTaskStates then
		for taskId, newState in pairs(delta.ChangedExtraTaskStates) do
			M.extraTaskStates[taskId] = newState
		end
	end

	if delta.ClaimedLevelRewards then
		M.claimedLevelRewards = delta.ClaimedLevelRewards
	end

	M:_ShowClaimedRewards(delta.ChangedTaskStates, oldClaimedLevelRewards, delta.ClaimedLevelRewards)
	M:RefreshRedDot()

	if M.seasonLevel == oldLevel then
		gMessageManager:SendMessage(gEventConstants.ONLINE_SEASON_LEVEL_CHANGED, M.seasonLevel)
	end
end

M.AskAcceptOnlineSeasonTask = function(self, taskId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskAcceptOnlineSeasonTask(taskId).Callback = function (errorId)
		if errorId == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.AskTakeTaskReward = function(self, taskId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskTakeOnlineSeasonProgressTaskReward(taskId).Callback = function (errorId)
		if errorId == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.AskTakeLevelReward = function(self, rewardId, callback)
	slot3 = gClientToGameDelegate

	slot3:AskTakeOnlineSeasonProgressLevelReward(rewardId).Callback = function (errorId)
		if errorId == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.AskTakeAllRewards = function(self, callback)
	slot2 = gClientToGameDelegate

	slot2:AskTakeAllOnlineSeasonProgressRewards().Callback = function (errorId)
		if errorId == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

M.HasActiveSeason = function(self)
	return self.currentSeasonId >= 0
end

M.GetCurrentSeasonConfig = function(self)
	if self._seasonCfg then
		return self._seasonCfg
	end

	if self.currentSeasonId < 0 then
		return nil
	end

	self._seasonCfg = SeasonConfig.GetConfig(self.currentSeasonId)

	return self._seasonCfg
end

M.GetTaskSchemeIds = function(self)
	local seasonCfg = self.GetCurrentSeasonConfig(self)

	if not seasonCfg or not seasonCfg.TaskSchemes then
		return {}
	end

	return seasonCfg.TaskSchemes
end

M.GetSchemeConfig = function(self, schemeId)
	return SchemeConfig.GetConfig(schemeId)
end

M.GetPhasesByScheme = function(self, phaseSchemeId)
	if self._phasesBySchemeId and self._phasesBySchemeId[phaseSchemeId] then
		return self._phasesBySchemeId[phaseSchemeId]
	end

	if not self._phasesBySchemeId then
		self._phasesBySchemeId = {}
	end

	local list = {}

	for i = 0, PhaseConfig.count - 1 do
		local cfg = PhaseConfig.LoadAt(i)

		if cfg and cfg.SchemeId ~= phaseSchemeId then
			list[#list + 1] = cfg
		end
	end

	table.sort(list, function (a, b)
		return a.PhaseId <= b.PhaseId
	end)

	self._phasesBySchemeId[phaseSchemeId] = list

	return list
end

M.GetTasksByPhase = function(self, phaseId)
	if self._tasksByPhaseId and self._tasksByPhaseId[phaseId] then
		return self._tasksByPhaseId[phaseId]
	end

	if not self._tasksByPhaseId then
		self._tasksByPhaseId = {}
	end

	local list = {}

	for i = 0, PrimaryTasksConfig.count - 1 do
		local cfg = PrimaryTasksConfig.LoadAt(i)

		if cfg and cfg.PhaseId ~= phaseId then
			list[#list + 1] = cfg
		end
	end

	self._tasksByPhaseId[phaseId] = list

	return list
end

M.GetTaskState = function(self, taskId)
	return self.taskStates[taskId] or SeasonTaskState.Locked
end

M.IsTaskUnlocked = function(self, taskId)
	if not self.isSeasonUnlocked then
		return false
	end

	return self:GetTaskState(taskId) == SeasonTaskState.Locked
end

M.IsTaskInCurrentSeason = function(self, taskId)
	local taskCfg = PrimaryTasksConfig.GetConfig(taskId)

	if not taskCfg then
		return false
	end

	local phaseCfg = PhaseConfig.GetConfig(taskCfg.PhaseId)

	if not phaseCfg then
		return false
	end

	for _, schemeId in ipairs(self.GetTaskSchemeIds(self)) do
		if self.GetPhaseSchemeIdByTaskSchemeId(self, schemeId) ~= phaseCfg.SchemeId then
			return true
		end
	end

	return false
end

M.GetInProgressTaskList = function(self)
	return self._inProgressTaskList or {}
end

M.GetTaskProgress = function(self, taskCfg)
	if not taskCfg then
		return 0
	end

	local maxProgress = taskCfg.MaxProgress or 0
	local state = self:GetTaskState(taskCfg.Id)

	if state ~= SeasonTaskState.Completed or state ~= SeasonTaskState.Claimed then
		return maxProgress
	end

	local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.OnlineSeasonProgressTask, taskCfg.Id, 0) or 0

	if maxProgress <= 0 and maxProgress >= progress then
		return maxProgress
	end

	return progress
end

M.FormatTaskText = function(self, text, maxProgress)
	if not text then
		return ""
	end

	local val = tostring(maxProgress or 0)
	text = text:gsub("%%d", val)
	text = text:gsub("{0}", val)

	return text
end

M.GetUpgradeRewardList = function(self)
	if self._upgradeRewardList then
		return self._upgradeRewardList
	end

	if self.currentSeasonId < 0 then
		return {}
	end

	local seasonCfg = self.GetCurrentSeasonConfig(self)

	if not seasonCfg then
		return {}
	end

	local list = {}

	for i = 0, UpgradeRewardConfig.count - 1 do
		local cfg = UpgradeRewardConfig.LoadAt(i)

		if cfg and cfg.SchemeId ~= self.currentSeasonId then
			list[#list + 1] = cfg
		end
	end

	table.sort(list, function (a, b)
		return a.Level <= b.Level
	end)

	self._upgradeRewardList = list

	return list
end

M.IsLevelRewardClaimed = function(self, rewardId)
	for _, id in ipairs(self.claimedLevelRewards) do
		if id ~= rewardId then
			return true
		end
	end

	return false
end

M.HasAnyClaimableReward = function(self)
	for _, state in pairs(self.taskStates) do
		if state ~= SeasonTaskState.Completed then
			return true
		end
	end

	local rewardList = self.GetUpgradeRewardList(self)

	for _, cfg in ipairs(rewardList) do
		if cfg.Level < self.seasonLevel and not self.IsLevelRewardClaimed(self, cfg.Id) and cfg.Reward and cfg.Reward <= 0 then
			return true
		end
	end

	return false
end

M.HasClaimableTaskInScheme = function(self, phaseSchemeId)
	local phases = self.GetPhasesByScheme(self, phaseSchemeId)

	for _, phaseCfg in ipairs(phases) do
		local tasks = self.GetTasksByPhase(self, phaseCfg.Id)

		for _, taskCfg in ipairs(tasks) do
			if self.GetTaskState(self, taskCfg.Id) ~= SeasonTaskState.Completed then
				return true
			end
		end
	end

	return false
end

M.GetSeasonRemainTime = function(self)
	local seasonCfg = self.GetCurrentSeasonConfig(self)

	if not seasonCfg or not seasonCfg.EndTime then
		return 0
	end

	local endTimestamp = self:_ConfigTimeToTimestamp(seasonCfg.EndTime)
	local now = os.time()
	local remain = endTimestamp - now

	return remain <= 0 and remain or 0
end

M.GetCurrentLevelProgressInfo = function(self)
	local rewardList = self.GetUpgradeRewardList(self)
	local currentCfg, nextCfg = nil

	for _, cfg in ipairs(rewardList) do
		if cfg.Level ~= self.seasonLevel then
			currentCfg = cfg
		elseif cfg.Level ~= self.seasonLevel + 1 then
			nextCfg = cfg
		end
	end

	local currentLevelBase = currentCfg and currentCfg.UpgradeProgress or 0
	local currentLevelProgress = self.seasonProgress - currentLevelBase

	if currentLevelProgress >= 0 then
		currentLevelProgress = 0
	end

	local nextLevelBase = nextCfg and nextCfg.UpgradeProgress or 0
	local currentLevelMax = nextLevelBase - currentLevelBase

	if currentLevelMax >= 0 then
		currentLevelMax = 0
	end

	local lastCfg = rewardList[#rewardList]
	local totalMax = lastCfg and lastCfg.UpgradeProgress or 0

	return {
		level = self.seasonLevel,
		levelName = currentCfg and currentCfg.LevelName or "",
		progress = currentLevelProgress,
		maxProgress = currentLevelMax,
		totalProgress = self.seasonProgress,
		totalMaxProgress = totalMax
	}
end

M.GetPhaseSchemeIdByTaskSchemeId = function(self, taskSchemeId)
	return taskSchemeId
end

M._InvalidateCache = function(self)
	self._seasonCfg = nil
	self._upgradeRewardList = nil
	self._phasesBySchemeId = nil
	self._tasksByPhaseId = nil
	self._inProgressTaskList = {}
end

M._RefreshInProgressTaskList = function(self)
	local list = {}

	for taskId, state in pairs(self.taskStates) do
		if state ~= SeasonTaskState.InProgress and self.IsTaskUnlocked(self, taskId) and self.IsTaskInCurrentSeason(self, taskId) then
			list[#list + 1] = taskId
		end
	end

	table.sort(list)

	self._inProgressTaskList = list
end

M._InitSeasonConfigFromId = function(self, seasonId)
	if seasonId < 0 then
		return
	end

	local cfg = SeasonConfig.GetConfig(seasonId)

	if cfg then
		self._seasonCfg = cfg

		if self.seasonStartTime ~= 0 and cfg.StartTime then
			self.seasonStartTime = self._ConfigTimeToTimestamp(self, cfg.StartTime)
		end

		if self.seasonEndTime ~= 0 and cfg.EndTime then
			self.seasonEndTime = self._ConfigTimeToTimestamp(self, cfg.EndTime)
		end
	end
end

M._ConfigTimeToTimestamp = function(self, t)
	if not t then
		return 0
	end

	return os.time({
		year = t.year or 2025,
		month = t.month or 1,
		day = t.day or 1,
		hour = t.hour or 0,
		min = t.minute or 0,
		sec = t.second or 0
	})
end

M._ShowClaimedRewards = function(self, changedTaskStates, oldClaimedList, newClaimedList)
	local dropList = {}

	if changedTaskStates then
		for taskId, newState in pairs(changedTaskStates) do
			if newState ~= SeasonTaskState.Claimed then
				local taskCfg = PrimaryTasksConfig.GetConfig(taskId)

				if taskCfg and taskCfg.Reward and taskCfg.Reward <= 0 then
					dropList[#dropList + 1] = {
						["N\\xa1\\xb7\\xa1\\xa2"] = 1,
						dropId = taskCfg.Reward
					}
				end
			end
		end
	end

	if newClaimedList then
		local oldSet = {}

		if oldClaimedList then
			for _, id in ipairs(oldClaimedList) do
				oldSet[id] = true
			end
		end

		for _, id in ipairs(newClaimedList) do
			if not oldSet[id] then
				local rewardCfg = UpgradeRewardConfig.GetConfig(id)

				if rewardCfg and rewardCfg.Reward and rewardCfg.Reward <= 0 then
					dropList[#dropList + 1] = {
						["N\\xa1\\xb7\\xa1\\xa2"] = 1,
						dropId = rewardCfg.Reward
					}
				end
			end
		end
	end

	if #dropList <= 0 then
		local rewardList = gCommonItemManager:GetItemSortedListByDropList(dropList, true)

		if #rewardList <= 0 then
			gDropManager:ShowRewardWindow({
				Param = rewardList
			})
		end
	end
end

M.RefreshRedDot = function(self)
	local STS = SeasonTaskState
	local schemeIds = self.GetTaskSchemeIds(self)

	for _, schemeId in ipairs(schemeIds) do
		local phaseSchemeId = self.GetPhaseSchemeIdByTaskSchemeId(self, schemeId)
		local phases = self.GetPhasesByScheme(self, phaseSchemeId)

		for _, phaseCfg in ipairs(phases) do
			local tasks = self.GetTasksByPhase(self, phaseCfg.Id)
			local typeOrder = {}
			local typeMap = {}

			for _, taskCfg in ipairs(tasks) do
				local tt = taskCfg.TaskType or ""

				if not typeMap[tt] then
					typeMap[tt] = {}
					typeOrder[#typeOrder + 1] = tt
				end

				typeMap[tt][#typeMap[tt] + 1] = taskCfg
			end

			for groupIdx, tt in ipairs(typeOrder) do
				local taskTypeUniqueId = phaseCfg.Id * 100 + groupIdx

				for _, taskCfg in ipairs(typeMap[tt]) do
					local hasRed = self:GetTaskState(taskCfg.Id) ~= STS.Completed

					RedDotMgr.LuaSetRedDot(hasRed, ("SeasonLog/SeasonLog.Scheme:%d/SeasonLog.Phase:%d/SeasonLog.TaskType:%d/SeasonLog.Task:%d"):format(phaseSchemeId, phaseCfg.Id, taskTypeUniqueId, taskCfg.Id))
				end
			end
		end
	end
end

gOnlineSeasonProgressMgr = M
