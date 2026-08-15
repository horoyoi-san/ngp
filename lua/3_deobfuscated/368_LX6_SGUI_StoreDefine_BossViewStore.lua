local GameConfig = LTConfig.GameConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local AnimMgr = SGUI.AnimMgr
local ShieldType = {
	Single = 0,
	Hide = 2,
	Multi = 1
}
local BossLevel = {
	safe = 0,
	dangerous = 2,
	warning = 1
}
local RampageType = {
	Accumulate = 0,
	Hide = 2,
	Release = 1
}
local JinShenType = {
	Hide = 1,
	Show = 0
}
C_BossViewStore = DefClass("C_BossViewStore", C_BossViewStore, C_StoreGroup)
GroupName2Class.BossViewStore = C_BossViewStore
local M = C_BossViewStore

function M:ctor()
	self.rootAniName = {
		open = "S_vx_BossHpPanel_open",
		unlock = "S_vx_BossHpPanel_UnLock",
		lock = "S_vx_BossHpPanel_Locked",
		close = "S_vx_BossHpPanel_close"
	}
	self.currentEnemyCfg = nil
	self.shakePosFrameCount = 0
	self.dropHpEffectTimes = 0
	self.dropShieldEffectTimes = 0
	self.maxShieldCount = 0
	self.showBuffs = {}
	self.shields = {}
	self.defaultPos = Vector3.zero
	self.offsetPos = Vector3.zero
	self.hpGlintEffectPos = Vector3.zero
	self.aniElementDelay = {}
	self.isFirstUpdate = false
	self._showBossHpPanel = nil
	self.weakBarFullAni = "S_vx_BossHpPanel_weakbar"
	self.loopName = "S_Vx_BossElementTemplate_Max"
end

function M:OnGroupEnable()
	self:RegisterAction()
	self:InitDatas()

	gLuaUIMgr.bossViewPanel = self

	gMainMenuMgr:SetAwakeUI("awakeBossViewPanel")
end

function M:OnShow()
	gBossViewManager:DebugLog("BossViewShow OnShow", gBossViewManager.bossId, gBossViewManager.bossConfig and gBossViewManager.bossConfig.Id or "no cfg")

	if not gBossViewManager.bossId or gBossViewManager.bossId == 0 then
		gBossViewManager:DebugLog("BossViewShow OnShow no boss , close panel")
		gPanelManager:Close(gBossViewManager:GetBossPanelId())

		return
	end

	self.showDist = 0
	self.isFirstUpdate = true
	local bossUnit = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)

	if bossUnit ~= nil then
		self:InitBossInfo(bossUnit)
		self:RefreshBasicInfo()
		self:ShowBossHpPanel(false, true)
		gBattleMgr:CommonPlayAniTool(self.bindData.rootAni, self.rootAniName.open, 0, 1, true)

		if gBossViewManager.delayClosePanel then
			gLuaTimeMgrUtils:CancelUnitDelay(gBossViewManager.delayClosePanel)

			gBossViewManager.delayClosePanel = nil
		end
	else
		self:ShowBossHpPanel(false, true)
	end
end

function M:OnUpdate()
	self:UpdateRampageTime()
	self:UpdateWeakBar()
	self:CheckShakeNodePosition()

	if self.isFirstUpdate then
		self.isFirstUpdate = false

		self:RefreshBasicInfo()

		return
	end

	local visible = self:CanShowHP()

	self:ShowBossHpPanel(visible)

	if visible then
		self:UpdateHpBar()

		if self.shakePosFrameCount > 0 then
			self.shakePosFrameCount = self.shakePosFrameCount - 1

			if self.shakePosFrameCount > 0 then
				self:ShakeHpBarPosition()
			else
				self:ResetHpBarPosition()
			end
		end
	end
end

function M:OnClose()
	gBossViewManager:DebugLog("BossViewShow OnClose", gBossViewManager.bossId)
end

function M:OnDestroy()
	self:ClearMessageEvents()

	gLuaUIMgr.bossViewPanel = nil
end

function M:RegisterAction()
	self.msgEvents = {
		[gEventConstants.REFRESH_BOSSVIEW_BUFFS] = self:CreateAction("OnRefreshBuffs"),
		[gEventConstants.BOSS_HP_PANEL_DOWN] = self:CreateAction("CheckPosDown")
	}

	self:RegisterMessageEvents(self.msgEvents)
	self:InitDataSetEvents()

	self.bindData.shieldList.luaSimpleRenderItem = self:CreateAction("OnRenderShieldItem")
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
			"shield",
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

