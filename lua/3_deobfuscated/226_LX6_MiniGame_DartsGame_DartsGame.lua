gDartsGame = DefClass("DartsGame", gDartsGame)
local DartsGame = gDartsGame
local LayerConstants = LX6.Constants.LayerConstants
local PoiGameDartConfig = LTConfig.PoiGameDartConfig
local PoiGameDartAIConfig = LTConfig.PoiGameDartAIConfig
local UnitModelManager = LX6.Units.UnitModelManager
local GeneralModelConfig = LTConfig.GeneralModelConfig
local AgentConfig = LTConfig.AgentConfig
local DartsTriggerName = {
	GoToStart = "GoToStart",
	GoToClearDarts = "GoToClearDarts",
	WinAct = "WinAct",
	DoNextDarts = "DoNext",
	FailAct = "FailAct",
	NoMoveToStart = "NoMoveToStart",
	Shot = "Shot"
}
local DartsStatusName = {
	IsShotEnd = "IsShotEnd"
}
local DartsGameMode = {
	X01 = 2,
	HIGH_SCORE = 1
}
local DartsGameModeDetailType = {
	P701 = 4,
	HIGH_SCORE = 1,
	P301 = 2,
	P501 = 3
}
local CameraStatus = {
	SelectDart = 3,
	BackClose = 1,
	WatchScreen = 2
}
local BodyType = {
	nil,
	3,
	5,
	1,
	2,
	4
}
local TurnAchievement = {
	HighTon = 7,
	NiceOne = 3,
	Bust = 5,
	Ton80 = 8,
	HatTrick = 2,
	LowTon = 4,
	ThreeInTheBlack = 6,
	Normal = 1
}

function DartsGame:ctor(args)
	self.isLoadFinish = false
	self.args = args
	self.taskId = args.taskId
	self.timelineName = "Gameplay_Dart"
	self.slotEntity = args.slotEntity
	self.wayPointPosition = args.wayPointPosition
	self.wayPointRotation = args.wayPointRotation
	self.useSuit = args.useSuit
	self.playerUnit = nil
	self.enemyUnit = nil
	self.uiScale = Vector3.New(0.69, 0.69, 0.69)
	self.goal = 0
	self.isGameEnd = false
	self.doStartFlyFunc = nil
	self.playMode = 2
	self.targetScore = 301
	self.roundCount = 15
	self.currentFireCount = 0
	self.currentIndex = 0
	self.playerList = {}
	self.coList = {}
	self.currentCamera = nil
	self.nextCamera = nil
	self.isFadingCamera = false
	self.cameraSwitchQueue = {}
	self.onEndTlFinishHandler = nil
	self.npcDartLoadOp = nil

	self:Initialize()
end

function DartsGame:Initialize()
	self.gameMainPageStore = gStoreManager:GetStoreGroup("S_Dart3D_MainPageStore")

	gSoundMgr:SetStateValue("StateGroup_Quest", "State_FeiBiao")
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.Dart)
	self:InitDartsScene()
end

function DartsGame:SetModeAndOpenSelectPanel(modeId, targetScore)
	self.playMode = modeId
	self.targetScore = targetScore

	if self.playMode == DartsGameMode.HIGH_SCORE then
		self.roundCount = 3
		self.playModeDetail = DartsGameModeDetailType.HIGH_SCORE
	elseif self.playMode == DartsGameMode.X01 then
		if targetScore == 301 then
			self.roundCount = 5
			self.playModeDetail = DartsGameModeDetailType.P301
		elseif targetScore == 501 then
			self.roundCount = 10
			self.playModeDetail = DartsGameModeDetailType.P501
		elseif targetScore == 701 then
			self.roundCount = 15
			self.playModeDetail = DartsGameModeDetailType.P701
		elseif targetScore == 901 then
			self.roundCount = 20
		end
	end

	if gDartsGameManager._isOnLine then
		local gameType = 0

		if self.playMode == DartsGameMode.HIGH_SCORE then
			gameType = 0
		elseif self.playMode == DartsGameMode.X01 then
			if targetScore == 301 then
				gameType = 1
			else
				gameType = 2
			end
		end

		gDartsGameManager:RequestServerStartDartsGame(gameType)

		return
	end

	gPanelManager:CheckShow(gPanelId.S_DART_SELECT_PANEL)
end

function DartsGame:OnServerEnterRoom(playerInfo)
	self.participantInfo = playerInfo
	local pid = playerInfo.Pid
	local _, unitId = gCS.PlayerUnitMgr:TryGetCurrentSpirit(pid, ulong.zero)
	local participantAgent = gCS.SceneDataMgr.GetUnit(unitId)

	if not participantAgent then
		print_error("Dart: participant invalid ", pid)

		return
	end

	self.enemyUnit = participantAgent
	self.playerList[2] = {
		roundIndex = 0,
		playerName = "participant",
		point = 0,
		roundStartPoint = 0,
		player = self.enemyUnit
	}

	gPanelManager:CheckShow(gPanelId.S_DART_SELECT_PANEL)
