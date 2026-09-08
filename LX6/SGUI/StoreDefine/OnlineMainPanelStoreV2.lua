-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineMainPanelStoreV2.lua
-- Decompiled from: 01125_OnlineMainPanelStoreV2.lua_468b8120f2bb.luajit

local MessageConfig = LTConfig.MessageConfig
local LinkMode = UX.Game.LinkMode
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local LinkConfig = LTConfig.LinkConfig
local GameInputManager = LX6.Manager.GameInputManager
C_OnlineMainPanelStoreV2 = DefClass("C_OnlineMainPanelStoreV2", C_OnlineMainPanelStoreV2, C_StoreGroup)
GroupName2Class.OnlineMainPanelStoreV2 = C_OnlineMainPanelStoreV2
local M = C_OnlineMainPanelStoreV2

M.ctor = function(self)
	self.MAX_SHORT_MEMBER = 5
	self.DAY = 86400
	self.KICK_REFRESH_INTERVAL = 5
end

M.DefineAllVariables = function(self)
	self.linkMgr = gLinkManager
	self.currentSelectedOtherMode = nil
	self.lastMode = nil
	self.isCreatingPrivate = false
	self.lastKickCheckTime = 0
	self.selfAvatarStore = nil
	self.ScrollWheel = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.leftPanelStateEnum = {
		["Z\\x94\\x8f\\x97D"] = 2,
		["A\\x9f\\x89\\x8fD"] = 0,
		["v+sP"] = 1
	}
	self.rightPanelStateEnum = {
		["F\\x87\\x87\\x97D"] = 1,
		["^_ÿ\\x81\\x94\r\\xda\\xfc"] = 2,
		["LSdl\\3="] = 0
	}
	self.friendsCtrlEnum = {
		["r#k^"] = 0,
		[""] = 1
	}
	self.isLastEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.leftPanelStateEnum = nil
	self.rightPanelStateEnum = nil
	self.friendsCtrlEnum = nil
	self.isLastEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)

	self.ScrollWheel = self.CreateAction(self, "OnMouseScrollWheel")
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnUpdate = function(self)
	if self.linkMgr.LinkMode == LinkMode.Private then
		return
	end

	local now = gCS.TimeManager.ServerUnixTime or 0

	if now - self.lastKickCheckTime >= self.KICK_REFRESH_INTERVAL then
		return
	end

	self.lastKickCheckTime = now
	local list = self.bindData.currentMemberDetailList

	if list then
		list.RefreshList(list)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.rightPanelState = self.rightPanelStateEnum.otherMode

	self.InitSelfAvatar(self)
	self.RefreshPage(self)
	self.InitButton(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
	end
end

M.InitButton = function(self)
	local buttonNode = self.rootWidget.transform:Find("OtherModePanel/S_BlueCommonBtn")

	if buttonNode then
		self.confirmButton = buttonNode.GetComponent(buttonNode, "UButton")
	end
end

M.OnClose = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.ScrollWheel)
	end
end

M.OnActiveDeviceChange = function(self, device)
	self.TryFocusModeListItem(self)
end

