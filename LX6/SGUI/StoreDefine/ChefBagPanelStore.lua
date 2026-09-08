-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefBagPanelStore.lua
-- Decompiled from: 01481_ChefBagPanelStore.lua_895b9c21bb1e.luajit

local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ChefFoodPrepareConfig = LTConfig.ChefFoodPrepareConfig
local ChefSeasoningConfig = LTConfig.ChefSeasoningConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local CookType = {
	I6xL = 2,
	["\\xec\\xd53\\xff"] = 0,
	["\\xa8z"] = 4,
	["\\xea\\xcf86\\xe8"] = 1,
	["~\\xba\\xa7\\xae\\xbb"] = 3
}
C_ChefBagPanelStore = DefClass("C_ChefBagPanelStore", C_ChefBagPanelStore, C_StoreGroup)
GroupName2Class.ChefBagPanelStore = C_ChefBagPanelStore
local M = C_ChefBagPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.bag = {}
	self.seasonings = {}
	self.currentRecipe = nil
	self.hideNum = false
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if data then
		self.currentRecipe = data
	else
		self.currentRecipe = nil

		FrameTimer.New(function ()
			self:RefreshBag()
		end, 1):Start()
		self:RefreshSeasoning()
	end

	self.bindData.switchCtrl = 0
end

M.OnClose = function(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_BAG_HIDE] = function (_, hide)
			if self.rootGo then
				self.rootGo:SetActive(not hide)
			end
		end,
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "RefreshSeasoning"),
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_IDLE] = self.CreateAction(self, "RefreshBagView"),
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_START] = self.CreateAction(self, "RefreshBagView"),
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_END] = self.CreateAction(self, "RefreshBagView"),
		[gEventConstants.CHEF_BUSINESS_INVENTORY_CHANGED] = self.CreateAction(self, "RefreshBagView"),
		[gEventConstants.CHEF_ADD_INGREDIENT_CHANGED] = self.CreateAction(self, "RefreshBagView")
	}
end

M.RegisterWidget = function(self)
	self.bindData.switchBtn.luaClick = self.CreateAction(self, "OnClickSwitchBtn")
	self.bindData.bagList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderBagListItem")
	self.bindData.bagList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderBagListItem")
	self.bindData.seasonList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderSeasonListItem")
	self.bindData.seasonList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSeasonListItem")
end

M.OnClickSwitchBtn = function(self)
	if not self.bindData.switchCtrl then
		self.bindData.switchCtrl = 0
	else
		self.bindData.switchCtrl = 1 - self.bindData.switchCtrl
	end
end

M.OnSimpleRenderBagListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.bag[index + 1]
	local itemId = data.consumableId
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId
	store.numText = self.GetItemCount(self, L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen(), itemId)

	if data.hasPut then
		btn.interactable = false
	else
		btn.interactable = true
	end

	if self.hideNum then
		store.hideNumCtrl = 1
	else
		store.hideNumCtrl = 0
	end
end

M.OnSimpleRenderSeasonListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefSeasonTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.seasonings[index + 1]
	local id = data.id
	local itemId = ChefSeasoningConfig.GetConfig(id).Consumableid
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId
	store.numText = self.GetItemCount(self, L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen(), itemId)
	store.hideNumCtrl = 0
end

M.RefreshBagView = function(self)
	if self.isCookMode then
		self.RefreshBagWithCurrentRecipe(self)
	else
		self.RefreshBag(self)
	end
end

M.GetItemCount = function(self, kitchen, itemId)
	if kitchen and kitchen.isBusiness then
		return kitchen.GetInventoryItemCountByConsumableId(kitchen, itemId)
	else
		return gCommonItemManager:GetPackItemNum(itemId)
	end
end

