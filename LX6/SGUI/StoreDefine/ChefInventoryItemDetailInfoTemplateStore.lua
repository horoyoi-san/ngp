-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefInventoryItemDetailInfoTemplateStore.lua
-- Decompiled from: 01421_ChefInventoryItemDetailInfoTemplateStore.lua_bfee8a84379f.luajit

C_ChefInventoryItemDetailInfoTemplateStore = DefClass("C_ChefInventoryItemDetailInfoTemplateStore", C_ChefInventoryItemDetailInfoTemplateStore, C_StoreGroup)
GroupName2Class.ChefInventoryItemDetailInfoTemplateStore = C_ChefInventoryItemDetailInfoTemplateStore
local M = C_ChefInventoryItemDetailInfoTemplateStore
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.qualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.stateCtrlEnum = {
		["\\xa1}r"] = 1,
		[")"] = 0
	}
	self.LIST_TEMPLATE = {
		["VNo"] = 2,
		["y\\x87\\x96\\x83\\x93"] = 0,
		["\\xaaMU"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.qualityCtrlEnum = nil
	self.stateCtrlEnum = nil
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
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.addMenuBtn.luaClick = self.CreateAction(self, self.OnClickAddMenuBtn)
	self.bindData.removeMenuBtn.luaClick = self.CreateAction(self, self.OnClickRemoveMenuBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetListTIndex)
end

M.OnClickAddMenuBtn = function(self)
	if self.addMenuCallBack then
		self.addMenuCallBack()
	end
end

M.OnClickRemoveMenuBtn = function(self)
	if self.removeMenuCallBack then
		self.removeMenuCallBack()
	end
end

M.OnGetListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if not data then
		return 0
	end

	return data.tIndex or 0
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.listData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.tIndex ~= self.LIST_TEMPLATE.LIST then
		store.list.luaSimpleRenderItem = self:CreateAction(self.OnSimpleRenderIngredientListItem)

		store.list:SetSimpleList(#self.ingredients)
	else
		store.nameLabel = data.content
	end
end

M.OnSimpleRenderIngredientListItem = function(self, btn, index)
	local data = self.ingredients[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId or 0
	store.greyState = data.quality or 0
end

M.ShowContent = function(self, args)
	self.recipeId = args.recipeId or 0
	self.addMenuCallBack = args.addMenuCallBack
	self.removeMenuCallBack = args.removeMenuCallBack
	local canInteractable = true

	if args.canInteractable == nil and not args.canInteractable then
		canInteractable = false
	end

	self.bindData.addMenuBtn.interactable = canInteractable
	self.bindData.removeMenuBtn.interactable = canInteractable
	self.bindData.stateCtrl = args.select and self.stateCtrlEnum.Out or self.stateCtrlEnum.In
	local recipeCfg = LTConfig.ChefRecipeConfig.GetConfig(self.recipeId)

	if recipeCfg then
		self.bindData.name = recipeCfg.RecipeName
		self.bindData.money = recipeCfg.MealBasePrice
		local consumableCfg = ConsumableConfig.GetConfig(recipeCfg.Consumableid)

		if consumableCfg then
			self.bindData.qualityCtrl = consumableCfg.Quality
		end

		self.RefreshList(self, recipeCfg)
	end
end

M.RefreshList = function(self, recipeCfg)
	self.listData = {}

	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		content = LTConfig.TextScriptTextConfig.GetConfig(89901023).Text
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.DES,
		content = recipeCfg.RecipeInstructions
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.TITLE,
		content = LTConfig.TextScriptTextConfig.GetConfig(89901492).Text
	})
	table.insert(self.listData, {
		tIndex = self.LIST_TEMPLATE.LIST
	})

	self.ingredients = {}

	if recipeCfg.Ingredientsid and #recipeCfg.Ingredientsid <= 0 then
		for i = 1, #recipeCfg.Ingredientsid do
			local success, originConsumableId = ChefManager.TryGetOriginConsumableIdByIngredientId(recipeCfg.Ingredientsid[i], nil)

			if success and originConsumableId <= 0 then
				local cfg = ConsumableConfig.GetConfig(originConsumableId)

				table.insert(self.ingredients, {
					id = originConsumableId,
					iconId = cfg and cfg.SItemIconId,
					quality = cfg and cfg.Quality
				})
			end
		end
	end

	self.bindData.list:SetSimpleList(#self.listData)
end
