C_ChattingToNpcPanelStore = DefClass("C_ChattingToNpcPanelStore", C_ChattingToNpcPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingToNpcPanelStore = C_ChattingToNpcPanelStore
local M = C_ChattingToNpcPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChattingToNpcPanelStore_Gamepad")

function M:OnAwake()
	M.base.OnAwake(self)

	self.optionList = self.bindData.optionList
	self.optionList.luaRenderItem = self:CreateAction(self.OnRenderOptionItem)
	self.optionList.luaClick = self:CreateAction(self.OnClickOptionItem)
	self.bindData.bgBtn.luaClick = self:CreateAction(self.OnClickChatBG)

	self:OnAwake_Gamepad()
end

function M:InitDataOnAwake()
	M.base.InitDataOnAwake(self)

	self.banOptionClick = false
end

function M:OnShow(tabIndex, data)
	self:ShowBottom(false)
	M.base.OnShow(self, tabIndex, data)

	self.waitForEllipsisBubble = false
end

function M:InitView()
	M.base.InitView(self)
	self.chatList:RegisterToScrollEvent(self:CreateAction(self.OnListScroll))

	self.bindData.optionList.poolMode = SGUI.EPoolMode.Default
end

function M:BeforeAddMessage(msg)
	self:TryRemoveEllipsisBubble()
end

function M:AfterAddMessage(msg)
	self.lastMessage = msg
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if not string.is_null_or_empty(chatCfg.MessageText) then
		self:AddHintWithIcon(msg.MessageText)
	end

	if chatCfg.Eventid > 0 then
		self:AddTaskBubble(msg)
	end

	if chatCfg.CustomChatType == LTConfig.NPCChatConfig.CustomChatTypeType.StoryTap then
		self:AddCustomViewItem({
			context = msg.chatContext
		}, gChatConst.MessageType.BubbleNotice, "Right")
	end
end

function M:AfterAddLastMessage(msg)
	self:RefreshNpcChatOptions(msg)

	local isChatFinish = not gChatUtils.HasNextMessage(msg)
	local nextNpcChatId = msg.npcNextChatId > 0 and msg.npcNextChatId or msg.NextMessage[1]

	if gChatUtils.IsNextNpcMessage(msg) then
		self:AddEllipsisBubble("Left", nextNpcChatId)
	elseif L50.Chat.ChatUtils.IsNextPlayerEllipsis(msg.npcChatId) then
		self:AddEllipsisBubble("Right", nextNpcChatId)
	elseif isChatFinish then
		self:OnChatFinish()
	end
end

function M:OnChatFinish()
	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		gChatUtils.SetCloseType(gChatConst.CloseButtonType.ClosePhone)
	end

	self:AddFinishedHint()
end

function M:BeginInviteNpcChat(chatCfg)
	if self.inviteNpcChatCo then
		coroutine.stop(self.inviteNpcChatCo)
	end

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
	local options = {}

	if inviteChatCfg then
		table.insert(nextChatCfgList, inviteChatCfg)
	elseif msg then
		local lastChatId = msg.npcChatId
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

		if lastChatCfg and not gChatManager:IsChatControlledByCurrentNpc(lastChatId) then
			self:ShowBottom(false)

			return
		end

		if lastChatCfg and gChatUtils.HasNextMessage(msg) and not L50.Chat.ChatUtils.IsNextPlayerEllipsis(lastChatId) then
			for _, v in ipairs(lastChatCfg.NextMessage) do
				local cfg = LTConfig.NPCChatConfig.GetConfig(v)

				if cfg and cfg.IsPlayerMessage then
					table.insert(nextChatCfgList, cfg)
				end
			end
		end
	end

	for _, cfg in ipairs(nextChatCfgList) do
		local isEmoji = cfg.SpecialMsgType == gChatConst.SpecialMsgType.Emoji
		local itemData = {
			cfg = cfg,
			tIndex = isEmoji and 1 or 0,
			content = string.is_null_or_empty(cfg.OptionText) and cfg.Message or cfg.OptionText
		}

		table.insert(options, itemData)
	end

	if #options > 0 then
		if self:CheckIsFake(true) then
			self:ShowBottom(false)
			self:OnClickChatBG()

			return
		end

		self.optionList:SetList(options)
		self:ShowBottom(true)
	else
		self:ShowBottom(false)
		self:DoAutoClick(msg)
	end
end

function M:DoAutoClick(msg)
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.AutoClickChatBGCo = coroutine.start(function ()
		local nextChatCfgId = gChatUtils.GetNextNpcChatId(msg)

		if nextChatCfgId == 0 then
			return
		end

		local nextChatCfg = LTConfig.NPCChatConfig.GetConfig(nextChatCfgId)
		local text = nextChatCfg.Message
		local time = self:CalcAutoClickTime(text)

		coroutine.wait(time)

		while self.waitForEllipsisBubble do
			coroutine.step()
		end

		if self.bActive and self.rootWidget.activation then
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
			self:AddCustomViewItem(customData, gChatConst.MessageType.Waiting, bubblePos)
		end, true)
		M.base.ScrollToBottom(self, true)

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
		isFinish = gTaskNodeManager:GetTaskLineState(chatCfg.Eventid) == gTaskLineState.Finish
	}

	self:AddCustomViewItem(customData, gChatConst.MessageType.Task, "Mid")
