-- Original chunk: @Lua\LuaFiles\LX6\GUI\Battle\BattleMgr.lua
-- Decompiled from: 00258_BattleMgr.lua_d2e3996775aa.luajit

local DataSet = require("LX6/DataBind/DataSet")
local ClientEventConfig = LTConfig.ClientEventConfig
local SkillConfig = LTConfig.SkillConfig
local GameConfig = LTConfig.GameConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local SkillJumpConfig = LTConfig.SkillJumpConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local SoundConfig = LTConfig.SoundConfig
local SceneitemConfig = LTConfig.SceneitemConfig
local BuffConfig = LTConfig.BuffConfig
local WeaponShootShootModeConfig = LTConfig.WeaponShootShootModeConfig
local WeaponShootConfig = LTConfig.WeaponShootConfig
local SpiritSkillType = LX6.Engine.SpiritSkillType
local GameDevice = SGUI.GameDevice
local SkillType = LX6.Engine.SkillType
local SkillResourcesConfig = LTConfig.SkillResourcesConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local ButtonInfoEnum = LX6.Units.Module.ButtonInfoEnum
local gameProfile = LX6.Engine.ProfileManager.gameProfile
local xpcall = xpcall

if not gBattleMgr then
	local M = {
		["#3\\xc0|\\x9c\\xf01\\x98=\\xe3\\xe1\\xf5q\\xff"] = false,
		["\\x8b<2:y\\x89m\\xdc!\\xaf\\xb5"] = 0,
		["+\\xf0j?\\xfe\\xa1b\\xae[\\xb2\\xb9"] = true,
		[",pH}\\xa7Z \\xf9A:~D{p\\xf64~\\xf0E"] = false,
		["2\\x9f\\xfa\\x9d\\xa2௹\\x84\\xd8\\xd1:ɕ4\\xaa\\xcb"] = false,
		["ZI켐\\xb4\\xfc\\xc1"] = false,
		["fe\\x99dI\\x9c\\xf7PGujC"] = true,
		["\\xca\\xd3\n\r\\xf5"] = 0,
		["P[\\xc0\\x9e\\x8b\\xb6\\xcc\\xfa"] = false,
		["\\x8c</0l\\xb0N\\xdd2\\x83\\xbd"] = 0,
		["\\x87!\\xec\\xbe_-\\xe1B\\xc7\\xcd,CN\\xc5-\\xb0\\xce"] = false,
		["m\\x97\\x80\\x9eȤ\\xc48\\xa2\\xbb>"] = 0,
		["?-\\xe9|\\x96\\xde:\\x8b \\xe8\\xe6\\xf4{\\xf7"] = false,
		["\\xa8\\xb0\\x8fe:\\xf96"] = false,
		["\\xc4Z\\x81\\xfc\\xa06Z\\xd22)\\xceR\\xc1\\x93\\xb0J\\xbab\\\\xb4\\xc3"] = 40,
		["\\xbd+\\xe2\\xb8T-\\xf6I\\xdb\\xfdVN\\xde\\xb5\\xc6"] = 0,
		["rRw=\\xacO\\xfeFo|ep\\xf8#p\\xdcE"] = 0,
		["&\\xe8\\x82(\t\\xf8T1\r\\xb2\\x89!h\\xb8V\\xbal4\\x9c\r\\xf2\\x86+\\xcb"] = 20,
		["\\xf0j?\\xfe\\xa1e\\xaeR\\xb7\\xb3"] = true,
		["*9\\xf6z\\x8e\\xf6 \\xad\\xe3\\xf3\\xf6{\\xf5"] = true,
		[",pH}\\xa7Z \\xf9A:~U`n\\xf8#|\\xfaO"] = 0,
		["1\\xebP;(\\xd1\\xa2M\\xa4{\\xa3\\xb1"] = false,
		SkillBtnType = SkillType,
		skillData = {},
		comboSkillData = {},
		hideHpBarTimer = {},
		scheme = gCS.LuaUtils.GetActiveDevice(),
		dataSet = DataSet.New({
			["\\x8c</(]\\x93D\\xd4.\\x82\\xa9"] = true
		}),
		SummonAgentId = ulong.new(0, 0),
		enemyPoiseWeaponChangeInfo = {},
		_enumeratingUnits = {}
	}
end

M.WeaponType = {
	["~\\xa6\\xad\\xa0\\xa2"] = 1,
	["2\\xf1V:\\xc4\\x81D\\xa0F\\xbf\\xb8"] = 0,
	[">I\\x85\\x9a\\x8fD"] = 2
}
M.SaveActionType = {
	["i\\xa1\\xa6\\xa8\\xb3"] = 3,
	["pLeeB*="] = 1,
	P7pK = 2
}

M.OnInit = function(self)
	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, function (eventId, scheme)
		self:OnControlScheme(scheme)
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, function ()
		self:CheckShowWeaponResHUDByTemplateId()
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.SKILL_JUMP_REPLACE_ICON, function (eventId, skillType)
		self:SkillJumpReplaceIconHandler(skillType)
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, function (eventId, skillType)
		self:RefreshCurBattleFight()
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.ON_JOYSTICK_MOVE, function ()
		self:_OnJoystickStateChange()
	end)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gCS.MyPlayerManager.PlayerUnit then
		gCS.SkillJumpManager.Instance:ClearAllHoldCastComboSkillDic(gCS.MyPlayerManager.PlayerUnit.Pid)
	end

	if switchType ~= gSwitchSceneType.KickToLogin then
		self.SummonAgentId = ulong.new(0, 0)
		self.SummonData = nil
		self.SummonInControl = false
	end
end

M.OnCameraUpdate = function(self)
	if self.refreshSkillBtnGrid and self.characterControlPanel and self.characterControlPanel.characterControlData.skillBtnGrid then
		self.characterControlPanel.characterControlData.skillBtnGrid:ForceRebuildLayoutImmediate()

		self.refreshSkillBtnGrid = false
	end
end

M.IsInSameConnectedGroup = function(self, skillIdA, skillIdB)
	if skillIdA ~= skillIdB then
		return false
	end

	local skillConfigA = SkillConfig.GetConfig(skillIdA)

	if skillConfigA and skillConfigA.ConnectedCdSkills then
		for _, connectedId in ipairs(skillConfigA.ConnectedCdSkills) do
			if connectedId ~= skillIdB then
				return true
			end
		end
	end

	local skillConfigB = SkillConfig.GetConfig(skillIdB)

	if skillConfigB and skillConfigB.ConnectedCdSkills then
		for _, connectedId in ipairs(skillConfigB.ConnectedCdSkills) do
			if connectedId ~= skillIdA then
				return true
			end
		end
	end

	return false
