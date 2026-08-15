local TextCommonTextConfig = LTConfig.TextCommonTextConfig
C_TeamInviteMenuStore = DefClass("C_TeamInviteMenuStore", C_TeamInviteMenuStore, C_StoreGroup)
GroupName2Class.TeamInviteMenuStore = C_TeamInviteMenuStore
local M = C_TeamInviteMenuStore

function M:ctor()
	self.TabData = {
		{
			name = LTConfig.TextScriptTextConfig.GetConfig(89900110).Text
		},
		{
			name = LTConfig.TextScriptTextConfig.GetConfig(89900113).Text
		}
	}
	self.TabType = {
		Channel = 1,
		Friend = 0
	}
	self.SettingType = {
		AutoApplyJoin = 1,
		AllowMemberInvite = 0
	}
	self.SettingName = {
		[self.SettingType.AllowMemberInvite] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamAllowMemberInvite).Text,
		[self.SettingType.AutoApplyJoin] = TextCommonTextConfig.GetConfig(TextCommonTextConfig.TeamAutoApplyJoin).Text
	}
end

function M:OnAwake()
	self.tick = 0
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRenderTabItem")

	function self.bindData.tabList.onGetTIndex(_)
		return 0
	end

	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnChangeTabSelect")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.onGetTIndex = self:CreateAction("OnGetTIndex")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnSettingBtnClick")
	self.bindData.closeSettingBtn.luaClick = self:CreateAction("OnCloseSettingBtnClick")
	self.bindData.settingList.luaSimpleRenderItem = self:CreateAction("OnRenderSettingItem")

	function self.bindData.settingList.onGetTIndex(_)
		return 0
	end

	self.bindData.qBtn.luaClick = self:CreateAction("OnLeftBtnClick")
	self.bindData.eBtn.luaClick = self:CreateAction("OnRightBtnClick")
	local msgEvents = {
		[gEventConstants.TEAM_REFRESH_DATA] = self:CreateAction("OnTeamRefreshData")
	}

	self:RegisterMessageEvents(msgEvents)

	self.groupList = {}
end

function M:OnTeamRefreshData()
	self.bindData.settingList:SetSimpleList(2)
end

function M:OnGetTIndex()
	return self.selectedTabIndex or 0
end

function M:OnEnable()
	self:SetTabData()
	self:InitListData()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:InitListData()
	self.groupList = {}

	if gLinkManager:CheckInLinkMode() then
		local data = {
			isLink = true
		}

		table.insert(self.groupList, data)
	end

	local list = gChatGroupManager:GetChatGroups()

	for i, v in pairs(list) do
		table.insert(self.groupList, v)
	end

	self.friendList = {}

	gFriendManager.cs:GetOrderedFriendList(function (pidList)
		pidList = pidList:ToTable()

		gFriendManager:GetSimplePlayerInfoByPidList(pidList, function (data)
			for _, v in ipairs(data) do
				if not gLinkManager:CheckMemberIsInMatchOrRoom(v.Pid) then
					table.insert(self.friendList, v)
				end
			end
		end)
	end)
end

local TICK_RATE = 10

function M:OnUpdate()
	self.tick = self.tick + 1

	if TICK_RATE <= self.tick then
		self.tick = 0

		self:SetList()
	end
end

