local CarShopConfig = LTConfig.CarShopConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local CarShopOutColorConfig = LTConfig.CarShopOutColorConfig
local CarShopMaterialConfig = LTConfig.CarShopMaterialConfig
local CarShopInColorConfig = LTConfig.CarShopInColorConfig
local CarShopWheelConfig = LTConfig.CarShopWheelConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local CarShopSetConfig = LTConfig.CarShopSetConfig
C_CarStoreOptionPanelStore = DefClass("C_CarStoreOptionPanelStore", C_CarStoreOptionPanelStore, C_StoreGroup)
GroupName2Class.CarStoreOptionPanelStore = C_CarStoreOptionPanelStore
local M = C_CarStoreOptionPanelStore
local OPTION_TYPE = {
	WHEEL = 2,
	DETAIL = 1,
	PRESET = 0
}
local DETAIL_TYPE = {
	OUT_COLOR = 0,
	IN_COLOR = 2,
	MATERIAL = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.buyBtn.luaClick = self:CreateAction("OnBuyBtnClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabList")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnSelectTab")
	self.bindData.topTabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTopTabList")
	self.bindData.topTabList.luaSelectedChanged = self:CreateAction("OnSelectTopTab")
	self.bindData.itemList.luaRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaClick = self:CreateAction("OnChangeItem")
	self.bindData.topTabLeftBtn.luaClick = self:CreateActionWithArgs("OnBtnChangeTab", -1)
	self.bindData.topTabRightBtn.luaClick = self:CreateActionWithArgs("OnBtnChangeTab", 1)
end

function M:OnEnable()
	return
end

function M:OnDestroy()
	self.noCarSetList = nil
end

function M:OnClose()
	return
end

function M:OnShow(panelId, data)
	return
end

function M:InitInfo(carStore, itemInfo)
	self.carStore = carStore
	self.optionType = 0
	self.detailType = 0
	self.itemInfo = itemInfo
	self.selectItemTypeIndex = {}
	self.commodityList = {}
	self.commodityInfo = {}
	local carSetListCfg = gCarStoreManager:GetCarSetByVehicleId(itemInfo.vehicleId)

	if carSetListCfg == nil then
		self.noCarSetList = true

		self.bindData.tabList:SetSimpleList(0)
		self.bindData.topTabList:SetSimpleList(0)

		return
	end

	self.noCarSetList = false
	self.myMoneyCount = gPlayerItemManager:GetPackItemNum(itemInfo.moneyType)
	self.bindData.moneyIcon = itemInfo.moneyIconId
	self.selectSet = 0
	self.selectOutColor = 0
	self.selectInColor = 0
	self.selectWheel = 0
	self.selectMaterial = 0

	self:InitPresetInfo(carSetListCfg)
	self:InitTabInfo()
	self:CheckIsLackMoney()
end

function M:InitTabInfo()
	self.tabList = {}

	for i = 1, #CarShopConfig.TabName do
		local view = {
			iconId = CarShopConfig.TabName[i]
		}

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SetItemSelected(0, true)

	self.tabTopList = {}

	for i = 1, #CarShopConfig.ColorTabName do
		local view = {
			iconId = CarShopConfig.ColorTabName[i]
		}

		table.insert(self.tabTopList, view)
	end

	self.bindData.topTabList:SetSimpleList(#self.tabTopList)
	self.bindData.tabList:SetItemSelected(0, true)
end

function M:InitPresetInfo(carSetListCfg)
	self.itemList = {}
	self.setIdList = {}
	self.selectId2ResourcePath = {}
	self.outColorIdList = {}
	self.inColorIdList = {}
	self.wheelIdList = {}

	for i = 1, #carSetListCfg do
		local cfg = carSetListCfg[i]
		local view = {
			Id = carSetListCfg[i].Id,
			iconId = cfg.Icon,
			name = cfg.Name,
			CommodityId = cfg.CommodityId
		}
		local comCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

		if comCfg then
			view.price = comCfg.Price
			view.moenyIconId = self.itemInfo.moneyIconId
		end

		view.tIndex = 0
		view.optionType = OPTION_TYPE.PRESET
		view.resourcePath = cfg.SetIndex
		self.selectId2ResourcePath[cfg.Id] = view.resourcePath

		if table.isNilOrEmpty(self.itemList[OPTION_TYPE.PRESET]) then
			self.itemList[OPTION_TYPE.PRESET] = {}
		end

		table.insert(self.setIdList, cfg.Id)
		table.insert(self.itemList[OPTION_TYPE.PRESET], view)
	end

	self.selectSet = self.setIdList[1]

	self:SetDetailInfo()
end

function M:SetDetailInfo()
	self.outColorIdList = {}
	self.inColorIdList = {}
	self.wheelIdList = {}

	if not table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL]) then
		self.itemList[OPTION_TYPE.DETAIL] = {}
	end

	if not table.isNilOrEmpty(self.itemList[OPTION_TYPE.WHEEL]) then
		self.itemList[OPTION_TYPE.WHEEL] = {}
	end

	local cfg = CarShopSetConfig.GetConfig(self.selectSet)

	if cfg then
		for t = 1, #cfg.OutColor do
			if not table.contains(self.outColorIdList, cfg.OutColor[t]) then
				table.insert(self.outColorIdList, cfg.OutColor[t])
			end
		end

		for t = 1, #cfg.InColor do
			if not table.contains(self.inColorIdList, cfg.InColor[t]) then
				table.insert(self.inColorIdList, cfg.InColor[t])
			end
		end

		for t = 1, #cfg.Wheel do
			if not table.contains(self.wheelIdList, cfg.Wheel[t]) then
				table.insert(self.wheelIdList, cfg.Wheel[t])
			end
		end
	end

	self.selectOutColor = self.outColorIdList[1]
	self.selectInColor = self.inColorIdList[1]
	self.selectWheel = self.wheelIdList[1]

	self:InitDetailInfo()
	self:InitWheelInfo()
	self:SetInitSelectItemType()
	self:InitMaterial()
	self:SelectTab()
