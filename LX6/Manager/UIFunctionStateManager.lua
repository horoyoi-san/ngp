-- Original chunk: @Lua\LuaFiles\LX6\Manager\UIFunctionStateManager.lua
-- Decompiled from: 00359_UIFunctionStateManager.lua_42a2f684a766.luajit

local DataSet = require("LX6/DataBind/DataSet")
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local UnitStateConfig = LTConfig.UnitStateConfig
C_UIFunctionStateManager = DefClass("C_UIFunctionStateManager", C_UIFunctionStateManager)
local M = C_UIFunctionStateManager

M.ctor = function(self)
	self.STATE_DEFINE = {
		["\\xe9\\xfa76?\\xd4"] = 4,
		["NNo"] = 7,
		["I\\u"] = 8,
		["j\\x8f\\x81\\x87\\x97"] = 6,
		["\\xa3IV"] = 11,
		["}\\x86\\x8d\\x81\\x93"] = 3,
		["\\x8f\\x86\\x86\\x99"] = 13,
		["_To"] = 9,
		["wf_Bq28!"] = 10,
		["\\x8d\\x94 \\x8fH\\xdd"] = 19,
		["/}\\xa3\\xb8\\xa6x"] = 20,
		["N\\v"] = 1,
		["n\\x81\\x97\\x81\\x82"] = 22,
		["nfEGq.05"] = 21,
		["VSp"] = 15,
		["Y\n\\o"] = 22
	}
	self.StateMonitor = DataSet.New()
	self.StateMonitor.phoneEnable = {
		false,
		false
	}
	self.StateMonitor.packageEnable = {
		false,
		false
	}
	self.StateMonitor.gachaEnable = {
		false,
		false
	}
	self.StateMonitor.testEnable = {
		false,
		false
	}
	self.StateMonitor.scanEnable = {
		false,
		false
	}
	self.StateMonitor.exitEnable = {
		false,
		false
	}
	self.StateMonitor.taskListEnable = {
		false,
		false
	}
	self.StateMonitor.mapEnable = {
		false,
		false
	}
	self.StateMonitor.radioEnable = {
		false,
		false
	}
	self.StateMonitor.linkEnable = {
		false,
		false
	}
	self.StateMonitor.feedbackEnable = {
		false,
		false
	}
	self.StateMonitor.surveyEnable = {
		false,
		false
	}
	self.StateMonitor.mainPageEnable = {
		false,
		false
	}
	self.StateMonitor.chatEnable = {
		false,
		false
	}
	self._DataSetEvents = C_DataEventSet.New()
	self.dataSetEvents = {
		{
			gRaidDataManager,
			".I\\x98\\x8a\\xaaE",
			self:CreateAction("RefreshRaidIdChange")
		},
		{
			gChallengeManager.challengeData,
			"+\\xf0|$\\xdc\\xb3O\\xa6_\\xbe\\xb1",
			self:CreateAction("RefreshChallengeChange")
		},
		{
			gMainMenuMgr.extraVisiable,
			"JTEgj",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.PHONE)
		},
		{
			gMainMenuMgr.hackerScanVisiable,
			1,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gMainMenuMgr.hackerScanVisiable,
			2,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gMainMenuMgr.hackerScanVisiable,
			3,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gMainMenuMgr.hackerScanVisiable,
			4,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gMainMenuMgr.hackerScanVisiable,
			5,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gPlayerManager.main.bindData,
			"\\xf0v\"9\\xdc\\xb2D\\x93W\\xb9\\xba",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			self.StateMonitor,
			"\\x8f</1}\\xb8O\\xd85\\xa6\\xbc",
			self:CreateAction("OnPhoneEnableChangedForSummon")
		},
		{
			self.StateMonitor,
			"\\x8f</1}\\xb8O\\xd85\\xa6\\xbc",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.MAIN_PAGE)
		},
		{
			self.StateMonitor,
			"PRϩ\\xa1\\xb9\\xc5\\xed",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.CHAT)
		}
	}
	self._MsgEvents = {}
	self.msgEvents = {
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.L50_AFTER_SWITCH_SCENE] = self:CreateAction("OnAfterSwitchScene"),
		[gEventConstants.ON_KICK_TO_LOGIN] = self:CreateAction("OnKickToLogin"),
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.OPEN_VEHICLE_RADIO] = self:CreateActionWithArgs("OnSpoonHideRadio", false),
		[gEventConstants.CLOSE_VEHICLE_RADIO] = self:CreateActionWithArgs("OnSpoonHideRadio", true),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart"),
		[gEventConstants.ANDROID_CONTROL_SWITCH] = self:CreateAction("OnAndroidControlSwitch"),
		[gEventConstants.DIALOG_START] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.DIALOG_END] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.MY_UNIT_STATE_CHANGE] = self:CreateAction("OnMyUnitStateChange"),
		[gEventConstants.MINI_MAP_VISIBILITY_CHANGE] = self:CreateAction("OnMiniMapVisibilityChange"),
		[gEventConstants.ON_FORMAL_SHORT_CUT_KEY_STATE_CHANGE] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.ON_PHONE_CALL_CONTACT_UNLOCKED] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.PAOKU_STATE_ADD_REMOVE] = self:CreateAction("OnParkourAddRemove"),
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self:CreateAction("OnUpdateActivityState"),
		[gEventConstants.ON_GAMESWITCH_CHANGED] = self:CreateAction("OnGameSwitchChanged"),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self:CreateAction("OnGameWatchStateChanged"),
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentTaskChanged"),
		[gEventConstants.MOTOR_RIDER_STATE_CHANGE] = self:CreateAction("OnMotorRiderChange"),
		[gEventConstants.LINK_GAME_CFG_CHANGE] = self:CreateAction("OnLinkModeChange")
	}
	self.pvHideBtn = false
	self.CharacterSwitchControl = {
		["$)\\xf0@\\x8c\\xf6 \\xad\n\\xe8\\xf3\\xe4x\\xfe"] = true,
		["\\xc0\\x9b\\xe9\\xe7φ\\xec\\x80,-"] = true,
		["6;\\x82椲\\xfa\\x95\\xae\\x89\\xc9\\xe7ț\"\\x93\\xe7"] = true
	}
	self.RadioControl = {
		["${\\xa3\\x8f\\x8aE"] = false,
		["pWcf@6="] = false,
		["\\o\\xbfcI\\xbf\\xc7Ifu}G"] = false
	}
	self.isBaseVehicle = false
	self.isMotorRider = false
	self.isAndroidControl = false
	self.isGuidePicOpen = false
	self.miniMapVisibility = {}
	self.QuickPhoneCallControl = {
		["\\xaf524w\\x88S\\xea?\\xa5\\xae"] = true,
		["M\r\\xa0:\\xf8l\\x84t5%+r\\xb5\\xff'\\xd5\\xe2"] = true,
		Condition = {}
	}
	self._Dirty = false
	self._DirtyUpdating = false
	self._DirtyDict = {}
	self._DirtyDictBackUp = {}
	self._DirtyUpdateFunc = {
		[self.STATE_DEFINE.PHONE] = self:CreateAction("RefreshPhoneState"),
		[self.STATE_DEFINE.PACKAGE] = self:CreateAction("RefreshPackageState"),
		[self.STATE_DEFINE.TEST] = self:CreateAction("RefreshTestState"),
		[self.STATE_DEFINE.SCAN] = self:CreateAction("RefreshScanState"),
		[self.STATE_DEFINE.EXIT] = self:CreateAction("RefreshExitState"),
		[self.STATE_DEFINE.TASK_LIST] = self:CreateAction("RefreshTaskListState"),
		[self.STATE_DEFINE.MAP] = self:CreateAction("RefreshMapState"),
		[self.STATE_DEFINE.RADIO] = self:CreateAction("RefreshRadioState"),
		[self.STATE_DEFINE.LINK] = self:CreateAction("RefreshLinkEnableState"),
		[self.STATE_DEFINE.FEEDBACK] = self:CreateAction("RefreshFeedbackState"),
		[self.STATE_DEFINE.SURVEY] = self:CreateAction("RefreshSurveyState"),
		[self.STATE_DEFINE.MAIN_PAGE] = self:CreateAction("RefreshMainPageState"),
		[self.STATE_DEFINE.CHAT] = self:CreateAction("RefreshChatState")
	}
