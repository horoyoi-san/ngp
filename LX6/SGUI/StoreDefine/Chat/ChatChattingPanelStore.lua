-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChattingPanelStore.lua
-- Decompiled from: 01933_ChatChattingPanelStore.lua_349742268530.luajit

C_ChatChattingPanelStore = DefClass("C_ChatChattingPanelStore", C_ChatChattingPanelStore, C_AppFragmentStore)
local M = C_ChatChattingPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_Utils")
dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_Handler")

local ProcessMsgFunc = dofile("LX6/SGUI/StoreDefine/Chat/ChatChattingPanelStore_ProcessMsgFunc")

M.ctor = function(self)
	ProcessMsgFunc.OnConstruction(self)
end

M.OnAwake = function(self)
	self.cs = self.rootWidget:GetComponent(typeof(L18.Script.SGUI.Chat.ChatChattingPanel))
	self.cs.luaRenderItem = self:CreateAction(self.OnRenderChatItem)
	self.cs.luaClearAndRefreshAllMsg = self:CreateAction(self.OnClearAndRefreshAllMsg)
	self.cs.luaGetTIndex = self:CreateAction(self.OnGetChatItemTIndex)
	self.chatList = self.bindData.chatList
	self.chatList.poolMode = SGUI.EPoolMode.Default

	self:RegisterMessageEventHandlers()
	self:InitDataOnAwake()
end

M.InitDataOnAwake = function(self)
end

M.OnShow = function(self, tabIndex, data)
	self.data = data or {}
	self.inInit = true

	self:InitData()
	self:InitView()

	self.inInit = false
	self.refreshTimer = Timer.New(function ()
		self:RefreshTeamListData()
	end, 3, -1):Start()
end

M.OnUpdate = function(self)
	if self.interactiveChatItemBtnListDirty then
		self.UpdateInteractiveChatItemBtnList(self)

		self.interactiveChatItemBtnListDirty = false
	end
end

M.UpdateInteractiveChatItemBtnList = function(self)
end

M.InitData = function(self)
	self.interactiveMessageBtnList = {}
	self.interactiveChatItemBtnListDirty = true
	local top = self.data.topChannelId
	local sub = self.data.subChannelId

	if top ~= nil or sub ~= nil then
		top, sub = gChatManager:GetCurrentChannel()
	end

	self.topChannelId = top
	self.subChannelId = sub
	self.currentChannelInfo = gChatManager:GetChannel(top, sub)

	gChatManager:RequestStableList(top, sub)
	gChatManager:ResetUnreadCount(top, sub)
end

M.InitView = function(self)
	self:SetHeader()
	self.cs:ClearAndRefreshAllMsg()
end

M.SetHeader = function(self)
	if self.bindData.header ~= nil then
		return
	end

	gChatUtils.SetHeader(self.bindData.header, false, self.topChannelId, self.subChannelId)
end

M.ReceiveNewMessage = function(self, msg, skipScroll)
	if gClientUtils.NotNil(self.bindData.chatList) then
		self.UpdateChatList(self, function ()
			self:AddNewChatMessage(msg)
			self:AfterAddLastMessage(msg)
		end, not msg.isNpcChat)

		if not skipScroll then
			self.ScrollToBottom(self)
		end
	end
end

M.AddNewChatMessage = function(self, msg)
	local bubblePos = "Mid"

	if msg.templateMode ~= gChatConst.MsgTemplateMode.MyChat then
		bubblePos = "Right"
	elseif msg.templateMode ~= gChatConst.MsgTemplateMode.TheirChat then
		bubblePos = "Left"
	end

	self.BeforeAddMessage(self, msg)

	if msg.mode ~= gChatConst.MsgMode.Text and string.is_null_or_empty(msg.GetText(msg)) then
		self.AfterAddMessage(self, msg)

		return
	end

	self.AddViewItem(self, msg, bubblePos)
	self.AfterAddMessage(self, msg)
end

M.AddViewItem = function(self, msg, bubblePos)
	local msgType = msg.msgType
	local tIndex = gChatConst.MsgType2Template[msgType][bubblePos] or gChatConst.MsgType2Template[msgType].Mid

	if tIndex ~= nil then
		print_warn("ChatChattingPanel: 不支持的气泡显示类型！ msgType = " .. tostring(msgType), ", bubblePos = " .. tostring(bubblePos))

		return
	end

	local itemData = {
		msg = msg,
		tIndex = tIndex,
		msgType = msgType
	}

	if not msg.cfg then
		self.AddItemToList(self, itemData)

		return
	end

	if not msg.isNpcChat or msg.cfg.Message then
		self.AddItemToList(self, itemData)
	end
end

M.AddCustomViewItem = function(self, customData, msgType, bubblePos)
	customData.tIndex = gChatConst.MsgType2Template[msgType][bubblePos] or gChatConst.MsgType2Template[msgType].Mid

	if customData.tIndex ~= nil then
		print_warn("ChatChattingPanel: 不支持的气泡显示类型！ msgType = " .. tostring(msgType), ", bubblePos = " .. tostring(bubblePos))

		return
	end

	customData.msgType = msgType

	if customData.isCustomAvatar ~= nil then
		customData.isCustomAvatar = true
	end

	self.AddItemToList(self, customData)
end

M.OnRenderChatItem = function(self, btn, index)
	index = index + 1
	local item = self.chatItemList[index]
	local processMsgFunc = self.ProcessMsgFunc[item.msgType]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store.EnableImmediatelyCommit(store, true)
	end

	self.RecordTeamMsg(self, item, btn, index)

	if (self.data.topChannelId ~= gChatTopChannel.Group or self.CheckIsLink(self)) and store and store.name then
		local sender = self:GetSender(index).pid
		slot8 = gFriendManager

		slot8:GetSimplePlayerInfoByPidList({
			sender
		}, function (data)
			store.name.text = data[1].Name
		end)

		store.showName = 1
	end

	processMsgFunc(self, item, store, btn)

	if not item.isCustomAvatar then
		self.SetChatItemAvatar(self, btn, item, index)
	end
