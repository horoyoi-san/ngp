C_RobberyBoardPanelStore = DefClass("C_RobberyBoardPanelStore", C_RobberyBoardPanelStore, C_StoreGroup)
GroupName2Class.RobberyBoardPanelStore = C_RobberyBoardPanelStore
local M = C_RobberyBoardPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.leaveButton.luaClick = self:CreateAction("OnLeaveClick")
	self.bindData.selectButton.luaClick = self:CreateAction("OnSelectClick")
	self.bindData.confirmButton.luaClick = self:CreateAction("OnConfirmClick")
	self.bindData.startButton.luaClick = self:CreateAction("OnStartClick")
	self.bindData.wButton.luaClick = self:CreateAction("wButtonClick")
	self.bindData.aButton.luaClick = self:CreateAction("aButtonClick")
	self.bindData.sButton.luaClick = self:CreateAction("sButtonClick")
	self.bindData.dButton.luaClick = self:CreateAction("dButtonClick")

	gPanelManager:CheckShowInBackground(gPanelId.BACK_BTN_PANEL)
	self:InitMessages()
end

function M:InitMessages()
	self:RegisterMessageEvents({
		[gEventConstants.ON_ROBBERY_BOARD_ENTER_INTERACTION] = self:CreateAction("OnEnterInteraction"),
		[gEventConstants.ON_ROBBERY_BOARD_EXIT_INTERACTION] = self:CreateAction("OnExitInteraction"),
		[gEventConstants.ON_PLANNING_BOARD_INFO_CHANGE] = self:CreateAction("OnPlanningBoardInfoChange"),
		[gEventConstants.TASK_STATE_CHANGED] = self:CreateAction("OnTaskStateChange"),
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("OnExitInteraction"),
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("OnBeforeSwitchScene"),
		[gEventConstants.ON_ROBBERY_INTERACT_STATE_CHANGE] = self:CreateAction("OnInteractStateChange"),
		[gEventConstants.ON_COMPUTER_PANEL_EXIT_BUTTON_STATE_CHANGE] = self:CreateAction("OnExitStateChange"),
		[gEventConstants.ON_ROBBERY_STEP_SELECTED] = self:CreateAction("OnSelectedStep")
	})
end

function M:OnShow(_, args)
	self:InitModel(args)
	self:InitView(args)
end

function M:InitModel(args)
	self.id = args.id
	self.STEP_TYPE = {
		TASK = 1,
		CHOICE = 2
	}
	self.ARROW_SHOW_TYPE_CONTROL = {
		RIGHT = 2,
		NONE = 3,
		LEFT = 0,
		BOTH = 1
	}
	self.BUTTON_SHOW_TYPE_CONTROL = {
		TASK_SELECTED = 3,
		CHOICE_SELECTED = 2,
		CHOICE_UNSELECTED = 1,
		NONE = 0
	}
	self.buttonStoreMap = {}
end

function M:InitView(args)
	self:InitButtons()
	self:InitPosition(args.uiPivot)

	self.bindData.showButtonTypeControl = self.BUTTON_SHOW_TYPE_CONTROL.NONE

	self:RefreshPanelView()
	self.rootGo.transform:ChangeLayersRecursively(Layer.Default)
end

function M:InitPosition(uiPivot)
	if gClientUtils.IsNil(uiPivot) then
		return
	end

	self.rootGo.transform.position = uiPivot.position
	self.rootGo.transform.rotation = uiPivot.rotation
	self.rootGo.transform.localScale = uiPivot.localScale
end

function M:GetInitNavigationStepId()
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep
	local targetStepId = stepIdList[1]

	for _, stepId in ipairs(stepIdList) do
		if not self:CheckStepHasCompleted(stepId) then
			targetStepId = stepId

			break
		end
	end

	return targetStepId
end

