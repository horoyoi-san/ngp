-- Original chunk: @Lua\LuaFiles\LX6\MiniGame\BBQ\BBQGame.lua
-- Decompiled from: 00673_BBQGame.lua_16861524a356.luajit

local BBQConstants = require("LX6/MiniGame/BBQ/BBQConstants")
local BBQConfig = require("LX6/MiniGame/BBQ/BBQConfig")
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local MeatCookedLevel = BBQConstants.MeatCookedLevel
local MeatState = BBQConstants.MeatState
local GamePhase = BBQConstants.GamePhase
local PartType = BBQConstants.PartType
local LayerConstants = LX6.Constants.LayerConstants
gBBQGame = DefClass("BBQGame", gBBQGame, gBaseMiniGame)
local BBQGame = gBBQGame

BBQGame.Initialize = function(self, args)
	self:InitData(args)

	self.players = {}
	self.aiControllers = {}
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
	self.totalTime = args.totalTime or BBQConstants.DefaultGameTime
	self.prepareTime = args.prepareTime or BBQConstants.DefaultPrepareTime
	self.gameTimer = 0
	self.prepareTimer = 0
	self.playerInputPositions = {}
	self.m_OccupiedSeats = args.occupiedSeats or {
		[0] = true,
		true,
		true,
		true
	}
	self.m_IsInputTakenOver = false
	self.m_HoverEffectUUID = nil
	self.m_HoverMeatId = nil
	self.m_GrillHadMeat = false

	self:SetSceneOtherNodesVisible(false)
end

BBQGame.InitData = function(self, args)
	self.args = args
	self.meatUniqueIdCounter = 40000
end

BBQGame.NextMeatId = function(self)
	self.meatUniqueIdCounter = self.meatUniqueIdCounter + 1

	return self.meatUniqueIdCounter
end

BBQGame.StartGame = function(self)
	if not self.sceneNodeGo or gClientUtils.IsNil(self.sceneNodeGo) then
		print_warn("[BBQGame] StartGame 时 sceneNodeGo 为空，无法初始化")

		return false
	end

	local partyOverTime = gPartyManager and gPartyManager.partyOverTime

	if partyOverTime then
		local needTime = BBQConstants.DefaultPrepareTime + BBQConstants.DefaultGameTime

		if needTime <= partyOverTime - gLuaDataManager.serverTime then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.PartyBarbecueStop)

			return false
		end
	end

	self.InitMaterialCache(self, function ()
		if self.hasDestroy then
			return
		end

		self:InitScene()
		self:InitPlayers()
		self:InitAIControllers()
		self:StartGameCoroutine()
	end)

	return true
end

BBQGame.InitMaterialCache = function(self, onDone)
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
					local asset = loadOp.asset

					if not asset then
						print_error(string.format("[BBQGame] InitMaterialCache: load failed, meatType=%s level=%s path=%s", tostring(mt), tostring(lv), tostring(path)))
					end

					self.materialCache[mt][lv] = asset
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

BBQGame.InitScene = function(self)
	local sceneTrans = self.sceneNodeGo.transform
	local poolTrans = self.FindChildRecursive(self, sceneTrans, "ObjectPool")

	if poolTrans then
		self.meatPool = poolTrans.gameObject
	else
		print_error("[BBQGame] 未找到 ObjectPool 节点")
	end

	local camTrans = self.FindChildRecursive(self, sceneTrans, "Cam")

	if camTrans then
		self.cameraGo = camTrans.gameObject

		self.cameraGo:SetActive(true)
		gCS.CameraDataMgr:SetMainCameraCullingMask(gPanelId.BBQ_PANEL_STORE, LX6.Constants.LayerConstants.AllWithoutPlayerAndNpc)
	else
		print_warn("[BBQGame] 未找到相机节点 Cam")
	end

	self.InitMeatTemplates(self)
	self.InitPartsFromScene(self)
end

BBQGame.FindChildRecursive = function(self, rootTrans, name)
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

