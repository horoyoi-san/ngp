-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponChipPanelStore.lua
-- Decompiled from: 01154_WeaponChipPanelStore.lua_324266798810.luajit

local CategoryType = LTConfig.SceneitemConfig.CategoryType
local SceneitemConfig = LTConfig.SceneitemConfig
local DecorationTabConfig = LTConfig.DecorationTabConfig
C_WeaponChipPanelStore = DefClass("C_WeaponChipPanelStore", C_WeaponChipPanelStore, C_StoreGroup)
GroupName2Class.WeaponChipPanelStore = C_WeaponChipPanelStore
local M = C_WeaponChipPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.BTN_MODE_LOGIC = {
		["8g\\xa4\\xac\\xafd"] = 2,
		["/a\\xbf\\xa9\\xafd"] = 1,
		["T\rS~"] = 0
	}
	self.chipListForRender = {}
	self.chipListForRenderTemp = {}
	self.chipList = {}
	self.tabList = {}
	self.validTabIdMap = {}
	self.selectedTabId = nil

	self.sortFunc = function(a, b)
		if a.decoCfg.Quality == b.decoCfg.Quality then
			if self.sortIncrease then
				return a.decoCfg.Quality <= b.decoCfg.Quality
			else
				return b.decoCfg.Quality <= a.decoCfg.Quality
			end
		end

		if self.sortIncrease then
			return a.TemplateId <= b.TemplateId
		else
			return b.TemplateId <= a.TemplateId
		end
	end

	self.defaultSlotIndex = -1
	self.selectedSlotIndex = -1
	self.selectedChipIndex = -1
	self.isTarkov = false
	self.tarkovWeaponInstanceId = nil
	self.tarkovGamePlayTypeId = nil
	self.weaponBag = nil
	self.pendingWeaponMove = nil
	self.pendingTarkovMove = nil
	self.chipSlotCount = 4
	self.universeString = nil
	self.tipSource = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.ShowToolTipCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.stateCtrlEnum = {
		["\\xbcmb"] = 1,
		["j\\xbc\\xa7\\xaa\\xb8"] = 2,
		["2G\\x83\\x83\\x82M"] = 0
	}
	self.EmptyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.ActiveTagCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.qualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.QualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.ShowToolTipCtrlEnum = nil
	self.stateCtrlEnum = nil
	self.EmptyCtrlEnum = nil
	self.ActiveTagCtrlEnum = nil
	self.qualityCtrlEnum = nil
	self.QualityCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
	self.chipSlotStores = {}

	for i = 1, self.chipSlotCount do
		local curChipSlot = self.bindData["chipSlot" .. i]
		local store = gStoreManager:GetStoreGroup(curChipSlot.Store):GetStoreByWidget(curChipSlot)
		self.chipSlotStores[i] = store

		if store and store.btnChip then
			store.btnChip.luaClick = self.CreateActionWithArgs(self, "OnChipSlotClick", i)
		end
	end
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self:RegisterMessageEvents(self.msgEvents)
	self.SubGroup.WeaponChipTooltipStore:RegisterButtonHandler(self:CreateAction("OnTipBtnClick"), self:CreateAction("OnTipRBtnClick"), self:CreateAction("OnTipMoveBtnClick"))
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)

	self.chipSlotStores = nil
	self.pendingWeaponMove = nil
	self.pendingTarkovMove = nil
	self.isTarkov = false
	self.tarkovGamePlayTypeId = nil
end

M.UpdateTarkovWeaponContext = function(self)
	local weaponData, gunBagConfigId, gunCellX, gunCellY = gExtractionShooterManager:GetTarkovWeaponBagByInstanceId(self.tarkovWeaponInstanceId)

	if not weaponData then
		return false
	end

	local bagMeta = gExtractionShooterManager:GetTarkovBagMeta(gunBagConfigId)

	if not bagMeta then
		print_error("[WeaponChipPanel] tarkov weapon bag config not found, bagConfigId=", gunBagConfigId)

		return false
	end

	self.weapon = weaponData
	self.tarkovGamePlayTypeId = bagMeta.gamePlayTypeId
	self.weaponBag = {
		gunBagConfigId = gunBagConfigId,
		gunCellX = gunCellX,
		gunCellY = gunCellY
	}

	return true
end

M.ResolveTarkovRemoveContext = function(self, instanceId, decorationId)
	local weaponData, gunBagConfigId, gunCellX, gunCellY = gExtractionShooterManager:GetTarkovWeaponBagByInstanceId(instanceId)

	if not weaponData then
		print_error("[WeaponChipPanel] tarkov weapon not found before remove, InstanceId=", instanceId)

		return nil
	end

	local bagMeta = gExtractionShooterManager:GetTarkovBagMeta(gunBagConfigId)
	local consumableCfg = gCommonItemManager:GetDecorationConsumableCfg(decorationId)
	local extractionItemCfg = consumableCfg and gExtractionShooterUtils.GetItemCfgByConsumableId(consumableCfg.Id) or nil

	if not bagMeta or not consumableCfg or not extractionItemCfg then
		print_error("[WeaponChipPanel] failed to resolve tarkov remove context, InstanceId=", instanceId)

		return nil
	end

	local returnBagConfigId = gCommonItemManager:GetFirstAvailableTarkovStashBag(bagMeta.gamePlayTypeId, consumableCfg.Id, extractionItemCfg)

	if not returnBagConfigId then
		return nil
	end

	return {
		weaponData = weaponData,
		gunBagConfigId = gunBagConfigId,
		gunCellX = gunCellX,
		gunCellY = gunCellY,
		gamePlayTypeId = bagMeta.gamePlayTypeId,
		returnBagConfigId = returnBagConfigId
	}
end