function M:RefreshPanelView()
	self:RefreshStepOptionCostMoneyView()

	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep

	for _, stepId in ipairs(stepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

		if stepCfg.StepType == self.STEP_TYPE.TASK then
			self:RefreshTaskItemView(stepId)
		elseif stepCfg.StepType == self.STEP_TYPE.CHOICE then
			self:RefreshResourceItemView(stepId)
		end
	end

	local nextHasUnlocked = self:CheckNextHasUnlocked()
	self.bindData.taskUnlockControl = nextHasUnlocked and 1 or 0

	if nextHasUnlocked then
		self.navigationMap = {
			{
				stepIdList[1]
			},
			{
				stepIdList[2],
				stepIdList[3]
			},
			{
				stepIdList[4],
				stepIdList[5]
			},
			{
				stepIdList[6]
			}
		}
	else
		self.navigationMap = {
			{
				stepIdList[1]
			},
			{
				stepIdList[2],
				stepIdList[3]
			}
		}
	end
end

function M:RefreshStepOptionCostMoneyView()
	local optionStepIdList = self:GetOptionStepIdList()
	local costMoney = 0

	for _, stepId in ipairs(optionStepIdList) do
		if not self:CheckStepHasCompleted(stepId) then
			local store = self.buttonStoreMap[stepId]
			local stepDetailCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
			local optionIdList = stepDetailCfg.OptionIds
			local optionId = optionIdList[store.selectedIndex or 1]
			local optionCfg = LTConfig.PlanningBoardOptionConfig.GetConfig(optionId)
			costMoney = costMoney + optionCfg.Cost
		end
	end

	self.bindData.money = ("-%d"):format(costMoney)

	self.bindData.moneyNode:SetActive(costMoney > 0)
end

function M:CheckNextHasUnlocked()
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep
	local preStepIdList = {
		stepIdList[2],
		stepIdList[3]
	}

	for _, stepId in ipairs(preStepIdList) do
		if not self:CheckStepHasCompleted(stepId) then
			return false
		end
	end

	return true
end

function M:InitButtons()
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep

	for index, stepId in ipairs(stepIdList) do
		local bindName = ("step%d"):format(index)
		local button = self.bindData[bindName]

		function button.luaClick()
			self:OnStepButtonClick(stepId, true)
		end

		button.luaHover = self:CreateActionWithArgs("OnStepButtonHover", stepId)
		button.luaFocus = self:CreateActionWithArgs("OnStepButtonHover", stepId)
		local store = gStoreManager:GetStoreGroup(button.Store):GetStoreByWidget(button)
		store.stepId = stepId
		store.selectedIndex = self:GetStepSelectedIndex(stepId)
		self.buttonStoreMap[stepId] = store
	end
end

function M:OnStepButtonHover(stepId)
	self:ResetAllHoverStatus()

	local store = self.buttonStoreMap[stepId]
	store.hoverControl = 1
	self.currentHoverStepId = stepId
end

function M:OnStepButtonClick(stepId, isFromItemClick, isForce)
	if not self:CheckCanClick() and not isForce then
		return
	end

	self:ResetAllButtonSelectStatus()

	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

	if stepCfg.StepType == self.STEP_TYPE.CHOICE then
		self:OnResourceItemClick(stepId, isFromItemClick)
	else
		self:OnTaskItemClick(stepId)
	end

	local stepIndex = self:GetPlanningBoardStepIndex(stepId)
	local signalKey = ("RobberyStepHover%d"):format(stepIndex)

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = signalKey
	})
	print_debug(signalKey)
end

function M:CheckCanClick()
	if self.needCheckCdTime then
		if self.isClickCdIng then
			return false
		end

		self:StartIsClickCdIng()
	end

	return true
end

function M:StartIsClickCdIng()
	self.isClickCdIng = true

	LX6.Manager.GameInputManager.SetDisableInput(self.m_Id, true, true, false)

	self.clickCdCo = coroutine.stop(self.clickCdCo)
	self.clickCdCo = coroutine.start(function ()
		coroutine.wait(1)

		self.isClickCdIng = false

		LX6.Manager.GameInputManager.SetEnableInput(self.m_Id, true, true, true)
	end)
end

