local DiceBadgeConfig = LTConfig.PoiGameDiceBadgetConfig
local DiceAIConfig = LTConfig.PoiGameDiceAIConfig
local AgentQuoteConfig = LTConfig.AgentQuoteConfig
local Level = {
	primary = 100,
	professional = 103,
	intermediate = 101,
	advanced = 102,
	none = -1
}
local DiceGameManager = L50.Gameplay.DiceGame.DiceGameManager
C_BarGameStartPanelStore = DefClass("C_BarGameStartPanelStore", C_BarGameStartPanelStore, C_StoreGroup)
GroupName2Class.BarGameStartPanelStore = C_BarGameStartPanelStore
local M = C_BarGameStartPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.level = Level.none
	self.slotEntity = nil
	self.diceSceneNodeOp = nil
	self.isSceneNodeLoadComplete = false
	self.diceGame = nil
	self.badgesData = {}
	self.focusBadge = nil
	self.focusBadgeBtn = nil
	self.selectedBadges = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	if data then
		self.slotEntity = data[3]
		self.level = data.customLevel

		if not self.level or self.level == 0 then
			self.level = Level.none
		end
	end

	self.bindData.emptyCtrl = 1

	if Level.professional < self.level then
		self:InitCustom()
	end
end

function M:OnClose()
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.DICE_GAME_SCENE_NODE_LOAD_COMPLETE] = function (eventId, data)
			self.isSceneNodeLoadComplete = true
			self.diceGame = DiceGameManager.GetCurrentDiceGame()
		end
	}
end

function M:RegisterWidget()
	self.bindData.primaryBtn.luaClick = self:CreateActionWithArgs("OnClickLevelSelectBtn", Level.primary)
	self.bindData.intermediateBtn.luaClick = self:CreateActionWithArgs("OnClickLevelSelectBtn", Level.intermediate)
	self.bindData.advancedBtn.luaClick = self:CreateActionWithArgs("OnClickLevelSelectBtn", Level.advanced)
	self.bindData.professionalBtn.luaClick = self:CreateActionWithArgs("OnClickLevelSelectBtn", Level.professional)
	self.bindData.startGameBtn.luaClick = self:CreateAction("OnClickStartGameBtn")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.badgeShowList.luaSimpleRenderItem = self:CreateAction("OnRenderBadgeShowListItem")
	self.bindData.badgeShowList.luaSimpleClick = self:CreateAction("OnClickBadgeShowList")
	self.bindData.selectedList.luaSimpleRenderItem = self:CreateAction("OnRenderSelectedListItem")
	self.bindData.selectedList.luaSimpleClick = self:CreateAction("OnClickSelectedListList")
end

function M:OnClickLevelSelectBtn(level)
	self.level = level
	self.bindData.stageCtrl = 1
	self.bindData.levelCtrl = level - 100

	self:RefreshBadgeList()

	if self.slotEntity ~= nil then
		local slotGo = self.slotEntity.gameObject

		self:LoadDiceSceneNode(slotGo)
	end
end

function M:OnClickStartGameBtn()
	if not self.isSceneNodeLoadComplete then
		return
	end

	self.diceGame:DiceGameStartStandalone(self.level)
	self.slotEntity:TryCallInnerSignal("StartDiceGame")
	gPanelManager:CheckShow(gPanelId.S_BAR_GAME_PLAY_PANEL, {
		diceGame = self.diceGame,
		slot = self.slotEntity,
		skills = self.selectedBadges
	})
	gPanelManager:Close(self.m_Id)
end

