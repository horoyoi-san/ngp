local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local MessageConfig = LTConfig.MessageConfig
local UXTime = LTUtils.UXTime
local UnitState = UX.Game.TwoDimConfig.UnitState
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local DieKaLevelIconId = {
	[0] = 30302024,
	30302025,
	30302026,
	30302027,
	30302028,
	30302029
}
local M = {
	isFireWorking = false,
	checkExpireFrame = 9000,
	packCurServerTime = 0,
	itemType = {
		Weapon = 3,
		Stone = 2,
		Item = 1
	},
	buffIconType = {},
	SORT_TYPE = {
		QUALITY_SORT = 1,
		TYPE_SORT = 2
	}
}

function M:OnInit()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	local typeIconList = ConsumableConfig.TypeIcon

	if not typeIconList then
		return
	end

	M.buffIconType = {}

	for typeIndex = 1, #typeIconList do
		local type = ConsumableTypeConfig[typeIconList[typeIndex].Type]

		if type then
			M.buffIconType[type] = typeIconList[typeIndex].imageId
		end
	end
end

function M:OnBeforeSwitchScene(switchType)
	gPackagePanelManager.isFireWorking = false
end

function M:GetItemData(item, cfg, preItem)
	if cfg == nil then
		cfg = ConsumableConfig.GetConfig(item.TemplateId)
	end

	if cfg then
		local data = preItem or {}
		data.itemType = M.itemType.Item
		data.SubType = cfg.SubType
		data.Alpha = 1
		data.sguiIconId = cfg.SItemIconId
		data.ItemIconType = 0
		data.Quality = cfg.Quality
		data.showCount = true
		data.showRecycleSelected = false
		data.Count = item.Count or 0
		data.selectedRecycleCountStr = "0/0"
		data.showValidTime = false
		data.validTime = ""
		data.showBreak = false
		data.buffIcon = gPackagePanelManager.buffIconType[cfg.SubType] or 0
		data.showBuffIcon = gPackagePanelManager.buffIconType[cfg.SubType] ~= nil
		data.showX = false
		data.isSelected = false
		data.showEquipped = false
		data.showEquipment = false
		data.equipmentStr = ""
		data.showLevel = false

		if cfg.RequireLevel then
			data.levelStr = "Lv. " .. cfg.RequireLevel
		else
			data.levelStr = ""
		end

		data.IsNew = item.IsNew or false
		data.isCD = false
		data.medicineSelected = false
		data.isLock = false
		data.showDieKaLevel = false
		data.showWeaponBreak = false
		data.selectedRecycleCount = 0
		data.canDiscard = cfg.Discard
		data.name = cfg.Name
		data.level = cfg.RequireLevel
		data.systemPrice = cfg.SystemPrice
		data.showMask = false
		data.TemplateId = cfg.Id
		data.UniqueId = item.UniqueId
		data.ExpiryTime = item.ExpiryTime or 0
		data.CreateTime = item.CreateTime or 0
		data.buff = nil
		data.CDFinishTime = item.CDFinishTime or 0
		data.Description = cfg.Description
		data.ShortDescription = cfg.ShortDescription
		data.cfg = cfg

		if data.ExpiryTime and data.ExpiryTime > 0 then
			local time = gTimeUtils:GetRemainingTime(UXTime.GetNowUnixTime(), data.ExpiryTime)
			data.validTime = time.day > 0 and time.day .. "D" or "[FF0000]" .. time.hour .. "H[-]"
			data.showValidTime = true
		end

		local singleCD = cfg.CDTime
		local commonCD = nil
		local commonCDType = cfg.CDType

		if commonCDType then
			local cdCfg = LTConfig.ConsumableCDTypeConfig.GetConfig(commonCDType)
			commonCD = cdCfg and cdCfg.ShareCDTime
		end

		data.totalCD = commonCD or singleCD

		return data
	else
		print_error("道具", item.TemplateId, "被删除")
	end
end

function M:GetSortList(selectIndex)
	local sortList = {
		{
			title = 553,
			id = M.SORT_TYPE.QUALITY_SORT,
			selected = selectIndex == M.SORT_TYPE.QUALITY_SORT
		},
		{
			title = 554,
			id = M.SORT_TYPE.TYPE_SORT,
			selected = selectIndex == M.SORT_TYPE.TYPE_SORT
		}
	}

	return sortList
end

