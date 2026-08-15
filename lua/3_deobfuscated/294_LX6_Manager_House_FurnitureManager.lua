local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseConfig = LTConfig.HouseConfig
local MessageConfig = LTConfig.MessageConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local CSFurnitureMono = LX6.GamePlay.House.HouseFurniture
local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
local AdsorptionTypeToTagList = gFurnitureConst.AdsorptionTypeToTagList
local carryTag = gFurnitureConst.carryTag
local CarryItemTagList = {
	carryTag
}
C_FurnitureManager = DefClass("C_FurnitureManager", C_FurnitureManager)
local M = C_FurnitureManager

function M:ctor()
	self.followingFurniture = nil
	self.followingFurnitureComponent = nil
	self.isFollowing = false
	self.followingFurnitureId = nil
	self.followingFurnitureConfig = nil
	self.nowHitLayer = nil
	self.nowHitNormal = nil
	self.nowHitGameObject = nil
	self.previewEffectUUID = nil
	self.followingFurnitureManualRotation = 0
	self.uid2FurnitureGoDict = {}
	self.previewUid2GoDict = {}
	self.carryUid2AdsUidListDict = {}
	self.showCeiling = true
	self.isLongPressing = false
	self.canFollow = false
	self.canEditPlacedFurniture = false
	self.lastCanPlaceState = nil
	self.currentOperationUniqueId = nil
	self.furnitureRoot = nil
	self.uniqueIdCounter = 0
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
	self.lastCollisionState = false
	self.collisionCheckInterval = 0.1
	self.lastCollisionCheckTime = 0
	self.lastBoundaryState = true
	self.furnitureMaterials = {}
	self.baseMeshMaterials = {}
	self.gadgetMeshMaterials = {}
	self.defaultColors = {}
	self.debugSkipTagCheck = false
	self.hoveredFurnitureGo = nil
	self.hoveredFurnitureUID = nil
	self.hoverEffectUUID = nil
	self.previewOriginalFurnitureGo = nil
	self.previewOriginalUID = nil
	self.previewOriginalAdsorbedUIDs = {}
	self.previewAdsorbed2OriginalUID = {}
	self.isPreviewEditMode = false
end

function M:OnInit()
	gFurnitureOperationManager:OnInit()
	self:CreateFurnitureRoot()
end

function M:OnUpdate()
	if self.canEditPlacedFurniture and (not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture)) then
		local inputPos = SGUI.Utils.GetInputCenterPosition()
		local isClicked = SGUI.Utils.IsTouchBegan(inputPos)

		if not isClicked and not self.isLongPressing and (not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture)) then
			self:CheckHoveredFurniture()
		end
	end

	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return
	end

	if not self.isLongPressing or not self.canFollow then
		return
	end

	local adsorptionTypes = self.followingFurnitureConfig.AdsorptionTypeFinal
	local layerMask = self:GetFurnitureLayerMask(adsorptionTypes)
	local newPosition, hitLayer, hitNormal = self:GetMultiLayerRaycastPosition(layerMask)
	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal

	if newPosition then
		local currentRotation = self.followingFurniture.transform.rotation
		local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
		local applyManualRotation = adsorptionType == AdsorptionType.Wall
		local adjustedPosition, adjustedRotation = self:AdjustFurniturePosition(newPosition, currentRotation, applyManualRotation)
		local finalPosition = gFurnitureUtils:SnapToGrid(adjustedPosition, adsorptionType, self.gridModeEnabled, self.gridSize, self.nowHitNormal)
		local currentIndoorId = gHouseManager:GetCurrentIndoorId()
		local isPositionValid = CSFurnitureManager.MoveBoundContains(finalPosition, currentIndoorId, gHouseManager:GetCurRoomPos())
		local boundaryStateChanged = isPositionValid ~= self.lastBoundaryState
		self.lastBoundaryState = isPositionValid

		if isPositionValid then
			self.followingFurniture.transform.position = finalPosition
			self.followingFurniture.transform.rotation = adjustedRotation
			local currentTime = gLogicTime.time

			if self.collisionCheckInterval <= currentTime - self.lastCollisionCheckTime then
				self.lastCollisionCheckTime = currentTime
				local isColliding = self:CheckFurnitureCollision()

				if boundaryStateChanged or isColliding ~= self.lastCollisionState then
					self.lastCollisionState = isColliding

					self:SetFurnitureColor(self.followingFurniture, isColliding, false)
				end
			elseif boundaryStateChanged then
				local isColliding = self:CheckFurnitureCollision()
				self.lastCollisionState = isColliding

				self:SetFurnitureColor(self.followingFurniture, isColliding, false)
			end
		else
			self:SetFurnitureColor(self.followingFurniture, true, true)
		end
	end

	if self.surfaceHintMeshEnabled then
		self:UpdateSurfaceHintMeshIfNeeded()
	end
end

function M:CreateFurnitureRoot()
	if not self.furnitureRoot or gCS.LuaUtils.IsNull(self.furnitureRoot) then
		self.furnitureRoot = GameObject.New("FurnitureRoot")
	end
end

function M:GetFurnitureRoot()
	self:CreateFurnitureRoot()

	return self.furnitureRoot
end

function M:FindFurnitureByUniqueId(uniqueId)
	return self.uid2FurnitureGoDict[uniqueId] or nil
end

function M:GenerateUniqueId()
	self.uniqueIdCounter = self.uniqueIdCounter + 1

	return self.uniqueIdCounter
end

function M:GeneratePreviewChildUniqueId()
	self.uniqueIdCounter = self.uniqueIdCounter + 1

	return self.uniqueIdCounter + 1000000000
end

function M:OnDestroy()
	self:ClearFollowingFurniture()
end

function M:SpawnFurniture(furnitureId, initAtScreenCenter)
	local availableCount = gHouseManager:GetRealTimeAvailableCount(furnitureId)

	if availableCount <= 0 then
		gDisplayMessageMgr:ShowMessageContentDebug("MessageConfig.HouseBuildFurnitureNotEnough")

		return false
	end

	self:ClearHoveredFurniture()

	if self.isFollowing and self.followingFurniture then
		self:ClearFollowingFurniture()
	elseif self.followingFurniture then
		self:ClearFollowingFurniture()
	end

	self.currentOperationUniqueId = self:GenerateUniqueId()

	gFurnitureOperationManager:BeginSpawnOperation(furnitureId, self.currentOperationUniqueId)

	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)
	self.followingFurnitureId = furnitureId
	self.followingFurnitureConfig = furnitureCfg
	local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)
	local spawnPosition, hitLayer, hitNormal = self:GetMultiLayerRaycastPosition(layerMask, initAtScreenCenter)

	if spawnPosition == Vector3.zero and initAtScreenCenter then
		gDisplayMessageMgr:ShowMessage(MessageConfig.HouseBuildCantSetFurniture)

		return
	end

	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal
	local surfaceBounds = nil

	if CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] then
		local hitInfo = CSFurnitureManager.SortedRayCastList[0]

		if hitInfo.collider then
			surfaceBounds = hitInfo.collider.bounds
		end
	end

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			local defaultY = gHouseManager:GetNowBuildDefaultTowards()
			self.followingFurniture = furnitureGo
			self.followingFurnitureComponent = furnitureGo:GetComponent(typeof(CSFurnitureMono))
			self.isFollowing = true
			self.isLongPressing = false
			self.canFollow = false

			if not initAtScreenCenter then
				self.isLongPressing = true
				self.canFollow = true
			end

			local baseRotation = Quaternion.Euler(0, defaultY, 0)
			local adjustedPosition, adjustedRotation = self:AdjustFurniturePosition(spawnPosition, baseRotation)
			furnitureGo.transform.position = adjustedPosition
			furnitureGo.transform.rotation = adjustedRotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, self.currentOperationUniqueId, false)

			self:SetFurnitureInteractionEnabled(furnitureGo, false)

			local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
			self.previewEffectUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "furniturePreview_" .. tostring(furnitureId), self.followingFurnitureComponent.meshObject)

			self:GenerateBaseMesh(furnitureCfg, adsorptionType, self.nowHitNormal)

			if surfaceBounds and self.surfaceHintMeshEnabled then
				self:GenerateSurfaceHintMesh(surfaceBounds, adsorptionType, self.nowHitNormal)
			end

			self:CreateMaterialInstances(furnitureGo)

			local isColliding = self:CheckFurnitureCollision()

			self:SetFurnitureColor(self.followingFurniture, isColliding)
			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_ENTER_EDIT)
		else
			print_error(string.format("FurnitureManager: 加载家具模型失败 [%s] 路径:%s", furnitureCfg.Name or "未知", furnitureCfg.ModelName))
		end
	end)
end

function M:GetFurnitureLayerMask(adsorptionTypes)
	local layers = {}

	for i, adsorptionType in ipairs(adsorptionTypes) do
		local layer = 0

		if adsorptionType == AdsorptionType.Floor then
			layer = LX6.Constants.LayerConstants.Floor or 8
		elseif adsorptionType == AdsorptionType.Ceiling then
			layer = 27

			if 27 then
				layer = LX6.Constants.LayerConstants._Ceiling
			end
		elseif adsorptionType == AdsorptionType.Wall then
			layer = LX6.Constants.LayerConstants.Wall or 16
		else
			print_notice("FurnitureManager: 未知的吸附类型: " .. tostring(adsorptionType) .. "，跳过")
		end

		table.insert(layers, layer)
	end

	local IsAdsorptOnItem = self.followingFurnitureConfig and self.followingFurnitureConfig.IsAdsorptOnItem

	if IsAdsorptOnItem then
		local defaultLayer = LX6.Constants.LayerConstants.Default or 0

		table.insert(layers, defaultLayer)
	end

	local layerMask = gFurnitureUtils:GetMask(layers)

	return layerMask
end