M.TryFocusModeListItem = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if gCS.LuaUtils.GetActiveDevice() < SGUI.GameDevice.KeyboardMouse then
		return
	end

	if self.bindData.rightPanelState == self.rightPanelStateEnum.otherMode then
		return
	end

	if not self.otherLinkModeDatas or #self.otherLinkModeDatas ~= 0 then
		return
	end

	local index = self.bindData.modeList.selectedIndex

	if index >= 0 then
		return
	end

	local btn = self.bindData.modeList:GetChildAt(index)

	if not gClientUtils.NotNil(btn) then
		return
	end

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.mainNavi
	self.bindData.mainNavi.CurrentActiveContent = btn
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_MODE_CHANGE] = self.CreateAction(self, "RefreshPage"),
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, "OnLinkMemberInfoChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.modeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderModeListItem")

	self.bindData.modeList.onGetTIndex = function()
		return 0
	end

	self.bindData.modeList.luaSelectedChanged = self.CreateAction(self, "OnOtherModeSelectChanged")
	self.bindData.currentMemberList.onGetTIndex = self.CreateAction(self, "OnGetCurrentMemberShortListTIndex")
	self.bindData.currentMemberList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMemberInfo")

	self.bindData.currentMemberDetailList.onGetTIndex = function()
		return 0
	end

	self.bindData.currentMemberDetailList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMemberDetailInfo")
	self.bindData.onGotoLinkMode = self.CreateAction(self, "OnConfirmLinkMode")
	self.bindData.onExit = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.onInviteBtn = self.CreateAction(self, "OnInviteMemberBtnClick")
	self.bindData.onShowMembers = self.CreateAction(self, "OnShowMembersBtnClick")
	self.bindData.onMemberListExit = self.CreateAction(self, "OnMemberListExit")
	self.bindData.infoTipsBtn = self.CreateAction(self, "OnInfoTipsBtnClick")
end

M.OnLinkMemberInfoChange = function(self)
	if self.bindData.linkMode ~= UX.Game.LinkMode.None then
		return
	end

	self.RefreshPage(self)
end

M.RefreshPage = function(self)
	self:RefreshOtherModeData()
	self:RefreshCurrentLinkModeInfo()
	self.linkMgr:GetCurrentLinkInfo(function ()
		if not self.STATE_OnShowOnce then
			return
		end

		self:RefreshCurrentMemberData()
	end)
	self:RefreshCurrentMemberData()
	self:RefreshInviteFriendList()
	self:RefreshSelfAvatar()
end

M.RefreshCurrentLinkModeInfo = function(self)
	self.bindData.currentModeName = self.linkMgr:GetLinkModeName()
end

M.InitSelfAvatar = function(self)
	self.bindData.userInfo.pid = gPlayerManager.infoLogin.bindData.pid

	if self.selfAvatarStore then
		return
	end

	local widget = self.bindData.selfAvatar

	if not gClientUtils.NotNil(widget) then
		return
	end

	local group = gStoreManager:GetStoreGroup("CommonAccountAvatarStore")

	if not group then
		return
	end

	self.selfAvatarStore = group.GetStoreByWidget(group, widget)

	widget.luaRenderTooltip = function(btn, tooltip, _)
		local store = self.selfAvatarStore

		if store and store.userInfoLight and store.userInfoLight.pid == 0 then
			gSocialPalyerTooltipManager:OnRenderToolTips(store.userInfoLight.pid, btn, tooltip, _)
		else
			btn.CloseTooltip(btn)
		end
	end
end

M.RefreshSelfAvatar = function(self)
	local store = self.selfAvatarStore

	if not store then
		return
	end

	store.userInfoLight.pid = gPlayerManager.infoLogin.bindData.pid
	store.isSelfCtrl = 1
	store.isEmptyCtrl = 0
end

M.OnConfirmLinkMode = function(self)
	if self.bindData.modeList.selectedIndex >= 0 then
		return
	end

	local data = self.otherLinkModeDatas[self.bindData.modeList.selectedIndex + 1]

	if not data or not data.mode then
		return
	end

	if data.mode ~= LinkMode.Private and not self.linkMgr.LinkData[data.mode] then
		if not gLuaDataManager.isNetworkAvailable then
			return
		end

		gLinkManager:RPC_AskSwitchLinkMode(LinkMode.Private, true)

		return
	end

	self.linkMgr:EnterLink(data.mode)
	gPanelManager:Close(gPanelId.S_ONLINE_MAIN_PANEL_V2)
end

M.OnExitBtnClick = function(self)
	if self.bindData.showMemberList ~= 1 then
		self.bindData.showMemberList = 0
	end

	gPanelManager:Close(gPanelId.S_ONLINE_MAIN_PANEL_V2)
