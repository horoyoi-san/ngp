-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialChattingListBaseStore.lua
-- Decompiled from: 01308_SocialChattingListBaseStore.lua_0a81af1bf682.luajit

C_SocialChattingListBaseStore = DefClass("C_SocialChattingListBaseStore", C_SocialChattingListBaseStore, C_StoreGroup)
GroupName2Class.SocialChattingListBaseStore = C_SocialChattingListBaseStore
local M = C_SocialChattingListBaseStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local json = require("cjson/json")
local CustomInviteType = {
	["}\\xaf\\xb0\\xbb\\xaf"] = 1,
	["\\x8c\\xb0\\xaez2\\xff*"] = 2
}
M.SocialChattingListItemTpl = {
	["\\x82\\xbf\\xa2~;\\xc1"] = 4,
	["}\\xa7\\xa1\\x90\\x9a"] = 7,
	["\\xef\\xd4\\xdd"] = 2,
	["}\\xa7\\xa1\\x90\\x84"] = 8,
	["Uͼ\\x90\\xb7\n\\xf6\\xda"] = 10,
	["\\x82\\xbf\\xa2~;\\xc1"] = 5,
	["I\\x8d\\xbd\\xbaϣ\\xc4<\\xac\\xa65"] = 11,
	["Hd\\xa3b\\\\x9f\\xf7Ty{yI"] = 6,
	["(M\\x89\\x9a\\xbcs"] = 1,
	["Uͼ\\x90\\xb7\n\\xf6\\xc4"] = 9,
	["(M\\x89\\x9a\\xbcm"] = 0,
	["\\xef\\xd4\\xc3"] = 3
}
M.InviteDataRefreshInterval = 10

M.ctor = function(self)
	self.topChannelId = 0
	self.subChannelId = ulong.zero
	self.chatItemList = {}
	self.chatListBtnRenderCache = {}
	self.chatListBtnStoreCache = {}
	self.optionListData = {}
	self.currentPlayingVoiceIndex = nil
	self.pendingPlayMsgId = nil
	self.manualVoiceAutoPlayEnabled = false
	self.lastMsgTimestamp = nil
	self.contentSize = {
		["Z\\xa7\\xa6\\xbb\\xbe"] = 0,
		["M\\x98\\x89\\x8bU"] = 0
	}
	self.lastChatItemTooltipBtnIdx = nil
	self.chatListIsAtBottom = nil
	self.unreadMsgCnt = nil
	self.unreadMsgSeparatorIdx = nil
	self.lastShowUnreadMsgNoticeTimestamp = nil
	self.oldUnreadMsgSeparatorIdx = nil

	self.ResetUnreadMsgStates(self)

	self.TIME_SEPARATOR_TINDEX = 6
	self.TIME_SEPARATOR_INTERVAL = 1800000
	local const = gSocialChatManager.MessageType
	self.ProcessMsgFunc = {
		[const.Text] = self.ProcessTextMsg,
		[const.Voice] = self.ProcessVoiceMsg,
		[const.TeamInvite] = self.ProcessTeamMsg,
		[const.CustomInvite] = self.ProcessCustomInviteMsg,
		[const.Emoji] = self.ProcessEmojiMsg,
		[const.Location] = self.ProcessLocationMsg
	}
end

M.OnAwake = function(self)
	self.bindData.chatList.luaRenderItem = self:CreateAction("OnRenderChatItem")
	self.bindData.chatList.onGetTIndex = self:CreateAction("OnGetChatItemTIndex")
	self.bindData.chatList.luaBeginDrag = self:CreateAction("OnChatListBeginDrag")

	self.bindData.chatList:RegisterToScrollEndEvent(self:CreateAction("OnChatListScrollEnd"))

	self.bindData.chatListNavArea.luaAreaIn = self:CreateAction("OnChatAreaNavIn")
	self.bindData.chatListNavArea.luaAreaOut = self:CreateAction("OnChatAreaNavOut")
	self.bindData.detailBtn.luaRenderTooltip = self:CreateAction("OnRenderToolTips")
	self.bindData.inviteBtn.luaClick = self:CreateAction("InviteBtnOnClick")
	self.bindData.backBtn.luaClick = self:CreateAction("BackBtnOnClick")
	self.bindData.ctrlPlayerTipsBtn.luaClick = self:CreateAction("OnCtrlPlayerTipsBtnClick")
	self.bindData.unreadMsgBtn.luaClick = self:CreateAction("OnClickGoToFirstUnreadMsg")

	if self.bindData.dpadYController then
		self.bindData.dpadYController.luaGamePadInputChanged = self.CreateAction(self, "OnDpadY")
	end

	self.bindData.leftStickController.luaGamePadInputChanged = self:CreateAction("OnLeftJoyStickMove")
	self.socialChattingBar = gStoreManager:GetStoreGroup("SocialChattingBarStore")
	self.bindData.type = 2

	self:InitToolTips()
	self:InitEvent()
end

M.InitToolTips = function(self)
	self.itemTooltips = {}

	for i = 0, LTConfig.FriendsChatItemConfig.count - 1 do
		local headTab = LTConfig.FriendsChatItemConfig.LoadAt(i)

		table.insert(self.itemTooltips, {
			id = headTab.Id,
			icon = headTab.TabIcon,
			title = headTab.TabName,
			index = headTab.TabIndex
		})
	end

	table.sort(self.itemTooltips, function (a, b)
		return a.index <= b.index
	end)
end

M.OnUpdate = function(self)
	self.UpdateInviteData(self)
end

