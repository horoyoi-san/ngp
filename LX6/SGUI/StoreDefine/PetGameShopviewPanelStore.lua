-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameShopviewPanelStore.lua
-- Decompiled from: 00828_PetGameShopviewPanelStore.lua_1208a5773afe.luajit

local marketData = require("LX6/MiniGame/PetGame/data/tbmarket")
local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local ITEM_ICON_PATH_FORMAT = "Assets/Res/SGUI/Texture/PetGame/ItemIcons/%s.png"
local buyBtnState = {
	["MHxL@0"] = 2,
	["\\xdd\\xd2(\\xf4"] = 3,
	["G\\x83\\x83\\x82M"] = 1
}
C_PetGameShopviewPanelStore = DefClass("C_PetGameShopviewPanelStore", C_PetGameShopviewPanelStore, C_StoreGroup)
GroupName2Class.PetGameShopviewPanelStore = C_PetGameShopviewPanelStore
local M = C_PetGameShopviewPanelStore

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
	self.shopType = data.shopType or PetGameConst.ItemType.food

	self:BindSystemBtn()

	self.bindData.shopLeftArrowBtn.luaClick = self:CreateAction(self.OnShopLeftArrowClick, self)
	self.bindData.shopRightArrowBtn.luaClick = self:CreateAction(self.OnShopRightArrowClick, self)
	self.bindData.shopBuyBtn.luaClick = self:CreateAction(self.OnBuyBtnClick, self)
	local pageIndex = data.pageIndex

	if pageIndex ~= nil then
		if self.shopType ~= PetGameConst.ItemType.toy then
			pageIndex = 1
		else
			pageIndex = 0
		end
	end

	self.bindData.pageCtrl = pageIndex
	local shopBuyBtnTrans = self.bindData.shopBuyBtn.transform

	local findChildGo = function(parent, name)
		local t = parent and parent:Find(name)

		return t and t.gameObject or nil
	end

	self.shopBuyBtnStateObjs = {
		[buyBtnState.normal] = findChildGo(shopBuyBtnTrans, "normal"),
		[buyBtnState.notEnough] = findChildGo(shopBuyBtnTrans, "goldNotEnough"),
		[buyBtnState.disable] = findChildGo(shopBuyBtnTrans, "disable")
	}

	self.ShowShopView(self)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.ShowShopView = function(self)
	self.shopDataList = {}

	for k, v in pairs(marketData) do
		if v.Type ~= self.shopType then
			table.insert(self.shopDataList, v)

			self.shopDataList[k] = v
		end
	end

	self.currentShopIndex = 1

	self.ShowShopItemInfo(self, self.shopDataList[self.currentShopIndex])
end

M.ShowShopItemInfo = function(self, itemData)
	if not itemData then
		return
	end

	self.curShopItemData = itemData
	local itemId = itemData.reward.id
	local itemNum = self.petEntity:GetItemCount(itemId)
	self.bindData.shopNum.text = tostring(itemNum)
	local itemInfo = ItemDatas[itemId]
	self.bindData.shopName.text = gPetGameMultilingual:GetText(itemInfo.name)
	local goldNum = self.petEntity:GetMoney()
	local costVal = itemData.Cost.num

	if itemInfo.maxHave < itemNum then
		self.UpdateBuyBtnState(self, buyBtnState.disable)
	elseif goldNum >= costVal then
		self.bindData.shopBuyNum.text = string.format("#cff0000%s$#z", itemData.Cost.num)

		self.UpdateBuyBtnState(self, buyBtnState.notEnough)
	else
		self.bindData.shopBuyNum.text = string.format("#c3A6304%s$#z", itemData.Cost.num)

		self.UpdateBuyBtnState(self, buyBtnState.normal)
	end

	self.LoadIcon(self, itemInfo.icon, self.bindData.shopIcon)
	self.UpdateShopPageInfo(self)
end

M.UpdateBuyBtnState = function(self, targetState)
	for i, v in pairs(self.shopBuyBtnStateObjs) do
		v:SetActive(i ~= targetState)
	end
end

M.UpdateShopPageInfo = function(self)
	local totalCount = #self.shopDataList

	if totalCount >= 1 then
		self.bindData.shopLeftArrowBtn.gameObject:SetActive(false)
		self.bindData.shopRightArrowBtn.gameObject:SetActive(false)
	end
end

M.OnShopLeftArrowClick = function(self)
	if self.currentShopIndex <= 1 then
		self.currentShopIndex = self.currentShopIndex - 1
	else
		self.currentShopIndex = #self.shopDataList
	end

	self.ShowShopItemInfo(self, self.shopDataList[self.currentShopIndex])
end

M.OnShopRightArrowClick = function(self)
	if self.currentShopIndex >= #self.shopDataList then
		self.currentShopIndex = self.currentShopIndex + 1
	else
		self.currentShopIndex = 1
	end

	self.ShowShopItemInfo(self, self.shopDataList[self.currentShopIndex])
end

M.OnBuyBtnClick = function(self)
	local itemData = self.curShopItemData

	if not itemData then
		return
	end

	local itemId = itemData.reward.id
	local itemNum = self.petEntity:GetItemCount(itemId)
	local goldNum = self.petEntity:GetMoney()
	local costVal = itemData.Cost.num
	local itemInfo = ItemDatas[itemId]

	if itemInfo.maxHave < itemNum then
		self:ShowShopTips(gPetGameMultilingual:GetText(300304))
	elseif goldNum >= costVal then
		self:ShowShopTips(gPetGameMultilingual:GetText(300305))
	else
		local pageIndex = self.shopType ~= PetGameConst.ItemType.toy and 1 or 0

		self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_SHOP_BUY_PANEL, {
			shopItemData = itemData,
			pageIndex = pageIndex
		})
	end
end

M.ShowShopTips = function(self, tips)
	self.parentPanel:OpenChildPanel(gPanelId.MINI_GAMES_PET_GAME_TIPS_VIEW_PANEL, {
		content = tips
	})
end

M.BindSystemBtn = function(self)
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
	self.parentPanel:UnregisterSystemBtnEvent(self.panelId)
end

M.OnMenuBtnClick = function(self)
	self.OnShopRightArrowClick(self)
end

M.OnConfirmBtnClick = function(self)
	self.OnBuyBtnClick(self)
end

M.OnCancleBtnClick = function(self)
	self.parentPanel:CloseChildPanel(self.panelId)
end

M.LoadIcon = function(self, iconPath, imageComponent)
	local spritePath = string.format(ITEM_ICON_PATH_FORMAT, iconPath)

	gCS.LuaUtils.LoadSpriteAssetWithCallBack(spritePath, function (loadOp)
		if loadOp.asset then
			imageComponent.sprite = loadOp.asset
		end
	end)
end