end

M.OnInviteMemberBtnClick = function(self)
	self.bindData.rightPanelState = self.rightPanelStateEnum.invite

	gPanelManager:CheckShow(gPanelId.S_TEAM_INVITE_MENU, {
		inviteMode = gInviteManager.TYPE.LINK,
		closeCallback = function ()
			if gPanelManager:IsPanelShowing(gPanelId.S_ONLINE_MAIN_PANEL_V2) then
				self:OnInviteMenuExit()
			end
		end
	})
end

M.OnInviteMenuExit = function(self)
	if self.isCreatingPrivate then
		self.isCreatingPrivate = false
		self.bindData.leftPanelState = self.linkMgr.LinkMode ~= LinkMode.None and self.leftPanelStateEnum.single or self.leftPanelStateEnum.link
	end

	self.bindData.rightPanelState = self.rightPanelStateEnum.otherMode

	self.TryFocusModeListItem(self)
end

M.OnMemberListExit = function(self)
	self.bindData.rightPanelState = self.rightPanelStateEnum.otherMode

	self.TryFocusModeListItem(self)
end

M.OnInviteAllBtnClick = function(self)
	local mode = self.isCreatingPrivate and LinkMode.Private or self.linkMgr.LinkMode

	for _, v in ipairs(self.friendToInviteList) do
		self.linkMgr:InviteFriendToLink(v.Pid, mode)
	end
end

M.OnShowMembersBtnClick = function(self)
	self.bindData.rightPanelState = self.rightPanelStateEnum.memberList
end

M.OnInfoTipsBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_INFO_PANEL, {
		id = LTConfig.MessageExplainConfig.OnlineAppExplain
	})
end

M.RefreshInviteFriendList = function(self)
	if self.bindData.rightPanelState == self.rightPanelStateEnum.invite then
		return
	end

	local targetMode = self.isCreatingPrivate and LinkMode.Private or self.linkMgr.LinkMode

	gFriendManager:GetOrderedFriendSimpleInfoList(function (data)
		self.friendToInviteList = {}

		for _, v in ipairs(data) do
			local shouldExclude = nil
			shouldExclude = (targetMode == LinkMode.Public or gLinkManager:GetPlayerInLink(v.Pid, LinkMode.Public)) and v.LinkMode ~= targetMode

			if not gLinkManager:CheckMemberIsInMatchOrRoom(v.Pid) and not shouldExclude then
				table.insert(self.friendToInviteList, v)
			end
		end

		self:RefreshInviteList()
	end)
end

M.RefreshInviteList = function(self)
	local count = #self.friendToInviteList
	self.bindData.friendsCtrl = count <= 0 and self.friendsCtrlEnum.have or self.friendsCtrlEnum.no

	self.bindData.inviteList:SetSimpleList(count)
end

M.OnRenderInviteListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("TeamInviteMenuFriendTemplateStore"):GetStoreByWidget(btn)
	local data = self.friendToInviteList[index + 1]

	if not store or not data then
		return
	end

	store.userInfo.pid = data.Pid
	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs(gInviteManager.OnInvitePlayerRenderTooltips, data.Pid, gInviteManager)
	store.stateCtl = data.OnlineState ~= UX.Game.PlayerState.Offline and 2 or 0
	store.inviteBtn.luaClick = self:CreateActionWithArgs("OnInviteFriendBtnClick", data.Pid)

	if gTeamManager:GetMember(data.Pid) then
		store.isInCD = 1
		store.cdTimeLabel = TextCommonTextConfig.GetConfig(TextCommonTextConfig.InTeam).Text

		return
	end

	store.isInCD = 0
end

M.OnInviteFriendBtnClick = function(self, pid, btn, index)
	if self.isCreatingPrivate then
		self.linkMgr:InviteFriendToLink(pid, LinkMode.Private)

		return
	end

	self.linkMgr:InviteFriendToLink(pid, self.linkMgr.LinkMode)
