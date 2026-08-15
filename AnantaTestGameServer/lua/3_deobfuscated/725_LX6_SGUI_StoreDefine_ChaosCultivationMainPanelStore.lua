C_ChaosCultivationMainPanelStore = DefClass("C_ChaosCultivationMainPanelStore", C_ChaosCultivationMainPanelStore, C_StoreGroup)
GroupName2Class.ChaosCultivationMainPanelStore = C_ChaosCultivationMainPanelStore
local M = C_ChaosCultivationMainPanelStore
M.EquipType = {
	Weapon = 3,
	Body = 1,
	Camp = 2,
	Talent = 4
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
end

function M:OnRenderTab(_, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.bindData.bgTextCtrl = self.bindData.tabRect.selectedIndex

	if self.bindData.tabRect.selectedIndex == 0 then
		self.chaosInfo = store
	end

	store:OnShow(nil, {
		curChaosData = self.curChaosData,
		uRawImage = self.bindData.uRawImage,
		uCameraRenderImage = self.bindData.uCameraRenderImage,
		parent = self,
		curChaosId = self.curChaosId,
		belong = self.belong
	})
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnShow(panelId, data)
	self.curChaosId = ulong.zero
	self.belong = self.EquipType.Camp
	self.bindData.tabRect.selectedIndex = 0

	gCS.GuiUtils.SetXuWeiWeatherState(true, 6)
end

function M:OnDestroy()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

function M:OnClose()
	return
end

function M:ReleaseModel(index)
	if self.loadModelTimer then
		self.loadModelTimer:Stop()

		self.loadModelTimer = nil
	end

	if self.modelUnit and (not index or index == 1) then
		self.modelUnit:DestroyUnit(true)

		self.modelUnit = nil
	end

	if self.modelUnit2 and (not index or index == 2) then
		self.modelUnit2:DestroyUnit(true)

		self.modelUnit2 = nil
	end
end

function M:ChangeChaosModelVisible(show)
	self.bindData.modelRoot.gameObject:SetActive(show)
	self.bindData.mirrorRoot.gameObject:SetActive(show)
end

function M:RefreshChaosModel(targetId)
	if self.bindData.tabRect.selectedIndex >= 2 then
		return
	end

	self.bindData.modelRoot.gameObject:SetActive(true)
	self.bindData.mirrorRoot.gameObject:SetActive(true)

	local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(targetId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(cfg.AgentId)

	if not agentConfig then
		self:OnNoModelCanShow()

		return
	end

	local agentId = cfg.AgentId
	local modelId = agentConfig.GeneralModelId
	local times = 1
	self.isModel1Loaded = false
	self.isModel2Loaded = false
	self.currentAgentConfig = agentConfig

	if self.loadModelTimer then
		self.loadModelTimer:Stop()

		self.loadModelTimer = nil
	end

	self.loadModelTimer = FrameTimer.New(function ()
		if not self.STATE_EnableOnce then
			return
		end

		if times == 1 then
			self:LoadFirstModel(modelId, agentId, agentConfig)

			times = times + 1
		else
			self:LoadSecondMirrorModel(modelId, agentId, agentConfig)

			if self.loadModelTimer then
				self.loadModelTimer = nil
			end
		end
	end, 2, 2)

	self.loadModelTimer:Start()
end

function M:LoadFirstModel(modelId, agentId, agentConfig)
	local function cb(C_BaseUnit)
		self:ReleaseModel(1)
		LX6.Units.UnitModelManager.SetAnimancerEnabled(C_BaseUnit, true)

		C_BaseUnit.PlayerObj.transform.localScale = Vector3.one
		C_BaseUnit.PlayerObj.transform.localEulerAngles = Vector3.New(0, 155, 0)
		C_BaseUnit.PlayerObj.transform.localPosition = Vector3.New(0, 1, 0)

		gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit.PlayerObj)
		gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit.Pid, C_BaseUnit)

		self.modelUnit = C_BaseUnit
		self.bindData.uCameraRenderImage.targetRawImage = self.bindData.uRawImage
		self.bindData.uRawImage.texture = self.bindData.uCameraRenderImage.targetRawImage.texture
		self.isModel1Loaded = true

		self:CheckAndPlayAnimation(agentConfig)
	end

	local modelData = {
		isSetFacing = false,
		customFacing = 0,
		modelId = modelId,
		callback = cb,
		otherData = {
			isChaos = true,
			uiShowModel = true,
			AgentId = agentId,
			SubType = agentId,
			agentBornWithWeaponId = agentConfig.InitWeaponId
		}
	}

	gStoreBindMethod:BindModel(self.bindData.modelRoot, modelData)
end

function M:CheckAndPlayAnimation(agentConfig)
	if self.isModel1Loaded and self.isModel2Loaded then
		if self.modelUnit then
			gClientUtils.PlaySingleAction(self.modelUnit, 1001, agentConfig.ActionGroup, 999999)
		end

		if self.modelUnit2 then
			gClientUtils.PlaySingleAction(self.modelUnit2, 1001, agentConfig.ActionGroup, 999999)
		end

		self.isModel1Loaded = false
		self.isModel2Loaded = false
	end
end

function M:LoadSecondMirrorModel(modelId, agentId, agentConfig)
	local function cb2(C_BaseUnit2)
		self:ReleaseModel(2)
		LX6.Units.UnitModelManager.SetAnimancerEnabled(C_BaseUnit2, true)

		C_BaseUnit2.PlayerObj.transform.localScale = Vector3.New(1, -1, 1)
		C_BaseUnit2.PlayerObj.transform.localEulerAngles = Vector3.New(0, 155, 0)
		C_BaseUnit2.PlayerObj.transform.localPosition = Vector3.New(0, 1, 0)

		gCS.SceneDataMgr.UIUnitManager:AddUnitShadowRequest(C_BaseUnit2.PlayerObj)
		gCS.SceneDataMgr.UIUnitManager:AddUnit(C_BaseUnit2.Pid, C_BaseUnit2)

		self.modelUnit2 = C_BaseUnit2
		self.bindData.uCameraRenderImageMirror.targetRawImage = self.bindData.uRawImageMirror
		self.bindData.uRawImageMirror.texture = self.bindData.uCameraRenderImageMirror.targetRawImage.texture
		self.isModel2Loaded = true

		self:CheckAndPlayAnimation(agentConfig)
	end

	local modelData2 = {
		isSetFacing = false,
		customFacing = 0,
		modelId = modelId,
		callback = cb2,
		otherData = {
			isChaos = true,
			uiShowModel = true,
			AgentId = agentId,
			SubType = agentId,
			agentBornWithWeaponId = agentConfig.InitWeaponId
		}
	}

	if self.STATE_EnableOnce then
		gStoreBindMethod:BindModel(self.bindData.mirrorRoot, modelData2)
	end
end

function M:OnNoModelCanShow()
	return
end
