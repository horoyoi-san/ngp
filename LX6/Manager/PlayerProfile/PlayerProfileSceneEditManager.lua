-- Original chunk: @Lua\LuaFiles\LX6\Manager\PlayerProfile\PlayerProfileSceneEditManager.lua
-- Decompiled from: 00530_PlayerProfileSceneEditManager.lua_98c5315b5a53.luajit

local DriveUtils = LX6.Drive.DriveUtils
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local VehicleConfig = LTConfig.VehicleConfig
local LayerConstants = LX6.Constants.LayerConstants
local FilterEffectManager = LX6.Effect.FilterEffectManager
local PhotoUtils = LX6.Utils.PhotoUtils
local ImageConfig = LTConfig.ImageConfig
C_PlayerProfileSceneEditManager = DefClass("C_PlayerProfileSceneEditManager", C_PlayerProfileSceneEditManager)
local M = C_PlayerProfileSceneEditManager
local OpType = gPlayerProfileSceneOperationManager.OperationType
M.MODEL_RANGE_X = 2
M.MODEL_RANGE_Z = 2
M.RANKING_SLOT = 4
M.SPAWN_SPACING = 1
M.SPAWN_RAYCAST_HEIGHT = 10
M.CAMERA_CENTER_OFFSET = Vector3.New(0, 1.053, 2.817)
M.CAMERA_RANGE_X = 3
M.CAMERA_RANGE_Y = 2
M.CAMERA_RANGE_Z = 3
local StickerMode = {
	["\\x98\\xb2\\xaeo0\\xcb"] = 1,
	["z\\xa1\\xb0\\xa3\\xb2"] = 0
}
M.StickerMode = StickerMode
local DEFAULT_STICKER_MODE = StickerMode.ScreenUI
local STICKER_SCREEN_OFFSET_LIMIT = 0.5
local DEFAULT_STICKER_SCREEN_OFFSET_X = 0
local DEFAULT_STICKER_SCREEN_OFFSET_Y = 0
local DEFAULT_STICKER_SCREEN_DISTANCE = 3
local VEHICLE_OUTLINE_COLOR = Color.New(1, 1, 1, 1)

M.GetModelRange = function(self)
	local cfg = ImageConfig.ScenarioRange

	if cfg and #cfg > 2 then
		return cfg[1] / 2, cfg[2] / 2
	end

	return self.MODEL_RANGE_X, self.MODEL_RANGE_Z
end

M.GetCameraCenterOffset = function(self)
	local cfg = ImageConfig.CameraCenterOffset

	if cfg and #cfg > 3 then
		return Vector3.New(cfg[1], cfg[2], cfg[3])
	end

	return self.CAMERA_CENTER_OFFSET
end

M.GetCameraRange = function(self)
	local cfg = ImageConfig.CameraDownLimit

	if cfg and #cfg > 3 then
		return cfg[1], cfg[2], cfg[3]
	end

	return self.CAMERA_RANGE_X, self.CAMERA_RANGE_Y, self.CAMERA_RANGE_Z
end

M.GetCameraYawRange = function(self)
	local cfg = ImageConfig.CameraYawRange

	if cfg and #cfg > 2 then
		return cfg[1], cfg[2]
	end

	return -100, 100
end

M.GetCameraPitchRange = function(self)
	local cfg = ImageConfig.CameraPitchRange

	if cfg and #cfg > 2 then
		return cfg[1], cfg[2]
	end

	return -10, 70
end

M.ctor = function(self)
	self.characterModels = {}
	self.vehicleModels = {}
	self.stickerModels = {}
	self.currentSceneId = 0
	self.currentFilterId = 0
	self.currentFilterStrength = 100
	self.characterLoadingToken = 0
	self.vehicleLoadingToken = 0
	self.stickerLoadingToken = 0
	self.selectedCharacterIndex = 0
	self.selectedVehicleIndex = 0
	self.selectedStickerIndex = 0
	self.selectedOutlineUUID = nil
	self.onModelListChanged = nil
	self._transformActive = false
	self._cameraTransformActive = false
end

M.SetOnModelListChanged = function(self, callback)
	self.onModelListChanged = callback
end

M.NotifyModelListChanged = function(self)
	print_debug("[SceneEditManager] NotifyModelListChanged characterModels count=" .. tostring(#self.characterModels))

	if self.onModelListChanged then
		self.onModelListChanged()
	end
end

M.SelectCharacter = function(self, index)
	if self.selectedCharacterIndex ~= index then
		return
	end

	self:ClearSelection()

	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local go = entry.unit.PlayerObj

	if not go or gCS.LuaUtils.IsNull(go) then
		return
	end

	self.selectedCharacterIndex = index
	self.selectedOutlineUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, LX6.Effect.EffectPlayTag.Gameplay, "profileSceneEdit_char_" .. tostring(index), go.gameObject)
end

M.SelectVehicle = function(self, index)
	print_debug("[SceneEditManager] SelectVehicle index=" .. tostring(index) .. " current=" .. tostring(self.selectedVehicleIndex))

	if self.selectedVehicleIndex ~= index then
		return
	end

	self:ClearSelection()

	local entry = self.vehicleModels[index]

	if not entry or not entry.vehicle then
		print_debug("[SceneEditManager] SelectVehicle BAIL: no entry or no vehicle")

		return
	end

	local go = entry.vehicle.gameObject

	if not go or gCS.LuaUtils.IsNull(go) then
		print_debug("[SceneEditManager] SelectVehicle BAIL: go is null")

		return
	end

	self.selectedVehicleIndex = index

	print_debug("[SceneEditManager] SelectVehicle outline on " .. tostring(go.name))
	self:SetVehicleOutlineVisible(true)
end

M.SetVehicleOutlineVisible = function(self, visible)
	if visible then
		gCS.LuaUtils.SetVehicleOutlineColor(VEHICLE_OUTLINE_COLOR)
		gCS.LuaUtils.SetVehicleOutlineWidth(2)
		gCS.LuaUtils.SetVehicleOutlineVisible(true)
	else
		gCS.LuaUtils.SetVehicleOutlineVisible(false)
	end
end

M.FindVehicleIndexByConfigId = function(self, vehicleConfigId)
	for i, entry in ipairs(self.vehicleModels) do
		if entry.vehicleId ~= vehicleConfigId then
			return i
		end
	end

	return 0
end

M.FindCharacterIndexBySpiritId = function(self, spiritId)
	for i, entry in ipairs(self.characterModels) do
		if entry.spiritId ~= spiritId then
			return i
		end
	end

	return 0
end

M.GetSelectedSpiritId = function(self)
	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		return entry and entry.spiritId or 0
	end

	return 0
end

M.ClearSelection = function(self)
	print_debug("[SceneEditManager] ClearSelection charIdx=" .. tostring(self.selectedCharacterIndex) .. " vehIdx=" .. tostring(self.selectedVehicleIndex) .. " uuid=" .. tostring(self.selectedOutlineUUID))

	local prevStickerIndex = self.selectedStickerIndex

	if self.selectedOutlineUUID then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.selectedOutlineUUID)

		self.selectedOutlineUUID = nil
	end

	self.selectedCharacterIndex = 0
	self.selectedVehicleIndex = 0
	self.selectedStickerIndex = 0

	self:SetVehicleOutlineVisible(false)

	if prevStickerIndex and prevStickerIndex <= 0 then
		self:ApplyStickerRenderOnTop(self.stickerModels and self.stickerModels[prevStickerIndex])
	end
end

M.RotateSelectedModel = function(self, angleDeg)
	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		if entry and entry.unit then
			local t = entry.unit.PlayerObj

			if t and not gCS.LuaUtils.IsNull(t) then
				local euler = t.localEulerAngles
				euler.y = euler.y + angleDeg
				t.localEulerAngles = euler
				entry.euler = euler
			end
		end
	elseif self.selectedVehicleIndex <= 0 then
		local entry = self.vehicleModels[self.selectedVehicleIndex]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local t = entry.vehicle.gameObject.transform
			local euler = t.eulerAngles
			euler.y = euler.y + angleDeg
			t.eulerAngles = euler
			entry.euler = euler
		end
	end
end

M.RaycastSelectModel = function(self, screenPos)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return 0, nil, 
	end

	local ray = cam:ScreenPointToRay(Vector3.New(screenPos.x, screenPos.y, 0))
	local npcMask = bit.lshift(1, LayerConstants.Npc)
	local vehicleMask = bit.lshift(1, LayerConstants._Vehicle)
	local decorationMask = bit.lshift(1, LayerConstants._Decoration)
	local layerMask = bit.bor(npcMask, vehicleMask, decorationMask)
	local hits = gCS.LuaUtils.RaycastAll(ray.origin, ray.direction, 100, layerMask, false)

	if not hits or hits.Length ~= 0 then
		return 0, nil, 
	end

	for i = 0, hits.Length - 1 do
		local hitTransform = hits[i].transform

		if hitTransform then
			for idx, entry in ipairs(self.characterModels) do
				if entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) and hitTransform:IsChildOf(entry.unit.PlayerObj) then
					return idx, "character", hits[i].point
				end
			end

			for idx, entry in ipairs(self.vehicleModels) do
				if entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) and hitTransform:IsChildOf(entry.vehicle.gameObject.transform) then
					return idx, "vehicle", hits[i].point
				end
			end

			for idx, entry in ipairs(self.stickerModels) do
				if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) and hitTransform:IsChildOf(entry.gameObject.transform) then
					return idx, "sticker", hits[i].point
				end
			end
		end
	end

	return 0, nil, 
end

M.OffsetSelectedModelPosition = function(self, dx, dz)
	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		if entry and entry.unit then
			local t = entry.unit.PlayerObj

			if t and not gCS.LuaUtils.IsNull(t) then
				local pos = t.position
				local nx, nz = self:ClampToRange(pos.x + dx, pos.z + dz)
				pos.x = nx
				pos.z = nz
				t.position = pos
				entry.position = pos
			end
		end
	elseif self.selectedVehicleIndex <= 0 then
		local entry = self.vehicleModels[self.selectedVehicleIndex]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local t = entry.vehicle.gameObject.transform
			local pos = t.position
			local nx, nz = self:ClampToRange(pos.x + dx, pos.z + dz)
			pos.x = nx
			pos.z = nz
			t.position = pos
			entry.position = pos
		end
	end
end