M.InitEvent = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_CHATTING_CHANGED] = self.CreateAction(self, "OnChattingChanged"),
		[gEventConstants.SOCIAL_CHAT_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatMessageChanged"),
		[gEventConstants.SOCIAL_CHAT_LAST_MESSAGE_CHANGED] = self.CreateAction(self, "OnChatLastMessage"),
		[gEventConstants.SOCIAL_CHAT_GROUP_MEMBER_CHANGE] = self.CreateAction(self, "OnGroupMemberChanged"),
		[gEventConstants.AUDIO_PLAY_FINISH] = self.CreateAction(self, "OnAudioPlayFinish"),
		[gEventConstants.DOWNLOAD_AUDIO_SUCCESS] = self.CreateAction(self, "OnAudioDownloadSuccess"),
		[gEventConstants.SOCIAL_GROUP_NAME_CHANGED] = self.CreateAction(self, "OnChatGroupNameChanged"),
		[gEventConstants.TEAM_JOIN] = self.CreateAction(self, "RefreshAllTeamDataByForce")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnDestroy = function(self)
	self.StopVoicePlay(self)
	self.ClearTeamInfoCache(self)
	self.ClearMessageEvents(self)

	self.inviteDataSet = {}
end

M.OnEnable = function(self)
	self.bindData.isEmpty = 2

	self.ResetUnreadMsgStates(self)
	self.OnChattingChanged(self)
end

M.OnChattingChanged = function(self)
	self.StopVoicePlay(self)
	self.HideChatItemTooltips(self)

	if not gSocialChatManager.currentTopChannel or not gSocialChatManager.currentSubChannelId then
		self.bindData.isEmpty = 2

		return
	end

	self.ResetUnreadMsgStates(self)
	self.SetData(self)
	self.InitChatListData(self)

	if self.topChannelId == gSocialChatManager.currentTopChannel or self.subChannelId == gSocialChatManager.currentSubChannelId then
		self.socialChattingBar:ClearInputText()
	end

	self.bindData.chatList:ScrollToBottom(true)
end

M.ClearTeamInfoCache = function(self)
	self.teamInfoCache = {}
	self.teamInfoCacheTime = {}
	self.teamInfoRequesting = {}

	self.StopTeamInfoPolling(self)
end

M.HideChatItemTooltips = function(self)
end

M.GetLastKnownTooltipOpenBtn = function(self)
	local idx = self.lastChatItemTooltipBtnIdx

	if idx and self.bindData.chatList.VirtualStartIndex < idx and idx < self.bindData.chatList.VirtualEndIndex and self.chatListBtnStoreCache[idx] then
		return self.chatListBtnStoreCache[idx].replyAreaBtn
	else
		self.lastChatItemTooltipBtnIdx = nil
	end

	return nil
end

M.StopVoicePlayAction = function(self)
	if self.currentPlayingMsgId then
		self:StopVoiceAnimation(self.currentPlayingMsgId)
		gCS.IMManager:StopPlayAllAudios()
	end
end

M.StopVoicePlay = function(self)
	self.StopVoicePlayAction(self)

	self.currentPlayingMsgId = nil
	self.currentPlayingVoiceIndex = nil
	self.pendingPlayMsgId = nil
	self.manualVoiceAutoPlayEnabled = false
	self.voiceStoreMap = nil
end

M.OnDpadY = function(self, data)
	local chatListTooltipBtn = self:GetLastKnownTooltipOpenBtn()
	local chatListTooltipOpened = chatListTooltipBtn and chatListTooltipBtn.isTooltipOpen

	if self.bindData.detailBtn.isTooltipOpen or self.navInChatArea or self.socialChattingBar:IsEmojiPanelOpen() or chatListTooltipOpened then
		return
	end

	local value = data.ReadValueFloat(data)

	if value == 0 and (self.lastDpadY ~= nil or self.lastDpadY ~= 0) then
		if value <= 0 then
			gSocialChatManager:SelectItemByDirection(1)
		elseif value >= 0 then
			gSocialChatManager:SelectItemByDirection(-1)
		end
	end

	self.lastDpadY = value
end

M.OnLeftJoyStickMove = function(self, data)
	local chatListTooltipBtn = self:GetLastKnownTooltipOpenBtn()
	local chatListTooltipOpened = chatListTooltipBtn and chatListTooltipBtn.isTooltipOpen

	if self.bindData.detailBtn.isTooltipOpen or self.navInChatArea or self.socialChattingBar:IsEmojiPanelOpen() or chatListTooltipOpened then
		return
	end

	local vec2 = data:ReadValueVector2()

	gSocialChatManager:OnJoyStickInput(vec2.y)
end

M.ChatGroupRefreshData = function(self)
	if self.topChannelId ~= gSocialChatManager.ChatTopChannel.Group then
		self.SetGroupData(self)
		self.SetInviteBtn(self)
	end
end

M.OnChatGroupNameChanged = function(self, _, groupId)
	if self.topChannelId ~= gSocialChatManager.ChatTopChannel.Group and groupId ~= self.subChannelId then
		slot3 = gSocialChatGroupManager
		local groupData = slot3:GetGroupData(self.subChannelId)
		slot4 = gFriendManager

		slot4:GetPlayerRealName(groupData.Owner, function (ownerName)
			local fmt = LTConfig.FriendsConfig.ChangeGroupName

			self:TryInsertSeparatorMessage(gString.Format(fmt, ownerName, groupData.Name))
			self:ChatGroupRefreshData()
			self:SetChatList()
		end)
	end
end

M.OnGroupMemberChanged = function(self, _, data)
	if data and data.action then
		if data.action ~= "join" then
			slot3 = gFriendManager

			slot3:GetPlayerRealName(data.friendId, function (name)
				local fmt = LTConfig.FriendsConfig.JoinGroup

				self:TryInsertSeparatorMessage(gString.Format(fmt, name))
				self:ChatGroupRefreshData()
				self:SetChatList()
			end)
		elseif data.action ~= "remove" then
			self.SetData(self)
		end
	end
end

M.SetData = function(self)
	self.bindData.isEmpty = 2
	self.topChannelId = gSocialChatManager.currentTopChannel
	self.subChannelId = gSocialChatManager.currentSubChannelId

	gSocialChatManager:SaveMemoryJumpTo(self.topChannelId, self.subChannelId)

	local isPartyLiveChannel = gPartyManager:IsPartyLiveChannel(self.topChannelId, self.subChannelId)
	self.bindData.type = self.topChannelId ~= gSocialChatManager.ChatTopChannel.Group and 0 or 1

	self:SetDetailBtn()

	if isPartyLiveChannel then
		self.bindData.title = ""
	elseif self.topChannelId ~= gSocialChatManager.ChatTopChannel.Group then
		self.SetGroupData(self)
	elseif self.topChannelId ~= gSocialChatManager.ChatTopChannel.Friend then
		slot2 = gFriendManager

		slot2:GetPlayerRealName(self.subChannelId, function (name)
			self.bindData.title = name or ""
		end)
	elseif self.topChannelId ~= gSocialChatManager.ChatTopChannel.Channels or self.topChannelId ~= gSocialChatManager.ChatTopChannel.Team then
		local displayName = gSocialChatManager:GetChannelDisplayName(self.topChannelId, self.subChannelId)

		if displayName then
			self.bindData.title = displayName
		end
	elseif self.topChannelId ~= gSocialChatManager.ChatTopChannel.ThridSys_OC then
		local ocSessions = gOCMgr:SocialChat_GetSessions()

		if ocSessions and ocSessions[self.subChannelId] then
			self.bindData.title = ocSessions[self.subChannelId].name
		end
	end
end

M.SetDetailBtn = function(self)
	local isTeam = self.topChannelId ~= gSocialChatManager.ChatTopChannel.Team
	local isLink = self.topChannelId ~= gSocialChatManager.ChatTopChannel.Channels

	self.bindData.detailBtn:SetActive(not isTeam and not isLink)
end

M.SetGroupData = function(self)
	local data = gSocialChatGroupManager:GetGroupData(self.subChannelId)

	if not data then
		self.bindData.isEmpty = 0

		return
	end

	self.groupPlayerNum = gSocialChatGroupManager:GetGroupHeadCount(self.subChannelId)
	self.bindData.title = data.Name .. "(" .. self.groupPlayerNum .. "/ " .. LTConfig.FriendsConfig.ChatGroupMemberLimit .. ")"
end

M.InitChatListData = function(self)
	self.chatItemList = {}
	self.lastMsgTimestamp = nil

	gSocialChatManager:EnsureChannelMessages(self.topChannelId, self.subChannelId)

	self.currentChannelInfo = gSocialChatManager:GetChannel(self.topChannelId, self.subChannelId)

	if not self.currentChannelInfo and self.topChannelId ~= gSocialChatManager.ChatTopChannel.Team then
		self.currentChannelInfo = {
			messages = {},
			messageDict = {},
			topChannelId = self.topChannelId,
			subChannelId = self.subChannelId
		}
	end

	self.SetNormalBtnBar(self)
	self.RefreshAllMsg(self)
end

M.SetNormalBtnBar = function(self)
	local data = {
		topChannelId = self.topChannelId,
		subChannelId = self.subChannelId
	}

	self.socialChattingBar:SetData(data)
end

M.OnChatMessageChanged = function(self, _, data)
	if self.OnChatMessageChanged_CheckIsCurrentChannel(self, data) then
		local myPid = gPlayerManager.infoLogin.bindData.pid

		if data.msg and data.msg.pid and ulong.equals(data.msg.pid, myPid) then
			self.chatListIsAtBottom = true

			self.ClearUnreadMessageNotice(self)
		end

		if not self.chatListIsAtBottom then
			self.OnReceivedNewUnreadMessage(self)
		end

		self.ReceiveNewMessage(self, data.msg, data.skipScroll)
		self.SetChatList(self)
		self.SetInviteBtn(self)
	end
end

M.SetChatList = function(self)
	if #self.chatItemList < 0 then
		self.bindData.chatList:SetList(0)
		self:SetInviteBtn()

		return
	end

	if self.chatListIsAtBottom or self.CheckNeedScrollToBottom(self) then
		self.bindData.chatList:SetList(#self.chatItemList)
		self.bindData.chatList:ScrollToBottom(true)
	else
		self.bindData.chatList:SetDataCountNoRefresh(#self.chatItemList)
	end

	self.SetInviteBtn(self)
end

M.SetInviteBtn = function(self)
	if self.topChannelId ~= gSocialChatManager.ChatTopChannel.Group then
		local isGroupFull = LTConfig.FriendsConfig.ChatGroupMemberLimit > self.groupPlayerNum
		local shouldShowInvite = self.groupPlayerNum < 1 and #self.chatItemList ~= 0 and not isGroupFull
		self.bindData.isEmpty = shouldShowInvite and 1 or 0
	else
		self.bindData.isEmpty = 0
	end
end

M.ReceiveNewMessage = function(self, msg, skipScroll)
	if not gSocialChatManager:ShouldShowMessage(self.topChannelId, self.subChannelId, msg.timeStamp) then
		return
	end

	self.AddNewChatMessage(self, msg)
end

M.RefreshAllMsg = function(self)
	if not self.currentChannelInfo then
		return
	end

	local messages = self.currentChannelInfo.messages

	if not messages then
		return
	end

	for i = 1, #messages do
		local msg = messages[i]

		if gSocialChatManager:ShouldShowMessage(self.topChannelId, self.subChannelId, msg.timeStamp) then
			self.AddNewChatMessage(self, msg)
		end
	end

	self.SetChatList(self)
end

M.OnChatMessageChanged_CheckIsCurrentChannel = function(self, data)
	if self.topChannelId == data.topChannelId or not gSocialChatManager:IsSameSubChannel(self.subChannelId, data.subChannelId) or not data.msg then
		return false
	end

	return true
end

M.AddNewChatMessage = function(self, msg)
	local bubblePos = "Mid"

	if msg.templateMode ~= gSocialChatManager.ChatMsgTemplateMode.MyChat then
		bubblePos = "Right"
	elseif msg.templateMode ~= gSocialChatManager.ChatMsgTemplateMode.TheirChat then
		bubblePos = "Left"
	end

	if msg.mode ~= gSocialChatManager.MsgMode.Text and string.is_null_or_empty(msg.GetText(msg)) then
		return
	end

	if msg.msgType ~= gSocialChatManager.MessageType.Pin then
		return
	end

	self.AddViewItem(self, msg, bubblePos)
end

M.AddViewItem = function(self, msg, bubblePos)
	local msgType = msg.msgType
	local tIndex = gSocialChatManager.MsgType2Template[msgType][bubblePos] or gSocialChatManager.MsgType2Template[msgType].Mid

	if tIndex ~= nil then
		return
	end

	self.ConditionalInsertNewMessageNotifySeparator(self)
	self.TryInsertTimeSeparator(self, msg.timeStamp)

	local itemData = {
		msg = msg,
		tIndex = tIndex,
		msgType = msgType
	}

	self.AddItemToList(self, itemData)

	self.lastMsgTimestamp = msg.timeStamp
end

M.TryInsertTimeSeparator = function(self, currentTimestamp)
	if not currentTimestamp or currentTimestamp < 0 then
		return
	end

	local interval = self.TIME_SEPARATOR_INTERVAL or 1800000
	local tIndex = self.TIME_SEPARATOR_TINDEX or 6
	local needSeparator = false

	if self.lastMsgTimestamp ~= nil or self.lastMsgTimestamp < 0 then
		needSeparator = true
	else
		local timeDiff = currentTimestamp - self.lastMsgTimestamp

		if interval < timeDiff then
			needSeparator = true
		end
	end

	if needSeparator then
		self.TryInsertSeparatorMessage(self, self.FormatTimeSeparatorText(self, currentTimestamp), currentTimestamp)
	end
end

M.TryInsertSeparatorMessage = function(self, msg, timestamp)
	timestamp = timestamp or math.floor(gLuaDataManager.serverTime * 1000)
	local separatorData = {
		["*9\\xed~\\x9d\\xc41\\xb8.\\xf4\\xf3\\xf2{\\xe9"] = true,
		tIndex = self.TIME_SEPARATOR_TINDEX or 6,
		timestamp = timestamp,
		timeText = msg
	}

	table.insert(self.chatItemList, separatorData)
end

M.FormatTimeSeparatorText = function(self, timestamp)
	return gTimeUtils:FormatDayRelativeTime(math.floor(timestamp / 1000))
end

M.AddItemToList = function(self, itemData)
	for _, existingItem in ipairs(self.chatItemList) do
		if existingItem.msg and existingItem.msg.msgId ~= itemData.msg.msgId then
			return
		end
	end

	table.insert(self.chatItemList, itemData)
end

M.OnRenderChatItem = function(self, btn, index)
	self.chatListBtnRenderCache[index] = btn
	index = index + 1
	local item = self.chatItemList[index]

	if item.isTimeSeparator then
		self.ProcessTimeSeparator(self, item, btn)

		return
	end

	if item.tIndex ~= self.SocialChattingListItemTpl.NewMessageNotice and item.unreadMsgSeparatorHidden then
		btn.SetActive(btn, false)
	end

	if not item.msgType then
		return
	end

	local processMsgFunc = self.ProcessMsgFunc[item.msgType]
	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn) or nil

	if not store then
		return
	end

	self.chatListBtnStoreCache[index - 1] = store
	local partyLiveNpcInfo = item.msg.partyLiveNpcInfo

	if partyLiveNpcInfo then
		store.userInfo.pid = 0

		store.Commit(store, "avatarIconId", partyLiveNpcInfo.iconId, COMMIT_IMMEDIATELY)

		store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderHeadToolTips", partyLiveNpcInfo)
	else
		store.userInfo.pid = item.msg.pid
		store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderHeadToolTips", item.msg.pid)
	end

	store.time = self.FormatTimestampToChatTime(self, item.msg.timeStamp)

	processMsgFunc(self, item, store, btn, index)
end

M.ProcessTimeSeparator = function(self, item, btn)
	local label = btn.GetComponentInChildren(btn, typeof(SGUI.UBaseText))

	if label then
		label.text = item.timeText
	end
end

M.OnRenderHeadToolTips = function(self, data, btn, PopUp, _)
	self:HideChatItemTooltips()

	local store = gStoreManager:GetStoreGroup(PopUp.Store)

	if not store then
		return
	end

	if type(data) ~= "table" and data.npcId then
		store.SetRobotData(store, btn, data.iconId, data.nickName, data)

		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(data, btn, PopUp, _)
	gSocialPalyerTooltipManager:KeepBtnSelectedWhileTooltipOpened(btn)
end

M.FormatTimestampToChatTime = function(self, timestamp)
	local currentTime = gLuaDataManager.serverTime
	local currentYear = os.date("%Y", currentTime)
	local currentDayOfYear = os.date("%j", currentTime)
	local messageTime = math.floor(timestamp / 1000)
	local messageYear = os.date("%Y", messageTime)
	local messageDayOfYear = os.date("%j", messageTime)

	if messageYear == currentYear then
		return os.date("%Y-%m-%d %H:%M", messageTime)
	elseif messageDayOfYear == currentDayOfYear then
		return os.date("%m-%d %H:%M", messageTime)
	else
		return os.date("%H:%M", messageTime)
	end
end

M.OnGetChatItemTIndex = function(self, itemIndex)
	itemIndex = itemIndex + 1
	local chatItem = self.chatItemList[itemIndex]

	if chatItem then
		return chatItem.tIndex
	end

	return 0
end

M.GetSender = function(self, index)
	local chatItem = self.chatItemList[index]

	if chatItem ~= nil then
		return nil
	end

	local msg = chatItem.msg
	chatItem.sender = ChatSenderId.NewPlayer(msg.pid)

	return chatItem.sender
end

M.CheckIsLink = function(self)
	if self.topChannelId ~= gChatTopChannel.Channels and (self.subChannelId ~= UX.Game.MessageChannel.PrivateLink or self.subChannelId ~= UX.Game.MessageChannel.PublicLink or self.subChannelId ~= UX.Game.MessageChannel.MatchLink) then
		return true
	end

	return false
end

M.OnChatLastMessage = function(self, _, data)
	if self.OnChatMessageChanged_CheckIsCurrentChannel(self, data) then
		if data.msg and data.msg.timeStamp and not gSocialChatManager:ShouldShowMessage(self.topChannelId, self.subChannelId, data.msg.timeStamp) then
			return
		end

		self.AddNewChatMessage(self, data.msg)
		self.SetChatList(self)
		self.SetInviteBtn(self)
	end
end

M.OnRenderToolTips = function(self, btn, popup, index)
	local store = gStoreManager:GetStoreGroup("SocialChatSettingTooltipStore"):GetStoreByWidget(popup)

	if not store then
		return
	end

	self.ButtonEnum = gSocialChatManager.ButtonEnum
	self.visibleButtons = gSocialChatManager:GetToolTipsBtns()
	store.btnList.luaSimpleRenderItem = self:CreateAction("OnBtnRenderItem")

	store.btnList:SetSimpleList(#self.visibleButtons)
end

M.OnBtnRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.visibleButtons[index + 1]

	if store and data then
		store.title = data.title
		store.score = data.score
	end

	btn.luaClick = self.CreateActionWithArgs(self, "OnButtonClick", data.type)
end

M.OnButtonClick = function(self, buttonType)
	if buttonType ~= self.ButtonEnum.InviteFriend then
		self.InviteBtnOnClick(self)
	elseif buttonType ~= self.ButtonEnum.ManageMembers then
		gSocialChatManager:ChangeChattingPage(gSocialChatManager.chattingPageType.MemberManager)
	elseif buttonType ~= self.ButtonEnum.GroupSettings then
		local groupData = gSocialChatGroupManager:GetGroupData(self.subChannelId)

		if groupData then
			gPanelManager:CheckShow(gPanelId.SOCIAL_GROUP_SETTING_PANEL, groupData)
		end
	elseif buttonType ~= self.ButtonEnum.LeaveGroup then
		self.QuitChatGroup(self)
	elseif buttonType ~= self.ButtonEnum.DisbandGroup then
		self.DismissGroup(self)
	elseif buttonType ~= self.ButtonEnum.ReportGroup then
		-- Nothing
	elseif buttonType ~= self.ButtonEnum.PutTop then
		gSocialChatManager:SetPinned(self.topChannelId, self.subChannelId)
	elseif buttonType ~= self.ButtonEnum.CancelPutTop then
		gSocialChatManager:CancelPinned(self.topChannelId, self.subChannelId)
	elseif buttonType ~= self.ButtonEnum.DeleteChat then
		self.OnDeleteChat(self)
	elseif buttonType ~= self.ButtonEnum.MuteChat then
		gSocialChatManager:SetMuted(self.topChannelId, self.subChannelId)
	elseif buttonType ~= self.ButtonEnum.UnmuteChat then
		gSocialChatManager:CancelMuted(self.topChannelId, self.subChannelId)
	else
		print_error("Unknown button type: " .. tostring(buttonType))
	end

	self.bindData.detailBtn:CloseTooltip()
end

M.OnDeleteChat = function(self)
	gSocialChatManager:SetDeletedTimestamp(self.topChannelId, self.subChannelId)
	gSocialChatManager:ClearMemoryJumpToIfMatch(self.topChannelId, self.subChannelId)
	self:ClearCurrentChatData()
end

M.ClearCurrentChatData = function(self)
	self.chatItemList = {}
	local channel = gSocialChatManager:GetChannel(self.topChannelId, self.subChannelId)

	if channel then
		channel.messages = {}
		channel.messageDict = {}
		channel.lastMessage = nil
	end
end

M.QuitChatGroup = function(self)
	gSocialChatGroupManager:AskQuitChatGroup(self.subChannelId)

	self.bindData.type = 2
end

M.DismissGroup = function(self)
	gSocialChatGroupManager:AskDismissChatGroup(self.subChannelId)

	self.bindData.type = 2
end

M.InviteBtnOnClick = function(self)
	local friendList = gSocialChatGroupManager:GetAddFriendList(self.subChannelId)

	if table.isNilOrEmpty(friendList) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.GroupChatNoFriend)

		return
	end

	gStoreManager:GetStoreGroup("SocialChatTabPageStore"):ChangeInviteFriendPage()
end

M.SetInputReplyData = function(self, name, text, refId)
	self.socialChattingBar:SetReply(name, text, refId)
end

M.OnCtrlPlayerTipsBtnClick = function(self)
	gSocialChatManager:ClickCurrentSelectedHeadBtn()
end

M.GetMsgByMsgId = function(self, msgId)
	local id = gCS.LuaUtils.StringToUlong(msgId)

	for _, existingItem in ipairs(self.chatItemList) do
		if existingItem.msg and existingItem.msg.msgId ~= id then
			return existingItem.msg
		end
	end
end

M.ProcessTextMsg = function(self, itemData, store, btn, index)
	store.content = gClientUtils.RichTextToPlain(itemData.msg:GetText())

	store:Commit("content", store.content, COMMIT_IMMEDIATELY)

	store.showNameCtrl = 0

	if itemData.msg.partyLiveNpcInfo then
		store.name = itemData.msg.partyLiveNpcInfo.nickName
		store.showNameCtrl = 1
		store.showReferenceCtrl = 0
		store.replyAreaBtn.luaRenderTooltip = nil

		store.layout:ForceRebuildLayoutImmediate()

		return
	end

	if itemData.msg and itemData.msg.bubble then
		local bubbleDef = gSocialChatManager:GetBubbleDefById(itemData.msg.bubble or 0)

		if bubbleDef then
			local bubbleInfo = gSocialChatManager:GenerateChatBubbleInfo(bubbleDef)
			bubbleInfo = gSocialChatManager:ResolveChatBubbleInfo(bubbleInfo)

			if bubbleInfo and bubbleInfo.bg and bubbleInfo.bg == 0 then
				store.Commit(store, "bubble", bubbleInfo.bg)
			end
		end
	end

	local arg = {
		itemData = itemData,
		store = store,
		btn = store.replyAreaBtn,
		index = index
	}
	local refMsgId = itemData.msg.referenceMsgId

	if refMsgId then
		local isRef = refMsgId == "-"
		store.showReferenceCtrl = isRef and 1 or 0

		if isRef then
			local refMsg = self.GetMsgByMsgId(self, refMsgId)

			if refMsg then
				local chatterInfo = gSocialChatManager:GetChatterInfo(refMsg.pid)
				local senderName = chatterInfo and chatterInfo.name or ""
				local isLeft = refMsg.templateMode ~= gSocialChatManager.ChatMsgTemplateMode.TheirChat
				store.referenceText = senderName .. ": " .. refMsg.text
				store.refBtn.luaClick = self:CreateActionWithArgs("OnRefBtnClick", {
					refMsgId = refMsgId,
					isLeft = isLeft
				})
			else
				store.referenceText = LTConfig.TextScriptTextConfig.GetConfig(89901394).Text
			end
		end
	else
		store.showReferenceCtrl = 0
	end

	store.replyAreaBtn.luaRenderTooltip = self:CreateActionWithArgs("OnRenderChatItemToolTips", arg)

	store.layout:ForceRebuildLayoutImmediate()
end

M.ProcessLocationMsg = function(self, itemData, store, btn)
	store.location = gClientUtils.RichTextToPlain(itemData.msg:GetText())
	store.locBtn.luaClick = self:CreateActionWithArgs("OnClickLocationMsg", itemData.msg.location)
end

M.OnClickLocationMsg = function(self, location)
	local raidCfg = LTConfig.RaidConfig.GetConfig(location.raidid)

	if not raidCfg or not raidCfg.CountryId or not gMapSystem_Region:IsCountryUnlocked(raidCfg.CountryId) then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.LockedAreaLoact)

		return
	end

	gMapUtils:CheckRaidCanOpenMap({
		MapRaidId = location.raidid,
		autoPinWorldPos = Vector3.New(location.x, location.y, location.z)
	})
end

M.OnRenderChatItemToolTips = function(self, arg, _, popup, _)
	local store = gStoreManager:GetStoreGroup("SocialChatSettingTooltipStore"):GetStoreByWidget(popup)

	if not store then
		return
	end

	store.btnList.luaSimpleRenderItem = self:CreateActionWithArgs("OnChatItemToolTipsBtnRenderItem", arg)

	store.btnList:SetSimpleList(#self.itemTooltips)

	self.lastChatItemTooltipBtnIdx = arg.index - 1
end

M.OnChatItemToolTipsBtnRenderItem = function(self, arg, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.itemTooltips[index + 1]

	if store and data then
		store.title = data.title

		if data.icon then
			store.Commit(store, "icon", data.icon, COMMIT_FORCE)
		end
	end

	btn.luaClick = self.CreateActionWithArgs(self, "OnChatItemToolTipsButtonClick", {
		id = data.id,
		itemData = arg.itemData,
		btn = arg.btn
	})
end

M.OnChatItemToolTipsButtonClick = function(self, args)
	if args.id ~= LTConfig.FriendsChatItemConfig.Copy then
		local text = gClientUtils.RichTextToPlain(args.itemData.msg:GetText())

		gCS.LuaUtils.PasteText2Clipboard(text)
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.CopyIDComplete)
	elseif args.id ~= LTConfig.FriendsChatItemConfig.Reply then
		local chatterInfo = gSocialChatManager:GetChatterInfo(args.itemData.msg.pid)
		local senderName = chatterInfo and chatterInfo.name or ""

		self:SetInputReplyData(senderName, args.itemData.msg.text, args.itemData.msg.msgId)
	else
		print_error("社交聊天: 聊天记录Item点击: OnChatItemToolTipsButtonClick: 操作id不支持", args.id)
	end

	args.btn:CloseTooltip(true)
end

M.IsChatListAtBottom = function(self)
	local chatList = self.bindData.chatList

	if not chatList.needScrollable then
		return true
	end

	local pos = chatList.normalizedScrollPosition

	return pos.y > 0.01
end

M.OnChatListBeginDrag = function(self)
	self.HideChatItemTooltips(self)
end

M.OnChatListScrollEnd = function(self)
	local viewrange = self.bindData.chatList:GetViewRange()
	self.chatListIsAtBottom = self:IsChatListAtBottom()

	if self.chatListIsAtBottom then
		self.unreadMsgCnt = 0
		self.unreadMsgSeparatorIdx = nil

		self.RefreshUnreadMsgCnt(self)

		self.contentSize = {
			width = viewrange.z - viewrange.x,
			height = viewrange.w
		}
		self.viewSize = {
			width = viewrange.z - viewrange.x,
			height = viewrange.w - viewrange.y
		}
	end

	local currentScrollPosition = self.contentSize.height - viewrange.w
	local delta = currentScrollPosition / viewrange.w
	self.lastScrollDelta = delta
	local nowTime = gLuaDataManager.serverTime
	self.nextJumpToBottomTime = nowTime + LTConfig.FriendsConfig.ScrollProtectTime
end

M.OnRefBtnClick = function(self, data)
	local targetIndex = self.GetMsgIndexByMsgId(self, data.refMsgId)

	if targetIndex then
		local idx = targetIndex - 2

		if idx >= 0 then
			idx = 0
		end

		self.bindData.chatList:GoToIndex(idx, true)

		local store = self.chatListBtnStoreCache[targetIndex - 1]

		if store then
			local aniName = data.isLeft and "S_Vx_S_SocialChattingTextTemplate_L_highlight" or "S_Vx_S_SocialChattingTextTemplate_R_highlight"

			gCS.LuaUtils.PlayAnimationByName(store.ani, aniName)
		end
	end
end

M.GetMsgIndexByMsgId = function(self, msgId)
	local id = gCS.LuaUtils.StringToUlong(msgId)

	for i, existingItem in ipairs(self.chatItemList) do
		if existingItem.msg and existingItem.msg.msgId ~= id then
			return i
		end
	end

	return nil
end

M.ProcessEmojiMsg = function(self, itemData, store, btn)
	local emojiUrl = itemData.msg.emojiUrl or ""

	if store.rawImage and not string.is_null_or_empty(emojiUrl) then
		slot5 = gSocialFriendManager

		slot5:DownloadImage(emojiUrl, function (tex)
			if tex and store.rawImage then
				store.rawImage.texture = tex
			end
		end, nil, true)
	end
end

M.ProcessVoiceMsg = function(self, itemData, store, btn)
	store.content = math.max(math.ceil(itemData.msg.duration), 1)
	store.btn.luaClick = self:CreateActionWithArgs("OnClickAudioBubble", itemData)
	btn.redKey = gSocialChatManager:GetUnplayedVoiceMsgKey(itemData.msg.msgId)
	local myPid = gPlayerManager.infoLogin.bindData.pid
	local shouldShowVoiceRedDot = itemData.msg.pid and not ulong.equals(itemData.msg.pid, myPid) and not gSocialChatManager:IsVoicePlayed(itemData.msg.msgId)

	SGUI.RedDotMgr.LuaSetRedDot(shouldShowVoiceRedDot, btn.redKey)

	self.voiceStoreMap = self.voiceStoreMap or {}
	self.voiceStoreMap[tostring(itemData.msg.msgId)] = store

	if self.currentPlayingMsgId and ulong.equals(self.currentPlayingMsgId, itemData.msg.msgId) then
		store.audioStatus = 1

		self.PlayVoiceAnimation(self, itemData.msg.msgId)
	end
end

M.PlayVoiceAnimation = function(self, msgId)
	if not self.voiceStoreMap then
		return
	end

	local store = self.voiceStoreMap[tostring(msgId)]

	if store and store.ani then
		gCS.LuaUtils.PlayAnimationByName(store.ani, "vx_S_SocialChatVoiceMsgTemplateL_icon")
	end
end

M.StopVoiceAnimation = function(self, msgId)
	if not self.voiceStoreMap then
		return
	end

	local store = self.voiceStoreMap[tostring(msgId)]

	if store then
		store.audioStatus = 0

		if store.ani then
			gCS.LuaUtils.StopCurrentAnimation(store.ani)
			gClientUtils.ResetAnimation(store.ani, "vx_S_SocialChatVoiceMsgTemplateL_icon")
		end
	end
end

M.OnClickAudioBubble = function(self, itemData)
	if self.currentPlayingMsgId then
		self.StopVoicePlayAction(self)
	end

	for i, item in ipairs(self.chatItemList) do
		if item.msg and item.msg.msgId ~= itemData.msg.msgId then
			self.currentPlayingVoiceIndex = i

			break
		end
	end

	self.manualVoiceAutoPlayEnabled = true

	self.StartVoicePlayback(self, itemData.msg.msgId, itemData.msg.filePath)
end

M.OnAudioPlayFinish = function(self, _, msgId)
	if self.currentPlayingMsgId and self.currentPlayingMsgId == msgId then
		return
	end

	self.StopVoiceAnimation(self, msgId)

	self.currentPlayingMsgId = nil

	if not self.manualVoiceAutoPlayEnabled then
		self.currentPlayingVoiceIndex = nil
		self.pendingPlayMsgId = nil

		return
	end

	if not self.currentPlayingVoiceIndex then
		return
	end

	local nextIndex = self.FindNextUnplayedVoiceIndex(self, self.currentPlayingVoiceIndex)

	if nextIndex then
		local nextItem = self.chatItemList[nextIndex]
		self.currentPlayingVoiceIndex = nextIndex

		self.StartVoicePlayback(self, nextItem.msg.msgId, nextItem.msg.filePath)
	else
		self.currentPlayingVoiceIndex = nil
		self.pendingPlayMsgId = nil
		self.manualVoiceAutoPlayEnabled = false
	end
end

M.OnAudioDownloadSuccess = function(self, _, data)
	local msgId = data[0]
	local filePath = data[1]

	if self.pendingPlayMsgId and ulong.equals(self.pendingPlayMsgId, msgId) then
		self.currentPlayingMsgId = msgId

		gCS.IMManager:StartPlayAudioWithPath(filePath, msgId)
	end
end

M.FindNextUnplayedVoiceIndex = function(self, currentIndex)
	for i = currentIndex + 1, #self.chatItemList do
		local item = self.chatItemList[i]

		if item.msgType ~= gSocialChatManager.MessageType.Voice and item.msg.pid == gPlayerManager.infoLogin.bindData.pid and not gSocialChatManager:IsVoicePlayed(item.msg.msgId) then
			return i
		end
	end

	for i = 1, currentIndex - 1 do
		local item = self.chatItemList[i]

		if item.msgType ~= gSocialChatManager.MessageType.Voice and item.msg.pid == gPlayerManager.infoLogin.bindData.pid and not gSocialChatManager:IsVoicePlayed(item.msg.msgId) then
			return i
		end
	end

	return nil
end

M.StartVoicePlayback = function(self, msgId, filePath)
	if not msgId then
		return
	end

	self.currentPlayingMsgId = msgId
	self.pendingPlayMsgId = msgId

	gSocialChatManager:MarkVoicePlayed(msgId)

	local msgIdStr = tostring(msgId)
	local store = self.voiceStoreMap and self.voiceStoreMap[msgIdStr]

	if store then
		store.audioStatus = 1

		if store.ani then
			gCS.LuaUtils.PlayAnimationByName(store.ani, "vx_S_SocialChatVoiceMsgTemplateL_icon")
		end
	end

	gCS.IMManager:StartPlayAudio(msgId, filePath)
end

M.ProcessTipsMsg = function(self, itemData, _, btn)
	local label = btn.GetComponentInChildren(btn, typeof(SGUI.UBaseText))
	label.text = gClientUtils.RichTextToPlain(itemData.content)
end

M.ProcessTeamMsg = function(self, itemData, store, btn)
	local msgText = itemData.msg.teamData or ""
	local teamIdStr = string.match(msgText, "\"teamId\"%s*:%s*(%d+)")
	local numStr = string.match(msgText, "\"num\"%s*:%s*(%d+)")
	local teamNum = numStr and tonumber(numStr) or 1

	if store.btn then
		store.btn.luaClick = self.CreateActionWithArgs(self, "OnClickTeamBubble", teamIdStr)
	end

	self:RegisterVisibleTeamMsg(teamIdStr, store)

	self.teamInfoCache = self.teamInfoCache or {}
	local cachedData = self.teamInfoCache[teamIdStr]

	if cachedData == nil then
		self.RefreshTeamData(self, teamIdStr, store, cachedData)
	else
		store.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.TeamInviteCardTitle).Text, teamNum, gTeamManager.teamMaxMemberCount)
		store.desc = LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.TeamInviteCardDesc).Text
		store.status = gTeamManager.TEAM_STATUS.NONE

		if store.btn then
			store.btn.interactable = false
		end
	end

	self.AskQueryTeamInfo(self, teamIdStr, store)
