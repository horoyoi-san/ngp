local FashionConfig = LTConfig.FashionConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local MessageConfig = LTConfig.MessageConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local RedDotMgr = SGUI.RedDotMgr
C_CommonChangeDressPanelStore = DefClass("C_CommonChangeDressPanelStore", C_CommonChangeDressPanelStore, C_StoreGroup)
GroupName2Class.CommonChangeDressPanelStore = C_CommonChangeDressPanelStore
local M = C_CommonChangeDressPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.countFinish = false
	self.callBack = nil
	self.suitFashionItemList = nil
	self.itemListByPart = nil
	self.suitList = nil
	self.isShowProfessionEdit = false
	self.fashionType = 0
	self.tabList = {}
	self.tabTopList = {}
	self.itemList = {}
	self.suitList = {}
	self.suitFashionRightList = {}
	self.tagList = {}
	self.tabTopIndex = 1
	self.touchMoveLimit = 15
	self.selectFashionId = 0
	self.suitFashionItemList = {}
	self.itemListByPart = {}
	self.sortLargeToSmall = true
	self.selectedSortItemId = self.SELECTOR_SORT_TYPE.QUALITY
	self.needRecordFashion = true
	self.finishTabLayOut = false
	self.gotoIndexFashionId = 0
	self.recordItems = {}
end

function M:OnAwake()
	self:InitEnumData()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
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
	end
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	gDressManager.SelectType.collect = {}
	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}
	gDressManager.SelectType.tag = {}

	self.SubGroup.DropMenuTemplateStore:SetFilterMenuState(false)

	self.isShowProfessionEdit = data and data.isShowProfessionEdit or false
	self.fashionType = data and data.fashionType or 0
	self.callBack = data and data.callBack
	self.bindData.title = data and data.title or FashionConfig.FashionChangeTitle

	self:InitInfo()
	self:RecordFashionTypeFashionList()
end

function M:OnClose()
	return
end

function M:GenMessageEvents()
	self.msgEvents = {
		[gEventConstants.RESET_PLAYER_FASHION_DATA] = self:CreateAction("ResetPlayerFashionData")
	}
end

function M:ResetPlayerFashionData(eventId, data)
	gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList = {}

	for i = 1, data.Length do
		if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i]) then
			gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i] = {}
		end

		gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList[i].FashionId = data[i - 1]
	end
end

function M:RegisterWidget()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.collectBtn.luaClick = self:CreateAction("OnCollectBtnClick")
	self.bindData.refreshBtn.luaClick = self:CreateAction("OnRefreshBtnClick")
	self.bindData.foldBtn.luaClick = self:CreateAction("OnFoldBtnClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabListItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnSelectTab")
	self.bindData.tabList.luaLayoutSet = self:CreateAction("OnTabFinish")
	self.bindData.tabTopList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTabTopListItem")
	self.bindData.tabTopList.luaSelectedChanged = self:CreateAction("OnSelectTabTop")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderItemListItem")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnSimpleClickItemList")
	self.bindData.suitList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderSuitListItem")
	self.bindData.suitList.luaSimpleClick = self:CreateAction("OnSimpleClickSuitList")
	self.bindData.suitFashionList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderSuitFashionListItem")
	self.bindData.suitFashionList.luaSimpleClick = self:CreateAction("OnSimpleClickSuitFashionList")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderTagListItem")
end

function M:OnBackBtnClick()
	local function cb()
		gDressManager.SelectType.collect = {}
		gDressManager.SelectType.approach = {}
		gDressManager.SelectType.brand = {}
		gDressManager.SelectType.tag = {}

		gPanelManager:Close(gPanelId.S_COMMON_CHANGE_DRESS_PANEL)
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

function M:OnFoldBtnClick()
	if self.bindData.isInfoFold == 1 then
		self.bindData.isInfoFold = 0
	else
		self.bindData.isInfoFold = 1
	end
end