M._SnapshotSelectedTransform = function(self)
	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		if entry and entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			return {
				["q+s_"] = "@Om{O*",
				spiritId = entry.spiritId,
				position = Vector3.New(entry.unit.PlayerObj.position.x, entry.unit.PlayerObj.position.y, entry.unit.PlayerObj.position.z),
				euler = Vector3.New(entry.unit.PlayerObj.localEulerAngles.x, entry.unit.PlayerObj.localEulerAngles.y, entry.unit.PlayerObj.localEulerAngles.z)
			}
		end
	elseif self.selectedVehicleIndex <= 0 then
		local entry = self.vehicleModels[self.selectedVehicleIndex]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local t = entry.vehicle.gameObject.transform

			return {
				["q+s_"] = "\\xcf\\xde(\\xf4",
				vehicleId = entry.vehicleId,
				position = Vector3.New(t.position.x, t.position.y, t.position.z),
				euler = Vector3.New(t.eulerAngles.x, t.eulerAngles.y, t.eulerAngles.z)
			}
		end
	elseif self.selectedStickerIndex <= 0 then
		local entry = self.stickerModels[self.selectedStickerIndex]

		if entry and entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			local t = entry.gameObject.transform
			local billboard = entry.gameObject:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))
			local rotOffset = billboard and billboard.rotationOffset or Vector3.zero

			return {
				["q+s_"] = "\\xca\\xcf!\\xe3",
				stickerId = entry.stickerId,
				position = Vector3.New(t.position.x, t.position.y, t.position.z),
				scale = entry.scale or t.localScale.x,
				rotationOffset = Vector3.New(rotOffset.x, rotOffset.y, rotOffset.z),
				billboard = self:SnapshotStickerBillboard(entry)
			}
		end
	end

	return nil
end

M.BeginTransform = function(self)
	if self._transformActive then
		return
	end

	local snap = self:_SnapshotSelectedTransform()

	if not snap then
		return
	end

	self._transformActive = true

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.TRANSFORM_MODEL, snap)
end

M.EndTransform = function(self)
	if not self._transformActive then
		return
	end

	self._transformActive = false
	local snap = self:_SnapshotSelectedTransform()

	if snap then
		gPlayerProfileSceneOperationManager:EndOperation(snap)
	else
		gPlayerProfileSceneOperationManager:CancelOperation()
	end
end

M.BeginCameraTransform = function(self)
	if self._cameraTransformActive then
		return
	end

	local mgr = gPlayerProfileSceneManager
	local camPos = mgr:GetCameraPosition()

	if not camPos then
		return
	end

	self._cameraTransformActive = true
	local camEuler = mgr:GetCameraEuler()

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.MOVE_CAMERA, {
		cameraPos = Vector3.New(camPos.x, camPos.y, camPos.z),
		cameraEuler = camEuler and Vector3.New(camEuler.x, camEuler.y, camEuler.z) or nil
	})
end

M.EndCameraTransform = function(self)
	if not self._cameraTransformActive then
		return
	end

	self._cameraTransformActive = false
	local mgr = gPlayerProfileSceneManager
	local camPos = mgr:GetCameraPosition()

	if camPos then
		local camEuler = mgr:GetCameraEuler()

		gPlayerProfileSceneOperationManager:EndOperation({
			cameraPos = Vector3.New(camPos.x, camPos.y, camPos.z),
			cameraEuler = camEuler and Vector3.New(camEuler.x, camEuler.y, camEuler.z) or nil
		})
	else
		gPlayerProfileSceneOperationManager:CancelOperation()
	end
end

M._ApplyTransformState = function(self, state)
	if not state then
		return
	end

	if state.kind ~= "character" then
		local idx = self:FindCharacterIndexBySpiritId(state.spiritId)
		local entry = self.characterModels[idx]

		if entry and entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			entry.unit.PlayerObj.position = state.position
			entry.unit.PlayerObj.localEulerAngles = state.euler
			entry.position = state.position
			entry.euler = state.euler
		end
	elseif state.kind ~= "vehicle" then
		local idx = self:FindVehicleIndexByConfigId(state.vehicleId)
		local entry = self.vehicleModels[idx]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local t = entry.vehicle.gameObject.transform
			t.position = state.position
			t.eulerAngles = state.euler
			entry.position = state.position
			entry.euler = state.euler
		end
	elseif state.kind ~= "sticker" then
		local idx = self:FindStickerIndexByConfigId(state.stickerId)
		local entry = self.stickerModels[idx]

		if entry and entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			local t = entry.gameObject.transform
			local isScreenUI = state.billboard and state.billboard.mode ~= StickerMode.ScreenUI

			if state.billboard then
				self:ApplyStickerBillboardState(entry, state.billboard)
			end

			if state.position and not isScreenUI then
				t.position = state.position
				entry.position = state.position
			end

			if state.scale and state.scale <= 0 then
				t.localScale = Vector3.New(state.scale, state.scale, state.scale)
				entry.scale = state.scale
			end

			if state.rotationOffset then
				self:ApplyStickerRotationOffset(entry, state.rotationOffset)
			end
		end
	end
end

M.GetSelectedModelPosition = function(self)
	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		if entry and entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			return entry.unit.PlayerObj.position
		end
	elseif self.selectedVehicleIndex <= 0 then
		local entry = self.vehicleModels[self.selectedVehicleIndex]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			return entry.vehicle.gameObject.transform.position
		end
	elseif self.selectedStickerIndex <= 0 then
		local entry = self.stickerModels[self.selectedStickerIndex]

		if entry and entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			return entry.gameObject.transform.position
		end
	end

	return nil
end

M.ClampToRange = function(self, x, z)
	local sceneCenter = gPlayerProfileSceneManager.centerPos or Vector3.zero
	local rx, rz = self:GetModelRange()
	x = Mathf.Clamp(x, sceneCenter.x - rx, sceneCenter.x + rx)
	z = Mathf.Clamp(z, sceneCenter.z - rz, sceneCenter.z + rz)

	return x, z
end

M.GetSpawnPositionFromCamera = function(self)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return nil
	end

	local sw = UnityEngine.Screen.width
	local sh = UnityEngine.Screen.height
	local screenCenter = Vector3.New(sw * 0.5, sh * 0.5, 0)
	local ray = cam:ScreenPointToRay(screenCenter)
	local modelPos = gPlayerProfileSceneManager.modelPos or gPlayerProfileSceneManager.centerPos or Vector3.zero
	local planeY = modelPos.y
	local denom = ray.direction.y

	if math.abs(denom) >= 0.0001 then
		return nil
	end

	local t = (planeY - ray.origin.y) / denom

	if t >= 0 then
		return nil
	end

	local hitX = ray.origin.x + ray.direction.x * t
	local hitZ = ray.origin.z + ray.direction.z * t
	local cx, cz = self:ClampToRange(hitX, hitZ)

	return Vector3.New(cx, planeY, cz)
end

M.FindNonOverlapPosition = function(self)
	local modelPos = gPlayerProfileSceneManager.modelPos or gPlayerProfileSceneManager.centerPos or Vector3.zero
	local planeY = modelPos.y
	local rayHeight = self.SPAWN_RAYCAST_HEIGHT
	local spacing = self.SPAWN_SPACING
	local npcMask = bit.lshift(1, LayerConstants.Npc)
	local vehicleMask = bit.lshift(1, LayerConstants._Vehicle)
	local layerMask = bit.bor(npcMask, vehicleMask)
	local rx = self:GetModelRange()
	local maxSteps = math.floor(rx / spacing)
	local lastPos = Vector3.New(modelPos.x, planeY, modelPos.z)

	local isOccupied = function(x, z)
		for _, entry in ipairs(self.characterModels) do
			if entry.position and not entry.cancelled then
				local dx = entry.position.x - x
				local dz = entry.position.z - z

				if dx * dx + dz * dz >= spacing * spacing then
					return true
				end
			end
		end

		for _, entry in ipairs(self.vehicleModels) do
			if entry.position and not entry.cancelled then
				local dx = entry.position.x - x
				local dz = entry.position.z - z

				if dx * dx + dz * dz >= spacing * spacing then
					return true
				end
			end
		end

		local origin = Vector3.New(x, planeY + rayHeight, z)
		local hit = gCS.LuaUtils.Raycast(origin, Vector3.down, rayHeight + 1, layerMask)

		return hit
	end

	if not isOccupied(modelPos.x, modelPos.z) then
		return Vector3.New(modelPos.x, planeY, modelPos.z)
	end

	for step = 1, maxSteps do
		local offsetX = spacing * step
		local leftX = modelPos.x - offsetX
		local rightX = modelPos.x + offsetX

		if leftX > modelPos.x - rx then
			if not isOccupied(leftX, modelPos.z) then
				return Vector3.New(leftX, planeY, modelPos.z)
			end

			lastPos = Vector3.New(leftX, planeY, modelPos.z)
		end

		if rightX < modelPos.x + rx then
			if not isOccupied(rightX, modelPos.z) then
				return Vector3.New(rightX, planeY, modelPos.z)
			end

			lastPos = Vector3.New(rightX, planeY, modelPos.z)
		end
	end

	return lastPos
end

M.ClampToRangeWithDirection = function(self, x, z, fromX, fromZ)
	local sceneCenter = gPlayerProfileSceneManager.centerPos or Vector3.zero
	local rx, rz = self:GetModelRange()
	local minX = sceneCenter.x - rx
	local maxX = sceneCenter.x + rx
	local minZ = sceneCenter.z - rz
	local maxZ = sceneCenter.z + rz

	if minX < x and x < maxX and minZ < z and z < maxZ then
		return x, z
	end

	local dirX = x - fromX
	local dirZ = z - fromZ

	if dirX ~= 0 and dirZ ~= 0 then
		return Mathf.Clamp(x, minX, maxX), Mathf.Clamp(z, minZ, maxZ)
	end

	local t = 1

	if dirX == 0 then
		if x >= minX then
			t = math.min(t, (minX - fromX) / dirX)
		elseif maxX >= x then
			t = math.min(t, (maxX - fromX) / dirX)
		end
	end

	if dirZ == 0 then
		if z >= minZ then
			t = math.min(t, (minZ - fromZ) / dirZ)
		elseif maxZ >= z then
			t = math.min(t, (maxZ - fromZ) / dirZ)
		end
	end

	if t >= 0 then
		t = 0
	end

	local resultX = fromX + dirX * t
	local resultZ = fromZ + dirZ * t

	return Mathf.Clamp(resultX, minX, maxX), Mathf.Clamp(resultZ, minZ, maxZ)
end

