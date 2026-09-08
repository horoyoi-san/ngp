-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChaosReshapePanelStore.lua
-- Decompiled from: 01475_ChaosReshapePanelStore.lua_865910799743.luajit

local ChaosMasterLimboChaConfig = LTConfig.ChaosMasterLimboChaConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local ChaosMasterCampConfig = LTConfig.ChaosMasterCampConfig
local ChaosMasterWeaponConfig = LTConfig.ChaosMasterWeaponConfig
local ChaosMasterBodyConfig = LTConfig.ChaosMasterBodyConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local ChaosMasterConfig = LTConfig.ChaosMasterConfig
C_ChaosReshapePanelStore = DefClass("C_ChaosReshapePanelStore", C_ChaosReshapePanelStore, C_StoreGroup)
GroupName2Class.ChaosReshapePanelStore = C_ChaosReshapePanelStore
local M = C_ChaosReshapePanelStore
M.ReshapeType = {
	["+M\\x90\\x9e\\x8cO"] = 3,
	["X-yB"] = 1,
	["Y#pK"] = 2
}
M.ListType = {
	["+M\\x90\\x9e\\x8cO"] = 0,
	S6xV = 1
}

M.ctor = function(self)
	self.leftTabListData = {}
	self.weaponListData = {}
	self.materialConsumeListData = {}
end

M.getLimboChaHashKey = function(bodyId, campId, weaponId)
	return bodyId .. "_" .. campId .. "_" .. weaponId
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)

	self.limboChaHash = {}
	local configCount = ChaosMasterLimboChaConfig.count

	for i = 0, configCount - 1 do
		local cfg = ChaosMasterLimboChaConfig.LoadAt(i)

		if cfg then
			self.limboChaHash[self.getLimboChaHashKey(cfg.Body, cfg.Camp, cfg.Weapon)] = cfg
		end
	end

	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.DefineAllVariables = function(self)
	self.curChaosData = nil
	self.curReshapeType = self.ReshapeType.Camp
	self.selectedItemData = nil
	self.weaponList = {}
	self.equipmentPlan = {}
	self.materialCosts = {}
	self.isShowingCompare = false
end

M.RegisterWidget = function(self)
	self.bindData.leftTabList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderLeftTabItem")
	self.bindData.leftTabList.luaSimpleClick = self.CreateAction(self, "OnClickLeftTab")
	self.bindData.leftTabList.onGetTIndex = self.CreateAction(self, "OnGetLeftTabListTIndex")
	self.bindData.weaponList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderWeaponListItem")
	self.bindData.weaponList.luaSimpleClick = self.CreateAction(self, "OnClickWeaponList")
	self.bindData.weaponList.onGetTIndex = self.CreateAction(self, "OnGetWeaponListTIndex")
	self.bindData.materialConsumeList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMaterialItem")
	self.bindData.materialConsumeList.onGetTIndex = self.CreateAction(self, "OnGetMaterialConsumeListTIndex")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
	self.bindData.closeToolTipBtn.luaClick = self.CreateAction(self, "OnClickCloseToolTipBtn")
	self.bindData.successReshapeCloseBtn.luaClick = self.CreateAction(self, "OnClickReshapeSuccessBtn")

	if self.bindData.backBtn then
		self.bindData.backBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	end

	if self.bindData.showMaterialBtn then
		self.bindData.showMaterialBtn.luaClick = self.CreateAction(self, "OnClickShowMaterialBtn")
	end

	if self.bindData.compareBtn then
		self.bindData.compareBtn.luaClick = self.CreateAction(self, "OnClickCompareBtn")
	end

	if self.bindData.deleteBtn then
		self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnClickDeleteBtn")
	end
end

M.OnClickCloseBtn = function(self, btn, data)
	self.parent.bindData.tabRect.selectedIndex = 0
end

M.OnClickShowMaterialBtn = function(self, btn, data)
	if gClientUtils.IsControllerMode() then
		local materialCostList = {}

		for materialId, count in pairs(self.materialCosts) do
			local materialCfg = ConsumableConfig.GetConfig(materialId)

			if materialCfg then
				table.insert(materialCostList, {
					itemId = materialId
				})
			end
		end

		gCommonItemManager:OnShowItemList(materialCostList)
	end
end

