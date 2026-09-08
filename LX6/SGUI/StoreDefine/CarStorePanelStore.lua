-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarStorePanelStore.lua
-- Decompiled from: 01639_CarStorePanelStore.lua_810aba2d2c2c.luajit

local MoneyType = UX.Game.MoneyType
local MessageConfig = LTConfig.MessageConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local VehiclePartTagConfig = LTConfig.VehiclePartTagConfig
local VehiclePartSuitConfig = LTConfig.VehiclePartSuitConfig
local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local DriveUtils = LX6.Drive.DriveUtils
local CarShopConfig = LTConfig.CarShopConfig
C_CarStorePanelStore = DefClass("C_CarStorePanelStore", C_CarStorePanelStore, C_StoreGroup)
GroupName2Class.CarStorePanelStore = C_CarStorePanelStore
local M = C_CarStorePanelStore

M.ctor = function(self)
	self.mgr = gNewCarStoreMgr
end

M.OnAwake = function(self)
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, self.OnRenderTab)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnExit)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightStickRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnGamePadInputChanged)
	end

	self.msgEvents = {
		[gEventConstants.CAR_SHOP_INFO_CHANGE] = self:CreateAction(self.OnCarShopInfoChange)
	}
	self.childStore = nil
	self.modifyData = {}
	self.modifyIndex = {}
	self.activeList = {}
	self.defaultPriceList = {}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.gamepadUpdateRotate = false
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
	self.vehicleId = nil
	self.vehicle = nil
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if not self.mgr.isShopping then
		print_error("CarStorePanel opened without shop init")
		gPanelManager:Close(self.m_Id)

		return
	end

	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	if self.mgr.isShopping and self.mgr.isShopInfoReady then
		self.OnCarShopInfoChange(self)
	end
end

M.OnCarShopInfoChange = function(self)
	self:RefreshPage()
	self:RefreshDiscount()

	self.bindData.shopName = self.mgr.currentShopCfg and self.mgr.currentShopCfg.ShopName or ""
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.OnUpdate = function(self)
	if self.gamepadMode then
		self.UpdateCameraRotateGamePad(self)
	end
end

M.RefreshPage = function(self)
	if self.childStore and self.childStore.RefreshPage then
		self.childStore:RefreshPage()
	elseif self.mgr.shopType ~= C_NewCarStoreMgr.SHOP_TYPE.BUY then
		self.OnStep(self, self.mgr.DisplayType.Vehicle)
	end
end

M.RefreshDiscount = function(self)
	local discount = self.mgr.currentDiscount or 0
	self.bindData.discountText = gShopManager:GetFactionDiscountStr(discount)
end

M.OnClose = function(self)
	self.mgr:EndShop()
end

M.OnExit = function(self)
	if self.mgr.shopType ~= C_NewCarStoreMgr.SHOP_TYPE.BUY and self.bindData.tabRect.selectedIndex == self.mgr.DisplayType.Vehicle then
		self.OnStep(self, self.mgr.DisplayType.Vehicle)

		return
	end

	gPanelManager:Close(self.m_Id)
end

M.OnStep = function(self, step)
	self.bindData.tabRect.selectedIndex = step
end

M.OnRenderTab = function(self, index, widget)
	if self.childStore and self.childStore.OnClose then
		self.childStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.childStore = store

	self:RefreshPage()
end

M.OnCurrentVehicleChange = function(self, vehicle)
	self.vehicle = vehicle
	self.vehicleId = vehicle.id

	self.ResetModifyData(self)
end

M.ResetModifyData = function(self)
	self.modifyData = self.mgr:GetActiveVehiclePart(self.vehicleId)

	for i = 1, #self.modifyData do
		if i ~= VehiclePartShopTabConfig.Suit and #self.modifyData[i] ~= 0 then
			self.modifyIndex[i] = 0
		else
			self.modifyIndex[i] = 1
		end
	end

	self.activeList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, self.modifyIndex)
	self.standardKitLockedReported = false
end

M.CreateDefaultVehicle = function(self, callback)
	local defaultIndex = {}

	for i = 1, #self.modifyData do
		defaultIndex[i] = 1
	end

	defaultIndex[VehiclePartShopTabConfig.Suit] = 0
	local exceptTagList = {
		VehiclePartTagConfig.TyreMesh,
		VehiclePartTagConfig.TyreMat,
		VehiclePartTagConfig.RimMesh,
		VehiclePartTagConfig.RimMat,
		VehiclePartTagConfig.Color
	}
	local defaultList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, defaultIndex, exceptTagList)

	self.mgr:CreateVehicle(self.vehicleId, defaultList, callback)
end