end

M.ProcessCustomInviteMsg = function(self, itemData, store, btn, index)
	local msgText = itemData.msg.inviteData or "{}"
	local ok, info = pcall(json.decode, msgText)

	if not ok then
		return
	end

	local gameId = info.gameId or 0
	local inviteId = info.roomId or gameId
	local inviteData = self:GetOrCreateInviteData(gSocialChatManager.MessageType.CustomInvite, inviteId)
	inviteData.info = info
	store.btn.luaClick = self:CreateActionWithArgs("OnClickCustomInviteBubble", inviteData)
	inviteData.renderIdx = index - 1

	self:PollInviteData(inviteData, self:CreateAction("RefreshInviteDisplay"))
end

local TEAM_INFO_POLL_INTERVAL = 10

M.RegisterVisibleTeamMsg = function(self, teamId, store)
	if not teamId then
		return
	end

	self.visibleTeamMsgs = self.visibleTeamMsgs or {}
	self.visibleTeamMsgs[teamId] = self.visibleTeamMsgs[teamId] or {}
	local found = false

	for _, s in ipairs(self.visibleTeamMsgs[teamId]) do
		if s ~= store then
			found = true

			break
		end
	end

	if not found then
		table.insert(self.visibleTeamMsgs[teamId], store)
	end
