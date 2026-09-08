-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureMeshUtils.lua
-- Decompiled from: 00735_FurnitureMeshUtils.lua_af9d7e520f59.luajit

local HouseConfig = LTConfig.HouseConfig
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local AdsorptionType = gFurnitureConst.AdsorptionType

local GetGridMeshColor = function()
	local gridMeshColor = HouseConfig.GridMeshColor

	return Color.New(gridMeshColor[1], gridMeshColor[2], gridMeshColor[3], gridMeshColor[4])
end

local FurnitureMeshUtils = {
	GenerateBaseMesh = function (self, furnitureCfg, furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState, onBaseMeshCreated, onGadgetMeshCreated)
		if furnitureComponent and not gCS.LuaUtils.IsNull(furnitureComponent.baseFootprintObject) then
			local footprintGo = furnitureComponent.baseFootprintObject

			footprintGo.SetActive(footprintGo, true)

			meshState.baseMeshGo = footprintGo
			meshState.isBaseFootprint = true

			if onBaseMeshCreated then
				onBaseMeshCreated(meshState.baseMeshGo)
			end

			if furnitureComponent and furnitureComponent.isGadget then
				local gadgetMeshPath = HouseConfig.GadgetMeshPath

				gFurnitureMeshUtils:GenerateGadgetMesh(gadgetMeshPath, furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState, onGadgetMeshCreated)
			end

			return
		end

		local baseMeshPath = HouseConfig.BaseMeshPath
		slot10 = gResourceManager
		meshState.baseMeshLoadOp = slot10:LoadAssetWithCallBack(baseMeshPath, typeof(GameObject), function (loadOp)
			if loadOp.asset then
				meshState.baseMeshGo = GameObject.Instantiate(loadOp.asset)

				meshState.baseMeshGo.transform:SetParent(furnitureGo.transform, false)
				gFurnitureMeshUtils:AdjustBaseMeshSize(furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState.baseMeshGo)

				meshState.baseMeshGo.name = "BaseMesh_" .. (furnitureCfg.Name or "Unknown")

				if onBaseMeshCreated then
					onBaseMeshCreated(meshState.baseMeshGo)
				end

				if furnitureComponent and furnitureComponent.isGadget then
					local gadgetMeshPath = HouseConfig.GadgetMeshPath

					gFurnitureMeshUtils:GenerateGadgetMesh(gadgetMeshPath, furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState, onGadgetMeshCreated)
				end
			else
				print_error(string.format("FurnitureMeshUtils: 加载底座mesh失败，路径: %s", baseMeshPath))
			end
		end)
	end
}

FurnitureMeshUtils.GenerateGadgetMesh = function(self, gadgetMeshPath, furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState, onGadgetMeshCreated)
	slot8 = gResourceManager
	meshState.gadgetMeshLoadOp = slot8:LoadAssetWithCallBack(gadgetMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			meshState.gadgetMeshGo = GameObject.Instantiate(loadOp.asset)

			meshState.gadgetMeshGo.transform:SetParent(furnitureGo.transform, false)

			if furnitureComponent and furnitureComponent.boundsBox then
				local furnitureBounds = furnitureComponent.boundsBox
				local furnitureSizeZ = furnitureBounds.size.z
				local params = HouseConfig.GadgetMeshSizeParams or {
					0.3,
					12
				}
				local adaptiveScale = params[1] + furnitureSizeZ / params[2]
				meshState.gadgetMeshGo.transform.localScale = Vector3.New(adaptiveScale, adaptiveScale, adaptiveScale)
			end

			if furnitureComponent and furnitureComponent.gadgetOffset then
				local offset = furnitureComponent.gadgetOffset
				local meshSizeX = 0.5
				local meshSizeZ = 0.5
				local renderer = meshState.gadgetMeshGo:GetComponent(typeof(UnityEngine.Renderer))

				if renderer and renderer.bounds then
					meshSizeX = renderer.bounds.size.x * 0.5
					meshSizeZ = renderer.bounds.size.z
				end

				meshState.gadgetMeshGo.transform.localPosition = Vector3.New(offset.x + meshSizeX, 0.01, offset.z + meshSizeZ)
			end

			meshState.gadgetMeshGo.name = "GadgetMesh_" .. (furnitureGo.name or "Unknown")

			if onGadgetMeshCreated then
				onGadgetMeshCreated(meshState.gadgetMeshGo)
			end
		else
			print_error(string.format("FurnitureMeshUtils: 加载gadget mesh失败，路径: %s", gadgetMeshPath))
		end
	end)
