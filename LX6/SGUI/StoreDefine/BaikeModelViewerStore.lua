-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaikeModelViewerStore.lua
-- Decompiled from: 01573_BaikeModelViewerStore.lua_74e4811f3970.luajit

local DriveUtils = LX6.Drive.DriveUtils
local VehicleConfig = LTConfig.VehicleConfig
local LayerConstants = LX6.Constants.LayerConstants
C_BaikeModelViewerStore = DefClass("C_BaikeModelViewerStore", C_BaikeModelViewerStore, C_StoreGroup)
GroupName2Class.BaikeModelViewerStore = C_BaikeModelViewerStore
local M = C_BaikeModelViewerStore
M.LoadingType = {
	["\\xef\\xde(\\xf4"] = 2,
	["`Om{O*"] = 1,
	["T-s^"] = 0
}

M.ctor = function(self)
	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
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
	self.loadingToken = 0
	self.currentLoadingType = self.LoadingType.None
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.FashionWeatherIndex or 17)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self.bindData.modelTrans.gameObject:SetParent(nil, true)
	self.bindData.modelTrans.gameObject:SetPosition(0, -500, 0)
	self.bindData.modelTrans:SetLocalScale(1)
	self:LoadScenePrefab()

	self.isStarted = true

	self:ExecutePendingLoadRequests()
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
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
	self.loadingToken = 0
	self.currentLoadingType = self.LoadingType.None

	gCS.CameraDataMgr:ResetOverrideStreamingCam()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.ResetCfg = function(self)
	local weatherIndex = nil

	if self.currentLoadingType ~= self.LoadingType.Vehicle then
		weatherIndex = LTConfig.CityPediaConfig.VehicleWeatherIndex or 17
	else
		weatherIndex = LTConfig.CityPediaConfig.FashionWeatherIndex or 17
	end

	gCS.GuiUtils.SetXuWeiWeatherState(true, weatherIndex)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
	gCS.PauseManager.Instance:ProessUIModelShow(true)
end

M.OnClose = function(self)
end

M.LoadScenePrefab = function(self)
	local path = LTConfig.CityPediaConfig.PediaScenePath

	print_debug("BaikeModelViewerStore LoadScenePrefab Begin framecount" .. Time.frameCount .. "time" .. Time.time)

	slot2 = gResourceManager
	self.scenePrefabOp = slot2:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
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

		if self.onSceneLoadComplete then
			self.onSceneLoadComplete()
		end

		print_debug("BaikeModelViewerStore LoadScenePrefab End  framecount" .. Time.frameCount .. "time" .. Time.time)
	end)
end

M.ClearScenePrefab = function(self)
	print_debug("BaikeModelViewerStore ClearScenePrefab  framecount" .. Time.frameCount .. "time" .. Time.time)
	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		GameObject.Destroy(self.scenePrefab)

		self.scenePrefab = nil
	end
end

M.ClearVehicle = function(self)
	if self.currentVehicle then
		DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)

		self.currentVehicle = nil
	end

	self.loadedVehicleId = nil

	if self.currentLoadingType ~= self.LoadingType.Vehicle then
		self.currentLoadingType = self.LoadingType.None
	end

	if self.originalModelSlotPos and self.bindData.modelSlot then
		self.bindData.modelSlot.localPosition = self.originalModelSlotPos
	end
end

M.GetModelSlot = function(self)
	return self.bindData.modelSlot
end

M.GetCamera = function(self)
	return self.bindData.camera
end

M.SetSceneLoadCompleteCallback = function(self, callback)
	self.onSceneLoadComplete = callback

	if self.scenePrefab and callback then
		callback()
	end
end

M.ExecutePendingLoadRequests = function(self)
	if not self.pendingLoadRequest then
		return
	end

	local request = self.pendingLoadRequest
	self.pendingLoadRequest = nil

	if request.type ~= "character" then
		self.LoadCharacterModel(self, request.spiritId, request.fashionInfo, request.suitId, request.onLoadComplete)
	elseif request.type ~= "vehicle" then
		self.LoadVehicleModel(self, request.vehicleId, request.onLoadComplete)
	end