end

M.StartTeamInfoPolling = function(self)
	if self.teamInfoPollTimer then
		return
	end

	self.teamInfoPollTimer = Timer.New(function ()
		self:PollTeamInfo()
	end, TEAM_INFO_POLL_INTERVAL, -1)

	self.teamInfoPollTimer:Start()
end

M.StopTeamInfoPolling = function(self)
	if self.teamInfoPollTimer then
		self.teamInfoPollTimer:Stop()

		self.teamInfoPollTimer = nil
	end

	self.visibleTeamMsgs = nil
end

M.PollTeamInfo = function(self)
	if not self.visibleTeamMsgs then
		return
	end

	self.teamInfoCache = {}
	self.teamInfoCacheTime = {}

	for teamId, stores in pairs(self.visibleTeamMsgs) do
		for _, store in ipairs(stores) do
			self.AskQueryTeamInfo(self, teamId, store)
		end
	end
end

local TEAM_INFO_CACHE_EXPIRE_TIME = 30000

M.AskQueryTeamInfo = function(self, teamIdStr, store)
	if not teamIdStr then
		return
	end

	self.teamInfoCache = self.teamInfoCache or {}
	self.teamInfoCacheTime = self.teamInfoCacheTime or {}
	self.teamInfoRequesting = self.teamInfoRequesting or {}
	local cacheTime = self.teamInfoCacheTime[teamIdStr]
	local now = gCS.TimeManager:GetClientMilliSeconds()

	if self.teamInfoCache[teamIdStr] == nil and cacheTime and now - cacheTime >= TEAM_INFO_CACHE_EXPIRE_TIME then
		self.RefreshTeamData(self, teamIdStr, store, self.teamInfoCache[teamIdStr])

		return
	end

	if self.teamInfoRequesting[teamIdStr] then
		table.insert(self.teamInfoRequesting[teamIdStr], store)

		return
	end

	self.teamInfoRequesting[teamIdStr] = {
		store
	}
	local teamIdUlong = gCS.LuaUtils.StringToUlong(teamIdStr)
	slot6 = gClientToGameDelegate

	slot6:AskQueryTeamInfo(teamIdUlong).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			self.teamInfoCache[teamIdStr] = data or false
			self.teamInfoCacheTime[teamIdStr] = gCS.TimeManager:GetClientMilliSeconds()
		end

		local waitingStores = self.teamInfoRequesting[teamIdStr] or {}
		self.teamInfoRequesting[teamIdStr] = nil

		if err == LTConfig.MessageConfig.Ok then
			return
		end

		for _, waitStore in ipairs(waitingStores) do
			self:RefreshTeamData(teamIdStr, waitStore, data)
		end
	end
