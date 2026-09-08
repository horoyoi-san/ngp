-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PetGameFoodviewPanelStore.lua
-- Decompiled from: 01056_PetGameFoodviewPanelStore.lua_fbb16a771c60.luajit

local ItemDatas = require("LX6/MiniGame/PetGame/data/tbitems")
local PetGameConst = require("LX6/MiniGame/PetGame/PetGameConst")
local ITEM_ICON_PATH_FORMAT = "Assets/Res/SGUI/Texture/PetGame/ItemIcons/%s.png"
C_PetGameFoodviewPanelStore = DefClass("C_PetGameFoodviewPanelStore", C_PetGameFoodviewPanelStore, C_StoreGroup)
GroupName2Class.PetGameFoodviewPanelStore = C_PetGameFoodviewPanelStore
local M = C_PetGameFoodviewPanelStore

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

	self.bindData.foodLeftArrow.luaClick = self:CreateAction(self.OnFoodLeftArrowClick, self)
	self.bindData.foodRightArrow.luaClick = self:CreateAction(self.OnFoodRightArrowClick, self)
	self.bindData.eatFoodBtn.luaClick = self:CreateAction(self.OnEatFoodConfirmBtnClick, self)
	self.viewType = data.viewType or "food"
	local pageIndex = data.pageIndex

	if pageIndex ~= nil then
		if self.viewType ~= "toy" then
			pageIndex = 1
		else
			pageIndex = 0
		end
	end

	self.bindData.pageCtrl = pageIndex

	self.ShowFoodView(self, data.itemId)
end

M.OnClose = function(self)
	self.UnBindSystemBtn(self)
end

M.ShowFoodView = function(self, itemId)
	local dataList = {}
	local allList, freeId, itemType = nil

	if self.viewType ~= "toy" then
		allList = self.petEntity:GetAllToys() or {}
		freeId = self.petEntity:GetFreeToys()
		itemType = PetGameConst.ItemType.toy
	else
		allList = self.petEntity:GetAllFood() or {}
		freeId = self.petEntity:GetFreeFood()
		itemType = PetGameConst.ItemType.food
	end

	dataList = table.clone(allList)

	if freeId then
		dataList[freeId] = {
			["N\\xa1\\xb7\\xa1\\xa2"] = 1,
			["[\\xb7\\x9c\\x86D"] = true,
			itemId = freeId,
			itemType = itemType
		}
	end

	self.currentFoodIndex = 1
	self.foodDataList = table.to_array(dataList)
	itemId = itemId or 0

	table.sort(self.foodDataList, function (a, b)
		return a.itemId <= b.itemId
	end)
	table.sort(self.foodDataList, function (a, b)
		return a.itemId ~= itemId
	end)
	self:ShowFoodInfo(self.foodDataList[1])
end

M.ShowFoodInfo = function(self, itemData)
	if not itemData then
		return
	end

	if itemData.isFree then
		self.bindData.foodNum.text = "∞"
	else
		self.bindData.foodNum.text = itemData.count
	end

	local itemInfo = ItemDatas[itemData.itemId]
	self.bindData.foodName.text = gPetGameMultilingual:GetText(itemInfo.name)

	self:LoadIcon(itemInfo.icon, self.bindData.foodIcon)
	self:UpdateFoodPageInfo()
end

M.UpdateFoodPageInfo = function(self)
	local totalCount = #self.foodDataList

	if totalCount >= 1 then
		self.bindData.foodLeftArrow.gameObject:SetActive(false)
		self.bindData.foodRightArrow.gameObject:SetActive(false)
	end
end

M.OnFoodLeftArrowClick = function(self)
	if self.currentFoodIndex <= 1 then
		self.currentFoodIndex = self.currentFoodIndex - 1
	else
		self.currentFoodIndex = #self.foodDataList
	end

	self.ShowFoodInfo(self, self.foodDataList[self.currentFoodIndex])
end

M.OnFoodRightArrowClick = function(self)
	if self.currentFoodIndex >= #self.foodDataList then
		self.currentFoodIndex = self.currentFoodIndex + 1
	else
		self.currentFoodIndex = 1
	end

	self.ShowFoodInfo(self, self.foodDataList[self.currentFoodIndex])
end

M.OnEatFoodConfirmBtnClick = function(self)
	local tipsPanelId = gPanelId.MINI_GAMES_PET_GAME_TIPS_PANEL
	local currentItem = self.foodDataList[self.currentFoodIndex]
	local tipType = self.viewType ~= "toy" and "playToy" or "eatFood"

	self.parentPanel:OpenChildPanel(tipsPanelId, {
		tipType = tipType,
		itemData = currentItem,
		returnPanel = self.panelId,
		returnData = {
			itemId = currentItem and currentItem.itemId,
			viewType = self.viewType
		}
	})
end

M.FeedPet = function(self, itemData)
	if not itemData then
		return
	end

	local success = self.petEntity:FeedPet(itemData.itemId, itemData.isFree)

	if not success then
		return
	end

	self.parentPanel:CloseChildPanel(self.panelId)
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
	self.OnFoodRightArrowClick(self)
end

M.OnConfirmBtnClick = function(self)
	self.OnEatFoodConfirmBtnClick(self)
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
