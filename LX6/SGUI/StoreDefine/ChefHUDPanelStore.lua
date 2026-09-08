-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefHUDPanelStore.lua
-- Decompiled from: 01420_ChefHUDPanelStore.lua_fc8a8540c480.luajit

local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefConfig = LTConfig.ChefConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ChefFoodPrepareConfig = LTConfig.ChefFoodPrepareConfig
local ChefFoodPrepareTypeConfig = LTConfig.ChefFoodPrepareTypeConfig
local ChefCookConfig = LTConfig.ChefCookConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager
local GUIDE_TINDEX = {
	["nFxl\\+"] = 1,
	["y\\xa7\\xb6\\xa3\\xb3"] = 0
}
local SHICAI_STATE = {
	["V#~P"] = 1,
	["\\x88\\xbe\\xbbf;\\xea6"] = 2,
	["2G\\x83\\x83\\x82M"] = 0
}

local GetCookConfigByCookType = function(cookType)
	for i = 0, ChefCookConfig.count - 1 do
		local cookCfg = ChefCookConfig.LoadAt(i)

		if cookCfg and cookCfg.CookType ~= cookType then
			return cookCfg
		end
	end

	return nil
end

local GetOrCreateGroup = function(groups, key)
	local group = groups[key]

	if not group then
		group = {
			items = {}
		}
		groups[key] = group
	end

	return group
end

local GetSortedGroupKeys = function(groups)
	local keys = {}

	for key in pairs(groups) do
		table.insert(keys, key)
	end

	table.sort(keys)

	return keys
end

C_ChefHUDPanelStore = DefClass("C_ChefHUDPanelStore", C_ChefHUDPanelStore, C_StoreGroup)
GroupName2Class.ChefHUDPanelStore = C_ChefHUDPanelStore
local M = C_ChefHUDPanelStore

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
	self.DEFINE_DynamicOnCameraUpdate = true
end

M.DefineAllVariables = function(self)
	self.kitchen = nil
	self.games = {}
	self.freeListItem = {}
	self.freeListStore = {}
	self.fireStores = {}
	self.nearStores = {}
	self.gameHintPos = {}
	self.guideRecipeId = 0
	self.guideListData = {}
	self.guideStepCount = 0
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	if self.kitchen ~= nil then
		print_error("当前无可用厨房！")

		return
	end

	self.RefreshGameData(self)
	self.RefreshGuideRecipe(self)
end

M.OnClose = function(self)
	self.kitchen = nil

	table.clear(self.games)

	self.games = {}

	table.clear(self.guideListData)

	self.guideStepCount = 0
end

M.OnUpdate = function(self)
	if table.count(self.games) < 0 then
		return
	end

	for index, btn in pairs(self.freeListItem) do
		local game = self.games[index]

		if gCS.LuaUtils.IsNull(game) then
			-- Nothing
		elseif not game.GetIsOccupied(game) then
			local store = self.freeListStore[index]

			if store then
				local fireLevel = game.HeatLevel

				self.UpdateFireList(self, fireLevel, index)

				local dis = game.GetGameDistance(game)

				if dis < ChefConfig.SceneUISwitchDistance then
					store.distanceCtrl = 1

					self.UpdateNearList(self, game, index)
				else
					store.distanceCtrl = 0

					self.UpdateTotalInfo(self, game, index)
				end
			end

			self.UpdateTemplatePos(self, btn, index)
		end
	end
end

M.OnCameraUpdate = function(self)
	if table.count(self.games) < 0 then
		return
	end

	for index, btn in pairs(self.freeListItem) do
		local game = self.games[index]

		if not game.GetIsOccupied(game) then
			self.UpdateTemplatePos(self, btn, index)
		end
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_GAME_ADD] = function (_)
			self:RefreshGameData()
		end,
		[gEventConstants.CHEF_GAME_REMOVE] = function (_)
			self:RefreshGameData()
		end,
		[gEventConstants.CHEF_GAME_ENTER] = function (_)
			self.bindData.stateCtrl = 1

			gStoreManager:UnregisterDynamicOnUpdate(self)
			gStoreManager:UnregisterDynamicOnCameraUpdate(self)
		end,
		[gEventConstants.CHEF_GAME_EXIT] = function (_)
			self.bindData.stateCtrl = 0

			self:RefreshUpdateState()
		end,
		[gEventConstants.CHEF_BUSINESS_INVENTORY_CHANGED] = function (_)
			self:RefreshGuideList()
		end,
		[gEventConstants.CHEF_ADD_INGREDIENT_CHANGED] = function (_)
			self:RefreshGuideList()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.freeList.luaRenderItem = self.CreateAction(self, "OnRenderFreeListItem")

	self.bindData.freeList.onGetTIndex = function(_)
		return 0
	end

	self.bindData.guideList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderGuideListItem")
	self.bindData.guideList.onGetTIndex = self.CreateAction(self, "OnGetGuideListTIndex")
	self.bindData.changeBtn.luaClick = self.CreateAction(self, "OnClickChangeBtn")
