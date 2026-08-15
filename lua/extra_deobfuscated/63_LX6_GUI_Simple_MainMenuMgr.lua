local DataSet = require("LX6/DataBind/DataSet")
local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local UnitState = UX.Game.TwoDimConfig.UnitState
local ParkourStateConfig = LTConfig.ParkourStateConfig
local ParkourStateButtonInfoConfig = LTConfig.ParkourStateButtonInfoConfig
local SkillConfig = LTConfig.SkillConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local MindButtonTypeType = LTConfig.BattleMindPowerInteractConfig.MindButtonTypeType
local ButtonInfoEnum = LX6.Units.Module.ButtonInfoEnum
local WeaponConfig = LTConfig.WeaponConfig

if not gMainMenuMgr then
	local M = {
		hideHUDTimer = 0,
		HALF_ALPHA = 0.5,
		extraVisiable = DataSet.New({
			isInDeadS = false
		}),
		onAwakeUI = DataSet.New({
			awakeSimpleQuickMenuPanel = 0,
			UniqueSkillProtagonistStore = 0,
			awakeBattlePanel = 0,
			awakeBossViewPanel = 0
		}),
		taskAndTeamState = DataSet.New({
			isShowTeam = false,
			isShowTask = true
		}),
		defaultDelayTime = GameConfig.PCBattleUIHideTime,
		unlockSystems = {},
		idealState = {
			true,
			true
		},
		checkBtnInfoList = {},
		hpUIVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			Count = 4
		}),
		jumpUIVisiable = DataSet.New({
			-1,
			0,
			Count = 3,
			[3.0] = 0
		}),
		hackerScanVisiable = DataSet.New({
			1,
			-1,
			-1,
			0,
			Count = 5,
			[5.0] = 0
		}),
		rightBottomVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			0,
			0,
			Count = 6
		}),
		chatSimpleUIVisiable = DataSet.New({
			0,
			0,
			Count = 3,
			[3.0] = 0
		}),
		deviceStatusUIVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		deviceStatusBtnUIVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		bossViewPanelUIVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		miniMapNewPanelUIVisiable = DataSet.New({
			0,
			0,
			Count = 3,
			[3.0] = 0
		}),
		taskGuideVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		battleUIVisiable = DataSet.New({
			1,
			-1,
			0,
			0,
			Count = 5,
			[5.0] = 0
		}),
		battleSkill1UIVisiable = DataSet.New({
			1,
			0,
			0,
			0,
			1,
			0,
			0,
			1,
			1,
			0,
			0,
			Count = 11
		}),
		hideRushOrJumpBtnsVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		clientState = DataSet.New({
			parkourState = {}
		}),
		comboSkill = DataSet.New({
			0,
			0,
			0,
			0,
			Count = 4,
			[5.0] = 0
		}),
		triggerDisableBattleSkillUIVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			Count = 8,
			[9.0] = 0
		}),
		triggerDisableParkourUIVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		uiHideInUnBattleState = DataSet.New({
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			Count = 10
		}),
		btnAssassinateVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			Count = 4
		}),
		clientStateConfig = {},
		clientStateCache = DataSet.New({
			1,
			1,
			1,
			2,
			1,
			1,
			1,
			1,
			0,
			0,
			0,
			0,
			1,
			1,
			1,
			1,
			1,
			1,
			1,
			0,
			Count = 20
		}),
		clientStateCacheType = {
			OffWall = 10,
			Skill = 2,
			MindPower = 4,
			JumpJump = 7,
			Dodge = 6,
			NormalAttack = 1,
			Magnet = 11,
			DiveBtnInfo = 18,
			UltSkill = 3,
			MagnetPutDown = 12,
			Assassin = 9,
			HandBagPutDown = 16,
			AirDash_mobile = 17,
			SwitchWeaponWheels = 15,
			Grapple = 8,
			Hp = 13,
			SwitchCharacterWheels = 14,
			HeavyAttack = 5
		},
		clientStateName = {
			MindPower = 7,
			JumpJump = 6,
			Dodge = 5,
			MindPower_Destructible_Three = 10,
			MindPower_Destructible_One = 8,
			NormalAttack = 1,
			Magnet = 14,
			Skill = 3,
			SwitchWeaponWheels = 18,
			DiveBtnInfo = 19,
			UltSkill = 4,
			MagnetPutDown = 15,
			Assassin = 12,
			MotionAction = 21,
			TaFeiMoto = 22,
			Hold_E = 24,
			Hold_R = 25,
			Phone_ShortCuts = 26,
			Hack = 27,
			HandBagPutDown = 16,
			AirDash_mobile = 20,
			OffWall = 13,
			Grapple = 11,
			Hp = 17,
			Hold_Left = 23,
			MindPower_Destructible_Two = 9,
			HeavyAttack = 2
		},
		parkourStateButtonInfoType = LX6.Units.Module.ButtonInfoEnum,
		parkourStateButtonRef = {
			[ButtonInfoEnum.NormalAttack] = "normalAttackBtn",
			[ButtonInfoEnum.HeavyAttack] = "heavyAttackBtn",
			[ButtonInfoEnum.Skill] = "basicSkillBtnGo",
			[ButtonInfoEnum.UltSkill] = "ultSkillBtnGo",
			[ButtonInfoEnum.Dodge] = "dodgeBtn",
			[ButtonInfoEnum.JumpJump] = "jumpSwingBtn",
			[ButtonInfoEnum.MindPower] = "mindPowerBtn",
			[ButtonInfoEnum.Grapple] = "grappleBtn",
			[ButtonInfoEnum.OffWall] = "dropBtn",
			[ButtonInfoEnum.Magnet] = "magnetBtn",
			[ButtonInfoEnum.MagnetPutDown] = "putDownBtn",
			[ButtonInfoEnum.HandBagPutDown] = "handBagPutDownBtn",
			[ButtonInfoEnum.DiveBtnInfo] = "ctrlButton",
			[ButtonInfoEnum.EBtnInfo] = "basicNormalBtnGo",
			[ButtonInfoEnum.RBtnInfo] = "ultNormalBtnGo",
			[ButtonInfoEnum.TaFeiMoto] = "motoBtn",
			[ButtonInfoEnum.Hold_Left] = "holdLeftBtn",
			[ButtonInfoEnum.Hold_E] = "holdEBtn",
			[ButtonInfoEnum.Hold_R] = "holdRBtn"
		},
		parkourStateButtonInfoIndex = {
			[ButtonInfoEnum.NormalAttack] = 5,
			[ButtonInfoEnum.HeavyAttack] = 10,
			[ButtonInfoEnum.Skill] = 13,
			[ButtonInfoEnum.UltSkill] = 11,
			[ButtonInfoEnum.Dodge] = 2,
			[ButtonInfoEnum.JumpJump] = 1,
			[ButtonInfoEnum.MindPower] = -1,
			[ButtonInfoEnum.Grapple] = -1,
			[ButtonInfoEnum.OffWall] = -1,
			[ButtonInfoEnum.Magnet] = 4,
			[ButtonInfoEnum.MagnetPutDown] = 3,
			[ButtonInfoEnum.HandBagPutDown] = -1,
			[ButtonInfoEnum.DiveBtnInfo] = -1,
			[ButtonInfoEnum.EBtnInfo] = -1,
			[ButtonInfoEnum.RBtnInfo] = -1,
			[ButtonInfoEnum.TaFeiMoto] = 1,
			[ButtonInfoEnum.Hold_Left] = -1,
			[ButtonInfoEnum.Hold_R] = -1,
			[ButtonInfoEnum.Hold_E] = -1
		},
		parkourStateButtonInitInfoCache = {},
		parkourStateButtonInitTipStateCachePC = {},
		parkourStateButtonInitTipStateCacheController = {},
		wallJumpOffBtnVisable = DataSet.New({
			0,
			0,
			Count = 3,
			[3.0] = 0
		}),
		weaponFightResVisiable = DataSet.New({
			0,
			0,
			Count = 3,
			[3.0] = 0
		}),
		kickOffBtnVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		spiderBotExitBtnVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		charEnergyVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		airDashVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			Count = 4
		}),
		professionalSkillBtnVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		}),
		handBagPutDownBtnVisiable = DataSet.New({
			Count = 1,
			[1.0] = 0
		})
	}
end

