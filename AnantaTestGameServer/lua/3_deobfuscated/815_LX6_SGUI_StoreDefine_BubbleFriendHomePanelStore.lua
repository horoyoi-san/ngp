local SocialMediaConfig = LTConfig.SocialMediaConfig
C_BubbleFriendHomePanelStore = DefClass("C_BubbleFriendHomePanelStore", C_BubbleFriendHomePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.BubbleFriendHomePanelStore = C_BubbleFriendHomePanelStore
local M = C_BubbleFriendHomePanelStore
local HOME_STATE = {
	EMPTY = 2,
	NORMAL = 0,
	BUSY = 1
}
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor(name, id, isSub)
	self.agentType = 0
end

function M:OnAwake()
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
	self.bindData.nextBtn.luaClick = self:CreateActionWithArgs(self.OnStep, 1)
	self.favorInfo = {}
	self.currentStore = {}
	self.refreshNav = 0
end

function M:InitView(data)
	self.agentType = data and data.agentType or 0
	self.bindData.tabIndex = data and data.tabIndex or 0
	self.bindData.startTime.unixTimestamp = self.favorMgr:GetAgentActiveTime(self.agentType)

	self:BuildTab()
end

function M:OnBackBtnClick()
	self.mgr:ExitCurrentPanel()
end

function M:OnRenderToolTipTagList(btn, index)
	local data = self.tagList[index + 1]

	self.favorMgr:OnRenderToolTipTagList(btn, index, data)
end

function M:OnClickFavorItem(btn, index)
	self.bindData.showFavorTip = self.bindData.showFavorTip == 1 and 0 or 1
end

function M:OnPreRendScheduleItem(btn, index)
	local length = self.daliyMgr:GetNpcScheuduleLength(self.agentType, index + 1)

	btn:SetSizeY(length)
end

function M:OnRenderScheduleItem(btn, index)
	self:OnPreRendScheduleItem(btn, index)

	self.currentStore[index] = self.daliyMgr:OnRenderActivity(self.agentType, btn, index)
end

function M:OnClickScheduleItem(btn, index)
	local scheduleInfo = self.daliyMgr.NpcTimeTableLists[self.agentType][self.contentList[index + 1]]

	if self.daliyMgr:CheckScheduleOnGoing(scheduleInfo) and not gMapGpsCmd:TryOpenBigMapAndFocusSelectFavorNpc(scheduleInfo.ActivityId) then
		local name = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(self.agentType).Name
		local message = string.format(LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.SleepTime).Content, name)

		gDisplayMessageMgr:ShowMessageContent(message)
	end
end

function M:OnSetListLayout(uList)
	if not table.isNilOrEmpty(self.currentStore) then
		for i = 0, #self.currentStore do
			local store = self.currentStore[i]

			if store then
				store:Commit("canLocate", store.canLocate, COMMIT_FORCE)
			end
		end
	end

	if self.refreshNav <= 0 then
		return
	end

	if uList:SetNavSelectToTop(true) then
		self.refreshNav = self.refreshNav - 1
	end
end

function M:OnGetProcessIndex(index)
	local progress = self.contentList[index + 1]

	return progress.tIndex
end

function M:OnRenderProcessItem(btn, index)
	local progress = self.contentList[index + 1]

	self.daliyMgr:RenderAgentProgress(btn, index, progress)
end

function M:OnClickProcessItem(btn, index)
	local progress = self.contentList[index + 1]

	if not self.daliyMgr:CheckProgressUnlock(progress.progressId) then
		return
	end

	if not self.daliyMgr:RunFavorBehavior(progress.progressId, false, true) then
		self.daliyMgr:RequeseHyperLink(progress.progressId)
	end
end

function M:OnRenderPhotoItem(btn, index)
	local data = self.contentList[index + 1]
	local info = self.mgr.postDict[data]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local image = cfg and cfg.Image or {}
	store.url = table.isNilOrEmpty(image) and info.ImageUrl or image[1]
end