end

function M:TryRemoveEllipsisBubble()
	if self.addEllipsisBubbleCo then
		self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)
	end

	local lastItem = self.chatItemList[#self.chatItemList]

	if lastItem and lastItem.msgType == gChatConst.MessageType.Waiting then
		self:RemoveLastItem()
	end
end

function M:OnRenderOptionItem(btn, csIndex, data)
	if csIndex == 0 then
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

function M:OnClickOptionItem(_, data)
	if self.banOptionClick then
		return
	end

	self.banOptionClick = true

	self:OnClickNPCOption(data.cfg.Id, nil, function (success)
		if success and self.STATE_EnableOnce and not self.chatFinishHintShowing then
			self:ShowBottom(false)
		end

		self.banOptionClick = false
	end)
end

function M:OnClickChatBG()
	local lastMessage = self.lastMessage

	if lastMessage == nil or self.isSendingNpcChat then
		return
	end

	if self.waitForEllipsisBubble then
		return
	end

	local msgId = lastMessage.msgId

	if self.bindData.lastInteractedMsgId == msgId then
		return
	end

	self.bindData.lastInteractedMsgId = msgId

	if self:CheckIsFake() then
		return
	end

	if gChatUtils.IsNextNpcMessage(lastMessage) then
		self.isSendingNpcChat = true

		gClientToGameDelegate:InteractNpcChat(lastMessage.npcChatId).Callback = function (err)
			if self == nil or gClientUtils.IsNil(self.rootGo) then
				return
			end

			self.isSendingNpcChat = false

			if err ~= LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage)
				gChatManager.cs:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end
		end
	elseif L50.Chat.ChatUtils.IsNextPlayerEllipsis(lastMessage.npcChatId) then
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

function M:OnPhotoTaskTarget(_, data)
	if data.Finish and self.clickOptionId and self.clickOptionId > 0 then
		gPanelManager:SetActiveById(gChatUtils.GetMainPhonePanelId(), true)
		self:OnClickNPCOption(self.clickOptionId, true)

		self.clickOptionId = nil
	end
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

	gClientToGameDelegate:InviteNpcChat(cfg.Id).Callback = function (err)
		self.isSendingNpcChat = false

		if err == LTConfig.MessageConfig.Ok then
			gChatUtils.SetCloseType(gChatConst.CloseButtonType.Hide)
		else
			print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
			gDialogMainChatManager:RequestNpcChatList(self.subChannelId, cfg.Id, self.topChannelId == gChatTopChannel.NpcGroup)
		end

		if rpcCallback then
			rpcCallback(err == LTConfig.MessageConfig.Ok)
		end
	end
end

