local ChaosMasterChaosBattleNpcConfig = LTConfig.ChaosMasterChaosBattleNpcConfig
C_ChaosMasterPreviewPanelStore = DefClass("C_ChaosMasterPreviewPanelStore", C_ChaosMasterPreviewPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterPreviewPanelStore = C_ChaosMasterPreviewPanelStore
local M = C_ChaosMasterPreviewPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnDown")
	self.bindData.comfirmBtn.luaClick = self:CreateAction(self.OnConfirmBtnDown)
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self:InitData(data)

	gBattlePetsMgr.countDown = 0
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:OnExitBtnDown()
	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREVIEW_PANEL)
end

function M:OnConfirmBtnDown()
	if not self:CheckHasChaos() then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901162).Text)

		return
	end

	gPanelManager:CheckShow(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREVIEW_PANEL)
end

function M:OnGenreClick()
	return
end

function M:OnChaosClick(cfg)
	gBattlePetsMgr:DebugLog("OnChaosClick")
end

function M:OnGenreRender(item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId ~= 0 and data.iconId or nil
	store.button.luaClick = self:CreateActionWithArgs("OnGenreClick")
end

function M:OnChaosRender(item, index)
	local store = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.chaosList[index + 1]
	store.lihuiId = data.lihuiId
	store.name = data.name
	store.hideCost = data.hideCost
	store.button.luaClick = self:CreateActionWithArgs("OnChaosClick", {
		cfg = data.chaosCfg
	})
end

function M:OnRewardRender(btn, index)
	local reward = self.rewardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, reward)
end

function M:InitData(data)
	if not data then
		return
	end

	self.npcId = data.npcId
	self.gameMode = data.gameMode
	self.npcUnit = gCS.SceneDataMgr.GetUnit(self.npcId)

	gBattlePetsMgr:InitNpcAndSceneData(self.npcId, UX.Game.BVBGameModeType.BVBGameSimpleBrawl, data.isTest)

	local cfg = ChaosMasterChaosBattleNpcConfig.GetConfig(self.npcId)

	self:RefreshContent(cfg)
end

function M:RefreshContent(cfg)
	local store = gStoreManager:GetStoreGroup("ChaosMasterPreviewContentStore"):GetStoreByWidget(self.bindData.contentRect.content)

	if not store then
		print_error("ChaosMasterPreviewContentStore not found")

		return
	end

	local battleText = cfg.ChaosBattleText[1]

	if not battleText then
		print_error("ChaosMasterChaosBattleNpcConfig battleText is nil, npcId:", cfg.Id)

		return
	else
		store.levelName = battleText.title
		store.levelDes = battleText.Explanation
	end

	self.chaosList = gBattlePetsMgr:GetChaosEnemyList(cfg.ChoasEnemyInfo)
	store.chaosList.luaSimpleRenderItem = self:CreateAction(self.OnChaosRender)

	store.chaosList:SetSimpleList(#self.chaosList)

	local drops = {}

	table.insert(drops, {
		isFirstKill = false,
		count = 0,
		dropId = cfg.DropId
	})

	local itemList = gCommonItemManager:GetItemSortedListByDropList(drops, true)
	self.rewardList = {}

	for i = 1, #itemList do
		self.rewardList[i] = gCommonItemManager:GetItemRenderData({
			itemId = itemList[i].Id
		})
		self.rewardList[i].quality = itemList[i].Quality
	end

	store.rewardList.luaSimpleRenderItem = self:CreateAction(self.OnRewardRender)

	store.rewardList:SetSimpleList(#self.rewardList)
end

function M:RefreshGenreList(sceneIdList)
	self.genreList = gBattlePetsMgr:RefreshGenreList(self.bindData.genreList, sceneIdList)
end

function M:CheckHasChaos()
	for k, v in pairs(gBattlePetsMgr.petDataDic) do
		if v then
			return true
		end
	end

	return false
end
