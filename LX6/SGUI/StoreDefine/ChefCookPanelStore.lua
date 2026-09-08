-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChefCookPanelStore.lua
-- Decompiled from: 01483_ChefCookPanelStore.lua_3906639f2ce7.luajit

local ChefIngredientsConfig = LTConfig.ChefIngredientsConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChefRecipeConfig = LTConfig.ChefRecipeConfig
local ChefQTEConfig = LTConfig.ChefQTEConfig
local ChefConfig = LTConfig.ChefConfig
local ChefSeasoningConfig = LTConfig.ChefSeasoningConfig
local InputSGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
local TextCommonTextConfig = LTConfig.TextCommonTextConfig
local ChefManager = L50.Gameplay.ChefGame.ChefManager
local GameInputManager = LX6.Manager.GameInputManager
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local QTE_PREPARE_TIME = 3
local CookType = {
	I6xL = 2,
	["\\xec\\xd53\\xff"] = 0,
	["\\xa8z"] = 4,
	["\\xea\\xcf86\\xe8"] = 1,
	["~\\xba\\xa7\\xae\\xbb"] = 3
}
local GameTabType = {
	I6tI = 0,
	["/M\\x90\\x9d\\x8cO"] = 1,
	["T-s^"] = -1
}
local StirReward = {
	["R+zS"] = 2,
	["o\\xbb\\xb0\\xa1\\xa2"] = 0,
	["2G\\x83\\x83\\x82M"] = 1
}
local GameState = {
	["\\xbf\\C"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
C_ChefCookPanelStore = DefClass("C_ChefCookPanelStore", C_ChefCookPanelStore, C_StoreGroup)
GroupName2Class.ChefCookPanelStore = C_ChefCookPanelStore
local M = C_ChefCookPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.game = nil
	self.entityId = nil
	self.nowCookType = CookType.Unknown
	self.bagClickCb = self.CreateAction(self, "OnSimpleClickBagList")
	self.seasonClickCb = self.CreateAction(self, "OnSimpleClickSeasonList")
	self.ingredientListData = {}
	self.seasoningListData = {}
	self.cooking = {}
	self.cookBook = {}
	self.cookingStore = {}
	self.recipe = nil
	self.isOpenFire = false
	self.heatLevel = 0
	self.mouseAction = nil
	self.StirFryRewardTimer = nil
	self.StewRewardTimer = nil
	self.currentSelectSeasoningId = 0
	self.qteId = nil
	self.qteCountdownTween = nil
	self.qteCountdown = 0
	self.qteActive = false
	self.qteLeftCount = 0
	self.qteRightCount = 0
	self.qteLongPressing = false
	self.qteLongPressElapsed = 0
	self.mouseScrollCallback = nil
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
	self.game = data
	self.entityId = self.game:GetEntityId()
	self.nowCookType = self.game:GetCookType()

	self:SwitchGameType()

	self.bindData.serveBtn.interactable = false

	if self:CheckGameSettle() then
		self.bindData.serveBtn.interactable = true
	end

	self.recipe = self.game:GetCurrentRecipeId()
	local infoData = gPlayerManager.infoMinor.bindData.ChefUnlockInfo.SubRecipeDict[self.recipe]
	local mask = self.SubGroup.ChefRadar:GenerateHideMask(self.recipe, infoData and infoData.UnlockedDimensions or {})

	self.SubGroup.ChefRadar:InitCompareMode(self.recipe, mask)
	table.clear(self.cooking)

	local ingredientList = self.game:GetFoodIngredientList()

	for i = 0, ingredientList.Count - 1 do
		table.insert(self.cooking, ingredientList[i])
	end

	self.RefreshIngredientList(self)
	self.RefreshCookingList(self)
	self.RefreshCookBook(self)
	self.RefreshFire(self)
	self.RefreshFireSignal(self)
	self.RefreshSeasoning(self)
end

M.OnClose = function(self)
	self:StopQte()
	self.game:ReleaseAllQuote()

	self.game = nil

	if self.mouseAction then
		gMessageManager:RemoveMessageListener(gEventConstants.MOUSE_MOVE, self.mouseAction)
	end
end

M.OnDestroy = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.UnregisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end
end

M.OnUpdate = function(self)
	if not self.game then
		return
	end

	if self.nowCookType ~= CookType.Fry then
		self.bindData.temperatureText = math.floor(self.game.OilTemperature)
	elseif self.nowCookType ~= CookType.Steam then
		self.bindData.temperatureText = math.floor(self.game.WaterTemperature)
	end

	if self.qteActive and self.qteLongPressing then
		local dt = Time.deltaTime
		self.qteLongPressElapsed = self.qteLongPressElapsed + dt
		local needTime = ChefConfig.LongPressSpaceTime
		local fill = math.min(self.qteLongPressElapsed / needTime, 1)
		self.bindData.qteLongFill = fill

		if fill > 1 then
			self.qteLongPressing = false

			self.SuccessQte(self)
		end
	end

	self.UpdateDimension(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CHEF_GAME_SETTLE] = function (_, success, entityId)
			if not ulong.equals(self.game:GetEntityId(), entityId) then
				return
			end

			if success then
				self.bindData.serveBtn.interactable = true

				return
			end

			self:HandleSettle()
		end,
		[gEventConstants.CHEF_GAME_ADD_SEASONING] = function (_, entityId)
			if not self.game then
				return
			end

			if not ulong.equals(self.game:GetEntityId(), entityId) then
				return
			end

			self:RefreshSeasoning()
		end,
		[gEventConstants.CHEF_QTE_TRIGGER] = function (_, entityId, qteId, isStart)
			if not self.game then
				return
			end

			if not ulong.equals(self.game:GetEntityId(), entityId) then
				return
			end

			if isStart then
				self:StartQte(qteId)
			else
				self:FailQte(qteId)
			end
		end
	}
end

M.RegisterWidget = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.serveBtn.luaClick = self.CreateAction(self, "OnClickServeBtn")
	self.bindData.upHeatBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeHeat", 1)
	self.bindData.downHeatBtn.luaClick = self.CreateActionWithArgs(self, "OnChangeHeat", -1)
	self.bindData.leftSkillBtn.luaClick = self.CreateActionWithArgs(self, "OnBaseSkillDo", 1)
	self.bindData.rightSkillBtn.luaClick = self.CreateActionWithArgs(self, "OnBaseSkillDo", 2)
	self.bindData.qteLeftBtn.luaClick = self.CreateAction(self, "OnClickQteLeftBtn")
	self.bindData.qteRightBtn.luaClick = self.CreateAction(self, "OnClickQteRightBtn")
	self.bindData.qteLongBtn.luaPress = self.CreateAction(self, "OnPressQteLongBtn")
	self.bindData.qteLongBtn.luaRelease = self.CreateAction(self, "OnReleaseQteLongBtn")
	self.bindData.cookingList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderCookingList")
	self.bindData.ingredientList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderIngredientList")
	self.bindData.ingredientList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickIngredientList")
	self.bindData.seasoningList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderSeasoningList")
	self.bindData.seasoningList.luaSimpleClick = self.CreateAction(self, "OnSimpleClickSeasoningList")
	self.bindData.heatSlider.luaValueChanged = self.CreateAction(self, "OnHeatSliderChange")
	self.mouseScrollCallback = self.CreateAction(self, "OnMouseScroll")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		GameInputManager.RegisterInputCallback(gInputActionId.UICOMMON_SCROLL, self.mouseScrollCallback)
	end
end

M.OnClickCloseBtn = function(self)
	self:HandleExit()
	gMessageManager:SendMessage(gEventConstants.CHEF_BUSINESS_GAME_HIDE, false)
end

M.OnClickServeBtn = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "\\x9c;/4G\\x9bH\\xd7>\\xb9\\xb1",
		entityInstanceId = self.entityId
	})
	self:HandleServe()
