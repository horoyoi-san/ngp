-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChattingPanelStore.lua
-- Decompiled from: 01956_NpcChatChattingPanelStore.lua_babc7fe00d93.luajit

C_NpcChatChattingPanelStore = DefClass("C_NpcChatChattingPanelStore", C_NpcChatChattingPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatChattingPanelStore = C_NpcChatChattingPanelStore
local M = C_NpcChatChattingPanelStore

dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Utils")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Handler")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_ProcessMsgFunc")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Gamepad")

M.ctor = function(self)
	local const = gNpcChatConst
	self._lastClearAndRefreshFrame = 0
	self._clearAndRefreshCallCount = 0
	self._clearAndRefreshRetryTimer = nil
	self.chatItemList = {}
	self.ProcessMsgFunc = {
		[const.MessageType.Text] = "ProcessTextMsg",
		[const.MessageType.Waiting] = "ProcessWaitingMsg",
		[const.MessageType.Voice] = "ProcessVoiceMsg",
		[const.MessageType.Restaurant] = "ProcessRestaurantMsg",
		[const.MessageType.Map] = "ProcessMapMsg",
		[const.MessageType.Photo] = "ProcessPhotoMsg",
		[const.MessageType.Emoji] = "ProcessEmojiMsg",
		[const.MessageType.Link] = "ProcessLinkMsg",
		[const.MessageType.BubbleNotice] = "ProcessBubbleNoticeMsg",
		[const.MessageType.Money] = "ProcessMoneyMsg",
		[const.MessageType.HintSimple] = "ProcessTipsMsg",
		[const.MessageType.Tips] = "ProcessTipsMsg",
		[const.MessageType.Task] = "ProcessTaskMsg",
		[const.MessageType.TipsWithIcon] = "ProcessTipsMsg"
	}
	self.optionListData = {}
end

M.OnAwake = function(self)
	self.cs = self.rootWidget:GetComponent(typeof(L18.Script.SGUI.Chat.NpcChatChattingPanel))
	self.cs.luaRenderItem = self:CreateAction("OnRenderChatItem")
	self.cs.luaClearAndRefreshAllMsg = self:CreateAction("OnClearAndRefreshAllMsg")
	self.cs.luaGetTIndex = self:CreateAction("OnGetChatItemTIndex")
	self.chatList = self.bindData.chatList
	self.chatList.poolMode = SGUI.EPoolMode.Default
	self.isTalkingToPlayer = false

	self:RegisterMessageEventHandlers()
	self:InitDataOnAwake()

	if self.bindData.optionList then
		self.optionList = self.bindData.optionList
		self.optionList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderOptionItem")
		self.optionList.luaSimpleClick = self.CreateAction(self, "OnClickOptionItem")
		self.optionList.onGetTIndex = self.CreateAction(self, "OnGetOptionListTIndex")
	end

	self.bindData.bgBtn.luaClick = self.CreateAction(self, "OnClickChatBG")
	self.bindData.skillAllBtn.luaClick = self.CreateAction(self, "OnClickSkillAllBtn")

	self.OnAwake_Gamepad(self)
end

M.InitDataOnAwake = function(self)
	self.needClickItem = {}
	self.clickedMsgIds = {}
	self.lastClickBgTime = 0
	self.clickBgCooldown = 0.2
	self.isSkippingToEnd = false
	self.chatTimeoutTimer = nil
	self.chatTimeoutDuration = 6
	self.isWaitingForResponse = false
	self.chatInitCheckTimer = nil
end

M.StartChatTimeout = function(self, chatId)
	self:ClearChatTimeout()

	self.isWaitingForResponse = true
	self.chatTimeoutTimer = Timer.New(function ()
		self:OnChatTimeout(chatId)
	end, self.chatTimeoutDuration):Start()
end

M.ClearChatTimeout = function(self)
	if self.chatTimeoutTimer then
		self.chatTimeoutTimer:Stop()

		self.chatTimeoutTimer = nil
	end

	if self.chatInitCheckTimer then
		self.chatInitCheckTimer:Stop()

		self.chatInitCheckTimer = nil
	end

	self.isWaitingForResponse = false
end

M.OnChatTimeout = function(self, chatId)
	print_error("#NoCreateIssue @zhangzhiyuan NPC聊天超时，可能是网络问题或chatId配置问题:", chatId)
	self.ClearChatTimeout(self)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)

	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.isSendingNpcChat = false
end

