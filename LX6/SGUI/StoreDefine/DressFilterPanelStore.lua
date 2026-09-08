-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DressFilterPanelStore.lua
-- Decompiled from: 01894_DressFilterPanelStore.lua_19e2b8456648.luajit

local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
local SHOW_SORT_CTRL = {
	["r+y^"] = 1,
	["i*rL"] = 0
}
C_DressFilterPanelStore = DefClass("C_DressFilterPanelStore", C_DressFilterPanelStore, C_StoreGroup)
GroupName2Class.DressFilterPanelStore = C_DressFilterPanelStore
local M = C_DressFilterPanelStore

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.clearBtn.luaClick = self.CreateAction(self, "OnClearBtnClick")
	self.bindData.baseButton.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.filterStore = nil
	self.sortStore = nil
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.panelId = panelId
	self.callBack = data and data.callBack
	self.filterStore = data and data.filterStore
	self.sortStore = data and data.sortStore
	self.hideCollectList = data and data.hideCollectList or false
	self.skipMovementState = data and data.skipMovementState or false

	if self.hideCollectList then
		self.bindData.blurCtrl = 1
	else
		self.bindData.blurCtrl = 0
	end

	self.InitInfo(self)

	local cameraParams = {}

	if not self.skipMovementState then
		cameraParams.movementState = LX6.Cinemachine.EMovementCamState.TryFashion
	end

	gDressStack:SetDressStack(self.m_Id, true, cameraParams)
end

M.OnClose = function(self)
	if self.callBack then
		self.callBack()
	end

	self:CheckFilterMenuState()
	gDressStack:SetDressStack(self.m_Id, false)
end

M.CheckFilterMenuState = function(self)
	if not self.filterStore then
		return
	end

	local tag = gDressManager.SelectType.tag
	local collect = gDressManager.SelectType.collect
	local approach = gDressManager.SelectType.approach
	local brand = gDressManager.SelectType.brand
	local state = nil

	if self.hideCollectList then
		state = table.isNilOrEmpty(approach) and table.isNilOrEmpty(brand) and table.isNilOrEmpty(tag)
	else
		state = table.isNilOrEmpty(collect) and table.isNilOrEmpty(approach) and table.isNilOrEmpty(brand) and table.isNilOrEmpty(tag)
	end

	self.filterStore:SetFilterMenuState(not state)
end

M.InitInfo = function(self)
	self.contentStore = gStoreManager:GetStoreGroup("DressFilterContent"):GetStoreByWidget(self.bindData.scroll.content)
	self.contentStore.tagList.luaSimpleRenderItem = self:CreateAction("OnSelectTagList")
	self.contentStore.tagList.luaSimpleClick = self:CreateAction("OnChangeTagList")

	if not self.hideCollectList then
		self.contentStore.collectList.luaSimpleRenderItem = self.CreateAction(self, "OnSelectCollectList")
		self.contentStore.collectList.luaSimpleClick = self.CreateAction(self, "OnChangeCollectList")
	end

	self.contentStore.approachList.luaSimpleRenderItem = self.CreateAction(self, "OnSelectApproachList")
	self.contentStore.approachList.luaSimpleClick = self.CreateAction(self, "OnChangeApproachList")
	self.contentStore.brandList.luaSimpleRenderItem = self.CreateAction(self, "OnSelectBrandList")
	self.contentStore.brandList.luaSimpleClick = self.CreateAction(self, "OnChangeBrandList")

	if self.contentStore then
		self.InitTagList(self)

		if self.hideCollectList then
			self.contentStore.collectList.gameObject:SetActive(false)
		else
			self.contentStore.collectList.gameObject:SetActive(true)
			self:InitCollectList()
		end

		self.InitApproachList(self)
		self.InitBrandList(self)
		self.InitSortSelector(self)
	end

	if not self.hideCollectList then
		local modelId = gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId
		local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)

		if modelCfg ~= nil then
			print_error("@libiao01 模型配表找不到，问题很严重！暂时换成空模型", "modelId = ", modelId, gCS.MyPlayerManager.PlayerUnit.ClientData.Name, "单位 配表ID ", gCS.MyPlayerManager.PlayerUnit.ClientData.SubType)

			modelCfg = LTConfig.GeneralModelConfig.GetConfig(LTConfig.GeneralModelConfig.EmptyModel)
			modelId = LTConfig.GeneralModelConfig.EmptyModel
		end

		local bodyType = modelCfg.BodyType
		local FashionBaseCfg = FashionBaseConfig.GetConfig(bodyType)

		if FashionBaseCfg then
			self.cameraOffset = FashionBaseCfg.CameraOffset
		end
	end