end

M.OnRenderFreeListItem = function(self, btn, index)
	local game = self.games[index + 1]
	self.freeListItem[index + 1] = btn
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefSceneTemplate"):GetStoreById(id)

	if store then
		self.freeListStore[index + 1] = store
		local fireList = store.fireList
		fireList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderFireListItem", index + 1)

		fireList:SetSimpleList(3)

		local ingredientList = game:GetFoodIngredientList()
		local recipeId = game:GetCurrentRecipeId()
		local cfg = ChefRecipeConfig.GetConfig(recipeId)
		local nearList = store.nearList
		nearList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderNearListItem", {
			itemIndex = index + 1,
			ingredientList = ingredientList,
			recipeId = recipeId
		})

		nearList:SetSimpleList(table.count(cfg.Ingredientsid))

		local itemStore = gStoreManager:GetStoreGroup("ChefGameItemTemplate"):GetStoreById(store.totalItem.gameObject:GetInstanceID())

		if itemStore then
			local itemId = cfg.Consumableid
			local itemCfg = ConsumableConfig.GetConfig(itemId)
			local recipeIconId = itemCfg.SItemIconId
			itemStore.iconId = recipeIconId
		end
	end
end

M.OnRenderFireListItem = function(self, itemIndex, btn, index)
	self.fireStores[itemIndex] = self.fireStores[itemIndex] or {}
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefFireTemplate"):GetStoreById(id)

	if store then
		self.fireStores[itemIndex][index + 1] = store
	end
end

M.OnRenderNearListItem = function(self, data, btn, index)
	local recipeId = data.recipeId
	local cfg = ChefRecipeConfig.GetConfig(recipeId)
	local allList = cfg.Ingredientsid
	local ingredientId = allList[index + 1]
	local ingredientList = data.ingredientList
	local hasPut = ingredientList:Contains(ingredientId)
	local itemIndex = data.itemIndex
	self.nearStores[itemIndex] = self.nearStores[itemIndex] or {}
	local insId = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefGameSceneItemTemplate"):GetStoreById(insId)

	if store then
		local nearData = {
			store = store,
			hasPut = hasPut,
			ingredientId = ingredientId
		}
		self.nearStores[itemIndex][index + 1] = nearData
		local foodItemId = ChefIngredientsConfig.GetConfig(ingredientId).Consumableid
		local iconId = ConsumableConfig.GetConfig(foodItemId).SItemIconId
		store.iconId = iconId
		store.emptyCtrl = hasPut and 0 or 1
	end
end

M.OnClickChangeBtn = function(self)
	gPanelManager:CheckShow(gPanelId.S_CHEF_HANDBOOK_PANEL)
end

M.GetIngredientConsumableId = function(self, ingredientId)
	if not ingredientId or ingredientId < 0 then
		return nil
	end

	local ingredientCfg = ChefIngredientsConfig.GetConfig(ingredientId)

	if not ingredientCfg then
		return nil
	end

	local itemId = ingredientCfg.Consumableid

	return itemId and itemId <= 0 and itemId or nil
end

M.AddGuideItem = function(self, items, itemId, afterItemId)
	if not itemId or itemId < 0 then
		return
	end

	table.insert(items, {
		itemId = itemId,
		afterItemId = afterItemId and afterItemId <= 0 and afterItemId or nil
	})
end

M.CollectRecipeGuideItems = function(self, recipeCfg, items, afterItemId)
	local ingredientIds = recipeCfg.Ingredientsid

	if not ingredientIds then
		return
	end

	for i = 1, #ingredientIds do
		self.AddGuideItem(self, items, self.GetIngredientConsumableId(self, ingredientIds[i]), afterItemId)
	end
end

M.AddGuideSection = function(self, titleText, items)
	if not next(items) then
		return
	end

	self.guideStepCount = self.guideStepCount + 1

	table.insert(self.guideListData, {
		tIndex = GUIDE_TINDEX.Title,
		step = self.guideStepCount,
		titleText = titleText
	})
	table.insert(self.guideListData, {
		tIndex = GUIDE_TINDEX.Materials,
		items = items
	})
