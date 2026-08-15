local HUDCtrl = require("LX6/Manager/HUD/HudController")
local AgentConfig = LTConfig.AgentConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local StealthEnemyConfig = LTConfig.AgentDetectConfig
local EnemyGrowthSchemeConfig = LTConfig.EnemyGrowthSchemeConfig
local AttributeNameConfig = LTConfig.AttributeNameConfig
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local HUDManager = LX6.GUI.HUDNew.HUDManager
local DetectStealthState = UX.Game.EnemyDetectState
C_EnemyHUDCtrl = DefClass("C_EnemyHUDCtrl", C_EnemyHUDCtrl, HUDCtrl)

local function ClampHpValue(value, max)
	if value <= 0 or max <= 0 then
		return 0
	end

	local x = value / max

	if x < 0 then
		return 0
	elseif x > 1 then
		return 1
	else
		return x
	end
end

local EnemyHUDCtrl = C_EnemyHUDCtrl

function EnemyHUDCtrl:ctor()
	self.tType = gHudMgr.HUDTargetType.Enemy
	self.showDisarm = false
	self.showAttractedEffect = false
	self.showDetect = false
	self.hintShowType = 0
	self.forceHideHp = false
	self.OnSystemUnlockHandler = nil
	self.onMindIconEnemyChanged = nil
	self.isPveRaid = nil
	self.cfg = nil
	self.hpVisible = false
	self.detectVisible = false
	self.dangerIconVisible = false
	self.enemyPosVisible = false
end

function EnemyHUDCtrl:RegisterBindHandlers()
	EnemyHUDCtrl.base.RegisterBindHandlers(self)

	if not self.unitDataSet then
		print_error("EnemyHUD对应unit数据不存在!", self.uniId)

		return
	end

	if not self.cfg then
		print_error("EnemyConfig数据不存在或非同帧内使用cfg数据！", self.uniId, self.unit.ClientData.SubType)

		return
	end

	if self.cfg.DetectId ~= 0 then
		local stealthEnemyCfg = StealthEnemyConfig.GetConfig(self.cfg.DetectId)

		if stealthEnemyCfg and stealthEnemyCfg.EnterVisionRange and stealthEnemyCfg.EnterVisionRange.DetectRadius ~= 0 then
			if self.unitDataSet.detectionValue == nil then
				self.unitDataSet.detectionValue = 0
			end

			if self.unitDataSet.detectionState == nil then
				self.unitDataSet.detectionState = DetectStealthState.Idle
			end

			self.eventSet:BindHandler(self.unitDataSet, "detectionState", self.OnShowDetectionEffect, self)
			self.eventSet:BindHandler(self.unitDataSet, "detectionValue", self.OnRefreshDetectionValue, self)
			self.eventSet:BindHandler(self.unitDataSet, "beingAssassinated", self.OnRefreshDetectionValue, self)
			self.eventSet:BindHandler(self.unitDataSet, "beAttracted", self.OnShowAttractedEffect, self)
			self.eventSet:BindHandler(self.unitDataSet, "enableIdleHint", self.OnRefreshIdleHint, self)
			self.eventSet:BindHandler(self.unitDataSet, "beingAssassinated", self.OnShowDangerState, self)
		end
	end

	local needBind = self.cfg.ShowHPBarUnderAttack or self.cfg.ShowHPBar
	self.isMinion = self.unit.ClientData.Type == UX.Game.EntityType.Player

	if self.isPveRaid and self.isMinion then
		needBind = false
	end

	if needBind then
		self.eventSet:BindHandler2({
			self.unitDataSet,
			"isDead",
			self.unitDataSet,
			"realInVisiable",
			self.unitDataSet,
			"showHpOrUnderAttack",
			self.unitDataSet,
			"isBuffHideNameBar",
			self.unitDataSet,
			"isGrabByMind"
		}, self.OnRefreshVisible, self)
	end

	self.eventSet:BindHandler(self.unitDataSet, "level", self.OnRefreshLevel, self)
	self.eventSet:BindHandler(self.unitDataSet, "showPartBarUnderAttack", self.OnRefreshPartBar, self)
	self.eventSet:BindHandler(self.unitDataSet, "isDead", self.OnDead, self)
	self.eventSet:BindHandler(gBattleMgr.dataSet, "showEnemyHp", self.OnRefreshVisible, self)
