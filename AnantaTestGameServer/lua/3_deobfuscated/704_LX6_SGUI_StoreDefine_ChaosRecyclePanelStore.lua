C_ChaosRecyclePanelStore = DefClass("C_ChaosRecyclePanelStore", C_ChaosRecyclePanelStore, C_StoreGroup)
GroupName2Class.ChaosRecyclePanelStore = C_ChaosRecyclePanelStore
local M = C_ChaosRecyclePanelStore
M.EquipType = {
	Weapon = 3,
	Body = 1,
	Camp = 2,
	Talent = 4
}
M.SortTypeIdMap = {
	Quality = 2,
	CreateTime = 1,
	Category = 3
}

function M:ctor()
	self.chaosListData = {}
	self.previewMaterialListData = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()

	self.msgEvents = {
		[gEventConstants.CHAOS_MASTER_FILTER] = self:CreateAction("RefreshChaosListAfterFilter"),
		[gEventConstants.CHAOS_MASTER_CHAOS_LOCKED] = self:CreateAction("OnChaosLockedChange")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:DefineAllVariables()
	self.selectedChaosIds = {}
	self.chaosList = {}
	self.previewMaterials = {}
end

function M:RegisterWidget()
	self.bindData.chaosList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosListItem")
	self.bindData.chaosList.luaSimpleClick = self:CreateAction("OnClickChaosList")
	self.bindData.chaosList.onGetTIndex = self:CreateAction("OnGetChaosListTIndex")
	self.bindData.previewMaterialList.luaSimpleRenderItem = self:CreateAction("OnRenderPreviewMaterialItem")
	self.bindData.previewMaterialList.onGetTIndex = self:CreateAction("OnGetPreviewMaterialListTIndex")
	self.bindData.decomposeBtn.luaClick = self:CreateAction("OnClickDecomposeBtn")
	self.bindData.quickSelectBtn.luaClick = self:CreateAction("OnClickQuickSelectBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickCloseBtn")

	if self.bindData.showMaterialBtn then
		self.bindData.showMaterialBtn.luaClick = self:CreateAction("OnClickShowMaterialBtn")
	end
end

function M:OnClickCloseBtn(btn, data)
	self.parent.bindData.tabRect.selectedIndex = 0

	self.parent:ChangeChaosModelVisible(true)
end

function M:OnClickShowMaterialBtn(btn, data)
	self:OnClickCloseSkillTipBtn()

	if gClientUtils.IsControllerMode() then
		gCommonItemManager:OnShowItemList(self.previewMaterials)
	end
end

function M:OnClickDecomposeBtn(btn, data)
	if #self.selectedChaosIds == 0 then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901208).Text)

		return
	end

	self:DoDecomposeChaos()
end

function M:OnClickQuickSelectBtn(btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_RECYCLE_PANEL,
		data = data
	})
end

function M:OnClickFilterBtn(btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_RECYCLE_PANEL,
		data = data
	})
end

function M:OnRenderChaosListItem(btn, index)
	local data = self.chaosListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosListItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.costText = data.cost > 0 and string.format("%d", data.cost) or ""
	store.quality = (data.quality or 3) - 3
	local isSelected = self:IsChaosSelected(data.Id)
	store.showMinusCtrl = not isSelected and 1 or 0
	store.lockCtrl = not data.isLocked and 1 or 0
end

function M:OnClickChaosList(btn, index)
	local data = self.chaosListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosListItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	self.bindData.toolTipStateCtrl = 0
	local chaosId = data.chaosData and data.chaosData.Id or data.Id
	local isSelected = self:IsChaosSelected(chaosId)

	if isSelected then
		self:UnselectChaos(chaosId)
	elseif data.canRecycle then
		self:SelectChaos(chaosId)
	end

	local nowSelected = self:IsChaosSelected(chaosId)
	store.showMinusCtrl = not nowSelected and 1 or 0

	if self.lastSelectChaos then
		self.lastSelectChaos.isSelected = false
	end

	btn.isSelected = true
	self.lastSelectChaos = btn

	self:RefreshSelectedCount()
	self:RefreshPreviewMaterials()
	self:RefreshChaosInfo(chaosId)
