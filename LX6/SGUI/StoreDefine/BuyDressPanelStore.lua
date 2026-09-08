-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BuyDressPanelStore.lua
-- Decompiled from: 01632_BuyDressPanelStore.lua_94f98a394b75.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ShopConfig = LTConfig.ShopConfig
local FashionConfig = LTConfig.FashionConfig
local MessageConfig = LTConfig.MessageConfig
local FashionSuitConfig = LTConfig.FashionSuitConfig
local RedDotMgr = SGUI.RedDotMgr
local NpcShopCommodityStatus = UX.Game.NpcShopCommodityStatus
local bit = require("bit")
local ShopBrandConfig = LTConfig.ShopBrandConfig
local MoneyType = UX.Game.MoneyType
C_BuyDressPanelStore = DefClass("C_BuyDressPanelStore", C_BuyDressPanelStore, C_StoreGroup)
GroupName2Class.BuyDressPanelStore = C_BuyDressPanelStore
local M = C_BuyDressPanelStore
local SELECT_TYPE = {
	["k\\x8f\\x8e\\x9c\\x93"] = 0,
	["NH~"] = 1
}
local SHOP_TYPE = {
	["ITo"] = 2,
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["i\\x9b\\x8f\\x82\\x8f"] = 1
}
local GENDER = {
	["WQ~"] = 1,
	[":m\\xbc\\xaf\\xafd"] = 2,
	["\\xec\\xf5?31\\xdf"] = 0
}

M.DefineAllVariables = function(self)
	self.selectTabPart = gDressManager.DRESS_PART.ALL
	self.selectDressFashionId = 0
	self.selectTab = 1
	self.selectGenderTab = 1
	self.CurrentDiscount = 1
	self.tabList = {}
	self.shopId = 0
	self.taskFashionIdList = nil
	self.taskSuitIdList = nil
	self.itemListByPart = nil
	self.itemList = nil
	self.isDressBuyFashion = true
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	if self.shopId then
		gShopManager:NpcShopExitTime(self.shopId)
	end
end

M.OnShow = function(self, panelId, data)
	self.spiritContext = gDressManager:GetSpiritContext()
	self.recordSpriteId = self.spiritContext.spiritId

	gDressManager:PrepareUnitForDress(self.spiritContext.unit)

	if gDressManager:CheckIsInTryWear() then
		gDialogManager:ShowGeneralDialog(100053490, gDialogSource.Fashion)
		gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.DressBreak)
		gPanelManager:Close(self.m_Id)

		return
	end

	gClientUtils.CloseMainPhonePanel()
	gDressManager:SetPlayerFashionsInfo()

	local info = gDressManager:GetCurrentSpritWearFashionInfo(self.spiritContext)

	if not info then
		print_error("@hzliuyibing 没有找到角色对应的时装信息 SpiritId = " .. self.spiritContext.spiritId)

		return
	end

	if data and data.id then
		self.InitView(self, data)
		self.SyncInfo(self, data)

		local cameraParams = {
			verticalButton = self.bindData.baseUpdownButton,
			basePanel = self.bindData.basePanel,
			rightStickCustomNavRespond = self.bindData.mouseCustomNavRespond,
			L2CustomNavRespond = self.bindData.L2CustomNavRespond,
			R2CustomNavRespond = self.bindData.R2CustomNavRespond,
			movementState = LX6.Cinemachine.EMovementCamState.TryFashion
		}

		if self.bindData.BuyingType == SHOP_TYPE.SUIT then
			gCS.CameraDataMgr.cameraEffectController:EnableMotionBlur(false)
		end

		gDressStack:SetDressStack(self.m_Id, true, cameraParams)
	else
		print_error("没有传入shopId")
	end
end

M.SyncInfo = function(self, data)
	self.shopId = tonumber(data.id)

	gShopManager:SetShopIdEnterTime(self.shopId)
	gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("InitShopInfo"))
end