function M:AdjustFurniturePosition(position, baseRotation, applyManualRotation)
	local adjustedPosition = position
	local adjustedRotation = baseRotation or Quaternion.identity
	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor

	if adsorptionType == AdsorptionType.Floor then
		adjustedPosition = Vector3.New(position.x, position.y, position.z)
	elseif adsorptionType == AdsorptionType.Ceiling then
		adjustedPosition = Vector3.New(position.x, position.y, position.z)
	elseif adsorptionType == AdsorptionType.Wall then
		if self.nowHitNormal and self.nowHitNormal ~= Vector3.zero then
			adjustedRotation = gFurnitureUtils:CalculateWallBaseRotation(self.nowHitNormal)

			if self.followingFurnitureComponent and self.followingFurnitureComponent.boundsBox then
				local boundsDepth = self.followingFurnitureComponent.boundsBox.size.z
				local offsetDistance = boundsDepth * 0.5
				adjustedPosition = position + self.nowHitNormal * offsetDistance
			else
				local fixedOffset = 0.5
				adjustedPosition = position + self.nowHitNormal * fixedOffset
			end
		else
			print_warn("FurnitureManager: 墙面法线无效，使用默认旋转和位置")

			adjustedRotation = baseRotation or Quaternion.identity
		end
	else
		print_warn(string.format("FurnitureManager: 未知吸附类型: %d，保持原位置和旋转", adsorptionType))
	end

	if applyManualRotation ~= false and self.followingFurnitureManualRotation ~= 0 then
		if adsorptionType == AdsorptionType.Wall then
			adjustedRotation = gFurnitureUtils:ApplyWallManualRotation(adjustedRotation, self.followingFurnitureManualRotation)
		else
			local worldRotationAxis = gFurnitureUtils:GetRotationAxis(adsorptionType, self.nowHitNormal)
			local manualRotation = Quaternion.AngleAxis(self.followingFurnitureManualRotation, worldRotationAxis)
			adjustedRotation = adjustedRotation * manualRotation
		end
	end

	return adjustedPosition, adjustedRotation
end

function M:GenerateBaseMesh(furnitureCfg, adsorptionType, hitNormal)
	local furnitureGo = self.followingFurniture
	local baseMeshPath = HouseConfig.BaseMeshPath
	self.baseMeshLoadOp = gResourceManager:LoadAssetWithCallBack(baseMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			self.baseMeshGo = GameObject.Instantiate(loadOp.asset)

			self.baseMeshGo.transform:SetParent(furnitureGo.transform, false)
			self:AdjustBaseMeshSize(furnitureGo, adsorptionType, hitNormal)

			self.baseMeshGo.name = "BaseMesh_" .. (furnitureCfg.Name or "Unknown")

			if self.baseMeshGo then
				local baseMeshRenderer = self.baseMeshGo:GetComponent(typeof(UnityEngine.Renderer))

				if baseMeshRenderer and baseMeshRenderer.material then
					local originalBaseMaterial = baseMeshRenderer.material
					local baseMaterialInstance = UnityEngine.Object.Instantiate(originalBaseMaterial)
					baseMeshRenderer.material = baseMaterialInstance

					table.insert(self.baseMeshMaterials, baseMaterialInstance)

					local baseDefaultColor = nil

					if baseMaterialInstance:HasProperty("_MainColor") then
						baseDefaultColor = baseMaterialInstance:GetColor("_MainColor")
						self.defaultColors._BaseMesh_MainColor = baseDefaultColor
					elseif baseMaterialInstance:HasProperty("_BaseColor") then
						baseDefaultColor = baseMaterialInstance:GetColor("_BaseColor")
						self.defaultColors._BaseMesh_BaseColor = baseDefaultColor
					elseif baseMaterialInstance:HasProperty("_Color") then
						baseDefaultColor = baseMaterialInstance:GetColor("_Color")
						self.defaultColors._BaseMesh_Color = baseDefaultColor
					end

					if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
						local isColliding = self:CheckFurnitureCollision()

						self:SetFurnitureColor(self.followingFurniture, isColliding)
					end
				end
			end

			if self.followingFurnitureComponent and self.followingFurnitureComponent.isGadget then
				local gadgetMeshPath = HouseConfig.GadgetMeshPath

				self:GenerateGadgetMesh(gadgetMeshPath, furnitureGo, adsorptionType, hitNormal)
			end
		else
			print_error(string.format("FurnitureManager: 加载底座mesh失败，路径: %s", baseMeshPath))
		end
	end)
end

function M:GenerateGadgetMesh(gadgetMeshPath, furnitureGo, adsorptionType, hitNormal)
	self.gadgetMeshLoadOp = gResourceManager:LoadAssetWithCallBack(gadgetMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			self.gadgetMeshGo = GameObject.Instantiate(loadOp.asset)

			self.gadgetMeshGo.transform:SetParent(furnitureGo.transform, false)

			if self.followingFurnitureComponent and self.followingFurnitureComponent.boundsBox then
				local furnitureBounds = self.followingFurnitureComponent.boundsBox
				local furnitureSizeZ = furnitureBounds.size.z
				local params = HouseConfig.GadgetMeshSizeParams or {
					0.3,
					12
				}
				local adaptiveScale = params[1] + furnitureSizeZ / params[2]
				self.gadgetMeshGo.transform.localScale = Vector3.New(adaptiveScale, adaptiveScale, adaptiveScale)
			end

			if self.followingFurnitureComponent and self.followingFurnitureComponent.gadgetOffset then
				local offset = self.followingFurnitureComponent.gadgetOffset
				local meshSizeX = 0.5
				local meshSizeZ = 0.5
				local renderer = self.gadgetMeshGo:GetComponent(typeof(UnityEngine.Renderer))

				if renderer and renderer.bounds then
					meshSizeX = renderer.bounds.size.x * 0.5
					meshSizeZ = renderer.bounds.size.z
				end

				self.gadgetMeshGo.transform.localPosition = Vector3.New(offset.x + meshSizeX, 0.01, offset.z + meshSizeZ)
			end

			self.gadgetMeshGo.name = "GadgetMesh_" .. (furnitureGo.name or "Unknown")

			if self.gadgetMeshGo then
				local gadgetMeshRenderer = self.gadgetMeshGo:GetComponent(typeof(UnityEngine.Renderer))

				if gadgetMeshRenderer and gadgetMeshRenderer.material then
					local originalGadgetMaterial = gadgetMeshRenderer.material
					local gadgetMaterialInstance = UnityEngine.Object.Instantiate(originalGadgetMaterial)
					gadgetMeshRenderer.material = gadgetMaterialInstance

					if not self.gadgetMeshMaterials then
						self.gadgetMeshMaterials = {}
					end

					table.insert(self.gadgetMeshMaterials, gadgetMaterialInstance)

					local gadgetDefaultColor = nil

					if gadgetMaterialInstance:HasProperty("_MainColor") then
						gadgetDefaultColor = gadgetMaterialInstance:GetColor("_MainColor")
						self.defaultColors._GadgetMesh_MainColor = gadgetDefaultColor
					elseif gadgetMaterialInstance:HasProperty("_BaseColor") then
						gadgetDefaultColor = gadgetMaterialInstance:GetColor("_BaseColor")
						self.defaultColors._GadgetMesh_BaseColor = gadgetDefaultColor
					elseif gadgetMaterialInstance:HasProperty("_Color") then
						gadgetDefaultColor = gadgetMaterialInstance:GetColor("_Color")
						self.defaultColors._GadgetMesh_Color = gadgetDefaultColor
					end

					if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
						local isColliding = self:CheckFurnitureCollision()

						self:SetFurnitureColor(self.followingFurniture, isColliding)
					end
				end
			end
		else
			print_error(string.format("FurnitureManager: 加载gadget mesh失败，路径: %s", gadgetMeshPath))
		end
	end)
end

function M:AdjustBaseMeshSize(furnitureGo, adsorptionType, hitNormal)
	if not self.baseMeshGo then
		return
	end

	local renderer = furnitureGo:GetComponent(typeof(UnityEngine.Renderer))
	renderer = renderer or furnitureGo:GetComponentInChildren(typeof(UnityEngine.Renderer))

	if not self.followingFurnitureComponent.boundsBox then
		local boundsCenter = self.followingFurnitureComponent.boundsBox.center
		self.baseMeshGo.transform.localScale = Vector3.New(1, 1, 1)
		self.baseMeshGo.transform.localPosition = Vector3.New(boundsCenter.x, boundsCenter.y, boundsCenter.z)

		return
	end

	local boundsSize = self.followingFurnitureComponent.boundsBox.size
	local scaleX = boundsSize.x
	local scaleZ = boundsSize.z
	local boundsCenter = self.followingFurnitureComponent.boundsBox.center
	self.baseMeshGo.transform.localScale = Vector3.New(scaleX, 1, scaleZ)

	if adsorptionType == AdsorptionType.Floor then
		self.baseMeshGo.transform.localRotation = Quaternion.identity
		local offsetToCenterX = scaleX * 0.5
		local offsetToCenterZ = scaleZ * 0.5
		local localPositionX = offsetToCenterX + boundsCenter.x
		local localPositionY = 0.01
		local localPositionZ = offsetToCenterZ + boundsCenter.z
		self.baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	elseif adsorptionType == AdsorptionType.Ceiling then
		self.baseMeshGo.transform.localRotation = Quaternion.identity
		local offsetToCenterX = scaleX * 0.5
		local offsetToCenterZ = scaleZ * 0.5
		local localPositionX = offsetToCenterX + boundsCenter.x
		local localPositionY = -0.01
		local localPositionZ = offsetToCenterZ + boundsCenter.z
		self.baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	elseif adsorptionType == AdsorptionType.Wall and hitNormal then
		local wallNormal = hitNormal
		wallNormal.y = 0
		wallNormal = wallNormal.normalized
		local xRotation90 = Quaternion.Euler(90, 0, 0)
		self.baseMeshGo.transform.localRotation = xRotation90
		local wallScaleX = boundsSize.x
		local wallScaleY = boundsSize.y
		local offset = 0.08
		self.baseMeshGo.transform.localScale = Vector3.New(wallScaleX + offset, 1, wallScaleY + offset)
		local localPositionX = wallScaleX * 0.5 + offset / 2
		local localPositionY = -wallScaleY * 0.5 - offset / 2
		local localPositionZ = 0
		self.baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	else
		self.baseMeshGo.transform.localRotation = Quaternion.identity
		self.baseMeshGo.transform.localPosition = Vector3.New(boundsCenter.x, boundsCenter.y, boundsCenter.z)
	end
end

