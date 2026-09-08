-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefCookBeginPanelStore.lua
-- Decompiled from: 01482_ChefCookBeginPanelStore.lua_c7c65d02fb62.luajit

local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefMainRecipeConfig = LTConfig.ChefMainRecipeConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local ChefCookConfig = LTConfig.ChefCookConfig
local CookType = {
	I6xL = 2,
	["\\xec\\xd53\\xff"] = 0,
	["\\xa8z"] = 4,
	["\\xea\\xcf86\\xe8"] = 1,
	["~\\xba\\xa7\\xae\\xbb"] = 3
}
local PrepareType = {
	["Y-rP"] = 1,
	["\\xe9\\xc9\r6\\xf4"] = 2
}
C_ChefCookBeginPanelStore = DefClass("C_ChefCookBeginPanelStore", C_ChefCookBeginPanelStore, C_StoreGroup)
GroupName2Class.ChefCookBeginPanelStore = C_ChefCookBeginPanelStore
local M = C_ChefCookBeginPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.game = nil
	self.entityId = nil
	self.nowCookType = CookType.Unknown
	self.currentTab = 0
	self.selectedIndex = 1
	self.selectedMainIngredientIndex = 1
	self.selectedRecipe = nil
	self.currentSubRecipeId = nil
	self.mainRecipeList = {}
	self.mainIngredientsMap = {}
	self.firstSubRecipeMap = {}
	self.prepareRecipes = {}
	self.prepareListData = {}
	self.currentIngredients = {}
	self.currentMainIngredients = {}
	self.currentMatchedRecipes = {}
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.game = data
	self.entityId = self.game:GetEntityId()
	self.nowCookType = self.game:GetCookType()

	self:InitTabList()
	self:SwitchTab(0)
end

M.OnClose = function(self)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.dishItem.luaClick = self.CreateAction(self, "OnClickDishItem")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.cookList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCookListItem")
	self.bindData.cookList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickCookList")
	self.bindData.prepareList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderPrepareListItem")
	self.bindData.prepareList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickPrepareList")
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickTabList")
	self.bindData.infoList.onGetTIndex = self.CreateAction(self, "OnInfoListGetTIndex")
	self.bindData.infoList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderInfoListItem")
end

M.OnClickDishItem = function(self)
end

M.OnClickConfirmBtn = function(self)
	if self.selectedRecipe then
		local isPrepare = self.currentTab ~= 1

		self.game:StartGame(self.selectedRecipe, isPrepare)
		gPanelManager:Close(gPanelId.S_CHEF_COOK_BEGIN_PANEL)
	end
end

M.OnClickCloseBtn = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "@Hcbq\t,",
		entityInstanceId = self.entityId
	})
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
	gPanelManager:Close(gPanelId.S_CHEF_COOK_BEGIN_PANEL)
end

M.InitTabList = function(self)
	self.bindData.tabList:SetSimpleList(2)
	self.bindData.tabList:SetItemSelected(0, true)
end

M.OnSimpleRenderTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefBeginTabTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if index ~= 0 then
		for i = 0, ChefCookConfig.count - 1 do
			local cfg = ChefCookConfig.LoadAt(i)

			if cfg and cfg.CookType ~= self.nowCookType then
				store.titleText = cfg.CookTypeName
			end
		end
	else
		store.titleText = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefPrepareName).Text
	end
end

M.OnSimpleClickTabList = function(self, btn, index)
	self.SwitchTab(self, index)
end

M.SwitchTab = function(self, tabIndex)
	self.currentTab = tabIndex
	self.bindData.stateCtrl = tabIndex
	self.selectedIndex = 1
	self.selectedMainIngredientIndex = 1

	if self.currentTab ~= 0 then
		self.InitCookData(self)
	else
		self.InitPrepareData(self)
	end
end

M.OnSimpleRenderCookListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefMenuItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.mainRecipeList[index + 1]

	if data then
		store.nameText = data.name
		store.iconId = data.iconId
	end
end

M.OnSimpleClickCookList = function(self, btn, index)
	self.selectedIndex = index + 1
	self.selectedMainIngredientIndex = 1

	self.RefreshAfterSelect(self)
end

M.OnSimpleRenderPrepareListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefBeginItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.prepareRecipes[index + 1]

	if data then
		store.nameText = data.name
		store.iconId = data.iconId
	end
end

