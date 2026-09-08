-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BarGameStartPanelStore.lua
-- Decompiled from: 01581_BarGameStartPanelStore.lua_9a611b4b431a.luajit

local DiceBadgeConfig = LTConfig.PoiGameDiceBadgetConfig
local DiceAIConfig = LTConfig.PoiGameDiceAIConfig
local AgentQuoteConfig = LTConfig.AgentQuoteConfig
local MessageConfig = LTConfig.MessageConfig
local Level = {
	["\\xc9\\xc96\\xe8"] = 100,
	["d\\xa3qI\\xa1\\xe1Net@"] = 103,
	["fx\\xb8r^\\xbf\\xf7Cc{jI"] = 101,
	["\\xaa\\xb5\\xaad=\\xfb7"] = 102,
	["t-s^"] = -1
}
local DiceGameManager = L50.Gameplay.DiceGame.DiceGameManager
C_BarGameStartPanelStore = DefClass("C_BarGameStartPanelStore", C_BarGameStartPanelStore, C_StoreGroup)
GroupName2Class.BarGameStartPanelStore = C_BarGameStartPanelStore
local M = C_BarGameStartPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.level = Level.none
	self.gameType = 0
	self.slotEntity = nil
	self.diceSceneNodeOp = nil
	self.isSceneNodeLoadComplete = false
	self.diceGame = nil
	self.badgesData = {}
	self.focusBadge = nil
	self.focusBadgeBtn = nil
	self.selectedBadges = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data and data.level then
		self.level = data.level
	else
		self.level = Level.primary

		print_error("传入参数不包含难度配置，请检查！")
	end

	if data and data.gameType == nil then
		self.gameType = data.gameType
	end

	self.slotEntity = data.customData.entity
	self.customPath = data.customPath
	self.bindData.emptyCtrl = 1

	if Level.professional >= self.level then
		self.InitCustom(self)
	else
		self.OnClickLevelSelectBtn(self, self.level)
	end
end

M.OnClose = function(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.DICE_GAME_SCENE_NODE_LOAD_COMPLETE] = function (eventId, data)
			self.isSceneNodeLoadComplete = true
			self.diceGame = DiceGameManager.GetCurrentDiceGame()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.startGameBtn.luaClick = self.CreateAction(self, "OnClickStartGameBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.badgeShowList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBadgeShowListItem")
	self.bindData.badgeShowList.luaSimpleClick = self.CreateAction(self, "OnClickBadgeShowList")
	self.bindData.selectedList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderSelectedListItem")
	self.bindData.selectedList.luaSimpleClick = self.CreateAction(self, "OnClickSelectedListList")
end

M.OnClickLevelSelectBtn = function(self, level)
	self.level = level
	self.bindData.stageCtrl = 1
	self.bindData.levelCtrl = level - 100

	self.RefreshBadgeList(self)

	if self.slotEntity == nil then
		local slotGo = self.slotEntity.gameObject

		self.LoadDiceSceneNode(self, slotGo)
	end
end

M.OnClickStartGameBtn = function(self)
	if not self.isSceneNodeLoadComplete then
		return
	end

	self.diceGame:DiceGameStartRemote(self.level, self.gameType)

	local gadgetUId = self.slotEntity.entityInstanceId
	local badges = {}

	for i, badge in ipairs(self.selectedBadges) do
		badges[i] = badge.id
	end

	slot3 = gClientToGameSceneDelegate

	slot3:AskEnterDiceZoneDoubleAI(gadgetUId, self.level, self.gameType, badges).Callback = function (err, agentId)
		if err == MessageConfig.Ok then
			print_error("[DiceGame_Net] AskEnterDiceZoneDoubleAI失败", err, gCS.Error.GetNameById(err), ulong.tostring(agentId))

			return
		end

		if ulong.equals(agentId, 0) then
			print_error("[DiceGame_Net] AskEnterDiceZoneDoubleAI成功，但AgentId为0，无法继续游戏", ulong.tostring(agentId))

			return
		end

		self.diceGame:SetOpponentAgentId(agentId)
		self.slotEntity:TryCallInnerSignal("StartDiceGameLeft")
		gPanelManager:CheckShow(gPanelId.S_BAR_GAME_PLAY_PANEL, {
			diceGame = self.diceGame,
			slot = self.slotEntity,
			skills = self.selectedBadges,
			aiAgentId = agentId
		})
		gPanelManager:Close(self.m_Id)
	end
end

