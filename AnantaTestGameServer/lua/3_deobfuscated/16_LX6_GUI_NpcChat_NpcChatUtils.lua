local NpcChatUtils = {}
local this = NpcChatUtils
local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local TaskEventState = UX.Game.TaskEventState
NpcChatUtils.GmUtils = require("LX6/GUI/NpcChat/NpcChatUtils_GmUtils")

function NpcChatUtils.OpenChatPanel(params)
	gNpcChatNpcsPhoneManager:Reset()

	params = this._OpenChatPanelParamsPreprocess(params)
	params.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Message

	if params.forceShow and this.IsNeedShowFrontFullscreen(params) then
		if not gPanelManager:IsPanelShowing(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL) then
			local panelIdList = gClientUtils.GetMainPhonePanelIdList()

			for _, panelId in ipairs(panelIdList) do
				if panelIdList ~= gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL and gPanelManager:IsPanelShowing(panelId) then
					gPanelManager:Close(panelId)
				end
			end
		end

		gPanelManager:CheckShow(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL, params)
	else
		gMainPhoneUtils.ShowPhoneAppContent(params)
	end
end

function NpcChatUtils.MakeInviteNpcView(npcTemplateId, npcChatInfo, npcCardInfo)
	local view = {
		subChannelId = npcTemplateId,
		name = npcChatInfo:GetName(),
		showFavor = true,
		isOnline = true,
		favorLevel = this.GetFavorLevel(npcCardInfo.Favor),
		favorViewInfo = this.GetFavorViewInfo(npcTemplateId)
	}

	gNpcChatManager:SetHeadIcon(view, nil, nil, npcChatInfo:GetIcon())

	return view
end

function NpcChatUtils.GetFavorLevel(favor)
	for i = 1, #LTConfig.NpcCultivationConfig.FavorLevel do
		if favor < LTConfig.NpcCultivationConfig.FavorLevel[i] then
			return i - 1
		end
	end

	return #LTConfig.NpcCultivationConfig.FavorLevel
end

function NpcChatUtils.IsNextMessage(lastMsg, thisMsg)
	if not lastMsg or not thisMsg then
		return false
	end

	if lastMsg.npcNextChatId > 0 then
		return thisMsg.npcChatId == lastMsg.npcNextChatId
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(lastMsg.npcChatId)

	if cfg == nil or table.isNilOrEmpty(cfg.NextMessage) then
		return false
	end

	if cfg.ChatGroup > 0 then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		if not groupCfg then
			return false
		end

		if not table.isNilOrEmpty(groupCfg.GroupMember) then
			return table.contains(cfg.NextMessage, thisMsg.npcChatId)
		end

		local members = gNpcChatManager.groupInviteList

		if table.isNilOrEmpty(members) then
			return false
		end

		for _, chatId in pairs(cfg.NextMessage) do
			if chatId == thisMsg.npcChatId then
				local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

				if chatCfg and table.contains(members, chatCfg.NPCid) then
					return true
				end
			end
		end

		return false
	end

	return table.contains(cfg.NextMessage, thisMsg.npcChatId)
end

function NpcChatUtils.HasNextMessage(msg)
	if msg.npcNextChatId > 0 then
		return true
	end

	local cfg = LTConfig.NPCChatConfig.GetConfig(msg.npcChatId)

	if cfg == nil or table.isNilOrEmpty(cfg.NextMessage) then
		return false
	end

	if cfg.ChatGroup > 0 then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		if not groupCfg then
			return false
		end

		if not table.isNilOrEmpty(groupCfg.GroupMember) then
			return true
		end

		local members = gNpcChatManager.groupInviteList

		if table.isNilOrEmpty(members) then
			return false
		end

		for _, chatId in pairs(cfg.NextMessage) do
			local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

			if chatCfg and table.contains(members, chatCfg.NPCid) then
				return true
			end
		end

		return false
	end

	return true
end

