C_DartsGameManager = DefClass("C_DartsGameManager", C_DartsGameManager)
local DartsGameManager = C_DartsGameManager

function DartsGameManager:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self.OnAfterSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.ON_POI_GAME_CHANGE_PLAYER, self.DoChangePlayer)
	gMessageManager:AddMessageListener(gEventConstants.ENEMY_DO_SHOT, self.DoShotByEnemy)
	gMessageManager:AddMessageListener(gEventConstants.REMOVEDART_FROM_TARGET, self.DoRemoveFromTarget)
	gMessageManager:AddMessageListener(gEventConstants.ON_MY_TURN_START, self.DoMyTurnStart)
	gMessageManager:AddMessageListener(gEventConstants.DO_RELOAD_DART, self.DoReload)
	gMessageManager:AddMessageListener(gEventConstants.DO_DISPLAY_ACH, self.DoDisplayAchievement)
	gMessageManager:AddMessageListener(gEventConstants.DO_DISPLAY_ACHIEVEMENT_READY, self.DoDisplayAchievementReady)
	gMessageManager:AddMessageListener(gEventConstants.ON_DART_GAME_CHANGE_PLAYER, self.DoChangePlayerOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_DO_SHOT, self.DoShotOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_REMOVE_DART_FROM_PLAYER, self.DoRemoveFromPlayerOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_PLAYER_TURN_START, self.DoPlayerTurnStartOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_RELOAD_DART, self.DoDartReloadOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_DO_DISPLAY_ACH, self.DoDisplayAchievementOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_DO_DISPLAY_ACHIEVEMENT_READY, self.DoDisplayAchievementReadyOnLine)
	gMessageManager:AddMessageListener(gEventConstants.ON_WAIT_FOR_PLAYER_SHOOT_COMMAND, self.DoWaitForPlayerShootOnLine)
	gMessageManager:AddMessageListener(gEventConstants.READY_INVITE_NPC_DART_GAME, function (eventId, data)
		gDartsGameManager:ReadyInviteNpcDartGame(eventId, data)
	end)
	gMessageManager:AddMessageListener(gEventConstants.DO_INVITE_NPC_DART_GAME, function (eventId, data)
		gDartsGameManager:DoInviteNpcDartGame(eventId, data)
	end)

	self._npc_DartGame_Gadget = nil
	self._npc_DartGame_GameType = nil
	self._dartNpcCfg = nil
	self._isSkip = false
	self.TLActorName = LTConfig.PoiGameConfig.DartNpc_TLActorName
	self._isOnLine = false
	self._isMatchMode = false
	self._rpcCache = {}
	self._canHandleRpc = false
	self.srcModelDict = {
		invite = "飞镖邀约角色",
		GamePlay = "Npc"
	}
end

function DartsGameManager:CreateGame(args)
	if gLinkManager:CheckInLinkMode() then
		self.currentDartsGame = gDartsGameOnline.new(args)
		self._dart_gadgetId = self.currentDartsGame.slotEntity.entityInstanceId

		return
	end

	self.currentDartsGame = gDartsGame.new(args)
	self._dart_gadgetId = self.currentDartsGame.slotEntity.entityInstanceId
end

function DartsGameManager:SetAiConfig(aiconfig)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:SetAiConfig(aiconfig)
	end
end

function DartsGameManager:OnBeforeSwitchScene(switchType)
	if switchType <= gSwitchSceneType.Reconnect then
		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DestroyGame()

		gDartsGameManager.currentDartsGame = nil
	end
end

function DartsGameManager:OnAfterSwitchScene(switchType)
	return
end

function DartsGameManager:DoDisplayAchievement()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:LookScreenBeforeSwitchPlayer()
	end
end

function DartsGameManager:DoDisplayAchievementReady()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoBeforeDisplayAchievement()
	end
end

function DartsGameManager:DoChangePlayer()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoChangePlayer()
	end
end

function DartsGameManager:DoShotByEnemy()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoShootEventTimeline()
	end
end

function DartsGameManager:DoRemoveFromTarget()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ClearAllDartsInTargetTimeline()
	end
