-- Original chunk: @Lua\LuaFiles\LX6\GUI\Simple\MainMenuMgr.lua
-- Decompiled from: 00261_MainMenuMgr.lua_6982486fbe04.luajit

local DataSet = require("LX6/DataBind/DataSet")
local ProfileManager = LX6.Engine.ProfileManager
local GameConfig = LTConfig.GameConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local UnitStateConfig = LTConfig.UnitStateConfig
local UnitState = UX.Game.TwoDimConfig.UnitState
local ParkourStateConfig = LTConfig.ParkourStateConfig
local SkillConfig = LTConfig.SkillConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local MindButtonTypeType = LTConfig.BattleEnemyInteractConfig.MindButtonTypeType
local CoreHudButtonConfig = LTConfig.CoreHudButtonConfig

if not gMainMenuMgr then
	local M = {
		["{{⛻)\\x944\\xe1\\xc9"] = 0.5,
		extraVisiable = DataSet.New({
			["JTEgj"] = false
		}),
		onAwakeUI = DataSet.New({
			["Mv\\xf6N\\xc1\\xca\\xfbb,\\xf8mt\\xee\\xf9{\\xf6Iw\\xd8\\xc5\\xcfܒ\\xf7h"] = 0,
			["\\xe9?\"\\xfc\\x9d\\x96\\xff\\xb0\\x8b가๊%\\xc0\\x88\"\\x83\\x9d\r\\x8f\\xdd \\xe2"] = 0,
			["f\\x9b\\x9b\\xba\\xfe\\xb1\\xd1/\\xa5:=\\xb33"] = 0,
			["-\\x91殅絩\\xbe\\xd4\\xe7%\\xf6\\x9b.\\x9a\\xee"] = 0
		}),
		unlockSystems = {},
		idealState = {
			true,
			true
		},
		checkBtnInfoList = {},
		hackerScanVisiable = DataSet.New({
			1,
			-1,
			-1,
			0,
			["n\\xa1\\xb7\\xa1\\xa2"] = 5,
			[5.0] = 0
		}),
		rightBottomVisiable = DataSet.New({
			0,
			0,
			0,
			0,
			0,
			0,
			["n\\xa1\\xb7\\xa1\\xa2"] = 6
		}),
		bossViewPanelUIVisiable = DataSet.New({
			["n\\xa1\\xb7\\xa1\\xa2"] = 1,
			[1.0] = 0
		}),
		battleUIVisiable = DataSet.New({
			1,
			-1,
			0,
			0,
			["n\\xa1\\xb7\\xa1\\xa2"] = 5,
			[5.0] = 0
		}),
		clientState = DataSet.New({
			parkourState = {}
		}),
		comboSkill = DataSet.New({
			0,
			0,
			0,
			0,
			["n\\xa1\\xb7\\xa1\\xa2"] = 4,
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
			["n\\xa1\\xb7\\xa1\\xa2"] = 8,
			[9.0] = 0
		}),
		triggerDisableParkourUIVisiable = DataSet.New({
			["n\\xa1\\xb7\\xa1\\xa2"] = 1,
			[1.0] = 0
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
			1,
			0,
			nil,
			nil,
			0,
			0,
			0,
			1,
			1,
			1,
			0,
			nil,
			nil,
			nil,
			0
		}),
		clientStateCacheType = {
			["kH`mq2,"] = 16,
			["~\\xa5\\xab\\xa3\\xba"] = 2,
			["\\xbb=6:Z\\x89O\\xf09\\xac\\xb6"] = 13,
			["nNbm~*"] = 4,
			["\\x81\\xa4\\xbb@+\\xf3#"] = 7,
			["Ay\\xbezM\\xbe\\xd3S~{}G"] = 1,
			["1I\\x96\\x80\\x86U"] = 10,
			["i\\xa1\\xa6\\xa8\\xb3"] = 6,
			["5-\\x99\\xf9\\xa8\\xafߣ\\xbb\\x98\\xd2\\xecΟ%\\x93\\xf1"] = 20,
			["R#~P"] = 26,
			["\\x9e\\xbd\\x98a7\\xf2?"] = 3,
			["/\\xe2X\"\\xc4,\\xa3U\\x85Y\\xa7\\xb8"] = 11,
			["4G\\x9d\\x8a\\xbcs"] = 18,
			["\"/\\xeav\\xa7\\xc4<\\xa7=\\xf2\\xd1\\xf3`\\xe8"] = 22,
			["Ɠ\\xc8\\xee$\\xe7\\x87\\xef\\x8b,-"] = 21,
			["\\xf6\\xdd*(\\xfd"] = 9,
			["\\xfe\\xc9\r(\\xf4"] = 8,
			["("] = 12,
			["4G\\x9d\\x8a\\xbcd"] = 17,
			["<!\\xbd\\xf4<'{-\\x977=Ȏ\\xa2;\\x9c\\x92ŝ"] = 19,
			["\\xb71!)a\\xbcU\\xcd6\\xa9\\xb2"] = 5
		},
		clientStateName = {
			["\\xfe\\xc9\r(\\xf4"] = 11,
			["\\x81\\xa4\\xbb@+\\xf3#"] = 6,
			["i\\xa1\\xa6\\xa8\\xb3"] = 5,
			["\\xf6\\xdd*(\\xfd"] = 13,
			[".\\xef\\x89! \\xc1J'\\x8f\\xa1!S\\xa9M\\xa8g4\\xb1\\xe3\\xb8\n\\xcb"] = 8,
			["Ay\\xbezM\\xbe\\xd3S~{}G"] = 1,
			["1I\\x96\\x80\\x86U"] = 14,
			["~\\xa5\\xab\\xa3\\xba"] = 3,
			["\\xbb=6:Z\\x89O\\xf09\\xac\\xb6"] = 19,
			["By\\xb8~C\\xbc\\xd3D~sqB"] = 21,
			["\\x9e\\xbd\\x98a7\\xf2?"] = 4,
			["/\\xe2X\"\\xc4,\\xa3U\\x85Y\\xa7\\xb8"] = 15,
			["\\xbc\\xd9X)f\\x99sw\\xb2nZ\\x82|\\xf5\\xb8\\x9d\\xe8h{\\x8b"] = 10,
			["4G\\x9d\\x8a\\xbcd"] = 24,
			["wFJlG37"] = 22,
			["4G\\x9d\\x8a\\xbcs"] = 25,
			["R#~P"] = 27,
			["\"/\\xeav\\xa7\\xc4<\\xa7=\\xf2\\xd1\\xf3`\\xe8"] = 26,
			["Ɠ\\xc8\\xee$\\xe7\\x87\\xef\\x8b,-"] = 20,
			["5-\\x99\\xf9\\xa8\\xafߣ\\xbb\\x98\\xd2\\xecΟ%\\x93\\xf1"] = 18,
			["nNbm~*"] = 7,
			["("] = 17,
			["kH`mq2,"] = 23,
			[".\\xef\\x89! \\xc1J'\\x8f\\xa1!S\\xa9M\\xa8g4\\xb1\\xe3\\xb8\\xc1"] = 9,
			["\\xb71!)a\\xbcU\\xcd6\\xa9\\xb2"] = 2
		}
	}
