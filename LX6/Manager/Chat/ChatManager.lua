-- Original chunk: @Lua\LuaFiles\LX6\Manager\Chat\ChatManager.lua
-- Decompiled from: 00291_ChatManager.lua_7f35dcef8084.luajit

local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local ImageAvatar = LTConfig.ImageNewAvatarConfig
local Chat = L50.Chat
local ChatTabs = Chat.ChatTabs.Instance
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
C_ChatManager = DefClass("C_ChatManager", C_ChatManager)
local M = C_ChatManager

M.ctor = function(self)
	self.currentNpcChatType = ChatType.Normal
	self.cs = Chat.ChatManager.Instance
	self.ChatMsgTemplateMode = Chat.ChatMsgTemplateMode
	self.MsgMode = Chat.ChatMsgMode
	self.ChatHistoryState = Chat.ChatHistoryState
	self.ChatMessageSource = Chat.ChatMessageSource
	self.HeadIconType = {
		["/Q\\x82\\x9a\\x86L"] = 2,
		["\\xfa\\xd3!\\xfd"] = 3,
		["\\x85\\x81&\\x8cx1\\xeb#"] = 4
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

M.OpenChatPanel = function(self, topChannelId, subChannelId, npcChatType, gamePlayId, _, chatCfg)
	local params = {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		npcChatType = npcChatType,
		npcInviteGamePlay = gamePlayId,
		chatCfg = chatCfg
	}

	gChatUtils.OpenChatPanel(params)
end

M.SetHeadIcon = function(self, headRoot, pid, pzHeadInfo, systemIcon, npcGroupIcons, groupLimit)
	local isMe = pid and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) or false

	local showSystemIcon = function(icon)
		headRoot.headType = self.HeadIconType.System
		headRoot.lihuiIcon = icon
	end

	local showNpcGroupIcons = function(icons)
		headRoot.headType = self.HeadIconType.NPCGroup
		headRoot.groupLength = #icons

		for i, v in ipairs(icons) do
			if groupLimit ~= nil and headRoot["groupMember" .. i] or groupLimit and i < groupLimit then
				headRoot["groupMember" .. i] = v
			else
				headRoot.groupExcess = headRoot.groupLength - i + 2

				break
			end
		end
	end

	local showPZHeadInfoHead = function(headInfo)
		local type, path = gImageManager:GetHeadIconByHeadIconInfo(headInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)

		if cfg ~= nil then
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
				["P[\\xc0\\x9e\\x8b\\xba\r\\xc7\\xed"] = true
			}, {
				pid
			}).Callback = function (err, datas)
				if err ~= LTConfig.MessageConfig.Ok and datas[1] then
					local headInfo = datas[1].PzHeadInfo
					self.PZHeadInfoDict[pid] = headInfo

					showPZHeadInfoHead(headInfo)
				end
			end
		end
	end
end

M.GetImageAvatarConfigByPidWithCallback = function(self, pid, callback)
	local isMe = pid and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) or false

	local getPZHeadInfoHead = function(headInfo)
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(headInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)

		callback(true, cfg)
	end

	if pid ~= nil then
		callback(false)

		return
	end

	if isMe then
		getPZHeadInfoHead(gPlayerManager.infoLogin.bindData.infoPzHeadInfo)
	elseif self.PZHeadInfoDict[pid] then
		getPZHeadInfoHead(self.PZHeadInfoDict[pid])
	else
		local GetSimplePlayerInfoCallback = function(data)
			local headInfo = data.PzHeadInfo
			self.PZHeadInfoDict[pid] = headInfo

			getPZHeadInfoHead(headInfo)
		end

		gFriendManager:GetSimplePlayerInfo(pid, GetSimplePlayerInfoCallback)
	end
end