function M.DefaultSortAsc(a, b)
	if a.itemType == M.itemType.Item then
		if a.Quality == b.Quality then
			return a.TemplateId < b.TemplateId
		else
			return b.Quality < a.Quality
		end
	elseif a.itemType == M.itemType.Stone then
		if a.level == b.level then
			if a.Quality == b.Quality then
				if a.TemplateId == b.TemplateId then
					return a.showEquipped == true and b.showEquipped ~= true
				else
					return a.TemplateId < b.TemplateId
				end
			else
				return b.Quality < a.Quality
			end
		else
			return b.level < a.level
		end
	elseif a.itemType == M.itemType.Weapon then
		if a.spiritTempId == b.spiritTempId then
			if a.Quality == b.Quality then
				return a.TemplateId < b.TemplateId
			else
				return b.Quality < a.Quality
			end
		else
			return b.spiritTempId < a.spiritTempId
		end
	end
end

function M.DefaultSortDesc(a, b)
	if a.itemType == M.itemType.Item then
		if a.Quality == b.Quality then
			return b.TemplateId < a.TemplateId
		else
			return a.Quality < b.Quality
		end
	elseif a.itemType == M.itemType.Stone then
		if a.level == b.level then
			if a.Quality == b.Quality then
				if a.TemplateId == b.TemplateId then
					return a.showEquipped ~= true and b.showEquipped == true
				else
					return b.TemplateId < a.TemplateId
				end
			else
				return a.Quality < b.Quality
			end
		else
			return a.level < b.level
		end
	elseif a.itemType == M.itemType.Weapon then
		if a.spiritTempId == b.spiritTempId then
			if a.Quality == b.Quality then
				return b.TemplateId < a.TemplateId
			else
				return a.Quality < b.Quality
			end
		else
			return a.spiritTempId < b.spiritTempId
		end
	end
end

function M.SortByQualityDesc(a, b)
	if a.Quality == b.Quality then
		return M.DefaultSortDesc(a, b)
	else
		return b.Quality < a.Quality
	end
end

function M.SortByQualityAsc(a, b)
	if a.itemType == M.itemType.Weapon then
		-- Nothing
	end

	if a.Quality == b.Quality then
		return M.DefaultSortAsc(a, b)
	else
		return a.Quality < b.Quality
	end
end

function M.SortByLevelDesc(a, b)
	if a.level == b.level then
		return M.DefaultSortDesc(a, b)
	else
		return b.level < a.level
	end
end

function M.SortByLevelAsc(a, b)
	if a.level == b.level then
		return M.DefaultSortAsc(a, b)
	else
		return a.level < b.level
	end
end

function M.SortByEquippedDesc(a, b)
	if a.showEquipped == b.showEquipped then
		return M.DefaultSortDesc(a, b)
	else
		return a.showEquipped == true
	end
end

function M.SortByEquippedAsc(a, b)
	if a.showEquipped == b.showEquipped then
		return M.DefaultSortAsc(a, b)
	else
		return a.showEquipped == false
	end
end

function M.SortItemByQualityDesc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.Quality == b.Quality then
		return M.DefaultSortDesc(a, b)
	else
		return b.Quality < a.Quality
	end
end

function M.SortItemByQualityAsc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.Quality == b.Quality then
		return M.DefaultSortAsc(a, b)
	else
		return a.Quality < b.Quality
	end
end

function M.SortItemByTypeDesc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.SubType == b.SubType then
		return M.DefaultSortDesc(a, b)
	else
		return b.SubType < a.SubType
	end
end

function M.SortItemByTypeAsc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.SubType == b.SubType then
		return M.DefaultSortAsc(a, b)
	else
		return a.SubType < b.SubType
	end
end

function M.SortItemByCreateTimeAsc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.CreateTime == b.CreateTime then
		return M.DefaultSortAsc(a, b)
	else
		return b.CreateTime < a.CreateTime
	end
end

function M.SortItemByCreateTimeDesc(a, b)
	if a.hasUnlock ~= b.hasUnlock then
		return a.hasUnlock
	end

	if a.CreateTime == b.CreateTime then
		return M.DefaultSortDesc(a, b)
	else
		return a.CreateTime < b.CreateTime
	end
end

function M:RefreshPackServerTime()
	self.packCurServerTime = gLuaDataManager.serverTime
end

