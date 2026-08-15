local ShopConfig = LTConfig.ShopConfig
local MessageConfig = LTConfig.MessageConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_BuyCarPanelStore = DefClass("C_BuyCarPanelStore", C_BuyCarPanelStore, C_StoreGroup)
GroupName2Class.BuyCarPanelStore = C_BuyCarPanelStore
local M = C_BuyCarPanelStore
local PAGE_TYPE = {
	SHOP = 0,
	BUY_MSG = 1
}
local SELECT_TYPE = {
	FALSE = 0,
	TRUE = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.backBtn2.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.backBtn3.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.buyBtn.luaClick = self:CreateAction("OnBuyClick")
	self.bindData.yesBtn.luaClick = self:CreateAction("OnYesClick")
	self.bindData.noBtn.luaClick = self:CreateAction("OnNoClick")
	self.bindData.baikeBtn.luaClick = self:CreateAction("OnBaikeBtnClick")
	self.bindData.carList.luaSimpleRenderItem = self:CreateAction("OnRefreshCarList")
	self.bindData.carList.luaSelectedChanged = self:CreateAction("OnChangeCar")
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
	return
end

function M:OnShow(panelId, data)
	self.bindData.page = PAGE_TYPE.SHOP

	if data and data.id then
		self.shopId = data.id

		gShopManager:SetShopIdEnterTime(self.shopId)

		gClientToGameDelegate:AskNpcShopCommodityInfo(self.shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				local commodityInfoList = npcShopInfo.CommodityInfoList
				self.info = commodityInfoList

				self:InitInfo()
			end
		end
	end
end

function M:OnClose()
	gShopManager:NpcShopExitTime(self.shopId)
end

function M:InitInfo(info)
	self.selectCarInfo = nil
	local info = self.info
	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg == nil then
		return
	end

	self.moneyType = cfg.Money
	self.myMoneyCount = gPlayerItemManager:GetPackItemNum(cfg.Money)
	local moenyIconId = nil
	self.carItems = {}
	local pendingAsyncCount = 0
	local completeAsyncCount = 0

	for i = 1, info.Count do
		if info[i].Status ~= 1 then
			if info[i].Status ~= 3 then
				local CommodityID = info[i].TemplateId
				local SCCfg = ShopCommodityCfg.GetConfig(CommodityID)

				if SCCfg == nil then
					return
				end

				local view = {}
				local itemCfg = ConsumableConfig.GetConfig(SCCfg.ConsumableID)

				if itemCfg then
					view.CommodityID = CommodityID
					view.ConsumableID = SCCfg.ConsumableID
					view.name = itemCfg.Name
					view.quality = itemCfg.Quality
					view.iconId = itemCfg.SItemIconId
					local moenyItemCfg = ConsumableConfig.GetConfig(cfg.Money)

					if moenyItemCfg then
						view.moneyIconId = moenyItemCfg.SItemIconId

						if moenyIconId == nil then
							moenyIconId = moenyItemCfg.SItemIconId
						end
					end

					view.moneyNum = SCCfg.Price
					view.isMoneyLack = self.myMoneyCount < SCCfg.Price

					if info[i].Count == -1 then
						pendingAsyncCount = pendingAsyncCount + 1

						local function cb(vehicleList)
							view.hasBuy = false

							for i = 1, #vehicleList do
								if vehicleList[i].Id == itemCfg.BindId then
									view.hasBuy = true

									break
								end
							end

							table.insert(self.carItems, view)

							completeAsyncCount = completeAsyncCount + 1

							if completeAsyncCount == pendingAsyncCount then
								self:allDoneCallback(moenyIconId)
							end
						end

						gClientToGameDelegate:AskGetUnlockedVehicles().Callback = function (err, playerVehicleClientDetails)
							if err == MessageConfig.Ok then
								if cb then
									cb(playerVehicleClientDetails)
								end
							else
								print_error("AskGetUnlockedVehicles failed, err = " .. tostring(err))

								view.hasBuy = false
							end
						end
					else
						view.hasBuy = info[i].Count == 0

						table.insert(self.carItems, view)
					end
				end
			end
		end
	end

	if pendingAsyncCount == 0 then
		self:allDoneCallback(moenyIconId)
	end
end

function M:allDoneCallback(moenyIconId)
	self:SortCarList(self.carItems)
	self.bindData.carList:SetSimpleList(#self.carItems)
	self.bindData.carList:SelectItem(0, true)

	self.bindData.moneyNum = self.myMoneyCount
	self.bindData.moneyIcon = moenyIconId
end

function M:OnRefreshCarList(btn, index)
	local data = self.carItems[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("PhoneBuyCarTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		store.name = data.name
		store.qualityCtrl = data.quality
		store.isMoneyLack = data.isMoneyLack and SELECT_TYPE.FALSE or SELECT_TYPE.TRUE
		store.moneyNum = data.moneyNum
		store.moneyIconId = data.moneyIconId
		btn.interactable = not data.hasBuy or false

		if btn.isSelected then
			self.bindData.buyBtn.interactable = not data.isMoneyLack and not data.hasBuy
		end
	end
end

function M:OnChangeCar(selector)
	self.selectIndex = selector.selectedIndex + 1
	local data = self.carItems[self.selectIndex]

	if data then
		self.bindData.buyBtn.interactable = not data.isMoneyLack and not data.hasBuy
		self.selectCarInfo = data
	end
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_BUY_CAR_PANEL)
end

function M:OnBuyClick()
	if self.selectCarInfo == nil then
		return
	end

	if not self.selectCarInfo.hasBuy then
		local content = MessageConfig.GetConfig(MessageConfig.VehicleShopConfirm).Content
		self.bindData.tipsMsg = gString.Format(content, self.selectCarInfo.moneyNum, self.selectCarInfo.name)
		self.bindData.page = PAGE_TYPE.BUY_MSG
	end
end

function M:OnYesClick()
	local function cb()
		self.myMoneyCount = gPlayerItemManager:GetPackItemNum(self.moneyType)
		self.bindData.moneyNum = self.myMoneyCount

		for i = 1, #self.carItems do
			if self.carItems[i].ConsumableID == self.selectCarInfo.ConsumableID and not self.carItems[i].hasBuy then
				self.carItems[i].hasBuy = true
			end

			self.carItems[i].isMoneyLack = self.myMoneyCount < self.carItems[i].moneyNum
		end

		self:SortCarList(self.carItems)
		self.bindData.carList:SetSimpleList(#self.carItems)
		self.bindData.carList:SetNavSelectToTop()
		self.bindData.carList:SelectItem(0, true)
	end

	if self.selectCarInfo and self.selectCarInfo.CommodityID > 0 and not self.selectCarInfo.hasBuy then
		gClientToGameDelegate:AskBuyCommodity(self.selectCarInfo.CommodityID, 1).Callback = function (err)
			if err == MessageConfig.Ok then
				if cb then
					cb()
				end
			else
				print_error("NPC商店购买商品失败", err)
			end

			self.bindData.page = PAGE_TYPE.SHOP
		end
	end
end

function M:OnNoClick()
	self.bindData.page = PAGE_TYPE.SHOP
end

function M:OnBaikeBtnClick()
	if not self.selectCarInfo then
		return
	end

	local itemCfg = ConsumableConfig.GetConfig(self.selectCarInfo.ConsumableID)

	if not itemCfg or not itemCfg.BindId then
		return
	end

	gPanelManager:CheckShow(gPanelId.BAIKE_CAR_PREVIEW_PANEL, {
		targetItemId = itemCfg.BindId
	})
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