function M:InitBindDta()
	local stateHideBattleButton = self:HasUnitState(UnitStateConfig.HideBattleButton)
	local stateDeadS = self:HasUnitState(UnitStateConfig.DeadS)
	local stateHideBattleUI = self:HasUnitState(UnitStateConfig.HideBattleUI)
	local stateHidePlayerHp = self:HasUnitState(UnitStateConfig.HidePlayerHp)
	local stateHideHackScan = 0
	local stateHidechatSimpleQuick = self:HasUnitState(UnitStateConfig.HideMiniChat)
	local stateHideDeviceStatus = self:HasUnitState(UnitStateConfig.HideDeviceStatus)
	local stateHideBossView = self:HasUnitState(UnitStateConfig.HideBossView)
	local stateHideMiniMap = self:HasUnitState(UnitStateConfig.HideMiniMap)
	local stateHideRushOrJump = self:HasUnitState(UnitStateConfig.HideBattleUIJump)
	local stateCharacterFight = self:HasUnitState(UnitStateConfig.FightS)
	local eventForbidJumpButton = 0
	local me = gCS.MyPlayerManager.PlayerUnit

	if me and me.CanUseRes then
		if gCS.MyPlayerManager.CheckEventForbidden(UnitState.JumpEvent, true) then
			eventForbidJumpButton = 1
		else
			eventForbidJumpButton = 0
		end
	end

	self.onAwakeUI.awakeBattlePanel = 0
	self.onAwakeUI.awakeSimpleQuickMenuPanel = 0
	self.onAwakeUI.awakeBossViewPanel = 0
	self.extraVisiable.isInDeadS = self:HasUnitStateBool(UnitStateConfig.DeadS)

	self:SetTableVisible(self.battleUIVisiable, 1, 1)
	self:SetTableVisible(self.battleUIVisiable, 2, -1)
	self:SetTableVisible(self.battleUIVisiable, 3, stateHideBattleUI)
	self:SetTableVisible(self.battleUIVisiable, 4, 1)
	self:SetTableVisible(self.battleUIVisiable, 5, stateDeadS)
	self:SetTableVisible(self.battleSkill1UIVisiable, 11, 0)
	self:SetTableVisible(self.hpUIVisiable, 1, stateHidePlayerHp)
	self:SetTableVisible(self.hpUIVisiable, 2, stateDeadS)
	self:SetTableVisible(self.hpUIVisiable, 3, -1)
	self:SetTableVisible(self.hpUIVisiable, 4, 1)
	self:SetTableVisible(self.jumpUIVisiable, 1, -1)
	self:SetTableVisible(self.jumpUIVisiable, 2, eventForbidJumpButton)
	self:SetTableVisible(self.jumpUIVisiable, 3, gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Jump) and 1 or 0)
	self:SetTableVisible(self.hackerScanVisiable, 1, 1)
	self:SetTableVisible(self.hackerScanVisiable, 2, stateHideHackScan)
	self:SetTableVisible(self.hackerScanVisiable, 3, -1)
	self:SetTableVisible(self.hackerScanVisiable, 5, gCS.LuaUtils.IsNonMobileAdaptive() and 0 or 1)
	self:SetTableVisible(self.rightBottomVisiable, 1, stateDeadS)
	self:SetTableVisible(self.rightBottomVisiable, 2, stateHideBattleButton)
	self:SetTableVisible(self.rightBottomVisiable, 3, 0)
	self:SetTableVisible(self.rightBottomVisiable, 4, 0)
	self:SetTableVisible(self.rightBottomVisiable, 6, 0)
	self:SetTableVisible(self.chatSimpleUIVisiable, 2, stateHidechatSimpleQuick)
	self:SetTableVisible(self.deviceStatusUIVisiable, 1, stateHideDeviceStatus)
	self:SetTableVisible(self.deviceStatusBtnUIVisiable, 1, 0)
	self:SetTableVisible(self.bossViewPanelUIVisiable, 1, stateHideBossView)
	self:SetTableVisible(self.miniMapNewPanelUIVisiable, 1, -1)
	self:SetTableVisible(self.miniMapNewPanelUIVisiable, 2, stateHideMiniMap)
	self:SetTableVisible(self.miniMapNewPanelUIVisiable, 3, 1)
	self:SetTableVisible(self.taskGuideVisiable, 1, -1)
	self:SetTableVisible(self.hideRushOrJumpBtnsVisiable, 1, stateHideRushOrJump)
	self:SetTableVisible(self.clientState, "parkourState", {})
	self:SetTableVisible(self.triggerDisableParkourUIVisiable, 1, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 1, stateCharacterFight)
	self:SetTableVisible(self.uiHideInUnBattleState, 2, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 3, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 4, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 5, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 6, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 7, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 8, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 9, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 10, 0)
	self:SetTableVisible(self.uiHideInUnBattleState, 11, 0)
	self:SetTableVisible(self.clientStateCache, 1, 1)
	self:SetTableVisible(self.clientStateCache, 2, 1)
	self:SetTableVisible(self.clientStateCache, 3, 1)
	self:SetTableVisible(self.clientStateCache, 4, 2)
	self:SetTableVisible(self.clientStateCache, 5, 1)
	self:SetTableVisible(self.clientStateCache, 6, 1)
	self:SetTableVisible(self.clientStateCache, 7, 1)
	self:SetTableVisible(self.clientStateCache, 8, 1)
	self:SetTableVisible(self.clientStateCache, 9, 0)
	self:SetTableVisible(self.clientStateCache, 10, 0)
	self:SetTableVisible(self.clientStateCache, 11, 0)
	self:SetTableVisible(self.clientStateCache, 12, 0)
	self:SetTableVisible(self.clientStateCache, 13, 1)
	self:SetTableVisible(self.clientStateCache, 14, 1)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 1, 1)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 2, gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Drop) and 1 or 0)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 3, 1)
	self:SetTableVisible(self.weaponFightResVisiable, 1, 0)
	self:SetTableVisible(self.weaponFightResVisiable, 2, 0)
	self:SetTableVisible(self.weaponFightResVisiable, 3, gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.Jump) and 1 or 0)
	self:SetTableVisible(self.kickOffBtnVisiable, 1, 0)
	self:SetTableVisible(self.spiderBotExitBtnVisiable, 1, 0)
	self:SetTableVisible(self.charEnergyVisiable, 1, 0)
	self:SetTableVisible(self.airDashVisiable, 1, 0)
	self:SetTableVisible(self.airDashVisiable, 2, me and gBuffUtils.HasBuff(me.Pid, LTConfig.BuffConfig.CanAirDash) and 1 or 0)
	self:SetTableVisible(self.airDashVisiable, 3, gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.AirCrush) and 1 or 0)
	self:SetTableVisible(self.airDashVisiable, 4, gMapManager.IndoorId and gMapManager.IndoorId > 0 and 1 or 0)
	self:SetTableVisible(self.professionalSkillBtnVisiable, 1, 0)
	self:SetTableVisible(self.handBagPutDownBtnVisiable, 1, 0)
end

function M:OnInit()
	self:InitClientStateConfig()
	gMessageManager:AddMessageListener(gEventConstants.DEVICES_MORE_PANEL_MESSAGE, self.OnCheckDevicesMorePanel)
	gMessageManager:AddMessageListener(gEventConstants.UI_RESET, self.OnResetUI)
	gMessageManager:AddMessageListener(gEventConstants.LOADING_FINISHED, self.OnLoadingFinish)
	gMessageManager:AddMessageListener(gEventConstants.CHANGE_MY_UNIT, self.OnChangeUnit)
	gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY, self.OnChangeIndoorMap)
	gMessageManager:AddMessageListener(gEventConstants.PAOKU_STATE_CHANGE, function ()
		self:OnParkourStateChange()
	end)
	gMessageManager:AddMessageListener(gEventConstants.PARKOUR_CLIENT_STATE_REFRESH, function (event, data)
		local state = data.state

		if not self.clientStateCache[state] then
			return
		end

		self.clientStateCache[state] = self.clientStateCache[state] >= 10000 and 0 or self.clientStateCache[state] + 1
	end)
	gMessageManager:AddMessageListener(gEventConstants.CAST_SKILL, function (event, data)
		self:CheckIsFightState()
	end)
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SKILL_END, function (event, data)
		self:CheckIsFightState()
	end)
end

function M.OnCheckDevicesMorePanel(eventId, data)
	local isOpen = data

	M:SetTableVisible(M.chatSimpleUIVisiable, 3, isOpen and 1 or 0)
end

function M.OnResetUI()
	M:RegisterVisiableRules()
	M:SetAwakeUI("awakeSimpleQuickMenuPanel")
	M:SetAwakeUI("awakeBattlePanel")
end

function M.OnLoadingFinish()
	M:SetUnLockSystems()
end

function M.OnChangeUnit(eventId, msg)
	gMainMenuMgr:SetBtnVisibleByBuff(msg)
end

function M.OnChangeIndoorMap()
	local inDoor = gMapManager.IndoorId and gMapManager.IndoorId > 0

	M:SetTableVisible(M.airDashVisiable, 4, inDoor and 1 or 0)
end

function M:OnBeforeSwitchScene(switchType)
	self:InitClientStateConfig()

	local isReconnect = switchType == gSwitchSceneType.Reconnect

	if not isReconnect and M.eventSet then
		M:RegisterVisiableRules()
	end

	M.taskAndTeamState.isShowTask = true
	M.taskAndTeamState.isShowTeam = false

	if switchType == gSwitchSceneType.KickToLogin then
		self:InitBindDta()
	end
end

function M:RegisterVisiableRules()
	self:InitBindDta()
	self:RegisterBindHandlersOnce()
end

