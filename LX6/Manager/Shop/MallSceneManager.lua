-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\MallSceneManager.lua
-- Decompiled from: 00526_MallSceneManager.lua_d01bff30d4ff.luajit

local DriveUtils = LX6.Drive.DriveUtils
local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
local VehicleConfig = LTConfig.VehicleConfig
local MallSceneConfig = LTConfig.MallSceneConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local MallConfig = LTConfig.MallConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local LayerConstants = LX6.Constants.LayerConstants
local UnitModelManager = LX6.Units.UnitModelManager
C_MallSceneManager = DefClass("C_MallSceneManager", C_MallSceneManager)
local M = C_MallSceneManager
M.LoadingType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["\\xef\\xde(\\xf4"] = 2,
	["`Om{O*"] = 1,
	["T-s^"] = 0
}
M.SmokeColorState = {
	["z\\xa6\\xab\\xbb\\xb3"] = 1,
	[",]\\x83\\x9e\\x8fD"] = 2,
	["T-s^"] = 0
}
M.SmokeColorIndicator = {
	["\\x9f"] = 2,
	["\\x9c"] = 1
}
M.DEFAULT_MALL_DGO = 23001951
M.DEFAULT_SCENE_PATH = "scene"
M.DEFAULT_CAMERA_POS = Vector3.New(10, -98, -25)
M.DEFAULT_IK_TYPE = "NPC_ground_idle"
M.CHARACTER_SHOW_TIMEOUT_FRAMES = 8
M.MALL_MODEL_MONTAGE_BLEND_OUT = 0.1
M.MALL_MODEL_ANIM_GRAPH_TYPE = LTConfig.AgentConfig.AnimGraphType.Npc_Other
M.MALL_SHOWCASE_MONTAGE_SIGNAL_ID = LTConfig.GameplaySignalInwardConfig.SystemMallPlayMontage
M.CAMERA_TRANSITION_LERP_SPEED = 8
M.CAMERA_TRANSITION_EPS = 0.001

M.ctor = function(self)
	self.currentModelUnit = nil
	self.currentModelEntry = nil
	self.currentModelSpiritId = nil
	self.loadedSuitId = nil
	self.pendingSuitId = nil
	self.pendingSuitCallbacks = nil
	self.currentLookAtIKType = ""
	self.mallVCamera = nil
	self.mallCenterPos = nil
	self.mallCenterEuler = nil
	self.mallModelPos = nil
	self.mallModelEuler = nil
	self.currentVehicle = nil
	self.pendingVehicle = nil
	self.loadedVehicleId = nil
	self.pendingVehicleId = nil
	self.pendingVehicleCallbacks = nil
	self.currentWeaponGo = nil
	self.weaponLoadOp = nil
	self.loadedWeaponId = nil
	self.pendingWeaponId = nil
	self.pendingWeaponCallbacks = nil
	self.loadingToken = 0
	self.currentLoadingType = self.LoadingType.None
	self.spawnSeq = 0
	self._characterShowTimer = nil
	self._characterShowFrames = 0
	self._pendingVideoEntrance = false
	self._videoPlaying = false
	self.currentSceneId = nil
	self.activeSceneDgoIds = {}
	self.mallWeatherId = 0
	self.sceneEffectUUIDs = {}
	self.loadedSceneEffectKey = nil
	self._sceneEffectArgs = nil
	self.dynamicLightGos = {}
	self.dynamicLightOps = {}
	self.loadedDynamicLightKey = nil
	self._dynamicLightArgs = nil
	self._smokeEffectGo = nil
	self._smokeColorState = self.SmokeColorState.None
	self._smokeColorTimer = nil
	self._smokeLerpTimer = nil
	self._vehicleTimelineName = nil
	self._vehicleShowReq = nil
	self._vehicleShowTimer = nil
	self.turnTableGo = nil
	self.turnTableOp = nil
	self.loadedTurnTableKey = nil
	self.turnTableInitPos = nil
	self.turnTableInitEuler = nil
	self.turnTableParented = false
	self.keepSceneHandleId = nil
	self._neighborWarmupTimer = nil
	self._neighborWarmupList = nil
	self._neighborWarmupIndex = 0
	self._dgoLoadedAction = nil
	self._cameraTransitionUpdateHandler = nil
	self._cameraTransitionTargetPos = nil
	self._cameraTransitionTargetEuler = nil
	self._cameraTransitionTargetFov = nil
	self.commoditySpiritMap = {}
	self._lastPreviewCommodityId = 0

	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self:CreateAction("_OnLoadingFinished"))
end

M.SaveCommoditySpiritMapping = function(self, commodityId, spiritId)
	self.commoditySpiritMap[commodityId] = spiritId
end

M.GetCommoditySpiritMapping = function(self, commodityId)
	return self.commoditySpiritMap[commodityId]
end

M.ClearCommoditySpiritMapping = function(self)
	self.commoditySpiritMap = {}
end

M.GetMallSceneConfigById = function(self, sceneId)
	if not MallSceneConfig then
		return nil
	end

	return MallSceneConfig.GetConfig(sceneId)
end

M.GetScenePathFromCfg = function(self, cfg)
	return cfg and cfg.Path and cfg.Path == "" and cfg.Path or self.DEFAULT_SCENE_PATH
end

M.ParsePosAndRot = function(self, data)
	if not data or type(data) == "table" or #data >= 3 then
		return nil, , 
	end

	local pos = Vector3.New(data[1], data[2], data[3])
	local fov = #data > 7 and data[7] and data[7] or nil

	if #data > 6 then
		return pos, Vector3.New(data[4], data[5], data[6]), fov
	end

	if #data > 4 then
		return pos, Vector3.New(0, data[4], 0), fov
	end

	return pos, nil, fov
end

M.ConvertLocalPoseToWorld = function(self, centerPos, centerEuler, localPos, localEuler)
	if not localPos and not localEuler then
		return nil, 
	end

	local zeroEuler = Vector3.New(0, 0, 0)
	local centerQuat = Quaternion.Euler(centerEuler or zeroEuler)
	local worldPos, worldEuler = nil

	if localPos then
		worldPos = centerPos + centerQuat * localPos
	end

	if localEuler then
		local worldQuat = centerQuat * Quaternion.Euler(localEuler)
		worldEuler = worldQuat.eulerAngles
	end

	return worldPos, worldEuler
end

M.ResolveSceneIdForCommodity = function(self, commodityData)
	if not commodityData then
		return 0
	end

	local sceneId = commodityData.sceneId or commodityData.SceneId

	if (not sceneId or sceneId ~= 0) and commodityData.id then
		local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityData.id)
		sceneId = commodityCfg and (commodityCfg.sceneId or commodityCfg.SceneId)
	end

	return sceneId or 0
end

M.ResolveTransformData = function(self, transformData)
	if transformData and transformData.position and (transformData.eulerAngles or transformData.euler) then
		return transformData.position, transformData.eulerAngles or transformData.euler
	end

	if self.mallModelPos and self.mallModelEuler then
		return self.mallModelPos, self.mallModelEuler
	end

	error("MallSceneManager:ResolveTransformData failed - mallModelPos/mallModelEuler not set, missing scene config?")
end

M._ComputeTransformsFromSceneCfg = function(self, cfg)
	if not cfg then
		return nil, , , 
	end

	local centerPos, centerEuler = self:ParsePosAndRot(cfg.CenterPosAndRot)
	centerPos = centerPos or Vector3.New(0, 0, 0)
	centerEuler = centerEuler or Vector3.New(0, 0, 0)
	local modelLocalPos, modelLocalEuler = self:ParsePosAndRot(cfg.ModelPosAndRot)
	local modelPos, modelEuler = self:ConvertLocalPoseToWorld(centerPos, centerEuler, modelLocalPos, modelLocalEuler)

	return centerPos, centerEuler, modelPos, modelEuler
end

M.BuildModelTransformBySceneCfg = function(self, cfg)
	self.mallCenterPos, self.mallCenterEuler, self.mallModelPos, self.mallModelEuler = self:_ComputeTransformsFromSceneCfg(cfg)
end

M.GetModelTransformData = function(self)
	if not self.mallModelPos and not self.mallModelEuler then
		return nil
	end

	return {
		position = self.mallModelPos,
		eulerAngles = self.mallModelEuler
	}