M.InitShopInfo = function(self, success, commodityList, commodityDict, commodityInfos)
	self.selectPlayerSex = self.spiritContext.spiritInfo.Sex
	self.taskSuitIdList = nil
	self.taskType = 4

	if not success then
		return
	end

	self.CurrentDiscount = commodityInfos.CurrentDiscount

	self.SetTaskFashion(self)
	self.InitViewAfterSync(self)

	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg then
		self.myMoneyCount = gUIUtils:GetMoneyByType(MoneyType.Money)

		self:InitShopItemList(commodityList)

		if self.bindData.BuyingType ~= SHOP_TYPE.NORMAL then
			self:SetItemList()
			gDressManager:PlayDressDefaultAction()
		elseif self.bindData.BuyingType ~= SHOP_TYPE.DUMMY then
			self:SetSuitList()
			gDressManager:PlayDressDefaultAction()
		else
			self:SetCowSuitTabList()
			gDressManager:PlayDressDefaultAction()
		end
	end

	if self.bindData.BuyingType == SHOP_TYPE.SUIT then
		gDressCamera:SetFullSlotShotCamera()
	end
end

M.SetTaskFashion = function(self)
	self.taskSuitIdList = {}
	self.taskFashionIdList = {}
	self.bindData.isShowFashionTask = SELECT_TYPE.FALSE
	local curTaskInfo, _, _ = gTaskNodeManager:GetTaskCounterInfo(gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1])

	if curTaskInfo then
		if table.isNilOrEmpty(curTaskInfo.spiritWearFashionInfoList) then
			return
		end

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

			self.bindData.isShowFashionTask = SELECT_TYPE.TRUE
			self.bindData.taskDes = gUtils:GetSpecialDescription(curTaskInfo.WorkDescription, true)
			self.bindData.taskIcon = gTaskManager.TaskSIconId[self.taskType]
		end
	end
end

M.InitView = function(self, data)
	self.bindData.isShowTips = 1
	self.bindData.isShowMessage = 1
	self.bindData.BuyingType = data.type or SHOP_TYPE.NORMAL
	self.bindData.isShowInfo = data.type

	self:SetPlayerIcon()
end

M.SetPlayerIcon = function(self)
	local info = LTConfig.FightSpiritConfig.GetConfig(self.spiritContext.spiritId)

	if info then
		self.bindData.switchIconId = info.SHeadIconID
	end
end

M.InitViewAfterSync = function(self)
	self.bindData.currentDressName = ""
	self.bindData.reputationDiscountText = gShopManager:GetFactionDiscountStr(self.CurrentDiscount)
	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg then
		self.bindData.title = cfg.ShopName
		self.bindData.brandIconId = cfg.Banner

		self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

		self.bindData.bannerId = cfg.Banner
	end
end

M.InitShopItemList = function(self, list)
	local commodityList = {}

	for _, group in pairs(list) do
		for _, commodityItem in ipairs(group) do
			table.insert(commodityList, commodityItem)
		end
	end

	self.itemListByPart = {}
	self.itemList = {}

	for i = 1, #commodityList do
		local view = {}
		local itemCfg = ConsumableConfig.GetConfig(commodityList[i].ConsumableID)

		if itemCfg then
			view.CommodityItemInfo = commodityList[i]
			view.iconId = itemCfg.SItemIconId
			view.quality = itemCfg.Quality
			view.CommodityID = commodityList[i].CommodityId
			view.ConsumableID = commodityList[i].ConsumableID
			view.BindId = itemCfg.BindId

			if self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
				local suitCfg = commodityList[i].Cfg

				if suitCfg and suitCfg.IsShow then
					view.Name = suitCfg.Name
					view.Description = suitCfg.Description
					view.FashionIdList = table.clone(suitCfg.FashionIdList)
					view.isShowTask = table.contains(self.taskSuitIdList, itemCfg.BindId)
					view.isLock = bit.band(view.CommodityItemInfo.Status, NpcShopCommodityStatus.Locked) == 0
					view.lockDes = commodityList[i].UnlockDesc
					view.isNew = bit.band(view.CommodityItemInfo.Status, NpcShopCommodityStatus.Readable) == 0 and not view.isLock
					local gender = GENDER.UNKNOWN
					local isHad = true
					local needBuyList = {}

					for t = 1, #suitCfg.FashionIdList do
						local fashionCfg = FashionConfig.GetConfig(suitCfg.FashionIdList[t])

						if gender ~= GENDER.UNKNOWN and fashionCfg.Gender == GENDER.UNKNOWN then
							gender = fashionCfg.Gender
						end

						if isHad then
							isHad = gDressManager:IsFashionHad(suitCfg.FashionIdList[t])

							if not isHad then
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

					view.isAvailable = (gender ~= self.selectPlayerSex or gender ~= GENDER.UNKNOWN) and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
					view.isHaved = isHad
					view.needBuyList = needBuyList
					view.Gender = gender
				end
			else
				view.isHaved = gDressManager:IsFashionHad(itemCfg.BindId)
				view.isLock = bit.band(view.CommodityItemInfo.Status, NpcShopCommodityStatus.Locked) == 0
				view.lockDes = commodityList[i].UnlockDesc
				local fashionCfg = FashionConfig.GetConfig(itemCfg.BindId)

				if fashionCfg then
					view.Name = fashionCfg.Name
					view.Description = fashionCfg.Description
					view.Part = fashionCfg.Part
					view.Gender = fashionCfg.Gender
					local available = gDressManager:CheckGenderWithBodyTypeAllow(itemCfg.BindId, self.spiritContext.spiritInfo)
					view.isAvailable = available and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
				else
					print_error("当前配置找不到对应的fashion配表，请策划排查，shopId = " .. self.shopId .. "   fashionId = " .. itemCfg.BindId)
				end
			end

			view.id = commodityList[i].CommodityId
			view.moneyNum = view.CommodityItemInfo.PriceCurrent
			view.canBuyItem = view.moneyNum < self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
			view.itemListId = #self.itemList + 1

			if not table.isNilOrEmpty(self.taskFashionIdList) then
				view.isItemTask = table.contains(self.taskFashionIdList, itemCfg.BindId)
			else
				view.isItemTask = false
			end

			table.insert(self.itemList, view)

			if view.Part then
				if table.isNilOrEmpty(self.itemListByPart[view.Part]) then
					self.itemListByPart[view.Part] = {}
				end

				table.insert(self.itemListByPart[view.Part], view)
			end
		end
	end