end

M.RefreshTeamData = function(self, teamIdStr, store, data)
	if not data then
		store.num = LTConfig.TextScriptTextConfig.GetConfig(89901373).Text
		store.status = gTeamManager.TEAM_STATUS.DISSOLUTION
		store.btn.interactable = false

		return
	end

	local num = #data.Members or 0
	store.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.TeamInviteCardTitle).Text, num, gTeamManager.teamMaxMemberCount)
	store.desc = LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.TeamInviteCardDesc).Text
	local myTeamIdStr = gTeamManager.teamId and ulong.tostring(gTeamManager.teamId) or nil

	if teamIdStr ~= myTeamIdStr then
		store.status = gTeamManager.TEAM_STATUS.JOINED
		store.btn.interactable = false
	elseif gTeamManager.teamMaxMemberCount < num then
		store.status = gTeamManager.TEAM_STATUS.FULL
		store.btn.interactable = false
	else
		store.status = gTeamManager.TEAM_STATUS.NONE
		store.btn.interactable = true
	end
end

M.RefreshAllTeamDataByForce = function(self)
	self.inviteDataSet = self.inviteDataSet or {}

	for invitetype, inviteDatas in pairs(self.inviteDataSet) do
		for inviteId, v in pairs(inviteDatas) do
			local inviteData = v

			if inviteData.pollEnabled then
				inviteData.nextPollTime = 0
			end
		end
	end

	self.PollTeamInfo(self)