end

M.OnInit = function(self)
	self:RegisterDataSetEvents(self.dataSetEvents)
	self:RegisterMessageEvents(self.msgEvents)
	self:RefreshAllState()
end

M.RegisterDataSetEvents = function(self, eventHandlers)
	if #eventHandlers ~= 0 then
		return
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

M.ClearDataSetEvents = function(self)
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

M.RegisterSingleEvent = function(self, enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

M.RegisterMessageEvents = function(self, eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

M.ClearMessageEvents = function(self)
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

M.MarkStateDirty = function(self, state)
	if not self._DirtyUpdating then
		self._DirtyDict[state] = true
		self._Dirty = true
	elseif not self._DirtyDict[state] then
		self._DirtyDictBackUp[state] = true
	end
end

M.OnLateUpdate = function(self)
	if not self._Dirty then
		return
	end

	self._Dirty = false
	self._DirtyUpdating = true

	for k, _ in pairs(self._DirtyDict) do
		self._DirtyUpdateFunc[k]()

		self._DirtyDict[k] = nil
	end

	self._DirtyUpdating = false

	for k, _ in pairs(self._DirtyDictBackUp) do
		self._DirtyUpdateFunc[k]()

		self._DirtyDictBackUp[k] = nil
	end
end

M.RefreshAllState = function(self)
	for i = 1, self.STATE_DEFINE.COUNT do
		if self._DirtyUpdateFunc[i] then
			self._DirtyUpdateFunc[i](true)
		end
	end
end

M.RefreshRaidIdChange = function(self)
	self:MarkStateDirty(self.STATE_DEFINE.PACKAGE)
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.RADIO)
	self:MarkStateDirty(self.STATE_DEFINE.MAIN_PAGE)
	self:MarkStateDirty(self.STATE_DEFINE.TEST)
	self:MarkStateDirty(self.STATE_DEFINE.TASK_LIST)
	self:MarkStateDirty(self.STATE_DEFINE.MAP)
end

M.RefreshChallengeChange = function(self)
	self:MarkStateDirty(self.STATE_DEFINE.PACKAGE)
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.TASK_LIST)
end

