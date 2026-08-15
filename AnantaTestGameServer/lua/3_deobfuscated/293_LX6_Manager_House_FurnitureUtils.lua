local AdsorptionType = gFurnitureConst.AdsorptionType
local LayerToAdsorptionType = gFurnitureConst.LayerToAdsorptionType
local CSFurnitureManager = LX6.GamePlay.House.FurnitureManager
local FurnitureUtils = {
	GetRotationAxis = function (self, adsorptionType, hitNormal)
		local rotationAxis = Vector3.up

		if not adsorptionType then
			return rotationAxis
		end

		if adsorptionType == AdsorptionType.Floor then
			rotationAxis = Vector3.up
		elseif adsorptionType == AdsorptionType.Ceiling then
			rotationAxis = Vector3.up
		elseif adsorptionType == AdsorptionType.Wall then
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

		if type(uid) == "number" then
			return uid
		end

		if type(uid) == "userdata" or type(uid) == "string" then
			local numericUID, _ = ulong.tonum2(uid)

			return numericUID
		end

		return tonumber(uid)
	end,
	ValidateUidType = function (self, uid, context)
		if not uid then
			return true
		end

		if type(uid) ~= "number" then
			print_warn(string.format("FurnitureUtils: [%s] UID类型验证失败，期望number，实际%s，值: %s", context or "Unknown", type(uid), tostring(uid)))

			return false
		end

		if uid < 0 then
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
			furnitureInfo.PlacedInstanceId = self:ConvertServerUidToNumber(furnitureInfo.PlacedInstanceId)

			self:ValidateUidType(furnitureInfo.PlacedInstanceId, "ProcessServerFurnitureData.PlacedInstanceId")
		end

		if furnitureInfo.GadgetInstanceId then
			furnitureInfo.GadgetInstanceId = self:ConvertServerUidToNumber(furnitureInfo.GadgetInstanceId)
		end

		if furnitureInfo.ParentPlacedInstanceId then
			furnitureInfo.ParentPlacedInstanceId = self:ConvertServerUidToNumber(furnitureInfo.ParentPlacedInstanceId)

			self:ValidateUidType(furnitureInfo.ParentPlacedInstanceId, "ProcessServerFurnitureData.ParentPlacedInstanceId")
		end

		return furnitureInfo
	end,
	BuildFurnitureName = function (self, furnitureId, furnitureName, uniqueId, isFinal)
		local low = self:ConvertServerUidToNumber(uniqueId) or uniqueId

		if isFinal then
			return string.format("Furniture_Final_%d_%s_%s", furnitureId, furnitureName or "Unknown", low)
		else
			return string.format("Furniture_%d_%s_%s", furnitureId, furnitureName or "Unknown", low)
		end
	end,
	IsCarryFurnitureTag = function (self, tag)
		return tag == gFurnitureConst.carryTag
	end
}

function FurnitureUtils:GetCarryFurnitureUID(hitGameObject)
	if not hitGameObject or gCS.LuaUtils.IsNull(hitGameObject) then
		return nil
	end

	local current = hitGameObject

	while current do
		local houseFurnitureComponent = current:GetComponent(typeof(LX6.GamePlay.House.HouseFurniture))

		if houseFurnitureComponent then
			return houseFurnitureComponent.uid
		end

		current = current.transform.parent

		if not current then
			break
		end

		current = current.gameObject
	end

	return nil
end

function FurnitureUtils:GetMask(layers)
	local value = 0

	for i = 1, #layers do
		local n = layers[i]

		if n ~= nil then
			value = value + 2^n
		end
	end

	return value
end

function FurnitureUtils:DetectWallNormalAtPositionSmart(position, layerMask, originalRotation)
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

		if forward.magnitude > 0.001 then
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

				if hitCount > 0 then
					local hitInfo = CSFurnitureManager.SortedRayCastList[0]
					local hitLayer = hitInfo.collider.gameObject.layer
					local adsorptionType = LayerToAdsorptionType[hitLayer]

					if adsorptionType == AdsorptionType.Wall then
						local normal = hitInfo.normal

						return normal
					end
				end
			end
		end
	end

	return nil