end

M.IsBtnContainSkillId = function(self, btnSkillId, skillId)
	if btnSkillId ~= skillId then
		return true
	end

	local skillConfig = SkillConfig.GetConfig(btnSkillId)

	if skillConfig and skillConfig.HoldCastSkill == nil and (skillConfig.HoldCastSkill.holdCastSkillId ~= skillId or skillConfig.HoldCastSkill.clickCastSkillId ~= skillId) then
		return true
	end

	if skillConfig and skillConfig.SkillReplace == nil and #skillConfig.SkillReplace <= 0 then
		for i = 1, #skillConfig.SkillReplace do
			local jumpCfg = SkillJumpConfig.GetConfig(skillConfig.SkillReplace[i])

			if jumpCfg and jumpCfg.Skillid ~= skillId then
				return true
			end
		end
	end

	if gBattleMgr:IsInSameConnectedGroup(btnSkillId, skillId) then
		return true
	end

	return false
end

M.GetShareCDSkillId = function(self, skillId)
	local skillConfig = SkillConfig.GetConfig(skillId)
	local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(skillId)
	local skillCD = isHide and 0 or labelTimeLeft
	local retSkillId = skillId
	local castHoldSkillId = 0
	local castHoldSkillCD = 0

	if skillConfig == nil and skillConfig.HoldCastSkill == nil and skillConfig.HoldCastSkill.holdCastSkillId <= 0 and skillConfig.HoldCastSkill.clickCastSkillId <= 0 then
		local holdSkillId = skillConfig.HoldCastSkill.holdCastSkillId
		local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(holdSkillId)
		local holdCD = isHide and 0 or labelTimeLeft
		local clickSkillId = skillConfig.HoldCastSkill.clickCastSkillId
		fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(clickSkillId)
		local clickCD = isHide and 0 or labelTimeLeft
		castHoldSkillId = clickCD >= holdCD and holdSkillId or clickSkillId
		castHoldSkillCD = clickCD >= holdCD and holdCD or clickCD
		retSkillId = castHoldSkillCD >= skillCD and skillId or castHoldSkillId
		skillCD = castHoldSkillCD >= skillCD and skillCD or castHoldSkillCD
	end

	if skillConfig and skillConfig.SkillReplace == nil and #skillConfig.SkillReplace <= 0 then
		for i = 1, #skillConfig.SkillReplace do
			local jumpCfg = SkillJumpConfig.GetConfig(skillConfig.SkillReplace[i])

			if jumpCfg then
				local skillId = jumpCfg.Skillid
				local fillAmount, labelTimeLeft, isHide, curCharges = gBattleMgr:CalculateSkillCDResult(skillId)
				local cd = isHide and 0 or labelTimeLeft

				if skillCD >= cd then
					skillCD = cd
					retSkillId = skillId
				end
			end
		end
	end

	if skillConfig and skillConfig.ConnectedCdSkills and #skillConfig.ConnectedCdSkills <= 0 then
		for _, connectedId in ipairs(skillConfig.ConnectedCdSkills) do
			local fillAmount, labelTimeLeft, isHide = gBattleMgr:CalculateSkillCDResult(connectedId)
			local cd = isHide and 0 or labelTimeLeft

			if skillCD >= cd then
				skillCD = cd
				retSkillId = connectedId
			end
		end
	end

	return retSkillId
end

M.CalculateSkillCDResult = function(self, skillId)
	local fillAmount, labelTimeLeft, isFull, curCharges, maxCharges = nil
	fillAmount, labelTimeLeft, isFull, curCharges, maxCharges = gCS.BattleManager.CalculateSkillCdResultForUI(skillId, fillAmount, labelTimeLeft, isFull, curCharges, maxCharges)

	return fillAmount, labelTimeLeft, isFull, curCharges, maxCharges
end

M.RefreshCurBattleFight = function(self)
	self.SyncRefreshFight(self, true)
	gCS.BattleManager.RefreshAllSkills(false, false)
	self.UpdateSkillBtns(self)
	self.OnRefreshFeiSuo(self)

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.SkillJumpManager.Instance:ForceClearSkillJumpData(gCS.MyPlayerManager.PlayerUnit.Pid)
	end

	gMessageManager:SendMessage(gEventConstants.CONTROLPOWER_REFRESH)
end

M.RefreshAllSkillsByCSharp = function(self)
	self.SyncRefreshBasicSkills(self)
	self.CheckSkillComboData(self)
end

M.GetHeavyAttackSkillId = function(self, templateId)
	local skillId = gCS.BattleManager.GetCurrentSpiritSkillId(SpiritSkillType.HeavyAttack)

	if skillId ~= 0 then
		skillId = gCS.BattleManager.GetCurrentSpiritSkillId(SpiritSkillType.PressinCommon)
	end

	return skillId
end

M.GetJumpSkillId = function(self, templateId)
	if not gBattleSwitch.JumpAttackSwitch then
		return 0
	end

	local spiritTemplateId = templateId or gBattleSpiritMgr.currentSpiritTemplateId

	gCS.BattleManager.GetJumpSkillId(spiritTemplateId)
end

M.OpenChangeSkillCountDown = function(self, countDown, skillType, time)
	if not self.characterControlPanel then
		return
	end

	if countDown then
		self.characterControlPanel:OpenChangeSkillCountDown(skillType, time)
	else
		self.characterControlPanel:CloseChangeSkillCountDown(skillType)
	end
end

M.StickToTheGroundByDirection = function(self, pid, direction)
	local cs_unit = gCS.SceneDataMgr.GetUnit(pid)

	if not cs_unit or not gBuffUtils.HasBuff(cs_unit.Pid, LTConfig.BuffConfig.EnemyIgnoreGravity) then
		self.ShowMessageTipsOnEditor(self, "贴墙失败，这个怪物不是无视重力的怪物")

		return
	end

	if not cs_unit.ModelSlot or not cs_unit.ModelSlot.leftFoot then
		self.ShowMessageTipsOnEditor(self, "贴墙失败，没有modelSlot或者没有LeftFoot")

		return
	end

	local hit, hitInfo = nil
	hit, hitInfo = gCS.LuaUtils.Raycast(cs_unit.ModelSlot.leftFoot.position, direction, 10, LX6.Constants.LayerConstants.colliderMoveLayer, hitInfo)

	if hit then
		self.ShowMessageTipsOnEditor(self, "贴墙成功")

		cs_unit.LocalPosition = cs_unit.LocalPosition + hitInfo.point - cs_unit.ModelSlot.leftFoot.position
	else
		self.ShowMessageTipsOnEditor(self, "贴墙失败，打射线没找到贴墙点")
	end