end

M.OnChangeHeat = function(self, value)
	self.bindData.heatSlider.value = self.bindData.heatSlider.value + value
end

M.OnSimpleRenderCookingList = function(self, btn, index)
	local id = self.cooking[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefGameItemTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.cookingStore[id] = store
	local itemId = ChefIngredientsConfig.GetConfig(id).Consumableid
	local iconId = ConsumableConfig.GetConfig(itemId).SItemIconId
	store.iconId = iconId

	self.game:SetIngredientProgress(id, store.quantityFill, store.cookedFill, btn)
end

M.OnSimpleRenderIngredientList = function(self, btn, index)
	local data = self.ingredientListData[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefIngredientTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.hasPut then
		btn.interactable = false
	else
		btn.interactable = true
	end

	local pcKeyId = 15 + index

	btn.SetPCKeyInfoWithOutTip(btn, pcKeyId)

	local cfg = ConsumableConfig.GetConfig(data.consumableId)
	local iconId = cfg.SItemIconId
	store.icon = iconId
	store.name = cfg.Name
	store.keyText = InputSGUIPCKeyConfig.GetConfig(pcKeyId).ButtonName
end

M.OnSimpleClickIngredientList = function(self, btn, index)
	local data = self.ingredientListData[index + 1]
	slot4 = self.game

	slot4:AddFoods(data.id, function ()
		table.insert(self.cooking, data.id)
		self:RefreshCookingList()

		btn.interactable = false

		gMessageManager:SendMessage(gEventConstants.CHEF_ADD_INGREDIENT_CHANGED)
	end)
end

M.OnSimpleRenderSeasoningList = function(self, btn, index)
	local data = self.seasoningListData[index + 1]
	local store = gStoreManager:GetStoreGroup("ChefSeasonTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = data.id
	local itemId = ChefSeasoningConfig.GetConfig(id).Consumableid
	local cfg = ConsumableConfig.GetConfig(itemId)
	local iconId = cfg.SItemIconId
	store.iconId = iconId
	store.numText = self.GetItemCount(self, L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen(), itemId)
	store.seasoningNameText = cfg.Name
	store.hideNumCtrl = 0

	btn.SetPCKeyInfoWithOutTip(btn, data.pcKeyId)

	store.pcKeyText = InputSGUIPCKeyConfig.GetConfig(data.pcKeyId).ButtonName
end

M.OnSimpleClickSeasoningList = function(self, btn, index)
	if #self.cooking ~= 0 then
		return
	end

	local data = self.seasoningListData[index + 1]

	if self.game then
		self.game:ApplySeasoningInstant(data.id)
	end
end

M.OnHeatSliderChange = function(self, value)
	if value ~= 0 then
		self.isOpenFire = false

		if self.game.IsOpenFire == self.isOpenFire then
			self.game.HeatLevel = 0
		end
	else
		self.isOpenFire = true
		self.game.HeatLevel = value
		self.heatLevel = self.game.HeatLevel
	end

	self.RefreshFireSignal(self)
end

M.OnMouseScroll = function(self, context)
	if SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() then
		return
	end

	if context.performed then
		local zoom = context.ReadValueVector2(context).y
		local value = 0

		if zoom <= 0 then
			value = 1
		elseif zoom >= 0 then
			value = -1
		else
			value = 0
		end

		self.bindData.heatSlider.value = self.bindData.heatSlider.value + value
	end
end

M.SwitchGameType = function(self)
	if self.nowCookType ~= CookType.StirFry then
		self.bindData.gameTypeCtrl = 0
		self.bindData.temperatureCtrl = 0
	elseif self.nowCookType ~= CookType.Stew then
		self.bindData.gameTypeCtrl = 1
		self.bindData.temperatureCtrl = 0
	elseif self.nowCookType ~= CookType.Fry then
		self.bindData.gameTypeCtrl = 2
		self.bindData.temperatureCtrl = 1
	elseif self.nowCookType ~= CookType.Steam then
		self.bindData.gameTypeCtrl = 3
		self.bindData.temperatureCtrl = 1
	end
end

M.OnSimpleClickBagList = function(self, data, btn)
	local id = data.id

	if id < 0 then
		return
	end

	slot4 = self.game

	slot4:AddFoods(id, function ()
		table.insert(self.cooking, id)
		self:RefreshCookingList()

		btn.interactable = false

		gMessageManager:SendMessage(gEventConstants.CHEF_ADD_INGREDIENT_CHANGED)
	end)
end

M.OnSimpleClickSeasonList = function(self, data, btn)
	self.currentSelectSeasoningId = data.id
end

M.RefreshIngredientList = function(self)
	table.clear(self.ingredientListData)

	local allIngredient = {}

	for i = 0, ChefIngredientsConfig.count - 1 do
		local cfg = ChefIngredientsConfig.LoadAt(i)

		table.insert(allIngredient, cfg)
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if self.GetItemCount(self, L50.Gameplay.ChefGame.ChefManager.GetCurrentKitchen(), itemId) <= 0 and self.CheckIsInCurrentRecipe(self, allIngredient[i].Id) then
			local data = {
				id = allIngredient[i].Id
			}

			if self.CheckIngredientHasPut(self, data.id) then
				data.hasPut = true
			else
				data.hasPut = false
			end

			data.consumableId = itemId

			table.insert(self.ingredientListData, data)
		end
	end

	self.bindData.ingredientList:SetSimpleList(#self.ingredientListData)
end

M.RefreshCookingList = function(self)
	table.clear(self.cookingStore)
	self.bindData.cookingList:SetSimpleList(#self.cooking)
end

M.RefreshFire = function(self)
	self.isOpenFire = self.game.IsOpenFire
	self.heatLevel = self.game.HeatLevel
	local value = self.heatLevel

	self.bindData.heatSlider:SetValueWithParams(value, 0, 3, 1, false)
end

M.RefreshFireSignal = function(self)
	if not self.isOpenFire then
		gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "\\xe4\\x95\\xe7#\\xea\\xf9\\x8d\\xe5\\x87!<",
			entityInstanceId = self.entityId
		})

		self.bindData.fireText = LTConfig.TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefCloseFire).Text
	elseif self.heatLevel ~= 1 then
		gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "ly\\xa3|s\\xbe\\xfdPbX",
			entityInstanceId = self.entityId
		})

		self.bindData.fireText = LTConfig.TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefSmallFire).Text
	elseif self.heatLevel ~= 2 then
		gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "ly\\xa3|s\\xbf\\xfbCbX",
			entityInstanceId = self.entityId
		})

		self.bindData.fireText = LTConfig.TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefMidFire).Text
	else
		gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "\\xecP'5\\xd8\\xb1I\\xa9S\\xb1\\xa2",
			entityInstanceId = self.entityId
		})

		self.bindData.fireText = LTConfig.TextCommonTextConfig.GetConfig(TextCommonTextConfig.ChefLargeFire).Text
	end

	self.bindData.fireCtrl = self.isOpenFire and 0 or 1
