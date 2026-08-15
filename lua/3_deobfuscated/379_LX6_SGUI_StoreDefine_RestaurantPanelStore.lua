local RestaurantConfig = LTConfig.RestaurantConfig
local RestaurantFoodConfig = LTConfig.RestaurantFoodConfig
local MessageConfig = LTConfig.MessageConfig
local MoneyType = UX.Game.MoneyType
local SguiImageConfig = LTConfig.SguiImageConfig
local AgentConfig = LTConfig.AgentConfig
C_RestaurantPanelStore = DefClass("C_RestaurantPanelStore", C_RestaurantPanelStore, C_StoreGroup)
GroupName2Class.RestaurantPanelStore = C_RestaurantPanelStore
local RestaurantPanelStore = C_RestaurantPanelStore

function RestaurantPanelStore:OnAwake()
	self.bindData.menuList.luaSimpleRenderItem = self:CreateAction("OnRenderMenuItem")
	self.bindData.menuList.luaSimpleClick = self:CreateAction("OnMenuItemClick")
	self.bindData.btnBack.luaClick = self:CreateAction("ClosePanel")
	self.bindData.btnCommit.luaClick = self:CreateAction("SubmitOrder")
	self.OrderTextTime = RestaurantConfig.OrderTextTime
	self.OrderTextCD = RestaurantConfig.OrderTextCD
	self.OrderTooFastTime = RestaurantConfig.OrderTooFastTime
	self.OrderTooSlowTime = RestaurantConfig.OrderTooSlowTime
	self.curSelectItemIndex = -1
	self.orderList = nil
	self.totalCost = 0
	self.taskCountCur = 0
	self.taskTotalCount = 0
	self.lastAddTime = -1
	self.lastAtomsphereDialogTime = -5
	self.meetConditions = false
end

function RestaurantPanelStore:OnShow(panelId, data)
	gRestaurantManager.isOrdering = true
	self.focusNpc = data.focusNpc
	self.mode = data.mode
	self.gameplayId = data.gameplayId
	self.cfg = gRestaurantManager:GetRestaurantCfg(self.gameplayId)

	if self.focusNpc then
		self:SetCameraFocusTarget(self.focusNpc, self.mode)

		if C_RestaurantManager.ORDER_MODE.ALONE < self.mode then
			self.inviteNpcCfg = AgentConfig.GetConfig(self.focusNpc.TemplateId)
		end
	else
		print_warn("RestaurantPanel focus npc is nil")
	end

	self:RefreshTaskInfo()

	if self.cfg then
		self.bindData.restaurantName = self.cfg.RestaurantName

		self:InitFoodMenu()

		self.OrderTooMuchCount = self.cfg.OrderTooMuchCount
	else
		print_error("RestaurantPanel cfg is nil, gameplayId=", self.gameplayId)
	end

	if C_RestaurantManager.ORDER_MODE.ALONE < self.mode and gRestaurantManager:IsInviteNpc() then
		self.npcDailyCfg = gRestaurantManager:GetCurrentInviteNpcDailyCfg()
	end

	LX6.Cinemachine.CameraPostProcessHandler.enableAutoDof = false
	self.orderList = {}
	self.totalCost = 0
	self.bindData.totalMoney = self.totalCost

	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.bindData.showToolTipCtrl = 0
end

function RestaurantPanelStore:OnClose()
	return
end

