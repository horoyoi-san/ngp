local RestaurantConfig = LTConfig.RestaurantConfig
local RestaurantFoodConfig = LTConfig.RestaurantFoodConfig
local AgentConfig = LTConfig.AgentConfig
local MessageConfig = LTConfig.MessageConfig
local SguiImageConfig = LTConfig.SguiImageConfig
C_RestaurantPhonePanelStore = DefClass("C_RestaurantPhonePanelStore", C_RestaurantPhonePanelStore, C_StoreGroup)
GroupName2Class.RestaurantPhonePanelStore = C_RestaurantPhonePanelStore
local M = C_RestaurantPhonePanelStore

function M:OnAwake()
	self.bindData.menuList.luaRenderItem = self:CreateAction("OnRenderMenuItem")
	self.bindData.menuList.luaClick = self:CreateAction("OnClickMenuItem")
	self.bindData.btnBack.luaClick = self:CreateAction("OnClickBtnBack")
	self.bindData.btnCommit.luaClick = self:CreateAction("OnClickBtnCommit")
	self.bindData.btnDetailCommit.luaClick = self:CreateAction("OnClickBtnDetailCommit")
	self.cfg = nil
	self.focusNpc = nil
	self.mode = nil
	self.gameplayId = nil
	self.inviteNpcCfg = nil
	self.npcDailyCfg = nil
	self.gameplayHudPanelStore = nil
	self.meetConditions = false
	self.npcTreat = false
	self.menuList = {}
	self.orderList = nil
	self.totalCost = 0
	self.curOrderCount = 0
	self.targetOrderCount = 0
	self.curFoodDetailIndex = nil
	self.curTabIndex = 0
	self.lastAddTime = -1
	self.lastAtomsphereDialogTime = -5
	self.OrderTextTime = RestaurantConfig.OrderTextTime
	self.OrderTextCD = RestaurantConfig.OrderTextCD
	self.OrderTooFastTime = RestaurantConfig.OrderTooFastTime
	self.OrderTooSlowTime = RestaurantConfig.OrderTooSlowTime
	self.cameraList = nil
	self.maxCameraIndex = 0
	self.curCameraIndex = 0
end

function M:OnDestroy()
	gMessageManager:SendMessage(gEventConstants.INTERACTION_ACTION_FINISH)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, true)

	gRestaurantManager.isOrdering = false

	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(false, LX6.PaoKu.TransitionMgr.ShowActionBanReason.RestaurantOrding)
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	gRestaurantManager:SwitchOrderState(gRestaurantManager.ORDER_STATE.TAKE_PHONE)

	self.gameplayHudPanelStore = gStoreManager:GetStoreGroup("GameplayHudPanelStore")

	self.gameplayHudPanelStore:RegisterBtnBackCallback(function ()
		self:OnClickBtnExit()
	end)
	self.gameplayHudPanelStore:RegisterBtnSwitchViewCallback(function ()
		self:OnClickBtnSwitchCamera()
	end)
	self.gameplayHudPanelStore:SetBtnSwitchViewState(true)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_GAMEPLAY_HUD_PANEL, false)

	gRestaurantManager.isOrdering = true

	gBlackScreenManager:CloseTransition(gBlackScreenId.DIALOG_CAMERA_TEMPLATE, 0)
	gBlackScreenManager:CloseTransition(gBlackScreenId.TIMELINE, 0)
	gCS.TransitionMgr.AddOrRemoveShowActionBanReason(true, LX6.PaoKu.TransitionMgr.ShowActionBanReason.RestaurantOrding)

	self.focusNpc = data.focusNpc
	self.mode = data.mode
	self.gameplayId = data.gameplayId
	self.cfg = gRestaurantManager:GetRestaurantCfg(self.gameplayId)

	if self.focusNpc then
		if C_RestaurantManager.ORDER_MODE.ALONE < self.mode then
			self.inviteNpcCfg = AgentConfig.GetConfig(self.focusNpc.TemplateId)
		end
	elseif self.mode ~= C_RestaurantManager.ORDER_MODE.ALONE then
		print_warn("RestaurantPanel focus npc is nil")
	end

	self:RefreshTaskInfo()

	self.bindData.moneyText = gPlayerManager.infoItem.bindData.money

	if self.cfg then
		self.bindData.img1 = self.cfg.OrderPanelImg1
		self.bindData.img2 = self.cfg.OrderPanelImg2
		self.bindData.restaurantNameText = self.cfg.RestaurantName
		self.OrderTooMuchCount = self.cfg.OrderTooMuchCount

		self:InitFoodMenu()
	else
		print_error("RestaurantPanel cfg is nil, gameplayId=", self.gameplayId)
	end

	if C_RestaurantManager.ORDER_MODE.ALONE < self.mode and gRestaurantManager:IsInviteNpc() then
		self.npcDailyCfg = gRestaurantManager:GetCurrentInviteNpcDailyCfg()
	end

	self.cameraList = gRestaurantManager:GetCameraConfigByIdList(data.cameraIdList)
	self.maxCameraIndex = #self.cameraList
	local playerUnit = gCS.MyPlayerManager.PlayerUnit

	if self.mode == C_RestaurantManager.ORDER_MODE.INVITE then
		local deltaPos = (self.focusNpc.LocalPosition - playerUnit.LocalPosition) / 2
		local targetPos = playerUnit.LocalPosition + playerUnit.LocalRotation * Vector3.New(0, 1.255, 0) + deltaPos

		gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(targetPos, 37, 2)
	elseif self.mode == C_RestaurantManager.ORDER_MODE.ALONE then
		local targetPos = playerUnit.LocalPosition + playerUnit.LocalRotation * Vector3.New(0, 1.255, -0.5)

		gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(targetPos, 36, 2)
	end

	gRestaurantManager.setFreeLook = true

	if self.mode == C_RestaurantManager.ORDER_MODE.DATE then
		self.bindData.isShowSwitchCamBtn = false

		if self.maxCameraIndex > 0 then
			self.bindData.openUICamera = true

			gUtils:SetFixCameraView(playerUnit, self.cameraList[1], self.bindData.UIvcam)
		else
			print_error("餐饮店约会任务没有传入正确的镜头id")
		end
	else
		self.bindData.isShowSwitchCamBtn = true
	end

	self.orderList = {}
	self.curOrderCount = 0
	self.totalCost = 0
	self.npcTreat = data.npcTreat
	self.bindData.needPayCtrl = self.npcTreat and 0 or 1

	self:RefreshOrderCountAndCost()
	self:RefreshBtnStyle()
