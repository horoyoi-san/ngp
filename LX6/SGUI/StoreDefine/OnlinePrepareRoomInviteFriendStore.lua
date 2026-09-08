-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePrepareRoomInviteFriendStore.lua
-- Decompiled from: 01114_OnlinePrepareRoomInviteFriendStore.lua_b1ea21dd05a4.luajit

local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local LinkConfig = LTConfig.LinkConfig
local MessageConfig = LTConfig.MessageConfig
C_OnlinePrepareRoomInviteFriendStore = DefClass("C_OnlinePrepareRoomInviteFriendStore", C_OnlinePrepareRoomInviteFriendStore, C_StoreGroup)
GroupName2Class.OnlinePrepareRoomInviteFriendStore = C_OnlinePrepareRoomInviteFriendStore
local M = C_OnlinePrepareRoomInviteFriendStore
local TICK_RATE = 10

M.ctor = function(self)
	self.TabType = {
		["\\xfa\\xd3!\\xfd"] = 1,
		[":Z\\x98\\x8b\\x8dE"] = 0
	}
	self.OnlineStatus = {
		["3F\\x9d\\x87\\x8dD"] = 0,
		["\\xf6\\xdd*\\xf4"] = 1,
		["/A\\x9f\\x89\\x8fD"] = 2,
		X7nB = 3
	}
	self.inviteCD = {}
end

M.DefineAllVariables = function(self)
	self.TabData = {
		{
			id = self.TabType.Friend,
			title = TextScriptTextConfig.GetConfig(89900110).Text
		},
		{
			id = self.TabType.Channel,
			title = TextScriptTextConfig.GetConfig(89900113).Text
		}
	}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.tick = 0
	self.selectedTabIndex = self.TabType.Friend
	self.friendList = {}
	self.channelList = {}
	self.closeCallback = nil
	self.watchIdSet = {}
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
end

