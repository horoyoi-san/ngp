-- Original chunk: @Lua\LuaFiles\LX6\Manager\MiniGame\DartsGameManager.lua
-- Decompiled from: 00611_DartsGameManager.lua_01fa7a48e9dc.luajit

C_DartsGameManager = DefClass("C_DartsGameManager", C_DartsGameManager)
local DartsGameManager = C_DartsGameManager

DartsGameManager.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self.OnAfterSwitchScene)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.OnBeforeSwitchScene)
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
		["F\\x87\\x87\\x97D"] = "\\x8f\\xf9nd^QaDZ$\\xbah\\xa8v0",
		["\\x8c\\xb0\\xaeZ2\\xff*"] = "\\xa0xe"
	}
end

DartsGameManager.CreateGame = function(self, args)
	if gLinkManager:CheckInLinkMode() then
		self.currentDartsGame = gDartsGameOnline.new(args)
		self._dart_gadgetId = self.currentDartsGame.slotEntity.entityInstanceId

		return
	end

	self.currentDartsGame = gDartsGame.new(args)
	self._dart_gadgetId = self.currentDartsGame.slotEntity.entityInstanceId
end

DartsGameManager.StartSingleDartGame = function(self, gadgetEntity, uiParams)
	uiParams = uiParams or {}
	uiParams[3] = gadgetEntity

	self:CreateGame({
		slotEntity = gadgetEntity,
		aiConfigId = uiParams.aiConfigId,
		useSuit = uiParams.useSuit,
		onEndTlFinishHandler = uiParams.onEndTlFinishHandler,
		uiParams = uiParams
	})
end

DartsGameManager.SetAiConfig = function(self, aiconfig)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:SetAiConfig(aiconfig)
	end
end