function M:RegisterBindHandlersOnce()
	if self.eventSet then
		self.eventSet:Destroy()
	end

	self.eventSet = C_DataEventSet.New()

	self.eventSet:BindHandler(gRaidDataManager, "RaidId", self.bindHandlers.OnRefreshRaidId)
	self.eventSet:BindHandler2({
		self.jumpUIVisiable,
		1,
		self.jumpUIVisiable,
		2,
		self.jumpUIVisiable,
		3,
		gPlayerManager.main.bindData,
		"isInZipLine",
		gPlayerManager.main.bindData,
		"isInLift",
		self.hideRushOrJumpBtnsVisiable,
		1,
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.JumpJump,
		self.triggerDisableParkourUIVisiable,
		1
	}, self.bindHandlers.OnRefreshJumpUIVisiable)
	self.eventSet:BindHandler2({
		gPlayerManager.main.bindData,
		"isInSkillQTE",
		self.onAwakeUI,
		"awakeSimpleQuickMenuPanel",
		self.clientStateCache,
		self.clientStateCacheType.Hp,
		self.hpUIVisiable,
		1,
		self.hpUIVisiable,
		2,
		self.hpUIVisiable,
		3,
		self.hpUIVisiable,
		4
	}, self.bindHandlers.OnRefreshHpUIVisiable)
	self.eventSet:BindHandler2({
		self.rightBottomVisiable,
		1,
		self.rightBottomVisiable,
		2,
		self.rightBottomVisiable,
		3,
		self.rightBottomVisiable,
		4,
		self.rightBottomVisiable,
		5,
		self.rightBottomVisiable,
		6,
		self.onAwakeUI,
		"awakeSimpleQuickMenuPanel",
		self.onAwakeUI,
		"awakeBattlePanel"
	}, self.bindHandlers.OnRefreshRightBottomVisiable)
	self.eventSet:BindHandler2({
		self.deviceStatusUIVisiable,
		1,
		gPlayerManager.main.bindData,
		"UIStyle"
	}, self.bindHandlers.OnRefreshDeviceStatusUIVisiable)
	self.eventSet:BindHandler2({
		self.bossViewPanelUIVisiable,
		1,
		self.onAwakeUI,
		"awakeBossViewPanel"
	}, self.bindHandlers.OnRefreshBossViewPanelUIVisiable)
	self.eventSet:BindHandler2({
		self.miniMapNewPanelUIVisiable,
		1,
		self.miniMapNewPanelUIVisiable,
		2,
		self.miniMapNewPanelUIVisiable,
		3
	}, self.bindHandlers.OnRefreshMiniMapNewPanelUIVisiable)
	self.eventSet:BindHandler2({
		self.battleUIVisiable,
		1,
		self.battleUIVisiable,
		2,
		self.battleUIVisiable,
		3,
		self.battleUIVisiable,
		4,
		self.battleUIVisiable,
		5,
		self.onAwakeUI,
		"awakeBattlePanel"
	}, self.bindHandlers.OnRefreshBattleUIVisiable)
	self.eventSet:BindHandler2({
		self.uiHideInUnBattleState,
		1,
		self.uiHideInUnBattleState,
		2,
		self.uiHideInUnBattleState,
		3,
		self.uiHideInUnBattleState,
		4,
		self.uiHideInUnBattleState,
		5,
		self.uiHideInUnBattleState,
		6,
		self.uiHideInUnBattleState,
		7,
		self.uiHideInUnBattleState,
		8,
		self.uiHideInUnBattleState,
		9,
		self.uiHideInUnBattleState,
		10,
		gPlayerManager.main.bindData,
		"isMindPowerAim",
		gPlayerManager.main.bindData,
		"isInMagnetHold",
		self.onAwakeUI,
		"awakeSimpleQuickMenuPanel",
		self.onAwakeUI,
		"awakeBattlePanel"
	}, self.bindHandlers.OnHideInUnBattleState)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.Grapple,
		self.triggerDisableParkourUIVisiable,
		1
	}, self.bindHandlers.OnRefreshFeiSuo)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.JumpJump
	}, self.bindHandlers.OnRefreshHighSpeed)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.Magnet,
		gPlayerManager.main.bindData,
		"isInHoldEnemy"
	}, self.bindHandlers.OnRefreshMagnet)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.wallJumpOffBtnVisable,
		1,
		self.wallJumpOffBtnVisable,
		2,
		self.wallJumpOffBtnVisable,
		3,
		self.triggerDisableParkourUIVisiable,
		1,
		self.clientStateCache,
		self.clientStateCacheType.OffWall
	}, self.bindHandlers.OnRefreshWallJumpOff)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.MagnetPutDown
	}, self.bindHandlers.OnRefreshMagnetPutDown)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.SwitchCharacterWheels
	}, self.bindHandlers.OnRefreshCharacterWheelsVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.weaponFightResVisiable,
		1,
		self.weaponFightResVisiable,
		2,
		self.weaponFightResVisiable,
		3
	}, self.bindHandlers.OnRefreshWeaponFightResVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.kickOffBtnVisiable,
		1
	}, self.bindHandlers.OnRefreshKickOffBtnVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.spiderBotExitBtnVisiable,
		1
	}, self.bindHandlers.OnRefreshSpiderBotExitBtnVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.charEnergyVisiable,
		1
	}, self.bindHandlers.OnRefreshCharEnergyVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.onAwakeUI,
		"UniqueSkillProtagonistStore",
		self.airDashVisiable,
		1,
		self.airDashVisiable,
		2,
		self.airDashVisiable,
		3,
		self.airDashVisiable,
		4,
		self.clientStateCache,
		self.clientStateCacheType.AirDash_mobile
	}, self.bindHandlers.OnRefreshAirDashVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.professionalSkillBtnVisiable,
		1
	}, self.bindHandlers.OnRefreshProfessionalSkillBtnVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.handBagPutDownBtnVisiable,
		1,
		self.clientStateCache,
		self.clientStateCacheType.HandBagPutDown
	}, self.bindHandlers.OnRefreshHandBagPutDownBtnVisiable)
	self.eventSet:BindHandler2({
		self.onAwakeUI,
		"awakeBattlePanel",
		self.clientStateCache,
		self.clientStateCacheType.DiveBtnInfo
	}, self.bindHandlers.OnRefreshDiveControlBtnVisible)
end

