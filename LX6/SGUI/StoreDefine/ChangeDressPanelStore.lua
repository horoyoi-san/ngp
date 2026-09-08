-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeDressPanelStore.lua
-- Decompiled from: 02032_ChangeDressPanelStore.lua_84d37456d30c.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local MessageConfig = LTConfig.MessageConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local RedDotMgr = SGUI.RedDotMgr
C_ChangeDressPanelStore = DefClass("C_ChangeDressPanelStore", C_ChangeDressPanelStore, C_BaseChangeDressPanelStore)
GroupName2Class.ChangeDressPanelStore = C_ChangeDressPanelStore
local M = C_ChangeDressPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	M.base.DefineAllVariables(self)

	self.countFinish = false
	self.callBack = nil
	self.isPanelFocus = true
	self.isShowProfessionEdit = false
	self.fashionType = 0
	self.allowSpecified = false
	self.specifiedList = nil
	self.allowSpecifiedSuit = false
	self.specifiedSuitList = nil
	self.banExit = false
end

M.OnEnable = function(self)
	self.isPanelFocus = true
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnDisable = function(self)
	self.isPanelFocus = false
end

M.OnDestroy = function(self)
	if self.callBack then
		self.callBack()
	end

	if self.fashionType ~= 0 then
		gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
		gDressManager:ClearSteps()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end

	self.recordSpriteId = nil
	self.spiritContext = nil
end

M.BeforeCheckInit = function(self)
	self.spiritContext = gDressManager:GetSpiritContext()

	if self.spiritContext then
		if not self.recordSpriteId or self.recordSpriteId ~= 0 then
			self.recordSpriteId = self.spiritContext.spiritId
		end

		gDressManager:PrepareUnitForDress(self.spiritContext.unit)
	end
end

M.ShowCheck = function(self)
	if gDressManager:CheckIsInTryWear() then
		gDialogManager:ShowGeneralDialog(100053490, gDialogSource.Fashion)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressBreak)
		gPanelManager:Close(self.m_Id)

		return false
	end

	return true
end

M.InitInfo = function(self, panelId, data)
	gClientUtils.CloseMainPhonePanel()
	gDressManager:ClearSelectTypeData()

	self.isShowProfessionEdit = data and data.isShowProfessionEdit or false

	if self.isShowProfessionEdit then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.naviArea
	end

	self.fashionType = data and data.fashionType or 0
	self.callBack = data and data.callBack

	self:RecordFashionTypeFashionList()

	if self.fashionType ~= 0 then
		gDressManager:SetPlayerFashionsInfo()
	end

	if not self.spiritContext then
		self.spiritContext = gDressManager:GetSpiritContext()
	end

	gDressManager:InitSteps(self.spiritContext)

	local info = gDressManager:GetCurrentSpritWearFashionInfo(self.spiritContext)

	if not info then
		print_error("@hzliuyibing 没有找到角色对应的时装信息 SpiritId = " .. self.spiritContext.spiritId)

		return
	end

	self:SetTaskFashion()
	gDressManager:PlayDressDefaultAction()
	self:InitView(data)

	local cameraParams = {
		verticalButton = self.bindData.baseUpdownButton,
		basePanel = self.bindData.basePanel,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	}

	if data and data.source then
		cameraParams.source = data.source
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)

	if data and data.onShowCb then
		data.onShowCb()
	end
end

M.InitView = function(self, data)
	self.SubGroup.DropMenuTemplateStore:SetFilterMenuState(false)

	self.bindData.isShowProfessionEdit = self.isShowProfessionEdit and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE

	if data and data.specified and #data.specified <= 0 then
		self.allowSpecified = true
		self.specifiedList = data.specified
		self.bindData.isShowProfessionEdit = self.SELECT_TYPE.FALSE
	else
		self.allowSpecified = false
	end

	if data and data.specifiedSuit and #data.specifiedSuit <= 0 then
		self.allowSpecifiedSuit = true
		self.allowSpecified = true
		self.specifiedSuitList = data.specifiedSuit

		for _, id in pairs(self.specifiedSuitList) do
			local cfg = FashionSuitConfig.GetConfig(id)
			local fashionList = cfg.FashionIdList

			if not self.specifiedList then
				self.specifiedList = {}
			end

			for i = 1, #fashionList do
				if not table.contains(self.specifiedList, fashionList[i]) then
					table.insert(self.specifiedList, fashionList[i])
				end
			end
		end

		self.bindData.isShowProfessionEdit = self.SELECT_TYPE.FALSE
	else
		self.allowSpecifiedSuit = false
	end

	self.bindData.title = data and data.title or FashionConfig.FashionChangeTitle

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.outFitPlanTipBtn:SetActive(not self.isShowProfessionEdit)

		self.bindData.pctitle = data and data.title or FashionConfig.FashionChangeTitle
	end

	self.bindData.isShowSetting = gDressManager:CheckShowSetting(self.spiritContext) and 0 or 1
	self.bindData.type = self.OPEN_TYPE.SUIT
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.showSwitch = 0
	self.bindData.isSelect = 0
	self.bindData.partDes = ""
	self.bindData.partCount = 0
	self.bindData.hidePanel = 1
	self.bindData.hidePage = 1

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local isGamePad = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
		self.bindData.isInGamePad = isGamePad and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
	end

	self.SetPlayerIcon(self)
	self.RefreshStepBtnState(self)
