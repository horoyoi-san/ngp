local DataSet = require("LX6/DataBind/DataSet")
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local RaidConfig = LTConfig.RaidConfig
local RaidRaidTypeConfig = LTConfig.RaidRaidTypeConfig
local MessageConfig = LTConfig.MessageConfig
local MobileMenuSGuiConfig = LTConfig.MobileMenuSGuiConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
local PhoneConfig = LTConfig.PhoneConfig
C_UIFunctionStateManager = DefClass("C_UIFunctionStateManager", C_UIFunctionStateManager)
local M = C_UIFunctionStateManager

function M:ctor()
	self.STATE_DEFINE = {
		PACKAGE = 4,
		QUICK_PHONE_COMMON = 16,
		XUWEI = 5,
		GACHA = 6,
		SCAN = 8,
		PHONE = 3,
		TEST = 7,
		MAP = 11,
		TASK_LIST = 10,
		FEEDBACK = 19,
		SURVEY = 20,
		COUNT = 21,
		MAIN_PAGE = 21,
		MOTION_ACTION = 14,
		BABA = 2,
		CHARACTER = 12,
		EXIT = 9,
		RADIO = 13,
		ACTIVITY = 18,
		TEAM = 1,
		LINK = 15,
		QUICK_PHONE_MILK = 17
	}
	self.StateMonitor = DataSet.New()
	self.StateMonitor.teamEnable = {
		false,
		false
	}
	self.StateMonitor.babaEnable = {
		false,
		false
	}
	self.StateMonitor.phoneEnable = {
		false,
		false
	}
	self.StateMonitor.packageEnable = {
		false,
		false
	}
	self.StateMonitor.xuWeiEnable = {
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
	self.StateMonitor.characterSwitchEnable = {
		false,
		false
	}
	self.StateMonitor.radioEnable = {
		false,
		false
	}
	self.StateMonitor.motionActionEnable = {
		false,
		false
	}
	self.StateMonitor.linkEnable = {
		false,
		false
	}
	self.StateMonitor.quickPhoneCallCommonEnable = {
		false,
		false
	}
	self.StateMonitor.quickPhoneCallMilkEnable = {
		false,
		false
	}
	self.StateMonitor.activityEnable = {
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
	self._DataSetEvents = C_DataEventSet.New()
	self.dataSetEvents = {
		{
			gRaidDataManager,
			"RaidId",
			self:CreateAction("RefreshRaidIdChange")
		},
		{
			gChallengeManager.challengeData,
			"IsChallenging",
			self:CreateAction("RefreshChallengeChange")
		},
		{
			gMainMenuMgr.chatSimpleUIVisiable,
			1,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.BABA)
		},
		{
			gMainMenuMgr.chatSimpleUIVisiable,
			2,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.BABA)
		},
		{
			gMainMenuMgr.chatSimpleUIVisiable,
			3,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.BABA)
		},
		{
			gMainMenuMgr.deviceStatusBtnUIVisiable,
			1,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.TEST)
		},
		{
			gMainMenuMgr.extraVisiable,
			"isInDeadS",
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
			"isInSlideRail",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.SCAN)
		},
		{
			gMainMenuMgr.taskGuideVisiable,
			1,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.TASK_LIST)
		},
		{
			gMainMenuMgr.taskAndTeamState,
			"isShowTask",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.TASK_LIST)
		},
		{
			gMainMenuMgr.miniMapNewPanelUIVisiable,
			1,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.MAP)
		},
		{
			gMainMenuMgr.miniMapNewPanelUIVisiable,
			2,
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.MAP)
		},
		{
			self.StateMonitor,
			"phoneEnable",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.QUICK_PHONE_COMMON)
		},
		{
			self.StateMonitor,
			"phoneEnable",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.QUICK_PHONE_MILK)
		},
		{
			self.StateMonitor,
			"phoneEnable",
			self:CreateActionWithArgs("MarkStateDirty", self.STATE_DEFINE.MAIN_PAGE)
		}
	}
	self._MsgEvents = {}
	self.msgEvents = {
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = self:CreateAction("OnSystemUnlock"),
		[gEventConstants.AFTER_SWITCH_SCENE] = self:CreateAction("OnAfterSwitchScene"),
		[gEventConstants.ON_KICK_TO_LOGIN] = self:CreateAction("OnKickToLogin"),
		[gEventConstants.PANEL_ON_SHOW] = self:CreateAction("OnPanelShow"),
		[gEventConstants.PANEL_ON_CLOSE] = self:CreateAction("OnPanelClose"),
		[gEventConstants.LINK_MODE_CHANGE] = self:CreateAction("OnLinkModeChange"),
		[gEventConstants.ENTER_VEHICLE_FINISH] = self:CreateAction("OnEnterVehicleFinish"),
		[gEventConstants.EXIT_VEHICLE_START] = self:CreateAction("OnExitVehicleStart"),
		[gEventConstants.OPEN_VEHICLE_RADIO] = self:CreateActionWithArgs("OnSpoonHideRadio", false),
		[gEventConstants.CLOSE_VEHICLE_RADIO] = self:CreateActionWithArgs("OnSpoonHideRadio", true),
		[gEventConstants.ENTER_BASE_VEHICLE_FINISH] = self:CreateAction("OnEnterBaseVehicleFinish"),
		[gEventConstants.EXIT_BASE_VEHICLE_START] = self:CreateAction("OnExitBaseVehicleStart"),
		[gEventConstants.ANDROID_CONTROL_SWITCH] = self:CreateAction("OnAndroidControlSwitch"),
		[gEventConstants.DIALOG_START] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.DIALOG_END] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.MY_UNIT_STATE_CHANGE] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.ON_FORMAL_SHORT_CUT_KEY_STATE_CHANGE] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.ON_PHONE_CALL_CONTACT_UNLOCKED] = self:CreateAction("MarkQuickPhoneCallDirty"),
		[gEventConstants.PAOKU_STATE_ADD_REMOVE] = self:CreateAction("OnParkourAddRemove"),
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self:CreateAction("OnUpdateActivityState"),
		[gEventConstants.ON_GAMESWITCH_CHANGED] = self:CreateAction("OnGameSwitchChanged"),
		[gEventConstants.ONLINE_INGAME_WATCH_STATE_CHANGE] = self:CreateAction("OnGameWatchStateChanged"),
		[gEventConstants.CURRENT_TASK_CHANGE] = self:CreateAction("OnCurrentTaskChanged")
	}
	self.pvHideBtn = false
	self.babaBlockCount = 0
	self.CharacterSwitchControl = {
		UnitStateEnable = true,
		GameplayEnable = true,
		Dialog22Enable = true,
		ParkourStateEnable = true
	}
	self.isDrive = false
	self.RadioControl = {
		XSRaid = false,
		SpoonHide = false,
		SystemUnlock = false
	}
	self.isBaseVehicle = false
	self.isAndroidControl = false
	self.isGuidePicOpen = false
	self.QuickPhoneCallControl = {
		Parkour = false,
		Condition = {}
	}
	self._Dirty = false
	self._DirtyUpdating = false
	self._DirtyDict = {}
	self._DirtyDictBackUp = {}
	self._DirtyUpdateFunc = {
		[self.STATE_DEFINE.TEAM] = self:CreateAction("RefreshTeamState"),
		[self.STATE_DEFINE.BABA] = self:CreateAction("RefreshBabaState"),
		[self.STATE_DEFINE.PHONE] = self:CreateAction("RefreshPhoneState"),
		[self.STATE_DEFINE.PACKAGE] = self:CreateAction("RefreshPackageState"),
		[self.STATE_DEFINE.XUWEI] = self:CreateAction("RefreshXuWeiState"),
		[self.STATE_DEFINE.GACHA] = self:CreateAction("RefreshGachaState"),
		[self.STATE_DEFINE.TEST] = self:CreateAction("RefreshTestState"),
		[self.STATE_DEFINE.SCAN] = self:CreateAction("RefreshScanState"),
		[self.STATE_DEFINE.EXIT] = self:CreateAction("RefreshExitState"),
		[self.STATE_DEFINE.TASK_LIST] = self:CreateAction("RefreshTaskListState"),
		[self.STATE_DEFINE.MAP] = self:CreateAction("RefreshMapState"),
		[self.STATE_DEFINE.CHARACTER] = self:CreateAction("RefreshCharacterSwitchState"),
		[self.STATE_DEFINE.RADIO] = self:CreateAction("RefreshRadioState"),
		[self.STATE_DEFINE.MOTION_ACTION] = self:CreateAction("RefreshMotionActionState"),
		[self.STATE_DEFINE.LINK] = self:CreateAction("RefreshLinkEnableState"),
		[self.STATE_DEFINE.QUICK_PHONE_COMMON] = self:CreateAction("RefreshQuickPhoneCallCommonState"),
		[self.STATE_DEFINE.QUICK_PHONE_MILK] = self:CreateAction("RefreshQuickPhoneCallMilkState"),
		[self.STATE_DEFINE.ACTIVITY] = self:CreateAction("RefreshActivityState"),
		[self.STATE_DEFINE.FEEDBACK] = self:CreateAction("RefreshFeedbackState"),
		[self.STATE_DEFINE.SURVEY] = self:CreateAction("RefreshSurveyState"),
		[self.STATE_DEFINE.MAIN_PAGE] = self:CreateAction("RefreshMainPageState")
	}