end

function DartsGame:OnParticipantSelectDart(playerInfo)
	self.participantInfo = playerInfo
	local counter = 0
	local cfg = PoiGameDartConfig.GetConfig(self.currentUsingDartId)

	self:LoadDartTemplate(function (go)
		self.dartsPrefab = go
		counter = counter + 1
	end, cfg, self.dartsLoadOp)

	self.currentNpcDartID = playerInfo.DartId
	self.npcDartPrefab = nil
	local npcDartCfg = PoiGameDartConfig.GetConfig(self.currentNpcDartID)

	if npcDartCfg == nil then
		self.currentNpcDartID = 5
		npcDartCfg = PoiGameDartConfig.GetConfig(self.currentNpcDartID)
	end

	self:LoadDartTemplate(function (go)
		counter = counter + 1
		self.npcDartPrefab = go
	end, npcDartCfg, self.npcDartLoadOp)
	coroutine.start(function ()
		while counter < 2 do
			coroutine.yield(nil)
		end

		self:OnReady()
	end)
end

function DartsGame:OnReady()
	gDartsGameManager:NotifyServerReady()
end

function DartsGame:OnBattleStart()
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
	self.currentAnim = info.anim

	self:SetOrLoadThreeDartsInHand(info)
	self:MeGoToStartTimeline()
end

function DartsGame:SelectDart(dartsConfigId)
	self.currentUsingDartId = dartsConfigId

	if gDartsGameManager._isOnLine then
		gDartsGameManager:NotifyServerSelectDart(dartsConfigId)

		return
	end

	gClientToGameDelegate:StartDarts(dartsConfigId, self.challengeId, self.playModeDetail).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("开启挑战失败", err)
		else
			self.isStartDarts = true
		end
	end

	local cfg = PoiGameDartConfig.GetConfig(self.currentUsingDartId)

	self:LoadDartTemplate(function (go)
		self.dartsPrefab = go
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
		self.currentAnim = info.anim

		self:SetOrLoadThreeDartsInHand(info)
		self:MeGoToStartTimeline()
	end, cfg, self.dartsLoadOp)
end

function DartsGame:OnEnterLeaveDartSelect(isEnter, darts, isExit)
	if isEnter then
		self:SwitchCameraCondition(CameraStatus.SelectDart)

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
		self:SwitchCameraCondition(CameraStatus.WatchScreen)
	end
end

