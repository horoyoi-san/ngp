C_BowlingGameManager = DefClass("C_BowlingGameManager", C_BowlingGameManager, gBaseMiniGameManager)
local BowlingGameManager = C_BowlingGameManager
local json = require("cjson/json")

local function print_debug(...)
	if gBowlingGameManager.debug then
		_G.print_warn("[BowlingGameManager] ", ...)
	end
end

local function print_warn(...)
	_G.print_warn("[BowlingGameManager] ", ...)
end

local function print_error(...)
	_G.print_error("[BowlingGameManager] ", ...)
end

local function debug_rpc(name, fromServer, ...)
	if fromServer then
		_G.print_warn("[BowlingGameManager] RPC: " .. name .. " ", ...)
	else
		_G.print_warn("[BowlingGameManager] RPC: " .. name .. " ", ...)
		_G.print_warn("[BowlingGameManager] RPC: " .. name, debug.traceback(" stack=", 3))
	end
end

local function try_handle_error(err, rpcName)
	if err ~= LTConfig.MessageConfig.Ok then
		gDisplayMessageMgr:DisplayServerMessageId(err)
		print_error_without_stack("[BowlingGameManager] RPC error in callback: " .. (rpcName or "unknown"), err, LTConfig.MessageConfig.GetConfig(err).Content)

		return true
	end

	return false
end

local GameGroundZoneSyncReason = UX.Game.GameGroundZoneSyncReason
local BowlingConstants = require("LX6/MiniGame/BowlingGame/BowlingConstants")
local GameMode = BowlingConstants.GameMode

function BowlingGameManager:ctor()
	self.debug = false

	self:InitConstants()

	self.sceneItemBallIdList = {}
	self.sceneItemPinIdList = {}
end

function BowlingGameManager:InitConstants()
	self.sceneItemType = {
		Pin = 101,
		Ball = 1,
		BallMax = 100
	}
	self.ballNum = 5
end

function BowlingGameManager:RemoveMessageListeners()
	if self.msgHandlers then
		for k, v in pairs(self.msgHandlers) do
			gMessageManager:RemoveMessageListener(k, v)
		end

		self.msgHandlers = nil
	end
end

function BowlingGameManager:DestroyGame()
	print_debug("now destroy bowling game", self.gameInstance, self.currentGame)
	self:RemoveMessageListeners()

	if self.gameInstance and self.gameInstance.lastDOTweenUseSafeMode ~= nil then
		DOTween.useSafeMode = self.gameInstance.lastDOTweenUseSafeMode
	end

	BowlingGameManager.base.DestroyGame(self)

	if self.debug then
		local function print_count(name)
			local tbl = self and self.gameInstance and self.gameInstance[name]

			if table.isNilOrEmpty(tbl) then
				print_debug(name, "has no data")
			else
				local cnt1 = 0
				local cnt2 = 0

				for k, v in pairs(tbl) do
					if v.rent == false then
						cnt1 = cnt1 + 1
					else
						cnt2 = cnt2 + 1

						if gClientUtils.NotNil(v.go) and gClientUtils.NotNil(v.origRoot) then
							v.go.transform:SetParent(v.origRoot)
							print_debug("collect item", k, v)
						else
							print_debug("item is destroyed!", k, v)
						end
					end
				end

				print_debug(name, " [no rent] ", cnt1, " [rent] ", cnt2)
			end
		end

		print_count("sceneItemBallList")
		print_count("sceneItemPinList")
	end

	if self.zoneInfo then
		array.remove_if_all(self.sceneItemBallIdList, function (v)
			return array.contains(self.zoneInfo.BowlingBallSceneItemIdList, v)
		end)
		array.remove_if_all(self.sceneItemPinIdList, function (v)
			return array.contains(self.zoneInfo.BowlingPinSceneItemIdList, v)
		end)

		if self.zoneInfo.GameType == UX.Game.BowlingGameType.Single then
			self:LeaveBowling(self.createArgs.entityInstanceId)
		else
			self:AskPutDownSceneItem()
		end
	end

	for i, v in ipairs(self.sceneItemBallIdList) do
		gCS.SceneItemMgr:TagAndLoadGameobject(v, false)
	end

	for i, v in ipairs(self.sceneItemPinIdList) do
		gCS.SceneItemMgr:TagAndLoadGameobject(v, false)
	end

	self.zoneInfo = nil
	self.gameInstance = nil
	self.gadgetEntity = nil
	self.currentGame = nil
