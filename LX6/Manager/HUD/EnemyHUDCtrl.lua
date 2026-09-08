-- Original chunk: @Lua\LuaFiles\LX6\Manager\HUD\EnemyHUDCtrl.lua
-- Decompiled from: 02285_EnemyHUDCtrl.lua_36475acef365.luajit

local HUDCtrl = require("LX6/Manager/HUD/HudController")
local AgentConfig = LTConfig.AgentConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local StealthEnemyConfig = LTConfig.AgentDetectConfig
local AttributeNameConfig = LTConfig.AttributeNameConfig
local BuffConfig = LTConfig.BuffConfig
local HudInterfaceConfig = LTConfig.HudInterfaceConfig
local DOTween = DOTween
local Ease = DG.Tweening.Ease
local HUDManager = LX6.GUI.HUDNew.HUDManager
local DetectStealthState = UX.Game.EnemyDetectState
C_EnemyHUDCtrl = DefClass("C_EnemyHUDCtrl", C_EnemyHUDCtrl, HUDCtrl)

local ClampHpValue = function(value, max)
	if value > 0 or max < 0 then
		return 0
	end

	local x = value / max

	if x >= 0 then
		return 0
	elseif x <= 1 then
		return 1
	else
		return x
	end
end

local EnemyHUDCtrl = C_EnemyHUDCtrl

EnemyHUDCtrl.ctor = function(self)
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
	self.allyHpVisible = false
	self.detectVisible = false
	self.enemyPosVisible = false
	self.buffUIList = {}
	self.buffItemStores = {}
	self.buffTweens = {}
end

EnemyHUDCtrl.RegisterBindHandlers = function(self)
	EnemyHUDCtrl.base.RegisterBindHandlers(self)

	if not self.unitDataSet then
		print_error("EnemyHUD对应unit数据不存在!", self.uniId)

		return
	end

	if not self.cfg then
		print_error("EnemyConfig数据不存在或非同帧内使用cfg数据！", self.uniId, self.unit.ClientData.SubType)

		return
	end

	if self.cfg.DetectId == 0 then
		local stealthEnemyCfg = StealthEnemyConfig.GetConfig(self.cfg.DetectId)

		if stealthEnemyCfg and stealthEnemyCfg.EnterVisionRange and stealthEnemyCfg.EnterVisionRange.DetectRadius == 0 then
			if self.unitDataSet.detectionValue ~= nil then
				self.unitDataSet.detectionValue = 0
			end

			if self.unitDataSet.detectionState ~= nil then
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

	local needBind = self.cfg.ShowHPBarUnderAttack or self.cfg.ShowHPBar or L18.Gameplay.PoliceJobManager.Instance:IsUnitIsFakePersonByUnit(self.unit)
	self.isMinion = self.unit.ClientData.Type ~= UX.Game.EntityType.Player

	if self.isPveRaid and self.isMinion then
		needBind = false
	end

	if needBind then
		self.eventSet:BindHandler2({
			self.unitDataSet,
			"[\\xb5\\x8b\\x82E",
			self.unitDataSet,
			"\\xf5\\x9f\\xe05\\xd0\\xf9\\x81\\xec\\x80,-",
			self.unitDataSet,
			"n\\xbd&\\xdfi!\\xbfO/28P\\xb5\\xea$\\xda\\xec",
			self.unitDataSet,
			"}\\xef\\xf9/1\\xcae%\\xfbJ\\x81\t`\\xc7\\xf4",
			self.unitDataSet,
			"fe\\x8beM\\xb0\\xd0^GspH"
		}, self.OnRefreshVisible, self)
		self.eventSet:BindHandler2({
			self.unitDataSet,
			"[\\xb5\\x8b\\x82E",
			self.unitDataSet,
			"\\xf5\\x9f\\xe05\\xd0\\xf9\\x81\\xec\\x80,-",
			self.unitDataSet,
			"n\\xbd&\\xdfi!\\xbfO/28P\\xb5\\xea$\\xda\\xec",
			self.unitDataSet,
			"}\\xef\\xf9/1\\xcae%\\xfbJ\\x81\t`\\xc7\\xf4",
			self.unitDataSet,
			"fe\\x8beM\\xb0\\xd0^GspH"
		}, self.OnRefreshAllyHpVisible, self)
	end

	self.eventSet:BindHandler(self.unitDataSet, "level", self.OnRefreshLevel, self)
	self.eventSet:BindHandler(self.unitDataSet, "showPartBarUnderAttack", self.OnRefreshPartBar, self)
	self.eventSet:BindHandler(self.unitDataSet, "isDead", self.OnDead, self)
	self.eventSet:BindHandler(gBattleMgr.dataSet, "showEnemyHp", self.OnRefreshVisible, self)
	self.eventSet:BindHandler(gBattleMgr.dataSet, "showEnemyHp", self.OnRefreshAllyHpVisible, self)
end

