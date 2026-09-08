-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefHandbookPanelStore.lua
-- Decompiled from: 01419_ChefHandbookPanelStore.lua_3b519c8542df.luajit

local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefMainRecipeConfig = LTConfig.ChefMainRecipeConfig
local ChefQTEConfig = LTConfig.ChefQTEConfig
local ChefConfig = LTConfig.ChefConfig
local ChefSeasoningConfig = LTConfig.ChefSeasoningConfig
local ChefFoodPrepareTypeConfig = LTConfig.ChefFoodPrepareTypeConfig
local ChefFoodPrepareConfig = LTConfig.ChefFoodPrepareConfig
local ChefCookConfig = LTConfig.ChefCookConfig
local HyperLinkConfig = LTConfig.HyperLinkConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager
local STEP_TINDEX = {
	["zTɯ\\x81\\xb1\\xc7\\xfc"] = 1,
	["~\\xbe\\xae\\xa6\\xa2"] = 2,
	["y\\xa7\\xb6\\xa3\\xb3"] = 0
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
			before = {},
			after = {}
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

C_ChefHandbookPanelStore = DefClass("C_ChefHandbookPanelStore", C_ChefHandbookPanelStore, C_StoreGroup)
GroupName2Class.ChefHandbookPanelStore = C_ChefHandbookPanelStore
local M = C_ChefHandbookPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.recipeListData = {}
	self.subRecipeData = {}
	self.hyperLinkData = {}
	self.totalRewardsData = {}
	self.stepListData = {}
	self.stepCount = 0
	self.selectedSubRecipesIndex = 1
	self.selectedMainRecipesIndex = 1
	self.currentTab = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		["V-~P"] = 2,
		["H#sP"] = 0,
		I6xK = 1
	}
	self.rankCtrlEnum = {
		["\\xec"] = 1,
		["\\xee"] = 3,
		["\\xe9"] = 4,
		["\\xfe"] = 0,
		["\\xef"] = 2
	}
	self.hasSubRecipeCtrlEnum = {
		["\\x86iu"] = 1,
		["t-s^"] = 0
	}
	self.rewardActiveCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
	self.rankCtrlEnum = nil
	self.hasSubRecipeCtrlEnum = nil
	self.rewardActiveCtrlEnum = nil
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
	self.InitData(self)
	self.RefreshChefTotalRewards(self)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.holdBtn.luaClick = self.CreateAction(self, self.OnClickHoldBtn)
	self.bindData.rewardBtn.luaClick = self.CreateAction(self, self.OnClickRewardBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnClickCloseBtn)
	self.bindData.totalList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTotalListItem)
	self.bindData.ingredientList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderIngredientListItem)
	self.bindData.infoTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderInfoTabListItem)
	self.bindData.stepList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderStepListItem)
	self.bindData.lockList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderLockListItem)
	self.bindData.totalRewardList.luaRenderItem = self.CreateAction(self, self.OnSimpleRenderTotalRewardListItem)
	self.bindData.totalList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTotalList)
	self.bindData.ingredientList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickIngredientList)
	self.bindData.infoTabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickInfoTabList)
	self.bindData.stepList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickStepList)
	self.bindData.lockList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickLockList)
	self.bindData.totalRewardList.luaClick = self.CreateAction(self, self.OnSimpleClickTotalRewardList)

	self.bindData.totalRewardList.onGetTIndex = function()
		return 0
	end

	self.bindData.stepList.onGetTIndex = self.CreateAction(self, self.OnGetStepListTIndex)
end

M.OnClickHoldBtn = function(self)
	local id = self.subRecipeData[self.selectedSubRecipesIndex]

	if not id or id < 0 then
		return
	end

	if ChefManager.GetGuideRecipeId() ~= id then
		id = 0
	end

	ChefManager.SetGuideRecipeId(id)

	local hudStore = gStoreManager:GetStoreGroup("ChefHUDPanelStore")

	if hudStore then
		hudStore.RefreshGuideRecipe(hudStore)
	end
end

