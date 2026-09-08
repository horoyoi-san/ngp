-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefCookPreparePanelStore.lua
-- Decompiled from: 01448_ChefCookPreparePanelStore.lua_c188fa8c82c5.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefFoodPrepareConfig = LTConfig.ChefFoodPrepareConfig
local ChefCookNpcConfig = LTConfig.ChefCookNpcConfig
local MessageConfig = LTConfig.MessageConfig
local AgentConfig = LTConfig.AgentConfig
local ChefConfig = LTConfig.ChefConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager
C_ChefCookPreparePanelStore = DefClass("C_ChefCookPreparePanelStore", C_ChefCookPreparePanelStore, C_StoreGroup)
GroupName2Class.ChefCookPreparePanelStore = C_ChefCookPreparePanelStore
local M = C_ChefCookPreparePanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curChefAgentData = {}
	self.curChefSelectData = {}
	self.menuData = {}
	self.curShowData = {}
	self.kitchen = nil
	self.isAgentMode = false
	self.currentAgent = 37014003
	self.workSpace = 1
	self.currentWorkCount = 0
	self.isWorking = false
	self.currentNpcInfo = nil
	self.WORK_LIST_TEMPLATE = {
		["h\\x83\\x92\\x9b\\x8f"] = 1,
		["M\rOp"] = 0
	}
end

M.DefineAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = {
		["\\x81n`"] = 1,
		[""] = 0
	}
	self.buttonActiveCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.typeCtrlEnum = {
		["-"] = 0,
		["b\\xba\\xaa\\xaa\\xa4"] = 1
	}
	self.tooltipActiveCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.stateCtrlEnum = nil
	self.buttonActiveCtrlEnum = nil
	self.typeCtrlEnum = nil
	self.tooltipActiveCtrlEnum = nil
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
	self.kitchen = ChefManager.GetCurrentKitchen()

	if self.kitchen ~= nil then
		print_error("当前无可用厨房！")

		return
	end

	self.isAgentMode = data.isAgentMode or false
	self.bindData.typeCtrl = self.isAgentMode and self.typeCtrlEnum.Other or self.typeCtrlEnum.Me
	self.selectIndex = 1

	if self.isAgentMode then
		self.RefreshChefAgent(self)
	end

	self.RefreshMenuList(self)
end

M.OnClose = function(self)
end

M.OnUpdate = function(self)
	if not self.isAgentMode then
		return
	end

	for _, data in ipairs(self.curChefAgentData) do
		local store = data.store
		local startTime = data.startTime

		if startTime ~= 0 then
			store.progressFill = 0
		else
			store.progressFill = math.min(1, (LTUtils.UXTime.GetNowUnixTime() - startTime) / data.totalTime)
		end
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_GAME_CHEF_AGENT_CHANGE] = function (_)
			self:RefreshChefAgent()
		end,
		[gEventConstants.CHEF_BUSINESS_REAL_ORDER_CHANGED] = function (_)
			self:RefreshMenuList()
		end,
		[gEventConstants.CHEF_RECIPE_UNLOCK_CHANGED] = function (_)
			self:RefreshMenuList()
		end,
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_IDLE] = function (_)
			self:RefreshChefAgent()
			self:RefreshMenuList()
		end,
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_END] = function (_)
			self:RefreshChefAgent()
			self:RefreshMenuList()
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.npcControlBtn.luaClick = self.CreateAction(self, "OnClickNpcControlBtn")
	self.bindData.leftBtn.luaClick = self.CreateAction(self, "OnLeftBtnClick")
	self.bindData.rightBtn.luaClick = self.CreateAction(self, "OnRightBtnClick")
	self.bindData.fullBtn.luaClick = self.CreateAction(self, "OnFullBtnClick")
	self.bindData.startBtn.luaClick = self.CreateAction(self, "OnStartBtnClick")
	self.bindData.chefWorkList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderChefWorkListItem")
	self.bindData.chefWorkList.onGetTIndex = self.CreateAction(self, "OnGetChefWorkListTIndex")
	self.bindData.menuList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderMenuListItem")
	self.bindData.menuList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickMenuListItem")
	self.bindData.showList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderShowListItem")