DartsGameManager.OnBeforeSwitchScene = function(self, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType < gSwitchSceneType.Reconnect then
		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DestroyGame()

		gDartsGameManager.currentDartsGame = nil
	end
end

DartsGameManager.OnAfterSwitchScene = function(self, switchSceneEventParams)
end

DartsGameManager.DoDisplayAchievement = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:LookScreenBeforeSwitchPlayer()
	end
end

DartsGameManager.DoDisplayAchievementReady = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoBeforeDisplayAchievement()
	end
end

DartsGameManager.DoChangePlayer = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoChangePlayer()
	end
end

DartsGameManager.DoShotByEnemy = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoShootEventTimeline()
	end
end

DartsGameManager.DoRemoveFromTarget = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ClearAllDartsInTargetTimeline()
	end
end

DartsGameManager.DoMyTurnStart = function(self)
	if gDartsGameManager.currentDartsGame and gDartsGameManager.currentDartsGame.DoMyTurnStartTimeline then
		gDartsGameManager.currentDartsGame:DoMyTurnStartTimeline()
	end
end

DartsGameManager.DoReload = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoReloadDartTimeline()
	end
end

DartsGameManager.DestroyGame = function(self)
	if self.currentDartsGame == nil then
		local dartGame = self.currentDartsGame
		self.currentDartsGame = nil

		dartGame:DestroyGame()
	end

	if self._npc_DartGame_GameType == nil then
		self:_ClearInviteNpcDartGame()
	end

	if self._isMatchMode then
		self._rpcCache = {}
		self._isMatchMode = false
		self._canHandleRpc = false
	end
end

DartsGameManager.RetryPlay = function(self, args)
	self:DestroyGame()
	self:CreateGame(args)
end

DartsGameManager.GMFinishDartsGame = function(self, isSuccess)
	if self.currentDartsGame == nil then
		self.currentDartsGame:GameEnd(isSuccess)
	end
end

DartsGameManager.IsInviteNpc = function(self)
	return self._npc_DartGame_GameType == nil
end

DartsGameManager.InviteNpcDartGameSkipModeSelect = function(self, data)
	self._npc_DartGame_GameType = data.gameType
	self._dart_gadgetId = data.gadgetId
	self._npc_DartGame_Gadget = gGadgetManager:GetEntitySearchByInstanceId(data.gadgetId)
	local dartNpcConfigId = data.dartNpcConfigId
	self._dartNpcCfg = LTConfig.PoiGameDartNpcConfig.GetConfig(dartNpcConfigId)
	local aiConfigId = self._dartNpcCfg.DartAiId
	local agentId = LTConfig.PoiGameDartAIConfig.GetConfig(aiConfigId).AgentId[1]
	local pos = self._npc_DartGame_Gadget.gameObject.transform.position
	local eulerAngles = self._npc_DartGame_Gadget.gameObject.transform.eulerAngles

	local onEndTlFinishHandler = function(isSuccess)
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

	self:CreateGame({
		["\\xcc\\xc8.-\\xe5"] = false,
		slotEntity = self._npc_DartGame_Gadget,
		aiConfigId = aiConfigId,
		onEndTlFinishHandler = onEndTlFinishHandler,
		uiParams = panelParams
	})
end

DartsGameManager.InviteCultivationNpcDartGame = function(self, data)
	self._npc_DartGame_GameType = data.gameType
	self._dart_gadgetId = data.gadgetId
	self._npc_DartGame_Gadget = gGadgetManager:GetEntitySearchByInstanceId(data.gadgetId)

	if not data.cultivationNpcId then
		return
	end

	self._dartNpcCfg = self:_FindDartNpcCfg(data.cultivationNpcId)

	self:DoInviteNpcDartGame(nil, data.cultivationNpcId)
end

DartsGameManager.ReadyInviteNpcDartGame = function(self, eventId, data)
	self._isSkip = data.isSkip

	if self._isSkip then
		self:InviteNpcDartGameSkipModeSelect(data)

		return
	end

	local isCultivation = gTaskUtils:CheckIsInCultivation()

	if isCultivation then
		data.cultivationNpcId = gTaskUtils:GetRideCultivationId()

		self:InviteCultivationNpcDartGame(data)

		return
	end

	self._npc_DartGame_GameType = data.gameType
	self._dart_gadgetId = data.gadgetId
	self._npc_DartGame_Gadget = gGadgetManager:GetEntitySearchByInstanceId(data.gadgetId)
end

DartsGameManager.DoInviteNpcDartGame = function(self, eventId, curNpcId)
	local npcId = curNpcId
	self._dartNpcCfg = self:_FindDartNpcCfg(npcId)
	local DartAiId = self._dartNpcCfg.DartAiId
	local agentId = LTConfig.PoiGameDartAIConfig.GetConfig(DartAiId).AgentId
	local FightSpiritID = LTConfig.NpcCultivationConfig.GetConfig(npcId).FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(FightSpiritID).Callback = function (err, list)
		if err == LTConfig.MessageConfig.Ok then
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
			data.pos = self._npc_DartGame_Gadget.gameObject.transform.localPosition
			data.rot = self._npc_DartGame_Gadget.gameObject.transform.localRotation.eulerAngles

			data.onFinishCallback = function(t)
				gDartsGameManager:OnTimeLineEnd(self.curSuit, agentId[1], position)
			end

			data.dynamicPersonalityTypes = {
				self._dartNpcCfg.Personality
			}
			local dialogIds = LTConfig.NpcCultivationConfig.GetConfig(npcId).EnterTimelineDialog
			data.dynamicDialogIds = {
				dialogIds
			}

			if gLinkManager:CheckInLinkMode() then
				data.linkType = 5
			end

			gCS.LuaUtils.TryAttachMainPlayerMover(data)
			gTimelineManager:Timeline_LoadAndPlay(startTl, data)
		end
	end
end

DartsGameManager.OnTimeLineEnd = function(self, suit, agentId, pos)
	suit = suit or 0
	local GameStage = gLuaDataManager.gameStage

	if GameStage == gGFConstant.GameStage.GameScene then
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

	local onEndTlFinishHandler = function(isSuccess)
		if isSuccess then
			self:_OnDartGameWinWithNpc(suit, agentId, pos)
		else
			self:_OnDartGameFailWithNpc(suit, agentId, pos)
		end
	end

	panelParams.onEndTlFinishHandler = onEndTlFinishHandler
	panelParams.useSuit = true
	panelParams[3] = self._npc_DartGame_Gadget

	self:CreateGame({
		["\\xcc\\xc8.-\\xe5"] = true,
		slotEntity = self._npc_DartGame_Gadget,
		aiConfigId = aiConfigId,
		onEndTlFinishHandler = onEndTlFinishHandler,
		uiParams = panelParams
	})
end

DartsGameManager._FindDartNpcCfg = function(self, npcId)
	local PoiGameDartNpcConfig = LTConfig.PoiGameDartNpcConfig

	for index = 0, PoiGameDartNpcConfig.count - 1 do
		local cfg = PoiGameDartNpcConfig.LoadAt(index)

		if cfg and cfg.NpcId ~= npcId then
			return cfg
		end
	end

	return nil
end

DartsGameManager._OnDartGameWinWithNpc = function(self, suit, agentId, pos)
	local winTl = LTConfig.PoiGameConfig.DartNpc_WinEndTL
	local bindInfos = {}
	self.finalUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, Vector3.zero, nil, suit)
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.finalUnit.Pid, self.TLActorName, nil)

	table.insert(bindInfos, c_bindInfo)

	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.bindUnitInfos = bindInfos
	data.pos = self._npc_DartGame_Gadget.gameObject.transform.localPosition
	data.rot = self._npc_DartGame_Gadget.gameObject.transform.localRotation.eulerAngles
	data.dynamicPersonalityTypes = {
		self._dartNpcCfg.Personality
	}
	local npcId = self._dartNpcCfg.Id
	local dialogIds = LTConfig.PoiGameDartNpcConfig.GetConfig(npcId).DartNpc_WinDialog
	data.dynamicDialogIds = {
		dialogIds
	}
	data.loadWithBlackScreen = true

	data.onFinishCallback = function(t)
		gCS.BaseUnitUtils.DestroyAgentUnit(self.finalUnit, true, true, false)

		self.finalUnit = nil
	end

	if gLinkManager:CheckInLinkMode() then
		data.linkType = 5
	end

	gCS.LuaUtils.TryAttachMainPlayerMover(data)
	gTimelineManager:Timeline_LoadAndPlay(winTl, data)
