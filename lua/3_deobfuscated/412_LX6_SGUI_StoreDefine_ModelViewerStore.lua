local LayerConstants = LX6.Constants.LayerConstants
local FightSpiritConfig = LTConfig.FightSpiritConfig
local UnitModelManager = LX6.Units.UnitModelManager
local VehicleConfig = LTConfig.VehicleConfig
local DriveUtils = LX6.Drive.DriveUtils
C_ModelViewerStore = DefClass("C_ModelViewerStore", C_ModelViewerStore, C_StoreGroup)
GroupName2Class.ModelViewerStore = C_ModelViewerStore
local M = C_ModelViewerStore

function M:ctor()
	self:OnInit()
end

function M:OnAwake()
	self:OnInit()
end

function M:OnInit()
	self.modelSlotTid = {}
	self.modelSlotUnit = {}
	self.modelVehicleTid = {}
	self.modelVehicleEntityId = {}
	self.cacheModelAction = {}
end

function M:OnStart()
	gCS.CameraDataMgr.MainCamera.enabled = false

	gCS.GuiUtils.SetXuWeiWeatherState(true, 4)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
end

function M:OnDestroy()
	gCS.GuiUtils.SetXuWeiWeatherState(false)

	for k, v in pairs(self.modelVehicleEntityId) do
		DriveUtils.DestroyVehicleClient(v)
	end

	for k, v in pairs(self.modelSlotUnit) do
		v:DestroyUnit(true)
	end

	gCS.CameraDataMgr.MainCamera.enabled = true
end

function M:SetModelViewType(type)
	self.bindData.modelViewType = type
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:LoadPose(slotIndex, actionId, actionGroupId, expressionId)
	if self.cacheModelAction[slotIndex] and self.cacheModelAction[slotIndex].actionId == actionId and self.cacheModelAction[slotIndex].actionGroupId == actionGroupId and self.cacheModelAction[slotIndex].expressionId == expressionId then
		return
	end

	local unit = self.modelSlotUnit[slotIndex]
	self.cacheModelAction[slotIndex] = {
		actionId = actionId,
		actionGroupId = actionGroupId,
		expressionId = expressionId
	}

	if not unit then
		return
	end

	if unit.State.ActionGroupId ~= actionGroupId then
		unit.State.ActionGroupId = actionGroupId
	end

	gClientUtils.PlaySingleAction(unit, actionId, actionGroupId, 99999)

	if unit.ModelSlot and unit.ModelSlot.ExpressionController then
		unit.ModelSlot.ExpressionController:Init(unit, 2)
		unit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 0)
	end
end

function M:GetVehiclePos(slotIndex, offset)
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

function M:LoadVehicle(slotIndex, tid)
	if slotIndex ~= 1 then
		return
	end

	if self.modelVehicleTid[slotIndex] == tid then
		return true
	end

	self.modelVehicleTid[slotIndex] = tid
	local cfg = VehicleConfig.GetConfig(tid)

	if not cfg then
		return false
	end

	if self.modelVehicleEntityId[slotIndex] then
		DriveUtils.DestroyVehicleClient(self.modelVehicleEntityId[slotIndex])

		self.modelVehicleEntityId[slotIndex] = nil
	end

	local entityId = DriveUtils.CreateVehicleEntityId()
	self.modelVehicleEntityId[slotIndex] = entityId
	local transforms = self.bindData["carSlot" .. slotIndex]

	DriveUtils.SpawnVehicleClient(tid, transforms.position, -90, entityId, 0, function (vehicle)
		vehicle.gameObject:SetLayer(LayerConstants.Player)
		vehicle.transform:SetParent(transforms, true)
		vehicle.transform:SetLocalScale(1)
	end)

	return true
end

function M:GetModelPositon(slotIndex, offset)
	if not self.modelSlotTid[slotIndex] then
		return Vector2.zero
	end

	local transform = self.bindData["modelTransform" .. slotIndex]
	local pos = transform.position + offset
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(pos, self.bindData.camera, 0, 0, 0)
	local uiPos = gCS.LuaUtils.ScreenPointToUINoRay(x, y)
	uiPos = uiPos / SGUI.UIConfig.instance:GetCurrentAdaptationScale()

	return uiPos
end

function M:LoadModel(slotIndex, tid, fashionInfo)
	print_debug("LoadModel", slotIndex, tid, fashionInfo)

	if self.modelSlotTid[slotIndex] == tid then
		return
	end

	self.modelSlotTid[slotIndex] = tid

	if tid == nil or tid == 0 then
		self.bindData["model" .. slotIndex] = {
			modelId = 0
		}

		return
	end

	local fightSpiritConfig = FightSpiritConfig.GetConfig(tid)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)
	local ModelId = agentConfig.GeneralModelId

	if self.modelSlotUnit[slotIndex] then
		self.modelSlotUnit[slotIndex]:DestroyUnit(true)
	end

	local modelData = {
		customFacing = 0,
		isSetFacing = false,
		modelId = ModelId,
		layer = LayerConstants.Player,
		otherData = {
			unitActionLoop = true,
			uiShowModel = true,
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
			if tid ~= self.modelSlotTid[slotIndex] then
				C_BaseUnit:DestroyUnit(true)

				return
			end

			self.modelSlotUnit[slotIndex] = C_BaseUnit

			C_BaseUnit.PlayerObj:SetLayer(LayerConstants.Player)
			UnitModelManager.SetAnimancerEnabled(C_BaseUnit, true)
			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit.PlayerObj)

			C_BaseUnit.PlayerObj.transform.localScale = Vector3.one

			if self.cacheModelAction[slotIndex] then
				if C_BaseUnit.ModelSlot.ExpressionController then
					C_BaseUnit.ModelSlot.ExpressionController:Init(C_BaseUnit, 2)
				end

				C_BaseUnit.State.ActionGroupId = self.cacheModelAction[slotIndex].actionGroupId

				gClientUtils.PlaySingleAction(C_BaseUnit, self.cacheModelAction[slotIndex].actionId, self.cacheModelAction[slotIndex].actionGroupId, 9999)
			else
				C_BaseUnit.State.ActionGroupId = 66
			end

			gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit.Pid, C_BaseUnit)
		end
	}
	self.bindData["model" .. slotIndex] = modelData
end
