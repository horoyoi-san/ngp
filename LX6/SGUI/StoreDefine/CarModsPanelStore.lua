-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarModsPanelStore.lua
-- Decompiled from: 01637_CarModsPanelStore.lua_01d9d10309dc.luajit

local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local TAB_PAGE = {
	["\\xef\\xfe<4=\\xd4"] = 1,
	["8m\\xa5\\xaf\\xaam"] = 2,
	["WTu"] = 0
}
C_CarModsPanelStore = DefClass("C_CarModsPanelStore", C_CarModsPanelStore, C_StoreGroup)
GroupName2Class.CarModsPanelStore = C_CarModsPanelStore
local M = C_CarModsPanelStore

M.ctor = function(self)
	self.mgr = gNewCarStoreMgr
end

M.DefineAllVariables = function(self)
	self.modifyData = {}
	self.previewIndex = {}
	self.previewParts = {}
	self.vehicleId = nil
	self.currentModsType = nil
	self.vehicleFilter = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.vehicleId = nil
	self.vehicleFilter = nil
end

M.OnShow = function(self, panelId, data)
	if not self.mgr.isShopping then
		print_error("CarModsPanel opened without shop init")
		gPanelManager:Close(self.m_Id)

		return
	end

	if self.mgr.isShopping and self.mgr.isShopInfoReady then
		self.OnCarShopInfoChange(self)
	end

	self.isCloseByUser = false
	self.bindData.mainTabRect.selectedIndex = TAB_PAGE.MAIN

	self.SubGroup.MoneyTemplateStore:SetData(UX.Game.MoneyType.Money)
end

M.OnClose = function(self)
	if self.isCloseByUser and self.mgr.isRepairModified then
		self.mgr:LeaveFromRepairShop()
	end

	self.mgr:EndShop()

	self.currentChildStore = nil
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.CAR_SHOP_INFO_CHANGE] = self.CreateAction(self, self.OnCarShopInfoChange),
		[gEventConstants.UNLOCKED_VEHICLES_SYNC] = self.CreateAction(self, self.OnUnlockedVehiclesSync)
	}
end

M.OnCarShopInfoChange = function(self)
	self.vehicleId = self.mgr.curtRepairCfgId

	self.ResetModifyData(self)
	self._EnsureRepairVehicle(self)

	if self.currentChildStore and self.currentChildStore.RefreshPage then
		self.currentChildStore:RefreshPage()
	end
end

M.OnUnlockedVehiclesSync = function(self)
	if not self.vehicleId then
		return
	end

	self.mgr:RebuildBasePartMap(self.vehicleId)

	if self.currentChildStore and self.currentChildStore.RefreshPage then
		self.currentChildStore:RefreshPage()
	end
end

M.ResetModifyData = function(self)
	if not self.vehicleId then
		return
	end

	self.modifyData = self.mgr:GetActiveVehiclePart(self.vehicleId)

	if self.mgr.useDefaultSuitIdExpand then
		local suitTabId = VehiclePartShopTabConfig.Suit
		local partList = self.modifyData[suitTabId]

		if partList then
			local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
			local defaultSuitId = vehicleCfg and vehicleCfg.DefaultSuitId or 0

			if defaultSuitId == 0 and LTConfig.VehiclePartSuitConfig.GetConfig(defaultSuitId) then
				local newList = {
					defaultSuitId
				}

				for _, id in ipairs(partList) do
					if id == defaultSuitId then
						table.insert(newList, id)
					end
				end

				self.modifyData[suitTabId] = newList
			end
		end
	end

	self.previewIndex = {}
	self.previewParts = {}
end