end

M.GetDefaultCameraFov = function(self)
	if self.currentVehicle then
		return 30
	end

	return 40
end

M.ApplyMallSceneWeather = function(self, cfg)
	local weatherId = cfg and cfg.Weather or 0

	if weatherId and weatherId <= 0 then
		gCS.GuiUtils.SetXuWeiWeatherState(true, weatherId)

		self.mallWeatherId = weatherId

		return
	end

	self:ClearMallSceneWeather()
end

M.ClearMallSceneWeather = function(self)
	if self.mallWeatherId and self.mallWeatherId <= 0 then
		self.mallWeatherId = 0
	end

	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

M.ApplyMallSceneById = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return nil
	end

	local cfg = self:GetMallSceneConfigById(sceneId)
	self.currentSceneId = sceneId

	self:ApplyMallSceneDgo(cfg)
	self:BuildModelTransformBySceneCfg(cfg)
	self:ApplyMallSceneWeather(cfg)
	self:LoadSceneTurnTable(cfg)

	return self:GetScenePathFromCfg(cfg)
end

M.WarmupSceneById = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return false
	end

	return self:_ActivateMallSceneDgo(self:_ResolveDgoId(self:GetMallSceneConfigById(sceneId)))
end

M.IsSceneWarmedUp = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return true
	end

	return self.activeSceneDgoIds[self:_ResolveDgoId(self:GetMallSceneConfigById(sceneId))] ~= true
end

M.NEIGHBOR_BEFORE = 1
M.NEIGHBOR_AFTER = 2

M.ScheduleWarmupNeighborScenes = function(self, list, centerIndex, getSceneIdFn)
	self:CancelScheduledWarmup()

	if not list or #list ~= 0 or not centerIndex or centerIndex <= 1 or not getSceneIdFn then
		return
	end

	local sceneIds = {}
	local seen = {}

	local pushAt = function(idx)
		local item = list[idx]

		if not item then
			return
		end

		local sceneId = getSceneIdFn(item)

		if sceneId and sceneId <= 0 and not seen[sceneId] then
			seen[sceneId] = true

			table.insert(sceneIds, sceneId)
		end
	end

	slot7 = 1
	slot8 = M.NEIGHBOR_BEFORE or 1

	for i = slot7, slot8 do
		pushAt(centerIndex - i)
	end

	slot7 = 1
	slot8 = M.NEIGHBOR_AFTER or 2

	for i = slot7, slot8 do
		pushAt(centerIndex + i)
	end

	if #sceneIds ~= 0 then
		return
	end

	self._neighborWarmupList = sceneIds
	self._neighborWarmupIndex = 0
	self._neighborWarmupTimer = Timer.New(self:CreateAction("_TickNeighborWarmup"), 0.1, -1):Start()
end

M.CancelScheduledWarmup = function(self)
	if self._neighborWarmupTimer then
		self._neighborWarmupTimer:Stop()

		self._neighborWarmupTimer = nil
	end

	self._neighborWarmupList = nil
	self._neighborWarmupIndex = 0
end

M._TickNeighborWarmup = function(self)
	if not self._neighborWarmupList then
		self:CancelScheduledWarmup()

		return
	end

	local list = self._neighborWarmupList

	while self._neighborWarmupIndex >= #list do
		self._neighborWarmupIndex = self._neighborWarmupIndex + 1
		local sceneId = list[self._neighborWarmupIndex]

		if not self:IsSceneWarmedUp(sceneId) then
			self:WarmupSceneById(sceneId)

			return
		end
	end

	self:CancelScheduledWarmup()
end

M.ReleaseAllPreloadedResources = function(self)
	self:CancelScheduledWarmup()
	self:ReleaseMallScene()
	self:ClearCommoditySceneEffects()
	self:ClearCommodityDynamicLight()
	self:ClearCharacterModel()
	self:ClearVehicle()
	self:ClearWeapon()
	self:ClearMallVCamera()
end

