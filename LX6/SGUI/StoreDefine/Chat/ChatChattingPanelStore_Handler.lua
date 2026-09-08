-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChattingPanelStore_Handler.lua
-- Decompiled from: 01936_ChatChattingPanelStore_Handler.lua_3c83d5714660.luajit

local M = C_ChatChattingPanelStore

M.OnClickTeamBubble = function(self, teamId)
	if not gTeamManager:IsInTeam() and not gLinkManager:CheckInLinkMode() then
		slot2 = gDisplayMessageMgr

		slot2:ShowMessage(LTConfig.MessageConfig.SoloModeAcceptLinkInviteConfirm, function ()
			gTeamManager:AskApplyToTeam(teamId)
		end)

		return
	end

	gTeamManager:AskApplyToTeam(teamId)
end

M.OnClickAudioBubble = function(self, itemData)
	gCS.IMManager:StartPlayAudio(itemData.msg.msgId, itemData.msg.filePath)
end

M.OnClickMapBubble = function(self, data)
	self.OnNavigateBackToPanelBtnClick(self)

	local taskId = data.itemData.msg.SpecialMsgTaskid

	if taskId and taskId <= 0 then
		local param = {
			AutoSelectTaskId = taskId
		}

		gMapUtils:CheckRaidCanOpenMap(param)

		return
	end

	if data.cfg and #data.cfg.Coordinate ~= 3 then
		MapRaidId = LTConfig.RaidConfig.WorldMap
		local pos = data.cfg.Coordinate

		gMapUtils:CheckRaidCanOpenMap({
			MapRaidId = LTConfig.RaidConfig.WorldMap,
			autoPinWorldPos = Vector3.New(pos[1], pos[2], pos[3])
		})
	end
end

M.OnClickLinkBubble = function(self, itemData)
	self.OnNavigateBackToPanelBtnClick(self)

	local id = itemData.msg.npcChatId
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(id)
	local webPageCfg = LTConfig.NPCChatWebPageConfig.GetConfig(chatCfg.WebPageID)

	if webPageCfg.ShowSignButton then
		self.activity:ShowFragment(gChatConst.TabShowType.ApplicationPage, {
			["\\xbb\\xb0\\xae^'\\xee6"] = 0,
			chatID = id
		})
	else
		self.activity:ShowFragment(gChatConst.TabShowType.WebPage, {
			["\\xbb\\xb0\\xae^'\\xee6"] = 0,
			chatID = id
		})
	end
end

M.OnClickPhotoBubble = function(self, photoData)
	self:OnNavigateBackToPanelBtnClick()
	gUIUtils:CommonShowPhoto(photoData)
end

M.OnClickTaskBubble = function(self, itemData)
	self:OnNavigateBackToPanelBtnClick()

	local eventId = itemData.eventId

	gTaskManager:JumpToTaskListPanel(eventId)
end

M.RegisterMessageEventHandlers = function(self)
	self.ClearMessageEvents(self)

	local msgEvents = self.GetMessageEventHandlers(self)

	self.RegisterMessageEvents(self, msgEvents)
end

M.GetMessageEventHandlers = function(self)
	return {
		[gEventConstants.SEND_CHAT_MSG_OVER] = self.CreateAction(self, self.OnSendChatMsgOver),
		[gEventConstants.CHAT_MESSAGE_CHANGED] = self.CreateAction(self, self.OnChatMessageChanged),
		[gEventConstants.CHAT_CLEAR_CHANNEL_MESSAGE] = self.CreateAction(self, self.OnClearChatChannelMessage),
		[gEventConstants.DOWNLOAD_AUDIO_SUCCESS] = self.CreateAction(self, self.OnDownloadVoiceSuccess),
		[gEventConstants.AUDIO_PLAY_FINISH] = self.CreateAction(self, self.OnAudioPlayFinish),
		[gEventConstants.CHAT_REMOVE_CHANNEL] = self.CreateAction(self, self.OnChatRemoveChannel),
		[gEventConstants.PHOTO_TASK_TARGET] = self.CreateAction(self, self.OnPhotoTaskTarget)
	}
end

M.OnSendChatMsgOver = function(self, _, data)
	local isSuccess = data[0]
	self.bindData.sendingMessage = false

	if isSuccess then
		self.ClearInputField(self)
	end
end

M.OnChatMessageChanged_CheckIsCurrentChannel = function(self, data)
	if self.topChannelId == data.topChannelId or not ulong.equals(self.subChannelId, data.subChannelId) or not data.msg then
		return false
	end

	if gChatUtils.IsStoryChannel(self.topChannelId) and LTConfig.NPCChatConfig.GetConfig(data.msg.npcChatId).ChatType == gChatManager.currentNpcChatType then
		return false
	end

	return true
end

M.OnChatMessageChanged = function(self, _, data)
	if self.OnChatMessageChanged_CheckIsCurrentChannel(self, data) then
		self.ReceiveNewMessage(self, data.msg, data.skipScroll)
	end
end

M.OnClearChatChannelMessage = function(self, _, data)
	if data.topChannelId ~= self.topChannelId and data.subChannelId ~= self.subChannelId and gClientUtils.NotNil(self.bindData.chatList) then
		self.cs:ClearAndRefreshAllMsg()
	end
end

M.OnDownloadVoiceSuccess = function(self, _, data)
end

M.OnAudioPlayFinish = function(self, _, msgId)
end

M.OnChatRemoveChannel = function(self, _, data)
	if data.topChannelId ~= self.topChannelId and data.subChannelId ~= self.subChannelId then
		self.ClearChatItems(self)
	end
end

M.OnPhotoTaskTarget = function(self, _, data)
end