M.OnShow = function(self, panelId, data)
	self.isTarkov = data and data.isTarkov or false
	self.weapon = nil
	self.tarkovWeaponInstanceId = nil
	self.tarkovGamePlayTypeId = nil
	self.weaponBag = nil
	self.pendingWeaponMove = nil
	self.pendingTarkovMove = nil

	if data then
		if self.isTarkov then
			self.tarkovWeaponInstanceId = data.id

			if not self.UpdateTarkovWeaponContext(self) then
				print_error("[WeaponChipPanel] tarkov weapon not found, InstanceId=", data.id)
			end
		else
			self.weapon = gWeaponManager:GetWeaponByInstanceId(data.id)
		end

		self.defaultSlotIndex = data.SlotIndex or 0

		print_debug("[WeaponChipPanel] OnShow", "weapon=", self.weapon, "defaultSlotIndex=", self.defaultSlotIndex)
	else
		local weapons = gWeaponManager:GetCurrentWeapons()

		for i = 1, weapons.Length do
			local detail = weapons[i]

			if detail and gPlayerManager.infoSpirit.bindData.currentWeapon and detail.InstanceId ~= gPlayerManager.infoSpirit.bindData.currentWeapon.InstanceId then
				self.weapon = detail

				break
			end
		end

		self.defaultSlotIndex = 0
	end

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	self:InitAttrInfo()
	self:InitChipSlotInfo()
	self:InitTabInfo()
	self:InitChipListInfo()
	self:InitFilterAndSorter()
	self:RebuildAttrView()
	self:ReBuildChipSlotView()
	self:ReBuildTabView()
	self:RefreshChipList()
end

M.OnClose = function(self)
	self.pendingWeaponMove = nil
	self.pendingTarkovMove = nil
	self.isTarkov = false
	self.tarkovGamePlayTypeId = nil
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.PACK_ITEM_CHANGED] = self.CreateAction(self, "OnPackItemChanged"),
		[gEventConstants.WEAPON_DECORATION_RETURN_ITEM] = self.CreateAction(self, "OnWeaponDecorationReturnItem"),
		[gEventConstants.CURRENT_WEAPON_DETAIL_CHANGED] = self.CreateAction(self, "OnCurrentWeaponDetailChanged"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE] = self.CreateAction(self, "OnTarkovBagChanged"),
		[gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_REMOVE] = self.CreateAction(self, "OnTarkovBagChanged")
	}
end

M.RegisterWidget = function(self)
	self.bindData.btnBack.luaClick = self.CreateAction(self, "OnBtnBackClick")
	self.bindData.removeTooltipBtn.luaClick = self.CreateAction(self, "OnRemoveTooltipBtnClick")
	self.bindData.chipList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderChipListItem")
	self.bindData.chipList.luaSelectedChanged = self.CreateAction(self, "OnChipListSelectChange")
end

M.OnTipBtnClick = function(self)
	local data = self.chipListForRender[self.selectedChipIndex]

	print_debug("[WeaponChipPanel] OnTipBtnClick", "selectedChipIndex=", self.selectedChipIndex, "selectedSlotIndex=", self.selectedSlotIndex, "#chipSlots=", #self.chipSlots, "data=", data)

	if data and self.selectedSlotIndex <= 0 and self.selectedSlotIndex < #self.chipSlots then
		local slotIndex = self.selectedSlotIndex
		local slotInfo = self.chipSlots[slotIndex]

		if slotInfo and slotInfo.valid then
			if self.isTarkov then
				self.EquipChipToSlot(self, data, slotIndex)

				return
			end

			if self.IsChipTabFull(self) then
				gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.ArmoryIsFull)

				return
			end

			slot4 = gClientToGameSceneDelegate

			slot4:AskRemoveWeaponDecoration(self.weaponInfo.InstanceId, slotIndex - 1).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					slotInfo.valid = false

					print_debug("[WCP-OnTipBtnClick] removed chip from slot:", slotIndex - 1)
					self:RenderChipSlot(slotIndex)
					self:RefreshLeftChipList()
					self:EquipChipToSlot(data, slotIndex)
				else
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end
		else
			self.EquipChipToSlot(self, data, slotIndex)
		end
	end
end

