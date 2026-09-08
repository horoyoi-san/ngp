-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BowlingGame\BowlingGameManager.lua
-- Decompiled from: 00647_BowlingGameManager.lua_bf49c1103dac.luajit

C_BowlingGameManager = DefClass("C_BowlingGameManager", C_BowlingGameManager, gBaseMiniGameManager)
local BowlingGameManager = C_BowlingGameManager
local json = require("cjson/json")
local BowlingBallUtils = require("LX6/MiniGame/BowlingGame/BowlingBallUtils")

local print_debug = function(...)
	if gBowlingGameManager.debug then
		_G.print_warn("[BowlingGameManager] ", ...)
	end
end

local print_warn = function(...)
	_G.print_warn("[BowlingGameManager] ", ...)
end

local print_error = function(...)
	_G.print_error("[BowlingGameManager] ", ...)
end

local debug_rpc = function(name, fromServer, ...)
	if fromServer then
		_G.print_warn("[BowlingGameManager] RPC: " .. name .. " ", ...)
	else
		_G.print_warn("[BowlingGameManager] RPC: " .. name .. " ", ...)
		_G.print_warn("[BowlingGameManager] RPC: " .. name, debug.traceback(" stack=", 3))
	end
end

local try_handle_error = function(err, rpcName)
	if err == LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(err)
		print_error_without_stack("[BowlingGameManager] RPC error in callback: " .. (rpcName or "unknown"), err, LTConfig.MessageConfig.GetConfig(err).Content)

		return true
	end

	return false
end

local GameGroundZoneSyncReason = UX.Game.GameGroundZoneSyncReason
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameMode = BowlingConstants.GameMode
local LifecycleState = BowlingConstants.LifecycleState

BowlingGameManager.ctor = function(self)
	self.debug = false

	self:InitConstants()

	self.sceneItemBallIdList = {}
	self.sceneItemPinIdList = {}
	self.lifecycleState = LifecycleState.NONE

	gMessageManager:AddMessageListener(gEventConstants.LINK_SETTLEMENT_CONTINUE_CLICKED, self:CreateAction("OnLinkSettlementContinueClicked"))
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction("OnAfterSwitchScene"))
end

BowlingGameManager.OnLinkSettlementContinueClicked = function(self, _, playId)
	if self.currentGame and self.currentGame.linkPlayId ~= playId then
		self:ExecuteExitGame()
	end
end

BowlingGameManager.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	self.spectatorManager:StopAll()
	self:ExecuteExitGame(true)
end

BowlingGameManager.SetLifecycleState = function(self, state)
	local oldState = self.lifecycleState
	self.lifecycleState = state

	print_debug("Lifecycle state changed:", oldState, "->", state)
end

BowlingGameManager.MarkExitByUI = function(self)
	if self.gameInstance then
		self.gameInstance.isExitByUI = true
	end
end

BowlingGameManager.IsExitByUI = function(self)
	return self.gameInstance and self.gameInstance.isExitByUI ~= true
end

BowlingGameManager.IsDestroying = function(self)
	return self.lifecycleState ~= LifecycleState.DESTROYING
end

BowlingGameManager.InitConstants = function(self)
	self.sceneItemType = {
		["\\xbeah"] = 101,
		["X#qW"] = 1,
		["\\xfb\\xda3%\\xe9"] = 100
	}
	self.ballNum = 5
	self.spectatorManager = gBowlingSpectatorManager.new()
end

BowlingGameManager.DestroyGame = function(self)
	print_debug("now destroy bowling game", "hasInstance=", self.gameInstance == nil, "hasGame=", self.currentGame == nil, "state=", self.lifecycleState)
	self:SendSignalToGadget("ExitBowling")
	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_END)

	for _, v in ipairs(self.sceneItemBallIdList) do
		LX6.Item.SceneItemMgr.Instance:TagAndLoadGameobject(v, false)
	end

	for _, v in ipairs(self.sceneItemPinIdList) do
		LX6.Item.SceneItemMgr.Instance:TagAndLoadGameobject(v, false)
	end

	if self.currentGame and not self.currentGame.hasDestroy then
		self.currentGame:CleanupAndDestroy()
	end

	self.currentGame = nil

	self:ClearServerGameState()

	if self.gameInstance ~= nil then
		return
	end

	if self.gameInstance.gameLoop then
		gCoroutineManager:CancelCoroutine(self.gameInstance.gameLoop)

		self.gameInstance.gameLoop = nil
	end

	if self.gameInstance.broadcastMergeCo then
		gCoroutineManager:CancelCoroutine(self.gameInstance.broadcastMergeCo)

		self.gameInstance.broadcastMergeCo = nil
	end

	if self.gameInstance.lastDOTweenUseSafeMode == nil then
		DOTween.useSafeMode = self.gameInstance.lastDOTweenUseSafeMode
	end

	self.gameInstance = nil
end