M.bindHandlers = {
	OnRefreshRaidId = function (cell)
		local raidId = cell.value
		local raidCfg = RaidConfig.GetConfig(raidId)

		if raidCfg then
			local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
			local showBattleUI = raidTypeConfig.showBattleUI

			M:SetTableVisible(M.battleUIVisiable, 2, showBattleUI)
			M:SetTableVisible(M.jumpUIVisiable, 1, raidTypeConfig.hideUIJump)
			M:SetTableVisible(M.miniMapNewPanelUIVisiable, 1, raidTypeConfig.hideUIMiniMap)
			M:SetTableVisible(M.taskGuideVisiable, 1, raidTypeConfig.hideTaskList)
			M:SetTableVisible(M.chatSimpleUIVisiable, 1, raidTypeConfig.hideUIMiniChat)
			M:SetTableVisible(M.deviceStatusBtnUIVisiable, 1, raidTypeConfig.hideBtnUIVisiable)
		end
	end,
	OnRefreshBattleUIVisiable = function (cell)
		for i = 1, M.battleUIVisiable.Count do
			local state = M.battleUIVisiable[i]

			if i == 1 and state == 0 or i == 2 and state == -1 or i == 3 and state == 1 or i == 4 and state == 0 or i == 5 and state == 1 then
				gBattleMgr:SetBattlePanelActive(false, false)

				return
			end
		end

		gBattleMgr:SetBattlePanelActive(true, true)
		M:HideUIInUnBattleState(true)
	end,
	OnRefreshJumpUIVisiable = function (cell)
		if gBattleMgr:GetBattlePanel() then
			local uiDisplayState = 0
			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				local jumpConfig = gMainMenuMgr.clientStateConfig[state].JumpJump

				if type(jumpConfig) == "table" and jumpConfig[platform] and not jumpConfig[platform].visible and not jumpConfig[platform].interactable and uiDisplayState < 2 then
					uiDisplayState = 2

					M:ShowMainMenuMgrMessageTipsOnEditor("跑酷状态禁用跳跃:", state)
				end
			end

			for i = 1, M.jumpUIVisiable.Count do
				local state = M.jumpUIVisiable[i]

				if i == 1 and state == 2 or i == 2 and state == 1 or gPlayerManager.main.bindData.isInZipLine then
					if uiDisplayState < 1 then
						uiDisplayState = 1

						M:ShowMainMenuMgrMessageTipsOnEditor("跳跃禁用: index:", i, "state:", state, "inzipline:", gPlayerManager.main.bindData.isInZipLine)
					end
				elseif i == 3 and state == 0 and uiDisplayState < 2 then
					uiDisplayState = 2

					M:ShowMainMenuMgrMessageTipsOnEditor("跳跃禁用: index:", i, "state:", state)
				end
			end

			for i = 1, M.hideRushOrJumpBtnsVisiable.Count do
				local state = M.hideRushOrJumpBtnsVisiable[i]

				if state == 1 and uiDisplayState < 1 then
					uiDisplayState = 1

					M:ShowMainMenuMgrMessageTipsOnEditor("跳跃禁用: index:", i, "state:", state)
				end
			end

			if (gPlayerManager.main.bindData.isInLift or gPaokuLimitManager:CheckInDisableJump()) and uiDisplayState < 2 then
				uiDisplayState = 2

				M:ShowMainMenuMgrMessageTipsOnEditor("跳跃禁用 isInLift")
			end

			if uiDisplayState == 1 then
				gBattleMgr:SetJumpBtnAlphaAndColliderEnable(false, false)
				gBattleMgr:SetJumpBtnActive(true, true)
				M:ShowMainMenuMgrMessageTipsOnEditor("跳跃按钮半透", uiDisplayState)

				return
			elseif uiDisplayState == 2 then
				gBattleMgr:SetJumpBtnAlphaAndColliderEnable(false, false)
				gBattleMgr:SetJumpBtnActive(false, false)
				M:ShowMainMenuMgrMessageTipsOnEditor("跳跃按钮隐藏", uiDisplayState)

				return
			end

			gBattleMgr:SetJumpBtnAlphaAndColliderEnable(true, true)
			gBattleMgr:SetJumpBtnActive(true, true)
		end
	end,
	OnRefreshHpUIVisiable = function (cell)
		if gBattleMgr.characterPartPanel then
			for i = 1, M.hpUIVisiable.Count do
				local state = M.hpUIVisiable[i]

				if (i == 1 or i == 2) and state == 1 or (i == 3 or i == 4) and state == 0 then
					gBattleMgr:SetCharacterHpActive(false)
					M:ShowMainMenuMgrMessageTipsOnEditor("隐藏血条: index:", i, "state:", state)

					return
				end
			end

			if gPlayerManager.main.bindData.isInSkillQTE then
				gBattleMgr:SetCharacterHpActive(false)
				M:ShowMainMenuMgrMessageTipsOnEditor("长按念力、QTE下隐藏血条:", gPlayerManager.main.bindData.isInSkillQTE, " uiDisplayState:")

				return
			end

			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				local hpConfig = gMainMenuMgr.clientStateConfig[state].Hp

				if type(hpConfig) == "table" and hpConfig[platform] and not hpConfig[platform].visible then
					gBattleMgr:SetCharacterHpActive(false)
					M:ShowMainMenuMgrMessageTipsOnEditor("跑酷状态隐藏血条:", state)

					return
				end
			end

			gBattleMgr:SetCharacterHpActive(true)
		end
	end,
	OnRefreshRightBottomVisiable = function (cell)
		for i = 1, M.rightBottomVisiable.Count do
			local state = M.rightBottomVisiable[i]

			if state == 1 then
				gBattleMgr:SetGoBottomRightActive(false, false)
				M:ShowMainMenuMgrMessageTipsOnEditor("隐藏右下角那坨按钮，index:", i, "state:", state)

				return
			end

			if i == 3 and state > 0 then
				gBattleMgr:SetGoBottomRightActive(false, false)
				M:ShowMainMenuMgrMessageTipsOnEditor("隐藏右下角那坨按钮，index:", i, "state:", state)

				return
			end
		end

		gBattleMgr:SetGoBottomRightActive(true, true)
	end,
	OnRefreshDeviceStatusUIVisiable = function (cell)
		for i = 1, M.deviceStatusUIVisiable.Count do
			local state = M.deviceStatusUIVisiable[i]

			if i == 1 and state == 1 then
				gMessageManager:SendMessage(gEventConstants.SHOW_DEVICE_STATUS_PANEL, false)

				return
			end
		end

		gMessageManager:SendMessage(gEventConstants.SHOW_DEVICE_STATUS_PANEL, true)
	end,
	OnRefreshBossViewPanelUIVisiable = function (cell)
		if gLuaUIMgr.bossViewPanel then
			for i = 1, M.bossViewPanelUIVisiable.Count do
				local state = M.bossViewPanelUIVisiable[i]

				if i == 1 and state == 1 then
					gUIUtils:SetGoActive(gLuaUIMgr.bossViewPanel.gameObject, false)
					M:ShowMainMenuMgrMessageTipsOnEditor("隐藏boss血条面板，index:", i, "state:", state)

					return
				end
			end

			gUIUtils:SetGoActive(gLuaUIMgr.bossViewPanel.gameObject, true)
		end
	end,
	OnRefreshMiniMapNewPanelUIVisiable = function (cell)
		for i = 1, M.miniMapNewPanelUIVisiable.Count do
			local state = M.miniMapNewPanelUIVisiable[i]

			if i == 1 and state == 2 or i == 2 and state == 1 or i == 3 and state == 0 then
				gMapUtils:CloseMiniMap()
				M:ShowMainMenuMgrMessageTipsOnEditor("隐藏小地图，index:", i, "state:", state)

				return
			end
		end

		gMapUtils:ShowMiniMap()
	end,
	OnHideInUnBattleState = function (cell)
		local show = false

		for i = 1, M.uiHideInUnBattleState.Count do
			if M.uiHideInUnBattleState[i] == 1 then
				M:ShowMainMenuMgrMessageTipsOnEditor("主界面按钮显隐 index", i, "state:1")

				show = true
			end
		end

		if gPlayerManager.main.bindData.isMindPowerAim or gPlayerManager.main.bindData.isInMagnetHold then
			show = true

			M:ShowMainMenuMgrMessageTipsOnEditor("主界面按钮显隐 在念力瞄准或者hold下")
		end

		if show then
			M:HideUIInUnBattleState(true)
			gLuaTimeMgrUtils.CancelUnitDelay(M.hideHUDTimer)
		else
			M.hideHUDTimer = gLuaTimeMgrUtils.Delay(function ()
				M:HideUIInUnBattleState(false)
			end, M.defaultDelayTime)
		end
	end,
	OnRefreshFeiSuo = function (cell)
		gBattleMgr:OnRefreshFeiSuo()
	end,
	OnRefreshHighSpeed = function (cell)
		if gBattleMgr:GetBattlePanel() then
			local visible = true
			local interactable = true
			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				local jumpConfig = gMainMenuMgr.clientStateConfig[state].JumpJump

				if M:IsParkourStateValid(jumpConfig, platform) then
					visible = visible and jumpConfig[platform].visible
					interactable = interactable and jumpConfig[platform].interactable
				end
			end

			gBattleMgr:SetHighSpeedActive(visible, interactable)
		end
	end,
	OnRefreshMagnet = function (cell)
		if gBattleMgr:GetBattlePanel() then
			local visible = true
			local interactable = true
			local stateCount = 0
			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				stateCount = stateCount + 1
				local magnetConfig = gMainMenuMgr.clientStateConfig[state].Magnet

				if M:IsParkourStateValid(magnetConfig, platform) then
					visible = visible and magnetConfig[platform].visible
					interactable = interactable and magnetConfig[platform].interactable
				end
			end

			if stateCount == 0 then
				visible = false
				interactable = false
			end

			if gPlayerManager.main.bindData.isInHoldEnemy then
				visible = false
				interactable = false

				M:ShowMainMenuMgrMessageTipsOnEditor("磁力被念动怪物隐藏了 isInHoldEnemy:", gPlayerManager.main.bindData.isInHoldEnemy)
			end

			if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.FightS) then
				visible = false
				interactable = false

				M:ShowMainMenuMgrMessageTipsOnEditor("磁力被战斗状态隐藏了")
			end

			if not gCS.MindPowerMgr.AimItem or gCS.MindPowerMgr.AimItem.ItemType ~= MindPowerConst.MindObjType.Npc then
				visible = false
				interactable = false
			end

			gBattleMgr:SetMagnetBtnActive(visible, visible, interactable)
		end
	end,
	OnRefreshWallJumpOff = function (cell)
		if gBattleMgr:GetBattlePanel() then
			local visible = true
			local interactable = true
			local stateCount = 0
			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				stateCount = stateCount + 1
				local offWallConfig = gMainMenuMgr.clientStateConfig[state].OffWall

				if M:IsParkourStateValid(offWallConfig, platform) then
					visible = visible and offWallConfig[platform].visible
					interactable = interactable and offWallConfig[platform].interactable
				end
			end

			for i = 1, M.wallJumpOffBtnVisable.Count do
				local state = M.wallJumpOffBtnVisable[i]

				if state == 0 and (i == 2 or i == 3) or state == 0 and i == 1 then
					visible = false
					interactable = false

					M:ShowMainMenuMgrMessageTipsOnEditor("下墙按钮被隐藏了 index:", i, " state:", state, " visible:", visible, " interactable:", interactable)

					break
				end
			end

			if gPaokuLimitManager:CheckInDisableOffWall() then
				visible = false
				interactable = false

				M:ShowMainMenuMgrMessageTipsOnEditor("下墙按钮被区域禁用隐藏了")
			end

			if stateCount == 0 then
				visible = false
				interactable = false
			end

			gBattleMgr:SetWallJumpOffActive(visible, interactable)
			M:ShowMainMenuMgrMessageTipsOnEditor("下墙按钮状态", " visible:", visible, " interactable:", interactable, M:GetClientState())
		end
	end,
	OnRefreshMagnetPutDown = function (cell)
		if gBattleMgr:GetBattlePanel() then
			local visible = true
			local interactable = true
			local stateCount = 0
			local platform = M:GetParkourStatePlatform()

			for k, state in pairs(M:GetClientState()) do
				stateCount = stateCount + 1
				local putDownConfig = M.clientStateConfig[state].MagnetPutDown

				if M:IsParkourStateValid(putDownConfig, platform) then
					visible = visible and putDownConfig[platform].visible
					interactable = interactable and putDownConfig[platform].interactable
				end
			end

			if stateCount == 0 then
				visible = false
				interactable = false
			end

			gBattleMgr:SetMagnetPutDownActive(visible, interactable)
		end
	end,
	OnRefreshCharacterWheelsVisiable = function (cell)
		local showState = 0

		for k, state in pairs(M:GetClientState()) do
			if M.clientStateConfig[state].SwitchCharacterWheels == 0 and showState < 1 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:SetCharacterWheelsVisiable(false)

			return
		end

		gBattleMgr:SetCharacterWheelsVisiable(true)
	end,
	OnRefreshWeaponFightResVisiable = function (cell)
		local showState = 0

		for i = 1, M.weaponFightResVisiable.Count do
			local state = M.weaponFightResVisiable[i]

			if (i == 1 or i == 2 or i == 3) and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:ShowWeaponFightResHUD(false)

			return
		end

		gBattleMgr:ShowWeaponFightResHUD(true)
	end,
	OnRefreshKickOffBtnVisiable = function (cell)
		local showState = 0

		for i = 1, M.kickOffBtnVisiable.Count do
			local state = M.kickOffBtnVisiable[i]

			if i == 1 and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:ShowKickOffBtn(false)

			return
		end

		gBattleMgr:ShowKickOffBtn(true)
	end,
	OnRefreshSpiderBotExitBtnVisiable = function (cell)
		local showState = 0

		for i = 1, M.spiderBotExitBtnVisiable.Count do
			local state = M.spiderBotExitBtnVisiable[i]

			if i == 1 and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:EnableSpiderExitBtn(false)

			return
		end

		gBattleMgr:EnableSpiderExitBtn(true)
	end,
	OnRefreshCharEnergyVisiable = function (cell)
		local showState = 0

		for i = 1, M.charEnergyVisiable.Count do
			local state = M.charEnergyVisiable[i]

			if i == 1 and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:ShowCharEnergyUI(false)

			return
		end

		gBattleMgr:ShowCharEnergyUI(true)
	end,
	OnRefreshAmmunitionVisiable = function (cell)
		local visible = true
		local interactable = true
		local platform = M:GetParkourStatePlatform()

		for k, state in pairs(M:GetClientState()) do
			local ammunitionConfig = gMainMenuMgr.clientStateConfig[state].SwitchWeaponWheels

			if M:IsParkourStateValid(ammunitionConfig, platform) then
				visible = visible and ammunitionConfig[platform].visible
				interactable = interactable and ammunitionConfig[platform].interactable
			end
		end

		for i = 1, M.ammunitionVisiable.Count do
			local state = M.ammunitionVisiable[i]

			if i == 1 and state == 0 then
				visible = false
			elseif (i == 2 or i == 3 or i == 4) and state == 0 then
				visible = false
				interactable = false

				break
			end
		end

		if gPaokuLimitManager:CheckFightNeedLimit(LX6.PaoKu.FightLimitType.Weapon) then
			visible = false
			interactable = false
		end

		gBattleMgr:ShowAmmunitionInfo(visible, interactable)
	end,
	OnRefreshAirDashVisiable = function (cell)
		local showState = 0
		local platform = M:GetParkourStatePlatform()

		for k, state in pairs(M:GetClientState()) do
			local dashConfig = M.clientStateConfig[state].AirDash_mobile

			if type(dashConfig) == "table" and dashConfig[platform] and (not dashConfig[platform].visible or not dashConfig[platform].interactable) and showState < 1 then
				showState = 1

				break
			end
		end

		for i = 1, M.airDashVisiable.Count do
			local state = M.airDashVisiable[i]

			if (i == 1 or i == 2 or i == 3) and state == 0 or i == 4 and state == 1 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:EnableAirDashBtn(false)

			return
		end

		gBattleMgr:EnableAirDashBtn(true)
	end,
	OnRefreshProfessionalSkillBtnVisiable = function (cell)
		local showState = 0

		for i = 1, M.professionalSkillBtnVisiable.Count do
			local state = M.professionalSkillBtnVisiable[i]

			if i == 1 and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:EnableProfessionalSkillBtn(false)

			return
		end

		gBattleMgr:EnableProfessionalSkillBtn(true)
	end,
	OnRefreshHandBagPutDownBtnVisiable = function (cell)
		local showState = 0

		for i = 1, M.handBagPutDownBtnVisiable.Count do
			local state = M.handBagPutDownBtnVisiable[i]

			if i == 1 and state == 0 then
				showState = 1
			end
		end

		if showState == 1 then
			gBattleMgr:EnableHandBagPutDownBtn(false)

			return
		end

		gBattleMgr:EnableHandBagPutDownBtn(true)
	end,
	OnRefreshDiveControlBtnVisible = function (_)
		local isEnableDiving = LX6.Units.Module.DiveManager.CheckIsEnableDiving()

		if not isEnableDiving then
			gBattleMgr:EnableDiveControlBtn(false)

			return
		end

		local clientStates = M:GetClientState()

		if not clientStates or not next(clientStates) then
			gBattleMgr:EnableDiveControlBtn(false)

			return
		end

		local visible = true
		local interactable = true
		local platform = M:GetParkourStatePlatform()

		for _, state in pairs(clientStates) do
			local diveConfig = M.clientStateConfig[state].DiveBtnInfo

			if M:IsParkourStateValid(diveConfig, platform) then
				visible = visible and diveConfig[platform].visible
				interactable = interactable and diveConfig[platform].interactable
			end
		end

		gBattleMgr:EnableDiveControlBtn(visible)
	end
}

