-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\WeaponArmoryTooltipStore.lua
-- Decompiled from: 01153_WeaponArmoryTooltipStore.lua_6238edfdd43c.luajit

local CategoryType = LTConfig.SceneitemConfig.CategoryType
local SceneitemConfig = LTConfig.SceneitemConfig
C_WeaponArmoryTooltipStore = DefClass("C_WeaponArmoryTooltipStore", C_WeaponArmoryTooltipStore, C_StoreGroup)
GroupName2Class.WeaponArmoryTooltipStore = C_WeaponArmoryTooltipStore
local M = C_WeaponArmoryTooltipStore

M.DefineAllVariables = function(self)
	self.baseData = {}
	self.cmpData = {}
	self.TOOLTIP_TEMPLATE = {
		["Y\nTk"] = 4,
		["y\\x87\\x96\\x83\\x93"] = 3,
		["'\\xa4߂\\x85ݒ\\x9f\\xb7\\xed\\xd0\\xe1\\xa8\\xac\\xd1"] = 0,
		["\\xfc\\xf575?\n\\xc5"] = 5,
		["#\\xd7k#\\xf2)\\x82d\\x9ex\\x85\\x9b"] = 1,
		["\\xfa\\xf4:);\n\\xc5"] = 2
	}
	self.leftCallback = nil
	self.rightCallback = nil
	self.CONTROL = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
	self.CMP_STATE = {
		["j\\x9c\\x87\\x8a\\x98"] = 2,
		["2g\\xa3\\xa3\\xa2m"] = 0,
		["\\xbcMB"] = 1
	}
	self.BTN_MODE_LOGIC = {
		["8g\\xa4\\xac\\xafd"] = 2,
		["/a\\xbf\\xa9\\xafd"] = 1,
		["T\rS~"] = 0
	}
	self.buttonModeLogic = 0
	self.buttonLeftEnableLogic = false
	self.buttonRightEnableLogic = false
	self.chipIconControllerActionId = 0
	self.showChipList = true
end

