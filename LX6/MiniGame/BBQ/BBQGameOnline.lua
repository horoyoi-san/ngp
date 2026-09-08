-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGameOnline.lua
-- Decompiled from: 00674_BBQGameOnline.lua_80c3d395615e.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local MeatCookedLevel = BBQConstants.MeatCookedLevel
local MeatState = BBQConstants.MeatState
local GamePhase = BBQConstants.GamePhase
local PartType = BBQConstants.PartType
local LayerConstants = LX6.Constants.LayerConstants
gBBQGameOnline = DefClass("BBQGameOnline", gBBQGameOnline, gBaseMiniGame)
local M = gBBQGameOnline
local PICKUP_INFLIGHT_TIMEOUT = 2
local PLACE_CONFIRM_TIMEOUT = 2

M.Initialize = function(self, args)
	self.args = args
	self.gadgetUId = args.gadgetUId
	self.zoneInfo = args.zoneInfo
	self.mySeatIndex = -1
	self.players = {}
	self.meats = {}
	self.burntMeatIds = {}
	self.grillCache = gBBQGrillCache.new()
	self.grill = nil
	self.plates = {}
	self.sauceBowls = {}
	self.sceneNodeGo = args.sceneNodeGo
	self.meatTemplates = {}
	self.materialCache = {}
	self.cameraGo = nil
	self.meatPool = nil
	self.meatPoolByType = {}
	self.gamePhase = GamePhase.Prepare
	self.totalTime = args.zoneInfo and args.zoneInfo.GameDurationSeconds or BBQConstants.DefaultGameTime
	self.prepareTime = BBQConstants.DefaultPrepareTime
	self.gameTimer = self.totalTime
	self.prepareTimer = 0
	self.playerInputPositions = {
		[0] = {
			["\\xd5"] = 0,
			["\\xd4"] = 0
		},
		{
			["\\xd5"] = 0,
			["\\xd4"] = 0
		},
		{
			["\\xd5"] = 0,
			["\\xd4"] = 0
		},
		{
			["\\xd5"] = 0,
			["\\xd4"] = 0
		}
	}
	self.m_MeatLastSyncTime = {}
	self.m_ChopstickSyncFrameCounter = 0
	self.m_ChopstickTargets = {}
	self.m_ChopstickHolding = {}
	self.m_ParticipantBySeat = {}
	self.m_PickupInFlight = false
	self.m_PickupInFlightTime = 0
	self.m_PendingReleaseAction = nil
	self.m_PendingPlaceConfirm = nil
	self.m_IsInputTakenOver = false
	self.m_HoverEffectUUID = nil
	self.m_HoverMeatId = nil
	self.m_GrillHadMeat = false

	self:SetSceneOtherNodesVisible(false)
end

M.StartGame = function(self)
	if not self.sceneNodeGo or gClientUtils.IsNil(self.sceneNodeGo) then
		print_warn("[BBQGameOnline] StartGame 时 sceneNodeGo 为空，无法初始化")

		return false
	end

	self.InitMaterialCache(self, function ()
		if self.hasDestroy then
			return
		end

		self:InitScene()
		self:InitPlayers()
		self:StartGameCoroutine()
	end)

	return true
end

M.InitMaterialCache = function(self, onDone)
	self._materialLoadOps = {}
	local pendingCount = 0

	local tryDone = function()
		pendingCount = pendingCount - 1

		if pendingCount ~= 0 and onDone then
			onDone()
		end
	end

	for meatType, levelPaths in pairs(BBQConfig.MaterialPaths) do
		if not self.materialCache[meatType] then
			self.materialCache[meatType] = {}
		end

		for level, path in pairs(levelPaths) do
			pendingCount = pendingCount + 1
			local mt = meatType
			local lv = level
			slot16 = gResourceManager
			local op = slot16:LoadAssetWithCallBack(path, typeof(UnityEngine.Material), function (loadOp)
				if not self.hasDestroy then
					self.materialCache[mt][lv] = loadOp.asset
				end

				tryDone()
			end)

			table.insert(self._materialLoadOps, op)
		end
	end

	if pendingCount ~= 0 and onDone then
		onDone()
	end
end

M.InitScene = function(self)
	local sceneTrans = self.sceneNodeGo.transform
	local poolTrans = self.FindChildRecursive(self, sceneTrans, "ObjectPool")

	if poolTrans then
		self.meatPool = poolTrans.gameObject
	else
		print_error("[BBQGameOnline] 未找到 ObjectPool 节点")
	end

	local camTrans = self.FindChildRecursive(self, sceneTrans, "Cam")

	if camTrans then
		self.cameraGo = camTrans.gameObject

		if self.gamePhase ~= GamePhase.Playing then
			self.SetCameraActive(self, true)
		end
	else
		print_warn("[BBQGameOnline] 未找到相机节点 Cam")
	end

	self.InitMeatTemplates(self)
	self.InitPartsFromScene(self)
end

M.SetCameraActive = function(self, active)
	if gClientUtils.NotNil(self.cameraGo) then
		self.cameraGo:SetActive(active)

		if active then
			gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.BBQ_PANEL_STORE, LX6.Constants.LayerConstants.AllWithoutPlayerAndNpc)
		else
			gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.BBQ_PANEL_STORE)
		end
	end
end

M.FindChildRecursive = function(self, rootTrans, name)
	local direct = rootTrans.Find(rootTrans, name)

	if direct then
		return direct
	end

	for i = 0, rootTrans.childCount - 1 do
		local child = rootTrans.GetChild(rootTrans, i)
		local found = self.FindChildRecursive(self, child, name)

		if found then
			return found
		end
	end

	return nil
end

M.InitMeatTemplates = function(self)
	local sceneTrans = self.sceneNodeGo.transform

	for plateName, meatType in pairs(BBQConfig.PlateMeatTypeMap) do
		local meatNodeName = plateName.gsub(plateName, "^BBQPlate", "BBQMeat")
		local meatTrans = self.FindChildRecursive(self, sceneTrans, meatNodeName)

		if meatTrans then
			meatTrans.gameObject:SetActive(false)

			self.meatTemplates[meatType] = meatTrans.gameObject
		else
			print_warn("[BBQGameOnline] 未找到肉模板: " .. meatNodeName)
		end
	end
