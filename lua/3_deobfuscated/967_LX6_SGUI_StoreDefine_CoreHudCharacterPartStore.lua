local GameConfig = LTConfig.GameConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local BuffConfig = LTConfig.BuffConfig
local SkillResourcesConfig = LTConfig.SkillResourcesConfig
local AnimMgr = SGUI.AnimMgr
C_CoreHudCharacterPartStore = DefClass("C_CoreHudCharacterPartStore", C_CoreHudCharacterPartStore, C_StoreGroup)
GroupName2Class.CoreHudCharacterPartStore = C_CoreHudCharacterPartStore
local M = C_CoreHudCharacterPartStore
local EnergyType = {
	Low = 0,
	Enough = 1
}

function M:ctor()
	self.initHp = {}
	self.fightViewDatas = {}
	self.buffUIList = {}
	self.BattlePrototypeCommonUIStore_Slider_CurValue = 0
	self.BattlePrototypeCommonUIStore_Slider_MaxValue = 100
	self.showFightResHUD = false
	self.fightResUITypeCtrl = 1
	self.fightWeaponResHudFillMaxValue = 100
	self.fightWeaponResHudFillCurValue = 50
end

function M:OnAwake()
	return
end

function M:OnDestroy()
	gBattleMgr.characterPartPanel = nil

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
end

function M:OnStart()
	gBattleMgr.characterPartPanel = self

	self:BindDataByScheme(gCS.LuaUtils.GetActiveDevice())
	self:BindCharacterData()
	self:RegisterBtnAction()
	self:SyncRefreshFight()
	self:OnRefreshBuffs()
	self:RefreshWeaponFightResHUD()
	self:UpdatePoliceNumbValue(0, true)
	gMainMenuMgr:SetAwakeUI("awakeSimpleQuickMenuPanel")
end

function M:OnClose()
	gBattleMgr.characterPartPanel = nil
end

function M:BeforeSwitchScene()
	self.initHp = {}
	self.playingSwitchCharacterAni = false
end

function M:GetInstRefByPath(path)
	local inst = self.characterPartData[path]

	if not inst then
		return nil
	end

	return inst
end

function M:BindDataByScheme(scheme)
	self.characterPartData = self.bindData
end

function M:BindCharacterData()
	self.characterPartData.buffList.luaSimpleRenderItem = self:CreateAction("OnRenderBuffItem")
	self.hpBar = self:GetStoreByWidget(self.characterPartData.playerHpBar)
	self.weaponFightResHUDRoot = self:GetStoreByWidget(self.characterPartData.weaponFightResHUDRoot)
	self.characterPartData.weaponFightResHUDRoot.OnRenderTab = self:CreateAction("FightResHUDRootRenderTab")
	self.bustValueCom = self:GetStoreByWidget(self.characterPartData.bustValueCom)
end

function M:RegisterBtnAction()
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self:CreateAction("ReBindUnitDataSetEvent"),
		[gEventConstants.REFRESH_HEADVIEW_BUFFS] = self:CreateAction("OnRefreshBuffs"),
		[gEventConstants.BEFORE_SWITCH_SCENE] = self:CreateAction("BeforeSwitchScene"),
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self:CreateAction("OnSkillResourceChanged")
	}

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
	self:RegisterMessageEvents(self.msgEvents)
	self:InitDataSetEvents()
end

function M:InitDataSetEvents()
	local refreshHpHandler = self:CreateAction("OnRefreshHp")
	self.dataSetEvents = {
		{
			gDataSetManager.myUnit,
			"hp",
			refreshHpHandler
		},
		{
			gDataSetManager.myUnit,
			"maxhp",
			refreshHpHandler
		}
	}

	self:RegisterDataSetEvents(self.dataSetEvents)
end

function M:ReBindUnitDataSetEvent()
	if not self.dataSetEvents then
		return
	end

	self:ClearDataSetEvents()
	self:InitDataSetEvents()
end

function M:SyncRefreshFight()
	if not self.STATE_EnableOnce then
		return
	end

	self:BuildFightViewData()
end