end

M.OnClickCloseBtn = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnLeftBtnClick = function(self)
	local preIndex = self.selectIndex
	self.selectIndex = self.selectIndex - 1

	if self.selectIndex >= 1 then
		self.selectIndex = #self.npcIds
	end

	if preIndex == self.selectIndex then
		self.RefreshChefAgent(self)
	end
end

M.OnRightBtnClick = function(self)
	local preIndex = self.selectIndex
	self.selectIndex = self.selectIndex + 1

	if self.selectIndex <= #self.npcIds then
		self.selectIndex = 1
	end

	if preIndex == self.selectIndex then
		self.RefreshChefAgent(self)
	end
end

M.OnClickNpcControlBtn = function(self)
	slot1 = self.kitchen
	local isWorking, npcInfo = slot1:GetNpcWorkInfo(self.currentAgent, nil)
	slot3 = self.kitchen

	slot3:ChangeChefAgent(self.currentAgent, not isWorking, function ()
		self.bindData.npcControlBtn.interactable = true

		self:RefreshChefAgent()
	end)

	self.bindData.npcControlBtn.interactable = false
end

M.OnFullBtnClick = function(self)
	self.bindData.tooltipActiveCtrl = self.tooltipActiveCtrlEnum._false
	self.curShowData = nil
end

M.OnStartBtnClick = function(self)
	ChefManager.AskInitChefFoodPrepare(self.curChefSelectData, function (err)
		if err ~= MessageConfig.Ok then
			gPanelManager:CheckShow(gPanelId.S_CHEF_CUT_PANEL, {
				prepareIdList = self.curChefSelectData
			})
		end

		gPanelManager:Close(self.m_Id)
	end)
end

M.OnAddBtnClick = function(self, id)
	if self.isAgentMode then
		if not self.isWorking then
			return
		end

		local workInfoList = self.currentNpcInfo.WorkInfos

		if self.workSpace < workInfoList.Count then
			return
		end

		slot3 = self.kitchen

		slot3:AddChefAgentWorkSequence(self.currentAgent, id, function ()
			self:RefreshChefAgent()
		end)
	else
		if ChefConfig.PlayerFoodPrepareMaxCnt < #self.curChefSelectData then
			return
		end

		table.insert(self.curChefSelectData, id)
		self.RefreshChefSelectList(self)
	end
end

M.OnCancelBtnClick = function(self, index)
	table.remove(self.curChefSelectData, index)
	self.RefreshChefSelectList(self)
end

M.OnGetChefWorkListTIndex = function(self, index)
	if self.isAgentMode then
		if self.currentNpcInfo and self.currentNpcInfo.WorkInfos and index >= self.currentNpcInfo.WorkInfos.Count then
			return self.WORK_LIST_TEMPLATE.WORK
		end

		return self.WORK_LIST_TEMPLATE.EMPTY
	else
		return self.WORK_LIST_TEMPLATE.WORK
	end
end

M.OnSimpleRenderChefWorkListItem = function(self, btn, index)
	if self.isAgentMode then
		self.RenderChefWorkListItemAgent(self, btn, index)
	else
		self.RenderChefWorkListItemNormal(self, btn, index)
	end
end

M.RenderChefWorkListItemAgent = function(self, btn, index)
	if not self.currentNpcInfo or not self.currentNpcInfo.WorkInfos or self.currentNpcInfo.WorkInfos.Count < index then
		return
	end

	local workInfoList = self.currentNpcInfo.WorkInfos
	local workInfo = workInfoList[index]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefCutPrepareListTemplate"):GetStoreById(id)

	if store then
		local data = {
			store = store,
			startTime = workInfo.WorkTime,
			workId = workInfo.WorkId
		}
		local cfg = ChefFoodPrepareConfig.GetConfig(data.workId)
		data.totalTime = cfg.PrepareTime

		table.insert(self.curChefAgentData, data)

		local itemCfg = ConsumableConfig.GetConfig(cfg.AfterPrepareConsumableid)
		local preItemCfg = ConsumableConfig.GetConfig(cfg.BeforePrepareConsumableid)
		local iconId = itemCfg and itemCfg.SItemIconId
		local preIconId = preItemCfg and preItemCfg.SItemIconId
		store.typeCtrl = 1
		store.beforeIconId = preIconId
		store.afterIconId = iconId
	end
