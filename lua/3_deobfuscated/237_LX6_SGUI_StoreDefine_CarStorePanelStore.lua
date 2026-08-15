local MoneyType = UX.Game.MoneyType
local MessageConfig = LTConfig.MessageConfig
C_CarStorePanelStore = DefClass("C_CarStorePanelStore", C_CarStorePanelStore, C_StoreGroup)
GroupName2Class.CarStorePanelStore = C_CarStorePanelStore
local M = C_CarStorePanelStore

function M:ctor()
	self.mgr = gNewCarStoreMgr
end

function M:OnAwake()
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnExit)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightStickRespond.luaGamePadInputChanged = self:CreateAction(self.OnGamePadInputChanged)
	end

	self.msgEvents = {
		[gEventConstants.CAR_SHOP_INFO_CHANGE] = self:CreateAction(self.OnCarShopInfoChange)
	}
	self.childStore = nil
	self.modifyData = {}
	self.modifyIndex = {}
	self.activeList = {}
	self.defaultPriceList = {}
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.gamepadUpdateRotate = false
	self.rightStickValue = {
		x = 0,
		y = 0
	}

	self.mgr:CreateLight()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	local pos = data and data.pos or nil
	local shopId = data and data.shopId or 0
	local facing = data and data.facing or 0
	local endPos = data and data.endPos or nil
	local endFacing = data and data.endFacing or nil

	if shopId == 0 then
		self:OnExit()

		return
	end

	self.mgr:OnBeginShop(shopId, pos, facing, endPos, endFacing)
	self.SubGroup.MoneyTemplateStore:SetData(MoneyType.Money)

	self.vehicleId = nil
	self.vehicle = nil
end

function M:OnCarShopInfoChange()
	self:RefreshPage()
	self:RefreshDiscount()

	self.bindData.shopName = self.mgr.currentShopCfg.ShopName
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnUpdate()
	if self.gamepadMode then
		self:UpdateCameraRotateGamePad()
	end
end

function M:RefreshPage()
	if self.childStore and self.childStore.RefreshPage then
		self.childStore:RefreshPage()
	else
		self:OnStep(self.mgr.DisplayType.Vehicle)
	end
end

function M:RefreshDiscount()
	local discount = self.mgr.currentDiscount or 0
	self.bindData.discountText = string.format("声望折扣%d", 100 - discount) .. "%"
end

function M:OnClose()
	self.mgr:OnEndShop()
end

function M:OnExit()
	if self.bindData.tabRect.selectedIndex ~= self.mgr.DisplayType.Vehicle then
		self:OnStep(self.mgr.DisplayType.Vehicle)

		return
	end

	gPanelManager:Close(self.m_Id)
end

function M:OnStep(step)
	self.bindData.tabRect.selectedIndex = step
end

function M:OnRenderTab(index, widget)
	if self.childStore and self.childStore.OnClose then
		self.childStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.childStore = store

	self:RefreshPage()
end

function M:OnCurrentVehicleChange(vehicle)
	self:ResetModifyData(vehicle)
end

function M:ResetModifyData(vehicle)
	self.vehicle = vehicle
	self.vehicleId = vehicle.id
	self.modifyData = self.mgr:GetActiveVehiclePart(self.vehicleId)

	for i = 1, #self.modifyData do
		self.modifyIndex[i] = 1
	end

	self.activeList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, self.modifyIndex)
end

function M:CreateDefaultVehicle(callback)
	local defaultIndex = {}

	for i = 1, #self.modifyData do
		defaultIndex[i] = 1
	end

	local exceptTagList = {
		7,
		8,
		9,
		10,
		11
	}
	local defaultList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, defaultIndex, exceptTagList)

	self.mgr:OnCreateVehicle(self.vehicleId, defaultList, callback)
end