function M:BuildFightViewData()
	self.fightSpirits = gBattleSpiritMgr:GetBattleSpiritList()
	self.fightViewDatas = {}
	local spiritData = self.fightSpirits[1]

	if spiritData then
		local cfgFightSpirit = FightSpiritConfig.GetConfig(spiritData.templateId)

		if not cfgFightSpirit then
			print_error("FightSpiritConfig 找不到战灵 ", spiritData.templateId)
		else
			local newData = {
				index = 1,
				allTime = 1,
				spiritData = spiritData
			}
			self.fightViewDatas[1] = newData
		end
	else
		self.fightViewDatas[1] = nil
	end
end

function M:OnRefreshBuffs(eventId, pid)
	if pid == nil and gCS.MyPlayerManager.PlayerUnit then
		pid = gCS.MyPlayerManager.PlayerUnit.Pid
	end

	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit or not unit.IsMe then
		return
	end

	local allBuffs = gBuffUtils.GetCSBuffList(pid)

	if #allBuffs == 0 then
		self.characterPartData.buffList:SetSimpleList(0)

		return
	end

	local max_conut = 5
	local maybeBuffs = {}

	for i = 1, #allBuffs do
		local id = allBuffs[i].Id
		local cfg = BuffConfig.GetConfig(id)

		if cfg and not cfg.IsHidden and cfg.IconIdSGUI then
			table.insert(maybeBuffs, allBuffs[i])
		end
	end

	self.showBuffs = {}

	if max_conut < #maybeBuffs then
		for i = #maybeBuffs - 4, #maybeBuffs do
			table.insert(self.showBuffs, maybeBuffs[i])
		end
	else
		self.showBuffs = maybeBuffs
	end

	if #self.showBuffs == 0 then
		self.characterPartData.buffList:SetSimpleList(0)

		return
	end

	table.clear(self.buffUIList)

	for i = 1, max_conut do
		local iconId = 0
		local isShow = false
		local isShowCD = false
		local tier = ""
		local cfg = nil

		if i <= #self.showBuffs then
			cfg = BuffConfig.GetConfig(self.showBuffs[i].Id)
			iconId = cfg.IconIdSGUI
			isShow = true

			if self.showBuffs[i].Tier and self.showBuffs[i].Tier > 1 then
				tier = self.showBuffs[i].Tier
			end
		end

		if cfg then
			local expireTime = math.max(self.showBuffs[i].ExpireTime - gCS.TimeManager.ServerUnixTime, 0)
			local item = {
				iconId = iconId,
				isShowBuff = isShow,
				isShowCD = isShowCD,
				expireTime = self.showBuffs[i].ExpireTime,
				duration = cfg.Duration,
				fillAmount = math.min(expireTime / cfg.Duration, 1),
				templateId = self.showBuffs[i].Id,
				tier = tier,
				cfg = cfg
			}

			table.insert(self.buffUIList, item)
		end
	end

	self.characterPartData.buffList:SetSimpleList(#self.buffUIList)
end

function M:OnRenderBuffItem(btn, index)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if not store then
		return
	end

	local data = self.buffUIList[index + 1]
	store.iconId = data.iconId
	store.fillAmount = data.fillAmount
	store.tier = data.tier
	store.cfg = data.cfg

	store.fill:SetActive(data.isShowCD)

	store.button.luaRenderTooltip = self:CreateAction("OnBuffToolTipRender")
end

function M:OnBuffToolTipRender(btn, popup, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore"):GetStoreByWidget(btn)
	local popupStore = gStoreManager:GetStoreGroup("CommonBuffTip"):GetStoreByWidget(popup)

	if not popupStore or not popupStore then
		return
	end

	popupStore.des = store.cfg.Description
	popupStore.arrowCtrl = 1
end

function M:OnRefreshHp()
	local hpFill, shieldFill = self:CalcHpAndShieldFill()

	if not self.initHp[gCS.MyPlayerManager.PlayerUnit.Pid] then
		self.hpBar.hp.fillAmount = hpFill
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill
		self.hpBar.hpSlowTween.fillAmount = hpFill
	elseif hpFill <= self.hpValue then
		self.hpBar.hp.fillAmount = hpFill
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill

		AnimMgr.Kill(self.hpBar.hp.transform, "PlayerRecoverHpTween")
		AnimMgr.Kill(self.hpBar.hpSlowTween.transform, "PlayerWeakHpTween")
		AnimMgr.DoFill(self.hpBar.hpSlowTween, "PlayerWeakHpTween", hpFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)
	elseif self.hpValue < hpFill then
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill
		self.hpBar.hpSlowTween.fillAmount = hpFill

		AnimMgr.Kill(self.hpBar.hp.transform, "PlayerRecoverHpTween")
		AnimMgr.Kill(self.hpBar.hpSlowTween.transform, "PlayerWeakHpTween")
		AnimMgr.DoFill(self.hpBar.hp, "PlayerRecoverHpTween", hpFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)
		self:PlayRecoverAni()
	end

	self.hpValue = hpFill
	self.initHp[gCS.MyPlayerManager.PlayerUnit.Pid] = true

	gMainMenuMgr:RefreshFullScreenLowHpAni(hpFill)
	gMainMenuMgr:RecoverHpShowBattleUI(true)
end

function M:CalcHpAndShieldFill()
	local hpFill = 0
	local shieldFill = 0
	local hpValue = gDataSetManager.myUnit.hp or 0
	local maxHpValue = gDataSetManager.myUnit.maxhp or 0
	local shieldValue = gDataSetManager.myUnit.shield or 0

	if maxHpValue > hpValue + shieldValue then
		local total = maxHpValue
		hpFill = total > 0 and hpValue / total or 0
		shieldFill = total > 0 and (hpValue + shieldValue) / total or 0
	else
		local total = hpValue + shieldValue
		hpFill = total > 0 and hpValue / total or 0
		shieldFill = 1
	end

	return hpFill, shieldFill
end

function M:PlayRecoverAni()
	gBattleMgr:CommonPlayAniTool(self.hpBar.recoverAni, nil, 0, 1)
end

function M:PlayFullScreenLowHpAni(showLowHpEffect)
	if self.characterPartData.showLowHpEffect ~= showLowHpEffect then
		local openAniName = "S_vx_LowHp_open"
		local loopAniName = "S_vx_LowHp_loop"
		local ani = self.characterPartData.fullScreenLowHpAni
		self.characterPartData.showLowHpEffect = showLowHpEffect

		self.characterPartData.fullScreenLowHp.gameObject:SetActive(showLowHpEffect)

		self.fullScreenAni_LowHpTimer = gBattleMgr:CommonPlayAniTool(ani, openAniName, 0, 1, true, function ()
			if not self.fullScreenAni_LowHpTimer then
				return
			end

			self.fullScreenAni_LowHpTimer = nil

			gBattleMgr:CommonPlayAniTool(ani, loopAniName, 0, 1)
		end)
	end
end

function M:UpdateFullScreenLowHpAniSpeed(hpFill, showLowHpEffect)
	if showLowHpEffect then
		local loopAniName = "S_vx_LowHp_loop"
		local speed = 1
		local percent = 1

		for i = 1, #GameConfig.LowHpEffectActiveSpeedUp do
			local item = GameConfig.LowHpEffectActiveSpeedUp[i]

			if hpFill <= item.percent * GameConfig.LowHpEffectActive and item.percent < percent then
				speed = item.speed
				percent = item.percent
			end
		end

		self.characterPartData.fullScreenLowHpAni:get_Item(loopAniName).speed = speed
	end
end

function M:GetBattlePrototypeCommonUI_Slider()
	return self.characterPartData.BattlePrototypeCommonUI_Slider
end

function M:GetBattlePrototypeCommonUIStore_Slider()
	local store = self:GetStoreByWidget(self.characterPartData.BattlePrototypeCommonUI_Slider)

	return store
end

function M:BattlePrototypeCommonUIStore_Slider_SetMaxValue(value)
	self.BattlePrototypeCommonUIStore_Slider_MaxValue = value
end

function M:BattlePrototypeCommonUIStore_Slider_SetCurValue(value)
	self.BattlePrototypeCommonUIStore_Slider_CurValue = value
end

function M:BattlePrototypeCommonUIStore_Slider_AddValue(value)
	self.BattlePrototypeCommonUIStore_Slider_CurValue = self.BattlePrototypeCommonUIStore_Slider_CurValue + value
end

function M:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
	local store = self:GetBattlePrototypeCommonUIStore_Slider()
	local fill = self.BattlePrototypeCommonUIStore_Slider_CurValue / self.BattlePrototypeCommonUIStore_Slider_MaxValue
	store.fillAmount = Mathf.Clamp01(fill)
end

function M:FightResHUDRootRenderTab(index, widget)
	self.weaponFightResHUD = gStoreManager:GetStoreGroup("WeaponFightResUIStore"):GetStoreByWidget(widget)

	self:ResetTaiChiValue()
	self:ResetWingChunValue()
	self:InitStaminaBar()

	if self.staminaBarFill then
		self:UpdateStaminaBarFill(self.staminaBarFill)
	end
end

function M:RefreshWeaponFightResHUD()
	self:ShowWeaponFightResHUD(self.showFightResHUD)
	self:ChangeWeaponFightResHUD(self.fightResUITypeCtrl)
	self:CheckPlayOverHeatAni()
	self:SetWeaponFightResHUDFillMaxValue(self.fightWeaponResHudFillMaxValue)
	self:SetWeaponFightResHUDFillCurValue(self.fightWeaponResHudFillCurValue)
end

function M:ShowWeaponFightResHUD(show)
	self.showFightResHUD = show

	if self.characterPartData and self.characterPartData.weaponFightResHUDRoot then
		self.characterPartData.weaponFightResHUDRoot.transform:SetLocalPositionZ(show and 0 or gCS.GuiUtils.UI_TRANS_OUT_RANGE)
	end
end

function M:ChangeWeaponFightResHUD(type)
	if not gCS.LuaUtils.IsNonMobileAdaptive() and type == 0 then
		type = type + 1
	end

	self.fightResUITypeCtrl = type

	if self.characterPartData and self.characterPartData.weaponFightResHUDRoot then
		self.characterPartData.weaponFightResHUDRoot.selectedIndex = type - 1

		self:InitStaminaBar()
	end
end

function M:OnSkillResourceChanged(eventId, msg)
	local table = msg
	local templateId = table[0]

	if templateId == SkillResourcesConfig.MainChrEnergy then
		self:SetWeaponFightResHUDFillMaxValue(table[2])
		self:SetWeaponFightResHUDFillCurValue(table[1])
	elseif templateId == SkillResourcesConfig.PoliceNumbValue then
		self:UpdatePoliceNumbValue(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.TaijiEnergyYang1 then
		self:UpdateTaiChiValueYang1(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.TaijiEnergyYang2 then
		self:UpdateTaiChiValueYang2(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.TaijiEnergyYin1 then
		self:UpdateTaiChiValueYin1(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.TaijiEnergyYin2 then
		self:UpdateTaiChiValueYin2(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.StaminaBar then
		self:UpdateStaminaBarFill(table[1] / table[2])
	elseif templateId == SkillResourcesConfig.YongChunCombolCount then
		self:UpdateWingChunValue(table[1])
	end

	gBattleMgr:RefreshFightSpiritUniqueSkillID(templateId, table[1], table[2])
end

function M:SetWeaponFightResHUDFillMaxValue(value)
	self.fightWeaponResHudFillMaxValue = value
end

function M:SetWeaponFightResHUDFillCurValue(value)
	if not self.weaponFightResHUD then
		return
	end

	self.fightWeaponResHudFillCurValue = value
	self.weaponFightResHUD.fightResUIFill = value / self.fightWeaponResHudFillMaxValue
	self.weaponFightResHUD.fightResUIFillColorCtrl = GameConfig.FightResHUDPlayHotEffectPercent <= self.weaponFightResHUD.fightResUIFill and 1 or 0
end

function M:CheckPlayOverHeatAni()
	if not self.weaponFightResHUD then
		return
	end

	self.weaponFightResHUD.overheatCtrl = gBattleMgr.weaponOverHot and 0 or 1

	if self.weaponFightResHUD.overheatCtrl == 0 then
		self:WeaponFightResHUDPlayAddValueAni()
	end
end

function M:WeaponFightResHUDPlayAddValueAni()
	if not self.weaponFightResHUD then
		return
	end

	local ani = self.weaponFightResHUD.addValueAni

	ani:Play()
end

function M:UpdateTaiChiValueYin1(value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin1 then
		return
	end

	self.weaponFightResHUD.yin1.fillAmount = value

	self:CheckPlayTaiChiAni()
end

function M:UpdateTaiChiValueYin2(value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin2 then
		return
	end

	self.weaponFightResHUD.yin2.fillAmount = value

	self:CheckPlayTaiChiAni()
end

function M:UpdateTaiChiValueYang1(value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yang1 then
		return
	end

	self.weaponFightResHUD.yang1.fillAmount = value

	self:CheckPlayTaiChiAni()
end

function M:UpdateTaiChiValueYang2(value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yang2 then
		return
	end

	self.weaponFightResHUD.yang2.fillAmount = value

	self:CheckPlayTaiChiAni()
end

function M:CheckPlayTaiChiAni()
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin1 or not self.weaponFightResHUD.yang1 then
		return
	end

	local playAni = self.weaponFightResHUD.yin1.fillAmount == 1 and self.weaponFightResHUD.yang1.fillAmount == 1

	if self.playTaiChiAni ~= playAni then
		self.playTaiChiAni = playAni

		if playAni then
			gBattleMgr:CommonPlayAniTool(self.weaponFightResHUD.ani, nil, 0, 1)
		else
			gBattleMgr:CommonStopAniTool(self.weaponFightResHUD.ani, nil)
		end
	end
end

function M:ResetTaiChiValue()
	if self.fightResUITypeCtrl ~= 3 then
		return
	end

	self:UpdateTaiChiValueYin1(0)
	self:UpdateTaiChiValueYin2(0)
	self:UpdateTaiChiValueYang1(0)
	self:UpdateTaiChiValueYang2(0)
end

function M:UpdateWingChunValue(value)
	if not self.weaponFightResHUD then
		return
	end

	self.weaponFightResHUD.count = value
end

function M:ResetWingChunValue()
	self:UpdateWingChunValue(0)
end

function M:InitStaminaBar()
	if self.fightResUITypeCtrl ~= 5 or not self.weaponFightResHUD or not self.weaponFightResHUD.rootTrans or not self.weaponFightResHUD.splitTrans then
		return
	end

	local curWidth = self.weaponFightResHUD.rootTrans.rect.width
	local onceCostPercent = self:GetStaminaCostOnce() - 0.5
	local pos = Vector3.forward * -100000

	if onceCostPercent > -0.5 then
		pos = Vector3.right * onceCostPercent * curWidth
	end

	self.weaponFightResHUD.splitTrans:SetLocalPosition(pos)
end

function M:UpdateStaminaBarFill(fill)
	self.staminaBarFill = fill

	if not self.weaponFightResHUD or not self.weaponFightResHUD.fillCom then
		return
	end

	self.weaponFightResHUD.fillCom.fillAmount = fill
	self.weaponFightResHUD.energyCtrl = self:CheckStaminaBarEnough() and EnergyType.Enough or EnergyType.Low
end

function M:CheckStaminaBarEnough()
	local skillId = gCS.BattleManager.GetBasicSkillId()
	local result = false

	if gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId) then
		result = true
	end

	return result
end

function M:GetStaminaCostOnce()
	local skillId = gCS.BattleManager.GetBasicSkillId()
	local skillConfig = LTConfig.SkillConfig.GetConfig(skillId)
	local mul = gCS.BattleManager.GetStaminaBarUseEfficiency()
	local result = 0

	if skillConfig ~= nil and skillConfig.UseSkillRes ~= nil and #skillConfig.UseSkillRes > 0 then
		if skillConfig.UseSkillRes[1].IsPercentage then
			result = skillConfig.UseSkillRes[1].Value * mul
		else
			local cfg = SkillResourcesConfig.GetConfig(SkillResourcesConfig.StaminaBar)
			local max = cfg.Max
			result = skillConfig.UseSkillRes[1].Value * mul / max
		end
	end

	result = Mathf.Clamp01(result)

	return result
end

function M:UpdatePoliceNumbValue(fill, force)
	local show = fill > 0

	if self.policeNumShow ~= show or force then
		self.policeNumShow = show

		self.characterPartData.bustValueCom.gameObject:SetActive(show)
	end

	self.bustValueCom.fillCom.fillAmount = fill
	self.bustValueCom.fillText = math.ceil(fill * 100)

	if GameConfig.BustValueAniThreshold < fill then
		gBattleMgr:CommonPlayAniTool(self.bustValueCom.redAni, "S_vx_BustValue_loop", 0, 1)
	else
		gBattleMgr:CommonStopAniTool(self.bustValueCom.redAni, "S_vx_BustValue_loop")
	end

	if fill < GameConfig.BustValueColorChange[1] then
		self.bustValueCom.colorCtrl = 0
	elseif fill < GameConfig.BustValueColorChange[2] then
		self.bustValueCom.colorCtrl = 1
	else
		self.bustValueCom.colorCtrl = 2
	end
end