M.OnSimpleClickPrepareList = function(self, btn, index)
	self.selectedIndex = index + 1
	self.selectedMainIngredientIndex = 1

	self.RefreshAfterSelect(self)
end

M.OnInfoListGetTIndex = function(self, csIndex)
	local itemData = self.prepareListData[csIndex + 1]

	if itemData then
		return itemData.tIndex
	end

	return 0
end

M.OnSimpleRenderInfoListItem = function(self, btn, index)
	local itemData = self.prepareListData[index + 1]

	if not itemData then
		return
	end

	local tIndex = itemData.tIndex

	if tIndex ~= 0 then
		self.RenderTitleTemplate(self, btn, itemData)
	elseif tIndex ~= 1 then
		self.RenderIngredientsListTemplate(self, btn, itemData)
	elseif tIndex ~= 2 then
		self.RenderIngredientsSelectTemplate(self, btn, itemData)
	elseif tIndex ~= 3 then
		self.RenderRecipeListTemplate(self, btn, itemData)
	end
end

M.RenderTitleTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup("ChefCookBeginTitleTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = itemData.text
	store.iconId = 0
end

M.RenderIngredientsListTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup("ChefCookBeginIngredientsListTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.currentIngredients = itemData.ingredients or {}
	store.ingredientsList.luaSimpleRenderItem = self:CreateAction("OnRenderIngredientItem")

	store.ingredientsList:SetSimpleList(#self.currentIngredients)
end

M.RenderIngredientsSelectTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup("ChefCookBeginIngredientsSelectListTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.currentMainIngredients = itemData.mainIngredients or {}
	store.selectList.luaSimpleRenderItem = self:CreateAction("OnRenderMainIngredientItem")
	store.selectList.luaSimpleClick = self:CreateAction("OnClickMainIngredientItem")

	store.selectList:SetSimpleList(#self.currentMainIngredients)

	if #self.currentMainIngredients <= 0 then
		store.selectList:SetItemSelected(self.selectedMainIngredientIndex - 1, true)
	end
end

M.RenderRecipeListTemplate = function(self, btn, itemData)
	local store = gStoreManager:GetStoreGroup("ChefCookRecipeListTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.currentMatchedRecipes = itemData.matchedRecipes or {}
	store.recipeList.luaSimpleRenderItem = self:CreateAction("OnRenderMatchedRecipeItem")

	store.recipeList:SetSimpleList(#self.currentMatchedRecipes)
end

M.OnRenderIngredientItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefBeginItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local ingredientId = self.currentIngredients[index + 1]

	if not ingredientId then
		return
	end

	local ingredientCfg = ChefIngredientsConfig.GetConfig(ingredientId)

	if not ingredientCfg then
		return
	end

	local itemId = ingredientCfg.Consumableid
	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if itemCfg then
		store.iconId = itemCfg.SItemIconId
		store.nameText = itemCfg.Name
	end
end

M.OnRenderMainIngredientItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefCookBeginIngredientsTabTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.currentMainIngredients[index + 1]

	if not data then
		return
	end

	local ingredientCfg = ChefIngredientsConfig.GetConfig(data.mainIngredients)

	if not ingredientCfg then
		return
	end

	local itemId = ingredientCfg.Consumableid
	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if itemCfg then
		store.titleText = itemCfg.Name
	end
end

M.OnClickMainIngredientItem = function(self, btn, index)
	self.selectedMainIngredientIndex = index + 1
	local data = self.currentMainIngredients[self.selectedMainIngredientIndex]

	if data then
		self.currentSubRecipeId = data.recipeId

		self.RefreshCookIngredients(self)
	end
end

M.OnRenderMatchedRecipeItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("ChefMenuItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.currentMatchedRecipes[index + 1]

	if not data then
		return
	end

	local mainRecipeCfg = ChefMainRecipeConfig.GetConfig(data.belongRecipe)

	if mainRecipeCfg then
		store.nameText = mainRecipeCfg.MainRecipeName
		store.iconId = 0
	end
end

M.InitCookData = function(self)
	table.clear(self.mainRecipeList)
	table.clear(self.mainIngredientsMap)
	table.clear(self.firstSubRecipeMap)

	local mainRecipeIdSet = {}

	for i = 0, ChefCookConfig.count - 1 do
		local cfg = ChefCookConfig.LoadAt(i)

		if cfg and cfg.CookType ~= self.nowCookType then
			self.bindData.prepareTypeText = cfg.CookTypeName

			break
		end
	end

	for i = 0, ChefRecipeConfig.count - 1 do
		local cfg = ChefRecipeConfig.LoadAt(i)

		if cfg and cfg.CookType ~= self.nowCookType and cfg.PrepareType ~= PrepareType.Cook then
			local belongId = cfg.BelongRecipe

			if belongId and belongId == 0 then
				if not mainRecipeIdSet[belongId] then
					mainRecipeIdSet[belongId] = true
				end

				if not self.firstSubRecipeMap[belongId] then
					self.firstSubRecipeMap[belongId] = cfg.Id
				end

				if cfg.MainIngredients and cfg.MainIngredients == 0 then
					if not self.mainIngredientsMap[belongId] then
						self.mainIngredientsMap[belongId] = {}
					end

					local ingredientData = {
						mainIngredients = cfg.MainIngredients,
						recipeId = cfg.Id
					}

					table.insert(self.mainIngredientsMap[belongId], ingredientData)
				end
			end
		end
	end

	local dict = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict

	for mainRecipeId, _ in pairs(mainRecipeIdSet) do
		local mainCfg = ChefMainRecipeConfig.GetConfig(mainRecipeId)

		if mainCfg and dict and dict[mainRecipeId] and dict[mainRecipeId].Unlock then
			local data = {
				id = mainRecipeId,
				name = mainCfg.MainRecipeName,
				iconId = mainCfg.MainRecipeIcon
			}

			table.insert(self.mainRecipeList, data)
		end
	end

	if #self.mainRecipeList <= 0 then
		self.selectedIndex = 1

		self.bindData.cookList:SetSimpleList(#self.mainRecipeList)
		self.bindData.cookList:SetItemSelected(0, true)
		self:RefreshAfterSelect()
	end
end

M.InitPrepareData = function(self)
	table.clear(self.prepareRecipes)

	for i = 0, ChefRecipeConfig.count - 1 do
		local cfg = ChefRecipeConfig.LoadAt(i)

		if cfg and cfg.CookType ~= self.nowCookType and cfg.PrepareType ~= PrepareType.Prepare then
			local itemId = cfg.Consumableid
			local itemCfg = ConsumableConfig.GetConfig(itemId)
			local iconId = 0

			if itemCfg then
				iconId = itemCfg.SItemIconId
			end

			local data = {
				id = cfg.Id,
				name = cfg.RecipeName,
				iconId = iconId
			}

			table.insert(self.prepareRecipes, data)
		end
	end

	if #self.prepareRecipes <= 0 then
		self.selectedIndex = 1

		self.bindData.prepareList:SetSimpleList(#self.prepareRecipes)
		self.bindData.prepareList:SetItemSelected(0, true)
		self:RefreshAfterSelect()
	end
end

M.RefreshAfterSelect = function(self)
	if self.currentTab ~= 0 then
		self.RefreshCookPrepareList(self)
	else
		self.RefreshPreparePrepareList(self)
	end
end

M.RefreshCookPrepareList = function(self)
	local data = self.mainRecipeList[self.selectedIndex]

	if not data then
		return
	end

	local mainRecipeId = data.id
	local ingredientsList = self.mainIngredientsMap[mainRecipeId]
	self.selectedMainIngredientIndex = 1

	if ingredientsList and #ingredientsList <= 0 then
		self.currentSubRecipeId = ingredientsList[1].recipeId
	else
		self.currentSubRecipeId = self.firstSubRecipeMap[mainRecipeId]
	end

	table.clear(self.prepareListData)

	if ingredientsList and #ingredientsList <= 0 then
		table.insert(self.prepareListData, {
			["a\\x9f\\x8a\\x86Y"] = 0,
			text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefChooseFoodName).Text
		})
		table.insert(self.prepareListData, {
			["a\\x9f\\x8a\\x86Y"] = 2,
			mainIngredients = ingredientsList
		})
	end

	table.insert(self.prepareListData, {
		["a\\x9f\\x8a\\x86Y"] = 0,
		text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefNeedFoodName).Text
	})

	local ingredients = self.GetRecipeIngredients(self, self.currentSubRecipeId)

	table.insert(self.prepareListData, {
		["a\\x9f\\x8a\\x86Y"] = 1,
		ingredients = ingredients
	})
	self.SetInfoList(self)
	self.RefreshDishItem(self)
end

M.RefreshPreparePrepareList = function(self)
	local data = self.prepareRecipes[self.selectedIndex]

	if not data then
		return
	end

	self.selectedRecipe = data.id
	local cfg = ChefRecipeConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	table.clear(self.prepareListData)

	local title1 = {
		["a\\x9f\\x8a\\x86Y"] = 0,
		text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefNeedFoodName).Text
	}

	table.insert(self.prepareListData, title1)

	local ingredientsItem = {
		["a\\x9f\\x8a\\x86Y"] = 1,
		ingredients = cfg.Ingredientsid
	}

	table.insert(self.prepareListData, ingredientsItem)

	local title2 = {
		["a\\x9f\\x8a\\x86Y"] = 0,
		text = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefRecipeName).Text
	}

	table.insert(self.prepareListData, title2)

	local matchedRecipes = self.BuildMatchedRecipesData(self, cfg.FoodPrepareIngredientsid)
	local recipeItem = {
		["a\\x9f\\x8a\\x86Y"] = 3,
		matchedRecipes = matchedRecipes
	}

	table.insert(self.prepareListData, recipeItem)
	self.SetInfoList(self)
	self.RefreshDishItem(self)
end

M.SetInfoList = function(self)
	self.bindData.infoList:SetSimpleList(#self.prepareListData)
end

M.RefreshCookIngredients = function(self)
	local ingredients = self.GetRecipeIngredients(self, self.currentSubRecipeId)

	for _, itemData in ipairs(self.prepareListData) do
		if itemData.tIndex ~= 1 then
			itemData.ingredients = ingredients

			break
		end
	end

	self.bindData.infoList:RefreshList()
	self:RefreshDishItem()
end

M.RefreshDishItem = function(self)
	local recipeId = nil

	if self.currentTab ~= 0 then
		recipeId = self.currentSubRecipeId
	else
		recipeId = self.selectedRecipe
	end

	if not recipeId then
		return
	end

	local cfg = ChefRecipeConfig.GetConfig(recipeId)

	if not cfg then
		return
	end

	self.selectedRecipe = recipeId
	self.bindData.descText = cfg.RecipeInstructions
	local itemId = cfg.Consumableid
	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if not itemCfg then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChefItemTemplate"):GetStoreByWidget(self.bindData.dishItem)

	if not store then
		return
	end

	store.iconId = itemCfg.SItemIconId
	store.nameText = itemCfg.Name

	self.RefreshConfirmBtn(self, cfg)
end

M.RefreshConfirmBtn = function(self, cfg)
	local ingredients = cfg.Ingredientsid
	local allow = true

	for i = 1, #ingredients do
		local id = ingredients[i]
		local ingredientCfg = ChefIngredientsConfig.GetConfig(id)

		if ingredientCfg then
			local foodItemId = ingredientCfg.Consumableid

			if self.GetItemCount(self, foodItemId) < 0 then
				allow = false

				break
			end
		end
	end

	self.bindData.confirmBtn.interactable = allow
end

M.GetItemCount = function(self, itemId)
	local kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	if kitchen and kitchen.isBusiness then
		return kitchen.GetInventoryItemCountByConsumableId(kitchen, itemId)
	else
		return gCommonItemManager:GetPackItemNum(itemId)
	end
end

M.GetRecipeIngredients = function(self, recipeId)
	if not recipeId then
		return {}
	end

	local cfg = ChefRecipeConfig.GetConfig(recipeId)

	if not cfg then
		return {}
	end

	return cfg.Ingredientsid or {}
end

M.BuildMatchedRecipesData = function(self, foodPrepareIngredientsId)
	local result = {}

	if not foodPrepareIngredientsId or foodPrepareIngredientsId ~= 0 then
		return result
	end

	local addedBelongRecipes = {}

	for i = 0, ChefRecipeConfig.count - 1 do
		local cfg = ChefRecipeConfig.LoadAt(i)

		if cfg and cfg.PrepareType ~= PrepareType.Cook then
			local ingredients = cfg.Ingredientsid

			if ingredients then
				for j = 1, #ingredients do
					if ingredients[j] ~= foodPrepareIngredientsId then
						if not addedBelongRecipes[cfg.BelongRecipe] then
							addedBelongRecipes[cfg.BelongRecipe] = true
							local matchData = {
								belongRecipe = cfg.BelongRecipe,
								recipeId = cfg.Id
							}

							table.insert(result, matchData)
						end

						break
					end
				end
			end
		end
	end

	return result
end
