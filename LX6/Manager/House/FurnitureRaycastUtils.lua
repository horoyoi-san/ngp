-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureRaycastUtils.lua
-- Decompiled from: 00737_FurnitureRaycastUtils.lua_76317240fa17.luajit

local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
local AdsorptionTypeToTagList = gFurnitureConst.AdsorptionTypeToTagList
local carryTag = gFurnitureConst.carryTag
local CarryItemTagList = {
	carryTag
}
local FurnitureRaycastUtils = {
	IsChildOf = function (self, childGo, parentGo)
		if not childGo or not parentGo or gCS.LuaUtils.IsNull(childGo) or gCS.LuaUtils.IsNull(parentGo) then
			return false
		end

		return childGo.transform:IsChildOf(parentGo.transform)
	end,
	IsValidTagByTag = function (self, objectTag, objectExtraTag, validTags)
		if not validTags then
			return false
		end

		if not objectTag and not objectExtraTag then
			return false
		end

		for _, validTag in ipairs(validTags) do
			if objectTag ~= validTag or objectExtraTag ~= validTag then
				return true
			end
		end

		return false
	end,
	GetColliderHitInfo = function (self, collider)
		if not collider then
			return nil, , , 
		end

		local layer = gCS.LuaUtils.GetColliderLayer(collider)
		local objectTag, objectExtraTag = gCS.LuaUtils.GetColliderTags(collider, "")
		local hitGo = gCS.LuaUtils.GetColliderGameObject(collider)

		if hitGo and gCS.LuaUtils.IsNull(hitGo) then
			hitGo = nil
		end

		if layer ~= -1 then
			return nil, , , 
		end

		return layer, objectTag, hitGo, objectExtraTag
	end,
	GetFurnitureLayerMask = function (self, adsorptionTypes, isAdsorptOnItem)
		local layers = {}

		for i, adsorptionType in ipairs(adsorptionTypes) do
			local layer = 0

			if adsorptionType ~= AdsorptionType.Floor then
				layer = LX6.Constants.LayerConstants.Floor or 8
			elseif adsorptionType ~= AdsorptionType.Ceiling then
				layer = 27

				if 27 then
					layer = LX6.Constants.LayerConstants._Ceiling
				end
			elseif adsorptionType ~= AdsorptionType.Wall then
				layer = LX6.Constants.LayerConstants.Wall or 16
			else
				print_notice("FurnitureRaycastUtils: 未知的吸附类型: " .. tostring(adsorptionType) .. "，跳过")
			end

			table.insert(layers, layer)
		end

		if isAdsorptOnItem then
			local defaultLayer = LX6.Constants.LayerConstants.Default or 0

			table.insert(layers, defaultLayer)
		end

		local layerMask = gFurnitureUtils:GetMask(layers)

		return layerMask
	end
}

FurnitureRaycastUtils.GetValidTagsForLayer = function(self, hitLayer, adsorptionType, isAdsorptOnItem)
	local defaultLayer = LX6.Constants.LayerConstants.Default or 0

	if hitLayer ~= defaultLayer and isAdsorptOnItem then
		return CarryItemTagList
	end

	local validTags = AdsorptionTypeToTagList[adsorptionType]

	if not validTags then
		return nil
	end

	if isAdsorptOnItem then
		local extendedTags = {}

		for i, tag in ipairs(validTags) do
			extendedTags[i] = tag
		end

		table.insert(extendedTags, carryTag)

		return extendedTags
	end

	return validTags
end

FurnitureRaycastUtils.ShouldCheckCarrySpace = function(self, furnitureConfig)
	if not furnitureConfig then
		return false
	end

	return furnitureConfig.IsCheckCarrySpace ~= true
end

FurnitureRaycastUtils.CheckCarrySpaceAvailable = function(self, centerPosition, hitGameObject, followingFurniture, followingFurnitureComponent)
	if not followingFurnitureComponent or not followingFurnitureComponent.boundsBox then
		print_warn("FurnitureRaycastUtils: 无法获取家具包围盒，跳过空间检测")

		return true
	end

	local bounds = followingFurnitureComponent.boundsBox
	local halfSizeX = bounds.size.x * 0.5
	local halfSizeZ = bounds.size.z * 0.5
	local corners = {
		Vector3.New(-halfSizeX, 0, -halfSizeZ),
		Vector3.New(halfSizeX, 0, -halfSizeZ),
		Vector3.New(halfSizeX, 0, halfSizeZ),
		Vector3.New(-halfSizeX, 0, halfSizeZ)
	}

	for i, cornerOffset in ipairs(corners) do
		local cornerWorldOffset = followingFurniture.transform:TransformVector(cornerOffset)
		local cornerWorldPos = Vector3.New(centerPosition.x + cornerWorldOffset.x, centerPosition.y + 0.1, centerPosition.z + cornerWorldOffset.z)
		local raycastDistance = 1
		local defaultLayer = LX6.Constants.LayerConstants.Default or 0
		local layerMask = gFurnitureUtils:GetMask({
			defaultLayer
		})
		local hitCount = CSFurnitureManager.RayCastNonAlloc(cornerWorldPos, Vector3.down, raycastDistance, nil, layerMask, true, 1)

		if hitCount <= 0 then
			local cornerHitInfo = CSFurnitureManager.SortedRayCastList[0]
			local _, cornerHitTag, cornerHitGameObject, cornerHitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(cornerHitInfo.collider)

			if not gFurnitureUtils:IsCarryFurnitureTag(cornerHitTag, cornerHitExtraTag) or cornerHitGameObject == hitGameObject then
				return false
			end
		else
			return false
		end
	end

	return true