M.OnClickCompareBtn = function(self, btn, data)
	self.isShowingCompare = not self.isShowingCompare

	if self.isShowingCompare then
		self.bindData.showCompareTooltipCtrl = 0

		if self.selectedItemData then
			self.UpdateCompareTooltip(self, self.selectedItemData)
		end
	else
		self.bindData.showCompareTooltipCtrl = 1
	end
end

M.OnClickDeleteBtn = function(self, btn, data)
	if not self.curChaosData then
		return
	end

	slot3 = gDisplayMessageMgr

	slot3:ShowMessage(LTConfig.MessageConfig.ChaosDeleteEquip, function ()
		self:DoDelete()
	end)
end

M.DoDelete = function(self)
	self.equipmentPlan = {
		[self.curReshapeType] = 0
	}

	self.DoReshapeChaos(self)
end

M.OnClickReshapeSuccessBtn = function(self, btn, data)
	self.bindData.showFeedbackCtrl = 1

	self.OnClickCloseBtn(self)
end

M.OnClickCloseToolTipBtn = function(self, btn, data)
end

M.OnClickConfirmBtn = function(self, btn, data)
	self.DoReshapeChaos(self)
end

M.OnRenderLeftTabItem = function(self, btn, index)
	local data = self.leftTabListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosReshapeTabStore"):GetStoreByWidget(btn)

	if store then
		store.icon = data.icon or store.icon
		btn.isSelected = data.selected
	end
end

M.OnClickLeftTab = function(self, btn, index)
	local data = self.leftTabListData[index + 1]

	if not data then
		return
	end

	if self.curReshapeType ~= data.reshapeType then
		return
	end

	self.curReshapeType = data.reshapeType
	self.selectedItemData = nil

	self.RefreshLeftTabList(self)
	self.RefreshItemLists(self)

	self.selectedItemData = self._getCurrentChaosEquipItemData(self)

	self.HideTooltips(self)
	self.RefreshTypeText(self)

	if self.selectedItemData then
		self.ShowTooltips(self, self.selectedItemData)
		self.RefreshMaterialCosts(self)
		self.RefreshCompareBtnState(self)
	end
end

M.OnRenderWeaponListItem = function(self, btn, index)
	local data = self.weaponListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChaosEquipmentItem"):GetStoreByWidget(btn)

	if store then
		btn.isSelected = data.selected

		gBattlePetsMgr:RefreshEquipListItem(store, data)
	end
end

M.OnClickWeaponList = function(self, btn, index)
	local data = self.weaponListData[index + 1]

	if not data then
		return
	end

	self.selectedItemData = data

	if data.equipType and data.equipId then
		self.SetEquipmentPlan(self, data.equipType, data.equipId)
	end

	self.RefreshItemLists(self)
	self.ShowTooltips(self, data)
	self.RefreshMaterialCosts(self)
	self.RefreshEquipmentPlan(self)
	self.RefreshCompareBtnState(self)
end

