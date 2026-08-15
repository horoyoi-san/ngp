gDartsGameOnline = DefClass("DartsGameOnline", gDartsGameOnline)
local M = gDartsGameOnline
local LayerConstants = LX6.Constants.LayerConstants
local PoiGameDartConfig = LTConfig.PoiGameDartConfig
local UnitModelManager = LX6.Units.UnitModelManager
local GeneralModelConfig = LTConfig.GeneralModelConfig
local AgentConfig = LTConfig.AgentConfig
M.DartsGameMode = {
	X01 = 2,
	HIGH_SCORE = 1
}
M.DartsGameModeDetailType = {
	P701 = 4,
	HIGH_SCORE = 1,
	P301 = 2,
	P501 = 3
}
M.CameraStatus = {
	SelectDart = 3,
	BackClose = 1,
	WatchScreen = 2
}
M.BodyType = {
	nil,
	3,
	5,
	1,
	2,
	4
}
M.TurnAchievement = {
	HighTon = 7,
	NiceOne = 3,
	Bust = 5,
	Ton80 = 8,
	HatTrick = 2,
	LowTon = 4,
	ThreeInTheBlack = 6,
	Normal = 1
}
M.ViewType = {
	Observer = 2,
	player = 1
}
M.PlayerType = {
	Me = 1,
	Player = 2,
	Npc = 3
}

function M:ctor(args)
	self.args = args
	self.taskId = args.taskId
	self.timelineName = "Gameplay_Dart_Online"
	self.slotEntity = args.slotEntity
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.onInitFinish = args.onInitFinish
	self.player1 = nil
	self.player2 = nil
	self.currentUsingDartId = 0
	self.uiScale = Vector3.New(0.69, 0.69, 0.69)
	self.goal = 0
	self.isDestroy = false
	self.isGameEnd = false
	self.isStartBattle = false
	self.doStartFlyFunc = nil
	self.playMode = 2
	self.targetScore = 301
	self.playModeDetail = 0
	self.roundCount = 15
	self.aiConfigId = 0
	self.playerList = {}
	self.currentFireCount = 0
	self.currentTurnPoints = nil
	self.meIndex = 0
	self.opponentIndex = 0
	self.currentIndex = 0
	self.currentPlayer = nil
	self.currentPlayerInfo = nil
	self.currentShootingDart = nil
	self.nextDart = nil
	self.nextShotWhileEndTurn = false
	self.waitOpponentScoreSync = false
	self.totalBurstCount = nil
	self.selectDarts = {}
	self.coList = {}
	self.gameEndCo = nil
	self.currentCamera = nil
	self.nextCamera = nil
	self.isFadingCamera = false
	self.cameraSwitchQueue = {}
	self.onEndTlFinishHandler = nil
	self.gameMainPageStore = nil
	self.loadedTimeline = nil
	self.dartsSceneNodeGo = nil
	self.player2_InitPos = nil
	self.player1_InitPos = nil
	self.targetCenterTransform = nil
	self.lookAtPointTransform = nil
	self.effectNode = nil
	self.quad = nil
	self.hitEffects = nil
	self.effectHitActiveNode = nil
	self.dartsSelectNode = nil
	self.virtualList = nil
	self.cinemachineLuaHandler = nil
	self.screenCenter = nil
	self.targetViewTransform = nil
	self.achievementList = nil
	self.isRealCanShot = false
	self.isBustWaitEnd = false
	self.meViewType = args.viewType or self.ViewType.player
	self.dartsSceneNodeOp = nil
	self.dartHitEffectNodesOp = nil
	self.dartsLoadOps = {}

	self:Initialize()
end

function M:Initialize()
	if self.meViewType ~= self.ViewType.Observer then
		self.gameMainPageStore = gStoreManager:GetStoreGroup("S_Dart3D_MainPageStore")

		gSoundMgr:SetStateValue("StateGroup_Quest", "State_FeiBiao")
		gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.Dart)
		self:InitDartsScene()
	end
end

function M:InitDartsScene()
	local DartsSceneNodePath = "Res/MiniGame/Prefab/Dart/DartSceneNode.prefab"
	self.dartsSceneNodeOp = gResourceManager:LoadAssetWithCallBack(DartsSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.isDestroy then
			return
		end

		local dartsSceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
		self.dartsSceneNodeGo = dartsSceneNodeGo
		dartsSceneNodeGo.transform.position = Vector3.New(unpack(self.wayPointPosition))
		dartsSceneNodeGo.transform.rotation = Quaternion.New(unpack(self.wayPointRotation))
		dartsSceneNodeGo.gameObject.name = "DartsSceneNode"

		dartsSceneNodeGo.gameObject:SetActive(true)
		self.slotEntity.gameObject:SetActive(false)

		self.player2_InitPos = dartsSceneNodeGo.transform:Find("offset/enemyInitPos")
		self.player1_InitPos = dartsSceneNodeGo.transform:Find("offset/playerInitPos")
		self.targetCenterTransform = dartsSceneNodeGo.transform:Find("offset/targetCenterTransform")
		self.lookAtPointTransform = dartsSceneNodeGo.transform:Find("offset/targetCenterTransform/lookAtPoint")
		self.effectNode = dartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/hitEffects")
		self.quad = dartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/vx_Screen")
		self.dartHitEffectNodesOp = {}

		for i = 1, 7 do
			local DartsHitEffectSceneNodePath = "Res/MiniGame/Prefab/Dart/fx_gp_bazi0" .. i .. ".prefab"
			self.dartHitEffectNodesOp[i] = gResourceManager:LoadAssetWithCallBack(DartsHitEffectSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp2)
				if self.isDestroy then
					return
				end

				if self.hitEffects == nil then
					self.hitEffects = {}
				end

				local hitEffect = UnityEngine.GameObject.Instantiate(loadOp2.asset, self.effectNode.transform)
				self.hitEffects[i] = hitEffect
			end)
		end

		self.effectHitActiveNode = dartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/sc_fd_ty_jh_jifb01a_pm_pc")

		self:SetScreenShootAchievement(self.TurnAchievement.Normal)

		self.dartsSelectNode = dartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/DartPlate/DartHookNode")
		local virtualCameraNode = dartsSceneNodeGo.transform:Find("offset/cinemachineVCList")
		self.virtualList = {
			virtualCameraNode:Find("BackClose"),
			virtualCameraNode:Find("WatchScreen"),
			virtualCameraNode:Find("SelectDart")
		}
		self.cinemachineLuaHandler = virtualCameraNode:GetComponent(typeof(LX6.Cinemachine.CinemachineLuaHandler))
		self.cinemachineLuaHandler.onCameraInactive = self.OnVCamInactive
		self.screenCenter = dartsSceneNodeGo.transform:Find("offset/ScreenCenter")
		self.targetViewTransform = dartsSceneNodeGo.transform:Find("offset/TargetViewTransform")

		self:InitUI()

		if self.onInitFinish then
			self.onInitFinish()

			self.onInitFinish = nil
		end
	end)
