-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\VehicleFilterPanelStore.lua
-- Decompiled from: 01143_VehicleFilterPanelStore.lua_d9a1e56361b6.luajit

C_VehicleFilterPanelStore = DefClass("C_VehicleFilterPanelStore", C_VehicleFilterPanelStore, C_StoreGroup)
GroupName2Class.VehicleFilterPanelStore = C_VehicleFilterPanelStore
local M = C_VehicleFilterPanelStore
local VehicleTypeConfig = LTConfig.VehicleTypeConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local VehicleConfig = LTConfig.VehicleConfig

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = {
		["^\\xad\\xa7\\xa1\\xb3"] = 0,
		["O\\xaf\\xab\\xa4\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.blurCtrlEnum = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.callBack = data and data.callBack

	self:InitInfo()
end

M.OnClose = function(self)
	if self.callBack then
		self.callBack()
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.clearBtn.luaClick = self.CreateAction(self, self.OnClickClearBtn)
	self.bindData.baseButton.luaClick = self.CreateAction(self, self.OnClickBaseButton)
end

M.OnClickBackBtn = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
end

M.OnClickBaseButton = function(self)
	self.OnClickBackBtn(self)
end

M.OnClickClearBtn = function(self)
	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")
	local filter = mainStore and mainStore.vehicleFilter

	if not filter then
		return
	end

	self:_InitFilterSets(filter, true)
	self.contentStore.typeList:SetSimpleList(#self.typeList)
	self.contentStore.approachList:SetSimpleList(#self.approachList)
	self.contentStore.brandList:SetSimpleList(#self.brandList)

	filter.sortType = 1
	filter.ascending = true

	if self.sorterStore then
		self.sorterStore:SetAscending(true)
	end

	local selector = self.contentStore.sortTypeSelector

	if selector then
		selector.selectedIndex = 0

		selector.RefreshOptions(selector)
	end
end

M.InitInfo = function(self)
	self.contentStore = gStoreManager:GetStoreGroup(self.bindData.scroll.content.Store):GetStoreByWidget(self.bindData.scroll.content)

	if not self.contentStore then
		return
	end

	self.contentStore.typeList.luaSimpleRenderItem = self:CreateAction(self.OnSelectTypeList)
	self.contentStore.typeList.luaSimpleClick = self:CreateAction(self.OnChangeTypeList)
	self.contentStore.approachList.luaSimpleRenderItem = self:CreateAction(self.OnSelectApproachList)
	self.contentStore.approachList.luaSimpleClick = self:CreateAction(self.OnChangeApproachList)
	self.contentStore.brandList.luaSimpleRenderItem = self:CreateAction(self.OnSelectBrandList)
	self.contentStore.brandList.luaSimpleClick = self:CreateAction(self.OnChangeBrandList)
	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")

	if not mainStore then
		return
	end

	if not mainStore.vehicleFilter then
		mainStore.vehicleFilter = {
			["BTol@?"] = true,
			["\\xb8\\xbe\\xbf^'\\xee6"] = 1,
			typeSet = {},
			approachSet = {},
			brandSet = {}
		}

		self._InitFilterSets(self, mainStore.vehicleFilter, true)
	end

	self:InitTypeList()
	self:InitApproachList()
	self:InitBrandList()
	self:SetupSortTypeSelector()
	self:SetupSortOrder()
	self.contentStore.typeList:SetNavSelectToTop()
end

M._InitFilterSets = function(self, filter, isAll)
	filter.typeSet = {}
	filter.approachSet = {}
	filter.brandSet = {}

	if not isAll then
		return
	end

	for i = 0, VehicleTypeConfig.count - 1 do
		local cfg = VehicleTypeConfig.LoadAt(i)

		if cfg then
			filter.typeSet[cfg.Id] = true
		end
	end

	filter.approachSet[VehicleConfig.VehicleGetwayType.Mass] = true
	filter.approachSet[VehicleConfig.VehicleGetwayType.Drop] = true

	for i = 0, ShopBrandConfig.count - 1 do
		local cfg = ShopBrandConfig.LoadAt(i)

		if cfg then
			filter.brandSet[cfg.Id] = true
		end
	end
end

M.InitTypeList = function(self)
	self.typeList = {}

	for i = 0, VehicleTypeConfig.count - 1 do
		local cfg = VehicleTypeConfig.LoadAt(i)

		if cfg and cfg.CarshopCanShow then
			table.insert(self.typeList, {
				type = cfg.Id,
				title = cfg.DisplayName or ""
			})
		end
	end

	self.contentStore.typeList:SetSimpleList(#self.typeList)
end

M.InitApproachList = function(self)
	self.approachList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = "\\x94\\x95WV\\xa0",
			source = VehicleConfig.VehicleGetwayType.Mass
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = "\\x9a\\xa6xs\\x9c",
			source = VehicleConfig.VehicleGetwayType.Drop
		}
	}

	self.contentStore.approachList:SetSimpleList(#self.approachList)
end

M.InitBrandList = function(self)
	self.brandList = {}

	for i = 0, ShopBrandConfig.count - 1 do
		local cfg = ShopBrandConfig.LoadAt(i)

		if cfg and cfg.BrandType ~= ShopBrandConfig.BrandTypeType.Vehicle then
			table.insert(self.brandList, {
				brandId = cfg.Id,
				icon = cfg.BrandLogo,
				name = cfg.BrandName
			})
		end
	end

	self.contentStore.brandList:SetSimpleList(#self.brandList)
end

M.SetupSortTypeSelector = function(self)
	local selector = self.contentStore.sortTypeSelector

	if not selector then
		return
	end

	self.sortTypeOptions = {
		{
			["\\xb8\\xbe\\xbf^'\\xee6"] = 1,
			["t#p^"] = "\\x99\\xbbpW\\x89"
		},
		{
			["\\xb8\\xbe\\xbf^'\\xee6"] = 2,
			["t#p^"] = "\\xe7\\x98{\\xf2\\xa3Dt\\xb0\\xbc\\xf3\\x89\\x98"
		}
	}

	selector.SetSimpleOptions(selector, 0)

	for i = 1, #self.sortTypeOptions do
		selector.AddSimpleOptionLabel(selector, 0, self.sortTypeOptions[i].name, false)
	end

	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")
	local filter = mainStore and mainStore.vehicleFilter
	local curSortType = filter and filter.sortType or 1
	selector.selectedIndex = curSortType - 1

	selector:RefreshOptions()

	selector.luaSelectedChanged = self:CreateAction(self.OnSortTypeChanged)
end

M.SetupSortOrder = function(self)
	local orderWidget = self.contentStore.sortOrderSelectBtn

	if not orderWidget then
		return
	end

	self.sorterStore = gStoreManager:GetStoreGroup(orderWidget.Store)

	if not self.sorterStore then
		return
	end

	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")
	local filter = mainStore and mainStore.vehicleFilter

	if filter and filter.ascending ~= false then
		self.sorterStore:SetAscending(false)
	end

	self.sorterStore:SetOrderChangedCallback(self:CreateAction(self.OnOrderChanged))
end

M.OnSelectTypeList = function(self, btn, index)
	local data = self.typeList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data and data.title or ""
		local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter
		btn.isSelected = filter and filter.typeSet[data.type] or false
	end
end

M.OnChangeTypeList = function(self, btn, index)
	local data = self.typeList[index + 1]
	local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter

	if not filter or not data then
		return
	end

	if btn.isSelected then
		filter.typeSet[data.type] = true
	else
		filter.typeSet[data.type] = nil
	end
end

M.OnSelectApproachList = function(self, btn, index)
	local data = self.approachList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data and data.title or ""
		local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter
		btn.isSelected = filter and filter.approachSet[data.source] or false
	end
end

M.OnChangeApproachList = function(self, btn, index)
	local data = self.approachList[index + 1]
	local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter

	if not filter or not data then
		return
	end

	if btn.isSelected then
		filter.approachSet[data.source] = true
	else
		filter.approachSet[data.source] = nil
	end
end

M.OnSelectBrandList = function(self, btn, index)
	local data = self.brandList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterImgTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data and data.icon or nil
		store.name = data and data.name or ""
		local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter
		btn.isSelected = filter and filter.brandSet[data.brandId] or false
	end
end

M.OnChangeBrandList = function(self, btn, index)
	local data = self.brandList[index + 1]
	local filter = gStoreManager:GetStoreGroup("CarModsPanelStore").vehicleFilter

	if not filter or not data then
		return
	end

	if btn.isSelected then
		filter.brandSet[data.brandId] = true
	else
		filter.brandSet[data.brandId] = nil
	end
end

M.OnSortTypeChanged = function(self, selector)
	local option = self.sortTypeOptions and self.sortTypeOptions[selector.selectedIndex + 1]
	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")
	local filter = mainStore and mainStore.vehicleFilter

	if filter and option then
		filter.sortType = option.sortType
	end

	selector.ClosePopUp(selector)
end

M.OnOrderChanged = function(self, isAscending)
	local mainStore = gStoreManager:GetStoreGroup("CarModsPanelStore")
	local filter = mainStore and mainStore.vehicleFilter

	if filter then
		filter.ascending = isAscending
	end
end