end

function EnemyHUDCtrl:RegisterEventListener()
	function self.OnSystemUnlockHandler(event, data)
		self:SystemUnlock(data)
	end

	function self.onMindIconEnemyChanged()
		self:RefreshHpVisible()
	end

	function self.onWeaponChange(eventId, data)
		self:RefreshWeakRate(eventId, data)
	end

	gMessageManager:AddMessageListener(gEventConstants.MIND_ICON_ENEMY_CHANGED, self.onMindIconEnemyChanged)
	gMessageManager:AddMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self.OnSystemUnlockHandler)
	gMessageManager:AddMessageListener(gEventConstants.WEAPON_CHANGED, self.onWeaponChange)
end

function EnemyHUDCtrl:RefreshData()
	local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	self.isPveRaid = raidTypeConfig.Type == RaidRaidTypeConfig.TypeType.SoloPve or raidTypeConfig.Type == RaidRaidTypeConfig.TypeType.TeamPve or raidTypeConfig.Type == RaidRaidTypeConfig.TypeType.JvQing
	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
	local cfg = AgentConfig.GetConfig(agentId)
	self.cfg = cfg
	self.maxDisarmValue = 0
	local growthCfg = EnemyGrowthSchemeConfig.GetConfig(self.cfg.AttributeSchemeId)

	if growthCfg then
		self.maxDisarmValue = growthCfg.MaxPoiseValue
	end
end

function EnemyHUDCtrl:CustomProcedure()
	local camp = self.unit.ClientData.Camp

	if camp == 6 or camp == 7 then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.BVB, self.unit.Pid)
	end

	self.disarmTween = nil
end

function EnemyHUDCtrl:OnCreateEnemyHpBar()
	local ani = self.template.hpBar.anim
	local clip = ani:GetClip("S_vx_EmenyHpTemplate_close")

	clip:SampleAnimation(ani.gameObject, 0)
	ani:Stop("S_vx_EmenyHpTemplate_close")
	self:HpChanged()
	self:RefreshHpVisible()

	self.template.hpBar.levelText = self.unit.ClientData.Level

	self.template.hpBar.levelNode:SetLocalScale(self:ShowLevelText() and 1 or 0)

	local hpThreshold = AttributeNameConfig.HPLengthThreshold
	local disarmThreshold = AttributeNameConfig.PoiseLengthThreshold
	local hpMax = self.unit.ClientData.MaxHp

	if hpMax < hpThreshold.para1 then
		self.template.hpBar.hpTypeCtrl = 2
	elseif hpThreshold.para1 <= hpMax and hpMax < hpThreshold.para2 then
		self.template.hpBar.hpTypeCtrl = 1
	else
		self.template.hpBar.hpTypeCtrl = 0
	end

	if self.maxDisarmValue < disarmThreshold.para1 then
		self.template.hpBar.disarmTypeCtrl = 2
	elseif disarmThreshold.para1 <= self.maxDisarmValue and self.maxDisarmValue < disarmThreshold.para2 then
		self.template.hpBar.disarmTypeCtrl = 1
	else
		self.template.hpBar.disarmTypeCtrl = 0
	end
end