M.EquipChipToSlot = function(self, data, slotIndex)
	if not data or not data.uniqueId and (not self.isTarkov or not data.cell) or slotIndex > 0 or slotIndex <= #self.chipSlots then
		return
	end

	if self.isTarkov then
		print_debug("[WeaponChipPanel] EquipChipToSlot", "selectedChipIndex=", self.selectedChipIndex, "selectedSlotIndex=", self.selectedSlotIndex, "#chipSlots=", #self.chipSlots, "data=", data)

		if not self.weaponBag or not data.cell then
			return
		end

		slot3 = gClientToGameSceneDelegate

		slot3:AskSocketExtractionShooterWeaponDecoration(self.weaponBag.gunBagConfigId, self.weaponBag.gunCellX, self.weaponBag.gunCellY, slotIndex - 1, data.cell.bagConfigId, data.cell.cellX, data.cell.cellY).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				self:RefreshTarkovPanelData()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end

		return
	end

	slot3 = gClientToGameSceneDelegate

	slot3:AskSocketWeaponDecoration(self.weaponInfo.InstanceId, slotIndex - 1, data.uniqueId).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			local slotInfo = self.chipSlots[slotIndex]
			slotInfo.valid = true
			slotInfo.info = {
				DecorationId = data.decoCfg.Id
			}

			print_debug("[WCP-EquipChipToSlot] equipped decoId:", data.decoCfg.Id, "to slot:", slotIndex - 1)
			self:RenderChipSlot(slotIndex)
			self:RefreshLeftChipList()
			self:RemoveChipEntriesByUniqueIds(data.uniqueId)
			self:ReBuildChipListView()

			if self.gamepadMode and #self.chipListForRender <= 0 then
				self.bindData.chipList:SelectItem(0, true)
			else
				self.selectedChipIndex = -1

				self:RefreshChipTooltip()
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.RemoveChipEntriesByUniqueIds = function(self, ...)
	local uniqueIdSet = {}

	for index = 1, select("#", ...) do
		local uniqueId = select(index, ...)

		if uniqueId then
			uniqueIdSet[uniqueId] = true
		end
	end

	if table.is_empty(uniqueIdSet) then
		return
	end

	for _, list in ipairs({
		self.chipListForRender,
		self.chipList
	}) do
		for index = #list, 1, -1 do
			if uniqueIdSet[list[index].uniqueId] then
				table.remove(list, index)
			end
		end
	end
end

M.OnBtnBackClick = function(self)
	gPanelManager:Close(gPanelId.WEAPON_CHIP_PANEL)
end

M.OnRemoveTooltipBtnClick = function(self)
	self.bindData.ShowToolTipCtrl = self.CONTROL.FALSE

	self.bindData.chipList:DeselectAll()
end

M.OnChipSlotClick = function(self, index)
	print_debug("[WeaponChipPanel] OnChipSlotClick", "index=", index, "#chipSlots=", #self.chipSlots)

	if index <= #self.chipSlots then
		return
	end

	self.SelectChipSlot(self, index)
end

M.RenderChipSlot = function(self, index)
	local store = self.chipSlotStores and self.chipSlotStores[index]

	if not store then
		return
	end

	if index <= #self.chipSlots then
		store.haveCtrl = self.CONTROL.TRUE
		store.emptyCtrl = self.CONTROL.FALSE
		store.iconId = 0
		store.qualityCtrl = 0

		return
	end

	store.haveCtrl = self.CONTROL.FALSE
	local data = self.chipSlots[index]

	if data and data.valid then
		store.emptyCtrl = self.CONTROL.FALSE
		local cfg = LTConfig.DecorationConfig.GetConfig(data.info.DecorationId)
		store.iconId = cfg and cfg.Icon or 0
		store.qualityCtrl = cfg and cfg.Quality or 0
		store.btnDelete.luaClick = self:CreateActionWithArgs("OnDeleteChipSlot", index)
	else
		store.emptyCtrl = self.CONTROL.TRUE
		store.iconId = 0
		store.qualityCtrl = 0
		store.btnDelete.luaClick = nil
	end
end

M.OnDeleteChipSlot = function(self, index)
	local slotInfo = self.chipSlots[index]
	local decorationId = slotInfo and slotInfo.valid and slotInfo.info and slotInfo.info.DecorationId

	if not decorationId then
		return
	end

	if not self.isTarkov and self.IsChipTabFull(self) then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.ArmoryIsFull)

		return
	end

	print_debug("[WCP-OnDeleteChipSlot] removing chip from slot:", index - 1, "weapon:", self.weaponInfo and self.weaponInfo.InstanceId)

	if self.isTarkov then
		local removeContext = self.ResolveTarkovRemoveContext(self, self.tarkovWeaponInstanceId, decorationId)

		if not removeContext then
			gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.ArmoryIsFull)

			return
		end

		self.weapon = removeContext.weaponData
		self.tarkovGamePlayTypeId = removeContext.gamePlayTypeId
		self.weaponBag = {
			gunBagConfigId = removeContext.gunBagConfigId,
			gunCellX = removeContext.gunCellX,
			gunCellY = removeContext.gunCellY
		}
		slot5 = gClientToGameSceneDelegate

		slot5:AskRemoveExtractionShooterWeaponDecoration(removeContext.gunBagConfigId, removeContext.gunCellX, removeContext.gunCellY, index - 1, removeContext.returnBagConfigId).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				self:RefreshTarkovPanelData()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end

		return
	end

	slot4 = gClientToGameSceneDelegate

	slot4:AskRemoveWeaponDecoration(self.weaponInfo.InstanceId, index - 1).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self.chipSlots[index].valid = false

			print_debug("[WCP-OnDeleteChipSlot] OK, chipSlots[", index, "].valid = false")
			self:RenderChipSlot(index)
			self:SelectChipSlot(index)
			self:RefreshChipTooltip()
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.IsChipTabFull = function(self)
	local chipList = gCommonItemManager:GetPackItemListByTab(LTConfig.ConsumableTabConfig.Chip)
	local capacity = LTConfig.ConsumableTabConfig.GetConfig(LTConfig.ConsumableTabConfig.Chip).Capacity

	return capacity > #chipList
end

M.OnSimpleRenderChipListItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)
	local data = self.chipListForRender[index + 1]

	if store and data then
		store.iconId = data.decoCfg.Icon
		store.QualityCtrl = data.decoCfg.Quality

		if not string.is_null_or_empty(data.decoCfg.GuideId) and btn.guide then
			btn.guide.guideID = data.decoCfg.GuideId
		end
	end
end

M.OnChipListSelectChange = function(self)
	self.selectedChipIndex = self.bindData.chipList.selectedIndex + 1

	self.RefreshChipTooltip(self)
end

M.SelectChipSlot = function(self, index)
	if index <= 1 or self.chipSlotCount >= index then
		return
	end

	self.selectedSlotIndex = index

	for i = 1, self.chipSlotCount do
		local s = self.chipSlotStores[i]

		if s and s.bindWidget then
			s.bindWidget:SetSelected(i ~= index)
		end
	end

	self.RefreshLeftChipList(self)
end

M.RefreshLeftChipList = function(self)
	local tooltipStore = self.SubGroup.WeaponArmoryTooltipStore_Cur

	if tooltipStore and self.weapon then
		tooltipStore:SetChipListHighlightIndex(self.selectedSlotIndex)
		tooltipStore:SetBaseWeapon(gWeaponManager:GetWeaponByInstanceId(self.weapon.InstanceId) or self.weapon)
	end
end

M.OnCurrentWeaponDetailChanged = function(self, eventId, data)
	if self.isTarkov then
		return
	end

	if not data or not data.weapon or not self.weapon then
		return
	end

	if data.weaponId == self.weapon.InstanceId then
		return
	end

	self.weapon = data.weapon

	self.RefreshLeftChipList(self)
end

