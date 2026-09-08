-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChattingToNpcPanelStore.lua
-- Decompiled from: 02099_ChattingToNpcPanelStore.lua_39f0575636c2.luajit

C_ChattingToNpcPanelStore = DefClass("C_ChattingToNpcPanelStore", C_ChattingToNpcPanelStore, C_ChatChattingPanelStore)
GroupName2Class.ChattingToNpcPanelStore = C_ChattingToNpcPanelStore
local M = C_ChattingToNpcPanelStore

dofile("LX6/SGUI/StoreDefine/Chat/ChattingToNpcPanelStore_Gamepad")

M.OnAwake = function(self)
	M.base.OnAwake(self)

	self.optionList = self.bindData.optionList
	self.optionList.luaRenderItem = self.CreateAction(self, self.OnRenderOptionItem)
	self.optionList.luaClick = self.CreateAction(self, self.OnClickOptionItem)
	self.bindData.bgBtn.luaClick = self.CreateAction(self, self.OnClickChatBG)

	self.OnAwake_Gamepad(self)
end

M.InitDataOnAwake = function(self)
	M.base.InitDataOnAwake(self)

	self.banOptionClick = false
end

M.OnShow = function(self, tabIndex, data)
	self.ShowBottom(self, false)
	M.base.OnShow(self, tabIndex, data)

	self.waitForEllipsisBubble = false
end

M.InitView = function(self)
	M.base.InitView(self)
	self.chatList:RegisterToScrollEvent(self:CreateAction(self.OnListScroll))

	self.bindData.optionList.poolMode = SGUI.EPoolMode.Default
end

M.BeforeAddMessage = function(self, msg)
	self.TryRemoveEllipsisBubble(self)
end

M.AfterAddMessage = function(self, msg)
	self.lastMessage = msg
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if not string.is_null_or_empty(chatCfg.MessageText) then
		self.AddHintWithIcon(self, msg.MessageText)
	end

	if chatCfg.Eventid <= 0 then
		self.AddTaskBubble(self, msg)
	end

	if chatCfg.CustomChatType ~= LTConfig.NPCChatConfig.CustomChatTypeType.StoryTap then
		self.AddCustomViewItem(self, {
			context = msg.chatContext
		}, gChatConst.MessageType.BubbleNotice, "Right")
	end
end

M.AfterAddLastMessage = function(self, msg)
	self:RefreshNpcChatOptions(msg)

	local isChatFinish = not gChatUtils.HasNextMessage(msg)
	local nextNpcChatId = msg.npcNextChatId <= 0 and msg.npcNextChatId or msg.NextMessage[1]

	if gChatUtils.IsNextNpcMessage(msg) then
		self.AddEllipsisBubble(self, "Left", nextNpcChatId)
	elseif L50.Chat.ChatUtils.IsNextPlayerEllipsis(msg.npcChatId) then
		self.AddEllipsisBubble(self, "Right", nextNpcChatId)
	elseif isChatFinish then
		self.OnChatFinish(self)
	end
end

M.OnChatFinish = function(self)
	if gChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		gChatUtils.SetCloseType(gChatConst.CloseButtonType.ClosePhone)
	end

	self.AddFinishedHint(self)
end

M.BeginInviteNpcChat = function(self, chatCfg)
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

M.RefreshNpcChatOptions = function(self, msg, inviteChatCfg)
	local nextChatCfgList = {}
	local options = {}

	if inviteChatCfg then
		table.insert(nextChatCfgList, inviteChatCfg)
	elseif msg then
		local lastChatId = msg.npcChatId
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatId)

		if lastChatCfg and not gChatManager:IsChatControlledByCurrentNpc(lastChatId) then
			self.ShowBottom(self, false)

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
		local isEmoji = cfg.SpecialMsgType ~= gChatConst.SpecialMsgType.Emoji
		local itemData = {
			cfg = cfg,
			tIndex = isEmoji and 1 or 0,
			content = string.is_null_or_empty(cfg.OptionText) and cfg.Message or cfg.OptionText
		}

		table.insert(options, itemData)
	end

	if #options <= 0 then
		if self.CheckIsFake(self, true) then
			self.ShowBottom(self, false)
			self.OnClickChatBG(self)

			return
		end

		self.ShowBottom(self, true)
	else
		self.ShowBottom(self, false)
		self.DoAutoClick(self, msg)
	end
end

