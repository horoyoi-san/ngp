local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local UNavigationMgr = SGUI.UNavigationMgr
local LinkConfig = LTConfig.LinkConfig
C_OnlineRoomPanelStore = DefClass("C_OnlineRoomPanelStore", C_OnlineRoomPanelStore, C_StoreGroup)
GroupName2Class.OnlineRoomPanelStore = C_OnlineRoomPanelStore
local M = C_OnlineRoomPanelStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor()
	self.currentFriendList = {}
	self.tick = 0
	self.mgr = gLinkManager
end

function M:OnAwake()
	self.bindData.chatBtn.luaClick = self:CreateAction("OnOpenChat")
	self.bindData.hideChatBtn.luaClick = self:CreateAction("HideChat")
	self.bindData.backBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.inviteBtn.luaClick = self:CreateAction("OnOpenInvite")
	self.bindData.startGameBtn.luaClick = self:CreateAction("OnStartGame")
	self.bindData.searchBtn.luaClick = self:CreateAction("OnBeginSearch")
	self.bindData.cancelSearchBtn.luaClick = self:CreateAction("OnCancelSearch")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnOpenSetting")
	self.bindData.backGroundBtn.luaClick = self:CreateAction("OnBackGroundClick")
	self.bindData.tabLeftBtn.luaClick = self:CreateActionWithArgs("OnChangeTab", -1)
	self.bindData.tabRightBtn.luaClick = self:CreateActionWithArgs("OnChangeTab", 1)
	self.bindData.settingList.luaSimpleRenderItem = self:CreateAction(self.OnRenderSettingItem)
	self.bindData.playerList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRoomPlayerItem)
	self.bindData.tabTabList.luaSelectedChanged = self:CreateAction(self.OnTabTabListSelectedChange)
	self.bindData.tabPlayerList.luaSimpleRenderItem = self:CreateAction(self.OnRenderRoomFriendItem)
	self.SETTING_LIST = {
		{
			state = "AllowNonLeaderInvite",
			label = TextScriptTextConfig.GetConfig(89901089).Text,
			luaClick = self:CreateAction("ChangeAllowNonLeaderInvite", self.mgr)
		}
	}
	self.TAB_LIST = {
		{
			selected = true,
			label = TextScriptTextConfig.GetConfig(89901091).Text
		},
		{
			selected = false,
			label = TextScriptTextConfig.GetConfig(89901092).Text
		}
	}
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self:CreateAction(self.OnFriendMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self:CreateAction(self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_SEARCHING_REFRESH] = self:CreateAction(self.OnRefreshSearching),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self:CreateAction(self.OnRefreshSearchState),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self:CreateAction(self.OnRefreshMemberInfo),
		[gEventConstants.LINK_ROOM_SETTING_CHANGE] = self:CreateAction(self.OnRefreshSetting)
	}
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnBackGroundClick()
	self:SwitchTabDisplay(0)
end

function M:OnCloseBtnClick()
	local name = self.mgr:GetPlayModeName(self.mgr.targetPlayId)

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.OnLineRoomExit, self:CreateAction("_OnRealClose"), function ()
		return
	end, name)
end

function M:_OnRealClose()
	local inSearch = self.mgr.baseTime ~= 0

	if inSearch then
		self.mgr:AskMatchCancel()
	end

	self.mgr:AskLeaveRoom()
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
end

function M:OnShow(panelId, data)
	self.mgr:OnRefreshLinkContent(self.bindData.content)
	self:OnInit()
	self:OnRefreshSearchState()
end

function M:OnInit()
	self:InitSetting()
	self:OnRefreshMemberInfo()
end

local TICK_RATE = 10

function M:OnUpdate()
	self.tick = self.tick + 1

	if self.tick < TICK_RATE then
		return
	end

	self.tick = 0

	if self.bindData.showFriendTab == BOOL2CTL[true] then
		self.bindData.tabPlayerList:RefreshList()
	end
end

function M:OnOpenChat()
	self.bindData.showChat = 1
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.phoneChatNavigationArea
end

function M:HideChat()
	self.bindData.showChat = 0
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
end

function M:OnRenderSettingItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.SETTING_LIST[index + 1]
	store.titleLabel = data.label
	store.showBtn.isSelected = self.mgr.roomSetting[data.state]
	store.showBtn.luaClick = data.luaClick
	store.showBtn.interactable = self.mgr:CheckIsRoomLeader()
end

function M:OnOpenSetting()
	self:SwitchTabDisplay(self.bindData.showSettingTab == BOOL2CTL[true] and 0 or 2)
	self.bindData.settingList:RefreshList()
end

