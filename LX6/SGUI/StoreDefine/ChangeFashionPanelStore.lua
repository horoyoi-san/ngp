-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChangeFashionPanelStore.lua
-- Decompiled from: 01454_ChangeFashionPanelStore.lua_5f5e06058523.luajit

local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local FashionRentConfig = LTConfig.FashionRentConfig
local MessageConfig = LTConfig.MessageConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local PartyConfig = LTConfig.PartyConfig
local PartyPartyTypeConfig = LTConfig.PartyPartyTypeConfig
local FashionFunctionSuitConfig = LTConfig.FashionFunctionSuitConfig
C_ChangeFashionPanelStore = DefClass("C_ChangeFashionPanelStore", C_ChangeFashionPanelStore, C_StoreGroup)
GroupName2Class.ChangeFashionPanelStore = C_ChangeFashionPanelStore
local M = C_ChangeFashionPanelStore

dofile("LX6/SGUI/StoreDefine/ChangeFashionPanelStore_DressFormMode")
dofile("LX6/SGUI/StoreDefine/ChangeFashionPanelStore_PartyMode")
dofile("LX6/SGUI/StoreDefine/ChangeFashionPanelStore_RentMode")
dofile("LX6/SGUI/StoreDefine/ChangeFashionPanelStore_OCMode")

