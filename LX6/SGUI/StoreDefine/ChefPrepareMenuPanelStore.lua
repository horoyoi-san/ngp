-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefPrepareMenuPanelStore.lua
-- Decompiled from: 01422_ChefPrepareMenuPanelStore.lua_cb2a74895a4f.luajit

C_ChefPrepareMenuPanelStore = DefClass("C_ChefPrepareMenuPanelStore", C_ChefPrepareMenuPanelStore, C_StoreGroup)
GroupName2Class.ChefPrepareMenuPanelStore = C_ChefPrepareMenuPanelStore
local M = C_ChefPrepareMenuPanelStore
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefCookNpcConfig = LTConfig.ChefCookNpcConfig
local ChefConfig = LTConfig.ChefConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local AgentConfig = LTConfig.AgentConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.LEFT_LIST_TYPE = {
		[".m\\xb2\\xa7\\xb3d"] = 1,
		["\\xa0XE"] = 2,
		["T\rS~"] = 0
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = {
		["^-jU"] = 1,
		["5"] = 0
	}
	self.menuCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.assistantCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = nil
	self.menuCtrlEnum = nil
	self.assistantCtrlEnum = nil
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
	self.isShow = true

	self.InitData(self)
end

M.OnClose = function(self)
	self.isShow = false

	if self.requestTimer then
		self.requestTimer:Stop()
	end

	self.ClearData(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_RECIPE_UNLOCK_CHANGED] = function (eventId)
			self:RefreshLeftRecipeList()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, self.OnClickConfirmBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.menuEditBtn.luaClick = self.CreateActionWithArgs(self, self.RequestLeftList, self.LEFT_LIST_TYPE.RECIPE)
	self.bindData.npcEditBtn.luaClick = self.CreateActionWithArgs(self, self.RequestLeftList, self.LEFT_LIST_TYPE.NPC)
	self.bindData.selectMenuList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSelectMenuListItem)
	self.bindData.selectMenuList.onGetTIndex = self.CreateAction(self, self.OnGetSelectMenuListTIndex)
	self.bindData.menuList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderMenuListItem)
	self.bindData.assistantList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderAssistantListItem)
	self.bindData.selectAssistantList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderSelectAssistantListItem)
	self.bindData.selectAssistantList.onGetTIndex = self.CreateAction(self, self.OnGetSelectAssistantListTIndex)
	self.bindData.assistantList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickAssistantList)
	self.bindData.selectAssistantList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickSelectAssistantList)
	self.bindData.consumableList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderConsumableListItem)
end

M.OnClickConfirmBtn = function(self)
	gClientToGameSceneDelegate:AskStartChefManagementRound(self.selectNpc).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	gPanelManager:Close(self.m_Id)
end

M.OnClickBackBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderSelectMenuListItem = function(self, btn, index)
	if index >= #self.selectRecipes then
		local recipeId = self.selectRecipes[index + 1]

		if not recipeId then
			return
		end

		local info = self.recipeInfos[recipeId]

		if not info then
			return
		end

		local store = self.GetStoreByWidget(self, btn)

		if not store then
			return
		end

		store.peopleNum = info.people
		store.money = info.money
		local menuItemStore = gStoreManager:GetStoreGroup(store.menuItem.Store):GetStoreByWidget(store.menuItem)

		if menuItemStore then
			menuItemStore.nameText = info.name
			menuItemStore.iconId = info.iconId
		end

		store.closeBtn = self:CreateActionWithArgs(self.ChangeSelectRecipe, {
			["D\\xbd\\x83\\xab\\xb2"] = false,
			recipeId = recipeId
		})
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderSelectMenuConsumableListItem, recipeId)

		store.list:SetSimpleList(#info.originConsumableIds)
	else
		btn.luaClick = self.CreateActionWithArgs(self, self.RequestLeftList, self.LEFT_LIST_TYPE.RECIPE)
	end
end

M.OnSimpleRenderSelectMenuConsumableListItem = function(self, recipeId, btn, index)
	local info = self.recipeInfos[recipeId]

	if not info then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local consumableId = info.originConsumableIds[index + 1]

	if not consumableId then
		return
	end

	local cfg = ConsumableConfig.GetConfig(consumableId)

	if cfg then
		store.iconId = cfg.SItemIconId
		store.greyState = cfg.Quality
	end

	store.count = info.people
end

M.OnGetSelectMenuListTIndex = function(self, index)
	if index >= #self.selectRecipes then
		return 0
	end

	return 1
end

M.OnSimpleRenderConsumableListItem = function(self, btn, index)
	local data = self.consumableList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId or 0
	store.greyState = data.quality or 0
	store.count = data.count or 0
end

M.OnSimpleRenderMenuListItem = function(self, btn, index)
	local recipeId = self.unlockRecipes[index + 1]

	if not recipeId then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = self.recipeInfos[recipeId]

	if info then
		store.iconId = info.iconId
		store.nameText = info.name
		store.stateCtrl = info.select and 1 or 0
	end

	btn.enabledTooltip = true
	btn.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderMenuItemTooltip, recipeId)