BowlingGameManager.ClearServerGameState = function(self, abort)
	self:AskPutDownSceneItem()
	gNewGamePlayProgressMgr:StopProgressTemplate(1801)

	if self.gameInstance ~= nil or self.gameInstance.zoneInfo ~= nil then
		return
	end

	array.remove_if_all(self.sceneItemBallIdList, function (v)
		return array.contains(self.gameInstance.zoneInfo.BowlingBallSceneItemIdList, v)
	end)
	array.remove_if_all(self.sceneItemPinIdList, function (v)
		return array.contains(self.gameInstance.zoneInfo.BowlingPinSceneItemIdList, v)
	end)

	local hideSceneItem = function(instanceId)
		local hold = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(instanceId)

		if hold and gClientUtils.NotNil(hold.SceneItemObj) then
			hold.SceneItemObj:SetActive(false)
		end
	end

	slot3 = ipairs
	slot5 = self.gameInstance.zoneInfo.BowlingBallSceneItemIdList or {}

	for _, v in slot3(slot5) do
		hideSceneItem(v)
	end

	slot3 = ipairs
	slot5 = self.gameInstance.zoneInfo.BowlingPinSceneItemIdList or {}

	for _, v in slot3(slot5) do
		hideSceneItem(v)
	end

	slot3 = ipairs
	slot5 = self.gameInstance.zoneInfo.ParticipantInfos or {}

	for _, info in slot3(slot5) do
		local agentId = info.AgentInstanceId

		if agentId and ulong.Greater(agentId, 0) then
			local unit = gCS.SceneDataMgr.GetUnit(agentId)

			if gCS.LuaUtils.IsBaseUnitValid(unit) then
				unit:DestroyUnit(true)
			end
		end
	end

	if self.gameInstance.createArgs and self.gameInstance.createArgs.entityInstanceId then
		if abort ~= nil then
			abort = true
		end

		if abort then
			self:SetPlayAgain(false)
			self:SurrenderGame()
			self:LeaveBowling(self.gameInstance.createArgs.entityInstanceId, true)
		else
			self:LeaveBowling(self.gameInstance.createArgs.entityInstanceId, false)
		end

		self.gameInstance.createArgs.entityInstanceId = nil
	end
end

BowlingGameManager.CreateGameLoop = function(self)
	if self.gameInstance.gameLoop then
		print_error("#NoCreateIssue 上一个 game loop 没销毁！")
		gCoroutineManager:CancelCoroutine(self.gameInstance.gameLoop)
	end

	self.gameInstance.tasksIn = {}
	self.gameInstance.gameLoop = gCoroutineManager:StartCoroutine(function ()
		while true do
			local tasks = self.gameInstance.tasksIn
			self.gameInstance.tasksIn = {}

			for _, task in ipairs(tasks) do
				task()
			end

			coroutine.yield(nil)
		end
	end)
end

BowlingGameManager.AddTask = function(self, task)
	table.insert(self.gameInstance.tasksIn, task)
end

BowlingGameManager.CreateAndStartGame_Async = function(self, mode, args)
	if self.currentGame then
		print_error("currentGame ~= nil")

		return false
	end

	args.zoneInfo = self.gameInstance.zoneInfo
	self.gameInstance.lastDOTweenUseSafeMode = DOTween.useSafeMode
	DOTween.useSafeMode = true

	self:InitSceneItems()

	if gLinkManager.LinkMode == UX.Game.LinkMode.None and mode == GameMode.ONLINE_BATTLE then
		self:AskHandHoldSceneItem()
	end

	for _, v in ipairs(self.gameInstance.sceneItemBallList) do
		local go = v.go

		if gClientUtils.NotNil(go) then
			local comp = go:GetOrAddComponent(typeof(LX6.Audio.PhysicsColliderSound))
			comp.soundId = 0
			comp.isDynamic = true
			comp.otherMask = LayerMask.GetMask("Floor")
			comp.sendVelocityAndImpulse = true
		end
	end

	self.currentGame = gBowlingGame.new(args)

	self.currentGame:InitBowlingScene_Async()

	if self:IsDestroying() or self.currentGame.hasDestroy then
		return
	end

	self.currentGame:InitCoroutine()

	if not self.currentGame:ExecuteSelectMode_Async(mode) then
		return false
	end

	self.gameInstance.gameMode = self.currentGame.gameMode

	if self:IsMatchGame() then
		self:SetReady(true)
	end

	return true
end

BowlingGameManager.CreateAndStartGameCs = function(self, mode, npcId, position, rotation, entityInstanceId, npcCreateTrans, timelineAllMoveTrans)
	self.gameInstance = self.gameInstance or {}
	local args = {
		["i\\x99\\xb6\\xb6۸\\xd1\\xb96\\xbb"] = 0,
		["i\\x99\\xb3\\xaaФ\\xcc-\\xa8+\\xbd"] = 0,
		["\"-%\\xeag\\xac\\xf29\\xb8#\\xe7\\xe6\\xe3]\\xff"] = 0,
		mode = mode,
		npcId = npcId,
		wayPointPosition = position,
		wayPointRotation = rotation,
		entityInstanceId = entityInstanceId,
		npcCreateTrans = npcCreateTrans,
		timelineAllMoveTrans = timelineAllMoveTrans
	}
	self.gameInstance.createArgs = args

	print_debug("CreateAndStartGameCs", args)

	if mode ~= GameMode.ONLINE_BATTLE then
		self:RealStartGame()
	elseif mode ~= GameMode.NPC_BATTLE then
		gClientToGameDelegate:AskSimulationInviteNpc(LTConfig.NpcCultivationGameplayTypeConfig.Bowling).Callback = function (err)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		self.gameInstance.pendingInviteTask = function(npcTemplateId)
			self:CreateGameLoop()
			self:AddTask(function ()
				if self:CreateNpcGame_Async(args, npcTemplateId) then
					self:TriggerClientGameFromGadget_Async(entityInstanceId)
				end
			end)
		end
	elseif mode ~= GameMode.RIDE_NPC_BATTLE then
		local npcCultivationId = npcId
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)

		if npcCultivationCfg then
			args.npcCultivationId = npcCultivationId
			args.npcFightSpiritId = npcCultivationCfg.FightSpiritID
			local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(args.npcFightSpiritId)

			if spiritCfg then
				args.agentTemplateId = spiritCfg.AgentId
			end
		end

		self.gameInstance.npcUnit = gNpcFavorManager:GetRideNpcInst()
		args.needDestroyNpcUnit = false

		self:CreateGameLoop()
		self:AddTask(function ()
			self:TriggerClientGameFromGadget_Async(entityInstanceId)
		end)
	else
		self:CreateGameLoop()
		self:AddTask(function ()
			self:TriggerClientGameFromGadget_Async(entityInstanceId)
		end)
	end
end

