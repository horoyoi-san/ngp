-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BackCircleAnantarkovStore.lua
-- Decompiled from: 01926_BackCircleAnantarkovStore.lua_1cb1b41c85f8.luajit

C_BackCircleAnantarkovStore = DefClass("C_BackCircleAnantarkovStore", C_BackCircleAnantarkovStore, C_BackCircleBase)
GroupName2Class.BackCircleAnantarkovStore = C_BackCircleAnantarkovStore
local M = C_BackCircleAnantarkovStore

M.DefineAllVariables = function(self)
	self.SELECT_MODE = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.WARN_TEXT = {
		["h\\x83\\x92\\x9b\\x8f"] = 0,
		["\\xf7\\xf4+9,\\xc1"] = 1
	}
	self.MAX_SLOT_COUNT = 8
end

M.DefineAllEnumsAutoGen = function(self)
	self.weaponStartSelectEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ShowWeaponDetailCtrlEnum = {
		["+M\\x90\\x9e\\x8cO"] = 1,
		["\\xfd\\xde(\\xe5"] = 0,
		["c\\xa1\\x97\\xbc\\xb3"] = 3,
		["pU\\xc0\\xae\\x91\\xb9\\xc5\\xed"] = 2
	}
	self.WarningTextCtrlEnum = {
		["2G\\xb5\\x9c\\x8cQ"] = 1,
		[">Z\\x9e\\x85\\x86O"] = 3,
		[".\\xecH\\xc2\\xb4H\\xad_\\xa4\\xaf"] = 2,
		["h\\xa3\\xb2\\xbb\\xaf"] = 0
	}
	self.QualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.WheelTypeCtrlEnum = {
		["\\x98\\xa5\\xa5n?\\xec7"] = 0,
		["\\xf4\\xd2+\\xff"] = 1
	}
	self.ShowTooltipCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.weaponHasElemtensCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.weaponStartSelectEnum = nil
	self.ShowWeaponDetailCtrlEnum = nil
	self.WarningTextCtrlEnum = nil
	self.QualityCtrlEnum = nil
	self.WheelTypeCtrlEnum = nil
	self.ShowTooltipCtrlEnum = nil
	self.weaponHasElemtensCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_ADD] = self.CreateAction(self, "RefreshCircleView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE] = self.CreateAction(self, "RefreshCircleView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE] = self.CreateAction(self, "RefreshCircleView"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_CLEAR] = self.CreateAction(self, "RefreshCircleView")
	}
end

M.RegisterWidget = function(self)
end

M.OnShow = function(self, args)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitModel(self, args)
	self.InitView(self, args)
	self.RefreshCircleView(self)
end

M.InitModel = function(self, args)
	self.cellSize = args.cellSize
	self.gamePlayTypeId = args.gamePlayTypeId
end

