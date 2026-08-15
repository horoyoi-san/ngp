local ShopConfig = LTConfig.ShopConfig
local MessageConfig = LTConfig.MessageConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local VehicleConfig = LTConfig.VehicleConfig
C_CarStoreMainPanelStore = DefClass("C_CarStoreMainPanelStore", C_CarStoreMainPanelStore, C_StoreGroup)
GroupName2Class.CarStoreMainPanelStore = C_CarStoreMainPanelStore
local M = C_CarStoreMainPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.buyBtn.luaClick = self:CreateAction("OnBuyBtnClick")
	self.bindData.hideBtn.luaClick = self:CreateAction("OnHideBtnClick")
	self.bindData.cancelClick.luaClick = self:CreateAction("OnCancelBtnClick")
	self.bindData.tabRect.OnRenderTab = self:CreateAction("OnRenderTab")
	self.bindData.buyItemList.luaSimpleRenderItem = self:CreateAction("OnRefreshBuyItemList")
	self.bindData.buyItemList.luaClick = self:CreateAction("OnClickBuyItem")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.mouseCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnMouseRespondInput")
	end
end

function M:OnDestroy()
	gCS.GuiUtils.SetXuWeiWeatherState(false)
	gShopManager:NpcShopExitTime(self.shopId)
end

function M:OnShow(panelId, data)
	gCS.GuiUtils.SetXuWeiWeatherState(true, 5)
	gCarStoreManager:InitCarShopCfg()

	self.isShowUI = false
	self.buySuccessCb = nil

	if data then
		self:OnHideBtnClick()

		self.shopId = data.id

		gShopManager:SetShopIdEnterTime(self.shopId)

		self.storeId = data.storeId or 0

		gClientToGameDelegate:AskNpcShopCommodityInfo(self.shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local commodityInfoList = npcShopInfo.CommodityInfoList
				self.info = commodityInfoList

				self:InitInfo()
			end
		end
	end
end

function M:InitInfo()
	self.selectCarInfo = nil
	self.bindData.tabRect.selectedIndex = 0
	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg == nil then
		return
	end

	local info = self.info
	self.bindData.shopName = cfg.ShopName
	self.bindData.shopIcon = cfg.ShopLogo
	local scaleVec = self.bindData.parentTrans:GetLocalScale()

	self.bindData.modelTrans:SetLocalScaleX(1 / scaleVec.x)
	self.bindData.modelTrans:SetLocalScaleY(1 / scaleVec.y)
	self.bindData.modelTrans:SetLocalScaleZ(1 / scaleVec.z)
	gCarStoreManager:OnSetVehiclePosParent(self.bindData.carRoot)
	self.SubGroup.MoneyTemplateStore:SetData(cfg.Money)

	self.myMoneyCount = gPlayerItemManager:GetPackItemNum(cfg.Money)
	self.carItems = {}
	self.carTypeItems = {}

	for i = 1, info.Count do
		local CommodityID = info[i].TemplateId
		local SCCfg = ShopCommodityCfg.GetConfig(CommodityID)

		if SCCfg == nil then
			return
		end

		local view = {}
		local itemCfg = ConsumableConfig.GetConfig(SCCfg.ConsumableID)

		if itemCfg then
			view.hasBuy = info[i].Count == 0
			view.state = 0

			if info[i].Status == 1 then
				view.state = 2
			end

			if view.hasBuy then
				view.state = 1
			end

			view.CommodityID = CommodityID
			view.ConsumableID = SCCfg.ConsumableID
			view.BelongBrand = SCCfg.BelongBrand
			view.UnlockConditionsDes = SCCfg.UnlockConditionsDes
			view.name = itemCfg.Name
			view.quality = itemCfg.Quality
			view.iconId = itemCfg.SItemIconId
			view.VehicleSubType = itemCfg.VehicleSubType
			view.moneyType = cfg.Money
			local moenyItemCfg = ConsumableConfig.GetConfig(cfg.Money)

			if moenyItemCfg then
				view.moneyIconId = moenyItemCfg.SMoneyIconId
			end

			view.vehicleId = itemCfg.BindId
			view.moneyNum = self:GetCarPrice(view.vehicleId)
			local vehicleCfg = VehicleConfig.GetConfig(view.vehicleId)

			if vehicleCfg then
				view.iconId = vehicleCfg.SBuyVehicleIconId
				view.VehicleSeatNum = vehicleCfg.VehicleSeatNum
				view.VehicleType = vehicleCfg.VehicleType
				view.VehicleAttr = vehicleCfg.VehicleAttr
				view.brandId = vehicleCfg.VehicleBrandPicIcon
				view.brandLogo = vehicleCfg.SVehicleBrandIcon
			end

			table.insert(self.carItems, view)
		end
	end

	self:SortCarList(self.carItems)
end

function M:GetCarPrice(vehicleId)
	local price = nil
	local carSetListCfg = gCarStoreManager:GetCarSetByVehicleId(vehicleId)

	if carSetListCfg then
		for i = 1, #carSetListCfg do
			local cfg = carSetListCfg[i]
			local itemCfg = ShopCommodityCfg.GetConfig(cfg.CommodityId)

			if itemCfg then
				if price == nil then
					price = itemCfg.Price
				else
					price = math.min(price, itemCfg.Price)
				end
			end
		end
	end

	return price
end

function M:OnClose()
	if self.commodityInfoList then
		self.commodityInfoList = nil
	end
end

function M:OnActiveDeviceChange(device)
	return
end

function M:SortCarList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		return a.ConsumableID < b.ConsumableID
	end)
	table.sort(itemList, function (a, b)
		if a.hasBuy == b.hasBuy then
			if a.isMoneyLack == b.isMoneyLack then
				return b.quality < a.quality
			end

			return not a.isMoneyLack and b.isMoneyLack
		end

		return not a.hasBuy and b.hasBuy
	end)