function NpcChatUtils.IsNextNpcMessage(msg)
	if msg.npcNextChatId > 0 then
		return true
	end

	local lastChatCfg = msg.cfg

	if lastChatCfg and lastChatCfg.NextMessage and #lastChatCfg.NextMessage == 1 then
		local nextChatCfg = LTConfig.NPCChatConfig.GetConfig(lastChatCfg.NextMessage[1])

		if not nextChatCfg.IsPlayerMessage then
			return true
		end
	end

	return false
end

function NpcChatUtils.CheckIsValidChatCfgOnShowNpcNewChat(cfg)
	if cfg == nil then
		return false
	end

	local isGroup = cfg.ChatGroup > 0
	local id = isGroup and cfg.ChatGroup or cfg.NPCid

	if id == nil or id == 0 then
		print_error("NPCChat表NPCid或ChatGroup字段空了！！！！id：", cfg.Id)

		return false
	end

	if not isGroup then
		local info = gDialogMainChatManager:GetNpcChatInfo(cfg.NPCid)

		if info == nil then
			return false
		end
	end

	return true
end

function NpcChatUtils.GetMySignature()
	local roleInfo = gHunLunManager.roleInfo or {}

	if table.isNilOrEmpty(roleInfo) then
		print_error("@liulijun04 ChatUtils.GetMySignature 未初始化 gHunLunManager.roleInfo")
	end

	return string.is_null_or_empty(roleInfo.sign) and LTConfig.NPCChatConfig.DefaultPlayerSignature or roleInfo.sign
end

function NpcChatUtils.GetPlayerSignature(pid, callback, default)
	local Mgr = require("LX6/GUI/HunLun/V3XingZheFileMgr")
	local targetId = ulong.tonum2(pid)

	Mgr.Init()
	Mgr.RequestBaseInfo(targetId, function (data)
		local signature = data and data.signature

		if string.is_null_or_empty(signature) then
			callback(default or "")
		else
			callback(signature)
		end
	end)
end

function NpcChatUtils.SetSignature(topChannel, subChannel, setter)
	if topChannel == gNpcChatConst.ChatTopChannel.Self then
		setter(LTConfig.NPCChatConfig.DefaultPlayerSignature)
		this.GetPlayerSignature(subChannel, setter, LTConfig.NPCChatConfig.DefaultPlayerSignature)
	elseif topChannel == gNpcChatConst.ChatTopChannel.Npc then
		local npcInfo = gDialogMainChatManager:GetNpcChatInfo(subChannel)
		local signature = npcInfo:GetSignature()

		if string.is_null_or_empty(signature) then
			setter(LTConfig.NPCChatConfig.DefaultPlayerSignature)
		else
			setter(signature)
		end
	end
end

function NpcChatUtils.SetHeader(headerWidget, showMyInfo, topChannel, subChannel)
	local headerStore = gStoreManager:GetStoreGroup("NpcChatHeaderStore"):GetStoreByWidget(headerWidget)

	if subChannel == gNpcChatConst.PlayerSelfIndex then
		showMyInfo = true
	end

	if showMyInfo then
		local info = gPlayerManager.infoLogin.bindData
		headerStore.name = info.name
		local senderId = NpcChatSenderId.NewPlayer(info.pid)

		gNpcChatAvatarUtils:SetSingleAvatar(senderId, headerStore.avatar)

		return
	end

	headerStore.signature = ""
	headerStore.showTypeCtrl = 2

	gNpcChatAvatarUtils:SetChannelAvatar(topChannel, subChannel, headerStore.avatar)

	if topChannel == gNpcChatConst.ChatTopChannel.Npc then
		local npcInfo = gDialogMainChatManager:GetNpcChatInfo(subChannel)

		if not npcInfo then
			print_warn("npcInfo is nil")

			return
		end

		headerStore.name = npcInfo:GetName()
	elseif topChannel == gNpcChatConst.ChatTopChannel.NpcGroup then
		local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannel)
		headerStore.name = gClientUtils.RichTextToPlain(cfg.GroupName)
	else
		print_error("ChatUtils.SetHeader: invalid topChannel", topChannel)
	end
end

