-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatPersonalPagePanelStore.lua
-- Decompiled from: 01906_ChatPersonalPagePanelStore.lua_3c6c7d00e7dd.luajit

C_ChatPersonalPagePanelStore = DefClass("C_ChatPersonalPagePanelStore", C_ChatPersonalPagePanelStore, C_AppFragmentStore)
GroupName2Class.ChatPersonalPagePanelStore = C_ChatPersonalPagePanelStore
local M = C_ChatPersonalPagePanelStore
local MenuConfig = LTConfig.FriendsInteractionMenuConfig

M.ctor = function(self)
	self.TypeCtrl = {
		["\\xd8V\\x89\\xeb'\\x9e,G\\xd819\\xf7aܺ\\xb8K\\xa5MS\\xba\\xc3"] = 1,
		["\\xa4=\\xe4\\xb9],\\xf1R\\xc0\\xdc&VN\\xc1\\xbd\\xc6"] = 0,
		["1Q\\xa2\\x8b\\x8fG"] = 2,
		["\\xa0xe"] = 3
	}
	self.ListButtonType = {
		["8M\\x9d\\x8b\\x97D"] = 1,
		["\\xec\\xd5'\\xfa"] = 3,
		[".M\\x81\\x81\\x91U"] = 2,
		["o\\xa2\\xad\\xac\\xbd"] = 0
	}
	self.InviteTeamBtnType = {
		["5F\\xa5\\x8b\\x82L"] = 2,
		["S,^"] = 1,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.OnAwake = function(self)
	self.bindData.btm_dropdown_list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)
	self.bindData.btm_dropdown_list.luaSimpleClick = self.CreateAction(self, self.OnItemClick)
	self.bindData.starBtn.luaClick = self.CreateAction(self, self.OnStarBtnClick)
	self.bindData.editRemarkNameBtn.luaClick = self.CreateAction(self, self.OnEditRemarkNameBtnClick)
	self.bindData.editMySignatureBtn.luaClick = self.CreateAction(self, self.OnEditMySignatureBtnClick)
	self.bindData.btm_inviteOnlineBtn.luaClick = self.CreateAction(self, self.OnInviteOnlineBtnClick)
	self.bindData.btm_chatBtn.luaClick = self.CreateAction(self, self.OnChatBtnClick)
	self.bindData.btm_addFriendBtn.luaClick = self.CreateAction(self, self.OnAddFriendBtnClick)
	self.bindData.btm_showDropdownBtn.luaClick = self.CreateAction(self, self.OnShowDropdownBtnClick)
	self.bindData.closeDropdownBtn.luaClick = self.CreateAction(self, self.OnCloseDropdownBtnClick)
	self.bindData.teamInviteBtn.luaClick = self.CreateAction(self, self.OnTeamInviteBtnClick)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, _, data)
	self.data = data
	self.noChatBtn = data.noChatBtn

	if data.npcId then
		self.npcId = data.npcId

		self.InitNpcView(self, data.npcId)

		return
	else
		self.npcId = nil
	end

	self.pid = data.pid
	self.isMySelf = self.pid ~= gPlayerManager.infoBase.bindData.Pid

	self:InitView()

	if self.isMySelf then
		self.RegisterSingleEvent(self, gEventConstants.PLAYER_SIGN_CHANGED, self.CreateAction(self, self.OnPlayerSignChanged))
	end

	self.InitTeamData(self)
end

M.InitTeamData = function(self)
	self:StartRefreshTimer()

	slot1 = gClientToGameDelegate

	slot1:AskQueryTeamInfoByPid(self.pid).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self.teamData = data
	end
end

