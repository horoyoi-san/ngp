-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureManager.lua
-- Decompiled from: 00742_FurnitureManager.lua_ce015e2ef2c7.luajit

local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local MessageConfig = LTConfig.MessageConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local CSFurnitureMono = LX6.UGC.HouseFurniture
local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
C_FurnitureManager = DefClass("C_FurnitureManager", C_FurnitureManager)
local M = C_FurnitureManager

M.ctor = function(self)
	self.followingFurniture = nil
	self.followingFurnitureComponent = nil
	self.isFollowing = false
	self.followingFurnitureId = nil
	self.followingFurnitureConfig = nil
	self.nowHitLayer = nil
	self.nowHitNormal = nil
	self.nowHitGameObject = nil
	self.followingFurnitureManualRotation = 0
	self.carryUid2AdsUidListDict = {}
	self.isLongPressing = false
	self.canFollow = false
	self.dragStartScreenPos = nil
	self.dragThreshold = 5
	self.isEditingExisting = false
	self.canEditPlacedFurniture = false
	self.lastCanPlaceState = nil
	self.currentOperationUniqueId = nil
	self.furnitureRoot = nil
	self.gridSystemSetupInstanceId = 0
	self.gridSystemSetupBuildId = 0
	self.uniqueIdCounter = 0
	self.CLIENT_UID_BASE = -1000000000
	self.baseMeshGo = nil
	self.baseMeshLoadOp = nil
	self.gadgetMeshGo = nil
	self.gadgetMeshLoadOp = nil
	self.surfaceHintMeshGo = nil
	self.surfaceHintMeshLoadOp = nil
	self.surfaceHintMeshEnabled = false
	self.currentSurfaceCollider = nil
	self.currentSurfaceBounds = nil
	self.currentSurfaceAdsorptionType = nil
	self.currentSurfaceNormal = nil
	self.gridModeEnabled = false
	self.gridSize = 0.2
	self.gridModePlaneNormal = nil
	self.gridModePlanePoint = nil
	self.lastUseGridMeshForFurniture = false
	self.fenSkipState = {}
	self.fenestrationBoundsBoxEnabled = false
	self.lastCollisionState = false
	self.collisionCheckInterval = 0.1
	self.lastCollisionCheckTime = 0
	self.lastBoundaryState = true
	self.furnitureMaterials = {}
	self.baseMeshMaterials = {}
	self.gadgetMeshMaterials = {}
	self.defaultColors = {}
	self.hoveredFurnitureGo = nil
	self.hoveredFurnitureUID = nil
	self.hoverEffectUUID = nil
	self.rotationAxisMeshGo = nil
	self.rotationAxisMeshLoadOp = nil
	self.isRotatingDrag = false
	self.rotationDragStartAngle = 0
	self.rotationDragStartScreenPos = nil
	self.followingFurnitureRotationAngle = 0
	self.hoverSuppressChecker = nil
	self.hoverFurnitureFilter = nil
	self.hasValidSurface = false
end

M.OnInit = function(self)
	gFurnitureOperationManager:OnInit()
	self:CreateFurnitureRoot()
end

M.OnUpdate = function(self)
	if self.canEditPlacedFurniture and not self.isFollowing then
		local inputPos = SGUI.Utils.GetInputCenterPosition()
		local isClicked = SGUI.Utils.IsTouchBegan(inputPos)

		if not isClicked and not self.isLongPressing and not self.isFollowing then
			self.CheckHoveredFurniture(self)
		end
	end

	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	if not self.isLongPressing or not self.canFollow then
		return
	end

	local adsorptionTypes = self.followingFurnitureConfig.AdsorptionTypeFinal
	local layerMask = self.GetFurnitureLayerMask(self, adsorptionTypes)
	local newPosition, hitLayer, hitNormal, surfaceBounds, surfaceCollider = nil

	if not newPosition then
		newPosition, hitLayer, hitNormal, surfaceBounds, surfaceCollider = self:GetMultiLayerRaycastPosition(layerMask)
		local adsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor

		self:BuildGridModePlane(newPosition, adsorptionType, hitNormal)
	end

	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal

	self:RefreshGridMeshForFurniture(hitLayer and (LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor) or nil, self.nowHitGameObject)
	self:_RefreshHasValidSurface(newPosition == nil)

	if newPosition then
		local currentRotation = self.followingFurniture.transform.rotation
		local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
		local applyManualRotation = adsorptionType ~= AdsorptionType.Wall
		local adjustedPosition, adjustedRotation = self:AdjustFurniturePosition(newPosition, currentRotation, applyManualRotation)
		local finalPosition = gFurnitureUtils:SnapToGrid(adjustedPosition, adsorptionType, self.gridModeEnabled, self.gridSize, self.nowHitNormal)
		local fenestrationAdjusted = gWallFurniturePlacementUtils:UpdateFenestrationSkip(self.fenSkipState, finalPosition, adsorptionType, self.followingFurniture, self.followingFurnitureComponent, self.nowHitGameObject, self:GetGridSystemProxy())

		if fenestrationAdjusted then
			finalPosition = fenestrationAdjusted
			adjustedRotation = self.followingFurniture.transform.rotation
		end

		local isPositionValid = gHouseManager:IsPositionInBuildBound(finalPosition)
		local boundaryStateChanged = isPositionValid == self.lastBoundaryState
		self.lastBoundaryState = isPositionValid

		if isPositionValid then
			self.followingFurniture.transform.position = finalPosition
			self.followingFurniture.transform.rotation = adjustedRotation

			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_POSITION_CHANGED, {
				position = finalPosition,
				rotation = adjustedRotation
			})

			local currentTime = gLogicTime.time

			if self.collisionCheckInterval < currentTime - self.lastCollisionCheckTime then
				self.lastCollisionCheckTime = currentTime
				local isColliding = self.CheckFurnitureCollision(self)

				if boundaryStateChanged or isColliding == self.lastCollisionState then
					self.lastCollisionState = isColliding

					self.SetFurnitureColor(self, self.followingFurniture, isColliding, false)
				end
			elseif boundaryStateChanged then
				local isColliding = self.CheckFurnitureCollision(self)
				self.lastCollisionState = isColliding

				self.SetFurnitureColor(self, self.followingFurniture, isColliding, false)
			end
		else
			if boundaryStateChanged then
				print_debug("[CheckFurnitureCollision] 家具移出房间边界，变红")
			end

			self.SetFurnitureColor(self, self.followingFurniture, true, true)
		end
	elseif self.hasValidSurface then
		if self.lastBoundaryState then
			local carryName = self.nowHitGameObject and not gCS.LuaUtils.IsNull(self.nowHitGameObject) and self.nowHitGameObject.name or "<unknown>"

			print_debug(string.format("[CheckFurnitureCollision] 家具移出承载面边界，变红，承载面: %s", carryName))
		end

		self.lastBoundaryState = false

		self.SetFurnitureColor(self, self.followingFurniture, true, true)
	end

	if self.surfaceHintMeshEnabled then
		self.UpdateSurfaceHintMeshIfNeeded(self, newPosition, hitLayer, hitNormal, surfaceBounds, surfaceCollider)
	end
end

M.CreateFurnitureRoot = function(self)
	self.furnitureRoot = gHouseSceneLayout:GetFurnitureRoot()
end

M.SetupGridSystemByBuildConfig = function(self, buildCfg, houseId)
	self:CreateFurnitureRoot()

	local houseRoot = gHouseSceneLayout:EnsureHouseRootGo(houseId)

	if not houseRoot or gCS.LuaUtils.IsNull(houseRoot) then
		print_error(string.format("FurnitureManager: SetupGridSystemByBuildConfig 无法取得 houseRoot, houseId=%s", tostring(houseId)))

		return
	end

	local gridOrigin = buildCfg.GridOrigin
	houseRoot.transform.localPosition = Vector3.New(gridOrigin[1], gridOrigin[2], gridOrigin[3])
	houseRoot.transform.localEulerAngles = Vector3.New(gridOrigin[4] or 0, gridOrigin[5] or 0, gridOrigin[6] or 0)
	local gridSystem = houseRoot:GetOrAddComponent(typeof(LX6.GamePlay.House.LuaGridSystemProxy))

	self:InitGridSystemProxyResList(gridSystem)

	local instanceId = gridSystem:GetInstanceID()
	local houseTransform = gridSystem.transform:Find("House")
	local hasHouseRoot = houseTransform and not gCS.LuaUtils.IsNull(houseTransform)
	self.gridSystemSetupStates = self.gridSystemSetupStates or {}
	local state = self.gridSystemSetupStates[houseId]

	if not state or state.instanceId == instanceId or state.buildId == buildCfg.Id or not hasHouseRoot then
		gridSystem.CloseGridSystem(gridSystem)
		gridSystem.SetupGridSystem(gridSystem)

		self.gridSystemSetupStates[houseId] = {
			instanceId = instanceId,
			buildId = buildCfg.Id
		}
	end
end

M.ClearGridSystemSetupStates = function(self)
	self.gridSystemSetupStates = {}
end

M.InitGridSystemProxyResList = function(self, gridSystem)
	local instanceId = gridSystem.GetInstanceID(gridSystem)

	if self.gridSystemProxyResListInitedId ~= instanceId then
		return
	end

	self.gridSystemProxyResLoadOps = {}

	if not self.fenestrationResIndex then
		self.fenestrationResIndex = {}
		self.texResIndex = {}

		for i = 0, HouseFurnitureConfig.count - 1 do
			local cfg = HouseFurnitureConfig.LoadAt(i)
			local modelName = cfg.ModelName

			if modelName and modelName == "" then
				local subType = cfg.SubType

				if gFurnitureUtils:IsFenestrationSubType(subType) then
					self.fenestrationResIndex[cfg.Id] = modelName
				elseif gFurnitureUtils:IsTexSubType(subType) then
					self.texResIndex[cfg.Id] = modelName
				end
			end
		end
	end

	self.gridSystemProxyResListInitedId = instanceId
end

M.LoadMatForCS = function(self, cfgId, gridSystem)
	return gridSystem.LoadAssetProxy(gridSystem, cfgId)
end

M.OnFenestrationRenderComplete = function(self, gridProxy)
	gHouseGadgetManager:OnFenestrationRenderComplete(gridProxy)
end

M.GetFurnitureRoot = function(self)
	self.CreateFurnitureRoot(self)

	return self.furnitureRoot
end

M.FindFurnitureByUniqueId = function(self, uniqueId)
	return gFurnitureUIDManager.uid2FurnitureGoDict[uniqueId] or nil
end

M.GenerateUniqueId = function(self)
	self.uniqueIdCounter = self.uniqueIdCounter + 1

	return self.CLIENT_UID_BASE - self.uniqueIdCounter
end

M.OnDestroy = function(self)
	self.ClearFollowingFurniture(self)
end

