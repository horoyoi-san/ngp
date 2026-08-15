local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local MessageConfig = LTConfig.MessageConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local UXVector3 = UX.Game.UXVector3
C_ChangeDressPanelStore = DefClass("C_ChangeDressPanelStore", C_ChangeDressPanelStore, C_StoreGroup)
GroupName2Class.ChangeDressPanelStore = C_ChangeDressPanelStore
local M = C_ChangeDressPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.countFinish = false
	self.callBack = nil
	self.suitFashionItemList = nil
	self.itemListByPart = nil
	self.suitList = nil
	self.touchStart = false
	self.isShowProfessionEdit = false
	self.fashionType = 0
	self.isPanelFocus = true
end

function M:OnAwake()
	self:DefineAllVariables()
	gClientUtils.CloseMainPhonePanel()
	self:InitEnumData()
	self:InitList()

	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnSwitchBtnClick")
	self.bindData.hideBtn.luaClick = self:CreateAction("OnHideBtnClick")
	self.bindData.collectBtn.luaClick = self:CreateAction("OnCollectBtnClick")
	self.bindData.dyeBtn.luaClick = self:CreateAction("OnDyeBtnClick")
	self.bindData.adjustBtn.luaClick = self:CreateAction("OnAdjustBtnClick")
	self.bindData.refreshBtn.luaClick = self:CreateAction("OnRefreshBtnClick")
	self.bindData.undoBtn.luaClick = self:CreateAction("OnUnDoBtnClick")
	self.bindData.redoBtn.luaClick = self:CreateAction("OnReDoBtnClick")
	self.bindData.settingBtn.luaClick = self:CreateAction("OnSettingBtnClick")
	self.bindData.outFitPlanBtn.luaClick = self:CreateAction("OnOutFitPlanBtnClick")
	self.bindData.baikeBtn.luaClick = self:CreateAction("OnBaikeBtnClick")
	self.bindData.foldBtn.luaClick = self:CreateAction("OnFoldBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.baikeBtn2.luaClick = self:CreateAction("OnBaikeBtnClick")
		self.bindData.upSelectTabBtn.luaClick = self:CreateAction("OnUpSelectTab")
		self.bindData.downSelectTabBtn.luaClick = self:CreateAction("OnDownSelectTab")
		self.bindData.leftSelectTabBtn.luaClick = self:CreateAction("OnLeftSelectTab")
		self.bindData.rightSelectTabBtn.luaClick = self:CreateAction("OnRightSelectTab")
		InputActionBind.onLuaActiveDeviceChanged = self:CreateAction("OnActionDeviceChanged")
	end
end

function M:OnDisable()
	self.isPanelFocus = false
end

function M:OnEnable()
	self.isPanelFocus = true
end

function M:InitEnumData()
	self.GENDER = {
		MALE = 1,
		FEMALE = 2,
		UNKNOWN = 0
	}
	self.SELECTOR_SORT_TYPE = {
		GET_TIME = 2,
		QUALITY = 1
	}
	self.COLLECT_TYPE = {
		ALL = 0,
		NO_COLLECT = 2,
		HAS_COLLECT = 1
	}
	self.SELECT_TYPE = {
		FALSE = 0,
		TRUE = 1
	}
	self.OPEN_TYPE = {
		FASHION = 0,
		SUIT = 1
	}
	self.DYE_TYPE = {
		CAN_DYE = 1,
		HAS_DYE = 2,
		NONE = 0
	}
end

function M:OnDestroy()
	if self.callBack then
		self.callBack()
	end

	if self.fashionType == 0 then
		gDressManager:ClearCurrentPlayerSpirit(true)
		gDressManager:ClearSteps()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end

	self:DestroyItemData()

	InputActionBind.onLuaActiveDeviceChanged = nil
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
	gDressManager.SelectType.collect = {}
	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}
	gDressManager.SelectType.tag = {}

	self.SubGroup.DropMenuTemplateStore:SetFilterMenuState(false)

	self.isShowProfessionEdit = data and data.isShowProfessionEdit or false

	if self.isShowProfessionEdit then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.naviArea
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.outFitPlanTipBtn:SetActive(not self.isShowProfessionEdit)
	end

	self.fashionType = data and data.fashionType or 0
	self.callBack = data and data.callBack
	self.bindData.title = data and data.title or FashionConfig.FashionChangeTitle

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.pctitle = data and data.title or FashionConfig.FashionChangeTitle
	end

	self:InitInfo()
	self:RecordFashionTypeFashionList()
	gCS.MyPlayerManager.PlayerUnit.FashionSlot:SyncApplyPlayerFashionInfo()

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond
	}

	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)
