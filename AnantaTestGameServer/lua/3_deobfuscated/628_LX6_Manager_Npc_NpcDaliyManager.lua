local AtmosphereManager = LX6.Manager.AtmosphereManager
local ActivityConfig = LTConfig.AgentDataSetsActivityConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local NpcCultivationNpcFavorLevelConfig = LTConfig.NpcCultivationNpcFavorLevelConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local StaticProps = {}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_NpcDaliyManager = DefClass("C_NpcDaliyManager", C_NpcDaliyManager, nil, StaticProps)
local M = C_NpcDaliyManager

function M:Log(...)
	if not self.isDebug then
		return
	end

	print_debug("[C_NpcDaliyManager]", ...)
end

function M:ctor()
	self.isDebug = true
	self.PROCESS_TEMPLATE = {
		TASK = 3,
		SUIT = 5,
		HYPER = 1,
		ITEM = 2,
		PHONE = 4,
		FASHION = 6,
		NONE = 0
	}
	self.favorMgr = gNpcFavorManager

	self:InitData()
	self:BuildData()
end

function M:BuildData()
	self.agentType2Progress = {}
	self.eventId2Behavior = {}
	self.progress2Template = {}

	for i = 0, NpcCultivationNpcFavorLevelConfig.count - 1 do
		local cfg = NpcCultivationNpcFavorLevelConfig.LoadAt(i)
		local progressList = self.agentType2Progress[cfg.AgentTagId] or {}
		local eventId = self:GetEventId(cfg)

		table.insert(progressList, cfg.Id)

		self.agentType2Progress[cfg.AgentTagId] = progressList
		self.eventId2Behavior[eventId] = cfg.Id
	end
end

function M:InitData()
	self.NpcTimeTableInfos = {}
	self.NpcTimeTableLists = {}
	self.NpcTempLeave = {}
	self.todayNpcTimeTableInfos = {}

	self:OnQueueInit()

	self.preFrame = 0
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.LOADING_PANEL_CLOSED, self:CreateAction(self.AfterLoadingPanelClosed))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_CLOSE, self:CreateAction(self.OnPanelClose))
end

