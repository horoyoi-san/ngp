C_ChaosCultivationInfoPanelStore = DefClass("C_ChaosCultivationInfoPanelStore", C_ChaosCultivationInfoPanelStore, C_StoreGroup)
GroupName2Class.ChaosCultivationInfoPanelStore = C_ChaosCultivationInfoPanelStore
local M = C_ChaosCultivationInfoPanelStore
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
	self.chaosPartListData = {}
	self.chaosListData = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:RegisterWidget()

	self.msgEvents = {
		[gEventConstants.CHAOS_MASTER_FILTER] = self:CreateAction("RefreshChaosListAfterFilter"),
		[gEventConstants.CHAOS_MASTER_CHAOS_UPDATE] = self:CreateAction("RefreshChaosListAfterUpdate"),
		[gEventConstants.CHAOS_MASTER_CHAOS_LOCKED] = self:CreateAction("RefreshChaosListAfterLock")
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:DefineAllVariables()
	self.curChaosId = ulong.zero
end

function M:RegisterWidget()
	self.bindData.chaosPartList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosPartItem")
	self.bindData.chaosPartList.onGetTIndex = self:CreateAction("OnGetChaosPartListTIndex")
	self.bindData.chaosPartList.luaSimpleClick = self:CreateAction("OnClickChaosPartItem")
	self.bindData.chaosList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosListItem")
	self.bindData.chaosList.luaSimpleClick = self:CreateAction("OnClickChaosList")
	self.bindData.chaosList.luaSelectedChanged = self:CreateAction("OnChaosListSelectChanged")
	self.bindData.chaosList.onGetTIndex = self:CreateAction("OnGetChaosListTIndex")
	self.bindData.recycleBtn.luaClick = self:CreateAction("OnClickRecycleBtn")
	self.bindData.backBtn.luaClick = self:CreateAction("OnClickCloseBtn")
	self.bindData.closeSkillTipBtn.luaClick = self:CreateAction("OnClickCloseSkillTipBtn")

	if self.bindData.l2Btn then
		self.bindData.l2Btn.luaClick = self:CreateAction("OnClickL2BtnByGamePad")
	end
end

function M:OnClickCloseBtn(btn, data)
	gPanelManager:Close(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL)
end

function M:OnClickRecycleBtn(btn, data)
	self.parent.curChaosId = self.curChaosId
	self.parent.bindData.tabRect.selectedIndex = 2
end

function M:OpenReshapeTab(subTab)
	self.parent.curChaosId = self.curChaosId
	self.parent.belong = subTab or 2
	self.parent.bindData.tabRect.selectedIndex = 1
end

function M:OnClickFilterBtn(btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_CULTIVATION_MAIN_PANEL,
		data = data
	})
end

function M:OnRenderChaosPartItem(btn, index)
	local data = self.chaosPartListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosEquipItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = nil

	if data.belong == self.EquipType.Body then
		cfg = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
	elseif data.belong == self.EquipType.Camp then
		cfg = LTConfig.ChaosMasterCampConfig.GetConfig(self.curChaosData.Camp)
	elseif data.belong == self.EquipType.Weapon then
		cfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curChaosData.Weapon)
	end

	if not cfg then
		store.isEmptyCtrl = 0

		return
	end

	store.quality = (cfg.Quality or 3) - 3
	local typeText = ""

	if data.belong == self.EquipType.Body then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901214).Text
	elseif data.belong == self.EquipType.Camp then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901215).Text
	elseif data.belong == self.EquipType.Weapon then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901201).Text
	end

	store.typeText = typeText
	store.equipType = data.belong
	store.iconId = cfg.IconID or 0
	store.isEmptyCtrl = 1
end

function M:OnGetChaosPartListTIndex(index)
	return 0
end

function M:OnClickChaosPartItem(btn, index)
	local data = self.chaosPartListData[index + 1]

	if not data then
		return
	end

	self:OpenReshapeTab(data.belong)
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
	store.costText = data.cost
	store.quality = (data.quality or 3) - 3
	btn.isSelected = data.selected
	store.lockCtrl = not data.isLocked and 1 or 0
	btn.autoClickOnHover = true
end

function M:OnClickChaosList(btn, index)
	local data = self.chaosListData[index + 1]

	if not data then
		return
	end

	local id = data.chaosData and data.chaosData.Id or data.Id

	if self.curChaosId == id then
		return
	end

	self.curChaosId = id
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)

	self:RefreshChaosList()
	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

function M:OnGetChaosListTIndex(index)
	return 0
end

function M:RefreshChaosInfo()
	self.SubGroup.ChaosInfoTooltipStore:RefreshChaosInfo(self.curChaosId, self:CreateAction("OpenBodyDetail"))
	self.parent:ReleaseModel()

	if self.curChaosData then
		self.parent:RefreshChaosModel(self.curChaosData.LimboChaId)
	end
end