M.SetSelectedModelPositionXZ = function(self, x, z)
	local camPos = gPlayerProfileSceneManager:GetCameraPosition()
	local fromX = camPos and camPos.x or 0
	local fromZ = camPos and camPos.z or 0
	x, z = self:ClampToRangeWithDirection(x, z, fromX, fromZ)

	if self.selectedCharacterIndex <= 0 then
		local entry = self.characterModels[self.selectedCharacterIndex]

		if entry and entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			local pos = entry.unit.PlayerObj.position
			pos.x = x
			pos.z = z
			entry.unit.PlayerObj.position = pos
			entry.position = pos
		end
	elseif self.selectedVehicleIndex <= 0 then
		local entry = self.vehicleModels[self.selectedVehicleIndex]

		if entry and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local t = entry.vehicle.gameObject.transform
			local pos = t.position
			pos.x = x
			pos.z = z
			t.position = pos
			entry.position = pos
		end
	end
end

M.AddMergedBoxCollider = function(self, go)
	if not go or gCS.LuaUtils.IsNull(go) then
		return
	end
end

M.AddRendererBoxCollider = function(self, tf)
	if not tf or gCS.LuaUtils.IsNull(tf) then
		return
	end
end

M._GetSpiritFashionWearInfo = function(self, spiritId)
	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[spiritId]

	if not spiritFashionsInfo then
		return fashionInfo
	end

	local wearList = spiritFashionsInfo.SpiritWearFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo.WearFashionInfoList

	if wearList then
		for i = 1, wearList.Count do
			table.insert(fashionInfo.WearFashionInfoList, {
				FashionId = wearList[i].FashionId
			})
		end
	end

	local editList = spiritFashionsInfo.WearFashionEditInfoList

	if editList then
		for i = 1, editList.Count do
			local editInfo = editList[i]

			if editInfo.SpiritId ~= spiritId then
				table.insert(fashionInfo.WearFashionEditInfoList, {
					FashionId = editInfo.FashionId,
					SpiritId = editInfo.SpiritId,
					Scale = editInfo.Scale,
					Offset = editInfo.Offset,
					Rotation = editInfo.Rotation
				})
			end
		end
	end

	return fashionInfo
end

M.AddCharacterModel = function(self, spiritId, transformData, onLoadComplete)
	if not spiritId or spiritId ~= 0 then
		return false
	end

	local maxCount = ImageConfig.ScenarioMaxRoleCount or 10

	if maxCount < #self.characterModels then
		local text = string.format(LTConfig.MessageConfig.GetConfig(ImageConfig.MaxCharacterLimitReached).Content, maxCount)

		gDisplayMessageMgr:ShowMessageContent(text)

		return false
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		return
	end

	local agentId = fightSpiritConfig.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)

	if not agentConfig then
		return
	end

	local beforeState = {
		spiritId = spiritId
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.ADD_CHARACTER, beforeState)

	self.characterLoadingToken = self.characterLoadingToken + 1
	local currentToken = self.characterLoadingToken
	local pos = transformData and transformData.position or self:FindNonOverlapPosition() or gPlayerProfileSceneManager.modelPos or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	local euler = transformData and transformData.eulerAngles or gPlayerProfileSceneManager.modelEuler or gPlayerProfileSceneManager.centerEuler or Vector3.New(0, 0, 0)
	local entry = {
		spiritId = spiritId,
		position = pos,
		euler = euler
	}

	table.insert(self.characterModels, entry)

	local entryIndex = #self.characterModels

	gPlayerProfileSceneOperationManager:EndOperation({
		spiritId = spiritId,
		index = entryIndex,
		position = pos,
		euler = euler
	})
	self:NotifyModelListChanged()

	local fashionWearInfo = self:_GetSpiritFashionWearInfo(spiritId)
	local defaultActionId, defaultActionGroup = gPlayerProfileSceneManager:GetDefaultAction()

	gPlayerProfileSceneManager:LoadCharacterUnit(spiritId, pos, euler, fashionWearInfo, function (unit)
		if entry.cancelled then
			if unit then
				unit:DestroyUnit(true)
			end

			return
		end

		self:AddRendererBoxCollider(unit.PlayerObj)
		unit.PlayerObj.gameObject:SetLayerRecursively(LayerConstants.Npc)

		entry.unit = unit

		if defaultActionId <= 0 then
			gPlayerProfileSceneManager:PlayActionOnUnit(unit, defaultActionId, defaultActionGroup)

			entry.currentActionId = defaultActionId
			entry.currentActionGroup = defaultActionGroup
		end

		self:SelectCharacter(entryIndex)
		self:NotifyModelListChanged()

		if onLoadComplete then
			onLoadComplete(unit)
		end
	end)
end

M.RemoveCharacterModel = function(self, index)
	local entry = self.characterModels[index]

	if not entry then
		return
	end

	local beforeState = {
		spiritId = entry.spiritId,
		index = index,
		position = entry.position,
		euler = entry.euler,
		actionId = entry.currentActionId,
		actionGroup = entry.currentActionGroup,
		dressSlot = entry.currentDressPresetSlot,
		expressionId = entry.currentExpressionId,
		fashionIdList = entry.currentFashionIdList
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.REMOVE_CHARACTER, beforeState)
	self:RemoveCharacterModelRaw(index)
	gPlayerProfileSceneOperationManager:EndOperation({
		spiritId = entry.spiritId
	})
	self:NotifyModelListChanged()
end

M.RemoveCharacterBySpiritId = function(self, spiritId)
	for i = #self.characterModels, 1, -1 do
		if self.characterModels[i].spiritId ~= spiritId then
			self:RemoveCharacterModelRaw(i)
		end
	end
end

M.RemoveCharacterBySpiritIdWithUndo = function(self, spiritId)
	for i = #self.characterModels, 1, -1 do
		if self.characterModels[i].spiritId ~= spiritId then
			self:RemoveCharacterModel(i)

			return
		end
	end
end

M.RemoveCharacterModelRaw = function(self, index)
	local entry = self.characterModels[index]

	if not entry then
		return
	end

	entry.cancelled = true

	if entry.unit then
		entry.unit:DestroyUnit(true)
	end

	table.remove(self.characterModels, index)

	if self.selectedCharacterIndex ~= index then
		self:ClearSelection()
	elseif index >= self.selectedCharacterIndex then
		self.selectedCharacterIndex = self.selectedCharacterIndex - 1
	end
end

M.SelectOrLoadVehicle = function(self, vehicleId)
	if not vehicleId or vehicleId ~= 0 then
		return false
	end

	local existIndex = self:FindVehicleIndexByConfigId(vehicleId)

	if existIndex <= 0 then
		self:SelectVehicle(existIndex)

		return true
	end

	local maxCount = ImageConfig.ScenarioMaxCarCount or 1

	if maxCount <= #self.vehicleModels then
		return self:AddVehicleModel(vehicleId)
	end

	local replaceIndex = self.selectedVehicleIndex <= 0 and self.selectedVehicleIndex or #self.vehicleModels

	return self:ReplaceVehicleModel(replaceIndex, vehicleId)
end

M.GetVehicleTransform = function(self, entry)
	if not entry then
		return nil, 
	end

	local go = entry.vehicle and entry.vehicle.gameObject

	if go and not gCS.LuaUtils.IsNull(go) then
		local t = go.transform
		local pos = t.position
		local euler = t.eulerAngles

		return Vector3.New(pos.x, pos.y, pos.z), Vector3.New(euler.x, euler.y, euler.z)
	end

	return entry.position, entry.euler
end

M.ReplaceVehicleModel = function(self, index, vehicleId)
	local entry = self.vehicleModels[index]

	if not entry then
		return false
	end

	if entry.vehicleId ~= vehicleId then
		self:SelectVehicle(index)

		return true
	end

	if not VehicleConfig.GetConfig(vehicleId) then
		return false
	end

	local pos, euler = self:GetVehicleTransform(entry)
	local oldVehicleId = entry.vehicleId

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.REPLACE_VEHICLE, {
		vehicleId = oldVehicleId,
		position = pos,
		euler = euler
	})
	self:ReplaceVehicleRaw(oldVehicleId, vehicleId, pos, euler)
	gPlayerProfileSceneOperationManager:EndOperation({
		vehicleId = vehicleId,
		position = pos,
		euler = euler
	})

	return true
end

M.AddVehicleModel = function(self, vehicleId, transformData, onLoadComplete)
	if not vehicleId or vehicleId ~= 0 then
		return false
	end

	local existIndex = self:FindVehicleIndexByConfigId(vehicleId)

	if existIndex <= 0 then
		self:SelectVehicle(existIndex)

		return true
	end

	local maxCount = ImageConfig.ScenarioMaxCarCount or 1

	if maxCount < #self.vehicleModels then
		gDisplayMessageMgr:ShowMessage(ImageConfig.MaxVehicleLimitReached)

		return false
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	if not cfg then
		return false
	end

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.ADD_VEHICLE, {
		vehicleId = vehicleId
	})

	self.vehicleLoadingToken = self.vehicleLoadingToken + 1
	local currentToken = self.vehicleLoadingToken
	local pos = transformData and transformData.position or gPlayerProfileSceneManager.carPos or self:GetSpawnPositionFromCamera() or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	local euler = transformData and transformData.eulerAngles or gPlayerProfileSceneManager.carEuler or gPlayerProfileSceneManager.centerEuler or Vector3.New(0, 0, 0)
	local vehicleDetail = gPlayerProfileSceneManager:GetOwnedVehicleDetail(vehicleId)
	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = pos
	spawnParam.facing = euler.y
	spawnParam.forceDummy = true
	spawnParam.disableCollision = false
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

	spawnParam.beforeLoadAction = function(vehicle)
		if currentToken == self.vehicleLoadingToken then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if vehicleDetail then
			gPlayerProfileSceneManager:ApplyPlayerVehicleParts(vehicle, vehicleDetail)
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		print_debug("[SceneEditManager] AddVehicle afterLoadAction vehicleId=" .. tostring(vehicleId) .. " token=" .. tostring(currentToken) .. " self.token=" .. tostring(self.vehicleLoadingToken))

		if currentToken == self.vehicleLoadingToken then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
			print_debug("[SceneEditManager] AddVehicle afterLoadAction BAIL: go null")

			return
		end

		vehicle.gameObject.transform.eulerAngles = euler

		vehicle:SetMainLightOn(true, true)
		gCS.LuaUtils.ForceSetPlayerTransform(vehicle.gameObject.transform)
		self:AddMergedBoxCollider(vehicle.gameObject)
		self:EnableVehicleColliders(vehicle)

		local entry = {
			vehicleId = vehicleId,
			vehicle = vehicle,
			position = pos,
			euler = euler
		}

		table.insert(self.vehicleModels, entry)
		gPlayerProfileSceneOperationManager:EndOperation({
			vehicleId = vehicleId,
			index = #self.vehicleModels,
			position = pos,
			euler = euler
		})
		self:SelectVehicle(#self.vehicleModels)
		self:NotifyModelListChanged()

		if onLoadComplete then
			onLoadComplete(vehicle)
		end
	end

	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)

	return true
