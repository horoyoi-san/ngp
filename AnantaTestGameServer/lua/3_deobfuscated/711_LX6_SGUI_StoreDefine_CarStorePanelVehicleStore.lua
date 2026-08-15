local VehicleConfig = LTConfig.VehicleConfig
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local EVehicleStateCtrl = {
	Got = 1,
	Lock = 2,
	Normal = 0
}
C_CarStorePanelVehicleStore = DefClass("C_CarStorePanelVehicleStore", C_CarStorePanelVehicleStore, C_StoreGroup)
GroupName2Class.CarStorePanelVehicleStore = C_CarStorePanelVehicleStore
local M = C_CarStorePanelVehicleStore

function M:ctor()
	self.mgr = gNewCarStoreMgr
end

function M:OnAwake()
	self.parent = gStoreManager:GetStoreGroup("CarStorePanelStore")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderVehicleItem)
	self.bindData.itemList.luaSelectedChanged = self:CreateAction(self.OnSelectVehicleItem)
	self.bindData.optionalBtn.luaClick = self:CreateActionWithArgs("OnStep", self.mgr.DisplayType.Part, self.parent)
end

function M:RefreshPage()
	self.vehicleList = self.mgr:GetVehicleList()
	self.vehicleDataList = {}

	for i, v in ipairs(self.vehicleList) do
		local data = {
			vehicle = v
		}
		local _, moneyIconId, info = self.mgr:GetPartPriceAndMoneyIcon(v.id)
		data.moneyIconId = moneyIconId
		data.info = info

		table.insert(self.vehicleDataList, data)
	end

	table.sort(self.vehicleDataList, self:CreateAction(self.VehicleDataSorter))

	local selectIndex = 0

	if self.parent.vehicleId then
		for i, v in ipairs(self.vehicleDataList) do
			if v.vehicle.id == self.parent.vehicleId then
				selectIndex = i - 1

				break
			end
		end
	end

	self.bindData.itemList:SetSimpleList(#self.vehicleDataList)
	self.bindData.itemList:SelectItem(selectIndex)
end

function M:RefreshTooltip(vehicle)
	self.infoTooltipStore = gStoreManager:GetStoreGroup(self.bindData.infoTooltipWidget.Store):GetStoreByWidget(self.bindData.infoTooltipWidget)
	local id = vehicle.id
	local cfg = VehicleConfig.GetConfig(id)
	self.infoTooltipStore.logo = cfg.SVehicleBrandIcon
	self.infoTooltipStore.carName = cfg.VehicleName
	self.infoTooltipStore.chairNum = cfg.VehicleSeatNum
	self.infoTooltipStore.vehicleTypeText = VehicleTypeConfig.GetConfig(cfg.VehicleType).DisplayName
	local featureCfg = gCarStoreManager:GetFeatureByVehicleId(id)
	self.scoreList = {}

	if featureCfg ~= nil then
		for i = 1, 5 do
			local view = {}

			if VehicleConfig["Feature" .. i .. "Name"] and featureCfg["Feature" .. i] then
				view.title = VehicleConfig["Feature" .. i .. "Name"]
				view.progress = featureCfg["Feature" .. i]

				table.insert(self.scoreList, view)
			end
		end

		self.infoTooltipStore.scoreList.luaSimpleRenderItem = self:CreateAction(self.OnRenderAttributeListItem)

		self.infoTooltipStore.scoreList:SetSimpleList(#self.scoreList)
	else
		print_error("#NoCreateIssue @zhujiaying 车辆属性配置缺失，车辆ID：" .. tostring(id))
		self.infoTooltipStore.scoreList:SetSimpleList(0)
	end
end

function M:OnRenderAttributeListItem(btn, index)
	local data = self.scoreList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		store.des = data.title
		store.progress.value = data.progress
	end
end

function M:OnRenderVehicleItem(btn, index)
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

	store.moneyIconId = data.moneyIconId
	store.moneyNum = self.parent:GetKitStartPrice(vehicleId, 1)

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

function M:OnSelectVehicleItem(uList)
	if self.parent.childStore ~= self then
		return
	end

	local data = self.vehicleDataList[uList.selectedIndex + 1]
	local id = data.vehicle.id

	if id ~= self.parent.vehicleId then
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

function M:VehicleDataSorter(a, b)
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

			if aQuality ~= bQuality then
				return aQuality < bQuality
			else
				local aPrice, _, _ = self.parent:GetKitStartPrice(a.vehicle.id, 1)
				local bPrice, _, _ = self.parent:GetKitStartPrice(b.vehicle.id, 1)

				if aPrice ~= bPrice then
					return aPrice < bPrice
				else
					return b.vehicle.id < a.vehicle.id
				end
			end
		end
	end
end