end

function M:InitMaterial()
	self.materialIdList = {}
	local outColorConfig = CarShopOutColorConfig.GetConfig(self.selectOutColor)

	if outColorConfig then
		for t = 1, #outColorConfig.MaterialId do
			if not table.contains(self.materialIdList, outColorConfig.MaterialId[t]) then
				table.insert(self.materialIdList, outColorConfig.MaterialId[t])
			end
		end
	end

	if self.selectMaterial == 0 then
		self.selectMaterial = self.materialIdList[1]
	end

	self.selectItemTypeIndex[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL] = self.selectMaterial

	if not table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL]) and not table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL]) then
		self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL] = {}
	end

	for i = 1, #self.materialIdList do
		local cfg = CarShopMaterialConfig.GetConfig(self.materialIdList[i])

		if cfg then
			local view = {
				Id = self.materialIdList[i],
				name = cfg.Name,
				iconId = cfg.MaterialIcon,
				CommodityId = cfg.CommodityId
			}
			local comCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

			if comCfg then
				view.price = comCfg.Price
				view.moenyIconId = self.itemInfo.moneyIconId
			end

			view.tIndex = 1
			view.optionType = OPTION_TYPE.DETAIL
			view.detailType = DETAIL_TYPE.MATERIAL
			view.resourcePath = cfg.MaterialPart
			self.selectId2ResourcePath[cfg.Id] = view.resourcePath

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL]) then
				self.itemList[OPTION_TYPE.DETAIL] = {
					[DETAIL_TYPE.MATERIAL] = {}
				}
			end

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL]) then
				self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL] = {}
			end

			table.insert(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL], view)
		end
	end
end

