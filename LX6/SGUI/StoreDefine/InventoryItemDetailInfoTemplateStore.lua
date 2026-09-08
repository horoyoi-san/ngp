-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InventoryItemDetailInfoTemplateStore.lua
-- Decompiled from: 01798_InventoryItemDetailInfoTemplateStore.lua_3fe786deb8dc.luajit

local UNavigationMgr = SGUI.UNavigationMgr
local Screen = UnityEngine.Screen
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ExtractionShooterItemConfig = LTConfig.ExtractionShooterItemConfig
C_InventoryItemDetailInfoTemplateStore = DefClass("C_InventoryItemDetailInfoTemplateStore", C_InventoryItemDetailInfoTemplateStore, C_StoreGroup)
GroupName2Class.InventoryItemDetailInfoTemplateStore = C_InventoryItemDetailInfoTemplateStore
local M = C_InventoryItemDetailInfoTemplateStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local MONEY_COLOR = {
	["2g\\xa3\\xa3\\xa2m"] = 0,
	["\\xe9\\xe9107\\xdc"] = 2,
	["\\x8f\\x986\\x88E\\xd0"] = 1
}
local SCREEN_HEIGHT_OCCUPANCY = 0.8
local TOOLTIP_TOP_HEIGHT = 300.14
local TOOLTIP_BOTTOM_HEIGHT = 883.78 - TOOLTIP_TOP_HEIGHT - 555
local LAYOUT_BOX_RESERVED_HEIGHT = 80.16
local COUNTER_HEIGHT = 68
local SUM_HEIGHT = 38
local MAXH = 5
local MAXW = 5

M.ctor = function(self)
	self.OnInit(self)

	self.mgr = gCommonItemManager
end

M.OnInit = function(self)
	self.range = {
		0,
		0
	}
	self.val = 0
	self.preTime = 0
	self.selectedItem = {}
	self.onConfirmCallback = nil
	self.onCheckBtnVisible = nil
	self.onValueChangeCallback = nil
	self.stepInterval = 1
	self.vibrationId = "TabPress"
	self.npcShopInfo = nil
end

M.OnAwake = function(self)
	self.UpdateEffectiveMaxHeight(self)

	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnConfirmBtnClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnSubBackBtnClick")
	self.bindData.hyperLinkBtn.luaClick = self.CreateAction(self, self.OnHyperLinkBtnClick)
	self.bindData.lockBtn.luaClick = self.CreateAction(self, "OnLockBtnClick")
	self.bindData.descList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderDescItem)
	self.bindData.descList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderDescItem)
	self.bindData.descList.luaSimpleClick = self.CreateAction(self, self.OnDescItemClick)
	self.bindData.descList.onGetTIndex = self.CreateAction(self, self.OnGetDescIndex)
	self.bindData.descList.maxHeight = self.effectiveMaxHeight

	self.bindData.descList.luaLayoutSet = function()
		self:UpdateEffectiveMaxHeight()

		self.bindData.descList.maxHeight = self.effectiveMaxHeight or self.maxHeight
	end

	self.bindData.elementList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItemElementList)
	self.bindData.elementList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderItemElementList)
	self.bindData.tagList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderToolTipTagList)
	self.bindData.tagList.luaSimpleDynamicRenderItem = self.CreateAction(self, self.OnRenderToolTipTagList)
	self.descList = {}
	local refreshInstanceStateAction = self.CreateAction(self, "RefreshInstanceState")
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, self.OnPackItemChange),
		[gEventConstants.SPIRIT_WEAPON_SLOT_ADD] = refreshInstanceStateAction,
		[gEventConstants.SPIRIT_WEAPON_SLOT_REMOVE] = refreshInstanceStateAction,
		[gEventConstants.CURRENT_WEAPON_SLOT_ADD] = refreshInstanceStateAction,
		[gEventConstants.CURRENT_WEAPON_SLOT_REMOVE] = refreshInstanceStateAction,
		[gEventConstants.ARMORY_WEAPON_ADD] = refreshInstanceStateAction,
		[gEventConstants.ARMORY_WEAPON_REMOVE] = refreshInstanceStateAction,
		[gEventConstants.ARMORY_WEAPON_UPDATE] = refreshInstanceStateAction
	}
end