end

M.InitBindDta = function(self)
	local stateHideBattleButton = self.HasUnitState(self, UnitStateConfig.HideBattleButton)
	local stateDeadS = self.HasUnitState(self, UnitStateConfig.DeadS)
	local stateHideBattleUI = self.HasUnitState(self, UnitStateConfig.HideBattleUI)
	local stateHidePlayerHp = self.HasUnitState(self, UnitStateConfig.HidePlayerHp)
	local stateHideHackScan = 0
	local stateHideBossView = self.HasUnitState(self, UnitStateConfig.HideBossView)
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

	self:SetTableVisible(self.hackerScanVisiable, 1, 1)
	self:SetTableVisible(self.hackerScanVisiable, 2, stateHideHackScan)
	self:SetTableVisible(self.hackerScanVisiable, 3, -1)
	self:SetTableVisible(self.hackerScanVisiable, 5, gCS.LuaUtils.IsNonMobileAdaptive() and 0 or 1)
	self:SetTableVisible(self.bossViewPanelUIVisiable, 1, stateHideBossView)
	self:SetTableVisible(self.clientState, "parkourState", {})
	self:SetTableVisible(self.triggerDisableParkourUIVisiable, 1, 0)
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
	self:SetTableVisible(self.clientStateCache, 12, 1)
	self:SetTableVisible(self.clientStateCache, 13, 0)
	self:SetTableVisible(self.clientStateCache, 16, 0)
	self:SetTableVisible(self.clientStateCache, 17, 0)
	self:SetTableVisible(self.clientStateCache, 18, 0)
	self:SetTableVisible(self.clientStateCache, 19, 1)
	self:SetTableVisible(self.clientStateCache, 20, 1)
	self:SetTableVisible(self.clientStateCache, 21, 1)
	self:SetTableVisible(self.clientStateCache, 22, 0)
	self:SetTableVisible(self.clientStateCache, 26, 0)