end

function DartsGameManager:DoMyTurnStart()
	if gDartsGameManager.currentDartsGame and gDartsGameManager.currentDartsGame.DoMyTurnStartTimeline then
		gDartsGameManager.currentDartsGame:DoMyTurnStartTimeline()
	end
end

function DartsGameManager:DoReload()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoReloadDartTimeline()
	end
end

function DartsGameManager:DestroyGame()
	if self.currentDartsGame ~= nil then
		local dartGame = self.currentDartsGame
		self.currentDartsGame = nil

		dartGame:DestroyGame()
	end

	if self._npc_DartGame_GameType ~= nil then
		self:_ClearInviteNpcDartGame()
	end

	if self._isMatchMode then
		self._rpcCache = {}
		self._isMatchMode = false
		self._canHandleRpc = false
	end
end

function DartsGameManager:RetryPlay(args)
	self:DestroyGame()
	self:CreateGame(args)
end

function DartsGameManager:GMFinishDartsGame(isSuccess)
	if self.currentDartsGame ~= nil then
		self.currentDartsGame:GameEnd(isSuccess)
	end
end

function DartsGameManager:IsInviteNpc()
	return self._npc_DartGame_GameType ~= nil
end

function DartsGameManager:InviteNpcDartGameSkipModeSelect(data)
	self._npc_DartGame_GameType = data.gameType
	self._dart_gadgetId = data.gadgetId
	self._npc_DartGame_Gadget = gGadgetManager:GetEntitySearchByInstanceId(data.gadgetId)
	local dartNpcConfigId = data.dartNpcConfigId
	self._dartNpcCfg = LTConfig.PoiGameDartNpcConfig.GetConfig(dartNpcConfigId)
	local aiConfigId = self._dartNpcCfg.DartAiId
	local agentId = LTConfig.PoiGameDartAIConfig.GetConfig(aiConfigId).AgentId[1]
	local pos = self._npc_DartGame_Gadget.gameObject.transform.position
	local eulerAngles = self._npc_DartGame_Gadget.gameObject.transform.eulerAngles

	local function onEndTlFinishHandler(isSuccess)
		if isSuccess then
			self:_OnDartGameWinWithNpc(0, agentId, pos, eulerAngles)
		else
			self:_OnDartGameFailWithNpc(0, agentId, pos, eulerAngles)
		end
	end

	local panelParams = {
		isSkip = true,
		gameMode = data.gameMode,
		x01Score = data.x01Score,
		aiConfigId = aiConfigId,
		onEndTlFinishHandler = onEndTlFinishHandler,
		[3] = self._npc_DartGame_Gadget,
		useSuit = false
	}

	gPanelManager:CheckShow(gPanelId.S_DART_HARD_LEVEL_SELECT, panelParams)
end

function DartsGameManager:ReadyInviteNpcDartGame(eventId, data)
	self._isSkip = data.isSkip

	if self._isSkip then
		self:InviteNpcDartGameSkipModeSelect(data)

		return
	end

	self._npc_DartGame_GameType = data.gameType
	self._dart_gadgetId = data.gadgetId
	self._npc_DartGame_Gadget = gGadgetManager:GetEntitySearchByInstanceId(data.gadgetId)
end