end

M.UpdateInviteData = function(self)
	self.inviteDataSet = self.inviteDataSet or {}
	local nowTime = gLuaDataManager.serverTime

	for invitetype, inviteDatas in pairs(self.inviteDataSet) do
		for inviteId, v in pairs(inviteDatas) do
			local inviteData = v

			if inviteData.pollEnabled and inviteData.nextPollTime < nowTime then
				self.PollInviteData(self, inviteData, function ()
					if inviteData.renderIdx and self.bindData.chatList.VirtualStartIndex < inviteData.renderIdx and inviteData.renderIdx < self.bindData.chatList.VirtualEndIndex then
						self:RefreshInviteDisplay(inviteData)
					else
						self.chatListBtnRenderCache[inviteData.renderIdx] = nil
						self.chatListBtnStoreCache[inviteData.renderIdx] = nil
					end
				end)

				inviteData.nextPollTime = nowTime + self.InviteDataRefreshInterval
			end
		end
	end
end

M.GetOrCreateInviteData = function(self, type, id)
	self.inviteDataSet = self.inviteDataSet or {}

	if not self.inviteDataSet[type] then
		self.inviteDataSet[type] = {}
	end

	if not self.inviteDataSet[type][id] then
		self.inviteDataSet[type][id] = {
			["\\x8f;,3]\\x93@\\xdb;\\xaf\\xbd"] = true,
			["QBbmK8 "] = 0,
			["Y\\xa7\\xb6\\xa3\\xb3"] = "",
			["~'nX"] = "",
			type = type,
			id = id,
			status = gTeamManager.TEAM_STATUS.NONE,
			nextPollTime = gLuaDataManager.serverTime
		}
	end

	return self.inviteDataSet[type][id]