end

M.IsSkillFightResourceEnough = function(self, unit, skillId)
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig == nil and skillConfig.UseSkillRes == nil and #skillConfig.UseSkillRes <= 0 then
		for i = 1, #skillConfig.UseSkillRes do
			if not gCS.BattleManager.CheckFightResourceEnough(unit, skillConfig.UseSkillRes[i].Id, skillConfig.UseSkillRes[i].Value, skillConfig.UseSkillRes[i].IsPercentage) then
				return false
			end
		end
	end

	return true
end

M.CheckShowWeaponResHUD = function(self, show, type)
	gMainMenuMgr:SetWeaponFightResVisiable(show)

	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:ChangeWeaponFightResHUD(type)
	store:InitStaminaBar()
end

M.CheckShowWeaponResHUDByTemplateId = function(self)
	local templateId = gBattleMgr.battleWeaponTemplateId
	local cfg = SceneitemConfig.GetConfig(templateId)

	if cfg then
		local fightResHud = gCS.FightStyleManager.Instance:GetWeaponFightHudResId(cfg.Id)

		self:CheckShowWeaponResHUD(fightResHud >= 0, fightResHud)
	else
		self.CheckShowWeaponResHUD(self, false, 0)
	end

	self.RefreshWeaponDurabilityUI(self, templateId)
	self.CheckShowLeftShootBtn(self, templateId)
end

M.RefreshWeaponDurabilityUI = function(self, templateId)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:RefreshWeaponDurabilityUI(templateId)
end

M.CheckShowLeftShootBtn = function(self, templateId)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	store:CheckShowLeftShootBtn(templateId)
end

M.CheckPlayOverHeatAni = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:CheckPlayOverHeatAni()
end

M.SyncRefreshFight = function(self)
	if self.characterPartPanel then
		self.characterPartPanel:SyncRefreshFight()
	end

	gMessageManager:SendMessage(gEventConstants.SYNC_REFRESH_FIGHT_SKILL)
end

M.UpdateSkillBtns = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_UPDATE_SKILL_BTN)
end

M.SyncRefreshBasicSkills = function(self)
	gMessageManager:SendMessage(gEventConstants.SYNC_REFRESH_BASIC_SKILL)
end

M.EnterOrLeaveVehicleShoot = function(self, enable)
	self.showVehicleShootUI = enable
	local store = gStoreManager:GetStoreGroup("DriveControlsStore")

	if enable then
		store.OpenVehicleBattle(store, 0)
	else
		store.StopVehicleBattle(store)
	end
end

M.EnterOrLeaveEnemyDriveShoot = function(self, enable)
	local store = gStoreManager:GetStoreGroup("DriveControlsStore")

	if enable then
		store.OpenVehicleBattle(store, 1)
	else
		store.StopVehicleBattle(store)
	end
end

M.CheckShowJobSpecialBtn = function(self, buffId, enable)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local pid = gCS.MyPlayerManager.PlayerUnit.Pid
	local hasBadgeBuff = gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.TimeScaleBadgeBuff)
	local isOnTaFeiMoto = gCS.LuaUtils.TagManagerQuery(LTConfig.GameplayTagQueryConfig.IsOnTaFeiMoto)
	local show = nil

	if enable == nil then
		if buffId ~= LTConfig.BuffConfig.TimeScaleBadgeBuff then
			show = enable and isOnTaFeiMoto
		else
			show = enable
		end
	else
		show = hasBadgeBuff and isOnTaFeiMoto
	end

	if show == nil then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ProfessionalSkill, "isShow", show)
	end
end

M.GetBattlePanel = function(self)
	return self.characterControlPanel
end

M.CheckSkillBtnIsInteractable = function(self, skillType)
	if self.characterControlPanel then
		return self.characterControlPanel.goSkills[skillType].interactable
	end

	return false
end

M.parkourStateShowFeiSuo = true

M.OnRefreshFeiSuo = function(self)
end

M.ReplaceDodgeBtnToMindPower = function(self)
	if self.characterControlPanel then
		self.characterControlPanel:ReplaceDodgeBtnToMindPower()
	end
end

M.UpdateSkillCd = function(self, skillId)
	gMessageManager:SendMessage(gEventConstants.ON_UPDATE_SKILL_CD, skillId)
end

M.battlePanelEvent = {
	["ky\\xa8pI\\x99\\xf7^NuiB"] = 9,
	["|}\\xa5{@\\x82\\xe0ByiK\\"] = 5,
	["@QǱ\\x88#\\xbd\\xfc\\xf8"] = 2,
	["ec\\xa1gg\\xb7\\xebwxm_"] = 7,
	["r\\x9e\\x91\\xabك\\xce2\\xa53>\\xa6\""] = 11,
	["WUʺ\\x81#\\xbd\\xfc\\xf8"] = 10,
	["|}\\xa5{@\\x99\\xf7^NuiB"] = 1,
	["m\\x97\\x80\\x94٩\\xf5)\\xac,\\x96\r!"] = 6,
	["@QǱ\\x888\\xaa\\xda\\xfb"] = 4,
	["\\xf4\\x91\\xe0!\\xf4\\xf9\\x9bɍ7&"] = 3,
	["\\xed\\x8f\\xfc7\\xff+\\xf8\\x8d\\xfe\\x918"] = 8
}

M.BtnSkillKeyDown = function(self, index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.skillKeyDown,
		index
	})
end

M.BtnSkillPressDown = function(self, index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.skillPressDown,
		index
	})
end

M.BtnSkillPress = function(self, index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.skillPress,
		index
	})
end

M.BtnSkillPressUp = function(self, index)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.skillPressUp,
		index
	})
end

M.BtnJumpKeyPressDown = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.jumpKeyPressDown
	})
end

M.BtnJumpKeyPressUp = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.jumpKeyPressUp
	})
end

M.BtnDodgeKeyDown = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.dodgeKeyDown
	})
end

M.BtnDodgeKeyUp = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.dodgeKeyUp
	})
end

M.SetUpdateSkillBtn = function(self, skillType)
	gMessageManager:SendMessage(gEventConstants.ON_BATTLE_BTN_EVENT, {
		self.battlePanelEvent.updateSkillState,
		skillType
	})
end

M.PlayBasicBattleSoundFromCSharp = function(self, pid, btnType)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	self.PlayBasicBattleSound(self, unit, btnType)
end