end

function M:OnClose()
	return
end

function M:InitFoodMenu()
	self.menuList = {}

	for _, foodId in ipairs(self.cfg.Foodincluded) do
		local foodInfo = RestaurantFoodConfig.GetConfig(foodId)

		if foodInfo then
			local food = {
				order = false,
				cfgId = foodId,
				price = foodInfo.Price,
				foodName = foodInfo.Name,
				foodIconId = foodInfo.SImage,
				foodDesc = foodInfo.Intro,
				effectIconId = foodInfo.EffectIconSGUI,
				effectDesc = foodInfo.EffectIntro,
				showTemp = false,
				showRule = foodInfo.ShowRule,
				allowMultiSelect = true,
				arrayIndex = #self.menuList + 1
			}

			table.insert(self.menuList, food)
		else
			print_error("RestaurantFoodConfig 食物配表里没有对应的食物信息。foodId = " .. foodId .. ", gameplayId = " .. self.gameplayId, " 请找对应玩法的策划查配表")
		end
	end

	self.bindData.menuList:SetList(self.menuList)
end

function M:SetCameraFocusTarget(csUnit, mode)
	gRestaurantManager:SetRestaurantCameraView(csUnit, mode, self.cfg, self.bindData.UIvcam.gameObject)
	self.bindData.UIvcam.gameObject:SetActive(true)
end

function M:RefreshTaskInfo()
	self.targetOrderCount = 1
end

function M:RefreshBtnStyle()
	self.meetConditions = self.targetOrderCount <= self.curOrderCount
	self.bindData.btnCommit.interactable = self.meetConditions and (self.npcTreat or self.totalCost <= gPlayerManager.infoItem.bindData.money)
end

function M:CheckSpecialFoodOrder(foodId)
	local menuList = self:GetCurrentMenu()

	for idx, v in pairs(self.orderList) do
		if menuList[idx].cfgId == foodId then
			return true
		end
	end

	return false
end

function M:GetCurrentMenu()
	return self.menuList
end

function M:AddOrder(index)
	self.menuList[index].order = true

	if not self.orderList[index] then
		self.orderList[index] = true
		local menuList = self:GetCurrentMenu()
		self.totalCost = self.totalCost + menuList[index].price
		self.curOrderCount = self.curOrderCount + 1

		self:RefreshOrderCountAndCost()
		self:RefreshBtnStyle()
		self:CheckShowAtomsphereReaction(true, index)
	end
end