function M:SetTableVisible(listData, index, value)
	if listData[index] ~= value then
		listData[index] = value
	end
end

function M:HasUnitState(state)
	return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state) and 1 or 0
end

function M:HasUnitStateBool(state)
	return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state)
end

function M:RecoverHpShowBattleUI(display)
	self.uiHideInUnBattleState[4] = display and 1 or 0

	if display then
		FrameTimer.New(function ()
			gMainMenuMgr:RecoverHpShowBattleUI(false)
		end, 1):Start()
	end
end

function M:ClickSkillBtn(skillBtn, isDown)
	local needShowBattleUI = isDown

	if skillBtn == gBattleMgr.SkillBtnType.Normal then
		self.uiHideInUnBattleState[6] = needShowBattleUI and 1 or 0
	elseif skillBtn == gBattleMgr.SkillBtnType.Basic then
		self.uiHideInUnBattleState[7] = needShowBattleUI and 1 or 0
	elseif skillBtn == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		self.uiHideInUnBattleState[8] = needShowBattleUI and 1 or 0
	elseif skillBtn == gBattleMgr.SkillBtnType.ControlPower then
		self.uiHideInUnBattleState[9] = needShowBattleUI and 1 or 0
	elseif skillBtn == gBattleMgr.SkillBtnType.HeavyAttack then
		self.uiHideInUnBattleState[10] = needShowBattleUI and 1 or 0
	end
end

function M:ClickWeaponCircle(isDown)
	local needShowBattleUI = isDown
	self.uiHideInUnBattleState[2] = needShowBattleUI and 1 or 0
end

function M:CheckIsFightState()
	local inFightState = gBattleMgr.isBattleUI or gCS.MyPlayerManager.PlayerUnit.CurrentSkillId > 0

	self:SetTableVisible(self.uiHideInUnBattleState, 1, inFightState and 1 or 0)
end

function M:SetFightSpiritEpFull(isFull)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "fightSpiritEpNotFull", not isFull)
end

function M:CheckNoPowerState()
	local isHaveState = gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.NoMindPower)

	if isHaveState then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isNoMindPower", true)
	else
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isNoMindPower", false)
	end
end

function M:CheckInCrouchAssassination()
	local isHaveState = gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.CrouchAssass)

	if isHaveState then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isCrouchAssassin", true)
	else
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isCrouchAssassin", false)
	end
end

function M:NoUsePowerWhenCanInteractive(noUse)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isGamePadInteract", noUse)
end

function M:DisableUltSkillByBulletNum(enable)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "disableByBulletNum", enable)
end

function M:ShowSkillBtn(isShow)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.HeavyAttack, "specialReplace", not isShow)
end

function M:SetRefreshAssassinate()
	gCoreHudUIManager:OnRefreshSkillBtn(ButtonInfoEnum.NormalAttack)
end

function M:SetCanAssassinate(canAssassinate)
	if not gPlayerManager.main.bindData.isFeiSuoCrouch then
		canAssassinate = true
	end

	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "hasAssassinTarget", canAssassinate or not gPlayerManager.main.bindData.isFeiSuoCrouch)
end

function M:SetCanUseAssassinate(canAssassinate)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "canAssassin", canAssassinate)
end

function M:SetBtnVisibleByBuff(pid)
	self:SetCanUseAssassinateByBuff(pid)
	self:SetAirDashVisiableByBuff(pid)
end

function M:SetCanUseAssassinateByBuff(pid, hasBuff)
	local hasBuff = gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.CanCiSha) or hasBuff

	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "hasAssassinBuff", hasBuff)
end

function M:SetAirDashVisiableByBuff(pid)
	local hasBuff = gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.CanAirDash)

	self:SetTableVisible(self.airDashVisiable, 2, hasBuff and 1 or 0)
end

function M:SetHandBagPutDownBtnVisiable(enable)
	self:SetTableVisible(self.handBagPutDownBtnVisiable, 1, enable and 1 or 0)
end