function DartsGame:SetAiConfig(aiConfig)
	if gDartsGameManager._isOnLine then
		return
	end

	self.aiConfigId = aiConfig
	local aiConfig = PoiGameDartAIConfig.GetConfig(self.aiConfigId)
	self.agentId = nil
	self.modelId = nil
	local agentIdList = aiConfig.AgentId

	if agentIdList and #agentIdList > 0 then
		local randomIndex = math.random(1, #agentIdList)
		self.agentId = agentIdList[randomIndex]
	else
		local modelIdList = aiConfig.FightSpiritID
		local randomIndex = math.random(1, #modelIdList)
		self.modelId = modelIdList[randomIndex]
	end

	self.challengeId = aiConfig.ChallengeID
	self.bustCount = aiConfig.BustCount

	self:SetNpcRandomDarts()
end

function DartsGame:DoConfirmAISetting()
	if gDartsGameManager._isOnLine then
		return
	end

	self:LoadNpcCharacterModel()
end

function DartsGame:OnSelectDart(idx)
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

function DartsGame:IsAimDarts(transform)
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

function DartsGame:InitDartsInNode(darts)
	self.dartsSelectNodeMulti = self.dartsSelectNode.transform:GetChildren():ToTable()
	self.dartSnapsGo = {}

	for i = 1, #darts do
		if darts[i] ~= nil and i <= #self.dartsSelectNodeMulti then
			local dartInfo = darts[i]

			if dartInfo.Id ~= 0 then
				local cfg = PoiGameDartConfig.GetConfig(dartInfo.Id)
				local index = i

				table.insert(self.dartSnapsGo, self.dartsSelectNodeMulti[i])
				self:LoadDartTemplate(function (go)
					local prefab = go
					local childNode = self.dartsSelectNodeMulti[i].transform:Find("Offset")
					local dartsGo = UnityEngine.GameObject.Instantiate(prefab, childNode.transform)
					dartsGo.transform.localPosition = Vector3.zero
					dartsGo.transform.localRotation = Quaternion.identity
					self.selectDarts[index] = dartsGo

					if index == 1 then
						self:OnSelectDart(1)
					end
				end, cfg, self.dartsLoadOp)
			else
				self.selectDarts[i] = 0
			end
		end
	end

	self.coList[6] = coroutine.start(function ()
		coroutine.wait(2)

		local store = gStoreManager:GetStoreGroup("DartSelectPanelStore")

		if store then
			store:InitSnap(self.dartSnapsGo)
		end
	end)
end

function DartsGame:SwitchPlayer()
	if self.isGameEnd then
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
	self.currentAnim = info.anim
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
	end

	gMessageManager:SendMessage(gEventConstants.ON_PANEL_REFRESH_CURRENT_PLAYER)

	gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.TurnFinish).Callback = function (err)
		return
	end
end

function DartsGame:DoStartGame()
	self.dartsSelectNode.transform.parent.gameObject:SetActive(false)
	gPanelManager:Close(gPanelId.S_DART_HARD_LEVEL_SELECT)

	if not self:IsMyTurn() then
		self:SwitchPlayer()
	end

	self.firstStart = true
end

function DartsGame:InstantiateDartPrefab(prefab, info)
	for i = 1, 3 do
		local dartsGo = UnityEngine.GameObject.Instantiate(prefab)

		SGUITools.SetLayer(dartsGo.gameObject, LayerConstants.DynamicShadowCaster_EnvRoom)

		info.darts[i] = dartsGo
	end
end

function DartsGame:SetOrLoadThreeDartsInHand(info, index, isReset)
	if info == nil then
		info = self.playerList[self.currentIndex]
	end

	if self.dartsPrefab == nil then
		print_error("飞镖资源不存在")
		gDartsGameManager:DestroyGame()

		return
	end

	if info.darts == nil then
		info.darts = {}

		if index == 2 then
			self:InstantiateDartPrefab(self.npcDartPrefab, info)
		else
			self:InstantiateDartPrefab(self.dartsPrefab, info)
		end
	end

	local hand = info.player.ModelSlot.handl

	if self.currentIndex == 1 then
		local sexType = gPlayerManager.infoLogin.bindData.sexType
		local bodyType = nil

		if sexType == 1 then
			bodyType = 2
		else
			bodyType = 5
		end

		for i = 1, 3 do
			info.darts[i].transform.transform.parent = hand.transform
			info.darts[i].transform.localPosition = Vector3.New(0, 0, 0)
			info.darts[i].transform.localRotation = Quaternion.Euler(0, 0, 0)
		end
	else
		local modelId = info.player.ModelCfg.Id
		local modelConfig = GeneralModelConfig.GetConfig(modelId)

		if modelConfig and modelConfig.BodyType ~= 0 then
			local bodyTypeIndex = BodyType[modelConfig.BodyType]
			local dartsOff = PoiGameDartConfig.GetConfig(self.currentNpcDartID).DartsOffset
			local dartsRot = PoiGameDartConfig.GetConfig(self.currentNpcDartID).DartsRot

			if not bodyTypeIndex then
				for i = 1, 3 do
					local off = dartsOff[bodyTypeIndex]
					local rot = dartsRot[bodyTypeIndex]
					info.darts[i].transform.transform.parent = hand.transform
					info.darts[i].transform.localPosition = Vector3.New(0, 0, 0)
					info.darts[i].transform.localRotation = Quaternion.Euler(0, 0, 0)
				end
			else
				for i = 1, 3 do
					local off = dartsOff[bodyTypeIndex]
					local rot = dartsRot[bodyTypeIndex]
					info.darts[i].transform.transform.parent = hand.transform
					info.darts[i].transform.localPosition = Vector3.New(off.x, off.y, off.z)
					info.darts[i].transform.localRotation = Quaternion.Euler(rot.x, rot.y, rot.z)
				end
			end
		end
	end
end

function DartsGame:LoadDartTemplate(endLoadDartFunc, cfg, op)
	local dartsPath = "Res/MiniGame/Prefab/Dart/" .. cfg.Model .. ".prefab"
	op = gResourceManager:LoadAssetWithCallBack(dartsPath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			return
		end

		endLoadDartFunc(loadOp.asset)
	end)
end

function DartsGame:ReloadOneDartInHand()
	if self.currentPlayer == nil or self.currentPlayer.ModelSlot == nil then
		return
	end

	if self.dartsPrefab == nil then
		print_error("飞镖资源不存在")
		gDartsGameManager:DestroyGame()

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

function DartsGame:ClearAllDartsInTarget()
	local owner = self.currentDartInTargetOwner

	self:SetOrLoadThreeDartsInHand(owner)
end

local nextShotWhileEndTurn = false

function DartsGame:SetScreenShootAchievement(index)
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

function DartsGame:LookScreenBeforeSwitchPlayer()
	local achievement = self:CheckThisTurnAchievement()

	self:SetScreenShootAchievement(achievement)

	self.coList[5] = coroutine.start(function ()
		coroutine.wait(5)
		self:SetScreenShootAchievement(TurnAchievement.Normal)
	end)

	self:SwitchCameraCondition(CameraStatus.WatchScreen)
end

function DartsGame:DoBeforeDisplayAchievement()
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

function DartsGame:InitDartsScene()
	local DartsSceneNodePath = "Res/MiniGame/Prefab/Dart/DartSceneNode.prefab"
	self.dartsSceneNodeOp = gResourceManager:LoadAssetWithCallBack(DartsSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp)
		if self.hasDestroy then
			return
		end

		local DartsSceneNodeGo = UnityEngine.GameObject.Instantiate(loadOp.asset)
		self.DartsSceneNodeGo = DartsSceneNodeGo
		DartsSceneNodeGo.transform.position = Vector3.New(unpack(self.wayPointPosition))
		DartsSceneNodeGo.transform.rotation = Quaternion.New(unpack(self.wayPointRotation))
		DartsSceneNodeGo.gameObject.name = "DartsSceneNode"

		DartsSceneNodeGo.gameObject:SetActive(true)
		self.slotEntity.gameObject:SetActive(false)

		self.EnemyInitPos = DartsSceneNodeGo.transform:Find("offset/enemyInitPos")
		self.PlayerInitPos = DartsSceneNodeGo.transform:Find("offset/playerInitPos")
		self.targetCenterTransform = DartsSceneNodeGo.transform:Find("offset/targetCenterTransform")
		self.lookAtPointTransform = DartsSceneNodeGo.transform:Find("offset/targetCenterTransform/lookAtPoint")
		self.effectNode = DartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/hitEffects")
		self.quad = DartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/vx_Screen")
		self.dartHitEffectNodesOp = {}

		for i = 1, 7 do
			local DartsHitEffectSceneNodePath = "Res/MiniGame/Prefab/Dart/fx_gp_bazi0" .. i .. ".prefab"
			self.dartHitEffectNodesOp[i] = gResourceManager:LoadAssetWithCallBack(DartsHitEffectSceneNodePath, typeof(UnityEngine.GameObject), function (loadOp2)
				if self.hasDestroy then
					return
				end

				if self.hitEffects == nil then
					self.hitEffects = {}
				end

				local hitEffect = UnityEngine.GameObject.Instantiate(loadOp2.asset, self.effectNode.transform)
				self.hitEffects[i] = hitEffect
			end)
		end

		self.effectHitActiveNode = DartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/sc_fd_ty_jh_jifb01a_pm_pc")

		self:SetScreenShootAchievement(TurnAchievement.Normal)

		self.dartsSelectNode = DartsSceneNodeGo.transform:Find("offset/effect/sc_fd_ty_jh_jifb01a_pc/DartPlate/DartHookNode")
		local virtualCameraNode = DartsSceneNodeGo.transform:Find("offset/cinemachineVCList")
		self.virtualList = {
			virtualCameraNode:Find("BackClose"),
			virtualCameraNode:Find("WatchScreen"),
			virtualCameraNode:Find("SelectDart")
		}
		self.CinemachineLuaHandler = virtualCameraNode:GetComponent(typeof(LX6.Cinemachine.CinemachineLuaHandler))
		self.CinemachineLuaHandler.onCameraInactive = self.OnVCamInactive
		self.screenCenter = DartsSceneNodeGo.transform:Find("offset/ScreenCenter")
		self.targetViewTransform = DartsSceneNodeGo.transform:Find("offset/TargetViewTransform")

		self:InitDartsCharacter(DartsSceneNodeGo, self.EnemyInitPos, self.PlayerInitPos)
		self:InitUI()

		self.isLoadFinish = true
	end)
