local FightSpiritConfig = LTConfig.FightSpiritConfig
local UnitModelManager = LX6.Units.UnitModelManager
C_UrbanAbilityModelViewerStore = DefClass("C_UrbanAbilityModelViewerStore", C_UrbanAbilityModelViewerStore, C_StoreGroup)
GroupName2Class.UrbanAbilityModelViewerStore = C_UrbanAbilityModelViewerStore
local M = C_UrbanAbilityModelViewerStore

function M:ctor()
	self:OnInit()
end

function M:OnAwake()
	self:OnInit()

	self.scenePrefab = nil
end

function M:OnInit()
	self.tid = 0
	self.modelUnit = nil
	self.changeAni = "S_Vx_UrbanAbilityModelViewer_cut"
	self.isFirstOpen = true
end

function M:OnStart()
	gCS.SceneDataMgr.UIUnitManager:ClearShadowRequest()
	self.bindData.modelTrans.gameObject:SetParent(nil, true)
	self.bindData.modelTrans.gameObject:SetPosition(0, -2000, 0)
	self.bindData.modelTrans:SetLocalScale(1)
end

function M:OnDestroy()
	self.bindData.rawImage.texture:Release()

	if self.animatorPlayCor then
		coroutine.stop(self.animatorPlayCor)
	end

	self:DestroyUnit()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gCS.PauseManager.Instance:ProessUIModelShow(false)
	GameObject.Destroy(self.bindData.modelTrans.gameObject)

	local baikeStore = gStoreManager:GetStoreGroup("BaikeModelViewerStore")

	if baikeStore and baikeStore.STATE_EnableOnce then
		baikeStore:ResetCfg()
	end
end

function M:DestroyUnit()
	if self.modelUnit then
		self.modelUnit:DestroyUnit(true)

		self.modelUnit = nil
	end
end

function M:LoadModel(tid)
	if self.tid == tid then
		return
	end

	self.tid = tid

	if tid == nil or tid == 0 then
		self.bindData.model = {
			modelId = 0
		}

		return
	end

	self:DestroyUnit()

	if self.bindData.rawImage.texture and self.bindData.stillFrame.texture then
		gCS.LuaUtils.GraphicsBlit(self.bindData.rawImage.texture, self.bindData.stillFrame.texture)
	end

	if self.isFirstOpen then
		self.isFirstOpen = false
	else
		gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, self.changeAni)
	end

	self.cfg = self:GetUIModelCfg()

	self:SetCameraPos()

	local agentId = FightSpiritConfig.GetConfig(tid).AgentId
	local agentConfig = LTConfig.AgentConfig.GetConfig(agentId)
	local ModelId = agentConfig and agentConfig.GeneralModelId or 0

	if gSpiritManager.isWeatherTest then
		print_debug("SetXuWeiWeatherState", self.tid % 4 + 7)
		gCS.GuiUtils.SetXuWeiWeatherState(true, self.tid % 4 + 7)
	elseif self.cfg then
		gCS.GuiUtils.SetXuWeiWeatherState(true, self.cfg.WeatherIndex)
	end

	gResourceManager:UnloadAssetLoadOp(self.scenePrefabOp)

	if self.scenePrefab and not gCS.LuaUtils.IsNull(self.scenePrefab) then
		GameObject.Destroy(self.scenePrefab)

		self.scenePrefab = nil
	end

	self:LoadScenePrefab()

	local modelData = {
		ignoreLayer = true,
		customFacing = 0,
		isSetFacing = false,
		modelId = ModelId,
		otherData = {
			syncPlayerFashion = true,
			unitActionLoop = true,
			uiShowModel = true,
			SubType = tid,
			cardId = tid
		},
		callback = function (C_BaseUnit)
			if tid ~= self.tid then
				C_BaseUnit:DestroyUnit(true)

				return
			end

			self:DestroyUnit()

			self.modelUnit = C_BaseUnit

			UnitModelManager.SetAnimancerEnabled(C_BaseUnit, true)
			gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit.PlayerObj)

			C_BaseUnit.PlayerObj.transform.localScale = Vector3.one
			C_BaseUnit.State.ActionGroupId = 66
			self.isOne = true

			gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit.Pid, C_BaseUnit)
			self:PlayAnimation()
			LX6.Units.UnitModelManager.HideOrShowAllRender(self.modelUnit, true, true)
			gCS.LuaUtils.ForceSetPlayerTransform(self.modelUnit.ModelSlot.transform)
			gCS.PauseManager.Instance:ProessUIModelShow(false)
			gCS.PauseManager.Instance:ProessUIModelShow(true, C_BaseUnit)
			gCS.LuaUtils.SetUIUnitBindItemListLod(self.modelUnit)
		end
	}
	self.bindData.model1 = modelData
end

function M:PlayAnimation()
	local cfg = self.cfg

	if not cfg then
		return
	end

	if self.animatorPlayCor then
		coroutine.stop(self.animatorPlayCor)
	end

	self.animatorPlayCor = coroutine.start(function ()
		gCS.AnimationManager.AnimatorPlay(self.modelUnit, 6001, 66, 0, 0)
		coroutine.wait(cfg.IdleDuration)
		gCS.AnimationManager.AnimatorPlay(self.modelUnit, 6002, 66, 0.5, 0)
		coroutine.wait(cfg.LoopDuration)
		self:PlayAnimation()
	end)
end

function M:LoadScenePrefab()
	local cfg = self.cfg

	if not cfg then
		return
	end

	local path = cfg.SceneResPath

	if gSpiritManager.isWeatherTest then
		path = "Res/SGUI/Panel/UrbanAbility/Edit/lky/prefab/sc_lky_beijing.prefab"
	end

	self.scenePrefabOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.GameObject), function (loadOp)
		local scenePrefab = UnityEngine.GameObject.Instantiate(loadOp.asset)
		scenePrefab.gameObject.name = "ScenePrefab"

		scenePrefab.gameObject.transform:SetParent(self.bindData.sceneObj)
		scenePrefab.gameObject.transform:SetLocalPosition(Vector3.zero)
		scenePrefab.gameObject.transform:SetLocalScale(1)

		scenePrefab.gameObject.transform.localRotation = Quaternion.Euler(0, 0, 0)
		self.scenePrefab = scenePrefab
	end)
end

function M:SetCameraPos()
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

function M:GetUIModelCfg()
	for i = 0, LTConfig.FightSpiritUIModelConfig.count - 1 do
		local cfg = LTConfig.FightSpiritUIModelConfig.LoadAt(i)

		if self.tid == cfg.SpiritId then
			return cfg
		end
	end
end