end

DartsGameManager._OnDartGameFailWithNpc = function(self, suit, agentId, pos, eulerAngles)
	local failTl = LTConfig.PoiGameConfig.DartNpc_FailEndTL
	local bindInfos = {}
	self.finalUnit = gCS.LuaUtils.CreateClientAgentByCfg(agentId, pos, Vector3.zero, nil, suit)
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.finalUnit.Pid, self.TLActorName, nil)

	table.insert(bindInfos, c_bindInfo)

	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.bindUnitInfos = bindInfos

	if self._npc_DartGame_Gadget.gameObject then
		data.pos = self._npc_DartGame_Gadget.gameObject.transform.localPosition
		data.rot = self._npc_DartGame_Gadget.gameObject.transform.localRotation.eulerAngles
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

	data.onFinishCallback = function(t)
		gCS.BaseUnitUtils.DestroyAgentUnit(self.finalUnit, true, true, false)

		self.finalUnit = nil
	end

	if gLinkManager:CheckInLinkMode() then
		data.linkType = 5
	end

	gCS.LuaUtils.TryAttachMainPlayerMover(data)
	gTimelineManager:Timeline_LoadAndPlay(failTl, data)
end

DartsGameManager._ClearInviteNpcDartGame = function(self)
	self._npc_DartGame_GameType = nil
	self._isSkip = false
end

DartsGameManager.ShowOrHideQuad = function(self, show)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ShowOrHideQuad(show)
	end
end

DartsGameManager.DoDisplayAchievementOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:LookScreenBeforeSwitchPlayer()
	end
end

DartsGameManager.DoDisplayAchievementReadyOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoBeforeDisplayAchievement()
	end
end

DartsGameManager.DoWaitForPlayerShootOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:WaitForPlayerShoot()
	end
end

DartsGameManager.DoChangePlayerOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoChangePlayer()
	end
end

DartsGameManager.DoShotOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoShootEventTimeline()
	end
