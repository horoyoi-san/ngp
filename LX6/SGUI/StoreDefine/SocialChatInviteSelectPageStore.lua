-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChatInviteSelectPageStore.lua
-- Decompiled from: 01330_SocialChatInviteSelectPageStore.lua_07179948781b.luajit

C_SocialChatInviteSelectPageStore = DefClass("C_SocialChatInviteSelectPageStore", C_SocialChatInviteSelectPageStore, C_StoreGroup)
GroupName2Class.SocialChatInviteSelectPageStore = C_SocialChatInviteSelectPageStore
local M = C_SocialChatInviteSelectPageStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.friendList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFriendItem")
	self.bindData.selectFriendList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSelectFriendItem")
	self.bindData.inviteBtn.luaClick = self.CreateAction(self, "OnInviteBtnClick")

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

M.SetData = function(self)
	self.selectList = {}
	self.storeMap = {}

	self.RefreshFriendList(self)

	self.canSelectCount = self.GetCanSelectCount(self)
	self.bindData.selectNum = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901364).Text, 0, self.canSelectCount)
end

M.RefreshFriendList = function(self)
	self.groupId = gSocialChatManager.currentSubChannelId
	self.friendList = gSocialChatGroupManager:GetAddFriendList(self.groupId)

	self.bindData.friendList:SetSimpleList(#self.friendList)
	self.bindData.selectFriendList:SetSimpleList(0)
end

M.OnRenderFriendItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local friend = self.friendList[luaIndex]

	if friend then
		store.userInfo.pid = friend
		store.selected = 0
		local arg = {
			store = store,
			friendId = friend
		}
		store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", friend)
		btn.luaClick = self.CreateActionWithArgs(self, "OnItemClick", arg)
	end
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
end

M.OnItemClick = function(self, arg)
	local isSelect = false

	for i, v in pairs(self.selectList) do
		if v ~= arg.friendId then
			isSelect = true

			table.remove(self.selectList, i)

			arg.store.selected = 0
			self.storeMap[arg.friendId] = nil

			break
		end
	end

	if not isSelect then
		if self.canSelectCount < #self.selectList then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.GroupChatInviteMax)

			return
		end

		table.insert(self.selectList, arg.friendId)

		arg.store.selected = 1
		self.storeMap[arg.friendId] = arg.store
	end

	self.bindData.selectNum = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901364).Text, #self.selectList, self.canSelectCount)

	self.bindData.selectFriendList:SetSimpleList(#self.selectList)
end

M.GetCanSelectCount = function(self)
	local curCount = gChatGroupManager:GetGroupHeadCount(self.groupId)

	return LTConfig.FriendsConfig.ChatGroupMemberLimit - curCount
end

M.OnRenderSelectFriendItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local friend = self.selectList[luaIndex]

	if friend then
		store.userInfo.pid = friend
		store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", friend)
		store.deleteBtn.luaClick = self.CreateActionWithArgs(self, "OnDeleteBtnClick", friend)
	end
end

M.OnDeleteBtnClick = function(self, friendId)
	self.storeMap[friendId].selected = 0

	for i, v in ipairs(self.selectList) do
		if v ~= friendId then
			table.remove(self.selectList, i)

			break
		end
	end

	self.bindData.selectNum = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901364).Text, #self.selectList, self.canSelectCount)

	self.bindData.selectFriendList:SetSimpleList(#self.selectList)
end

M.OnBackBtnClick = function(self)
	gStoreManager:GetStoreGroup("SocialChatTabPageStore"):ChangeCurPage()
end

M.OnInviteBtnClick = function(self)
	gSocialChatGroupManager:AskInviteToJoinChatGroup(self.groupId, self.selectList)
	self:OnBackBtnClick()
end