end

M.InitPartsFromScene = function(self)
	local sceneTrans = self.sceneNodeGo.transform
	local potPartTrans = self.FindChildRecursive(self, sceneTrans, "PotPart")

	if potPartTrans then
		self.grill = gBBQGrill.new(potPartTrans)
	else
		print_error("[BBQGameOnline] 未找到烤架 PotPart 节点")
	end

	local platesParent = sceneTrans.Find(sceneTrans, "plateParts")

	for plateName, meatType in pairs(BBQConfig.PlateMeatTypeMap) do
		local plateTrans = platesParent and platesParent:Find(plateName)

		if plateTrans then
			local plate = gBBQPlate.new(plateName, plateTrans)
			plate.meatType = meatType
			self.plates[plateName] = plate
		else
			print_warn("[BBQGameOnline] 未找到盘子: " .. plateName)
		end
	end

	for playerId, relPath in pairs(BBQConstants.SeatToSauceNode) do
		local sauceTrans = self.FindChildRecursive(self, sceneTrans, relPath)

		if sauceTrans then
			self.sauceBowls[playerId] = gBBQSauceBowl.new(playerId, sauceTrans)
		else
			print_warn("[BBQGameOnline] 未找到蘸碟: " .. relPath)
		end
	end
end

M.InitPlayers = function(self)
	for playerId = 0, BBQConstants.MaxPlayers - 1 do
		local player = gBBQPlayer.new()

		player:Initialize(playerId, playerId ~= self.mySeatIndex, false)

		self.players[playerId + 1] = player
		self.playerInputPositions[playerId] = {
			["\\xd5"] = 0,
			["\\xd4"] = 0
		}
	end
end

M.StartGameCoroutine = function(self)
	self.mainCoroutine = coroutine.start(function ()
		while self.gamePhase == GamePhase.Playing do
			coroutine.wait(0)

			if self.hasDestroy then
				return
			end

			if gClientUtils.IsNil(self.sceneNodeGo) then
				self:OnSceneDestroyed()

				return
			end
		end

		while self.gamePhase ~= GamePhase.Playing do
			coroutine.wait(0)

			if self.hasDestroy then
				return
			end

			if self.gameTimer <= 0 then
				self.gameTimer = self.gameTimer - UnityEngine.Time.deltaTime
			end

			self:UpdateGame()
		end
	end)
end

M.OnBattleStart = function(self)
	self.gamePhase = GamePhase.Playing
	self.gameTimer = self.totalTime

	self.SetCameraActive(self, true)
end

M.OnGameEnd = function(self, endInfo)
	self.gamePhase = GamePhase.End
	self.gameTimer = 0

	self.StopHoverOutline(self)
end

M.ResetForPlayAgain = function(self, zoneInfo)
	print_debug("[BBQGameOnline] ResetForPlayAgain — 清空上一局状态")

	for _, meat in pairs(self.meats) do
		meat.Destroy(meat)
	end

	for _, pool in pairs(self.meatPoolByType) do
		for _, meat in ipairs(pool) do
			meat.Destroy(meat)
		end
	end

	self.meats = {}
	self.meatPoolByType = {}
	self.m_MeatLastSyncTime = {}
	self.burntMeatIds = {}

	self.grillCache:Clear()

	self.m_GrillHadMeat = false
	self.m_ChopstickTargets = {}
	self.m_ChopstickHolding = {}
	self.m_ChopstickSyncFrameCounter = 0
	self.m_PickupInFlight = false
	self.m_PickupInFlightTime = 0
	self.m_PendingReleaseAction = nil
	self.m_PendingPlaceConfirm = nil

	for _, player in pairs(self.players) do
		player.draggedPartId = -1
		player.hasEnterDrag = false
		player.totalScore = 0
		player.singleAddScore = 0
		player.pressTargetType = nil
		player.pressPartId = nil
		player.hasPressTarget = nil
	end

	self.gamePhase = GamePhase.Prepare
	self.gameTimer = self.totalTime
	self.prepareTimer = 0

	if self.mainCoroutine then
		coroutine.stop(self.mainCoroutine)

		self.mainCoroutine = nil
	end

	self.StartGameCoroutine(self)

	self.m_ParticipantBySeat = {}

	if zoneInfo and zoneInfo.ParticipantInfos then
		for _, info in ipairs(zoneInfo.ParticipantInfos) do
			self.m_ParticipantBySeat[info.SeatIndex] = info
		end
	end
end

M.OnSceneDestroyed = function(self)
	self.hasDestroy = true

	coroutine.start(function ()
		coroutine.wait(0)

		if gBBQGameManager then
			gBBQGameManager:StopBBQGame()
		end
	end)
end

M.CleanGame = function(self)
	self.CleanupAndDestroy(self)
end

M.CleanupAndDestroy = function(self)
	self.hasDestroy = true

	self.StopHoverOutline(self)

	if self.mainCoroutine then
		coroutine.stop(self.mainCoroutine)

		self.mainCoroutine = nil
	end

	if self._materialLoadOps then
		for _, op in ipairs(self._materialLoadOps) do
			gResourceManager:UnloadAssetLoadOp(op)
		end

		self._materialLoadOps = nil
	end

	for _, meat in pairs(self.meats) do
		meat.Destroy(meat)
	end

	for _, pool in pairs(self.meatPoolByType) do
		for _, meat in ipairs(pool) do
			meat.Destroy(meat)
		end
	end

	self.meatPool = nil
	self.meatPoolByType = {}
	self.meats = {}
	self.m_MeatLastSyncTime = {}

	if gClientUtils.NotNil(self.cameraGo) then
		self.cameraGo:SetActive(false)
	end

	self.cameraGo = nil

	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.BBQ_PANEL_STORE)

	self.burntMeatIds = {}
	self.materialCache = {}
	self.meatTemplates = {}
	self.plates = {}
	self.sauceBowls = {}
	self.grill = nil
	self.sceneNodeGo = nil

	self.grillCache:Clear()

	self.m_ChopstickTargets = {}
	self.m_ChopstickHolding = {}
	self.m_ParticipantBySeat = {}
	self.m_ChopstickSyncFrameCounter = 0
	self.m_PickupInFlight = false
	self.m_PickupInFlightTime = 0
	self.m_PendingReleaseAction = nil
	self.m_PendingPlaceConfirm = nil

	for _, player in pairs(self.players) do
		player.Reset(player)
	end

	self.SetSceneOtherNodesVisible(self, true)
