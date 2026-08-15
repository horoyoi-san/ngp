C_VaultGameplayPanelStore = DefClass("C_VaultGameplayPanelStore", C_VaultGameplayPanelStore, C_StoreGroup)
GroupName2Class.VaultGameplayPanelStore = C_VaultGameplayPanelStore
local M = C_VaultGameplayPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.pressure = 0
	self.drillAdvanceDisRate = 0.4
	self.logicAdvanceDis = 0
	self.performAdvanceDis = 0
	self.maxLogicAdvanceDis = 4
	self.maxOverPressureDistance = 2
	self.diskThickness = 2
	self.diskSpacing = 2
	self.totalDiskCount = 4
	self.maxAdvanceDis = (self.diskThickness + self.diskSpacing) * self.totalDiskCount
	self.currentDiskIndex = 1
	self.drillState = {
		overPressureDrill = 6,
		idle = 1,
		overDrill = 7,
		overPressure = 5,
		pressureDrilling = 3,
		drilling = 2,
		emptyDrilling = 4
	}
	self.inPressure = false
	self.pressureIncreaseRate = 0.3
	self.normalIncreaseRate = 0.1
	self.slowCoolRate = 0.02
	self.fastCoolRate = 0.1
	self.mouseMoveRate = 0.05
	self.robBandDrillShelf = 4
	self.currentDrillDis = self.diskThickness
	self.maxNormalPressureDis = 0.1
	self.currentNormalPressureDis = 0
	self.currentDrillState = self.drillState.idle
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.bindData.vxParAllWidget.gameObject:SetActive(false)
end

function M:OnClose()
	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overDrill)
end

function M:OnUpdate()
	if self.currentDrillState == self.drillState.drilling then
		if self.maxNormalPressureDis < self.currentNormalPressureDis then
			local rand = math.random()

			if rand > 0.5 then
				self.pressure = self.pressure + self.normalIncreaseRate * Time.deltaTime
			else
				self.pressure = self.pressure - self.normalIncreaseRate * Time.deltaTime
			end
		else
			self.pressure = self.pressure + self.normalIncreaseRate * Time.deltaTime
			self.currentNormalPressureDis = self.currentNormalPressureDis + self.normalIncreaseRate * Time.deltaTime
		end

		self.logicAdvanceDis = self.logicAdvanceDis + self.drillAdvanceDisRate * Time.deltaTime
		self.performAdvanceDis = self.performAdvanceDis + self.drillAdvanceDisRate * Time.deltaTime

		if self.currentDrillDis < self.performAdvanceDis then
			self.currentDrillDis = self.performAdvanceDis
		end

		local currentDiskStartDis = self:GetCurrentDiskStartDis()

		if self.currentDrillDis > currentDiskStartDis + self.diskThickness then
			self.currentDiskIndex = self.currentDiskIndex + 1
			self.currentDrillDis = self:GetCurrentDiskStartDis()

			if self.totalDiskCount < self.currentDiskIndex then
				self.currentDrillState = self.drillState.overDrill

				gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overDrill)
				gPanelManager:Close(gPanelId.VAULT_GAMEPLAY_PANEL)
			end
		end
	elseif self.currentDrillState == self.drillState.pressureDrilling then
		self.pressure = self.pressure + self.pressureIncreaseRate * Time.deltaTime
	elseif self.currentDrillState == self.drillState.overPressure then
		self.pressure = self.pressure - self.fastCoolRate * Time.deltaTime
	elseif self.currentDrillState == self.drillState.overPressureDrill then
		self.pressure = self.pressure - self.slowCoolRate * Time.deltaTime
	elseif self.currentDrillState == self.drillState.idle then
		self.pressure = self.pressure - self.fastCoolRate * Time.deltaTime
	elseif self.currentDrillState == self.drillState.overDrill then
		self.bindData.rootWidget.anim:Stop()
		self.bindData.vxParAllWidget.anim:Stop()
		self.bindData.vxZuanWidget.anim:Stop()

		return
	end

	if self.pressure > 1 then
		self.pressure = 1
		self.currentDrillState = self.drillState.overPressure

		gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.overPressure)
	elseif self.pressure < 0 then
		self.pressure = 0

		if self.currentDrillState == self.drillState.overPressure then
			self.currentDrillState = self.drillState.idle
		elseif self.currentDrillState == self.drillState.overPressureDrill then
			self.currentDrillState = self.drillState.drilling
		end
	end

	self:RefreshProcessBar()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.clickBtn.luaPress = self:CreateAction(self.OnClickBtnPress)
	self.bindData.clickBtn.luaRelease = self:CreateAction(self.OnClickBtnRelease)
	self.bindData.mouseMoveResponse.luaGamePadInputChanged = self:CreateAction(self.OnMouseMove)