end

M.OnClose = function(self)
	if self.bindData.BuyingType == SHOP_TYPE.SUIT then
		gCS.CameraDataMgr.cameraEffectController:EnableMotionBlur(true)
	end

	if self.shopId then
		gClientToGameDelegate:AskCloseNpcShop(self.shopId)
	end

	gUnitStateMgr:ResetMyStateAndClearMove(true)
	gDressStack:SetDressStack(self.m_Id, false)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.buyBtn.luaClick = self.CreateAction(self, "OnBuyClick")
	self.bindData.switchBtn.luaClick = self.CreateAction(self, "OnSwitchClick")
	self.bindData.resetBtn.luaClick = self.CreateAction(self, "OnResetClick")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftCowBtnClick.luaClick = self.CreateAction(self, "OnChangeLeftPCClick")
		self.bindData.rightCowBtnClick.luaClick = self.CreateAction(self, "OnChangeRightPCClick")
	end

	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, "OnItemListSimpleRenderItem")
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, "OnChangeItemList")
	self.bindData.suitList.luaSimpleRenderItem = self.CreateAction(self, "OnDummyListSimpleRenderItem")
	self.bindData.cowSuitTabList.luaSimpleRenderItem = self.CreateAction(self, "OnSuitTabListSimpleRenderItem")
	self.bindData.cowSuitTabList.luaSelectedChanged = self.CreateAction(self, "OnChangeSuitTabList")
	self.bindData.cowSuitList.luaSimpleRenderItem = self.CreateAction(self, "OnSuitListSimpleRenderItem")
	self.bindData.cowSuitList.luaSimpleClick = self.CreateAction(self, "OnChangeSuitList")
	self.OnRefreshCowSuitInfoItemAction = self.CreateAction(self, "OnSuitInfoItemListSimpleRenderItem")
	self.OnChangeCowSuitInfoItemAction = self.CreateAction(self, "OnChangeSuitInfoItemList")
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, "OnTagListSimpleRenderItem")
end

M.OnBackBtnClick = function(self)
	if self.bindData.BuyingType == SHOP_TYPE.SUIT then
		if self.CheckHasBuyFashion(self) then
			self.AskSetSpiritFashions(self)
		else
			slot1 = gDisplayMessageMgr

			slot1:ShowMessage(MessageConfig.FashionShopUnpaid, function ()
				gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
				self:AskSetSpiritFashions()
			end, nil)
		end
	elseif self.isDressBuyFashion then
		self.AskSetSpiritFashions(self)
	else
		slot1 = gDisplayMessageMgr

		slot1:ShowMessage(MessageConfig.FashionShopUnpaid, function ()
			gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
			self:AskSetSpiritFashions()
		end, nil)
	end
end

