C_NpcChatChattingPanelStore = DefClass("C_NpcChatChattingPanelStore", C_NpcChatChattingPanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatChattingPanelStore = C_NpcChatChattingPanelStore
local M = C_NpcChatChattingPanelStore

dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Utils")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Handler")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_ProcessMsgFunc")
dofile("LX6/SGUI/StoreDefine/NpcChat/NpcChatChattingPanelStore_Gamepad")

function M:ctor()
	local const = gNpcChatConst
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

function M:OnAwake()
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
		self.optionList.luaSimpleRenderItem = self:CreateAction("OnRenderOptionItem")
		self.optionList.luaSimpleClick = self:CreateAction("OnClickOptionItem")
		self.optionList.onGetTIndex = self:CreateAction("OnGetOptionListTIndex")
	end

	self.bindData.bgBtn.luaClick = self:CreateAction("OnClickChatBG")
	self.bindData.skillAllBtn.luaClick = self:CreateAction("OnClickSkillAllBtn")

	self:OnAwake_Gamepad()
end

function M:InitDataOnAwake()
	self.needClickItem = {}
	self.banOptionClick = false
	self.lastClickBgTime = 0
	self.clickBgCooldown = 0.2
	self.chatTimeoutTimer = nil
	self.chatTimeoutDuration = 5
	self.isWaitingForResponse = false
end

function M:StartChatTimeout(chatId)
	self:ClearChatTimeout()

	self.isWaitingForResponse = true
	self.chatTimeoutTimer = Timer.New(function ()
		self:OnChatTimeout(chatId)
	end, self.chatTimeoutDuration):Start()
end

function M:ClearChatTimeout()
	if self.chatTimeoutTimer then
		self.chatTimeoutTimer:Stop()

		self.chatTimeoutTimer = nil
	end

	self.isWaitingForResponse = false
end

function M:OnChatTimeout(chatId)
	print_error("NPC聊天超时，chatId:", chatId)
	self:ClearChatTimeout()
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)

	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.isSendingNpcChat = false
end

function M:OnShow(tabIndex, data)
	self:ShowBottom(false)

	self.data = data or {}
	self.lastMessage = nil
	gNpcChatManager.SkipAll = false
	self.inInit = true

	self:InitData()
	self:InitView()

	self.inInit = false
	self.waitForEllipsisBubble = false
	local cfg = data.chatMessage and data.chatMessage.cfg or data.cfg

	if gNpcChatUtils.ShouldAskReadChat(cfg) then
		gClientToGameDelegate:AskMarkNpcChatRead(cfg.Id).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end
		end
	end
end

function M:OnUpdate()
	if self.interactiveChatItemBtnListDirty then
		self:UpdateInteractiveChatItemBtnList()

		self.interactiveChatItemBtnListDirty = false
	end
end

function M:InitData()
	self.interactiveMessageBtnList = {}
	self.interactiveChatItemBtnListDirty = true
	local top = self.data.topChannelId
	local sub = self.data.subChannelId

	if top == nil or sub == nil then
		top, sub = gNpcChatManager:GetCurrentChannel()
	end

	self.topChannelId = top
	self.subChannelId = sub
	self.currentChannelInfo = gNpcChatManager:GetChannel(top, sub)

	gNpcChatManager:ResetUnreadCount(top, sub)
end

function M:InitView()
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

function M:SetHeader()
	if self.bindData.header == nil then
		return
	end

	gNpcChatUtils.SetHeader(self.bindData.header, false, self.topChannelId, self.subChannelId)
end

function M:ReceiveNewMessage(msg, skipScroll)
	self.isSendingNpcChat = false

	if gClientUtils.NotNil(self.bindData.chatList) then
		if gNpcChatManager.SkipAll then
			self:UpdateChatContent(msg)

			return
		end

		if msg.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake and gNpcChatUtils.HasNextMessage(msg) and not gNpcChatUtils.IsCurrentInChatPage() then
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)
		end

		self.cs:EnableNpcChatItemAnim(true)
		self:UpdateChatList(function ()
			self:AddNewChatMessage(msg)
			self:AfterAddLastMessage(msg)
		end, true, msg)

		if not skipScroll and not gNpcChatUtils.IsCurrentInChatPage() then
			self:ScrollToBottom()
		end

		local cfg = msg.cfg or LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

		if cfg and cfg.OneClickSkip and gNpcChatUtils.HasNextMessage(msg) then
			self.bindData.showSkipBtnCtrl = 1
		end
	end
