-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CoreHudCharacterPartStore.lua
-- Decompiled from: 01488_CoreHudCharacterPartStore.lua_691d066d6262.luajit

local GameConfig = LTConfig.GameConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local BuffConfig = LTConfig.BuffConfig
local SkillResourcesConfig = LTConfig.SkillResourcesConfig
local SkillHUDBindLogicConfig = LTConfig.SkillResourcesSkillHUDBindLogicConfig
local HudInterfaceConfig = LTConfig.HudInterfaceConfig
local AnimMgr = SGUI.AnimMgr
local DOTween = DOTween
local Ease = DG.Tweening.Ease
C_CoreHudCharacterPartStore = DefClass("C_CoreHudCharacterPartStore", C_CoreHudCharacterPartStore, C_StoreGroup)
GroupName2Class.CoreHudCharacterPartStore = C_CoreHudCharacterPartStore
local M = C_CoreHudCharacterPartStore
local EnergyType = {
	["\\xa2gq"] = 0,
	["9F\\x9e\\x9b\\x84I"] = 1
}

M.ctor = function(self)
	self.DEFINE_DynamicOnUpdate = true
	self.initHp = {}
	self.fightViewDatas = {}
	self.buffUIList = {}
	self.buffItemStores = {}
	self.buffWindowItemStores = {}
	self.BattlePrototypeCommonUIStore_Slider_CurValue = 0
	self.BattlePrototypeCommonUIStore_Slider_MaxValue = 100
	self.showFightResHUD = false
	self.fightResUITypeCtrl = 1
	self.fightWeaponResHudFillMaxValue = 100
	self.fightWeaponResHudFillCurValue = 50
	self.taiChiSwordSlots = {}
	self.taiChiSwordUltraSlots = {}

	self.ResetXingyiquanRecorder(self)

	self.isWaterGunUI = false
	self.hasShield = false
	self.isStart = false

	self.InitBindWidgetData(self)

	self.HPTypeEnum = {
		["\\xb95,3q\\x93F\\xfd8\\xbd\\xb7"] = 2,
		["\\x9c\\xb0\\xaex\\xeb="] = 1,
		["/@\\x94\\x87\\x8fE"] = 3,
		["2G\\x83\\x83\\x82M"] = 0
	}
end

M.OnAwake = function(self)
end

M.OnDestroy = function(self)
	gStoreManager:UnregisterDynamicOnUpdate(self)

	self.isStart = false
	gBattleMgr.characterPartPanel = nil

	self:ClearDataSetEvents()
	self:ClearMessageEvents()
end

M.OnStart = function(self)
	self.isStart = true
	gBattleMgr.characterPartPanel = self

	self:BindDataByScheme(gCS.LuaUtils.GetActiveDevice())
	self:BindCharacterData()
	self:RegisterBtnAction()
	self:BuildSkillHUDBindCache()
	self:SyncRefreshFight()
	self:OnRefreshBuffs()
	self:RefreshWeaponFightResHUD()
	self:UpdatePoliceNumbValue(0, true)
	gMainMenuMgr:SetAwakeUI("awakeSimpleQuickMenuPanel")
	gCoreHudUIManager:OnRefreshForAwakeSimpleQuickMenuUI()
	self:InitStaminaBar()
	self:SyncFallingDownState()
	self:UpdateMobileOnBattleCtrl()
end

M.UpdateMobileOnBattleCtrl = function(self)
	gCoreHudUIManager:ApplyMobileOnBattleCtrl(self.bindData)
end

M.OnClose = function(self)
	gBattleMgr.characterPartPanel = nil
	self.skillHUDAnimationStates = nil
	self.skillHUDAnimationWarnings = nil
end

M.BeforeSwitchScene = function(self)
	self.initHp = {}
	self.playingSwitchCharacterAni = false
	self.hasShield = false
end

M.OnLanguageChange = function(self, lang)
	self.OnRefreshBuffs(self)
end

M.GetInstRefByPath = function(self, path)
	if not self.characterPartData then
		return nil
	end

	local inst = self.characterPartData[path]

	if not inst then
		return nil
	end

	return inst
end

M.BindDataByScheme = function(self, scheme)
	self.characterPartData = self.bindData
end

M.BindCharacterData = function(self)
	self.characterPartData.closeTooltipBtn.luaClick = self.CreateAction(self, "OnCloseTooltipBtnClick")
	self.characterPartData.buffList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBuffItem")
	local buffTipsWindowStore = self.GetStoreByWidget(self, self.characterPartData.buffTipsWindow)

	if buffTipsWindowStore then
		buffTipsWindowStore.buffDetailList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderBuffWindowItem")
	end

	self.hpBar = self.GetStoreByWidget(self, self.characterPartData.playerHpBar)
	self.weaponFightResHUDRoot = self.GetStoreByWidget(self, self.characterPartData.weaponFightResHUDRoot)
	self.characterPartData.weaponFightResHUDRoot.OnRenderTab = self.CreateAction(self, "FightResHUDRootRenderTab")
	self.bustValueCom = self.GetStoreByWidget(self, self.characterPartData.bustValueCom)
	self.staminaBar = self.GetStoreByWidget(self, self.characterPartData.staminaBar)
	self.waterHpBar = self.GetStoreByWidget(self, self.characterPartData.waterHpBar)

	if self.bindData.oxygenTab then
		self.bindData.oxygenTab.OnRenderTab = self.CreateAction(self, "OnOxygenRenderTab")
	end
end

M.RegisterBtnAction = function(self)
	self.msgEvents = {
		[gEventConstants.CHANGE_MY_UNIT] = self.CreateAction(self, "ReBindUnitDataSetEvent"),
		[gEventConstants.REFRESH_HEADVIEW_BUFFS] = self.CreateAction(self, "OnRefreshBuffs"),
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = self.CreateAction(self, "BeforeSwitchScene"),
		[gEventConstants.NOTIFY_CHANGE_SKILL_RESOURCE] = self.CreateAction(self, "OnSkillResourceChanged"),
		[gEventConstants.SPIRIT_INFO_CHANGED] = self.CreateAction(self, "OnSpiritInfoChanged"),
		[gEventConstants.ON_WATER_UI] = self.CreateAction(self, "OnWaterGunUI"),
		[gEventConstants.FALLING_DOWN_STATE] = self.CreateAction(self, "OnPlayerFallingDownChanged"),
		[gEventConstants.FALL_DOWN_PROGRESS_UPDATE] = self.CreateAction(self, "OnFallDownProgressChanged"),
		[gEventConstants.ON_SHOW_UI_EFFECT] = self.CreateAction(self, "OnShowUIEffect"),
		[gEventConstants.SHIELD_CHANGE] = self.CreateAction(self, "OnShieldChange"),
		[gEventConstants.SHIELD_VALUE_CHANGE] = self.CreateAction(self, "OnShieldValueChange"),
		[gEventConstants.FORCE_REFRESH_PLAYER_HP_HUD] = self.CreateAction(self, "OnRefreshHp"),
		[gEventConstants.ON_OXYGEN_OPEN] = self.CreateAction(self, "CheckOxygenShow"),
		[gEventConstants.ON_OXYGEN_UPDATE] = self.CreateAction(self, "UpdateOxygenUI")
	}

	self.ClearDataSetEvents(self)
	self.ClearMessageEvents(self)
	self.RegisterMessageEvents(self, self.msgEvents)
	self.InitDataSetEvents(self)
end

M.InitDataSetEvents = function(self)
	local refreshHpHandler = self.CreateAction(self, "OnRefreshHp")
	self.dataSetEvents = {
		{
			gDataSetManager.myUnit,
			"",
			refreshHpHandler
		},
		{
			gDataSetManager.myUnit,
			"@\\xaf\\xba\\xa7\\xa6",
			refreshHpHandler
		},
		{
			gCoreHudUIManager.buttonStateMonitor,
			gCoreHudUIManager.skillType.Hp,
			self.CreateAction(self, "UpdateHpUIState")
		},
		{
			gCoreHudUIManager.battleHudAutoHideState,
			"5\\x92䧢Ǩ\\x98\\x89\\xc9\\xf6>ù4\\x8d\\xee",
			self.CreateAction(self, "UpdateMobileOnBattleCtrl")
		},
		{
			gRaidDataManager,
			".I\\x98\\x8a\\xaaE",
			self.CreateAction(self, "RefreshRaidIdChange")
		}
	}

	self.RegisterDataSetEvents(self, self.dataSetEvents)
