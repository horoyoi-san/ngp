-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialFriendListStore.lua
-- Decompiled from: 01280_SocialFriendListStore.lua_229820215109.luajit

C_SocialFriendListStore = DefClass("C_SocialFriendListStore", C_SocialFriendListStore, C_StoreGroup)
GroupName2Class.SocialFriendListStore = C_SocialFriendListStore
local M = C_SocialFriendListStore
M.OnlineStatus = {
	["3F\\x9d\\x87\\x8dD"] = 0,
	["\\xf6\\xdd*\\xf4"] = 1,
	["/A\\x9f\\x89\\x8fD"] = 2,
	X7nB = 3
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFriendItem")

	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_FRIEND_INFO_CHANGE] = self.CreateAction(self, "RefreshFriendList")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi
end

M.OnEnable = function(self)
	self.bindData.num = ""

	self.RefreshFriendList(self)
end

M.RefreshFriendList = function(self)
	local friendList = gSocialFriendManager.friendList

	if #friendList < 0 then
		self.bindData.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901365).Text, 0, 0)

		self.bindData.list:SetSimpleList(0)

		self.bindData.isEmpty = 1

		return
	end

	local pidList = {}

	for _, friend in ipairs(friendList) do
		table.insert(pidList, friend.Pid)
	end

	slot3 = gFriendManager

	slot3:GetSimplePlayerInfoByPidList(pidList, function (infoList)
		self.pidToInfo = {}

		for _, info in ipairs(infoList) do
			self.pidToInfo[info.Pid] = info
		end

		table.sort(friendList, function (a, b)
			local infoA = self.pidToInfo[a.Pid]
			local infoB = self.pidToInfo[b.Pid]
			local onlineStateA = infoA and infoA.OnlineState or UX.Game.PlayerState.Offline
			local onlineStateB = infoB and infoB.OnlineState or UX.Game.PlayerState.Offline
			local isOnlineA = onlineStateA ~= UX.Game.PlayerState.Online
			local isOnlineB = onlineStateB ~= UX.Game.PlayerState.Online

			if isOnlineA == isOnlineB then
				return isOnlineA
			end

			if isOnlineA and isOnlineB then
				return ulong.Less(a.Pid, b.Pid)
			end

			local logoutTimeA = infoA and infoA.LastLogoutTime or 0
			local logoutTimeB = infoB and infoB.LastLogoutTime or 0

			if logoutTimeA == logoutTimeB then
				return logoutTimeB <= logoutTimeA
			end

			return ulong.Less(a.Pid, b.Pid)
		end)

		local onlineCount = 0

		for _, friend in ipairs(friendList) do
			local info = self.pidToInfo[friend.Pid]

			if info and info.OnlineState ~= UX.Game.PlayerState.Online then
				onlineCount = onlineCount + 1
			end
		end

		if not self.bindData then
			return
		end

		self.bindData.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901365).Text, onlineCount, #friendList)

		if not self.bindData.list then
			return
		end

		self.bindData.list:SetSimpleList(#friendList)

		self.bindData.isEmpty = 0
	end, true)
end

M.OnRenderFriendItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local friend = gSocialFriendManager.friendList[luaIndex]

	if friend then
		store.userInfo.pid = friend.Pid
		store.headBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", friend.Pid)
		local info = self.pidToInfo and self.pidToInfo[friend.Pid]

		if info then
			if info.OnlineState ~= UX.Game.PlayerState.Online then
				local mode = info.LinkMode

				if not mode or mode ~= UX.Game.LinkMode.None then
					store.onlineStatus = self.OnlineStatus.Single
				elseif mode ~= UX.Game.LinkMode.Match or info.InMatch then
					store.onlineStatus = self.OnlineStatus.Busy
				elseif mode ~= UX.Game.LinkMode.Public or mode ~= UX.Game.LinkMode.Private then
					store.onlineStatus = self.OnlineStatus.Online
				end
			else
				store.onlineStatus = self.OnlineStatus.Offline
			end
		else
			store.onlineStatus = self.OnlineStatus.Offline
		end
	end

	if friend then
		btn.luaClick = self.CreateActionWithArgs(self, "OnFriendBtnClick", friend.Pid)
	end
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
	gSocialPalyerTooltipManager:KeepBtnSelectedWhileTooltipOpened(btn)
end

M.OnFriendBtnClick = function(self, pid)
	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Friend, pid)
end