end

M.SetPlayerIcon = function(self)
	local info = LTConfig.FightSpiritConfig.GetConfig(self.spiritContext.spiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

M.OnClose = function(self)
	gDressStack:SetDressStack(self.m_Id, false)
	gDressData:FlushFavoriteFashionChanges()
	gDressData:FlushFavoriteSuitChanges()
end

M.OnActiveDeviceChange = function(self, device)
	self.bindData.isEnableController = device >= 0

	if not self.isPanelFocus then
		return
	end

	local gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
	self.bindData.isInGamePad = gamepadMode and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.naviArea

	self:RefreshStepBtnState()
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.switchBtn.luaClick = self.CreateAction(self, "OnSwitchBtnClick")
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnHideBtnClick")
	self.bindData.collectBtn.luaClick = self.CreateAction(self, "OnCollectBtnClick")
	self.bindData.dyeBtn.luaClick = self.CreateAction(self, "OnDyeBtnClick")
	self.bindData.adjustBtn.luaClick = self.CreateAction(self, "OnAdjustBtnClick")
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, "OnRefreshBtnClick")
	self.bindData.undoBtn.luaClick = self.CreateAction(self, "OnUnDoBtnClick")
	self.bindData.redoBtn.luaClick = self.CreateAction(self, "OnReDoBtnClick")
	self.bindData.settingBtn.luaClick = self.CreateAction(self, "OnSettingBtnClick")
	self.bindData.outFitPlanBtn.luaClick = self.CreateAction(self, "OnOutFitPlanBtnClick")
	self.bindData.foldBtn.luaClick = self.CreateAction(self, "OnFoldBtnClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.upSelectTabBtn.luaClick = self.CreateAction(self, "OnUpSelectTab")
		self.bindData.downSelectTabBtn.luaClick = self.CreateAction(self, "OnDownSelectTab")
		self.bindData.leftSelectTabBtn.luaClick = self.CreateAction(self, "OnLeftSelectTab")
		self.bindData.rightSelectTabBtn.luaClick = self.CreateAction(self, "OnRightSelectTab")
	end
end

M.SavePlayerFashion = function(self, callBack)
	gDressManager:ClearSelectTypeData()
	gDressData:AskSetSpiritFashions(callBack, self.spiritContext.spiritId, self.spiritContext.unit)
end

M.OnBackBtnClick = function(self)
	if self.banExit then
		return
	end

	local cb = function()
		gDressManager:ClearSelectTypeData()
		gPanelManager:Close(gPanelId.S_CHANGE_DRESS)
	end

	if self.fashionType ~= 0 then
		self.SavePlayerFashion(self, cb)
	elseif gDressManager:CheckSpriteHasDefaultUnderwear(self.spiritContext) then
		slot2 = gDisplayMessageMgr

		slot2:ShowMessage(MessageConfig.FashionSuitQuitUnderware, function ()
			gDressManager:DressNewFashionListAndEdit(self.fashionTypeRecordInfo.WearFashionInfoList, self.fashionTypeRecordInfo.WearFashionEditInfoList, self.spiritContext)
			cb()
		end)
	else
		cb()
	end
end

M.OnSortBtnClick = function(self, selectedSortItemId, isAscending)
	self.sortLargeToSmall = not isAscending
	self.selectedSortItemId = selectedSortItemId

	if self.currentTabData then
		self.OnChangeTab(self, nil, self.currentTabData)
	end
end

M.OnFilterBtnClick = function(self)
	self:SetExitBarrier()
	gPanelManager:CheckShow(gPanelId.S_DRESS_FILTER, {
		callBack = function ()
			if table.isNilOrEmpty(self.currentTabData) and self.bindData.type ~= self.OPEN_TYPE.SUIT then
				self.currentTabData = {
					Part = gDressManager.DRESS_PART.SUITS
				}
			end

			self:OnChangeTab(nil, self.currentTabData)
		end,
		filterStore = self.SubGroup.DropMenuTemplateStore
	})
end

M.OnSwitchBtnClick = function(self)
	self:SetExitBarrier()

	local msgCallBack = function()
		local cb = function()
			gMessageManager:SendMessage(gEventConstants.MOUSE_MOVE, Vector2.New(0, 0))
			gDressManager:InitSteps(self.spiritContext)

			self.needRecordFashion = true
			self.bindData.isShowInfo = self.SELECT_TYPE.FALSE

			self:OnShow()
			self.bindData.dressAnim:Play("S_Vx_ChangeDressPanel_Back")
		end

		gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, {
			callBack = cb
		})
	end

	gDressData:AskSetSpiritFashions(msgCallBack, self.spiritContext.spiritId, self.spiritContext.unit)
