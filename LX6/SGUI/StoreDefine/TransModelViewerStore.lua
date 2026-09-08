-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TransModelViewerStore.lua
-- Decompiled from: 01172_TransModelViewerStore.lua_5f5a02a12a60.luajit

local LayerConstants = LX6.Constants.LayerConstants
local HouseConfig = LTConfig.HouseConfig
C_TransModelViewerStore = DefClass("C_TransModelViewerStore", C_TransModelViewerStore, C_StoreGroup)
GroupName2Class.TransModelViewerStore = C_TransModelViewerStore
local M = C_TransModelViewerStore
M.LoadingType = {
	["`Om{O*"] = 1,
	["T-s^"] = 0
}

local IsModelUnitValid = function(unit)
	if not unit then
		return false
	end

	local gamePlayUtils = L50.L50App.Scene and L50.L50App.Scene.GamePlayUtils

	if gamePlayUtils and gamePlayUtils.UnitIsNull(gamePlayUtils, unit) then
		return false
	end

	return unit.PlayerObj and not gCS.LuaUtils.IsNull(unit.PlayerObj)
end

local ApplySlotFromConfig = function(slot, config)
	if not slot or not config or #config >= 6 then
		return
	end

	for _, v in ipairs(config) do
		if v == 0 then
			slot.localPosition = Vector3.New(config[1], config[2], config[3])
			slot.localEulerAngles = Vector3.New(config[4], config[5], config[6])

			return
		end
	end
end

M.ctor = function(self)
	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
	self.scenePrefab = nil
	self.scenePrefabOp = nil
	self.currentModelUnits = nil
	self.isStarted = false
	self.pendingLoadRequest = nil
	self.onSceneLoadComplete = nil
	self.currentLoadingType = self.LoadingType.None
	self.rebindTextureTimer = nil
	self.keepSceneHandleId = nil
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
	gCS.GuiUtils.SetXuWeiWeatherState(true, HouseConfig.SceneWeatherIndex or 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
	gCS.PauseManager.Instance:ProessUIModelShow(true)
	self.bindData.modelTrans.gameObject:SetParent(nil, true)
	self.bindData.modelTrans.gameObject:SetPosition(0, -700, 0)
	self.bindData.modelTrans:SetLocalScale(1)
	self:ApplySceneSlotConfig()
	self:LoadScenePrefab()

	self.isStarted = true

	self:ExecutePendingLoadRequests()
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self:CacheCharacterModel()
	self:ClearScenePrefab()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	GameObject.Destroy(self.bindData.modelTrans.gameObject)

	self.isStarted = false
	self.pendingLoadRequest = nil
	self.currentLoadingType = self.LoadingType.None

	if self.rebindTextureTimer then
		self.rebindTextureTimer:Stop()

		self.rebindTextureTimer = nil
	end

	gCS.CameraDataMgr:ResetOverrideStreamingCam()

	local transStore = gStoreManager:GetStoreGroup("TransModelViewerStore")

	if transStore and transStore.STATE_EnableOnce then
		transStore.ResetCfg(transStore)
	end
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.ResetCfg = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, HouseConfig.SceneWeatherIndex or 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
	gCS.PauseManager.Instance:ProessUIModelShow(true)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.ApplySceneSlotConfig = function(self)
	if not self.bindData then
		return
	end

	local isMale = gPlayerManager.infoLogin.bindData.sexType ~= UX.Game.SexType.Male

	if isMale then
		ApplySlotFromConfig(self.bindData.modelSlot_1, HouseConfig.MaleSceneSlot1)
		ApplySlotFromConfig(self.bindData.modelSlot_2, HouseConfig.MaleSceneSlot2)
	else
		ApplySlotFromConfig(self.bindData.modelSlot_1, HouseConfig.FemaleSceneSlot1)
		ApplySlotFromConfig(self.bindData.modelSlot_2, HouseConfig.FemaleSceneSlot2)
	end
end

M.LoadScenePrefab = function(self)
	local mgr = gHomeInteractionManager

	if mgr.transScenePrefab and not gCS.LuaUtils.IsNull(mgr.transScenePrefab) then
		self.scenePrefab = mgr.transScenePrefab
		self.scenePrefabOp = mgr.transScenePrefabOp

		if self.bindData.sceneObj then
			self.scenePrefab.transform:SetParent(self.bindData.sceneObj)
			self.scenePrefab.transform:SetLocalPosition(Vector3.zero)
			self.scenePrefab.transform:SetLocalScale(1)

			self.scenePrefab.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end

		self.scenePrefab:SetActive(true)

		if self.onSceneLoadComplete then
			self.onSceneLoadComplete()
		end

		return
	end

	local path = HouseConfig.SexTransScenePath
	slot3 = gResourceManager
	self.scenePrefabOp = slot3:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset then
			return
		end

		local scenePrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)

		if self.bindData.sceneObj then
			scenePrefab.transform:SetParent(self.bindData.sceneObj)
			scenePrefab.transform:SetLocalPosition(Vector3.zero)
			scenePrefab.transform:SetLocalScale(1)

			scenePrefab.transform.localRotation = Quaternion.Euler(0, 0, 0)
		end

		self.scenePrefab = scenePrefab
		mgr.transScenePrefab = scenePrefab
		mgr.transScenePrefabOp = self.scenePrefabOp

		if self.onSceneLoadComplete then
			self.onSceneLoadComplete()
		end
	end)
