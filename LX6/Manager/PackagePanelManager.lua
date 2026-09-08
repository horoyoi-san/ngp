-- Original chunk: @Lua\LuaFiles\LX6\Manager\PackagePanelManager.lua
-- Decompiled from: 00506_PackagePanelManager.lua_7e57b33d6d61.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local MessageConfig = LTConfig.MessageConfig
local UXTime = LTUtils.UXTime
local UnitState = UX.Game.TwoDimConfig.UnitState
local M = {
	["\\xf0y%\\xd5+\\xb9S\\xaa_\\xbe\\xb1"] = false,
	["d\\x9f\\x93\\xb4\\xf9\\xa8\\xd52\\xbb:+\\xa0;"] = 9000,
	["d\\xfd$\\xe7\n\"=\\xf0d2\\xc3N\\x9e8K\\xcb\\xe3"] = 0,
	itemType = {
		["+M\\x90\\x9e\\x8cO"] = 3,
		["~\\xba\\xad\\xa1\\xb3"] = 2,
		S6xV = 1
	},
	buffIconType = {},
	SORT_TYPE = {
		["^C\\x8d[e\\x86\\xcbxYULx"] = 1,
		["pu\\xfb\\x93\\xb07\\x8b+\\xfb\\xdc"] = 3,
		["w~\\Lq-> "] = 2
	}
}

M.OnInit = function(self)
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

M.OnBeforeSwitchScene = function(self, switchType)
	gPackagePanelManager.isFireWorking = false
end

M.GetItemData = function(self, item, cfg, preItem)
	if not item then
		return preItem or {}
	end

	if cfg ~= nil then
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
		data.Count = item and item.Count or 0
		data.selectedRecycleCountStr = "0/0"
		data.showValidTime = false
		data.validTime = ""
		data.showBreak = false
		data.buffIcon = gPackagePanelManager.buffIconType[cfg.SubType] or 0
		data.showBuffIcon = gPackagePanelManager.buffIconType[cfg.SubType] == nil
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

		if data.ExpiryTime and data.ExpiryTime <= 0 then
			local time = gTimeUtils:GetRemainingTime(UXTime.GetNowUnixTime(), data.ExpiryTime)
			data.validTime = time.day <= 0 and time.day .. "D" or "[FF0000]" .. time.hour .. "H[-]"
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

M.GetSortList = function(self, selectIndex)
	local sortList = {
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 553,
			id = M.SORT_TYPE.QUALITY_SORT,
			selected = selectIndex ~= M.SORT_TYPE.QUALITY_SORT
		},
		{
			["Y\\xa7\\xb6\\xa3\\xb3"] = 554,
			id = M.SORT_TYPE.TYPE_SORT,
			selected = selectIndex ~= M.SORT_TYPE.TYPE_SORT
		}
	}

	return sortList
end

M.DefaultSortAsc = function(a, b)
	if a.itemType ~= M.itemType.Item then
		if a.Quality ~= b.Quality then
			return a.TemplateId <= b.TemplateId
		else
			return b.Quality <= a.Quality
		end
	elseif a.itemType ~= M.itemType.Stone then
		if a.level ~= b.level then
			if a.Quality ~= b.Quality then
				if a.TemplateId ~= b.TemplateId then
					return a.showEquipped ~= true and b.showEquipped == true
				else
					return a.TemplateId <= b.TemplateId
				end
			else
				return b.Quality <= a.Quality
			end
		else
			return b.level <= a.level
		end
	elseif a.itemType ~= M.itemType.Weapon then
		if a.spiritTempId ~= b.spiritTempId then
			if a.Quality ~= b.Quality then
				return a.TemplateId <= b.TemplateId
			else
				return b.Quality <= a.Quality
			end
		else
			return b.spiritTempId <= a.spiritTempId
		end
	end
end