function M:OnClickBadgeSelectBtn()
	if #self.selectedBadges >= 3 then
		return
	end

	local exclusion = DiceBadgeConfig.GetConfig(self.focusBadge).MutuallyExclusive

	for _, badge in ipairs(self.selectedBadges) do
		if badge.id == exclusion then
			return
		end
	end

	for _, data in ipairs(self.badgesData) do
		if data.id == self.focusBadge and not data.hasSelected then
			data.hasSelected = true

			table.insert(self.selectedBadges, {
				id = data.id
			})
		end
	end

	self.bindData.badgeShowList:RefreshList()
	self.bindData.selectedList:SetSimpleList(#self.selectedBadges)
end

function M:OnClickCloseBtn()
	self:DestroyDiceSceneNode()
	gPanelManager:Close(self.m_Id)
end

function M:OnRenderBadgeShowListItem(btn, index)
	local data = self.badgesData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DiceBadgeTemplate"):GetStoreById(id)

	if store then
		store.showUnselectCtrl = 0
		store.idText = DiceBadgeConfig.GetConfig(data.id).Name
		store.badgeIconId = DiceBadgeConfig.GetConfig(data.id).IconId
		store.selectedCtrl = data.hasSelected and 1 or 0
	end
end

function M:OnClickBadgeShowList(btn, index)
	local data = self.badgesData[index + 1]
	self.focusBadge = data.id

	self.bindData.selectedList:DeselectAll()
	self:RefreshBadgeDesc()
	self:OnClickBadgeSelectBtn()
end

function M:OnRenderSelectedListItem(btn, index)
	local data = self.selectedBadges[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DiceBadgeTemplate"):GetStoreById(id)

	if store then
		store.showUnselectCtrl = 1
		store.idText = DiceBadgeConfig.GetConfig(data.id).Name
		store.badgeIconId = DiceBadgeConfig.GetConfig(data.id).IconId
		store.unselectBtn.luaClick = self:CreateActionWithArgs("OnClickUnselectBtn", data.id)
	end
end

function M:OnClickSelectedListList(btn, index)
	local data = self.selectedBadges[index + 1]

	self.bindData.badgeShowList:DeselectAll()

	self.bindData.emptyCtrl = 1

	self:OnClickUnselectBtn(data.id)
end

function M:OnClickUnselectBtn(id)
	for _, data in ipairs(self.badgesData) do
		if id == data.id then
			data.hasSelected = false

			if self.bindData.selectedList.selectedIndex and id == self.selectedBadges[self.bindData.selectedList.selectedIndex + 1].id then
				self.bindData.selectBadgeNameText = ""
				self.bindData.selectBadgeDescText = ""
			end
		end
	end

	self.bindData.badgeShowList:RefreshList()

	for i = #self.selectedBadges, 1, -1 do
		if self.selectedBadges[i].id == id then
			table.remove(self.selectedBadges, i)

			break
		end
	end

	self.bindData.selectedList:SetSimpleList(#self.selectedBadges)
end

function M:RefreshBadgeList()
	for i = 0, DiceBadgeConfig.count - 1 do
		local cfg = DiceBadgeConfig.LoadAt(i)
		local badge = {
			id = cfg.Id,
			hasSelected = false
		}

		if gPlayerItemManager:GetPackItemNum(cfg.BadgetId) > 0 then
			table.insert(self.badgesData, badge)
		end
	end

	self.bindData.badgeShowList:SetSimpleList(#self.badgesData)

	self.bindData.selectBadgeNameText = ""
	self.bindData.selectBadgeDescText = ""
end

function M:RefreshBadgeDesc()
	self.bindData.emptyCtrl = 0
	self.bindData.selectBadgeNameText = DiceBadgeConfig.GetConfig(self.focusBadge).Name
	self.bindData.selectBadgeDescText = DiceBadgeConfig.GetConfig(self.focusBadge).Des
end

function M:InitCustom()
	local cfg = DiceAIConfig.GetConfig(self.level)

	if not cfg then
		print_error("AI配置不存在！", self.level)

		return
	end

	local agentQuoteId = cfg.AgentID
	local npcName = AgentQuoteConfig.GetConfig(agentQuoteId).Name
	self.bindData.npcNameText = npcName
	self.bindData.stageCtrl = 1

	self:RefreshBadgeList()

	if self.slotEntity ~= nil then
		local slotGo = self.slotEntity.gameObject

		self:LoadDiceSceneNode(slotGo)
	end
end

function M:LoadDiceSceneNode(slotGo)
	self.isSceneNodeLoadComplete = false

	DiceGameManager.LoadGameSceneNode(slotGo)
end

function M:DestroyDiceSceneNode()
	DiceGameManager.DestroyGameSceneNode()
end