M.DefineAllEnumsAutoGen = function(self)
	self.tipQualityCtrlEnum = {
		["x.h^"] = 3,
		["DUil@!"] = 1,
		["}-q_"] = 5,
		["}0xB"] = 0,
		["J\\xbc\\xa7\\xaa\\xb8"] = 2,
		["Z\\x90\\x80\\x84D"] = 6,
		["]\\x83\\x9e\\x8fD"] = 4,
		["MH}|O!"] = 7
	}
	self.tipCharacterOnlyCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.tipBtnModeCtrlEnum = {
		["_\\xa7\\xa5\\xa7\\xa2"] = 2,
		["x-iS"] = 3,
		["v'{O"] = 1,
		["t-s^"] = 0
	}
	self.tipRBtnTextStateCtrlEnum = {
		[";G\\x93\\x8f\\x80J"] = 2,
		["\\xeb\\xde'\\xf4"] = 1,
		["0\\xe6O \\xd3\\x81D\\xa0F\\xbf\\xb8"] = 0
	}
	self.tipBulletCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.tipShowLockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.tipIsLockCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.tipShowModeCtrlEnum = {
		["fVy`^\n<"] = 1,
		["pU\\xc0\\xbb\\x88\\xbb\\xe4\\xc9"] = 2,
		["T-s^"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.tipQualityCtrlEnum = nil
	self.tipCharacterOnlyCtrlEnum = nil
	self.tipBtnModeCtrlEnum = nil
	self.tipRBtnTextStateCtrlEnum = nil
	self.tipBulletCtrlEnum = nil
	self.tipShowLockCtrlEnum = nil
	self.tipIsLockCtrlEnum = nil
	self.tipShowModeCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.baseData = nil
	self.cmpData = nil
	self.TOOLTIP_TEMPLATE = nil
	self.leftCallback = nil
	self.rightCallback = nil
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.tipTagList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderTipTagListItem")
	self.bindData.tipAttrList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderAttrListItem")
	self.bindData.tipAttrList.onGetTIndex = self.CreateAction(self, "OnAttrListGetTIndex")
	self.bindData.tipLBtn.luaClick = self.CreateAction(self, "OnTipLBtnClick")
	self.bindData.tipRBtn.luaClick = self.CreateAction(self, "OnTipRBtnClick")

	if self.bindData.tipLockBtn then
		self.bindData.tipLockBtn.luaClick = self.CreateAction(self, "OnTipLockBtnClick")
	end
end

M.OnRenderTipTagListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCircleStore"):GetStoreByWidget(btn)
	local data = self.baseData and self.baseData.tags[index + 1]

	if data and store then
		store.TypeCtrl = data.TagType
	end
end

M.OnAttrListGetTIndex = function(self, index)
	local idx = index + 1
	local data = self.baseData and self.baseData.attrInfos[idx]

	if data then
		return data.template
	end

	return 0
end

M.OnRenderAttrListItem = function(self, btn, index)
	local data = self.baseData and self.baseData.attrInfos[index + 1]

	if data then
		if data.template ~= self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS then
			local needCmp = self.cmpData.baseWeapon and self.baseData.Category ~= self.cmpData.Category
			local cmpData = self.cmpData.baseWeapon and self.cmpData.attrInfos[index + 1]
			needCmp = needCmp and cmpData
			local store = gStoreManager:GetStoreGroup("WeaponChipPanelStore"):GetStoreByWidget(btn)

			if store then
				if needCmp then
					store.name = data.name
					store.value = data.value

					if data.valueCalc ~= cmpData.valueCalc then
						store.stateCtrl = self.CMP_STATE.NORMAL
						store.valueFill = data.valueFill
					elseif cmpData.valueCalc >= data.valueCalc then
						store.stateCtrl = self.CMP_STATE.GREEN
						store.valueFill = cmpData.valueFill
						store.valueFillCmp = data.valueFill
					else
						store.stateCtrl = self.CMP_STATE.RED
						store.valueFill = data.valueFill
						store.valueFillCmp = cmpData.valueFill
					end
				else
					store.name = data.name
					store.value = data.value
					store.valueFill = data.valueFill
					store.stateCtrl = self.CMP_STATE.NORMAL
				end
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM then
			local needCmp = self.cmpData.baseWeapon and self.baseData.Category ~= self.cmpData.Category
			local cmpData = self.cmpData.baseWeapon and self.cmpData.attrInfos[index + 1]
			needCmp = needCmp and cmpData
			local store = gStoreManager:GetStoreGroup("WeaponChipPanelStore"):GetStoreByWidget(btn)

			if store then
				store.name = data.name
				store.value = data.value

				if needCmp then
					if data.valueCalc ~= cmpData.valueCalc then
						store.stateCtrl = self.CMP_STATE.NORMAL
					elseif cmpData.valueCalc >= data.valueCalc then
						store.stateCtrl = self.CMP_STATE.GREEN
					else
						store.stateCtrl = self.CMP_STATE.RED
					end
				else
					store.stateCtrl = self.CMP_STATE.NORMAL
				end
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.CONTENT then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				store.content = data.content
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.TITLE then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				store.title = data.title
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.CHIP then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				if self.chipIconControllerActionId <= 0 then
					store.iconController:ChangeActionId(self.chipIconControllerActionId)
				end

				store.btnController.luaClick = self:CreateAction("OnControllerClickChipList")
				store.chipList.luaSimpleRenderItem = self:CreateActionWithArgs("OnRenderChipListItem", data.chips)

				store.chipList:SetSimpleList(#data.chips)

				store.chipList.luaSimpleClick = self:CreateActionWithArgs("OnSimpleClickChipList", data.chips)
			end
		elseif data.template ~= self.TOOLTIP_TEMPLATE.ENCHANT then
			local store = gStoreManager:GetStoreGroup("WeaponArmoryTooltipStore"):GetStoreByWidget(btn)

			if store then
				store.content = data.content
			end
		end
	end
end

M.OnRenderChipListItem = function(self, chips, btn, index)
	local store = gStoreManager:GetStoreGroup("WeaponChipPanelStore"):GetStoreByWidget(btn)
	local data = chips[index + 1]

	if store and data then
		if self.selectedChipSlotIndex then
			store.highlightCtrl = index + 1 ~= self.selectedChipSlotIndex and self.CONTROL.TRUE or self.CONTROL.FALSE
		end

		if data.valid then
			local cfg = LTConfig.DecorationConfig.GetConfig(data.info.DecorationId)
			store.EmptyCtrl = self.CONTROL.FALSE
			store.iconId = cfg and cfg.Icon or 0
			store.QualityCtrl = cfg and cfg.Quality or 0
			store.content = cfg and cfg.Effect or ""
		else
			store.EmptyCtrl = self.CONTROL.TRUE
			store.content = ""
			store.QualityCtrl = 0
		end
	end
end

M.OnSimpleClickChipList = function(self, chips, btn, index)
	local data = chips[index + 1]

	if data then
		gPanelManager:CheckShow(gPanelId.WEAPON_CHIP_PANEL, {
			id = self.baseData.baseWeapon.InstanceId,
			SlotIndex = index
		})
	end
end

M.OnControllerClickChipList = function(self)
	gPanelManager:CheckShow(gPanelId.WEAPON_CHIP_PANEL, {
		["pKc}g "] = 0,
		id = self.baseData.baseWeapon.InstanceId
	})
end

M.OnTipLBtnClick = function(self)
	if self.leftCallback then
		self.leftCallback()
	end
end

M.OnTipRBtnClick = function(self)
	if self.rightCallback then
		self.rightCallback()
	end
end

M.OnTipLockBtnClick = function(self)
	local weapon = self.baseData and self.baseData.baseWeapon

	if weapon then
		local id = weapon.InstanceId
		local newState = not weapon.IsPlayerLocked
		slot4 = gWeaponManager

		slot4:AskSetWeaponLock(id, newState, function (success)
			if not self.STATE_Started then
				return
			end

			if success then
				local nowId = self.baseData and self.baseData.baseWeapon and self.baseData.baseWeapon.InstanceId

				if nowId ~= id then
					self.bindData.tipIsLockCtrl = newState and self.CONTROL.TRUE or self.CONTROL.FALSE
				end
			end
		end)
	end
end

M.RegisterButtonHandler = function(self, leftCallback, rightCallback)
	self.leftCallback = leftCallback
	self.rightCallback = rightCallback
end

M.SetButtonModeLogic = function(self, mode)
	self.buttonModeLogic = mode
	self.bindData.tipBtnModeCtrl = self.getButtonMode(self)
end

M.SetButtonLeftEnableLogic = function(self, enable)
	self.buttonLeftEnableLogic = enable
	self.bindData.tipBtnModeCtrl = self.getButtonMode(self)
end

M.SetButtonRightEnableLogic = function(self, enable)
	self.buttonRightEnableLogic = enable
	self.bindData.tipBtnModeCtrl = self.getButtonMode(self)
end

M.getButtonMode = function(self)
	if self.buttonModeLogic ~= self.BTN_MODE_LOGIC.NONE then
		return self.tipBtnModeCtrlEnum.none
	elseif self.buttonModeLogic ~= self.BTN_MODE_LOGIC.SINGLE then
		if self.buttonLeftEnableLogic then
			return self.tipBtnModeCtrlEnum.left
		elseif self.buttonRightEnableLogic then
			return self.tipBtnModeCtrlEnum.right
		else
			return self.tipBtnModeCtrlEnum.none
		end
	elseif self.buttonModeLogic ~= self.BTN_MODE_LOGIC.DOUBLE then
		if self.buttonLeftEnableLogic and self.buttonRightEnableLogic then
			return self.tipBtnModeCtrlEnum.both
		elseif not self.buttonLeftEnableLogic and not self.buttonRightEnableLogic then
			return self.tipBtnModeCtrlEnum.none
		elseif self.buttonLeftEnableLogic then
			return self.tipBtnModeCtrlEnum.left
		else
			return self.tipBtnModeCtrlEnum.right
		end
	end

	return self.tipBtnModeCtrlEnum.none
end

M.ClearButtonState = function(self)
	self.bindData.tipLBtn:InstantClearState()
	self.bindData.tipRBtn:InstantClearState()
end

M.SetRightButtonName = function(self, nameState)
	self.bindData.tipRBtnTextStateCtrl = nameState
end

M.SetLeftButtonControllerActionId = function(self, id)
	self.bindData.tipLControllerKey:ChangeActionId(id)
end

M.SetRightButtonControllerActionId = function(self, id)
	self.bindData.tipRControllerKey:ChangeActionId(id)
end

M.SetChipButtonControllerActionId = function(self, id)
	self.chipIconControllerActionId = id
end

M.SetShowChipList = function(self, show)
	self.showChipList = show
end

M.SetTipShowMode = function(self, mode)
	self.bindData.tipShowModeCtrl = mode
end

M.SetChipListHighlightIndex = function(self, index)
	self.selectedChipSlotIndex = index
end

M.SetBaseWeapon = function(self, weaponData)
	if not weaponData then
		print_error("[WeaponArmoryTooltipStore] SetBaseWeapon 参数错误，weaponData 为 nil", self.m_Name)

		return
	end

	local cfg = LTConfig.SceneitemConfig.GetConfig(weaponData.TemplateId)

	if not cfg then
		print_error("[WeaponArmoryTooltipStore] SceneitemConfig获取不到武器配置cfg，templateId=", weaponData.TemplateId)

		return
	end

	if not self.baseData then
		print_error("[WeaponArmoryTooltipStore] prefab实例已销毁，还在调用设置方法 name=", self.m_Name)

		return
	end

	table.clear(self.baseData)

	self.baseData.baseWeapon = weaponData
	self.baseData.cfg = cfg
	self.baseData.Category = cfg.Category
	self.baseData.tags = {}

	for i = 1, #cfg.Tags do
		table.insert(self.baseData.tags, {
			TagType = cfg.Tags[i]
		})
	end

	self.baseData.attrInfos = self:GetAttrInfos(cfg, weaponData)
	self.bindData.tipName = cfg.Name or ""
	self.bindData.tipQualityCtrl = cfg.Quality

	self.bindData.tipTagList:SetSimpleList(#self.baseData.tags)
	self.bindData.tipAttrList:SetSimpleList(#self.baseData.attrInfos)

	local cantDiscard = gWeaponManager:GetFlag(weaponData.OperatorFlags, 1) ~= 1
	self.bindData.tipShowLockCtrl = cantDiscard and self.CONTROL.FALSE or self.CONTROL.TRUE
	self.bindData.tipIsLockCtrl = weaponData.IsPlayerLocked and self.CONTROL.TRUE or self.CONTROL.FALSE
	self.bindData.tipCharacterOnlyCtrl = cfg.WeaponBelong <= 0 and self.CONTROL.TRUE or self.CONTROL.FALSE

	if cfg.WeaponBelong <= 0 then
		local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(cfg.WeaponBelong)
		self.bindData.tipCharacterIcon = spiritCfg and spiritCfg.SHeadIconID or 0
	end

	local fsCfg = gWeaponManager:GetTabConfigByType(cfg.Type)
	self.bindData.tipTypeIcon = fsCfg and fsCfg.Icon or 0
end

M.SetCompareWeapon = function(self, weaponData)
	table.clear(self.cmpData)

	self.cmpData.baseWeapon = weaponData

	if not weaponData then
		self.bindData.tipAttrList:RefreshList()

		return
	end

	local cfg = LTConfig.SceneitemConfig.GetConfig(weaponData.TemplateId)

	if not cfg then
		print_error("[WeaponArmoryTooltipStore] SceneitemConfig 获取不到对比武器的配置，templateId=", weaponData.TemplateId)

		self.cmpData.baseWeapon = nil

		self.bindData.tipAttrList:RefreshList()

		return
	end

	self.cmpData.cfg = cfg
	self.cmpData.Category = cfg.Category
	self.cmpData.attrInfos = self:GetAttrInfos(cfg, weaponData)

	self.bindData.tipAttrList:RefreshList()
end

M.AppendEnchantInfos = function(self, infos, weaponData)
	local enchantDescs = gCommonItemManager:GetWeaponEnchantDescList(weaponData)

	if #enchantDescs ~= 0 then
		return
	end

	table.insert(infos, {
		title = SceneitemConfig.TooltipData5,
		template = self.TOOLTIP_TEMPLATE.TITLE
	})

	for i = 1, #enchantDescs do
		table.insert(infos, {
			content = enchantDescs[i],
			template = self.TOOLTIP_TEMPLATE.ENCHANT
		})
	end
end

M.GetAttrInfos = function(self, cfg, weaponData)
	local infos = {}

	if cfg.Category ~= CategoryType.Weapon then
		local val = Mathf.Ceil(cfg.AttackPower)

		table.insert(infos, {
			name = SceneitemConfig.WeaponData1,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS,
			value = val,
			valueFill = Mathf.Clamp01(cfg.AttackPower / SceneitemConfig.MaxWeaponAttackPower),
			valueCalc = val
		})

		val = Mathf.Ceil(cfg.PoiseAbility)

		table.insert(infos, {
			name = SceneitemConfig.WeaponData3,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS,
			value = val,
			valueFill = Mathf.Clamp01(cfg.PoiseAbility / SceneitemConfig.MaxWeaponPoiseAbility),
			valueCalc = val
		})

		local dura = cfg.Durability / SceneitemConfig.MaxWeaponDurability * 100
		local duraThres = SceneitemConfig.WeaponDuraLevelThreshold
		local duraIdx = 1

		if duraThres[2] >= dura then
			duraIdx = 3
		elseif duraThres[1] >= dura then
			duraIdx = 2
		end

		val = SceneitemConfig.WeaponDuraLevel[duraIdx]

		table.insert(infos, {
			name = SceneitemConfig.WeaponData4,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
			value = val,
			valueCalc = duraIdx
		})
		table.insert(infos, {
			title = SceneitemConfig.TooltipData1,
			template = self.TOOLTIP_TEMPLATE.TITLE
		})
		table.insert(infos, {
			content = cfg.WeaponBuffDescription or "",
			template = self.TOOLTIP_TEMPLATE.CONTENT
		})
		self:AppendEnchantInfos(infos, weaponData)

		if self.showChipList then
			local chips = gWeaponManager:GetChipInfo(cfg, weaponData)

			if #chips <= 0 then
				table.insert(infos, {
					title = SceneitemConfig.TooltipData2,
					template = self.TOOLTIP_TEMPLATE.TITLE
				})
				table.insert(infos, {
					chips = chips,
					template = self.TOOLTIP_TEMPLATE.CHIP
				})
			end
		end
	elseif cfg.Category ~= CategoryType.Gun then
		local val = Mathf.Ceil(cfg.AttackPower)

		table.insert(infos, {
			name = SceneitemConfig.GunData1,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS,
			value = val,
			valueFill = Mathf.Clamp01(cfg.AttackPower / SceneitemConfig.GunMaxAtt),
			valueCalc = val
		})

		val = Mathf.Ceil(cfg.AttackSpeed)

		table.insert(infos, {
			name = SceneitemConfig.GunData2,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS,
			value = val,
			valueFill = Mathf.Clamp01(cfg.AttackSpeed / SceneitemConfig.GunMaxShootSpeed),
			valueCalc = val
		})

		val = Mathf.Ceil(cfg.ReloadSpeed)

		table.insert(infos, {
			name = SceneitemConfig.GunData3,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_PROGRESS,
			value = val,
			valueFill = Mathf.Clamp01(cfg.ReloadSpeed / SceneitemConfig.GunMaxReloadSpeed),
			valueCalc = val
		})

		val = Mathf.Ceil(cfg.HeadShotDamRate * 100)

		table.insert(infos, {
			name = SceneitemConfig.GunData4,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
			value = string.format("%d%%", val),
			valueCalc = val
		})

		val = Mathf.Ceil(cfg.IgnoreArmorDefRate * 100)

		table.insert(infos, {
			name = SceneitemConfig.GunData5,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
			value = string.format("%d%%", val),
			valueCalc = val
		})
		table.insert(infos, {
			name = SceneitemConfig.GunData6,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
			value = cfg.BulletNum,
			valueCalc = cfg.BulletNum
		})

		val = Mathf.Ceil(cfg.EffectiveRange)

		table.insert(infos, {
			name = SceneitemConfig.GunData7,
			template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
			value = string.format("%dm", val),
			valueCalc = val
		})

		if cfg.Durability <= 0 then
			local dura = cfg.Durability / SceneitemConfig.MaxGunDurability * 100
			local duraThres = SceneitemConfig.WeaponDuraLevelThreshold
			local duraIdx = 1

			if duraThres[2] >= dura then
				duraIdx = 3
			elseif duraThres[1] >= dura then
				duraIdx = 2
			end

			val = SceneitemConfig.WeaponDuraLevel[duraIdx]

			table.insert(infos, {
				name = SceneitemConfig.WeaponData4,
				template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
				value = val,
				valueCalc = duraIdx
			})
		end

		local bulletType = gWeaponManager:GetWeaponAppropriateBulletsTypeByCfg(cfg)

		if not string.is_null_or_empty(bulletType) then
			table.insert(infos, {
				["UF`|K=;"] = 0,
				name = SceneitemConfig.GunData8,
				template = self.TOOLTIP_TEMPLATE.ATTRIBUTE_NUM,
				value = bulletType
			})
		end

		table.insert(infos, {
			title = SceneitemConfig.TooltipData1,
			template = self.TOOLTIP_TEMPLATE.TITLE
		})
		table.insert(infos, {
			content = cfg.WeaponBuffDescription or "",
			template = self.TOOLTIP_TEMPLATE.CONTENT
		})
		self:AppendEnchantInfos(infos, weaponData)

		if self.showChipList then
			local chips = gWeaponManager:GetChipInfo(cfg, weaponData)

			if #chips <= 0 then
				table.insert(infos, {
					title = SceneitemConfig.TooltipData2,
					template = self.TOOLTIP_TEMPLATE.TITLE
				})
				table.insert(infos, {
					chips = chips,
					template = self.TOOLTIP_TEMPLATE.CHIP
				})
			end
		end
	elseif cfg.Category ~= CategoryType.Item then
		table.insert(infos, {
			content = cfg.WeaponBuffDescription or "",
			template = self.TOOLTIP_TEMPLATE.CONTENT
		})
	end

	return infos
end