M.OnShow = function(self, tabIndex, data)
	self:ShowBottom(false)

	self.data = data or {}
	self.lastMessage = nil
	gNpcChatManager.SkipAll = false
	self.inInit = true
	self.optionListData = {}

	if self.optionList then
		self.optionList:SetSimpleList(0)
	end

	self:InitData()
	self:InitView()

	self.inInit = false
	self.waitForEllipsisBubble = false
	local cfg = data.chatMessage and data.chatMessage.cfg or data.cfg

	if gNpcChatUtils.ShouldAskReadChat(cfg) then
		slot4 = gClientToGameDelegate

		slot4:AskMarkNpcChatRead(cfg.Id).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end

	self.chatInitCheckTimer = Timer.New(function ()
		if #self.chatItemList ~= 0 and self.optionListData and #self.optionListData ~= 0 then
			self:StartChatTimeout(cfg and cfg.Id or 0)
		end

		self.chatInitCheckTimer = nil
	end, 3, 1):Start()
end

M.OnUpdate = function(self)
	if self.interactiveChatItemBtnListDirty then
		self.UpdateInteractiveChatItemBtnList(self)

		self.interactiveChatItemBtnListDirty = false
	end
end

M.InitData = function(self)
	self.interactiveMessageBtnList = {}
	self.interactiveChatItemBtnListDirty = true
	local top = self.data.topChannelId
	local sub = self.data.subChannelId

	if top ~= nil or sub ~= nil then
		top, sub = gNpcChatManager:GetCurrentChannel()
	end

	self.topChannelId = top
	self.subChannelId = sub
	self.currentChannelInfo = gNpcChatManager:GetChannel(top, sub)

	gNpcChatManager:ResetUnreadCount(top, sub)
end

M.InitView = function(self)
	self:SetHeader()
	self.cs:ClearAndRefreshAllMsg()

	if self.bindData.showSkipBtnCtrl then
		self.bindData.showSkipBtnCtrl = 0
	end

	self.chatList:RegisterToScrollEvent(self:CreateAction("OnListScroll"))

	if self.bindData.optionList then
		self.bindData.optionList.poolMode = SGUI.EPoolMode.Default
	end
end

M.SetHeader = function(self)
	if self.bindData.header ~= nil then
		return
	end

	gNpcChatUtils.SetHeader(self.bindData.header, false, self.topChannelId, self.subChannelId)
end

M.ReceiveNewMessage = function(self, msg, skipScroll)
	if not self.isSkippingToEnd then
		self.isSendingNpcChat = false
	end

	if gClientUtils.NotNil(self.bindData.chatList) then
		if gNpcChatManager.SkipAll then
			self.UpdateChatContent(self, msg)

			return
		end

		if msg.cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake and gNpcChatUtils.HasNextMessage(msg) and gNpcChatUtils.IsCurrentInChatPage() then
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)
		end

		slot3 = self.cs

		slot3:EnableNpcChatItemAnim(true)
		self:UpdateChatList(function ()
			self:AddNewChatMessage(msg)
			self:AfterAddLastMessage(msg)
		end, true, msg)

		if not skipScroll and gNpcChatUtils.IsCurrentInChatPage() then
			self.ScrollToBottom(self)
		end

		self.RefreshSkipAllBtnByMessage(self, msg)
	end
end

M.AddNewChatMessage = function(self, msg)
	self.BeforeAddMessage(self, msg)

	if msg.msgType ~= gNpcChatConst.MessageType.Text and string.is_null_or_empty(msg.GetText(msg)) then
		self.AfterAddMessage(self, msg)

		return
	end

	self.AddViewItem(self, msg)
	self.AfterAddMessage(self, msg)
end

M.AddViewItem = function(self, msg)
	if self.isWaitingForResponse then
		self.ClearChatTimeout(self)
	end

	local bubblePos = "Mid"

	if msg.cfg and msg.cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local curNpcId = gNpcChatUtils.GetCurrentNpcId()
		local speaker = msg.cfg.Speaker == 0 and msg.cfg.Speaker or curNpcId

		if curNpcId ~= speaker or not msg.fromOther and speaker ~= msg.cfg.AsNpcCultivation and curNpcId ~= msg.cfg.SpecialReadableCharacter then
			bubblePos = "Right"
		else
			bubblePos = "Left"
		end
	elseif msg.templateMode ~= gNpcChatConst.ChatMsgTemplateMode.MyChat then
		bubblePos = "Right"
	elseif msg.templateMode ~= gNpcChatConst.ChatMsgTemplateMode.TheirChat then
		bubblePos = "Left"
	end

	if self.isTalkingToPlayer then
		if bubblePos ~= "Left" then
			bubblePos = "Right"
		elseif bubblePos ~= "Right" then
			bubblePos = "Left"
		end
	end

	local msgType = msg.msgType
	local tIndex = gNpcChatConst.MsgType2Template[msgType][bubblePos] or gNpcChatConst.MsgType2Template[msgType].Mid

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

	if gNpcChatUtils.GetMessage(msg.cfg) then
		self.AddItemToList(self, itemData)
	end
end