M.OnRenderMaterialItem = function(self, item, index)
	local data = self.materialConsumeListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup("NewCommonItemStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	store.iconId = data.iconId
	local currentCount = gCommonItemManager:GetPackItemNum(data.materialId)
	local needCount = data.count

	if currentCount >= needCount then
		store.count = string.format("<color=#FF0000>%d</color>/%d", currentCount, needCount)
	else
		store.count = string.format("%d/%d", currentCount, needCount)
	end

	store.quality = data.quality - 1
	store.templateId = data.materialId
	item.luaRenderTooltip = self.CreateAction(self, "OnMaterialItemRenderTooltip")
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

M.OnGetLeftTabListTIndex = function(self, index)
	return 0
end

M.OnGetWeaponListTIndex = function(self, index)
	return 0
end

M.OnGetMaterialConsumeListTIndex = function(self, index)
	return 0
end

M.OnClickEquipmentResetBtn = function(self, data)
	self.ResetEquipmentPlan(self, data.equipType)
	self.OnEquipmentPlanChange(self)
	self.RefreshMaterialCosts(self)
	self.RefreshEquipmentPlan(self)
	self.RefreshItemLists(self)
end

M.OnEquipmentPlanChange = function(self)
	local curCampId = self._getNowPlanEquipId(self, self.ReshapeType.Camp)
	local curBodyId = self._getNowPlanEquipId(self, self.ReshapeType.Body)
	local curWeaponId = self._getNowPlanEquipId(self, self.ReshapeType.Weapon)

	if curCampId ~= 0 or curBodyId ~= 0 or curWeaponId ~= 0 then
		self.parent:OnNoModelCanShow()

		return
	end

	local curCampCfg = ChaosMasterCampConfig.GetConfig(curCampId)
	local curBodyCfg = ChaosMasterBodyConfig.GetConfig(curBodyId)
	local curWeaponCfg = ChaosMasterWeaponConfig.GetConfig(curWeaponId)

	if not curCampCfg or not curBodyCfg or not curWeaponCfg then
		self.parent:OnNoModelCanShow()

		return
	end

	local hashKey = self.getLimboChaHashKey(curBodyId, curCampId, curWeaponId)

	if self.limboChaHash[hashKey] then
		self.parent:RefreshChaosModel(self.limboChaHash[hashKey].Id)
	else
		self.parent:OnNoModelCanShow()
	end
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnShow = function(self, panelId, data)
	self.parent = data and data.parent or nil
	self.curChaosId = data and data.curChaosId or nil
	self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosId)

	if data and data.belong then
		self.curReshapeType = data.belong
	else
		self.curReshapeType = self.ReshapeType.Body
	end

	self.selectedItemData = nil

	self.InitUI(self)
	self.RefreshLeftTabList(self)
	self.RefreshItemLists(self)

	self.selectedItemData = self._getCurrentChaosEquipItemData(self)

	self.RefreshEquipmentPlan(self)
	self.RefreshTypeText(self)

	if self.selectedItemData then
		self.ShowTooltips(self, self.selectedItemData)
		self.RefreshMaterialCosts(self)
		self.RefreshCompareBtnState(self)
	end
end

M.OnPackItemChanged = function(self)
	if self.bindData.showMaterialConsumeCtrl ~= 0 then
		self.RefreshMaterialCosts(self)
		self.RefreshEquipmentPlan(self)
	end
end

M.OnClose = function(self)
	self.curChaosData = nil
	self.selectedItemData = nil
	self.weaponList = {}
	self.equipmentPlan = {}
	self.materialCosts = {}
	self.isShowingCompare = false
end

M.OnActiveDeviceChange = function(self, device)
end

M._sortByQualityAndCost = function(self, list)
	table.sort(list, function (a, b)
		if a.quality == b.quality then
			return b.quality <= a.quality
		end

		return b.cost <= a.cost
	end)
end

M.InitUI = function(self)
	self.bindData.showMaterialConsumeCtrl = 1
	self.bindData.showCompareTooltipCtrl = 1
	self.bindData.showFeedbackCtrl = 1
	self.bindData.ListTypeCtrl = self.ListType.Item
	self.isShowingCompare = false

	self.RefreshCompareBtnState(self)
end

M.RefreshCompareBtnState = function(self)
	if not self.bindData.compareBtn then
		return
	end

	local shouldShow = false

	if self.curChaosData and self.selectedItemData then
		local currentEquipId = 0

		if self.curReshapeType ~= self.ReshapeType.Body then
			currentEquipId = self.curChaosData.Body
		elseif self.curReshapeType ~= self.ReshapeType.Camp then
			currentEquipId = self.curChaosData.Camp
		elseif self.curReshapeType ~= self.ReshapeType.Weapon then
			currentEquipId = self.curChaosData.Weapon
		end

		shouldShow = currentEquipId == 0 and self.selectedItemData.id == currentEquipId
	end

	if not shouldShow and self.isShowingCompare then
		self.isShowingCompare = false
		self.bindData.showCompareTooltipCtrl = 1
	end

	self.bindData.compareBtn.gameObject:SetActive(shouldShow)
end

M.SetEquipmentPlan = function(self, equipType, equipId)
	self.equipmentPlan = {}

	if equipType and equipId then
		self.equipmentPlan[equipType] = equipId

		self.OnEquipmentPlanChange(self)
	end
end

M.ResetEquipmentPlan = function(self, equipType)
	if equipType then
		self.equipmentPlan[equipType] = nil
	end
end