function M:SetState(state, isAdd)
	if state == UnitStateConfig.NoMindPower then
		self:CheckNoPowerState()
	end

	if state == UnitStateConfig.CrouchAssass then
		self:CheckInCrouchAssassination()
	end

	if state == UnitStateConfig.StiffS then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isStiffS", isAdd)
	end

	if state == UnitStateConfig.HideBattleUISkill1 then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "hideSkill1", isAdd)
	end

	if state == UnitStateConfig.ForbidAttack then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "forbidAttack", isAdd)
	end

	if state == UnitStateConfig.HideBattleUISkill2 then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "UnitStateCfgNeedHide", isAdd)
	end

	if state == UnitStateConfig.ForbidSkill1 then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "unitStateCfgNeedForbid", isAdd)
	end

	if state == UnitStateConfig.ForbidSpiritUnique then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "unitStateCfgNeedForbid", isAdd)
	end

	if state == UnitStateConfig.ForbidPrivateWeaponUltSkill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "unitStateCfgNeedForbidPrivateWeaponUltSkill", isAdd and gBattleMgr.isPrivateWeapon)
	end

	if state == UnitStateConfig.HideBattleUIJump then
		self:SetTableVisible(self.hideRushOrJumpBtnsVisiable, 1, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideBattleButton then
		self:SetTableVisible(self.rightBottomVisiable, 2, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.DeadS then
		if gCS.MyPlayerManager.PlayerUnit then
			isAdd = gCS.MyPlayerManager.PlayerUnit.IsDead
		end

		self.extraVisiable.isInDeadS = isAdd

		self:SetTableVisible(self.battleUIVisiable, 5, isAdd and 1 or 0)
		self:SetTableVisible(self.hpUIVisiable, 2, isAdd and 1 or 0)
		self:SetTableVisible(self.rightBottomVisiable, 1, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideBattleUI then
		self:SetTableVisible(self.battleUIVisiable, 3, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HidePlayerHp then
		self:SetTableVisible(self.hpUIVisiable, 1, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideBattleUISprint then
		-- Nothing
	end

	if state == UnitStateConfig.HideLightHack then
		self:SetTableVisible(self.hackerScanVisiable, 2, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideMiniChat then
		self:SetTableVisible(self.chatSimpleUIVisiable, 2, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideDeviceStatus then
		self:SetTableVisible(self.deviceStatusUIVisiable, 1, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideBossView then
		self:SetTableVisible(self.bossViewPanelUIVisiable, 1, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.HideMiniMap then
		self:SetTableVisible(self.miniMapNewPanelUIVisiable, 2, isAdd and 1 or 0)
	end

	if state == UnitStateConfig.Sitting then
		self:SetSitState(isAdd)
	end

	if state == UnitStateConfig.FightS then
		gBattleMgr.isBattleUI = isAdd
		gCS.FightDataMgr.isShowBattleUI = isAdd

		self:CheckIsFightState()
	end

	if state == UnitStateConfig.ForbidAttack then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "forbidAttack", isAdd)
	end

	if state == UnitStateConfig.ForbidChangeWeapon then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "unitStateCfgNeedForbid", isAdd)
	end
end

function M:SetAwakeUI(name)
	if self.onAwakeUI[name] >= 1 then
		self.onAwakeUI[name] = 0
	else
		self.onAwakeUI[name] = 1
	end
end

function M:RefreshEnemyMindInteractBtn(btnType)
	local mindIsNormalAttack = btnType == MindButtonTypeType.NormalSkillBtn
	local mindIsInteract = btnType == MindButtonTypeType.InteractBtn or btnType == MindButtonTypeType.ExecuteBtn

	self:SetTableVisible(self.battleSkill1UIVisiable, 11, mindIsNormalAttack and 1 or 0)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isMonsterInteract", not mindIsNormalAttack and not mindIsInteract)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "isMonsterInteract", mindIsNormalAttack)
end

function M:SetSitState(isAdd)
	self:SetTableVisible(self.rightBottomVisiable, 4, isAdd and 1 or 0)
end

function M:SetBattleSkillBtnIsInCd(skilltype, isInCd)
	if skilltype == gBattleMgr.SkillBtnType.Normal then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "skillInCD", isInCd)
	elseif skilltype == gBattleMgr.SkillBtnType.Basic then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "skillInCD", isInCd)
	elseif skilltype == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "skillInCD", isInCd)
	elseif skilltype == gBattleMgr.SkillBtnType.ControlPower then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "skillInCD", isInCd)
	end
end

function M:HideMiniMapByShootMode(show)
	self:SetTableVisible(self.miniMapNewPanelUIVisiable, 3, show and 1 or 0)
end

function M:ClickTaskOnTaskAndTeamState()
	if self.taskAndTeamState.isShowTask then
		gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
	else
		self.taskAndTeamState.isShowTask = true
		self.taskAndTeamState.isShowTeam = false
	end
end

function M:SetComboSkill(index)
	if self.comboSkill[index] >= 1 then
		self.comboSkill[index] = 0
	else
		self.comboSkill[index] = 1
	end
end

function M:SyncAllStates(states)
	self.clientState.parkourState = states:ToTable()
end

function M:OnParkourStateChange()
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("gMainMenuMgr.OnParkourStateChange.SetParkourStateLimit")
	end

	gCS.BaseUnitModuleUtils.SetParkourStateLimitSwim(gCS.MyPlayerManager.PlayerUnit, self:CheckForbidSwim())
	gCS.BaseUnitModuleUtils.SetParkourStateLimitFall(gCS.MyPlayerManager.PlayerUnit, self:CheckForbidFallDown())

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.BeginSample("gMainMenuMgr.OnParkourStateChange.UpdateGlobalTipStatus")
	end

	self:UpdateGlobalTipStatus()

	if gGameManager.Env.IsENABLE_PROFILER then
		gCS.LuaUtils.EndSample()
	end
end

function M:CheckForbidFallDown()
	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if gMainMenuMgr.clientStateConfig[state].Not_FallDown == 1 then
			return true
		end
	end

	return false
end

function M:CheckForbidSwim()
	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if gMainMenuMgr.clientStateConfig[state].Not_Swim == 1 then
			return true
		end
	end

	return false
end

function M:UpdateGlobalTipStatus()
	local maxLevel = 0

	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		local curLevel = 0

		if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			curLevel = gMainMenuMgr.clientStateConfig[state].DisplayLevel.standalone
		elseif gCS.LuaUtils.IsPSPlatform() then
			curLevel = gMainMenuMgr.clientStateConfig[state].DisplayLevel.console
		end

		maxLevel = Mathf.Max(maxLevel, curLevel)
	end

	if gMainMenuMgr.vehicleDisplayLevel then
		maxLevel = Mathf.Max(maxLevel, gMainMenuMgr.vehicleDisplayLevel)
	end

	SGUI.UGamePadBar.globalBar:ChangeCurDisplayLevel(maxLevel)
end

function M:CheckMindPowerCounterSkill()
	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if gMainMenuMgr.clientStateConfig[state].MindPowerCounterSkill == 0 then
			return false
		end
	end

	return true
end

function M:GetClientState()
	return self.clientState.parkourState
end

function M:GetStateLookAtConfig(curState, nextState)
	if M.clientStateConfig == nil or M.clientStateConfig[curState] == nil or M.clientStateConfig[nextState] == nil or M.clientStateConfig[curState].LookAtConfig == M.clientStateConfig[nextState].LookAtConfig then
		return -1
	else
		return M.clientStateConfig[nextState].LookAtConfig
	end
end

function M:CheckHasClientState(state)
	if self.clientState.parkourState then
		for _, parkourState in pairs(self.clientState.parkourState) do
			if state == parkourState then
				return true
			end
		end
	end
end

function M:InitClientStateConfig()
	self.clientStateConfig = {}

	for i = 0, ParkourStateConfig.count - 1 do
		local cfg = ParkourStateConfig.LoadAt(i)

		for parkourName, _ in pairs(self.clientStateName) do
			local attributeList = cfg[parkourName]

			self:ExchangeClientStateConfigType(attributeList)
		end

		self.clientStateConfig[cfg.Id] = cfg
	end

	self:InitParkourStateBtnInfoConfig()
end

function M:ExchangeClientStateConfigType(attributeList)
	if not attributeList or type(attributeList) ~= "table" then
		return
	end

	for _, item in ipairs(attributeList) do
		if type(item) == "table" and item.visible ~= nil and type(item.visible) == "number" and item.interactable ~= nil and type(item.interactable) == "number" then
			item.visible = item.visible ~= 0
			item.interactable = item.interactable ~= 0
		end
	end
end

function M:InitParkourStateBtnInfoConfig()
	self.BtnInfoInitData = {
		useTipMode = -1,
		height = -1,
		tipId = -1,
		posY = -1,
		width = -1,
		posX = -1
	}
	self.parkourStateBtnInfoConfig = {}

	for i = 0, ParkourStateButtonInfoConfig.count - 1 do
		local cfg = ParkourStateButtonInfoConfig.LoadAt(i)
		self.parkourStateBtnInfoConfig[cfg.Id] = {}

		for k, v in pairs(self.parkourStateButtonInfoType) do
			if v ~= self.parkourStateButtonInfoType.Count then
				local item = cfg[k]

				if item and (item.posX ~= -1 or item.posY ~= -1 or item.useTipMode ~= -1 or item.tipId ~= -1 or item.width ~= -1 or item.height ~= -1) then
					self.parkourStateBtnInfoConfig[cfg.Id][k] = item
				end
			end
		end
	end
end

function M:DebugParkourStateLog(enable)
	self.debugParkourState = enable
end

function M:HasTargetParkourState(targetState)
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	return gCS.ParkourStateModule.HasTargetState(gCS.MyPlayerManager.PlayerUnit, targetState)
end

function M:SetInMindPowerHoldMode(enable)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isMindHold", enable)
end

function M:SetTriggerDisableSkill(index, value)
	self.triggerDisableBattleSkillUIVisiable[index] = value

	if value == 1 then
		gBattleMgr:DoSthWhenSkillBtnClose()
	end
end

function M:ClearTriggerDisableSkill()
	for i = 1, self.triggerDisableBattleSkillUIVisiable.Count do
		self.triggerDisableBattleSkillUIVisiable[i] = 0
	end
end

function M:SetTriggerDisableParkour()
	local count = self.triggerDisableParkourUIVisiable[1] + 1

	if count > 10000 then
		count = 0
	end

	self.triggerDisableParkourUIVisiable[1] = count
end

function M:HideUIInUnBattleState(isSkinActive)
	if not gCS.LuaUtils.IsNonMobileAdaptive() or M.battleUIVisiable[2] ~= 2 then
		isSkinActive = true
	end

	self.hideState = isSkinActive

	if gBattleMgr.characterPartPanel then
		M.hpUIVisiable[4] = M.hpUIVisiable[4] and isSkinActive and 1 or 0
	end

	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "isNotHideInUnBattle", gCoreHudUIManager.skill2State.isNotHideInUnBattle ~= nil and isSkinActive)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isNotHideInUnBattle", gCoreHudUIManager.skill3State.isNotHideInUnBattle ~= nil and isSkinActive)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isNotHideInUnBattle", gCoreHudUIManager.skill4State.isNotHideInUnBattle ~= nil and isSkinActive)

	M.weaponFightResVisiable[2] = M.weaponFightResVisiable[2] and isSkinActive and 1 or 0
	M.charEnergyVisiable[1] = M.charEnergyVisiable[1] and isSkinActive and 1 or 0

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "isNotHideInUnBattle", gCoreHudUIManager.switchWeaponState.isNotHideInUnBattle ~= nil and isSkinActive)
end