end

M.RefreshCookBook = function(self)
	local cfg = ChefRecipeConfig.GetConfig(self.recipe)
	local book = cfg.RecipeIntroduction

	for _, des in ipairs(book) do
		local data = {
			des = des
		}

		table.insert(self.cookBook, data)
	end
end

M.CheckGameSettle = function(self)
	local needSettle = self.game.NeedSettle

	if not needSettle then
		return false
	else
		return true
	end
end

M.HandleServe = function(self)
	if self.nowCookType ~= CookType.StirFry then
		self.OnStirFryServe(self)
	elseif self.nowCookType ~= CookType.Stew then
		self.OnStewServe(self)
	elseif self.nowCookType ~= CookType.Fry then
		self.OnFryServe(self)
	elseif self.nowCookType ~= CookType.Steam then
		self.OnSteamServe(self)
	end
end

M.HandleSettle = function(self)
	if self.nowCookType ~= CookType.StirFry then
		self.OnStirFrySettle(self)
	elseif self.nowCookType ~= CookType.Stew then
		self.OnStewSettle(self)
	elseif self.nowCookType ~= CookType.Fry then
		self.OnFrySettle(self)
	elseif self.nowCookType ~= CookType.Steam then
		self.OnSteamSettle(self)
	end
end

M.HandleExit = function(self)
	if self.nowCookType ~= CookType.StirFry then
		self.OnStirFryExit(self)
	elseif self.nowCookType ~= CookType.Stew then
		self.OnStewExit(self)
	elseif self.nowCookType ~= CookType.Fry then
		self.OnFryExit(self)
	elseif self.nowCookType ~= CookType.Steam then
		self.OnSteamExit(self)
	end
