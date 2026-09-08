-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudDriveBattle02Store.lua
-- Decompiled from: 01489_CoreHudDriveBattle02Store.lua_6e7cf8acebe0.luajit

C_CoreHudDriveBattle02Store = DefClass("C_CoreHudDriveBattle02Store", C_CoreHudDriveBattle02Store, C_StoreGroup)
GroupName2Class.CoreHudDriveBattle02Store = C_CoreHudDriveBattle02Store
local M = C_CoreHudDriveBattle02Store

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.started = false
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.started = nil
end

M.OnGroupEnable = function(self)
	self.InitVehicleUnitAttackBtns(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.IsMainDrive = IsMainDrive
	self.IsPhoneMode = IsPhoneMode

	if self.started then
		self.RefreshButtonState(self)
	end
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitVehicleUnitAttackBtns = function(self)
	self.specialSkillStore = self.GetStoreByWidget(self, self.bindData.specialSkill)
	self.normalSkillStore = self.GetStoreByWidget(self, self.bindData.normalSkill)
	self.bindData.specialSkill.luaPress = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnDown", 2)
	self.bindData.specialSkill.luaRelease = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnUp", 2)
	self.bindData.specialSkill.luaClick = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnClick", 2)
	self.bindData.specialSkill.luaBeginLongPress = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnLongPressBegin", 2)
	self.bindData.specialSkill.luaLongPress = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnLongPress", 2)
	self.bindData.specialSkill.luaEndLongPress = self.CreateActionWithArgs(self, "OnVehicleSpecialBtnLongPressEnd", 2)
	self.bindData.normalSkill.luaPress = self.CreateActionWithArgs(self, "OnVehicleNormalBtnDown", 1)
	self.bindData.normalSkill.luaRelease = self.CreateActionWithArgs(self, "OnVehicleNormalBtnUp", 1)
	self.bindData.normalSkill.luaClick = self.CreateActionWithArgs(self, "OnVehicleNormalBtnClick", 1)
	self.bindData.normalSkill.luaBeginLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalBtnLongPressBegin", 1)
	self.bindData.normalSkill.luaLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalBtnLongPress", 1)
	self.bindData.normalSkill.luaEndLongPress = self.CreateActionWithArgs(self, "OnVehicleNormalBtnLongPressEnd", 1)
end

M.SetShowVehicleUnitAttackBtns = function(self, enable)
	self.showVehicleAttackBtnDefaNormal = enable
end

M.OnVehicleSpecialBtnDown = function(self, data)
	self.OnVehicleSpecialBtnLongPressBegin(self, data)
end

M.OnVehicleSpecialBtnUp = function(self, data)
	self.OnVehicleSpecialBtnLongPressEnd(self, data)
end

M.OnVehicleSpecialBtnClick = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

M.OnVehicleSpecialBtnLongPressBegin = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

M.OnVehicleSpecialBtnLongPress = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

M.OnVehicleSpecialBtnLongPressEnd = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
end

M.OnVehicleNormalBtnDown = function(self, data)
	self.OnVehicleNormalBtnLongPressBegin(self, data)
end

M.OnVehicleNormalBtnUp = function(self, data)
	self.OnVehicleNormalBtnLongPressEnd(self, data)
end

M.OnVehicleNormalBtnClick = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

M.OnVehicleNormalBtnLongPressBegin = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

M.OnVehicleNormalBtnLongPress = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

M.OnVehicleNormalBtnLongPressEnd = function(self, data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
end

M.SetBtnVisible = function(self, btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

M.SetBtnInteractable = function(self, btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.SetBtnActive = function(self, btn, active)
	if btn then
		btn.SetActive(btn, active)
	end
end

M.RefreshButtonState = function(self)
	local vehicleGameplayConfig = nil

	if self.vehicleUnitAgentCfg then
		vehicleGameplayConfig = LTConfig.AgentAIBehaviorSetsVehicleGameplayConfig.GetConfig(self.vehicleUnitAgentCfg.VehicleGameplay)
	end

	if vehicleGameplayConfig then
		if vehicleGameplayConfig.VehicleChangeCommonSkill and vehicleGameplayConfig.VehicleChangeCommonSkill <= 0 then
			self.SetBtnActive(self, self.bindData.normalSkill, true)
		else
			self.SetBtnActive(self, self.bindData.normalSkill, false)
		end

		if vehicleGameplayConfig.VehicleChangeActiveSkill and vehicleGameplayConfig.VehicleChangeActiveSkill <= 0 then
			self.SetBtnActive(self, self.bindData.specialSkill, true)
		else
			self.SetBtnActive(self, self.bindData.specialSkill, false)
		end
	else
		self.SetBtnActive(self, self.bindData.normalSkill, false)
		self.SetBtnActive(self, self.bindData.specialSkill, false)
	end
end

M.OnUpdate = function(self)
	self.UpdateCountDown(self)
end

M.BindAgentConfig = function(self, agentConfigID)
	self.vehicleUnitAgentCfg = LTConfig.AgentConfig.GetConfig(agentConfigID)

	self.RefreshButtonState(self)
end

M.RefreshCountDown = function(self, enable, startTime, duration)
	if enable then
		self.duration = duration
		self.endTime = startTime + duration
		self.bindData.countDownFill1 = 1
		self.bindData.countDownFill2 = 1
	end
end

M.UpdateCountDown = function(self)
	local cur = Time.unscaledTime
	local fill = (self.endTime - cur) / self.duration
	self.bindData.countDownFill1 = fill
	self.bindData.countDownFill2 = fill
end
