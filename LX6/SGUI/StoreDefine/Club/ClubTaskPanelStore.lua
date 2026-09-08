-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Club\ClubTaskPanelStore.lua
-- Decompiled from: 01240_ClubTaskPanelStore.lua_4526cc2bb8a4.luajit

C_ClubTaskPanelStore = DefClass("C_ClubTaskPanelStore", C_ClubTaskPanelStore, C_StoreGroup)
GroupName2Class.ClubTaskPanelStore = C_ClubTaskPanelStore
local M = C_ClubTaskPanelStore

M.OnStart = function(self)
	self.Init(self)
	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.CLUB_INFO_REFRESH] = self.CreateAction(self, self.OnClubDataRefresh),
		[gEventConstants.CLUB_MEMBER_LIST_REFRESH] = self.CreateAction(self, self.OnClubDataRefresh),
		[gEventConstants.ON_EVENT_CONDITION_PROGRESS_CHANGE] = self.CreateAction(self, self.OnClubDataRefresh),
		[gEventConstants.ON_LOGIC_WEEK_CHANGED] = self.CreateAction(self, self.OnClubDataRefresh),
		[gEventConstants.CLUB_TASK_INFO_REFRESH] = self.CreateAction(self, self.OnClubDataRefresh)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
	self.RefreshView(self)
end

M.Init = function(self)
	self.instance = {
		["6\\x85\\xfe\\xa3\\xb6\\xbc\\xdc\\xf05Î\\x87\\xf2"] = 1,
		["lz\\xb9u`\\xb7\\xe4Bf_f\\"] = 0,
		["g\\xf9&\\xff&9\\xc0u)\\xc3N\\xbcK\\xc8\\xf2"] = 0,
		["@_Ϯ\\x8b\\x8a\\xc7\\xe3"] = 1,
		["\\xfa~/\\xd9\n\\xb3q\\xae_\\xbe\\xa2"] = 0,
		["@Kykb4"] = 0,
		["DW\\xacB#\\xe3G;xtfo\\xcf6y\\xe0D"] = 0,
		["j\\xa9\\x95\\xbeϿ\\xcb\\xaa+\\xa4\""] = 0,
		weeklyTaskList = {},
		rewardGotIdMap = {}
	}
end

M.RegisterWidget = function(self)
	self.bindData.weeklyRewardList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderWeeklyRewardItem)
	self.bindData.weeklyRewardList.luaSimpleClick = self.CreateAction(self, self.OnClickWeeklyRewardItem)
	self.bindData.weeklyTaskList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderWeeklyTaskItem)
	self.bindData.benefitBtn.luaClick = self.CreateAction(self, self.OnClickBenefitBtn)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)

	self.instance = nil
end

M.OnClubDataRefresh = function(self)
	self.RefreshView(self)
end

M.BuildRewardGotIdMap = function(self, rewardGotIds)
	local rewardGotIdMap = {}

	if rewardGotIds ~= nil then
		return rewardGotIdMap
	end

	for _, rewardId in ipairs(rewardGotIds) do
		rewardGotIdMap[rewardId] = true
	end

	return rewardGotIdMap
end

M.GetClaimableWeeklyRewardCfgList = function(self)
	local rewardCfgList = {}

	for i = 0, LTConfig.ClubWeeklyAwardConfig.count - 1 do
		local cfg = LTConfig.ClubWeeklyAwardConfig.LoadAt(i)
		local isRewardClaimable = gClubUIUtils:GetWeeklyRewardState(cfg, self.instance.myActivePoint, self.instance.rewardGotIdMap)

		if isRewardClaimable then
			table.insert(rewardCfgList, cfg)
		end
	end

	return rewardCfgList
end

M.MarkWeeklyRewardsAsGot = function(self, rewardCfgList)
	for _, cfg in ipairs(rewardCfgList) do
		self.instance.rewardGotIdMap[cfg.Id] = true
	end
end