M.PreloadCommodityFull = function(self, commodityData)
	if not commodityData then
		return
	end

	print_debug("MallSceneManager PreloadCommodityFull commodityId:" .. tostring(commodityData.id) .. " type:" .. tostring(commodityData.type) .. " bindId:" .. tostring(commodityData.bindId) .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	local sceneId = self:ResolveSceneIdForCommodity(commodityData)
	local centerPos, centerEuler, modelPos, modelEuler = nil

	if sceneId <= 0 then
		self:WarmupSceneById(sceneId)

		centerPos, centerEuler, modelPos, modelEuler = self:_ComputeTransformsFromSceneCfg(self:GetMallSceneConfigById(sceneId))
	end

	if commodityData.id and commodityData.id <= 0 then
		self:PlayCommoditySceneEffects(commodityData.id, centerPos, centerEuler)
		self:LoadCommodityDynamicLight(commodityData.id, centerPos, centerEuler)
	end

	if sceneId <= 0 then
		self:LoadSceneTurnTable(self:GetMallSceneConfigById(sceneId), centerPos, centerEuler)
	end

	local itemType = commodityData.type

	if itemType ~= 0 or itemType ~= 7 then
		local spiritId = gMallManager:ResolveDisplaySpiritId(commodityData, commodityId and commodityId <= 0 and self:GetCommoditySpiritMapping(commodityId) or nil)

		if spiritId and spiritId <= 0 then
			local fashionInfo, suitKey = gMallManager:BuildFashionLoadParams(commodityData, spiritId)
			local transformData = nil

			if modelPos or modelEuler then
				transformData = {
					position = modelPos,
					eulerAngles = modelEuler
				}
			end

			self:LoadCharacterModel(spiritId, fashionInfo, suitKey, transformData, nil, commodityData.id)
		end
	elseif itemType ~= 1 and commodityData.bindId and commodityData.bindId <= 0 then
		local transformData = nil

		if modelPos or modelEuler then
			transformData = {
				position = modelPos,
				eulerAngles = modelEuler
			}
		end

		self:LoadVehicleModel(commodityData.bindId, transformData, nil)
	end
end

M._ResolveTargetCameraPose = function(self, isCheckCamera)
	local defaultFov = self:GetDefaultCameraFov()
	local cfg = self:GetMallSceneConfigById(self.currentSceneId)

	if not cfg then
		return self.DEFAULT_CAMERA_POS, nil, defaultFov, defaultFov
	end

	local cameraPosAndRot = isCheckCamera and cfg.CheckCameraPosAndRot or cfg.CameraPosAndRot
	local cameraLocalPos, cameraLocalEuler, fov = self:ParsePosAndRot(cameraPosAndRot)

	if not cameraLocalPos and not cameraLocalEuler then
		local fallbackPos = not isCheckCamera and self.DEFAULT_CAMERA_POS or nil

		return fallbackPos, nil, defaultFov, defaultFov
	end

	local cameraPos, cameraEuler = self:ConvertLocalPoseToWorld(self.mallCenterPos or Vector3.New(0, 0, 0), self.mallCenterEuler or Vector3.New(0, 0, 0), cameraLocalPos, cameraLocalEuler)

	if not cameraPos and not isCheckCamera then
		cameraPos = self.DEFAULT_CAMERA_POS
	end

	return cameraPos, cameraEuler, fov or defaultFov, defaultFov
end

M.ApplyMallSceneCamera = function(self, isCheckCamera, smooth)
	local vCamera = self.mallVCamera

	if not vCamera then
		return nil
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return nil
	end

	local targetPos, targetEuler, targetFov, _ = self:_ResolveTargetCameraPose(isCheckCamera)

	if smooth then
		self:_StartCameraTransition(cameraTransform, vCamera, targetPos, targetEuler, targetFov)
	else
		self:_StopCameraTransition()

		if targetPos then
			cameraTransform.position = targetPos
		end

		if targetEuler then
			cameraTransform.eulerAngles = targetEuler
		end

		gCS.LuaUtils.SetVCameraFOV(vCamera.gameObject, targetFov)
	end

	return targetFov
end

M._StartCameraTransition = function(self, cameraTransform, vCamera, targetPos, targetEuler, targetFov)
	self._cameraTransitionTargetPos = targetPos
	self._cameraTransitionTargetEuler = targetEuler
	self._cameraTransitionTargetFov = targetFov

	if self._cameraTransitionUpdateHandler then
		return
	end

	self._cameraTransitionUpdateHandler = UpdateBeat:CreateListener(self:CreateAction("_TickCameraTransition"), self)

	UpdateBeat:AddListener(self._cameraTransitionUpdateHandler)
end

M._TickCameraTransition = function(self)
	local vCamera = self.mallVCamera

	if not vCamera or gCS.LuaUtils.IsNull(vCamera) then
		self:_StopCameraTransition()

		return
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		self:_StopCameraTransition()

		return
	end

	local t = Time.deltaTime * self.CAMERA_TRANSITION_LERP_SPEED

	if t <= 1 then
		t = 1
	end

	local arrivedPos = true
	local arrivedRot = true
	local arrivedFov = true
	local targetPos = self._cameraTransitionTargetPos

	if targetPos then
		local cur = cameraTransform.position
		local newPos = Vector3.Lerp(cur, targetPos, t)
		cameraTransform.position = newPos

		if self.CAMERA_TRANSITION_EPS < Vector3.Distance(newPos, targetPos) then
			arrivedPos = false
		else
			cameraTransform.position = targetPos
		end
	end

	local targetEuler = self._cameraTransitionTargetEuler

	if targetEuler then
		local curQuat = cameraTransform.rotation
		local targetQuat = Quaternion.Euler(targetEuler)
		local newQuat = Quaternion.Slerp(curQuat, targetQuat, t)
		cameraTransform.rotation = newQuat

		if Quaternion.Angle(newQuat, targetQuat) > 0.05 then
			arrivedRot = false
		else
			cameraTransform.rotation = targetQuat
		end
	end

	local targetFov = self._cameraTransitionTargetFov

	if targetFov then
		local curFov = gCS.LuaUtils.GetVCameraFOV(vCamera.gameObject, nil) or targetFov
		local newFov = Mathf.Lerp(curFov, targetFov, t)

		if self.CAMERA_TRANSITION_EPS < math.abs(newFov - targetFov) then
			gCS.LuaUtils.SetVCameraFOV(vCamera.gameObject, newFov)

			arrivedFov = false
		else
			gCS.LuaUtils.SetVCameraFOV(vCamera.gameObject, targetFov)
		end
	end

	if arrivedPos and arrivedRot and arrivedFov then
		self:_StopCameraTransition()
	end
end

M._StopCameraTransition = function(self)
	if self._cameraTransitionUpdateHandler then
		UpdateBeat:RemoveListener(self._cameraTransitionUpdateHandler)

		self._cameraTransitionUpdateHandler = nil
	end

	self._cameraTransitionTargetPos = nil
	self._cameraTransitionTargetEuler = nil
	self._cameraTransitionTargetFov = nil
end

M.SetMallVCamera = function(self, camera)
	self.mallVCamera = camera
	camera.Priority = LX6.Cinemachine.EVcamPriority.Panel
end

M.ClearMallVCamera = function(self)
	self:_StopCameraTransition()

	self.mallVCamera = nil
end

M.GetCurrentLookAtIKType = function(self)
	local ikType = self.currentLookAtIKType

	if ikType and ikType == "" then
		return ikType
	end

	return self.DEFAULT_IK_TYPE
end

M.EnableMallSceneLookAtForCurrentModel = function(self)
	local unit = self.currentModelUnit

	if not unit or not self.mallVCamera then
		return
	end

	gCS.ShowcaseLookAtIkModule.StartShowcaseLookAt(unit, self:GetCurrentLookAtIKType(), self.mallVCamera.transform)
end

M.DisableMallSceneLookAt = function(self)
	local unit = self.currentModelUnit

	if not unit then
		return
	end

	gCS.ShowcaseLookAtIkModule.StopShowcaseLookAt(unit)
end

M.ApplyShopNamePrefix = function(self, go)
	if not go then
		return
	end

	local oldName = go.name

	if string.is_null_or_empty(oldName) then
		oldName = "model"
	end

	if string.sub(oldName, 1, 5) ~= "shop_" then
		return
	end

	go.name = "shop_" .. oldName
end

M._ResolveDgoId = function(self, cfg)
	return cfg and cfg.DgoId and cfg.DgoId <= 0 and cfg.DgoId or self.DEFAULT_MALL_DGO
end

M._ActivateMallSceneDgo = function(self, dgoId)
	if self.activeSceneDgoIds[dgoId] then
		return false
	end

	LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, true)

	if gLuaDataManager.isNetworkAvailable then
		gClientToGameSceneDelegate:AskActiveDynamicGo(dgoId, true, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
		end
	end

	self.activeSceneDgoIds[dgoId] = true

	return true
end

M.ApplyMallSceneDgo = function(self, cfg)
	self:_ActivateMallSceneDgo(self:_ResolveDgoId(cfg))
end

M.ReleaseAllActivatedDgos = function(self)
	local networkOk = gLuaDataManager.isNetworkAvailable

	for dgoId, isActive in pairs(self.activeSceneDgoIds) do
		if isActive then
			LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, false)

			if networkOk then
				gClientToGameSceneDelegate:AskActiveDynamicGo(dgoId, false, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
				end
			end
		end
	end

	self.activeSceneDgoIds = {}
end

M.BuildMallModelMontageActionArrays = function(self, actionClips)
	if not actionClips or #actionClips ~= 0 then
		return nil, , , , , , 
	end

	local actionKeys = {}
	local blendIns = {}
	local loopFlags = {}
	local playRates = {}
	local startTimes = {}
	local endTimes = {}

	for _, clip in ipairs(actionClips) do
		local actionKey = clip and (clip.ActionKey or 0) or 0

		if actionKey <= 0 then
			local index = #actionKeys + 1
			actionKeys[index] = actionKey
			blendIns[index] = clip.BlendIn or -1
			loopFlags[index] = clip.IsLoop and 1 or 0
			playRates[index] = clip.PlayRate and clip.PlayRate <= 0 and clip.PlayRate or 1
			startTimes[index] = clip.StartTime or 0
			endTimes[index] = clip.EndTime or 0
		end
	end

	if #actionKeys ~= 0 then
		return nil, , , , , , 
	end

	return actionKeys, blendIns, loopFlags, playRates, startTimes, endTimes, actionKeys[1]
end

M.TryPlayMallModelMontage = function(self, unit, modelEntry, useVideoClips)
	local clips = modelEntry and modelEntry.actionClips

	if useVideoClips and modelEntry and modelEntry.videoActionClips and #modelEntry.videoActionClips <= 0 then
		clips = modelEntry.videoActionClips
	end

	local actionKeys, blendIns, loopFlags, playRates, startTimes, endTimes, firstActionKey = self:BuildMallModelMontageActionArrays(clips)

	if not actionKeys then
		print_error_without_stack("MallSceneManager LoadCharacterModel InvalidMallModelActionClips")

		return false, nil
	end

	local ok = gCS.LogicStateMachineManager.SendGameplayMontageActions(unit, self.MALL_SHOWCASE_MONTAGE_SIGNAL_ID, actionKeys, blendIns, loopFlags, playRates, startTimes, endTimes, self.MALL_MODEL_MONTAGE_BLEND_OUT)

	print_debug("MallSceneManager LoadCharacterModel PlayConfiguredMontageActions", ok, #actionKeys)

	if not ok then
		print_error_without_stack("MallSceneManager LoadCharacterModel PlayConfiguredMontageActionsFailed", firstActionKey)
	end

	return ok, firstActionKey
end

M.ReleaseMallScene = function(self)
	self:ReleaseAllActivatedDgos()
	self:ClearMallSceneWeather()
	self:ClearSceneTurnTable()

	self.currentSceneId = nil
	self.mallCenterPos = nil
	self.mallCenterEuler = nil
	self.mallModelPos = nil
	self.mallModelEuler = nil
end

M.LoadCharacterModel = function(self, spiritId, fashionInfo, suitId, transformData, onLoadComplete, commodityId)
	if not spiritId or spiritId ~= 0 then
		self:ClearCharacterModel()

		return
	end

	if self.loadedSuitId and self.loadedSuitId ~= suitId and self.currentModelUnit then
		if onLoadComplete then
			onLoadComplete(self.currentModelUnit)
		end

		return
	end

	if self.pendingSuitId and self.pendingSuitId ~= suitId then
		if onLoadComplete then
			self.pendingSuitCallbacks = self.pendingSuitCallbacks or {}

			table.insert(self.pendingSuitCallbacks, onLoadComplete)
		end

		return
	end

	local fightSpiritConfig = FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	if not agentConfig then
		return
	end

	print_debug("MallSceneManager LoadCharacterModel BeginNew spiritId:" .. tostring(spiritId) .. " suitId:" .. tostring(suitId) .. " prevPendingSuitId:" .. tostring(self.pendingSuitId) .. " prevLoadedSuitId:" .. tostring(self.loadedSuitId))
	self:ClearVehicle()
	self:ClearCharacterModel()

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Character
	self.loadedSuitId = suitId
	self.currentModelSpiritId = spiritId
	self.pendingSuitId = suitId
	self.pendingSuitCallbacks = nil
	local characterPos, characterEuler = self:ResolveTransformData(transformData)
	local modelId = agentConfig.GeneralModelId
	local otherData = {
		["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
		["  \\xb1\\xf2- v ,\\xa0=;ى\\x94?\\xac\\x99\\xc0\\x9a"] = false,
		SubType = spiritId,
		cardId = spiritId,
		fashionWearInfo = fashionInfo
	}

	local cb = function(unit)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Character or self.loadedSuitId == suitId then
			if unit then
				unit:DestroyUnit(true)
			end

			return
		end

		UnitModelManager.HideOrShowAllRender(unit, false, true)

		self.currentModelUnit = unit

		self:ApplyShopNamePrefix(unit.PlayerObj)
		UnitModelManager.SetRenderLayer(unit, LayerConstants.Player)
		UnitModelManager.SetShadow(unit, true)
		gCS.LuaUtils.SetUnitHeightDarken(unit, 0.35)

		unit.PlayerObj.transform.localScale = Vector3.one
		unit.PlayerObj.transform.localEulerAngles = characterEuler
		unit.PlayerObj.transform.position = characterPos

		gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
		gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)
		gCS.LuaUtils.ForceSetPlayerPid(unit.Pid)

		unit.State.ActionGroupId = 1

		gCS.LuaUtils.AddLocalUnitStateMachineModule(unit, self.MALL_MODEL_ANIM_GRAPH_TYPE)

		local modelEntry = gMallManager:GetCommodityModelEntry(commodityId, spiritId)
		self.currentModelEntry = modelEntry
		self.currentLookAtIKType = modelEntry.lookAtIKType or ""
		local useVideoClips = self._pendingVideoEntrance
		self._pendingVideoEntrance = false
		local _, firstActionKey = self:TryPlayMallModelMontage(unit, modelEntry, useVideoClips)

		self:EnableMallSceneLookAtForCurrentModel()
		self:_StartWaitCharacterActionLoaded(unit, currentToken, suitId, firstActionKey)

		local queued = self.pendingSuitCallbacks
		self.pendingSuitId = nil
		self.pendingSuitCallbacks = nil

		if onLoadComplete then
			onLoadComplete(unit)
		end

		if queued then
			for _, fn in ipairs(queued) do
				fn(unit)
			end
		end
	end

	gUIUtils:LoadModel("", modelId, nil, , , , cb, nil, otherData)
end

M._StartWaitCharacterActionLoaded = function(self, unit, token, suitId, actionKey)
	self:_StopWaitCharacterActionLoaded()

	self._characterShowFrames = 0
	local timeoutFrames = self.CHARACTER_SHOW_TIMEOUT_FRAMES

	local tick = function()
		if token == self.loadingToken or self.currentLoadingType == self.LoadingType.Character or self.loadedSuitId == suitId or self.currentModelUnit == unit then
			self:_StopWaitCharacterActionLoaded()

			return
		end

		if not unit or gCS.LuaUtils.IsNull(unit.PlayerObj) then
			self:_StopWaitCharacterActionLoaded()

			return
		end

		self._characterShowFrames = self._characterShowFrames + 1
		local loaded = false

		if actionKey then
			loaded = gCS.AnimationManager.isLoadedActionKeyClip(unit, actionKey)
		end

		if loaded or timeoutFrames < self._characterShowFrames then
			UnitModelManager.HideOrShowAllRender(unit, true, true)
			self:_StopWaitCharacterActionLoaded()
		end
	end

	self._characterShowTimer = FrameTimer.New(tick, 2, -1):Start()
end

M._StopWaitCharacterActionLoaded = function(self)
	if self._characterShowTimer then
		self._characterShowTimer:Stop()

		self._characterShowTimer = nil
	end

	self._characterShowFrames = 0
end

M.ClearCharacterModel = function(self)
	self:DisableMallSceneLookAt()
	self:_StopWaitCharacterActionLoaded()

	self._pendingVideoEntrance = false

	if self.currentModelUnit then
		self.currentModelUnit:DestroyUnit(true)

		self.currentModelUnit = nil
	end

	self.currentModelEntry = nil
	self.currentModelSpiritId = nil
	self.loadedSuitId = nil
	self.pendingSuitId = nil
	self.pendingSuitCallbacks = nil
	self.currentLookAtIKType = ""

	if self.currentLoadingType ~= self.LoadingType.Character then
		self.currentLoadingType = self.LoadingType.None
	end
end

M.SetVideoPlaying = function(self, playing, skipReapply)
	playing = playing and true or false

	if self._videoPlaying ~= playing then
		return
	end

	self._videoPlaying = playing

	print_debug("MallSceneManager SetVideoPlaying:" .. tostring(playing) .. " skipReapply:" .. tostring(skipReapply ~= true))

	if playing then
		self:_RestartVehicleShowForVideo()

		return
	end

	if not skipReapply then
		self:_ReloadCommodityFxAndLight()
	end
end

M.IsVideoPlaying = function(self)
	return self._videoPlaying ~= true
end

M.ReplayCurrentModelActionClipsAfterVideo = function(self, onDone)
	self:SetVideoPlaying(false)

	local unit = self.currentModelUnit
	local entry = self.currentModelEntry

	if not unit or gCS.LuaUtils.IsNull(unit.PlayerObj) or not entry then
		local isCharacterFlow = self.currentLoadingType == self.LoadingType.Vehicle and self.currentLoadingType == self.LoadingType.Weapon
		self._pendingVideoEntrance = isCharacterFlow

		print_debug("MallSceneManager ReplayAfterVideo ModelNotReady, pendingVideoEntrance=" .. tostring(isCharacterFlow))

		if onDone then
			onDone()
		end

		return
	end

	print_debug("MallSceneManager ReplayAfterVideo videoClips:" .. tostring(entry.videoActionClips and #entry.videoActionClips or 0) .. " actionClips:" .. tostring(entry.actionClips and #entry.actionClips or 0))
	self:TryPlayMallModelMontage(unit, entry, true)

	if onDone then
		onDone()
	end
end

M.RerollPose = function(self, commodityId)
	local unit = self.currentModelUnit

	if not unit or gCS.LuaUtils.IsNull(unit.PlayerObj) then
		return false
	end

	local spiritId = self.currentModelSpiritId

	if not spiritId or spiritId ~= 0 then
		return false
	end

	if commodityId and commodityId <= 0 then
		local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityId)
		local specifiedId = commodityCfg and commodityCfg.SpecifiedModelid or 0

		if specifiedId and specifiedId <= 0 then
			return false
		end
	end

	if not gMallManager.spiritModelMap then
		gMallManager:BuildSpiritModelMap()
	end

	local list = gMallManager.spiritModelMap[spiritId]

	if not list or #list < 1 then
		return false
	end

	local prevEntry = self.currentModelEntry
	local newEntry = prevEntry

	for _ = 1, 10 do
		newEntry = list[math.random(1, #list)]

		if newEntry == prevEntry then
			break
		end
	end

	if newEntry ~= prevEntry then
		return false
	end

	self.currentModelEntry = newEntry
	self.currentLookAtIKType = newEntry.lookAtIKType or ""

	self:TryPlayMallModelMontage(unit, newEntry, false)
	self:EnableMallSceneLookAtForCurrentModel()

	return true
end

M.LoadVehicleModel = function(self, vehicleId, transformData, onLoadComplete, partId)
	if not vehicleId or vehicleId ~= 0 then
		self:ClearVehicle()

		return
	end

	if self.loadedVehicleId ~= vehicleId and self.currentVehicle then
		if onLoadComplete then
			onLoadComplete(self.currentVehicle)
		end

		return
	end

	if self.pendingVehicleId and self.pendingVehicleId ~= vehicleId then
		if onLoadComplete then
			self.pendingVehicleCallbacks = self.pendingVehicleCallbacks or {}

			table.insert(self.pendingVehicleCallbacks, onLoadComplete)
		end

		return
	end

	local cfg = VehicleConfig.GetConfig(vehicleId)

	if not cfg then
		return
	end

	print_debug("MallSceneManager LoadVehicleModel BeginNew vehicleId:" .. tostring(vehicleId) .. " prevPendingVehicleId:" .. tostring(self.pendingVehicleId) .. " prevLoadedVehicleId:" .. tostring(self.loadedVehicleId))
	gMessageManager:SendMessage(gEventConstants.UI_SHOW_VEHICLE, true)
	self:ClearCharacterModel()
	self:ClearVehicle(true)

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Vehicle
	self.loadedVehicleId = vehicleId
	self.pendingVehicleId = vehicleId
	self.pendingVehicleCallbacks = nil
	self.spawnSeq = self.spawnSeq + 1
	local mySeq = self.spawnSeq
	local vehiclePos, vehicleEuler = self:ResolveTransformData(transformData)
	local spawnParam = SpawnVehicleParam.New()
	spawnParam.position = vehiclePos
	spawnParam.facing = vehicleEuler.y
	spawnParam.forceDummy = true
	spawnParam.disableCollision = true
	spawnParam.shapeLightOff = true
	spawnParam.mainLightOn = true
	spawnParam.forceLODLevel = LX6.Share.VehicleForceLODLevel.Highest
	local partsId = partId and {
		partId
	} or cfg.DefaultPaint and {
		cfg.DefaultPaint
	} or nil

	spawnParam.beforeLoadAction = function(vehicle)
		if currentToken == self.loadingToken or mySeq == self.spawnSeq then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		self.pendingVehicle = vehicle

		if partsId then
			partsId = table.to_array(partsId)
		end

		if self.currentVehicle then
			self.currentVehicle:HideVehicle()
		end
	end

	spawnParam.afterLoadAction = function(vehicle)
		if currentToken == self.loadingToken or mySeq == self.spawnSeq then
			DriveUtils.DestroyVehicleClient(vehicle.uid)

			return
		end

		if not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) or not vehicle.gameObject.transform then
			print_error("MallSceneManager LoadVehicleModel vehicle gameObject or transform is null, vehicleId:" .. vehicleId)

			return
		end

		if self.currentVehicle and self.currentVehicle.uid == vehicle.uid then
			DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)
		end

		self.currentVehicle = vehicle

		self:ApplyShopNamePrefix(vehicle.gameObject)

		vehicle.gameObject.transform.eulerAngles = vehicleEuler

		if self.pendingVehicle ~= vehicle then
			self.pendingVehicle = nil
		end

		gCS.LuaUtils.ForceSetPlayerTransform(vehicle.gameObject.transform)
		self:AttachSceneTurnTableToVehicle(vehicle)
		self:RequestShowVehicleWithTimeline(vehicle, vehiclePos)

		local queued = self.pendingVehicleCallbacks
		self.pendingVehicleId = nil
		self.pendingVehicleCallbacks = nil

		if onLoadComplete then
			onLoadComplete(vehicle)
		end

		if queued then
			for _, fn in ipairs(queued) do
				fn(vehicle)
			end
		end
	end

	DriveUtils.SpawnVehicleClient(vehicleId, spawnParam)
end

M.ClearVehicle = function(self, isSwitchingVehicle)
	local hadVehicle = self.pendingVehicle == nil or self.currentVehicle == nil or self.loadedVehicleId == nil

	self:_StopVehicleTimeline()
	self:DetachSceneTurnTable()

	if self.pendingVehicle then
		DriveUtils.DestroyVehicleClient(self.pendingVehicle.uid)

		self.pendingVehicle = nil
	end

	if self.currentVehicle then
		DriveUtils.DestroyVehicleClient(self.currentVehicle.uid)

		self.currentVehicle = nil
	end

	self.loadedVehicleId = nil
	self.pendingVehicleId = nil
	self.pendingVehicleCallbacks = nil

	if self.currentLoadingType ~= self.LoadingType.Vehicle then
		self.currentLoadingType = self.LoadingType.None
	end

	if not isSwitchingVehicle and hadVehicle then
		gMessageManager:SendMessage(gEventConstants.UI_SHOW_VEHICLE, false)
	end
end

M.VEHICLE_SHOW_TIMEOUT_FRAMES = 60
M.VEHICLE_WAIT_VIDEO_TIMEOUT_SEC = 60

M.RequestShowVehicleWithTimeline = function(self, vehicle, pos)
	if not vehicle then
		return false
	end

	local sceneCfg = self.currentSceneId and self:GetMallSceneConfigById(self.currentSceneId)
	local timelineName = sceneCfg and sceneCfg.VehicleSceneTimeline

	if not timelineName or timelineName ~= "" then
		return false
	end

	self:_StopVehicleTimeline()
	gTimelineManager:Timeline_DiscardTimeline(timelineName)
	vehicle:HideVehicle()

	self._vehicleShowReq = {
		["`\\xf5*\\xe9%>!\\xc6S%\\xc4^\\x89V\\xc3\\xe2"] = false,
		["\\xf3\\x93\\xe9\\xe8Ƈ\\xec\\x86%,"] = false,
		["D[ǩ\\xa2\\xb9\t\\xcc\\xfb"] = 0,
		["\\xea[)\\xe7\\xbfU\\x95_\\xbd\\xb3"] = 0,
		["y\\xa8rC\\x86\\xfbJoukX"] = false,
		vehicle = vehicle,
		pos = pos,
		timelineName = timelineName
	}
	self._vehicleShowTimer = FrameTimer.New(function ()
		self:_TryShowVehicleWithTimeline()
	end, 1, -1):Start()

	return true
end

M._RestartVehicleShowForVideo = function(self)
	if self._vehicleShowReq then
		return
	end

	local vehicle = self.currentVehicle

	if not vehicle or not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
		return
	end

	self:RequestShowVehicleWithTimeline(vehicle, vehicle.gameObject.transform.position)
end

M._TryShowVehicleWithTimeline = function(self)
	local req = self._vehicleShowReq

	if not req then
		self:_StopVehicleShowRequest()

		return
	end

	local vehicle = req.vehicle

	if self.currentVehicle == vehicle or not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
		self:_StopVehicleShowRequest()

		return
	end

	if self._videoPlaying and not req.videoTimeout then
		req.videoWaitTime = req.videoWaitTime + Time.deltaTime

		if req.videoWaitTime >= self.VEHICLE_WAIT_VIDEO_TIMEOUT_SEC then
			return
		end

		req.videoTimeout = true

		print_warn("MallSceneManager VehicleTimeline wait video timeout, keep going:" .. tostring(req.timelineName))
	end

	if not req.timelineRequested then
		req.timelineRequested = true

		self:_PlayVehicleTimeline(req)

		return
	end

	if not req.timelineLoaded then
		req.waitFrames = req.waitFrames + 1

		if req.waitFrames >= self.VEHICLE_SHOW_TIMEOUT_FRAMES then
			return
		end

		print_warn("MallSceneManager VehicleTimeline wait timeout, show vehicle anyway:" .. tostring(req.timelineName))
	end

	self:_StopVehicleShowRequest()
	print_debug("MallSceneManager VehicleTimeline Show:" .. tostring(req.timelineName) .. " loaded:" .. tostring(req.timelineLoaded))
	gTimelineManager:Timeline_Pause(req.timelineName, false)
	FrameTimer.New(function ()
		if self.currentVehicle ~= vehicle and not gCS.LuaUtils.IsNull(vehicle.gameObject) then
			vehicle:ShowVehicle(0)
		end
	end, 1, 1):Start()
end

M._PlayVehicleTimeline = function(self, req)
	local timelineName = req.timelineName
	local tlData = gTimelineManager:Timeline_CreateTimelineData()
	tlData.pos = req.pos

	tlData.onLoadDoneCallback = function()
		if self._vehicleShowReq ~= req then
			gTimelineManager:Timeline_Pause(timelineName, true)

			req.timelineLoaded = true

			return
		end

		if self._vehicleTimelineName == timelineName then
			gTimelineManager:Timeline_Stop(timelineName)
		end
	end

	self._vehicleTimelineName = timelineName

	gTimelineManager:Timeline_LoadAndPlay(timelineName, tlData)
end

M._StopVehicleShowRequest = function(self)
	if self._vehicleShowTimer then
		self._vehicleShowTimer:Stop()

		self._vehicleShowTimer = nil
	end

	self._vehicleShowReq = nil
end

M._StopVehicleTimeline = function(self)
	self:_StopVehicleShowRequest()

	if self._vehicleTimelineName then
		gTimelineManager:Timeline_Stop(self._vehicleTimelineName)

		self._vehicleTimelineName = nil
	end
end

M.TryToggleVehiclePartByScreenPos = function(self, screenPos)
	local vehicle = self.currentVehicle

	if not vehicle then
		return false
	end

	local camera = gCS.CameraDataMgr.MainCamera

	if not camera or gCS.LuaUtils.IsNull(camera) then
		return false
	end

	local ray = camera:ScreenPointToRay(screenPos)

	return gVehicleGamePlayManager.cs_manager:TryToggleVehiclePartByRay(vehicle.uid, ray)
end

M.LoadWeaponModel = function(self, weaponId, transformData, onLoadComplete)
	if not weaponId or weaponId ~= 0 then
		self:ClearWeapon()

		return
	end

	if self.loadedWeaponId ~= weaponId and self.currentWeaponGo and not gCS.LuaUtils.IsNull(self.currentWeaponGo) then
		if onLoadComplete then
			onLoadComplete(self.currentWeaponGo)
		end

		return
	end

	if self.pendingWeaponId and self.pendingWeaponId ~= weaponId then
		if onLoadComplete then
			self.pendingWeaponCallbacks = self.pendingWeaponCallbacks or {}

			table.insert(self.pendingWeaponCallbacks, onLoadComplete)
		end

		return
	end

	local weaponCfg = SceneitemConfig.GetConfig(weaponId)

	if not weaponCfg or not weaponCfg.DJResPath or #weaponCfg.DJResPath ~= 0 then
		self:ClearWeapon()

		return
	end

	local modelResPath = nil

	for i = 1, #weaponCfg.DJResPath do
		local path = weaponCfg.DJResPath[i]

		if not string.is_null_or_empty(path) then
			modelResPath = path

			break
		end
	end

	if string.is_null_or_empty(modelResPath) then
		self:ClearWeapon()

		return
	end

	print_debug("MallSceneManager LoadWeaponModel BeginNew weaponId:" .. tostring(weaponId) .. " prevPendingWeaponId:" .. tostring(self.pendingWeaponId) .. " prevLoadedWeaponId:" .. tostring(self.loadedWeaponId))
	self:ClearWeapon()

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Weapon
	self.loadedWeaponId = weaponId
	self.pendingWeaponId = weaponId
	self.pendingWeaponCallbacks = nil
	local weaponPos, weaponEuler = self:ResolveTransformData(transformData)
	self.weaponLoadOp = gResourceManager:LoadAssetWithCallBack(gCS.LuaUtils.GetWeaponResPath(modelResPath), typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Weapon or self.loadedWeaponId == weaponId then
			return
		end

		if not loadOp or not loadOp.asset then
			return
		end

		local weaponGo = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if not weaponGo then
			return
		end

		self:ApplyShopNamePrefix(weaponGo)

		weaponGo.transform.position = weaponPos
		weaponGo.transform.eulerAngles = weaponEuler
		weaponGo.transform.localScale = Vector3.New(1, 1, 1)

		weaponGo:SetActive(true)
		gCS.LuaUtils.ForceSetPlayerTransform(weaponGo.transform)

		self.currentWeaponGo = weaponGo
		local queued = self.pendingWeaponCallbacks
		self.pendingWeaponId = nil
		self.pendingWeaponCallbacks = nil

		if onLoadComplete then
			onLoadComplete(weaponGo)
		end

		if queued then
			for _, fn in ipairs(queued) do
				fn(weaponGo)
			end
		end
	end)
end

M.ClearWeapon = function(self)
	if self.weaponLoadOp then
		gResourceManager:UnloadAssetLoadOp(self.weaponLoadOp)

		self.weaponLoadOp = nil
	end

	if self.currentWeaponGo and not gCS.LuaUtils.IsNull(self.currentWeaponGo) then
		UnityEngine.GameObject.Destroy(self.currentWeaponGo)
	end

	self.currentWeaponGo = nil
	self.loadedWeaponId = nil
	self.pendingWeaponId = nil
	self.pendingWeaponCallbacks = nil

	if self.currentLoadingType ~= self.LoadingType.Weapon then
		self.currentLoadingType = self.LoadingType.None
	end
end

M.PlayCommoditySceneEffects = function(self, commodityId, centerPos, centerEuler)
	local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityId)
	local effectIds = commodityCfg and commodityCfg.SceneEffects

	if not effectIds or #effectIds ~= 0 then
		self:ClearCommoditySceneEffects()

		return
	end

	centerPos = centerPos or self.mallCenterPos or Vector3.zero
	centerEuler = centerEuler or self.mallCenterEuler or Vector3.zero
	self._sceneEffectArgs = {
		commodityId = commodityId,
		centerPos = centerPos,
		centerEuler = centerEuler
	}
	local key = string.format("%s|%s,%s,%s|%s,%s,%s", table.concat(effectIds, ","), tostring(centerPos.x), tostring(centerPos.y), tostring(centerPos.z), tostring(centerEuler.x), tostring(centerEuler.y), tostring(centerEuler.z))

	if self.loadedSceneEffectKey ~= key and #self.sceneEffectUUIDs <= 0 then
		return
	end

	self:ClearCommoditySceneEffects()

	for _, effectId in ipairs(effectIds) do
		local uuid = gCS.EffectMgr:PlayEffect(effectId, LX6.Effect.EffectPlayTag.Gameplay, centerPos, centerEuler, nil, 0, -1)

		table.insert(self.sceneEffectUUIDs, uuid)
	end

	self.loadedSceneEffectKey = key
end

M.ClearCommoditySceneEffects = function(self)
	for _, uuid in ipairs(self.sceneEffectUUIDs) do
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)
	end

	self.sceneEffectUUIDs = {}
	self.loadedSceneEffectKey = nil
	self._sceneEffectArgs = nil
end

M._ReloadCommodityFxAndLight = function(self)
	local fxArgs = self._sceneEffectArgs

	if fxArgs then
		print_debug("MallSceneManager ReloadSceneEffectsAfterVideo commodityId:" .. tostring(fxArgs.commodityId))
		self:ClearCommoditySceneEffects()
		self:PlayCommoditySceneEffects(fxArgs.commodityId, fxArgs.centerPos, fxArgs.centerEuler)
	end

	local lightArgs = self._dynamicLightArgs

	if lightArgs then
		print_debug("MallSceneManager ReloadDynamicLightAfterVideo commodityId:" .. tostring(lightArgs.commodityId))
		self:ClearCommodityDynamicLight()
		self:LoadCommodityDynamicLight(lightArgs.commodityId, lightArgs.centerPos, lightArgs.centerEuler, lightArgs.applyPlayerLayer)
	end
end

M._GetSmokeStateFromDynamicLight = function(self, paths)
	local indicators = gMallSceneManager.SmokeColorIndicator

	for _, p in ipairs(paths) do
		local state = indicators[p]

		if state then
			return state
		end
	end

	return gMallSceneManager.SmokeColorState.None
end

M._IsSmokeColorIndicator = function(self, path)
	return gMallSceneManager.SmokeColorIndicator[path] == nil
end

M._IsSmokePath = function(self, path)
	return path ~= MallConfig.Smoke1 or path ~= MallConfig.Smoke2
end

M._ParseSmokeHSVA = function(self, cfgTable)
	local h = cfgTable[1] / 360
	local s = cfgTable[2] / 100
	local v = cfgTable[3] / 100
	local a = cfgTable[4] / 100
	local c = Color.HSVToRGB(h, s, v)
	c.a = a

	return c
end

M._GetSmokeColors = function(self, state)
	if state ~= gMallSceneManager.SmokeColorState.White then
		return self:_ParseSmokeHSVA(MallConfig.SmokeColorWhite)
	elseif state ~= gMallSceneManager.SmokeColorState.Purple then
		return self:_ParseSmokeHSVA(MallConfig.SmokeColorPurple)
	end

	return nil
end

M._StopSmokeColorTimer = function(self)
	if self._smokeColorTimer then
		self._smokeColorTimer:Stop()

		self._smokeColorTimer = nil
	end

	if self._smokeLerpTimer then
		self._smokeLerpTimer:Stop()

		self._smokeLerpTimer = nil
	end
end

M._LerpSmokeShaderColor = function(self, go, targetColor, duration)
	if self._smokeLerpTimer then
		self._smokeLerpTimer:Stop()

		self._smokeLerpTimer = nil
	end

	local renderers = go:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)

	if not renderers or renderers.Length ~= 0 then
		return
	end

	local startColor = renderers[0].material:GetColor("_TransmissionColor")
	local elapsed = 0
	self._smokeLerpTimer = Timer.New(function ()
		elapsed = elapsed + Time.deltaTime
		local t = elapsed / duration

		if t > 1 then
			t = 1
		end

		local curveT = t >= 0.5 and 2 * t * t or 1 - 2 * (1 - t) * (1 - t)
		local lerpedColor = Color.Lerp(startColor, targetColor, curveT)

		for i = 0, renderers.Length - 1 do
			local renderer = renderers[i]

			if renderer and renderer.material then
				renderer.material:SetColor("_TransmissionColor", lerpedColor)
			end
		end

		if t > 1 then
			self._smokeLerpTimer:Stop()

			self._smokeLerpTimer = nil
		end
	end, 0.016, -1):Start()