EnemyHUDCtrl.RegisterEventListener = function(self)
	self.OnSystemUnlockHandler = function(event, data)
		self:SystemUnlock(data)
	end

	self.onMindIconEnemyChanged = function()
		self:RefreshHpVisible()
	end

	self.onWeaponChange = function(eventId, data)
		self:RefreshWeakRate(eventId, data)
	end

	self.onBuffChange = function(...)
		self:OnRefreshBuffs(...)
	end

	self.onMaxPoiseValueChange = function(eventId, value)
		if value >= 0 then
			self:SetDisarmDebuff(gHudMgr.DisarmDebuffType.PoXing)
		else
			self:SetDisarmDebuff(gHudMgr.DisarmDebuffType.None)
		end

		self:DisarmChanged()
	end

	gMessageManager:AddMessageListener(gEventConstants.REFRESH_HEADVIEW_BUFFS, self.onBuffChange)
	gMessageManager:AddMessageListener(gEventConstants.MIND_ICON_ENEMY_CHANGED, self.onMindIconEnemyChanged)
	gMessageManager:AddMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self.OnSystemUnlockHandler)
	gMessageManager:AddMessageListener(gEventConstants.WEAPON_CHANGED, self.onWeaponChange)
	gMessageManager:AddMessageListener(gEventConstants.ATTRIBUTE_CHANGED_MAXPOISEVALUE, self.onMaxPoiseValueChange)
end

EnemyHUDCtrl.RefreshData = function(self)
	local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	self.isPveRaid = raidTypeConfig.Type ~= RaidRaidTypeConfig.TypeType.SoloPve or raidTypeConfig.Type ~= RaidRaidTypeConfig.TypeType.TeamPve or raidTypeConfig.Type ~= RaidRaidTypeConfig.TypeType.JvQing
	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
	local cfg = AgentConfig.GetConfig(agentId)
	self.cfg = cfg
	self.maxDisarmValue = clientData.InitialMaxPoiseValue <= 0 and clientData.InitialMaxPoiseValue or clientData.MaxPoiseValue
end

EnemyHUDCtrl.CustomProcedure = function(self)
	local camp = self.unit.ClientData.Camp

	if camp ~= 6 or camp ~= 7 then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.BVB, self.unit.Pid)
	end

	self.disarmTween = nil
	self.disarmLoopDelayId = nil
end

EnemyHUDCtrl.OnCreateEnemyHpBar = function(self)
	local hpBar = self.template.hpBar
	local ani = hpBar.anim
	local clip = ani:GetClip("S_vx_EmenyHpTemplate_close")

	clip:SampleAnimation(ani.gameObject, 0)
	ani:Stop("S_vx_EmenyHpTemplate_close")
	self:HpChanged()
	self:RefreshHpVisible()

	hpBar.levelText = self.unit.ClientData.Level

	hpBar.levelNode:SetLocalScale(self:ShowLevelText() and 1 or 0)

	local hpThreshold = AttributeNameConfig.HPLengthThreshold
	local disarmThreshold = AttributeNameConfig.PoiseLengthThreshold
	local hpMax = self.unit.ClientData.MaxHp

	if hpMax >= hpThreshold.para1 then
		hpBar.hpTypeCtrl = 2
	elseif hpThreshold.para1 < hpMax and hpMax >= hpThreshold.para2 then
		hpBar.hpTypeCtrl = 1
	else
		hpBar.hpTypeCtrl = 0
	end

	if self.maxDisarmValue >= disarmThreshold.para1 then
		hpBar.disarmTypeCtrl = 2
	elseif disarmThreshold.para1 < self.maxDisarmValue and self.maxDisarmValue >= disarmThreshold.para2 then
		hpBar.disarmTypeCtrl = 1
	else
		hpBar.disarmTypeCtrl = 0
	end

	local isDanger = gBattleMgr:CalcEnemyDangerValue(self.unit.Pid)
	hpBar.dangerCtrl = isDanger and 1 or 0
	hpBar.disarmDebuffTypeCtrl = gHudMgr.DisarmDebuffType.None

	hpBar.buffList.luaSimpleRenderItem = function(btn, index)
		self:OnRenderBuffItem(btn, index)
	end
end

EnemyHUDCtrl.ShowHpBar = function(self, visible)
	if self.unitDataSet and self.unitDataSet.isDead and self.template.hpBar then
		local ani = self.template.hpBar.anim

		ani.Play(ani, "S_vx_EmenyHpTemplate_close")

		local clip = ani.GetClip(ani, "S_vx_EmenyHpTemplate_close")

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
		self.CheckShowDisarmBar(self)
	end

	self:SetIgnoreDistance(visible, gHudMgr.HUDTemplateType.EnemyHpBar)
	self.template.hpBar.template:SetTemplateVisibility(visible)

	self.hpVisible = visible

	self.template.hpBar.hpNode:SetLocalScale(gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.EnemyHp) and 1 or 0)
end

EnemyHUDCtrl.HpChanged = function(self)
	if self.template.hpBar then
		self.EnemyHpBarHpChanged(self)
	end

	if self.template.allyHpBar then
		self.AllyHpBarHpChanged(self)
	end
end

EnemyHUDCtrl.AllyHpBarHpChanged = function(self)
	local allyHpBar = self.template.allyHpBar
	local unit = self.unit
	local hp = unit.ClientData.Hp + unit.ClientData.Shield

	if hp >= 0 then
		hp = 0
	end

	local sum = unit.ClientData.Hp + unit.ClientData.Shield

	if sum > 0 then
		sum = Mathf.Max(unit.ClientData.MaxHp, sum)
		allyHpBar.value = ClampHpValue(hp, sum)
	end
end