function M:OnResourceItemClick(stepId, isFromItemClick)
	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local optionId = stepCfg.OptionIds[store.selectedIndex]

	if self.bindData.showButtonTypeControl == self.BUTTON_SHOW_TYPE_CONTROL.CHOICE_SELECTED then
		if isFromItemClick then
			return
		end

		local optionHasUnlocked = self:CheckOptionHasUnlocked(optionId)

		if not optionHasUnlocked then
			return
		end

		local optionCfg = LTConfig.PlanningBoardOptionConfig.GetConfig(optionId)

		local function executeOption()
			local selectedIndex = store.selectedIndex
			local csIndex = selectedIndex - 1

			gClientToGameDelegate:AskPlanningBoardSelectStepOption(stepId, csIndex).Callback = function (errorId)
				if errorId ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(errorId)

					return
				end

				self:SetOptionSelected(stepId, selectedIndex)

				self.bindData.showButtonTypeControl = self.BUTTON_SHOW_TYPE_CONTROL.NONE

				self:RefreshPanelView()
				self:CheckAllStepOptionHasCompleted()
			end
		end

		if optionCfg.Cost > 0 then
			if gPlayerManager.infoItem.bindData.money < optionCfg.Cost then
				gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.ShopCommodityBuyNotEnoughMoney)
			else
				gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.MoneyCostConfirm, function ()
					executeOption()
				end, nil, optionCfg.Cost, optionCfg.Desc)
			end
		else
			executeOption()
		end

		return
	end

	local stepButton = store.button

	self:ResetAllButtonSelectStatus()

	stepButton.isSelected = true

	if self:CheckOptionHasSelected(stepId) then
		return
	end

	local stepHasCompleted = self:CheckStepHasCompleted(stepId)
	self.bindData.showButtonTypeControl = stepHasCompleted and self.BUTTON_SHOW_TYPE_CONTROL.NONE or self.BUTTON_SHOW_TYPE_CONTROL.CHOICE_SELECTED

	self:RefreshResourceItemView(stepId)
end

function M:CheckAllStepOptionHasCompleted()
	local optionStepIdList = self:GetOptionStepIdList()
	local allStepOptionHasCompleted = true

	for _, stepId in ipairs(optionStepIdList) do
		if not self:CheckStepHasCompleted(stepId) then
			allStepOptionHasCompleted = false

			break
		end
	end

	if allStepOptionHasCompleted then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "RobberyAllStepOptionHasCompleted"
		})
	end
end

function M:GetOptionStepIdList()
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep
	local optionStepIdList = {}

	for _, stepId in ipairs(stepIdList) do
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

		if stepCfg.StepType == self.STEP_TYPE.CHOICE then
			table.insert(optionStepIdList, stepId)
		end
	end

	return optionStepIdList
end

function M:OnTaskItemClick(stepId)
	local store = self.buttonStoreMap[stepId]
	local stepButton = store.button

	if stepButton.isSelected then
		return
	end

	self:ResetAllButtonSelectStatus()

	stepButton.isSelected = true
end

function M:ResetAllHoverStatus()
	for _, store in pairs(self.buttonStoreMap) do
		store.hoverControl = 0
	end
end

function M:ResetAllButtonSelectStatus()
	for _, store in pairs(self.buttonStoreMap) do
		store.button.isSelected = false
		store.buttonShowTypeControl = self.ARROW_SHOW_TYPE_CONTROL.NONE
	end

	self.bindData.showButtonTypeControl = self.BUTTON_SHOW_TYPE_CONTROL.NONE
end

function M:RefreshTaskItemView(stepId)
	local store = self.buttonStoreMap[stepId]
	local stepDetailCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskEventId = stepDetailCfg.TaskId
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(taskEventId)
	store.title = stepDetailCfg.MethodTitle
	store.description = stepDetailCfg.Describe
	local playerRoleId = taskEventCfg.PlayRoles and taskEventCfg.PlayRoles[1]
	local roleCfg = LTConfig.TaskRoleConfig.GetConfig(playerRoleId)
	store.name = roleCfg and roleCfg.Name or ""
	store.iconId = taskEventCfg.SMapPhoto
	local stateControl = 0
	local hasUnlocked = self:CheckStepHasUnlocked(stepId)

	if hasUnlocked then
		if self:CheckStepHasCompleted(stepId) then
			stateControl = 2
		else
			stateControl = 1
		end
	else
		stateControl = 0
	end

	store.stateControl = stateControl
end

function M:CheckStepHasCompleted(stepId)
	if self:CheckStepHasUnlocked(stepId) then
		local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)

		if stepCfg.StepType == self.STEP_TYPE.TASK then
			local taskEventId = stepCfg.TaskId

			return gTaskManager:GetTaskEventState(taskEventId) == UX.Game.TaskEventState.Submited
		elseif stepCfg.StepType == self.STEP_TYPE.CHOICE then
			return self:CheckOptionHasSelected(stepId)
		end
	end
end

