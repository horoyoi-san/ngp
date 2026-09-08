-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_UI.lua
-- Decompiled from: 02203_CommonItemManager_UI.lua_778f806ea374.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local DecorationConfig = LTConfig.DecorationConfig
local M = C_CommonItemManager
local BOOL2CTL = gClientConst.BOOL2CTL

M.OnDescItemClick = function(self, btn, data)
	if data.callback then
		data.callback()

		return
	end
end

M.GetDescRewardRenderList = function(self, data)
	if table.isNilOrEmpty(data) then
		return {}
	end

	if not table.isNilOrEmpty(data.rewardRenderList) then
		return data.rewardRenderList
	end

	local rewardList = data.rewardList or {}
	local ret = {}

	for i = 1, #rewardList do
		local reward = rewardList[i]
		local templateId = reward and self:GetTemplateId(reward) or nil

		if reward and reward.itemId and reward.iconId then
			table.insert(ret, reward)
		elseif templateId and templateId == 0 then
			table.insert(ret, self:GetItemRenderData({
				itemId = templateId,
				itemNum = reward.count or reward.Count or reward.itemNum or ""
			}))
		end
	end

	return ret
end

M.OnRenderDescItem = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.EnableImmediatelyCommit(store, true)

	if data.tIndex ~= self.Template2Index.REWARD_LIST then
		local rewardRenderList = self.GetDescRewardRenderList(self, data)

		if store.rewardList then
			store.rewardList.luaSimpleRenderItem = function(itemBtn, itemIndex)
				local rewardData = rewardRenderList[itemIndex + 1]

				if rewardData then
					self:OnCommonItemRender(itemBtn, itemIndex, rewardData)
				end
			end

			store.rewardList:SetSimpleList(#rewardRenderList)
		end

		return
	end

	if data.tIndex ~= self.Template2Index.WEAPON_CHIP then
		local chipStore = store

		if data.valid then
			local cfg = DecorationConfig.GetConfig(data.info.DecorationId)
			store.EmptyCtrl = BOOL2CTL[false]
			store.iconId = cfg and cfg.Icon or 0
			store.QualityCtrl = cfg and cfg.Quality or 0
			store.content = cfg and cfg.Effect or ""
		else
			store.EmptyCtrl = BOOL2CTL[true]
			chipStore.content = ""
		end

		return
	end

	store.nameLabel = data.text or data.name
	store.descLabel = data.desc or ""
	store.iconId = data.iconId or 0
	store.state = data.state or 0

	if store.progress then
		store.progress.maxValue = data.maxValue or 1
		store.progress.value = data.value or 0
	end
end

M.InitRenderList = function(self, list, customRenderFunc, customClickFunc)
	list.luaRenderItem = customRenderFunc or self:CreateAction(self.OnCommonItemRender)
end

M.OnRenderToolTips = function(self, data, btn, popup, index)
	self.itemToolTipStore = gStoreManager:GetStoreGroup(popup.Store)

	if not self.itemToolTipStore then
		return
	end

	self.itemToolTipRefBtn = btn

	self.itemToolTipRefBtn:SetSelected(true)
	self.itemToolTipStore:SetSelectedItem(data, data.checkBtnVisCallback, data.onConfirmCallback, data.onValueChangeCallback, nil)

	if data.toolTipsCallback then
		data.toolTipsCallback(popup)
	end
end

M.OnToolTipsClose = function(self, btn, popup, index)
	if not popup then
		btn.SetSelected(btn, false)
	end
end

M.OnItemToolTipBtnClose = function(self)
	self.itemToolTipRefBtn = nil
	self.itemToolTipStore = nil
end

M.CloseItemToolTips = function(self)
	if self.itemToolTipRefBtn then
		self.itemToolTipRefBtn:CloseTooltip(true)
	end
end

M.OnRenderCommonBuyItem = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup("CommonBuyItemStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.nameLabel = data.name
	store.numLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901018).Text, data.count)
	local itemData = self.GetItemRenderData(self, {
		itemId = data.templateId
	})

	self.OnCommonItemRender(self, store.itemBtn, 0, itemData)
end

