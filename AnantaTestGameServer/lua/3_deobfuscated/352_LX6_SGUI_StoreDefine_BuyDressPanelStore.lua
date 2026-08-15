local ConsumableConfig = LTConfig.ConsumableConfig
local ShopConfig = LTConfig.ShopConfig
local FashionConfig = LTConfig.FashionConfig
local ShopCommodityCfg = LTConfig.ShopCommodityConfig
local ShopCommodityGroupCfg = LTConfig.ShopCommodityGroupConfig
local MessageConfig = LTConfig.MessageConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local RedDotMgr = SGUI.RedDotMgr
local NpcShopCommodityStatus = UX.Game.NpcShopCommodityStatus
local bit = require("bit")
local ShopBrandConfig = LTConfig.ShopBrandConfig
C_BuyDressPanelStore = DefClass("C_BuyDressPanelStore", C_BuyDressPanelStore, C_StoreGroup)
GroupName2Class.BuyDressPanelStore = C_BuyDressPanelStore
local M = C_BuyDressPanelStore
local SELECT_TYPE = {
	FALSE = 0,
	TRUE = 1
}
local SHOP_TYPE = {
	SUIT = 1,
	COW_SHOP = 2,
	NORMAL = 0
}
local GENDER = {
	MALE = 1,
	FEMALE = 2,
	UNKNOWN = 0
}

function M:OnAwake()
	gClientUtils.CloseMainPhonePanel()

	self.tabList = {}
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.buyBtn.luaClick = self:CreateAction("OnBuyClick")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnSwitchClick")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnRefreshTabList")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnChangeTab")
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction("OnRefreshItemList")
	self.bindData.itemList.luaSimpleClick = self:CreateAction("OnChangeItem")
	self.bindData.suitList.luaSimpleRenderItem = self:CreateAction("OnRefreshSuitItemList")
	self.bindData.cowSuitTabList.luaSimpleRenderItem = self:CreateAction("OnRefreshCowSuitTabList")
	self.bindData.cowSuitTabList.luaSelectedChanged = self:CreateAction("OnChangeCowSuitTabItem")
	self.bindData.cowSuitList.luaSimpleRenderItem = self:CreateAction("OnRefreshCowSuitList")
	self.bindData.cowSuitList.luaSimpleClick = self:CreateAction("OnChangeCowSuitItem")
	self.OnRefreshCowSuitInfoItemAction = self:CreateAction("OnRefreshCowSuitInfoItemList")
	self.OnChangeCowSuitInfoItemAction = self:CreateAction("OnChangeCowSuitInfoItemList")
	self.bindData.tagList.luaSimpleRenderItem = self:CreateAction("OnRefreshTagList")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnChangeStep", -1)
		self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnChangeStep", 1)
		self.bindData.leftCowBtnClick.luaClick = self:CreateAction("OnChangeLeftPCClick")
		self.bindData.rightCowBtnClick.luaClick = self:CreateAction("OnChangeRightPCClick")
	end
end

function M:SetBanMove(_, data)
	self.banMove = data == 0
end

function M:OnDestroy()
	gDressCamera:SetCameraHide(false, gPanelId.S_BUY_DRESS_PANEL)
	gDressCamera:RemoveHiddenArea()
	self:ClearMessageEvents()
	gShopManager:NpcShopExitTime(self.shopId)
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
	self.selectTabPart = gDressManager.DRESS_PART.ALL
	self.selectDressFashionId = 0
	self.selectTab = 1
	self.selectGenderTab = 1
	self.bindData.isShowTips = 1
	self.bindData.isShowMessage = 1
	self.tempSaveConflicts = {}
	self.CurrentDiscount = 1

	gDressManager:SetCurrentPlayerSpirit()
	gDressManager:SetPlayerFashionsInfo()
	gCS.MyPlayerManager.PlayerUnit.FashionSlot:SyncApplyPlayerFashionInfo()

	if table.isNilOrEmpty(gDressManager.SpriteFashionInfoDict) or gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId] == nil then
		print_error("@hzliuyibing 没有找到角色对应的时装信息 SpiritId = " .. gDressManager.CurrentSpiritId)

		return
	end

	self:SetPlayerIcon()

	if data and data.id then
		self.shopId = data.id
		self.bindData.BuyingType = data.type or SHOP_TYPE.NORMAL
		self.bindData.isShowInfo = data.type

		gShopManager:SetShopIdEnterTime(self.shopId)

		self.dressFashionList = gDressManager:GetCurrentSpritFashionList()
		self.originalFashionList = table.clone(gDressManager:GetCurrentSpritFashionList())
		local cameraParams = {
			verticalButton = self.bindData.baseUpdownButton,
			basePanel = self.bindData.basePanel,
			rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
			L2CustomNavRespond = self.bindData.L2CustomNavRespond,
			R2CustomNavRespond = self.bindData.R2CustomNavRespond
		}

		if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
			gCS.CameraDataMgr.cameraEffectController:EnableMotionBlur(false)
		end

		cameraParams.banRotate = true

		gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, cameraParams)

		gClientToGameDelegate:AskNpcShopCommodityInfo(self.shopId).Callback = function (err, npcShopInfo)
			if err == MessageConfig.Ok then
				self.CurrentDiscount = npcShopInfo.CurrentDiscount
				local commodityInfoList = npcShopInfo.CommodityInfoList
				self.commodityInfo = commodityInfoList

				self:InitInfo()
			end
		end
	else
		print_error("没有传入shopId")
	end