M.ShowWeeklyRewardPopup = function(self, rewardCfgList)
	local dropList = {}

	for _, cfg in ipairs(rewardCfgList) do
		if cfg.DropId == 0 then
			table.insert(dropList, {
				["N\\xa1\\xb7\\xa1\\xa2"] = 1,
				dropId = cfg.DropId
			})
		end
	end

	if #dropList ~= 0 then
		return
	end

	local rewardList = gCommonItemManager:GetItemSortedListByDropList(dropList, true)

	if #rewardList ~= 0 then
		return
	end

	gDropManager:ShowRewardWindow({
		Param = rewardList
	})
end

M.RefreshData = function(self)
	local clubInfo = gClubManager:GetClubInfo()
	self.instance.weeklyTaskList = self:BuildWeeklyTaskList()
	self.instance.rewardGotIdMap = {}
	self.instance.myActivePoint = 0
	self.instance.seasonActivePoint = 0
	self.instance.mySeasonActivity = 0
	self.instance.seasonRank = 1
	self.instance.clubLevel = 0
	self.instance.clubLevelExp = 0
	self.instance.clubLevelTargetExp = 1
	self.instance.clubLevelProgressValue = 0

	if clubInfo ~= nil then
		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid
	local weeklyContribution = gClubUIUtils:GetCurrentWeeklyContribution(clubInfo)
	local myWeeklyContribution = gClubUIUtils:GetWeeklyMemberContribution(weeklyContribution, myPid)
	self.instance.rewardGotIdMap = self:BuildRewardGotIdMap(myWeeklyContribution.RewardGotIds)
	self.instance.myActivePoint = myWeeklyContribution.Activity or 0
	self.instance.seasonActivePoint = gClubUIUtils:GetSeasonActivePoint(clubInfo)
	self.instance.mySeasonActivity = gClubUIUtils:GetMemberSeasonActivity(clubInfo, myPid)
	self.instance.seasonRank = gClubUIUtils:GetSeasonRank(clubInfo, myPid)
	local clubLevel, currentExp, targetExp, progressValue = gClubUIUtils:GetClubLevelDisplayData(clubInfo)
	self.instance.clubLevel = clubLevel
	self.instance.clubLevelExp = currentExp
	self.instance.clubLevelTargetExp = targetExp
	self.instance.clubLevelProgressValue = progressValue
	self.instance.playerClubTaskInfo = gClubManager:GetPlayerClubTaskInfo()
	self.instance.weeklyTaskList = self:BuildWeeklyTaskList()
end

M.BuildWeeklyTaskList = function(self)
	local weeklyTaskList = {}

	for i = 0, LTConfig.ClubWeeklyTaskConfig.count - 1 do
		local cfg = LTConfig.ClubWeeklyTaskConfig.LoadAt(i)
		local progress = gEventConditionUtils.GetEventInfoProgress(UX.Game.EventConditionImplModule.ClubWeeklyTask, cfg.Id, 0)
		weeklyTaskList[#weeklyTaskList + 1] = {
			cfg = cfg,
			sortIndex = i,
			progress = progress,
			isFinished = cfg.MaxProgress > progress
		}
	end

	table.sort(weeklyTaskList, function (a, b)
		if a.isFinished == b.isFinished then
			return not a.isFinished
		end

		return a.sortIndex <= b.sortIndex
	end)

	return weeklyTaskList
end