M.OnRenderNum = function(self, itemId, itemNum, useLocalizedMoneyFormat, forceShowNum)
	local cfg = ConsumableConfig.GetConfig(itemId)
	local typeCfg = cfg and ConsumableTypeConfig.GetConfig(cfg.SubType) or nil

	if not forceShowNum and typeCfg and typeCfg.StackMaxCount and typeCfg.StackMaxCount ~= 1 then
		return ""
	end

	if type(itemNum) ~= "number" then
		if itemNum ~= 0 then
			return ""
		end

		if useLocalizedMoneyFormat and self.IsMoneyItem(self, itemId) then
			return self.BuildLargeNum(self, itemNum)
		end

		return itemNum
	end

	return itemNum or ""
end

M.OnDynCommonItemRender = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.Commit(store, "itemType", self.GetItemDisplayType(self, data.itemId), COMMIT_IMMEDIATELY)

	return store
end

M.OnCommonItemChipRender = function(self, chipInfos, btn, index)
	local group = gStoreManager:GetStoreGroup(btn.Store)
	local store = group and group:GetStoreByWidget(btn) or nil
	local data = chipInfos[index + 1]

	if not store or not data then
		return
	end

	local cfg = data.valid and data.info and DecorationConfig.GetConfig(data.info.DecorationId) or nil
	store.qualityCtrl = cfg and cfg.Quality or 0
end