end

M.UpdateGame = function(self)
	if gClientUtils.IsNil(self.sceneNodeGo) then
		self.OnSceneDestroyed(self)

		return
	end

	self:UpdatePickupInFlightTimeout()
	self:UpdatePlaceConfirmTimeout()
	self:UpdateAllMeats()
	self:UpdateInput()
	self.grillCache:UpdateCacheIfNeeded(self:GetAllGrillMeatData())
	self:UpdateHoverOutline()
	self:CheckGrillStateChange()
end

M.UpdatePickupInFlightTimeout = function(self)
	if not self.m_PickupInFlight then
		return
	end

	if PICKUP_INFLIGHT_TIMEOUT >= UnityEngine.Time.time - (self.m_PickupInFlightTime or 0) then
		print_warn("[BBQGameOnline] pickup in-flight 超时未确认，复位 m_PickupInFlight")

		self.m_PickupInFlight = false
		self.m_PendingReleaseAction = nil
	end
end

M.UpdatePlaceConfirmTimeout = function(self)
	local pending = self.m_PendingPlaceConfirm

	if not pending then
		return
	end

	if PLACE_CONFIRM_TIMEOUT >= UnityEngine.Time.time - (pending.time or 0) then
		self.m_PendingPlaceConfirm = nil

		print_warn("[BBQGameOnline] 放置确认超时 meatId=", pending.meatId, "，按 RPC 未执行恢复持有")
		self.OnPlaceMeatRpcFailed(self, pending.meatId)
	end
end

M._TrackPlaceConfirm = function(self, meatId)
	self.m_PendingPlaceConfirm = {
		meatId = meatId,
		time = UnityEngine.Time.time
	}
end

M._ClearPlaceConfirm = function(self, meatId)
	if self.m_PendingPlaceConfirm and self.m_PendingPlaceConfirm.meatId ~= meatId then
		self.m_PendingPlaceConfirm = nil
	end
end

M.UpdateAllMeats = function(self)
	for _, meat in pairs(self.meats) do
		if meat.isCooking and not meat.meatData.isBurnt then
			meat.UpdateCooking(meat, function (m)
				return m.GetUpSideDot(m)
			end, function (m)
				self:OnMeatBurntInGame(m)
			end)
		end
	end
end

M.OnMeatBurntInGame = function(self, meat)
	table.insert(self.burntMeatIds, meat.id)
end

M.UpdateInput = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	local screenX, screenY = nil

	if not self.m_IsInputTakenOver then
		if GameDevice.KeyboardMouse >= InputActionBind.activeGameDevice then
			local screenPos = SGUI.UCursorInput.GetCursorScreenPos()
			screenY = screenPos.y
			screenX = screenPos.x
		else
			local mousePos = UnityEngine.Input.mousePosition
			screenY = mousePos.y
			screenX = mousePos.x
		end

		player.inputPosition = {
			x = screenX,
			y = screenY
		}
		self.playerInputPositions[self.mySeatIndex] = player.inputPosition
	else
		screenX = player.inputPosition and player.inputPosition.x or 0
		screenY = player.inputPosition and player.inputPosition.y or 0
	end

	self:DoPlayerRaycast(player)

	if player.hasEnterDrag and player.draggedPartId > 0 then
		local meat = self.meats[player.draggedPartId]

		if meat and meat.state ~= MeatState.Dragging then
			meat.FollowScreenPosition(meat, player.inputPosition)
		end
	end

	self.m_ChopstickSyncFrameCounter = self.m_ChopstickSyncFrameCounter + 1

	if BBQConstants.ChopstickSyncFrameInterval < self.m_ChopstickSyncFrameCounter then
		self.m_ChopstickSyncFrameCounter = 0

		self.ReportChopstickState(self, screenX, screenY, player)
	end

	local dt = UnityEngine.Time.deltaTime
	local t = BBQConstants.ChopstickLerpSpeed * dt

	if t <= 1 then
		t = 1
	end

	for seat = 0, BBQConstants.MaxPlayers - 1 do
		if seat == self.mySeatIndex then
			local target = self.m_ChopstickTargets[seat]

			if target then
				if not self.playerInputPositions[seat] then
					local cur = {
						x = target.x,
						y = target.y
					}
				end

				cur.x = cur.x + (target.x - cur.x) * t
				cur.y = cur.y + (target.y - cur.y) * t
				self.playerInputPositions[seat] = cur
			end
		end
	end

	for _, meat in pairs(self.meats) do
		if meat.state ~= MeatState.Dragging and meat.ownerPlayerId == nil and meat.ownerPlayerId == self.mySeatIndex then
			local remotePos = self.playerInputPositions[meat.ownerPlayerId]

			if remotePos then
				meat.FollowScreenPosition(meat, remotePos)
			end
		end
	end

	local panel = gBBQGameManager and gBBQGameManager.panelRef

	if panel and panel.isStart and panel.UpdateMousePositions then
		panel.UpdateMousePositions(panel)
	end
end

M.ReportChopstickState = function(self, screenX, screenY, player)
	if not self.gadgetUId then
		return
	end

	local holdingMeatId = 0

	if player.hasEnterDrag and player.draggedPartId > 0 then
		holdingMeatId = player.draggedPartId
	end

	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera
	local ray = mainCamera:ScreenPointToRay(Vector3.New(screenX, screenY, 0))
	local planeY = self.grill and self.grill.position.y or 0
	local plane = Plane.New(Vector3.up, 0)

	plane:SetNormalAndPosition(Vector3.up, Vector3.New(0, planeY, 0))

	local wx = 0
	local wy = planeY
	local wz = 0
	local hit, enter = plane:Raycast(ray)

	if hit then
		local hitPoint = ray.GetPoint(ray, enter)
		wz = hitPoint.z
		wy = hitPoint.y
		wx = hitPoint.x
	end

	if holdingMeatId == 0 then
		local meat = self.meats[holdingMeatId]

		if meat and meat.gameObject then
			local pos = meat.gameObject.transform.position
			wz = pos.z
			wy = pos.y
			wx = pos.x
		end
	end

	local state = {
		Position = UX.Game.UXVector3.New(wx, wy, wz),
		HoldingMeatId = holdingMeatId
	}

	gClientToGameSceneDelegate:BBQSyncChopstickState(self.gadgetUId, state)