end

FurnitureMeshUtils.AdjustBaseMeshSize = function(self, furnitureGo, furnitureComponent, adsorptionType, hitNormal, baseMeshGo)
	if not baseMeshGo then
		return
	end

	if not furnitureComponent or not furnitureComponent.boundsBox then
		baseMeshGo.transform.localScale = Vector3.New(1, 1, 1)
		baseMeshGo.transform.localPosition = Vector3.New(0, 0, 0)

		return
	end

	local boundsSize = furnitureComponent.boundsBox.size
	local boundsCenter = furnitureComponent.boundsBox.center
	local scaleX = boundsSize.x
	local scaleZ = boundsSize.z
	baseMeshGo.transform.localScale = Vector3.New(scaleX, 1, scaleZ)

	if adsorptionType ~= AdsorptionType.Floor then
		baseMeshGo.transform.localRotation = Quaternion.identity
		local offsetToCenterX = scaleX * 0.5
		local offsetToCenterZ = scaleZ * 0.5
		local localPositionX = offsetToCenterX + boundsCenter.x
		local localPositionY = 0.01
		local localPositionZ = offsetToCenterZ + boundsCenter.z
		baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	elseif adsorptionType ~= AdsorptionType.Ceiling then
		baseMeshGo.transform.localRotation = Quaternion.identity
		local offsetToCenterX = scaleX * 0.5
		local offsetToCenterZ = scaleZ * 0.5
		local localPositionX = offsetToCenterX + boundsCenter.x
		local localPositionY = -0.01
		local localPositionZ = offsetToCenterZ + boundsCenter.z
		baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	elseif adsorptionType ~= AdsorptionType.Wall and hitNormal then
		local wallNormal = hitNormal
		wallNormal.y = 0
		wallNormal = wallNormal.normalized
		local xRotation90 = Quaternion.Euler(90, 0, 0)
		baseMeshGo.transform.localRotation = xRotation90
		local wallScaleX = boundsSize.x
		local wallScaleY = boundsSize.y
		local offset = 0.08
		baseMeshGo.transform.localScale = Vector3.New(wallScaleX + offset, 1, wallScaleY + offset)
		local localPositionX = wallScaleX * 0.5 + offset / 2
		local localPositionY = -wallScaleY * 0.5 - offset / 2
		local localPositionZ = 0.01
		baseMeshGo.transform.localPosition = Vector3.New(localPositionX, localPositionY, localPositionZ)
	else
		baseMeshGo.transform.localRotation = Quaternion.identity
		baseMeshGo.transform.localPosition = Vector3.New(boundsCenter.x, boundsCenter.y, boundsCenter.z)
	end
end

FurnitureMeshUtils.ClearBaseMesh = function(self, meshState)
	if meshState.baseMeshGo and not gCS.LuaUtils.IsNull(meshState.baseMeshGo) then
		if meshState.isBaseFootprint then
			meshState.baseMeshGo:SetActive(false)
		else
			GameObject.Destroy(meshState.baseMeshGo)
		end

		meshState.baseMeshGo = nil
		meshState.isBaseFootprint = nil
	end

	if meshState.baseMeshLoadOp then
		meshState.baseMeshLoadOp = nil
	end

	if meshState.gadgetMeshGo and not gCS.LuaUtils.IsNull(meshState.gadgetMeshGo) then
		GameObject.Destroy(meshState.gadgetMeshGo)

		meshState.gadgetMeshGo = nil
	end

	if meshState.gadgetMeshLoadOp then
		meshState.gadgetMeshLoadOp = nil
	end

	gFurnitureMeshUtils:ClearRotationAxisMesh(meshState)