M.ChangeActiveList = function(self, tabId, partIndex)
	if self.modifyIndex[tabId] == partIndex then
		self.modifyIndex[tabId] = partIndex
		self.activeList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, self.modifyIndex)

		if self.mgr.currentVehicle then
			if tabId ~= VehiclePartShopTabConfig.Wheel then
				local sortedList = self:GetSortPart(self.activeList)

				self.mgr.currentVehicle:ECS_ChangeWheel(sortedList[9] or 0, sortedList[10] or 0)
			elseif tabId ~= VehiclePartShopTabConfig.Paint then
				local sortedList = self:GetSortPart(self.activeList)
				local partCfg = VehiclePartConfig.GetConfig(sortedList[11] or 0)

				if partCfg then
					self.mgr.currentVehicle:SyncPaintColor(partCfg.Id)
				end
			else
				self.mgr:CreateVehicle(self.vehicleId, self.activeList)
			end
		else
			self.mgr:CreateVehicle(self.vehicleId, self.activeList)
		end

		return true
	end

	return false
end

M.GetSortPart = function(self, allPart)
	local newList = {}

	for i, part in pairs(allPart) do
		local cfg = LTConfig.VehiclePartConfig.GetConfig(part)

		if cfg then
			newList[cfg.PartTag] = part
		end
	end

	return newList
end

M.GetTotalPrice = function(self)
	local buyableParts = self:GetBuyablePartsAndState()
	local partPrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(buyableParts)
	local vehiclePrice = self.mgr:GetPartPriceAndMoneyIcon(self.vehicleId)

	return vehiclePrice + partPrice
end