M.InitView = function(self)
	self.bagStoreSet = gExtractionShooterManager.GetBagStoreSet(self.gamePlayTypeId)
	local rootButtonPath = "Root/WeaponCircleItemTemplate/Root"
	self.uNavigationArea = self.rootWidget:GetComponent("UNavigationArea")

	if self.uNavigationArea then
		self.uNavigationArea.enabled = false
	end

	for slotIndex = 1, self.MAX_SLOT_COUNT do
		local button = self.bindData["weaponItem" .. slotIndex]
		local store = gStoreManager:GetStoreGroup(button.Store):GetStoreByWidget(button)
		local rootButton = button.transform:Find(rootButtonPath):GetComponent("UButton")
		button.luaEnterDropWidget = self:CreateAction("OnCircleButtonEnterDropWidget", slotIndex)
		rootButton.luaEnterDropWidget = self:CreateActionWithArgs("OnCircleButtonEnterDropWidget", slotIndex)

		self:WrapDoubleClick(store, rootButton, slotIndex, function ()
			self:OnDoubleClick(slotIndex)
		end)

		rootButton.draggable = LTConfig.SceneitemConfig.PrivateWeaponSlotSize <= slotIndex
		rootButton.luaRenderTooltip = self:CreateActionWithArgs("OnRenderToolTips", slotIndex)

		rootButton.luaRightClick = function()
			rootButton:CloseTooltip(true)
			rootButton:OpenTooltip(0)
		end

		rootButton.luaEndDrag = function(dropWidget)
			if dropWidget then
				return
			end

			local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

			if itemInfo and gExtractionShooterManager.CheckItemCanDiscard(itemInfo.Id) then
				local fromBagConfigId = self.bagStoreSet.wheel

				gExtractionShooterManager:AskExtractionShooterRemoveItem(fromBagConfigId, itemInfo.CellX, itemInfo.CellY)
			end
		end

		rootButton.luaBeginDrag = function()
			local replicaWidget = rootButton.replicaWidget

			if replicaWidget then
				local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

				gExtractionShooterManager:RefreshCommonItemInfoView(replicaWidget, itemInfo)

				local itemCfg = gExtractionShooterManager.GetExtractionItemCfgByConsumableId(itemInfo.Id)
				local itemX, itemY = gExtractionShooterUtils.GetRotatedVolume(itemCfg, false)
				local cellSizeX = self.cellSize.x
				local cellSizeY = self.cellSize.x
				replicaWidget.transform.sizeDelta = Vector2.Fetch(itemX * cellSizeX, itemY * cellSizeY)
				replicaWidget.transform.localScale = Vector2.one
				local replaceWidgetStore = gStoreManager:GetStoreGroup(replicaWidget.Store):GetStoreByWidget(replicaWidget)

				if replaceWidgetStore.image then
					local sizeX = cellSizeX * itemX - 40
					local sizeY = cellSizeY * itemY - 40
					replaceWidgetStore.image.transform.sizeDelta = Vector2.Fetch(sizeX, sizeY)
					replaceWidgetStore.image.transform.localRotation = Quaternion.Euler(0, 0, 0)
				end
			end
		end
	end
end

M.RefreshCircleView = function(self)
	for i = 1, self.MAX_SLOT_COUNT do
		self.OnRenderItemSlot(self, i)
	end
end

M.OnRenderItemSlot = function(self, slotIndex)
	local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)
	local button = self.bindData[("weaponItem%d"):format(slotIndex)]
	local store = gStoreManager:GetStoreGroup(button.Store):GetStoreByWidget(button)

	if itemInfo then
		store.IsLockedCtrl = 0

		gExtractionShooterManager:RefreshCommonItemInfoView(button, itemInfo)

		button.luaHover = nil
		store.IsEmptyCtrl = self.SELECT_MODE.FALSE
	elseif slotIndex < LTConfig.SceneitemConfig.PrivateWeaponSlotSize then
		local weaponList = gWeaponManager:GetCurrentWeapons()
		local weaponInfo = weaponList[slotIndex]
		store.IsLockedCtrl = 0
		store.IsEmptyCtrl = weaponInfo and 0 or 1

		if weaponInfo then
			gExtractionShooterManager:RefreshCommonItemInfoView(button, weaponInfo)
		end
	else
		local slotIndexHasUnlocked = gExtractionShooterManager.CheckSlotIndexHasUnlocked(slotIndex, self.bagStoreSet.wheel)
		store.IsLockedCtrl = slotIndexHasUnlocked and 0 or 1
		store.IsEmptyCtrl = self.SELECT_MODE.TRUE
		store.qualityCtrl = 0
		store.showCountCtrl = self.SELECT_MODE.FALSE
		store.count = 0
	end
end

M.OnDoubleClick = function(self, slotIndex)
	local fromBagConfigId = self.bagStoreSet.wheel
	local fromCellX, fromCellY = gExtractionShooterManager.GetCellIndexBySlotIndex(slotIndex)
	local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

	if not itemInfo then
		return
	end

	if self.CheckIsActiveGameplay(self) then
		if self.containerInstanceId then
			gExtractionShooterManager:QuickShiftBagToContainer(fromBagConfigId, itemInfo, self.containerInstanceId)
		else
			gExtractionShooterManager:QuickShiftBagToBag(fromBagConfigId, fromCellX, fromCellY, itemInfo, self.bagStoreSet.normal)
		end
	else
		gExtractionShooterManager:QuickShiftBagToBag(fromBagConfigId, fromCellX, fromCellY, itemInfo, self.bagStoreSet.inventory)
	end