end

DartsGameManager.DoRemoveFromPlayerOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:ClearAllDartsInTargetTimeline()
	end
end

DartsGameManager.DoPlayerTurnStartOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoPlayerTimeline()
	end
end

DartsGameManager.DoDartReloadOnLine = function(self)
	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:DoReloadDartTimeline()
	end
end

DartsGameManager.RequestServerStartDartsGame = function(self, gameType)
	gClientToGameSceneGMDelegate:GmStartDart(self._dart_gadgetId, gameType)
	print_debug("Dart: RequestServerStartDartsGame")
end

DartsGameManager.StartDartMatchMode = function(self, uid, zoneInfo)
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

DartsGameManager.LoadDartMatchGame = function(self, zoneInfo)
	local gadgetEntity = gGadgetManager:GetEntitySearchByInstanceId(zoneInfo.GadgetUId)
	local panelParams = {
		isSkip = true,
		zoneInfo = zoneInfo,
		[3] = gadgetEntity,
		useSuit = false
	}

	self:CreateGame({
		slotEntity = gadgetEntity,
		zoneInfo = zoneInfo,
		onInitFinish = function ()
			gDartsGameManager:OnDartMatchGameInit()
		end,
		uiParams = panelParams
	})
	print_debug("Dart: OnMatchGameLoad ", zoneInfo)
end

DartsGameManager.OnDartMatchGameInit = function(self)
	local rpcCache = self._rpcCache
	self._rpcCache = {}
	self._canHandleRpc = true

	print_debug("Dart: OnMatchGameInit ")

	for _, v in ipairs(rpcCache) do
		v[1](gDartsGameManager, v[2], v[3])
	end
end

DartsGameManager.TryHandleRpcInMatchMode = function(self, rpcInfo)
	if self._canHandleRpc then
		local v = rpcInfo

		v[1](gDartsGameManager, v[2], v[3])

		return
	end

	table.insert(self._rpcCache, rpcInfo)
end

DartsGameManager.OnSyncZoneInfo = function(self, uid, zoneInfo, fromRpc)
	print_debug("Dart: Receive OnSyncZoneInfo ", zoneInfo)

	if fromRpc and zoneInfo.StartReason ~= UX.Game.GameGroundZoneStartReason.Match then
		if zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.Enter then
			self:StartDartMatchMode(uid, zoneInfo)

			return
		elseif zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.ReEnter then
			if not gDartsGameManager.currentDartsGame then
				print_error("Dart: Reconnect, but currentDartsGame is nil")

				return
			end

			gDartsGameManager.currentDartsGame:OnReconnectSync(zoneInfo)

			return
		elseif zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.ReEnterLogin then
			return
		elseif zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.Prepare then
			return
		elseif zoneInfo.SyncReason ~= UX.Game.GameGroundZoneSyncReason.RePrepare then
			self:StartDartMatchMode(uid, zoneInfo)

			return
		end
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

DartsGameManager.OnServerEnterRoom = function(self, uid, playerInfo)
	if self._isMatchMode and not self._canHandleRpc then
		local rpcInfo = {
			self.OnServerEnterRoom,
			uid,
			playerInfo
		}

		self:TryHandleRpcInMatchMode(rpcInfo)

		return
	end

	if uid == self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	if gDartsGameManager.currentDartsGame then
		gDartsGameManager.currentDartsGame:OnServerEnterRoom(playerInfo)
		print_debug("Dart: JoinRoom ", playerInfo)

		if playerInfo.DartId and playerInfo.DartId == 0 then
			print_debug("Dart: SelectDart ", playerInfo)
			gDartsGameManager.currentDartsGame:OnParticipantSelectDart(playerInfo)

			return
		end
	end
end

DartsGameManager.NotifyServerSelectDart = function(self, dartCfgId)
	self:SendDartRpc("RecordDartId", function ()
		return gClientToGameSceneDelegate:RecordDartId(dartCfgId)
	end)
	print_debug("Dart: SelectDart,Wait Resource Loaded")
end

DartsGameManager.OnParticipantSelectDart = function(self, uid, playerInfo)
	if uid == self._dart_gadgetId then
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

