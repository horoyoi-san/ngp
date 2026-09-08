-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatBasePanelStore.lua
-- Decompiled from: 02113_ChatBasePanelStore.lua_9e288cde6e0b.luajit

C_ChatBasePanelStore = DefClass("C_ChatBasePanelStore", C_ChatBasePanelStore, C_AppActivityStore)
GroupName2Class.ChatBasePanelStore = C_ChatBasePanelStore
local M = C_ChatBasePanelStore
local CloseButtonType = gChatConst.CloseButtonType

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.returnBtn.luaClick = self:CreateAction(self.OnExitClick)
	self.bindData.fullscreenBtn.luaClick = self:CreateAction(self.OnFullscreenButtonClick)
	self.closeType = CloseButtonType.Return
	self.customCloseFunc = nil
	self.navArea = self.rootWidget:GetComponent(typeof(SGUI.UNavigationArea))

	LX6.GUI.NavMgrEx.Instance:AddBanArea(self.navArea)
end

M.OnDestroy = function(self)
	LX6.GUI.NavMgrEx.Instance:RemoveBanArea(self.navArea)
end

M.OnClose = function(self)
	gChatManager:UpdateCurrentChannel(nil, )
	gChatUtils.SetCloseType(CloseButtonType.Return)
	gMessageManager:SendMessage(gEventConstants.CHAT_PANEL_CLOSE)
	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.ChatId)
end

M.OnRenderTab = function(self, index, widget)
	M.base.OnRenderTab(self, index, widget)

	local default = gChatConst.TabInfo.Default
	local tabInfo = gChatConst.TabInfo[index] or default
	self.bindData.bgTypeCtrl = tabInfo.BgType or default.BgType
	local hideCloseBtn = tabInfo.HideCloseBtn or default.HideCloseBtn
	self.bindData.returnBtn.rectTransform.localScale = hideCloseBtn and Vector3.forward or Vector3.one
end

M.OnShow = function(self, _, data)
	if data.npcChatType then
		if gChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId) and data.npcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
			gChatUtils.SetCloseType(CloseButtonType.Hide)
		end

		self.ShowChattingPanel(self, data.topChannelId, data.subChannelId, nil)
	end

	if data.npcInviteGamePlay then
		self.InviteChat(self, data.npcInviteGamePlay)

		return
	end

	local top = data.topChannelId or gChatManager:GetNewestUnreadChannel()
	local sub = data.subChannelId

	if top ~= nil then
		top, sub = gChatManager:GetRecordChannel()
	end

	top = top or gChatTopChannel.Npc
	local channel = gChatManager:GetChannel(top, sub)

	if sub then
		local skipCheckChannel = gChatNpcsPhoneManager.isNpcsPhone and channel ~= nil

		if not skipCheckChannel and sub and channel ~= nil then
			print_error_without_stack("ChatPanelStore.OnShow: sub channel not exist", "top", top, "sub", sub)

			sub = nil
		end
	end

	if channel then
		gChatManager:UpdateCurrentChannel(top, sub)
	end
end

M.GetMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.CHAT_CHANNEL_CHANGED] = self.CreateAction(self, self.OnChatChannelChanged)
	}

	return msgEvents
end

M.OnChatChannelChanged = function(self, _, data)
	if data.topChannelId and data.subChannelId then
		local chatMessage = gChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId)

		self.ShowChattingPanel(self, data.topChannelId, data.subChannelId, chatMessage)
	end
end

M.InviteChat = function(self, npcInviteGamePlay)
	self.ShowFragment(self, gChatConst.TabShowType.Invite, {
		inviteGamePlayId = npcInviteGamePlay
	})
end

