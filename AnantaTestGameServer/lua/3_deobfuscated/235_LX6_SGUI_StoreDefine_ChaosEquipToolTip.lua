local ChaosMasterConfig = LTConfig.ChaosMasterConfig
C_ChaosEquipToolTip = DefClass("C_ChaosEquipToolTip", C_ChaosEquipToolTip, C_StoreGroup)
GroupName2Class.ChaosEquipToolTip = C_ChaosEquipToolTip
local M = C_ChaosEquipToolTip
local EquipType = {
	Weapon = 3,
	Body = 1,
	Camp = 2
}

function M:ctor()
	self.EquipType = EquipType
end

function M:RegisterWidget(store)
	if store.attrList then
		store.attrList.luaSimpleRenderItem = self:CreateAction("OnRenderAttrItem")
		store.attrList.onGetTIndex = self:CreateAction("OnGetAttrListTIndex")
	end

	if store.skillList then
		store.skillList.luaSimpleRenderItem = self:CreateAction("OnRenderSkillItem")
		store.skillList.onGetTIndex = self:CreateAction("OnGetSkillListTIndex")
	end
end

function M:SetChaosEquipTooltip(widget, equipType, equipId, chaosData, limboChaHash)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	self:RegisterWidget(store)

	local cfg = self:_getEquipConfig(equipType, equipId)

	if not cfg then
		return
	end

	store.nameText = cfg.CampName or cfg.BodyName or cfg.WeaponName or ""

	if equipType == self.EquipType.Weapon then
		store.isWeaponCtrl = 0
		store.weaponTypeText = ""
	else
		store.isWeaponCtrl = 1
		local typeText = ""

		if equipType == self.EquipType.Body then
			typeText = LTConfig.TextScriptTextConfig.GetConfig(89901214).Text
		elseif equipType == self.EquipType.Camp then
			typeText = LTConfig.TextScriptTextConfig.GetConfig(89901215).Text
		end

		store.weaponTypeText = typeText
	end

	self:_setCostComponent(store, cfg)
	self:_setAttrList(store, cfg, equipType, chaosData)
	self:_setSkillList(store, cfg, equipType, chaosData, limboChaHash)
end

function M:_getEquipConfig(equipType, equipId)
	if equipType == self.EquipType.Body then
		return LTConfig.ChaosMasterBodyConfig.GetConfig(equipId)
	elseif equipType == self.EquipType.Camp then
		return LTConfig.ChaosMasterCampConfig.GetConfig(equipId)
	elseif equipType == self.EquipType.Weapon then
		return LTConfig.ChaosMasterWeaponConfig.GetConfig(equipId)
	end

	return nil
end

function M:_setCostComponent(store, cfg)
	store.qualityCtrl = (cfg.Quality or 3) - 3
end