EnemyHUDCtrl.EnemyHpBarHpChanged = function(self)
	local hpBar = self.template.hpBar
	local unit = self.unit
	local hp1 = unit.ClientData.Hp + unit.ClientData.Shield

	if hp1 >= 0 then
		hp1 = 0
	end

	local sum = unit.ClientData.Hp + unit.ClientData.Shield

	if sum > 0 then
		sum = Mathf.Max(unit.ClientData.MaxHp, sum)
		local oldHpValue = hpBar.hpBar.value
		local newHpValue = ClampHpValue(hp1, sum)

		if oldHpValue < newHpValue then
			hpBar.hpBar.value = newHpValue
			hpBar.weakHpBar.fillAmount = newHpValue
			hpBar.flashBar.fillAmount = newHpValue
			hpBar.dangerBar.fillAmount = newHpValue
		else
			if self.flashTweenFill then
				self.flashTweenFill:Kill()
			end

			if self.weakTweenFill then
				self.weakTweenFill:Kill()
			end

			hpBar.flashBar.renderOpacity = 1
			slot7 = DOTween.To(function ()
				return self.template.hpBar.flashBar.renderOpacity
			end, function (value)
				if self.template.hpBar then
					self.template.hpBar.flashBar.renderOpacity = value
				end
			end, 0, 0.1)
			slot7 = slot7:SetEase(Ease.Linear)
			self.flashTweenFill = slot7:OnKill(function ()
				self.flashTweenFill = nil
			end)

			gLuaTimeMgrUtils.NotDestroyDelay(function ()
				if self.template.hpBar and not self.unit.IsDead then
					local duration = (self.template.hpBar.weakHpBar.fillAmount - newHpValue) * 100 / GameConfig.WeakHpDecreaseSpeed
					self.template.hpBar.flashBar.fillAmount = newHpValue
					slot2 = DOTween.To(function ()
						return self.template.hpBar.weakHpBar.fillAmount
					end, function (value)
						if self.template.hpBar then
							self.template.hpBar.weakHpBar.fillAmount = value
						end
					end, newHpValue, duration)
					slot2 = slot2:SetEase(Ease.Linear)
					self.weakTweenFill = slot2:OnKill(function ()
						self.weakTweenFill = nil
					end)
				end
			end, 0.1)

			hpBar.hpBar.value = newHpValue
			hpBar.dangerBar.fillAmount = newHpValue
		end
	end
end

EnemyHUDCtrl.SetHpDebuff = function(self, debuffType)
	if not self.template.hpBar then
		return
	end

	self.template.hpBar.hpDebuffTypeCtrl = debuffType
end

EnemyHUDCtrl.SetDisarmDebuff = function(self, debuffType)
	if not self.template.hpBar then
		return
	end

	self.template.hpBar.disarmDebuffTypeCtrl = debuffType

	if debuffType ~= gHudMgr.DisarmDebuffType.PoXing then
		self.template.hpBar.debuffBar.value = (self.unit.ClientData.InitialMaxPoiseValue - self.unit.ClientData.MaxPoiseValue) / self.unit.ClientData.InitialMaxPoiseValue
	end
end

EnemyHUDCtrl.SetDisarmBarFill = function(self, value)
	if not self.template.hpBar then
		return
	end

	self.template.hpBar.disarmBarFill = value

	self.OnDisarmBarFillChanged(self, value)
end

EnemyHUDCtrl.OnDisarmBarFillChanged = function(self, value)
	if self.template.hpBar.disarmDebuffTypeCtrl ~= gHudMgr.DisarmDebuffType.DuanYi then
		self.template.hpBar.debuffBar.value = value
	end
end

EnemyHUDCtrl.CheckShowDisarmBar = function(self)
	local clientData = self.unit.ClientData
	self.maxDisarmValue = clientData.InitialMaxPoiseValue <= 0 and clientData.InitialMaxPoiseValue or clientData.MaxPoiseValue
	local needShow = self.maxDisarmValue <= 0 and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.EnemyDisarmBar)

	if self.showDisarm ~= needShow and self.template.hpBar.disarmNode.gameObject.activeSelf ~= needShow then
		return
	end

	self.showDisarm = needShow

	self.template.hpBar.disarmNode.gameObject:SetActive(needShow)
	self:DisarmChanged()
end

