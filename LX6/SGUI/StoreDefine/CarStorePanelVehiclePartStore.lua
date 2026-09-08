-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CarStorePanelVehiclePartStore.lua
-- Decompiled from: 01640_CarStorePanelVehiclePartStore.lua_74ad9d423cfe.luajit

local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local VehicleConfig = LTConfig.VehicleConfig
local GameConfig = LTConfig.GameConfig
local EShowTabLv2Ctrl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
local EListTypeCtrl = {
	["~\\xa7\\xb8\\xaa\\xe4"] = 1,
	["R+y^"] = 3,
	["~\\xa7\\xb8\\xaa\\xe7"] = 0,
	["n\\xa1\\xae\\xa0\\xa4"] = 2
}
local EShowPriceCtrl = {
	["R+y^"] = 0,
	["I*rL"] = 1
}
local EHasSecondTabCtrl = {
	["k\\xaf\\xae\\xbc\\xb3"] = 1,
	["N0h^"] = 0
}
local EMobileTabTreeTemplateType = {
	["(I\\x93\\xa2\\x95"] = 0,
	["(I\\x93\\xa2\\x95"] = 1
}
local EMobileTabTreeTemplateSelectCtrl = {
	["k\\xaf\\xae\\xbc\\xb3"] = 1,
	["N0h^"] = 0
}
local ELockCtrl = {
	["k\\xaf\\xae\\xbc\\xb3"] = 1,
	["N0h^"] = 0
}
local PaintSubTab = {
	["\\xea\\xcb%\\xfd"] = 3,
	["\\x86\\xb0\\xaex7\\xff?"] = 2,
	["n\\xa1\\xae\\xa0\\xa4"] = 1
}
local EFoldCtrl = {
	["\\-q_"] = 1,
	[")F\\x97\\x81\\x8fE"] = 0
}
local FirstPaintSubTab = PaintSubTab.Color
local LastPaintSubTab = PaintSubTab.Special
C_CarStorePanelVehiclePartStore = DefClass("C_CarStorePanelVehiclePartStore", C_CarStorePanelVehiclePartStore, C_StoreGroup)
GroupName2Class.CarStorePanelVehiclePartStore = C_CarStorePanelVehiclePartStore
local M = C_CarStorePanelVehiclePartStore
local logicTime = gLogicTime
local STEP_LOCK_TIMER = 0.2

M.ctor = function(self)
	self.mgr = gNewCarStoreMgr
	self.paintGroupByColor = nil
	self.colorIndex = nil
	self.matIndex = nil
	self.partId2IndexDic = nil
	self.lv2Step = 0
	self.lv2PreTime = 0
end

M.DefineAllVariables = function(self)
end

M.OnAwake = function(self)
	self.parent = gStoreManager:GetStoreGroup("CarStorePanelStore")
	self.bindData.size1itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderVehiclePartItem)
	self.bindData.size1itemList.luaSelectedChanged = self:CreateAction(self.OnSelectVehiclePartItem)
	self.bindData.size2itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderVehiclePartItem)
	self.bindData.size2itemList.luaSelectedChanged = self:CreateAction(self.OnSelectVehiclePartItem)
	self.bindData.colorList.luaSimpleRenderItem = self:CreateAction(self.OnRenderColorItem)
	self.bindData.colorList.luaSelectedChanged = self:CreateAction(self.OnSelectColorItem)
	self.bindData.mobileTabTree.luaRenderItem = self:CreateAction(self.OnRenderTabTreeItem)
	self.bindData.mobileTabTree.luaClick = self:CreateAction(self.OnClickTabTreeItem)
	self.bindData.checkList.luaSimpleRenderItem = self:CreateAction(self.OnRenderCheckListItem)
	self.bindData.checkList.luaSelectedChanged = self:CreateAction(self.OnSelectCheckListItem)
	self.bindData.foldBtn.luaClick = self:CreateAction(self.OnClickFoldBtn)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.pcTabLv2LeftBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTabLv2SwitchBtn, -1)
		self.bindData.pcTabLv2LeftBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTabLv2SwitchBtn)
		self.bindData.pcTabLv2RightBtn.luaBeginLongPress = self.CreateActionWithArgs(self, self.OnBeginLongPressTabLv2SwitchBtn, 1)
		self.bindData.pcTabLv2RightBtn.luaEndLongPress = self.CreateAction(self, self.OnEndLongPressTabLv2SwitchBtn)
	end

	self.bindData.buyBtn.luaClick = self.CreateAction(self, self.OnBuyBtnClick)
	self.colorIndex = nil
	self.matIndex = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.RegisterUpdate(self)
	end