function M:InitDetailInfo()
	for i = 1, #self.outColorIdList do
		local cfg = CarShopOutColorConfig.GetConfig(self.outColorIdList[i])

		if cfg then
			local view = {
				Id = self.outColorIdList[i],
				name = cfg.Name,
				iconId = cfg.OutColorIcon,
				CommodityId = cfg.CommodityId
			}
			local comCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

			if comCfg then
				view.price = comCfg.Price
				view.moenyIconId = self.itemInfo.moneyIconId
			end

			view.tIndex = 1
			view.optionType = OPTION_TYPE.DETAIL
			view.detailType = DETAIL_TYPE.OUT_COLOR
			view.resourcePath = cfg.OutColorPart
			self.selectId2ResourcePath[cfg.Id] = view.resourcePath

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL]) then
				self.itemList[OPTION_TYPE.DETAIL] = {}
			end

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.OUT_COLOR]) then
				self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.OUT_COLOR] = {}
			end

			table.insert(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.OUT_COLOR], view)
		end
	end

	for i = 1, #self.inColorIdList do
		local cfg = CarShopInColorConfig.GetConfig(self.inColorIdList[i])

		if cfg then
			local view = {
				Id = self.inColorIdList[i],
				name = cfg.Name,
				iconId = cfg.InColorIcon,
				CommodityId = cfg.CommodityId
			}
			local comCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

			if comCfg then
				view.price = comCfg.Price
				view.moenyIconId = self.itemInfo.moneyIconId
			end

			view.tIndex = 1
			view.optionType = OPTION_TYPE.DETAIL
			view.detailType = DETAIL_TYPE.IN_COLOR
			view.resourcePath = cfg.InColorPart
			self.selectId2ResourcePath[cfg.Id] = view.resourcePath

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL]) then
				self.itemList[OPTION_TYPE.DETAIL] = {}
			end

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.IN_COLOR]) then
				self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.IN_COLOR] = {}
			end

			table.insert(self.itemList[OPTION_TYPE.DETAIL][DETAIL_TYPE.IN_COLOR], view)
		end
	end
end

function M:InitWheelInfo()
	for i = 1, #self.wheelIdList do
		local cfg = CarShopWheelConfig.GetConfig(self.wheelIdList[i])

		if cfg then
			local view = {
				Id = self.wheelIdList[i],
				name = cfg.Name,
				iconId = cfg.WheelIcon,
				CommodityId = cfg.CommodityId
			}
			local comCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

			if comCfg then
				view.price = comCfg.Price
				view.moenyIconId = self.itemInfo.moneyIconId
			end

			view.tIndex = 1
			view.optionType = OPTION_TYPE.WHEEL
			view.resourcePath = cfg.WheelId
			self.selectId2ResourcePath[cfg.Id] = view.resourcePath

			if table.isNilOrEmpty(self.itemList[OPTION_TYPE.WHEEL]) then
				self.itemList[OPTION_TYPE.WHEEL] = {}
			end

			table.insert(self.itemList[OPTION_TYPE.WHEEL], view)
		end
	end
end

function M:OnRefreshTabList(btn, index)
	local data = self.tabList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarStoreTab1Store"):GetStoreByWidget(btn)

	if store then
		store.icon = data.iconId
		btn.isSelected = self.optionType == index

		if btn.isSelected then
			self:SelectTab()
		end
	end
end

function M:OnSelectTab(data)
	self.optionType = data.selectedIndex

	self:SelectTab()
end

function M:SelectTab()
	local list = nil

	if self.optionType == OPTION_TYPE.DETAIL then
		list = self.itemList[self.optionType][self.detailType]
		self.bindData.hasSecondTab = 0

		if self.detailType == DETAIL_TYPE.IN_COLOR then
			gCarStoreManager:SetCameraState(gCarStoreManager.VIEW_TYPE.Trim)
		else
			gCarStoreManager:SetCameraState(gCarStoreManager.VIEW_TYPE.Right)
		end

		self.bindData.title = CarShopConfig.ColorTabNameDes[self.detailType + 1]
	else
		self.bindData.title = CarShopConfig.TabNameDes[self.optionType + 1]
		self.bindData.hasSecondTab = 1
		list = self.itemList[self.optionType]

		if self.optionType == OPTION_TYPE.WHEEL then
			gCarStoreManager:SetCameraState(gCarStoreManager.VIEW_TYPE.Wheel)
		else
			gCarStoreManager:SetCameraState(gCarStoreManager.VIEW_TYPE.Right)
		end
	end

	self.bindData.itemList:SetList(list)
end

function M:OnRefreshTopTabList(btn, index)
	local data = self.tabTopList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("CarStoreTab2Store"):GetStoreByWidget(btn)

	if store then
		store.icon = data.iconId
		btn.isSelected = self.detailType == index

		if btn.isSelected then
			self:SelectTab()
		end
	end
end

function M:OnSelectTopTab(data)
	self.detailType = data.selectedIndex

	self:SelectTab()
end

function M:OnRefreshItemList(btn, index, data)
	local store = nil

	if data.tIndex == 0 then
		store = gStoreManager:GetStoreGroup("PresetKitItemStore"):GetStoreByWidget(btn)
	else
		store = gStoreManager:GetStoreGroup("OptionalItemStore"):GetStoreByWidget(btn)
	end

	if store then
		btn.isSelected = self:CheckIsSelect(data)

		if btn.isSelected then
			self:SetSelectItemTypeIndex(btn.isSelected, data)
		end

		store.name = data.name
		store.iconId = data.iconId
		store.price = data.price
		store.moenyIconId = data.moenyIconId
	end
