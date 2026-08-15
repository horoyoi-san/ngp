local ChaosMasterConfig = LTConfig.ChaosMasterConfig
local ChaosMasterChaosBuffConfig = LTConfig.ChaosMasterChaosBuffConfig
local ChaosMasterChaosTagConfig = LTConfig.ChaosMasterChaosTagConfig
local ChaosMasterLimboChaConfig = LTConfig.ChaosMasterLimboChaConfig
local traceback = tolua.traceback
local AttrToFieldDic = {
	"MaxHp",
	"Dam",
	nil,
	nil,
	nil,
	nil,
	"Def",
	[72.0] = "AttackSpeed",
	[73.0] = "EnergyRecovery"
}

if not gBattlePetsMgr then
	local M = {
		countDown = "",
		rCardPercent = 20,
		srCardPercent = 3,
		nCardPercent = 77,
		refreshBuffCardMoney = 100,
		bInBVBGame = false,
		currentLevelNpcId = 0,
		petDataDic = {},
		quickSummonList = {},
		quickSummonDic = {},
		buffDict = {},
		allGenreList = {},
		currentLevelGenreList = {},
		currentTeamList = {},
		gameMode = UX.Game.BVBGameModeType.BVBGameDoJoChallenge,
		maxCost = ChaosMasterConfig.MaxEnemyCost,
		maxListCnt = ChaosMasterConfig.MaxLimboChaBattle,
		damageList = {},
		allDamageList = {},
		maxDamageList = {},
		tagInfoDic = {},
		myBuffDic = {},
		enemyBuffDic = {},
		myGenreBuffDic = {},
		enemyGenreBuffDic = {},
		myChaosList = {},
		enemyChaosList = {},
		myChaosTagLevels = {},
		enemyChaosTagLevels = {},
		enableEquipIds = {
			{},
			{},
			{}
		}
	}
end

M.ChaosAttributeName = {
	Dam = "Dam",
	BVBSpecialAttRate = "BVBSpecialAttRate",
	Hp = "MaxHp",
	BVBEnemyAutoRecovery = "BVBEnemyAutoRecovery",
	BVBAttackSpeed = "BVBAttackSpeed",
	BVBBlockRate = "BVBBlockRate",
	ChaosRebirth = "ChaosRebirth"
}
M.GenreTagType = {
	ChaosGenre = 1,
	Hide = 2,
	LevelGenre = 0
}
M.BVBDDLType = {
	RoundEnd = 2,
	Battle = 1,
	GameEnd = 3,
	Prepare = 0
}
M.GenreLevelType = {
	UnActive = 1,
	Active = 2,
	Hide = 0
}
M.BVBOnlineType = {
	MultiOnline = 2,
	Single = 0,
	SingleOnline = 1
}
M.TalentForbidState = {
	UnActive = 1,
	Normal = 0
}
M.PreparePanelTab = {
	Team = 0,
	GenreDetail = 2,
	EditTeam = 1
}
M.EquipType = {
	Weapon = 3,
	Body = 1,
	Camp = 2
}

function M:OnInit()
	self:BuildBuffDict()
	self:BuildAllGenreList()

	self.bvbOnlineType = self.BVBOnlineType.Single
end

function M:OnBeforeSwitchScene(switchType)
	self:BuildBuffDict()
	self:BuildAllGenreList()
end

function M:SyncNewPet(pet)
	if not pet then
		return
	end

	self.petDataDic[pet.Id] = pet
end

function M:SyncRemovePet(petIdList)
	if not petIdList then
		return
	end

	for i = 1, #petIdList do
		self.petDataDic[petIdList[i]] = nil
	end

	gMessageManager:SendMessage(gEventConstants.CHAOS_MASTER_CHAOS_UPDATE)
end

function M:SyncPetLockChange(id, data)
	self.petDataDic[id].IsLocked = data

	gMessageManager:SendMessage(gEventConstants.CHAOS_MASTER_CHAOS_LOCKED, {
		isLock = data,
		id = id
	})
end

function M:SyncQuickSummonList(list)
	self.quickSummonList = list

	table.clear(self.quickSummonDic)

	for k, v in pairs(self.quickSummonList) do
		self.quickSummonDic[v] = self:GetPetDataById(v)
	end
end