function EnemyHUDCtrl:ShowHpBar(visible)
	if self.unit and self.unit.IsDead and self.template.hpBar then
		local ani = self.template.hpBar.anim

		ani:Play("S_vx_EmenyHpTemplate_close")

		local clip = ani:GetClip("S_vx_EmenyHpTemplate_close")

		gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if gCS.LuaUtils.IsNull(ani) or not self.template.hpBar then
				return
			end

			clip:SampleAnimation(ani.gameObject, 0)
			ani:Stop("S_vx_EmenyHpTemplate_close")
			self.template.hpBar.template:SetTemplateVisibility(false)

			self.hpVisible = false
		end, clip.length)

		return
	end

	if visible then
		self:CheckShowDisarmBar()
	end

	self.uiRoot:SetIgnoreDistance(visible)
	self.template.hpBar.template:SetTemplateVisibility(visible)

	self.hpVisible = visible

	self:RefreshDangerIcon()
	self.template.hpBar.hpNode:SetLocalScale(gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.EnemyHp) and 1 or 0)
end

function EnemyHUDCtrl:HpChanged()
	if not self.template.hpBar then
		return
	end

	local unit = self.unit
	local hp1 = unit.ClientData.Hp + unit.ClientData.Shield

	if hp1 < 0 then
		hp1 = 0
	end

	local sum = unit.ClientData.Hp + unit.ClientData.Shield

	if sum >= 0 then
		sum = Mathf.Max(unit.ClientData.MaxHp, sum)
		local oldHpValue = self.template.hpBar.hpBar.fillAmount
		local newHpValue = ClampHpValue(hp1, sum)

		if oldHpValue <= newHpValue then
			self.template.hpBar.hpBar.fillAmount = newHpValue
			self.template.hpBar.weakHpBar.fillAmount = newHpValue
			self.template.hpBar.flashBar.fillAmount = newHpValue
		else
			if self.flashTweenFill then
				self.flashTweenFill:Kill()
			end

			if self.weakTweenFill then
				self.weakTweenFill:Kill()
			end

			self.template.hpBar.flashBar.renderOpacity = 1
			self.flashTweenFill = DOTween.To(function ()
				return self.template.hpBar.flashBar.renderOpacity
			end, function (value)
				if self.template.hpBar then
					self.template.hpBar.flashBar.renderOpacity = value
				end
			end, 0, 0.1):SetEase(Ease.Linear):OnKill(function ()
				self.flashTweenFill = nil
			end)

			gLuaTimeMgrUtils.NotDestroyDelay(function ()
				if self.template.hpBar and not self.unit.IsDead then
					local duration = (self.template.hpBar.weakHpBar.fillAmount - newHpValue) * 100 / GameConfig.WeakHpDecreaseSpeed
					self.template.hpBar.flashBar.fillAmount = newHpValue
					self.weakTweenFill = DOTween.To(function ()
						return self.template.hpBar.weakHpBar.fillAmount
					end, function (value)
						if self.template.hpBar then
							self.template.hpBar.weakHpBar.fillAmount = value
						end
					end, newHpValue, duration):SetEase(Ease.Linear):OnKill(function ()
						self.weakTweenFill = nil
					end)
				end
			end, 0.1)

			self.template.hpBar.hpBar.fillAmount = newHpValue
		end
	end
end

function EnemyHUDCtrl:CheckShowDisarmBar()
	local needShow = self.maxDisarmValue > 0 and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.EnemyDisarmBar)

	if self.showDisarm == needShow and self.template.hpBar.disarmNode.gameObject.activeSelf == needShow then
		return
	end

	self.showDisarm = needShow

	self.template.hpBar.disarmNode.gameObject:SetActive(needShow)
	self:DisarmChanged()
end

