-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatChattingPanelStore_ProcessMsgFunc.lua
-- Decompiled from: 01959_NpcChatChattingPanelStore_ProcessMsgFunc.lua_7c9735fecf3e.luajit

local M = C_NpcChatChattingPanelStore
local FightSpiritConfig = LTConfig.FightSpiritConfig

local GetSexSIcon = function(cfg)
	if not cfg.SIcon[2] then
		return cfg.SIcon[1]
	end

	local sexType = gPlayerManager.infoLogin.bindData.sexType

	if sexType ~= UX.Game.SexType.Male then
		return cfg.SIcon[1]
	end

	if sexType ~= UX.Game.SexType.Female then
		return cfg.SIcon[2]
	end

	local isMale = gSpiritManager:GetCurFirstSpiritTid() ~= FightSpiritConfig.DefaultMale

	return isMale and cfg.SIcon[1] or cfg.SIcon[2]
end

M.ProcessTextMsg = function(self, itemData, store, btn)
	store.content = gClientUtils.RichTextToPlain(itemData.msg:GetText())
end

M.ProcessWaitingMsg = function(self, _, _, btn)
end

M.ProcessVoiceMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.content = math.max(math.ceil(itemData.msg.duration), 1)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}
	store.btn.luaClick = self.CreateActionWithArgs(self, "OnClickAudioBubble", data)

	self.CacheInteractiveChatItemWidget(self, btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not gNpcChatManager:IsMsgClicked(itemData.msg.npcChatId, itemData.msg.timeStamp) then
		self.needClickItem[itemData.msg.msgId] = store
		self.clickedMsgIds[itemData.msg.msgId] = nil

		gNpcChatManager:MarkMsgNeedClick(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end
end

M.ProcessRestaurantMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = GetSexSIcon(cfg)
	store.starNumCtrl = cfg.MsgSubType - 1
end

M.ProcessMapMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}

	if store.btn then
		store.btn.luaClick = self.CreateActionWithArgs(self, "OnClickMapBubble", data)
	end

	if store.btn2 then
		store.btn2.luaClick = self.CreateActionWithArgs(self, "OnClickMapBubble", data)
	end

	self.CacheInteractiveChatItemWidget(self, btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not gNpcChatManager:IsMsgClicked(itemData.msg.npcChatId, itemData.msg.timeStamp) then
		self.needClickItem[itemData.msg.msgId] = store
		self.clickedMsgIds[itemData.msg.msgId] = nil

		gNpcChatManager:MarkMsgNeedClick(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end

	self.baseMap = gBaseMapMgr:GetBaseMap(store.baseMap)

	self.baseMap:SetFixedScaleLevel(3)
	self.baseMap:SetMapInfo(gMapSystem.area:GetAreaId(cfg.RaidId, 0), 2)

	if #cfg.Coordinate ~= 3 then
		local pos = cfg.Coordinate

		self.baseMap:Align(Vector3.New(pos[1], pos[2], pos[3]))
	end

	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(cfg.taskEventId)
	local taskId = taskEventCfg and taskEventCfg.StartTask

	if taskId and taskId <= 0 then
		store.taskCtrl = 1
		store.taskStatusCtrl = gNpcChatUtils.GetTaskControlValue(cfg.taskEventId)
	else
		store.taskCtrl = 0
	end
end

M.ProcessPhotoMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}

	if cfg.SpecialMsgType ~= gNpcChatConst.SpecialMsgType.Photo then
		local icon = GetSexSIcon(cfg)
		data.imageId = icon

		gStoreBindMethod:BindIconIdToImage(store.image, icon)
	else
		local texture = LX6.Utils.PhotoUtils.GetTaskPhoto(cfg.SpecialMsgTaskid)
		data.texture = texture
		store.image.texture = texture
	end

	store.btn.luaClick = self.CreateActionWithArgs(self, "OnClickPhotoBubble", data)

	self.CacheInteractiveChatItemWidget(self, btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not gNpcChatManager:IsMsgClicked(itemData.msg.npcChatId, itemData.msg.timeStamp) then
		self.needClickItem[itemData.msg.msgId] = store
		self.clickedMsgIds[itemData.msg.msgId] = nil

		gNpcChatManager:MarkMsgNeedClick(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end
end

M.ProcessEmojiMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.icon = GetSexSIcon(cfg)
end

M.ProcessLinkMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = GetSexSIcon(cfg)
	local data = {
		itemData = itemData,
		cfg = cfg,
		store = store
	}
	store.btn.luaClick = self.CreateActionWithArgs(self, "OnClickLinkBubble", data)

	self.CacheInteractiveChatItemWidget(self, btn)

	store.clickVfxCtrl = 0
	store.msgId = itemData.msg.msgId

	if cfg.NeedClick and not gNpcChatManager:IsMsgClicked(itemData.msg.npcChatId, itemData.msg.timeStamp) then
		self.needClickItem[itemData.msg.msgId] = store
		self.clickedMsgIds[itemData.msg.msgId] = nil

		gNpcChatManager:MarkMsgNeedClick(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end
end

M.ProcessBubbleNoticeMsg = function(self, itemData, store, btn)
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

M.ProcessTipsMsg = function(self, itemData, _, btn)
	local label = btn.GetComponentInChildren(btn, typeof(SGUI.UBaseText))
	label.text = gClientUtils.RichTextToPlain(itemData.content)
end

M.ProcessTaskMsg = function(self, itemData, store, btn)
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

	if cfg.NeedClick and not gNpcChatManager:IsMsgClicked(itemData.msg.npcChatId, itemData.msg.timeStamp) then
		self.needClickItem[itemData.msg.msgId] = store
		self.clickedMsgIds[itemData.msg.msgId] = nil

		gNpcChatManager:MarkMsgNeedClick(self.topChannelId, self.subChannelId, itemData.msg.npcChatId, itemData.msg.timeStamp)
	end
end

M.ProcessMoneyMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.typeCtrl = cfg.MsgSubType
end
