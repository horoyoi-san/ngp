local DriveUtils = LX6.Drive.DriveUtils
local VehicleConfig = LTConfig.VehicleConfig
local LayerConstants = LX6.Constants.LayerConstants
C_BaikeModelViewerStore = DefClass("C_BaikeModelViewerStore", C_BaikeModelViewerStore, C_StoreGroup)
GroupName2Class.BaikeModelViewerStore = C_BaikeModelViewerStore
local M = C_BaikeModelViewerStore

function M:ctor()
	self:DefineAllVariables()
end

function M:DefineAllVariables()
	self.scenePrefab = nil
	self.scenePrefabOp = nil
	self.currentVehicle = nil
	self.loadedVehicleId = nil
	self.currentModelUnit = nil
	self.loadedSuitId = nil
	self.isStarted = false
	self.pendingLoadRequest = nil
	self.originalModelSlotPos = nil
	self.onSceneLoadComplete = nil
end

function M:DefineAllEnumsAutoGen()
	return
end

function M:ClearAllEnumsAutoGen()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
end

function M:OnEnable()
	return
end

function M:OnStart()
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.SceneWeatherIndex or 17)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self.bindData.modelTrans.gameObject:SetParent(nil, true)
	self.bindData.modelTrans.gameObject:SetPosition(0, -500, 0)
	self.bindData.modelTrans:SetLocalScale(1)
	self:LoadScenePrefab()

	self.isStarted = true

	self:ExecutePendingLoadRequests()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearCharacterModel()
	self:ClearVehicle()
	self:ClearScenePrefab()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	GameObject.Destroy(self.bindData.modelTrans.gameObject)

	self.isStarted = false
	self.pendingLoadRequest = nil
	self.originalModelSlotPos = nil

	gCS.CameraDataMgr:ResetOverrideStreamingCam()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:ResetCfg()
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.SceneWeatherIndex or 17)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
end

function M:OnClose()
	return
end

function M:LoadScenePrefab()
	local path = LTConfig.CityPediaConfig.PediaScenePath

	print_debug("BaikeModelViewerStore LoadScenePrefab Begin framecount" .. Time.frameCount .. "time" .. Time.time)

	self.scenePrefabOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset then
			return
		end

		local scenePrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if self.bindData.sceneObj then
			scenePrefab.gameObject.transform:SetParent(self.bindData.sceneObj)
			scenePrefab.gameObject.transform:SetLocalPosition(Vector3.zero)
			scenePrefab.gameObject.transform:SetLocalScale(1)

			scenePrefab.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end

		self.scenePrefab = scenePrefab

		gCS.LuaUtils.ForceAddCustomProbeForBaike(scenePrefab.gameObject)

		if self.onSceneLoadComplete then
			self.onSceneLoadComplete()
		end

		print_debug("BaikeModelViewerStore LoadScenePrefab End  framecount" .. Time.frameCount .. "time" .. Time.time)
	end)
end

function M:ClearScenePrefab()
	print_debug("BaikeModelViewerStore ClearScenePrefab  framecount" .. Time.frameCount .. "time" .. Time.time)
	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		GameObject.Destroy(self.scenePrefab)

		self.scenePrefab = nil
	end
end

function M:ClearVehicle()
	if self.currentVehicle then
		DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)

		self.currentVehicle = nil
	end

	self.loadedVehicleId = nil

	if self.originalModelSlotPos and self.bindData.modelSlot then
		self.bindData.modelSlot.localPosition = self.originalModelSlotPos
	end
end

function M:GetModelSlot()
	return self.bindData.modelSlot
end

function M:GetCamera()
	return self.bindData.camera
end

function M:SetSceneLoadCompleteCallback(callback)
	self.onSceneLoadComplete = callback

	if self.scenePrefab and callback then
		callback()
	end
end

function M:ExecutePendingLoadRequests()
	if not self.pendingLoadRequest then
		return
	end

	local request = self.pendingLoadRequest
	self.pendingLoadRequest = nil

	if request.type == "character" then
		self:LoadCharacterModel(request.spiritId, request.fashionInfo, request.suitId, request.onLoadComplete)
	elseif request.type == "vehicle" then
		self:LoadVehicleModel(request.vehicleId, request.onLoadComplete)
	end
end