function M:SyncBVBChaosBuff(buffId, level)
	local cfg = ChaosMasterChaosBuffConfig.GetConfig(buffId)
	self.myBuffDic[buffId] = level

	for i = 1, #cfg.Tag do
		if not self.myGenreBuffDic[cfg.Tag[i]] then
			self.myGenreBuffDic[cfg.Tag[i]] = {}
		end

		if not table.contains(self.myGenreBuffDic[cfg.Tag[i]], buffId) then
			table.insert(self.myGenreBuffDic[cfg.Tag[i]], buffId)
		end
	end
end

function M:SyncBVBChaosTagInfo(tagInfos)
	local uiInfo = {}

	for i = 1, tagInfos.Count do
		local info = tagInfos[i]
		local oldInfo = self.tagInfoDic[info.TagId]
		local item = {
			isActive = false,
			isLevelUp = false,
			id = info.TagId
		}

		if oldInfo ~= nil then
			item.isActive = oldInfo.TagLevel == 0 and info.TagLevel > 0
			item.isLevelUp = oldInfo.TagLevel < info.TagLevel
		end

		uiInfo[info.TagId] = item
		self.tagInfoDic[info.TagId] = info
	end
end

function M:SyncBVBDamageStatistics(damage)
	self.allDamageList[damage.DamageType] = 0

	if not self.maxDamageList[damage.DamageType] then
		self.maxDamageList[damage.DamageType] = 0
	end

	self.maxDamageList[damage.DamageType] = math.max(self.maxDamageList[damage.DamageType], damage.Value)

	self:AddDamage(damage)

	local store = self:GetHUDStore()

	store:RefreshDpsList()
end

function M:SyncChaosAgentStatisticInfo(data)
	self.totalDamage = self.totalDamage - (self.agentDamageList[data.AgentId] or 0) + data.Damage
	self.totalBeDamaged = self.totalBeDamaged - (self.agentBeDamagedList[data.AgentId] or 0) + data.BeDamaged
	self.maxDamage = math.max(self.maxDamage, data.Damage)
	self.maxBeDamaged = math.max(self.maxBeDamaged, data.BeDamaged)
	self.agentDamageList[data.AgentId] = data.Damage
	self.agentBeDamagedList[data.AgentId] = data.BeDamaged
	local store = self:GetHUDStore()

	store:RefreshDpsList()
end

function M:AddDamage(damage)
	local flag = false

	for i = 1, #self.damageList do
		if self.damageList[i].DamageType == damage.DamageType then
			if self.damageList[i].ConfigId == damage.ConfigId then
				flag = true
				self.damageList[i].Value = damage.Value
			end

			self.allDamageList[damage.DamageType] = self.allDamageList[damage.DamageType] + self.damageList[i].Value
		end
	end

	if not flag then
		table.insert(self.damageList, damage)

		self.allDamageList[damage.DamageType] = self.allDamageList[damage.DamageType] + damage.Value
	end

	table.sort(self.damageList, function (a, b)
		return b.Value < a.Value
	end)
end

function M:InitNpcAndSceneData(npcId, gameMode, isTest)
	self.currentLevelNpcId = npcId
	self.gameMode = gameMode
	self.isTest = isTest or false
	local cfg = LTConfig.ChaosMasterChaosBattleNpcConfig.GetConfig(npcId)
	local eventCfg = nil

	if npcId == LTConfig.ChaosMasterChaosBattleNpcConfig.Link then
		self.bvbOnlineType = M.BVBOnlineType.SingleOnline
		gCS.BattleManager.bvb_isOnlineMode = true
	else
		self.bvbOnlineType = M.BVBOnlineType.Single
		gCS.BattleManager.bvb_isOnlineMode = false
	end

	if eventCfg then
		gBattlePetsMgr.currentLevelGenreList = table.clone(cfg.EnvironmentChaosTag)
	else
		print_warn("ChaosMaster npcId error id:", npcId)
	end
end

function M:RestoreTeamInfo(dataList)
	self.restoreTeamInfo = dataList
end

function M:RestoreTeamTestInfo(dataList)
	self.restoreTeamTestInfo = dataList
end

function M:GetPetDataById(Id)
	if not Id then
		return
	end

	return self.petDataDic[Id]
end

function M:GetLimboChaId(agentId)
	for i = 0, LTConfig.ChaosMasterLimboChaConfig.count - 1 do
		local cfg = LTConfig.ChaosMasterLimboChaConfig.LoadAt(i)

		if cfg.AgentId == agentId then
			return cfg.Id
		end
	end

	return 0
end

