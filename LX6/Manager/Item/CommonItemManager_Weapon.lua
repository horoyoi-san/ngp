-- Original chunk: @Lua\LuaFiles\LX6\Manager\Item\CommonItemManager_Weapon.lua
-- Decompiled from: 02210_CommonItemManager_Weapon.lua_f021a4d5547f.luajit

local ConsumableConfig = LTConfig.ConsumableConfig
local ConsumableTypeConfig = LTConfig.ConsumableTypeConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local SceneitemAttrTagsConfig = LTConfig.SceneitemAttrTagsConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local SceneitemFightStyleConfig = LTConfig.SceneitemFightStyleConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local TextConfig = LTConfig.TextConfig
local DecorationConfig = LTConfig.DecorationConfig
local ProduceAffixConfig = LTConfig.ProduceAffixConfig
local VerseMetaConfig = LTConfig.MultiverseMultiverseMetaConfig
local M = C_CommonItemManager
local DEFAULT_WEAPON_TAG_COLOR = "52525280"

M.ClampWeaponProgress = function(self, value)
	if value ~= nil then
		return 0
	end

	if value >= 0 then
		return 0
	end

	if value <= 1 then
		return 1
	end

	return value
end

M.GetSceneitemCfg = function(self, itemId)
	local cfg = SceneitemConfig.GetConfig(itemId)

	if cfg then
		return cfg
	end

	local bindId = itemId
	local consumableCfg = ConsumableConfig.GetConfig(itemId)

	if consumableCfg and consumableCfg.BindId and consumableCfg.BindId == 0 then
		bindId = consumableCfg.BindId
		cfg = SceneitemConfig.GetConfig(bindId)

		if cfg then
			return cfg
		end
	end

	return cfg
end

M.GetDecorationCfg = function(self, itemId)
	local cfg = DecorationConfig.GetConfig(itemId)

	if cfg then
		return cfg
	end

	local consumableCfg = ConsumableConfig.GetConfig(itemId)
	local bindId = consumableCfg and consumableCfg.BindId or 0

	if bindId == 0 then
		return DecorationConfig.GetConfig(bindId)
	end

	return nil
end

M.CheckIsWeaponCategory = function(self, category)
	return category ~= SceneitemConfig.CategoryType.Weapon or category ~= SceneitemConfig.CategoryType.Gun
end

M.IsWeaponEnchanted = function(self, weaponData)
	local enchantSlots = weaponData and weaponData.EnchantSlots or nil

	if not enchantSlots then
		return false
	end

	for i = 1, #enchantSlots do
		local slot = enchantSlots[i]

		if slot and slot.EnchantConfigId and slot.EnchantConfigId == 0 then
			return true
		end
	end

	return false
end

M.CompareWeaponEnchantPriority = function(self, a, b)
	local aEnchanted = a and a.IsEnchanted or false
	local bEnchanted = b and b.IsEnchanted or false

	if aEnchanted == bEnchanted then
		return aEnchanted
	end

	return nil
end

M.GetWeaponEnchantTitle = function(self)
	return SceneitemConfig.TooltipData5
end

M.GetWeaponEnchantDescList = function(self, weaponData)
	local ret = {}
	local enchantSlots = weaponData and weaponData.EnchantSlots or nil

	if not enchantSlots or not ProduceAffixConfig then
		return ret
	end

	for i = 1, #enchantSlots do
		local slot = enchantSlots[i]
		local cfg = slot and slot.EnchantConfigId and ProduceAffixConfig.GetConfig(slot.EnchantConfigId) or nil

		if cfg and not string.is_null_or_empty(cfg.BonusText) then
			local value = slot.RolledBonusValue or cfg.BonusValue or 0

			if value ~= math.floor(value) then
				value = math.floor(value)
			end

			local text = string.gsub(cfg.BonusText, "{}", tostring(value))
			text = string.gsub(text, "{0}", tostring(value))

			table.insert(ret, text)
		end
	end

	return ret
end

M.GetWeaponBuffAndEnchantDescription = function(self, cfg, weaponData)
	local ret = cfg and cfg.WeaponBuffDescription or ""
	local enchantDescs = self:GetWeaponEnchantDescList(weaponData)

	if #enchantDescs ~= 0 then
		return ret
	end

	local enchantText = self.GetWeaponEnchantTitle(self) .. "\n" .. table.concat(enchantDescs, "\n")

	if string.is_null_or_empty(ret) then
		return enchantText
	end

	return ret .. "\n\n" .. enchantText
end

