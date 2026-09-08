-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosRecyclePanelStore.lua
-- Decompiled from: 01474_ChaosRecyclePanelStore.lua_278b97b292ab.luajit

C_ChaosRecyclePanelStore = DefClass("C_ChaosRecyclePanelStore", C_ChaosRecyclePanelStore, C_StoreGroup)
GroupName2Class.ChaosRecyclePanelStore = C_ChaosRecyclePanelStore
local M = C_ChaosRecyclePanelStore
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
	self.chaosListData = {}
	self.previewMaterialListData = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)

	self.msgEvents = {
		[gEventConstants.CHAOS_MASTER_FILTER] = self.CreateAction(self, "RefreshChaosListAfterFilter"),
		[gEventConstants.CHAOS_MASTER_CHAOS_LOCKED] = self.CreateAction(self, "OnChaosLockedChange")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.DefineAllVariables = function(self)
	self.selectedChaosIds = {}
	self.chaosList = {}
	self.previewMaterials = {}
end

M.RegisterWidget = function(self)
	self.bindData.chaosList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderChaosListItem")
	self.bindData.chaosList.luaSimpleClick = self.CreateAction(self, "OnClickChaosList")
	self.bindData.chaosList.onGetTIndex = self.CreateAction(self, "OnGetChaosListTIndex")
	self.bindData.previewMaterialList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderPreviewMaterialItem")
	self.bindData.previewMaterialList.onGetTIndex = self.CreateAction(self, "OnGetPreviewMaterialListTIndex")
	self.bindData.decomposeBtn.luaClick = self.CreateAction(self, "OnClickDecomposeBtn")
	self.bindData.quickSelectBtn.luaClick = self.CreateAction(self, "OnClickQuickSelectBtn")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")

	if self.bindData.showMaterialBtn then
		self.bindData.showMaterialBtn.luaClick = self.CreateAction(self, "OnClickShowMaterialBtn")
	end
end

M.OnClickCloseBtn = function(self, btn, data)
	self.parent.bindData.tabRect.selectedIndex = 0

	self.parent:ChangeChaosModelVisible(true)
end

M.OnClickShowMaterialBtn = function(self, btn, data)
	self.OnClickCloseSkillTipBtn(self)

	if gClientUtils.IsControllerMode() then
		gCommonItemManager:OnShowItemList(self.previewMaterials)
	end
end

M.OnClickDecomposeBtn = function(self, btn, data)
	if #self.selectedChaosIds ~= 0 then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89901208).Text)

		return
	end

	self.DoDecomposeChaos(self)
end

M.OnClickQuickSelectBtn = function(self, btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_RECYCLE_PANEL,
		data = data
	})
end

M.OnClickFilterBtn = function(self, btn, data)
	gPanelManager:CheckShow(gPanelId.CHAOS_FILTER_PANEL, {
		from = gPanelId.CHAOS_RECYCLE_PANEL,
		data = data
	})
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
	store.costText = data.cost <= 0 and string.format("%d", data.cost) or ""
	store.quality = (data.quality or 3) - 3
	local isSelected = self:IsChaosSelected(data.Id)
	store.showMinusCtrl = not isSelected and 1 or 0
	store.lockCtrl = not data.isLocked and 1 or 0
end

M.OnClickChaosList = function(self, btn, index)
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
		self.UnselectChaos(self, chaosId)
	elseif data.canRecycle then
		self.SelectChaos(self, chaosId)
	end

	local nowSelected = self:IsChaosSelected(chaosId)
	store.showMinusCtrl = not nowSelected and 1 or 0

	if self.lastSelectChaos then
		self.lastSelectChaos.isSelected = false
	end

	btn.isSelected = true
	self.lastSelectChaos = btn

	self.RefreshSelectedCount(self)
	self.RefreshPreviewMaterials(self)
	self.RefreshChaosInfo(self, chaosId)
end

M.OnRenderPreviewMaterialItem = function(self, item, index)
	local data = self.previewMaterialListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.count = data.count
	store.quality = data.quality - 1
	store.templateId = data.materialId
	item.luaRenderTooltip = self.CreateAction(self, "OnMaterialItemRenderTooltip")
end

M.OnGetChaosListTIndex = function(self, index)
	return 0
end

M.OnGetPreviewMaterialListTIndex = function(self, index)
	return 0
end

