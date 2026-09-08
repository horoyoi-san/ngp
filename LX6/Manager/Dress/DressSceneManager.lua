-- Original chunk: @Lua\LuaFiles\LX6\Manager\Dress\DressSceneManager.lua
-- Decompiled from: 00536_DressSceneManager.lua_bf3942c75944.luajit

local FashionSceneConfig = LTConfig.FashionSceneConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local WeaponSkinDefaultSkinConfig = LTConfig.WeaponSkinDefaultSkinConfig
local LayerConstants = LX6.Constants.LayerConstants
local UnitModelManager = LX6.Units.UnitModelManager
C_DressSceneManager = DefClass("C_DressSceneManager", C_DressSceneManager)
local M = C_DressSceneManager
M.LoadingType = {
	["+M\\x90\\x9e\\x8cO"] = 2,
	["`Om{O*"] = 1,
	["T-s^"] = 0
}
M.TabType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["1I\\x9a\\x8b\\x96Q"] = 2,
	["\\xff\\xda+\\xff"] = 1
}
M.DEFAULT_CHARACTER_POS = Vector3.New(0, -100, 0)
M.DEFAULT_CHARACTER_EULER = Vector3.New(0, 180, 0)
M.DEFAULT_DRESS_DGO = 0
M.DEFAULT_SCENE_PATH = "scene"
M.DEFAULT_CAMERA_POS = Vector3.New(10, -98, -25)
M.DEFAULT_IK_TYPE = "NPC_ground_idle"
M.DEFAULT_WEAPON_POS = Vector3.New(0, -100, 0)
M.DEFAULT_WEAPON_EULER = Vector3.New(0, 180, 0)
M.WEAPON_VERTICAL_OFFSET = 0.6
M.goTypeEnum = {
	["@Om{O*"] = 0,
	["M\\x90\\x9e\\x8cO"] = 1
}

M.ctor = function(self)
	self.currentModelUnit = nil
	self.loadedSpiritId = nil
	self.dressCenterPos = nil
	self.dressCenterEuler = nil
	self.dressModelPos = nil
	self.dressModelEuler = nil
	self.loadingToken = 0
	self.currentLoadingType = self.LoadingType.None
	self.currentSceneId = nil
	self.dressSceneDgoId = 0
	self.activeSceneDgoIds = {}
	self.dressWeatherId = 0
	self.keepSceneHandleId = nil
	self.dynamicLightGo = nil
	self.dynamicLightOp = nil
	self.currentWeaponGo = nil
	self.weaponParent = nil
	self.currentWeaponTab2 = nil
	self.weaponLoadOp = nil
	self.loadedWeaponId = nil
	self.pendingWeaponId = nil
	self.pendingWeaponCallbacks = nil
end

M._GetFashionSceneConfigById = function(self, sceneId)
	return FashionSceneConfig.GetConfig(sceneId)
end

M._GetScenePathFromCfg = function(self, cfg)
	return cfg and cfg.Path and cfg.Path == "" and cfg.Path or self.DEFAULT_SCENE_PATH
end

M._ParsePosAndRot = function(self, data)
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

M._ConvertLocalPoseToWorld = function(self, centerPos, centerEuler, localPos, localEuler)
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

M._GetCharacterEuler = function(self)
	return self.DEFAULT_CHARACTER_EULER
end

M._ResolveTransformData = function(self, transformData, params, goType)
	goType = goType or self.goTypeEnum.character
	local defaultPos, defaultEuler = nil

	if goType ~= self.goTypeEnum.weapon then
		defaultPos = self.DEFAULT_WEAPON_POS
		defaultEuler = self.DEFAULT_WEAPON_EULER
	else
		defaultPos = self.DEFAULT_CHARACTER_POS
		defaultEuler = self:_GetCharacterEuler()
	end

	transformData = transformData or self:GetModelTransformData()

	if not transformData then
		if goType ~= self.goTypeEnum.weapon and params and params.tab2 then
			defaultEuler = self:_ApplyWeaponDefaultRotation(defaultEuler, params.tab2)
		end

		return defaultPos, defaultEuler
	end

	local pos = transformData.position or defaultPos

	if goType ~= self.goTypeEnum.weapon then
		pos = Vector3.New(pos.x, pos.y + self.WEAPON_VERTICAL_OFFSET, pos.z)
	end

	local euler = transformData.eulerAngles or transformData.euler or defaultEuler

	if goType ~= self.goTypeEnum.weapon and params and params.tab2 then
		euler = self:_ApplyWeaponDefaultRotation(euler, params.tab2)
	end

	return pos, euler