end

function M:OnClose()
	if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
		gCS.CameraDataMgr.cameraEffectController:EnableMotionBlur(true)
	end

	gUnitStateMgr:ResetMyStateAndClearMove(true)
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:InitInfo()
	local info = self.commodityInfo
	self.selectPlayerSex = gDressManager.CurrentSpiritInfo.Sex
	self.bindData.currentDressName = ""

	if self.CurrentDiscount == 100 then
		self.bindData.reputationDiscountText = ShopConfig.FactionDiscountText[2]
	elseif self.CurrentDiscount < 100 then
		local discount = 100 - self.CurrentDiscount
		self.bindData.reputationDiscountText = string.format(ShopConfig.FactionDiscountText[1], discount)
	else
		local discount = self.CurrentDiscount - 100
		self.bindData.reputationDiscountText = string.format(ShopConfig.FactionDiscountText[3], discount)
	end

	self.originalFashionList = table.clone(gDressManager:GetCurrentSpritFashionList())

	self:SetDressScroll()
	self:SetTaskFashion()

	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg then
		self.bindData.title = cfg.ShopName
		self.bindData.brandIconId = cfg.Banner

		self.SubGroup.MoneyTemplateStore:SetData(cfg.Money)

		local conCfg = ConsumableConfig.GetConfig(cfg.Money)

		if conCfg then
			self.bindData.curMoneyIcon = conCfg.SMoneyIconId
			self.bindData.suitMoneyIcon = conCfg.SMoneyIconId
		end

		self.moneyId = cfg.Money
		self.myMoneyCount = gPlayerItemManager:GetPackItemNum(self.moneyId)
		self.bindData.bannerId = cfg.Banner
		local items = {}

		if self.bindData.BuyingType == SHOP_TYPE.NORMAL and #cfg.SellBrands ~= 0 then
			items = gDressManager:GetBrandsById(cfg.SellBrands)
		else
			for i = 1, #cfg.CommodityGroupIdList do
				local SCCfg = ShopCommodityGroupCfg.GetConfig(cfg.CommodityGroupIdList[i]).CommodityIDList

				for _, id in ipairs(SCCfg) do
					local cfg = ShopCommodityCfg.GetConfig(id)

					table.insert(items, cfg)
				end
			end
		end

		self.itemListByPart = {}
		self.itemList = {}
		local itemList = {}

		for i = 1, #items do
			local view = {}
			local itemCfg = ConsumableConfig.GetConfig(items[i].ConsumableID)

			if itemCfg then
				if not table.isNilOrEmpty(info) then
					for t = 1, info.Count do
						if info[t].TemplateId == items[i].Id then
							view.CommodityItemInfo = info[t]

							break
						end
					end
				end

				view.iconId = itemCfg.SItemIconId
				view.quality = itemCfg.Quality
				view.CommodityID = items[i].Id
				view.ConsumableID = items[i].ConsumableID
				view.BindId = itemCfg.BindId

				if self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
					local suitCfg = FashionSuitConfig.GetConfig(itemCfg.BindId)

					if suitCfg and suitCfg.IsShow then
						view.Name = suitCfg.Name
						view.Description = suitCfg.Description
						view.FashionIdList = table.clone(suitCfg.FashionIdList)
						view.isShowTask = self.taskSuitId == itemCfg.BindId
						view.isLock = bit.band(view.CommodityItemInfo.Status, NpcShopCommodityStatus.Locked) ~= 0
						view.lockDes = items[i].Description
						view.isNew = bit.band(view.CommodityItemInfo.Status, NpcShopCommodityStatus.Readable) ~= 0 and not view.isLock
						local gender = GENDER.UNKNOWN
						local isHaved = true
						local needBuyList = {}

						for t = 1, #suitCfg.FashionIdList do
							local fashionCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[t])

							if gender == GENDER.UNKNOWN and fashionCfg.Gender ~= GENDER.UNKNOWN then
								gender = fashionCfg.Gender
							end

							if isHaved then
								isHaved = gDressManager:IsFashionHaved(suitCfg.FashionIdList[t])

								if not isHaved then
									table.insert(needBuyList, suitCfg.FashionIdList[t])

									break
								end
							end
						end

						local fashionCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[1])

						if fashionCfg then
							local brandCfg = ShopBrandConfig.GetConfig(fashionCfg.BelongBrand)

							if brandCfg then
								view.iconBg = brandCfg.SuitBG
							end
						end

						view.isAvailable = (gender == self.selectPlayerSex or gender == GENDER.UNKNOWN) and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
						view.isHaved = isHaved
						view.needBuyList = needBuyList
						view.Gender = gender
					end
				else
					view.isHaved = gDressManager:IsFashionHaved(itemCfg.BindId)
					local fashionCfg = FashionConfig.GetConfig(itemCfg.BindId)

					if fashionCfg then
						view.Name = fashionCfg.Name
						view.Description = fashionCfg.Description
						view.Part = fashionCfg.Part
						view.Gender = fashionCfg.Gender
						view.isAvailable = (self.selectPlayerSex == fashionCfg.Gender or fashionCfg.Gender == GENDER.UNKNOWN) and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
					else
						print_error("当前配置找不到对应的fashion配表，请策划排查，shopId = " .. self.shopId .. "   fashionId = " .. itemCfg.BindId)
					end
				end

				local moenyItemCfg = ConsumableConfig.GetConfig(cfg.Money)

				if moenyItemCfg then
					view.moneyIcon = moenyItemCfg.SMoneyIconId
				end

				view.id = items[i].Id
				view.moneyNum = view.CommodityItemInfo.DiscountPrice
				view.canBuyItem = view.moneyNum <= self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
				view.itemListId = #itemList + 1

				if not table.isNilOrEmpty(self.taskFashionIdList) then
					view.isItemTask = table.contains(self.taskFashionIdList, itemCfg.BindId)
				else
					view.isItemTask = false
				end

				table.insert(itemList, view)

				if view.Part then
					if table.isNilOrEmpty(self.itemListByPart[view.Part]) then
						self.itemListByPart[view.Part] = {}
					end

					table.insert(self.itemListByPart[view.Part], view)
				end
			end
		end

		self.itemList = itemList

		if self.bindData.BuyingType == SHOP_TYPE.NORMAL then
			self:SetItemList()
			gDressManager:PlayDressDefaultAction()
		elseif self.bindData.BuyingType == SHOP_TYPE.SUIT then
			self:SetSuitList()
			gDressManager:PlayDressDefaultAction()
		else
			self:SetCowSuitTabList()
			gDressManager:PlayDressDefaultAction()
		end
	end

	if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
		gDressCamera:SetFullSlotShotCamera()
	end