function NpcChatUtils.IsNeedShowFrontFullscreen(params)
	if gMainPhoneUtils.IsFakePhoneExist() then
		return false
	end

	if params.npcInviteGamePlay then
		return true
	end

	if params.chatCfg and params.chatCfg.Id == 84013630 then
		return true
	end

	return false
end

function NpcChatUtils.CheckParam(params, key, value, ...)
	if params[key] and params[key] ~= value then
		print_error(gString.FormatString("OpenChatPanel: params.{0} not match value! params.{0} = {1}, value = {2}", key, params[key], value), ...)
	end
end

function NpcChatUtils._OpenChatPanelParamsPreprocess(params)
	params = params or {}
	local top = params.topChannelId
	local sub = params.subChannelId
	local chatCfg = params.chatCfg or LTConfig.NPCChatConfig.GetConfig(params.chatCfgId)
	gNpcChatManager.rollToCfgId = params.rollToCfg and chatCfg and chatCfg.Id or nil

	if chatCfg then
		if chatCfg.ChatGroup == 0 then
			top = gNpcChatConst.ChatTopChannel.Npc
			sub = chatCfg.NPCid
		else
			top = gNpcChatConst.ChatTopChannel.NpcGroup
			sub = chatCfg.ChatGroup
		end

		params.npcChatType = chatCfg.ChatType

		NpcChatUtils.CheckParam(params, "npcChatType", chatCfg.ChatType, chatCfg.Id)
	else
		top = top or gNpcChatManager:GetNewestUnreadChannel()

		if top == nil then
			top, sub = gNpcChatManager:GetRecordChannel()
		end

		top = top or gNpcChatConst.ChatTopChannel.Npc

		if sub and gNpcChatManager:GetChannel(top, sub) == nil then
			print_error("OpenChatPanel: sub channel not exist", "top", top, "sub", sub)

			sub = nil
		end
	end

	if top or params.npcInviteGamePlay then
		local npcChatType = params.npcChatType or LTConfig.NPCChatConfig.ChatTypeType.Normal

		if params.npcInviteGamePlay then
			npcChatType = LTConfig.NPCChatConfig.ChatTypeType.Invite
		end

		gNpcChatManager.currentNpcChatType = npcChatType
		gNpcChatManager.FakeChatAutoPlay = false
	end

	if top and sub then
		local npcChatMsg = this.GetCurrentNpcChannelLastMsg(top, sub)
		local toCheckIsFakePhone = false

		if chatCfg == nil then
			if npcChatMsg then
				chatCfg = npcChatMsg.cfg
				params.chatCfg = chatCfg
			else
				toCheckIsFakePhone = true
			end
		end

		local npcsPhoneCfg = params.npcsPhoneCfg or this._TryGetNpcsPhoneCfg(chatCfg)

		if npcsPhoneCfg then
			gNpcChatNpcsPhoneManager:Init(npcsPhoneCfg, chatCfg, params)
			gNpcChatManager:GetOrAddSubChannel(top, sub)

			toCheckIsFakePhone = false
		end

		if toCheckIsFakePhone then
			print_error("OpenChatPanel: NpcChatMessage not found!!!, topChannelId", top, "subChannelId", sub)
		end
	end

	if gNpcChatManager.currentNpcChatType ~= LTConfig.NPCChatConfig.ChatTypeType.Normal then
		params.forceShow = true
	end

	params.topChannelId = top
	params.subChannelId = sub

	NpcChatUtils.CheckParam(params, "topChannelId", top, chatCfg and chatCfg.Id)
	NpcChatUtils.CheckParam(params, "subChannelId", sub, chatCfg and chatCfg.Id)

	return params
end

function NpcChatUtils._TryGetNpcsPhoneCfg(chatCfg)
	if not chatCfg then
		return nil
	end

	local count = LTConfig.NPCChatNpcsPhoneConfig.count

	for i = 0, count - 1 do
		local npcPhoneCfg = LTConfig.NPCChatNpcsPhoneConfig.LoadAt(i)

		if table.find(npcPhoneCfg.ChatList, chatCfg.Id) then
			return npcPhoneCfg
		end
	end
end

