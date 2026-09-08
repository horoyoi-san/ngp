-- Original chunk: @Lua\LuaFiles\LX6\Manager\PlayerProfile\PlayerProfileSceneManager.lua
-- Decompiled from: 00528_PlayerProfileSceneManager.lua_58b2b1f876ca.luajit

local ImageSceneiconConfig = LTConfig.ImageSceneiconConfig
local ImageSceneStickerConfig = LTConfig.ImageSceneStickerConfig
local ImageActionListConfig = LTConfig.ImageActionListConfig
local VehiclePartSuitConfig = LTConfig.VehiclePartSuitConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local LayerConstants = LX6.Constants.LayerConstants
local FilterEffectManager = LX6.Effect.FilterEffectManager
local PhotoUtils = LX6.Utils.PhotoUtils
local STICKER_MODE_WORLD = 0
local STICKER_MODE_SCREEN_UI = 1
local SCENARIO_MONTAGE_SIGNAL_ID = LTConfig.GameplaySignalInwardConfig.SystemMallPlayMontage
local SCENARIO_MONTAGE_BLEND_OUT = 0.1
C_PlayerProfileSceneManager = DefClass("C_PlayerProfileSceneManager", C_PlayerProfileSceneManager)
local M = C_PlayerProfileSceneManager

M.ctor = function(self)
	self.vCamera = nil
	self.currentSceneId = nil
	self.activeSceneDgoIds = {}
	self.centerPos = nil
	self.centerEuler = nil
	self.cameraPos = nil
	self.cameraEuler = nil
	self.weatherId = 0
	self.keepSceneHandleId = nil
	self._dgoLoadedAction = nil
	self.actionClipsMap = nil
end

M.SetVCamera = function(self, camera)
	self.vCamera = camera
	camera.Priority = LX6.Cinemachine.EVcamPriority.Panel
end

M.ClearVCamera = function(self)
	self.vCamera = nil
end

M.GetSceneConfig = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return nil
	end

	return ImageSceneiconConfig.GetConfig(sceneId)
end

M.ParsePosAndRot = function(self, data)
	if not data or type(data) == "table" or #data >= 3 then
		return nil, 
	end

	local pos = Vector3.New(data[1], data[2], data[3])

	if #data > 6 then
		return pos, Vector3.New(data[4], data[5], data[6])
	end

	if #data > 4 then
		return pos, Vector3.New(0, data[4], 0)
	end

	return pos, nil
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