function M:RemoveOrder(index, refreshBtn, refreshDialog)
	self.menuList[index].order = false

	if self.orderList[index] then
		self.orderList[index] = nil
		local menuList = self:GetCurrentMenu()
		self.totalCost = self.totalCost - menuList[index].price
		self.curOrderCount = self.curOrderCount - 1

		self:RefreshOrderCountAndCost()

		if refreshBtn then
			self:RefreshBtnStyle()
		end

		if refreshDialog then
			self:CheckShowAtomsphereReaction(false, index)
		end
	end
end

function M:ClearAllOrder()
	if not self.orderList then
		return
	end

	for index, _ in pairs(self.orderList) do
		self:RemoveOrder(index)
	end
end

function M:RefreshOrderCountAndCost()
	self.bindData.totalCostText = self.totalCost
	self.bindData.moneyLackController = (self.npcTreat or self.totalCost <= gPlayerManager.infoItem.bindData.money) and 1 or 0
	self.bindData.shownumberCtrl = self.curOrderCount > 0 and 1 or 0
	self.bindData.foodCountText = self.curOrderCount
end

function M:SwitchTab(tabIndex)
	if tabIndex == 0 then
		self.bindData.menuList:SetList(self.menuList)

		self.bindData.showBtnBackCtrl = 0
	else
		self:RefreshFoodDetailTab()

		self.bindData.showBtnBackCtrl = 1
	end

	self.bindData.tabCtrl = tabIndex
	self.curTabIndex = tabIndex
end

function M:RefreshFoodDetailTab()
	local food = self.menuList[self.curFoodDetailIndex]
	self.bindData.curFoodIconUrl = SguiImageConfig.GetConfig(food.foodIconId).ImgPath
	self.bindData.curFoodBuffIconUrl = SguiImageConfig.GetConfig(food.effectIconId).ImgPath
	self.bindData.curFoodNameText = food.foodName
	self.bindData.curFoodBuffText = food.effectDesc
	self.bindData.curFoodDescText = food.foodDesc
	self.bindData.curFoodPriceText = food.price
	self.bindData.curFoodBtnStateCtrl = food.order and 1 or 0
end