M.SpawnFurniture = function(self, furnitureId, initAtScreenCenter)
	if not gHouseManager:IsFurnitureUsable(furnitureId) then
		gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")

		return false
	end

	self.ClearHoveredFurniture(self)

	if self.isFollowing and self.followingFurniture then
		self.ClearFollowingFurniture(self)
	elseif self.followingFurniture then
		self.ClearFollowingFurniture(self)
	end

	self.currentOperationUniqueId = self:GenerateUniqueId()

	gFurnitureOperationManager:BeginSpawnOperation(furnitureId, self.currentOperationUniqueId)

	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)
	self.followingFurnitureId = furnitureId
	self.followingFurnitureConfig = furnitureCfg
	local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)

	self:EnableFenestrationBoundsBoxIfWall(furnitureCfg)

	local spawnPosition, hitLayer, hitNormal, surfaceBounds = self:GetMultiLayerRaycastPosition(layerMask, initAtScreenCenter)

	if not spawnPosition and initAtScreenCenter then
		local adsorptionTypes = furnitureCfg.AdsorptionTypeFinal

		if adsorptionTypes and #adsorptionTypes <= 0 then
			local primaryType = adsorptionTypes[1]

			if primaryType ~= AdsorptionType.Floor then
				gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildOnlyAllowFloor)
			elseif primaryType ~= AdsorptionType.Wall then
				gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildOnlyAllowWall)
			elseif primaryType ~= AdsorptionType.Ceiling then
				gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildOnlyAllowCeiling)
			else
				gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCantSetFurniture)
			end
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCantSetFurniture)
		end

		return
	end

	local hasInitialHit = spawnPosition == nil

	if not hasInitialHit then
		spawnPosition = Vector3.zero
		hitLayer, hitNormal = nil
	end

	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal
	self.hasValidSurface = hasInitialHit
	local spawnAdsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor

	if hasInitialHit then
		self.BuildGridModePlane(self, spawnPosition, spawnAdsorptionType, hitNormal)
	end

	local capturedHitGo = self.nowHitGameObject
	slot12 = gResourceManager

	slot12:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)

			if not hasInitialHit then
				furnitureGo:SetActive(false)
			end

			local defaultY = gHouseManager:GetNowBuildDefaultTowards()
			local parentRoot = gHouseSceneLayout:EnsureHouseNamespaceGo(gHouseManager:GetCurHouseId())

			if parentRoot and not gCS.LuaUtils.IsNull(parentRoot) then
				furnitureGo.transform:SetParent(parentRoot.transform, true)
			end

			self.followingFurniture = furnitureGo
			self.followingFurnitureComponent = furnitureGo:GetComponent(typeof(CSFurnitureMono))

			self:SetMovingFurnitureLightDynamicMode(furnitureGo, true, self.followingFurnitureComponent)

			self.isFollowing = true
			self.isLongPressing = false
			self.canFollow = false

			if not initAtScreenCenter then
				self.isLongPressing = true
				self.canFollow = true
			end

			if hasInitialHit and spawnAdsorptionType ~= AdsorptionType.Wall and capturedHitGo then
				local fenInfo = gWallEditManager:GetFenestrationHitInfo(capturedHitGo)

				if fenInfo then
					local wallData = gWallFurniturePlacementUtils:GetWallEdgeData(capturedHitGo, self:GetGridSystemProxy())

					if wallData then
						local furHalfWidth = gWallFurniturePlacementUtils:GetFurnitureHalfWidthOnWall(furnitureGo, self.followingFurnitureComponent, wallData.dir)
						local zones = gWallFurniturePlacementUtils:GetFenestrationExclusionZones(wallData.gridSystemProxy, wallData.edgeA, wallData.edgeB, wallData.startPos, wallData.endPos, wallData.dir, wallData.length, furHalfWidth, wallData.tagIndex)
						local desiredT = gWallFurniturePlacementUtils:ProjectOntoWall(spawnPosition, wallData.startPos, wallData.dir)
						local validT = gWallFurniturePlacementUtils:FindNearestValidT(desiredT, furHalfWidth, zones, wallData.length)

						if not validT then
							gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCantSetFurniture)
							self:ClearFollowingFurniture()

							return
						end

						local wallSurfacePos = gWallFurniturePlacementUtils:RaycastWallSurface(validT, wallData, hitNormal, spawnPosition.y)

						if wallSurfacePos then
							spawnPosition = wallSurfacePos
						else
							spawnPosition = gWallFurniturePlacementUtils:WallTToWorldPos(validT, wallData.startPos, wallData.dir, spawnPosition)
						end

						gWallFurniturePlacementUtils:InitFenSkipState(self.fenSkipState, wallData, validT)
					end
				end
			end

			local baseRotation = Quaternion.Euler(0, defaultY, 0)
			local adjustedPosition, adjustedRotation = self:AdjustFurniturePosition(spawnPosition, baseRotation)
			furnitureGo.transform.position = adjustedPosition
			furnitureGo.transform.rotation = adjustedRotation

			if hasInitialHit then
				gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_POSITION_CHANGED, {
					position = adjustedPosition,
					rotation = adjustedRotation
				})
			end

			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, self.currentOperationUniqueId, false)

			self:SetFurnitureInteractionEnabled(furnitureGo, false)

			local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor

			self:GenerateBaseMesh(furnitureCfg, adsorptionType, self.nowHitNormal)

			if furnitureCfg.RotType and furnitureCfg.RotType == LTConfig.HouseFurnitureConfig.RotTypeType.None then
				self:GenerateRotationAxisMesh(furnitureCfg, adsorptionType, self.nowHitNormal)
			end

			self:RefreshGridMeshForFurniture(adsorptionType, self.nowHitGameObject)

			if surfaceBounds and self.surfaceHintMeshEnabled then
				self:GenerateSurfaceHintMesh(surfaceBounds, adsorptionType, self.nowHitNormal)
			end

			self:CreateMaterialInstances(furnitureGo)

			local isColliding = self:CheckFurnitureCollision()

			self:SetFurnitureColor(self.followingFurniture, isColliding)
			gFurnitureShowCaseUtils:DrivePreviewUnitFollow(furnitureGo)
			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_ENTER_EDIT)

			if not hasInitialHit then
				gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_POSITION_CHANGED, {
					["[\\xaf\\xae\\xa6\\xb2"] = false
				})
			end
		else
			print_error(string.format("FurnitureManager: 加载家具模型失败 [%s] 路径:%s", furnitureCfg.Name or "未知", furnitureCfg.ModelName))
		end
	end)
end

M.GetFurnitureLayerMask = function(self, adsorptionTypes)
	local isAdsorptOnItem = self.followingFurnitureConfig and self.followingFurnitureConfig.IsAdsorptOnItem

	return gFurnitureRaycastUtils:GetFurnitureLayerMask(adsorptionTypes, isAdsorptOnItem)
end

M.IsCarrySurfaceHit = function(self, hitGameObject)
	local hitGo = hitGameObject or self.nowHitGameObject

	if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
		return false
	end

	local tag, extraTag = gCS.LuaUtils.GetGameObjectTags(hitGo, "")

	return gFurnitureUtils:IsCarryFurnitureTag(tag, extraTag)
end

M.ShouldUseGridMeshForFurniture = function(self, adsorptionType, hitGameObject)
	if not self.gridModeEnabled or not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return false
	end

	local currentAdsorptionType = adsorptionType

	if currentAdsorptionType ~= nil and self.nowHitLayer == nil then
		currentAdsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
	end

	if currentAdsorptionType == AdsorptionType.Floor then
		return false
	end

	if self.IsCarrySurfaceHit(self, hitGameObject) then
		return false
	end

	if gWallEditManager and gWallEditManager.IsGridMeshAvailable and not gWallEditManager:IsGridMeshAvailable() then
		return false
	end

	return true
end

M.ShouldUseSurfaceHintMesh = function(self, adsorptionType, hitGameObject)
	if not self.gridModeEnabled or not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return false
	end

	local currentAdsorptionType = adsorptionType

	if currentAdsorptionType ~= nil and self.nowHitLayer == nil then
		currentAdsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
	end

	if currentAdsorptionType ~= AdsorptionType.Wall then
		return false
	end

	return not self.ShouldUseGridMeshForFurniture(self, adsorptionType, hitGameObject)
end

M.RefreshGridMeshForFurniture = function(self, adsorptionType, hitGameObject)
	local shouldUseGridMesh = self.ShouldUseGridMeshForFurniture(self, adsorptionType, hitGameObject)

	if shouldUseGridMesh then
		self.ClearSurfaceHintMesh(self)
	end

	if self.lastUseGridMeshForFurniture ~= shouldUseGridMesh then
		return
	end

	self.lastUseGridMeshForFurniture = shouldUseGridMesh

	if gWallEditManager and gWallEditManager.RefreshGroundHintMesh then
		gWallEditManager:RefreshGroundHintMesh()
	end
end

M.GetGridSystemProxy = function(self)
	local houseId = gHouseManager and gHouseManager.GetCurHouseId and gHouseManager:GetCurHouseId() or 0
	local houseRoot = gHouseSceneLayout:GetHouseRootGo(houseId)

	if not houseRoot or gCS.LuaUtils.IsNull(houseRoot) then
		return nil
	end

	return houseRoot.GetComponent(houseRoot, typeof(LX6.GamePlay.House.LuaGridSystemProxy))
end

M.EnableFenestrationBoundsBoxIfWall = function(self, furnitureCfg)
	if not furnitureCfg or not furnitureCfg.AdsorptionTypeFinal then
		return
	end

	local hasWall = false

	for _, aType in ipairs(furnitureCfg.AdsorptionTypeFinal) do
		if aType ~= AdsorptionType.Wall then
			hasWall = true

			break
		end
	end

	if not hasWall then
		return
	end

	local gridSystemProxy = self.GetGridSystemProxy(self)

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
		return
	end

	local fenTrans = gridSystemProxy.fenestrationsTransform

	if not fenTrans or gCS.LuaUtils.IsNull(fenTrans) then
		return
	end

	CSFurnitureManager.EnableAllBoundsBox(fenTrans.gameObject, true)

	self.fenestrationBoundsBoxEnabled = true
end

M.DisableFenestrationBoundsBox = function(self)
	if not self.fenestrationBoundsBoxEnabled then
		return
	end

	self.fenestrationBoundsBoxEnabled = false
	local gridSystemProxy = self.GetGridSystemProxy(self)

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
		return
	end

	local fenTrans = gridSystemProxy.fenestrationsTransform

	if not fenTrans or gCS.LuaUtils.IsNull(fenTrans) then
		return
	end

	CSFurnitureManager.EnableAllBoundsBox(fenTrans.gameObject, false)
end

M.RestoreFenestrationBoundsBox = function(self)
	if not self.fenestrationBoundsBoxEnabled then
		return
	end

	local gridSystemProxy = self.GetGridSystemProxy(self)

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
		return
	end

	local fenTrans = gridSystemProxy.fenestrationsTransform

	if fenTrans and not gCS.LuaUtils.IsNull(fenTrans) then
		CSFurnitureManager.EnableAllBoundsBox(fenTrans.gameObject, true)
	end
end

M.BuildGridModePlane = function(self, seedPosition, adsorptionType, hitNormal)
	if not self.gridModeEnabled or not seedPosition then
		self.gridModePlaneNormal = nil
		self.gridModePlanePoint = nil

		return false
	end

	local gridSystem = self.GetGridSystemProxy(self)

	if not gridSystem then
		self.gridModePlaneNormal = nil
		self.gridModePlanePoint = nil

		return false
	end

	if adsorptionType ~= AdsorptionType.Wall and hitNormal and hitNormal == Vector3.zero then
		local normal = Vector3.New(hitNormal.x, 0, hitNormal.z).normalized

		if normal ~= Vector3.zero then
			return false
		end

		self.gridModePlaneNormal = normal
		self.gridModePlanePoint = Vector3.New(seedPosition.x, seedPosition.y, seedPosition.z)

		return true
	end

	local planeY = gridSystem.transform.position.y + gridSystem._floorLevel * gridSystem._floorHeight

	if adsorptionType ~= AdsorptionType.Ceiling then
		planeY = planeY + gridSystem._floorHeight
	end

	self.gridModePlaneNormal = Vector3.up
	self.gridModePlanePoint = Vector3.New(0, planeY, 0)

	return true
end

M.GetCurrentCeilingBottomY = function(self, defaultY)
	if CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] and CSFurnitureManager.SortedRayCastList[0].collider then
		return CSFurnitureManager.SortedRayCastList[0].collider.bounds.min.y
	end

	if self.nowHitGameObject and not gCS.LuaUtils.IsNull(self.nowHitGameObject) then
		local collider = self.nowHitGameObject:GetComponent(typeof(UnityEngine.Collider))

		if collider and not gCS.LuaUtils.IsNull(collider) then
			return collider.bounds.min.y
		end
	end

	return defaultY
end

M.AdjustFurniturePosition = function(self, position, baseRotation, applyManualRotation)
	local adjustedPosition = position
	local adjustedRotation = baseRotation or Quaternion.identity
	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor

	if adsorptionType ~= AdsorptionType.Floor then
		adjustedPosition = Vector3.New(position.x, position.y, position.z)
	elseif adsorptionType ~= AdsorptionType.Ceiling then
		local ceilingBottomY = self.GetCurrentCeilingBottomY(self, position.y)
		adjustedPosition = Vector3.New(position.x, ceilingBottomY, position.z)
	elseif adsorptionType ~= AdsorptionType.Wall then
		if self.nowHitNormal and self.nowHitNormal == Vector3.zero then
			adjustedRotation = gFurnitureUtils:CalculateWallBaseRotation(self.nowHitNormal)
		else
			print_warn("FurnitureManager: 墙面法线无效，使用默认旋转和位置")

			adjustedRotation = baseRotation or Quaternion.identity
		end
	else
		print_warn(string.format("FurnitureManager: 未知吸附类型: %d，保持原位置和旋转", adsorptionType))
	end

	local rotationAngle = self.followingFurnitureRotationAngle == 0 and self.followingFurnitureRotationAngle or self.followingFurnitureManualRotation

	if applyManualRotation == false and rotationAngle == 0 then
		if adsorptionType ~= AdsorptionType.Wall then
			adjustedRotation = gFurnitureUtils:ApplyWallManualRotation(adjustedRotation, rotationAngle)
		else
			local worldRotationAxis = gFurnitureUtils:GetRotationAxis(adsorptionType, self.nowHitNormal)
			local manualRotation = Quaternion.AngleAxis(rotationAngle, worldRotationAxis)
			adjustedRotation = adjustedRotation * manualRotation
		end
	end

	return adjustedPosition, adjustedRotation
end