end

M.OnRenderVehiclePartItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local partTabSecIndex = nil

	if self.selectedTab ~= self.colorTabIndex then
		if self.selectedSecTab ~= PaintSubTab.Material then
			local entry = self.paintGroupByColor and self.colorIndex and self.paintGroupByColor[self.colorIndex]
			local partGroup = entry and entry.group

			if partGroup then
				partTabSecIndex = partGroup[index + 1]
			else
				print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorIndex)

				return
			end
		elseif self.selectedSecTab ~= PaintSubTab.Special then
			partTabSecIndex = self.specialPaintPartIndexList[index + 1]
		end
	end

	if self.selectedTab ~= self.suitTabIndex then
		if index ~= 0 then
			store.priceCtrl = EShowPriceCtrl.Hide
			store.lockCtrl = ELockCtrl.False
			local cmInfo = self.parent:GetDefaultSuitBumperCmInfo()

			if cmInfo then
				store.iconId = cmInfo.Cfg.SItemIconId
				store.name = cmInfo.Name
			end

			return
		end

		partTabSecIndex = index
	elseif not partTabSecIndex then
		partTabSecIndex = index + 1
	end

	local price, _, cmInfo = self.parent:GetPartDiffPriceAndMoneyIcon(self.selectedTab, partTabSecIndex)
	local moneyRichText = gCommonItemManager:GetCurrMoneyRichText()

	if self.selectedTab ~= self.suitTabIndex then
		store.price = moneyRichText .. gCommonItemManager:GetExchangeRate(self.parent:GetSuitStartPrice(self.parent.vehicleId, index))
	else
		store.price = moneyRichText .. gCommonItemManager:GetExchangeRate(price)
	end

	if table.isNilOrEmpty(cmInfo) then
		return
	end

	store.iconId = cmInfo.Cfg.SItemIconId
	store.name = cmInfo.Name
	btn.interactable = not cmInfo.SoldOut
	local isStandard = index ~= 0 and self.selectedTab == self.suitTabIndex
	store.priceCtrl = isStandard and EShowPriceCtrl.Hide or EShowPriceCtrl.Show
	store.lockCtrl = cmInfo.Unlocked and ELockCtrl.False or ELockCtrl.True
end

M.OnSelectVehiclePartItem = function(self, uList)
	local isChange = false

	if self.selectedTab ~= self.colorTabIndex then
		if self.selectedSecTab ~= PaintSubTab.Material then
			local entry = self.paintGroupByColor and self.colorIndex and self.paintGroupByColor[self.colorIndex]
			local partGroup = entry and entry.group

			if partGroup then
				local partIndex = partGroup[uList.selectedIndex + 1]
				self.matIndex = uList.selectedIndex + 1
				isChange = self.parent:ChangeActiveList(self.selectedTab, partIndex)
			else
				print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorIndex)

				return
			end
		elseif self.selectedSecTab ~= PaintSubTab.Special then
			local partIndex = self.specialPaintPartIndexList[uList.selectedIndex + 1]
			isChange = self.parent:ChangeActiveList(self.selectedTab, partIndex)
		end
	else
		local partIndex = nil

		if self.selectedTab ~= self.suitTabIndex then
			partIndex = uList.selectedIndex
		else
			partIndex = uList.selectedIndex + 1
		end

		isChange = self.parent:ChangeActiveList(self.selectedTab, partIndex)
	end

	if isChange then
		self.RefreshCheckList(self)
	end
end