function M:SetTabData()
	self.bindData.tabList:SetSimpleList(#self.TabData)
	Timer.New(function ()
		self.bindData.tabList:SetItemSelected(0, true)
	end, 0.2):Start()
end

function M:OnChangeTabSelect()
	self.selectedTabIndex = self.bindData.tabList.selectedIndex

	self:SetList()
end

function M:SetList()
	local count = 0

	if self.selectedTabIndex == self.TabType.Friend then
		if self.friendList then
			count = #self.friendList
		end
	elseif self.friendList then
		count = #self.groupList
	end

	self.bindData.list:SetSimpleList(count)
end

function M:OnRenderTabItem(btn, index)
	local store = gStoreManager:GetStoreGroup("TeamInviteMenuTabTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemData = self.TabData[index + 1]
	store.nameLabel = itemData.name
end

function M:OnRenderItem(btn, index)
	local store, data = nil
	local isFriendTab = self.selectedTabIndex == self.TabType.Friend
	local list = nil

	if isFriendTab then
		store = gStoreManager:GetStoreGroup("TeamInviteMenuFriendTemplateStore"):GetStoreByWidget(btn)
		data = self.friendList[index + 1]

		if not store or not data then
			return
		end

		store.userInfo.pid = data.Pid
		local state = data.OnlineState == UX.Game.PlayerState.Offline and 2 or 0
		store.inviteBtn.luaClick = self:CreateActionWithArgs("OnInviteBtnClick", data.Pid)
		list = gInviteManager:GetInviteFriendList(gInviteManager.TYPE.TEAM)
		store.stateCtl = state

		if gTeamManager:GetMember(data.Pid) then
			store.isInCD = 1
			store.cdTimeLabel = TextCommonTextConfig.GetConfig(TextCommonTextConfig.InTeam).Text

			return
		end
	else
		if not index or not btn then
			return
		end

		store = gStoreManager:GetStoreGroup("TeamGroupInviteTemplateStore"):GetStoreByWidget(btn)
		data = self.groupList[index + 1]

		if not store or not data then
			return
		end

		if index == 0 then
			data.Name = LTConfig.TextScriptTextConfig.GetConfig(89900115).Text
		end

		store.name = data.Name
		store.inviteBtn.luaClick = self:CreateActionWithArgs("OnSendBtnClick", data)
		list = gInviteManager:GetInviteGroupList(gInviteManager.TYPE.TEAM)
	end

	if list then
		local inviteInfo = list[isFriendTab and data.Pid or data.Id]

		if inviteInfo then
			store.isInCD = 1
			local countdown = inviteInfo.stayTime - (gLuaDataManager.serverTime - inviteInfo.timestamp)

			if countdown < inviteInfo.stayTime and countdown > 0 then
				store.cdTimeLabel = math.floor(countdown) .. "s   "
			end
		else
			store.isInCD = 0
		end
	else
		store.isInCD = 0
	end
end

function M:OnRenderSettingItem(btn, index)
	local store = gStoreManager:GetStoreGroup("TeamSettingTemplateStore"):GetStoreByWidget(btn)
	local name = self.SettingName[index]

	if not store or not name then
		return
	end

	store.text = name

	if index == self.SettingType.AllowMemberInvite then
		store.selected = gTeamManager.allowMemberInvite and 1 or 0
	elseif index == self.SettingType.AutoApplyJoin then
		store.selected = gTeamManager.autoApplyJoin and 1 or 0
	end

	if gTeamManager:IsTeamLeader() then
		btn.luaClick = self:CreateActionWithArgs("OnSettingItemClick", index)
	end
end

function M:OnSettingItemClick(type)
	local setting = {}

	if type == self.SettingType.AllowMemberInvite then
		setting.AllowMemberInvite = not gTeamManager.allowMemberInvite
		setting.AutoApplyJoin = gTeamManager.autoApplyJoin
	elseif type == self.SettingType.AutoApplyJoin then
		setting.AllowMemberInvite = gTeamManager.allowMemberInvite
		setting.AutoApplyJoin = not gTeamManager.autoApplyJoin
	end

	gClientToGameDelegate:AskSetTeamSetting(setting).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		gTeamManager.allowMemberInvite = setting.AllowMemberInvite
		gTeamManager.autoApplyJoin = setting.AutoApplyJoin

		self.bindData.settingList:SetSimpleList(2)
	end
end

function M:OnInviteBtnClick(pid)
	gTeamManager:InviteToTeam(pid)
	self:OnCloseBtnClick()
end

function M:OnSendBtnClick(data)
	self:OnCloseBtnClick()

	if not gTeamManager.allowMemberInvite and not gTeamManager:IsTeamLeader() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_HasNoPermissions)

		return
	end

	gTeamManager:InviteGroupFriendToTeam(data.Id)

	if data.isLink then
		gCS.IMManager:SendInviteTeam(gChatTopChannel.Channels, gChatManager:GetLinkChannel(), gTeamManager.teamId, gTeamManager:GetTeamNumber())
	else
		gCS.IMManager:SendInviteTeam(gChatTopChannel.Group, data.Id, gTeamManager.teamId, gTeamManager:GetTeamNumber())
	end

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_InviteSendGroup, nil, nil, data.Name)
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.S_TEAM_INVITE_MENU)
end

function M:OnSettingBtnClick()
	self.bindData.isShowSettingMenu = 1

	self.bindData.settingList:SetSimpleList(2)
end

function M:OnCloseSettingBtnClick()
	self.bindData.isShowSettingMenu = 0
end

function M:OnLeftBtnClick()
	self.bindData.tabList:SelectItem(0)
end

function M:OnRightBtnClick()
	self.bindData.tabList:SelectItem(1)
end
