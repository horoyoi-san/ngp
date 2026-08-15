C_ChatChattingPanelStore = DefClass("C_ChatChattingPanelStore", C_ChatChattingPanelStore, C_AppFragmentStore)
local M = C_ChatChattingPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_Utils")
dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_Handler")

local ProcessMsgFunc = dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_ProcessMsgFunc")

function M:ctor()
	ProcessMsgFunc.OnConstruction(self)
end

function M:OnAwake()
	self.cs = self.rootWidget:GetComponent(typeof(L18.Script.SGUI.Chat.ChatChattingPanel))
	self.cs.luaRenderItem = self:CreateAction(self.OnRenderChatItem)
	self.cs.luaClearAndRefreshAllMsg = self:CreateAction(self.OnClearAndRefreshAllMsg)
	self.cs.luaGetTIndex = self:CreateAction(self.OnGetChatItemTIndex)
	self.chatList = self.bindData.chatList
	self.chatList.poolMode = SGUI.EPoolMode.Default

	self:RegisterMessageEventHandlers()
	self:InitDataOnAwake()
end

function M:InitDataOnAwake()
	return
end

function M:OnShow(tabIndex, data)
	self.data = data or {}
	self.inInit = true

	self:InitData()
	self:InitView()

	self.inInit = false
	self.refreshTimer = Timer.New(function ()
		self:RefreshTeamListData()
	end, 3, -1):Start()
end

function M:OnUpdate()
	if self.interactiveChatItemBtnListDirty then
		self:UpdateInteractiveChatItemBtnList()

		self.interactiveChatItemBtnListDirty = false
	end
end

function M:UpdateInteractiveChatItemBtnList()
	return
end

function M:InitData()
	self.interactiveMessageBtnList = {}
	self.interactiveChatItemBtnListDirty = true
	local top = self.data.topChannelId
	local sub = self.data.subChannelId

	if top == nil or sub == nil then
		top, sub = gChatManager:GetCurrentChannel()
	end

	self.topChannelId = top
	self.subChannelId = sub
	self.currentChannelInfo = gChatManager:GetChannel(top, sub)

	gChatManager:RequestStableList(top, sub)
	gChatManager:ResetUnreadCount(top, sub)
end

function M:InitView()
	self:SetHeader()
	self.cs:ClearAndRefreshAllMsg()
end

function M:SetHeader()
	if self.bindData.header == nil then
		return
	end

	gChatUtils.SetHeader(self.bindData.header, false, self.topChannelId, self.subChannelId)
end

function M:ReceiveNewMessage(msg, skipScroll)
	if gClientUtils.NotNil(self.bindData.chatList) then
		self:UpdateChatList(function ()
			self:AddNewChatMessage(msg)
			self:AfterAddLastMessage(msg)
		end, not msg.isNpcChat)

		if not skipScroll then
			self:ScrollToBottom()
		end
	end
end

function M:AddNewChatMessage(msg)
	local bubblePos = "Mid"

	if msg.templateMode == gChatConst.MsgTemplateMode.MyChat then
		bubblePos = "Right"
	elseif msg.templateMode == gChatConst.MsgTemplateMode.TheirChat then
		bubblePos = "Left"
	end

	self:BeforeAddMessage(msg)

	if msg.mode == gChatConst.MsgMode.Text and string.is_null_or_empty(msg:GetText()) then
		self:AfterAddMessage(msg)

		return
	end

	self:AddViewItem(msg, bubblePos)
	self:AfterAddMessage(msg)
end

function M:AddViewItem(msg, bubblePos)
	local msgType = msg.msgType
	local tIndex = gChatConst.MsgType2Template[msgType][bubblePos] or gChatConst.MsgType2Template[msgType].Mid

	if tIndex == nil then
		print_warn("ChatChattingPanel: 不支持的气泡显示类型！ msgType = " .. tostring(msgType), ", bubblePos = " .. tostring(bubblePos))

		return
	end

	local itemData = {
		msg = msg,
		tIndex = tIndex,
		msgType = msgType
	}

	if not msg.cfg then
		self:AddItemToList(itemData)

		return
	end

	if not msg.isNpcChat or msg.cfg.Message then
		self:AddItemToList(itemData)
	end
end

function M:AddCustomViewItem(customData, msgType, bubblePos)
	customData.tIndex = gChatConst.MsgType2Template[msgType][bubblePos] or gChatConst.MsgType2Template[msgType].Mid

	if customData.tIndex == nil then
		print_warn("ChatChattingPanel: 不支持的气泡显示类型！ msgType = " .. tostring(msgType), ", bubblePos = " .. tostring(bubblePos))

		return
	end

	customData.msgType = msgType

	if customData.isCustomAvatar == nil then
		customData.isCustomAvatar = true
	end

	self:AddItemToList(customData)
end

function M:OnRenderChatItem(btn, index)
	index = index + 1
	local item = self.chatItemList[index]
	local processMsgFunc = self.ProcessMsgFunc[item.msgType]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store:EnableImmediatelyCommit(true)
	end

	self:RecordTeamMsg(item, btn, index)

	if (self.data.topChannelId == gChatTopChannel.Group or self:CheckIsLink()) and store and store.name then
		local sender = self:GetSender(index).pid

		gFriendManager:GetSimplePlayerInfoByPidList({
			sender
		}, function (data)
			store.name.text = data[1].Name
		end)

		store.showName = 1
	end

	processMsgFunc(self, item, store, btn)

	if not item.isCustomAvatar then
		self:SetChatItemAvatar(btn, item, index)
	end