M.OnRenderColorItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	if self.selectedSecTab ~= PaintSubTab.Color then
		local entry = self.paintGroupByColor and self.paintGroupByColor[index + 1]

		if not entry then
			return
		end

		store.colorCode = entry.colorCode
	else
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)

		return
	end

	store.isLock = self.mgr.BOOL2CTL[false]
end

M.OnSelectColorItem = function(self, uList)
	if self.selectedSecTab == PaintSubTab.Color then
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)

		return
	end

	local newColorIndex = uList.selectedIndex + 1

	if newColorIndex ~= self.colorIndex then
		return
	end

	self.colorIndex = newColorIndex
	local entry = self.paintGroupByColor[self.colorIndex]
	local partGroup = entry and entry.group

	if not partGroup or #partGroup < 0 then
		print_error("汽修店改装材质列表错误，色码 group 为空", self.colorIndex)

		return
	end

	if not self.matIndex or self.matIndex <= #partGroup then
		if self.matIndex then
			print_error("汽修店改装色板材质数量不足，无法保留旧 matIndex", self.colorIndex, self.matIndex, #partGroup)
		end

		self.matIndex = 1
	end

	local colorPartIndex = partGroup[self.matIndex]
	local isChange = self.parent:ChangeActiveList(self.selectedTab, colorPartIndex)

	if isChange then
		self.RefreshCheckList(self)
	end
end

M.OnRenderCheckListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.checkList[index + 1]

	if not data then
		return
	end

	store.optionNameText = data.name or ""
	store.priceText = gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(data.price)
	store.showPriceCtrl = data.isStandard and EShowPriceCtrl.Hide or EShowPriceCtrl.Show
end

M.OnSelectCheckListItem = function(self, uList)
	local data = self.checkList[uList.selectedIndex + 1]
	local tabIndex = data.tabIndex

	if self.selectedTab ~= tabIndex then
		return
	end

	self.selectedTab = tabIndex

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(uList.selectedIndex, nil, false)
		self.SubGroup.CommonTabSingleStore:RefreshItems()
	else
		self.RefreshTabTreeSelect(self)
	end

	self.RefreshItemList(self)
end

M.OnClickFoldBtn = function(self)
	self.bindData.foldCtrl = self.bindData.foldCtrl ~= EFoldCtrl.Unfold and EFoldCtrl.Fold or EFoldCtrl.Unfold
end

M.OnBeginLongPressTabLv2SwitchBtn = function(self, offset)
	self.lv2Step = offset
	self.lv2PreTime = 0

	self.RefreshLv2Step(self)
end

M.OnEndLongPressTabLv2SwitchBtn = function(self)
	self.lv2Step = 0
end

M.RefreshLv2Step = function(self)
	if self.lv2Step ~= 0 then
		return
	end

	if logicTime.unscaledTime - self.lv2PreTime < STEP_LOCK_TIMER then
		return
	end

	if not self.selectedSecTab then
		return
	end

	local newSecTab = self.selectedSecTab + self.lv2Step

	if newSecTab >= FirstPaintSubTab then
		newSecTab = LastPaintSubTab
	end

	if LastPaintSubTab >= newSecTab then
		newSecTab = FirstPaintSubTab
	end

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(newSecTab - 1, true, true)

	self.lv2PreTime = logicTime.unscaledTime
end

M.RegisterUpdate = function(self)
	if not self.lv2UpdateHandler then
		self.lv2UpdateHandler = UpdateBeat:CreateListener(self.OnLv2Update, self)

		UpdateBeat:AddListener(self.lv2UpdateHandler)
	end
end

M.UnRegisterUpdate = function(self)
	if self.lv2UpdateHandler then
		UpdateBeat:RemoveListener(self.lv2UpdateHandler)

		self.lv2UpdateHandler = nil
	end
end

M.OnLv2Update = function(self)
	if GameConfig.TabLongPressTimeInterval >= logicTime.unscaledTime - self.lv2PreTime then
		self.RefreshLv2Step(self)
	end
end

M.RefreshTabTreeSelect = function(self)
	for i, data in ipairs(self.tabList) do
		self._SetTabTreeDataSelect(self, data)
	end

	self.bindData.mobileTabTree:RefreshList()
end

M._SetTabTreeDataSelect = function(self, data)
	if self.selectedTab ~= self.colorTabIndex then
		if data.depth ~= 1 and self.selectedSecTab ~= data.index + 1 then
			data.selected = true
			data.isSelect = true
		elseif data.depth ~= 0 and self.selectedTab ~= data.index + 1 then
			data.selected = false
			data.expanded = true
			data.isSelect = true
		else
			data.selected = false
			data.isSelect = false
		end
	elseif data.depth ~= 0 and self.selectedTab ~= data.index + 1 then
		data.selected = true
		data.isSelect = true
	else
		data.selected = false
		data.isSelect = false
	end
end

M.OnChangeTab = function(self, uList, isSub)
	if not isSub then
		local tabData = self.tabList[uList.selectedIndex + 1]
		self.selectedTab = tabData.index + 1

		self.RefreshItemList(self)
		self.RefreshCheckList(self)
	else
		self.selectedSecTab = uList.selectedIndex + 1

		self.RefreshColorMatItemList(self)
	end
end

M.OnRenderTabItem = function(self, btn, index, data, store, isSub, uList)
	if isSub then
		store.title = self.subTabList[index + 1].title
	else
		store.title = data.title
	end
end

M.OnRenderTabTreeItem = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		store.isSelectCtrl = data.isSelect and EMobileTabTreeTemplateSelectCtrl.True or EMobileTabTreeTemplateSelectCtrl.False

		if data.depth ~= 0 then
			local hasSecondTab = data.index + 1 ~= self.colorTabIndex
			store.hasSecondTabCtrl = hasSecondTab and EHasSecondTabCtrl.True or EHasSecondTabCtrl.False
		end
	end
end

M.OnClickTabTreeItem = function(self, btn, data)
	if data.depth ~= 0 then
		self.selectedTab = data.index + 1

		self.RefreshItemList(self)
		self.RefreshCheckList(self)
	else
		self.selectedSecTab = data.index + 1

		self.RefreshColorMatItemList(self)
	end

	self.RefreshTabTreeSelect(self)
end

M.RefreshPage = function(self)
	self.selectedTab = 1
	self.selectedSecTab = 1
	self.suitTabIndex = nil
	self.colorTabIndex = nil
	self.tabList = nil
	self.subTabList = nil
	self.colorIndex = nil
	self.matIndex = nil
	self.bindData.colorList.cancelSupport = false
	self.bindData.size1itemList.cancelSupport = false
	self.bindData.size2itemList.cancelSupport = false
	self.bindData.foldCtrl = EFoldCtrl.Unfold
	local colorSubTabLabel = VehiclePartConfig.ShopColorTab[1]
	local matSubTabLabel = VehiclePartConfig.ShopColorTab[2]
	local specialPaintSubTabLabel = VehiclePartConfig.ShopColorTab[3]
	local vehicleCfg = VehicleConfig.GetConfig(self.parent.vehicleId)
	local carName = vehicleCfg and vehicleCfg.VehicleName or ""
	self.bindData.carNameText = carName
	local firstValidCameraType = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local tabList = {}

		for i = 0, VehiclePartShopTabConfig.count - 1 do
			if self.parent.modifyData[i + 1] then
				if #self.parent.modifyData[i + 1] == 0 then
					local cfg = VehiclePartShopTabConfig.LoadAt(i)
					firstValidCameraType = firstValidCameraType or cfg.ViewType

					table.insert(tabList, {
						title = cfg.Title,
						index = i
					})

					if cfg.Id ~= VehiclePartShopTabConfig.Suit then
						self.suitTabIndex = cfg.Id
					end

					if cfg.IsColor then
						self.colorTabIndex = i + 1
					end
				end
			end
		end

		self.tabList = tabList
		self.subTabList = {}

		table.insert(self.subTabList, {
			title = colorSubTabLabel
		})
		table.insert(self.subTabList, {
			title = matSubTabLabel
		})
		table.insert(self.subTabList, {
			title = specialPaintSubTabLabel
		})
		self.SubGroup.CommonTabSingleStore:SetData(tabList, self.subTabList, 0, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
	else
		local tabList = {}

		for i = 0, VehiclePartShopTabConfig.count - 1 do
			if self.parent.modifyData[i + 1] then
				if #self.parent.modifyData[i + 1] == 0 then
					local cfg = VehiclePartShopTabConfig.LoadAt(i)
					local isSelect = i + 1 ~= self.selectedTab

					table.insert(tabList, {
						["I\\xab\\xb2\\xbb\\xbe"] = 0,
						selected = isSelect,
						isSelect = isSelect,
						tIndex = EMobileTabTreeTemplateType.TabLv1,
						title = cfg.Title,
						index = i
					})

					if cfg.Id ~= VehiclePartShopTabConfig.Suit then
						self.suitTabIndex = cfg.Id
					end

					if cfg.IsColor then
						table.insert(tabList, {
							["D\\xa0\\xa6\\xaa\\xae"] = 0,
							["I\\xab\\xb2\\xbb\\xbe"] = 1,
							tIndex = EMobileTabTreeTemplateType.TabLv2,
							title = colorSubTabLabel
						})
						table.insert(tabList, {
							["D\\xa0\\xa6\\xaa\\xae"] = 1,
							["I\\xab\\xb2\\xbb\\xbe"] = 1,
							tIndex = EMobileTabTreeTemplateType.TabLv2,
							title = matSubTabLabel
						})
						table.insert(tabList, {
							["D\\xa0\\xa6\\xaa\\xae"] = 2,
							["I\\xab\\xb2\\xbb\\xbe"] = 1,
							tIndex = EMobileTabTreeTemplateType.TabLv2,
							title = specialPaintSubTabLabel
						})

						self.colorTabIndex = i + 1
					end
				end
			end
		end

		self.tabList = tabList

		self.bindData.mobileTabTree:SetList(tabList)
		self:RefreshItemList()
	end

	self:RefreshCheckList()

	local targetCameraType = firstValidCameraType or VehiclePartShopTabConfig.ViewTypeType.Right

	if not self.colorIndex then
		self.InitDefaultPaintSelect(self)
	end

	local createVehicleCallback = function()
		self.mgr:SetCameraState(targetCameraType)
	end

	self.parent.mgr:CreateVehicle(self.parent.vehicleId, self.parent.activeList, createVehicleCallback)
end

M.RefreshItemList = function(self)
	local cfg = VehiclePartShopTabConfig.GetConfig(self.selectedTab)

	if not cfg then
		return
	end

	local isColor = self.selectedTab ~= self.colorTabIndex
	self.bindData.isColor = self.mgr.BOOL2CTL[isColor]
	self.bindData.showTabLv2Ctrl = isColor and EShowTabLv2Ctrl.Show or EShowTabLv2Ctrl.Hide

	if isColor then
		self.selectedSecTab = PaintSubTab.Color

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.selectedSecTab - 1, nil, true)
		end

		self.RefreshColorMatItemList(self)
	else
		self.RefreshKitOrPartItemList(self)
	end

	self.mgr:SetCameraState(cfg.ViewType)
end

M.RefreshColorMatItemList = function(self)
	self.selectedSecTab = self.selectedSecTab or PaintSubTab.Color

	if self.selectedSecTab ~= PaintSubTab.Color then
		self.RefreshColorItemList(self)
	elseif self.selectedSecTab ~= PaintSubTab.Material then
		self.RefreshMatItemList(self)
	elseif self.selectedSecTab ~= PaintSubTab.Special then
		self.RefreshSpecialPaintItemList(self)
	end
end

M.RefreshMatItemList = function(self)
	local entry = self.paintGroupByColor and self.colorIndex and self.paintGroupByColor[self.colorIndex]
	local partGroup = entry and entry.group

	if partGroup and #partGroup <= 0 then
		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Size2, COMMIT_IMMEDIATELY)
		self.bindData.size2itemList:SetSimpleList(#partGroup)

		local selectIdx = self.matIndex and self.matIndex <= 0 and self.matIndex < #partGroup and self.matIndex - 1 or 0

		self.bindData.size2itemList:SelectItem(selectIdx)
		self.bindData.size2itemList:SetNavSelectToSelect(false)
	else
		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Hide, COMMIT_IMMEDIATELY)
		print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorIndex)

		return
	end