end

M.OnInit = function(self)
	self:InitClientStateConfig()

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.UI_RESET, self.OnResetUI)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.LOADING_FINISHED, self.OnLoadingFinish)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.CHANGE_MY_UNIT, self.OnChangeUnit)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY, self.OnChangeIndoorMap)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.PAOKU_STATE_CHANGE, function ()
		self:OnParkourStateChange()
	end)

	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.PARKOUR_CLIENT_STATE_REFRESH, function (event, data)
		local state = data.state

		if not self.clientStateCache[state] then
			return
		end

		self.clientStateCache[state] = self.clientStateCache[state] > 10000 and 0 or self.clientStateCache[state] + 1
	end)
end

M.OnCheckDevicesMorePanel = function(eventId, data)
end

M.OnResetUI = function()
	M:RegisterVisiableRules()
	M:SetAwakeUI("awakeSimpleQuickMenuPanel")
	M:SetAwakeUI("awakeBattlePanel")
end

M.OnLoadingFinish = function()
	M:SetUnLockSystems()
end

M.OnChangeUnit = function(eventId, msg)
	gMainMenuMgr:SetBtnVisibleByBuff(msg)
end

M.OnChangeIndoorMap = function()
	local inDoor = gMapManager.IndoorId and gMapManager.IndoorId >= 0

	if CoreHudButtonConfig.AirDash then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.AirDash, "isIndoor", inDoor)
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	self:InitClientStateConfig()

	local isReconnect = switchType ~= gSwitchSceneType.Reconnect

	if not isReconnect and M.eventSet then
		M:RegisterVisiableRules()
	end

	if switchType ~= gSwitchSceneType.KickToLogin then
		self.InitBindDta(self)
	end
end

M.RegisterVisiableRules = function(self)
	self.InitBindDta(self)
	self.RegisterBindHandlersOnce(self)
end

M.RegisterBindHandlersOnce = function(self)
	if self.eventSet then
		self.eventSet:Destroy()
	end

	self.eventSet = C_DataEventSet.New()

	self.eventSet:BindHandler(gRaidDataManager, "RaidId", self.bindHandlers.OnRefreshRaidId)
	self.eventSet:BindHandler2({
		self.bossViewPanelUIVisiable,
		1,
		self.onAwakeUI,
		"-\\x91殅絩\\xbe\\xd4\\xe7%\\xf6\\x9b.\\x9a\\xee"
	}, self.bindHandlers.OnRefreshBossViewPanelUIVisiable)
end

M.bindHandlers = {
	OnRefreshRaidId = function (cell)
		local raidId = cell.value
		local raidCfg = RaidConfig.GetConfig(raidId)

		if raidCfg then
			local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

			gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "hideByRaidType", raidTypeConfig.showBattleUI)
			gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.JumpJump, "hideByRaidType", raidTypeConfig.hideUIJump)
		end
	end,
	OnRefreshBossViewPanelUIVisiable = function (cell)
		if gLuaUIMgr.bossViewPanel then
			for i = 1, M.bossViewPanelUIVisiable.Count do
				local state = M.bossViewPanelUIVisiable[i]

				if i ~= 1 and state ~= 1 then
					gUIUtils:SetGoActive(gLuaUIMgr.bossViewPanel.gameObject, false)
					M:ShowMainMenuMgrMessageTipsOnEditor("隐藏boss血条面板，index:", i, "state:", state)

					return
				end
			end

			gUIUtils:SetGoActive(gLuaUIMgr.bossViewPanel.gameObject, true)
		end
	end
}

M.SetTableVisible = function(self, listData, index, value)
	if listData[index] == value then
		listData[index] = value
	end
end

M.HasUnitState = function(self, state)
	return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state) and 1 or 0
end

M.HasUnitStateBool = function(self, state)
	return gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, state)
end

M.SetFightSpiritEpFull = function(self, isFull)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "fightSpiritEpNotFull", not isFull)
end

M.CheckNoPowerState = function(self)
	local isHaveState = gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.NoMindPower)

	if isHaveState then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isNoMindPower", true)
	else
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isNoMindPower", false)
	end
end