M.GenerateBaseMesh = function(self, furnitureCfg, adsorptionType, hitNormal)
	local furnitureGo = self.followingFurniture
	local meshState = {
		baseMeshGo = self.baseMeshGo,
		baseMeshLoadOp = self.baseMeshLoadOp,
		gadgetMeshGo = self.gadgetMeshGo,
		gadgetMeshLoadOp = self.gadgetMeshLoadOp
	}
	slot6 = gFurnitureMeshUtils

	slot6:GenerateBaseMesh(furnitureCfg, furnitureGo, self.followingFurnitureComponent, adsorptionType, hitNormal, meshState, function (baseMeshGo)
		self.baseMeshGo = baseMeshGo
		local materialState = {
			furnitureMaterials = self.furnitureMaterials,
			baseMeshMaterials = self.baseMeshMaterials,
			gadgetMeshMaterials = self.gadgetMeshMaterials,
			defaultColors = self.defaultColors
		}

		gFurnitureMaterialUtils:CreateMaterialInstances(furnitureGo, baseMeshGo, nil, materialState)

		if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
			local isColliding = self:CheckFurnitureCollision()
			local newCanPlace = gFurnitureMaterialUtils:SetFurnitureColor(self.followingFurniture, isColliding, false, baseMeshGo, nil, self.lastCanPlaceState)

			if newCanPlace == nil then
				self.lastCanPlaceState = newCanPlace

				gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED, {
					canPlace = newCanPlace
				})
			end
		end
	end, function (gadgetMeshGo)
		self.gadgetMeshGo = gadgetMeshGo
		local materialState = {
			furnitureMaterials = self.furnitureMaterials,
			baseMeshMaterials = self.baseMeshMaterials,
			gadgetMeshMaterials = self.gadgetMeshMaterials,
			defaultColors = self.defaultColors
		}

		gFurnitureMaterialUtils:CreateMaterialInstances(furnitureGo, self.baseMeshGo, gadgetMeshGo, materialState)

		if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
			local isColliding = self:CheckFurnitureCollision()
			local newCanPlace = gFurnitureMaterialUtils:SetFurnitureColor(self.followingFurniture, isColliding, false, self.baseMeshGo, gadgetMeshGo, self.lastCanPlaceState)

			if newCanPlace == nil then
				self.lastCanPlaceState = newCanPlace

				gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED, {
					canPlace = newCanPlace
				})
			end
		end
	end)

	self.baseMeshLoadOp = meshState.baseMeshLoadOp
	self.gadgetMeshLoadOp = meshState.gadgetMeshLoadOp
	self.isBaseFootprint = meshState.isBaseFootprint
end

M.GenerateGadgetMesh = function(self, gadgetMeshPath, furnitureGo, adsorptionType, hitNormal)
	local meshState = {
		baseMeshGo = self.baseMeshGo,
		baseMeshLoadOp = self.baseMeshLoadOp,
		gadgetMeshGo = self.gadgetMeshGo,
		gadgetMeshLoadOp = self.gadgetMeshLoadOp
	}
	slot6 = gFurnitureMeshUtils

	slot6:GenerateGadgetMesh(gadgetMeshPath, furnitureGo, self.followingFurnitureComponent, adsorptionType, hitNormal, meshState, function (gadgetMeshGo)
		self.gadgetMeshGo = gadgetMeshGo
		local materialState = {
			furnitureMaterials = self.furnitureMaterials,
			baseMeshMaterials = self.baseMeshMaterials,
			gadgetMeshMaterials = self.gadgetMeshMaterials,
			defaultColors = self.defaultColors
		}

		gFurnitureMaterialUtils:CreateMaterialInstances(furnitureGo, self.baseMeshGo, gadgetMeshGo, materialState)

		if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
			local isColliding = self:CheckFurnitureCollision()
			local newCanPlace = gFurnitureMaterialUtils:SetFurnitureColor(self.followingFurniture, isColliding, false, self.baseMeshGo, gadgetMeshGo, self.lastCanPlaceState)

			if newCanPlace == nil then
				self.lastCanPlaceState = newCanPlace

				gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED, {
					canPlace = newCanPlace
				})
			end
		end
	end)

	self.gadgetMeshLoadOp = meshState.gadgetMeshLoadOp
end

M.AdjustBaseMeshSize = function(self, furnitureGo, adsorptionType, hitNormal)
	if not self.baseMeshGo then
		return
	end

	gFurnitureMeshUtils:AdjustBaseMeshSize(furnitureGo, self.followingFurnitureComponent, adsorptionType, hitNormal, self.baseMeshGo)
end

M.GenerateSurfaceHintMesh = function(self, surfaceBounds, adsorptionType, hitNormal)
	if not self.ShouldUseSurfaceHintMesh(self, adsorptionType) then
		self.ClearSurfaceHintMesh(self)

		return
	end

	local finalSurfaceBounds = self.GetSurfaceHintBounds(self, surfaceBounds, adsorptionType, hitNormal)

	if not finalSurfaceBounds then
		return
	end

	self:ClearSurfaceHintMesh()

	slot5 = gFurnitureMeshUtils

	slot5:GenerateSurfaceHintMesh(finalSurfaceBounds, adsorptionType, hitNormal, self.followingFurniture, self.gridModeEnabled, self.gridSize, self, function ()
		return gHouseSceneLayout:EnsureHouseNamespaceGo(gHouseManager:GetCurHouseId())
	end)
end

M.GetSurfaceHintBounds = function(self, surfaceBounds, adsorptionType, hitNormal)
	if not surfaceBounds then
		return nil
	end

	if not self.gridModeEnabled then
		return surfaceBounds
	end

	local gridSystemProxy = gWallEditManager and gWallEditManager.gridSystemProxy or nil

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) then
		return surfaceBounds
	end

	local seedPoint = surfaceBounds.center

	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		seedPoint = self.followingFurniture.transform.position
	end

	if adsorptionType ~= AdsorptionType.Wall then
		return surfaceBounds
	end

	if adsorptionType ~= AdsorptionType.Floor then
		local ok, bounds = CSFurnitureManager.MergeRendererBoundsByY(gridSystemProxy.floorsTransform, seedPoint.y, 0.6, nil)

		return ok and bounds or surfaceBounds
	end

	if adsorptionType ~= AdsorptionType.Ceiling then
		local ok, bounds = CSFurnitureManager.MergeRendererBoundsByY(gridSystemProxy.ceilingsTransform, seedPoint.y, 0.6, nil)

		return ok and bounds or surfaceBounds
	end

	return surfaceBounds
end

M.AdjustSurfaceHintMeshPosition = function(self, surfaceBounds, adsorptionType, hitNormal)
	if not self.surfaceHintMeshGo or not surfaceBounds then
		return
	end

	gFurnitureMeshUtils:AdjustSurfaceHintMeshPosition(surfaceBounds, adsorptionType, hitNormal, self.followingFurniture, self.gridModeEnabled, self.gridSize, self.surfaceHintMeshGo)
end

M.GenerateRotationAxisMesh = function(self, furnitureCfg, adsorptionType, hitNormal)
	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self.ClearRotationAxisMesh(self)

		return
	end

	local furnitureGo = self.followingFurniture

	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	self:ClearRotationAxisMesh()

	local meshState = {
		baseMeshGo = self.baseMeshGo,
		baseMeshLoadOp = self.baseMeshLoadOp,
		gadgetMeshGo = self.gadgetMeshGo,
		gadgetMeshLoadOp = self.gadgetMeshLoadOp,
		rotationAxisMeshGo = self.rotationAxisMeshGo,
		rotationAxisMeshLoadOp = self.rotationAxisMeshLoadOp
	}
	local created = false
	slot7 = gFurnitureMeshUtils

	slot7:GenerateRotationAxisMesh(furnitureCfg, furnitureGo, self.followingFurnitureComponent, adsorptionType, hitNormal, meshState, function (rotationAxisMeshGo)
		created = true
		self.rotationAxisMeshLoadOp = nil

		if rotationAxisMeshGo and not gCS.LuaUtils.IsNull(rotationAxisMeshGo) and (not self.isFollowing or self.followingFurniture == furnitureGo) then
			GameObject.Destroy(rotationAxisMeshGo)

			self.rotationAxisMeshGo = nil

			return
		end

		self.rotationAxisMeshGo = rotationAxisMeshGo
	end)

	if not created then
		self.rotationAxisMeshLoadOp = meshState.rotationAxisMeshLoadOp
	end
end

M.ClearRotationAxisMesh = function(self)
	local meshState = {
		rotationAxisMeshGo = self.rotationAxisMeshGo,
		rotationAxisMeshLoadOp = self.rotationAxisMeshLoadOp
	}

	gFurnitureMeshUtils:ClearRotationAxisMesh(meshState)

	self.rotationAxisMeshGo = meshState.rotationAxisMeshGo
	self.rotationAxisMeshLoadOp = meshState.rotationAxisMeshLoadOp
end

M.ClearBaseMesh = function(self)
	local meshState = {
		baseMeshGo = self.baseMeshGo,
		baseMeshLoadOp = self.baseMeshLoadOp,
		gadgetMeshGo = self.gadgetMeshGo,
		gadgetMeshLoadOp = self.gadgetMeshLoadOp,
		rotationAxisMeshGo = self.rotationAxisMeshGo,
		rotationAxisMeshLoadOp = self.rotationAxisMeshLoadOp,
		isBaseFootprint = self.isBaseFootprint
	}

	gFurnitureMeshUtils:ClearBaseMesh(meshState)

	self.baseMeshGo = meshState.baseMeshGo
	self.baseMeshLoadOp = meshState.baseMeshLoadOp
	self.gadgetMeshGo = meshState.gadgetMeshGo
	self.gadgetMeshLoadOp = meshState.gadgetMeshLoadOp
	self.rotationAxisMeshGo = meshState.rotationAxisMeshGo
	self.rotationAxisMeshLoadOp = meshState.rotationAxisMeshLoadOp
	self.isBaseFootprint = meshState.isBaseFootprint
end

M.ClearSurfaceHintMesh = function(self)
	gFurnitureMeshUtils:ClearSurfaceHintMesh(self)
end

M.SetSurfaceHintMeshEnabled = function(self, enabled)
	if self.surfaceHintMeshEnabled ~= enabled then
		return
	end

	local oldEnabled = self.surfaceHintMeshEnabled
	self.surfaceHintMeshEnabled = enabled

	if not enabled then
		self.ClearSurfaceHintMesh(self)
	elseif oldEnabled ~= false and enabled ~= true and self.isFollowing and self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) and self.ShouldUseSurfaceHintMesh(self) then
		self.RegenerateSurfaceHintMesh(self)
	end
end

M.SetGridModeEnabled = function(self, enabled)
	self.gridModeEnabled = enabled
	local adsorptionType = self.nowHitLayer and (LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor) or nil

	if enabled and self.isFollowing and self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) and adsorptionType then
		self.BuildGridModePlane(self, self.followingFurniture.transform.position, adsorptionType, self.nowHitNormal)
	else
		self.gridModePlaneNormal = nil
		self.gridModePlanePoint = nil
	end

	self.SetSurfaceHintMeshEnabled(self, enabled)
	self.RefreshGridMeshForFurniture(self, adsorptionType, self.nowHitGameObject)

	if gWallEditManager and gWallEditManager.RefreshGroundHintMesh then
		gWallEditManager:RefreshGroundHintMesh()
	end
end

M.GetGridModeEnabled = function(self)
	return self.gridModeEnabled
end

M.RegenerateSurfaceHintMesh = function(self)
	if not self.surfaceHintMeshEnabled then
		return
	end

	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	local furniturePosition = self.followingFurniture.transform.position
	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
	local raycastOrigin = furniturePosition
	local raycastDirection = Vector3.zero
	local layerMask = 0

	if adsorptionType ~= AdsorptionType.Floor then
		raycastOrigin = Vector3.New(furniturePosition.x, furniturePosition.y + 0.1, furniturePosition.z)
		raycastDirection = Vector3.down
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants.Floor
		})
	elseif adsorptionType ~= AdsorptionType.Ceiling then
		raycastOrigin = Vector3.New(furniturePosition.x, furniturePosition.y - 0.1, furniturePosition.z)
		raycastDirection = Vector3.up
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants._Ceiling
		})
	else
		raycastOrigin = Vector3.New(furniturePosition.x, furniturePosition.y + 0.1, furniturePosition.z)
		raycastDirection = Vector3.down
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants.Floor
		})
	end

	local raycastDistance = 10
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)
	local surfaceBounds, hitNormal = nil

	if hitCount <= 0 then
		local hitInfo = CSFurnitureManager.SortedRayCastList[0]

		if hitInfo.collider then
			surfaceBounds = hitInfo.collider.bounds
			hitNormal = hitInfo.normal
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)
			self.nowHitGameObject = hitGo
		end

		if surfaceBounds then
			self.RefreshGridMeshForFurniture(self, adsorptionType, self.nowHitGameObject)
			self.GenerateSurfaceHintMesh(self, surfaceBounds, adsorptionType, hitNormal)
		end
	else
		self.RefreshGridMeshForFurniture(self, nil, )
	end
end

