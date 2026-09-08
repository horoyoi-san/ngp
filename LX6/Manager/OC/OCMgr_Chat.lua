-- Original chunk: @Lua\LuaFiles\LX6\Manager\OC\OCMgr_Chat.lua
-- Decompiled from: 02261_OCMgr_Chat.lua_b3f4ea9a38df.luajit

local Consts = gClientConst
local OriginalCharacterChatSettingsConfig = LTConfig.OriginalCharacterChatSettingsConfig
local M = C_OCMgr

M._AddDialogItem = function(self, ret, sessionId, content, isSelf, replyId)
	local ele = {
		id = sessionId,
		label = content,
		isSelf = isSelf,
		replyId = replyId
	}

	table.insert(ret, ele)
end

M.ChatToNpc = function(self, content, callback)
	if self.isMeikaGrandpa then
		local cfg = self.GetMeikaChatParams(self)

		if not cfg then
			if callback then
				callback(nil)
			end

			return
		end

		self.api.MeikaGrandpaChat(content, self.currentSessionId, cfg.npcId, cfg.npcName, cfg.stage, cfg.unlockedMemoryIds, false, function (res)
			if callback then
				callback(res)
			end
		end)

		return
	end

	self.api.SimpleChat(content, false, function (res)
		if callback then
			callback(res)
		end
	end)
end

M.FinishChat = function(self)
	if self.isMeikaGrandpa then
		local cfg = self.GetMeikaChatParams(self)

		if not cfg then
			return
		end

		self.api.MeikaGrandpaChat(nil, self.currentSessionId, cfg.npcId, cfg.npcName, cfg.stage, cfg.unlockedMemoryIds, true, function (obj)
		end)

		return
	end

	self.api.SimpleChat("", true, function (obj)
	end)
end

M.RefreshChat = function(self, replyId, callback)
	self.api.SimpleRewrite(replyId, false, function (obj, utterance)
		if callback then
			callback(obj, utterance)
		end
	end)
end

M.FeedBackChatWithBool = function(self, sessionId, replyId, reply, isLike, callback)
	self.api.FeedbackReaction(sessionId, replyId, reply, isLike, function (res)
		if callback then
			callback(res)
		end
	end)
end

M.OnSessionChange = function(self, _, msg)
	self.currentSessionId = msg
end

M.GetSessionMemory = function(self, sessionId, calback)
	sessionId = sessionId or self.currentSessionId

	return self.api.GetSessionMemory(sessionId, calback)
end

M.OnSimpleRenderDialogListItem = function(self, store, data, refreshCallback)
	if data.isSelf then
		store.titleLabel = gClientUtils.GetCurrentSpiritDisplayName()
	else
		store.titleLabel = self.baseData.name
	end

	store.isSelf = Consts.BOOL2CTL[data.isSelf]
	store.isMeika = Consts.BOOL2CTL[self.isMeikaGrandpa]

	store.Commit(store, "contentLabel", data.label, COMMIT_IMMEDIATELY)

	if not self.isMeikaGrandpa and store.likeBtn then
		store.generateCtrl = Consts.BOOL2CTL[data.isGenerating or false]
		store.likeBtn.isSelected = data.isLiked or false
		store.disLikeBtn.isSelected = data.isDisliked or false
		store.likeBtn.interactable = not data.isDisliked
		store.disLikeBtn.interactable = not data.isLiked

		store.likeBtn.luaClick = function()
			if store.likeBtn.isSelected then
				return
			end

			store.disLikeBtn.interactable = false
			store.likeBtn.isSelected = true
			data.isLiked = true

			self:FeedBackChatWithBool(data.id, data.replyId, data.label, true)
		end

		store.disLikeBtn.luaClick = function()
			if store.disLikeBtn.isSelected then
				return
			end

			store.likeBtn.interactable = false
			store.disLikeBtn.isSelected = true
			data.isDisliked = true

			self:FeedBackChatWithBool(data.id, data.replyId, data.label, false)
		end

		store.newBtn.luaClick = function()
			store.generateCtrl = Consts.BOOL2CTL[true]
			data.isGenerating = true

			self:RefreshChat(data.replyId, function (res, utterance)
				store.generateCtrl = Consts.BOOL2CTL[false]
				data.isGenerating = false

				if refreshCallback then
					refreshCallback(res, utterance)
				end
			end)
		end

		store.editBtn.luaClick = function()
			local parentStore = self:GetChatBaseStore()

			if parentStore then
				parentStore:OpenReivewWindow(data.id, function (res)
					store.editBtn.interactable = false
				end)
			end
		end
	end