M.SetPreview = function(self, tabId, partIndex)
	if self.previewIndex[tabId] ~= partIndex then
		return
	end

	self.previewIndex[tabId] = partIndex
	self.previewParts = {}

	if partIndex ~= 0 and tabId ~= VehiclePartShopTabConfig.Spoiler then
		local partList = self.modifyData[tabId] or {}
		local firstCfg = partList[1] and VehiclePartConfig.GetConfig(partList[1])

		if firstCfg then
			self.previewParts[firstCfg.PartTag] = 0
		end
	end

	if partIndex <= 0 then
		local modifyEntry = self.modifyData[tabId] and self.modifyData[tabId][partIndex]

		if modifyEntry then
			if tabId ~= VehiclePartShopTabConfig.Suit then
				local suitCfg = LTConfig.VehiclePartSuitConfig.GetConfig(modifyEntry)

				if suitCfg then
					local vehicleCfg = LTConfig.VehicleConfig.GetConfig(self.vehicleId)
					local isDefaultSuit = vehicleCfg == nil and modifyEntry ~= vehicleCfg.DefaultSuitId

					local trySet = function(partId)
						if not partId or partId ~= 0 then
							return
						end

						local cfg = VehiclePartConfig.GetConfig(partId)

						if cfg then
							self.previewParts[cfg.PartTag] = partId
						end
					end

					if suitCfg.Suit then
						for i = 1, #suitCfg.Suit do
							trySet(suitCfg.Suit[i])
						end
					end

					if not isDefaultSuit then
						trySet(suitCfg.SuitPaint)
					end

					local colorTag = LTConfig.VehiclePartTagConfig.Color

					if not self.previewParts[colorTag] then
						self.previewParts[colorTag] = 0
					end
				end
			else
				local partList = {}

				self._AppendModifyParts(self, modifyEntry, partList)

				for _, partId in ipairs(partList) do
					local cfg = VehiclePartConfig.GetConfig(partId)

					if cfg then
						self.previewParts[cfg.PartTag] = partId
					end
				end
			end
		end
	end

	self._RenderPreview(self, tabId)
end

M._RenderPreview = function(self, tabId)
	local effectiveMap = self.mgr:GetEffectivePartsMap(self.previewParts)

	if not self.mgr.currentVehicle then
		self.mgr:CreateVehicle(self.vehicleId, table.to_array(effectiveMap))

		return
	end

	if tabId ~= VehiclePartShopTabConfig.Wheel then
		self.mgr.currentVehicle:ECS_ChangeWheel(effectiveMap[9] or 0, effectiveMap[10] or 0)
		gMessageManager:SendMessage(gEventConstants.CAR_SHOP_VEHICLE_READY)
	elseif tabId ~= VehiclePartShopTabConfig.Paint then
		local partCfg = VehiclePartConfig.GetConfig(effectiveMap[11] or 0)

		if partCfg then
			self.mgr.currentVehicle:SyncPaintColor(partCfg.Id)
		end
	else
		self.mgr:CreateVehicle(self.vehicleId, table.to_array(effectiveMap))
	end
end

M.CommitPreview = function(self, tabId)
	for partTag, partId in pairs(self.previewParts) do
		self.mgr.basePartMap[partTag] = partId

		if self.mgr.curtRepairDefaultPartSet then
			self.mgr.curtRepairDefaultPartSet[partId] = true
		end
	end

	self.previewIndex[tabId] = 0
	self.previewParts = {}
end

M.CommitRemove = function(self, tabId, partTag)
	local oldPartId = self.mgr.basePartMap and self.mgr.basePartMap[partTag]

	if self.mgr.basePartMap then
		self.mgr.basePartMap[partTag] = nil
	end

	if oldPartId and self.mgr.curtRepairDefaultPartSet then
		self.mgr.curtRepairDefaultPartSet[oldPartId] = nil
	end

	self.previewIndex[tabId] = 0
	self.previewParts[partTag] = nil
end

M.ClearPreview = function(self, tabId)
	if self.previewIndex[tabId] ~= nil then
		return
	end

	self.previewIndex[tabId] = 0
	self.previewParts = {}

	self._RenderPreview(self, tabId)
end