M.GetSuitStartPrice = function(self, vehicleId, presetIndex)
	local modifyData = self.mgr:GetActiveVehiclePart(vehicleId)
	local modifyIndex = {}

	for k in pairs(modifyData) do
		modifyIndex[k] = 1
	end

	local suitList = modifyData[VehiclePartShopTabConfig.Suit]

	if presetIndex <= 0 and (not suitList or #suitList ~= 0) then
		presetIndex = 0
	end

	modifyIndex[VehiclePartShopTabConfig.Suit] = presetIndex
	local buyableParts = {}

	for tabIndex, partList in pairs(modifyData) do
		local selectedIndex = modifyIndex[tabIndex] or 1

		if tabIndex ~= VehiclePartShopTabConfig.Suit and selectedIndex ~= 0 then
			local vehicleCfg = LTConfig.VehicleConfig.GetConfig(vehicleId)
			local defaultSuit = vehicleCfg and vehicleCfg.DefaultSuit

			if defaultSuit then
				for i = 1, #defaultSuit do
					local partId = defaultSuit[i]

					if partId and partId == 0 then
						table.insert(buyableParts, partId)
					end
				end
			end
		elseif partList and #partList <= 0 and selectedIndex == 0 then
			local modifyEntry = partList[selectedIndex]

			self._AppendModifyParts(self, modifyEntry, buyableParts)
		end
	end

	local partPrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(buyableParts)
	local vehiclePrice = self.mgr:GetPartPriceAndMoneyIcon(vehicleId)

	return vehiclePrice + partPrice
end

M.RefreshDefaultPriceList = function(self)
	self.defaultPriceList = {}

	for i, partList in ipairs(self.modifyData) do
		if #partList ~= 0 then
			self.defaultPriceList[i] = 0
		else
			local defaultPartId = nil

			if i ~= VehiclePartShopTabConfig.Paint then
				local paintGroupByColor = self.mgr:GetActivePaintFor4S(self.modifyData[VehiclePartShopTabConfig.Paint])
				local defaultColorGroup = paintGroupByColor and paintGroupByColor[1] and paintGroupByColor[1].group

				if not defaultColorGroup then
					print_error("没有可用车漆")

					defaultPartId = 0
				else
					local defaultIdx = defaultColorGroup and defaultColorGroup[1]

					if not defaultIdx then
						print_error("没有可用车漆")

						defaultPartId = 0
					else
						defaultPartId = partList[defaultIdx]
					end
				end
			else
				defaultPartId = partList[1]
			end

			local singlePrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(defaultPartId, i)
			self.defaultPriceList[i] = singlePrice
		end
	end
end

M.GetPartDiffPriceAndMoneyIcon = function(self, tabIndex, partIndex)
	if partIndex ~= 0 then
		return 0, nil, 
	end

	self:RefreshDefaultPriceList()

	local partId = self.modifyData[tabIndex][partIndex]
	local singlePrice, moneyIcon, cmInfo = self.mgr:GetPartPriceAndMoneyIcon(partId, tabIndex)
	local diffPrice = singlePrice - (self.defaultPriceList[tabIndex] or 0)

	return diffPrice, moneyIcon, cmInfo
end

M.GetPartPriceAndMoneyIcon = function(self, tabIndex, partIndex)
	if partIndex ~= 0 then
		return 0, nil, 
	end

	local partId = self.modifyData[tabIndex][partIndex]

	return self.mgr:GetPartPriceAndMoneyIcon(partId, tabIndex)
end

M.GetDefaultSuitBumperCmInfo = function(self)
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
	local defaultSuit = vehicleCfg and vehicleCfg.DefaultSuit

	if defaultSuit then
		for i = 1, #defaultSuit do
			local partId = defaultSuit[i]

			if partId and partId == 0 then
				local partCfg = VehiclePartConfig.GetConfig(partId)

				if partCfg and partCfg.PartTag ~= VehiclePartTagConfig.bumper then
					local _, _, cmInfo = self.mgr:GetPartPriceAndMoneyIcon(partId)

					return cmInfo
				end
			end
		end
	end
end

M.GetSelected = function(self, tabId)
	return self.modifyIndex[tabId] or 1
end

M._IsPartUnlocked = function(self, partId)
	if not partId or partId ~= 0 then
		return false
	end

	local commodityId = self.mgr.vehiclePartId2CommodityId[partId] or self.mgr.vehicleId2CommodityId[partId]
	local cmInfo = commodityId and self.mgr.commodityInfoDic[commodityId]

	return cmInfo and cmInfo.Unlocked or false
end

M._IsModifyUnlocked = function(self, modifyEntry)
	if not modifyEntry then
		return false
	end

	if type(modifyEntry) ~= "number" then
		return self._IsPartUnlocked(self, modifyEntry)
	end

	if type(modifyEntry) ~= "table" then
		for k, partId in pairs(modifyEntry) do
			if (type(k) == "string" or not string.starts_with(k, "__")) and partId == 0 and partId == self.vehicleId and not self._IsPartUnlocked(self, partId) then
				return false
			end
		end

		return true
	end

	return false
end

M._AppendModifyParts = function(self, modifyEntry, outList)
	if not modifyEntry then
		return
	end

	if type(modifyEntry) ~= "number" then
		if modifyEntry == 0 and modifyEntry == self.vehicleId then
			table.insert(outList, modifyEntry)
		end

		return
	end

	if type(modifyEntry) ~= "table" then
		for k, partId in pairs(modifyEntry) do
			if (type(k) == "string" or not string.starts_with(k, "__")) and partId == 0 and partId == self.vehicleId then
				table.insert(outList, partId)
			end
		end
	end
end

M.GetBuyablePartsAndState = function(self)
	local buyableParts = {}
	local canBuy = true
	local suitSelectedIndex = self.modifyIndex[VehiclePartShopTabConfig.Suit]
	suitSelectedIndex = suitSelectedIndex or 1

	if suitSelectedIndex ~= 0 then
		local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
		local defaultSuit = vehicleCfg and vehicleCfg.DefaultSuit

		if defaultSuit then
			for i = 1, #defaultSuit do
				local partId = defaultSuit[i]

				if partId and partId == 0 and self._IsPartUnlocked(self, partId) then
					table.insert(buyableParts, partId)
				end
			end
		end
	elseif suitSelectedIndex <= 0 then
		local suitList = self.modifyData[VehiclePartShopTabConfig.Suit]
		local suitEntry = suitList and suitList[suitSelectedIndex]

		if suitEntry and self._IsModifyUnlocked(self, suitEntry) then
			self._AppendModifyParts(self, suitEntry, buyableParts)
		end
	end

	for tabIndex, partList in ipairs(self.modifyData) do
		if tabIndex ~= VehiclePartShopTabConfig.Suit then
			-- Nothing
		elseif partList and #partList <= 0 then
			local selectedIndex = self.modifyIndex[tabIndex]
			selectedIndex = selectedIndex or 1

			if selectedIndex == 0 then
				local modifyEntry = partList[selectedIndex]
				local isUnlocked = self._IsModifyUnlocked(self, modifyEntry)

				if not isUnlocked then
					modifyEntry = nil
				end

				self._AppendModifyParts(self, modifyEntry, buyableParts)
			end
		end
	end

	return buyableParts, canBuy
end

M.OnBuyBtnClick = function(self)
	local buyableParts, canBuy = self.GetBuyablePartsAndState(self)

	if not canBuy then
		return
	end

	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
	local totalPrice = self:GetTotalPrice()
	slot7 = gCommonItemManager
	local displayPrice = tostring(slot7:GetExchangeRate(totalPrice))
	gNewCarStoreMgr.isPopup = true
	slot6 = gDisplayMessageMgr

	slot6:ShowMessage(MessageConfig.VehicleShopConfirm, function ()
		gNewCarStoreMgr.isPopup = false

		self:RealBuy()
	end, function ()
		gNewCarStoreMgr.isPopup = false
	end, displayPrice, vehicleCfg.VehicleName)
end

M.RealBuy = function(self)
	local buyableParts, canBuy = self.GetBuyablePartsAndState(self)

	if not canBuy then
		return
	end

	local ret = table.clone(buyableParts)

	local buySuccessCb = function()
		local teleportSuccessCb = function(_)
			gNewCarStoreMgr:LoadEndTimeLine(self.vehicle.vehicleSubType, function ()
				gPanelManager:Close(self.m_Id)
			end)
		end

		gNewCarStoreMgr:AskVehicleShopSpawnVehicle(self.vehicleId, true, teleportSuccessCb)
	end

	self.mgr:AskBuyCar(ret, self.vehicleId, buySuccessCb)
end

M.OnGamePadInputChanged = function(self, context)
	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.gamepadUpdateRotate = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	end

	if context.canceled then
		self.gamepadUpdateRotate = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(4, 0, 0)
	end
end

M.UpdateCameraRotateGamePad = function(self)
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end
