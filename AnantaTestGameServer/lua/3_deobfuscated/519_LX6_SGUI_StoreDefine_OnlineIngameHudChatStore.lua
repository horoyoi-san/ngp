local LinkConfig = LTConfig.LinkConfig
local ProgressConfig = LTConfig.LinkProgressConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_OnlineIngameHudChatStore = DefClass("C_OnlineIngameHudChatStore", C_OnlineIngameHudChatStore, C_StoreGroup)
GroupName2Class.OnlineIngameHudChatStore = C_OnlineIngameHudChatStore
local M = C_OnlineIngameHudChatStore

function M:OnAwake()
	self.msgList = {}
	self.msgCountLimit = 4
	self.redDotKey = "OnlineChatBtn"
	self.topChannelId = gChatTopChannel.Channels
	self.bindData.enter = self:CreateAction("OnChatBtnClick")
	self.bindData.chatBtn = self:CreateAction("OnChatBtnClick")
	self.bindData.send = self:CreateAction("OnSendBtnClick")

	if self.bindData.sendBtn then
		self.bindData.sendBtn.luaClick = self:CreateAction("OnSendBtnClick")
	end

	if self.bindData.chatMobileBtn then
		self.bindData.chatMobileBtn.luaClick = self:CreateAction("OnChatBtnClick")
	end

	self.bindData.chatList.luaRenderItem = self:CreateAction("OnRenderItem")

	function self.bindData.chatList.onGetTIndex(_)
		return 0
	end

	self.interactionStore = gStoreManager:GetStoreGroup("WatchingGameInteractionStore")
	local msgEvents = {
		[gEventConstants.CHAT_HUD_MESSAGE_CHANGED] = self:CreateAction("OnChatMessageChanged"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.SYNC_WATCH_INTERACTION_INFO] = self:CreateAction("SyncWatchInteractionInfo"),
		[gEventConstants.ON_PHONE_APP_HOME_SHOW] = self:CreateAction("OnPhoneShow"),
		[gEventConstants.ON_PHONE_APP_HOME_HIDE] = self:CreateAction("OnPhoneHide"),
		[gEventConstants.LINK_PROGRESS_VISIBILITY_CHANGE] = self:CreateAction("OnLinkProgressVisibilityChange")
	}

	self:SetCurChannel()
	self:RegisterMessageEvents(msgEvents)

	self.bindData.hideThis = 1
	gChatManager.unReadList = {}
end

function M:OnStart()
	self.redDotAction = self:CreateAction("OnRenderRedDot")
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot and SGUI.RedDotMgr.onRenderRedDot + self.redDotAction or self.redDotAction
end

function M:OnClose()
	SGUI.RedDotMgr.onRenderRedDot = SGUI.RedDotMgr.onRenderRedDot - self.redDotAction
end

function M:OnDestroy()
	if self.countDown then
		self.countDown:Stop()

		self.countDown = nil
	end

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self:ClearMessageEvents()
end

function M:OnChatMessageChanged(_, data)
	self:HideThisCountDown()

	local subChannelId = ulong.tonum2(data.subChannelId)

	if self.topChannelId == data.topChannelId and self.subChannelId == subChannelId then
		self:AddNewChatMessage(data.msg)
	elseif data.topChannelId == gChatTopChannel.Friend then
		if self.subChannelId == UX.Game.MessageChannel.PublicLink then
			self:HideThisCountDown()
			self:AddNewChatMessage(data.msg)
		else
			table.insert(gChatManager.unReadList, data.msg.pid)
			SGUI.RedDotMgr.LuaSetRedDot(true, self.redDotKey, true)
		end
	end
end

function M:HideThisCountDown()
	self.bindData.hideThis = 0

	if self.countDown then
		self.countDown:Stop()

		self.countDown = nil
	end

	self.countDown = Timer.New(function ()
		self.bindData.hideThis = 1
	end, LTConfig.LinkConfig.ChatBubbleFloatingTime):Start()
end

function M:OnPanelClose(eventId, panelId)
	if panelId == gPanelId.S_HALF_PHONE_APP_HOME_PANEL then
		self:SetCurChannel()

		self.bindData.showInput = 0
	end
end

function M:OnLinkModeChange()
	if not gLinkManager:CheckInLinkMode() then
		return
	end

	self.bindData.showInput = 0

	self:SetCurChannel()
end

function M:SetCurChannel()
	if gLinkManager.LinkMode == UX.Game.LinkMode.Private then
		self.subChannelId = UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Public then
		self.subChannelId = UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Match then
		self.subChannelId = UX.Game.MessageChannel.MatchLink
	end

	gChatManager:GetOrAddSubChannel(self.topChannelId, self.subChannelId)
	gChatManager:UpdateCurrentChannel(self.topChannelId, self.subChannelId)