function M:GetBodyCampSkillList(cfg)
	local skillList = {}

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

	return skillList
end

function M:GetWeaponSkillList(limboChaCfg)
	local skillList = {}

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

	return skillList
end

function M:GetChaosAttributeList(attrs)
	local attrsData = {}
	local attrList = ChaosMasterConfig.BVBAttributeNameList

	for index, attr in ipairs(attrList) do
		local attrId = attr.AttributeName
		local value = attrs[attrId] or 0
		local showType = attr.ParametersType
		local attributeNameConfig = LTConfig.AttributeNameConfig.GetConfig(attrId)
		local item = {
			iconId = ChaosMasterConfig.BVBAttributeIcon[index],
			name = attributeNameConfig.AttributeName,
			value = gUIUtils:_format_number(showType, value)
		}

		table.insert(attrsData, item)
	end

	return attrsData
end

function M:GetEquipAttributeList(attrs)
	local attrsData = {}
	local attrList = ChaosMasterConfig.BVBAttributeNameList

	for index, attr in ipairs(attrList) do
		local attrId = attr.AttributeName

		if attrs[attrId] then
			local value = attrs[attrId].addValue or 0
			local showType = attr.ParametersType
			local attributeNameConfig = LTConfig.AttributeNameConfig.GetConfig(attrId)
			local item = {
				iconId = ChaosMasterConfig.BVBAttributeIcon[index],
				name = attributeNameConfig.AttributeName,
				value = gUIUtils:_format_number(showType, value)
			}

			table.insert(attrsData, item)
		end
	end

	return attrsData
end

function M:GetChaosEquipItemDataByBody(bodyId)
	local body = LTConfig.ChaosMasterBodyConfig.GetConfig(bodyId)

	return {
		isUnlocked = true,
		iconId = body.IconID,
		quality = body.Quality
	}
end

function M:GetChaosEquipItemDataByCamp(campId)
	local camp = LTConfig.ChaosMasterCampConfig.GetConfig(campId)

	return {
		isUnlocked = true,
		iconId = camp.IconID,
		quality = camp.Quality
	}
end

function M:GetChaosEquipItemDataByWeapon(weaponId)
	local weapon = LTConfig.ChaosMasterWeaponConfig.GetConfig(weaponId)

	return {
		isUnlocked = true,
		iconId = weapon.IconID,
		quality = weapon.Quality
	}
end

function M:RefreshEquipListItem(store, data)
	store.iconId = data.iconId or store.iconId
	store.qualityCtrl = data.quality - 3
	store.currentEquipCtrl = not data.isEquipped and 1 or 0
	store.isConflictCtrl = not data.isConflict and 1 or 0
	store.lockCtrl = data.isUnlocked and 1 or 0
	local needShowReset = false
	store.showResetBtnCtrl = not needShowReset and 1 or 0
end

function M:GetChaosRoleName(limboChaConfig)
	return LTConfig.TextScriptTextConfig.GetConfig(LTConfig.ChaosMasterConfig.ChaosTagName[limboChaConfig.ChaosTag[1]]).Text
end

function M:RefreshAttributeListItem(store, data)
	store.name = data.name
	store.value = data.value
	store.iconId = data.iconId
end

function M:GetEquipAttributes(cfg)
	local attrs = {}

	if cfg and cfg.BuffStatFactorId and cfg.BuffStatValue then
		for i = 1, #cfg.BuffStatFactorId do
			local attrId = cfg.BuffStatFactorId[i]
			local addValue = cfg.BuffStatValue[i] or 0
			local multiplyValue = cfg.BuffStatFactor and cfg.BuffStatFactor[i] or 0
			attrs[attrId] = attrs[attrId] or {}
			attrs[attrId].addValue = (attrs[attrId].addValue or 0) + addValue
			attrs[attrId].multiplyValue = (attrs[attrId].multiplyValue or 0) + multiplyValue
		end
	end

	return attrs
end

