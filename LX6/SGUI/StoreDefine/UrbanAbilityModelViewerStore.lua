-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\UrbanAbilityModelViewerStore.lua
-- Decompiled from: 01187_UrbanAbilityModelViewerStore.lua_1d989f810b54.luajit

local FightSpiritConfig = LTConfig.FightSpiritConfig
local FightSpiritUIModelConfig = LTConfig.FightSpiritUIModelConfig
local UnitModelManager = LX6.Units.UnitModelManager
local Log = UnityEngine.Debug.Log
local DEFAULT_WRAPPER_PATH = "Res/SGUI/Panel/UrbanAbility/Edit/nz/prefab/wrapper_nz.prefab"
local HISTORY_CACHE_CAPACITY = 2

local GetLoadTimestamp = function()
	return Time.realtimeSinceStartup
end

local GetHighResolutionTimestamp = function()
	return os.clock()
end

local GetHighResolutionCostMs = function(startTime)
	return (os.clock() - startTime) * 1000
end

local LogLoadTimeline = function(format, ...)
	Log(string.format("[UrbanAbilityModelViewerPerf] timestampMs=%.2f frame=%d " .. format, Time.realtimeSinceStartup * 1000, Time.frameCount, ...))
end

local BeginSample = function(name)
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample(name)
	end
end

local EndSample = function()
	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

C_UrbanAbilityModelViewerStore = DefClass("C_UrbanAbilityModelViewerStore", C_UrbanAbilityModelViewerStore, C_StoreGroup)
GroupName2Class.UrbanAbilityModelViewerStore = C_UrbanAbilityModelViewerStore
local M = C_UrbanAbilityModelViewerStore

M.ctor = function(self)
	self.OnInit(self)
end

M.OnAwake = function(self)
	self.OnInit(self)

	self.viewerAwakeTime = GetLoadTimestamp()
	self.scenePrefab = nil
end

M.OnInit = function(self)
	self.tid = 0
	self.modelLoadCounts = {}
	self.modelUnit = nil
	self.mainCamera = nil
	self.mainCameraOrigin = nil
	self.mainCameraOutputTexture = nil
	self.mainCameraOutputApplied = false
	self.animationLoadCor = nil
	self.wrapperReady = false
	self.modelReady = false
	self.modelReadyCallback = nil
	self.cachedModels = {}
	self.cachedScenes = {}
	self.scenePrefab = nil
	self.scenePrefabOp = nil
	self.scenePrefabPath = nil
end

M.OnStart = function(self)
	BeginSample("UrbanAbilityModelViewer.OnStart")
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()

	self.bindData.rawImage.material = nil

	EndSample()

	if self.viewerAwakeTime then
		LogLoadTimeline("phase=ViewerStarted costMs=%.2f", (Time.realtimeSinceStartup - self.viewerAwakeTime) * 1000)
	end
end

M.InitMainCameraOutput = function(self)
	if self.mainCameraOutputApplied then
		return
	end

	local mainCamera = gCS.CameraDataMgr.MainCamera
	local outputTexture = self.bindData.rawImage.texture

	if not mainCamera or not outputTexture then
		return
	end

	self.mainCamera = mainCamera
	self.mainCameraOrigin = mainCamera.targetTexture
	self.mainCameraOutputTexture = outputTexture
	self.mainCameraOutputApplied = true
	mainCamera.targetTexture = outputTexture
end