M.OnCommonItemRender = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.sizeCtl then
		store.sizeCtl = data.sizeCtl
	end

	store.isFirst = BOOL2CTL[data.isFirstKill]
	store.isLock = BOOL2CTL[data.isLock]

	store.Commit(store, "quality", data.quality, COMMIT_IMMEDIATELY)
	store.Commit(store, "iconId", data.iconId, COMMIT_IMMEDIATELY)

	store.isOwned = BOOL2CTL[data.IsOwned]
	btn.interactable = data.interactable
	btn.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderToolTips, data)

	btn.luaTooltipPopup = function(toolTipsBtn, toolTipsPopup, toolTipsIndex)
		self:OnToolTipsClose(toolTipsBtn, toolTipsPopup, toolTipsIndex)

		if not toolTipsPopup and data.toolTipsCloseCallback then
			data.toolTipsCloseCallback()
		end
	end

	store.showUnselect = BOOL2CTL[data.showUnselect]

	if data.unselectedCb then
		store.unselectBtn.luaClick = function()
			data.unselectedCb()
		end
	end

	store.itemType = self:GetItemDisplayType(data.itemId)
	store.notAvailableCtrl = BOOL2CTL[data.notAvailable]
	store.vx_complateCtrl = BOOL2CTL[data.showVfx]
	store.subQualityCtrl = data.subQualityCtrl or self.SUB_QUALITY_CTRL.NONE
	local chipInfos = data.chipInfos or {}
	store.chipListCtrl = data.chipListCtrl or BOOL2CTL[#chipInfos >= 0]

	if store.chipList then
		store.chipList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnCommonItemChipRender, chipInfos)

		store.chipList:SetSimpleList(#chipInfos)
	end

	store.equippedCtrl = data.equippedCtrl or self.EQUIPPED_CTRL.NONE
	store.brokenCtrl = data.brokenCtrl or self.BROKEN_CTRL.NORMAL
	store.durabilityLabel = data.durabilityLabel or ""

	if string.is_null_or_empty(data.durabilityLabel) then
		store.Commit(store, "count", self.OnRenderNum(self, data.itemId, data.itemNum, data.useLocalizedMoneyFormat, data.forceShowNum), COMMIT_FORCE)
	else
		store.Commit(store, "count", "", COMMIT_FORCE)
	end

	store.ownerIcon = data.ownerIcon or 0

	return store
end

M.OnCommonItemClick = function(self, list, btn, data)
	local itemList = {}
	local selectIndex = 0
	data = data or list:GetData(0)

	if table.isNilOrEmpty(data) then
		return
	end

	local selectId = self:GetTemplateId(data)
	local selectItemId = data and selectId or -1

	for i = 0, list.itemData.Count - 1 do
		local itemId = self.GetTemplateId(self, list.itemData[i])

		table.insert(itemList, {
			itemId = itemId
		})

		if itemId ~= selectItemId then
			selectIndex = #itemList
		end
	end

	self.OnShowItemList(self, itemList, selectIndex)
end

M.GetItemRenderData = function(self, item)
	if type(item) ~= "number" then
		item = {
			itemId = item
		}
	end

	local itemId = self.GetTemplateId(self, item)

	if itemId and itemId == 0 then
		local itemData = self.TryGetItemInfo(self, item)

		if table.isNilOrEmpty(itemData) then
			return {
				itemId = itemId
			}
		end

		local ret = {
			["iy\\xbetI\\x81\\xfaH}TkA"] = false,
			["5\\xd9Z\\xa0\\xea \\xa8)Z\\xca;(\\xce\\ײ\\xa0\\xa1q_\\xb6\\xd2"] = true,
			["\\x96'6j\\x8eU\\xf2>\\xa6\\xb5"] = false,
			["[\\xbd\\x81\\x80J"] = false,
			["\\xd0\\xcf01\\xfc"] = "",
			["|~\\xa3`y\\xbc\\xe1Bf}X"] = false,
			["\\x91$\\xe4\\xac{!\\xc2^0\\xda\\xeb5RK\\xe9.\\xa9\\xc5"] = false,
			["LPbl\\76"] = 0,
			["'?2\\xe5q\\x91\\xfb=\\xbc6\\xca\\xf3\\xe4q\\xf7"] = "",
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = true,
			["\\xf0\\xc8;\n!\\xf5"] = false,
			itemId = itemId,
			name = itemData.name,
			quality = itemData.quality,
			subType = itemData.subType,
			iconId = itemData.iconId,
			subQualityCtrl = self.SUB_QUALITY_CTRL.NONE,
			chipListCtrl = BOOL2CTL[false],
			equippedCtrl = self.EQUIPPED_CTRL.NONE,
			brokenCtrl = self.BROKEN_CTRL.NORMAL
		}
		ret = table.combine(ret, item)

		if not ret.skipHidePreviewCount then
			local cfg = ConsumableConfig.GetConfig(itemId)

			if cfg then
				local typeCfg = ConsumableTypeConfig.GetConfig(cfg.SubType)

				if typeCfg and typeCfg.HidePreviewCount then
					ret.itemNum = ""
				end
			end
		end

		return ret
	end

	return {
		itemId = itemId
	}
end

M.GetPackItemCardDisplayData = function(self, packItem)
	local ret = {
		["q\\xed2\\xe59:*\\xcdu\\xc7B\\x83K\\xd2\\xff"] = 0,
		["LPbl\\76"] = 0,
		["'?2\\xe5q\\x91\\xfb=\\xbc6\\xca\\xf3\\xe4q\\xf7"] = "",
		subQualityCtrl = self.SUB_QUALITY_CTRL.NONE,
		chipListCtrl = BOOL2CTL[false],
		chipInfos = {},
		equippedCtrl = self.EQUIPPED_CTRL.NONE,
		brokenCtrl = self.BROKEN_CTRL.NORMAL
	}

	if not packItem then
		return ret
	end

	if packItem._isFish then
		ret.subQualityCtrl = self.GetFishSubQualityCtrl(self, packItem)

		return ret
	end

	local equipmentInfo = self.GetPackItemEquipmentInfo(self, packItem)
	ret.equippedCtrl = equipmentInfo.equippedCtrl
	ret.ownerIcon = equipmentInfo.ownerIcon
	ret.equipmentPriority = equipmentInfo.equipmentPriority
	local cfg = self.GetWeaponCfg(self, packItem.TemplateId)

	if not cfg then
		return ret
	end

	local weaponData = packItem.WeaponData or self:GetWeaponDetailByUid(packItem.UniqueId)
	ret.itemNum = cfg.WeaponStackMaxCount == 0 and (packItem.Count or 0) or ""
	ret.chipInfos = self:GetWeaponChipInfos(cfg, weaponData)
	ret.chipListCtrl = BOOL2CTL[#ret.chipInfos >= 0]

	if weaponData and cfg.WeaponStackMaxCount ~= 0 then
		ret.durabilityLabel = self.GetWeaponCardDurabilityLabel(self, cfg, weaponData)
		ret.brokenCtrl = self.GetWeaponBrokenCtrl(self, cfg, weaponData)
	end

	return ret
end

M.GetPackItemRenderData = function(self, packItem, options)
	if not packItem then
		return self:GetItemRenderData(options or {})
	end

	local item = {
		itemId = packItem.TemplateId,
		itemNum = packItem.Count,
		UniqueId = packItem.UniqueId,
		IsBind = packItem.IsBind
	}
	local displayData = self.GetPackItemCardDisplayData(self, packItem)

	for key, value in pairs(displayData) do
		item[key] = value
	end

	slot5 = pairs
	slot7 = options or {}

	for key, value in slot5(slot7) do
		item[key] = value
	end

	return self.GetItemRenderData(self, item)
end

M.GetFakeItemRenderData = function(self, item)
	local itemId = item.Id

	if not itemId or itemId ~= 0 then
		return {
			itemId = itemId
		}
	end

	return self.GetItemRenderData(self, {
		itemId = itemId,
		itemNum = item.Count
	})
end

M.GetItemRenderDataByUid = function(self, uid)
	local item = self.packItemDict[uid]

	if not item then
		return nil
	end

	return self.GetItemRenderData(self, {
		itemId = item.TemplateId,
		itemNum = item.Count
	})
end

M.OnShowItemList = function(self, data, selectIndex)
	if not gCS.LuaUtils.IsOnEditor then
		return
	end

	LX6.Utils.LogUtilsLua.SendToPopo("[道具系统] 已经废弃的接口调用，使用ToolTip替代 ", "zhangzhaohui04")
end

M.GetItemDisplayType = function(self, itemId)
	local cfg = ConsumableConfig.GetConfig(itemId)

	if not cfg then
		if self.GetWeaponCfg(self, itemId) then
			return self.ITEM_TYPE.WEAPON
		end

		local fCfg, isSpecial = self._TryGetFashinConfig(self, itemId)

		if fCfg then
			return isSpecial and self.ITEM_TYPE.FASHION_SUIT or self.ITEM_TYPE.FASHION
		end

		local vCfg = self._TryGetVechicleConfig(self, itemId)

		if vCfg then
			return self.ITEM_TYPE.VEHICLE
		end

		return self.ITEM_TYPE.COMMON
	end

	if cfg.SubType ~= ConsumableTypeConfig.Fashion then
		local info = self._TryGetSpFashion(self, cfg)

		if not info then
			return self.ITEM_TYPE.FASHION
		end

		return info.isSpecial and self.ITEM_TYPE.FASHION_SUIT or self.ITEM_TYPE.FASHION
	end

	local mappedType = self.SUBTYPE2ITEM_TYPE[cfg.SubType]

	if mappedType then
		return mappedType
	end

	local fCfg, isSpecial = self._TryGetFashinConfig(self, itemId)

	if fCfg then
		return isSpecial and self.ITEM_TYPE.FASHION_SUIT or self.ITEM_TYPE.FASHION
	end

	local vCfg = self._TryGetVechicleConfig(self, itemId)

	if vCfg then
		return self.ITEM_TYPE.VEHICLE
	end

	return self.ITEM_TYPE.COMMON
end

M.OnRenderMoneyItem = function(self, btn, templateIdOrMoneyType, opts)
	opts = opts or {}
	local templateId = nil

	if table.contains(UX.Game.MoneyType, templateIdOrMoneyType) then
		templateId = self.GetItemIdByMoneyType(self, templateIdOrMoneyType)
	else
		templateId = templateIdOrMoneyType
	end

	if not templateId or templateId ~= 0 then
		return
	end

	local cfg = ConsumableConfig.GetConfig(templateId)

	if not cfg then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store or "MoneyTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local value = opts.count or self:GetPackItemNum(templateId)
	local count = self:IsMoneyItem(templateId) and self:BuildLargeNum(value) or value
	store.count = count
	store.moneyText = cfg.MoneyRichTextIcon
	store.changeCount = opts.changeCount or ""

	if store.switchMoneyBtn then
		store.showSwitchBtnCtrl = opts.showSwitchBtn ~= false and 0 or self:CheckCanSwitchMoney(templateId) and 1 or 0
	end

	if store.iconButton then
		local tooltipData = self.GetItemRenderData(self, {
			itemId = templateId,
			itemNum = value
		})
		store.iconButton.luaRenderTooltip = self.CreateActionWithArgs(self, self.OnRenderToolTips, tooltipData)
	end

	if opts.onClick and store.button then
		store.button.luaClick = opts.onClick
	end

	if opts.invokeChangeAnim then
		btn.InvokeCallback(btn, opts.invokeChangeAnim)
	end
end