end

function M:RecordFashionTypeFashionList()
	if self.fashionType > 0 then
		self.fashionTypeFashionList, self.fashionTypeFashionEditList = gDressManager:GetMyCurrentFashionList()
	end
end

function M:OnClose()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:InitInfo()
	self.tabTopIndex = 1
	self.touchMoveLimit = 15
	self.selectFashionId = 0
	self.bindData.isShowProfessionEdit = self.isShowProfessionEdit and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE

	if self.fashionType == 0 then
		gDressManager:SetCurrentPlayerSpirit()
		gDressManager:SetPlayerFashionsInfo()
		gDressManager:CheckMyPresentHiddenPart()
	end

	self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1

	if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict) or gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId] == nil then
		print_error("@hzliuyibing 没有找到角色对应的时装信息 SpiritId = " .. gDressManager.CurrentSpiritId)

		return
	end

	self.suitFashionItemList = {}
	self.itemListByPart = {}
	self.suitList = {}
	self.touchStart = false

	self:SetPlayerIcon()
	self:SetTaskFashion()

	self.bindData.type = self.OPEN_TYPE.SUIT
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.showSwitch = 0
	self.bindData.isSelect = 0
	self.bindData.partDes = ""
	self.bindData.partCount = 0
	self.bindData.hidePanel = 1
	self.bindData.hidePage = 1

	self:RefreshStepBtnState()

	self.selectedSortItemId = self.SELECTOR_SORT_TYPE.QUALITY
	self.sortLargeToSmall = true

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.isInGamePad = self:IsInGamePad() and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
	end

	gDressManager:PlayDressDefaultAction()
	self:OnShow_Item()

	self.needRecordFashion = true
end

function M:SetRecordFashion()
	if gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId] == nil then
		print_error("没有找到角色对应的时装信息 SpiritId = " .. gDressManager.CurrentSpiritId)

		return
	end

	local list = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList
	local fashionList = {}

	for i = 1, #list do
		local fashionId = list[i].FashionId

		table.insert(fashionList, fashionId)
	end

	local stepData = {
		fashionList = fashionList,
		stepType = gDressManager.STEP_TYPE.ADD_SUIT,
		selectFashionId = self.selectFashionId
	}

	self:AddStep(stepData)
end