M.RefreshPackageState = function(self, force)
	local state = true

	if gRaidDataManager.RaidId ~= 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIPackage ~= 2 or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state == self.StateMonitor.packageEnable[1] or force then
		self.StateMonitor.packageEnable[1] = state
		self.StateMonitor.packageEnable[2] = state

		self.StateMonitor:SendBindEvent("packageEnable")
	end
end

M.RefreshBabaState = function(self, force)
end

M.RefreshGachaState = function(self, force)
	local state = true

	if gRaidDataManager.RaidId ~= 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIGacha ~= 2 or not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.GachaUnlock) or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state == self.StateMonitor.gachaEnable[1] or force then
		self.StateMonitor.gachaEnable[1] = state
		self.StateMonitor.gachaEnable[2] = state

		self.StateMonitor:SendBindEvent("gachaEnable")
	end
end

M.RefreshTestState = function(self, force)
	local state = true
	local raidTypeConfig = self:GetCurrentRaidTypeConfig()

	if raidTypeConfig and raidTypeConfig.hideBtnUIVisiable ~= 2 or gCS.LuaUtils.IsPublish or self.pvHideBtn then
		state = false
	end

	if state == self.StateMonitor.testEnable[1] or force then
		self.StateMonitor.testEnable[1] = state
		self.StateMonitor.testEnable[2] = state

		self.StateMonitor:SendBindEvent("testEnable")
	end
end

