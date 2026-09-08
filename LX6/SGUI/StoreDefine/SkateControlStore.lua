-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SkateControlStore.lua
-- Decompiled from: 01344_SkateControlStore.lua_46566e6ce256.luajit

local ClientEventConfig = LTConfig.ClientEventConfig
local ABPCCCEventConfig = LTConfig.ABPCCCEventConfig
local MOUSE_MAP_RADIUS = 200
local CENTER_REGION_RADIUS = 0.3
C_SkateControlStore = DefClass("C_SkateControlStore", C_SkateControlStore, C_StoreGroup)
GroupName2Class.SkateControlStore = C_SkateControlStore
local M = C_SkateControlStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.isRecording = false
	self.mousePressPos = nil
	self.cameraRestoreTimer = nil
	self.trajectoryPoints = {}
	self.regionSequence = {}
	self.lastRegion = nil
	self.isFlipTrickEnabled = true
end

M.DefineAllEnumsAutoGen = function(self)
	self.flipTrickActiveCtrlEnum = {
		["\\xdc\\xd5!\\xf5"] = 1,
		["\\xaf\\xb8\\xaah2\\xfb7"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.flipTrickActiveCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.RefreshFlipTrickActive(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
	self.CancelRecord(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.jumpBtn.luaPress = self.CreateAction(self, "OnJumpBtnPress")
	self.bindData.jumpBtn.luaRelease = self.CreateAction(self, "OnJumpBtnRelease")
	self.bindData.crouchBtn.luaPress = self.CreateAction(self, "OnCrouchBtnPress")
	self.bindData.crouchBtn.luaRelease = self.CreateAction(self, "OnCrouchBtnRelease")
	self.bindData.dashBtn.luaClick = self.CreateAction(self, "OnDashBtnClick")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.exitBtn.luaLongPress = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.flipBtn.luaPress = self.CreateAction(self, "OnFlipBtnPress")
	self.bindData.flipBtn.luaRelease = self.CreateAction(self, "OnFlipBtnRelease")

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.rightJoyStick.luaValueChanged = self.CreateAction(self, "OnRightJoyStickValueChange")
	end
end

M.OnJumpBtnPress = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		return
	end

	gCS.LogicStateMachineManager.Send3CEvent(unit, ABPCCCEventConfig.JumpPress)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(unit.Pid, ABPCCCEventConfig.JumpPress)
	gCS.SkillJumpManager.Instance:CheckSkillJump(unit.Pid, ClientEventConfig.JumpButtonClick)

	gCS.TransitionMgr.isPressingJumpDown = true
end

M.OnJumpBtnRelease = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		return
	end

	gCS.LogicStateMachineManager.Send3CEvent(unit, ABPCCCEventConfig.JumpRelease)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(unit.Pid, ABPCCCEventConfig.JumpRelease)

	gCS.TransitionMgr.isPressingJumpDown = false
end

M.OnCrouchBtnPress = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		return
	end

	gCS.LogicStateMachineManager.Send3CEvent(unit, ABPCCCEventConfig.CtrlPress)
end

M.OnCrouchBtnRelease = function(self)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if unit ~= nil then
		return
	end

	gCS.LogicStateMachineManager.Send3CEvent(unit, ABPCCCEventConfig.CtrlRelease)
end

M.OnDashBtnClick = function(self)
	if not self.isHightSpeedDown then
		self.HighSpeedDown(self)
	else
		self.HighSpeedUp(self)
	end
end

M.HighSpeedDown = function(self)
	self.isHightSpeedDown = true
	self.isHightSpeedDownNow = true
	gCS.TransitionMgr.isHightSpeedDown = true
	gCS.TransitionMgr.isHightSpeedDownNow = true

	if gCS.MyPlayerManager.PlayerUnit and gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
		gCS.LuaUtils.CheckSwitchAction(false, false, false, 0)
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.DashPress)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, ABPCCCEventConfig.DashPress)

	self.isHightSpeedDownNow = false
	gCS.TransitionMgr.isHightSpeedDownNow = false
end

M.HighSpeedUp = function(self)
	self.isHightSpeedDown = false
	gCS.TransitionMgr.isHightSpeedDown = false

	if gCS.MyPlayerManager.PlayerUnit.NoMoveTime ~= 0 then
		self.isHightSpeedUp = true
		gCS.TransitionMgr.isHightSpeedUp = true

		gCS.LuaUtils.CheckSwitchAction(true, false, false, 0)

		self.isHightSpeedUp = false
		gCS.TransitionMgr.isHightSpeedUp = false
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, ABPCCCEventConfig.DashRelease)
	gCS.BaseUnitUtils.CheckNeedToTransferToRideTarget(gCS.MyPlayerManager.PlayerUnit.Pid, ABPCCCEventConfig.DashRelease)
end

M.OnExitBtnClick = function(self)
	gCS.SceneBattleBtnMgr.OnBattleBtnLongPressBegin(gBattleMgr.SkillBtnType.Normal)
end

M.RefreshFlipTrickActive = function(self)
	local skateId = gCS.WeaponMgr.GetCurrentWeaponTid() or 0
	local enabled = LX6.PaoKu.Setting.SkateMoveSettingList.GetFlipTrickEnabled(skateId)
	self.isFlipTrickEnabled = enabled
	self.bindData.flipTrickActiveCtrl = enabled and self.flipTrickActiveCtrlEnum.enabled or self.flipTrickActiveCtrlEnum.disabled
	self.bindData.flipBtn.interactable = enabled
end

M.OnFlipBtnPress = function(self)
	if not self.isFlipTrickEnabled then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local mp = UnityEngine.Input.mousePosition
	self.mousePressPos = {
		x = mp.x,
		y = mp.y
	}

	self.BeginRecord(self)
end

M.OnFlipBtnRelease = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.EndRecord(self)
end

M.OnUpdate = function(self)
	if not gCoreHudUIManager.isNonMobileAdaptive then
		return
	end

	if self.cameraRestoreTimer then
		self.cameraRestoreTimer = self.cameraRestoreTimer - gLogicTime.deltaTime

		if self.cameraRestoreTimer < 0 then
			self.cameraRestoreTimer = nil

			gClientUtils.SetCameraRotateEnabled(true, LX6.Manager.BanCameraControlSource.SKATE)
		end
	end

	if not self.isRecording or not self.mousePressPos then
		return
	end

	if not UnityEngine.Input.GetMouseButton(0) then
		return
	end

	local mp = UnityEngine.Input.mousePosition

	self.SampleTrajectory(self, (mp.x - self.mousePressPos.x) / MOUSE_MAP_RADIUS, (mp.y - self.mousePressPos.y) / MOUSE_MAP_RADIUS)
end

M.OnRightJoyStickValueChange = function(self, dx, dy, size)
	if not self.isFlipTrickEnabled then
		return
	end

	if size <= 0 then
		if not self.isRecording then
			self.BeginRecord(self)
		end

		self.SampleTrajectory(self, dx * size, dy * size)
	elseif self.isRecording then
		self.EndRecord(self)
	end
end

M.BeginRecord = function(self)
	if self.isRecording then
		return
	end

	self.isRecording = true
	self.trajectoryPoints = {}
	self.regionSequence = {}
	self.lastRegion = nil

	self.bindData.trajectoryBoard:BeginTrajectory()
	self:SampleTrajectory(0, 0)

	if SGUI.InputActionBind.activeGameDevice ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		LX6.Manager.GameInputManager.SetCursorPositionInPC(UnityEngine.Screen.width / 2, UnityEngine.Screen.height / 2)
		LX6.Manager.GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt, true, UnityEngine.CursorLockMode.None)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.cameraRestoreTimer = nil

		gClientUtils.SetCameraRotateEnabled(false, LX6.Manager.BanCameraControlSource.SKATE)
	end