function M:InitDatas()
	self.defaultPos = Vector3.zero

	self:CheckShakeNodePosition()

	self.bindData.shieldTypeCtrl = ShieldType.Hide
	self.bindData.bossLevelCtrl = BossLevel.dangerous
end

function M:InitBossInfo(bossUnit)
	local clientData = bossUnit.ClientData
	local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
	self.unitAgentCfg = LTConfig.AgentConfig.GetConfig(agentId)

	if self.unitAgentCfg == nil then
		gBossViewManager:DebugLog("BossViewShow Cant Find Boss", agentId)

		return
	end

	self.currentEnemyCfg = self.unitAgentCfg
	self.showDist = self.unitAgentCfg.ShowBossHpInDistance
	self.showBossHpInLockPlayer = self.unitAgentCfg.ShowBossHpInLockPlayer
	self.maxShieldCount = 0
	local shieldCfg = LTConfig.ShieldConfig.GetConfig(self.unitAgentCfg.ShieldIds[1])

	if shieldCfg and shieldCfg.ShieldStrip and shieldCfg.ShieldStrip > 1 then
		self.maxShieldCount = shieldCfg.ShieldStrip
	end
end

function M:RefreshBasicInfo()
	local unit = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)

	if unit ~= nil then
		self.bindData.bossName = gBossViewManager.bossConfig.Name
		self.bindData.bossLevel = gUIUtils:IsInShowEnemyLevelRaid() and "Lv." .. unit.ClientData.Level or ""
		self.bindData.RampageType = RampageType.Hide

		self:CheckPosDown(nil, gBossViewManager.bossHpPanelDown)
		self:ForceSetHPValue(unit.ClientData.Hp, unit.ClientData.MaxHp)
		self:RefreshBossShield()

		self.shakePosFrameCount = 0
	end
end

function M:ForceSetHPValue(hpValue, maxHpValue)
	local mount = hpValue > 0 and hpValue / maxHpValue or 0
	self.bindData.weakHpCom.fillAmount = mount

	self.bindData.hpCom:ProgressToValue(mount, 0)

	self.bindData.healCom.fillAmount = mount
	self.bindData.flickerCom.fillAmount = mount
	self.bindData.flickerCom.renderOpacity = 0
	self.hpValue = hpValue
end

function M:UpdateHpBar()
	local bossUnit = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)

	if bossUnit == nil then
		self:ShowBossHpPanel(false)

		return
	end

	local hpValue = bossUnit.ClientData.Hp
	local maxHpValue = bossUnit.ClientData.MaxHp

	if self.hpValue ~= nil and self.hpValue ~= 0 and hpValue == self.hpValue then
		gBossViewManager.playedDeadEffect = false

		return
	end

	local isRecover = false

	if self.hpValue ~= nil and self.hpValue ~= 0 and self.hpValue < hpValue then
		isRecover = true
	end

	self.hpValue = hpValue
	local mount = hpValue > 0 and hpValue / maxHpValue or 0

	if mount <= 0 and not gBossViewManager.playedDeadEffect then
		gBossViewManager.playedDeadEffect = true

		self:PlayDeadEffect()
	end

	if isRecover then
		AnimMgr.Kill(self.bindData.weakHpCom.transform, "BossWeakHpTween", true)
		self:PlayRecoverHp(self.bindData.hpCom.value, mount)
	else
		local preHp = self.bindData.hpCom.value

		self.bindData.hpCom:ProgressToValue(mount, 0)

		self.bindData.healCom.fillAmount = mount

		AnimMgr.Kill(self.bindData.flickerCom.transform, "BossFlickerTween")

		if self.bindData.shieldTypeCtrl == ShieldType.Multi then
			self.bindData.flickerCom.renderOpacity = 0

			self:PlayDropHp(preHp, mount)
			gBattleMgr:CommonPlayAniTool(self.bindData.rootAni, self.rootAniName.lock, 0, 1, true)
		else
			self.bindData.flickerCom.renderOpacity = 1

			AnimMgr.DoAlpha(self.bindData.flickerCom, "BossFlickerTween", 0, 0.1, 0, DG.Tweening.Ease.Linear, function ()
				self:PlayDropHp(preHp, mount)
				self:StartShakeHpBar()
			end, false)
		end
	end