M.OnClickRewardBtn = function(self)
	local id = self.subRecipeData[self.selectedSubRecipesIndex]

	ChefManager.AskReceiveChefRecipeRewardBatch(id)
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnSimpleRenderTotalListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.recipeListData[index + 1]
	local recipeId = data.id
	local cfg = ChefMainRecipeConfig.GetConfig(recipeId)
	store.nameText = cfg.MainRecipeName
	store.iconId = cfg.MainRecipeIcon
end

M.OnSimpleClickTotalList = function(self, btn, index)
	local data = self.recipeListData[index + 1]
	local recipeId = data.id

	self.RefreshMainRecipe(self, recipeId)
end

M.OnSimpleRenderIngredientListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.subRecipeData[index + 1]
	local mainIngredient = ChefRecipeConfig.GetConfig(data).MainIngredients

	if mainIngredient and mainIngredient <= 0 then
		local itemId = ChefIngredientsConfig.GetConfig(mainIngredient).Consumableid
		local itemCfg = ConsumableConfig.GetConfig(itemId)
		store.titleText = itemCfg.Name
	end
end

M.OnSimpleClickIngredientList = function(self, btn, index)
	local id = self.subRecipeData[index + 1]

	if not id then
		return
	end

	self.selectedSubRecipesIndex = index + 1

	self.RefreshSubRecipeInfo(self)
end

M.OnSimpleRenderInfoTabListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.titleText = index ~= 0 and TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefAppRank).Text or TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefAppStep).Text
end

M.OnSimpleClickInfoTabList = function(self, btn, index)
	self.currentTab = index

	self.RefreshTabInfo(self)
end

M.OnGetStepListTIndex = function(self, index)
	local data = self.stepListData[index + 1]

	return data and data.tIndex or STEP_TINDEX.Title
end