M.CheckInCrouchAssassination = function(self)
	local isHaveState = gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.CrouchAssass)

	if isHaveState then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isCrouchAssassin", true)
	else
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isCrouchAssassin", false)
	end
end

M.NoUsePowerWhenCanInteractive = function(self, noUse)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isGamePadInteract", noUse)
end

M.DisableUltSkillByBulletNum = function(self, enable)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "disableByBulletNum", enable)
end

M.ShowSkillBtn = function(self, isShow)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Basic, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "specialReplace", not isShow)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.HeavyAttack, "specialReplace", not isShow)
end

M.SetRefreshAssassinate = function(self)
	gCoreHudUIManager:OnRefreshSkillBtn(gCoreHudUIManager.skillType.Normal)
end

M.SetBtnVisibleByBuff = function(self, pid)
	self.SetAirDashVisiableByBuff(self, pid)
end

M.SetAirDashVisiableByBuff = function(self, pid)
	local hasBuff = gBuffUtils.HasBuff(pid, LTConfig.BuffConfig.CanAirDash)

	if CoreHudButtonConfig.AirDash and pid ~= gCS.MyPlayerManager.PlayerUnit.Pid then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.AirDash, "hasBuff", hasBuff)
	end
end

M.SetState = function(self, state, isAdd)
	if state ~= UnitStateConfig.NoMindPower then
		self.CheckNoPowerState(self)
	end

	if state ~= UnitStateConfig.CrouchAssass then
		self.CheckInCrouchAssassination(self)
	end

	if state ~= UnitStateConfig.StiffS then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isStiffS", isAdd)
	end

	if state ~= UnitStateConfig.HideBattleUISkill1 then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "hideSkill1", isAdd)
	end

	if state ~= UnitStateConfig.ForbidAttack then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "forbidAttack", isAdd)
	end

	if state ~= UnitStateConfig.HideBattleUISkill2 then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Basic, "UnitStateCfgNeedHide", isAdd)
	end

	if state ~= UnitStateConfig.ForbidSkill1 then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Basic, "unitStateCfgNeedForbid", isAdd)
	end

	if state ~= UnitStateConfig.ForbidSpiritUnique then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "unitStateCfgNeedForbid", isAdd)
	end

	if state ~= UnitStateConfig.ForbidPrivateWeaponUltSkill then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "unitStateCfgNeedForbidPrivateWeaponUltSkill", isAdd and gBattleMgr.isPrivateWeapon)
	end

	if state ~= UnitStateConfig.HideBattleUIJump then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.JumpJump, "unitStateCfgNeedForbid", isAdd)
	end

	if state ~= UnitStateConfig.HideBattleButton then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.RightBottom, "stateHideBattleButton", isAdd)
	end

	if state ~= UnitStateConfig.DeadS then
		if gCS.MyPlayerManager.PlayerUnit then
			isAdd = gCS.MyPlayerManager.PlayerUnit.IsDead
		end

		self.extraVisiable.isInDeadS = isAdd

		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "stateDeadS", isAdd)
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.Hp, "stateDeadS", isAdd)
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.RightBottom, "stateDeadS", isAdd)
	end

	if state ~= UnitStateConfig.HideBattleUI then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.BattleUI, "stateHideBattleUI", isAdd)
	end

	if state ~= UnitStateConfig.HidePlayerHp then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.Hp, "stateHidePlayerHp", isAdd)
	end

	if state ~= UnitStateConfig.HideBattleUISprint then
		-- Nothing
	end

	if state ~= UnitStateConfig.HideLightHack then
		self:SetTableVisible(self.hackerScanVisiable, 2, isAdd and 1 or 0)
	end

	if state ~= UnitStateConfig.HideBossView then
		self:SetTableVisible(self.bossViewPanelUIVisiable, 1, isAdd and 1 or 0)
	end

	if state ~= UnitStateConfig.HideMiniMap then
		gMessageManager:SendMessage(gEventConstants.MINI_MAP_VISIBILITY_CHANGE, {
			["M\\x90\\x9d\\x8cO"] = "VIe}}\n=",
			visible = not isAdd
		})
	end

	if state ~= UnitStateConfig.Sitting then
		self.SetSitState(self, isAdd)
	end

	if state ~= UnitStateConfig.FightS then
		gBattleMgr.isBattleUI = isAdd
		gCS.FightDataMgr.isShowBattleUI = isAdd

		gCoreHudUIManager:RefreshBattleHudFightState()
	end

	if state ~= UnitStateConfig.ForbidAttack then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "forbidAttack", isAdd)
	end

	if state ~= UnitStateConfig.ForbidChangeWeapon then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "unitStateCfgNeedForbid", isAdd)
	end