function NpcChatUtils.SortSubChannelItems(items)
	table.sort(items, function (a, b)
		if a.info and b.info then
			if a.info.OnlineState ~= b.info.OnlineState then
				return a.info.OnlineState < b.info.OnlineState
			elseif a.info.OnlineState == UX.Game.PlayerState.Online then
				return ulong.Less(a.subChannelId, b.subChannelId)
			else
				return b.info.LastLogoutTime < a.info.LastLogoutTime
			end
		end

		if a.timeStamp ~= b.timeStamp then
			return b.timeStamp < a.timeStamp
		else
			return ulong.Less(a.subChannelId, b.subChannelId)
		end
	end)
end

function NpcChatUtils.GetNpcChatChannelId(cfg)
	local isGroup = cfg.ChatGroup > 0
	local topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc
	local templateId = isGroup and cfg.ChatGroup or cfg.NPCid

	return topChannelId, templateId
end

function NpcChatUtils.SetCloseType(...)
	local store = this.GetBasePanelStore()

	store:SetCloseType(...)
end

function NpcChatUtils.ShowPhoneAppTip(text)
	local store = this.GetBasePanelStore()

	store:ShowMessage(text)
end

function NpcChatUtils.GetCurrentCloseType()
	local store = this.GetBasePanelStore()

	return store.closeType, store.customCloseFunc
end

function NpcChatUtils.GetCurrentNpcChannelLastMsg(top, sub)
	if not top or not sub then
		top, sub = gNpcChatManager:GetCurrentChannel()
	end

	local channel = gNpcChatManager:GetChannel(top, sub)

	return channel and channel.messages and channel.messages[#channel.messages]
end

function NpcChatUtils.GetBasePanelStore()
	return gStoreManager:GetStoreGroup("NpcChatBasePanelStore")
end

function NpcChatUtils.IsChatPanelShowing()
	local basePanelStore = this.GetBasePanelStore()

	return basePanelStore and gClientUtils.NotNil(basePanelStore.rootWidget) and basePanelStore.rootWidget.activation and basePanelStore.rootWidget.gameObject.activeInHierarchy
end

function NpcChatUtils.GetMainPhonePanelId()
	if gPanelManager:IsPanelShowing(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL) then
		return gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL
	end

	return gClientUtils.GetMainPhonePanelId()
end

function NpcChatUtils.GetNextNpcChatId(msg)
	if msg.npcNextChatId > 0 then
		return msg.npcNextChatId
	end

	local lastChatCfg = msg.cfg

	if lastChatCfg and lastChatCfg.NextMessage and #lastChatCfg.NextMessage == 1 then
		return lastChatCfg.NextMessage[1]
	end

	return 0
end

function NpcChatUtils.GetFavorViewInfo(npcCultivationId)
	local favorInfo = gNpcFavorManager:GetSpiritFavorInfo(npcCultivationId)

	if table.isNilOrEmpty(favorInfo) then
		print_error("GetFavorViewInfo not found! npcCultivationId:", npcCultivationId)

		return nil
	end

	local result = {
		favorNum = favorInfo.favorLevel,
		favorFillAmount = favorInfo.favorAmount
	}

	return result
end

function NpcChatUtils.SetChatChannelCardBaseView(btn, topChannelId, subChannelId)
	if gClientUtils.IsNil(btn) then
		print_error("@liulijun04 SetChatChannelCardBaseView btn is nil")

		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)
	local store = storeGroup and storeGroup:GetStoreByWidget(btn)

	if store == nil then
		print_error("@liulijun04 SetChatChannelCardBaseView btn.Store is nil!, btn", btn.name)
	end

	gNpcChatAvatarUtils:SetChannelAvatar(topChannelId, subChannelId, store.avatar)
end

function NpcChatUtils.NotImplementedHint()
	gDisplayMessageMgr:ShowMessage(65401046)
end

function NpcChatUtils.ShowSystemIcon(headRoot, icon)
	headRoot.headType = gNpcChatConst.HeadIconType.System
	headRoot.lihuiIcon = icon
end