end

M.OnHideBtnClick = function(self)
	if self.bindData.hidePanel ~= 1 then
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

M.SetSelectFashionCollectState = function(self, isCollect)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.naviArea:ChangeButtonNameByActionId(10, isCollect and 202 or 195)
	end

	for i = 1, #self.itemList do
		if self.itemList[i].fashionId ~= self.selectFashionId then
			self.itemList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

			break
		end
	end

	for partId, partItemList in pairs(self.itemListByPart) do
		for i = 1, #partItemList do
			if partItemList[i].fashionId ~= self.selectFashionId then
				partItemList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

				break
			end
		end
	end

	self.bindData.itemList:RefreshList()
end

M.SetSelectSuitCollectState = function(self, isCollect)
	local index = nil

	for i = 1, #self.suitList do
		if self.suitList[i].suitId ~= self.suitId then
			self.suitList[i].isCollect = isCollect and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			index = i

			break
		end
	end

	self.bindData.suitList:RefreshList()
end

M.OnCollectBtnClick = function(self)
	if self.currentTabData.Part ~= gDressManager.DRESS_PART.SUITS then
		if self.suitId and self.suitId <= 0 then
			local isCollected = gDressManager:IsFashinSuitCollected(self.suitId)

			gDressData:RecordFavoriteSuitChange(self.suitId, not isCollected)

			self.bindData.isCollected = isCollected and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE

			self:SetSelectSuitCollectState(not isCollected)
		end
	elseif self.selectFashionId and self.selectFashionId <= 0 then
		local isCollected = gDressManager:IsFashionCollected(self.selectFashionId)

		gDressData:RecordFavoriteFashionChange(self.selectFashionId, not isCollected)

		self.bindData.isCollected = isCollected and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE

		self:SetSelectFashionCollectState(not isCollected)
	end
end

M.OnSettingBtnClick = function(self)
	local cb = function()
		gPanelManager:CheckShow(gPanelId.DRESS_SETTINGS_PANEL, {
			fashionId = self.selectFashionId
		})
	end

	self.SavePlayerFashion(self, cb)
end

M.OnOutFitPlanBtnClick = function(self)
	self.SetExitBarrier(self)

	local cb = function()
		gPanelManager:CheckShow(gPanelId.DRESS_PLAN_PANEL, {
			fashionId = self.selectFashionId
		})
	end

	self.SavePlayerFashion(self, cb)
end

M.OnDyeBtnClick = function(self)
	self.SetExitBarrier(self)

	local cb = function()
		local callBack = function()
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

	self.SavePlayerFashion(self, cb)
end

M.OnAdjustBtnClick = function(self)
	self:SetExitBarrier()

	local callBack = function()
		self:RefreshStepBtnState()
		self.bindData.itemList:RefreshList()
	end

	gPanelManager:CheckShow(gPanelId.S_ACCESSORIES_EDIT, {
		fashionId = self.selectFashionId,
		callBack = callBack,
		fashionType = self.fashionType
	})
end