end

M.SetAwakeUI = function(self, name)
	if self.onAwakeUI[name] > 1 then
		self.onAwakeUI[name] = 0
	else
		self.onAwakeUI[name] = 1
	end
end

M.RefreshEnemyMindInteractBtn = function(self, btnType)
	local mindIsNormalAttack = btnType ~= MindButtonTypeType.NormalSkillBtn
	local mindIsInteract = btnType ~= MindButtonTypeType.InteractBtn or btnType ~= MindButtonTypeType.ExecuteBtn

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isMonsterInteract", not mindIsNormalAttack and not mindIsInteract)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "isMonsterInteract", mindIsNormalAttack)
end

M.SetSitState = function(self, isAdd)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.RightBottom, "stateSitting", isAdd)
end

M.SetBattleSkillBtnIsInCd = function(self, skilltype, isInCd)
	if skilltype ~= gBattleMgr.SkillBtnType.Normal then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "skillInCD", isInCd)
	elseif skilltype ~= gBattleMgr.SkillBtnType.Basic then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Basic, "skillInCD", isInCd)
	elseif skilltype ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "skillInCD", isInCd)
	elseif skilltype ~= gBattleMgr.SkillBtnType.ControlPower then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "skillInCD", isInCd)
	end
end

M.ClickTaskOnTaskAndTeamState = function(self)
end

M.SetComboSkill = function(self, index)
	if self.comboSkill[index] > 1 then
		self.comboSkill[index] = 0
	else
		self.comboSkill[index] = 1
	end
end

M.SyncAllStates = function(self, states)
	self.clientState.parkourState = states.ToTable(states)
end

M.OnParkourStateChange = function(self)
	if not gCS.MyPlayerManager.PlayerUnit then
		return
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("gMainMenuMgr.OnParkourStateChange.SetParkourStateLimit")
	end

	gCS.BaseUnitModuleUtils.SetParkourStateLimitSwim(gCS.MyPlayerManager.PlayerUnit, self.CheckForbidSwim(self))
	gCS.BaseUnitModuleUtils.SetParkourStateLimitFall(gCS.MyPlayerManager.PlayerUnit, self.CheckForbidFallDown(self))

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("gMainMenuMgr.OnParkourStateChange.UpdateGlobalTipStatus")
	end

	self.UpdateGlobalTipStatus(self)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.CheckForbidFallDown = function(self)
	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if gMainMenuMgr.clientStateConfig[state].Not_FallDown ~= 1 then
			return true
		end
	end

	return false
end

M.CheckForbidSwim = function(self)
	for k, state in pairs(gMainMenuMgr:GetClientState()) do
		if gMainMenuMgr.clientStateConfig[state].Not_Swim ~= 1 then
			return true
		end
	end

	return false
end

M.UpdateGlobalTipStatus = function(self)
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

M.GetClientState = function(self)
	return self.clientState.parkourState
end

M.CheckHasClientState = function(self, state)
	if self.clientState.parkourState then
		for _, parkourState in pairs(self.clientState.parkourState) do
			if state ~= parkourState then
				return true
			end
		end
	end
end

M.InitClientStateConfig = function(self)
	self.clientStateConfig = {}

	for i = 0, ParkourStateConfig.count - 1 do
		local cfg = ParkourStateConfig.LoadAt(i)

		for parkourName, _ in pairs(self.clientStateName) do
			local attributeList = cfg[parkourName]

			self.ExchangeClientStateConfigType(self, attributeList)
		end

		self.clientStateConfig[cfg.Id] = cfg
	end
end

M.ExchangeClientStateConfigType = function(self, attributeList)
	if not attributeList or type(attributeList) == "table" then
		return
	end

	for _, item in ipairs(attributeList) do
		if type(item) ~= "table" and item.visible == nil and type(item.visible) ~= "number" and item.interactable == nil and type(item.interactable) ~= "number" then
			item.visible = item.visible == 0
			item.interactable = item.interactable == 0
		end
	end
end

M.DebugParkourStateLog = function(self, enable)
	self.debugParkourState = enable
end