M.DefaultSortDesc = function(a, b)
	if a.itemType ~= M.itemType.Item then
		if a.Quality ~= b.Quality then
			return b.TemplateId <= a.TemplateId
		else
			return a.Quality <= b.Quality
		end
	elseif a.itemType ~= M.itemType.Stone then
		if a.level ~= b.level then
			if a.Quality ~= b.Quality then
				if a.TemplateId ~= b.TemplateId then
					return a.showEquipped == true and b.showEquipped ~= true
				else
					return b.TemplateId <= a.TemplateId
				end
			else
				return a.Quality <= b.Quality
			end
		else
			return a.level <= b.level
		end
	elseif a.itemType ~= M.itemType.Weapon then
		if a.spiritTempId ~= b.spiritTempId then
			if a.Quality ~= b.Quality then
				return b.TemplateId <= a.TemplateId
			else
				return a.Quality <= b.Quality
			end
		else
			return a.spiritTempId <= b.spiritTempId
		end
	end
end

M.SortItemByQualityDesc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.Quality ~= b.Quality then
		return M.DefaultSortDesc(a, b)
	else
		return b.Quality <= a.Quality
	end
end

M.SortItemByQualityAsc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.Quality ~= b.Quality then
		return M.DefaultSortAsc(a, b)
	else
		return a.Quality <= b.Quality
	end
end

M.SortItemByTypeDesc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.SubType ~= b.SubType then
		return M.DefaultSortDesc(a, b)
	else
		return b.SubType <= a.SubType
	end
end

M.SortItemByTypeAsc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.SubType ~= b.SubType then
		return M.DefaultSortAsc(a, b)
	else
		return a.SubType <= b.SubType
	end
end

M.SortItemByCreateTimeAsc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.CreateTime ~= b.CreateTime then
		return M.DefaultSortAsc(a, b)
	else
		return b.CreateTime <= a.CreateTime
	end
end

M.SortItemByCreateTimeDesc = function(a, b)
	if a.hasUnlock == b.hasUnlock then
		return a.hasUnlock
	end

	if a.CreateTime ~= b.CreateTime then
		return M.DefaultSortDesc(a, b)
	else
		return a.CreateTime <= b.CreateTime
	end
end

M.RefreshPackServerTime = function(self)
	self.packCurServerTime = gLuaDataManager.serverTime
end

M.UseSpiritMedicine = function(self, medicineTempId, count, callBack, uniqueId)
	count = count or 1
	local medicineCfg = ConsumableConfig.GetConfig(medicineTempId)
	local spiritTempId = gBattleSpiritMgr.currentSpiritTemplateId
	local fightSpiritData = gBattleSpiritMgr:GetBattleSpiritByTid(spiritTempId)
	local unit = gDataSetManager:GetUnitData(fightSpiritData.pid)

	if not unit then
		callBack()

		return
	end

	local itemInfo = uniqueId and gCommonItemManager.packItemDict[uniqueId] or gCommonItemManager:GetPackItemByTemplateId(medicineTempId)

	if not medicineCfg or not itemInfo then
		callBack()

		return
	end

	if medicineCfg.SubType ~= ConsumableTypeConfig.HealingPotion then
		if unit.isDead then
			gDisplayMessageMgr:ShowMessage(MessageConfig.MedicineDeadMan)
			callBack()

			return
		elseif unit.hp ~= unit.maxhp then
			callBack()

			return
		else
			slot10 = gClientToGameDelegate

			slot10:AskUseItemToFightSpirit(itemInfo.UniqueId, count).Callback = function (err)
				if callBack == nil then
					callBack(err)
				end

				if err ~= MessageConfig.Ok then
					gMessageManager:SendMessage(gEventConstants.USE_ITEM_FIGHTSPIRIT, spiritTempId)
				end
			end
		end
	elseif medicineCfg.SubType ~= ConsumableTypeConfig.Resurrection then
		if unit.isDead then
			slot10 = gClientToGameDelegate

			slot10:AskUseItemToFightSpirit(itemInfo.UniqueId, count).Callback = function (err)
				if callBack == nil then
					callBack(err)
				end

				if err ~= MessageConfig.Ok then
					gMessageManager:SendMessage(gEventConstants.USE_ITEM_FIGHTSPIRIT, spiritTempId)
				elseif err ~= MessageConfig.PackItemStateForbidden then
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