M.OnRefreshBtnClick = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.FashionResetReconfirm, function ()
		if self.fashionType < 0 then
			gDressManager:CheckClearFashionPart()

			self.bindData.isShowInfo = self.SELECT_TYPE.FALSE

			self:OnShow()
		else
			gDressManager:DressNewFashionListAndEdit(self.fashionTypeRecordInfo.WearFashionInfoList, self.fashionTypeRecordInfo.WearFashionEditInfoList, self.spiritContext)
			self:InitInfo()
		end
	end)
end

M.OnUnDoBtnClick = function(self)
	local snapshot = gDressManager:Undo(self.spiritContext)

	if snapshot then
		self.RestoreUIFromSnapshot(self, snapshot)
	end

	self.RefreshStepBtnState(self)
end

M.OnReDoBtnClick = function(self)
	local snapshot = gDressManager:Redo(self.spiritContext)

	if snapshot then
		self.RestoreUIFromSnapshot(self, snapshot)
	end

	self.RefreshStepBtnState(self)
end

M.OnFoldBtnClick = function(self)
	if self.bindData.isInfoFold ~= 1 then
		self.bindData.isInfoFold = 0
	else
		self.bindData.isInfoFold = 1
	end
end

M.OnUpSelectTab = function(self)
	self.tabIndex = self.bindData.tabList.selectedIndex > 0 and self.bindData.tabList.selectedIndex or 0

	if self.tabIndex <= 0 then
		self.bindData.tabList:SelectItem(self.tabIndex - 1, true)
	end
end

M.OnDownSelectTab = function(self)
	self.tabIndex = self.bindData.tabList.selectedIndex > 0 and self.bindData.tabList.selectedIndex or 0

	if self.tabIndex + 1 >= #self.tabList then
		self.bindData.tabList:SelectItem(self.tabIndex + 1, true)
	end
end

M.OnLeftSelectTab = function(self)
	self.tabTopIndex = self.bindData.tabTopList.selectedIndex > 0 and self.bindData.tabTopList.selectedIndex or 0

	if self.tabTopIndex <= 0 then
		self.bindData.tabTopList:SelectItem(self.tabTopIndex - 1, true)
	end
end

M.OnRightSelectTab = function(self)
	self.tabTopIndex = self.bindData.tabTopList.selectedIndex > 0 and self.bindData.tabTopList.selectedIndex or 0

	if self.tabTopIndex + 1 >= #self.tabTopList then
		self.bindData.tabTopList:SelectItem(self.tabTopIndex + 1, true)
	end
end

M.OnChangeTabTop = function(self, btn, data)
	self.bindData.showSwitch = self.SELECT_TYPE.TRUE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.bindData.partDes = data.PartName
	self.bindData.type = self.OPEN_TYPE.FASHION

	self.bindData.tabTopList:GoToIndex(self.tabTopIndex - 1, false)

	local itemList = self.itemListByPart[data.Part] or {}
	local propItemList = {}

	for i = 1, #itemList do
		if itemList[i].PropPart ~= data.Type then
			table.insert(propItemList, itemList[i])
		end
	end

	self.itemList = self:FilterItems(propItemList) or {}
	self.bindData.partCount = table.count(self.itemList)

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.bindData.itemList:PlayStartOffsetAnim()
end