end

M._ApplyWeaponDefaultRotation = function(self, baseEuler, tab2)
	for i = 0, WeaponSkinDefaultSkinConfig.count - 1 do
		local skinCfg = WeaponSkinDefaultSkinConfig.LoadAt(i)

		if skinCfg and skinCfg.Tab2 ~= tab2 and skinCfg.Rotation then
			return Vector3.New(baseEuler.x + skinCfg.Rotation.X, baseEuler.y + skinCfg.Rotation.Y, baseEuler.z + skinCfg.Rotation.Z)
		end
	end

	return baseEuler
end

M._BuildModelTransformBySceneCfg = function(self, cfg)
	self.dressCenterPos = nil
	self.dressCenterEuler = nil
	self.dressModelPos = nil
	self.dressModelEuler = nil

	if not cfg then
		return
	end

	local centerPos, centerEuler = self:_ParsePosAndRot(cfg.CenterPosAndRot)
	self.dressCenterPos = centerPos or Vector3.New(0, 0, 0)
	self.dressCenterEuler = centerEuler or Vector3.New(0, 0, 0)
	local modelLocalPos, modelLocalEuler = self:_ParsePosAndRot(cfg.ModelPosAndRot)
	local modelPos, modelEuler = self:_ConvertLocalPoseToWorld(self.dressCenterPos, self.dressCenterEuler, modelLocalPos, modelLocalEuler)
	self.dressModelPos = modelPos
	self.dressModelEuler = modelEuler
end

M._ApplyDressSceneDgo = function(self, cfg)
	local dgoId = nil
	dgoId = (cfg or self.DEFAULT_DRESS_DGO) and (cfg.DgoId and cfg.DgoId <= 0 and cfg.DgoId or 0)

	if dgoId < 0 then
		self.dressSceneDgoId = 0

		return
	end

	if not self.activeSceneDgoIds[dgoId] then
		LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, true)

		gClientToGameSceneDelegate:AskActiveDynamicGo(dgoId, true, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
		end

		self.activeSceneDgoIds[dgoId] = true
	end

	self.dressSceneDgoId = dgoId
end

M._ReleaseAllActivatedDgos = function(self)
	for dgoId, isActive in pairs(self.activeSceneDgoIds) do
		if isActive then
			LX6.Item.DynamicGoManager.SetDynamicGoActiveFromClient(dgoId, false)

			gClientToGameSceneDelegate:AskActiveDynamicGo(dgoId, false, UX.Game.DynamicGoChangeReason.Shop).Callback = function (err)
			end
		end
	end

	self.activeSceneDgoIds = {}
	self.dressSceneDgoId = 0
end

M._ApplyDressSceneWeather = function(self, cfg)
	local weatherId = cfg and cfg.Weather or 0

	if weatherId and weatherId <= 0 then
		gCS.GuiUtils.SetXuWeiWeatherState(true, weatherId)

		self.dressWeatherId = weatherId

		return
	end

	self:_ClearDressSceneWeather()
end

M._ClearDressSceneWeather = function(self)
	if self.dressWeatherId and self.dressWeatherId <= 0 then
		self.dressWeatherId = 0
	end

	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

M._SyncUnitPosition = function(self)
	if not self.currentModelUnit or not self.currentModelUnit.PlayerObj then
		return
	end

	gDressManager:KeepBoneCloth(self.currentModelUnit, true, 1)

	local pos, euler = self:_ResolveTransformData(nil)
	self.currentModelUnit.PlayerObj.transform.position = pos
	self.currentModelUnit.PlayerObj.transform.localEulerAngles = euler

	gCS.LuaUtils.ForceSetPlayerTransform(self.currentModelUnit.PlayerObj.transform)
end

M._SyncWeaponPosition = function(self)
	if not self.weaponParent or gCS.LuaUtils.IsNull(self.weaponParent) then
		return
	end

	local pos, _ = self:_ResolveTransformData(nil, , self.goTypeEnum.weapon)
	self.weaponParent.transform.position = pos

	gCS.LuaUtils.ForceSetPlayerTransform(self.weaponParent.transform)
end

M._LoadDynamicLight = function(self, sceneId)
	self:_ClearDynamicLight()

	local cfg = self:_GetFashionSceneConfigById(sceneId)

	if not cfg then
		print_error("@hzliuyibing 场景配置找不到！sceneId = ", sceneId)

		return
	end

	local path = cfg.DynamicLight

	if not path then
		return
	end

	local centerPos = self.dressCenterPos or Vector3.zero
	local centerEuler = self.dressCenterEuler or Vector3.zero
	self.dynamicLightOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset then
			return
		end

		local go = UnityEngine.GameObject.Instantiate(loadOp.asset)
		go.transform.position = centerPos
		go.transform.eulerAngles = centerEuler
		self.dynamicLightGo = go
	end)