end

function DartsGame:GetScreenUITransform()
	if self.screenCenter == nil then
		return
	end

	return self.screenCenter.transform
end

function DartsGame:GetScreenUIPosition()
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

function DartsGame:GetScreenRotation()
	local q = Quaternion.Inverse(gCS.CameraDataMgr.MainCamera.transform.rotation) * self.screenCenter.transform.rotation

	return q
end

function DartsGame:SwitchCameraCondition(condition)
	self:DoSwitchCamera(condition)
end

function DartsGame:DoSwitchCamera(condition)
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

function DartsGame:DoNextChange()
	if #self.cameraSwitchQueue <= 0 then
		return
	end

	local next = self.cameraSwitchQueue[1]

	table.remove(self.cameraSwitchQueue, 1)
	self:DoSwitchCamera(next)
end

function DartsGame.OnVCamInactive(vCamName)
	if gDartsGameManager.currentDartsGame ~= nil and CameraStatus[vCamName] == gDartsGameManager.currentDartsGame.currentCamera then
		gDartsGameManager.currentDartsGame.isFadingCamera = false
		gDartsGameManager.currentDartsGame.currentCamera = gDartsGameManager.currentDartsGame.nextCamera

		gDartsGameManager.currentDartsGame:DoNextChange()
	end
end