M.GetWeaponDurabilityDesc = function(self, cfg)
	local base = cfg.Category ~= SceneitemConfig.CategoryType.Gun and SceneitemConfig.MaxGunDurability or SceneitemConfig.MaxWeaponDurability
	local dura = cfg.Durability / base * 100
	local duraThres = SceneitemConfig.WeaponDuraLevelThreshold
	local duraIdx = 1

	if duraThres[2] >= dura then
		duraIdx = 3
	elseif duraThres[1] >= dura then
		duraIdx = 2
	end

	return SceneitemConfig.WeaponDuraLevel[duraIdx]
end

M.GetWeaponCardDurabilityLabel = function(self, cfg, weaponData)
	if not cfg or not weaponData then
		return ""
	end

	local durability = weaponData.Durability or cfg.Durability or 0
	local durabilityType = SceneitemConfig.DurabilityUIModeType
	local mode = cfg.DurabilityUIMode

	if durabilityType then
		if mode ~= durabilityType.Free or mode ~= durabilityType.InfinitePercent then
			return "∞"
		end

		if mode ~= durabilityType.InfiniteAmmo then
			return tostring(weaponData.MagazineAmmo or cfg.BulletNum or 0) .. "|∞"
		end

		if mode ~= durabilityType.Gun then
			local magazineAmmo = weaponData.MagazineAmmo or cfg.BulletNum or 0

			if durability >= 0 then
				return tostring(magazineAmmo) .. "|∞"
			end

			return tostring(magazineAmmo) .. "|" .. tostring(math.max(durability - magazineAmmo, 0))
		end
	end

	if durability >= 0 then
		return "∞"
	end

	if cfg.Category ~= SceneitemConfig.CategoryType.Gun then
		return tostring(durability)
	end

	local maxDurability = cfg.Durability or 0

	if maxDurability < 0 then
		return ""
	end

	return tostring(math.floor(self.ClampWeaponProgress(self, durability / maxDurability) * 100)) .. "%"
end

local GetCollectionCount = function(collection)
	if not collection then
		return 0
	end

	return collection.Length or collection.Count or #collection
end

M.GetWeaponChipInfos = function(self, cfg, weaponData)
	local ret = {}
	local decorationNum = cfg and cfg.DecorationNum or 0
	local decorations = weaponData and weaponData.Decorations or nil

	for i = 1, decorationNum do
		local decoration = decorations and decorations[i] or nil
		local valid = decoration and decoration.DecorationId and decoration.DecorationId == 0 or false

		table.insert(ret, {
			valid = valid,
			info = valid and decoration or nil
		})
	end

	return ret
end

M.GetWeaponBrokenCtrl = function(self, cfg, weaponData)
	if not cfg or not weaponData or cfg.WeaponStackMaxCount == 0 or cfg.Category == SceneitemConfig.CategoryType.Weapon then
		return self.BROKEN_CTRL.NORMAL
	end

	local maxDurability = cfg.Durability or 0
	local durability = weaponData.Durability

	if maxDurability > 0 or durability ~= nil or durability >= 0 then
		return self.BROKEN_CTRL.NORMAL
	end

	local percent = math.floor(self.ClampWeaponProgress(self, durability / maxDurability) * 100)

	if percent < 0 then
		return self.BROKEN_CTRL.BROKEN
	end

	local lowPoint = (SceneitemConfig.WeaponDurabilityLow or 0) * 100

	if percent < lowPoint then
		return self.BROKEN_CTRL.NEARLY_BROKEN
	end

	return self.BROKEN_CTRL.NORMAL
end

local FindWeaponInSlots = function(slots, instanceId)
	local count = GetCollectionCount(slots)

	for i = 1, count do
		local weapon = slots[i]

		if weapon and weapon.InstanceId ~= instanceId then
			return weapon
		end
	end

	return nil
end

