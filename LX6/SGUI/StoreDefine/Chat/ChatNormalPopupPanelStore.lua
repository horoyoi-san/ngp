-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatNormalPopupPanelStore.lua
-- Decompiled from: 01269_ChatNormalPopupPanelStore.lua_fe6591067ba6.luajit

C_ChatNormalPopupPanelStore = DefClass("C_ChatNormalPopupPanelStore", C_ChatNormalPopupPanelStore, C_StoreGroup)
GroupName2Class.ChatNormalPopupPanelStore = C_ChatNormalPopupPanelStore
local M = C_ChatNormalPopupPanelStore

M.OnAwake = function(self)
	self.bindData.button.luaClick = self.CreateAction(self, self.OnClick)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId

	if data ~= nil then
		print_error("bad argument! data == nil", panelId, self.GetTypeName(self))
	end

	self.data = data

	self.AutoClose(self)
	self.SetContent(self, data.topChannelId, data.subChannelId)
end

M.OnClick = function(self)
	gChatUtils.OpenChatPanel(self.data)
	gPanelManager:Close(self.panelId)
end

M.GetLastMessage = function(self, top, sub)
	if gChatManager:GetChannel(top, sub) then
		return gChatManager:GetChannel(top, sub).lastMessage
	end

	return nil
end

M.SetContent = function(self, top, sub)
	local lastMessage = self:GetLastMessage(top, sub)
	local rawText = lastMessage and lastMessage:GetPreviewText() or ""
	local previewText = gClientUtils.RichTextToPlain(rawText)
	self.bindData.content = previewText

	if top ~= gChatTopChannel.Npc then
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(sub)
		self.bindData.name = npcChatInfo:GetName()

		if npcChatInfo.isCultivationNpc then
			local npcCultivationInfo = gNpcInteracsUtils:GetNpcCultivationInfo(sub)

			if npcCultivationInfo then
				self.bindData.showFavor = true
				self.bindData.favorLevel = gChatUtils.GetFavorLevel(npcCultivationInfo.Favor)
			end
		end
	elseif top ~= gChatTopChannel.NpcGroup then
		local cfg = LTConfig.NPCChatGroupConfig.GetConfig(sub)
		self.bindData.name = cfg.GroupName
	end

	gChatAvatarUtils:SetChannelAvatar(top, sub, self.bindData.chatHead)
end

M.AutoClose = function(self)
	local duration = LTConfig.NPCChatConfig.NormalChatMessageTime

	Timer.New(function ()
		if self and gClientUtils.NotNil(self.rootGo) then
			gPanelManager:Close(self.panelId)
		end
	end, duration):Start()
end

M.OnClose = function(self)
	if self.data and self.data.areaIndex then
		-- Nothing
	end
end