end

function M:AddNewChatMessage(msg)
	self:BeforeAddMessage(msg)

	if msg.msgType == gNpcChatConst.MessageType.Text and string.is_null_or_empty(msg:GetText()) then
		self:AfterAddMessage(msg)

		return
	end

	self:AddViewItem(msg)
	self:AfterAddMessage(msg)
end

function M:AddViewItem(msg)
	if self.isWaitingForResponse then
		self:ClearChatTimeout()
	end

	local bubblePos = "Mid"

	if msg.cfg and msg.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local curNpcId = gNpcChatUtils.GetCurrentNpcId()
		local speaker = msg.cfg.Speaker ~= 0 and msg.cfg.Speaker or curNpcId

		if curNpcId == speaker or not msg.fromOther and speaker == msg.cfg.AsNpcCultivation and curNpcId == msg.cfg.SpecialReadableCharacter then
			bubblePos = "Right"
		else
			bubblePos = "Left"
		end
	elseif msg.templateMode == gNpcChatConst.ChatMsgTemplateMode.MyChat then
		bubblePos = "Right"
	elseif msg.templateMode == gNpcChatConst.ChatMsgTemplateMode.TheirChat then
		bubblePos = "Left"
	end

	if self.isTalkingToPlayer then
		if bubblePos == "Left" then
			bubblePos = "Right"
		elseif bubblePos == "Right" then
			bubblePos = "Left"
		end
	end

	local msgType = msg.msgType
	local tIndex = gNpcChatConst.MsgType2Template[msgType][bubblePos] or gNpcChatConst.MsgType2Template[msgType].Mid

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

	if gNpcChatUtils.GetMessage(msg.cfg) then
		self:AddItemToList(itemData)
	end
end

function M:AddCustomViewItem(customData, msgType, bubblePos)
	if self.isTalkingToPlayer then
		if bubblePos == "Left" then
			bubblePos = "Right"
		elseif bubblePos == "Right" then
			bubblePos = "Left"
		end
	end

	customData.tIndex = gNpcChatConst.MsgType2Template[msgType][bubblePos] or gNpcChatConst.MsgType2Template[msgType].Mid

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
	local processMsgFuncName = self.ProcessMsgFunc[item.msgType]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if store then
		store:EnableImmediatelyCommit(true)
	end

	item.store = store

	if self.topChannelId == gNpcChatConst.ChatTopChannel.NpcGroup and store and store.name then
		local sender = self:GetSender(index)
		local npcId = sender and sender.npcId or 1
		local asNpc = npcId ~= 0 and npcId or gNpcChatUtils.GetCurrentNpcId()

		if asNpc ~= 1 then
			local npcInfo = LTConfig.NPCChatNpcConfig.GetConfig(asNpc) or LTConfig.NpcCultivationConfig.GetConfig(asNpc)

			if npcInfo then
				store.name.text = npcInfo.NpcName or npcInfo.Name
			end
		else
			store.name.text = gPlayerManager.infoLogin.bindData.name
		end

		store.showName = 1
	elseif store and store.showName ~= nil then
		store.showName = 0
	end

	if processMsgFuncName and self[processMsgFuncName] then
		self[processMsgFuncName](self, item, store, btn)
	end

	if not item.isCustomAvatar then
		self:SetChatItemAvatar(btn, item, index)
	end
end

function M:SetChatItemAvatar(btn, item, index)
	local btnTransform = btn.transform
	local avatarGo = btnTransform:Find("ChatHead/S_MessageHeadTemplate") or btnTransform:Find("S_MessageHeadTemplate") or btnTransform:Find("ChatHead/S_ChatHeadTemplate") or btnTransform:Find("S_ChatHeadTemplate")
	local avatarWidget = avatarGo and avatarGo:GetComponent(typeof(SGUI.UWidget))

	if gClientUtils.IsNil(avatarWidget) then
		return
	end

	local sender = self:GetSender(index)

	gNpcChatAvatarUtils:SetSingleAvatar(sender, avatarWidget)
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
			chatItem.sender = NpcChatSenderId.New(chatCfg)
		else
			chatItem.sender = NpcChatSenderId.NewPlayer(msg.pid)
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
	}, gNpcChatConst.MessageType.Tips, "Mid")