function M:SetTaskFashion()
	self.taskSuitId = nil
	self.taskFashionIdList = {}
	self.bindData.isShowFashionTask = self.SELECT_TYPE.FALSE
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

	if curTaskInfo and not table.isNilOrEmpty(curTaskInfo.spiritWearFashionInfoList) then
		local info = curTaskInfo.spiritWearFashionInfoList

		for i = 1, #curTaskInfo.spiritWearFashionInfoList do
			local spiritId = curTaskInfo.spiritWearFashionInfoList[i].SpiritId

			if spiritId == gDressManager.CurrentSpiritId or spiritId == 0 or spiritId == 4294967295.0 then
				info = curTaskInfo.spiritWearFashionInfoList[i]
			end
		end

		if not table.isNilOrEmpty(info.fashionIdList) then
			self.taskFashionIdList = info.fashionIdList
		end

		if info.FashionSuitId and info.FashionSuitId > 0 then
			self.taskSuitId = info.FashionSuitId
			local cfg = FashionSuitConfig.GetConfig(self.taskSuitId)

			if cfg then
				self.taskFashionIdList = cfg.FashionIdList
			end
		end

		if not table.isNilOrEmpty(self.taskFashionIdList) or self.taskSuitId ~= nil and self.taskSuitId > 0 then
			local cfg = LTConfig.TaskConfig.GetConfig(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

			if cfg then
				self.taskType = cfg.Title
			end

			self.bindData.isShowFashionTask = self.SELECT_TYPE.TRUE
			self.bindData.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			self.bindData.taskDes = gUtils:GetSpecialDescription(curTaskInfo.WorkDescription, true)
		end
	end
end

function M:OnFixedUpdate()
	return
end

function M:SetPlayerIcon()
	local info = LTConfig.FightSpiritConfig.GetConfig(gDressManager.CurrentSpiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

function M:SetDressScroll(str)
	self.bindData.des = str
end

function M:OnBackBtnClick()
	local function cb()
		gDressManager.SelectType.collect = {}
		gDressManager.SelectType.approach = {}
		gDressManager.SelectType.brand = {}
		gDressManager.SelectType.tag = {}

		gPanelManager:Close(gPanelId.S_CHANGE_DRESS)
	end

	if self.fashionType == 0 then
		self:SavePlayerFashion(cb)
	elseif gDressManager:CheckSpriteHasDefaultUnderwear() then
		gDisplayMessageMgr:ShowMessage(MessageConfig.FashionSuitQuitUnderware, function ()
			gDressManager:DressNewFashionListAndEdit(self.fashionTypeFashionList, self.fashionTypeFashionEditList)
			cb()
		end)
	else
		cb()
	end
end

function M:SavePlayerFashion(callBack)
	gDressManager.SelectType.collect = {}
	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}
	gDressManager.SelectType.tag = {}

	gDressData:AskSetSpiritFashions(callBack)
end

function M:OnSortBtnClick(selectedSortItemId, isAscending)
	self.sortLargeToSmall = not isAscending
	self.selectedSortItemId = selectedSortItemId

	if self.currentTabData then
		self:OnChangeTab(nil, self.currentTabData)
	end
end

function M:OnFilterBtnClick()
	gPanelManager:CheckShow(gPanelId.S_DRESS_FILTER, {
		callBack = function ()
			if table.isNilOrEmpty(self.currentTabData) and self.bindData.type == self.OPEN_TYPE.SUIT then
				self.currentTabData = {
					Part = gDressManager.DRESS_PART.SUITS
				}
			end

			self:OnChangeTab(nil, self.currentTabData)
		end,
		filterStore = self.SubGroup.DropMenuTemplateStore
	})
end

function M:OnSwitchBtnClick()
	local function msgCallBack()
		local function cb()
			gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(0, 0))
			gDressManager:ClearSteps()

			self.bindData.isShowInfo = self.SELECT_TYPE.FALSE

			self:OnShow()
			self.bindData.dressAnim:Play("S_Vx_ChangeDressPanel_Back")
		end

		gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, {
			callBack = cb
		})
	end

	gDressData:AskSetSpiritFashions(msgCallBack)
end

function M:OnHideBtnClick()
	if self.bindData.hidePanel == 1 then
		self.bindData.hidePanel = 0
		self.bindData.hidePage = 0

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
			self.bindData.navArea.enabled = false
		end
	else
		self.bindData.hidePage = 1
		self.bindData.hidePanel = 1

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.bindData.rightNavi.CurrentActiveContent = self.bindData.HideNaviBtn
			self.bindData.navArea.enabled = true
		end
	end
end

function M:SetSelectFashionCollectState(isCollect)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.naviArea:ChangeButtonNameByActionId(10, isCollect and 202 or 195)
	end

	for i = 1, #self.itemList do
		if self.itemList[i].fashionId == self.selectFashionId then
			self.itemList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

			break
		end
	end

	for partId, partItemList in pairs(self.itemListByPart) do
		for i = 1, #partItemList do
			if partItemList[i].fashionId == self.selectFashionId then
				partItemList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

				break
			end
		end
	end

	self.bindData.itemList:RefreshList()
end

function M:SetSelectSuitCollectState(isCollect)
	local index = nil

	for i = 1, #self.suitList do
		if self.suitList[i].suitId == self.suitId then
			self.suitList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			index = i

			break
		end
	end

	self.bindData.suitList:RefreshList()
end