end

M._ClearDynamicLight = function(self)
	if self.dynamicLightGo and not gCS.LuaUtils.IsNull(self.dynamicLightGo) then
		GameObject.Destroy(self.dynamicLightGo)
	end

	self.dynamicLightGo = nil

	if self.dynamicLightOp then
		gResourceManager:UnloadAssetLoadOp(self.dynamicLightOp)

		self.dynamicLightOp = nil
	end
end

M._GetSpiritFashionInfo = function(self, spiritId)
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

M.ApplyDressSceneById = function(self, sceneId, defaultSceneId)
	sceneId = sceneId or defaultSceneId or 1
	local cfg = self:_GetFashionSceneConfigById(sceneId)
	self.currentSceneId = sceneId

	self:_ApplyDressSceneDgo(cfg)
	self:_BuildModelTransformBySceneCfg(cfg)
	self:_SyncUnitPosition()
	self:_SyncWeaponPosition()

	return self:_GetScenePathFromCfg(cfg)
end

M.EnterDressScene = function(self, spiritId, sceneId, onLoadComplete)
	self:SetKeepScene(true)
	self:ApplyDressSceneById(sceneId)
	self:_LoadDynamicLight(sceneId)
	self:_EnsureWeaponParent()

	local weatherCb = function()
		local cfg = self:_GetFashionSceneConfigById(sceneId)

		self:_ApplyDressSceneWeather(cfg)
	end

	local fashionInfo = self:_GetSpiritFashionInfo(spiritId)

	self:LoadCharacterModel(spiritId, fashionInfo, nil, function (unit)
		if onLoadComplete then
			onLoadComplete(unit, weatherCb)
		end

		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.FashionPortal, self.currentModelUnit)
	end)
	gCS.LuaUtils.SetBoneClothGlobalWindEnabled(false)
end

M.ExitDressScene = function(self)
	self:ClearCharacterModel()
	self:ClearWeaponModel()
	self:_DestroyWeaponParent()
	self:_ClearDynamicLight()
	self:_ReleaseDressSceneConfig()
	self:SetKeepScene(false)
	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.FashionPortal, self.currentModelUnit)
	gCS.LuaUtils.SetBoneClothGlobalWindEnabled(true)
end

M.CycleDressScene = function(self)
	local totalCount = FashionSceneConfig.count

	if totalCount < 0 then
		return
	end

	local currentId = self.currentSceneId or 1
	local nextId = nil
	local foundCurrent = false

	for i = 0, totalCount - 1 do
		local cfg = FashionSceneConfig.LoadAt(i)

		if cfg then
			if foundCurrent then
				nextId = cfg.Id

				break
			end

			if cfg.Id ~= currentId then
				foundCurrent = true
			end
		end
	end

	if not nextId then
		local firstCfg = FashionSceneConfig.LoadAt(0)
		nextId = firstCfg and firstCfg.Id or 1
	end

	self:ApplyDressSceneById(nextId)
	self:_LoadDynamicLight(nextId)
end