M.RefreshPhoneState = function(self, force)
	local phoneId = gClientUtils.GetMainPhonePanelId()
	local phoneHasUnlocked = gClientUtils.CheckPanelSystemUnlocked(phoneId)

	if not phoneHasUnlocked or gRaidDataManager.RaidId ~= 0 then
		if self.StateMonitor.phoneEnable[1] or force then
			self.StateMonitor.phoneEnable[1] = false
			self.StateMonitor.phoneEnable[2] = false

			self.StateMonitor:SendBindEvent("phoneEnable")
		end

		return
	end

	local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	local openMainPhoneType = raidTypeConfig and raidTypeConfig.CanOpenMainCube or 1
	local state = not gMainMenuMgr.extraVisiable.isInDeadS and raidTypeConfig.showMainCube ~= 0 and not self.showPauseBar and openMainPhoneType ~= 1
	state = (not gLinkManager:CheckInMatchMode() or state and (gLinkManager:CheckIsInRace() or not gLinkManager:CheckIsInHideAndSeek()) and false) and state and not gChallengeManager.challengeData.IsChallenging

	if not state then
		if self.StateMonitor.phoneEnable[1] or force then
			self.StateMonitor.phoneEnable[1] = false
			self.StateMonitor.phoneEnable[2] = false

			self.StateMonitor:SendBindEvent("phoneEnable")
		end

		return
	end

	state = state and gPhonePanelRuleCheckManager:CheckPanelCanShow(phoneId)

	if not self.StateMonitor.phoneEnable[1] or self.StateMonitor.phoneEnable[2] == state or force then
		self.StateMonitor.phoneEnable[1] = true
		self.StateMonitor.phoneEnable[2] = state

		self.StateMonitor:SendBindEvent("phoneEnable")
	end
end

M.RefreshScanState = function(self, force)
	local scanEnable = self.StateMonitor.scanEnable

	if self.isBaseVehicle then
		if scanEnable[1] or scanEnable[2] or force then
			scanEnable[1] = false
			scanEnable[2] = false

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	end

	local show = 0
	local oldChecker = gMainMenuMgr.hackerScanVisiable

	for i = 1, oldChecker.Count do
		local checker = oldChecker[i]

		if i ~= 5 and checker ~= 0 and show >= 1 then
			show = 1
		end

		if i ~= 1 and checker ~= 0 or i ~= 2 and checker ~= 1 or i ~= 3 and checker ~= 1 or i ~= 4 and checker ~= 0 or gPlayerManager.main.bindData.isInSlideRail then
			if show >= 2 then
				show = 2
			end

			return
		end
	end

	if show ~= 1 then
		if scanEnable[1] or not scanEnable[2] or force then
			scanEnable[1] = false
			scanEnable[2] = true

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	elseif show ~= 2 then
		if scanEnable[1] or scanEnable[2] or force then
			scanEnable[1] = false
			scanEnable[2] = false

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	end

	if not scanEnable[1] or not scanEnable[2] or force then
		scanEnable[1] = true
		scanEnable[2] = true

		self.StateMonitor:SendBindEvent("scanEnable")
	end
end

M.RefreshExitState = function(self, force)
	local isInXinShouRaid = gUIUtils:IsInXinShouRaid()
	local visible = false
	local interactable = false

	if gRaidDataManager.RaidId == 0 then
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
		interactable = raidTypeConfig.CanEscape or gChallengeManager.challengeData.IsChallenging

		if gLinkManager:CheckInMatchMode() then
			interactable = interactable or gLinkManager:CheckIsInRace() or gLinkManager:CheckIsInHideAndSeek()
		end
	end

	interactable = interactable or self.showPauseBar
	visible = interactable and not isInXinShouRaid

	if self.StateMonitor.exitEnable[1] == visible or self.StateMonitor.exitEnable[2] == interactable or force then
		self.StateMonitor.exitEnable[1] = visible
		self.StateMonitor.exitEnable[2] = interactable

		self.StateMonitor:SendBindEvent("exitEnable")
	end
end

M.RefreshXuWeiState = function(self, force)
end

M.RefreshTaskListState = function(self, force)
	local state = true
	local raidTypeConfig = self:GetCurrentRaidTypeConfig()

	if raidTypeConfig then
		local hideTaskConfig = raidTypeConfig.hideTaskList

		if (hideTaskConfig == 1 or gChallengeManager.challengeData.IsChallenging) and (hideTaskConfig ~= 2 or hideTaskConfig ~= 3 or hideTaskConfig ~= 4 or gChallengeManager.challengeData.IsChallenging) then
			state = false
		end
	end

	if state == self.StateMonitor.taskListEnable[1] or force then
		self.StateMonitor.taskListEnable[1] = state
		self.StateMonitor.taskListEnable[2] = state

		self.StateMonitor:SendBindEvent("taskListEnable")
	end
end