end

M.GetChatBaseStore = function(self)
	if self.chatBaseStore then
		return self.chatBaseStore
	end

	self.chatBaseStore = gStoreManager:GetStoreGroup("OCDialogMainPageStore")

	return self.chatBaseStore
end

M.GetChatSettings = function(self)
	local ret = {}

	for i = 0, OriginalCharacterChatSettingsConfig.count - 1 do
		local cfg = OriginalCharacterChatSettingsConfig.LoadAt(i)

		if cfg and (not self.isMeikaGrandpa or cfg.showInGrandpa ~= nil or cfg.showInGrandpa) then
			ret[#ret + 1] = cfg.Id
		end
	end

	return ret
end

M.FeedBackByLanguage = function(self, sessionId, feedback, callback)
	self.api.FeedbackLanguage(sessionId, feedback, function (res)
		if callback then
			callback(res)
		end
	end)
end

M.FirstChat = function(self, callback)
	if self.isMeikaGrandpa then
		local cfg = self.GetMeikaChatParams(self)

		if not cfg then
			if callback then
				callback(nil)
			end

			return
		end

		self.api.MeikaGrandpaFirstChat(cfg.npcId, cfg.npcName, cfg.stage, cfg.unlockedMemoryIds, function (res)
			if callback then
				callback(res)
			end
		end)

		return
	end

	self.api.FirstChat(function (res)
		if callback then
			callback(res)
		end
	end)
end

M.SuggestUserInputs = function(self, sessionId, callback)
	sessionId = sessionId or self.currentSessionId

	if not sessionId or sessionId ~= "" then
		if callback then
			callback(nil)
		end

		return
	end

	if self.isMeikaGrandpa then
		local cfg = self.GetMeikaChatParams(self)

		if not cfg then
			if callback then
				callback(nil)
			end

			return
		end

		self.api.MeikaGrandpaSuggestUserInputs(sessionId, cfg.npcId, cfg.npcName, cfg.stage, function (data)
			if callback then
				callback(data)
			end
		end)

		return
	end

	self.api.SuggestUserInputs(sessionId, function (data)
		if callback then
			callback(data)
		end
	end)
end

M.SocialChat_GetSessions = function(self)
	if not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.OC) then
		return {}
	end

	local oc = {
		name = gOCMgr.ocInfo.OCInfoDict.name or "OC",
		id = gOCMgr.ocInfo.OCInfoDict.OCId or 1
	}

	return {
		[oc.id] = oc
	}
end

M.SocialChat_SendText = function(self, text, referenceMsgId)
	self.SocialChat_PushMessageDisplay(self, true, text)
	self.ChatToNpc(self, text, function (res)
		if not res then
			return
		end

		local data = res

		self:SocialChat_PushMessageDisplay(false, data.Reply)
	end)
end

M.SocialChat_PushMessageDisplay = function(self, bIsSelf, msg)
	local messageInfo = {
		msg = msg,
		isSelf = bIsSelf,
		type = gSocialChatManager.MessageType.Text,
		chatSessionId = gOCMgr.ocInfo.OCInfoDict.OCId or 1,
		msgId = 1,
		time = gCS.TimeManager:GetClientMilliSeconds()
	}

	if not bIsSelf then
		local senderSex = gOCMgr.ocInfo.OCInfoDict.gender
		senderSex = senderSex or "男"
		messageInfo.sender = gOCMgr.ocInfo.OCInfoDict.name or "OC"
		messageInfo.senderId = gOCMgr.ocInfo.OCInfoDict.OCId or 1

		if senderSex ~= "男" then
			messageInfo.senderSex = UX.Game.SexType.Male
		elseif senderSex ~= "女" then
			messageInfo.senderSex = UX.Game.SexType.Female
		else
			messageInfo.senderSex = UX.Game.SexType.UnKnow
		end

		messageInfo.time = gLuaDataManager.serverTime
	end

	gSocialChatManager:OnMessageReceiveFromOC(messageInfo)
end