end

M.OnRemoteChopstick = function(self, seatIndex, state)
	if seatIndex ~= self.mySeatIndex then
		return
	end

	if not state or not state.Position then
		return
	end

	local wx = state.Position.X
	local wy = state.Position.Y
	local wz = state.Position.Z
	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera
	local screenPos = mainCamera:WorldToScreenPoint(Vector3.New(wx, wy, wz))
	self.m_ChopstickTargets[seatIndex] = {
		x = screenPos.x,
		y = screenPos.y
	}
	self.m_ChopstickHolding[seatIndex] = state.HoldingMeatId == 0
end

M.DoPlayerRaycast = function(self, player)
	if not player.canRaycast then
		player.raycastTargetType = -1
		player.raycastPartId = -1
		player.hasRaycastPart = false

		return
	end

	local targetType, partId, hasTarget = self.RaycastAt(self, player.inputPosition.x, player.inputPosition.y)

	if targetType ~= nil then
		return
	end

	player.raycastTargetType = targetType
	player.raycastPartId = partId
	player.hasRaycastPart = hasTarget
end

M.RaycastAt = function(self, screenX, screenY)
	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera

	if not mainCamera then
		return nil
	end

	local screenPos = Vector3.New(screenX, screenY, 0)
	local ray = mainCamera.ScreenPointToRay(mainCamera, screenPos)
	local hit, hitInfo = UnityEngine.Physics.Raycast(ray, nil, 20, bit.lshift(1, LayerConstants._Decoration), 2)

	if hit and hitInfo and hitInfo.transform then
		local hitGo = hitInfo.transform.gameObject
		local result = self.LookupSceneNode(self, hitGo)

		if result then
			return result.targetType, result.partId, true
		end
	end

	return -1, -1, false
end

M.CapturePressTarget = function(self, screenX, screenY)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	local targetType, partId, hasTarget = nil

	if not player.canRaycast then
		hasTarget = false
		partId = -1
		targetType = -1
	else
		targetType, partId, hasTarget = self.RaycastAt(self, screenX, screenY)

		if targetType ~= nil then
			hasTarget = false
			partId = -1
			targetType = -1
		end
	end

	player.pressTargetType = targetType
	player.pressPartId = partId
	player.hasPressTarget = hasTarget

	if not self.IsPressTargetInteractable(self, targetType, partId) then
		self.PlayChopsticksClipAir(self)
	end
end

M.IsPressTargetInteractable = function(self, targetType, partId)
	if targetType ~= PartType.Plate then
		return self.plates[partId] == nil
	end

	if targetType and PartType.Meat0 < targetType and targetType < PartType.Meat4 then
		local meat = self.meats[partId]

		return meat == nil and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill
	end

	return false
end

M.ClearPressTarget = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	player.pressTargetType = nil
	player.pressPartId = nil
	player.hasPressTarget = nil
end

M.LookupSceneNode = function(self, hitGo)
	if self.grill and self.grill.gameObject ~= hitGo then
		return {
			["I\\x83\\x9a\\xaaE"] = -1,
			targetType = PartType.Grill
		}
	end

	for playerId, bowl in pairs(self.sauceBowls) do
		if bowl.gameObject ~= hitGo then
			return {
				targetType = PartType.Sauce,
				partId = playerId
			}
		end
	end

	for plateName, plate in pairs(self.plates) do
		if plate.gameObject ~= hitGo then
			return {
				targetType = PartType.Plate,
				partId = plateName
			}
		end
	end

	for meatId, meat in pairs(self.meats) do
		if meat.gameObject ~= hitGo then
			return {
				targetType = meat.meatType - 1,
				partId = meatId
			}
		end
	end

	return nil
end

M.IsDescendantOf = function(self, hitGo, ancestorGo)
	local t = hitGo.transform

	while t do
		if t.gameObject ~= ancestorGo then
			return true
		end

		t = t.parent
	end

	return false
end

M.GetSauceBowlOwnerId = function(self, hitGo)
	for ownerId, bowl in pairs(self.sauceBowls) do
		if hitGo ~= bowl.gameObject or self.IsDescendantOf(self, hitGo, bowl.gameObject) then
			return ownerId
		end
	end

	return -1
end

local HOVER_EFFECT_ID = 538000452

M.UpdateHoverOutline = function(self)
	local panel = gBBQGameManager and gBBQGameManager.panelRef

	if not panel or not panel.gamepadMode then
		if self.m_HoverEffectUUID then
			self.StopHoverOutline(self)
		end

		return
	end

	if panel.bindData and panel.bindData.controllerState ~= 1 then
		if self.m_HoverEffectUUID then
			self.StopHoverOutline(self)
		end

		return
	end

	local player = self.GetPlayer(self, self.mySeatIndex)
	local meat = nil

	if player then
		if player.hasEnterDrag and player.draggedPartId > 0 then
			meat = self.meats[player.draggedPartId]
		elseif player.hasRaycastPart then
			local t = player.raycastTargetType

			if t and PartType.Meat0 < t and t < PartType.Meat4 then
				local m = self.meats[player.raycastPartId]

				if m and m.ownerPlayerId ~= nil and m.state ~= MeatState.OnGrill then
					meat = m
				end
			end
		end
	end

	local newId = meat and meat.id or nil

	if newId ~= self.m_HoverMeatId then
		return
	end

	if self.m_HoverEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.m_HoverEffectUUID)

		self.m_HoverEffectUUID = nil
	end

	self.m_HoverMeatId = newId

	if meat and meat.gameObject then
		self.m_HoverEffectUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(HOVER_EFFECT_ID, LX6.Effect.EffectPlayTag.Gameplay, "BBQHover_" .. tostring(meat.id), meat.gameObject)
	end
end

M.StopHoverOutline = function(self)
	if self.m_HoverEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.m_HoverEffectUUID)

		self.m_HoverEffectUUID = nil
	end

	self.m_HoverMeatId = nil
end

