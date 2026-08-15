local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
C_ChefBagPanelStore = DefClass("C_ChefBagPanelStore", C_ChefBagPanelStore, C_StoreGroup)
GroupName2Class.ChefBagPanelStore = C_ChefBagPanelStore
local M = C_ChefBagPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.bag = {}
	self.currentRecipe = nil
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
	if data then
		self.currentRecipe = data
	else
		self.currentRecipe = nil
	end

	self:RefreshBag()
end

function M:OnClose()
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.bagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderBagListItem")
end

function M:OnSimpleRenderBagListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("ChefItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = self.bag[index + 1]
	local itemId = ChefIngredientsConfig.GetConfig(id).Consumableid
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId

	if self.currentRecipe then
		local canAdd = self:CheckIsInCurrentRecipe(id)
		store.greyState = canAdd and 0 or 1
		btn.interactable = canAdd
	end
end

function M:RefreshBag()
	table.clear(self.bag)

	local allIngredient = {}

	for i = 0, ChefIngredientsConfig.count - 1 do
		local cfg = ChefIngredientsConfig.LoadAt(i)

		table.insert(allIngredient, cfg)
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if gPlayerItemManager:GetPackItemNum(itemId) > 0 then
			table.insert(self.bag, allIngredient[i].Id)
		end
	end

	self.bindData.bagList:SetSimpleList(#self.bag)
end

function M:RegisterListClickEvent(cb)
	function self.bindData.bagList.luaSimpleClick(btn, index)
		cb(self.bag[index + 1])
	end
end

function M:UnRegisterListClickEvent()
	self.bindData.bagList.luaSimpleClick = nil
end

function M:CheckIsInCurrentRecipe(id)
	local recipeCfg = ChefRecipeConfig.GetConfig(self.currentRecipe)
	local ingredients = recipeCfg.Ingredientsid

	return table.contains(ingredients, id)
end
