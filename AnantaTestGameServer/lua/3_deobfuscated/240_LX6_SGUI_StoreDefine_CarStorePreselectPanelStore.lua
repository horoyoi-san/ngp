local ConsumableConfig = LTConfig.ConsumableConfig
local VehicleConfig = LTConfig.VehicleConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
C_CarStorePreselectPanelStore = DefClass("C_CarStorePreselectPanelStore", C_CarStorePreselectPanelStore, C_StoreGroup)
GroupName2Class.CarStorePreselectPanelStore = C_CarStorePreselectPanelStore
local M = C_CarStorePreselectPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.optionalBtn.luaClick = self:CreateAction("OnOptionalBtnClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabList")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabSelectedChange")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSelectedChanged = self:CreateAction("OnItemSelectedChange")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnChangeStep", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnChangeStep", 1)
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	gCarStoreManager:ClearBaseVehicle()
	gCS.CameraDataMgr.cinemachineManager:ExitMovementState(LX6.Cinemachine.EMovementCamState.BuyVehicle)

	self.scoreList = nil
	self.tabList = nil
end

function M:OnShow(panelId, data)
	return
end

function M:InitInfo(itemList, changeTabRect)
	self.changeTabRect = changeTabRect
	self.selectTabIndex = 1
	self.selectItemIndex = 1
	self.tabList = {}

	for i = 1, #itemList do
		if itemList[i].VehicleSubType and itemList[i].VehicleSubType > 0 then
			local type = itemList[i].VehicleSubType + 1

			if table.isNilOrEmpty(self.tabList[type]) then
				self.tabList[type] = {
					title = ConsumableConfig.VehicleShopTabName[type],
					itemList = {}
				}
			end

			if gCarStoreManager.commidity2Type[itemList[i].CommodityID] ~= gCarStoreManager.COMMIDITY_TYPE.OTHER then
				table.insert(self.tabList[type].itemList, itemList[i])
			end
		end

		if self.tabList[1] == nil then
			self.tabList[1] = {
				title = ConsumableConfig.VehicleShopTabName[1],
				itemList = {}
			}
		end

		if gCarStoreManager.commidity2Type[itemList[i].CommodityID] ~= gCarStoreManager.COMMIDITY_TYPE.OTHER then
			table.insert(self.tabList[1].itemList, itemList[i])
		end
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SetItemSelected(0, true)
	self.bindData.itemList:SetSimpleList(#self.tabList[self.selectTabIndex].itemList)
	self.bindData.itemList:SetItemSelected(0, true)
end

function M:OnClose()
	return
end

function M:OnRefreshTabList(item, index)
	local data = self.tabList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarStoreMainTab"):GetStoreByWidget(item)

	if store then
		store.title = data.title
		item.isSelected = self.selectTabIndex == index + 1
	end
end

function M:OnRefreshItemList(item, index)
	local data = self.tabList[self.selectTabIndex].itemList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("MainCarItem"):GetStoreByWidget(item)

	if store then
		store.iconId = data.iconId
		store.moneyIconId = data.moneyIconId
		store.brandId = data.brandId
		store.moneyNum = data.moneyNum
		store.state = data.state
		item.isSelected = self.selectItemIndex == index + 1

		if item.isSelected then
			self:SetItemInfo(item, data)
		end
	end
end

function M:OnItemSelectedChange(uList)
	local data = self.tabList[self.selectTabIndex].itemList[uList.selectedIndex + 1]

	if data then
		self.selectItemIndex = uList.selectedIndex + 1

		self:SetItemInfo(nil, data)
	end
end

function M:SetItemInfo(btn, data)
	self.curItemInfo = data
	self.bindData.state = data.state
	local SCCfg = ShopCommodityCfg.GetConfig(data.CommodityID)

	if SCCfg then
		self.bindData.unlockDes = SCCfg.UnlockConditionsDes or ""
	end

	gCarStoreManager:OnCreateVehicle(data.vehicleId)

	local store = gStoreManager:GetStoreGroup("CarInfoTooltipStore"):GetStoreByWidget(self.bindData.infoTooltip)

	if store then
		store.logo = data.brandLogo
		store.carName = data.name
		store.chairNum = data.VehicleSeatNum
		local featureCfg = gCarStoreManager:GetFeatureByVehicleId(data.vehicleId)

		if data and featureCfg ~= nil then
			self.scoreList = {}

			for i = 1, 5 do
				local view = {}

				if VehicleConfig["Feature" .. i .. "Name"] and featureCfg["Feature" .. i] then
					view.title = VehicleConfig["Feature" .. i .. "Name"]
					view.progress = featureCfg["Feature" .. i]

					table.insert(self.scoreList, view)
				end
			end

			store.scoreList.luaSimpleRenderItem = self:CreateAction("OnRefreshAttributeList")

			store.scoreList:SetSimpleList(#self.scoreList)
		else
			store.scoreList:SetSimpleList(0)
		end
	end
end

function M:OnOptionalBtnClick()
	self.changeTabRect(1, self.curItemInfo)
end

function M:OnRefreshAttributeList(btn, index)
	local data = self.scoreList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarScoreTemplate"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		store.des = data.title
		store.progress.value = data.progress
	end
end

function M:OnTabSelectedChange(uList)
	self.selectTabIndex = uList.selectedIndex + 1

	self.bindData.itemList:SetSimpleList(#self.tabList[self.selectTabIndex].itemList)
	self.bindData.itemList:SetItemSelected(0, true)
end

function M:OnChangeStep(step)
	local nextStep = self:RefreshStep(self.bindData.tabList.selectedIndex, step)

	self.bindData.tabList:SelectItem(nextStep)
end

function M:RefreshStep(curStep, step)
	local nextStep = curStep + step

	if nextStep < 0 then
		nextStep = #self.tabList - 1
	elseif nextStep >= #self.tabList then
		nextStep = 0
	end

	return nextStep
end