end

function M:OnClickBtnPress()
	if self.currentDrillState == self.drillState.overPressure then
		self.currentDrillState = self.drillState.overPressureDrill
	elseif self.currentDrillState == self.drillState.idle then
		if self.logicAdvanceDis < self.currentDrillDis then
			self.currentDrillState = self.drillState.emptyDrilling
		elseif self.inPressure then
			self.currentDrillState = self.drillState.pressureDrilling
		else
			self.currentDrillState = self.drillState.drilling
		end

		self.bindData.vxParAllWidget.anim:Play()
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.currentDrillState)
	self.bindData.vxParAllWidget.gameObject:SetActive(true)

	local currentDiskStartDis = self:GetCurrentDiskStartDis()

	if currentDiskStartDis < self.logicAdvanceDis and self.logicAdvanceDis < self.currentDrillDis then
		self.logicAdvanceDis = self.currentDrillDis
		self.performAdvanceDis = self.logicAdvanceDis
	end

	if not self.bindData.rootWidget.anim:IsPlaying("S_Vx_VaultGameplayPanel_Unlock_move2") then
		self.bindData.rootWidget.anim:Play("S_Vx_VaultGameplayPanel_Unlock_move2")
	end
end

function M:OnClickBtnRelease()
	if self.currentDrillState == self.drillState.overPressureDrill then
		self.currentDrillState = self.drillState.overPressure
	elseif self.currentDrillState == self.drillState.drilling or self.currentDrillState == self.drillState.emptyDrilling or self.currentDrillState == self.drillState.pressureDrilling then
		self.currentDrillState = self.drillState.idle
	end

	gCS.LogicStateMachineManager.SendSpoonEvent(gCS.MyPlayerManager.PlayerUnit, self.robBandDrillShelf, self.drillState.idle)
	self.bindData.vxParAllWidget.gameObject:SetActive(false)

	if not self.bindData.rootWidget.anim:IsPlaying("S_Vx_VaultGameplayPanel_Unlock_move1") then
		self.bindData.rootWidget.anim:Play("S_Vx_VaultGameplayPanel_Unlock_move1")
	end
end

function M:RefreshProcessBar()
	self.bindData.heatProgress:ProgressToValue(self.pressure, 0, 0)
	self.bindData.hitProgress:ProgressToValue(self.performAdvanceDis / self.maxAdvanceDis, 0, 0)
	L50.L50App.Scene.VaultGameplayManager:SetHitProgress(self.logicAdvanceDis / self.maxAdvanceDis)
end

function M:OnMouseMove(context)
	local mousePos = context:ReadValueVector2()
	self.logicAdvanceDis = self.logicAdvanceDis + mousePos.y * self.mouseMoveRate

	if self.logicAdvanceDis < 0 then
		self.logicAdvanceDis = 0
	end

	if self.logicAdvanceDis < self.currentDrillDis then
		self.performAdvanceDis = self.logicAdvanceDis
	else
		self.performAdvanceDis = self.currentDrillDis
	end

	if self.logicAdvanceDis > self.performAdvanceDis + self.maxLogicAdvanceDis then
		self.logicAdvanceDis = self.performAdvanceDis + self.maxLogicAdvanceDis
	end

	if self.logicAdvanceDis > self.performAdvanceDis + self.maxOverPressureDistance then
		self.inPressure = true
	else
		self.inPressure = false
	end

	self.currentNormalPressureDis = 0
end

function M:GetCurrentDiskStartDis()
	return self:GetDiskDis(self.currentDiskIndex)
end

function M:GetDiskDis(index)
	return (index - 1) * self.diskThickness + index * self.diskSpacing
end
