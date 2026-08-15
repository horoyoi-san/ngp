local VehiclePartShopTabConfig = LTConfig.VehiclePartShopTabConfig
local VehiclePartConfig = LTConfig.VehiclePartConfig
local VehicleConfig = LTConfig.VehicleConfig
local EShowTabLv2Ctrl = {
	Hide = 0,
	Show = 1
}
local EListTypeCtrl = {
	Size2 = 1,
	Hide = 3,
	Size1 = 0,
	Color = 2
}
local EShowPriceCtrl = {
	Hide = 0,
	Show = 1
}
local EHasSecondTabCtrl = {
	False = 1,
	True = 0
}
local EMobileTabTreeTemplateType = {
	TabLv1 = 0,
	TabLv2 = 1
}
local EMobileTabTreeTemplateSelectCtrl = {
	False = 1,
	True = 0
}
local ELockCtrl = {
	False = 1,
	True = 0
}
C_CarStorePanelVehiclePartStore = DefClass("C_CarStorePanelVehiclePartStore", C_CarStorePanelVehiclePartStore, C_StoreGroup)
GroupName2Class.CarStorePanelVehiclePartStore = C_CarStorePanelVehiclePartStore
local M = C_CarStorePanelVehiclePartStore

function M:ctor()
	self.mgr = gNewCarStoreMgr
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
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

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.pcTabLv2LeftBtn.luaBeginLongPress = self:CreateActionWithArgs(self.OnClickTabLv2SwitchBtn, -1)
		self.bindData.pcTabLv2RightBtn.luaBeginLongPress = self:CreateActionWithArgs(self.OnClickTabLv2SwitchBtn, 1)
	end

	self.bindData.buyBtn.luaClick = self:CreateAction(self.OnBuyBtnClick)
	self.colorCode = nil
	self.isNeedChangeNav = false
end

function M:OnRenderVehiclePartItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local partTabSecIndex = nil

	if self.selectedTab == self.colorTabIndex and self.selectedSecTab == 2 then
		local partGroup = self.colorDic[self.colorCode]

		if partGroup then
			partTabSecIndex = partGroup[index + 1]
		else
			print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorList[self.colorCode])

			return
		end
	end

	partTabSecIndex = partTabSecIndex or index + 1

	if self.isNeedChangeNav and partTabSecIndex == self.parent:GetSelected(self.selectedTab) then
		self.isNeedChangeNav = false
		self.bindData.mainNavArea.CurrentActiveContent = btn
	end

	local diffPrice, moneyIconId, cmInfo = self.parent:GetPartDiffPriceAndMoneyIcon(self.selectedTab, partTabSecIndex)
	store.moenyIconId = moneyIconId

	if self.selectedTab == self.kitTabIndex then
		store.price = self.parent:GetKitStartPrice(self.parent.vehicleId, index + 1)
	else
		store.price = diffPrice
	end

	if table.isNilOrEmpty(cmInfo) then
		return
	end

	store.iconId = cmInfo.IconId
	store.name = cmInfo.Name
	btn.interactable = not cmInfo.SoldOut
	local isStandard = index == 0 and self.selectedTab ~= self.kitTabIndex
	store.priceCtrl = isStandard and EShowPriceCtrl.Hide or EShowPriceCtrl.Show
	store.lockCtrl = cmInfo.Unlocked and ELockCtrl.False or ELockCtrl.True
end

function M:OnSelectVehiclePartItem(uList)
	local isChange = false

	if self.selectedTab == self.colorTabIndex and self.selectedSecTab == 2 then
		local partGroup = self.colorDic[self.colorCode]

		if partGroup then
			local partIndex = partGroup[uList.selectedIndex + 1]
			isChange = self.parent:ChangeActiveList(self.selectedTab, partIndex)
		else
			print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorList[self.colorCode])

			return
		end
	else
		isChange = self.parent:ChangeActiveList(self.selectedTab, uList.selectedIndex + 1)
	end

	if isChange then
		self:RefreshCheckList()
	end
end