function M:GenerateSurfaceHintMesh(surfaceBounds, adsorptionType, hitNormal)
	local surfaceHintMeshPath = HouseConfig.GridMeshPath

	self:ClearSurfaceHintMesh()

	local currentSurfaceCollider = nil

	if CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] and CSFurnitureManager.SortedRayCastList[0].collider then
		currentSurfaceCollider = CSFurnitureManager.SortedRayCastList[0].collider
	end

	self.surfaceHintMeshLoadOp = gResourceManager:LoadAssetWithCallBack(surfaceHintMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			if not self.surfaceHintMeshEnabled or not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
				self.surfaceHintMeshLoadOp = nil

				return
			end

			self.surfaceHintMeshGo = GameObject.Instantiate(loadOp.asset)
			local furnitureRoot = self:GetFurnitureRoot()

			if furnitureRoot then
				self.surfaceHintMeshGo.transform:SetParent(furnitureRoot.transform, true)
			end

			self:AdjustSurfaceHintMeshPosition(surfaceBounds, adsorptionType, hitNormal)

			self.surfaceHintMeshGo.name = "SurfaceHintMesh_" .. tostring(adsorptionType)
			local renderer = self.surfaceHintMeshGo:GetComponent(typeof(UnityEngine.Renderer))

			if renderer and renderer.material then
				local material = renderer.material

				if material:HasProperty("_Color") then
					material:SetColor("_Color", Color.New(0, 1, 0, 0.3))
				elseif material:HasProperty("_BaseColor") then
					material:SetColor("_BaseColor", Color.New(0, 1, 0, 0.3))
				elseif material:HasProperty("_MainColor") then
					material:SetColor("_MainColor", Color.New(0, 1, 0, 0.3))
				end
			end

			if currentSurfaceCollider then
				self:UpdateCurrentSurfaceState(currentSurfaceCollider, surfaceBounds, adsorptionType, hitNormal)
			end
		else
			print_error(string.format("FurnitureManager: 加载表面提示mesh失败，路径: %s", surfaceHintMeshPath))
		end

		self.surfaceHintMeshLoadOp = nil
	end)
end

function M:AdjustSurfaceHintMeshPosition(surfaceBounds, adsorptionType, hitNormal)
	if not self.surfaceHintMeshGo or not surfaceBounds then
		return
	end

	local surfaceCenter = surfaceBounds.center
	local surfaceSize = surfaceBounds.size
	local defaultY = gHouseManager:GetNowBuildDefaultTowards()
	defaultY = 0

	if adsorptionType == AdsorptionType.Floor then
		local offsetToCenterX = surfaceSize.x * 0.5
		local offsetToCenterZ = surfaceSize.z * 0.5
		self.surfaceHintMeshGo.transform.rotation = Quaternion.Euler(0, defaultY, 0)
		local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, self.gridSize)
		local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, self.gridSize)
		self.surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
		local hintPosition = Vector3.New(surfaceCenter.x + offsetToCenterX, surfaceCenter.y + surfaceSize.y * 0.5 + 0.01, surfaceCenter.z + offsetToCenterZ)
		hintPosition = gFurnitureUtils:SnapToGrid(hintPosition, adsorptionType, self.gridModeEnabled, self.gridSize, hitNormal)
		self.surfaceHintMeshGo.transform.position = hintPosition
	elseif adsorptionType == AdsorptionType.Ceiling then
		self.surfaceHintMeshGo.transform.rotation = Quaternion.Euler(180, defaultY, 0)
		local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, self.gridSize)
		local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, self.gridSize)
		self.surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
		local offsetToCenterX = surfaceSize.x * 0.5
		local offsetToCenterZ = surfaceSize.z * 0.5
		local hintPosition = Vector3.New(surfaceCenter.x + offsetToCenterX, surfaceCenter.y - surfaceSize.y * 0.5 - 0.01, surfaceCenter.z - offsetToCenterZ)
		hintPosition = gFurnitureUtils:SnapToGrid(hintPosition, adsorptionType, self.gridModeEnabled, self.gridSize, hitNormal)
		self.surfaceHintMeshGo.transform.position = hintPosition
	elseif adsorptionType == AdsorptionType.Wall then
		if hitNormal and self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
			local wallNormal = hitNormal
			wallNormal.y = 0
			wallNormal = wallNormal.normalized
			local lookRotation = Quaternion.LookRotation(wallNormal, Vector3.up)
			local xRotation90 = Quaternion.Euler(90, 0, 0)
			self.surfaceHintMeshGo.transform.rotation = lookRotation * xRotation90
			local sizeX = math.max(surfaceSize.x, surfaceSize.z)
			local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(sizeX, self.gridSize)
			local expandedSizeY = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.y, self.gridSize)
			self.surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeY)
			local wallScaleX = sizeX
			local wallScaleY = surfaceSize.y
			local localOffsetX = wallScaleX * 0.5
			local localOffsetY = -wallScaleY * 0.5
			local localOffsetLength = 0.12
			local meshCenterOffset = Vector3.New(localOffsetX, localOffsetY, 0)
			local worldCenterOffset = lookRotation * meshCenterOffset
			local hintPosition = surfaceCenter + worldCenterOffset + wallNormal * localOffsetLength
			hintPosition = gFurnitureUtils:SnapToGrid(hintPosition, adsorptionType, self.gridModeEnabled, self.gridSize, hitNormal)
			self.surfaceHintMeshGo.transform.position = hintPosition
		else
			self.surfaceHintMeshGo.transform.rotation = Quaternion.identity
			local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, self.gridSize)
			local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, self.gridSize)
			self.surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
			local alignedPosition = gFurnitureUtils:SnapToGrid(surfaceCenter, adsorptionType, self.gridModeEnabled, self.gridSize, hitNormal)
			self.surfaceHintMeshGo.transform.position = alignedPosition
		end
	else
		self.surfaceHintMeshGo.transform.rotation = Quaternion.identity
		local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, self.gridSize)
		local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, self.gridSize)
		self.surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
		local alignedPosition = gFurnitureUtils:SnapToGrid(surfaceCenter, adsorptionType, self.gridModeEnabled, self.gridSize, hitNormal)
		self.surfaceHintMeshGo.transform.position = alignedPosition
	end
end

function M:ClearBaseMesh()
	if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) then
		GameObject.Destroy(self.baseMeshGo)

		self.baseMeshGo = nil
	end

	if self.baseMeshLoadOp then
		self.baseMeshLoadOp = nil
	end

	if self.gadgetMeshGo and not gCS.LuaUtils.IsNull(self.gadgetMeshGo) then
		GameObject.Destroy(self.gadgetMeshGo)

		self.gadgetMeshGo = nil
	end

	if self.gadgetMeshLoadOp then
		self.gadgetMeshLoadOp = nil
	end
end

function M:ClearSurfaceHintMesh()
	if self.surfaceHintMeshGo and not gCS.LuaUtils.IsNull(self.surfaceHintMeshGo) then
		GameObject.Destroy(self.surfaceHintMeshGo)

		self.surfaceHintMeshGo = nil
	end

	if self.surfaceHintMeshLoadOp then
		self.surfaceHintMeshLoadOp = nil
	end

	self:ResetCurrentSurfaceState()
end

function M:SetSurfaceHintMeshEnabled(enabled)
	if self.surfaceHintMeshEnabled == enabled then
		return
	end

	local oldEnabled = self.surfaceHintMeshEnabled
	self.surfaceHintMeshEnabled = enabled

	if not enabled then
		self:ClearSurfaceHintMesh()
	elseif oldEnabled == false and enabled == true and self.isFollowing and self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		self:RegenerateSurfaceHintMesh()
	end
end

function M:SetGridModeEnabled(enabled)
	self.gridModeEnabled = enabled

	self:SetSurfaceHintMeshEnabled(enabled)
end

function M:GetGridModeEnabled()
	return self.gridModeEnabled
end

function M:RegenerateSurfaceHintMesh()
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

	if adsorptionType == AdsorptionType.Floor then
		raycastOrigin = Vector3.New(furniturePosition.x, furniturePosition.y + 0.1, furniturePosition.z)
		raycastDirection = Vector3.down
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants.Floor
		})
	elseif adsorptionType == AdsorptionType.Ceiling then
		raycastOrigin = Vector3.New(furniturePosition.x, furniturePosition.y - 0.1, furniturePosition.z)
		raycastDirection = Vector3.up
		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants._Ceiling
		})
	elseif adsorptionType == AdsorptionType.Wall then
		if self.nowHitNormal then
			local wallDirection = -self.nowHitNormal
			raycastDirection = Vector3.New(wallDirection.x, 0, wallDirection.z)
			raycastDirection = raycastDirection.normalized
		else
			raycastDirection = Vector3.forward
		end

		layerMask = gFurnitureUtils:GetMask({
			LX6.Constants.LayerConstants.Wall
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

	if hitCount > 0 then
		local hitInfo = CSFurnitureManager.SortedRayCastList[0]

		if hitInfo.collider then
			surfaceBounds = hitInfo.collider.bounds
			hitNormal = hitInfo.normal
		end

		if surfaceBounds then
			self:GenerateSurfaceHintMesh(surfaceBounds, adsorptionType, hitNormal)
		end
	end
end

function M:UpdateSurfaceHintMeshIfNeeded()
	if not self.surfaceHintMeshEnabled then
		if self.surfaceHintMeshGo or self.surfaceHintMeshLoadOp then
			self:ClearSurfaceHintMesh()
		end

		return
	end

	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) or not self.followingFurnitureConfig then
		if self.surfaceHintMeshGo or self.surfaceHintMeshLoadOp then
			self:ClearSurfaceHintMesh()
		end

		return
	end

	if self.surfaceHintMeshLoadOp then
		return
	end

	local adsorptionTypes = self.followingFurnitureConfig.AdsorptionTypeFinal
	local layerMask = self:GetFurnitureLayerMask(adsorptionTypes)
	local newPosition, hitLayer, hitNormal = self:GetMultiLayerRaycastPosition(layerMask)

	if not newPosition then
		if self.surfaceHintMeshGo then
			self:ClearSurfaceHintMesh()
		end

		self:ResetCurrentSurfaceState()

		return
	end

	local surfaceCollider, surfaceBounds = nil

	if CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] then
		local hitInfo = CSFurnitureManager.SortedRayCastList[0]

		if hitInfo.collider then
			surfaceCollider = hitInfo.collider
			surfaceBounds = hitInfo.collider.bounds
		end
	end

	if not surfaceCollider or not surfaceBounds then
		if self.surfaceHintMeshGo then
			self:ClearSurfaceHintMesh()
		end

		self:ResetCurrentSurfaceState()

		return
	end

	local adsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor
	local surfaceChanged = self:HasSurfaceChanged(surfaceCollider, surfaceBounds, adsorptionType, hitNormal)

	if surfaceChanged then
		self:ClearSurfaceHintMesh()
		self:GenerateSurfaceHintMesh(surfaceBounds, adsorptionType, hitNormal)
		self:UpdateCurrentSurfaceState(surfaceCollider, surfaceBounds, adsorptionType, hitNormal)
	end
end

