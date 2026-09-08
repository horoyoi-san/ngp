-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialFriendApplicationListStore.lua
-- Decompiled from: 01278_SocialFriendApplicationListStore.lua_6fd7c607d7fd.luajit

C_SocialFriendApplicationListStore = DefClass("C_SocialFriendApplicationListStore", C_SocialFriendApplicationListStore, C_StoreGroup)
GroupName2Class.SocialFriendApplicationListStore = C_SocialFriendApplicationListStore
local M = C_SocialFriendApplicationListStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetTIndex")
	self.bindData.acceptAllBtn.luaClick = self.CreateAction(self, "OnAcceptAllBtnClick")
	self.bindData.refuseAllBtn.luaClick = self.CreateAction(self, "OnRefuseAllBtnClick")

	self.RegisterSingleEvent(self, gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT, self.CreateAction(self, "RefreshData"))
end

M.OnGetTIndex = function(self, index)
	return self.listData[index + 1].tIndex
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	self:SetFriendData()
	SGUI.RedDotMgr.LuaSetRedDot(false, gSocialChatManager:GetFriendApplicationPath())
	gMessageManager:SendMessage(gEventConstants.SOCIAL_HUD_CHAT_REDDOT_CHANGED, gSocialChatManager:HasSocialChatRedDot())
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi

	self.SetFriendData(self)
end

M.RefreshData = function(self)
	self.SetFriendData(self)
end

M.SetFriendData = function(self)
	self.GetApplicationListData(self)

	if #self.listData ~= 0 then
		self.curListData = {}

		self.bindData.list:SetSimpleList(0)
		self.bindData.acceptAllBtn:SetActive(false)
		self.bindData.refuseAllBtn:SetActive(false)

		return
	end

	self.bindData.acceptAllBtn:SetActive(true)
	self.bindData.refuseAllBtn:SetActive(true)
	self.bindData.list:SetSimpleList(#self.listData)
end

M.GetApplicationListData = function(self)
	self.listData = {}
	self.pidList = {}
	self.groupList = {}

	for i, v in pairs(gSocialFriendManager.friendApplicationList) do
		local data = {
			tIndex = 0,
			topChannelId = gSocialChatManager.ChatTopChannel.Friend,
			pid = v.applicantPid,
			timestamp = v.timestamp
		}

		table.insert(self.listData, data)
		table.insert(self.pidList, v.applicantPid)
	end

	gSocialChatGroupManager:GetChatGroupInviteCount()

	for i, v in pairs(gSocialChatGroupManager.chatGroupInviteList) do
		local data = {
			tIndex = 1,
			topChannelId = gSocialChatManager.ChatTopChannel.Group,
			pid = v.inviter,
			timestamp = v.timestamp,
			groupName = v.groupName,
			groupId = v.groupId
		}

		table.insert(self.listData, data)
		table.insert(self.groupList, {
			groupId = v.groupId,
			pid = v.inviter
		})
	end

	table.sort(self.listData, function (a, b)
		return b.timestamp <= a.timestamp
	end)
end

M.OnRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.listData[index + 1]

	if data.tIndex ~= 1 then
		store.groupName = data.groupName
		btn.redKey = gSocialChatManager:GetGroupInvitationListItemKey(data.groupId)
	else
		btn.redKey = gSocialChatManager:GetFriendApplicationListItemKey(data.pid)
	end

	store.userInfo.pid = data.pid
	store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", data.pid)
	store.acceptBtn.luaClick = self.CreateActionWithArgs(self, "OnAcceptBtnClick", data)
	store.refuseBtn.luaClick = self.CreateActionWithArgs(self, "OnRefuseBtnClick", data)
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
	gSocialPalyerTooltipManager:KeepBtnSelectedWhileTooltipOpened(btn)
end

M.OnAcceptBtnClick = function(self, data)
	self.OnResponseApplication(self, data, true)
end

M.OnRefuseBtnClick = function(self, data)
	self.OnResponseApplication(self, data, false)
end

M.OnResponseApplication = function(self, data, accept)
	if data.topChannelId ~= gSocialChatManager.ChatTopChannel.Group then
		gSocialChatGroupManager:ResponseChatGroupInvite(data.pid, data.groupId, accept)
	elseif data.topChannelId ~= gSocialChatManager.ChatTopChannel.Friend then
		slot3 = gFriendManager

		slot3:GetSimplePlayerInfo(data.pid, function (info)
			if not info then
				return
			end

			gSocialFriendManager:ApplyFriendResponse(data.pid, accept, info.Name)
		end)
	end
end

M.OnAcceptAllBtnClick = function(self)
	if #self.pidList <= 0 then
		gSocialFriendManager:ApplyFriendResponseList(self.pidList, true)
	end

	self.ResponseAllChatGroupInvite(self, true)
end

M.OnRefuseAllBtnClick = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(LTConfig.MessageConfig.SocialIgnoreAllFriendRequest, function ()
		if #self.pidList <= 0 then
			gSocialFriendManager:RefuseAllFriendApplication(self.pidList)
		end

		self:ResponseAllChatGroupInvite(false)
	end)
end

M.ResponseAllChatGroupInvite = function(self, accept)
	if #self.groupList <= 0 then
		for i, v in pairs(self.groupList) do
			gSocialChatGroupManager:ResponseChatGroupInvite(v.pid, v.groupId, accept)
		end
	end
end