function M:CheckShowAtomsphereReaction(isAdd, index)
	if C_RestaurantManager.ORDER_MODE.ALONE < self.mode and self.npcDailyCfg and self.OrderTextCD < Time.time - self.lastAtomsphereDialogTime then
		local reactions = {}

		if isAdd then
			if self.lastAddTime > 0 then
				if self.OrderTooSlowTime <= Time.time - self.lastAddTime and self.npcDailyCfg.OrderTooSlow.dialogid then
					table.insert(reactions, self.npcDailyCfg.OrderTooSlow)
				end

				if Time.time - self.lastAddTime <= self.OrderTooFastTime and self.npcDailyCfg.OrderTooFast.dialogid then
					table.insert(reactions, self.npcDailyCfg.OrderTooFast)
				end
			end

			if self.OrderTooMuchCount <= self.curOrderCount and self.npcDailyCfg.OrderTooMuch.dialogid then
				table.insert(reactions, self.npcDailyCfg.OrderTooMuch)
			end

			local menuList = self:GetCurrentMenu()
			local foodId = menuList[index].cfgId

			for i = 1, #self.npcDailyCfg.OrderSpecial do
				if foodId == self.npcDailyCfg.OrderSpecial[i].foodid and self.npcDailyCfg.OrderSpecial[i].dialogid then
					table.insert(reactions, self.npcDailyCfg.OrderSpecial[i])
				end
			end

			for i = 1, #self.npcDailyCfg.OrderSpecialSet do
				local OrderSpecialSet = self.npcDailyCfg.OrderSpecialSet[i]

				if foodId == OrderSpecialSet.foodid1 and self:CheckSpecialFoodOrder(OrderSpecialSet.foodid2) and OrderSpecialSet.dialogid then
					table.insert(reactions, OrderSpecialSet)
				end
			end

			for i = 1, #self.npcDailyCfg.OrderSpecialSet do
				local OrderSpecialSet = self.npcDailyCfg.OrderSpecialSet[i]

				if foodId == OrderSpecialSet.foodid2 and self:CheckSpecialFoodOrder(OrderSpecialSet.foodid1) and OrderSpecialSet.dialogid then
					table.insert(reactions, OrderSpecialSet)
				end
			end
		elseif self.npcDailyCfg.OrderCancel.dialogid then
			table.insert(reactions, self.npcDailyCfg.OrderCancel)
		end

		if #reactions > 0 then
			self.lastAtomsphereDialogTime = Time.time
			local reaction = reactions[Mathf.Random(#reactions)]

			if reaction.actionid ~= 0 then
				gRestaurantManager:PlaySingleAction(self.focusNpc, reaction.actionid, nil, 0, 0.5)
			end

			if self.focusNpc and reaction.expressionid ~= 0 then
				if self.focusNpc.ModelSlot.ExpressionController then
					self.focusNpc.ModelSlot.ExpressionController:PlaySpecialExpression(reaction.expressionid, 0, true, 0)
				else
					print_warn("RestaurantPanel => Npc Play Expression Failed, ExpressionController is Nil (模型未配置表情组件).", self.focusNpc.NpcId, self.focusNpc.Pid)
				end
			end

			if reaction.dialogid and reaction.dialogid > 0 then
				gDialogManager:ShowGeneralDialog(reaction.dialogid, gDialogSource.Restaurant)
			end
		end
	end

	if isAdd then
		self.lastAddTime = Time.time
	end
end

function M:OnRenderMenuItem(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		store.foodNameText = data.foodName
		store.foodPriceText = data.price
		store.foodIconUrl = SguiImageConfig.GetConfig(data.foodIconId).ImgPath
		store.foodBuffIconUrl = SguiImageConfig.GetConfig(data.effectIconId).ImgPath
		store.foodBuffText = data.effectDesc
		store.btn.luaClick = self:CreateActionWithArgs("OnClickMenuItemBtn", {
			index = data.arrayIndex,
			id = id
		})
		store.btnStateCtrl = data.order and 1 or 0

		if self.cfg then
			store.color = self.cfg.OrderPanelColor1
		end
	end
end

function M:OnClickMenuItem(btn, data)
	local store = self:GetStoreById(btn.gameObject:GetInstanceID())

	if store then
		self.curFoodDetailIndex = data.arrayIndex

		self:SwitchTab(1)
	end
end

function M:OnClickMenuItemBtn(data)
	local store = self:GetStoreById(data.id)

	if store then
		local food = self.menuList[data.index]

		if food.order then
			self:RemoveOrder(data.index, true, true)
		else
			self:AddOrder(data.index)
		end

		store.btnStateCtrl = food.order and 1 or 0
	end
end

function M:OnClickBtnSwitchCamera()
	self.curCameraIndex = self.curCameraIndex + 1

	if self.maxCameraIndex < self.curCameraIndex then
		self.bindData.UIvcam.gameObject:SetActive(false)

		self.curCameraIndex = 0
	else
		if self.curCameraIndex == 1 then
			self.bindData.UIvcam.gameObject:SetActive(true)
		end

		local cfg = self.cameraList[self.curCameraIndex]

		gUtils:SetCameraView(gCS.MyPlayerManager.PlayerUnit, cfg, self.bindData.UIvcam.gameObject)
	end
end

function M:OnClickBtnBack()
	self:SwitchTab(0)
end

function M:OnClickBtnCommit()
	if not self.meetConditions then
		if self.mode == C_RestaurantManager.ORDER_MODE.DATE then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OrderFoodFailed)
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.OrderFoodSubmitCheck)
		end

		return
	end

	if not self.npcTreat and gPlayerManager.infoItem.bindData.money < self.totalCost then
		gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)

		return
	end

	local buyFoodInfo = {
		RestaurantId = self.cfg.Id,
		FoodIdList = {}
	}
	local menuList = self:GetCurrentMenu()

	for idx, v in pairs(self.orderList) do
		table.insert(buyFoodInfo.FoodIdList, menuList[idx].cfgId)
	end

	if C_RestaurantManager.ORDER_MODE.ALONE < self.mode and self.inviteNpcCfg then
		buyFoodInfo.CompanionNpcId = gRestaurantManager:GetInviteCultivationId()

		if self.mode == C_RestaurantManager.ORDER_MODE.DATE then
			buyFoodInfo.Date = true
			buyFoodInfo.NPCTreat = self.npcTreat
		end
	end

	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)
	gRestaurantManager:EndRestaurantOrder(buyFoodInfo, self.mode)
end

function M:OnClickBtnDetailCommit()
	local food = self.menuList[self.curFoodDetailIndex]

	if food.order then
		self:RemoveOrder(self.curFoodDetailIndex, true, true)
	else
		self:AddOrder(self.curFoodDetailIndex)
	end

	self.bindData.curFoodBtnStateCtrl = food.order and 1 or 0
end

function M:OnClickBtnExit()
	gRestaurantManager:ExitRestaurantOrder(true)
end