function M:HasSurfaceChanged(newCollider, newBounds, newAdsorptionType, newNormal)
	if self.currentSurfaceCollider ~= newCollider then
		return true
	end

	if self.currentSurfaceAdsorptionType ~= newAdsorptionType then
		return true
	end

	if newNormal and self.currentSurfaceNormal then
		local dotProduct = Vector3.Dot(newNormal.normalized, self.currentSurfaceNormal.normalized)

		if dotProduct < 0.99 then
			return true
		end
	elseif newNormal ~= self.currentSurfaceNormal then
		return true
	end

	if newBounds and self.currentSurfaceBounds then
		local centerDist = Vector3.Distance(newBounds.center, self.currentSurfaceBounds.center)
		local sizeDiff = Vector3.Distance(newBounds.size, self.currentSurfaceBounds.size)

		if centerDist > 0.1 or sizeDiff > 0.1 then
			return true
		end
	elseif newBounds ~= self.currentSurfaceBounds then
		return true
	end

	return false
end

function M:UpdateCurrentSurfaceState(collider, bounds, adsorptionType, normal)
	self.currentSurfaceCollider = collider
	self.currentSurfaceBounds = bounds
	self.currentSurfaceAdsorptionType = adsorptionType
	self.currentSurfaceNormal = normal
end

function M:ResetCurrentSurfaceState()
	self.currentSurfaceCollider = nil
	self.currentSurfaceBounds = nil
	self.currentSurfaceAdsorptionType = nil
	self.currentSurfaceNormal = nil
end

function M:CheckFurnitureCollision()
	local center = self.followingFurniture.transform:TransformPoint(self.followingFurnitureComponent.boundsBox.center)
	local size = self.followingFurnitureComponent.boundsBox.size
	local freeFactor = 0.9

	if self.followingFurnitureConfig and self.followingFurnitureConfig.CanIgnoreCollision then
		freeFactor = 1
	end

	local halfExtents = Vector3.New(size.x * 0.5 * freeFactor, size.y * 0.5 * freeFactor, size.z * 0.5 * freeFactor)
	local layerMask = bit.band(4294967295.0, bit.bnot(bit.bor(bit.lshift(1, 2), bit.bor(bit.lshift(1, 13), bit.lshift(1, 15)))))

	for uid, go in pairs(self.uid2FurnitureGoDict) do
		if not gCS.LuaUtils.IsNull(go) then
			local furnitureId = self:TryGetFurnitureIdFromGo(go)
			local cfg = HouseFurnitureConfig.GetConfig(furnitureId)

			if cfg and not cfg.CanIgnoreCollision then
				CSFurnitureManager.EnableAllBoundsBox(go, true)
			end
		end
	end

	local hitCount = 0
	local success, result = pcall(function ()
		return CSFurnitureManager.BoxNonAlloc(center, halfExtents, nil, self.followingFurniture.transform.rotation, layerMask, true, 1)
	end)

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), false)

	if not success then
		print_error(string.format("FurnitureManager: 碰撞检测失败: %s", tostring(result)))

		return false
	end

	hitCount = result

	if hitCount > 0 then
		for i = 0, hitCount - 1 do
			local hitCollider = CSFurnitureManager.SortedColliderList[i]
			local hitGo = hitCollider.gameObject

			if hitGo ~= self.followingFurniture and (not self.baseMeshGo or hitGo ~= self.baseMeshGo) and not self:IsChildOf(hitGo, self.followingFurniture) then
				if self.followingFurnitureConfig and self.followingFurnitureConfig.CanIgnoreCollision then
					local hitFurnitureRoot, hitFurnitureId = self:FindFurnitureRootFromHitObject(hitGo)
					local isCollidingWithFurniture = hitFurnitureRoot ~= nil and hitFurnitureId ~= nil

					if not isCollidingWithFurniture then
						print_debug(string.format("[CheckFurnitureCollision] 家具与非家具物体发生碰撞，碰撞对象: %s", hitGo.name))

						return true
					end
				else
					local hitFurnitureRoot, hitFurnitureId = self:FindFurnitureRootFromHitObject(hitGo)

					print_debug(string.format("[CheckFurnitureCollision] 家具发生碰撞, 对象名称: %s", hitFurnitureRoot and hitFurnitureRoot.name or hitGo.name))

					return true
				end
			end
		end
	end

	return false
end

function M:CreateMaterialInstances(furnitureGo)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	self.furnitureMaterials = {}
	self.baseMeshMaterials = {}
	self.gadgetMeshMaterials = {}
	self.defaultColors = {}
	local renderers = furnitureGo:GetComponentsInChildren(typeof(UnityEngine.Renderer))

	if renderers then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]

			if renderer and renderer.material then
				local originalMaterial = renderer.material
				local materialInstance = UnityEngine.Object.Instantiate(originalMaterial)
				renderer.material = materialInstance

				table.insert(self.furnitureMaterials, materialInstance)

				local defaultColor = nil

				if materialInstance:HasProperty("_MainColor") then
					defaultColor = materialInstance:GetColor("_MainColor")
					self.defaultColors["_MainColor_" .. i] = defaultColor
				elseif materialInstance:HasProperty("_BaseColor") then
					defaultColor = materialInstance:GetColor("_BaseColor")
					self.defaultColors["_BaseColor_" .. i] = defaultColor
				elseif materialInstance:HasProperty("_Color") then
					defaultColor = materialInstance:GetColor("_Color")
					self.defaultColors["_Color_" .. i] = defaultColor
				end
			end
		end
	end

	if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) then
		local baseMeshRenderer = self.baseMeshGo:GetComponent(typeof(UnityEngine.Renderer))

		if baseMeshRenderer and baseMeshRenderer.material then
			local originalBaseMaterial = baseMeshRenderer.material
			local baseMaterialInstance = UnityEngine.Object.Instantiate(originalBaseMaterial)
			baseMeshRenderer.material = baseMaterialInstance

			table.insert(self.baseMeshMaterials, baseMaterialInstance)

			local baseDefaultColor = nil

			if baseMaterialInstance:HasProperty("_MainColor") then
				baseDefaultColor = baseMaterialInstance:GetColor("_MainColor")
				self.defaultColors._BaseMesh_MainColor = baseDefaultColor
			elseif baseMaterialInstance:HasProperty("_BaseColor") then
				baseDefaultColor = baseMaterialInstance:GetColor("_BaseColor")
				self.defaultColors._BaseMesh_BaseColor = baseDefaultColor
			elseif baseMaterialInstance:HasProperty("_Color") then
				baseDefaultColor = baseMaterialInstance:GetColor("_Color")
				self.defaultColors._BaseMesh_Color = baseDefaultColor
			end
		end
	end
end

function M:SetFurnitureColor(furnitureGo, isColliding, forceRed)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local red = Color.New(0.5, 0.1, 0.1, 1)
	local green = Color.New(0.1, 0.5, 0.1, 1)
	local canPlace, targetColor = nil

	if forceRed then
		canPlace = false
		targetColor = red
	else
		canPlace = not isColliding
		targetColor = canPlace and green or red
	end

	if self.lastCanPlaceState ~= canPlace then
		self.lastCanPlaceState = canPlace

		gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_CAN_PLACE_CHANGED, {
			canPlace = canPlace
		})
	end

	if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) then
		local baseMeshRenderer = self.baseMeshGo:GetComponent(typeof(UnityEngine.Renderer))

		if baseMeshRenderer and baseMeshRenderer.material then
			local baseMaterial = baseMeshRenderer.material

			if baseMaterial:HasProperty("_EmissionColor") then
				local emissionColor = targetColor

				baseMaterial:SetColor("_EmissionColor", emissionColor)
			end
		end
	end

	if self.gadgetMeshGo and not gCS.LuaUtils.IsNull(self.gadgetMeshGo) then
		local gadgetMeshRenderer = self.gadgetMeshGo:GetComponent(typeof(UnityEngine.Renderer))

		if gadgetMeshRenderer and gadgetMeshRenderer.material then
			local gadgetMaterial = gadgetMeshRenderer.material

			if gadgetMaterial:HasProperty("_EmissionColor") then
				local emissionColor = targetColor

				gadgetMaterial:SetColor("_EmissionColor", emissionColor)
			end
		end
	end
end

function M:RestoreMaterialColors(furnitureGo)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local renderers = furnitureGo:GetComponentsInChildren(typeof(UnityEngine.Renderer))

	if renderers then
		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]

			if renderer and renderer.material then
				local material = renderer.material
				local mainColorKey = "_MainColor_" .. i
				local baseColorKey = "_BaseColor_" .. i
				local colorKey = "_Color_" .. i

				if self.defaultColors[mainColorKey] and material:HasProperty("_MainColor") then
					material:SetColor("_MainColor", self.defaultColors[mainColorKey])
				elseif self.defaultColors[baseColorKey] and material:HasProperty("_BaseColor") then
					material:SetColor("_BaseColor", self.defaultColors[baseColorKey])
				elseif self.defaultColors[colorKey] and material:HasProperty("_Color") then
					material:SetColor("_Color", self.defaultColors[colorKey])
				end

				if material:HasProperty("_EmissionColor") then
					material:SetColor("_EmissionColor", Color.black)
				end
			end
		end
	end

	if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) then
		local baseMeshRenderer = self.baseMeshGo:GetComponent(typeof(UnityEngine.Renderer))

		if baseMeshRenderer and baseMeshRenderer.material then
			local baseMaterial = baseMeshRenderer.material

			if self.defaultColors._BaseMesh_MainColor and baseMaterial:HasProperty("_MainColor") then
				baseMaterial:SetColor("_MainColor", self.defaultColors._BaseMesh_MainColor)
			elseif self.defaultColors._BaseMesh_BaseColor and baseMaterial:HasProperty("_BaseColor") then
				baseMaterial:SetColor("_BaseColor", self.defaultColors._BaseMesh_BaseColor)
			elseif self.defaultColors._BaseMesh_Color and baseMaterial:HasProperty("_Color") then
				baseMaterial:SetColor("_Color", self.defaultColors._BaseMesh_Color)
			end

			if baseMaterial:HasProperty("_EmissionColor") then
				baseMaterial:SetColor("_EmissionColor", Color.black)
			end
		end
	end

	if self.gadgetMeshGo and not gCS.LuaUtils.IsNull(self.gadgetMeshGo) then
		local gadgetMeshRenderer = self.gadgetMeshGo:GetComponent(typeof(UnityEngine.Renderer))

		if gadgetMeshRenderer and gadgetMeshRenderer.material then
			local gadgetMaterial = gadgetMeshRenderer.material

			if self.defaultColors._GadgetMesh_MainColor and gadgetMaterial:HasProperty("_MainColor") then
				gadgetMaterial:SetColor("_MainColor", self.defaultColors._GadgetMesh_MainColor)
			elseif self.defaultColors._GadgetMesh_BaseColor and gadgetMaterial:HasProperty("_BaseColor") then
				gadgetMaterial:SetColor("_BaseColor", self.defaultColors._GadgetMesh_BaseColor)
			elseif self.defaultColors._GadgetMesh_Color and gadgetMaterial:HasProperty("_Color") then
				gadgetMaterial:SetColor("_Color", self.defaultColors._GadgetMesh_Color)
			end

			if gadgetMaterial:HasProperty("_EmissionColor") then
				gadgetMaterial:SetColor("_EmissionColor", Color.black)
			end
		end
	end