M.HasTargetParkourState = function(self, targetState)
	if not gCS.MyPlayerManager.PlayerUnit then
		return false
	end

	return gCS.ParkourStateModule.HasTargetState(gCS.MyPlayerManager.PlayerUnit, targetState)
end

M.SetInMindPowerHoldMode = function(self, enable)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isMindHold", enable)
end

M.SetTriggerDisableSkill = function(self, index, value)
	self.triggerDisableBattleSkillUIVisiable[index] = value

	if value ~= 1 then
		gBattleMgr:DoSthWhenSkillBtnClose()
	end
end

M.ClearTriggerDisableSkill = function(self)
	for i = 1, self.triggerDisableBattleSkillUIVisiable.Count do
		self.triggerDisableBattleSkillUIVisiable[i] = 0
	end
end

M.SetTriggerDisableParkour = function(self)
	local count = self.triggerDisableParkourUIVisiable[1] + 1

	if count <= 10000 then
		count = 0
	end

	self.triggerDisableParkourUIVisiable[1] = count
end

M.SetUnLockSystems = function(self)
	M:ShowMainMenuMgrMessageTipsOnEditor("版署版本功能解锁:", gPlayerManager.infoMinor.bindData.UnlockSystems, "test")
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleNormalUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Basic, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleEUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BattleRUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.MindPowerUnlock))
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.HeavyAttack, "systemBattleUnlock", gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BlockState))

	M.hackerScanVisiable[4] = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.ScanUnlock) and 1 or 0
end

M.GMUnlockAllSystems = function(self, enable)
	M:SetUnLockSystems()
end

M.CheckCanVehicleInteract = function(self)
	for k, state in pairs(M:GetClientState()) do
		if M.clientStateConfig[state].CanInteractVehicleDoor ~= 0 then
			return false
		end
	end

	return true
end

M.CheckCanGroundInteract = function(self)
	local queryResult = LX6.Units.Module.TagManager.QueryTag_ParkourStateInteraction(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplayTagQueryConfig.OnGroundInteraction)

	if queryResult ~= 0 then
		for k, state in pairs(M:GetClientState()) do
			if M.clientStateConfig[state].OnGroundInteraction ~= 0 then
				return false
			end
		end
	elseif queryResult ~= 1 then
		return true
	else
		return false
	end

	return true
end

M.CheckCanChairInteract = function(self)
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	local queryResult = LX6.Units.Module.TagManager.QueryTag_ParkourStateInteraction(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplayTagQueryConfig.SitInteraction)

	if queryResult ~= 0 then
		for k, state in pairs(M:GetClientState()) do
			if M.clientStateConfig[state].SitInteraction ~= 0 then
				return false
			end
		end

		return true
	elseif queryResult ~= 1 then
		return true
	else
		return false
	end
end

M.CheckCanWallInteract = function(self)
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	local queryResult = LX6.Units.Module.TagManager.QueryTag_ParkourStateInteraction(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplayTagQueryConfig.OnWallInteraction)

	if queryResult ~= 0 then
		for k, state in pairs(M:GetClientState()) do
			if M.clientStateConfig[state].OnWallInteraction ~= 0 then
				return false
			end
		end

		return true
	elseif queryResult ~= 1 then
		return true
	else
		return false
	end
end

M.GetPaoKuStatesStr = function(self)
	local str = ""

	for k, state in pairs(M:GetClientState()) do
		str = str .. state .. ","
	end

	return str
end

M.CheckForbidSkillInAir = function(self, skillId)
	if table.isNilOrEmpty(M:GetClientState()) then
		return false
	end

	local skillCfg = SkillConfig.GetConfig(skillId)

	if skillCfg and (skillCfg.SkillCastTypeTag ~= SkillConfig.SkillCastTypeTagType.CommonAttack or skillCfg.SkillCastTypeTag ~= SkillConfig.SkillCastTypeTagType.FireAttack) then
		for k, state in pairs(M:GetClientState()) do
			if (state ~= ParkourStateConfig.Feisuo or state ~= ParkourStateConfig.Fall or state ~= ParkourStateConfig.Jump) and (skillCfg ~= nil or not skillCfg.CanUseInTheAir.CanUseInTheAir) then
				return true
			elseif skillCfg == nil and not skillCfg.CanUseInTheAir.CanUseInTheAir then
				-- Nothing
			end
		end
	end

	return false
end

