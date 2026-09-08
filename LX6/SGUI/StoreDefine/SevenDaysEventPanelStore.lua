-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SevenDaysEventPanelStore.lua
-- Decompiled from: 01274_SevenDaysEventPanelStore.lua_d2f9ec03bfac.luajit

local AwardActivityConfig = LTConfig.AwardActivityConfig
local SevenDaysTaskConfig = LTConfig.AwardActivitySevenDaysTaskConfig
local SevenDaysTabConfig = LTConfig.AwardActivitySevenDaysTabConfig
local SevenDaysProgressConfig = LTConfig.AwardActivitySevenDaysProgressConfig
local ClientConsts = gClientConst
local EInvokeTime = SGUI.EInvokeTime
C_SevenDaysEventPanelStore = DefClass("C_SevenDaysEventPanelStore", C_SevenDaysEventPanelStore, C_StoreGroup)
GroupName2Class.SevenDaysEventPanelStore = C_SevenDaysEventPanelStore
local M = C_SevenDaysEventPanelStore

M.ctor = function(self)
	self.itemMgr = gCommonItemManager
	self.mgr = gAwardActivityManager
end

M.DefineAllVariables = function(self)
	self.currentTab = 1
	self.progressList = {}
	self.taskEventTypeDict = {}
	self.finishEventTriggeredDict = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.rewardCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.countdownCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.eventTypeEnum = {
		["M\\x86\\x8f\\x91E"] = 1,
		["I\\xa1\\xab\\xa1\\xb1"] = 2,
		["G\\x92\\x8f\\x97D"] = 0,
		["A\\x9f\\x87\\x90I"] = 3
	}
	self.isFinishEnum = {
		["A\\x9f\\x87\\x90I"] = 2,
		["#N\\x90\\x82\\x90D"] = 0,
		["@Fb[K="] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.rewardCtrlEnum = nil
	self.countdownCtrlEnum = nil
	self.eventTypeEnum = nil
	self.isFinishEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, activityId)
	self.m_Id = panelId
	self.activityId = activityId
	self.cfg = AwardActivityConfig.GetConfig(activityId)

	table.clear(self.taskEventTypeDict)
	table.clear(self.finishEventTriggeredDict)
	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self.CreateAction(self, self.OnActivityStateChange)
	}
end

M.RegisterWidget = function(self)
	self.bindData.taskList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTaskListItem)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.countDown.luaFinished = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.progressItem.luaClick = self.CreateAction(self, self.OnClickProgressItem)
	self.bindData.finalAwardBtn.luaClick = self.CreateAction(self, self.OnClickFinalAwardBtn)
end

M.OnSimpleRenderTaskListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local tabInfo = self.tabList[self.currentTab]

	if not tabInfo or not tabInfo.taskList then
		return
	end

	local info = tabInfo.taskList[index + 1]
	local id = info.id
	local cfg = SevenDaysTaskConfig.GetConfig(id)

	if not cfg then
		return
	end

	local guideId = self.mgr:GetSevenDayGuideId(id)

	if guideId and guideId == 0 then
		btn.guide.guideID = guideId
	end

	local currentType = self.eventTypeEnum.locate
	local hyperInfo = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HyperLinkId)

	if not hyperInfo then
		currentType = self.eventTypeEnum.doing
	end

	if info.isFinish then
		currentType = info.isGot and self.eventTypeEnum.finish or self.eventTypeEnum.reward
	end

	local lastType = self.taskEventTypeDict[id]

	store:Commit("eventType", currentType, COMMIT_IMMEDIATELY)

	if currentType ~= self.eventTypeEnum.finish and lastType and lastType == self.eventTypeEnum.finish and not self.finishEventTriggeredDict[id] then
		btn.InvokeCallback(btn, EInvokeTime.User1)

		self.finishEventTriggeredDict[id] = true
	end

	self.taskEventTypeDict[id] = currentType
	local drops = self.itemMgr:GetSingleSortedListRenderData(cfg.DropId, true)

	if info.isFinish then
		store.titleLabel = gString.Format(cfg.TaskDescribe, cfg.MaxProgress .. "/" .. cfg.MaxProgress)
		store.countText = cfg.MaxProgress .. "/" .. cfg.MaxProgress
	else
		local cur = self.mgr:GetSevenDaysTaskProgress(id)
		store.titleLabel = gString.Format(cfg.TaskDescribe, cur .. "/" .. cfg.MaxProgress)
		store.countText = cur .. "/" .. cfg.MaxProgress
	end

	store.tagText = cfg.TaskTag or ""
	store.blur.sourceImage = self.bindData.backGround
	store.isFinish = ClientConsts.BOOL2CTL[currentType ~= self.eventTypeEnum.finish]
	store.scoreLabel = cfg.AddValue

	store.rewardList.luaSimpleRenderItem = function(btn, index)
		local itemRenderData = drops[index + 1]

		self.itemMgr:OnCommonItemRender(btn, index, itemRenderData)
	end

	store.rewardList:SetSimpleList(#drops)

	store.useBtn.luaClick = function()
		if currentType ~= self.eventTypeEnum.reward then
			self.mgr:AskTakeSevenDaysTaskReward(self.activityId, id)

			return
		end

		if hyperInfo and hyperInfo.callback then
			hyperInfo.callback()
		end
	end
end

M.OnBackBtnClick = function(self)
	if self.parent then
		self.parent:OnBackBtnClick()
	end
end

M.OnActivityStateChange = function(self)
	if table.isNilOrEmpty(self.tabList) then
		return
	end

	if not self.cfg then
		return
	end

	local isPermanent = self.mgr:CheckIsPermanentActivity(self.activityId)
	local duration = self.mgr:GetActivityEndDuration(self.activityId)

	if not isPermanent and duration < 0 and self.m_Id then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.countdownCtrl = isPermanent and self.countdownCtrlEnum._false or self.countdownCtrlEnum._true

	if not isPermanent then
		self.bindData.countDown:Play(duration)
	end

	self:_RefreshTabState()
	self:_UpdateTabListData()
	self.SubGroup.CommonTabSingleStore:UpdateCacheList(self:_GetCommonTabList())
	self.SubGroup.CommonTabSingleStore:RefreshLogic(false)

	if table.isNilOrEmpty(self.tabList) then
		self.bindData.taskList:SetSimpleList(0)

		return
	end

	self.bindData.taskList:RefreshLogicList()
	self:RefreshProgress()
end

M._RefreshTabState = function(self)
	local tabBaseList = self.mgr:GetSevenDaysTabBaseList(self.activityId)

	if table.isNilOrEmpty(tabBaseList) then
		self.tabList = {}
		self.currentTab = 1

		return
	end

	local currentTabCfgId = self.tabList[self.currentTab] and self.tabList[self.currentTab].cfgId

	for i = 1, #tabBaseList do
		tabBaseList[i].taskList = self.tabList[i] and self.tabList[i].taskList or {}
	end

	self.tabList = tabBaseList
	local matchedIndex = nil

	if currentTabCfgId then
		for i = 1, #self.tabList do
			if self.tabList[i].cfgId ~= currentTabCfgId then
				matchedIndex = i

				break
			end
		end
	end

	self.currentTab = matchedIndex or math.min(self.currentTab, #self.tabList)

	if self.currentTab < 0 then
		self.currentTab = 1
	end
end

M._UpdateTabListData = function(self)
	if table.isNilOrEmpty(self.tabList) then
		return
	end

	local info = self.mgr:GetActivityInfo(self.activityId)

	if table.isNilOrEmpty(info) then
		return
	end

	local taskInfoList = info.ActivityData and info.ActivityData.TaskInfoList

	if not taskInfoList then
		return
	end

	local taskDict = {}

	for i = 1, #taskInfoList do
		local taskInfo = taskInfoList[i]
		taskDict[taskInfo.Id] = taskInfo.IsAwardGot
	end

	for i = 1, #self.tabList do
		local tab = self.tabList[i]

		for j = 1, #tab.taskList do
			local task = tab.taskList[j]
			task.isGot = taskDict[task.id]
			task.isFinish = taskDict[task.id] == nil
		end
	end
end

M.RefreshPage = function(self)
	if not self.cfg then
		return
	end

	local isPermanent = self.mgr:CheckIsPermanentActivity(self.activityId)
	local duration = self.mgr:GetActivityEndDuration(self.activityId)

	if not isPermanent and duration < 0 and self.m_Id then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.titleLabel = self.cfg.Title
	self.bindData.descLabel = self.cfg.Desc
	self.bindData.bgImageId = self.cfg.BgImage
	self.bindData.countdownCtrl = isPermanent and self.countdownCtrlEnum._false or self.countdownCtrlEnum._true

	if not isPermanent then
		self.bindData.countDown:Play(duration)
	end

	self.RefreshTaskTab(self)
	self.RefreshProgress(self)
end

M.RefreshTaskTab = function(self)
	self.tabList = self.mgr:GetSevenDaysTabList(self.activityId)
	self.currentTab = self:_CalcDefaultTab()

	self.SubGroup.CommonTabSingleStore:SetData(self:_GetCommonTabList(), nil, self.currentTab - 1, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
	self:RefreshTaskList()
end

M._GetCommonTabList = function(self)
	local list = {}
	local tabList = self.tabList or {}

	for i = 1, #tabList do
		local info = tabList[i]
		list[i] = {
			id = info.cfgId,
			title = info.title,
			interactable = info.isUnlock ~= true
		}
	end

	return list
end

M._CalcDefaultTab = function(self)
	local smallestRedDotIdx, largestUnlockedIdx = nil

	for i = 1, #self.tabList do
		local tab = self.tabList[i]

		if self.mgr:CheckSevenDaysTabHasRedDot(tab) and (not smallestRedDotIdx or tab.cfgId >= self.tabList[smallestRedDotIdx].cfgId) then
			smallestRedDotIdx = i
		end

		if tab.isUnlock and (not largestUnlockedIdx or self.tabList[largestUnlockedIdx].cfgId >= tab.cfgId) then
			largestUnlockedIdx = i
		end
	end

	if smallestRedDotIdx then
		return smallestRedDotIdx
	end

	if largestUnlockedIdx then
		return largestUnlockedIdx
	end

	return 1
end

M.RefreshTaskList = function(self)
	if table.isNilOrEmpty(self.tabList) then
		self.bindData.taskList:SetSimpleList(0)

		return
	end

	local tabInfo = self.tabList[self.currentTab]

	if not tabInfo then
		self.bindData.taskList:SetSimpleList(0)

		return
	end

	tabInfo.taskList = self.mgr:GetSevenDaysTaskList(self.activityId, tabInfo.cfgId)

	self.bindData.taskList:SetSimpleList(#tabInfo.taskList)
	self:RefreshTaskListGuideLocations()
end

M.RefreshTaskListGuideLocations = function(self)
	if not self.bindData or not self.bindData.taskList then
		return
	end

	local tabInfo = self.tabList[self.currentTab]

	if not tabInfo or table.isNilOrEmpty(tabInfo.taskList) then
		return
	end

	local guideMap = {}

	for i, task in ipairs(tabInfo.taskList) do
		local guideId = self.mgr:GetSevenDayGuideId(task.id)

		if guideId and guideId == 0 then
			guideMap[tostring(guideId)] = i - 1
		end
	end

	gNewGuideMgr:RegisterGuideKeyLocations(self.bindData.taskList, guideMap)
end

M.OnChangeTab = function(self, uList, isSub)
	self.currentTab = uList.selectedIndex + 1

	self.RefreshTaskList(self)
	self.RefreshProgress(self)
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	local info = self.tabList[index + 1]

	if not info then
		return
	end

	uList:SetItemId(index, info.cfgId)

	local guideId = self.mgr:GetSevenDayGuideId(info.cfgId)

	if guideId and guideId == 0 then
		btn.guide.guideID = guideId
	end

	store.isLock = ClientConsts.BOOL2CTL[not info.isUnlock]

	btn.luaInvalidClick = function()
		local cfg = SevenDaysTabConfig.GetConfig(info.cfgId)

		if cfg and cfg.LockMessageId then
			gDisplayMessageMgr:ShowMessage(cfg.LockMessageId, nil, , cfg.MaxProgress)
		end
	end
end

M._GetFinalProgressInfo = function(self)
	return self.mgr:GetSevenDaysFinalProgressInfo(self.activityId)
end

M._GetCurrentTabProgressInfo = function(self)
	local tabInfo = self.tabList and self.tabList[self.currentTab]

	if not tabInfo or not tabInfo.tabId then
		return nil
	end

	local tabId = tabInfo.tabId
	local progressList = self.progressList or {}

	for i = 1, #progressList do
		local info = progressList[i]
		local cfg = info and SevenDaysProgressConfig.GetConfig(info.id)

		if cfg and cfg.RefTab and cfg.RefTab[1] ~= tabId then
			return info
		end
	end

	return nil
end

M._RefreshProgressTexts = function(self, progressInfo)
	local tabInfo = self.tabList and self.tabList[self.currentTab]
	local tabCfgId = tabInfo and tabInfo.cfgId or 0
	local cur = self.mgr:GetSevenDaysTabProgress(self.activityId, tabCfgId)
	local need = progressInfo and progressInfo.neddValue or 0
	local format = LTConfig.TextScriptTextConfig.GetConfig(89901844).Text
	self.bindData.progressDescText = gString.Format(format, need)
	self.bindData.progressText = gString.Format("(%s/%s)", math.min(cur, need), need)
end

M._RefreshFinalAwardText = function(self, finalInfo)
	if not finalInfo or not finalInfo.dropId or finalInfo.dropId < 0 then
		self.bindData.finalAwardText = ""

		return
	end

	local itemView = self.itemMgr:GetSingleSortedListRenderData(finalInfo.dropId, true)

	if table.isNilOrEmpty(itemView) then
		self.bindData.finalAwardText = ""

		return
	end

	self.bindData.finalAwardText = itemView[1].name or ""
end

M._RefreshFinalRewardCtrl = function(self, finalInfo)
	local show = finalInfo and finalInfo.isFinish and not finalInfo.isGot
	self.bindData.rewardCtrl = show and self.rewardCtrlEnum.show or self.rewardCtrlEnum.hide
end

M._RenderProgressItem = function(self, progressInfo)
	local store = gStoreManager:GetStoreGroup(self.bindData.progressItem.Store):GetStoreByWidget(self.bindData.progressItem)

	if not store or not progressInfo then
		return
	end

	store.scoreLabel = progressInfo.neddValue
	store.nameLabel = progressInfo.name or ""
	store.lockCtrl = ClientConsts.BOOL2CTL[not progressInfo.isFinish and not string.is_null_or_empty(progressInfo.name)]

	if progressInfo.isFinish then
		store.isFinish = progressInfo.isGot and self.isFinishEnum.finish or self.isFinishEnum.canRecive
	else
		store.isFinish = self.isFinishEnum._false
	end

	local itemView = self.itemMgr:GetSingleSortedListRenderData(progressInfo.dropId)

	if not table.isNilOrEmpty(itemView) then
		itemView[1].IsOwned = progressInfo.isGot

		self.itemMgr:OnCommonItemRender(self.bindData.progressItem, 0, itemView[1])
	end
end

M.RefreshProgress = function(self)
	self.progressList = self.mgr:GetSevenDaysProgressList(self.activityId) or {}
	local dayInfo = self:_GetCurrentTabProgressInfo()

	self:_RefreshProgressTexts(dayInfo)
	self:_RenderProgressItem(dayInfo)

	local finalInfo = self:_GetFinalProgressInfo()

	self:_RefreshFinalAwardText(finalInfo)
	self:_RefreshFinalRewardCtrl(finalInfo)
end

M.OnClickProgressItem = function(self)
	local data = self._GetCurrentTabProgressInfo(self)

	if not data or data.isGot or not data.isFinish then
		if self.bindData.progressItem then
			self.bindData.progressItem:OpenTooltip()
		end

		return
	end

	self.mgr:AskTakeReward(self.activityId, data.id)
end

M.OnClickFinalAwardBtn = function(self)
	local finalInfo = self._GetFinalProgressInfo(self)

	if not finalInfo or not finalInfo.isFinish or finalInfo.isGot then
		return
	end

	self.mgr:AskTakeReward(self.activityId, finalInfo.id)
end