M.OnChangeTab = function(self, btn, data)
	self.currentTabData = data
	self.bindData.partDes = data.PartName
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.recordItems = {}

	if self.finishTabLayOut then
		self.bindData.tabList:GoToIndex(self.tabIndex - 1, false)
	end

	local gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	if gamepadMode then
		self.bindData.navArea.rightNav = data.Part ~= gDressManager.DRESS_PART.SUITS and self.bindData.suitList.transform:GetComponent(typeof(SGUI.UNavigationArea)) or self.bindData.itemList.transform:GetComponent(typeof(SGUI.UNavigationArea))
	end

	if data.Part ~= gDressManager.DRESS_PART.SUITS then
		self.bindData.type = self.OPEN_TYPE.SUIT
		self.suitList = self:FilterItems(self.suitList)

		self.bindData.suitList:SetSimpleList(#self.suitList)

		self.bindData.partCount = table.count(self.suitList)
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.hasSecondTab = 1

		self.bindData:Commit("type", self.OPEN_TYPE.SUIT, COMMIT_IMMEDIATELY)
		self.bindData.suitList:PlayStartOffsetAnim(0)
	elseif data.Part ~= gDressManager.DRESS_PART.PROP then
		self.bindData.hasSecondTab = 0
		self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		data.PropPart = FashionConfig.FashionPropTabIcon[1].type
		self.bindData.partDes = FashionConfig.FashionChangePropTabName[1].Name
		self.bindData.type = self.OPEN_TYPE.FASHION

		self.bindData:Commit("type", self.OPEN_TYPE.FASHION, COMMIT_IMMEDIATELY)

		local itemList = self.itemListByPart[data.Part] or {}
		local propItemList = {}

		for i = 1, #itemList do
			if itemList[i].PropPart ~= data.PropPart then
				table.insert(propItemList, itemList[i])
			end
		end

		self.itemList = self:FilterItems(propItemList) or {}
		self.bindData.partCount = table.count(self.itemList)

		self.bindData.itemList:SetSimpleList(#self.itemList)
		self.bindData.itemList:PlayStartOffsetAnim(0)
		self.bindData.tabTopList:SelectItem(self.tabTopIndex - 1, true)
	else
		self.bindData.hasSecondTab = 1
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.type = self.OPEN_TYPE.FASHION

		self.bindData:Commit("type", self.OPEN_TYPE.FASHION, COMMIT_IMMEDIATELY)

		if not table.isNilOrEmpty(self.itemListByPart) then
			self.itemList = self:FilterItems(self.itemListByPart[data.Part]) or {}
			self.bindData.partCount = table.count(self.itemList)

			self.bindData.itemList:SetSimpleList(#self.itemList)
			self.bindData.itemList:PlayStartOffsetAnim(0)

			self.recordItems = self.itemList

			self:OnItemFinish()
		end
	end
end

M.OnSimpleClickSuitList = function(self, btn, index)
	local data = self.suitList[index + 1]

	if btn.isSelected then
		if data.isNew then
			local redDotSuitList = {}

			table.insert(redDotSuitList, data.suitId)

			slot5 = gDressData

			slot5:AskReadFashionSuits(redDotSuitList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageSuitList:" .. data.id)
				self:RefreshRedDotInfo(nil, redDotSuitList)
			end)
		end

		self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.suitId = data.suitId
		self.bindData.isCollected = gDressManager:IsFashinSuitCollected(self.suitId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		self:SelectSuitInfo(data)

		if data.isAvailable ~= self.SELECT_TYPE.TRUE then
			gDressManager:DressSuitFashionList(data.fashionList, false, self.spiritContext)
			self:PushSnapshot(nil, self.suitId)
		end
	else
		self.suitId = 0
		self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
		self.bindData.isCollected = self.SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self:SetDressScroll()
		gDressManager:RemoveFashionPart(data.fashionList, self.spiritContext)
		self:PushSnapshot(nil, self.suitId)
	end
end

M.OnSimpleClickItemList = function(self, btn, index)
	local data = self.itemList[index + 1]

	if not data then
		print_error("换装失败，当前itemList总数", #self.itemList, "当前选中index", index)

		return
	end

	if btn.isSelected then
		if data.isNew then
			local redDotFashionList = {}

			table.insert(redDotFashionList, data.fashionId)

			slot5 = gDressData

			slot5:AskReadFashions(redDotFashionList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageList:" .. data.id)
				self:RefreshRedDotInfo(redDotFashionList)
			end)
		end

		self.bindData.isShowEdit = data.EditId and data.EditId <= 0 and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		if self.bindData.isShowInfo ~= self.SELECT_TYPE.FALSE then
			self.bindData.isShowInfo = self.SELECT_TYPE.TRUE
		end

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.selectFashionId = data.fashionId
		self.bindData.isCollected = gDressManager:IsFashionCollected(data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

			if brandCfg then
				self.bindData.currentDressIcon = brandCfg.BrandLogo
				self.bindData.brandBanner = brandCfg.BrandBG
			end

			self.bindData.currentDressName = fashionCfg.Name

			self.SetFashionTagInfo(self, data.fashionId)
			self.SetDressScroll(self, fashionCfg.Description)
		end

		if data.Part ~= gDressManager.DRESS_PART.PROP then
			self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		end

		if data.isAvailable ~= self.SELECT_TYPE.TRUE then
			if gDressManager:IsFashionHad(data.fashionId) then
				local conflictItems, addItems = gDressManager:CheckFashionConflict({
					data.fashionId
				})

				table.insert(addItems, data.fashionId)

				if not table.isNilOrEmpty(conflictItems) then
					local isSamePart = true
					local conflictName = ""

					for i = 1, #conflictItems do
						local cfg = FashionConfig.GetConfig(conflictItems[i])

						if cfg and cfg.Part == data.Part and not cfg.IsDefaultUnderwear and cfg.IsShow then
							isSamePart = false

							if conflictName ~= "" then
								conflictName = conflictName .. cfg.Name
							else
								conflictName = conflictName .. "," .. cfg.Name
							end
						end
					end

					if not isSamePart then
						local msgConfig = MessageConfig.GetConfig(MessageConfig.FashionConflict)

						if msgConfig then
							self.bindData.isShowMessage = self.SELECT_TYPE.TRUE
							self.bindData.msgDes = string.format(msgConfig.Content, conflictName, data.Name)
							self.timerMsg = Timer.New(function ()
								self.bindData.isShowMessage = self.SELECT_TYPE.FALSE
								self.timerMsg = nil
							end, 2):Start()
						end
					end
				end

				gDressManager:CheckSetPropEditInfo(data.fashionId, self.spiritContext)
				gDressManager:SetFashionList(addItems, nil, self.spiritContext)

				if not gDressManager:CheckFashionConflictIsTakeEffect() then
					return
				end

				self.PushSnapshot(self, self.selectFashionId, nil)
			end
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FashionGenderMismacth)
		end

		if not gDressManager:CheckFashionConflictIsTakeEffect() then
			return
		end

		self.bindData.itemList:RefreshList()
	else
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.showdye = self.SELECT_TYPE.FALSE
		self.bindData.isCollected = self.SELECT_TYPE.FALSE
		self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self.SetDressScroll(self)

		self.bindData.redoBtnState = 1

		if data.isAvailable ~= self.SELECT_TYPE.TRUE and gDressManager:IsFashionHad(data.fashionId) then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict({
				data.fashionId
			})

			gDressManager:RemoveFashionPart({
				data.fashionId
			}, self.spiritContext)
			self:PushSnapshot(0, nil)
		end
	end

	if data.isAvailable ~= self.SELECT_TYPE.TRUE then
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local minType = fashionCfg.Types[1]

			for i = 1, #fashionCfg.Types do
				if fashionCfg.Types[i] >= minType then
					minType = fashionCfg.Types[i]
				end
			end

			gDressManager:PlayDressAction(minType, data.fashionId, nil, self.spiritContext)
		end
	end

	self.bindData.isShowSetting = gDressManager:CheckShowSetting(self.spiritContext) and 0 or 1
end

M.PushSnapshot = function(self, selectFashionId, selectSuitId)
	gDressManager:PushSnapshot(self.spiritContext, selectFashionId, selectSuitId)
	self:RefreshStepBtnState()
end

M.RestoreUIFromSnapshot = function(self, snapshot)
	if snapshot.selectFashionId then
		self.selectFashionId = snapshot.selectFashionId
	end

	if snapshot.selectSuitId then
		self.suitId = snapshot.selectSuitId
	end

	self.bindData.itemList:RefreshList()
	self.bindData.suitList:RefreshList()

	self.bindData.isShowSetting = gDressManager:CheckShowSetting(self.spiritContext) and 0 or 1
end

M.RefreshStepBtnState = function(self)
	self.bindData.undoBtn.interactable = gDressManager:HasLastStep()
	self.bindData.redoBtn.interactable = gDressManager:HasNextStep()

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.undoTipBtn.interactable = gDressManager:HasLastStep()
		self.bindData.redoTipBtn.interactable = gDressManager:HasNextStep()
	end
end

M.SetTaskFashion = function(self)
	self.taskSuitIdList = {}
	self.taskFashionIdList = {}
	self.bindData.isShowFashionTask = self.SELECT_TYPE.FALSE
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

	if curTaskInfo and not table.isNilOrEmpty(curTaskInfo.spiritWearFashionInfoList) then
		for i = 1, #curTaskInfo.spiritWearFashionInfoList do
			local entry = curTaskInfo.spiritWearFashionInfoList[i]
			local spiritId = entry.SpiritId

			if spiritId ~= self.spiritContext.spiritId or spiritId ~= 0 or spiritId ~= gClientConst.MAX_UINT then
				if not table.isNilOrEmpty(entry.fashionIdList) then
					for j = 1, #entry.fashionIdList do
						local fId = entry.fashionIdList[j]

						if not table.contains(self.taskFashionIdList, fId) then
							table.insert(self.taskFashionIdList, fId)
						end
					end
				end

				if entry.FashionSuitId and entry.FashionSuitId <= 0 then
					if not table.contains(self.taskSuitIdList, entry.FashionSuitId) then
						table.insert(self.taskSuitIdList, entry.FashionSuitId)
					end

					local cfg = FashionSuitConfig.GetConfig(entry.FashionSuitId)

					if cfg and not table.isNilOrEmpty(cfg.FashionIdList) then
						for j = 1, #cfg.FashionIdList do
							local fId = cfg.FashionIdList[j]

							if not table.contains(self.taskFashionIdList, fId) then
								table.insert(self.taskFashionIdList, fId)
							end
						end
					end
				end
			end
		end

		if not table.isNilOrEmpty(self.taskFashionIdList) or not table.isNilOrEmpty(self.taskSuitIdList) then
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

M.SetExitBarrier = function(self)
	self.banExit = true

	gLuaTimeMgrUtils.Delay(function ()
		self.banExit = false
	end, 1)
end

M.SetRecordFashion = function(self)
	local spiritId = self.spiritContext and self.spiritContext.spiritId or 0
	local info = gDressManager:GetCurrentSpritWearFashionInfo(self.spiritContext)

	if not info then
		print_error("没有找到角色对应的时装信息 SpiritId = " .. spiritId)

		return
	end

	local list = info.WearFashionInfoList
	local fashionList = {}

	for i = 0, list.Count - 1 do
		local fashionId = list[i].FashionId

		table.insert(fashionList, fashionId)
	end

	self.PushSnapshot(self, self.selectFashionId, nil)
end

M.OnItemFinish = function(self)
	if self.gotoIndexFashionId <= 0 and not table.isNilOrEmpty(self.recordItems) then
		for i = 1, #self.recordItems do
			if self.recordItems[i].fashionId ~= self.gotoIndexFashionId then
				self.bindData.itemList:GoToIndex(i - 1, false)

				self.gotoIndexFashionId = 0

				break
			end
		end
	end
end

M.SetDressScroll = function(self, str)
	self.bindData.des = str
end

M.SelectSuitInfo = function(self, data)
	self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

	self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

	local fashionCfg = FashionConfig.GetConfig(data.fashionList and data.fashionList[1] or 0)

	if fashionCfg then
		local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

		if brandCfg then
			self.bindData.currentDressIcon = brandCfg.BrandLogo
			self.bindData.brandBanner = brandCfg.BrandBG
		end

		local suitCfg = FashionSuitConfig.GetConfig(data.suitId)

		if suitCfg then
			self.bindData.currentDressName = suitCfg.Name
		end
	end

	self.InitSuitFashionRightList(self)
	self.SetFashionTagInfo(self)
end

M.SetFashionTagInfo = function(self, fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

M.InitSuitFashionRightList = function(self)
	if self.suitId ~= nil or self.suitId ~= 0 then
		return
	end

	self.suitFashionRightList = {}
	local cfg = FashionSuitConfig.GetConfig(self.suitId)

	if cfg then
		for i = 1, #cfg.FashionIdList do
			local view = {
				fashionId = cfg.FashionIdList[i]
			}
			local fashionCfg = FashionConfig.GetConfig(view.fashionId)

			if fashionCfg then
				view.icon = fashionCfg.Icon
				view.quality = fashionCfg.Quality
				view.Part = fashionCfg.Part
				view.PropPart = fashionCfg.PropPart
				view.isLock = gDressManager:IsFashionHad(view.fashionId)
				view.Types = fashionCfg.Types
			end

			local available = gDressManager:CheckGenderWithBodyTypeAllow(view.fashionId, self.spiritContext.spiritInfo)

			if available and cfg.IsShow then
				table.insert(self.suitFashionRightList, view)
			end
		end
	end

	self.bindData.suitFashionList:SetSimpleList(#self.suitFashionRightList)
end

M.CheckFashionIdCanShow = function(self, fashionId)
	if self.allowSpecified then
		if not self.specifiedList then
			return false
		end

		return table.contains(self.specifiedList, fashionId)
	else
		return true
	end
end

M.CheckFashionSuitCanShow = function(self, suitId)
	if self.allowSpecifiedSuit then
		if not self.specifiedSuitList then
			return false
		end

		return table.contains(self.specifiedSuitList, suitId)
	else
		return true
	end
end