M.UpdateSurfaceHintMeshIfNeeded = function(self, newPosition, hitLayer, hitNormal, surfaceBounds, surfaceCollider)
	if not self.surfaceHintMeshEnabled then
		if self.surfaceHintMeshGo or self.surfaceHintMeshLoadOp then
			self.ClearSurfaceHintMesh(self)
		end

		return
	end

	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) or not self.followingFurnitureConfig then
		if self.surfaceHintMeshGo or self.surfaceHintMeshLoadOp then
			self.ClearSurfaceHintMesh(self)
		end

		return
	end

	if self.surfaceHintMeshLoadOp then
		return
	end

	if not newPosition or not surfaceCollider or not surfaceBounds then
		self.RefreshGridMeshForFurniture(self, nil, )

		return
	end

	local adsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor
	local _, _, hitGameObject = gFurnitureRaycastUtils:GetColliderHitInfo(surfaceCollider)

	self:RefreshGridMeshForFurniture(adsorptionType, hitGameObject)

	if not self:ShouldUseSurfaceHintMesh(adsorptionType, hitGameObject) then
		if self.surfaceHintMeshGo then
			self.ClearSurfaceHintMesh(self)
		end

		self.ResetCurrentSurfaceState(self)

		return
	end

	local surfaceChanged = self.HasSurfaceChanged(self, surfaceCollider, surfaceBounds, adsorptionType, hitNormal)

	if surfaceChanged then
		self.ClearSurfaceHintMesh(self)
		self.GenerateSurfaceHintMesh(self, surfaceBounds, adsorptionType, hitNormal)
		self.UpdateCurrentSurfaceState(self, surfaceCollider, surfaceBounds, adsorptionType, hitNormal)
	end
end

M.HasSurfaceChanged = function(self, newCollider, newBounds, newAdsorptionType, newNormal)
	local surfaceHintState = {
		currentSurfaceCollider = self.currentSurfaceCollider,
		currentSurfaceBounds = self.currentSurfaceBounds,
		currentSurfaceAdsorptionType = self.currentSurfaceAdsorptionType,
		currentSurfaceNormal = self.currentSurfaceNormal
	}

	return gFurnitureMeshUtils:HasSurfaceChanged(newCollider, newBounds, newAdsorptionType, newNormal, surfaceHintState)
end

M.UpdateCurrentSurfaceState = function(self, collider, bounds, adsorptionType, normal)
	local surfaceHintState = {
		currentSurfaceCollider = self.currentSurfaceCollider,
		currentSurfaceBounds = self.currentSurfaceBounds,
		currentSurfaceAdsorptionType = self.currentSurfaceAdsorptionType,
		currentSurfaceNormal = self.currentSurfaceNormal
	}

	gFurnitureMeshUtils:UpdateCurrentSurfaceState(collider, bounds, adsorptionType, normal, surfaceHintState)

	self.currentSurfaceCollider = surfaceHintState.currentSurfaceCollider
	self.currentSurfaceBounds = surfaceHintState.currentSurfaceBounds
	self.currentSurfaceAdsorptionType = surfaceHintState.currentSurfaceAdsorptionType
	self.currentSurfaceNormal = surfaceHintState.currentSurfaceNormal
end

M.ResetCurrentSurfaceState = function(self)
	local surfaceHintState = {
		currentSurfaceCollider = self.currentSurfaceCollider,
		currentSurfaceBounds = self.currentSurfaceBounds,
		currentSurfaceAdsorptionType = self.currentSurfaceAdsorptionType,
		currentSurfaceNormal = self.currentSurfaceNormal
	}

	gFurnitureMeshUtils:ResetCurrentSurfaceState(surfaceHintState)

	self.currentSurfaceCollider = surfaceHintState.currentSurfaceCollider
	self.currentSurfaceBounds = surfaceHintState.currentSurfaceBounds
	self.currentSurfaceAdsorptionType = surfaceHintState.currentSurfaceAdsorptionType
	self.currentSurfaceNormal = surfaceHintState.currentSurfaceNormal
end

M.CheckFurnitureCollision = function(self)
	local collisionTypeEnum = HouseFurnitureConfig.CollisionTypeType
	local followingCollisionType = self.followingFurnitureConfig.CollisionType

	if followingCollisionType ~= collisionTypeEnum.IgnoreAllCollision then
		return false
	end

	local freeFactor = 0.9
	local layerMask = nil

	if followingCollisionType ~= collisionTypeEnum.WallCollision then
		freeFactor = 1
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants.Wall
		})
	else
		layerMask = gHouseCollisionUtils:GetDefaultOverlapLayerMask()
	end

	local boundsBoxList = self.followingFurnitureComponent.boundsBoxList
	local useMultiBox = boundsBoxList and boundsBoxList.Length >= 0
	local checkBoxes = {}

	if useMultiBox then
		for i = 0, boundsBoxList.Length - 1 do
			local box = boundsBoxList[i]
			local c = self.followingFurniture.transform:TransformPoint(box.center)
			local s = box.size
			local he = Vector3.New(s.x * 0.5 * freeFactor, s.y * 0.5 * freeFactor, s.z * 0.5 * freeFactor)
			checkBoxes[#checkBoxes + 1] = {
				center = c,
				halfExtents = he
			}
		end
	else
		local center = self.followingFurniture.transform:TransformPoint(self.followingFurnitureComponent.boundsBox.center)
		local size = self.followingFurnitureComponent.boundsBox.size
		local halfExtents = Vector3.New(size.x * 0.5 * freeFactor, size.y * 0.5 * freeFactor, size.z * 0.5 * freeFactor)
		checkBoxes[1] = {
			center = center,
			halfExtents = halfExtents
		}
	end

	for uid, go in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
		if not gCS.LuaUtils.IsNull(go) then
			local furnitureId = self.TryGetFurnitureIdFromGo(self, go, uid)

			if furnitureId then
				local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

				if cfg and cfg.CollisionType ~= collisionTypeEnum.Bound then
					CSFurnitureManager.EnableAllBoundsBox(go, true)
				end
			else
				print_debug(string.format("[CheckFurnitureCollision] 无法从碰撞对象中获取家具ID，跳过碰撞检测，碰撞对象: %s", go.name))
			end
		end
	end

	local curHouseRoot = gHouseSceneLayout:GetHouseRootGo(gHouseManager:GetCurHouseId())

	if curHouseRoot and not gCS.LuaUtils.IsNull(curHouseRoot) then
		CSFurnitureManager.EnableAllBoundsBox(curHouseRoot, true)
	end

	local ignoreSet = {
		[self.followingFurniture] = true
	}

	if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) then
		ignoreSet[self.baseMeshGo] = true
	end

	local checkOpts = {
		["\\xbe\\xa2 \\x9bI?\\xf2?"] = true,
		layerMask = layerMask,
		ignoreSet = ignoreSet,
		ignoreChildOf = self.followingFurniture,
		isBlockingHit = function (targetGo)
			if followingCollisionType ~= collisionTypeEnum.WallCollision then
				local hitFurnitureRoot, hitFurnitureId = self:FindFurnitureRootFromHitObject(targetGo)
				local isCollidingWithFurniture = hitFurnitureRoot == nil and hitFurnitureId == nil

				if isCollidingWithFurniture then
					return false
				end

				print_debug(string.format("[CheckFurnitureCollision] 家具与非家具物体发生碰撞，碰撞对象: %s", targetGo.name))

				return true
			end

			local hitFurnitureRoot = self:FindFurnitureRootFromHitObject(targetGo)

			print_debug(string.format("[CheckFurnitureCollision] 家具发生碰撞, 对象名称: %s", hitFurnitureRoot and hitFurnitureRoot.name or targetGo.name))

			return true
		end
	}
	local isBlocked = false
	local errMsg = nil

	for _, boxData in ipairs(checkBoxes) do
		local blocked, _, err = gHouseCollisionUtils:CheckBoxBlocked(boxData.center, boxData.halfExtents, self.followingFurniture.transform.rotation, checkOpts)

		if err then
			errMsg = err

			break
		end

		if blocked then
			isBlocked = true

			break
		end
	end

	CSFurnitureManager.EnableAllBoundsBox(self.GetFurnitureRoot(self), false)
	self.RestoreFenestrationBoundsBox(self)

	if errMsg then
		print_error(string.format("FurnitureManager: 碰撞检测失败: %s", tostring(errMsg)))

		return false
	end

	if isBlocked then
		return true
	end

	return false
end

M.CreateMaterialInstances = function(self, furnitureGo)
	local materialState = {
		furnitureMaterials = self.furnitureMaterials,
		baseMeshMaterials = self.baseMeshMaterials,
		gadgetMeshMaterials = self.gadgetMeshMaterials,
		defaultColors = self.defaultColors
	}

	gFurnitureMaterialUtils:CreateMaterialInstances(furnitureGo, self.baseMeshGo, self.gadgetMeshGo, materialState)

	self.furnitureMaterials = materialState.furnitureMaterials
	self.baseMeshMaterials = materialState.baseMeshMaterials
	self.gadgetMeshMaterials = materialState.gadgetMeshMaterials
	self.defaultColors = materialState.defaultColors
end

M.SetFurnitureColor = function(self, furnitureGo, isColliding, forceRed)
	local newCanPlace = gFurnitureMaterialUtils:SetFurnitureColor(furnitureGo, isColliding, forceRed, self.baseMeshGo, self.gadgetMeshGo, self.lastCanPlaceState)

	if newCanPlace == nil then
		self.lastCanPlaceState = newCanPlace

		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED, {
			canPlace = newCanPlace
		})
	end
end

M._RefreshHasValidSurface = function(self, hasValid)
	if not hasValid or self.hasValidSurface then
		return
	end

	self.hasValidSurface = true

	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		self.followingFurniture:SetActive(true)
		gFurnitureShowCaseUtils:DrivePreviewUnitFollow(self.followingFurniture)
	end
end

M.RefreshFollowingFurnitureCanPlaceState = function(self, useInterval)
	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	local currentPosition = self.followingFurniture.transform.position
	local isPositionValid = gHouseManager:IsPositionInBuildBound(currentPosition)
	local boundaryStateChanged = isPositionValid == self.lastBoundaryState
	self.lastBoundaryState = isPositionValid

	if not isPositionValid then
		self.lastCollisionState = true

		self.SetFurnitureColor(self, self.followingFurniture, true, true)

		return
	end

	local shouldCheckCollision = true

	if useInterval then
		local currentTime = gLogicTime.time
		shouldCheckCollision = boundaryStateChanged or self.collisionCheckInterval > currentTime - self.lastCollisionCheckTime

		if shouldCheckCollision then
			self.lastCollisionCheckTime = currentTime
		end
	end

	if not shouldCheckCollision then
		return
	end

	local isColliding = self.CheckFurnitureCollision(self)

	if boundaryStateChanged or isColliding == self.lastCollisionState or not useInterval then
		self.lastCollisionState = isColliding

		self.SetFurnitureColor(self, self.followingFurniture, isColliding, false)
	end
end

M.ShouldCheckCarrySpace = function(self)
	return gFurnitureRaycastUtils:ShouldCheckCarrySpace(self.followingFurnitureConfig)
end

M.CheckCarrySpaceAvailable = function(self, centerPosition, hitGameObject)
	return gFurnitureRaycastUtils:CheckCarrySpaceAvailable(centerPosition, hitGameObject, self.followingFurniture, self.followingFurnitureComponent)
end

M.GetValidTagsForLayer = function(self, hitLayer, adsorptionType)
	local isAdsorptOnItem = self.followingFurnitureConfig and self.followingFurnitureConfig.IsAdsorptOnItem

	return gFurnitureRaycastUtils:GetValidTagsForLayer(hitLayer, adsorptionType, isAdsorptOnItem)
end

M.GetMultiLayerRaycastPosition = function(self, layerMask, initAtScreenCenter)
	slot3 = gFurnitureRaycastUtils

	return slot3:GetMultiLayerRaycastPosition(layerMask, initAtScreenCenter, self.followingFurnitureConfig, self.followingFurniture, self.followingFurnitureComponent, function (hitGameObject)
		self.nowHitGameObject = hitGameObject
	end)
end

M.CopyFurniture = function(self, targetScreenPos)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureId then
		return false
	end

	local currentOperation = gFurnitureOperationManager.currentOperation

	if currentOperation and currentOperation.operationType ~= gFurnitureOperationManager.OperationType.SPAWN then
		return false
	end

	local furnitureId = self.followingFurnitureId

	if not gHouseManager:IsFurnitureUsable(furnitureId) then
		gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")

		return false
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return false
	end

	local ray = mainCamera.ScreenPointToRay(mainCamera, targetScreenPos)
	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if not furnitureCfg then
		return false
	end

	local layerMask = self.GetFurnitureLayerMask(self, furnitureCfg.AdsorptionTypeFinal)
	local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
	local raycastOrigin = ray.origin
	local raycastDirection = ray.direction
	local raycastDistance = 20
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)

	if hitCount > 0 or not CSFurnitureManager.SortedRayCastList or not CSFurnitureManager.SortedRayCastList[0] then
		return false
	end

	local hitInfo = CSFurnitureManager.SortedRayCastList[0]

	if not hitInfo or not hitInfo.collider then
		return false
	end

	local hitPoint = hitInfo.point
	local hitLayer = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)
	local hitNormal = hitInfo.normal
	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal

	self:SpawnFurniture(furnitureId, false)

	if self.followingFurniture then
		self.followingFurniture.transform.position = hitPoint
	end

	return true