end

function BowlingGameManager:CreateAndStartGame(mode, args)
	if not self or self.currentGame then
		return
	end

	if self.debugIndex then
		args.entityInstanceId = ulong.new(self.debugIndex, 0)
	end

	args.zoneInfo = self.zoneInfo
	self.gameInstance = {}

	self:RemoveMessageListeners()

	self.msgHandlers = {
		[gEventConstants.BEFORE_SWITCH_SCENE] = function (_, switchType)
			if gSwitchSceneType.Reconnect <= switchType then
				self:DestroyGame()
			end
		end
	}

	for k, v in pairs(self.msgHandlers) do
		gMessageManager:AddMessageListener(k, v)
	end

	self.gameInstance.lastDOTweenUseSafeMode = DOTween.useSafeMode
	DOTween.useSafeMode = true

	self:InitSceneItems()

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None and mode ~= GameMode.ONLINE_BATTLE then
		self:AskHandHoldSceneItem()
	end

	for _, v in ipairs(self.gameInstance.sceneItemBallList) do
		local go = v.go

		if gClientUtils.NotNil(go) then
			local comp = go:GetOrAddComponent(typeof(LX6.Audio.PhysicsColliderSound))
			comp.soundId = LTConfig.PoiGameConfig.BowlingSound_GutterBump
			comp.isOnlyOnce = false
			comp.isDynamic = true
			comp.otherMask = LayerMask.GetMask("Floor")
			comp.sendVelocityAndImpulse = true
		end
	end

	self.currentGame = gBowlingGame.new(args)

	self.currentGame:ExecuteSelectMode(mode)

	self.gameMode = self.currentGame.gameMode
end

function BowlingGameManager:CreateAndStartGameCs(mode, npcId, position, rotation, entityInstanceId)
	local function StartGame()
		local args = {
			agentTemplateId = 40130937,
			mode = mode,
			npcId = npcId,
			wayPointPosition = position,
			wayPointRotation = rotation,
			entityInstanceId = entityInstanceId
		}
		self.createArgs = args

		self:CreateAndStartGame(mode, args)
	end

	if mode == GameMode.ONLINE_BATTLE then
		self:TriggerOnlineGameFromGadget(entityInstanceId, StartGame)
	else
		self:TriggerClientGameFromGadget(entityInstanceId, StartGame)
	end
end

function BowlingGameManager:TriggerOnlineGameFromGadget(entityInstanceId, startGameFunction)
	if self.waitSceneItemAndGadgetCo then
		print_error("流程不对！数据还没准备好就进游戏了")
		coroutine.start(function ()
			local endWaitTime = Time.realtimeSinceStartup + 20

			while self.waitSceneItemAndGadgetCo and Time.realtimeSinceStartup < endWaitTime do
				coroutine.step()
			end

			if self.waitSceneItemAndGadgetCo then
				print_error("数据加载超时，进不了游戏了")
				self:LeaveBowling(entityInstanceId)
			else
				startGameFunction()
			end
		end)
	else
		startGameFunction()
	end
end

function BowlingGameManager:TriggerClientGameFromGadget(entityInstanceId, startGameFunction)
	self.startGameFunction = startGameFunction

	self:EnterGame(entityInstanceId, UX.Game.BowlingGameType.Single, 0)
end