end

M._TransitionSmokeColor = function(self, targetState)
	self:_StopSmokeColorTimer()

	local go = self._smokeEffectGo

	if not go then
		return
	end

	local times = MallConfig.SmokeColorChangeTime
	local time1 = times[1]
	local time2 = times[2]
	local time3 = times[3]
	local midColor = self:_ParseSmokeHSVA(MallConfig.SmokeColorMid)
	local targetColor = self:_GetSmokeColors(targetState)

	self:_LerpSmokeShaderColor(go, midColor, time1)

	self._smokeColorTimer = Timer.New(function ()
		self._smokeColorTimer = nil

		if not go or not targetColor then
			return
		end

		self:_LerpSmokeShaderColor(go, targetColor, time3)
	end, time1 + time2, 1):Start()
end

M.LoadCommodityDynamicLight = function(self, commodityId, centerPos, centerEuler, applyPlayerLayer)
	local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityId)
	local paths = commodityCfg and commodityCfg.DynamicLight

	if not paths or #paths ~= 0 then
		self:ClearCommodityDynamicLight()

		return
	end

	centerPos = centerPos or self.mallCenterPos or Vector3.zero
	centerEuler = centerEuler or self.mallCenterEuler or Vector3.zero
	self._dynamicLightArgs = {
		commodityId = commodityId,
		centerPos = centerPos,
		centerEuler = centerEuler,
		applyPlayerLayer = applyPlayerLayer
	}
	local key = table.concat(paths, ",") .. "|" .. tostring(applyPlayerLayer and 1 or 0)
	local newSmokeState = self:_GetSmokeStateFromDynamicLight(paths)
	local oldSmokeState = self._smokeColorState

	if newSmokeState == gMallSceneManager.SmokeColorState.None and oldSmokeState == gMallSceneManager.SmokeColorState.None and newSmokeState == oldSmokeState and self._smokeEffectGo and not gCS.LuaUtils.IsNull(self._smokeEffectGo) then
		self:_TransitionSmokeColor(newSmokeState)

		self._smokeColorState = newSmokeState
		self.loadedDynamicLightKey = key

		return
	end

	if self.loadedDynamicLightKey ~= key and #self.dynamicLightGos <= 0 then
		for _, go in ipairs(self.dynamicLightGos) do
			if go and not gCS.LuaUtils.IsNull(go) then
				go.transform.position = centerPos
				go.transform.eulerAngles = centerEuler
			end
		end

		return
	end

	self:ClearCommodityDynamicLight()

	self.loadedDynamicLightKey = key

	for _, path in ipairs(paths) do
		if not self:_IsSmokeColorIndicator(path) then
			local isSmoke = self:_IsSmokePath(path)
			local op = gResourceManager:LoadAssetWithCallBack("Assets/Res/Prefab/Misc/" .. path .. ".prefab", typeof(UnityEngine.GameObject), function (loadOp)
				if not loadOp or not loadOp.asset then
					return
				end

				if self.loadedDynamicLightKey == key then
					return
				end

				local go = UnityEngine.GameObject.Instantiate(loadOp.asset)
				go.transform.position = centerPos
				go.transform.eulerAngles = centerEuler

				if applyPlayerLayer then
					go:SetLayerRecursively(LX6.Constants.LayerConstants.Player)
					go:SetActive(false)
					go:SetActive(true)
				end

				table.insert(self.dynamicLightGos, go)

				if isSmoke then
					self._smokeEffectGo = go
					self._smokeColorState = newSmokeState
				end
			end)

			table.insert(self.dynamicLightOps, op)
		end
	end
