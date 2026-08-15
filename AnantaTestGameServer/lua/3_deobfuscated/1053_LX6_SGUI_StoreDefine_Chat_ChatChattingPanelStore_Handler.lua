local M = C_ChatChattingPanelStore

function M:OnClickTeamBubble(teamId)
	gTeamManager:AskApplyToTeam(teamId)
end

function M:OnClickAudioBubble(itemData)
	gCS.IMManager:StartPlayAudio(itemData.msg.msgId, itemData.msg.filePath)
end

function M:OnClickMapBubble(data)
	self:OnNavigateBackToPanelBtnClick()

	local taskId = data.itemData.msg.SpecialMsgTaskid

	if taskId and taskId > 0 then
		local param = {
			AutoSelectTaskId = taskId
		}

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
	end
end

function M:OnClickLinkBubble(itemData)
	self:OnNavigateBackToPanelBtnClick()

	local id = itemData.msg.npcChatId
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(id)
	local webPageCfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if webPageCfg.ShowSignButton then
		self.activity:ShowFragment(gChatConst.TabShowType.ApplicationPage, {
			pageType = 0,
			chatID = id
		})
	else
		self.activity:ShowFragment(gChatConst.TabShowType.WebPage, {
			pageType = 0,
			chatID = id
		})
	end
end

function M:OnClickPhotoBubble(photoData)
	self:OnNavigateBackToPanelBtnClick()
	gUIUtils:CommonShowPhoto(photoData)
end

function M:OnClickTaskBubble(itemData)
	self:OnNavigateBackToPanelBtnClick()

	local eventId = itemData.eventId

	gTaskManager:JumpToTaskListPanel(eventId)
end

function M:RegisterMessageEventHandlers()
	self:ClearMessageEvents()

	local msgEvents = self:GetMessageEventHandlers()

	self:RegisterMessageEvents(msgEvents)
end

function M:GetMessageEventHandlers()
	return {
		[gEventConstants.SEND_CHAT_MSG_OVER] = self:CreateAction(self.OnSendChatMsgOver),
		[gEventConstants.CHAT_MESSAGE_CHANGED] = self:CreateAction(self.OnChatMessageChanged),
		[gEventConstants.CHAT_CLEAR_CHANNEL_MESSAGE] = self:CreateAction(self.OnClearChatChannelMessage),
		[gEventConstants.DOWNLOAD_AUDIO_SUCCESS] = self:CreateAction(self.OnDownloadVoiceSuccess),
		[gEventConstants.AUDIO_PLAY_FINISH] = self:CreateAction(self.OnAudioPlayFinish),
		[gEventConstants.CHAT_REMOVE_CHANNEL] = self:CreateAction(self.OnChatRemoveChannel),
		[gEventConstants.PHOTO_TASK_TARGET] = self:CreateAction(self.OnPhotoTaskTarget)
	}
end

function M:OnSendChatMsgOver(_, data)
	local isSuccess = data[0]
	self.bindData.sendingMessage = false

	if isSuccess then
		self:ClearInputField()
	end
end

function M:OnChatMessageChanged_CheckIsCurrentChannel(data)
	if self.topChannelId ~= data.topChannelId or not ulong.equals(self.subChannelId, data.subChannelId) or not data.msg then
		return false
	end

	if gChatUtils.IsStoryChannel(self.topChannelId) and LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType ~= gChatManager.currentNpcChatType then
		return false
	end

	return true
end

function M:OnChatMessageChanged(_, data)
	if self:OnChatMessageChanged_CheckIsCurrentChannel(data) then
		self:ReceiveNewMessage(data.msg, data.skipScroll)
	end
end

function M:OnClearChatChannelMessage(_, data)
	if data.topChannelId == self.topChannelId and data.subChannelId == self.subChannelId and gClientUtils.NotNil(self.bindData.chatList) then
		self.cs:ClearAndRefreshAllMsg()
	end
end

function M:OnDownloadVoiceSuccess(_, data)
	return
end

function M:OnAudioPlayFinish(_, msgId)
	return
end

function M:OnChatRemoveChannel(_, data)
	if data.topChannelId == self.topChannelId and data.subChannelId == self.subChannelId then
		self:ClearChatItems()
	end
end

function M:OnPhotoTaskTarget(_, data)
	return
end