M.OnGroupDisable = function(self)
	self.UnwatchAll(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnUpdate = function(self)
	self.tick = self.tick + 1

	if self.tick >= TICK_RATE then
		return
	end

	self.tick = 0

	self.RefreshList(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnClickExitBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetTIndex)
end

M.OnClickExitBtn = function(self)
	if self.closeCallback then
		self.closeCallback()
	end
end

M.InitData = function(self, linkGame, closeCallback)
	self.linkGame = linkGame
	self.closeCallback = closeCallback
end

M.OnOpen = function(self)
	gPSNOnlineInviteManager:RefreshSafetySnapshot()
	self:InitChannelMemberList()
	self:InitFriendList()
	self:SetTabData()
end

M.InitChannelMemberList = function(self)
	self.channelList = {}
	slot1 = gLinkManager

	slot1:RefreshFriendAndLinkMemberInfo(function ()
		self.channelList = {}
		local members = gLinkManager:GetLinkMemberInfo()

		for _, ele in ipairs(members) do
			if not self.linkGame:ContainsPlayer(ele.pid) then
				local vo = gLinkManager.LinkMember[ele.pid]

				table.insert(self.channelList, vo)
			end
		end

		self:RefreshList()
	end)
end

M.InitFriendList = function(self)
	slot1 = gFriendManager

	slot1:GetOrderedFriendSimpleInfoList(function (data)
		self.friendList = {}

		for _, v in ipairs(data) do
			if not self.linkGame:ContainsPlayer(v.Pid) then
				table.insert(self.friendList, v)
			end
		end

		self:RefreshList()
		self:WatchAll()
	end)
end

M.SetTabData = function(self)
	self.SubGroup.CommonTabSingleStore:SetData(self.TabData, nil, self.selectedTabIndex or self.TabType.Friend, nil, self:CreateAction(self.OnChangeTabSelect))
end

M.OnGetTIndex = function(self)
	return 0
end

M.OnChangeTabSelect = function(self, uList, isSub)
	if isSub then
		return
	end

	self.selectedTabIndex = uList.selectedIndex

	self:RefreshList()
	Timer.New(function ()
		self.bindData.list:SetItemSelected(0, true)
	end, 0.2):Start()
end

M.RefreshList = function(self)
	local count = 0
	local list = self.selectedTabIndex ~= self.TabType.Friend and self.friendList or self.channelList

	if list then
		count = #list
	end

	self.bindData.list:SetSimpleList(count)
end

M.WatchAll = function(self)
	self.UnwatchAll(self)

	if not self.friendList then
		return
	end

	for _, v in ipairs(self.friendList) do
		local pid = v.Pid
		slot7 = gLinkPlayerHub.cs
		local watchId = slot7:Watch(pid, function (info)
			self:OnPlayerStateChanged(pid, info)
		end)
		self.watchIdSet[pid] = watchId
	end
end

M.UnwatchAll = function(self)
	for pid, watchId in pairs(self.watchIdSet) do
		gLinkPlayerHub.cs:Unwatch(pid, watchId)
	end

	self.watchIdSet = {}
end

M.OnPlayerStateChanged = function(self, pid, info)
	if not self.friendList then
		return
	end

	for _, v in ipairs(self.friendList) do
		if v.Pid ~= pid then
			v.OnlineState = info.OnlineState
			v.LinkMode = info.LinkMode
			v.InMatch = info.InMatch

			break
		end
	end

	self.bindData.list:RefreshList()
end

M.ClearExpiredCD = function(self, list)
	local now = gLuaDataManager.serverTime

	for k, v in pairs(list) do
		if v.stayTime >= now - v.timestamp then
			list[k] = nil
		end
	end
end

M.GetInviteCDInfo = function(self, pid)
	self.ClearExpiredCD(self, self.inviteCD)

	return self.inviteCD[pid]
end

M.AddInviteCD = function(self, pid, stayTime)
	if self.inviteCD[pid] then
		return false
	end

	self.inviteCD[pid] = {
		timestamp = gLuaDataManager.serverTime,
		stayTime = stayTime
	}

	return true
end

M.OnRenderItem = function(self, btn, index)
	local list = self.selectedTabIndex ~= self.TabType.Friend and self.friendList or self.channelList
	local data = list and list[index + 1]

	if not data then
		return
	end

	self.OnRenderPlayerItem(self, btn, data)
end

M.OnRenderPlayerItem = function(self, btn, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if store.userInfo then
		store.userInfo.pid = data.Pid
	end

	store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderTooltips, data.Pid)

	if data.OnlineState ~= UX.Game.PlayerState.Offline then
		store.onlineStatus = self.OnlineStatus.Offline
		store.showInviteBtn = 0
	else
		local mode = data.LinkMode

		if not mode or mode ~= UX.Game.LinkMode.None then
			store.onlineStatus = self.OnlineStatus.Single
			store.showInviteBtn = 0
		elseif mode ~= UX.Game.LinkMode.Match or data.InMatch then
			store.onlineStatus = self.OnlineStatus.Busy
			store.showInviteBtn = 0
		elseif mode ~= UX.Game.LinkMode.Public or mode ~= UX.Game.LinkMode.Private then
			store.onlineStatus = self.OnlineStatus.Online
			store.showInviteBtn = 1
		end
	end

	store.inviteBtn.luaClick = self:CreateActionWithArgs(self.OnInvitePlayerBtnClick, data.Pid)

	if gPSNOnlineInviteManager:IsInviteBlockedByPSN(data.Pid) then
		store.showInviteBtn = 0
	end

	if self.linkGame:ContainsPlayer(data.Pid) then
		store.isInCD = 1
		store.cdTimeLabel = TextCommonTextConfig.GetConfig(TextCommonTextConfig.InTeam).Text

		return
	end

	self.RenderCDLabel(self, store, self.GetInviteCDInfo(self, data.Pid))
end

M.RenderCDLabel = function(self, store, cdInfo)
	if not cdInfo then
		store.isInCD = 0

		return
	end

	store.isInCD = 1
	local countdown = cdInfo.stayTime - (gLuaDataManager.serverTime - cdInfo.timestamp)

	if countdown >= cdInfo.stayTime and countdown <= 0 then
		store.cdTimeLabel = math.floor(countdown) .. "s   "
	end
end

M.OnRenderTooltips = function(self, pid, btn, popup, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(popup)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, popup, _)
end

M.OnInvitePlayerBtnClick = function(self, pid)
	if self.linkGame:ContainsPlayer(pid) then
		return
	end

	if self.GetInviteCDInfo(self, pid) then
		return
	end

	if not self.CheckCanInvite(self) then
		return
	end

	gLinkManager:InvitePlayerToPrepareRoom(pid)
	self:AddInviteCD(pid, LinkConfig.LinkInviteCountDownTime)
	self.bindData.list:RefreshList()
end

M.CheckCanInvite = function(self)
	local setting = self.linkGame.uxData.Setting

	if setting and not setting.AllowNonLeaderInvite and not self.linkGame:IsLeader(gPlayerManager.infoLogin.bindData.pid) then
		gDisplayMessageMgr:ShowMessage(MessageConfig.Team_HasNoPermissions)

		return false
	end

	return true
end