M.LoadRootWrapper = function(self, loadIndex, isFirstLoad)
	local path = self.GetWrapperPath(self)

	if self.currentWrapperPath ~= path and self.rootWrapperGo and not gCS.LuaUtils.IsNull(self.rootWrapperGo) then
		self.SetCameraPos(self)

		self.wrapperReady = true

		self.TryNotifyModelReady(self)
		LogLoadTimeline("phase=WrapperReused tid=%s loadIndex=%d isFirstLoad=%s path=%s", tostring(self.tid), loadIndex, tostring(isFirstLoad), path)

		return
	end

	self.currentWrapperPath = path
	self.wrapperCache = self.wrapperCache or {}
	self.rootOps = self.rootOps or {}
	local cachedGo = self.wrapperCache[path]

	if cachedGo and not gCS.LuaUtils.IsNull(cachedGo) then
		self.SwitchToRootWrapper(self, cachedGo)
		LogLoadTimeline("phase=WrapperReused tid=%s loadIndex=%d isFirstLoad=%s path=%s", tostring(self.tid), loadIndex, tostring(isFirstLoad), path)

		return
	end

	if self.rootOps[path] then
		LogLoadTimeline("phase=WrapperPending tid=%s loadIndex=%d isFirstLoad=%s path=%s", tostring(self.tid), loadIndex, tostring(isFirstLoad), path)

		return
	end

	slot5 = self.bindData.modelRoot.gameObject

	slot5:SetActive(false)

	slot5 = self.bindData.sceneRoot.gameObject

	slot5:SetActive(false)

	local loadStartTime = GetLoadTimestamp()
	local tid = self.tid

	LogLoadTimeline("phase=WrapperLoadBegin tid=%s loadIndex=%d isFirstLoad=%s path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), path)

	slot8 = gResourceManager
	self.rootOps[path] = slot8:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not self.wrapperCache or not loadOp or not loadOp.asset then
			return
		end

		local assetLoadedTime = GetLoadTimestamp()

		if loadStartTime and assetLoadedTime then
			LogLoadTimeline("phase=WrapperAssetLoaded tid=%s loadIndex=%d isFirstLoad=%s loadMs=%.2f path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), (assetLoadedTime - loadStartTime) * 1000, path)
		end

		BeginSample("UrbanAbilityModelViewer.RootWrapperLoadedCallback")

		local instantiateStartTime = GetLoadTimestamp()
		local wrapperGo = UnityEngine.GameObject.Instantiate(loadOp.asset, Vector3.New(-1130, 0, 160), Quaternion.identity)
		local instantiateEndTime = GetLoadTimestamp()

		if instantiateStartTime and instantiateEndTime then
			LogLoadTimeline("phase=WrapperInstantiated tid=%s loadIndex=%d isFirstLoad=%s instantiateMs=%.2f path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), (instantiateEndTime - instantiateStartTime) * 1000, path)
		end

		wrapperGo.transform:SetLocalScale(1)

		self.wrapperCache[path] = wrapperGo

		if self.currentWrapperPath ~= path then
			self:SwitchToRootWrapper(wrapperGo)
		else
			wrapperGo:SetActive(false)
		end

		EndSample()

		if loadStartTime then
			LogLoadTimeline("phase=WrapperReady tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.2f path=%s", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000, path)
		end
	end)
end

M.GetWrapperPath = function(self)
	local cfg = self.GetUIModelCfg(self)

	if cfg and cfg.WrapperResPath and cfg.WrapperResPath == "" then
		return cfg.WrapperResPath
	end

	return DEFAULT_WRAPPER_PATH
end

M.SwitchToRootWrapper = function(self, wrapperGo)
	wrapperGo:SetActive(true)
	self:SetParentAndReset(self.bindData.camera.transform, wrapperGo.transform)
	self:SetParentAndReset(self.bindData.modelRoot, wrapperGo.transform)
	self:SetParentAndReset(self.bindData.sceneRoot, wrapperGo.transform)
	self.bindData.modelRoot.gameObject:SetActive(true)
	self.bindData.sceneRoot.gameObject:SetActive(true)

	if self.rootWrapperGo and not gCS.LuaUtils.IsNull(self.rootWrapperGo) and self.rootWrapperGo == wrapperGo then
		self.rootWrapperGo:SetActive(false)
	end

	self.rootWrapperGo = wrapperGo

	self.SetCameraPos(self)

	self.wrapperReady = true

	self.TryNotifyModelReady(self)
end

M.SetParentAndReset = function(self, trans, parent)
	trans.SetParent(trans, parent)
	trans.SetLocalPosition(trans, Vector3.zero)

	trans.localRotation = Quaternion.Euler(0, 0, 0)

	trans.SetLocalScale(trans, 1)
end

M.OnDestroy = function(self)
	self.tid = 0
	self.modelReadyCallback = nil

	self.RestoreMainCameraOutput(self)

	if self.animationLoadCor then
		coroutine.stop(self.animationLoadCor)

		self.animationLoadCor = nil
	end

	if self.animatorPlayCor then
		coroutine.stop(self.animatorPlayCor)
	end

	self:DestroyUnit()
	self:DestroyCachedModels()
	self:DestroyCurrentScene()
	self:DestroyCachedScenes()
	gCS.LuaUtils.SetStreamingMipmapsMaxFileIORequests(false)

	if not gPanelManager:IsPanelShowing(gPanelId.S_FASHION_PORTAL_PANEL) then
		gCS.GuiUtils.SetXuWeiWeatherState(false)
	end

	gCS.PauseManager.Instance:ProessUIModelShow(false)

	if self.rootOps then
		for _, op in pairs(self.rootOps) do
			gResourceManager:UnloadAssetLoadOp(op)
		end

		self.rootOps = nil
	end

	if self.wrapperCache then
		for _, go in pairs(self.wrapperCache) do
			if go and not gCS.LuaUtils.IsNull(go) then
				GameObject.Destroy(go)
			end
		end

		self.wrapperCache = nil
	end

	self.rootWrapperGo = nil

	gCS.CameraDataMgr:ResetOverrideStreamingCam()

	local baikeStore = gStoreManager:GetStoreGroup("BaikeModelViewerStore")

	if baikeStore and baikeStore.STATE_EnableOnce then
		baikeStore.ResetCfg(baikeStore)
	end
end

M.TryNotifyModelReady = function(self)
	if not self.wrapperReady or not self.modelReady or not self.modelReadyCallback then
		return
	end

	local callback = self.modelReadyCallback
	self.modelReadyCallback = nil

	LogLoadTimeline("phase=ModelReady tid=%s", tostring(self.tid))
	callback()
end

M.SetModelReady = function(self, tid, loadIndex)
	if self.tid == tid or self.modelLoadCounts[tid] == loadIndex then
		return
	end

	self.modelReady = true

	self.TryNotifyModelReady(self)
end

M.RestoreMainCameraOutput = function(self)
	if not self.mainCameraOutputApplied then
		return
	end

	if self.mainCamera and not gCS.LuaUtils.IsNull(self.mainCamera) and self.mainCamera.targetTexture ~= self.mainCameraOutputTexture then
		self.mainCamera.targetTexture = self.mainCameraOrigin
	end

	self.mainCamera = nil
	self.mainCameraOrigin = nil
	self.mainCameraOutputTexture = nil
	self.mainCameraOutputApplied = false
end

M.DestroyUnit = function(self)
	if not self.modelUnit then
		return
	end

	if gCS.LuaUtils.IsBaseUnitValid(self.modelUnit) then
		BeginSample("UrbanAbilityModelViewer.DestroyUnit")
		self.modelUnit.PlayerObj:SetParent(nil, true)
		self.modelUnit:DestroyUnit(true, true, true)
		EndSample()
	end

	self.modelUnit = nil
end

M.DestroyCachedModel = function(self, cachedModel)
	if gCS.LuaUtils.IsBaseUnitValid(cachedModel.unit) then
		gCS.PauseManager.Instance:ProessUIModelShow(false, cachedModel.unit)
		cachedModel.unit.PlayerObj:SetParent(nil, true)
		cachedModel.unit:DestroyUnit(true, true, true)
	end
end

M.DestroyCachedModels = function(self)
	if #self.cachedModels <= 0 then
		LogLoadTimeline("phase=ModelCacheClear size=%d", #self.cachedModels)
	end

	for _, cachedModel in ipairs(self.cachedModels) do
		self.DestroyCachedModel(self, cachedModel)
	end

	self.cachedModels = {}
end

M.TakeCachedModel = function(self, tid)
	for i = #self.cachedModels, 1, -1 do
		local cachedModel = self.cachedModels[i]

		if cachedModel.tid ~= tid then
			table.remove(self.cachedModels, i)

			if gCS.LuaUtils.IsBaseUnitValid(cachedModel.unit) then
				LogLoadTimeline("phase=ModelCacheHit tid=%s remaining=%d capacity=%d", tostring(tid), #self.cachedModels, HISTORY_CACHE_CAPACITY)

				return cachedModel.unit
			end

			LogLoadTimeline("phase=ModelCacheInvalid tid=%s remaining=%d capacity=%d", tostring(tid), #self.cachedModels, HISTORY_CACHE_CAPACITY)

			return nil
		end
	end

	LogLoadTimeline("phase=ModelCacheMiss tid=%s size=%d capacity=%d", tostring(tid), #self.cachedModels, HISTORY_CACHE_CAPACITY)
end

M.CacheCurrentModel = function(self, tid)
	if not self.modelUnit or not gCS.LuaUtils.IsBaseUnitValid(self.modelUnit) then
		self.modelUnit = nil

		return
	end

	gCS.SceneDataMgr.UIUnitManager:RemoveUnit(self.modelUnit.Pid)
	self.modelUnit.PlayerObj.gameObject:SetActive(false)
	table.insert(self.cachedModels, {
		tid = tid,
		unit = self.modelUnit
	})

	if HISTORY_CACHE_CAPACITY >= #self.cachedModels then
		local evictedModel = table.remove(self.cachedModels, 1)

		LogLoadTimeline("phase=ModelCacheEvict tid=%s size=%d capacity=%d", tostring(evictedModel.tid), #self.cachedModels, HISTORY_CACHE_CAPACITY)
		self.DestroyCachedModel(self, evictedModel)
	end

	LogLoadTimeline("phase=ModelCacheStore tid=%s size=%d capacity=%d", tostring(tid), #self.cachedModels, HISTORY_CACHE_CAPACITY)

	self.modelUnit = nil
end

M.IsCurrentModel = function(self, unit, tid, loadIndex)
	return self.tid ~= tid and self.modelLoadCounts[tid] ~= loadIndex and self.modelUnit ~= unit and gCS.LuaUtils.IsBaseUnitValid(unit)
end

M.ShowModelRenderer = function(self, unit, tid, loadIndex)
	if not self.IsCurrentModel(self, unit, tid, loadIndex) then
		return
	end

	UnitModelManager.HideOrShowAllRender(unit, true, true)
	LogLoadTimeline("phase=ModelRenderEnabled tid=%s loadIndex=%d", tostring(tid), loadIndex)
	self.SetModelReady(self, tid, loadIndex)
end

M.PlayAndShowModel = function(self, unit, tid, loadIndex, animancers)
	if not self.IsCurrentModel(self, unit, tid, loadIndex) then
		return
	end

	local animationPlayTime = GetHighResolutionTimestamp()

	self.PlayAnimation(self)
	LogLoadTimeline("phase=AnimationPlayCall tid=%s loadIndex=%d callMs=%.3f", tostring(tid), loadIndex, GetHighResolutionCostMs(animationPlayTime))

	for i = 0, animancers.Length - 1 do
		animancers[i]:SendMessage("Evaluate")
	end

	LogLoadTimeline("phase=AnimationPoseEvaluated tid=%s loadIndex=%d", tostring(tid), loadIndex)
	self.ShowModelRenderer(self, unit, tid, loadIndex)
end

M.ShowModelUnit = function(self, unit, tid, loadIndex)
	self.modelUnit = unit

	UnitModelManager.HideOrShowAllRender(unit, false, true)
	unit.PlayerObj.gameObject:SetActive(true)
	UnitModelManager.SetAnimancerEnabled(unit, true)

	local animancers = unit.PlayerObj:GetComponentsInChildren(typeof(Animancer.AnimancerComponent), true)

	for i = 0, animancers.Length - 1 do
		LX6.Utils.LuaUtils.SetAnimancerPlayableSpeed(animancers[i], 1)
	end

	gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(unit.PlayerObj)

	unit.PlayerObj.transform.localScale = Vector3.one
	self.isOne = true

	gCS.SceneDataMgr.UIUnitManager:AddUnit(unit.Pid, unit)
	gCS.LuaUtils.ForceSetPlayerTransform(unit.ModelSlot.transform)
	gCS.LuaUtils.ForceSetPlayerPid(unit.Pid)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	gCS.PauseManager.Instance:ProessUIModelShow(true, unit)
	gCS.LuaUtils.SetUIUnitBindItemListLod(unit)
	gCS.LuaUtils.SetStreamingMipmapsMaxFileIORequests(false)
	LogLoadTimeline("phase=ModelRenderHidden tid=%s loadIndex=%d", tostring(tid), loadIndex)

	if not gCS.AnimationManager.HasAnimatorClip(unit, 6001, 66) then
		LogLoadTimeline("phase=AnimationUnavailable tid=%s loadIndex=%d reason=clip_unavailable", tostring(tid), loadIndex)
		self.ShowModelRenderer(self, unit, tid, loadIndex)

		return
	end

	if gCS.AnimationManager.isLoadedClip(unit, 6001, 66) then
		LogLoadTimeline("phase=AnimationClipReady tid=%s loadIndex=%d cached=true", tostring(tid), loadIndex)
		self.PlayAndShowModel(self, unit, tid, loadIndex, animancers)

		return
	end

	LogLoadTimeline("phase=AnimationClipLoadBegin tid=%s loadIndex=%d", tostring(tid), loadIndex)

	self.animationLoadCor = coroutine.start(function ()
		while self:IsCurrentModel(unit, tid, loadIndex) and not gCS.AnimationManager.isLoadedClip(unit, 6001, 66) do
			coroutine.step()
		end

		self.animationLoadCor = nil

		if not self:IsCurrentModel(unit, tid, loadIndex) then
			return
		end

		LogLoadTimeline("phase=AnimationClipReady tid=%s loadIndex=%d cached=false", tostring(tid), loadIndex)
		self:PlayAndShowModel(unit, tid, loadIndex, animancers)
	end)

	gCS.AnimationManager.StartLoad(unit, 6001, 66, nil, false)
end

M.LoadModel = function(self, tid, modelReadyCallback)
	if modelReadyCallback then
		self.modelReadyCallback = modelReadyCallback
	end

	if self.tid ~= tid then
		self.TryNotifyModelReady(self)

		return
	end

	local oldTid = self.tid
	self.tid = tid

	if self.animatorPlayCor then
		coroutine.stop(self.animatorPlayCor)

		self.animatorPlayCor = nil
	end

	if self.animationLoadCor then
		coroutine.stop(self.animationLoadCor)

		self.animationLoadCor = nil
	end

	if tid ~= nil or tid ~= 0 then
		self.bindData.model = {
			["\\xd4\\xd4\r\\xf5"] = 0
		}

		return
	end

	local loadStartTime = GetLoadTimestamp()
	local loadIndex = (self.modelLoadCounts[tid] or 0) + 1
	self.modelLoadCounts[tid] = loadIndex
	local isFirstLoad = loadIndex ~= 1
	self.wrapperReady = false
	self.modelReady = false

	LogLoadTimeline("phase=SwitchBegin tid=%s oldTid=%s loadIndex=%d isFirstLoad=%s", tostring(tid), tostring(oldTid), loadIndex, tostring(isFirstLoad))
	BeginSample("UrbanAbilityModelViewer.LoadModel.Sync")

	local cachedModel = self:TakeCachedModel(tid)

	self:CacheCurrentModel(oldTid)

	self.cfg = self:GetUIModelCfg()
	local agentId = FightSpiritConfig.GetConfig(tid).AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local characterUIModelId = tonumber(self.cfg and self.cfg.CharacterUIModelId) or 0
	local modelId = characterUIModelId <= 0 and characterUIModelId or agentConfig and agentConfig.GeneralModelId or 0

	if gSpiritManager.isWeatherTest then
		print_debug("SetXuWeiWeatherState", self.tid % 4 + 7)
		gCS.GuiUtils.SetXuWeiWeatherState(true, self.tid % 4 + 7)
	elseif self.cfg then
		gCS.GuiUtils.SetXuWeiWeatherState(true, self.cfg.WeatherIndex)
	end

	gCS.LuaUtils.SetStreamingMipmapsMaxFileIORequests(true)
	self.LoadRootWrapper(self, loadIndex, isFirstLoad)
	self.LoadScenePrefab(self, loadIndex, isFirstLoad)

	if cachedModel then
		LogLoadTimeline("phase=ModelLoaded tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.2f cacheHit=true", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000)
		self.ShowModelUnit(self, cachedModel, tid, loadIndex)
		EndSample()
		LogLoadTimeline("phase=SyncEnd tid=%s loadIndex=%d isFirstLoad=%s costMs=%.2f", tostring(tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000)

		return
	end

	local modelInstantiateStartTime, animationLoadStartTime = nil
	local modelsData = {
		["\\x963.0j\\x98m\\xd8.\\xaf\\xab"] = true,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		modelId = modelId,
		otherData = {
			["g\\xe5)\\xef;.\\xdad2\\xf3J\\x9fK\\xc9\\xe8"] = true,
			["\\xf2\\x94\\xf8=\\xf2\\xe5\\x86\\xc1\\x8d/8"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			SubType = tid,
			cardId = characterUIModelId ~= 0 and tid or nil
		},
		beforeLoadCallback = function (C_BaseUnit)
			UnitModelManager.HideOrShowAllRender(C_BaseUnit, false, true)

			if modelInstantiateStartTime then
				LogLoadTimeline("phase=ModelUnitCreated tid=%s loadIndex=%d unitCreateMs=%.3f", tostring(tid), loadIndex, GetHighResolutionCostMs(modelInstantiateStartTime))
			end

			animationLoadStartTime = GetLoadTimestamp()
			local animationRequestStartTime = GetHighResolutionTimestamp()
			C_BaseUnit.State.ActionGroupId = 66

			gCS.ActionManager.SetLoadPlayAction(C_BaseUnit, gUtils:GetActionKey(6001, 66, false), 999999, 0)
			LogLoadTimeline("phase=AnimationLoadRequested tid=%s loadIndex=%d requestMs=%.3f", tostring(tid), loadIndex, GetHighResolutionCostMs(animationRequestStartTime))
		end,
		callback = function (C_BaseUnit)
			if loadStartTime then
				LogLoadTimeline("phase=ModelLoaded tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.2f", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000)
			end

			if animationLoadStartTime then
				LogLoadTimeline("phase=AnimationLoadReady tid=%s loadIndex=%d pipelineMs=%.2f", tostring(tid), loadIndex, (Time.realtimeSinceStartup - animationLoadStartTime) * 1000)
			end

			BeginSample("UrbanAbilityModelViewer.ModelLoadedCallback")

			if tid == self.tid or self.modelLoadCounts[tid] == loadIndex then
				C_BaseUnit:DestroyUnit(true)
				EndSample()

				return
			end

			self:ShowModelUnit(C_BaseUnit, tid, loadIndex)
			EndSample()
		end
	}
	modelInstantiateStartTime = GetHighResolutionTimestamp()

	LogLoadTimeline("phase=ModelLoadBegin tid=%s loadIndex=%d modelId=%s", tostring(tid), loadIndex, tostring(modelId))

	self.bindData.model1 = modelsData

	LogLoadTimeline("phase=ModelInstantiateCall tid=%s loadIndex=%d callMs=%.3f", tostring(tid), loadIndex, GetHighResolutionCostMs(modelInstantiateStartTime))
	EndSample()

	if loadStartTime then
		LogLoadTimeline("phase=SyncEnd tid=%s loadIndex=%d isFirstLoad=%s costMs=%.2f", tostring(tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000)
	end
end

M.PlayAnimation = function(self)
	local cfg = self.cfg

	if self.animatorPlayCor then
		coroutine.stop(self.animatorPlayCor)

		self.animatorPlayCor = nil
	end

	gCS.AnimationManager.AnimatorPlay(self.modelUnit, 6001, 66, 0, 0)

	if cfg then
		self.animatorPlayCor = coroutine.start(function ()
			coroutine.wait(cfg.IdleDuration)
			gCS.AnimationManager.AnimatorPlay(self.modelUnit, 6002, 66, 0.5, 0)
			coroutine.wait(cfg.LoopDuration)

			self.animatorPlayCor = nil

			self:PlayAnimation()
		end)
	end
end

M.ReleaseScene = function(self, prefab, loadOp)
	if prefab and not gCS.LuaUtils.IsNull(prefab) then
		GameObject.Destroy(prefab)
	end

	gResourceManager:UnloadAssetLoadOp(loadOp)
end

M.DestroyCurrentScene = function(self)
	self.ReleaseScene(self, self.scenePrefab, self.scenePrefabOp)

	self.scenePrefab = nil
	self.scenePrefabOp = nil
	self.scenePrefabPath = nil
end

M.DestroyCachedScene = function(self, cachedScene)
	self.ReleaseScene(self, cachedScene.prefab, cachedScene.loadOp)
end

M.DestroyCachedScenes = function(self)
	if #self.cachedScenes <= 0 then
		LogLoadTimeline("phase=SceneCacheClear size=%d", #self.cachedScenes)
	end

	for _, cachedScene in ipairs(self.cachedScenes) do
		self.DestroyCachedScene(self, cachedScene)
	end

	self.cachedScenes = {}
end

M.TakeCachedScene = function(self, path)
	for i = #self.cachedScenes, 1, -1 do
		local cachedScene = self.cachedScenes[i]

		if cachedScene.path ~= path then
			table.remove(self.cachedScenes, i)

			if cachedScene.prefab and not gCS.LuaUtils.IsNull(cachedScene.prefab) then
				LogLoadTimeline("phase=SceneCacheHit path=%s remaining=%d capacity=%d", path, #self.cachedScenes, HISTORY_CACHE_CAPACITY)

				return cachedScene
			end

			LogLoadTimeline("phase=SceneCacheInvalid path=%s remaining=%d capacity=%d", path, #self.cachedScenes, HISTORY_CACHE_CAPACITY)
			self.DestroyCachedScene(self, cachedScene)

			return nil
		end
	end

	LogLoadTimeline("phase=SceneCacheMiss path=%s size=%d capacity=%d", path, #self.cachedScenes, HISTORY_CACHE_CAPACITY)
end

M.CacheCurrentScene = function(self)
	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		self.scenePrefab.gameObject:SetActive(false)
		table.insert(self.cachedScenes, {
			path = self.scenePrefabPath,
			prefab = self.scenePrefab,
			loadOp = self.scenePrefabOp
		})

		if HISTORY_CACHE_CAPACITY >= #self.cachedScenes then
			local evictedScene = table.remove(self.cachedScenes, 1)

			LogLoadTimeline("phase=SceneCacheEvict path=%s size=%d capacity=%d", evictedScene.path, #self.cachedScenes, HISTORY_CACHE_CAPACITY)
			self.DestroyCachedScene(self, evictedScene)
		end

		LogLoadTimeline("phase=SceneCacheStore path=%s size=%d capacity=%d", self.scenePrefabPath, #self.cachedScenes, HISTORY_CACHE_CAPACITY)

		self.scenePrefab = nil
		self.scenePrefabOp = nil
		self.scenePrefabPath = nil

		return
	end

	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	self.scenePrefabOp = nil
	self.scenePrefabPath = nil
end

M.LoadScenePrefab = function(self, loadIndex, isFirstLoad)
	local cfg = self.cfg

	if not cfg then
		return
	end

	local path = cfg.SceneResPath

	if gSpiritManager.isWeatherTest then
		path = "Res/SGUI/Panel/UrbanAbility/Edit/lky/prefab/sc_lky_beijing.prefab"
	end

	local restoreStartTime = GetHighResolutionTimestamp()
	local tid = self.tid

	if self.scenePrefabPath ~= path and self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		self.scenePrefab.gameObject:SetActive(true)
		LogLoadTimeline("phase=SceneReady tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.3f path=%s cacheHit=true", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), GetHighResolutionCostMs(restoreStartTime), path)

		return
	end

	local cachedScene = self.TakeCachedScene(self, path)

	self.CacheCurrentScene(self)

	if cachedScene then
		self.scenePrefab = cachedScene.prefab
		self.scenePrefabOp = cachedScene.loadOp
		self.scenePrefabPath = path

		self:SetParentAndReset(self.scenePrefab.gameObject.transform, self.bindData.sceneObj)
		self.scenePrefab.gameObject:SetActive(true)
		LogLoadTimeline("phase=SceneReady tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.3f path=%s cacheHit=true", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), GetHighResolutionCostMs(restoreStartTime), path)

		return
	end

	local loadStartTime = GetLoadTimestamp()
	self.scenePrefabPath = path

	LogLoadTimeline("phase=SceneLoadBegin tid=%s loadIndex=%d isFirstLoad=%s path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), path)

	slot9 = gResourceManager
	self.scenePrefabOp = slot9:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		if not loadOp or not loadOp.asset or path == self.scenePrefabPath or tid == self.tid or self.modelLoadCounts[tid] == loadIndex then
			return
		end

		local assetLoadedTime = GetLoadTimestamp()

		if loadStartTime and assetLoadedTime then
			LogLoadTimeline("phase=SceneAssetLoaded tid=%s loadIndex=%d isFirstLoad=%s loadMs=%.2f path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), (assetLoadedTime - loadStartTime) * 1000, path)
		end

		BeginSample("UrbanAbilityModelViewer.SceneLoadedCallback")

		local instantiateStartTime = GetHighResolutionTimestamp()
		local scenePrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)

		LogLoadTimeline("phase=SceneInstantiated tid=%s loadIndex=%d isFirstLoad=%s instantiateMs=%.3f path=%s", tostring(tid), loadIndex, tostring(isFirstLoad), GetHighResolutionCostMs(instantiateStartTime), path)

		scenePrefab.gameObject.name = "ScenePrefab"

		self:SetParentAndReset(scenePrefab.gameObject.transform, self.bindData.sceneObj)

		self.scenePrefab = scenePrefab

		EndSample()

		if loadStartTime then
			LogLoadTimeline("phase=SceneReady tid=%s currentTid=%s loadIndex=%d isFirstLoad=%s totalMs=%.2f path=%s", tostring(tid), tostring(self.tid), loadIndex, tostring(isFirstLoad), (Time.realtimeSinceStartup - loadStartTime) * 1000, path)
		end
	end)
end

M.SetCameraPos = function(self)
	local cfg = self.cfg

	if cfg then
		if gSpiritManager.isWeatherTest then
			local rot = Quaternion.Euler(354.796295, 359.087799, 6.69771083e-09)

			self.bindData.camera.transform:SetLocalRotation(rot)
			self.bindData.camera.transform:SetLocalPosition(2.51399994, 0.671000004, -3.61400008)

			return
		end

		local rot = Quaternion.Euler(cfg.CameraRotation.x, cfg.CameraRotation.y, cfg.CameraRotation.z)

		self.bindData.camera.transform:SetLocalRotation(rot)
		self.bindData.camera.transform:SetLocalPosition(cfg.CameraPosition.x, cfg.CameraPosition.y, cfg.CameraPosition.z)
	end
end

M.GetUIModelCfg = function(self)
	for i = 0, LTConfig.FightSpiritUIModelConfig.count - 1 do
		local cfg = LTConfig.FightSpiritUIModelConfig.LoadAt(i)

		if self.tid ~= cfg.SpiritId then
			return cfg
		end
	end
end