end

M.ReplaceFurniture = function(self, newFurnitureId)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		return false
	end

	local currentOperation = gFurnitureOperationManager.currentOperation

	if not self.currentOperationUniqueId or not currentOperation or currentOperation.operationType == gFurnitureOperationManager.OperationType.EDIT then
		return false
	end

	local originalUID = self.currentOperationUniqueId
	local originalFurnitureId = currentOperation.furnitureId

	if originalFurnitureId ~= newFurnitureId then
		return false
	end

	if not gHouseManager:IsFurnitureUsable(newFurnitureId) then
		gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")

		return false
	end

	local carryUid2GoInfoDict = {}

	if self.carryUid2AdsUidListDict[originalUID] then
		for _, adsUid in ipairs(self.carryUid2AdsUidListDict[originalUID]) do
			local go = gFurnitureUIDManager.uid2FurnitureGoDict[adsUid]

			if go and not gCS.LuaUtils.IsNull(go) then
				carryUid2GoInfoDict[adsUid] = {
					position = go.transform.position,
					rotation = go.transform.rotation,
					furnitureId = self.TryGetFurnitureIdFromGo(self, go, adsUid),
					uid = adsUid
				}
			end
		end
	end

	local currentPosition = self.followingFurniture.transform.position
	local currentRotation = self.followingFurniture.transform.rotation

	gFurnitureOperationManager:CancelCurrentOperation()

	local originalGo = self:FindFurnitureByUniqueId(originalUID)

	if not originalGo or gCS.LuaUtils.IsNull(originalGo) then
		print_warn(string.format("FurnitureManager: 无法找到原家具[%s]，替换操作失败", tostring(originalUID)))

		return false
	end

	local originalGadgetInstanceId = nil
	local originalFurnitureComp = originalGo.GetComponent(originalGo, typeof(CSFurnitureMono))

	if originalFurnitureComp and originalFurnitureComp.isGadget then
		local originalSlotComp = originalGo.GetComponentInChildren(originalGo, typeof(SlotComponentBase))

		if originalSlotComp and originalSlotComp.LuaEntityId then
			originalGadgetInstanceId = originalSlotComp.LuaEntityId
		end
	end

	local carrySurfaceUID = self.GetAdsorptionSurfaceGoUid(self, originalUID)
	local adsorbedUIDs = {}

	if self.carryUid2AdsUidListDict[originalUID] then
		for _, uid in ipairs(self.carryUid2AdsUidListDict[originalUID]) do
			table.insert(adsorbedUIDs, uid)
		end
	end

	gHouseManager:RecordRemovedFurniture(originalUID)

	for _, adsorbedUID in ipairs(adsorbedUIDs) do
		gHouseManager:RecordRemovedFurniture(adsorbedUID)
	end

	self.DestroyCarryAndAdsorbedDirect(self, originalUID, adsorbedUIDs)
	self.RemoveAdsorptionRelation(self, originalUID)

	if self.isEditingExisting then
		gFurnitureMaterialUtils:RestoreMaterialColors(self.followingFurniture, self.baseMeshGo, self.gadgetMeshGo, self.defaultColors)
		self:SetFurnitureInteractionEnabled(self.followingFurniture, true)
		self:SetAdsorbedChildrenInteraction(originalUID, true)

		self.isEditingExisting = false
	end

	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		GameObject.Destroy(self.followingFurniture)
	end

	self.ClearFollowingState(self)

	local newUID = self.GenerateUniqueId(self)
	local newFurnitureCfg = HouseFurnitureConfig.GetConfig(newFurnitureId)

	if not newFurnitureCfg then
		return false
	end

	slot15 = gResourceManager

	slot15:LoadAssetWithCallBack(newFurnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			furnitureGo.transform.position = currentPosition
			furnitureGo.transform.rotation = currentRotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(newFurnitureId, newFurnitureCfg.Name, newUID, true)

			self:SetHouseFurnitureFields(furnitureGo, newUID, newFurnitureId)

			if originalGadgetInstanceId then
				gFurnitureUtils:TrySetGadgetInstanceId(furnitureGo, originalGadgetInstanceId)
			end

			local root, carryFurnitureUID = self:UpdateFurnitureAdsorptionRelation(furnitureGo, newUID, carrySurfaceUID, true)

			furnitureGo.transform:SetParent(root.transform, true)

			local furnitureComponent = furnitureGo:GetComponent(typeof(CSFurnitureMono))

			if furnitureComponent and furnitureComponent.meshObject and not gCS.LuaUtils.IsNull(furnitureComponent.meshObject) then
				furnitureComponent.meshObject.transform.localPosition = Vector3.zero
			end

			local rotationEuler = currentRotation.eulerAngles

			gHouseManager:RecordAddedFurniture(newUID, newFurnitureId, currentPosition, rotationEuler, carryFurnitureUID)
			self:StartEditingPlacedFurniture(furnitureGo, newFurnitureId)
		else
			print_error(string.format("FurnitureManager: 替换家具失败，加载资源失败 [%s]", newFurnitureCfg.ModelName))
		end
	end)

	return true
end

M.CancelFurniturePreview = function(self)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法取消")

		return false
	end

	if self.isEditingExisting then
		gFurnitureMaterialUtils:RestoreMaterialColors(self.followingFurniture, self.baseMeshGo, self.gadgetMeshGo, self.defaultColors)
		self:SetFurnitureInteractionEnabled(self.followingFurniture, true)
		self:SetAdsorbedChildrenInteraction(self.currentOperationUniqueId, true)
		self:SetMovingFurnitureLightDynamicMode(self.followingFurniture, false, self.followingFurnitureComponent)
	elseif self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		GameObject.Destroy(self.followingFurniture)

		self.followingFurniture = nil
	end

	gFurnitureOperationManager:CancelCurrentOperation()
	self:ClearFollowingState()
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)

	return true
end

M.FinalizeFurniture = function(self)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法固定")

		return false
	end

	local finalPosition = self.followingFurniture.transform.position
	local finalRotation = self.followingFurniture.transform.rotation
	self.isFollowing = false

	self:ClearBaseMesh()
	self:ClearSurfaceHintMesh()
	gFurnitureMaterialUtils:RestoreMaterialColors(self.followingFurniture, self.baseMeshGo, self.gadgetMeshGo, self.defaultColors)

	if self.isEditingExisting then
		local uid = self.currentOperationUniqueId
		local furnitureCfg = self.followingFurnitureConfig

		self:SetFurnitureInteractionEnabled(self.followingFurniture, true)
		self:SetAdsorbedChildrenInteraction(uid, true)

		local wallEdgeKey = self:_SyncWallBindingForFollowingFurniture(uid, furnitureCfg and furnitureCfg.Id)
		local detectedCarryGameObject = self:DetectCarrySurfaceAtPosition(finalPosition, furnitureCfg)
		self.nowHitGameObject = detectedCarryGameObject
		local root, carryFurnitureUID = self:UpdateFurnitureAdsorptionRelation(self.followingFurniture, uid, nil, true)

		self.followingFurniture.transform:SetParent(root.transform, true)

		if self.followingFurnitureComponent and self.followingFurnitureComponent.meshObject and not gCS.LuaUtils.IsNull(self.followingFurnitureComponent.meshObject) then
			self.followingFurnitureComponent.meshObject.transform.localPosition = Vector3.zero
		end

		local rotationEuler = finalRotation.eulerAngles

		gHouseManager:RecordChangedFurniture(uid, finalPosition, rotationEuler, carryFurnitureUID)
		gFurnitureOperationManager:EndOperation(self.followingFurniture, carryFurnitureUID, wallEdgeKey)
		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
		self:ClearFollowingState()
	else
		local uid = self.currentOperationUniqueId
		local furnitureCfg = self.followingFurnitureConfig
		local furnitureGo = self.followingFurniture
		furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureCfg.Id, furnitureCfg.Name, uid, true)

		self:SetHouseFurnitureFields(furnitureGo, uid, furnitureCfg.Id)
		self:SetFurnitureInteractionEnabled(furnitureGo, true)

		local root, carryFurnitureUID = self:UpdateFurnitureAdsorptionRelation(furnitureGo, uid, nil, true)

		furnitureGo.transform:SetParent(root.transform, true)

		local rotationEuler = finalRotation.eulerAngles

		gHouseManager:RecordAddedFurniture(uid, furnitureCfg.Id, finalPosition, rotationEuler, carryFurnitureUID)
		gHouseGadgetManager:RegisterFurnitureLuaSlotReplace(uid, furnitureGo, furnitureCfg.Id)

		local wallEdgeKey = self:_SyncWallBindingForFollowingFurniture(uid, furnitureCfg.Id)

		gFurnitureOperationManager:EndOperation(furnitureGo, carryFurnitureUID, wallEdgeKey)
		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
		self:ClearFollowingState()
	end

	return true
end

M.StorageFurniture = function(self)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法收回")

		return gFurnitureConst.StorageRes.NoFollowingFurniture
	end

	local currentOperation = gFurnitureOperationManager.currentOperation

	if not self.currentOperationUniqueId or not currentOperation or currentOperation.operationType == gFurnitureOperationManager.OperationType.EDIT then
		gFurnitureManager:CancelFurniturePreview()

		return gFurnitureConst.StorageRes.NotInEdit
	end

	local editOperation = currentOperation
	local originalUID = self.currentOperationUniqueId
	local carryUid2GoInfoDict = self:CollectAdsorbedFurnitureSnapshot(originalUID)

	gFurnitureMaterialUtils:RestoreMaterialColors(self.followingFurniture, self.baseMeshGo, self.gadgetMeshGo, self.defaultColors)
	self:SetFurnitureInteractionEnabled(self.followingFurniture, true)
	self:SetAdsorbedChildrenInteraction(originalUID, true)
	gFurnitureOperationManager:CancelCurrentOperation()

	local originalGo = self:FindFurnitureByUniqueId(editOperation.uniqueId)

	if not originalGo or gCS.LuaUtils.IsNull(originalGo) then
		print_warn(string.format("FurnitureManager: 无法找到原家具[%s]，收回操作失败", tostring(editOperation.uniqueId)))

		return gFurnitureConst.StorageRes.FurnitureNotFound
	end

	local success = gFurnitureOperationManager:BeginStorageOperation(editOperation.furnitureId, originalGo, editOperation.uniqueId, editOperation.beforeState.carrySurfaceUID)

	if not success then
		print_warn("FurnitureManager: 无法开始存储操作")

		return gFurnitureConst.StorageRes.OperationFailed
	end

	gFurnitureOperationManager.currentOperation.beforeState.carryUid2GoInfoDict = carryUid2GoInfoDict

	gFurnitureOperationManager:EndStorageOperation()

	local adsorbedUIDs = {}
	local adsList = self.carryUid2AdsUidListDict[originalUID]

	if adsList then
		for _, uid in ipairs(adsList) do
			table.insert(adsorbedUIDs, uid)
		end
	end

	gHouseManager:RecordRemovedFurniture(originalUID)

	for _, adsorbedUID in ipairs(adsorbedUIDs) do
		gHouseManager:RecordRemovedFurniture(adsorbedUID)
	end

	self:DestroyCarryAndAdsorbedDirect(originalUID, adsorbedUIDs)
	self:ClearFollowingState()
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_EXIT_EDIT)

	return gFurnitureConst.StorageRes.Success
end

M.DetectCarrySurfaceAtPosition = function(self, position, furnitureCfg)
	local originalHitGameObject = self.nowHitGameObject
	slot4 = gFurnitureRaycastUtils
	local detectedCarryGameObject = slot4:DetectCarrySurfaceAtPosition(position, furnitureCfg, function (adsorptionTypes, isAdsorptOnItem)
		return gFurnitureRaycastUtils:GetFurnitureLayerMask(adsorptionTypes, isAdsorptOnItem)
	end)
	self.nowHitGameObject = originalHitGameObject

	return detectedCarryGameObject
end

M.UpdateFurnitureAdsorptionRelation = function(self, furnitureGo, uid, carrySurfaceUID, useDetected, houseId)
	local root = gHouseSceneLayout:EnsureHouseNamespaceGo(houseId or gHouseManager:GetCurHouseId())
	local actualCarryUID = carrySurfaceUID

	if not actualCarryUID and useDetected and self.nowHitGameObject then
		local hitTag, hitExtraTag = gCS.LuaUtils.GetGameObjectTags(self.nowHitGameObject, "")

		if gFurnitureUtils:IsCarryFurnitureTag(hitTag, hitExtraTag) then
			actualCarryUID = gFurnitureUtils:GetCarryFurnitureUID(self.nowHitGameObject)
		end
	end

	if actualCarryUID then
		self.RemoveAdsorptionRelation(self, uid)
		self.AddAdsorptionRelation(self, actualCarryUID, uid)

		local carryFurnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[actualCarryUID]

		if carryFurnitureGo and not gCS.LuaUtils.IsNull(carryFurnitureGo) then
			root = carryFurnitureGo
		end
	else
		self.RemoveAdsorptionRelation(self, uid)
	end

	return root, actualCarryUID