function DartsGame:InitDartsCharacter(DartsSceneNodeGo, SpectatorStandPos, PlayerStandPos)
	local unit = gCS.MyPlayerManager.PlayerUnit
	self.playerUnit = unit

	UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(unit, false)

	self.playerList[1] = {
		roundIndex = 1,
		point = 0,
		roundStartPoint = 0,
		player = unit,
		playerName = gPlayerManager.infoLogin.bindData.name
	}
	self.playerUnit.LocalPosition = self.PlayerInitPos.position

	self.playerUnit:SetFacing(self.PlayerInitPos.forward)
end

function DartsGame:LoadPlayerCharacterModel()
	local sexType = gPlayerManager.infoLogin.bindData.sexType

	gCS.UnitsManager:GetDialogModelByAgentId(function (baseUnit, _)
		if self.isDestroy then
			if baseUnit then
				baseUnit:DestroyUnit(true)
			end

			return
		end

		self.playerUnit = baseUnit

		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)

		self.playerList[1] = {
			roundIndex = 1,
			point = 0,
			roundStartPoint = 0,
			player = baseUnit,
			playerName = gPlayerManager.infoLogin.bindData.name
		}
		self.playerUnit.LocalPosition = self.PlayerInitPos.position

		self.playerUnit:SetFacing(self.PlayerInitPos.forward)
		gCS.AnimationManager.AnimatorPlay(self.playerUnit, 1001, 1, 0, 0)
	end, sexType, gCS.MyPlayerManager.PlayerUnit.ClientData.AgentId, false, true, true, gBattleSpiritMgr.currentSpiritTemplateId)
end

function DartsGame:OnBeforeSwitchScene(switchType)
	return
end

function DartsGame:OnAfterSwitchScene(switchType)
	return
end

function DartsGame:LoadNpcCharacterModel()
	if self.isLoadingNpc then
		return
	end

	self.isLoadingNpc = true

	if self.enemyUnit then
		self.enemyUnit:DestroyUnit(true)
	end

	local modelName = nil

	if self.agentId then
		local agentConfig = AgentConfig.GetConfig(self.agentId)
		modelName = agentConfig.Name
	else
		local modelConfig = GeneralModelConfig.GetConfig(self.modelId)
		modelName = modelConfig.Name
	end

	local function cb(baseUnit, _)
		if self.isDestroy then
			if baseUnit then
				baseUnit:DestroyUnit(true)
			end

			return
		end

		self.isLoadingNpc = false
		self.enemyUnit = baseUnit

		UnitModelManager.ShowOrHideAllBindItemAndWeaponRender(baseUnit, false)

		self.playerList[2] = {
			roundIndex = 0,
			point = 0,
			roundStartPoint = 0,
			player = baseUnit,
			playerName = modelName
		}
		self.enemyUnit.LocalPosition = self.EnemyInitPos.position

		self.enemyUnit:SetFacing(self.EnemyInitPos.forward)
	end

	if self.agentId then
		local me = gCS.MyPlayerManager.PlayerUnit
		local position = Vector3.New(me.LocalPosition.x, me.LocalPosition.y, me.LocalPosition.z)
		local suit = nil

		if not self.useSuit or not gDartsGameManager:IsInviteNpc() then
			suit = 0
		else
			suit = gDartsGameManager.curSuit
		end

		self.enemyUnit = gCS.LuaUtils.CreateClientAgentByCfg(self.agentId, position, Vector3.one, cb, suit)
	else
		self.enemyUnit = gCS.UnitsManager:GetDialogModel(cb, UX.Game.SexType.UnKnow, self.modelId, false, true, true)
	end
end

function DartsGame:PlayAnimationByTriggerName(characterAnim, triggerName)
	characterAnim:SetTrigger(triggerName)
end

function DartsGame:InitUI()
	gMessageManager:SendMessage(gEventConstants.DO_DART_SCENE_NODE_LOADED)
	self:SwitchCameraCondition(CameraStatus.WatchScreen)
end