function M:GetChaosAttributes(chaos)
	local addAttrs = {}
	local multiplyAttrs = {}
	local bodyCfg = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)
	local campCfg = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)
	local weaponCfg = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)
	local configs = {
		bodyCfg,
		campCfg,
		weaponCfg
	}

	for _, cfg in ipairs(configs) do
		local attrs = self:GetEquipAttributes(cfg)

		for attrId, values in pairs(attrs) do
			addAttrs[attrId] = (addAttrs[attrId] or 0) + values.addValue
			multiplyAttrs[attrId] = (multiplyAttrs[attrId] or 0) + values.multiplyValue
		end
	end

	local finalAttrs = {}
	local allAttrIds = {}

	for attrId in pairs(addAttrs) do
		allAttrIds[attrId] = true
	end

	for attrId in pairs(multiplyAttrs) do
		allAttrIds[attrId] = true
	end

	for attrId in pairs(allAttrIds) do
		local addValue = addAttrs[attrId] or 0
		local multiplyValue = multiplyAttrs[attrId] or 0
		finalAttrs[attrId] = addValue * (1 + multiplyValue)
	end

	return finalAttrs
end

function M:GetFightPokemonAttributes(fightPokemon)
	local attrs = {}
	local attrList = ChaosMasterConfig.BVBAttributeNameList

	for index, attr in ipairs(attrList) do
		local attrId = attr.AttributeName
		local fieldName = AttrToFieldDic[attrId]

		if not fieldName then
			print_error("GetFightPokemonAttributes error attrId:", attrId)
		else
			local value = fightPokemon[fieldName]

			if not value then
				print_error("GetFightPokemonAttributes error fieldName:", fieldName)
			else
				attrs[attrId] = value
			end
		end
	end

	return attrs
end

function M:RefreshSkillListItem(store, data)
	store.skillName = data.name
	store.skillTypeName = data.type or ""
	store.skillDetail = data.description or ""
end

function M:RefreshDpsListItem(store, data)
	store.iconId = data.iconId
	store.value = data.value .. "(" .. data.percent .. "%)"

	store.progress:ResetValue(data.percent, 0, 0, 100)
end

function M:RefreshGenreList(uiList, genreList)
	local list = {}

	for i = 1, #genreList do
		local tag = ChaosMasterChaosTagConfig.GetConfig(genreList[i])
		local item = {
			iconId = tag.SImageId,
			tagCfg = tag
		}

		table.insert(list, item)
	end

	table.sort(list, function (a, b)
		return a.tagCfg.Id < b.tagCfg.Id
	end)
	uiList:SetList(list)

	return list
end

function M:RefreshTalentList(uiList, talentList)
	local list = {}

	for i = 1, #talentList do
		local talent = LTConfig.ChaosMasterChaosTalentConfig.GetConfig(talentList[i])
		local item = {
			iconId = talent.Icon,
			talentCfg = talent
		}

		table.insert(list, item)
	end

	uiList:SetList(list)

	return list
end

function M:GetChaosEnemyList(chaosList)
	local list = {}

	for i = 1, #chaosList do
		local chaos = self:GetChaosLimboChaConfig(chaosList[i].ChoasEnemyId)
		local item = {
			hideCost = true,
			lihuiId = chaos.CardIcon,
			name = chaos.Name,
			chaosCfg = chaos
		}

		table.insert(list, item)
	end

	return list
end

function M:SortByQuality(list)
	table.sort(list, function (a, b)
		return a.qualityCtrl < b.qualityCtrl
	end)
end

function M:GetCurrentGenreType(id, chaosId)
	if table.contains(self.currentLevelGenreList, id) then
		return self.GenreTagType.LevelGenre
	end

	local cfg = self:GetChaosLimboChaConfig(chaosId)

	if cfg and table.contains(cfg.ChaosTag, id) then
		return self.GenreTagType.ChaosGenre
	end

	return self.GenreTagType.Hide
end

function M:GetBuffLevel(buffId, isMyChaos)
	if isMyChaos and self.myBuffDic[buffId] then
		return self.myBuffDic[buffId]
	elseif not isMyChaos and self.enemyBuffDic[buffId] then
		return self.enemyBuffDic[buffId]
	end

	return 0
end

function M:GetGenreLevelCtrlType(genreId, isMyChaos)
	if isMyChaos then
		if self.tagInfoDic[genreId] and self.tagInfoDic[genreId].TagLevel >= 0 then
			return M.GenreLevelType.Active
		end
	else
		local info = gBattlePetsMgr:GetTagInfo(genreId, isMyChaos)

		if info and info.TagExp > 0 then
			return M.GenreLevelType.Active
		end
	end

	return M.GenreLevelType.UnActive
end

function M:GetAllDamage(type)
	if self.allDamageList[type] then
		return self.allDamageList[type]
	end

	return 0
end

function M:GetMaxDamage(type)
	if self.maxDamageList[type] then
		return self.maxDamageList[type]
	end

	return 0