M.RefreshMapState = function(self, force)
	local state = true
	local raidTypeConfig = self:GetCurrentRaidTypeConfig()

	if raidTypeConfig and raidTypeConfig.hideUIMiniMap ~= 2 then
		state = false
	end

	local player = gCS.MyPlayerManager.PlayerUnit

	if player and gCS.UnitStateMgr:HasState(player, UnitStateConfig.HideMiniMap) then
		state = false
	end

	for _, visible in pairs(self.miniMapVisibility) do
		if not visible then
			state = false

			break
		end
	end

	if state == self.StateMonitor.mapEnable[1] or force then
		self.StateMonitor.mapEnable[1] = state
		self.StateMonitor.mapEnable[2] = state

		self.StateMonitor:SendBindEvent("mapEnable")

		if state then
			gMapUtils:ShowMiniMap()
		else
			gMapUtils:CloseMiniMap()
		end
	end
end

M.RefreshCharacterSwitchState = function(self, force)
end

M.RefreshMiniMapArrestState = function(self)
	gMessageManager:SendMessage(gEventConstants.MINIMAP_ARREST_STATE_UPDATE)
end

M.RefreshRadioState = function(self, force)
	self.RadioControl.XSRaid = gUIUtils:IsInXinShouRaid()
	self.RadioControl.SystemUnlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.CarRadio)
	local state = true

	if not self.RadioControl.SystemUnlock or self.RadioControl.XSRaid or self.RadioControl.SpoonHide then
		state = false
	end

	if state == self.StateMonitor.radioEnable[1] or force then
		self.StateMonitor.radioEnable[1] = state
		self.StateMonitor.radioEnable[2] = state

		self.StateMonitor:SendBindEvent("radioEnable")
	end
end

M.RefreshMotionActionState = function(self, force)
end

M.SetMotionActionState = function(self, visible, interactable, force)
end

M.RefreshLinkEnableState = function(self, force)
	local state = gLinkManager:CheckLinkEnable()

	if state == self.StateMonitor.linkEnable[1] or force then
		self.StateMonitor.linkEnable[1] = state
		self.StateMonitor.linkEnable[2] = state

		self.StateMonitor:SendBindEvent("linkEnable")
	end
end

M.RefreshActivityState = function(self, force)
end

M.RefreshFeedbackState = function(self, force)
	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.FeedbackUnlock) and LTConfig.InformConfig.EnableFeedback

	if state == self.StateMonitor.feedbackEnable[1] or force then
		self.StateMonitor.feedbackEnable[1] = state
		self.StateMonitor.feedbackEnable[2] = state

		self.StateMonitor:SendBindEvent("feedbackEnable")
	end
end

M.RefreshSurveyState = function(self, force)
	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Survey)

	if state == self.StateMonitor.surveyEnable[1] or force then
		self.StateMonitor.surveyEnable[1] = state
		self.StateMonitor.surveyEnable[2] = state

		self.StateMonitor:SendBindEvent("surveyEnable")
	end
end

M.RefreshMainPageState = function(self, force)
	local state = self.StateMonitor.phoneEnable[2]
	local raidCfg = LTConfig.RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	local openMainPhoneType = raidTypeCfg and raidTypeCfg.CanOpenMainCube or 1
	local curTaskNeedPause = self.showPauseBar

	if openMainPhoneType ~= 1 and not curTaskNeedPause then
		state = self.StateMonitor.phoneEnable[2]
	elseif openMainPhoneType ~= 2 or curTaskNeedPause then
		state = false
	end

	if state == self.StateMonitor.mainPageEnable[2] or force then
		self.StateMonitor.mainPageEnable[1] = state
		self.StateMonitor.mainPageEnable[2] = state

		self.StateMonitor:SendBindEvent("mainPageEnable")
	end
end

M.RefreshChatState = function(self, force)
	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Friend)

	if gLinkManager:CheckInLinkMode() then
		state = false
	end

	if state == self.StateMonitor.chatEnable[1] or force then
		self.StateMonitor.chatEnable[1] = state
		self.StateMonitor.chatEnable[2] = state

		self.StateMonitor:SendBindEvent("chatEnable")
	end
end

M.RefreshQuickPhoneCallCommonState = function(self, force)
end

M.RefreshQuickPhoneCallMilkState = function(self, force)
end

