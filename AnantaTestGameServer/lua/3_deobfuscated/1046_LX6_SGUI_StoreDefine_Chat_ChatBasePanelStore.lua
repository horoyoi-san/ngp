C_ChatBasePanelStore = DefClass("C_ChatBasePanelStore", C_ChatBasePanelStore, C_AppActivityStore)
GroupName2Class.ChatBasePanelStore = C_ChatBasePanelStore
local M = C_ChatBasePanelStore
local CloseButtonType = gChatConst.CloseButtonType

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.returnBtn.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.fullscreenBtn.luaClick = self:CreateAction(self.OnFullscreenButtonClick)
	self.closeType = CloseButtonType.Return
	self.customCloseFunc = nil
	self.navArea = self.rootWidget:GetComponent(typeof(SGUI.UNavigationArea))

	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.navArea)
end

function M:OnDestroy()
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.navArea)
end

function M:OnClose()
	gChatManager:UpdateCurrentChannel(nil, nil)
	gChatUtils.SetCloseType(CloseButtonType.Return)
	gMessageManager:SendMessage(gEventConstants.CHAT_PANEL_CLOSE)

	local redDotKey = ("PhoneAppItemRedDot:%d"):format(LTConfig.MobileMenuSGuiConfig.ChatId)

	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.ChatId, redDotKey)
end

function M:OnRenderTab(index, widget)
	M.base.OnRenderTab(self, index, widget)

	local default = gChatConst.TabInfo.Default
	local tabInfo = gChatConst.TabInfo[index] or default
	self.bindData.bgTypeCtrl = tabInfo.BgType or default.BgType
	local hideCloseBtn = tabInfo.HideCloseBtn or default.HideCloseBtn
	self.bindData.returnBtn.rectTransform.localScale = hideCloseBtn and Vector3.forward or Vector3.one
end

function M:OnShow(_, data)
	if data.npcChatType then
		if gChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId) and data.npcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
			gChatUtils.SetCloseType(CloseButtonType.Hide)
		end

		self:ShowChattingPanel(data.topChannelId, data.subChannelId, nil)
	end

	if data.npcInviteGamePlay then
		self:InviteChat(data.npcInviteGamePlay)

		return
	end

	local top = data.topChannelId or gChatManager:GetNewestUnreadChannel()
	local sub = data.subChannelId

	if top == nil then
		top, sub = gChatManager:GetRecordChannel()
	end

	top = top or gChatTopChannel.Npc
	local channel = gChatManager:GetChannel(top, sub)

	if sub then
		local skipCheckChannel = gChatNpcsPhoneManager.isNpcsPhone and channel == nil

		if not skipCheckChannel and sub and channel == nil then
			print_error_without_stack("ChatPanelStore.OnShow: sub channel not exist", "top", top, "sub", sub)

			sub = nil
		end
	end

	if channel then
		gChatManager:UpdateCurrentChannel(top, sub)
	end
end

function M:GetMessageEvents()
	local msgEvents = {
		[gEventConstants.CHAT_CHANNEL_CHANGED] = self:CreateAction(self.OnChatChannelChanged)
	}

	return msgEvents
end

function M:OnChatChannelChanged(_, data)
	if data.topChannelId and data.subChannelId then
		local chatMessage = gChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId)

		self:ShowChattingPanel(data.topChannelId, data.subChannelId, chatMessage)
	end
end

function M:InviteChat(npcInviteGamePlay)
	self:ShowFragment(gChatConst.TabShowType.Invite, {
		inviteGamePlayId = npcInviteGamePlay
	})
end