end

M.InitTagList = function(self)
	self.tagList = {}
	local count = LTConfig.FashionTagConfig.count

	for i = 0, count - 1 do
		local fashionTagCfg = LTConfig.FashionTagConfig.LoadAt(i)

		if fashionTagCfg and fashionTagCfg.IsShow then
			local view = {
				title = fashionTagCfg.Name,
				color = fashionTagCfg.BackgroundColor,
				tagId = fashionTagCfg.Id
			}

			table.insert(self.tagList, view)
		end
	end

	self.contentStore.tagList:SetSimpleList(#self.tagList)
end

M.InitCollectList = function(self)
	self.collectList = {}
	local FashionCollectDes = FashionConfig.FashionCollectDes or {}

	for i = 1, #FashionCollectDes do
		local view = {
			title = FashionCollectDes[i],
			collectType = i
		}

		table.insert(self.collectList, view)
	end

	self.contentStore.collectList:SetSimpleList(#self.collectList)
end

M.InitApproachList = function(self)
	self.approchTypeList = {}
	local FashionSourceDes = FashionConfig.FashionSourceDes

	for i = 1, #FashionSourceDes do
		local view = {
			title = FashionSourceDes[i].des,
			sourceType = FashionSourceDes[i].source
		}

		table.insert(self.approchTypeList, view)
	end

	self.contentStore.approachList:SetSimpleList(#self.approchTypeList)
end

M.InitBrandList = function(self)
	local brandList = {}
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	for fashionId in pairs(fashionInfoDict) do
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			if brandList[cfg.BelongBrand] ~= nil then
				brandList[cfg.BelongBrand] = {}
			end

			table.insert(brandList[cfg.BelongBrand], fashionId)
		end
	end

	self.brandList = {}

	for brandId, brandFashionId in pairs(brandList) do
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

M.InitSortSelector = function(self)
	local enabled = self.sortStore == nil and self.sortStore.SetSortState == nil
	self.contentStore.showSortCtrl = enabled and SHOW_SORT_CTRL.show or SHOW_SORT_CTRL.hide
	local selector = self.contentStore.dropSelector

	if not enabled or not selector then
		self.sortList = nil

		return
	end

	self.sortList = {}
	local sortItemTitle = FashionConfig.SortItemTitle

	for i = 1, #sortItemTitle do
		table.insert(self.sortList, {
			label = sortItemTitle[i],
			id = i
		})
	end

	selector.luaSimpleOptionClick = self.CreateAction(self, "OnDropSelectorSelectedChange")

	selector.SetSimpleOptions(selector, #self.sortList)

	for i = 1, #self.sortList do
		selector.SetItemLabel(selector, i - 1, self.sortList[i].label)
	end

	local sortItemId = self.sortStore:GetSortState()
	local selectedIndex = 0

	for i = 1, #self.sortList do
		if self.sortList[i].id ~= sortItemId then
			selectedIndex = i - 1

			break
		end
	end

	selector.SelectOption(selector, selectedIndex, false)
	self.RefreshSortTitle(self, selectedIndex)
end

M.OnDropSelectorSelectedChange = function(self, btn, index)
	local item = self.sortList and self.sortList[index + 1]

	if not item then
		return
	end

	self.RefreshSortTitle(self, index)

	if self.sortStore and self.sortStore.SetSortState then
		local _, isAscending = self.sortStore:GetSortState()

		self.sortStore:SetSortState(item.id, isAscending)
	end
end

M.RefreshSortTitle = function(self, index)
	local item = self.sortList and self.sortList[index + 1]
	local selector = self.contentStore and self.contentStore.dropSelector

	if item and selector and selector.title then
		selector.title.text = item.label
	end
end

M.OnBackBtnClick = function(self)
	gUIUtils:PlayAniClosePanel(self.bindData.anim, "S_Vx_DressFilterPanel_close", self.panelId)
end

M.OnClearBtnClick = function(self)
	gDressManager.SelectType.tag = {}
	gDressManager.SelectType.collect = {}
	gDressManager.SelectType.approach = {}
	gDressManager.SelectType.brand = {}

	self.contentStore.tagList:SetSimpleList(#self.tagList)

	if not self.hideCollectList then
		self.contentStore.collectList:SetSimpleList(#self.collectList)
	end

	self.contentStore.approachList:SetSimpleList(#self.approchTypeList)
	self.contentStore.brandList:SetSimpleList(#self.brandList)
end

M.OnSelectTagList = function(self, btn, index)
	local data = self.tagList[index + 1]
	local store = gStoreManager:GetStoreGroup("DressTagFilterStore"):GetStoreByWidget(btn)

	if store then
		local color = Color.New(data.color[1] / 255, data.color[2] / 255, data.color[3] / 255, data.color[4] / 255)
		store.title = data.title
		store.selectTitle = data.title
		store.titleColor = color
		store.frameColor = color
		store.selectFrameColor = color
		btn.isSelected = table.contains(gDressManager.SelectType.tag, data.tagId)
	end
end

M.OnChangeTagList = function(self, btn, index)
	local data = self.tagList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.tag, data.tagId)
	elseif table.contains(gDressManager.SelectType.tag, data.tagId) then
		local index = self.GetIndex(self, gDressManager.SelectType.tag, data.tagId)

		table.remove(gDressManager.SelectType.tag, index)
	end
end

M.OnSelectCollectList = function(self, btn, index)
	local data = self.collectList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = table.contains(gDressManager.SelectType.collect, data.collectType)
	end
end

M.OnChangeCollectList = function(self, btn, index)
	local data = self.collectList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.collect, data.collectType)
	elseif table.contains(gDressManager.SelectType.collect, data.collectType) then
		local index = self.GetIndex(self, gDressManager.SelectType.collect, data.collectType)

		table.remove(gDressManager.SelectType.collect, index)
	end
end

M.OnSelectApproachList = function(self, btn, index)
	local data = self.approchTypeList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = table.contains(gDressManager.SelectType.approach, data.sourceType)
	end
end

M.OnChangeApproachList = function(self, btn, index)
	local data = self.approchTypeList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.approach, data.sourceType)
	elseif table.contains(gDressManager.SelectType.approach, data.sourceType) then
		local index = self.GetIndex(self, gDressManager.SelectType.approach, data.sourceType)

		table.remove(gDressManager.SelectType.approach, index)
	end
end

M.OnSelectBrandList = function(self, btn, index)
	local data = self.brandList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterImgTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.name = data.name
		btn.isSelected = table.contains(gDressManager.SelectType.brand, data.brandId)
	end
end

M.OnChangeBrandList = function(self, btn, index)
	local data = self.brandList[index + 1]

	if table.isNilOrEmpty(gDressManager.SelectType.brand) then
		gDressManager.SelectType.brand = {}
	end

	if btn.isSelected then
		table.insert(gDressManager.SelectType.brand, data.brandId)
	elseif table.contains(gDressManager.SelectType.brand, data.brandId) then
		local index = self.GetIndex(self, gDressManager.SelectType.brand, data.brandId)

		table.remove(gDressManager.SelectType.brand, index)
	end
end

M.GetIndex = function(self, list, id)
	for i, v in pairs(list) do
		if v ~= id then
			return i
		end
	end
end
