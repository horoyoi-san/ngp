-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarModsPanelMainPageStore.lua
-- Decompiled from: 01636_CarModsPanelMainPageStore.lua_41aa3c345a54.luajit

C_CarModsPanelMainPageStore = DefClass("C_CarModsPanelMainPageStore", C_CarModsPanelMainPageStore, C_StoreGroup)
GroupName2Class.CarModsPanelMainPageStore = C_CarModsPanelMainPageStore
local M = C_CarModsPanelMainPageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.parent = gStoreManager:GetStoreGroup("CarModsPanelStore")

	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.cachedTooltipStore = nil
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CAR_SHOP_VEHICLE_READY] = self.CreateAction(self, self.OnCarShopVehicleReady),
		[gEventConstants.CAR_SHOP_VEHICLE_SWITCH] = self.CreateAction(self, self.OnSwitchVehicle)
	}
end

M.RegisterWidget = function(self)
	self.bindData.kitBtn.luaClick = self.CreateAction(self, self.OnClickKitBtn)
	self.bindData.tyreBtn.luaClick = self.CreateAction(self, self.OnClickTyreBtn)
	self.bindData.outlookBtn.luaClick = self.CreateAction(self, self.OnClickOutlookBtn)
	self.bindData.performanceBtn.luaClick = self.CreateAction(self, self.OnClickPerformanceBtn)
	self.bindData.colorBtn.luaClick = self.CreateAction(self, self.OnClickColorBtn)
	self.bindData.switchCarBtn.luaClick = self.CreateAction(self, self.OnClickSwitchCarBtn)
end

M.OnClickKitBtn = function(self)
	self.parent:GotoDetail(C_NewCarStoreMgr.MODS_TYPE.KIT)
end

M.OnClickTyreBtn = function(self)
	self.parent:GotoDetail(C_NewCarStoreMgr.MODS_TYPE.TYRE)
end

M.OnClickOutlookBtn = function(self)
	self.parent:GotoDetail(C_NewCarStoreMgr.MODS_TYPE.OUTLOOK)
end

M.OnClickPerformanceBtn = function(self)
	self.parent:GotoDetail(C_NewCarStoreMgr.MODS_TYPE.PERFORMANCE)
end

M.OnClickColorBtn = function(self)
	self.parent:GotoDetail(C_NewCarStoreMgr.MODS_TYPE.COLOR)
end

M.OnClickSwitchCarBtn = function(self)
	self.parent:GotoVehicle()
end

M.RefreshPage = function(self)
	local vehicleId = gApplyCarManager:GetParkingVehicleCfgId()

	if not vehicleId then
		return
	end

	local tooltipStore = gStoreManager:GetStoreGroup(self.bindData.infoTooltipWidget.Store):GetStoreByWidget(self.bindData.infoTooltipWidget)
	self.cachedTooltipStore = tooltipStore

	gNewCarStoreMgr:RenderCarInfoTooltipV2(tooltipStore, vehicleId)
end

M.OnCarShopVehicleReady = function(self)
	if self.cachedTooltipStore then
		local vehicleId = gApplyCarManager:GetParkingVehicleCfgId()

		if vehicleId then
			gNewCarStoreMgr:RenderCarInfoTooltipV2(self.cachedTooltipStore, vehicleId)
		end
	end
end

M.OnSwitchVehicle = function(self)
	self.RefreshPage(self)
end