end

function M:GetTalentForbidText(cfg, curLevel)
	local activeLevel = cfg.Limit[2]

	if curLevel < activeLevel then
		local text = string.format(ChaosMasterConfig.TalentUnlock, ChaosMasterConfig.TalentActiveText, activeLevel)

		return M.TalentForbidState.UnActive, text
	end

	return M.TalentForbidState.Normal, nil
end

function M:CheckIsMyChaos(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)
	local camp = unit.ClientData.Camp

	if self.bvbOnlineType == self.BVBOnlineType.Single then
		if camp == UX.Game.UnitCamp.BVBFriend then
			return true
		end
	else
		return camp == gBattlePetsMgr.myChaosCamp
	end

	return false
end

function M:CheckIsBVBUnit(pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false
	end

	local camp = unit.ClientData.Camp

	return camp == UX.Game.UnitCamp.BVBFriend or camp == UX.Game.UnitCamp.BVBEnemy
end

function M:DisableCamera()
	gCS.CameraDataMgr.cinemachineManager:DisableCustomFreeLook()
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0, 1)
end

function M:GetCurrentRoundChaosDataAndConfig(isMyChaos)
	local chaos = isMyChaos and gBattlePetsMgr.myChaos or gBattlePetsMgr.enemyChaos

	if not chaos then
		return nil, nil
	end

	local cfg = self:GetChaosLimboChaConfig(chaos.TemplateId)

	return chaos, cfg
end

function M:GetChaosGenreLevel(isMyChaos)
	local tags = isMyChaos and self.tagInfoDic or self.enemyChaosLevels
	local level = 0

	if not tags then
		return 0
	end

	for k, v in pairs(tags) do
		if type(v) == "table" then
			level = level + v.TagLevel
		end
	end

	return level
end

function M:GetTagInfo(id, isMyChaos)
	local list = self.enemyChaosLevels

	if isMyChaos then
		list = self.myChaosTagLevels
	end

	if not list or #list == 0 then
		return
	end

	for i = 1, list.Count do
		if list[i].TagId == id then
			return list[i]
		end
	end
end

function M:CheckBVBHUDReady()
	local store = self:GetHUDStore()

	if store.isShow then
		return true
	end

	return false
end

function M:SetChaosMasterPrepareTab(index, data, needOnShow)
	local store = gStoreManager:GetStoreGroup("ChaosMasterPreparePanelStore")
	self.curPrepareTab = index

	store:SetChaosMasterPrepareTab(index, data, needOnShow)
end

function M:EnableBattleSelect(enable, ddl)
	return
end

function M:EnableHud(enable)
	return
end

function M:SetPokemonHpData(pid)
	self:GetHUDStore():RefreshPokemonHp(pid)
end

function M:SetPokemonEnergyData(pid, curValue)
	self:GetHUDStore():RefreshPokemonEnergy(pid, curValue)
end

function M:RefreshBVBHUDData()
	return
end

function M:SyncBVBLinkSelectTeam()
	gBattlePetsMgr.countDown = 0

	gBattlePetsMgr:InitNpcAndSceneData(LTConfig.ChaosMasterChaosBattleNpcConfig.Link)
	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_PREPARE_PANEL)
end

function M:SyncBVBStartGame(me, other)
	self.myChaosCamp = me.BVBCamp
	gCS.BattleManager.bvb_myChaosCamp = me.BVBCamp
	self.myPlayerPid = me.PlayerId
	self.otherPlayerPid = other.PlayerId

	gPanelManager:Close(gPanelId.CHAOS_MASTER_PREPARE_PANEL)
	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_NEW_HUD_PANEL)
	gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_LOADING_PANEL, {
		me = me,
		other = other
	})

	gBattlePetsMgr.bInBVBGame = true
	self.maxDamage = 0
	self.totalDamage = 0
	self.maxBeDamaged = 0
	self.totalBeDamaged = 0
	self.agentDamageList = {}
	self.agentBeDamagedList = {}
end

