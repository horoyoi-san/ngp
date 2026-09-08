-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePlayEntrancePanelStore.lua
-- Decompiled from: 01123_OnlinePlayEntrancePanelStore.lua_09348ed55521.luajit

C_OnlinePlayEntrancePanelStore = DefClass("C_OnlinePlayEntrancePanelStore", C_OnlinePlayEntrancePanelStore, C_StoreGroup)
GroupName2Class.OnlinePlayEntrancePanelStore = C_OnlinePlayEntrancePanelStore
local M = C_OnlinePlayEntrancePanelStore
local SearchButtonIndex = 3
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.mgr = gLinkManager
end

M.OnAwake = function(self)
	self.bindData.matchBtn.luaClick = self.CreateAction(self, self.OnMatchBtnClick)
	self.bindData.hostBtn.luaClick = self.CreateAction(self, self.OnHostBtnClick)
	self.bindData.onCloseBtn = self.CreateAction(self, self.OnCloseBtnClick)
	self.bindData.searchCloseBtn.luaClick = self.CreateAction(self, self.OnSearchCloseBtnClick)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnStartBtnClick)
	self.msgEvents = {
		[gEventConstants.LINK_SEARCHING_REFRESH] = self.CreateAction(self, self.OnRefreshSearching),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self.CreateAction(self, self.OnRefreshSearchState),
		[gEventConstants.TEAM_REFRESH_DATA] = self.CreateAction(self, self.RefreshTeamState)
	}
	self.isFullEntrance = false
end

M.OnEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "openCommonHalf", false)
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnMatchBtnClick = function(self)
	local _, _, isFullMax = self.mgr:CheckIsFullTeam()

	if isFullMax then
		return
	end

	slot4 = self.mgr

	slot4:AskMatchBegin(nil, true, function ()
		self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime == 0]
	end)
end

M.OnHostBtnClick = function(self)
	self:OnCloseBtnClick()
	self.mgr:AskNewRoom(false)
end

M.OnSearchCloseBtnClick = function(self)
	self.bindData.inSearching = BOOL2CTL[false]

	self.mgr:AskMatchCancel(self:CreateAction("OnLeaveMatchList"))
end

M.OnLeaveMatchList = function(self)
	self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime == 0]
end

M.OnCloseBtnClick = function(self)
	if self.bindData.inSearching ~= BOOL2CTL[true] then
		gPanelManager:CheckShow(gPanelId.S_ONLINE_PLAY_ENTRANCE_HALF_PANEL)
	end

	gPanelManager:Close(gPanelId.S_ONLINE_PLAY_ENTRANCE_PANEL)
end

M.OnRefreshSearchState = function(self)
	self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime == 0]

	if self.bindData.inSearching ~= BOOL2CTL[true] then
		self.OnRefreshSearching(self)
	end
end

M.OnRefreshSearching = function(self)
	if self.bindData.inSearching ~= BOOL2CTL[false] then
		self.bindData.inSearching = BOOL2CTL[self.mgr.baseTime == 0]
	end

	self.bindData.timeLabel = self.mgr.baseTime == 0 and gTimeUtils:FormatTime(Time.unscaledTime - self.mgr.baseTime) or ""
end

M.OnShow = function(self, panelId, data)
	if not data or not data.modeId then
		self.modeId = self.mgr.targetPlayId
	else
		self.modeId = data.modeId
	end

	local _, cfg, isFullEnterance = self.mgr:OnRefreshLinkContent(self.bindData.content, self.modeId, self.SubGroup.CommonTabSingleStore)
	self.isFullEntrance = isFullEnterance
	self.bindData.showTabCtrl = BOOL2CTL[isFullEnterance]

	if not cfg then
		self.OnCloseBtnClick(self)

		return
	end

	local inLinkMode = self.mgr:CheckInLinkMode()
	self.bindData.canRoom = BOOL2CTL[inLinkMode and self.modeId == 12110013 and self.modeId == 12111114 and self.modeId == 12111115 and self.modeId == 12111113]

	self:OnRefreshSearchState()
	self:RefreshTeamState()
end

M.RefreshTeamState = function(self)
	local inQuickStart, isOutMember, isFullMax = self.mgr:CheckIsFullTeam()
	local isInTeam = gTeamManager:IsInTeam()
	self.bindData.canQuickStart = BOOL2CTL[inQuickStart]
	self.bindData.isOutMember = BOOL2CTL[isOutMember]
	self.bindData.canMatch = BOOL2CTL[not isFullMax]
	self.bindData.isSingle = BOOL2CTL[not isInTeam]

	if isInTeam then
		self.bindData.uNavigationArea:SetButtonInfoTipNameId(844, SearchButtonIndex)
	else
		self.bindData.uNavigationArea:SetButtonInfoTipNameId(843, SearchButtonIndex)
	end

	if not isInTeam then
		self.bindData.showNotTeamLeaderTip = 0
		self.bindData.startBtn.interactable = true
		self.bindData.hostBtn.interactable = true

		return
	end

	local isLeader = gTeamManager:IsTeamLeader()
	self.bindData.showNotTeamLeaderTip = not isLeader and 1 or 0
	self.bindData.startBtn.interactable = isLeader
	self.bindData.hostBtn.interactable = isLeader

	if isLeader and isOutMember then
		self.bindData.startBtn.interactable = false
		self.bindData.showNotTeamLeaderTip = 1
		self.bindData.tips = LTConfig.LinkConfig.ExceedPlayerNumLimit
	else
		self.bindData.tips = LTConfig.TextCommonTextConfig.GetConfig(74009538).Text
	end
end

M.OnStartBtnClick = function(self)
	self:OnCloseBtnClick()
	self.mgr:AskStartGame()
end

M.OnClose = function(self)
	gMessageManager:SendMessage(gEventConstants.INTERACTION_ACTION_FINISH)
end

M.OnActiveDeviceChange = function(self, device)
end
