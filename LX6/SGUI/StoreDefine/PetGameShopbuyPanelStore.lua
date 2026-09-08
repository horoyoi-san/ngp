-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameShopbuyPanelStore.lua
-- Decompiled from: 00825_PetGameShopbuyPanelStore.lua_d7e617c32f32.luajit

local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
C_PetGameShopbuyPanelStore = DefClass("C_PetGameShopbuyPanelStore", C_PetGameShopbuyPanelStore, C_StoreGroup)
GroupName2Class.PetGameShopbuyPanelStore = C_PetGameShopbuyPanelStore
local M = C_PetGameShopbuyPanelStore

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	self.UnBindSystemBtn(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
	self.UnBindSystemBtn(self)
end

M.OnShow = function(self, panelId, data)
	self.parentPanel = data.parent
	self.panelId = panelId
	self.petEntity = gPetGameManager.currentGame and gPetGameManager.currentGame.pet

	self:BindSystemBtn()

	self.bindData.shopbuyLeftArrow.luaClick = self:CreateAction(self.OnBuyViewLeftArrowClick, self)
	self.bindData.shopbuyRightArrow.luaClick = self:CreateAction(self.OnBuyViewRightArrowClick, self)
	self.bindData.buyShopViewBtn.luaClick = self:CreateAction(self.ShopBuyItem, self)
	self.bindData.buyViewNumText.luaValueChanged = self:CreateAction(self.OnInputChanged, self)
	self.bindData.buyViewNumText.luaEndEdit = self:CreateAction(self.OnInputEndEdit, self)
	local pageIndex = data.pageIndex or 0
	self.bindData.pageCtrl = pageIndex

	self:InitBuyView(data.shopItemData)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.InitBuyView = function(self, itemData)
	self.buyNum = 1
	self.price = 1
	self.maxCanBuyNum = 1

	if not itemData then
		self.UpdateShopBuyNum(self)

		return
	end

	self.buyItemId = itemData.reward and itemData.reward.id
	self.costItemId = itemData.Cost and itemData.Cost.id
	self.price = itemData.Cost and itemData.Cost.num or 1
	local itemNum = self.buyItemId and self.petEntity:GetItemCount(self.buyItemId) or 0
	local goldNum = self.costItemId and self.petEntity:GetItemCount(self.costItemId) or 0
	local itemInfo = self.buyItemId and ItemDatas[self.buyItemId]
	local maxHave = itemInfo and itemInfo.maxHave or 0
	local maxBuyNum = maxHave - itemNum
	local canBuyNum = self.price <= 0 and math.floor(goldNum / self.price) or 0
	self.maxCanBuyNum = math.max(1, math.min(maxBuyNum, canBuyNum))
	self.bindData.shopBuyGoldText.text = tostring(goldNum)

	self:UpdateShopBuyNum()
end

M.UpdateShopBuyNum = function(self)
	self._suppressInputChange = true
	self.bindData.buyViewNumText.text = tostring(self.buyNum)
	self._suppressInputChange = false

	self.UpdateCostText(self)
end

M.UpdateCostText = function(self)
	local cost = self.buyNum * self.price
	self.bindData.totleMoneyText.text = string.format("%s$", cost)
end

M.OnInputChanged = function(self, text)
	if self._suppressInputChange then
		return
	end

	local n = tonumber(text)
	n = n or 1
	n = math.floor(n)

	if n >= 1 then
		n = 1
	end

	if self.maxCanBuyNum >= n then
		n = self.maxCanBuyNum
		self._suppressInputChange = true
		self.bindData.buyViewNumText.text = tostring(n)
		self._suppressInputChange = false
	end

	self.buyNum = n

	self.UpdateCostText(self)
end

M.OnInputEndEdit = function(self, text, isCanceled)
	self._suppressInputChange = true
	self.bindData.buyViewNumText.text = tostring(self.buyNum)
	self._suppressInputChange = false
end

M.OnBuyViewLeftArrowClick = function(self)
	self.buyNum = self.buyNum - 1

	if self.buyNum >= 1 then
		self.buyNum = 1
	end

	self.UpdateShopBuyNum(self)
end

M.OnBuyViewRightArrowClick = function(self)
	self.buyNum = self.buyNum + 1

	if self.maxCanBuyNum >= self.buyNum then
		self.buyNum = 1
	end

	self.UpdateShopBuyNum(self)
end

M.ShopBuyItem = function(self)
	local cost = self.buyNum * self.price

	self.petEntity:RemoveItem(self.costItemId, cost)
	self.petEntity:AddItem(self.buyItemId, self.buyNum)

	local tips = gPetGameMultilingual:GetText(300306)

	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_TIPS_VIEW_PANEL, {
		content = tips
	})
end

M.BindSystemBtn = function(self)
	if not self.parentPanel then
		return
	end

	self.isMenuBtnPressed = false
	local eventHandler = {
		panelId = self.panelId,
		OnMenuBtnClick = self.OnMenuBtnClick,
		OnConfirmBtnClick = self.OnConfirmBtnClick,
		OnCancleBtnClick = self.OnCancleBtnClick,
		target = self
	}

	self.parentPanel:RegisterSystemBtnEvent(eventHandler)
end

M.UnBindSystemBtn = function(self)
	if not self.parentPanel or not self.panelId then
		return
	end

	self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
end

M.OnMenuBtnClick = function(self)
	self.OnBuyViewRightArrowClick(self)
end

M.OnConfirmBtnClick = function(self)
	self.ShopBuyItem(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end