function EnemyHUDCtrl:DisarmChanged()
	if not self.showDisarm or not self.template.hpBar then
		return
	end

	local oldHpValue = self.template.hpBar.disarmBarFill or self.unit.ClientData.DisarmRate
	local fillAmount = self.unit.ClientData.DisarmRate
	local maxValue = self.maxDisarmValue

	if self.template.hpBar.disarmBarFill == fillAmount then
		return
	end

	local ani = self.template.hpBar.disarmAnim
	local clip = ani:GetClip("S_vx_EmenyHpTemplate_DisarmBar_open")

	if oldHpValue > 0 and oldHpValue < 1 and fillAmount >= 1 then
		ani:Stop()
		ani:Play("S_vx_EmenyHpTemplate_DisarmBar_open")
		gLuaTimeMgrUtils.Delay(function ()
			if not self.template.hpBar then
				return
			end

			ani:Play("S_vx_EmenyHpTemplate_DisarmBar_loop")
		end, clip.length)

		if not gLinkManager:CheckInLinkMode() and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.WeakPercent) then
			self.template.hpBar.weakDetailCtrl = 1
			local rate = gBattleMgr:GetEnemyPoiseWeaponChangeInfo(self.unit.Pid, gCS.WeaponMgr:GetCurrentWeaponInstanceId())
			rate = rate == 0 and "100%" or math.floor(rate * 100) .. "%"
			self.template.hpBar.weakRateText = rate
		end

		if self.disarmTween then
			self.disarmTween:Kill()

			self.disarmTween = nil
		end

		self.disarmTween = DOTween.To(function ()
			if self.template.hpBar then
				return self.template.hpBar.disarmBarFill
			end

			return 0
		end, function (v)
			if self.template.hpBar then
				self.template.hpBar.disarmBarFill = v
				self.template.hpBar.disarmVxBarFill = v
			end
		end, 0.001, gBattleMgr:GetRecoverTime(self.unit.Pid)):SetEase(Ease.Linear):OnKill(function ()
			self.disarmTween = nil
		end)
	else
		local disarmClip = ani:GetClip("S_vx_EmenyHpTemplate_IconBG")

		if (fillAmount - oldHpValue) * maxValue > 0 then
			disarmClip:SampleAnimation(ani.gameObject, 0)
			ani:Stop()
			ani:Play("S_vx_EmenyHpTemplate_IconBG")
		else
			disarmClip:SampleAnimation(ani.gameObject, 0)
			clip:SampleAnimation(ani.gameObject, 0)
			ani:Stop()

			if self.disarmTween then
				self.disarmTween:Kill()

				self.disarmTween = nil
			end

			self.template.hpBar.weakDetailCtrl = 0
		end
	end

	self.template.hpBar.disarmBarFill = fillAmount
	self.template.hpBar.disarmVxBarFill = fillAmount
end

function EnemyHUDCtrl:RefreshWeakRate(eventId, data)
	if not self.template.hpBar then
		return
	end

	if self.template.hpBar.weakDetailCtrl ~= 1 then
		return
	end

	if not gCS.MyPlayerManager.PlayerUnit or gCS.MyPlayerManager.PlayerUnit.Pid ~= data.pid then
		return
	end

	if gLinkManager:CheckInLinkMode() then
		return
	end

	local rate = gBattleMgr:GetEnemyPoiseWeaponChangeInfo(self.unit.Pid, gCS.WeaponMgr:GetCurrentWeaponInstanceId())
	rate = rate == 0 and "100%" or math.floor(rate * 100) .. "%"
	self.template.hpBar.weakRateText = rate
end

function EnemyHUDCtrl:RefreshHpVisible()
	if not self.template.hpBar then
		return
	end

	local dataSet = self.unitDataSet
	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId > 0 and clientData.AgentId or clientData.SubType
	local cfg = AgentConfig.GetConfig(agentId)
	self.cfg = cfg
	local canShowHp = self.cfg.ShowHPBar

	if canShowHp and self.cfg.ShowHPBarUnderAttack then
		canShowHp = dataSet.showHpOrUnderAttack
	end

	if self.isPveRaid and self.isMinion then
		canShowHp = false
	end

	if dataSet.beingAssassinated then
		canShowHp = false
	end

	if self.forceHideHp then
		canShowHp = false
	end

	local shouldShowHp = not dataSet.isDead and not dataSet.isBuffHideNameBar and not dataSet.realInVisiable and not dataSet.isGrabByMind and not gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.NearDeath) and gBattleMgr.dataSet.showEnemyHp
	local showHp = canShowHp and shouldShowHp

	self:ShowHpBar(showHp)
end