function RestaurantPanelStore:InitFoodMenu()
	self.menuList = {}

	for _, foodId in ipairs(self.cfg.Foodincluded) do
		local foodInfo = RestaurantFoodConfig.GetConfig(foodId)

		if foodInfo then
			local food = {
				cfgId = foodId,
				price = foodInfo.Price,
				foodName = foodInfo.Name,
				foodIconId = foodInfo.SImage,
				foodDesc = foodInfo.Intro,
				effectIconId = foodInfo.EffectIcon,
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

	self.bindData.menuList:SetSimpleList(#self.menuList)
end

function RestaurantPanelStore:SetCameraFocusTarget(csunit, mode)
	gRestaurantManager:SetRestaurantCameraView(csunit, mode, self.cfg, self.bindData.UIvcam.gameObject)
	self.bindData.UIvcam.gameObject:SetActive(true)
end

function RestaurantPanelStore:RefreshTaskInfo()
	self.taskCountCur = 0

	if self.mode == C_RestaurantManager.ORDER_MODE.ALONE then
		self.bindData.haveTaskCtrl = 0
		self.bindData.taskDesc = RestaurantConfig.DinnerAloneTaskText
		self.taskTotalCount = RestaurantConfig.DinnerAloneTaskCount
		self.bindData.countTotal = self.taskTotalCount
		self.bindData.countCur = self.taskCountCur
	elseif self.mode == C_RestaurantManager.ORDER_MODE.INVITE then
		if self.focusNpc then
			self.bindData.haveTaskCtrl = 1
			self.bindData.taskDesc = gString.Format(RestaurantConfig.DinnerInviteTaskText, self.inviteNpcCfg.Name)
			self.taskTotalCount = RestaurantConfig.DinnerInviteTaskCount
			self.bindData.countTotal = self.taskTotalCount
			self.bindData.countCur = self.taskCountCur
		end
	elseif self.mode == C_RestaurantManager.ORDER_MODE.DATE and self.focusNpc then
		self.bindData.haveTaskCtrl = 0
		self.bindData.taskDesc = gRestaurantManager.dateTaskDesc or ""
		self.taskTotalCount = gRestaurantManager.dateSpecialFoods and #gRestaurantManager.dateSpecialFoods or 0
		self.bindData.countTotal = self.taskTotalCount
		self.bindData.countCur = self.taskCountCur
	end

	self:RefreshBtnStyle()
end

function RestaurantPanelStore:RefreshBtnStyle()
	self.meetConditions = self.taskTotalCount <= self.taskCountCur

	if self.mode == C_RestaurantManager.ORDER_MODE.DATE and gRestaurantManager.dateSpecialFoods then
		for i = 1, #gRestaurantManager.dateSpecialFoods do
			self.meetConditions = self.meetConditions and self:CheckSpecialFoodOrder(gRestaurantManager.dateSpecialFoods[i])
		end
	end

	if self.meetConditions then
		self.bindData.curCountColor = Color.NewByStr("FFFFFF")
		self.bindData.commitBtnInteractable = true
	else
		self.bindData.curCountColor = Color.red
		self.bindData.commitBtnInteractable = false
	end
end

function RestaurantPanelStore:CheckSpecialFoodOrder(foodId)
	local menuList = self:GetCurrentMenu()

	for idx, v in pairs(self.orderList) do
		if menuList[idx].cfgId == foodId then
			return true
		end
	end

	return false
end

function RestaurantPanelStore:GetCurrentMenu()
	return self.menuList
end

function RestaurantPanelStore:OnRenderMenuItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)
	local data = self.menuList[index + 1]

	if store and data then
		store.foodName = data.foodName
		store.foodPrice = data.price
		store.iconId = data.foodIconId
		store.btnMinus.luaClick = self:CreateActionWithArgs("OnMinusClick", {
			index = data.arrayIndex,
			id = id
		})
		store.selectCtrl = 0
	end
end

function RestaurantPanelStore:OnMinusClick(data)
	local store = self:GetStoreById(data.id)

	if store then
		self:RemoveOrder(data.index, true, true)

		store.selectCtrl = 0
	end
end

function RestaurantPanelStore:ClosePanel()
	gRestaurantManager:SetReleaseTimer()
	gPanelManager:Close(gPanelId.S_RESTAURANT)
	gRestaurantManager:RevertRestaurantCameraView()
end

function RestaurantPanelStore:SubmitOrder()
	if self.meetConditions then
		if gPlayerManager.infoItem.bindData.money < self.totalCost then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MoneyNotEnough)
		else
			local buyFoodInfo = {
				RestaurantId = self.cfg.Id,
				FoodIdList = {}
			}
			local menuList = self:GetCurrentMenu()

			for idx, v in pairs(self.orderList) do
				table.insert(buyFoodInfo.FoodIdList, menuList[idx].cfgId)
			end

			if C_RestaurantManager.ORDER_MODE.ALONE < self.mode and self.inviteNpcCfg then
				buyFoodInfo.CompanionNpcId = gRestaurantManager.clientNpcCultivationId

				if self.mode == C_RestaurantManager.ORDER_MODE.DATE then
					buyFoodInfo.Date = true
				end
			end

			gClientToGameSceneDelegate:AskRestaurantBuyFoods(buyFoodInfo).Callback = function (errID)
				if errID == 0 then
					gPanelManager:Close(gPanelId.S_RESTAURANT)
					gRestaurantManager:RevertRestaurantCameraView()
				else
					print_warn("AskRestaurantBuyFoods failed, error =", gCS.Error.GetNameById(errID))

					return
				end
			end
		end
	elseif self.mode == C_RestaurantManager.ORDER_MODE.DATE then
		gDisplayMessageMgr:ShowMessage(MessageConfig.OrderFoodFailed)
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.OrderFoodSubmitCheck)
	end
