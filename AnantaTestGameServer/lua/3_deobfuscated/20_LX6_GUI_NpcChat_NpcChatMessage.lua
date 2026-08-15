C_NpcChatMessage = DefClass("C_NpcChatMessage", C_NpcChatMessage)
local M = C_NpcChatMessage

function M:ctor()
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

function M:GetText()
	return gNpcChatUtils.GetMessage(self.cfg)
end

function M:GetPreviewText()
	return gNpcChatUtils.GetMessage(self.cfg) or self.cfg and self.cfg.MessageText or ""
end

gNpcChatMessage = M