end

M.BuildGuideListData = function(self)
	table.clear(self.guideListData)

	self.guideStepCount = 0

	if not self.guideRecipeId or self.guideRecipeId < 0 then
		return
	end

	local cfg = ChefRecipeConfig.GetConfig(self.guideRecipeId)

	if not cfg then
		print_error("固定的子菜谱配置缺失！ guideRecipeId = ", self.guideRecipeId)

		return
	end

	local prepareGroups = {}
	local foodPrepareIds = cfg.FoodPrepareID

	if foodPrepareIds then
		for i = 1, #foodPrepareIds do
			local foodPrepareId = foodPrepareIds[i]

			if foodPrepareId and foodPrepareId <= 0 then
				local foodPrepareCfg = ChefFoodPrepareConfig.GetConfig(foodPrepareId)

				if foodPrepareCfg then
					local group = GetOrCreateGroup(prepareGroups, foodPrepareCfg.MethodType)

					self.AddGuideItem(self, group.items, foodPrepareCfg.BeforePrepareConsumableid, foodPrepareCfg.AfterPrepareConsumableid)
				end
			end
		end
	end

	local prepareKeys = GetSortedGroupKeys(prepareGroups)

	for i = 1, #prepareKeys do
		local methodType = prepareKeys[i]
		local prepareTypeCfg = ChefFoodPrepareTypeConfig.GetConfig(methodType)

		self:AddGuideSection(prepareTypeCfg and prepareTypeCfg.FoodPrepareTypeName or nil, prepareGroups[methodType].items)
	end

	local prepareRecipeGroups = {}
	local recipePrepareIds = cfg.RecipePrepareID

	if recipePrepareIds then
		for i = 1, #recipePrepareIds do
			local recipePrepareId = recipePrepareIds[i]

			if recipePrepareId and recipePrepareId <= 0 then
				local prepareRecipeCfg = ChefRecipeConfig.GetConfig(recipePrepareId)

				if prepareRecipeCfg then
					local group = GetOrCreateGroup(prepareRecipeGroups, prepareRecipeCfg.CookType)
					local prepareItemId = self.GetIngredientConsumableId(self, prepareRecipeCfg.FoodPrepareIngredientsid)

					self.CollectRecipeGuideItems(self, prepareRecipeCfg, group.items, prepareItemId)
				end
			end
		end
	end

	local prepareRecipeKeys = GetSortedGroupKeys(prepareRecipeGroups)

	for i = 1, #prepareRecipeKeys do
		local cookType = prepareRecipeKeys[i]
		local prepareCookCfg = GetCookConfigByCookType(cookType)

		self:AddGuideSection(prepareCookCfg and prepareCookCfg.CookPrepareName or nil, prepareRecipeGroups[cookType].items)
	end

	local cookItems = {}

	self:CollectRecipeGuideItems(cfg, cookItems, nil)

	local cookCfg = GetCookConfigByCookType(cfg.CookType)

	self:AddGuideSection(cookCfg and cookCfg.CookTypeName or nil, cookItems)
end

M.RefreshGuideRecipe = function(self)
	self.guideRecipeId = ChefManager.GetGuideRecipeId()

	self.BuildGuideListData(self)
	self.RefreshGuideList(self)
end

