-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChattingPanelStore_Handler.lua
-- Decompiled from: 01958_NpcChatChattingPanelStore_Handler.lua_b34bd19318dc.luajit

local M = C_NpcChatChattingPanelStore

M.OnClickAudioBubble = function(self, data)
	local itemData = data.itemData
	local cfg = data.cfg
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil
	self.clickedMsgIds[itemData.msg.msgId] = true

	gNpcChatManager:MarkMsgClicked(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	self:OnNavigateBackToPanelBtnClick()

	store.clickVfxCtrl = 0
end

M.OnClickMapBubble = function(self, data)
	local store = data.store
	self.needClickItem[data.itemData.msg.msgId] = nil
	self.clickedMsgIds[data.itemData.msg.msgId] = true

	gNpcChatManager:MarkMsgClicked(self.topChannelId, self.subChannelId, data.itemData.msg.npcChatId, data.itemData.msg.timeStamp)

	self.pendingRestorePhotoMsgId = data.itemData.msg.msgId
	local cfg = data.cfg
	store.taskCtrl = 0

	if cfg.HypeLinkId == 0 then
		local ret, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HypeLinkId, cfg.HypeLinkParam)

		if ret.callback then
			ret.callback()
		end
	else
		local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(cfg.taskEventId)
		local taskId = taskEventCfg and taskEventCfg.StartTask

		if taskId and taskId <= 0 then
			local param = {
				AutoSelectTaskId = taskId
			}
			store.taskCtrl = 1
			store.taskStatusCtrl = gNpcChatUtils.GetTaskControlValue(cfg.taskEventId)
			store.clickVfxCtrl = 0

			if store.taskStatusCtrl == 0 then
				return
			end

			gMapUtils:CheckRaidCanOpenMap(param)

			return
		end

		if data.cfg and #data.cfg.Coordinate ~= 3 then
			local pos = data.cfg.Coordinate

			gMapUtils:CheckRaidCanOpenMap({
				["\\xb250v\\x99N\\xd6%\\x83\\xbd"] = 0,
				MapRaidId = data.cfg.RaidId,
				autoPinWorldPos = Vector3.New(pos[1], pos[2], pos[3])
			})

			store.clickVfxCtrl = 0
		end
	end

	store.clickVfxCtrl = 0
end