end

function M:AddHintWithIcon(content)
	self:AddCustomViewItem({
		content = content
	}, gNpcChatConst.MessageType.TipsWithIcon, "Mid")
end

function M:CheckDisplayNewFriend()
	if gNpcChatConst.ChatTopChannel.Npc == self.topChannelId and gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		self:AddHint(LTConfig.NPCChatConfig.NewFriendHint)
	end
end

function M:ShowBottom(isShow, onBegin, onComplete, instant)
	local function OnBegin()
		self:ShowBottom_Gamepad(isShow)

		if onBegin then
			onBegin()
		end
	end

	self.chatFinishHintShowing = false
	instant = instant or self.inInit

	self.cs:ShowBottom(isShow, OnBegin, onComplete, instant)
end

function M:OnClose()
	self.isSendingNpcChat = false
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	self.selfMessageCoroutine = coroutine.stop(self.selfMessageCoroutine)
	gNpcChatManager.rollToCfgId = nil

	if not self.npcInviteGamePlay or self.npcInviteGamePlay == 0 then
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

function M:RefreshAllMsg()
	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		local specialAsNpc = nil
		local cfg = self.data.cfg
		local specialReadableCharacter = cfg and cfg.SpecialReadableCharacter or nil

		if specialReadableCharacter == gNpcChatUtils.GetCurrentNpcId() then
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

					self:AddNewChatMessage(msg)
				end
			end

			if #segments > 0 and #segments[#segments] > 0 then
				local lastSegment = segments[#segments]

				self:AfterAddLastMessage(lastSegment[#lastSegment])
			end
		else
			self:CheckDisplayNewFriend()
		end
	end
end

function M:OnClearAndRefreshAllMsg()
	self:ClearChatItems()
	self:UpdateChatList(function ()
		self:RefreshAllMsg()
	end, false)

	if gNpcChatManager.rollToCfgId then
		local targetCfgId = gNpcChatManager.rollToCfgId
		gNpcChatManager.rollToCfgId = nil
		local targetIndex = nil

		for i, itemData in ipairs(self.chatItemList) do
			if itemData.msg and itemData.msg.npcChatId == targetCfgId then
				targetIndex = i

				break
			end
		end

		if targetIndex then
			self:ScrollToMessageByIndex(targetIndex)
		end
	end
end

function M:OnDisable()
	if self.lastMessage and not gNpcChatUtils.HasNextMessage(self.lastMessage) then
		gClientToGameDelegate:AskCloseNpcChatWnd(self.lastMessage.npcChatId)
		gMessageManager:SendMessage(gEventConstants.NPC_CHAT_PANEL_CLOSE, self.lastMessage.npcChatId)
	end

	if self.scrollTweener then
		self.scrollTweener:Kill()

		self.scrollTweener = nil
	end

	self:OnDisable_Gamepad()

	self.npcInviteGamePlay = 0
end

function M:BeforeAddMessage(msg)
	if self.lastMessage and not gNpcChatUtils.IsNextMessage(self.lastMessage, msg) then
		self:RemoveSpecificItem()
		self:AddCustomViewItem({
			canRemove = true,
			content = LTConfig.NPCChatConfig.HistoryMessageSeparatorText or "----"
		}, gNpcChatConst.MessageType.Tips, "Mid")
	end

	self:TryRemoveEllipsisBubble()
end

function M:TryAddTimestamp(timestamp)
	local lastTimestamp = self.lastTimestamp

	if lastTimestamp == nil or timestamp - lastTimestamp > 300 then
		self:AddCustomViewItem({
			content = gCS.LuaUtils.FormatTimestamp(timestamp)
		}, gNpcChatConst.MessageType.Tips, "Mid")

		self.lastTimestamp = timestamp
	end
end

function M:AfterAddMessage(msg)
	self.lastMessage = msg
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if not string.is_null_or_empty(chatCfg.MessageText) then
		self:AddHintWithIcon(chatCfg.MessageText)
	end

	if chatCfg.Eventid > 0 then
		self:AddTaskBubble(msg)
	end

	if chatCfg.CustomChatType == LTConfig.NPCChatConfig.CustomChatTypeType.StoryTap then
		local bubblePos = chatCfg.Speaker == gNpcChatUtils.GetCurrentNpcId() and "Left" or "Right"

		self:AddCustomViewItem({
			context = msg.chatContext
		}, gNpcChatConst.MessageType.BubbleNotice, bubblePos)
	end
end

function M:AfterAddLastMessage(msg)
	self:RefreshNpcChatOptions(msg)

	local nextNpcChatId = msg.npcNextChatId > 0 and msg.npcNextChatId or msg.cfg.NextMessage[1]

	if gNpcChatUtils.IsNextNpcMessage(msg) then
		self:AddEllipsisBubble("Left", nextNpcChatId)
	elseif gNpcChatUtils.IsNextPlayerEllipsis(msg.npcChatId) then
		self:AddEllipsisBubble("Right", nextNpcChatId)
	elseif not gNpcChatUtils.HasNextMessage(msg) then
		self:OnChatFinish()
	end
end

function M:OnChatFinish()
	if gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self:CheckSpecialItemAllClicked(gNpcChatConst.CloseButtonType.ClosePhone)
	elseif gNpcChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		gNpcChatManager.FakeChatAutoPlay = false
	else
		self:CheckSpecialItemAllClicked(gNpcChatConst.CloseButtonType.Return)
	end

	gNpcChatManager.SkipAll = false

	self:AddFinishedHint()
end

function M:CheckSpecialItemAllClicked(closeType)
	self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	self.CheckSpecialItemAllClickedCo = coroutine.start(function ()
		while self.needClickItem and next(self.needClickItem) ~= nil do
			coroutine.wait(1)
		end

		gNpcChatUtils.SetCloseType(closeType)
	end)
end

function M:BeginInviteNpcChat(chatCfg, inviteGameplayId)
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

function M:RefreshNpcChatOptions(msg, inviteChatCfg)
	local nextChatCfgList = {}
	local lastChatId = nil

	if inviteChatCfg then
		table.insert(nextChatCfgList, inviteChatCfg)

		lastChatId = inviteChatCfg.Id
	elseif msg then
		lastChatId = msg.npcChatId
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

		if lastChatCfg and lastChatCfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake and not gNpcChatUtils.IsVisibleToCurrentNpc(lastChatId) then
			self:ShowBottom(false)

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

	if #options > 0 then
		if self:CheckIsFake(true) then
			self:ShowBottom(false)
			self:AddEllipsisBubble("Right", nextChatCfgList[1].Id)
			self:DoAutoClick(msg)

			return
		end

		self.optionListData = options

		self.optionList:SetSimpleList(#options)
		self:ShowBottom(true)

		if lastChatId then
			local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

			if gNpcChatUtils.ShouldAskReadChat(lastChatCfg) then
				gClientToGameDelegate:AskMarkNpcChatRead(lastChatId).Callback = function (err)
					if err ~= LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			end
		end
	else
		self:ShowBottom(false)
		self:DoAutoClick(msg)
	end
end

function M:DoAutoClick(msg)
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.AutoClickChatBGCo = coroutine.start(function ()
		local nextChatCfgId = gNpcChatUtils.GetNextNpcChatId(msg)

		if nextChatCfgId == 0 then
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

function M:AddEllipsisBubble(bubblePos, npcChatId)
	self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)
	self.waitForEllipsisBubble = true
	self.addEllipsisBubbleCo = coroutine.start(function ()
		coroutine.wait(0.01)

		while self.cs.isScrolling do
			coroutine.step()
		end

		local msg = {
			npcChatId = npcChatId
		}
		local customData = {
			isCustomAvatar = false,
			msg = msg
		}

		self:UpdateChatList(function ()
			self:AddCustomViewItem(customData, gNpcChatConst.MessageType.Waiting, bubblePos)
		end, true)
		self:ScrollToBottom()

		self.waitForEllipsisBubble = false
	end)

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_FINISH, npcChatId)
end

function M:AddTaskBubble(msg)
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(chatCfg.Eventid)

	if taskEventCfg == nil then
		return
	end

	local customData = {
		title = taskEventCfg.EventName,
		eventId = chatCfg.Eventid,
		isFinish = gTaskNodeManager:GetTaskLineState(chatCfg.Eventid) == gTaskLineState.Finish,
		msg = msg
	}

	self:AddCustomViewItem(customData, gNpcChatConst.MessageType.Task, "Mid")
end

function M:TryRemoveEllipsisBubble()
	if self.addEllipsisBubbleCo then
		self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)
	end

	local lastItem = self.chatItemList[#self.chatItemList]

	if lastItem and lastItem.msgType == gNpcChatConst.MessageType.Waiting then
		self:RemoveLastItem()
	end
end

function M:OnRenderOptionItem(btn, csIndex)
	local data = self.optionListData[csIndex + 1]

	if not data then
		return
	end

	if csIndex == 0 and self.bindData.optionNavArea then
		self.bindData.optionNavArea.CurrentActiveContent = btn
	end

	if data.tIndex == 1 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.emoji = data.cfg.SIcon
	else
		local label = btn:GetComponentInChildren(typeof(SGUI.UBaseText))
		label.text = gClientUtils.RichTextToPlain(data.content)
	end
end

function M:OnClickOptionItem(_, index)
	local data = self.optionListData[index + 1]

	if not data then
		return
	end

	if self.banOptionClick then
		return
	end

	self.banOptionClick = true

	self:OnClickNPCOption(data.cfg.Id, nil, function (success)
		if success and self.STATE_EnableOnce and not self.chatFinishHintShowing then
			if self.optionList then
				self.optionList:SetActive(true)

				self.optionList.enabled = true
				self.optionListData = {}

				self.optionList:SetSimpleList(0)
			end

			self:ShowBottom(false)
		end

		self.banOptionClick = false
	end)
end

function M:OnGetOptionListTIndex(index)
	local data = self.optionListData[index + 1]

	return data and data.tIndex or 0
end

function M:OnClickChatBG()
	if self.lastMessage and self.lastMessage.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local currentTime = Time.unscaledTime

		if currentTime - self.lastClickBgTime < self.clickBgCooldown then
			return
		end

		self.lastClickBgTime = currentTime
	end

	local lastMessage = self.lastMessage

	if lastMessage == nil or self.isSendingNpcChat then
		return
	end

	if #lastMessage.cfg.NextMessage == 0 and lastMessage.npcNextChatId == 0 then
		return
	end

	if self.waitForEllipsisBubble then
		return
	end

	local msgId = lastMessage.msgId
	self.bindData.lastInteractedMsgId = msgId

	if self:CheckIsFake() then
		return
	end

	if gNpcChatUtils.IsNextNpcMessage(lastMessage) then
		self.isSendingNpcChat = true

		self:StartChatTimeout(lastMessage.npcChatId)

		gClientToGameDelegate:InteractNpcChat(lastMessage.npcChatId).Callback = function (err)
			if self == nil or gClientUtils.IsNil(self.rootGo) then
				return
			end

			if err ~= LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage.npcChatId)
				gNpcChatManager:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end
		end
	elseif gNpcChatUtils.IsNextPlayerEllipsis(lastMessage.npcChatId) then
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastMessage.npcChatId)

		self:OnClickNPCOption(lastChatCfg.NextMessage[1])

		self.waitShowMyChatItemTime = 0
	end
end

function M:CheckIsFake(isRefreshNpc)
	if self.lastMessage and self.lastMessage.cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		local cfg = LTConfig.NPCChatConfig.GetConfig(self.lastMessage.cfg.NextMessage[1])

		if isRefreshNpc and cfg.IsPlayerMessage then
			return true
		end

		local chatItem = UX.Game.NpcChatItem.New()
		chatItem.ChatId = self.lastMessage.cfg.NextMessage[1]

		gNpcChatManager:AddNewNpcChatItem(chatItem)

		return true
	end

	return false
end

function M:OnClickNPCOption(npcChatId, sendTaskPhoto, rpcCallback)
	if self.isSendingNpcChat then
		return
	end

	self.waitShowMyChatItemTime = Time.unscaledTime + self.cs.delaySendTime
	local cfg = LTConfig.NPCChatConfig.GetConfig(npcChatId)

	if cfg.IsPlayerFirst and cfg.Inviteid > 0 then
		self:InviteNpcChat(cfg, rpcCallback)
	elseif cfg.IsPlayerMessage then
		self:ChatToNpc(cfg, npcChatId, sendTaskPhoto, rpcCallback)
	end
end

function M:InviteNpcChat(cfg, rpcCallback)
	self.isSendingNpcChat = true

	self:StartChatTimeout(cfg.Id)

	gClientToGameDelegate:InviteNpcChat(cfg.Id).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)
		else
			print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.ClosePhone)
		end

		if rpcCallback then
			rpcCallback(err == LTConfig.MessageConfig.Ok)
		end
	end
