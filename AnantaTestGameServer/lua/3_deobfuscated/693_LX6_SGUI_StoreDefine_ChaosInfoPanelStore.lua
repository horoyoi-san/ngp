C_ChaosInfoPanelStore = DefClass("C_ChaosInfoPanelStore", C_ChaosInfoPanelStore, C_StoreGroup)
GroupName2Class.ChaosInfoPanelStore = C_ChaosInfoPanelStore
local M = C_ChaosInfoPanelStore
local ShowType = {
	Hide = 1,
	Show = 0
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	return
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.showGenreDetail = data.showGenreDetail
	self.curChaosData = data.curChaosData
	self.isMyChaos = data.isMyChaos
	self.bindData.showDurabilityCtrl = gBattlePetsMgr:CheckIsBVBGameDoJoChallenge() and 1 or 0

	self:RefreshGenreDetalCtrl()
	self:RefreshChaosBaseInfo()
	self:RefreshChaosSkillOrTalentInfo()
	self:RefreshChaosGenreInfo()
	self:RefreshChaosGenreDetailInfo()
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:GenMessageEvents()
	return
end

function M:RegisterWidget()
	self.bindData.attributeList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosAttribute")
	self.bindData.skillList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosInfoSkillList")
	self.bindData.genreList.luaSimpleRenderItem = self:CreateAction("OnRenderChaosGenreInfo")
	self.bindData.genreDetailList.luaSimpleRenderItem = self:CreateAction("OnRenderGenreDetailListItem")
	self.bindData.genreList.luaClick = self:CreateAction("OnClickChaosGenre")
end

function M:OnRenderChaosAttribute(item, index)
	local store = gStoreManager:GetStoreGroup("ChaosAttributeTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.attributeList[index + 1]
	store.iconId = data.iconId
	store.name = data.name
	store.value = data.value
end

function M:OnRenderChaosInfoSkillList(item, index)
	local store = gStoreManager:GetStoreGroup("ChaosSkillListStore"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.skillList[index + 1]
	store.title = data.title
	store.list.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderChaosInfoSkill, index + 1)

	store.list:SetSimpleList(#data.list)
end

function M:OnRenderChaosInfoSkill(skillIndex, item, index)
	local store = gStoreManager:GetStoreGroup("ChaosSkillTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.skillList[skillIndex][index]
	store.iconId = data.iconId
	store.name = data.name
	store.des = data.des
	store.typeName = data.typeName
	store.showIcon = data.showIcon
	store.showType = data.showType
	store.conditionText = data.conditionText
	store.conditionCtrl = data.conditionCtrl
	store.belongName = data.belongName
	store.hideLineCtrl = data.hideLineCtrl
end

function M:OnRenderChaosGenreInfo(item, index)
	local store = gStoreManager:GetStoreGroup("BuffGenreTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.genreList[index + 1]
	store.iconId = data.iconId
end

function M:OnRenderGenreDetailListItem(item, index)
	local store = gStoreManager:GetStoreGroup("GenreDetailTemplate"):GetStoreByWidget(item)

	if not store then
		return
	end

	local data = self.genreDetailList[index + 1]
	store.iconId = data.iconId
	store.name = data.name
	store.level = data.level
	store.expText = data.expText
	store.des = data.des

	store.ExpProgress:ResetValue(data.fill, 0, 0, 1)
end

function M:OnClickChaosGenre(btn, data)
	local curTab = gBattlePetsMgr.curPrepareTab

	gBattlePetsMgr:SetChaosMasterPrepareTab(gBattlePetsMgr.PreparePanelTab.GenreDetail, {
		curGenre = self.genreList,
		closeAction = function ()
			gBattlePetsMgr:SetChaosMasterPrepareTab(curTab, nil, false)
		end
	})
end

function M:RefreshGenreDetalCtrl()
	self.bindData.genreCtrl = self.showGenreDetail and 1 or 0
	self.bindData.genraDetailCtrl = self.showGenreDetail and 0 or 1
end

function M:RefreshChaosBaseInfo()
	local cfgId = self.showGenreDetail and self.curChaosData.TemplateId or self.curChaosData.LimboChaId
	local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(cfgId)
	self.bindData.name = cfg.Name
	self.bindData.auatarId = cfg.CardIcon
	self.bindData.level = self.showGenreDetail and "Lv." .. gBattlePetsMgr:GetChaosGenreLevel(self.isMyChaos) or ""
	self.bindData.showLevelCtrl = self.showGenreDetail and 0 or 1
	local list = {}

	if self.showGenreDetail then
		self.bindData.durability = self.curChaosData.RemainDurability

		self:AddAttributeInfo(list, 1, self.curChaosData.MaxHp, 1)
		self:AddAttributeInfo(list, 2, self.curChaosData.Dam, 2)
		self:AddAttributeInfo(list, 72, string.format("%.1f", self.curChaosData.AttackSpeed * 100) .. "%", 3)
		self:AddAttributeInfo(list, 73, self.curChaosData.EnergyRecovery, 4)
		self:AddAttributeInfo(list, 71, string.format("%.1f", self.curChaosData.SpecialAttRate * 100) .. "%", 5)
		self:AddAttributeInfo(list, 70, string.format("%.1f", self.curChaosData.BlockRate * 100) .. "%", 6)
	else
		self.bindData.durability = gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.ChaosRebirth)

		self:AddAttributeInfo(list, 1, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.Hp), 1)
		self:AddAttributeInfo(list, 2, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.Dam), 2)
		self:AddAttributeInfo(list, 72, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.BVBAttackSpeed), 3)
		self:AddAttributeInfo(list, 73, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.BVBEnemyAutoRecovery), 4)
		self:AddAttributeInfo(list, 71, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.BVBSpecialAttRate), 5)
		self:AddAttributeInfo(list, 70, gBattlePetsMgr:GetChaosAttribute(self.curChaosData, gBattlePetsMgr.ChaosAttributeName.BVBBlockRate), 6)
	end

	self.attributeList = list

	self.bindData.attributeList:SetSimpleList(#self.attributeList)
end

function M:RefreshChaosSkillOrTalentInfo()
	self.skillList = {}

	self:RefreshChaosPassiveSkillInfo()
	self:RefreshChaosSkillInfo()
	self:RefreshChaosTalentInfo()
	self.bindData.skillList:SetSimpleList(#self.skillList)
end

function M:RefreshChaosSkillInfo()
	local cfgId = self.showGenreDetail and self.curChaosData.TemplateId or self.curChaosData.LimboChaId
	local limboChaConfig = gBattlePetsMgr:GetChaosLimboChaConfig(cfgId)
	local skills = limboChaConfig and limboChaConfig.SkillId or {}
	local list = {}

	for i = 1, #skills do
		local cfg = LTConfig.ChaosMasterSkillConfig.GetConfig(skills[i])

		if cfg then
			local item = {
				showIcon = true,
				showType = true,
				iconId = cfg.Icon,
				name = cfg.Name,
				des = cfg.Description,
				typeName = LTConfig.ChaosMasterConfig.SkillTypeName[cfg.SkillType],
				belongName = LTConfig.ChaosMasterConfig.SkillBelongName[3],
				hideLineCtrl = i < #skills and ShowType.Show or ShowType.Hide
			}

			table.insert(list, item)
		end
	end

	local skillData = {
		title = LTConfig.ChaosMasterConfig.SkillTitleName[2],
		list = list
	}

	table.insert(self.skillList, skillData)
end

function M:RefreshChaosPassiveSkillInfo()
	local cfgId = self.showGenreDetail and self.curChaosData.TemplateId or self.curChaosData.LimboChaId
	local skills = gBattlePetsMgr:GetChaosPassiveSkill(self.curChaosData)
	local list = {}

	for i = 1, #skills do
		local cfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(skills[i].Id)

		if cfg then
			local item = {
				showType = true,
				showIcon = true,
				iconId = cfg.Icon,
				name = cfg.Name or "",
				des = cfg.Effect,
				typeName = LTConfig.ChaosMasterConfig.SkillTypeName[3],
				Id = cfg.Id,
				belongName = skills[i].from,
				hideLineCtrl = i < #skills and ShowType.Show or ShowType.Hide
			}

			table.insert(list, item)
		end
	end

	table.sort(list, function (a, b)
		return a.Id < b.Id
	end)

	local talentData = {
		title = LTConfig.ChaosMasterConfig.SkillTitleName[1],
		list = list
	}

	table.insert(self.skillList, talentData)
end

function M:RefreshChaosTalentInfo()
	local cfgId = self.showGenreDetail and self.curChaosData.TemplateId or self.curChaosData.LimboChaId
	local cfg = gBattlePetsMgr:GetChaosLimboChaConfig(cfgId)
	local talents = cfg.TalentBuff
	local list = {}

	for i = 1, #talents do
		local cfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(talents[i])

		if cfg then
			local item = {
				showType = false,
				showIcon = true,
				iconId = cfg.Icon,
				name = cfg.Name or "",
				des = cfg.Effect,
				Id = cfg.Id,
				typeName = LTConfig.ChaosMasterConfig.SkillTypeName[3],
				belongName = LTConfig.ChaosMasterConfig.SkillBelongName[4],
				hideLineCtrl = i < #talents and ShowType.Show or ShowType.Hide
			}

			table.insert(list, item)
		end
	end

	table.sort(list, function (a, b)
		if a.conditionCtrl == b.conditionCtrl then
			return a.Id < b.Id
		end

		return b.conditionCtrl < a.conditionCtrl
	end)

	local talentData = {
		title = LTConfig.ChaosMasterConfig.SkillTitleName[3],
		list = list
	}

	table.insert(self.skillList, talentData)
end

function M:RefreshChaosGenreInfo()
	local genres = self.showGenreDetail and (self.isMyChaos and gBattlePetsMgr.myChaosTagLevels or gBattlePetsMgr.enemyChaosLevels) or nil

	if not self.showGenreDetail then
		genres = gBattlePetsMgr:GetChaosGenre(self.curChaosData.LimboChaId)
	end

	self.genreList = {}

	if genres then
		for i = 1, #genres do
			local cfg = LTConfig.ChaosMasterChaosTagConfig.GetConfig(genres[i])

			if cfg then
				local item = {
					iconId = cfg.SImageId,
					id = cfg.Id
				}

				table.insert(self.genreList, item)
			end
		end
	end

	self.bindData.genreList:SetSimpleList(#self.genreList)
end

function M:RefreshChaosGenreDetailInfo()
	local list = {}
	local genreList = gBattlePetsMgr.allGenreList

	if genreList and #genreList ~= 0 then
		for i = 1, #genreList do
			local genreId = genreList[i].Id
			local cfgId = self.showGenreDetail and self.curChaosData.TemplateId or self.curChaosData.LimboChaId
			local chaosCfg = gBattlePetsMgr:GetChaosLimboChaConfig(cfgId)
			local cfg = LTConfig.ChaosMasterChaosTagConfig.GetConfig(genreId)
			local tagType = gBattlePetsMgr:GetCurrentGenreType(cfg.Id)
			local isChaosTag = table.contains(chaosCfg.ChaosTag, cfg.Id)

			if cfg and tagType ~= gBattlePetsMgr.GenreTagType.Hide and isChaosTag then
				local tagInfo = self.isMyChaos and gBattlePetsMgr.tagInfoDic[cfg.Id] or gBattlePetsMgr:GetTagInfo(cfg.Id, self.isMyChaos)
				local level = tagInfo and tagInfo.TagLevel or 0
				local expFz = tagInfo and tagInfo.TagExp or 0
				local nextLevel = LTConfig.ChaosMasterConfig.TagMaxLevel < level + 1 and LTConfig.ChaosMasterConfig.TagMaxLevel or level + 1
				local expFm = LTConfig.ChaosMasterConfig.TagExp[nextLevel]
				local item = {
					iconId = cfg.SImageId,
					name = cfg.Name,
					des = gBattlePetsMgr:BuildDescriptionStrByValueList(cfg.Effect, cfg.BuffParameter, cfg.StarUpParametersType, level, true),
					level = "Lv." .. (tagInfo and tagInfo.TagLevel or 0),
					expText = expFz .. "/" .. expFm,
					fill = expFz / expFm,
					expNum = expFz
				}

				table.insert(list, item)
			end
		end

		table.sort(list, function (a, b)
			return b.expNum < a.expNum
		end)
	end

	self.genreDetailList = list

	self.bindData.genreDetailList:SetSimpleList(#list)
end

function M:AddAttributeInfo(list, attribute, value, index)
	local attributeNameConfig = LTConfig.AttributeNameConfig.GetConfig(attribute)
	local item = {
		iconId = LTConfig.ChaosMasterConfig.BVBAttributeIcon[index],
		name = attributeNameConfig.AttributeName,
		value = value
	}

	table.insert(list, item)
end
