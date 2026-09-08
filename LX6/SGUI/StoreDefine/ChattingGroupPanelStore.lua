-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChattingGroupPanelStore.lua
-- Decompiled from: 02087_ChattingGroupPanelStore.lua_93bdf7bba869.luajit

C_ChattingGroupPanelStore = DefClass("C_ChattingGroupPanelStore", C_ChattingGroupPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingGroupPanelStore = C_ChattingGroupPanelStore
local M = C_ChattingGroupPanelStore

M.ctor = function(self)
	self.EDIT_TYPE = {
		["\\xafLB"] = 0,
		["8m\\xbd\\xab\\xb7d"] = 1
	}
end

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.bindData.settingBtn.luaClick = self:CreateAction("OnSettingBtnClick")
	self.bindData.moreBtn.luaClick = self:CreateAction("OnMoreBtnClick")
	self.bindData.inviteFriendBtn.luaClick = self:CreateAction("OnInviteFriendBtnClick")
	self.bindData.teamInviteBtn.luaClick = self:CreateAction("OnTeamInviteBtnClick")
	self.bindData.closeDropBtn.luaClick = self:CreateAction("OnCloseDropBtnClick")
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")
end

M.InitDataOnAwake = function(self)
	self.lastTimestamp = nil
end

M.InitView = function(self)
	M.base.InitView(self)
	self.SetData(self)
	self.SetOnlineNum(self)
	self.SetNormalBtnBar(self)
end

M.OnDisable = function(self)
	for i, timer in pairs(gTeamManager.chatRefreshTimer) do
		if timer then
			timer.Stop(timer)

			timer = nil
		end
	end
end

M.SetOnlineNum = function(self)
	if self.topChannelId ~= gChatTopChannel.Group then
		self.SetGroupMemberNum(self)
	else
		self.SetLinkMemberNum(self)
	end
end

M.SetGroupMemberNum = function(self)
	local data = gChatGroupManager:GetGroupData(self.subChannelId)

	if data and data.Members then
		slot2 = gClientToAvatarDelegate

		slot2:GetPlayerState(data.Members).Callback = function (err, infoList)
			local onlineNum = 0

			for i = 1, infoList.Count do
				if infoList[i] ~= 0 then
					onlineNum = onlineNum + 1
				end
			end

			self.bindData.onlineNum = string.format("%d/%d", onlineNum, infoList.Count)
		end
	end
end

M.SetLinkMemberNum = function(self)
	self.bindData.onlineNum = ""
end

M.BeforeAddMessage = function(self, msg)
	self.TryAddTimestamp(self, msg.timeStamp)
end

M.TryAddTimestamp = function(self, timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp ~= nil or timestamp - lastTimestamp <= 300 then
		self.AddCustomViewItem(self, {
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

M.SetData = function(self)
	self.groupData = gChatGroupManager:GetGroupData(self.subChannelId)
	local headerStore = gStoreManager:GetStoreGroup("ChatHeaderStore"):GetStoreByWidget(self.bindData.chatTopPanel)
	headerStore.name = self:GetName()
	headerStore.icon = 28002104
end

M.GetName = function(self)
	if self.topChannelId ~= gChatTopChannel.Channels then
		if self.subChannelId ~= UX.Game.MessageChannel.PrivateLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901222).Text
		elseif self.subChannelId ~= UX.Game.MessageChannel.PublicLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901221).Text
		elseif self.subChannelId ~= UX.Game.MessageChannel.MatchLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901223).Text
		end
	end

	if self.topChannelId ~= gChatTopChannel.Team then
		return LTConfig.TextScriptTextConfig.GetConfig(89901334).Text
	end

	if self.isCreate then
		self.bindData.isCreate = 1

		return self.groupName
	else
		self.bindData.isCreate = 0

		return self.groupData.Name
	end
end

M.OnSettingBtnClick = function(self)
	gChatUtils.OpenGroupSettingPage(self.groupData)
end

M.OnInviteFriendBtnClick = function(self)
	print_debug("OnInviteFriendBtnClick")
	self.activity:ShowFragment(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.ADD
	})
end

M.SetNormalBtnBar = function(self)
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

M.ScrollToBottom = function(self)
	M.base.ScrollToBottom(self, true)
end

M.OnMoreBtnClick = function(self)
	self.bindData.dropDown = 1
end

M.OnTeamInviteBtnClick = function(self)
	self.bindData.dropDown = 0

	if gInviteManager:IsInviteGroupCD(gInviteManager.TYPE.TEAM, self.subChannelId) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_OperateFrequent)

		return
	end

	if gTeamManager:IsInTeam() then
		if not gTeamManager.allowMemberInvite and not gTeamManager:IsTeamLeader() then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

			return
		end

		gTeamManager:InviteGroupFriendToTeam(self.subChannelId)
		gCS.IMManager:SendInviteTeam(self.topChannelId, self.subChannelId, gTeamManager.teamId, gTeamManager:GetTeamNumber())
	else
		local callBack = function()
			gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				gTeamManager:SyncPlayerCreateTeam(data)
				gTeamManager:InviteGroupFriendToTeam(self.subChannelId)
				gCS.IMManager:SendInviteTeam(self.topChannelId, self.subChannelId, gTeamManager.teamId, gTeamManager:GetTeamNumber())
			end

			return true
		end

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_CheckIfCreatTeam, callBack, nil)
	end
end

M.OnCloseDropBtnClick = function(self)
	self.bindData.dropDown = 0
end