function EnemyHUDCtrl:ShowLevelText()
	if gUIUtils:IsInXinShouRaid() then
		return false
	end

	if gUIUtils:IsInShowEnemyLevelRaid() then
		return true
	end

	return false
end

function EnemyHUDCtrl:DestroyHpBar()
	if self.template.hpBar then
		if self.flashTweenFill then
			self.flashTweenFill:Kill()

			self.flashTweenFill = nil
		end

		if self.weakTweenFill then
			self.weakTweenFill:Kill()

			self.weakTweenFill = nil
		end

		local instanceId = self.template.hpBar.wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function EnemyHUDCtrl:CreateHpBar()
	if not self.template.hpBar then
		local unit = self.unit

		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyHpBar, unit.Pid)
	end
end

function EnemyHUDCtrl:SetForceHideHp(force)
	self.forceHideHp = force

	self:RefreshHpVisible()
end

function EnemyHUDCtrl:FrequencyShieldChanged(index)
	if not self.template.hpBar then
		return
	end

	local unit = self.unit
	local shieldValue = gCS.BattleManager.GetPartShieldValue(unit, index)

	if shieldValue > 0 then
		self.template.hpBar.shieldTypeCtrl = 1
		self.template.hpBar.shieldCountText = shieldValue
	else
		self.template.hpBar.shieldTypeCtrl = 0
	end
end

function EnemyHUDCtrl:WholeBodyShieldChanged()
	if not self.template.hpBar then
		return
	end

	local unit = self.unit
	local shieldValue, shieldMaxValue = gCS.ShieldManager:GetWholeBodyShieldValue(unit.Pid, 0, 0)

	if shieldValue > 0 then
		self.template.hpBar.shieldTypeCtrl = 2
		self.template.hpBar.wholeShieldFill = shieldValue / shieldMaxValue
		self.template.hpBar.wholeShieldWeakFill = shieldValue / shieldMaxValue
	else
		self.template.hpBar.shieldTypeCtrl = 0
		self.template.hpBar.wholeShieldFill = 0
		self.template.hpBar.wholeShieldWeakFill = 0
	end
end

function EnemyHUDCtrl:OnCreateEnemyPartShieldBar(index)
	self:ShowPartShieldBar(index, true)
	self:PartShieldChanged(index)
end

function EnemyHUDCtrl:PartShieldChanged(index)
	local unit = self.unit
	local partShieldValue = gCS.BattleManager.GetPartShieldValue(unit, index)
	local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(unit, index)

	if (self.templatesGroup.partBar == nil or self.templatesGroup.partBar[index] == nil) and partShieldValue ~= nil and partShieldValue > 0 and maxPartShieldValue ~= nil and maxPartShieldValue > 0 then
		self:OnPartShieldBar(true, false, index)

		if self.templatesGroup.partBar and self.templatesGroup.partBar[index] then
			local bar = self.templatesGroup.partBar[index].shieldBar
			local weakBar = self.templatesGroup.partBar[index].shieldWeakBar
			bar.fillAmount = Mathf.Max(4 / bar:GetTargetWidth(), ClampHpValue(partShieldValue, maxPartShieldValue))
			weakBar.fillAmount = bar.fillAmount
		end
	elseif self.templatesGroup.partBar and self.templatesGroup.partBar[index] then
		if partShieldValue == nil or partShieldValue <= 0 or maxPartShieldValue == nil or maxPartShieldValue <= 0 then
			self:OnPartShieldBar(false, false, index)
		else
			local bar = self.templatesGroup.partBar[index].shieldBar
			local weakBar = self.templatesGroup.partBar[index].shieldWeakBar
			bar.fillAmount = Mathf.Max(4 / bar:GetTargetWidth(), ClampHpValue(partShieldValue, maxPartShieldValue))
			weakBar.fillAmount = bar.fillAmount

			self:OnPartShieldBar(true, true, index)
		end
	end
end

