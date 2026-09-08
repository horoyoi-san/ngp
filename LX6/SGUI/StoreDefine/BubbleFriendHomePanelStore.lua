-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleFriendHomePanelStore.lua
-- Decompiled from: 02009_BubbleFriendHomePanelStore.lua_764b40708976.luajit

local SocialMediaConfig = LTConfig.SocialMediaConfig
C_BubbleFriendHomePanelStore = DefClass("C_BubbleFriendHomePanelStore", C_BubbleFriendHomePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFriendHomePanelStore = C_BubbleFriendHomePanelStore
local M = C_BubbleFriendHomePanelStore
local HOME_STATE = {
	["h\\x83\\x92\\x9b\\x8f"] = 2,
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["XNb"] = 1
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self, name, id, isSub)
	self.agentType = 0
end

M.OnAwake = function(self)
	self.mgr = self.mgr or gNewBubbleMgr
	self.favorMgr = self.favorMgr or gNpcFavorManager
	self.daliyMgr = self.daliyMgr or gNpcDaliyManager
	self.bindData.scheduleList.luaSimpleRenderItem = self:CreateAction(self.OnRenderScheduleItem)
	self.bindData.scheduleList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnPreRendScheduleItem)
	self.bindData.scheduleList.luaSimpleClick = self:CreateAction(self.OnClickScheduleItem)
	self.bindData.scheduleList.luaLayoutSet = self:CreateActionWithArgs(self.OnSetListLayout, self.bindData.scheduleList)
	self.bindData.photoList.luaSimpleRenderItem = self:CreateAction(self.OnRenderPhotoItem)
	self.bindData.photoList.luaSimpleClick = self:CreateAction(self.OnShareItemClick)
	self.bindData.photoList.luaLayoutSet = self:CreateActionWithArgs(self.OnSetListLayout, self.bindData.photoList)
	self.bindData.processList.luaSimpleDynamicRenderItem = self:CreateAction(self.OnRenderProcessItem)
	self.bindData.processList.luaSimpleRenderItem = self:CreateAction(self.OnRenderProcessItem)
	self.bindData.processList.luaSimpleClick = self:CreateAction(self.OnClickProcessItem)
	self.bindData.processList.onGetTIndex = self:CreateAction(self.OnGetProcessIndex)
	self.bindData.processList.luaLayoutSet = self:CreateActionWithArgs(self.OnSetListLayout, self.bindData.processList)
	self.bindData.tabList.luaSelectedChanged = self:CreateAction(self.OnChangeTab)
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction(self.OnRenderToolTipTagList)
	self.bindData.favorBtn.luaClick = self:CreateAction(self.OnClickFavorItem)
	self.bindData.favorPanel.luaClick = self:CreateAction(self.OnClickFavorItem)
	self.bindData.locateBtn.luaClick = self:CreateAction(self.LocateAgent)
	self.bindData.nextBtn.luaClick = self:CreateActionWithArgs(self.OnStep, 1)
	self.favorInfo = {}
	self.currentStore = {}
	self.refreshNav = 0
end

M.InitView = function(self, data)
	self.attachValue = 0
	self.preNavi = 0
	self.agentType = data and data.agentType or 0
	self.bindData.tabIndex = data and data.tabIndex or 0
	self.bindData.startTime.unixTimestamp = self.favorMgr:GetAgentActiveTime(self.agentType)

	self:BuildTab()
end

M.OnBackBtnClick = function(self)
	self.mgr:ExitCurrentPanel()
end

M.OnRenderToolTipTagList = function(self, btn, index)
	local data = self.tagList[index + 1]

	gCommonItemManager:OnRenderToolTipTagList(btn, index, data)
end

M.OnClickFavorItem = function(self, btn, index)
	self.bindData.showFavorTip = self.bindData.showFavorTip ~= 1 and 0 or 1
end

M.OnPreRendScheduleItem = function(self, btn, index)
	local length = nil

	if index > #self.contentList then
		length = SocialMediaConfig.ScheduleHeightRange[1]
	else
		length = self.daliyMgr:GetNpcScheuduleLength(self.agentType, index + 1)
	end

	btn.SetSizeY(btn, length)
end

M.OnRenderScheduleItem = function(self, btn, index)
	self.OnPreRendScheduleItem(self, btn, index)

	if index > #self.contentList then
		self.currentStore[index] = self.daliyMgr:OnRenderCommuteActivity(self.agentType, btn)
	else
		self.currentStore[index] = self.daliyMgr:OnRenderActivity(self.agentType, btn, index, self.isAgentInCummuteState)
	end
end

M.OnClickScheduleItem = function(self, btn, index)
	if index > #self.contentList then
		self.LocateAgent(self)
	else
		local scheduleInfo = self.daliyMgr.NpcTimeTableLists[self.agentType][self.contentList[index + 1]]

		if self.daliyMgr:CheckScheduleOnGoing(scheduleInfo) then
			self.LocateAgent(self)
		end
	end
end