M.InitView = function(self)
	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Friend, self.pid, self.bindData.avatar)

	if self.isMySelf then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.Myself)
		self.bindData.typeCtrl = self.TypeCtrl.MySelf
		self.bindData.name = gPlayerManager.infoLogin.bindData.name
		self.bindData.signature = gChatUtils.GetMySignature()

		return
	end

	if gFriendManager:IsInBlackList(self.pid) then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.Blacklist)
	elseif not gFriendManager:IsFriend(self.pid) then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.Stranger)
	else
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.Friend)

		if gLinkManager.LinkMode == UX.Game.LinkMode.None then
			if not table.isNilOrEmpty(gLinkManager.LinkMemberInfo[self.pid]) then
				self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendSameLink)
			else
				slot1 = gFriendManager

				slot1:GetSimplePlayerInfo(self.pid, function (info)
					self:UpdateLinkState(info.LinkMode)
				end, true, true)
			end
		end
	end

	self:InitFriendNameAndType()
	self:SetIsSpecialFriend(gFriendManager:IsSpecialFriend(self.pid))
	gChatUtils.GetPlayerSignature(self.pid, function (signature)
		self.bindData.signature = signature
	end, LTConfig.NPCChatConfig.DefaultPlayerSignature)
	self:OnCloseDropdownBtnClick()
	self:RefreshPageBtns()
end

M.UpdateLinkState = function(self, linkMode)
	if linkMode ~= UX.Game.LinkMode.Private then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendLinked)
	elseif linkMode ~= UX.Game.LinkMode.Public then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendPublicLink)
	else
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendSingle)
	end

	self.RefreshPageBtns(self)
end

M.RefreshPageBtns = function(self)
	self.bindData.btm_chatBtn:SetActive(self.menuConfig.Chat and not self.noChatBtn)
	self.bindData.btm_inviteOnlineBtn:SetActive(self.menuConfig.Link)
	self.bindData.btm_addFriendBtn:SetActive(self.menuConfig.AddFriend)
	self.bindData.teamInviteBtn:SetActive(gLinkManager:CheckInLinkMode())
	self:RefreshTeamBtn()
	self:SetDropdownList()
end

M.RefreshTeamBtn = function(self)
	if gTeamManager:IsInTeamByPid(self.pid) then
		self.bindData.inviteTeamBtnType = self.InviteTeamBtnType.InTeam

		return
	end

	if gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, self.pid) and not gTeamManager:CheckIdRejected(self.pid) then
		self.bindData.inviteTeamBtnType = self.InviteTeamBtnType.InCD

		return
	end

	self.bindData.inviteTeamBtnType = self.InviteTeamBtnType.Normal
end

M.InitFriendNameAndType = function(self)
	local remarkName = gFriendManager:GetFriendRemarkName(self.pid)

	if remarkName then
		self.bindData.typeCtrl = self.TypeCtrl.FriendWithRemarkName
		self.bindData.name = remarkName
		self.bindData.origName = ""
		slot2 = gFriendManager

		slot2:GetSimplePlayerInfo(self.pid, function (info)
			self.bindData.origName = info.Name
		end)
	else
		self.bindData.typeCtrl = self.TypeCtrl.FriendWithoutRemarkName
		self.bindData.name = ""
		slot2 = gFriendManager

		slot2:GetSimplePlayerInfo(self.pid, function (info)
			self.bindData.name = info.Name
		end)
	end
end

M.SetIsSpecialFriend = function(self, isSpecialFriend)
	self.isSpecialFriend = isSpecialFriend
	self.bindData.starBtnCtrl = isSpecialFriend and 1 or 0
end

M.OnStarBtnClick = function(self)
	local Callback = function(err)
		if err ~= LTConfig.MessageConfig.Ok then
			self:SetIsSpecialFriend(not self.isSpecialFriend)
		end
	end

	if self.isSpecialFriend then
		gFriendManager:RemoveFromSpecialList(self.pid, Callback)
	else
		gFriendManager:AddToSpecialList(self.pid, Callback)
	end
end

M.OnEditRemarkNameBtnClick = function(self)
	self.activity:ShowFragment(gChatConst.TabShowType.EditRemarkName, {
		targetPid = self.pid,
		closeCallback = self:CreateAction(self.InitView)
	})
end

M.OnEditMySignatureBtnClick = function(self)
	self.activity:ShowFragment(gChatConst.TabShowType.EditPersonalNote)
end

