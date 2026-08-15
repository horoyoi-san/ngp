C_TaxiHUDPanelStore = DefClass("C_TaxiHUDPanelStore", C_TaxiHUDPanelStore, C_StoreGroup)
GroupName2Class.TaxiHUDPanelStore = C_TaxiHUDPanelStore
local M = C_TaxiHUDPanelStore

function M:OnAwake()
	self.urgeIconId = 28005200
	self.urgeSpeedIconId = 28005201
	self.bindData.changeDestinationBtn.luaClick = self:CreateAction("OnBtnChangeDestination")
	self.bindData.urgeBtn.luaClick = self:CreateAction("OnBtnUrge")
	self.bindData.skipBtn.luaClick = self:CreateAction("OnBtnSkip")
	self.bindData.skipBtn.luaLongPress = self:CreateAction("OnBtnSkip")
	self.priceLastUpdateTime = 0
	self.startTime = 0
	self.started = false
	self.currVehicleId = 0
end

function M:OnShow(panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	self:InitTaxiStyle()

	if self.started then
		self:RefreshButtonState()
	end
end

function M:OnStart()
	self.started = true

	self:RefreshButtonState()
end

function M:OnDestroy()
	self.started = false
end

function M:OnGroupEnable()
	self.changeDestinationBtnStore = self:GetStoreByWidget(self.bindData.changeDestinationBtn)
	self.urgeBtnStore = self:GetStoreByWidget(self.bindData.urgeBtn)
	self.skipBtnStore = self:GetStoreByWidget(self.bindData.skipBtn)
end

function M:InitTaxiStyle()
	self.needUpdate = true
	self.startTime = gLogicTime.time

	self:OnUpdate(true)

	self.bindData.urgeIconId = self.urgeIconId
end

function M:OnClose()
	self.currVehicleId = 0
	self.needUpdate = false
end

function M:OnUpdate(force)
	if self.needUpdate then
		self:UpdatePriceTable(force)
	end
end

function M:UpdatePriceTable(force)
	if gLogicTime.time - self.priceLastUpdateTime < 1 and not force then
		return
	end

	self.priceLastUpdateTime = gLogicTime.time
	local cost = gTaxiManager.CurrentTaxiCost
	local costInt = math.floor(cost)
	costInt = math.min(costInt, 99999)
	local dis = gTaxiManager.CurrentTaxiDistance / 1000
	dis = math.min(dis, 9999.9)
	local timeElapse = gLogicTime.time - self.startTime
	local hour = math.floor(timeElapse / 3600)
	local min = math.floor(timeElapse / 60 % 60)
	local sec = math.floor((timeElapse - min * 60) % 60)
	hour = math.min(hour, 99)
	min = math.min(min, 60)
	sec = math.min(sec, 60)
	self.bindData.price = costInt
	self.bindData.distance = gString.Format("%.1f", dis)
	self.bindData.time = gString.Format("%02d'%02d'%02d", hour, min, sec)
end

function M:OnBtnSkip()
	gTaxiManager:Skip()
end

function M:OnBtnUrge()
	self.bindData.urgeIconId = self.urgeSpeedIconId

	gTaxiManager:Accelerate()
end

function M:OnBtnChangeDestination()
	gTaxiManager:ChangeDestination()
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
	btn:SetActive(active)
end

function M:EnterPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self:RefreshButtonState()
end

function M:ExitPhoneMode()
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self:RefreshButtonState()
end

function M:RefreshButtonState()
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode

	self:SetBtnActive(self.bindData.changeDestinationBtn, active)
	self:SetBtnActive(self.bindData.skipBtn, active)
	self:SetBtnActive(self.bindData.urgeBtn, active)
	self:SetBtnVisible(self.changeDestinationBtnStore, isMobile)
	self:SetBtnVisible(self.skipBtnStore, isMobile)
	self:SetBtnVisible(self.urgeBtnStore, isMobile)
end