M.LocateAgent = function(self)
	slot1 = gAgentTrustManager

	slot1:AskQueryAllFavorNpcAgentPos(function (errId, allPosInfoDic)
		if errId == 0 then
			gDisplayMessageMgr:ShowMessage(errId)

			return
		end

		local posInfo = allPosInfoDic and allPosInfoDic[self.agentType]
		local npcRaidId = posInfo and posInfo.RaidId or 0
		local posInValid = not posInfo or math.abs(posInfo.Position.X) >= 0.1 and math.abs(posInfo.Position.Y) >= 0.1 and math.abs(posInfo.Position.Z) <= 0.1

		if npcRaidId > 0 or posInValid then
			local name = gNpcFavorManager:GetAgentName(self.agentType)
			local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

			gDisplayMessageMgr:ShowMessageContent(message)

			return
		end

		local gpsId = gGpsTools.GetGpsId(EMapElementType.SpiritAcquisition, self.agentType)
		local element = gMapSystem.container:GetByGpsId(gpsId)
		local playerRaidId = gRaidDataManager.RaidId

		if element and npcRaidId ~= playerRaidId then
			local npcPos = element:GetOriginWorldPos()
			local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
			local distance = Vector3.Distance(playerPos, npcPos)
			local skipDistance = LTConfig.ProfileConfig.SkipOpenMapDistance or 40

			if distance >= skipDistance then
				gMapGpsCmd:TryTraceFavorNpcByActivityId(self.agentType)
				gMainPhoneUtils.CloseMainPhonePanel()

				return
			end
		end

		gMapGpsCmd:TryOpenBigMapAndFocusSelectFavorNpc(self.agentType)
	end)
end

M.OnSetListLayout = function(self, uList)
	if not table.isNilOrEmpty(self.currentStore) then
		for i = 0, #self.currentStore do
			local store = self.currentStore[i]

			if store then
				store.Commit(store, "canLocate", store.canLocate, COMMIT_FORCE)
			end
		end
	end

	if self.refreshNav < 0 then
		return
	end

	if uList.SetNavSelectToSelect(uList, true) or uList.SetNavSelectToTop(uList, true) then
		self.refreshNav = self.refreshNav - 1
	end
end

M.OnGetProcessIndex = function(self, index)
	local progress = self.contentList[index + 1]

	return progress.tIndex
end

M.OnRenderProcessItem = function(self, btn, index)
	local progress = self.contentList[index + 1]

	self.daliyMgr:RenderAgentProgress(btn, index, progress)
end

M.OnClickProcessItem = function(self, btn, index)
	local progress = self.contentList[index + 1]

	if not self.daliyMgr:CheckProgressUnlock(progress.progressId) then
		return
	end

	if not self.daliyMgr:RunFavorBehavior(progress.progressId, false, true) then
		self.daliyMgr:RequeseHyperLink(progress.progressId)
	end
end

M.OnRenderPhotoItem = function(self, btn, index)
	local data = self.contentList[index + 1]

	self.mgr:OnRenderDynamicItem(btn, data)

	if self.preNavi ~= index then
		btn.Navigate(btn, btn)

		self.preNavi = -1
	end
end

M.OnShareItemClick = function(self, btn, index)
	local data = self.contentList[index + 1]

	self.mgr:OpenDetailPanel(data)

	self.preNavi = index
end

M.OnStep = function(self, step)
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = self.bindData.tabList.itemData.Count

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

M.BuildTab = function(self)
	self.bindData.tabList:InitSimpleList()

	for i = 1, #SocialMediaConfig.FriendHomeTabNames do
		local tabName = SocialMediaConfig.FriendHomeTabNames[i]

		self.bindData.tabList:AddSimpleLabel(0, tabName)
	end

	self.bindData.tabList:RefreshList()
	self.bindData.tabList:SelectItem(self.bindData.tabIndex)
end