M._getCurrentChaosEquipItemData = function(self)
	if not self.curChaosData then
		return nil
	end

	local currentEquipId = nil

	if self.curReshapeType ~= self.ReshapeType.Body then
		currentEquipId = self.curChaosData.Body
	elseif self.curReshapeType ~= self.ReshapeType.Camp then
		currentEquipId = self.curChaosData.Camp
	elseif self.curReshapeType ~= self.ReshapeType.Weapon then
		currentEquipId = self.curChaosData.Weapon
	else
		return nil
	end

	local foundItem = nil

	for _, itemData in ipairs(self.weaponListData) do
		itemData.selected = itemData.id ~= currentEquipId

		if itemData.selected then
			foundItem = itemData
		end
	end

	if not foundItem and #self.weaponListData <= 0 then
		self.weaponListData[1].selected = true
		foundItem = self.weaponListData[1]
	end

	self.bindData.weaponList:SetSimpleList(#self.weaponListData)

	if foundItem and foundItem.equipType and foundItem.equipId then
		self.SetEquipmentPlan(self, foundItem.equipType, foundItem.equipId)
	end

	return foundItem
end

M.RefreshLeftTabList = function(self)
	local tabData = {
		{
			name = TextScriptTextConfig.GetConfig(89901215).Text,
			reshapeType = self.ReshapeType.Camp,
			selected = self.curReshapeType ~= self.ReshapeType.Camp,
			icon = LTConfig.ChaosMasterConfig.BVBComponentIcon[2]
		},
		{
			name = TextScriptTextConfig.GetConfig(89901201).Text,
			reshapeType = self.ReshapeType.Weapon,
			selected = self.curReshapeType ~= self.ReshapeType.Weapon,
			icon = LTConfig.ChaosMasterConfig.BVBComponentIcon[3]
		}
	}
	self.leftTabListData = tabData

	self.bindData.leftTabList:SetSimpleList(#tabData)
end

M.RefreshItemLists = function(self)
	self.bindData.ListTypeCtrl = self.ListType.Weapon

	if self.curReshapeType ~= self.ReshapeType.Weapon then
		self.RefreshWeaponList(self)
	else
		self.RefreshItemList(self)
	end
end

M.RefreshItemList = function(self)
	local itemList = {}

	if self.curReshapeType ~= self.ReshapeType.Body then
		local bodyConfigCount = ChaosMasterBodyConfig.count

		for i = 0, bodyConfigCount - 1 do
			local cfg = ChaosMasterBodyConfig.LoadAt(i)
			local item = {
				["\\xa8\\xb0\\x99o-\\xfb'"] = true,
				id = cfg.Id,
				name = cfg.BodyName,
				iconId = cfg.IconID or 0,
				quality = cfg.Quality or 3,
				cost = cfg.Cost or 0,
				cfg = cfg,
				selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
				isConflict = self:_checkBodyConflict(cfg.Id),
				isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Body, cfg.Id),
				equipType = self.ReshapeType.Body,
				equipId = cfg.Id,
				chaosData = self.curChaosData,
				isEquipped = cfg.Id ~= self.curChaosData.Body
			}

			table.insert(itemList, item)
		end
	elseif self.curReshapeType ~= self.ReshapeType.Camp then
		local campConfigCount = ChaosMasterCampConfig.count
		local curBodyCfg = ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
		local availableCampIds = {}

		if curBodyCfg and curBodyCfg.CanUseCampId then
			for _, campId in ipairs(curBodyCfg.CanUseCampId) do
				availableCampIds[campId] = true
			end
		end

		for i = 0, campConfigCount - 1 do
			local cfg = ChaosMasterCampConfig.LoadAt(i)

			if availableCampIds[cfg.Id] then
				local item = {
					["\\xa8\\xb0\\x99o-\\xfb'"] = true,
					id = cfg.Id,
					name = cfg.CampName,
					iconId = cfg.IconID or 0,
					quality = cfg.Quality or 3,
					cost = cfg.Cost or 0,
					cfg = cfg,
					selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
					isConflict = self:_checkCampConflict(cfg.Id),
					isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Camp, cfg.Id),
					equipType = self.ReshapeType.Camp,
					equipId = cfg.Id,
					chaosData = self.curChaosData,
					isEquipped = cfg.Id ~= self.curChaosData.Camp
				}

				table.insert(itemList, item)
			end
		end
	end

	self:_sortByQualityAndCost(itemList)

	self.weaponListData = itemList

	self.bindData.weaponList:SetSimpleList(#itemList)
end

M.RefreshWeaponList = function(self)
	self.weaponList = {}
	local curBodyCfg = ChaosMasterBodyConfig.GetConfig(self.curChaosData.Body)
	local availableWeaponIds = {}

	if curBodyCfg and curBodyCfg.CanUseWeaponId then
		for _, weaponId in ipairs(curBodyCfg.CanUseWeaponId) do
			availableWeaponIds[weaponId] = true
		end
	end

	local weaponConfigCount = ChaosMasterWeaponConfig.count

	for i = 0, weaponConfigCount - 1 do
		local cfg = ChaosMasterWeaponConfig.LoadAt(i)

		if availableWeaponIds[cfg.Id] then
			local item = {
				["\\xa8\\xb0\\x99o-\\xfb'"] = true,
				id = cfg.Id,
				name = cfg.WeaponName,
				iconId = cfg.IconID or 0,
				quality = cfg.Quality or 3,
				cost = cfg.Cost or 0,
				cfg = cfg,
				selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
				isConflict = self:_checkWeaponConflict(cfg.Id),
				isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Weapon, cfg.Id),
				equipType = self.ReshapeType.Weapon,
				equipId = cfg.Id,
				chaosData = self.curChaosData,
				isEquipped = cfg.Id ~= self.curChaosData.Weapon
			}

			table.insert(self.weaponList, item)
		end
	end

	self:_sortByQualityAndCost(self.weaponList)

	self.weaponListData = self.weaponList

	self.bindData.weaponList:SetSimpleList(#self.weaponList)
end

M.ShowTooltips = function(self, itemData)
	if self.isShowingCompare then
		self.bindData.showCompareTooltipCtrl = 0

		self.UpdateCompareTooltip(self, itemData)
	else
		self.bindData.showCompareTooltipCtrl = 1
	end

	self.UpdateSelectTooltip(self, itemData, itemData.isEquipped)
end

M.HideTooltips = function(self)
	self.bindData.showCompareTooltipCtrl = 1
	self.isShowingCompare = false
end

M.UpdateSelectTooltip = function(self, itemData, isEquipped)
	local toolTip = self.SubGroup.ChaosEquipToolTip
	local showBtnCtrl = 0

	if not itemData.isUnlocked then
		showBtnCtrl = 2
	elseif itemData.isEquipped then
		showBtnCtrl = 1
	else
		showBtnCtrl = 0
	end

	self.bindData.showBtnCtrl = showBtnCtrl

	toolTip.SetChaosEquipTooltip(toolTip, self.bindData.selectTooltipComp, itemData.equipType, itemData.equipId, self.curChaosData, self.limboChaHash)
end

M.UpdateCompareTooltip = function(self, itemData)
	local toolTip = self.SubGroup.ChaosEquipToolTip
	local nowRealEquipId = self._getNowRealEquipId(self, itemData.equipType)

	toolTip.SetChaosEquipTooltip(toolTip, self.bindData.compareTooltipComp, itemData.equipType, nowRealEquipId, self.curChaosData, self.limboChaHash)
end

M._getNowRealEquipId = function(self, equipType)
	if equipType ~= self.ReshapeType.Body then
		return self.curChaosData.Body
	elseif equipType ~= self.ReshapeType.Camp then
		return self.curChaosData.Camp
	elseif equipType ~= self.ReshapeType.Weapon then
		return self.curChaosData.Weapon
	end
end

M._getNowPlanEquipId = function(self, equipType)
	if self.equipmentPlan[equipType] == nil then
		return self.equipmentPlan[equipType]
	end

	if equipType ~= self.ReshapeType.Body then
		return self.curChaosData.Body
	elseif equipType ~= self.ReshapeType.Camp then
		return self.curChaosData.Camp
	elseif equipType ~= self.ReshapeType.Weapon then
		return self.curChaosData.Weapon
	end

	return nil
end

M.RefreshMaterialCosts = function(self)
	local needMaterialConsume = false
	local materialCosts = {}

	for _, type in pairs(self.ReshapeType) do
		local equipId = self._getNowPlanEquipId(self, type)

		if equipId == self._getNowRealEquipId(self, type) then
			needMaterialConsume = true

			if equipId and equipId == 0 then
				local cfg = nil

				if type ~= self.ReshapeType.Body then
					cfg = ChaosMasterBodyConfig.GetConfig(equipId)
				elseif type ~= self.ReshapeType.Camp then
					cfg = ChaosMasterCampConfig.GetConfig(equipId)
				elseif type ~= self.ReshapeType.Weapon then
					cfg = ChaosMasterWeaponConfig.GetConfig(equipId)
				end

				if cfg and cfg.SwitchMaterials then
					local materials = cfg.SwitchMaterials

					for _, material in ipairs(materials) do
						materialCosts[material.Id] = material.Num + (materialCosts[material.Id] or 0)
					end
				end
			end
		end
	end

	if not needMaterialConsume then
		self.bindData.showMaterialConsumeCtrl = 1

		return
	end

	self.materialCosts = materialCosts
	local materialCostList = {}

	for materialId, count in pairs(self.materialCosts) do
		local materialCfg = ConsumableConfig.GetConfig(materialId)

		if materialCfg then
			table.insert(materialCostList, {
				iconId = materialCfg.SItemIconId or 0,
				count = count or 1,
				quality = materialCfg.Quality or 1,
				materialId = materialId,
				itemId = materialId
			})
		end
	end

	self.materialConsumeListData = materialCostList

	self.bindData.materialConsumeList:SetSimpleList(#materialCostList)

	self.bindData.showMaterialConsumeCtrl = 0
end

M.RefreshEquipmentPlan = function(self)
	local equipmentPlanListData = {}
	local hasConflict = false
	local hasLocked = false
	local hasChange = false
	local bodyId = self._getNowPlanEquipId(self, self.ReshapeType.Body)

	if bodyId == self._getNowRealEquipId(self, self.ReshapeType.Body) then
		hasChange = true
	end

	local cfg = ChaosMasterBodyConfig.GetConfig(bodyId)

	if cfg then
		local data = {
			["\\xa8\\xb0\\x99o-\\xfb'"] = true,
			id = cfg.Id,
			iconId = cfg.IconID or 0,
			quality = cfg.Quality or 3,
			cfg = cfg,
			selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
			isConflict = self:_checkBodyConflict(cfg.Id),
			isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Body, cfg.Id),
			equipType = self.ReshapeType.Body,
			equipId = cfg.Id,
			chaosData = self.curChaosData,
			isEquipped = cfg.Id ~= self.curChaosData.Body
		}

		if data.isConflict then
			hasConflict = true
		end

		if not data.isUnlocked then
			hasLocked = true
		end

		table.insert(equipmentPlanListData, data)
	end

	local campId = self._getNowPlanEquipId(self, self.ReshapeType.Camp)

	if campId == self._getNowRealEquipId(self, self.ReshapeType.Camp) then
		hasChange = true
	end

	cfg = ChaosMasterCampConfig.GetConfig(campId)

	if cfg then
		local data = {
			["\\xa8\\xb0\\x99o-\\xfb'"] = true,
			id = cfg.Id,
			iconId = cfg.IconID or 0,
			quality = cfg.Quality or 3,
			cfg = cfg,
			selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
			isConflict = self:_checkCampConflict(cfg.Id),
			isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Camp, cfg.Id),
			equipType = self.ReshapeType.Camp,
			equipId = cfg.Id,
			chaosData = self.curChaosData,
			isEquipped = cfg.Id ~= self.curChaosData.Camp
		}

		if data.isConflict then
			hasConflict = true
		end

		if not data.isUnlocked then
			hasLocked = true
		end

		table.insert(equipmentPlanListData, data)
	end

	local weaponId = self._getNowPlanEquipId(self, self.ReshapeType.Weapon)

	if weaponId == self._getNowRealEquipId(self, self.ReshapeType.Weapon) then
		hasChange = true
	end

	cfg = ChaosMasterWeaponConfig.GetConfig(weaponId)

	if cfg then
		local data = {
			["\\xa8\\xb0\\x99o-\\xfb'"] = true,
			id = cfg.Id,
			iconId = cfg.IconID or 0,
			quality = cfg.Quality or 3,
			cfg = cfg,
			selected = self.selectedItemData and self.selectedItemData.id ~= cfg.Id,
			isConflict = self:_checkWeaponConflict(cfg.Id),
			isUnlocked = gBattlePetsMgr:CheckEquipPartUnlocked(self.ReshapeType.Weapon, cfg.Id),
			equipType = self.ReshapeType.Weapon,
			equipId = cfg.Id,
			chaosData = self.curChaosData,
			isEquipped = cfg.Id ~= self.curChaosData.Weapon
		}

		if data.isConflict then
			hasConflict = true
		end

		if not data.isUnlocked then
			hasLocked = true
		end

		table.insert(equipmentPlanListData, data)
	end

	local hasEnoughMaterials = self._checkAllMaterialsEnough(self)

	if hasConflict or hasLocked or not hasEnoughMaterials or not hasChange then
		self.bindData.confirmBtn.interactable = false
	else
		self.bindData.confirmBtn.interactable = true
	end