M.GetNextSceneName = function(self)
	local totalCount = FashionSceneConfig.count

	if totalCount < 0 then
		return ""
	end

	local currentId = self.currentSceneId or 1
	local nextId = nil
	local foundCurrent = false

	for i = 0, totalCount - 1 do
		local cfg = FashionSceneConfig.LoadAt(i)

		if cfg then
			if foundCurrent then
				nextId = cfg.Id

				break
			end

			if cfg.Id ~= currentId then
				foundCurrent = true
			end
		end
	end

	if not nextId then
		local firstCfg = FashionSceneConfig.LoadAt(0)
		nextId = firstCfg and firstCfg.Id or 1
	end

	local nextCfg = FashionSceneConfig.GetConfig(nextId)

	return nextCfg and nextCfg.Name or ""
end

M._ReleaseDressSceneConfig = function(self)
	self:_ReleaseAllActivatedDgos()
	self:_ClearDressSceneWeather()

	self.currentSceneId = nil
	self.dressCenterPos = nil
	self.dressCenterEuler = nil
	self.dressModelPos = nil
	self.dressModelEuler = nil
end

M.SetKeepScene = function(self, value)
	if value then
		gCS.PanelManager.Instance.AddSceneTargetUIControl(gBanId.FASHION_SCENE)
	else
		gCS.PanelManager.Instance.RemoveSceneTargetUIControl(gBanId.FASHION_SCENE)
	end

	gCS.LuaUtils.SetShadowRenderDataUIMode(value)
end

M._GetCurrentLookAtIKType = function(self)
	return self.DEFAULT_IK_TYPE
end

M.GetCurrentModelRoot = function(self)
	if self.currentModelUnit and self.currentModelUnit.PlayerObj then
		return self.currentModelUnit.PlayerObj.transform
	end

	return nil
end

M.DisableDressSceneLookAt = function(self)
	local unit = self.currentModelUnit

	if not unit then
		return
	end

	gCS.ShowcaseLookAtIkModule.StopShowcaseLookAt(unit)
end

M._ApplyDressNamePrefix = function(self, go)
	if not go then
		return
	end

	local oldName = go.name

	if string.is_null_or_empty(oldName) then
		oldName = "model"
	end

	if string.sub(oldName, 1, 6) ~= "dress_" then
		return
	end

	go.name = "dress_" .. oldName
end

M._ApplyWeaponNamePrefix = function(self, go)
	if not go then
		return
	end

	local oldName = go.name

	if string.is_null_or_empty(oldName) then
		oldName = "weapon"
	end

	if string.sub(oldName, 1, 7) ~= "weapon_" then
		return
	end

	go.name = "weapon_" .. oldName
end

M.GetModelTransformData = function(self)
	if not self.dressModelPos and not self.dressModelEuler then
		return nil
	end

	return {
		position = self.dressModelPos,
		eulerAngles = self.dressModelEuler
	}
end