end

function M:OnInit()
	self:RegisterDataSetEvents(self.dataSetEvents)
	self:RegisterMessageEvents(self.msgEvents)
	self:RefreshAllState()
end

function M:RegisterDataSetEvents(eventHandlers)
	if #eventHandlers == 0 then
		return
	end

	for i = 1, #eventHandlers do
		local handler = eventHandlers[i]

		self._DataSetEvents:BindHandler(unpack(handler))
	end
end

function M:ClearDataSetEvents()
	if self._DataSetEvents then
		self._DataSetEvents:Clear()
	end
end

function M:RegisterSingleEvent(enentId, func)
	self._MsgEvents[#self._MsgEvents + 1] = {
		eventid = enentId,
		func = func
	}

	gMessageManager:AddMessageListener(enentId, func)
end

function M:RegisterMessageEvents(eventHandlers)
	for k, v in pairs(eventHandlers) do
		self:RegisterSingleEvent(k, v)
	end
end

function M:ClearMessageEvents()
	for i, v in pairs(self._MsgEvents) do
		gMessageManager:RemoveMessageListener(v.eventid, v.func)
	end

	table.clear(self._MsgEvents)
end

function M:MarkStateDirty(state)
	if not self._DirtyUpdating then
		self._DirtyDict[state] = true
		self._Dirty = true
	elseif not self._DirtyDict[state] then
		self._DirtyDictBackUp[state] = true
	end
