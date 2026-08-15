C_ChaosMasterNewHUDPanelStore = DefClass("C_ChaosMasterNewHUDPanelStore", C_ChaosMasterNewHUDPanelStore, C_StoreGroup)
GroupName2Class.ChaosMasterNewHUDPanelStore = C_ChaosMasterNewHUDPanelStore
local M = C_ChaosMasterNewHUDPanelStore
local DamageTabType = {
	Damaged = 0,
	DamageOther = 1
}
local CellEffectId = {
	Unknown = 53802014,
	Focus = 53802013,
	Normal = 53802012
}

function M:ctor()
	return
end

function M:DefineAllVariables()
	self.isShow = false
	self.isShowRightTooltip = false
	self.pokemonDataList = {}
	self.mainCamera = nil
	self.focusEffectId = LTConfig.ChaosMasterConfig.ChooseEffect
	self.summonEffectId = LTConfig.ChaosMasterConfig.SummonEffect
	self.isUnitFocused = false
	self.focusedUnit = nil
	self.focusedUnitEffectUuid = nil
	self.summonEffectUuid = nil
	self.damageTabType = DamageTabType.DamageOther
	self.focusedToolTipPokemon = nil
	self.focusedCube = nil
	self.unitToLimboChaCfgDic = {}
end

function M:OnAwake()
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()
end

function M:OnEnable()
	gClientToGameSceneDelegate:AskBVBGetReady().Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	if self.cellEffectUuidMap then
		for q, v in pairs(self.cellEffectUuidMap) do
			for r, cell in pairs(v) do
				if cell then
					gCS.EffectMgr:StopEffectAndSetCacheByUUID(cell)
				end
			end
		end
	end

	if self.focusedUnitEffectUuid then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.focusedUnitEffectUuid)

		self.focusedUnitEffectUuid = nil
	end

	if self.summonEffectUuid then
		gCS.EffectMgr:StopEffectAndSetCacheByUUID(self.summonEffectUuid)

		self.summonEffectUuid = nil
	end

	if self.pokemonDataList then
		if self.pokemonDataList then
			for _, v in pairs(self.pokemonDataList) do
				if v and v.widget and not gCS.LuaUtils.IsNull(v.widget) and not gCS.LuaUtils.IsNull(v.widget.gameObject) then
					UnityEngine.Object.Destroy(v.widget.gameObject)
				end
			end
		end

		self.pokemonDataList = nil
	end

	self.isShow = false
	gBattleMgr.dataSet.showEnemyHp = true
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.isShow = true

	self:EnableCamera()
	self.bindData.hpBarTemplate:SetActive(false)

	self.mainCamera = gCS.CameraDataMgr.ActiveCamera

	self:RefreshDpsTabList()
	self:RegisterTooltip()
	self:HideChaosTooltip()

	if self.isDataReady then
		self:RegisterPokemon()

		self.isDataReady = false
	end

	self:GenerateHexMap()

	gBattleMgr.dataSet.showEnemyHp = false
end

function M:OnUpdate()
	self:UpdateHpBarPos()
	self:UpdateCountDown()
	self:UpdateFocusedCube()
end

function M:UpdateHpBarPos()
	for _, v in pairs(self.pokemonDataList) do
		if not v or not v.target or gCS.LuaUtils.IsNull(v.target) then
			return
		end

		local worldFollowPos = v.target.position + Vector3.New(0, 2, 0)
		local worldFollowPos = v.target.position + Vector3.New(0, 2, 0)
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(worldFollowPos, gCS.CameraDataMgr.MainCamera, 0, 0, 0)
		local screenPos = gCS.LuaUtils.ScreenPointUI(self.bindData.hpBarContainerWidget.rectTransform, Vector2.New(x, y))

		v.widget.rectTransform:SetLocalPositionXY(screenPos.x, screenPos.y)
	end
end

function M:UpdateCountDown()
	if not self.isCountingDown then
		return
	end

	local remainTime = math.floor(self.endTime - gLogicTime.time)

	if remainTime <= 0 then
		self.isCountingDown = false

		return
	end

	self.bindData.countDownText = string.format("%02d", remainTime)
end