end

M.CheckIsActiveGameplay = function(self)
	local isSettle = self.activeEndMode

	return gExtractionShooterManager.CheckInGame() and not isSettle
end

M.WrapDoubleClick = function(self, store, btn, slotIndex, callback)
	btn.luaClick = function()
		self:OnCircleButtonClick(slotIndex)

		if store.waitForClick then
			store.waitForClick = false
			store.waitForClickCo = coroutine.stop(store.waitForClickCo)

			if callback then
				callback()
			end
		else
			store.waitForClick = true
			store.waitForClickCo = coroutine.start(function ()
				coroutine.wait(0.2)

				store.waitForClick = false
			end)
		end
	end
end

M.OnCircleButtonClick = function(self, _)
	if self.CheckIsActiveGameplay(self) then
		-- Nothing
	end
end

M.OnCircleButtonEnterDropWidget = function(self, slotIndex, targetWidget)
	local fromCellX, fromCellY = gExtractionShooterManager.GetCellIndexBySlotIndex(slotIndex)
	local toSlotIndex = gExtractionShooterManager.GetSlotIndexByWidget(targetWidget)

	if toSlotIndex then
		local toCellX, toCellY = gExtractionShooterManager.GetCellIndexBySlotIndex(toSlotIndex)
		local fromBagConfigId = self.bagStoreSet.wheel
		local toBagConfigId = self.bagStoreSet.wheel
		local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

		if gExtractionShooterManager.CheckCellAllowed(toBagConfigId, itemInfo.Id, toSlotIndex) then
			gExtractionShooterManager:AskExtractionShooterShiftItem(fromBagConfigId, fromCellX, fromCellY, toBagConfigId, toCellX, toCellY)
		end
	end
end

M.OnRenderToolTips = function(self, slotIndex, btn, popup, popupIndex)
	local store = gStoreManager:GetStoreGroup(popup.Store):GetStoreByWidget(popup)

	if popupIndex ~= 0 then
		self.OnRenderPopupItemTypeList(self, store, btn, slotIndex)
	elseif popupIndex ~= 3 then
		local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)

		self.OnRenderPopupItemDetail(self, popup, btn, {
			itemInfo = itemInfo
		})
	end
end

M.OnRenderPopupItemTypeList = function(self, store, oriButton, slotIndex)
	local itemInfo = gExtractionShooterManager.GetItemInfoBySlot(slotIndex, self.bagStoreSet.wheel)
	local bagConfigId = self.bagStoreSet.wheel
	local buttonDataList = C_AnantarkovBagStoreBase.GetRightClickButtonDataList({
		gamePlayTypeId = self.gamePlayTypeId,
		srcBagConfigId = bagConfigId,
		itemInfo = itemInfo,
		activeEndMode = self.activeEndMode
	})
	local ButtonConfig = LTConfig.ExtractionShooterRightClickButtonConfig

	C_AnantarkovBagStoreBase.SetupRightClickButtonList(store, oriButton, buttonDataList, function ()
		return {
			srcBagConfigId = bagConfigId,
			itemInfo = itemInfo,
			activeEndMode = self.activeEndMode,
			gamePlayTypeId = self.gamePlayTypeId
		}
	end, function (data)
		if data.id ~= ButtonConfig.Detail then
			oriButton:OpenTooltip(3)
		end
	end)
end

M.OnRenderPopupItemDetail = function(self, popup, btn, args)
	local itemInfo = args.itemInfo
	local id = itemInfo.Id
	local toolTipsData = gCommonItemManager:GetItemRenderData({
		["\\xa2\\xa21\\xaax5\\xf1%"] = true,
		itemId = id,
		itemNum = itemInfo.StackCount,
		gamePlayTypeId = self.gamePlayTypeId,
		bagConfigId = args.bagConfigId,
		UniqueId = itemInfo.WeaponData and itemInfo.WeaponData.InstanceId or nil
	})

	gCommonItemManager:OnRenderToolTips(toolTipsData, btn, popup)
end