function M:CheckStepHasUnlocked(stepId)
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local preStepIdList = stepCfg.PreStep

	if #preStepIdList == 0 then
		if stepCfg.StepType == self.STEP_TYPE.TASK then
			local taskEventId = stepCfg.TaskId

			return gTaskManager:GetTaskEventState(taskEventId) ~= UX.Game.TaskEventState.Locked
		elseif stepCfg.StepType == self.STEP_TYPE.CHOICE then
			return true
		end
	else
		for _, preStep in ipairs(preStepIdList) do
			if not self:CheckStepHasCompleted(preStep) then
				return false
			end
		end

		return true
	end
end

function M:RefreshResourceItemView(stepId)
	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	store.title = stepCfg.MethodTitle
	local hasUnlocked = self:CheckStepHasUnlocked(stepId)
	store.hasUnlockedControl = hasUnlocked and 1 or 0
	local hasSelectedOption = self:CheckOptionHasSelected(stepId)
	store.hasChooseControl = hasSelectedOption and 1 or 0

	store.noChooseNode:SetActive(not hasSelectedOption)

	store.itemTypeControl = 0
	store.selectedIndex = store.selectedIndex or 1
	local optionId = stepCfg.OptionIds[store.selectedIndex]
	local optionCfg = LTConfig.PlanningBoardOptionConfig.GetConfig(optionId)
	store.description = optionCfg.Desc
	store.iconId = optionCfg.Pic
	store.typeControl = optionCfg.ImageControl

	self:RefreshResourceOptionItemView({
		step = 0,
		stepId = stepId
	})

	store.leftButton.luaClick = self:CreateActionWithArgs("RefreshResourceOptionItemView", {
		step = -1,
		stepId = stepId
	})
	store.switchButton.luaClick = self:CreateActionWithArgs("RefreshResourceOptionItemView", {
		step = -1,
		stepId = stepId
	})
	store.rightButton.luaClick = self:CreateActionWithArgs("RefreshResourceOptionItemView", {
		step = 1,
		stepId = stepId
	})
	store.confirmButton.luaClick = self:CreateActionWithArgs("OnResourceItemClick", stepId)
	store.costControl = hasSelectedOption and 1 or 0
end

function M:GetResourceItemShowType(stepId)
	if self:CheckStepHasCompleted(stepId) then
		return self.ARROW_SHOW_TYPE_CONTROL.NONE
	end

	if not self:CheckStepHasUnlocked(stepId) then
		return self.ARROW_SHOW_TYPE_CONTROL.NONE
	end

	local store = self.buttonStoreMap[stepId]

	if not store.button.isSelected then
		return self.ARROW_SHOW_TYPE_CONTROL.NONE
	end

	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local choiceCount = #stepCfg.OptionIds

	if choiceCount <= 1 then
		return self.ARROW_SHOW_TYPE_CONTROL.NONE
	end

	local selectedIndex = store.selectedIndex

	if selectedIndex <= 1 then
		return self.ARROW_SHOW_TYPE_CONTROL.RIGHT
	elseif choiceCount <= selectedIndex then
		return self.ARROW_SHOW_TYPE_CONTROL.LEFT
	end

	return self.ARROW_SHOW_TYPE_CONTROL.BOTH
end

function M:GetPlanningBoardStepIndex(stepId)
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep
	local _, stepIndex = table.find(stepIdList, stepId)

	return stepIndex
end

function M:RefreshResourceOptionItemView(args)
	local stepId = args.stepId
	local step = args.step
	local store = self.buttonStoreMap[stepId]
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local targetIndex = store.selectedIndex + step

	if targetIndex < 1 or targetIndex > #stepCfg.OptionIds then
		return
	end

	store.selectedIndex = store.selectedIndex + step
	local currentOptionId = stepCfg.OptionIds[store.selectedIndex]
	local optionCfg = LTConfig.PlanningBoardOptionConfig.GetConfig(currentOptionId)
	store.description = optionCfg.Desc
	store.iconId = optionCfg.Pic
	local currentOptionHasUnlocked = self:CheckOptionHasUnlocked(currentOptionId)

	if store.button.isSelected then
		store.optionHasUnlockedControl = currentOptionHasUnlocked and 1 or 0
		local stepIndex = self:GetPlanningBoardStepIndex(stepId)
		local signalKey = ("RobberyStepOption%d_%d"):format(stepIndex, store.selectedIndex)

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = signalKey
		})
		print_debug(signalKey)
	else
		store.optionHasUnlockedControl = 1
	end

	self.bindData.confirmButton.interactable = currentOptionHasUnlocked
	store.buttonShowTypeControl = self:GetResourceItemShowType(stepId)
	local textCommonTextId = optionCfg.Intro
	store.effect = LTConfig.TextCommonTextConfig.GetConfig(textCommonTextId).Text
	store.money = optionCfg.Cost

	self:RefreshStepOptionCostMoneyView()