function EnemyHUDCtrl:OnPartShieldBar(show, needCheckVisible, index)
	local unit = self.unit

	if self:IsHpBarNeverShow() then
		return
	end

	if show then
		if self.templatesGroup.partBar == nil or self.templatesGroup.partBar[index] == nil then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyPartShieldBar, unit.Pid, tostring(index))
		end
	elseif self.templatesGroup.partBar[index] then
		local instanceId = self.templatesGroup.partBar[index].wgtId

		self:RemoveHudTemplate(instanceId)
	end

	if needCheckVisible then
		self:UpdateEnemyPartShieldBarVisible(index)
	end
end

function EnemyHUDCtrl:UpdateEnemyPartShieldBarVisible(index)
	local unit = self.unit

	if unit.ClientData.Type == UX.Game.EntityType.Enemy and self.templatesGroup.partBar and self.templatesGroup.partBar[index] then
		local canShow = false

		if gShieldDefendMgr.CanShow[unit.Pid] and gShieldDefendMgr.CanShow[unit.Pid][tonumber(index)] == true then
			canShow = true
		end

		self:ShowPartShieldBar(index, canShow)
	end
end

function EnemyHUDCtrl:ShowPartShieldBar(index, visible, recursionEnd)
	if not self.templatesGroup.partBar or not self.templatesGroup.partBar[index] then
		return
	end

	local unit = self.unit

	if tonumber(index) > 0 then
		self.templatesGroup.partBar[index].template:SetTemplateVisibility(visible)
	else
		for _, template in pairs(self.templatesGroup.partBar) do
			template.template:SetTemplateVisibility(visible)
		end
	end

	if recursionEnd then
		return
	end

	gLuaTimeMgrUtils.CancelUnitDelay(self.newDelayHideShieldUUID)

	self.newDelayHideShieldUUID = gLuaTimeMgrUtils.Delay(function ()
		if unit and self.templatesGroup.partBar and self.templatesGroup.partBar[index] then
			self:ShowPartShieldBar(index, false, true)
		end
	end, 3, nil, nil, true)
end

function EnemyHUDCtrl:SetHpHideByBarrier(enable)
	if not self.template.hpBar then
		return
	end

	self.template.hpBar.template.SetHideByBarrier = enable
end

function EnemyHUDCtrl:OnCreateBVBTemplate()
	local camp = self.unit.ClientData.Camp

	if not self.template.BVB then
		return
	end

	if camp == 6 then
		self.template.BVB.playerCtrl = 0
	elseif camp == 7 then
		self.template.BVB.playerCtrl = 1
	end
end

function EnemyHUDCtrl:OnCreateStealthDetectValue()
	if self.unitDataSet.beAttracted then
		self.template.detect.attractedEffect.gameObject:SetActive(true)

		self.showAttractedEffect = true
	else
		self.template.detect.attractedEffect.gameObject:SetActive(false)

		self.showAttractedEffect = false
	end

	self:RefreshShowDetectRoot()

	self.template.detect.fillValue = 0
end

function EnemyHUDCtrl:RefreshShowDetectRoot()
	if self.template.detect and gClientUtils.NotNil(self.template.detect.template) then
		self.template.detect.template:SetTemplateVisibility(self.showAttractedEffect or self.showDetect)

		self.detectVisible = self.showAttractedEffect or self.showDetect

		self:RefreshDangerIcon()
	end
end

function EnemyHUDCtrl:OnCreatDangerIcon()
	self:RefreshDangerIcon()
end

function EnemyHUDCtrl:RefreshDangerIcon()
	if self.template.dangerIcon and self.unitDataSet then
		local visible = not self.hpVisible and not self.detectVisible and not self.unitDataSet.isDead

		self.template.dangerIcon.template:SetTemplateVisibility(visible)

		self.dangerIconVisible = visible

		self:RefreshEnemyPosition()
	end
end

function EnemyHUDCtrl:RemoveDangerIcon()
	if self.template.dangerIcon then
		local instanceId = self.template.dangerIcon.wgtId

		self:RemoveHudTemplate(instanceId)
	end
end