end

function M:InitUI()
	gMessageManager:SendMessage(gEventConstants.DO_DART_SCENE_NODE_LOADED)
	self:SwitchCameraCondition(self.CameraStatus.WatchScreen)
end

function M:GetScreenUITransform()
	if self.screenCenter == nil then
		return
	end

	return self.screenCenter.transform
end

function M:GetScreenUIPosition()
	if self.screenCenter == nil then
		return
	end

	local x = 0
	local y = 0
	local z = 0
	x, y, z = gCS.LuaUtils.WorldToScreenPoint(self.screenCenter.transform.position, x, y, z)
	local rectPosition = gUtils:ScreenToUIPosition(Vector3.New(x, y, z))

	return rectPosition
end

function M:GetScreenRotation()
	local q = Quaternion.Inverse(gCS.CameraDataMgr.MainCamera.transform.rotation) * self.screenCenter.transform.rotation

	return q
end

function M:ShowOrHideQuad(show)
	if self.quad then
		self.quad.gameObject:SetActive(show)
	end
end

function M:ShowPanelByPanelId(panelId, prePanel)
	self.gameMainPageStore:ShowTabByPanelId(panelId, prePanel)
end

function M:BackPre()
	self.gameMainPageStore:BackPre()
end

function M:SetScreenShootAchievement(index)
	if self.achievementList == nil then
		self.achievementList = {
			self.effectHitActiveNode.transform:Find("vx_Normal"),
			self.effectHitActiveNode.transform:Find("vx_HatTrick"),
			self.effectHitActiveNode.transform:Find("vx_NiceOne"),
			self.effectHitActiveNode.transform:Find("vx_LowTon"),
			self.effectHitActiveNode.transform:Find("vx_Bust"),
			self.effectHitActiveNode.transform:Find("vx_ThreeInTheBlack"),
			self.effectHitActiveNode.transform:Find("vx_HighTon"),
			self.effectHitActiveNode.transform:Find("vx_Ton80")
		}
	end

	for i = 1, #self.achievementList do
		if i ~= index then
			self.achievementList[i].gameObject:SetActive(false)
		else
			self.achievementList[i].gameObject:SetActive(true)
		end
	end
end

function M:SetAiConfig(aiConfig)
	self.aiConfigId = aiConfig
end

function M:DoConfirmAISetting()
	return
end

function M:OnEnterLeaveDartSelect(isEnter, darts, isExit)
	if isEnter then
		self:SwitchCameraCondition(self.CameraStatus.SelectDart)

		if self.selectDarts ~= nil and #self.selectDarts > 0 then
			for i = 1, #self.selectDarts do
				if self.selectDarts[i] ~= 0 then
					GameObject.Destroy(self.selectDarts[i])
				end
			end

			self.selectDartsGo = nil
		end

		self.selectDarts = {}

		self:InitDartsInNode(darts)
	elseif isExit then
		gDartsGameManager:DestroyGame()
	else
		self:SwitchCameraCondition(self.CameraStatus.WatchScreen)
	end
end

function M:InitDartsInNode(darts)
	self.dartsSelectNodeMulti = self.dartsSelectNode.transform:GetChildren():ToTable()
	self.dartSnapsGo = {}

	for i = 1, #darts do
		if darts[i] ~= nil and i <= #self.dartsSelectNodeMulti then
			local dartInfo = darts[i]

			if dartInfo.Id ~= 0 then
				local cfg = PoiGameDartConfig.GetConfig(dartInfo.Id)
				local index = i

				table.insert(self.dartSnapsGo, self.dartsSelectNodeMulti[i])

				local op = self:LoadDartTemplate(function (go)
					local prefab = go
					local childNode = self.dartsSelectNodeMulti[i].transform:Find("Offset")
					local dartsGo = UnityEngine.GameObject.Instantiate(prefab, childNode.transform)
					dartsGo.transform.localPosition = Vector3.zero
					dartsGo.transform.localRotation = Quaternion.identity
					self.selectDarts[index] = dartsGo

					if index == 1 then
						self:OnSelectDart(1)
					end
				end, cfg)

				table.insert(self.dartsLoadOps, op)
			else
				self.selectDarts[i] = 0
			end
		end
	end

	local co = coroutine.start(function ()
		coroutine.wait(2)

		local store = gStoreManager:GetStoreGroup("DartSelectPanelStore")

		if store then
			store:InitSnap(self.dartSnapsGo)
		end
	end)

	table.insert(self.coList, co)
end