end

M.OnRenderMenuItemTooltip = function(self, recipeId, button, popIns, toolIndex)
	local popStore = gStoreManager:GetStoreGroup(popIns.Store)

	if popStore then
		local recipeInfo = self.recipeInfos[recipeId]
		local canInteract = false
		local addCb, removeCb = nil

		if recipeInfo.select then
			canInteract = true

			removeCb = function()
				button:CloseTooltip()
				self:ChangeSelectRecipe({
					["D\\xbd\\x83\\xab\\xb2"] = false,
					["\\xd0\\xd5\t*\\xe5"] = true,
					recipeId = recipeId
				})
			end
		else
			canInteract = #self.selectRecipes <= self.maxRecipeCount

			addCb = function()
				button:CloseTooltip()
				self:ChangeSelectRecipe({
					["D\\xbd\\x83\\xab\\xb2"] = true,
					recipeId = recipeId
				})
			end
		end

		popStore.ShowContent(popStore, {
			recipeId = recipeId,
			select = recipeInfo.select,
			canInteractable = canInteract,
			addMenuCallBack = addCb,
			removeMenuCallBack = removeCb
		})
	end
end

M.OnSimpleRenderAssistantListItem = function(self, btn, index)
	local npcId = self.unlockCookNpc[index + 1]

	if not npcId then
		return
	end

	local info = self.unlockCookNpcInfo[npcId]

	if not info then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = info.iconId
end

M.OnSimpleClickAssistantList = function(self, btn, index)
	local npcId = self.unlockCookNpc[index + 1]

	if not npcId then
		return
	end

	local info = self.unlockCookNpcInfo[npcId]

	if not info then
		return
	end

	if not info.select and #self.selectNpc >= self.maxNpcCount then
		info.select = true

		if not table.contains(self.selectNpc, npcId) then
			table.insert(self.selectNpc, npcId)
			self.bindData.selectAssistantList:SetSimpleList(self.maxNpcCount)
		end
	end
end

M.OnGetSelectAssistantListTIndex = function(self, index)
	if index >= #self.selectNpc then
		return 0
	end

	return 1
end

M.OnSimpleRenderSelectAssistantListItem = function(self, btn, index)
	if index >= #self.selectNpc then
		local npcId = self.selectNpc[index + 1]

		if not npcId then
			return
		end

		local info = self.unlockCookNpcInfo[npcId]

		if not info then
			return
		end

		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		store.iconId = info.iconId
	end
end

M.OnSimpleClickSelectAssistantList = function(self, btn, index)
	if index >= #self.selectNpc then
		local npcId = self.selectNpc[index + 1]

		if not npcId then
			return
		end

		local info = self.unlockCookNpcInfo[npcId]

		if not info then
			return
		end

		if info.select then
			info.select = false

			if table.contains(self.selectNpc, npcId) then
				table.removeEx(self.selectNpc, npcId)
				self.bindData.selectAssistantList:SetSimpleList(self.maxNpcCount)
			end
		end
	else
		self.RequestLeftList(self, self.LEFT_LIST_TYPE.NPC)
	end
end

