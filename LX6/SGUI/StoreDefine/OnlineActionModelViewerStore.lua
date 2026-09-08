-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineActionModelViewerStore.lua
-- Decompiled from: 01096_OnlineActionModelViewerStore.lua_d455bc8299b1.luajit

C_OnlineActionModelViewerStore = DefClass("C_OnlineActionModelViewerStore", C_OnlineActionModelViewerStore, C_StoreGroup)
GroupName2Class.OnlineActionModelViewerStore = C_OnlineActionModelViewerStore
local M = C_OnlineActionModelViewerStore
local LayerConstants = LX6.Constants.LayerConstants

M.ctor = function(self)
	self.DefineAllVariables(self)
end

M.DefineAllVariables = function(self)
	self.bindModelName = "model"
	self.bindModelTransName = "modelTransform"
	self.pendingLoadRequest = nil
	self.originalModelSlotPos = nil
	self.currentModelUnit = nil
	self.modelSlotTid = nil
	self.isStarted = false
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self.bindData.baseTrans.gameObject:SetParent(nil, true)
	self.bindData.baseTrans.gameObject:SetPosition(0, -100, 0)
	self.bindData.baseTrans:SetLocalScale(1)
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
	gCS.PauseManager.Instance:ProessUIModelShow(true)
	self:LoadScenePrefab()

	self.isStarted = true

	self:ExecutePendingLoadRequests()

	if self.startCallback then
		self.startCallback()

		self.startCallback = nil
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.targetWeatherIndex = nil

	self:ClearCharacterModel()
	self:ClearScenePrefab()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gCS.LuaUtils.SetShadowRenderDataUIMode(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	GameObject.Destroy(self.bindData.baseTrans.gameObject)

	self.isStarted = false
	self.pendingLoadRequest = nil
	self.originalModelSlotPos = nil
	self.currentModelUnit = nil
	self.modelSlotTid = nil

	gCS.CameraDataMgr:ResetOverrideStreamingCam()
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
end

M.ResetCfg = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, 20)
	gCS.LuaUtils.SetShadowRenderDataUIMode(true)
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	gCS.CameraDataMgr:SetOverrideStreamingCam(self.bindData.camera)
	gCS.PauseManager.Instance:ProessUIModelShow(true)
end

M.GetCamera = function(self)
	return self.bindData.camera or gCS.CameraDataMgr.MainCamera
end

M.SetupCameraRender = function(self)
	local camera = self.GetCamera(self)
	local cameraRenderImage = self.bindData.uCameraRenderImage

	if cameraRenderImage ~= nil then
		return nil
	end

	cameraRenderImage.targetRawImage = self.bindData.rawImage

	cameraRenderImage:SetSourceCamera(camera)
	gCS.CameraDataMgr:SetMainCameraEnable(true, gPanelId.ONLINE_SIGNAL_CIRCLE_ACTION_PREVIEW_PANEL)
	cameraRenderImage:SetDepthStencilFormatBaike()

	if self.bindData.rawImage ~= nil then
		return nil
	end

	self.bindData.rawImage.texture = cameraRenderImage.targetRawImage.texture

	return camera
end

M.GetCurrentUnit = function(self)
	return self.currentModelUnit
end

M.LoadScenePrefab = function(self)
	local path = LTConfig.LinkConfig.ActionPreviewScenePath
	slot2 = gResourceManager
	self.scenePrefabOp = slot2:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
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

		if self.onSceneLoadComplete then
			self.onSceneLoadComplete()
		end
	end)
end

M.ClearScenePrefab = function(self)
	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		GameObject.Destroy(self.scenePrefab)

		self.scenePrefab = nil
	end

	self.scenePrefabOp = nil
end

M.ExecutePendingLoadRequests = function(self)
	local req = self.pendingLoadRequest

	if not req then
		return
	end

	self.pendingLoadRequest = nil

	if req.type ~= "character" then
		self.LoadCharacterModel(self, req.spiritId, req.fashionInfo, req.onLoadComplete)
	end
end

M.LoadCharacterModel = function(self, spiritId, fashionInfo, onLoadComplete)
	if not self.isStarted then
		self.pendingLoadRequest = {
			["n;m^"] = "@Om{O*",
			spiritId = spiritId,
			fashionInfo = fashionInfo,
			onLoadComplete = onLoadComplete
		}

		return
	end

	if self.modelSlotTid ~= spiritId then
		return
	end

	if not spiritId or spiritId ~= 0 then
		self.ClearCharacterModel(self)

		return
	end

	local fightSpiritConfig = LTConfig.FightSpiritConfig.GetConfig(spiritId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(fightSpiritConfig.AgentId)

	self.ClearCharacterModel(self)

	self.modelSlotTid = spiritId
	local modelSlot = self.bindData[self.bindModelTransName]

	if not self.originalModelSlotPos and modelSlot then
		self.originalModelSlotPos = modelSlot.localPosition
	end

	local modelId = agentConfig.GeneralModelId
	self.bindData[self.bindModelName] = {
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
			if spiritId == self.modelSlotTid then
				unit.DestroyUnit(unit, true)

				return
			end

			unit.PlayerObj.gameObject:SetLayerRecursively(LayerConstants.Npc)

			self.currentModelUnit = unit
			unit.PlayerObj.transform.localScale = Vector3.one
			unit.PlayerObj.transform.localEulerAngles = Vector3(0, 0, 0)
			local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentConfig.GeneralModelId)

			if modelCfg and self.bindData[self.bindModelTransName] and self.originalModelSlotPos then
				local bodyType = modelCfg.CameraBodyType == 0 and modelCfg.CameraBodyType or modelCfg.BodyType
				local fashionBaseCfg = LTConfig.FashionBaseConfig.GetConfig(bodyType)

				if fashionBaseCfg and fashionBaseCfg.PediaModelOffset then
					local offset = fashionBaseCfg.PediaModelOffset
					local newPos = self.originalModelSlotPos + Vector3.New(offset.x, offset.y, offset.z)
					self.bindData[self.bindModelTransName].localPosition = newPos
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
		local unit = self.currentModelUnit

		if gCS.LuaUtils.IsBaseUnitValid(unit) then
			gCS.PauseManager.Instance:ProessUIModelShow(false, unit)
			unit:DestroyUnit(true)
		end

		self.currentModelUnit = nil
	end

	self.modelSlotTid = nil

	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()

	local modelSlot = self.bindData[self.bindModelTransName]

	if self.originalModelSlotPos and modelSlot then
		modelSlot.localPosition = self.originalModelSlotPos
	end
end

M.PlayIdle = function(self)
	local unit = self.currentModelUnit

	if not unit or not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return
	end

	gCS.AnimControllerManager.PlayAction(unit, 1001, 1, 9999, 0, -1, false, nil, 0)
end

M.PlayActionItem = function(self, actionItemId)
	local unit = self.currentModelUnit

	if not unit or not gCS.LuaUtils.IsBaseUnitValid(unit) then
		return false
	end

	local cfg = LTConfig.ActionItemConfig.GetConfig(actionItemId)

	if not cfg then
		return false
	end

	local pose = cfg.ActionPose

	if not pose or not pose[1] then
		return false
	end

	local actionType, actionGroup = nil

	if type(pose[1]) ~= "table" then
		actionGroup = pose[1][2]
		actionType = pose[1][1]
	else
		actionGroup = pose[2]
		actionType = pose[1]
	end

	actionGroup = actionGroup or 1

	if not actionType or actionType ~= 0 then
		return false
	end

	gCS.AnimControllerManager.PlayAction(unit, actionType, actionGroup, 9999, 0, -1, false, nil, 0)

	return true
end