end

function M:CheckOptionHasUnlocked(optionId)
	local optionCfg = LTConfig.PlanningBoardOptionConfig.GetConfig(optionId)

	return gEventConditionUtils.CheckHasUnlocked(optionCfg, UX.Game.EventConditionImplModule.PlanningBoardOption)
end

function M:OnStartClick()
	local stepId = self.currentHoverStepId
	local stepCfg = LTConfig.PlanningBoardStepDetailConfig.GetConfig(stepId)
	local taskEventId = stepCfg.TaskId
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(taskEventId)
	local taskId = taskEventCfg and taskEventCfg.StartTask
	local rootGo = self.rootGo

	gClientToGameDelegate:AskAcceptTask(taskId).Callback = function (errorId)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		if gClientUtils.NotNil(rootGo) then
			self.bindData.showButtonTypeControl = self.BUTTON_SHOW_TYPE_CONTROL.TASK_SELECTED

			self:RefreshPanelView()
			self:OnLeaveClick()
		end
	end
end

function M:OnConfirmClick()
	local stepId = self:GetCurrentSelectedStepId()

	self:OnResourceItemClick(stepId)
end

function M:NavigationToTargetStep(targetStepId, isForce)
	self:ResetAllButtonSelectStatus()
	self:OnStepButtonHover(targetStepId)
	self:OnStepButtonClick(targetStepId, nil, isForce)
end

function M:wButtonClick()
	local navIndex, currentSelectedStepId = self:GetNavigationIndex()

	if navIndex then
		local navStepIdList = self.navigationMap[navIndex]
		local _, currentNavIndex = table.find(navStepIdList, currentSelectedStepId)

		if navStepIdList[currentNavIndex - 1] then
			local targetStepId = navStepIdList[currentNavIndex - 1]

			self:NavigationToTargetStep(targetStepId)
		end
	end
end

function M:aButtonClick()
	local navIndex, _ = self:GetNavigationIndex()

	if navIndex and self.navigationMap[navIndex - 1] then
		local targetStepId = self.navigationMap[navIndex - 1][1]

		self:NavigationToTargetStep(targetStepId)
	end
end

function M:sButtonClick()
	local navIndex, currentSelectedStepId = self:GetNavigationIndex()

	if navIndex then
		local navStepIdList = self.navigationMap[navIndex]
		local _, currentNavIndex = table.find(navStepIdList, currentSelectedStepId)

		if navStepIdList[currentNavIndex + 1] then
			local targetStepId = navStepIdList[currentNavIndex + 1]

			self:NavigationToTargetStep(targetStepId)
		end
	end
end

function M:dButtonClick()
	local navIndex, _ = self:GetNavigationIndex()

	if navIndex and navIndex and self.navigationMap[navIndex + 1] then
		local targetStepId = self.navigationMap[navIndex + 1][1]

		self:NavigationToTargetStep(targetStepId)
	end
end

function M:GetNavigationIndex()
	local navIndex = nil
	local currentSelectedStepId = self:GetCurrentSelectedStepId()

	for index, navStepIdList in ipairs(self.navigationMap) do
		for _, stepId in ipairs(navStepIdList) do
			if currentSelectedStepId == stepId then
				navIndex = index

				break
			end
		end
	end

	return navIndex, currentSelectedStepId
end

function M:GetCurrentSelectedStepId()
	local currentSelectedStepId = nil

	for stepId, store in pairs(self.buttonStoreMap) do
		if store.button.isSelected then
			currentSelectedStepId = stepId

			break
		end
	end

	return currentSelectedStepId
end

function M:OnSelectClick()
	local stepId = self:GetCurrentSelectedStepId()

	self:OnStepButtonClick(stepId)
end

function M:OnLeaveClick()
	self:OnExitInteraction()
end