function DartsGameManager:DoInviteNpcDartGame(eventId, curNpcId)
	local npcId = curNpcId
	self._dartNpcCfg = self:_FindDartNpcCfg(npcId)
	local DartAiId = self._dartNpcCfg.DartAiId
	local agentId = LTConfig.PoiGameDartAIConfig.GetConfig(DartAiId).AgentId
	local FightSpiritID = LTConfig.NpcCultivationConfig.GetConfig(npcId).FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(FightSpiritID).Callback = function (err, list)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		else
			local me = gCS.MyPlayerManager.PlayerUnit
			local position = Vector3.New(me.LocalPosition.x, me.LocalPosition.y, me.LocalPosition.z)
			self.curSuit = list
			self.curInviteNpc = gCS.LuaUtils.CreateClientAgentByCfg(agentId[1], position, Vector3.zero, nil, self.curSuit)
			local startTl = LTConfig.PoiGameConfig.DartNpc_StartTL
			local bindInfos = {}
			local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.curInviteNpc.Pid, self.TLActorName, nil)

			table.insert(bindInfos, c_bindInfo)

			local data = gTimelineManager:Timeline_CreateTimelineData()
			data.bindUnitInfos = bindInfos
			data.pos = self._npc_DartGame_Gadget.gameObject.transform.position
			data.rot = self._npc_DartGame_Gadget.gameObject.transform.eulerAngles

			function data.onFinishCb()
				gDartsGameManager:OnTimeLineEnd(self.curSuit, agentId[1], position)
			end

			data.dynamicPersonalityTypes = {
				self._dartNpcCfg.Personality
			}
			local dialogIds = LTConfig.PoiGameDartNpcConfig.GetConfig(self._dartNpcCfg.Id).DartNpc_StartDialog
			data.dynamicDialogIds = {
				dialogIds
			}

			gTimelineManager:Timeline_LoadAndPlay(startTl, data)
		end
	end
end

function DartsGameManager:OnTimeLineEnd(suit, agentId, pos)
	suit = suit or 0
	local GameStage = gLuaDataManager.gameStage

	if GameStage ~= gGFConstant.GameStage.GameScene then
		return
	end

	if self.curInviteNpc then
		gCS.BaseUnitUtils.DestroyAgentUnit(self.curInviteNpc, true, true, false)

		self.curInviteNpc = nil
	end

	local aiConfigId = self._dartNpcCfg.DartAiId
	local panelParams = {
		playType = gDart3DMainPageType.Choice,
		aiConfigId = aiConfigId
	}

	local function onEndTlFinishHandler(isSuccess)
		if isSuccess then
			self:_OnDartGameWinWithNpc(suit, agentId, pos)
		else
			self:_OnDartGameFailWithNpc(suit, agentId, pos)
		end
	end

	panelParams.onEndTlFinishHandler = onEndTlFinishHandler
	panelParams.useSuit = true
	panelParams[3] = self._npc_DartGame_Gadget

	gPanelManager:CheckShow(gPanelId.S_DART_HARD_LEVEL_SELECT, panelParams)
end

function DartsGameManager:_FindDartNpcCfg(npcId)
	local PoiGameDartNpcConfig = LTConfig.PoiGameDartNpcConfig

	for index = 0, PoiGameDartNpcConfig.count - 1 do
		local cfg = PoiGameDartNpcConfig.LoadAt(index)

		if cfg and cfg.NpcId == npcId then
			return cfg
		end
	end

	return nil
end

function DartsGameManager:_OnDartGameWinWithNpc(suit, agentId, pos)
	local winTl = LTConfig.PoiGameConfig.DartNpc_WinEndTL
	local bindInfos = {}
	self.finalUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, Vector3.zero, nil, suit)
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.finalUnit.Pid, self.TLActorName, nil)

	table.insert(bindInfos, c_bindInfo)

	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.bindUnitInfos = bindInfos
	data.pos = self._npc_DartGame_Gadget.gameObject.transform.position
	data.rot = self._npc_DartGame_Gadget.gameObject.transform.eulerAngles
	data.dynamicPersonalityTypes = {
		self._dartNpcCfg.Personality
	}
	local npcId = self._dartNpcCfg.Id
	local dialogIds = LTConfig.PoiGameDartNpcConfig.GetConfig(npcId).DartNpc_WinDialog
	data.dynamicDialogIds = {
		dialogIds
	}
	data.loadWithBlackScreen = true

	function data.onFinishCb()
		gCS.BaseUnitUtils.DestroyAgentUnit(self.finalUnit, true, true, false)

		self.finalUnit = nil
	end

	gTimelineManager:Timeline_LoadAndPlay(winTl, data)
end

