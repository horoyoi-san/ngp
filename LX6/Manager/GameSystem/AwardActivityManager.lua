-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\AwardActivityManager.lua
-- Decompiled from: 02252_AwardActivityManager.lua_69415594e826.luajit

local MessageConfig = LTConfig.MessageConfig
local AwardActivityConfig = LTConfig.AwardActivityConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local AwardActivityTemplateConfig = LTConfig.AwardActivityTemplateConfig
local NoticeConfig = LTConfig.AwardActivityNoticeConfig
local LevelLandmarkConfig = LTConfig.AwardActivityLevelLandmarkConfig
local PanelRedDotConfig = LTConfig.PanelRedDotConfig
local RedDotMgr = SGUI.RedDotMgr
local SevenDaysProgressConfig = LTConfig.AwardActivitySevenDaysProgressConfig
local SevenDaysTaskConfig = LTConfig.AwardActivitySevenDaysTaskConfig
local SevenDaysTabConfig = LTConfig.AwardActivitySevenDaysTabConfig
local EventConditionImplModule = UX.Game.EventConditionImplModule
C_AwardActivityManager = DefClass("C_AwardActivityManager", C_AwardActivityManager)
local M = C_AwardActivityManager

M.ctor = function(self)
	self:Clear()

	self.AWARD_STATE = {
		["\\x99\\x94&\\x8eC\\xdb"] = 2,
		["0g\\xb2\\xa5\\xa6e"] = 0,
		["ft\\xfc\\x98\\xa7-\\x912\\xec\\xcc"] = 1
	}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
end

M.OnBeforeSwitchScene = function(self, eventId, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		self:Clear()
	end
end

M.Clear = function(self)
	self.activityDict = {}
	self.sevenDaysRedDotStateDict = {}
	self.noticeCfgDict = {}
	self.levelLandmarkCfgDict = {}
end

M.CheckHasActivity = function(self)
	local systemUnlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.AwardActivity)

	return gGameSwitch.EnableActivity and not table.isNilOrEmpty(self.activityDict) and systemUnlock
end

M.CheckIsPermanentActivity = function(self, activityCfgId)
	local activityInfo = self:GetActivityInfo(activityCfgId)

	if table.isNilOrEmpty(activityInfo) or activityInfo.ActivityData.IsOutOfDate then
		return false
	end

	local endTime = activityInfo.BaseActivityInfo and activityInfo.BaseActivityInfo.EndTime

	return not endTime or endTime ~= 0
end