end

M.OnRenderMemberDetailInfo = function(self, btn, index)
	local data = self.curMemberList[index + 1]
	local store = gStoreManager:GetStoreGroup("OnlineMemberListPlayerTemplate"):GetStoreByWidget(btn)
	store.commonAccount.pid = data.pid
	local avatarStore = gStoreManager:GetStoreGroup("S_CommonAccountAvatarMiddle1Store"):GetStoreByWidget(store.headBtn)

	if avatarStore then
		avatarStore.userInfo.pid = data.pid
	end

	store.headBtn.luaRenderTooltip = self:CreateActionWithArgs(gInviteManager.OnInvitePlayerRenderTooltips, data.pid, gInviteManager)
	local memberInfo = self.linkMgr.LinkMember[data.pid]
	local isOnline = memberInfo and memberInfo.OnlineState == UX.Game.PlayerState.Offline
	store.isOnline = isOnline and 1 or 0

	if self.linkMgr.LinkMode == LinkMode.Private then
		store.btnType = 0
	elseif data.pid ~= gPlayerManager.infoLogin.bindData.pid then
		store.btnType = 1

		store.onQuitBtn = function()
			gLinkManager:RPC_AskLeaveLink(LinkMode.Private)
		end
	elseif not isOnline then
		local timeBeforeCanKick = self.DAY * LinkConfig.UnlinkMemberGetOutTime
		local timeAfterLogout = memberInfo and gCS.TimeManager.ServerUnixTime - memberInfo.LastLogoutTime or 0

		if timeBeforeCanKick >= timeAfterLogout then
			store.btnType = 2
			store.onKickBtn = self.CreateActionWithArgs(self, "OnKickMemberBtnClick", data.pid)
		else
			store.btnType = 0
		end
	else
		store.btnType = 0
	end
end

M.OnKickMemberBtnClick = function(self, pid)
	slot2 = gLinkManager

	slot2:LinkKickOut(pid, function ()
		self:RefreshPage()
	end)
end