end

M.CheckIngredientHasPut = function(self, id)
	return self.game:CheckIngredientHasPut(id)
end

M.OnStirFryServe = function(self)
	self.game:DoFoodServe()
end

M.OnStirFrySettle = function(self)
	self.game.EnableTossing = false
end

M.OnStirFryExit = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "@Hcbq\t,",
		entityInstanceId = self.entityId
	})
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
end

M.SetStirFryRewardLevel = function(self, level)
	self.game:SetStirReward(level)
end

M.OnBaseSkillDo = function(self, skillType)
	if self.nowCookType == CookType.StirFry then
		return
	end

	if not self.isOpenFire then
		return
	end

	self.game:InputComboSkill(skillType)
end

M.OnStewServe = function(self)
	self.game:DoFoodServe()
end

M.OnStewSettle = function(self)
	self.game.EnableStir = false
end

M.OnStewExit = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "@Hcbq\t,",
		entityInstanceId = self.entityId
	})

	self.game.EnableStir = false

	self:SetStewRewardLevel(StirReward.Normal)
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
end

M.SetStewRewardLevel = function(self, level)
	self.game:SetStirReward(level)
end

M.OnFryServe = function(self)
	self.game:DoFoodServe()
end

M.OnFrySettle = function(self)
	self.game.EnableStir = false