function M:OnBeforeSwitchScene(eventId, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:InitData()
end

function M:AfterLoadingPanelClosed()
	self:RunQueue(true)
end

function M:OnPanelClose(eventId, _)
	self:RunQueue(false)
end

function M:OnSyncNpcTimeTableInfos(timeTableInfos)
	self:Log("OnSyncNpcTimeTableInfos", timeTableInfos)

	self.NpcTimeTableInfos = timeTableInfos or {}

	for k, v in pairs(self.NpcTimeTableInfos) do
		self.NpcTimeTableLists[k] = {
			v.Schedule0,
			v.Schedule1,
			v.Schedule2,
			v.Schedule3,
			v.Schedule4
		}

		if self.NpcTimeTableLists[k][1].EndDaySecond < self.NpcTimeTableLists[k][1].StartDaySecond then
			self.NpcTimeTableLists[k][1].StartDaySecond = self.NpcTimeTableLists[k][1].StartDaySecond - gClientConst.SECONDS_PER_DAY
		end

		if self.NpcTimeTableLists[k][5].EndDaySecond < self.NpcTimeTableLists[k][5].StartDaySecond then
			self.NpcTimeTableLists[k][5].EndDaySecond = self.NpcTimeTableLists[k][5].EndDaySecond + gClientConst.SECONDS_PER_DAY
		end
	end
end

function M:OnSyncFavorNpcSpoonAgentId(agentTag, spoonAgentId, Position, isAtTemporaryPosition)
	self:Log("OnSyncFavorNpcSpoonAgentId", agentTag, spoonAgentId, isAtTemporaryPosition)

	if table.isNilOrEmpty(self.NpcTimeTableInfos[agentTag]) then
		return
	end

	self.NpcTimeTableInfos[agentTag].CurrentSpoonAgentId = spoonAgentId
	self.NpcTimeTableInfos[agentTag].SpoonPosition = Position
	self.NpcTempLeave[agentTag] = isAtTemporaryPosition
end

function M:GetAllHaveSpiritIds()
	local ret = {}

	gSpiritManager:Foreach(function (spirit)
		if spirit.config then
			local npcId = spirit.config.NpcCultivationRelatedId
			ret[npcId] = true
		end
	end)

	return ret
end

function M:GetAgentTagByNpcId(npcId)
	local cfg = NpcCultivationConfig.GetConfig(npcId)

	if not cfg then
		return 0
	end

	return cfg.AgentTag
end

function M:CheckScheduleOnGoing(scheduleInfo)
	if type(scheduleInfo) ~= "table" or not scheduleInfo.StartDaySecond then
		return false
	end

	local cTime = AtmosphereManager.Instance:GetGameTime()

	return scheduleInfo.StartDaySecond < cTime and cTime <= scheduleInfo.EndDaySecond
end

local _wrapReturnVector3 = Vector3.zero

function M:GetNpcPosition(npcTag)
	local currentSchedule = self:GetCurrentSchedule(npcTag)

	if not currentSchedule then
		_wrapReturnVector3.x = 0
		_wrapReturnVector3.y = 0
		_wrapReturnVector3.z = 0
	else
		local uxVector = currentSchedule.Position
		_wrapReturnVector3.x = uxVector.X
		_wrapReturnVector3.y = uxVector.Y
		_wrapReturnVector3.z = uxVector.Z
	end

	return _wrapReturnVector3
end

function M:GetNpcScheuduleLength(tag, index)
	local sIndex = self.todayNpcTimeTableInfos[tag][index]
	local scheduleInfo = self.NpcTimeTableLists[tag][sIndex]

	if table.isNilOrEmpty(scheduleInfo) then
		return SocialMediaConfig.ScheduleHeightRange[1]
	end

	local totalLength = scheduleInfo.EndDaySecond - scheduleInfo.StartDaySecond

	if totalLength <= 0 then
		return SocialMediaConfig.ScheduleHeightRange[1]
	end

	local targetHeight = totalLength / gClientConst.SECONDS_PER_HOUR * SocialMediaConfig.ScheduleHeight

	return math.max(math.min(targetHeight, SocialMediaConfig.ScheduleHeightRange[2]), SocialMediaConfig.ScheduleHeightRange[1])
end

function M:GetCurrentSchedule(npcTag)
	local timeTableInfo = self.NpcTimeTableLists[npcTag]

	if table.isNilOrEmpty(timeTableInfo) then
		return nil
	end

	for k, v in ipairs(timeTableInfo) do
		if self:CheckScheduleOnGoing(v) then
			return v
		end
	end

	return nil
end

function M:CheckNpcInBusy(npcId)
	local tag = self.favorMgr.agentType2NpcId[npcId] and npcId or self:GetAgentTagByNpcId(npcId)
	local timeTable = self.NpcTimeTableInfos[tag]
	local currentSchedule = self:GetCurrentSchedule(tag)

	if not currentSchedule then
		return true
	end

	if self.NpcTempLeave[tag] then
		return true
	end

	return timeTable.CurrentSpoonAgentId ~= 0 and currentSchedule.SpoonAgentId ~= timeTable.CurrentSpoonAgentId
end

function M:CheckNpcInBusyByTag(tag)
	local timeTable = self.NpcTimeTableInfos[tag]
	local currentSchedule = self:GetCurrentSchedule(tag)

	if not currentSchedule then
		return true
	end

	if self.NpcTempLeave[tag] then
		return true
	end

	return timeTable.CurrentSpoonAgentId ~= 0 and currentSchedule.SpoonAgentId ~= timeTable.CurrentSpoonAgentId
end

function M:GetTimeStr(time)
	return time / 3600 .. ":" .. time % 3600 / 60
end

function M:OnQueueInit()
	self.npcQueue = {}
	self.Id2NpcId = {}
	self.totalTodayCount = 0

	if self.triggerTimer then
		self.triggerTimer:Stop()

		self.triggerTimer = nil
	end

	self:OnTriggerInit()
end

function M:OnTriggerInit()
	self.npcTriggerCount = {}
	self.lastTriggerTime = 0
end

function M:OnQueueListSync(eveneQueueList)
	for k, v in pairs(eveneQueueList.IdToNpcDict) do
		self:OnNewQueueEvent(v)
	end

	for k, v in pairs(eveneQueueList.NpcQueues) do
		self.npcTriggerCount[k] = v.TodayTriggeredCount
	end

	self.totalTodayCount = eveneQueueList.TodayTriggeredCount
	self.lastTriggerTime = eveneQueueList.LastTriggerTime
end

function M:CheckNpcQueue()
	if table.isNilOrEmpty(self.npcQueue) then
		return false
	end

	for k, v in pairs(self.npcQueue) do
		if not table.isNilOrEmpty(v) then
			return true
		end
	end

	return false
end

function M:OnNewQueueEvent(eventInfo)
	local agentType = self:GetAgentTagByNpcId(eventInfo.NpcId)
	local queueList = self.npcQueue[agentType] or {}

	table.insert(queueList, eventInfo.Id)

	self.Id2NpcId[eventInfo.Id] = agentType
	self.npcQueue[agentType] = queueList

	self:Log("OnNewQueueEvent", "agentType=", agentType, "eventId=", eventInfo.Id)
end

function M:OnQueueEventRemove(eventId)
	local npcId = self.Id2NpcId[eventId] or 0

	if npcId == 0 then
		return
	end

	local queueList = self.npcQueue[npcId] or {}

	for i = 1, #queueList do
		if queueList[i] == eventId then
			table.remove(queueList, i)

			break
		end
	end

	self:Log("OnQueueEventRemove", "npcId=", npcId, "eventId=", eventId)
end

function M:CheckEventInQueue(npcTag, eventId)
	local queueList = self.npcQueue[npcTag] or {}

	for i = 1, #queueList do
		if queueList[i] == eventId then
			return true
		end
	end

	return false
end

function M:OnQueueEventTriggerChange(totalTodayCount, lastTriggerTime, npcId, npcTodayCount)
	local agentType = self:GetAgentTagByNpcId(npcId)
	self.totalTodayCount = totalTodayCount
	self.lastTriggerTime = lastTriggerTime
	self.npcTriggerCount[agentType] = npcTodayCount
end

function M:OnQueueEvenetReset()
	self:OnTriggerInit()
end

function M:RunFavorBehavior(behaviorId, isLogin, isForce)
	self:Log("Begin RunFavorBehavior behaviorId:", behaviorId, "EventId:", behaviorId, isLogin, isForce)

	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(behaviorId)

	if not cfg then
		self:Log("RunFavorBehavior fail with no cfg behaviorId:", behaviorId, "EventId:", behaviorId)

		return false
	end

	local eventId = self:GetEventId(cfg)

	if cfg.Trigger == NpcCultivationNpcFavorLevelConfig.TriggerType.Login and not isLogin and not isForce then
		self:Log("RunFavorBehavior fail with Trigger behaviorId:", behaviorId, "EventId:", eventId)

		return false
	end

	local isUnlock = self:CheckProgressUnlock(behaviorId)
	local traceable = eventId ~= 0

	if not isUnlock or not traceable then
		self:Log("RunFavorBehavior fail behaviorId:", behaviorId, "EventId:", eventId, "isUnlock", isUnlock, "traceable", traceable)

		return false
	end

	self:Log("RunFavorBehavior success behaviorId:", behaviorId, "EventId:", eventId, isLogin, isForce)

	if self:CheckEventInQueue(cfg.AgentTagId, eventId) then
		gClientToGameDelegate:AskTriggerNpcQueuedEvent(eventId, isForce).Callback = function (errorId)
			if errorId ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end

			gMainPhoneUtils:CloseMainPhonePanel()
		end

		return true
	elseif isForce then
		gMainPhoneUtils:CloseMainPhonePanel()

		if cfg.PhoneId ~= 0 then
			gMessageManager:SendMessage(gEventConstants.ON_PHONE_CALL_IN, eventId)

			return true
		end

		if cfg.NpcChatId ~= 0 then
			gNpcChatUtils.OpenChatPanel({
				rollToCfg = true,
				chatCfgId = eventId
			})

			return true
		end
	end

	return false
end

function M:RunQueue(isLogin)
	local preFrame = self.preFrame
	self.preFrame = Time.frameCount

	if preFrame == Time.frameCount or not self:CheckCanTrigger(isLogin) then
		return
	end

	self.triggerTimer = Timer.New(function ()
		self.triggerTimer = nil

		self:_RunQueue(isLogin)
	end, NpcCultivationConfig.TriggerDelayTime):Start()
end

function M:_RunQueue(isLogin)
	if not self:CheckCanTrigger(isLogin) then
		return
	end

	for k, v in pairs(self.npcQueue) do
		local currentCount = self.npcTriggerCount[k] or 0

		if currentCount < NpcCultivationConfig.TriggerNpcDailyLimit and not table.isNilOrEmpty(v) then
			for i = 1, #v do
				local behaviorId = self.eventId2Behavior[v[i]] or 0

				if self:RunFavorBehavior(behaviorId, isLogin, false) then
					return
				end
			end
		end
	end
end

function M:CheckCanTrigger(isLogin)
	if not self:CheckNpcQueue() then
		return
	end

	if self.triggerTimer then
		self:Log("CheckCanTrigger fail with triggerTimer")

		return false
	end

	if not gLuaDataManager.isNetworkAvailable then
		self:Log("CheckCanTrigger fail with no network")

		return false
	end

	if gBattleSpiritMgr.currentSpiritTemplateId ~= FightSpiritConfig.DefaultFemale and gBattleSpiritMgr.currentSpiritTemplateId ~= FightSpiritConfig.DefaultMale then
		self:Log("CheckCanTrigger fail with not default spirit")

		return false
	end

	if not isLogin and not gPanelManager:VisibleModeAll() then
		self:Log("CheckCanTrigger fail with not login")

		return false
	end

	if gCS.TimeManager.ServerUnixTime < self.lastTriggerTime + NpcCultivationConfig.TriggerCdTime then
		self:Log("CheckCanTrigger fail with cd time")

		return false
	end

	if NpcCultivationConfig.TriggerTotalDailyLimit <= self.totalTodayCount then
		self:Log("CheckCanTrigger fail with total count")

		return false
	end

	self:Log("CheckCanTrigger success")

	return true
end

function M:GetTodayScheduleList(agentType)
	local scheduleList = self.NpcTimeTableLists[agentType] or {}
	local ret = {}

	for i = 1, #scheduleList do
		local scheduleInfo = scheduleList[i]

		if scheduleInfo.ActivityId ~= 0 then
			ret[#ret + 1] = i
		end

		if self:CheckScheduleOnGoing(scheduleInfo) then
			break
		end
	end

	self.todayNpcTimeTableInfos[agentType] = ret

	return self.todayNpcTimeTableInfos[agentType]
end

function M:GetEventId(cfg)
	return cfg.PhoneId == 0 and cfg.NpcChatId or cfg.PhoneId
end

function M:GetAgentProgress(agentType)
	local ret = {}

	if table.isNilOrEmpty(self.agentType2Progress[agentType]) then
		return ret
	end

	for i = 1, #self.agentType2Progress[agentType] do
		local id = self.agentType2Progress[agentType][i]
		ret[i] = self:GetNpcProgressTemplate(id)
	end

	return ret
end

function M:GetNpcProgressTemplate(id)
	if not table.isNilOrEmpty(self.progress2Template[id]) then
		return self.progress2Template[id]
	end

	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(id)
	local ele = {
		tIndex = self.PROCESS_TEMPLATE.NONE,
		progressId = id
	}
	self.progress2Template[id] = ele

	if #cfg.Icons >= 2 then
		ele.tIndex = self.PROCESS_TEMPLATE.TASK
		ele.topIcon = cfg.Icons[1]
		ele.bottomIcon = cfg.Icons[2]

		return ele
	end

	local rewardList = gCommonItemManager:GetItemSortedListByDropList(cfg.Drops, true)
	ele.rewardList = rewardList

	for i = 1, #rewardList do
		local itemType = gCommonItemManager:GetItemDisplayType(rewardList[i].Id)

		if itemType == gCommonItemManager.ITEM_TYPE.FASHION_SUIT then
			ele.tIndex = self.PROCESS_TEMPLATE.SUIT

			return ele
		elseif itemType == gCommonItemManager.ITEM_TYPE.FASHION then
			ele.tIndex = self.PROCESS_TEMPLATE.FASHION

			return ele
		elseif itemType == gCommonItemManager.ITEM_TYPE.PHONE_THEME then
			local cfg = ConsumableConfig.GetConfig(rewardList[i].Id)
			ele.tIndex = self.PROCESS_TEMPLATE.PHONE
			ele.bottomIcon = cfg.SItemIconId
		end

		if ele.tIndex ~= self.PROCESS_TEMPLATE.NONE then
			return ele
		end
	end

	if not table.isNilOrEmpty(rewardList) then
		ele.tIndex = self.PROCESS_TEMPLATE.ITEM

		return ele
	end

	if cfg.HyperLink ~= 0 then
		ele.tIndex = self.PROCESS_TEMPLATE.HYPER
		ele.topIcon = table.isNilOrEmpty(cfg.Icons) and 0 or cfg.Icons[1]

		return ele
	end

	return ele
end

function M:RenderAgentProgress(btn, index, progress)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local progressId = progress.progressId
	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(progressId)
	local activeTime = self.favorMgr:GetAgentActiveTime(cfg.AgentTagId)
	local isUnlock = self:CheckProgressUnlock(progressId)
	local traceable = self:GetEventId(cfg) ~= 0 or cfg.HyperLink ~= 0
	store.traceable = BOOL2CTL[traceable]
	store.isUnLock = BOOL2CTL[isUnlock]
	store.nameLabel = cfg.Name

	if isUnlock then
		local baseInfo = string.is_null_or_empty(cfg.Info) and "" or cfg.Info
		store.descLabel = gString.Format(baseInfo, gTimeUtils:TransFormatTimeWithSec(activeTime))
	else
		store.descLabel = cfg.UnlockDesc or ""

		self.favorMgr:OnRenderFavorTemplateByFavor(store.unlockFavorWid, cfg.UnlockFavor)
	end

	store.index = gString.Format("%02d", index + 1)

	if not table.isNilOrEmpty(progress.rewardList) and store.rewardList then
		store.rewardList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderRewardItem, progressId)

		store.rewardList:SetSimpleList(#progress.rewardList)
	end

	store.bottomIcon = progress.bottomIcon
	store.upIcon = progress.topIcon
	store.traceType = self:GetProgressTraceType(progressId)
end

function M:OnRenderRewardItem(progress, btn, index)
	local template = self:GetNpcProgressTemplate(progress)

	if template.tIndex == self.PROCESS_TEMPLATE.ITEM or template.tIndex == self.PROCESS_TEMPLATE.PHONE then
		local itemData = gCommonItemManager:GetItemRenderData({
			itemId = template.rewardList[index + 1].Id,
			itemNum = template.rewardList[index + 1].Count
		})

		gCommonItemManager:OnCommonItemRender(btn, index, itemData)
	else
		gCommonItemManager:OnRenderCommonFashion(btn, index, template.rewardList[index + 1].Id)
	end
end

function M:CheckProgressUnlock(progressId)
	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(progressId)
	local agentId = cfg.AgentTagId
	local favorInfo = self.favorMgr:GetSpiritFavorInfo(agentId)
	local activeTime = self.favorMgr:GetAgentActiveTime(cfg.AgentTagId)

	return cfg.UnlockFavor <= favorInfo.favor and activeTime > 0
end

function M:RequeseHyperLink(progressId)
	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(progressId)

	if not cfg then
		return
	end

	local hyper, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLink, progressId)

	if hyper and hyper.callback then
		hyper.callback()
	end
end

local TRACE_TYPE = {
	Hyper = 2,
	TraceAble = 1,
	None = 0
}

function M:GetProgressTraceType(progressId)
	local cfg = NpcCultivationNpcFavorLevelConfig.GetConfig(progressId)

	if not cfg then
		return TRACE_TYPE.None
	end

	local hyper, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLink, progressId)
	local traceType = hyper and TRACE_TYPE.Hyper or TRACE_TYPE.None
	local eventId = self:GetEventId(cfg)
	local isUnlock = self:CheckProgressUnlock(progressId)
	local traceable = eventId ~= 0

	if not isUnlock or not traceable then
		return traceType
	end

	if cfg.PhoneId ~= 0 or cfg.NpcChatId ~= 0 then
		return TRACE_TYPE.TraceAble
	end

	return traceType