function NpcChatUtils.ShowNpcGroupIcons(headRoot, icons, groupLimit)
	headRoot.headType = gNpcChatConst.HeadIconType.NPCGroup
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

function NpcChatUtils.ShowPZHeadInfoHead(headRoot, headInfo, isMe)
	local type, path = gImageManager:GetHeadIconByHeadIconInfo(headInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
	local iconId = path
	local cfg = LTConfig.ImageAvatarConfig.GetConfig(iconId)

	if cfg == nil then
		print_warn(iconId .. " AvatarImage Dont Exist")

		return
	end

	gNpcChatUtils.ShowSystemIcon(headRoot, cfg.ImageId)
end

function NpcChatUtils.TurnChatCfgListToOptions(nextChatCfgList)
	local options = {}

	for _, cfg in ipairs(nextChatCfgList) do
		local isEmoji = cfg.SpecialMsgType == gNpcChatConst.SpecialMsgType.Emoji
		local itemData = {
			cfg = cfg,
			tIndex = isEmoji and 1 or 0,
			content = string.is_null_or_empty(cfg.OptionText) and gNpcChatUtils.GetMessage(cfg) or cfg.OptionText
		}

		table.insert(options, itemData)
	end

	return options
end

function NpcChatUtils.IsNextPlayerEllipsis(chatId)
	local msgNow = LTConfig.NPCChatConfig.GetConfig(chatId)

	if not msgNow then
		return false
	end

	if not msgNow.IsPlayerMessage then
		return false
	end

	if #msgNow.NextMessage ~= 1 then
		return false
	end

	local followingMsg = LTConfig.NPCChatConfig.GetConfig(msgNow.NextMessage[1])

	if not followingMsg then
		print_error("NextMessage 引用了不存在的 chatId! NPCChatConfig=", chatId)

		return false
	end

	return followingMsg.IsPlayerMessage
end

function NpcChatUtils.NewFromNpcChatItem(chatItem)
	if chatItem == nil then
		return nil
	end

	local msg = C_NpcChatMessage.new()
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatItem.ChatId)

	if not chatCfg then
		print_error("#NoCreateIssue NpcChatUtils.NewFromNpcChatItem: chatCfg not found, chatId may be deleted :", chatItem.ChatId)

		return nil
	end

	local isGroup = chatCfg.ChatGroup > 0
	msg.timeStamp = chatItem.Timestamp
	msg.npcChatId = chatItem.ChatId
	msg.npcNextChatId = chatItem.NextChatId
	msg.chatContext = chatItem.ChatContext
	msg.msgId = gNpcChatManager:NextId()
	msg.cfg = chatCfg
	msg.topChannelId = isGroup and gNpcChatConst.ChatTopChannel.NpcGroup or gNpcChatConst.ChatTopChannel.Npc
	msg.subChannelId = isGroup and chatCfg.ChatGroup or chatCfg.NPCid
	msg.npcTemplateId = chatCfg.IsPlayerMessage and 0 or chatCfg.NPCid
	msg.pid = chatCfg.IsPlayerMessage and gPlayerManager.infoLogin.bindData.pid or 0

	if chatCfg.IsPlayerMessage or chatCfg.ShowAsReceiver then
		msg.templateMode = gNpcChatConst.ChatMsgTemplateMode.MyChat
	else
		msg.templateMode = gNpcChatConst.ChatMsgTemplateMode.TheirChat
	end

	msg.msgType = gNpcChatConst.SpecialMsgType2MsgType[chatCfg.SpecialMsgType] or gNpcChatConst.MessageType.Text
	msg.isHistory = chatItem.IsRead
	msg.belongNpc = chatItem.BelongNpc

	return msg
end

function NpcChatUtils.NewFromNpcChatMsg(msg)
	if msg == nil then
		return nil
	end

	local newMsg = C_NpcChatMessage.new()
	newMsg.timeStamp = msg.timeStamp
	newMsg.npcChatId = msg.npcChatId
	newMsg.npcNextChatId = msg.npcNextChatId
	newMsg.chatContext = msg.chatContext
	newMsg.msgId = gNpcChatManager:NextId()
	newMsg.cfg = msg.cfg
	newMsg.topChannelId = msg.topChannelId
	newMsg.subChannelId = msg.subChannelId
	newMsg.npcTemplateId = msg.npcTemplateId
	newMsg.pid = msg.pid
	newMsg.templateMode = msg.templateMode
	newMsg.msgType = msg.msgType
	newMsg.isHistory = msg.isHistory
	newMsg.belongNpc = msg.belongNpc

	return newMsg