M.PlayChopsticksClipAir = function(self)
	gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.ChopsticksClipAir)
end

M.PlayMeatClipSound = function(self, meat)
	if not meat then
		return
	end

	local pos = meat.GetPosition(meat)

	if pos then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.MeatClip, pos)
	end
end

M.CheckGrillStateChange = function(self)
	local hasMeat = self.HasGrillMeat(self)

	if hasMeat and not self.m_GrillHadMeat then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.GrillExist)
	elseif not hasMeat and self.m_GrillHadMeat then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.GrillEmpty)
	end

	self.m_GrillHadMeat = hasMeat
end

M.HasGrillMeat = function(self)
	for _, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and meat.state == MeatState.Dragging then
			return true
		end
	end

	return false
end

M.GetPlayer = function(self, playerId)
	return self.players[playerId + 1]
end

M.GetMeat = function(self, meatId)
	return self.meats[meatId]
end

M.GetMaterialForLevel = function(self, meatType, level)
	local byLevel = self.materialCache[meatType]

	return byLevel and byLevel[level] or nil
end

M.GetBurntMeats = function(self)
	local result = {}

	for _, meatId in ipairs(self.burntMeatIds) do
		local meat = self.meats[meatId]

		if meat and meat.ownerPlayerId ~= nil then
			table.insert(result, meat)
		end
	end

	return result
end

M.GetAvailableGrillMeats = function(self, onlyForFlip, aiController)
	local result = {}

	for meatId, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and not meat.meatData.isBurnt and meat.state ~= MeatState.OnGrill and meat.ownerPlayerId ~= nil and (not onlyForFlip or not aiController or not aiController.IsFlipCoolingDown(aiController, meatId)) then
			table.insert(result, meatId)
		end
	end

	return result
end

M.GetAllGrillMeatData = function(self)
	local result = {}

	for _, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and meat.meatData then
			table.insert(result, meat.meatData)
		end
	end

	return result
end

M.GetOtherPlayerBowls = function(self, playerId)
	local result = {}

	for id, bowl in pairs(self.sauceBowls) do
		if id == playerId then
			table.insert(result, bowl)
		end
	end

	return result
end

M.GetPlayerBowl = function(self, playerId)
	return self.sauceBowls[playerId]
end

M.GetPlates = function(self)
	local result = {}

	for plateName, plate in pairs(self.plates) do
		table.insert(result, {
			id = plateName,
			position = plate.position
		})
	end

	return result
end

M.GetGrillPosition = function(self)
	return self.grill and self.grill.position or nil
end

M.GetMeatWorldPosition = function(self, meatId)
	local meat = self.meats[meatId]

	return meat and meat:GetPosition() or nil
end

M.GetBowlWorldPosition = function(self, bowl)
	return bowl and bowl.position or nil
end

M.GetPlateWorldPosition = function(self, plateId)
	local plate = self.plates[plateId]

	return plate and plate.position or nil
end

M.GetDropPositionOnGrill = function(self)
	return self.grill and self.grill:GetRandomPosition() or nil
end

M.SetPlayerInputPosition = function(self, playerId, x, y)
	self.playerInputPositions[playerId] = {
		x = x,
		y = y
	}
end

M.GetMouseSlotForSeat = function(self, seatIndex)
	if seatIndex ~= self.mySeatIndex then
		return "self"
	end

	local slot = 0

	for s = 0, BBQConstants.MaxPlayers - 1 do
		if s == self.mySeatIndex then
			slot = slot + 1

			if s ~= seatIndex then
				return "p" .. slot
			end
		end
	end

	return nil
end

M.IsSeatHoldingMeat = function(self, seatIndex)
	if seatIndex ~= self.mySeatIndex then
		local p = self:GetPlayer(seatIndex)

		return p and p.hasEnterDrag or false
	end

	return self.m_ChopstickHolding[seatIndex] ~= true
end

M.IsPickupInFlight = function(self)
	return self.m_PickupInFlight ~= true
end

M.OnPickupRejected = function(self)
	if not self.m_PickupInFlight then
		return
	end

	print_warn("[BBQGameOnline] 取肉被服端拒绝，复位 m_PickupInFlight")

	self.m_PickupInFlight = false
	self.m_PendingReleaseAction = nil
end

M.OnPlaceMeatRpcFailed = function(self, meatId)
	self._ClearPlaceConfirm(self, meatId)

	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	if player.hasEnterDrag then
		return
	end

	local meat = self.meats[meatId]

	if not meat then
		return
	end

	if meat.state == MeatState.Dragging or meat.ownerPlayerId == self.mySeatIndex then
		return
	end

	print_warn("[BBQGameOnline] 放置 RPC 未到达服端，恢复持有 meatId=", meatId)

	player.draggedPartId = meatId
	player.hasEnterDrag = true
end

M.SetInputTakenOver = function(self, taken)
	self.m_IsInputTakenOver = taken and true or false
end

M.OnServerEnterRoom = function(self, participantInfo, add, remove)
	if not participantInfo then
		return
	end

	local seat = participantInfo.SeatIndex

	if remove then
		self.m_ParticipantBySeat[seat] = nil
	else
		self.m_ParticipantBySeat[seat] = participantInfo
	end

	if gBBQGameManager and gBBQGameManager.panelRef and gBBQGameManager.panelRef.RefreshSeatAvatarOnline then
		gBBQGameManager.panelRef:RefreshSeatAvatarOnline(seat)
	end
end

M.GetSeatPid = function(self, seatIndex)
	local info = self.m_ParticipantBySeat[seatIndex]

	return info and info.Pid or nil
end

M.IsSeatOccupied = function(self, seatIndex)
	return self.m_ParticipantBySeat[seatIndex] == nil
end