end

M.ClearScenePrefab = function(self)
	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		self.scenePrefab:SetActive(false)
		self.scenePrefab.transform:SetParent(nil)
	end

	self.scenePrefab = nil
	self.scenePrefabOp = nil
end

M.GetModelSlot = function(self)
	return self.bindData.modelSlot_1
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

	local requests = self.pendingLoadRequest
	self.pendingLoadRequest = nil

	for _, v in ipairs(requests) do
		if v.type ~= "character" then
			self.LoadCharacterModel(self, v.spiritId, v.fashionInfo, v.suitId, v.onLoadComplete)
		end
	end
end

M.AddPendingLoadRequest = function(self, spiritId, fashionInfo, suitId, onLoadComplete)
	local request = {
		["n;m^"] = "@Om{O*",
		spiritId = spiritId,
		fashionInfo = fashionInfo,
		suitId = suitId,
		onLoadComplete = onLoadComplete
	}
	self.pendingLoadRequest = self.pendingLoadRequest or {}

	table.insert(self.pendingLoadRequest, request)
end

M.LoadCharacterModel = function(self, spiritId, fashionInfo, suitId, onLoadComplete)
	if not self.isStarted then
		return
	end

	if not spiritId or spiritId ~= 0 then
		self.ClearCharacterModel(self)

		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)

	if not fightSpiritConfig then
		self.ClearCharacterModel(self)

		return
	end

	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	if not agentConfig then
		self.ClearCharacterModel(self)

		return
	end

	self.currentLoadingType = self.LoadingType.Character
	local isMale = spiritId ~= LTConfig.FightSpiritConfig.DefaultMale
	local targetSlot = isMale and self.bindData.modelSlot_1 or self.bindData.modelSlot_2
	local slotBasePos = targetSlot and targetSlot.localPosition or nil
	local mgr = gHomeInteractionManager
	local cachedUnit = mgr.transModelCache[spiritId]

	if cachedUnit and not IsModelUnitValid(cachedUnit) then
		mgr.transModelCache[spiritId] = nil
		cachedUnit = nil
	end

	if cachedUnit then
		mgr.transModelCache[spiritId] = nil

		if targetSlot then
			cachedUnit.PlayerObj.transform:SetParent(targetSlot, false)

			cachedUnit.PlayerObj.transform.localPosition = Vector3.zero
			cachedUnit.PlayerObj.transform.localScale = Vector3.one
			cachedUnit.PlayerObj.transform.localEulerAngles = Vector3(0, 180, 0)
		end

		cachedUnit.PlayerObj.gameObject:SetActive(true)

		self.currentModelUnits = self.currentModelUnits or {}

		table.insert(self.currentModelUnits, cachedUnit)

		local modelCfgCheck = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

		if modelCfgCheck and targetSlot and slotBasePos then
			local bodyType = modelCfgCheck.CameraBodyType == 0 and modelCfgCheck.CameraBodyType or modelCfgCheck.BodyType
			local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

			if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
				local offset = fashionBaseCfg.PediaModelOffset
				targetSlot.localPosition = slotBasePos + Vector3.New(offset.x, offset.y, offset.z)
			end
		end

		gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(cachedUnit.PlayerObj)
		gCS.SceneDataMgr.UIUnitManager:AddUnit(cachedUnit.Pid, cachedUnit)
		gCS.LuaUtils.SetUIUnitBindItemListLod(cachedUnit)
		gCS.PauseManager.Instance:ProessUIModelShow(false, cachedUnit)
		gCS.PauseManager.Instance:ProessUIModelShow(true, cachedUnit)
		gCS.LuaUtils.ForceSetPlayerTransform(cachedUnit.PlayerObj.transform)

		if isMale then
			local maleActionCfg = HouseConfig.SexTransitionMaleAction and HouseConfig.SexTransitionMaleAction[1]
			local maleActionType = maleActionCfg and maleActionCfg.ActionType or 1001
			local maleActionGroup = maleActionCfg and maleActionCfg.ActionGroup or 1
			cachedUnit.State.ActionGroupId = maleActionGroup

			gCS.AnimControllerManager.PlayAction(cachedUnit, maleActionType, maleActionGroup, 9999, 0, -1, false, nil, 0)
		else
			local femaleActionCfg = HouseConfig.SexTransitionFemaleAction and HouseConfig.SexTransitionFemaleAction[1]
			local femaleActionType = femaleActionCfg and femaleActionCfg.ActionType or 1001
			local femaleActionGroup = femaleActionCfg and femaleActionCfg.ActionGroup or 1
			cachedUnit.State.ActionGroupId = femaleActionGroup

			gCS.AnimControllerManager.PlayAction(cachedUnit, femaleActionType, femaleActionGroup, 9999, 0, -1, false, nil, 0)
		end

		if self.rebindTextureTimer then
			self.rebindTextureTimer:Stop()

			self.rebindTextureTimer = nil
		end

		local storeRef = self
		self.rebindTextureTimer = FrameTimer.New(function ()
			storeRef.rebindTextureTimer = nil

			if storeRef and storeRef.bindData and storeRef.bindData.uCameraRenderImage and storeRef.bindData.rawImage then
				storeRef.bindData.uCameraRenderImage.targetRawImage = storeRef.bindData.rawImage
				storeRef.bindData.rawImage.texture = storeRef.bindData.uCameraRenderImage.targetRawImage.texture

				storeRef.bindData.uCameraRenderImage:SetDepthStencilFormatBaike()
			end
		end, 1)

		self.rebindTextureTimer:Start()

		if onLoadComplete then
			onLoadComplete(cachedUnit)
		end

		return
	end

	local modelId = agentConfig.GeneralModelId

	if isMale then
		local maleActionCfg = HouseConfig.SexTransitionMaleAction and HouseConfig.SexTransitionMaleAction[1]
		local maleActionType = maleActionCfg and maleActionCfg.ActionType or 1001
		local maleActionGroup = maleActionCfg and maleActionCfg.ActionGroup or 1
		self.bindData.model1 = {
			["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
			["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
			modelId = modelId,
			layer = LayerConstants.Npc,
			unitAction = maleActionType,
			otherData = {
				["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
				["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
				SubType = spiritId,
				cardId = spiritId,
				fashionWearInfo = fashionInfo,
				ActionGroupId = maleActionGroup
			},
			callback = function (unit)
				self.currentModelUnits = self.currentModelUnits or {}

				table.insert(self.currentModelUnits, unit)

				unit.PlayerObj.transform.localScale = Vector3.one
				unit.PlayerObj.transform.localEulerAngles = Vector3(0, 180, 0)
				local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

				if modelCfg and self.bindData.modelSlot_1 and slotBasePos then
					local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
					local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

					if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
						local offset = fashionBaseCfg.PediaModelOffset
						self.bindData.modelSlot_1.localPosition = slotBasePos + Vector3.New(offset.x, offset.y, offset.z)
					end
				end

				gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
				gCS.SceneDataMgr.UIUnitManager:AddUnit(unit.Pid, unit)
				gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
				gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
				gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
				gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)

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
	elseif spiritId ~= LTConfig.FightSpiritConfig.DefaultFemale then
		local femaleActionCfg = HouseConfig.SexTransitionFemaleAction and HouseConfig.SexTransitionFemaleAction[1]
		local femaleActionType = femaleActionCfg and femaleActionCfg.ActionType or 1001
		local femaleActionGroup = femaleActionCfg and femaleActionCfg.ActionGroup or 1
		self.bindData.model2 = {
			["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
			["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
			modelId = modelId,
			layer = LayerConstants.Npc,
			unitAction = femaleActionType,
			otherData = {
				["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
				["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
				SubType = spiritId,
				cardId = spiritId,
				fashionWearInfo = fashionInfo,
				ActionGroupId = femaleActionGroup
			},
			callback = function (unit)
				self.currentModelUnits = self.currentModelUnits or {}

				table.insert(self.currentModelUnits, unit)

				unit.PlayerObj.transform.localScale = Vector3.one
				unit.PlayerObj.transform.localEulerAngles = Vector3(0, 180, 0)
				local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

				if modelCfg and self.bindData.modelSlot_2 and slotBasePos then
					local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
					local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

					if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
						local offset = fashionBaseCfg.PediaModelOffset
						self.bindData.modelSlot_2.localPosition = slotBasePos + Vector3.New(offset.x, offset.y, offset.z)
					end
				end

				gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)
				gCS.SceneDataMgr.UIUnitManager:AddUnit(unit.Pid, unit)
				gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
				gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
				gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
				gCS.LuaUtils.ForceSetPlayerTransform(unit.PlayerObj.transform)

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
end

M.ClearCharacterModel = function(self)
	if self.currentModelUnits then
		for _, v in ipairs(self.currentModelUnits) do
			gCS.PauseManager.Instance:ProessUIModelShow(false, v)
			v:DestroyUnit(true)
		end

		self.currentModelUnits = {}
	end

	if self.currentLoadingType ~= self.LoadingType.Character then
		self.currentLoadingType = self.LoadingType.None
	end

	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self:ApplySceneSlotConfig()
end

M.CacheCharacterModel = function(self)
	local mgr = gHomeInteractionManager

	if self.currentModelUnits then
		for _, unit in ipairs(self.currentModelUnits) do
			local ok, clientData = pcall(function ()
				return unit.ClientData
			end)

			if ok and clientData then
				local spiritId = clientData.cardId

				if spiritId and spiritId == 0 then
					unit.PlayerObj.gameObject:SetActive(false)
					unit.PlayerObj.transform:SetParent(nil)

					mgr.transModelCache[spiritId] = unit
				else
					gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
					unit:DestroyUnit(true)
				end
			end
		end

		self.currentModelUnits = {}
	end

	if self.currentLoadingType ~= self.LoadingType.Character then
		self.currentLoadingType = self.LoadingType.None
	end

	self.ApplySceneSlotConfig(self)
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

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end