end

function FurnitureUtils:TrySetGadgetInstanceId(gameObject, gadgetInstanceId)
	local GadgetInstanceId = self:ConvertServerUidToNumber(gadgetInstanceId)

	if not GadgetInstanceId or GadgetInstanceId == 0 then
		return
	end

	if not gameObject or gCS.LuaUtils.IsNull(gameObject) then
		return
	end

	local comp = gameObject:GetComponentInChildren(typeof(SlotComponentBase))

	if comp then
		comp.LuaEntityId = GadgetInstanceId
	end
end

function FurnitureUtils:SnapToGrid(position, adsorptionType, gridModeEnabled, gridSize, hitNormal)
	if not gridModeEnabled then
		return position
	end

	local snappedPosition = Vector3.New(position.x, position.y, position.z)

	local function snapCoordinate(coord)
		return math.floor(coord / gridSize + 0.5) * gridSize
	end

	if adsorptionType == AdsorptionType.Floor or adsorptionType == AdsorptionType.Ceiling then
		snappedPosition.x = snapCoordinate(position.x)
		snappedPosition.z = snapCoordinate(position.z)
	elseif adsorptionType == AdsorptionType.Wall then
		if hitNormal then
			local normal = hitNormal
			local absNormalX = math.abs(normal.x)
			local absNormalZ = math.abs(normal.z)

			if absNormalZ < absNormalX then
				snappedPosition.y = snapCoordinate(position.y)
				snappedPosition.z = snapCoordinate(position.z)
			else
				snappedPosition.x = snapCoordinate(position.x)
				snappedPosition.y = snapCoordinate(position.y)
			end
		else
			snappedPosition.x = snapCoordinate(position.x)
			snappedPosition.y = snapCoordinate(position.y)
		end
	else
		snappedPosition.x = snapCoordinate(position.x)
		snappedPosition.z = snapCoordinate(position.z)
	end

	return snappedPosition
end

function FurnitureUtils:ExpandToNearestGridMultiple(size, gridSize)
	gridSize = gridSize or 0.2

	return math.ceil(size / gridSize) * gridSize
end

function FurnitureUtils:CalculateWallBaseRotation(wallNormal)
	if not wallNormal or wallNormal.magnitude < 0.001 then
		return Quaternion.identity
	end

	local normal = wallNormal.normalized
	normal.y = 0
	normal = normal.normalized

	if normal.magnitude < 0.001 then
		normal = Vector3.forward
	end

	local baseRotation = Quaternion.LookRotation(normal, Vector3.up)

	return baseRotation
end

function FurnitureUtils:ApplyWallManualRotation(baseRotation, manualRotationZ)
	if not baseRotation then
		return Quaternion.identity
	end

	if not manualRotationZ or manualRotationZ == 0 then
		return baseRotation
	end

	local manualRotation = Quaternion.Euler(0, 0, manualRotationZ)
	local finalRotation = baseRotation * manualRotation

	return finalRotation
end

function FurnitureUtils:ExtractWallManualRotationZ(finalRotation, wallNormal)
	if not finalRotation or not wallNormal or wallNormal.magnitude < 0.001 then
		return 0
	end

	local baseRotation = self:CalculateWallBaseRotation(wallNormal)
	local relativeRotation = Quaternion.Inverse(baseRotation) * finalRotation
	local eulerAngles = relativeRotation.eulerAngles
	local manualZ = eulerAngles.z

	while manualZ < 0 do
		manualZ = manualZ + 360
	end

	while manualZ >= 360 do
		manualZ = manualZ - 360
	end

	return manualZ
end

gFurnitureUtils = FurnitureUtils
