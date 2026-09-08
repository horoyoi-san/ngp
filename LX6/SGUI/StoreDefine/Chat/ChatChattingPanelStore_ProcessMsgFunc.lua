-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChattingPanelStore_ProcessMsgFunc.lua
-- Decompiled from: 01937_ChatChattingPanelStore_ProcessMsgFunc.lua_37a88337b663.luajit

local M = C_ChatChattingPanelStore

M.ProcessTextMsg = function(self, itemData, store, btn)
	store.content = gClientUtils.RichTextToPlain(itemData.msg:GetText())
end

M.ProcessWaitingMsg = function(self, _, _, btn)
end

M.ProcessVoiceMsg = function(self, itemData, store, btn)
	store.content = math.max(math.ceil(itemData.msg.duration), 1)
	store.btn.luaClick = self.CreateActionWithArgs(self, self.OnClickAudioBubble, itemData)

	self.CacheInteractiveChatItemWidget(self, btn)
end

M.ProcessTeamMsg = function(self, itemData, store, btn)
	self.AskQueryTeamInfo(self, itemData, store)

	if store.joinBtn then
		store.joinBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickTeamBubble, itemData.msg.teamId)
	end
end

M.AskQueryTeamInfo = function(self, itemData, store)
	slot3 = gClientToGameDelegate

	slot3:AskQueryTeamInfo(itemData.msg.teamId).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			return
		end

		self:RefreshTeamData(itemData, store, data)
	end
end

M.RefreshTeamData = function(self, itemData, store, data)
	if not data then
		store.status = gTeamManager.TEAM_STATUS.DISSOLUTION

		return
	end

	local num = #data.Members or 0
	store.num = "(" .. num .. "/4)"

	if itemData.msg.teamId ~= gTeamManager.teamId then
		store.status = gTeamManager.TEAM_STATUS.JOINED
	elseif num > 4 then
		store.status = gTeamManager.TEAM_STATUS.FULL
	else
		store.status = gTeamManager.TEAM_STATUS.NONE
	end
end

M.ProcessRestaurantMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = cfg.SIcon
	store.starNumCtrl = cfg.MsgSubType - 1
end

M.ProcessMapMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	local data = {
		itemData = itemData,
		cfg = cfg
	}
	store.btn.luaClick = self:CreateActionWithArgs(self.OnClickMapBubble, data)

	self:CacheInteractiveChatItemWidget(btn)

	self.baseMap = gBaseMapMgr:GetBaseMap(store.baseMap)

	self.baseMap:SetFixedScaleLevel(3)
	self.baseMap:SetMapInfo(LTConfig.RaidConfig.WorldMap, 1)

	if #cfg.Coordinate ~= 3 then
		local pos = cfg.Coordinate

		self.baseMap:Align(Vector3.New(pos[1], pos[2], pos[3]))
	end
end

M.ProcessPhotoMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	local photoData = {}

	if cfg.SpecialMsgType ~= gChatConst.SpecialMsgType.Photo then
		photoData.imageId = cfg.SIcon

		gStoreBindMethod:BindIconIdToImage(store.image, cfg.SIcon)
	else
		local texture = LX6.Utils.PhotoUtils.GetTaskPhoto(cfg.SpecialMsgTaskid)
		photoData.texture = texture
		store.image.texture = texture
	end

	store.btn.luaClick = self.CreateActionWithArgs(self, self.OnClickPhotoBubble, photoData)

	self.CacheInteractiveChatItemWidget(self, btn)
end

M.ProcessEmojiMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.icon = cfg.SIcon
end

M.ProcessLinkMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.icon = cfg.SIcon
	store.btn.luaClick = self.CreateActionWithArgs(self, self.OnClickLinkBubble, itemData)

	self.CacheInteractiveChatItemWidget(self, btn)
end

M.ProcessBubbleNoticeMsg = function(self, itemData, store, btn)
	local chatContext = itemData.context
	local bubbleConfig = LTConfig.SocialMediaConfig.GetConfig(chatContext.BubbleId)
	store.iconUrl = bubbleConfig.Image[1]
	local emojiList = chatContext.EmojiList:ToTable()
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
	store.title = itemData.title
	store.taskStateCtrl = itemData.isFinish and 1 or 0
	btn.luaClick = self:CreateActionWithArgs(self.OnClickTaskBubble, itemData)
end

M.ProcessMoneyMsg = function(self, itemData, store, btn)
	local cfg = LTConfig.NPCChatConfig.GetConfig(itemData.msg.npcChatId)
	store.title = gClientUtils.RichTextToPlain(cfg.ShareMsgTitle)
	store.description = gClientUtils.RichTextToPlain(cfg.ShareMsgIntro)
	store.typeCtrl = cfg.MsgSubType
end

local OnConstruction = function(inst)
	local const = gChatConst
	inst.ProcessMsgFunc = {
		[const.MessageType.Text] = inst.ProcessTextMsg,
		[const.MessageType.Channel] = nil,
		[const.MessageType.Waiting] = inst.ProcessWaitingMsg,
		[const.MessageType.Voice] = inst.ProcessVoiceMsg,
		[const.MessageType.Restaurant] = inst.ProcessRestaurantMsg,
		[const.MessageType.Map] = inst.ProcessMapMsg,
		[const.MessageType.Photo] = inst.ProcessPhotoMsg,
		[const.MessageType.Emoji] = inst.ProcessEmojiMsg,
		[const.MessageType.Link] = inst.ProcessLinkMsg,
		[const.MessageType.BubbleNotice] = inst.ProcessBubbleNoticeMsg,
		[const.MessageType.Money] = inst.ProcessMoneyMsg,
		[const.MessageType.HintSimple] = inst.ProcessTipsMsg,
		[const.MessageType.Tips] = inst.ProcessTipsMsg,
		[const.MessageType.Task] = inst.ProcessTaskMsg,
		[const.MessageType.TipsWithIcon] = inst.ProcessTipsMsg,
		[const.MessageType.Voice] = inst.ProcessVoiceMsg,
		[const.MessageType.Team] = inst.ProcessTeamMsg
	}
end

return {
	OnConstruction = OnConstruction
}
