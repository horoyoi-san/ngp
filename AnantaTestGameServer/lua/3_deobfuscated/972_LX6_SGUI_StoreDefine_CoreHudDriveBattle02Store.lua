C_CoreHudDriveBattle02Store = DefClass("C_CoreHudDriveBattle02Store", C_CoreHudDriveBattle02Store, C_StoreGroup)
GroupName2Class.CoreHudDriveBattle02Store = C_CoreHudDriveBattle02Store
local M = C_CoreHudDriveBattle02Store

function M:ctor()
	return
end

function M:OnAwake()
	self.started = false
end

function M:OnEnable()
	return
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self.started = nil
end

function M:OnGroupEnable()
	self:InitVehicleUnitAttackBtns()
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.IsMainDrive = IsMainDrive
	self.IsPhoneMode = IsPhoneMode

	if self.started then
		self:RefreshButtonState()
	end
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:InitVehicleUnitAttackBtns()
	self.specialSkillStore = self:GetStoreByWidget(self.bindData.specialSkill)
	self.normalSkillStore = self:GetStoreByWidget(self.bindData.normalSkill)
	self.bindData.specialSkill.luaPress = self:CreateActionWithArgs("OnVehicleSpecialBtnDown", 2)
	self.bindData.specialSkill.luaRelease = self:CreateActionWithArgs("OnVehicleSpecialBtnUp", 2)
	self.bindData.specialSkill.luaClick = self:CreateActionWithArgs("OnVehicleSpecialBtnClick", 2)
	self.bindData.specialSkill.luaBeginLongPress = self:CreateActionWithArgs("OnVehicleSpecialBtnLongPressBegin", 2)
	self.bindData.specialSkill.luaLongPress = self:CreateActionWithArgs("OnVehicleSpecialBtnLongPress", 2)
	self.bindData.specialSkill.luaEndLongPress = self:CreateActionWithArgs("OnVehicleSpecialBtnLongPressEnd", 2)
	self.bindData.normalSkill.luaPress = self:CreateActionWithArgs("OnVehicleNormalBtnDown", 1)
	self.bindData.normalSkill.luaRelease = self:CreateActionWithArgs("OnVehicleNormalBtnUp", 1)
	self.bindData.normalSkill.luaClick = self:CreateActionWithArgs("OnVehicleNormalBtnClick", 1)
	self.bindData.normalSkill.luaBeginLongPress = self:CreateActionWithArgs("OnVehicleNormalBtnLongPressBegin", 1)
	self.bindData.normalSkill.luaLongPress = self:CreateActionWithArgs("OnVehicleNormalBtnLongPress", 1)
	self.bindData.normalSkill.luaEndLongPress = self:CreateActionWithArgs("OnVehicleNormalBtnLongPressEnd", 1)
end

function M:SetShowVehicleUnitAttackBtns(enable)
	self.showVehicleAttackBtnDefaNormal = enable
end

function M:OnVehicleSpecialBtnDown(data)
	self:OnVehicleSpecialBtnLongPressBegin(data)
end

function M:OnVehicleSpecialBtnUp(data)
	self:OnVehicleSpecialBtnLongPressEnd(data)
end

function M:OnVehicleSpecialBtnClick(data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

function M:OnVehicleSpecialBtnLongPressBegin(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

function M:OnVehicleSpecialBtnLongPress(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

function M:OnVehicleSpecialBtnLongPressEnd(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
end

function M:OnVehicleNormalBtnDown(data)
	self:OnVehicleNormalBtnLongPressBegin(data)
end

function M:OnVehicleNormalBtnUp(data)
	self:OnVehicleNormalBtnLongPressEnd(data)
end

function M:OnVehicleNormalBtnClick(data)
	gBattleMgr.characterControlPanel:OnMergeBtnClick(data)
end

function M:OnVehicleNormalBtnLongPressBegin(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressBegin(data)
end

function M:OnVehicleNormalBtnLongPress(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPress(data)
end

function M:OnVehicleNormalBtnLongPressEnd(data)
	gBattleMgr.characterControlPanel:OnMergeBtnLongPressEnd(data)
end

function M:SetBtnVisible(btnStore, visible)
	gStoreButtonMgr:SetButtonVisibleBase(btnStore, visible)
end

function M:SetBtnInteractable(btnStore, interactable)
	gStoreButtonMgr:SetButtonInteractableBase(btnStore, interactable)
end

function M:SetBtnControl(btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

function M:SetBtnActive(btn, active)
	if btn then
		btn:SetActive(active)
	end
end

function M:RefreshButtonState()
	local vehicleGameplayConfig = nil

	if self.vehicleUnitAgentCfg then
		vehicleGameplayConfig = LTConfig.AgentAIBehaviorSetsVehicleGameplayConfig.GetConfig(self.vehicleUnitAgentCfg.VehicleGameplay)
	end

	if vehicleGameplayConfig then
		if vehicleGameplayConfig.VehicleChangeCommonSkill and vehicleGameplayConfig.VehicleChangeCommonSkill > 0 then
			self:SetBtnActive(self.bindData.normalSkill, true)
		else
			self:SetBtnActive(self.bindData.normalSkill, false)
		end

		if vehicleGameplayConfig.VehicleChangeActiveSkill and vehicleGameplayConfig.VehicleChangeActiveSkill > 0 then
			self:SetBtnActive(self.bindData.specialSkill, true)
		else
			self:SetBtnActive(self.bindData.specialSkill, false)
		end
	else
		self:SetBtnActive(self.bindData.normalSkill, false)
		self:SetBtnActive(self.bindData.specialSkill, false)
	end
end

function M:OnUpdate()
	self:UpdateCountDown()
end

function M:BindAgentConfig(agentConfigID)
	self.vehicleUnitAgentCfg = LTConfig.AgentConfig.GetConfig(agentConfigID)

	self:RefreshButtonState()
end

function M:RefreshCountDown(enable, startTime, duration)
	if enable then
		self.duration = duration
		self.endTime = startTime + duration
		self.bindData.countDownFill1 = 1
		self.bindData.countDownFill2 = 1
	end
end

function M:UpdateCountDown()
	local cur = Time.unscaledTime
	local fill = (self.endTime - cur) / self.duration
	self.bindData.countDownFill1 = fill
	self.bindData.countDownFill2 = fill
end