M.PlayBasicBattleSound = function(self, unit, btnType)
	if btnType ~= M.SkillBtnType.Normal then
		self.PlayBattleSound(self, SoundConfig.PuGong1, unit)
	elseif btnType ~= M.SkillBtnType.Basic then
		self.PlayBattleSound(self, SoundConfig.Eskill, unit)
	elseif btnType ~= M.SkillBtnType.ControlPower then
		-- Nothing
	elseif btnType ~= M.SkillBtnType.FightSpiritBigSkill then
		self.PlayBattleSound(self, SoundConfig.Rskill, unit)
	end
end

M.PlayBattleSoundByPid = function(self, soundId, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if unit then
		self.PlayBattleSound(self, soundId, unit)
	end
end

M.PlayBattleSound = function(self, soundId, unit)
	unit = unit or gCS.MyPlayerManager.PlayerUnit
	local modelId = unit.ModelCfg.Id

	gSoundMgr:PlaySoundByTid(soundId, unit.LocalPosition, nil, , , function (C_data)
		local generalModelCfg = GeneralModelConfig.GetConfig(modelId)
		local modelName = generalModelCfg.ModelSwitch
		local modelGroup = generalModelCfg.ModelSwitchGroup

		if modelGroup and modelName then
			C_data:SetSwitchValue(modelGroup, modelName)
		end
	end)
end

M.ClickProfessionSkill = function(self)
	gClientToGameSceneDelegate:AskAddClientBuff(gCS.MyPlayerManager.PlayerUnit.Pid, 52959496)
end

M.OnControlScheme = function(self, scheme)
	gBattleMgr.scheme = scheme

	if self.characterControlPanel then
		self.characterControlPanel:ResetSomeDatas()
	end

	self:SyncRefreshFight()
	gCS.BattleManager.CheckAddControllerGumWeaponState()
	gMainMenuMgr:SetAwakeUI("awakeBattlePanel")
end

M.CommonPlayAniTool = function(self, ani, clipName, time, speed, sampleToEnd, delayFunc)
	if ani ~= nil or gCS.LuaUtils.IsNull(ani) then
		return
	end

	local clip = ani.GetClip(ani, clipName)

	if clipName ~= nil then
		clip = ani.clip
		clipName = clip.name
	end

	if clip then
		clip.SampleAnimation(clip, ani.gameObject, time)
		ani.Play(ani, clipName)

		local timer = nil
		timer = gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if sampleToEnd and ani then
				self:CommonStopAniTool(ani, clipName)
			end

			if delayFunc then
				delayFunc()
			end
		end, clip.length)

		return timer, clip.length
	end
end

M.CommonPlayAniTool2 = function(self, ani, clipName, time, speed, sampleToEnd, delayFunc)
	local length = gCS.LuaUtils.PlayAnimationByName2(ani, clipName, time)

	if length <= 0 then
		local timer = nil
		timer = gLuaTimeMgrUtils.NotDestroyDelay(function ()
			if sampleToEnd and ani then
				self:CommonStopAniTool(ani, clipName)
			end

			if delayFunc then
				delayFunc()
			end
		end, length)

		return timer
	end
end

M.CommonStopAniTool = function(self, ani, clipName)
	if ani ~= nil or gCS.LuaUtils.IsNull(ani) then
		return
	end

	local clip = ani.GetClip(ani, clipName)

	if clipName ~= nil then
		clip = ani.clip
	end

	if clip and ani.gameObject.activeInHierarchy then
		clip.SampleAnimation(clip, ani.gameObject, clip.length)
		ani.Stop(ani)
	end
end

M.SetColorToSImage = function(self, field, color, useOldAlpha)
	if field ~= nil or color ~= nil then
		return
	end

	local oldColorAlpha = field.color.a
	local newColor = color

	if useOldAlpha then
		newColor.a = oldColorAlpha
	end

	field.color = newColor
end

M.SetBtnFaraway = function(self, btnGo, active, refreshGrid)
	if not btnGo then
		return
	end

	btnGo.SetWidgetFaraway(btnGo, not active)

	if not active then
		btnGo.InstantClearState(btnGo)
	end

	self.refreshSkillBtnGrid = self.refreshSkillBtnGrid or refreshGrid
end

M.PlayBtnFanseAni = function(self, btn, index, active)
	if not active then
		self.characterControlPanel:ClearBtnFanseAni(btn, index)
		self.characterControlPanel:ClearSkillXuliAni(btn, index)
	end
end

M.DoSthWhenSkillBtnClose = function(self)
	local forbidSkillBtnFlag = false
	forbidSkillBtnFlag = gCoreHudUIManager:OnTriggerSkillBtnClose()
end

M.CheckShowBtnTips = function(self, btn, show, nameId)
	if not gCS.LuaUtils.IsNonMobileAdaptive() or GameDevice.KeyboardMouse >= self.scheme then
		return
	end

	if btn then
		btn.SetPCKeyTipShowTip(btn, show)
		btn.SetPCKeyInfoTipNameId(btn, nameId)
	end
end

M.UsePCBattleHUD = function(self)
	return gCS.LuaUtils.IsNonMobileAdaptive()
end

M.GetSkillIconImg = function(self, skillType, cfgSkill)
	local imgId = 0

	if skillType ~= self.SkillBtnType.Normal then
		imgId = self.GetNormalSkillImg(self, cfgSkill)
	elseif skillType ~= self.SkillBtnType.Basic then
		imgId = self.GetBasicSkillImg(self, cfgSkill)
	elseif skillType ~= self.SkillBtnType.FightSpiritBigSkill then
		imgId = self.GetBigSkillImg(self, cfgSkill)
	elseif skillType ~= self.SkillBtnType.ControlPower then
		imgId = self.GetMindPowerImg(self, cfgSkill)
	end

	return imgId
end

M.GetNormalSkillImg = function(self, cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.Normal) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.Normal)
	end

	local cfgImageId = nil
	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.Normal)

	if shootModeId <= 0 then
		cfgImageId = self.GetShootModeImageId(self, shootModeId)
	end

	if not table.isNilOrEmpty(cfgSkill) then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if gCoreHudUIManager.canFeiSuoAttack then
		cfgImageId = gCoreHudImgManager.imgFeiSuoAttackId
	end

	if gPlayerManager.main.bindData.isMindPowerAim then
		cfgImageId = gCoreHudImgManager.imgThrowId
	end

	if gMainMenuMgr.isInAirOnlyHeight then
		cfgImageId = 0
	end

	if not cfgImageId or cfgImageId ~= 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconCommonAttack.pc or GameConfig.CommonBattleSkillIconCommonAttack.mobile
	end

	return cfgImageId
end