end

function M:PlayRecoverHp(curHpFill, toHpFill)
	self.bindData.healCom.fillAmount = toHpFill
	self.bindData.weakHpCom.fillAmount = toHpFill
	self.bindData.flickerCom.fillAmount = toHpFill

	self.bindData.hpCom:ProgressToValue(toHpFill, 1)
end

function M:PlayDropHp(curHpFill, toHpFill)
	local dropHpfill = Mathf.Abs(toHpFill - curHpFill)
	local isEquip = self.bindData.hpCom.value == self.bindData.weakHpCom.fillAmount
	self.bindData.flickerCom.fillAmount = toHpFill

	AnimMgr.Kill(self.bindData.weakHpCom.transform, "BossWeakHpTween")

	if dropHpfill < GameConfig.BossWeakHpTypeAPercent then
		self.dropHpEffectTimes = self.dropHpEffectTimes + 1
		local delay = GameConfig.BossWeakHpTypeAPauseTime

		if self.dropHpEffectTimes == 3 then
			delay = 0
			self.dropHpEffectTimes = 0
		end

		AnimMgr.DoFill(self.bindData.weakHpCom, "BossWeakHpTween", toHpFill, 1, delay, DG.Tweening.Ease.OutCirc, nil, false)
	elseif GameConfig.BossWeakHpTypeAPercent <= dropHpfill and dropHpfill < GameConfig.BossWeakHpTypeBPercent then
		local delay = 0

		if isEquip then
			delay = GameConfig.BossWeakHpTypeBPauseTime
		end

		AnimMgr.DoFill(self.bindData.weakHpCom, "BossWeakHpTween", toHpFill, 1, delay, DG.Tweening.Ease.OutCirc, nil, false)

		self.dropHpEffectTimes = 0
	else
		AnimMgr.DoFill(self.bindData.weakHpCom, "BossWeakHpTween", toHpFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)

		self.dropHpEffectTimes = 0
	end
end

function M:RefreshBossShield()
	if gBossViewManager.bossId == nil or ulong.equals(gBossViewManager.bossId, 0) then
		return false
	end

	local wholeShield, wholeShieldMax = gCS.BattleManager.GetBossLocShieldValue(gBossViewManager.bossId, 0, 1)
	local showShield = wholeShield and wholeShieldMax and wholeShield ~= 0 and wholeShieldMax ~= 1
	local index = gCS.BattleManager.GetBossLocShieldIndex(gBossViewManager.bossId)
	local shieldCfg = LTConfig.ShieldConfig.GetConfig(self.currentEnemyCfg.ShieldIds[index])

	if shieldCfg then
		showShield = showShield and shieldCfg.ShowShield

		if shieldCfg.ShieldStrip and shieldCfg.ShieldStrip > 1 then
			self.maxShieldCount = shieldCfg.ShieldStrip
		end
	end

	if self.maxShieldCount > 1 then
		self:CheckShowMultiShieldEffect(showShield, wholeShield)
	else
		self:CheckShowSingleShieldEffect(showShield, wholeShield)
	end

	if showShield then
		self.bindData.shieldTypeCtrl = self.maxShieldCount > 1 and ShieldType.Multi or ShieldType.Single
		self.bindData.jinshenCtrl = self.maxShieldCount > 1 and JinShenType.Show or JinShenType.Hide
		self.bindData.hpBarJinshenCtrl = self.maxShieldCount > 1 and JinShenType.Show or JinShenType.Hide
	else
		self.bindData.shieldTypeCtrl = ShieldType.Hide
		self.bindData.jinshenCtrl = JinShenType.Hide
		self.bindData.hpBarJinshenCtrl = JinShenType.Hide
	end

	if wholeShieldMax ~= nil and wholeShieldMax > 0 then
		local fill = wholeShield / wholeShieldMax

		if fill ~= self.bindData.shieldCom.value then
			self:PlayDropShield(self.bindData.shieldCom.value, fill)
		end
	end
end