M.ShowChipTooltip = function(self, decoCfg)
	self.curDecoCfg = decoCfg

	if not decoCfg then
		self.bindData.ShowToolTipCtrl = self.CONTROL.FALSE

		return
	end

	self.bindData.ShowToolTipCtrl = self.CONTROL.TRUE
	local tags = {}

	if decoCfg.ValidUniverse == 0 then
		table.insert(tags, {
			TagType = decoCfg.ValidUniverse
		})
	end

	local equippedWeapon, equippedCfg, duraInfo = self.GetWeaponEquippedWithChip(self, decoCfg.Id)
	local btnMode, showEquippedCfg, showDura, showBroken = nil

	if not equippedWeapon then
		btnMode = 0
	elseif self.weapon and equippedWeapon.InstanceId ~= self.weapon.InstanceId then
		btnMode = 1
	else
		btnMode = 2
		showEquippedCfg = equippedCfg
		showDura = duraInfo and duraInfo.DurabilityText1 or ""
		showBroken = duraInfo and duraInfo.BrokenState or 0
	end

	print_debug("[WCP-ShowTooltip] decoId:", decoCfg.Id, "equippedWeapon:", equippedWeapon and equippedWeapon.InstanceId or "nil", "btnMode:", btnMode)

	local slotStates = {}

	for k = 1, #self.chipSlots do
		table.insert(slotStates, string.format("slot%d:valid=%s,decoId=%s", k - 1, tostring(self.chipSlots[k].valid), tostring(self.chipSlots[k].info and self.chipSlots[k].info.DecorationId)))
	end

	print_debug("[WCP-ShowTooltip] chipSlots state:", table.concat(slotStates, " | "))
	self.SubGroup.WeaponChipTooltipStore:SetChipData({
		name = decoCfg.Name,
		quality = decoCfg.Quality,
		desc = decoCfg.Effect,
		stockCtrl = btnMode ~= 2 and 0 or 1,
		tags = tags,
		btnMode = btnMode,
		equippedCfg = showEquippedCfg,
		equippedWeaponData = btnMode ~= 2 and equippedWeapon or nil,
		durability = showDura or "",
		brokenCtrl = showBroken or 0
	})
end

M.RefreshChipTooltip = function(self)
	local data = self.chipListForRender[self.selectedChipIndex]

	print_debug("[WCP-RefreshTooltip] selectedChipIndex:", self.selectedChipIndex, "hasData:", data == nil, "decoId:", data and data.decoCfg and data.decoCfg.Id)

	if data then
		self.tipSource = "list"

		self.ShowChipTooltip(self, data.decoCfg)
	else
		self.bindData.ShowToolTipCtrl = self.CONTROL.FALSE
	end
end

M.OnTipRBtnClick = function(self)
	if not self.curDecoCfg then
		return
	end

	local equippedWeapon, equippedCfg, duraInfo, srcSlot, uniqueId = self.GetWeaponEquippedWithChip(self, self.curDecoCfg.Id)

	if equippedWeapon and self.weapon and equippedWeapon.InstanceId ~= self.weapon.InstanceId then
		self.OnDeleteChipSlot(self, srcSlot + 1)
	end
end

M.OnTipMoveBtnClick = function(self)
	local data = self.chipListForRender[self.selectedChipIndex]

	if not data then
		return
	end

	local equippedWeapon, equippedCfg, duraInfo, srcSlot, uniqueId = self.GetWeaponEquippedWithChip(self, data.decoCfg.Id)

	if not equippedWeapon then
		return
	end

	if self.weapon and equippedWeapon.InstanceId ~= self.weapon.InstanceId then
		return
	end

	if not self.isTarkov and not uniqueId then
		return
	end

	local targetSlotIndex = self.selectedSlotIndex

	if targetSlotIndex > 0 or targetSlotIndex <= #self.chipSlots then
		return
	end

	if not self.isTarkov and self.IsChipTabFull(self) then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.ArmoryIsFull)

		return
	end

	local weaponName = equippedCfg and equippedCfg.Name or ""

	gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.WeaponChipMoveConfirm, function ()
		self:DoTipMoveChip(data, equippedWeapon, srcSlot, targetSlotIndex)
	end, nil, weaponName)
end

