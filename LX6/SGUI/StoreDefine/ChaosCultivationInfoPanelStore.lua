-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosCultivationInfoPanelStore.lua
-- Decompiled from: 01459_ChaosCultivationInfoPanelStore.lua_57204882c88b.luajit

C_ChaosCultivationInfoPanelStore = DefClass("C_ChaosCultivationInfoPanelStore", C_ChaosCultivationInfoPanelStore, C_StoreGroup)
GroupName2Class.ChaosCultivationInfoPanelStore = C_ChaosCultivationInfoPanelStore
local M = C_ChaosCultivationInfoPanelStore
M.EquipType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["X-yB"] = 1,
	["Y#pK"] = 2,
	["(I\\x9d\\x8b\\x8dU"] = 4
}
M.SortTypeIdMap = {
	["\\xe8\\xce0\\xe8"] = 2,
	["pH˼\\x90\r\\x8c\r\\xc4\\xed"] = 1,
	["\\x88\\xb0\\xaem1\\xec*"] = 3
}

M.ctor = function(self)
	self.chaosPartListData = {}
	self.chaosListData = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.CHAOS_MASTER_FILTER] = self.CreateAction(self, "RefreshChaosListAfterFilter"),
		[gEventConstants.CHAOS_MASTER_CHAOS_UPDATE] = self.CreateAction(self, "RefreshChaosListAfterUpdate"),
		[gEventConstants.CHAOS_MASTER_CHAOS_LOCKED] = self.CreateAction(self, "RefreshChaosListAfterLock")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.DefineAllVariables = function(self)
	self.curChaosId = ulong.zero
end

M.RegisterWidget = function(self)
	self.bindData.chaosPartList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChaosPartItem")
	self.bindData.chaosPartList.onGetTIndex = self.CreateAction(self, "OnGetChaosPartListTIndex")
	self.bindData.chaosPartList.luaSimpleClick = self.CreateAction(self, "OnClickChaosPartItem")
	self.bindData.chaosList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChaosListItem")
	self.bindData.chaosList.luaSimpleClick = self.CreateAction(self, "OnClickChaosList")
	self.bindData.chaosList.luaSelectedChanged = self.CreateAction(self, "OnChaosListSelectChanged")
	self.bindData.chaosList.onGetTIndex = self.CreateAction(self, "OnGetChaosListTIndex")
	self.bindData.recycleBtn.luaClick = self.CreateAction(self, "OnClickRecycleBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.closeSkillTipBtn.luaClick = self.CreateAction(self, "OnClickCloseSkillTipBtn")

	if self.bindData.l2Btn then
		self.bindData.l2Btn.luaClick = self.CreateAction(self, "OnClickL2BtnByGamePad")
	end
end

M.OnClickCloseBtn = function(self, btn, data)
	gPanelManager:Close(gPanelId.CHAOS_CULTIVATION_MAIN_PANEL)
end

M.OnClickRecycleBtn = function(self, btn, data)
	self.parent.curChaosId = self.curChaosId
	self.parent.bindData.tabRect.selectedIndex = 2
end

M.OpenReshapeTab = function(self, subTab)
	self.parent.curChaosId = self.curChaosId
	self.parent.belong = subTab or 2
	self.parent.bindData.tabRect.selectedIndex = 1
end

M.OnClickFilterBtn = function(self, btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_CULTIVATION_MAIN_PANEL,
		data = data
	})
end

M.OnRenderChaosPartItem = function(self, btn, index)
	local data = self.chaosPartListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosEquipItem"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = nil

	if data.belong ~= self.EquipType.Body then
		cfg = LTConfig.ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
	elseif data.belong ~= self.EquipType.Camp then
		cfg = LTConfig.ChaosMasterCampConfig.GetConfig(self.curChaosData.Camp)
	elseif data.belong ~= self.EquipType.Weapon then
		cfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(self.curChaosData.Weapon)
	end

	if not cfg then
		store.isEmptyCtrl = 0

		return
	end

	store.quality = (cfg.Quality or 3) - 3
	local typeText = ""

	if data.belong ~= self.EquipType.Body then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901214).Text
	elseif data.belong ~= self.EquipType.Camp then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901215).Text
	elseif data.belong ~= self.EquipType.Weapon then
		typeText = LTConfig.TextScriptTextConfig.GetConfig(89901201).Text
	end

	store.typeText = typeText
	store.equipType = data.belong
	store.iconId = cfg.IconID or 0
	store.isEmptyCtrl = 1