function M:SyncBVBStartFight(myPokemons, enemyPokemons, myChaosTagLevels, enemyChaosLevels, myChaosBuffs, enemyChaosBuffs)
	self.myChaosList = myPokemons
	self.enemyChaosList = enemyPokemons
	self.myChaosTagLevels = myChaosTagLevels
	self.enemyChaosLevels = enemyChaosLevels
	self.myChaosBuffs = myChaosBuffs
	self.enemyChaosBuffs = enemyChaosBuffs
	self.myChaos = #self.myChaosList > 0 and self.myChaosList[1] or nil
	self.enemyChaos = #self.enemyChaosList > 0 and self.enemyChaosList[1] or nil

	for i = 1, #self.myChaosList do
		local chaos = self.myChaosList[i]

		if chaos.IsActive then
			self.myChaos = chaos
		end
	end

	for i = 1, #self.enemyChaosList do
		local chaos = self.enemyChaosList[i]

		if chaos.IsActive then
			self.enemyChaos = chaos
		end
	end

	self:BuildEnemyBuffDic()

	local store = self:GetHUDStore()

	store:RegisterPokemon()
	self:ClearBVBGameDataRoundEnd()
end

function M:SyncBVBStartSelectFightPokemon(fightPokemons, ddl, opponentPokemons)
	self:EnableBattleSelect(true, ddl)
	self:EnableHud(true)

	gClientToGameSceneDelegate:AskBVBSelectFightPokemonList(self.restoreTeamInfo).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			print_error("上传编队数据失败，err=" .. gCS.Error.GetNameById(err))
		end
	end
end

function M:SyncBVBUpdateFightPokemon(pokemon)
	local isMyPokemon = true

	for i = 1, #self.myChaosList do
		if self.myChaosList[i].PokemonId == pokemon.PokemonId then
			self.myChaosList[i] = pokemon
		end

		if self.myChaosList[i].IsActive then
			self.myChaos = self.myChaosList[i]
		end
	end

	for i = 1, #self.enemyChaosList do
		if self.enemyChaosList[i].PokemonId == pokemon.PokemonId then
			self.enemyChaosList[i] = pokemon
			isMyPokemon = false
		end

		if self.enemyChaosList[i].IsActive then
			self.enemyChaos = self.enemyChaosList[i]
		end
	end
end

function M:SyncBVBUpdateFightPokemons(fightingPokemons)
	for i, v in pairs(fightingPokemons) do
		self:SyncBVBUpdateFightPokemon(v)
	end

	local store = self:GetHUDStore()

	store:OnSyncBVBUpdateFightPokemons()
end

function M:OnPokemonHpChange(pid)
	if not self:CheckIsBVBUnit(pid) or not self:CheckBVBHUDReady() then
		return
	end

	self:SetPokemonHpData(pid)
end

function M:SyncBVBEnemyUltEnergy(pid, value)
	if not self:CheckIsBVBUnit(pid) or not self:CheckBVBHUDReady() then
		return
	end

	self:SetPokemonEnergyData(pid, value)
end

function M:SyncBVBUltSkill(pid)
	if not self:CheckIsBVBUnit(pid) or not self:CheckBVBHUDReady() then
		return
	end

	local isMyChaos = self:CheckIsMyChaos(pid)
end

function M:SyncBVBStartSelectChaosBuff(buffs, ddl, cost)
	gBattlePetsMgr.refreshBuffCardMoney = cost

	self:EnableBattleSelect(false)
	gBattlePetsMgr:EnableHud(true)
end

function M:SyncBVBMoney(money)
	return
end

function M:SyncBVBFightEndTime(round, endTime)
	local store = self:GetHUDStore()

	store:RefreshEndTime(endTime)
end

function M:SyncBVBRoundEnd(result, bonus, nextRoundStartTime)
	self:ClearBVBGameDataRoundEnd()

	local store = self:GetHUDStore()
end

function M:SyncBVBGameEnd(result, rewardInfo)
	local delay = self.clickExitHUDBtn and 0 or LTConfig.ChaosMasterConfig.EndGameWaitingTime

	Timer.New(function ()
		self:ClearBVBGameData()
		gPanelManager:Close(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN)
		gPanelManager:Close(gPanelId.CHAOS_MASTER_NEW_HUD_PANEL)
		gPanelManager:CheckShow(gPanelId.CHAOS_MASTER_ENDING_PANEL, {
			resultType = result,
			rewardInfo = rewardInfo
		})

		gBattlePetsMgr.bInBVBGame = false
	end, delay):Start()
end

