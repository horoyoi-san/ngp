-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarStorePanelVehicleStore.lua
-- Decompiled from: 01641_CarStorePanelVehicleStore.lua_b902c77e3290.luajit

local VehicleConfig = LTConfig.VehicleConfig
local EVehicleStateCtrl = {
	["\\xa9gr"] = 1,
	["V-~P"] = 2,
	["2G\\x83\\x83\\x82M"] = 0
}
C_CarStorePanelVehicleStore = DefClass("C_CarStorePanelVehicleStore", C_CarStorePanelVehicleStore, C_StoreGroup)
GroupName2Class.CarStorePanelVehicleStore = C_CarStorePanelVehicleStore
local M = C_CarStorePanelVehicleStore

M.ctor = function(self)
	self.mgr = gNewCarStoreMgr
end

M.OnAwake = function(self)
	self.parent = gStoreManager:GetStoreGroup("CarStorePanelStore")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderVehicleItem)
	self.bindData.itemList.luaSelectedChanged = self:CreateAction(self.OnSelectVehicleItem)
	self.bindData.optionalBtn.luaClick = self:CreateActionWithArgs("OnStep", self.mgr.DisplayType.Part, self.parent)

	self:GenMessageEvents()
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.infoTooltipStore = nil
	self.infoTooltipVehicleId = nil
end

M.RefreshPage = function(self)
	self.vehicleList = self.mgr:GetVehicleList()
	self.vehicleDataList = {}

	for i, v in ipairs(self.vehicleList) do
		local data = {
			vehicle = v
		}
		local _, _, info = self.mgr:GetPartPriceAndMoneyIcon(v.id)
		data.info = info

		table.insert(self.vehicleDataList, data)
	end

	table.sort(self.vehicleDataList, self.CreateAction(self, self.VehicleDataSorter))

	local selectIndex = 0

	if self.parent.vehicleId then
		for i, v in ipairs(self.vehicleDataList) do
			if v.vehicle.id ~= self.parent.vehicleId then
				selectIndex = i - 1

				break
			end
		end
	end

	self.bindData.itemList:SetSimpleList(#self.vehicleDataList)
	self.bindData.itemList:SelectItem(selectIndex)
end

M.RefreshTooltip = function(self, vehicle)
	self.infoTooltipStore = gStoreManager:GetStoreGroup(self.bindData.infoTooltipWidget.Store):GetStoreByWidget(self.bindData.infoTooltipWidget)
	self.infoTooltipVehicleId = vehicle.id

	gNewCarStoreMgr:RenderCarInfoTooltipV2(self.infoTooltipStore, self.infoTooltipVehicleId)
end

M.OnCarShopVehicleReady = function(self)
	if self.infoTooltipStore and self.infoTooltipVehicleId then
		gNewCarStoreMgr:RenderCarInfoTooltipV2(self.infoTooltipStore, self.infoTooltipVehicleId)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CAR_SHOP_VEHICLE_READY] = self.CreateAction(self, self.OnCarShopVehicleReady)
	}
end

M.OnRenderVehicleItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.vehicleDataList[index + 1]
	local vehicleId = data.vehicle.id
	local cfg = VehicleConfig.GetConfig(vehicleId)
	local info = data.info

	if not cfg then
		return
	end

	local formatStrCfg = LTConfig.TextConfig.GetConfig(73977003)

	if not formatStrCfg then
		print_error("TextConfig config is missing, id = 73977003")
	else
		local formatStr = formatStrCfg.Text
		local price = gCommonItemManager:GetExchangeRate(self.parent:GetSuitStartPrice(vehicleId, 0))
		local moneyRichText = gCommonItemManager:GetCurrMoneyRichText()
		store.moneyNum = string.format(formatStr, moneyRichText, price)
	end

	if table.isNilOrEmpty(info) then
		return
	end

	store.iconId = cfg.SVehicleIconId
	store.brandId = cfg.VehicleBrandPicIcon
	store.qualityCtrl = info.Quality

	if not info.Unlocked then
		store.state = EVehicleStateCtrl.Lock

		return
	elseif data.vehicle.isGot then
		store.state = EVehicleStateCtrl.Got
	else
		store.state = EVehicleStateCtrl.Normal
	end
end

M.OnSelectVehicleItem = function(self, uList)
	if self.parent.childStore == self then
		return
	end

	local data = self.vehicleDataList[uList.selectedIndex + 1]
	local id = data.vehicle.id

	if id == self.parent.vehicleId then
		self.parent:OnCurrentVehicleChange(data.vehicle)

		self.bindData.optionalBtn.interactable = not data.vehicle.isGot and data.info.Unlocked

		if data.vehicle.isGot then
			self.bindData.stateCtrl = EVehicleStateCtrl.Got
		elseif not data.info.Unlocked then
			self.bindData.stateCtrl = EVehicleStateCtrl.Lock
			self.bindData.lockDescText = data.info.UnlockDesc
		else
			self.bindData.stateCtrl = EVehicleStateCtrl.Normal
		end
	end

	self.parent:CreateDefaultVehicle(function ()
		self.mgr:SetCameraState(LTConfig.VehiclePartShopTabConfig.ViewTypeType.Center)
	end)
	self:RefreshTooltip(data.vehicle)
end

M.VehicleDataSorter = function(self, a, b)
	if a.vehicle.isGot and not b.vehicle.isGot then
		return false
	elseif not a.vehicle.isGot and b.vehicle.isGot then
		return true
	else
		local aUnlocked = a.info.Unlocked
		local bUnlocked = b.info.Unlocked

		if aUnlocked and not bUnlocked then
			return true
		elseif not aUnlocked and bUnlocked then
			return false
		else
			local aQuality = a.info.Quality
			local bQuality = b.info.Quality

			if aQuality == bQuality then
				return aQuality <= bQuality
			else
				local aPrice, _, _ = self.parent:GetSuitStartPrice(a.vehicle.id, 0)
				local bPrice, _, _ = self.parent:GetSuitStartPrice(b.vehicle.id, 0)

				if aPrice == bPrice then
					return aPrice <= bPrice
				else
					return b.vehicle.id <= a.vehicle.id
				end
			end
		end
	end
end