function DartsGame:DestroyGame()
	if self.isDestroy then
		return
	end

	gResourceManager:UnloadAssetLoadOp(self.dartsLoadOp)
	gResourceManager:UnloadAssetLoadOp(self.dartsSceneNodeOp)
	gResourceManager:UnloadAssetLoadOp(self.animatorControllerLoadOp)
	gResourceManager:UnloadAssetLoadOp(self.npcDartLoadOp)

	self.isDestroy = true

	if self.DartsSceneNodeGo and not gCS.LuaUtils.IsNull(self.DartsSceneNodeGo) then
		GameObject.Destroy(self.DartsSceneNodeGo)
	end

	gTimelineManager:Timeline_Stop(self.timelineName)

	if self.isStartDarts and self.playerList[1] then
		local score = self.playerList[1].point
		local achievements = {}

		if self.totalBurstCount ~= nil and self.totalBurstCount >= 3 then
			table.insert(achievements, UX.Game.SpecialAchievementType.Baobiao)
		end

		local isInviteNpc = gDartsGameManager:IsInviteNpc()

		if self.goal ~= nil and self.aiConfigId ~= nil and self.goal == 1 and self.aiConfigId >= 103 and self.playMode == DartsGameMode.X01 and not isInviteNpc then
			table.insert(achievements, UX.Game.SpecialAchievementType.EagleEye)
		end

		local goal = self.goal

		if self.isGameEnd then
			local PoiGameConfig = LTConfig.PoiGameConfig
			local delay = 0

			if gDartsGameManager._npc_DartGame_GameType ~= nil then
				if goal == 1 then
					delay = PoiGameConfig.DartNpc_Challenge_End_Delay_Show
				else
					delay = PoiGameConfig.DartNpc_Challenge_FaileEnd_Delay_Show
				end
			else
				delay = PoiGameConfig.DartSingle_Challenge_End_Delay_Show
			end

			if delay <= 0 then
				gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
					isSuccess = goal == 1
				})
			else
				Timer.New(function ()
					gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
						isSuccess = goal == 1
					})
				end, delay):Start()
			end
		else
			gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
				isSuccess = goal == 1
			})
		end

		gDartsGameManager.preEnd = true
		gDartsGameManager.curSuit = nil

		gClientToGameDelegate:RecordDarts(self.challengeId, score, self.goal, self.isGameEnd, achievements).Callback = function (err)
			return
		end
	end

	self.virtualList = nil
	self.DartsSceneNodeGo = nil

	gPanelManager:Close(gPanelId.S_DART_HARD_LEVEL_SELECT)
	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	gPanelManager:Close(gPanelId.S_DartHUDStorePanel)

	for i = 2, #self.playerList do
		local unit = self.playerList[i].player

		gCS.BaseUnitUtils.DestroyAgentUnit(unit, true, true, false)
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

	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.Dart)

	if self.slotEntity then
		if not gCS.LuaUtils.IsNull(self.slotEntity.gameObject) then
			self.slotEntity.gameObject:SetActive(true)
		end

		self.slotEntity:TryCallInnerSignal("DartGameEnd")
	end

	gSoundMgr:SetStateValue("StateGroup_Quest", "None")
	self:ReleaseTimeline()

	local cursorGo = SGUI.UCursorInput.Inst.gameObject:FindChild("S_Cursor")

	if cursorGo then
		cursorGo:SetActive(false)
	end
end

function DartsGame:IsShotWhileEndTurn(point)
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

function DartsGame:SetHitEffectType(ringIndex)
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

function DartsGame:ShowOrHideQuad(show)
	if self.quad then
		self.quad.gameObject:SetActive(show)
	end
end

function DartsGame:PlayHitEffect(areaIndex, ringIndex)
	if areaIndex == nil then
		return
	end

	self:SetHitEffectType(ringIndex)
	self.effectNode.gameObject:SetActive(false)

	self.effectNode.gameObject.transform.localRotation = Quaternion.Euler(0, 0, (areaIndex - 1) * 18)

	self.effectNode.gameObject:SetActive(true)
end

function DartsGame:CurrentPlayerGetPoint(point)
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

			self:GameEnd(playerIndex == 1)

			return false
		end
	elseif self.playMode == 2 then
		local isBust = false

		if self.targetScore < currentPlayerInfo.point + point then
			currentPlayerInfo.point = currentPlayerInfo.roundStartPoint

			table.insert(self.currentTurnPoints, -1)

			isBust = true

			gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.Bust).Callback = function (err)
				return
			end
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
				self:GameEnd(self.playerList[2].point < self.playerList[1].point)

				return false
			elseif isBust then
				if self.playerList[2].point < self.playerList[1].point then
					gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.ExceedScore).Callback = function (err)
						return
					end
				elseif self.playerList[1].point < self.playerList[2].point then
					gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.OverTakenScore).Callback = function (err)
						return
					end
				end

				return false
			end
		end

		for i = 1, #self.playerList do
			local playerCurrentPoint = self.playerList[i].point

			if playerCurrentPoint == self.targetScore then
				self:GameEnd(i == 1)

				return false
			end
		end
	end

	if self.currentFireCount >= 3 then
		if self.playerList[2].point < self.playerList[1].point then
			gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.ExceedScore).Callback = function (err)
				return
			end
		elseif self.playerList[1].point < self.playerList[2].point then
			gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.OverTakenScore).Callback = function (err)
				return
			end
		end

		return false
	end

	if self.playerList[2].point < self.playerList[1].point then
		gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.ExceedScore).Callback = function (err)
			return
		end
	elseif self.playerList[1].point < self.playerList[2].point then
		gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.OverTakenScore).Callback = function (err)
			return
		end
	end

	return true
end

function DartsGame:PlayGameEndView(isActWin)
	if isActWin then
		gTimelineManager:Timeline_JumpTo(self.timelineName, "endWin")
	else
		gTimelineManager:Timeline_JumpTo(self.timelineName, "endLose")
	end