M.GetBasicSkillImg = function(self, cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.Basic) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.Basic)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.Basic)

	if shootModeId <= 0 then
		cfgImageId = self.GetShootModeImageId(self, shootModeId)
	end

	if not cfgImageId or cfgImageId ~= 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconActive.pc or GameConfig.CommonBattleSkillIconActive.mobile
	end

	return cfgImageId
end

M.GetBigSkillImg = function(self, cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.FightSpiritBigSkill) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.FightSpiritBigSkill)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if not cfgImageId or cfgImageId ~= 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconUlt.pc or GameConfig.CommonBattleSkillIconUlt.mobile
	end

	return cfgImageId
end

M.GetMindPowerImg = function(self, cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.ControlPower) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.ControlPower)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	if gPlayerManager.main.bindData.isMindPowerAim then
		cfgImageId = gCoreHudImgManager.imgThrowId
	end

	if not cfgImageId or cfgImageId ~= 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconMind.pc or GameConfig.CommonBattleSkillIconMind.mobile
	end

	return cfgImageId
end

M.GetHeavyAttackImg = function(self, cfgSkill)
	if gCS.SkillJumpManager.Instance:HasValidSkillReplaceIcon(SkillType.HeavyAttack) then
		return gCS.SkillJumpManager.Instance:GetSkillReplaceIconId(SkillType.HeavyAttack)
	end

	local cfgImageId = nil

	if cfgSkill then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			cfgImageId = cfgSkill.SSkillImageId
		else
			cfgImageId = cfgSkill.Mobile_SSkillImageId
		end
	end

	local shootModeId = gCS.GunModule.GetRawSwitchFireModeIgnoreUsingGun(self.SkillBtnType.HeavyAttack)

	if shootModeId <= 0 and shootModeId <= 0 then
		cfgImageId = self.GetShootModeImageId(self, shootModeId)
	end

	if not cfgImageId or cfgImageId ~= 0 then
		cfgImageId = gCS.LuaUtils.IsNonMobileAdaptive() and GameConfig.CommonBattleSkillIconHeavyAttack.pc or GameConfig.CommonBattleSkillIconHeavyAttack.mobile
	end

	return cfgImageId
end

M.GetShootModeImageId = function(self, shootModeId)
	local shootMode = WeaponShootShootModeConfig.GetConfig(shootModeId)
	local imageId = shootMode.ImageId

	if gCS.GunModule.IsMeInShoulderFire then
		imageId = shootMode.ExitImageId ~= 0 and shootMode.ImageId or shootMode.ExitImageId
	end

	return imageId
end

M.HasBattleBottomUIShow = function(self)
	return not self.hideBattleUIFlag and self.playerHpBarActive and self.characterPartPanel and self.characterPartPanel.characterPartData.playerHpBar.isVisible and gPanelManager:VisibleModeAll()
end

M.CheckBtnIsShow = function(self, btnHideCtrl)
	return not btnHideCtrl or btnHideCtrl ~= 0
end