end

function RestaurantPanelStore:OnMenuItemClick(btn, index)
	local data = self.menuList[index + 1]
	local store = self:GetStoreById(btn.gameObject:GetInstanceID())

	if store and data then
		store.selectCtrl = 1

		self:AddOrder(data.arrayIndex)

		self.curSelectItemIndex = data.arrayIndex

		self:RefreshToolTip()
	end
end

function RestaurantPanelStore:AddOrder(index)
	self.menuList[index].order = true

	if not self.orderList[index] then
		self.orderList[index] = true
		local menuList = self:GetCurrentMenu()
		self.totalCost = self.totalCost + menuList[index].price
		self.bindData.totalMoney = self.totalCost

		if gPlayerManager.infoItem.bindData.money < self.totalCost then
			self.bindData.moneyColorCtrl = 1
		end

		self.taskCountCur = self.taskCountCur + 1
		self.bindData.countCur = self.taskCountCur

		self:RefreshBtnStyle()
		self:CheckShowAtomsphereReaction(true, index)
	end
end

function RestaurantPanelStore:RemoveOrder(index, refreshBtn, refreshDialog)
	self.menuList[index].order = false

	if self.orderList[index] then
		self.orderList[index] = nil
		local menuList = self:GetCurrentMenu()
		self.totalCost = self.totalCost - menuList[index].price
		self.bindData.totalMoney = self.totalCost

		if self.totalCost <= gPlayerManager.infoItem.bindData.money then
			self.bindData.moneyColorCtrl = 0
		end

		self.taskCountCur = self.taskCountCur - 1
		self.bindData.countCur = self.taskCountCur

		if refreshBtn then
			self:RefreshBtnStyle()
		end

		if refreshDialog then
			self:CheckShowAtomsphereReaction(false, index)
		end
	end
end

function RestaurantPanelStore:ClearAllOrder()
	if not self.orderList then
		return
	end

	for index, _ in pairs(self.orderList) do
		self:RemoveOrder(index)
	end
end

function RestaurantPanelStore:RefreshToolTip()
	if self.curSelectItemIndex > 0 then
		self.bindData.showToolTipCtrl = 1
		local info = self:GetCurrentMenu()[self.curSelectItemIndex]
		self.bindData.tipEffectDesc = info.effectDesc
		self.bindData.tipFoodDesc = info.foodDesc
		self.bindData.tipFoodIcon = SguiImageConfig.GetConfig(info.foodIconId).ImgPath
		self.bindData.tipFoodName = info.foodName
	else
		self.bindData.showToolTipCtrl = 0
	end
end

function RestaurantPanelStore:CheckShowAtomsphereReaction(isAdd, index)
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

			if self.OrderTooMuchCount <= self.taskCountCur and self.npcDailyCfg.OrderTooMuch.dialogid then
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

			gDialogManager:ShowGeneralDialog(reaction.dialogid, gDialogSource.Restaurant)
		end
	end

	if isAdd then
		self.lastAddTime = Time.time
	end
end