function EnemyHUDCtrl:OnCreateEnemyPosition()
	if self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] ~= nil then
		self.enemyPosVisible = self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition]

		self:RefreshEnemyPosition()

		self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] = nil
	end
end

function EnemyHUDCtrl:RefreshEnemyPosition()
	if self.template.enemyPos then
		self.template.enemyPos.template:SetTemplateVisibility(self.enemyPosVisible and not self.detectVisible)
	end
end

function EnemyHUDCtrl:OnCreateDangerHint()
	local showType = self.hintShowType

	if showType then
		self.template.dangerHint.template:SetTemplateVisibility(showType ~= 0)

		if showType ~= 0 then
			self.template.dangerHint.hintCtrl = showType - 1
		end
	else
		self.template.dangerHint.template:SetTemplateVisibility(false)
	end
end

function EnemyHUDCtrl:SystemUnlock(data)
	if data == LTConfig.SystemUnlockConfig.EnemyHp then
		self:RefreshHpVisible()
	elseif data == LTConfig.SystemUnlockConfig.EnemyDisarmBar then
		self:CheckShowDisarmBar()
	end
end

function EnemyHUDCtrl.OnRefreshLevel(cell)
	local self = cell.param

	if self.unit and self.template.hpBar then
		self.template.hpBar.levelText = self.unit.ClientData.Level
	end
end

function EnemyHUDCtrl.OnRefreshVisible(cell)
	local self = cell.param

	self:RefreshHpVisible()
end

function EnemyHUDCtrl.OnRefreshPartBar(cell)
	local self = cell.param
	local index = cell.index or -1
	local dataSet = self.unitDataSet
	local canShow = false
	local pid = self.unit.Pid
	local canShow = false

	if gShieldDefendMgr.CanShow[pid] and gShieldDefendMgr.CanShow[pid][index] == true then
		canShow = true
	end

	self:ShowPartShieldBar(index, canShow)
end

function EnemyHUDCtrl.OnShowDetectionEffect(cell)
	local self = cell.param
	local value = cell.value
	local unit = self.unit

	if not value then
		if self.template.detect then
			self.showDetect = false

			self:RefreshShowDetectRoot()
		end

		return
	end

	if not self.template.detect then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.StealthDetectValue, unit.Pid)
	else
		if self.unitDataSet.beAttracted then
			self.template.detect.attractedEffect.gameObject:SetActive(true)

			self.showAttractedEffect = true
		else
			self.template.detect.attractedEffect.gameObject:SetActive(false)

			self.showAttractedEffect = false
		end

		self:RefreshShowDetectRoot()
	end

	if not self.template.enemyPos then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyPosition, unit.Pid)
	end
end

function EnemyHUDCtrl.OnRefreshDetectionValue(cell)
	local self = cell.param
	local unit = self.unit

	if not self.template.detect then
		return
	end

	if self:IsHideState() then
		self.template.detect.detectCtrl = 3
		self.showDetect = false

		self:RefreshShowDetectRoot()
		gStealthManager:KillPerceivedEffect(unit.Pid)

		return
	end

	local value = cell.value or 0

	if self.detectTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.detectTimer)
	end

	local dataSet = self.unitDataSet

	if value == 0 or value == 100 then
		self.template.detect.debugText = ""
	else
		self.template.detect.debugText = gStealthManager.showEnemyViewNum and value or ""
	end

	if value == 0 then
		if self.showDetect then
			self.showDetect = false

			self:RefreshShowDetectRoot()
		end
	elseif value < 50 then
		if not self.showDetect then
			self.showDetect = true

			self:RefreshShowDetectRoot()
		end
	elseif value < 100 then
		if not self.showDetect then
			self.showDetect = true

			self:RefreshShowDetectRoot()
		end
	else
		if not self.showDetect then
			self.showDetect = true

			self:RefreshShowDetectRoot()
		end

		local this = self
		self.detectTimer = gLuaTimeMgrUtils.Delay(function ()
			this.showDetect = false

			this:RefreshShowDetectRoot()

			dataSet.detectionToMeValue = 0
			this.detectTimer = nil
		end, 0.7)
	end

	local fillValue = value / 100

	if self.detectTweenFill then
		self.detectTweenFill:Kill()
	end

	self.detectTweenFill = DOTween.To(function ()
		if self.template.detect then
			return self.template.detect.fillValue or 0
		end

		return 0
	end, function (v)
		if self.template.detect then
			self.template.detect.fillValue = v

			if v == 0 then
				self.template.detect.detectCtrl = 3
			elseif v < 0.5 then
				self.template.detect.detectCtrl = 0
			elseif v < 1 then
				self.template.detect.detectCtrl = 1
			else
				self.template.detect.detectCtrl = 2
			end
		end
	end, fillValue, 0.25):SetEase(Ease.Linear):OnKill(function ()
		self.detectTweenFill = nil
	end)