end

FurnitureMeshUtils.GenerateRotationAxisMesh = function(self, furnitureCfg, furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState, onRotationAxisMeshCreated)
	local rotationMeshPath = HouseConfig.RotationMeshPath
	slot9 = gResourceManager
	meshState.rotationAxisMeshLoadOp = slot9:LoadAssetWithCallBack(rotationMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			if not furnitureGo or gCS.LuaUtils.IsNull(furnitureGo) then
				meshState.rotationAxisMeshLoadOp = nil

				if onRotationAxisMeshCreated then
					onRotationAxisMeshCreated(nil)
				end

				return
			end

			meshState.rotationAxisMeshGo = GameObject.Instantiate(loadOp.asset)

			meshState.rotationAxisMeshGo.transform:SetParent(furnitureGo.transform, false)
			gFurnitureMeshUtils:AdjustRotationAxisMeshPosition(furnitureGo, furnitureComponent, adsorptionType, hitNormal, meshState.rotationAxisMeshGo, furnitureCfg)

			meshState.rotationAxisMeshGo.layer = LX6.Constants.LayerConstants.Default or 0
			local transform = meshState.rotationAxisMeshGo.transform

			for i = 0, transform.childCount - 1 do
				local child = transform:GetChild(i)

				if child and child.gameObject then
					child.gameObject.layer = LX6.Constants.LayerConstants.Default or 0
				end
			end

			local colliders = meshState.rotationAxisMeshGo:GetComponentsInChildren(typeof(UnityEngine.Collider))

			if not colliders or colliders.Length ~= 0 then
				local transform = meshState.rotationAxisMeshGo.transform
				local childCount = transform.childCount

				if childCount <= 0 then
					local lastChild = transform:GetChild(childCount - 1)

					if lastChild and lastChild.gameObject then
						local boxCollider = lastChild.gameObject:AddComponent(typeof(UnityEngine.BoxCollider))

						if boxCollider then
							boxCollider.isTrigger = false
						end
					end
				else
					local boxCollider = meshState.rotationAxisMeshGo:AddComponent(typeof(UnityEngine.BoxCollider))

					if boxCollider then
						boxCollider.isTrigger = false
					end
				end
			else
				for i = 0, colliders.Length - 1 do
					local collider = colliders[i]

					if collider then
						collider.enabled = true
					end
				end
			end

			meshState.rotationAxisMeshGo.name = "RotationAxisMesh_" .. (furnitureCfg.Name or "Unknown")
		else
			print_error(string.format("FurnitureMeshUtils: 加载旋转轴mesh失败，路径: %s", rotationMeshPath))
		end

		meshState.rotationAxisMeshLoadOp = nil

		if onRotationAxisMeshCreated then
			onRotationAxisMeshCreated(meshState.rotationAxisMeshGo)
		end
	end)
end

FurnitureMeshUtils.AdjustRotationAxisMeshPosition = function(self, furnitureGo, furnitureComponent, adsorptionType, hitNormal, rotationAxisMeshGo, furnitureCfg)
	if not rotationAxisMeshGo or not furnitureComponent or not furnitureComponent.boundsBox then
		return
	end

	local boundsCenter = furnitureComponent.boundsBox.center
	local rotationScale = 1

	if furnitureCfg and furnitureCfg.RotationScale then
		rotationScale = furnitureCfg.RotationScale
	end

	if adsorptionType ~= AdsorptionType.Floor then
		rotationAxisMeshGo.transform.localRotation = Quaternion.identity
		rotationAxisMeshGo.transform.localPosition = Vector3.New(0, 0.01, 0)
		rotationAxisMeshGo.transform.localScale = Vector3.New(rotationScale, 1, rotationScale)
	elseif adsorptionType ~= AdsorptionType.Ceiling then
		rotationAxisMeshGo.transform.localRotation = Quaternion.identity
		rotationAxisMeshGo.transform.localPosition = Vector3.New(0, -0.01, 0)
		rotationAxisMeshGo.transform.localScale = Vector3.New(rotationScale, 1, rotationScale)
	elseif adsorptionType ~= AdsorptionType.Wall and hitNormal then
		rotationAxisMeshGo.transform.localRotation = Quaternion.Euler(90, 0, 0)
		rotationAxisMeshGo.transform.localPosition = Vector3.New(0, boundsCenter.y, 0)
		rotationAxisMeshGo.transform.localScale = Vector3.New(rotationScale, 1, rotationScale)
	else
		rotationAxisMeshGo.transform.localRotation = Quaternion.identity
		rotationAxisMeshGo.transform.localPosition = Vector3.New(boundsCenter.x, boundsCenter.y, boundsCenter.z)
		rotationAxisMeshGo.transform.localScale = Vector3.New(rotationScale, 1, rotationScale)
	end