BowlingGameManager.OnNpcInvited = function(self, npcTemplateId)
	if self.gameInstance.pendingInviteTask then
		self.gameInstance.pendingInviteTask(npcTemplateId)

		self.gameInstance.pendingInviteTask = nil
	end
end

BowlingGameManager.RealStartGame = function(self)
	local createArgs = self.gameInstance.createArgs

	if createArgs ~= nil then
		print_error("createArgs == nil")

		return
	end

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_START)
	self:AddTask(function ()
		self:CreateAndStartGame_Async(createArgs.mode, createArgs)
		self:ConsumePendingRpcQueue()
	end)
end

BowlingGameManager.TriggerClientGameFromGadget_Async = function(self, entityInstanceId)
	self:SetLifecycleState(LifecycleState.CREATING)
	self:EnterGame(entityInstanceId, UX.Game.BowlingGameType.Single, 0)
end

BowlingGameManager.TryShowClassicModeExitDialog = function(self)
	local game = self.currentGame

	if game ~= nil or game.mode == GameMode.NPC_BATTLE then
		return
	end

	local npcId = self.gameInstance.createArgs and self.gameInstance.createArgs.npcCultivationId or 0

	if npcId < 0 then
		return
	end

	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
	local dialogId = npcCfg and npcCfg.LeaveHalfwayDialog or 0

	if dialogId <= 0 then
		gDialogManager:ShowGeneralDialog(dialogId, gDialogSource.Dart)
	end
end

BowlingGameManager.CreateNpcGame_Async = function(self, args, npcCultivationId)
	local buyTicketToken = gWaitToken.Create()

	gClientToGameSceneDelegate:AskBowlingBuyTicket(false).Callback = function (err)
		buyTicketToken:SetResult(err)
	end

	coroutine.yield(buyTicketToken)

	local askBowlingBuyTicketErrCode = buyTicketToken.result

	if askBowlingBuyTicketErrCode == LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(askBowlingBuyTicketErrCode)
		self:DestroyGame()

		return false
	end

	local fashionToken = gWaitToken.Create()
	local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)
	local spiritId = npcCultivationCfg.FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, list)
		fashionToken:SetResult({
			err = err,
			list = list
		})
	end

	coroutine.yield(fashionToken)

	local fashionResult = fashionToken.result or {}
	local askGetNpcRandomWearFashionsErrCode = fashionResult.err
	local npcFashionList = fashionResult.list

	if askGetNpcRandomWearFashionsErrCode == LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(askGetNpcRandomWearFashionsErrCode)
	end

	local pos = args.npcCreateTrans.position
	local eulerAngles = args.npcCreateTrans.eulerAngles
	args.npcCultivationId = npcCultivationId
	args.npcFightSpiritId = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId).FightSpiritID
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(args.npcFightSpiritId)

	if spiritCfg ~= nil then
		print_error("配置 NpcCultivationConfig=", npcCultivationId, "对应的 FightSpirit 不存在！")
		self:DestroyGame()

		return false
	end

	local agentTemplateId = spiritCfg.AgentId
	args.agentTemplateId = agentTemplateId
	local npcUnitToken = gWaitToken.Create()

	gCS.LuaUtils.CreateClientAgentByCfg(agentTemplateId, pos, eulerAngles, function (npcUnit)
		self.gameInstance.npcUnit = npcUnit
		self.gameInstance.npcUnitPid = npcUnit.Pid

		npcUnitToken:SetResult(npcUnit)
	end, npcFashionList or 0)
	coroutine.yield(npcUnitToken)

	while not gCS.LuaUtils.IsBaseUnitValid(self.gameInstance.npcUnit) do
		coroutine.yield(nil)
	end

	args.needDestroyNpcUnit = true
	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.gameInstance.npcUnitPid, LTConfig.LivehouseConfig.LivehouseInviteTL_ActorName, nil)
	timelineData.bindUnitInfos = {
		bindInfo
	}
	timelineData.pos = args.timelineAllMoveTrans.position
	timelineData.rot = args.timelineAllMoveTrans.eulerAngles
	local dialogId = npcCultivationCfg.EnterTimelineDialog

	if dialogId and dialogId <= 0 then
		timelineData.dynamicDialogIds = {
			dialogId
		}
	end

	local entityInstanceId = args.entityInstanceId

	timelineData.onPlayCallback = function()
		local entity = L50.L50App.Scene.SpoonGadgetManager:GetEntitySearchByInstanceId(entityInstanceId)

		if entity then
			entity:TryCallInnerSignal("BowlingInviteTimelinePlay")
		end
	end

	local timelineEndToken = gWaitToken.Create()

	timelineData.onFinishCallback = function()
		timelineEndToken:SetResult(true)
	end

	gTimelineManager:Timeline_LoadAndPlay(LTConfig.LivehouseConfig.LivehouseInviteTL, timelineData)
	coroutine.yield(timelineEndToken)

	return true
end

BowlingGameManager.CreateGameFromServerImpl = function(self, zoneInfo)
	self.gameInstance = self.gameInstance or {}
	self.gameInstance.zoneInfo = zoneInfo

	if self:IsOnlineGameType(zoneInfo.GameType) then
		self:CreateGameLoop()
	end

	self:AddTask(function ()
		self:SetLifecycleState(LifecycleState.CREATING)
		self:CreateGameFromServerImpl_Async(zoneInfo)
	end)
end

BowlingGameManager.CreateGameFromServerImpl_Async = function(self, zoneInfo)
	local gadgetEntity = self:WaitSceneItemAndGadget_Async(zoneInfo)

	if self:IsDestroying() or gadgetEntity ~= nil then
		return
	end

	self.gameInstance.gadgetEntity = gadgetEntity

	if zoneInfo.GameType ~= UX.Game.BowlingGameType.Single or self.gameInstance.isPlayAgain then
		self:RealStartGame()
	elseif self:IsOnlineGameType(zoneInfo.GameType) then
		self:SendSignalToGadget("StartOnlineBattleFromLink")
	else
		print_error("未知的 GameType", zoneInfo)
	end
