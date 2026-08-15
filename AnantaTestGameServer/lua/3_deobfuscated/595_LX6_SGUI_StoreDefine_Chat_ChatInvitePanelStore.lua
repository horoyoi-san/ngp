C_ChatInvitePanelStore = DefClass("C_ChatInvitePanelStore", C_ChatInvitePanelStore, C_AppFragmentStore)
GroupName2Class.ChatInvitePanelStore = C_ChatInvitePanelStore
local M = C_ChatInvitePanelStore

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.btn.luaClick = self:CreateAction(self.OnSubmitBtnClick)
end

function M:OnEnable()
	gChatUtils.SetCloseType(gChatConst.CloseButtonType.ClosePhone)
end

function M:OnShow(_, data)
	self.inviteGamePlayId = data.inviteGamePlayId
	self.inviteGroupChatId = self:GetGroupInviteChatId(self.inviteGamePlayId)

	if self.inviteGroupChatId then
		self.isGroupInvite = true

		self:RefreshGroupNpcInviteList()

		self.groupId = LTConfig.NPCChatConfig.GetConfig(self.inviteGroupChatId).ChatGroup
		self.limit = LTConfig.NPCChatGroupConfig.GetConfig(self.groupId).GroupLimit
		self.bindData.btnText = gString.Format(LTConfig.NPCChatConfig.MultiInviteButtonText, 0, self.limit)
		self.bindData.btn.interactable = false
	else
		self.isGroupInvite = false

		self:RefreshNPCInviteList()
	end

	self.bindData.inviteTypeCtrl = self.isGroupInvite and 1 or 0

	gChatManager:UpdateCurrentChannel(nil)

	self.bindData.cost = gNpcFavorManager:RefreshInteractPoint(self.inviteGamePlayId, self.bindData.totalWidget)
end

function M:OnClose()
	gChatManager.groupInviteList = {}
	self.inviteGroupChatId = nil
	self.inviteGamePlayId = nil
end

function M:SetList(items)
	gChatUtils.SortSubChannelItems(items)
	self.bindData.list:SetList(items)
end

function M:RefreshGroupNpcInviteList()
	local inviteItems = {}
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(self.inviteGroupChatId)
	local npcMessages = chatCfg.NextMessage or {}

	for _, chatId in pairs(npcMessages) do
		local npcTid = LTConfig.NPCChatConfig.GetConfig(chatId).NPCid
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

		if npcChatInfo then
			if not npcChatInfo.isCultivationNpc then
				-- Nothing
			else
				local npcCardInfo = gNpcInteracsUtils:GetNpcCultivationInfo(npcTid) or gNpcInteracsUtils:GetUnlockedNpcCultivationInfo(npcTid)

				if npcCardInfo then
					local item = {
						isSelected = false,
						tIndex = 0,
						view = gChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, npcCardInfo)
					}
					item.subChannelId = item.view.subChannelId

					table.insert(inviteItems, item)
				end
			end
		end
	end

	self:SetList(inviteItems)
end

function M:RefreshNPCInviteList()
	local npcCardInfo = gNpcInteracsUtils:GetInteractableNpcSet()
	local inviteItems = {}
	local chatList = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId).FirstChatIdList
	local npcId2ChatCfg = {}

	for _, id in ipairs(chatList) do
		local cfg = LTConfig.NPCChatConfig.GetConfig(id)
		npcId2ChatCfg[cfg.NPCid] = cfg
	end

	for npcTid, info in pairs(npcCardInfo) do
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

		if npcChatInfo ~= nil and npcChatInfo.isCultivationNpc then
			if npcId2ChatCfg[npcTid] ~= nil then
				local npcCultivationInfo = info
				local item = {
					isSelected = false,
					tIndex = 0,
					view = gChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, npcCultivationInfo),
					chatCfg = npcId2ChatCfg[npcTid]
				}
				item.subChannelId = item.view.subChannelId

				table.insert(inviteItems, item)
			end
		end
	end

	self:SetList(inviteItems)
end

function M:OnRenderItem(btn, _, itemData)
	local store = gStoreManager:GetStoreGroup("ChatBaseCardTemplateStore"):GetStoreByWidget(btn)
	store.typeCtrl = 1
	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(itemData.subChannelId)
	store.name = npcChatInfo:GetName()

	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Npc, itemData.subChannelId, store.avatar)

	store.favorNum = itemData.view.favorViewInfo.favorNum
	store.favorFillAmount = itemData.view.favorViewInfo.favorFillAmount
	store.selectCtrl = itemData.isSelected and 0 or 1

	if self.isGroupInvite then
		itemData.btn = btn
		itemData.store = store
		btn.luaClick = self:CreateActionWithArgs(self.OnClickGroupInviteItem, itemData)
	else
		btn.luaClick = self:CreateActionWithArgs(self.OnClickSingleInviteItem, itemData)
	end
end

function M:OnClickGroupInviteItem(itemData)
	local selected = not itemData.isSelected

	if selected and #gChatManager.groupInviteList == self.limit then
		return
	end

	itemData.store.selectCtrl = selected and 0 or 1
	itemData.isSelected = selected

	if selected then
		table.insert(gChatManager.groupInviteList, itemData.subChannelId)
	else
		for k, v in ipairs(gChatManager.groupInviteList) do
			if v == itemData.subChannelId then
				table.remove(gChatManager.groupInviteList, k)

				break
			end
		end
	end

	self.bindData.btnText = gString.Format(LTConfig.NPCChatConfig.MultiInviteButtonText, #gChatManager.groupInviteList, self.limit)
	self.bindData.btn.interactable = #gChatManager.groupInviteList == self.limit
end

function M:OnClickSingleInviteItem(itemData)
	local subChannelId = itemData.subChannelId

	gChatManager:ClearInviteChat(subChannelId, false)
	gChatManager:GetOrAddSubChannel(gChatTopChannel.Npc, subChannelId)
	gChatManager:UpdateCurrentChannel(gChatTopChannel.Npc, subChannelId)

	local chattingStore = gStoreManager:GetStoreGroup("ChattingToNpcPanelStore")

	chattingStore:BeginInviteNpcChat(itemData.chatCfg)
	gChatUtils.SetCloseType(gChatConst.CloseButtonType.Return)
end

function M:InviteGroupChat()
	gChatManager:ClearInviteChat(self.groupId, true)
	gChatManager:GetOrAddSubChannel(gChatTopChannel.NpcGroup, self.groupId)
	gChatManager:UpdateCurrentChannel(gChatTopChannel.NpcGroup, self.groupId)
	gChatUtils.SetCloseType(gChatConst.CloseButtonType.Hide)

	gClientToGameDelegate:InviteMultiNpcChat(self.inviteGroupChatId, gChatManager.groupInviteList).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gChatUtils.SetCloseType(gChatConst.CloseButtonType.Return)
		end
	end
end

function M:GetGroupInviteChatId(gamePlayId)
	local chatList = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(gamePlayId).FirstChatIdList
	local id = chatList[1]
	local inviteCfg = LTConfig.NPCChatConfig.GetConfig(id)

	if inviteCfg and inviteCfg.IsPlayerMessage and inviteCfg.IsPlayerFirst and inviteCfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Invite and inviteCfg.ChatGroup > 0 and table.isNilOrEmpty(LTConfig.NPCChatGroupConfig.GetConfig(inviteCfg.ChatGroup).GroupMember) then
		return inviteCfg.Id
	end

	return nil
end

function M:OnSubmitBtnClick()
	if #gChatManager.groupInviteList == self.limit then
		self:InviteGroupChat()
	end
end