function M:OnCollectBtnClick()
	if self.currentTabData.Part == gDressManager.DRESS_PART.SUITS then
		if self.suitId and self.suitId > 0 then
			if gDressManager:IsFashinSuitCollected(self.suitId) then
				gDressData:AskFavoriteFashionSuits(nil, self.suitId, function ()
					self.bindData.isCollected = self.SELECT_TYPE.FALSE

					self:SetSelectSuitCollectState(false)
				end)
			else
				gDressData:AskFavoriteFashionSuits(self.suitId, nil, function ()
					self.bindData.isCollected = self.SELECT_TYPE.TRUE

					self:SetSelectSuitCollectState(true)
				end)
			end
		end
	elseif self.selectFashionId and self.selectFashionId > 0 then
		if gDressManager:IsFashinCollected(self.selectFashionId) then
			gDressData:AskFavoriteFashions(nil, self.selectFashionId, function ()
				self.bindData.isCollected = self.SELECT_TYPE.FALSE

				self:SetSelectFashionCollectState(false)
			end)
		else
			gDressData:AskFavoriteFashions(self.selectFashionId, nil, function ()
				self.bindData.isCollected = self.SELECT_TYPE.TRUE

				self:SetSelectFashionCollectState(true)
			end)
		end
	end
end

function M:OnSettingBtnClick()
	local function cb()
		gPanelManager:CheckShow(gPanelId.DRESS_SETTINGS_PANEL, {
			fashionId = self.selectFashionId
		})
	end

	self:SavePlayerFashion(cb)
end

function M:OnOutFitPlanBtnClick()
	local function cb()
		gPanelManager:CheckShow(gPanelId.DRESS_PLAN_PANEL, {
			fashionId = self.selectFashionId
		})
	end

	self:SavePlayerFashion(cb)
end

function M:OnBaikeBtnClick()
	if self.currentTabData.Part == gDressManager.DRESS_PART.SUITS then
		gPanelManager:CheckShow(gPanelId.BAIKE_CLOTHES_PANEL, {
			targetSuitId = self.suitId
		})
	else
		gPanelManager:CheckShow(gPanelId.BAIKE_CLOTHES_PANEL, {
			targetItemId = self.selectFashionId
		})
	end
end

function M:OnDyeBtnClick()
	local function cb()
		local function callBack()
			print("OnDyeBtnClick Call back")

			self.bindData.isShowInfo = self.SELECT_TYPE.FALSE

			self:OnShow()
			self.bindData.dressAnim:Play("S_Vx_ChangeDressPanel_Back")
		end

		gPanelManager:CheckShow(gPanelId.SDYE_PANEL, {
			fashionId = self.selectFashionId,
			callBack = callBack
		})
	end

	self:SavePlayerFashion(cb)
end

function M:OnAdjustBtnClick()
	local function callBack()
		self:RefreshStepBtnState()
	end

	self.touchStart = false

	gPanelManager:CheckShow(gPanelId.S_ACCESSORIES_EDIT, {
		fashionId = self.selectFashionId,
		callBack = callBack,
		fashionType = self.fashionType
	})
end

function M:OnRefreshBtnClick()
	gDisplayMessageMgr:ShowMessage(MessageConfig.FashionResetReconfirm, function ()
		if self.fashionType <= 0 then
			gDressManager:CheckClearFashionPart()

			self.bindData.isShowInfo = self.SELECT_TYPE.FALSE

			self:OnShow()
		else
			gDressManager:DressNewFashionListAndEdit(self.fashionTypeFashionList, self.fashionTypeFashionEditList)
			self:InitInfo()
		end
	end)
end

function M:OnUnDoBtnClick()
	if gDressManager:HasLastStep() then
		gDressManager.currentPointIndex = gDressManager.currentPointIndex - 1

		self:CheckStepState(true)
		self:RefreshStepBtnState()
	end
end

function M:OnReDoBtnClick()
	if gDressManager:HasNextStep() then
		gDressManager.currentPointIndex = gDressManager.currentPointIndex + 1

		self:CheckStepState(false)
		self:RefreshStepBtnState()
	end
end

function M:AddStep(stepData)
	gDressManager:AddStep(stepData)
	self:RefreshStepBtnState()
end

