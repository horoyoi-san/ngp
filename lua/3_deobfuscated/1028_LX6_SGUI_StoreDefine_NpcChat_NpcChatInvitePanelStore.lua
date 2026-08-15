local MessageConfig = LTConfig.MessageConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local AgentConfig = LTConfig.AgentConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
C_NpcChatInvitePanelStore = DefClass("C_NpcChatInvitePanelStore", C_NpcChatInvitePanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatInvitePanelStore = C_NpcChatInvitePanelStore
local M = C_NpcChatInvitePanelStore

function M:ctor()
	self.listData = {}
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.onGetTIndex = self:CreateAction("OnGetListTIndex")
	self.bindData.btn.luaClick = self:CreateAction("OnSubmitBtnClick")
	self.msgEvents = {
		[gEventConstants.NPC_INVITE_POINT_CHANGE] = self:CreateAction("RefreshPoint")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnEnable()
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.ClosePhone)
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

	gNpcChatManager:UpdateCurrentChannel(nil)

	self.bindData.cost = gNpcFavorManager:RefreshInteractPoint(self.inviteGamePlayId, self.bindData.totalWidget)
	local gamePlayCfg = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local needLevel = gamePlayCfg.NeedLevel

	if needLevel and needLevel > 0 then
		self.bindData.showLevelCtrl = 1
		self.bindData.levelLimitText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901302).Text, needLevel)
	else
		self.bindData.showLevelCtrl = 0
	end
end

function M:OnResume()
	gNpcChatManager:UpdateCurrentChannel(nil)
end

function M:OnClose()
	gNpcChatManager.groupInviteList = {}
	self.inviteGroupChatId = nil
	self.inviteGamePlayId = nil
end

function M:SetList(items)
	local needLevel = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId).NeedLevel or 3

	table.sort(items, function (a, b)
		local aLevel = a.view.favorLevel or 0
		local bLevel = b.view.favorLevel or 0
		local aCanInvite = needLevel <= aLevel
		local bCanInvite = needLevel <= bLevel

		if aCanInvite ~= bCanInvite then
			return aCanInvite
		end

		local aFavor = a.view.favorViewInfo and a.view.favorViewInfo.favorNum or 0
		local bFavor = b.view.favorViewInfo and b.view.favorViewInfo.favorNum or 0

		return aFavor > bFavor
	end)

	self.listData = items

	self.bindData.list:SetSimpleList(#items)
end

function M:RefreshPoint()
	gNpcFavorManager:OnRenderActionPoint(self.bindData.totalWidget, nil, nil)

	if self.isGroupInvite then
		self.bindData.btn.interactable = #gNpcChatManager.groupInviteList == self.limit and gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId)
	end
end

function M:RefreshGroupNpcInviteList()
	local inviteItems = {}
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(self.inviteGroupChatId)
	local gamePlayCfg = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local npcMessages = chatCfg.NextMessage or {}

	for _, chatId in pairs(npcMessages) do
		local npcTid = LTConfig.NPCChatConfig.GetConfig(chatId).NPCid
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

		if npcChatInfo then
			if not npcChatInfo.isCultivationNpc then
				-- Nothing
			elseif self:ShouldFilterNpcByBodyType(npcTid, gamePlayCfg) then
				-- Nothing
			else
				local npcCardInfo = gNpcInteracsUtils:GetNpcCultivationInfo(npcTid) or gNpcInteracsUtils:GetUnlockedNpcCultivationInfo(npcTid)

				if npcCardInfo then
					local item = {
						isSelected = false,
						tIndex = 0,
						view = gNpcChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, npcCardInfo)
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
	local gamePlayCfg = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local chatList = gamePlayCfg.FirstChatIdList
	local npcId2ChatCfg = {}

	for _, id in ipairs(chatList) do
		local cfg = LTConfig.NPCChatConfig.GetConfig(id)
		npcId2ChatCfg[cfg.NPCid] = cfg
	end

	for npcTid, info in pairs(npcCardInfo) do
		local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

		if npcChatInfo and npcChatInfo.isCultivationNpc then
			if not npcId2ChatCfg[npcTid] then
				-- Nothing
			elseif not self:ShouldFilterNpcByBodyType(npcTid, gamePlayCfg) then
				local item = {
					isSelected = false,
					tIndex = 0,
					view = gNpcChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, info),
					chatCfg = npcId2ChatCfg[npcTid]
				}
				item.subChannelId = item.view.subChannelId

				table.insert(inviteItems, item)
			end
		end
	end

	self:SetList(inviteItems)
end