end

M.ClearCommodityDynamicLight = function(self)
	self:_StopSmokeColorTimer()

	for _, go in ipairs(self.dynamicLightGos) do
		if go and not gCS.LuaUtils.IsNull(go) then
			GameObject.Destroy(go)
		end
	end

	self.dynamicLightGos = {}

	for _, op in ipairs(self.dynamicLightOps) do
		if op then
			gResourceManager:UnloadAssetLoadOp(op)
		end
	end

	self.dynamicLightOps = {}
	self.loadedDynamicLightKey = nil
	self._dynamicLightArgs = nil
	self._smokeEffectGo = nil
	self._smokeColorState = gMallSceneManager.SmokeColorState.None
end

M.LoadSceneTurnTable = function(self, cfg, centerPos, centerEuler)
	local path = cfg and cfg.VehicleSceneTurnTable

	if not path or path ~= "" then
		self:ClearSceneTurnTable()

		return
	end

	centerPos = centerPos or self.mallCenterPos or Vector3.zero
	centerEuler = centerEuler or self.mallCenterEuler or Vector3.zero
	local key = path .. "|" .. centerPos.x .. "," .. centerPos.y .. "," .. centerPos.z

	if self.loadedTurnTableKey ~= key then
		return
	end

	self:ClearSceneTurnTable()

	self.loadedTurnTableKey = key
	self.turnTableInitPos = centerPos
	self.turnTableInitEuler = centerEuler
	self.turnTableOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if self.loadedTurnTableKey == key then
			return
		end

		if not loadOp or not loadOp.asset then
			return
		end

		local go = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if not go then
			return
		end

		self:ApplyShopNamePrefix(go)

		go.transform.position = self.turnTableInitPos or centerPos
		go.transform.eulerAngles = self.turnTableInitEuler or centerEuler
		go.transform.localScale = Vector3.one

		go:SetActive(true)
		go:SetLayerRecursively(LayerConstants.Floor)

		if go.transform.childCount <= 0 then
			local firstChild = go.transform:GetChild(0).gameObject

			if not firstChild:GetComponent(typeof(UnityEngine.BoxCollider)) then
				firstChild:AddComponent(typeof(UnityEngine.BoxCollider))
			end
		end

		self.turnTableGo = go
		self.turnTableParented = false

		if self.currentVehicle and self.currentVehicle.gameObject and not gCS.LuaUtils.IsNull(self.currentVehicle.gameObject) then
			self:AttachSceneTurnTableToVehicle(self.currentVehicle)
		end
	end)