end

function M:SetTaskFashion()
	self.taskSuitId = nil
	self.taskType = 4
	self.taskFashionIdList = {}
	self.bindData.isShowFashionTask = SELECT_TYPE.FALSE
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

	if curTaskInfo then
		if table.isNilOrEmpty(curTaskInfo.spiritWearFashionInfoList) then
			return
		end

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

			self.bindData.isShowFashionTask = SELECT_TYPE.TRUE
			self.bindData.taskDes = gUtils:GetSpecialDescription(curTaskInfo.WorkDescription, true)
			self.bindData.taskIcon = gTaskManager.TaskSIconId[self.taskType]
		end
	end
end

function M:SetItemList()
	if self.bindData.BuyingType ~= SHOP_TYPE.NORMAL then
		return
	end

	self:SortItemList(self.itemList)

	if self.selectTabPart == gDressManager.DRESS_PART.ALL then
		self.bindData.itemList:SetSimpleList(#self.itemList)
	else
		self.bindData.itemList:SetSimpleList(#self.itemListByPart[self.selectTabPart])
	end

	self.bindData.itemList:SetNavSelectToTop()

	local tabIcon = FashionConfig.FashionShopTabIcon
	self.tabList = {}

	for i = 1, #tabIcon do
		local view = {
			tabIndex = i,
			Part = tabIcon[i].part,
			icon = tabIcon[i].IconId
		}

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)
end

function M:SetSuitList()
	if self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
		return
	end

	local totalPrice = 0
	local fashionList = {}
	local isAvailable = false

	for i = 1, #self.itemList do
		if self.itemList[i].isHaved then
			totalPrice = totalPrice + self.itemList[i].moneyNum
		end

		if self.itemList[i].isAvailable then
			isAvailable = true
		end

		table.insert(fashionList, self.itemList[i].BindId)
	end

	if isAvailable then
		gDressManager:DressSuitFashionList(fashionList)
	end

	self.bindData.suitPrice = totalPrice

	self.bindData.suitList:SetSimpleList(#self.itemList)

	local notBuy = false

	for i = 1, #self.itemList do
		if not self.itemList[i].isHaved then
			notBuy = true
		end
	end

	self.bindData.buyBtn.interactable = notBuy and totalPrice <= self.myMoneyCount
	self.bindData.moneyLack = notBuy and self.myMoneyCount < totalPrice and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg then
		self.bindData.suitTitle = cfg.ShopName
		self.bindData.currentDressName = cfg.ShopName

		self:SetDressScroll(FashionConfig.ModelFashionShopDes)
	end
end

function M:OnRefreshTabList(btn, index)
	local data = self.tabList[index + 1]
	local store = gStoreManager:GetStoreGroup("ClothingTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		btn.isSelected = data.tabIndex == self.selectTab
	end
end

function M:OnChangeTab(uList)
	self.selectTab = uList.selectedIndex + 1

	self.bindData.tabList:GoToIndex(self.selectTab - 1, false)

	local data = self.tabList[self.selectTab]

	if data == nil then
		print_error("没有找到对应的tab数据 tabIndex = " .. self.selectTab)

		return
	end

	self.selectTabPart = data.Part

	if data.Part == gDressManager.DRESS_PART.ALL then
		self:SortItemList(self.itemList)
		self.bindData.itemList:SetSimpleList(#self.itemList)
		self.bindData.itemList:SetNavSelectToTop()
	else
		self:SortItemList(self.itemListByPart[data.Part])

		self.itemListByPart[data.Part] = self.itemListByPart[data.Part] or {}

		self.bindData.itemList:SetSimpleList(#self.itemListByPart[data.Part])
		self.bindData.itemList:SetNavSelectToTop()
	end

	if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
		local shotType = gDressCamera:GetShotTypeByFashionPart(data.Part)

		gDressCamera:EnableFashionShotCamera(shotType, "buyDressPanel")
	end
end

function M:OnRefreshItemList(btn, index)
	local data = nil

	if self.selectTabPart == gDressManager.DRESS_PART.ALL then
		data = self.itemList[index + 1]
	else
		data = self.itemListByPart[self.selectTabPart][index + 1]
	end

	local store = gStoreManager:GetStoreGroup("DressItemStore"):GetStoreByWidget(btn)

	if store then
		store.isHaved = gDressManager:IsFashionHaved(data.BindId) and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.quality = data.quality
		store.moneyIcon = data.moneyIcon
		store.moneyNum = data.moneyNum
		store.moneyColor = data.moneyNum <= self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		btn.isSelected = self.selectDressFashionId == data.BindId

		if btn.isSelected then
			self:SetFashionTagInfo(data.BindId)
		end

		if not table.isNilOrEmpty(self.taskFashionIdList) then
			local tempTs = table.contains(self.taskFashionIdList, data.BindId)
			store.isShowTask = tempTs and 0 or 1

			if tempTs then
				store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			end
		else
			store.isShowTask = 1
		end
	end
end

function M:OnChangeItem(btn, index)
	local data = nil

	if self.selectTabPart == gDressManager.DRESS_PART.ALL then
		data = self.itemList[index + 1]
	else
		data = self.itemListByPart[self.selectTabPart][index + 1]
	end

	if data.isAvailable == SELECT_TYPE.TRUE then
		local fashionCfg = FashionConfig.GetConfig(data.BindId)

		if fashionCfg then
			local minType = fashionCfg.Types[1]

			for i = 1, #fashionCfg.Types do
				if fashionCfg.Types[i] < minType then
					minType = fashionCfg.Types[i]
				end
			end

			if minType then
				gDressManager:PlayDressAction(minType)
			else
				print_error("@hzliuyibing 当前时装未配置类型，请联系策划检查配置，fashionId = " .. data.BindId)
			end

			if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
				local shotType = gDressCamera:GetShotTypeByFashionType(minType)

				gDressCamera:EnableFashionShotCamera(shotType, "buyDressPanel")
			end
		end
	else
		local cfg = MessageConfig.GetConfig(MessageConfig.FashionGenderMismacth)

		if cfg then
			self.bindData.messageDes = cfg.Content
		end

		if self.bindData.isShowMessage ~= 0 then
			self.bindData.isShowMessage = 0
		end

		if self.bindData.msgTipsAnim:IsPlaying("S_Vx_BuyDressPanel_MSG") then
			self.bindData.msgTipsAnim:Stop()
		end

		self.bindData.msgTipsAnim:Play("S_Vx_BuyDressPanel_MSG")
	end

	if btn.isSelected then
		self:SetFashionTagInfo(data.BindId)

		self.bindData.isShowInfo = SELECT_TYPE.TRUE

		FrameTimer.New(function ()
			SGUI.UNavigationMgr.Inst.gameBarsNeedRefresh = true
		end, 1):Start()

		self.bindData.currentDressName = data.Name

		self:SetDressScroll(data.Description)

		self.selectDressFashionId = data.BindId
		self.bindData.buyBtn.interactable = data.moneyNum <= self.myMoneyCount and not data.isHaved or false
		self.bindData.moneyLack = not data.isHaved and self.myMoneyCount < data.moneyNum and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

		if data.isAvailable == SELECT_TYPE.TRUE then
			local conflictItems, addItems = gDressManager:CheckFashionConflict({
				data.BindId
			})

			table.insert(addItems, data.BindId)

			if data.isHaved then
				gDressManager:ChangeFashionPart(addItems, conflictItems)
			else
				self:SetMyFashionList(addItems, conflictItems)
			end

			local conflictsView = {
				fashionId = data.BindId,
				conflictItems = conflictItems,
				addItems = addItems
			}

			table.insert(self.tempSaveConflicts, conflictsView)
			gDressManager:SetFashionList({
				data.BindId
			})
		end
	else
		self.bindData.isShowInfo = SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""

		self:SetDressScroll()

		self.selectDressFashionId = 0
		self.bindData.buyBtn.interactable = false

		if data.isAvailable == SELECT_TYPE.TRUE then
			local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict({
				data.BindId
			})

			if not table.contains(conflictItems, data.BindId) then
				table.insert(conflictItems, data.BindId)
			end

			self:SetMyFashionList(addItems, conflictItems)
			gDressManager:ChangeFashionPart(addItems, conflictItems)
			gDressManager:RemoveFashionPart({
				data.BindId
			})
		end
	end
end

function M:OnRefreshSuitItemList(btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressItemSuitStore"):GetStoreByWidget(btn)

	if store then
		store.isHaved = data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.quality = data.quality
		store.moneyColor = data.moneyNum <= self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	end
end

function M:SetCowSuitTabList()
	if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
		return
	end

	local cowTabInfo = FashionConfig.CowSuitTabName
	self.cowSuitTabList = {}

	for i = 1, #cowTabInfo do
		local view = {
			Name = cowTabInfo[i].Name,
			Gender = cowTabInfo[i].Gender,
			index = i
		}

		if view.Gender == self.selectPlayerSex then
			self.selectGenderTab = i
		end

		table.insert(self.cowSuitTabList, view)
	end

	self.bindData.cowSuitTabList:SetSimpleList(#self.cowSuitTabList)

	self.curGenderItemList = {}

	for i = 1, #self.itemList do
		if self.itemList[i].Gender == GENDER.UNKNOWN or self.itemList[i].Gender == self.selectGenderTab then
			table.insert(self.curGenderItemList, self.itemList[i])
		end
	end

	self:SortSuitItemList(self.curGenderItemList)
	self.bindData.cowSuitList:SetSimpleList(#self.curGenderItemList)
	self.bindData.cowSuitList:SetNavSelectToTop()
end

function M:OnRefreshCowSuitTabList(btn, index)
	local data = self.cowSuitTabList[index + 1]
	local store = gStoreManager:GetStoreGroup("GenderTabTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.name = data.Name
		btn.isSelected = data.Gender == self.selectGenderTab

		if btn.isSelected then
			self.selectCoutSuitTabIndex = data.index
		end
	end
end

function M:OnChangeCowSuitTabItem(uList)
	self.selectCoutSuitTabIndex = uList.selectedIndex + 1
	local data = self.cowSuitTabList[self.selectCoutSuitTabIndex]
	self.selectGenderTab = data.Gender
	self.curGenderItemList = {}

	for i = 1, #self.itemList do
		if self.itemList[i].Gender == GENDER.UNKNOWN or self.itemList[i].Gender == self.selectGenderTab then
			table.insert(self.curGenderItemList, self.itemList[i])
		end
	end

	self:SortSuitItemList(self.curGenderItemList)
	self.bindData.cowSuitList:SetSimpleList(#self.curGenderItemList)
	self.bindData.cowSuitList:SetNavSelectToTop()
end

function M:OnChangeCowSuitItem(btn, index)
	local data = self.curGenderItemList[index + 1]

	if btn.isSelected then
		self.bindData.isShowInfo = SELECT_TYPE.TRUE
		self.bindData.currentSuitName = data.Name
		self.bindData.isShowTask = data.isShowTask and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		self.bindData.isShowBuyBtn = data.isLock and not data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

		self:SetSuitScroll(data)

		self.bindData.buyBtn.interactable = data.moneyNum <= self.myMoneyCount and not data.isHaved and not data.isLock or false
		self.bindData.moneyLack = not data.isHaved and self.myMoneyCount < data.moneyNum and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		self.selectDressFashionId = data.BindId

		if data.isLock then
			self.bindData.lockDes = data.lockDes
		end

		self.bindData.tipAnim:Play("S_Vx_BuyDressPanel_info")

		if data.isAvailable == SELECT_TYPE.TRUE then
			self.isDressBuyFashion = data.isHaved
			self.cowSuitList = data.FashionIdList

			gDressManager:PlayRandomDressAction()
			gDressManager:DressSuitFashionList(data.FashionIdList, true)
		else
			local cfg = MessageConfig.GetConfig(MessageConfig.FashionGenderMismacth)

			if cfg then
				self.bindData.messageDes = cfg.Content
			end

			if self.bindData.isShowMessage ~= 0 then
				self.bindData.isShowMessage = 0
			end

			if self.bindData.msgTipsAnim:IsPlaying("S_Vx_BuyDressPanel_MSG") then
				self.bindData.msgTipsAnim:Stop()
			end

			self.bindData.msgTipsAnim:Play("S_Vx_BuyDressPanel_MSG")
		end

		if data.isNew then
			gDressData:AskReadCommodities({
				data.CommodityID
			}, function ()
				RedDotMgr.LuaSetRedDot(false, "SuitItemRedDot.pageSuitList:" .. data.id)
				self:RefreshRedDotInfo(data.CommodityID)
			end)
		end
	else
		local conflictItems, addItems = gDressManager:CheckRemoveFashionConflict(data.FashionIdList)

		for i = 1, #data.FashionIdList do
			if not table.contains(conflictItems, data.FashionIdList[i]) then
				table.insert(conflictItems, data.FashionIdList[i])
			end
		end

		gDressManager:ChangeFashionPart(addItems, conflictItems)
		gDressManager:RemoveFashionPart(data.FashionIdList)

		self.bindData.isShowInfo = SELECT_TYPE.FALSE

		self:SetSuitScroll()

		self.bindData.currentSuitName = ""
		self.bindData.lockDes = ""
		self.selectDressFashionId = 0
	end
end

function M:OnRefreshCowSuitList(btn, index)
	local data = self.curGenderItemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressItemCowsStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "SuitItemRedDot.pageSuitList:" .. data.id)

		store.isHaved = data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.iconBg = data.iconBg
		store.quality = data.quality
		store.moneyIcon = data.moneyIcon
		store.moneyNum = data.moneyNum
		store.moneyColor = data.moneyNum <= self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isLock = not data.isHaved and data.isLock and SELECT_TYPE.FALSE or SELECT_TYPE.TRUE

		if self.taskSuitId and self.taskSuitId > 0 then
			store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			store.isShowTask = data.isShowTask and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		else
			store.isShowTask = SELECT_TYPE.FALSE
		end

		btn.isSelected = self.selectDressFashionId == data.BindId

		if btn.isSelected then
			self.bindData.isShowBuyBtn = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

			if data.isLock then
				self.bindData.lockDes = data.lockDes
			end

			if data.isAvailable == SELECT_TYPE.TRUE then
				self.isDressBuyFashion = data.isHaved

				gDressManager:PlayRandomDressAction()
				gDressManager:DressSuitFashionList(data.FashionIdList, true)
			end

			if data.isNew then
				gDressData:AskReadCommodities({
					data.CommodityID
				}, function ()
					RedDotMgr.LuaSetRedDot(false, "SuitItemRedDot.pageSuitList:" .. data.id)
					self:RefreshRedDotInfo(data.CommodityID)
				end)
			end
		end
	end
end

function M:SetFashionTagInfo(fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

function M:OnRefreshTagList(btn, index)
	local data = self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
end

function M:SetDressScroll(str)
	if str == nil then
		str = ""
	end

	local store = gStoreManager:GetStoreGroup("DressinfoTextTemplateStore"):GetStoreByWidget(self.bindData.currentDressDesScroll.content)

	if not store then
		return
	end

	store.des = str
end

function M:SetSuitScroll(data)
	local store = gStoreManager:GetStoreGroup("DressSuitInfoTemplateStore"):GetStoreByWidget(self.bindData.currentSuitInfoScroll.content)

	if not store then
		return
	end

	if table.isNilOrEmpty(data) then
		store.des = ""

		return
	end

	store.itemList.luaSimpleRenderItem = self.OnRefreshCowSuitInfoItemAction
	store.itemList.luaSimpleClick = self.OnChangeCowSuitInfoItemAction
	store.des = data.Description or ""

	if not table.isNilOrEmpty(data.FashionIdList) then
		self.suitScrollList = {}

		for i = 1, #data.FashionIdList do
			local view = {}
			local cfg = FashionConfig.GetConfig(data.FashionIdList[i])

			if cfg then
				view.icon = cfg.Icon
				view.quality = cfg.Quality
				view.isLock = false
				view.itemId = data.FashionIdList[i]
				view.name = ""
			end

			table.insert(self.suitScrollList, view)
		end

		store.itemList:SetSimpleList(#self.suitScrollList)
	end
end

function M:OnRefreshCowSuitInfoItemList(btn, index)
	local data = self.suitScrollList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplarePreviewStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.quality = data.quality
		store.isLock = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	end
end

function M:OnChangeCowSuitInfoItemList(btn, index)
	local data = self.suitScrollList[index + 1]

	gCommonItemManager:OnShowItemList({
		data
	})
end

function M:SortItemList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		if a.isItemTask ~= b.isItemTask then
			return a.isItemTask and not b.isItemTask
		end

		if a.isHaved ~= b.isHaved then
			return not a.isHaved and b.isHaved
		end

		if a.isAvailable ~= b.isAvailable then
			return a.isAvailable == SELECT_TYPE.TRUE and b.isAvailable == SELECT_TYPE.FALSE
		end

		if a.quality ~= b.quality then
			return b.quality < a.quality
		end

		if a.itemListId ~= b.itemListId then
			return a.itemListId < b.itemListId
		end

		return b.id < a.id
	end)
end

function M:SortSuitItemList(itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		if a.isShowTask == b.isShowTask then
			if a.isHaved == b.isHaved then
				if a.isLock == b.isLock then
					if a.quality == b.quality then
						return a.itemListId < b.itemListId
					else
						return b.quality < a.quality
					end
				end

				return not a.isLock and b.isLock
			end

			return not a.isHaved and b.isHaved
		end

		return a.isShowTask and not b.isShowTask
	end)
end

function M:SetPlayerIcon()
	self.recordSpiritId = gDressManager.CurrentSpiritId
	local info = LTConfig.FightSpiritConfig.GetConfig(gDressManager.CurrentSpiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

function M:OnBackBtnClick()
	if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
		if self:CheckHasBuyFashion() then
			gDressManager:ClearCurrentPlayerSpirit(false, true)
			self:AskSetSpiritFashions()
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.FashionShopUnpaid, function ()
				gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList = self.originalFashionList

				gDressManager:ClearCurrentPlayerSpirit(true)
				self:AskSetSpiritFashions()
			end, nil)
		end
	elseif self.isDressBuyFashion then
		self:AskSetSpiritFashions()
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.FashionShopUnpaid, function ()
			gDressManager.SpriteFashionInfoDict[gDressManager.CurrentSpiritId].WearFashionInfoList = self.originalFashionList

			gDressManager:ClearCurrentPlayerSpirit(true)
			self:AskSetSpiritFashions()
		end, nil)
	end
end

function M:AskSetSpiritFashions()
	gDressData:AskSetSpiritFashions(function ()
		if self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
			if self.isDressBuyFashion and gDressManager:CheckSpriteHasDefaultUnderwear() then
				gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
				gDressManager:ClearCurrentPlayerSpirit(false)

				return
			end

			local function callBack()
				gDressManager:ClearCurrentPlayerSpirit(true)
				gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
			end

			gDressData:AskSetSpiritFashions(callBack)

			return
		else
			gDressManager:ClearCurrentPlayerSpirit(false)
			gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
		end
	end)
end

function M:CheckHasBuyFashion()
	local fashionList = gDressManager:GetCurrentSpritFashionList()
	local hasBuy = true

	if not table.isNilOrEmpty(fashionList) then
		for i = 1, #fashionList do
			if not gDressManager:IsFashionHaved(fashionList[i].FashionId) then
				hasBuy = false
			end
		end
	end

	return hasBuy
end

function M:SetMyFashionList(addItems, conflictItems)
	local dressFashionList = gDressManager:GetCurrentSpritFashionList()

	for i = 1, #conflictItems do
		for t = #dressFashionList, 1, -1 do
			if dressFashionList[t].FashionId == conflictItems[i] then
				table.remove(dressFashionList, t)
			end
		end
	end

	for i = 1, #addItems do
		table.insert(dressFashionList, {
			FashionId = addItems[i]
		})
	end
end

function M:OnBuyClick()
	if self.bindData.BuyingType == SHOP_TYPE.NORMAL or self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
		if self.selectDressFashionId == 0 then
			return
		end

		local itemInfo = nil
		local index = 0

		if self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
			for i = 1, #self.curGenderItemList do
				if self.curGenderItemList[i].BindId == self.selectDressFashionId then
					itemInfo = self.curGenderItemList[i]
					index = i

					break
				end
			end
		else
			for i = 1, #self.itemList do
				if self.itemList[i].BindId == self.selectDressFashionId then
					itemInfo = self.itemList[i]
					index = i

					break
				end
			end
		end

		local function cb()
			self.myMoneyCount = gPlayerItemManager:GetPackItemNum(self.moneyId)
			self.bindData.buyBtn.interactable = false

			if self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
				self.curGenderItemList[index].isHaved = true

				self.bindData.cowSuitList:RefreshList()
			else
				self.itemList[index].isHaved = true

				self.bindData.itemList:RefreshList()
			end

			if self.bindData.isShowTips == 1 then
				self.bindData.isShowTips = 0
			end

			if self.bindData.buyTipsAnim:IsPlaying("S_Vx_buyDressTips") then
				self.bindData.buyTipsAnim:Stop()
			end

			self.bindData.buyTipsAnim:Play("S_Vx_buyDressTips")

			self.bindData.buyDressName = itemInfo.Name

			if not table.isNilOrEmpty(self.tempSaveConflicts) and self.tempSaveConflicts[#self.tempSaveConflicts].fashionId == itemInfo.BindId then
				for i = 1, #self.tempSaveConflicts do
					local view = self.tempSaveConflicts[i]

					gDressManager:ChangeFashionPart(view.addItems, view.conflictItems)
				end

				self.tempSaveConflicts = {}
			end
		end

		gDressData:AskBuyFashion(itemInfo.CommodityID, cb)

		return
	end

	local function cb()
		for i = 1, #self.itemList do
			if not self.itemList[i].isHaved then
				self.itemList[i].isHaved = true
			end
		end

		self:SetSuitList()
	end

	local commodityList = {}

	for i = 1, #self.itemList do
		if not self.itemList[i].isHaved then
			commodityList[self.itemList[i].CommodityID] = 1
		end
	end

	gDressData:AskBuyCommodities(commodityList, cb)
end

function M:OnSwitchClick()
	local function cb(hasChange)
		if self.recordSpiritId == gDressManager.CurrentSpiritId and not hasChange then
			if self.bindData.BuyingType ~= SHOP_TYPE.COW_SHOP then
				gDressCamera:SetFullSlotShotCamera()
			end

			gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.TryFashion, nil)
		else
			self.bindData.isShowInfo = SELECT_TYPE.FALSE
			self.selectDressFashionId = 0

			self:InitInfo()
			self:SetPlayerIcon()
		end
	end

	local data = {}

	if self.bindData.BuyingType == SHOP_TYPE.NORMAL or self.bindData.BuyingType == SHOP_TYPE.COW_SHOP then
		data = {
			callBack = cb
		}
	else
		data = {
			sex = self.selectPlayerSex,
			callBack = cb
		}
	end

	data.isFromShop = true

	gDressCamera:SetFullSlotShotCamera()
	gPanelManager:CheckShow(gPanelId.S_SWITCH_CHARACTER, data)
end

function M:OnChangeLeftPCClick()
	self.selectCoutSuitTabIndex = self.bindData.cowSuitTabList.selectedIndex >= 0 and self.bindData.cowSuitTabList.selectedIndex or 0

	if self.selectCoutSuitTabIndex > 0 then
		self.bindData.cowSuitTabList:SelectItem(self.selectCoutSuitTabIndex - 1, true)
	end
end

function M:OnChangeRightPCClick()
	self.selectCoutSuitTabIndex = self.bindData.cowSuitTabList.selectedIndex >= 0 and self.bindData.cowSuitTabList.selectedIndex or 0

	if self.selectCoutSuitTabIndex + 1 < #self.cowSuitTabList then
		self.bindData.cowSuitTabList:SelectItem(self.selectCoutSuitTabIndex + 1, true)
	end
end

function M:RefreshRedDotInfo(CommodityID)
	for i = 1, #self.itemList do
		if self.itemList[i].CommodityID == CommodityID then
			self.itemList[i].isNew = false

			break
		end
	end

	for i = 1, #self.curGenderItemList do
		if self.curGenderItemList[i].CommodityID == CommodityID then
			self.curGenderItemList[i].isNew = false

			break
		end
	end
end

function M:OnChangeStep(step)
	local nextStep = self:RefreshStep(self.selectTab, step)

	self.bindData.tabList:SelectItem(nextStep - 1)
end

function M:RefreshStep(curStep, step)
	local nextStep = curStep + step

	if nextStep < 1 then
		nextStep = #self.tabList
	elseif nextStep > #self.tabList then
		nextStep = 1
	end

	return nextStep
end