end

function M:OnLateUpdate()
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

function M:RefreshAllState()
	for i = 1, self.STATE_DEFINE.COUNT do
		self._DirtyUpdateFunc[i](true)
	end
end

function M:RefreshRaidIdChange()
	self:MarkStateDirty(self.STATE_DEFINE.PACKAGE)
	self:MarkStateDirty(self.STATE_DEFINE.GACHA)
	self:MarkStateDirty(self.STATE_DEFINE.TEAM)
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.XUWEI)
	self:MarkStateDirty(self.STATE_DEFINE.RADIO)
	self:MarkStateDirty(self.STATE_DEFINE.ACTIVITY)
	self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	self:MarkStateDirty(self.STATE_DEFINE.MAIN_PAGE)
end

function M:RefreshChallengeChange()
	self:MarkStateDirty(self.STATE_DEFINE.PACKAGE)
	self:MarkStateDirty(self.STATE_DEFINE.GACHA)
	self:MarkStateDirty(self.STATE_DEFINE.TEAM)
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.BABA)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.XUWEI)
	self:MarkStateDirty(self.STATE_DEFINE.TASK_LIST)
end

function M:RefreshTeamState(force)
	local state = true

	if gRaidDataManager.RaidId == 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIXuWei == 2 or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state ~= self.StateMonitor.teamEnable[1] or force then
		self.StateMonitor.teamEnable[1] = state
		self.StateMonitor.teamEnable[2] = state

		self.StateMonitor:SendBindEvent("teamEnable")
	end
end

function M:RefreshPackageState(force)
	local state = true

	if gRaidDataManager.RaidId == 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIPackage == 2 or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state ~= self.StateMonitor.packageEnable[1] or force then
		self.StateMonitor.packageEnable[1] = state
		self.StateMonitor.packageEnable[2] = state

		self.StateMonitor:SendBindEvent("packageEnable")
	end
end

function M:RefreshBabaState(force)
	local state = true
	local oldChatChecker = gMainMenuMgr.chatSimpleUIVisiable

	for i = 1, oldChatChecker.Count do
		local checker = oldChatChecker[i]

		if i == 1 and checker == 2 or i == 2 and checker == 1 or i == 3 and checker == 1 then
			state = false
		end
	end

	state = state and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BaBa) and not gChallengeManager.challengeData.IsChallenging and self.babaBlockCount == 0

	if state ~= self.StateMonitor.babaEnable[1] or force then
		self.StateMonitor.babaEnable[1] = state
		self.StateMonitor.babaEnable[2] = state

		self.StateMonitor:SendBindEvent("babaEnable")
	end
end

function M:RefreshGachaState(force)
	local state = true

	if gRaidDataManager.RaidId == 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIGacha == 2 or not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.GachaUnlock) or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state ~= self.StateMonitor.gachaEnable[1] or force then
		self.StateMonitor.gachaEnable[1] = state
		self.StateMonitor.gachaEnable[2] = state

		self.StateMonitor:SendBindEvent("gachaEnable")
	end
end

function M:RefreshTestState(force)
	local state = true
	local oldChecker = gMainMenuMgr.deviceStatusBtnUIVisiable

	for i = 1, oldChecker.Count do
		local checker = oldChecker[i]

		if checker == 2 or gCS.LuaUtils.IsNotUseGM then
			state = false
		end
	end

	if self.pvHideBtn then
		state = false
	end

	if state ~= self.StateMonitor.testEnable[1] or force then
		self.StateMonitor.testEnable[1] = state
		self.StateMonitor.testEnable[2] = state

		self.StateMonitor:SendBindEvent("testEnable")
	end