end

FurnitureRaycastUtils.GetMultiLayerRaycastPosition = function(self, layerMask, initAtScreenCenter, followingFurnitureConfig, followingFurniture, followingFurnitureComponent, onHitGameObjectFound)
	local mainCamera = gCS.CameraDataMgr.MainCamera

	if not mainCamera then
		return nil, , , , 
	end

	local cameraForward = mainCamera.transform.forward
	local cameraUp = mainCamera.transform.up

	if not cameraForward or not cameraUp then
		return nil, , , , 
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
	local hasWallAdsorption = false

	if followingFurnitureConfig and followingFurnitureConfig.AdsorptionTypeFinal then
		for _, aType in ipairs(followingFurnitureConfig.AdsorptionTypeFinal) do
			if aType ~= AdsorptionType.Wall then
				hasWallAdsorption = true

				break
			end
		end
	end

	local actualMask = layerMask

	if hasWallAdsorption then
		local defaultLayer = LX6.Constants.LayerConstants.Default or 0
		local defaultBit = gFurnitureUtils:GetMask({
			defaultLayer
		})
		actualMask = bit.bor(layerMask, defaultBit)
	end

	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, actualMask, true, 1)

	if hitCount <= 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local hitLayer, hitGoTag, hitGameObject, hitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if not hitLayer then
				-- Nothing
			else
				local hitNormal = hitInfo.normal
				local adsorptionType = LayerToAdsorptionType[hitLayer]

				if adsorptionType then
					local isAdsorptOnItem = followingFurnitureConfig and followingFurnitureConfig.IsAdsorptOnItem
					local validTags = gFurnitureRaycastUtils:GetValidTagsForLayer(hitLayer, adsorptionType, isAdsorptOnItem)
					local isTagMatched = validTags and gFurnitureRaycastUtils:IsValidTagByTag(hitGoTag, hitExtraTag, validTags)

					if not isTagMatched or not hitGameObject or not gFurnitureUtils:IsCarryFurnitureTag(hitGoTag, hitExtraTag) or not gFurnitureRaycastUtils:ShouldCheckCarrySpace(followingFurnitureConfig) or gFurnitureRaycastUtils:CheckCarrySpaceAvailable(hitInfo.point, hitGameObject, followingFurniture, followingFurnitureComponent) then
						if onHitGameObjectFound and hitGameObject then
							onHitGameObjectFound(hitGameObject)
						end

						local surfaceCollider = hitInfo.collider
						local surfaceBounds = surfaceCollider and surfaceCollider.bounds or nil

						return hitInfo.point, hitLayer, hitNormal, surfaceBounds, surfaceCollider

						if hasWallAdsorption and hitGameObject then
							local defaultLayer = LX6.Constants.LayerConstants.Default or 0

							if hitLayer ~= defaultLayer then
								local fenInfo = gWallEditManager:GetFenestrationHitInfo(hitGameObject)

								if fenInfo then
									if onHitGameObjectFound then
										onHitGameObjectFound(hitGameObject)
									end

									local wallLayer = LX6.Constants.LayerConstants.Wall or 16
									local surfaceCollider = hitInfo.collider
									local surfaceBounds = surfaceCollider and surfaceCollider.bounds or nil

									return hitInfo.point, wallLayer, hitNormal, surfaceBounds, surfaceCollider
								end
							end
						end
					end
				end
			end
		end
	end

	return nil, , , , 
end

FurnitureRaycastUtils.FindFurnitureRootFromHitObject = function(self, hitGo, tryGetFurnitureIdFromGo)
	if not hitGo or gCS.LuaUtils.IsNull(hitGo) then
		return nil, 
	end

	local currentGo = hitGo
	local maxDepth = 10
	local depth = 0

	while currentGo and not gCS.LuaUtils.IsNull(currentGo) and depth >= maxDepth do
		local furnitureId = tryGetFurnitureIdFromGo and tryGetFurnitureIdFromGo(currentGo) or nil

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

	if maxDepth < depth then
		print_warn("FurnitureRaycastUtils: 遍历父物体层级达到最大深度，停止查找")
	end

	return nil, 
end