function M:UpdateFocusedCube()
	if not self.isUnitFocused then
		return
	end

	if not self.focusedUnit then
		print_error("focusedUnit is nil")

		return
	end

	local cube = self:WorldToCube(self.focusedUnit.PlayerObj.position)

	if not cube then
		print_error("Cannot find cube for position:", tostring(self.focusedUnit.PlayerObj.position))

		return
	end

	if not self.focusedCube or cube.q ~= self.focusedCube.q or cube.r ~= self.focusedCube.r then
		self:SetCubeFocusEffect(cube, CellEffectId.Focus)
	end
end

function M:OnClose()
	gBattleMgr.dataSet.showEnemyHp = true

	self:UnFocusPokemon()
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
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnClickExitBtn)
	self.bindData.switchBtn.luaClick = self:CreateAction(self.OnClickSwitchBtn)
	self.bindData.fullScreenBackBtn.luaClick = self:CreateAction(self.OnClickFullScreenBackBtn)
	self.bindData.dpsList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDpsListItem)
	self.bindData.dpsTabList.luaSimpleRenderItem = self:CreateAction(self.OnRenderDpsTabListItem)
end

function M:RegisterTooltip()
	self.chaosInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosInfoTooltipWidget.Store):GetStoreByWidget(self.bindData.chaosInfoTooltipWidget)
	self.equipInfoStore = gStoreManager:GetStoreGroup(self.bindData.chaosEquipInfoWidget.Store):GetStoreByWidget(self.bindData.chaosEquipInfoWidget)
	self.chaosInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderChaosAttributeListItem)
	self.chaosInfoStore.equipList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipListItem)
	self.equipInfoStore.attributeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipAttributeListItem)
	self.equipInfoStore.skillList.luaSimpleRenderItem = self:CreateAction(self.OnRenderEquipSkillListItem)
end

function M:RegisterPokemon()
	if self.pokemonDataList then
		for _, v in pairs(self.pokemonDataList) do
			if v and v.widget and not gCS.LuaUtils.IsNull(v.widget) and not gCS.LuaUtils.IsNull(v.widget.gameObject) then
				UnityEngine.Object.Destroy(v.widget.gameObject)
			end
		end
	end

	self.pokemonDataList = {}

	if not self.isShow then
		self.isDataReady = true

		return
	end

	self:InsertAllHpBarData(gBattlePetsMgr.myChaosList)
	self:InsertAllHpBarData(gBattlePetsMgr.enemyChaosList)

	for i, v in pairs(self.pokemonDataList) do
		gCS.EffectMgr:PlayGameObjectMaterialEffect(self.summonEffectId, "ChaosMasterSummon" .. ulong.tostring(i), v.target.gameObject)
	end
end

function M:InsertAllHpBarData(pokemons)
	for _, v in ipairs(pokemons) do
		local unit = gCS.SceneDataMgr.GetUnit(v.UnitId)

		if not unit then
			if not gBattlePetsMgr.isTest then
				print_error("找不到怪物对应的unit:", ulong.tostring(v.UnitId))
			end
		else
			local isMyChaos = unit.ClientData.Camp == UX.Game.UnitCamp.BVBFriend
			local data = {
				widget = self:CreateHpBarWidget()
			}
			data.store = gStoreManager:GetStoreGroup(data.widget.Store):GetStoreByWidget(data.widget)
			data.store.hpBarTypeCtrl = isMyChaos and 0 or 1
			data.target = unit.PlayerObj
			data.unit = unit
			data.pokemon = v

			self:RefreshHpStore(data.store, v.MaxHp, v.MaxHp)
			self:RefreshEnergyStore(data.store, 0, 100)

			self.pokemonDataList[v.UnitId] = data
		end
	end
end

function M:CreateHpBarWidget()
	local go = UnityEngine.Object.Instantiate(self.bindData.hpBarTemplate.gameObject)

	go.transform:SetParent(self.bindData.hpBarContainerWidget.rectTransform, false)

	local widget = go:GetComponent(typeof(SGUI.UWidget))

	go:SetActive(true)
	widget:SetActive(true)

	return widget
end