end

function M:RefreshPhoneState(force)
	local phoneId = gClientUtils.GetMainPhonePanelId()
	local phoneHasUnlocked = gClientUtils.CheckPanelSystemUnlocked(phoneId)

	if not phoneHasUnlocked or gRaidDataManager.RaidId == 0 then
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
	local state = not gMainMenuMgr.extraVisiable.isInDeadS and raidTypeConfig.showMainCube == 0 and not self.showPauseBar and openMainPhoneType == 1

	if gLinkManager:CheckInMatchMode() then
		state = state and not gLinkManager:CheckIsInRace()
	else
		state = state and not gChallengeManager.challengeData.IsChallenging
	end

	if not state then
		if self.StateMonitor.phoneEnable[1] or force then
			self.StateMonitor.phoneEnable[1] = false
			self.StateMonitor.phoneEnable[2] = false

			self.StateMonitor:SendBindEvent("phoneEnable")
		end

		return
	end

	state = state and gPhonePanelRuleCheckManager:CheckPanelCanShow(phoneId)

	if not self.StateMonitor.phoneEnable[1] or self.StateMonitor.phoneEnable[2] ~= state or force then
		self.StateMonitor.phoneEnable[1] = true
		self.StateMonitor.phoneEnable[2] = state

		self.StateMonitor:SendBindEvent("phoneEnable")
	end
end

function M:RefreshScanState(force)
	if self.isDrive or self.isBaseVehicle then
		if self.StateMonitor.scanEnable[1] or self.StateMonitor.scanEnable[2] or force then
			self.StateMonitor.scanEnable[1] = false
			self.StateMonitor.scanEnable[2] = false

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	end

	local show = 0
	local oldChecker = gMainMenuMgr.hackerScanVisiable

	for i = 1, oldChecker.Count do
		local checker = oldChecker[i]

		if i == 5 and checker == 0 and show < 1 then
			show = 1
		end

		if i == 1 and checker == 0 or i == 2 and checker == 1 or i == 3 and checker == 1 or i == 4 and checker == 0 or gPlayerManager.main.bindData.isInSlideRail then
			if show < 2 then
				show = 2
			end

			return
		end
	end

	if show == 1 then
		if self.StateMonitor.scanEnable[1] or not self.StateMonitor.scanEnable[2] or force then
			self.StateMonitor.scanEnable[1] = false
			self.StateMonitor.scanEnable[2] = true

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	elseif show == 2 then
		if self.StateMonitor.scanEnable[1] or self.StateMonitor.scanEnable[2] or force then
			self.StateMonitor.scanEnable[1] = false
			self.StateMonitor.scanEnable[2] = false

			self.StateMonitor:SendBindEvent("scanEnable")
		end

		return
	end

	if not self.StateMonitor.scanEnable[1] or not self.StateMonitor.scanEnable[2] or force then
		self.StateMonitor.scanEnable[1] = true
		self.StateMonitor.scanEnable[2] = true

		self.StateMonitor:SendBindEvent("scanEnable")
	end
end

function M:RefreshExitState(force)
	local isInXinShouRaid = gUIUtils:IsInXinShouRaid()
	local visible = false
	local interactable = false

	if gRaidDataManager.RaidId ~= 0 then
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
		interactable = raidTypeConfig.CanEscape or gChallengeManager.challengeData.IsChallenging

		if gLinkManager:CheckInMatchMode() then
			interactable = interactable or gLinkManager:CheckIsInRace()
		end
	end

	interactable = interactable or self.showPauseBar
	visible = interactable and not isInXinShouRaid

	if self.StateMonitor.exitEnable[1] ~= visible or self.StateMonitor.exitEnable[2] ~= interactable or force then
		self.StateMonitor.exitEnable[1] = visible
		self.StateMonitor.exitEnable[2] = interactable

		self.StateMonitor:SendBindEvent("exitEnable")
	end
end

function M:RefreshXuWeiState(force)
	local state = true

	if gRaidDataManager.RaidId == 0 then
		state = false
	else
		local raidCfg = RaidConfig.GetConfig(gRaidDataManager.RaidId)
		local raidTypeConfig = RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

		if raidTypeConfig.hideUIXuWei == 2 or gChallengeManager.challengeData.IsChallenging then
			state = false
		end
	end

	if state ~= self.StateMonitor.xuWeiEnable[1] or force then
		self.StateMonitor.xuWeiEnable[1] = state
		self.StateMonitor.xuWeiEnable[2] = state

		self.StateMonitor:SendBindEvent("xuWeiEnable")
	end
end