end

M.RemoveVehicleModel = function(self, index)
	local entry = self.vehicleModels[index]

	if not entry then
		return
	end

	local beforeState = {
		vehicleId = entry.vehicleId,
		index = index,
		position = entry.position,
		euler = entry.euler
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.REMOVE_VEHICLE, beforeState)
	self:RemoveVehicleModelRaw(index)
	gPlayerProfileSceneOperationManager:EndOperation({
		vehicleId = entry.vehicleId
	})
end

M.RemoveVehicleModelRaw = function(self, index)
	local entry = self.vehicleModels[index]

	if not entry then
		return
	end

	if entry.vehicle then
		DriveUtils.DestroyVehicleClient(entry.vehicle.uid)
	end

	table.remove(self.vehicleModels, index)

	if self.selectedVehicleIndex ~= index then
		self:ClearSelection()
	elseif index >= self.selectedVehicleIndex then
		self.selectedVehicleIndex = self.selectedVehicleIndex - 1
	end
end

M.EnableVehicleColliders = function(self, vehicle)
	if not vehicle or not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
		return
	end
end

M.FindStickerIndexByConfigId = function(self, stickerId)
	for i, entry in ipairs(self.stickerModels) do
		if entry.stickerId ~= stickerId then
			return i
		end
	end

	return 0
end

M.GetStickerRotationOffset = function(self, entry)
	if not entry or not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return nil
	end

	local billboard = entry.gameObject:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))

	if not billboard then
		return nil
	end

	local offset = billboard.rotationOffset

	return Vector3.New(offset.x, offset.y, offset.z)
end

M.ApplyStickerRotationOffset = function(self, entry, offset)
	if not entry or not offset then
		return
	end

	if not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return
	end

	local billboard = entry.gameObject:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))

	if not billboard then
		return
	end

	billboard.rotationOffset = offset
	entry.rotationOffset = offset
	local cam = gCS.CameraDataMgr.MainCamera

	if cam and not gCS.LuaUtils.IsNull(cam) then
		entry.gameObject.transform.rotation = cam.transform.rotation * Quaternion.Euler(offset)
	end
end

M.SnapshotStickerBillboard = function(self, entry)
	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return nil
	end

	return {
		mode = billboard.mode ~= StickerMode.ScreenUI and StickerMode.ScreenUI or StickerMode.World,
		offsetX = billboard.offsetX,
		offsetY = billboard.offsetY,
		distanceToCamera = billboard.distanceToCamera
	}
end

M.ApplyStickerBillboardState = function(self, entry, state)
	if not state then
		return
	end

	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	local isScreenUI = state.mode ~= StickerMode.ScreenUI

	if isScreenUI and state.offsetX ~= nil and state.offsetY ~= nil then
		self:ApplyRestoredStickerScreenUIMode(entry, billboard)

		return
	end

	if state.offsetX then
		billboard.offsetX = state.offsetX
	end

	if state.offsetY then
		billboard.offsetY = state.offsetY
	end

	if state.distanceToCamera and state.distanceToCamera <= 0 then
		billboard.distanceToCamera = state.distanceToCamera
	end

	billboard.mode = isScreenUI and StickerMode.ScreenUI or StickerMode.World

	if billboard.mode ~= StickerMode.ScreenUI then
		self:_ApplyScreenUIStickerPosition(entry, billboard)
	end

	self:ApplyStickerRenderOnTop(entry, billboard)
end

M.SnapshotStickerEntry = function(self, entry)
	if not entry then
		return nil
	end

	local pos = entry.position
	local scale = entry.scale

	if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
		local t = entry.gameObject.transform
		pos = Vector3.New(t.position.x, t.position.y, t.position.z)
		scale = scale or t.localScale.x
	end

	return {
		stickerId = entry.stickerId,
		meshPath = entry.meshPath,
		position = pos,
		scale = scale,
		rotationOffset = self:GetStickerRotationOffset(entry),
		billboard = self:SnapshotStickerBillboard(entry)
	}
end

M.AddStickerModel = function(self, stickerId, meshPath, pos)
	if not stickerId or stickerId ~= 0 then
		return
	end

	if not meshPath or meshPath ~= "" then
		return
	end

	local existIndex = self:FindStickerIndexByConfigId(stickerId)

	if existIndex <= 0 then
		self:SelectSticker(existIndex)

		return
	end

	local maxCount = ImageConfig.StickerLimit or 5

	if maxCount < #self.stickerModels then
		gDisplayMessageMgr:ShowMessage(ImageConfig.MaxStickerLimitReached)

		return
	end

	local useDefaultScreenUI = pos ~= nil and DEFAULT_STICKER_MODE ~= StickerMode.ScreenUI
	local spawnPos = pos

	if useDefaultScreenUI then
		spawnPos = self:CalcDefaultStickerScreenUIPosition()
	end

	spawnPos = spawnPos or self:GetSpawnPositionFromCamera() or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	local opStarted = gPlayerProfileSceneOperationManager:BeginOperation(OpType.ADD_STICKER, {
		stickerId = stickerId,
		meshPath = meshPath
	})

	local cancelOp = function()
		if opStarted then
			gPlayerProfileSceneOperationManager:CancelOperation()
		end
	end

	local currentToken = self.stickerLoadingToken or 0

	print_debug("[SceneEditManager] AddStickerModel stickerId=" .. tostring(stickerId) .. " meshPath=" .. tostring(meshPath) .. " pos=" .. tostring(pos))
	gResourceManager:LoadAssetWithCallBack(meshPath, typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == self.stickerLoadingToken then
			cancelOp()
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp or not loadOp.asset then
			cancelOp()

			return
		end

		local go = GameObject.Instantiate(loadOp.asset)

		if not go or gCS.LuaUtils.IsNull(go) then
			cancelOp()

			return
		end

		go.transform.position = spawnPos
		go.transform.eulerAngles = Vector3.zero

		go:SetLayerRecursively(LayerConstants._Decoration)
		go:AddComponent(typeof("LX6.Utils.BillboardFaceCamera"))

		local entry = {
			stickerId = stickerId,
			gameObject = go,
			loadOp = loadOp,
			meshPath = meshPath,
			position = spawnPos,
			euler = Vector3.zero
		}

		table.insert(self.stickerModels, entry)

		if useDefaultScreenUI then
			self:ApplyDefaultStickerScreenUIMode(entry)
		else
			self:SetStickerMode(entry, DEFAULT_STICKER_MODE)
		end

		if opStarted then
			gPlayerProfileSceneOperationManager:EndOperation(self:SnapshotStickerEntry(entry))
		end

		self:SelectSticker(#self.stickerModels)
		self:NotifyModelListChanged()
	end)
end

M.AddStickerModelRaw = function(self, stickerId, meshPath, pos, scale, rotationOffset, billboardState)
	if not stickerId or stickerId ~= 0 then
		return
	end

	if not meshPath or meshPath ~= "" then
		return
	end

	local spawnPos = pos or self:GetSpawnPositionFromCamera() or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	local currentToken = self.stickerLoadingToken or 0

	gResourceManager:LoadAssetWithCallBack(meshPath, typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == self.stickerLoadingToken then
			gResourceManager:UnloadAssetLoadOp(loadOp)

			return
		end

		if not loadOp or not loadOp.asset then
			return
		end

		local go = GameObject.Instantiate(loadOp.asset)

		if not go or gCS.LuaUtils.IsNull(go) then
			return
		end

		go.transform.position = spawnPos
		go.transform.eulerAngles = Vector3.zero

		if scale and scale <= 0 then
			go.transform.localScale = Vector3.New(scale, scale, scale)
		end

		go:SetLayerRecursively(LayerConstants._Decoration)
		go:AddComponent(typeof("LX6.Utils.BillboardFaceCamera"))

		local entry = {
			stickerId = stickerId,
			gameObject = go,
			loadOp = loadOp,
			meshPath = meshPath,
			position = spawnPos,
			euler = Vector3.zero,
			scale = scale
		}

		table.insert(self.stickerModels, entry)

		if rotationOffset then
			self:ApplyStickerRotationOffset(entry, rotationOffset)
		end

		if billboardState then
			self:ApplyStickerBillboardState(entry, billboardState)
		end

		self:NotifyModelListChanged()
	end)
end

M.SelectSticker = function(self, index)
	if self.selectedStickerIndex ~= index then
		return
	end

	self:ClearSelection()

	local entry = self.stickerModels[index]

	if not entry or not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return
	end

	self.selectedStickerIndex = index
	self.selectedOutlineUUID = gCS.EffectMgr:PlayGameObjectMaterialEffect(53610525, LX6.Effect.EffectPlayTag.Gameplay, "profileSceneEdit_sticker_" .. tostring(index), entry.gameObject)

	self:ApplyStickerRenderOnTop(entry)
end

M.RemoveStickerModel = function(self, index)
	local entry = self.stickerModels[index]

	if not entry then
		return
	end

	local beforeState = self:SnapshotStickerEntry(entry)

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.REMOVE_STICKER, beforeState)
	self:RemoveStickerModelRaw(index)
	gPlayerProfileSceneOperationManager:EndOperation({
		stickerId = beforeState.stickerId
	})
end

M.RemoveStickerModelRaw = function(self, index)
	local entry = self.stickerModels[index]

	if not entry then
		return
	end

	if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
		GameObject.Destroy(entry.gameObject)
	end

	if entry.loadOp then
		gResourceManager:UnloadAssetLoadOp(entry.loadOp)
	end

	table.remove(self.stickerModels, index)

	if self.selectedStickerIndex ~= index then
		self:ClearSelection()
	elseif index >= self.selectedStickerIndex then
		self.selectedStickerIndex = self.selectedStickerIndex - 1
	end
end

M.RemoveStickerByIdRaw = function(self, stickerId)
	local index = self:FindStickerIndexByConfigId(stickerId)

	if index < 0 then
		return
	end

	self:RemoveStickerModelRaw(index)
	self:NotifyModelListChanged()