function M:OnShareItemClick(btn, index)
	local data = self.contentList[index + 1]

	self.mgr:OpenDetailPanel(data)
end

function M:OnStep(step)
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = self.bindData.tabList.itemData.Count

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

function M:BuildTab()
	self.bindData.tabList:InitSimpleList()

	for i = 1, #SocialMediaConfig.FriendHomeTabNames do
		local tabName = SocialMediaConfig.FriendHomeTabNames[i]

		self.bindData.tabList:AddSimpleLabel(0, tabName)
	end

	self.bindData.tabList:RefreshList()
	self.bindData.tabList:SelectItem(self.bindData.tabIndex)
end

function M:RefreshPage()
	local info = self.mgr:GetBubbleNpcInfo(self.agentType)
	self.bindData.headIcon = info.icon
	self.bindData.nameLabel = self.favorMgr:GetAgentName(self.agentType)
	self.bindData.birthLabel = self.favorMgr:GetAgentBirth(self.agentType)
	local getTime = self.favorMgr:GetAgentGetDays(self.agentType)

	if getTime > 0 then
		self.bindData.getDayLabel = LTConfig.TextScriptTextConfig.GetConfig(89901006).Text .. gTimeUtils:GetDayStr(getTime)
	else
		self.bindData.getDayLabel = SocialMediaConfig.NotBestieTip
	end

	self:RefreshFavorInfo()

	self.tagList = self.favorMgr:GetNpcGiftTagInfo(self.agentType)

	self.bindData.tagList:SetSimpleList(#self.tagList)

	self.bindData.showGiftTag = BOOL2CTL[#self.tagList > 0]

	self:RefreshContent()
end

function M:RefreshContent()
	self.contentList = {}
	self.currentStore = {}
	local index = self.bindData.tabIndex

	if index == gClientConst.FriendHomeShowType.SCHEDULE then
		self.bindData.homeState = self.daliyMgr:CheckNpcInBusy(self.agentType) and HOME_STATE.BUSY or HOME_STATE.NORMAL
		self.contentList = self.daliyMgr:GetTodayScheduleList(self.agentType)

		self.bindData.scheduleList:SetSimpleList(#self.contentList)

		for i = 1, #self.contentList do
			if self.daliyMgr:CheckScheduleOnGoing(self.daliyMgr.NpcTimeTableLists[self.agentType][self.contentList[i]]) then
				self.bindData.scheduleList:GoToIndex(i - 1, true)

				break
			end
		end
	elseif index == gClientConst.FriendHomeShowType.PROCESS then
		self.bindData.homeState = HOME_STATE.NORMAL
		self.contentList = self.daliyMgr:GetAgentProgress(self.agentType)

		self.bindData.processList:SetSimpleList(#self.contentList)
	elseif index == gClientConst.FriendHomeShowType.SHARE then
		self.bindData.homeState = HOME_STATE.NORMAL
		self.contentList = self.mgr:GetAllShareList(self.agentType)

		self.bindData.photoList:SetSimpleList(#self.contentList)
	end

	self.refreshNav = 2

	if table.isNilOrEmpty(self.contentList) then
		self.bindData.homeState = self.bindData.homeState == HOME_STATE.BUSY and self.bindData.homeState or HOME_STATE.EMPTY
	end
end

function M:RefreshFavorInfo()
	self.favorInfo = self.favorMgr:GetSpiritFavorInfo(self.agentType)
	self.bindData.favorLevelLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901059).Text, self.favorInfo.favorLevel, self.favorMgr:GetMaxFavoriteLevel())

	self.favorMgr:OnRenderFavorTemplate(self.bindData.favorWidget, self.agentType)

	local minFavor = self.favorInfo.minFavor
	local maxFavor = self.favorInfo.maxFavor
	self.bindData.favorDetail = self.favorInfo.favor - minFavor .. "/" .. maxFavor - minFavor
end

function M:OnChangeTab(uList)
	local index = uList.selectedIndex
	self.bindData.tabIndex = index

	self:RefreshContent()
end