M.AddCustomViewItem = function(self, customData, msgType, bubblePos)
	if self.isTalkingToPlayer then
		if bubblePos ~= "Left" then
			bubblePos = "Right"
		elseif bubblePos ~= "Right" then
			bubblePos = "Left"
		end
	end

	customData.tIndex = gNpcChatConst.MsgType2Template[msgType][bubblePos] or gNpcChatConst.MsgType2Template[msgType].Mid

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

	if not item then
		local t = debug.traceback()

		print_warn("npcChatChattingPanel: OnRenderChatItem 找不到对应的 chatItem! index = " .. tostring(index), t)

		return
	end

	local processMsgFuncName = self.ProcessMsgFunc[item.msgType]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store.EnableImmediatelyCommit(store, true)
	end

	item.store = store

	if self.topChannelId ~= gNpcChatConst.ChatTopChannel.NpcGroup and store and store.name then
		local sender = self:GetSender(index)
		local npcId = sender and sender.npcId or 1
		local asNpc = npcId == 0 and npcId or gNpcChatUtils.GetCurrentNpcId()

		if asNpc == 1 then
			local npcInfo = LTConfig.NPCChatNpcConfig.GetConfig(asNpc) or LTConfig.NpcCultivationConfig.GetConfig(asNpc)

			if npcInfo then
				store.name.text = npcInfo.NpcName or npcInfo.Name
			end
		else
			store.name.text = gPlayerManager.infoLogin.bindData.name
		end

		store.showName = 1
	elseif store and store.showName == nil then
		store.showName = 0
	end

	if processMsgFuncName and self[processMsgFuncName] then
		self[processMsgFuncName](self, item, store, btn)
	end

	if not item.isCustomAvatar then
		self.SetChatItemAvatar(self, btn, item, index)
	end
end

M.SetChatItemAvatar = function(self, btn, item, index)
	local btnTransform = btn.transform
	local avatarGo = btnTransform:Find("ChatHead/S_MessageHeadTemplate") or btnTransform:Find("S_MessageHeadTemplate") or btnTransform:Find("ChatHead/S_ChatHeadTemplate") or btnTransform:Find("S_ChatHeadTemplate")
	local avatarWidget = avatarGo and avatarGo:GetComponent(typeof(SGUI.UWidget))

	if gClientUtils.IsNil(avatarWidget) then
		return
	end

	local sender = self:GetSender(index)

	gNpcChatAvatarUtils:SetSingleAvatar(sender, avatarWidget)
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
			chatItem.sender = NpcChatSenderId.New(chatCfg)
		else
			chatItem.sender = NpcChatSenderId.NewPlayer(msg.pid)
		end
	end

	return chatItem.sender
end