function M:RefreshTaskListState(force)
	local state = true
	local oldChecker = gMainMenuMgr.taskGuideVisiable

	for i = 1, oldChecker.Count do
		local checker = oldChecker[i]

		if i == 1 and checker ~= 1 or gMainMenuMgr.taskAndTeamState.isShowTask == false or gChallengeManager.challengeData.IsChallenging then
			if checker == 2 or checker == 4 or gChallengeManager.challengeData.IsChallenging then
				state = false
			end

			if checker == 2 or checker == 3 then
				state = false
			end
		end
	end

	if state ~= self.StateMonitor.taskListEnable[1] or force then
		self.StateMonitor.taskListEnable[1] = state
		self.StateMonitor.taskListEnable[2] = state

		self.StateMonitor:SendBindEvent("taskListEnable")
	end
end

function M:RefreshMapState(force)
	local state = true
	local oldChecker = gMainMenuMgr.miniMapNewPanelUIVisiable

	for i = 1, oldChecker.Count do
		local checker = oldChecker[i]

		if i == 1 and checker == 2 or i == 2 and checker == 1 then
			state = false
		end
	end

	if state ~= self.StateMonitor.mapEnable[1] or force then
		self.StateMonitor.mapEnable[1] = state
		self.StateMonitor.mapEnable[2] = state

		self.StateMonitor:SendBindEvent("mapEnable")
	end
end

function M:RefreshCharacterSwitchState(force)
	local state = true
	local interactState = true

	if not gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.SwitchSpiritWheel) then
		state = false
	end

	if not self.CharacterSwitchControl.UnitStateEnable then
		state = false
	end

	if not self.CharacterSwitchControl.GameplayEnable then
		state = false
	end

	if not self.CharacterSwitchControl.ParkourStateEnable then
		state = false
	end

	if gLinkManager:CheckInMatchMode() then
		state = false
	end

	if not self.CharacterSwitchControl.Dialog22Enable then
		state = false
	end

	local raidCfg = LTConfig.RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)

	if not raidTypeCfg or not raidTypeCfg.CanChangeRole then
		state = false
	end

	if gTaskManager:GetNowTaskIsRoleTeamTask() and not gSpiritManager:CheckCanTaskRoleSwitch() then
		interactState = false
	end

	if self.StateMonitor.characterSwitchEnable[1] ~= state or self.StateMonitor.characterSwitchEnable[2] ~= interactState or force then
		self.StateMonitor.characterSwitchEnable[1] = state
		self.StateMonitor.characterSwitchEnable[2] = interactState

		self.StateMonitor:SendBindEvent("characterSwitchEnable")
	end
end

function M:RefreshRadioState(force)
	self.RadioControl.XSRaid = gUIUtils:IsInXinShouRaid()
	self.RadioControl.SystemUnlock = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.CarRadio)
	local state = true

	if not self.RadioControl.SystemUnlock or self.RadioControl.XSRaid or self.RadioControl.SpoonHide then
		state = false
	end

	if state ~= self.StateMonitor.radioEnable[1] or force then
		self.StateMonitor.radioEnable[1] = state
		self.StateMonitor.radioEnable[2] = state

		self.StateMonitor:SendBindEvent("radioEnable")
	end
end

function M:RefreshMotionActionState(force)
	local hasUnlocked = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.HUDPlayerMotionEntrance)

	if not hasUnlocked then
		self:SetMotionActionState(false, false, force)

		return
	end

	if self.isGuidePicOpen then
		self:SetMotionActionState(false, false, force)

		return
	end

	local isPcMode = gCS.LuaUtils.IsNonMobileAdaptive()
	local isLinkMode = gClientUtils.CheckIsLinkMode()

	if isPcMode and not isLinkMode then
		self:SetMotionActionState(false, false, force)

		return
	end

	self:SetMotionActionState(true, true, force)
end

function M:SetMotionActionState(visible, interactable, force)
	if visible ~= self.StateMonitor.motionActionEnable[1] or interactable ~= self.StateMonitor.motionActionEnable[2] or force then
		self.StateMonitor.motionActionEnable[1] = visible
		self.StateMonitor.motionActionEnable[2] = interactable

		self.StateMonitor:SendBindEvent("motionActionEnable")
	end
end

function M:RefreshLinkEnableState(force)
	local state = gLinkManager:CheckLinkEnable()

	if state ~= self.StateMonitor.radioEnable[1] or force then
		self.StateMonitor.linkEnable[1] = state
		self.StateMonitor.linkEnable[2] = state

		self.StateMonitor:SendBindEvent("linkEnable")
	end
end

function M:RefreshActivityState(force)
	local state = gAwardActivityManager:CheckHasActivity()

	if state ~= self.StateMonitor.activityEnable[1] or force then
		self.StateMonitor.activityEnable[1] = state
		self.StateMonitor.activityEnable[2] = state

		self.StateMonitor:SendBindEvent("activityEnable")
	end
end