M.InitData = function(self)
	self.kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	if self.kitchen ~= nil then
		print_error("Chef job error:打开厨师经营准备界面失败，当前无可用厨房！")

		return
	end

	self.selectRecipes = {}
	self.selectNpc = {}
	self.curListType = nil
	self.recipeInfos = {}
	self.maxRecipeCount = ChefConfig.MealMax or 3
	self.maxNpcCount = ChefConfig.CookNpcMax or 3
	self.requestCd = 0.3

	self.bindData.selectMenuList:SetSimpleList(self.maxRecipeCount)
	self.bindData.selectAssistantList:SetSimpleList(self.maxNpcCount)
	self:InitCookNpcInfo()
	self:RequestLeftList(self.LEFT_LIST_TYPE.NONE)

	self.bindData.confirmBtn.interactable = #self.selectRecipes >= 0
end

M.ClearData = function(self)
	self.selectRecipes = nil
	self.selectNpc = nil
	self.curListType = nil
	self.recipeInfos = nil
	self.unlockRecipes = nil
	self.unlockCookNpc = nil
	self.unlockCookNpcInfo = nil
end

M.RequestLeftList = function(self, targetType)
	if self.curListType == targetType then
		self.curListType = targetType

		if self.curListType ~= self.LEFT_LIST_TYPE.RECIPE then
			self.bindData.menuCtrl = self.menuCtrlEnum._true
			self.bindData.assistantCtrl = self.assistantCtrlEnum._false

			self.RefreshLeftRecipeList(self)
		elseif self.curListType ~= self.LEFT_LIST_TYPE.NPC then
			self.bindData.menuCtrl = self.menuCtrlEnum._false
			self.bindData.assistantCtrl = self.assistantCtrlEnum._true

			self.RefreshLeftNpcList(self)
		else
			self.bindData.menuCtrl = self.menuCtrlEnum._false
			self.bindData.assistantCtrl = self.assistantCtrlEnum._false
		end
	end
end

M.RefreshLeftRecipeList = function(self)
	self.unlockRecipes = {}
	local unlockRecipes = ChefManager.GetUnlockRecipes()

	if unlockRecipes then
		local recipes = unlockRecipes.ToTable(unlockRecipes)

		for i = 1, #recipes do
			local recipeId = recipes[i]

			table.insert(self.unlockRecipes, recipeId)

			local info = self.recipeInfos[recipeId]

			if not info then
				info = {}

				self.InitRecipeInfo(self, info, recipeId)

				self.recipeInfos[recipeId] = info
				info.select = false
			end
		end
	end

	self.bindData.menuList:SetSimpleList(#self.unlockRecipes)
end

M.InitCookNpcInfo = function(self)
	self.unlockCookNpc = {}
	self.unlockCookNpcInfo = {}

	for i = 1, ChefCookNpcConfig.count do
		local config = ChefCookNpcConfig.LoadAt(i - 1)

		if gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.ChefCookNpcUnlock) then
			table.insert(self.unlockCookNpc, config.Id)

			local agentConfig = AgentConfig.GetConfig(config.AgentID)
			self.unlockCookNpcInfo[config.Id] = {
				["M\\x9d\\x8b\\x80U"] = false,
				agentId = config.AgentID,
				iconId = agentConfig.HeadIcon
			}
		end
	end
end

