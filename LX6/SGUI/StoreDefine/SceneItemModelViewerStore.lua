-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SceneItemModelViewerStore.lua
-- Decompiled from: 00869_SceneItemModelViewerStore.lua_e9b4b6f55ddb.luajit

C_SceneItemModelViewerStore = DefClass("C_SceneItemModelViewerStore", C_SceneItemModelViewerStore, C_StoreGroup)
GroupName2Class.SceneItemModelViewerStore = C_SceneItemModelViewerStore
local M = C_SceneItemModelViewerStore
local LayerConstants = LX6.Constants.LayerConstants
local SceneitemConfig = LTConfig.SceneitemConfig
local CollectionBookConfig = LTConfig.CollectionBookConfig
local PreviewWeatherIndex = LTConfig.CityPediaConfig.FashionWeatherIndex or 17

local GetModelPath = function(sceneItemModelId)
	local config = SceneitemConfig.GetConfig(sceneItemModelId)

	if not config or not config.SceneitemResPath then
		return
	end

	return config.SceneitemResPath
end

local GetRendererBounds = function(modelGo)
	local renderers = modelGo:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)

	if not renderers or renderers.Length ~= 0 then
		return
	end

	local bounds = renderers[0].bounds

	for index = 1, renderers.Length - 1 do
		bounds:Encapsulate(renderers[index].bounds)
	end

	return bounds
end

M.DefineAllVariables = function(self)
	self.sceneItemModelId = 0
	self.modelPath = nil
	self.modelGo = nil
	self.modelLoadOp = nil
	self.loadToken = 0
	self.onLoaded = nil
	self.effectRequests = {}
	self.effectUUIDs = {}
	self.rotationAxis = Vector3.up
	self.baseCameraDistance = 0
	self.zoomFactor = 1
	self.cameraDirection = Vector3.forward
	self.defaultFarClip = 20
end

M.OnAwake = function(self)
	self:DefineAllVariables()

	self.beforeSwitchSceneAction = self:CreateAction("OnBeforeSwitchScene")
	self.loadingFinishedAction = self:CreateAction("OnLoadingFinished")

	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.beforeSwitchSceneAction)
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self.loadingFinishedAction)
end

M.OnStart = function(self)
	local camera = self.bindData.camera
	local modelRoot = self.bindData.sceneObj
	local modelTrans = self.bindData.modelTrans

	assert(camera and modelRoot and modelTrans and self.bindData.uCameraRenderImage.targetRawImage, "SceneItemModelViewer prefab binding is incomplete")
	modelTrans.gameObject:SetParent(nil, true)
	modelTrans.gameObject:GetOrAddComponent(typeof(LX6.GUI.DestroyOnPlayModeExit))
	modelTrans.gameObject:SetPosition(0, 0, 0)
	modelTrans:SetLocalScale(1)

	local direction = camera.transform.position - modelRoot.position

	if direction.sqrMagnitude <= 0.001 then
		self.cameraDirection = direction.normalized
	end

	self.defaultFarClip = camera.farClipPlane
	local inputGo = self.bindData.uCameraRenderImage.targetRawImage.gameObject
	local gestureListener = SGUI.EventSystems.GestureEventListener.Get(inputGo)
	gestureListener.onDrag = self:CreateAction("OnDrag")
	gestureListener.onZoom = self:CreateAction("OnGestureZoom")
end

M.OnEnable = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(true, PreviewWeatherIndex)
	self.bindData.modelTrans.gameObject:SetActive(true)

	if self.sceneItemModelId <= 0 and not self.modelGo and not self.modelLoadOp then
		self:LoadModel()
	end
end

M.OnDisable = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	self:ReleaseModel()
	self.bindData.modelTrans.gameObject:SetActive(false)
end

M.OnDestroy = function(self)
	self:Clear()
	GameObject.Destroy(self.bindData.modelTrans.gameObject)
	gMessageManager:RemoveMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self.beforeSwitchSceneAction)
	gMessageManager:RemoveMessageListener(gEventConstants.LOADING_FINISHED, self.loadingFinishedAction)