function M:OnClickCloseSkillTipBtn()
	if self.bindData.infoPaneNavArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.infoPaneNavArea
	end

	self.SubGroup.ChaosInfoTooltipStore:OnClickCloseSkillTipBtn()
end

function M:OnClickL2BtnByGamePad()
	if self.bindData.skillNavArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.skillNavArea
	end

	if self.itemToolTipRefBtn and not gCS.LuaUtils.IsNull(self.itemToolTipRefBtn) then
		self.itemToolTipRefBtn:CloseTooltip(true)
	end
end

function M:OnChaosListSelectChanged(uList)
	local selectedIndex = uList.selectedIndex

	if selectedIndex >= 0 then
		self:OnClickChaosList(nil, selectedIndex)
	end
end

function M:OnEnable()
	if self.curChaosId ~= ulong.zero then
		self:RefreshChaosInfo()
	end
end

function M:OnStart()
	self.SubGroup.ChaosInfoTooltipStore:SetParentPanel(self)
end

function M:OnDestroy()
	self.parent:ReleaseModel()
	self:ClearMessageEvents()
end

function M:InitData(data)
	self.chaosList = {}
	self.filterData = nil
	self.parent = data and data.parent or nil
	self.curChaosId = data and data.curChaosId or ulong.zero
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
	self.bindData.isFilterEmptyCtrl = 1
	self.bindData.showBodyDetailCtrl = 1
end

function M:OnShow(panelId, data)
	self:InitData(data)
	self:InitDropMenu()
	self:RefreshChaosList(not self.curChaosData)
	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

function M:InitDropMenu()
	self.selectorList = {
		{
			title = 560,
			id = self.SortTypeIdMap.CreateTime
		},
		{
			title = 561,
			id = self.SortTypeIdMap.Quality
		},
		{
			title = 554,
			id = self.SortTypeIdMap.Category
		}
	}

	self.SubGroup.FilterSorterComponentStore:SetData({
		onSortChanged = self:CreateAction("OnSortBtnClick"),
		onFilterBtnClick = self:CreateAction("OnClickFilterBtn"),
		sortList = self.selectorList
	})

	self.SubGroup.FilterSorterComponentStore.bindData.showFilter = 0

	self.SubGroup.FilterSorterComponentStore:SelectOption(0, true)
end

function M:OnSortBtnClick(_, _)
	self:RefreshChaosList()
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

function M:RefreshChaosEquipList()
	if self.curChaosData then
		local partListData = {
			{
				belong = self.EquipType.Camp
			},
			{
				belong = self.EquipType.Weapon
			}
		}
		self.chaosPartListData = partListData

		self.bindData.chaosPartList:SetSimpleList(#partListData)
	end
end

function M:RefreshChaosListAfterFilter(eventId, filterData)
	if not filterData.isFromInfo then
		return
	end

	self.filterData = filterData

	self:RefreshChaosList(true)

	self.bindData.isFilterEmptyCtrl = #self.chaosList > 0 and 1 or 0

	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

function M:RefreshChaosListAfterUpdate(eventId, data)
	if not gBattlePetsMgr:GetPetDataById(self.curChaosId) then
		self:RefreshChaosList(true)
	else
		self:RefreshChaosList()
	end

	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)

	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

function M:RefreshChaosListAfterLock(eventId, data)
	for i = 1, #self.chaosListData do
		if self.chaosListData[i].Id == data.id then
			self.chaosListData[i].isLocked = data.isLock
			local hasWidget, widget = self.bindData.chaosList:TryGetChildAt(i - 1, nil)

			if hasWidget then
				local store = gStoreManager:GetStoreGroup("ChaosListItem"):GetStoreByWidget(widget)

				if store then
					store.lockCtrl = not data.isLock and 1 or 0
				end
			end

			break
		end
	end
end

