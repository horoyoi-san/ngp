local FashionConfig = LTConfig.FashionConfig
local ShopBrandConfig = LTConfig.ShopBrandConfig
local FashionBaseConfig = LTConfig.FashionBaseConfig
C_DressFilterPanelStore = DefClass("C_DressFilterPanelStore", C_DressFilterPanelStore, C_StoreGroup)
GroupName2Class.DressFilterPanelStore = C_DressFilterPanelStore
local M = C_DressFilterPanelStore

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.clearBtn.luaClick = self:CreateAction("OnClearBtnClick")
	self.bindData.baseButton.luaClick = self:CreateAction("OnBackBtnClick")
	self.filterStore = nil
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.panelId = panelId
	self.callBack = data and data.callBack
	self.filterStore = data and data.filterStore
	self.hideCollectList = data and data.hideCollectList or false

	if self.hideCollectList then
		self.bindData.blurCtrl = 1
	else
		self.bindData.blurCtrl = 0
	end

	self:InitInfo()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, true, {})
end

function M:OnClose()
	if self.callBack then
		self.callBack()
	end

	self:CheckFilterMenuState()
	gDressSetPanelCamera:SetDressPanelCamera(self.m_Id, false)
end

function M:CheckFilterMenuState()
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

function M:InitInfo()
	self.contentStore = gStoreManager:GetStoreGroup("DressFilterContent"):GetStoreByWidget(self.bindData.scroll.content)
	self.contentStore.tagList.luaSimpleRenderItem = self:CreateAction("OnSelectTagList")
	self.contentStore.tagList.luaSimpleClick = self:CreateAction("OnChangeTagList")

	if not self.hideCollectList then
		self.contentStore.collectList.luaSimpleRenderItem = self:CreateAction("OnSelectCollectList")
		self.contentStore.collectList.luaSimpleClick = self:CreateAction("OnChangeCollectList")
	end

	self.contentStore.approachList.luaSimpleRenderItem = self:CreateAction("OnSelectApproachList")
	self.contentStore.approachList.luaSimpleClick = self:CreateAction("OnChangeApproachList")
	self.contentStore.brandList.luaSimpleRenderItem = self:CreateAction("OnSelectBrandList")
	self.contentStore.brandList.luaSimpleClick = self:CreateAction("OnChangeBrandList")

	if self.contentStore then
		self:InitTagList()

		if self.hideCollectList then
			self.contentStore.collectList.gameObject:SetActive(false)
		else
			self:InitCollectList()
		end

		self:InitApprochList()
		self:InitBrandList()
	end

	if not self.hideCollectList then
		local modelId = gCS.MyPlayerManager.PlayerUnit.ClientData.ModelId
		local modelCfg = LTConfig.GeneralModelConfig.GetConfig(modelId)

		if modelCfg == nil then
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

function M:InitTagList()
	self.tagList = {}
	local count = LTConfig.FashionTagConfig.count

	for i = 0, count - 1 do
		local fashionTagCfg = LTConfig.FashionTagConfig.LoadAt(i)

		if fashionTagCfg then
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

function M:InitCollectList()
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

function M:InitApprochList()
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

function M:InitBrandList()
	local brandList = {}
	local fashionInfoDict = gPlayerManager.infoMinor.bindData.PlayerFashionsInfo.FashionInfoDict

	for fashionId in pairs(fashionInfoDict) do
		local cfg = FashionConfig.GetConfig(fashionId)

		if cfg then
			if brandList[cfg.BelongBrand] == nil then
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

function M:OnBackBtnClick()
	gPanelManager:Close(self.panelId)
end

function M:OnClearBtnClick()
	print("OnClearBtnClick")

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

function M:OnSelectTagList(btn, index)
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

function M:OnChangeTagList(btn, index)
	local data = self.tagList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.tag, data.tagId)
	elseif table.contains(gDressManager.SelectType.tag, data.tagId) then
		local index = self:GetIndex(gDressManager.SelectType.tag, data.tagId)

		table.remove(gDressManager.SelectType.tag, index)
	end
end

function M:OnSelectCollectList(btn, index)
	local data = self.collectList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = table.contains(gDressManager.SelectType.collect, data.collectType)

		print("OnSelectCollectList")
	end
end

function M:OnChangeCollectList(btn, index)
	local data = self.collectList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.collect, data.collectType)
	elseif table.contains(gDressManager.SelectType.collect, data.collectType) then
		local index = self:GetIndex(gDressManager.SelectType.collect, data.collectType)

		table.remove(gDressManager.SelectType.collect, index)
	end
end

function M:OnSelectApproachList(btn, index)
	local data = self.approchTypeList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterTxtTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = table.contains(gDressManager.SelectType.approach, data.sourceType)

		print("OnSelectApproachList")
	end
end

function M:OnChangeApproachList(btn, index)
	local data = self.approchTypeList[index + 1]

	if btn.isSelected then
		table.insert(gDressManager.SelectType.approach, data.sourceType)
	elseif table.contains(gDressManager.SelectType.approach, data.sourceType) then
		local index = self:GetIndex(gDressManager.SelectType.approach, data.sourceType)

		table.remove(gDressManager.SelectType.approach, index)
	end
end

function M:OnSelectBrandList(btn, index)
	local data = self.brandList[index + 1]
	local store = gStoreManager:GetStoreGroup("FilterImgTemplateStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon
		store.name = data.name
		btn.isSelected = table.contains(gDressManager.SelectType.brand, data.brandId)

		print("OnSelectBrandList")
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
		local index = self:GetIndex(gDressManager.SelectType.brand, data.brandId)

		table.remove(gDressManager.SelectType.brand, index)
	end
end

function M:GetIndex(list, id)
	for i, v in pairs(list) do
		if v == id then
			return i
		end
	end
end