function M:_setAttrList(store, cfg, equipType, chaosData)
	if not store.attrList then
		return
	end

	local addAttrs, multiplyAttrs = self:_getEquipAttrs(cfg)
	local attrsData = {}
	local attrList = ChaosMasterConfig.BVBAttributeNameList

	for index, attr in ipairs(attrList) do
		local attrId = attr.AttributeName
		local addValue = addAttrs[attrId] or 0
		local multiplyValue = multiplyAttrs[attrId] or 0
		local currentValue = self:_getCurrentAttrValue(chaosData, attrId, equipType)
		local showType = attr.ParametersType
		local attributeNameConfig = LTConfig.AttributeNameConfig.GetConfig(attrId)

		if addValue ~= 0 or currentValue ~= 0 then
			local item = {
				iconId = ChaosMasterConfig.BVBAttributeIcon[index],
				name = attributeNameConfig.AttributeName,
				value = gUIUtils:_format_number(showType, addValue),
				compareValue = addValue - currentValue,
				showType = showType
			}

			table.insert(attrsData, item)
		end

		local currentMultiplyValue = self:_getCurrentMultiplyAttrValue(chaosData, attrId, equipType)

		if multiplyValue ~= 0 or currentMultiplyValue ~= 0 then
			local item = {
				iconId = ChaosMasterConfig.BVBAttributeIcon[index],
				name = attributeNameConfig.AttributeName,
				value = gUIUtils:_format_number("p0", multiplyValue),
				compareValue = multiplyValue - currentMultiplyValue,
				showType = "p0"
			}

			table.insert(attrsData, item)
		end
	end

	store.attrListData = attrsData

	store.attrList:SetSimpleList(#attrsData)
end

function M:_setSkillList(store, cfg, equipType, chaosData, limboChaHash)
	if not store.skillList then
		return
	end

	local skillList = {}

	if equipType == self.EquipType.Body and cfg.PassiveSkill then
		for _, skillId in ipairs(cfg.PassiveSkill) do
			local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(skillId)

			if skillCfg then
				table.insert(skillList, {
					skillId = skillId,
					name = skillCfg.Name,
					icon = skillCfg.Icon,
					description = skillCfg.Effect,
					type = LTConfig.TextScriptTextConfig.GetConfig(89901196).Text
				})
			end
		end
	elseif equipType == self.EquipType.Camp and cfg.PassiveSkill then
		for _, skillId in ipairs(cfg.PassiveSkill) do
			local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(skillId)

			if skillCfg then
				table.insert(skillList, {
					skillId = skillId,
					name = skillCfg.Name,
					icon = skillCfg.Icon,
					description = skillCfg.Effect,
					type = LTConfig.TextScriptTextConfig.GetConfig(89901196).Text
				})
			end
		end
	elseif equipType == self.EquipType.Weapon and chaosData and limboChaHash then
		local bodyId = chaosData.Body
		local campId = chaosData.Camp
		local weaponId = cfg.Id
		local hashKey = bodyId .. "_" .. campId .. "_" .. weaponId
		local limboChaCfg = limboChaHash[hashKey]

		if limboChaCfg and limboChaCfg.SkillId then
			for _, skillId in ipairs(limboChaCfg.SkillId) do
				local skillCfg = LTConfig.ChaosMasterSkillConfig.GetConfig(skillId)

				if skillCfg then
					table.insert(skillList, {
						skillId = skillId,
						name = skillCfg.Name,
						icon = skillCfg.Icon,
						description = skillCfg.Description,
						type = LTConfig.TextScriptTextConfig.GetConfig(89901197).Text
					})
				end
			end
		end
	end

	store.skillListData = skillList

	store.skillList:SetSimpleList(#skillList)
end

function M:_getEquipAttrs(cfg)
	local addAttrs = {}
	local multiplyAttrs = {}

	if cfg.BuffStatFactorId and cfg.BuffStatValue then
		for i = 1, #cfg.BuffStatFactorId do
			local attrId = cfg.BuffStatFactorId[i]
			local addValue = cfg.BuffStatValue[i] or 0
			local multiplyValue = cfg.BuffStatFactor and cfg.BuffStatFactor[i] or 0
			addAttrs[attrId] = addValue
			multiplyAttrs[attrId] = multiplyValue
		end
	end

	return addAttrs, multiplyAttrs
end

function M:_getCurrentAttrValue(chaosData, attrId, equipType)
	local currentCfg = nil

	if equipType == self.EquipType.Body then
		currentCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(chaosData.Body)
	elseif equipType == self.EquipType.Camp then
		currentCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaosData.Camp)
	elseif equipType == self.EquipType.Weapon then
		currentCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaosData.Weapon)
	end

	if not currentCfg then
		return 0
	end

	if currentCfg.BuffStatFactorId and currentCfg.BuffStatValue then
		for i = 1, #currentCfg.BuffStatFactorId do
			if currentCfg.BuffStatFactorId[i] == attrId then
				return currentCfg.BuffStatValue[i] or 0
			end
		end
	end

	return 0
end

function M:_getCurrentMultiplyAttrValue(chaosData, attrId, equipType)
	local currentCfg = nil

	if equipType == self.EquipType.Body then
		currentCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(chaosData.Body)
	elseif equipType == self.EquipType.Camp then
		currentCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaosData.Camp)
	elseif equipType == self.EquipType.Weapon then
		currentCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaosData.Weapon)
	end

	if not currentCfg then
		return 0
	end

	if currentCfg.BuffStatFactorId and currentCfg.BuffStatFactor then
		for i = 1, #currentCfg.BuffStatFactorId do
			if currentCfg.BuffStatFactorId[i] == attrId then
				return currentCfg.BuffStatFactor[i] or 0
			end
		end
	end

	return 0
end

function M:OnRenderAttrItem(item, index)
	local store = gStoreManager:GetStoreGroup("ChaosAttributeTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local parentStore = gStoreManager:GetStoreGroup(item.parentComponent.Store):GetStoreByWidget(item.parentComponent)
	local data = parentStore.attrListData[index + 1]

	if not data then
		return
	end

	store.name = data.name
	store.value = data.value
	store.iconId = data.iconId or 0
	store.showCompareCtrl = 1

	if data.compareValue ~= 0 then
		store.showCompareCtrl = 0
		store.compareTypeCtrl = data.compareValue < 0 and 1 or 0
		store.diffText = gUIUtils:_format_number(data.showType, math.abs(data.compareValue))
	end
end

function M:OnRenderSkillItem(item, index)
	local store = gStoreManager:GetStoreGroup("ChaosEquipSkill"):GetStoreByWidget(item)

	if not store then
		return
	end

	local parentStore = gStoreManager:GetStoreGroup(item.parentComponent.Store):GetStoreByWidget(item.parentComponent)
	local data = parentStore.skillListData[index + 1]

	if not data then
		return
	end

	gBattlePetsMgr:RefreshSkillListItem(store, data)
end

function M:OnGetAttrListTIndex(index)
	return 0
end

function M:OnGetSkillListTIndex(index)
	return 0
end