function M:CheckStepState(isUndo)
	local info = gDressManager.CtrlZSteps[gDressManager.currentPointIndex]
	local oldInfo = isUndo and gDressManager.CtrlZSteps[gDressManager.currentPointIndex + 1] or gDressManager.CtrlZSteps[gDressManager.currentPointIndex - 1]

	if oldInfo.stepType == gDressManager.STEP_TYPE.EDIT then
		if table.contains(info.fashionList, oldInfo.editInfoList.FashionId) then
			if table.isNilOrEmpty(info.editInfoList) then
				gDressManager:DoChange(oldInfo.editInfoList.FashionId, Vector3.New(0, 0, 0), Vector3.New(0, 0, 0), 1, true)
			else
				gDressManager:DoChange(oldInfo.editInfoList.FashionId, info.editInfoList.Offset, info.editInfoList.Rotation, info.editInfoList.Scale, true)
			end
		end
	elseif oldInfo.stepType == gDressManager.STEP_TYPE.ADD_FASHION then
		gDressManager:RemoveFashionPart(oldInfo.fashionList)
		gDressManager:ChangeFashionPart({}, oldInfo.fashionList)

		self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
	end

	if info then
		local selectFashionId, suitId = nil

		if info.selectFashionId then
			selectFashionId = info.selectFashionId
			self.selectFashionId = selectFashionId
		end

		if info.selectSuitId then
			suitId = info.selectSuitId
			self.suitId = suitId
		end

		if info.stepType == gDressManager.STEP_TYPE.ADD_SUIT then
			gDressManager:DressSuitFashionList(info.fashionList, true, false, true)
		elseif info.stepType == gDressManager.STEP_TYPE.ADD_FASHION then
			local conflictItems, addItems = gDressManager:CheckFashionConflict(info.fashionList)

			for i = 1, #info.fashionList do
				table.insert(addItems, info.fashionList[i])
			end

			if isUndo and suitId == nil then
				gDressManager:ChangeFashionPart(addItems, conflictItems)
				gDressManager:SetFashionList(addItems)

				self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
			else
				local hasEdit = false

				for i = 1, #info.fashionList do
					local cfg = FashionConfig.GetConfig(info.fashionList[i])

					if cfg and cfg.EditId > 0 then
						hasEdit = true

						gDressManager:PreSetPropEditInfo(info.fashionList[i], UXVector3.New(0, 0, 0), UXVector3.New(0, 0, 0), 1, true)
					end
				end

				gDressManager:ChangeFashionPart(addItems, conflictItems)

				if not hasEdit then
					gDressManager:SetFashionList(info.fashionList)
				end

				self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
			end
		elseif info.stepType == gDressManager.STEP_TYPE.REMOVE_FASHION then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict(info.fashionList)

			for i = 1, #info.fashionList do
				if not table.contains(conflictItems, info.fashionList[i]) then
					table.insert(conflictItems, info.fashionList[i])
				end
			end

			if not isUndo and not table.isNilOrEmpty(info.removeFashionList) then
				for i = 1, #info.removeFashionList do
					if not table.contains(addItems, info.removeFashionList[i]) then
						table.insert(addItems, info.removeFashionList[i])
					end
				end
			end

			if not isUndo and self.suitId == nil then
				gDressManager:ChangeFashionPart(addItems, conflictItems)
				gDressManager:SetFashionList(info.fashionList)

				self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
			else
				gDressManager:ChangeFashionPart(addItems, conflictItems)
				gDressManager:RemoveFashionPart(info.fashionList)

				self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
			end
		elseif info.stepType == gDressManager.STEP_TYPE.EDIT then
			if not table.isNilOrEmpty(info.editInfoList) then
				gDressManager:PreSetPropEditInfo(info.editInfoList.FashionId, info.editInfoList.Rotation, info.editInfoList.Offset, info.editInfoList.Scale)
			end
		else
			print_error("没有找到对应的操作类型")
		end

		if selectFashionId then
			self.bindData.itemList:RefreshList()
		end

		if suitId then
			self.bindData.suitList:RefreshList()
		end
	end
end

function M:RefreshStepBtnState()
	self.bindData.undoBtn.interactable = gDressManager:HasLastStep()
	self.bindData.redoBtn.interactable = gDressManager:HasNextStep()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.undoTipBtn.interactable = gDressManager:HasLastStep()
		self.bindData.redoTipBtn.interactable = gDressManager:HasNextStep()
	end