M.OnClickLinkBubble = function(self, data)
	if self.isSendingNpcChat then
		return
	end

	local itemData = data.itemData
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil
	self.clickedMsgIds[itemData.msg.msgId] = true

	gNpcChatManager:MarkMsgClicked(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	self:OnNavigateBackToPanelBtnClick()

	local id = itemData.msg.npcChatId
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(id)
	local webPageCfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if webPageCfg.ShowSignButton then
		self.activity:ShowFragment(gNpcChatConst.TabShowType.ApplicationPage, {
			["\\xbb\\xb0\\xae^'\\xee6"] = 0,
			chatID = id
		})
	else
		self.activity:ShowFragment(gNpcChatConst.TabShowType.WebPage, {
			["\\xbb\\xb0\\xae^'\\xee6"] = 0,
			chatID = id
		})
	end

	store.clickVfxCtrl = 0
end

M.OnClickPhotoBubble = function(self, data)
	local itemData = data.itemData
	local cfg = data.cfg
	local store = data.store
	self.pendingRestorePhotoMsgId = itemData.msg.msgId

	if cfg then
		self.needClickItem[itemData.msg.msgId] = nil
		self.clickedMsgIds[itemData.msg.msgId] = true

		gNpcChatManager:MarkMsgClicked(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end

	gUIUtils:CommonShowPhoto(data)

	store.clickVfxCtrl = 0
end

M.OnClickTaskBubble = function(self, data)
	local itemData = data.itemData
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil
	self.clickedMsgIds[itemData.msg.msgId] = true

	gNpcChatManager:MarkMsgClicked(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	self:OnNavigateBackToPanelBtnClick()

	local eventId = itemData.eventId

	gTaskManager:JumpToTaskListPanel(eventId)

	store.clickVfxCtrl = 0
end

M.RegisterMessageEventHandlers = function(self)
	self.ClearMessageEvents(self)

	local msgEvents = self.GetMessageEventHandlers(self)

	self.RegisterMessageEvents(self, msgEvents)
end

M.GetMessageEventHandlers = function(self)
	return {
		[gEventConstants.PANEL_ON_SHOW] = self.CreateAction(self, "OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, "OnPanelClose"),
		[gEventConstants.NPC_CHAT_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatMessageChanged"),
		[gEventConstants.NPC_CHAT_CLEAR_CHANNEL_MESSAGE] = self.CreateAction(self, "OnClearChatChannelMessage"),
		[gEventConstants.PHOTO_TASK_TARGET] = self.CreateAction(self, "OnPhotoTaskTarget"),
		[gEventConstants.NPC_CHAT_MESSAGE_SKIP_ALL] = self.CreateAction(self, "OnChatMessageSkipAll"),
		[gEventConstants.NPC_CHAT_GROUP_NAME_CHANGED] = self.CreateAction(self, "OnNpcChatGroupNameChanged")
	}
end

M.OnPanelClose = function(self, _, panelId)
	if panelId == gPanelId.S_SHOW_PHOTO_PANEL and panelId == gPanelId.S_NEW_MAP_PANEL then
		return
	end

	local msgId = self.pendingRestorePhotoMsgId
	self.pendingRestorePhotoMsgId = nil

	self.RestoreGamepadFocusToMsgId(self, msgId)
end

M.OnChatMessageChanged_CheckIsCurrentChannel = function(self, data)
	if self.topChannelId == data.topChannelId or not ulong.equals(self.subChannelId, data.subChannelId) or not data.msg then
		return false
	end

	if LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType == gNpcChatManager.currentNpcChatType then
		return false
	end

	return true
end

M.OnChatMessageChanged = function(self, _, data)
	if not self.STATE_EnableOnce then
		return
	end

	if data.refreshOnRemove ~= true then
		if data.chatId and self.chatItemList then
			for i, itemData in ipairs(self.chatItemList) do
				if itemData.msg and itemData.msg.npcChatId ~= data.chatId then
					gClientUtils.CloseMainPhonePanel()

					return
				end
			end
		end

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
			self.selfMessageCoroutine = coroutine.start(function ()
				while self.STATE_EnableOnce and self.cs.isScrolling do
					coroutine.step()
				end

				if self.STATE_EnableOnce then
					for i, v in ipairs(queue) do
						v.skipScroll = i <= #queue

						if self:OnChatMessageChanged_CheckIsCurrentChannel(v) then
							self:ReceiveNewMessage(v.msg, v.skipScroll)
						end
					end

					self.bindData.chatMessageQueue = nil
				end
			end, restWaitTime)
		else
			table.insert(queue, data)
		end

		return
	end

	if self.OnChatMessageChanged_CheckIsCurrentChannel(self, data) then
		self.ReceiveNewMessage(self, data.msg, data.skipScroll)
	end
end

M.OnClearChatChannelMessage = function(self, _, data)
	if not self.STATE_EnableOnce then
		return
	end

	if data.topChannelId ~= self.topChannelId and data.subChannelId ~= self.subChannelId and gClientUtils.NotNil(self.bindData.chatList) and gClientUtils.NotNil(self.chatList) and self.cs then
		self.cs:ClearAndRefreshAllMsg()
	end
end

M.OnPhotoTaskTarget = function(self, _, data)
	if data.Finish and self.clickOptionId and self.clickOptionId <= 0 then
		gPanelManager:SetActiveById(gNpcChatUtils.GetMainPhonePanelId(), true)
		self:OnClickNPCOption(self.clickOptionId, true)

		self.clickOptionId = nil
	end
end

M.OnNpcChatGroupNameChanged = function(self, _, data)
	if not self.STATE_EnableOnce then
		return
	end

	if self.topChannelId == gNpcChatConst.ChatTopChannel.NpcGroup then
		return
	end

	if ulong.equals(self.subChannelId, data.groupId) or self.subChannelId ~= data.groupId then
		self.SetHeader(self)
	end
end

M.OnChatMessageSkipAll = function(self, _, chatItems)
	if not self.STATE_EnableOnce then
		return
	end

	gNpcChatManager.SkipAll = true
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.selfMessageCoroutine = coroutine.stop(self.selfMessageCoroutine)

	self.cs:SkipAllAnims()

	self.inUpdateChatList = true

	self:TryRemoveEllipsisBubble()

	for _, chatItem in ipairs(chatItems) do
		gNpcChatManager:AddNewNpcChatItem(chatItem, true)
	end

	self.inUpdateChatList = false

	if gClientUtils.NotNil(self.chatList) then
		self.chatList:SetList(#self.chatItemList)
	end

	self.ScrollTo(self, 0, 0)

	self.bindData.showSkipBtnCtrl = 0

	self.OnChatFinish(self)

	if chatItems and #chatItems <= 0 then
		local lastChatItem = chatItems[#chatItems]
		local lastCfg = LTConfig.NPCChatConfig.GetConfig(lastChatItem.ChatId)

		if lastCfg then
			self.lastMessage = {
				["\\xf3\\\\xc8\\x95I\\xa0B\\x99\\xb2"] = 0,
				npcChatId = lastChatItem.ChatId,
				cfg = lastCfg
			}
		end
	end

	self.isSkippingToEnd = false
	self.isSendingNpcChat = false
	gNpcChatManager.SkipAll = false
	local lastStore = self.chatItemList[#self.chatItemList] and self.chatItemList[#self.chatItemList].store

	if lastStore and lastStore.bgImageTargetSize == nil then
		local bgImageTargetSize = lastStore.bgImageTargetSize.rectTransform.sizeDelta

		lastStore.bgImage:SetSizeDelta(bgImageTargetSize)
	end
end