end

function M:OnRenderPreviewMaterialItem(item, index)
	local data = self.previewMaterialListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.countCtl = 0
	store.iconId = data.iconId
	store.count = data.count
	store.quality = data.quality - 1
	store.templateId = data.materialId
	item.luaRenderTooltip = self:CreateAction("OnMaterialItemRenderTooltip")
end

function M:OnGetChaosListTIndex(index)
	return 0
end

function M:OnGetPreviewMaterialListTIndex(index)
	return 0
end

function M:OnMaterialItemRenderTooltip(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemTips = gStoreManager:GetStoreGroup("InventoryItemDetailInfoTemplateStore")

	if itemTips then
		itemTips:SetSelectedItem({
			TemplateId = store.templateId
		})
	end
end

function M:OnEnable()
	return
end

function M:OnStart()
	if self.bindData.chaosRecycleToolTip then
		self.bindData.toolTipStateCtrl = 1
	end

	self.SubGroup.ChaosInfoTooltipStore:SetParentPanel(self)

	if self.bindData.closeSkillTipBtn then
		self.bindData.closeSkillTipBtn.luaClick = self:CreateAction("OnClickCloseSkillTipBtn")
	end
end

function M:RefreshChaosInfo(chaosId)
	self.SubGroup.ChaosInfoTooltipStore:RefreshChaosInfo(chaosId)
end

function M:OnClickCloseSkillTipBtn()
	self.SubGroup.ChaosInfoTooltipStore:OnClickCloseSkillTipBtn()
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:InitData()
	self.selectedChaosIds = {}
	self.filterData = nil
	self.lastSelectChaos = nil
end

function M:OnShow(panelId, data)
	self:InitData()

	self.parent = data and data.parent or nil

	self.parent:ChangeChaosModelVisible(false)
	self:RefreshChaosList()
	self:RefreshSelectedCount()
	self:RefreshPreviewMaterials()
end

function M:OnClose()
	self.selectedChaosIds = {}
	self.chaosList = {}
	self.previewMaterials = {}
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:IsChaosSelected(chaosId)
	for _, selectedId in ipairs(self.selectedChaosIds) do
		if selectedId == chaosId then
			return true
		end
	end

	return false
end

function M:SelectChaos(chaosId)
	if not self:IsChaosSelected(chaosId) then
		table.insert(self.selectedChaosIds, chaosId)
	end
end

function M:UnselectChaos(chaosId)
	for i, selectedId in ipairs(self.selectedChaosIds) do
		if selectedId == chaosId then
			table.remove(self.selectedChaosIds, i)

			break
		end
	end
end

function M:DoDecomposeChaos()
	if #self.selectedChaosIds == 0 then
		return
	end

	gClientToGameDelegate:AskDecompositePokemon(self.selectedChaosIds).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			self.selectedChaosIds = {}

			if #self.previewMaterials > 0 then
				gDropManager:ShowRewardWindow({
					ExtraRewardParam = 2,
					Param = self.previewMaterials
				})
			end

			self:RefreshChaosList()
			self:RefreshSelectedCount()
			self:RefreshPreviewMaterials()

			local curTooltipChaos = self.SubGroup.ChaosInfoTooltipStore.curChaosData

			if curTooltipChaos then
				local nowSelectId = curTooltipChaos.Id

				if nowSelectId and gBattlePetsMgr:GetPetDataById(nowSelectId) then
					self.bindData.toolTipStateCtrl = 1
				end
			end
		else
			gDisplayMessageMgr:ShowMessage(err)
		end
	end
end

function M:_getChaosCost(chaos)
	local bodyCost = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body).Cost
	local campCost = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp).Cost
	local weaponCost = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon).Cost
	local cost = bodyCost + campCost + weaponCost

	return cost
end

function M:_getChaosQuality(chaos)
	local limboChaConfig = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

	return limboChaConfig and limboChaConfig.Quality or 3
end

function M:_canRecycleChaos(chaos)
	if chaos.IsLocked then
		return false
	end

	return true
end