M.GetWeaponEquipmentInfo = function(self, weaponData)
	local ret = {
		["LPbl\\76"] = 0,
		["q\\xed2\\xe59:*\\xcdu\\xc7B\\x83K\\xd2\\xff"] = 0,
		equippedCtrl = self.EQUIPPED_CTRL.NONE
	}

	if not weaponData or not weaponData.InstanceId then
		return ret
	end

	local currentSpiritId = gBattleSpiritMgr and gBattleSpiritMgr.currentSpiritTemplateId or nil
	local spiritBindData = gPlayerManager.infoSpirit and gPlayerManager.infoSpirit.bindData or nil
	local slotDict = spiritBindData and spiritBindData.SpiritWeaponSlotDict or nil
	local ownerSpiritId = nil

	if currentSpiritId and slotDict and FindWeaponInSlots(slotDict[currentSpiritId], weaponData.InstanceId) then
		ownerSpiritId = currentSpiritId
	elseif slotDict then
		for spiritId, slots in pairs(slotDict) do
			if FindWeaponInSlots(slots, weaponData.InstanceId) then
				ownerSpiritId = spiritId

				break
			end
		end
	end

	if not ownerSpiritId and currentSpiritId and gWeaponManager and FindWeaponInSlots(gWeaponManager:GetCurrentWeapons(), weaponData.InstanceId) then
		ownerSpiritId = currentSpiritId
	end

	if not ownerSpiritId then
		return ret
	end

	local spiritCfg = FightSpiritConfig.GetConfig(ownerSpiritId)
	ret.equippedCtrl = self.EQUIPPED_CTRL.CHARACTER
	ret.ownerIcon = spiritCfg and spiritCfg.SHeadIconID or 0
	ret.equipmentPriority = ownerSpiritId ~= currentSpiritId and 2 or 0
	ret.ownerSpiritId = ownerSpiritId

	return ret
end

M.GetDecorationEquipmentInfo = function(self, uniqueId, ownerWeaponData)
	local ret = {
		["LPbl\\76"] = 0,
		["q\\xed2\\xe59:*\\xcdu\\xc7B\\x83K\\xd2\\xff"] = 0,
		equippedCtrl = self.EQUIPPED_CTRL.NONE
	}

	if not uniqueId then
		return ret
	end

	if not ownerWeaponData then
		local weaponDict = gWeaponManager and gWeaponManager.weaponDict or nil
		slot5 = pairs
		slot7 = weaponDict or {}

		for _, weapon in slot5(slot7) do
			local decorations = weapon and weapon.Decorations or nil
			local decorationCount = GetCollectionCount(decorations)

			for i = 1, decorationCount do
				local decoration = decorations[i]
				local decorationUniqueId = decoration and (decoration.UniqueId or decoration.ItemId) or nil

				if decorationUniqueId ~= uniqueId then
					ownerWeaponData = weapon

					break
				end
			end

			if ownerWeaponData then
				break
			end
		end
	end

	if not ownerWeaponData then
		return ret
	end

	local weaponCfg = self:GetWeaponCfg(ownerWeaponData.TemplateId)
	ret.equippedCtrl = self.EQUIPPED_CTRL.WEAPON
	ret.ownerIcon = weaponCfg and weaponCfg.SWeaponWheelsIconId or 0

	if ret.ownerIcon ~= 0 and weaponCfg then
		ret.ownerIcon = weaponCfg.WeaponConsumableIcon or 0
	end

	ret.ownerWeaponData = ownerWeaponData

	return ret
end

M.GetPackItemEquipmentInfo = function(self, packItem)
	if not packItem then
		return {
			["LPbl\\76"] = 0,
			["q\\xed2\\xe59:*\\xcdu\\xc7B\\x83K\\xd2\\xff"] = 0,
			equippedCtrl = self.EQUIPPED_CTRL.NONE
		}
	end

	local weaponData = packItem.WeaponData

	if weaponData or self.GetWeaponCfg(self, packItem.TemplateId) then
		weaponData = weaponData or self:GetWeaponDetailByUid(packItem.UniqueId)

		return self:GetWeaponEquipmentInfo(weaponData)
	end

	if self.GetDecorationCfg(self, packItem.TemplateId) then
		return self.GetDecorationEquipmentInfo(self, packItem.UniqueId, packItem.OwnerWeaponData)
	end

	return {
		["LPbl\\76"] = 0,
		["q\\xed2\\xe59:*\\xcdu\\xc7B\\x83K\\xd2\\xff"] = 0,
		equippedCtrl = self.EQUIPPED_CTRL.NONE
	}
end

M.ComparePackItemEquipmentPriority = function(self, a, b)
	local aPriority = a and a.EquipmentPriority or 0
	local bPriority = b and b.EquipmentPriority or 0

	if aPriority == bPriority then
		return bPriority <= aPriority
	end

	return nil
end