function BowlingGameManager:CreateGameFromServer(zoneInfo)
	print_debug("CreateGameFromServer")

	if zoneInfo.SyncReason == GameGroundZoneSyncReason.Enter then
		self:CreateGameFromServerImpl(zoneInfo)
	elseif zoneInfo.SyncReason == GameGroundZoneSyncReason.ReEnter then
		print_warn("保龄球 重连", zoneInfo)
		self:CreateGameFromServerImpl(zoneInfo)
	elseif zoneInfo.SyncReason == GameGroundZoneSyncReason.Prepare then
		print_warn("保龄球 暂时不需要 Prepare 消息")

		return
	else
		print_error("未知的类型", zoneInfo)
	end
end

function BowlingGameManager:CreateGameFromServerImpl(zoneInfo)
	if self.waitSceneItemAndGadgetCo then
		return
	end

	self.zoneInfo = zoneInfo

	self:WaitSceneItemAndGadget(zoneInfo, function (gadgetEntity)
		self.gadgetEntity = gadgetEntity

		if zoneInfo.GameType == UX.Game.BowlingGameType.Single then
			if self.startGameFunction then
				self.startGameFunction()

				self.startGameFunction = nil
			else
				print_error("没有触发 CreateAndStartGameCs")
			end
		elseif zoneInfo.GameType == UX.Game.BowlingGameType.DoublePlayer then
			self:SendSignalToGadget("StartOnlineBattleFromLink")
		else
			print_error("未知的 GameType", zoneInfo)
		end
	end)
end

function BowlingGameManager:WaitSceneItemAndGadget(zoneInfo, callback)
	local waitCoroutine = nil
	waitCoroutine = coroutine.start(function ()
		coroutine.step()

		self.waitSceneItemAndGadgetCo = waitCoroutine
		local endWaitTime = Time.realtimeSinceStartup + 5
		local sceneItemLoaded = false

		while not sceneItemLoaded and Time.realtimeSinceStartup < endWaitTime do
			sceneItemLoaded = self:CheckDisableSceneItems(zoneInfo.BowlingBallSceneItemIdList) and self:CheckDisableSceneItems(zoneInfo.BowlingPinSceneItemIdList)

			coroutine.step()
		end

		if not sceneItemLoaded then
			print_warn("[BowlingGameManager] 服务器创建的 scene item 一直没加载出 go，跳过！")
		end

		self.sceneItemBallIdList = array.concat(self.sceneItemBallIdList, zoneInfo.BowlingBallSceneItemIdList)
		self.sceneItemPinIdList = array.concat(self.sceneItemPinIdList, zoneInfo.BowlingPinSceneItemIdList)
		local gadgetUId = zoneInfo.GadgetUId
		self.GadgetUId = gadgetUId

		print_debug("保龄球 等机关加载", gadgetUId, "当前", gGadgetManager:GetEntitySearchByInstanceId(gadgetUId))

		local fail = false
		local waitGadgetOk = false

		L50.L50App.Scene.SpoonGadgetManager:RegisterWaitLoad({
			gadgetUId
		}, function (gadgetEntity)
			print_debug("RegisterWaitLoad OK ", gadgetUId)

			if self.waitSceneItemAndGadgetCo ~= waitCoroutine then
				print_error("这个协程不是 self.waitSceneItemAndGadgetCo！可能会有流程问题")
				coroutine.stop(waitCoroutine)
			end

			coroutine.stop(self.waitSceneItemAndGadgetCo)

			self.waitSceneItemAndGadgetCo = nil
			waitGadgetOk = true

			if fail then
				print_error("保龄球 机关加载好了，但是已经超时了，无法进游戏", gadgetUId)
			else
				print_debug("保龄球 机关加载好了", gadgetUId)

				if callback then
					callback(gadgetEntity)
				end
			end
		end)
		coroutine.wait(20)

		if not waitGadgetOk then
			fail = true

			self:LeaveBowling(gadgetUId)

			self.waitSceneItemAndGadgetCo = nil
		end
	end)