M.DoTipMoveChip = function(self, data, equippedWeapon, srcSlot, targetSlotIndex)
	if self.isTarkov then
		self.DoTarkovTipMoveChip(self, data, equippedWeapon, srcSlot, targetSlotIndex)

		return
	end

	if self.pendingWeaponMove then
		return
	end

	print_debug("[WCP-OnTipMoveBtn] moving chip decoId:", data.decoCfg.Id, "from slot:", srcSlot, "to current weapon")

	local pending = {
		["\\x8d1-0n\\x98s\\xc94\\x85\\xb2"] = false,
		["\\xec\\'\\xc4.\\xa6B\\x92S\\xbe\\xa2"] = false,
		data = data,
		targetSlotIndex = targetSlotIndex,
		expectedDecorationId = data.decoCfg.Id,
		deferredPackAddList = {}
	}
	self.pendingWeaponMove = pending
	slot6 = gClientToGameSceneDelegate

	slot6:AskRemoveWeaponDecoration(equippedWeapon.InstanceId, srcSlot).Callback = function (err)
		if self.pendingWeaponMove == pending then
			return
		end

		if err ~= LTConfig.MessageConfig.Ok then
			pending.removeRpcOk = true

			self:TryContinueWeaponMove()
		else
			self.pendingWeaponMove = nil

			self:ApplyPackItemAddList(pending.deferredPackAddList)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.TryContinueWeaponMove = function(self)
	local pending = self.pendingWeaponMove

	if not pending or not pending.removeRpcOk or not pending.returnedItemUid or pending.socketRpcSent then
		return
	end

	pending.socketRpcSent = true
	local targetSlotIndex = pending.targetSlotIndex

	if targetSlotIndex > 0 or targetSlotIndex >= #self.chipSlots or not self.weaponInfo then
		self.RemoveChipEntriesByUniqueIds(self, pending.data.uniqueId)

		self.pendingWeaponMove = nil

		self.ApplyPackItemAddList(self, pending.deferredPackAddList, nil, false)
		self.SortChipRenderList(self)
		self.ReBuildChipListView(self)

		return
	end

	local data = pending.data
	local returnedItemUid = pending.returnedItemUid
	slot5 = gClientToGameSceneDelegate

	slot5:AskSocketWeaponDecoration(self.weaponInfo.InstanceId, targetSlotIndex - 1, returnedItemUid).Callback = function (err)
		if self.pendingWeaponMove == pending then
			return
		end

		if err ~= LTConfig.MessageConfig.Ok then
			local slotInfo = self.chipSlots[targetSlotIndex]
			slotInfo.valid = true
			slotInfo.info = {
				DecorationId = data.decoCfg.Id
			}

			print_debug("[WCP-OnTipMoveBtn] socketed to slot:", targetSlotIndex - 1)
			self:RenderChipSlot(targetSlotIndex)
			self:RefreshLeftChipList()
			self:RemoveChipEntriesByUniqueIds(data.uniqueId, returnedItemUid)

			self.pendingWeaponMove = nil

			self:ApplyPackItemAddList(pending.deferredPackAddList, returnedItemUid, false)
			self:SortChipRenderList()
			self:ReBuildChipListView()

			self.selectedChipIndex = -1

			self:RefreshChipTooltip()
		else
			self:RemoveChipEntriesByUniqueIds(data.uniqueId)

			self.pendingWeaponMove = nil

			self:ApplyPackItemAddList(pending.deferredPackAddList, nil, false)
			self:SortChipRenderList()
			self:ReBuildChipListView()
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.DoTarkovTipMoveChip = function(self, data, equippedWeapon, srcSlot, targetSlotIndex)
	if self.pendingTarkovMove or not self.weaponBag or not equippedWeapon then
		return
	end

	local consumableCfg = gCommonItemManager:GetDecorationConsumableCfg(data.decoCfg.Id)

	if not consumableCfg then
		print_error("[WeaponChipPanel] decoration consumable config not found, DecorationId=", data.decoCfg.Id)

		return
	end

	local removeContext = self.ResolveTarkovRemoveContext(self, equippedWeapon.InstanceId, data.decoCfg.Id)

	if not removeContext then
		gDisplayMessageMgr:DisplayServerMessageId(LTConfig.MessageConfig.ArmoryIsFull)

		return
	end

	local pending = {
		["\\x8d1-0n\\x98s\\xc94\\x85\\xb2"] = false,
		targetSlotIndex = targetSlotIndex,
		expectedConsumableId = consumableCfg.Id,
		returnBagConfigId = removeContext.returnBagConfigId
	}
	self.pendingTarkovMove = pending
	slot8 = gClientToGameSceneDelegate

	slot8:AskRemoveExtractionShooterWeaponDecoration(removeContext.gunBagConfigId, removeContext.gunCellX, removeContext.gunCellY, srcSlot, pending.returnBagConfigId).Callback = function (err)
		if self.pendingTarkovMove == pending then
			return
		end

		if err ~= LTConfig.MessageConfig.Ok then
			pending.removeRpcOk = true

			self:TryContinueTarkovMove()
		else
			self.pendingTarkovMove = nil

			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.TryContinueTarkovMove = function(self)
	local pending = self.pendingTarkovMove

	if not pending or not pending.removeRpcOk or not pending.returnedItemInfo then
		return
	end

	self.pendingTarkovMove = nil

	if not self.UpdateTarkovWeaponContext(self) then
		print_error("[WeaponChipPanel] current tarkov weapon not found before socket")
		self.RefreshTarkovPanelData(self)

		return
	end

	local itemInfo = pending.returnedItemInfo
	slot3 = gClientToGameSceneDelegate

	slot3:AskSocketExtractionShooterWeaponDecoration(self.weaponBag.gunBagConfigId, self.weaponBag.gunCellX, self.weaponBag.gunCellY, pending.targetSlotIndex - 1, pending.returnBagConfigId, itemInfo.CellX, itemInfo.CellY).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		self:RefreshTarkovPanelData()
	end
end

