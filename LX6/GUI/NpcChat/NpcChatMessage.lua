-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatMessage.lua
-- Decompiled from: 00311_NpcChatMessage.lua_16bd29fba204.luajit

C_NpcChatMessage = DefClass("C_NpcChatMessage", C_NpcChatMessage)
local M = C_NpcChatMessage

M.ctor = function(self)
	self.msgId = 0
	self.pid = 0
	self.timeStamp = 0
	self.topChannelId = gNpcChatConst.ChatTopChannel.Npc
	self.subChannelId = nil
	self.npcTemplateId = 0
	self.npcChatId = 0
	self.npcNextChatId = 0
	self.templateMode = gNpcChatConst.ChatMsgTemplateMode.TheirChat
	self.msgType = gNpcChatConst.MessageType.Text
	self.chatContext = nil
	self.cfg = nil
	self.isNpcChat = true
	self.isHistory = true
	self.fromOther = false
	self.belongNpc = nil
end

M.GetText = function(self)
	return gNpcChatUtils.GetMessage(self.cfg)
end

M.GetPreviewText = function(self)
	return gNpcChatUtils.GetMessage(self.cfg) or self.cfg and self.cfg.MessageText or ""
end

gNpcChatMessage = M