M.DoAutoClick = function(self, msg)
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.AutoClickChatBGCo = coroutine.start(function ()
		local nextChatCfgId = gChatUtils.GetNextNpcChatId(msg)

		if nextChatCfgId ~= 0 then
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

M.AddEllipsisBubble = function(self, bubblePos, npcChatId)
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
			["\\xee\\x892\\xf9\\xe9˞\\xec\\x96!:"] = false,
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

M.AddTaskBubble = function(self, msg)
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(chatCfg.Eventid)

	if taskEventCfg ~= nil then
		return
	end

	local customData = {
		title = taskEventCfg.EventName,
		eventId = chatCfg.Eventid,
		isFinish = gTaskNodeManager:GetTaskLineState(chatCfg.Eventid) ~= gTaskLineState.Finish
	}

	self:AddCustomViewItem(customData, gChatConst.MessageType.Task, "Mid")
end

M.TryRemoveEllipsisBubble = function(self)
	if self.addEllipsisBubbleCo then
		self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)
	end

	local lastItem = self.chatItemList[#self.chatItemList]

	if lastItem and lastItem.msgType ~= gChatConst.MessageType.Waiting then
		self.RemoveLastItem(self)
	end
end

M.OnRenderOptionItem = function(self, btn, csIndex, data)
	if csIndex ~= 0 then
		self.bindData.optionNavArea.CurrentActiveContent = btn
	end

	if data.tIndex ~= 1 then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.emoji = data.cfg.SIcon
	else
		local label = btn.GetComponentInChildren(btn, typeof(SGUI.UBaseText))
		label.text = gClientUtils.RichTextToPlain(data.content)
	end
end

M.OnClickOptionItem = function(self, _, data)
	if self.banOptionClick then
		return
	end

	self.banOptionClick = true

	self.OnClickNPCOption(self, data.cfg.Id, nil, function (success)
		if success and self.STATE_EnableOnce and not self.chatFinishHintShowing then
			self:ShowBottom(false)
		end

		self.banOptionClick = false
	end)
end

M.OnClickChatBG = function(self)
	local lastMessage = self.lastMessage

	if lastMessage ~= nil or self.isSendingNpcChat then
		return
	end

	if self.waitForEllipsisBubble then
		return
	end

	local msgId = lastMessage.msgId

	if self.bindData.lastInteractedMsgId ~= msgId then
		return
	end

	self.bindData.lastInteractedMsgId = msgId

	if self.CheckIsFake(self) then
		return
	end

	if gChatUtils.IsNextNpcMessage(lastMessage) then
		self.isSendingNpcChat = true
		slot3 = gClientToGameDelegate

		slot3:InteractNpcChat(lastMessage.npcChatId).Callback = function (err)
			if self ~= nil or gClientUtils.IsNil(self.rootGo) then
				return
			end

			self.isSendingNpcChat = false

			if err == LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, lastMessage)
				gChatManager.cs:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end
		end
	elseif L50.Chat.ChatUtils.IsNextPlayerEllipsis(lastMessage.npcChatId) then
		local lastChatCfg = LTConfig.NPCChatConfig.GetConfig(lastMessage.npcChatId)

		self.OnClickNPCOption(self, lastChatCfg.NextMessage[1])

		self.waitShowMyChatItemTime = 0
	end
end

M.CheckIsFake = function(self, isRefreshNpc)
	if self.lastMessage and self.lastMessage.cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Fake then
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

M.OnPhotoTaskTarget = function(self, _, data)
	if data.Finish and self.clickOptionId and self.clickOptionId <= 0 then
		gPanelManager:SetActiveById(gChatUtils.GetMainPhonePanelId(), true)
		self:OnClickNPCOption(self.clickOptionId, true)

		self.clickOptionId = nil
	end
end

M.OnClickNPCOption = function(self, npcChatId, sendTaskPhoto, rpcCallback)
	if self.isSendingNpcChat then
		return
	end

	self.waitShowMyChatItemTime = Time.unscaledTime + self.cs.delaySendTime
	local cfg = LTConfig.NPCChatConfig.GetConfig(npcChatId)

	if cfg.IsPlayerFirst and cfg.ChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Invite then
		self.InviteNpcChat(self, cfg, rpcCallback)
	elseif cfg.IsPlayerMessage then
		self.ChatToNpc(self, cfg, npcChatId, sendTaskPhoto, rpcCallback)
	end
end

M.InviteNpcChat = function(self, cfg, rpcCallback)
	self.isSendingNpcChat = true
	slot3 = gClientToGameDelegate

	slot3:InviteNpcChat(cfg.Id).Callback = function (err)
		self.isSendingNpcChat = false

		if err ~= LTConfig.MessageConfig.Ok then
			gChatUtils.SetCloseType(gChatConst.CloseButtonType.Hide)
		else
			print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
			gDialogMainChatManager:RequestNpcChatList(self.subChannelId, cfg.Id, self.topChannelId ~= gChatTopChannel.NpcGroup)
		end

		if rpcCallback then
			rpcCallback(err ~= LTConfig.MessageConfig.Ok)
		end
	end