end

M.RenderChefWorkListItemNormal = function(self, btn, index)
	local data = self.curChefSelectData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefCutPrepareListTemplate"):GetStoreById(id)

	if store then
		local cfg = ChefFoodPrepareConfig.GetConfig(data)
		local itemCfg = ConsumableConfig.GetConfig(cfg.AfterPrepareConsumableid)
		local preItemCfg = ConsumableConfig.GetConfig(cfg.BeforePrepareConsumableid)
		local iconId = itemCfg and itemCfg.SItemIconId
		local preIconId = preItemCfg and preItemCfg.SItemIconId
		store.typeCtrl = 0
		store.beforeIconId = preIconId
		store.afterIconId = iconId
		store.cancelBtn.luaClick = self:CreateActionWithArgs("OnCancelBtnClick", index + 1)
	end
end

M.OnSimpleRenderMenuListItem = function(self, btn, index)
	local data = self.menuData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefMenuItemTemplate"):GetStoreById(id)

	if store then
		store.nameText = data.name
		store.iconId = data.iconId
	end
end

M.OnSimpleClickMenuListItem = function(self, btn, index)
	local data = self.menuData[index + 1]

	self.RefreshToolTip(self, data)
end

M.OnSimpleRenderShowListItem = function(self, btn, index)
	local data = self.curShowData[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefPrepareShowTemplate"):GetStoreById(id)

	if store then
		store.beforeIconId = data.preIconId
		store.beforeNameText = data.preItemName
		store.afterIconId = data.iconId
		store.afterNameText = data.itemName
		store.addBtn.luaClick = self.CreateActionWithArgs(self, "OnAddBtnClick", data.id)
	end
end

M.OnSimpleRenderStepListItem = function(self, menuId, btn, index)
	local data = self.menuData[menuId + 1].workList[index + 1]
	local id = btn.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("ChefIngredientTemplate"):GetStoreById(id)

	if store then
		store.productIconId = data.iconId
		store.beforeIcon = data.preIconId
		store.progressFill = 0
		btn.interactable = self:GetItemCount(data.preItemId) >= 0
	end
end

M.OnSimpleClickStepList = function(self, menuId, btn, index)
	if not self.isWorking then
		return
	end

	local data = self.menuData[menuId + 1].workList[index + 1]
	local workInfoList = self.currentNpcInfo.WorkInfos

	if self.workSpace < workInfoList.Count then
		return
	end

	slot6 = self.kitchen

	slot6:AddChefAgentWorkSequence(self.currentAgent, data.id, function ()
		self:RefreshChefAgent()
	end)
end

M.GetItemCount = function(self, itemId)
	if self.kitchen and self.kitchen.isBusiness then
		return self.kitchen:GetInventoryItemCountByConsumableId(itemId)
	else
		return gCommonItemManager:GetPackItemNum(itemId)
	end
end

M.RefreshChefAgent = function(self)
	self.curChefAgentData = {}

	if self.kitchen.isBusiness then
		self.bindData.buttonActiveCtrl = 1
		local npcList = self.kitchen:GetWorkNpcList()

		if npcList then
			self.npcIds = npcList.ToTable(npcList)
		else
			self.npcIds = {}
		end
	else
		self.bindData.buttonActiveCtrl = 0

		self.GetAllUnlockNpc(self)
	end

	if #self.npcIds ~= 0 then
		table.insert(self.npcIds, 37014003)
	end

	self.selectIndex = math.max(0, math.min(#self.npcIds, self.selectIndex))
	self.currentAgent = self.npcIds[self.selectIndex]
	local cfg = ChefCookNpcConfig.GetConfig(self.currentAgent)
	self.workSpace = cfg.PrepareSpace
	local isWorking, npcInfo = self.kitchen:GetNpcWorkInfo(self.currentAgent, nil)
	self.isWorking = isWorking
	self.currentNpcInfo = npcInfo

	self.bindData.chefWorkList:SetSimpleList(cfg.PrepareSpace)

	if not isWorking then
		self.bindData.stateCtrl = 0
	else
		self.bindData.stateCtrl = 1
	end

	local id = self.bindData.headAvatar.gameObject:GetInstanceID()
	local store = gStoreManager:GetStoreGroup("HeadAvatarStore"):GetStoreById(id)

	if store then
		local agentId = cfg.AgentID
		local iconId = AgentConfig.GetConfig(agentId).HeadIcon
		store.headIcon = iconId
	end
end

M.GetAllUnlockNpc = function(self)
	self.npcIds = {}

	for i = 1, ChefCookNpcConfig.count do
		local config = ChefCookNpcConfig.LoadAt(i - 1)

		if gEventConditionUtils.CheckHasUnlocked(config, UX.Game.EventConditionImplModule.ChefCookNpcUnlock) then
			table.insert(self.npcIds, config.Id)
		end
	end
end

M.RefreshMenuList = function(self)
	if self.kitchen.isBusiness then
		self.RefreshBusinessMenuList(self)
	else
		self.RefreshNormalMenuList(self)
	end
end

M.BuildRecipeData = function(self, cfg)
	local recipeData = {
		id = cfg.Id
	}
	local recipeItemId = cfg.Consumableid
	local recipeItemCfg = ConsumableConfig.GetConfig(recipeItemId)
	recipeData.iconId = recipeItemCfg.SItemIconId
	recipeData.name = cfg.RecipeName
	local workList = {}

	for _, id in ipairs(cfg.FoodPrepareID) do
		local workCfg = ChefFoodPrepareConfig.GetConfig(id)
		local itemCfg = ConsumableConfig.GetConfig(workCfg.AfterPrepareConsumableid)
		local preItemCfg = ConsumableConfig.GetConfig(workCfg.BeforePrepareConsumableid)

		if itemCfg and preItemCfg then
			local data = {
				id = id,
				iconId = itemCfg and itemCfg.SItemIconId,
				itemId = workCfg.AfterPrepareConsumableid,
				itemName = itemCfg.Name,
				preIconId = preItemCfg and preItemCfg.SItemIconId,
				preItemId = workCfg.BeforePrepareConsumableid,
				preItemName = preItemCfg.Name
			}

			table.insert(workList, data)
		end
	end

	recipeData.workList = workList

	return recipeData
end

M.RefreshBusinessMenuList = function(self)
	self.menuData = {}
	local addRecipe = {}
	local predictRecipeSequence = self.kitchen.predictRecipeSequence

	if predictRecipeSequence then
		local predictRecipeSequenceTable = predictRecipeSequence.ToTable(predictRecipeSequence)

		for i = 1, #predictRecipeSequenceTable do
			local predictRecipe = predictRecipeSequenceTable[i]

			if predictRecipe and not addRecipe[predictRecipe] then
				addRecipe[predictRecipe] = true
				local cfg = ChefRecipeConfig.GetConfig(predictRecipe)

				if cfg and #cfg.FoodPrepareID <= 0 then
					table.insert(self.menuData, self.BuildRecipeData(self, cfg))
				end
			end
		end
	end

	self.bindData.menuList:SetSimpleList(#self.menuData)
end

M.RefreshNormalMenuList = function(self)
	self.menuData = {}

	for i = 0, ChefRecipeConfig.count - 1 do
		local cfg = ChefRecipeConfig.LoadAt(i)

		if cfg and cfg.PrepareType ~= ChefRecipeConfig.PrepareTypeType.Cook and ChefManager.IsRecipeUnlock(cfg.BelongRecipe) and #cfg.FoodPrepareID <= 0 then
			table.insert(self.menuData, self.BuildRecipeData(self, cfg))
		end
	end

	self.bindData.menuList:SetSimpleList(#self.menuData)
end

M.RefreshToolTip = function(self, data)
	self.bindData.tooltipActiveCtrl = self.tooltipActiveCtrlEnum._true
	self.curShowData = data.workList

	self.bindData.showList:SetSimpleList(#self.curShowData)
end

M.RefreshChefSelectList = function(self)
	self.bindData.chefWorkList:SetSimpleList(#self.curChefSelectData)
end