M.OnRenderDescItem = function(self, btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnRenderDescItem(btn, index, data)
end

M.OnDescItemClick = function(self, btn, index)
	local data = self.descList[index + 1]

	self.mgr:OnDescItemClick(btn, data)
end

M.OnGetDescIndex = function(self, index)
	return self.descList[index + 1].tIndex
end

M.OnRenderToolTipTagList = function(self, btn, index, data)
	self.mgr:OnRenderToolTipTagList(btn, index, self.tagList[index + 1])
end

M.OnRenderItemElementList = function(self, btn, index)
	local data = self.elementList[index + 1]

	self.mgr:OnRenderItemElementList(btn, index, self.elementList[index + 1])
end

M.SetSelectedItem = function(self, item, checkBtnVisCallback, onConfirmCallback, onValueChangeCallback, parent)
	self.onConfirmCallback = onConfirmCallback
	self.npcShopInfo = nil
	self.onCheckBtnVisible = checkBtnVisCallback
	self.onValueChangeCallback = onValueChangeCallback
	self.parentArea = parent and parent or UNavigationMgr.Inst.CurrentActiveArea
	self.moneyIconText = self.mgr:GetCurrMoneyRichText()
	self.selectedItem = item
	self.range = item.range or {}

	if #self.range > 2 and self.range[2] >= self.range[1] then
		self.range[2] = self.range[1]
		self.range[1] = self.range[1]
	end

	self.stepInterval = item.stepInterval or 1
	self.vibrationId = item.vibrationId or "TabPress"

	self:OnRefreshInfo()
end

M.RefreshBasicInfo = function(self, itemData, name, quality, iconId, showCount, itemId)
	self.bindData.typeQuality = self.mgr:GetItemQualityLabel(itemData)

	self.bindData:Commit("quality", quality, COMMIT_FORCE)

	self.bindData.nameLabel = name
	self.bindData.iconId = iconId
	self.bindData.showCountLabel = showCount and 1 or 0
	self.bindData.haveLabel = self:GetHaveLabel(itemId)
end

M.GetHaveLabel = function(self, itemId)
	local itemNum = self.mgr:GetItemNum(itemId)

	if self.mgr:IsBulletItem(itemId) then
		local cfg = ConsumableConfig.GetConfig(itemId)
		local maxCount = cfg and self.mgr.itemCountLimitMax[cfg.SubType]

		if maxCount and maxCount <= 0 then
			local format = nil

			if itemNum ~= 0 then
				format = ConsumableConfig.HaveNumZeroFormat
			elseif maxCount < itemNum then
				format = ConsumableConfig.HaveNumFullFormat
			else
				format = ConsumableConfig.HaveNumNotFullFormat
			end

			return string.format(format, itemNum, maxCount)
		end
	end

	return itemNum
end

M.SetSelectedNpcShopItem = function(self, shopItemInfo, moneys, onBuyCallback, moneyIconText, onValueChangeExtra)
	local cId = self.mgr:TryConvertToConsumableId(shopItemInfo.BindId)
	self.npcShopInfo = shopItemInfo
	self.npcShopMoneys = moneys
	self.npcShopCallback = onBuyCallback
	self.npcShopMoneyIconText = moneyIconText
	self.npcShopValueChangeExtra = onValueChangeExtra
	self.selectedItem = {
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
		TemplateId = cId,
		isTarkov = shopItemInfo.isTarkov
	}
	self.moneyIconText = moneyIconText or shopItemInfo.MoneyRichTextIcon or self.mgr:GetCurrMoneyRichText()
	self.onConfirmCallback = onBuyCallback
	self.onCheckBtnVisible = nil
	self.onValueChangeCallback = nil
	self.useStr = nil

	self:OnRefreshInfo()

	if table.isNilOrEmpty(self.data) then
		return
	end

	self:RefreshBasicInfo(self.data, shopItemInfo.Name, shopItemInfo.Quality, shopItemInfo.IconId, self.data.showCount, cId)

	self.bindData.stateCtrl = shopItemInfo.State
	self.bindData.unlockText = shopItemInfo.UnlockDesc
	local priceColorCtrl, priceChangePercent, originalPriceLabel = self:GetNpcShopPriceChangeInfo(shopItemInfo)
	self.bindData.moneyColorCtrl = priceColorCtrl
	self.bindData.priceChangePercent = priceChangePercent
	self.bindData.originalPriceLabel = originalPriceLabel
	local canPurchase = shopItemInfo.State ~= 0
	self.bindData.showCounter = BOOL2CTL[shopItemInfo.ShowCount and canPurchase]
	self.bindData.showSumCtrl = BOOL2CTL[shopItemInfo.ShowCount and canPurchase]

	self:RefreshCutLine()
	self:UpdateEffectiveMaxHeight()

	self.bindData.descList.maxHeight = self.effectiveMaxHeight or self.maxHeight
	local buyText = LTConfig.TextCommonTextConfig.GetConfig(74000531).Text
	self.bindData.buyText = buyText
	self.bindData.btnNameLabel = buyText
	self.bindData.showBtn = BOOL2CTL[true]

	if self.bindData.confirmBtn then
		self.bindData.confirmBtn.interactable = true
	end

	self.onConfirmCallback = onBuyCallback

	if shopItemInfo.ShowCount then
		self.onValueChangeCallback = function(val)
			local totalPrice = val * shopItemInfo.PriceCurrent
			local notEnough = self.mgr:GetPackItemNum(shopItemInfo.Money) <= totalPrice
			local priceStr = self.moneyIconText .. tostring(totalPrice)

			if notEnough then
				priceStr = "#R" .. priceStr .. "#z"
			end

			self.bindData.priceText = priceStr
			self.bindData.moneyNotEnoughCtrl = BOOL2CTL[notEnough]
			local _, _, originalPriceLabel = self:GetNpcShopPriceChangeInfo(shopItemInfo, val)
			self.bindData.originalPriceLabel = originalPriceLabel

			if onValueChangeExtra then
				onValueChangeExtra(val)
			end
		end
	else
		self.onValueChangeCallback = onValueChangeExtra
	end

	if table.isNilOrEmpty(shopItemInfo.range) then
		local maxNum = shopItemInfo.LimitOnceNum
		local canAfford = math.floor(moneys[shopItemInfo.Money] / shopItemInfo.PriceCurrent)
		maxNum = math.min(maxNum, canAfford)

		if not shopItemInfo.NoLimit then
			maxNum = math.min(maxNum, shopItemInfo.RemainNum)
		end

		maxNum = math.max(1, maxNum)
		self.range = {
			1,
			maxNum
		}
	else
		self.range = shopItemInfo.range
	end

	if self.bindData.confirmBtn then
		self.bindData.confirmBtn.interactable = self.range[1] < self.range[2] and self.range[2] >= 0
	end

	self.InitCounter(self)
end

M.GetNpcShopPriceChangeInfo = function(self, shopItemInfo, count)
	local discount = shopItemInfo.Discount or 100
	local colorCtrl = MONEY_COLOR.NORMAL
	local changePercent = ""
	local originalPriceLabel = ""

	if discount >= 100 then
		colorCtrl = MONEY_COLOR.DISCOUNT
		changePercent = string.format("-%d%%", 100 - discount)

		if shopItemInfo.PriceOriginal and shopItemInfo.PriceOriginal <= 0 then
			originalPriceLabel = self.moneyIconText .. tostring(shopItemInfo.PriceOriginal * (count or 1))
		end
	elseif discount <= 100 then
		colorCtrl = MONEY_COLOR.PREMIUM
		changePercent = string.format("+%d%%", discount - 100)
	end

	return colorCtrl, changePercent, originalPriceLabel
end

M.OnSubBackBtnClick = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() and self.parentArea then
		UNavigationMgr.Inst.CurrentActiveArea = self.parentArea
	end
end

M.OnHyperLinkBtnClick = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.hyperNavigationArea
	end
end

M.IsWeaponOrBattleItems = function(self, subType)
	return subType ~= ConsumableTypeConfig.Weapon or subType ~= ConsumableTypeConfig.BattleItems
end

M.ShouldShowAssembleBtn = function(self)
	local data = self.data

	return data and data.fromNewInventoryPanel ~= true and self:IsWeaponOrBattleItems(data.subType) and not data.sellMode and not data.selectMode and not self.npcShopInfo
end

M.OnConfirmBtnClick = function(self)
	if self.ShouldShowAssembleBtn(self) then
		gPanelManager:CheckShow(gPanelId.WEAPON_ARMORY_PANEL)

		return
	end

	if self.onConfirmCallback then
		self.onConfirmCallback(self.data, self.val, self.bindData.confirmBtn)
	end
end

M.GetCurrentWeaponData = function(self)
	local data = self.data or self.selectedItem
	local uniqueId = data and data.UniqueId

	if not uniqueId or uniqueId ~= 0 then
		return nil
	end

	local packItem = self.mgr.packItemDict and self.mgr.packItemDict[uniqueId]

	return packItem and (packItem.WeaponData or self.mgr:GetWeaponDetailByUid(uniqueId)) or nil
end

M.OnLockBtnClick = function(self)
	local weaponData = self.GetCurrentWeaponData(self)

	if not weaponData or gWeaponManager:GetFlag(weaponData.OperatorFlags, 1) ~= 1 then
		return
	end

	local instanceId = weaponData.InstanceId
	local newState = not weaponData.IsPlayerLocked
	slot4 = self.bindData.lockBtn

	slot4:SetSelected(newState)

	slot4 = gWeaponManager

	slot4:AskSetWeaponLock(instanceId, newState, function (success)
		if not self.STATE_Started then
			return
		end

		local currentWeaponData = self:GetCurrentWeaponData()

		if currentWeaponData and currentWeaponData.InstanceId ~= instanceId then
			local selected = success and newState or currentWeaponData.IsPlayerLocked ~= true

			self.bindData.lockBtn:SetSelected(selected)
		end
	end)
end

M.RefreshTarkovExchange = function(self)
	if not self.data or not self.data.itemId then
		self.bindData.showAnantarkovInfoCtrl = BOOL2CTL[false]

		return
	end

	local cfg = ConsumableConfig.GetConfig(self.data.itemId)
	local extractionId = cfg and cfg.ExtractionId or 0
	local showTarkovGrid = extractionId == 0 and (gExtractionShooterManager.CheckInGame() or self.data.isTarkov)
	self.bindData.showAnantarkovInfoCtrl = BOOL2CTL[showTarkovGrid]

	if showTarkovGrid and self.bindData.tarkovVIew then
		local extCfg = ExtractionShooterItemConfig.GetConfig(extractionId)

		if extCfg then
			self.bindData.tarkovVIew:SetSimpleList(MAXH * MAXW)

			for y = 1, MAXH do
				for x = 1, MAXW do
					local occupied = x < extCfg.Volume.x and y > extCfg.Volume.y

					self.bindData.tarkovVIew:SetItemSelected((y - 1) * MAXW + x - 1, occupied)
				end
			end
		end
	end
end

M.OnRefreshInfo = function(self)
	if not self.STATE_EnableOnce or not self.rootWidget then
		return
	end

	if table.isNilOrEmpty(self.selectedItem) then
		return
	end

	self.data = self.mgr:TryGetItemInfo(self.selectedItem)
	self.bindData.inTestCtrl = BOOL2CTL[not gCS.LuaUtils.IsPublish]

	if table.isNilOrEmpty(self.data) then
		print_error("[InventoryPanelStore] RefreshPage data is nil")

		return
	end

	self.bindData.nameLabel = self.data.name

	self.bindData:Commit("quality", self.data.quality, COMMIT_FORCE)

	self.bindData.iconId = self.data.iconId
	self.bindData.typeQuality = self.mgr:GetItemQualityLabel(self.data)
	self.bindData.haveLabel = self:GetHaveLabel(self.data.itemId)
	self.bindData.showCountLabel = BOOL2CTL[self.data.showCount]

	self:RefreshInstanceState()

	local systemPrice = self.mgr:GetSystemPrice(self.data.itemId)
	self.bindData.isBindCtrl = BOOL2CTL[self.data.IsBind ~= true]

	self:RefreshTarkovExchange()

	self.bindData.showValueCtrl = BOOL2CTL[systemPrice >= 0]

	if systemPrice <= 0 then
		self.bindData.valueText = self.moneyIconText .. tostring(systemPrice)
	end

	self.bindData.moneyColorCtrl = MONEY_COLOR.NORMAL
	self.bindData.priceChangePercent = ""
	self.bindData.originalPriceLabel = ""
	local action = nil
	local hasUseStr = false

	if self.data.sellMode then
		self.useStr = nil
		local sellTextCfg = LTConfig.TextScriptTextConfig.GetConfig(89901461)
		local shopTabTypeText = LTConfig.ShopConfig and LTConfig.ShopConfig.ShopTabTypeText
		self.bindData.btnNameLabel = sellTextCfg and sellTextCfg.Text or shopTabTypeText and shopTabTypeText[2] or ""
	elseif type(self.data.confirmTitle) ~= "string" and not string.is_null_or_empty(self.data.confirmTitle) then
		self.bindData.btnNameLabel = self.data.confirmTitle
	elseif self.ShouldShowAssembleBtn(self) then
		self.useStr = nil
		self.bindData.btnNameLabel = LTConfig.TextScriptTextConfig.GetConfig(89901125).Text
	else
		self.useStr, action = gItemHyperLinkManager:GetUseStr(self.data.itemId)
		hasUseStr = not string.is_null_or_empty(self.useStr)

		if hasUseStr then
			local isItemUsable = nil

			if self.onCheckBtnVisible then
				isItemUsable = self.onCheckBtnVisible(self.data)
			elseif self.data.fromNewInventoryPanel then
				local consumableTypeCfg = ConsumableTypeConfig.GetConfig(self.data.subType)
				isItemUsable = consumableTypeCfg and consumableTypeCfg.CanUse or false
			end

			if isItemUsable then
				self.bindData.btnNameLabel = LTConfig.TextScriptTextConfig.GetConfig(89901124).Text
			else
				self.bindData.btnNameLabel = self.useStr
				self.onConfirmCallback = action and action.callback or self.onConfirmCallback
			end
		else
			self.bindData.btnNameLabel = LTConfig.TextScriptTextConfig.GetConfig(89901124).Text
		end
	end

	local btnVisible = false

	if self.onCheckBtnVisible then
		btnVisible = self.onCheckBtnVisible(self.data)
	elseif self.data.sellMode then
		btnVisible = self.data.canSell ~= true
	elseif self.data.fromNewInventoryPanel then
		local consumableTypeCfg = ConsumableTypeConfig.GetConfig(self.data.subType)
		btnVisible = consumableTypeCfg and consumableTypeCfg.CanUse or false
	end

	if self.data.fromNewInventoryPanel and not self.data.sellMode and not self.data.selectMode then
		btnVisible = btnVisible or not string.is_null_or_empty(self.useStr)
	end

	if self:ShouldShowAssembleBtn() then
		btnVisible = true
	end

	self.bindData.showBtn = BOOL2CTL[btnVisible]

	if btnVisible then
		self.bindData.confirmBtn.interactable = true
	end

	self.descList = {}
	local hasSource = self.mgr:GetItemDescList(self.data, self.descList)
	self.bindData.hasHyperLink = BOOL2CTL[hasSource]
	self.elementList = self.mgr:GetItemElementList(self.data.itemId, self.data)

	self.bindData.elementList:SetSimpleList(#self.elementList)

	self.tagList = self.mgr:GetItemTagList(self.data)

	self.bindData.tagList:SetSimpleList(#self.tagList)

	self.bindData.showTagCtrl = BOOL2CTL[#self.tagList >= 0]
	local hasRange = not table.isNilOrEmpty(self.range) and (self.data.canSell ~= true or self.data.fromNewInventoryPanel ~= true) and btnVisible
	self.bindData.showCounter = BOOL2CTL[hasRange]

	if hasRange then
		self.InitCounter(self)
	end

	if self.data.sellMode then
		self.RefreshSellInfo(self, self.val)
	else
		self.bindData.showSumCtrl = 0
	end

	self.bindData.itemType = self.mgr:GetItemDisplayType(self.data.itemId)
	local showCreateMoney = self.data.subType ~= ConsumableTypeConfig.QuantumWallet
	self.bindData.showCreateMoney = BOOL2CTL[showCreateMoney]

	self:RefreshQuantumWallet()
	self:RefreshCutLine()
	self.bindData.descList:SetSimpleList(#self.descList)
end

M.RefreshSellInfo = function(self, count)
	count = math.max(tonumber(count) or 1, 1)
	local canSell = self.data.canSell ~= true
	self.bindData.showSumCtrl = canSell and 1 or 0

	self:RefreshCutLine()

	if canSell then
		local totalPrice = (self.data.sellPrice or 0) * count
		self.bindData.priceText = self:GetPriceText(totalPrice, false)
	end

	self.bindData.moneyNotEnoughCtrl = BOOL2CTL[false]

	if self.bindData.confirmBtn then
		self.bindData.confirmBtn.interactable = canSell
	end

	local colorCtrl = MONEY_COLOR.NORMAL
	local changePercent = ""
	local originalPriceLabel = ""

	if canSell then
		local discount = gShopManager and gShopManager:GetShopGeneralBuyBackDiscount(self.data.shopId) or 100

		if discount <= 100 then
			colorCtrl = MONEY_COLOR.DISCOUNT
			changePercent = string.format("+%d%%", discount - 100)
		elseif discount >= 100 then
			colorCtrl = MONEY_COLOR.PREMIUM
			changePercent = string.format("-%d%%", 100 - discount)
		end

		if discount == 100 then
			local packItem = self.mgr.packItemDict and self.mgr.packItemDict[self.data.UniqueId]
			local originalPrice = packItem and self.mgr:GetPackItemSellPrice(packItem) or self.mgr:GetItemSellPrice(self.data.itemId)

			if originalPrice and originalPrice <= 0 then
				originalPriceLabel = self.GetPriceText(self, originalPrice * count, false)
			end
		end
	end

	self.bindData.moneyColorCtrl = colorCtrl
	self.bindData.priceChangePercent = changePercent
	self.bindData.originalPriceLabel = originalPriceLabel
end

M.UpdateEffectiveMaxHeight = function(self)
	local isPC = gCS.LuaUtils.IsNonMobileAdaptive()
	local screenLogicalHeight = Screen.height / gCS.LuaUtils.GetScreenScalerRatio()
	local platformScale = isPC and SGUI.UIConfig.instance:GetCurrentAdaptationScale() or 1
	local occupiedHeight = screenLogicalHeight / platformScale * SCREEN_HEIGHT_OCCUPANCY
	self.maxHeight = occupiedHeight - TOOLTIP_TOP_HEIGHT - TOOLTIP_BOTTOM_HEIGHT - LAYOUT_BOX_RESERVED_HEIGHT
	local deduct = 0

	if self.bindData.showCounter ~= BOOL2CTL[true] then
		deduct = deduct + COUNTER_HEIGHT
	end

	if self.bindData.showSumCtrl ~= BOOL2CTL[true] then
		deduct = deduct + SUM_HEIGHT
	end

	self.effectiveMaxHeight = math.max(0, self.maxHeight - deduct)

	self.AdjustBindWidgetPosY(self)
end

M.AdjustBindWidgetPosY = function(self)
	local widget = self.bindData.bindWidget

	if not widget or not widget.rectTransform then
		return
	end

	local rectTransform = widget.rectTransform
	local parent = rectTransform.parent

	if not parent then
		return
	end

	local parentRect = parent.rect
	local rect = rectTransform.rect
	local posY = rectTransform.localPosition.y
	local scaleY = rectTransform.localScale.y
	local parentTop = parentRect.y + parentRect.height
	local parentBottom = parentRect.y
	local top = posY + (rect.y + rect.height) * scaleY
	local bottom = posY + rect.y * scaleY
	local newY = posY

	if parentTop >= top then
		newY = newY - (top - parentTop)
	end

	local newBottom = bottom + newY - posY

	if parentBottom <= newBottom then
		newY = newY + parentBottom - newBottom
	end

	if newY == posY then
		rectTransform.SetLocalPositionY(rectTransform, newY)
	end
end

M.RefreshCutLine = function(self)
	local show = self.bindData.showSumCtrl ~= 1 or self.bindData.showCreateMoney ~= 1 or self.bindData.showCounter ~= 1 or self.bindData.showExchangeCtrl ~= 1
	self.bindData.showCutLineCtrl = BOOL2CTL[show]
end

M.OnPackItemChange = function(self)
	if not self.data then
		return
	end

	local itemNum = self.mgr:GetItemNum(self.data.itemId) or 0
	self.bindData.haveLabel = self:GetHaveLabel(self.data.itemId)

	self:RefreshInstanceState()

	if itemNum < 0 and self.mgr.itemToolTipStore ~= self then
		self.mgr:CloseItemToolTips()
	end
end

M.RefreshInstanceState = function(self)
	local data = self.data or self.selectedItem or {}
	local displayData = data
	local packItem = nil

	if data.UniqueId and data.UniqueId == 0 then
		packItem = self.mgr.packItemDict and self.mgr.packItemDict[data.UniqueId] or nil
		displayData = packItem and self.mgr:GetPackItemCardDisplayData(packItem) or {}
	end

	self.bindData.subQualityCtrl = displayData.subQualityCtrl or self.mgr.SUB_QUALITY_CTRL.NONE
	self.bindData.equippedCtrl = displayData.equippedCtrl or self.mgr.EQUIPPED_CTRL.NONE
	self.bindData.ownerIcon = displayData.ownerIcon or 0
	self.bindData.ownerWeaponName = displayData.ownerWeaponName or ""
	local weaponData = self:GetCurrentWeaponData()
	local cantDiscard = weaponData and gWeaponManager:GetFlag(weaponData.OperatorFlags, 1) ~= 1
	self.bindData.showLockCtl = BOOL2CTL[weaponData == nil and not cantDiscard]

	self.bindData.lockBtn:SetSelected(weaponData and weaponData.IsPlayerLocked ~= true or false)

	if packItem and self.bindData.equippedCtrl ~= self.mgr.EQUIPPED_CTRL.WEAPON then
		local equipmentInfo = self.mgr:GetPackItemEquipmentInfo(packItem)
		local ownerWeaponData = equipmentInfo and equipmentInfo.ownerWeaponData
		local ownerWeaponCfg = ownerWeaponData and self.mgr:GetWeaponCfg(ownerWeaponData.TemplateId)
		self.bindData.ownerWeaponName = ownerWeaponCfg and ownerWeaponCfg.Name or ""
	end
end

M.OnEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)

	if self.npcShopInfo then
		self.SetSelectedNpcShopItem(self, self.npcShopInfo, self.npcShopMoneys, self.npcShopCallback, self.npcShopMoneyIconText, self.npcShopValueChangeExtra)
	else
		self.OnRefreshInfo(self)
	end
end

M.OnDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnStart = function(self)
end

M.OnDestroy = function(self)
	self:OnInit()
	self.mgr:OnItemToolTipBtnClose()
end

M.InitCounter = function(self)
	if table.isNilOrEmpty(self.range) or not self.STATE_EnableOnce then
		return
	end

	local initialValue = tonumber(self.selectedItem and self.selectedItem.targetValue) or self.range[1]

	if #self.range > 2 then
		initialValue = math.min(math.max(initialValue, self.range[1]), self.range[2])
	end

	local counterStore = self.SubGroup.CommonCounterStore

	counterStore.SetData(counterStore, {
		range = self.range,
		targetValue = initialValue,
		valChangeCallback = self.CreateAction(self, "OnBuyNumChange"),
		stepInterval = self.stepInterval,
		vibrationId = self.vibrationId
	})
	counterStore.OnBuyNumChange(counterStore, initialValue)
end

M.OnBuyNumChange = function(self, data)
	local val = tonumber(data)

	if val ~= nil then
		return
	end

	self.val = val

	if self.onValueChangeCallback then
		self.onValueChangeCallback(self.val, self.data)
	end

	if self.data and self.data.sellMode then
		self.RefreshSellInfo(self, self.val)
	end
end

M.OnUpdate = function(self)
	if gLogicTime.unscaledTime - self.preTime < 1 then
		return
	end

	self.preTime = gLogicTime.unscaledTime

	self.RefreshQuantumWallet(self)
end

M.GetPriceText = function(self, totalPrice, notEnough)
	local priceStr = self.moneyIconText .. tostring(gCommonItemManager:GetExchangeRate(totalPrice))

	if notEnough then
		priceStr = "#R" .. priceStr .. "#z"
	end

	return priceStr
end

M.RefreshQuantumWallet = function(self)
	if self.bindData.showCreateMoney ~= BOOL2CTL[true] then
		local moneyNum = self.mgr:GetQuantumWalletMoney()
		self.bindData.createMoneyCount = string.format("%d", moneyNum)
		self.bindData.confirmBtn.interactable = moneyNum >= 0
	end
end