M.OnBuyClick = function(self)
	if self.bindData.BuyingType ~= SHOP_TYPE.NORMAL or self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
		if self.selectDressFashionId ~= 0 then
			return
		end

		local itemInfo = nil
		local index = 0

		if self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
			for i = 1, #self.curGenderItemList do
				if self.curGenderItemList[i].BindId ~= self.selectDressFashionId then
					itemInfo = self.curGenderItemList[i]
					index = i

					break
				end
			end
		else
			for i = 1, #self.itemList do
				if self.itemList[i].BindId ~= self.selectDressFashionId then
					itemInfo = self.itemList[i]
					index = i

					break
				end
			end
		end

		local cb = function()
			self.myMoneyCount = gUIUtils:GetMoneyByType(MoneyType.Money)
			self.bindData.buyBtn.interactable = false

			if self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
				self.curGenderItemList[index].isHaved = true

				self.bindData.cowSuitList:RefreshList()
			else
				self.itemList[index].isHaved = true

				self.bindData.itemList:RefreshList()
			end

			if self.bindData.isShowTips ~= 1 then
				self.bindData.isShowTips = 0
			end

			if self.bindData.buyTipsAnim:IsPlaying("S_Vx_buyDressTips") then
				self.bindData.buyTipsAnim:Stop()
			end

			self.bindData.buyTipsAnim:Play("S_Vx_buyDressTips")

			self.bindData.buyDressName = itemInfo.Name
			self.bindData.tipsQualityCtrl = itemInfo.quality
		end

		gDressData:AskBuyFashion(self.shopId, itemInfo.CommodityID, cb)

		return
	end

	local cb = function()
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

	gDressData:AskBuyCommodities(self.shopId, commodityList, cb)
end

M.OnSwitchClick = function(self)
	local cb = function(hasChange)
		if self.recordSpriteId ~= self.spiritContext.spiritId and not hasChange then
			if self.bindData.BuyingType == SHOP_TYPE.SUIT then
				gDressCamera:SetFullSlotShotCamera()
			end

			gCS.CameraDataMgr.cinemachineManager:EnterMovementState(LX6.Cinemachine.EMovementCamState.TryFashion, nil)
		else
			if self.bindData.BuyingType == SHOP_TYPE.DUMMY then
				self.bindData.isShowInfo = SELECT_TYPE.FALSE
			end

			self.spiritContext = gDressManager:GetSpiritContext()

			gDressManager:PrepareUnitForDress(self.spiritContext.unit)
			gDressManager:SetPlayerFashionsInfo()

			self.selectDressFashionId = 0

			gShopManager:GetShopCommodityInfo(self.shopId, self:CreateAction("InitShopInfo"))
			self:SetPlayerIcon()
		end
	end

	local data = {}

	if self.bindData.BuyingType ~= SHOP_TYPE.NORMAL or self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
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

M.OnResetClick = function(self)
	slot1 = gDisplayMessageMgr

	slot1:ShowMessage(MessageConfig.FashionResetReconfirm, function ()
		gDressManager:CleanupDressState(self.spiritContext, true)

		self.selectDressFashionId = 0
		self.bindData.isShowInfo = SELECT_TYPE.FALSE

		self.bindData.itemList:RefreshList()
	end)
end

M.OnChangeLeftPCClick = function(self)
	self.selectCoutSuitTabIndex = self.bindData.cowSuitTabList.selectedIndex > 0 and self.bindData.cowSuitTabList.selectedIndex or 0

	if self.selectCoutSuitTabIndex <= 0 then
		self.bindData.cowSuitTabList:SelectItem(self.selectCoutSuitTabIndex - 1, true)
	end
end

M.OnChangeRightPCClick = function(self)
	self.selectCoutSuitTabIndex = self.bindData.cowSuitTabList.selectedIndex > 0 and self.bindData.cowSuitTabList.selectedIndex or 0

	if self.selectCoutSuitTabIndex + 1 >= #self.cowSuitTabList then
		self.bindData.cowSuitTabList:SelectItem(self.selectCoutSuitTabIndex + 1, true)
	end
end