end

M._ReparentOrphanedChildrenTo = function(self, parentUid, parentGo)
	if not parentUid or not parentGo or gCS.LuaUtils.IsNull(parentGo) then
		return
	end

	local childList = self.carryUid2AdsUidListDict[parentUid]

	if not childList or #childList ~= 0 then
		return
	end

	for _, childUid in ipairs(childList) do
		local childGo = gFurnitureUIDManager.uid2FurnitureGoDict[childUid]

		if childGo and not gCS.LuaUtils.IsNull(childGo) then
			local curParent = childGo.transform.parent

			if not curParent or curParent.gameObject == parentGo then
				childGo.transform:SetParent(parentGo.transform, true)
			end
		end
	end
end

M._SyncWallBindingForFollowingFurniture = function(self, uid, furnitureId)
	if not uid then
		return nil
	end

	if furnitureId and gWallEditUtils:IsFenestrationFurnitureId(furnitureId) then
		return nil
	end

	local edgeKey = gWallFurnitureBindingManager:DetectEdgeKeyForFollowingFurniture()

	if edgeKey then
		gWallFurnitureBindingManager:Bind(uid, edgeKey)
	else
		gWallFurnitureBindingManager:Unbind(uid)
	end

	return edgeKey
end

M.ClearFollowingFurniture = function(self)
	if self.isEditingExisting then
		self.SetFurnitureInteractionEnabled(self, self.followingFurniture, true)
		self.SetAdsorbedChildrenInteraction(self, self.currentOperationUniqueId, true)
	elseif self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		GameObject.Destroy(self.followingFurniture)

		self.followingFurniture = nil
	end

	self.ClearFollowingState(self)
end

M.SetMovingFurnitureLightDynamicMode = function(self, furnitureGo, isMoving, houseFurnitureComp)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	houseFurnitureComp = houseFurnitureComp or furnitureGo:GetComponent(typeof(CSFurnitureMono))

	if not houseFurnitureComp or not houseFurnitureComp.isLight then
		return
	end

	CSFurnitureManager.SetMoveLightDynamicMode(furnitureGo, isMoving)
end

M.RefreshMovingFurnitureLightDynamicMode = function(self, isMoving)
	self.SetMovingFurnitureLightDynamicMode(self, self.followingFurniture, isMoving, self.followingFurnitureComponent)
end

M.ClearFollowingState = function(self)
	self.RefreshMovingFurnitureLightDynamicMode(self, false)

	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		gFurnitureMaterialUtils:RestoreMaterialColors(self.followingFurniture, self.baseMeshGo, self.gadgetMeshGo, self.defaultColors)
	end

	self:ClearBaseMesh()
	self:ClearSurfaceHintMesh()
	self:ClearHoveredFurniture()

	self.furnitureMaterials = {}
	self.baseMeshMaterials = {}
	self.defaultColors = {}
	self.lastCollisionState = nil
	self.lastCollisionCheckTime = 0
	self.lastBoundaryState = true
	self.followingFurniture = nil
	self.followingFurnitureComponent = nil
	self.isFollowing = false
	self.followingFurnitureId = nil
	self.followingFurnitureConfig = nil
	self.nowHitLayer = nil
	self.nowHitNormal = nil
	self.nowHitGameObject = nil
	self.gridModePlaneNormal = nil
	self.gridModePlanePoint = nil
	self.nowSurfaceBounds = nil
	self.lastUseGridMeshForFurniture = false
	self.followingFurnitureManualRotation = 0
	self.followingFurnitureRotationAngle = 0
	self.hasValidSurface = false

	self:DisableFenestrationBoundsBox()
	gWallFurniturePlacementUtils:ResetFenSkipState(self.fenSkipState)

	self.isRotatingDrag = false
	self.rotationDragStartAngle = 0
	self.rotationDragStartScreenPos = nil
	self.isEditingExisting = false
	self._savedLayers = nil
	self.isLongPressing = false
	self.canFollow = false
	self.dragStartScreenPos = nil
	self.currentOperationUniqueId = nil

	if gWallEditManager and gWallEditManager.RefreshGroundHintMesh then
		gWallEditManager:RefreshGroundHintMesh()
	end
end

M.SetFurnitureInteractionEnabled = function(self, furnitureGo, enabled)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	if enabled then
		self.RestoreGameObjectLayers(self, furnitureGo)
	else
		self.SaveAndSetGameObjectLayer(self, furnitureGo, LX6.Constants.LayerConstants.IgnoreRaycast)
	end

	CSFurnitureManager.SetCollidersEnabled(furnitureGo, enabled)
	CSFurnitureManager.SetRigidbodiesKinematic(furnitureGo, not enabled)
end

M.SaveAndSetGameObjectLayer = function(self, gameObject, layer)
	if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
		return
	end

	if not self._savedLayers then
		self._savedLayers = {}
	end

	local instanceId = gameObject.GetInstanceID(gameObject)
	self._savedLayers[instanceId] = gameObject.layer
	gameObject.layer = layer
	local transform = gameObject.transform

	for i = 0, transform.childCount - 1 do
		local child = transform.GetChild(transform, i)

		if child and child.gameObject then
			self.SaveAndSetGameObjectLayer(self, child.gameObject, layer)
		end
	end
end

M.RestoreGameObjectLayers = function(self, gameObject)
	if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
		return
	end

	if self._savedLayers then
		local instanceId = gameObject.GetInstanceID(gameObject)

		if self._savedLayers[instanceId] then
			gameObject.layer = self._savedLayers[instanceId]
			self._savedLayers[instanceId] = nil
		end
	end

	local transform = gameObject.transform

	for i = 0, transform.childCount - 1 do
		local child = transform.GetChild(transform, i)

		if child and child.gameObject then
			self.RestoreGameObjectLayers(self, child.gameObject)
		end
	end
end

M.SetGameObjectLayer = function(self, gameObject, layer)
	if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
		return
	end

	gameObject.layer = layer
	local transform = gameObject.transform

	for i = 0, transform.childCount - 1 do
		local child = transform.GetChild(transform, i)

		if child and child.gameObject then
			self.SetGameObjectLayer(self, child.gameObject, layer)
		end
	end
end

M.RotateFollowingFurniture45 = function(self)
	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		print_warn("FurnitureManager: 当前没有预览家具，无法旋转")

		return
	end

	self.followingFurnitureRotationAngle = self.followingFurnitureRotationAngle + 45

	if self.followingFurnitureRotationAngle > 360 then
		self.followingFurnitureRotationAngle = self.followingFurnitureRotationAngle - 360
	end

	self.followingFurnitureManualRotation = self.followingFurnitureRotationAngle

	if self.nowHitLayer and self.nowHitNormal then
		local currentPosition = self.followingFurniture.transform.position
		local baseRotation = self.GetBaseRotationForManualRotation(self)
		local adjustedPosition, adjustedRotation = self.AdjustFurniturePosition(self, currentPosition, baseRotation)
		local firstChild, worldRotation = self.GetRotationAxisMeshFirstChildRotation(self)
		self.followingFurniture.transform.rotation = adjustedRotation

		if firstChild then
			firstChild.rotation = worldRotation
		end

		self.RefreshFollowingFurnitureCanPlaceState(self, false)
	else
		print_warn("FurnitureManager: 缺少命中层级或法线信息，无法进行旋转更新")
	end
end

M.CheckMouseHitPreviewFurniture = function(self)
	return gFurnitureRaycastUtils:CheckMouseHitPreviewFurniture(self.followingFurniture, self.baseMeshGo)
end

M.CheckMouseHitRotationAxis = function(self)
	if not self.rotationAxisMeshGo or gCS.LuaUtils.IsNull(self.rotationAxisMeshGo) then
		return false
	end

	return gFurnitureRaycastUtils:CheckMouseHitRotationAxis(self.rotationAxisMeshGo)
end

M.GetRotationAxisMeshFirstChildRotation = function(self)
	if not self.rotationAxisMeshGo or gCS.LuaUtils.IsNull(self.rotationAxisMeshGo) then
		return nil, 
	end

	local childCount = self.rotationAxisMeshGo.transform.childCount

	if childCount <= 0 then
		local firstChild = self.rotationAxisMeshGo.transform:GetChild(0)

		if firstChild then
			return firstChild, firstChild.rotation
		end
	end

	return nil, 
end

M.BeginRotationDrag = function(self)
	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	local currentPosition = self.followingFurniture.transform.position
	local baseRotation = self.GetBaseRotationForManualRotation(self)
	local adjustedPosition, adjustedRotation = self.AdjustFurniturePosition(self, currentPosition, baseRotation)
	local firstChild, worldRotation = self.GetRotationAxisMeshFirstChildRotation(self)
	self.followingFurniture.transform.rotation = adjustedRotation

	if firstChild then
		firstChild.rotation = worldRotation
	end

	self.isRotatingDrag = true
	self.rotationDragStartAngle = self.followingFurnitureRotationAngle
	local touchPos = SGUI.Utils.GetInputCenterPosition()

	if touchPos then
		self.rotationDragStartScreenPos = Vector3.New(touchPos.x, touchPos.y, 0)
	end
end

M.EndRotationDrag = function(self)
	self.isRotatingDrag = false
	self.rotationDragStartAngle = 0
	self.rotationDragStartScreenPos = nil
end

M.UpdateFurnitureRotationByDrag = function(self, deltaScreenPos)
	if not self.isRotatingDrag or not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	if not self.nowHitLayer or not self.nowHitNormal then
		return
	end

	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
	local rotationSensitivity = 0.5
	local rotationDelta = deltaScreenPos.x * rotationSensitivity
	self.followingFurnitureRotationAngle = self.followingFurnitureRotationAngle + rotationDelta

	while self.followingFurnitureRotationAngle >= 0 do
		self.followingFurnitureRotationAngle = self.followingFurnitureRotationAngle + 360
	end

	while self.followingFurnitureRotationAngle > 360 do
		self.followingFurnitureRotationAngle = self.followingFurnitureRotationAngle - 360
	end

	self.followingFurnitureManualRotation = self.followingFurnitureRotationAngle
	local currentPosition = self.followingFurniture.transform.position
	local baseRotation = self.GetBaseRotationForManualRotation(self)
	local adjustedPosition, adjustedRotation = self.AdjustFurniturePosition(self, currentPosition, baseRotation)
	local firstChild, worldRotation = self.GetRotationAxisMeshFirstChildRotation(self)
	self.followingFurniture.transform.rotation = adjustedRotation

	if firstChild then
		firstChild.rotation = worldRotation
	end

	self:RefreshFollowingFurnitureCanPlaceState(true)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_POSITION_CHANGED, {
		position = adjustedPosition,
		rotation = adjustedRotation
	})
end

M.SetEditPlacedFurnitureMode = function(self, enabled)
	if self.canEditPlacedFurniture ~= enabled then
		return
	end

	self.canEditPlacedFurniture = enabled

	if enabled then
		gLuaClient:RegisterDynamicUpdate("FurnitureManager", self)
	else
		gLuaClient:UnregisterDynamicUpdate("FurnitureManager")
		self:ClearHoveredFurniture()
		self:ClearSurfaceHintMesh()
	end
end

M.OnLongPressFullScreenBtn = function(self, isPress)
	if isPress then
		return
	end

	self.canFollow = false
	self.isLongPressing = false
	self.dragStartScreenPos = nil

	if self.isRotatingDrag then
		self.EndRotationDrag(self)
	end

	if self.isFollowing and not self.hasValidSurface then
		self:CancelFurniturePreview()
		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_EXIT_EDIT)
	end
end

M.TryGetFurnitureIdFromGo = function(self, go, uid)
	if uid then
		local state = gFurnitureUIDManager:GetFurnitureState(uid)

		if state and state.furnitureId then
			return state.furnitureId
		end
	end

	local furnitureComp = go.GetComponent(go, typeof(CSFurnitureMono))

	if furnitureComp and furnitureComp.furnitureId then
		return furnitureComp.furnitureId
	end

	return nil
end

M.FindFurnitureRootFromHitObject = function(self, hitGo)
	slot2 = gFurnitureRaycastUtils

	return slot2:FindFurnitureRootFromHitObject(hitGo, function (go)
		return self:TryGetFurnitureIdFromGo(go)
	end)
end