function M:OnRenderColorItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	if self.selectedSecTab == 1 then
		local colorCode = self.colorList[index + 1]
		store.colorCode = colorCode

		if self.isNeedChangeNav and self.colorCode and colorCode == self.colorCode then
			self.isNeedChangeNav = false
			self.bindData.mainNavArea.CurrentActiveContent = btn
		end
	else
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)

		return
	end

	store.isLock = self.mgr.BOOL2CTL[false]
end

function M:OnSelectColorItem(uList)
	local colorPartIndex = nil

	if self.selectedSecTab == 1 then
		local newColorCode = self.colorList[uList.selectedIndex + 1]

		if self.colorCode == newColorCode then
			return
		end

		self.colorCode = self.colorList[uList.selectedIndex + 1]
		local partGroup = self.colorDic[self.colorCode]

		if not partGroup or #partGroup <= 0 then
			print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorCode)

			return
		end

		local partIndex = partGroup[1]
		colorPartIndex = partIndex
	else
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)

		return
	end

	local isChange = self.parent:ChangeActiveList(self.selectedTab, colorPartIndex)

	if isChange then
		self:RefreshCheckList()
	end
end

function M:OnRenderCheckListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.checkList[index + 1]

	if not data then
		return
	end

	store.optionNameText = data.name
	store.priceText = data.price
	store.showPriceCtrl = data.isStandard and EShowPriceCtrl.Hide or EShowPriceCtrl.Show
end

function M:OnSelectCheckListItem(uList)
	local data = self.checkList[uList.selectedIndex + 1]
	local tabIndex = data.tabIndex

	if self.selectedTab == tabIndex then
		return
	end

	self.selectedTab = tabIndex

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.SubGroup.CommonTabSingleStore:SetSelectedIndex(uList.selectedIndex, nil, false)
		self.SubGroup.CommonTabSingleStore:RefreshItems()
	else
		self:RefreshTabTreeSelect()
	end

	self:RefreshItemList()
end

function M:OnClickTabLv2SwitchBtn(offset)
	if not self.selectedSecTab then
		return
	end

	local newSecTab = self.selectedSecTab + offset

	if newSecTab < 1 or newSecTab > 2 then
		return
	end

	self.selectedSecTab = newSecTab

	self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.selectedSecTab - 1, nil, true)
	self:RefreshColorMatItemList()
end

function M:RefreshTabTreeSelect()
	for i, data in ipairs(self.tabList) do
		self:_SetTabTreeDataSelect(data)
	end

	self.bindData.mobileTabTree:RefreshList()
end

function M:_SetTabTreeDataSelect(data)
	if self.selectedTab == self.colorTabIndex then
		if data.depth == 1 and self.selectedSecTab == data.index + 1 then
			data.selected = true
			data.isSelect = true
		elseif data.depth == 0 and self.selectedTab == data.index + 1 then
			data.selected = false
			data.expanded = true
			data.isSelect = true
		else
			data.selected = false
			data.isSelect = false
		end
	elseif data.depth == 0 and self.selectedTab == data.index + 1 then
		data.selected = true
		data.isSelect = true
	else
		data.selected = false
		data.isSelect = false
	end
end

function M:OnChangeTab(uList, isSub)
	if not isSub then
		local tabData = self.tabList[uList.selectedIndex + 1]
		self.selectedTab = tabData.index + 1

		self:RefreshItemList()
		self:RefreshCheckList()
	else
		self.selectedSecTab = uList.selectedIndex + 1

		self:RefreshColorMatItemList()
	end
end

function M:OnRenderTabItem(btn, index, data, store, isSub, uList)
	if isSub then
		store.title = self.subTabList[index + 1].title
	else
		store.title = data.title
	end
end

function M:OnRenderTabTreeItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		store.isSelectCtrl = data.isSelect and EMobileTabTreeTemplateSelectCtrl.True or EMobileTabTreeTemplateSelectCtrl.False

		if data.depth == 0 then
			local hasSecondTab = data.index + 1 == self.colorTabIndex
			store.hasSecondTabCtrl = hasSecondTab and EHasSecondTabCtrl.True or EHasSecondTabCtrl.False
		end
	end
end

function M:OnClickTabTreeItem(btn, data)
	if data.depth == 0 then
		self.selectedTab = data.index + 1

		self:RefreshItemList()
		self:RefreshCheckList()
	else
		self.selectedSecTab = data.index + 1

		self:RefreshColorMatItemList()
	end

	self:RefreshTabTreeSelect()