end

BowlingGameManager.WaitSceneItemAndGadget_Async = function(self, zoneInfo)
	local sceneItemToken = gWaitToken.Create():WaitUntil(function ()
		return self:IsDestroying() or self:CheckDisableSceneItems(zoneInfo.BowlingBallSceneItemIdList) and self:CheckDisableSceneItems(zoneInfo.BowlingPinSceneItemIdList)
	end):SetTimeout(5)

	coroutine.yield(sceneItemToken)

	if self:IsDestroying() then
		return nil
	end

	self.sceneItemBallIdList = array.concat(self.sceneItemBallIdList, zoneInfo.BowlingBallSceneItemIdList)
	self.sceneItemPinIdList = array.concat(self.sceneItemPinIdList, zoneInfo.BowlingPinSceneItemIdList)

	self:InitSceneItemsLayer(self.sceneItemBallIdList)
	self:InitSceneItemsLayer(self.sceneItemPinIdList)

	local gadgetUId = zoneInfo.GadgetUId

	print_debug("保龄球 等机关加载", gadgetUId, "当前", gGadgetManager:GetEntitySearchByInstanceId(gadgetUId))

	local gadgetToken = gWaitToken.Create():CancelWhen(function ()
		return self:IsDestroying()
	end):SetTimeout(20)

	L50.L50App.Scene.SpoonGadgetManager:RegisterWaitLoad({
		gadgetUId
	}, function (entity)
		print_debug("RegisterWaitLoad OK ", gadgetUId)
		gadgetToken:SetResult(entity)
	end)
	coroutine.yield(gadgetToken)

	if gadgetToken.isCanceled then
		return nil
	end

	if gadgetToken.isTimeout then
		print_error("保龄球 机关加载超时", gadgetUId)
		self:LeaveBowling(gadgetUId, true)

		return nil
	end

	print_debug("保龄球 机关加载好了", gadgetUId)

	return gadgetToken.result
end

BowlingGameManager.ExecuteExitGame = function(self, abort)
	if self.lifecycleState ~= LifecycleState.DESTROYING or self.lifecycleState ~= LifecycleState.NONE then
		return
	end

	self:SetLifecycleState(LifecycleState.DESTROYING)
	self:ClearServerGameState(abort)

	if self.currentGame then
		self.currentGame:CleanupAndDestroy()
	end

	self:DestroyGame()
	self:SetLifecycleState(LifecycleState.NONE)
end

BowlingGameManager.ConsumePendingRpcQueue = function(self)
	local pending = self.gameInstance.pendingRpcQueue

	if pending ~= nil then
		return
	end

	self.gameInstance.pendingRpcQueue = nil

	for _, rpc in ipairs(pending) do
		if rpc.type ~= "ZoneState" then
			if self.currentGame and self.currentGame.args.entityInstanceId ~= rpc.uId then
				self.currentGame:OnSyncZoneState(rpc.state)
			end
		elseif rpc.type ~= "TurnChange" and self.currentGame and self.gameInstance.gameMode and self.currentGame.args.entityInstanceId ~= rpc.uId then
			self.gameInstance.gameMode:OnSyncTurnChange_Async(rpc.currentRound, rpc.currentTurn)
		end
	end
end

BowlingGameManager.OnServerTriggerPlayAgain = function(self, zoneInfo)
	print_debug("保龄球 重置游戏用于再来一局")

	if self.lifecycleState ~= LifecycleState.DESTROYING then
		print_warn("保龄球 重置时已处于销毁状态，跳过")

		return
	end

	self:SetLifecycleState(LifecycleState.DESTROYING)

	if self.gameInstance.gameLoop then
		gCoroutineManager:CancelCoroutine(self.gameInstance.gameLoop)

		self.gameInstance.gameLoop = nil
	end

	if self.gameInstance.broadcastMergeCo then
		gCoroutineManager:CancelCoroutine(self.gameInstance.broadcastMergeCo)

		self.gameInstance.broadcastMergeCo = nil
	end

	self.gameInstance.broadcastQueue = {}
	self.gameInstance.npcUnit = nil

	gMessageManager:SendMessage(gEventConstants.BOWLING_GAME_END)

	self.gameInstance.cacheTimeline = self.currentGame and self.currentGame.timelineManager
	self.gameInstance.bPreserveTimelineOnce = true

	if self.currentGame and not self.currentGame.hasDestroy then
		self.currentGame:CleanupAndDestroy()
	end

	self.gameInstance.bPreserveTimelineOnce = false
	self.sceneItemBallIdList = {}
	self.sceneItemPinIdList = {}

	if self.currentGame then
		LX6.Game.BowlingGameBridge.ClearBalls(self.currentGame.args.entityInstanceId)
	end

	self.gameInstance.zoneInfo = nil
	self.gameInstance.gadgetEntity = nil
	self.currentGame = nil
	self.gameInstance.gameMode = nil
	self.gameInstance.pendingRpcQueue = {}
	self.gameInstance.isPlayAgain = true

	self:SetLifecycleState(LifecycleState.NONE)
	self:CreateGameFromServerImpl(zoneInfo)
end

BowlingGameManager.RegisterSceneItemBall = function(self, ball)
	if self.gameInstance ~= nil then
		return
	end

	table.insert(self.sceneItemBallIdList, ball)
end

BowlingGameManager.RegisterSceneItemPin = function(self, pin)
	if self.gameInstance ~= nil then
		return
	end

	table.insert(self.sceneItemPinIdList, pin)
end