end

function M:ChatToNpc(cfg, npcChatId, sendTaskPhoto, rpcCallback)
	if not sendTaskPhoto and cfg.SpecialMsgType == gNpcChatConst.SpecialMsgType.TakePhoto then
		self.clickOptionId = npcChatId

		gPanelManager:SetActiveById(gNpcChatUtils.GetMainPhonePanelId(), false)
		gTakePhotoUtils.TryTakePhoto()
	else
		self.isSendingNpcChat = true

		self:StartChatTimeout(cfg.Id)

		gClientToGameDelegate:ChatToNpc(cfg.Id).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
				gNpcChatManager:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end

			if rpcCallback then
				rpcCallback(err == LTConfig.MessageConfig.Ok)
			end
		end
	end
end

function M:AddFinishedHint(content)
	if not self.STATE_EnableOnce then
		return
	end

	if self.optionList then
		self.optionList:SetActive(true)

		self.optionList.enabled = true
		content = content or LTConfig.NPCChatConfig.ChatFinishHint
		local item = {
			tIndex = 2,
			content = content
		}

		self.optionList:SetList({
			item
		})
	end

	self:ShowBottom(true, function ()
		if self.STATE_EnableOnce then
			self:ShowBottom_Gamepad(false)
		end
	end)

	self.chatFinishHintShowing = true
	self.bindData.showSkipBtnCtrl = 0
