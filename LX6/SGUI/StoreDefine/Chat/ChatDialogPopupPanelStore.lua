-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatDialogPopupPanelStore.lua
-- Decompiled from: 01938_ChatDialogPopupPanelStore.lua_ea5404b52564.luajit

C_ChatDialogPopupPanelStore = DefClass("C_ChatDialogPopupPanelStore", C_ChatDialogPopupPanelStore, C_ChatNormalPopupPanelStore)
GroupName2Class.ChatDialogPopupPanelStore = C_ChatDialogPopupPanelStore
local M = C_ChatDialogPopupPanelStore

M.OnClose = function(self)
end

M.OnClick = function(self)
end

M.OnShow = function(self, panelId, data)
	if self.bShowing then
		return
	end

	M.base.OnShow(self, panelId, data)

	self.bShowing = true

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_PAUSE)
end

M.OnDestroy = function(self)
	self.bShowing = false

	gMessageManager:SendMessage(gEventConstants.DROP_QUEUE_RESUME)
	M.base.OnDestroy(self)
end

M.AutoClose = function(self)
	local duration = LTConfig.NPCChatConfig.MessageBeforeTime

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if self and gClientUtils.NotNil(self.rootGo) then
			if self:GetLastMessage(self.data.topChannelId, self.data.subChannelId) == nil then
				gChatUtils.OpenChatPanel(self.data)
			end

			gPanelManager:Close(self.panelId)
		end
	end, duration):Start()
end

M.GetLastMessage = function(self, top, sub)
	local lastChatItem = gNpcChatManager:GetLastDialogNpcChatItem(sub, top ~= gChatTopChannel.NpcGroup)
	local lastMessage = C_NpcChatMessage.New(lastChatItem)

	return lastMessage
end