function M:ChangeActiveList(tabId, partIndex)
	local isWheel = tabId == 2
	local isPaint = tabId == 6

	if self.modifyIndex[tabId] ~= partIndex then
		self.modifyIndex[tabId] = partIndex
		self.activeList = self.mgr:GetDefaultModifyInfo(self.vehicleId, self.modifyData, self.modifyIndex)

		if isWheel then
			local sortedList = self:GetSortPart(self.activeList)

			self.mgr.currentVehicle:ECS_ChangeWheel(sortedList[9] or 0, sortedList[10] or 0)
		elseif isPaint then
			local sortedList = self:GetSortPart(self.activeList)
			local partCfg = LTConfig.VehiclePartConfig.GetConfig(sortedList[11] or 0)

			if partCfg then
				self.mgr.currentVehicle:SyncPaintColor(partCfg.PartID)
			end
		else
			self.mgr:OnCreateVehicle(self.vehicleId, self.activeList)
		end

		return true
	end

	return false
end

function M:GetSortPart(allPart)
	local newList = {}

	for i, part in pairs(allPart) do
		local cfg = LTConfig.VehiclePartConfig.GetConfig(part)

		if cfg then
			newList[cfg.PartTag] = part
		end
	end

	return newList
end

function M:GetTotalPrice()
	local vehiclePrice = self.mgr:GetPartPriceAndMoneyIcon(self.vehicleId)
	local partPrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(self.activeList)

	return vehiclePrice + partPrice
end

function M:GetKitStartPrice(vehicleId, presetIndex)
	local modifyData = self.mgr:GetActiveVehiclePart(vehicleId)
	local modifyIndex = {}

	for i = 1, #modifyData do
		modifyIndex[i] = 1
	end

	modifyIndex[1] = presetIndex
	local activeList = self.mgr:GetDefaultModifyInfo(vehicleId, modifyData, modifyIndex)
	local partPrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(activeList)
	local vehiclePrice = self.mgr:GetPartPriceAndMoneyIcon(vehicleId)

	return vehiclePrice + partPrice
end

function M:RefreshDefaultPriceList()
	self.defaultPriceList = {}

	for i, partList in ipairs(self.modifyData) do
		if #partList == 0 then
			self.defaultPriceList[i] = 0
		else
			local defaultPartId = partList[1]
			local singlePrice, _, _ = self.mgr:GetPartPriceAndMoneyIcon(defaultPartId, i)
			self.defaultPriceList[i] = singlePrice
		end
	end
end

function M:GetPartDiffPriceAndMoneyIcon(tabIndex, partIndex)
	self:RefreshDefaultPriceList()

	local partId = self.modifyData[tabIndex][partIndex]
	local singlePrice, moneyIcon, cmInfo = self.mgr:GetPartPriceAndMoneyIcon(partId, tabIndex)
	local diffPrice = singlePrice - (self.defaultPriceList[tabIndex] or 0)

	return diffPrice, moneyIcon, cmInfo
end

function M:GetSelected(tabId)
	return self.modifyIndex[tabId] or 1
end

function M:OnBuyBtnClick()
	local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
	local totalPrice = self:GetTotalPrice()

	gDisplayMessageMgr:ShowMessage(MessageConfig.VehicleShopConfirm, function ()
		self:RealBuy()
	end, nil, tostring(totalPrice), vehicleCfg.VehicleName)
end

function M:RealBuy()
	local ret = table.clone(self.activeList)

	table.insert(ret, self.vehicleId)

	local function buySuccessCb()
		local function teleportSuccessCb()
			gNewCarStoreMgr:LoadEndTimeLine(self.vehicle.vehicleSubType, function ()
				gPanelManager:Close(self.m_Id)
			end)
		end

		gNewCarStoreMgr:AskVehicleShopSpawnVehicle(self.vehicleId, teleportSuccessCb)
	end

	self.mgr:AskBuyPartList(ret, buySuccessCb)
end

function M:OnGamePadInputChanged(context)
	local value = context:ReadValueVector2()

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

function M:UpdateCameraRotateGamePad()
	if not self.gamepadUpdateRotate then
		return
	end

	gCameraUtils:DoRotateCameraByGamePad(4, self.rightStickValue.x, self.rightStickValue.y)
end