function M:SetUnLockSystems()
	M:ShowMainMenuMgrMessageTipsOnEditor("版署版本功能解锁:", gPlayerManager.infoMinor.bindData.UnlockSystems, "test")
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleNormalUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleEUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleRUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.MindPowerUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.HeavyAttack, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BlockState))

	M.hackerScanVisiable[4] = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.ScanUnlock) and 1 or 0
end

function M:GMUnlockAllSystems(enable)
	M:SetUnLockSystems()
end

function M:CheckCanVehicleInteract()
	for k, state in pairs(M:GetClientState()) do
		if M.clientStateConfig[state].CanInteractVehicleDoor == 0 then
			return false
		end
	end

	return true
end

function M:CheckCanGroundInteract()
	for k, state in pairs(M:GetClientState()) do
		if M.clientStateConfig[state].OnGroundInteraction == 0 then
			return false
		end
	end

	return true
end

function M:CheckCanChairInteract()
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	for k, state in pairs(M:GetClientState()) do
		if M.clientStateConfig[state].SitInteraction == 0 then
			return false
		end
	end

	return true
end

function M:CheckCanWallInteract()
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	for k, state in pairs(M:GetClientState()) do
		if M.clientStateConfig[state].OnWallInteraction == 0 then
			return false
		end
	end

	return true
end

function M:GetPaoKuStatesStr()
	local str = ""

	for k, state in pairs(M:GetClientState()) do
		str = str .. state .. ","
	end

	return str
end

function M:CheckForbidSkillInAir(skillId)
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	local skillCfg = SkillConfig.GetConfig(skillId)

	if skillCfg and (skillCfg.SkillCastTypeTag == SkillConfig.SkillCastTypeTagType.CommonAttack or skillCfg.SkillCastTypeTag == SkillConfig.SkillCastTypeTagType.FireAttack) then
		for k, state in pairs(M:GetClientState()) do
			if (state == ParkourStateConfig.Feisuo or state == ParkourStateConfig.Fall or state == ParkourStateConfig.Jump) and (skillCfg == nil or not skillCfg.CanUseInTheAir.CanUseInTheAir) then
				return true
			elseif skillCfg ~= nil and not skillCfg.CanUseInTheAir.CanUseInTheAir then
				-- Nothing
			end
		end
	end

	return false
end

function M:CheckCanUseWeaponCircle()
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.ForbidChangeWeapon) then
		return false
	end

	local platform = M:GetParkourStatePlatform()

	for k, state in pairs(M:GetClientState()) do
		local wheelConfig = M.clientStateConfig[state].SwitchWeaponWheels

		if type(wheelConfig) == "table" and wheelConfig[platform] and not wheelConfig[platform].interactable then
			return false
		end
	end

	return true
end

function M:IsParkourStateValid(stateConfig, platform)
	return type(stateConfig) == "table" and stateConfig[platform] and stateConfig[platform].visible ~= nil and stateConfig[platform].interactable ~= nil
end

function M:GetParkourStatePlatform()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return 1
	else
		return 2
	end
end

function M:AfterCheckClientState()
	gBattleMgr.canDodge = not gBattleMgr:HasDodgeDisableState()
end

function M:BattleSkillSwitch(skillBtnType, active)
	if skillBtnType == gBattleMgr.SkillBtnType.Basic then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "isTestSkillSwitchOn", active)
	elseif skillBtnType == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isTestSkillSwitchOn", active)
	end
end

function M:ShowJumpBtnByUnitState(show)
	self:SetTableVisible(self.jumpUIVisiable, 2, show and 1 or 0)
end

function M:ShowJumpBtnBySystemUnlock(isUnlock)
	self:SetTableVisible(self.jumpUIVisiable, 3, isUnlock and 1 or 0)
end

function M:SetWallJumpState(enable)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 1, enable and 1 or 0)
end

function M:SetWallJumpStateByInturn(enable)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 3, enable and 1 or 0)
end

function M:SetWallJumpStateBySystemUnlock(enable)
	self:SetTableVisible(self.wallJumpOffBtnVisable, 2, enable and 1 or 0)
end

function M:SetAmmunitionStateBySystemUnlock(enable)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "systemBattleUnlock", enable)
end

function M:SetAirdashStateBySystemUnlock(enable)
	self:SetTableVisible(self.airDashVisiable, 3, enable and 1 or 0)
end

function M:SetWeaponFightResVisiable(show)
	self:SetTableVisible(self.weaponFightResVisiable, 1, show and 1 or 0)
end

function M:SetWeaponFightResBySystemUnlock(enable)
	self:SetTableVisible(self.weaponFightResVisiable, 3, enable and 1 or 0)
end

function M:SetKickOffBtnVisiable(show)
	self:SetTableVisible(self.kickOffBtnVisiable, 1, show and 1 or 0)
end

function M:SetSpiderBotExitBtnVisiable(show)
	self:SetTableVisible(self.spiderBotExitBtnVisiable, 1, show and 1 or 0)
end

function M:SetAmmunitionVisiable(show)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "isUnShow", show)
end

function M:SetAirDashVisiable(show)
	self:SetTableVisible(self.airDashVisiable, 1, show and 1 or 0)
end

function M:SetProfessionalSkillBtnVisiable(show)
	self:SetTableVisible(self.professionalSkillBtnVisiable, 1, show and 1 or 0)
end

function M:ForbidSkillBtnByNoSkillId(skillBtnType, noSkillId)
	if skillBtnType == gBattleMgr.SkillBtnType.Normal then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType)

		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType == gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType)

		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType == gBattleMgr.SkillBtnType.ControlPower then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType == gBattleMgr.SkillBtnType.HeavyAttack then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType)

		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.HeavyAttack, "isForbidByNoSkillId", noSkillId)
	end
end