end

M.RefreshSpecialPaintItemList = function(self)
	if self.specialPaintPartIndexList and #self.specialPaintPartIndexList <= 0 then
		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Size2, COMMIT_IMMEDIATELY)
		self.bindData.size2itemList:SetSimpleList(#self.specialPaintPartIndexList)

		if not self.parent.modifyIndex[self.selectedTab] then
			self.bindData.size2itemList:SelectItem(0)
		else
			for i, v in ipairs(self.specialPaintPartIndexList) do
				if v ~= self.parent.modifyIndex[self.selectedTab] then
					self.bindData.size2itemList:SelectItem(i - 1)

					break
				end
			end
		end

		self.bindData.size2itemList:SetNavSelectToSelect(false)
	else
		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Hide, COMMIT_IMMEDIATELY)
	end
end

M.RefreshKitOrPartItemList = function(self)
	local partCount = #self.parent.modifyData[self.selectedTab]

	if self.selectedTab ~= self.suitTabIndex then
		local suitCount = partCount + 1

		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Size1, COMMIT_IMMEDIATELY)
		self.bindData.size1itemList:SetSimpleList(suitCount)

		local selectedIndex = self.parent:GetSelected(self.selectedTab)

		self.bindData.size1itemList:SelectItem(selectedIndex)
		self.bindData.size1itemList:SetNavSelectToSelect(false)

		return
	end

	if partCount <= 0 then
		local selectedIndex = self.parent:GetSelected(self.selectedTab)

		if self.selectedTab ~= self.suitTabIndex then
			self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Size1, COMMIT_IMMEDIATELY)
			self.bindData.size1itemList:SetSimpleList(partCount)

			if selectedIndex == 0 then
				self.bindData.size1itemList:SelectItem(selectedIndex - 1)
			end
		else
			self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Size2, COMMIT_IMMEDIATELY)
			self.bindData.size2itemList:SetSimpleList(partCount)

			if selectedIndex == 0 then
				self.bindData.size2itemList:SelectItem(selectedIndex - 1)
			end
		end

		self.bindData.size2itemList:SetNavSelectToSelect(false)
	else
		self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Hide, COMMIT_IMMEDIATELY)
	end