end

function NpcChatUtils.ConvertCSNpcChatData(npcChatData)
	local data = {
		TemplateId = npcChatData.TemplateId,
		DialogChatListDict = {}
	}

	if npcChatData.DialogChatListDict then
		for key, chatInfoList in pairs(npcChatData.DialogChatListDict) do
			local chatList = chatInfoList.ChatList
			local msgList = {}

			for _, chatItem in ipairs(chatList) do
				local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

				if msg then
					table.insert(msgList, msg)
				end
			end

			data.DialogChatListDict[key] = {
				ChatList = msgList
			}
		end
	end

	data.InviteChatList = {}

	for _, chatItem in ipairs(npcChatData.InviteChatList) do
		local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

		if msg then
			table.insert(data.InviteChatList, msg)
		end
	end

	data.NpcChatListDict = {}

	for key, chatInfoList in pairs(npcChatData.NpcChatListDict) do
		local chatList = chatInfoList.ChatList
		local msgList = {}

		for _, chatItem in ipairs(chatList) do
			local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

			if msg then
				table.insert(msgList, msg)
			end
		end

		data.NpcChatListDict[key] = {
			ChatList = msgList
		}
	end

	return data
end

function NpcChatUtils.ConvertCSNpcGroupChatData(npcGroupChatData)
	local data = {
		TemplateId = npcGroupChatData.TemplateId,
		DialogChatListDict = {}
	}

	if npcGroupChatData.DialogChatListDict then
		for key, chatInfoList in pairs(npcGroupChatData.DialogChatListDict) do
			local chatList = chatInfoList.ChatList
			local msgList = {}

			for _, chatItem in ipairs(chatList) do
				local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

				if msg then
					table.insert(msgList, msg)
				end
			end

			data.DialogChatListDict[key] = {
				ChatList = msgList
			}
		end
	end

	data.InviteChatList = {}

	for _, chatItem in ipairs(npcGroupChatData.InviteChatList) do
		local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

		if msg then
			table.insert(data.InviteChatList, msg)
		end
	end

	data.Members = {}

	for _, memberId in ipairs(npcGroupChatData.Members) do
		table.insert(data.Members, memberId)
	end

	data.NpcChatListDict = {}

	for key, chatInfoList in pairs(npcGroupChatData.NpcChatListDict) do
		local chatList = chatInfoList.ChatList
		local msgList = {}

		for _, chatItem in ipairs(chatList) do
			local msg = NpcChatUtils.NewFromNpcChatItem(chatItem)

			if msg then
				table.insert(msgList, msg)
			end
		end

		data.NpcChatListDict[key] = {
			ChatList = msgList
		}
	end

	return data
end

function NpcChatUtils.ShowChatNotify(topChannel, subChannel)
	local channel = gNpcChatManager:GetChannel(topChannel, subChannel)

	if not channel or not channel.lastMessage then
		print_error("ShowChatNotify Error! channel =", channel, "topChannel =", topChannel, "subChannel =", subChannel)

		return
	end

	if not gNpcChatUtils.IsVisibleToCurrentNpc(channel.lastMessage.npcChatId) then
		return
	end

	local param = {
		topChannelId = topChannel,
		subChannelId = subChannel,
		chatCfg = channel.lastMessage.cfg
	}

	if topChannel == gNpcChatConst.ChatTopChannel.NpcGroup then
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannel)

		if groupCfg.SIcon ~= 0 then
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.NpcChatNewMessage, {
				info = param
			})
		else
			gNewPopupManager:PushPopup(LTConfig.PopupConfig.NpcGroupChatNewMessage, {
				info = param
			})
		end
	else
		gNewPopupManager:PushPopup(LTConfig.PopupConfig.NpcChatNewMessage, {
			info = param
		})
	end