end

M.UpdateHpUIState = function(self, data)
	local state = data.value

	if not state then
		return
	end

	local visible = state[1]

	if self.characterPartData and self.characterPartData.playerHpBar then
		gBattleMgr.playerHpBarActive = visible

		self.characterPartData.playerHpBar:SetActiveFastest(visible)
	end

	self.ShowWeaponFightResHUD(self, visible)
end

M.ReBindUnitDataSetEvent = function(self)
	if not self.dataSetEvents then
		return
	end

	self.ClearDataSetEvents(self)
	self.InitDataSetEvents(self)
end

M.SyncRefreshFight = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.BuildFightViewData(self)
end

M.BuildFightViewData = function(self)
	self.fightSpirits = gBattleSpiritMgr:GetBattleSpiritList()
	self.fightViewDatas = {}
	local spiritData = self.fightSpirits[1]

	if spiritData then
		local cfgFightSpirit = FightSpiritConfig.GetConfig(spiritData.templateId)

		if not cfgFightSpirit then
			print_error("FightSpiritConfig 找不到战灵 ", spiritData.templateId)
		else
			local newData = {
				["D\\xa0\\xa6\\xaa\\xae"] = 1,
				["\\xd8\\xd7))\\xf4"] = 1,
				spiritData = spiritData
			}
			self.fightViewDatas[1] = newData
		end
	else
		self.fightViewDatas[1] = nil
	end
end

local FormatExpireTime = function(remaining)
	if remaining < 0 then
		return "00:00"
	end

	local totalSeconds = math.floor(remaining)
	local mins = math.floor(totalSeconds / 60)
	local secs = totalSeconds % 60

	return string.format("%02d:%02d", mins, secs)
end