M.CheckCanUseWeaponCircle = function(self)
	if gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, UnitStateConfig.ForbidChangeWeapon) then
		return false
	end

	local platform = M:GetParkourStatePlatform()

	for k, state in pairs(M:GetClientState()) do
		local wheelConfig = M.clientStateConfig[state].SwitchWeaponWheels

		if type(wheelConfig) ~= "table" and wheelConfig[platform] and not wheelConfig[platform].interactable then
			return false
		end
	end

	return true
end

M.IsParkourStateValid = function(self, stateConfig, platform)
	return type(stateConfig) ~= "table" and stateConfig[platform] and stateConfig[platform].visible == nil and stateConfig[platform].interactable == nil
end

M.GetParkourStatePlatform = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return 1
	else
		return 2
	end
end

M.AfterCheckClientState = function(self)
	gBattleMgr.canDodge = not gBattleMgr:HasDodgeDisableState()
end

M.BattleSkillSwitch = function(self, skillBtnType, active)
	if skillBtnType ~= gBattleMgr.SkillBtnType.Basic then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.Skill, "isTestSkillSwitchOn", active)
	elseif skillBtnType ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.UltSkill, "isTestSkillSwitchOn", active)
	end
end

M.SetWallJumpState = function(self, enable)
	gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.OffWall, "isOnWall", enable)
end

M.SetWallJumpStateByInturn = function(self, enable)
	gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.OffWall, "isInteractOpen", enable)
end

M.SetWeaponFightResVisiable = function(self, show)
end

M.SetWeaponFightResBySystemUnlock = function(self, enable)
end

M.SetKickOffBtnVisiable = function(self, show)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.KickOff, "isShow", show)
end

M.SetAmmunitionVisiable = function(self, show)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchWeaponWheels, "isUnShow", show)
end

M.SetAirDashVisiable = function(self, show)
	if CoreHudButtonConfig.AirDash then
		gCoreHudUIManager:OnSetSkillBtnState(CoreHudButtonConfig.AirDash, "jumpInAir", show)
	end
end

M.ForbidSkillBtnByNoSkillId = function(self, skillBtnType, noSkillId)
	if skillBtnType ~= gBattleMgr.SkillBtnType.Normal then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType) and not gCS.MyPlayerManager.PlayerUnit:HasGameplayTag(LTConfig.GameplayTagConfig.Interaction_MindPower_HoldBlend)

		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType ~= gBattleMgr.SkillBtnType.FightSpiritBigSkill then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType)

		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.UltSkill, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType ~= gBattleMgr.SkillBtnType.ControlPower then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isForbidByNoSkillId", noSkillId)
	elseif skillBtnType ~= gBattleMgr.SkillBtnType.HeavyAttack then
		noSkillId = noSkillId and gCS.GunModule.IsMeForbitSkillBtnByNoSkillId(skillBtnType)

		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.HeavyAttack, "isForbidByNoSkillId", noSkillId)
	end
end

M.SetForbidByMotoBuff = function(self, hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.HeavyAttack, "isTaFeiMoto", hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.Normal, "isTaFeiMoto", hasBuff)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.ControlPower, "isTaFeiMoto", hasBuff)
end

M.GetParkourStateMindPowerMode = function(self, config)
	local destructibleCfg = nil
	local aimItem = gCS.MindPowerMgr:GetAimItem()

	if aimItem then
		destructibleCfg = LTConfig.SceneitemConfig.GetConfig(aimItem.SceneItemConfigId)
	end

	if destructibleCfg then
		local type = destructibleCfg.MindPower_CanUseType

		self.ShowMainMenuMgrMessageTipsOnEditor(self, "GetParkourStateMindPowerMode type", type)

		if type ~= 1 then
			return config.MindPower_Destructible_One
		elseif type ~= 2 then
			return config.MindPower_Destructible_Two
		elseif type ~= 3 then
			return config.MindPower_Destructible_Three
		else
			return config.MindPower
		end
	end

	self.ShowMainMenuMgrMessageTipsOnEditor(self, "GetParkourStateMindPowerMode", config.Id)

	return config.MindPower
end

