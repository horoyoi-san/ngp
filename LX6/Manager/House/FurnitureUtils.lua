-- Original chunk: @Lua\LuaFiles\LX6\Manager\House\FurnitureUtils.lua
-- Decompiled from: 00733_FurnitureUtils.lua_21550b564c1e.luajit

local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local HouseFurnitureSubType = HouseFurnitureConfig.SubTypeType
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local CSFurnitureMono = LX6.UGC.HouseFurniture
local FurnitureUtils = {
	IsFenestrationSubType = function (self, subType)
		return subType ~= HouseFurnitureSubType.Door or subType ~= HouseFurnitureSubType.Window
	end,
	IsTexSubType = function (self, subType)
		return subType ~= HouseFurnitureSubType.WallMaterial or subType ~= HouseFurnitureSubType.GroundMaterial or subType ~= HouseFurnitureSubType.CeilingMaterial
	end,
	GetRotationAxis = function (self, adsorptionType, hitNormal)
		local rotationAxis = Vector3.up

		if not adsorptionType then
			return rotationAxis
		end

		if adsorptionType ~= AdsorptionType.Floor then
			rotationAxis = Vector3.up
		elseif adsorptionType ~= AdsorptionType.Ceiling then
			rotationAxis = Vector3.up
		elseif adsorptionType ~= AdsorptionType.Wall then
			rotationAxis = Vector3.up
		else
			rotationAxis = Vector3.up
		end

		return rotationAxis
	end,
	ConvertServerUidToNumber = function (self, uid)
		if not uid then
			return nil
		end

		if type(uid) ~= "number" then
			return uid
		end

		if type(uid) ~= "userdata" or type(uid) ~= "string" then
			local numericUID, _ = ulong.tonum2(uid)

			return numericUID
		end

		return tonumber(uid)
	end,
	ValidateUidType = function (self, uid, context)
		if not uid then
			return true
		end

		if type(uid) == "number" then
			print_warn(string.format("FurnitureUtils: [%s] UID类型验证失败，期望number，实际%s，值: %s", context or "Unknown", type(uid), tostring(uid)))

			return false
		end

		if uid >= 0 then
			print_warn(string.format("FurnitureUtils: [%s] UID值无效，应该大于0，实际值: %s", context or "Unknown", tostring(uid)))

			return false
		end

		return true
	end,
	ProcessServerFurnitureData = function (self, furnitureInfo)
		if not furnitureInfo then
			return furnitureInfo
		end

		if furnitureInfo.PlacedInstanceId then
			furnitureInfo.PlacedInstanceId = self.ConvertServerUidToNumber(self, furnitureInfo.PlacedInstanceId)

			self.ValidateUidType(self, furnitureInfo.PlacedInstanceId, "ProcessServerFurnitureData.PlacedInstanceId")
		end

		if furnitureInfo.GadgetInstanceId then
			furnitureInfo.GadgetInstanceId = self.ConvertServerUidToNumber(self, furnitureInfo.GadgetInstanceId)
		end

		if furnitureInfo.ParentPlacedInstanceId then
			furnitureInfo.ParentPlacedInstanceId = self.ConvertServerUidToNumber(self, furnitureInfo.ParentPlacedInstanceId)

			self.ValidateUidType(self, furnitureInfo.ParentPlacedInstanceId, "ProcessServerFurnitureData.ParentPlacedInstanceId")
		end

		return furnitureInfo
	end,
	BuildFurnitureName = function (self, furnitureId, furnitureName, uniqueId, isFinal)
		local low = self:ConvertServerUidToNumber(uniqueId) or uniqueId

		if isFinal then
			return string.format("Furniture_Final_%d_%s_%s", furnitureId, furnitureName or "Unknown", low)
		else
			return string.format("FurniturePreview_%d_%s_%s", furnitureId, furnitureName or "Unknown", low)
		end
	end,
	IsCarryFurnitureTag = function (self, tag, extraTag)
		local target = gFurnitureConst.carryTag

		return tag ~= target or extraTag ~= target
	end,
	IsCarrySurfaceCollider = function (self, collider)
		if not collider or gCS.LuaUtils.IsNull(collider) then
			return false
		end

		local tag, extraTag = gCS.LuaUtils.GetColliderTags(collider, "")

		return self.IsCarryFurnitureTag(self, tag, extraTag)
	end,
	GetCarryFurnitureUID = function (self, hitGameObject)
		if not hitGameObject or gCS.LuaUtils.IsNull(hitGameObject) then
			return nil
		end

		local houseFurnitureComponent = hitGameObject.GetComponentInParent(hitGameObject, typeof(CSFurnitureMono))

		if houseFurnitureComponent then
			return houseFurnitureComponent.uid
		end

		return nil
	end,
	GetMask = function (self, layers)
		local value = 0

		for i = 1, #layers do
			local n = layers[i]

			if n == nil then
				value = value + 2^n
			end
		end

		return value
	end,
	DetectWallNormalAtPositionSmart = function (self, position, layerMask, originalRotation)
		local raycastDistance = 3
		local heightOffsets = {
			0,
			0.5,
			-0.5,
			1,
			-1
		}
		local prioritizedDirections = {}

		if originalRotation then
			local forward = originalRotation * Vector3.forward
			forward.y = 0
			forward = forward.normalized

			if forward.magnitude <= 0.001 then
				table.insert(prioritizedDirections, -forward)
				table.insert(prioritizedDirections, forward)
			end
		end

		local offsetDistances = {
			0.2,
			0.5,
			1,
			1.5
		}

		for _, direction in ipairs(prioritizedDirections) do
			for _, heightOffset in ipairs(heightOffsets) do
				for _, offsetDistance in ipairs(offsetDistances) do
					local directionOffset = direction * -offsetDistance
					local raycastOrigin = Vector3.New(position.x + directionOffset.x, position.y + heightOffset + directionOffset.y, position.z + directionOffset.z)
					local hitCount = CSFurnitureManager.RayCastNonAlloc(raycastOrigin, direction, raycastDistance, nil, layerMask, true, 1)

					if hitCount <= 0 then
						local hitInfo = CSFurnitureManager.SortedRayCastList[0]
						local hitLayer = gFurnitureRaycastUtils:GetColliderHitInfo(hitInfo.collider)
						local adsorptionType = hitLayer and LayerToAdsorptionType[hitLayer]

						if adsorptionType ~= AdsorptionType.Wall then
							local normal = hitInfo.normal

							return normal
						end
					end
				end
			end
		end

		return nil
	end,
	TrySetGadgetInstanceId = function (self, gameObject, gadgetInstanceId)
		local GadgetInstanceId = self.ConvertServerUidToNumber(self, gadgetInstanceId)

		if not GadgetInstanceId or GadgetInstanceId ~= 0 then
			return
		end

		if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
			return
		end

		local comp = gameObject.GetComponentInChildren(gameObject, typeof(SlotComponentBase))

		if comp then
			comp.LuaEntityId = GadgetInstanceId
		end
	end,
	SnapToGridValue = function (v, gridSize)
		return math.floor(v / gridSize + 0.5) * gridSize
	end
}