function M:RefreshHpStore(store, curValue, maxValue)
	local rate = maxValue / LTConfig.ChaosMasterConfig.HpEverRange
	local divideCnt = math.ceil(rate)
	local totalLength = store.hpBarProgress.rectTransform.rect.width
	local divideLength = totalLength / rate

	store.hpBarProgress:ProgressToValue(curValue / maxValue)

	store.hpBarDivideList.colSpacing = divideLength

	store.hpBarDivideList:SetSimpleList(divideCnt)
end

function M:RefreshPokemonHp(pid)
	if not self.isShow or not self.pokemonDataList then
		return
	end

	local data = self.pokemonDataList[pid]

	if not data then
		print_error("Cannot find hp bar data for pid:", ulong.tostring(pid))

		return
	end

	if data.unit.ClientData.Hp <= 0 then
		print_debug("Pokemon is dead, remove hp bar. id:", ulong.tostring(pid))

		if self.focusedUnit == data.unit then
			self:UnFocusPokemon()
		end

		self:RefreshHpStore(data.store, 0, data.unit.ClientData.MaxHp)

		if data and data.widget and not gCS.LuaUtils.IsNull(data.widget) and not gCS.LuaUtils.IsNull(data.widget.gameObject) then
			UnityEngine.Object.Destroy(data.widget.gameObject)
		end

		self.pokemonDataList[pid] = nil
	else
		self:RefreshHpStore(data.store, data.unit.ClientData.Hp, data.unit.ClientData.MaxHp)
	end
end

function M:RefreshEnergyStore(store, curValue, maxValue)
	store.energyBarProgress:ProgressToValue(curValue / maxValue)
end

function M:RefreshPokemonEnergy(pid, curValue)
	if not self.isShow or not self.pokemonDataList then
		return
	end

	local data = self.pokemonDataList[pid]

	if not data then
		print_error("Cannot find hp bar data for pid:", ulong.tostring(pid))

		return
	end

	self:RefreshEnergyStore(data.store, curValue, 100)
end

function M:OnClickExitBtn()
	gDisplayMessageMgr:ShowMessageContent(LTConfig.ChaosMasterConfig.ExitBtnContent, gDisplayMessageId.SELECT, 1, function ()
		gBattlePetsMgr.clickExitHUDBtn = true

		gClientToGameSceneDelegate:AskExitBVBGame().Callback = function ()
			return
		end
	end, nil)
	self:SetShowExitBtn(true)
end

function M:OnClickSwitchBtn()
	self.isShowRightTooltip = not self.isShowRightTooltip

	if self.isShowRightTooltip then
		self:RefreshDpsTabList()
		self:RefreshDpsList()
	end

	self:SetShowRightTooltip(self.isShowRightTooltip)
end

function M:OnClickFullScreenBackBtn()
	self:RaycastCheck()
end

function M:RaycastCheck()
	local hitInfo = gCS.LuaUtils.RaycastByScreenPos(UnityEngine.Input.mousePosition, LX6.Constants.LayerConstants.AllWithoutPlayer)

	if not hitInfo.collider then
		self:UnFocusPokemon()

		return
	end

	for _, v in pairs(self.pokemonDataList) do
		if v.target and not gCS.LuaUtils.IsNull(v.target) and hitInfo.collider == v.unit.HitCollider then
			self:FocusPokemon(v)

			return
		end
	end

	self:UnFocusPokemon()
end

function M:FocusPokemon(pokemonData)
	if self.focusedUnit then
		self:UnFocusPokemon()
	end

	self.focusedUnit = pokemonData.unit

	self:ShowChaosTooltip(pokemonData.pokemon)
	self:SetUnitFocusEffect(pokemonData.unit)

	self.isUnitFocused = true
end

function M:UnFocusPokemon()
	self.isUnitFocused = false

	self:HideChaosTooltip()

	if self.focusedUnit then
		self:StopUnitFocusEffect()
		self:StopCubeFocusEffect()

		self.focusedUnit = nil
	end
end

function M:OnRenderDpsTabListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	btn:SetWidgetFaraway(false)

	btn.luaClick = self:CreateActionWithArgs(self.OnClickDpsTabListItem, index)
end

function M:OnClickDpsTabListItem(index)
	self.damageTabType = index == 0 and DamageTabType.DamageOther or DamageTabType.Damaged

	self:RefreshDpsTabList()
	self:RefreshDpsList(self.damageTabType)
end