M.RefreshFullScreenLowHpAni = function(self, hpFill, force)
	local showLowHpEffect = hpFill and hpFill < GameConfig.LowHpEffectActive and hpFill >= 0 or false
	local csUnit = gCS.MyPlayerManager.PlayerUnit

	if gCS.ShootModule.GetVehicleShootState(csUnit) == LX6.Units.Module.ShootModule.VehicleShootState.None then
		gCoreHudEffectManager:SetCondition(gCoreHudEffectManager.EffectType.LowHp, false)
		self:PlayVehicleCameraLowHpAni(showLowHpEffect, force)
	else
		showLowHpEffect = showLowHpEffect and not gMainMenuMgr:HasTargetParkourState(LTConfig.ParkourStateConfig.Drive)

		self:PlayVehicleCameraLowHpAni(false, force)

		gCoreHudEffectManager.lowHpFill = hpFill

		gCoreHudEffectManager:SetCondition(gCoreHudEffectManager.EffectType.LowHp, showLowHpEffect)
	end
end

M.PlayVehicleCameraLowHpAni = function(self, showLowHpEffect, force)
end

M.ModifyCameraColorModulation = function(self, force)
	local deltaTime = Time.time - self.modifyCameraColorModulationStartTime
	local percent = deltaTime / GameConfig.CameraPostProcessVehicleLowHp.blendTime

	if force or percent > 1 then
		self:CheckDriveBattleUpdateDisable()
		gCS.CameraDataMgr.cameraEffectController:ModifyCameraColorModulations(self.modifyCameraColorModulationEndType, self.modifyCameraColorModulationEndValue)

		return
	end

	local deltaValue = self.modifyCameraColorModulationEndValue - self.modifyCameraColorModulationStartValue
	local curSaturation = self.modifyCameraColorModulationStartValue + deltaValue * percent

	gCS.CameraDataMgr.cameraEffectController:ModifyCameraColorModulations(true, curSaturation)
end

M.CheckDriveBattleUpdateEnable = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:CheckUpdateEnable()

	return store.bActive
end

M.CheckDriveBattleUpdateDisable = function(self)
	local store = gStoreManager:GetStoreGroup("CoreHudDriveBattleStore")

	store:CheckUpdateDisable()
end

M.GetCameraDragSensitivity = function(self, isHoriZontal)
	local sensitivity = isHoriZontal and ProfileManager.gameProfile.swingCameraRotateXLevel / 10 or ProfileManager.gameProfile.swingCameraRotateYLevel / 10

	if sensitivity >= 0.1 then
		sensitivity = isHoriZontal and GameConfig.FreeLookRotateXDefaultSensitivity or GameConfig.FreeLookRotateYDefaultSensitivity

		if isHoriZontal then
			ProfileManager.gameProfile.swingCameraRotateXLevel = sensitivity * 10
		else
			ProfileManager.gameProfile.swingCameraRotateYLevel = sensitivity * 10
		end

		ProfileManager.SaveGameProperty()
	end

	return sensitivity
end

M.OnDragBtnDragBegin = function(self, btn, eventPointer)
	self._skipFirstDragDeltaMap = self._skipFirstDragDeltaMap or {}
	self._skipFirstDragDeltaMap[btn] = true
end

M.OnDragBtnDraging = function(self, btn, eventPointer)
	if not eventPointer.delta then
		return
	end

	if self._skipFirstDragDeltaMap and self._skipFirstDragDeltaMap[btn] then
		self._skipFirstDragDeltaMap[btn] = nil

		return
	end

	self.OnDragBtnDragButton(self, eventPointer.delta)
end

M.OnDragBtnDragEnd = function(self, btn, eventPointer)
end

M.OnDragBtnDragButton = function(self, delta)
	local camRotateX = self.GetCameraDragSensitivity(self, true)
	local camRotateY = self.GetCameraDragSensitivity(self, false)
	local deltaX = delta.x * (1 + (camRotateX - 1) / 8 * 6) * 0.5
	local deltaY = delta.y * (1 + (camRotateY - 1) / 8 * 6) * 0.5
	local minDeltaInput = GameConfig.SwingJoystickMinInput

	if Mathf.Abs(deltaX) >= minDeltaInput.X then
		deltaX = 0
	end

	if Mathf.Abs(deltaY) >= minDeltaInput.Y then
		deltaY = 0
	end

	if deltaX == 0 or deltaY == 0 then
		local dir = Vector2.New(deltaX, deltaY)

		gCS.CameraDataMgr.cameraControllerManager:OnControlCameraAngle(dir)
	end
end

M.DebugMainMenu = function(self, enable)
	gMainMenuMgr.ShowTestMsg = enable
end

M.ShowMainMenuMgrMessageTipsOnEditor = function(self, content, ...)
	if gMainMenuMgr.ShowTestMsg then
		print_warn("纯编辑器测试：" .. content, ...)
	end
end

gMainMenuMgr = M