end

M.AttachSceneTurnTableToVehicle = function(self, vehicle)
	if self.turnTableParented then
		return
	end

	if not self.turnTableGo or gCS.LuaUtils.IsNull(self.turnTableGo) then
		return
	end

	if not vehicle or not vehicle.gameObject or gCS.LuaUtils.IsNull(vehicle.gameObject) then
		return
	end

	self.turnTableGo.transform:SetParent(vehicle.gameObject.transform, true)

	self.turnTableParented = true
end

M.DetachSceneTurnTable = function(self)
	if not self.turnTableParented then
		return
	end

	self.turnTableParented = false

	if not self.turnTableGo or gCS.LuaUtils.IsNull(self.turnTableGo) then
		return
	end

	self.turnTableGo.transform:SetParent(nil, true)

	if self.turnTableInitPos then
		self.turnTableGo.transform.position = self.turnTableInitPos
	end

	if self.turnTableInitEuler then
		self.turnTableGo.transform.eulerAngles = self.turnTableInitEuler
	end
end

M.ClearSceneTurnTable = function(self)
	if self.turnTableGo and not gCS.LuaUtils.IsNull(self.turnTableGo) then
		GameObject.Destroy(self.turnTableGo)
	end

	self.turnTableGo = nil

	if self.turnTableOp then
		gResourceManager:UnloadAssetLoadOp(self.turnTableOp)

		self.turnTableOp = nil
	end

	self.loadedTurnTableKey = nil
	self.turnTableInitPos = nil
	self.turnTableInitEuler = nil
	self.turnTableParented = false
