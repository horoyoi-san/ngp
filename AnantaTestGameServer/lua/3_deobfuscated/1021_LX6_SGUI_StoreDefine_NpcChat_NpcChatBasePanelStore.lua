local NpcChatConfig = LTConfig.NPCChatConfig
C_NpcChatBasePanelStore = DefClass("C_NpcChatBasePanelStore", C_NpcChatBasePanelStore, C_NpcChatActivityStore)
GroupName2Class.NpcChatBasePanelStore = C_NpcChatBasePanelStore
local M = C_NpcChatBasePanelStore
local CloseButtonType = gNpcChatConst.CloseButtonType

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
	gNpcChatManager:UpdateCurrentChannel(nil, nil)
	gNpcChatUtils.SetCloseType(CloseButtonType.Return)
	gMessageManager:SendMessage(gEventConstants.CHAT_PANEL_CLOSE)

	local redDotKey = ("PhoneAppItemRedDot:%d"):format(LTConfig.MobileMenuSGuiConfig.MessageId)

	gMainPhoneUtils.RefreshAppItemRedDot(LTConfig.MobileMenuSGuiConfig.MessageId, redDotKey)

	gNpcChatNpcsPhoneManager.otherData = nil

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "InvitePanelPlayerClose"
	})
end

function M:OnRenderTab(index, widget)
	M.base.OnRenderTab(self, index, widget)

	local default = gNpcChatConst.TabInfo.Default
	local tabInfo = gNpcChatConst.TabInfo[index] or default
	self.bindData.bgTypeCtrl = tabInfo.BgType or default.BgType
	local hideCloseBtn = tabInfo.HideCloseBtn or default.HideCloseBtn
	self.bindData.returnBtn.rectTransform.localScale = hideCloseBtn and Vector3.forward or Vector3.one
end

function M:OnShow(_, data)
	gNpcChatNpcsPhoneManager.otherData = data
	local lastMsg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId)

	if data.npcChatType then
		if lastMsg and data.npcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
			gNpcChatUtils.SetCloseType(CloseButtonType.Hide)
		end

		if data.npcsPhoneCfg and data.npcsPhoneCfg.BackToListAfterDialog then
			gNpcChatManager:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.Npc)
			self:ShowFragment(gNpcChatConst.TabShowType.NpcPhoneChannel)

			return
		end
	end

	if data.npcInviteGamePlay then
		self:InviteChat(data.npcInviteGamePlay)

		return
	end

	local top = data.topChannelId or gNpcChatManager:GetNewestUnreadChannel()
	local sub = data.subChannelId

	if top == nil then
		top, sub = gNpcChatManager:GetRecordChannel()
	end

	top = top or gNpcChatConst.ChatTopChannel.Npc
	local channel = gNpcChatManager:GetChannel(top, sub)

	if sub then
		local skipCheckChannel = gNpcChatNpcsPhoneManager.isNpcsPhone and channel == nil

		if not skipCheckChannel and sub and channel == nil then
			print_error_without_stack("ChatPanelStore.OnShow: sub channel not exist", "top", top, "sub", sub)

			sub = nil
		end
	end

	if channel then
		gNpcChatManager:UpdateCurrentChannel(top, sub, data.chatCfg or lastMsg and lastMsg.cfg or nil)
	end
end

function M:GetMessageEvents()
	local msgEvents = {
		[gEventConstants.NPC_CHAT_CHANNEL_CHANGED] = self:CreateAction(self.OnChatChannelChanged)
	}

	return msgEvents
end

function M:OnChatChannelChanged(_, data)
	if data.topChannelId and data.subChannelId then
		local chatMessage = gNpcChatUtils.GetCurrentNpcChannelLastMsg(data.topChannelId, data.subChannelId)

		if chatMessage and chatMessage.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
			gNpcChatUtils.SetCloseType(CloseButtonType.Hide)
		end

		self:ShowChattingPanel(data.topChannelId, data.subChannelId, chatMessage, data.cfg)
	end
end

function M:InviteChat(npcInviteGamePlay)
	self:ShowFragment(gNpcChatConst.TabShowType.Invite, {
		inviteGamePlayId = npcInviteGamePlay
	})
end

function M:ShowChattingPanel(topChannelId, subChannelId, chatMessage, cfg)
	local showType = gNpcChatNpcsPhoneManager.isNpcsPhone and gNpcChatConst.TabShowType.NpcToNpcChatting or gNpcChatConst.TabShowType.NpcChatting

	self:ShowFragment(showType, {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		chatMessage = chatMessage,
		cfg = cfg
	})
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

function M:CheckHasNeedClickItemsAndShow()
	local currentStore = self:GetCurrentFragmentStore()

	if currentStore and currentStore.needClickItem then
		local count = 0

		for msgId, store in pairs(currentStore.needClickItem) do
			store.clickVfxCtrl = 0
			store.clickVfxCtrl = 1

			if count == 0 then
				currentStore:ScrollToMessageByMsgId(msgId)
			end

			count = count + 1
		end

		return count > 0, count
	end

	return false, 0
end

function M:OnExitClick()
	local hasNeedClick, _ = self:CheckHasNeedClickItemsAndShow()

	if hasNeedClick then
		return
	end

	if self.customCloseFunc and self.customCloseFunc(0) then
		return
	end

	if self.closeType == CloseButtonType.Hide then
		print_error_without_stack("NpcChatBasePanelStore.OnExitClick: close button is hidden, should not be clicked")
	elseif self.closeType == CloseButtonType.Return then
		M.base.OnExitClick(self)
	elseif self.closeType == CloseButtonType.CloseApp then
		self:CloseThisActivity()
	elseif self.closeType == CloseButtonType.ClosePhone then
		gClientUtils.CloseMainPhonePanel()
	end
end

function M:OnFullscreenButtonClick()
	local hasNeedClick, _ = self:CheckHasNeedClickItemsAndShow()

	if hasNeedClick then
		return
	end

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

function M:ShowMessage(text, type)
	if not self.STATE_EnableOnce then
		return
	end

	local messageTip = self.bindData.messageTip

	if gClientUtils.IsNil(messageTip) then
		return
	end

	messageTip:SetActive(false)
	messageTip:SetActive(true)

	self.bindData.tipText = text
	self.bindData.tipTypeCtrl = type or 0

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
	local chatCfg = NpcChatConfig.GetConfig(chatId)

	if chatCfg and chatCfg.TuiteParam and chatCfg.TuiteParam.tuiteId and chatCfg.TuiteParam.tuiteId > 0 then
		self:OpenSocialNetworkPanel(chatCfg.TuiteParam)
	else
		M.base.ShowFragment(self, showType, params)
	end
end

function M:OpenSocialNetworkPanel(args)
	if args.isHalfScreen then
		gMainPhoneUtils.ShowPhoneAppContent({
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
