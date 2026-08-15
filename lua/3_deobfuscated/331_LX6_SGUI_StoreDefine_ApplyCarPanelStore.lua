local VehicleConfig = LTConfig.VehicleConfig
local VehicleAttributeConfig = LTConfig.VehicleAttributeConfig
local MessageConfig = LTConfig.MessageConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_ApplyCarPanelStore = DefClass("C_ApplyCarPanelStore", C_ApplyCarPanelStore, C_StoreGroup)
GroupName2Class.ApplyCarPanelStore = C_ApplyCarPanelStore
local M = C_ApplyCarPanelStore
local PAGE = {
	NORMAL = 0,
	APPLY_SUCCESS = 1
}
local SELECT = {
	FALSE = 0,
	TRUE = 1
}

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.backBtn2.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.applyCarBtn.luaClick = self:CreateAction("OnApplyCarBtnClick")
	self.bindData.switchCarBtn.luaClick = self:CreateAction("OnSwitchCarBtnClick")
end

function M:OnShow(panelId, data)
	self.hasCallBack = false

	if data then
		if data.vehicleId then
			self.curVehicleTypeId = data.vehicleId
		else
			self.curVehicleTypeId = gApplyCarManager.driveCarTypeId
		end

		if data.callback then
			self.callback = data.callback
		end

		self.banApply = data.banApply or false
		self.isExchange = data.isExchange or false

		if data.banVehicleIdList then
			self.banVehicleIdList = data.banVehicleIdList
		end
	end

	if self.curVehicleTypeId == nil or self.curVehicleTypeId == 0 then
		return
	end

	self.bindData.page = PAGE.NORMAL

	self:SetVehicleInfo()
end

function M:OnClose()
	if self.callback and not self.hasCallBack then
		self.callback()

		self.hasCallBack = false
	end
end

function M:OnDestroy()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnGroupEnable()
	return
end

function M:SetVehicleInfo()
	local cfg = VehicleConfig.GetConfig(self.curVehicleTypeId)

	if cfg then
		self.VehicleCanGet = not self.banApply and cfg.VehicleCanGet or false

		if self.isExchange then
			self.bindData.canBuy = 2
		else
			self.bindData.canBuy = self.VehicleCanGet and 0 or 1
		end

		self.bindData.name = cfg.VehicleName
		self.bindData.quality = cfg.VehicleQuality
		self.bindData.moneyNum = cfg.VehicleCostCount
		local moenyItemCfg = ConsumableConfig.GetConfig(cfg.VehicleCost)

		if moenyItemCfg then
			self.bindData.moneyIcon = moenyItemCfg.SItemIconId
		end

		self.bindData.carImg = cfg.SBuyVehicleIconId
		self.myMoneyCount = gPlayerItemManager:GetPackItemNum(cfg.VehicleCost)
		self.bindData.isLackmoney = cfg.VehicleCostCount <= self.myMoneyCount and SELECT.TRUE or SELECT.FALSE
		self.bindData.applyCarBtn.interactable = cfg.VehicleCostCount <= self.myMoneyCount
		local attrCfg = VehicleAttributeConfig.GetConfig(cfg.VehicleAttr)

		if attrCfg then
			for i = 1, 6 do
				self.bindData.radar:SetVertexValue(i - 1, attrCfg["Attribute" .. i])
			end
		end
	else
		print_error("没有找到车辆配置 vehicleId = " .. self.curVehicleTypeId)
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_APPLY_CAR)
end

function M:OnApplyCarBtnClick()
	if self.bindData.isLackmoney == SELECT.FALSE or self.VehicleCanGet == false then
		return
	end

	local cfg = VehicleConfig.GetConfig(self.curVehicleTypeId)

	if cfg then
		gClientToGameDelegate:AskBuyVehicleFromMass(self.curVehicleTypeId, true).Callback = function (err)
			if err == MessageConfig.Ok then
				print("申请车辆成功")

				self.bindData.page = PAGE.APPLY_SUCCESS

				gApplyCarManager:AddUnlockVehicle(self.curVehicleTypeId)
			end
		end
	end
end

function M:OnSwitchCarBtnClick()
	if self.isExchange then
		local args = {
			banVehicleIdList = self.banVehicleIdList,
			showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.CallPhone,
			secondShowType = gClientConst.CallPhoneShowType.Call_Car,
			onConfirmCallback = function (newVehicleId)
				self.callback(newVehicleId)

				self.hasCallBack = true

				self:OnBackBtnClick()
			end
		}

		gPanelManager:CheckShow(gPanelId.S_FRONT_FULLSCREEN_PHONE_APP_HOME_PANEL, args)
	end
end