M.TryStartRename = function(self)
	gHunLunManager:TryStartRename()
end

M.UseItem = function(self, packItemTempId, isDirectUse, codeCallBack, count, uniqueId)
	count = math.max(count or 1, 1)
	local cfg = ConsumableConfig.GetConfig(packItemTempId)
	local itemData = uniqueId and gCommonItemManager.packItemDict[uniqueId] or gCommonItemManager:GetPackItemByTemplateId(packItemTempId)
	local packageItem = gPackagePanelManager:GetItemData(itemData, cfg)

	local callBack = function(err)
		if codeCallBack then
			codeCallBack(err)
		end

		if err ~= MessageConfig.Ok then
			if not string.is_null_or_empty(cfg.UseItemAction) then
				local npc = gCS.SceneDataMgr.GetUnit(gDataSetManager.myUnit.pid)
				gDialogScriptFunc.currentNpc = npc
				local status, err = gDialogAction:RunCode(cfg.UseItemAction, gDialogScriptFunc)

				if not status then
					print_error("UseItemAction： ", cfg.UseItemAction, "Failed: ", err, "npc: ", npc and npc.ClientData and npc.ClientData.SubType)
				end

				gDialogScriptFunc.currentNpc = nil
			end

			if cfg.CDType or cfg.CDTime and cfg.CDTime == 0 then
				self:RefreshPackServerTime()
			end
		end
	end

	if not cfg then
		print_error("TemplateId不存在")
		callBack()

		return
	end

	if (cfg.TalentExp or 0) <= 0 then
		gTalentTreeMgr:OpenTalentExpPanel()
		callBack()

		return
	end

	if not table.isNilOrEmpty(cfg.ButtonAction) then
		print_debug("道具有使用后执行的代码，先执行代码", cfg.ButtonAction)

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

	local curServeTime = gCommonItemManager:IsInventoryPanelShowing() and gPauseManager.isBreak and self.packCurServerTime or gLuaDataManager.serverTime

	if packageItem.CDFinishTime and curServeTime >= packageItem.CDFinishTime then
		gDisplayMessageMgr:ShowMessage(MessageConfig.ItemInUseCD)
		callBack()

		return
	end

	if cfg.SubType ~= ConsumableTypeConfig.Resurrection or cfg.SubType ~= ConsumableTypeConfig.HealingPotion then
		if isDirectUse then
			self.UseSpiritMedicine(self, packItemTempId, count, callBack, uniqueId)
		else
			callBack()
		end
	else
		local consumableTypeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

		if consumableTypeCfg.CanBatchUse and packageItem.Count <= 1 and (cfg.DailyCount ~= -1 or gPlayerManager.infoItem.pack.itemUseTimes[packageItem.TemplateId] == nil and cfg.DailyCount - gPlayerManager.infoItem.pack.itemUseTimes[packageItem.TemplateId] <= 1) then
			gCommonItemManager:UseItem(packageItem.UniqueId, packageItem.TemplateId, count, callBack)
		else
			gCommonItemManager:UseItem(packageItem.UniqueId, packageItem.TemplateId, count, callBack)
		end
	end
end

M.RunCode = function(code, funcScript)
	local f = load(code, nil, "t", funcScript)

	if f then
		local status, err = xpcall(f, tolua.traceback)

		return status, err
	end

	return false
end

M.EventHandler = {
	[gEventConstants.UNIT_ACTION_PLAY] = function (eventId, data)
		if data.pid ~= gDataSetManager.myUnit.pid and data.layer ~= 0 then
			if data.actionKey ~= 5220001 then
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