BBQGame.InitMeatTemplates = function(self)
	local sceneTrans = self.sceneNodeGo.transform

	for plateName, meatType in pairs(BBQConfig.PlateMeatTypeMap) do
		local meatNodeName = plateName.gsub(plateName, "^BBQPlate", "BBQMeat")
		local meatTrans = self.FindChildRecursive(self, sceneTrans, meatNodeName)

		if meatTrans then
			meatTrans.gameObject:SetActive(false)

			self.meatTemplates[meatType] = meatTrans.gameObject
		else
			print_warn("[BBQGame] 未找到肉模板: " .. meatNodeName)
		end
	end
end

BBQGame.InitPartsFromScene = function(self)
	local sceneTrans = self.sceneNodeGo.transform
	local potPartTrans = self.FindChildRecursive(self, sceneTrans, "PotPart")

	if potPartTrans then
		self.grill = gBBQGrill.new(potPartTrans)
	else
		print_error("[BBQGame] 未找到烤架 PotPart 节点")
	end

	local platesParent = sceneTrans.Find(sceneTrans, "plateParts")

	for plateName, meatType in pairs(BBQConfig.PlateMeatTypeMap) do
		local plateTrans = platesParent and platesParent:Find(plateName)

		if plateTrans then
			local plate = gBBQPlate.new(plateName, plateTrans)
			plate.meatType = meatType
			self.plates[plateName] = plate
		else
			print_warn("[BBQGame] 未找到盘子: " .. plateName)
		end
	end

	for playerId, relPath in pairs(BBQConstants.SeatToSauceNode) do
		local sauceTrans = self.FindChildRecursive(self, sceneTrans, relPath)

		if sauceTrans then
			self.sauceBowls[playerId] = gBBQSauceBowl.new(playerId, sauceTrans)
		else
			print_warn("[BBQGame] 未找到蘸碟: " .. relPath)
		end
	end
end

BBQGame.InitPlayers = function(self)
	for playerId = 0, BBQConstants.MaxPlayers - 1 do
		local player = gBBQPlayer.new()

		player:Initialize(playerId, playerId ~= BBQConstants.LocalSeatIndex, playerId == BBQConstants.LocalSeatIndex)

		self.players[playerId + 1] = player
		self.playerInputPositions[playerId] = {
			["\\xd5"] = 0,
			["\\xd4"] = 0
		}
	end
end

BBQGame.InitAIControllers = function(self)
	for playerId = 0, BBQConstants.MaxPlayers - 1 do
		local player = self.GetPlayer(self, playerId)

		if player and player.isAI and self.IsSeatOccupied(self, playerId) then
			local aiController = gBBQAIController.new()

			aiController.Initialize(aiController, self, playerId)
			table.insert(self.aiControllers, aiController)
		end
	end
end

BBQGame.StartGameCoroutine = function(self)
	self.mainCoroutine = coroutine.start(function ()
		self.gamePhase = GamePhase.Prepare
		self.prepareTimer = self.prepareTime

		while self.prepareTimer <= 0 do
			coroutine.wait(0)

			if self.hasDestroy then
				return
			end

			if gClientUtils.IsNil(self.sceneNodeGo) then
				self:OnSceneDestroyed()

				return
			end

			self.prepareTimer = self.prepareTimer - UnityEngine.Time.deltaTime
		end

		self.gamePhase = GamePhase.Playing
		self.gameTimer = self.totalTime

		gBBQGameManager:OnPrepareEnd()

		while self.gameTimer <= 0 do
			coroutine.wait(0)

			if self.hasDestroy then
				return
			end

			self.gameTimer = self.gameTimer - UnityEngine.Time.deltaTime

			self:UpdateGame()
		end

		self.gamePhase = GamePhase.End

		self:OnGameEnd()
	end)
end

BBQGame.UpdateGame = function(self)
	if gClientUtils.IsNil(self.sceneNodeGo) then
		self.OnSceneDestroyed(self)

		return
	end

	self:UpdateAllMeats()
	self:UpdateInput()
	self.grillCache:UpdateCacheIfNeeded(self:GetAllGrillMeatData())
	self:UpdateHoverOutline()
	self:CheckGrillStateChange()