end

function EnemyHUDCtrl.OnRefreshIdleHint(cell)
	local self = cell.param
	local value = cell.value

	if not self.template.enemyPos then
		self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] = value and true or false

		return
	end

	self.enemyPosVisible = value

	self:RefreshEnemyPosition()
end

function EnemyHUDCtrl.OnShowAttractedEffect(cell)
	local self = cell.param
	local value = cell.value

	if value then
		self.showAttractedEffect = true

		self:RefreshShowDetectRoot()

		if self.template.detect and self.template.detect.attractedEffect then
			self.template.detect.attractedEffect.gameObject:SetActive(true)
		end
	else
		if self.template.detect and self.template.detect.attractedEffect then
			self.template.detect.attractedEffect.gameObject:SetActive(false)
		end

		self.showAttractedEffect = false

		self:RefreshShowDetectRoot()
	end
end

function EnemyHUDCtrl.OnShowDangerState(cell)
	local self = cell.param
	local showType = cell.value
	local unit = self.unit
	local unitDataSet = gDataSetManager:GetUnitData(unit.Pid)

	if unitDataSet.beingAssassinated then
		showType = 0
	end

	self.hintShowType = showType

	if not self.template.dangerHint then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.DangerHint, unit.Pid)
	elseif showType then
		self.template.dangerHint.template:SetTemplateVisibility(showType ~= 0)

		if showType ~= 0 then
			self.template.dangerHint.hintCtrl = showType - 1
		end
	else
		self.template.dangerHint.template:SetTemplateVisibility(false)
	end
end

function EnemyHUDCtrl.OnDead(cell)
	local self = cell.param
	self.showDetect = false
	self.showAttractedEffect = false

	if self.flashTweenFill then
		self.flashTweenFill:Kill()
	end

	if self.weakTweenFill then
		self.weakTweenFill:Kill()
	end

	self:RefreshShowDetectRoot()
	self:RefreshDangerIcon()
	gStealthManager:KillPerceivedEffect(self.unit.Pid)
end

function EnemyHUDCtrl:CustomClearProcedure()
	if self.flashTweenFill then
		self.flashTweenFill:Kill()
	end

	if self.weakTweenFill then
		self.weakTweenFill:Kill()
	end

	self.showDisarm = false
	self.showAttractedEffect = false
	self.showDetect = false
	self.hintShowType = 0
	self.OnSystemUnlockHandler = nil
	self.onMindIconEnemyChanged = nil
	self.isPveRaid = nil
	self.cfg = nil
end

function EnemyHUDCtrl:ClearEventListener()
	if self.onMindIconEnemyChanged then
		gMessageManager:RemoveMessageListener(gEventConstants.MIND_ICON_ENEMY_CHANGED, self.onMindIconEnemyChanged)
	end

	if self.OnSystemUnlockHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self.OnSystemUnlockHandler)
	end

	if self.onWeaponChange then
		gMessageManager:RemoveMessageListener(gEventConstants.WEAPON_CHANGED, self.onWeaponChange)
	end
end

return EnemyHUDCtrl