M.GetActivityList = function(self)
	local ret = {}

	for k, v in pairs(self.activityDict) do
		local cfg = AwardActivityConfig.GetConfig(k)

		if cfg then
			local ele = {
				Order = cfg.Order,
				id = k,
				title = cfg.Name,
				iconId = self:GetTabImage(k)
			}
			ret[#ret + 1] = ele
		end
	end

	table.sort(ret, function (a, b)
		return a.Order <= b.Order
	end)

	return ret
end

M.GetActivityTemplateIndex = function(self, activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	return cfg and cfg.TemplateId - 1 or 0
end

M.GetActivityTemplateId = function(self, activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	return cfg and cfg.TemplateId or 0
end

M.GetTabImage = function(self, activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	return cfg and cfg.TabImage or 0
end

M.GetActivityInfo = function(self, activityCfgId)
	return self.activityDict[activityCfgId] or {}
end

M.GetActivityEndDuration = function(self, activityCfgId)
	local activityInfo = self:GetActivityInfo(activityCfgId)

	if table.isNilOrEmpty(activityInfo) or activityInfo.ActivityData.IsOutOfDate then
		return 0
	end

	local endTime = activityInfo.BaseActivityInfo and activityInfo.BaseActivityInfo.EndTime

	if not endTime or endTime ~= 0 then
		return 0
	end

	return math.max(0, endTime - gCS.TimeManager.ServerUnixTime)
end

M.OpenActivity = function(self)
	if not self:CheckHasActivity() then
		return false
	end

	gPanelManager:CheckShow(gPanelId.ACTIVITY_BASE_PANEL)

	return true
end

M._GetSevenDaysBaseTabList = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return nil, 
	end

	return info, info.BaseActivityInfo and info.BaseActivityInfo.TabList
end

M.GetSevenDaysTabBaseList = function(self, activityCfgId)
	local _, tabList = self:_GetSevenDaysBaseTabList(activityCfgId)

	if table.isNilOrEmpty(tabList) then
		return {}
	end

	local ret = {}

	for i = 1, #tabList do
		local id = tabList[i].TabCfgId
		local cfg = SevenDaysTabConfig.GetConfig(id)
		local isUnlock = gEventConditionUtils.CheckHasUnlocked(cfg, EventConditionImplModule.SevenDaysTab)
		ret[i] = {
			cfgId = id,
			tabId = cfg.TabId,
			title = cfg.TabName,
			isUnlock = isUnlock,
			taskList = {}
		}
	end

	return ret
end

M._GetSevenDaysTaskGotDict = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return {}
	end

	local taskInfoList = info.ActivityData and info.ActivityData.TaskInfoList

	if table.isNilOrEmpty(taskInfoList) then
		return {}
	end

	local taskDict = {}

	for i = 1, #taskInfoList do
		local taskInfo = taskInfoList[i]
		taskDict[taskInfo.Id] = taskInfo.IsAwardGot
	end

	return taskDict
end

M.GetSevenDaysTaskList = function(self, activityCfgId, tabCfgId)
	local _, tabList = self:_GetSevenDaysBaseTabList(activityCfgId)

	if table.isNilOrEmpty(tabList) then
		return {}
	end

	local sourceTab = nil

	for i = 1, #tabList do
		if tabList[i].TabCfgId ~= tabCfgId then
			sourceTab = tabList[i]

			break
		end
	end

	if not sourceTab or table.isNilOrEmpty(sourceTab.TaskList) then
		return {}
	end

	local taskDict = self:_GetSevenDaysTaskGotDict(activityCfgId)
	local ret = {}

	for i = 1, #sourceTab.TaskList do
		local id = sourceTab.TaskList[i]
		local cfg = SevenDaysTaskConfig.GetConfig(id)

		if cfg then
			ret[i] = {
				id = id,
				isGot = taskDict[id],
				isFinish = taskDict[id] == nil,
				order = cfg.Order
			}
		end
	end

	table.sort(ret, function (a, b)
		local pa = a.isFinish and (a.isGot and 2 or 0) or 1
		local pb = b.isFinish and (b.isGot and 2 or 0) or 1

		if pa == pb then
			return pa <= pb
		end

		return a.order <= b.order
	end)

	return ret
end

M.GetSevenDaysTabList = function(self, activityCfgId)
	local ret = self:GetSevenDaysTabBaseList(activityCfgId)

	for i = 1, #ret do
		ret[i].taskList = self:GetSevenDaysTaskList(activityCfgId, ret[i].cfgId)
	end

	return ret
end

M.GetSevenDaysProgress = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return 0
	end

	local ret = 0
	local taskInfoList = info.ActivityData and info.ActivityData.TaskInfoList

	if table.isNilOrEmpty(taskInfoList) then
		return 0
	end

	for i = 1, #taskInfoList do
		local taskInfo = taskInfoList[i]

		if taskInfo.IsAwardGot then
			local cfg = SevenDaysTaskConfig.GetConfig(taskInfo.Id)
			ret = ret + (cfg and cfg.AddValue or 0)
		end
	end

	return ret
end

M.GetSevenDaysTabProgress = function(self, activityId, tabCfgId)
	if not tabCfgId or tabCfgId < 0 then
		return 0
	end

	local info = self.activityDict[activityId]

	if table.isNilOrEmpty(info) then
		return 0
	end

	local tabList = info.BaseActivityInfo and info.BaseActivityInfo.TabList

	if table.isNilOrEmpty(tabList) then
		return 0
	end

	local dayTaskList = nil

	for i = 1, #tabList do
		if tabList[i].TabCfgId ~= tabCfgId then
			dayTaskList = tabList[i].TaskList

			break
		end
	end

	if table.isNilOrEmpty(dayTaskList) then
		return 0
	end

	local taskIdSet = {}

	for i = 1, #dayTaskList do
		taskIdSet[dayTaskList[i]] = true
	end

	local taskInfoList = info.ActivityData and info.ActivityData.TaskInfoList

	if table.isNilOrEmpty(taskInfoList) then
		return 0
	end

	local score = 0

	for i = 1, #taskInfoList do
		local taskInfo = taskInfoList[i]

		if taskInfo.IsAwardGot and taskIdSet[taskInfo.Id] then
			local cfg = SevenDaysTaskConfig.GetConfig(taskInfo.Id)
			score = score + (cfg and cfg.AddValue or 0)
		end
	end

	return score
end

M._GetSevenDaysTabCfgIdByTabId = function(self, activityCfgId, tabId)
	if not tabId or tabId < 0 then
		return nil
	end

	local _, tabList = self:_GetSevenDaysBaseTabList(activityCfgId)

	if table.isNilOrEmpty(tabList) then
		return nil
	end

	for i = 1, #tabList do
		local tabCfgId = tabList[i].TabCfgId
		local tabCfg = SevenDaysTabConfig.GetConfig(tabCfgId)

		if tabCfg and tabCfg.TabId ~= tabId then
			return tabCfgId
		end
	end

	return nil
end

M.GetSevenDaysTabProgressByTabId = function(self, activityId, tabId)
	local tabCfgId = self:_GetSevenDaysTabCfgIdByTabId(activityId, tabId)

	if not tabCfgId then
		return 0
	end

	return self:GetSevenDaysTabProgress(activityId, tabCfgId)
end

M._GetSevenDaysProgressNeedValue = function(self, cfg)
	if not cfg then
		return 0
	end

	local needTabValue = cfg.NeedTabValue

	if needTabValue and needTabValue[1] and needTabValue[1] <= 0 then
		return needTabValue[1]
	end

	return cfg.NeedValue or 0
end

M.IsSevenDaysFinalProgress = function(self, progressCfgId)
	local cfg = SevenDaysProgressConfig.GetConfig(progressCfgId)

	if not cfg or table.isNilOrEmpty(cfg.RefTab) then
		return false
	end

	return #cfg.RefTab >= 1
end

M.GetSevenDaysProgressList = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return {}, 0
	end

	local progressList = info.BaseActivityInfo and info.BaseActivityInfo.ProgressList

	if table.isNilOrEmpty(progressList) then
		return {}, 0
	end

	local gotList = self:GetSevenDaysProgressAwardGotList(activityCfgId)
	local gotDict = {}

	for i = 1, #gotList do
		gotDict[gotList[i]] = true
	end

	local ret = {}
	local maxValue = 0

	for i = 1, #progressList do
		local id = progressList[i]
		local cfg = SevenDaysProgressConfig.GetConfig(id)

		if cfg and not self:IsSevenDaysFinalProgress(id) then
			local name = nil

			if cfg.ShowTabId and cfg.ShowTabId <= 0 then
				local tabCfg = SevenDaysTabConfig.GetConfig(cfg.ShowTabId)
				name = tabCfg and tabCfg.TabName
			end

			local needValue = self:_GetSevenDaysProgressNeedValue(cfg)
			local refTabId = cfg.RefTab and cfg.RefTab[1] or 0
			local dayScore = self:GetSevenDaysTabProgressByTabId(activityCfgId, refTabId)
			ret[#ret + 1] = {
				id = id,
				neddValue = needValue,
				dropId = cfg.DropId,
				isFinish = needValue > dayScore,
				isGot = gotDict[id] ~= true,
				name = name
			}
			maxValue = math.max(needValue, maxValue)
		end
	end

	table.sort(ret, function (a, b)
		return (a.neddValue or 0) <= (b.neddValue or 0)
	end)

	return ret, maxValue
end

M.GetSevenDaysFinalProgressInfo = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return nil
	end

	local progressList = info.BaseActivityInfo and info.BaseActivityInfo.ProgressList

	if table.isNilOrEmpty(progressList) then
		return nil
	end

	local gotList = self:GetSevenDaysProgressAwardGotList(activityCfgId)
	local gotDict = {}

	for i = 1, #gotList do
		gotDict[gotList[i]] = true
	end

	for i = 1, #progressList do
		local id = progressList[i]

		if self:IsSevenDaysFinalProgress(id) then
			local cfg = SevenDaysProgressConfig.GetConfig(id)
			local refTab = cfg.RefTab
			local needTabValue = cfg.NeedTabValue
			local isFinish = true
			local doneCnt = 0
			local totalCnt = math.min(#refTab, #needTabValue)

			for j = 1, totalCnt do
				local need = needTabValue[j] or 0
				local cur = self:GetSevenDaysTabProgressByTabId(activityCfgId, refTab[j])

				if need > 0 or need < cur then
					doneCnt = doneCnt + 1
				else
					isFinish = false
				end
			end

			return {
				["MBhmx="] = 0,
				id = id,
				dropId = cfg.DropId,
				isFinish = isFinish,
				isGot = gotDict[id] ~= true
			}
		end
	end

	return nil
end

M.GetSevenDaysProgressAwardGotList = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) then
		return {}
	end

	local gotList = info.ActivityData and info.ActivityData.ProgressAwardGotList

	return gotList or {}
end

M.GetSevenDaysTaskProgress = function(self, id)
	return gEventConditionUtils.GetEventInfoProgress(EventConditionImplModule.SevenDaysTask, id, 0)
end

M.CheckSevenDaysTabHasRedDot = function(self, tabInfo)
	if not tabInfo or not tabInfo.isUnlock then
		return false
	end

	local taskList = tabInfo.taskList

	if not taskList then
		return false
	end

	for i = 1, #taskList do
		local taskInfo = taskList[i]

		if taskInfo.isFinish and not taskInfo.isGot then
			return true
		end
	end

	return false
end

M.GetSevenDayGuideId = function(self, id)
	local cfg = SevenDaysTabConfig.GetConfig(id)

	if cfg and cfg.GuideId then
		return cfg.GuideId
	end

	cfg = SevenDaysTaskConfig.GetConfig(id)

	return cfg and cfg.GuideId or 0
end

M.GetNoticeConfig = function(self, activityCfgId)
	if not self.noticeCfgDict then
		self.noticeCfgDict = {}
	end

	if self.noticeCfgDict[activityCfgId] then
		return self.noticeCfgDict[activityCfgId]
	end

	for i = 0, NoticeConfig.count - 1 do
		local cfg = NoticeConfig.LoadAt(i)

		if cfg and cfg.AwardActivityId ~= activityCfgId then
			self.noticeCfgDict[activityCfgId] = cfg

			return cfg
		end
	end

	return nil
end

M.GetNoticeAwardList = function(self, activityCfgId)
	local cfg = self:GetNoticeConfig(activityCfgId)

	if not cfg or not cfg.IsShowAward then
		return {}
	end

	return cfg.AwardConsumable or {}
end

M._GetNoticeUnlockDict = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) or table.isNilOrEmpty(info.ActivityData) then
		return {}
	end

	local unlockList = info.ActivityData.UnlockList
	local dict = {}

	if table.isNilOrEmpty(unlockList) then
		return dict
	end

	for i = 1, #unlockList do
		local noticeId = unlockList[i]

		if noticeId then
			dict[noticeId] = true
		end
	end

	return dict
end

M.IsNoticeUnlocked = function(self, activityCfgId, noticeCfgId)
	if not noticeCfgId then
		local cfg = self:GetNoticeConfig(activityCfgId)

		if not cfg then
			return false
		end

		noticeCfgId = cfg.Id
	end

	local dict = self:_GetNoticeUnlockDict(activityCfgId)

	return dict[noticeCfgId] ~= true
end

M.GetLevelLandmarkProgress = function(self)
	return gPlayerManager.infoMinor.bindData.fan12 / 10000 or 0
end

M._GetLevelLandmarkAwardGotInfo = function(self, activityCfgId)
	local info = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(info) or table.isNilOrEmpty(info.ActivityData) then
		return {}
	end

	return info.ActivityData.AwardGotInfo or {}
end

M._GetLevelLandmarkCfgList = function(self, activityCfgId)
	if not self.levelLandmarkCfgDict then
		self.levelLandmarkCfgDict = {}
	end

	local cache = self.levelLandmarkCfgDict[activityCfgId]

	if cache then
		return cache
	end

	local list = {}

	for i = 0, LevelLandmarkConfig.count - 1 do
		local cfg = LevelLandmarkConfig.LoadAt(i)

		if cfg and cfg.AwardActivityId ~= activityCfgId then
			list[#list + 1] = cfg
		end
	end

	table.sort(list, function (a, b)
		return a.GoalValue <= b.GoalValue
	end)

	self.levelLandmarkCfgDict[activityCfgId] = list

	return list
end

M.GetLevelLandmarkList = function(self, activityCfgId)
	local awardGotInfo = self:_GetLevelLandmarkAwardGotInfo(activityCfgId)
	local cfgList = self:_GetLevelLandmarkCfgList(activityCfgId)
	local ret = {}

	for i = 1, #cfgList do
		local cfg = cfgList[i]
		local gotFlag = awardGotInfo[cfg.Id]
		ret[#ret + 1] = {
			id = cfg.Id,
			goalValue = cfg.GoalValue,
			goalUnit = cfg.GoalUnit,
			goalName = cfg.GoalName,
			progressDesc = cfg.ProgressDesc,
			isFinish = gotFlag == nil,
			isGot = gotFlag ~= true,
			dropId = cfg.RewardDrop
		}
	end

	return ret
end

M.AskTakeLevelLandmarkReward = function(self, activityCfgId, landmarkCfgId)
	gClientToGameDelegate:AskTakeLevelLandmarkProgressReward(activityCfgId, landmarkCfgId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshRedDot(activityCfgId)
	end
end

M.GetAwaradList = function(self, activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return {}
	end

	local ret = {}

	if cfg.TemplateId ~= AwardActivityTemplateConfig.SignIn then
		self:GetSignInAwardList(ret, cfg)
	elseif cfg.TemplateId ~= AwardActivityTemplateConfig.SevenDays then
		-- Nothing
	end

	return ret
end

M.GetSignInFocusDay = function(self, activityCfgId)
	local list = self:GetAwaradList(activityCfgId)

	for i = 1, #list do
		if list[i].state ~= self.AWARD_STATE.UNRECEIVED then
			return i
		end
	end

	return self:GetFinalSignIn(activityCfgId)
end

M.GetFinalSignIn = function(self, id)
	local info = self.activityDict[id].ActivityData

	if table.isNilOrEmpty(info.SignInList) then
		return 1
	end

	return #info.SignInList
end

M.GetSignInAwardList = function(self, ret, cfg)
	local info = self.activityDict[cfg.Id].ActivityData
	local signList = info.SignInList
	local rewardList = self.activityDict[cfg.Id].BaseActivityInfo.DisplayReward
	local dropList = self.activityDict[cfg.Id].BaseActivityInfo.Rewards
	local focusList = self.activityDict[cfg.Id].BaseActivityInfo.FocusRewards

	if table.isNilOrEmpty(signList) or table.isNilOrEmpty(rewardList) or table.isNilOrEmpty(dropList) or table.isNilOrEmpty(focusList) then
		return
	end

	for i = 1, #rewardList do
		local signIn = signList[i]
		local state = signIn and self.AWARD_STATE.UNRECEIVED or self.AWARD_STATE.LOCKED

		if signIn and signIn.IsGot then
			state = self.AWARD_STATE.RECEIVED
		end

		local ele = {
			state = state,
			itemId = rewardList[i],
			dropId = dropList[i],
			isFocus = focusList[i]
		}
		ret[#ret + 1] = ele
	end
end

M.RefreshTaskAwardState = function(self, activityCfgId, index)
	local activityInfo = self.activityDict[activityCfgId]

	if table.isNilOrEmpty(activityInfo) or table.isNilOrEmpty(activityInfo.ActivityData) then
		return
	end

	local taskInfoList = activityInfo.ActivityData.TaskInfoList

	if table.isNilOrEmpty(taskInfoList) then
		return
	end

	for i = 1, #taskInfoList do
		local taskInfo = taskInfoList[i]

		if taskInfo.Id ~= index then
			taskInfo.IsAwardGot = true

			break
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

M.RefreshAwardState = function(self, activityCfgId, index)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return {}
	end

	if cfg.TemplateId ~= AwardActivityTemplateConfig.SignIn then
		self:RefreshSignInAwardState(cfg, index)
	end

	if cfg.TemplateId ~= AwardActivityTemplateConfig.SevenDays then
		local activityInfo = self.activityDict[activityCfgId]

		if not table.isNilOrEmpty(activityInfo) and not table.isNilOrEmpty(activityInfo.ActivityData) then
			local gotList = activityInfo.ActivityData.ProgressAwardGotList

			if not gotList then
				gotList = {}
				activityInfo.ActivityData.ProgressAwardGotList = gotList
			end

			local hasGot = false

			for i = 1, #gotList do
				if gotList[i] ~= index then
					hasGot = true

					break
				end
			end

			if not hasGot then
				gotList[#gotList + 1] = index
			end
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

M.RefreshSignInAwardState = function(self, cfg, index)
	local info = self.activityDict[cfg.Id].ActivityData
	local signIn = info.SignInList[index]

	if not signIn then
		return
	end

	self.activityDict[cfg.Id].ActivityData.SignInList[index].IsGot = true
end

M.AskTakeReward = function(self, activityCfgId, index)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return
	end

	if cfg.TemplateId ~= AwardActivityTemplateConfig.SevenDays then
		self:AskTakeSevenDaysReward(activityCfgId, index)

		return
	end

	if cfg.TemplateId ~= AwardActivityTemplateConfig.LevelLandmark then
		self:AskTakeLevelLandmarkReward(activityCfgId, index)

		return
	end

	gClientToGameDelegate:AskTakeAccumulateSignInReward(activityCfgId, index).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshAwardState(activityCfgId, index)
		self:RefreshRedDot(activityCfgId)
	end
end

M.AskTakeSevenDaysReward = function(self, activityCfgId, progressId)
	gClientToGameDelegate:AskTakeSevenDaysProgressReward(activityCfgId, progressId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshAwardState(activityCfgId, progressId)
		self:RefreshRedDot(activityCfgId)
	end
end

M.AskTakeSevenDaysTaskReward = function(self, activityCfgId, taskId)
	gClientToGameDelegate:AskTakeSevenDaysTaskReward(activityCfgId, taskId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshTaskAwardState(activityCfgId, taskId)
		self:RefreshRedDot(activityCfgId)
	end
end

M.RefreshRedDot = function(self, key)
	if key then
		self:_RefreshActivityRedDot(key)

		return
	end

	for k, _ in pairs(self.activityDict) do
		self:_RefreshActivityRedDot(k)
	end
end

M._RefreshActivityRedDot = function(self, activityCfgId)
	RedDotMgr.LuaSetRedDot(self:CheckHasNewInfo(activityCfgId), self:GetRedDot(activityCfgId))

	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg or cfg.TemplateId == AwardActivityTemplateConfig.SevenDays then
		self:_ClearSevenDaysChildRedDots(activityCfgId)

		return
	end

	self:_RefreshSevenDaysChildRedDots(activityCfgId)
end

M.GetSevenDaysTabRedDot = function(self, activityCfgId, tabCfgId, taskId)
	if tabCfgId ~= nil then
		tabCfgId = activityCfgId
	end

	return ("%s:%s/Activity.SevenDays.SecTabItem:%s"):format(self:GetRedDot(activityCfgId), tostring(tabCfgId), tostring(taskId))
end

M.GetSevenDaysProgressRedDot = function(self, activityCfgId, progressId)
	return ("%s:progress_%s"):format(self:GetRedDot(activityCfgId), tostring(progressId))
end

M._CollectSevenDaysChildRedDotState = function(self, activityCfgId)
	local stateDict = {}
	local tabList = self:GetSevenDaysTabList(activityCfgId)

	for i = 1, #tabList do
		local tabInfo = tabList[i]

		if tabInfo.isUnlock then
			for j = 1, #tabInfo.taskList do
				local taskInfo = tabInfo.taskList[j]
				stateDict[self:GetSevenDaysTabRedDot(activityCfgId, tabInfo.cfgId, taskInfo.id)] = taskInfo.isFinish and not taskInfo.isGot
			end
		end
	end

	local progressList = self:GetSevenDaysProgressList(activityCfgId)

	for i = 1, #progressList do
		local progressInfo = progressList[i]
		stateDict[self:GetSevenDaysProgressRedDot(activityCfgId, progressInfo.id)] = progressInfo.isFinish and not progressInfo.isGot
	end

	local finalInfo = self:GetSevenDaysFinalProgressInfo(activityCfgId)

	if finalInfo then
		stateDict[self:GetSevenDaysProgressRedDot(activityCfgId, finalInfo.id)] = finalInfo.isFinish and not finalInfo.isGot
	end

	return stateDict
end

M._ClearSevenDaysChildRedDots = function(self, activityCfgId)
	local lastStateDict = self.sevenDaysRedDotStateDict[activityCfgId]

	if table.isNilOrEmpty(lastStateDict) then
		self.sevenDaysRedDotStateDict[activityCfgId] = nil

		return
	end

	for redDotKey, _ in pairs(lastStateDict) do
		RedDotMgr.LuaSetRedDot(false, redDotKey)
	end

	self.sevenDaysRedDotStateDict[activityCfgId] = nil
end

M._RefreshSevenDaysChildRedDots = function(self, activityCfgId)
	local stateDict = self:_CollectSevenDaysChildRedDotState(activityCfgId)
	local lastStateDict = self.sevenDaysRedDotStateDict[activityCfgId]

	if not table.isNilOrEmpty(lastStateDict) then
		for redDotKey, _ in pairs(lastStateDict) do
			if stateDict[redDotKey] ~= nil then
				RedDotMgr.LuaSetRedDot(false, redDotKey)
			end
		end
	end

	for redDotKey, hasRedDot in pairs(stateDict) do
		RedDotMgr.LuaSetRedDot(hasRedDot, redDotKey)
	end

	if table.isNilOrEmpty(stateDict) then
		self.sevenDaysRedDotStateDict[activityCfgId] = nil

		return
	end

	self.sevenDaysRedDotStateDict[activityCfgId] = stateDict
end

M.GetRedId = function(self, activityCfgId, layer)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)
	local template = cfg and cfg.TemplateId or 0
	local tCfg = AwardActivityTemplateConfig.GetConfig(template)
	local redDotKey = tCfg and tCfg.RedDotKey or 0
	layer = layer or 1

	return not table.isNilOrEmpty(redDotKey) and redDotKey[layer] or 0
end

M.GetRedIdList = function(self, activityCfgId)
	local cfg = AwardActivityConfig.GetConfig(activityCfgId)
	local template = cfg and cfg.TemplateId or 0
	local tCfg = AwardActivityTemplateConfig.GetConfig(template)
	local redDotKey = tCfg and tCfg.RedDotKey or {}
	local redIdList = {}

	for i = 1, #redDotKey do
		local redId = redDotKey[i]

		if redId and redId <= 0 then
			redIdList[#redIdList + 1] = redId
		end
	end

	return redIdList
end

M.GetRedDot = function(self, activityCfgId)
	local redIdList = self:GetRedIdList(activityCfgId)
	local redDotChain = {
		"\\x8a\\xb2\\xa2|7\\xea*"
	}

	if not table.isNilOrEmpty(redIdList) then
		for i = 1, #redIdList do
			local cfg = PanelRedDotConfig.GetConfig(redIdList[i])

			if cfg and cfg.Name and cfg.Name == "" then
				redDotChain[#redDotChain + 1] = cfg.Name
			end
		end
	end

	return table.concat(redDotChain, "/")
end

M.CheckHasNewInfo = function(self, activityCfgId)
	local activityInfo = self.activityDict[activityCfgId]

	if not activityInfo then
		return false
	end

	local baseRed = activityInfo.ActivityData.ShowRedPoint

	if baseRed then
		return true
	end

	local cfg = AwardActivityConfig.GetConfig(activityCfgId)

	if not cfg then
		return false
	end

	if cfg.TemplateId ~= AwardActivityTemplateConfig.SevenDays then
		local progressList = self:GetSevenDaysProgressList(activityCfgId)

		for i = 1, #progressList do
			local progressInfo = progressList[i]

			if progressInfo.isFinish and not progressInfo.isGot then
				return true
			end
		end

		local finalInfo = self:GetSevenDaysFinalProgressInfo(activityCfgId)

		if finalInfo and finalInfo.isFinish and not finalInfo.isGot then
			return true
		end

		local tabList = self:GetSevenDaysTabList(activityCfgId)

		for i = 1, #tabList do
			local tabInfo = tabList[i]

			if tabInfo.isUnlock then
				local taskList = tabInfo.taskList

				for j = 1, #taskList do
					local taskInfo = taskList[j]

					if taskInfo.isFinish and not taskInfo.isGot then
						return true
					end
				end
			end
		end

		return false
	end

	local rewardList = self:GetAwaradList(activityCfgId)

	for i = 1, #rewardList do
		if rewardList[i].state ~= self.AWARD_STATE.UNRECEIVED then
			return true
		end
	end

	return false
end

M.AskCancelRedPoint = function(self, activityCfgId)
	if table.isNilOrEmpty(self.activityDict[activityCfgId]) then
		return
	end

	local hasRedPoint = self.activityDict[activityCfgId].ActivityData.ShowRedPoint

	if not hasRedPoint then
		return
	end

	self.activityDict[activityCfgId].ActivityData.ShowRedPoint = false

	gClientToGameDelegate:AskActivityCancelRedPoint(activityCfgId).Callback = function (err)
		if err == MessageConfig.Ok then
			self.activityDict[activityCfgId].ActivityData.ShowRedPoint = true

			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:RefreshRedDot(activityCfgId)
	end
end

M.OnSyncAwardActivity = function(self, activities)
	for i = 1, #activities do
		self.activityDict[activities[i].ActivityData.CfgId] = activities[i]
	end

	self:RefreshRedDot()
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

M.OnSyncNewActivity = function(self, activity)
	self.activityDict[activity.ActivityData.CfgId] = activity

	self:RefreshRedDot(activity.ActivityData.CfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

M.OnSyncActivityData = function(self, activityData)
	if table.isNilOrEmpty(self.activityDict[activityData.CfgId]) then
		return
	end

	self.activityDict[activityData.CfgId].ActivityData = activityData

	self:RefreshRedDot(activityData.CfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

M.OnRemoveActivity = function(self, activityCfgId)
	self.activityDict[activityCfgId] = nil

	self:RefreshRedDot(activityCfgId)
	gMessageManager:SendMessage(gEventConstants.ON_ACTIVITY_STATE_CHANGE)
end

gAwardActivityManager = gAwardActivityManager or C_AwardActivityManager.new()