M.OnItemListSimpleRenderItem = function(self, btn, index)
	local data = nil

	if self.selectTabPart ~= gDressManager.DRESS_PART.ALL then
		data = self.itemList[index + 1]
	else
		data = self.itemListByPart[self.selectTabPart][index + 1]
	end

	local store = gStoreManager:GetStoreGroup("DressItemStore"):GetStoreByWidget(btn)

	if store then
		store.isHaved = gDressManager:IsFashionHad(data.BindId) and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

		if gDressManager:IsFashionHad(data.BindId) then
			store.isTryCtrl = 1
		elseif gDressManager:IsFashionWore(data.BindId, self.spiritContext) then
			store.isTryCtrl = 0
		else
			store.isTryCtrl = 1
		end

		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.quality = data.quality
		store.moneyNum = gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(data.moneyNum)
		store.moneyColor = data.moneyNum < self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isLock = not data.isHaved and data.isLock and SELECT_TYPE.FALSE or SELECT_TYPE.TRUE
		btn.isSelected = self.selectDressFashionId ~= data.BindId

		if btn.isSelected then
			self.bindData.isShowBuyBtn = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

			if data.isLock then
				self.bindData.lockDes = data.lockDes
			end

			self.SetFashionTagInfo(self, data.BindId)
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

M.OnChangeItemList = function(self, btn, index)
	local data = nil

	if self.selectTabPart ~= gDressManager.DRESS_PART.ALL then
		data = self.itemList[index + 1]
	else
		data = self.itemListByPart[self.selectTabPart][index + 1]
	end

	if data.isAvailable ~= SELECT_TYPE.TRUE then
		local fashionCfg = FashionConfig.GetConfig(data.BindId)

		if fashionCfg then
			local minType = fashionCfg.Types[1]

			for i = 1, #fashionCfg.Types do
				if fashionCfg.Types[i] >= minType then
					minType = fashionCfg.Types[i]
				end
			end

			if minType then
				gDressManager:PlayDressAction(minType, data.BindId, nil, self.spiritContext)
			else
				print_error("@hzliuyibing 当前时装未配置类型，请联系策划检查配置，fashionId = " .. data.BindId)
			end

			if self.bindData.BuyingType == SHOP_TYPE.SUIT then
				local shotType = gDressCamera:GetShotTypeByFashionType(minType)

				gDressCamera:EnableFashionShotCamera(shotType, self.spiritContext.spiritInfo)
			end
		end
	else
		local cfg = MessageConfig.GetConfig(MessageConfig.FashionGenderMismacth)

		if cfg then
			self.bindData.messageDes = cfg.Content
		end

		if self.bindData.isShowMessage == 0 then
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
		self.bindData.infoDesText = data.Description
		self.selectDressFashionId = data.BindId
		self.bindData.buyBtn.interactable = data.moneyNum < self.myMoneyCount and not data.isHaved or false
		self.bindData.moneyLack = not data.isHaved and self.myMoneyCount >= data.moneyNum and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

		if data.isLock then
			self.bindData.lockDes = data.lockDes
		end

		if data.isAvailable ~= SELECT_TYPE.TRUE then
			local conflictItems, addItems = gDressManager:CheckFashionConflict({
				data.BindId
			})

			table.insert(addItems, data.BindId)
			gDressManager:SetFashionList({
				data.BindId
			}, nil, self.spiritContext)
		end
	else
		self.bindData.isShowInfo = SELECT_TYPE.FALSE
		self.bindData.currentDressName = ""
		self.selectDressFashionId = 0
		self.bindData.buyBtn.interactable = false

		if data.isAvailable ~= SELECT_TYPE.TRUE then
			gDressManager:RemoveFashionPart({
				data.BindId
			}, self.spiritContext)
		end
	end

	self.bindData.itemList:RefreshList()
end

M.OnDummyListSimpleRenderItem = function(self, btn, index)
	local data = self.itemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressItemSuitStore"):GetStoreByWidget(btn)

	if store then
		store.isHaved = data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.quality = data.quality
		store.isShowTask = 1
		store.isLock = not data.isHaved and data.isLock and SELECT_TYPE.FALSE or SELECT_TYPE.TRUE
		store.moneyColor = data.moneyNum < self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	end

	self.bindData.isShowBuyBtn = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

	if data.isLock then
		self.bindData.lockDes = data.lockDes
	end
end