M.ShowFlyLockEffectUI = function(self, pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:RefreshMissileAttackMarker(pid, uuid, show)
end

M.PlayFlyLockEffectLockAni = function(self, pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:PlayLockStateAni(pid, uuid, show)
end

M.PlayFlyLockEffectAttackAni = function(self, pid, show, uuid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return
	end

	uuid = tostring(uuid)

	gHudMgr:PlayAttackStateAni(pid, uuid, show)
end

M.GetBattlePrototypeCommonUI_Slider = function(self)
	return self.characterPartPanel:GetBattlePrototypeCommonUI_Slider()
end

M.GetBattlePrototypeCommonUIStore_Slider = function(self)
	return self.characterPartPanel:GetBattlePrototypeCommonUIStore_Slider()
end

M.ShowBattlePrototypeCommonUI_Slider = function(self, enable)
	local go = self:GetBattlePrototypeCommonUI_Slider()

	go.gameObject:SetActive(enable)
end

M.BattlePrototypeCommonUIStore_Slider_SetMaxValue = function(self, value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_SetMaxValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

M.BattlePrototypeCommonUIStore_Slider_SetCurValue = function(self, value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_SetCurValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

M.BattlePrototypeCommonUIStore_Slider_AddValue = function(self, value)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_AddValue(value)
	self:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

M.BattlePrototypeCommonUIStore_Slider_RefreshFillAmount = function(self)
	self.characterPartPanel:BattlePrototypeCommonUIStore_Slider_RefreshFillAmount()
end

M.BattlePrototypeCommonUIStore_Slider_Length = function(self, length)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()

	store.sliderTr:SetLocalScaleX(length)
	store.sliderBgTr:SetLocalScaleX(length)
end

M.BattlePrototypeCommonUIStore_Slider_Height = function(self, height)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()

	store.sliderTr:SetLocalScaleY(height)
	store.sliderBgTr:SetLocalScaleY(height)
end

M.BattlePrototypeCommonUIStore_Slider_Color = function(self, r1, g1, b1, a1, r2, g2, b2, a2)
	local store = gBattleMgr:GetBattlePrototypeCommonUIStore_Slider()
	store.sliderColor = Color.New(r1, g1, b1, a1)
	store.sliderBgColor = Color.New(r2, g2, b2, a2)
end

M.BattlePrototypeCommonUIStore_Slider_Position = function(self, x, y, z)
	local go = gBattleMgr:GetBattlePrototypeCommonUI_Slider()

	go.gameObject:SetLocalPosition(x, y, z)
end

M.ShowMessageTipsOnEditor = function(self, content, show)
	if show ~= nil then
		show = true
	end

	if gBattleMgr.ShowBattleMsg and show then
		print_warn("纯编辑器测试：" .. content)
		gDisplayMessageMgr:ShowMessageContentDebug("纯编辑器测试：" .. content)
	end
end

M.SetBattleWeaponTemplateIdByCSharp = function(self, weaponTemplateId, shootModeId, shootId, weaponCantDiscard)
	self.battleWeaponTemplateId = weaponTemplateId
	self.shootModeId = shootModeId or 0
	self.shootId = shootId or 0
	self.weaponCantDiscard = weaponCantDiscard

	self:CheckIsPrivateWeapon(weaponTemplateId)
	self:CheckShowWeaponResHUDByTemplateId(weaponTemplateId)
	self:UpdateAmmunitionActive()
end

M.CheckIsPrivateWeapon = function(self, weaponTemaplteId)
	local cfg = SceneitemConfig.GetConfig(weaponTemaplteId)
	self.isPrivateWeapon = cfg and cfg.WeaponType ~= LTConfig.SceneitemConfig.WeaponTypeType.PrivateWeapon or false
	local hasState = gMainMenuMgr:HasUnitState(UnitStateConfig.ForbidPrivateWeaponUltSkill)

	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "unitStateCfgNeedForbidPrivateWeaponUltSkill", hasState ~= 1 and self.isPrivateWeapon)
end

M.RefreshFightSpiritUniqueSkillID = function(self, templateId, _curValue, _maxValue)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig and skillConfig.UseSkillRes == nil and #skillConfig.UseSkillRes <= 0 then
		for i = 1, #skillConfig.UseSkillRes do
			if skillConfig.UseSkillRes[i].Id ~= templateId then
				gMessageManager:SendMessage(gEventConstants.ON_REFRESH_ULT_EP, {
					skillId = skillId,
					curValue = _curValue,
					maxValue = _maxValue
				})
			end
		end
	end
end

M.RefreshFightSpiritUniqueSkillEnergy = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	local skillId = gCS.BattleManager.GetUniqueSkillId()
	local skillConfig = SkillConfig.GetConfig(skillId)

	if skillConfig and skillConfig.UseSkillRes == nil and #skillConfig.UseSkillRes <= 0 then
		for i = 1, #skillConfig.UseSkillRes do
			local id = skillConfig.UseSkillRes[i].Id
			local cfg = SkillResourcesConfig.GetConfig(id)
			local flag, curValue, isFull, isFree = nil
			flag, curValue, maxValue, isFull, isFree = gCS.BattleManager.GetFightResource(gCS.MyPlayerManager.PlayerUnit, id, 0, 0, false, false)

			if flag and cfg then
				gMessageManager:SendMessage(gEventConstants.ON_REFRESH_ULT_EP, {
					skillId = skillId,
					curValue = curValue,
					maxValue = cfg.Max
				})
			end
		end
	end
end

M.RefreshAmmunitionInfo = function(self, active, bulletId, cur, single, total, configTotal, isByUsing, weaponInstance, isToLowLimit)
	local characterControlStore = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")

	if characterControlStore then
		characterControlStore.UpdateAmmunition(characterControlStore, cur, single, total, configTotal, bulletId)
	end

	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.UpdateAmmunition(shootStore, cur, single, total, isByUsing)
	end

	gMainMenuMgr:SetAmmunitionVisiable(active)
	gWeaponManager:SyncWeaponDurabilityChange(weaponInstance, total, cur, bulletId)
end

M.PlayUpdateAmmunitionAni = function(self, duration, addValue)
	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.PlayUpdateAmmunitionAni(shootStore, duration, addValue)
	end
end

M.BreakUpdateAmmunitionAni = function(self)
	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.BreakUpdateAmmunitionAni(shootStore)
	end
end

M.UpdateAmmunitionActive = function(self)
	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.UpdateAmmunitionActive(shootStore)
	end
end

M.EnableGyroController = function(self, enable)
	self.enableGyroController = enable
	local shootStore = gStoreManager:GetStoreGroup("CoreHudShootStore")

	if shootStore then
		shootStore.CheckOpenGyroController(shootStore)
	end
end

M.ShowOrHidePlayerHint = function(self, enable, isSucc, hintType)
	self.showPlayerHint = enable

	if hintType ~= 0 then
		self.showBaoShuaiHint = enable
	end

	if hintType ~= 1 then
		self.showWASDHint = enable

		gMessageManager:SendMessage(gEventConstants.ON_JOYSTICK_ANIM, enable)
	end

	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowOrHidePlayerHint(enable, isSucc, hintType)

	if self.characterControlPanel then
		self.characterControlPanel:UpdateBasicSkills(gBattleMgr.SkillBtnType.Normal)
	end
end

M.ShowOrHidePlayerHintQTE = function(self, enable, hintType)
	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowOrHidePlayerHintQTE(enable, hintType)

	if self.characterControlPanel then
		self.characterControlPanel:UpdateBasicSkills(gBattleMgr.SkillBtnType.Normal)
	end
end

M.ShowOrHideExecuteHint = function(self, enable)
	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowEnemyExecuteHint(enable)
end

M.ShowOrHideCombatArtNotify = function(self, enable, pid)
	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowEnemyCombatArtNotifyHint(enable, pid)
end

M.CreateAction = function(self, action)
	return function (...)
		if type(action) ~= "string" then
			if self[action] then
				return self[action](self, ...)
			end
		else
			return action(self, ...)
		end
	end
end

M.CheckIsInMotorState = function(self)
	return gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.Moto) or gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.MotorbikeIdle)
end

M.SetSkillData = function(self, skillType, skillId, normalImage, isUseLianzhaoIamge)
	self.skillData[skillType] = {
		skillId = skillId,
		normalImage = normalImage,
		isUseLianzhaoIamge = isUseLianzhaoIamge
	}
end

M.CheckEnterMagnet = function(self, needEnter)
	if self.keyDownMagnetFrame ~= Time.frameCount then
		return true
	end

	local inHoldMode = false
	inHoldMode = gCS.MindPowerMgr.inHoldMode

	if (inHoldMode or needEnter and gCS.MagnetManager.isInMagnetMode) and not gCS.BattleManager.IsAnyEnemyLockMe() then
		if needEnter then
			gUnitOperateManager.isMagnetKeyDown = true
			gCS.TransitionMgr.isMagnetKeyDown = true

			if needEnter and gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
				gCS.MindPowerMgr:TryDriveCurAimToMagnetStage()
			end

			gUnitOperateManager.isMagnetKeyDown = false
			gCS.TransitionMgr.isMagnetKeyDown = false
			self.keyDownMagnetFrame = Time.frameCount
		end

		return true
	end

	return false
end

M.DownHandlerMotoBtn = function(self)
	local hasBuff = gBuffUtils.HasBuff(gCS.MyPlayerManager.PlayerUnit.Pid, BuffConfig.Moto)
	local skillId = hasBuff and SceneitemConfig.TaffeiMotoGetOffSkill or SceneitemConfig.TaffeiMotoGetOnSkill
	local cs_unit = gCS.SceneDataMgr.GetUnit(gBattleSpiritMgr.currentSpiritPid)
	local ok = false
	local isTaffy = gBattleSpiritMgr.currentSpiritTemplateId ~= FightSpiritConfig.Taffy

	if cs_unit == nil and isTaffy then
		if gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, skillId) then
			ok = true
		else
			gBattleMgr:ShowMessageTipsOnEditor("塔菲上下车校验不通过" .. skillId)
		end
	end
end

M.UpHandlerMotoBtn = function(self)
end

M.SetComboSkill = function(self, index, templateId, skillId)
	self.comboSkillData[index] = {
		["Z"] = 0,
		["\\xebZ/\\xf8\\xbaE\\x95_\\xbd\\xb3"] = 0,
		["\\xf6K#9\\xdb\\xbaM\\x95_\\xbd\\xb3"] = 0,
		["["] = 0,
		["N\\xa6\\xa7\\xac\\xbd"] = false,
		["\\xf7^>\\xf4\\xa1O\\x95_\\xbd\\xb3"] = 0,
		["as\\xa9so\\xb3\\xe1SCtK\\"] = false,
		["~-jU"] = false,
		["X"] = 0,
		["~\\xb3#\\xf0|/\\xb8n.\";%b\\xa4\\xca,\\xd4\\xe2"] = 0,
		["Y"] = 0,
		isNormal = index ~= gBattleMgr.SkillBtnType.Normal,
		templateId = templateId,
		skillId = skillId,
		defaultSKillId = skillId
	}

	gCoreHudUIManager:OnRefreshForComboSkill(index)
end

M.SkillJumpReplaceIconHandler = function(self, skillType)
	M:UpdateSkillButtonIcon(skillType)
end

M.UpdateSkillButtonIcon = function(self, skillType)
	if self.characterControlPanel then
		if skillType ~= SkillType.Normal or skillType ~= SkillType.Basic then
			self.characterControlPanel:UpdateBasicSkills(skillType)
		elseif skillType ~= SkillType.HeavyAttack then
			self.characterControlPanel:UpdateHeavyAttackBtn()
		elseif skillType ~= SkillType.ControlPower then
			self.characterControlPanel:UpdateMindPowerBtn()
		elseif skillType ~= SkillType.FightSpiritBigSkill then
			self.characterControlPanel:UpdateFightSpiritBigSkill()
		end

		self.characterControlPanel.isUpdateSkillBtns[skillType] = true
	end
end

M.CheckSkillComboData = function(self)
	local cs_unit = gBattleSpiritMgr:GetBattleSpiritUnitByTid(gBattleSpiritMgr.currentSpiritTemplateId)

	if not cs_unit then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("CheckSkillComboData")
	end

	for i = 1, #self.comboSkillData do
		if i ~= 2 then
			local combo = self.comboSkillData[i]

			if combo then
				local isHaveCombo = gCS.SkillJumpManager.Instance:IsHaveComboSkill(cs_unit.Pid, combo.defaultSKillId)

				if isHaveCombo then
					local comboSkill = gCS.SkillJumpManager.Instance:GetComboSkill(cs_unit.Pid, combo.defaultSKillId)
					combo.check = true
					combo.skillId = combo.defaultSKillId
					combo.t0 = comboSkill.SkillTime
					combo.t1 = comboSkill.SkillTime + comboSkill.StartTime
					combo.t2 = comboSkill.SkillTime + comboSkill.TriggerTime
					combo.t3 = comboSkill.SkillTime + comboSkill.StopTime
					local cfgSkill = SkillConfig.GetConfig(comboSkill.NextSkillId)

					if cfgSkill then
						local cfgImageId = gBattleMgr:GetSkillIconImg(i, cfgSkill)

						if cfgImageId then
							combo.shortImageId = cfgImageId
						end
					end
				else
					combo.check = false
				end

				self.SetUpdateSkillBtn(self, i)
			end
		end
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.IsDodgeDisable = function(self, state)
	if state ~= ParkourStateConfig.WingsuitFly or state ~= ParkourStateConfig.WalkPhone or state ~= ParkourStateConfig.Dive or state ~= ParkourStateConfig.HasEarphone then
		return true
	end

	return false
end

M.HasDodgeDisableState = function(self)
	local disableState = false

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		disableState = disableState or self:IsDodgeDisable(state)
	end

	return disableState
end

M.CheckIsBanFunGun = function(self)
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.Moto) then
		return true
	end

	return false