M.OnPlayerBeginDrag = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player or player.hasEnterDrag or self.m_PickupInFlight then
		return
	end

	local targetType, partId, hasTarget = nil

	if player.hasPressTarget == nil then
		hasTarget = player.hasPressTarget
		partId = player.pressPartId
		targetType = player.pressTargetType
		player.hasPressTarget = nil
	else
		hasTarget = player.hasRaycastPart
		partId = player.raycastPartId
		targetType = player.raycastTargetType
	end

	if not hasTarget then
		return
	end

	if targetType ~= PartType.Plate then
		local plate = self.plates[partId]

		if not plate then
			return
		end

		gBBQGameManager:RpcPickupMeatFromPlate(plate.meatType)

		self.m_PickupInFlight = true
		self.m_PickupInFlightTime = UnityEngine.Time.time
		self.m_PendingReleaseAction = nil
	elseif PartType.Meat0 < targetType and targetType < PartType.Meat4 then
		local meat = self.meats[partId]

		if meat and meat.state ~= MeatState.OnGrill and meat.ownerPlayerId ~= nil then
			gBBQGameManager:RpcPickupMeatFromGrill(meat.id)

			self.m_PickupInFlight = true
			self.m_PickupInFlightTime = UnityEngine.Time.time
			self.m_PendingReleaseAction = nil
		end
	end
end

M.OnPlayerBeginDragFromPlate = function(self, plateId)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player or player.hasEnterDrag or self.m_PickupInFlight then
		return
	end

	local plate = self.plates[plateId]

	if not plate then
		return
	end

	gBBQGameManager:RpcPickupMeatFromPlate(plate.meatType)

	self.m_PickupInFlight = true
	self.m_PickupInFlightTime = UnityEngine.Time.time
	self.m_PendingReleaseAction = nil
end

M.OnPlayerEndDrag = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	if self.m_PickupInFlight and not player.hasEnterDrag then
		self.m_PendingReleaseAction = self._DecidePendingReleaseAction(self, player)

		return
	end

	if not player.hasEnterDrag then
		return
	end

	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	local decision, payload = self._DecideEndDragRpcFromHits(self, player)

	if decision ~= "grill" then
		gBBQGameManager:RpcPutMeatOnGrill(meatId, payload)
	elseif decision ~= "bowl" then
		gBBQGameManager:RpcPutMeatToBowl(meatId, payload)
	else
		gBBQGameManager:RpcDropMeat(meatId)
	end

	player.draggedPartId = -1
	player.hasEnterDrag = false

	self._TrackPlaceConfirm(self, meatId)
end

M.GetGrillDropPosition = function(self, player)
	if not self.grill then
		return nil
	end

	local pos = self.grill:ScreenToPlacementPos(player.inputPosition.x, player.inputPosition.y)

	return self.grill:ClampPosition(pos or self.grill.position)
end

M._DecideEndDragRpcFromHits = function(self, player)
	local meatId = player.draggedPartId
	local meat = self.meats[meatId]

	if not meat then
		return "drop", nil
	end

	local screenPos = Vector3.New(player.inputPosition.x, player.inputPosition.y, 0)
	local ray = gCS.CameraDataMgr.Instance.MainCamera:ScreenPointToRay(screenPos)
	local hits = gCS.LuaUtils.RaycastAll(ray.origin, ray.direction, 20, bit.lshift(1, LayerConstants._Decoration), false)
	local meatGo = meat.gameObject

	if hits then
		for i = 0, hits.Length - 1 do
			local hitGo = hits[i].transform and hits[i].transform.gameObject

			if hitGo and not self.IsDescendantOf(self, hitGo, meatGo) then
				if self.grill and (hitGo ~= self.grill.gameObject or self.IsDescendantOf(self, hitGo, self.grill.gameObject)) then
					local clamped = self.GetGrillDropPosition(self, player)

					return "grill", UX.Game.UXVector3.New(clamped.x, clamped.y, clamped.z)
				end

				local sauceOwner = self.GetSauceBowlOwnerId(self, hitGo)

				if sauceOwner > 0 and self.IsSeatOccupied(self, sauceOwner) then
					return "bowl", sauceOwner
				end
			end
		end
	end

	if meat.grillPosition then
		local gp = meat.grillPosition

		return "grill", UX.Game.UXVector3.New(gp.x, gp.y, gp.z)
	end

	return "drop", nil
end

M._DecidePendingReleaseAction = function(self, player)
	local screenPos = Vector3.New(player.inputPosition.x, player.inputPosition.y, 0)
	local ray = gCS.CameraDataMgr.Instance.MainCamera:ScreenPointToRay(screenPos)
	local hits = gCS.LuaUtils.RaycastAll(ray.origin, ray.direction, 20, bit.lshift(1, LayerConstants._Decoration), false)

	if hits then
		for i = 0, hits.Length - 1 do
			local hitGo = hits[i].transform and hits[i].transform.gameObject

			if hitGo then
				if self.grill and (hitGo ~= self.grill.gameObject or self.IsDescendantOf(self, hitGo, self.grill.gameObject)) then
					local clamped = self.GetGrillDropPosition(self, player)

					return {
						["q+s_"] = "J\\xbc\\xab\\xa3\\xba",
						grillPos = UX.Game.UXVector3.New(clamped.x, clamped.y, clamped.z)
					}
				end

				local sauceOwner = self.GetSauceBowlOwnerId(self, hitGo)

				if sauceOwner > 0 and self.IsSeatOccupied(self, sauceOwner) then
					return {
						["q+s_"] = "x-jW",
						seat = sauceOwner
					}
				end
			end
		end
	end

	return {
		["q+s_"] = "~0rK"
	}
end

M._FlushPendingRelease = function(self, meatId)
	local act = self.m_PendingReleaseAction
	self.m_PendingReleaseAction = nil

	if not act then
		return false
	end

	if act.kind ~= "grill" then
		gBBQGameManager:RpcPutMeatOnGrill(meatId, act.grillPos)
	elseif act.kind ~= "bowl" then
		gBBQGameManager:RpcPutMeatToBowl(meatId, act.seat)
	else
		local meat = self.meats[meatId]

		if meat and meat.grillPosition then
			local gp = meat.grillPosition

			gBBQGameManager:RpcPutMeatOnGrill(meatId, UX.Game.UXVector3.New(gp.x, gp.y, gp.z))
		else
			gBBQGameManager:RpcDropMeat(meatId)
		end
	end

	self._TrackPlaceConfirm(self, meatId)

	return true
end

M.OnPlayerClick = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	local meat = nil

	if player.hasRaycastPart and PartType.Meat0 < player.raycastTargetType and player.raycastTargetType < PartType.Meat4 then
		meat = self.meats[player.raycastPartId]
	end

	if meat and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill then
		gBBQGameManager:RpcFlipMeat(meat.id)
	end