end

BBQGame.UpdateAllMeats = function(self)
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

BBQGame.OnMeatBurntInGame = function(self, meat)
	table.insert(self.burntMeatIds, meat.id)
end

BBQGame.UpdateInput = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player then
		return
	end

	if not self.m_IsInputTakenOver then
		if GameDevice.KeyboardMouse >= InputActionBind.activeGameDevice then
			local screenPos = SGUI.UCursorInput.GetCursorScreenPos()
			player.inputPosition = {
				x = screenPos.x,
				y = screenPos.y
			}
			self.playerInputPositions[BBQConstants.LocalSeatIndex] = player.inputPosition
		else
			local mousePos = UnityEngine.Input.mousePosition
			player.inputPosition = {
				x = mousePos.x,
				y = mousePos.y
			}
			self.playerInputPositions[BBQConstants.LocalSeatIndex] = player.inputPosition
		end
	end

	self.DoPlayerRaycast(self, player)

	if player.hasEnterDrag and player.draggedPartId > 0 then
		local meat = self.meats[player.draggedPartId]

		if meat and meat.state ~= MeatState.Dragging then
			meat.FollowScreenPosition(meat, player.inputPosition)
		end
	end

	for _, playerId in ipairs(BBQConstants.AISeatIndices) do
		if self.IsSeatOccupied(self, playerId) then
			local aiPlayer = self.GetPlayer(self, playerId)

			if aiPlayer then
				self.DoPlayerRaycast(self, aiPlayer)

				if aiPlayer.hasEnterDrag and aiPlayer.draggedPartId > 0 then
					local meat = self.meats[aiPlayer.draggedPartId]

					if meat and meat.state ~= MeatState.Dragging then
						meat.FollowScreenPosition(meat, aiPlayer.inputPosition)
					end
				end
			end
		end
	end

	local panel = gBBQGameManager and gBBQGameManager.panelRef

	if panel and panel.isStart and panel.UpdateMousePositions then
		panel.UpdateMousePositions(panel)
	end
end

BBQGame.DoPlayerRaycast = function(self, player)
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

BBQGame.RaycastAt = function(self, screenX, screenY)
	local mainCamera = gCS.CameraDataMgr.Instance.MainCamera

	if not mainCamera then
		return nil
	end

	local screenPos = UnityEngine.Vector3.New(screenX, screenY, 0)
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

BBQGame.CapturePressTarget = function(self, screenX, screenY)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

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

BBQGame.IsPressTargetInteractable = function(self, targetType, partId)
	if targetType ~= PartType.Plate then
		return self.plates[partId] == nil
	end

	if targetType and PartType.Meat0 < targetType and targetType < PartType.Meat4 then
		local meat = self.meats[partId]

		return meat == nil and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill
	end

	return false
end

BBQGame.ClearPressTarget = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player then
		return
	end

	player.pressTargetType = nil
	player.pressPartId = nil
	player.hasPressTarget = nil
end

BBQGame.LookupSceneNode = function(self, hitGo)
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

BBQGame.CreateMeatFromPlate = function(self, plateId)
	local plate = self.plates[plateId]

	if not plate then
		print_warn("[BBQGame] CreateMeatFromPlate: 未知 plate", plateId)

		return nil
	end

	local meatType = plate.meatType
	local meatId = self.NextMeatId(self)
	local pool = self.meatPoolByType[meatType]
	local meat = nil

	if pool and #pool <= 0 then
		meat = table.remove(pool)
		meat.id = meatId

		meat:ResetData()

		slot7 = meat.gameObject

		slot7:SetActive(true)

		meat.gameObject.name = string.format("BBQMeat_%d_Type%d", meatId, meatType)

		meat:SetPosition(plate.position)

		meat.state = MeatState.Dragging

		meat:SetDragOffset(BBQConstants.MeatPlatePickupYOffset)
		meat:SetMaterialProvider(function (mt, level)
			return self:GetMaterialForLevel(mt, level)
		end)
	else
		local templateGo = self.meatTemplates[meatType]

		if not templateGo then
			print_warn("[BBQGame] 无肉模板 type=" .. tostring(meatType))

			return nil
		end

		meat = gBBQMeat.new({
			id = meatId,
			meatType = meatType,
			templateGo = templateGo,
			position = plate.position,
			poolParent = self.meatPool.transform
		})

		meat.SetMaterialProvider(meat, function (mt, level)
			return self:GetMaterialForLevel(mt, level)
		end)

		meat.state = MeatState.Dragging

		meat.SetDragOffset(meat, BBQConstants.MeatPlatePickupYOffset)
	end

	meat.RandomizeHorizontalRotation(meat)

	self.meats[meatId] = meat

	return meat