function M:LoadCharacterModel(spiritId, fashionInfo, suitId, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest = {
			type = "character",
			spiritId = spiritId,
			fashionInfo = fashionInfo,
			suitId = suitId,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if not spiritId or spiritId == 0 then
		self:ClearCharacterModel()

		return
	end

	if self.loadedSuitId == suitId then
		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	self:ClearCharacterModel()

	self.loadedSuitId = suitId

	print_debug("BaikeModelViewerStore LoadCharacterModel Begin spiritId:" .. spiritId .. " suitId:" .. suitId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	if not self.originalModelSlotPos and self.bindData.modelSlot then
		self.originalModelSlotPos = self.bindData.modelSlot.localPosition
	end

	local modelId = agentConfig.GeneralModelId
	self.bindData.model1 = {
		isSetFacing = false,
		customFacing = 0,
		modelId = modelId,
		layer = LayerConstants.Player,
		otherData = {
			unitActionLoop = true,
			uiShowModel = true,
			SubType = spiritId,
			cardId = spiritId,
			fashionWearInfo = fashionInfo
		},
		callback = function (unit)
			if self.loadedSuitId ~= suitId then
				unit:DestroyUnit(true)

				return
			end

			print_debug("BaikeModelViewerStore LoadCharacterModel End spiritId:" .. spiritId .. " suitId:" .. suitId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

			self.currentModelUnit = unit
			unit.PlayerObj.transform.localScale = Vector3.one
			unit.PlayerObj.transform.localEulerAngles = Vector3(0, 180, 0)
			local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

			if modelCfg and self.bindData.modelSlot and self.originalModelSlotPos then
				local bodyType = modelCfg.CameraBodyType ~= 0 and modelCfg.CameraBodyType or modelCfg.BodyType
				local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

				if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
					local offset = fashionBaseCfg.PediaModelOffset
					local newPos = self.originalModelSlotPos + Vector3.New(offset.x, offset.y, offset.z)
					self.bindData.modelSlot.localPosition = newPos
				end
			end

			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
			gCS.SceneDataMgr.UIUnitManager:AddUnit(unit.Pid, unit)
			gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
			gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
			gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)

			unit.State.ActionGroupId = 1

			gCS.AnimControllerManager.PlayAction(unit, 1001, 1, 9999, 0, -1, false, nil, 0)

			if self.bindData.uCameraRenderImage and self.bindData.rawImage then
				self.bindData.uCameraRenderImage.targetRawImage = self.bindData.rawImage
				self.bindData.rawImage.texture = self.bindData.uCameraRenderImage.targetRawImage.texture

				self.bindData.uCameraRenderImage:SetDepthStencilFormatBaike()
			end

			if onLoadComplete then
				onLoadComplete(unit)
			end
		end
	}
end

function M:ClearCharacterModel()
	if self.currentModelUnit then
		gCS.PauseManager.Instance:ProessUIModelShow(false, self.currentModelUnit)
		self.currentModelUnit:DestroyUnit(true)

		self.currentModelUnit = nil
	end

	self.loadedSuitId = nil

	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()

	if self.originalModelSlotPos and self.bindData.modelSlot then
		self.bindData.modelSlot.localPosition = self.originalModelSlotPos
	end
end

function M:LoadVehicleModel(vehicleId, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest = {
			type = "vehicle",
			vehicleId = vehicleId,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if not vehicleId or vehicleId == 0 then
		self:ClearVehicle()

		return
	end

	if self.loadedVehicleId == vehicleId then
		return
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	self:ClearVehicle()

	self.loadedVehicleId = vehicleId

	print_debug("BaikeModelViewerStore LoadVehicleModel Begin vehicleId:" .. vehicleId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	local modelSlot = self.bindData.modelSlot

	if not self.originalModelSlotPos and modelSlot then
		self.originalModelSlotPos = modelSlot.localPosition
	end

	modelSlot.localEulerAngles = Vector3.New(0, 0, 0)
	local spawnParam = LX6.Drive.SpawnVehicleParam.New()
	spawnParam.facing = VehicleConfig.PediaDefaultVehicleRotation
	spawnParam.forceDummy = true
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest
	local partsId = cfg.DefaultPaint and {
		cfg.DefaultPaint
	} or nil

	function spawnParam.beforeLoadAction(vehicle)
		if self.loadedVehicleId ~= vehicleId then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if partsId then
			partsId = table.to_array(partsId)

			vehicle:InitClientPartsData(partsId)
		end
	end

	function spawnParam.afterLoadAction(vehicle)
		if self.loadedVehicleId ~= vehicleId then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		print_debug("BaikeModelViewerStore LoadVehicleModel End vehicleId:" .. vehicleId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

		self.currentVehicle = vehicle

		vehicle.gameObject.transform:SetParent(modelSlot, true)
		vehicle.gameObject.transform:SetLocalScale(1)

		vehicle.gameObject.transform.localPosition = Vector3.zero

		if cfg and cfg.PediaModelOffset and self.originalModelSlotPos then
			local offset = cfg.PediaModelOffset
			local newPos = self.originalModelSlotPos + Vector3.New(offset.x, offset.y, offset.z)
			modelSlot.localPosition = newPos
		end

		gCS.LuaUtils.ForceSetPlayerTransform(vehicle.gameObject.transform)

		if self.bindData.uCameraRenderImage and self.bindData.rawImage then
			self.bindData.uCameraRenderImage.targetRawImage = self.bindData.rawImage
			self.bindData.rawImage.texture = self.bindData.uCameraRenderImage.targetRawImage.texture

			self.bindData.uCameraRenderImage:SetDepthStencilFormatBaike()
		end

		gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)

		if onLoadComplete then
			onLoadComplete(vehicle)
		end
	end

	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)
end