M.RefreshGuideList = function(self)
	self.bindData.guideList:SetSimpleList(#self.guideListData)
end

M.OnGetGuideListTIndex = function(self, index)
	local data = self.guideListData[index + 1]

	return data and data.tIndex or GUIDE_TINDEX.Title
end

M.OnSimpleRenderGuideListItem = function(self, btn, index)
	local data = self.guideListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= GUIDE_TINDEX.Title then
		store.titleText = data.titleText or ""
		store.stepText = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefStepText).Text .. " " .. data.step
	elseif data.tIndex ~= GUIDE_TINDEX.Materials and store.materialsList then
		store.materialsList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderGuideShicaiItem", data.items)

		store.materialsList:SetSimpleList(#data.items)
	end
end

M.OnSimpleRenderGuideShicaiItem = function(self, items, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local item = items and items[index + 1]

	if not item then
		return
	end

	local itemCfg = ConsumableConfig.GetConfig(item.itemId)

	if not itemCfg then
		return
	end

	store.iconId = itemCfg.SItemIconId
	store.nameText = itemCfg.Name
	store.stateCtrl = self.GetGuideItemState(self, item)
end

M.GetGuideItemState = function(self, item)
	if item.afterItemId and self.GetItemCount(self, item.afterItemId) <= 0 then
		return SHICAI_STATE.Complete
	end

	if self.GetItemCount(self, item.itemId) <= 0 then
		return SHICAI_STATE.Normal
	end

	return SHICAI_STATE.Lack
end

M.GetItemCount = function(self, itemId)
	if not itemId or itemId < 0 then
		return 0
	end

	if self.kitchen and self.kitchen.isBusiness then
		return self.kitchen:GetInventoryItemCountByConsumableId(itemId)
	else
		return gCommonItemManager:GetPackItemNum(itemId)
	end
end

M.RefreshUpdateState = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_CHEF_COOK_BEGIN_PANEL) or gPanelManager:IsPanelShowing(gPanelId.S_CHEF_COOK_PANEL) then
		gStoreManager:UnregisterDynamicOnUpdate(self)
		gStoreManager:UnregisterDynamicOnCameraUpdate(self)
	end

	self.RefreshGameData(self)
end

M.RefreshGameData = function(self)
	if not self.kitchen then
		return
	end

	table.clear(self.games)
	table.clear(self.freeListItem)
	table.clear(self.freeListStore)
	table.clear(self.fireStores)
	table.clear(self.nearStores)
	table.clear(self.gameHintPos)

	local gameList = self.kitchen.gameList

	if gameList.Count < 0 then
		gStoreManager:UnregisterDynamicOnUpdate(self)
		gStoreManager:UnregisterDynamicOnCameraUpdate(self)
	else
		gStoreManager:RegisterDynamicOnUpdate(self)
		gStoreManager:RegisterDynamicOnCameraUpdate(self)

		for i = 0, gameList.Count - 1 do
			local recipeId = gameList[i]:GetCurrentRecipeId()

			if recipeId and recipeId == 0 then
				table.insert(self.games, gameList[i])

				local hintPos = gameList[i]:GetHintPos()

				table.insert(self.gameHintPos, hintPos)
			end
		end
	end

	self.bindData.freeList:SetList(#self.games)
end

M.UpdateFireList = function(self, fireLevel, itemIndex)
	local stores = self.fireStores[itemIndex]

	if not stores then
		return
	end

	for i = 1, 3 do
		local store = stores[i]

		if store then
			if i < fireLevel then
				store.stateCtrl = 0
			else
				store.stateCtrl = 1
			end
		end
	end
end

M.UpdateNearList = function(self, game, itemIndex)
	local stores = self.nearStores[itemIndex]

	if not stores then
		return
	end

	for i = 1, #stores do
		local data = stores[i]
		local ingredientId = data.ingredientId
		local store = data.store
		local hasPut = data.hasPut

		if hasPut then
			local progress = game.GetIngredientProgress(game, ingredientId)
			local cfg = ChefIngredientsConfig.GetConfig(ingredientId)

			if cfg then
				local cookedThreshold = cfg.CookedValue
				local overCookedThreshold = cfg.OvercookedValue
				local realProgress = progress < cookedThreshold and progress / cookedThreshold or (progress - cookedThreshold) / (overCookedThreshold - cookedThreshold)
				store.cookedFill.fillAmount = realProgress
			end
		else
			store.cookedFill.fillAmount = 0
		end
	end
end

M.UpdateTotalInfo = function(self, game, itemIndex)
	local store = self.freeListStore[itemIndex]
	local itemStore = gStoreManager:GetStoreGroup("ChefGameItemTemplate"):GetStoreById(store.totalItem.gameObject:GetInstanceID())

	if itemStore then
		itemStore.cookedFill.fillAmount = game.GetTotalIngredientProgress(game)
	end
end

local tmpVec = Vector2.New(0, 0)
local tmpVec3 = Vector3.New(0, 0)

M.UpdateTemplatePos = function(self, btn, itemIndex)
	local pos = self.gameHintPos[itemIndex]
	local x, y, _ = gCS.LuaUtils.WorldToScreenPointProjected(pos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)

	tmpVec:Set(x, y)

	local uiPos = gCS.LuaUtils.ScreenPointUI(self.bindData.freeList.rectTransform, tmpVec)
	btn.gameObject.transform.localPosition = uiPos
	local playerPosition = gClientUtils.GetPlayerPosition()

	tmpVec3:Set(playerPosition.X, playerPosition.Y, playerPosition.Z)

	local dis = Vector3.Distance(pos, tmpVec3)
	local scale = self.kitchen:GetHintCurveScale(dis)

	btn.gameObject.transform:SetLocalScale(scale)
end