function M:ShowChattingPanel(topChannelId, subChannelId, chatMessage)
	if gChatUtils.IsStoryChannel(topChannelId) then
		local showType = gChatNpcsPhoneManager.isNpcsPhone and gChatConst.TabShowType.NpcToNpcChatting or gChatConst.TabShowType.NpcChatting

		self:ShowFragment(showType, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId == gChatTopChannel.Group then
		self:ShowFragment(gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId == gChatTopChannel.Friend then
		self:ShowFragment(gChatConst.TabShowType.ChatingToFriend, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId == gChatTopChannel.Channels and self:CheckIsLink(subChannelId) then
		self:ShowFragment(gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId == gChatTopChannel.Team then
		self:ShowFragment(gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	end
end

function M:CheckIsLink(subChannelId)
	return subChannelId == UX.Game.MessageChannel.PrivateLink or subChannelId == UX.Game.MessageChannel.PublicLink or subChannelId == UX.Game.MessageChannel.MatchLink
end

function M:SetCloseType(closeBtnType, customCloseFunc)
	if gClientUtils.IsNil(self.bindData.returnBtn) then
		return
	end

	self.closeType = closeBtnType

	if closeBtnType == CloseButtonType.Hide then
		self.bindData.returnBtn:SetActive(false)

		self.customCloseFunc = nil
	else
		self.bindData.returnBtn:SetActive(true)

		self.customCloseFunc = customCloseFunc
	end
end

function M:OnExitClick()
	if self.customCloseFunc and self.customCloseFunc(0) then
		return
	end

	if self.closeType == CloseButtonType.Hide then
		print_error_without_stack("ChatBasePanelStore.OnExitClick: close button is hidden, should not be clicked")
	elseif self.closeType == CloseButtonType.Return then
		M.base.OnExitClick(self)
	elseif self.closeType == CloseButtonType.CloseApp then
		self:CloseThisActivity()
	elseif self.closeType == CloseButtonType.ClosePhone then
		gClientUtils.CloseMainPhonePanel()
	end
end

function M:OnFullscreenButtonClick()
	if self.customCloseFunc and self.customCloseFunc(1) then
		return
	end

	if self.closeType == CloseButtonType.Return or self.closeType == CloseButtonType.CloseApp then
		self:CloseThisActivity()
	elseif self.closeType ~= CloseButtonType.Hide then
		gClientUtils.CloseMainPhonePanel()
	end
end

function M:ShowUid(isShow)
	self.bindData.uidWidget:SetActive(isShow)
end

function M:ShowMessage(text)
	if not self.STATE_EnableOnce then
		return
	end

	local messageTip = self.bindData.messageTip

	if gClientUtils.IsNil(messageTip) then
		return
	end

	messageTip:SetActive(true)

	local store = self:GetStoreByWidget(messageTip)
	store.text = text

	if self.hideMessageTipTimer then
		self.hideMessageTipTimer:Stop()
	end

	self.hideMessageTipTimer = Timer.New(function ()
		if gClientUtils.NotNil(messageTip) then
			messageTip:SetActive(false)
		end

		self.hideMessageTipTimer = nil
	end, 3):Start()
end

function M:ShowFragment(showType, params)
	local currentFragmentInfo = self.fragmentInfoStack:Peek() or {}
	local selectedIndex = self.bindData.tabRect.selectedIndex

	if self.bindData.tabAnimRoot then
		self.bindData.tabAnimRoot:PlaySwitchTabAnim(selectedIndex, currentFragmentInfo.widget, showType)
	end

	local chatId = params and params.chatID
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if chatCfg and chatCfg.TuiteParam and chatCfg.TuiteParam.tuiteId and chatCfg.TuiteParam.tuiteId > 0 then
		self:OpenSocialNetworkPanel(chatCfg.TuiteParam)
	else
		M.base.ShowFragment(self, showType, params)
	end
end

function M:OpenSocialNetworkPanel(args)
	if args.isHalfScreen then
		gMainPhoneUtils.ShowPhoneAppContent({
			args = gPanelId.S_HALF_PHONE_APP_HOME_PANEL,
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie,
			id = args.tuiteId,
			secondShowType = args.secondShowType
		})
	else
		gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
			id = args.tuiteId,
			secondShowType = args.secondShowType
		})
	end
end

function M:CloseCurrentFragment()
	if self.fragmentInfoStack.count > 1 then
		local currentFragmentInfo = self.fragmentInfoStack:Peek() or {}
		local selectedIndex = self.bindData.tabRect.selectedIndex
		local fragmentToShow = self.fragmentInfoStack[self.fragmentInfoStack.topIndex - 1]

		if self.bindData.tabAnimRoot then
			self.bindData.tabAnimRoot:PlaySwitchTabAnim(selectedIndex, currentFragmentInfo.widget, fragmentToShow.args[gClientConst.PhoneAppShowTypeLevel.SecondLevel])
		end
	end

	M.base.CloseCurrentFragment(self)
end