end

function M:OnBackBtnClick()
	if self.selectCarInfo then
		self.selectCarInfo = nil
		self.bindData.tabRect.selectedIndex = 0

		gCarStoreManager:SetCameraCenter(self.isShowUI, true)
	else
		gPanelManager:Close(gPanelId.CAR_STORE_MAIN_PANEL)
	end
end

function M:OnBuyBtnClick()
	gClientToGameDelegate:AskBuyCommodities(self.commodityList).Callback = function (err)
		if err == MessageConfig.Ok then
			if self.buySuccessCb then
				self.buySuccessCb()
			end
		else
			print_error("NPC商店购买商品list失败", err)
		end

		self.bindData.isShowBuyConfirm = 1
	end
end

function M:OnHideBtnClick()
	self.isShowUI = not self.isShowUI
	self.bindData.isShowUI = self.isShowUI and 0 or 1

	gCarStoreManager:SetCameraCenter(self.isShowUI)
end

function M:OnCancelBtnClick()
	self.bindData.isShowBuyConfirm = 1
end

function M:OnRenderTab(index, widget)
	local function func(index, itemInfo)
		if index == 0 then
			self.selectCarInfo = nil
		else
			self.selectCarInfo = itemInfo
		end

		self.bindData.tabRect.selectedIndex = index
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	store.m_Id = self.m_Id

	if self.selectCarInfo then
		store:InitInfo(self, self.selectCarInfo)
	else
		store:InitInfo(self.carItems, func)
	end
end

function M:AskBuyCommodities(commodityList, commodityInfo, text, buySuccessCb)
	if table.isNilOrEmpty(commodityList) then
		return
	end

	self.commodityList = commodityList
	self.buySuccessCb = buySuccessCb
	self.bindData.buyConfirmText = text
	self.bindData.isShowBuyConfirm = 0
	self.commodityInfoList = {}

	for i, info in pairs(commodityInfo) do
		if info then
			local view = {
				iconId = info.iconId,
				name = info.name
			}

			table.insert(self.commodityInfoList, view)
		end
	end

	self.bindData.buyItemList:SetList(#self.commodityInfoList)
end

function M:OnRefreshBuyItemList(btn, index)
	local data = self.commodityInfoList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("BuycarSettlementItemStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		store.name = data.name
	end
end

function M:OnClickBuyItem(btn, data)
	print("OnClickBuyItem")
end

function M:OnUpdate()
	if self.dragGamePad and self.gamePadPos and self.gamePadPos ~= Vector2.zero then
		gCameraUtils:DoRotateCameraByGamePad(1, self.gamePadPos.x, self.gamePadPos.y)
	end
end

function M:OnMouseRespondInput(context)
	if context.started then
		self.dragGamePad = true
	end

	if context.performed then
		local rotateParam = context:ReadValueVector2()
		self.gamePadPos = rotateParam * Time.deltaTime * 300 * -1
	end

	if context.canceled then
		self.dragGamePad = false
		self.gamePadPos = nil
	end
end