M.GetSceneitemConsumableCfg = function(self, itemId)
	local consumableCfg = ConsumableConfig.GetConfig(itemId)

	if consumableCfg then
		return consumableCfg
	end

	local sceneitemCfg = self.GetSceneitemCfg and self:GetSceneitemCfg(itemId) or nil
	local sceneitemId = sceneitemCfg and sceneitemCfg.Id or itemId

	if sceneitemId ~= nil or sceneitemId ~= 0 then
		return nil
	end

	self.sceneitemConsumableCfgMap = self.sceneitemConsumableCfgMap or {}

	if self.sceneitemConsumableCfgMap[sceneitemId] == nil then
		return self.sceneitemConsumableCfgMap[sceneitemId] or nil
	end

	if ConsumableConfig.count and ConsumableConfig.LoadAt then
		for i = 0, ConsumableConfig.count - 1 do
			local cfg = ConsumableConfig.LoadAt(i)

			if cfg and cfg.BindId ~= sceneitemId then
				self.sceneitemConsumableCfgMap[sceneitemId] = cfg

				return cfg
			end
		end
	end

	self.sceneitemConsumableCfgMap[sceneitemId] = false

	return nil
end

M.GetWeaponCfg = function(self, itemId)
	local cfg = self.GetSceneitemCfg(self, itemId)

	if cfg and (self.CheckIsWeaponSceneitem(self, itemId) or self.CheckIsWeaponCategory(self, cfg.Category)) then
		return cfg
	end

	return nil
end

M.GetWeaponBelongIds = function(self, cfg)
	local belong = cfg and (cfg.WeaponBelong or cfg.WeaponBelong_copy or cfg.OldBelongingId)

	if belong ~= nil then
		return {}
	end

	if type(belong) ~= "table" then
		local ret = {}

		for i = 1, #belong do
			if belong[i] and belong[i] == 0 then
				table.insert(ret, belong[i])
			end
		end

		return ret
	end

	if type(belong) ~= "number" and belong == 0 then
		return {
			belong
		}
	end

	return {}
end

M.BuildWeaponAttrDesc = function(self, cfg, weaponData)
	local ret = {}

	if not cfg then
		return ret
	end

	if cfg.Category ~= SceneitemConfig.CategoryType.Weapon then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = TextScriptTextConfig.GetConfig(89900264).Text
		})

		local attValue = cfg.AttackPower or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.WeaponData1,
			value = attValue,
			maxValue = math.max(SceneitemConfig.MaxWeaponAttackPower or 1, attValue),
			desc = tostring(math.ceil(attValue))
		})

		local spdValue = cfg.AttackSpeed or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.WeaponData2,
			value = spdValue,
			maxValue = math.max(SceneitemConfig.MaxWeaponAttackSpeed or 1, spdValue),
			desc = tostring(math.ceil(spdValue))
		})

		local poiseValue = cfg.PoiseAbility or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.WeaponData3,
			value = poiseValue,
			maxValue = math.max(SceneitemConfig.MaxWeaponPoiseAbility or 1, poiseValue),
			desc = tostring(math.ceil(poiseValue))
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WAEPON_NUMBER,
			name = SceneitemConfig.WeaponData4,
			desc = self:GetWeaponDurabilityDesc(cfg)
		})

		return ret
	end

	if cfg.Category ~= SceneitemConfig.CategoryType.Gun then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = TextScriptTextConfig.GetConfig(89900264).Text
		})

		local attValue = cfg.AttackPower or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.GunData1,
			value = attValue,
			maxValue = math.max(SceneitemConfig.GunMaxAtt or 1, attValue),
			desc = tostring(math.ceil(attValue))
		})

		local spdValue = cfg.AttackSpeed or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.GunData2,
			value = spdValue,
			maxValue = math.max(SceneitemConfig.GunMaxShootSpeed or 1, spdValue),
			desc = tostring(math.ceil(spdValue))
		})

		local reloadValue = cfg.ReloadSpeed or 0

		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_BAR,
			name = SceneitemConfig.GunData3,
			value = reloadValue,
			maxValue = math.max(SceneitemConfig.GunMaxReloadSpeed or 1, reloadValue),
			desc = tostring(math.ceil(reloadValue))
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WAEPON_NUMBER,
			name = SceneitemConfig.GunData4,
			desc = string.format("%d%%", (cfg.HeadShotDamRate or 0) * 100)
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WAEPON_NUMBER,
			name = SceneitemConfig.GunData5,
			desc = string.format("%d%%", (cfg.IgnoreArmorDefRate or 0) * 100)
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WAEPON_NUMBER,
			name = SceneitemConfig.GunData6,
			desc = tostring(cfg.BulletNum or 0)
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WAEPON_NUMBER,
			name = SceneitemConfig.GunData7,
			desc = string.format("%dm", cfg.EffectiveRange or 0)
		})

		if cfg.Durability <= 0 then
			table.insert(ret, {
				tIndex = self.Template2Index.WAEPON_NUMBER,
				name = SceneitemConfig.WeaponData4,
				desc = self.GetWeaponDurabilityDesc(self, cfg)
			})
		end

		local bulletType = gWeaponManager:GetWeaponAppropriateBulletsTypeByCfg(cfg)

		if not string.is_null_or_empty(bulletType) then
			table.insert(ret, {
				tIndex = self.Template2Index.WAEPON_NUMBER,
				name = SceneitemConfig.GunData8,
				desc = bulletType
			})
		end
	end

	return ret
