-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosCultivationMainPanelStore.lua
-- Decompiled from: 01460_ChaosCultivationMainPanelStore.lua_56f7f3bcf7d5.luajit

C_ChaosCultivationMainPanelStore = DefClass("C_ChaosCultivationMainPanelStore", C_ChaosCultivationMainPanelStore, C_StoreGroup)
GroupName2Class.ChaosCultivationMainPanelStore = C_ChaosCultivationMainPanelStore
local M = C_ChaosCultivationMainPanelStore
M.EquipType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["X-yB"] = 1,
	["Y#pK"] = 2,
	["(I\\x9d\\x8b\\x8dU"] = 4
}

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.bindData.bgTextCtrl = self.bindData.tabRect.selectedIndex

	if self.bindData.tabRect.selectedIndex ~= 0 then
		self.chaosInfo = store
	end

	store.OnShow(store, nil, {
		curChaosData = self.curChaosData,
		uRawImage = self.bindData.uRawImage,
		uCameraRenderImage = self.bindData.uCameraRenderImage,
		parent = self,
		curChaosId = self.curChaosId,
		belong = self.belong
	})
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnShow = function(self, panelId, data)
	self.curChaosId = ulong.zero
	self.belong = self.EquipType.Camp
	self.bindData.tabRect.selectedIndex = 0

	gCS.GuiUtils.SetXuWeiWeatherState(true, 6)
end

M.OnDestroy = function(self)
	gCS.GuiUtils.SetXuWeiWeatherState(false)
end

M.OnClose = function(self)
end

M.ReleaseModel = function(self, index)
	if self.loadModelTimer then
		self.loadModelTimer:Stop()

		self.loadModelTimer = nil
	end

	if self.modelUnit and (not index or index ~= 1) then
		self.modelUnit:DestroyUnit(true)

		self.modelUnit = nil
	end

	if self.modelUnit2 and (not index or index ~= 2) then
		self.modelUnit2:DestroyUnit(true)

		self.modelUnit2 = nil
	end
end

M.ChangeChaosModelVisible = function(self, show)
	self.bindData.modelRoot.gameObject:SetActive(show)
	self.bindData.mirrorRoot.gameObject:SetActive(show)
end

M.RefreshChaosModel = function(self, targetId)
	if self.bindData.tabRect.selectedIndex > 2 then
		return
	end

	self.bindData.modelRoot.gameObject:SetActive(true)
	self.bindData.mirrorRoot.gameObject:SetActive(true)

	local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(targetId)
	local agentConfig = LTConfig.AgentConfig.GetConfig(cfg.AgentId)

	if not agentConfig then
		self.OnNoModelCanShow(self)

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

		if times ~= 1 then
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

M.LoadFirstModel = function(self, modelId, agentId, agentConfig)
	local cb = function(C_BaseUnit)
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
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		modelId = modelId,
		callback = cb,
		otherData = {
			["\\xd0\\xc87+\\xe2"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			AgentId = agentId,
			SubType = agentId,
			agentBornWithWeaponId = agentConfig.InitWeaponId
		}
	}

	gStoreBindMethod:BindModel(self.bindData.modelRoot, modelData)
end

M.CheckAndPlayAnimation = function(self, agentConfig)
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

M.LoadSecondMirrorModel = function(self, modelId, agentId, agentConfig)
	local cb2 = function(C_BaseUnit2)
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
		["\\x96':l\\xbb@\\xda>\\xa4\\xbe"] = false,
		["lc\\xbfcC\\xbf\\xd4FispK"] = 0,
		modelId = modelId,
		callback = cb2,
		otherData = {
			["\\xd0\\xc87+\\xe2"] = true,
			["\\x8a=7w\\x8al\\xd63\\xaf\\xb5"] = true,
			AgentId = agentId,
			SubType = agentId,
			agentBornWithWeaponId = agentConfig.InitWeaponId
		}
	}

	if self.STATE_EnableOnce then
		gStoreBindMethod:BindModel(self.bindData.mirrorRoot, modelData2)
	end
end

M.OnNoModelCanShow = function(self)
end