M.RefreshBag = function(self)
	local kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	table.clear(self.bag)

	local allIngredient = {}
	local addIngredient = {}

	for i = 0, ChefIngredientsConfig.count - 1 do
		local cfg = ChefIngredientsConfig.LoadAt(i)

		table.insert(allIngredient, cfg)

		addIngredient[cfg.Consumableid] = true
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if self.GetItemCount(self, kitchen, itemId) <= 0 then
			local data = {
				id = allIngredient[i].Id,
				consumableId = itemId
			}

			table.insert(self.bag, data)
		end
	end

	if kitchen and kitchen.isBusiness then
		for i = 0, ChefFoodPrepareConfig.count - 1 do
			local cfg = ChefFoodPrepareConfig.LoadAt(i)

			if not addIngredient[cfg.BeforePrepareConsumableid] and self.GetItemCount(self, kitchen, cfg.BeforePrepareConsumableid) <= 0 then
				local data = {
					id = 0,
					consumableId = cfg.BeforePrepareConsumableid
				}

				table.insert(self.bag, data)
			end

			if not addIngredient[cfg.AfterPrepareConsumableid] and self.GetItemCount(self, kitchen, cfg.AfterPrepareConsumableid) <= 0 then
				local data = {
					id = 0,
					consumableId = cfg.AfterPrepareConsumableid
				}

				table.insert(self.bag, data)
			end
		end
	end

	self.bindData.bagList:SetSimpleList(#self.bag)
end

M.RefreshBagWithCurrentRecipe = function(self)
	table.clear(self.bag)

	local allIngredient = {}

	for i = 0, ChefIngredientsConfig.count - 1 do
		local cfg = ChefIngredientsConfig.LoadAt(i)

		table.insert(allIngredient, cfg)
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if self.GetItemCount(self, L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen(), itemId) <= 0 and self.CheckIsInCurrentRecipe(self, allIngredient[i].Id) then
			local data = {
				id = allIngredient[i].Id
			}

			if self.checkFunc and self.checkFunc(data.id) then
				data.hasPut = true
			else
				data.hasPut = false
			end

			data.consumableId = itemId

			table.insert(self.bag, data)
		end
	end

	self.bindData.bagList:SetSimpleList(#self.bag)
end

M.RefreshSeasoning = function(self)
	table.clear(self.seasonings)

	local allIngredient = {}

	for i = 0, ChefSeasoningConfig.count - 1 do
		local cfg = ChefSeasoningConfig.LoadAt(i)

		table.insert(allIngredient, cfg)
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if self.GetItemCount(self, nil, itemId) <= 0 then
			local data = {
				id = allIngredient[i].Id
			}

			table.insert(self.seasonings, data)
		end
	end

	self.bindData.seasonList:SetSimpleList(#self.seasonings)
end

M.RegisterListClickEvent = function(self, cb)
	self.bindData.bagList.luaSimpleClick = function(btn, index)
		cb(self.bag[index + 1])
	end
end

M.UnRegisterListClickEvent = function(self)
	self.bindData.bagList.luaSimpleClick = nil
	self.bindData.seasonList.luaSimpleClick = nil
end

M.EnterCookMode = function(self, clickCb, clickSeasonCb, checkFunc, recipeId, cookType)
	self.bindData.bagList.luaSimpleClick = function(btn, index)
		clickCb(self.bag[index + 1], btn)
	end

	self.bindData.seasonList.luaSimpleClick = function(btn, index)
		clickSeasonCb(self.seasonings[index + 1], btn)
	end

	self.isCookMode = true
	self.hideNum = true
	self.currentRecipe = recipeId

	if cookType ~= CookType.StirFry or cookType ~= CookType.Stew or cookType ~= CookType.Steam then
		self.bindData.canSwitchCtrl = 0
	else
		self.bindData.canSwitchCtrl = 1
	end

	self.checkFunc = checkFunc

	self.RefreshBagWithCurrentRecipe(self)
	self.RefreshSeasoning(self)
end

M.ExitCookMode = function(self)
	self.isCookMode = false
	self.bindData.canSwitchCtrl = 0
	self.hideNum = false
	self.checkFunc = nil

	self.UnRegisterListClickEvent(self)
	self.RefreshBag(self)
	self.RefreshSeasoning(self)
end

M.CheckIsInCurrentRecipe = function(self, id)
	local recipeCfg = ChefRecipeConfig.GetConfig(self.currentRecipe)
	local ingredients = recipeCfg.Ingredientsid

	return table.contains(ingredients, id)
end