end

M.RecordTeamMsg = function(self, item, btn, index)
	if item.msgType == gChatConst.MessageType.Team then
		return
	end

	if not gChatGroupManager.nowShowTeam then
		gChatGroupManager.nowShowTeam = {}
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store.EnableImmediatelyCommit(store, true)
	end

	gChatGroupManager.nowShowTeam[index] = {
		teamid = item.msg.teamId,
		store = store
	}
	gChatGroupManager.nowShowTeam[index].store.indexzxxx = index
	gChatGroupManager.nowShowTeam[index].btn = btn
end

M.RefreshTeamListData = function(self)
	if not gChatGroupManager.nowShowTeam then
		return
	end

	local startIndexOld = self.chatList.VirtualStartIndex
	local endIndexOld = self.chatList.VirtualEndIndex

	for index, v in pairs(gChatGroupManager.nowShowTeam) do
		if startIndexOld >= index and index < endIndexOld + 1 and v.store and v.btn and self.chatItemList[index] then
			local processMsgFunc = self.ProcessMsgFunc[gChatConst.MessageType.Team]

			processMsgFunc(self, self.chatItemList[index], v.store, v.btn)
		end
	end
end

M.CheckIsLink = function(self)
	if self.data.topChannelId ~= gChatTopChannel.Channels and (self.data.subChannelId ~= UX.Game.MessageChannel.PrivateLink or self.data.subChannelId ~= UX.Game.MessageChannel.PublicLink or self.data.subChannelId ~= UX.Game.MessageChannel.MatchLink) then
		return true
	end

	return false
end

M.SetChatItemAvatar = function(self, btn, item, index)
	local btnTransform = btn.transform
	local avatarGo = btnTransform:Find("ChatHead/S_ChatHeadTemplate") or btnTransform:Find("S_ChatHeadTemplate")
	local avatarWidget = avatarGo and avatarGo:GetComponent(typeof(SGUI.UWidget))

	if gClientUtils.IsNil(avatarWidget) then
		return
	end

	local sender = self:GetSender(index)

	gChatAvatarUtils:SetSingleAvatar(sender, avatarWidget)
end

M.GetSender = function(self, index)
	local chatItem = self.chatItemList[index]

	if chatItem ~= nil then
		return nil
	end

	local msg = chatItem.msg

	if chatItem.sender ~= nil and msg then
		local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if chatCfg then
			chatItem.sender = ChatSenderId.New(chatCfg)
		else
			chatItem.sender = ChatSenderId.NewPlayer(msg.pid)
		end
	end

	return chatItem.sender
end

M.OnGetChatItemTIndex = function(self, itemIndex)
	itemIndex = itemIndex + 1
	local chatItem = self.chatItemList[itemIndex]

	return chatItem.tIndex
end

M.AddHint = function(self, content)
	self.AddCustomViewItem(self, {
		content = content
	}, gChatConst.MessageType.Tips, "Mid")
end

M.AddHintWithIcon = function(self, content)
	self.AddCustomViewItem(self, {
		content = content
	}, gChatConst.MessageType.TipsWithIcon, "Mid")
end

M.CheckDisplayNewFriend = function(self)
	if gChatTopChannel.Friend ~= self.topChannelId or gChatTopChannel.Npc ~= self.topChannelId and gChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		self.AddHint(self, LTConfig.NPCChatConfig.NewFriendHint)
	end
end

M.ShowBottom = function(self, isShow, onBegin, onComplete, instant)
	instant = instant or self.inInit

	self.cs:ShowBottom(isShow, onBegin, onComplete, instant)
end

M.OnClose = function(self)
	if self.refreshTimer then
		self.refreshTimer:Stop()

		self.refreshTimer = nil
	end

	if self.npcInviteGamePlay and self.npcInviteGamePlay == 0 then
		-- Nothing
	elseif self.topChannelId ~= gChatTopChannel.Group then
		gChatManager:UpdateCurrentChannel()
	else
		gChatManager:UpdateCurrentChannel(self.topChannelId)
	end

	if self.baseMap then
		gBaseMapMgr:Release(self.baseMap)

		self.baseMap = nil
	end
end

M.RefreshAllMsg = function(self)
	local messages = self.currentChannelInfo.messages
	messages = messages and messages:ToTable()

	if gChatUtils.IsStoryChannel(self.topChannelId) then
		messages = gChatManager:FilterStoryMessages(messages)
	end

	if not table.isNilOrEmpty(messages) then
		for i = 1, #messages do
			self.AddNewChatMessage(self, messages[i])
		end

		self.AfterAddLastMessage(self, messages[#messages])
	else
		self.CheckDisplayNewFriend(self)
	end
end

M.OnClearAndRefreshAllMsg = function(self)
	self.ClearChatItems(self)
	self.UpdateChatList(self, function ()
		self:RefreshAllMsg()
	end, false)
	self.ScrollTo(self, 0, 0)
end

M.OnDisable = function(self)
	if self.scrollTweener then
		self.scrollTweener:Kill()

		self.scrollTweener = nil
	end
end

M.BeforeAddMessage = function(self, msg)
end

M.AfterAddMessage = function(self, msg)
end

M.AfterAddLastMessage = function(self, msg)
end

M.TryRemoveEllipsisBubble = function(self)
end

M.TryAddTimestamp = function(self, timeStamp)
end