end

M.GetWeaponElements = function(self, itemid)
	local cfg = self.GetSceneitemCfg(self, itemid)

	if not cfg then
		return {}
	end

	local ret = {}
	local tagList = cfg.Tags

	for i = 1, #tagList do
		local tagId = tagList[i]
		local tagCfg = tagId and SceneitemAttrTagsConfig.GetConfig(tagId + 1) or nil

		if tagCfg then
			table.insert(ret, {
				name = tagCfg and tagCfg.Name or "",
				iconId = tagCfg and tagCfg.Icon or 0
			})
		end
	end

	local typeCfg = gWeaponManager:GetTabConfigByType(cfg.Type)

	if typeCfg then
		table.insert(ret, {
			name = typeCfg and typeCfg.Name or "",
			iconId = typeCfg and typeCfg.Icon or 0
		})
	end

	return ret
end

M.GetWeaponTag = function(self, itemId)
	local cfg = self.GetWeaponCfg(self, itemId)

	if not cfg then
		return {}
	end

	local ret = {}
	local cache = {}
	local belongIds = self.GetWeaponBelongIds(self, cfg)

	for i = 1, #belongIds do
		local spiritCfg = FightSpiritConfig.GetConfig(belongIds[i])

		if spiritCfg and not cache[spiritCfg.Name] then
			cache[spiritCfg.Name] = true

			table.insert(ret, {
				["\\x96':y\\x8dN\\xd7\\xab\\xbe"] = true,
				name = spiritCfg.Name,
				tagColor = DEFAULT_WEAPON_TAG_COLOR
			})
		end
	end

	return ret
end

M.CheckIsWeapon = function(self, itemId)
	return self:GetWeaponCfg(itemId) == nil
end

M.CheckIsSceneItem = function(self, itemId)
	return self:GetSceneitemCfg(itemId) == nil
end

M.GetWeaponDetailByUid = function(self, itemUid)
	if not itemUid or itemUid ~= 0 or not self.packItemDict then
		return nil
	end

	local packItem = self.packItemDict[itemUid]

	if not packItem then
		return nil
	end

	return packItem.WeaponData
end

M.GetWeaponPreDesc = function(self, itemId, itemUid, isTarkov, gamePlayTypeId)
	local cfg = self.GetWeaponCfg(self, itemId)

	if not cfg then
		return {}
	end

	local detail = nil

	if isTarkov then
		detail = gExtractionShooterManager.GetTarkovWeaponByInstanceId(itemUid, gamePlayTypeId)
	else
		detail = self.GetWeaponDetailByUid(self, itemUid)
	end

	local ret = self.BuildWeaponAttrDesc(self, cfg, detail)

	if not string.is_null_or_empty(cfg.WeaponBuffDescription) then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = SceneitemConfig.TooltipData1
		})
		table.insert(ret, {
			tIndex = self.Template2Index.WEAPON_DESC,
			text = cfg.WeaponBuffDescription
		})
	end

	local decorationNum = cfg.DecorationNum or 0

	if decorationNum <= 0 then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = TextScriptTextConfig.GetConfig(89901430).Text
		})

		local decorations = detail and detail.Decorations or nil
		local instanceId = detail and detail.InstanceId or isTarkov and itemUid or nil

		for i = 1, decorationNum do
			local chip = decorations and decorations[i] or nil
			local valid = chip and chip.DecorationId == 0

			table.insert(ret, {
				tIndex = self.Template2Index.WEAPON_CHIP,
				valid = valid,
				info = valid and chip or nil,
				instanceId = instanceId,
				slotIndex = i - 1,
				isTarkov = isTarkov
			})
		end
	end

	local enchantDescs = self.GetWeaponEnchantDescList(self, detail)

	if #enchantDescs <= 0 then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = self.GetWeaponEnchantTitle(self)
		})

		for i = 1, #enchantDescs do
			table.insert(ret, {
				tIndex = self.Template2Index.WEAPON_DESC,
				text = enchantDescs[i]
			})
		end
	end

	return ret