end

M.OnDodgeBtnPressFunc = function(self)
	if gameProfile.auxiliaryCombatMode and self.canCounter and self.threatLevel < 2 then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.HeavyAttack)

		return
	end

	self._isDodgePressed = true
	self._dodgePressStartTime = Time.time

	if self._confrontShiftUnlocked then
		self._StartConfrontDodgeTimer(self)
	end

	self.HighSpeedDown(self)

	if gUnitOperateManager.isOnJoystickMove then
		gCS.MotionFlagManager.SetTempMotionFlag(gCS.MyPlayerManager.PlayerUnit, 9)
	end

	if gBattleMgr.isBattleUI or not gUnitOperateManager.isOnJoystickMove then
		if not gPlayerManager.main.bindData.isInSlideRail and not gPlayerManager.main.bindData.isFreeClimbing then
			local isOk = false

			if gBattleMgr.IsUseNewCombo then
				isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonClick)
			end

			if not isOk and not self.CheckIsBanFunGun(self) then
				isOk = gCS.BattleManager.UseSkillByPid(gCS.MyPlayerManager.PlayerUnit.Pid, gCS.BattleManager.GetDodgeSkillID(), -1, ClientEventConfig.DodgeButtonClick)
			end

			if isOk then
				return
			end
		end

		local ok = gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)

		if not ok then
			gCS.SaveActionManager.Instance:CheckSaveAction(gCS.MyPlayerManager.PlayerUnit, self.SaveActionType.Dodge)
		end
	end
end

M.OnDodgeBtnReleaseFunc = function(self)
	if gameProfile.auxiliaryCombatMode and self.canCounter and self.threatLevel < 2 then
		gCS.SceneBattleBtnMgr.OnBattleBtnLongPressEnd(gBattleMgr.SkillBtnType.HeavyAttack)

		return
	end

	self._isDodgePressed = false

	self._StopConfrontDodgeTimer(self)
	self.HighSpeedUp(self)
	gCS.MotionFlagManager.ClearTempMotionFlag(gCS.MyPlayerManager.PlayerUnit)

	if not gPlayerManager.main.bindData.isInSlideRail and not gPlayerManager.main.bindData.isFreeClimbing then
		local isOk = false

		if gBattleMgr.IsUseNewCombo then
			local elapsedTime = Time.time - self._dodgePressStartTime
			local shortUpTime = WeaponShootConfig.DodgeShortUpTime

			if self._dodgePressStartTime <= 0 and elapsedTime < shortUpTime then
				local fightStyleId = gCS.FightStyleManager.Instance:GetCurrentWeaponFightStyleId()

				if fightStyleId and fightStyleId <= 0 then
					local fightStyleCfg = LTConfig.FightSkillConfig.GetConfig(fightStyleId)

					if fightStyleCfg and fightStyleCfg.DodgeShortUpSkill and fightStyleCfg.DodgeShortUpSkill <= 0 then
						isOk = gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonClick, fightStyleCfg.DodgeShortUpSkill)
					end
				end
			end

			isOk = isOk or gCS.SkillJumpManager.Instance:CheckSkillJump(gCS.MyPlayerManager.PlayerUnit.Pid, ClientEventConfig.DodgeButtonUp)
		end

		if isOk then
			return
		end
	end

	if gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
		gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)
	end