end

function M:AddNewChatMessage(msg)
	self:HideThisCountDown()

	if self.msgCountLimit <= #self.msgList then
		table.remove(self.msgList, 1)
	end

	table.insert(self.msgList, msg)
	self.bindData.chatList:SetList(#self.msgList)

	self.bindData.chatList.normalizedScrollPosition = Vector2.Fetch(0, 0)
end

function M:OnRenderItem(btn, csIndex)
	local msg = self.msgList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local isMe = msg.pid == gPlayerManager.infoLogin.bindData.pid
	local format = isMe and LTConfig.LinkConfig.RoomChatFormatMe or LTConfig.LinkConfig.RoomChatFormatOther
	local playerName = gFriendManager:GetPlayerRealName(msg.pid)
	local playerIndex = self:GetLinkIndex(msg.pid) or 0
	local content = ""
	local msgText = msg.text

	if msg.msgType == gChatConst.MessageType.Team then
		msgText = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.InviteTeam).Text
	end

	if playerIndex == 0 then
		content = gString.Format("#c51d1ff%s:#z %s", playerName, msgText)
	else
		content = gString.Format(format, playerIndex, playerName, msgText)
	end

	store.content = content
end

function M:GetLinkIndex(pid)
	return gLinkManager.LinkMemberIndex[gLinkManager.LinkMode][pid] or 0
end

function M:OnRenderRedDot(redKey, templateKey, redDot)
	if templateKey == "Number" then
		local store = gStoreManager:GetStoreGroup("RedDotNumber"):GetStoreByWidget(redDot)

		if not store then
			return
		end

		store.num = #gChatManager.unReadList
	end
end

function M:SendChat(text)
	coroutine.start(function ()
		coroutine.step()
		gChatManager:TrySendChat(text, gChatTopChannel.Channels, self.subChannelId)

		self.bindData.inputField.text = ""
		self.bindData.showInput = 0
	end)
end

function M:ShowInput()
	self.bindData.showInput = 1
	self.activeInputFieldCo = coroutine.start(function ()
		coroutine.step()
		self.bindData.inputField:ActivateInputField()
	end)
end

function M:ContentIsEmpty(str)
	for i = 1, #str do
		if string.sub(str, i, i) ~= "\n" and string.sub(str, i, i) ~= " " then
			return false
		end
	end

	return true
end

function M:OpenChatPanel()
	gChatUtils.OpenChatPanel()

	if self.waitTimer then
		self.waitTimer:Stop()

		self.waitTimer = nil
	end

	self.waitTimer = Timer.New(function ()
		gChatManager:GetOrAddSubChannel(gChatTopChannel.Channels, self.subChannelId)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Channels, self.subChannelId)
	end, 0.5):Start()
end

function M:OnChatBtnClick()
	self:HideThisCountDown()

	if self.bindData.hideThis == 1 then
		self.bindData.hideThis = 0

		return
	end

	if self.bindData.showInput == 1 then
		if not self:ContentIsEmpty(self.bindData.inputField.text) then
			self:SendChat(self.bindData.inputField.text)

			return
		end

		self:HideInput()

		return
	end

	local result = gPanelManager:CheckCanPanelShow(LTConfig.PanelConfig.S_HALF_PHONE_APP_HOME_PANEL)

	if result == gPanelManager.CHECK_RESULT.UNLOCK then
		self:ShowInput()
	else
		self.bindData.showInput = 0

		self:OpenChatPanel()
	end
end

function M:HideInput()
	coroutine.start(function ()
		coroutine.step()
		self.bindData.inputField:DeactivateInputField()
	end)

	self.bindData.showInput = 0
end

function M:OnSendBtnClick()
	self:SendChat(self.bindData.inputField.text)
end

function M:OnPhoneShow(_, data)
	self.bindData.hideAll = 1
end

function M:OnPhoneHide(_, data)
	self.bindData.hideAll = 0
end

function M:SyncWatchInteractionInfo(_, data)
	if data.type == LTConfig.LinkInteractionConfig.BeWatched then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Link_WatchingGame_Enter, nil, nil, data.name)
	elseif data.type == LTConfig.LinkInteractionConfig.ExitWatching then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.Link_WatchingGame_Exit, nil, nil, data.name)
	else
		self.interactionStore:SetData(data)
	end
end

function M:OnLinkProgressVisibilityChange(_, data)
	local groupId = data and data.groupId or 0

	if groupId == ProgressConfig.halfConfirm then
		local visible = data and data.visible or false
		self.bindData.showMatchReady = BOOL2CTL[visible]
	end
end