end

BBQGame.RemoveMeat = function(self, meatId)
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
	local pool = self.meatPoolByType[meat.meatType]

	if not pool then
		pool = {}
		self.meatPoolByType[meat.meatType] = pool
	end

	table.insert(pool, meat)
end

BBQGame.GetPlatePositionByMeatType = function(self, meatType)
	for _, plate in pairs(self.plates) do
		if plate.meatType ~= meatType then
			return plate.position
		end
	end

	return nil
end

BBQGame.FlyMeatToPlateThenRemove = function(self, meatId)
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

BBQGame.OnPlayerBeginDrag = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player or player.hasEnterDrag then
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
		local meat = self.CreateMeatFromPlate(self, partId)

		if meat then
			meat.ownerPlayerId = BBQConstants.LocalSeatIndex
			player.draggedPartId = meat.id
			player.hasEnterDrag = true

			self.PlayMeatClipSound(self, meat)
		end
	else
		local meat = self.meats[partId]

		if meat and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill then
			meat.ownerPlayerId = BBQConstants.LocalSeatIndex

			meat.OnBeginDrag(meat)

			player.draggedPartId = meat.id
			player.hasEnterDrag = true

			self.PlayMeatClipSound(self, meat)
		end
	end
end

BBQGame.OnPlayerBeginDragFromPlate = function(self, plateId)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player then
		return
	end

	if player.hasEnterDrag then
		return
	end

	local meat = self.CreateMeatFromPlate(self, plateId)

	if meat then
		meat.ownerPlayerId = BBQConstants.LocalSeatIndex
		player.draggedPartId = meat.id
		player.hasEnterDrag = true

		self.PlayMeatClipSound(self, meat)
	end
end

BBQGame.OnPlayerEndDrag = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player or not player.hasEnterDrag then
		return
	end

	self.HandleMeatRelease(self, player)

	player.draggedPartId = -1
	player.hasEnterDrag = false
end

BBQGame.OnPlayerClick = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player then
		return
	end

	local meat = player.hasRaycastPart and self.meats[player.raycastPartId] or nil

	if meat and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill then
		meat.OnClick(meat)
	end
end

BBQGame.OnPlayerScoreToBowl = function(self, playerId)
	if not self.IsSeatOccupied(self, playerId) then
		return
	end

	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player or not player.hasEnterDrag then
		return
	end

	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	local meat = self.meats[meatId]

	if not meat then
		player.draggedPartId = -1
		player.hasEnterDrag = false

		return
	end

	meat.ownerPlayerId = nil

	meat:OnScored()

	local cookedLevel = meat.meatData:GetFeedbackLevel()

	self:AddScoreToPlayer(playerId, meat:GetTotalScore(), cookedLevel)
	self:RemoveMeat(meatId)

	player.draggedPartId = -1
	player.hasEnterDrag = false
end

BBQGame.OnPlayerDropHeld = function(self)
	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)

	if not player or not player.hasEnterDrag then
		return
	end

	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	local meat = self.meats[meatId]

	if meat then
		meat.ownerPlayerId = nil

		if meat.grillPosition then
			meat.OnDragCancelled(meat, meat.grillPosition)
		else
			self.FlyMeatToPlateThenRemove(self, meatId)
		end
	end

	player.draggedPartId = -1
	player.hasEnterDrag = false