end

function M:IsChildOf(childGo, parentGo)
	if not childGo or not parentGo or gCS.LuaUtils.IsNull(childGo) or gCS.LuaUtils.IsNull(parentGo) then
		return false
	end

	local childTransform = childGo.transform

	while childTransform.parent do
		if childTransform.parent.gameObject == parentGo then
			return true
		end

		childTransform = childTransform.parent
	end

	return false
end

function M:IsValidTag(gameObject, validTags)
	if not gameObject or not validTags then
		return false
	end

	local objectTag = gameObject.tag

	if not objectTag then
		return false
	end

	for _, validTag in ipairs(validTags) do
		if objectTag == validTag then
			return true
		end
	end

	return false
end

function M:ShouldCheckCarrySpace()
	if not self.followingFurnitureConfig then
		return false
	end

	return self.followingFurnitureConfig.IsCheckCarrySpace == true
end

function M:CheckCarrySpaceAvailable(centerPosition, hitGameObject)
	if not self.followingFurnitureComponent or not self.followingFurnitureComponent.boundsBox then
		print_warn("FurnitureManager: 无法获取家具包围盒，跳过空间检测")

		return true
	end

	local bounds = self.followingFurnitureComponent.boundsBox
	local halfSizeX = bounds.size.x * 0.5
	local halfSizeZ = bounds.size.z * 0.5
	local corners = {
		Vector3.New(-halfSizeX, 0, -halfSizeZ),
		Vector3.New(halfSizeX, 0, -halfSizeZ),
		Vector3.New(halfSizeX, 0, halfSizeZ),
		Vector3.New(-halfSizeX, 0, halfSizeZ)
	}

	for i, cornerOffset in ipairs(corners) do
		local cornerWorldOffset = self.followingFurniture.transform:TransformVector(cornerOffset)
		local cornerWorldPos = Vector3.New(centerPosition.x + cornerWorldOffset.x, centerPosition.y + 0.1, centerPosition.z + cornerWorldOffset.z)
		local raycastDistance = 1
		local defaultLayer = LX6.Constants.LayerConstants.Default or 0
		local layerMask = gFurnitureUtils:GetMask({
			defaultLayer
		})
		local hitCount = CSFurnitureManager.RayCastNonAlloc(cornerWorldPos, Vector3.down, raycastDistance, nil, layerMask, true, 1)

		if hitCount > 0 then
			local cornerHitInfo = CSFurnitureManager.SortedRayCastList[0]
			local cornerHitGameObject = cornerHitInfo.collider.gameObject

			if not gFurnitureUtils:IsCarryFurnitureTag(cornerHitGameObject.tag) or cornerHitGameObject ~= hitGameObject then
				return false
			end
		else
			return false
		end
	end

	return true
end

function M:GetValidTagsForLayer(hitLayer, adsorptionType)
	local IsAdsorptOnItem = self.followingFurnitureConfig and self.followingFurnitureConfig.IsAdsorptOnItem
	local defaultLayer = LX6.Constants.LayerConstants.Default or 0

	if hitLayer == defaultLayer and IsAdsorptOnItem then
		return CarryItemTagList
	end

	local validTags = AdsorptionTypeToTagList[adsorptionType]

	if not validTags then
		return nil
	end

	if IsAdsorptOnItem then
		local extendedTags = {}

		for i, tag in ipairs(validTags) do
			extendedTags[i] = tag
		end

		table.insert(extendedTags, carryTag)

		return extendedTags
	end

	return validTags
end

function M:GetMultiLayerRaycastPosition(layerMask, initAtScreenCenter)
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return nil, nil, nil
	end

	local cameraForward = mainCamera.transform.forward
	local cameraUp = mainCamera.transform.up

	if not cameraForward or not cameraUp then
		return nil, nil, nil
	end

	local raycastOrigin, raycastDirection = nil

	if initAtScreenCenter then
		raycastOrigin = mainCamera.transform.position
		raycastDirection = cameraForward
	else
		local touchPos = SGUI.Utils.GetInputCenterPosition()
		local ray = mainCamera:ScreenPointToRay(touchPos)
		raycastOrigin = ray.origin or mainCamera.transform.position
		raycastDirection = ray.direction or cameraForward
	end

	local raycastDistance = 20
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)

	if hitCount > 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local hitLayer = hitInfo.collider.gameObject.layer
			local hitNormal = hitInfo.normal
			local hitGameObject = hitInfo.collider.gameObject
			local adsorptionType = LayerToAdsorptionType[hitLayer]

			if adsorptionType then
				local validTags = self:GetValidTagsForLayer(hitLayer, adsorptionType)

				if self.debugSkipTagCheck or validTags and self:IsValidTag(hitGameObject, validTags) then
					if not gFurnitureUtils:IsCarryFurnitureTag(hitGameObject.tag) or not self:ShouldCheckCarrySpace() or self:CheckCarrySpaceAvailable(hitInfo.point, hitGameObject) then
						self.nowHitGameObject = hitGameObject

						return hitInfo.point, hitLayer, hitNormal
					end
				end
			end
		end
	end

	return Vector3.zero, 8, Vector3.up
end

function M:CancelFurniturePreview()
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法取消")

		return false
	end

	self:ClearFollowingFurniture()
	gFurnitureOperationManager:CancelCurrentOperation()
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)

	return true
end

function M:FinalizeFurniture()
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法固定")

		return false
	end

	local finalPosition = self.followingFurniture.transform.position
	local finalRotation = self.followingFurniture.transform.rotation
	self.isFollowing = false

	if self.previewEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.previewEffectUUID)

		self.previewEffectUUID = nil
	end

	self:ClearBaseMesh()
	self:ClearSurfaceHintMesh()
	self:SpawnFinalFurniture(self.followingFurnitureConfig, finalPosition, finalRotation, self.currentOperationUniqueId)
	self:DestroyFollowingFurniture()

	return true
end

function M:StorageFurniture()
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		print_warn("FurnitureManager: 当前没有预览家具，无法收回")

		return gFurnitureConst.StorageRes.NoFollowingFurniture
	end

	if not self.currentOperationUniqueId or not gFurnitureOperationManager.currentOperation or gFurnitureOperationManager.currentOperation.operationType ~= gFurnitureOperationManager.OperationType.EDIT then
		gFurnitureManager:CancelFurniturePreview()

		return gFurnitureConst.StorageRes.NotInEdit
	end

	local carryUid2GoInfoDict = {}

	if self.carryUid2AdsUidListDict[self.previewOriginalUID] then
		for _, adsUid in ipairs(self.carryUid2AdsUidListDict[self.previewOriginalUID]) do
			local go = self.uid2FurnitureGoDict[adsUid]

			if go and not gCS.LuaUtils.IsNull(go) then
				carryUid2GoInfoDict[adsUid] = {
					position = go.transform.position,
					rotation = go.transform.rotation,
					furnitureId = self:TryGetFurnitureIdFromGo(go),
					uid = adsUid
				}
			end
		end
	end

	gFurnitureOperationManager:ChangeToStorageOperation(carryUid2GoInfoDict)
	gFurnitureOperationManager:EndStorageOperation()

	if self.previewOriginalFurnitureGo and not gCS.LuaUtils.IsNull(self.previewOriginalFurnitureGo) then
		local originalUID = self.previewOriginalUID
		local adsorbedUIDs = {}

		for _, uid in ipairs(self.previewOriginalAdsorbedUIDs) do
			table.insert(adsorbedUIDs, uid)
		end

		gHouseManager:RecordRemovedFurniture(originalUID)

		for _, adsorbedUID in ipairs(adsorbedUIDs) do
			gHouseManager:RecordRemovedFurniture(adsorbedUID)
		end

		local furnitureGo = self.uid2FurnitureGoDict[originalUID]

		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)

			self.uid2FurnitureGoDict[originalUID] = nil
		end

		for _, adsorbedUID in ipairs(adsorbedUIDs) do
			local adsorbedGo = self.uid2FurnitureGoDict[adsorbedUID]

			if adsorbedGo and not gCS.LuaUtils.IsNull(adsorbedGo) then
				GameObject.Destroy(adsorbedGo)

				self.uid2FurnitureGoDict[adsorbedUID] = nil
			end
		end

		self.carryUid2AdsUidListDict[originalUID] = nil

		print_notice(string.format("FurnitureManager: 预览编辑模式收回，已删除原始承载家具[%d]及%d个吸附小家具", originalUID, #adsorbedUIDs))
	end

	self:ClearAllPreviewObjects()
	self:ClearFollowingState()
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_EXIT_EDIT)

	return gFurnitureConst.StorageRes.Success
end

function M:ApplyPreviewToOriginal()
	if not self.isPreviewEditMode or not self.previewOriginalFurnitureGo or not self.followingFurniture then
		print_warn("FurnitureManager: 不是预览编辑模式，无法应用预览")

		return false, nil
	end

	local finalPosition = self.followingFurniture.transform.position
	local finalRotation = self.followingFurniture.transform.rotation
	self.previewOriginalFurnitureGo.transform.position = finalPosition
	self.previewOriginalFurnitureGo.transform.rotation = finalRotation
	local originalUID = self.previewOriginalUID
	local furnitureComponent = self.previewOriginalFurnitureGo:GetComponent(typeof(LX6.GamePlay.House.HouseFurniture))
	local furnitureId = furnitureComponent and furnitureComponent.furnitureId
	local furnitureCfg = furnitureId and HouseFurnitureConfig.GetConfig(furnitureId)

	if furnitureCfg then
		local detectedCarryGameObject = self:DetectCarrySurfaceAtPosition(finalPosition, furnitureCfg)
		self.nowHitGameObject = detectedCarryGameObject
	end

	local root, carryFurnitureUID = self:UpdateFurnitureAdsorptionRelation(self.previewOriginalFurnitureGo, originalUID, nil, true)

	self:ClearAllPreviewObjects()
	self.previewOriginalFurnitureGo:SetActive(true)

	if root then
		self.previewOriginalFurnitureGo.transform:SetParent(root.transform, true)

		if carryFurnitureUID then
			print_debug(string.format("FurnitureManager: 预览编辑完成，家具[%d]已吸附到承载家具[%d]", originalUID, carryFurnitureUID))
		else
			print_debug(string.format("FurnitureManager: 预览编辑完成，家具[%d]已移至根节点", originalUID))
		end
	end

	return true, carryFurnitureUID
end

function M:ClearAllPreviewObjects()
	for previewUID, originalUID in pairs(self.previewAdsorbed2OriginalUID) do
		local previewGo = self.previewUid2GoDict[previewUID]

		if previewGo and not gCS.LuaUtils.IsNull(previewGo) then
			GameObject.Destroy(previewGo)
		end

		self.previewUid2GoDict[previewUID] = nil

		self:RemoveAdsorptionRelation(previewUID)
	end

	self:DestroyFollowingFurniture()
end

function M:DetectCarrySurfaceAtPosition(position, furnitureCfg)
	if not furnitureCfg or not furnitureCfg.AdsorptionTypeFinal then
		return nil
	end

	local originalHitGameObject = self.nowHitGameObject
	local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)
	local raycastOrigin = Vector3.New(position.x, position.y + 0.1, position.z)
	local raycastDirection = Vector3.down
	local raycastDistance = 2
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)
	local detectedCarryGameObject = nil

	if hitCount > 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local hitGameObject = hitInfo.collider.gameObject

			if gFurnitureUtils:IsCarryFurnitureTag(hitGameObject.tag) then
				detectedCarryGameObject = hitGameObject

				break
			end
		end
	end

	self.nowHitGameObject = originalHitGameObject

	return detectedCarryGameObject
