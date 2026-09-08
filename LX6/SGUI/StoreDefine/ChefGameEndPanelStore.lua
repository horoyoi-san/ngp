-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefGameEndPanelStore.lua
-- Decompiled from: 01417_ChefGameEndPanelStore.lua_5a34d7cdfe74.luajit

C_ChefGameEndPanelStore = DefClass("C_ChefGameEndPanelStore", C_ChefGameEndPanelStore, C_StoreGroup)
GroupName2Class.ChefGameEndPanelStore = C_ChefGameEndPanelStore
local M = C_ChefGameEndPanelStore
local ChefRankConfig = LTConfig.ChefRankConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.LIST_TEMPLATE = {
		["~\\x8d\\x8d\\x9d\\x93"] = 0,
		["b\\x9c\\x86\\x8a\\x84"] = 1
	}
	self.rankCtrlEnum = {
		["\\xec"] = 1,
		["\\xee"] = 3,
		["\\xe9"] = 4,
		["\\xfe"] = 0,
		["\\xef"] = 2
	}
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
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
	self.InitContent(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.continueBtn.luaClick = self.CreateAction(self, self.OnClickContinueBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.onGetTIndex = self.CreateAction(self, self.OnGetListTIndex)
end

M.OnClickContinueBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnGetListTIndex = function(self, index)
	local data = self.listData[index + 1]

	if data then
		return data.tIndex or 0
	end

	return 0
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

	if data.tIndex ~= self.LIST_TEMPLATE.ORDER then
		store.title = data.title
		store.content = data.content
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderRecipeListItem, index + 1)

		store.list:SetSimpleList(#data.recipes)
	else
		store.title = data.title
		store.score = data.content
	end
end

M.OnSimpleRenderRecipeListItem = function(self, dataIndex, btn, index)
	local data = self.listData[dataIndex]

	if not data then
		return
	end

	local recipeData = data.recipes[index + 1]

	if not recipeData then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.productIconId = recipeData.iconId
	store.rankCtrl = recipeData.rankCtrl
end

M.InitContent = function(self)
	self.kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	if self.kitchen ~= nil then
		print_error("Chef job error:打开厨师经营结算界面失败，当前无可用厨房！")

		return
	end

	self.listData = {}
	local realOrders = self.kitchen.realOrders

	if realOrders then
		local realOrdersTable = realOrders.ToTable(realOrders)

		for i = 1, #realOrdersTable do
			local realOrderInfo = realOrdersTable[i]
			local info = {}
			local orderFormat = TextScriptTextConfig.GetConfig(89901487).Text
			info.title = string.format(orderFormat, i)
			local satisfactionFormat = TextScriptTextConfig.GetConfig(89901488).Text
			info.content = string.format(satisfactionFormat, math.floor(realOrderInfo.Satisfaction * 100 + 0.5))

			if realOrderInfo.Recipes == nil then
				info.recipes = {}
				local recipesTable = realOrderInfo.Recipes:ToTable()

				for k, v in pairs(recipesTable) do
					local score = math.floor(v.FinalScore * 100 + 0.5)
					local finalRankCfg = nil
					local minScore = 0
					local rankCtrl = self.rankCtrlEnum.S

					for j = 1, ChefRankConfig.count do
						local rankCfg = ChefRankConfig.LoadAt(j - 1)

						if minScore < rankCfg.RatePoint and rankCfg.RatePoint < score then
							minScore = rankCfg.RatePoint
							finalRankCfg = rankCfg
						end
					end

					if finalRankCfg then
						if finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.S then
							rankCtrl = self.rankCtrlEnum.S
						elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.A then
							rankCtrl = self.rankCtrlEnum.A
						elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.B then
							rankCtrl = self.rankCtrlEnum.B
						elseif finalRankCfg.RankType ~= ChefRankConfig.RankTypeType.C then
							rankCtrl = self.rankCtrlEnum.C
						end
					end

					local iconId = 0
					local recipeConfig = ChefRecipeConfig.GetConfig(v.RecipeId)

					if recipeConfig and recipeConfig.Consumableid <= 0 then
						local consumableCfg = ConsumableConfig.GetConfig(recipeConfig.Consumableid)
						iconId = consumableCfg and consumableCfg.SItemIconId or 0
					end

					table.insert(info.recipes, {
						recipeId = v.RecipeId,
						iconId = iconId,
						finalScore = score,
						rankCtrl = rankCtrl
					})
				end
			end

			info.tIndex = self.LIST_TEMPLATE.ORDER

			table.insert(self.listData, info)
		end
	end

	local settlement = self.kitchen.finalSettlement

	if settlement then
		table.insert(self.listData, {
			title = TextScriptTextConfig.GetConfig(89901489).Text,
			content = settlement.Cost,
			tIndex = self.LIST_TEMPLATE.SCORE
		})
		table.insert(self.listData, {
			title = TextScriptTextConfig.GetConfig(89901490).Text,
			content = settlement.Income,
			tIndex = self.LIST_TEMPLATE.SCORE
		})
		table.insert(self.listData, {
			title = TextScriptTextConfig.GetConfig(89901491).Text,
			content = settlement.Profit,
			tIndex = self.LIST_TEMPLATE.SCORE
		})

		self.bindData.exp = "+" .. tostring(settlement.Exp)
	end

	self.bindData.list:SetSimpleList(#self.listData)
end