end

M.RefreshTypeText = function(self)
	local typeNames = {
		[self.ReshapeType.Body] = TextScriptTextConfig.GetConfig(89901214).Text,
		[self.ReshapeType.Camp] = TextScriptTextConfig.GetConfig(89901215).Text,
		[self.ReshapeType.Weapon] = TextScriptTextConfig.GetConfig(89901201).Text
	}
	self.bindData.typeText = TextScriptTextConfig.GetConfig(89901212).Text .. (typeNames[self.curReshapeType] or "")
end

M.DoReshapeChaos = function(self)
	if not self.curChaosData then
		return
	end

	local curChaosId = self.curChaosData.Id
	local curBodyId = self:_getNowPlanEquipId(self.ReshapeType.Body)
	local curCampId = self:_getNowPlanEquipId(self.ReshapeType.Camp)
	local curWeaponId = self:_getNowPlanEquipId(self.ReshapeType.Weapon)
	slot5 = gClientToGameDelegate

	slot5:AskPokemonRebuild(curChaosId, curBodyId, curCampId, curWeaponId).Callback = function (err, data)
		if err ~= LTConfig.MessageConfig.Ok then
			self.bindData.showFeedbackCtrl = 0
			self.curChaosData = gBattlePetsMgr:GetPetDataById(self.curChaosData.Id)
			self.selectedItemData = nil

			self:RefreshItemLists()
			self:RefreshEquipmentPlan()
			self:HideTooltips()
		else
			gDisplayMessageMgr:ShowMessage(err)
		end
	end