end

FurnitureMeshUtils.ClearRotationAxisMesh = function(self, meshState)
	if meshState.rotationAxisMeshGo and not gCS.LuaUtils.IsNull(meshState.rotationAxisMeshGo) then
		GameObject.Destroy(meshState.rotationAxisMeshGo)

		meshState.rotationAxisMeshGo = nil
	end

	if meshState.rotationAxisMeshLoadOp then
		meshState.rotationAxisMeshLoadOp = nil
	end
end

FurnitureMeshUtils.GenerateSurfaceHintMesh = function(self, surfaceBounds, adsorptionType, hitNormal, followingFurniture, gridModeEnabled, gridSize, surfaceHintState, getFurnitureRoot, surfaceCollider)
	local surfaceHintMeshPath = HouseConfig.GridMeshPath

	gFurnitureMeshUtils:ClearSurfaceHintMesh(surfaceHintState)

	local currentSurfaceCollider = surfaceCollider

	if not currentSurfaceCollider and CSFurnitureManager.SortedRayCastList and CSFurnitureManager.SortedRayCastList[0] and CSFurnitureManager.SortedRayCastList[0].collider then
		currentSurfaceCollider = CSFurnitureManager.SortedRayCastList[0].collider
	end

	slot12 = gResourceManager
	surfaceHintState.surfaceHintMeshLoadOp = slot12:LoadAssetWithCallBack(surfaceHintMeshPath, typeof(GameObject), function (loadOp)
		if loadOp.asset then
			if not followingFurniture or gCS.LuaUtils.IsNull(followingFurniture) then
				surfaceHintState.surfaceHintMeshLoadOp = nil

				return
			end

			surfaceHintState.surfaceHintMeshGo = GameObject.Instantiate(loadOp.asset)
			local furnitureRoot = getFurnitureRoot and getFurnitureRoot() or nil

			if furnitureRoot then
				surfaceHintState.surfaceHintMeshGo.transform:SetParent(furnitureRoot.transform, true)
			end

			gFurnitureMeshUtils:AdjustSurfaceHintMeshPosition(surfaceBounds, adsorptionType, hitNormal, followingFurniture, gridModeEnabled, gridSize, surfaceHintState.surfaceHintMeshGo, currentSurfaceCollider)

			surfaceHintState.surfaceHintMeshGo.name = "SurfaceHintMesh_" .. tostring(adsorptionType)
			local renderer = surfaceHintState.surfaceHintMeshGo:GetComponent(typeof(UnityEngine.Renderer))

			if renderer and renderer.material then
				local material = renderer.material
				local gridMeshColor = GetGridMeshColor()

				if material:HasProperty("_Color") then
					material:SetColor("_Color", gridMeshColor)
				elseif material:HasProperty("_BaseColor") then
					material:SetColor("_BaseColor", gridMeshColor)
				elseif material:HasProperty("_MainColor") then
					material:SetColor("_MainColor", gridMeshColor)
				end
			end

			if currentSurfaceCollider then
				gFurnitureMeshUtils:UpdateCurrentSurfaceState(currentSurfaceCollider, surfaceBounds, adsorptionType, hitNormal, surfaceHintState)
			end
		else
			print_error(string.format("FurnitureMeshUtils: 加载表面提示mesh失败，路径: %s", surfaceHintMeshPath))
		end

		surfaceHintState.surfaceHintMeshLoadOp = nil
	end)