function M:AskStartGame(isReplay, isEnemy)
	if self.isTest and not isEnemy then
		gPanelManager:CheckShow(gPanelId.CHAOS_EDIT_TEAM_FULLSCREEN, {
			isEnemy = true,
			isReplay = isReplay
		})

		return
	end

	gClientToGameSceneDelegate:AskStartBVBGame(self.currentLevelNpcId, self.gameMode, self.lastPlayerPos).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end

	if self.isTest then
		gClientToGameSceneDelegate:AskBVBDebugSelectNpcFightPokemonList(self.restoreTeamTestInfo).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				print_error("上传测试敌方编队数据失败，err=" .. gCS.Error.GetNameById(err))
			end
		end
	end
end

function M:BuildBuffDict()
	table.clear(self.buffDict)

	for i = 0, ChaosMasterChaosBuffConfig.count - 1 do
		local cfg = ChaosMasterChaosBuffConfig.LoadAt(i)

		for j = 1, #cfg.Tag do
			if not self.buffDict[cfg.Tag[j]] then
				self.buffDict[cfg.Tag[j]] = {}
			end

			table.insert(self.buffDict[cfg.Tag[j]], cfg)
		end
	end
end

function M:BuildAllGenreList()
	table.clear(self.allGenreList)

	for i = 0, ChaosMasterChaosTagConfig.count - 1 do
		local cfg = ChaosMasterChaosTagConfig.LoadAt(i)

		table.insert(self.allGenreList, cfg)
	end
end

function M:RebuildCurrentTeamList(newList)
	local index = 1

	for i = 1, self.maxListCnt do
		self.currentTeamList[i] = nil

		if newList[i] then
			self.currentTeamList[index] = newList[i]
			index = index + 1
		end
	end
end

function M:BuildCurrentTeamByQuickSummonList()
	local index = 1

	for i = 1, self.maxListCnt do
		self.currentTeamList[i] = nil

		if self.quickSummonList[i] then
			self.currentTeamList[index] = self:GetPetDataById(self.quickSummonList[i])
			index = index + 1
		end
	end
end

function M:BuildEnemyBuffDic()
	table.clear(self.enemyGenreBuffDic)

	for i = 1, self.enemyChaosBuffs.Count do
		local buffId = self.enemyChaosBuffs[i].ChaosBuffId
		local level = self.enemyChaosBuffs[i].Level
		local cfg = ChaosMasterChaosBuffConfig.GetConfig(buffId)
		self.enemyBuffDic[buffId] = level

		for i = 1, #cfg.Tag do
			if not self.enemyGenreBuffDic[cfg.Tag[i]] then
				self.enemyGenreBuffDic[cfg.Tag[i]] = {}
			end

			if not table.contains(self.enemyGenreBuffDic[cfg.Tag[i]], buffId) then
				table.insert(self.enemyGenreBuffDic[cfg.Tag[i]], buffId)
			end
		end
	end
end

function M:ClearBVBGameDataRoundEnd()
	table.clear(self.damageList)
	table.clear(self.allDamageList)
	table.clear(self.maxDamageList)

	self.countDown = ""
end

function M:ClearBVBGameData()
	table.clear(self.myBuffDic)
	table.clear(self.enemyBuffDic)
	table.clear(self.myGenreBuffDic)
	table.clear(self.enemyGenreBuffDic)
	table.clear(self.myChaosList)
	table.clear(self.enemyChaosList)
	table.clear(self.tagInfoDic)
	table.clear(self.damageList)
	table.clear(self.allDamageList)
	table.clear(self.maxDamageList)

	self.myChaos = nil
	self.enemyChaos = nil
	self.countDown = ""
	self.myChaosTagLevels = nil
	self.enemyChaosLevels = nil
end

function M:GetHUDStore()
	if not self.hudStore then
		self.hudStore = gStoreManager:GetStoreGroup("ChaosMasterNewHUDPanelStore")
	end

	return self.hudStore
end

function M:GetChaosLimboChaConfig(limboChaId)
	return LTConfig.ChaosMasterLimboChaConfig.GetConfig(limboChaId)
end

function M:GetChaosCost(chaos)
	if chaos then
		local body = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)
		local camp = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)
		local weapon = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)

		return (body and body.Cost or 0) + (camp and camp.Cost or 0) + (weapon and weapon.Cost or 0)
	end

	return 0
end

function M:GetChaosAttribute(chaos, attribute)
	if chaos then
		local body = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)
		local camp = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)
		local weapon = LTConfig.ChaosMasterWeaponConfig.GetConfig(chaos.Weapon)
		local sum = body[attribute] + camp[attribute] + weapon[attribute]

		if attribute == M.ChaosAttributeName.BVBBlockRate or attribute == M.ChaosAttributeName.BVBSpecialAttRate or attribute == M.ChaosAttributeName.BVBAttackSpeed then
			sum = string.format("%.1f", sum * 100) .. "%"
		end

		return sum
	end

	return 0