M.ClearAllPreviews = function(self)
	local activeTabId = nil

	for tabId, idx in pairs(self.previewIndex) do
		if idx == nil then
			activeTabId = tabId

			break
		end
	end

	self.previewIndex = {}

	if next(self.previewParts) ~= nil then
		return
	end

	self.previewParts = {}

	if activeTabId then
		self._RenderPreview(self, activeTabId)
	end
end

M.GetSelected = function(self, tabId)
	return self.previewIndex[tabId] or 0
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

M.GetPartPriceAndMoneyIcon = function(self, tabIndex, partIndex)
	if not partIndex or partIndex ~= 0 then
		return 0, nil, 
	end

	local partId = self.modifyData[tabIndex] and self.modifyData[tabIndex][partIndex]

	if not partId then
		return 0, nil, 
	end

	return self.mgr:GetPartPriceAndMoneyIcon(partId, tabIndex)
end

M._FilterRepairDefaultParts = function(self, partList)
	local ret = {}

	for _, partId in ipairs(partList) do
		if not self.mgr:IsPartEquipped(partId) and self.mgr.curtRepairSuitId == partId then
			table.insert(ret, partId)
		end
	end

	return ret
end

M.GotoDetail = function(self, modsType)
	self.currentModsType = modsType
	self.bindData.mainTabRect.selectedIndex = TAB_PAGE.DETAIL
end

M.GotoVehicle = function(self)
	self.currentModsType = nil
	self.bindData.mainTabRect.selectedIndex = TAB_PAGE.VEHICLE
end

M.SwitchVehicle = function(self, newVehicleId)
	if not newVehicleId or newVehicleId ~= self.vehicleId then
		return
	end

	gApplyCarManager:SwitchRepairVehicle(newVehicleId)

	self.vehicleId = newVehicleId

	self.mgr:RebuildBasePartMap(newVehicleId)
	self:ResetModifyData()
	self.mgr:CreateVehicle(newVehicleId, self.mgr:GetEffectiveParts({}))
end

M._EnsureRepairVehicle = function(self, cameraType, onVehicleReady)
	cameraType = cameraType or VehiclePartShopTabConfig.ViewTypeType.Right

	if self.mgr.pendingVehicle then
		self.mgr:SetCameraState(cameraType)

		return
	end

	if self.mgr.currentVehicle then
		self.mgr:SetCameraAsShop(self.mgr.currentVehicle)
		self.mgr:SetCameraState(cameraType)

		if onVehicleReady then
			onVehicleReady()
		end

		return
	end

	local vehicleId = self.vehicleId or self.mgr.curtRepairCfgId or 0

	if vehicleId ~= 0 then
		print_error("[CarModsPanel] _EnsureRepairVehicle: vehicleId invalid")

		return
	end

	slot4 = self.mgr
	slot8 = self.mgr

	slot4:CreateVehicle(vehicleId, slot8:GetEffectiveParts(self.previewParts), function ()
		self.mgr:SetCameraState(cameraType)

		if onVehicleReady then
			onVehicleReady()
		end
	end)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.mainTabRect.OnRenderTab = self.CreateAction(self, self.OnMainTabRectRender)
end

M.OnClickBackBtn = function(self)
	local curIndex = self.bindData.mainTabRect.selectedIndex

	if curIndex == TAB_PAGE.MAIN then
		self.bindData.mainTabRect.selectedIndex = TAB_PAGE.MAIN

		return
	end

	self.isCloseByUser = true

	self._LeavePanel(self)
end

M._LeavePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.OnMainTabRectRender = function(self, index, widget)
	if index == TAB_PAGE.DETAIL then
		self.ClearAllPreviews(self)
	end

	if index ~= TAB_PAGE.MAIN then
		self._EnsureRepairVehicle(self)
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)
	self.currentChildStore = store

	if store and store.RefreshPage then
		store.RefreshPage(store)
	end
end