end

M.PollInviteData = function(self, inviteData, cb)
	if inviteData.type ~= gSocialChatManager.MessageType.CustomInvite then
		self.PollCustomInviteData(self, inviteData.info, function (data)
			if data then
				inviteData.title = data.title
				inviteData.desc = data.desc
				inviteData.status = data.status
			end

			cb(inviteData)
		end)
	end
end

M.GetCustomInviteType = function(self, info)
	local partyCfg = LTConfig.PartyConfig.GetConfig(info.gameId)

	if partyCfg and partyCfg.OnlineParty ~= true then
		return CustomInviteType.Party, partyCfg
	end

	local gameplayCfg = LTConfig.LinkMultiPlayerConfig.GetConfig(info.gameId)

	if gameplayCfg then
		return CustomInviteType.Gameplay, gameplayCfg
	end
end

M.PollCustomInviteData = function(self, info, cb)
	local inviteType, cfg = self.GetCustomInviteType(self, info)

	if inviteType ~= CustomInviteType.Party then
		self.PollPartyCustomInviteData(self, info, cfg, cb)

		return
	end

	if inviteType ~= CustomInviteType.Gameplay then
		self.PollGameplayCustomInviteData(self, info, cfg, cb)

		return
	end

	cb()
end

M.PollPartyCustomInviteData = function(self, info, partyCfg, cb)
	local num = info.memberCount or 1
	local numMax = info.maxMembers or partyCfg.MaxNum
	local data = {
		title = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.GameInviteCardTitle).Text, num, numMax),
		desc = info.roomName or "",
		status = gTeamManager.TEAM_STATUS.NONE
	}

	cb(data)
end

M.PollGameplayCustomInviteData = function(self, info, gameplayCfg, cb)
	local num = info.memberCount or 1
	local numMax = info.maxMembers or gameplayCfg.PlayerNum and gameplayCfg.PlayerNum[#gameplayCfg.PlayerNum] or 4
	local data = {
		title = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(LTConfig.TextScriptTextConfig.GameInviteCardTitle).Text, num, numMax),
		desc = info.roomName or gameplayCfg.Name or "",
		status = gTeamManager.TEAM_STATUS.NONE
	}

	cb(data)
end