M.OnSuitTabListSimpleRenderItem = function(self, btn, index)
	local data = self.cowSuitTabList[index + 1]
	local store = gStoreManager:GetStoreGroup("GenderTabTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.name = data.Name
		btn.isSelected = data.Gender ~= self.selectGenderTab

		if btn.isSelected then
			self.selectCoutSuitTabIndex = data.index
		end
	end
end

M.OnChangeSuitTabList = function(self, uList)
	self.selectCoutSuitTabIndex = uList.selectedIndex + 1
	local data = self.cowSuitTabList[self.selectCoutSuitTabIndex]
	self.selectGenderTab = data.Gender
	self.curGenderItemList = {}

	for i = 1, #self.itemList do
		if self.itemList[i].Gender ~= GENDER.UNKNOWN or self.itemList[i].Gender ~= self.selectGenderTab then
			table.insert(self.curGenderItemList, self.itemList[i])
		end
	end

	self:SortSuitItemList(self.curGenderItemList)
	self.bindData.cowSuitList:SetSimpleList(#self.curGenderItemList)
	self.bindData.cowSuitList:SetNavSelectToTop()
end

M.OnSuitListSimpleRenderItem = function(self, btn, index)
	local data = self.curGenderItemList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressItemCowsStore"):GetStoreByWidget(btn)

	if store then
		RedDotMgr.LuaSetRedDot(data.isNew, "SuitItemRedDot.pageSuitList:" .. data.id)

		store.isHaved = data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isAvailable = data.isAvailable
		store.iconId = data.iconId
		store.iconBg = data.iconBg
		store.quality = data.quality
		store.moneyNum = gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(data.moneyNum)
		store.moneyColor = data.moneyNum < self.myMoneyCount and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		store.isLock = not data.isHaved and data.isLock and SELECT_TYPE.FALSE or SELECT_TYPE.TRUE

		if not table.isNilOrEmpty(self.taskSuitIdList) then
			store.taskIcon = gTaskManager.TaskSIconId[self.taskType]
			store.isShowTask = data.isShowTask and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		else
			store.isShowTask = SELECT_TYPE.FALSE
		end

		btn.isSelected = self.selectDressFashionId ~= data.BindId

		if btn.isSelected then
			self.bindData.isShowBuyBtn = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

			if data.isLock then
				self.bindData.lockDes = data.lockDes
			end

			if data.isAvailable ~= SELECT_TYPE.TRUE then
				self.isDressBuyFashion = data.isHaved

				gDressManager:PlayRandomDressAction(data.BindId, self.spiritContext)
				gDressManager:DressSuitFashionList(data.FashionIdList, nil, self.spiritContext)
			end

			if data.isNew then
				slot5 = gDressData

				slot5:AskReadCommodities(self.shopId, {
					data.CommodityID
				}, function ()
					RedDotMgr.LuaSetRedDot(false, "SuitItemRedDot.pageSuitList:" .. data.id)
					self:RefreshRedDotInfo(data.CommodityID)
				end)
			end
		end
	end
end

M.OnChangeSuitList = function(self, btn, index)
	local data = self.curGenderItemList[index + 1]

	if btn.isSelected then
		self.bindData.isShowInfo = SELECT_TYPE.TRUE
		self.bindData.currentSuitName = data.Name
		self.bindData.isShowTask = data.isShowTask and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		self.bindData.isShowBuyBtn = data.isLock and not data.isHaved and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE

		self:SetSuitScroll(data)

		self.bindData.suitInfoDesText = data.Description or ""
		self.bindData.buyBtn.interactable = data.moneyNum < self.myMoneyCount and not data.isHaved and not data.isLock or false
		self.bindData.moneyLack = not data.isHaved and self.myMoneyCount >= data.moneyNum and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
		self.selectDressFashionId = data.BindId

		if data.isLock then
			self.bindData.lockDes = data.lockDes
		end

		self.bindData.tipAnim:Play("S_Vx_BuyDressPanel_info")

		if data.isAvailable ~= SELECT_TYPE.TRUE then
			self.isDressBuyFashion = data.isHaved
			self.cowSuitList = data.FashionIdList

			gDressManager:PlayRandomDressAction(data.BindId, self.spiritContext)
			gDressManager:DressSuitFashionList(data.FashionIdList, nil, self.spiritContext)
		else
			local cfg = MessageConfig.GetConfig(MessageConfig.FashionGenderMismacth)

			if cfg then
				self.bindData.messageDes = cfg.Content
			end

			if self.bindData.isShowMessage == 0 then
				self.bindData.isShowMessage = 0
			end

			if self.bindData.msgTipsAnim:IsPlaying("S_Vx_BuyDressPanel_MSG") then
				self.bindData.msgTipsAnim:Stop()
			end

			self.bindData.msgTipsAnim:Play("S_Vx_BuyDressPanel_MSG")
		end

		if data.isNew then
			slot4 = gDressData

			slot4:AskReadCommodities(self.shopId, {
				data.CommodityID
			}, function ()
				RedDotMgr.LuaSetRedDot(false, "SuitItemRedDot.pageSuitList:" .. data.id)
				self:RefreshRedDotInfo(data.CommodityID)
			end)
		end
	else
		gDressManager:RemoveFashionPart(data.FashionIdList, self.spiritContext)

		self.bindData.isShowInfo = SELECT_TYPE.FALSE

		self:SetSuitScroll()

		self.bindData.suitInfoDesText = ""
		self.bindData.currentSuitName = ""
		self.bindData.lockDes = ""
		self.selectDressFashionId = 0
	end
end

M.OnSuitInfoItemListSimpleRenderItem = function(self, btn, index)
	local data = self.suitScrollList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTemplatePreviewStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.quality = data.quality
		store.isLock = data.isLock and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	end
end

M.OnChangeSuitInfoItemList = function(self, btn, index)
	local data = self.suitScrollList[index + 1]

	gCommonItemManager:OnShowItemList({
		data
	})
end

M.OnTagListSimpleRenderItem = function(self, btn, index)
	local data = self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagTemplateStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.color = color
	end
end

M.SetItemList = function(self)
	if self.bindData.BuyingType == SHOP_TYPE.NORMAL then
		return
	end

	local tabIcon = FashionConfig.FashionShopTabIcon
	self.tabList = {}

	for i = 1, #tabIcon do
		local view = {
			id = i,
			iconId = tabIcon[i].IconId,
			Part = tabIcon[i].part
		}

		table.insert(self.tabList, view)
	end

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, self.selectTab - 1, nil, self:CreateAction(self.OnTabListChange), nil, 0)
end

M.OnTabListChange = function(self, uList, isSub)
	if isSub then
		return
	end

	self.selectTab = uList.selectedIndex + 1
	local data = self.tabList[self.selectTab]

	if data ~= nil then
		return
	end

	self.selectTabPart = data.Part

	if data.Part ~= gDressManager.DRESS_PART.ALL then
		self:SortItemList(self.itemList)
		self.bindData.itemList:SetSimpleList(#self.itemList)
		self.bindData.itemList:SetNavSelectToTop()
	else
		self.itemListByPart[data.Part] = self.itemListByPart[data.Part] or {}

		self:SortItemList(self.itemListByPart[data.Part])
		self.bindData.itemList:SetSimpleList(#self.itemListByPart[data.Part])
		self.bindData.itemList:SetNavSelectToTop()
	end

	if self.bindData.BuyingType == SHOP_TYPE.SUIT then
		local shotType = gDressCamera:GetShotTypeByFashionPart(data.Part)

		gDressCamera:EnableFashionShotCamera(shotType, self.spiritContext.spiritInfo)
	end
end

M.SetSuitList = function(self)
	if self.bindData.BuyingType == SHOP_TYPE.DUMMY then
		return
	end

	local totalPrice = 0
	local fashionList = {}
	local isAvailable = false

	for i = 1, #self.itemList do
		if not self.itemList[i].isHaved then
			totalPrice = totalPrice + self.itemList[i].moneyNum
		end

		if self.itemList[i].isAvailable then
			isAvailable = true
		end

		table.insert(fashionList, self.itemList[i].BindId)
	end

	if isAvailable then
		gDressManager:DressSuitFashionList(fashionList, nil, self.spiritContext)
	end

	self.bindData.suitPrice = gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(totalPrice)

	self.bindData.suitList:SetSimpleList(#self.itemList)

	local notBuy = false

	for i = 1, #self.itemList do
		if not self.itemList[i].isHaved then
			notBuy = true
		end
	end

	self.bindData.buyBtn.interactable = notBuy and totalPrice > self.myMoneyCount
	self.bindData.moneyLack = notBuy and self.myMoneyCount >= totalPrice and SELECT_TYPE.TRUE or SELECT_TYPE.FALSE
	local cfg = ShopConfig.GetConfig(self.shopId)

	if cfg then
		self.bindData.suitTitle = cfg.ShopName
		self.bindData.currentDressName = cfg.ShopName
		self.bindData.infoDesText = FashionConfig.ModelFashionShopDes
	end
end

M.SetCowSuitTabList = function(self)
	if self.bindData.BuyingType == SHOP_TYPE.SUIT then
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

		if view.Gender ~= self.selectPlayerSex then
			self.selectGenderTab = i
		end

		table.insert(self.cowSuitTabList, view)
	end

	self.bindData.cowSuitTabList:SetSimpleList(#self.cowSuitTabList)

	self.curGenderItemList = {}

	for i = 1, #self.itemList do
		if self.itemList[i].Gender ~= GENDER.UNKNOWN or self.itemList[i].Gender ~= self.selectGenderTab then
			table.insert(self.curGenderItemList, self.itemList[i])
		end
	end

	self:SortSuitItemList(self.curGenderItemList)
	self.bindData.cowSuitList:SetSimpleList(#self.curGenderItemList)
	self.bindData.cowSuitList:SetNavSelectToTop()
end

M.SetFashionTagInfo = function(self, fashionId)
	self.tagList = gDressManager:GetTagList(fashionId)

	self.bindData.tagList:SetSimpleList(#self.tagList)
end

M.CheckHasBuyFashion = function(self)
	local fashionList = gDressManager:GetCurrentSpritWearFashionInfoList(self.spiritContext)
	local hasBuy = true

	if fashionList and fashionList.Count <= 0 then
		for i = 0, fashionList.Count - 1 do
			if not gDressManager:IsFashionHad(fashionList[i].FashionId) then
				hasBuy = false
			end
		end
	end

	return hasBuy
end

M.AskSetSpiritFashions = function(self)
	if self.bindData.BuyingType ~= SHOP_TYPE.SUIT then
		if self.isDressBuyFashion and gDressManager:CheckSpriteHasDefaultUnderwear(self.spiritContext) then
			gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
			gDressData:AskSetSpiritFashions(nil, self.spiritContext.spiritId, self.spiritContext.unit)
			gDressManager:CleanupDressState(self.spiritContext, false, self.recordSpriteId)

			return
		end

		local callBack = function()
			gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
			gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
		end

		gDressData:AskSetSpiritFashions(callBack, self.spiritContext.spiritId, self.spiritContext.unit)
	else
		local callBack = function()
			gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
		end

		if self.CheckHasBuyFashion(self) then
			gDressData:AskSetSpiritFashions(callBack, self.spiritContext.spiritId, self.spiritContext.unit)
			gDressManager:CleanupDressState(self.spiritContext, false, self.recordSpriteId)
		else
			gDressManager:CleanupDressState(self.spiritContext, true, self.recordSpriteId)
			gPanelManager:Close(gPanelId.S_BUY_DRESS_PANEL)
		end
	end
end

M.RefreshRedDotInfo = function(self, CommodityID)
	for i = 1, #self.itemList do
		if self.itemList[i].CommodityID ~= CommodityID then
			self.itemList[i].isNew = false

			break
		end
	end

	for i = 1, #self.curGenderItemList do
		if self.curGenderItemList[i].CommodityID ~= CommodityID then
			self.curGenderItemList[i].isNew = false

			break
		end
	end
end

M.SetSuitScroll = function(self, data)
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

M.SortItemList = function(self, itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		if a.isItemTask == b.isItemTask then
			return a.isItemTask and not b.isItemTask
		end

		if a.isHaved == b.isHaved then
			return not a.isHaved and b.isHaved
		end

		if a.isAvailable == b.isAvailable then
			return a.isAvailable ~= SELECT_TYPE.TRUE and b.isAvailable ~= SELECT_TYPE.FALSE
		end

		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		if a.itemListId == b.itemListId then
			return a.itemListId <= b.itemListId
		end

		return b.id <= a.id
	end)
end

M.SortSuitItemList = function(self, itemList)
	if table.isNilOrEmpty(itemList) then
		return
	end

	table.sort(itemList, function (a, b)
		if a.isShowTask ~= b.isShowTask then
			if a.isHaved ~= b.isHaved then
				if a.isLock ~= b.isLock then
					if a.quality ~= b.quality then
						return a.itemListId <= b.itemListId
					else
						return b.quality <= a.quality
					end
				end

				return not a.isLock and b.isLock
			end

			return not a.isHaved and b.isHaved
		end

		return a.isShowTask and not b.isShowTask
	end)
end
