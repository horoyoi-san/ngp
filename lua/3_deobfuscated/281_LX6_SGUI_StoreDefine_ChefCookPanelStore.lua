local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
C_ChefCookPanelStore = DefClass("C_ChefCookPanelStore", C_ChefCookPanelStore, C_StoreGroup)
GroupName2Class.ChefCookPanelStore = C_ChefCookPanelStore
local M = C_ChefCookPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.game = nil
	self.entityId = nil
	self.bagClickCb = self:CreateAction("OnSimpleClickBagList")
	self.cooking = {}
	self.cookBook = {}
	self.cookingStore = {}
	self.recipe = nil
	self.isOpenFire = false
	self.heatLevel = 1
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
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.game = data
	self.entityId = self.game:GetEntityId()
	self.bindData.serveBtn.interactable = false

	if self:CheckGameSettle() then
		local result = self.game.IsSuccess

		if not result then
			gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
				isSuccess = result
			})
			gSpoonClientMgr:ReleaseContextEvent(self.entityId, gSpoonEventType.OnReceiveSignal, {
				signalKey = "cook_exit",
				entityInstanceId = self.entityId
			})

			self.game.EnableTossing = false

			L50.Gameplay.ChefGame.ChefManager.DestroyCookGame(self.entityId)

			return
		else
			self.bindData.serveBtn.interactable = true
		end
	end

	self.recipe = self.game:GetCurrentRecipeId()

	table.clear(self.cooking)

	local ingredientList = self.game:GetFoodIngredientList()

	for i = 0, ingredientList.Count - 1 do
		table.insert(self.cooking, ingredientList[i])
	end

	self:RefreshCookingList()
	self:RefreshCookBook()
	self:RefreshFire()
	gPanelManager:CheckShow(gPanelId.S_CHEF_BAG_PANEL, self.recipe)
end

function M:OnClose()
	local store = gStoreManager:GetStoreGroup("ChefBagPanelStore")

	if store then
		store:UnRegisterListClickEvent()
	end

	self.game:ReleaseAllQuote()

	self.game = nil

	gPanelManager:CheckShow(gPanelId.S_CHEF_BAG_PANEL)
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.PANEL_ON_SHOW] = function (_, panelId)
			if panelId == gPanelId.S_CHEF_BAG_PANEL then
				local store = gStoreManager:GetStoreGroup("ChefBagPanelStore")

				if store then
					store:RegisterListClickEvent(self.bagClickCb)
				end
			end
		end,
		[gEventConstants.CHEF_GAME_SETTLE] = function (_, success)
			if success then
				self.bindData.serveBtn.interactable = true

				return
			end

			gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
				isSuccess = success
			})
			gSpoonClientMgr:ReleaseContextEvent(self.entityId, gSpoonEventType.OnReceiveSignal, {
				signalKey = "cook_exit",
				entityInstanceId = self.entityId
			})

			self.game.EnableTossing = false

			L50.Gameplay.ChefGame.ChefManager.DestroyCookGame(self.entityId)
		end
	}
end

function M:RegisterWidget()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.wokEnterBtn.luaClick = self:CreateAction("OnClickWokEnterBtn")
	self.bindData.wokExitBtn.luaClick = self:CreateAction("OnClickWokExitBtn")
	self.bindData.fireBtn.luaClick = self:CreateAction("OnClickFireBtn")
	self.bindData.serveBtn.luaClick = self:CreateAction("OnClickServeBtn")
	self.bindData.cookingList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderCookingList")
	self.bindData.cookBookList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderCookBookListList")
	self.bindData.heatSlider.luaValueChanged = self:CreateAction("OnHeatSliderChange")
end

function M:OnClickCloseBtn()
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, gSpoonEventType.OnReceiveSignal, {
		signalKey = "cook_exit",
		entityInstanceId = self.entityId
	})

	self.game.EnableTossing = false

	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
end

function M:OnClickWokEnterBtn()
	self.bindData.gameStateCtrl = 1
	self.game.EnableTossing = true

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_CHEF_COOK_PANEL, true)
end

function M:OnClickWokExitBtn()
	self.bindData.gameStateCtrl = 0
	self.game.EnableTossing = false

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_CHEF_COOK_PANEL, false)
end

function M:OnClickFireBtn()
	self.isOpenFire = not self.isOpenFire
	self.game.IsOpenFire = self.isOpenFire
	self.bindData.fireCtrl = self.isOpenFire and 0 or 1
end

function M:OnClickServeBtn()
	gPanelManager:CheckShow(gPanelId.S_CHALLENGE_END_PANEL, {
		isSuccess = true
	})
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, gSpoonEventType.OnReceiveSignal, {
		signalKey = "cook_exit",
		entityInstanceId = self.entityId
	})

	self.game.EnableTossing = false

	L50.Gameplay.ChefGame.ChefManager.DestroyCookGame(self.entityId)
end

function M:OnSimpleRenderCookingList(btn, index)
	local id = self.cooking[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefGameItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.cookingStore[id] = store
	local itemId = ChefIngredientsConfig.GetConfig(id).Consumableid
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId

	self.game:SetIngredientProgress(id, store.quantityFill, store.cookedFill, function ()
		store.stateCtrl = 1
	end)
end

function M:OnSimpleRenderCookBookListList(btn, index)
	local data = self.cookBook[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefCookBookTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.cookText = data.des
end

function M:OnHeatSliderChange(value)
	self.game.HeatLevel = value - 1
end

function M:OnSimpleClickBagList(data)
	local id = data

	self.game:AddFoods(id, function ()
		table.insert(self.cooking, id)
		self:RefreshCookingList()
	end)
end

function M:RefreshCookingList()
	table.clear(self.cookingStore)
	self.bindData.cookingList:SetSimpleList(#self.cooking)
end

function M:RefreshFire()
	self.isOpenFire = self.game.IsOpenFire
	self.heatLevel = self.game.HeatLevel
	self.bindData.fireCtrl = self.isOpenFire and 0 or 1

	self.bindData.heatSlider:SetValueWithParams(self.heatLevel, 1, 3, 1, false)
end

function M:RefreshCookBook()
	local cfg = ChefRecipeConfig.GetConfig(self.recipe)
	local book = cfg.RecipeIntroduction

	for _, des in ipairs(book) do
		local data = {
			des = des
		}

		table.insert(self.cookBook, data)
	end

	self.bindData.cookBookList:SetSimpleList(#self.cookBook)
end

function M:CheckGameSettle()
	local needSettle = self.game.NeedSettle

	if not needSettle then
		return false
	else
		return true
	end
end