end

function DartsGame:GameEnd(isSuccess)
	local isActWin = isSuccess
	self.isRealCanShot = false
	local store = gStoreManager:GetStoreGroup("DartGamePanelStore")

	store:RefreshCursorCanInput()

	local dartTiming = UX.Game.DartTiming.Success

	if isSuccess then
		dartTiming = UX.Game.DartTiming.Success
	else
		dartTiming = UX.Game.DartTiming.Fail
	end

	gClientToGameSceneDelegate:TriggerDartTiming(dartTiming).Callback = function (err)
		return
	end

	self.coList[1] = coroutine.start(function ()
		self:PlayGameEndView(isActWin)
		coroutine.wait(3.5)
		gDartsGameManager:DestroyGame()

		if self.onEndTlFinishHandler then
			self.onEndTlFinishHandler(isSuccess)

			self.onEndTlFinishHandler = nil
		end
	end)

	for i, v in pairs(self.coList) do
		if i ~= 1 then
			coroutine.stop(v)
		end
	end

	if isSuccess then
		self.goal = 1
	end

	self.score = self.playerList[1].point
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

function DartsGame:CheckThisTurnAchievement()
	local totalScore = 0
	local all50 = true
	local allInCenter = true
	local oneInRed = false

	for i = 1, #self.currentTurnPoints do
		if self.currentTurnPoints[i] < 0 then
			return TurnAchievement.Bust
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
		return TurnAchievement.ThreeInTheBlack
	end

	if allInCenter then
		return TurnAchievement.HatTrick
	end

	if totalScore >= 100 and totalScore < 151 then
		return TurnAchievement.LowTon
	end

	if totalScore >= 151 and totalScore < 180 then
		return TurnAchievement.HighTon
	end

	if totalScore < 100 then
		return TurnAchievement.NiceOne
	end

	if totalScore == 180 then
		return TurnAchievement.Ton80
	end

	return TurnAchievement.Normal
end

function DartsGame:IsMyTurn()
	return self.currentIndex == 1
end

function DartsGame:StartGameTimeline(loadedDone)
	gCoroutineManager:StartCoroutine(function ()
		gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)

		local startTime = gLogicTime.time

		while (self.playerList[1] == nil or self.playerList[2] == nil) and gLogicTime.time - startTime < 5 do
			print_debug("dart: wait loading...")
			coroutine.yield(nil)
		end

		local data = gTimelineManager:Timeline_CreateTimelineData()
		data.pos = self.DartsSceneNodeGo.transform.position
		local rot = self.DartsSceneNodeGo.transform.rotation.eulerAngles
		data.rot = Vector3.New(rot.x, rot.y, rot.z)
		data.startClip = "firstStartEnter"

		function data.onPlayCb()
			loadedDone()
		end

		local unitInfo = {}
		local player_pid = self.playerUnit.Pid
		local player_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, player_pid, "Player", nil)

		table.insert(unitInfo, player_bindInfo)

		local npc_pid = self.enemyUnit.Pid
		local npc_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, npc_pid, "Npc", nil)

		table.insert(unitInfo, npc_bindInfo)

		data.bindUnitInfos = unitInfo

		self:SetOrLoadThreeDartsInHand(self.playerList[1], 1)
		self:SetOrLoadThreeDartsInHand(self.playerList[2], 2)

		data.preLoadReleaseType = 3

		if self.loadedTimeline == nil then
			self.loadedTimeline = {}
		end

		table.insert(self.loadedTimeline, self.timelineName)

		self.coList[3] = coroutine.start(function ()
			gDartsGameManager.currentDartsGame:OnEnterLeaveDartSelect(false)
			gPanelManager:Close(gPanelId.S_DART_SELECT_PANEL)
			self.gameMainPageStore:ShowTabByPanelId(gPanelId.S_Dart3D_GameTypePanel)

			if self.playMode == DartsGameMode.X01 then
				coroutine.wait(1)
			else
				coroutine.wait(0.5)
			end

			self.gameMainPageStore:ShowTabByPanelId(gPanelId.S_Dart3D_GameStartPanel)
			coroutine.wait(2)
			gTimelineManager:Timeline_LoadAndPlay(self.timelineName, data)
		end)
	end)
end