M.RefreshCurrentMemberData = function(self)
	local mode = self.linkMgr.LinkMode

	if self.bindData.leftPanelState == self.leftPanelStateEnum.create then
		self.bindData.leftPanelState = mode ~= LinkMode.None and self.leftPanelStateEnum.single or self.leftPanelStateEnum.link
	end

	self.curMemberList = {}

	for k, v in pairs(self.linkMgr.LinkMemberState) do
		if v ~= mode then
			local index = self.linkMgr.LinkMemberIndex[v][k]

			if index then
				local ele = {
					index = index,
					pid = k
				}

				table.insert(self.curMemberList, ele)
			end
		end
	end

	table.sort(self.curMemberList, function (a, b)
		return a.index <= b.index
	end)
	self.bindData.currentMemberDetailList:SetSimpleList(#self.curMemberList)
	self.bindData.currentMemberDetailList:RefreshList()
	self:RefreshShortCurrentMemberList()
end

M.RefreshShortCurrentMemberList = function(self)
	local count = #self.curMemberList
	local cap = self.linkMgr:GetMaxPlayerNum(self.linkMgr.LinkMode)
	self.bindData.memberCount = count .. "/" .. cap
	self.shortListCount = 0
	self.hasAddMemberIcon = true

	if cap < count then
		self.hasAddMemberIcon = false

		if self.MAX_SHORT_MEMBER < count then
			self.shortListCount = self.MAX_SHORT_MEMBER
		else
			self.shortListCount = count
		end
	elseif count >= self.MAX_SHORT_MEMBER then
		self.shortListCount = count + 1
	else
		self.shortListCount = self.MAX_SHORT_MEMBER
	end

	self.bindData.currentMemberList:SetSimpleList(self.shortListCount)
	self.bindData.currentMemberList:RefreshList()
end

M.OnGetCurrentMemberShortListTIndex = function(self, index)
	if not self.hasAddMemberIcon then
		return 0
	elseif index + 1 ~= self.shortListCount then
		return 1
	else
		return 0
	end
end

M.OnRenderMemberInfo = function(self, btn, index)
	local tIndex = self.OnGetCurrentMemberShortListTIndex(self, index)

	if tIndex ~= 0 then
		local data = self.curMemberList[index + 1]

		self.linkMgr:OnMemberRenderItem(btn, index, data, true)

		btn.luaRenderTooltip = self:CreateActionWithArgs(gInviteManager.OnInvitePlayerRenderTooltips, data.pid, gInviteManager)
	elseif tIndex ~= 1 then
		btn.luaClick = self.CreateAction(self, "OnInviteMemberBtnClick")
	end
end

M.RefreshOtherModeData = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:GetLastMode().Callback = function (err, data)
		if err == MessageConfig.Ok then
			print_warn("GetLastMode failed, error =", gCS.Error.GetNameById(err))

			return
		end

		if not self.STATE_OnShowOnce then
			return
		end

		self.lastMode = data or LinkMode.None

		self:RefreshOtherLinkModeList()
	end
end

M.OnRenderModeListItem = function(self, btn, index)
	local data = self.otherLinkModeDatas[index + 1]
	local cfg = data.cfg
	local store = self.GetStoreByWidget(self, btn)

	if not store or not cfg then
		return
	end

	store.linkModeName = cfg.Name
	store.descText = cfg.ShortDesc
	store.isLast = self.lastMode ~= data.mode and 1 or 0

	if cfg.IconId and cfg.IconId <= 0 then
		store.iconImage = cfg.IconId
	end
end

M.RefreshOtherLinkModeList = function(self)
	self.otherLinkModeDatas = {}
	local selectIndex = 0

	for i = 0, LTConfig.LinkModeConfig.count - 1 do
		local cfg = LTConfig.LinkModeConfig.LoadAt(i)

		if cfg.ShowInLinkMainPanel then
			local mode = cfg.LinkModeCode

			if mode == self.linkMgr.LinkMode then
				local data = {
					cfg = cfg,
					mode = mode
				}

				if self.lastMode ~= mode then
					selectIndex = #self.otherLinkModeDatas
				end

				table.insert(self.otherLinkModeDatas, data)
			end
		end
	end

	self.bindData.modeList:SetSimpleList(#self.otherLinkModeDatas)
	self.bindData.modeList:SelectItem(selectIndex)
	self:TryFocusModeListItem()
end

M.OnOtherModeSelectChanged = function(self)
	local index = self.bindData.modeList.selectedIndex
	local data = index and self.otherLinkModeDatas[index + 1]

	if not data then
		self.bindData.needCreatePrivate = 0

		return
	end

	if data.mode ~= LinkMode.Private and not self.linkMgr.LinkData[data.mode] then
		self.bindData.needCreatePrivate = 1
	else
		self.bindData.needCreatePrivate = 0
	end

	if gLoginManager:CheckIsOnlineTest() and self.confirmButton then
		self.confirmButton.interactable = data.mode == LinkMode.None
	end
end

M.OnMouseScrollWheel = function(self, context)
	if not context.performed then
		return
	end

	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return
	end

	if self.bindData.rightPanelState == self.rightPanelStateEnum.otherMode then
		return
	end

	if not self.otherLinkModeDatas or #self.otherLinkModeDatas ~= 0 then
		return
	end

	local zoom = context:ReadValueVector2().y
	local count = #self.otherLinkModeDatas
	local index = self.bindData.modeList.selectedIndex or 0

	if zoom <= 0 then
		index = index - 1
	else
		index = index + 1
	end

	index = math.max(0, math.min(index, count - 1))

	if index == self.bindData.modeList.selectedIndex then
		self.bindData.modeList:SelectItem(index, false)
	end
end