function M:RefreshFeedbackState(force)
	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.FeedbackUnlock)

	if state ~= self.StateMonitor.feedbackEnable[1] or force then
		self.StateMonitor.feedbackEnable[1] = state
		self.StateMonitor.feedbackEnable[2] = state

		self.StateMonitor:SendBindEvent("feedbackEnable")
	end
end

function M:RefreshSurveyState(force)
	local state = gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.Survey)

	if state ~= self.StateMonitor.surveyEnable[1] or force then
		self.StateMonitor.surveyEnable[1] = state
		self.StateMonitor.surveyEnable[2] = state

		self.StateMonitor:SendBindEvent("surveyEnable")
	end
end

function M:RefreshMainPageState(force)
	local state = self.StateMonitor.phoneEnable[2]
	local raidCfg = LTConfig.RaidConfig.GetConfig(gRaidDataManager.RaidId)
	local raidTypeCfg = raidCfg and LTConfig.RaidRaidTypeConfig.GetConfig(raidCfg.RaidType)
	local openMainPhoneType = raidTypeCfg and raidTypeCfg.CanOpenMainCube or 1
	local curTaskNeedPause = self.showPauseBar

	if openMainPhoneType == 1 and not curTaskNeedPause then
		state = self.StateMonitor.phoneEnable[2]
	elseif openMainPhoneType == 2 or curTaskNeedPause then
		state = false
	end

	if state ~= self.StateMonitor.mainPageEnable[2] or force then
		self.StateMonitor.mainPageEnable[1] = state
		self.StateMonitor.mainPageEnable[2] = state

		self.StateMonitor:SendBindEvent("mainPageEnable")
	end
end

function M:RefreshQuickPhoneCallCommonState(force)
	local visible, interactable = self:GetQuickPhoneCallSate(PhoneConfig.ShortCutCallCar.contactId)

	if visible ~= self.StateMonitor.quickPhoneCallCommonEnable[1] or interactable ~= self.StateMonitor.quickPhoneCallCommonEnable[2] or force then
		self.StateMonitor.quickPhoneCallCommonEnable[1] = visible
		self.StateMonitor.quickPhoneCallCommonEnable[2] = interactable

		self.StateMonitor:SendBindEvent("quickPhoneCallCommonEnable")
	end
end

function M:RefreshQuickPhoneCallMilkState(force)
	local visible, interactable = self:GetQuickPhoneCallSate(PhoneConfig.ShortCutCallMilkVehicle.contactId)

	if visible ~= self.StateMonitor.quickPhoneCallMilkEnable[1] or interactable ~= self.StateMonitor.quickPhoneCallMilkEnable[2] or force then
		self.StateMonitor.quickPhoneCallMilkEnable[1] = visible
		self.StateMonitor.quickPhoneCallMilkEnable[2] = interactable

		self.StateMonitor:SendBindEvent("quickPhoneCallMilkEnable")
	end
end

function M:GetQuickPhoneCallSate(contactId)
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
	local isParkourShow = self.QuickPhoneCallControl.Parkour
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
	local state = hasUnlock and checkPass and canCallVehicle and isEnableFormalShortCutKey and isParkourShow and isPhoneAppCanOpen

	return state, state
end

function M:CheckVehicleSpiritLimit()
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local npcCultivationId = 91050034
	local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)

	if spiritId == npcCultivationCfg.FightSpiritID then
		return true
	end
end

function M:OnSystemUnlock(eventId, id)
	if id == SystemUnlockConfig.BaBa then
		self:MarkStateDirty(self.STATE_DEFINE.BABA)
	elseif id == SystemUnlockConfig.MainPanelUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	elseif id == SystemUnlockConfig.SwitchSpiritWheel then
		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	elseif id == SystemUnlockConfig.CarRadio then
		self:MarkStateDirty(self.STATE_DEFINE.RADIO)
	elseif id == SystemUnlockConfig.HUDPlayerMotionEntrance then
		self:MarkStateDirty(self.STATE_DEFINE.MOTION_ACTION)
	elseif id == SystemUnlockConfig.LinkUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.LINK)
	elseif id == SystemUnlockConfig.AwardActivity then
		self:MarkStateDirty(self.STATE_DEFINE.ACTIVITY)
	elseif id == SystemUnlockConfig.FeedbackUnlock then
		self:MarkStateDirty(self.STATE_DEFINE.FEEDBACK)
	elseif id == SystemUnlockConfig.Survey then
		self:MarkStateDirty(self.STATE_DEFINE.SURVEY)
	end

	self:MarkQuickPhoneCallDirty()
end

function M:OnGameSwitchChanged()
	self:MarkStateDirty(self.STATE_DEFINE.LINK)
	self:MarkStateDirty(self.STATE_DEFINE.ACTIVITY)
end

function M:OnGameWatchStateChanged()
	self:MarkQuickPhoneCallDirty()
end