function M:PlayDropShield(curShieldFill, toShieldFill)
	local dropShieldFill = Mathf.Abs(toShieldFill - curShieldFill)
	local isEquip = self.bindData.shieldCom.value == self.bindData.weakShieldCom.fillAmount

	self.bindData.shieldCom:ProgressToValue(toShieldFill, 0)

	if dropShieldFill < GameConfig.BossWeakHpTypeAPercent then
		self.dropShieldEffectTimes = self.dropShieldEffectTimes + 1
		local delay = GameConfig.BossWeakHpTypeAPauseTime

		if self.dropShieldEffectTimes == 3 then
			delay = 0
			self.dropShieldEffectTimes = 0
		end

		AnimMgr.DoFill(self.bindData.weakShieldCom, "BossWeakHpTween", toShieldFill, 1, delay, DG.Tweening.Ease.OutCirc, nil, false)
	elseif GameConfig.BossWeakHpTypeAPercent <= dropShieldFill and dropShieldFill < GameConfig.BossWeakHpTypeBPercent then
		local delay = 0

		if isEquip then
			delay = GameConfig.BossWeakHpTypeBPauseTime
		end

		AnimMgr.DoFill(self.bindData.weakShieldCom, "BossWeakHpTween", toShieldFill, 1, delay, DG.Tweening.Ease.OutCirc, nil, false)

		self.dropShieldEffectTimes = 0
	else
		AnimMgr.DoFill(self.bindData.weakShieldCom, "BossWeakHpTween", toShieldFill, 1, 0, DG.Tweening.Ease.OutCirc, nil, false)

		self.dropShieldEffectTimes = 0
	end
end

function M:OnRenderShieldItem(btn, index)
	index = index + 1
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.shields[index]
	store.shieldCtrl = data.show and 0 or 1
end

function M:UpdateRampageTime()
	if self.bindData.bossRageCtrl == RampageType.Accumulate then
		local fill = Mathf.Clamp(1 - (self.ramPageEndTime - gLogicTime.time) / self.ramPageAllTime, 0, 1)
		self.bindData.regaFill = fill
		self.bindData.regaCountDown = math.ceil(self.ramPageEndTime - gLogicTime.time) .. "s"

		if fill >= 1 then
			self:EndRampageCountDown()
		end
	end
end

function M:ShowRampageUI()
	self.bindData.bossRageCtrl = RampageType.Accumulate

	self:UpdateRampageTime()

	local ani = self.bindData.rampageAni
	local clipName = "S_vx_bosshpRageBar_open"

	gBattleMgr:CommonPlayAniTool(ani, clipName, 0, 1)
end

function M:HideRampageUI(skillId)
	if self.ramPageSkillId ~= skillId then
		return
	end

	self.bindData.bossRageCtrl = RampageType.Hide
end

function M:InitRampageInfo(rampageAllTime, skillId)
	rampageAllTime = rampageAllTime or 0
	self.ramPageAllTime = rampageAllTime
	self.ramPageEndTime = gLogicTime.time + rampageAllTime
	self.ramPageSkillId = skillId

	self:ShowRampageUI()
end

function M:EndRampageCountDown()
	self.bindData.bossRageCtrl = RampageType.Release
	local ani = self.bindData.rampageAni
	local clipName = "S_vx_bosshpRageBar_release"

	gBattleMgr:CommonPlayAniTool(ani, clipName, 0, 1)
end

function M:CanShowHP()
	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BossHp) then
		return false
	end

	if self.showDist == nil then
		return false
	end

	if gBossViewManager.bossId == nil or ulong.equals(gBossViewManager.bossId, 0) then
		return false
	end

	local boss = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)

	if not boss then
		return false
	end

	if self.showBossHpInLockPlayer and (not boss.LockTargetId or ulong.equals(boss.LockTargetId, 0)) then
		return false
	end

	if self.showDist > 0 and self.showDist < gCS.LuaUtils.ComputeUnitDist(gBossViewManager.bossId, gCS.MyPlayerManager.PlayerUnit.Pid) then
		return false
	end

	if gBossViewManager.forceHideHpBar then
		return false
	end

	return true
end

function M:ShowBossHpPanel(show, force)
	if force or self._showBossHpPanel ~= show then
		gBossViewManager:DebugLog("ShowBossHpPanel", gBossViewManager.bossId, self._showBossHpPanel, "---", show, force)
		self.bindData.panelRoot:SetActiveFastest(show)

		if show then
			local unit = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)

			if unit ~= nil then
				self:ForceSetHPValue(unit.ClientData.Hp, unit.ClientData.MaxHp)
			end
		end
	end

	self._showBossHpPanel = show
end

function M:ShowStartShieldEffect()
	return
end

function M:ShowEndShieldEffect()
	return
end