end

M.ClearAllStickersRaw = function(self)
	if self.selectedStickerIndex <= 0 then
		self:ClearSelection()
	end

	for i = #self.stickerModels, 1, -1 do
		local entry = self.stickerModels[i]

		if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			GameObject.Destroy(entry.gameObject)
		end

		if entry.loadOp then
			gResourceManager:UnloadAssetLoadOp(entry.loadOp)
		end
	end

	self.stickerModels = {}
	self.selectedStickerIndex = 0
	self.stickerLoadingToken = (self.stickerLoadingToken or 0) + 1
end

M.GetSelectedStickerEntry = function(self)
	if self.selectedStickerIndex < 0 then
		return nil
	end

	local entry = self.stickerModels[self.selectedStickerIndex]

	if not entry or not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return nil
	end

	return entry
end

M.GetSelectedStickerBillboard = function(self)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return nil
	end

	return entry.gameObject:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))
end

M.GetStickerBillboard = function(self, entry)
	if not entry or not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return nil
	end

	return entry.gameObject:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))
end

M.GetStickerMode = function(self, entry)
	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return StickerMode.World
	end

	return billboard.mode ~= StickerMode.ScreenUI and StickerMode.ScreenUI or StickerMode.World
end

M.GetSelectedStickerMode = function(self)
	return self:GetStickerMode(self:GetSelectedStickerEntry())
end

M.IsSelectedStickerScreenUI = function(self)
	return self:GetSelectedStickerMode() ~= StickerMode.ScreenUI
end

local GetScreenSize = function()
	return UnityEngine.Screen.width, UnityEngine.Screen.height
end

M._ApplyScreenUIStickerPosition = function(self, entry, billboard)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return
	end

	local screenW, screenH = GetScreenSize()
	local screenPos = Vector3.New((0.5 + billboard.offsetX) * screenW, (0.5 + billboard.offsetY) * screenH, billboard.distanceToCamera)
	local worldPos = cam:ScreenToWorldPoint(screenPos)
	entry.gameObject.transform.position = worldPos
	entry.position = worldPos
end

M.CalcDefaultStickerScreenUIPosition = function(self)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return nil
	end

	local screenW, screenH = GetScreenSize()

	if screenW > 0 or screenH < 0 then
		return nil
	end

	local screenPos = Vector3.New((0.5 + DEFAULT_STICKER_SCREEN_OFFSET_X) * screenW, (0.5 + DEFAULT_STICKER_SCREEN_OFFSET_Y) * screenH, DEFAULT_STICKER_SCREEN_DISTANCE)

	return cam:ScreenToWorldPoint(screenPos)
end

M.ApplyDefaultStickerScreenUIMode = function(self, entry)
	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	billboard.offsetX = DEFAULT_STICKER_SCREEN_OFFSET_X
	billboard.offsetY = DEFAULT_STICKER_SCREEN_OFFSET_Y
	billboard.distanceToCamera = DEFAULT_STICKER_SCREEN_DISTANCE
	billboard.mode = StickerMode.ScreenUI

	self:_ApplyScreenUIStickerPosition(entry, billboard)
	self:ApplyStickerRenderOnTop(entry, billboard)
end

M.ApplyStickerRenderOnTop = function(self, entry, billboard)
	if not entry then
		return
	end

	if not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return
	end

	billboard = billboard or self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	billboard:SetRenderOnTop(billboard.mode ~= StickerMode.ScreenUI)
end

M.ApplyRestoredStickerScreenUIMode = function(self, entry, billboard)
	billboard = billboard or self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	if not entry.gameObject or gCS.LuaUtils.IsNull(entry.gameObject) then
		return
	end

	local offsetX, offsetY, distance = gPlayerProfileSceneManager:CalcStickerScreenUIParams(entry.gameObject.transform.position)

	if offsetX then
		billboard.offsetX = offsetX
		billboard.offsetY = offsetY
		billboard.distanceToCamera = distance
	end

	billboard.mode = StickerMode.ScreenUI

	self:ApplyStickerRenderOnTop(entry, billboard)
end

M.SetStickerMode = function(self, entry, mode)
	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	if mode ~= StickerMode.ScreenUI then
		local cam = gCS.CameraDataMgr.MainCamera

		if cam and not gCS.LuaUtils.IsNull(cam) then
			local sp = cam:WorldToScreenPoint(entry.gameObject.transform.position)

			if sp.z <= 0 then
				local screenW, screenH = GetScreenSize()
				billboard.offsetX = sp.x / screenW - 0.5
				billboard.offsetY = sp.y / screenH - 0.5
				billboard.distanceToCamera = sp.z
			end
		end

		billboard.mode = StickerMode.ScreenUI

		self:_ApplyScreenUIStickerPosition(entry, billboard)
	else
		billboard.mode = StickerMode.World
		local pos = entry.gameObject.transform.position
		entry.position = Vector3.New(pos.x, pos.y, pos.z)
	end

	self:ApplyStickerRenderOnTop(entry, billboard)
end

M.ToggleSelectedStickerMode = function(self)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return nil
	end

	if not self:GetStickerBillboard(entry) then
		return nil
	end

	local newMode = self:GetStickerMode(entry) ~= StickerMode.ScreenUI and StickerMode.World or StickerMode.ScreenUI

	self:BeginTransform()
	self:SetStickerMode(entry, newMode)
	self:EndTransform()

	return newMode
end

M.MoveStickerOnScreenViewport = function(self, screenDx, screenDy)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return
	end

	local billboard = self:GetStickerBillboard(entry)

	if not billboard then
		return
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return
	end

	local screenW, screenH = GetScreenSize()

	if screenW > 0 or screenH < 0 then
		return
	end

	local limit = STICKER_SCREEN_OFFSET_LIMIT
	local offsetX = billboard.offsetX + screenDx / screenW
	local offsetY = billboard.offsetY + screenDy / screenH

	if offsetX >= -limit then
		offsetX = -limit
	elseif limit >= offsetX then
		offsetX = limit
	end

	if offsetY >= -limit then
		offsetY = -limit
	elseif limit >= offsetY then
		offsetY = limit
	end

	billboard.offsetX = offsetX
	billboard.offsetY = offsetY

	self:_ApplyScreenUIStickerPosition(entry, billboard)
end

M.MoveStickerByScreenDelta = function(self, screenDx, screenDy)
	if self:GetSelectedStickerMode() ~= StickerMode.ScreenUI then
		self:MoveStickerOnScreenViewport(screenDx, screenDy)
	else
		self:MoveStickerOnCameraPlane(screenDx, screenDy)
	end
end

M.MoveStickerDistance = function(self, delta)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return
	end

	if self:GetStickerMode(entry) ~= StickerMode.ScreenUI then
		return
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return
	end

	local camPos = cam.transform.position
	local stickerPos = entry.gameObject.transform.position
	local dir = (stickerPos - camPos).normalized
	local currentDist = Vector3.Distance(stickerPos, camPos)
	local newDist = currentDist + delta

	if newDist >= 0.15 then
		newDist = 0.15
	end

	if newDist <= 100 then
		newDist = 100
	end

	local newPos = camPos + dir * newDist
	entry.gameObject.transform.position = newPos
	entry.position = newPos
end

M.MoveStickerOnCameraPlane = function(self, screenDx, screenDy)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return
	end

	local camTransform = cam.transform
	local stickerPos = entry.gameObject.transform.position
	local dist = Vector3.Distance(stickerPos, camTransform.position)
	local screenPos = cam:WorldToScreenPoint(stickerPos)
	local newScreenPos = Vector3.New(screenPos.x + screenDx, screenPos.y + screenDy, screenPos.z)
	local newWorldPos = cam:ScreenToWorldPoint(newScreenPos)
	local camPos = camTransform.position
	local dir = (newWorldPos - camPos).normalized
	local finalPos = camPos + dir * dist
	entry.gameObject.transform.position = finalPos
	entry.position = finalPos
end

M.SetStickerScale = function(self, scale)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return
	end

	if scale >= 0.01 then
		scale = 0.01
	end

	if scale <= 1 then
		scale = 1
	end

	entry.gameObject.transform.localScale = Vector3.New(scale, scale, scale)
	entry.scale = scale
end

M.GetStickerScale = function(self)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return 1
	end

	return entry.scale or entry.gameObject.transform.localScale.x
end

M.GetSelectedStickerScreenPos = function(self)
	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return nil
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam then
		return nil
	end

	return cam:WorldToScreenPoint(entry.gameObject.transform.position)
end

M.RotateStickerAroundCamera = function(self, angleDeg)
	if not angleDeg or angleDeg ~= 0 then
		return
	end

	local entry = self:GetSelectedStickerEntry()

	if not entry then
		return
	end

	local offset = self:GetStickerRotationOffset(entry)

	if offset then
		self:ApplyStickerRotationOffset(entry, Vector3.New(offset.x, offset.y, offset.z + angleDeg))

		return
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return
	end

	local t = entry.gameObject.transform
	t.rotation = Quaternion.AngleAxis(angleDeg, cam.transform.forward) * t.rotation
end

M.RestoreStickerFromSaveData = function(self, stickerData, worldPos)
	if not stickerData then
		return false
	end

	local meshPath, scale, rotationOffset, mode = gPlayerProfileSceneManager:DecodeStickerSaveData(stickerData)

	if not meshPath then
		return false
	end

	local billboardState = mode ~= StickerMode.ScreenUI and {
		mode = StickerMode.ScreenUI
	} or nil

	self:AddStickerModelRaw(stickerData.StickerId, meshPath, worldPos, scale, rotationOffset, billboardState)

	return true
end

M.ChangeScene = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return
	end

	if sceneId ~= self.currentSceneId then
		return
	end

	self:EndCameraTransform()

	local beforeState = {
		sceneId = self.currentSceneId
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_SCENE, beforeState)
	self:ApplySceneWithOffset(sceneId)
	gPlayerProfileSceneOperationManager:EndOperation({
		sceneId = sceneId
	})
end

M.ChangeSceneRaw = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return
	end

	self:ApplySceneWithOffset(sceneId)
end