function M:OnSelectDart(idx)
	if self.selectDarts == nil then
		return
	end

	local nextGo = self.selectDarts[idx]

	if nextGo == 0 then
		return
	end

	if self.selectDartsGo ~= nextGo then
		if self.selectDartsGo then
			self.selectDartsGo.transform.localPosition = Vector3.zero
			self.selectDartsGo.transform.localRotation = Quaternion.identity
		end

		self.selectDartsGo = nextGo

		if self.preSelectDartsUUID then
			gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preSelectDartsUUID)
		end

		self.preSelectDartsUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "dartsGameSelect_" .. tostring(idx), self.selectDartsGo)
		nextGo.transform.localPosition = Vector3.New(0, 0, 0.02)
		local store = gStoreManager:GetStoreGroup("DartSelectPanelStore")

		store:OnModelSelect(idx)
	end
end

function M:IsAimDarts(transform)
	if transform ~= nil and transform:IsChildOf(self.dartsSelectNode.transform) then
		for i = 1, #self.selectDarts do
			local go = self.selectDarts[i]

			if go and go ~= 0 and go.transform:IsChildOf(transform.parent) then
				if self.preHover ~= go.transform and go ~= self.selectDartsGo then
					if self.preHoverUUID then
						gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)
					end

					self.preHoverUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "dartsGameSelect_" .. tostring(i), go)
					self.preHover = go.transform
				end

				return i
			end
		end
	end

	if self.preHover ~= nil then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.preHoverUUID)

		self.preHoverUUID = nil
		self.preHover = nil
	end
end

function M:InitPlayer1(playerType, playerId)
	local unit, name = nil
	local isMe = false

	if playerType == self.PlayerType.Me then
		unit = gCS.MyPlayerManager.PlayerUnit
		name = gPlayerManager.infoLogin.bindData.name
		isMe = true
	elseif playerType == self.PlayerType.Player then
		local _, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerId, ulong.zero)
		local participantAgent = gCS.SceneDataMgr.GetUnit(unitId)

		if not participantAgent then
			print_error("Dart: participant invalid ", playerId)

			return
		end

		unit = participantAgent
		name = gFriendManager:GetPlayerRealName(playerId)
	elseif playerType == self.PlayerType.Npc then
		print_error("Dart: playerType invalid ")

		return
	end

	if not unit then
		return
	end

	if isMe then
		self.meIndex = 1
	else
		self.opponentIndex = 1
	end

	self.player1 = unit

	UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(unit, false)

	self.playerList[1] = {
		roundStartPoint = 0,
		shootCounter = 0,
		roundIndex = 1,
		point = 0,
		player = unit,
		playerName = name,
		isMe = isMe,
		playerType = playerType,
		scoreCache = {},
		darts = {}
	}
	self.player1.LocalPosition = self.player1_InitPos.position

	self.player1:SetFacing(self.player1_InitPos.forward)
end

function M:InitPlayer2(playerType, playerId, agentId)
	local unit, name = nil
	local isMe = false

	if playerType == self.PlayerType.Me then
		unit = gCS.MyPlayerManager.PlayerUnit
		name = gPlayerManager.infoLogin.bindData.name
		isMe = true
	elseif playerType == self.PlayerType.Player then
		local _, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(playerId, ulong.zero)
		local participantAgent = gCS.SceneDataMgr.GetUnit(unitId)

		if not participantAgent then
			print_error("Dart: participant invalid ", playerId)

			return
		end

		unit = participantAgent
		name = gFriendManager:GetPlayerRealName(playerId)
	elseif playerType == self.PlayerType.Npc then
		name, unit = self:LoadNpcModel()
	end

	if not unit then
		return
	end

	if isMe then
		self.meIndex = 2
	else
		self.opponentIndex = 2
	end

	self.player2 = unit

	UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(unit, false)

	self.playerList[2] = {
		roundStartPoint = 0,
		shootCounter = 0,
		roundIndex = 0,
		point = 0,
		player = unit,
		playerName = name,
		isMe = isMe,
		playerType = playerType,
		scoreCache = {},
		darts = {}
	}
	self.player2.LocalPosition = self.player2_InitPos.position

	self.player2:SetFacing(self.player2_InitPos.forward)
end

function M:LoadNpcModel(agentId)
	local agentConfig = AgentConfig.GetConfig(agentId)
	local modelName = agentConfig.Name

	local function cb(baseUnit, _)
		if self.isDestroy then
			if baseUnit then
				baseUnit:DestroyUnit(true)
			end

			return
		end

		self.player2 = baseUnit

		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)

		self.player2.LocalPosition = self.player2_InitPos.position

		self.player2:SetFacing(self.player2_InitPos.forward)
	end

	local unit = gCS.UnitsManager:GetDialogModelByAgentId(cb, UX.Game.SexType.UnKnow, self.agentId, false, true, true)

	return modelName, unit
end

function M:SetModeAndOpenSelectPanel(modeId, targetScore)
	print_debug("Dart: SetModeAndOpenSelectPanel ", modeId, targetScore)

	self.playMode = modeId
	self.targetScore = targetScore

	if self.playMode == self.DartsGameMode.HIGH_SCORE then
		self.roundCount = 3
		self.playModeDetail = self.DartsGameModeDetailType.HIGH_SCORE
	elseif self.playMode == self.DartsGameMode.X01 then
		if targetScore == 301 then
			self.roundCount = 5
			self.playModeDetail = self.DartsGameModeDetailType.P301
		elseif targetScore == 501 then
			self.roundCount = 10
			self.playModeDetail = self.DartsGameModeDetailType.P501
		elseif targetScore == 701 then
			self.roundCount = 15
			self.playModeDetail = self.DartsGameModeDetailType.P701
		elseif targetScore == 901 then
			self.roundCount = 20
		end
	end

	local gameType = 0

	if self.playMode == self.DartsGameMode.HIGH_SCORE then
		gameType = 0
	elseif self.playMode == self.DartsGameMode.X01 then
		if targetScore == 301 then
			gameType = 1
		else
			gameType = 2
		end
	end

	gDartsGameManager:RequestServerStartDartsGame(gameType)
end