end

function M:OnDestroy()
	self.inviteNpcChatCo = coroutine.stop(self.inviteNpcChatCo)
	self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)

	self:ClearChatTimeout()

	if self.lastMessage then
		if not gNpcChatUtils.HasNextMessage(self.lastMessage) then
			gClientToGameDelegate:AskCloseNpcChatWnd(self.lastMessage.npcChatId)
			gMessageManager:SendMessage(gEventConstants.NPC_CHAT_PANEL_CLOSE, self.lastMessage.npcChatId)
		end

		self.lastMessage = nil
	end

	self.clickOptionId = nil
end

function M:OnListScroll(_)
	self:OnListScroll_Gamepad()
end

function M:CalcAutoClickTime(cfg)
	if cfg.Delay and cfg.Delay > 0 then
		return cfg.Delay
	end

	local text = gNpcChatUtils.GetMessage(cfg)
	local textLength = gCS.LuaUtils.GetTextLength(text)
	local messageReceivingDelay = LTConfig.NPCChatConfig.MessageReceivingDelay

	for _, v in ipairs(messageReceivingDelay) do
		if textLength <= v.MaxCharCount then
			return v.AvgTime + (math.random() - 0.5) * v.Sigma * 2
		end
	end

	print_error("@liulijun04 CalcAutoClickTime text too long!", text)

	return 1