end

M.Show = function(self, sceneItemModelId, onLoaded)
	if not sceneItemModelId or sceneItemModelId ~= 0 then
		self:Clear()

		return false
	end

	if self.sceneItemModelId ~= sceneItemModelId then
		self.onLoaded = onLoaded

		if self.modelGo and not gCS.LuaUtils.IsNull(self.modelGo) then
			if onLoaded then
				onLoaded(self.modelGo)
			end

			return true
		end

		if self.modelLoadOp then
			return true
		end
	end

	local modelPath = GetModelPath(sceneItemModelId)

	if not modelPath then
		print_error_without_stack("SceneItemModelViewer invalid modelId:" .. tostring(sceneItemModelId))
		self:Clear()

		return false
	end

	if self.sceneItemModelId == 0 then
		self.effectRequests = {}
	end

	self.sceneItemModelId = sceneItemModelId
	self.modelPath = modelPath
	self.onLoaded = onLoaded

	self:LoadModel()

	return true
end

M.LoadModel = function(self)
	if self.sceneItemModelId ~= 0 or not self.modelPath or not self.rootGo.activeInHierarchy then
		return
	end

	self:ReleaseModel()

	local sceneItemModelId = self.sceneItemModelId
	local currentToken = self.loadToken
	self.modelLoadOp = gResourceManager:LoadAssetWithCallBack(self.modelPath, typeof(UnityEngine.GameObject), function (loadOp)
		if currentToken == self.loadToken or sceneItemModelId == self.sceneItemModelId then
			return
		end

		if not loadOp or not loadOp.asset then
			print_error_without_stack("SceneItemModelViewer load failed modelId:" .. tostring(sceneItemModelId))

			return
		end

		local modelGo = UnityEngine.GameObject.Instantiate(loadOp.asset)

		modelGo.transform:SetParent(self.bindData.sceneObj, false)

		modelGo.transform.localPosition = Vector3.zero
		modelGo.transform.localEulerAngles = Vector3.zero
		modelGo.transform.localScale = Vector3.one

		modelGo:SetLayerRecursively(LayerConstants.Ui)
		modelGo:SetActive(true)

		self.modelGo = modelGo

		self:CenterAndFitModel()
		self:PlayRequestedEffects()

		if self.onLoaded then
			self.onLoaded(modelGo)
		end
	end)
end

M.SetRotationAxis = function(self, rotation)
	if type(rotation) ~= "number" then
		self.rotationAxis = Vector3.up

		return
	end

	local axis = Vector3.New(rotation.x, rotation.y, rotation.z)
	self.rotationAxis = axis.sqrMagnitude <= 0 and axis.normalized or Vector3.up
end

M.CenterAndFitModel = function(self)
	local bounds = GetRendererBounds(self.modelGo)

	if not bounds then
		self.baseCameraDistance = 0

		return
	end

	local modelRoot = self.bindData.sceneObj
	local modelTransform = self.modelGo.transform
	local localCenter = modelRoot:InverseTransformPoint(bounds.center)
	modelTransform.localPosition = modelTransform.localPosition - localCenter
	local extents = bounds.extents
	local camera = self.bindData.camera
	local halfFov = camera.fieldOfView * math.pi / 360
	local aspect = camera.targetTexture.width / camera.targetTexture.height
	local distanceByHeight = extents.y / math.tan(halfFov)
	local distanceByWidth = extents.x / (math.tan(halfFov) * aspect)
	self.baseCameraDistance = (math.max(distanceByHeight, distanceByWidth) + extents.z) * CollectionBookConfig.CameraPadding
	self.boundsRadius = math.sqrt(extents.x * extents.x + extents.y * extents.y + extents.z * extents.z)

	self:ResetView()
end

M.ResetView = function(self)
	self.bindData.sceneObj.localEulerAngles = Vector3.zero
	self.zoomFactor = 1

	if self.baseCameraDistance <= 0 then
		self:ApplyCameraDistance(self.baseCameraDistance)
	end
end