end

BBQGame.GetGrillDropPosition = function(self, player)
	if not self.grill then
		return nil
	end

	local pos = self.grill:ScreenToPlacementPos(player.inputPosition.x, player.inputPosition.y)

	return self.grill:ClampPosition(pos or self.grill.position)
end

BBQGame.HandleMeatRelease = function(self, player)
	local meatId = player.draggedPartId

	if meatId >= 0 then
		return
	end

	local meat = self.meats[meatId]

	if not meat then
		return
	end

	meat.ownerPlayerId = nil
	local screenPos = Vector3.New(player.inputPosition.x, player.inputPosition.y, 0)
	local ray = gCS.CameraDataMgr.Instance.MainCamera:ScreenPointToRay(screenPos)
	local hits = gCS.LuaUtils.RaycastAll(ray.origin, ray.direction, 20, bit.lshift(1, LayerConstants._Decoration), false)
	local meatGo = meat.gameObject
	local sceneHits = {}

	if hits then
		for i = 0, hits.Length - 1 do
			local hitGo = hits[i].transform and hits[i].transform.gameObject

			if hitGo and not self.IsDescendantOf(self, hitGo, meatGo) then
				table.insert(sceneHits, hitGo)
			end
		end
	end

	for _, hitGo in ipairs(sceneHits) do
		if self.grill and (hitGo ~= self.grill.gameObject or self.IsDescendantOf(self, hitGo, self.grill.gameObject)) then
			local targetPos = self.GetGrillDropPosition(self, player)

			meat.OnEndDrag(meat, targetPos)

			if targetPos then
				self.grillCache:AddMeat(meatId, targetPos, meat.meatData.meatSize)
			end

			return
		end
	end

	local hasInvalidHit = false

	for _, hitGo in ipairs(sceneHits) do
		local ownerId = self.GetSauceBowlOwnerId(self, hitGo)

		if ownerId <= 0 or not self.IsSeatOccupied(self, ownerId) then
			hasInvalidHit = true

			break
		end
	end

	if hasInvalidHit or #sceneHits ~= 0 then
		if meat.grillPosition then
			meat.OnDragCancelled(meat, meat.grillPosition)
		else
			self.FlyMeatToPlateThenRemove(self, meatId)
		end

		return
	end

	for _, hitGo in ipairs(sceneHits) do
		local ownerId = self.GetSauceBowlOwnerId(self, hitGo)

		if ownerId > 0 and self.IsSeatOccupied(self, ownerId) then
			meat:OnScored()

			local cookedLevel = meat.meatData:GetFeedbackLevel()

			self:AddScoreToPlayer(ownerId, meat:GetTotalScore(), cookedLevel)
			self:RemoveMeat(meatId)

			return
		end
	end

	if meat.grillPosition then
		meat.OnDragCancelled(meat, meat.grillPosition)
	else
		self.FlyMeatToPlateThenRemove(self, meatId)
	end
end

BBQGame.IsDescendantOf = function(self, hitGo, ancestorGo)
	local t = hitGo.transform

	while t do
		if t.gameObject ~= ancestorGo then
			return true
		end

		t = t.parent
	end

	return false
end

BBQGame.GetSauceBowlOwnerId = function(self, hitGo)
	for ownerId, bowl in pairs(self.sauceBowls) do
		if hitGo ~= bowl.gameObject or self.IsDescendantOf(self, hitGo, bowl.gameObject) then
			return ownerId
		end
	end

	return -1
end

BBQGame.OnAIBeginDrag = function(self, playerId, meatId)
	local player = self.GetPlayer(self, playerId)

	if not player then
		return
	end

	local meat = self.meats[meatId]

	if meat and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill then
		meat.ownerPlayerId = playerId

		meat.OnBeginDrag(meat)

		player.draggedPartId = meatId
		player.hasEnterDrag = true

		self.PlayMeatClipSound(self, meat)
	end
end