end

M.ChatToNpc = function(self, cfg, npcChatId, sendTaskPhoto, rpcCallback)
	if not sendTaskPhoto and cfg.SpecialMsgType ~= gChatConst.SpecialMsgType.TakePhoto then
		self.clickOptionId = npcChatId

		gPanelManager:SetActiveById(gChatUtils.GetMainPhonePanelId(), false)
		gTakePhotoUtils.TryTakePhoto()
	else
		self.isSendingNpcChat = true
		slot5 = gClientToGameDelegate

		slot5:ChatToNpc(cfg.Id).Callback = function (err)
			self.isSendingNpcChat = false

			if err == LTConfig.MessageConfig.Ok then
				print_error("ChatToNpc err", err, self.topChannelId, self.subChannelId, cfg.Id)
				gChatManager.cs:ClearAllNpcDialogChat()
				gClientUtils.CloseMainPhonePanel()
			end

			if rpcCallback then
				rpcCallback(err ~= LTConfig.MessageConfig.Ok)
			end
		end
	end
end

M.RefreshAllMsg = function(self)
	if gChatManager.currentNpcChatType == LTConfig.NPCChatConfig.ChatTypeType.Normal then
		gDialogMainChatManager:GetAllNpcMessage(self.topChannelId, self.subChannelId, gChatManager.currentNpcChatType)
	else
		M.base.RefreshAllMsg(self)
	end
end

M.OnClose = function(self)
	self.isSendingNpcChat = false
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)

	M.base.OnClose(self)
end

M.AddFinishedHint = function(self, content)
	if not self.STATE_EnableOnce then
		return
	end

	content = content or LTConfig.NPCChatConfig.ChatFinishHint

	self:ShowBottom(true, function ()
		if self.STATE_EnableOnce then
			self:ShowBottom_Gamepad(false)
		end
	end)

	self.chatFinishHintShowing = true
end

M.OnDestroy = function(self)
	M.base.OnDestroy(self)

	self.inviteNpcChatCo = coroutine.stop(self.inviteNpcChatCo)
	self.addEllipsisBubbleCo = coroutine.stop(self.addEllipsisBubbleCo)

	if self.lastMessage then
		if not gChatUtils.HasNextMessage(self.lastMessage) then
			slot1 = gReliableRpcManager

			slot1:RegisterRPC(gClientToGameSceneDelegate.AskCloseNpcChatWnd, self.lastMessage.npcChatId, function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end)
		end

		self.lastMessage = nil
	end

	self.clickOptionId = nil
end

M.OnListScroll = function(self, _)
	self.OnListScroll_Gamepad(self)
end

M.ShowBottom = function(self, isShow, onBegin, onComplete, instant)
	local OnBegin = function()
		self:ShowBottom_Gamepad(isShow)

		if onBegin then
			onBegin()
		end
	end

	self.chatFinishHintShowing = false

	M.base.ShowBottom(self, isShow, OnBegin, onComplete, instant)
end

M.OnDisable = function(self)
	M.base.OnDisable(self)
	self.OnDisable_Gamepad(self)
end

M.OnChatMessageChanged = function(self, _, data)
	if not self.STATE_EnableOnce then
		return
	end

	if data.msg then
		data.msg.isNpcChat = true
	end

	local waitTime = self.waitShowMyChatItemTime or 0
	local currentTime = Time.unscaledTime
	local restWaitTime = waitTime - currentTime

	if restWaitTime >= 0 or self.cs.isScrolling then
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
						v.skipScroll = i <= #queue

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

M.CalcAutoClickTime = function(self, text)
	local textLength = gCS.LuaUtils.GetTextLength(text)
	local messageReceivingDelay = LTConfig.NPCChatConfig.MessageReceivingDelay

	for _, v in ipairs(messageReceivingDelay) do
		if textLength < v.MaxCharCount then
			return v.AvgTime + (math.random() - 0.5) * v.Sigma * 2
		end
	end

	print_error("@liulijun04 CalcAutoClickTime text too long!", text)

	return 1
end

M.GetMessageEventHandlers = function(self)
	local msgEvents = M.base.GetMessageEventHandlers(self)
	msgEvents[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, self.OnPanelShow)

	return msgEvents
end

M.OnPanelShow = function(self, panel, data)
	local panelCfg = LTConfig.PanelConfig.GetConfig(panel)

	if panelCfg and panelCfg.UILayer ~= LTConfig.PanelConfig.UILayerType.FRONT then
		self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
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