function DartsGame:SetNpcRandomDarts()
	local npcDartIDs = PoiGameDartAIConfig.GetConfig(self.aiConfigId).DartID
	local randomIndex = math.random(1, #npcDartIDs)
	self.currentNpcDartID = npcDartIDs[randomIndex]

	if self.currentNpcDartID then
		local npcDartCfg = PoiGameDartConfig.GetConfig(self.currentNpcDartID)

		if npcDartCfg == nil then
			self.currentNpcDartID = 5
			npcDartCfg = PoiGameDartConfig.GetConfig(self.currentNpcDartID)
		end

		self:LoadDartTemplate(function (go)
			self.npcDartPrefab = go
		end, npcDartCfg, self.npcDartLoadOp)
	end
end

function DartsGame:MeGoToStartTimeline()
	if self.firstStart == nil then
		self:StartGameTimeline(function ()
			self:DoStartGame()
		end)
	end
end

function DartsGame:DoChangePlayer()
	self:SwitchPlayer()
end

function DartsGame:OnSyncScoreInfo(scoreInfo)
	local preCulPoint = scoreInfo.GameScore

	if self.currentFireCount >= 3 then
		return
	end

	self.currentFireCount = self.currentFireCount + 1
	nextShotWhileEndTurn = self:IsShotWhileEndTurn(preCulPoint)
	self.coList[4] = coroutine.start(function ()
		if self.isGameEnd then
			return
		end

		if not nextShotWhileEndTurn then
			if self:IsMyTurn() then
				self:PlayOnceMyFireAndReload()
			end
		elseif self:IsMyTurn() then
			self:PlayOnceMyFireAndEnd()
			coroutine.wait(3)
		elseif self.currentFireCount ~= 3 then
			self.isBustWaitEnd = true

			coroutine.wait(0.5)
			self:BreakEnemyShot()
		end
	end)
end

function DartsGame:FireOneDartTimeline(preCulPoint, doPlayFlyCb)
	if gDartsGameManager._isOnLine then
		gDartsGameManager:NotifyServerScore(preCulPoint)

		return
	end

	if self.currentFireCount >= 3 then
		return
	end

	self.currentFireCount = self.currentFireCount + 1
	nextShotWhileEndTurn = self:IsShotWhileEndTurn(preCulPoint)
	self.coList[4] = coroutine.start(function ()
		if self.isGameEnd then
			return
		end

		if not nextShotWhileEndTurn then
			if self:IsMyTurn() then
				self:PlayOnceMyFireAndReload()
			end
		elseif self:IsMyTurn() then
			self:PlayOnceMyFireAndEnd()
			coroutine.wait(3)
		elseif self.currentFireCount ~= 3 then
			self.isBustWaitEnd = true

			coroutine.wait(0.5)
			self:BreakEnemyShot()
		end
	end)
end

function DartsGame:PlayOnceMyFireAndReload()
	gTimelineManager:Timeline_JumpTo("Gameplay_Dart", "shootAndReload")
end

function DartsGame:PlayOnceMyFireAndEnd()
	gTimelineManager:Timeline_JumpTo("Gameplay_Dart", "shootAndEnd")
end

function DartsGame:BreakEnemyShot()
	gTimelineManager:Timeline_JumpTo(self.timelineName, "enemyEndShot")
end

function DartsGame:DoReloadDartTimeline()
	self:ReloadOneDartInHand()
end

function DartsGame:DoShootEventTimeline()
	if self.isBustWaitEnd ~= nil and self.isBustWaitEnd then
		return
	end

	if not self:IsMyTurn() then
		local store = gStoreManager:GetStoreGroup("DartGamePanelStore")

		store:OtherPlayerShoot()
	end

	self.currentShootingDart.transform.parent = nil
	self.currentDartInTargetOwner = self.currentPlayerInfo

	self.doStartFlyFunc(self.currentShootingDart, nextShotWhileEndTurn)
end

function DartsGame:DoMyTurnStartTimeline()
	self.isRealCanShot = true

	if not self:IsMyTurn() then
		self:SwitchPlayer()
	end

	self:SwitchCameraCondition(CameraStatus.BackClose)

	self.coList[2] = coroutine.start(function ()
		coroutine.wait(1.5)
		gMessageManager:SendMessage(gEventConstants.ON_PANEL_REFRESH_CURRENT_PLAYER)

		gClientToGameSceneDelegate:TriggerDartTiming(UX.Game.DartTiming.TurnFinish).Callback = function (err)
			return
		end
	end)

	if not gPanelManager:IsPanelShowing(gPanelId.S_GAMEPLAY_HUD_PANEL) then
		print_debug("Dart CheckShow")
		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			gameplayType = "Darts"
		})
		gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)
	end
end

function DartsGame:ClearAllDartsInTargetTimeline()
	local owner = self.currentDartInTargetOwner

	self:SetOrLoadThreeDartsInHand(owner, nil, true)
end

function DartsGame:ShowPanelByPanelId(panelId, prePanel)
	self.gameMainPageStore:ShowTabByPanelId(panelId, prePanel)
end

function DartsGame:BackPre()
	self.gameMainPageStore:BackPre()
end

function DartsGame:ReleaseTimeline()
	if self.loadedTimeline then
		for i = 1, #self.loadedTimeline do
			gTimelineManager:Timeline_DiscardTimeline(self.loadedTimeline[i])
		end

		self.loadedTimeline = {}
	end
end

function DartsGame:MoveCursorLookAt(dir)
	local vCamera = self.virtualList[CameraStatus.BackClose].transform
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
