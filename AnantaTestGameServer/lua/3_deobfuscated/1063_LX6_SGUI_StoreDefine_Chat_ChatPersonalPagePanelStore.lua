C_ChatPersonalPagePanelStore = DefClass("C_ChatPersonalPagePanelStore", C_ChatPersonalPagePanelStore, C_AppFragmentStore)
GroupName2Class.ChatPersonalPagePanelStore = C_ChatPersonalPagePanelStore
local M = C_ChatPersonalPagePanelStore
local MenuConfig = LTConfig.FriendsInteractionMenuConfig

function M:ctor()
	self.TypeCtrl = {
		FriendWithoutRemarkName = 1,
		FriendWithRemarkName = 0,
		MySelf = 2,
		Npc = 3
	}
	self.ListButtonType = {
		Delete = 1,
		Unblock = 3,
		Report = 2,
		Block = 0
	}
	self.InviteTeamBtnType = {
		InTeam = 2,
		InCD = 1,
		Normal = 0
	}
end

function M:OnAwake()
	self.bindData.btm_dropdown_list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.btm_dropdown_list.luaClick = self:CreateAction(self.OnItemClick)
	self.bindData.starBtn.luaClick = self:CreateAction(self.OnStarBtnClick)
	self.bindData.editRemarkNameBtn.luaClick = self:CreateAction(self.OnEditRemarkNameBtnClick)
	self.bindData.editMySignatureBtn.luaClick = self:CreateAction(self.OnEditMySignatureBtnClick)
	self.bindData.btm_inviteOnlineBtn.luaClick = self:CreateAction(self.OnInviteOnlineBtnClick)
	self.bindData.btm_chatBtn.luaClick = self:CreateAction(self.OnChatBtnClick)
	self.bindData.btm_addFriendBtn.luaClick = self:CreateAction(self.OnAddFriendBtnClick)
	self.bindData.btm_showDropdownBtn.luaClick = self:CreateAction(self.OnShowDropdownBtnClick)
	self.bindData.closeDropdownBtn.luaClick = self:CreateAction(self.OnCloseDropdownBtnClick)
	self.bindData.teamInviteBtn.luaClick = self:CreateAction(self.OnTeamInviteBtnClick)
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnShow(_, data)
	self.data = data
	self.noChatBtn = data.noChatBtn

	if data.npcId then
		self.npcId = data.npcId

		self:InitNpcView(data.npcId)

		return
	else
		self.npcId = nil
	end

	self.pid = data.pid
	self.isMySelf = self.pid == gPlayerManager.infoBase.bindData.Pid

	self:InitView()

	if self.isMySelf then
		self:RegisterSingleEvent(gEventConstants.PLAYER_SIGN_CHANGED, self:CreateAction(self.OnPlayerSignChanged))
	end

	self:InitTeamData()
end

function M:InitTeamData()
	self:StartRefreshTimer()

	gClientToGameDelegate:AskQueryTeamInfoByPid(self.pid).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			return
		end

		self.teamData = data
	end
end

function M:InitView()
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

		if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
			if not table.isNilOrEmpty(gLinkManager.LinkMemberInfo[self.pid]) then
				self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendSameLink)
			else
				gFriendManager:GetSimplePlayerInfo(self.pid, function (info)
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

function M:UpdateLinkState(linkMode)
	if linkMode == UX.Game.LinkMode.Private then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendLinked)
	elseif linkMode == UX.Game.LinkMode.Public then
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendPublicLink)
	else
		self.menuConfig = MenuConfig.GetConfig(MenuConfig.FriendSingle)
	end

	self:RefreshPageBtns()
end

function M:RefreshPageBtns()
	self.bindData.btm_chatBtn:SetActive(self.menuConfig.Chat and not self.noChatBtn)
	self.bindData.btm_inviteOnlineBtn:SetActive(self.menuConfig.Link)
	self.bindData.btm_addFriendBtn:SetActive(self.menuConfig.AddFriend)
	self.bindData.teamInviteBtn:SetActive(gLinkManager:CheckInLinkMode())
	self:RefreshTeamBtn()
	self:SetDropdownList()
end

function M:RefreshTeamBtn()
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

function M:InitFriendNameAndType()
	local remarkName = gFriendManager:GetFriendRemarkName(self.pid)

	if remarkName then
		self.bindData.typeCtrl = self.TypeCtrl.FriendWithRemarkName
		self.bindData.name = remarkName
		self.bindData.origName = ""

		gFriendManager:GetSimplePlayerInfo(self.pid, function (info)
			self.bindData.origName = info.Name
		end)
	else
		self.bindData.typeCtrl = self.TypeCtrl.FriendWithoutRemarkName
		self.bindData.name = ""

		gFriendManager:GetSimplePlayerInfo(self.pid, function (info)
			self.bindData.name = info.Name
		end)
	end