function M:OnRenderItem(btn, index)
	local itemData = self.listData[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChatBaseCardTemplateStore"):GetStoreByWidget(btn)
	store.typeCtrl = 1
	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(itemData.subChannelId)
	store.name = npcChatInfo:GetName()

	gNpcChatAvatarUtils:SetChannelAvatar(gNpcChatConst.ChatTopChannel.Npc, itemData.subChannelId, store.avatar)

	store.favorNum = itemData.view.favorViewInfo.favorNum
	store.favorFillAmount = itemData.view.favorViewInfo.favorFillAmount
	itemData.store = store
	store.headBtn.luaClick = self:CreateActionWithArgs(self.OnClickHead, itemData)
	store.improveBtn.luaClick = self:CreateActionWithArgs(self.OnClickHead, itemData)
	local level = itemData.view.favorLevel
	local needLevel = LTConfig.NPCChatGamePlayTypeConfig.GetConfig(self.inviteGamePlayId).NeedLevel or 3
	store.selectCtrl = level >= needLevel and 1 or 0

	if self.isGroupInvite then
		store.singleInviteCtrl = 0
		store.groupInviteSelectCtrl = itemData.isSelected and 1 or 0
		store.inviteGroupBtn.luaClick = self:CreateActionWithArgs(self.OnClickGroupInviteItem, itemData)
	else
		store.singleInviteCtrl = 1
		store.inviteBtn.luaClick = self:CreateActionWithArgs(self.OnClickSingleInviteItem, itemData)
	end
end

function M:OnGetListTIndex(index)
	local itemData = self.listData[index + 1]

	return itemData and itemData.tIndex or 0
end

function M:OnClickGroupInviteItem(itemData)
	if not gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId) then
		gNpcChatUtils.GetBasePanelStore():ShowMessage(MessageConfig.GetConfig(MessageConfig.NpcChatInvitePointNotEnough).Content, 2)

		return
	end

	local selected = not itemData.isSelected

	if selected and #gNpcChatManager.groupInviteList == self.limit then
		return
	end

	itemData.store.groupInviteSelectCtrl = selected and 1 or 0
	itemData.isSelected = selected

	if selected then
		table.insert(gNpcChatManager.groupInviteList, itemData.subChannelId)
	else
		for k, v in ipairs(gNpcChatManager.groupInviteList) do
			if v == itemData.subChannelId then
				table.remove(gNpcChatManager.groupInviteList, k)

				break
			end
		end
	end

	self.bindData.btnText = gString.Format(LTConfig.NPCChatConfig.MultiInviteButtonText, #gNpcChatManager.groupInviteList, self.limit)
	self.bindData.btn.interactable = #gNpcChatManager.groupInviteList == self.limit
end

function M:OnClickSingleInviteItem(itemData)
	if not gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId) then
		gNpcChatUtils.GetBasePanelStore():ShowMessage(MessageConfig.GetConfig(MessageConfig.NpcChatInvitePointNotEnough).Content, 2)

		return
	end

	local subChannelId = itemData.subChannelId

	gNpcChatManager:ClearInviteChat(subChannelId, false)
	gNpcChatManager:GetOrAddSubChannel(gNpcChatConst.ChatTopChannel.Npc, subChannelId)
	gNpcChatManager:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.Npc, subChannelId)

	local chattingStore = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

	chattingStore:BeginInviteNpcChat(itemData.chatCfg, self.inviteGamePlayId)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)
end

function M:InviteGroupChat()
	gNpcChatManager:ClearInviteChat(self.groupId, true)
	gNpcChatManager:GetOrAddSubChannel(gNpcChatConst.ChatTopChannel.NpcGroup, self.groupId)
	gNpcChatManager:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.NpcGroup, self.groupId)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)

	gClientToGameDelegate:InviteMultiNpcChat(self.inviteGroupChatId, gNpcChatManager.groupInviteList).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)
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

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnSubmitBtnClick()
	if #gNpcChatManager.groupInviteList == self.limit then
		self:InviteGroupChat()
	end
end

function M:OnClickHead(itemData)
	if not itemData or not itemData.subChannelId then
		print_error("OnClickHead: itemData or subChannelId is nil")

		return
	end

	local npcId = itemData.subChannelId

	if npcId and npcId > 0 then
		local agentType = gNpcDaliyManager:GetAgentTagByNpcId(npcId)

		gNewBubbleMgr:OpenNpcBubblePanel(agentType)
	end
end

function M:GetNpcBodyType(npcTid)
	local npcCfg = NpcCultivationConfig.GetConfig(npcTid)

	if not npcCfg or not npcCfg.FightSpiritID then
		return nil
	end

	local spiritCfg = FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)

	if not spiritCfg or not spiritCfg.AgentId then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg or not agentCfg.GeneralModelId then
		return nil
	end

	local modelCfg = GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	return modelCfg and modelCfg.BodyType or nil
end

function M:ShouldFilterNpcByBodyType(npcTid, gamePlayCfg)
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if not myPlayerCSUnit then
		return false
	end

	local agentCfg = AgentConfig.GetConfig(myPlayerCSUnit.ClientData.AgentId)

	if not agentCfg then
		return false
	end

	local playerSex = agentCfg.SexType
	local filterTypes = playerSex == UX.Game.SexType.Male and gamePlayCfg.MalePlayerDontInviteType or playerSex == UX.Game.SexType.Female and gamePlayCfg.FemalePlayerDontInviteType

	if not filterTypes or #filterTypes == 0 then
		return false
	end

	local npcBodyType = self:GetNpcBodyType(npcTid)

	if not npcBodyType then
		return false
	end

	for _, bodyType in ipairs(filterTypes) do
		if npcBodyType == bodyType then
			return true
		end
	end

	return false
end