end

M.OnPlayerScoreToBowl = function(self, seatIndex)
	if not self.IsSeatOccupied(self, seatIndex) then
		return
	end

	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	if self.m_PickupInFlight and not player.hasEnterDrag then
		self.m_PendingReleaseAction = {
			["q+s_"] = "x-jW",
			seat = seatIndex
		}

		return
	end

	if not player.hasEnterDrag then
		return
	end

	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	gBBQGameManager:RpcPutMeatToBowl(meatId, seatIndex)

	player.draggedPartId = -1
	player.hasEnterDrag = false

	self:_TrackPlaceConfirm(meatId)
end

M.OnPlayerDropHeld = function(self)
	local player = self.GetPlayer(self, self.mySeatIndex)

	if not player then
		return
	end

	if self.m_PickupInFlight and not player.hasEnterDrag then
		self.m_PendingReleaseAction = {
			["q+s_"] = "~0rK"
		}

		return
	end

	if not player.hasEnterDrag then
		return
	end

	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	local meat = self.meats[meatId]

	if meat and meat.grillPosition then
		local gp = meat.grillPosition

		gBBQGameManager:RpcPutMeatOnGrill(meatId, UX.Game.UXVector3.New(gp.x, gp.y, gp.z))
	else
		gBBQGameManager:RpcDropMeat(meatId)
	end

	player.draggedPartId = -1
	player.hasEnterDrag = false

	self._TrackPlaceConfirm(self, meatId)
end

M.CreateMeatFromInfo = function(self, meatInfo, initialPosition)
	local meatType = meatInfo.MeatType
	local meatId = meatInfo.MeatId
	local pool = self.meatPoolByType[meatType]
	local meat = nil

	if pool and #pool <= 0 then
		meat = table.remove(pool)
		meat.id = meatId

		meat:ResetData()
		meat.gameObject:SetActive(true)

		meat.gameObject.name = string.format("BBQMeat_%d_Type%d", meatId, meatType)

		meat:SetPosition(initialPosition)
	else
		local templateGo = self.meatTemplates[meatType]

		if not templateGo then
			print_warn("[BBQGameOnline] 无肉模板 type=" .. tostring(meatType))

			return nil
		end

		meat = gBBQMeat.new({
			id = meatId,
			meatType = meatType,
			templateGo = templateGo,
			position = initialPosition,
			poolParent = self.meatPool.transform
		})

		meat.SetMaterialProvider(meat, function (mt, level)
			return self:GetMaterialForLevel(mt, level)
		end)
	end

	self.meats[meatId] = meat

	return meat
end

M.RemoveMeat = function(self, meatId)
	local meat = self.meats[meatId]

	if not meat then
		return
	end

	for i, id in ipairs(self.burntMeatIds) do
		if id ~= meatId then
			table.remove(self.burntMeatIds, i)

			break
		end
	end

	self.grillCache:RemoveMeat(meatId)
	meat:Deactivate()

	self.meats[meatId] = nil
	self.m_MeatLastSyncTime[meatId] = nil
	local pool = self.meatPoolByType[meat.meatType]

	if not pool then
		pool = {}
		self.meatPoolByType[meat.meatType] = pool
	end

	table.insert(pool, meat)
end

M.GetPlatePositionByMeatType = function(self, meatType)
	for _, plate in pairs(self.plates) do
		if plate.meatType ~= meatType then
			return plate.position
		end
	end

	return nil
end

M.FlyMeatToPlateThenRemove = function(self, meatId)
	local meat = self.meats[meatId]

	if not meat then
		return
	end

	local platePos = self.GetPlatePositionByMeatType(self, meat.meatType)

	if not platePos then
		self.RemoveMeat(self, meatId)

		return
	end

	meat.OnReturnToPlate(meat, platePos, function ()
		self:RemoveMeat(meatId)
	end)
end

M.ApplyMeatInfo = function(self, meat, info)
	if not meat or not info then
		return
	end

	local md = meat.meatData
	local prevSide0 = md.sides[0] and md.sides[0].timer or 0

	print_debug("[BBQGameOnline] ApplyMeatInfo meatId=" .. meat.id, " serverSide0=" .. info.Side0CookTime, " localSide0=", prevSide0, " drift=" .. info.Side0CookTime - prevSide0)

	md.sides[0].timer = info.Side0CookTime
	md.sides[0].cookedLevel = info.Side0CookedLevel
	md.sides[0].score = info.Side0Score
	md.sides[1].timer = info.Side1CookTime
	md.sides[1].cookedLevel = info.Side1CookedLevel
	md.sides[1].score = info.Side1Score
	md.isBurnt = info.IsBurnt

	if info.CurrentSideUp ~= 0 then
		meat.UpdateMaterial(meat, 0, info.Side0CookedLevel)
	else
		meat.UpdateMaterial(meat, 1, info.Side1CookedLevel)
	end

	self.m_MeatLastSyncTime[meat.id] = UnityEngine.Time.time
end

M.OnSyncMeatCreated = function(self, meatInfo, creatorSeatIndex)
	local existing = self.meats[meatInfo.MeatId]

	if existing then
		print_warn("[BBQGameOnline] OnSyncMeatCreated 但 meat 已存在 id=", meatInfo.MeatId)

		if creatorSeatIndex ~= self.mySeatIndex then
			self.m_PickupInFlight = false
			self.m_PendingReleaseAction = nil
		end

		return
	end

	local plate = nil

	for _, p in pairs(self.plates) do
		if p.meatType ~= meatInfo.MeatType then
			plate = p

			break
		end
	end

	local initPos = plate and plate.position or self:GetGrillPosition() or Vector3.zero
	local meat = self:CreateMeatFromInfo(meatInfo, initPos)

	if not meat then
		return
	end

	meat.state = MeatState.Dragging

	meat.SetDragOffset(meat, BBQConstants.MeatPlatePickupYOffset)
	meat.RandomizeHorizontalRotation(meat)

	meat.ownerPlayerId = creatorSeatIndex

	self.ApplyMeatInfo(self, meat, meatInfo)
	self.PlayMeatClipSound(self, meat)

	if creatorSeatIndex ~= self.mySeatIndex then
		self.m_PickupInFlight = false

		if self._FlushPendingRelease(self, meatInfo.MeatId) then
			return
		end
	end

	local creator = self.GetPlayer(self, creatorSeatIndex)

	if creator then
		creator.draggedPartId = meatInfo.MeatId
		creator.hasEnterDrag = true
	end
