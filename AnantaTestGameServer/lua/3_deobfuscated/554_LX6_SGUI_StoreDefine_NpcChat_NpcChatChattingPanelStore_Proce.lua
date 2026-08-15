local M = C_NpcChatChattingPanelStore

function M:ProcessTextMsg(itemData, store, btn)
	store.content = gClientUtils.RichTextToPlain(itemData.msg:GetText())
end

function M:ProcessWaitingMsg(_, _, btn)
	return
end

function M:ProcessVoiceMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.content = math.max(math.ceil(itemData.msg.duration), 1)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}
	store.btn.luaClick = self:CreateActionWithArgs("OnClickAudioBubble", data)

	self:CacheInteractiveChatItemWidget(btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not itemData.msg.isHistory then
		self.needClickItem[itemData.msg.msgId] = store
	end
end

function M:ProcessRestaurantMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = cfg.SIcon
	store.starNumCtrl = cfg.MsgSubType - 1
end

function M:ProcessMapMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}

	if store.btn then
		store.btn.luaClick = self:CreateActionWithArgs("OnClickMapBubble", data)
	end

	if store.btn2 then
		store.btn2.luaClick = self:CreateActionWithArgs("OnClickMapBubble", data)
	end

	self:CacheInteractiveChatItemWidget(btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not itemData.msg.isHistory then
		self.needClickItem[itemData.msg.msgId] = store
	end

	self.baseMap = gBaseMapMgr:GetBaseMap(store.baseMap)

	self.baseMap:SetFixedScaleLevel(3)
	self.baseMap:SetMapInfo(gMapSystem.area:GetAreaId(LTConfig.RaidConfig.WorldMap, 0), 2)

	if #cfg.Coordinate == 3 then
		local pos = cfg.Coordinate

		self.baseMap:Align(Vector3.New(pos[1], pos[2], pos[3]))
	end

	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(cfg.taskEventId)
	local taskId = taskEventCfg and taskEventCfg.StartTask

	if taskId and taskId > 0 then
		store.taskCtrl = 1
		store.taskStatusCtrl = gNpcChatUtils.GetTaskControlValue(cfg.taskEventId)
	else
		store.taskCtrl = 0
	end
end

function M:ProcessPhotoMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}

	if cfg.SpecialMsgType == gNpcChatConst.SpecialMsgType.Photo then
		data.imageId = cfg.SIcon

		gStoreBindMethod:BindIconIdToImage(store.image, cfg.SIcon)
	else
		local texture = LX6.Utils.PhotoUtils.GetTaskPhoto(cfg.SpecialMsgTaskid)
		data.texture = texture
		store.image.texture = texture
	end

	store.btn.luaClick = self:CreateActionWithArgs("OnClickPhotoBubble", data)

	self:CacheInteractiveChatItemWidget(btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not itemData.msg.isHistory then
		self.needClickItem[itemData.msg.msgId] = store
	end
end

function M:ProcessEmojiMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.icon = cfg.SIcon
end

function M:ProcessLinkMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = cfg.SIcon
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}
	store.btn.luaClick = self:CreateActionWithArgs("OnClickLinkBubble", data)

	self:CacheInteractiveChatItemWidget(btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not itemData.msg.isHistory then
		self.needClickItem[itemData.msg.msgId] = store
	end
end

function M:ProcessBubbleNoticeMsg(itemData, store, btn)
	local chatContext = itemData.context

	if not chatContext then
		print_debug("ProcessBubbleNoticeMsg: chatContext is nil, do you use gm to send bubble notice?")

		return
	end

	local bubbleConfig = LTConfig.SocialMediaConfig.GetConfig(chatContext.BubbleId)
	store.iconUrl = bubbleConfig.Image[1]
	local emojiList = chatContext.EmojiList
	local emojiNum = #emojiList
	store.emojiNumCtrl = math.min(emojiNum - 1, 3)

	for i = 1, math.min(emojiNum, 3) do
		local emojiInfo = emojiList[i]
		local textComp = store["widget" .. i]:GetComponentInChildren(typeof(SGUI.UBaseText))
		textComp.text = emojiInfo.Count
		local imageComp = store["widget" .. i]:GetComponentInChildren(typeof(SGUI.UImage))
		local iconId = tonumber(emojiInfo.Id)

		gStoreBindMethod:BindIconIdToImage(imageComp, iconId)
	end
end

function M:ProcessTipsMsg(itemData, _, btn)
	local label = btn:GetComponentInChildren(typeof(SGUI.UBaseText))
	label.text = gClientUtils.RichTextToPlain(itemData.content)
end

function M:ProcessTaskMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = itemData.title
	store.taskStateCtrl = itemData.isFinish and 1 or 0
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}
	btn.luaClick = self:CreateActionWithArgs("OnClickTaskBubble", data)
	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not itemData.msg.isHistory then
		self.needClickItem[itemData.msg.msgId] = store
	end
end

function M:ProcessMoneyMsg(itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.typeCtrl = cfg.MsgSubType
end
