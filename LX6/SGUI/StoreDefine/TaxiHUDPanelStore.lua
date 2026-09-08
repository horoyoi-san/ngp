-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TaxiHUDPanelStore.lua
-- Decompiled from: 01404_TaxiHUDPanelStore.lua_ea5ea9b6f567.luajit

C_TaxiHUDPanelStore = DefClass("C_TaxiHUDPanelStore", C_TaxiHUDPanelStore, C_StoreGroup)
GroupName2Class.TaxiHUDPanelStore = C_TaxiHUDPanelStore
local M = C_TaxiHUDPanelStore
local TaxiManager = LX6.Drive.GamePlay.TaxiSystemManager.Instance

M.OnAwake = function(self)
	self.urgeIconId = 28005200
	self.urgeSpeedIconId = 28005201
	self.bindData.changeDestinationBtn.luaClick = self.CreateAction(self, "OnBtnChangeDestination")
	self.bindData.urgeBtn.luaClick = self.CreateAction(self, "OnBtnUrge")
	self.bindData.skipBtn.luaClick = self.CreateAction(self, "OnBtnSkip")
	self.bindData.skipBtn.luaLongPress = self.CreateAction(self, "OnBtnSkip")
	self.priceLastUpdateTime = 0
	self.startTime = 0
	self.started = false
	self.currVehicleId = 0
end

M.OnShow = function(self, panelId, data, widget, IsMainDrive, IsPhoneMode)
	self.currVehicleId = data.vehicleId
	self.IsPhoneMode = IsPhoneMode
	self.IsMainDrive = IsMainDrive

	self.InitTaxiStyle(self)

	if self.started then
		self.RefreshButtonState(self)
	end
end

M.OnStart = function(self)
	self.started = true

	self.RefreshButtonState(self)
end

M.OnDestroy = function(self)
	self.started = false
end

M.OnGroupEnable = function(self)
	self.changeDestinationBtnStore = self.GetStoreByWidget(self, self.bindData.changeDestinationBtn)
	self.urgeBtnStore = self.GetStoreByWidget(self, self.bindData.urgeBtn)
	self.skipBtnStore = self.GetStoreByWidget(self, self.bindData.skipBtn)
end

M.InitTaxiStyle = function(self)
	self.needUpdate = true
	self.startTime = gLogicTime.time

	self.OnUpdate(self, true)

	self.bindData.urgeIconId = self.urgeIconId
end

M.OnClose = function(self)
	self.currVehicleId = 0
	self.needUpdate = false
end

M.OnUpdate = function(self, force)
	if self.needUpdate then
		self.UpdatePriceTable(self, force)
	end
end

M.UpdatePriceTable = function(self, force)
	if gLogicTime.time - self.priceLastUpdateTime >= 1 and not force then
		return
	end

	self.priceLastUpdateTime = gLogicTime.time
	local cost = TaxiManager.CurrentTaxiCost
	local costInt = math.floor(cost)
	costInt = math.min(costInt, 99999)
	local dis = TaxiManager.CurrentTaxiDistance / 1000
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

M.OnBtnSkip = function(self)
	TaxiManager:Skip()
end

M.OnBtnUrge = function(self)
	self.bindData.urgeIconId = self.urgeSpeedIconId

	TaxiManager:Accelerate()
end

M.OnBtnChangeDestination = function(self)
	TaxiManager:ChangeDestination()
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
	btn.SetActive(btn, active)
end

M.EnterPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = true

	self.RefreshButtonState(self)
end

M.ExitPhoneMode = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.IsPhoneMode = false

	self.RefreshButtonState(self)
end

M.RefreshButtonState = function(self)
	local isMobile = not gCS.LuaUtils.IsNonMobileAdaptive()
	local active = not self.IsPhoneMode

	self.SetBtnActive(self, self.bindData.changeDestinationBtn, active)
	self.SetBtnActive(self, self.bindData.skipBtn, active)
	self.SetBtnActive(self, self.bindData.urgeBtn, active)
	self.SetBtnVisible(self, self.changeDestinationBtnStore, isMobile)
	self.SetBtnVisible(self, self.skipBtnStore, isMobile)
	self.SetBtnVisible(self, self.urgeBtnStore, isMobile)
end