end

function M:UpdateFurnitureAdsorptionRelation(furnitureGo, uid, carrySurfaceUID, useDetected)
	local root = self:GetFurnitureRoot()
	local actualCarryUID = carrySurfaceUID

	if not actualCarryUID and useDetected and self.nowHitGameObject and gFurnitureUtils:IsCarryFurnitureTag(self.nowHitGameObject.tag) then
		actualCarryUID = gFurnitureUtils:GetCarryFurnitureUID(self.nowHitGameObject)
	end

	if actualCarryUID then
		local carryFurnitureGo = self.uid2FurnitureGoDict[actualCarryUID]

		if carryFurnitureGo and not gCS.LuaUtils.IsNull(carryFurnitureGo) then
			self:RemoveAdsorptionRelation(uid)
			self:AddAdsorptionRelation(actualCarryUID, uid)

			root = carryFurnitureGo
		else
			actualCarryUID = nil
		end
	else
		self:RemoveAdsorptionRelation(uid)
	end

	return root, actualCarryUID
end

function M:SpawnFinalFurniture(furnitureCfg, position, rotation, uid)
	if self.isPreviewEditMode then
		local success, carryFurnitureUID = self:ApplyPreviewToOriginal()

		if success then
			local parentClientUID = carryFurnitureUID
			local rotationEuler = rotation.eulerAngles

			gHouseManager:RecordChangedFurniture(self.previewOriginalUID, position, rotationEuler, parentClientUID)
			gFurnitureOperationManager:EndOperation(self.previewOriginalFurnitureGo, carryFurnitureUID)
			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
			self:ClearFollowingState()
		else
			print_error("FurnitureManager: 应用预览失败")
		end

		return
	end

	local furnitureId = furnitureCfg.Id

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			furnitureGo.transform.position = position
			furnitureGo.transform.rotation = rotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, uid, true)

			self:SetHouseFurnitureFields(furnitureGo, uid, furnitureId)

			local root, carryFurnitureUID = self:UpdateFurnitureAdsorptionRelation(furnitureGo, uid, nil, true)

			furnitureGo.transform:SetParent(root.transform, true)

			local parentClientUID = carryFurnitureUID
			local rotationEuler = rotation.eulerAngles

			gHouseManager:RecordAddedFurniture(uid, furnitureId, position, rotationEuler, parentClientUID)
			gFurnitureOperationManager:EndOperation(furnitureGo, carryFurnitureUID)
			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)
			self:ClearFollowingState()
		else
			print_error(string.format("FurnitureManager: 重新生成家具失败 [%s] 路径:%s", furnitureCfg.Name or "未知", furnitureCfg.ModelName))
		end
	end)
end

function M:ClearFollowingFurniture()
	if self.isPreviewEditMode and self.previewOriginalFurnitureGo and not gCS.LuaUtils.IsNull(self.previewOriginalFurnitureGo) then
		self.previewOriginalFurnitureGo:SetActive(true)
		print_notice(string.format("FurnitureManager: 恢复原始家具显示，UID: %s", tostring(self.previewOriginalUID)))
	end

	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		self:ClearAllPreviewObjects()
	end

	self:ClearFollowingState()
end

function M:ClearFollowingState()
	if self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
		self:RestoreMaterialColors(self.followingFurniture)
	end

	if self.previewEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.previewEffectUUID)

		self.previewEffectUUID = nil
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
	self.nowSurfaceBounds = nil
	self.followingFurnitureManualRotation = 0
	self.previewOriginalFurnitureGo = nil
	self.previewOriginalUID = nil
	self.previewOriginalAdsorbedUIDs = {}
	self.previewAdsorbed2OriginalUID = {}
	self.isPreviewEditMode = false
	self.isLongPressing = false
	self.canFollow = false
	self.currentOperationUniqueId = nil
end

function M:SetFurnitureInteractionEnabled(furnitureGo, enabled)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		return
	end

	local targetLayer = enabled and LX6.Constants.LayerConstants.Default or LX6.Constants.LayerConstants.IgnoreRaycast

	self:SetGameObjectLayer(furnitureGo, targetLayer)

	local colliders = furnitureGo:GetComponentsInChildren(typeof(UnityEngine.Collider))

	if colliders then
		for i = 0, colliders.Length - 1 do
			local collider = colliders[i]

			if collider then
				collider.enabled = enabled
			end
		end
	end

	local rigidbodies = furnitureGo:GetComponentsInChildren(typeof(UnityEngine.Rigidbody))

	if rigidbodies then
		for i = 0, rigidbodies.Length - 1 do
			local rb = rigidbodies[i]

			if rb then
				rb.isKinematic = not enabled
			end
		end
	end
end

function M:SetGameObjectLayer(gameObject, layer)
	if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
		return
	end

	gameObject.layer = layer
	local transform = gameObject.transform

	for i = 0, transform.childCount - 1 do
		local child = transform:GetChild(i)

		if child and child.gameObject then
			self:SetGameObjectLayer(child.gameObject, layer)
		end
	end
end

function M:RotateFollowingFurniture45()
	if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		print_warn("FurnitureManager: 当前没有预览家具，无法旋转")

		return
	end

	self.followingFurnitureManualRotation = self.followingFurnitureManualRotation + 45

	if self.followingFurnitureManualRotation >= 360 then
		self.followingFurnitureManualRotation = self.followingFurnitureManualRotation - 360
	end

	if self.nowHitLayer and self.nowHitNormal then
		local currentPosition = self.followingFurniture.transform.position
		local baseRotation = self:GetBaseRotationForManualRotation()
		local adjustedPosition, adjustedRotation = self:AdjustFurniturePosition(currentPosition, baseRotation)
		self.followingFurniture.transform.rotation = adjustedRotation
	else
		print_warn("FurnitureManager: 缺少命中层级或法线信息，无法进行旋转更新")
	end
end

function M:CheckMouseHitPreviewFurniture()
	if not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
		return false
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return false
	end

	local touchPos = SGUI.Utils.GetInputCenterPosition()

	if not touchPos then
		return false
	end

	local colliders = self.followingFurniture:GetComponentsInChildren(typeof(UnityEngine.Collider), true)
	local originalStates = {}

	if colliders then
		for i = 0, colliders.Length - 1 do
			local collider = colliders[i]

			if collider then
				originalStates[i] = collider.enabled
				collider.enabled = true
			end
		end
	end

	local ray = mainCamera:ScreenPointToRay(touchPos)
	local raycastOrigin = ray.origin or mainCamera.transform.position
	local raycastDirection = ray.direction or mainCamera.transform.forward
	local raycastDistance = 50
	local layerMask = gFurnitureUtils:GetMask({
		LX6.Constants.LayerConstants.IgnoreRaycast
	})
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)
	local hitResult = false

	if hitCount > 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local hitGo = hitInfo.collider.gameObject

			if hitGo == self.followingFurniture then
				hitResult = true

				break
			end

			if self:IsChildOf(hitGo, self.followingFurniture) then
				hitResult = true

				break
			end

			if self.baseMeshGo and not gCS.LuaUtils.IsNull(self.baseMeshGo) and hitGo == self.baseMeshGo then
				hitResult = true

				break
			end
		end
	end

	if colliders then
		for i = 0, colliders.Length - 1 do
			local collider = colliders[i]

			if collider and originalStates[i] ~= nil then
				collider.enabled = originalStates[i]
			end
		end
	end

	return hitResult
end

function M:SetEditPlacedFurnitureMode(enabled)
	self.canEditPlacedFurniture = enabled

	if enabled then
		gLuaClient:RegisterDynamicUpdate("FurnitureManager", self)
	else
		gLuaClient:UnregisterDynamicUpdate("FurnitureManager")
		self:ClearHoveredFurniture()
	end
end

function M:OnLongPressFullScreenBtn(isPress)
	if isPress then
		if not self.isFollowing or not self.followingFurniture or gCS.LuaUtils.IsNull(self.followingFurniture) then
			self:CheckClickedPlacedFurniture()

			if self.isFollowing then
				self.canFollow = true
				self.isLongPressing = true
			end
		elseif self.isFollowing and self.followingFurniture and not gCS.LuaUtils.IsNull(self.followingFurniture) then
			local hitFurniture = self:CheckMouseHitPreviewFurniture()
			self.canFollow = hitFurniture
			self.isLongPressing = true

			return hitFurniture
		end
	else
		self.canFollow = false
		self.isLongPressing = false
	end
end

function M:TryGetFurnitureIdFromGo(go)
	local furnitureComp = go:GetComponent(typeof(CSFurnitureMono))

	if furnitureComp and furnitureComp.furnitureId then
		return furnitureComp.furnitureId
	end

	return nil
end

function M:TryGetFurnitureGoFromId(uid)
	return self.uid2FurnitureGoDict[uid]
end