M.GetQuickPhoneCallSate = function(self, contactId)
	if gLinkManager.watchState then
		return false, false
	end

	if self:CheckVehicleSpiritLimit() then
		return false, false
	end

	if gCallPhoneUtils.CheckPhoneCallConflict() then
		return false, false
	end

	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local isPhoneAppCanOpen = self.StateMonitor.phoneEnable[2]
	local isEnableFormalShortCutKey = gGmUtils:GetFormalShortCutKeyState()
	local isParkourShow = self.QuickPhoneCallControl.ParkourShow
	local isParkourInteract = self.QuickPhoneCallControl.ParkourInteractable
	local contactCfg = LTConfig.PhoneContactConfig.GetConfig(contactId)
	local hasUnlock = gCallPhoneUtils.CheckConfigContactHasUnlock(spiritId, contactCfg.Id)
	local checkPass = true

	if not string.is_null_or_empty(contactCfg.Check) then
		local success, flag = gClientUtils.RunCode(contactCfg.Check, gDialogScriptFunc)

		if not success or not flag then
			checkPass = false
		end
	end

	local canCallVehicle = self.QuickPhoneCallControl.Condition[contactId]
	local state = hasUnlock and checkPass and canCallVehicle and isEnableFormalShortCutKey and isPhoneAppCanOpen

	return state and isParkourShow, state and isParkourInteract
end

M.CheckVehicleSpiritLimit = function(self)
	return false
end

M.OnSystemUnlock = function(self, eventId, id)
	if id ~= SystemUnlockConfig.MainPanelUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	elseif id ~= SystemUnlockConfig.SwitchSpiritWheel then
		-- Nothing
	elseif id ~= SystemUnlockConfig.CarRadio then
		self:MarkStateDirty(self.STATE_DEFINE.RADIO)
	elseif id ~= SystemUnlockConfig.HUDPlayerMotionEntrance then
		-- Nothing
	elseif id ~= SystemUnlockConfig.LinkUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.LINK)
	elseif id ~= SystemUnlockConfig.AwardActivity then
		-- Nothing
	elseif id ~= SystemUnlockConfig.FeedbackUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.FEEDBACK)
	elseif id ~= SystemUnlockConfig.Survey then
		self:MarkStateDirty(self.STATE_DEFINE.SURVEY)
	elseif id ~= SystemUnlockConfig.Friend then
		self:MarkStateDirty(self.STATE_DEFINE.CHAT)
	end

	self:MarkQuickPhoneCallDirty()
end

M.OnGameSwitchChanged = function(self)
	self:MarkStateDirty(self.STATE_DEFINE.LINK)
end

M.OnGameWatchStateChanged = function(self)
	self:MarkQuickPhoneCallDirty()
end

M.OnMyUnitStateChange = function(self)
	self:MarkQuickPhoneCallDirty()
	self:MarkStateDirty(self.STATE_DEFINE.MAP)
end

M.OnMiniMapVisibilityChange = function(self, _, data)
	if not data or not data.reason or data.visible ~= nil then
		return
	end

	self.miniMapVisibility[data.reason] = data.visible

	self:MarkStateDirty(self.STATE_DEFINE.MAP)
end

M.OnCurrentTaskChanged = function(self)
	self.showPauseBar = gTaskNodeManager:CheckCurTaskShowPause()

	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.MAIN_PAGE)
end

M.OnKickToLogin = function(self)
	self.CharacterSwitchControl = {
		["$)\\xf0@\\x8c\\xf6 \\xad\n\\xe8\\xf3\\xe4x\\xfe"] = true,
		["\\xc0\\x9b\\xe9\\xe7φ\\xec\\x80,-"] = true,
		["6;\\x82椲\\xfa\\x95\\xae\\x89\\xc9\\xe7ț\"\\x93\\xe7"] = true
	}

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "unitStateEnable", true)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.SwitchCharacterWheels, "gameplayEnable", true)
	table.clear(self.miniMapVisibility)
end

M.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType == gSwitchSceneType.KickToLogin then
		table.clear(self.miniMapVisibility)
		self:RefreshAllState()
	end
end

M.OnPanelShow = function(self, eventId, panelId)
	if panelId ~= gPanelId.S_DIALOG_22N_PANEL then
		-- Nothing
	end

	self:MarkQuickPhoneCallDirty()