M.WEAR_SOURCE = {
	["\\x89\\x9e7\\x99E\t\\xdb"] = 2,
	["\\xa1_H"] = 1
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.countFinish = false
	self.callBack = nil
	self.isPanelFocus = true
	self.isShowProfessionEdit = false
	self.fashionType = 0
	self.banExit = false
	self.needRecordFashion = true
	self.allowSpecified = false
	self.specifiedList = nil
	self.allowSpecifiedSuit = false
	self.specifiedSuitList = nil
	self.spiritContext = nil
	self.recordSpriteId = nil
	self.fashionTypeRecordInfo = nil
	self.selectFashionId = 0
	self.suitId = 0
	self.skipMovementState = false
	self.isDummyMode = false
	self.taskSuitIdList = nil
	self.taskFashionIdList = nil
	self.taskType = nil
	self.taskWorkDescription = nil
	self.fashionChangeType = gClientConst.FashionChangeType.Self
	self.currentToggleIndex = self.WEAR_SOURCE.OWN
	self.currentWearSource = self.WEAR_SOURCE.OWN
	self.tooltipShownByRender = false

	self.DefinePartyVariables(self)
	self.DefineDressFormVariables(self)
	self.DefineRentVariables(self)
	self.DefineOCVariables(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.messageCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowInfoCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showTaskCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.showFashionToggleCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.showCharacterOrderCtrlEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.hidePageCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.isShowRentCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.isShowSwitchFormCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.uiDisplayCtrlEnum = {
		["\\xcf\\xd2\t%\\xfd"] = 0,
		["h'|W"] = 1
	}
	self.formTypeCtrlEnum = {
		["Z\\xa1\\xaf\\xae\\xb8"] = 1,
		["\\x83ih"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.messageCtrlEnum = nil
	self.isShowInfoCtrlEnum = nil
	self.showTaskCtrlEnum = nil
	self.showFashionToggleCtrlEnum = nil
	self.showCharacterOrderCtrlEnum = nil
	self.hidePageCtrlEnum = nil
	self.isShowRentCtrlEnum = nil
	self.isShowSwitchFormCtrlEnum = nil
	self.uiDisplayCtrlEnum = nil
	self.formTypeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.isPanelFocus = true
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.isPanelFocus = false
end

M.OnDestroy = function(self)
	if self.callBack then
		self.callBack()
	end

	if self.fashionChangeType ~= gClientConst.FashionChangeType.Rent then
		self.DestroyRentMode(self)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.Party then
		self.DestroyPartyMode(self)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		self.DestroyDressFormMode(self)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		self.DestroyOCMode(self)
	else
		self.DestroySelfMode(self)
	end

	self.recordSpriteId = nil
	self.spiritContext = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.showData = data

	self.BeforeCheckInit(self)

	if not self.ShowCheck(self) then
		return
	end

	self.InitInfo(self, panelId, data)
end

M.OnClose = function(self)
	if self.shouldExitScene then
		gDressManager:ExitDressScene()
	end

	gDressStack:SetDressStack(self.m_Id, false)
	gDressData:FlushFavoriteFashionChanges()
	gDressData:FlushFavoriteSuitChanges()
end

M.OnActiveDeviceChange = function(self, device)
	if not self.isPanelFocus then
		return
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {}
end

M.RegisterWidget = function(self)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, "OnClickRefreshBtn")
	self.bindData.lightBtn.luaClick = self.CreateAction(self, "OnClickLightBtn")
	self.bindData.hideBtn.luaClick = self.CreateAction(self, "OnClickHideBtn")
	self.bindData.undoBtn.luaClick = self.CreateAction(self, "OnClickUndoBtn")
	self.bindData.redoBtn.luaClick = self.CreateAction(self, "OnClickRedoBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.switchFormBtn.luaClick = self.CreateAction(self, "OnClickSwitchBodyBtn")
	self.bindData.fashionToggleList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFashionToggle")
	self.bindData.fashionToggleList.luaSimpleClick = self.CreateAction(self, "OnClickFashionToggle")
	self.bindData.characterList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderCharacterList")
	self.bindData.characterList.luaSimpleClick = self.CreateAction(self, "OnClickCharacterItem")
	self.bindData.characterList.onGetTIndex = self.CreateAction(self, "OnGetCharacterListTIndex")
end

M.OnClickRefreshBtn = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.FashionResetReconfirm, function ()
		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false
		local refreshHandlers = {
			[gClientConst.FashionChangeType.DressForm] = self.OnRefreshDressFormMode,
			[gClientConst.FashionChangeType.OC] = self.OnRefreshOCMode,
			[gClientConst.FashionChangeType.Party] = self.OnRefreshPartyMode,
			[gClientConst.FashionChangeType.Rent] = self.OnRefreshRentMode
		}
		local handler = refreshHandlers[self.fashionChangeType]

		if handler then
			handler(self)
		else
			self:OnRefreshSelfMode()
		end

		self:InitInfo(nil, self.showData)
	end)
end

M.OnRefreshSelfMode = function(self)
	if self.fashionType < 0 then
		gDressManager:CheckClearFashionPart(self.spiritContext)
	else
		gDressManager:DressNewFashionListAndEdit(self.fashionTypeRecordInfo.WearFashionInfoList, self.fashionTypeRecordInfo.WearFashionEditInfoList, self.spiritContext)
	end
end

M.OnClickLightBtn = function(self)
	gDressSceneManager:CycleDressScene()

	self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
end

M.OnClickHideBtn = function(self)
	if not self.bindData.hidePageCtrl then
		self.bindData.hidePageCtrl = 0
	else
		self.bindData:Commit("hidePageCtrl", 1 - self.bindData.hidePageCtrl, COMMIT_IMMEDIATELY)
	end

	if self.bindData.hidePageCtrl ~= 1 then
		self.bindData.lightBtn:SetActive(self.isDummyMode)
	end
end

M.OnClickUndoBtn = function(self)
	local snapshot = gDressManager:Undo(self.spiritContext)

	if snapshot then
		self.RestoreUIFromSnapshot(self, snapshot)
	end

	self.RefreshStepBtnState(self)
end

M.OnClickRedoBtn = function(self)
	local snapshot = gDressManager:Redo(self.spiritContext)

	if snapshot then
		self.RestoreUIFromSnapshot(self, snapshot)
	end

	self.RefreshStepBtnState(self)
end

M.OnClickCloseBtn = function(self)
	if self.banExit then
		return
	end

	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		self.SaveDressFormFashion(self, function ()
			gDressManager:ClearSelectTypeData()
			gPanelManager:Close(self.m_Id)
		end)

		return
	end

	if self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		gDressManager:ClearSelectTypeData()
		gPanelManager:Close(self.m_Id)

		return
	end

	if self.currentWearSource ~= self.WEAR_SOURCE.BORROWED then
		if self.fashionChangeType ~= gClientConst.FashionChangeType.Party then
			self.settled = true

			self.SavePartyFashion(self, function ()
				gDressManager:ClearSelectTypeData()
				gPanelManager:Close(self.m_Id)
			end)
		else
			gDressManager:ClearSelectTypeData()
			gPanelManager:Close(self.m_Id)
		end
	else
		local partyId = self.partyPartyId or self.partyId

		if (self.fashionChangeType ~= gClientConst.FashionChangeType.Party or self.fashionChangeType ~= gClientConst.FashionChangeType.Rent) and partyId then
			self.settled = true

			self.SaveToFunctionSuit(self, partyId, function ()
				gDressManager:ClearSelectTypeData()
				gPanelManager:Close(self.m_Id)
			end)
		else
			self.SavePlayerFashion(self, function ()
				gDressManager:ClearSelectTypeData()
				gPanelManager:Close(self.m_Id)
			end)
		end
	end
end

M.OnClickSwitchBodyBtn = function(self)
	local currentModelId = self.spiritContext.spiritInfo.ModelId
	local currentModelCfg = LTConfig.GeneralModelConfig.GetConfig(currentModelId)
	local currentBodyType = currentModelCfg.BodyType
	local isMale = currentBodyType > 3
	local targetShowcaseId = nil

	if isMale then
		targetShowcaseId = self.GetDefaultFemaleShowcaseId(self)
	else
		targetShowcaseId = self.GetDefaultMaleShowcaseId(self)
	end

	if targetShowcaseId and targetShowcaseId == self.dressFormShowcaseId then
		self.SwitchDressFormShowcase(self, targetShowcaseId)
	end
end

M.BeforeCheckInit = function(self)
	if self.showData and self.showData.spiritContext then
		self.spiritContext = self.showData.spiritContext
	elseif self.showData and self.showData.unit then
		self.spiritContext = gDressManager:GetSpiritContext(nil, , self.showData.unit)
	else
		self.spiritContext = gDressManager:GetSpiritContext()
	end

	self.isDummyMode = self.showData and self.showData.isDummyMode or false

	self.bindData.lightBtn:SetActive(self.isDummyMode)

	self.bindData.uiDisplayCtrl = self.isDummyMode and self.uiDisplayCtrlEnum.virtual or self.uiDisplayCtrlEnum.real

	if self.isDummyMode then
		self.bindData.lightNameText = gDressSceneManager:GetNextSceneName()
	end

	if self.spiritContext then
		if not self.recordSpriteId or self.recordSpriteId ~= 0 then
			self.recordSpriteId = self.spiritContext.spiritId
		end

		gDressManager:PrepareUnitForDress(self.spiritContext.unit)
	end
end

M.ShowCheck = function(self)
	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm or self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		return true
	end

	if gDressManager:CheckIsInTryWear() then
		gDialogManager:ShowGeneralDialog(100053490, gDialogSource.Fashion)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressBreak)
		gPanelManager:Close(self.m_Id)

		return false
	end

	return true
end

M.TryPlayDressAction = function(self, actionType, ...)
	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm or self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		return
	end

	if actionType ~= "suit" then
		gDressManager:PlayDressSuitAction(...)
	elseif actionType ~= "single" then
		gDressManager:PlayDressAction(...)
	end
end

M.InitInfo = function(self, panelId, data)
	gClientUtils.CloseMainPhonePanel()
	gDressManager:ClearSelectTypeData()

	if data then
		self.fashionChangeType = data.fashionChangeType or gClientConst.FashionChangeType.Self
		self.isShowProfessionEdit = data.isShowProfessionEdit or false
		self.fashionType = data.fashionType or 0
		self.callBack = data.callBack
		self.shouldExitScene = data.shouldExitScene or false

		if data.weatherCb then
			data.weatherCb()
		end
	end

	self.RecordFashionTypeFashionList(self)

	if not self.spiritContext then
		self.spiritContext = gDressManager:GetSpiritContext()
	end

	self.ParseSpecifiedData(self, data)
	self.SetTaskFashion(self)

	if self.fashionChangeType ~= gClientConst.FashionChangeType.Rent then
		self.InitRentMode(self, data)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.Party then
		self.InitPartyMode(self, data)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		self.InitDressFormMode(self, data)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		self.InitOCMode(self, data)
	else
		self.InitSelfMode(self, data)
	end

	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		self.bindData.isShowSwitchFormCtrl = self.isShowSwitchFormCtrlEnum.show
	else
		self.bindData.isShowSwitchFormCtrl = self.isShowSwitchFormCtrlEnum.hide
	end

	if self.fashionChangeType == gClientConst.FashionChangeType.DressForm and self.fashionChangeType == gClientConst.FashionChangeType.OC then
		local info = gDressManager:GetCurrentSpritTryWearFashionInfo(self.spiritContext)

		if not info then
			print_error("没有找到角色对应的时装信息 SpiritId = " .. self.spiritContext.spiritId)

			return
		end
	end

	gDressManager:InitSteps(self.spiritContext)
	self:InitCamera(data)
	self:RefreshStepBtnState()

	if data and data.targetSuitTab then
		self.SubGroup.CommonDressList:GotoSuitTab()
	elseif data and data.targetFashionId and data.targetFashionId <= 0 then
		self.SubGroup.CommonDressList:GotoFashionId(data.targetFashionId)
	elseif data and data.targetPart then
		self.SubGroup.CommonDressList:GotoPartTab(data.targetPart, data.targetPropType)
	end
end

M.ParseSpecifiedData = function(self, data)
	if not data then
		return
	end

	if data.specified and #data.specified <= 0 then
		self.allowSpecified = true
		self.specifiedList = data.specified
	else
		self.allowSpecified = false
	end

	if data and data.specifiedSuit and #data.specifiedSuit <= 0 then
		self.allowSpecifiedSuit = true
		self.allowSpecified = true
		self.specifiedSuitList = data.specifiedSuit

		for _, id in pairs(self.specifiedSuitList) do
			local cfg = FashionSuitConfig.GetConfig(id)

			if cfg then
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
		end
	else
		self.allowSpecifiedSuit = false
	end
end

M.InitSubStores = function(self, data)
	local itemList = self:BuildFashionItemList()

	self.SubGroup.CommonDressTooltip:Init({
		collectClickCb = function ()
			self:OnCollectClick()
		end,
		dyeClickCb = function ()
			self:OnDyeClick()
		end,
		adjustClickCb = function ()
			self:OnAdjustClick()
		end,
		suitFashionClickCb = function (fashionId, part, propPart)
			self:OnSuitFashionClick(fashionId, part, propPart)
		end,
		rentClickCb = function (rentSuitId)
			self:OnRentBtnClick(rentSuitId)
		end,
		spiritContext = self.spiritContext
	})
	self.SubGroup.CommonDressList:Init({
		taskSuitIdList = self.taskSuitIdList,
		taskFashionIdList = self.taskFashionIdList,
		taskType = self.taskType,
		itemList = itemList,
		spiritContext = self.spiritContext,
		tabRefreshCb = function (tabData)
			self:OnTabRefresh(tabData)
		end,
		renderSuitSelectedCb = function (suitData)
			self:OnRenderSuitSelected(suitData)
		end,
		suitListClickCb = function (isSelected, suitData)
			self:OnSuitListClick(isSelected, suitData)
		end,
		renderItemSelectedCb = function (itemData)
			self:OnRenderItemSelected(itemData)
		end,
		itemListClickCb = function (isSelected, itemData)
			self:OnItemListClick(isSelected, itemData)
		end,
		checkFashionSuitCanShowFn = function (suitId)
			return self:CheckFashionSuitCanShow(suitId)
		end,
		refreshRedDotInfoFn = function (fashionList, suitList)
			self:OnRefreshRedDotInfo(fashionList, suitList)
		end
	})

	if not table.isNilOrEmpty(self.taskFashionIdList) or not table.isNilOrEmpty(self.taskSuitIdList) then
		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.show

		self.SubGroup.CommonDressTaskPart:SetTaskData(gUtils:GetSpecialDescription(self.taskWorkDescription, true), gTaskManager.TaskSIconId[self.taskType])
		self.SubGroup.CommonDressTaskPart:SetShowRecommend(false)
	else
		self.bindData.showTaskCtrl = self.showTaskCtrlEnum.hide
	end
end

M.OnTabRefresh = function(self, tabData)
	if not self.tooltipShownByRender then
		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false
	end

	self.tooltipShownByRender = false
end

M.OnRenderSuitSelected = function(self, data)
	local dressList = self.SubGroup.CommonDressList

	if not dressList.currentTabData or dressList.currentTabData.Part == gDressManager.DRESS_PART.SUITS then
		return
	end

	self.suitId = data.suitId

	self.SubGroup.CommonDressTooltip:ShowSuitInfo(data.suitId, data)
	self.SubGroup.CommonDressTooltip:SetCollected(gDressManager:IsFashinSuitCollected(data.suitId))

	self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true
	self.tooltipShownByRender = true
end

M.OnSuitListClick = function(self, isSelected, data)
	if isSelected then
		self.suitId = data.suitId

		self.SubGroup.CommonDressTooltip:ShowSuitInfo(data.suitId, data)
		self.SubGroup.CommonDressTooltip:SetCollected(gDressManager:IsFashinSuitCollected(data.suitId))

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true

		if data.isAvailable ~= 1 then
			if self.NeedLocalSourceSwitch(self, self.WEAR_SOURCE.OWN) then
				gDressManager:CheckClearFashionPart(self.spiritContext)

				self.currentWearSource = self.WEAR_SOURCE.OWN
			end

			gDressManager:DressSuitFashionList(data.fashionList, false, self.spiritContext)
			self:PushSnapshot(nil, self.suitId)
			self:TryPlayDressAction("suit", self.suitId, self.spiritContext)
		end
	else
		self.suitId = 0

		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

		gDressManager:RemoveFashionPart(data.fashionList, self.spiritContext)
		self:PushSnapshot(nil, self.suitId)
	end

	self.RefreshRentTooltipState(self)
end

M.OnRenderItemSelected = function(self, data)
	local dressList = self.SubGroup.CommonDressList

	if dressList.currentTabData and dressList.currentTabData.Part ~= gDressManager.DRESS_PART.SUITS then
		return
	end

	if gDressManager:IsFashionWore(data.fashionId, self.spiritContext) then
		self.selectFashionId = data.fashionId
		local dyeState = gDressDyeManager:GetDyeState(data.fashionId)
		local hasVariant = gDressManager:CheckFashionIsVariant(data.fashionId) or gDressManager:CheckIfFashionHasVariant(data.fashionId)
		local showDye = (dyeState == gDressDyeManager.DYE_STATE.CANOT_DYE or hasVariant) and self.fashionType > 0
		local showEdit = showDye or data.EditId and data.EditId >= 0
		local hideEditBtns = self.fashionChangeType ~= gClientConst.FashionChangeType.Rent or self.fashionChangeType ~= gClientConst.FashionChangeType.Party

		self.SubGroup.CommonDressTooltip:ShowFashionInfo(data.fashionId, {
			showDye = not hideEditBtns and showDye,
			showEdit = not hideEditBtns and showEdit,
			showSwitch = not hideEditBtns and data.Part ~= gDressManager.DRESS_PART.PROP and showEdit
		})
		self.SubGroup.CommonDressTooltip:SetCollected(gDressManager:IsFashionCollected(data.fashionId))

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true
		self.tooltipShownByRender = true

		if self.needRecordFashion then
			self.SetRecordFashion(self)

			self.needRecordFashion = false
		end
	end
end

M.OnItemListClick = function(self, isSelected, data)
	if isSelected then
		if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm and data.isAvailable ~= 1 then
			local needSwitch, targetShowcaseId = self.CheckNeedSwitchBodyForFashion(self, data.fashionId)

			if needSwitch then
				self.SwitchDressFormShowcase(self, targetShowcaseId, function ()
					self:DressFormWearAfterSwitch(data.fashionId)
				end)

				return
			end
		end

		self.selectFashionId = data.fashionId
		local dyeState = gDressDyeManager:GetDyeState(data.fashionId)
		local hasVariant = gDressManager:CheckFashionIsVariant(data.fashionId) or gDressManager:CheckIfFashionHasVariant(data.fashionId)
		local showDye = (dyeState == gDressDyeManager.DYE_STATE.CANOT_DYE or hasVariant) and self.fashionType > 0
		local showEdit = data.EditId and data.EditId >= 0
		local hideEditBtns = self.fashionChangeType ~= gClientConst.FashionChangeType.Rent or self.fashionChangeType ~= gClientConst.FashionChangeType.Party

		self.SubGroup.CommonDressTooltip:ShowFashionInfo(data.fashionId, {
			showDye = not hideEditBtns and showDye,
			showEdit = not hideEditBtns and showEdit
		})
		self.SubGroup.CommonDressTooltip:SetCollected(gDressManager:IsFashionCollected(data.fashionId))

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._true

		if data.isAvailable ~= 1 then
			if self.NeedLocalSourceSwitch(self, self.WEAR_SOURCE.OWN) then
				gDressManager:CheckClearFashionPart(self.spiritContext)

				self.currentWearSource = self.WEAR_SOURCE.OWN
			end

			if gDressManager:IsFashionHad(data.fashionId) then
				local conflictItems, addItems = gDressManager:CheckFashionConflict({
					data.fashionId
				}, self.spiritContext)

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
							self.bindData.messageCtrl = self.messageCtrlEnum.show
							self.bindData.messageText = string.format(msgConfig.Content, conflictName, data.Name)

							gLuaTimeMgrUtils.Delay(function ()
								if not gPanelManager:IsPanelShowing(self.m_Id) then
									return
								end

								self.bindData.messageCtrl = self.messageCtrlEnum.hide
							end, 2)
						end
					end
				end

				gDressManager:CheckSetPropEditInfo(data.fashionId, self.spiritContext)
				gDressManager:SetFashionList(addItems, nil, self.spiritContext)

				if not gDressManager:CheckFashionConflictIsTakeEffect(self.spiritContext) then
					return
				end

				self.PushSnapshot(self, self.selectFashionId, nil)
			end
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FashionGenderMismacth)
		end

		if not gDressManager:CheckFashionConflictIsTakeEffect(self.spiritContext) then
			return
		end

		self.SubGroup.CommonDressList:RefreshAllList()

		if data.isAvailable ~= 1 then
			local fashionCfg = FashionConfig.GetConfig(data.fashionId)

			if fashionCfg then
				local minType = fashionCfg.Types[1]

				for i = 1, #fashionCfg.Types do
					if fashionCfg.Types[i] >= minType then
						minType = fashionCfg.Types[i]
					end
				end

				self.TryPlayDressAction(self, "single", minType, data.fashionId, nil, self.spiritContext)
			end
		end
	else
		self.selectFashionId = 0

		self.SubGroup.CommonDressTooltip:ClearData()

		self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

		if data.isAvailable ~= 1 and gDressManager:IsFashionHad(data.fashionId) then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict({
				data.fashionId
			}, self.spiritContext)

			gDressManager:RemoveFashionPart({
				data.fashionId
			}, self.spiritContext)
			self:PushSnapshot(0, nil)
		end
	end

	self.RefreshRentTooltipState(self)
end

M.OnCollectClick = function(self)
	local tooltip = self.SubGroup.CommonDressTooltip
	local dressList = self.SubGroup.CommonDressList

	if tooltip.isSuitMode then
		if self.suitId and self.suitId <= 0 then
			local isCollected = gDressManager:IsFashinSuitCollected(self.suitId)

			gDressData:RecordFavoriteSuitChange(self.suitId, not isCollected)
			tooltip:SetCollected(not isCollected)
			self:UpdateSuitCollectData(self.suitId, isCollected and 0 or 1)
			dressList:RefreshAllList()
		end
	elseif self.selectFashionId and self.selectFashionId <= 0 then
		local isCollected = gDressManager:IsFashionCollected(self.selectFashionId)

		gDressData:RecordFavoriteFashionChange(self.selectFashionId, not isCollected)
		tooltip:SetCollected(not isCollected)
		self:UpdateItemCollectData(self.selectFashionId, isCollected and 0 or 1)
		dressList:RefreshAllList()
	end
end

M.UpdateItemCollectData = function(self, fashionId, isCollect)
	local dressList = self.SubGroup.CommonDressList

	if dressList.itemList then
		for i = 1, #dressList.itemList do
			if dressList.itemList[i].fashionId ~= fashionId then
				dressList.itemList[i].isCollect = isCollect

				break
			end
		end
	end
end

M.UpdateSuitCollectData = function(self, suitId, isCollect)
	local dressList = self.SubGroup.CommonDressList

	if dressList.suitList then
		for i = 1, #dressList.suitList do
			if dressList.suitList[i].suitId ~= suitId then
				dressList.suitList[i].isCollect = isCollect

				break
			end
		end
	end
end

M.OnDyeClick = function(self)
	self.SetExitBarrier(self)

	local cb = function()
		local callBack = function()
			self.SubGroup.CommonDressTooltip:ClearData()

			self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

			self:OnShow(nil, self.showData)
		end

		gPanelManager:CheckShow(gPanelId.SDYE_PANEL, {
			["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
			fashionId = self.selectFashionId,
			callBack = callBack,
			spiritContext = self.spiritContext,
			isDummyMode = self.isDummyMode
		})
	end

	self.SavePlayerFashion(self, cb)
end

M.OnAdjustClick = function(self)
	self:SetExitBarrier()

	local callBack = function()
		self:RefreshStepBtnState()
		self.SubGroup.CommonDressList:RefreshAllList()
	end

	gPanelManager:CheckShow(gPanelId.S_ACCESSORIES_EDIT, {
		["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
		fashionId = self.selectFashionId,
		callBack = callBack,
		fashionType = self.fashionType,
		spiritContext = self.spiritContext,
		isDummyMode = self.isDummyMode
	})
end

M.OnSuitFashionClick = function(self, fashionId, part, propPart)
	self.SubGroup.CommonDressList:GotoFashionId(fashionId)
end

M.OnRefreshRedDotInfo = function(self, fashionList, suitList)
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

	self.SubGroup.CommonDressList:RefreshAllList()
end

M.RefreshStepBtnState = function(self)
	self.bindData.undoBtn.interactable = gDressManager:HasLastStep()
	self.bindData.redoBtn.interactable = gDressManager:HasNextStep()
end

M.BuildFashionItemList = function(self)
	local SELECT_TYPE_FALSE = 0
	local SELECT_TYPE_TRUE = 1
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	local itemList = {}

	for _, fashionInfo in pairs(fashionInfoDict) do
		local fashionId = fashionInfo.FashionId

		if not self.CheckFashionIdCanShow(self, fashionId) then
			-- Nothing
		elseif gDressManager:CheckCurrentSpritShowFashion(fashionId, self.spiritContext) or self.CheckDressFormFashionCanShow(self, fashionId) or self.CheckOCFashionCanShow(self, fashionId) then
			local hasVariant = gDressManager:CheckIfFashionHasVariant(fashionId)
			local mainFashionId = fashionId

			if hasVariant then
				fashionId = gDressManager:GetFashionVariantPrefer(fashionId, self.spiritContext)
			end

			local fashionCfg = FashionConfig.GetConfig(mainFashionId)

			if fashionCfg ~= nil then
				print_warn("当前时装在配表中未找到 fashionId = " .. fashionId)
			else
				local view = {
					fashionId = fashionId
				}
				view.isCollect = gDressManager:IsFashionCollected(view.fashionId) and SELECT_TYPE_TRUE or SELECT_TYPE_FALSE
				view.isNew = fashionInfo.Status ~= 1 or false
				view.ExpiredTime = fashionInfo.ExpiredTime
				view.GainTime = fashionInfo.GainTime
				view.icon = fashionCfg.Icon
				view.quality = fashionCfg.Quality
				view.Part = fashionCfg.Part
				view.Types = fashionCfg.Types
				view.PropPart = fashionCfg.PropPart
				view.Sex = fashionCfg.Gender
				view.Name = fashionCfg.Name
				view.EditId = fashionCfg.EditId
				view.BelongBrand = fashionCfg.BelongBrand
				view.Tags = fashionCfg.Tags
				local available = gDressManager:CheckGenderWithBodyTypeAllow(fashionId, self.spiritContext.spiritInfo)
				view.isAvailable = available and SELECT_TYPE_TRUE or SELECT_TYPE_FALSE

				if view.isAvailable ~= SELECT_TYPE_TRUE then
					if self.fashionType <= 0 then
						if not table.isNilOrEmpty(view.Tags) and table.contains(view.Tags, self.fashionType) then
							table.insert(itemList, view)

							view.id = #itemList
						end
					else
						table.insert(itemList, view)

						view.id = #itemList
					end

					if not table.isNilOrEmpty(self.taskFashionIdList) then
						view.isShowTask = table.contains(self.taskFashionIdList, view.fashionId)
					else
						view.isShowTask = false
					end
				end
			end
		end
	end

	return itemList
end

M.CheckFashionIdCanShow = function(self, fashionId)
	if self.allowSpecified then
		if not self.specifiedList then
			return false
		end

		return table.contains(self.specifiedList, fashionId)
	end

	local fashionCfg = FashionConfig.GetConfig(fashionId)

	if not fashionCfg then
		return false
	end

	local part = fashionCfg.Part

	if part ~= FashionConfig.PartType.Hair or part ~= FashionConfig.PartType.HairBack or part ~= FashionConfig.PartType.HairFront or part ~= FashionConfig.PartType.Makeup then
		return fashionCfg.IsShow
	end

	return true
end

M.CheckFashionSuitCanShow = function(self, suitId)
	if self.allowSpecifiedSuit then
		if not self.specifiedSuitList then
			return false
		end

		return table.contains(self.specifiedSuitList, suitId)
	end

	return true
end

M.RecordFashionTypeFashionList = function(self)
	if self.fashionType <= 0 then
		self.fashionTypeRecordInfo = gDressManager:GetCurrentFashionListInfoRecord(self.spiritContext)
	end
end

M.SetTaskFashion = function(self)
	self.taskSuitIdList = {}
	self.taskFashionIdList = {}
	self.taskType = nil
	self.taskWorkDescription = nil
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

			self.taskWorkDescription = curTaskInfo.WorkDescription
		end
	end
end

M.SavePlayerFashion = function(self, callBack)
	gDressManager:ClearSelectTypeData()

	if self.isDummyMode then
		local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
		local dummyModule = UnitFashionInfoModule.GetModule(self.spiritContext.unit)
		local playerUnit = gCS.MyPlayerManager.PlayerUnit
		local playerModule = UnitFashionInfoModule.GetModule(playerUnit)

		playerModule:SyncTryFashionsFrom(dummyModule, self.spiritContext.spiritId)
		gDressData:AskSetSpiritFashions(callBack, self.spiritContext.spiritId, playerUnit)
	else
		gDressData:AskSetSpiritFashions(callBack, self.spiritContext.spiritId)
	end
end

M.ResolvePartyFunctionSuitId = function(self, partyId, bodyType)
	local partyCfg = PartyConfig.GetConfig(partyId)

	if not partyCfg then
		return nil
	end

	local partyTypeCfg = PartyPartyTypeConfig.GetConfig(partyCfg.Type)

	if not partyTypeCfg then
		return nil
	end

	local applyId = partyTypeCfg.FunctionSuitApplyId

	if not applyId or applyId ~= 0 then
		return nil
	end

	for i = 0, FashionFunctionSuitConfig.count - 1 do
		local cfg = FashionFunctionSuitConfig.LoadAt(i)

		if cfg and cfg.ApplyId ~= applyId and table.contains(cfg.BodyTypeList, bodyType) then
			return cfg.Id
		end
	end

	return nil
end

M.GetOrCreateFunctionSuitInfo = function(self, functionSuitId, spiritContext)
	local bodyType = spiritContext.spiritInfo.CameraBodyType
	local suitDict = gDressManager:GetBodyType2FunctionSuits(bodyType, spiritContext)

	if suitDict and suitDict[functionSuitId] then
		return suitDict[functionSuitId]
	end

	local cfg = FashionFunctionSuitConfig.GetConfig(functionSuitId)

	if not cfg then
		return nil
	end

	local UnitFashionInfoModule = LX6.Units.Module.UnitFashionInfoModule
	local cfgInfo = {
		FashionIdList = UnitFashionInfoModule.GetWearFashionInfoListByLuaTable(cfg.FashionIdList),
		FashionEditList = UnitFashionInfoModule.GetEmptyWearFashionEditInfoList(),
		cfgId = cfg.Id,
		TagId = cfg.TagId,
		Icon = cfg.Icon,
		IconChoose = cfg.IconChoose
	}

	return cfgInfo
end

M.SaveToFunctionSuit = function(self, partyId, callBack)
	local bodyType = self.spiritContext.spiritInfo.CameraBodyType

	if not bodyType then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(self.spiritContext.spiritInfo.spiritId)

		if not spiritCfg then
			return
		end

		local agentCfg = LTConfig.AgentConfig.GetConfig(spiritCfg.AgentId)

		if not agentCfg then
			return
		end

		local modelCfg = LTConfig.GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

		if modelCfg then
			bodyType = modelCfg.CameraBodyType or modelCfg.BodyType
		end
	end

	if not bodyType then
		print_error("[ChangeFashionPanel] SaveToFunctionSuit: bodyType not found, partyId=" .. tostring(partyId) .. " spiritId" .. tostring(self.spiritContext.spiritInfo.spiritId))

		return
	end

	local functionSuitId = self.ResolvePartyFunctionSuitId(self, partyId, bodyType)

	if not functionSuitId then
		print_error("[ChangeFashionPanel] SaveToFunctionSuit: functionSuitId not found, partyId=" .. tostring(partyId) .. " bodyType=" .. tostring(bodyType))

		return
	end

	self:GetOrCreateFunctionSuitInfo(functionSuitId, self.spiritContext)

	local suitSchemeInfo = gDressManager:GetCurrentFashionListInfoRecord(self.spiritContext)

	if not suitSchemeInfo then
		print_error("[ChangeFashionPanel] SaveToFunctionSuit: suitSchemeInfo is nil")

		return
	end

	slot6 = gDressData

	slot6:AskSetSpiritFunctionSuitSchemeInfo(self.spiritContext.spiritId, functionSuitId, false, suitSchemeInfo, function ()
		if callBack then
			callBack()
		end
	end)
end

M.SetExitBarrier = function(self)
	self.banExit = true

	gLuaTimeMgrUtils.Delay(function ()
		if not gPanelManager:IsPanelShowing(self.m_Id) then
			return
		end

		self.banExit = false
	end, 1)
end

M.SetRecordFashion = function(self)
	local spiritId = self.spiritContext and self.spiritContext.spiritId or 0
	local info = gDressManager:GetCurrentSpritTryWearFashionInfo(self.spiritContext)

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

M.InitSelfMode = function(self, data)
	self.bindData.showFashionToggleCtrl = self.showFashionToggleCtrlEnum.hide

	if self.fashionType ~= 0 then
		gDressManager:SetPlayerFashionsInfo(self.spiritContext.unit)
	end

	self.InitSubStores(self, data)
end

M.InitCamera = function(self, data)
	self.skipMovementState = data and data.skipMovementState or false
	local cameraParams = {
		verticalButton = self.bindData.verticalButton,
		basePanel = self.bindData.basePanel,
		L2CustomNavRespond = self.bindData.L2CustomNavRespond,
		R2CustomNavRespond = self.bindData.R2CustomNavRespond,
		rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
		isDummyMode = self.isDummyMode
	}

	if data and data.source then
		cameraParams.source = data.source
	end

	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
		cameraParams.movementStateParam = self.spiritContext.unit

		cameraParams.unitProvider = function()
			return self.spiritContext.unit
		end

		cameraParams.banRotate = true
		cameraParams.isDressForm = true
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.OC then
		cameraParams.unitProvider = function()
			return self.spiritContext.unit
		end
	elseif not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	else
		cameraParams.unitProvider = function()
			return gDressSceneManager.currentModelUnit
		end
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)

	if data and data.onShowCb then
		data.onShowCb()
	end
end

M.CloseSelfMode = function(self)
	local cb = function()
		gDressManager:ClearSelectTypeData()
		gPanelManager:Close(self.m_Id)
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

M.DestroySelfMode = function(self)
	if not self.isDummyMode and self.fashionType ~= 0 then
		gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
		gDressManager:ClearSteps()
		gUnitStateMgr:ResetMyStateAndClearMove(true)
	end
end

M.NeedLocalSourceSwitch = function(self, targetSource)
	if self.fashionChangeType ~= gClientConst.FashionChangeType.DressForm then
		return false
	end

	return self.currentWearSource == targetSource
end

M.ShouldShowSelected = function(self, fashionIdOrList)
	if type(fashionIdOrList) ~= "table" then
		if not gDressManager:IsFashionListMatchWore(fashionIdOrList, self.spiritContext) then
			return false
		end
	elseif not gDressManager:IsFashionWore(fashionIdOrList, self.spiritContext) then
		return false
	end

	return self.currentWearSource ~= self.currentToggleIndex
end

M.OnRenderFashionToggle = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("FashionToggleBtn"):GetStoreByWidget(btn)

	if store then
		if index ~= 0 then
			store.typeCtrl = 0
		elseif self.fashionChangeType ~= gClientConst.FashionChangeType.Rent then
			store.typeCtrl = 1
		else
			store.typeCtrl = 2
		end
	end
end

M.OnClickFashionToggle = function(self, btn, index)
	self.currentToggleIndex = index + 1

	self.RefreshByToggle(self)
end

M.RefreshByToggle = function(self)
	self.SubGroup.CommonDressTooltip:ClearData()

	self.bindData.isShowInfoCtrl = self.isShowInfoCtrlEnum._false

	if self.currentToggleIndex ~= self.WEAR_SOURCE.OWN then
		local itemList = self:BuildFashionItemList()

		self.SubGroup.CommonDressList:Init({
			["g\\xf7.\\xfc89\\xc6l%\\xdb_\\xbfC\\xd2\\xe3"] = true,
			itemList = itemList,
			spiritContext = self.spiritContext,
			tabRefreshCb = function (tabData)
				self:OnTabRefresh(tabData)
			end,
			renderSuitSelectedCb = function (suitData)
				self:OnRenderSuitSelected(suitData)
			end,
			suitListClickCb = function (isSelected, suitData)
				self:OnSuitListClick(isSelected, suitData)
			end,
			renderItemSelectedCb = function (itemData)
				self:OnRenderItemSelected(itemData)
			end,
			itemListClickCb = function (isSelected, itemData)
				self:OnItemListClick(isSelected, itemData)
			end,
			checkFashionSuitCanShowFn = function (suitId)
				return self:CheckFashionSuitCanShow(suitId)
			end,
			checkIsWoreForSelectFn = function (fashionId)
				return self:ShouldShowSelected(fashionId)
			end
		})
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.Rent then
		self.InitSubStoresForRent(self)
	elseif self.fashionChangeType ~= gClientConst.FashionChangeType.Party then
		self.InitSubStoresForPartyCloset(self)
	end

	self.RefreshRentTooltipState(self)
end