end

M.RefreshColorItemList = function(self)
	self.bindData:Commit("listTypeCtrl", EListTypeCtrl.Color, COMMIT_IMMEDIATELY)

	self.paintGroupByColor = self.mgr:GetActivePaintFor4S(self.parent.modifyData[self.selectedTab])
	self.specialPaintPartIndexList = nil
	self.partIndex2specialPart = nil

	self:RefreshPartId2IndexDic()

	if self.selectedSecTab ~= PaintSubTab.Color then
		self.bindData.colorList:SetSimpleList(#self.paintGroupByColor)

		if self.colorIndex then
			self.bindData.colorList:SelectItem(self.colorIndex - 1, true)
		elseif #self.paintGroupByColor <= 0 then
			self.bindData.colorList:SelectItem(0)
		end

		self.bindData.colorList:SetNavSelectToSelect(false)
	else
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)
	end
end

M.InitDefaultPaintSelect = function(self)
	if not self.paintGroupByColor or #self.paintGroupByColor ~= 0 then
		return
	end

	local vehicleCfg = VehicleConfig.GetConfig(self.parent.vehicleId)
	local defaultPaintId = vehicleCfg and vehicleCfg.DefaultPaint or nil
	local defaultModifyIndex = defaultPaintId and self.partId2IndexDic[defaultPaintId] or nil
	local colorIndex, matIndex = nil

	if defaultModifyIndex then
		for ci, entry in ipairs(self.paintGroupByColor) do
			for mi, mIdx in ipairs(entry.group) do
				if mIdx ~= defaultModifyIndex then
					colorIndex = ci
					matIndex = mi

					break
				end
			end

			if colorIndex then
				break
			end
		end
	end

	if not colorIndex then
		print_error("汽修店改装车漆色板未找到车辆原厂配置车漆", self.mgr.shopId, defaultPaintId)

		colorIndex = 1
		matIndex = 1
		defaultModifyIndex = self.paintGroupByColor[1].group[1]
	end

	self.colorIndex = colorIndex
	self.matIndex = matIndex
	self.parent.modifyIndex[VehiclePartShopTabConfig.Paint] = defaultModifyIndex
	self.parent.activeList = self.mgr:GetDefaultModifyInfo(self.parent.vehicleId, self.parent.modifyData, self.parent.modifyIndex)