M.SmartRaycastForFurniture = function(self, furnitureCfg, position, originalRotation)
	slot4 = gFurnitureRaycastUtils

	return slot4:SmartRaycastForFurniture(furnitureCfg, position, originalRotation, function (adsorptionTypes, isAdsorptOnItem)
		return gFurnitureRaycastUtils:GetFurnitureLayerMask(adsorptionTypes, isAdsorptOnItem)
	end)
end

M.SmartRaycastForPlacedFurniture = function(self, furnitureCfg, position, rotation)
	local hitLayer, hitNormal, surfaceBounds = self:SmartRaycastForFurniture(furnitureCfg, position, rotation)
	local hitGo = nil
	local hitInfo = CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] or nil

	if hitInfo and hitInfo.collider then
		local _, _, go = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)
		hitGo = go
	end

	return hitLayer, hitNormal, hitGo, surfaceBounds
end

M.StartEditingPlacedFurniture = function(self, placedFurnitureGo, furnitureId)
	if not placedFurnitureGo or gCS.LuaUtils.IsNull(placedFurnitureGo) then
		print_error("FurnitureManager: 要编辑的家具对象无效")

		return
	end

	self.ClearHoveredFurniture(self)

	local placedFurnitureComp = placedFurnitureGo.GetComponent(placedFurnitureGo, typeof(CSFurnitureMono))
	self.currentOperationUniqueId = placedFurnitureComp.uid

	if not self.currentOperationUniqueId then
		print_error("FurnitureManager: 无法提取唯一ID: " .. placedFurnitureGo.name)

		return
	end

	local state = gFurnitureUIDManager:GetFurnitureState(self.currentOperationUniqueId)
	local currentUID = self.currentOperationUniqueId

	if state then
		currentUID = gFurnitureUIDManager:GetCurrentUID(state)
	end

	local carrySurfaceUID = self:GetAdsorptionSurfaceGoUid(currentUID)
	local wallEdgeKey = gWallFurnitureBindingManager:GetWallEdgeKey(self.currentOperationUniqueId)
	local success = gFurnitureOperationManager:BeginEditOperation(furnitureId, placedFurnitureGo, self.currentOperationUniqueId, carrySurfaceUID, wallEdgeKey)

	if not success then
		print_error("FurnitureManager: 无法开始编辑操作记录")

		return
	end

	local originalPosition = placedFurnitureGo.transform.position
	local originalRotation = placedFurnitureGo.transform.rotation
	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

	self:EnableFenestrationBoundsBoxIfWall(furnitureCfg)

	self.followingFurnitureId = furnitureId
	self.followingFurnitureConfig = furnitureCfg
	self.isFollowing = true
	self.isLongPressing = false
	self.canFollow = false
	self.hasValidSurface = true
	local hitLayer, hitNormal, hitGo, surfaceBounds = self:SmartRaycastForPlacedFurniture(furnitureCfg, originalPosition, originalRotation)
	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal
	self.nowHitGameObject = hitGo
	local adsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor

	self:BuildGridModePlane(originalPosition, adsorptionType, hitNormal)

	if surfaceBounds then
		self.nowSurfaceBounds = surfaceBounds
	end

	self.RefreshGridMeshForFurniture(self, adsorptionType, self.nowHitGameObject)

	self.followingFurnitureManualRotation = self.CalculateCorrectManualRotation(self, originalPosition, originalRotation, furnitureCfg)
	self.followingFurnitureRotationAngle = self.followingFurnitureManualRotation
	self.followingFurniture = placedFurnitureGo
	self.followingFurnitureComponent = placedFurnitureGo.GetComponent(placedFurnitureGo, typeof(CSFurnitureMono))
	self.isEditingExisting = true

	self.SetMovingFurnitureLightDynamicMode(self, placedFurnitureGo, true, self.followingFurnitureComponent)

	if self.followingFurnitureComponent and self.followingFurnitureComponent.isLight then
		placedFurnitureGo.SetActive(placedFurnitureGo, false)
		placedFurnitureGo.SetActive(placedFurnitureGo, true)
	end

	self:SetFurnitureInteractionEnabled(placedFurnitureGo, false)
	self:SetAdsorbedChildrenInteraction(self.currentOperationUniqueId, false)
	self:CreateMaterialInstances(placedFurnitureGo)
	self:GenerateBaseMesh(furnitureCfg, adsorptionType, hitNormal or Vector3.up)

	if furnitureCfg.RotType and furnitureCfg.RotType == LTConfig.HouseFurnitureConfig.RotTypeType.None then
		self:GenerateRotationAxisMesh(furnitureCfg, adsorptionType, hitNormal or Vector3.up)
	end

	local isColliding = self:CheckFurnitureCollision()

	self:SetFurnitureColor(self.followingFurniture, isColliding)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_POSITION_CHANGED, {
		position = originalPosition,
		rotation = originalRotation
	})

	if self.surfaceHintMeshEnabled and self.nowSurfaceBounds then
		self.GenerateSurfaceHintMesh(self, self.nowSurfaceBounds, adsorptionType, hitNormal)
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_ENTER_EDIT)
end

M.IsRealFollowing = function(self)
	return self.canFollow
end

M.SpawnFurnitureFromServerData = function(self, furnitureId, position, rotation, uid, gadgetInstanceId, carrySurfaceUID, houseId)
	local oldGo = nil

	if gFurnitureUIDManager.uid2FurnitureGoDict[uid] then
		oldGo = gFurnitureUIDManager.uid2FurnitureGoDict[uid]
	end

	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if string.is_null_or_empty(furnitureCfg.ModelName) then
		print_error("#NoCreateIssue FurnitureManager: 家具配置错误，无法生成家具" .. tostring(furnitureId))

		return
	end

	slot10 = gResourceManager

	slot10:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			furnitureGo.transform.position = position
			furnitureGo.transform.eulerAngles = rotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, uid, true)

			self:SetHouseFurnitureFields(furnitureGo, uid, furnitureId, houseId)
			gFurnitureUtils:TrySetGadgetInstanceId(furnitureGo, gadgetInstanceId)

			local root, actualCarryUID = self:UpdateFurnitureAdsorptionRelation(furnitureGo, uid, carrySurfaceUID, false, houseId)

			furnitureGo.transform:SetParent(root.transform, true)
			self:_ReparentOrphanedChildrenTo(uid, furnitureGo)
			gHouseGadgetManager:RegisterFurnitureLuaSlotReplace(uid, furnitureGo, furnitureId)

			if oldGo and not gCS.LuaUtils.IsNull(oldGo) then
				GameObject.Destroy(oldGo)
			end
		else
			print_warn(string.format("FurnitureManager: 重新生成家具失败 [%s] 路径:%s", furnitureCfg.Name or "未知", furnitureCfg.ModelName))
		end
	end)
end

M.DestroyFollowingFurniture = function(self)
	if not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		self.followingFurniture = nil
		self.followingFurnitureComponent = nil

		return
	end

	GameObject.Destroy(self.followingFurniture)

	self.followingFurniture = nil
	self.followingFurnitureComponent = nil
end

M.CollectAdsorbedFurnitureSnapshot = function(self, carryUID)
	local carryUid2GoInfoDict = {}
	local adsorbedUIDsList = {}
	local list = carryUID and self.carryUid2AdsUidListDict[carryUID]

	if not list then
		return carryUid2GoInfoDict, adsorbedUIDsList
	end

	for _, adsUid in ipairs(list) do
		local go = gFurnitureUIDManager.uid2FurnitureGoDict[adsUid]

		if go and not gCS.LuaUtils.IsNull(go) then
			carryUid2GoInfoDict[adsUid] = {
				position = go.transform.position,
				rotation = go.transform.rotation,
				furnitureId = self.TryGetFurnitureIdFromGo(self, go, adsUid),
				uid = adsUid
			}
			adsorbedUIDsList[#adsorbedUIDsList + 1] = adsUid
		end
	end

	return carryUid2GoInfoDict, adsorbedUIDsList
end

M.DestroyCarryAndAdsorbedDirect = function(self, carryUID, adsorbedUIDsList)
	if not carryUID then
		return
	end

	local carryGo = gFurnitureUIDManager.uid2FurnitureGoDict[carryUID]

	if carryGo and not gCS.LuaUtils.IsNull(carryGo) then
		GameObject.Destroy(carryGo)
		gFurnitureUIDManager:UnregisterFurnitureGo(carryUID)
	end

	if adsorbedUIDsList then
		for _, adsUid in ipairs(adsorbedUIDsList) do
			local go = gFurnitureUIDManager.uid2FurnitureGoDict[adsUid]

			if go and not gCS.LuaUtils.IsNull(go) then
				GameObject.Destroy(go)
				gFurnitureUIDManager:UnregisterFurnitureGo(adsUid)
			end
		end
	end

	self.carryUid2AdsUidListDict[carryUID] = nil
end

M.RemoveExistFurniture = function(self, uid)
	if not uid or not gFurnitureUIDManager.uid2FurnitureGoDict[uid] then
		print_warn("FurnitureManager: 无效的家具UID，无法移除家具")

		return false
	end

	local isStorageOperation = gFurnitureOperationManager.currentOperation and gFurnitureOperationManager.currentOperation.operationType ~= gFurnitureOperationManager.OperationType.STORAGE

	if not isStorageOperation then
		gHouseManager:RecordRemovedFurniture(uid)
	end

	local adsorbedUIDs = self.carryUid2AdsUidListDict[uid] or {}

	if #adsorbedUIDs <= 0 then
		for _, adsorbedUID in ipairs(adsorbedUIDs) do
			self.RemoveExistFurniture(self, adsorbedUID)
		end

		self.carryUid2AdsUidListDict[uid] = nil
	end

	self:RemoveAdsorptionRelation(uid)
	gWallFurnitureBindingManager:Unbind(uid)

	if gHouseGadgetManager.isEditMode then
		gFurnitureShowCaseUtils:ReparentUnits(uid, nil, false)
	end

	local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[uid]

	if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
		GameObject.Destroy(furnitureGo)
		gFurnitureUIDManager:UnregisterFurnitureGo(uid)
	else
		print_warn("FurnitureManager: 尝试删除的家具不存在或已被销毁，UID: " .. tostring(uid))
	end

	return true
end

M.RemoveAllFurniture = function(self)
	for uid, furnitureGo in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)
		end
	end

	gFurnitureUIDManager:ClearAllFurnitureGoMappings()
end

M.RemoveFurnituresByHouseId = function(self, houseId)
	local uidsToRemove = gFurnitureUIDManager:CollectUIDsByHouseId(houseId)

	for _, uid in ipairs(uidsToRemove) do
		self:RemoveAdsorptionRelation(uid)

		self.carryUid2AdsUidListDict[uid] = nil

		gWallFurnitureBindingManager:Unbind(uid)

		local furnitureGo = gFurnitureUIDManager.uid2FurnitureGoDict[uid]

		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)
		end

		gFurnitureUIDManager:UnregisterFurnitureGo(uid)
	end
end

M.StorageAllFurniture = function(self)
	local hasFenestrations = false

	if gWallEditManager and gWallEditManager.CollectAllFenestrationInfos then
		hasFenestrations = #gWallEditManager:CollectAllFenestrationInfos() >= 0
	end

	if not next(gFurnitureUIDManager.uid2FurnitureGoDict) and not hasFenestrations then
		return gFurnitureConst.StorageRes.Success
	end

	local startBuildIndex = gBuildOperationManager and gBuildOperationManager.currentIndex or 0

	if next(gFurnitureUIDManager.uid2FurnitureGoDict) then
		local allFurnitureStates = {}

		for uid, furnitureGo in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
			if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
				local furnitureId = self:TryGetFurnitureIdFromGo(furnitureGo, uid)
				local carrySurfaceUID = self:GetAdsorptionSurfaceGoUid(uid)
				allFurnitureStates[uid] = {
					furnitureId = furnitureId,
					position = furnitureGo.transform.position,
					rotation = furnitureGo.transform.rotation,
					carrySurfaceUID = carrySurfaceUID or 0,
					wallEdgeKey = gWallFurnitureBindingManager:GetWallEdgeKey(uid)
				}
			end
		end

		if not gFurnitureOperationManager:BeginStorageAllOperation(allFurnitureStates) then
			return gFurnitureConst.StorageRes.NotInEdit
		end

		local allFurnitureUIDs = {}

		for uid, _ in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
			table.insert(allFurnitureUIDs, uid)
		end

		local carryFurnitureUIDs = {}
		local independentFurnitureUIDs = {}

		for _, uid in ipairs(allFurnitureUIDs) do
			if self.carryUid2AdsUidListDict[uid] and #self.carryUid2AdsUidListDict[uid] <= 0 then
				table.insert(carryFurnitureUIDs, uid)
			else
				local isAdsorbed = false

				for _, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
					for _, adsorbedUID in ipairs(adsorbedList) do
						if adsorbedUID ~= uid then
							isAdsorbed = true

							break
						end
					end

					if isAdsorbed then
						break
					end
				end

				if not isAdsorbed then
					table.insert(independentFurnitureUIDs, uid)
				end
			end
		end

		for _, carryUID in ipairs(carryFurnitureUIDs) do
			if gFurnitureUIDManager.uid2FurnitureGoDict[carryUID] then
				local adsorbedUIDs = self.carryUid2AdsUidListDict[carryUID] or {}

				gHouseManager:RecordRemovedFurniture(carryUID)

				for _, adsorbedUID in ipairs(adsorbedUIDs) do
					if gFurnitureUIDManager.uid2FurnitureGoDict[adsorbedUID] then
						gHouseManager:RecordRemovedFurniture(adsorbedUID)
					end
				end

				self.RemoveExistFurniture(self, carryUID)
			end
		end

		for _, uid in ipairs(independentFurnitureUIDs) do
			if gFurnitureUIDManager.uid2FurnitureGoDict[uid] then
				gHouseManager:RecordRemovedFurniture(uid)
				self:RemoveExistFurniture(uid)
			end
		end

		self.carryUid2AdsUidListDict = {}

		for uid, furnitureGo in pairs(gFurnitureUIDManager.uid2FurnitureGoDict) do
			if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
				GameObject.Destroy(furnitureGo)
			end
		end

		gFurnitureUIDManager:ClearAllFurnitureGoMappings()
		gFurnitureOperationManager:EndStorageAllOperation()
	end

	if hasFenestrations and gWallEditManager and gWallEditManager.StorageAllFenestrationFurniture then
		gWallEditManager:StorageAllFenestrationFurniture()
	end

	local endBuildIndex = gBuildOperationManager and gBuildOperationManager.currentIndex or 0

	if gBuildOperationManager and endBuildIndex <= startBuildIndex + 1 then
		gBuildOperationManager:CollapseHistoryRangeToBatch(startBuildIndex + 1, endBuildIndex, "StorageAllFurnitureWithFenestrations")
	end

	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)

	return gFurnitureConst.StorageRes.Success