M.LoadCharacterModel = function(self, spiritId, fashionInfo, transformData, onLoadComplete)
	if not spiritId or spiritId ~= 0 then
		self:ClearCharacterModel()

		return
	end

	if self.loadedSpiritId ~= spiritId and self.currentModelUnit then
		local unit = self.currentModelUnit

		gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)
		gCS.LuaUtils.ForceSetPlayerPid(unit.Pid)

		if onLoadComplete then
			onLoadComplete(unit)
		end

		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	if not agentConfig then
		return
	end

	self:ClearCharacterModel()

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Character
	self.loadedSpiritId = spiritId

	print_debug("DressSceneManager LoadCharacterModel Begin spiritId:" .. tostring(spiritId) .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

	local characterPos, characterEuler = self:_ResolveTransformData(transformData)
	local modelId = agentConfig.GeneralModelId
	local otherData = {
		["``\\xa9e^\\xbb\\xf6BCiKe"] = false,
		["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
		["#\\xe0K%\\xde;\\xa4N\\xb4F\\x99\\xb2"] = 1,
		["g\\xe5)\\xef;.\\xdad2\\xf3J\\x9fK\\xc9\\xe8"] = true,
		["  \\xb1\\xf2- v ,\\xa0=;ى\\x94?\\xac\\x99\\xc0\\x9a"] = false,
		SubType = spiritId,
		cardId = spiritId,
		fashionWearInfo = fashionInfo
	}

	local cb = function(unit)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Character or self.loadedSpiritId == spiritId then
			if unit then
				unit:DestroyUnit(true)
			end

			return
		end

		print_debug("DressSceneManager LoadCharacterModel End spiritId:" .. spiritId .. " framecount:" .. Time.frameCount .. " time:" .. Time.time)

		self.currentModelUnit = unit

		self:_ApplyDressNamePrefix(unit.PlayerObj)
		UnitModelManager.SetRenderLayer(unit, LayerConstants.Player)
		UnitModelManager.SetShadow(unit, true)

		unit.PlayerObj.transform.localScale = Vector3.one
		unit.PlayerObj.transform.localEulerAngles = characterEuler
		unit.PlayerObj.transform.position = characterPos

		gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
		gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)
		gCS.LuaUtils.ForceSetPlayerPid(unit.Pid)
		self:_ApplyHiddenParts(spiritId, unit)

		if onLoadComplete then
			onLoadComplete(unit)
		end
	end

	gUIUtils:LoadModel("", modelId, 1001, nil, , , cb, nil, otherData)
end

M._ApplyHiddenParts = function(self, spiritId, unit)
	local spiritFashionsInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.SpiritFashionsInfoDict
	local spiritFashionsInfo = spiritFashionsInfoDict and spiritFashionsInfoDict[spiritId]

	if spiritFashionsInfo and spiritFashionsInfo.SpiritWearFashionsInfo then
		local hiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.HiddenParts
		local editedHiddenParts = spiritFashionsInfo.SpiritWearFashionsInfo.EditedHiddenParts

		gDressManager:SetHiddenParts(hiddenParts, editedHiddenParts, unit)
	end
end

M.SwitchCharacterModel = function(self, spiritId, onLoadComplete)
	local fashionInfo = self:_GetSpiritFashionInfo(spiritId)

	self:LoadCharacterModel(spiritId, fashionInfo, nil, function (unit)
		if onLoadComplete then
			onLoadComplete(unit)
		end

		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.FashionPortal, self.currentModelUnit)
	end)
end

M.ClearCharacterModel = function(self)
	self:DisableDressSceneLookAt()

	if self.currentModelUnit and not L50.L50App.Scene.GamePlayUtils:UnitIsNull(self.currentModelUnit) then
		self.currentModelUnit:DestroyUnit(true)
	end

	self.currentModelUnit = nil
	self.loadedSpiritId = nil

	if self.currentLoadingType ~= self.LoadingType.Character then
		self.currentLoadingType = self.LoadingType.None
	end
end

M._EnsureWeaponParent = function(self)
	if self.weaponParent and not gCS.LuaUtils.IsNull(self.weaponParent) then
		return self.weaponParent
	end

	local go = UnityEngine.GameObject("WeaponParent")
	self.weaponParent = go

	return go
end

M._DestroyWeaponParent = function(self)
	if self.weaponParent and not gCS.LuaUtils.IsNull(self.weaponParent) then
		UnityEngine.GameObject.Destroy(self.weaponParent)
	end

	self.weaponParent = nil
end

M._CalcWeaponAABBOffset = function(self, weaponGo)
	local pAabb = gCS.WeaponSkinManager.Instance:GetGameObjectAABBCenter(weaponGo)

	if not pAabb then
		return Vector3.zero
	end

	local pPivot = weaponGo.transform.position

	return Vector3.New(pPivot.x - pAabb.x, pPivot.y - pAabb.y, pPivot.z - pAabb.z)
end