function M:SetForbidByMotoBuff(hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.HeavyAttack, "isTaFeiMoto", hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.NormalAttack, "isTaFeiMoto", hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isTaFeiMoto", hasBuff)
	gMessageManager:SendMessage(gEventConstants.ON_TAFFY_MOTO, hasBuff)
end

function M:GetParkourStateMindPowerMode(config)
	local destructibleCfg = nil
	local aimItem = gCS.MindPowerMgr:GetAimItem()

	if aimItem then
		destructibleCfg = LTConfig.DestructibleConfig.GetConfig(aimItem.DestructibleCfgId)
	end

	if destructibleCfg then
		local type = destructibleCfg.MindPower_CanUseType

		self:ShowMainMenuMgrMessageTipsOnEditor("GetParkourStateMindPowerMode type", type)

		if type == 1 then
			return config.MindPower_Destructible_One
		elseif type == 2 then
			return config.MindPower_Destructible_Two
		elseif type == 3 then
			return config.MindPower_Destructible_Three
		else
			return config.MindPower
		end
	end

	self:ShowMainMenuMgrMessageTipsOnEditor("GetParkourStateMindPowerMode", config.Id)

	return config.MindPower
end

function M:InitButtonInfo()
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterControlStore")
	local coreHud = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	local tafei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")

	if not store.STATE_EnableOnce or not coreHud.STATE_EnableOnce then
		return
	end

	self.isInitButtonInfo = true

	for _, btnTypeNum in pairs(self.parkourStateButtonInfoType) do
		if btnTypeNum ~= self.parkourStateButtonInfoType.Count and self.parkourStateButtonRef[btnTypeNum] then
			local btnRefIndex = self.parkourStateButtonRef[btnTypeNum]
			local buttonInfoIndex = self.parkourStateButtonInfoIndex[btnTypeNum]
			local btn = store.characterControlData[btnRefIndex] or store[btnRefIndex] or tafei.bindData[btnRefIndex]

			if btn then
				self.parkourStateButtonInitInfoCache[btnTypeNum] = {
					pos = btn.anchoredPosition,
					size = btn.sizeDelta
				}

				if gCS.LuaUtils.IsNonMobileAdaptive() then
					self.parkourStateButtonInitTipStateCachePC[btnTypeNum] = {
						showTip = btn:GetPCKeyTipShowTip(),
						tipNameId = btn:GetPCKeyInfoTipNameId()
					}
				end
			else
				self.parkourStateButtonInitTipStateCachePC[btnTypeNum] = {
					showTip = false,
					tipNameId = -1
				}
			end

			if gCS.LuaUtils.IsNonMobileAdaptive() then
				local showTip = false
				local tipNameId = -1

				if buttonInfoIndex ~= -1 then
					showTip = coreHud.bindData.gamePadArea:GetButtonInfoTipShowTip(buttonInfoIndex)
					tipNameId = coreHud.bindData.gamePadArea:GetButtonInfoTipNameId(buttonInfoIndex)
				end

				self.parkourStateButtonInitTipStateCacheController[btnTypeNum] = {
					showTip = showTip,
					tipNameId = tipNameId
				}
			end
		end
	end
end

function M:InitButtonInfoForTabRect(btn, btnTypeNum)
	if not btn or not btnTypeNum then
		return
	end

	self.parkourStateButtonInitInfoCache[btnTypeNum] = {
		pos = btn.anchoredPosition,
		size = btn.sizeDelta
	}

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.parkourStateButtonInitTipStateCachePC[btnTypeNum] = {
			showTip = btn:GetPCKeyTipShowTip(),
			tipNameId = btn:GetPCKeyInfoTipNameId()
		}
	end
end

function M:RefreshBtnPosition(data, btnType)
	if gCoreHudTipManager.isEnable then
		gCoreHudTipManager:UpdateBtnPosition(btnType, gCoreHudTipManager.conditionType.Parkour, data)

		return
	end

	local store = gBattleMgr.characterControlPanel
	local btnRefIndex = self.parkourStateButtonRef[btnType]
	local tafei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")
	local btn = store and (store.characterControlData[btnRefIndex] or store[btnRefIndex] or tafei.bindData[btnRefIndex]) or nil

	if btn then
		local posX = data.posX == -1 and self.parkourStateButtonInitInfoCache[btnType].pos.x or data.posX
		local posY = data.posY == -1 and self.parkourStateButtonInitInfoCache[btnType].pos.y or data.posY
		local width = data.width == -1 and self.parkourStateButtonInitInfoCache[btnType].size.x or data.width
		local height = data.height == -1 and self.parkourStateButtonInitInfoCache[btnType].size.y or data.height
		local newPos = Vector2.New(posX, posY)
		btn.anchoredPosition = newPos
		local newSize = Vector2.New(width, height)
		btn.sizeDelta = newSize
	end
end

function M:RefreshBtnTips(data, btnType)
	if gCoreHudTipManager.isEnable then
		gCoreHudTipManager:UpdateBtnTipState(btnType, gCoreHudTipManager.conditionType.Parkour, data)
		gCoreHudTipManager:UpdateGamepadBtnTipState(btnType, gCoreHudTipManager.conditionType.Parkour, data)

		return
	end

	local store = gBattleMgr.characterControlPanel
	local coreHud = gStoreManager:GetStoreGroup("CoreHudPanelStore")
	local tafei = gStoreManager:GetStoreGroup("UniqueSkillTaFeiStore")
	local btnRefIndex = self.parkourStateButtonRef[btnType]
	local btn = store and (store.characterControlData[btnRefIndex] or store[btnRefIndex] or tafei.bindData[btnRefIndex]) or nil
	local control = btnType == ButtonInfoEnum.TaFeiMoto and tafei or coreHud

	self:RefreshBtnTipsPC(btn, btnType, data)
	self:RefreshBtnTipsController(control, btnType, data)
end

function M:RefreshBtnTipsPC(btn, btnType, data)
	if not btn or not data then
		return
	end

	local showTip = data.useTipMode == -1 and self.parkourStateButtonInitTipStateCachePC[btnType].showTip or data.useTipMode == 1
	local tipId = data.tipId == -1 and self.parkourStateButtonInitTipStateCachePC[btnType].tipNameId or data.tipId

	btn:SetPCKeyTipShowTip(showTip)
	self:SetBtnHideByBtnType(btnType, showTip)
	btn:SetPCKeyInfoTipNameId(tipId)
end

function M:ExchangeJumpBtnForDive(hud, btnType, jumpBtnIndexForDive)
	if btnType == "JumpJumpBtnInfo" and not gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.Dive) and self.isInDiving == true then
		self.isInDiving = false

		hud.bindData.gamePadArea:SetButtonInfoTipShowTip(false, jumpBtnIndexForDive)
	end

	if gMainMenuMgr:HasTargetParkourState(ParkourStateConfig.Dive) and btnType == "JumpJumpBtnInfo" then
		self.isInDiving = true

		return true
	end

	return false
end

function M:RefreshBtnTipsController(hud, btnType, data)
	local jumpBtnIndexForDive = 0
	local buttonInfoIndex = self:ExchangeJumpBtnForDive(hud, btnType, jumpBtnIndexForDive) and jumpBtnIndexForDive or self.parkourStateButtonInfoIndex[btnType]

	if not hud or not hud.bindData.gamePadArea or buttonInfoIndex == -1 then
		return
	end

	local showTip = data.useTipMode == -1 and self.parkourStateButtonInitTipStateCacheController[btnType].showTip or data.useTipMode == 1
	local tipId = data.tipId == -1 and self.parkourStateButtonInitTipStateCacheController[btnType].tipNameId or data.tipId

	hud.bindData.gamePadArea:SetButtonInfoTipShowTip(showTip, buttonInfoIndex)
	self:SetBtnHideByBtnType(btnType, showTip)
	hud.bindData.gamePadArea:SetButtonInfoTipNameId(tipId, buttonInfoIndex)
end

function M:SetBtnHideByBtnType(btnType, showTip)
	if btnType == ButtonInfoEnum.Skill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.Skill, "isHideByTipRefresh", showTip)
	elseif btnType == ButtonInfoEnum.UltSkill then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.UltSkill, "isHideByTipRefresh", showTip)
	elseif btnType == ButtonInfoEnum.MindPower then
		gCoreHudUIManager:OnSetSkillBtnState(ButtonInfoEnum.MindPower, "isHideByTipRefresh", not showTip)
	end
end

function M:RefreshFullScreenLowHpAni(hpFill, force)
	local showLowHpEffect = hpFill and hpFill <= GameConfig.LowHpEffectActive and hpFill > 0 or false
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) ~= LX6.Units.Module.ShootModule.VehicleShootState.None then
		self:PlayFullScreenLowHpAni(false)
		self:PlayVehicleCameraLowHpAni(showLowHpEffect, force)
	else
		showLowHpEffect = showLowHpEffect and not gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.Drive)

		self:PlayVehicleCameraLowHpAni(false, force)
		self:PlayFullScreenLowHpAni(showLowHpEffect)
		self:UpdateFullScreenLowHpAniSpeed(hpFill, showLowHpEffect)
	end
end

function M:PlayFullScreenLowHpAni(showLowHpEffect)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:PlayFullScreenLowHpAni(showLowHpEffect)
end

function M:UpdateFullScreenLowHpAniSpeed(hpFill, showLowHpEffect)
	local store = gStoreManager:GetStoreGroup("CoreHudCharacterPartStore")

	store:UpdateFullScreenLowHpAniSpeed(hpFill, showLowHpEffect)
end

function M:PlayVehicleCameraLowHpAni(showLowHpEffect, force)
	return
end

function M:ModifyCameraColorModulation(force)
	local deltaTime = Time.time - self.modifyCameraColorModulationStartTime
	local percent = deltaTime / GameConfig.CameraPostProcessVehicleLowHp.blendTime

	if force or percent >= 1 then
		self:CheckDriveBattleUpdateDisable()
		gCS.CameraDataMgr.cameraEffectController:ModifyCameraColorModulations(self.modifyCameraColorModulationEndType, self.modifyCameraColorModulationEndValue)

		return
	end

	local deltaValue = self.modifyCameraColorModulationEndValue - self.modifyCameraColorModulationStartValue
	local curSaturation = self.modifyCameraColorModulationStartValue + deltaValue * percent

	gCS.CameraDataMgr.cameraEffectController:ModifyCameraColorModulations(true, curSaturation)
end

function M:CheckDriveBattleUpdateEnable()
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:CheckUpdateEnable()

	return store.bActive
end

function M:CheckDriveBattleUpdateDisable()
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:CheckUpdateDisable()
end

function M:DebugMainMenu(enable)
	gMainMenuMgr.ShowTestMsg = enable
end

function M:ShowMainMenuMgrMessageTipsOnEditor(content, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("纯编辑器测试：" .. content, ...)
	end
end

gMainMenuMgr = M