end

M.LoadCharacterModel = function(self, spiritId, fashionInfo, suitId, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest = {
			["n;m^"] = "@Om{O*",
			spiritId = spiritId,
			fashionInfo = fashionInfo,
			suitId = suitId,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if not spiritId or spiritId ~= 0 then
		self.ClearCharacterModel(self)

		return
	end

	if self.loadedSuitId and self.loadedSuitId ~= suitId then
		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	self:ClearVehicle()
	self:ClearCharacterModel()
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.FashionWeatherIndex or 17)

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Character
	self.loadedSuitId = suitId

	print_debug("BaikeModelViewerStore LoadCharacterModel Begin spiritId:" .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	if not self.originalModelSlotPos and self.bindData.modelSlot then
		self.originalModelSlotPos = self.bindData.modelSlot.localPosition
	end

	local modelId = agentConfig.GeneralModelId
	self.bindData.model1 = {
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		modelId = modelId,
		layer = LayerConstants.Player,
		otherData = {
			["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			SubType = spiritId,
			cardId = spiritId,
			fashionWearInfo = fashionInfo
		},
		callback = function (unit)
			if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Character or self.loadedSuitId == suitId then
				if unit then
					unit.DestroyUnit(unit, true)
				end

				return
			end

			print_debug("BaikeModelViewerStore LoadCharacterModel End spiritId:" .. spiritId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

			self.currentModelUnit = unit
			unit.PlayerObj.transform.localScale = Vector3.one
			unit.PlayerObj.transform.localEulerAngles = Vector3(0, 180, 0)
			local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

			if modelCfg and self.bindData.modelSlot and self.originalModelSlotPos then
				local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
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
			gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
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

M.ClearCharacterModel = function(self)
	if self.currentModelUnit then
		gCS.PauseManager.Instance:ProessUIModelShow(false, self.currentModelUnit)

		if gCS.LuaUtils.IsBaseUnitValid(self.currentModelUnit) then
			self.currentModelUnit:DestroyUnit(true)
		end

		self.currentModelUnit = nil
	end

	self.loadedSuitId = nil

	if self.currentLoadingType ~= self.LoadingType.Character then
		self.currentLoadingType = self.LoadingType.None
	end

	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()

	if self.originalModelSlotPos and self.bindData.modelSlot then
		self.bindData.modelSlot.localPosition = self.originalModelSlotPos
	end
end

M.LoadVehicleModel = function(self, vehicleId, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest = {
			["n;m^"] = "\\xcf\\xde(\\xf4",
			vehicleId = vehicleId,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if not vehicleId or vehicleId ~= 0 then
		self.ClearVehicle(self)

		return
	end

	if self.loadedVehicleId ~= vehicleId then
		return
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	self:ClearCharacterModel()
	self:ClearVehicle()
	gCS.GuiUtils.SetXuWeiWeatherState(true, LTConfig.CityPediaConfig.VehicleWeatherIndex or 17)

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Vehicle
	self.loadedVehicleId = vehicleId

	print_debug("BaikeModelViewerStore LoadVehicleModel Begin vehicleId:" .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

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

	spawnParam.beforeLoadAction = function(vehicle)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Vehicle or self.loadedVehicleId == vehicleId then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if partsId then
			partsId = table.to_array(partsId)

			vehicle:InitClientPartsData(partsId)
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Vehicle or self.loadedVehicleId == vehicleId then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) or not vehicle.gameObject.transform then
			print_error("BaikeModelViewerStore LoadVehicleModel vehicle gameObject or transform is null, vehicleId:" .. vehicleId)

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

		gCS.LuaUtils.SetStreamingMipmapsMaxFileIORequests(false)
	end

	gCS.LuaUtils.SetStreamingMipmapsMaxFileIORequests(true)
	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)
end

M.HideScene = function(self)
	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		self.scenePrefab.gameObject:SetActive(false)
	end
end

M.ShowScene = function(self)
	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		self.scenePrefab.gameObject:SetActive(true)
	end
end