end

M.OnPanelClose = function(self, eventId, panelId)
	if panelId ~= gPanelId.S_DIALOG_22N_PANEL then
		-- Nothing
	end

	self:MarkQuickPhoneCallDirty()
end

M.OnLinkModeChange = function(self)
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.CHAT)
end

M.OnSpoonHideRadio = function(self, hide)
	self.RadioControl.SpoonHide = hide

	self:MarkStateDirty(self.STATE_DEFINE.RADIO)
end

M.OnEnterBaseVehicleFinish = function(self)
	self.isBaseVehicle = true

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

M.OnExitBaseVehicleStart = function(self)
	self.isBaseVehicle = false

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

M.OnAndroidControlSwitch = function(self, eventId, data)
	self.isAndroidControl = data.enterOrLeave
end

M.OnSummonCommonConditionChange = function(self, canSummonCommonVehicle)
	if gCoreHudUIManager then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.PhoneCall, "vehicleCondition", canSummonCommonVehicle ~= true)
	end
end

M.OnSummonMilkConditionChange = function(self, canSummonMilk)
	if gCoreHudUIManager then
		gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.MilkCar, "vehicleCondition", canSummonMilk ~= true)
	end
end

M.OnParkourAddRemove = function(self, eventId, data)
	local isParkourShow = true

	for _, state in pairs(gMainMenuMgr:GetClientState()) do
		local btnState = gMainMenuMgr.clientStateConfig[state].Phone_ShortCuts ~= 1
		isParkourShow = isParkourShow and btnState
	end
end

M.OnMotorRiderChange = function(self, eventId, isInMotor)
	if isInMotor then
		self.isMotorRider = true
	else
		self.isMotorRider = false
	end
end

M.OnUpdateActivityState = function(self)
end

M.OnPhoneEnableChangedForSummon = function(self)
	if not gCoreHudUIManager then
		return
	end

	local enable = self.StateMonitor.phoneEnable[2]

	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.PhoneCall, "phoneAppEnable", enable)
	gCoreHudUIManager:OnSetSkillBtnState(gCoreHudUIManager.skillType.MilkCar, "phoneAppEnable", enable)
end

M.MarkQuickPhoneCallDirty = function(self)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
end

M.GetPhoneEnable = function(self)
	return self.StateMonitor.phoneEnable
end

M.GetPackageEnable = function(self)
	return self.StateMonitor.packageEnable
end

M.GetXuWeiEnable = function(self)
	return self.StateMonitor.xuWeiEnable
end

M.GetGachaEnable = function(self)
	return false
end

M.GetTestEnable = function(self)
	return self.StateMonitor.testEnable
end

M.GetScanEnable = function(self)
	return self.StateMonitor.scanEnable
end

M.GetExitEnable = function(self)
	return self.StateMonitor.exitEnable
end

M.GetTaskListEnable = function(self)
	return self.StateMonitor.taskListEnable
end

M.GetMapEnable = function(self)
	return self.StateMonitor.mapEnable
end

M.GetRadioEnable = function(self)
	return self.StateMonitor.radioEnable
end

M.GetLinkEnable = function(self)
	return self.StateMonitor.linkEnable
end

M.GetFeedbackEnable = function(self)
	return {
		false
	}
end

M.GetSurveyEnable = function(self)
	return self.StateMonitor.surveyEnable
end

M.GetQuickPhoneCallCommonStateEnable = function(self)
end

M.GetQuickPhoneCallMilkStateEnable = function(self)
end

M.GetMainPageEnable = function(self)
	return self.StateMonitor.mainPageEnable
end

M.GetChatEnable = function(self)
	return self.StateMonitor.chatEnable
end

M.CheckCanOpenMainCubeUI = function(self)
	local open = true

	if gPlayerManager.main.bindData.isInClimbing then
		open = false
	end

	return open
end

M.OpenSchedule = function(self)
end

M.OpenBaba = function(self)
end

M.OpenPhone = function(self)
	if not self:CheckCanOpenMainCubeUI() then
		return
	end

	gClientUtils.OpenMainPhonePanel()
end

M.OpenPackage = function(self)
	if not gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.PackageId) then
		return
	end

	gCommonItemManager:OpenInventoryPanel()