end

function M:RecordTeamMsg(item, btn, index)
	if item.msgType ~= gChatConst.MessageType.Team then
		return
	end

	if not gChatGroupManager.nowShowTeam then
		gChatGroupManager.nowShowTeam = {}
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store:EnableImmediatelyCommit(true)
	end

	gChatGroupManager.nowShowTeam[index] = {
		teamid = item.msg.teamId,
		store = store
	}
	gChatGroupManager.nowShowTeam[index].store.indexzxxx = index
	gChatGroupManager.nowShowTeam[index].btn = btn
end

function M:RefreshTeamListData()
	if not gChatGroupManager.nowShowTeam then
		return
	end

	local startIndexOld = self.chatList.VirtualStartIndex
	local endIndexOld = self.chatList.VirtualEndIndex

	for index, v in pairs(gChatGroupManager.nowShowTeam) do
		if startIndexOld < index and index <= endIndexOld + 1 and v.store and v.btn and self.chatItemList[index] then
			local processMsgFunc = self.ProcessMsgFunc[gChatConst.MessageType.Team]

			processMsgFunc(self, self.chatItemList[index], v.store, v.btn)
		end
	end
end

function M:CheckIsLink()
	if self.data.topChannelId == gChatTopChannel.Channels and (self.data.subChannelId == UX.Game.MessageChannel.PrivateLink or self.data.subChannelId == UX.Game.MessageChannel.PublicLink or self.data.subChannelId == UX.Game.MessageChannel.MatchLink) then
		return true
	end

	return false
end

function M:SetChatItemAvatar(btn, item, index)
	local btnTransform = btn.transform
	local avatarGo = btnTransform:Find("ChatHead/S_ChatHeadTemplate") or btnTransform:Find("S_ChatHeadTemplate")
	local avatarWidget = avatarGo and avatarGo:GetComponent(typeof(SGUI.UWidget))

	if gClientUtils.IsNil(avatarWidget) then
		return
	end

	local sender = self:GetSender(index)

	gChatAvatarUtils:SetSingleAvatar(sender, avatarWidget)
end

function M:GetSender(index)
	local chatItem = self.chatItemList[index]

	if chatItem == nil then
		return nil
	end

	local msg = chatItem.msg

	if chatItem.sender == nil and msg then
		local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if chatCfg then
			chatItem.sender = ChatSenderId.New(chatCfg)
		else
			chatItem.sender = ChatSenderId.NewPlayer(msg.pid)
		end
	end

	return chatItem.sender
end

function M:OnGetChatItemTIndex(itemIndex)
	itemIndex = itemIndex + 1
	local chatItem = self.chatItemList[itemIndex]

	return chatItem.tIndex
end

function M:AddHint(content)
	self:AddCustomViewItem({
		content = content
	}, gChatConst.MessageType.Tips, "Mid")
end

function M:AddHintWithIcon(content)
	self:AddCustomViewItem({
		content = content
	}, gChatConst.MessageType.TipsWithIcon, "Mid")
end

function M:CheckDisplayNewFriend()
	if gChatTopChannel.Friend == self.topChannelId or gChatTopChannel.Npc == self.topChannelId and gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		self:AddHint(LTConfig.NPCChatConfig.NewFriendHint)
	end
end

function M:ShowBottom(isShow, onBegin, onComplete, instant)
	instant = instant or self.inInit

	self.cs:ShowBottom(isShow, onBegin, onComplete, instant)
end

function M:OnClose()
	if self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end

	if self.npcInviteGamePlay and self.npcInviteGamePlay ~= 0 then
		-- Nothing
	elseif self.topChannelId == gChatTopChannel.Group then
		gChatManager:UpdateCurrentChannel()
	else
		gChatManager:UpdateCurrentChannel(self.topChannelId)
	end

	if self.baseMap then
		gBaseMapMgr:Release(self.baseMap)

		self.baseMap = nil
	end
end

function M:RefreshAllMsg()
	local messages = self.currentChannelInfo.messages
	messages = messages and messages:ToTable()

	if gChatUtils.IsStoryChannel(self.topChannelId) then
		messages = gChatManager:FilterStoryMessages(messages)
	end

	if not table.isNilOrEmpty(messages) then
		for i = 1, #messages do
			self:AddNewChatMessage(messages[i])
		end

		self:AfterAddLastMessage(messages[#messages])
	else
		self:CheckDisplayNewFriend()
	end
end

function M:OnClearAndRefreshAllMsg()
	self:ClearChatItems()
	self:UpdateChatList(function ()
		self:RefreshAllMsg()
	end, false)
	self:ScrollTo(0, 0)
end

function M:OnDisable()
	if self.scrollTweener then
		self.scrollTweener:Kill()

		self.scrollTweener = nil
	end
end

function M:BeforeAddMessage(msg)
	return
end

function M:AfterAddMessage(msg)
	return
end

function M:AfterAddLastMessage(msg)
	return
end

function M:TryRemoveEllipsisBubble()
	return
end

function M:TryAddTimestamp(timeStamp)
	return
end