end

function M:GetChaosPassiveSkill(chaos)
	if chaos then
		local list = {}
		local body = LTConfig.ChaosMasterBodyConfig.GetConfig(chaos.Body)
		local camp = LTConfig.ChaosMasterCampConfig.GetConfig(chaos.Camp)

		for i = 1, #body.PassiveSkill do
			local item = {
				Id = body.PassiveSkill[i],
				from = LTConfig.ChaosMasterConfig.SkillBelongName[2]
			}

			table.insert(list, item)
		end

		for i = 1, #camp.PassiveSkill do
			local item = {
				Id = camp.PassiveSkill[i],
				from = LTConfig.ChaosMasterConfig.SkillBelongName[1]
			}

			table.insert(list, item)
		end

		return list
	end

	return nil
end

function M:GetChaosGenre(limboChaId)
	local cfg = self:GetChaosLimboChaConfig(limboChaId)

	if cfg then
		return cfg.ChaosTag
	end

	return nil
end

function M:CheckIsBVBGameDoJoChallenge()
	return gBattlePetsMgr.gameMode == UX.Game.BVBGameModeType.BVBGameDoJoChallenge
end

local unActive_color = {
	black = "<color=#D9D9D94C>",
	white = "<color=##1d1d1d99>"
}
local active_color = {
	black = "<color=#FFFFFFCC>",
	white = "<color=#000000FF>"
}
local end_color = "</color>"

function M:BuildDescriptionStrByValueList(str, valueList, type, curLevel, isBlack)
	if not type or type == "" then
		return str
	end

	local colorText = isBlack and "black" or "white"
	local formattedValues = {}
	curLevel = curLevel or 0

	if curLevel > #valueList then
		curLevel = #valueList
	end

	local typePre = string.sub(type, 1, 1)
	local typeAfter = string.sub(type, -1)

	for i = 1, #valueList do
		local value = valueList[i]
		formattedValues[i] = 0

		if typePre == "p" then
			formattedValues[i] = string.format("%." .. typeAfter .. "f%%", value * 100)
		elseif typePre == "f" then
			formattedValues[i] = string.format("%." .. typeAfter .. "f", value)
		end

		if i == curLevel then
			formattedValues[i] = active_color[colorText] .. formattedValues[i] .. end_color
		else
			formattedValues[i] = unActive_color[colorText] .. formattedValues[i] .. end_color
		end
	end

	local function func()
		result = string.format(str, table.concat(formattedValues, "/"))
	end

	local ok = xpcall(func, traceback)

	if not ok then
		print_error("策划配置错误，大概率是需要format的字符串中，固定百分比需要用两个%，错误字符串为：", str)
	end

	return result
end

function M:SyncUnlockedEquipIds(info)
	if info.EnabledBodyIds and #info.EnabledBodyIds > 0 then
		self.enableEquipIds[M.EquipType.Body] = {}

		for i = 1, #info.EnabledBodyIds do
			local id = info.EnabledBodyIds[i]

			if not self.enableEquipIds[M.EquipType.Body][id] then
				self.enableEquipIds[M.EquipType.Body][id] = true
			end
		end
	end

	if info.EnabledCampIds and #info.EnabledCampIds > 0 then
		self.enableEquipIds[M.EquipType.Camp] = {}

		for i = 1, #info.EnabledCampIds do
			local id = info.EnabledCampIds[i]

			if not self.enableEquipIds[M.EquipType.Camp][id] then
				self.enableEquipIds[M.EquipType.Camp][id] = true
			end
		end
	end

	if info.EnabledWeaponIds and #info.EnabledWeaponIds > 0 then
		self.enableEquipIds[M.EquipType.Weapon] = {}

		for i = 1, #info.EnabledWeaponIds do
			local id = info.EnabledWeaponIds[i]

			if not self.enableEquipIds[M.EquipType.Weapon][id] then
				self.enableEquipIds[M.EquipType.Weapon][id] = true
			end
		end
	end
end

function M:CheckEquipPartUnlocked(partType, cfgId)
	return true
end

function M:DebugLog(msg)
	print_warn("[ChaosMaster] ", msg)
end

gBattlePetsMgr = M
