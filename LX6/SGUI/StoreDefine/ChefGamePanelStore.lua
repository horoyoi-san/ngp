-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefGamePanelStore.lua
-- Decompiled from: 01418_ChefGamePanelStore.lua_59d2473830ea.luajit

C_ChefGamePanelStore = DefClass("C_ChefGamePanelStore", C_ChefGamePanelStore, C_StoreGroup)
GroupName2Class.ChefGamePanelStore = C_ChefGamePanelStore
local M = C_ChefGamePanelStore
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeState = UX.Game.ChefRecipeState

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = {
		["\\xbc}h"] = 1,
		["\\xe9\\xc9\r6\\xf4"] = 0
	}
	self.fullCompleteCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.typeCtrlEnum = nil
	self.fullCompleteCtrlEnum = nil
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

	self.ShowPrepareContent(self, data)
end

M.OnClose = function(self)
	self.isShow = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_START] = function (eventId)
			self:RefreshBusiness()
		end,
		[gEventConstants.CHEF_BUSINESS_GAME_HIDE] = function (eventId, hide)
			if self.rootGo then
				self.rootGo:SetActive(not hide)
			end
		end,
		[gEventConstants.CHEF_BUSINESS_GAMEPLAY_END] = function (eventId)
			gPanelManager:Close(gPanelId.CHEF_GAME_PANEL)
		end,
		[gEventConstants.CHEF_BUSINESS_REAL_ORDER_CHANGED] = function (eventId)
			self:RefreshBusiness()
		end,
		[gEventConstants.CHEF_BUSINESS_RECIPE_STATE_CHANGED] = function (eventId, recipeUid, state)
			self:RefreshRecipeState(recipeUid, state)
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.orderBtn.luaClick = self.CreateAction(self, self.OnClickOrderBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.skipBtn.luaClick = self.CreateAction(self, self.SendSkipPrepareStage)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
end

M.OnClickOrderBtn = function(self)
	if not gPanelManager:IsPanelShowing(gPanelId.S_CHEF_COOK_PREPARE_PANEL) then
		gPanelManager:CheckShow(gPanelId.S_CHEF_COOK_PREPARE_PANEL)
	end
end

M.OnClickBackBtn = function(self)
	local cancelText = LTConfig.TextScriptTextConfig.GetConfig(89900120).Text
	local confirmText = LTConfig.TextScriptTextConfig.GetConfig(89900149).Text
	local content = LTConfig.MessageConfig.GetConfig(LTConfig.MessageConfig.ChefBusinessExit).Content
	slot4 = gDisplayMessageMgr

	slot4:ShowMessageContent(content, gDisplayMessageId.SELECT, nil, function ()
		gClientToGameSceneDelegate:AskFinishChefManagementRound().Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		gPanelManager:Close(gPanelId.CHEF_GAME_PANEL)
	end, nil, confirmText, cancelText)
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local data = self.orderData[index + 1]

	if not data then
		return
	end

	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	store.title = index + 1
	store.fullCompleteCtrl = data.allComplete and 1 or 0
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnSimpleRenderOrderRecipeListItem, index + 1)

	store.list:SetSimpleList(#data.recipes)

	if data.needTime < 0 then
		store.progress.value = 0
	else
		local percent = (data.endTime - gCS.TimeManager.ServerUnixTime) / data.needTime

		store.progress:ProgressToValue(math.max(0, math.min(1, percent)))
	end
end

M.OnSimpleRenderOrderRecipeListItem = function(self, dataIndex, btn, index)
	local data = self.orderData[dataIndex]

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

	store.completeCtrl = recipeData.state ~= ChefRecipeState.Served and 1 or 0
	local recipeConfig = ChefRecipeConfig.GetConfig(recipeData.recipeId)

	if recipeConfig and recipeConfig.Consumableid <= 0 then
		local consumableCfg = ConsumableConfig.GetConfig(recipeConfig.Consumableid)
		store.productIconId = consumableCfg and consumableCfg.SItemIconId
	end
end

M.ShowPrepareContent = function(self, prepareFinishTime)
	self.kitchen = L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen()

	if self.kitchen ~= nil then
		print_error("Chef job error:打开厨师经营背包界面失败，当前无可用厨房！")

		return
	end

	self.prepareFinishTime = prepareFinishTime or 0
	self.bindData.typeCtrl = self.typeCtrlEnum.Prepare
	self.curState = self.typeCtrlEnum.Prepare
	self.countDownLen = math.max(1, self.prepareFinishTime - gCS.TimeManager.ServerUnixTime)
	self.sendSkip = false

	self:RefreshCountDown(self.countDownLen)
end

M.SendSkipPrepareStage = function(self)
	if not self.sendSkip then
		self.sendSkip = true

		gClientToGameSceneDelegate:AskFinishChefPrepareCountDown().Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end

		self:RefreshBusiness()
	end
end

M.RefreshCountDown = function(self, curTime)
	local store = gStoreManager:GetStoreGroup(self.bindData.countDown.Store):GetStoreByWidget(self.bindData.countDown)

	if not store then
		return
	end

	store.fillValue = math.max(0, math.min(1, 1 - curTime / self.countDownLen))
	store.countDownTime = gTimeUtils:FormatTime(curTime, true)
end

M.OnUpdate = function(self)
	if self.curState ~= self.typeCtrlEnum.Prepare then
		local curTime = self.prepareFinishTime - gCS.TimeManager.ServerUnixTime

		if curTime < 0 then
			curTime = 0

			self.SendSkipPrepareStage(self)
		end

		self.RefreshCountDown(self, curTime)
	else
		local curTime = gCS.TimeManager.ServerUnixTime - self.lastUpdateTime

		if curTime <= 1 then
			self.lastUpdateTime = gCS.TimeManager.ServerUnixTime

			self.bindData.list:RefreshList()
		end
	end
end

M.RefreshBusiness = function(self)
	self.lastUpdateTime = gCS.TimeManager.ServerUnixTime
	self.bindData.typeCtrl = self.typeCtrlEnum.Run
	self.curState = self.typeCtrlEnum.Run
	self.orderData = {}

	if self.kitchen then
		local realOrders = self.kitchen.realOrders

		if realOrders then
			local realOrderTable = realOrders.ToTable(realOrders)

			for i = 1, #realOrderTable do
				local realOrderInfo = realOrderTable[i]
				local orderInfo = {}
				local needTime = 0

				if realOrderInfo.Recipes == nil then
					orderInfo.recipes = {}
					orderInfo.allComplete = true
					local recipesTable = realOrderInfo.Recipes:ToTable()

					for k, v in pairs(recipesTable) do
						if v.State == ChefRecipeState.Served then
							orderInfo.allComplete = false
						end

						table.insert(orderInfo.recipes, {
							recipeUid = k,
							recipeId = v.RecipeId,
							state = v.State
						})

						local recipeCfg = ChefRecipeConfig.GetConfig(v.RecipeId)

						if recipeCfg then
							needTime = needTime + recipeCfg.RecipeTime
						end
					end
				else
					orderInfo.allComplete = false
				end

				orderInfo.needTime = needTime
				orderInfo.endTime = realOrderInfo.CreateTime + needTime

				table.insert(self.orderData, orderInfo)
			end
		end
	end

	self.bindData.list:SetSimpleList(#self.orderData)
end

M.RefreshRecipeState = function(self, recipeUid, state)
	for i = 1, #self.orderData do
		local orderInfo = self.orderData[i]

		if orderInfo.recipes then
			local index = nil
			orderInfo.allComplete = true

			for j = 1, #orderInfo.recipes do
				local recipeInfo = orderInfo.recipes[j]

				if ulong.equals(recipeInfo.recipeUid, recipeUid) then
					recipeInfo.state = state
					index = i - 1
				end

				if recipeInfo.state == ChefRecipeState.Served then
					orderInfo.allComplete = false
				end
			end

			if index then
				self.bindData.list:RefreshElement(index)

				return
			end
		end
	end
end