M.ShowChattingPanel = function(self, topChannelId, subChannelId, chatMessage)
	if gChatUtils.IsStoryChannel(topChannelId) then
		local showType = gChatNpcsPhoneManager.isNpcsPhone and gChatConst.TabShowType.NpcToNpcChatting or gChatConst.TabShowType.NpcChatting

		self:ShowFragment(showType, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId ~= gChatTopChannel.Group then
		self.ShowFragment(self, gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId ~= gChatTopChannel.Friend then
		self.ShowFragment(self, gChatConst.TabShowType.ChatingToFriend, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId ~= gChatTopChannel.Channels and self.CheckIsLink(self, subChannelId) then
		self.ShowFragment(self, gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	elseif topChannelId ~= gChatTopChannel.Team then
		self.ShowFragment(self, gChatConst.TabShowType.ChattingGroup, {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			chatMessage = chatMessage
		})
	end
end

M.CheckIsLink = function(self, subChannelId)
	return subChannelId ~= UX.Game.MessageChannel.PrivateLink or subChannelId ~= UX.Game.MessageChannel.PublicLink or subChannelId ~= UX.Game.MessageChannel.MatchLink
end

M.SetCloseType = function(self, closeBtnType, customCloseFunc)
	if gClientUtils.IsNil(self.bindData.returnBtn) then
		return
	end

	self.closeType = closeBtnType

	if closeBtnType ~= CloseButtonType.Hide then
		self.bindData.returnBtn:SetActive(false)

		self.customCloseFunc = nil
	else
		self.bindData.returnBtn:SetActive(true)

		self.customCloseFunc = customCloseFunc
	end
end

M.OnExitClick = function(self)
	if self.customCloseFunc and self.customCloseFunc(0) then
		return
	end

	if self.closeType ~= CloseButtonType.Hide then
		print_error_without_stack("ChatBasePanelStore.OnExitClick: close button is hidden, should not be clicked")
	elseif self.closeType ~= CloseButtonType.Return then
		M.base.OnExitClick(self)
	elseif self.closeType ~= CloseButtonType.CloseApp then
		self.CloseThisActivity(self)
	elseif self.closeType ~= CloseButtonType.ClosePhone then
		gClientUtils.CloseMainPhonePanel()
	end
end

M.OnFullscreenButtonClick = function(self)
	if self.customCloseFunc and self.customCloseFunc(1) then
		return
	end

	if self.closeType ~= CloseButtonType.Return or self.closeType ~= CloseButtonType.CloseApp then
		self.CloseThisActivity(self)
	elseif self.closeType == CloseButtonType.Hide then
		gClientUtils.CloseMainPhonePanel()
	end
end

M.ShowUid = function(self, isShow)
	self.bindData.uidWidget:SetActive(isShow)
end

M.ShowMessage = function(self, text)
	if not self.STATE_EnableOnce then
		return
	end

	local messageTip = self.bindData.messageTip

	if gClientUtils.IsNil(messageTip) then
		return
	end

	messageTip.SetActive(messageTip, true)

	local store = self.GetStoreByWidget(self, messageTip)
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

M.ShowFragment = function(self, showType, params)
	local currentFragmentInfo = self.fragmentInfoStack:Peek() or {}
	local selectedIndex = self.bindData.tabRect.selectedIndex

	if self.bindData.tabAnimRoot then
		self.bindData.tabAnimRoot:PlaySwitchTabAnim(selectedIndex, currentFragmentInfo.widget, showType)
	end

	local chatId = params and params.chatID
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if chatCfg and chatCfg.TuiteParam and chatCfg.TuiteParam.tuiteId and chatCfg.TuiteParam.tuiteId <= 0 then
		self.OpenSocialNetworkPanel(self, chatCfg.TuiteParam)
	else
		M.base.ShowFragment(self, showType, params)
	end
end

M.OpenSocialNetworkPanel = function(self, args)
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

M.CloseCurrentFragment = function(self)
	if self.fragmentInfoStack.count <= 1 then
		local currentFragmentInfo = self.fragmentInfoStack:Peek() or {}
		local selectedIndex = self.bindData.tabRect.selectedIndex
		local fragmentToShow = self.fragmentInfoStack[self.fragmentInfoStack.topIndex - 1]

		if self.bindData.tabAnimRoot then
			self.bindData.tabAnimRoot:PlaySwitchTabAnim(selectedIndex, currentFragmentInfo.widget, fragmentToShow.args[gClientConst.PhoneAppShowTypeLevel.SecondLevel])
		end
	end

	M.base.CloseCurrentFragment(self)
end
