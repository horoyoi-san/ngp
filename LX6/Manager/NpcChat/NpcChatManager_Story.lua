-- Original chunk: @Lua\LuaFiles\LX6\Manager\NpcChat\NpcChatManager_Story.lua
-- Decompiled from: 00304_NpcChatManager_Story.lua_9d98e089ca7f.luajit

local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local M = C_NpcChatManager
M.PlayerSelf = 1

M.Init_Story = function(self)
	self.m_npcChatsDict = {}
	self.m_npcGroupChatsDict = {}
	self.isNotClearNpcGroupChats = false
	self.openingChatPanelLock = false
	self.needClickChatIds = {}
	self.clickedChatIds = {}
end

M._LockClosePhoneForOpeningChat = function(self)
	self.openingChatPanelLock = true
end

M._UnlockClosePhoneForOpeningChat = function(self)
	self.openingChatPanelLock = false
end

M.OnSyncPlayerInfo = function(self, playerInfo)
	self.playerInfoOver = false
	self.isNotClearNpcGroupChats = false
	local npcCultivationInfo = playerInfo.InfoMinor.InfoNpcCultivation
	local npcChats = npcCultivationInfo.NpcChats

	if not npcCultivationInfo.NpcGroupChats or #npcCultivationInfo.NpcGroupChats < 0 then
		self.isNotClearNpcGroupChats = true
	end

	local npcGroupChats = npcCultivationInfo.NpcGroupChats

	self.LoadClientChannel(self)
	self.RefreshNpcChatPhoneAppRedDot(self)

	self.m_npcChatsDict = {}

	for _, npcChatData in ipairs(npcChats) do
		self.m_npcChatsDict[npcChatData.TemplateId] = gNpcChatUtils.ConvertCSNpcChatData(npcChatData)
	end

	self.m_npcGroupChatsDict = {}

	for _, npcGroupChatData in ipairs(npcGroupChats) do
		self.m_npcGroupChatsDict[npcGroupChatData.TemplateId] = gNpcChatUtils.ConvertCSNpcGroupChatData(npcGroupChatData)
	end
end

M.LoadNpcChatMsgList = function(self)
	for npcId, _ in pairs(self.m_npcChatsDict) do
		self.ReLoadNpcChatMsg(self, npcId, false)
	end

	self.ReLoadNpcChatMsg(self, 1, false)

	for groupId, _ in pairs(self.m_npcGroupChatsDict) do
		self.ReLoadNpcChatMsg(self, groupId, true)
	end

	self.CleanupOrphanNeedClickMsgIds(self)
end

M.GetOrAddNpcChatData = function(self, npcId)
	if not self.m_init then
		return nil
	end

	local npcChatData = self.m_npcChatsDict[npcId]

	if npcChatData then
		return npcChatData
	end

	local data = {
		TemplateId = npcId,
		NpcChatListDict = {},
		DialogChatListDict = {},
		InviteChatList = {}
	}
	self.m_npcChatsDict[npcId] = data

	return data
end

M.GetOrAddNpcGroupChatData = function(self, groupId)
	if not self.m_init then
		return nil
	end

	local npcGroupChatData = self.m_npcGroupChatsDict[groupId]

	if npcGroupChatData then
		return npcGroupChatData
	end

	local data = {
		TemplateId = groupId,
		NpcChatListDict = {},
		DialogChatListDict = {},
		InviteChatList = {}
	}
	self.m_npcGroupChatsDict[groupId] = data

	return data
end

M.AddNewNpcChatItem = function(self, chatItem, isSkipAllMessage)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.ChatId)

	if not cfg then
		print_error("NPCChat表没有查到 ID=", chatItem.ChatId, "!")

		return
	end

	local msg = gNpcChatUtils.NewFromNpcChatItem(chatItem, isSkipAllMessage)

	if cfg.ChatType ~= ChatType.Fake then
		self.ShowNpcNewChat(self, msg, false)

		return
	end

	local asNpcCultivation = cfg.AsNpcCultivation
	local isGroup = cfg.ChatGroup >= 0
	local id = isGroup and cfg.ChatGroup or cfg.NPCid
	local topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc

	if not self:GetChannel(topChannelId, id) then
		self.ReLoadNpcChatMsg(self, id, isGroup)
	end

	local needShow = true
	local lastMsg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(topChannelId, id)
	local hasNextMessage = lastMsg and gNpcChatUtils.HasNextMessage(lastMsg)

	if hasNextMessage and not gNpcChatUtils.IsNextMessage(lastMsg, msg) then
		needShow = false
	end

	local chatData = nil

	if isGroup then
		chatData = self.GetOrAddNpcGroupChatData(self, cfg.ChatGroup)
	else
		chatData = self.GetOrAddNpcChatData(self, cfg.NPCid)
	end

	if not chatData then
		return
	end

	if asNpcCultivation ~= 0 then
		asNpcCultivation = msg.belongNpc
	end

	local chatInfoList = chatData.NpcChatListDict

	if not chatInfoList[asNpcCultivation] then
		chatInfoList[asNpcCultivation] = {
			ChatList = {}
		}
	end

	local chatList = chatInfoList[asNpcCultivation].ChatList

	table.insert(chatList, msg)

	if cfg.ChatType ~= ChatType.Normal then
		if needShow then
			self.ShowNpcNewChat(self, msg, false)
		end
	elseif cfg.ChatType ~= ChatType.Invite then
		self.ShowNpcNewChat(self, msg, false)
	elseif cfg.ChatType ~= ChatType.Dialog then
		if needShow then
			self._LockClosePhoneForOpeningChat(self)

			if not self.ShowNpcChatDialogPanel(self, topChannelId, id, cfg) then
				self._UnlockClosePhoneForOpeningChat(self)
				self.ShowNpcNewChat(self, msg, false)
			end
		end
	else
		print_error("未知的聊天类型", cfg.ChatType, cfg.Id)
	end