function M:CheckClickedPlacedFurniture()
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return
	end

	local touchPos = SGUI.Utils.GetInputCenterPosition()

	if not touchPos then
		return
	end

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), true)

	local ray = mainCamera:ScreenPointToRay(touchPos)
	local raycastOrigin = ray.origin or mainCamera.transform.position
	local raycastDirection = ray.direction or mainCamera.transform.forward
	local raycastDistance = 50
	local layerMask = -1
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), false)

	if hitCount > 0 then
		for i = 0, math.min(hitCount, 1) do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]

			if not hitInfo or not hitInfo.collider then
				print_warn("FurnitureManager: 射线检测结果无效")
			else
				local hitGo = hitInfo.collider.gameObject
				local furnitureRoot, furnitureId = self:FindFurnitureRootFromHitObject(hitGo)

				if furnitureRoot and furnitureId then
					self:StartEditingPlacedFurniture(furnitureRoot, furnitureId)

					return
				end
			end
		end
	end
end

function M:FindFurnitureRootFromHitObject(hitGo)
	if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
		return nil, nil
	end

	local currentGo = hitGo
	local maxDepth = 10
	local depth = 0

	while currentGo and not gCS.LuaUtils.IsNull(currentGo) and depth < maxDepth do
		local furnitureId = self:TryGetFurnitureIdFromGo(currentGo)

		if furnitureId then
			return currentGo, furnitureId
		end

		local transform = currentGo.transform

		if transform and transform.parent then
			currentGo = transform.parent.gameObject
			depth = depth + 1
		else
			break
		end
	end

	if maxDepth <= depth then
		print_warn("FurnitureManager: 遍历父物体层级达到最大深度，停止查找")
	end

	return nil, nil
end

function M:SmartRaycastForFurniture(furnitureCfg, position, originalRotation)
	local isWallFurniture = false
	local isCeilingFurniture = false

	if furnitureCfg and furnitureCfg.AdsorptionTypeFinal then
		for _, adsorptionType in ipairs(furnitureCfg.AdsorptionTypeFinal) do
			if adsorptionType == AdsorptionType.Wall then
				isWallFurniture = true
			elseif adsorptionType == AdsorptionType.Ceiling then
				isCeilingFurniture = true
			end
		end
	end

	if isWallFurniture then
		local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)
		local detectedNormal = gFurnitureUtils:DetectWallNormalAtPositionSmart(position, layerMask, originalRotation)

		if detectedNormal then
			local surfaceBounds = nil

			if CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] and CSFurnitureManager.SortedRayCastList[0].collider then
				surfaceBounds = CSFurnitureManager.SortedRayCastList[0].collider.bounds
			end

			return 16, detectedNormal, surfaceBounds
		else
			return 16, Vector3.forward, nil
		end
	elseif isCeilingFurniture then
		local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)
		local raycastOrigin = Vector3.New(position.x, position.y - 0.1, position.z)
		local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, Vector3.up, 2, nil, layerMask, true, 1)

		if hitCount > 0 then
			local hitInfo = CSFurnitureManager.SortedRayCastList[0]
			local surfaceBounds = hitInfo.collider.bounds

			return hitInfo.collider.gameObject.layer, hitInfo.normal, surfaceBounds
		else
			return 27, Vector3.down, nil
		end
	else
		local layerMask = self:GetFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal)
		local raycastOrigin = Vector3.New(position.x, position.y + 0.1, position.z)
		local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, Vector3.down, 2, nil, layerMask, true, 1)

		if hitCount > 0 then
			local hitInfo = CSFurnitureManager.SortedRayCastList[0]
			local surfaceBounds = hitInfo.collider.bounds

			return hitInfo.collider.gameObject.layer, hitInfo.normal, surfaceBounds
		else
			return 8, Vector3.up, nil
		end
	end
end

function M:StartEditingPlacedFurniture(placedFurnitureGo, furnitureId)
	if not placedFurnitureGo or gCS.LuaUtils.IsNull(placedFurnitureGo) then
		print_error("FurnitureManager: 要编辑的家具对象无效")

		return
	end

	self:ClearHoveredFurniture()

	local placedFurnitureComp = placedFurnitureGo:GetComponent(typeof(CSFurnitureMono))
	self.currentOperationUniqueId = placedFurnitureComp.uid

	if not self.currentOperationUniqueId then
		print_error("FurnitureManager: 无法提取唯一ID: " .. placedFurnitureGo.name)

		return
	end

	local carrySurfaceUID = self:GetAdsorptionSurfaceGoUid(self.currentOperationUniqueId)
	local success = gFurnitureOperationManager:BeginEditOperation(furnitureId, placedFurnitureGo, self.currentOperationUniqueId, carrySurfaceUID)

	if not success then
		print_error("FurnitureManager: 无法开始编辑操作记录")

		return
	end

	local originalPosition = placedFurnitureGo.transform.position
	local originalRotation = placedFurnitureGo.transform.rotation
	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)
	self.followingFurnitureId = furnitureId
	self.followingFurnitureConfig = furnitureCfg
	self.isFollowing = true
	self.isLongPressing = false
	self.canFollow = false
	local hitLayer, hitNormal, surfaceBounds = self:SmartRaycastForFurniture(furnitureCfg, originalPosition, originalRotation)
	self.nowHitLayer = hitLayer
	self.nowHitNormal = hitNormal

	if surfaceBounds then
		self.nowSurfaceBounds = surfaceBounds
	end

	self.followingFurnitureManualRotation = self:CalculateCorrectManualRotation(originalPosition, originalRotation, furnitureCfg)

	self:CreateFullPreviewForEdit(placedFurnitureGo, self.currentOperationUniqueId, furnitureCfg, originalPosition, originalRotation)

	if self.surfaceHintMeshEnabled then
		local adsorptionType = LayerToAdsorptionType[hitLayer] or AdsorptionType.Floor

		self:GenerateSurfaceHintMesh(self.nowSurfaceBounds, adsorptionType, hitNormal)
	end
end

function M:IsRealFollowing()
	return self.canFollow
end

function M:SpawnFurnitureFromServerData(furnitureId, position, rotation, uid, gadgetInstanceId, carrySurfaceUID)
	local oldGo = nil

	if self.uid2FurnitureGoDict[uid] then
		oldGo = self.uid2FurnitureGoDict[uid]
	end

	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)

	if string.is_null_or_empty(furnitureCfg.ModelName) then
		print_error("#NoCreateIssue FurnitureManager: 家具配置错误，无法生成家具" .. tostring(furnitureId))

		return
	end

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local furnitureGo = GameObject.Instantiate(loadOp.asset)
			furnitureGo.transform.position = position
			furnitureGo.transform.eulerAngles = rotation
			furnitureGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, uid, true)

			self:SetHouseFurnitureFields(furnitureGo, uid, furnitureId)
			gFurnitureUtils:TrySetGadgetInstanceId(furnitureGo, gadgetInstanceId)

			local root, actualCarryUID = self:UpdateFurnitureAdsorptionRelation(furnitureGo, uid, carrySurfaceUID, false)

			furnitureGo.transform:SetParent(root.transform, true)

			if oldGo and not gCS.LuaUtils.IsNull(oldGo) then
				GameObject.Destroy(oldGo)
			end
		else
			print_error(string.format("FurnitureManager: 重新生成家具失败 [%s] 路径:%s", furnitureCfg.Name or "未知", furnitureCfg.ModelName))
		end
	end)
end

function M:DestroyFollowingFurniture()
	GameObject.Destroy(self.followingFurniture)

	self.followingFurniture = nil
	self.followingFurnitureComponent = nil
end

function M:RemoveExistFurniture(uid)
	if not uid or not self.uid2FurnitureGoDict[uid] then
		print_warn("FurnitureManager: 无效的家具UID，无法移除家具")

		return false
	end

	local isStorageOperation = gFurnitureOperationManager.currentOperation and gFurnitureOperationManager.currentOperation.operationType == gFurnitureOperationManager.OperationType.STORAGE

	if not isStorageOperation then
		gHouseManager:RecordRemovedFurniture(uid)
	end

	local adsorbedUIDs = self.carryUid2AdsUidListDict[uid] or {}

	if #adsorbedUIDs > 0 then
		for _, adsorbedUID in ipairs(adsorbedUIDs) do
			self:RemoveExistFurniture(adsorbedUID)
		end

		self.carryUid2AdsUidListDict[uid] = nil
	end

	self:RemoveAdsorptionRelation(uid)

	local furnitureGo = self.uid2FurnitureGoDict[uid]

	if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
		GameObject.Destroy(furnitureGo)

		self.uid2FurnitureGoDict[uid] = nil
	else
		print_warn("FurnitureManager: 尝试删除的家具不存在或已被销毁，UID: " .. tostring(uid))
	end

	return true
end

function M:RemoveAllFurniture()
	for uid, furnitureGo in pairs(self.uid2FurnitureGoDict) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)
		end
	end

	self.uid2FurnitureGoDict = {}
end

function M:StorageAllFurniture()
	if not next(self.uid2FurnitureGoDict) then
		return gFurnitureConst.StorageRes.Success
	end

	local allFurnitureStates = {}

	for uid, furnitureGo in pairs(self.uid2FurnitureGoDict) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			local furnitureId = self:TryGetFurnitureIdFromGo(furnitureGo)
			local carrySurfaceUID = self:GetAdsorptionSurfaceGoUid(uid)
			allFurnitureStates[uid] = {
				furnitureId = furnitureId,
				position = furnitureGo.transform.position,
				rotation = furnitureGo.transform.rotation,
				carrySurfaceUID = carrySurfaceUID or 0
			}
		end
	end

	if not gFurnitureOperationManager:BeginStorageAllOperation(allFurnitureStates) then
		return gFurnitureConst.StorageRes.NotInEdit
	end

	local allFurnitureUIDs = {}

	for uid, _ in pairs(self.uid2FurnitureGoDict) do
		table.insert(allFurnitureUIDs, uid)
	end

	local carryFurnitureUIDs = {}
	local independentFurnitureUIDs = {}

	for _, uid in ipairs(allFurnitureUIDs) do
		if self.carryUid2AdsUidListDict[uid] and #self.carryUid2AdsUidListDict[uid] > 0 then
			table.insert(carryFurnitureUIDs, uid)
		else
			local isAdsorbed = false

			for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
				for _, adsorbedUID in ipairs(adsorbedList) do
					if adsorbedUID == uid then
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
		if self.uid2FurnitureGoDict[carryUID] then
			local adsorbedUIDs = self.carryUid2AdsUidListDict[carryUID] or {}

			gHouseManager:RecordRemovedFurniture(carryUID)

			for _, adsorbedUID in ipairs(adsorbedUIDs) do
				if self.uid2FurnitureGoDict[adsorbedUID] then
					gHouseManager:RecordRemovedFurniture(adsorbedUID)
				end
			end

			self:RemoveExistFurniture(carryUID)
		end
	end

	for _, uid in ipairs(independentFurnitureUIDs) do
		if self.uid2FurnitureGoDict[uid] then
			gHouseManager:RecordRemovedFurniture(uid)
			self:RemoveExistFurniture(uid)
		end
	end

	self.carryUid2AdsUidListDict = {}

	for uid, furnitureGo in pairs(self.uid2FurnitureGoDict) do
		if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
			GameObject.Destroy(furnitureGo)
		end
	end

	self.uid2FurnitureGoDict = {}

	gFurnitureOperationManager:EndStorageAllOperation()
	gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_OPERATION_CHANGED)

	return gFurnitureConst.StorageRes.Success