end

function M:InitSelectorList()
	self.selectorList = {}
	local sortItemTitle = FashionConfig.SortItemTitle

	for i = 1, #sortItemTitle do
		local view = {
			label = sortItemTitle[i],
			id = i
		}

		table.insert(self.selectorList, view)
	end

	self.SubGroup.DropMenuTemplateStore:SetData({
		onSortChanged = self:CreateAction("OnSortBtnClick"),
		onFilterBtnClick = self:CreateAction("OnFilterBtnClick"),
		isAscending = not self.sortLargeToSmall,
		sortList = self.selectorList
	})
end

function M:OnFoldBtnClick()
	if self.bindData.isInfoFold == 1 then
		self.bindData.isInfoFold = 0
	else
		self.bindData.isInfoFold = 1
	end
end

function M:OnUpSelectTab()
	self.tabIndex = self.bindData.tabList.selectedIndex >= 0 and self.bindData.tabList.selectedIndex or 0

	if self.tabIndex > 0 then
		self.bindData.tabList:SelectItem(self.tabIndex - 1, true)
	end
end

function M:OnDownSelectTab()
	self.tabIndex = self.bindData.tabList.selectedIndex >= 0 and self.bindData.tabList.selectedIndex or 0

	if self.tabIndex + 1 < #self.tabList then
		self.bindData.tabList:SelectItem(self.tabIndex + 1, true)
	end
end

function M:OnLeftSelectTab()
	self.tabTopIndex = self.bindData.tabTopList.selectedIndex >= 0 and self.bindData.tabTopList.selectedIndex or 0

	if self.tabTopIndex > 0 then
		self.bindData.tabTopList:SelectItem(self.tabTopIndex - 1, true)
	end
end

function M:OnRightSelectTab()
	self.tabTopIndex = self.bindData.tabTopList.selectedIndex >= 0 and self.bindData.tabTopList.selectedIndex or 0

	if self.tabTopIndex + 1 < #self.tabTopList then
		self.bindData.tabTopList:SelectItem(self.tabTopIndex + 1, true)
	end
end

function M:OnActiveDeviceChange(scheme)
	self.bindData.isEnableController = scheme > 0
end

function M:OnActionDeviceChanged()
	if not self.isPanelFocus then
		return
	end

	self.bindData.isInGamePad = self:IsInGamePad() and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.naviArea

	self:RefreshStepBtnState()
end

function M:IsInGamePad()
	return InputActionBind.activeGameDevice == GameDevice.PlayStation or InputActionBind.activeGameDevice == GameDevice.Xbox
end

function M:RefreshRedDotInfo(fashionList, suitList)
	if fashionList then
		for i = 1, #fashionList do
			for t = 1, #self.itemList do
				if self.itemList[t].fashionId == fashionList[i] then
					self.itemList[t].isNew = false

					break
				end
			end

			for part, list in pairs(self.itemListByPart) do
				for m = 1, #list do
					if list[m].fashionId == fashionList[i] then
						list[m].isNew = false

						break
					end
				end
			end
		end

		for i = 1, #self.suitList do
			local list = self.suitList[i].fashionList
			self.suitList[i].isNew = gDressManager:IsFashionListHasRedDotNew(list)
		end
	end

	if suitList then
		for i = 1, #suitList do
			for t = 1, #self.suitList do
				if self.suitList[t].suitId == suitList[i] then
					self.suitList[t].isNew = false

					break
				end
			end

			local cfg = FashionSuitConfig.GetConfig(suitList[i])
			local list = cfg and cfg.FashionIdList or {}

			for t = 1, #list do
				for m = 1, #self.itemList do
					if list[t] == self.itemList[m].fashionId then
						self.itemList[m].isNew = false

						break
					end
				end

				for _, tlist in pairs(self.itemListByPart) do
					for n = 1, #tlist do
						if tlist[n].fashionId == list[t] then
							tlist[n].isNew = false

							break
						end
					end
				end
			end
		end
	end
end

dofile("LX6/SGUI/StoreDefine/ChangeDressPanelStore_ItemList")