end

M.StopRecord = function(self, delayCameraRestore)
	self.isRecording = false
	self.mousePressPos = nil

	self.bindData.trajectoryBoard:Clear()

	if SGUI.InputActionBind.activeGameDevice ~= SGUI.GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		LX6.Manager.GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt)
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		local delay = 0

		if delayCameraRestore then
			local skateId = gCS.WeaponMgr.GetCurrentWeaponTid() or 0
			delay = LX6.PaoKu.Setting.SkateMoveSettingList.GetCameraLockDelayAfterDraw(skateId)
		end

		if delay <= 0 then
			self.cameraRestoreTimer = delay
		else
			self.cameraRestoreTimer = nil

			gClientUtils.SetCameraRotateEnabled(true, LX6.Manager.BanCameraControlSource.SKATE)
		end
	end
end

M.EndRecord = function(self)
	if not self.isFlipTrickEnabled then
		return
	end

	if not self.isRecording then
		return
	end

	self.StopRecord(self, true)

	local csv = table.concat(self.regionSequence, ",")

	print_debug("轨迹分区序列：" .. csv)

	local ev = LX6.PaoKu.Setting.SkateMoveSettingList.MatchFancyCCCEvent(csv)

	if ev == 0 then
		local unit = gCS.MyPlayerManager.PlayerUnit

		if unit == nil then
			gCS.LogicStateMachineManager.Send3CEvent(unit, ev)
		end
	end
end

M.CancelRecord = function(self)
	if not self.isRecording then
		return
	end

	self.StopRecord(self)
end

M.SampleTrajectory = function(self, nx, ny)
	if not self.isRecording then
		return
	end

	local len = math.sqrt(nx * nx + ny * ny)

	if len <= 1 then
		nx = nx / len
		ny = ny / len
	end

	self.trajectoryPoints[#self.trajectoryPoints + 1] = {
		x = nx,
		y = ny
	}
	local region = self.GetRegion(self, nx, ny)

	if region == self.lastRegion then
		if region == 0 then
			self.regionSequence[#self.regionSequence + 1] = region
		end

		self.lastRegion = region
	end

	self.bindData.trajectoryBoard:AddPoint(nx, ny)
end

M.GetRegion = function(self, nx, ny)
	if nx * nx + ny * ny < CENTER_REGION_RADIUS * CENTER_REGION_RADIUS then
		return 0
	end

	local deg = math.deg(math.atan2(nx, ny))

	if deg >= 0 then
		deg = deg + 360
	end

	local idx = math.floor((deg + 22.5) % 360 / 45) + 1

	if idx <= 8 then
		idx = 8
	end

	return idx
end
