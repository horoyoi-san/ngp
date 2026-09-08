-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\FishingGame\FishingGame.lua
-- Decompiled from: 00604_FishingGame.lua_bc71ba446a94.luajit

gFishingGame = DefClass("FishingGame", gFishingGame, gBaseMiniGame)
local FishingGame = gFishingGame
local MessageConfig = LTConfig.MessageConfig
local SCENE_PREFAB_PATH = "Res/MiniGame/Prefab/FishingGame/FishingGameSceneNode.prefab"

FishingGame.SetSceneOtherNodesVisible = function(self, isVisible)
	self.SetPlayerUnitVisible(self, isVisible)
	FishingGame.base.SetSceneOtherNodesVisible(self, isVisible)
end

FishingGame.Initialize = function(self, args)
	self.args = args
	self.taskId = args.taskId
	self.npcId = args.npcId
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.isQuestMode = args.isQuestMode or false
	self.entityInstanceId = args.entityInstanceId or 0
	self.maxFailCount = args.maxFailCount or 0
	self.spotId = args.spotId or 0

	self:SetSceneOtherNodesVisible(false)
	self:InitUI()
	self:PrepareSpotAndInitScene()
end

FishingGame.PrepareSpotAndInitScene = function(self)
	if self.spotId ~= 0 then
		self.CleanGame(self)

		return
	end

	slot1 = gFishingGameManager

	slot1:RequestSpotFullSync(self.spotId, function (err, pool)
		if self.hasDestroy then
			return
		end

		if err == MessageConfig.Ok then
			self:CleanGame()

			return
		end

		if not pool then
			self:CleanGame()

			return
		end

		if (pool.poolCount or 0) ~= 0 then
			self:CleanGame()

			return
		end

		gFishingGameManager:StartPolling(self.spotId)
		self:InitScene()
	end)
end

FishingGame.InitScene = function(self)
	self:ShowEmptyFullScreenPanel()

	slot1 = gResourceManager
	self.loadOp = slot1:LoadAssetWithCallBack(SCENE_PREFAB_PATH, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			return
		end

		local go = GameObject.Instantiate(loadOp.asset)
		self.sceneGo = go
		go.name = "Fishing"
		go.transform.position = self.wayPointPosition
		go.transform.rotation = Quaternion.identity

		go:SetActive(true)
		self:SetActiveEmptyFullScreenPanel(false)
		gStoreManager:InvokeStoreMethod("FishingGameMainPanelStore", "NotifyLoaded")
	end)
end

FishingGame.InitUI = function(self)
	gPanelManager:CheckShow(gPanelId.MINI_GAMES_FISHING_GAME_PANEL, {
		isQuestMode = self.isQuestMode,
		entityInstanceId = self.entityInstanceId,
		spotId = self.spotId,
		maxFailCount = self.maxFailCount
	})

	if self.isQuestMode then
		gPanelManager:CheckShow(gPanelId.S_NORMAL_TASK_NOTICE)
	end
end

FishingGame.CleanGame = function(self)
	if gFishingGameManager then
		gFishingGameManager:StopPolling()
	end

	self.SetSceneOtherNodesVisible(self, true)
	self.CleanSceneObjects(self)
	self.ClosePanels(self)
end

FishingGame.ForceExit = function(self)
	self.CleanGame(self)
end

FishingGame.CleanSceneObjects = function(self)
	local _ = gClientUtils.NotNil(self.sceneGo) and GameObject.Destroy(self.sceneGo)
	self.loadOp = gResourceManager:UnloadAssetLoadOp(self.loadOp)
	self.sceneGo = nil
end

FishingGame.ClosePanels = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.MINI_GAMES_FISHING_GAME_PANEL) then
		gPanelManager:Destroy(gPanelId.MINI_GAMES_FISHING_GAME_PANEL)
	end

	if gPanelManager:IsPanelShowing(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL) then
		gPanelManager:Destroy(gPanelId.MINI_GAMES_FISHING_RESULT_PANEL)
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_EMPTY_FULL_SCREEN_PANEL) then
		gPanelManager:Destroy(gPanelId.S_EMPTY_FULL_SCREEN_PANEL)
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_NORMAL_TASK_NOTICE) then
		gPanelManager:Destroy(gPanelId.S_NORMAL_TASK_NOTICE)
	end
end