M.RefreshView = function(self)
	self:RefreshData()

	self.bindData.seasonActivePointText = self.instance.seasonActivePoint
	self.bindData.myRankText = self.instance.seasonRank
	self.bindData.myActivePointText = self.instance.mySeasonActivity
	self.bindData.weeklyActivePointText = self.instance.myActivePoint
	self.bindData.clubLevel = tostring(self.instance.clubLevel)
	self.bindData.clubLevelProgressText = tostring(self.instance.clubLevelExp)
	self.bindData.clubLevelTargetScoreText = tostring(self.instance.clubLevelTargetExp)
	self.bindData.clubLevelProgress.maxValue = self.instance.clubLevelTargetExp <= 0 and self.instance.clubLevelTargetExp or 1
	self.bindData.clubLevelProgress.value = math.min(self.instance.clubLevelProgressValue, self.bindData.clubLevelProgress.maxValue)
	local maxActivityPoint = 0

	for i = 0, LTConfig.ClubWeeklyAwardConfig.count - 1 do
		local cfg = LTConfig.ClubWeeklyAwardConfig.LoadAt(i)

		if cfg and maxActivityPoint >= cfg.ActivityPoint then
			maxActivityPoint = cfg.ActivityPoint
		end
	end

	self.bindData.weeklyRewardProgress.maxValue = maxActivityPoint <= 0 and maxActivityPoint or 1
	self.bindData.weeklyRewardProgress.value = math.min(self.instance.myActivePoint, self.bindData.weeklyRewardProgress.maxValue)

	self.bindData.weeklyRewardList:SetSimpleList(LTConfig.ClubWeeklyAwardConfig.count)
	self.bindData.weeklyTaskList:SetSimpleList(#self.instance.weeklyTaskList)
end

M.OnClickBenefitBtn = function(self)
	gPanelManager:CheckShow(gPanelId.ONLINE_CLUB_LEVEL)
end

M.OnClickWeeklyRewardItem = function(self, btn, index)
	local cfg = LTConfig.ClubWeeklyAwardConfig.LoadAt(index)
	local clubInfo = gClubManager:GetClubInfo()

	if cfg ~= nil or clubInfo ~= nil then
		return
	end

	self:RefreshData()

	local isRewardClaimable = gClubUIUtils:GetWeeklyRewardState(cfg, self.instance.myActivePoint, self.instance.rewardGotIdMap)

	if not isRewardClaimable then
		return
	end

	local rewardCfgList = self.GetClaimableWeeklyRewardCfgList(self)

	if #rewardCfgList ~= 0 then
		return
	end

	slot7 = gClubManager

	slot7:AskTakeClubWeeklyAward(clubInfo.Id, cfg.Id, function (err)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:MarkWeeklyRewardsAsGot(rewardCfgList)
		self:ShowWeeklyRewardPopup(rewardCfgList)
		self.bindData.weeklyRewardList:RefreshList()
	end)
end

M.OnRenderWeeklyRewardItem = function(self, btn, index)
	local cfg = LTConfig.ClubWeeklyAwardConfig.LoadAt(index)

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup("ClubTaskPointTemplateStore"):GetStoreByWidget(btn)
	local isRewardClaimable, isRewardGot, isRewardLocked = gClubUIUtils:GetWeeklyRewardState(cfg, self.instance.myActivePoint, self.instance.rewardGotIdMap)
	store.rewardClaimCtrl = isRewardLocked and 0 or 1
	store.activityPointText = tostring(cfg.ActivityPoint)

	store.rayBox.gameObject:SetActive(isRewardClaimable)

	local renderData = gClubUIUtils:BuildWeeklyRewardRenderData(cfg.DropId, isRewardGot, isRewardLocked)

	gClubUIUtils:RenderCommonItem(store.rewardItem, renderData)
end

M.OnRenderWeeklyTaskItem = function(self, btn, index)
	local weeklyTaskData = self.instance.weeklyTaskList[index + 1]

	if not weeklyTaskData then
		return
	end

	local cfg = weeklyTaskData.cfg
	local isTaskFinished = weeklyTaskData.isFinished
	local displayProgress = math.min(weeklyTaskData.progress, cfg.MaxProgress)
	local store = gStoreManager:GetStoreGroup("ClubTaskTemplateStore"):GetStoreByWidget(btn)
	store.taskNameText = gString.Format(cfg.TaskDesc, cfg.MaxProgress)
	local playerClubTaskInfo = self.instance.playerClubTaskInfo
	local taskDict = gClubUIUtils:GetCurrentWeekTaskDict(playerClubTaskInfo)
	local taskInfo = taskDict and taskDict[cfg.Id]
	local currentFinishedTime = taskInfo and taskInfo.Count or 0
	store.taskFinishedCount = string.format("%d/%d", currentFinishedTime, cfg.MaxTime)
	store.currentProgressText = displayProgress
	store.targetProgressText = cfg.MaxProgress
	store.taskProgress.maxValue = cfg.MaxProgress
	store.taskProgress.value = displayProgress
	btn.interactable = not isTaskFinished
	local renderData = gClubUIUtils:BuildActivityPointItemRenderData(cfg.ActivityPointPerTime)

	gClubUIUtils:RenderCommonItem(store.rewardItem, renderData)

	store.rewardItem.interactable = not isTaskFinished
end