function M:RefreshChaosList(showFirst)
	local allChaos = gBattlePetsMgr.petDataDic
	local chaosNum = 0
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		chaosNum = chaosNum + 1
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

		if cfg then
			local cost = self:_getChaosCost(chaos)
			local quality = self:_getChaosQuality(chaos)

			if self.filterData and self.filterData.quality and self.filterData.construct then
				if self.filterData.construct[self.EquipType.Weapon] then
					local weaponCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)
				elseif self.filterData.construct[self.EquipType.Camp] then
					local campCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)
				end
			else
				local item = {
					iconId = cfg.CardIcon,
					selected = chaos.Id == self.curChaosId,
					Id = chaos.Id,
					limboChaId = chaos.LimboChaId,
					cfg = cfg,
					chaosData = chaos,
					cost = cost,
					quality = quality,
					isLocked = chaos.IsLocked
				}

				table.insert(self.chaosList, item)
			end
		end
	end

	local dropSelectedItem = self.SubGroup.FilterSorterComponentStore:GetSelectedItem()

	self:SortFunc(dropSelectedItem.id)

	if showFirst == true then
		if #self.chaosList > 0 then
			self.curChaosId = self.chaosList[1].Id
			self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
		else
			self.curChaosId = ulong.zero
			self.curChaosData = nil
		end
	end

	self.chaosListData = self.chaosList

	self.bindData.chaosList:SetSimpleList(#self.chaosList)

	self.bindData.isEmptyCtrl = chaosNum > 0 and 1 or 0

	if #self.chaosList == 0 then
		self.parent.bindData.bgTextCtrl = 2
	else
		self.parent.bindData.bgTextCtrl = 0
	end
end

function M:SortFunc(sortTypeId)
	local isAscending = self.SubGroup.FilterSorterComponentStore.isAscending

	if sortTypeId == self.SortTypeIdMap.CreateTime then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				if a.AcquireTime and b.AcquireTime then
					return b.AcquireTime < a.AcquireTime
				end

				return b.limboChaId < a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				if a.AcquireTime and b.AcquireTime then
					return a.AcquireTime < b.AcquireTime
				end

				return a.limboChaId < b.limboChaId
			end)
		end
	elseif sortTypeId == self.SortTypeIdMap.Quality then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				local qualityA = a.quality
				local qualityB = b.quality

				if qualityA ~= qualityB then
					return qualityB < qualityA
				end

				if a.cost ~= b.cost then
					return b.cost < a.cost
				end

				return b.limboChaId < a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				local qualityA = a.quality
				local qualityB = b.quality

				if qualityA ~= qualityB then
					return qualityA < qualityB
				end

				if a.cost ~= b.cost then
					return b.cost < a.cost
				end

				return a.limboChaId < b.limboChaId
			end)
		end
	elseif sortTypeId == self.SortTypeIdMap.Category then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				if a.limboChaId ~= b.limboChaId then
					return b.limboChaId < a.limboChaId
				end

				if a.cost ~= b.cost then
					return b.cost < a.cost
				end

				if a.AcquireTime and b.AcquireTime then
					return b.AcquireTime < a.AcquireTime
				end

				return b.limboChaId < a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				if a.limboChaId ~= b.limboChaId then
					return a.limboChaId < b.limboChaId
				end

				if a.cost ~= b.cost then
					return b.cost < a.cost
				end

				if a.AcquireTime and b.AcquireTime then
					return a.AcquireTime < b.AcquireTime
				end

				return a.limboChaId < b.limboChaId
			end)
		end
	end
end

function M:OpenBodyDetail()
	self.bindData.showBodyDetailCtrl = 0
	local bodyDetail = self.bindData.chaosBodyDetail
	local store = gStoreManager:GetStoreGroup(bodyDetail.Store):GetStoreByWidget(bodyDetail)

	if not store then
		return
	end

	store.closeBtn.luaClick = self:CreateAction("OnCloseBodyDetail")
	store.bodyList.luaSimpleRenderItem = self:CreateAction("OnRenderBodyDetailItem")
	store.bodyList.onGetTIndex = self:CreateAction("OnGetBodyDetailTIndex")
	local tableBodyData = {}
	local curBodyId = self.curChaosData and self.curChaosData.Body or 0
	local curBodyCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(curBodyId)

	table.insert(tableBodyData, {
		showBelongCtrl = 0,
		id = curBodyId,
		iconId = curBodyCfg.IconID,
		titleText = curBodyCfg.BodyName,
		desText = curBodyCfg.BodyDescription,
		cost = curBodyCfg.Cost,
		quality = curBodyCfg.Quality,
		config = curBodyCfg
	})

	for i = 0, LTConfig.ChaosMasterBodyConfig.count - 1 do
		local cfg = LTConfig.ChaosMasterBodyConfig.LoadAt(i)

		if cfg and cfg.Quality == curBodyCfg.Quality and cfg.Id ~= curBodyId then
			local bodyData = {
				showBelongCtrl = 1,
				id = cfg.Id,
				iconId = cfg.IconID,
				titleText = cfg.BodyName,
				desText = cfg.BodyDescription,
				cost = cfg.Cost,
				quality = cfg.Quality,
				config = cfg
			}

			table.insert(tableBodyData, bodyData)
		end
	end

	self.tableBodyData = tableBodyData

	store.bodyList:SetSimpleList(#tableBodyData)
end

function M:OnRenderBodyDetailItem(btn, index)
	local data = self.tableBodyData and self.tableBodyData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosBodyDetailTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.titleText = data.titleText
	store.desText = data.desText or ""
	store.showBelongCtrl = data.showBelongCtrl
	local costItem = gStoreManager:GetStoreGroup(store.costItem.Store):GetStoreByWidget(store.costItem)
	costItem.quality = (data.quality or 3) - 3
end

function M:OnGetBodyDetailTIndex(index)
	return 0
end

function M:OnCloseBodyDetail()
	self.bindData.showBodyDetailCtrl = 1
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