end

function M:RefreshPage()
	self.selectedTab = 1
	self.selectedSecTab = 1
	local colorPartIndex = self.parent.modifyIndex[self.colorTabIndex] or 1
	local partCfg = VehiclePartConfig.GetConfig(colorPartIndex)
	local colorId = partCfg and partCfg.ColorIndex or nil

	if colorId then
		local colorCfg = LTConfig.VehicleColorConfig.GetConfig(colorId)
		self.colorCode = colorCfg and colorCfg.ColorCode or nil
	else
		self.colorCode = nil
	end

	local vehicleCfg = VehicleConfig.GetConfig(self.parent.vehicleId)
	local carName = vehicleCfg and vehicleCfg.VehicleName or ""
	self.bindData.carNameText = carName

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local tabList = {}

		for i = 0, VehiclePartShopTabConfig.count - 1 do
			if self.parent.modifyData[i + 1] then
				if #self.parent.modifyData[i + 1] ~= 0 then
					local cfg = VehiclePartShopTabConfig.LoadAt(i)

					table.insert(tabList, {
						title = cfg.Title,
						index = i
					})

					if cfg.Name == "Kit" then
						self.kitTabIndex = i + 1
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
			title = "颜色"
		})
		table.insert(self.subTabList, {
			title = "材质"
		})
		self.SubGroup.CommonTabSingleStore:SetData(tabList, self.subTabList, 0, nil, self:CreateAction(self.OnChangeTab), self:CreateAction(self.OnRenderTabItem))
	else
		local tabList = {}

		for i = 0, VehiclePartShopTabConfig.count - 1 do
			if self.parent.modifyData[i + 1] then
				if #self.parent.modifyData[i + 1] ~= 0 then
					local cfg = VehiclePartShopTabConfig.LoadAt(i)
					local isSelect = i + 1 == self.selectedTab

					table.insert(tabList, {
						depth = 0,
						selected = isSelect,
						isSelect = isSelect,
						tIndex = EMobileTabTreeTemplateType.TabLv1,
						title = cfg.Title,
						index = i
					})

					if cfg.Name == "Kit" then
						self.kitTabIndex = i + 1
					end

					if cfg.IsColor then
						table.insert(tabList, {
							index = 0,
							title = "颜色",
							depth = 1,
							tIndex = EMobileTabTreeTemplateType.TabLv2
						})
						table.insert(tabList, {
							index = 1,
							title = "材质",
							depth = 1,
							tIndex = EMobileTabTreeTemplateType.TabLv2
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

	local function createVehicleCallback()
		self.mgr:SetCameraState(LTConfig.VehiclePartShopTabConfig.ViewTypeType.Right)
	end

	self.parent.mgr:OnCreateVehicle(self.parent.vehicleId, self.parent.activeList, createVehicleCallback)
end

function M:RefreshItemList()
	local cfg = VehiclePartShopTabConfig.GetConfig(self.selectedTab)

	if not cfg then
		return
	end

	local isColor = self.selectedTab == self.colorTabIndex
	self.bindData.isColor = self.mgr.BOOL2CTL[isColor]
	self.bindData.showTabLv2Ctrl = isColor and EShowTabLv2Ctrl.Show or EShowTabLv2Ctrl.Hide

	if isColor then
		self.selectedSecTab = 1

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.SubGroup.CommonTabSingleStore:SetSelectedIndex(self.selectedSecTab - 1, nil, true)
		end

		self:RefreshColorMatItemList()
	else
		self:RefreshKitOrPartItemList()
	end

	self.mgr:SetCameraState(cfg.ViewType)
end

function M:RefreshColorMatItemList()
	self.selectedSecTab = self.selectedSecTab or 1

	if self.selectedSecTab == 1 then
		self:RefreshColorItemList()
	else
		self:RefreshMatItemList()
	end
end

function M:RefreshMatItemList()
	self.bindData.listTypeCtrl = EListTypeCtrl.Size2
	local partGroup = self.colorDic[self.colorCode]

	if partGroup and #partGroup > 0 then
		self.bindData.size2itemList:SetSimpleList(#partGroup)

		if not self.parent.modifyIndex[self.selectedTab] then
			self.bindData.size2itemList:SelectItem(0)
		else
			for index, partId in ipairs(partGroup) do
				if partId == self.parent.modifyIndex[self.selectedTab] then
					self.bindData.size2itemList:SelectItem(index - 1)

					break
				end
			end
		end
	else
		print_error("汽修店改装材质列表错误，找不到对应颜色的部件组", self.colorList[self.colorCode])

		return
	end
end

function M:RefreshKitOrPartItemList()
	local partCount = #self.parent.modifyData[self.selectedTab]

	if partCount > 0 then
		if self.selectedTab == self.kitTabIndex then
			self.bindData.listTypeCtrl = EListTypeCtrl.Size1

			self.bindData.size1itemList:SetSimpleList(partCount)
			self.bindData.size1itemList:SelectItem(self.parent:GetSelected(self.selectedTab) - 1)
		else
			self.bindData.listTypeCtrl = EListTypeCtrl.Size2

			self.bindData.size2itemList:SetSimpleList(partCount)
			self.bindData.size2itemList:SelectItem(self.parent:GetSelected(self.selectedTab) - 1)
		end

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.isNeedChangeNav = true
		end
	else
		self.bindData.listTypeCtrl = EListTypeCtrl.Hide
	end
end

function M:RefreshColorItemList()
	self.bindData.listTypeCtrl = EListTypeCtrl.Color
	self.colorList, self.colorDic = self.mgr:GetActiveColorByModifyInfo(self.parent.modifyData[self.selectedTab])

	self:RefreshPartId2IndexDic()

	if self.selectedSecTab == 1 then
		self.bindData.colorList:SetSimpleList(#self.colorList)

		if not self.colorCode then
			self.bindData.colorList:SelectItem(0)
		else
			for index, colorCode in ipairs(self.colorList) do
				if colorCode == self.colorCode then
					self.bindData.colorList:SelectItem(index - 1)

					break
				end
			end
		end

		if gCS.LuaUtils.IsNonMobileAdaptive() then
			self.isNeedChangeNav = true
		end
	else
		print_error("汽修店改装二级tabIndex错误", self.selectedSecTab)
	end
end

function M:RefreshPartId2IndexDic()
	self.partId2IndexDic = {}
	local partList = self.parent.modifyData[self.selectedTab]

	for index, partId in ipairs(partList) do
		self.partId2IndexDic[partId] = index
	end
end

function M:RefreshCheckList()
	local checkList = {}
	local checkItem = nil
	local selectedIndex = -1

	for tabIndex, partList in pairs(self.parent.modifyData) do
		if #partList ~= 0 then
			local index = self.parent.modifyIndex[tabIndex] or 1
			local diffPrice, _, cmInfo = self.parent:GetPartDiffPriceAndMoneyIcon(tabIndex, index)

			if index == 1 then
				checkItem = {
					price = 0,
					isStandard = true,
					tabIndex = tabIndex,
					name = cmInfo.Name
				}
			else
				checkItem = {
					isStandard = false,
					tabIndex = tabIndex,
					price = diffPrice,
					name = cmInfo.Name
				}
			end

			table.insert(checkList, checkItem)

			if tabIndex == self.selectedTab then
				selectedIndex = #checkList
			end
		end
	end

	if self.kitTabIndex then
		checkList[self.kitTabIndex].price = self.parent:GetKitStartPrice(self.parent.vehicleId, self.parent.modifyIndex[self.kitTabIndex] or 1)
	else
		print_error("#NoCreateIssue @zhujiaying 汽修店改装套件配置有误，没有有效的套件")
	end

	self.checkList = checkList

	self.bindData.checkList:SetSimpleList(#checkList)

	if selectedIndex > 0 then
		self.bindData.checkList:SelectItem(selectedIndex - 1)
	end

	local price = self.parent:GetTotalPrice()
	local money = self.mgr:GetCurrentMoney()
	local isEnough = price <= money
	self.bindData.amountLabel = price
	self.bindData.isEnoughMoney = self.mgr.BOOL2CTL[isEnough]
	self.bindData.buyBtn.interactable = isEnough
end

function M:OnBuyBtnClick()
	self.parent:OnBuyBtnClick()
end