M.RefreshLeftNpcList = function(self)
	self.bindData.assistantList:SetSimpleList(#self.unlockCookNpc)
end

M.ChangeSelectRecipe = function(self, args)
	if args.isAdd then
		if args.recipeId and #self.selectRecipes >= self.maxRecipeCount and not table.contains(self.selectRecipes, args.recipeId) then
			table.insert(self.selectRecipes, args.recipeId)

			local info = self.recipeInfos[args.recipeId]

			if not info then
				info = {}

				self.InitRecipeInfo(self, info, args.recipeId)

				self.recipeInfos[args.recipeId] = info
			end

			info.select = true

			if not info.people then
				info.people = 1
			end

			self.bindData.confirmBtn.interactable = false

			self.RefreshMenu(self)
			self.RequestServerMenuInfo(self)
		end
	elseif args.recipeId and table.contains(self.selectRecipes, args.recipeId) then
		table.removeEx(self.selectRecipes, args.recipeId)

		local info = self.recipeInfos[args.recipeId]

		if not info then
			info = {}

			self.InitRecipeInfo(self, info, args.recipeId)

			self.recipeInfos[args.recipeId] = info
		end

		info.select = false

		if not info.people then
			info.people = 1
		end

		self.bindData.confirmBtn.interactable = false

		self.RefreshMenu(self)

		if args.instant or #self.selectRecipes ~= 0 then
			self.RequestServerMenuInfo(self)
		else
			if self.requestTimer then
				self.requestTimer:Stop()
			end

			self.requestTimer = Timer.New(function ()
				if self.isShow then
					self.requestTimer = nil

					self:RequestServerMenuInfo()
				end
			end, self.requestCd):Start()
		end
	end
end

M.InitRecipeInfo = function(self, info, recipeId)
	local recipeCfg = ChefRecipeConfig.GetConfig(recipeId)

	if recipeCfg then
		info.name = recipeCfg.RecipeName
		info.money = recipeCfg.MealBasePrice
		local consumableCfg = ConsumableConfig.GetConfig(recipeCfg.Consumableid)
		info.iconId = consumableCfg and consumableCfg.SItemIconId
		info.quality = consumableCfg and consumableCfg.Quality
		info.originConsumableIds = {}

		if recipeCfg.Ingredientsid and #recipeCfg.Ingredientsid <= 0 then
			for j = 1, #recipeCfg.Ingredientsid do
				local success, originConsumableId = ChefManager.TryGetOriginConsumableIdByIngredientId(recipeCfg.Ingredientsid[j], nil)

				if success and originConsumableId <= 0 then
					table.insert(info.originConsumableIds, originConsumableId)
				end
			end
		end
	end
end

M.RefreshMenu = function(self)
	self.bindData.menuList:SetSimpleList(#self.unlockRecipes)
	self.bindData.selectMenuList:SetSimpleList(self.maxRecipeCount)

	local consumableCount = {}

	for i = 1, #self.selectRecipes do
		local recipeId = self.selectRecipes[i]
		local info = self.recipeInfos[recipeId]

		for j = 1, #info.originConsumableIds do
			local originConsumableId = info.originConsumableIds[j]

			if consumableCount[originConsumableId] then
				consumableCount[originConsumableId] = consumableCount[originConsumableId] + info.people
			else
				consumableCount[originConsumableId] = info.people
			end
		end
	end

	self.consumableList = {}

	for consumableId, count in pairs(consumableCount) do
		local cfg = ConsumableConfig.GetConfig(consumableId)

		table.insert(self.consumableList, {
			id = consumableId,
			iconId = cfg.SItemIconId,
			quality = cfg.Quality,
			count = count
		})
	end

	self.bindData.consumableList:SetSimpleList(#self.consumableList)
end

M.RequestServerMenuInfo = function(self)
	if self.requestTimer then
		self.requestTimer:Stop()
	end

	slot1 = gClientToGameSceneDelegate

	slot1:AskGenerateChefOrder(self.selectRecipes).Callback = function (err, chefGenerateOrderResult)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if self.isShow then
			if chefGenerateOrderResult and not chefGenerateOrderResult.ItemSufficient then
				self.bindData.confirmBtn.interactable = false
			else
				self.bindData.confirmBtn.interactable = true
			end

			local newRecipe = {}

			if chefGenerateOrderResult and chefGenerateOrderResult.PredictRecipeSequence and chefGenerateOrderResult.PredictRecipeSequence.Count <= 0 then
				local len = chefGenerateOrderResult.PredictRecipeSequence.Count

				for i = 1, len do
					local recipeId = chefGenerateOrderResult.PredictRecipeSequence[i]
					local info = self.recipeInfos[recipeId]

					if table.contains(newRecipe, recipeId) then
						info.people = info.people + 1
					else
						table.insert(newRecipe, recipeId)

						info.people = 1
					end
				end
			end

			local oldLen = #self.selectRecipes

			for i = 1, #newRecipe do
				local recipeId = newRecipe[i]

				if not table.contains(self.selectRecipes, recipeId) then
					table.insert(self.selectRecipes, recipeId)

					self.recipeInfos[recipeId].select = true
				end
			end

			local removeCount = 0

			for i = 1, oldLen do
				local index = i - removeCount
				local recipeId = self.selectRecipes[index]

				if not table.contains(newRecipe, recipeId) then
					table.remove(self.selectRecipes, index)

					self.recipeInfos[recipeId].select = false
				end
			end

			self:RefreshMenu()
		end
	end
end
