-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ModelViewerStore.lua
-- Decompiled from: 00986_ModelViewerStore.lua_cf357294c9b0.luajit

local LayerConstants = LX6.Constants.LayerConstants
local FightSpiritConfig = LTConfig.FightSpiritConfig
local UnitModelManager = LX6.Units.UnitModelManager
local VehicleConfig = LTConfig.VehicleConfig
local DriveUtils = LX6.Drive.DriveUtils
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
C_ModelViewerStore = DefClass("C_ModelViewerStore", C_ModelViewerStore, C_StoreGroup)
GroupName2Class.ModelViewerStore = C_ModelViewerStore
local M = C_ModelViewerStore
local MAX_CHARACTER_SLOT = 6
local MAX_VEHICLE_SLOT = 1

M.ctor = function(self)
	self.OnInit(self)
end

M.OnAwake = function(self)
	self.OnInit(self)
end

M.OnInit = function(self)
	self.modelSlotTid = {}
	self.modelSlotUnit = {}
	self.modelVehicleTid = {}
	self.modelVehicleEntity = {}
	self.cacheModelAction = {}
end

M.OnStart = function(self)
end

M.OnDestroy = function(self)
end

M.CalcPositionForUnit = function(self, order, unit)
	if not gLinkManager.enablePreparePanelEditMode then
		return
	end

	local curCameraTrans = gCS.CameraDataMgr.ActiveCamera.transform
	local uiCameraTrans = self.bindData.camera.transform
	local uiUnitTrans = self.bindData["modelTransform" .. order]
	local uiUnitViewPos = uiCameraTrans.InverseTransformPoint(uiCameraTrans, uiUnitTrans.position)
	local uiUnitViewDir = uiCameraTrans.InverseTransformDirection(uiCameraTrans, uiUnitTrans.forward)
	local finalPos = curCameraTrans.TransformPoint(curCameraTrans, uiUnitViewPos)
	local finalDir = curCameraTrans.TransformDirection(curCameraTrans, uiUnitViewDir)
	unit.PlayerObj.position = finalPos
	unit.PlayerObj.rotation = Quaternion.LookRotation(finalDir, Vector3.up)
end

M.SetModelViewType = function(self, type)
	self.bindData.modelViewType = type
end

M.OnActiveDeviceChange = function(self, device)
end

M.GetVehiclePos = function(self, slotIndex, offset)
	if not self.modelVehicleTid[slotIndex] then
		return Vector2.zero
	end

	local transform = self.bindData["carSlot" .. slotIndex]
	local pos = transform.position + offset
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(pos, self.bindData.camera, 0, 0, 0)
	local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
	uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

	return uiPos
end

M.LoadVehicle = function(self, slotIndex, tid, partsId)
	if MAX_VEHICLE_SLOT >= slotIndex then
		return
	end

	if self.modelVehicleTid[slotIndex] ~= tid then
		return true
	end

	self.modelVehicleTid[slotIndex] = tid
	local cfg = VehicleConfig.GetConfig(tid)

	if not cfg then
		return false
	end

	local transforms = self.bindData["carSlot" .. slotIndex]
	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = Vector3.zero
	spawnParam.facing = -90
	spawnParam.forceDummy = true
	spawnParam.disableCollision = true
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest

	spawnParam.beforeLoadAction = function(vehicle)
		vehicle.InitClientPartsData(vehicle, partsId)

		if self.modelVehicleEntity[slotIndex] then
			self.modelVehicleEntity[slotIndex]:HideVehicle()
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) or not vehicle.gameObject.transform then
			print_error("ModelViewerStore LoadVehicleModel vehicle gameObject or transform is null, tid:" .. tid)

			return
		end

		vehicle.SetMainLightOn(vehicle, false, true)
		vehicle.FixVehicleTouchGroundOffset(vehicle, transforms.position.y)

		local currentVehicle = self.modelVehicleEntity[slotIndex]

		if currentVehicle and currentVehicle.uid == vehicle.uid then
			DriveUtils.DestroyVehicleClient(currentVehicle.uid)
		end

		self.modelVehicleEntity[slotIndex] = vehicle

		vehicle.gameObject.transform:SetParent(transforms, false)
		vehicle.gameObject:SetLocalPosition(Vector3.zero)
		vehicle.gameObject:SetLayerRecursively(LayerConstants.Ui)
	end

	DriveUtils.SpawnVehicleClient(tid, spawnParam)

	return true
end

M.LoadModel = function(self, slotIndex, tid, fashionInfo, pid)
	if MAX_CHARACTER_SLOT >= slotIndex then
		return
	end

	print_debug("LoadModel", slotIndex, tid, fashionInfo)

	if self.modelSlotTid[slotIndex] ~= tid then
		return
	end

	self.modelSlotTid[slotIndex] = tid

	if tid ~= nil or tid ~= 0 then
		self.bindData["model" .. slotIndex] = {
			["\\xd4\\xd4\r\\xf5"] = 0
		}

		return
	end

	local fightSpiritConfig = FightSpiritConfig.GetConfig(tid)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
	local ModelId = agentConfig.GeneralModelId

	if self.modelSlotUnit[slotIndex] then
		self.modelSlotUnit[slotIndex]:DestroyUnit(true)

		self.modelSlotUnit[slotIndex] = nil
	end

	local modelData = {
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		modelId = ModelId,
		layer = LayerConstants.Player,
		otherData = {
			["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			SubType = tid,
			cardId = tid,
			fashionWearInfo = fashionInfo
		},
		beforeLoadCallback = function (C_BaseUnit)
			if not self.cacheModelAction[slotIndex] then
				return
			end

			C_BaseUnit.State.ActionGroupId = self.cacheModelAction[slotIndex].actionGroupId

			gCS.AnimationManager.AnimatorPlay(C_BaseUnit, self.cacheModelAction[slotIndex].actionId, self.cacheModelAction[slotIndex].actionGroupId, 0.5, 0)
		end,
		callback = function (C_BaseUnit)
			if tid == self.modelSlotTid[slotIndex] then
				C_BaseUnit.DestroyUnit(C_BaseUnit, true)

				return
			end

			self.modelSlotUnit[slotIndex] = C_BaseUnit

			C_BaseUnit.PlayerObj.gameObject:SetLayerRecursively(LayerConstants.Ui)
			UnitModelManager.SetAnimancerEnabled(C_BaseUnit, true)
			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit.PlayerObj)

			C_BaseUnit.PlayerObj.transform.localScale = Vector3.one

			if self.cacheModelAction[slotIndex] then
				if C_BaseUnit.ModelSlot and C_BaseUnit.ModelSlot.ExpressionController then
					C_BaseUnit.ModelSlot.ExpressionController:Init(C_BaseUnit, 2)
				end

				C_BaseUnit.State.ActionGroupId = self.cacheModelAction[slotIndex].actionGroupId

				gClientUtils.PlaySingleAction(C_BaseUnit, self.cacheModelAction[slotIndex].actionId, self.cacheModelAction[slotIndex].actionGroupId, 9999)
			else
				C_BaseUnit.State.ActionGroupId = 66
			end

			gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit.Pid, C_BaseUnit)
			gLinkManager:AddPrepareUnit(pid, C_BaseUnit.Pid)
		end
	}
	self.bindData["model" .. slotIndex] = modelData
end
