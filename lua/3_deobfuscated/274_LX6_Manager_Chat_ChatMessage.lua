local NPCChatConfig = LTConfig.NPCChatConfig
C_ChatMessage = DefClass("C_ChatMessage", C_ChatMessage)
local M = C_ChatMessage

function M:ctor()
	self.msgId = 0
	self.pid = ulong.zero
	self.text = nil
	self.mode = nil
	self.templateMode = gChatConst.MsgTemplateMode.MyChat
	self.timeStamp = 0
	self.npcTemplateId = 0
	self.npcChatId = 0
	self.npcNextChatId = 0
	self.topChannelId = gChatTopChannel.Friend
	self.subChannelId = nil
	self.filePath = nil
	self.duration = 0
	self.richTextInfos = nil
	self.content = nil
	self.msgType = gChatConst.MessageType.Text
end

function M:Copy(msg)
	for k, value in pairs(msg) do
		self[k] = value
	end
end

function M:GetText()
	local topChannelId = self.topChannelId
	local npcChatId = self.npcChatId

	if topChannelId == gChatTopChannel.Npc or topChannelId == gChatTopChannel.NpcGroup then
		local cfg = NPCChatConfig.GetConfig(npcChatId)

		return cfg and cfg.Message or ""
	end

	return self.text
end

function M:GetPreviewText()
	local topChannelId = self.topChannelId
	local npcChatId = self.npcChatId

	if topChannelId == gChatTopChannel.Npc or topChannelId == gChatTopChannel.NpcGroup then
		local cfg = NPCChatConfig.GetConfig(npcChatId)

		return cfg and (cfg.Message or cfg.MessageText) or ""
	end

	return self.text
end

C_ChatMessage = M