function M:ChatToNpc(cfg, npcChatId, sendTaskPhoto, rpcCallback)
	if not sendTaskPhoto and cfg.SpecialMsgType == gChatConst.SpecialMsgType.TakePhoto then
		self.clickOptionId = npcChatId

		gPanelManager:SetActiveById(gChatUtils.GetMainPhonePanelId(), false)
		gTakePhotoUtils.TryTakePhoto()
	else
		self.isSendingNpcChat = true

		gClientToGameDelegate:ChatToNpc(cfg.Id).Callback = function (err)
			self.isSendingNpcChat = false

			if err ~= LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
				gChatManager.cs:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end

			if rpcCallback then
				rpcCallback(err == LTConfig.MessageConfig.Ok)
			end
		end
	end
end

function M:RefreshAllMsg()
	if gChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		gDialogMainChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gChatManager.currentNpcChatType)
	else
		M.base.RefreshAllMsg(self)
	end
end

function M:OnClose()
	self.isSendingNpcChat = false
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)

	M.base.OnClose(self)
end

function M:AddFinishedHint(content)
	if not self.STATE_EnableOnce then
		return
	end

	content = content or LTConfig.NPCChatConfig.ChatFinishHint
	local item = {
		tIndex = 2,
		content = content
	}

	self.optionList:SetList({
		item
	})
	self:ShowBottom(true, function ()
		if self.STATE_EnableOnce then
			self:ShowBottom_Gamepad(false)
		end
	end)

	self.chatFinishHintShowing = true
end

function M:OnDestroy()
	M.base.OnDestroy(self)

	self.inviteNpcChatCo = coroutine.stop(self.inviteNpcChatCo)
	self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)

	if self.lastMessage then
		if not gChatUtils.HasNextMessage(self.lastMessage) then
			gClientToGameDelegate:AskCloseNpcChatWnd(self.lastMessage.npcChatId)
		end

		self.lastMessage = nil
	end

	self.clickOptionId = nil
end

function M:OnListScroll(_)
	self:OnListScroll_Gamepad()
end

function M:ShowBottom(isShow, onBegin, onComplete, instant)
	local function OnBegin()
		self:ShowBottom_Gamepad(isShow)

		if onBegin then
			onBegin()
		end
	end

	self.chatFinishHintShowing = false

	M.base.ShowBottom(self, isShow, OnBegin, onComplete, instant)
end

function M:OnDisable()
	M.base.OnDisable(self)
	self:OnDisable_Gamepad()
end

function M:OnChatMessageChanged(_, data)
	if not self.STATE_EnableOnce then
		return
	end

	if data.msg then
		data.msg.isNpcChat = true
	end

	local waitTime = self.waitShowMyChatItemTime or 0
	local currentTime = Time.unscaledTime
	local restWaitTime = waitTime - currentTime

	if restWaitTime > 0 or self.cs.isScrolling then
		local queue = self.bindData.chatMessageQueue

		if not queue then
			queue = {
				data
			}
			self.bindData.chatMessageQueue = queue

			coroutine.start(function ()
				while self.STATE_EnableOnce and self.cs.isScrolling do
					coroutine.step()
				end

				if self.STATE_EnableOnce then
					for i, v in ipairs(queue) do
						v.skipScroll = i < #queue

						M.base.OnChatMessageChanged(self, nil, v)
					end

					self.bindData.chatMessageQueue = nil
				end
			end, restWaitTime)
		else
			table.insert(queue, data)
		end

		return
	end

	M.base.OnChatMessageChanged(self, nil, data)
end

function M:CalcAutoClickTime(text)
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

function M:GetMessageEventHandlers()
	local msgEvents = M.base.GetMessageEventHandlers(self)
	msgEvents[gEventConstants.PANEL_ON_SHOW] = self:CreateAction(self.OnPanelShow)

	return msgEvents
end

function M:OnPanelShow(panel, data)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panel)

	if panelCfg and panelCfg.UILayer == LTConfig.PanelConfig.UILayerType.FRONT then
		self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
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