function M:CheckShowSingleShieldEffect(showShield, wholeShield)
	if self.bindData.shieldTypeCtrl ~= ShieldType.Hide and not showShield then
		-- Nothing
	end
end

function M:CheckShowMultiShieldEffect(showShield, wholeShield)
	local playEndAction = false

	if self.bindData.shieldTypeCtrl ~= ShieldType.Hide and not showShield then
		playEndAction = true
	elseif self.bindData.shieldTypeCtrl == ShieldType.Hide and showShield then
		-- Nothing
	end

	if showShield or playEndAction then
		table.clear(self.shields)

		for i = 1, self.maxShieldCount do
			local shield = {
				show = i <= wholeShield
			}

			table.insert(self.shields, shield)
		end

		self.bindData.shieldList:SetSimpleList(#self.shields)
	end
end

function M:SwitchDifferentBossForceSet()
	self.bindData.shieldTypeCtrl = ShieldType.Hide

	self:RefreshBasicInfo()
end

function M:PlayDeadEffect()
	local clpName = self.rootAniName.close
	local ani = self.bindData.rootAni
	gBossViewManager.delayClosePanel = gBattleMgr:CommonPlayAniTool(ani, clpName, 0, 1, false, function ()
		if gCS.LuaUtils.IsNull(ani) or gBossViewManager.delayClosePanel == nil then
			return
		end

		self:ShowBossHpPanel(false, true)
		gPanelManager:Close(gBossViewManager:GetBossPanelId())

		gBossViewManager.delayClosePanel = nil
	end)
end

function M:CheckShakeNodePosition()
	local newY = -28

	if newY ~= self.bindData.shakeNode.transform.localPosition.y then
		self.defaultPos.y = newY

		self.bindData.shakeNode.transform:SetLocalPosition(self.defaultPos.x, self.defaultPos.y, self.defaultPos.z)
	end
end

function M:GetRandomOffset()
	local rand = math.random(GameConfig.BossHeathBarShakeMinDistance, GameConfig.BossHeathBarShakeMaxDistance)
	rand = rand * (math.random(1, 2) == 1 and 1 or -1)

	return rand
end

function M:ShakeHpBarPosition()
	local xOffset = self:GetRandomOffset()
	local yOffset = self:GetRandomOffset()
	self.offsetPos.x = self.defaultPos.x + xOffset
	self.offsetPos.y = self.defaultPos.y + yOffset

	self.bindData.shakeNode.transform:SetLocalPosition(self.offsetPos.x, self.offsetPos.y, self.offsetPos.z)
end

function M:ResetHpBarPosition()
	self.bindData.shakeNode.transform:SetLocalPosition(self.defaultPos.x, self.defaultPos.y, self.defaultPos.z)
end

function M:StartShakeHpBar()
	if self.bindData.shieldTypeCtrl == ShieldType.Multi then
		return
	end

	self.shakePosFrameCount = GameConfig.BossHeathBarShakeDuring
end

function M:UpdateWeakBar()
	local bossUnit = gCS.SceneDataMgr.GetUnit(gBossViewManager.bossId)
	local needShow = self:GetNeedShowWeakBar(bossUnit)

	if needShow ~= self.bindData.showWeakBar then
		self.bindData.showWeakBar = needShow
	end

	if needShow == 0 then
		return
	end

	local rate = bossUnit.ClientData.DisarmRate

	if self.bindData.weakRate ~= rate then
		self.bindData.weakRate = rate
		local showFull = rate == 1 and 1 or 0

		if showFull ~= self.bindData.showFullWeak then
			self.bindData.showFullWeak = showFull

			if showFull == 1 then
				gBattleMgr:CommonPlayAniTool(self.bindData.weakBarAni, self.weakBarFullAni, 0, 1, false)
			else
				gBattleMgr:CommonSampleAnimation(self.bindData.weakBarAni, self.weakBarFullAni, 0)
			end
		end
	end
end

function M:GetNeedShowWeakBar(bossUnit)
	if bossUnit == nil then
		return 0
	end

	if self.unitAgentCfg then
		local growthCfg = LTConfig.EnemyGrowthSchemeConfig.GetConfig(self.unitAgentCfg.AttributeSchemeId)

		if growthCfg and growthCfg.MaxPoiseValue <= 0 then
			return 0
		end
	end

	return 1
end

function M:CheckPosDown(eventId, enable)
	self.bindData.downCtrl = enable and 1 or 0
end