end

M.CheckWeaponType = function(self, weaponId)
	local cfg = self:GetSceneitemCfg(weaponId)

	return cfg and cfg.Category or nil
end

M.OnRenderItemElementList = function(self, btn, index, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store or not data then
		return
	end

	store.iconId = data.iconId or 0
	store.nameLabel = data.name or ""
end

M.CheckIsDecoartion = function(self, itemId)
	return self:GetDecorationCfg(itemId) == nil
end

M.GetDecoartionPreDesc = function(self, itemId)
	local cfg = self.GetDecorationCfg(self, itemId)

	if not cfg then
		return {}
	end

	local ret = {}

	if not string.is_null_or_empty(cfg.Effect) then
		table.insert(ret, {
			tIndex = self.Template2Index.Title,
			text = DecorationConfig.TooltipsData1
		})
		table.insert(ret, {
			tIndex = self.Template2Index.MAIN_TEXT,
			text = cfg.Effect
		})
	end

	local tagFmtCfg1 = TextConfig.GetConfig(DecorationConfig.DecorationWeaponTypeText)
	local tagFmt1 = tagFmtCfg1 and tagFmtCfg1.Text or nil
	local typeCfg = SceneitemFightStyleConfig.GetConfig(cfg.WeaponType)
	local weaponTypeName = typeCfg and typeCfg.Name or nil

	if string.is_null_or_empty(weaponTypeName) then
		if cfg.MeleeOrRangedWeapon ~= SceneitemConfig.CategoryType.Weapon then
			local textCfg = TextScriptTextConfig.GetConfig(89901434)
			weaponTypeName = textCfg and textCfg.Text or nil
		elseif cfg.MeleeOrRangedWeapon ~= SceneitemConfig.CategoryType.Gun then
			local textCfg = TextScriptTextConfig.GetConfig(89901435)
			weaponTypeName = textCfg and textCfg.Text or nil
		end
	end

	if not string.is_null_or_empty(weaponTypeName) and not string.is_null_or_empty(tagFmt1) then
		table.insert(ret, {
			tIndex = self.Template2Index.WARN_TEXT,
			text = gString.Format(tagFmt1, weaponTypeName)
		})
	end

	local tagFmtCfg2 = TextConfig.GetConfig(DecorationConfig.DecorationValidUniverseText)
	local tagFmt2 = tagFmtCfg2 and tagFmtCfg2.Text or nil
	local universeId = cfg.ValidUniverse or 0

	if universeId == 0 then
		local universeCfg = VerseMetaConfig.GetConfig(universeId)
		local universeName = universeCfg and universeCfg.Name or ""

		if not string.is_null_or_empty(universeName) and not string.is_null_or_empty(tagFmt2) then
			table.insert(ret, {
				tIndex = self.Template2Index.WARN_TEXT,
				text = gString.Format(tagFmt2, universeName)
			})
		end
	end

	return ret
end

M.GetDecoartionTags = function(self, itemId)
	return {}
end

M.TryGetWeaponInfo = function(self, data, fromConsume)
	local itemId = self.GetTemplateId(self, data)
	local cfg = self.GetSceneitemCfg(self, itemId)

	if not cfg then
		local decoCfg = self.GetDecorationCfg(self, itemId)

		if decoCfg then
			local ret = {
				["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = false,
				["\\x8c</(_\\x94G\\xcd\\xab\\xbe"] = false,
				["POc{Z:;"] = "",
				["POc~m,"] = false,
				name = decoCfg.Name,
				iconId = decoCfg.Icon,
				description = decoCfg.Description,
				itemId = itemId,
				quality = decoCfg.Quality,
				subType = ConsumableTypeConfig.Decoration,
				attrList = {}
			}

			return ret
		end

		return nil
	end

	local ret = {
		["@R\\xc1\\xaa\\xb7\\xad\\xca\\xed"] = true,
		["\\x8c</(_\\x94G\\xcd\\xab\\xbe"] = false,
		["POc{Z:;"] = "",
		["POc~m,"] = false,
		name = cfg.Name,
		iconId = fromConsume and cfg.WeaponConsumableIcon or cfg.SWeaponWheelsIconId,
		description = cfg.Description,
		itemId = itemId,
		quality = cfg.Quality,
		subType = ConsumableTypeConfig.Weapon,
		attrList = {}
	}

	return ret
end