end

FurnitureMeshUtils.AdjustSurfaceHintMeshPosition = function(self, surfaceBounds, adsorptionType, hitNormal, followingFurniture, gridModeEnabled, gridSize, surfaceHintMeshGo, surfaceCollider)
	if not surfaceHintMeshGo or not surfaceBounds then
		return
	end

	local isCarrySurface = false
	local carrySurfaceRotation, carrySurfaceLocalSize = nil

	if surfaceCollider and not gCS.LuaUtils.IsNull(surfaceCollider) then
		local colliderTag, colliderExtraTag = gCS.LuaUtils.GetColliderTags(surfaceCollider, "")

		if gFurnitureUtils:IsCarryFurnitureTag(colliderTag, colliderExtraTag) then
			local colliderGo = gCS.LuaUtils.GetColliderGameObject(surfaceCollider)

			if colliderGo and not gCS.LuaUtils.IsNull(colliderGo) then
				isCarrySurface = true
				carrySurfaceRotation = colliderGo.transform.rotation
				local boxCol = colliderGo.GetComponent(colliderGo, typeof(UnityEngine.BoxCollider))

				if boxCol then
					local localSize = boxCol.size
					local lossyScale = colliderGo.transform.lossyScale
					carrySurfaceLocalSize = Vector3.New(localSize.x * math.abs(lossyScale.x), localSize.y * math.abs(lossyScale.y), localSize.z * math.abs(lossyScale.z))
				end
			end
		end
	end

	local surfaceCenter = surfaceBounds.center
	local surfaceSize = surfaceBounds.size
	local defaultY = gHouseManager:GetNowBuildDefaultTowards()
	defaultY = 0

	if adsorptionType ~= AdsorptionType.Floor then
		if isCarrySurface and carrySurfaceRotation and carrySurfaceLocalSize then
			local euler = carrySurfaceRotation.eulerAngles
			local yRad = math.rad(euler.y)
			surfaceHintMeshGo.transform.rotation = Quaternion.Euler(0, euler.y, 0)
			local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(carrySurfaceLocalSize.x, gridSize)
			local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(carrySurfaceLocalSize.z, gridSize)
			surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
			local halfX = expandedSizeX * 0.5
			local halfZ = expandedSizeZ * 0.5
			local cosY = math.cos(yRad)
			local sinY = math.sin(yRad)
			local offsetX = halfX * cosY + halfZ * sinY
			local offsetZ = -halfX * sinY + halfZ * cosY
			local hintPosition = Vector3.New(surfaceCenter.x + offsetX, surfaceCenter.y + surfaceSize.y * 0.5 + 0.01, surfaceCenter.z + offsetZ)
			surfaceHintMeshGo.transform.position = hintPosition
		else
			local offsetToCenterX = surfaceSize.x * 0.5
			local offsetToCenterZ = surfaceSize.z * 0.5
			surfaceHintMeshGo.transform.rotation = Quaternion.Euler(0, defaultY, 0)
			local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, gridSize)
			local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, gridSize)
			surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
			local hintPosition = Vector3.New(surfaceCenter.x + offsetToCenterX, surfaceCenter.y + surfaceSize.y * 0.5 + 0.01, surfaceCenter.z + offsetToCenterZ)
			hintPosition = gFurnitureUtils:SnapToGrid(hintPosition, adsorptionType, gridModeEnabled, gridSize, hitNormal)
			surfaceHintMeshGo.transform.position = hintPosition
		end
	elseif adsorptionType ~= AdsorptionType.Ceiling then
		surfaceHintMeshGo.transform.rotation = Quaternion.Euler(180, defaultY, 0)
		local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, gridSize)
		local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, gridSize)
		surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
		local offsetToCenterX = surfaceSize.x * 0.5
		local offsetToCenterZ = surfaceSize.z * 0.5
		local hintPosition = Vector3.New(surfaceCenter.x + offsetToCenterX, surfaceCenter.y - surfaceSize.y * 0.5 - 0.01, surfaceCenter.z - offsetToCenterZ)
		hintPosition = gFurnitureUtils:SnapToGrid(hintPosition, adsorptionType, gridModeEnabled, gridSize, hitNormal)
		surfaceHintMeshGo.transform.position = hintPosition
	else
		surfaceHintMeshGo.transform.rotation = Quaternion.identity
		local expandedSizeX = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.x, gridSize)
		local expandedSizeZ = gFurnitureUtils:ExpandToNearestGridMultiple(surfaceSize.z, gridSize)
		surfaceHintMeshGo.transform.localScale = Vector3.New(expandedSizeX, 1, expandedSizeZ)
		local alignedPosition = gFurnitureUtils:SnapToGrid(surfaceCenter, adsorptionType, gridModeEnabled, gridSize, hitNormal)
		surfaceHintMeshGo.transform.position = alignedPosition
	end