EnemyHUDCtrl.DisarmChanged = function(self)
	local hpBar = self.template.hpBar

	if not self.showDisarm or not hpBar then
		return
	end

	local disarmRate = self.unit.ClientData.DisarmRate
	local currentMaxPoise = self.unit.ClientData.MaxPoiseValue
	local initialMaxPoise = self.unit.ClientData.InitialMaxPoiseValue

	if not initialMaxPoise or initialMaxPoise < 0 then
		initialMaxPoise = currentMaxPoise
	end

	local fillAmount = disarmRate * currentMaxPoise / initialMaxPoise

	if fillAmount <= 1 then
		fillAmount = 1
	end

	local oldHpValue = hpBar.disarmBarFill or fillAmount
	local maxValue = self.maxDisarmValue

	if hpBar.disarmBarFill ~= fillAmount then
		return
	end

	local ani = hpBar.disarmAnim
	local clip = ani.GetClip(ani, "S_vx_EmenyHpTemplate_DisarmBar_open")

	if oldHpValue > 0 and oldHpValue >= 1 and disarmRate > 1 then
		ani.Stop(ani)
		ani.Play(ani, "S_vx_EmenyHpTemplate_DisarmBar_open")

		if self.disarmLoopDelayId then
			gLuaTimeMgrUtils.CancelUnitDelay(self.disarmLoopDelayId)
		end

		self.disarmLoopDelayId = gLuaTimeMgrUtils.Delay(function ()
			self.disarmLoopDelayId = nil

			if not self.template.hpBar then
				return
			end

			ani:Play("S_vx_EmenyHpTemplate_DisarmBar_loop")
		end, clip.length)

		if not gLinkManager:CheckInLinkMode() and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.WeakPercent) then
			hpBar.weakDetailCtrl = 1
			local rate = gBattleMgr:GetEnemyPoiseWeaponChangeInfo(self.unit.Pid, gCS.WeaponMgr.GetCurrentWeaponInstanceId())
			rate = rate ~= 0 and "100%" or math.floor(rate * 100) .. "%"
			hpBar.weakRateText = rate
		end

		if self.disarmTween then
			self.disarmTween:Kill()

			self.disarmTween = nil
		end

		self:SetDisarmBarFill(fillAmount)

		hpBar.disarmVxBarFill = fillAmount
		slot10 = DOTween.To(function ()
			if self.template.hpBar then
				return self.template.hpBar.disarmBarFill
			end

			return 0
		end, function (v)
			if self.template.hpBar then
				self:SetDisarmBarFill(v)

				self.template.hpBar.disarmVxBarFill = v
			end
		end, 0.001, gCS.BattleManager.GetRecoverTime(self.unit.Pid))
		slot10 = slot10:SetEase(Ease.Linear)
		self.disarmTween = slot10:OnKill(function ()
			self.disarmTween = nil
		end)
	else
		local disarmClip = ani.GetClip(ani, "S_vx_EmenyHpTemplate_IconBG")

		if (fillAmount - oldHpValue) * maxValue <= 0 then
			disarmClip.SampleAnimation(disarmClip, ani.gameObject, 0)
			ani.Stop(ani)
			ani.Play(ani, "S_vx_EmenyHpTemplate_IconBG")
		else
			disarmClip.SampleAnimation(disarmClip, ani.gameObject, 0)
			clip.SampleAnimation(clip, ani.gameObject, 0)
			ani.Stop(ani)

			if self.disarmLoopDelayId then
				gLuaTimeMgrUtils.CancelUnitDelay(self.disarmLoopDelayId)

				self.disarmLoopDelayId = nil
			end

			if self.disarmTween then
				self.disarmTween:Kill()

				self.disarmTween = nil
			end

			hpBar.weakDetailCtrl = 0
		end

		self.SetDisarmBarFill(self, fillAmount)

		hpBar.disarmVxBarFill = fillAmount
	end
end

EnemyHUDCtrl.RefreshWeakRate = function(self, eventId, data)
	if not self.template.hpBar then
		return
	end

	if self.template.hpBar.weakDetailCtrl == 1 then
		return
	end

	if not gCS.MyPlayerManager.PlayerUnit or gCS.MyPlayerManager.PlayerUnit.Pid == data.pid then
		return
	end

	if gLinkManager:CheckInLinkMode() then
		return
	end

	local rate = gBattleMgr:GetEnemyPoiseWeaponChangeInfo(self.unit.Pid, gCS.WeaponMgr.GetCurrentWeaponInstanceId())
	rate = rate ~= 0 and "100%" or math.floor(rate * 100) .. "%"
	self.template.hpBar.weakRateText = rate
end

EnemyHUDCtrl.RefreshHpVisible = function(self)
	if not self.template.hpBar then
		return
	end

	local dataSet = self.unitDataSet
	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
	local cfg = AgentConfig.GetConfig(agentId)
	self.cfg = cfg
	local canShowHp = self.cfg.ShowHPBar

	if canShowHp and self.cfg.ShowHPBarUnderAttack or L18.Gameplay.PoliceJobManager.Instance:IsUnitIsFakePersonByUnit(self.unit) then
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

	local shouldShowHp = not dataSet.isDead and not dataSet.isBuffHideNameBar and not dataSet.realInVisiable and not dataSet.isGrabByMind and not gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.NearDeath) and not gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.HideHp) and gBattleMgr.dataSet.showEnemyHp
	local showHp = canShowHp and shouldShowHp

	self:ShowHpBar(showHp)
end

EnemyHUDCtrl.ShowLevelText = function(self)
	if gUIUtils:IsInXinShouRaid() then
		return false
	end

	if gUIUtils:IsInShowEnemyLevelRaid() then
		return true
	end

	return false
end

EnemyHUDCtrl.DestroyHpBar = function(self)
	if self.template.hpBar then
		if self.flashTweenFill then
			self.flashTweenFill:Kill()

			self.flashTweenFill = nil
		end

		if self.weakTweenFill then
			self.weakTweenFill:Kill()

			self.weakTweenFill = nil
		end

		self.KillAllBuffTweens(self)

		local instanceId = self.template.hpBar.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end

	if self.template.allyHpBar then
		local instanceId = self.template.allyHpBar.wgtId

		self.RemoveHudTemplate(self, instanceId)
	end
end