function DartsGameManager:_OnDartGameFailWithNpc(suit, agentId, pos, eulerAngles)
	local failTl = LTConfig.PoiGameConfig.DartNpc_FailEndTL
	local bindInfos = {}
	self.finalUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, Vector3.zero, nil, suit)
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.finalUnit.Pid, self.TLActorName, nil)

	table.insert(bindInfos, c_bindInfo)

	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.bindUnitInfos = bindInfos

	if self._npc_DartGame_Gadget.gameObject then
		data.pos = self._npc_DartGame_Gadget.gameObject.transform.position
		data.rot = self._npc_DartGame_Gadget.gameObject.transform.eulerAngles
	elseif pos and eulerAngles then
		data.pos = pos
		data.rot = eulerAngles
	end

	data.dynamicPersonalityTypes = {
		self._dartNpcCfg.Personality
	}
	local npcId = self._dartNpcCfg.Id
	local dialogIds = LTConfig.PoiGameDartNpcConfig.GetConfig(npcId).DartNpc_FailDialog
	data.dynamicDialogIds = {
		dialogIds
	}
	data.loadWithBlackScreen = true

	function data.onFinishCb()
		gCS.BaseUnitUtils.DestroyAgentUnit(self.finalUnit, true, true, false)

		self.finalUnit = nil
	end

	gTimelineManager:Timeline_LoadAndPlay(failTl, data)
end

function DartsGameManager:_ClearInviteNpcDartGame()
	self._npc_DartGame_GameType = nil
	self._isSkip = false
end

function DartsGameManager:ShowOrHideQuad(show)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ShowOrHideQuad(show)
	end
end

function DartsGameManager:DoDisplayAchievementOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:LookScreenBeforeSwitchPlayer()
	end
end

function DartsGameManager:DoDisplayAchievementReadyOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoBeforeDisplayAchievement()
	end
end

function DartsGameManager:DoWaitForPlayerShootOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:WaitForPlayerShoot()
	end
end

function DartsGameManager:DoChangePlayerOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoChangePlayer()
	end
end

function DartsGameManager:DoShotOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoShootEventTimeline()
	end
end

function DartsGameManager:DoRemoveFromPlayerOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ClearAllDartsInTargetTimeline()
	end
end

function DartsGameManager:DoPlayerTurnStartOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoPlayerTimeline()
	end
end

function DartsGameManager:DoDartReloadOnLine()
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoReloadDartTimeline()
	end
end

function DartsGameManager:RequestServerStartDartsGame(gameType)
	gClientToGameSceneGMDelegate:GmStartDart(self._dart_gadgetId, gameType)
	print_debug("Dart: RequestServerStartDartsGame")
end

function DartsGameManager:StartDartMatchMode(uid, zoneInfo)
	self._isMatchMode = true
	self._rpcCache = {}
	self._canHandleRpc = false

	print_debug("Dart: StartDartMatchMode ", zoneInfo)

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager:DestroyGame()
	end

	local rpcInfo = {
		self.OnSyncZoneInfo,
		uid,
		zoneInfo
	}

	self:TryHandleRpcInMatchMode(rpcInfo)

	local gadgetEntity = gGadgetManager:GetEntitySearchByInstanceId(zoneInfo.GadgetUId)

	if not gadgetEntity then
		print_debug("Dart: WaitGadgedLoad ", zoneInfo)

		local t = {
			zoneInfo.GadgetUId
		}

		L50.L50App.Scene.SpoonGadgetManager:RegisterWaitLoad(t, function (_)
			self:LoadDartMatchGame(zoneInfo)
		end)

		return
	end

	self:LoadDartMatchGame(zoneInfo)
end

function DartsGameManager:LoadDartMatchGame(zoneInfo)
	local panelParams = {
		isSkip = true,
		zoneInfo = zoneInfo,
		onInitFinish = function ()
			gDartsGameManager:OnDartMatchGameInit()
		end
	}
	local gadgetEntity = gGadgetManager:GetEntitySearchByInstanceId(zoneInfo.GadgetUId)
	panelParams[3] = gadgetEntity
	panelParams.useSuit = false

	gPanelManager:CheckShow(gPanelId.S_DART_HARD_LEVEL_SELECT, panelParams)
	print_debug("Dart: OnMatchGameLoad ", zoneInfo)
end