M.RefreshInviteDisplay = function(self, inviteData)
	local store = self.chatListBtnStoreCache[inviteData.renderIdx]

	if not store then
		return
	end

	store.num = inviteData.title

	if not inviteData.info then
		store.status = gTeamManager.TEAM_STATUS.DISSOLUTION
		store.btn.interactable = false
	else
		store.status = inviteData.status
		store.desc = inviteData.desc
		store.btn.interactable = inviteData.status ~= gTeamManager.TEAM_STATUS.NONE
	end
end

M.OnClickTeamBubble = function(self, teamIdStr)
	local teamId = gCS.LuaUtils.StringToUlong(teamIdStr)

	if not gTeamManager:IsInTeam() and not gLinkManager:CheckInLinkMode() then
		slot3 = gDisplayMessageMgr

		slot3:ShowMessage(LTConfig.MessageConfig.SoloModeAcceptLinkInviteConfirm, function ()
			gTeamManager:AskApplyToTeam(teamId)
		end)

		return
	end

	gTeamManager:AskApplyToTeam(teamId)
end

M.OnClickCustomInviteBubble = function(self, inviteData)
	local info = inviteData and inviteData.info
	local inviteType = info and self:GetCustomInviteType(info)

	if inviteType ~= CustomInviteType.Party then
		self.OnClickPartyCustomInviteBubble(self, info)
	elseif inviteType ~= CustomInviteType.Gameplay then
		self.OnClickGameplayCustomInviteBubble(self, info)
	end
end

M.OnClickPartyCustomInviteBubble = function(self, info)
	local roomId = info.roomId

	if not roomId then
		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskJoinPartyRoom(gCS.LuaUtils.StringToUlong(tostring(roomId)), nil).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)
		end
	end
end

M.OnClickGameplayCustomInviteBubble = function(self, info)
	local roomId = info.roomId

	if not roomId then
		return
	end

	local roomIdUlong = gCS.LuaUtils.StringToUlong(tostring(roomId))

	local doJoin = function()
		gLinkManager:RespondPrepareRoomInvite(roomIdUlong, true, function ()
		end)
	end

	if not gLinkManager:CheckInLinkMode() then
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SoloModeAcceptLinkInviteConfirm, doJoin)

		return
	end

	doJoin()
end

M.OnReceivedNewUnreadMessage = function(self)
	if not self.TryEnableNewMessageNotice(self) then
		return
	end

	self.unreadMsgCnt = self.unreadMsgCnt + 1

	self.RefreshUnreadMsgCnt(self)
end

M.ClearUnreadMessageNotice = function(self)
	self.unreadMsgCnt = 0

	self.RefreshUnreadMsgCnt(self)
end

M.CheckNeedScrollToBottom = function(self)
	if not self.lastScrollDelta then
		return
	end

	local needJumpToBottom = self.lastScrollDelta + 1 <= LTConfig.FriendsConfig.NewMessageForceScrollThreshold
	local nowTime = gLuaDataManager.serverTime

	if needJumpToBottom and self.nextJumpToBottomTime <= 0 then
		needJumpToBottom = self.nextJumpToBottomTime > nowTime
	end

	return needJumpToBottom
end

M.TryEnableNewMessageNotice = function(self)
	if self.IsNewMessageNoticeEnabled(self) then
		return true
	end

	local UnreadMsgNoticeCD = LTConfig.FriendsConfig.NewMessageNoticeCD
	local nowTime = gLuaDataManager.serverTime

	if self.nextShowUnreadMsgTime <= 0 and nowTime >= self.nextShowUnreadMsgTime then
		self.unreadMsgNoticeEnabled = false

		return false
	end

	self.nextShowUnreadMsgTime = nowTime + UnreadMsgNoticeCD
	self.unreadMsgNoticeEnabled = true

	return true
end

M.IsNewMessageNoticeEnabled = function(self)
	return not self.chatListIsAtBottom and self.unreadMsgNoticeEnabled
end

M.RefreshUnreadMsgCnt = function(self)
	self.bindData.showNewMessageCtrl = BOOL2CTL[self.unreadMsgCnt >= 0]

	if self.unreadMsgCnt <= 0 then
		local unreadMsgCnt = tostring(self.unreadMsgCnt)

		if self.unreadMsgCnt <= 99 then
			unreadMsgCnt = "99+"
		end

		self.bindData.newMessageText.text = string.format(LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.ChatNewMessageNum).Text, tostring(unreadMsgCnt))
	end
end

M.ConditionalInsertNewMessageNotifySeparator = function(self)
	local currIdx = #self.chatItemList + 1

	if self.IsNewMessageNoticeEnabled(self) and (not self.unreadMsgSeparatorIdx or currIdx ~= self.unreadMsgSeparatorIdx) then
		if self.oldUnreadMsgSeparatorIdx then
			local oldUnreadMsgSeparatorRenderIdx = self.oldUnreadMsgSeparatorIdx - 1

			if self.bindData.chatList.VirtualStartIndex < oldUnreadMsgSeparatorRenderIdx and oldUnreadMsgSeparatorRenderIdx < self.bindData.chatList.VirtualEndIndex and self.chatListBtnRenderCache[oldUnreadMsgSeparatorRenderIdx] then
				local chatItem = self.chatItemList[self.oldUnreadMsgSeparatorIdx]

				if chatItem.tIndex == self.SocialChattingListItemTpl.NewMessageNotice then
					print_error("社交聊天: 找不到对应的新消息分割条！！！！！")
				else
					self.chatListBtnRenderCache[oldUnreadMsgSeparatorRenderIdx]:SetActive(false)

					chatItem.unreadMsgSeparatorHidden = true
				end
			else
				table.remove(self.chatItemList, self.oldUnreadMsgSeparatorIdx)
			end
		end

		local separatorData = {
			tIndex = self.SocialChattingListItemTpl.NewMessageNotice
		}

		table.insert(self.chatItemList, separatorData)

		self.unreadMsgSeparatorIdx = #self.chatItemList
		self.oldUnreadMsgSeparatorIdx = self.unreadMsgSeparatorIdx
	end
end

M.OnClickGoToFirstUnreadMsg = function(self)
	if self.unreadMsgSeparatorIdx then
		local idx = self.unreadMsgSeparatorIdx + 1 + LTConfig.FriendsConfig.NewMessageJumpTo

		if self.bindData.chatList.rowCount >= idx then
			self.bindData.chatList:ScrollToBottom(false)
		else
			self.bindData.chatList:GoToIndex(idx, true)
		end
	end
end

M.ResetUnreadMsgStates = function(self)
	self.unreadMsgNoticeEnabled = false
	self.nextShowUnreadMsgTime = 0
	self.nextJumpToBottomTime = 0
	self.chatListIsAtBottom = true
	self.unreadMsgCnt = 0
	self.unreadMsgSeparatorIdx = nil
	self.lastShowUnreadMsgNoticeTimestamp = nil
	self.oldUnreadMsgSeparatorIdx = nil
	self.lastScrollDelta = 0
end

M.SetChatListNoFreshListAfterSizeChange = function(self)
	self.bindData.chatList.noFreshListAfterSizeChange = true
end

M.ScrollToBottom = function(self)
	self.bindData.chatList:ScrollToBottom(true)
end

M.BackBtnOnClick = function(self)
	self.HideChatItemTooltips(self)
end

M.OnChatAreaNavIn = function(self)
	self.navInChatArea = true
end

M.OnChatAreaNavOut = function(self)
	self.navInChatArea = false
end

M.SetChatListStatus = function(self, status)
	self.bindData.status = status
end
