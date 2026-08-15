local GameConfig = LTConfig.GameConfig
local StaticProps = {
	SHOW_TYPE = {
		SINGLE_ITEM = 0,
		SINGLE_PACKAGE = 1,
		MULTI_PACKAGE = 2
	}
}
C_CommonBuyWindowPanelStore = DefClass("C_CommonBuyWindowPanelStore", C_CommonBuyWindowPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.CommonBuyWindowPanelStore = C_CommonBuyWindowPanelStore
local M = C_CommonBuyWindowPanelStore

function M:ctor(name, id, isSub)
	self.callback = nil
	self.itemId = 0
	self.showType = M.SHOW_TYPE.SINGLE_ITEM
	self.range = {
		0,
		0
	}
	self.discount = 0
	self.refreshTime = 0
	self.data = {}
	self.buyNum = 0
	self.remainItemNum = 0
	self.timer = nil
end

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.tipsBtn.luaClick = self:CreateAction("OnTipsBtnClick")
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

function M:OnShow(panelId, data)
	if table.isNilOrEmpty(data) then
		print_error("C_CommonBuyWindowPanelStore:OnShow data is nil")
		self:OnCloseBtnClick()

		return
	end

	self:RefreshPage(data)
	self:RefreshTime()
end

function M:OnClose()
	return
end

function M:OnCloseBtnClick()
	gUIUtils:PlayAniClosePanel(self.bindData.animation, "S_Vx_NewCommonWindow_Close", gPanelId.S_COMMON_BUY_WINDOW)
end

function M:OnConfirmBtnClick()
	if self.buyNum <= 0 then
		return
	end

	if self.callback then
		self.callback(self.buyNum)

		self.callback = nil
	end

	self:OnCloseBtnClick()
end

local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:RefreshPage(data)
	self.itemId = data.itemId or 0
	self.range[1] = data.itemLimitMin or 1
	self.range[2] = data.itemLimitMax or 1

	if not data.isLimit then
		self.range[2] = GameConfig.ShopMaxNumber
	end

	self.remainItemNum = data.itemLimitMax
	self.callback = data.callback
	local itemInfo = gCommonItemManager:TryGetConsumableItem(self.itemId)

	if table.isNilOrEmpty(itemInfo) then
		itemInfo = gCommonItemManager:TryGetMallItem(self.itemId)
	end

	if table.isNilOrEmpty(itemInfo) then
		-- Nothing
	end

	if table.isNilOrEmpty(itemInfo) then
		print_error("C_CommonBuyWindowPanelStore:RefreshPage itemInfo is nil")
		self:OnCloseBtnClick()

		return
	end

	self.data = itemInfo
	self.data.moneyId = data.moneyId
	self.data.price = data.price or itemInfo.price or 0
	self.discount = data.discount or itemInfo.discount or 1
	self.refreshTime = data.refreshTime or itemInfo.refreshTime or -1
	local _, moneyCount = gCommonItemManager:GetMoneyIconAndCount(self.data.moneyId)
	self.range[2] = math.min(math.min(self.range[2], math.floor(moneyCount / self.data.price)), GameConfig.ShopMaxNumber)

	if itemInfo.isGiftPack then
		self.showType = data.showBar == true and M.SHOW_TYPE.MULTI_PACKAGE or M.SHOW_TYPE.SINGLE_PACKAGE
	else
		self.showType = M.SHOW_TYPE.SINGLE_ITEM
	end

	self.bindData.tabIndex = self.showType
	self.bindData.quality = itemInfo.quality
	self.bindData.titleLabel = data.title or LTConfig.TextScriptTextConfig.GetConfig(89900586).Text
	self.bindData.hasDiscount = BOOL2CTL[self.discount < 1]

	if self.bindData.hasDiscount == BOOL2CTL[true] then
		self.bindData.discountLabel = "-" .. math.floor((1 - self.discount) * 100) .. "%"
	end

	local itemNum = gCommonItemManager:GetItemNum(self.data.templateId)
	self.bindData.hasHave = BOOL2CTL[not itemInfo.isGiftPack and itemNum > 0]

	if self.bindData.hasHave == BOOL2CTL[true] then
		self.bindData.haveLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901017).Text, itemNum)
	end

	self.bindData.hasLimitCount = BOOL2CTL[data.isLimit == true]

	if self.bindData.hasLimitCount == BOOL2CTL[true] then
		if itemInfo.limitNum ~= 0 then
			self.bindData.countLabel = self.remainItemNum .. "/" .. itemInfo.limitNum
		else
			self.bindData.countLabel = self.remainItemNum
		end
	end

	self.bindData.nameLabel = itemInfo.name
	self.bindData.iconId = itemInfo.iconId
	self.bindData.showBtn = BOOL2CTL[self:HasRemainItem() and self.range[1] <= self.range[2]]
end

function M:OnBuyNumChange(num)
	self.buyNum = num
end

local timeTick = 3

function M:RefreshTime()
	if table.isNilOrEmpty(self.data) or self.STATE_OnShowOnce == false then
		return
	end

	local nextTime = self.refreshTime - timeTick

	if nextTime < 0 and self.data.crontabTime then
		self.refreshTime = gCS.LuaUtils.GetNextTime(self.data.crontabTime) - gCS.TimeManager.ServerUnixTime
	end

	self.refreshTime = nextTime
	self.bindData.hasRefreshTime = BOOL2CTL[self.refreshTime > 0]

	if self.bindData.hasRefreshTime == BOOL2CTL[true] then
		self.bindData.remainTimeLabel = gTimeUtils:GetLongTimeStrHaveDay(self.refreshTime)

		if self.timer then
			self.timer:Stop()
		end

		self.timer = Timer.New(function ()
			self:RefreshTime()
		end, timeTick):Start()
	end
end

function M:HasRemainItem()
	return self.remainItemNum ~= 0
end

function M:OnTipsBtnClick()
	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemId = self.data.templateId
	})
end