end

function M:OnChangeItem(btn, data)
	if data.optionType == OPTION_TYPE.PRESET then
		self.selectSet = data.Id

		self:SetDetailInfo()
	end

	self:SetSelectItemTypeIndex(btn.isSelected, data)

	if btn.isSelected then
		self:CheckIsLackMoney()
	end
end

function M:OnBuyBtnClick()
	local function buySuccessCb()
		gCarStoreManager:LoadEndTimeLine(self.itemInfo.VehicleSubType, 1)

		local function teleportSuccessCb()
			gPanelManager:Close(gPanelId.CAR_STORE_MAIN_PANEL)
		end

		gCarStoreManager:AskVehicleShopSpawnVehicle(self.itemInfo.vehicleId, teleportSuccessCb)
	end

	local moneyCfg = ConsumableConfig.GetConfig(self.itemInfo.moneyType)

	if moneyCfg then
		local text = string.format(CarShopConfig.FinalVerifyDes, self.bindData.totalPriceNum .. moneyCfg.Name, self.itemInfo.name)

		self.carStore:AskBuyCommodities(self.commodityList, self.commodityInfo, text, buySuccessCb)
	end
end

function M:CheckIsLackMoney()
	local totalPrice = self:CaculateTotalPrice()
	local isLackMoney = self.myMoneyCount < totalPrice
	self.bindData.isLackMoney = isLackMoney and 1 or 0
	self.bindData.totalPriceNum = totalPrice
	self.bindData.buyBtn.interactable = not isLackMoney
end

function M:SetInitSelectItemType()
	self.selectItemTypeIndex[OPTION_TYPE.PRESET] = self.selectSet
	self.selectItemTypeIndex[OPTION_TYPE.WHEEL] = self.selectWheel
	self.selectItemTypeIndex[OPTION_TYPE.DETAIL] = {
		[DETAIL_TYPE.IN_COLOR] = self.selectInColor,
		[DETAIL_TYPE.OUT_COLOR] = self.selectOutColor
	}
end

function M:SetSelectItemTypeIndex(isSelect, data)
	if isSelect then
		if self.selectItemTypeIndex[data.optionType] == nil then
			self.selectItemTypeIndex[data.optionType] = {}
		end

		if data.optionType == OPTION_TYPE.DETAIL then
			if data.detailType == DETAIL_TYPE.OUT_COLOR then
				self.selectOutColor = data.Id
				self.selectMaterial = 0

				self:InitMaterial()

				self.selectItemTypeIndex[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL] = self.selectMaterial
			end

			if self.selectItemTypeIndex[data.optionType][data.detailType] == nil then
				self.selectItemTypeIndex[data.optionType][data.detailType] = {}
			end

			self.selectItemTypeIndex[data.optionType][data.detailType] = data.Id

			self:SetDetailTypeSet(data.detailType, data.resourcePath)
		else
			self.selectItemTypeIndex[data.optionType] = data.Id

			self:SetOptionTypeSet(data.optionType, data.resourcePath)
		end
	end
end

function M:SetDetailTypeSet(detailType, resourcePath)
	if detailType == DETAIL_TYPE.IN_COLOR then
		gCarStoreManager:SetInColor(resourcePath)
	elseif detailType == DETAIL_TYPE.MATERIAL then
		gCarStoreManager:SetMaterial(resourcePath)
	elseif detailType == DETAIL_TYPE.OUT_COLOR then
		gCarStoreManager:SetOutColor(resourcePath)
	end
end

function M:SetOptionTypeSet(optionType, resourcePath)
	if optionType == OPTION_TYPE.WHEEL then
		gCarStoreManager:SetWheel(resourcePath)
	elseif optionType == OPTION_TYPE.PRESET then
		gCarStoreManager:SetCarSet(resourcePath)
		gCarStoreManager:SetWheel(self.selectId2ResourcePath[self.selectItemTypeIndex[OPTION_TYPE.WHEEL]])
		gCarStoreManager:SetInColor(self.selectId2ResourcePath[self.selectItemTypeIndex[OPTION_TYPE.DETAIL][DETAIL_TYPE.IN_COLOR]])
		gCarStoreManager:SetMaterial(self.selectId2ResourcePath[self.selectItemTypeIndex[OPTION_TYPE.DETAIL][DETAIL_TYPE.MATERIAL]])
		gCarStoreManager:SetOutColor(self.selectId2ResourcePath[self.selectItemTypeIndex[OPTION_TYPE.DETAIL][DETAIL_TYPE.OUT_COLOR]])
	end
