local MoneyType = UX.Game.MoneyType
local BuyButtonStateCtrl = {
	No_Enough = 0,
	Enough = 1
}
local AdPopUpCtrl = {
	Normal = 1,
	Success = 0
}
C_BuyHouseAdPanelStore = DefClass("BuyHouseAdPanelStore", C_BuyHouseAdPanelStore, C_StoreGroup)
GroupName2Class.BuyHouseAdPanelStore = C_BuyHouseAdPanelStore
local M = C_BuyHouseAdPanelStore

function M:OnAwake()
	self.bindData.btnClose.luaClick = self:CreateAction("OnCloseClick")
	self.bindData.btnBuy.luaClick = self:CreateAction("OnBuyClick")
	self.bindData.adList.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.adList.luaBeginDrag = self:CreateAction("OnListBeginDrag")
	self.bindData.adList.luaEndDrag = self:CreateAction("OnListEndDrag")
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitEvent()
	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.houseId, self.csImageIndex = unpack(args)
	self.csImageIndex = self.csImageIndex and self.csImageIndex - 1 or 0
	self.hasBuySuccess = nil
end

function M:InitEvent()
	self:RegisterSingleEvent(gEventConstants.ON_BUY_HOUSE_SUCCESS, self:CreateAction("BuyHouseSuccess"))
end

function M:InitView()
	self.bindData.adPopUp = AdPopUpCtrl.Normal
	local needMoney = gBuyHouseUtils.GetHousePrice(self.houseId)

	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	local houseCfg = LTConfig.HouseConfig.GetConfig(self.houseId)
	self.bindData.price = needMoney
	self.bindData.name = houseCfg.Name
	self.bindData.petCount = houseCfg.PetCount
	self.bindData.parkingSpaceCount = houseCfg.ParkingSpaceCount
	self.bindData.bedRoomCount = houseCfg.BedRoomCount
	self.bindData.description = houseCfg.Description
	local isEnough = gBuyHouseUtils.CheckBuyHouseMoneyEnough(self.houseId)
	self.bindData.buyButtonState = isEnough and BuyButtonStateCtrl.Enough or BuyButtonStateCtrl.No_Enough
	local hasBuyTheHouse = gBuyHouseUtils.CheckHasBuyTheHouse(self.houseId)
	self.bindData.showBuyViewActive = not hasBuyTheHouse

	self:PlayAdAnimation("fx_s_houseadpanel_open")

	local shopId = houseCfg.ShopId
	local shopCfg = LTConfig.ShopConfig.GetConfig(shopId)
	local adSizeTransform = self.bindData.adSizeTransform

	if shopCfg.Scale then
		local scaleX, scaleY = unpack(shopCfg.Scale)
		adSizeTransform.localScale = Vector3.Fetch(scaleX, scaleY, 1)
	end

	if shopCfg.Offset then
		local offsetX, offsetY = unpack(shopCfg.Offset)
		adSizeTransform.localPosition = adSizeTransform.localPosition + Vector3.New(offsetX, offsetY, 0)
	end

	self:InitAdListView()
end

function M:PlayAdAnimation(animationName)
	self.bindData.adWidget.anim:Stop()
	self.bindData.adWidget.anim:Play(animationName)
end

function M:InitAdListView()
	local houseCfg = LTConfig.HouseConfig.GetConfig(self.houseId)
	local imageList = houseCfg.Image
	local viewDataList = {}

	for _, imageId in ipairs(imageList) do
		table.insert(viewDataList, {
			imageId = imageId
		})
	end

	self.bindData.adList:SetList(viewDataList)
	self.bindData.adList:GoToIndex(self.csImageIndex, true)
	self:PlayAdListAutoScroll()
end

function M:PlayAdListAutoScroll()
	self.autoScrollCo = coroutine.stop(self.autoScrollCo)
	self.autoScrollCo = coroutine.start(function ()
		while true do
			coroutine.wait(LTConfig.HouseConfig.BuyHouseAdScrollIntervalTime)
			self.bindData.adList:GoNext(1, false)
		end
	end)
end

function M:OnCloseClick()
	self:ClosePanel()
end

function M:ClosePanel()
	local signalKey = ("BuyHousePanelCloseAnimation%d"):format(self.houseId)

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey
	})
	self:PlayAdAnimation("fx_s_houseadpanel_close")

	self.playCloseAnimation = coroutine.start(function ()
		coroutine.wait(0.3)
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnBuyClick()
	if gBuyHouseUtils.CheckBuyHouseMoneyEnough(self.houseId) then
		gBuyHouseUtils.BuyTheHouse(self.houseId)
	else
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900852).Text)
	end
end

function M:BuyHouseSuccess(_, houseId)
	if self.houseId == houseId then
		self.hasBuySuccess = true
		self.bindData.showBuyViewActive = false
		self.bindData.adPopUp = AdPopUpCtrl.Success
		self.successTweenCo = coroutine.start(function ()
			local tweenTime = LTConfig.HouseConfig.BuyHouseSuccessTweenTime

			coroutine.wait(tweenTime)
			self:ClosePanel()
		end)
	end
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("HouseAdImage"):GetStoreByWidget(btn)

	if store then
		local imageCfg = LTConfig.SguiImageConfig.GetConfig(data.imageId)
		store.imageIcon = imageCfg.ImgPath
	end
end

function M:OnListBeginDrag()
	self.autoScrollCo = coroutine.stop(self.autoScrollCo)
end

function M:OnListEndDrag()
	self:PlayAdListAutoScroll()
end

function M:OnClose()
	self.successTweenCo = coroutine.stop(self.successTweenCo)
	self.autoScrollCo = coroutine.stop(self.autoScrollCo)
	self.playCloseAnimation = coroutine.stop(self.playCloseAnimation)

	self:ClearMessageEvents()

	if self.hasBuySuccess then
		self:ShowBuySuccessPopUp()
	end
end

function M:ShowBuySuccessPopUp()
	local price = gBuyHouseUtils.GetHousePrice(self.houseId)
	local logoId = LTConfig.HouseConfig.BuyHouseCostTipIcon
	local textId = LTConfig.HouseConfig.BuyHouseCostTipTextId

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.PayTips, {
		Param = {
			moneyEnough = true,
			value = price,
			logoId = logoId,
			textId = textId
		}
	})
end
