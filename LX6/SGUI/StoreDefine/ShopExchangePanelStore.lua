-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ShopExchangePanelStore.lua
-- Decompiled from: 01316_ShopExchangePanelStore.lua_cc11293f57c0.luajit

local MoneyType = UX.Game.MoneyType
local MessageConfig = LTConfig.MessageConfig
local ShopCommon = require("LX6/GUI/Shop/ShopCommon")
C_ShopExchangePanelStore = DefClass("C_ShopExchangePanelStore", C_ShopExchangePanelStore, C_StoreGroup)
GroupName2Class.ShopExchangePanelStore = C_ShopExchangePanelStore
local M = C_ShopExchangePanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.currentItem.luaClick = self.CreateAction(self, "OnCommonItemClick")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "ExchangeMoney")
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, "OnExit")
end

M.OnShow = function(self, panelId, data)
	self.toMoney = data.ToMoney
	self.bindData.titleLabel = LTConfig.TextScriptTextConfig.GetConfig(89900705).Text

	self.InitExchangeMoney(self)
end

M.InitExchangeMoney = function(self)
	if self.toMoney ~= MoneyType.Money then
		self.fromMoney = MoneyType.BindingGold
	elseif self.toMoney ~= MoneyType.BindingGold then
		self.fromMoney = MoneyType.Gold
	elseif self.toMoney ~= MoneyType.Gold then
		self.fromMoney = MoneyType.BindingGold
	else
		print_error("传入money类型不对，不予以显示")
	end

	self.exchangeRate = gShopManager:GetExchangeRate(self.fromMoney, self.toMoney)
	self.maxMoney = gUIUtils:GetMoneyByType(self.fromMoney)

	if not table.contains(MoneyType, self.fromMoney) or not table.contains(MoneyType, self.toMoney) then
		print_error("货币类型不存在， from ", self.fromMoney, "To", self.toMoney)

		return
	end

	self:OnItemNumChange(1)
	self.SubGroup.CommonBuyNumSliderStore:SetData({
		range = {
			1,
			self.maxMoney
		},
		data = {
			moneyId = self.fromMoney,
			price = self.exchangeRate
		},
		valChangeCallback = self:CreateAction("OnItemNumChange")
	})
end

M.OnItemNumChange = function(self, buyNum)
	self.buyNum = buyNum

	self.RefreshItemDisplay(self, self.bindData.currentItem, self.fromMoney, buyNum)
	self.RefreshItemDisplay(self, self.bindData.targetItem, self.toMoney, buyNum * self.exchangeRate)
end

M.RefreshItemDisplay = function(self, btn, moneyType, count)
	local itemId = gCommonItemManager:GetItemIdByMoneyType(moneyType)
	local itemData = gCommonItemManager:GetItemRenderData({
		itemId = itemId,
		itemNum = count
	})

	gCommonItemManager:OnCommonItemRender(btn, 0, itemData)

	btn.luaClick = self:CreateActionWithArgs("OnShowItemRenderData", itemData, gCommonItemManager)
end

M.ExchangeMoney = function(self)
	local goldCount = gUIUtils:GetMoneyByType(MoneyType.Gold)
	local fromCount = self.buyNum

	if self.fromMoney ~= MoneyType.BindingGold then
		ShopCommon.ExchangeMoney(MoneyType.BindingGold, MoneyType.Gold, fromCount, self.CreateAction(self, "OnExit"))
	elseif self.fromMoney ~= MoneyType.Gold then
		if fromCount < goldCount then
			ShopCommon.ExchangeMoney(self.fromMoney, self.toMoney, fromCount, self.CreateAction(self, "OnExit"))
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.GoldToMall, self:CreateAction("OnExit"))
		end
	else
		print_error("当前没有添加这类金币组兑换，fromMoneyType = " .. self.fromMoney .. "  ,toMoneyType = " .. self.toMoney)
	end
end

M.OnClose = function(self)
end

M.OnExit = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.animation, "S_Vx_CommonBomb_Close", gPanelId.S_SHOP_EXCHANGE_PANEL)
end