function M:OnSyncZoneInfo(zoneInfo)
	local gameType = zoneInfo.GameType

	if gameType == 0 then
		self.playMode = self.DartsGameMode.HIGH_SCORE
	elseif gameType == 1 then
		self.playMode = self.DartsGameMode.X01
		self.targetScore = 301
	elseif gameType == 2 then
		self.playMode = self.DartsGameMode.X01
		self.targetScore = 501
	end

	if self.playMode == self.DartsGameMode.HIGH_SCORE then
		self.roundCount = 3
		self.playModeDetail = self.DartsGameModeDetailType.HIGH_SCORE
	elseif self.playMode == self.DartsGameMode.X01 then
		if self.targetScore == 301 then
			self.roundCount = 5
			self.playModeDetail = self.DartsGameModeDetailType.P301
		elseif self.targetScore == 501 then
			self.roundCount = 10
			self.playModeDetail = self.DartsGameModeDetailType.P501
		elseif self.targetScore == 701 then
			self.roundCount = 15
			self.playModeDetail = self.DartsGameModeDetailType.P701
		elseif self.targetScore == 901 then
			self.roundCount = 20
		end
	end

	local players = zoneInfo.ParticipantInfos
	local myPlayerPid = gPlayerManager.infoBase.bindData.Pid

	if players and #players > 1 then
		for _, player in ipairs(players) do
			if player and not ulong.equals(player.Pid, myPlayerPid) then
				self:OnServerEnterRoom(player)
			end
		end
	end
end

function M:CheckMeValid()
	return gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.CanUseRes
end

function M:CheckOtherPlayerValid(pid)
	if not pid or ulong.equals(pid, 0) then
		return true
	end

	local _, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)
	local participantAgent = gCS.SceneDataMgr.GetUnit(unitId)

	if not participantAgent then
		return false
	end

	return participantAgent.CanUseRes
end

function M:OnServerEnterRoom(playerInfo)
	gCoroutineManager:StartCoroutine(function ()
		local pid = playerInfo.Pid
		local startTime = gLogicTime.time

		while (not self:CheckMeValid() or not self:CheckOtherPlayerValid(pid)) and gLogicTime.time - startTime < 5 do
			print_debug("Dart: wait model loading...")
			coroutine.yield(nil)
		end

		if not self:CheckMeValid() or not self:CheckOtherPlayerValid(pid) then
			print_debug("Dart: wait model load fail...")

			return
		end

		if not pid or ulong.equals(pid, 0) then
			self:InitPlayer2(self.PlayerType.Npc, pid, playerInfo.AgentUId)
			self:InitPlayer1(self.PlayerType.Me)
		else
			local seatIndex = playerInfo.SeatIndex
			local isFirst = seatIndex == 0

			if isFirst then
				self:InitPlayer1(self.PlayerType.Player, pid, playerInfo.AgentUId)
				self:InitPlayer2(self.PlayerType.Me)
			else
				self:InitPlayer1(self.PlayerType.Me)
				self:InitPlayer2(self.PlayerType.Player, pid, playerInfo.AgentUId)
			end
		end

		gPanelManager:CheckShow(gPanelId.S_DART_SELECT_PANEL)
	end)
end

function M:SelectDart(dartsConfigId)
	local info = self.playerList[self.meIndex]

	if not info.currentUsingDartId or info.currentUsingDartId == 0 then
		info.currentUsingDartId = dartsConfigId
		self.currentUsingDartId = dartsConfigId

		gDartsGameManager:NotifyServerSelectDart(dartsConfigId)
		self:TryLoadDartResource()
	end
end

function M:OnParticipantSelectDart(playerInfo)
	local info = self.playerList[self.opponentIndex]
	info.currentUsingDartId = playerInfo.DartId

	self:TryLoadDartResource()
end

function M:TryLoadDartResource()
	for _, v in pairs(self.playerList) do
		if not v or not v.currentUsingDartId or v.currentUsingDartId == 0 then
			return
		end
	end

	local counter = 0
	local info1 = self.playerList[1]
	local cfg = PoiGameDartConfig.GetConfig(info1.currentUsingDartId)
	local op = self:LoadDartTemplate(function (go)
		info1.dartPrefab = go
		counter = counter + 1

		if counter >= 2 then
			self:OnReady()
		end
	end, cfg)

	table.insert(self.dartsLoadOps, op)

	local info2 = self.playerList[2]
	local player2DartCfg = PoiGameDartConfig.GetConfig(info2.currentUsingDartId)

	if player2DartCfg == nil then
		info2.currentUsingDartId = 5
		player2DartCfg = PoiGameDartConfig.GetConfig(info2.currentUsingDartId)
	end

	op = self:LoadDartTemplate(function (go)
		counter = counter + 1
		info2.dartPrefab = go

		if counter >= 2 then
			self:OnReady()
		end
	end, player2DartCfg)

	table.insert(self.dartsLoadOps, op)
end

function M:LoadDartTemplate(endLoadDartFunc, cfg)
	local dartsPath = "Res/MiniGame/Prefab/Dart/" .. cfg.Model .. ".prefab"
	local op = gResourceManager:LoadAssetWithCallBack(dartsPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			return
		end

		endLoadDartFunc(loadOp.asset)
	end)

	return op
end

function M:OnReady()
	gDartsGameManager:NotifyServerReady()
end

function M:OnBattleStart()
	self.isStartBattle = true
	self.currentFireCount = 0
	self.currentTurnPoints = {}
	self.currentIndex = self.currentIndex + 1

	if self.currentIndex > #self.playerList then
		self.currentIndex = 1
	end

	local info = self.playerList[self.currentIndex]
	self.currentPlayer = info.player
	self.currentPlayerInfo = info
	self.nextDart = nil

	self:SetOrLoadThreeDartsInHand(info)
	self:MeGoToStartTimeline()
end

