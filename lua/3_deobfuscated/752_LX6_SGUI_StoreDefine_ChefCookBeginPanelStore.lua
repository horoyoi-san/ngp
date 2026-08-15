local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
C_ChefCookBeginPanelStore = DefClass("C_ChefCookBeginPanelStore", C_ChefCookBeginPanelStore, C_StoreGroup)
GroupName2Class.ChefCookBeginPanelStore = C_ChefCookBeginPanelStore
local M = C_ChefCookBeginPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.game = nil
	self.entityId = nil
	self.selectedRecipe = nil
	self.ingredients = {}
	self.recipes = {}
	self.selectedIndex = 1
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	self.game = data
	self.entityId = self.game:GetEntityId()

	self:InitRecipe()
	self:RefreshRecipe()
end

function M:OnClose()
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.dishItem.luaClick = self:CreateAction("OnClickDishItem")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnClickConfirmBtn")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.leftSwitchBtn.luaClick = self:CreateActionWithArgs("OnClickSwitchBtn", -1)
	self.bindData.rightSwitchBtn.luaClick = self:CreateActionWithArgs("OnClickSwitchBtn", 1)
	self.bindData.ingredientList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderIngredientListItem")
end

function M:OnClickDishItem()
	return
end

function M:OnClickConfirmBtn()
	self.game:StartGame(self.selectedRecipe)
	gPanelManager:Close(gPanelId.S_CHEF_COOK_BEGIN_PANEL)
end

function M:OnClickCloseBtn()
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, gSpoonEventType.OnReceiveSignal, {
		signalKey = "cook_exit",
		entityInstanceId = self.entityId
	})
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
	gPanelManager:Close(gPanelId.S_CHEF_COOK_BEGIN_PANEL)
end

function M:OnClickSwitchBtn(dir)
	local count = #self.recipes
	self.selectedIndex = ((self.selectedIndex - 1 + dir) % count + count) % count + 1

	self:RefreshRecipe()
end

function M:OnSimpleRenderIngredientListItem(btn, index)
	local data = self.ingredients[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = data.id
	local itemId = ChefIngredientsConfig.GetConfig(id).Consumableid
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId
	store.greyState = data.exist and 0 or 1
end

function M:OnSimpleClickIngredientList(btn, index)
	return
end

function M:InitRecipe()
	for i = 0, ChefRecipeConfig.count - 1 do
		local cfg = ChefRecipeConfig.LoadAt(i)

		table.insert(self.recipes, cfg.Id)
	end

	self.selectedIndex = 1
end

function M:RefreshRecipe()
	self.selectedRecipe = self.recipes[self.selectedIndex]

	table.clear(self.ingredients)

	local cfg = ChefRecipeConfig.GetConfig(self.selectedRecipe)
	local itemId = cfg.Consumableid
	local itemCfg = ConsumableConfig.GetConfig(itemId)
	local iconId = itemCfg.SItemIconId
	local name = itemCfg.Name
	local store = gStoreManager:GetStoreGroup("ChefItemTemplate"):GetStoreByWidget(self.bindData.dishItem)

	if not store then
		return
	end

	store.iconId = iconId
	store.nameText = name
	local ingredients = cfg.Ingredientsid
	local allow = true

	for i = 1, #ingredients do
		local id = ingredients[i]
		local foodItemId = ChefIngredientsConfig.GetConfig(id).Consumableid
		local exist = false

		if gPlayerItemManager:GetPackItemNum(foodItemId) <= 0 then
			allow = false
		else
			exist = true
		end

		table.insert(self.ingredients, {
			id = id,
			exist = exist
		})
	end

	self.bindData.ingredientList:SetSimpleList(#self.ingredients)

	if not allow then
		self.bindData.confirmBtn.interactable = false
	else
		self.bindData.confirmBtn.interactable = true
	end
end