M.OnSimpleRenderStepListItem = function(self, btn, index)
	local data = self.stepListData[index + 1]

	if not data then
		return
	end

	if data.tIndex ~= STEP_TINDEX.Title then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		store.titleText = data.titleText or ""
		store.stepText = TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefStepText).Text .. " " .. data.step
	elseif data.tIndex ~= STEP_TINDEX.Ingredient then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		if not store then
			return
		end

		if store.beforeList then
			store.beforeList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderStepShicaiItem, data.beforeItems)

			store.beforeList:SetSimpleList(#data.beforeItems)
		end

		if store.afterList then
			store.afterList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderStepShicaiItem, data.afterItems)

			store.afterList:SetSimpleList(#data.afterItems)
		end
	end
end

M.OnSimpleRenderStepShicaiItem = function(self, itemIds, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemId = itemIds and itemIds[index + 1]

	if not itemId then
		return
	end

	local itemCfg = ConsumableConfig.GetConfig(itemId)

	if not itemCfg then
		return
	end

	store.iconId = itemCfg.SItemIconId
	store.nameText = itemCfg.Name
end

M.OnSimpleClickStepList = function(self, btn, index)
end

M.OnSimpleRenderLockListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = self.hyperLinkData[index + 1]
	local cfg = HyperLinkConfig.GetConfig(id)
	store.nameLabel = cfg.SourceLabels
end

M.OnSimpleRenderTotalRewardListItem = function(self, btn, index)
	local data = self.totalRewardsData[index + 1]
	local width = self.bindData.totalRewardList.rectTransform.rect.width
	local progress = data.progress / 100

	btn.rectTransform:SetLocalPositionX(0 - width / 2 + width * progress)

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.stateCtrl = data.isRewarded and 1 or 0
	store.progressText = data.progress .. "%"
	local rewardList, itemId = gCommonItemManager:GetRewardList(data.dropId)

	if rewardList and next(rewardList) then
		local renderData = gCommonItemManager:GetItemRenderData({
			itemId = itemId,
			itemNum = rewardList[1].count
		})

		gCommonItemManager:OnCommonItemRender(store.rewardComp, index, renderData)
	end

	store.rewardActiveCtrl = data.canGet and 1 or 0

	store.rewardBtn.luaClick = function()
		ChefManager.AskReceiveChefCollectionReward(index, function ()
			table.insert(gPlayerManager.infoMinor.bindData.ChefUnlockInfo.ReceivedCollectionRewards, index)
			self:RefreshChefTotalRewards()
		end)
	end
end

M.OnSimpleClickLockList = function(self, btn, index)
	local id = self.hyperLinkData[index + 1]
	local hyperLinkInfo, _ = gItemHyperLinkManager:GetSourceBehaviorByHyperLink(id, nil)

	if hyperLinkInfo and hyperLinkInfo.callback then
		hyperLinkInfo.callback()
	end
end

M.OnSimpleClickTotalRewardList = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if not store.detailCtrl then
		store.detailCtrl = 1
	else
		store.detailCtrl = 1 - store.detailCtrl
	end
end

M.LocateGuideRecipe = function(self)
	local guideId = ChefManager.GetGuideRecipeId()

	if not guideId or guideId < 0 then
		return 1, 1
	end

	for i = 1, #self.recipeListData do
		local mainId = self.recipeListData[i].id
		local mainRecipeCfg = ChefMainRecipeConfig.GetConfig(mainId)
		local subRecipes = mainRecipeCfg and mainRecipeCfg.IncludeRecipe

		if subRecipes then
			for j = 1, #subRecipes do
				if subRecipes[j] ~= guideId then
					local infoData = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict[mainId]

					if not infoData or not infoData.Unlock then
						return 1, 1
					end

					return i, j
				end
			end
		end
	end

	return 1, 1
end

M.InitData = function(self)
	local info = gPlayerManager.infoMinor.bindData.ChefUnlockInfo

	for id, recipeData in pairs(info.RecipeDict) do
		local data = {
			id = id,
			recipeData = recipeData
		}

		table.insert(self.recipeListData, data)
	end

	if #self.recipeListData >= 1 then
		self.bindData.totalList:SetSimpleList(0)

		return
	end

	local mainIndex, subIndex = self:LocateGuideRecipe()
	self.selectedMainRecipesIndex = mainIndex

	self.bindData.totalList:SetSimpleList(#self.recipeListData)
	self.bindData.totalList:SetItemSelected(self.selectedMainRecipesIndex - 1, true)
	self:RefreshMainRecipe(self.recipeListData[self.selectedMainRecipesIndex].id, subIndex)
end

M.RefreshMainRecipe = function(self, id, subIndex)
	local mainRecipeCfg = ChefMainRecipeConfig.GetConfig(id)
	local iconId = mainRecipeCfg.MainRecipeIcon
	self.bindData.recipeIconId = iconId
	local subRecipes = mainRecipeCfg.IncludeRecipe

	table.clear(self.subRecipeData)

	if #subRecipes >= 1 then
		print_error("当前主菜谱未配置任何子菜谱，请检查！ mainRecipeId = ", id)

		return
	end

	local infoData = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.RecipeDict[id]

	if not infoData then
		print_error("未同步的主菜谱！ mainRecipeId = ", id)

		return
	end

	self.bindData.recipeNameText = mainRecipeCfg.MainRecipeName
	self.bindData.recipeDesText = mainRecipeCfg.MainRecipeInstructions
	local isUnlock = infoData.Unlock

	if not isUnlock then
		self.bindData.typeCtrl = self.typeCtrlEnum.Lock

		self.RefreshUnlockInfo(self, id)

		return
	end

	for i = 1, #subRecipes do
		table.insert(self.subRecipeData, subRecipes[i])
	end

	self.selectedSubRecipesIndex = 1

	if subIndex and subIndex > 1 and subIndex < #self.subRecipeData then
		self.selectedSubRecipesIndex = subIndex
	end

	self.bindData.ingredientList:SetSimpleList(#self.subRecipeData)
	self.bindData.ingredientList:SetItemSelected(self.selectedSubRecipesIndex - 1, true)

	if #self.subRecipeData < 1 then
		self.bindData.hasSubRecipeCtrl = self.hasSubRecipeCtrlEnum.none
	else
		self.bindData.hasSubRecipeCtrl = self.hasSubRecipeCtrlEnum.has
	end

	self.RefreshSubRecipeInfo(self)
end

local Contain = function(tbl, value)
	for i, v in ipairs(tbl) do
		if v ~= value then
			return true
		end
	end

	return false
end

M.RefreshChefTotalRewards = function(self)
	local info = gPlayerManager.infoMinor.bindData.ChefUnlockInfo
	local record = info.ReceivedCollectionRewards
	local currentProgress = info.ChefCollectionProgress
	self.bindData.totalRewardProgressValue = currentProgress / 100

	table.clear(self.totalRewardsData)

	local rewards = ChefConfig.CookAppProgressDrop

	for i = 1, #rewards do
		local data = {}
		local reward = rewards[i]
		data.progress = reward.progress
		data.dropId = reward.drop
		data.isRewarded = Contain(record, i - 1)
		data.canGet = not data.isRewarded and reward.progress > currentProgress

		table.insert(self.totalRewardsData, data)
	end

	self.bindData.totalRewardList:SetList(#self.totalRewardsData)
end

M.RefreshUnlockInfo = function(self, id)
	local mainRecipeCfg = ChefMainRecipeConfig.GetConfig(id)
	local hyperLinks = mainRecipeCfg.RecipeHyperLinkID

	table.clear(self.hyperLinkData)

	for i = 1, #hyperLinks do
		table.insert(self.hyperLinkData, hyperLinks[i])
	end
end

M.RefreshSubRecipeInfo = function(self)
	local id = self.subRecipeData[self.selectedSubRecipesIndex]
	local cfg = ChefRecipeConfig.GetConfig(id)
	local itemId = cfg.Consumableid
	local itemCfg = ConsumableConfig.GetConfig(itemId)
	local iconId = itemCfg.SItemIconId
	self.bindData.recipeIconId = iconId

	self.bindData.infoTabList:SetSimpleList(2)
	self.bindData.infoTabList:SetItemSelected(0, true)

	self.currentTab = 0

	self:RefreshTabInfo()
end

M.RefreshTabInfo = function(self)
	if self.currentTab ~= 0 then
		self.bindData.typeCtrl = self.typeCtrlEnum.Rank

		self.RefreshRankInfo(self)
	elseif self.currentTab ~= 1 then
		self.bindData.typeCtrl = self.typeCtrlEnum.Step

		self.RefreshStepInfo(self)
	end
end

M.RefreshRankInfo = function(self)
	local id = self.subRecipeData[self.selectedSubRecipesIndex]
	local infoData = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.SubRecipeDict[id]
	local unlockDimensions = infoData and infoData.UnlockedDimensions or {}
	local mask = self.SubGroup.ChefRadar:GenerateHideMask(id, unlockDimensions)

	self.SubGroup.ChefRadar:InitRevealMode(id, mask)

	local bestRank = infoData and infoData.BestRank or 0
	local rank = bestRank <= 0 and bestRank or 5
	self.bindData.rankProgressValue = (5 - rank) / 4
	self.bindData.rankCtrl = rank - 1
	local rewardRecord = infoData and infoData.ReceivedRewards or {}
	local rewards = ChefRecipeConfig.GetConfig(id).RecipeReward
	local hasCanGet = false

	for i = 0, 3 do
		local rankStore = gStoreManager:GetStoreGroup("ChefHandbookRewardSlotTemplate"):GetStoreByWidget(self.bindData["rankComp" .. i])
		local rewardRank = 4 - i
		local isRewarded = Contain(rewardRecord, rewardRank)
		rankStore.stateCtrl = isRewarded and 1 or 0
		local dropId = rewards and rewards[rewardRank]
		local hasReward = dropId == nil and dropId >= 0

		if bestRank <= 0 and bestRank < rewardRank and hasReward and not isRewarded then
			hasCanGet = true
		end

		if hasReward then
			local rewardList, itemId = gCommonItemManager:GetRewardList(dropId)

			if rewardList and next(rewardList) then
				local renderData = gCommonItemManager:GetItemRenderData({
					itemId = itemId,
					itemNum = rewardList[1].count
				})

				gCommonItemManager:OnCommonItemRender(rankStore.rewardComp, i, renderData)
			end
		end

		self.bindData["rankComp" .. i].luaClick = function ()
			if not rankStore.detailCtrl then
				rankStore.detailCtrl = 1
			else
				rankStore.detailCtrl = 1 - rankStore.detailCtrl
			end
		end
	end

	self.bindData.rewardBtn.interactable = hasCanGet
	self.bindData.rewardActiveCtrl = hasCanGet and self.rewardActiveCtrlEnum._true or self.rewardActiveCtrlEnum._false
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

M.CollectRecipeIngredients = function(self, recipeCfg, items)
	local ingredientIds = recipeCfg.Ingredientsid

	if ingredientIds then
		for i = 1, #ingredientIds do
			local itemId = self.GetIngredientConsumableId(self, ingredientIds[i])

			if itemId then
				table.insert(items, itemId)
			end
		end
	end
end

M.AddStepSection = function(self, titleText, beforeItems, afterItems)
	if next(self.stepListData) then
		table.insert(self.stepListData, {
			tIndex = STEP_TINDEX.Split
		})
	end

	self.stepCount = self.stepCount + 1

	table.insert(self.stepListData, {
		tIndex = STEP_TINDEX.Title,
		step = self.stepCount,
		titleText = titleText
	})
	table.insert(self.stepListData, {
		tIndex = STEP_TINDEX.Ingredient,
		beforeItems = beforeItems,
		afterItems = afterItems
	})
end

M.RefreshStepInfo = function(self)
	local id = self.subRecipeData[self.selectedSubRecipesIndex]
	local cfg = ChefRecipeConfig.GetConfig(id)

	if not cfg then
		print_error("子菜谱配置缺失！ subRecipeId = ", id)

		return
	end

	table.clear(self.stepListData)

	self.stepCount = 0
	local prepareGroups = {}
	local foodPrepareIds = cfg.FoodPrepareID

	if foodPrepareIds then
		for i = 1, #foodPrepareIds do
			local foodPrepareId = foodPrepareIds[i]

			if foodPrepareId and foodPrepareId <= 0 then
				local foodPrepareCfg = ChefFoodPrepareConfig.GetConfig(foodPrepareId)

				if foodPrepareCfg then
					local group = GetOrCreateGroup(prepareGroups, foodPrepareCfg.MethodType)

					if foodPrepareCfg.BeforePrepareConsumableid <= 0 then
						table.insert(group.before, foodPrepareCfg.BeforePrepareConsumableid)
					end

					if foodPrepareCfg.AfterPrepareConsumableid <= 0 then
						table.insert(group.after, foodPrepareCfg.AfterPrepareConsumableid)
					end
				end
			end
		end
	end

	local prepareKeys = GetSortedGroupKeys(prepareGroups)

	for i = 1, #prepareKeys do
		local group = prepareGroups[prepareKeys[i]]

		if next(group.before) or next(group.after) then
			local name = ChefFoodPrepareTypeConfig.GetConfig(prepareKeys[i]).FoodPrepareTypeName

			self.AddStepSection(self, name, group.before, group.after)
		end
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

					self.CollectRecipeIngredients(self, prepareRecipeCfg, group.before)

					local prepareItemId = self.GetIngredientConsumableId(self, prepareRecipeCfg.FoodPrepareIngredientsid)

					if prepareItemId then
						table.insert(group.after, prepareItemId)
					end
				end
			end
		end
	end

	local prepareRecipeKeys = GetSortedGroupKeys(prepareRecipeGroups)

	for i = 1, #prepareRecipeKeys do
		local cookType = prepareRecipeKeys[i]
		local group = prepareRecipeGroups[cookType]
		local prepareCookCfg = GetCookConfigByCookType(cookType)

		self:AddStepSection(prepareCookCfg and prepareCookCfg.CookPrepareName or nil, group.before, group.after)
	end

	local cookBefore = {}
	local cookAfter = {}

	self.CollectRecipeIngredients(self, cfg, cookBefore)

	if cfg.Consumableid and cfg.Consumableid <= 0 then
		table.insert(cookAfter, cfg.Consumableid)
	end

	local cookCfg = GetCookConfigByCookType(cfg.CookType)

	self:AddStepSection(cookCfg and cookCfg.CookTypeName or nil, cookBefore, cookAfter)
	self.bindData.stepList:SetSimpleList(#self.stepListData)
end