end

FurnitureMeshUtils.ClearSurfaceHintMesh = function(self, surfaceHintState)
	if surfaceHintState.surfaceHintMeshGo and not gCS.LuaUtils.IsNull(surfaceHintState.surfaceHintMeshGo) then
		GameObject.Destroy(surfaceHintState.surfaceHintMeshGo)

		surfaceHintState.surfaceHintMeshGo = nil
	end

	if surfaceHintState.surfaceHintMeshLoadOp then
		surfaceHintState.surfaceHintMeshLoadOp = nil
	end

	gFurnitureMeshUtils:ResetCurrentSurfaceState(surfaceHintState)
end

FurnitureMeshUtils.HasSurfaceChanged = function(self, newCollider, newBounds, newAdsorptionType, newNormal, surfaceHintState)
	if surfaceHintState.currentSurfaceCollider == newCollider then
		return true
	end

	if surfaceHintState.currentSurfaceAdsorptionType == newAdsorptionType then
		return true
	end

	if newNormal and surfaceHintState.currentSurfaceNormal then
		local dotProduct = Vector3.Dot(newNormal.normalized, surfaceHintState.currentSurfaceNormal.normalized)

		if dotProduct >= 0.99 then
			return true
		end
	elseif newNormal == surfaceHintState.currentSurfaceNormal then
		return true
	end

	if newCollider and surfaceHintState.currentSurfaceCollider ~= newCollider then
		return false
	end

	if newBounds and surfaceHintState.currentSurfaceBounds then
		local centerDiff = newBounds.center - surfaceHintState.currentSurfaceBounds.center
		local sizeDiff = newBounds.size - surfaceHintState.currentSurfaceBounds.size
		local thresholdSqr = 0.010000000000000002

		if thresholdSqr <= centerDiff.sqrMagnitude or thresholdSqr >= sizeDiff.sqrMagnitude then
			return true
		end
	elseif newBounds == surfaceHintState.currentSurfaceBounds then
		return true
	end

	return false
end

FurnitureMeshUtils.UpdateCurrentSurfaceState = function(self, collider, bounds, adsorptionType, normal, surfaceHintState)
	surfaceHintState.currentSurfaceCollider = collider
	surfaceHintState.currentSurfaceBounds = bounds
	surfaceHintState.currentSurfaceAdsorptionType = adsorptionType
	surfaceHintState.currentSurfaceNormal = normal
end

FurnitureMeshUtils.ResetCurrentSurfaceState = function(self, surfaceHintState)
	surfaceHintState.currentSurfaceCollider = nil
	surfaceHintState.currentSurfaceBounds = nil
	surfaceHintState.currentSurfaceAdsorptionType = nil
	surfaceHintState.currentSurfaceNormal = nil
end

gFurnitureMeshUtils = FurnitureMeshUtils