end

M.OpenXuWei = function(self)
	if not gUIUtils:CheckCanOpenCardPanel() then
		return
	end

	gSpiritManager:ShowLingMainPanel()
end

M.OpenTest = function(self)
end

M.OpenExit = function(self)
	if gLinkManager:CheckInMatchMode() then
		if gLinkManager:CheckIsInRace() or gLinkManager:CheckIsInHideAndSeek() then
			gPanelManager:CheckShow(gPanelId.XINSHOU_EXIT)

			return
		end

		gLinkManager:TryExit()

		return
	end

	if gUIUtils:IsInXinShouRaid() or self.showPauseBar or gRaidDataManager:CheckShowSideBar() then
		gPanelManager:CheckShow(gPanelId.XINSHOU_EXIT)

		return
	end

	if gUIUtils:IsInSeasonRaid() then
		gPanelManager:CheckShow(gPanelId.S_SEASON_EXIT_PANEL)

		return
	end

	if gUIUtils:IsInBattleRaid() then
		return
	end

	if gChallengeManager.challengeData.IsChallenging then
		gChallengeManager:TryExit()

		return
	end
end

M.OpenTaskList = function(self)
	gPanelManager:CheckShow(gPanelId.S_TASK_LIST)
end

M.OpenMap = function(self)
	gMapUtils:CheckRaidCanOpenMap()
end

M.OpenCharacterSwitch = function(self)
	gPanelManager:CheckShow(gPanelId.S_SWAP_CHARACTER_LIST_PANEL)
end

M.ReleaseCloseCharacterSwitch = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gPanelManager:Close(gPanelId.S_SWAP_CHARACTER_LIST_PANEL)
	end
end

M.Scan = function(self)
	L50.L50App.Scene.ScanMgr:OnTriggerScan()
end

M.OpenTalentTree = function(self, showData)
	if not gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TalentTreeId) then
		return
	end

	gPanelManager:CheckShow(gPanelId.TALENT_TREE_PANEL, showData)
end

M.MailOpenTrigger = function(self, showData)
	gPanelManager:CheckShow(gPanelId.S_MAIL_PANEL, showData)
end

M.TalentTreeCheckCanShow = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.TalentTreeId)
end

M.InventoryCheckCanShow = function(self)
	return gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.PackageId)
end

M.TalentTreeOpenTrigger = function(self, showData)
	gPanelManager:CheckShow(gPanelId.TALENT_TREE_PANEL, showData)
end

M.TriggerCarSummon = function(self)
	gCallPhoneUtils.OnCarSummonBtnClick()
end

M.TriggerMilkCarSummon = function(self)
	gCallPhoneUtils.OnMilkCarSummonBtnClick()
end

M.OpenChat = function(self)
	gSocialChatManager:OpenChatUI()
end

M.PVHideBtn = function(self, hide)
	self.pvHideBtn = hide

	self:MarkStateDirty(self.STATE_DEFINE.TEST)
end

M.SetBtnControl = function(self, btnStore, visible, interactable)
	gStoreButtonMgr:SetButtonControlBase(btnStore, visible, interactable)
end

M.SetBtnActive = function(self, btn, active)
	btn:SetActive(active)
end

M.RefreshInventoryBtnState = function(self, btn, btnStore)
	local state = self.StateMonitor.packageEnable

	self:SetBtnControl(btnStore, state[1], state[2])
	self:SetBtnActive(btn, state[2])
end

M.RefreshPhoneBtnState = function(self, btn, btnStore)
	local state = self.StateMonitor.phoneEnable

	self:SetBtnControl(btnStore, state[1], state[2])
	self:SetBtnActive(btn, state[2])
end

M.RefreshChatBtnState = function(self, btn, btnStore)
	local state = self.StateMonitor.chatEnable

	self:SetBtnActive(btn, state[1])
end

M.GetCurrentRaidTypeConfig = function(self)
	if gRaidDataManager.RaidId ~= 0 then
		return nil
	end

	local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)

	return raidCfg and RaidRaidTypeConfig.GetConfig(raidCfg.RaidType) or nil
end

gUIFunctionStateManager = gUIFunctionStateManager or C_UIFunctionStateManager.new()