EnemyHUDCtrl.OnCreatAllyHpBar = function(self)
	local allyHpBar = self.template.allyHpBar
	local ani = allyHpBar.anim
	local clip = ani.GetClip(ani, "S_vx_EmenyHpTemplate_close")

	clip.SampleAnimation(clip, ani.gameObject, 0)
	ani.Stop(ani, "S_vx_EmenyHpTemplate_close")
	self.AllyHpBarHpChanged(self)
	self.RefreshAllyHpVisible(self)
end

EnemyHUDCtrl.ShowAllyHpBar = function(self, visible)
	if self.unitDataSet and self.unitDataSet.isDead and self.template.allyHpBar then
		local ani = self.template.allyHpBar.anim

		ani.Play(ani, "S_vx_EmenyHpTemplate_close")

		local clip = ani.GetClip(ani, "S_vx_EmenyHpTemplate_close")

		gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if gCS.LuaUtils.IsNull(ani) or not self.template.allyHpBar then
				return
			end

			clip:SampleAnimation(ani.gameObject, 0)
			ani:Stop("S_vx_EmenyHpTemplate_close")
			self.template.allyHpBar.template:SetTemplateVisibility(false)

			self.allyHpVisible = false
		end, clip.length)

		return
	end

	self:SetIgnoreDistance(visible, gHudMgr.HUDTemplateType.AllyHpBar)
	self.template.allyHpBar.template:SetTemplateVisibility(visible)

	self.allyHpVisible = visible
end

EnemyHUDCtrl.RefreshAllyHpVisible = function(self)
	if not self.template.allyHpBar then
		return
	end

	local dataSet = self.unitDataSet
	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
	local cfg = AgentConfig.GetConfig(agentId)
	self.cfg = cfg
	local canShowHp = self.cfg.ShowHPBar

	if canShowHp and self.cfg.ShowHPBarUnderAttack or L18.Gameplay.PoliceJobManager.Instance:IsUnitIsFakePersonByUnit(self.unit) then
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

	local shouldShowHp = not dataSet.isDead and not dataSet.isBuffHideNameBar and not dataSet.realInVisiable and not dataSet.isGrabByMind and not gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.NearDeath) and not gCS.UnitStateMgr:HasState(self.unit, UnitStateConfig.HideHp) and gBattleMgr.dataSet.showEnemyHp
	local showHp = canShowHp and shouldShowHp

	self:ShowAllyHpBar(showHp)
end

EnemyHUDCtrl.SetForceHideHp = function(self, force)
	self.forceHideHp = force

	self.RefreshHpVisible(self)
	self.RefreshAllyHpVisible(self)
end

EnemyHUDCtrl.FrequencyShieldChanged = function(self, index)
	if not self.template.hpBar then
		return
	end

	local unit = self.unit
	local shieldValue = gCS.BattleManager.GetPartShieldValue(unit, index)

	if shieldValue <= 0 then
		self.template.hpBar.shieldTypeCtrl = 1
		self.template.hpBar.shieldCountText = shieldValue
	else
		self.template.hpBar.shieldTypeCtrl = 0
	end
end

EnemyHUDCtrl.WholeBodyShieldChanged = function(self)
	if not self.template.hpBar then
		return
	end

	local unit = self.unit
	local shieldValue, shieldMaxValue = gCS.ShieldManager:GetWholeBodyShieldValue(unit.Pid, 0, 0)

	if shieldValue <= 0 then
		self.template.hpBar.shieldTypeCtrl = 2
		self.template.hpBar.wholeShieldFill = shieldValue / shieldMaxValue
		self.template.hpBar.wholeShieldWeakFill = shieldValue / shieldMaxValue
	else
		self.template.hpBar.shieldTypeCtrl = 0
		self.template.hpBar.wholeShieldFill = 0
		self.template.hpBar.wholeShieldWeakFill = 0
	end
end