end

function BowlingGameManager:ExecuteExitGame()
	if self == nil then
		return
	end

	if self.currentGame then
		self.currentGame:GameOver()
		self.currentGame:CleanGame()
	end

	self.gameMode = nil

	self:DestroyGame()
end

function BowlingGameManager:RegisterSceneItemBall(ball)
	table.insert(self.sceneItemBallIdList, ball)
end

function BowlingGameManager:RegisterSceneItemPin(pin)
	table.insert(self.sceneItemPinIdList, pin)
end

function BowlingGameManager:InitSceneItems()
	local function getItemsFromIdList(idList, maxCount)
		local goList = {}

		for i = #idList, 1, -1 do
			local id = idList[i]
			local hold = gCS.SceneItemMgr:GetSceneItemHold(id)
			local go = hold and hold.SceneItemObj

			if go then
				gCS.SceneItemMgr:TagAndLoadGameobject(id)
				gCS.LuaUtils.SetSceneItemRecoverDelayView(id)

				local item = {
					rent = false,
					go = go,
					hold = hold,
					id = id,
					origRoot = go.transform.parent
				}

				table.insert(goList, item)

				if #goList == maxCount then
					break
				end
			elseif hold == nil then
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

function BowlingGameManager:Rent(type, parent)
	local foundItem, go = nil

	if type <= self.sceneItemType.BallMax then
		local item = self.gameInstance.sceneItemBallList[type]

		if item == nil then
			print_error("[BowlingGameManager] type", type, "is not supported")

			return nil
		end

		foundItem = item
		go = item.go
		item.rent = true
	elseif type == self.sceneItemType.Pin then
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
	else
		print_error("[BowlingGameManager] type", type, "is not supported")
	end

	if foundItem == nil then
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

function BowlingGameManager:Return(type, go)
	if type == nil then
		print_error("[BowlingGameManager] passed a nil type", go)

		return
	end

	if go == nil then
		print_error("[BowlingGameManager] return a nil object", type)

		return
	end

	local destroyed = gCS.LuaUtils.IsNull(go)
	local item = nil

	if type <= self.sceneItemType.BallMax then
		item = self.gameInstance.sceneItemBallList[type]
	elseif type == self.sceneItemType.Pin then
		local v, _ = array.find_if(self.gameInstance.sceneItemPinList, function (i)
			return i.go == go and i.rent
		end)
		item = v
	else
		print_error("[BowlingGameManager] type", type, "is not supported")
	end

	if item == nil then
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

function BowlingGameManager:ActivateSceneItem(hold)
	self:SetCollidersEnabled(hold.SceneItemObj, true)
	hold:SetUseGravity(true)
end

function BowlingGameManager:CheckDisableSceneItems(idList)
	for _, v in ipairs(idList) do
		gCS.SceneItemMgr:TagAndLoadGameobject(v)

		local hold = gCS.SceneItemMgr:GetSceneItemHold(v)

		if hold == nil or hold.SceneItemObj == nil then
			print_debug("CheckDisableSceneItem ", v, " failed")

			return false
		end

		self:DisableSceneItemSimple(hold)
		print_debug("CheckDisableSceneItem ", v, " ok")
	end

	return true
end

function BowlingGameManager:DisableSceneItemSimple(hold)
	if hold == nil or hold.InstanceId == self.doNotDisableBallId then
		return
	end

	hold:SetKinematic(true)
	hold:SetUseGravity(false)
	hold:SyncPositionAndRotation(gCS.MyPlayerManager.PlayerUnit.PlayerObj.position + Vector3.Fetch(0, -1, 0), Quaternion.identity)
	self:SetCollidersEnabled(hold.SceneItemObj, false)
end

function BowlingGameManager:DisableBalls()
	if (self.gameInstance or {}).sceneItemBallList == nil then
		return
	end

	for i = 1, self.ballNum do
		self:DisableSceneItemSimple((self.gameInstance.sceneItemBallList[i] or {}).hold)
	end
