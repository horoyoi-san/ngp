local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local ImageAvatar = LTConfig.ImageAvatarConfig
local Chat = L50.Chat
local ChatTabs = Chat.ChatTabs.Instance
C_ChatManager = DefClass("C_ChatManager", C_ChatManager)
local M = C_ChatManager

function M:ctor()
	self.currentNpcChatType = ChatType.Normal
	self.cs = Chat.ChatManager.Instance
	self.ChatMsgTemplateMode = Chat.ChatMsgTemplateMode
	self.MsgMode = Chat.ChatMsgMode
	self.ChatHistoryState = Chat.ChatHistoryState
	self.ChatMessageSource = Chat.ChatMessageSource
	self.HeadIconType = {
		System = 2,
		Channel = 3,
		NPCGroup = 4
	}
	self.CHAT_HISTORY_AES_KEY = nil
	self.CHAT_HISTORY_AES_VECTOR = nil
	self.currentTopChannel = nil
	self.currentSubChannelId = nil
	self.LastTopChannel = nil
	self.LastSubChannel = nil
	self.playerInfoOver = false
	self.friendIsLoadOver = false
	self.isSceneLoading = true
	self.loadFriendHistory = false
	self.lastId = ulong.zero
	self.waitSceneLoadCallBack = {}
	self.groupInviteList = {}
	self.checkUncompletedDialogNextTime = 0
	self.PZHeadInfoDict = {}

	gChatGroupManager:OnInit()
end

function M:OpenChatPanel(topChannelId, subChannelId, npcChatType, gamePlayId, _, chatCfg)
	local params = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		npcChatType = npcChatType,
		npcInviteGamePlay = gamePlayId,
		chatCfg = chatCfg
	}

	gChatUtils.OpenChatPanel(params)
end

function M:SetHeadIcon(headRoot, pid, pzHeadInfo, systemIcon, npcGroupIcons, groupLimit)
	local isMe = pid and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) or false

	local function showSystemIcon(icon)
		headRoot.headType = self.HeadIconType.System
		headRoot.lihuiIcon = icon
	end

	local function showNpcGroupIcons(icons)
		headRoot.headType = self.HeadIconType.NPCGroup
		headRoot.groupLength = #icons

		for i, v in ipairs(icons) do
			if groupLimit == nil and headRoot["groupMember" .. i] or groupLimit and i <= groupLimit then
				headRoot["groupMember" .. i] = v
			else
				headRoot.groupExcess = headRoot.groupLength - i + 2

				break
			end
		end
	end

	local function showPZHeadInfoHead(headInfo)
		local type, path = gImageManager:GetHeadIconByHeadIconInfo(headInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)

		if cfg == nil then
			print_warn(iconId .. " AvatarImage Dont Exist")

			return
		end

		showSystemIcon(cfg.ImageId)
	end

	if npcGroupIcons then
		showNpcGroupIcons(npcGroupIcons)
	elseif systemIcon then
		showSystemIcon(systemIcon)
	elseif pzHeadInfo then
		showPZHeadInfoHead(pzHeadInfo)
	elseif pid then
		if isMe then
			showPZHeadInfoHead(gPlayerManager.infoLogin.bindData.infoPzHeadInfo)
		elseif self.PZHeadInfoDict[pid] then
			showPZHeadInfoHead(self.PZHeadInfoDict[pid])
		else
			gRpcUtils:SafeQueueAsk(gClientToAvatarDelegate, "GetSimplePlayerInfoByPidList", nil, {
				canCombine = true
			}, {
				pid
			}).Callback = function (err, datas)
				if err == LTConfig.MessageConfig.Ok and datas[1] then
					local headInfo = datas[1].PzHeadInfo
					self.PZHeadInfoDict[pid] = headInfo

					showPZHeadInfoHead(headInfo)
				end
			end
		end
	end
end