end

M.OnGetChaosPartListTIndex = function(self, index)
	return 0
end

M.OnClickChaosPartItem = function(self, btn, index)
	local data = self.chaosPartListData[index + 1]

	if not data then
		return
	end

	self.OpenReshapeTab(self, data.belong)
end

M.OnRenderChaosListItem = function(self, btn, index)
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

M.OnClickChaosList = function(self, btn, index)
	local data = self.chaosListData[index + 1]

	if not data then
		return
	end

	local id = data.chaosData and data.chaosData.Id or data.Id

	if self.curChaosId ~= id then
		return
	end

	self.curChaosId = id
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)

	self:RefreshChaosList()
	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

M.OnGetChaosListTIndex = function(self, index)
	return 0
end

M.RefreshChaosInfo = function(self)
	self.SubGroup.ChaosInfoTooltipStore:RefreshChaosInfo(self.curChaosId, self:CreateAction("OpenBodyDetail"))
	self.parent:ReleaseModel()

	if self.curChaosData then
		self.parent:RefreshChaosModel(self.curChaosData.LimboChaId)
	end
end

M.OnClickCloseSkillTipBtn = function(self)
	if self.bindData.infoPaneNavArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.infoPaneNavArea
	end

	self.SubGroup.ChaosInfoTooltipStore:OnClickCloseSkillTipBtn()
end

M.OnClickL2BtnByGamePad = function(self)
	if self.bindData.skillNavArea then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.skillNavArea
	end

	if self.itemToolTipRefBtn and not gCS.LuaUtils.IsNull(self.itemToolTipRefBtn) then
		self.itemToolTipRefBtn:CloseTooltip(true)
	end
end

M.OnChaosListSelectChanged = function(self, uList)
	local selectedIndex = uList.selectedIndex

	if selectedIndex > 0 then
		self.OnClickChaosList(self, nil, selectedIndex)
	end
end

M.OnEnable = function(self)
	if self.curChaosId == ulong.zero then
		self.RefreshChaosInfo(self)
	end
end

M.OnStart = function(self)
	self.SubGroup.ChaosInfoTooltipStore:SetParentPanel(self)
end

M.OnDestroy = function(self)
	self.parent:ReleaseModel()
	self:ClearMessageEvents()
end

M.InitData = function(self, data)
	self.chaosList = {}
	self.filterData = nil
	self.parent = data and data.parent or nil
	self.curChaosId = data and data.curChaosId or ulong.zero
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
	self.bindData.isFilterEmptyCtrl = 1
	self.bindData.showBodyDetailCtrl = 1
end

M.OnShow = function(self, panelId, data)
	self.InitData(self, data)
	self.InitDropMenu(self)
	self.RefreshChaosList(self, not self.curChaosData)
	self.RefreshChaosEquipList(self)
	self.RefreshChaosInfo(self)
end

M.InitDropMenu = function(self)
	self.selectorList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 560,
			id = self.SortTypeIdMap.CreateTime
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 561,
			id = self.SortTypeIdMap.Quality
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 554,
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

M.OnSortBtnClick = function(self, _, _)
	self.RefreshChaosList(self)
end

M._getChaosCost = function(self, chaos)
	local bodyCost = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body).Cost
	local campCost = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp).Cost
	local weaponCost = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon).Cost
	local cost = bodyCost + campCost + weaponCost

	return cost
end

M._getChaosQuality = function(self, chaos)
	local limboChaConfig = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

	return limboChaConfig and limboChaConfig.Quality or 3
end

M.RefreshChaosEquipList = function(self)
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

M.RefreshChaosListAfterFilter = function(self, eventId, filterData)
	if not filterData.isFromInfo then
		return
	end

	self.filterData = filterData

	self:RefreshChaosList(true)

	self.bindData.isFilterEmptyCtrl = #self.chaosList <= 0 and 1 or 0

	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

M.RefreshChaosListAfterUpdate = function(self, eventId, data)
	if not gBattlePetsMgr:GetPetDataById(self.curChaosId) then
		self.RefreshChaosList(self, true)
	else
		self.RefreshChaosList(self)
	end

	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)

	self:RefreshChaosEquipList()
	self:RefreshChaosInfo()
end

M.RefreshChaosListAfterLock = function(self, eventId, data)
	for i = 1, #self.chaosListData do
		if self.chaosListData[i].Id ~= data.id then
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