M.RefreshPage = function(self)
	local info = self.mgr:GetBubbleNpcInfo(self.agentType)
	self.bindData.headIcon = info.icon
	self.bindData.nameLabel = self.favorMgr:GetAgentName(self.agentType)
	self.bindData.birthLabel = self.favorMgr:GetAgentBirth(self.agentType)
	local getTime = self.favorMgr:GetAgentGetDays(self.agentType)

	if getTime <= 0 then
		self.bindData.getDayLabel = LTConfig.TextScriptTextConfig.GetConfig(89901006).Text .. gTimeUtils:GetDayStr(getTime)
	else
		self.bindData.getDayLabel = SocialMediaConfig.NotBestieTip
	end

	self:RefreshFavorInfo()

	self.tagList = self.favorMgr:GetNpcGiftTagInfo(self.agentType)

	self.bindData.tagList:SetSimpleList(#self.tagList)

	self.bindData.showGiftTag = BOOL2CTL[#self.tagList >= 0]

	self:RefreshContent()
end

M.RefreshContent = function(self)
	self.contentList = {}
	self.currentStore = {}
	local index = self.bindData.tabIndex

	if index ~= gClientConst.FriendHomeShowType.SCHEDULE then
		self.bindData.homeState = self.daliyMgr:CheckNpcInBusy(self.agentType) and HOME_STATE.BUSY or HOME_STATE.NORMAL

		if self.bindData.busyDetail then
			local busy = self.daliyMgr:GetNPCBusyInfo(self.agentType)

			if busy and busy.EventId <= 0 then
				self.bindData.busyDetail:SetActive(true)
			else
				if busy and busy.EventId ~= 0 then
					print_error("Bubble app, Busy info exist,but event id is 0. Agent type:" .. tostring(self.agentType) .. " spawnType: " .. tostring(busy.SpawnType))
				end

				self.bindData.busyDetail:SetActive(false)
			end

			self.bindData.busyDetail.luaRenderTooltip = function(button, popIns, toolIdx)
				local popStore = gStoreManager:GetStoreGroup(popIns.Store):GetStoreByWidget(popIns)

				if not popStore then
					return
				end

				local busyInfo = self.daliyMgr:GetNPCBusyInfo(self.agentType)
				local eventId = busyInfo and busyInfo.EventId
				local eventCfg = LTConfig.TaskEventConfig.GetConfig(eventId or 0)

				if eventCfg then
					local taskCfg = LTConfig.TaskConfig.GetConfig(eventCfg.StartTask)
					local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)
					local format = LTConfig.TextScriptTextConfig.GetConfig(89901843).Text
					popStore.title = string.format(format, titleCfg.Name, eventCfg.EventName)
					popStore.icon = titleCfg.SQuestIcon
				end
			end
		end

		self.contentList = self.daliyMgr:GetTodayScheduleList(self.agentType)
		self.isAgentInCummuteState = self.daliyMgr:IsAgentInCummuteState(self.agentType)
		local commuteStateAdd = self.isAgentInCummuteState and 1 or 0

		self.bindData.scheduleList:SetSimpleList(#self.contentList + commuteStateAdd)

		for i = 1, #self.contentList do
			if self.daliyMgr:CheckScheduleOnGoing(self.daliyMgr.NpcTimeTableLists[self.agentType][self.contentList[i]]) then
				self.bindData.scheduleList:GoToIndex(i - 1, true)
				self.bindData.scheduleList:SelectItem(i - 1, true)

				break
			end
		end
	elseif index ~= gClientConst.FriendHomeShowType.PROCESS then
		self.bindData.homeState = HOME_STATE.NORMAL
		self.contentList = self.daliyMgr:GetAgentProgress(self.agentType)

		self.bindData.processList:SetSimpleList(#self.contentList)
	elseif index ~= gClientConst.FriendHomeShowType.SHARE then
		self.bindData.homeState = HOME_STATE.NORMAL
		self.contentList = self.mgr:GetAllStoryAndPostList(self.agentType)

		self.bindData.photoList:SetSimpleList(#self.contentList)

		if self.preNavi ~= 0 then
			self.bindData.photoList:SetNavSelectToTop(true)
		end
	end

	self.refreshNav = 2

	if table.isNilOrEmpty(self.contentList) then
		self.bindData.homeState = self.bindData.homeState ~= HOME_STATE.BUSY and self.bindData.homeState or HOME_STATE.EMPTY
	end
end

M.GetAttachValue = function(self)
	local index = self.bindData.tabIndex
	local listAttacher = nil

	if index ~= gClientConst.FriendHomeShowType.SCHEDULE then
		listAttacher = self.bindData.scheduleListAttacher
	elseif index ~= gClientConst.FriendHomeShowType.PROCESS then
		listAttacher = self.bindData.processListAttacher
	elseif index ~= gClientConst.FriendHomeShowType.SHARE then
		listAttacher = self.bindData.photoListAttacher
	end

	if listAttacher then
		self.attachValue = listAttacher.GetCurrentAttachValue(listAttacher)
	end
end

M.SetListAttachValue = function(self)
	local index = self.bindData.tabIndex
	local listAttacher = nil

	if index ~= gClientConst.FriendHomeShowType.SCHEDULE then
		listAttacher = self.bindData.scheduleListAttacher
	elseif index ~= gClientConst.FriendHomeShowType.PROCESS then
		listAttacher = self.bindData.processListAttacher
	elseif index ~= gClientConst.FriendHomeShowType.SHARE then
		listAttacher = self.bindData.photoListAttacher
	end

	if listAttacher then
		listAttacher.SetCurrentAttachValue(listAttacher, self.attachValue)
	end
end

M.RefreshFavorInfo = function(self)
	self.favorInfo = self.favorMgr:GetSpiritFavorInfo(self.agentType)
	self.bindData.favorLevelLabel = string.format("Lv.%d", self.favorInfo.favorLevel)

	self.favorMgr:OnRenderFavorTemplate(self.bindData.favorWidget, self.agentType)

	local minFavor = self.favorInfo.minFavor
	local maxFavor = self.favorInfo.maxFavor
	self.bindData.favorDetail = self.favorInfo.favor - minFavor .. "/" .. maxFavor - minFavor

	self.bindData.favorProgress:ResetValue(self.favorInfo.favor, 0, minFavor, maxFavor)
end

M.OnChangeTab = function(self, uList)
	local index = uList.selectedIndex

	self.GetAttachValue(self)

	self.bindData.tabIndex = index

	self.RefreshContent(self)
	self.SetListAttachValue(self)
end