end

function BowlingGameManager:SetCollidersEnabled(go, enabled)
	if gClientUtils.IsNil(go) then
		return
	end

	local colliders = go:GetComponentsInChildren(typeof(UnityEngine.Collider)):ToTable()

	for _, v in ipairs(colliders) do
		v.enabled = enabled
	end
end

function BowlingGameManager:Destroy(object)
	print_debug("[BowlingGameManager] Destroy", object and object.name, object and tolua.typeof(object))

	if object then
		UnityEngine.Object.Destroy(object)
	end
end

function BowlingGameManager:DestroyImmediate(object)
	print_debug("[BowlingGameManager] DestroyImmediate", object and object.name, object and tolua.typeof(object))

	if object then
		UnityEngine.Object.DestroyImmediate(object)
	end
end

function BowlingGameManager:SendSignalToGadget(signal)
	if self.gadgetEntity then
		self.gadgetEntity:TryCallInnerSignal(signal)
	end
end

function BowlingGameManager:IsOnlineGame()
	local gameMode = self.currentGame and self.gameMode

	if gameMode then
		return gameMode:GetClassType() == gBowlingModeOnline
	else
		return false
	end
end

function BowlingGameManager:OnSyncGameGroundZoneInfo(zoneInfo)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("OnSyncGameGroundZoneInfo", true, zoneInfo)
	end

	if self.currentGame == nil then
		self:CreateGameFromServer(zoneInfo)

		return
	end

	if self.currentGame.args.entityInstanceId ~= zoneInfo.GadgetUId then
		return
	end

	if self.waitingForZoneInfo then
		self.waitingForZoneInfo = false
	end

	self.currentGame:OnSyncZoneInfo(zoneInfo)
end

function BowlingGameManager:OnSyncGameGroundZonePlayerInfo(uId, participantInfo, add)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("OnSyncGameGroundZonePlayerInfo", true, uId, participantInfo, add)
	end

	if self.currentGame == nil or self.currentGame.args.entityInstanceId ~= uId then
		if self.zoneInfo and self.zoneInfo.GadgetUId == uId then
			self.zoneInfo.ParticipantInfos[participantInfo.SeatIndex + 1] = participantInfo
		end

		return
	end

	self.gameMode:OnSyncZonePlayerInfo(participantInfo, add)
end

function BowlingGameManager:OnSyncGameGroundZoneState(uId, state)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("OnSyncGameGroundZoneState", true, uId, state)
	end

	if self.currentGame == nil or self.currentGame.args.entityInstanceId ~= uId then
		return
	end

	self.currentGame:OnSyncZoneState(state)
end

function BowlingGameManager:OnSyncGameGroundZoneTurnChange(uId, currentRound, currentTurn)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("OnSyncGameGroundZoneTurnChange", true, uId, currentRound, currentTurn)
	end

	if self.currentGame == nil or self.currentGame.args.entityInstanceId ~= uId then
		return
	end

	self.gameMode:OnSyncTurnChange(currentRound, currentTurn)
end

function BowlingGameManager:OnSyncBowlingScoreInfo(uId, scoreInfo)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("OnSyncBowlingScoreInfo", true, uId, scoreInfo)
	end

	if self.currentGame == nil or self.currentGame.args.entityInstanceId ~= uId then
		return
	end

	self.gameMode:OnSyncScoreInfo(scoreInfo)
end

function BowlingGameManager:OnSyncBowlingClientInfo(info)
	info.Data = json.decode(info.Data)

	if gCS.LuaUtils.IsDebug then
		debug_rpc("SyncBowlingClientInfo", true, info)
	end

	if self.currentGame == nil then
		return
	end

	self.gameMode:OnSyncClientInfo(info)
end

