-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\RoomChatStore.lua
-- Decompiled from: 01268_RoomChatStore.lua_73479c5bad46.luajit

local PrepareRoomState = UX.Game.PrepareRoomState
local UNavigationMgr = SGUI.UNavigationMgr
C_RoomChatStore = DefClass("C_RoomChatStore", C_RoomChatStore, C_StoreGroup)
GroupName2Class.RoomChatStore = C_RoomChatStore
local M = C_RoomChatStore

M.OnAwake = function(self)
	self.isPrepareStage = gLinkManager.currentLinkGame and gLinkManager.currentLinkGame.State ~= PrepareRoomState.Prepare and gLinkManager.currentLinkGame.StageId ~= LTConfig.LinkStageConfig.Prepare
	self.topChannelId = gChatTopChannel.Channels
	self.subChannelId = UX.Game.MessageChannel.Room
	self.msgCountLimit = 4
	self.pid = gPlayerManager.infoLogin.bindData.pid
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.normalBtn = gStoreManager:GetStoreGroup("ChatNormalBtnBarStore")

	self:SetNormalBtnBar()

	if self.bindData.chatList then
		self.hasChatList = true
		self.bindData.chatList.luaRenderItem = self.CreateAction(self, self.OnRenderComplexItem)
		self.bindData.chatList.onGetTIndex = self.CreateAction(self, self.OnComplexItemGetTIndex)
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
			self.AddNewChatMessage(self, messages[i])
		end
	end
end

M.OnDestroy = function(self)
	self:ClearMessageEvents()

	self.msgList = nil
	self.parentNaviArea = nil

	gChatManager:UpdateCurrentChannel()
end

M.SetNormalBtnBar = function(self)
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.normalBtn:SetData(data)
end

M.RegisterMessageEventHandlers = function(self)
	self.ClearMessageEvents(self)

	local msgEvents = {
		[gEventConstants.SOCIAL_CHAT_MESSAGE_CHANGED] = self.CreateAction(self, self.OnChatMessageChanged)
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnChatMessageChanged = function(self, _, data)
	if self.topChannelId ~= data.topChannelId and ulong.equals(self.subChannelId, data.subChannelId) and data.msg then
		self.AddNewChatMessage(self, data.msg)
	end
end

M.OnSendChatMsgOver = function(self, _, data)
end

M.AddNewChatMessage = function(self, msg)
	if self.msgCountLimit < #self.msgList then
		table.remove(self.msgList, 1)
	end

	table.insert(self.msgList, msg)
	self.bindData.list:SetSimpleList(#self.msgList)

	self.bindData.list.normalizedScrollPosition = Vector2.Fetch(0, 0)

	if self.hasChatList then
		table.insert(self.allMsgList, msg)
		self.bindData.chatList:SetList(#self.allMsgList)
	end
end

M.OnRenderItem = function(self, btn, index)
	local msg = self.msgList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local isMe = msg.pid ~= self.pid
	local format = isMe and LTConfig.LinkConfig.RoomChatFormatMe or LTConfig.LinkConfig.RoomChatFormatOther
	local playerName = gFriendManager:GetPlayerRealName(msg.pid)
	local content = gString.Format(format, playerName, msg.text)
	store.content = content
end

M.OnRenderComplexItem = function(self, btn, csIndex)
	local msg = self.allMsgList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local playerIndex = self:GetPlayerIndex(msg.pid) or 0
	store.mark = "[" .. playerIndex .. "]"
	store.name = gFriendManager:GetPlayerRealName(msg.pid)

	gChatAvatarUtils:SetSingleAvatar(ChatSenderId.NewPlayer(msg.pid), store.avatarWidget)

	if msg.msgType ~= gChatConst.MessageType.Voice then
		self.ProcessVoiceMsg(self, msg, store)
	else
		store.content = msg.text
	end
end

M.ProcessVoiceMsg = function(self, msg, store)
	store.content = math.max(math.ceil(msg.duration), 1)
	store.btn.luaClick = self.CreateActionWithArgs(self, self.OnClickAudioBubble, msg)
end

M.OnClickAudioBubble = function(self, msg)
	gCS.IMManager:StartPlayAudio(msg.msgId, msg.filePath)
end

M.OnComplexItemGetTIndex = function(self, csIndex)
	if self.allMsgList[csIndex + 1].msgType ~= gChatConst.MessageType.Voice then
		return self.allMsgList[csIndex + 1].pid ~= self.pid and 6 or 5
	end

	return self.allMsgList[csIndex + 1].pid ~= self.pid and 1 or 0
end

M.GetPlayerIndex = function(self, pid)
	if self.isPrepareStage then
		return self.GetPlayerIndexInPrepare(self, pid)
	else
		return self.GetPlayerIndexInRoom(self, pid)
	end
end

M.GetPlayerIndexInRoom = function(self, pid)
	local infos = gLinkManager:GetRoomPlayerInfo()

	for _, v in ipairs(infos) do
		if ulong.equals(pid, v.pid) then
			return v.id
		end
	end
end

M.GetPlayerIndexInPrepare = function(self, pid)
	local infos = gLinkManager.currentLinkGame and gLinkManager.currentLinkGame.PlayerInfos or {}

	for i, v in ipairs(infos) do
		if ulong.equals(pid, v.memberId) then
			return i
		end
	end
end

M.ActivateInputField = function(self)
	self.activeInputFieldCo = coroutine.start(function ()
		coroutine.wait(0.2)
		self.bindData.inputField:ActivateInputField()
	end)
end

M.SendChat = function(self, text)
	if not self.inputActive and string.is_null_or_empty(text) then
		self.ActivateInputField(self)

		return
	end

	gChatManager:TrySendChat(text, gChatTopChannel.Channels, UX.Game.MessageChannel.Room)
	self:ActivateInputField()
end

M.RegisterParentNaviArea = function(self, naviarea)
	self.parentNaviArea = naviarea
end

M.OnInputFieldActivate = function(self)
	self.inputActive = true

	if self.bindData.navigationArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.navigationArea
	end
end

M.OnInputFieldDeactivate = function(self)
	self.inputActive = false

	if self.parentNaviArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.parentNaviArea
	end
end
