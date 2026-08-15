C_OnlinePlayEntrancePanelStore = DefClass("C_OnlinePlayEntrancePanelStore", C_OnlinePlayEntrancePanelStore, C_StoreGroup)
GroupName2Class.OnlinePlayEntrancePanelStore = C_OnlinePlayEntrancePanelStore
local M = C_OnlinePlayEntrancePanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

function M:ctor()
	self.mgr = gLinkManager
end

function M:OnAwake()
	self.bindData.matchBtn.luaClick = self:CreateAction("OnMatchBtnClick")
	self.bindData.hostBtn.luaClick = self:CreateAction("OnHostBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.searchCloseBtn.luaClick = self:CreateAction("OnSearchCloseBtnClick")
	self.bindData.sendInviteBtn.luaClick = self:CreateAction("OnSendInvite")
	self.bindData.startBtn.luaClick = self:CreateAction(self.OnStartBtnClick)
	self.msgEvents = {
		[gEventConstants.LINK_SEARCHING_REFRESH] = self:CreateAction(self.OnRefreshSearching),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self:CreateAction(self.OnRefreshSearchState),
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction(self.RefreshTeamState)
	}
end

function M:OnEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnDisable()
	self:ClearMessageEvents()
end

function M:OnSendInvite()
	if not self.mgr:CheckCanInviteAll() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.RoomInviteAllInCD)

		self.bindData.sendInviteBtn.isSelected = false

		return
	end

	self.mgr:OnChangeSendToOther()
end

function M:OnMatchBtnClick()
	self.mgr:AskMatchBegin(self.modeId, true, function ()
		self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime ~= 0]
	end)
end

function M:OnHostBtnClick()
	self:OnCloseBtnClick()
	self.mgr:AskNewRoom(self.mgr.sendToOther)
end

function M:OnSearchCloseBtnClick()
	self.bindData.inSearching = BOOL2CTL[false]

	self.mgr:AskMatchCancel(self:CreateAction("OnLeaveMatchList"))
end

function M:OnLeaveMatchList()
	self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime ~= 0]
end

function M:OnCloseBtnClick()
	if self.bindData.inSearching == BOOL2CTL[true] then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
	end

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
end

function M:OnRefreshSearchState()
	self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime ~= 0]

	if self.bindData.inSearching == BOOL2CTL[true] then
		self:OnRefreshSearching()
	end
end

function M:OnRefreshSearching()
	if self.bindData.inSearching == BOOL2CTL[false] then
		self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime ~= 0]
	end

	self.bindData.timeLabel = self.mgr.baseTime ~= 0 and gTimeUtils:FormatTime(Time.unscaledTime - self.mgr.baseTime) or ""
end

function M:OnShow(panelId, data)
	if not data or not data.modeId then
		self.modeId = self.mgr.targetPlayId
	else
		self.mgr.targetPlayId = data.modeId
		self.modeId = data.modeId
	end

	local canInviteAll = self.mgr:CheckCanInviteAll()
	self.bindData.sendInviteBtn.isSelected = canInviteAll and self.mgr.sendToOther
	local inLinkMode = self.mgr:CheckInLinkMode()
	self.bindData.isSingle = BOOL2CTL[not inLinkMode]
	self.bindData.canRoom = BOOL2CTL[inLinkMode]

	self:OnRefreshSearchState()
	self.mgr:OnRefreshLinkContent(self.bindData.content)
	self:RefreshTeamState()
end

function M:RefreshTeamState()
	local inQuickStart, isOutMember = self.mgr:CheckIsFullTeam()
	self.bindData.canQuickStart = BOOL2CTL[inQuickStart]
	self.bindData.isOutMember = BOOL2CTL[isOutMember]

	if not gTeamManager:IsInTeam() then
		self.bindData.startBtn.interactable = true
		self.bindData.hostBtn.interactable = true

		return
	end

	local isLeader = gTeamManager:IsTeamLeader()
	self.bindData.startBtn.interactable = isLeader
	self.bindData.hostBtn.interactable = isLeader
end

function M:OnStartBtnClick()
	self:OnCloseBtnClick()
	self.mgr:AskStartGameInTeam(self.modeId)
end

function M:OnClose()
	gMessageManager:SendMessage(gEventConstants.INTERACTION_ACTION_FINISH)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