EnemyHUDCtrl.OnRefreshBuffs = function(self, eventId, pid)
	if not self.template.hpBar then
		return
	end

	if pid == self.unit.Pid then
		return
	end

	local allBuffs = gBuffUtils.GetCSBuffList(pid)

	if #allBuffs ~= 0 then
		self.template.hpBar.buffList:SetSimpleList(0)

		self.template.hpBar.hasBuffCtrl = 0

		self:KillAllBuffTweens()

		return
	end

	local max_count = HudInterfaceConfig.minionBuffMaxNumber
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

	local showBuffs = {}

	if max_count >= #priorityBuffs then
		for i = #priorityBuffs - max_count + 1, #priorityBuffs do
			table.insert(showBuffs, priorityBuffs[i])
		end
	else
		for i = 1, #priorityBuffs do
			table.insert(showBuffs, priorityBuffs[i])
		end

		local remainCount = max_count - #priorityBuffs

		if remainCount <= 0 and #normalBuffs <= 0 then
			local startIdx = math.max(#normalBuffs - remainCount + 1, 1)

			for i = startIdx, #normalBuffs do
				table.insert(showBuffs, normalBuffs[i])
			end
		end
	end

	if #showBuffs ~= 0 then
		self.template.hpBar.buffList:SetSimpleList(0)

		self.template.hpBar.hasBuffCtrl = 0

		self:KillAllBuffTweens()

		return
	end

	local clientData = self.unit.ClientData
	local agentId = clientData.AgentId <= 0 and clientData.AgentId or clientData.SubType
	local agentCfg = AgentConfig.GetConfig(agentId)
	local isEliteType = agentCfg and agentCfg.EnemyClassType ~= 7
	self.buffUIList = {}

	for i = 1, #showBuffs do
		local buff = showBuffs[i]
		local cfg = BuffConfig.GetConfig(buff.Id)
		local tier = ""
		local fillAmount = 1

		if isEliteType then
			if buff.Tier and buff.Tier <= 1 then
				tier = buff.Tier
			end

			local expireTime = math.max(buff.ExpireTime - gCS.TimeManager.ServerUnixTime, 0)
			fillAmount = cfg.Duration <= 0 and math.min(expireTime / cfg.Duration, 1) or 1
		end

		table.insert(self.buffUIList, {
			iconId = cfg.IconIdSGUI,
			expireTime = buff.ExpireTime,
			duration = cfg.Duration,
			fillAmount = fillAmount,
			tier = tier,
			cfg = cfg,
			isEliteType = isEliteType
		})
	end

	self:KillAllBuffTweens()
	table.clear(self.buffItemStores)
	self.template.hpBar.buffList:SetSimpleList(#self.buffUIList)

	self.template.hpBar.hasBuffCtrl = 1

	if isEliteType then
		self.StartBuffFillTweens(self)
	end
end

EnemyHUDCtrl.OnRenderBuffItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.buffUIList[index + 1]

	if not data then
		return
	end

	self.buffItemStores[index + 1] = store
	store.iconId = data.iconId

	if data.isEliteType then
		store.fillAmount = data.fillAmount
		store.tier = data.tier
		store.countDownCtrl = 1
		store.countNumbersCtrl = 0
	else
		store.fillAmount = 1
		store.tier = ""
		store.countDownCtrl = 0
		store.countNumbersCtrl = 1
	end
end

EnemyHUDCtrl.StartBuffFillTweens = function(self)
	for i = 1, #self.buffUIList do
		local data = self.buffUIList[i]

		if data.duration <= 0 then
			local remaining = math.max(data.expireTime - gCS.TimeManager.ServerUnixTime, 0)

			if remaining <= 0 then
				local idx = i
				slot8 = DOTween.To(function ()
					return data.fillAmount
				end, function (value)
					data.fillAmount = value
					local store = self.buffItemStores[idx]

					if store then
						store.fillAmount = value
					end
				end, 0, remaining)
				slot8 = slot8:SetEase(Ease.Linear)
				local tween = slot8:OnKill(function ()
					self.buffTweens[idx] = nil
				end)
				self.buffTweens[idx] = tween
			end
		end
	end
end

EnemyHUDCtrl.KillAllBuffTweens = function(self)
	for i, tween in pairs(self.buffTweens) do
		if tween then
			tween.Kill(tween)
		end
	end

	table.clear(self.buffTweens)
end

EnemyHUDCtrl.OnCreateEnemyPartShieldBar = function(self, index)
	self.ShowPartShieldBar(self, index, true)
	self.PartShieldChanged(self, index)
end

EnemyHUDCtrl.PartShieldChanged = function(self, index)
	local unit = self.unit
	local partShieldValue = gCS.BattleManager.GetPartShieldValue(unit, index)
	local maxPartShieldValue = gCS.BattleManager.GetMaxPartShieldValue(unit, index)
	local partBar = self.templatesGroup.partBar
	local partBarIdx = partBar and partBar[index]

	if (partBar ~= nil or partBarIdx ~= nil) and partShieldValue == nil and partShieldValue <= 0 and maxPartShieldValue == nil and maxPartShieldValue <= 0 then
		self:OnPartShieldBar(true, false, index)

		partBar = self.templatesGroup.partBar
		partBarIdx = partBar and partBar[index]

		if partBarIdx then
			local bar = partBarIdx.shieldBar
			local weakBar = partBarIdx.shieldWeakBar
			bar.fillAmount = Mathf.Max(4 / bar.GetTargetWidth(bar), ClampHpValue(partShieldValue, maxPartShieldValue))
			weakBar.fillAmount = bar.fillAmount
		end
	elseif partBarIdx then
		if partShieldValue ~= nil or partShieldValue > 0 or maxPartShieldValue ~= nil or maxPartShieldValue < 0 then
			self.OnPartShieldBar(self, false, false, index)
		else
			local bar = partBarIdx.shieldBar
			local weakBar = partBarIdx.shieldWeakBar
			bar.fillAmount = Mathf.Max(4 / bar.GetTargetWidth(bar), ClampHpValue(partShieldValue, maxPartShieldValue))
			weakBar.fillAmount = bar.fillAmount

			self.OnPartShieldBar(self, true, true, index)
		end
	end
end

EnemyHUDCtrl.OnPartShieldBar = function(self, show, needCheckVisible, index)
	local unit = self.unit

	if self.IsHpBarNeverShow(self) then
		return
	end

	if show then
		if self.templatesGroup.partBar ~= nil or self.templatesGroup.partBar[index] ~= nil then
			HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyPartShieldBar, unit.Pid, tostring(index))
		end
	elseif self.templatesGroup.partBar[index] then
		local instanceId = self.templatesGroup.partBar[index].wgtId

		self.RemoveHudTemplate(self, instanceId)
	end

	if needCheckVisible then
		self.UpdateEnemyPartShieldBarVisible(self, index)
	end
end

EnemyHUDCtrl.UpdateEnemyPartShieldBarVisible = function(self, index)
	local unit = self.unit

	if unit.ClientData.Type ~= UX.Game.EntityType.Enemy and self.templatesGroup.partBar and self.templatesGroup.partBar[index] then
		local canShow = false

		if gShieldDefendMgr.CanShow[unit.Pid] and gShieldDefendMgr.CanShow[unit.Pid][tonumber(index)] ~= true then
			canShow = true
		end

		self.ShowPartShieldBar(self, index, canShow)
	end
end

EnemyHUDCtrl.ShowPartShieldBar = function(self, index, visible, recursionEnd)
	if not self.templatesGroup.partBar or not self.templatesGroup.partBar[index] then
		return
	end

	local unit = self.unit

	if tonumber(index) <= 0 then
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
	end, 3, nil, , true)