M.ApplySceneWithOffset = function(self, sceneId)
	local mgr = gPlayerProfileSceneManager
	local oldCenter = mgr.centerPos or Vector3.zero
	local oldCameraBase = mgr.cameraPos or mgr.centerPos or Vector3.zero
	local cameraPos = mgr:GetCameraPosition()
	local cameraOffset = cameraPos and cameraPos - oldCameraBase or Vector3.zero
	local cameraEuler = mgr:GetCameraEuler()
	local modelOffsets = {}

	for i, entry in ipairs(self.characterModels) do
		if entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			modelOffsets[i] = entry.unit.PlayerObj.position - oldCenter
		end
	end

	local vehicleOffsets = {}

	for i, entry in ipairs(self.vehicleModels) do
		if entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			vehicleOffsets[i] = entry.vehicle.gameObject.transform.position - oldCenter
		end
	end

	local stickerOffsets = {}

	for i, entry in ipairs(self.stickerModels) do
		if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			stickerOffsets[i] = entry.gameObject.transform.position - oldCenter
		end
	end

	self.currentSceneId = sceneId

	mgr:ApplySceneById(sceneId)

	local newCenter = mgr.centerPos or Vector3.zero

	for i, entry in ipairs(self.characterModels) do
		if modelOffsets[i] and entry.unit and entry.unit.PlayerObj and not gCS.LuaUtils.IsNull(entry.unit.PlayerObj) then
			local newPos = newCenter + modelOffsets[i]
			entry.unit.PlayerObj.position = newPos
			entry.position = newPos
		end
	end

	for i, entry in ipairs(self.vehicleModels) do
		if vehicleOffsets[i] and entry.vehicle and entry.vehicle.gameObject and not gCS.LuaUtils.IsNull(entry.vehicle.gameObject) then
			local newPos = newCenter + vehicleOffsets[i]
			entry.vehicle.gameObject.transform.position = newPos
			entry.position = newPos
		end
	end

	for i, entry in ipairs(self.stickerModels) do
		if stickerOffsets[i] and entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
			local newPos = newCenter + stickerOffsets[i]
			entry.gameObject.transform.position = newPos
			entry.position = newPos
		end
	end

	mgr:ApplySceneCamera()

	local vCamera = mgr.vCamera

	if vCamera then
		local cameraTransform = vCamera.transform.parent

		if cameraTransform then
			if cameraOffset == Vector3.zero then
				cameraTransform.position = cameraTransform.position + cameraOffset
			end

			if cameraEuler then
				cameraTransform.eulerAngles = cameraEuler
			end
		end
	end
end

M.ApplyOperation = function(self, operation)
	local opType = operation.operationType
	local state = operation.afterState

	if opType ~= OpType.ADD_CHARACTER then
		self:AddCharacterModelRaw(state.spiritId, state.position, state.euler)
	elseif opType ~= OpType.REMOVE_CHARACTER then
		self:RemoveCharacterBySpiritId(operation.beforeState.spiritId)
	elseif opType ~= OpType.ADD_VEHICLE then
		self:AddVehicleModelRaw(state.vehicleId, state.position, state.euler)
	elseif opType ~= OpType.REMOVE_VEHICLE then
		self:RemoveVehicleByIdRaw(operation.beforeState.vehicleId)
	elseif opType ~= OpType.REPLACE_VEHICLE then
		self:ReplaceVehicleRaw(operation.beforeState.vehicleId, state.vehicleId, state.position, state.euler)
	elseif opType ~= OpType.ADD_STICKER then
		self:AddStickerModelRaw(state.stickerId, state.meshPath, state.position, state.scale, state.rotationOffset, state.billboard)
	elseif opType ~= OpType.REMOVE_STICKER then
		self:RemoveStickerByIdRaw(operation.beforeState.stickerId)
	elseif opType ~= OpType.CHANGE_SCENE then
		self:ChangeSceneRaw(state.sceneId)
	elseif opType ~= OpType.MOVE_CAMERA then
		if state.cameraPos then
			local vCamera = gPlayerProfileSceneManager.vCamera

			if vCamera then
				local cameraTransform = vCamera.transform.parent

				if cameraTransform then
					cameraTransform.position = state.cameraPos

					if state.cameraEuler then
						cameraTransform.eulerAngles = state.cameraEuler
					end
				end
			end
		end
	elseif opType ~= OpType.RESET_ALL then
		self:_ApplyResetState(state)
	elseif opType ~= OpType.TRANSFORM_MODEL then
		self:_ApplyTransformState(state)
	elseif opType ~= OpType.CHANGE_ACTION then
		self:ChangeCharacterActionRaw(state.spiritId, state.actionId, state.actionGroup)
	elseif opType ~= OpType.CHANGE_DRESS_PRESET then
		self:ChangeCharacterDressPresetRaw(state.spiritId, state.slotIndex, state.fashionIdList)
	elseif opType ~= OpType.CHANGE_EXPRESSION then
		self:ChangeCharacterExpressionRaw(state.spiritId, state.expressionId)
	elseif opType ~= OpType.CHANGE_FILTER then
		self.currentFilterStrength = state.filterStrength

		self:ChangeFilterRaw(state.filterId)
	end
end

M.RevertOperation = function(self, operation)
	local opType = operation.operationType
	local state = operation.beforeState

	if opType ~= OpType.ADD_CHARACTER then
		self:RemoveCharacterBySpiritId(state.spiritId)
	elseif opType ~= OpType.REMOVE_CHARACTER then
		self:AddCharacterModelRaw(state.spiritId, state.position, state.euler, nil, state.actionId, state.dressSlot, state.actionGroup, state.expressionId, state.fashionIdList)
	elseif opType ~= OpType.ADD_VEHICLE then
		self:RemoveVehicleByIdRaw(state.vehicleId)
	elseif opType ~= OpType.REMOVE_VEHICLE then
		self:AddVehicleModelRaw(state.vehicleId, state.position, state.euler)
	elseif opType ~= OpType.REPLACE_VEHICLE then
		self:ReplaceVehicleRaw(operation.afterState.vehicleId, state.vehicleId, state.position, state.euler)
	elseif opType ~= OpType.ADD_STICKER then
		self:RemoveStickerByIdRaw(state.stickerId)
	elseif opType ~= OpType.REMOVE_STICKER then
		self:AddStickerModelRaw(state.stickerId, state.meshPath, state.position, state.scale, state.rotationOffset, state.billboard)
	elseif opType ~= OpType.CHANGE_SCENE then
		self:ChangeSceneRaw(state.sceneId)
	elseif opType ~= OpType.MOVE_CAMERA then
		if state.cameraPos then
			local vCamera = gPlayerProfileSceneManager.vCamera

			if vCamera then
				local cameraTransform = vCamera.transform.parent

				if cameraTransform then
					cameraTransform.position = state.cameraPos

					if state.cameraEuler then
						cameraTransform.eulerAngles = state.cameraEuler
					end
				end
			end
		end
	elseif opType ~= OpType.RESET_ALL then
		self:_ApplyResetState(state)
	elseif opType ~= OpType.TRANSFORM_MODEL then
		self:_ApplyTransformState(state)
	elseif opType ~= OpType.CHANGE_ACTION then
		self:ChangeCharacterActionRaw(state.spiritId, state.actionId, state.actionGroup)
	elseif opType ~= OpType.CHANGE_DRESS_PRESET then
		self:ChangeCharacterDressPresetRaw(state.spiritId, state.slotIndex, state.fashionIdList)
	elseif opType ~= OpType.CHANGE_EXPRESSION then
		self:ChangeCharacterExpressionRaw(state.spiritId, state.expressionId)
	elseif opType ~= OpType.CHANGE_FILTER then
		self.currentFilterStrength = state.filterStrength

		self:ChangeFilterRaw(state.filterId)
	end
end

M.AddCharacterModelRaw = function(self, spiritId, pos, euler, fashionWearInfoOverride, actionId, dressPresetSlot, actionGroupId, expressionId, fashionIdList)
	if not spiritId or spiritId ~= 0 then
		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		return
	end

	local agentId = fightSpiritConfig.AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)

	if not agentConfig then
		return
	end

	pos = pos or gPlayerProfileSceneManager.modelPos or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	euler = euler or gPlayerProfileSceneManager.modelEuler or gPlayerProfileSceneManager.centerEuler or Vector3.New(0, 0, 0)
	local fashionWearInfo = fashionWearInfoOverride or self:_GetSpiritFashionWearInfo(spiritId)
	local restoreActionId = actionId or 0
	local restoreActionGroup = actionGroupId or 0
	local restoreDressSlot = dressPresetSlot or 0
	local restoreExpressionId = expressionId or 0
	local restoreFashionIdList = fashionIdList and #fashionIdList <= 0 and fashionIdList or nil

	gPlayerProfileSceneManager:LoadCharacterUnit(spiritId, pos, euler, fashionWearInfo, function (unit)
		self:AddRendererBoxCollider(unit.PlayerObj)
		unit.PlayerObj.gameObject:SetLayerRecursively(LayerConstants.Npc)
		table.insert(self.characterModels, {
			spiritId = spiritId,
			unit = unit,
			position = pos,
			euler = euler,
			currentActionId = restoreActionId <= 0 and restoreActionId or nil,
			currentActionGroup = restoreActionGroup <= 0 and restoreActionGroup or nil,
			currentDressPresetSlot = restoreDressSlot <= 0 and restoreDressSlot or nil,
			currentExpressionId = restoreExpressionId <= 0 and restoreExpressionId or nil,
			currentFashionIdList = restoreFashionIdList
		})

		if restoreActionId <= 0 then
			gPlayerProfileSceneManager:PlayActionOnUnit(unit, restoreActionId, restoreActionGroup)
		end

		if restoreFashionIdList then
			gDressManager:DressSuitFashionList(restoreFashionIdList, false, {
				spiritId = spiritId,
				unit = unit
			})
		end

		if restoreExpressionId <= 0 and unit.ModelSlot and unit.ModelSlot.ExpressionController then
			unit.ModelSlot.ExpressionController:PlaySpecialExpression(restoreExpressionId, 0, true, 9999)
		end

		self:NotifyModelListChanged()
	end)
end

