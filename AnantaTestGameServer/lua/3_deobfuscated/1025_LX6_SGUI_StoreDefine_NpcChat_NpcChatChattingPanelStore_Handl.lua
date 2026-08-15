local M = C_NpcChatChattingPanelStore

function M:OnClickAudioBubble(data)
	local itemData = data.itemData
	local cfg = data.cfg
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil

	self:OnNavigateBackToPanelBtnClick()

	store.clickVfxCtrl = 0
end

function M:OnClickMapBubble(data)
	local store = data.store
	self.needClickItem[data.itemData.msg.msgId] = nil

	self:OnNavigateBackToPanelBtnClick()

	local cfg = data.cfg
	store.taskCtrl = 0

	if cfg.HypeLinkId ~= 0 then
		local ret, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(cfg.HypeLinkId, cfg.HypeLinkParam)

		if ret.callback then
			ret.callback()
		end
	else
		local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(cfg.taskEventId)
		local taskId = taskEventCfg and taskEventCfg.StartTask

		if taskId and taskId > 0 then
			local param = {
				AutoSelectTaskId = taskId
			}
			store.taskCtrl = 1
			store.taskStatusCtrl = gNpcChatUtils.GetTaskControlValue(cfg.taskEventId)
			store.clickVfxCtrl = 0

			if store.taskStatusCtrl ~= 0 then
				return
			end

			gMapUtils:CheckRaidCanOpenMap(param)

			return
		end

		if data.cfg and #data.cfg.Coordinate == 3 then
			MapRaidId = LTConfig.RaidConfig.WorldMap
			local pos = data.cfg.Coordinate

			gMapUtils:CheckRaidCanOpenMap({
				MapRaidId = LTConfig.RaidConfig.WorldMap,
				autoPinWorldPos = Vector3.New(pos[1], pos[2], pos[3])
			})

			store.clickVfxCtrl = 0
		end
	end

	store.clickVfxCtrl = 0
end

function M:OnClickLinkBubble(data)
	if self.isSendingNpcChat then
		return
	end

	local itemData = data.itemData
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil

	self:OnNavigateBackToPanelBtnClick()

	local id = itemData.msg.npcChatId
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(id)
	local webPageCfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if webPageCfg.ShowSignButton then
		self.activity:ShowFragment(gNpcChatConst.TabShowType.ApplicationPage, {
			pageType = 0,
			chatID = id
		})
	else
		self.activity:ShowFragment(gNpcChatConst.TabShowType.WebPage, {
			pageType = 0,
			chatID = id
		})
	end

	store.clickVfxCtrl = 0
end

function M:OnClickPhotoBubble(data)
	local itemData = data.itemData
	local cfg = data.cfg
	local store = data.store

	if cfg then
		self.needClickItem[itemData.msg.msgId] = nil
	end

	self:OnNavigateBackToPanelBtnClick()
	gUIUtils:CommonShowPhoto(data)

	store.clickVfxCtrl = 0
end

function M:OnClickTaskBubble(data)
	local itemData = data.itemData
	local store = data.store
	self.needClickItem[itemData.msg.msgId] = nil

	self:OnNavigateBackToPanelBtnClick()

	local eventId = itemData.eventId

	gTaskManager:JumpToTaskListPanel(eventId)

	store.clickVfxCtrl = 0
end

function M:RegisterMessageEventHandlers()
	self:ClearMessageEvents()

	local msgEvents = self:GetMessageEventHandlers()

	self:RegisterMessageEvents(msgEvents)
end

function M:GetMessageEventHandlers()
	return {
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.NPC_CHAT_MESSAGE_CHANGED] = self:CreateAction("OnChatMessageChanged"),
		[gEventConstants.NPC_CHAT_CLEAR_CHANNEL_MESSAGE] = self:CreateAction("OnClearChatChannelMessage"),
		[gEventConstants.PHOTO_TASK_TARGET] = self:CreateAction("OnPhotoTaskTarget"),
		[gEventConstants.NPC_CHAT_MESSAGE_SKIP_ALL] = self:CreateAction("OnChatMessageSkipAll")
	}
end

function M:OnChatMessageChanged_CheckIsCurrentChannel(data)
	if self.topChannelId ~= data.topChannelId or not ulong.equals(self.subChannelId, data.subChannelId) or not data.msg then
		return false
	end

	if LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType ~= gNpcChatManager.currentNpcChatType then
		return false
	end

	return true
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
			self.selfMessageCoroutine = coroutine.start(function ()
				while self.STATE_EnableOnce and self.cs.isScrolling do
					coroutine.step()
				end

				if self.STATE_EnableOnce then
					for i, v in ipairs(queue) do
						v.skipScroll = i < #queue

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

	if self:OnChatMessageChanged_CheckIsCurrentChannel(data) then
		self:ReceiveNewMessage(data.msg, data.skipScroll)
	end
end

function M:OnClearChatChannelMessage(_, data)
	if data.topChannelId == self.topChannelId and data.subChannelId == self.subChannelId and gClientUtils.NotNil(self.bindData.chatList) then
		self.cs:ClearAndRefreshAllMsg()
	end
end

function M:OnPhotoTaskTarget(_, data)
	if data.Finish and self.clickOptionId and self.clickOptionId > 0 then
		gPanelManager:SetActiveById(gNpcChatUtils.GetMainPhonePanelId(), true)
		self:OnClickNPCOption(self.clickOptionId, true)

		self.clickOptionId = nil
	end
end

function M:OnChatMessageSkipAll(_, chatItems)
	if not self.STATE_EnableOnce then
		return
	end

	gNpcChatManager.SkipAll = true
	self.AutoClickChatBGCo = coroutine.stop(self.AutoClickChatBGCo)
	self.selfMessageCoroutine = coroutine.stop(self.selfMessageCoroutine)

	self:UpdateChatList(function ()
		self:TryRemoveEllipsisBubble()

		for _, chatItem in ipairs(chatItems) do
			gNpcChatManager:AddNewNpcChatItem(chatItem)
		end
	end, true, true)
	self:ScrollTo(0, 0)

	self.bindData.showSkipBtnCtrl = 0

	self:OnChatFinish()

	self.isSendingNpcChat = false
	local lastStore = self.chatItemList[#self.chatItemList].store

	if lastStore and lastStore.bgImageTargetSize ~= nil then
		local bgImageTargetSize = lastStore.bgImageTargetSize.rectTransform.sizeDelta

		lastStore.bgImage:SetSizeDelta(bgImageTargetSize)
	end
end