M.RefreshChaosList = function(self, showFirst)
	local allChaos = gBattlePetsMgr.petDataDic
	local chaosNum = 0
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		chaosNum = chaosNum + 1
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

		if cfg then
			local cost = self._getChaosCost(self, chaos)
			local quality = self._getChaosQuality(self, chaos)

			if self.filterData and self.filterData.quality and self.filterData.construct then
				if self.filterData.construct[self.EquipType.Weapon] then
					local weaponCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)

					if not self.filterData.quality[weaponCfg.Quality] then
						-- Nothing
					end
				elseif self.filterData.construct[self.EquipType.Camp] then
					local campCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)

					if not self.filterData.quality[campCfg.Quality] then
						-- Nothing
					end
				elseif self.filterData.construct[self.EquipType.Body] then
					local bodyCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)

					if not self.filterData.quality[bodyCfg.Quality] then
						-- Nothing
					end
				end
			else
				local item = {
					iconId = cfg.CardIcon,
					selected = chaos.Id ~= self.curChaosId,
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

	if showFirst ~= true then
		if #self.chaosList <= 0 then
			self.curChaosId = self.chaosList[1].Id
			self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)
		else
			self.curChaosId = ulong.zero
			self.curChaosData = nil
		end
	end

	self.chaosListData = self.chaosList

	self.bindData.chaosList:SetSimpleList(#self.chaosList)

	self.bindData.isEmptyCtrl = chaosNum <= 0 and 1 or 0

	if #self.chaosList ~= 0 then
		self.parent.bindData.bgTextCtrl = 2
	else
		self.parent.bindData.bgTextCtrl = 0
	end
end

M.SortFunc = function(self, sortTypeId)
	local isAscending = self.SubGroup.FilterSorterComponentStore.isAscending

	if sortTypeId ~= self.SortTypeIdMap.CreateTime then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				if a.AcquireTime and b.AcquireTime then
					return b.AcquireTime <= a.AcquireTime
				end

				return b.limboChaId <= a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				if a.AcquireTime and b.AcquireTime then
					return a.AcquireTime <= b.AcquireTime
				end

				return a.limboChaId <= b.limboChaId
			end)
		end
	elseif sortTypeId ~= self.SortTypeIdMap.Quality then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				local qualityA = a.quality
				local qualityB = b.quality

				if qualityA == qualityB then
					return qualityB <= qualityA
				end

				if a.cost == b.cost then
					return b.cost <= a.cost
				end

				return b.limboChaId <= a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				local qualityA = a.quality
				local qualityB = b.quality

				if qualityA == qualityB then
					return qualityA <= qualityB
				end

				if a.cost == b.cost then
					return b.cost <= a.cost
				end

				return a.limboChaId <= b.limboChaId
			end)
		end
	elseif sortTypeId ~= self.SortTypeIdMap.Category then
		if isAscending then
			table.sort(self.chaosList, function (a, b)
				if a.limboChaId == b.limboChaId then
					return b.limboChaId <= a.limboChaId
				end

				if a.cost == b.cost then
					return b.cost <= a.cost
				end

				if a.AcquireTime and b.AcquireTime then
					return b.AcquireTime <= a.AcquireTime
				end

				return b.limboChaId <= a.limboChaId
			end)
		else
			table.sort(self.chaosList, function (a, b)
				if a.limboChaId == b.limboChaId then
					return a.limboChaId <= b.limboChaId
				end

				if a.cost == b.cost then
					return b.cost <= a.cost
				end

				if a.AcquireTime and b.AcquireTime then
					return a.AcquireTime <= b.AcquireTime
				end

				return a.limboChaId <= b.limboChaId
			end)
		end
	end
end

M.OpenBodyDetail = function(self)
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
		["\\xf4\\x92\\xfb>\\xea\\xe4\\x8fΖ2$"] = 0,
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

		if cfg and cfg.Quality ~= curBodyCfg.Quality and cfg.Id == curBodyId then
			local bodyData = {
				["\\xf4\\x92\\xfb>\\xea\\xe4\\x8fΖ2$"] = 1,
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

M.OnRenderBodyDetailItem = function(self, btn, index)
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

M.OnGetBodyDetailTIndex = function(self, index)
	return 0
end

M.OnCloseBodyDetail = function(self)
	self.bindData.showBodyDetailCtrl = 1
end

M.OnActiveDeviceChange = function(self, device)
end
