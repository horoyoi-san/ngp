-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineRoomPanelStore.lua
-- Decompiled from: 01060_OnlineRoomPanelStore.lua_86decc24618e.luajit

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

M.ctor = function(self)
	self.currentFriendList = {}
	self.tick = 0
	self.mgr = gLinkManager
end

M.OnAwake = function(self)
	self.bindData.chatBtn.luaClick = self.CreateAction(self, "OnOpenChat")
	self.bindData.hideChatBtn.luaClick = self.CreateAction(self, "HideChat")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.inviteBtn.luaClick = self.CreateAction(self, "OnOpenInvite")
	self.bindData.startGameBtn.luaClick = self.CreateAction(self, "OnStartGame")
	self.bindData.searchBtn.luaClick = self.CreateAction(self, "OnBeginSearch")
	self.bindData.cancelSearchBtn.luaClick = self.CreateAction(self, "OnCancelSearch")
	self.bindData.settingBtn.luaClick = self.CreateAction(self, "OnOpenSetting")
	self.bindData.backGroundBtn.luaClick = self.CreateAction(self, "OnBackGroundClick")
	self.bindData.tabLeftBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeTab", -1)
	self.bindData.tabRightBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeTab", 1)
	self.bindData.settingList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderSettingItem)
	self.bindData.playerList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRoomPlayerItem)
	self.bindData.tabTabList.luaSelectedChanged = self.CreateAction(self, self.OnTabTabListSelectedChange)
	self.bindData.tabPlayerList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderRoomFriendItem)
	self.SETTING_LIST = {
		{
			["^\\xba\\xa3\\xbb\\xb3"] = "\\xa3#\\xe1\\xb3D\\xc9U,\\xcd\\xef'Eu\\xc47\\xb5\\xdf",
			label = TextScriptTextConfig.GetConfig(89901089).Text,
			luaClick = self.CreateAction(self, "ChangeAllowNonLeaderInvite", self.mgr)
		}
	}
	self.TAB_LIST = {
		{
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = true,
			label = TextScriptTextConfig.GetConfig(89901091).Text
		},
		{
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			label = TextScriptTextConfig.GetConfig(89901092).Text
		}
	}
	self.msgEvents = {
		[gEventConstants.ADD_CHAT_FRIEND] = self.CreateAction(self, self.OnFriendMemberInfoChange),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange),
		[gEventConstants.LINK_SEARCHING_REFRESH] = self.CreateAction(self, self.OnRefreshSearching),
		[gEventConstants.LINK_SEARCHING_STATE_CHANGE] = self.CreateAction(self, self.OnRefreshSearchState),
		[gEventConstants.LINK_MATCH_MEMBER_INFO_CHANGE] = self.CreateAction(self, self.OnRefreshMemberInfo),
		[gEventConstants.LINK_ROOM_SETTING_CHANGE] = self.CreateAction(self, self.OnRefreshSetting)
	}
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnBackGroundClick = function(self)
	self.SwitchTabDisplay(self, 0)
end

M.OnCloseBtnClick = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(LTConfig.MessageConfig.OnLineRoomExit, self:CreateAction("_OnRealClose"), function ()
	end)
end

M._OnRealClose = function(self)
	local inSearch = self.mgr.baseTime == 0

	if inSearch then
		self.mgr:AskMatchCancel()
	end

	self.mgr:AskLeaveRoom()
	self.mgr:OnMatchInit()
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_PANEL)
end

M.OnShow = function(self, panelId, data)
	self.mgr:OnRefreshLinkContent(self.bindData.content, self.mgr.targetPlayId)
	self:OnInit()
	self:OnRefreshSearchState()
end

M.OnInit = function(self)
	self.InitSetting(self)
	self.OnRefreshMemberInfo(self)
end

local TICK_RATE = 10

M.OnUpdate = function(self)
	self.tick = self.tick + 1

	if self.tick >= TICK_RATE then
		return
	end

	self.tick = 0

	if self.bindData.showFriendTab ~= BOOL2CTL[true] then
		self.bindData.tabPlayerList:RefreshList()
	end