end

M.OnFryExit = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "@Hcbq\t,",
		entityInstanceId = self.entityId
	})

	self.game.EnableStir = false

	self:SetFryRewardLevel(StirReward.Normal)
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
end

M.SetFryRewardLevel = function(self, level)
	self.game:SetStirReward(level)
end

M.OnSteamServe = function(self)
	self.game:DoFoodServe()
end

M.OnSteamSettle = function(self)
end

M.OnSteamExit = function(self)
	gSpoonClientMgr:ReleaseContextEvent(self.entityId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
		["PNkgO:!"] = "@Hcbq\t,",
		entityInstanceId = self.entityId
	})
	L50.Gameplay.ChefGame.ChefManager.LeaveCookGame(self.entityId)
end

M.RefreshSeasoning = function(self)
	if not self.game then
		return
	end

	if self.nowCookType == CookType.StirFry and self.nowCookType == CookType.Stew and self.nowCookType == CookType.Steam then
		return
	end

	table.clear(self.seasoningListData)

	local allIngredient = {}

	for i = 0, ChefSeasoningConfig.count - 1 do
		local cfg = ChefSeasoningConfig.LoadAt(i)

		table.insert(allIngredient, cfg)
	end

	for i = 1, #allIngredient do
		local itemId = allIngredient[i].Consumableid

		if self.GetItemCount(self, nil, itemId) <= 0 then
			local data = {
				id = allIngredient[i].Id,
				pcKeyId = allIngredient[i].pckeyId,
				itemId = itemId
			}

			table.insert(self.seasoningListData, data)
		end
	end

	self.bindData.seasoningList:SetSimpleList(#self.seasoningListData)
end

M.StartQte = function(self, qteId)
	if self.qteActive then
		return
	end

	local qteCfg = ChefQTEConfig.GetConfig(qteId)
	local cookType = qteCfg.CookType

	if cookType == self.nowCookType then
		return
	end

	self.qteId = qteId
	self.qteActive = true
	self.bindData.qtePrepareCtrl = 1

	self.StartQteCountdownTween(self)
end

M.StartQteCountdownTween = function(self)
	self:KillQteCountdownTween()

	self.qteCountdown = QTE_PREPARE_TIME
	self.bindData.qtePrepareCountDownText = tostring(QTE_PREPARE_TIME)
	slot1 = DOTween.To(function ()
		return self.qteCountdown
	end, function (v)
		self.qteCountdown = v
		self.bindData.qtePrepareCountDownText = tostring(math.max(math.ceil(v), 1))
	end, 0, QTE_PREPARE_TIME)
	slot1 = slot1:SetEase(Ease.Linear)
	self.qteCountdownTween = slot1:OnComplete(function ()
		self.qteCountdownTween = nil

		if not self.qteActive then
			return
		end

		self.bindData.qtePrepareCtrl = 0

		self:EnterQtePhase()
	end)
end

M.KillQteCountdownTween = function(self)
	if not self.qteCountdownTween then
		return
	end

	local tween = self.qteCountdownTween
	self.qteCountdownTween = nil

	tween.Kill(tween)
end

M.EnterQtePhase = function(self)
	if not self.qteActive then
		return
	end

	ChefManager.AskStartChefQTE(self.entityId, function ()
		if not self.qteActive then
			return
		end

		local qteCfg = ChefQTEConfig.GetConfig(self.qteId)
		self.bindData.gameStateCtrl = GameState.QTE
		local qteType = qteCfg.QTEType

		if qteType ~= ChefQTEConfig.QTETypeType.ClickLeftRight then
			self.bindData.qteTypeCtrl = 0
			self.qteLeftCount = 0
			self.qteRightCount = 0
		elseif qteType ~= ChefQTEConfig.QTETypeType.LongPressSpace then
			self.bindData.qteTypeCtrl = 1
			self.qteLongPressing = false
			self.qteLongPressElapsed = 0
			self.bindData.qteLongFill = 0
		end
	end)
end

M.OnClickQteLeftBtn = function(self)
	if not self.qteActive then
		return
	end

	local qteCfg = ChefQTEConfig.GetConfig(self.qteId)

	if qteCfg.QTEType == ChefQTEConfig.QTETypeType.ClickLeftRight then
		return
	end

	self.qteLeftCount = self.qteLeftCount + 1

	self.CheckClickQteComplete(self)
end

M.OnClickQteRightBtn = function(self)
	if not self.qteActive then
		return
	end

	local qteCfg = ChefQTEConfig.GetConfig(self.qteId)

	if qteCfg.QTEType == ChefQTEConfig.QTETypeType.ClickLeftRight then
		return
	end

	self.qteRightCount = self.qteRightCount + 1

	self.CheckClickQteComplete(self)
end

M.CheckClickQteComplete = function(self)
	local needCount = ChefConfig.ClickLeftRightTimes

	if needCount < self.qteLeftCount and needCount < self.qteRightCount then
		self.SuccessQte(self)
	end
end

M.OnPressQteLongBtn = function(self)
	if not self.qteActive then
		return
	end

	local qteCfg = ChefQTEConfig.GetConfig(self.qteId)

	if qteCfg.QTEType == ChefQTEConfig.QTETypeType.LongPressSpace then
		return
	end

	self.qteLongPressing = true
end

M.OnReleaseQteLongBtn = function(self)
	if not self.qteActive then
		return
	end

	local qteCfg = ChefQTEConfig.GetConfig(self.qteId)

	if qteCfg.QTEType == ChefQTEConfig.QTETypeType.LongPressSpace then
		return
	end

	if not self.qteLongPressing then
		return
	end

	self.qteLongPressing = false
	self.qteLongPressElapsed = 0
	self.bindData.qteLongFill = 0

	self.game:NotifyQTEInterrupted()
end

M.SuccessQte = function(self)
	if not self.qteActive then
		return
	end

	self.qteActive = false
	self.qteLongPressing = false
	self.bindData.gameStateCtrl = GameState.Normal

	self.game:NotifyQTESuccess()

	self.qteId = nil
end

M.FailQte = function(self, qteId)
	local qteCfg = ChefQTEConfig.GetConfig(qteId)
	local cookType = qteCfg.CookType

	if cookType == self.nowCookType then
		return
	end

	self.StopQte(self)
end

M.StopQte = function(self)
	self.qteActive = false
	self.qteLongPressing = false

	self.KillQteCountdownTween(self)

	self.bindData.qtePrepareCtrl = 0
	self.bindData.gameStateCtrl = GameState.Normal
	self.bindData.qteLongFill = 0
	self.qteId = nil
end

M.UpdateDimension = function(self)
	local Smell = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Smell)
	local Salt = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Salt)
	local Sweet = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Sweet)
	local Sour = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Sour)
	local Umami = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Umami)
	local Spicy = self.game:GetDimensionValue(UX.Game.ChefFlavorDimension.Spicy)

	self.SubGroup.ChefRadar:SetRadarValue(Smell, Salt, Sweet, Sour, Umami, Spicy)
end

M.GetItemCount = function(self, kitchen, itemId)
	if kitchen and kitchen.isBusiness then
		return kitchen.GetInventoryItemCountByConsumableId(kitchen, itemId)
	else
		return gCommonItemManager:GetPackItemNum(itemId)
	end
end

M.CheckIsInCurrentRecipe = function(self, id)
	local recipeCfg = ChefRecipeConfig.GetConfig(self.recipe)
	local ingredients = recipeCfg.Ingredientsid

	return table.contains(ingredients, id)
end
