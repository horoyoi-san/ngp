C_ChatNormalPopupPanelStore = DefClass("C_ChatNormalPopupPanelStore", C_ChatNormalPopupPanelStore, C_StoreGroup)
GroupName2Class.ChatNormalPopupPanelStore = C_ChatNormalPopupPanelStore
local M = C_ChatNormalPopupPanelStore

function M:OnAwake()
	self.bindData.button.luaClick = self:CreateAction(self.OnClick)
end

function M:OnShow(panelId, data)
	self.panelId = panelId

	if data == nil then
		print_error("bad argument! data == nil", panelId, self:GetTypeName())
	end

	self.data = data

	self:AutoClose()
	self:SetContent(data.topChannelId, data.subChannelId)
end

function M:OnClick()
	gChatUtils.OpenChatPanel(self.data)
	gPanelManager:Close(self.panelId)
end

function M:GetLastMessage(top, sub)
	if gChatManager:GetChannel(top, sub) then
		return gChatManager:GetChannel(top, sub).lastMessage
	end

	return nil
end

function M:SetContent(top, sub)
	local lastMessage = self:GetLastMessage(top, sub)
	local rawText = lastMessage and lastMessage:GetPreviewText() or ""
	local previewText = gClientUtils.RichTextToPlain(rawText)
	self.bindData.content = previewText

	if top == gChatTopChannel.Npc then
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(sub)
		self.bindData.name = npcChatInfo:GetName()

		if npcChatInfo.isCultivationNpc then
			local npcCultivationInfo = gNpcInteracsUtils:GetNpcCultivationInfo(sub)

			if npcCultivationInfo then
				self.bindData.showFavor = true
				self.bindData.favorLevel = gChatUtils.GetFavorLevel(npcCultivationInfo.Favor)
			end
		end
	elseif top == gChatTopChannel.NpcGroup then
		local cfg = LTConfig.NPCChatGroupConfig.GetConfig(sub)
		self.bindData.name = cfg.GroupName
	end

	gChatAvatarUtils:SetChannelAvatar(top, sub, self.bindData.chatHead)
end

function M:AutoClose()
	local duration = LTConfig.NPCChatConfig.NormalChatMessageTime

	Timer.New(function ()
		if self and gClientUtils.NotNil(self.rootGo) then
			gPanelManager:Close(self.panelId)
		end
	end, duration):Start()
end

function M:OnClose()
	if self.data and self.data.areaIndex then
		-- Nothing
	end
end