BBQGame.OnAIEndDrag = function(self, playerId, meatId)
	local player = self.GetPlayer(self, playerId)

	if not player then
		return
	end

	self.HandleMeatRelease(self, player)

	player.draggedPartId = -1
	player.hasEnterDrag = false
end

BBQGame.OnAIMeatClick = function(self, playerId, meatId)
	local meat = self.meats[meatId]

	if meat and meat.ownerPlayerId ~= nil and meat.state ~= MeatState.OnGrill then
		meat.OnClick(meat)
	end
end

BBQGame.OnAIPlateBeginDrag = function(self, playerId, plateId)
	local meat = self.CreateMeatFromPlate(self, plateId)
	local player = self.GetPlayer(self, playerId)

	if meat and player then
		meat.ownerPlayerId = playerId
		player.draggedPartId = meat.id
		player.hasEnterDrag = true

		self.PlayMeatClipSound(self, meat)

		return meat.id
	end

	return nil
end

BBQGame.AddScoreToPlayer = function(self, playerId, singleScore, cookedLevel)
	local player = self.GetPlayer(self, playerId)

	if not player then
		return
	end

	player.singleAddScore = singleScore
	player.totalScore = player.totalScore + singleScore

	gBBQGameManager:AddPlayerScore(playerId, singleScore, cookedLevel)
end

local HOVER_EFFECT_ID = 538000452

BBQGame.UpdateHoverOutline = function(self)
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

	local player = self.GetPlayer(self, BBQConstants.LocalSeatIndex)
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

BBQGame.StopHoverOutline = function(self)
	if self.m_HoverEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.m_HoverEffectUUID)

		self.m_HoverEffectUUID = nil
	end

	self.m_HoverMeatId = nil
end

BBQGame.PlayChopsticksClipAir = function(self)
	gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.ChopsticksClipAir)
end

BBQGame.PlayMeatClipSound = function(self, meat)
	if not meat then
		return
	end

	local pos = meat.GetPosition(meat)

	if pos then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.MeatClip, pos)
	end
end

BBQGame.CheckGrillStateChange = function(self)
	local hasMeat = self.HasGrillMeat(self)

	if hasMeat and not self.m_GrillHadMeat then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.GrillExist)
	elseif not hasMeat and self.m_GrillHadMeat then
		gSoundMgr:PlaySoundByTid(BBQConstants.SoundTid.GrillEmpty)
	end

	self.m_GrillHadMeat = hasMeat
end

BBQGame.HasGrillMeat = function(self)
	for _, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and meat.state == MeatState.Dragging then
			return true
		end
	end

	return false
end

BBQGame.GetPlayer = function(self, playerId)
	return self.players[playerId + 1]
end

BBQGame.IsSeatOccupied = function(self, seatIndex)
	return self.m_OccupiedSeats[seatIndex] ~= true
end

BBQGame.GetMouseSlotForSeat = function(self, seatIndex)
	local mySeat = BBQConstants.LocalSeatIndex

	if seatIndex ~= mySeat then
		return "self"
	end

	local slot = 0

	for s = 0, BBQConstants.MaxPlayers - 1 do
		if s == mySeat then
			slot = slot + 1

			if s ~= seatIndex then
				return "p" .. slot
			end
		end
	end

	return nil
end

BBQGame.IsSeatHoldingMeat = function(self, seatIndex)
	local p = self:GetPlayer(seatIndex)

	return p and p.hasEnterDrag or false
end

BBQGame.GetMeat = function(self, meatId)
	return self.meats[meatId]
end

BBQGame.GetMaterialForLevel = function(self, meatType, level)
	local byLevel = self.materialCache[meatType]

	if not byLevel then
		print_error(string.format("[BBQGame] GetMaterialForLevel: materialCache[%s] is nil, material not loaded for this meatType", tostring(meatType)))

		return nil
	end

	local mat = byLevel[level]

	if not mat then
		print_error(string.format("[BBQGame] GetMaterialForLevel: materialCache[%s][%s] is nil, material not loaded for this level", tostring(meatType), tostring(level)))
	end

	return mat
end