function M:OnCurrentTaskChanged()
	self.showPauseBar = gTaskNodeManager:CheckCurTaskShowPause()

	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.MAIN_PAGE)
end

function M:OnKickToLogin()
	self.CharacterSwitchControl = {
		UnitStateEnable = true,
		GameplayEnable = true,
		Dialog22Enable = true,
		ParkourStateEnable = true
	}
end

function M:OnAfterSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		self:RefreshAllState()
	end
end

local BabaConflictPanels = {
	gPanelId.S_BUBBLE_NEW_TIPS_PANEL,
	gPanelId.S_YAN_JIE_NEW_TIPS_PANEL,
	gPanelId.S_CHAT_POPUP_NORMAL,
	gPanelId.S_CHAT_POPUP_DIALOG,
	gPanelId.NEW_FRIEND_APPLICATION_POPUP_PANEL
}

function M:OnPanelShow(eventId, panelId)
	if table.contains(BabaConflictPanels, panelId) then
		self.babaBlockCount = self.babaBlockCount + 1

		self:MarkStateDirty(self.STATE_DEFINE.BABA)
	end

	if panelId == gPanelId.S_DIALOG_22N_PANEL then
		self.CharacterSwitchControl.Dialog22Enable = false

		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	end

	self:MarkQuickPhoneCallDirty()
end

function M:OnPanelClose(eventId, panelId)
	if table.contains(BabaConflictPanels, panelId) then
		self.babaBlockCount = self.babaBlockCount - 1

		self:MarkStateDirty(self.STATE_DEFINE.BABA)
	end

	if panelId == gPanelId.S_DIALOG_22N_PANEL then
		self.CharacterSwitchControl.Dialog22Enable = true

		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	end

	self:MarkQuickPhoneCallDirty()
end

function M:OnLinkModeChange()
	self:MarkStateDirty(self.STATE_DEFINE.EXIT)
	self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	self:MarkStateDirty(self.STATE_DEFINE.MOTION_ACTION)
end

function M:OnEnterVehicleFinish()
	self.isDrive = true

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

function M:OnExitVehicleStart()
	self.isDrive = false

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

function M:OnSpoonHideRadio(hide)
	self.RadioControl.SpoonHide = hide

	self:MarkStateDirty(self.STATE_DEFINE.RADIO)
end

function M:OnEnterBaseVehicleFinish()
	self.isBaseVehicle = true

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

function M:OnExitBaseVehicleStart()
	self.isBaseVehicle = false

	self:MarkStateDirty(self.STATE_DEFINE.SCAN)
end

function M:OnAndroidControlSwitch(eventId, data)
	self.isAndroidControl = data.enterOrLeave
end

function M:OnSummonCommonConditionChange(canSummonCommonVehicle)
	self.QuickPhoneCallControl.Condition[PhoneConfig.ShortCutCallCar.contactId] = canSummonCommonVehicle

	self:MarkStateDirty(self.STATE_DEFINE.QUICK_PHONE_COMMON)
end

function M:OnSummonMilkConditionChange(canSummonMilk)
	self.QuickPhoneCallControl.Condition[PhoneConfig.ShortCutCallMilkVehicle.contactId] = canSummonMilk

	self:MarkStateDirty(self.STATE_DEFINE.QUICK_PHONE_MILK)
end

function M:OnParkourAddRemove(eventId, data)
	local isParkourShow = true

	for _, state in pairs(gMainMenuMgr:GetClientState()) do
		local btnState = gMainMenuMgr.clientStateConfig[state].Phone_ShortCuts == 1
		isParkourShow = isParkourShow and btnState
	end

	if self.QuickPhoneCallControl.Parkour ~= isParkourShow then
		self.QuickPhoneCallControl.Parkour = isParkourShow

		self:MarkQuickPhoneCallDirty()
	end
end

function M:OnUpdateActivityState()
	self:MarkStateDirty(self.STATE_DEFINE.ACTIVITY)
end

function M:MarkQuickPhoneCallDirty()
	self:MarkStateDirty(self.STATE_DEFINE.PHONE)
	self:MarkStateDirty(self.STATE_DEFINE.QUICK_PHONE_COMMON)
	self:MarkStateDirty(self.STATE_DEFINE.QUICK_PHONE_MILK)
end

function M:GetTeamEnable()
	local state = {
		false,
		false
	}

	if gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.CardGroupId) then
		state = self.StateMonitor.teamEnable
	end

	return state
end

function M:GetBabaEnable()
	local state = {
		false,
		false
	}

	if gMainPhoneUtils.CheckAppCanShow(MobileMenuSGuiConfig.MessageId) then
		state = self.StateMonitor.babaEnable
	end

	return state
end

function M:GetPhoneEnable()
	return self.StateMonitor.phoneEnable
end

function M:GetPackageEnable()
	return self.StateMonitor.packageEnable