end

function M:OnPanelShow(panel, data)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panel)

	if panelCfg and panelCfg.UILayer == LTConfig.PanelConfig.UILayerType.FRONT then
		self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
		self.CheckSpecialItemAllClickedCo = coroutine.stop(self.CheckSpecialItemAllClickedCo)
	end
end

function M:PlayAnimation(name, data)
	if self.bindData.panelAni == nil then
		return
	end

	local time = gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAni, name)

	coroutine.start(function ()
		coroutine.wait(time)
		data.OnAnimStopCallback()
	end)
end

function M:OnClickSkillAllBtn()
	local lastMessage = self.lastMessage

	if lastMessage == nil or self.isSendingNpcChat then
		return
	end

	if #lastMessage.cfg.NextMessage == 0 and lastMessage.npcNextChatId == 0 then
		return
	end

	self.isSendingNpcChat = true

	self:StartChatTimeout(lastMessage.npcChatId)

	gClientToGameDelegate:InteractNpcChatToEnd(lastMessage.npcChatId).Callback = function (err)
		if self == nil or gClientUtils.IsNil(self.rootGo) then
			return
		end

		if err ~= LTConfig.MessageConfig.Ok then
			print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage)
			gNpcChatManager:ClearAllNpcDialogChat()
			gClientUtils.CloseMainPhonePanel()
		end
	end
end