function M:GetImageAvatarConfigByPidWithCallback(pid, callback)
	local isMe = pid and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) or false

	local function getPZHeadInfoHead(headInfo)
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(headInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)

		callback(true, cfg)
	end

	if pid == nil then
		callback(false)

		return
	end

	if isMe then
		getPZHeadInfoHead(gPlayerManager.infoLogin.bindData.infoPzHeadInfo)
	elseif self.PZHeadInfoDict[pid] then
		getPZHeadInfoHead(self.PZHeadInfoDict[pid])
	else
		local function GetSimplePlayerInfoCallback(data)
			local headInfo = data.PzHeadInfo
			self.PZHeadInfoDict[pid] = headInfo

			getPZHeadInfoHead(headInfo)
		end

		gFriendManager:GetSimplePlayerInfo(pid, GetSimplePlayerInfoCallback)
	end
end

function M:OnSyncNpcChatLeaveGameplay(npcId, gameplay)
	local gamePlayType = LTConfig.NPCChatGamePlayTypeConfig
	local multiNpcTidList = gChatManager.groupInviteList

	Timer.New(function ()
		gClientUtils.CloseMainPhonePanel()

		if gameplay == gamePlayType.Restaurant or gameplay == gamePlayType.MaidHouse or gameplay == gamePlayType.FastFood or gameplay == gamePlayType.MaidTea then
			gMessageManager:SendMessage(gEventConstants.RESTAURANT_INVITE_NPC, {
				npcId = npcId,
				gameplayId = gameplay
			})
		elseif gameplay == gamePlayType.Cinema then
			gMessageManager:SendMessage(gEventConstants.CINEMA_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.Firework then
			gMessageManager:SendMessage(gEventConstants.FIREWORK_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.ClawMachine then
			gMessageManager:SendMessage(gEventConstants.CLAWMACHINE_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.LiveHouse then
			gMessageManager:SendMessage(gEventConstants.LIVEHOUSE_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.Mahjong then
			gMaJiangManager:AskInviteNpcFromChat(multiNpcTidList)
		elseif gameplay == gamePlayType.FerriswheelCity or gameplay == gamePlayType.FerriswheelPark then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnFerrisInviteNpc, {
				isSkip = false,
				npcId = npcId
			})
		elseif gameplay == gamePlayType.Sunbath then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnSunbathInviteNpc, {
				isSkip = false,
				npcId = npcId
			})
		elseif gameplay == gamePlayType.Dart then
			gMessageManager:SendMessage(gEventConstants.DO_INVITE_NPC_DART_GAME, npcId)
		end
	end, LTConfig.NPCChatConfig.InviteWaitTime):Start()
end

function M:HaveNormalTypeChat(topChannelId, subChannelId)
	local subChannel = self:GetChannel(topChannelId, subChannelId)

	return subChannel and subChannel.messages.Count > 0
end

function M:GetChatAesVector(pid)
	local str = ulong.tostring(pid)
	local length = string.len(str)

	if length > 16 then
		return string.sub(str, length - 16 + 1)
	elseif length == 16 then
		return str
	end

	return string.rep("0", 16 - length) .. str
end

function M:IsVisibleToCurrentNpc(chatId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg == nil then
		return false
	end

	local currentNpcId = self:GetCurrentNpcId()

	if currentNpcId == nil then
		return false
	end

	if cfg.ChatType == ChatType.Dialog then
		return true
	end

	if cfg.ChatGroup > 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation == 0 or currentNpcId == group.AsNpcCultivation or table.find(group.GroupMember, currentNpcId) ~= nil
	end

	return cfg.AsNpcCultivation == 0 or cfg.AsNpcCultivation == currentNpcId
end

function M:FilterStoryMessages(messages)
	local result = {}

	for _, msg in ipairs(messages) do
		if self:IsVisibleToCurrentNpc(msg.npcChatId) then
			table.insert(result, msg)
		end
	end

	return result
end

function M:IsChatControlledByCurrentNpc(chatId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg == nil then
		return false
	end

	if cfg.ChatType == ChatType.Dialog then
		return true
	end

	local currentNpcId = self:GetCurrentNpcId() or 0

	if cfg.ChatGroup > 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation == 0 or currentNpcId == group.AsNpcCultivation
	end

	local asNpcCultivation = cfg.AsNpcCultivation

	return asNpcCultivation == 0 or asNpcCultivation == currentNpcId
end

function M:OnInit()
	self.CHAT_HISTORY_AES_KEY = gCS.IMManager.CHAT_HISTORY_AES_KEY

	gMessageManager:AddMessageListener(gEventConstants.UPDATE_FRIEND_INFO, self:CreateAction("LoadChatChannelFriendList"))
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self:CreateAction("OnLoadingFinished"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction("OnPanelClose"))
	self:LoadClientChannel()

	self.friendIsLoadOver = false
	self.playerInfoOver = false
end

function M:OnBeforeSwitchScene(switchType)
	self.isSceneLoading = true

	self:UpdateCurrentChannel(nil)

	if switchType == gSwitchSceneType.KickToLogin then
		self.currentTopChannel = nil
		self.currentSubChannelId = nil
		self.playerInfoOver = false
		self.friendIsLoadOver = false
		self.loadFriendHistory = false
		self.lastId = 0
		self.isSceneLoading = true
		self.waitSceneLoadCallBack = {}
		self.groupInviteList = {}
		self.checkUncompletedDialogNextTime = 0

		self:LoadClientChannel()
		gChatGroupManager:ClearData()
	elseif gSwitchSceneType.Reconnect < switchType then
		self.isSceneLoading = true
	end
end

function M:OnLoadingFinished()
	self.isSceneLoading = false

	while #self.waitSceneLoadCallBack > 0 do
		local cb = table.remove(self.waitSceneLoadCallBack)

		cb()
	end
end

function M:OnPanelClose(eventId, panelId)
	if gLuaDataManager.gameStage == gGFConstant.GameStage.Loading then
		return
	end

	self.checkPanelCloseCo = coroutine.stop(self.checkPanelCloseCo)
	self.checkPanelCloseCo = coroutine.start(function ()
		coroutine.step()
	end)
end

function M:TranslateSubChannelType(topChannelId, subChannelId)
	if subChannelId == nil then
		return nil
	end

	if topChannelId == gChatTopChannel.Friend or topChannelId == gChatTopChannel.Group then
		return ulong.check(subChannelId) and subChannelId or ulong.new(subChannelId, 0)
	elseif ulong.check(subChannelId) then
		local low, _ = ulong.tonum2(subChannelId)

		return low
	else
		return subChannelId
	end
end

function M:ResetMessageOfChannelInfo(topChannelId, subChannelId)
	self.cs:ResetMessageOfChannelInfo(topChannelId, subChannelId)
end

function M:GetChannel(topChannelId, subChannel)
	return self.cs:GetChannel(topChannelId, subChannel)
end

function M:GetOrAddSubChannel(topChannelId, subChannelId)
	return self.cs:GetOrAddSubChannel(topChannelId, subChannelId)
end

function M:LoadClientChannel()
	self.cs:LoadClientChannel()
end

function M:GetNewestUnreadChannel()
	return self.cs:GetNewestUnreadChannelLua(nil, nil)
end

function M:CreateChatMessage()
	return C_ChatMessage.New()
end

function M:LoadLocalMessages(topChannelId, subChannelId)
	self.cs:LoadLocalMessages(topChannelId, subChannelId)
end

function M:LoadChatChannelPlayerInfo()
	self.CHAT_HISTORY_AES_VECTOR = self:GetChatAesVector(gPlayerManager.infoLogin.bindData.pid)

	if self.playerInfoOver then
		return
	end

	self.playerInfoOver = true

	self:LoadNpcChatMsgList()
end

function M:LoadChatChannelFriendList(_, data)
	self.friendIsLoadOver = true

	if self.playerInfoOver then
		local friends = data

		if #friends == 0 then
			return
		end

		local friendChannel = self:GetChannel(gChatTopChannel.Friend)

		if friendChannel == nil then
			print_error("好友频道没了！！")

			return
		end

		self:LoadFriendChannel(friends)

		if not self.loadFriendHistory then
			self:LoadFriendsLocalHistory(friends)
		end
	end
end

function M:LoadNpcChatMsgList()
	self.cs:LoadNpcChatMsgList()

	if not table.contains(self.waitSceneLoadCallBack, gDialogMainChatManager.CheckUncompletedDialog) and self.isSceneLoading then
		table.insert(self.waitSceneLoadCallBack, gDialogMainChatManager.CheckUncompletedDialog)
	end
end

function M:ReLoadNpcChatMsg(templateId, isGroup)
	self.cs:ReLoadNpcChatMsg(templateId, isGroup)
end

function M:LoadFriendChannel(friends)
	self.cs:LoadFriendChannel(gFriendManager.cs.ToUlongList(friends))
end

function M:UpdateChatter(pid, sex, level, name, onlineState, pzHeadInfo, timeStamp)
	self.cs:UpdateChatter(pid, sex, level, name, onlineState, pzHeadInfo, timeStamp)
end

function M:GetChatterInfo(pid)
	return self.cs:GetChatterInfo(pid)
end

function M:LoadFriendsLocalHistory(friends)
	self.loadFriendHistory = true

	for _, pid in pairs(friends) do
		self:LoadLocalMessages(gChatTopChannel.Friend, pid)
	end

	self:RequestFriendLatestMessages()
end

function M:RequestFriendLatestMessages()
	self.cs:RequestFriendLatestMessages()
end

function M:RequestStableList(topChannelId, subChannelId)
	self.cs:RequestStableList(topChannelId, subChannelId)
end

function M:TrySendChat(inputValue, topChannelId, subChannelId)
	self.cs:TrySendChat(inputValue, topChannelId, subChannelId)
end

function M:InitChatMsg(chatInfo)
	local msgMode = chatInfo.msgMode or self.MsgMode.Text
	local msg = nil

	if msgMode == self.MsgMode.Audio then
		msg = self:CreateAudioChatMessage(chatInfo)
	elseif msgMode == self.MsgMode.Team then
		msg = self:CreateTeamChatMessage(chatInfo)
		msg.teamId = chatInfo.teamId
		msg.num = chatInfo.teamNum
	else
		msg = self:CreateTextChatMessage(chatInfo)
	end

	msg.pid = chatInfo.senderId
	msg.timeStamp = chatInfo.timeStamp > 0 and chatInfo.timeStamp or gCS.TimeManager:GetClientMilliSeconds()
	msg.topChannelId = chatInfo.topChannelId
	msg.subChannelId = chatInfo.subChannelId
	msg.npcTemplateId = chatInfo.npcTemplateId
	msg.npcChatId = chatInfo.npcChatId
	msg.npcNextChatId = chatInfo.npcNextChatId

	if ulong.equals(msg.pid, gPlayerManager.infoLogin.bindData.pid) then
		msg.templateMode = self.ChatMsgTemplateMode.MyChat
	else
		msg.templateMode = self.ChatMsgTemplateMode.TheirChat
	end

	msg.msgId = ulong.Greater(chatInfo.msgId, 0) and chatInfo.msgId or self:NextId()

	return msg
end

function M:InitNpcChatMessage(chatItem)
	return C_NpcChatMessage.New(chatItem)
end

function M:NextId()
	self.lastId = ulong.add(self.lastId, 1)

	return self.lastId
end

function M:CreateTextChatMessage(chatInfo)
	local msg = self:CreateChatMessage()
	msg.mode = self.MsgMode.Text
	msg.text = chatInfo.str
	msg.mode = chatInfo.msgMode

	return msg
end

function M:CreateAudioChatMessage(chatInfo)
	local msg = self:CreateChatMessage()
	msg.mode = self.MsgMode.Audio
	msg.msgType = gChatConst.MessageType.Voice
	msg.filePath = chatInfo.str
	msg.duration = chatInfo.audioInfo.AudioDuration
	msg.content = chatInfo.audioInfo.AudioText
	msg.text = LTConfig.TextScriptTextConfig.GetConfig(89900734).Text

	return msg
end

function M:CreateTeamChatMessage(chatInfo)
	local msg = self:CreateChatMessage()
	msg.msgType = gChatConst.MessageType.Team
	msg.mode = chatInfo.msgMode

	return msg
end

function M:GetTotalUnreadCount()
	return self.cs:GetTotalUnreadCount()
end

function M:ResetUnreadCount(topChannelId, subChannelId, force)
	self.cs:ResetUnreadCount(topChannelId, subChannelId, force)
end

function M:IsAuxiliaryChannel(topChannelId, auxiliaryChannelId)
	local topChannelInfo = ChatTabs.topChannelInfo:ToTable()

	if topChannelId == nil or auxiliaryChannelId == nil or topChannelInfo[topChannelId] == nil then
		return false
	end

	return topChannelInfo[topChannelId].auxiliaryChannel and array.contains(topChannelInfo[topChannelId].auxiliaryChannel:ToTable(), auxiliaryChannelId)
end

function M:UpdateCurrentChannel(topChannelId, subChannelId)
	subChannelId = self:TranslateSubChannelType(topChannelId, subChannelId)

	if topChannelId and subChannelId == nil then
		local topChannelInfo = ChatTabs.topChannelInfo:ToTable()

		if topChannelInfo[topChannelId] == nil then
			return
		end

		if topChannelInfo[topChannelId].redirectChannel ~= 0 then
			topChannelId = topChannelInfo[topChannelId].redirectChannel
		end
	end

	local top, sub = self:GetCurrentChannel()

	if top == topChannelId and sub == subChannelId then
		return
	end

	if topChannelId == nil then
		self.currentTopChannel = nil
		self.currentSubChannelId = nil
	elseif self:GetChannel(topChannelId, subChannelId) then
		self.currentTopChannel = topChannelId
		self.currentSubChannelId = subChannelId

		self:RecordCurrentChannel()
	else
		print_error("UpdateCurrentChannel Error 没有该频道，不能更新当前频道", topChannelId, subChannelId)

		return
	end

	gMessageManager:SendMessage(gEventConstants.CHAT_CHANNEL_CHANGED, {
		topChannelId = topChannelId,
		subChannelId = subChannelId
	})
end

function M:RecordCurrentChannel()
	self.LastTopChannel = self.currentTopChannel
	self.LastSubChannel = self.currentSubChannelId
end

function M:GetRecordChannel()
	return self.LastTopChannel, self.LastSubChannels
end

function M:IsCurrentChannel(topChannelId, subChannelId)
	subChannelId = self:TranslateSubChannelType(topChannelId, subChannelId)

	return topChannelId == self.currentTopChannel and subChannelId == self.currentSubChannelId
end

function M:GetCurrentChannel()
	return self.currentTopChannel, self.currentSubChannelId
end

function M:ClearInviteChat(sub, isGroup)
	self.cs:ClearInviteChat(sub, isGroup)
end

function M:CheckAudioPermissionSucc()
	return
end

function M:GetCurrentNpcId()
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self:GetCurSpiritId())
	local npcId = spiritCfg and spiritCfg.NpcCultivationRelatedId

	if npcId == LTConfig.NpcCultivationConfig.DefaultMale or npcId == LTConfig.NpcCultivationConfig.DefaultFemale then
		return L50.Chat.ChatManager.PlayerSelf
	end

	return npcId
end

function M:MakeLuaTable(args)
	if args == nil or args.Length % 2 ~= 0 then
		print_error("MakeLuaTable bad args!")

		return nil
	end

	args = args:ToTable()
	local result = {}

	for i = 1, #args, 2 do
		result[args[i]] = args[i + 1]
	end

	return result
end

function M:GetCurSpiritId()
	return gSpiritManager:GetCurFirstSpiritTid()
end

function M:PlayPhoneAni(param)
	local param1 = param.param1
	local param2 = param.param2
	local animName = param.param2
	local OnAnimStopCallback = param.OnAnimStopCallback

	if param1 == gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Chat and gMainPhoneUtils.GetSelectedIndex() == param1 and param2 == gNpcChatConst.TabShowType.NpcChatting then
		local store = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

		store:PlayAnimation(animName, {
			OnAnimStopCallback = OnAnimStopCallback
		})
	end
end

function M:GetLinkChannel()
	if gLinkManager.LinkMode == UX.Game.LinkMode.Private then
		return UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Public then
		return UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Match then
		return UX.Game.MessageChannel.MatchLink
	end

	return 0
end

gChatManager = gChatManager or C_ChatManager.new()