end

M.OnOpenChat = function(self)
	gPanelManager:CheckShow(gPanelId.SOCIAL_CHAT_HOME_PANEL_HALF_SCREEN, {
		tabId = tabId,
		topChannelId = gSocialChatManager.ChatTopChannel.Channels,
		subChannelId = UX.Game.MessageChannel.Room
	})
end

M.HideChat = function(self)
end

M.OnRenderSettingItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.SETTING_LIST[index + 1]
	store.titleLabel = data.label
	store.showBtn.isSelected = self.mgr.roomSetting[data.state]
	store.showBtn.luaClick = data.luaClick
	store.showBtn.interactable = self.mgr:CheckIsRoomLeader()
end

M.OnOpenSetting = function(self)
	self:SwitchTabDisplay(self.bindData.showSettingTab ~= BOOL2CTL[true] and 0 or 2)
	self.bindData.settingList:RefreshList()
end

M.InitSetting = function(self)
	self.bindData.settingList:SetSimpleList(#self.SETTING_LIST)
end

M.OnChangeTab = function(self, step)
	local index = self.bindData.tabTabList.selectedIndex + step

	if index >= 0 then
		index = 0
	elseif index > #self.TAB_LIST then
		index = #self.TAB_LIST - 1
	end

	self.bindData.tabTabList:SelectItem(index)
end

M.OnOpenInvite = function(self)
	self:SwitchTabDisplay(self.bindData.showFriendTab ~= BOOL2CTL[true] and 0 or 1)

	if self.bindData.showFriendTab ~= BOOL2CTL[true] then
		self.bindData.tabTabList:SetSimpleList(#self.TAB_LIST)

		for i = 1, #self.TAB_LIST do
			self.bindData.tabTabList:SetItemLabel(i - 1, self.TAB_LIST[i].label)
		end

		self.bindData.tabTabList:SelectItem(0)
		self:OnRequestFriendInfo()
	end
end

M.OnRequestFriendInfo = function(self)
	slot1 = self.bindData.tabPlayerList

	slot1:SetSimpleList(0)

	slot1 = self.mgr

	slot1:RefreshFriendAndLinkMemberInfo(function ()
		self:OnTabTabListSelectedChange()
	end)
end

M.OnTabTabListSelectedChange = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	if self.bindData.tabTabList.selectedIndex ~= 0 then
		self.inviteList = self.mgr:GetFriendemberInfo()
	else
		self.inviteList = self.mgr:GetLinkMemberInfo()
	end

	self.bindData.tabPlayerList:SetSimpleList(#self.inviteList)
end

M.OnRenderRoomFriendItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("OnlineFriendCommonTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.inviteList[index + 1]
	local cdTime = self.mgr.roomAskInviteDict[data.pid] and LinkConfig.LinkRoomInviteStayTime - gCS.TimeManager.ServerUnixTime + self.mgr.roomAskInviteDict[data.pid] or 0
	local inCD = cdTime >= 0
	store.isInRoom = self.mgr.matchRoomMemberDict[data.pid] and 0 or 1
	store.userInfo.pid = data.pid
	store.userInfo.luaInfoUpdate = self:CreateActionWithArgs("OnUserInfoUpdate", store)
	store.isInCD = inCD and 0 or 1

	if inCD then
		store.cdTimeLabel = gString.Format(TextScriptTextConfig.GetConfig(89901105).Text, math.floor(cdTime))
	end

	store.headBtn.luaRenderTooltip = function(btn, tooltip)
		gSocialPalyerTooltipManager:OnRenderToolTips(data.pid, btn, tooltip, _)
	end

	store.inviteBtn.luaClick = function()
		self.mgr:AskInviteFriendToRoom(data.pid)

		store.isInCD = 0
		store.cdTimeLabel = ""
	end
end

M.OnFriendMemberInfoChange = function(self)
	self:OnRequestFriendInfo()
	self.bindData.playerList:RefreshList()
end

M.OnLinkMemberInfoChange = function(self)
	self.OnFriendMemberInfoChange(self)
end

M.OnRenderRoomPlayerItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.playerList[index + 1]
	store.isHomeOwner = BOOL2CTL[data.isLeader]
	store.isFriend = BOOL2CTL[data.isSelf or gFriendManager:IsFriend(data.pid)]
	store.userInfo.pid = data.pid
	store.numberLabel = data.id
	store.color = self.mgr:GetColorInfo(data.pid)
	store.addFriendBtn.luaClick = self:CreateActionWithArgs("AskApplyFriend", data.pid, gFriendManager)
	store.viewMoreBtn.luaClick = self:CreateActionWithArgs("OpenPlayerDetailInfo", data.pid, self.mgr)
end

M.OnRefreshMemberInfo = function(self)
	local playerInfo = self.mgr:GetRoomPlayerInfo()
	self.playerList = playerInfo

	self.bindData.playerList:SetSimpleList(#self.playerList)
	self.bindData.settingList:RefreshList()

	self.bindData.isHost = BOOL2CTL[self.mgr:CheckIsRoomLeader()]

	self:OnRefreshSetting()
	self:OnRequestFriendInfo()
end

M.SwitchTabDisplay = function(self, tab)
	self.bindData.showChat = 0
	self.bindData.showFriendTab = BOOL2CTL[tab ~= 1]
	self.bindData.showSettingTab = BOOL2CTL[tab ~= 2]
	self.bindData.showBackBtn = BOOL2CTL[tab ~= 0]

	if self.bindData.showBackBtn ~= BOOL2CTL[true] then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
	elseif self.bindData.showSettingTab ~= BOOL2CTL[true] then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tab2NavigationArea
	else
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.tab1NavigationArea
	end
end

M.OnRefreshSetting = function(self)
	local isLeader = self.mgr:CheckIsRoomLeader()
	local canEnter, canStart = self.mgr:CheckRoomCanEnterAndStart()
	local canInvite = self.mgr.roomSetting.AllowNonLeaderInvite or isLeader
	self.bindData.inviteBtn.interactable = canEnter and canInvite
	self.bindData.startGameBtn.interactable = isLeader and canStart
	self.bindData.searchBtn.interactable = isLeader and canEnter

	if self.bindData.showFriendTab ~= BOOL2CTL[true] and (not canEnter or not canInvite) then
		self.SwitchTabDisplay(self, 0)
	end
end

M.OnStartGame = function(self)
	if not self.mgr:CheckRoomCanEnterGame() then
		return
	end

	self.mgr:AskStartGame()
end

M.OnBeginSearch = function(self)
	if not self.mgr:CheckRoomCanEnterGame() then
		return
	end

	self.bindData.inSearching = BOOL2CTL[true]
	self.bindData.showBackBtn = BOOL2CTL[false]

	self.mgr:AskMatchBegin(self.mgr.targetPlayId, false, self:CreateAction("OnRefreshSearchState"))
end

M.OnCancelSearch = function(self)
	self.bindData.inSearching = BOOL2CTL[false]
	self.bindData.showBackBtn = BOOL2CTL[true]

	self.mgr:AskMatchCancel(self:CreateAction("OnRefreshSearchState"))
end

M.OnRefreshSearchState = function(self)
	local inSearch = self.mgr.baseTime == 0
	self.bindData.inSearching = BOOL2CTL[inSearch]
	self.bindData.showBackBtn = BOOL2CTL[not inSearch]
end

M.OnRefreshSearching = function(self)
	if self.bindData.inSearching ~= BOOL2CTL[false] then
		self.OnRefreshSearchState(self)
	end

	self.bindData.timeLabel = self.mgr.baseTime == 0 and gTimeUtils:FormatTime(Time.unscaledTime - self.mgr.baseTime) or ""
end