function M:InitSetting()
	self.bindData.settingList:SetSimpleList(#self.SETTING_LIST)
end

function M:OnChangeTab(step)
	local index = self.bindData.tabTabList.selectedIndex + step

	if index < 0 then
		index = 0
	elseif index >= #self.TAB_LIST then
		index = #self.TAB_LIST - 1
	end

	self.bindData.tabTabList:SelectItem(index)
end

function M:OnOpenInvite()
	self:SwitchTabDisplay(self.bindData.showFriendTab == BOOL2CTL[true] and 0 or 1)

	if self.bindData.showFriendTab == BOOL2CTL[true] then
		self.bindData.tabTabList:SetSimpleList(#self.TAB_LIST)

		for i = 1, #self.TAB_LIST do
			self.bindData.tabTabList:SetItemLabel(i - 1, self.TAB_LIST[i].label)
		end

		self.bindData.tabTabList:SelectItem(0)
		self:OnRequestFriendInfo()
	end
end

function M:OnRequestFriendInfo()
	self.bindData.tabPlayerList:SetSimpleList(0)
	self.mgr:RefreshFriendAndLinkMemberInfo(function ()
		self:OnTabTabListSelectedChange()
	end)
end

function M:OnTabTabListSelectedChange()
	if not self.STATE_EnableOnce then
		return
	end

	if self.bindData.tabTabList.selectedIndex == 0 then
		self.inviteList = self.mgr:GetFriendemberInfo()
	else
		self.inviteList = self.mgr:GetLinkMemberInfo()
	end

	self.bindData.tabPlayerList:SetSimpleList(#self.inviteList)
end

function M:OnRenderRoomFriendItem(btn, index)
	local store = gStoreManager:GetStoreGroup("OnlineFriendCommonTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.inviteList[index + 1]
	local cdTime = self.mgr.roomAskInviteDict[data.pid] and LinkConfig.LinkRoomInviteStayTime - gCS.TimeManager.ServerUnixTime + self.mgr.roomAskInviteDict[data.pid] or 0
	local inCD = cdTime > 0
	store.isInRoom = self.mgr.matchRoomMemberDict[data.pid] and 0 or 1
	store.userInfo.pid = data.pid
	store.userInfo.luaInfoUpdate = self:CreateActionWithArgs("OnUserInfoUpdate", store)
	store.isInCD = inCD and 0 or 1

	if inCD then
		store.cdTimeLabel = gString.Format(TextScriptTextConfig.GetConfig(89901105).Text, math.floor(cdTime))
	end

	function store.inviteBtn.luaClick()
		self.mgr:AskInviteFriendToRoom(data.pid)

		store.isInCD = 0
		store.cdTimeLabel = ""
	end
end

function M:OnFriendMemberInfoChange()
	self:OnRequestFriendInfo()
	self.bindData.playerList:RefreshList()
end

function M:OnLinkMemberInfoChange()
	self:OnFriendMemberInfoChange()
end

function M:OnRenderRoomPlayerItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.playerList[index + 1]
	store.isHomeOwner = BOOL2CTL[data.isLeader]
	store.isFriend = BOOL2CTL[data.isSelf or gFriendManager:IsFriend(data.pid)]
	store.userInfo.pid = data.pid
	store.numberLabel = data.id
	store.addFriendBtn.luaClick = self:CreateActionWithArgs("AskApplyFriend", data.pid, gFriendManager)
	store.viewMoreBtn.luaClick = self:CreateActionWithArgs("OpenPlayerDetailInfo", data.pid, self.mgr)
end

function M:OnRefreshMemberInfo()
	local playerInfo = self.mgr:GetRoomPlayerInfo()
	self.playerList = playerInfo

	self.bindData.playerList:SetSimpleList(#self.playerList)
	self.bindData.settingList:RefreshList()

	self.bindData.isHost = BOOL2CTL[self.mgr:CheckIsRoomLeader()]

	self:OnRefreshSetting()
	self:OnRequestFriendInfo()
end

function M:SwitchTabDisplay(tab)
	self.bindData.showChat = 0
	self.bindData.showFriendTab = BOOL2CTL[tab == 1]
	self.bindData.showSettingTab = BOOL2CTL[tab == 2]
	self.bindData.showBackBtn = BOOL2CTL[tab == 0]

	if self.bindData.showBackBtn == BOOL2CTL[true] then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
	elseif self.bindData.showSettingTab == BOOL2CTL[true] then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tab2NavigationArea
	else
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tab1NavigationArea
	end
end

function M:OnRefreshSetting()
	local isLeader = self.mgr:CheckIsRoomLeader()
	local canEnter, canStart = self.mgr:CheckRoomCanEnterAndStart()
	local canInvite = self.mgr.roomSetting.AllowNonLeaderInvite or isLeader
	self.bindData.inviteBtn.interactable = canEnter and canInvite
	self.bindData.startGameBtn.interactable = isLeader and canStart
	self.bindData.searchBtn.interactable = isLeader and canEnter

	if self.bindData.showFriendTab == BOOL2CTL[true] and (not canEnter or not canInvite) then
		self:SwitchTabDisplay(0)
	end
end

function M:OnStartGame()
	if not self.mgr:CheckRoomCanEnterGame() then
		return
	end

	self.mgr:AskStartGame()
end

function M:OnBeginSearch()
	if not self.mgr:CheckRoomCanEnterGame() then
		return
	end

	self.bindData.inSearching = BOOL2CTL[true]
	self.bindData.showBackBtn = BOOL2CTL[false]

	self.mgr:AskMatchBegin(self.mgr.targetPlayId, false, self:CreateAction("OnRefreshSearchState"))
end

function M:OnCancelSearch()
	self.bindData.inSearching = BOOL2CTL[false]
	self.bindData.showBackBtn = BOOL2CTL[true]

	self.mgr:AskMatchCancel(self:CreateAction("OnRefreshSearchState"))
end

function M:OnRefreshSearchState()
	local inSearch = self.mgr.baseTime ~= 0
	self.bindData.inSearching = BOOL2CTL[inSearch]
	self.bindData.showBackBtn = BOOL2CTL[not inSearch]
end

function M:OnRefreshSearching()
	if self.bindData.inSearching == BOOL2CTL[false] then
		self:OnRefreshSearchState()
	end

	self.bindData.timeLabel = self.mgr.baseTime ~= 0 and gTimeUtils:FormatTime(Time.unscaledTime - self.mgr.baseTime) or ""
end
