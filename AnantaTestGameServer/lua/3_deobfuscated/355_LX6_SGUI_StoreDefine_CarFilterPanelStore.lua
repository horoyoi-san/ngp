local VehicleConfig = LTConfig.VehicleConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
C_CarFilterPanelStore = DefClass("C_CarFilterPanelStore", C_CarFilterPanelStore, C_StoreGroup)
GroupName2Class.CarFilterPanelStore = C_CarFilterPanelStore
local M = C_CarFilterPanelStore

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.filterStore = nil
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.callBack = data and data.callBack
	self.filterStore = data and data.filterStore

	self:InitInfo()
end

function M:OnClose()
	if self.callBack then
		self.callBack()
	end

	self:CheckFilterMenuState()
end

function M:CheckFilterMenuState()
	local brand = gDressManager.SelectType.brand
	local state = table.isNilOrEmpty(brand)

	if self.filterStore then
		self.filterStore:SetFilterMenuState(not state)
	end
end

function M:InitInfo()
	self.contentStore = gStoreManager:GetStoreGroup("CarFilterContent"):GetStoreByWidget(self.bindData.scroll.content)
	self.contentStore.brandList.luaSimpleRenderItem = self:CreateAction("OnSelectBrandList")
	self.contentStore.brandList.luaSimpleClick = self:CreateAction("OnChangeBrandList")

	if self.contentStore then
		self.contentStore.collectList.gameObject:SetActive(false)
		self.contentStore.approachList.gameObject:SetActive(false)
		self.contentStore.tagList.gameObject:SetActive(false)
		self:InitBrandList()
	end
end

function M:InitBrandList()
	local brandList = {}
	local vehicleCount = VehicleConfig.count

	for i = 0, vehicleCount - 1 do
		local vehicleCfg = VehicleConfig.LoadAt(i)

		if vehicleCfg and vehicleCfg.ShowInPedia and vehicleCfg.Brand and vehicleCfg.Brand > 0 then
			if brandList[vehicleCfg.Brand] == nil then
				brandList[vehicleCfg.Brand] = {}
			end

			table.insert(brandList[vehicleCfg.Brand], vehicleCfg.Id)
		end
	end

	self.brandList = {}

	for brandId, vehicleIds in pairs(brandList) do
		local brandCfg = ShopBrandConfig.GetConfig(brandId)

		if brandCfg then
			local view = {
				brandId = brandId,
				icon = brandCfg.BrandLogo,
				name = brandCfg.BrandName
			}

			table.insert(self.brandList, view)
		end
	end

	self.contentStore.brandList:SetSimpleList(#self.brandList)
end

function M:RegisterWidget()
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickBackBtn")
	self.bindData.clearBtn.luaClick = self:CreateAction("OnClickClearBtn")
	self.bindData.baseButton.luaClick = self:CreateAction("OnClickBaseButton")
end

function M:OnClickBackBtn()
	gPanelManager:Close(gPanelId.CAR_FILTER_PANEL)
end

function M:OnClickClearBtn()
	gDressManager.SelectType.brand = {}

	self.contentStore.brandList:SetSimpleList(#self.brandList)
end

function M:OnClickBaseButton()
	gPanelManager:Close(gPanelId.CAR_FILTER_PANEL)
end

function M:OnSelectBrandList(btn, index)
	local data = self.brandList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterImgTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.name = data.name
		btn.isSelected = table.contains(gDressManager.SelectType.brand, data.brandId)
	end
end

function M:OnChangeBrandList(btn, index)
	local data = self.brandList[index + 1]

	if table.isNilOrEmpty(gDressManager.SelectType.brand) then
		gDressManager.SelectType.brand = {}
	end

	if btn.isSelected then
		table.insert(gDressManager.SelectType.brand, data.brandId)
	elseif table.contains(gDressManager.SelectType.brand, data.brandId) then
		local idx = self:GetIndex(gDressManager.SelectType.brand, data.brandId)

		table.remove(gDressManager.SelectType.brand, idx)
	end
end

function M:GetIndex(list, id)
	for i, v in pairs(list) do
		if v == id then
			return i
		end
	end
end