end

M._checkMaterialEnough = function(self, materialId, needCount)
	local currentCount = gCommonItemManager:GetPackItemNum(materialId)

	return needCount > currentCount
end

M._checkAllMaterialsEnough = function(self)
	for materialId, needCount in pairs(self.materialCosts) do
		if not self._checkMaterialEnough(self, materialId, needCount) then
			return false
		end
	end

	return true
end

M._checkWeaponConflict = function(self, weaponId)
	local curCampId = self._getNowPlanEquipId(self, self.ReshapeType.Camp)
	local curBodyId = self._getNowPlanEquipId(self, self.ReshapeType.Body)

	if curCampId ~= 0 or curBodyId ~= 0 then
		return false
	end

	local hashKey = self.getLimboChaHashKey(curBodyId, curCampId, weaponId)

	if self.limboChaHash[hashKey] then
		return false
	end

	return true
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M._checkBodyConflict = function(self, bodyId)
	local curCampId = self._getNowPlanEquipId(self, self.ReshapeType.Camp)
	local curWeaponId = self._getNowPlanEquipId(self, self.ReshapeType.Weapon)

	if curCampId ~= 0 or curWeaponId ~= 0 then
		return false
	end

	local hashKey = self.getLimboChaHashKey(bodyId, curCampId, curWeaponId)

	if self.limboChaHash[hashKey] then
		return false
	end

	return true
end

M._checkCampConflict = function(self, campId)
	local curBodyId = self._getNowPlanEquipId(self, self.ReshapeType.Body)
	local curWeaponId = self._getNowPlanEquipId(self, self.ReshapeType.Weapon)

	if curBodyId ~= 0 or curWeaponId ~= 0 then
		return false
	end

	local hashKey = self.getLimboChaHashKey(curBodyId, campId, curWeaponId)

	if self.limboChaHash[hashKey] then
		return false
	end

	return true
end