M.OnSyncNpcChatLeaveGameplay = function(self, npcId, gameplay)
	local gamePlayType = GamePlayTypeConfig
	local multiNpcTidList = gChatManager.groupInviteList

	Timer.New(function ()
		gClientUtils.CloseMainPhonePanel()

		if gameplay ~= gamePlayType.Restaurant or gameplay ~= gamePlayType.MaidHouse or gameplay ~= gamePlayType.FastFood or gameplay ~= gamePlayType.MaidTea then
			gMessageManager:SendMessage(gEventConstants.RESTAURANT_INVITE_NPC, {
				npcId = npcId,
				gameplayId = gameplay
			})
		elseif gameplay ~= gamePlayType.Cinema then
			gMessageManager:SendMessage(gEventConstants.CINEMA_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.Firework then
			gMessageManager:SendMessage(gEventConstants.FIREWORK_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.ClawMachine then
			gMessageManager:SendMessage(gEventConstants.CLAWMACHINE_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.LiveHouse then
			gMessageManager:SendMessage(gEventConstants.LIVEHOUSE_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.KTV then
			gMessageManager:SendMessage(gEventConstants.KTV_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.Mahjong or gameplay ~= gamePlayType.ReachMahjong then
			gMaJiangManager:AskInviteNpcFromChat(multiNpcTidList, gameplay)
		elseif gameplay ~= gamePlayType.FerriswheelCity or gameplay ~= gamePlayType.FerriswheelPark then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnFerrisInviteNpc, {
				["[\\xa2\\x85\\x8aQ"] = false,
				npcId = npcId
			})
			L50.L50App.Scene.FerrisMgr:OnInviteSuccess(npcId, false)
		elseif gameplay ~= gamePlayType.Sunbath then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnSunbathInviteNpc, {
				["[\\xa2\\x85\\x8aQ"] = false,
				npcId = npcId
			})
		elseif gameplay ~= gamePlayType.Dart then
			gMessageManager:SendMessage(gEventConstants.DO_INVITE_NPC_DART_GAME, npcId)
		end
	end, LTConfig.NPCChatConfig.InviteWaitTime):Start()
end

M.HaveNormalTypeChat = function(self, topChannelId, subChannelId)
	local subChannel = self:GetChannel(topChannelId, subChannelId)

	return subChannel and subChannel.messages.Count >= 0
end

M.GetChatAesVector = function(self, pid)
	local str = ulong.tostring(pid)
	local length = string.len(str)

	if length <= 16 then
		return string.sub(str, length - 16 + 1)
	elseif length ~= 16 then
		return str
	end

	return string.rep("0", 16 - length) .. str
end

M.IsVisibleToCurrentNpc = function(self, chatId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg ~= nil then
		return false
	end

	local currentNpcId = self:GetCurrentNpcId()

	if currentNpcId ~= nil then
		return false
	end

	if cfg.ChatType ~= ChatType.Dialog then
		return true
	end

	if cfg.ChatGroup <= 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation ~= 0 or currentNpcId ~= group.AsNpcCultivation or table.find(group.GroupMember, currentNpcId) == nil
	end

	return cfg.AsNpcCultivation ~= 0 or cfg.AsNpcCultivation ~= currentNpcId
end

M.FilterStoryMessages = function(self, messages)
	local result = {}

	for _, msg in ipairs(messages) do
		if self:IsVisibleToCurrentNpc(msg.npcChatId) then
			table.insert(result, msg)
		end
	end

	return result
end

M.IsChatControlledByCurrentNpc = function(self, chatId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg ~= nil then
		return false
	end

	if cfg.ChatType ~= ChatType.Dialog then
		return true
	end

	local currentNpcId = self:GetCurrentNpcId() or 0

	if cfg.ChatGroup <= 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation ~= 0 or currentNpcId ~= group.AsNpcCultivation
	end

	local asNpcCultivation = cfg.AsNpcCultivation

	return asNpcCultivation ~= 0 or asNpcCultivation ~= currentNpcId
end

M.OnInit = function(self)
	self.CHAT_HISTORY_AES_KEY = gCS.IMManager.CHAT_HISTORY_AES_KEY

	gMessageManager:AddMessageListener(gEventConstants.UPDATE_FRIEND_INFO, self:CreateAction("LoadChatChannelFriendList"))
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self:CreateAction("OnLoadingFinished"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction("OnPanelClose"))
	self:LoadClientChannel()

	self.friendIsLoadOver = false
	self.playerInfoOver = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.isSceneLoading = true

	self:UpdateCurrentChannel(nil)

	if switchType ~= gSwitchSceneType.KickToLogin then
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
	elseif gSwitchSceneType.Reconnect >= switchType then
		self.isSceneLoading = true
	end
end

M.OnLoadingFinished = function(self)
	self.isSceneLoading = false

	while #self.waitSceneLoadCallBack <= 0 do
		local cb = table.remove(self.waitSceneLoadCallBack)

		cb()
	end
end

M.OnPanelClose = function(self, eventId, panelId)
	if gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
		return
	end

	self.checkPanelCloseCo = coroutine.stop(self.checkPanelCloseCo)
	self.checkPanelCloseCo = coroutine.start(function ()
		coroutine.step()
	end)
end

M.TranslateSubChannelType = function(self, topChannelId, subChannelId)
	if subChannelId ~= nil then
		return nil
	end

	if topChannelId ~= gChatTopChannel.Friend or topChannelId ~= gChatTopChannel.Group then
		return ulong.check(subChannelId) and subChannelId or ulong.new(subChannelId, 0)
	elseif ulong.check(subChannelId) then
		local low, _ = ulong.tonum2(subChannelId)

		return low
	else
		return subChannelId
	end
end

M.ResetMessageOfChannelInfo = function(self, topChannelId, subChannelId)
	self.cs:ResetMessageOfChannelInfo(topChannelId, subChannelId)
end

M.GetChannel = function(self, topChannelId, subChannel)
	return self.cs:GetChannel(topChannelId, subChannel)
end

M.GetOrAddSubChannel = function(self, topChannelId, subChannelId)
	return self.cs:GetOrAddSubChannel(topChannelId, subChannelId)
end

M.LoadClientChannel = function(self)
	self.cs:LoadClientChannel()
end

M.GetNewestUnreadChannel = function(self)
	return self.cs:GetNewestUnreadChannelLua(nil, )
end

M.CreateChatMessage = function(self)
	return C_ChatMessage.New()
end

M.LoadLocalMessages = function(self, topChannelId, subChannelId)
	self.cs:LoadLocalMessages(topChannelId, subChannelId)
end

M.LoadChatChannelPlayerInfo = function(self)
	self.CHAT_HISTORY_AES_VECTOR = self:GetChatAesVector(gPlayerManager.infoLogin.bindData.pid)

	if self.playerInfoOver then
		return
	end

	self.playerInfoOver = true

	self:LoadNpcChatMsgList()
end

M.LoadChatChannelFriendList = function(self, _, data)
	self.friendIsLoadOver = true

	if self.playerInfoOver then
		local friends = data

		if #friends ~= 0 then
			return
		end

		local friendChannel = self:GetChannel(gChatTopChannel.Friend)

		if friendChannel ~= nil then
			print_error("好友频道没了！！")

			return
		end

		self:LoadFriendChannel(friends)

		if not self.loadFriendHistory then
			self:LoadFriendsLocalHistory(friends)
		end
	end
end

M.LoadNpcChatMsgList = function(self)
	self.cs:LoadNpcChatMsgList()

	if not table.contains(self.waitSceneLoadCallBack, gDialogMainChatManager.CheckUncompletedDialog) and self.isSceneLoading then
		table.insert(self.waitSceneLoadCallBack, gDialogMainChatManager.CheckUncompletedDialog)
	end
end

M.ReLoadNpcChatMsg = function(self, templateId, isGroup)
	self.cs:ReLoadNpcChatMsg(templateId, isGroup)
end

M.LoadFriendChannel = function(self, friends)
	self.cs:LoadFriendChannel(gFriendManager.cs.ToUlongList(friends))
end

M.UpdateChatter = function(self, pid, sex, level, name, onlineState, pzHeadInfo, timeStamp)
	self.cs:UpdateChatter(pid, sex, level, name, onlineState, pzHeadInfo, timeStamp)
end

M.GetChatterInfo = function(self, pid)
	return self.cs:GetChatterInfo(pid)
end

M.LoadFriendsLocalHistory = function(self, friends)
	self.loadFriendHistory = true

	for _, pid in pairs(friends) do
		self:LoadLocalMessages(gChatTopChannel.Friend, pid)
	end

	self:RequestFriendLatestMessages()
end

M.RequestFriendLatestMessages = function(self)
	self.cs:RequestFriendLatestMessages()
end

M.RequestStableList = function(self, topChannelId, subChannelId)
	self.cs:RequestStableList(topChannelId, subChannelId)
end

M.TrySendChat = function(self, inputValue, topChannelId, subChannelId)
	self.cs:TrySendChat(inputValue, topChannelId, subChannelId)
end

M.InitChatMsg = function(self, chatInfo)
	local msgMode = chatInfo.msgMode or self.MsgMode.Text
	local msg = nil

	if msgMode ~= self.MsgMode.Audio then
		msg = self:CreateAudioChatMessage(chatInfo)
	elseif msgMode ~= self.MsgMode.Team then
		msg = self:CreateTeamChatMessage(chatInfo)
		msg.teamId = chatInfo.teamId
		msg.num = chatInfo.teamNum
	else
		msg = self:CreateTextChatMessage(chatInfo)
	end

	msg.pid = chatInfo.senderId
	msg.timeStamp = chatInfo.timeStamp <= 0 and chatInfo.timeStamp or gCS.TimeManager:GetClientMilliSeconds()
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

M.InitNpcChatMessage = function(self, chatItem)
	return C_NpcChatMessage.New(chatItem)
end

M.NextId = function(self)
	self.lastId = ulong.add(self.lastId, 1)

	return self.lastId
end

M.CreateTextChatMessage = function(self, chatInfo)
	local msg = self:CreateChatMessage()
	msg.mode = self.MsgMode.Text
	msg.text = chatInfo.str
	msg.mode = chatInfo.msgMode

	return msg
end

M.CreateAudioChatMessage = function(self, chatInfo)
	local msg = self:CreateChatMessage()
	msg.mode = self.MsgMode.Audio
	msg.msgType = gChatConst.MessageType.Voice
	msg.filePath = chatInfo.str
	msg.duration = chatInfo.audioInfo.AudioDuration
	msg.content = chatInfo.audioInfo.AudioText
	msg.text = LTConfig.TextScriptTextConfig.GetConfig(89900734).Text

	return msg
end

M.CreateTeamChatMessage = function(self, chatInfo)
	local msg = self:CreateChatMessage()
	msg.msgType = gChatConst.MessageType.Team
	msg.mode = chatInfo.msgMode

	return msg
end

M.GetTotalUnreadCount = function(self)
	return self.cs:GetTotalUnreadCount()
end

M.ResetUnreadCount = function(self, topChannelId, subChannelId, force)
	self.cs:ResetUnreadCount(topChannelId, subChannelId, force)
end

M.IsAuxiliaryChannel = function(self, topChannelId, auxiliaryChannelId)
	local topChannelInfo = ChatTabs.topChannelInfo:ToTable()

	if topChannelId ~= nil or auxiliaryChannelId ~= nil or topChannelInfo[topChannelId] ~= nil then
		return false
	end

	return topChannelInfo[topChannelId].auxiliaryChannel and array.contains(topChannelInfo[topChannelId].auxiliaryChannel:ToTable(), auxiliaryChannelId)
end

M.UpdateCurrentChannel = function(self, topChannelId, subChannelId)
	subChannelId = self:TranslateSubChannelType(topChannelId, subChannelId)

	if topChannelId and subChannelId ~= nil then
		local topChannelInfo = ChatTabs.topChannelInfo:ToTable()

		if topChannelInfo[topChannelId] ~= nil then
			return
		end

		if topChannelInfo[topChannelId].redirectChannel == 0 then
			topChannelId = topChannelInfo[topChannelId].redirectChannel
		end
	end

	local top, sub = self:GetCurrentChannel()

	if top ~= topChannelId and sub ~= subChannelId then
		return
	end

	if topChannelId ~= nil then
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

M.RecordCurrentChannel = function(self)
	self.LastTopChannel = self.currentTopChannel
	self.LastSubChannel = self.currentSubChannelId
end

M.GetRecordChannel = function(self)
	return self.LastTopChannel, self.LastSubChannels
end

M.IsCurrentChannel = function(self, topChannelId, subChannelId)
	subChannelId = self:TranslateSubChannelType(topChannelId, subChannelId)

	return topChannelId ~= self.currentTopChannel and subChannelId ~= self.currentSubChannelId
end

M.GetCurrentChannel = function(self)
	return self.currentTopChannel, self.currentSubChannelId
end

M.ClearInviteChat = function(self, sub, isGroup)
	self.cs:ClearInviteChat(sub, isGroup)
end

M.CheckAudioPermissionSucc = function(self)
end

M.GetCurrentNpcId = function(self)
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self:GetCurSpiritId())
	local npcId = spiritCfg and spiritCfg.NpcCultivationRelatedId

	if npcId ~= LTConfig.NpcCultivationConfig.DefaultMale or npcId ~= LTConfig.NpcCultivationConfig.DefaultFemale then
		return L50.Chat.ChatManager.PlayerSelf
	end

	return npcId
end

M.MakeLuaTable = function(self, args)
	if args ~= nil or args.Length % 2 == 0 then
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

M.GetCurSpiritId = function(self)
	return gSpiritManager:GetCurFirstSpiritTid()
end

M.PlayPhoneAni = function(self, param)
	local param1 = param.param1
	local param2 = param.param2
	local animName = param.param2
	local OnAnimStopCallback = param.OnAnimStopCallback

	if param1 ~= gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Chat and gMainPhoneUtils.GetSelectedIndex() ~= param1 and param2 ~= gNpcChatConst.TabShowType.NpcChatting then
		local store = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

		store:PlayAnimation(animName, {
			OnAnimStopCallback = OnAnimStopCallback
		})
	end
end

M.GetLinkChannel = function(self)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Private then
		return UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Public then
		return UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		return UX.Game.MessageChannel.MatchLink
	end

	return 0
end

gChatManager = gChatManager or C_ChatManager.new()