function M:SetOrLoadThreeDartsInHand(info, index)
	if info == nil then
		info = self.playerList[self.currentIndex]
	end

	if info.darts == nil or #info.darts <= 0 then
		self:InstantiateDartPrefab(info)
	end

	local hand = info.player.ModelSlot.handl

	if self.currentIndex == 1 then
		for i = 1, 3 do
			info.darts[i].transform.transform.parent = hand.transform
			info.darts[i].transform.localPosition = Vector3.New(0, 0, 0)
			info.darts[i].transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	else
		local playerType = info.playerType

		if playerType == self.PlayerType.Npc then
			local modelId = info.player.ModelCfg.Id
			local modelConfig = GeneralModelConfig.GetConfig(modelId)

			if modelConfig and modelConfig.BodyType ~= 0 then
				local bodyTypeIndex = self.BodyType[modelConfig.BodyType]

				if not bodyTypeIndex then
					for i = 1, 3 do
						info.darts[i].transform.transform.parent = hand.transform
						info.darts[i].transform.localPosition = Vector3.New(0, 0, 0)
						info.darts[i].transform.localRotation = Quaternion.Euler(0, 0, 0)
					end
				else
					for i = 1, 3 do
						local dartsOff = PoiGameDartConfig.GetConfig(self.currentNpcDartID).DartsOffset
						local dartsRot = PoiGameDartConfig.GetConfig(self.currentNpcDartID).DartsRot
						local off = dartsOff[bodyTypeIndex]
						local rot = dartsRot[bodyTypeIndex]
						info.darts[i].transform.transform.parent = hand.transform
						info.darts[i].transform.localPosition = Vector3.New(off.x, off.y, off.z)
						info.darts[i].transform.localRotation = Quaternion.Euler(rot.x, rot.y, rot.z)
					end
				end
			end
		else
			for i = 1, 3 do
				info.darts[i].transform.transform.parent = hand.transform
				info.darts[i].transform.localPosition = Vector3.New(0, 0, 0)
				info.darts[i].transform.localRotation = Quaternion.Euler(0, 0, 0)
			end
		end
	end
end

function M:InstantiateDartPrefab(info)
	local prefab = info.dartPrefab

	for i = 1, 3 do
		local dartsGo = UnityEngine.GameObject.Instantiate(prefab)

		SGUITools.SetLayer(dartsGo.gameObject, LayerConstants.DynamicShadowCaster_EnvRoom)

		info.darts[i] = dartsGo
	end
end

function M:MeGoToStartTimeline()
	self:StartGameTimeline(function ()
		self:DoStartGame()
	end)
end

function M:DoStartGame()
	self.dartsSelectNode.transform.parent.gameObject:SetActive(false)
	gPanelManager:Close(gPanelId.S_DART_HARD_LEVEL_SELECT)

	self.firstStart = true
end

function M:StartGameTimeline(loadedDone)
	local data = gTimelineManager:Timeline_CreateTimelineData()
	data.pos = self.dartsSceneNodeGo.transform.position
	local rot = self.dartsSceneNodeGo.transform.rotation.eulerAngles
	data.rot = Vector3.New(rot.x, rot.y, rot.z)
	data.startClip = "firstStartEnter"

	function data.onPlayCb()
		loadedDone()
	end

	local unitInfo = {}
	local player_pid = self.player1.Pid
	local player_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, player_pid, "Player", nil)

	table.insert(unitInfo, player_bindInfo)

	local npc_pid = self.player2.Pid
	local npc_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, npc_pid, "Npc", nil)

	table.insert(unitInfo, npc_bindInfo)

	data.bindUnitInfos = unitInfo

	self:SetOrLoadThreeDartsInHand(self.playerList[1], 1)
	self:SetOrLoadThreeDartsInHand(self.playerList[2], 2)

	data.preLoadReleaseType = 3

	gTimelineManager:Timeline_TimelinePreLoad(self.timelineName, data)

	if self.loadedTimeline == nil then
		self.loadedTimeline = {}
	end

	table.insert(self.loadedTimeline, self.timelineName)

	local co = coroutine.start(function ()
		gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(false)
		gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)
		self.gameMainPageStore:ShowTabByPanelId(gPanelId.S_Dart3D_GameTypePanel)

		if self.playMode == self.DartsGameMode.X01 then
			coroutine.wait(1)
		else
			coroutine.wait(0.5)
		end

		self.gameMainPageStore:ShowTabByPanelId(gPanelId.S_Dart3D_GameStartPanel)
		coroutine.wait(2)
		gTimelineManager:Timeline_LoadAndPlay(self.timelineName, data)
	end)

	table.insert(self.coList, co)
end

function M:DoPlayerTimeline()
	if self:IsMyTurn() then
		print_debug("dart: change DoPlayerTimeline ", self.isRealCanShot)

		self.isRealCanShot = true
	end

	self:SwitchCameraCondition(self.CameraStatus.BackClose)

	local co = coroutine.start(function ()
		coroutine.wait(1.5)
		gMessageManager:SendMessage(gEventConstants.ON_PANEL_REFRESH_CURRENT_PLAYER)
	end)

	table.insert(self.coList, co)

	if not gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_HUD_PANEL) then
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "Darts"
		})
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
	end
end