end

local ACTIVITY_TYPE = {
	TOP = 0,
	MID = 1,
	BOTTOM = 2,
	ALONE = 3
}

function M:OnRenderActivity(tag, btn, index)
	local store = gStoreManager:GetStoreGroup("NpcScheduleTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local sIndex = self.todayNpcTimeTableInfos[tag][index + 1]
	local scheduleInfo = self.NpcTimeTableLists[tag][sIndex]

	self:OnRenderActivtyBySchedule(btn, scheduleInfo)

	local cfg = ActivityConfig.GetConfig(scheduleInfo.ActivityId)
	local startTime = index ~= 0 and scheduleInfo.StartDaySecond or 0
	local endTime = scheduleInfo.EndDaySecond
	store.endTimeLabel = self:FormatTime(endTime % gClientConst.SECONDS_PER_DAY)
	store.startTimeLabel = self:FormatTime(startTime)
	store.qIcon = self.favorMgr:GetNpcQImage(tag)

	store:Commit("canLocate", BOOL2CTL[cfg.Raid ~= 0], COMMIT_FORCE)

	if index == 0 then
		store.nodeType = ACTIVITY_TYPE.TOP
	elseif index == #self.todayNpcTimeTableInfos[tag] - 1 then
		store.nodeType = ACTIVITY_TYPE.BOTTOM
	else
		store.nodeType = ACTIVITY_TYPE.MID
	end

	if #self.todayNpcTimeTableInfos[tag] == 1 then
		store.nodeType = ACTIVITY_TYPE.ALONE
	end

	return store
end

function M:OnRenderActivtyBySchedule(btn, scheduleInfo)
	if table.isNilOrEmpty(scheduleInfo) then
		return
	end

	local store = gStoreManager:GetStoreGroup("NpcScheduleTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = ActivityConfig.GetConfig(scheduleInfo.ActivityId)

	if not cfg then
		print_warn("[C_NpcDaliyManager] 错误的ActivityId", scheduleInfo.ActivityId)

		store.descLabel = ""
		store.startTimeLabel = ""
		store.endTimeLabel = ""
		store.goingOn = BOOL2CTL[false]
		store.iconId = 0

		return
	end

	store.iconId = cfg.Icon
	store.colorCode = cfg.ActivityColor
	store.goingOn = BOOL2CTL[self:CheckScheduleOnGoing(scheduleInfo)]
	store.descLabel = cfg.Info
end

function M:RenderActivityList(uList, npcId)
	local tag = self:GetAgentTagByNpcId(npcId)
	local timeTable = self:GetTodayScheduleList(tag)
	uList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderActivity, tag)

	uList:SetSimpleList(#timeTable)
end

function M:Format02d(time)
	return time > 9 and time or "0" .. time
end

function M:FormatTime(mTime)
	if mTime > 0 then
		local mins = math.floor(mTime / 60)
		local min = math.floor(mins % 60)
		local hour = math.floor(mins / 60)

		return self:Format02d(hour) .. ":" .. self:Format02d(min)
	end

	return "00:00"
end

gNpcDaliyManager = gNpcDaliyManager or C_NpcDaliyManager.new()