BowlingGameManager.InitSceneItems = function(self)
	local getItemsFromIdList = function(idList, maxCount)
		local goList = {}

		for i = #idList, 1, -1 do
			local id = idList[i]
			local hold = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(id)
			local go = hold and hold.SceneItemObj

			if go then
				LX6.Item.SceneItemMgr.Instance:TagAndLoadGameobject(id)
				gCS.LuaUtils.SetSceneItemRecoverDelayView(id)

				local item = {
					["h'sO"] = false,
					go = go,
					hold = hold,
					id = id,
					origRoot = go.transform.parent
				}

				table.insert(goList, item)

				if #goList ~= maxCount then
					break
				end
			elseif hold ~= nil then
				table.remove(idList, i)
				print_error("scene item", ulong.tostring(id), " hold not found")
			else
				print_debug("scene item", ulong.tostring(id), "not found, hold=", hold)
			end
		end

		return goList
	end

	self.sceneItemBallIdList = array.unique(self.sceneItemBallIdList or {})
	self.sceneItemPinIdList = array.unique(self.sceneItemPinIdList or {})
	self.gameInstance.sceneItemBallList = getItemsFromIdList(self.sceneItemBallIdList, 5)

	array.reverse(self.gameInstance.sceneItemBallList)

	self.gameInstance.sceneItemPinList = getItemsFromIdList(self.sceneItemPinIdList, 10)

	if self.debug then
		local fp = require("Core/moses")

		print_debug("sceneItemBallIdList", self.sceneItemBallIdList)
		print_debug("sceneItemBallList", fp.mapi(self.gameInstance.sceneItemBallList, function (v, k)
			return k, v.go.name
		end))
		print_debug("sceneItemPinIdList", self.sceneItemPinIdList)
		print_debug("sceneItemPinList", fp.mapi(self.gameInstance.sceneItemPinList, function (v, k)
			return k, v.go.name
		end))
	end
end

BowlingGameManager.Rent = function(self, type, parent, preferredSceneItemId)
	local foundItem, go = nil

	if type < self.sceneItemType.BallMax then
		local item = self.gameInstance.sceneItemBallList[type]

		if item ~= nil then
			print_error("[BowlingGameManager] type", type, "is not supported")

			return nil
		end

		foundItem = item
		go = item.go
		item.rent = true
	elseif type ~= self.sceneItemType.Pin then
		if preferredSceneItemId == nil then
			for _, item in ipairs(self.gameInstance.sceneItemPinList) do
				if item.id ~= preferredSceneItemId and not item.rent then
					foundItem = item
					go = item.go

					if gClientUtils.NotNil(go) then
						item.rent = true

						break
					else
						print_error("[BowlingGameManager] a preferred object in pool is destroyed!", item)
					end
				end
			end
		end

		if foundItem ~= nil then
			for _, item in ipairs(self.gameInstance.sceneItemPinList) do
				if not item.rent then
					foundItem = item
					go = item.go

					if gClientUtils.NotNil(go) then
						item.rent = true

						break
					else
						print_error("[BowlingGameManager] a object in pool is destroyed!", item)
					end
				end
			end
		end
	else
		print_error("[BowlingGameManager] type", type, "is not supported")
	end

	if foundItem ~= nil then
		print_error("[BowlingGameManager] pool[" .. tostring(type) .. "] is nil")

		return nil
	end

	self:ActivateSceneItem(foundItem.hold)

	if gClientUtils.IsNil(go) then
		print_error("[BowlingGameManager] pool[" .. tostring(type) .. "] is nil")

		return nil, foundItem.id
	end

	if gClientUtils.NotNil(parent) then
		go.transform:SetParent(parent)
	end

	return go, foundItem.id
end

BowlingGameManager.Return = function(self, type, go)
	if type ~= nil then
		print_error("[BowlingGameManager] passed a nil type", go)

		return
	end

	if go ~= nil then
		print_error("[BowlingGameManager] return a nil object", type)

		return
	end

	local destroyed = gCS.LuaUtils.IsNull(go)
	local item = nil

	if type < self.sceneItemType.BallMax then
		item = self.gameInstance.sceneItemBallList[type]
	elseif type ~= self.sceneItemType.Pin then
		local v, _ = array.find_if(self.gameInstance.sceneItemPinList, function (i)
			return i.go ~= go and i.rent
		end)
		item = v
	else
		print_error("[BowlingGameManager] type", type, "is not supported")
	end

	if item ~= nil then
		print_error("[BowlingGameManager] return a object which is not in pool")

		return
	end

	if destroyed then
		print_warn("[BowlingGameManager] return a destroyed object", type, item.id)
	else
		local parent = item.origRoot

		if gClientUtils.NotNil(parent) then
			go.transform:SetParent(parent)
		end
	end

	self:DisableSceneItemSimple(item.hold)

	if not item.rent then
		print_error("[BowlingGameManager] return a object which is not rent", item.id)
	end

	item.rent = false
end

BowlingGameManager.ActivateSceneItem = function(self, hold)
	self:SetCollidersEnabled(hold.SceneItemObj, true)
	hold:SetUseGravity(true)
end

BowlingGameManager.CheckDisableSceneItems = function(self, idList)
	for _, v in ipairs(idList) do
		LX6.Item.SceneItemMgr.Instance:TagAndLoadGameobject(v)

		local hold = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(v)

		if hold ~= nil or hold.SceneItemObj ~= nil then
			print_debug("CheckDisableSceneItem ", v, " failed")

			return false
		end

		self:DisableSceneItemSimple(hold)
		print_debug("CheckDisableSceneItem ", v, " ok")
	end

	return true
end

BowlingGameManager.DisableSceneItemSimple = function(self, hold)
	if hold ~= nil or hold.InstanceId ~= (self.gameInstance or {}).doNotDisableBallId then
		return
	end

	BowlingBallUtils:SetColliderSound(hold.InstanceId, 0)
	self:SetCollidersEnabled(hold.SceneItemObj, false)
	hold:SetKinematic(true)
	hold:SetUseGravity(false)

	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local playerTransform = playerUnit and playerUnit.PlayerObj

	if playerTransform then
		hold:SyncPositionAndRotation(playerTransform.position + Vector3.Fetch(0, -1, 0), Quaternion.identity)
	end