function BowlingGameManager:EnterGame(gadgetUid, gameType, agentTemplateId, callback)
	self.enterCallback = callback
	self.pendingGameType = gameType
	self.waitingForZoneInfo = true

	if gCS.LuaUtils.IsDebug then
		debug_rpc("EnterBowlingZone", false, gadgetUid, gameType, agentTemplateId)
	end

	gClientToGameSceneDelegate:EnterBowlingZone(gadgetUid, gameType, agentTemplateId).Callback = function (err, agentId)
		if try_handle_error(err, "EnterBowlingZone") then
			self.waitingForZoneInfo = false

			return
		end

		if callback then
			callback(agentId)
		end
	end
end

function BowlingGameManager:SetReady(isReady)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("SetGameGroundPlayerReady", false, isReady)
	end

	gClientToGameSceneDelegate:SetGameGroundPlayerReady(isReady).Callback = function (err)
		if try_handle_error(err, "SetGameGroundPlayerReady") then
			return
		end
	end
end

function BowlingGameManager:SetPlayAgain(isPlayAgain)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("SetGameGroundPlayerPlayAgain", false, isPlayAgain)
	end

	gClientToGameSceneDelegate:SetGameGroundPlayerPlayAgain(isPlayAgain).Callback = function (err)
		if try_handle_error(err, "SetGameGroundPlayerPlayAgain") then
			return
		end
	end
end

function BowlingGameManager:RecordBowlingScore(gadgetUId, throwIndex, score)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("RecordBowlingScore", false, gadgetUId, throwIndex, score)
	end

	gClientToGameSceneDelegate:RecordBowlingScore(gadgetUId, throwIndex, score).Callback = function (err)
		if try_handle_error(err, "RecordBowlingScore") then
			return
		end
	end
end

function BowlingGameManager:RecordAgentBowlingScore(gadgetUId, npcId, throwIndex, score)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("RecordAgentBowlingScore", false, gadgetUId, npcId, throwIndex, score)
	end

	gClientToGameSceneDelegate:RecordAgentBowlingScore(gadgetUId, npcId, throwIndex, score).Callback = function (err)
		if try_handle_error(err, "RecordAgentBowlingScore") then
			return
		end
	end
end

function BowlingGameManager:LeaveBowling(gadgetUId)
	if gCS.LuaUtils.IsDebug then
		debug_rpc("LeaveBowling", false, gadgetUId)
	end

	gClientToGameSceneDelegate:LeaveBowling(gadgetUId).Callback = function (err)
		if try_handle_error(err, "LeaveBowling") then
			return
		end
	end
end

function BowlingGameManager:AskHandHoldSceneItem()
	for _, entityId in ipairs(self.sceneItemBallIdList) do
		gClientToGameSceneDelegate:AskHandHoldDestructibleObject(entityId)
	end

	for _, entityId in ipairs(self.sceneItemPinIdList) do
		gClientToGameSceneDelegate:AskHandHoldDestructibleObject(entityId)
	end
end

function BowlingGameManager:AskPutDownSceneItem()
	for _, entityId in ipairs(self.sceneItemBallIdList) do
		gClientToGameSceneDelegate:AskPutDownDestructibleObject(entityId)
	end

	for _, entityId in ipairs(self.sceneItemPinIdList) do
		gClientToGameSceneDelegate:AskPutDownDestructibleObject(entityId)
	end
end

function BowlingGameManager:BroadcastBowlingClientInfo(type, syncInfo)
	if not self:IsOnlineGame() then
		return
	end

	local packedSyncInfo = {
		Type = type,
		Pid = gPlayerManager.infoBase.bindData.Pid,
		Data = json.encode(syncInfo or {})
	}

	gClientToGameSceneDelegate:BroadcastBowlingClientInfo(self.createArgs.entityInstanceId, packedSyncInfo).Callback = function (err)
		try_handle_error(err, "BroadcastBowlingClientInfo")
	end
end

gBowlingGameManager = gBowlingGameManager or C_BowlingGameManager.new()
