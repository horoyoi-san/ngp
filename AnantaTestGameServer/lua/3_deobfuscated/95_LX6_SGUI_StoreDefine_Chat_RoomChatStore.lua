local UNavigationMgr = SGUI.UNavigationMgr
C_RoomChatStore = DefClass("C_RoomChatStore", C_RoomChatStore, C_StoreGroup)
GroupName2Class.RoomChatStore = C_RoomChatStore
local M = C_RoomChatStore

function M:OnAwake()
	self.isPrepare = not table.isNilOrEmpty(gLinkManager.matchMemberList)
	self.topChannelId = gChatTopChannel.Channels
	self.subChannelId = UX.Game.MessageChannel.Room
	self.msgCountLimit = 4
	self.pid = gPlayerManager.infoLogin.bindData.pid
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")

	self:SetNormalBtnBar()

	if self.bindData.inputField and self.bindData.sendBtn then
		self.hasInputField = true
		self.bindData.sendBtn.luaClick = self:CreateAction(self.OnSendBtnClick)

		if self.bindData.sendBtn2 then
			self.bindData.sendBtn2.luaClick = self:CreateAction(self.OnSendBtnClick)
		end

		self.bindData.inputField.onActivateAction = self:CreateAction(self.OnInputFieldActivate)
		self.bindData.inputField.onDeActivateAction = self:CreateAction(self.OnInputFieldDeactivate)
	end

	if self.bindData.chatList then
		self.hasChatList = true
		self.bindData.chatList.luaRenderItem = self:CreateAction(self.OnRenderComplexItem)
		self.bindData.chatList.onGetTIndex = self:CreateAction(self.OnComplexItemGetTIndex)
		self.allMsgList = {}
	end

	self:RegisterMessageEventHandlers()

	local channel = gChatManager:GetOrAddSubChannel(self.topChannelId, self.subChannelId)

	gChatManager:UpdateCurrentChannel(self.topChannelId, self.subChannelId)
	gChatManager:ResetMessageOfChannelInfo(gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	gChatManager:RequestStableList(self.topChannelId, self.subChannelId)

	self.msgList = {}
	local messages = channel.messages:ToTable()

	if not table.isNilOrEmpty(messages) then
		for i = 1, #messages do
			self:AddNewChatMessage(messages[i])
		end
	end
end

function M:OnDestroy()
	self:ClearMessageEvents()

	self.msgList = nil
	self.parentNaviArea = nil

	gChatManager:UpdateCurrentChannel()
end

function M:SetNormalBtnBar()
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

function M:RegisterMessageEventHandlers()
	self:ClearMessageEvents()

	local msgEvents = {
		[gEventConstants.CHAT_MESSAGE_CHANGED] = self:CreateAction(self.OnChatMessageChanged),
		[gEventConstants.SEND_CHAT_MSG_OVER] = self:CreateAction(self.OnSendChatMsgOver)
	}

	self:RegisterMessageEvents(msgEvents)
end

function M:OnChatMessageChanged(_, data)
	if self.topChannelId == data.topChannelId and ulong.equals(self.subChannelId, data.subChannelId) and data.msg then
		self:AddNewChatMessage(data.msg)
	end
end

function M:OnSendChatMsgOver(_, data)
	local isSuccess = data[0]

	if isSuccess and self.hasInputField then
		self.bindData.inputField.text = ""
	end
end

function M:AddNewChatMessage(msg)
	if self.msgCountLimit <= #self.msgList then
		table.remove(self.msgList, 1)
	end

	table.insert(self.msgList, msg)
	self.bindData.list:SetList(self.msgList)

	self.bindData.list.normalizedScrollPosition = Vector2.Fetch(0, 0)

	if self.hasChatList then
		table.insert(self.allMsgList, msg)
		self.bindData.chatList:SetList(#self.allMsgList)
	end
end

function M:OnRenderItem(btn, _, msg)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local isMe = msg.pid == self.pid
	local format = isMe and LTConfig.LinkConfig.RoomChatFormatMe or LTConfig.LinkConfig.RoomChatFormatOther
	local playerIndex = self:GetPlayerIndex(msg.pid) or 0
	local playerName = gFriendManager:GetPlayerRealName(msg.pid)
	local content = gString.Format(format, playerIndex, playerName, msg.text)
	store.content = content
end

function M:OnRenderComplexItem(btn, csIndex)
	local msg = self.allMsgList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local playerIndex = self:GetPlayerIndex(msg.pid) or 0
	store.mark = "[" .. playerIndex .. "]"
	store.name = gFriendManager:GetPlayerRealName(msg.pid)

	gChatAvatarUtils:SetSingleAvatar(ChatSenderId.NewPlayer(msg.pid), store.avatarWidget)

	if msg.msgType == gChatConst.MessageType.Voice then
		self:ProcessVoiceMsg(msg, store)
	else
		store.content = msg.text
	end
end

function M:ProcessVoiceMsg(msg, store)
	store.content = math.max(math.ceil(msg.duration), 1)
	store.btn.luaClick = self:CreateActionWithArgs(self.OnClickAudioBubble, msg)
end

function M:OnClickAudioBubble(msg)
	gCS.IMManager:StartPlayAudio(msg.msgId, msg.filePath)
end

function M:OnComplexItemGetTIndex(csIndex)
	if self.allMsgList[csIndex + 1].msgType == gChatConst.MessageType.Voice then
		return self.allMsgList[csIndex + 1].pid == self.pid and 6 or 5
	end

	return self.allMsgList[csIndex + 1].pid == self.pid and 1 or 0
end

function M:OnSendBtnClick()
	self:SendChat(self.bindData.inputField.text)
end

function M:GetPlayerIndex(pid)
	if self.isPrepare then
		return self:GetPlayerIndexInPrepare(pid)
	else
		return self:GetPlayerIndexInRoom(pid)
	end
end

function M:GetPlayerIndexInRoom(pid)
	local infos = gLinkManager:GetRoomPlayerInfo()

	for _, v in ipairs(infos) do
		if ulong.equals(pid, v.pid) then
			return v.id
		end
	end
end

function M:GetPlayerIndexInPrepare(pid)
	local infos = gLinkManager.matchMemberList

	for i, v in ipairs(infos) do
		if ulong.equals(pid, v.memberId) then
			return i
		end
	end
end

function M:ActivateInputField()
	self.activeInputFieldCo = coroutine.start(function ()
		coroutine.wait(0.2)
		self.bindData.inputField:ActivateInputField()
	end)
end

function M:SendChat(text)
	if not self.inputActive and string.is_null_or_empty(text) then
		self:ActivateInputField()

		return
	end

	gChatManager:TrySendChat(text, gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	self:ActivateInputField()
end

function M:RegisterParentNaviArea(naviarea)
	self.parentNaviArea = naviarea
end

function M:OnInputFieldActivate()
	self.inputActive = true

	if self.bindData.navigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	end
end

function M:OnInputFieldDeactivate()
	self.inputActive = false

	if self.parentNaviArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.parentNaviArea
	end
end