DartsGameManager.NotifyServerReady = function(self)
	self:SendDartRpc("SetGameGroundPlayerReady", function ()
		return gClientToGameSceneDelegate:SetGameGroundPlayerReady(true)
	end)
	print_debug("Dart: Game Ready ")
end

DartsGameManager.NotifyServerScore = function(self, score, pos)
	local uxPos = UX.Game.UXVector3.New(pos.x, pos.y, pos.z)

	self:SendDartRpc("RecordDartScore", function ()
		return gClientToGameSceneDelegate:RecordDartScore(score, uxPos)
	end)
	print_debug("Dart: Notify Server Score ", score, pos)
end

DartsGameManager.OnSyncDartScoreInfo = function(self, uid, scoreInfo)
	if uid == self._dart_gadgetId then
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

DartsGameManager.OnGameStateChange = function(self, uid, state)
	if uid == self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	print_debug("Dart: Game State ", state)

	if state ~= UX.Game.GameGroundZoneState.GameStart then
		if gDartsGameManager.currentDartsGame then
			gDartsGameManager.currentDartsGame:OnBattleStart()
			print_debug("Dart: GameStart ", state)
		end
	elseif state ~= UX.Game.GameGroundZoneState.GameOver then
		self:DestroyGame()
	end
end

DartsGameManager.OnSyncZoneTurnChange = function(self, uid, currentRound, currentTurn)
	if uid == self._dart_gadgetId then
		return
	end

	if not gDartsGameManager.currentDartsGame then
		return
	end

	gDartsGameManager.currentDartsGame:OnZoneTurnChange(currentRound, currentTurn)
	print_debug("Dart: ZoneTurnChange ", currentRound, currentTurn)
end

local DART_RPC_RETRY_INTERVAL = 0.2
local DART_RPC_MAX_WAIT_TIME = 15

DartsGameManager.SendDartRpc = function(self, rpcName, rpcFunc, onSuccess, onFail)
	if gLuaDataManager.isNetworkAvailable and gCS.NetworkManager.Instance:IsServerConnected() then
		local task = rpcFunc()

		if task then
			task.Callback = function(err, ...)
				if err ~= LTConfig.MessageConfig.Ok then
					if onSuccess then
						onSuccess(...)
					end
				else
					print_error("Dart RPC failed: ", rpcName, " err:", err)

					if onFail then
						onFail(err)
					end
				end
			end
		end

		print_debug("Dart: SendRpc direct - ", rpcName)

		return
	end

	print_debug("Dart: SendRpc waiting network - ", rpcName)
	gCoroutineManager:StartCoroutine(function ()
		local waitTime = 0

		while not gLuaDataManager.isNetworkAvailable or not gCS.NetworkManager.Instance:IsServerConnected() do
			if gLuaDataManager.gameStage == gGFConstant.GameStage.GameScene or not self.currentDartsGame then
				print_debug("Dart: SendRpc aborted - ", rpcName)

				if onFail then
					onFail(-1)
				end

				return
			end

			if DART_RPC_MAX_WAIT_TIME < waitTime then
				print_error("Dart: SendRpc timeout - ", rpcName, " waited:", waitTime, "s")

				if onFail then
					onFail(-2)
				end

				return
			end

			coroutine.wait(DART_RPC_RETRY_INTERVAL)

			waitTime = waitTime + DART_RPC_RETRY_INTERVAL
		end

		if not self.currentDartsGame then
			print_debug("Dart: SendRpc aborted after reconnect - ", rpcName)

			if onFail then
				onFail(-1)
			end

			return
		end

		local task = rpcFunc()

		if task then
			task.Callback = function(err, ...)
				if err ~= LTConfig.MessageConfig.Ok then
					if onSuccess then
						onSuccess(...)
					end
				else
					print_error("Dart RPC failed after reconnect: ", rpcName, " err:", err)

					if onFail then
						onFail(err)
					end
				end
			end
		end

		print_debug("Dart: SendRpc after reconnect - ", rpcName)
	end)
end

gDartsGameManager = gDartsGameManager or C_DartsGameManager.new()