M.OnMaterialItemRenderTooltip = function(self, btn, popup, index)
	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local itemTips = gStoreManager:GetStoreGroup("InventoryItemDetailInfoTemplateStore")

	if itemTips then
		itemTips.SetSelectedItem(itemTips, {
			TemplateId = store.templateId
		})
	end
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	if self.bindData.chaosRecycleToolTip then
		self.bindData.toolTipStateCtrl = 1
	end

	self.SubGroup.ChaosInfoTooltipStore:SetParentPanel(self)

	if self.bindData.closeSkillTipBtn then
		self.bindData.closeSkillTipBtn.luaClick = self.CreateAction(self, "OnClickCloseSkillTipBtn")
	end
end

M.RefreshChaosInfo = function(self, chaosId)
	self.SubGroup.ChaosInfoTooltipStore:RefreshChaosInfo(chaosId)
end

M.OnClickCloseSkillTipBtn = function(self)
	self.SubGroup.ChaosInfoTooltipStore:OnClickCloseSkillTipBtn()
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.InitData = function(self)
	self.selectedChaosIds = {}
	self.filterData = nil
	self.lastSelectChaos = nil
end

M.OnShow = function(self, panelId, data)
	self:InitData()

	self.parent = data and data.parent or nil

	self.parent:ChangeChaosModelVisible(false)
	self:RefreshChaosList()
	self:RefreshSelectedCount()
	self:RefreshPreviewMaterials()
end

M.OnClose = function(self)
	self.selectedChaosIds = {}
	self.chaosList = {}
	self.previewMaterials = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.IsChaosSelected = function(self, chaosId)
	for _, selectedId in ipairs(self.selectedChaosIds) do
		if selectedId ~= chaosId then
			return true
		end
	end

	return false
end

M.SelectChaos = function(self, chaosId)
	if not self.IsChaosSelected(self, chaosId) then
		table.insert(self.selectedChaosIds, chaosId)
	end
end

M.UnselectChaos = function(self, chaosId)
	for i, selectedId in ipairs(self.selectedChaosIds) do
		if selectedId ~= chaosId then
			table.remove(self.selectedChaosIds, i)

			break
		end
	end
end

M.DoDecomposeChaos = function(self)
	if #self.selectedChaosIds ~= 0 then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskDecompositePokemon(self.selectedChaosIds).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			self.selectedChaosIds = {}

			if #self.previewMaterials <= 0 then
				gDropManager:ShowRewardWindow({
					["B\\x8e\\x82\\xbe\\xee\\xb5\\xd2:\\xbb;=\\xb37"] = 2,
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

M._canRecycleChaos = function(self, chaos)
	if chaos.IsLocked then
		return false
	end

	return true
end

M._getDecomposeMaterials = function(self, chaosIds)
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

M.RefreshChaosList = function(self, afterFilter)
	local allChaos = gBattlePetsMgr.petDataDic
	self.chaosList = {}

	for k, v in pairs(allChaos) do
		local chaos = gBattlePetsMgr:GetPetDataById(v.Id)
		local cfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(chaos.LimboChaId)

		if cfg then
			local cost = self._getChaosCost(self, chaos)
			local quality = self._getChaosQuality(self, chaos)
			local canRecycle = self._canRecycleChaos(self, chaos)
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
					self.SelectChaos(self, chaos.Id)
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
		if a.selected == b.selected then
			return a.selected
		end

		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return b.cost <= a.cost
	end)

	self.chaosListData = self.chaosList

	self.bindData.chaosList:SetSimpleList(#self.chaosList)
end

M.RefreshSelectedCount = function(self)
	local selectedCount = #self.selectedChaosIds
	local totalCount = #self.chaosList
	self.bindData.selectCount = string.format("%d", selectedCount)
	self.bindData.totalCount = string.format("%d", totalCount)
end

M.RefreshPreviewMaterials = function(self)
	self.previewMaterials = self:_getDecomposeMaterials(self.selectedChaosIds)
	self.previewMaterialListData = self.previewMaterials

	self.bindData.previewMaterialList:SetSimpleList(#self.previewMaterials)
end

M.OnChaosLockedChange = function(self, eventId, chaosId)
	if table.contains(self.selectedChaosIds, chaosId) then
		self.UnselectChaos(self, chaosId)
		self.RefreshSelectedCount(self)
		self.RefreshPreviewMaterials(self)
	end

	self.RefreshChaosList(self)
end

M.RefreshChaosListAfterFilter = function(self, eventId, filterData)
	if filterData.isFromInfo then
		return
	end

	self.filterData = filterData

	self.CleanupFilteredSelections(self)

	self.selectedChaosIds = {}

	self.RefreshChaosList(self, true)
	self.RefreshSelectedCount(self)
	self.RefreshPreviewMaterials(self)
end

M.CleanupFilteredSelections = function(self)
	if not self.filterData or #self.selectedChaosIds ~= 0 then
		return
	end

	local validSelections = {}
	self.selectedChaosIds = validSelections
end