end

function M:SetIsSpecialFriend(isSpecialFriend)
	self.isSpecialFriend = isSpecialFriend
	self.bindData.starBtnCtrl = isSpecialFriend and 1 or 0
end

function M:OnStarBtnClick()
	local function Callback(err)
		if err == LTConfig.MessageConfig.Ok then
			self:SetIsSpecialFriend(not self.isSpecialFriend)
		end
	end

	if self.isSpecialFriend then
		gFriendManager:RemoveFromSpecialList(self.pid, Callback)
	else
		gFriendManager:AddToSpecialList(self.pid, Callback)
	end
end

function M:OnEditRemarkNameBtnClick()
	self.activity:ShowFragment(gChatConst.TabShowType.EditRemarkName, {
		targetPid = self.pid,
		closeCallback = self:CreateAction(self.InitView)
	})
end

function M:OnEditMySignatureBtnClick()
	self.activity:ShowFragment(gChatConst.TabShowType.EditPersonalNote)
end

function M:OnInviteOnlineBtnClick()
	gLinkManager:InviteFriendToLink(self.pid, gLinkManager.LinkMode)
end

function M:OnChatBtnClick()
	if self.npcId then
		gChatManager:GetOrAddSubChannel(gChatTopChannel.Npc, self.npcId)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Npc, self.npcId)
	elseif self.pid then
		gChatManager:GetOrAddSubChannel(gChatTopChannel.Friend, self.pid)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Friend, self.pid)
	end
end

function M:OnAddFriendBtnClick()
	gFriendManager:ApplyFriend(self.pid)
end

function M:OnShowDropdownBtnClick()
	self.bindData.dropdownCtrl = 1

	self.bindData.closeDropdownBtn:SetActive(true)
end

function M:OnCloseDropdownBtnClick()
	self.bindData.dropdownCtrl = 0

	self.bindData.closeDropdownBtn:SetActive(false)
end

function M:SetDropdownList()
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

	self.bindData.btm_dropdown_list:SetList(itemList)
end

function M:OnRenderItem(btn, _, data)
	btn:TryChangePage("type", data.type, true)
end

function M:OnItemClick(btn, data)
	if data.type == self.ListButtonType.Block then
		self:AddToBlackList()
	elseif data.type == self.ListButtonType.Unblock then
		gFriendManager:RemoveFromBlackList(self.pid, self:CreateAction(self.InitView))
	elseif data.type == self.ListButtonType.Delete then
		gFriendManager:DeleteFriend(self.pid, self:CreateAction(self.InitView))
	elseif data.type ~= self.ListButtonType.Report then
		print_error("OnItemClick: unknown type:", data.type, data)
	end

	self:OnCloseDropdownBtnClick()
end

function M:AddToBlackList()
	gMainPhoneUtils.ShowFrontContent({
		showType = gClientConst.MAIN_PHONE_FRONT_SHOW_TYPE.ConfirmMessageBox,
		description = LTConfig.TextScriptTextConfig.GetConfig(89901186).Text,
		onConfirmCallback = function ()
			gFriendManager:AddToBlackList(self.pid, self:CreateAction(self.InitView))
		end
	})
end

function M:OnPlayerSignChanged(_, sign)
	self.bindData.signature = sign
end

function M:InitNpcView(npcId)
	self.bindData.typeCtrl = self.TypeCtrl.Npc

	self.bindData.btm_chatBtn:SetActive(not self.noChatBtn)
	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Npc, npcId, self.bindData.avatar)

	local info = gDialogMainChatManager:GetNpcChatInfo(npcId)
	self.bindData.name = info:GetName()
	self.bindData.signature = info:GetSignature()
end

function M:OnTeamInviteBtnClick()
	if gTeamManager:IsInTeamByPid(self.pid) then
		return
	end

	if gInviteManager:IsInviteFriendCD(gInviteManager.TYPE.TEAM, self.pid) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_OperateFrequent)

		return
	end

	if self.teamData and self.teamData.TeamId then
		gTeamManager:AskApplyToTeam(self.teamData.TeamId)
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YouAlreadySendApply)

		return
	end

	if gTeamManager:IsInTeam() then
		gTeamManager:InviteToTeam(self.pid)
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Team_YouAlreadySendInvite)
	else
		local function callBack()
			gClientToGameDelegate:AskCreateTeam().Callback = function (err, data)
				if err ~= LTConfig.MessageConfig.Ok then
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

function M:StartRefreshTimer()
	self.waitTimer = Timer.New(function ()
		if gTeamManager:IsInTeam() then
			self:RefreshTeamBtn()
		end
	end, 1, -1):Start()
end