M.ApplyCameraDistance = function(self, distance)
	local camera = self.bindData.camera
	local targetPosition = self.bindData.sceneObj.position
	camera.transform.position = targetPosition + self.cameraDirection * distance
	camera.transform.rotation = Quaternion.LookRotation(targetPosition - camera.transform.position, Vector3.up)
	camera.nearClipPlane = math.max(0.01, distance - self.boundsRadius * 1.5)
	camera.farClipPlane = math.max(self.defaultFarClip, distance + self.boundsRadius * 1.5)
end

M.Rotate = function(self, deltaX)
	if self.modelGo then
		self.bindData.sceneObj:Rotate(self.rotationAxis, -deltaX * CollectionBookConfig.RotateSpeed)
	end
end

M.Zoom = function(self, delta)
	if self.baseCameraDistance ~= 0 then
		return
	end

	self.zoomFactor = math.max(CollectionBookConfig.MinZoom, math.min(CollectionBookConfig.MaxZoom, self.zoomFactor - delta * CollectionBookConfig.ZoomSpeed))

	self:ApplyCameraDistance(self.baseCameraDistance * self.zoomFactor)
end

M.OnDrag = function(self, eventData)
	if eventData.button ~= 0 then
		self:Rotate(eventData.delta.x)
	end
end

M.OnGestureZoom = function(self, delta)
	self:Zoom(delta <= 0 and 1 or -1)
end

M.PlayEffect = function(self, effectId, mountPath)
	if not effectId or effectId ~= 0 then
		return 0
	end

	self.effectRequests[#self.effectRequests + 1] = {
		effectId = effectId,
		mountPath = mountPath
	}

	if not self.modelGo then
		return 0
	end

	return self:PlayEffectNow(effectId, mountPath)
end

M.PlayEffectNow = function(self, effectId, mountPath)
	local mount = self.modelGo.transform

	if not string.is_null_or_empty(mountPath) then
		mount = mount:Find(mountPath) or mount
	end

	local uuid = gCS.EffectMgr:PlayEffectsOnTransform(effectId, LX6.Effect.EffectPlayTag.UI, mount, mount.position, 0, -1)

	if uuid and uuid == 0 then
		self.effectUUIDs[#self.effectUUIDs + 1] = uuid
	end

	return uuid
end

M.PlayRequestedEffects = function(self)
	for _, request in ipairs(self.effectRequests) do
		self:PlayEffectNow(request.effectId, request.mountPath)
	end
end

M.StopActiveEffects = function(self)
	for _, uuid in ipairs(self.effectUUIDs) do
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(uuid)
	end

	self.effectUUIDs = {}
end

M.StopEffects = function(self)
	self.effectRequests = {}

	self:StopActiveEffects()
end

M.ReleaseModel = function(self)
	self.loadToken = self.loadToken + 1

	self:StopActiveEffects()

	if self.modelLoadOp then
		gResourceManager:UnloadAssetLoadOp(self.modelLoadOp)

		self.modelLoadOp = nil
	end

	if self.modelGo and not gCS.LuaUtils.IsNull(self.modelGo) then
		UnityEngine.GameObject.Destroy(self.modelGo)
	end

	self.modelGo = nil
	self.baseCameraDistance = 0
	self.bindData.sceneObj.localEulerAngles = Vector3.zero
end

M.Clear = function(self)
	self.sceneItemModelId = 0
	self.modelPath = nil
	self.onLoaded = nil
	self.effectRequests = {}
	self.rotationAxis = Vector3.up

	self:ReleaseModel()
end

M.OnBeforeSwitchScene = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	self.bindData.modelTrans.gameObject:SetActive(false)
	self:ReleaseModel()
end

M.OnLoadingFinished = function(self, _, switchType)
	if switchType ~= gSwitchSceneType.Reconnect and self.sceneItemModelId <= 0 and not self.modelGo and not self.modelLoadOp and self.rootGo.activeInHierarchy then
		gCS.GuiUtils.SetXuWeiWeatherState(true, PreviewWeatherIndex)
		self.bindData.modelTrans.gameObject:SetActive(true)
		self:LoadModel()
	end
end