M.OnInviteOnlineBtnClick = function(self)
	gLinkManager:InviteFriendToLink(self.pid, gLinkManager.LinkMode)
end

M.OnChatBtnClick = function(self)
	if self.npcId then
		gChatManager:GetOrAddSubChannel(gChatTopChannel.Npc, self.npcId)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Npc, self.npcId)
	elseif self.pid then
		gChatManager:GetOrAddSubChannel(gChatTopChannel.Friend, self.pid)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Friend, self.pid)
	end
end

M.OnAddFriendBtnClick = function(self)
	gFriendManager:ApplyFriend(self.pid)
end

M.OnShowDropdownBtnClick = function(self)
	self.bindData.dropdownCtrl = 1

	self.bindData.closeDropdownBtn:SetActive(true)
end

M.OnCloseDropdownBtnClick = function(self)
	self.bindData.dropdownCtrl = 0

	self.bindData.closeDropdownBtn:SetActive(false)
end

M.SetDropdownList = function(self)
	local itemList = {}

	if self.menuConfig.Block then
		table.insert(itemList, {
			type = self.ListButtonType.Block
		})
	end

	if self.menuConfig.Unblock then
		table.insert(itemList, {
			type = self.ListButtonType.Unblock
		})
	end

	if self.menuConfig.DeleteFriend then
		table.insert(itemList, {
			type = self.ListButtonType.Delete
		})
	end

	if self.menuConfig.Report then
		table.insert(itemList, {
			type = self.ListButtonType.Report
		})
	end

	self._dropdownListData = itemList

	self.bindData.btm_dropdown_list:SetSimpleList(#itemList)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._dropdownListData[index + 1]

	btn.TryChangePage(btn, "type", data.type, true)
end

M.OnItemClick = function(self, btn, index)
	local data = self._dropdownListData[index + 1]

	if data.type ~= self.ListButtonType.Block then
		self.AddToBlackList(self)
	elseif data.type ~= self.ListButtonType.Unblock then
		gFriendManager:RemoveFromBlackList(self.pid, self:CreateAction(self.InitView))
	elseif data.type ~= self.ListButtonType.Delete then
		gFriendManager:DeleteFriend(self.pid, self:CreateAction(self.InitView))
	elseif data.type == self.ListButtonType.Report then
		print_error("OnItemClick: unknown type:", data.type, data)
	end

	self.OnCloseDropdownBtnClick(self)
end

M.AddToBlackList = function(self)
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextScriptTextConfig.GetConfig(89901186).Text,
		onConfirmCallback = function ()
			gFriendManager:AddToBlackList(self.pid, self:CreateAction(self.InitView))
		end
	})
end

M.OnPlayerSignChanged = function(self, _, sign)
	self.bindData.signature = sign
end

M.InitNpcView = function(self, npcId)
	self.bindData.typeCtrl = self.TypeCtrl.Npc

	self.bindData.btm_chatBtn:SetActive(not self.noChatBtn)
	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Npc, npcId, self.bindData.avatar)

	local info = gDialogMainChatManager:GetNpcChatInfo(npcId)
	self.bindData.name = info:GetName()
	self.bindData.signature = info:GetSignature()
end

M.OnTeamInviteBtnClick = function(self)
	if gTeamManager:IsInTeamByPid(self.pid) then
		return
	end

	if gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, self.pid) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_OperateFrequent)

		return
	end

	if self.teamData and self.teamData.TeamId then
		gTeamManager:AskApplyToTeam(self.teamData.TeamId)

		return
	end

	if gTeamManager:IsInTeam() then
		gTeamManager:InviteToTeam(self.pid)
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YouAlreadySendInvite)
	else
		local callBack = function()
			gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end

				gTeamManager:SyncPlayerCreateTeam(data)
				gTeamManager:InviteToTeam(self.pid)
			end

			return true
		end

		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_CheckIfCreatTeam, callBack, nil)
	end
end

M.StartRefreshTimer = function(self)
	self.waitTimer = Timer.New(function ()
		if gTeamManager:IsInTeam() then
			self:RefreshTeamBtn()
		end
	end, 1, -1):Start()
end