end

BowlingGameManager.InitSceneItemsLayer = function(self, idList)
	local Destructible = UnityEngine.LayerMask.NameToLayer("Destructible")
	local destructibleMask = bit.lshift(1, Destructible)
	local excludeOthers = bit.bnot(destructibleMask)

	for _, id in ipairs(idList) do
		LX6.Item.SceneItemMgr.Instance:TagAndLoadGameobject(id)

		local hold = LX6.Item.SceneItemMgr.Instance:GetSceneItemHold(id)

		if hold and gClientUtils.NotNil(hold.SceneItemObj) then
			local colliders = hold.SceneItemObj:GetComponentsInChildren(typeof(UnityEngine.Collider))

			if colliders and colliders.Length <= 0 then
				for i = 0, colliders.Length - 1 do
					local c = colliders[i]

					if gClientUtils.NotNil(c) then
						c.excludeLayers = excludeOthers
						c.includeLayers = destructibleMask
					end
				end
			end
		end
	end
end

BowlingGameManager.DisableBalls = function(self)
	if (self.gameInstance or {}).sceneItemBallList ~= nil then
		return
	end

	for i = 1, self.ballNum do
		self:DisableSceneItemSimple((self.gameInstance.sceneItemBallList[i] or {}).hold)
	end
end

BowlingGameManager.SetCollidersEnabled = function(self, go, enabled)
	if gClientUtils.IsNil(go) then
		return
	end

	local colliders = go:GetComponentsInChildren(typeof(UnityEngine.Collider)):ToTable()

	for _, v in ipairs(colliders) do
		v.enabled = enabled
	end
end

BowlingGameManager.Destroy = function(self, object)
	gClientUtils.DestroyUnityObject(object)
end

BowlingGameManager.SendSignalToGadget = function(self, signal)
	if self.gameInstance and self.gameInstance.gadgetEntity then
		self.gameInstance.gadgetEntity:TryCallInnerSignal(signal)
	end
end

BowlingGameManager.IsOnlineGameType = function(self, gameType)
	return gameType ~= UX.Game.BowlingGameType.DoublePlayer or gameType ~= UX.Game.BowlingGameType.DoubleAI
end

BowlingGameManager.IsInOnlineDoubleAiGame = function(self)
	local gameType = self.gameInstance and self.gameInstance.zoneInfo and self.gameInstance.zoneInfo.GameType

	return gameType ~= UX.Game.BowlingGameType.DoubleAI
end

BowlingGameManager.IsOnlineGame = function(self)
	local gameMode = self.currentGame and (self.gameInstance or {}).gameMode

	if gameMode then
		return gameMode:GetClassType() ~= gBowlingModeOnline
	else
		return false
	end
end

BowlingGameManager.IsMatchGame = function(self)
	return self:IsOnlineGame() or self:IsInOnlineDoubleAiGame()
end

BowlingGameManager.QuickFinishGame = function(self)
	local game = self.currentGame
	local gameMode = game and game.gameMode

	if gameMode and gameMode.QuickFinishGame then
		gameMode:QuickFinishGame()
	end
end

BowlingGameManager.OnSyncGameGroundZoneInfo = function(self, zoneInfo)
	if self.debug then
		debug_rpc("OnSyncGameGroundZoneInfo", true, zoneInfo)
	end

	if self.currentGame and self.currentGame.args.entityInstanceId ~= zoneInfo.GadgetUId then
		if self.gameInstance.waitingForZoneInfo then
			self.gameInstance.waitingForZoneInfo = false
		end

		self.currentGame:OnSyncZoneInfo(zoneInfo)

		return
	end

	print_debug("CreateGameFromServer")

	if zoneInfo.SyncReason ~= GameGroundZoneSyncReason.Enter then
		self:CreateGameFromServerImpl(zoneInfo)
	elseif zoneInfo.SyncReason ~= GameGroundZoneSyncReason.ReEnter then
		-- Nothing
	elseif zoneInfo.SyncReason ~= GameGroundZoneSyncReason.ReEnterFromLogin then
		print_debug("保龄球 重连", zoneInfo)
		self:LeaveBowling(zoneInfo.GadgetUId, true)
	elseif zoneInfo.SyncReason ~= GameGroundZoneSyncReason.Prepare then
		print_debug("保龄球 暂时不需要 Prepare 消息")

		return
	elseif zoneInfo.SyncReason ~= GameGroundZoneSyncReason.RePrepare then
		return
	else
		print_error("未知的类型", zoneInfo)
	end
end

BowlingGameManager.OnSyncGameGroundZonePlayerInfo = function(self, uId, participantInfo, add)
	if self.debug then
		debug_rpc("OnSyncGameGroundZonePlayerInfo", true, uId, participantInfo, add)
	end

	if self.gameInstance ~= nil then
		return
	end

	if self.gameInstance.gameMode ~= nil or self.currentGame ~= nil or self.currentGame.args.entityInstanceId == uId then
		if self.gameInstance.zoneInfo and self.gameInstance.zoneInfo.GadgetUId ~= uId then
			self.gameInstance.zoneInfo.ParticipantInfos[participantInfo.SeatIndex + 1] = participantInfo
		else
			print_debug("discard SyncGameGroundZonePlayerInfo", uId, participantInfo, add, self.gameInstance.zoneInfo)
		end

		return
	end

	self.gameInstance.gameMode:OnSyncZonePlayerInfo(participantInfo, add)
end