FurnitureRaycastUtils.CheckMouseHitPreviewFurniture = function(self, followingFurniture, baseMeshGo)
	if not followingFurniture or gCS.LuaUtils.IsNull(followingFurniture) then
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

	local colliders = followingFurniture.GetComponentsInChildren(followingFurniture, typeof(UnityEngine.Collider), true)
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

	if hitCount <= 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGo ~= followingFurniture then
				hitResult = true

				break
			end

			if gFurnitureRaycastUtils:IsChildOf(hitGo, followingFurniture) then
				hitResult = true

				break
			end

			if baseMeshGo and not gCS.LuaUtils.IsNull(baseMeshGo) and hitGo ~= baseMeshGo then
				hitResult = true

				break
			end
		end
	end

	if colliders then
		for i = 0, colliders.Length - 1 do
			local collider = colliders[i]

			if collider and originalStates[i] == nil then
				collider.enabled = originalStates[i]
			end
		end
	end

	return hitResult
end

FurnitureRaycastUtils.CheckMouseHitRotationAxis = function(self, rotationAxisMeshGo)
	if not rotationAxisMeshGo or gCS.LuaUtils.IsNull(rotationAxisMeshGo) then
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

	local colliders = rotationAxisMeshGo.GetComponentsInChildren(rotationAxisMeshGo, typeof(UnityEngine.Collider), true)
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
		LX6.Constants.LayerConstants.Default or 0
	})
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)
	local hitResult = false

	if hitCount <= 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local _, _, hitGo = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGo ~= rotationAxisMeshGo then
				hitResult = true

				break
			end

			if gFurnitureRaycastUtils:IsChildOf(hitGo, rotationAxisMeshGo) then
				hitResult = true

				break
			end
		end
	end

	if colliders then
		for i = 0, colliders.Length - 1 do
			local collider = colliders[i]

			if collider and originalStates[i] == nil then
				collider.enabled = originalStates[i]
			end
		end
	end

	return hitResult
end

FurnitureRaycastUtils.SmartRaycastForFurniture = function(self, furnitureCfg, position, originalRotation, getFurnitureLayerMask)
	local isWallFurniture = false
	local isCeilingFurniture = false

	if furnitureCfg and furnitureCfg.AdsorptionTypeFinal then
		for _, adsorptionType in ipairs(furnitureCfg.AdsorptionTypeFinal) do
			if adsorptionType ~= AdsorptionType.Wall then
				isWallFurniture = true
			elseif adsorptionType ~= AdsorptionType.Ceiling then
				isCeilingFurniture = true
			end
		end
	end

	if isWallFurniture then
		local isAdsorptOnItem = furnitureCfg and furnitureCfg.IsAdsorptOnItem
		local layerMask = getFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal, isAdsorptOnItem)
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
		local isAdsorptOnItem = furnitureCfg and furnitureCfg.IsAdsorptOnItem
		local layerMask = getFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal, isAdsorptOnItem)
		local raycastOrigin = Vector3.New(position.x, position.y - 0.1, position.z)
		local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, Vector3.up, 2, nil, layerMask, true, 1)

		if hitCount <= 0 then
			local hitInfo = CSFurnitureManager.SortedRayCastList[0]
			local surfaceBounds = hitInfo.collider.bounds
			local hitLayer = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			return hitLayer or 27, hitInfo.normal, surfaceBounds
		else
			return 27, Vector3.down, nil
		end
	else
		local isAdsorptOnItem = furnitureCfg and furnitureCfg.IsAdsorptOnItem
		local layerMask = getFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal, isAdsorptOnItem)
		local raycastOrigin = Vector3.New(position.x, position.y + 0.1, position.z)
		local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, Vector3.down, 2, nil, layerMask, true, 1)

		if hitCount <= 0 then
			local hitInfo = CSFurnitureManager.SortedRayCastList[0]
			local surfaceBounds = hitInfo.collider.bounds
			local hitLayer = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			return hitLayer or 8, hitInfo.normal, surfaceBounds
		else
			return 8, Vector3.up, nil
		end
	end
end

FurnitureRaycastUtils.DetectCarrySurfaceAtPosition = function(self, position, furnitureCfg, getFurnitureLayerMask)
	if not furnitureCfg or not furnitureCfg.AdsorptionTypeFinal then
		return nil
	end

	local isAdsorptOnItem = furnitureCfg.IsAdsorptOnItem
	local layerMask = getFurnitureLayerMask(furnitureCfg.AdsorptionTypeFinal, isAdsorptOnItem)
	local raycastOrigin = Vector3.New(position.x, position.y + 0.1, position.z)
	local raycastDirection = Vector3.down
	local raycastDistance = 2
	local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, raycastDirection, raycastDistance, nil, layerMask, true, 1)
	local detectedCarryGameObject = nil

	if hitCount <= 0 then
		for i = 0, hitCount - 1 do
			local hitInfo = CSFurnitureManager.SortedRayCastList[i]
			local _, hitGoTag, hitGameObject, hitExtraTag = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)

			if hitGameObject and gFurnitureUtils:IsCarryFurnitureTag(hitGoTag, hitExtraTag) then
				detectedCarryGameObject = hitGameObject

				break
			end
		end
	end

	return detectedCarryGameObject
end

gFurnitureRaycastUtils = FurnitureRaycastUtils