M.OnRefreshBuffs = function(self, eventId, pid)
	if pid ~= nil then
		if gCS.MyPlayerManager.PlayerUnit then
			pid = gCS.MyPlayerManager.PlayerUnit.Pid
		else
			return
		end
	end

	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit or not unit.IsMe then
		return
	end

	local allBuffs = gBuffUtils.GetCSBuffList(pid)

	if #allBuffs ~= 0 then
		self.characterPartData.buffList:SetSimpleList(0)
		gStoreManager:UnregisterDynamicOnUpdate(self)
		self:OnCloseTooltipBtnClick()

		return
	end

	local max_count = HudInterfaceConfig.CharBuffMaxNumber
	local maybeBuffs = {}

	for i = 1, #allBuffs do
		local id = allBuffs[i].Id
		local cfg = BuffConfig.GetConfig(id)

		if cfg and not cfg.IsHidden and cfg.IconIdSGUI then
			table.insert(maybeBuffs, allBuffs[i])
		end
	end

	local priorityBuffs = {}
	local normalBuffs = {}

	for i = 1, #maybeBuffs do
		local cfg = BuffConfig.GetConfig(maybeBuffs[i].Id)

		if cfg and cfg.Type ~= 3 then
			table.insert(priorityBuffs, maybeBuffs[i])
		else
			table.insert(normalBuffs, maybeBuffs[i])
		end
	end

	self.showBuffs = {}

	if max_count >= #priorityBuffs then
		for i = #priorityBuffs - max_count + 1, #priorityBuffs do
			table.insert(self.showBuffs, priorityBuffs[i])
		end
	else
		for i = 1, #priorityBuffs do
			table.insert(self.showBuffs, priorityBuffs[i])
		end

		local remainCount = max_count - #priorityBuffs

		if remainCount <= 0 and #normalBuffs <= 0 then
			local startIdx = math.max(#normalBuffs - remainCount + 1, 1)

			for i = startIdx, #normalBuffs do
				table.insert(self.showBuffs, normalBuffs[i])
			end
		end
	end

	if #self.showBuffs ~= 0 then
		self.characterPartData.buffList:SetSimpleList(0)
		gStoreManager:UnregisterDynamicOnUpdate(self)
		self:OnCloseTooltipBtnClick()

		return
	end

	table.clear(self.buffUIList)

	for i = 1, max_count do
		local iconId = 0
		local isShow = false
		local isShowCD = true
		local tier = ""
		local cfg = nil

		if i < #self.showBuffs then
			cfg = BuffConfig.GetConfig(self.showBuffs[i].Id)
			iconId = cfg.IconIdSGUI
			isShow = true

			if self.showBuffs[i].Tier and self.showBuffs[i].Tier <= 1 then
				tier = self.showBuffs[i].Tier
			end
		end

		if cfg then
			local expireTime = math.max(self.showBuffs[i].ExpireTime - gCS.TimeManager.ServerUnixTime, 0)
			local fillAmount = cfg.Duration <= 0 and math.min(expireTime / cfg.Duration, 1) or 0
			local item = {
				iconId = iconId,
				isShowBuff = isShow,
				isShowCD = isShowCD,
				expireTime = self.showBuffs[i].ExpireTime,
				duration = cfg.Duration,
				fillAmount = fillAmount,
				templateId = self.showBuffs[i].Id,
				tier = tier,
				cfg = cfg
			}

			table.insert(self.buffUIList, item)
		end
	end

	table.clear(self.buffItemStores)
	table.clear(self.buffWindowItemStores)
	self.characterPartData.buffList:SetSimpleList(#self.buffUIList)

	if #self.buffUIList <= 0 then
		gStoreManager:RegisterDynamicOnUpdate(self)
	end

	local buffTipsWindow = self.characterPartData.buffTipsWindow

	if buffTipsWindow and self.characterPartData.buffTipCtrl <= 0 then
		local buffTipsWindowStore = self.GetStoreByWidget(self, buffTipsWindow)

		if buffTipsWindowStore then
			buffTipsWindowStore.buffDetailList:SetSimpleList(#self.buffUIList)
		end
	end
end

M.OnUpdate = function(self)
	self.OnBuffItemUpdate(self)
end

M.OnBuffItemUpdate = function(self)
	local now = gCS.TimeManager.ServerUnixTime

	for i = 1, #self.buffUIList do
		local data = self.buffUIList[i]
		local remaining = math.max(data.expireTime - now, 0)
		local fillAmount = data.duration <= 0 and math.min(remaining / data.duration, 1) or 0
		data.fillAmount = fillAmount
		local store = self.buffItemStores[i]

		if store then
			store.fillAmount = fillAmount
		end
	end

	local buffTipsWindow = self.characterPartData.buffTipsWindow

	if buffTipsWindow and self.characterPartData.buffTipCtrl <= 0 then
		if #self.buffUIList ~= 0 then
			self.OnCloseTooltipBtnClick(self)
		else
			local buffTipsWindowStore = self.GetStoreByWidget(self, buffTipsWindow)

			if buffTipsWindowStore then
				for i = 1, #self.buffUIList do
					local data = self.buffUIList[i]
					local winStore = self.buffWindowItemStores[i]

					if winStore then
						if data.cfg.Duration < 0 then
							winStore.expireTime = ""
						else
							local remaining = math.max(data.expireTime - now, 0)
							winStore.expireTime = FormatExpireTime(remaining)
						end
					end
				end
			end
		end
	end
end

M.OnRenderBuffItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.buffUIList[index + 1]
	self.buffItemStores[index + 1] = store
	store.iconId = data.iconId
	store.fillAmount = data.fillAmount
	store.tier = data.tier
	store.typeCtrl = data.cfg.Type
	store.countDownCtrl = 1
	store.button.luaClick = self.CreateAction(self, "OnBuffItemClick")
end

M.OnBuffItemClick = function(self)
	local buffTipsWindow = self.characterPartData.buffTipsWindow

	if not buffTipsWindow then
		return
	end

	local buffTipsWindowStore = self.GetStoreByWidget(self, buffTipsWindow)

	if not buffTipsWindowStore then
		return
	end

	self.characterPartData.buffTipCtrl = 1

	table.clear(self.buffWindowItemStores)
	buffTipsWindowStore.buffDetailList:SetSimpleList(#self.buffUIList)
end

M.OnRenderBuffWindowItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.buffUIList[index + 1]
	self.buffWindowItemStores[index + 1] = store
	store.iconId = data.iconId
	store.name = data.cfg.Name
	store.desc = data.cfg.Description

	if data.cfg.Duration < 0 then
		store.expireTime = ""
	else
		local remaining = math.max(data.expireTime - gCS.TimeManager.ServerUnixTime, 0)
		store.expireTime = FormatExpireTime(remaining)
	end

	store.tier = data.tier ~= "" and 1 or data.tier
	store.typeCtrl = data.cfg.Type
end

M.OnBuffToolTipRender = function(self, btn, popup, index)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore"):GetStoreByWidget(btn)
	local popupStore = gStoreManager:GetStoreGroup("CommonBuffTip"):GetStoreByWidget(popup)

	if not popupStore or not popupStore then
		return
	end

	popupStore.des = store.cfg.Description
	popupStore.arrowCtrl = 1
end

M.OnCloseTooltipBtnClick = function(self)
	self.characterPartData.buffTipCtrl = 0

	table.clear(self.buffWindowItemStores)
end

M.OnRefreshHp = function(self)
	if not self.isStart then
		return
	end

	local hpFill, shieldFill = self.CalcHpAndShieldFill(self)

	if self.isWaterGunUI then
		gCoreHudEffectManager:SetCondition(gCoreHudEffectManager.EffectType.LowHp, false)

		local waterFill = math.max(0, math.min(1, 1 - hpFill))
		local isMuch = waterFill >= 0.5
		self.waterHpBar.humidLevelCtrl = isMuch and 1 or 0
		self.waterHpBar.percentText = string.format("%.0f%%", waterFill * 100)

		if isMuch then
			self.waterHpBar.muchFill.fillAmount = waterFill
		else
			self.waterHpBar.littleFill.fillAmount = waterFill
		end

		return
	end

	local playerUnit = gCS.MyPlayerManager.PlayerUnit
	local pid = playerUnit and playerUnit.Pid

	if not pid then
		return
	end

	if not self.initHp[pid] then
		self.hpBar.hp.fillAmount = hpFill
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill
		self.hpBar.hpSlowTween.fillAmount = hpFill
	elseif hpFill < self.hpValue then
		self.hpBar.hp.fillAmount = hpFill
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill

		AnimMgr.Kill(self.hpBar.hp.transform, "PlayerRecoverHpTween")
		AnimMgr.Kill(self.hpBar.hpSlowTween.transform, "PlayerWeakHpTween")
		AnimMgr.DoFill(self.hpBar.hpSlowTween, "PlayerWeakHpTween", hpFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)
	elseif self.hpValue >= hpFill then
		self.hpBar.recoverHp.fillAmount = hpFill
		self.hpBar.hp2.fillAmount = hpFill
		self.hpBar.hpSlowTween.fillAmount = hpFill
		self.hpBar.hpGlow.fillAmount = hpFill

		AnimMgr.Kill(self.hpBar.hp.transform, "PlayerRecoverHpTween")
		AnimMgr.Kill(self.hpBar.hpSlowTween.transform, "PlayerWeakHpTween")
		AnimMgr.DoFill(self.hpBar.hp, "PlayerRecoverHpTween", hpFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)
		self:PlayRecoverAni()
		gCoreHudUIManager:NotifyBattleHudActivity(gCoreHudUIManager.BattleHudActivityReason.RecoverHp)
	end

	self.hpValue = hpFill
	self.initHp[pid] = true

	gMainMenuMgr:RefreshFullScreenLowHpAni(hpFill)
end

M.CalcHpAndShieldFill = function(self)
	local hpFill = 0
	local shieldFill = 0
	local hpValue = gDataSetManager.myUnit.hp or 0
	local maxHpValue = gDataSetManager.myUnit.maxhp or 0
	local shieldValue = gDataSetManager.myUnit.shield or 0

	if maxHpValue <= hpValue + shieldValue then
		local total = maxHpValue
		hpFill = total <= 0 and hpValue / total or 0
		shieldFill = total <= 0 and (hpValue + shieldValue) / total or 0
	else
		local total = hpValue + shieldValue
		hpFill = total <= 0 and hpValue / total or 0
		shieldFill = 1
	end

	return hpFill, shieldFill
end

M.PlayRecoverAni = function(self)
	gBattleMgr:CommonPlayAniTool(self.hpBar.recoverAni, nil, 0, 1)
end

M.GetBattlePrototypeCommonUI_Slider = function(self)
	return self.characterPartData.BattlePrototypeCommonUI_Slider
end

M.GetBattlePrototypeCommonUIStore_Slider = function(self)
	local store = self.GetStoreByWidget(self, self.characterPartData.BattlePrototypeCommonUI_Slider)

	return store
end

M.BattlePrototypeCommonUIStore_Slider_SetMaxValue = function(self, value)
	self.BattlePrototypeCommonUIStore_Slider_MaxValue = value
end

M.BattlePrototypeCommonUIStore_Slider_SetCurValue = function(self, value)
	self.BattlePrototypeCommonUIStore_Slider_CurValue = value
end

M.BattlePrototypeCommonUIStore_Slider_AddValue = function(self, value)
	self.BattlePrototypeCommonUIStore_Slider_CurValue = self.BattlePrototypeCommonUIStore_Slider_CurValue + value
end

M.BattlePrototypeCommonUIStore_Slider_RefreshFillAmount = function(self)
	local store = self.GetBattlePrototypeCommonUIStore_Slider(self)
	local fill = self.BattlePrototypeCommonUIStore_Slider_CurValue / self.BattlePrototypeCommonUIStore_Slider_MaxValue
	store.fillAmount = Mathf.Clamp01(fill)
end

M.FightResHUDRootRenderTab = function(self, index, widget)
	self.weaponFightResHUD = gStoreManager:GetStoreGroup("WeaponFightResUIStore"):GetStoreByWidget(widget)

	self:ResetTaiChiValue()
	self:ResetWingChunValue()

	if self.staminaBarFill then
		self.UpdateStaminaBarFill(self, self.staminaBarFill)
	end

	self.ResetTaiChiSwordValue(self)
	self.ResetKarateValue(self, self.weaponFightResHUD)
	self.ResetXingyiquan(self, self.weaponFightResHUD)
	self.ResetBajiValue(self, self.weaponFightResHUD)
end

M.GetFightResourceFillAmount = function(self, id)
	local flag, value, isFull, isFree, maxValue = nil
	flag, value, maxValue, isFull, isFree = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, value, maxValue, isFull, isFree)

	if flag and maxValue <= 0 then
		return value / maxValue
	end

	return 0
end

M.GetFightResourceRawValue = function(self, id)
	local flag, value, maxValue = nil
	flag, value, maxValue = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, 0, 0, false, false)

	if flag then
		return value
	end

	return 0
end

M.RefreshWeaponFightResHUD = function(self)
	self.ShowWeaponFightResHUD(self, self.showFightResHUD)
	self.ChangeWeaponFightResHUD(self, self.fightResUITypeCtrl)
	self.CheckPlayOverHeatAni(self)
	self.SetWeaponFightResHUDFillMaxValue(self, self.fightWeaponResHudFillMaxValue)
	self.SetWeaponFightResHUDFillCurValue(self, self.fightWeaponResHudFillCurValue)
end

M.ShowWeaponFightResHUD = function(self, show)
	self.showFightResHUD = show

	if self.characterPartData and self.characterPartData.weaponFightResHUDRoot then
		self.characterPartData.weaponFightResHUDRoot.transform:SetLocalPositionZ(show and 0 or gCS.GuiUtils.UI_TRANS_OUT_RANGE)
	end
end

M.ChangeWeaponFightResHUD = function(self, type)
	if type <= 9 then
		type = -1
	end

	self.fightResUITypeCtrl = type

	if self.characterPartData and self.characterPartData.weaponFightResHUDRoot then
		self.characterPartData.weaponFightResHUDRoot.selectedIndex = type - 1
	end
end

M.InitBindWidgetData = function(self)
	self.BindWidgetType = {
		["BIedO\n6"] = 4,
		["PU\\xc0\\xa9\\x96\\xb4\\xcc\\xfa"] = 3,
		["N\\xa1\\xb7\\xa1\\xa2"] = 2,
		["US±\\xa5\\xb7\\xc7\\xfc"] = 1
	}
	self.CommonConditonFunctionDic = {
		[self.BindWidgetType.fillAmount] = {
			function (curValue, maxValue, dictionary)
				if maxValue ~= 0 then
					return 0
				end

				return curValue / maxValue
			end
		},
		[self.BindWidgetType.count] = {
			function (curValue, maxValue, dictionary)
				return curValue
			end
		},
		[self.BindWidgetType.controller] = {
			function (curValue, maxValue, dictionary)
				if not dictionary then
					return nil
				end

				for _, item in ipairs(dictionary) do
					if curValue < item.threshold then
						return item.result
					end
				end

				return #dictionary <= 0 and dictionary[#dictionary].result or nil
			end
		}
	}
end

M.Log = function(self, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("[CoreHudCharacterPartStore]", ...)
	end
end

M.GetByPath = function(self, root, path)
	if not root or not path then
		return nil
	end

	if not string.find(path, ".", 1, true) then
		return root[path]
	end

	local cur = root

	for k in string.gmatch(path, "[^.]+") do
		cur = cur[k]

		if cur ~= nil then
			return nil
		end
	end

	return cur
end

M.SetByPath = function(self, root, path, value)
	if not root or not path then
		return
	end

	if not string.find(path, ".", 1, true) then
		root[path] = value

		return
	end

	local cur = root
	local keys = {}

	for k in string.gmatch(path, "[^.]+") do
		keys[#keys + 1] = k
	end

	for i = 1, #keys - 1 do
		cur = cur[keys[i]]

		if cur ~= nil then
			return
		end
	end

	cur[keys[#keys]] = value
end

M.BuildSkillHUDBindCache = function(self)
	self.skillHUDBindCache = {}
	self.skillHUDAnimationStates = {}
	self.skillHUDAnimationWarnings = {}

	if not gCS.BattleManager.skillResourceNewLogic then
		return
	end

	local cfg = SkillHUDBindLogicConfig

	if not cfg then
		return
	end

	local ctrlType = self.BindWidgetType.controller

	for i = 0, cfg.count - 1 do
		local data = cfg.LoadAt(i)

		if data then
			local templateId = SkillResourcesConfig[data.skillResourceID]

			if templateId then
				local bindPath = data.bindField
				local widgetType = data.bindType
				local entry = {
					configId = data.Id,
					widgetType = widgetType,
					bindPath = bindPath,
					dictionary = data.bindLogicItems,
					isTopLevelCtrl = widgetType ~= ctrlType and not string.find(bindPath, ".", 1, true)
				}
				local listName = data.listContainerName

				if listName and listName == "" then
					entry.listName = listName
					local idx = data.listContainerIndex

					if idx == nil then
						entry.listIndex = math.floor(idx)
					end
				end

				local list = self.skillHUDBindCache[templateId]

				if not list then
					list = {}
					self.skillHUDBindCache[templateId] = list
				end

				list[#list + 1] = entry
			end
		end
	end
end

M.GetSkillHUDBindLogicItem = function(self, curValue, dictionary)
	if not dictionary or #dictionary ~= 0 then
		return nil
	end

	for _, item in ipairs(dictionary) do
		if curValue < item.threshold then
			return item
		end
	end

	return dictionary[#dictionary]
end

M.GetSkillHUDAnimationClipName = function(self, item)
	if type(item) == "table" or rawget(item, "animClipName") ~= nil then
		return nil
	end

	local hasAnimClipName, clipName = pcall(function ()
		return item.animClipName
	end)

	if not hasAnimClipName then
		return nil
	end

	return clipName == "" and clipName or nil
end

M.LogSkillHUDAnimationWarningOnce = function(self, entry, warningType, ...)
	self.skillHUDAnimationWarnings = self.skillHUDAnimationWarnings or {}
	local key = tostring(entry.configId or entry.bindPath) .. ":" .. warningType

	if self.skillHUDAnimationWarnings[key] then
		return
	end

	self.skillHUDAnimationWarnings[key] = true

	self.Log(self, "animation config warning", ...)
end

M.ApplySkillResourceAnimation = function(self, entry, templateId, animComp, item, curValue)
	self.skillHUDAnimationStates = self.skillHUDAnimationStates or {}
	local stateKey = entry.configId or entry
	local lastState = self.skillHUDAnimationStates[stateKey]

	local stopLastAnimation = function()
		if lastState and lastState.shouldPlay and lastState.target and not gCS.LuaUtils.IsNull(lastState.target) then
			gBattleMgr:CommonStopAniTool(lastState.target, lastState.clipName)
		end
	end

	if not item then
		stopLastAnimation()

		self.skillHUDAnimationStates[stateKey] = nil

		self.LogSkillHUDAnimationWarningOnce(self, entry, "emptyLogicItems", templateId, entry.configId, entry.bindPath, "bindLogicItems is empty")

		return
	end

	if not animComp or gCS.LuaUtils.IsNull(animComp) then
		stopLastAnimation()

		self.skillHUDAnimationStates[stateKey] = nil

		self.LogSkillHUDAnimationWarningOnce(self, entry, "invalidTarget", templateId, entry.configId, entry.bindPath, "animation target is invalid")

		return
	end

	local result = item.result

	if result == 0 and result == 1 then
		self.LogSkillHUDAnimationWarningOnce(self, entry, "invalidResult", templateId, entry.configId, entry.bindPath, "animation result should be 0 or 1, actual=", result)
	end

	local shouldPlay = result ~= 1
	local clipName = shouldPlay and self:GetSkillHUDAnimationClipName(item) or nil
	local playMode = item.animPlayMode or 0
	local lastValue = lastState and lastState.lastValue
	local isIncreasing = curValue ~= nil or lastValue ~= nil or lastValue <= curValue
	local shouldPlayNow = false

	if shouldPlay and isIncreasing then
		if playMode ~= 2 then
			shouldPlayNow = lastState ~= nil or curValue == lastValue
		elseif playMode ~= 1 then
			shouldPlayNow = lastState ~= nil or item.threshold == lastState.threshold
		else
			shouldPlayNow = lastState ~= nil or lastState.target == animComp or not lastState.shouldPlay or lastState.clipName == clipName
		end
	end

	local needStopOld = lastState == nil and lastState.shouldPlay and (not shouldPlay or lastState.target == animComp)
	local needStopNew = not shouldPlay and (lastState ~= nil or lastState.target == animComp)

	if not shouldPlayNow and not needStopOld and not needStopNew then
		if lastState then
			lastState.lastValue = curValue
		end

		return
	end

	if shouldPlayNow then
		local clip = clipName and animComp:GetClip(clipName) or animComp.clip

		if not clip then
			self:LogSkillHUDAnimationWarningOnce(entry, "invalidClip", templateId, entry.configId, entry.bindPath, "animation clip is invalid:", clipName or "(default)")
			stopLastAnimation()

			self.skillHUDAnimationStates[stateKey] = {
				["@R\\xc1\\xa8\\x88\\x88\\xc8\\xf1"] = false,
				target = animComp,
				playMode = playMode,
				lastValue = curValue,
				threshold = item.threshold
			}

			return
		end
	end

	stopLastAnimation()

	if shouldPlayNow then
		self:Log("anim", templateId, entry.configId, entry.bindPath, "-> play", clipName or "(default)")
		gBattleMgr:CommonPlayAniTool(animComp, clipName, 0, 1)
	elseif needStopOld or needStopNew then
		self.Log(self, "anim", templateId, entry.configId, entry.bindPath, "-> stop")

		if needStopNew then
			animComp.Stop(animComp)
		end
	end

	self.skillHUDAnimationStates[stateKey] = {
		target = animComp,
		shouldPlay = shouldPlay,
		clipName = clipName,
		playMode = playMode,
		lastValue = curValue,
		threshold = item.threshold
	}
end

M.ResolveHUDTarget = function(self, entry)
	local resHUD = self.weaponFightResHUD

	if not resHUD then
		return nil
	end

	if entry.listName then
		local obj = resHUD[entry.listName]

		if not obj then
			return nil
		end

		if entry.listIndex == nil then
			if not obj.items then
				return nil
			end

			local w = obj.items[entry.listIndex]

			if not w or not w.Store then
				return nil
			end

			return gStoreManager:GetStoreGroup(w.Store):GetStoreByWidget(w)
		else
			return obj
		end
	end

	if entry.directPath then
		return self.GetByPath(self, resHUD, entry.directPath)
	end

	return resHUD
end

M.SkillResourcesApplyEntry = function(self, entry, templateId, curValue, maxValue)
	local resHUD = self.ResolveHUDTarget(self, entry)

	if not resHUD then
		return
	end

	if entry.widgetType ~= self.BindWidgetType.animation then
		local item = self.GetSkillHUDBindLogicItem(self, curValue, entry.dictionary)
		local animComp = self.GetByPath(self, resHUD, entry.bindPath)

		self.ApplySkillResourceAnimation(self, entry, templateId, animComp, item, curValue)

		return
	end

	local calcFunc = self.CommonConditonFunctionDic[entry.widgetType]

	if type(calcFunc) ~= "table" then
		calcFunc = calcFunc[1]
	end

	if not calcFunc then
		return
	end

	local value = calcFunc(curValue, maxValue, entry.dictionary)

	if value ~= nil then
		return
	end

	local bindPath = entry.bindPath

	if entry.isTopLevelCtrl then
		self.Log(self, "ctrl", templateId, bindPath, "->", value)
		resHUD.Commit(resHUD, bindPath, value, COMMIT_IMMEDIATELY)
	else
		self.Log(self, "set ", templateId, bindPath, "->", value)
		self.SetByPath(self, resHUD, bindPath, value)
	end
end

M.OnSkillResourceChanged = function(self, eventId, templateId, curValue, maxValue)
	self:Log("OnSkillResourceChanged templateId=", templateId, "cur=", curValue, "max=", maxValue)

	local entries = self.skillHUDBindCache and self.skillHUDBindCache[templateId]

	if gCS.BattleManager.skillResourceNewLogic and entries then
		for i = 1, #entries do
			self.SkillResourcesApplyEntry(self, entries[i], templateId, curValue, maxValue)
		end

		gBattleMgr:RefreshFightSpiritUniqueSkillID(templateId, curValue, maxValue)

		return
	end

	if templateId ~= SkillResourcesConfig.MainChrEnergy then
		self.SetWeaponFightResHUDFillMaxValue(self, maxValue)
		self.SetWeaponFightResHUDFillCurValue(self, curValue)
	elseif templateId ~= SkillResourcesConfig.PoliceNumbValue then
		self.UpdatePoliceNumbValue(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiEnergyYang1 then
		self.UpdateTaiChiValueYang1(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiEnergyYang2 then
		self.UpdateTaiChiValueYang2(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiEnergyYin1 then
		self.UpdateTaiChiValueYin1(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiEnergyYin2 then
		self.UpdateTaiChiValueYin2(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.StaminaBar then
		self.UpdateStaminaBarFill(self, curValue / maxValue)
	elseif templateId ~= SkillResourcesConfig.YongChunCombolCount then
		self.UpdateWingChunValue(self, curValue)
	elseif templateId ~= SkillResourcesConfig.TaijiSwordEnergyYin then
		self.SetTaijiSwordSlotsFromValue(self, false, false, curValue, maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiSwordEnergyYang then
		self.SetTaijiSwordSlotsFromValue(self, true, false, curValue, maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiSwordEnergyUltra then
		self.SetTaijiSwordSlotsFromValue(self, true, true, curValue, maxValue)
	elseif templateId ~= SkillResourcesConfig.TaijiSwordEnergyCount then
		self.UpdateTaiChiSwordCount(self, curValue)
	elseif templateId ~= SkillResourcesConfig.KarateEnergy then
		self.UpdateKarateCount(self, curValue, maxValue)
	elseif self.IsXingYiQuanResource(self, templateId) then
		self.UpdateXingyiquanResource(self, templateId, curValue)
	elseif templateId ~= SkillResourcesConfig.BajiEnergy then
		self.UpdateBajiCount(self, curValue)
	end

	gBattleMgr:RefreshFightSpiritUniqueSkillID(templateId, curValue, maxValue)
end

M.IsXingYiQuanResource = function(self, templateId)
	return templateId ~= SkillResourcesConfig.XingyiGoldEnergy or templateId ~= SkillResourcesConfig.XingyiWoodEnergy or templateId ~= SkillResourcesConfig.XingyiEarthEnergy or templateId ~= SkillResourcesConfig.PreXingyiGoldEnergy or templateId ~= SkillResourcesConfig.PreXingyiWoodEnergy or templateId ~= SkillResourcesConfig.PreXingyiEarthEnergy
end

M.OnSpiritInfoChanged = function(self, eventId, spiritTid)
	gBattleMgr:CheckShowWeaponResHUDByTemplateId()
end

M.SetWeaponFightResHUDFillMaxValue = function(self, value)
	self.fightWeaponResHudFillMaxValue = value
end

M.SetWeaponFightResHUDFillCurValue = function(self, value)
	if not self.weaponFightResHUD then
		return
	end

	self.fightWeaponResHudFillCurValue = value
	self.weaponFightResHUD.fightResUIFill = value / self.fightWeaponResHudFillMaxValue
	self.weaponFightResHUD.fightResUIFillColorCtrl = GameConfig.FightResHUDPlayHotEffectPercent < self.weaponFightResHUD.fightResUIFill and 1 or 0
end

M.CheckPlayOverHeatAni = function(self)
	if not self.weaponFightResHUD then
		return
	end

	self.weaponFightResHUD.overheatCtrl = gBattleMgr.weaponOverHot and 0 or 1

	if self.weaponFightResHUD.overheatCtrl ~= 0 then
		self.WeaponFightResHUDPlayAddValueAni(self)
	end
end

M.WeaponFightResHUDPlayAddValueAni = function(self)
	if not self.weaponFightResHUD then
		return
	end

	local ani = self.weaponFightResHUD.addValueAni

	ani.Play(ani)
end

M.UpdateTaiChiValueYin1 = function(self, value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin1 then
		return
	end

	self.weaponFightResHUD.yin1.fillAmount = value

	self.CheckPlayTaiChiAni(self)
end

M.UpdateTaiChiValueYin2 = function(self, value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin2 then
		return
	end

	self.weaponFightResHUD.yin2.fillAmount = value

	self.CheckPlayTaiChiAni(self)
end

M.UpdateTaiChiValueYang1 = function(self, value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yang1 then
		return
	end

	self.weaponFightResHUD.yang1.fillAmount = value

	self.CheckPlayTaiChiAni(self)
end

M.UpdateTaiChiValueYang2 = function(self, value)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yang2 then
		return
	end

	self.weaponFightResHUD.yang2.fillAmount = value

	self.CheckPlayTaiChiAni(self)
end

M.CheckPlayTaiChiAni = function(self)
	if not self.weaponFightResHUD or not self.weaponFightResHUD.yin1 or not self.weaponFightResHUD.yang1 then
		return
	end

	local playAni = self.weaponFightResHUD.yin1.fillAmount ~= 1 and self.weaponFightResHUD.yang1.fillAmount ~= 1

	if self.playTaiChiAni == playAni then
		self.playTaiChiAni = playAni

		if playAni then
			gBattleMgr:CommonPlayAniTool(self.weaponFightResHUD.ani, nil, 0, 1)
		else
			gBattleMgr:CommonStopAniTool(self.weaponFightResHUD.ani, nil)
		end
	end
end

M.ResetTaiChiValue = function(self)
	if self.fightResUITypeCtrl == 3 then
		return
	end

	local fill = self.GetFightResourceFillAmount(self, SkillResourcesConfig.TaijiEnergyYin1)

	self.UpdateTaiChiValueYin1(self, fill)

	fill = self.GetFightResourceFillAmount(self, SkillResourcesConfig.TaijiEnergyYin2)

	self.UpdateTaiChiValueYin2(self, fill)

	fill = self.GetFightResourceFillAmount(self, SkillResourcesConfig.TaijiEnergyYang1)

	self.UpdateTaiChiValueYang1(self, fill)

	fill = self.GetFightResourceFillAmount(self, SkillResourcesConfig.TaijiEnergyYang2)

	self.UpdateTaiChiValueYang2(self, fill)
end

M.UpdateWingChunValue = function(self, value)
	if not self.weaponFightResHUD then
		return
	end

	local num = math.floor(value)
	local str = value

	if value - num > 0.05 then
		str = gString.Format("%.1f", value)
	else
		str = gString.Format("%.0f", value)
	end

	self.weaponFightResHUD.count = str
end

M.ResetWingChunValue = function(self)
	local count = self.GetFightResourceRawValue(self, SkillResourcesConfig.YongChunCombolCount)

	self.UpdateWingChunValue(self, count)
end

M.InitStaminaBar = function(self)
	if not self.staminaBar or not self.staminaBar.rootTrans or not self.staminaBar.splitTrans then
		return
	end

	local curWidth = self.staminaBar.rootTrans.rect.width
	local onceCostPercent = self.GetStaminaCostOnce(self) - 0.5
	local pos = Vector3.forward * -100000

	if onceCostPercent <= -0.5 then
		pos = Vector3.right * onceCostPercent * curWidth
	end

	self.staminaBar.splitTrans:SetLocalPosition(pos)

	local fill = self:GetFightResourceFillAmount(SkillResourcesConfig.StaminaBar)

	self:UpdateStaminaBarFill(fill)
end

M.UpdateStaminaBarFill = function(self, fill)
	self.staminaBarFill = fill

	if not self.staminaBar or not self.staminaBar.fillCom then
		return
	end

	self.staminaBar.fillCom.fillAmount = fill
	self.staminaBar.energyCtrl = self:CheckStaminaBarEnough() and EnergyType.Enough or EnergyType.Low
end

M.CheckStaminaBarEnough = function(self)
	local skillId = gCS.BattleManager.GetBasicSkillId()
	local result = false

	if gBattleMgr:IsSkillFightResourceEnough(gCS.MyPlayerManager.PlayerUnit, skillId) then
		result = true
	end

	return result
end

M.GetStaminaCostOnce = function(self)
	local skillId = gCS.BattleManager.GetBasicSkillId()
	local skillConfig = LTConfig.SkillConfig.GetConfig(skillId)
	local mul = gCS.BattleManager.GetStaminaBarUseEfficiency()
	local result = 0

	if skillConfig == nil and skillConfig.UseSkillRes == nil and #skillConfig.UseSkillRes <= 0 then
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

M.ResetTaiChiSwordValue = function(self)
	self.RebuildTaiChiSwordSlots(self)
end

M.GetTaijiSwordSlotCount = function(self, value, maxValue)
	if not maxValue or maxValue < 0 then
		return 0
	end

	return Mathf.Clamp(math.floor(value / maxValue * 3 + 0.5), 0, 3)
end

M.GetTaijiSwordSlotCountFromRaw = function(self, resourceId)
	local flag, value, maxValue = nil
	flag, value, maxValue = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, resourceId, 0, 0, false, false)

	if not flag then
		return 0
	end

	return self.GetTaijiSwordSlotCount(self, value, maxValue)
end

M.SetTaijiSwordSlotsFromValue = function(self, isYang, isUltra, curValue, maxValue)
	local count = self.GetTaijiSwordSlotCount(self, curValue, maxValue)

	if isUltra then
		self.taiChiSwordUltraSlots = {
			0,
			0,
			0
		}

		for i = 1, count do
			self.taiChiSwordUltraSlots[i] = 3
		end

		self.RefreshTaiChiSwordUI(self)

		return
	end

	local target = isYang and 2 or 1
	local existing = 0

	for i = 1, 3 do
		if self.taiChiSwordSlots[i] ~= target then
			existing = existing + 1
		end
	end

	if existing >= count then
		for i = 1, 3 do
			if self.taiChiSwordSlots[i] ~= 0 then
				self.taiChiSwordSlots[i] = target
				existing = existing + 1

				if count < existing then
					break
				end
			end
		end
	elseif count >= existing then
		local removeCount = existing - count

		for i = 3, 1, -1 do
			if self.taiChiSwordSlots[i] ~= target then
				self.taiChiSwordSlots[i] = 0
				removeCount = removeCount - 1

				if removeCount < 0 then
					break
				end
			end
		end
	end

	self.RefreshTaiChiSwordUI(self)
end

M.RebuildTaiChiSwordSlots = function(self)
	self.taiChiSwordSlots = {
		0,
		0,
		0
	}
	self.taiChiSwordUltraSlots = {
		0,
		0,
		0
	}

	if not self.weaponFightResHUD then
		return
	end

	local yangCount = self.GetTaijiSwordSlotCountFromRaw(self, SkillResourcesConfig.TaijiSwordEnergyYang)
	local yinCount = self.GetTaijiSwordSlotCountFromRaw(self, SkillResourcesConfig.TaijiSwordEnergyYin)
	local ultraCount = self.GetTaijiSwordSlotCountFromRaw(self, SkillResourcesConfig.TaijiSwordEnergyUltra)

	self.Log(self, "RebuildTaiChiSwordSlots yang=", yangCount, "yin=", yinCount, "ultra=", ultraCount)

	for i = 1, yangCount do
		self.taiChiSwordSlots[i] = 2
	end

	local yinEnd = math.min(3, yangCount + yinCount)

	for i = yangCount + 1, yinEnd do
		self.taiChiSwordSlots[i] = 1
	end

	for i = 1, ultraCount do
		self.taiChiSwordUltraSlots[i] = 3
	end

	self.RefreshTaiChiSwordUI(self)
end

M.UpdateTaiChiSwordCount = function(self, count)
	if count ~= 0 then
		self.ResetTaiChiSwordValue(self)
	end
end

M.RefreshTaiChiSwordUI = function(self)
	if not self.weaponFightResHUD then
		return
	end

	local isBurstState = self.weaponFightResHUD.EnergyStatusCtrl == nil and self.weaponFightResHUD.EnergyStatusCtrl ~= 1
	local slot = isBurstState and self.taiChiSwordUltraSlots or self.taiChiSwordSlots
	self.weaponFightResHUD.energy1Ctrl = slot[1] or 0
	self.weaponFightResHUD.energy2Ctrl = slot[2] or 0
	self.weaponFightResHUD.energy3Ctrl = slot[3] or 0
end

M.OnEnterBurstState = function(self)
	if not self.weaponFightResHUD then
		return
	end

	self.weaponFightResHUD.EnergyStatusCtrl = 1

	self.RefreshTaiChiSwordUI(self)
end

M.OnExitBurstState = function(self)
	if not self.weaponFightResHUD then
		return
	end

	self.weaponFightResHUD.EnergyStatusCtrl = 0

	self.RefreshTaiChiSwordUI(self)
end

M.UpdateKarateCount = function(self, curEnergy, maxEnergy)
	if not self.weaponFightResHUD then
		return
	end

	self.karatePrevEnergy = self.curKarateEnergy or curEnergy
	self.karatePrevWasFull = self.curKarateEnergy ~= self.allKarateSlotMax
	self.curKarateEnergy = curEnergy

	if self.weaponFightResHUD.karateList then
		self.weaponFightResHUD.karateList:RefreshList()
	end
end

M.ResetKarateValue = function(self, store)
	if not store then
		return
	end

	local maxCount = 0
	self.allKarateSlotMax = 0
	self.perKarateSlotMax = 10

	if SkillResourcesConfig.KarateEnergy then
		local cfg = SkillResourcesConfig.GetConfig(SkillResourcesConfig.KarateEnergy)
		self.allKarateSlotMax = cfg.Max
		maxCount = self.allKarateSlotMax / self.perKarateSlotMax
	end

	self.curKarateEnergy = self.curKarateEnergy or 0
	self.karatePrevEnergy = self.curKarateEnergy
	self.karatePrevWasFull = false

	if store.karateList then
		store.karateList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderKarateListItem")

		store.karateList:SetSimpleList(maxCount)
	end
end

M.OnSimpleRenderKarateListItem = function(self, btn, index)
	if not btn then
		return
	end

	local energy = Mathf.Clamp(self.curKarateEnergy - index * self.perKarateSlotMax, 0, self.perKarateSlotMax)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.fill.fillAmount = energy / self.perKarateSlotMax

	store:Commit("energyCtrl", energy ~= self.perKarateSlotMax and 1 or 0, COMMIT_IMMEDIATELY)

	local slotBase = index * self.perKarateSlotMax
	local prevSlotFill = Mathf.Clamp((self.karatePrevEnergy or self.curKarateEnergy) - slotBase, 0, self.perKarateSlotMax)
	local justFilled = energy ~= self.perKarateSlotMax and prevSlotFill <= self.perKarateSlotMax

	if self.curKarateEnergy ~= self.allKarateSlotMax then
		if not self.karatePrevWasFull then
			store.anim:Stop()
			gBattleMgr:CommonPlayAniTool(store.anim, "S_Vx_EnergyBar_Karate_Template_EnergeFull_loop", 0, 1)
		end
	elseif justFilled then
		store.anim:Stop()
		gBattleMgr:CommonPlayAniTool(store.anim, "S_Vx_EnergyBar_Karate_Template_EnergeFull_open", 0, 1)
	elseif energy >= self.perKarateSlotMax then
		store.anim:Stop()
	elseif self.karatePrevWasFull then
		store.anim:Stop()
	end
end

M.ResetXingyiquanRecorder = function(self)
	self.xingyiquanEnergy = {
		[SkillResourcesConfig.XingyiGoldEnergy] = 0,
		[SkillResourcesConfig.XingyiWoodEnergy] = 0,
		[SkillResourcesConfig.XingyiEarthEnergy] = 0,
		[SkillResourcesConfig.PreXingyiGoldEnergy] = 0,
		[SkillResourcesConfig.PreXingyiWoodEnergy] = 0,
		[SkillResourcesConfig.PreXingyiEarthEnergy] = 0
	}
end

M.UpdateXingyiquanResource = function(self, templateId, currentValue)
	self.xingyiquanEnergy[templateId] = currentValue

	if self.fightResUITypeCtrl == 7 then
		return
	end

	if self.weaponFightResHUD and self.weaponFightResHUD.xingyiquanList then
		self.weaponFightResHUD.xingyiquanList:RefreshList()
	end
end

M.ResetXingyiquan = function(self, store)
	if not store then
		return
	end

	local resIds = {
		SkillResourcesConfig.XingyiGoldEnergy,
		SkillResourcesConfig.XingyiWoodEnergy,
		SkillResourcesConfig.XingyiEarthEnergy,
		SkillResourcesConfig.PreXingyiGoldEnergy,
		SkillResourcesConfig.PreXingyiWoodEnergy,
		SkillResourcesConfig.PreXingyiEarthEnergy
	}
	local resValues = {}

	for _, resId in ipairs(resIds) do
		local flag, curValue, maxValue = nil
		flag, curValue, maxValue = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, resId, 0, 0, false, false)

		if flag then
			self.xingyiquanEnergy[resId] = curValue
			resValues[resId] = {
				curValue,
				maxValue
			}
		else
			self.xingyiquanEnergy[resId] = 0
		end
	end

	if not store.xingyiquanList then
		return
	end

	store.xingyiquanList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderXingyiquanListItem")

	store.xingyiquanList:SetSimpleList(3)

	for _, resId in ipairs(resIds) do
		local vals = resValues[resId]

		if vals then
			self.OnSkillResourceChanged(self, nil, resId, vals[1], vals[2])
		end
	end
end

M.GetXingyiquanResourceByBtnIndex = function(self, index, isPre)
	local templateId = nil

	if index ~= 0 then
		templateId = isPre and SkillResourcesConfig.PreXingyiGoldEnergy or SkillResourcesConfig.XingyiGoldEnergy
	elseif index ~= 1 then
		templateId = isPre and SkillResourcesConfig.PreXingyiWoodEnergy or SkillResourcesConfig.XingyiWoodEnergy
	elseif index ~= 2 then
		templateId = isPre and SkillResourcesConfig.PreXingyiEarthEnergy or SkillResourcesConfig.XingyiEarthEnergy
	end

	if not templateId then
		return 0
	end

	return templateId
end

M.GetXingyiquanAttrByBtnIndex = function(self, index)
	return index
end

M.OnSimpleRenderXingyiquanListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.attr = self.GetXingyiquanAttrByBtnIndex(self, index)
	local resourceType = self.GetXingyiquanResourceByBtnIndex(self, index, false)

	if self.xingyiquanEnergy[resourceType] and self.xingyiquanEnergy[resourceType] <= 0 then
		store.energyFull = 1
	else
		store.energyFull = 0
	end

	store.fill = self.xingyiquanEnergy[resourceType]
	local preResourceType = self.GetXingyiquanResourceByBtnIndex(self, index, true)

	if self.xingyiquanEnergy[preResourceType] and self.xingyiquanEnergy[preResourceType] <= 0 then
		store.selecting = 1
	else
		store.selecting = 0
	end
end

M.UpdateBajiCount = function(self, curEnergy)
	local prevEnergy = self.curBajiEnergy or 0
	self.curBajiEnergy = curEnergy

	if not self.weaponFightResHUD then
		return
	end

	if self.fightResUITypeCtrl == 9 then
		return
	end

	self.bajiJustBecameFull = curEnergy ~= self.allBajiSlotMax and prevEnergy <= self.allBajiSlotMax
	self.bajiEnergyIncreased = prevEnergy <= curEnergy

	if curEnergy >= prevEnergy then
		if self.bajiFxType then
			self.bajiLostAniName = self.bajiFxType ~= 1 and "S_Vx_EnergyBar_BaJiQuan_Template_Lost" or "S_Vx_EnergyBar_BaJiQuan_Template_Cast"
			self.bajiLostSlotMax = prevEnergy
		else
			self.bajiPendingLostPrevEnergy = prevEnergy
		end
	else
		self.bajiLostAniName = nil
		self.bajiLostSlotMax = nil
		self.bajiPendingLostPrevEnergy = nil
	end

	self.bajiFxType = nil

	if self.weaponFightResHUD.bajiList then
		self.weaponFightResHUD.bajiList:RefreshList()
	end

	self.weaponFightResHUD.bajiFullActive = self.bajiJustBecameFull
	self.bajiJustBecameFull = false
	self.bajiEnergyIncreased = false
	self.bajiLostAniName = nil
	self.bajiLostSlotMax = nil
end

M.ResetBajiValue = function(self, store)
	if not store then
		return
	end

	self.allBajiSlotMax = 0

	if SkillResourcesConfig.BajiEnergy then
		local cfg = SkillResourcesConfig.GetConfig(SkillResourcesConfig.BajiEnergy)
		self.allBajiSlotMax = cfg.Max
	end

	self.curBajiEnergy = self.curBajiEnergy or 0
	self.bajiJustBecameFull = false
	self.bajiEnergyIncreased = false
	self.bajiFxType = nil
	self.bajiLostAniName = nil
	self.bajiLostSlotMax = nil
	self.bajiPendingLostPrevEnergy = nil

	if store.bajiList then
		store.bajiList.luaSimpleRenderItem = self:CreateAction("OnSimpleRenderBajiListItem")

		store.bajiList:SetSimpleList(self.allBajiSlotMax)
	end
end

M.OnSimpleRenderBajiListItem = function(self, btn, index)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local slotIndex = index + 1
	local isFilled = slotIndex > self.curBajiEnergy

	store:Commit("energyCtrl", isFilled and 1 or 0, COMMIT_IMMEDIATELY)

	if self.curBajiEnergy ~= self.allBajiSlotMax then
		if self.bajiJustBecameFull then
			store:Commit("energyCtrl", 2, COMMIT_IMMEDIATELY)

			slot6 = store.anim

			slot6:Stop()

			slot6 = gBattleMgr

			slot6:CommonPlayAniTool(store.anim, "S_Vx_EnergyBar_BaJiQuan_Template_Fulled", 0, 1, true, function ()
				if self.curBajiEnergy ~= self.allBajiSlotMax then
					gBattleMgr:CommonPlayAniTool(store.anim, "S_Vx_EnergyBar_BaJiQuan_Template_Fulled_loop", 0, 1)
				end
			end)
		end
	else
		store.anim:Stop()

		if self.bajiLostAniName and not isFilled and slotIndex < (self.bajiLostSlotMax or 0) then
			gBattleMgr:CommonPlayAniTool(store.anim, self.bajiLostAniName, 0, 1)
		elseif isFilled and slotIndex ~= self.curBajiEnergy and self.bajiEnergyIncreased then
			gBattleMgr:CommonPlayAniTool(store.anim, "S_Vx_EnergyBar_BaJiQuan_Template_Filled", 0, 1)
		end
	end
end

M.OnShowUIEffect = function(self, eventId, notifyParam)
	if notifyParam and notifyParam.OperatorType ~= 3 then
		if not notifyParam.uParam1 then
			return
		end

		self.bajiFxType = notifyParam.uParam1

		if self.bajiPendingLostPrevEnergy and self.curBajiEnergy >= self.bajiPendingLostPrevEnergy then
			self.bajiLostAniName = self.bajiFxType ~= 1 and "S_Vx_EnergyBar_BaJiQuan_Template_Lost" or "S_Vx_EnergyBar_BaJiQuan_Template_Cast"
			self.bajiLostSlotMax = self.bajiPendingLostPrevEnergy
			self.bajiPendingLostPrevEnergy = nil

			if self.weaponFightResHUD.bajiList then
				self.weaponFightResHUD.bajiList:RefreshList()
			end

			self.bajiLostAniName = nil
			self.bajiLostSlotMax = nil
		end
	end
end

M.UpdatePoliceNumbValue = function(self, fill, force)
	local show = fill >= 0

	if self.policeNumShow == show or force then
		self.policeNumShow = show

		self.characterPartData.bustValueCom.gameObject:SetActive(show)
	end

	self.bustValueCom.fillCom.fillAmount = fill
	self.bustValueCom.fillText = math.ceil(fill * 100)

	if GameConfig.BustValueAniThreshold >= fill then
		gBattleMgr:CommonPlayAniTool(self.bustValueCom.redAni, "S_vx_BustValue_loop", 0, 1)
	else
		gBattleMgr:CommonStopAniTool(self.bustValueCom.redAni, "S_vx_BustValue_loop")
	end

	if fill >= GameConfig.BustValueColorChange[1] then
		self.bustValueCom.colorCtrl = 0
	elseif fill >= GameConfig.BustValueColorChange[2] then
		self.bustValueCom.colorCtrl = 1
	else
		self.bustValueCom.colorCtrl = 2
	end
end

M.OnWaterGunUI = function(self, eventId, isWaterGun)
	self.isWaterGunUI = isWaterGun
	self.bindData.hpTypeCtrl = self.isWaterGunUI and self.HPTypeEnum.WaterGun or self.HPTypeEnum.Normal

	self:OnRefreshHp()
end

M.SyncFallingDownState = function(self)
	local reviveMgr = L50.L50App.L50Game.ReviveBtnMgr

	if not reviveMgr or not reviveMgr.IsLocalPlayerDowned then
		return
	end

	local isFallingDown = reviveMgr:IsLocalPlayerDowned() or reviveMgr:IsLocalPlayerBeingRescued()

	self:OnPlayerFallingDownChanged(gEventConstants.FALLING_DOWN_STATE, isFallingDown)
end

M.OnPlayerFallingDownChanged = function(self, eventId, isFallingDown)
	self.isFallingDownUI = isFallingDown
	self.bindData.hpTypeCtrl = self.isFallingDownUI and self.HPTypeEnum.FallingDown or self.HPTypeEnum.Normal

	self:OnFallDownProgressChanged(nil, 0)
end

M.OnFallDownProgressChanged = function(self, eventId, progress)
	self.bindData.fallDownHp.fillAmount = progress / LTConfig.LinkConfig.RescueMaxValue
end

local IsPlayerShieldIndex = function(index)
	local cfg = LTConfig.ShieldConfig.GetConfig(LTConfig.ShieldConfig.ExtractionBasicShield)

	return cfg and index ~= cfg.Index
end

M.OnShieldChange = function(self, eventId, isOn, templateIdOrIndex, shieldValue, maxShieldValue)
	if isOn then
		if templateIdOrIndex == LTConfig.ShieldConfig.ExtractionBasicShield then
			return
		end

		self.hasShield = true
		self.bindData.hpTypeCtrl = self.HPTypeEnum.Sheild
		local shieldFill = maxShieldValue and maxShieldValue <= 0 and shieldValue / maxShieldValue or 0
		self.hpBar.shield.fillAmount = shieldFill
	else
		if not IsPlayerShieldIndex(templateIdOrIndex) then
			return
		end

		self.hasShield = false
		self.bindData.hpTypeCtrl = self.HPTypeEnum.Normal

		self.OnRefreshHp(self)
	end
end

M.OnShieldValueChange = function(self, eventId, index, value, maxValue)
	if not self.hasShield or not IsPlayerShieldIndex(index) then
		return
	end

	local shieldFill = maxValue <= 0 and value / maxValue or 0
	self.hpBar.shield.fillAmount = shieldFill
end

M.RefreshRaidIdChange = function(self, eventId)
	if self.bindData.hpTypeCtrl ~= self.HPTypeEnum.FallingDown then
		local playerUnit = gCS.MyPlayerManager.PlayerUnit

		if not gCS.UnitStateMgr:HasState(playerUnit, LTConfig.UnitStateConfig.Savable) then
			self.bindData.hpTypeCtrl = self.HPTypeEnum.Normal
		end
	end
end

M.CheckOxygenShow = function(self, eventId, isOpen)
	if isOpen then
		self.isOxygenSystemOn = true
	else
		self.isOxygenSystemOn = false
		self.isOxygenOnShow = false
		self.bindData.oxygenTab.selectedIndex = -1
		self.preOxygen = nil
	end
end

M.UpdateOxygenUI = function(self, eventId, oxygenValue)
	if not self.isOxygenSystemOn then
		return
	end

	if not self.isOxygenOnShow then
		self.preOxygen = oxygenValue

		if gCoreHudUIManager.isInDive and oxygenValue >= gCoreHudUIManager.O2Max then
			self.bindData.oxygenTab.selectedIndex = 0

			if self.curOxygenTabStore then
				self.curOxygenTabStore.colorCtrl = oxygenValue < gCoreHudUIManager.O2LowThreshold and 1 or 0
			end

			self.isOxygenOnShow = true
		end

		return
	end

	if not self.curOxygenTabStore then
		return
	end

	if self.preOxygen and self.preOxygen - oxygenValue > 5 then
		local startOxygen = self.preOxygen
		slot4 = DOTween.To(function ()
			return startOxygen / gCoreHudUIManager.O2Max
		end, function (value)
			self.curOxygenTabStore.flashBar.fillAmount = value
		end, oxygenValue / gCoreHudUIManager.O2Max, 0.3)
		slot4 = slot4:SetEase(Ease.Linear)
		local oxygenTween = slot4:OnKill(function ()
			self.preOxygen = oxygenValue
			self.oxygenTween = nil
		end)
		self.oxygenTween = oxygenTween
	end

	self.curOxygenTabStore.hpBar.fillAmount = oxygenValue / gCoreHudUIManager.O2Max

	if oxygenValue < gCoreHudUIManager.O2LowThreshold then
		self.curOxygenTabStore.colorCtrl = 1
	else
		self.curOxygenTabStore.colorCtrl = 0
	end

	gMainMenuMgr:RefreshFullScreenLowHpAni(oxygenValue / gCoreHudUIManager.O2Max, true)

	if oxygenValue ~= gCoreHudUIManager.O2Max or oxygenValue ~= 0 then
		self.isOxygenOnShow = false
		self.bindData.oxygenTab.selectedIndex = -1
		self.preOxygen = nil
	end

	if not gCoreHudUIManager.isInDive then
		self.preOxygen = oxygenValue
	end
end

M.OnOxygenRenderTab = function(self, index, widget)
	self.curOxygenTabStore = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	self.curOxygenTabStore.hpBar.fillAmount = 1
end