end

M.ClearNpcChatInfo = function(self, npcId)
	if npcId ~= 0 then
		local npcIdList = {}

		for id, _ in pairs(self.m_npcChatsDict) do
			table.insert(npcIdList, id)
		end

		for _, singleNpcId in ipairs(npcIdList) do
			self.ClearStoryChannel(self, singleNpcId, false)
		end
	else
		self.ClearStoryChannel(self, npcId, false)
	end
end

M.ClearNpcGroupChatInfo = function(self, groupId)
	if groupId ~= 0 then
		local npcGroupIdList = {}

		for id, _ in pairs(self.m_npcGroupChatsDict) do
			table.insert(npcGroupIdList, id)
		end

		for _, singleGroupId in ipairs(npcGroupIdList) do
			self.ClearStoryChannel(self, singleGroupId, true)
		end
	else
		self.ClearStoryChannel(self, groupId, true)
	end
end

M.ClearStoryChannel = function(self, templateId, isGroup)
	local chatsDict = isGroup and self.m_npcGroupChatsDict or self.m_npcChatsDict

	if not chatsDict or not chatsDict[templateId] then
		return
	end

	chatsDict[templateId] = nil

	self.ReLoadNpcChatMsg(self, templateId, isGroup)
end

M.ClearUncompletedInvite = function(self)
	if not self.m_init then
		return
	end

	local changed = false
	local removedChatIds = {}
	local allChatData = {}

	for _, chatData in pairs(self.m_npcChatsDict) do
		table.insert(allChatData, chatData)
	end

	for _, chatData in pairs(self.m_npcGroupChatsDict) do
		table.insert(allChatData, chatData)
	end

	for _, chatData in ipairs(allChatData) do
		if chatData.NpcChatListDict then
			for _, chatInfo in pairs(chatData.NpcChatListDict) do
				local chatList = chatInfo.ChatList

				if chatList and #chatList <= 0 then
					local lastMsg = chatList[#chatList]
					local lastCfg = LTConfig.NPCChatConfig.GetConfig(lastMsg.npcChatId)

					if lastCfg and lastCfg.ChatType ~= ChatType.Invite and gNpcChatUtils.HasNextMessage(lastMsg) then
						local segmentStart = #chatList

						for i = #chatList - 1, 1, -1 do
							local msg = chatList[i]
							local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

							if not cfg or cfg.ChatType == ChatType.Invite or not gNpcChatUtils.IsNextMessage(msg, chatList[i + 1]) then
								break
							end

							segmentStart = i
						end

						for i = segmentStart, #chatList do
							table.insert(removedChatIds, chatList[i].npcChatId)
						end

						for _ = segmentStart, #chatList do
							table.remove(chatList, segmentStart)
						end

						changed = true
					end
				end
			end
		end
	end

	for _, chatId in ipairs(removedChatIds) do
		self.RemoveFromAllChannelMessages(self, chatId)
	end

	if changed then
		if self.isSceneLoading then
			table.insert(self.waitSceneLoadCallBack, function ()
				slot0 = gClientToGameDelegate

				slot0:AskClearNpcUncompletedInviteChat().Callback = function (err)
					if err == LTConfig.MessageConfig.Ok then
						gDisplayMessageMgr:DisplayServerMessageId(err)

						return
					end
				end
			end)
		else
			slot4 = gClientToGameDelegate

			slot4:AskClearNpcUncompletedInviteChat().Callback = function (err)
				if err == LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end

		gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_CHANGED, {
			["\\xcb\\xde7\\xf9"] = true
		})
	end
end