function M:OnExitInteraction()
	if gClientUtils.NotNil(self.rootGo) and self.isEnterInteraction then
		self.isEnterInteraction = nil

		self.rootGo.transform:ChangeLayersRecursively(Layer.Default)
		self:ResetAllButtonSelectStatus()
		self:ResetAllHoverStatus()

		self.bindData.uNavigationArea.enabled = false

		gPanelManager:SetActiveById(self.m_Id, false)
		gPanelManager:SetActiveById(gPanelId.BACK_BTN_PANEL, false)

		self.bindData.showButtonControl = 0

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = ("BoardExit:%d"):format(self.id)
		})
	end

	self:ResetCdTime()
end

function M:OnEnterInteraction(_, _)
	self.isEnterInteraction = true

	gPanelManager:SetActiveById(self.m_Id, true)
	gPanelManager:SetActiveById(gPanelId.BACK_BTN_PANEL, true)

	self.bindData.uNavigationArea.enabled = true
	self.bindData.showButtonControl = 1
	local stepId = self:GetInitNavigationStepId()

	self:NavigationToTargetStep(stepId)

	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.uNavigationArea
	SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.buttonStoreMap[stepId].button

	self.rootGo.transform:ChangeLayersRecursively(Layer.WorldUI_)

	SGUI.UNavigationMgr.Inst.gameBarsNeedRefresh = true
end

function M:SetOptionSelected(stepId, optionIndex)
	local csIndex = optionIndex - 1
	gPlayerManager.infoMinor.bindData.planningBoardInfo.StepId2OptionIndexDict[stepId] = csIndex
end

function M:GetStepSelectedIndex(stepId)
	local index = gPlayerManager.infoMinor.bindData.planningBoardInfo.StepId2OptionIndexDict[stepId]

	if index then
		local luaIndex = index + 1

		return luaIndex
	end
end

function M:OnPlanningBoardInfoChange()
	for _, store in pairs(self.buttonStoreMap) do
		store.selectedIndex = nil
	end

	self.bindData.showButtonTypeControl = self.BUTTON_SHOW_TYPE_CONTROL.NONE

	self:OnStepButtonHover(self.currentHoverStepId)
	self:RefreshPanelView()
end

function M:CheckOptionHasSelected(stepId)
	return gPlayerManager.infoMinor.bindData.planningBoardInfo.StepId2OptionIndexDict[stepId] ~= nil
end

function M:OnTaskStateChange()
	self.refreshPanelViewCo = coroutine.stop(self.refreshPanelViewCo)
	self.refreshPanelViewCo = coroutine.start(function ()
		coroutine.step()

		if gClientUtils.NotNil(self.rootGo) then
			self:RefreshPanelView()
		end
	end)
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType ~= gSwitchSceneType.Reconnect then
		self:OnExitInteraction()
	end
end

function M:OnInteractStateChange(_, forbidInteract)
	self.needCheckCdTime = true

	if forbidInteract then
		self:ResetAllButtonSelectStatus()
	end

	self.bindData.uNavigationArea.enabled = not forbidInteract

	self.bindData.fullScreenMask:SetActive(forbidInteract)
	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, forbidInteract)
end

function M:OnExitStateChange(_, showExitButton)
	self.bindData.exitNode:SetActive(showExitButton)
end

function M:OnSelectedStep(_, stepIndex)
	stepIndex = tonumber(stepIndex)
	local boardCfg = LTConfig.PlanningBoardConfig.GetConfig(self.id)
	local stepIdList = boardCfg.AllStep
	local stepId = stepIdList[stepIndex]

	if self:GetCurrentSelectedStepId() ~= stepId then
		self:NavigationToTargetStep(stepId, true)
	end
end

function M:ResetCdTime()
	LX6.Manager.GameInputManager.SetEnableInput(self.m_Id, true, true, true)

	self.clickCdCo = coroutine.stop(self.clickCdCo)
	self.isClickCdIng = nil
	self.needCheckCdTime = nil
end

function M:OnDestroy()
	gPanelManager:Close(gPanelId.BACK_BTN_PANEL)

	self.needCheckCdTime = nil

	gCS.GuiUtils.SetPanelHideCursor(self.m_Id, false)

	self.refreshPanelViewCo = coroutine.stop(self.refreshPanelViewCo)
	self.isEnterInteraction = nil

	self:OnExitInteraction()
	self:ClearMessageEvents()

	self.forbidInteract = nil
end