function M:DoShootEventTimeline()
	if self.isBustWaitEnd ~= nil and self.isBustWaitEnd then
		return
	end

	if not self:IsMyTurn() then
		local store = gStoreManager:GetStoreGroup("DartGamePanelStore")
		local info = self.playerList[self.currentIndex]
		local scoreCache = info.scoreCache

		store:OtherPlayerShoot(scoreCache[#scoreCache][1], scoreCache[#scoreCache][2])
	end

	self.currentShootingDart.transform.parent = nil

	self.doStartFlyFunc(self.currentShootingDart, self.nextShotWhileEndTurn)
end

function M:IsMyTurn()
	local info = self.playerList[self.currentIndex]

	print_debug("Dart: IsMyTurn ", info.isMe)

	return info.isMe
end

function M:SwitchPlayer()
	if self.isDestroy then
		return
	end

	self.currentFireCount = 0
	self.currentTurnPoints = {}
	self.currentIndex = self.currentIndex + 1

	if self.currentIndex > #self.playerList then
		self.currentIndex = 1
	end

	local info = self.playerList[self.currentIndex]
	self.currentPlayerInfo = info
	self.nextDart = nil
	self.currentPlayer = info.player
	self.isBustWaitEnd = false
	info.roundStartPoint = info.point
	info.roundIndex = info.roundIndex + 1

	for i = 1, 3 do
		info.darts[i].transform.gameObject:SetActive(true)
	end

	if self.currentIndex == 1 then
		gPanelManager:CheckShow(gPanelId.S_DartHUDStorePanel, {
			hudType = 0,
			roundNum = info.roundIndex
		})
	else
		gPanelManager:CheckShow(gPanelId.S_DartHUDStorePanel, {
			hudType = 1,
			roundNum = info.roundIndex
		})
	end

	self:SetOrLoadThreeDartsInHand(info)

	if not self:IsMyTurn() then
		self.isRealCanShot = false

		print_debug("dart: change isRealCanShot ", self.isRealCanShot)
	end

	gMessageManager:SendMessage(gEventConstants.ON_PANEL_REFRESH_CURRENT_PLAYER)
end

function M:SwitchCameraCondition(condition)
	self:DoSwitchCamera(condition)
end

function M:DoSwitchCamera(condition)
	if self.viewType == self.ViewType.Observer then
		return
	end

	if table.isNilOrEmpty(self.virtualList) then
		return
	end

	if gDartsGameManager.currentDartsGame.currentCamera == condition then
		return
	end

	for i = 1, #self.virtualList do
		if i ~= condition then
			self.virtualList[i].gameObject:SetActive(false)
		else
			self.virtualList[i].gameObject:SetActive(true)
		end
	end
end

function M:MoveCursorLookAt(dir)
	local vCamera = self.virtualList[self.CameraStatus.BackClose].transform
	local dis = Vector3.Distance(vCamera.position, self.targetCenterTransform.position)
	local vCmrFDir = vCamera.forward
	local vCmrUDir = vCamera.up
	local disMul = Vector3.Dot(dir, vCmrFDir)
	local yMul = Vector3.Dot(dir, vCmrUDir)
	local realY = dis / disMul * yMul
	local dampY = realY / 0.3 * 0.07

	if dampY < 0 then
		dampY = Mathf.Clamp(dampY + 0.02, -0.1, 0)
	else
		dampY = Mathf.Clamp(dampY - 0.02, 0, 0.12)
	end

	local y = dampY

	self.lookAtPointTransform.transform:SetLocalPositionY(y)
end

function M:PlayHitEffect(areaIndex, ringIndex)
	if areaIndex == nil then
		return
	end

	self:SetHitEffectType(ringIndex)
	self.effectNode.gameObject:SetActive(false)

	self.effectNode.gameObject.transform.localRotation = Quaternion.Euler(0, 0, (areaIndex - 1) * 18)

	self.effectNode.gameObject:SetActive(true)
end

function M:SetHitEffectType(ringIndex)
	if self.hitEffects == nil then
		self.hitEffects = {}

		for i = 1, 7 do
			self.hitEffects[i] = self.effectNode.transform:Find("fx_gp_bazi0" .. i)
		end
	end

	local activeEffectId = 0

	if ringIndex == 1 then
		activeEffectId = 6
	elseif ringIndex == 2 then
		activeEffectId = 5
	elseif ringIndex == 3 then
		activeEffectId = 4
	elseif ringIndex == 4 then
		activeEffectId = 1
	elseif ringIndex == 5 then
		activeEffectId = 2
	elseif ringIndex == 6 then
		activeEffectId = 3
	end

	for i = 1, #self.hitEffects do
		self.hitEffects[i].gameObject:SetActive(i == activeEffectId)
	end
end

function M:FireOneDartTimeline(preCulPoint, pos)
	if not self:IsMyTurn() then
		return
	end

	gDartsGameManager:NotifyServerScore(preCulPoint, pos)
	self:ReallyFireOneDartTimeline(preCulPoint)
end

function M:ReallyFireOneDartTimeline(preCulPoint)
	if self.currentFireCount >= 3 then
		return
	end

	local info = self.playerList[self.currentIndex]
	local shootCounter = info.shootCounter
	info.shootCounter = shootCounter + 1
	self.waitOpponentScoreSync = false
	self.currentFireCount = self.currentFireCount + 1
	self.nextShotWhileEndTurn = self:IsShotWhileEndTurn(preCulPoint)
	local isPlayer1 = self.currentIndex == 1

	if not self.nextShotWhileEndTurn then
		self:PlayOnceFireAndReload(isPlayer1)
	else
		self:PlayOnceFireAndEnd(isPlayer1)
	end
end

function M:OnSyncScoreInfo(scoreInfo)
	local winner = scoreInfo.Winner

	if winner == -2 then
		self:GameEnd(true)

		return
	end

	if winner >= 0 then
		local winnerIndex = winner + 1

		self:GameEnd(self.meIndex == winnerIndex)

		return
	end

	local preCulPoint = scoreInfo.CurrentScore

	if preCulPoint < 0 then
		return
	end

	local uxPos = scoreInfo.CurrentScorePos
	local pos = Vector3.New(uxPos.X, uxPos.Y, uxPos.Z)
	local info = self.playerList[self.currentIndex]

	if not info then
		return
	end

	local scoreCache = info.scoreCache

	table.insert(scoreCache, {
		preCulPoint,
		pos
	})

	if self.waitOpponentScoreSync then
		self:ReallyFireOneDartTimeline(preCulPoint)
	end
end

function M:IsShotWhileEndTurn(point)
	local currentPlayerInfo = self.playerList[self.currentIndex]

	if self.playMode == 1 then
		if self.currentIndex == #self.playerList and currentPlayerInfo.roundIndex == self.roundCount and self.currentFireCount >= 3 then
			return true
		end
	elseif self.playMode == 2 then
		local nextScore = currentPlayerInfo.point + point

		if self.targetScore <= nextScore then
			return true
		end
	end

	if self.currentFireCount >= 3 then
		return true
	end

	return false
end

function M:DoReloadDartTimeline()
	self:ReloadOneDartInHand()
end

function M:ReloadOneDartInHand()
	if self.currentPlayer == nil or self.currentPlayer.ModelSlot == nil then
		return
	end

	if self.nextDart == nil then
		self.nextDart = 1
	else
		self.nextDart = self.nextDart + 1
	end

	local dartsGo = self.currentPlayerInfo.darts[self.nextDart]
	dartsGo.transform.rotation = Quaternion.identity
	local hand = self.currentPlayer.ModelSlot.handr
	dartsGo.transform.transform.parent = hand.transform
	local sexType = gPlayerManager.infoLogin.bindData.sexType
	local dartsOff = nil
	local config = PoiGameDartConfig.GetConfig(self.currentUsingDartId)

	if config and config.MeDartsOffset and #config.MeDartsOffset > 0 then
		if sexType == 1 then
			dartsOff = config.MeDartsOffset[1]
		else
			dartsOff = config.MeDartsOffset[2]
		end
	else
		dartsOff = Vector3.zero
	end

	dartsOff = dartsOff or Vector3.zero
	dartsGo.transform.localPosition = Vector3.New(dartsOff.x, dartsOff.y, dartsOff.z)
	dartsGo.transform.localRotation = Quaternion.Euler(0, 0, 0)
	self.currentShootingDart = dartsGo
end

function M:WaitForPlayerShoot()
	if self:IsMyTurn() then
		return
	end

	local info = self.playerList[self.currentIndex]
	local scoreCache = info.scoreCache
	local shootCounter = info.shootCounter

	if scoreCache[shootCounter + 1] then
		self:ReallyFireOneDartTimeline(scoreCache[shootCounter + 1][1])

		return
	end

	self.waitOpponentScoreSync = true
end

function M:LookScreenBeforeSwitchPlayer()
	local achievement = self:CheckThisTurnAchievement()

	self:SetScreenShootAchievement(achievement)

	self.coList[5] = coroutine.start(function ()
		coroutine.wait(5)
		self:SetScreenShootAchievement(self.TurnAchievement.Normal)
	end)

	self:SwitchCameraCondition(self.CameraStatus.WatchScreen)
end

function M:CheckThisTurnAchievement()
	local totalScore = 0
	local all50 = true
	local allInCenter = true
	local oneInRed = false

	for i = 1, #self.currentTurnPoints do
		if self.currentTurnPoints[i] < 0 then
			return self.TurnAchievement.Bust
		end

		totalScore = totalScore + self.currentTurnPoints[i]

		if self.currentTurnPoints[i] ~= 50 then
			all50 = false
		end

		if self.currentTurnPoints[i] ~= 50 and self.currentTurnPoints[i] ~= 25 then
			allInCenter = false
		else
			oneInRed = true
		end
	end

	if all50 then
		return self.TurnAchievement.ThreeInTheBlack
	end

	if allInCenter then
		return self.TurnAchievement.HatTrick
	end

	if totalScore >= 100 and totalScore < 151 then
		return self.TurnAchievement.LowTon
	end

	if totalScore >= 151 and totalScore < 180 then
		return self.TurnAchievement.HighTon
	end

	if totalScore < 100 then
		return self.TurnAchievement.NiceOne
	end

	if totalScore == 180 then
		return self.TurnAchievement.Ton80
	end

	return self.TurnAchievement.Normal
end

function M:DoBeforeDisplayAchievement()
	if self.currentIndex == 1 then
		for i = 1, 3 do
			self.playerList[2].darts[i].transform.gameObject:SetActive(false)
		end
	else
		for i = 1, 3 do
			self.playerList[1].darts[i].transform.gameObject:SetActive(false)
		end
	end

	gMessageManager:SendMessage(gEventConstants.ON_BEFORE_DISPLAY_ACHIEVEMENT)
end

function M:ClearAllDartsInTargetTimeline()
	local owner = self.currentPlayerInfo

	self:SetOrLoadThreeDartsInHand(owner, nil, true)
end

function M:DoChangePlayer()
	self:SwitchPlayer()
end

function M:CurrentPlayerGetPoint(point)
	if self:IsMyTurn() then
		gClientToGameSceneDelegate:RecordDartEnd(self.currentFireCount).Callback = function (err)
			return
		end
	end

	local currentPlayerInfo = self.playerList[self.currentIndex]

	if self.playMode == 1 then
		currentPlayerInfo.point = currentPlayerInfo.point + point

		table.insert(self.currentTurnPoints, point)

		if self.currentIndex == #self.playerList and currentPlayerInfo.roundIndex == self.roundCount and self.currentFireCount >= 3 then
			local highPoint = 0
			local playerIndex = 0

			for i = 1, #self.playerList do
				local playerCurrentPoint = self.playerList[i].point

				if highPoint <= playerCurrentPoint then
					highPoint = playerCurrentPoint
					playerIndex = i
				end
			end

			return false
		end
	elseif self.playMode == 2 then
		local isBust = false

		if self.targetScore < currentPlayerInfo.point + point then
			currentPlayerInfo.point = currentPlayerInfo.roundStartPoint

			table.insert(self.currentTurnPoints, -1)

			isBust = true
		else
			currentPlayerInfo.point = currentPlayerInfo.point + point

			table.insert(self.currentTurnPoints, point)
		end

		if self.currentFireCount >= 3 or isBust then
			if self:IsMyTurn() and isBust then
				if self.totalBurstCount == nil then
					self.totalBurstCount = 0
				end

				self.totalBurstCount = self.totalBurstCount + 1
			end

			local isGameRoundEnd = true

			for i = 1, #self.playerList do
				local roundIndex = self.playerList[i].roundIndex

				if roundIndex ~= self.roundCount then
					isGameRoundEnd = false
				end
			end

			if isGameRoundEnd then
				return false
			elseif isBust then
				return false
			end
		end

		for i = 1, #self.playerList do
			local playerCurrentPoint = self.playerList[i].point

			if playerCurrentPoint == self.targetScore then
				return false
			end
		end
	end

	if self.currentFireCount >= 3 then
		return false
	end

	return true
end

function M:GameEnd(isSuccess)
	local isActWin = isSuccess
	self.isRealCanShot = false
	local store = gStoreManager:GetStoreGroup("DartGamePanelStore")

	store:RefreshCursorCanInput()

	self.gameEndCo = coroutine.start(function ()
		self:PlayGameEndView(isActWin)
		coroutine.wait(3.5)
		gDartsGameManager:DestroyGame()

		if self.onEndTlFinishHandler then
			self.onEndTlFinishHandler(isSuccess)

			self.onEndTlFinishHandler = nil
		end

		self.gameEndCo = nil
	end)

	for i, v in pairs(self.coList) do
		coroutine.stop(v)
	end

	self.coList = {}

	if isSuccess then
		self.goal = 1
	end

	self.isGameEnd = true

	for i = 1, #self.playerList do
		local darts = self.playerList[i].darts

		if darts then
			for j = 1, #darts do
				GameObject.Destroy(darts[j])
			end
		end

		self.playerList[i].darts = nil
	end
end

function M:PlayGameEndView(isActWin)
	if not self:IsMyTurn() then
		local store = gStoreManager:GetStoreGroup("DartGamePanelStore")

		store:CloseBgDeco()
	end

	local meIsFirst = self.meIndex == 1

	print_debug("PlayGameEndView: ", meIsFirst, isActWin)

	if meIsFirst then
		if isActWin then
			gTimelineManager:Timeline_JumpTo(self.timelineName, "player1EndWin")
		else
			gTimelineManager:Timeline_JumpTo(self.timelineName, "player2EndWin")
		end
	elseif isActWin then
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player2EndWin")
	else
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player1EndWin")
	end
end

function M:DestroyGame()
	if self.isDestroy then
		return
	end

	if not self.dartsSceneNodeOp then
		gResourceManager:UnloadAssetLoadOp(self.dartsSceneNodeOp)

		self.dartsSceneNodeOp = nil
	end

	if not self.dartHitEffectNodesOp then
		gResourceManager:UnloadAssetLoadOp(self.dartHitEffectNodesOp)

		self.dartHitEffectNodesOp = nil
	end

	for _, v in pairs(self.dartsLoadOps) do
		if not v then
			gResourceManager:UnloadAssetLoadOp(v)
		end
	end

	self.dartsLoadOps = {}
	self.isDestroy = true

	if self.dartsSceneNodeGo and not gCS.LuaUtils.IsNull(self.dartsSceneNodeGo) then
		GameObject.Destroy(self.dartsSceneNodeGo)

		self.dartsSceneNodeGo = nil
	end

	gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)
	gTimelineManager:Timeline_Stop(self.timelineName)

	if self.isStartBattle and self.playerList[1] then
		if self.isGameEnd then
			local PoiGameConfig = LTConfig.PoiGameConfig
			local delay = 0

			if gDartsGameManager._npc_DartGame_GameType ~= nil then
				if self.goal == 1 then
					delay = PoiGameConfig.DartNpc_Challenge_End_Delay_Show
				else
					delay = PoiGameConfig.DartNpc_Challenge_FaileEnd_Delay_Show
				end
			else
				delay = PoiGameConfig.DartSingle_Challenge_End_Delay_Show
			end

			if delay <= 0 then
				gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
					isSuccess = self.goal == 1
				})
			else
				Timer.New(function ()
					gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
						isSuccess = self.goal == 1
					})
				end, delay):Start()
			end
		else
			gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
				isSuccess = self.goal == 1
			})
		end

		gDartsGameManager.preEnd = true
	end

	self.virtualList = nil
	self.dartsSceneNodeGo = nil

	gClientToGameSceneDelegate:LeaveDart(gDartsGameManager._dart_gadgetId).Callback = function (err)
		return
	end

	gPanelManager:Close(gPanelId.S_DART_HARD_LEVEL_SELECT)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	gPanelManager:Close(gPanelId.S_DartHUDStorePanel)

	for i = 1, #self.playerList do
		local info = self.playerList[i]

		if info.playerType == self.PlayerType.Npc and info.player then
			info.player:DestroyUnit(true)
		end
	end

	for i = 1, #self.playerList do
		local darts = self.playerList[i].darts

		if darts then
			for j = 1, #darts do
				GameObject.Destroy(darts[j])
			end
		end
	end

	for i, v in pairs(self.coList) do
		if v then
			coroutine.stop(v)
		end
	end

	if not self.gameEndCo then
		coroutine.stop(self.gameEndCo)
	end

	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.Dart)

	if self.slotEntity then
		if not gCS.LuaUtils.IsNull(self.slotEntity.gameObject) then
			self.slotEntity.gameObject:SetActive(true)
		end

		self.slotEntity:TryCallInnerSignal("DartGameEnd")
	end

	gSoundMgr:SetStateValue("StateGroup_Quest", "None")
	self:ReleaseTimeline()
end

function M:ReleaseTimeline()
	if self.loadedTimeline then
		for i = 1, #self.loadedTimeline do
			gTimelineManager:Timeline_DiscardTimeline(self.loadedTimeline[i])
		end

		self.loadedTimeline = {}
	end
end

function M:PlayOnceFireAndReload(isPlayer1)
	if isPlayer1 then
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player1ShootAndReload")
	else
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player2ShootAndReload")
	end
end

function M:PlayOnceFireAndEnd(isPlayer1)
	if isPlayer1 then
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player1ShootAndEnd")
	else
		gTimelineManager:Timeline_JumpTo(self.timelineName, "player2ShootAndEnd")
	end
end