function M:_getDecomposeMaterials(chaosIds)
	local materials = {}
	local materialCounts = {}

	for _, chaosId in ipairs(chaosIds) do
		local chaos = gBattlePetsMgr:GetPetDataById(chaosId)

		if chaos then
			local limboChaConfig = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

			if limboChaConfig and limboChaConfig.ConsumableId then
				local materialId = limboChaConfig.ConsumableId
				local count = 1

				if materialCounts[materialId] then
					materialCounts[materialId] = materialCounts[materialId] + count
				else
					materialCounts[materialId] = count
				end
			end
		end
	end

	for materialId, count in pairs(materialCounts) do
		local materialCfg = LTConfig.ConsumableConfig.GetConfig(materialId)

		if materialCfg then
			table.insert(materials, {
				iconId = materialCfg.SItemIconId,
				count = count,
				quality = materialCfg.Quality,
				materialId = materialId,
				itemId = materialId,
				templateId = materialId,
				Count = count
			})
		end
	end

	return materials
end

function M:RefreshChaosList(afterFilter)
	local allChaos = gBattlePetsMgr.petDataDic
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

		if cfg then
			local cost = self:_getChaosCost(chaos)
			local quality = self:_getChaosQuality(chaos)
			local canRecycle = self:_canRecycleChaos(chaos)
			local shouldChoose = nil

			if afterFilter and self.filterData and self.filterData.quality and self.filterData.construct then
				shouldChoose = canRecycle

				if self.filterData.construct[self.EquipType.Weapon] then
					local weaponCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)

					if not self.filterData.quality[weaponCfg.Quality] then
						shouldChoose = false
					end
				end

				if self.filterData.construct[self.EquipType.Camp] then
					local campCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)

					if not self.filterData.quality[campCfg.Quality] then
						shouldChoose = false
					end
				end

				if self.filterData.construct[self.EquipType.Body] then
					local bodyCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)

					if not self.filterData.quality[bodyCfg.Quality] then
						shouldChoose = false
					end
				end

				if shouldChoose then
					self:SelectChaos(chaos.Id)
				end
			end

			local item = {
				iconId = cfg.CardIcon,
				selected = afterFilter and shouldChoose or self:IsChaosSelected(chaos.Id),
				Id = chaos.Id,
				cfg = cfg,
				chaosData = chaos,
				cost = cost,
				quality = quality,
				canRecycle = canRecycle,
				isLocked = chaos.IsLocked
			}

			table.insert(self.chaosList, item)
		end
	end

	table.sort(self.chaosList, function (a, b)
		if a.selected ~= b.selected then
			return a.selected
		end

		if a.quality ~= b.quality then
			return b.quality < a.quality
		end

		return b.cost < a.cost
	end)

	self.chaosListData = self.chaosList

	self.bindData.chaosList:SetSimpleList(#self.chaosList)
end

function M:RefreshSelectedCount()
	local selectedCount = #self.selectedChaosIds
	local totalCount = #self.chaosList
	self.bindData.selectCount = string.format("%d", selectedCount)
	self.bindData.totalCount = string.format("%d", totalCount)
end

function M:RefreshPreviewMaterials()
	self.previewMaterials = self:_getDecomposeMaterials(self.selectedChaosIds)
	self.previewMaterialListData = self.previewMaterials

	self.bindData.previewMaterialList:SetSimpleList(#self.previewMaterials)
end

function M:OnChaosLockedChange(eventId, chaosId)
	if table.contains(self.selectedChaosIds, chaosId) then
		self:UnselectChaos(chaosId)
		self:RefreshSelectedCount()
		self:RefreshPreviewMaterials()
	end

	self:RefreshChaosList()
end

function M:RefreshChaosListAfterFilter(eventId, filterData)
	if filterData.isFromInfo then
		return
	end

	self.filterData = filterData

	self:CleanupFilteredSelections()

	self.selectedChaosIds = {}

	self:RefreshChaosList(true)
	self:RefreshSelectedCount()
	self:RefreshPreviewMaterials()
end

function M:CleanupFilteredSelections()
	if not self.filterData or #self.selectedChaosIds == 0 then
		return
	end

	local validSelections = {}
	self.selectedChaosIds = validSelections
end