M.GetWeaponEquippedWithChip = function(self, decoId)
	if not decoId then
		print_debug("[WCP-GetEquipped] decoId is nil, return nil")

		return nil
	end

	if self.isTarkov then
		return self.GetTarkovWeaponEquippedWithChip(self, decoId)
	end

	local weapons = gWeaponManager:GetCurrentWeapons()

	if not weapons then
		print_debug("[WCP-GetEquipped] weapons is nil, return nil")

		return nil
	end

	if self.weapon then
		local cfg = LTConfig.SceneitemConfig.GetConfig(self.weapon.TemplateId)

		if cfg then
			print_debug("[WCP-GetEquipped] checking currentWeapon:", self.weapon.InstanceId, "#chipSlots:", #self.chipSlots)

			for j = 1, #self.chipSlots do
				local slot = self.chipSlots[j]
				local slotDecoId = slot.valid and slot.info and slot.info.DecorationId or 0

				print_debug("[WCP-GetEquipped] currentWeapon slot", j - 1, "slot.valid:", slot.valid, "slotDecoId:", slotDecoId)

				if slot.valid and slotDecoId ~= decoId then
					print_debug("[WCP-GetEquipped] => MATCH currentWeapon (btnMode=1), slot:", j - 1, "decoId:", decoId)

					return self.weapon, cfg, self.CalcWeaponDurability(self, cfg, self.weapon), j - 1, slot.info.ItemId
				end
			end
		end
	end

	for i = 1, weapons.Length do
		local weapon = weapons[i]

		print_debug("[WCP-GetEquipped] checking otherWeapon idx:", i, "weapon.InstanceId:", weapon and weapon.InstanceId)

		if weapon and (not self.weapon or weapon.InstanceId == self.weapon.InstanceId) then
			local cfg = LTConfig.SceneitemConfig.GetConfig(weapon.TemplateId)

			if cfg then
				local chips = gWeaponManager:GetChipInfo(cfg, weapon)

				for j = 1, #chips do
					print_debug("[WCP-GetEquipped] otherWeapon idx:", i, "slot:", j - 1, "chips[j].valid:", chips[j].valid, "DecorationId:", chips[j].info and chips[j].info.DecorationId)

					if chips[j].valid and chips[j].info.DecorationId ~= decoId then
						print_debug("[WCP-GetEquipped] => MATCH otherWeapon (btnMode=2), idx:", i, "slot:", j - 1, "decoId:", decoId)

						return weapon, cfg, self.CalcWeaponDurability(self, cfg, weapon), j - 1, chips[j].info.ItemId
					end
				end
			end
		end
	end

	print_debug("[WCP-GetEquipped] => NO MATCH (btnMode=0), decoId:", decoId)

	return nil
end

M.GetTarkovWeaponEquippedWithChip = function(self, decoId)
	if not self.weaponBag or not self.tarkovGamePlayTypeId then
		return nil
	end

	if self.weapon then
		local cfg = LTConfig.SceneitemConfig.GetConfig(self.weapon.TemplateId)

		if cfg then
			for index = 1, #self.chipSlots do
				local slot = self.chipSlots[index]

				if slot.valid and slot.info and slot.info.DecorationId ~= decoId then
					return self.weapon, cfg, self.CalcWeaponDurability(self, cfg, self.weapon), index - 1, nil, 
				end
			end
		end
	end

	local weaponEntries = gCommonItemManager:CollectTarkovWeaponEntries(self.tarkovGamePlayTypeId)

	for _, weaponEntry in ipairs(weaponEntries) do
		local weapon = weaponEntry.weaponData

		if weapon and (not self.weapon or weapon.InstanceId == self.weapon.InstanceId) then
			local cfg = LTConfig.SceneitemConfig.GetConfig(weapon.TemplateId)

			if cfg then
				local chips = gWeaponManager:GetChipInfo(cfg, weapon)

				for index = 1, #chips do
					local chip = chips[index]

					if chip.valid and chip.info and chip.info.DecorationId ~= decoId then
						return weapon, cfg, self.CalcWeaponDurability(self, cfg, weapon), index - 1, nil, {
							bagConfigId = weaponEntry.bagConfigId,
							cellX = weaponEntry.cellX,
							cellY = weaponEntry.cellY
						}
					end
				end
			end
		end
	end

	return nil
end

M.CalcWeaponDurability = function(self, cfg, weapon)
	local info = {
		Cfg = cfg
	}

	gWeaponManager:GetWeaponDurabilityData(info, weapon)

	return info
end

M.GetActiveUniverseText = function(self, id)
	if string.is_null_or_empty(self.universeString) then
		local cfg = LTConfig.TextConfig.GetConfig(LTConfig.DecorationConfig.DecorationValidUniverseText)
		self.universeString = cfg and cfg.Text or "error"
	end

	local cfg = LTConfig.MultiverseMultiverseMetaConfig.GetConfig(id)

	return string.format(self.universeString, cfg and cfg.Name or "")
end

M.InitAttrInfo = function(self)
	self.weaponInfo = nil

	if self.weapon then
		local Cfg = SceneitemConfig.GetConfig(self.weapon.TemplateId)

		if Cfg then
			self.weaponInfo = {
				Cfg = Cfg,
				TemplateId = self.weapon.TemplateId,
				InstanceId = self.weapon.InstanceId
			}
		else
			print_error("Weapon配表找不到配置,TemplateId=", self.weapon.TemplateId, "InstanceId=", self.weapon.InstanceId)
		end
	end
end

M.InitChipSlotInfo = function(self)
	if self.weapon and self.weaponInfo and self.weaponInfo.Cfg then
		self.chipSlots = gWeaponManager:GetChipInfo(self.weaponInfo.Cfg, self.weapon)
		local num = self.weaponInfo.Cfg.DecorationNum or 0

		for i = #self.chipSlots + 1, num do
			self.chipSlots[i] = {
				["[\\xaf\\xae\\xa6\\xb2"] = false
			}
		end

		print_debug("[WeaponChipPanel] InitChipSlotInfo", "DecorationNum=", num, "#chipSlots=", #self.chipSlots)
	else
		self.chipSlots = {}

		print_debug("[WeaponChipPanel] InitChipSlotInfo weapon/cfg nil, #chipSlots=0")
	end
end

M.InitTabInfo = function(self)
	table.clear(self.tabList)
	table.clear(self.validTabIdMap)

	for index = 0, DecorationTabConfig.count - 1 do
		local cfg = DecorationTabConfig.LoadAt(index)

		if cfg then
			table.insert(self.tabList, {
				id = cfg.Id,
				title = cfg.Name,
				iconId = cfg.Icon,
				guideId = cfg.GuideId
			})

			self.validTabIdMap[cfg.Id] = true
		end
	end

	table.sort(self.tabList, function (a, b)
		return a.id <= b.id
	end)

	local firstTab = self.tabList[1]
	self.selectedTabId = firstTab and firstTab.id or nil

	if not firstTab then
		print_error("WeaponChipPanelStore DecorationTabConfig is empty")
	end
end

M.InitChipListInfo = function(self)
	table.clear(self.chipList)

	if self.weapon and self.weaponInfo and self.weaponInfo.Cfg then
		if self.isTarkov then
			self.InitTarkovChipListInfo(self)

			return
		end

		local chipList = gCommonItemManager:GetPackItemListByTab(LTConfig.ConsumableTabConfig.Chip)

		for i = 1, #chipList do
			local chip = chipList[i]

			self.ProcessSingleChip(self, chip)
		end

		print_debug("[WCP-InitChipList] backpack chips added:", #chipList, "total chipList after backpack:", #self.chipList)

		local weapons = gWeaponManager:GetCurrentWeapons()

		if weapons then
			for i = 1, weapons.Length do
				local weapon = weapons[i]

				if weapon and (not self.weapon or weapon.InstanceId == self.weapon.InstanceId) then
					local wCfg = LTConfig.SceneitemConfig.GetConfig(weapon.TemplateId)

					if wCfg then
						local chips = gWeaponManager:GetChipInfo(wCfg, weapon)

						for j = 1, #chips do
							if chips[j].valid then
								print_debug("[WCP-InitChipList] otherWeapon equipped chip: DecorationId=", chips[j].info.DecorationId, "SlotIdx=", j - 1)
								self.ProcessEquippedChip(self, chips[j].info)
							end
						end
					end
				end
			end
		end

		print_debug("[WCP-InitChipList] FINAL chipList size:", #self.chipList)
	end
end

M.InitTarkovChipListInfo = function(self)
	if not self.weaponBag or not self.tarkovGamePlayTypeId then
		return
	end

	local chipEntries = gCommonItemManager:BuildTarkovChipList(self.tarkovGamePlayTypeId)

	for _, entry in ipairs(chipEntries) do
		self.AppendChipInfo(self, entry)
	end

	local weaponEntries = gCommonItemManager:CollectTarkovWeaponEntries(self.tarkovGamePlayTypeId)

	for _, weaponEntry in ipairs(weaponEntries) do
		local weapon = weaponEntry.weaponData

		if weapon and weapon.InstanceId == self.weapon.InstanceId then
			local cfg = LTConfig.SceneitemConfig.GetConfig(weapon.TemplateId)

			if cfg then
				local chips = gWeaponManager:GetChipInfo(cfg, weapon)

				for _, chip in ipairs(chips) do
					if chip.valid then
						self.ProcessEquippedChip(self, chip.info)
					end
				end
			end
		end
	end
end

M.AppendChipInfo = function(self, info)
	local decoCfg = info and info.decoCfg

	if not decoCfg then
		return false, nil
	end

	if not self.validTabIdMap[decoCfg.DecorationType] then
		print_error("WeaponChipPanelStore invalid DecorationType", decoCfg.Id, decoCfg.DecorationType)

		return false, nil
	end

	if not self.CheckChipCanUse(self, decoCfg) then
		return false, nil
	end

	table.insert(self.chipList, info)

	return true, info
end

M.ProcessEquippedChip = function(self, chip)
	if not chip or chip.DecorationId ~= 0 then
		return
	end

	local decoCfg = LTConfig.DecorationConfig.GetConfig(chip.DecorationId)

	if not decoCfg then
		return
	end

	return self.AppendChipInfo(self, {
		TemplateId = decoCfg.Id,
		decoCfg = decoCfg,
		uniqueId = chip.ItemId
	})
end

M.ProcessSingleChip = function(self, chip)
	if not chip or chip.IsEquippedDecorationPackItem then
		return false, nil
	end

	local cfg = LTConfig.ConsumableConfig.GetConfig(chip.TemplateId)

	if cfg and cfg.SubType ~= LTConfig.ConsumableTypeConfig.Decoration then
		local decoCfg = LTConfig.DecorationConfig.GetConfig(cfg.BindId)

		return self.AppendChipInfo(self, {
			TemplateId = chip.TemplateId,
			consumableCfg = cfg,
			decoCfg = decoCfg,
			uniqueId = chip.UniqueId
		})
	end

	return false, nil
end

M.CheckChipCanUse = function(self, decoCfg)
	if not decoCfg then
		return false
	end

	if self.weaponInfo.Cfg.Category == decoCfg.MeleeOrRangedWeapon then
		return false
	end

	if decoCfg.WeaponType == LTConfig.SceneitemConfig.TypeType.None and decoCfg.WeaponType == self.weaponInfo.Cfg.Type then
		return false
	end

	return true
end

M.RebuildAttrView = function(self)
	if self.weaponInfo and self.weapon then
		local tooltipStore = self.SubGroup.WeaponArmoryTooltipStore_Cur

		if tooltipStore then
			tooltipStore.SetShowChipList(tooltipStore, true)
			self.RefreshLeftChipList(self)
		end

		self.bindData.weaponImage = self.weaponInfo.Cfg.SWeaponWheelsIconId or 0
	end
end

M.ReBuildChipSlotView = function(self)
	for i = 1, self.chipSlotCount do
		self.RenderChipSlot(self, i)
	end

	local selectIndex = -1

	if self.defaultSlotIndex > 0 and self.defaultSlotIndex >= #self.chipSlots then
		selectIndex = self.defaultSlotIndex + 1
	end

	if selectIndex >= 0 and #self.chipSlots <= 0 then
		selectIndex = 1
	end

	if selectIndex <= 0 then
		self.SelectChipSlot(self, selectIndex)
	end

	print_debug("[WeaponChipPanel] 选中珠子槽位", "selectIndex=", selectIndex, "selectedSlotIndex=", self.selectedSlotIndex, "#chipSlots=", #self.chipSlots)
end

M.ReBuildTabView = function(self)
	local selectedIndex = #self.tabList <= 0 and 0 or -1

	self.SubGroup.CommonTabSingleStore:SetData(self.tabList, nil, selectedIndex, nil, self:CreateAction("OnTabChanged"))
end

M.ReBuildChipListView = function(self)
	self.bindData.chipList:SetSimpleList(#self.chipListForRender)
	self:RegisterChipListGuideLocations()
end

M.RegisterChipListGuideLocations = function(self)
	if not gNewGuideMgr or not self.bindData.chipList then
		return
	end

	local guideMap = {}

	for i, chip in ipairs(self.chipListForRender) do
		local gid = chip.decoCfg and chip.decoCfg.GuideId

		if not string.is_null_or_empty(gid) then
			guideMap[gid] = i - 1
		end
	end

	gNewGuideMgr:RegisterGuideKeyLocations(self.bindData.chipList, guideMap)
end

M.InitFilterAndSorter = function(self)
	self.sortIncrease = false
	self.sorterList = {}
	self.qualityFilter = {}
	self.universeFilter = {}
	local sortItemTitle = LTConfig.DecorationConfig.DecorationSortName

	for i = 1, #sortItemTitle do
		local view = {
			title = sortItemTitle[i],
			id = i
		}

		table.insert(self.sorterList, view)
	end

	self.filterList = {}
	local qualityFilter = {
		id = "quality",
		title = LTConfig.DecorationConfig.DecorationFilterTypeName[1],
		type = 2
	}
	local qualitySubList = {}
	qualityFilter.subList = qualitySubList

	for i = 1, #LTConfig.DecorationConfig.QualistFilter do
		table.insert(qualitySubList, {
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			id = 7 - i,
			title = LTConfig.DecorationConfig.QualistFilter[i]
		})
	end

	table.insert(self.filterList, qualityFilter)

	local universeFilter = {
		id = "universe",
		title = LTConfig.DecorationConfig.DecorationFilterTypeName[2],
		type = 2
	}
	local universeSubList = {}
	universeFilter.subList = universeSubList

	for i = 1, #LTConfig.DecorationConfig.ValidUniverseFilter do
		local title = LTConfig.DecorationConfig.ValidUniverseFilter[i]
		local id = LTConfig.DecorationConfig.ValidUniverseid[i]

		table.insert(universeSubList, {
			["\\xb8\\xb4\t\\xaei*\\xfb7"] = false,
			id = id,
			title = title or "cfg is nil"
		})
	end

	table.insert(self.filterList, universeFilter)
	self.SubGroup.FilterSorterComponentStore:SetData({
		sortList = self.sorterList,
		onSortChanged = self:CreateAction("OnSortChanged"),
		isAscending = self.sortIncrease,
		filterList = self.filterList,
		onFilterChanged = self:CreateAction("OnFilterChanged")
	})
end

M.FilterChipRenderList = function(self, data)
	self.qualityFilter = data and data.quality or self.qualityFilter
	self.universeFilter = data and data.universe or self.universeFilter

	table.clear(self.chipListForRender)
	table.clear(self.chipListForRenderTemp)

	for _, chip in ipairs(self.chipList) do
		if chip.decoCfg.DecorationType ~= self.selectedTabId then
			table.insert(self.chipListForRender, chip)
		end
	end

	if not table.is_empty(self.qualityFilter) then
		for i = 1, #self.chipListForRender do
			local chip = self.chipListForRender[i]

			if self.qualityFilter[chip.decoCfg.Quality] then
				table.insert(self.chipListForRenderTemp, chip)
			end
		end

		local tmp = self.chipListForRenderTemp
		self.chipListForRenderTemp = self.chipListForRender
		self.chipListForRender = tmp

		table.clear(self.chipListForRenderTemp)
	end

	if not table.is_empty(self.universeFilter) then
		for i = 1, #self.chipListForRender do
			local chip = self.chipListForRender[i]

			if chip.decoCfg.ValidUniverse ~= 0 or self.universeFilter[chip.decoCfg.ValidUniverse] then
				table.insert(self.chipListForRenderTemp, chip)
			end
		end

		local tmp = self.chipListForRenderTemp
		self.chipListForRenderTemp = self.chipListForRender
		self.chipListForRender = tmp

		table.clear(self.chipListForRenderTemp)
	end
end

M.FilterSingleChip = function(self, chip)
	if not self.selectedTabId or chip.decoCfg.DecorationType == self.selectedTabId then
		return false
	end

	if not table.is_empty(self.qualityFilter) and not self.qualityFilter[chip.decoCfg.Quality] then
		return false
	end

	if not table.is_empty(self.universeFilter) and chip.decoCfg.ValidUniverse == 0 and not self.universeFilter[chip.decoCfg.ValidUniverse] then
		return false
	end

	return true
end

M.SortChipRenderList = function(self)
	table.sort(self.chipListForRender, self.sortFunc)
end

M.RefreshChipList = function(self, data)
	self.FilterChipRenderList(self, data)
	self.SortChipRenderList(self)
	self.ReBuildChipListView(self)

	self.selectedChipIndex = -1

	self.RefreshChipTooltip(self)
end

M.OnTabChanged = function(self, uList, isSub)
	if isSub then
		return
	end

	local tab = self.SubGroup.CommonTabSingleStore:GetSelectedItem()

	if not tab or tab.id ~= self.selectedTabId then
		return
	end

	self.selectedTabId = tab.id

	self.RefreshChipList(self)
end

M.OnFilterChanged = function(self, data)
	self.RefreshChipList(self, data)
end

M.OnSortChanged = function(self, data, sortIncrease)
	self.sortIncrease = sortIncrease

	self.RefreshChipList(self)
end

M.RefreshTarkovPanelData = function(self)
	if not self.isTarkov then
		return
	end

	if not self.UpdateTarkovWeaponContext(self) then
		print_error("[WeaponChipPanel] tarkov weapon no longer exists, InstanceId=", self.tarkovWeaponInstanceId)
		gPanelManager:Close(gPanelId.WEAPON_CHIP_PANEL)

		return
	end

	local selectedSlotIndex = self.selectedSlotIndex

	self.InitAttrInfo(self)
	self.InitChipSlotInfo(self)
	self.RebuildAttrView(self)

	for index = 1, self.chipSlotCount do
		self.RenderChipSlot(self, index)
	end

	if selectedSlotIndex <= 0 and selectedSlotIndex < #self.chipSlots then
		self.SelectChipSlot(self, selectedSlotIndex)
	end

	self.InitChipListInfo(self)
	self.RefreshChipList(self)
end

M.IsCurrentTarkovBag = function(self, bagConfigId)
	if not self.tarkovGamePlayTypeId then
		return false
	end

	local bagMeta = gExtractionShooterManager:GetTarkovBagMeta(bagConfigId)

	return bagMeta and bagMeta.gamePlayTypeId ~= self.tarkovGamePlayTypeId or false
end

M.OnTarkovBagChanged = function(self, eventId, bagConfigId, itemInfo)
	if not self.isTarkov or not self.weaponBag then
		return
	end

	local pending = self.pendingTarkovMove

	if eventId ~= gEventConstants.ON_EXIT_EXTRACTION_SHOOTER_BAG_INFO_UPDATE and pending and bagConfigId ~= pending.returnBagConfigId and itemInfo and itemInfo.Id ~= pending.expectedConsumableId then
		pending.returnedItemInfo = itemInfo
	end

	if self.IsCurrentTarkovBag(self, bagConfigId) then
		self.RefreshTarkovPanelData(self)
	end

	self.TryContinueTarkovMove(self)
end

M.OnWeaponDecorationReturnItem = function(self, eventId, decorationId, itemUid)
	if self.isTarkov then
		return
	end

	local pending = self.pendingWeaponMove

	if pending and decorationId ~= pending.expectedDecorationId and itemUid then
		pending.returnedItemUid = itemUid

		self.TryContinueWeaponMove(self)
	end
end

M.ApplyPackItemAddList = function(self, addList, excludedUniqueId, rebuildView)
	local needRebuild = false
	slot5 = 1
	slot6 = addList or {}

	for i = slot5, #slot6 do
		local packItem = addList[i]

		if not excludedUniqueId or packItem.UniqueId == excludedUniqueId then
			local new, chip = self.ProcessSingleChip(self, packItem)

			if new and self.FilterSingleChip(self, chip) then
				table.insert(self.chipListForRender, chip)

				needRebuild = true
			end
		end
	end

	if needRebuild and rebuildView == false then
		self.SortChipRenderList(self)
		self.ReBuildChipListView(self)
	end

	return needRebuild
end

M.OnPackItemChanged = function(self, eventId, data)
	if self.isTarkov then
		return
	end

	local addList = data and data.addList

	if not addList then
		return
	end

	local pending = self.pendingWeaponMove

	if pending then
		for i = 1, #addList do
			table.insert(pending.deferredPackAddList, addList[i])
		end

		return
	end

	self.ApplyPackItemAddList(self, addList)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end