function M:OnRenderDpsListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("ChaosMasterDpsTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.dpsList[index + 1]

	gBattlePetsMgr:RefreshDpsListItem(store, data)
end

function M:OnRenderChaosAttributeListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.chaosAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

function M:OnRenderEquipListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipList[index + 1]

	gBattlePetsMgr:RefreshEquipListItem(store, data)

	btn.luaClick = self:CreateActionWithArgs(self.OnClickEquipListItem, {
		index = index
	})
end

function M:OnClickEquipListItem(param)
	self:ShowEquipTooltip(param.index)
end

function M:OnRenderEquipAttributeListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipAttributeList[index + 1]

	gBattlePetsMgr:RefreshAttributeListItem(store, data)
end

function M:OnRenderEquipSkillListItem(btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.equipSkillList[index + 1]

	gBattlePetsMgr:RefreshSkillListItem(store, data)
end

function M:RefreshEndTime(endTime)
	self.endTime = endTime + gLogicTime.time
	self.isCountingDown = true
end

function M:RefreshDpsTabList()
	self.bindData.dpsTitleText = self.damageTabType == DamageTabType.DamageOther and LTConfig.TextScriptTextConfig.GetConfig(89901160).Text or LTConfig.TextScriptTextConfig.GetConfig(89901161).Text

	self.bindData.dpsTabList:SetSimpleList(2)
	self.bindData.dpsTabList:SetItemSelected(0, self.damageTabType == DamageTabType.DamageOther)
	self.bindData.dpsTabList:SetItemSelected(1, self.damageTabType == DamageTabType.Damaged)
end

function M:RefreshDpsList(type)
	if not self.isShow then
		return
	end

	self.damageTabType = type or self.damageTabType
	self.dpsList = {}

	if self.damageTabType == DamageTabType.DamageOther then
		for i, v in pairs(gBattlePetsMgr.agentDamageList) do
			local percent = math.floor(v / gBattlePetsMgr.totalDamage * 100)
			local limboChaCfg = self:GetLimboChaCfg(i)
			local item = {
				iconId = limboChaCfg and limboChaCfg.HeadIconID or 0,
				value = v,
				percent = percent,
				maxRate = v / gBattlePetsMgr.maxDamage
			}

			table.insert(self.dpsList, item)
		end
	else
		for i, v in pairs(gBattlePetsMgr.agentBeDamagedList) do
			local percent = math.floor(v / gBattlePetsMgr.totalBeDamaged * 100)
			local limboChaCfg = self:GetLimboChaCfg(i)
			local item = {
				iconId = limboChaCfg and limboChaCfg.HeadIconID or 0,
				value = v,
				percent = percent,
				maxRate = v / gBattlePetsMgr.maxBeDamaged
			}

			table.insert(self.dpsList, item)
		end
	end

	table.sort(self.dpsList, function (a, b)
		return b.value < a.value
	end)
	self.bindData.dpsList:SetSimpleList(#self.dpsList)
end

function M:GetLimboChaCfg(uid)
	if self.unitToLimboChaCfgDic[uid] then
		return self.unitToLimboChaCfgDic[uid]
	end

	local unit = gCS.SceneDataMgr.GetUnit(uid)
	local limboChaId = gBattlePetsMgr:GetLimboChaId(unit.TemplateId)
	local limboChaCfg = gBattlePetsMgr:GetChaosLimboChaConfig(limboChaId)
	self.unitToLimboChaCfgDic[uid] = limboChaCfg

	return limboChaCfg
end

function M:ShowChaosTooltip(pokemon)
	self.focusedToolTipPokemon = pokemon

	self:RefreshChaosTooltip(self.focusedToolTipPokemon)
	self:SetShowChaosTooltip(true)
	self:SetShowEquipTooltip(false)
end

function M:HideChaosTooltip()
	self.focusedToolTipPokemon = nil

	self:SetShowChaosTooltip(false)
	self:SetShowEquipTooltip(false)
end

function M:ShowEquipTooltip(index)
	local dic = {
		[0] = LTConfig.ChaosMasterBodyConfig.GetConfig(self.focusedToolTipPokemon.Body),
		LTConfig.ChaosMasterCampConfig.GetConfig(self.focusedToolTipPokemon.Camp),
		LTConfig.ChaosMasterWeaponConfig.GetConfig(self.focusedToolTipPokemon.Weapon)
	}
	local cfg = dic[index]

	self:RefreshEquipTooltip(cfg, index == 2)
	self:SetShowEquipTooltip(true)
end

function M:RefreshChaosTooltip(fightPokemon)
	local limboChaConfig = gBattlePetsMgr:GetChaosLimboChaConfig(fightPokemon.TemplateId)
	self.chaosInfoStore.nameText = limboChaConfig.Name
	self.chaosInfoStore.costText = gBattlePetsMgr:GetChaosCost(fightPokemon)
	self.chaosInfoStore.roleText = gBattlePetsMgr:GetChaosRoleName(limboChaConfig)
	self.chaosInfoStore.avatarIconId = limboChaConfig.HeadIconID
	local attrs = gBattlePetsMgr:GetFightPokemonAttributes(fightPokemon)
	self.chaosAttributeList = gBattlePetsMgr:GetChaosAttributeList(attrs)

	self.chaosInfoStore.attributeList:SetSimpleList(#self.chaosAttributeList)

	local bodyEquip = gBattlePetsMgr:GetChaosEquipItemDataByBody(fightPokemon.Body)
	local campEquip = gBattlePetsMgr:GetChaosEquipItemDataByCamp(fightPokemon.Camp)
	local weaponEquip = gBattlePetsMgr:GetChaosEquipItemDataByWeapon(fightPokemon.Weapon)
	self.equipList = {
		bodyEquip,
		campEquip,
		weaponEquip
	}

	self.chaosInfoStore.equipList:SetSimpleList(#self.equipList)

	local skillWidget = self.chaosInfoStore.skillWidget
	local skillStore = gStoreManager:GetStoreGroup(skillWidget.Store):GetStoreByWidget(skillWidget)

	if not limboChaConfig or not limboChaConfig.TalentBuff or #limboChaConfig.TalentBuff == 0 then
		return
	end

	local skillCfg = LTConfig.ChaosMasterPassiveSkillConfig.GetConfig(limboChaConfig.TalentBuff[1])

	if skillCfg then
		local data = {
			name = skillCfg.Name,
			type = LTConfig.TextScriptTextConfig.GetConfig(89901196).Text,
			description = skillCfg.Effect
		}

		gBattlePetsMgr:RefreshSkillListItem(skillStore, data)
	end
end

function M:RefreshEquipTooltip(cfg, isWeapon)
	self.equipInfoStore.nameText = cfg.BodyName or cfg.CampName or cfg.WeaponName
	local equipAttrs = gBattlePetsMgr:GetEquipAttributes(cfg)
	self.equipAttributeList = gBattlePetsMgr:GetEquipAttributeList(equipAttrs)

	self.equipInfoStore.attributeList:SetSimpleList(#self.equipAttributeList)

	local skillList = {}

	if not isWeapon then
		skillList = gBattlePetsMgr:GetBodyCampSkillList(cfg)
	else
		local limboChaCfg = LTConfig.ChaosMasterLimboChaConfig.GetConfig(self.focusedToolTipPokemon.LimboChaId)
		skillList = gBattlePetsMgr:GetWeaponSkillList(limboChaCfg)
	end

	self.equipSkillList = skillList

	self.equipInfoStore.skillList:SetSimpleList(#skillList)
end

function M:OnSyncBVBUpdateFightPokemons()
	self:RegisterPokemon()

	if self.focusedToolTipPokemon then
		for _, v in pairs(self.pokemonDataList) do
			if v.pokemon.UnitId == self.focusedToolTipPokemon.UnitId then
				self.focusedToolTipPokemon = v.pokemon

				self:RefreshChaosTooltip(v.pokemon)

				break
			end
		end
	end
end

function M:SetShowExitBtn(isShow)
	self.bindData.hideExitCtrl = isShow and 0 or 1
end

function M:SetShowRightTooltip(isShow)
	self.bindData.showRightTooltipCtrl = isShow and 1 or 0
end

function M:SetShowChaosTooltip(isShow)
	self.bindData.showChaosTooltipCtrl = isShow and 0 or 1
end

function M:SetShowEquipTooltip(isShow)
	self.bindData.showEquipInfoCtrl = isShow and 0 or 1
end

function M:EnableCamera()
	local npcCfg = LTConfig.ChaosMasterChaosBattleNpcConfig.GetConfig(gBattlePetsMgr.currentLevelNpcId)

	if not npcCfg then
		-- Nothing
	end

	local sceneId = npcCfg.ChaosBattleSceneId

	if not sceneId then
		return
	end

	local sceneCfg = LTConfig.ChaosMasterChaosBattleSceneConfig.GetConfig(sceneId)

	if not sceneCfg then
		return
	end

	local pos = Vector3.New(sceneCfg.BattleCenterPosition[1], sceneCfg.BattleCenterPosition[2], sceneCfg.BattleCenterPosition[3])
	self.sceneCenterPos = pos
	local playerIndex = 1

	if playerIndex ~= 1 or not sceneCfg.CameraOne then
		local eulerCfg = sceneCfg.CameraTwo
	end

	local camDirection = nil

	if #eulerCfg >= 3 then
		local rot = Quaternion.Euler(45, eulerCfg[2] + sceneCfg.BattleCenterRotation, eulerCfg[3])
		camDirection = rot * Vector3.New(0, 0, 1)
	end

	self.initCameraPos = pos + Vector3.up
	self.lastCameraPos = pos + Vector3.up
	self.targetCameraPos = pos + Vector3.up

	gCS.CameraDataMgr.cinemachineManager.commonAssignableTarget:SetPosition(self.lastCameraPos)
	gCS.CameraDataMgr.cinemachineManager:SetCustomFreeLook(pos, LTConfig.CameraFreeLookActionStatusConfig.BVB, 0, nil, camDirection)
	gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(0.5, 1)
end

function M:SetUnitFocusEffect(unit)
	self.focusedUnitEffectUuid = gCS.EffectMgr:PlayEffectsForUnit(unit, self.focusEffectId, nil, -1)
end

function M:StopUnitFocusEffect()
	if self.focusedUnitEffectUuid then
		gCS.EffectMgr:StopEffectAndSetCacheByUUIDNow(self.focusedUnitEffectUuid)

		self.focusedUnitEffectUuid = nil
	end
end

function M:SetCubeFocusEffect(cube, effectId)
	self:StopCubeFocusEffect()

	if not self.cellEffectUuidMap[cube.q] or not self.cellEffectUuidMap[cube.q][cube.r] then
		print_error("Cannot find cell effect for cube:", cube.q, cube.r)

		return
	end

	local uuid = self.cellEffectUuidMap[cube.q][cube.r]

	if not uuid then
		print_error("Cannot find cell effect UUID for cube:", cube.q, cube.r)

		return
	end

	gCS.EffectMgr:StopEffectAndSetCacheByUUIDNow(uuid)

	if not LTConfig.ChaosMasterConfig.GridEffectZoom then
		local scaleValue = 0.6
	end

	local scale = Vector3.New(scaleValue, scaleValue, scaleValue)
	local newUuid = gCS.EffectMgr:PlayEffectsRotateScale(effectId, self:CubeToWorld(cube), Vector3.zero, scale, 0, -1)
	self.cellEffectUuidMap[cube.q][cube.r] = newUuid
	self.focusedCube = cube
end

function M:StopCubeFocusEffect()
	if not self.focusedCube then
		return
	end

	if not self.cellEffectUuidMap[self.focusedCube.q] or not self.cellEffectUuidMap[self.focusedCube.q][self.focusedCube.r] then
		print_error("Cannot find cell effect for cube:", self.focusedCube.q, self.focusedCube.r)

		return
	end

	local uuid = self.cellEffectUuidMap[self.focusedCube.q][self.focusedCube.r]

	gCS.EffectMgr:StopEffectAndSetCacheByUUIDNow(uuid)
	self:CreateCell(self.focusedCube)

	self.focusedCube = nil
end

function M:GenerateHexMap()

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-20, warpins: 1 ---
	self.cellEffectUuidMap = {}
	local abandonList = {}
	abandonList[1] = {
		2,
		2
	}
	abandonList[2] = {
		-2,
		-2
	}
	abandonList[3] = {
		3,
		0
	}
	abandonList[4] = {
		-3,
		0
	}
	local gridSizeM = 7
	local halfM = math.floor(gridSizeM / 2)
	--- END OF BLOCK #0 ---

	for r=-halfM, halfM, 1
	LOOP BLOCK #1
	GO OUT TO BLOCK #16


	-- Decompilation error in this vicinity:
	--- BLOCK #1 21-27, warpins: 2 ---
	local absR = math.abs(r)
	--- END OF BLOCK #1 ---

	if absR % 2 == 0 then
	JUMP TO BLOCK #2
	else
	JUMP TO BLOCK #3
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #2 28-29, warpins: 1 ---
	--- END OF BLOCK #2 ---

	slot9 = if not gridSizeM then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 30-30, warpins: 2 ---
	local count = gridSizeM - 1
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 31-34, warpins: 2 ---
	local startQ, endQ = nil
	--- END OF BLOCK #4 ---

	if r < 0 then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 35-48, warpins: 1 ---
	endQ = math.ceil((count + 1) / 2) - math.floor((halfM - absR) / 2)
	startQ = -r - endQ
	--- END OF BLOCK #5 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #6 49-62, warpins: 1 ---
	startQ = -math.ceil((count + 1) / 2) + math.floor((halfM - absR) / 2)
	endQ = -r - startQ
	--- END OF BLOCK #6 ---

	FLOW; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #7 63-66, warpins: 2 ---
	--- END OF BLOCK #7 ---

	for q=startQ, endQ, 1
	LOOP BLOCK #8
	GO OUT TO BLOCK #15


	-- Decompilation error in this vicinity:
	--- BLOCK #8 67-76, warpins: 2 ---
	local s = -q - r
	local cube = {}
	cube.q = q
	cube.r = r
	cube.s = s

	--- END OF BLOCK #8 ---

	FLOW; TARGET BLOCK #9



	-- Decompilation error in this vicinity:
	--- BLOCK #9 77-79, warpins: 1 ---
	--- END OF BLOCK #9 ---

	if ab[1] == q then
	JUMP TO BLOCK #10
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #10 80-82, warpins: 1 ---
	--- END OF BLOCK #10 ---

	if ab[2] == r then
	JUMP TO BLOCK #11
	else
	JUMP TO BLOCK #12
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #11 83-83, warpins: 1 ---
	--- END OF BLOCK #11 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #12 84-85, warpins: 3 ---
	--- END OF BLOCK #12 ---




	-- Decompilation error in this vicinity:
	--- BLOCK #13 86-89, warpins: 1 ---
	self:CreateCell(cube)

	--- END OF BLOCK #13 ---

	FLOW; TARGET BLOCK #14



	-- Decompilation error in this vicinity:
	--- BLOCK #14 90-90, warpins: 2 ---
	--- END OF BLOCK #14 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #7



	-- Decompilation error in this vicinity:
	--- BLOCK #15 91-91, warpins: 1 ---
	--- END OF BLOCK #15 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #0



	-- Decompilation error in this vicinity:
	--- BLOCK #16 92-92, warpins: 1 ---
	return
	--- END OF BLOCK #16 ---



end

function M:CreateCell(cube)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-9, warpins: 1 ---
	local worldPos = self:CubeToWorld(cube)
	--- END OF BLOCK #0 ---

	slot3 = if not LTConfig.ChaosMasterConfig.GridEffectZoom then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 10-10, warpins: 1 ---
	local scaleValue = 0.6
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 11-32, warpins: 2 ---
	local scale = Vector3.New(scaleValue, scaleValue, scaleValue)
	local uuid = gCS.EffectMgr:PlayEffectsRotateScale(CellEffectId.Normal, worldPos, Vector3.zero, scale, 0, -1)
	--- END OF BLOCK #2 ---

	if self.cellEffectUuidMap == nil then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 33-34, warpins: 1 ---
	self.cellEffectUuidMap = {}
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 35-39, warpins: 2 ---
	--- END OF BLOCK #4 ---

	if self.cellEffectUuidMap[cube.q] == nil then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #6
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 40-43, warpins: 1 ---
	self.cellEffectUuidMap[cube.q] = {}
	--- END OF BLOCK #5 ---

	FLOW; TARGET BLOCK #6



	-- Decompilation error in this vicinity:
	--- BLOCK #6 44-49, warpins: 2 ---
	self.cellEffectUuidMap[cube.q][cube.r] = uuid

	return
	--- END OF BLOCK #6 ---



end

function M:CubeToWorld(cube)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	local eulerY = -90
	--- END OF BLOCK #0 ---

	slot3 = if not self.hexSize then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-5, warpins: 1 ---
	local hexSize = 1.5
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-8, warpins: 2 ---
	--- END OF BLOCK #2 ---

	slot4 = if not self.sceneCenterPos then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-10, warpins: 1 ---
	local worldCenter = Vector3.zero
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 11-43, warpins: 2 ---
	local rotY = Quaternion.Euler(0, eulerY, 0)
	local x = hexSize * (math.sqrt(3) * cube.q + math.sqrt(3) / 2 * cube.r)
	local z = hexSize * 1.5 * cube.r
	local localPos = Vector3.New(x, 0, z)

	return worldCenter + rotY * localPos
	--- END OF BLOCK #4 ---



end

function M:WorldToCube(worldPos)

	-- Decompilation error in this vicinity:
	--- BLOCK #0 1-4, warpins: 1 ---
	local eulerY = -90
	--- END OF BLOCK #0 ---

	slot3 = if not self.hexSize then
	JUMP TO BLOCK #1
	else
	JUMP TO BLOCK #2
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #1 5-5, warpins: 1 ---
	local hexSize = 1.5
	--- END OF BLOCK #1 ---

	FLOW; TARGET BLOCK #2



	-- Decompilation error in this vicinity:
	--- BLOCK #2 6-8, warpins: 2 ---
	--- END OF BLOCK #2 ---

	slot4 = if not self.sceneCenterPos then
	JUMP TO BLOCK #3
	else
	JUMP TO BLOCK #4
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #3 9-10, warpins: 1 ---
	local worldCenter = Vector3.zero
	--- END OF BLOCK #3 ---

	FLOW; TARGET BLOCK #4



	-- Decompilation error in this vicinity:
	--- BLOCK #4 11-62, warpins: 2 ---
	local rotY = Quaternion.Euler(0, eulerY, 0)
	local invRot = Quaternion.Inverse(rotY)
	local localPos = invRot * (worldPos - worldCenter)
	local qf = (math.sqrt(3) / 3 * localPos.x - 0.3333333333333333 * localPos.z) / hexSize
	local rf = 0.6666666666666666 * localPos.z / hexSize
	local sf = -qf - rf

	local function roundToInt(x)

		-- Decompilation error in this vicinity:
		--- BLOCK #0 1-4, warpins: 1 ---
		return math.floor(x + 0.5)
		--- END OF BLOCK #0 ---



	end

	local rq = roundToInt(qf)
	local rr = roundToInt(rf)
	local rs = roundToInt(sf)
	local diffQ = math.abs(rq - qf)
	local diffR = math.abs(rr - rf)
	local diffS = math.abs(rs - sf)
	--- END OF BLOCK #4 ---

	if diffR < diffQ then
	JUMP TO BLOCK #5
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #5 63-64, warpins: 1 ---
	--- END OF BLOCK #5 ---

	if diffS < diffQ then
	JUMP TO BLOCK #6
	else
	JUMP TO BLOCK #7
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #6 65-67, warpins: 1 ---
	rq = -rr - rs
	--- END OF BLOCK #6 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #7 68-69, warpins: 2 ---
	--- END OF BLOCK #7 ---

	if diffS < diffR then
	JUMP TO BLOCK #8
	else
	JUMP TO BLOCK #9
	end



	-- Decompilation error in this vicinity:
	--- BLOCK #8 70-72, warpins: 1 ---
	rr = -rq - rs
	--- END OF BLOCK #8 ---

	UNCONDITIONAL JUMP; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #9 73-74, warpins: 1 ---
	rs = -rq - rr

	--- END OF BLOCK #9 ---

	FLOW; TARGET BLOCK #10



	-- Decompilation error in this vicinity:
	--- BLOCK #10 75-80, warpins: 3 ---
	return {
		q = rq,
		r = rr,
		s = rs
	}
	--- END OF BLOCK #10 ---



end