M.LoadWeaponModel = function(self, weaponSceneItemId, onLoadComplete, tab2)
	if not weaponSceneItemId or weaponSceneItemId ~= 0 then
		self:ClearWeaponModel()

		return
	end

	if self.loadedWeaponId ~= weaponSceneItemId and self.currentWeaponGo and not gCS.LuaUtils.IsNull(self.currentWeaponGo) then
		if onLoadComplete then
			onLoadComplete(self.currentWeaponGo)
		end

		return
	end

	if self.pendingWeaponId and self.pendingWeaponId ~= weaponSceneItemId then
		if onLoadComplete then
			self.pendingWeaponCallbacks = self.pendingWeaponCallbacks or {}

			table.insert(self.pendingWeaponCallbacks, onLoadComplete)
		end

		return
	end

	local weaponCfg = SceneitemConfig.GetConfig(weaponSceneItemId)

	if not weaponCfg or not weaponCfg.DJResPath or #weaponCfg.DJResPath ~= 0 then
		self:ClearWeaponModel()

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
		self:ClearWeaponModel()

		return
	end

	print_debug("DressSceneManager LoadWeaponModel BeginNew weaponId:" .. tostring(weaponSceneItemId) .. " prevPendingWeaponId:" .. tostring(self.pendingWeaponId) .. " prevLoadedWeaponId:" .. tostring(self.loadedWeaponId))
	self:ClearWeaponModel(false)

	self.loadingToken = self.loadingToken + 1
	local currentToken = self.loadingToken
	self.currentLoadingType = self.LoadingType.Weapon
	self.loadedWeaponId = weaponSceneItemId
	self.pendingWeaponId = weaponSceneItemId
	self.pendingWeaponCallbacks = nil
	local weaponPos, weaponEuler = self:_ResolveTransformData(nil, {
		tab2 = tab2
	}, self.goTypeEnum.weapon)
	self.weaponLoadOp = gResourceManager:LoadAssetWithCallBack(gCS.LuaUtils.GetWeaponResPath(modelResPath), typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == self.loadingToken or self.currentLoadingType == self.LoadingType.Weapon or self.loadedWeaponId == weaponSceneItemId then
			return
		end

		if not loadOp or not loadOp.asset then
			return
		end

		local weaponGo = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if not weaponGo then
			return
		end

		self:_ApplyWeaponNamePrefix(weaponGo)

		local weaponParent = self:_EnsureWeaponParent()
		weaponParent.transform.position = weaponPos
		local cachedForward = weaponParent.transform:TransformDirection(Vector3.forward)
		weaponParent.transform.localScale = Vector3.New(1, 1, 1)
		weaponParent.transform.eulerAngles = weaponEuler
		weaponGo.transform.position = weaponPos
		weaponGo.transform.eulerAngles = weaponEuler
		weaponGo.transform.localScale = Vector3.New(1, 1, 1)

		weaponGo:SetActive(true)

		local modelOffset = self:_CalcWeaponAABBOffset(weaponGo)
		weaponGo.transform.position = Vector3.New(weaponPos.x + modelOffset.x, weaponPos.y + modelOffset.y, weaponPos.z + modelOffset.z)

		weaponGo.transform:SetParent(weaponParent.transform, true)

		self.currentWeaponGo = weaponGo

		gCS.LuaUtils.ForceSetPlayerTransform(weaponParent.transform)
		gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.WeaponDisplay, {
			weaponGo = weaponParent,
			cachedForward = cachedForward,
			weaponType = tab2
		})

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

M.ClearWeaponModel = function(self, exitCamera)
	if exitCamera ~= nil or exitCamera then
		gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.WeaponDisplay, nil)
	end

	if self.weaponLoadOp then
		gResourceManager:UnloadAssetLoadOp(self.weaponLoadOp)

		self.weaponLoadOp = nil
	end

	if self.currentWeaponGo and not gCS.LuaUtils.IsNull(self.currentWeaponGo) then
		UnityEngine.GameObject.Destroy(self.currentWeaponGo)
	end

	self.currentWeaponGo = nil

	if self.weaponParent and not gCS.LuaUtils.IsNull(self.weaponParent) then
		self.weaponParent.transform.localEulerAngles = Vector3.zero
	end

	self.loadedWeaponId = nil
	self.pendingWeaponId = nil
	self.pendingWeaponCallbacks = nil

	if self.currentLoadingType ~= self.LoadingType.Weapon then
		self.currentLoadingType = self.LoadingType.None
	end
end

M.RotateWeaponModel = function(self, deltaY)
	if not self.weaponParent or gCS.LuaUtils.IsNull(self.weaponParent) then
		return
	end

	local euler = self.weaponParent.transform.eulerAngles
	euler.y = euler.y + deltaY
	self.weaponParent.transform.eulerAngles = euler
end

M.GetCurrentWeaponParent = function(self)
	if self.weaponParent and not gCS.LuaUtils.IsNull(self.weaponParent) then
		return self.weaponParent
	end

	return nil
end

gDressSceneManager = gDressSceneManager or C_DressSceneManager.new()