M.AddVehicleModelRaw = function(self, vehicleId, pos, euler, autoSelect)
	if not vehicleId or vehicleId ~= 0 then
		return
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	if not cfg then
		return
	end

	pos = pos or gPlayerProfileSceneManager.centerPos or Vector3.New(0, 0, 0)
	euler = euler or gPlayerProfileSceneManager.centerEuler or Vector3.New(0, 0, 0)
	local vehicleDetail = gPlayerProfileSceneManager:GetOwnedVehicleDetail(vehicleId)
	local currentToken = self.vehicleLoadingToken
	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = pos
	spawnParam.facing = euler.y
	spawnParam.forceDummy = true
	spawnParam.disableCollision = false
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

	spawnParam.beforeLoadAction = function(vehicle)
		if currentToken == self.vehicleLoadingToken then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if vehicleDetail then
			gPlayerProfileSceneManager:ApplyPlayerVehicleParts(vehicle, vehicleDetail)
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if currentToken == self.vehicleLoadingToken then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
			return
		end

		vehicle.gameObject.transform.eulerAngles = euler

		vehicle:SetMainLightOn(true, true)
		gCS.LuaUtils.ForceSetPlayerTransform(vehicle.gameObject.transform)
		self:AddMergedBoxCollider(vehicle.gameObject)
		self:EnableVehicleColliders(vehicle)
		table.insert(self.vehicleModels, {
			vehicleId = vehicleId,
			vehicle = vehicle,
			position = pos,
			euler = euler
		})

		if autoSelect then
			self:SelectVehicle(#self.vehicleModels)
		end

		self:NotifyModelListChanged()
	end

	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)
end

M.ReplaceVehicleRaw = function(self, oldVehicleId, newVehicleId, pos, euler)
	self.vehicleLoadingToken = self.vehicleLoadingToken + 1

	self:RemoveVehicleByIdRaw(oldVehicleId)
	self:AddVehicleModelRaw(newVehicleId, pos, euler, true)
	self:NotifyModelListChanged()
end

M.RemoveVehicleByIdRaw = function(self, vehicleId)
	for i = #self.vehicleModels, 1, -1 do
		if self.vehicleModels[i].vehicleId ~= vehicleId then
			self:RemoveVehicleModelRaw(i)

			break
		end
	end
end

M.ClearAll = function(self)
	self:ClearSelection()
	self:ClearAllCharactersRaw()
	self:ClearAllVehiclesRaw()
	self:ClearAllStickersRaw()

	self.currentSceneId = 0
	self.currentFilterId = 0
	self.currentFilterStrength = 100
	self._filterStrengthDragging = false
	self._filterStrengthBeforeState = nil
	self.characterLoadingToken = self.characterLoadingToken + 1
	self.vehicleLoadingToken = self.vehicleLoadingToken + 1
	self.stickerLoadingToken = self.stickerLoadingToken + 1
end

M.ClearAllCharactersRaw = function(self)
	for i = #self.characterModels, 1, -1 do
		local entry = self.characterModels[i]
		entry.cancelled = true

		if entry.unit then
			entry.unit:DestroyUnit(true)
		end
	end

	self.characterModels = {}
end

M.ClearAllVehiclesRaw = function(self)
	for i = #self.vehicleModels, 1, -1 do
		local entry = self.vehicleModels[i]

		if entry.vehicle then
			DriveUtils.DestroyVehicleClient(entry.vehicle.uid)
		end
	end

	self.vehicleModels = {}
end

M._SnapshotAllState = function(self)
	local characters = {}

	for _, entry in ipairs(self.characterModels) do
		table.insert(characters, {
			spiritId = entry.spiritId,
			position = entry.position,
			euler = entry.euler,
			actionId = entry.currentActionId,
			actionGroup = entry.currentActionGroup,
			dressSlot = entry.currentDressPresetSlot,
			expressionId = entry.currentExpressionId,
			fashionIdList = entry.currentFashionIdList
		})
	end

	local vehicles = {}

	for _, entry in ipairs(self.vehicleModels) do
		table.insert(vehicles, {
			vehicleId = entry.vehicleId,
			position = entry.position,
			euler = entry.euler
		})
	end

	local stickers = {}

	for _, entry in ipairs(self.stickerModels) do
		local snap = self:SnapshotStickerEntry(entry)

		if snap then
			table.insert(stickers, snap)
		end
	end

	return {
		characters = characters,
		vehicles = vehicles,
		stickers = stickers,
		sceneId = self.currentSceneId,
		filterId = self.currentFilterId,
		filterStrength = self.currentFilterStrength
	}
end

M._ApplyResetState = function(self, state)
	if not state then
		return
	end

	self:ClearSelection()
	self:ClearAllCharactersRaw()
	self:ClearAllVehiclesRaw()
	self:ClearAllStickersRaw()

	if state.sceneId and state.sceneId <= 0 then
		self:ChangeSceneRaw(state.sceneId)
	end

	if state.characters then
		for _, charData in ipairs(state.characters) do
			self:AddCharacterModelRaw(charData.spiritId, charData.position, charData.euler, nil, charData.actionId, charData.dressSlot, charData.actionGroup, charData.expressionId, charData.fashionIdList)
		end
	end

	if state.vehicles then
		for _, vehData in ipairs(state.vehicles) do
			self:AddVehicleModelRaw(vehData.vehicleId, vehData.position, vehData.euler)
		end
	end

	if state.stickers then
		for _, stickerData in ipairs(state.stickers) do
			self:AddStickerModelRaw(stickerData.stickerId, stickerData.meshPath, stickerData.position, stickerData.scale, stickerData.rotationOffset, stickerData.billboard)
		end
	end

	if state.filterId then
		self.currentFilterStrength = state.filterStrength or 100

		self:ChangeFilterRaw(state.filterId)
	end

	gPlayerProfileSceneManager:ApplySceneCamera()
	self:NotifyModelListChanged()
end

M.ResetAllWithUndo = function(self, defaultSceneId)
	if #self.characterModels ~= 0 and #self.vehicleModels ~= 0 and #self.stickerModels ~= 0 then
		return
	end

	local beforeState = self:_SnapshotAllState()

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.RESET_ALL, beforeState)
	self:ClearSelection()
	self:ClearAllCharactersRaw()
	self:ClearAllVehiclesRaw()
	self:ClearAllStickersRaw()

	if defaultSceneId and defaultSceneId <= 0 then
		self:ChangeSceneRaw(defaultSceneId)
	end

	gPlayerProfileSceneOperationManager:EndOperation({
		characters = {},
		vehicles = {},
		stickers = {},
		sceneId = defaultSceneId or self.currentSceneId,
		filterId = self.currentFilterId,
		filterStrength = self.currentFilterStrength
	})
	self:NotifyModelListChanged()
end

M.RevertToDefaultWithUndo = function(self)
	local beforeState = self:_SnapshotAllState()

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.RESET_ALL, beforeState)
	self:ClearSelection()
	self:ClearAllCharactersRaw()
	self:ClearAllVehiclesRaw()
	self:ClearAllStickersRaw()

	self._filterStrengthDragging = false
	self._filterStrengthBeforeState = nil
	self.currentFilterStrength = 100

	self:ChangeFilterRaw(0)

	local defaultSceneId = LTConfig.ImageSceneiconConfig.DefaultScene

	self:ChangeSceneRaw(defaultSceneId)
	gPlayerProfileSceneManager:ApplySceneCamera()

	local sex = gPlayerManager.infoLogin.bindData.sexType
	local spiritId = nil

	if sex ~= UX.Game.SexType.Female then
		spiritId = LTConfig.FightSpiritConfig.DefaultFemale
	else
		spiritId = LTConfig.FightSpiritConfig.DefaultMale
	end

	local defaultPos = gPlayerProfileSceneManager.modelPos or gPlayerProfileSceneManager.centerPos or Vector3.zero
	local defaultEuler = gPlayerProfileSceneManager.modelEuler or gPlayerProfileSceneManager.centerEuler or Vector3.zero
	local defaultActionId, defaultActionGroup = gPlayerProfileSceneManager:GetDefaultAction()

	self:AddCharacterModelRaw(spiritId, defaultPos, defaultEuler, nil, defaultActionId, nil, defaultActionGroup)
	gPlayerProfileSceneOperationManager:EndOperation({
		["\\xe1\\x93\\xf8\\xd5\\xf8\\x8d\\xe3\\x854 "] = 100,
		["\\xad\\xb8\t\\xbfo,\\xd77"] = 0,
		characters = {
			{
				spiritId = spiritId,
				position = defaultPos,
				euler = defaultEuler,
				actionId = defaultActionId,
				actionGroup = defaultActionGroup
			}
		},
		vehicles = {},
		stickers = {},
		sceneId = defaultSceneId
	})
	self:NotifyModelListChanged()
end

M.ChangeCharacterAction = function(self, index, actionType, actionGroupId)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	local beforeState = {
		spiritId = entry.spiritId,
		actionId = entry.currentActionId,
		actionGroup = entry.currentActionGroup
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_ACTION, beforeState)
	gPlayerProfileSceneManager:PlayActionOnUnit(unit, actionType, actionGroupId)

	entry.currentActionId = actionType
	entry.currentActionGroup = actionGroupId or unit.State.ActionGroupId

	gPlayerProfileSceneOperationManager:EndOperation({
		spiritId = entry.spiritId,
		actionId = actionType,
		actionGroup = entry.currentActionGroup
	})
end

M.ChangeCharacterActionRaw = function(self, spiritId, actionId, actionGroup)
	if not actionId then
		return
	end

	local index = self:FindCharacterIndexBySpiritId(spiritId)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	gPlayerProfileSceneManager:PlayActionOnUnit(unit, actionId, actionGroup)

	entry.currentActionId = actionId
	entry.currentActionGroup = actionGroup or unit.State.ActionGroupId
end

M.ChangeCharacterDressPreset = function(self, index, presetData)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	if not presetData or not presetData.fashionList then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	local beforeState = {
		spiritId = entry.spiritId,
		slotIndex = entry.currentDressPresetSlot,
		fashionIdList = entry.currentFashionIdList
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_DRESS_PRESET, beforeState)

	local fashionIdList = {}
	local fashionList = presetData.fashionList

	if fashionList.Count then
		for i = 1, fashionList.Count do
			table.insert(fashionIdList, fashionList[i].FashionId)
		end
	else
		for i = 1, #fashionList do
			table.insert(fashionIdList, fashionList[i].FashionId)
		end
	end

	local context = {
		spiritId = entry.spiritId,
		unit = unit
	}

	gDressManager:DressSuitFashionList(fashionIdList, false, context)

	entry.currentDressPresetSlot = presetData.slotIndex
	entry.currentFashionIdList = fashionIdList

	gPlayerProfileSceneOperationManager:EndOperation({
		spiritId = entry.spiritId,
		slotIndex = presetData.slotIndex,
		fashionIdList = fashionIdList
	})
end

