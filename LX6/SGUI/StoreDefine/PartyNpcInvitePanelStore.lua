-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyNpcInvitePanelStore.lua
-- Decompiled from: 01080_PartyNpcInvitePanelStore.lua_21af3233516d.luajit

C_PartyNpcInvitePanelStore = DefClass("C_PartyNpcInvitePanelStore", C_PartyNpcInvitePanelStore, C_StoreGroup)
GroupName2Class.PartyNpcInvitePanelStore = C_PartyNpcInvitePanelStore
local M = C_PartyNpcInvitePanelStore

M.ctor = function(self)
	self.npcList = {}
	self.selectedNpcIds = {}
end

M.DefineAllVariables = function(self)
	self.panelId = nil
	self.selectedNpcIds = {}
	self.linkMultiPlayerId = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", true)
end

M.OnGroupDisable = function(self)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "openCommonHalf", false)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.linkMultiPlayerId = data and data.linkMultiPlayerId

	self:RefreshNpcList()
end

M.OnClose = function(self)
	self.panelId = nil
	self.selectedNpcIds = {}
	self.npcList = {}
	self.linkMultiPlayerId = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.fullBaseBtn.luaClick = self.CreateAction(self, self.OnClickFullBaseBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.inviteBtn.luaClick = self.CreateAction(self, self.OnClickInviteBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
end

M.OnClickFullBaseBtn = function(self)
	self.ClosePanel(self)
end

M.OnClickBackBtn = function(self)
	self.ClosePanel(self)
end

M.OnClickInviteBtn = function(self)
	local selectedNpcList = self.GetSelectedNpcList(self)

	if #selectedNpcList ~= 0 then
		return
	end

	local entityIdList = {}

	for _, npcData in ipairs(selectedNpcList) do
		table.insert(entityIdList, npcData.targetId)
	end

	gMessageManager:SendMessage(gEventConstants.ON_PARTY_INVITE_NPC, {
		entityIdList = entityIdList
	})
	self:ClosePanel()
end

M.ClosePanel = function(self)
	if self.panelId then
		gPanelManager:Close(self.panelId)
	end
end

M.RefreshNpcList = function(self)
	local npcIdList = gPartyManager:GetPartyNpcInfoList()
	local cultivationIdSet = {}

	for _, npcId in ipairs(npcIdList) do
		cultivationIdSet[npcId] = true
	end

	local npcList = {}
	local units = {}

	gCS.SceneDataMgr.UnitsManager:LuaGetAllUnits(units)

	for _, unit in ipairs(units) do
		local npcId = self.GetNpcCultivationId(self, unit)

		if npcId == 0 and cultivationIdSet[npcId] then
			cultivationIdSet[npcId] = nil

			table.insert(npcList, {
				npcId = npcId,
				targetId = unit.Pid,
				name = self.GetNpcDisplayName(self, npcId),
				headIconId = self.GetNpcHeadIconId(self, npcId)
			})
		end
	end

	self.npcList = npcList
	self.selectedNpcIds = {}

	self:RefreshInviteBtnState()

	self.bindData.list.groupType = 2
	self.bindData.list.checkMax = self:GetInviteNpcLimit()

	self.bindData.list:SetSimpleList(#npcList)
end

M.GetInviteNpcLimit = function(self)
	local limit = #self.npcList

	if self.linkMultiPlayerId then
		limit = LTConfig.LinkMultiPlayerConfig.GetConfig(self.linkMultiPlayerId).PlayerNum[2] - 1
	end

	return math.min(#self.npcList, limit)
end

M.GetSelectedNpcList = function(self)
	local selectedNpcList = {}

	for _, npcData in ipairs(self.npcList) do
		if self.selectedNpcIds[npcData.npcId] then
			table.insert(selectedNpcList, npcData)
		end
	end

	return selectedNpcList
end

M.RefreshInviteBtnState = function(self)
	local selectedCount = #self:GetSelectedNpcList()
	local inviteNpcLimit = self:GetInviteNpcLimit()
	self.bindData.inviteBtn.interactable = selectedCount ~= inviteNpcLimit and selectedCount >= 0
	self.bindData.inviteBtnTitle = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901532).Text, selectedCount, inviteNpcLimit)
end

M.GetNpcCultivationId = function(self, npc)
	local clientData = npc and npc.ClientData

	if not clientData then
		return 0
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(clientData.cardId)

	return spiritCfg and spiritCfg.NpcCultivationRelatedId or 0
end

M.GetNpcDisplayName = function(self, npcId)
	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

	return npcCfg and npcCfg.Name or ""
end

M.GetNpcHeadIconId = function(self, npcId)
	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

	return npcCfg and npcCfg.SChatHeadId or 0
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.npcList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.head = data.headIconId
	btn.isSelected = self.selectedNpcIds[data.npcId] ~= true
end

M.OnSimpleClickList = function(self, btn, index)
	local data = self.npcList[index + 1]

	if not data then
		return
	end

	if btn.isSelected then
		self.selectedNpcIds[data.npcId] = true
	else
		self.selectedNpcIds[data.npcId] = nil
	end

	self.RefreshInviteBtnState(self)
end