end

function M:SetHouseFurnitureFields(furnitureGo, uid, furnitureId)
	if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
		print_warn("FurnitureManager: 无效的家具对象，无法设置HouseFurniture字段")

		return
	end

	self.uid2FurnitureGoDict[uid] = furnitureGo
	local houseFurnitureComponent = furnitureGo:GetComponent(typeof(CSFurnitureMono))

	if houseFurnitureComponent then
		if uid and type(uid) == "number" then
			houseFurnitureComponent.uid = uid
		else
			print_warn(string.format("FurnitureManager: 无效的UID类型[%s]，期望number类型", type(uid)))
		end

		houseFurnitureComponent.furnitureId = furnitureId
	else
		print_warn(string.format("FurnitureManager: 家具对象[%s]缺少HouseFurniture组件，无法设置字段", furnitureGo.name))
	end
end

function M:AddAdsorptionRelation(carryUID, adsorbedUID)
	if not carryUID or not adsorbedUID then
		return
	end

	if not self.carryUid2AdsUidListDict[carryUID] then
		self.carryUid2AdsUidListDict[carryUID] = {}
	end

	for _, uid in ipairs(self.carryUid2AdsUidListDict[carryUID]) do
		if uid == adsorbedUID then
			return
		end
	end

	table.insert(self.carryUid2AdsUidListDict[carryUID], adsorbedUID)
end

function M:RemoveAdsorptionRelation(adsorbedUID)
	if not adsorbedUID then
		return nil
	end

	for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
		for i, uid in ipairs(adsorbedList) do
			if uid == adsorbedUID then
				table.remove(adsorbedList, i)

				return carryUID
			end
		end
	end

	return nil
end

function M:GetAdsorptionSurfaceGoUid(adsorbedUID)
	if not adsorbedUID then
		return nil
	end

	for carryUID, adsorbedList in pairs(self.carryUid2AdsUidListDict) do
		for _, uid in ipairs(adsorbedList) do
			if uid == adsorbedUID then
				return carryUID
			end
		end
	end

	return nil
end

function M:CreatePreviewAdsorbedFurniture(originalUID, previewParentGo)
	if not originalUID or not previewParentGo then
		return nil
	end

	local originalGo = self.uid2FurnitureGoDict[originalUID]

	if not originalGo or gCS.LuaUtils.IsNull(originalGo) then
		print_warn("FurnitureManager: 创建预览小家具失败，找不到原始家具: " .. tostring(originalUID))

		return nil
	end

	local furnitureId = self:TryGetFurnitureIdFromGo(originalGo)
	local furnitureCfg = HouseFurnitureConfig.GetConfig(furnitureId)
	local localPosition = originalGo.transform.localPosition
	local localRotation = originalGo.transform.localRotation
	local previewUID = self:GeneratePreviewChildUniqueId()

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local previewGo = GameObject.Instantiate(loadOp.asset)

			previewGo.transform:SetParent(previewParentGo.transform, false)

			previewGo.transform.localPosition = localPosition
			previewGo.transform.localRotation = localRotation
			previewGo.name = gFurnitureUtils:BuildFurnitureName(furnitureId, furnitureCfg.Name, previewUID, false)

			self:SetFurnitureInteractionEnabled(previewGo, false)

			self.previewUid2GoDict[previewUID] = previewGo

			self:AddAdsorptionRelation(self.currentOperationUniqueId, previewUID)
			gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "furniturePreview_Adsorbed_" .. originalUID .. tostring(furnitureId), previewGo)

			self.previewAdsorbed2OriginalUID[previewUID] = originalUID
		end
	end)

	return previewUID
end

function M:CreateFullPreviewForEdit(originalFurnitureGo, originalUID, furnitureCfg, originalPosition, originalRotation)
	originalFurnitureGo:SetActive(false)

	self.previewOriginalFurnitureGo = originalFurnitureGo
	self.previewOriginalUID = originalUID
	self.previewOriginalAdsorbedUIDs = {}
	self.isPreviewEditMode = true
	local adsorbedUIDs = self.carryUid2AdsUidListDict[originalUID] or {}

	for _, adsorbedUID in ipairs(adsorbedUIDs) do
		table.insert(self.previewOriginalAdsorbedUIDs, adsorbedUID)
	end

	gResourceManager:LoadAssetWithCallBack(furnitureCfg.ModelName, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			local previewFurnitureGo = GameObject.Instantiate(loadOp.asset)
			previewFurnitureGo.transform.position = originalPosition
			previewFurnitureGo.transform.rotation = originalRotation
			previewFurnitureGo.name = gFurnitureUtils:BuildFurnitureName(self.followingFurnitureId, furnitureCfg.Name, self.currentOperationUniqueId, false)

			self:SetFurnitureInteractionEnabled(previewFurnitureGo, false)

			self.followingFurniture = previewFurnitureGo
			self.followingFurnitureComponent = previewFurnitureGo:GetComponent(typeof(CSFurnitureMono))
			self.previewEffectUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "furniturePreview_" .. tostring(self.followingFurnitureId), self.followingFurnitureComponent.meshObject)
			local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor
			local hitNormal = self.nowHitNormal or Vector3.up

			self:GenerateBaseMesh(furnitureCfg, adsorptionType, hitNormal)
			self:CreateMaterialInstances(previewFurnitureGo)

			local isColliding = self:CheckFurnitureCollision()

			self:SetFurnitureColor(previewFurnitureGo, isColliding)

			for _, originalAdsorbedUID in ipairs(self.previewOriginalAdsorbedUIDs) do
				self:CreatePreviewAdsorbedFurniture(originalAdsorbedUID, previewFurnitureGo)
			end

			gMessageManager:SendMessage(gEventConstants.HOME_FURNITURE_ENTER_EDIT)
		end
	end)
end

function M:SetDebugSkipTagCheck(enable)
	self.debugSkipTagCheck = enable
end

function M:CheckStorageFurnitureHasAdsFurniture()
	if not self.isFollowing or not self.followingFurniture or not self.followingFurnitureConfig then
		return false
	end

	if not self.currentOperationUniqueId or not gFurnitureOperationManager.currentOperation or gFurnitureOperationManager.currentOperation.operationType ~= gFurnitureOperationManager.OperationType.EDIT then
		return false
	end

	local adsList = self.carryUid2AdsUidListDict[self.previewOriginalUID]

	if not adsList or #adsList == 0 then
		return false
	end

	return true
end

function M:CheckHoveredFurniture()
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		self:ClearHoveredFurniture()

		return
	end

	local touchPos = SGUI.Utils.GetInputCenterPosition()

	if not touchPos then
		self:ClearHoveredFurniture()

		return
	end

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), true)

	local ray = mainCamera:ScreenPointToRay(touchPos)
	local raycastOrigin = ray.origin or mainCamera.transform.position
	local raycastDirection = ray.direction or mainCamera.transform.forward
	local raycastDistance = 50
	local layerMask = 1
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)

	CSFurnitureManager.EnableAllBoundsBox(self:GetFurnitureRoot(), false)

	local foundFurniture = false

	if hitCount > 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local hitGo = hitInfo.collider.gameObject
			local furnitureRoot, furnitureId = self:FindFurnitureRootFromHitObject(hitGo)

			if furnitureRoot and furnitureId then
				local furnitureComponent = furnitureRoot:GetComponent(typeof(CSFurnitureMono))
				local uid = furnitureComponent and furnitureComponent.uid

				if uid then
					self:SetHoveredFurniture(furnitureRoot, uid)

					foundFurniture = true

					break
				end
			end
		end
	end

	if not foundFurniture then
		self:ClearHoveredFurniture()
	end
end

function M:SetHoveredFurniture(furnitureGo, uid)
	if self.hoveredFurnitureGo == furnitureGo and self.hoveredFurnitureUID == uid then
		return
	end

	self:ClearHoveredFurniture()

	self.hoveredFurnitureGo = furnitureGo
	self.hoveredFurnitureUID = uid

	if furnitureGo and not gCS.LuaUtils.IsNull(furnitureGo) then
		self.hoverEffectUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, "furnitureHover_" .. tostring(uid), furnitureGo)
	end
end

function M:ClearHoveredFurniture()
	if self.hoverEffectUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.hoverEffectUUID)

		self.hoverEffectUUID = nil
	end

	self.hoveredFurnitureGo = nil
	self.hoveredFurnitureUID = nil
end

function M:CalculateCorrectManualRotation(originalPosition, originalRotation, furnitureCfg)
	if not furnitureCfg or not furnitureCfg.AdsorptionTypeFinal then
		return originalRotation.eulerAngles.y
	end

	local isWallFurniture = false

	for _, adsorptionType in ipairs(furnitureCfg.AdsorptionTypeFinal) do
		if adsorptionType == AdsorptionType.Wall then
			isWallFurniture = true

			break
		end
	end

	if not isWallFurniture then
		return originalRotation.eulerAngles.y
	end

	if self.followingFurnitureManualRotation and self.followingFurnitureManualRotation ~= 0 then
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

function M:GetBaseRotationForManualRotation()
	local adsorptionType = LayerToAdsorptionType[self.nowHitLayer] or AdsorptionType.Floor

	if adsorptionType == AdsorptionType.Floor or adsorptionType == AdsorptionType.Ceiling then
		local defaultY = gHouseManager:GetNowBuildDefaultTowards()

		return Quaternion.Euler(0, defaultY, 0)
	elseif adsorptionType == AdsorptionType.Wall then
		if self.nowHitNormal and self.nowHitNormal ~= Vector3.zero then
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

gFurnitureManager = M.New()