function M:UseSpiritMedicine(medicineTempId, count, callBack)
	count = count or 1
	local medicineCfg = ConsumableConfig.GetConfig(medicineTempId)
	local spiritTempId = gBattleSpiritMgr.currentSpiritTemplateId
	local fightSpiritData = gBattleSpiritMgr:GetBattleSpiritByTid(spiritTempId)
	local unit = gDataSetManager:GetUnitData(fightSpiritData.pid)

	if not unit then
		callBack()

		return
	end

	local itemInfo = gPlayerItemManager:GetPackItemByTemplateId(medicineTempId)

	if not medicineCfg or not itemInfo then
		callBack()

		return
	end

	if medicineCfg.SubType == ConsumableTypeConfig.HealingPotion then
		if unit.isDead then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MedicineDeadMan)
			callBack()

			return
		elseif unit.hp == unit.maxhp then
			callBack()

			return
		else
			gClientToGameDelegate:AskUseItemToFightSpirit(itemInfo.UniqueId, count).Callback = function (err)
				if callBack ~= nil then
					callBack(err)
				end

				if err == MessageConfig.Ok then
					gMessageManager:SendMessage(gEventConstants.USE_ITEM_FIGHTSPIRIT, spiritTempId)
				end
			end
		end
	elseif medicineCfg.SubType == ConsumableTypeConfig.Resurrection then
		if unit.isDead then
			gClientToGameDelegate:AskUseItemToFightSpirit(itemInfo.UniqueId, count).Callback = function (err)
				if callBack ~= nil then
					callBack(err)
				end

				if err == MessageConfig.Ok then
					gMessageManager:SendMessage(gEventConstants.USE_ITEM_FIGHTSPIRIT, spiritTempId)
				elseif err == MessageConfig.PackItemStateForbidden then
					gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900051).Text)
				end
			end
		else
			gDisplayMessageMgr:ShowMessage(MessageConfig.ResurrectionAlive)
			callBack()

			return
		end
	else
		callBack()
	end
end

function M:UseItem(packItemTempId, isDirectUse, codeCallBack)
	local cfg = ConsumableConfig.GetConfig(packItemTempId)
	local itemData = gPlayerItemManager:GetPackItemByTemplateId(packItemTempId)
	local packageItem = gPackagePanelManager:GetItemData(itemData, cfg)

	local function callBack(err)
		if codeCallBack then
			codeCallBack(err)
		end

		if err == MessageConfig.Ok then
			if not string.is_null_or_empty(cfg.UseItemAction) then
				local npc = gCS.SceneDataMgr.GetUnit(gDataSetManager.myUnit.pid)
				gDialogScriptFunc.currentNpc = npc
				local status, err = gDialogAction:RunCode(cfg.UseItemAction, gDialogScriptFunc)

				if not status then
					print_error("UseItemAction： ", cfg.UseItemAction, "Failed: ", err, "npc: ", npc and npc.ClientData and npc.ClientData.SubType)
				end

				gDialogScriptFunc.currentNpc = nil
			end

			if cfg.CDType or cfg.CDTime and cfg.CDTime ~= 0 then
				self:RefreshPackServerTime()
			end
		end
	end

	if not cfg then
		print_error("TemplateId不存在")
		callBack()

		return
	end

	if not table.isNilOrEmpty(cfg.ButtonAction) then
		for i = 1, #cfg.ButtonAction do
			M.RunCode(cfg.ButtonAction[i], M)
		end

		callBack()

		return
	end

	if gCS.MyPlayerManager.CheckEventForbidden(UnitState.UseItem) then
		callBack()

		return
	end

	local curServeTime = gPanelManager:IsPanelShowing(gPanelId.S_INVENTORY_PANEL) and gPauseManager.isBreak and self.packCurServerTime or gLuaDataManager.serverTime

	if packageItem.CDFinishTime and curServeTime < packageItem.CDFinishTime then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemInUseCD)
		callBack()

		return
	end

	if cfg.SubType == ConsumableTypeConfig.Resurrection or cfg.SubType == ConsumableTypeConfig.HealingPotion then
		if isDirectUse then
			self:UseSpiritMedicine(packItemTempId, 1, callBack)
		else
			callBack()
		end
	else
		local consumableTypeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

		if consumableTypeCfg.CanBatchUse and packageItem.Count > 1 and (cfg.DailyCount == -1 or gPlayerManager.infoItem.pack.itemUseTimes[packageItem.TemplateId] ~= nil and cfg.DailyCount - gPlayerManager.infoItem.pack.itemUseTimes[packageItem.TemplateId] > 1) then
			gPlayerItemManager:UseItem(packageItem.UniqueId, packageItem.TemplateId, 1, callBack)
		else
			gPlayerItemManager:UseItem(packageItem.UniqueId, packageItem.TemplateId, 1, callBack)
		end
	end
end

function M.RunCode(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

M.EventHandler = {
	[gEventConstants.UNIT_ACTION_PLAY] = function (eventId, data)
		if data.pid == gDataSetManager.myUnit.pid and data.layer == 0 then
			if data.actionKey == 5220001 then
				gPackagePanelManager.isFireWorking = true
			elseif gPackagePanelManager.isFireWorking then
				gPackagePanelManager.isFireWorking = false

				gCS.EffectMgr:StopEffectForUnit(gDataSetManager.myUnit.pid, 53610404)
			end
		end
	end
}
gPackagePanelManager = M

return gPackagePanelManager