end

M.RefreshPartId2IndexDic = function(self)
	self.partId2IndexDic = {}
	local partList = self.parent.modifyData[self.selectedTab]

	for index, partId in ipairs(partList) do
		self.partId2IndexDic[partId] = index
	end
end

M.RefreshCheckList = function(self)
	local checkList = {}
	local checkIndexByTab = {}
	local selectedIndex = -1

	for tabIndex = 1, VehiclePartShopTabConfig.count do
		local partList = self.parent.modifyData[tabIndex]

		if partList and #partList <= 0 then
			local index = self.parent.modifyIndex[tabIndex] or 1
			local price, cmInfo = nil
			price, _, cmInfo = self.parent:GetPartDiffPriceAndMoneyIcon(tabIndex, index)
			local checkItem = nil

			if index ~= 0 then
				checkItem = {
					["]\\xbc\\xab\\xac\\xb3"] = 0,
					["ZI\\xfd\\xa9\\x85\\xbc\\xdb\\xec"] = true,
					tabIndex = tabIndex
				}
			else
				checkItem = {
					["ZI\\xfd\\xa9\\x85\\xbc\\xdb\\xec"] = false,
					tabIndex = tabIndex,
					price = price,
					name = cmInfo and cmInfo.Name or ""
				}
			end

			table.insert(checkList, checkItem)

			checkIndexByTab[tabIndex] = #checkList

			if tabIndex ~= self.selectedTab then
				selectedIndex = #checkList
			end
		end
	end

	if self.suitTabIndex then
		local suitListIndex = checkIndexByTab[self.suitTabIndex]

		if suitListIndex then
			local suitModifyIndex = self.parent.modifyIndex[self.suitTabIndex] or 0
			checkList[suitListIndex].price = self.parent:GetSuitStartPrice(self.parent.vehicleId, suitModifyIndex)
			checkList[suitListIndex].isStandard = false

			if suitModifyIndex ~= 0 then
				local cmInfo = self.parent:GetDefaultSuitBumperCmInfo()

				if cmInfo then
					checkList[suitListIndex].name = cmInfo.Name
				end
			end
		else
			print_error("#NoCreateIssue @zhujiaying 汽修店改装套件配置有误，没有有效的套件")
		end
	else
		print_error("#NoCreateIssue @zhujiaying 汽修店改装套件配置有误，没有有效的套件")
	end

	self.checkList = checkList

	self.bindData.checkList:SetSimpleList(#checkList)

	if selectedIndex <= 0 then
		self.bindData.checkList:SelectItem(selectedIndex - 1)
	end

	local price = self.parent:GetTotalPrice()
	local money = self.mgr:GetCurrentMoney()
	local isEnough = price > money
	local buyableParts, canBuy = self.parent:GetBuyablePartsAndState()
	self.bindData.amountLabel = gCommonItemManager:GetCurrMoneyRichText() .. gCommonItemManager:GetExchangeRate(price)
	self.bindData.isEnoughMoney = self.mgr.BOOL2CTL[isEnough]
	self.bindData.buyBtn.interactable = isEnough and canBuy
end

M.OnBuyBtnClick = function(self)
	self.parent:OnBuyBtnClick()
end

M.OnClose = function(self)
	self.UnRegisterUpdate(self)
end