end

M.OnSyncMeatPlacedOnGrill = function(self, meatId, grillPosition)
	local meat = self.meats[meatId]

	if not meat then
		return
	end

	self:_ClearPlaceConfirm(meatId)

	local prevOwner = meat.ownerPlayerId
	meat.ownerPlayerId = nil
	local pos = Vector3.New(grillPosition.X, grillPosition.Y, grillPosition.Z)

	meat:OnEndDrag(pos)
	self.grillCache:AddMeat(meatId, pos, meat.meatData.meatSize)

	if prevOwner == nil then
		local p = self.GetPlayer(self, prevOwner)

		if p then
			p.draggedPartId = -1
			p.hasEnterDrag = false
		end
	end

	self.m_MeatLastSyncTime[meatId] = UnityEngine.Time.time
end

M.OnSyncMeatPickedFromGrill = function(self, meatId, pickerSeatIndex, updatedInfo)
	local meat = self.meats[meatId]

	if not meat then
		if pickerSeatIndex ~= self.mySeatIndex then
			self.m_PickupInFlight = false
			self.m_PendingReleaseAction = nil
		end

		return
	end

	self:ApplyMeatInfo(meat, updatedInfo)

	meat.ownerPlayerId = pickerSeatIndex

	meat:OnBeginDrag()
	self.grillCache:RemoveMeat(meatId)
	self:PlayMeatClipSound(meat)

	if pickerSeatIndex ~= self.mySeatIndex then
		self.m_PickupInFlight = false

		if self._FlushPendingRelease(self, meatId) then
			return
		end
	end

	local picker = self.GetPlayer(self, pickerSeatIndex)

	if picker then
		picker.draggedPartId = meatId
		picker.hasEnterDrag = true
	end
end

M.OnSyncMeatFlipped = function(self, meatId, flipperSeatIndex, updatedInfo)
	local meat = self.meats[meatId]

	if not meat then
		return
	end

	meat.DoFlipAnimation(meat, function ()
		if self.hasDestroy then
			return
		end

		if self.meats[meatId] ~= meat then
			self:ApplyMeatInfo(meat, updatedInfo)
		end
	end)
end

M.OnSyncMeatScored = function(self, meatId, targetSeatIndex, result)
	self._ClearPlaceConfirm(self, meatId)

	local meat = self.meats[meatId]

	if meat then
		local prevOwner = meat.ownerPlayerId
		meat.ownerPlayerId = nil

		if prevOwner == nil then
			local p = self.GetPlayer(self, prevOwner)

			if p then
				p.draggedPartId = -1
				p.hasEnterDrag = false
			end
		end

		meat.OnScored(meat)
	end

	local player = self.GetPlayer(self, targetSeatIndex)

	if player then
		player.singleAddScore = result.TotalMeatScore
		player.totalScore = result.PlayerNewTotalScore
	end

	local s0 = result.Side0CookedLevel or 0
	local s1 = result.Side1CookedLevel or 0
	local avg = nil

	if meat then
		avg = meat.meatData:CalcFeedbackLevel(s0, s1)
	else
		avg = math.floor((s0 + s1) / 2)
	end

	gBBQGameManager:AddPlayerScore(targetSeatIndex, result.TotalMeatScore, avg, result.PlayerNewTotalScore)
	self:RemoveMeat(meatId)
end

M.OnSyncMeatDropped = function(self, meatId)
	self._ClearPlaceConfirm(self, meatId)

	local meat = self.meats[meatId]

	if meat then
		local prevOwner = meat.ownerPlayerId
		meat.ownerPlayerId = nil

		if prevOwner == nil then
			local p = self.GetPlayer(self, prevOwner)

			if p then
				p.draggedPartId = -1
				p.hasEnterDrag = false
			end
		end

		if not meat.grillPosition then
			self.FlyMeatToPlateThenRemove(self, meatId)

			return
		end
	end

	self.RemoveMeat(self, meatId)
end

M.OnSyncZoneInfo = function(self, zoneInfo)
	if not zoneInfo or not zoneInfo.Meats then
		return
	end

	for _, info in ipairs(zoneInfo.Meats) do
		local existing = self.meats[info.MeatId]

		if not existing then
			local holderSeat = info.HoldingSeatIndex

			if info.IsOnGrill then
				local pos = Vector3.New(info.GrillPosition.X, info.GrillPosition.Y, info.GrillPosition.Z)
				local meat = self.CreateMeatFromInfo(self, info, pos)

				if meat then
					meat:OnEndDrag(pos)
					self.grillCache:AddMeat(info.MeatId, pos, meat.meatData.meatSize)
					self:ApplyMeatInfo(meat, info)
				end
			elseif holderSeat == nil and holderSeat > 0 then
				local initPos = self:GetGrillPosition() or Vector3.zero
				local meat = self:CreateMeatFromInfo(info, initPos)

				if meat then
					meat.state = MeatState.Dragging
					meat.ownerPlayerId = holderSeat

					self.ApplyMeatInfo(self, meat, info)

					local p = self.GetPlayer(self, holderSeat)

					if p then
						p.draggedPartId = info.MeatId
						p.hasEnterDrag = true
					end
				end
			else
				local meat = self:CreateMeatFromInfo(info, self:GetGrillPosition() or Vector3.zero)

				if meat then
					self.ApplyMeatInfo(self, meat, info)
				end
			end
		else
			self.ApplyMeatInfo(self, existing, info)
		end
	end

	if zoneInfo.PlayerScores then
		for seat = 0, BBQConstants.MaxPlayers - 1 do
			local score = zoneInfo.PlayerScores[seat]

			if score then
				local p = self.GetPlayer(self, seat)

				if p then
					p.totalScore = score
				end
			end
		end

		local panel = gBBQGameManager and gBBQGameManager.panelRef

		if panel and panel.RefreshAllScoresOnline then
			panel.RefreshAllScoresOnline(panel)
		end
	end
end