M.ActivateSceneDgo = function(self, dgoId)
	if not dgoId or dgoId ~= 0 then
		return
	end

	if self.activeSceneDgoIds[dgoId] then
		return
	end

	LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, true)

	if gLuaDataManager.isNetworkAvailable then
		slot2 = gClientToGameSceneDelegate

		slot2:AskActiveDynamicGo(dgoId, true, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
		end
	end

	self.activeSceneDgoIds[dgoId] = true
end

M.ReleaseAllActivatedDgos = function(self)
	local networkOk = gLuaDataManager.isNetworkAvailable

	for dgoId, isActive in pairs(self.activeSceneDgoIds) do
		if isActive then
			LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, false)

			if networkOk then
				slot7 = gClientToGameSceneDelegate

				slot7:AskActiveDynamicGo(dgoId, false, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
				end
			end
		end
	end

	self.activeSceneDgoIds = {}
end

M.ApplySceneById = function(self, sceneId)
	if not sceneId or sceneId ~= 0 then
		return
	end

	local cfg = self.GetSceneConfig(self, sceneId)

	if not cfg then
		return
	end

	self.currentSceneId = sceneId
	local dgoId = cfg.DgoId and cfg.DgoId <= 0 and cfg.DgoId or 0

	if dgoId <= 0 then
		self.ActivateSceneDgo(self, dgoId)
	end

	local centerPos, centerEuler = self:ParsePosAndRot(cfg.CenterPosAndRot)
	self.centerPos = centerPos or Vector3.New(0, 0, 0)
	self.centerEuler = centerEuler or Vector3.New(0, 0, 0)
	local cameraLocalPos, cameraLocalEuler = self:ParsePosAndRot(cfg.CameraPosAndRot)
	self.cameraPos, self.cameraEuler = self:ConvertLocalPoseToWorld(self.centerPos, self.centerEuler, cameraLocalPos, cameraLocalEuler)
	local carLocalPos, carLocalEuler = self:ParsePosAndRot(cfg.CarPosAndRot)
	self.carPos, self.carEuler = self:ConvertLocalPoseToWorld(self.centerPos, self.centerEuler, carLocalPos, carLocalEuler)
	local modelLocalPos, modelLocalEuler = self:ParsePosAndRot(cfg.ModelPosAndRot)
	self.modelPos, self.modelEuler = self:ConvertLocalPoseToWorld(self.centerPos, self.centerEuler, modelLocalPos, modelLocalEuler)

	if not self.modelPos then
		self.modelPos = self.centerPos
	end

	if not self.modelEuler then
		self.modelEuler = self.centerEuler
	end

	self.ApplySceneWeather(self, cfg)
end

M.ApplySceneCamera = function(self)
	local vCamera = self.vCamera

	if not vCamera then
		return
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return
	end

	if self.cameraPos then
		cameraTransform.position = self.cameraPos
	elseif self.centerPos then
		cameraTransform.position = self.centerPos
	end

	if self.cameraEuler then
		cameraTransform.eulerAngles = self.cameraEuler
	elseif self.centerEuler then
		cameraTransform.eulerAngles = self.centerEuler
	end
end

M.OffsetCameraPosition = function(self, dx, dy)
	local vCamera = self.vCamera

	if not vCamera then
		return
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return
	end

	local right = cameraTransform.right
	local up = cameraTransform.up
	local newPos = cameraTransform.position + right * dx + up * dy
	cameraTransform.position = self.ClampCameraPosition(self, newPos)
end

M.GetScreenCenterForward = function(self)
	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return nil
	end

	local sw = UnityEngine.Screen.width
	local sh = UnityEngine.Screen.height

	if not sw or sw > 0 or not sh or sh < 0 then
		return nil
	end

	local ray = cam.ScreenPointToRay(cam, Vector3.New(sw * 0.5, sh * 0.5, 0))

	return ray.direction
end

M.ZoomCameraAtScreenCenter = function(self, dz)
	local vCamera = self.vCamera

	if not vCamera then
		return
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return
	end

	local dir = self:GetScreenCenterForward() or cameraTransform.forward
	local newPos = cameraTransform.position + dir * dz
	cameraTransform.position = self:ClampCameraPosition(newPos)
end

M.GetCameraPosition = function(self)
	local vCamera = self.vCamera

	if not vCamera then
		return nil
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return nil
	end

	return cameraTransform.position
end

M.GetCameraEuler = function(self)
	local vCamera = self.vCamera

	if not vCamera then
		return nil
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return nil
	end

	return cameraTransform.eulerAngles
end

M.RotateCamera = function(self, deltaYaw, deltaPitch)
	local vCamera = self.vCamera

	if not vCamera then
		return
	end

	local cameraTransform = vCamera.transform.parent

	if not cameraTransform then
		return
	end

	local euler = cameraTransform.eulerAngles
	local baseEuler = self.cameraEuler or self.centerEuler or Vector3.zero
	local newYaw = euler.y + deltaYaw
	local newPitch = euler.x + deltaPitch

	if newPitch <= 180 then
		newPitch = newPitch - 360
	end

	local minYaw, maxYaw = gPlayerProfileSceneEditManager:GetCameraYawRange()
	local minPitch, maxPitch = gPlayerProfileSceneEditManager:GetCameraPitchRange()
	local baseYaw = baseEuler.y
	newYaw = Mathf.Clamp(newYaw, baseYaw + minYaw, baseYaw + maxYaw)
	local basePitch = baseEuler.x

	if basePitch <= 180 then
		basePitch = basePitch - 360
	end

	newPitch = Mathf.Clamp(newPitch, basePitch + minPitch, basePitch + maxPitch)
	cameraTransform.eulerAngles = Vector3.New(newPitch, newYaw, 0)
end

M.ClampCameraPosition = function(self, pos)
	local mgr = gPlayerProfileSceneEditManager

	if not mgr then
		return pos
	end

	local sceneCenter = self.centerPos or Vector3.zero
	local offset = mgr:GetCameraCenterOffset()
	local center = Vector3.New(sceneCenter.x + offset.x, sceneCenter.y + offset.y, sceneCenter.z + offset.z)
	local rangeX, rangeY, rangeZ = mgr:GetCameraRange()
	pos.x = Mathf.Clamp(pos.x, center.x - rangeX, center.x + rangeX)
	pos.y = Mathf.Clamp(pos.y, center.y - rangeY, center.y + rangeY)
	pos.z = Mathf.Clamp(pos.z, center.z - rangeZ, center.z + rangeZ)

	return pos
end

M.ApplySceneWeather = function(self, cfg)
	local weatherId = cfg and cfg.Weather or 0

	if weatherId and weatherId <= 0 then
		gCS.GuiUtils.SetXuWeiWeatherState(true, weatherId)

		self.weatherId = weatherId

		return
	end

	self.ClearSceneWeather(self)
end

M.ClearSceneWeather = function(self)
	if self.weatherId and self.weatherId <= 0 then
		self.weatherId = 0
	end

	gCS.GuiUtils.SetXuWeiWeatherState(false)
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
end

M.OnDynamicGoLoaded = function(self, _, dg)
	local go = dg.gameObject

	if go and not gCS.LuaUtils.IsNull(go) then
		gCS.LuaUtils.ForceAddCustomProbeByGo(go)
	end
end

M._GetActionClipsMap = function(self)
	if self.actionClipsMap then
		return self.actionClipsMap
	end

	local map = {}

	for i = 0, ImageActionListConfig.count - 1 do
		local cfg = ImageActionListConfig.LoadAt(i)
		local clips = cfg and cfg.ActionClips
		local firstClip = clips and #clips <= 0 and clips[1] or nil
		local actionKey = firstClip and firstClip.ActionKey or 0

		if actionKey <= 0 then
			map[actionKey] = clips
		end
	end

	self.actionClipsMap = map

	return map
end

M.BuildMontageActionArrays = function(self, actionClips)
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

M.PlayActionOnUnit = function(self, unit, actionType, actionGroup)
	if not unit or not actionType or actionType < 0 then
		return false
	end

	if actionGroup and actionGroup <= 0 then
		unit.State.ActionGroupId = actionGroup
	end

	local clips = self._GetActionClipsMap(self)[actionType]
	local actionKeys, blendIns, loopFlags, playRates, startTimes, endTimes, firstActionKey = self.BuildMontageActionArrays(self, clips)

	if not actionKeys then
		print_error_without_stack("PlayerProfileSceneManager PlayActionOnUnit InvalidActionClips", actionType)

		return false
	end

	local ok = gCS.LogicStateMachineManager.SendGameplayMontageActions(unit, SCENARIO_MONTAGE_SIGNAL_ID, actionKeys, blendIns, loopFlags, playRates, startTimes, endTimes, SCENARIO_MONTAGE_BLEND_OUT)

	if not ok then
		print_error_without_stack("PlayerProfileSceneManager PlayActionOnUnit PlayMontageFailed", firstActionKey)
	end

	return ok
end

M.LoadCharacterUnit = function(self, spiritId, pos, euler, fashionWearInfo, callback)
	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	if not agentConfig then
		return
	end

	local modelId = agentConfig.GeneralModelId
	local LayerConstants = LX6.Constants.LayerConstants
	local UnitModelManager = LX6.Units.UnitModelManager
	local otherData = {
		["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
		["  \\xb1\\xf2- v ,\\xa0=;ى\\x94?\\xac\\x99\\xc0\\x9a"] = false,
		SubType = spiritId,
		cardId = spiritId,
		fashionWearInfo = fashionWearInfo
	}
	slot12 = gUIUtils

	slot12:LoadModel("", modelId, nil, , , , function (unit)
		UnitModelManager.SetRenderLayer(unit, LayerConstants.Npc)

		unit.PlayerObj.transform.localScale = Vector3.one
		unit.PlayerObj.transform.localEulerAngles = euler
		unit.PlayerObj.transform.position = pos

		gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)
		gCS.LuaUtils.AddLocalUnitStateMachineModule(unit, LTConfig.AgentConfig.AnimGraphType.Npc_Other)

		if callback then
			callback(unit)
		end
	end, nil, otherData)
end

M._BuildFashionWearInfoFromSpirit = function(self, spirit)
	local fashionInfo = {
		WearFashionInfoList = {},
		WearFashionEditInfoList = {}
	}
	local wearInfo = spirit.CustomFashionInfo or spirit.FashionInfo

	if not wearInfo then
		return fashionInfo
	end

	local wearList = wearInfo.WearFashionInfoList

	if not wearList then
		return fashionInfo
	end

	local count = wearList.Count or #wearList

	for i = 1, count do
		table.insert(fashionInfo.WearFashionInfoList, {
			FashionId = wearList[i].FashionId
		})
	end

	return fashionInfo
end

M.DecodeStickerSaveData = function(self, stickerData)
	if not stickerData then
		return nil
	end

	local stickerId = stickerData.StickerId or 0

	if stickerId ~= 0 then
		return nil
	end

	local cfg = ImageSceneStickerConfig.GetConfig(stickerId)

	if not cfg then
		return nil
	end

	local meshPath = cfg.MeshPath

	if not meshPath or meshPath ~= "" then
		return nil
	end

	local scale = stickerData.ScaleX or 0

	if scale < 0 then
		scale = nil
	end

	local rotationOffset = nil
	local rot = stickerData.Rotation

	if rot then
		local x = rot.x or rot.X or 0
		local y = rot.y or rot.Y or 0
		local z = rot.z or rot.Z or 0

		if x == 0 or y == 0 or z == 0 then
			rotationOffset = Vector3.New(x, y, z)
		end
	end

	local mode = stickerData.Mode ~= STICKER_MODE_SCREEN_UI and STICKER_MODE_SCREEN_UI or STICKER_MODE_WORLD

	return meshPath, scale, rotationOffset, mode
end

M.ApplyStickerScreenUIMode = function(self, billboard, worldPos)
	if not billboard or gCS.LuaUtils.IsNull(billboard) then
		return
	end

	local offsetX, offsetY, distance = self.CalcStickerScreenUIParams(self, worldPos)

	if offsetX then
		billboard.offsetX = offsetX
		billboard.offsetY = offsetY
		billboard.distanceToCamera = distance
	end

	billboard.mode = STICKER_MODE_SCREEN_UI

	billboard.SetRenderOnTop(billboard, true)
end

M.CalcStickerScreenUIParams = function(self, worldPos)
	if not worldPos then
		return nil
	end

	local cam = gCS.CameraDataMgr.MainCamera

	if not cam or gCS.LuaUtils.IsNull(cam) then
		return nil
	end

	local samplePos = worldPos
	local vCamera = self.vCamera
	local cameraTransform = vCamera and vCamera.transform.parent

	if cameraTransform then
		local camT = cam.transform
		local relative = Quaternion.Inverse(cameraTransform.rotation) * (worldPos - cameraTransform.position)
		samplePos = camT.position + camT.rotation * relative
	end

	local sp = cam.WorldToScreenPoint(cam, samplePos)

	if sp.z < 0 then
		return nil
	end

	local screenW = UnityEngine.Screen.width
	local screenH = UnityEngine.Screen.height

	if screenW > 0 or screenH < 0 then
		return nil
	end

	return sp.x / screenW - 0.5, sp.y / screenH - 0.5, sp.z
end

M.LoadScenarioSticker = function(self, stickerData, worldPos, onDone)
	local finished = false

	local finish = function()
		if finished then
			return
		end

		finished = true

		if onDone then
			onDone()
		end
	end

	local meshPath, scale, rotationOffset, mode = self.DecodeStickerSaveData(self, stickerData)

	if not meshPath then
		finish()

		return
	end

	self.scenarioStickerToken = self.scenarioStickerToken or 0
	local currentToken = self.scenarioStickerToken

	gResourceManager:LoadAssetWithCallBack(meshPath, typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == (self.scenarioStickerToken or 0) then
			gResourceManager:UnloadAssetLoadOp(loadOp)
			finish()

			return
		end

		if not loadOp or not loadOp.asset then
			finish()

			return
		end

		local go = GameObject.Instantiate(loadOp.asset)

		if not go or gCS.LuaUtils.IsNull(go) then
			gResourceManager:UnloadAssetLoadOp(loadOp)
			finish()

			return
		end

		go.transform.position = worldPos
		go.transform.eulerAngles = Vector3.zero

		if scale then
			go.transform.localScale = Vector3.New(scale, scale, scale)
		end

		go:SetLayerRecursively(LayerConstants._Decoration)
		go:AddComponent(typeof("LX6.Utils.BillboardFaceCamera"))

		local billboard = go:GetComponent(typeof("LX6.Utils.BillboardFaceCamera"))

		if billboard and rotationOffset then
			billboard.rotationOffset = rotationOffset
			local cam = gCS.CameraDataMgr.MainCamera

			if cam and not gCS.LuaUtils.IsNull(cam) then
				go.transform.rotation = cam.transform.rotation * Quaternion.Euler(rotationOffset)
			end
		end

		if billboard and mode ~= STICKER_MODE_SCREEN_UI then
			self:ApplyStickerScreenUIMode(billboard, worldPos)
		end

		self.scenarioStickers = self.scenarioStickers or {}

		table.insert(self.scenarioStickers, {
			gameObject = go,
			loadOp = loadOp
		})
		finish()
	end)
end

M.ClearScenarioStickers = function(self)
	if self.scenarioStickers then
		for _, entry in ipairs(self.scenarioStickers) do
			if entry.gameObject and not gCS.LuaUtils.IsNull(entry.gameObject) then
				GameObject.Destroy(entry.gameObject)
			end

			if entry.loadOp then
				gResourceManager:UnloadAssetLoadOp(entry.loadOp)
			end
		end

		self.scenarioStickers = nil
	end

	self.scenarioStickerToken = (self.scenarioStickerToken or 0) + 1
end

M.LoadScenarioFromData = function(self, publicInfo, onComplete)
	if not publicInfo then
		if onComplete then
			onComplete()
		end

		return
	end

	self:ClearScenarioModels()

	local pending = 0
	local done = false

	local checkDone = function()
		pending = pending - 1

		if pending < 0 and not done and onComplete then
			done = true

			onComplete()
		end
	end

	local sceneId = publicInfo.SceneId or 0

	if sceneId <= 0 then
		self.ApplySceneById(self, sceneId)
	end

	local centerPos = self.centerPos or Vector3.zero
	local centerEuler = self.centerEuler or Vector3.zero
	local centerQuat = Quaternion.Euler(centerEuler)

	local localToWorld = function(localPos)
		if not localPos then
			return centerPos
		end

		local lp = Vector3.New(localPos.x or localPos.X or 0, localPos.y or localPos.Y or 0, localPos.z or localPos.Z or 0)

		return centerPos + centerQuat * lp
	end

	local localRotToWorld = function(localRot)
		if not localRot then
			return centerEuler
		end

		local lr = Vector3.New(localRot.x or localRot.X or 0, localRot.y or localRot.Y or 0, localRot.z or localRot.Z or 0)
		local worldQuat = centerQuat * Quaternion.Euler(lr)

		return worldQuat.eulerAngles
	end

	if publicInfo.Position then
		local camLocal = Vector3.New(publicInfo.Position.x or publicInfo.Position.X or 0, publicInfo.Position.y or publicInfo.Position.Y or 0, publicInfo.Position.z or publicInfo.Position.Z or 0)
		self.cameraPos = centerPos + centerQuat * camLocal
	end

	if publicInfo.Rotation then
		local camRotLocal = Vector3.New(publicInfo.Rotation.x or publicInfo.Rotation.X or 0, publicInfo.Rotation.y or publicInfo.Rotation.Y or 0, publicInfo.Rotation.z or publicInfo.Rotation.Z or 0)
		local camWorldQuat = centerQuat * Quaternion.Euler(camRotLocal)
		self.cameraEuler = camWorldQuat.eulerAngles
	end

	self.ApplySceneCamera(self)

	if publicInfo.Spirits then
		local spiritCount = publicInfo.Spirits.Count or #publicInfo.Spirits

		for i = 1, spiritCount do
			local spirit = publicInfo.Spirits[i]

			if spirit and spirit.SpiritId and spirit.SpiritId <= 0 then
				local pos = localToWorld(spirit.Position)
				local rot = localRotToWorld(spirit.Rotation)
				local fashionWearInfo = self:_BuildFashionWearInfoFromSpirit(spirit)
				local actionType = spirit.ActionType or 0
				local actionGroup = spirit.ActionGroup or 0
				local expressionId = spirit.Expression or 0
				pending = pending + 1

				self:LoadCharacterUnit(spirit.SpiritId, pos, rot, fashionWearInfo, function (unit)
					self.scenarioUnits = self.scenarioUnits or {}

					table.insert(self.scenarioUnits, unit)

					if actionType <= 0 then
						self:PlayActionOnUnit(unit, actionType, actionGroup)
					end

					if expressionId <= 0 and unit.ModelSlot and unit.ModelSlot.ExpressionController then
						unit.ModelSlot.ExpressionController:PlaySpecialExpression(expressionId, 0, true, 9999)
					end

					checkDone()
				end)
			end
		end
	end

	if publicInfo.Vehicles then
		local vehicleCount = publicInfo.Vehicles.Count or #publicInfo.Vehicles

		for i = 1, vehicleCount do
			local vehicle = publicInfo.Vehicles[i]

			if vehicle and vehicle.VehicleId and vehicle.VehicleId <= 0 then
				local pos = localToWorld(vehicle.Position)
				local rot = localRotToWorld(vehicle.Rotation)
				local DriveUtils = LX6.Drive.DriveUtils
				local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
				local vehicleDetail = vehicle.VehicleInfo or self:GetOwnedVehicleDetail(vehicle.VehicleId)
				local spawnParam = SpawnVehicleParam.New()
				spawnParam.position = pos
				spawnParam.facing = rot.y
				spawnParam.forceDummy = true
				spawnParam.mainLightOn = true
				spawnParam.disableCollision = false

				spawnParam.beforeLoadAction = function(vehicle)
					if vehicleDetail then
						gPlayerProfileSceneManager:ApplyPlayerVehicleParts(vehicle, vehicleDetail)
					end
				end

				spawnParam.afterLoadAction = function(v)
					if v and v.gameObject and not gCS.LuaUtils.IsNull(v.gameObject) then
						v.gameObject.transform.eulerAngles = rot
					end
				end

				local v = DriveUtils.SpawnVehicleClient(vehicle.VehicleId, spawnParam)

				if v then
					self.scenarioVehicles = self.scenarioVehicles or {}

					table.insert(self.scenarioVehicles, v)
				end
			end
		end
	end

	if publicInfo.Stickers then
		local stickerCount = publicInfo.Stickers.Count or #publicInfo.Stickers

		for i = 1, stickerCount do
			local sticker = publicInfo.Stickers[i]

			if sticker and sticker.StickerId and sticker.StickerId <= 0 then
				pending = pending + 1

				self.LoadScenarioSticker(self, sticker, localToWorld(sticker.Position), checkDone)
			end
		end
	end

	local filterId = publicInfo.FilterId or 0
	local filterStrength = publicInfo.FilterStrength or 100

	if filterId <= 0 then
		FilterEffectManager.AddFilterExclusive(filterId)
		PhotoUtils.SetCameraParam("CameraParamFilterIntensity", filterStrength)
	else
		FilterEffectManager.RemoveAllFilter()
	end

	if pending < 0 and not done and onComplete then
		done = true

		onComplete()
	end
end

M.GetDefaultSpiritId = function(self)
	local sex = gPlayerManager.infoLogin.bindData.sexType

	if sex ~= UX.Game.SexType.Female then
		return LTConfig.FightSpiritConfig.DefaultFemale
	end

	return LTConfig.FightSpiritConfig.DefaultMale
end

M.GetDefaultAction = function(self)
	if ImageActionListConfig.count ~= 0 then
		return 0, 0
	end

	local cfg = ImageActionListConfig.LoadAt(0)
	local clips = cfg and cfg.ActionClips
	local firstClip = clips and #clips <= 0 and clips[1] or nil

	return firstClip and firstClip.ActionKey or 0, 0
end

M.LoadDefaultScenario = function(self, spiritId, slotIndex, onComplete)
	self.ClearScenarioModels(self)

	local defaultSceneId = ImageSceneiconConfig.DefaultScene

	self.ApplySceneById(self, defaultSceneId)
	self.ApplySceneCamera(self)

	local pending = 0
	local done = false

	local checkDone = function()
		pending = pending - 1

		if pending < 0 and not done and onComplete then
			done = true

			onComplete()
		end
	end

	if spiritId and spiritId <= 0 then
		local pos = self.modelPos or self.centerPos or Vector3.zero
		local rot = self.modelEuler or self.centerEuler or Vector3.zero
		local defaultActionId, defaultActionGroup = self:GetDefaultAction()
		pending = pending + 1

		self:LoadCharacterUnit(spiritId, pos, rot, nil, function (unit)
			self.scenarioUnits = self.scenarioUnits or {}

			table.insert(self.scenarioUnits, unit)

			if defaultActionId <= 0 then
				self:PlayActionOnUnit(unit, defaultActionId, defaultActionGroup)
			end

			checkDone()
		end)
	end

	if slotIndex ~= gPlayerProfileSceneEditManager.RANKING_SLOT then
		local defaultCarId = LTConfig.ImageConfig.ScenarioDefaultCar or 81002007

		if defaultCarId <= 0 then
			local carPos = self.carPos or self.centerPos or Vector3.zero
			local carEuler = self.carEuler or self.centerEuler or Vector3.zero
			local DriveUtils = LX6.Drive.DriveUtils
			local SpawnVehicleParam = LX6.Drive.SpawnVehicleParam
			local spawnParam = SpawnVehicleParam.New()
			spawnParam.position = carPos
			spawnParam.facing = carEuler.y
			spawnParam.forceDummy = true
			spawnParam.mainLightOn = true
			spawnParam.disableCollision = false

			spawnParam.afterLoadAction = function(v)
				if v and v.gameObject and not gCS.LuaUtils.IsNull(v.gameObject) then
					v.gameObject.transform.eulerAngles = carEuler
				end
			end

			local v = DriveUtils.SpawnVehicleClient(defaultCarId, spawnParam)

			if v then
				self.scenarioVehicles = self.scenarioVehicles or {}

				table.insert(self.scenarioVehicles, v)
			end
		end
	end

	if pending < 0 and not done and onComplete then
		done = true

		onComplete()
	end
end

M.ClearScenarioModels = function(self)
	if self.scenarioUnits then
		for _, unit in ipairs(self.scenarioUnits) do
			if unit and unit.PlayerObj and type(unit.PlayerObj) == "string" and not gCS.LuaUtils.IsNull(unit.PlayerObj) then
				unit.DestroyUnit(unit, true)
			end
		end

		self.scenarioUnits = nil
	end

	if self.scenarioVehicles then
		local DriveUtils = LX6.Drive.DriveUtils

		for _, vehicle in ipairs(self.scenarioVehicles) do
			if vehicle then
				DriveUtils.DestroyVehicleClient(vehicle.uid)
			end
		end

		self.scenarioVehicles = nil
	end

	self.ClearScenarioStickers(self)
	FilterEffectManager.RemoveAllFilter()
	PhotoUtils.SetCameraParam("CameraParamFilterIntensity", 100)
end

M.ApplyPlayerVehicleParts = function(self, vehicle, vehicleDetail)
	if not vehicle or not vehicleDetail then
		return
	end

	local partMap = {}
	local suitId = vehicleDetail.SuitId or 0

	if suitId == 0 then
		local suitCfg = VehiclePartSuitConfig.GetConfig(suitId)

		if suitCfg and suitCfg.Suit then
			for i = 1, #suitCfg.Suit do
				local partId = suitCfg.Suit[i]

				if partId and partId == 0 then
					local cfg = VehiclePartConfig.GetConfig(partId)

					if cfg then
						partMap[cfg.PartTag] = partId
					end
				end
			end
		end
	end

	local parts = vehicleDetail.Parts

	if parts and parts.Count then
		for i = 1, parts.Count do
			local part = parts[i]

			if part then
				local partId = part.ConfigId or part.VehiclePartId or 0
				local partTag = part.Type or part.VehiclePartTag or 0

				if partId ~= 0 then
					if partTag == 0 then
						partMap[partTag] = nil
					end
				else
					local cfg = VehiclePartConfig.GetConfig(partId)

					if cfg then
						partMap[cfg.PartTag] = partId
					end
				end
			end
		end
	end

	local partIds = {}

	for _, partId in pairs(partMap) do
		if partId == 0 then
			partIds[#partIds + 1] = partId
		end
	end

	if #partIds <= 0 then
		vehicle.InitClientPartsData(vehicle, partIds)
	end
end

M.GetOwnedVehicleDetail = function(self, vehicleId)
	if not vehicleId or vehicleId ~= 0 then
		return nil
	end

	local list = gApplyCarManager and gApplyCarManager.UnlockedVehicles

	if not list or not list.Count then
		return nil
	end

	for i = 1, list.Count do
		if list[i].Id ~= vehicleId then
			return list[i]
		end
	end

	return nil
end

M.ReleaseScene = function(self)
	self.ClearScenarioModels(self)
	self.StopListenDynamicGoLoaded(self)
	self.ReleaseAllActivatedDgos(self)
	self.ClearSceneWeather(self)

	self.currentSceneId = nil
	self.centerPos = nil
	self.centerEuler = nil
	self.cameraPos = nil
	self.cameraEuler = nil
end

if gPlayerProfileSceneManager then
	dofile("LX6/Manager/PlayerProfile/PlayerProfileSceneEditManager")
	dofile("LX6/Manager/PlayerProfile/PlayerProfileSceneOperationManager")
end

gPlayerProfileSceneManager = gPlayerProfileSceneManager or C_PlayerProfileSceneManager.new()
