C_ChattingGroupPanelStore = DefClass("C_ChattingGroupPanelStore", C_ChattingGroupPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingGroupPanelStore = C_ChattingGroupPanelStore
local M = C_ChattingGroupPanelStore

function M:ctor()
	self.EDIT_TYPE = {
		ADD = 0,
		DELETE = 1
	}
end

function M:OnAwake()
	M.base.OnAwake(self)

	self.bindData.settingBtn.luaClick = self:CreateAction("OnSettingBtnClick")
	self.bindData.moreBtn.luaClick = self:CreateAction("OnMoreBtnClick")
	self.bindData.inviteFriendBtn.luaClick = self:CreateAction("OnInviteFriendBtnClick")
	self.bindData.teamInviteBtn.luaClick = self:CreateAction("OnTeamInviteBtnClick")
	self.bindData.closeDropBtn.luaClick = self:CreateAction("OnCloseDropBtnClick")
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")
end

function M:InitDataOnAwake()
	self.lastTimestamp = nil
end

function M:InitView()
	M.base.InitView(self)
	self:SetData()
	self:SetOnlineNum()
	self:SetNormalBtnBar()
end

function M:OnDisable()
	for i, timer in pairs(gTeamManager.chatRefreshTimer) do
		if timer then
			timer:Stop()

			timer = nil
		end
	end
end

function M:SetOnlineNum()
	if self.topChannelId == gChatTopChannel.Group then
		self:SetGroupMemberNum()
	else
		self:SetLinkMemberNum()
	end
end

function M:SetGroupMemberNum()
	local data = gChatGroupManager:GetGroupData(self.subChannelId)

	if data and data.Members then
		gClientToAvatarDelegate:GetPlayerState(data.Members).Callback = function (err, infoList)
			local onlineNum = 0

			for i = 1, infoList.Count do
				if infoList[i] == 0 then
					onlineNum = onlineNum + 1
				end
			end

			self.bindData.onlineNum = string.format("%d/%d", onlineNum, infoList.Count)
		end
	end
end

function M:SetLinkMemberNum()
	self.bindData.onlineNum = ""
end

function M:BeforeAddMessage(msg)
	self:TryAddTimestamp(msg.timeStamp)
end

function M:TryAddTimestamp(timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp == nil or timestamp - lastTimestamp > 300 then
		self:AddCustomViewItem({
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

function M:SetData()
	self.groupData = gChatGroupManager:GetGroupData(self.subChannelId)
	local headerStore = gStoreManager:GetStoreGroup("ChatHeaderStore"):GetStoreByWidget(self.bindData.chatTopPanel)
	headerStore.name = self:GetName()
	headerStore.icon = 28002104
end

function M:GetName()
	if self.topChannelId == gChatTopChannel.Channels then
		if self.subChannelId == UX.Game.MessageChannel.PrivateLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901222).Text
		elseif self.subChannelId == UX.Game.MessageChannel.PublicLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901221).Text
		elseif self.subChannelId == UX.Game.MessageChannel.MatchLink then
			return LTConfig.TextScriptTextConfig.GetConfig(89901223).Text
		end
	end

	if self.topChannelId == gChatTopChannel.Team then
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

function M:OnSettingBtnClick()
	gChatUtils.OpenGroupSettingPage(self.groupData)
end

function M:OnInviteFriendBtnClick()
	print_debug("OnInviteFriendBtnClick")
	self.activity:ShowFragment(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.ADD
	})
end

function M:SetNormalBtnBar()
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

function M:ScrollToBottom()
	M.base.ScrollToBottom(self, true)
end

function M:OnMoreBtnClick()
	self.bindData.dropDown = 1
end

function M:OnTeamInviteBtnClick()
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
		local function callBack()
			gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
				if err ~= LTConfig.MessageConfig.Ok then
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

function M:OnCloseDropBtnClick()
	self.bindData.dropDown = 0
end