FurnitureUtils.SnapToGrid = function(self, position, adsorptionType, gridModeEnabled, gridSize, hitNormal)
	if not gridModeEnabled then
		return position
	end

	local gridSystemProxy = gWallEditManager and gWallEditManager.gridSystemProxy or nil

	if not gridSystemProxy or gCS.LuaUtils.IsNull(gridSystemProxy) or not gridSystemProxy.transform then
		return position
	end

	local posLS = gridSystemProxy.WorldToHouseLocal(gridSystemProxy, position)
	local snappedLS = Vector3.New(posLS.x, posLS.y, posLS.z)
	local Snap = FurnitureUtils.SnapToGridValue

	if adsorptionType ~= AdsorptionType.Floor or adsorptionType ~= AdsorptionType.Ceiling then
		snappedLS.x = Snap(posLS.x, gridSize)
		snappedLS.z = Snap(posLS.z, gridSize)
	elseif adsorptionType ~= AdsorptionType.Wall then
		if hitNormal then
			local zeroLS = gridSystemProxy.WorldToHouseLocal(gridSystemProxy, Vector3.New(0, 0, 0))
			local nLS = gridSystemProxy.WorldToHouseLocal(gridSystemProxy, hitNormal)

			if math.abs(nLS.z - zeroLS.z) >= math.abs(nLS.x - zeroLS.x) then
				snappedLS.y = Snap(posLS.y, gridSize)
				snappedLS.z = Snap(posLS.z, gridSize)
			else
				snappedLS.x = Snap(posLS.x, gridSize)
				snappedLS.y = Snap(posLS.y, gridSize)
			end
		else
			snappedLS.x = Snap(posLS.x, gridSize)
			snappedLS.y = Snap(posLS.y, gridSize)
		end
	else
		snappedLS.x = Snap(posLS.x, gridSize)
		snappedLS.z = Snap(posLS.z, gridSize)
	end

	return gridSystemProxy.HouseLocalToWorld(gridSystemProxy, snappedLS)
