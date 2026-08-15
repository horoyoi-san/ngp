C_ChatDialogPopupPanelStore = DefClass("C_ChatDialogPopupPanelStore", C_ChatDialogPopupPanelStore, C_ChatNormalPopupPanelStore)
GroupName2Class.ChatDialogPopupPanelStore = C_ChatDialogPopupPanelStore
local M = C_ChatDialogPopupPanelStore

function M:OnClose()
	return
end

function M:OnClick()
	return
end

function M:OnShow(panelId, data)
	if self.bShowing then
		return
	end

	M.base.OnShow(self, panelId, data)

	self.bShowing = true

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_PAUSE)
end

function M:OnDestroy()
	self.bShowing = false

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_RESUME)
	M.base.OnDestroy(self)
end

function M:AutoClose()
	local duration = LTConfig.NPCChatConfig.MessageBeforeTime

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if self and gClientUtils.NotNil(self.rootGo) then
			if self:GetLastMessage(self.data.topChannelId, self.data.subChannelId) ~= nil then
				gChatUtils.OpenChatPanel(self.data)
			end

			gPanelManager:Close(self.panelId)
		end
	end, duration):Start()
end

function M:GetLastMessage(top, sub)
	local lastChatItem = gNpcChatManager:GetLastDialogNpcChatItem(sub, top == gChatTopChannel.NpcGroup)
	local lastMessage = C_NpcChatMessage.New(lastChatItem)

	return lastMessage
end