end

function M:CheckIsSelect(data)
	if self.selectItemTypeIndex[data.optionType] then
		if data.optionType == OPTION_TYPE.DETAIL then
			if self.selectItemTypeIndex[data.optionType][data.detailType] then
				return self.selectItemTypeIndex[data.optionType][data.detailType] == data.Id
			end
		else
			return self.selectItemTypeIndex[data.optionType] == data.Id
		end
	end

	return false
end

function M:CaculateTotalPrice()
	self.commodityList = {}
	self.commodityInfo = {}
	local totalPrice = 0
	local defaultPrice = 0

	if self.selectItemTypeIndex[OPTION_TYPE.PRESET] then
		local cfg = CarShopSetConfig.GetConfig(self.selectItemTypeIndex[OPTION_TYPE.PRESET])

		if cfg then
			local defaultItem = {}
			local defaultOutColor = CarShopOutColorConfig.GetConfig(cfg.OutColor[1])

			if defaultOutColor then
				table.insert(defaultItem, defaultOutColor.CommodityId)
			end

			local defaultInColor = CarShopInColorConfig.GetConfig(cfg.InColor[1])

			if defaultInColor then
				table.insert(defaultItem, defaultInColor.CommodityId)
			end

			local defaultMaterial = CarShopMaterialConfig.GetConfig(defaultOutColor.MaterialId[1])

			if defaultMaterial then
				table.insert(defaultItem, defaultMaterial.CommodityId)
			end

			local defaultWheel = CarShopWheelConfig.GetConfig(cfg.Wheel[1])

			if defaultWheel then
				table.insert(defaultItem, defaultWheel.CommodityId)
			end

			for i = 1, #defaultItem do
				local comCfg = ShopCommodityCfg.GetConfig(defaultItem[i])

				if comCfg then
					defaultPrice = defaultPrice + comCfg.Price
				end
			end
		end
	end

	for optionType, Ids in pairs(self.selectItemTypeIndex) do
		if optionType == OPTION_TYPE.DETAIL then
			for detailType, Id in pairs(Ids) do
				for i = 1, #self.itemList[optionType][detailType] do
					if self.itemList[optionType][detailType][i].Id == Id then
						totalPrice = totalPrice + self.itemList[optionType][detailType][i].price

						if not self.commodityList[self.itemList[optionType][detailType][i].CommodityId] then
							local info = self.itemList[optionType][detailType][i]
							self.commodityList[info.CommodityId] = 1
							self.commodityInfo[info.CommodityId] = {
								iconId = info.iconId,
								name = info.name
							}
						end

						break
					end
				end
			end
		else
			for i = 1, #self.itemList[optionType] do
				if self.itemList[optionType][i].Id == Ids then
					totalPrice = totalPrice + self.itemList[optionType][i].price

					if not self.commodityList[self.itemList[optionType][i].CommodityId] then
						local info = self.itemList[optionType][i]
						self.commodityList[self.itemList[optionType][i].CommodityId] = 1

						if optionType == OPTION_TYPE.WHEEL then
							self.commodityInfo[info.CommodityId] = {
								iconId = info.iconId,
								name = info.name
							}
						end
					end

					break
				end
			end
		end
	end

	print("最终价格  price = " .. totalPrice - defaultPrice)

	self.commodityList[self.itemInfo.CommodityID] = 1

	return totalPrice - defaultPrice
end

function M:OnBtnChangeTab(step)
	if self.noCarSetList then
		return
	end

	local selectTopTabIndex = self:RefreshStep(self.bindData.topTabList.selectedIndex, step)

	self.bindData.topTabList:SelectItem(selectTopTabIndex)
end

function M:RefreshStep(curStep, step)
	local nextStep = curStep + step

	if nextStep < 0 then
		nextStep = #self.tabTopList - 1
	elseif nextStep >= #self.tabTopList then
		nextStep = 0
	end

	return nextStep
end