M.OnClickBadgeSelectBtn = function(self)
	if #self.selectedBadges > 3 then
		return
	end

	local exclusion = DiceBadgeConfig.GetConfig(self.focusBadge).MutuallyExclusive

	for _, badge in ipairs(self.selectedBadges) do
		if badge.id ~= exclusion then
			return
		end
	end

	for _, data in ipairs(self.badgesData) do
		if data.id ~= self.focusBadge and not data.hasSelected then
			data.hasSelected = true

			table.insert(self.selectedBadges, {
				id = data.id
			})
		end
	end

	self.bindData.badgeShowList:RefreshList()
	self.bindData.selectedList:SetSimpleList(#self.selectedBadges)
end

M.OnClickCloseBtn = function(self)
	self:DestroyDiceSceneNode()
	gPanelManager:Close(self.m_Id)
end

M.OnRenderBadgeShowListItem = function(self, btn, index)
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

M.OnClickBadgeShowList = function(self, btn, index)
	local data = self.badgesData[index + 1]
	self.focusBadge = data.id

	self.bindData.selectedList:DeselectAll()
	self:RefreshBadgeDesc()
	self:OnClickBadgeSelectBtn()
end

M.OnRenderSelectedListItem = function(self, btn, index)
	local data = self.selectedBadges[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("DiceBadgeTemplate"):GetStoreById(id)

	if store then
		store.showUnselectCtrl = 1
		store.idText = DiceBadgeConfig.GetConfig(data.id).Name
		store.badgeIconId = DiceBadgeConfig.GetConfig(data.id).IconId
		store.unselectBtn.luaClick = self.CreateActionWithArgs(self, "OnClickUnselectBtn", data.id)
	end
end

M.OnClickSelectedListList = function(self, btn, index)
	local data = self.selectedBadges[index + 1]

	self.bindData.badgeShowList:DeselectAll()

	self.bindData.emptyCtrl = 1

	self:OnClickUnselectBtn(data.id)
end

M.OnClickUnselectBtn = function(self, id)
	for _, data in ipairs(self.badgesData) do
		if id ~= data.id then
			data.hasSelected = false

			if self.bindData.selectedList.selectedIndex and id ~= self.selectedBadges[self.bindData.selectedList.selectedIndex + 1].id then
				self.bindData.selectBadgeNameText = ""
				self.bindData.selectBadgeDescText = ""
			end
		end
	end

	self.bindData.badgeShowList:RefreshList()

	for i = #self.selectedBadges, 1, -1 do
		if self.selectedBadges[i].id ~= id then
			table.remove(self.selectedBadges, i)

			break
		end
	end

	self.bindData.selectedList:SetSimpleList(#self.selectedBadges)
end

M.RefreshBadgeList = function(self)
	for i = 0, DiceBadgeConfig.count - 1 do
		local cfg = DiceBadgeConfig.LoadAt(i)
		local badge = {
			id = cfg.Id,
			hasSelected = false
		}

		if gCommonItemManager:GetPackItemNum(cfg.BadgetId) <= 0 then
			table.insert(self.badgesData, badge)
		end
	end

	self.bindData.badgeShowList:SetSimpleList(#self.badgesData)

	self.bindData.selectBadgeNameText = ""
	self.bindData.selectBadgeDescText = ""
end

M.RefreshBadgeDesc = function(self)
	self.bindData.emptyCtrl = 0
	self.bindData.selectBadgeNameText = DiceBadgeConfig.GetConfig(self.focusBadge).Name
	self.bindData.selectBadgeDescText = DiceBadgeConfig.GetConfig(self.focusBadge).Des
end

M.InitCustom = function(self)
	local cfg = DiceAIConfig.GetConfig(self.level)

	if not cfg then
		print_error("AI配置不存在！", self.level)

		return
	end

	local agentQuoteId = cfg.AgentID
	local npcName = AgentQuoteConfig.GetConfig(agentQuoteId).Name
	self.bindData.npcNameText = npcName
	self.bindData.stageCtrl = 1

	self.RefreshBadgeList(self)

	if self.slotEntity == nil then
		local slotGo = self.slotEntity.gameObject

		self.LoadDiceSceneNode(self, slotGo)
	end
end

M.LoadDiceSceneNode = function(self, slotGo)
	self.isSceneNodeLoadComplete = false

	DiceGameManager.LoadGameSceneNode(slotGo, self.customPath)
end

M.DestroyDiceSceneNode = function(self)
	DiceGameManager.DestroyGameSceneNode()
end