function DartsGameManager:OnDartMatchGameInit()
	local rpcCache = self._rpcCache
	self._rpcCache = {}
	self._canHandleRpc = true

	print_debug("Dart: OnMatchGameInit ")

	for _, v in ipairs(rpcCache) do
		v[1](gDartsGameManager, v[2], v[3])
	end
end

function DartsGameManager:TryHandleRpcInMatchMode(rpcInfo)
	if self._canHandleRpc then
		local v = rpcInfo

		v[1](gDartsGameManager, v[2], v[3])

		return
	end

	table.insert(self._rpcCache, rpcInfo)
end

function DartsGameManager:OnSyncZoneInfo(uid, zoneInfo, fromRpc)
	print_debug("Dart: Receive OnSyncZoneInfo ", zoneInfo)

	if fromRpc and zoneInfo.StartReason == UX.Game.GameGroundZoneStartReason.Match and (zoneInfo.SyncReason == UX.Game.GameGroundZoneSyncReason.Enter or zoneInfo.SyncReason == UX.Game.GameGroundZoneSyncReason.ReEnter) then
		self:StartDartMatchMode(uid, zoneInfo)

		return
	end

	if self._isMatchMode and not self._canHandleRpc then
		local rpcInfo = {
			self.OnSyncZoneInfo,
			uid,
			zoneInfo
		}

		self:TryHandleRpcInMatchMode(rpcInfo)

		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	gDartsGameManager.currentDartsGame:OnSyncZoneInfo(zoneInfo)
	print_debug("Dart: OnSyncZoneInfo ", zoneInfo)
end

function DartsGameManager:OnServerEnterRoom(uid, playerInfo)
	if self._isMatchMode and not self._canHandleRpc then
		local rpcInfo = {
			self.OnServerEnterRoom,
			uid,
			playerInfo
		}

		self:TryHandleRpcInMatchMode(rpcInfo)

		return
	end

	if uid ~= self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	if playerInfo.DartId and playerInfo.DartId ~= 0 then
		print_debug("Dart: SelectDart ", playerInfo)
		gDartsGameManager.currentDartsGame:OnParticipantSelectDart(playerInfo)

		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:OnServerEnterRoom(playerInfo)
		print_debug("Dart: JoinRoom ", playerInfo)
	end
end

function DartsGameManager:NotifyServerSelectDart(dartCfgId)
	gClientToGameSceneDelegate:RecordDartId(dartCfgId).Callback = function (err)
		return
	end

	print_debug("Dart: SelectDart,Wait Resource Loaded")
end

function DartsGameManager:OnParticipantSelectDart(uid, playerInfo)
	if uid ~= self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:OnParticipantSelectDart(playerInfo)
		print_debug("Dart: Participant Select Dart ", playerInfo)
	end
end

function DartsGameManager:NotifyServerReady()
	gClientToGameSceneDelegate:SetGameGroundPlayerReady(true).Callback = function (err)
		return
	end

	print_debug("Dart: Game Ready ")
end

function DartsGameManager:NotifyServerScore(score, pos)
	local uxPos = UX.Game.UXVector3.New(pos.x, pos.y, pos.z)

	gClientToGameSceneDelegate:RecordDartScore(score, uxPos).Callback = function (err)
		return
	end

	print_debug("Dart: Notify Server Score ", score, pos)
end

function DartsGameManager:OnSyncDartScoreInfo(uid, scoreInfo)
	if uid ~= self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:OnSyncScoreInfo(scoreInfo)
		print_debug("Dart: OnSyncDartScoreInfo ", scoreInfo)
	end
end

function DartsGameManager:OnGameStateChange(uid, state)
	if uid ~= self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	print_debug("Dart: Game State ", state)

	if state == UX.Game.GameGroundZoneState.GameStart then
		if gDartsGameManager.currentDartsGame then
			gDartsGameManager.currentDartsGame:OnBattleStart()
			print_debug("Dart: GameStart ", state)
		end
	elseif state == UX.Game.GameGroundZoneState.GameOver then
		-- Nothing
	end
end

gDartsGameManager = gDartsGameManager or C_DartsGameManager.new()