M.ChangeCharacterDressPresetRaw = function(self, spiritId, slotIndex, fashionIdList)
	if not fashionIdList then
		return
	end

	local index = self:FindCharacterIndexBySpiritId(spiritId)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	local context = {
		spiritId = entry.spiritId,
		unit = unit
	}

	gDressManager:DressSuitFashionList(fashionIdList, false, context)

	entry.currentDressPresetSlot = slotIndex
	entry.currentFashionIdList = fashionIdList
end

M.ChangeCharacterExpression = function(self, index, expressionId)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	local beforeState = {
		spiritId = entry.spiritId,
		expressionId = entry.currentExpressionId or 0
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_EXPRESSION, beforeState)

	if unit.ModelSlot and unit.ModelSlot.ExpressionController then
		if expressionId ~= 0 then
			unit.ModelSlot.ExpressionController:PlayIdle(false, true)
		else
			unit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 9999)
		end
	end

	entry.currentExpressionId = expressionId

	gPlayerProfileSceneOperationManager:EndOperation({
		spiritId = entry.spiritId,
		expressionId = expressionId
	})
end

M.ChangeCharacterExpressionRaw = function(self, spiritId, expressionId)
	if not expressionId then
		return
	end

	local index = self:FindCharacterIndexBySpiritId(spiritId)
	local entry = self.characterModels[index]

	if not entry or not entry.unit then
		return
	end

	local unit = entry.unit

	if not unit.PlayerObj or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return
	end

	if unit.ModelSlot and unit.ModelSlot.ExpressionController then
		if expressionId ~= 0 then
			unit.ModelSlot.ExpressionController:PlayIdle(false, true)
		else
			unit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 9999)
		end
	end

	entry.currentExpressionId = expressionId
end

M.ChangeFilter = function(self, filterId)
	if filterId ~= self.currentFilterId then
		return
	end

	self:CommitPendingFilterStrength()

	local beforeState = {
		filterId = self.currentFilterId,
		filterStrength = self.currentFilterStrength
	}

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_FILTER, beforeState)
	self:ChangeFilterRaw(filterId)
	gPlayerProfileSceneOperationManager:EndOperation({
		filterId = self.currentFilterId,
		filterStrength = self.currentFilterStrength
	})
end

M.ChangeFilterStrength = function(self, strength)
	local newStrength = math.floor(strength)

	if newStrength ~= self.currentFilterStrength then
		return
	end

	if not self._filterStrengthDragging then
		self._filterStrengthBeforeState = {
			filterId = self.currentFilterId,
			filterStrength = self.currentFilterStrength
		}
		self._filterStrengthDragging = true
	end

	self.currentFilterStrength = newStrength

	PhotoUtils.SetCameraParam("CameraParamFilterIntensity", newStrength)
end

M.CommitPendingFilterStrength = function(self)
	if not self._filterStrengthDragging then
		return
	end

	self._filterStrengthDragging = false
	local beforeState = self._filterStrengthBeforeState
	self._filterStrengthBeforeState = nil

	if not beforeState then
		return
	end

	if beforeState.filterStrength ~= self.currentFilterStrength then
		return
	end

	gPlayerProfileSceneOperationManager:BeginOperation(OpType.CHANGE_FILTER, beforeState)
	gPlayerProfileSceneOperationManager:EndOperation({
		filterId = self.currentFilterId,
		filterStrength = self.currentFilterStrength
	})
end

M.ChangeFilterRaw = function(self, filterId)
	self.currentFilterId = filterId

	if filterId ~= 0 then
		FilterEffectManager.RemoveAllFilter()
		PhotoUtils.SetCameraParam("CameraParamFilterIntensity", 100)
	else
		FilterEffectManager.AddFilterExclusive(filterId)
		PhotoUtils.SetCameraParam("CameraParamFilterIntensity", self.currentFilterStrength)
	end
end

M.CollectScenarioData = function(self)
	local mgr = gPlayerProfileSceneManager
	local sceneId = self.currentSceneId

	if sceneId ~= 0 then
		sceneId = mgr.currentSceneId or 0
	end

	local centerPos = mgr.centerPos or Vector3.zero
	local centerEuler = mgr.centerEuler or Vector3.zero
	local centerQuat = Quaternion.Euler(centerEuler)
	local invCenterQuat = Quaternion.Inverse(centerQuat)

	local worldToLocal = function(worldPos)
		if not worldPos then
			return {
				["\\xf7"] = 0,
				["\\xf5"] = 0,
				["\\xf4"] = 0
			}
		end

		local offset = worldPos - centerPos
		local localPos = invCenterQuat * offset

		return {
			X = localPos.x,
			Y = localPos.y,
			Z = localPos.z
		}
	end

	local worldRotToLocal = function(worldEuler)
		if not worldEuler then
			return {
				["\\xf7"] = 0,
				["\\xf5"] = 0,
				["\\xf4"] = 0
			}
		end

		local worldQuat = Quaternion.Euler(worldEuler)
		local localQuat = invCenterQuat * worldQuat
		local localEuler = localQuat.eulerAngles

		return {
			X = localEuler.x,
			Y = localEuler.y,
			Z = localEuler.z
		}
	end

	local spirits = {}

	for _, entry in ipairs(self.characterModels) do
		local spiritData = {
			["5c\\xa5\\x97\\x93D"] = "",
			SpiritId = entry.spiritId,
			Position = worldToLocal(entry.position),
			Rotation = worldRotToLocal(entry.euler),
			ActionType = entry.currentActionId or 0,
			ActionGroup = entry.currentActionGroup or 0,
			SchemeIndex = entry.currentDressPresetSlot or 0,
			Expression = entry.currentExpressionId or 0
		}

		if spiritData.SchemeIndex <= 0 then
			local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
			local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[entry.spiritId]

			if spiritFashionsInfo and spiritFashionsInfo.FashionCustomSuitSchemeInfos then
				spiritData.FashionInfo = spiritFashionsInfo.FashionCustomSuitSchemeInfos[spiritData.SchemeIndex]
			end
		end

		spiritData.FashionInfo = {
			WearFashionInfoList = {}
		}

		table.insert(spirits, spiritData)
	end

	local vehicles = {}

	for _, entry in ipairs(self.vehicleModels) do
		table.insert(vehicles, {
			VehicleId = entry.vehicleId,
			Position = worldToLocal(entry.position),
			Rotation = worldRotToLocal(entry.euler)
		})
	end

	local stickers = {}

	for _, entry in ipairs(self.stickerModels) do
		local snap = self:SnapshotStickerEntry(entry)

		if snap and snap.stickerId and snap.stickerId <= 0 then
			local rot = snap.rotationOffset
			local scale = snap.scale or 1

			table.insert(stickers, {
				StickerId = snap.stickerId,
				Position = worldToLocal(snap.position),
				Rotation = rot and {
					X = rot.x,
					Y = rot.y,
					Z = rot.z
				} or {
					["\\xf7"] = 0,
					["\\xf5"] = 0,
					["\\xf4"] = 0
				},
				ScaleX = scale,
				ScaleY = scale,
				Mode = snap.billboard and snap.billboard.mode or StickerMode.World
			})
		end
	end

	local actualCameraPos = mgr:GetCameraPosition() or mgr.cameraPos
	local cameraTransform = mgr.vCamera and mgr.vCamera.transform and mgr.vCamera.transform.parent
	local actualCameraEuler = cameraTransform and cameraTransform.eulerAngles or mgr.cameraEuler
	local cameraPos = worldToLocal(actualCameraPos)
	local cameraRot = worldRotToLocal(actualCameraEuler)

	return {
		SceneId = sceneId,
		Spirits = spirits,
		Vehicles = vehicles,
		Stickers = stickers,
		Position = cameraPos,
		Rotation = cameraRot,
		FilterId = self.currentFilterId or 0,
		FilterStrength = self.currentFilterStrength or 100
	}
end

M.HasUnsavedChanges = function(self)
	return gPlayerProfileSceneOperationManager:HasUnsavedChanges()
end

M.GetSlotSceneName = function(self, slot)
	if not slot or slot < 0 then
		return ""
	end

	local showInfos = gPlayerManager.infoMinor.bindData.PlayerScenarioInfos
	local dict = showInfos and showInfos.PlayerScenarioInfoDict
	local slotInfo = dict and dict[slot]

	return slotInfo and slotInfo.SceneName or ""
end

M.BuildScenarioInfo = function(self, scenarioData, thumbnail, slot)
	if not scenarioData then
		return nil
	end

	local info = {
		SceneName = self:GetSlotSceneName(slot),
		PublicInfo = {
			["\\xb9=%3|\\xb2G\\xef>\\xaf\\xae"] = 0,
			SceneId = scenarioData.SceneId,
			Position = scenarioData.Position,
			Rotation = scenarioData.Rotation,
			Thumbnail = thumbnail or "",
			Vehicles = {},
			Spirits = {},
			Stickers = {},
			FilterId = scenarioData.FilterId or 0,
			FilterStrength = scenarioData.FilterStrength or 0
		}
	}

	for _, v in ipairs(scenarioData.Vehicles) do
		table.insert(info.PublicInfo.Vehicles, {
			VehicleId = v.VehicleId,
			Position = v.Position,
			Rotation = v.Rotation
		})
	end

	for _, s in ipairs(scenarioData.Spirits) do
		table.insert(info.PublicInfo.Spirits, {
			SpiritId = s.SpiritId,
			SchemeIndex = s.SchemeIndex,
			ActionType = s.ActionType,
			ActionGroup = s.ActionGroup,
			Expression = s.Expression or 0,
			IKType = s.IKType or "",
			Position = s.Position,
			Rotation = s.Rotation
		})
	end

	slot5 = ipairs
	slot7 = scenarioData.Stickers or {}

	for _, s in slot5(slot7) do
		table.insert(info.PublicInfo.Stickers, {
			StickerId = s.StickerId,
			Position = s.Position,
			Rotation = s.Rotation,
			ScaleX = s.ScaleX or 1,
			ScaleY = s.ScaleY or 1,
			Mode = s.Mode or StickerMode.World
		})
	end

	return info
end

M.SaveScenarioToSlot = function(self, slot, scenarioData, thumbnail, callback)
	local info = self:BuildScenarioInfo(scenarioData, thumbnail, slot)

	if not info then
		if callback then
			callback(true)
		end

		return
	end

	gClientToGameDelegate:AskUpdatePlayerScenarioInfo(slot, info).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback(false)
			end

			return
		end

		if callback then
			callback(true)
		end
	end
end

gPlayerProfileSceneEditManager = gPlayerProfileSceneEditManager or C_PlayerProfileSceneEditManager.new()