end

EnemyHUDCtrl.SetHpHideByBarrier = function(self, enable)
	if not self.template.hpBar then
		return
	end

	self.template.hpBar.template.SetHideByBarrier = enable
end

EnemyHUDCtrl.OnCreateBVBTemplate = function(self)
	local camp = self.unit.ClientData.Camp

	if not self.template.BVB then
		return
	end

	if camp ~= 6 then
		self.template.BVB.playerCtrl = 0
	elseif camp ~= 7 then
		self.template.BVB.playerCtrl = 1
	end
end

EnemyHUDCtrl.OnCreateStealthDetectValue = function(self)
	if self.unitDataSet.beAttracted then
		self.template.detect.attractedEffect.gameObject:SetActive(true)

		self.showAttractedEffect = true
	else
		self.template.detect.attractedEffect.gameObject:SetActive(false)

		self.showAttractedEffect = false
	end

	self.RefreshShowDetectRoot(self)

	self.template.detect.fillValue = 0
end

EnemyHUDCtrl.RefreshShowDetectRoot = function(self)
	if self.template.detect and gClientUtils.NotNil(self.template.detect.template) then
		self.template.detect.template:SetTemplateVisibility(self.showAttractedEffect or self.showDetect)

		self.detectVisible = self.showAttractedEffect or self.showDetect

		self:SetIgnoreDistance(self.detectVisible, gHudMgr.HUDTemplateType.StealthDetectValue)
		self:SetEnableOffscreen(self.detectVisible, gHudMgr.HUDTemplateType.StealthDetectValue)
	end
end

EnemyHUDCtrl.OnCreateEnemyPosition = function(self)
	if self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] == nil then
		self.enemyPosVisible = self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition]

		self.RefreshEnemyPosition(self)

		self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] = nil
	end
end

EnemyHUDCtrl.RefreshEnemyPosition = function(self)
	if self.template.enemyPos then
		self.template.enemyPos.template:SetTemplateVisibility(self.enemyPosVisible and not self.detectVisible)
	end
end

EnemyHUDCtrl.OnCreateDangerHint = function(self)
	local showType = self.hintShowType

	if showType then
		self.template.dangerHint.template:SetTemplateVisibility(showType == 0)

		if showType == 0 then
			self.template.dangerHint.hintCtrl = showType - 1
		end
	else
		self.template.dangerHint.template:SetTemplateVisibility(false)
	end
end

EnemyHUDCtrl.SystemUnlock = function(self, data)
	if data ~= LTConfig.SystemUnlockConfig.EnemyHp then
		self.RefreshHpVisible(self)
	elseif data ~= LTConfig.SystemUnlockConfig.EnemyDisarmBar then
		self.CheckShowDisarmBar(self)
	end
end

EnemyHUDCtrl.OnRefreshLevel = function(cell)
	local self = cell.param

	if self.unit and self.template.hpBar then
		self.template.hpBar.levelText = self.unit.ClientData.Level
	end
end

EnemyHUDCtrl.OnRefreshVisible = function(cell)
	local self = cell.param

	self.RefreshHpVisible(self)
end

EnemyHUDCtrl.OnRefreshAllyHpVisible = function(cell)
	local self = cell.param

	self.RefreshAllyHpVisible(self)
end

EnemyHUDCtrl.OnRefreshPartBar = function(cell)
	local self = cell.param
	local index = cell.index or -1
	local dataSet = self.unitDataSet
	local canShow = false
	local pid = self.unit.Pid

	if gShieldDefendMgr.CanShow[pid] and gShieldDefendMgr.CanShow[pid][index] ~= true then
		canShow = true
	end

	self.ShowPartShieldBar(self, index, canShow)
end

EnemyHUDCtrl.OnShowDetectionEffect = function(cell)
	local self = cell.param
	local value = cell.value
	local unit = self.unit

	if not value then
		if self.template.detect then
			self.showDetect = false

			self.RefreshShowDetectRoot(self)
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

		self.RefreshShowDetectRoot(self)
	end

	if not self.template.enemyPos then
		HUDManager.AddHUDTemplate(gHudMgr.HUDTemplateType.EnemyPosition, unit.Pid)
	end
end