end

function NpcChatUtils.IsAuxiliaryChannel(topChannelId, auxiliaryChannelId)
	local topChannelInfo = NpcChatTabs.topChannelInfo

	if topChannelId == nil or auxiliaryChannelId == nil or topChannelInfo[topChannelId] == nil then
		return false
	end

	return topChannelInfo[topChannelId].auxiliaryChannel and array.contains(topChannelInfo[topChannelId].auxiliaryChannel, auxiliaryChannelId)
end

function NpcChatUtils.GetCurrentNpcId()
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(gSpiritManager:GetCurFirstSpiritTid())
	local npcId = spiritCfg and spiritCfg.NpcCultivationRelatedId or gNpcChatConst.PlayerSelfIndex

	if npcId == LTConfig.NpcCultivationConfig.DefaultMale or npcId == LTConfig.NpcCultivationConfig.DefaultFemale then
		return gNpcChatConst.PlayerSelfIndex
	end

	return npcId
end

function NpcChatUtils.IsVisibleToCurrentNpc(chatId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg == nil then
		return false
	end

	local currentNpcId = gNpcChatUtils.GetCurrentNpcId()

	if currentNpcId == nil then
		return false
	end

	if cfg.ChatGroup > 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation == 0 or currentNpcId == group.AsNpcCultivation
	end

	return cfg.AsNpcCultivation == 0 or cfg.AsNpcCultivation == currentNpcId or currentNpcId == cfg.SpecialReadableCharacter
end

function NpcChatUtils.CanShowInNormalChatHistory(msg, curNpc)
	local chatId = msg.npcChatId
	local cfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if cfg == nil then
		return false
	end

	if cfg.ChatType == ChatType.Fake then
		return false
	end

	if cfg.SpecialReadableCharacter == curNpc then
		return false
	end

	return cfg.AsNpcCultivation ~= 0 or msg.belongNpc == curNpc
end

function NpcChatUtils.GetNormalAndOtherToSelfMessages(channelInfo)
	local messages = channelInfo.messages
	local curNpc = gNpcChatUtils.GetCurrentNpcId()
	local result = {}

	for _, msg in ipairs(messages) do
		if gNpcChatUtils.CanShowInNormalChatHistory(msg, curNpc) then
			table.insert(result, msg)
		end
	end

	local otherToSelfMessages = gNpcChatManager:GetOtherNpcChatToSelfMessages(channelInfo.topChannelId, channelInfo.subChannelId)

	for _, msg in ipairs(otherToSelfMessages) do
		table.insert(result, msg)
	end

	return result
end

function NpcChatUtils.IsCurrentInChatPage()
	local chatPanel = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")
	local active1 = chatPanel and chatPanel.rootWidget and chatPanel.rootWidget.gameObject.activeInHierarchy
	local chatN2NPanel = gStoreManager:GetStoreGroup("NpcChatN2NChattingPanel")
	local active2 = chatN2NPanel and chatN2NPanel.rootWidget and chatN2NPanel.rootWidget.gameObject.activeInHierarchy

	return active1 or active2
end

function NpcChatUtils.CheckSwitchTimelineEnd()
	return not LX6.Scene.SwitchSceneManager.AfterSwitchShow_CheckShowPlaying() and not LX6.GUI.SwitchTeleportManager.CheckIsLoading()
end

function NpcChatUtils.GetMessage(cfg)
	if not cfg then
		return ""
	end

	if cfg.SpecialMsgType then
		return LTConfig.NPCChatConfig.SpecialMsgDisplayText[cfg.SpecialMsgType] or cfg.Message or ""
	end

	return cfg.Message or ""
end

function NpcChatUtils.HaveNormalTypeChat(topChannelId, subChannelId)
	local subChannel = gNpcChatManager:GetChannel(topChannelId, subChannelId)

	if not subChannel then
		return false
	end

	local messages = gNpcChatUtils.GetNormalAndOtherToSelfMessages(subChannel)

	return messages and #messages > 0
end

function NpcChatUtils.GetUncompletedChatAndDialogCount(npcId)
	if not gNpcChatManager or not gNpcChatManager.m_init or not npcId then
		return 0
	end

	if npcId == LTConfig.NpcCultivationConfig.DefaultMale or npcId == LTConfig.NpcCultivationConfig.DefaultFemale then
		npcId = gNpcChatConst.PlayerSelfIndex
	end

	local count = 0

	for _, chatData in pairs(gNpcChatManager.m_npcChatsDict) do
		count = count + gNpcChatUtils._CountOneNpcUncompletedChatsForNpc(chatData, npcId)
	end

	for _, chatData in pairs(gNpcChatManager.m_npcGroupChatsDict) do
		count = count + gNpcChatUtils._CountOneNpcUncompletedChatsForNpc(chatData, npcId)
	end

	return count
end

function NpcChatUtils._CountOneNpcUncompletedChatsForNpc(chatData, targetNpcId)
	local count = 0
	local chatInfoList = chatData.NpcChatListDict

	if not chatInfoList then
		return count
	end

	for _, asNpcId in ipairs({
		targetNpcId
	}) do
		local chatInfo = chatInfoList[asNpcId]

		if chatInfo and chatInfo.ChatList and #chatInfo.ChatList > 0 then
			local dialogMessages = {}
			local normalMessages = {}

			for _, chatItem in ipairs(chatInfo.ChatList) do
				local cfg = LTConfig.NPCChatConfig.GetConfig(chatItem.npcChatId)

				if cfg then
					if cfg.ChatType == ChatType.Dialog then
						table.insert(dialogMessages, chatItem)
					elseif cfg.ChatType == ChatType.Normal then
						table.insert(normalMessages, chatItem)
					end
				end
			end

			if #dialogMessages > 0 then
				local lastMsg = dialogMessages[#dialogMessages]

				if lastMsg and gNpcChatUtils.HasNextMessage(lastMsg) then
					local cfg = LTConfig.NPCChatConfig.GetConfig(lastMsg.npcChatId)

					if cfg and gNpcChatUtils.IsVisibleToNpc(cfg, targetNpcId) then
						count = count + 1
					end
				end
			end

			if #normalMessages > 0 then
				local lastNormalMsg = normalMessages[#normalMessages]

				if lastNormalMsg and gNpcChatUtils.HasNextMessage(lastNormalMsg) then
					local cfg = LTConfig.NPCChatConfig.GetConfig(lastNormalMsg.npcChatId)

					if cfg and gNpcChatUtils.IsVisibleToNpc(cfg, targetNpcId) then
						count = count + 1
					end
				end
			end
		end
	end

	return count
end

function NpcChatUtils.IsVisibleToNpc(cfg, targetNpcId)
	if cfg == nil or targetNpcId == nil then
		return false
	end

	if cfg.ChatGroup > 0 then
		local group = LTConfig.NPCChatGroupConfig.GetConfig(cfg.ChatGroup)

		return group.AsNpcCultivation == 0 or targetNpcId == group.AsNpcCultivation
	end

	return cfg.AsNpcCultivation == 0 or cfg.AsNpcCultivation == targetNpcId or targetNpcId == cfg.SpecialReadableCharacter
end

function NpcChatUtils.GetTaskControlValue(eventId)
	local taskState = gTaskManager:GetTaskEventState(eventId)

	if taskState == TaskEventState.Accepted then
		return 1
	end

	if taskState == TaskEventState.NotAccept or taskState == TaskEventState.Locked then
		return 0
	elseif taskState == TaskEventState.Submited then
		return 2
	end
end

function NpcChatUtils.ShouldAskReadChat(cfg)
	if not cfg then
		return false
	end

	if cfg.ChatType ~= gNpcChatManager.currentNpcChatType then
		return false
	end

	if cfg.ChatType == ChatType.Fake then
		return false
	end

	if cfg.ChatType == ChatType.Invite and cfg.IsFirst then
		return false
	end

	return true
end

gNpcChatUtils = this
