-- Original chunk: @Lua\LuaFiles\LX6\Manager\Chat\ChatMessage.lua
-- Decompiled from: 00289_ChatMessage.lua_3947dc627e96.luajit

local NPCChatConfig = LTConfig.NPCChatConfig
C_ChatMessage = DefClass("C_ChatMessage", C_ChatMessage)
local M = C_ChatMessage

M.ctor = function(self)
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
	self.content = nil
	self.msgType = gChatConst.MessageType.Text
end

M.Copy = function(self, msg)
	for k, value in pairs(msg) do
		self[k] = value
	end
end

M.GetText = function(self)
	local topChannelId = self.topChannelId
	local npcChatId = self.npcChatId

	if topChannelId ~= gChatTopChannel.Npc or topChannelId ~= gChatTopChannel.NpcGroup then
		local cfg = NPCChatConfig.GetConfig(npcChatId)

		return cfg and cfg.Message or ""
	end

	return self.text
end

M.GetPreviewText = function(self)
	local topChannelId = self.topChannelId
	local npcChatId = self.npcChatId

	if topChannelId ~= gChatTopChannel.Npc or topChannelId ~= gChatTopChannel.NpcGroup then
		local cfg = NPCChatConfig.GetConfig(npcChatId)

		return cfg and (cfg.Message or cfg.MessageText) or ""
	end

	return self.text
end

C_ChatMessage = M