M.OnGetChatItemTIndex = function(self, itemIndex)
	itemIndex = itemIndex + 1
	local chatItem = self.chatItemList[itemIndex]

	if not chatItem then
		local t = debug.traceback()

		print_warn("npcChatChattingPanel: OnGetChatItemTIndex 找不到对应的 chatItem! itemIndex = " .. tostring(itemIndex), t)

		if itemIndex ~= 0 then
			if not self._refreshChatListTimer then
				self._refreshChatListTimer = FrameTimer.New(function ()
					if gClientUtils.NotNil(self.chatList) then
						self.chatList:SetList(#self.chatItemList, false, 0)
					end

					self._refreshChatListTimer = nil
				end, 2, 1):Start()
			end

			return 0
		end
	end

	return chatItem.tIndex
end

M.AddHint = function(self, content)
	self.AddCustomViewItem(self, {
		content = content
	}, gNpcChatConst.MessageType.Tips, "Mid")
end

M.AddHintWithIcon = function(self, content)
	self.AddCustomViewItem(self, {
		content = content
	}, gNpcChatConst.MessageType.TipsWithIcon, "Mid")
end

M.CheckDisplayNewFriend = function(self)
	if gNpcChatConst.ChatTopChannel.Npc ~= self.topChannelId and gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		self.AddHint(self, LTConfig.NPCChatConfig.NewFriendHint)
	end
end

M.ShowBottom = function(self, isShow, onBegin, onComplete, instant)
	local OnBegin = function()
		self:ShowBottom_Gamepad(isShow)

		if onBegin then
			onBegin()
		end
	end

	self.chatFinishHintShowing = false
	instant = instant or self.inInit

	self.cs:ShowBottom(isShow, OnBegin, onComplete, instant)
end

M.OnClose = function(self)
	self.isSendingNpcChat = false
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	self.selfMessageCoroutine = coroutine.stop(self.selfMessageCoroutine)

	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = false

	if self._clearAndRefreshRetryTimer then
		self._clearAndRefreshRetryTimer:Stop()

		self._clearAndRefreshRetryTimer = nil
	end

	self.ClearChatTimeout(self)

	gNpcChatManager.rollToCfgId = nil

	if not self.npcInviteGamePlay or self.npcInviteGamePlay ~= 0 then
		gNpcChatManager:UpdateCurrentChannel(self.topChannelId)
	end

	if self.baseMap then
		gBaseMapMgr:Release(self.baseMap)

		self.baseMap = nil
	end

	local messages = self.currentChannelInfo.messages

	if messages then
		for index, msg in ipairs(messages) do
			if gNpcChatUtils.IsVisibleToCurrentNpc(msg.npcChatId) then
				self.currentChannelInfo.messages[index].isHistory = true
			end
		end
	end
end

M.RefreshAllMsg = function(self)
	self.lastMessage = nil

	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		local specialAsNpc = nil
		local cfg = self.data.cfg
		local specialReadableCharacter = cfg and cfg.SpecialReadableCharacter or nil

		if specialReadableCharacter ~= gNpcChatUtils.GetCurrentNpcId() then
			specialAsNpc = cfg.AsNpcCultivation
		end

		gNpcChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gNpcChatManager.currentNpcChatType, specialAsNpc)
	else
		local messages = gNpcChatUtils.GetNormalAndOtherToSelfMessages(self.currentChannelInfo)

		if not table.isNilOrEmpty(messages) then
			local segments = gNpcChatManager:GroupMessagesBySegment(messages)
			segments = gNpcChatManager:SortSegmentsByLastMessageTime(segments)

			for segmentIndex, segment in ipairs(segments) do
				for msgIndex, msg in ipairs(segment) do
					msg.isHistory = true

					self.AddNewChatMessage(self, msg)
				end
			end

			if #segments <= 0 and #segments[#segments] <= 0 then
				local lastSegment = segments[#segments]

				self.AfterAddLastMessage(self, lastSegment[#lastSegment])
				self.RefreshSkipAllBtnByMessage(self, lastSegment[#lastSegment])
			else
				self.bindData.showSkipBtnCtrl = 0
			end
		end
	end
end

M.ShouldShowSkipAllBtn = function(self, msg)
	if not msg or not gNpcChatUtils.HasNextMessage(msg) then
		return false
	end

	local index = gNpcChatManager:GetMessageIndexInSegment(self.topChannelId, self.subChannelId, msg.npcChatId)

	return index == nil and index < 3
end

M.RefreshSkipAllBtnByMessage = function(self, msg)
	self.bindData.showSkipBtnCtrl = self:ShouldShowSkipAllBtn(msg) and 1 or 0
end

M.OnClearAndRefreshAllMsg = function(self)
	if not self.STATE_EnableOnce or not gClientUtils.NotNil(self.bindData.chatList) or not gClientUtils.NotNil(self.chatList) or not self.cs then
		if not self._clearAndRefreshRetryTimer then
			self._clearAndRefreshRetryTimer = FrameTimer.New(function ()
				self._clearAndRefreshRetryTimer = nil

				self:OnClearAndRefreshAllMsg()
			end, 4, 1):Start()
		end

		return
	end

	if self._clearAndRefreshRetryTimer then
		self._clearAndRefreshRetryTimer:Stop()

		self._clearAndRefreshRetryTimer = nil
	end

	local currentFrame = Time.frameCount

	if self._lastClearAndRefreshFrame ~= currentFrame then
		self._clearAndRefreshCallCount = self._clearAndRefreshCallCount + 1

		print_error("@zhangzhiyuan06 NpcChatChattingPanelStore.OnClearAndRefreshAllMsg: Warning - 同一帧内第 " .. self._clearAndRefreshCallCount .. " 次调用, frameCount=" .. currentFrame)
	else
		self._lastClearAndRefreshFrame = currentFrame
		self._clearAndRefreshCallCount = 1
	end

	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = false

	self.ClearChatItems(self)
	self.UpdateChatList(self, function ()
		self:RefreshAllMsg()
	end, false)

	if gNpcChatManager.rollToCfgId then
		local targetCfgId = gNpcChatManager.rollToCfgId
		gNpcChatManager.rollToCfgId = nil
		local targetIndex = nil

		for i, itemData in ipairs(self.chatItemList) do
			if itemData.msg and itemData.msg.npcChatId ~= targetCfgId then
				targetIndex = i

				break
			end
		end

		if targetIndex then
			self.ScrollToMessageByIndex(self, targetIndex)
		end
	end
end

M.OnDisable = function(self)
	if self.lastMessage and not gNpcChatUtils.HasNextMessage(self.lastMessage) then
		gClientToGameSceneDelegate:AskCloseNpcChatWnd(self.lastMessage.npcChatId)
		gMessageManager:SendMessage(gEventConstants.NPC_CHAT_PANEL_CLOSE, self.lastMessage.npcChatId)
	end

	if self.scrollTweener then
		self.scrollTweener:Kill()

		self.scrollTweener = nil
	end

	self.OnDisable_Gamepad(self)

	self.npcInviteGamePlay = 0
end

M.BeforeAddMessage = function(self, msg)
	if msg.isSkipAllMessage then
		self.TryRemoveEllipsisBubble(self)

		return
	end

	if self.lastMessage and not gNpcChatUtils.IsNextMessage(self.lastMessage, msg) then
		self:RemoveSpecificItem()
		self:AddCustomViewItem({
			["@Fb[K="] = true,
			content = LTConfig.NPCChatConfig.HistoryMessageSeparatorText or "----"
		}, gNpcChatConst.MessageType.Tips, "Mid")
	end

	self.TryRemoveEllipsisBubble(self)
end

M.TryAddTimestamp = function(self, timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp ~= nil or timestamp - lastTimestamp <= 300 then
		self.AddCustomViewItem(self, {
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gNpcChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

M.AfterAddMessage = function(self, msg)
	self.lastMessage = msg
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if not string.is_null_or_empty(chatCfg.MessageText) then
		self.AddHintWithIcon(self, chatCfg.MessageText)
	end

	if chatCfg.Eventid <= 0 then
		self.AddTaskBubble(self, msg)
	end

	if chatCfg.CustomChatType ~= LTConfig.NPCChatConfig.CustomChatTypeType.StoryTap then
		local bubblePos = chatCfg.Speaker ~= gNpcChatUtils.GetCurrentNpcId() and "Left" or "Right"

		self:AddCustomViewItem({
			context = msg.chatContext
		}, gNpcChatConst.MessageType.BubbleNotice, bubblePos)
	end
end

M.AfterAddLastMessage = function(self, msg)
	self:RefreshNpcChatOptions(msg)

	local nextNpcChatId = msg.npcNextChatId <= 0 and msg.npcNextChatId or msg.cfg.NextMessage[1]

	if gNpcChatUtils.IsNextNpcMessage(msg) then
		self.AddEllipsisBubble(self, "Left", nextNpcChatId)
	elseif gNpcChatUtils.IsNextPlayerEllipsis(msg.npcChatId) then
		self.AddEllipsisBubble(self, "Right", nextNpcChatId)
	elseif not gNpcChatUtils.HasNextMessage(msg) then
		self.OnChatFinish(self)
	end
end

M.OnChatFinish = function(self)
	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self.CheckSpecialItemAllClicked(self, gNpcChatConst.CloseButtonType.ClosePhone)
	elseif gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		gNpcChatManager.FakeChatAutoPlay = false
	else
		self.CheckSpecialItemAllClicked(self, gNpcChatConst.CloseButtonType.Return)
	end

	if not self.isSkippingToEnd then
		gNpcChatManager.SkipAll = false
	end

	self.AddFinishedHint(self)
end

M.CheckSpecialItemAllClicked = function(self, closeType)
	self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	self.CheckSpecialItemAllClickedCo = coroutine.start(function ()
		while self.needClickItem and next(self.needClickItem) == nil do
			coroutine.wait(1)
		end

		gNpcChatUtils.SetCloseType(closeType)
	end)
end

M.BeginInviteNpcChat = function(self, chatCfg, inviteGameplayId)
	if self.inviteNpcChatCo then
		coroutine.stop(self.inviteNpcChatCo)
	end

	self.npcInviteGamePlay = inviteGameplayId
	self.inviteNpcChatCo = coroutine.start(function ()
		while gClientUtils.IsNil(self.optionList) do
			coroutine.step()
		end

		self.inInit = true

		self:RefreshNpcChatOptions(nil, chatCfg)

		self.inInit = false
		self.inviteNpcChatCo = nil
	end)
end

M.RefreshNpcChatOptions = function(self, msg, inviteChatCfg)
	local nextChatCfgList = {}
	local lastChatId = nil

	if inviteChatCfg then
		table.insert(nextChatCfgList, inviteChatCfg)

		lastChatId = inviteChatCfg.Id
	elseif msg then
		lastChatId = msg.npcChatId
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

		if lastChatCfg and lastChatCfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake and not gNpcChatUtils.IsVisibleToCurrentNpc(lastChatId) then
			self.ShowBottom(self, false)

			return
		end

		if lastChatCfg and gNpcChatUtils.HasNextMessage(msg) and not gNpcChatUtils.IsNextPlayerEllipsis(lastChatId) then
			for _, v in ipairs(lastChatCfg.NextMessage) do
				local cfg = LTConfig.NPCChatConfig.GetConfig(v)

				if cfg and cfg.IsPlayerMessage then
					table.insert(nextChatCfgList, cfg)
				end
			end
		end
	end

	local options = gNpcChatUtils.TurnChatCfgListToOptions(nextChatCfgList)

	if #options <= 0 then
		if self.CheckIsFake(self, true) then
			self.ShowBottom(self, false)
			self.AddEllipsisBubble(self, "Right", nextChatCfgList[1].Id)
			self.DoAutoClick(self, msg)

			return
		end

		if self.bindData.optionNavArea then
			self.bindData.optionNavArea.enabled = true
		end

		self.optionListData = options

		self.optionList:SetSimpleList(#options)
		self:ShowBottom(true)

		if lastChatId then
			local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

			if gNpcChatUtils.ShouldAskReadChat(lastChatCfg) then
				local doMarkRead = function()
					slot0 = gClientToGameDelegate

					slot0:AskMarkNpcChatRead(lastChatId).Callback = function (err)
						if err == LTConfig.MessageConfig.Ok then
							gDisplayMessageMgr:DisplayServerMessageId(err)

							return
						end
					end
				end

				if gNpcChatManager.isSceneLoading or gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
					table.insert(gNpcChatManager.waitSceneLoadCallBack, doMarkRead)
				else
					doMarkRead()
				end
			end
		end
	else
		self.ShowBottom(self, false)
		self.DoAutoClick(self, msg)
	end
end

M.DoAutoClick = function(self, msg)
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.AutoClickChatBGCo = coroutine.start(function ()
		local nextChatCfgId = gNpcChatUtils.GetNextNpcChatId(msg)

		if nextChatCfgId ~= 0 then
			return
		end

		local nextChatCfg = LTConfig.NPCChatConfig.GetConfig(nextChatCfgId)
		local time = self:CalcAutoClickTime(nextChatCfg)

		coroutine.wait(time)

		while self.waitForEllipsisBubble do
			coroutine.step()
		end

		if self.bActive and self.rootWidget.activation then
			self.AutoClickChatBGCo = nil

			self:OnClickChatBG()
		end
	end)
end

M.AddEllipsisBubble = function(self, bubblePos, npcChatId)
	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = true
	local delayElapsed = false
	self.addEllipsisBubbleTimer = Timer.New(function ()
		if not delayElapsed then
			delayElapsed = true

			return
		end

		if not self.cs or not self.cs.isScrolling then
			self.addEllipsisBubbleTimer:Stop()

			self.addEllipsisBubbleTimer = nil
			local msg = {
				npcChatId = npcChatId
			}
			local customData = {
				["\\xee\\x892\\xf9\\xe9˞\\xec\\x96!:"] = false,
				msg = msg
			}

			self:UpdateChatList(function ()
				local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

				if string.is_null_or_empty(gNpcChatUtils.GetMessage(cfg)) then
					return
				end

				self:AddCustomViewItem(customData, gNpcChatConst.MessageType.Waiting, bubblePos)
			end, true)
			self:ScrollToBottom()

			self.waitForEllipsisBubble = false
		end
	end, 0.01, -1):Start()

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_FINISH, npcChatId)
end

M.AddTaskBubble = function(self, msg)
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(chatCfg.Eventid)

	if taskEventCfg ~= nil then
		return
	end

	local customData = {
		title = taskEventCfg.EventName,
		eventId = chatCfg.Eventid,
		isFinish = gTaskNodeManager:GetTaskLineState(chatCfg.Eventid) ~= gTaskLineState.Finish,
		msg = msg
	}

	self:AddCustomViewItem(customData, gNpcChatConst.MessageType.Task, "Mid")
end

M.TryRemoveEllipsisBubble = function(self)
	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = false
	self._ellipsisBubbleDelayElapsed = nil
	local lastItem = self.chatItemList[#self.chatItemList]

	if lastItem and lastItem.msgType ~= gNpcChatConst.MessageType.Waiting then
		self.RemoveLastItem(self)
	end
end

M.OnRenderOptionItem = function(self, btn, csIndex)
	local data = self.optionListData[csIndex + 1]

	if not data then
		return
	end

	if csIndex ~= 0 then
		if self.bindData.optionNavArea then
			self.bindData.optionNavArea.CurrentActiveContent = btn
		end

		self.firstOptionBtn = btn
	end

	if data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.emoji = data.cfg.SIcon
	else
		local label = btn.GetComponentInChildren(btn, typeof(SGUI.UBaseText))
		label.text = gClientUtils.RichTextToPlain(data.content)
	end
end

M.OnClickOptionItem = function(self, _, index)
	local data = self.optionListData[index + 1]

	if not data then
		return
	end

	if self.isSendingNpcChat then
		return
	end

	self.OnClickNPCOption(self, data.cfg.Id, nil, function (success)
		if success and self.STATE_EnableOnce and not self.chatFinishHintShowing then
			if self.optionList then
				self.optionList:SetActive(true)

				self.optionList.enabled = true
				self.optionListData = {}

				self.optionList:SetSimpleList(0)
			end

			self:ShowBottom(false)
		end
	end)
end

M.OnGetOptionListTIndex = function(self, index)
	local data = self.optionListData[index + 1]

	return data and data.tIndex or 0
end

M.OnClickChatBG = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if self.lastMessage and self.lastMessage.cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local currentTime = Time.unscaledTime

		if currentTime - self.lastClickBgTime >= self.clickBgCooldown then
			return
		end

		self.lastClickBgTime = currentTime
	end

	local lastMessage = self.lastMessage

	if lastMessage ~= nil or self.isSendingNpcChat then
		return
	end

	if #lastMessage.cfg.NextMessage ~= 0 and lastMessage.npcNextChatId ~= 0 then
		return
	end

	if self.waitForEllipsisBubble then
		return
	end

	if self.isSkippingToEnd or gNpcChatManager.SkipAll then
		slot2 = gClientToGameDelegate

		slot2:InteractNpcChat(lastMessage.npcChatId).Callback = function (err)
		end

		return
	end

	local msgId = lastMessage.msgId
	self.bindData.lastInteractedMsgId = msgId

	if self.CheckIsFake(self) then
		return
	end

	if gNpcChatUtils.IsNextNpcMessage(lastMessage) then
		self.isSendingNpcChat = true

		self:StartChatTimeout(lastMessage.npcChatId)

		slot3 = gClientToGameDelegate

		slot3:InteractNpcChat(lastMessage.npcChatId).Callback = function (err)
			if self ~= nil or gClientUtils.IsNil(self.rootGo) then
				return
			end

			if err ~= LTConfig.MessageConfig.TimeOut then
				self:OnChatTimeout(lastMessage.npcChatId)
			elseif err ~= LTConfig.MessageConfig.NpcChatFinished then
				if gNpcChatUtils.HasNextMessage(lastMessage) then
					gNpcChatManager:RemoveNpcChatSegment(lastMessage.npcChatId, lastMessage.cfg.AsNpcCultivation)
				end
			elseif err == LTConfig.MessageConfig.Ok then
				print_error("#NoCreateIssue ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage.npcChatId)
				gClientUtils.CloseMainPhonePanel()
				gNpcChatManager:ClearAllNpcDialogChat()
			end
		end
	elseif gNpcChatUtils.IsNextPlayerEllipsis(lastMessage.npcChatId) then
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastMessage.npcChatId)

		self.OnClickNPCOption(self, lastChatCfg.NextMessage[1])

		self.waitShowMyChatItemTime = 0
	end
end

M.CheckIsFake = function(self, isRefreshNpc)
	if self.lastMessage and self.lastMessage.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local nextChatId = self.lastMessage.cfg.NextMessage[1]

		if not nextChatId then
			return false
		end

		local cfg = LTConfig.NPCChatConfig.GetConfig(nextChatId)

		if isRefreshNpc and cfg.IsPlayerMessage then
			return true
		end

		local lastMsg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(self.topChannelId, self.subChannelId)

		if lastMsg and lastMsg.npcChatId ~= nextChatId then
			return true
		end

		if not isRefreshNpc then
			if self.isSendingNpcChat then
				return true
			end

			self.isSendingNpcChat = true
		end

		local chatItem = UX.Game.NpcChatItem.New()
		chatItem.ChatId = nextChatId

		gNpcChatManager:AddNewNpcChatItem(chatItem)

		return true
	end

	return false
end

M.OnClickNPCOption = function(self, npcChatId, sendTaskPhoto, rpcCallback)
	if self.isSendingNpcChat then
		return
	end

	self.waitShowMyChatItemTime = Time.unscaledTime + self.cs.delaySendTime
	local cfg = LTConfig.NPCChatConfig.GetConfig(npcChatId)

	if cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Invite then
		self.InviteNpcChat(self, cfg, rpcCallback)
	elseif cfg.IsPlayerMessage then
		self.ChatToNpc(self, cfg, npcChatId, sendTaskPhoto, rpcCallback)
	end
end

M.InviteNpcChat = function(self, cfg, rpcCallback)
	self.isSendingNpcChat = true

	self:StartChatTimeout(cfg.Id)

	slot3 = gClientToGameDelegate

	slot3:InviteNpcChat(cfg.Id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)
		else
			print_error("#NoCreateIssue ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.ClosePhone)
		end

		if rpcCallback then
			rpcCallback(err ~= LTConfig.MessageConfig.Ok)
		end
	end
end

M.ChatToNpc = function(self, cfg, npcChatId, sendTaskPhoto, rpcCallback)
	if not sendTaskPhoto and cfg.SpecialMsgType ~= gNpcChatConst.SpecialMsgType.TakePhoto then
		self.clickOptionId = npcChatId

		gPanelManager:SetActiveById(gNpcChatUtils.GetMainPhonePanelId(), false)
		gTakePhotoUtils.TryTakePhoto()
	else
		self.isSendingNpcChat = true

		self:StartChatTimeout(cfg.Id)

		slot5 = gClientToGameDelegate

		slot5:ChatToNpc(cfg.Id).Callback = function (err)
			if err ~= LTConfig.MessageConfig.NpcChatFinished then
				if gNpcChatUtils.HasNextMessage(self.lastMessage) then
					gNpcChatManager:RemoveNpcChatSegment(npcChatId, cfg.AsNpcCultivation)
				end
			elseif err == LTConfig.MessageConfig.Ok then
				print_error("#NoCreateIssue ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
				gNpcChatManager:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end

			if rpcCallback then
				rpcCallback(err ~= LTConfig.MessageConfig.Ok)
			end
		end
	end
end

M.AddFinishedHint = function(self, content)
	if not self.STATE_EnableOnce then
		return
	end

	if self.optionList then
		self.optionList:SetActive(true)

		self.optionList.enabled = true
		content = content or LTConfig.NPCChatConfig.ChatFinishHint
		local item = {
			["a\\x9f\\x8a\\x86Y"] = 2,
			content = content
		}
		self.optionListData = {
			item
		}

		self.optionList:SetSimpleList(1)
	end

	self.ShowBottom(self, true, function ()
		if self.STATE_EnableOnce then
			self:ShowBottom_Gamepad(false)
		end
	end)

	self.chatFinishHintShowing = true
	self.bindData.showSkipBtnCtrl = 0
end

M.OnDestroy = function(self)
	self.inviteNpcChatCo = coroutine.stop(self.inviteNpcChatCo)
	self.pendingRestorePhotoMsgId = nil

	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = false

	if self._clearAndRefreshRetryTimer then
		self._clearAndRefreshRetryTimer:Stop()

		self._clearAndRefreshRetryTimer = nil
	end

	self.ClearChatTimeout(self)

	if self.lastMessage then
		if not gNpcChatUtils.HasNextMessage(self.lastMessage) then
			gClientToGameSceneDelegate:AskCloseNpcChatWnd(self.lastMessage.npcChatId)
			gMessageManager:SendMessage(gEventConstants.NPC_CHAT_PANEL_CLOSE, self.lastMessage.npcChatId)
		end

		self.lastMessage = nil
	end

	self.clickOptionId = nil
end

M.OnListScroll = function(self, _)
	self.OnListScroll_Gamepad(self)
end

M.CalcAutoClickTime = function(self, cfg)
	if cfg.Delay and cfg.Delay <= 0 then
		return cfg.Delay
	end

	local text = gNpcChatUtils.GetMessage(cfg)
	local textLength = gCS.LuaUtils.GetTextLength(text)
	local messageReceivingDelay = LTConfig.NPCChatConfig.MessageReceivingDelay

	for _, v in ipairs(messageReceivingDelay) do
		if textLength < v.MaxCharCount then
			return v.AvgTime + (math.random() - 0.5) * v.Sigma * 2
		end
	end

	print_error("@zhangzhiyuan06 CalcAutoClickTime text too long!", text)

	return 1
end

M.OnPanelShow = function(self, panel, data)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panel)

	if panelCfg and panelCfg.UILayer ~= LTConfig.PanelConfig.UILayerType.FRONT then
		self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
		self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	end
end

M.PlayAnimation = function(self, name, data)
	if self.bindData.panelAni ~= nil then
		return
	end

	local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAni, name)

	coroutine.start(function ()
		coroutine.wait(time)
		data.OnAnimStopCallback()
	end)
end

M.OnClickSkillAllBtn = function(self)
	local lastMessage = self.lastMessage

	if lastMessage ~= nil or self.isSendingNpcChat then
		return
	end

	if #lastMessage.cfg.NextMessage ~= 0 and lastMessage.npcNextChatId ~= 0 then
		return
	end

	self.isSendingNpcChat = true
	self.isSkippingToEnd = true
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)

	if self.addEllipsisBubbleTimer then
		self.addEllipsisBubbleTimer:Stop()

		self.addEllipsisBubbleTimer = nil
	end

	self.waitForEllipsisBubble = false

	self:StartChatTimeout(lastMessage.npcChatId)

	slot2 = gClientToGameDelegate

	slot2:InteractNpcChatToEnd(lastMessage.npcChatId).Callback = function (err)
		if self ~= nil or gClientUtils.IsNil(self.rootGo) then
			return
		end

		if err == LTConfig.MessageConfig.Ok then
			print_error("#NoCreateIssue ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage)

			self.isSkippingToEnd = false

			gNpcChatManager:ClearAllNpcDialogChat()
			gClientUtils.CloseMainPhonePanel()
		end
	end
end