end

M.StartListenDynamicGoLoaded = function(self)
	if self._dgoLoadedAction then
		return
	end

	self._dgoLoadedAction = self:CreateAction("OnDynamicGoLoaded")

	gMessageManager:AddMessageListener(gEventConstants.ON_DYNAMIC_GO_LOADED, self._dgoLoadedAction)
end

M.StopListenDynamicGoLoaded = function(self)
	if not self._dgoLoadedAction then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_DYNAMIC_GO_LOADED, self._dgoLoadedAction)

	self._dgoLoadedAction = nil
	self._lastPreviewCommodityId = 0
end

M.OnDynamicGoLoaded = function(self, _, dg)
	local go = dg.gameObject

	if go and not gCS.LuaUtils.IsNull(go) then
		gCS.LuaUtils.ForceAddCustomProbeByGo(go)
	end
end

M._OnLoadingFinished = function(self, _, switchType)
	if switchType == gSwitchSceneType.Reconnect then
		return
	end

	self:_TryReloadAfterReconnect()
end

M._TryReloadAfterReconnect = function(self)
	if not self._lastPreviewCommodityId or self._lastPreviewCommodityId < 0 then
		return
	end

	if not gPanelManager:IsPanelShowing(gPanelId.SHOP_HOME_PAGE) then
		return
	end

	if self.currentModelUnit or self.currentVehicle or self.currentWeaponGo and not gCS.LuaUtils.IsNull(self.currentWeaponGo) then
		return
	end

	local homeStore = gStoreManager:GetStoreGroup("ShopHomePagePanelStore")

	if not self.mallVCamera and homeStore and homeStore.bindData and homeStore.bindData.VCamera and not gCS.LuaUtils.IsNull(homeStore.bindData.VCamera) then
		self:SetMallVCamera(homeStore.bindData.VCamera)
	end

	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	self:StartListenDynamicGoLoaded()
	print_debug("MallSceneManager _TryReloadAfterReconnect commodityId:" .. tostring(self._lastPreviewCommodityId))

	local onLoaded = nil

	if homeStore and homeStore.UpdateMallCameraControl then
		onLoaded = function()
			homeStore:UpdateMallCameraControl()
		end
	end

	self:PreviewCommodityById(self._lastPreviewCommodityId, {
		onLoaded = onLoaded
	})
