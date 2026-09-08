-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosMasterPreviewPanelStore.lua
-- Decompiled from: 01473_ChaosMasterPreviewPanelStore.lua_ceec50c2f21d.luajit

local ChaosMasterChaosBattleNpcConfig = LTConfig.ChaosMasterChaosBattleNpcConfig
C_ChaosMasterPreviewPanelStore = DefClass("C_ChaosMasterPreviewPanelStore", C_ChaosMasterPreviewPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterPreviewPanelStore = C_ChaosMasterPreviewPanelStore
local M = C_ChaosMasterPreviewPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnDown")
	self.bindData.comfirmBtn.luaClick = self.CreateAction(self, self.OnConfirmBtnDown)
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.InitData(self, data)

	gBattlePetsMgr.countDown = 0
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.OnExitBtnDown = function(self)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREVIEW_PANEL)
end

M.OnConfirmBtnDown = function(self)
	if not self.CheckHasChaos(self) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901162).Text)

		return
	end

	gPanelManager:CheckShow(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)
	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREVIEW_PANEL)
end

M.OnGenreClick = function(self)
end

M.OnChaosClick = function(self, cfg)
	gBattlePetsMgr:DebugLog("OnChaosClick")
end

M.OnGenreRender = function(self, item, index, data)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId == 0 and data.iconId or nil
	store.button.luaClick = self:CreateActionWithArgs("OnGenreClick")
end

M.OnChaosRender = function(self, item, index)
	local store = gStoreManager:GetStoreGroup("ChaosCardTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.chaosList[index + 1]
	store.lihuiId = data.lihuiId
	store.name = data.name
	store.hideCost = data.hideCost
	store.button.luaClick = self.CreateActionWithArgs(self, "OnChaosClick", {
		cfg = data.chaosCfg
	})
end

M.OnRewardRender = function(self, btn, index)
	local reward = self.rewardList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, reward)
end

M.InitData = function(self, data)
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

M.RefreshContent = function(self, cfg)
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
		["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
		["N\\xa1\\xb7\\xa1\\xa2"] = 0,
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

M.CheckHasChaos = function(self)
	for k, v in pairs(gBattlePetsMgr.petDataDic) do
		if v then
			return true
		end
	end

	return false
end