BBQGame.GetBurntMeats = function(self)
	local result = {}

	for _, meatId in ipairs(self.burntMeatIds) do
		local meat = self.meats[meatId]

		if meat and meat.ownerPlayerId ~= nil then
			table.insert(result, meat)
		end
	end

	return result
end

BBQGame.GetAvailableGrillMeats = function(self, onlyForFlip, aiController)
	local result = {}

	for meatId, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and not meat.meatData.isBurnt and meat.state ~= MeatState.OnGrill and meat.ownerPlayerId ~= nil and (not onlyForFlip or not aiController or not aiController.IsFlipCoolingDown(aiController, meatId)) then
			table.insert(result, meatId)
		end
	end

	return result
end

BBQGame.GetAllGrillMeatData = function(self)
	local result = {}

	for _, meat in pairs(self.meats) do
		if meat.isPlacedOnGrill and meat.meatData then
			table.insert(result, meat.meatData)
		end
	end

	return result
end

BBQGame.GetOtherPlayerBowls = function(self, playerId)
	local result = {}

	for id, bowl in pairs(self.sauceBowls) do
		if id == playerId and self.IsSeatOccupied(self, id) then
			table.insert(result, bowl)
		end
	end

	return result
end

BBQGame.GetPlayerBowl = function(self, playerId)
	return self.sauceBowls[playerId]
end

BBQGame.GetPlates = function(self)
	local result = {}

	for plateName, plate in pairs(self.plates) do
		table.insert(result, {
			id = plateName,
			position = plate.position
		})
	end

	return result
end

BBQGame.GetGrillPosition = function(self)
	return self.grill and self.grill.position or nil
end

BBQGame.GetMeatWorldPosition = function(self, meatId)
	local meat = self.meats[meatId]

	return meat and meat:GetPosition() or nil
end

BBQGame.GetBowlWorldPosition = function(self, bowl)
	return bowl and bowl.position or nil
end

BBQGame.GetPlateWorldPosition = function(self, plateId)
	local plate = self.plates[plateId]

	return plate and plate.position or nil
end

BBQGame.GetDropPositionOnGrill = function(self)
	return self.grill and self.grill:GetRandomPosition() or nil
end

BBQGame.SetPlayerInputPosition = function(self, playerId, x, y)
	self.playerInputPositions[playerId] = {
		x = x,
		y = y
	}
end

BBQGame.SetInputTakenOver = function(self, taken)
	self.m_IsInputTakenOver = taken and true or false
end

BBQGame.OnSceneDestroyed = function(self)
	self.hasDestroy = true

	self.StopAIControllers(self)
	coroutine.start(function ()
		coroutine.wait(0)

		if gBBQGameManager then
			gBBQGameManager:StopBBQGame()
		end
	end)
end

BBQGame.OnGameEnd = function(self)
	gBBQGameManager:OnGameTimerUp()
	self:StopAIControllers()
end

BBQGame.StopAIControllers = function(self)
	for _, aiController in ipairs(self.aiControllers) do
		aiController.OnExit(aiController)
	end
end

BBQGame.CleanGame = function(self)
	self.CleanupAndDestroy(self)
end

BBQGame.CleanupAndDestroy = function(self)
	self.hasDestroy = true

	self.StopHoverOutline(self)

	if self.mainCoroutine then
		coroutine.stop(self.mainCoroutine)

		self.mainCoroutine = nil
	end

	self.StopAIControllers(self)

	self.aiControllers = {}

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

	if gClientUtils.NotNil(self.cameraGo) then
		self.cameraGo:SetActive(false)
	end

	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.BBQ_PANEL_STORE)

	self.cameraGo = nil
	self.burntMeatIds = {}
	self.materialCache = {}
	self.meatTemplates = {}
	self.plates = {}
	self.sauceBowls = {}
	self.grill = nil
	self.sceneNodeGo = nil

	self.grillCache:Clear()

	for _, player in pairs(self.players) do
		player.Reset(player)
	end

	self.SetSceneOtherNodesVisible(self, true)
end
