-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialGroupMemberManagePageStore.lua
-- Decompiled from: 01283_SocialGroupMemberManagePageStore.lua_6a359b1e2088.luajit

C_SocialGroupMemberManagePageStore = DefClass("C_SocialGroupMemberManagePageStore", C_SocialGroupMemberManagePageStore, C_StoreGroup)
GroupName2Class.SocialGroupMemberManagePageStore = C_SocialGroupMemberManagePageStore
local M = C_SocialGroupMemberManagePageStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.removeBtn.luaClick = self.CreateAction(self, "OnRemoveBtnClick")
	self.bindData.friendList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFriendItem")

	self.InitEvent(self)
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_CHATTING_CHANGED] = self.CreateAction(self, "OnChattingChanged")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnChattingChanged = function(self)
	gSocialChatManager:ChangeChattingPage(gSocialChatManager.chattingPageType.ChattingList)
end

M.OnEnable = function(self)
	self.selectList = {}
	self.groupId = gSocialChatManager.currentSubChannelId
	self.groupData = gSocialChatGroupManager:GetGroupData(self.groupId)

	self.bindData.friendList:SetSimpleList(#self.groupData.Members)

	self.isOwner = gSocialChatGroupManager:IsGroupOwner(self.groupId, gPlayerManager.infoLogin.bindData.pid)
	self.bindData.type = self.isOwner and 0 or 1
	local hideRemoveBtn = self.isOwner and #self.groupData.Members > 1

	self.bindData.removeBtn:SetActive(not hideRemoveBtn)
	self:SetGrounNum()
end

M.SetGrounNum = function(self)
	self.curGroupCount = gChatGroupManager:GetGroupHeadCount(self.groupId)
	self.bindData.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901368).Text, self.curGroupCount, LTConfig.FriendsConfig.ChatGroupMemberLimit)
	self.bindData.num2 = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901367).Text, self.curGroupCount, LTConfig.FriendsConfig.ChatGroupMemberLimit)

	self:SetSelectNum()
end

M.SetSelectNum = function(self)
	self.bindData.selected = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901364).Text, #self.selectList, self.curGroupCount - 1)
end

M.OnRenderFriendItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local member = self.groupData.Members[luaIndex]
	store.userInfo.pid = member
	store.selected = 0
	local isGroupOwner = gSocialChatGroupManager:IsGroupOwner(self.groupId, member)
	store.isOwner = isGroupOwner and 1 or 0
	store.type = self.isOwner and not isGroupOwner and 0 or 1
	local arg = {
		store = store,
		friendId = member,
		isOwner = isGroupOwner
	}
	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", member)
	btn.luaClick = self:CreateActionWithArgs("OnItemClick", arg)
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
	gSocialPalyerTooltipManager:KeepBtnSelectedWhileTooltipOpened(btn)
end

M.OnItemClick = function(self, arg)
	if not self.isOwner or arg.isOwner then
		return
	end

	local isSelect = false

	for i, v in pairs(self.selectList) do
		if v ~= arg.friendId then
			isSelect = true

			table.remove(self.selectList, i)

			arg.store.selected = 0

			break
		end
	end

	if not isSelect then
		table.insert(self.selectList, arg.friendId)

		arg.store.selected = 1
	end

	self.SetSelectNum(self)
end

M.OnBackBtnClick = function(self)
	gSocialChatManager:ChangeChattingPage(gSocialChatManager.chattingPageType.ChattingList)
end

M.OnRemoveBtnClick = function(self)
	if self.isOwner then
		gSocialChatManager:ChangeChattingPage(gSocialChatManager.chattingPageType.ChattingList)
		gSocialChatGroupManager:AskRemoveMemberFromChatGroup(self.groupId, self.selectList)
	end
end