end

M.PreviewCommodityById = function(self, commodityId, options)
	options = options or {}
	local applyCamera = options.applyCamera == false
	local skipFxAndLight = options.skipFxAndLight ~= true
	local commodityData = gMallManager:GetCommodityDataById(commodityId)

	if not commodityData then
		return self.LoadingType.None
	end

	self._lastPreviewCommodityId = commodityId
	local itemType = commodityData.type
	local bindId = commodityData.bindId or 0

	local applySceneAndFx = function(isPlayerLayer)
		local sceneId = self:ResolveSceneIdForCommodity(commodityData)

		self:DisableMallSceneLookAt()

		if sceneId and sceneId <= 0 then
			self:ApplyMallSceneById(sceneId)

			if applyCamera then
				self:ApplyMallSceneCamera(false)
			end
		end

		if not skipFxAndLight then
			if commodityId <= 0 then
				self:PlayCommoditySceneEffects(commodityId)
				self:LoadCommodityDynamicLight(commodityId, nil, , isPlayerLayer)
			else
				self:ClearCommoditySceneEffects()
				self:ClearCommodityDynamicLight()
			end
		end
	end

	if itemType ~= 2 then
		local weaponId = bindId

		if weaponId ~= 0 and commodityData.dropId and commodityData.dropId <= 0 then
			local dropCfg = LTConfig.DropConfig.GetConfig(commodityData.dropId)
			local item1 = dropCfg and dropCfg.Item1 and dropCfg.Item1[1]
			local consumeCfg = item1 and LTConfig.ConsumableConfig.GetConfig(item1.id1)
			weaponId = consumeCfg and consumeCfg.BindId or 0
		end

		applySceneAndFx(true)

		local transformData = self:GetModelTransformData()

		gCS.LuaUtils.SetShadowFocus(self.mallModelPos)
		self:ClearCharacterModel()
		self:ClearVehicle()

		if weaponId <= 0 then
			self:LoadWeaponModel(weaponId, transformData, options.onLoaded)
		end

		return self.LoadingType.Weapon
	end

	if itemType ~= 1 then
		if bindId ~= 0 then
			return self.LoadingType.None
		end

		applySceneAndFx(false)
		self:ClearWeapon()
		gCS.LuaUtils.SetShadowFocus(self.mallModelPos)
		self:LoadVehicleModel(bindId, nil, options.onLoaded, options.partId)

		return self.LoadingType.Vehicle
	end

	if itemType ~= 0 or itemType ~= 7 then
		local overrideSpiritId = options.spiritId or commodityId and commodityId <= 0 and self:GetCommoditySpiritMapping(commodityId)
		local spiritId = gMallManager:ResolveDisplaySpiritId(commodityData, overrideSpiritId)

		if not spiritId or spiritId ~= 0 then
			return self.LoadingType.None
		end

		if options.spiritId and options.spiritId <= 0 and commodityId and commodityId <= 0 then
			self:SaveCommoditySpiritMapping(commodityId, spiritId)
		end

		local fashionInfo, suitKey = gMallManager:BuildFashionLoadParams(commodityData, spiritId)

		if self.loadedSuitId and self.loadedSuitId ~= suitKey and self.currentModelUnit then
			if options.onLoaded then
				options.onLoaded(self.currentModelUnit)
			end

			return self.LoadingType.Character
		end

		applySceneAndFx(false)
		self:ClearWeapon()
		gCS.LuaUtils.SetShadowFocus(self.mallModelPos)
		self:LoadCharacterModel(spiritId, fashionInfo, suitKey, nil, options.onLoaded, commodityId)

		return self.LoadingType.Character
	end

	if itemType ~= 5 or itemType ~= 6 then
		local consumeCfg = bindId <= 0 and ConsumableConfig.GetConfig(bindId) or nil

		if consumeCfg and consumeCfg.SubType ~= ConsumableTypeConfig.ActionItem then
			local commodityCfg = LTConfig.MallCommodityConfig.GetConfig(commodityId)
			local spiritId = gMallManager:AdjustProtagonistSpiritId(commodityCfg and commodityCfg.SpiritId or 0) or 0

			if spiritId ~= 0 then
				return self.LoadingType.None
			end

			local fashionInfo = gMallManager.GetSpiritDefaultFashionInfo(spiritId)
			local suitKey = tostring(spiritId) .. "_action_" .. tostring(commodityId)

			if self.loadedSuitId and self.loadedSuitId ~= suitKey and self.currentModelUnit then
				if options.onLoaded then
					options.onLoaded(self.currentModelUnit)
				end

				return self.LoadingType.Character
			end

			applySceneAndFx(false)
			self:ClearWeapon()
			gCS.LuaUtils.SetShadowFocus(self.mallModelPos)
			self:LoadCharacterModel(spiritId, fashionInfo, suitKey, nil, options.onLoaded, commodityId)

			return self.LoadingType.Character
		end
	end

	return self.LoadingType.None
end

gMallSceneManager = gMallSceneManager or C_MallSceneManager.new()