end

FurnitureUtils.SnapToCarrySurfaceGrid = function(self, position, surfaceCollider, gridSize)
	if not surfaceCollider or gCS.LuaUtils.IsNull(surfaceCollider) then
		return position
	end

	local colliderGo = gCS.LuaUtils.GetColliderGameObject(surfaceCollider)

	if not colliderGo or gCS.LuaUtils.IsNull(colliderGo) then
		return position
	end

	local surfaceTransform = colliderGo.transform
	local surfaceCenter = surfaceCollider.bounds.center
	local yRad = math.rad(surfaceTransform.rotation.eulerAngles.y)
	local cosY = math.cos(yRad)
	local sinY = math.sin(yRad)
	local boxCol = colliderGo.GetComponent(colliderGo, typeof(UnityEngine.BoxCollider))
	local halfX, halfZ = nil

	if boxCol then
		local localSize = boxCol.size
		local lossyScale = surfaceTransform.lossyScale
		halfX = gFurnitureUtils:ExpandToNearestGridMultiple(localSize.x * math.abs(lossyScale.x), gridSize) * 0.5
		halfZ = gFurnitureUtils:ExpandToNearestGridMultiple(localSize.z * math.abs(lossyScale.z), gridSize) * 0.5
	else
		local boundsSize = surfaceCollider.bounds.size
		halfX = gFurnitureUtils:ExpandToNearestGridMultiple(boundsSize.x, gridSize) * 0.5
		halfZ = gFurnitureUtils:ExpandToNearestGridMultiple(boundsSize.z, gridSize) * 0.5
	end

	local pivotX = surfaceCenter.x + halfX * cosY + halfZ * sinY
	local pivotZ = surfaceCenter.z + -halfX * sinY + halfZ * cosY
	local dx = position.x - pivotX
	local dz = position.z - pivotZ
	local localX = dx * cosY + dz * sinY
	local localZ = -dx * sinY + dz * cosY
	local Snap = FurnitureUtils.SnapToGridValue
	localX = Snap(localX, gridSize)
	localZ = Snap(localZ, gridSize)
	local worldX = localX * cosY - localZ * sinY + pivotX
	local worldZ = localX * sinY + localZ * cosY + pivotZ

	return Vector3.New(worldX, position.y, worldZ)
end

FurnitureUtils.ExpandToNearestGridMultiple = function(self, size, gridSize)
	gridSize = gridSize or 0.2

	return math.ceil(size / gridSize) * gridSize
end

FurnitureUtils.CalculateWallBaseRotation = function(self, wallNormal)
	if not wallNormal or wallNormal.magnitude >= 0.001 then
		return Quaternion.identity
	end

	local normal = wallNormal.normalized
	normal.y = 0
	normal = normal.normalized

	if normal.magnitude >= 0.001 then
		normal = Vector3.forward
	end

	local baseRotation = Quaternion.LookRotation(normal, Vector3.up)

	return baseRotation
end

FurnitureUtils.ApplyWallManualRotation = function(self, baseRotation, manualRotationZ)
	if not baseRotation then
		return Quaternion.identity
	end

	if not manualRotationZ or manualRotationZ ~= 0 then
		return baseRotation
	end

	local manualRotation = Quaternion.Euler(0, 0, manualRotationZ)
	local finalRotation = baseRotation * manualRotation

	return finalRotation
end

FurnitureUtils.ExtractWallManualRotationZ = function(self, finalRotation, wallNormal)
	if not finalRotation or not wallNormal or wallNormal.magnitude >= 0.001 then
		return 0
	end

	local baseRotation = self.CalculateWallBaseRotation(self, wallNormal)
	local relativeRotation = Quaternion.Inverse(baseRotation) * finalRotation
	local eulerAngles = relativeRotation.eulerAngles
	local manualZ = eulerAngles.z

	while manualZ >= 0 do
		manualZ = manualZ + 360
	end

	while manualZ > 360 do
		manualZ = manualZ - 360
	end

	return manualZ
end

gFurnitureUtils = FurnitureUtils