M.GetNpcChatList = function(self, chatType, channelId, isGroup, specialAsNpc)
	local chatData = self.GetChatData(self, channelId, isGroup)

	if not chatData then
		return {}
	end

	local NpcId = specialAsNpc or gNpcChatUtils.GetCurrentNpcId()
	local chatInfoList = chatData.NpcChatListDict
	local allChats = {}

	if chatType ~= ChatType.Normal then
		for _, asNpcId in ipairs({
			NpcId,
			0
		}) do
			local chatInfo = chatInfoList[asNpcId]

			if chatInfo and chatInfo.ChatList then
				for _, chatItem in ipairs(chatInfo.ChatList) do
					table.insert(allChats, chatItem)
				end
			end
		end

		return allChats
	elseif chatType ~= ChatType.Invite then
		for _, asNpcId in ipairs({
			0,
			NpcId
		}) do
			local chatInfo = chatInfoList[asNpcId]

			if chatInfo and chatInfo.ChatList then
				for _, chatItem in ipairs(chatInfo.ChatList) do
					local msgCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

					if msgCfg and msgCfg.ChatType ~= ChatType.Invite and (msgCfg.NPCid ~= channelId or msgCfg.ChatGroup ~= channelId) then
						table.insert(allChats, chatItem)
					end
				end
			end
		end

		return allChats
	elseif chatType ~= ChatType.Dialog then
		for _, asNpcId in ipairs({
			0,
			NpcId
		}) do
			local chatInfo = chatInfoList[asNpcId]

			if chatInfo and chatInfo.ChatList then
				for _, chatItem in ipairs(chatInfo.ChatList) do
					local msgCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

					if msgCfg and msgCfg.ChatType ~= ChatType.Dialog then
						table.insert(allChats, chatItem)
					end
				end
			end
		end

		if #allChats <= 0 then
			local segments = self.GroupMessagesBySegment(self, allChats)

			if #segments <= 0 then
				table.sort(segments, function (segmentA, segmentB)
					if #segmentA ~= 0 then
						return false
					end

					if #segmentB ~= 0 then
						return true
					end

					return segmentB[1].timeStamp <= segmentA[1].timeStamp
				end)

				local topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc

				local segmentHasUnclickedNeedClick = function(segment)
					for _, m in ipairs(segment) do
						if self:IsMsgNeedClick(topChannelId, channelId, m.npcChatId, m.timeStamp) then
							return true
						end
					end

					return false
				end

				for _, segment in ipairs(segments) do
					local lastMsg = segment[#segment]

					if gNpcChatUtils.HasNextMessage(lastMsg) or segmentHasUnclickedNeedClick(segment) then
						return segment
					end
				end

				local lastSegment = segments[#segments]

				if lastSegment and #lastSegment ~= 1 then
					local lastMsg = lastSegment[#lastSegment]
					local cfg = LTConfig.NPCChatConfig.GetConfig(lastMsg.npcChatId)

					if not gNpcChatUtils.HasNextMessage(lastMsg) and cfg.IsFirst then
						return lastSegment
					end
				end
			end
		end

		return {}
	end

	return {}
end

M.CheckUncompletedChatAndDialog = function(self, showNotify)
	if not self.m_init then
		return
	end

	local uncompletedChats = self.GetAllUncompletedChats(self)

	self.CheckAndShowUncompletedChats(self, uncompletedChats, showNotify)
end

M.GetAllUncompletedChats = function(self)
	local allChats = {}
	local dialogChats = self.GetUncompletedDialogList(self)

	for _, chat in ipairs(dialogChats) do
		table.insert(allChats, chat)
	end

	local normalChats = self.GetUncompletedNormalChatList(self)

	for _, chat in ipairs(normalChats) do
		table.insert(allChats, chat)
	end

	return allChats
end

M.GetUncompletedDialogList = function(self)
	local dialogChats = {}

	for _, chatData in pairs(self.m_npcChatsDict) do
		local chats = self.GetOneNpcUncompletedDialogList(self, chatData)

		for _, chat in ipairs(chats) do
			table.insert(dialogChats, chat)
		end
	end

	for _, chatData in pairs(self.m_npcGroupChatsDict) do
		local chats = self.GetOneNpcUncompletedDialogList(self, chatData)

		for _, chat in ipairs(chats) do
			table.insert(dialogChats, chat)
		end
	end

	local isAlreadyInList = function(list, topChannelId, subChannelId)
		for _, c in ipairs(list) do
			if c.topChannelId ~= topChannelId and c.templateId ~= subChannelId then
				return true
			end
		end

		return false
	end

	local needClick = self.GetChannelsWithNeedClick(self)

	for _, info in ipairs(needClick) do
		if not isAlreadyInList(dialogChats, info.topChannelId, info.subChannelId) then
			table.insert(dialogChats, {
				["\\xd8\\xc8:\r\r\\xf5"] = 0,
				chatType = ChatType.Dialog,
				topChannelId = info.topChannelId,
				templateId = info.subChannelId,
				cfg = info.chatCfg,
				priority = self.GetChatPriority(self, ChatType.Dialog, 0)
			})
		end
	end

	return dialogChats
end

local MakeNeedClickKey = function(chatId, timeStamp)
	return tostring(chatId) .. "|" .. tostring(timeStamp or 0)
end

M.MarkMsgNeedClick = function(self, topChannelId, subChannelId, chatId, timeStamp)
	if not topChannelId or not subChannelId or not chatId then
		return
	end

	local key = MakeNeedClickKey(chatId, timeStamp)

	if self.clickedChatIds[key] then
		return
	end

	local topMap = self.needClickChatIds[topChannelId]

	if not topMap then
		topMap = {}
		self.needClickChatIds[topChannelId] = topMap
	end

	local subMap = topMap[subChannelId]

	if not subMap then
		subMap = {}
		topMap[subChannelId] = subMap
	end

	subMap[key] = {
		chatId = chatId,
		timeStamp = timeStamp or 0
	}
end

M.MarkMsgClicked = function(self, topChannelId, subChannelId, chatId, timeStamp)
	if not chatId then
		return
	end

	local key = MakeNeedClickKey(chatId, timeStamp)
	self.clickedChatIds[key] = true
	local topMap = self.needClickChatIds[topChannelId]

	if topMap then
		local subMap = topMap[subChannelId]

		if subMap then
			subMap[key] = nil

			if next(subMap) ~= nil then
				topMap[subChannelId] = nil
			end
		end

		if next(topMap) ~= nil then
			self.needClickChatIds[topChannelId] = nil
		end
	end
end

M.IsMsgClicked = function(self, chatId, timeStamp)
	if not chatId then
		return false
	end

	return self.clickedChatIds[MakeNeedClickKey(chatId, timeStamp)] ~= true
end

M.IsMsgNeedClick = function(self, topChannelId, subChannelId, chatId, timeStamp)
	local topMap = self.needClickChatIds[topChannelId]

	if not topMap then
		return false
	end

	local subMap = topMap[subChannelId]

	if not subMap then
		return false
	end

	return subMap[MakeNeedClickKey(chatId, timeStamp)] == nil
end

M.GetChannelsWithNeedClick = function(self)
	local result = {}

	for topChannelId, topMap in pairs(self.needClickChatIds) do
		for subChannelId, subMap in pairs(topMap) do
			local items = {}
			local anyChatId = nil

			for _, info in pairs(subMap) do
				table.insert(items, info)

				anyChatId = anyChatId or info.chatId
			end

			if anyChatId then
				local chatCfg = LTConfig.NPCChatConfig.GetConfig(anyChatId)

				if chatCfg then
					table.insert(result, {
						topChannelId = topChannelId,
						subChannelId = subChannelId,
						chatCfg = chatCfg,
						items = items
					})
				end
			end
		end
	end

	return result
end

M.CleanupOrphanNeedClickMsgIds = function(self)
	local collectLiveKeys = function(chatsDict, topChannelId, liveSet)
		for templateId, chatData in pairs(chatsDict) do
			local subChannelId = templateId
			local subSet = liveSet[topChannelId] and liveSet[topChannelId][subChannelId]

			if not subSet then
				liveSet[topChannelId] = liveSet[topChannelId] or {}
				subSet = {}
				liveSet[topChannelId][subChannelId] = subSet
			end

			if chatData.NpcChatListDict then
				for _, chatInfo in pairs(chatData.NpcChatListDict) do
					if chatInfo and chatInfo.ChatList then
						for _, chatItem in ipairs(chatInfo.ChatList) do
							if chatItem and chatItem.npcChatId then
								subSet[MakeNeedClickKey(chatItem.npcChatId, chatItem.timeStamp)] = true
							end
						end
					end
				end
			end
		end
	end

	local liveSet = {}

	collectLiveKeys(self.m_npcChatsDict, gNpcChatConst.ChatTopChannel.Npc, liveSet)
	collectLiveKeys(self.m_npcGroupChatsDict, gNpcChatConst.ChatTopChannel.NpcGroup, liveSet)

	for topChannelId, topMap in pairs(self.needClickChatIds) do
		local liveTop = liveSet[topChannelId]

		for subChannelId, subMap in pairs(topMap) do
			local liveSub = liveTop and liveTop[subChannelId]

			if liveSub then
				for key, _ in pairs(subMap) do
					if not liveSub[key] then
						subMap[key] = nil
					end
				end
			else
				topMap[subChannelId] = nil
			end

			if topMap[subChannelId] and next(subMap) ~= nil then
				topMap[subChannelId] = nil
			end
		end

		if next(topMap) ~= nil then
			self.needClickChatIds[topChannelId] = nil
		end
	end
end

M.GetUncompletedNormalChatList = function(self)
	local normalChats = {}

	for _, chatData in pairs(self.m_npcChatsDict) do
		local chats = self.GetOneNpcUncompletedNormalChatList(self, chatData)

		for _, chat in ipairs(chats) do
			table.insert(normalChats, chat)
		end
	end

	for _, chatData in pairs(self.m_npcGroupChatsDict) do
		local chats = self.GetOneNpcUncompletedNormalChatList(self, chatData)

		for _, chat in ipairs(chats) do
			table.insert(normalChats, chat)
		end
	end

	return normalChats
end

M.IsMessageWithinFutureOneDay = function(self, msg)
	if not msg or not msg.timeStamp then
		return false
	end

	local currentTime = gCS.TimeManager.ServerUnixTime
	local oneDayInSeconds = gClientConst.SECONDS_PER_DAY
	local timeDiff = msg.timeStamp - currentTime

	return oneDayInSeconds < timeDiff
end

M.GetOneNpcUncompletedDialogList = function(self, chatData)
	local dialogChats = {}
	local chatInfoList = chatData.NpcChatListDict

	if not chatInfoList then
		return dialogChats
	end

	local currentNpcId = gNpcChatUtils.GetCurrentNpcId()

	for _, asNpcId in ipairs({
		0,
		currentNpcId
	}) do
		local chatInfo = chatInfoList[asNpcId]

		if chatInfo and chatInfo.ChatList and #chatInfo.ChatList <= 0 then
			local dialogMessages = {}
			local msgCfg = nil

			for _, chatItem in ipairs(chatInfo.ChatList) do
				msgCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if msgCfg and msgCfg.ChatType ~= ChatType.Dialog and self.IsMessageWithinFutureOneDay(self, chatItem) and gNpcChatUtils.ShouldShowInOnlineMode(msgCfg) then
					table.insert(dialogMessages, chatItem)
				end
			end

			if #dialogMessages <= 0 then
				local lastMsg = dialogMessages[#dialogMessages]

				if lastMsg and gNpcChatUtils.HasNextMessage(lastMsg) then
					local topChannelId, templateId = gNpcChatUtils.GetNpcChatChannelId(msgCfg)

					table.insert(dialogChats, {
						chatType = ChatType.Dialog,
						topChannelId = topChannelId,
						templateId = templateId,
						cfg = msgCfg,
						asNpcId = asNpcId,
						priority = self.GetChatPriority(self, ChatType.Dialog, asNpcId),
						msg = lastMsg
					})
				end
			end
		end
	end

	for npcId, chatInfo in pairs(chatInfoList) do
		if npcId == 0 and npcId == currentNpcId and chatInfo and chatInfo.ChatList and #chatInfo.ChatList <= 0 then
			local dialogMessages = {}
			local msgCfg = nil

			for _, chatItem in ipairs(chatInfo.ChatList) do
				msgCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if msgCfg and msgCfg.ChatType ~= ChatType.Dialog and self.IsMessageWithinFutureOneDay(self, chatItem) and gNpcChatUtils.ShouldShowInOnlineMode(msgCfg) then
					table.insert(dialogMessages, chatItem)
				end
			end

			if #dialogMessages <= 0 and msgCfg and msgCfg.SpecialReadableCharacter ~= currentNpcId then
				local lastMsg = dialogMessages[#dialogMessages]

				if lastMsg and gNpcChatUtils.HasNextMessage(lastMsg) then
					local topChannelId, templateId = gNpcChatUtils.GetNpcChatChannelId(msgCfg)

					table.insert(dialogChats, {
						chatType = ChatType.Dialog,
						topChannelId = topChannelId,
						templateId = templateId,
						cfg = msgCfg,
						asNpcId = npcId,
						priority = self.GetChatPriority(self, ChatType.Dialog, npcId),
						msg = lastMsg
					})
				end
			end
		end
	end

	return dialogChats
end

M.GetOneNpcUncompletedNormalChatList = function(self, chatData)
	local normalChats = {}
	local npcChatListDict = chatData.NpcChatListDict

	if not npcChatListDict then
		return normalChats
	end

	local currentNpcId = gNpcChatUtils.GetCurrentNpcId()

	for _, asNpcId in ipairs({
		0,
		currentNpcId
	}) do
		local chatInfoList = npcChatListDict[asNpcId]

		if chatInfoList and chatInfoList.ChatList and #chatInfoList.ChatList <= 0 then
			local normalMessages = {}

			for _, chatItem in ipairs(chatInfoList.ChatList) do
				local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if cfg and cfg.ChatType ~= ChatType.Normal and gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
					table.insert(normalMessages, chatItem)
				end
			end

			if #normalMessages <= 0 then
				local lastNormalMsg = normalMessages[#normalMessages]

				if lastNormalMsg and gNpcChatUtils.HasNextMessage(lastNormalMsg) then
					local cfg = LTConfig.NPCChatConfig.GetConfig(lastNormalMsg.npcChatId)

					if cfg and gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
						local topChannelId, templateId = gNpcChatUtils.GetNpcChatChannelId(cfg)

						table.insert(normalChats, {
							chatType = ChatType.Normal,
							topChannelId = topChannelId,
							templateId = templateId,
							cfg = cfg,
							asNpcId = asNpcId,
							priority = self.GetChatPriority(self, ChatType.Normal, asNpcId),
							msg = lastNormalMsg,
							lastMsg = normalMessages[#normalMessages - 1]
						})
					end
				end
			end
		end
	end

	return normalChats
end

M.GetChatPriority = function(self, chatType, asNpcId)
	local priority = 0

	if chatType ~= ChatType.Dialog then
		priority = priority + 100
	elseif chatType ~= ChatType.Normal then
		priority = priority + 200
	end

	if asNpcId ~= 0 then
		priority = priority + 10
	end

	return priority
end

M.CheckAndShowUncompletedChats = function(self, uncompletedChats, showNotify)
	if not uncompletedChats or #uncompletedChats ~= 0 then
		return
	end

	table.sort(uncompletedChats, function (a, b)
		return a.priority <= b.priority
	end)

	local showData = {}

	for _, chat in ipairs(uncompletedChats) do
		local success = false

		if chat.chatType ~= ChatType.Dialog then
			success = self.ShowNpcChatDialogPanel(self, chat.topChannelId, chat.templateId, chat.cfg)
		elseif chat.chatType ~= ChatType.Normal then
			local isFirstMessage = not chat.lastMsg or not gNpcChatUtils.HasNextMessage(chat.lastMsg)

			if isFirstMessage then
				if self.ShowNpcNewChat(self, chat.msg, false, true) and gNpcChatUtils.ShouldShowInOnlineMode(chat.cfg) then
					table.insert(showData, {
						topChannelId = chat.msg.topChannelId,
						subChannelId = chat.msg.subChannelId,
						chatCfg = chat.cfg,
						msg = chat.msg
					})
				end
			else
				local params = {
					["EH~jK-/"] = true,
					topChannelId = chat.topChannelId,
					subChannelId = chat.templateId,
					chatCfg = chat.cfg
				}

				gNpcChatUtils.OpenChatPanel(params)

				success = true
			end
		end

		if success then
			break
		end
	end

	gNpcChatUtils.ShowChatNotifyList(showData)
end

M.CheckAndNotifyUncompletedNormalChats = function(self, uncompletedChats)
	if not uncompletedChats or #uncompletedChats ~= 0 then
		return
	end

	table.sort(uncompletedChats, function (a, b)
		return a.priority <= b.priority
	end)

	local showData = {}

	for _, chat in ipairs(uncompletedChats) do
		if chat.chatType ~= ChatType.Normal then
			local isFirstMessage = not chat.lastMsg or not gNpcChatUtils.HasNextMessage(chat.lastMsg)

			if isFirstMessage and gNpcChatUtils.ShouldShowInOnlineMode(chat.cfg) then
				local topChannelId = chat.msg.topChannelId
				local subChannelId = chat.msg.subChannelId
				local channel = self.GetChannel(self, topChannelId, subChannelId)

				if not channel or not channel.lastMessage then
					self.ShowNpcNewChat(self, chat.msg, false, true)
				end

				table.insert(showData, {
					topChannelId = topChannelId,
					subChannelId = subChannelId,
					chatCfg = chat.cfg,
					msg = chat.msg
				})
			end
		end
	end

	gNpcChatUtils.ShowChatNotifyList(showData)
end

M.GetAllNpcMessage = function(self, topChannelId, subChannelId, chatType, specialAsNpc)
	local isGroup = topChannelId ~= gNpcChatConst.ChatTopChannel.NpcGroup
	local chatList = self:GetNpcChatList(chatType, subChannelId, isGroup, specialAsNpc)

	for _, msg in ipairs(chatList) do
		self.ShowNpcNewChat(self, msg, true)
	end
end

M.ShowNpcNewChat = function(self, msg, isHistory, notShowNotify)
	local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if not cfg then
		return false
	end

	if not gNpcChatUtils.IsVisibleToCurrentNpc(cfg.Id) then
		return false
	end

	if not gNpcChatUtils.ShouldShowInOnlineMode(cfg) then
		return false
	end

	msg.isHistory = isHistory or false
	local topChannelId = msg.topChannelId
	local subChannelId = msg.subChannelId

	if cfg.ChatType == ChatType.Normal then
		self.AddChannelMessage(self, topChannelId, subChannelId, msg, nil)
		self.SetLastMessage(self, topChannelId, subChannelId, msg)

		return true
	end

	local lastMsg = gNpcChatUtils.GetCurrentNpcChannelLastMsg(topChannelId, subChannelId)

	if lastMsg and lastMsg.msgId ~= msg.msgId then
		return false
	end

	local channel = self:GetChannel(topChannelId, subChannelId)
	local alreadyHave = channel and channel.messageDict[msg.msgId] and true or false

	self:AddChannelMessage(topChannelId, subChannelId, msg, nil)
	self:SetLastMessage(topChannelId, subChannelId, msg)

	if isHistory then
		self.UpdateUnreadMsgCount(self, msg, true)

		return not alreadyHave
	end

	self.UpdateUnreadMsgCount(self, msg, false)

	if not self.IsCurrentChannel(self, topChannelId, subChannelId) and not notShowNotify then
		gNpcChatUtils.ShowChatNotify(topChannelId, subChannelId)
	end

	return not alreadyHave
end

M.ClearAllNpcDialogChat = function(self)
	for _, chatData in pairs(self.m_npcChatsDict) do
		if chatData.NpcChatListDict then
			for asNpcId, chatInfoList in pairs(chatData.NpcChatListDict) do
				if chatInfoList.ChatList then
					local filteredList = {}

					for _, chatItem in ipairs(chatInfoList.ChatList) do
						local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

						if not cfg or cfg.ChatType == ChatType.Dialog then
							table.insert(filteredList, chatItem)
						end
					end

					chatInfoList.ChatList = filteredList
				end
			end
		end

		chatData.DialogChatListDict = {}
	end

	for _, chatData in pairs(self.m_npcGroupChatsDict) do
		if chatData.NpcChatListDict then
			for asNpcId, chatInfoList in pairs(chatData.NpcChatListDict) do
				if chatInfoList.ChatList then
					local filteredList = {}

					for _, chatItem in ipairs(chatInfoList.ChatList) do
						local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

						if not cfg or cfg.ChatType == ChatType.Dialog then
							table.insert(filteredList, chatItem)
						end
					end

					chatInfoList.ChatList = filteredList
				end
			end
		end

		chatData.DialogChatListDict = {}
	end
end

M.ClearInviteChat = function(self, subChannelId, isGroup)
	local chatData = self.GetChatData(self, subChannelId, isGroup)

	if not chatData or not chatData.NpcChatListDict then
		return
	end

	for asNpcId, chatInfoList in pairs(chatData.NpcChatListDict) do
		if chatInfoList.ChatList then
			local filteredList = {}

			for _, chatItem in ipairs(chatInfoList.ChatList) do
				local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if not cfg or cfg.ChatType == ChatType.Invite then
					table.insert(filteredList, chatItem)
				end
			end

			chatInfoList.ChatList = filteredList
		end
	end

	chatData.InviteChatList = {}
end

M.GetChatData = function(self, channelId, isGroup)
	local chatsDict = isGroup and self.m_npcGroupChatsDict or self.m_npcChatsDict

	if not chatsDict or not chatsDict[channelId] or chatsDict[channelId].Count ~= 0 then
		return nil
	end

	return chatsDict[channelId]
end

M.ShowNpcChatDialogPanel = function(self, topChannelId, subChannelId, chatCfg)
	if chatCfg and gNpcChatUtils.IsVisibleToCurrentNpc(chatCfg.Id) ~= false then
		return false
	end

	if not gNpcChatUtils.ShouldShowInOnlineMode(chatCfg) then
		return false
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_CHAT_POPUP_DIALOG) then
		return false
	end

	if gNpcChatManager:CheckFightState() then
		local dialogData = {
			topChannelId = topChannelId,
			subChannelId = subChannelId,
			npcChatType = LTConfig.NPCChatConfig.ChatTypeType.Dialog,
			chatCfg = chatCfg
		}

		gNpcChatManager:SavePendingDialog(dialogData)
		print_debug("ShowNpcChatDialogPanel: Dialog blocked due to fight state", topChannelId, subChannelId)

		return false
	end

	if gNpcChatUtils.IsChatPanelShowing() then
		if self.currentNpcChatType ~= ChatType.Normal then
			gClientUtils.CloseMainPhonePanel()
		end

		return false
	end

	if chatCfg and chatCfg.BlockDuringTask then
		local curTask = gTaskManager:GetCurTask()

		if curTask and curTask == 0 then
			print_debug("ShowNpcChatDialogPanel: Dialog blocked due to task, BlockDuringTask=true, curTask=", curTask, "chatCfg=", chatCfg.Id)

			return false
		end
	end

	local param = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		chatCfg = chatCfg
	}

	if not gNpcChatUtils.CheckSwitchTimelineEnd() then
		print_debug("npcchat dialog被切场景Timeline阻止显示")

		return false
	end

	if gTimelineManager:Timeline_IsPlaying() then
		if not chatCfg or not chatCfg.IsPlayedTimeline then
			print_debug("NPC对话不允许在timeline中播放，如果卡流程了需要检查配置，chatCfg=", chatCfg.Id)

			return false
		end
	elseif self.HasFullscreen(self) then
		return false
	end

	gNpcChatUtils.OpenChatPanel(param)

	return true
end

M.HasFullscreen = function(self)
	if gPanelManager.currVisibleMode ~= LX6.Manager.VisibleMode.Front and gPanelManager:HasFullscreenLayer(LX6.Manager.VisibleMode.Front) then
		return true
	elseif gPanelManager.currVisibleMode ~= LX6.Manager.VisibleMode.HUD and gPanelManager:HasFullscreenLayer(LX6.Manager.VisibleMode.HUD) then
		return true
	end

	return false
end

M.GetDialogNpcChatList = function(self, channelId, isGroup)
	local chatData = self.GetChatData(self, channelId, isGroup)
	local curNpcId = gNpcChatUtils.GetCurrentNpcId()

	if not chatData or not chatData.NpcChatListDict then
		return {}
	end

	local allDialogChats = {}

	for _, asNpcId in ipairs({
		0,
		curNpcId
	}) do
		local chatInfo = chatData.NpcChatListDict[asNpcId]

		if chatInfo and chatInfo.ChatList then
			for _, chatItem in ipairs(chatInfo.ChatList) do
				local msgCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if msgCfg and msgCfg.ChatType ~= ChatType.Dialog then
					table.insert(allDialogChats, chatItem)
				end
			end
		end
	end

	return allDialogChats
end

M.GetLastDialogNpcChatItem = function(self, channelId, isGroup)
	local chatList = self:GetDialogNpcChatList(channelId, isGroup)

	return chatList[#chatList] or nil
end

M.RemoveNpcChatSegment = function(self, chatId, asNpc)
	local firstChatId = self.FindDialogueFirstChatId(self, chatId, asNpc)

	if not firstChatId then
		print_error("RemoveNpcChatSegment: 无法找到对话首句, chatId=", chatId)

		return
	end

	self:RemoveFromAllNpcChats(firstChatId, asNpc)
	self:RemoveFromAllNpcGroupChats(firstChatId, asNpc)
	self:RemoveFromAllChannelMessages(firstChatId)
	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_MESSAGE_CHANGED, {
		["1/&\\xf6v\\x8b\\xff\\xa6\\xe3\\xff\\xe9b\\xfe"] = true,
		chatId = firstChatId
	})
end

M.FindDialogueFirstChatId = function(self, chatId, asNpc)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if not cfg then
		return nil
	end

	local topChannelId, subChannelId = gNpcChatUtils.GetNpcChatChannelId(cfg)

	if not topChannelId or not subChannelId then
		return nil
	end

	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.messages or #channel.messages ~= 0 then
		if cfg.IsFirst then
			return chatId
		end

		return nil
	end

	local targetMsg, targetIndex = nil

	for i = #channel.messages, 1, -1 do
		local msg = channel.messages[i]

		if msg.npcChatId ~= chatId then
			targetMsg = msg
			targetIndex = i

			break
		end
	end

	if not targetMsg then
		if cfg.IsFirst then
			return chatId
		end

		return nil
	end

	if gNpcChatUtils.IsFirstMessage(targetMsg, topChannelId, subChannelId) then
		return chatId
	end

	for i = targetIndex - 1, 1, -1 do
		local prevMsg = channel.messages[i]

		if prevMsg then
			if gNpcChatUtils.IsFirstMessage(prevMsg, topChannelId, subChannelId) then
				return prevMsg.npcChatId
			end

			if i >= #channel.messages then
				local nextMsg = channel.messages[i + 1]

				if nextMsg and not gNpcChatUtils.IsNextMessage(prevMsg, nextMsg) then
					break
				end
			end
		end
	end

	return chatId
end

M.RemoveFromAllNpcChats = function(self, chatId, asNpc)
	for _, chatData in pairs(self.m_npcChatsDict) do
		self.RemoveFromSingleChatData(self, chatData, chatId, asNpc)
	end
end

M.RemoveFromAllNpcGroupChats = function(self, chatId, asNpc)
	for _, chatData in pairs(self.m_npcGroupChatsDict) do
		self.RemoveFromSingleChatData(self, chatData, chatId, asNpc)
	end
end

M.RemoveFromSingleChatData = function(self, chatData, chatId, asNpc)
	if chatData.NpcChatListDict then
		if asNpc then
			local msgList = chatData.NpcChatListDict[asNpc]

			self.RemoveSegmentFromChatList(self, msgList, chatId)
		else
			for npcId, msgList in pairs(chatData.NpcChatListDict) do
				self.RemoveSegmentFromChatList(self, msgList, chatId)
			end
		end
	end
end

M.RemoveSegmentFromChatList = function(self, chatList, chatId)
	if not chatList then
		return
	end

	if chatList.ChatList then
		chatList = chatList.ChatList
	end

	for i = #chatList, 1, -1 do
		local msg = chatList[i]

		if msg.npcChatId ~= chatId then
			for _ = i, #chatList do
				table.remove(chatList, i)
			end

			break
		end
	end
end

M.RemoveFromAllChannelMessages = function(self, chatId)
	if not self.clientChannels then
		return
	end

	for topChannelId, topChannel in pairs(self.clientChannels) do
		if topChannel.subChannels then
			for subChannelId, subChannel in pairs(topChannel.subChannels) do
				self.RemoveSegmentFromChannelMessages(self, subChannel, chatId)
			end
		else
			self.RemoveSegmentFromChannelMessages(self, topChannel, chatId)
		end
	end
end

M.RemoveSegmentFromChannelMessages = function(self, channel, chatId)
	if not channel or not channel.messages then
		return
	end

	local deleteCount = 0

	for i = #channel.messages, 1, -1 do
		local msg = channel.messages[i]

		if msg and msg.npcChatId ~= chatId then
			for j = i, #channel.messages do
				local deletedMsg = table.remove(channel.messages, i)

				if deletedMsg then
					deleteCount = deleteCount + 1

					if channel.messageDict then
						channel.messageDict[deletedMsg.msgId] = nil
					end
				end
			end

			if channel.lastMessage and channel.lastMessage.npcChatId ~= chatId and #channel.messages <= 0 then
				channel.lastMessage = channel.messages[#channel.messages]

				break
			end

			channel.lastMessage = nil

			break
		end
	end

	channel.unread = math.max(0, channel.unread - deleteCount)
end

M.ReadNpcChat = function(self, topChannelId, subChannelId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.lastMessage then
		return
	end

	channel.lastMessage.isHistory = true
end

M.UnReadNpcChat = function(self, topChannelId, subChannelId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.lastMessage then
		return
	end

	channel.lastMessage.isHistory = false
end

M.IsUnReadNpcChat = function(self, topChannelId, subChannelId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.lastMessage then
		return false
	end

	return not channel.lastMessage.isHistory
end

M.SortSegmentsByLastMessageTime = function(self, segments)
	local normalIncompleteSegment = nil
	local otherSegments = {}

	for _, segment in ipairs(segments) do
		if #segment <= 0 then
			local lastMsg = segment[#segment]
			local cfg = LTConfig.NPCChatConfig.GetConfig(lastMsg.npcChatId)

			if cfg and cfg.ChatType ~= ChatType.Normal and gNpcChatUtils.HasNextMessage(lastMsg) then
				if normalIncompleteSegment == nil then
					print_error("发现多个未完成的Normal段落，这不应该发生！")
				end

				normalIncompleteSegment = segment
			else
				table.insert(otherSegments, segment)
			end
		end
	end

	table.sort(otherSegments, function (segmentA, segmentB)
		if #segmentA ~= 0 then
			return false
		end

		if #segmentB ~= 0 then
			return true
		end

		return segmentA[#segmentA].timeStamp <= segmentB[#segmentB].timeStamp
	end)

	local result = {}

	for _, segment in ipairs(otherSegments) do
		table.insert(result, segment)
	end

	if normalIncompleteSegment then
		table.insert(result, normalIncompleteSegment)
	end

	return result
end

M.GroupMessagesBySegment = function(self, messages)
	if not messages or #messages ~= 0 then
		return {}
	end

	local segments = {}
	local currentSegment = {}

	for i, msg in ipairs(messages) do
		table.insert(currentSegment, msg)

		if not gNpcChatUtils.HasNextMessage(msg) then
			if #currentSegment <= 0 then
				table.insert(segments, currentSegment)

				currentSegment = {}
			end
		else
			local nextMsg = messages[i + 1]

			if nextMsg and not gNpcChatUtils.IsNextMessage(msg, nextMsg) and #currentSegment <= 0 then
				table.insert(segments, currentSegment)

				currentSegment = {}
			end
		end
	end

	if #currentSegment <= 0 then
		table.insert(segments, currentSegment)
	end

	local filteredSegments = {}

	for _, segment in ipairs(segments) do
		if #segment <= 0 then
			local firstMsg = segment[1]

			if self.IsMessageWithinFutureOneDay(self, firstMsg) then
				table.insert(filteredSegments, segment)
			end
		end
	end

	return filteredSegments
end

M.GetMessageIndexInSegment = function(self, topChannelId, subChannelId, chatId)
	local channel = self.GetChannel(self, topChannelId, subChannelId)

	if not channel or not channel.messages or #channel.messages ~= 0 then
		return nil, , 
	end

	local targetMsg = nil

	for i = #channel.messages, 1, -1 do
		local msg = channel.messages[i]

		if msg and msg.npcChatId ~= chatId then
			targetMsg = msg

			break
		end
	end

	if not targetMsg then
		return nil, , 
	end

	local segments = self.GroupMessagesBySegment(self, channel.messages)

	for i = #segments, 1, -1 do
		local segment = segments[i]

		if segment then
			for j = #segment, 1, -1 do
				if segment[j] ~= targetMsg then
					return j, #segment, segment
				end
			end
		end
	end

	return nil, , 
end

M.GetOtherNpcChatToSelfMessages = function(self, topChannelId, subChannelId)
	local isGroup = topChannelId ~= gNpcChatConst.ChatTopChannel.NpcGroup
	local currentNpcId = gNpcChatUtils.GetCurrentNpcId() or 0
	local allMessages = {}

	if isGroup then
		local groupChatData = self.m_npcGroupChatsDict[subChannelId]

		if not groupChatData or not groupChatData.NpcChatListDict then
			return {}
		end

		local group = LTConfig.NPCChatGroupConfig.GetConfig(subChannelId)

		if group.AsNpcCultivation == 0 and currentNpcId == group.AsNpcCultivation and not table.contains(group.GroupMember, currentNpcId) then
			return {}
		end

		for npcId, chatInfo in pairs(groupChatData.NpcChatListDict) do
			if npcId == currentNpcId and chatInfo.ChatList then
				local tempMessages = {}

				for _, chatMsg in ipairs(chatInfo.ChatList) do
					if gNpcChatUtils.CanShowInNormalChatHistory(chatMsg, currentNpcId) then
						local msg = gNpcChatUtils.NewFromNpcChatMsg(chatMsg)
						msg.fromOther = true

						table.insert(tempMessages, msg)

						if not gNpcChatUtils.HasNextMessage(msg) then
							for _, _msg in ipairs(tempMessages) do
								table.insert(allMessages, _msg)
							end

							tempMessages = {}
						end
					end
				end
			end
		end

		return allMessages
	end

	local otherChatData = self.m_npcChatsDict[currentNpcId]

	if not otherChatData or not otherChatData.NpcChatListDict then
		return {}
	end

	local crossChatInfo = otherChatData.NpcChatListDict[subChannelId]

	if crossChatInfo and crossChatInfo.ChatList then
		local tempMessages = {}

		for _, chatMsg in ipairs(crossChatInfo.ChatList) do
			if gNpcChatUtils.CanShowInNormalChatHistory(chatMsg, currentNpcId) then
				local msg = gNpcChatUtils.NewFromNpcChatMsg(chatMsg)
				msg.fromOther = true

				table.insert(tempMessages, msg)

				if not gNpcChatUtils.HasNextMessage(msg) then
					for _, _msg in ipairs(tempMessages) do
						table.insert(allMessages, _msg)
					end

					tempMessages = {}
				end
			end
		end
	end

	return allMessages
end