function M:OnSimpleRenderItemListItem(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplareStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "FashionItemRedDot.pageList:" .. data.id)

		store.icon = data.icon
		store.quality = data.quality
		store.isAvailable = data.isAvailable
		store.dyeType = gDressDyeManager:GetDyeState(data.fashionId)
		store.isCollect = data.isCollect
		btn.isSelected = gDressManager:IsTempWearFashionList({
			data.fashionId
		})

		if btn.isSelected then
			if store.dyeType ~= gDressDyeManager.DYE_STATE.CANOT_DYE and self.fashionType <= 0 then
				self.bindData.showdye = self.SELECT_TYPE.TRUE
			end

			if self.bindData.isShowInfo == self.SELECT_TYPE.FALSE then
				self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

				self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")
			end

			self.bindData.isShowEdit = (data.EditId and data.EditId > 0 or store.dyeType ~= gDressDyeManager.DYE_STATE.CANOT_DYE) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			local fashionCfg = FashionConfig.GetConfig(data.fashionId)

			if fashionCfg then
				self.bindData.isSelect = self.SELECT_TYPE.TRUE
				self.bindData.currentDressName = fashionCfg.Name

				self:SetFashionTagInfo(data.fashionId)
				self:SetDressScroll(fashionCfg.Description)

				local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

				if brandCfg then
					self.bindData.currentDressIcon = brandCfg.BrandLogo
					self.bindData.brandBanner = brandCfg.BrandBG
				end

				self.selectFashionId = data.fashionId
				self.bindData.isCollected = gDressManager:IsFashinCollected(data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

				if self.needRecordFashion then
					self:SetRecordFashion()

					self.needRecordFashion = false
				end
			end
		end

		if not table.isNilOrEmpty(self.taskFashionIdList) then
			store.isShowTask = table.contains(self.taskFashionIdList, data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

			if store.isShowTask then
				store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			end
		else
			store.isShowTask = self.SELECT_TYPE.FALSE
		end

		local conflictItems, addItems = gDressManager:CheckFashionConflict({
			data.fashionId
		})

		table.insert(addItems, data.fashionId)

		if not table.isNilOrEmpty(conflictItems) then
			local isSamePart = true

			for i = 1, #conflictItems do
				local cfg = FashionConfig.GetConfig(conflictItems[i])

				if cfg and cfg.Part ~= data.Part and not cfg.IsDefaultUnderwear and cfg.IsShow then
					isSamePart = false
				end
			end

			store.isAvailable = isSamePart and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		end

		if self.selectFashionId > 0 and gDressManager:IsSamePart(self.selectFashionId, data.fashionId) then
			store.isAvailable = self.SELECT_TYPE.TRUE
		end
	end
end

function M:OnSelectTab(data)
	self.tabIndex = data.selectedIndex + 1
	local tabData = self.tabList[self.tabIndex]

	if tabData then
		self:OnChangeTab(nil, tabData)
	end
end

function M:OnTabFinish()
	self.finishTabLayOut = true
end

function M:OnSimpleRenderSuitListItem(btn, index)
	local data = self.suitList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplareSuitStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "FashionItemRedDot.pageSuitList:" .. data.id)

		store.icon = data.icon
		store.iconBg = data.iconBg
		store.quality = data.quality
		store.isAvailable = data.isAvailable
		store.isCollect = data.isCollect
		btn.isSelected = gDressManager:IsTempWearFashionList(data.fashionList)

		if self.taskSuitId and self.taskSuitId > 0 then
			store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			store.isShowTask = data.suitId == self.taskSuitId and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		else
			store.isShowTask = self.SELECT_TYPE.FALSE
		end

		if btn.isSelected then
			self.suitId = data.suitId
			self.bindData.isCollected = data.isCollect

			self:SelectSuitInfo(data)

			if data.isNew then
				local redDotSuitList = {}

				table.insert(redDotSuitList, data.suitId)
				gDressData:AskReadFashionSuits(redDotSuitList, function ()
					RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageSuitList:" .. data.id)
					self:RefreshRedDotInfo(nil, redDotSuitList)
				end)
			end
		end
	end
end

function M:OnSimpleClickSuitList(btn, index)
	local data = self.suitList[index + 1]

	if btn.isSelected then
		if data.isNew then
			local redDotSuitList = {}

			table.insert(redDotSuitList, data.suitId)
			gDressData:AskReadFashionSuits(redDotSuitList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageSuitList:" .. data.id)
				self:RefreshRedDotInfo(nil, redDotSuitList)
			end)
		end

		self.bindData.isShowInfo = self.SELECT_TYPE.TRUE

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.suitId = data.suitId
		self.bindData.isCollected = gDressManager:IsFashinSuitCollected(self.suitId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		self:SelectSuitInfo(data)

		if data.isAvailable == self.SELECT_TYPE.TRUE then
			gDressManager:DressSuitFashionList(data.fashionList, true, false, true)
		end
	else
		self.suitId = 0
		self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
		self.bindData.isCollected = self.SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self:SetDressScroll()

		local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict(data.fashionList)

		for i = 1, #data.fashionList do
			if not table.contains(conflictItems, data.fashionList[i]) then
				table.insert(conflictItems, data.fashionList[i])
			end
		end

		gDressManager:ChangeFashionPart(addItems, conflictItems)
		gDressManager:RemoveFashionPart(data.fashionList)
	end
end

function M:OnSimpleRenderTabListItem(btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("ClothingTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.IconId

		if btn.isSelected then
			if data.Part == gDressManager.DRESS_PART.SUITS then
				self.bindData.partCount = table.count(self.suitList)
			else
				self.bindData.partCount = table.isNilOrEmpty(self.itemListByPart[data.Part]) and 0 or #self.itemListByPart[data.Part]
			end

			self.bindData.partDes = data.PartName
		end
	end
end

function M:OnSimpleRenderSuitFashionListItem(btn, index)
	local data = self.suitFashionRightList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplarePreviewStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.quality = data.quality
		store.isLock = data.isLock and self.SELECT_TYPE.FALSE or self.SELECT_TYPE.TRUE
	end
end

function M:OnSimpleClickSuitFashionList(btn, index)
	local data = self.suitFashionRightList[index + 1]

	if not self.itemListByPart[data.Part] then
		return
	end

	for i = 1, #self.itemListByPart[data.Part] do
		if self.itemListByPart[data.Part][i].fashionId == data.fashionId then
			for t = 1, #self.tabList do
				if self.tabList[t].Part == data.Part then
					self.gotoIndexFashionId = data.fashionId

					self.bindData.tabList:SelectItem(self.tabList[t].tabIndex - 1, true)

					if data.Part == gDressManager.DRESS_PART.PROP then
						for m = 1, #self.tabTopList do
							if table.contains(data.Types, self.tabTopList[m].Type) then
								self.bindData.tabTopList:SelectItem(m - 1, true)
							end
						end
					end

					return
				end
			end
		end
	end
end

function M:OnSimpleRenderTabTopListItem(btn, index)
	local data = self.tabTopList[index + 1]
	local store = gStoreManager:GetStoreGroup("ClothingTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.IconId

		if self.tabIndex == #self.tabList then
			btn.isSelected = data.tabTopIndex == self.tabTopIndex
		end

		if btn.isSelected then
			if data.Part == gDressManager.DRESS_PART.SUITS then
				self.bindData.partCount = table.count(self.suitList)
			else
				self.bindData.partCount = table.isNilOrEmpty(self.itemListByPart[data.Part]) and 0 or #self.itemListByPart[data.Part]
			end

			self.bindData.partDes = data.PartName
		end
	end
end

function M:OnSimpleClickItemList(btn, index)
	local data = self.itemList[index + 1]

	if btn.isSelected then
		if data.isNew then
			local redDotFashionList = {}

			table.insert(redDotFashionList, data.fashionId)
			gDressData:AskReadFashions(redDotFashionList, function ()
				RedDotMgr.LuaSetRedDot(false, "FashionItemRedDot.pageList:" .. data.id)
				self:RefreshRedDotInfo(redDotFashionList)
			end)
		end

		self.bindData.isShowEdit = data.EditId and data.EditId > 0 and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE

		if self.bindData.isShowInfo == self.SELECT_TYPE.FALSE then
			self.bindData.isShowInfo = self.SELECT_TYPE.TRUE
		end

		self.bindData.tipAnim:Play("S_Vx_ChangeDressPanel_bottomRight")

		self.selectFashionId = data.fashionId
		self.bindData.isCollected = gDressManager:IsFashinCollected(data.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

			if brandCfg then
				self.bindData.currentDressIcon = brandCfg.BrandLogo
				self.bindData.brandBanner = brandCfg.BrandBG
			end

			self.bindData.currentDressName = fashionCfg.Name

			self:SetFashionTagInfo(data.fashionId)
			self:SetDressScroll(fashionCfg.Description)
		end

		if data.Part == gDressManager.DRESS_PART.PROP then
			self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		end

		if data.isAvailable == self.SELECT_TYPE.TRUE then
			if gDressManager:IsFashionHaved(data.fashionId) then
				local conflictItems, addItems = gDressManager:CheckFashionConflict({
					data.fashionId
				})

				table.insert(addItems, data.fashionId)

				if not table.isNilOrEmpty(conflictItems) then
					local isSamePart = true
					local conflictName = ""

					for i = 1, #conflictItems do
						local cfg = FashionConfig.GetConfig(conflictItems[i])

						if cfg and cfg.Part ~= data.Part and not cfg.IsDefaultUnderwear and cfg.IsShow then
							isSamePart = false

							if conflictName == "" then
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

				gDressManager:CheckHasPropEdit(data.fashionId)
				gDressManager:CheckMyOotdHiddenPart(data.fashionId)
				gDressManager:SetFashionList(addItems)

				if not gDressManager:CheckFashionConflictIsTakeEffect() then
					return
				end

				gDressManager:ChangeFashionPart(addItems, conflictItems)
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

		self:SetDressScroll()

		self.bindData.redoBtnState = 1

		if data.isAvailable == self.SELECT_TYPE.TRUE and gDressManager:IsFashionHaved(data.fashionId) then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict({
				data.fashionId
			})

			if not table.contains(conflictItems, data.fashionId) then
				table.insert(conflictItems, data.fashionId)
			end

			gDressManager:ChangeFashionPart(addItems, conflictItems)
			gDressManager:RemoveFashionPart({
				data.fashionId
			})
		end
	end

	if data.isAvailable == self.SELECT_TYPE.TRUE then
		local fashionCfg = FashionConfig.GetConfig(data.fashionId)

		if fashionCfg then
			local minType = fashionCfg.Types[1]

			for i = 1, #fashionCfg.Types do
				if fashionCfg.Types[i] < minType then
					minType = fashionCfg.Types[i]
				end
			end

			gDressManager:PlayDressAction(minType)
		end
	end

	self.bindData.isShowSetting = gDressManager.showHiddenPart and 0 or 1
end

function M:OnSelectTabTop(data)
	self.tabTopIndex = data.selectedIndex + 1
	local tabTopData = self.tabTopList[self.tabTopIndex]

	if tabTopData then
		self:OnChangeTabTop(nil, tabTopData)
	end
end

function M:OnSimpleRenderTagListItem(btn, index)
	local data = self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
end

function M:InitInfo()
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

	self.bindData.type = self.OPEN_TYPE.SUIT
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.isSelect = 0
	self.bindData.partDes = ""
	self.bindData.partCount = 0
	self.bindData.hidePanel = 1

	gDressManager:PlayDressDefaultAction()
	self:OnShow_Item()
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
end

function M:SetDressScroll(str)
	self.bindData.des = str
end

function M:OnShow_Item()
	self:InitFashionItemList()
	self:InitTabList()
	self:InitTabTopList()
	self:InitFashionSuitList()
	self:InitSelectorList()
end

function M:InitTabList()
	self.tabList = {}
	local FashionChangeTabIcon = FashionConfig.FashionChangeTabIcon
	local FashionChangeTabName = FashionConfig.FashionChangeTabName

	for i = 1, #FashionChangeTabIcon do
		local view = {
			depth = 1,
			Part = FashionChangeTabIcon[i].part,
			id = #self.tabList + 1,
			tabIndex = i,
			IconId = FashionChangeTabIcon[i].IconId,
			PartName = FashionChangeTabName[i].Name
		}

		table.insert(self.tabList, view)
	end

	self.tabIndex = self:GetTabIndex()

	self.bindData.tabList:SetSimpleList(#self.tabList)
	self.bindData.tabList:SelectItem(self.tabIndex - 1)
	self.bindData.tabList:SetNavSelectToSelect(true)
end

function M:GetTabIndex()
	local tabIndex = 1
	local spriteFashionInfo = gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId]

	print(" 换装界面默认tab为当前上衣（type=1）的item所在的tab")

	if self.taskSuitId and self.taskSuitId > 0 then
		for j = 1, #self.tabList do
			if self.tabList[j].Part == gDressManager.DRESS_PART.SUITS then
				tabIndex = self.tabList[j].tabIndex

				return tabIndex
			end
		end
	end

	if spriteFashionInfo and spriteFashionInfo.WearFashionInfoList then
		for i = 1, #spriteFashionInfo.WearFashionInfoList do
			local fashionId = spriteFashionInfo.WearFashionInfoList[i].FashionId
			local cfg = FashionConfig.GetConfig(fashionId)

			if cfg then
				if cfg.Part == gDressManager.DRESS_PART.TOPS then
					for j = 1, #self.tabList do
						if self.tabList[j].Part == gDressManager.DRESS_PART.TOPS then
							tabIndex = self.tabList[j].tabIndex

							return tabIndex
						end
					end
				elseif cfg.Part == gDressManager.DRESS_PART.BODY_SUIT then
					for j = 1, #self.tabList do
						if self.tabList[j].Part == gDressManager.DRESS_PART.BODY_SUIT then
							tabIndex = self.tabList[j].tabIndex

							return tabIndex
						end
					end
				end
			end
		end
	end

	return tabIndex
end

function M:InitTabTopList()
	self.tabTopList = {}
	local FashionPropTabIcon = FashionConfig.FashionPropTabIcon
	local FashionPropTabName = FashionConfig.FashionPropTabName

	for t = 1, #FashionPropTabIcon do
		local view = {
			depth = 2,
			Part = gDressManager.DRESS_PART.PROP,
			IconId = FashionPropTabIcon[t].IconId,
			PartName = FashionPropTabName[t].Name,
			Type = FashionPropTabIcon[t].type,
			tabTopIndex = t
		}

		table.insert(self.tabTopList, view)
	end

	self.bindData.tabTopList:SetSimpleList(#self.tabTopList)
end

function M:InitFashionItemList()
	self.selectPlayerSex = gDressManager.CurrentSpiritInfo.Sex
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict
	self.itemList = {}
	self.itemListByPart = {}

	for _, fashionInfo in pairs(fashionInfoDict) do
		local fashionId = fashionInfo.FashionId

		if gDressManager:CheckCurrentSpritShowFashion(fashionId) then
			local fashionCfg = FashionConfig.GetConfig(fashionId)

			if fashionCfg == nil then
				print_warn("当前时装在配表中未找到,时装id来源于服务器PlayerFashionsInfo.FashionInfoDict  fashionId = " .. fashionId)
			end

			local view = {
				fashionId = fashionId
			}
			view.isCollect = gDressManager:IsFashinCollected(view.fashionId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
			view.isNew = fashionInfo.Status == 1 or false
			view.ExpiredTime = fashionInfo.ExpiredTime
			view.GainTime = fashionInfo.GainTime

			if fashionCfg then
				view.icon = fashionCfg.Icon
				view.quality = fashionCfg.Quality
				view.Part = fashionCfg.Part
				view.Types = fashionCfg.Types
				view.Sex = fashionCfg.Gender
				view.Name = fashionCfg.Name
				view.EditId = fashionCfg.EditId
				view.BelongBrand = fashionCfg.BelongBrand
				view.Coloring = gDressDyeManager.ConvertToColoringType(fashionCfg.Coloring)
				view.isAvailable = (self.selectPlayerSex == fashionCfg.Gender or fashionCfg.Gender == 0) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
				view.Tags = fashionCfg.Tags

				if table.isNilOrEmpty(self.itemListByPart[view.Part]) then
					self.itemListByPart[view.Part] = {}
				end

				if view.isAvailable == self.SELECT_TYPE.TRUE then
					if self.fashionType > 0 then
						if not table.isNilOrEmpty(view.Tags) and table.contains(view.Tags, self.fashionType) then
							table.insert(self.itemListByPart[view.Part], view)
							table.insert(self.itemList, view)
						end
					else
						table.insert(self.itemListByPart[view.Part], view)
						table.insert(self.itemList, view)
					end

					view.id = #self.itemList
				end
			end
		end
	end
end

function M:InitFashionSuitList()
	self.suitFashionItemList = {}

	for i = 1, #self.itemList do
		local view = table.clone(self.itemList[i])
		view.suitIds = gDressManager:GetSuitIdByFashionId(view.fashionId)

		for t = 1, #view.suitIds do
			local suitId = view.suitIds[t]

			if self.suitFashionItemList[suitId] == nil then
				self.suitFashionItemList[suitId] = {}
			end

			table.insert(self.suitFashionItemList[suitId], view)
		end
	end

	self.suitList = {}

	for suitId, fashionList in pairs(self.suitFashionItemList) do
		local view = {
			suitId = suitId
		}
		local cfg = FashionSuitConfig.GetConfig(view.suitId)

		if cfg and cfg.IsShow then
			view.icon = cfg.Icon
			view.haveFashionCount = #fashionList
			view.fashionList = cfg.FashionIdList
			local isAvailable = self.SELECT_TYPE.TRUE

			for t = 1, #fashionList do
				if fashionList[t].isAvailable == self.SELECT_TYPE.FALSE and isAvailable == self.SELECT_TYPE.TRUE then
					isAvailable = self.SELECT_TYPE.FALSE
				end

				if view.GainTime == nil then
					view.GainTime = 0
				end

				view.GainTime = math.max(view.GainTime, fashionList[t].GainTime)
			end

			view.quality = fashionList[1].quality
			local fashionCfg = FashionConfig.GetConfig(cfg.FashionIdList[1])

			if fashionCfg then
				local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

				if brandCfg then
					view.iconBg = brandCfg.SuitBG
				end
			end

			local gender = self.GENDER.UNKNOWN

			for t = 1, #cfg.FashionIdList do
				local fashionCfg = FashionConfig.GetConfig(cfg.FashionIdList[t])

				if fashionCfg and gender == self.GENDER.UNKNOWN and fashionCfg.Gender ~= self.GENDER.UNKNOWN then
					gender = fashionCfg.Gender
				end
			end

			if gender == self.selectPlayerSex or gender == self.GENDER.UNKNOWN then
				view.isAvailable = isAvailable
				view.Sex = gender
				view.Part = gDressManager.DRESS_PART.SUITS
				view.isCollect = gDressManager:IsFashinSuitCollected(view.suitId) and self.SELECT_TYPE.TRUE or self.SELECT_TYPE.FALSE
				view.totalFashionCount = #cfg.FashionIdList
				view.isNew = gDressManager:IsFashionListHasRedDotNew(cfg.FashionIdList)

				if view.totalFashionCount > 0 and view.totalFashionCount == view.haveFashionCount then
					table.insert(self.suitList, view)

					view.id = #self.suitList
				end
			end
		end
	end

	self.suitList = self:FilterItems(self.suitList)

	self.bindData.suitList:SetSimpleList(#self.suitList)
	self.bindData.suitList:PlayStartOffsetAnim()
end

function M:InitSuitFashionRightList()
	if self.suitId == nil or self.suitId == 0 then
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
				view.isLock = gDressManager:IsFashionHaved(view.fashionId)
				view.Types = fashionCfg.Types
			end

			if self.selectPlayerSex == fashionCfg.Gender or fashionCfg.Gender == 0 and cfg.IsShow then
				table.insert(self.suitFashionRightList, view)
			else
				print_error("@hzliuyibing 当前配置套装内的时装与角色性别不一致，请联系策划检查配置，suitId = " .. self.suitId .. "  fashionId = " .. view.fashionId)
			end
		end
	end

	self.bindData.suitFashionList:SetSimpleList(#self.suitFashionRightList)
end

function M:FilterItems(itemList)
	local items = {}

	if table.isNilOrEmpty(itemList) then
		return items
	end

	local tag = gDressManager.SelectType.tag
	local collect = gDressManager.SelectType.collect
	local approach = gDressManager.SelectType.approach
	local brand = gDressManager.SelectType.brand

	if table.isNilOrEmpty(collect) and table.isNilOrEmpty(approach) and table.isNilOrEmpty(brand) and table.isNilOrEmpty(tag) then
		if not table.isNilOrEmpty(itemList) then
			self:SortItemList(itemList)
		end

		return itemList
	end

	local tempCollectType = self.COLLECT_TYPE.ALL

	if table.count(collect) == 1 then
		if table.contains(collect, self.COLLECT_TYPE.HAS_COLLECT) then
			tempCollectType = self.COLLECT_TYPE.HAS_COLLECT
		else
			tempCollectType = self.COLLECT_TYPE.NO_COLLECT
		end
	end

	local hasApproach = not table.isNilOrEmpty(approach) or false
	local hasBrand = not table.isNilOrEmpty(brand) or false
	local hasTag = not table.isNilOrEmpty(tag) or false

	for i = 1, #itemList do
		local canAdd = true
		local fashionId = itemList[i].fashionId

		if fashionId == nil then
			fashionId = itemList[i].fashionList[1]
		end

		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg == nil then
			print_warn("当前时装在配表中未找到,时装id来源于服务器PlayerFashionsInfo.FashionInfoDict   fashionId = " .. fashionId)
		end

		if hasTag then
			local canAddTag = false

			for i = 1, #tag do
				if table.contains(cfg.Tags, tag[i]) then
					canAddTag = true

					break
				end
			end

			if not canAddTag then
				canAdd = false
			end
		end

		if tempCollectType == self.COLLECT_TYPE.HAS_COLLECT then
			if itemList[i].isCollect ~= self.SELECT_TYPE.TRUE then
				canAdd = false
			end
		elseif tempCollectType == self.COLLECT_TYPE.NO_COLLECT and itemList[i].isCollect ~= self.SELECT_TYPE.FALSE then
			canAdd = false
		end

		if hasApproach and not table.contains(approach, cfg.Source) then
			canAdd = false
		end

		if hasBrand and not table.contains(brand, cfg.BelongBrand) then
			canAdd = false
		end

		if canAdd then
			table.insert(items, itemList[i])
		end
	end

	if not table.isNilOrEmpty(itemList) then
		self:SortItemList(items)
	end

	return items
end

function M:SortItemList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		return b.id < a.id
	end)
	table.sort(itemList, function (a, b)
		if a.isShowTask == b.isShowTask then
			if a.isAvailable == b.isAvailable then
				if self.selectedSortItemId == self.SELECTOR_SORT_TYPE.QUALITY then
					if self.sortLargeToSmall then
						return b.quality < a.quality
					else
						return a.quality < b.quality
					end
				elseif self.selectedSortItemId == self.SELECTOR_SORT_TYPE.GET_TIME then
					if self.sortLargeToSmall then
						return b.GainTime < a.GainTime
					else
						return a.GainTime < b.GainTime
					end
				end
			end

			return a.isAvailable == self.SELECT_TYPE.TRUE and b.isAvailable == self.SELECT_TYPE.FALSE
		end

		return a.isShowTask and not b.isShowTask
	end)
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

function M:SetFashionTagInfo(fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

function M:SelectSuitInfo(data)
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

	self:InitSuitFashionRightList()
	self:SetFashionTagInfo()
end

function M:OnItemFinish()
	if self.gotoIndexFashionId > 0 and not table.isNilOrEmpty(self.recordItems) then
		for i = 1, #self.recordItems do
			if self.recordItems[i].fashionId == self.gotoIndexFashionId then
				self.bindData.itemList:GoToIndex(i - 1, false)

				self.gotoIndexFashionId = 0

				break
			end
		end
	end
end

function M:OnChangeTab(btn, data)
	self.currentTabData = data
	self.bindData.partDes = data.PartName
	self.bindData.showdye = self.SELECT_TYPE.FALSE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.recordItems = {}

	if self.finishTabLayOut then
		self.bindData.tabList:GoToIndex(self.tabIndex - 1, false)
	end

	if data.Part == gDressManager.DRESS_PART.SUITS then
		self.bindData.type = self.OPEN_TYPE.SUIT
		self.suitList = self:FilterItems(self.suitList)

		self.bindData.suitList:SetSimpleList(#self.suitList)

		self.bindData.partCount = table.count(self.suitList)
		self.bindData.showSwitch = self.SELECT_TYPE.FALSE
		self.bindData.hasSecondTab = 1

		self.bindData:Commit("type", self.OPEN_TYPE.SUIT, COMMIT_IMMEDIATELY)
		self.bindData.suitList:PlayStartOffsetAnim(0)
	elseif data.Part == gDressManager.DRESS_PART.PROP then
		self.bindData.hasSecondTab = 0
		self.bindData.showSwitch = self.SELECT_TYPE.TRUE
		data.Type = FashionConfig.FashionPropTabIcon[1].type
		self.bindData.partDes = FashionConfig.FashionPropTabName[1].Name
		self.bindData.type = self.OPEN_TYPE.FASHION

		self.bindData:Commit("type", self.OPEN_TYPE.FASHION, COMMIT_IMMEDIATELY)

		local itemList = self.itemListByPart[data.Part] or {}
		local propItemList = {}

		for i = 1, #itemList do
			if table.contains(itemList[i].Types, data.Type) then
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

function M:OnChangeTabTop(btn, data)
	self.bindData.showSwitch = self.SELECT_TYPE.TRUE
	self.bindData.isShowInfo = self.SELECT_TYPE.FALSE
	self.bindData.partDes = data.PartName
	self.bindData.type = self.OPEN_TYPE.FASHION

	self.bindData.tabTopList:GoToIndex(self.tabTopIndex - 1, false)

	local itemList = self.itemListByPart[data.Part] or {}
	local propItemList = {}

	for i = 1, #itemList do
		if table.contains(itemList[i].Types, data.Type) then
			table.insert(propItemList, itemList[i])
		end
	end

	self.itemList = self:FilterItems(propItemList) or {}
	self.bindData.partCount = table.count(self.itemList)

	self.bindData.itemList:SetSimpleList(#self.itemList)
	self.bindData.itemList:PlayStartOffsetAnim()
end

function M:RecordFashionTypeFashionList()
	if self.fashionType > 0 then
		self.fashionTypeFashionList, self.fashionTypeFashionEditList = gDressManager:GetMyCurrentFashionList()
	end
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