EnemyHUDCtrl.OnRefreshDetectionValue = function(cell)
	local self = cell.param
	local unit = self.unit

	if not self.template.detect then
		return
	end

	if self.IsHideState(self) then
		self.template.detect.detectCtrl = 3
		self.showDetect = false

		self.RefreshShowDetectRoot(self)

		if self.detectTweenFill then
			self.detectTweenFill:Kill()

			self.detectTweenFill = nil
		end

		if self.detectTimer then
			gLuaTimeMgrUtils.CancelUnitDelay(self.detectTimer)

			self.detectTimer = nil
		end

		return
	end

	local value = cell.value or 0

	if self.detectTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self.detectTimer)
	end

	local dataSet = self.unitDataSet

	if value ~= 0 or value ~= 100 then
		self.template.detect.debugText = ""
	else
		self.template.detect.debugText = ""
	end

	if value ~= 0 then
		if self.showDetect then
			self.showDetect = false

			self.RefreshShowDetectRoot(self)
		end
	elseif value >= 50 then
		if not self.showDetect then
			self.showDetect = true

			self.RefreshShowDetectRoot(self)
		end
	elseif value >= 100 then
		if not self.showDetect then
			self.showDetect = true

			self.RefreshShowDetectRoot(self)
		end
	else
		if not self.showDetect then
			self.showDetect = true

			self.RefreshShowDetectRoot(self)
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

	slot6 = DOTween.To(function ()
		if self.template.detect then
			return self.template.detect.fillValue or 0
		end

		return 0
	end, function (v)
		if self.template.detect then
			self.template.detect.fillValue = v

			if v ~= 0 then
				self.template.detect.detectCtrl = 3
			elseif v >= 0.5 then
				self.template.detect.detectCtrl = 0
			elseif v >= 1 then
				self.template.detect.detectCtrl = 1
			else
				self.template.detect.detectCtrl = 2
			end
		end
	end, fillValue, 0.25)
	slot6 = slot6:SetEase(Ease.Linear)
	self.detectTweenFill = slot6:OnKill(function ()
		self.detectTweenFill = nil
	end)
end

EnemyHUDCtrl.OnRefreshIdleHint = function(cell)
	local self = cell.param
	local value = cell.value

	if not self.template.enemyPos then
		self.asyncParamsSave[gHudMgr.HUDTemplateType.EnemyPosition] = value and true or false

		return
	end

	self.enemyPosVisible = value

	self.RefreshEnemyPosition(self)
end

EnemyHUDCtrl.OnShowAttractedEffect = function(cell)
	local self = cell.param
	local value = cell.value

	if value then
		self.showAttractedEffect = true

		self.RefreshShowDetectRoot(self)

		if self.template.detect and self.template.detect.attractedEffect then
			self.template.detect.attractedEffect.gameObject:SetActive(true)
		end
	else
		if self.template.detect and self.template.detect.attractedEffect then
			self.template.detect.attractedEffect.gameObject:SetActive(false)
		end

		self.showAttractedEffect = false

		self.RefreshShowDetectRoot(self)
	end
end

EnemyHUDCtrl.OnShowDangerState = function(cell)
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
		self.template.dangerHint.template:SetTemplateVisibility(showType == 0)

		if showType == 0 then
			self.template.dangerHint.hintCtrl = showType - 1
		end
	else
		self.template.dangerHint.template:SetTemplateVisibility(false)
	end
end

EnemyHUDCtrl.OnDead = function(cell)
	local self = cell.param
	self.showDetect = false
	self.showAttractedEffect = false

	if self.flashTweenFill then
		self.flashTweenFill:Kill()
	end

	if self.weakTweenFill then
		self.weakTweenFill:Kill()
	end

	self.KillAllBuffTweens(self)

	if self.detectTweenFill then
		self.detectTweenFill:Kill()

		self.detectTweenFill = nil
	end

	self.RefreshShowDetectRoot(self)
end

EnemyHUDCtrl.CustomClearProcedure = function(self)
	if self.flashTweenFill then
		self.flashTweenFill:Kill()
	end

	if self.weakTweenFill then
		self.weakTweenFill:Kill()
	end

	if self.detectTweenFill then
		self.detectTweenFill:Kill()

		self.detectTweenFill = nil
	end

	self.KillAllBuffTweens(self)

	self.showDisarm = false
	self.showAttractedEffect = false
	self.showDetect = false
	self.hintShowType = 0
	self.allyHpVisible = false
	self.OnSystemUnlockHandler = nil
	self.onMindIconEnemyChanged = nil
	self.isPveRaid = nil
	self.cfg = nil
end

EnemyHUDCtrl.ClearEventListener = function(self)
	if self.onMindIconEnemyChanged then
		gMessageManager:RemoveMessageListener(gEventConstants.MIND_ICON_ENEMY_CHANGED, self.onMindIconEnemyChanged)
	end

	if self.OnSystemUnlockHandler then
		gMessageManager:RemoveMessageListener(gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE, self.OnSystemUnlockHandler)
	end

	if self.onWeaponChange then
		gMessageManager:RemoveMessageListener(gEventConstants.WEAPON_CHANGED, self.onWeaponChange)
	end

	if self.onMaxPoiseValueChange then
		gMessageManager:RemoveMessageListener(gEventConstants.ATTRIBUTE_CHANGED_MAXPOISEVALUE, self.onMaxPoiseValueChange)
	end

	if self.onBuffChange then
		gMessageManager:RemoveMessageListener(gEventConstants.REFRESH_HEADVIEW_BUFFS, self.onBuffChange)
	end
end

return EnemyHUDCtrl