end

M._OnJoystickStateChange = function(self)
	if not self._isDodgePressed then
		return
	end

	if gUnitOperateManager.isOnJoystickMove then
		gCS.MotionFlagManager.SetTempMotionFlag(gCS.MyPlayerManager.PlayerUnit, 9)
	else
		gCS.MotionFlagManager.ClearTempMotionFlag(gCS.MyPlayerManager.PlayerUnit)
	end
end

M.CheckCanShowUniqueSkillInfo = function(self, skillId)
	local cfg = SkillConfig.GetConfig(skillId)

	if not cfg then
		return false
	end

	if cfg.SkillCastTypeTag == SkillConfig.SkillCastTypeTagType.Unique then
		return false
	end

	return true
end

M.HighSpeedDown = function(self)
	gCS.TransitionMgr.isHightSpeedDown = true
	gCS.TransitionMgr.isHightSpeedDownNow = true

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
		gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashPress)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.DashPress)

	gCS.TransitionMgr.isHightSpeedDownNow = false
end

M.HighSpeedUp = function(self)
	gCS.TransitionMgr.isHightSpeedDown = false

	if gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
		gCS.TransitionMgr.isHightSpeedUp = true

		gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)

		gCS.TransitionMgr.isHightSpeedUp = false
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.DashRelease)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, LTConfig.ABPCCCEventConfig.DashRelease)
end

M._ForEach = function(self, cb)
	for _, unit in ipairs(self._enumeratingUnits) do
		cb(unit)
	end
end

M.ForEach = function(self, cb)
	table.clear(self._enumeratingUnits)
	gCS.SceneDataMgr.UnitsManager:LuaGetAllUnits(self._enumeratingUnits)
	xpcall(M._ForEach, tolua.traceback, self, cb)
	table.clear(self._enumeratingUnits)
end

M.StiffTransitionConfig = function(self, transitionCondition, pid)
	return gHurtStiffManager:DoCheckConfig(transitionCondition)
end

M.OnBVBAttackSpeedChange = function(self, pid, value)
	if gBattlePetsMgr and gBattlePetsMgr.bInBVBGame and gBattlePetsMgr.bInBVBGame ~= true then
		gCS.PauseManager.Instance:OnBVBAttackSpeedChange(pid, value)
	end
end

M.SetEnemyPoiseWeaponChangeInfo = function(self, pid, values)
	self.enemyPoiseWeaponChangeInfo[pid] = values
end

M.GetEnemyPoiseWeaponChangeInfo = function(self, pid, weaponInstanceId)
	if self.enemyPoiseWeaponChangeInfo[pid] and self.enemyPoiseWeaponChangeInfo[pid][weaponInstanceId] then
		return self.enemyPoiseWeaponChangeInfo[pid][weaponInstanceId]
	end

	return 0
end

M.CalcEnemyDangerValue = function(self, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		return false
	end

	local enemyFightingPara = 0
	local agentId = unit.ClientData.AgentId <= 0 and unit.ClientData.AgentId or unit.ClientData.SubType
	local cfg = LTConfig.AgentConfig.GetConfig(agentId)
	local growthCfg = LTConfig.EnemyGrowthSchemeConfig.GetConfig(cfg.AttributeSchemeId)
	enemyFightingPara = growthCfg.FightScore
	local myFightScore = gCS.BattleManager.GetMyFightPower()

	return myFightScore <= enemyFightingPara
end

M.GetInitBulletId = function(self, weaponShootId)
	local cfg = WeaponShootConfig.GetConfig(weaponShootId)

	if cfg and cfg.SeparateBullets and not table.isNilOrEmpty(cfg.AppropriateBullets) then
		for i = 1, #cfg.AppropriateBullets do
			local bulletId = cfg.AppropriateBullets[i]
			local count = gCommonItemManager:GetPackItemNum(bulletId)

			if count <= 0 then
				return bulletId, count
			end
		end

		return cfg.AppropriateBullets[1], 0
	end

	return 0, 0
end

M.SetIsInTaiChiSword = function(self, enable)
	local panel = self.characterPartPanel

	if not panel then
		return
	end

	if enable then
		panel.OnEnterBurstState(panel)
	else
		panel.OnExitBurstState(panel)
	end
end

M.CombatConfrontPressShiftUnlockEnter = function(self, duration)
	self._confrontShiftUnlocked = true
	self._confrontShiftDuration = duration

	if self._isDodgePressed then
		self._StartConfrontDodgeTimer(self)
	end
end

M.CombatConfrontPressShiftUnlockExit = function(self)
	self._confrontShiftUnlocked = false

	self._StopConfrontDodgeTimer(self)
end

M._StartConfrontDodgeTimer = function(self)
	self._StopConfrontDodgeTimer(self)

	if self._confrontShiftDuration < 0 then
		gCS.LockTargetMgr:ResetStrongLockFromStateTree()

		return
	end

	self._confrontDodgeTimer = Timer.New(function ()
		self._confrontDodgeTimer = nil

		gCS.LockTargetMgr:ResetStrongLockFromStateTree()
	end, self._confrontShiftDuration):Start()
end

M._StopConfrontDodgeTimer = function(self)
	if self._confrontDodgeTimer then
		self._confrontDodgeTimer:Stop()

		self._confrontDodgeTimer = nil
	end
end

M.ShowSaiMoLock = function(self, show)
	local store = gStoreManager:GetStoreGroup("HintInfosHudStore")

	store:ShowSaiMoLock(show)
end

M.ShowSaiMoHackerGunPuzzle = function(self, show)
	if show then
		gPanelManager:CheckShow(gPanelId.SAI_MO_WEAPON_PANEL)
	else
		gPanelManager:Close(gPanelId.SAI_MO_WEAPON_PANEL)
	end
end

M.GMCoreHudNewDodge = function(self, useNewDodge)
	self.isUseNewDodge = useNewDodge
end

M.GMCoreHudNewMoto = function(self, useNewMoto)
	self.isUseNewMoto = useNewMoto
end

gBattleMgr = M