end

function M:GetXuWeiEnable()
	return self.StateMonitor.xuWeiEnable
end

function M:GetGachaEnable()
	return false
end

function M:GetTestEnable()
	return self.StateMonitor.testEnable
end

function M:GetScanEnable()
	return self.StateMonitor.scanEnable
end

function M:GetExitEnable()
	return self.StateMonitor.exitEnable
end

function M:GetTaskListEnable()
	return self.StateMonitor.taskListEnable
end

function M:GetMapEnable()
	return self.StateMonitor.mapEnable
end

function M:GetCharacterSwitchEnable()
	return self.StateMonitor.characterSwitchEnable
end

function M:GetRadioEnable()
	return self.StateMonitor.radioEnable
end

function M:GetMotionActionEnable()
	return self.StateMonitor.motionActionEnable
end

function M:GetLinkEnable()
	return self.StateMonitor.linkEnable
end

function M:GetFeedbackEnable()
	return self.StateMonitor.feedbackEnable
end

function M:GetSurveyEnable()
	return self.StateMonitor.surveyEnable
end

function M:GetQuickPhoneCallCommonStateEnable()
	return self.StateMonitor.quickPhoneCallCommonEnable
end

function M:GetQuickPhoneCallMilkStateEnable()
	return self.StateMonitor.quickPhoneCallMilkEnable
end

function M:GetMainPageEnable()
	return self.StateMonitor.mainPageEnable
end

function M:CheckCanOpenMainCubeUI()
	local open = true

	if gPlayerManager.main.bindData.isInClimbing then
		open = false
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_PHONE_CALL_IN_PANEL) then
		open = false
	end

	return open
end

function M:OpenTeam()
	if not gUIUtils:CheckCanOpenCardPanel() then
		return
	end
end

function M:OpenSchedule()
	return
end

function M:OpenBaba()
	gMainPhoneUtils.OnAppItemClick(MobileMenuSGuiConfig.MessageId)
end

function M:OpenPhone()
	if not self:CheckCanOpenMainCubeUI() then
		return
	end

	gClientUtils.OpenMainPhonePanel()
end

function M:OpenPackage()
	gPanelManager:CheckShow(gPanelId.S_INVENTORY_PANEL)
end

function M:OpenXuWei()
	if not gUIUtils:CheckCanOpenCardPanel() then
		return
	end

	gSpiritManager:ShowLingMainPanel()
end

function M:OpenGacha()
	return
end

function M:OpenTest()
	return
end

function M:OpenExit()
	if gLinkManager:CheckInMatchMode() then
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
		local function leftCallBack()
			return true
		end

		local function rightCallBack()
			gClientToGameDelegate:AskDeleteTask(gChallengeManager.currentChallengeTaskId, true).Callback = function (err)
				if err ~= 0 then
					gDisplayMessageMgr:DisplayServerMessageId(err)
				end
			end

			return true
		end

		gDisplayMessageMgr:ShowMessage(MessageConfig.ChallengeFinish, rightCallBack, leftCallBack)

		return
	end
end

function M:OpenTaskList()
	gMainMenuMgr:ClickTaskOnTaskAndTeamState()
end

function M:OpenMap()
	gMapUtils:CheckRaidCanOpenMap()
end

function M:OpenCharacterSwitch()
	gPanelManager:CheckShow(gPanelId.S_SWAP_CHARACTER_LIST_PANEL)
end

function M:ReleaseCloseCharacterSwitch()
	if gCS.LuaUtils.IsNonMobileAdaptive() and gPanelManager:IsPanelShowing(gPanelId.S_SWAP_CHARACTER_LIST_PANEL) then
		gPanelManager:Close(gPanelId.S_SWAP_CHARACTER_LIST_PANEL)
	end
end

function M:Scan()
	L50.L50App.Scene.ScanMgr:OnTriggerScan()
end

function M:PVHideBtn(hide)
	self.pvHideBtn = hide

	self:MarkStateDirty(self.STATE_DEFINE.TEST)
end

function M:UnitStateSetCharacterSwitch(enable)
	if self.CharacterSwitchControl.UnitStateEnable ~= enable then
		self.CharacterSwitchControl.UnitStateEnable = enable

		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	end
end

function M:GameplaySetCharacterSwitch(enable)
	if self.CharacterSwitchControl.GameplayEnable ~= enable then
		self.CharacterSwitchControl.GameplayEnable = enable

		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	end
end

function M:ParkourStateSetCharacterSwitch(enable)
	if self.CharacterSwitchControl.ParkourStateEnable ~= enable then
		self.CharacterSwitchControl.ParkourStateEnable = enable

		self:MarkStateDirty(self.STATE_DEFINE.CHARACTER)
	end
end

gUIFunctionStateManager = gUIFunctionStateManager or C_UIFunctionStateManager.new()