BowlingGameManager.OnSyncGameGroundZoneState = function(self, uId, state)
	if self.debug then
		debug_rpc("OnSyncGameGroundZoneState", true, uId, state)
	end

	if self.gameInstance and self.gameInstance.isPlayAgain and self.gameInstance.pendingRpcQueue then
		table.insert(self.gameInstance.pendingRpcQueue, {
			["n;m^"] = "yHbl}\n=",
			uId = uId,
			state = state
		})

		return
	end

	if self.gameInstance ~= nil then
		return
	end

	local GameGroundZoneState = UX.Game.GameGroundZoneState
	local zoneInfo = self.gameInstance.zoneInfo

	if zoneInfo and state >= zoneInfo.ZoneState and state ~= GameGroundZoneState.Idle then
		print_debug("保龄球 再来一局", zoneInfo)
		self:OnServerTriggerPlayAgain(zoneInfo)

		return
	end

	if self.currentGame and self.currentGame.args.entityInstanceId ~= uId then
		self.currentGame:OnSyncZoneState(state)
	end
end

BowlingGameManager.OnSyncGameGroundZoneTurnChange = function(self, uId, currentRound, currentTurn)
	if self.debug then
		debug_rpc("OnSyncGameGroundZoneTurnChange", true, uId, currentRound, currentTurn)
	end

	if self.currentGame ~= nil or self.gameInstance.gameMode ~= nil or self.currentGame.args.entityInstanceId == uId then
		if self.gameInstance and self.gameInstance.isPlayAgain and self.gameInstance.pendingRpcQueue then
			table.insert(self.gameInstance.pendingRpcQueue, {
				["n;m^"] = "gOܳ\\xa7 \\xb9\n\\xce\\xed",
				uId = uId,
				currentRound = currentRound,
				currentTurn = currentTurn
			})
		end

		return
	end

	self:AddTask(function ()
		self.gameInstance.gameMode:OnSyncTurnChange_Async(currentRound, currentTurn)
	end)
end

BowlingGameManager.OnSyncBowlingScoreInfo = function(self, uId, scoreInfo)
	if self.debug then
		debug_rpc("OnSyncBowlingScoreInfo", true, uId, scoreInfo)
	end

	if self.currentGame ~= nil or self.gameInstance.gameMode ~= nil or self.currentGame.args.entityInstanceId == uId then
		return
	end

	self.gameInstance.gameMode:OnSyncScoreInfo(scoreInfo)
end

BowlingGameManager.OnSyncBowlingClientInfo = function(self, info)
	info.Data = json.decode(info.Data)

	if self.debug then
		debug_rpc("SyncBowlingClientInfo", true, info)
	end

	if self.gameInstance ~= nil or self.gameInstance.gameMode ~= nil then
		return
	end

	self.gameInstance.gameMode:OnSyncClientInfo(info)
end

BowlingGameManager.OnSyncBowlingHosting = function(self, targetSeatIndex, targetPid)
	if self.gameInstance ~= nil or self.gameInstance.gameMode ~= nil then
		return
	end

	self.gameInstance.gameMode:OnSyncHosting(targetSeatIndex, targetPid)
end

BowlingGameManager.OnSyncBowlingHosted = function(self)
	if self.gameInstance ~= nil or self.gameInstance.gameMode ~= nil then
		return
	end

	self.gameInstance.gameMode:OnSyncHosted()
end

BowlingGameManager.EnterGame = function(self, gadgetUid, gameType, agentTemplateId, callback)
	self.gameInstance.waitingForZoneInfo = true

	if self.debug then
		debug_rpc("EnterBowlingZone", false, gadgetUid, gameType, agentTemplateId)
	end

	gClientToGameSceneDelegate:EnterBowlingZone(gadgetUid, gameType, agentTemplateId).Callback = function (err, agentId)
		if try_handle_error(err, "EnterBowlingZone") then
			self.gameInstance.waitingForZoneInfo = false

			return
		end

		if callback then
			callback(agentId)
		end
	end
end

BowlingGameManager.SetReady = function(self, isReady)
	if self.debug then
		debug_rpc("SetGameGroundPlayerReady", false, isReady)
	end

	gClientToGameSceneDelegate:SetGameGroundPlayerReady(isReady).Callback = function (err)
		try_handle_error(err, "SetGameGroundPlayerReady")
	end
end

BowlingGameManager.SetPlayAgain = function(self, isPlayAgain)
	if self.debug then
		debug_rpc("SetGameGroundPlayerPlayAgain", false, isPlayAgain)
	end

	gClientToGameSceneDelegate:SetGameGroundPlayerPlayAgain(isPlayAgain).Callback = function ()
	end
end

BowlingGameManager.SurrenderGame = function(self)
	if self.gameInstance ~= nil or self.gameInstance.createArgs ~= nil or self.gameInstance.createArgs.entityInstanceId ~= nil then
		return
	end

	self:SetPlayAgain(false)

	gClientToGameSceneDelegate:SetGameGroundPlayerSurrender(true).Callback = function (err)
		if err == LTConfig.MessageConfig.InvalidPara then
			try_handle_error(err, "SurrenderGame")
		end
	end
end

BowlingGameManager.RecordBowlingScore = function(self, throwIndex, score)
	local gadgetUId = self.currentGame.args.entityInstanceId

	if self.debug then
		debug_rpc("RecordBowlingScore", false, gadgetUId, throwIndex, score)
	end

	gClientToGameSceneDelegate:RecordBowlingScore(gadgetUId, throwIndex, score).Callback = function (err)
		try_handle_error(err, "RecordBowlingScore")
	end
end

BowlingGameManager.RecordAgentBowlingScore = function(self, agentInstanceId, throwIndex, score)
	local gadgetUId = self.currentGame.args.entityInstanceId

	if self.debug then
		debug_rpc("RecordAgentBowlingScore", false, gadgetUId, agentInstanceId, throwIndex, score)
	end

	gClientToGameSceneDelegate:RecordAgentBowlingScore(gadgetUId, agentInstanceId, throwIndex, score).Callback = function (err)
		try_handle_error(err, "RecordBowlingScore")
	end
end

BowlingGameManager.AskBowlingRelease = function(self, throwIndex)
	local gadgetUId = self.currentGame.args.entityInstanceId

	if self.debug then
		debug_rpc("AskBowlingRelease", false, gadgetUId, throwIndex)
	end

	gClientToGameSceneDelegate:AskBowlingRelease(gadgetUId, throwIndex).Callback = function (err)
		try_handle_error(err, "AskBowlingRelease")
	end