end

M.SetHouseFurnitureFields = function(self, furnitureGo, uid, furnitureId, explicitHouseId)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		print_warn("FurnitureManager: 无效的家具对象，无法设置HouseFurniture字段")

		return
	end

	local houseId = explicitHouseId or gHouseSceneLayout:FindHouseIdFromGo(furnitureGo) or gHouseManager:GetCurHouseId()

	gFurnitureUIDManager:RegisterFurnitureGo(uid, furnitureGo, houseId)

	local houseFurnitureComponent = furnitureGo:GetComponent(typeof(CSFurnitureMono))

	if houseFurnitureComponent then
		if uid and type(uid) ~= "number" then
			houseFurnitureComponent.uid = uid
		else
			print_warn(string.format("FurnitureManager: 无效的UID类型[%s]，期望number类型", type(uid)))
		end

		houseFurnitureComponent.furnitureId = furnitureId
	else
		print_warn(string.format("FurnitureManager: 家具对象[%s]缺少HouseFurniture组件，无法设置字段", furnitureGo.name))
	end
end

M.AddAdsorptionRelation = function(self, carryUID, adsorbedUID)
	if not carryUID or not adsorbedUID then
		return
	end

	if not self.carryUid2AdsUidListDict[carryUID] then
		self.carryUid2AdsUidListDict[carryUID] = {}
	end

	for _, uid in ipairs(self.carryUid2AdsUidListDict[carryUID]) do
		if uid ~= adsorbedUID then
			return
		end
	end

	table.insert(self.carryUid2AdsUidListDict[carryUID], adsorbedUID)
end

M.ReplaceUIDInAdsorptionRelation = function(self, oldUID, newUID)
	if not oldUID or not newUID or oldUID ~= newUID then
		return
	end

	if self.carryUid2AdsUidListDict[oldUID] then
		if not self.carryUid2AdsUidListDict[newUID] then
			self.carryUid2AdsUidListDict[newUID] = self.carryUid2AdsUidListDict[oldUID]
		else
			for _, uid in ipairs(self.carryUid2AdsUidListDict[oldUID]) do
				local found = false

				for _, existingUid in ipairs(self.carryUid2AdsUidListDict[newUID]) do
					if existingUid ~= uid then
						found = true

						break
					end
				end

				if not found then
					table.insert(self.carryUid2AdsUidListDict[newUID], uid)
				end
			end
		end

		self.carryUid2AdsUidListDict[oldUID] = nil
	end

	for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
		for i = #adsorbedList, 1, -1 do
			local uid = adsorbedList[i]
			local uidState = gFurnitureUIDManager:GetFurnitureState(uid)

			if uidState then
				if uidState.clientUID ~= oldUID then
					adsorbedList[i] = newUID
				end
			elseif uid ~= oldUID then
				adsorbedList[i] = newUID
			end
		end
	end
end

M.RemoveAdsorptionRelation = function(self, adsorbedUID)
	if not adsorbedUID then
		return nil
	end

	for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
		for i, uid in ipairs(adsorbedList) do
			if uid ~= adsorbedUID then
				table.remove(adsorbedList, i)

				return carryUID
			end
		end
	end

	return nil
end

M.GetAdsorptionSurfaceGoUid = function(self, adsorbedUID)
	if not adsorbedUID then
		return nil
	end

	local state = gFurnitureUIDManager:GetFurnitureState(adsorbedUID)
	local currentUID = adsorbedUID

	if state then
		currentUID = gFurnitureUIDManager:GetCurrentUID(state)
	end

	for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
		for _, uid in ipairs(adsorbedList) do
			local uidState = gFurnitureUIDManager:GetFurnitureState(uid)
			local uidCurrentUID = uid

			if uidState then
				uidCurrentUID = gFurnitureUIDManager:GetCurrentUID(uidState)
			end

			if uidCurrentUID ~= currentUID then
				return carryUID
			end
		end
	end

	return nil
end

M.SetAdsorbedChildrenInteraction = function(self, parentUID, enabled)
	local list = self.carryUid2AdsUidListDict[parentUID]

	if not list then
		return
	end

	for _, childUID in ipairs(list) do
		local childGo = gFurnitureUIDManager.uid2FurnitureGoDict[childUID]

		if childGo and not gCS.LuaUtils.IsNull(childGo) then
			self.SetFurnitureInteractionEnabled(self, childGo, enabled)
		end
	end
end

M.CheckStorageFurnitureHasAdsFurniture = function(self)
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		return false
	end

	local currentOperation = gFurnitureOperationManager.currentOperation

	if not self.currentOperationUniqueId or not currentOperation or currentOperation.operationType == gFurnitureOperationManager.OperationType.EDIT then
		return false
	end

	local adsList = self.carryUid2AdsUidListDict[self.currentOperationUniqueId]

	if not adsList or #adsList ~= 0 then
		return false
	end

	return true
end

M.SetHoverSuppressChecker = function(self, checker)
	self.hoverSuppressChecker = checker
end

M.SetHoverFurnitureFilter = function(self, filter)
	self.hoverFurnitureFilter = filter
end

M.CheckHoveredFurniture = function(self)
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		self.ClearHoveredFurniture(self)

		return
	end

	local touchPos = SGUI.Utils.GetInputCenterPosition()

	if not touchPos then
		self.ClearHoveredFurniture(self)

		return
	end

	if self.hoverSuppressChecker and self.hoverSuppressChecker(touchPos) then
		self.ClearHoveredFurniture(self)

		return
	end

	gHouseCollisionUtils:EnableBoundsBoxByConfig()

	local ray = mainCamera:ScreenPointToRay(touchPos)
	local raycastOrigin = ray.origin or mainCamera.transform.position
	local raycastDirection = ray.direction or mainCamera.transform.forward
	local raycastDistance = 50
	local layerMask = bit.bor(1, bit.lshift(1, LX6.Constants.LayerConstants._Decoration))
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), false)
	self:RestoreFenestrationBoundsBox()

	local foundFurniture = false

	if hitCount <= 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if not hitGo then
				-- Nothing
			else
				local furnitureRoot, furnitureId = self.FindFurnitureRootFromHitObject(self, hitGo)

				if furnitureRoot and furnitureId then
					if self.hoverFurnitureFilter and not self.hoverFurnitureFilter(furnitureId) then
						-- Nothing
					else
						local furnitureComponent = furnitureRoot:GetComponent(typeof(CSFurnitureMono))
						local uid = furnitureComponent and furnitureComponent.uid

						if uid then
							self.SetHoveredFurniture(self, furnitureRoot, uid)

							foundFurniture = true

							break
						end
					end
				end
			end
		end
	end

	if not foundFurniture then
		self.ClearHoveredFurniture(self)
	end
end

M.SetHoveredFurniture = function(self, furnitureGo, uid)
	if self.hoveredFurnitureGo ~= furnitureGo and self.hoveredFurnitureUID ~= uid then
		return
	end

	self.ClearHoveredFurniture(self)

	self.hoveredFurnitureGo = furnitureGo
	self.hoveredFurnitureUID = uid

	if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
		self.hoverEffectUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, LX6.Effect.EffectPlayTag.Gameplay, "furnitureHover_" .. tostring(uid), furnitureGo)
	end
end

M.ClearHoveredFurniture = function(self)
	if self.hoverEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.hoverEffectUUID)

		self.hoverEffectUUID = nil
	end

	self.hoveredFurnitureGo = nil
	self.hoveredFurnitureUID = nil
end

M.CalculateCorrectManualRotation = function(self, originalPosition, originalRotation, furnitureCfg)
	if not furnitureCfg or not furnitureCfg.AdsorptionTypeFinal then
		local defaultY = gHouseManager:GetNowBuildDefaultTowards()
		local originalY = originalRotation.eulerAngles.y
		local manualRotation = originalY - defaultY

		while manualRotation >= 0 do
			manualRotation = manualRotation + 360
		end

		while manualRotation > 360 do
			manualRotation = manualRotation - 360
		end

		return manualRotation
	end

	local isWallFurniture = false

	for _, adsorptionType in ipairs(furnitureCfg.AdsorptionTypeFinal) do
		if adsorptionType ~= AdsorptionType.Wall then
			isWallFurniture = true

			break
		end
	end

	if not isWallFurniture then
		local defaultY = gHouseManager:GetNowBuildDefaultTowards()
		local originalY = originalRotation.eulerAngles.y
		local manualRotation = originalY - defaultY

		while manualRotation >= 0 do
			manualRotation = manualRotation + 360
		end

		while manualRotation > 360 do
			manualRotation = manualRotation - 360
		end

		return manualRotation
	end

	if self.followingFurnitureManualRotation and self.followingFurnitureManualRotation == 0 then
		return self.followingFurnitureManualRotation
	end

	local detectedNormal = self.nowHitNormal

	if not detectedNormal then
		print_warn("FurnitureManager: 墙面法线无效，返回0度")

		return 0
	end

	local manualRotationZ = gFurnitureUtils:ExtractWallManualRotationZ(originalRotation, detectedNormal)

	return manualRotationZ
end

M.GetBaseRotationForManualRotation = function(self)
	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor

	if adsorptionType ~= AdsorptionType.Floor or adsorptionType ~= AdsorptionType.Ceiling then
		local defaultY = gHouseManager:GetNowBuildDefaultTowards()

		return Quaternion.Euler(0, defaultY, 0)
	elseif adsorptionType ~= AdsorptionType.Wall then
		if self.nowHitNormal and self.nowHitNormal == Vector3.zero then
			return gFurnitureUtils:CalculateWallBaseRotation(self.nowHitNormal)
		else
			local defaultY = gHouseManager:GetNowBuildDefaultTowards()

			return Quaternion.Euler(0, defaultY, 0)
		end
	else
		local defaultY = gHouseManager:GetNowBuildDefaultTowards()

		return Quaternion.Euler(0, defaultY, 0)
	end
end

if gFurnitureManager then
	dofile("LX6/Manager/House/HouseManager")
	dofile("LX6/Manager/House/FurnitureRaycastUtils")
	dofile("LX6/Manager/House/FurnitureOperationManager")
	dofile("LX6/Manager/House/WallOperationManager")
	dofile("LX6/Manager/House/BuildOperationManager")
	dofile("LX6/Manager/House/WallEditManager")
	dofile("LX6/Manager/House/WallEditUtils")
	dofile("LX6/Manager/House/FurnitureUtils")
	dofile("LX6/Manager/House/FurnitureConst")
	dofile("LX6/Manager/House/FurnitureMaterialUtils")
	dofile("LX6/Manager/House/FurnitureMeshUtils")
	dofile("LX6/Manager/House/HouseCollisionUtils")
	dofile("LX6/Manager/House/HouseGadgetManager")
	dofile("LX6/Manager/House/HomeBuildUIUtils")
	dofile("LX6/Manager/House/FurnitureShowCaseUtils")
	dofile("LX6/Manager/House/HouseSceneLayout")
	dofile("LX6/Manager/House/WallFurniturePlacementUtils")
	gFurnitureManager:ClearFollowingState()
end

gFurnitureManager = gFurnitureManager or M.New()