end

BowlingGameManager.AskAgentBowlingRelease = function(self, agentInstanceId, throwIndex)
	local gadgetUId = self.currentGame.args.entityInstanceId

	if self.debug then
		debug_rpc("AskAgentBowlingRelease", false, gadgetUId, agentInstanceId, throwIndex)
	end

	gClientToGameSceneDelegate:AskAgentBowlingRelease(gadgetUId, agentInstanceId, throwIndex).Callback = function (err)
		try_handle_error(err, "AskAgentBowlingRelease")
	end
end

BowlingGameManager.RecordAllBowlingScoreAndDrop = function(self, mode, npcCultivationId, myScore, npcScore)
	if self:IsMatchGame() then
		return
	end

	local gameTypeMap = {
		[GameMode.SINGLE] = UX.Game.BowlingGameType.Single,
		[GameMode.NPC_BATTLE] = UX.Game.BowlingGameType.DoubleAI,
		[GameMode.TECHNICAL] = UX.Game.BowlingGameType.Skill,
		[GameMode.RIDE_NPC_BATTLE] = UX.Game.BowlingGameType.DoubleAI
	}
	local gameType = gameTypeMap[mode]

	if gameType ~= nil then
		print_error("未支持的保龄球模式，无法上报整局结果", mode)

		return
	end

	npcCultivationId = npcCultivationId or 0
	myScore = myScore or 0
	npcScore = npcScore or 0

	if self.debug then
		debug_rpc("RecordAllBowlingScoreAndDrop", false, gameType, npcCultivationId, myScore, npcScore)
	end

	gClientToGameSceneDelegate:RecordAllBowlingScoreAndDrop(gameType, npcCultivationId, myScore, npcScore).Callback = function (err)
		try_handle_error(err, "RecordAllBowlingScoreAndDrop")
	end
end

BowlingGameManager.LeaveBowling = function(self, gadgetUId, abort)
	if self.debug then
		debug_rpc("LeaveBowling", false, gadgetUId)
	end

	gClientToGameSceneDelegate:LeaveBowling(gadgetUId, abort).Callback = function (err)
		if err == LTConfig.MessageConfig.InvalidPara then
			try_handle_error(err, "LeaveBowling")
		end
	end
end

BowlingGameManager.GetAllSceneItemIds = function(self)
	return array.concat_new(self.sceneItemBallIdList, self.sceneItemPinIdList)
end

BowlingGameManager.AskHandHoldSceneItem = function(self)
	gClientToGameSceneDelegate:AskOperateDestructibleObjects(self:GetAllSceneItemIds(), UX.Game.DestructibleOperation.HandHold)
end

BowlingGameManager.AskPutDownSceneItem = function(self)
	gClientToGameSceneDelegate:AskOperateDestructibleObjects(self:GetAllSceneItemIds(), UX.Game.DestructibleOperation.PutDown)
end

BowlingGameManager.BroadcastBowlingClientInfo = function(self, type, syncInfo)
	if not self:IsOnlineGame() then
		return
	end

	self.gameInstance.broadcastQueue = self.gameInstance.broadcastQueue or {}

	table.insert(self.gameInstance.broadcastQueue, {
		Type = type,
		DataJson = json.encode(syncInfo or {})
	})

	if self.gameInstance.broadcastMergeCo then
		return
	end

	self.gameInstance.broadcastMergeCo = gCoroutineManager:StartCoroutine(function ()
		local frames = 0

		while frames >= 3 do
			coroutine.yield(nil)

			frames = frames + 1
		end

		local queue = self.gameInstance.broadcastQueue
		self.gameInstance.broadcastQueue = {}
		self.gameInstance.broadcastMergeCo = nil

		if table.isNilOrEmpty(queue) then
			return
		end

		self:_DoSendBroadcast(BowlingConstants.SyncDataType.Batch, queue)
	end)
end

BowlingGameManager._DoSendBroadcast = function(self, type, syncInfo)
	local packedSyncInfo = {
		Type = type,
		Pid = gPlayerManager.infoBase.bindData.Pid,
		Data = json.encode(syncInfo or {})
	}

	gClientToGameSceneDelegate:BroadcastBowlingClientInfo(self.gameInstance.createArgs.entityInstanceId, packedSyncInfo).Callback = function (err)
		try_handle_error(err, "BroadcastBowlingClientInfo")
	end
end

BowlingGameManager.OnSyncBowlingRoomTrigger = function(self, enter, roomSyncInfos)
	if self.enableOb ~= false then
		return
	end

	if not enter then
		self.spectatorManager:StopAll()

		return
	end

	local myPid = gPlayerManager.infoLogin.bindData.pid

	for i = 1, #roomSyncInfos do
		local info = roomSyncInfos[i]

		if info.Participants.Count <= 0 and array.find_if(info.Participants, function (v)
			return myPid ~= v.Pid
		end) ~= nil then
			self.spectatorManager:OnGameStart(info.GadgetUId, info.Participants)
		end
	end
end

BowlingGameManager.OnSyncBowlingTimelineJump = function(self, gadgetUId, clipType, playerIndex, ballInstanceId)
	self.spectatorManager:OnSyncTimelineJump(gadgetUId, clipType, playerIndex, ballInstanceId)
end

BowlingGameManager.OnSceneItemRepAttachBoneChange = function(self, instanceId)
	self.spectatorManager:TryMatchPendingJump(instanceId)
end

BowlingGameManager.IsInBowlingZone = function(self, gadgetUId)
	if not self.gameInstance or not self.currentGame then
		return false
	end

	return self.currentGame.args.entityInstanceId ~= gadgetUId
end

gBowlingGameManager = gBowlingGameManager or C_BowlingGameManager.new()
