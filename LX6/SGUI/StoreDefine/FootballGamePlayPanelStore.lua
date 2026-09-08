-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FootballGamePlayPanelStore.lua
-- Decompiled from: 01865_FootballGamePlayPanelStore.lua_8cac6e1a551f.luajit

C_FootballGamePlayPanelStore = DefClass("C_FootballGamePlayPanelStore", C_FootballGamePlayPanelStore, C_StoreGroup)
GroupName2Class.FootballGamePlayPanelStore = C_FootballGamePlayPanelStore
local M = C_FootballGamePlayPanelStore

M.ctor = function(self)
	self.ShootJoystickCtrl = {
		["aBk`@:?"] = 1,
		["\\xfc\\xd59%\\xf6"] = 0
	}
	self.ShootGamepadUIMouseSensitivity = 50
	self.rightStickValue = {
		["\\xd5"] = 0,
		["\\xd4"] = 0
	}
end

M.OnAwake = function(self)
	self.bindData.shootBtn.luaPress = self.CreateAction(self, "OnShootBtnDown")
	self.bindData.shootBtn.luaRelease = self.CreateAction(self, "OnShootBtnUp")
	self.bindData.precisionBallBearingBtn.luaPress = self.CreateAction(self, "OnPrecisionBallBearingBtnDown")
	self.bindData.precisionBallBearingBtn.luaRelease = self.CreateAction(self, "OnPrecisionBallBearingBtnUp")
	self.bindData.accelerateBtn.luaPress = self.CreateAction(self, "OnAccelerateBtnDown")
	self.bindData.accelerateBtn.luaRelease = self.CreateAction(self, "OnAccelerateBtnUp")
	self.bindData.cPressBtn.luaClick = self.CreateAction(self, "OnCPressBtnClick")
	self.bindData.spaceBtn.luaLongPress = self.CreateAction(self, "OnSpaceLongPress")
	self.bindData.spaceBtn.luaBeginLongPress = self.CreateAction(self, "OnSpaceBeginLongPress")
	self.bindData.spaceBtn.luaEndLongPress = self.CreateAction(self, "OnSpaceEndLongPress")
	self.bindData.passingBtn.luaRelease = self.CreateAction(self, "OnPassingBtnDown")
	self.bindData.passingBtn.luaRelease = self.CreateAction(self, "OnPassingBtnUp")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnMouseMove")
	self.bindData.joystick.luaValueChanged = self.CreateAction(self, "OnJoyStickValueChange")
	self.bindData.joystick.luaBeginDrag = self.CreateAction(self, "OnJoyStickBeginDrag")
	self.bindData.joystick.luaEndDrag = self.CreateAction(self, "OnJoyStickEndDrag")
	self.bindData.rightControllerMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightControllerMove")
end

M.OnJoyStickBeginDrag = function(self)
	self.bindData.shootJoystickCtrl = self.ShootJoystickCtrl.BeginDrag

	self.OnShootBtnDown(self)
end

M.OnJoyStickEndDrag = function(self)
	self.bindData.shootJoystickCtrl = self.ShootJoystickCtrl.EndDrag

	self.OnShootBtnUp(self)
end

M.OnJoyStickValueChange = function(self, x, y, size)
	self.SetballRect(self, Vector2.New(x, y))
end

M.OnEnable = function(self)
	self.ResetData(self)
end

M.OnDisable = function(self)
	self.ResetData(self)
end

M.ResetData = function(self)
	self.bindData.progress = 0
	self.bindData.showCrossHairCtrl = 1
	self.bindData.showBarCtrl = 0
	self.bindData.crossHairStatus = 1
	self.isPressed = false
	self.progressValue = 0
	self.shootdirection = Vector2.New(0, 0)
	self.offset = Vector2.New(0, 0)
	self.bindData.ballRect.anchoredPosition = Vector2.New(0, 0)
	self.bindData.shootJoystickCtrl = self.ShootJoystickCtrl.EndDrag
	self.isSpacePressed = false
	self.isCtrlPressed = false
	self.isFancySkill = false
	self.needUpdateCamera = false
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
end

M.OnShootBtnDown = function(self)
	if self.isPressed then
		return
	end

	self.bindData.crossHairStatus = 0
	self.isPressed = true
	self.canShootBtnDown = true

	self.PlayProgress(self)

	self.forward = gCS.CameraDataMgr.MainCamera.transform.forward
	self.bindData.showBarCtrl = 1

	if gFootBallManager.isShowFootBallPanel then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
	end

	gCS.LuaUtils.FootballShootRelease(Vector2.New(0, 0), 0, self.forward)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballShootPress)
end

M.OnShootBtnUp = function(self)
	self.canShootBtnDown = false

	if self.progressTimer then
		self.progressTimer:Stop()

		self.progressTimer = nil
	end

	gCS.LuaUtils.FootballShootRelease(self.shootdirection, self.progressValue, self.forward)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballShootRelease)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_Football_circleRect")
end

M.OnMouseMove = function(self, context)
	if not self.canShootBtnDown then
		return
	end

	local screenDelta = context.ReadValueVector2(context)

	self.SetballRect(self, screenDelta)
end

M.SetballRect = function(self, screenDelta)
	local size = self.bindData.circleRect.rect.size
	local r = math.min(size.x, size.y) * 0.5
	local localDelta = screenDelta / gCS.LuaUtils.GetFootballUIMouseSensitivity()

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		localDelta = localDelta * 50
	end

	self.offset = self.offset or Vector2.New(0, 0)
	self.offset = self.offset + localDelta
	local mag = self.offset.magnitude

	if r >= mag then
		self.offset = self.offset / mag * r
	end

	self.shootdirection = self.offset / r
	self.bindData.ballRect.anchoredPosition = self.offset
end

M.PlayProgress = function(self)
	self.currentValue = 0
	local maxTimer = gCS.LuaUtils.GetFootballUIForceMaxTimer()
	self.progressTimer = Timer.New(function ()
		self.currentValue = self.currentValue + 0.1

		if maxTimer < self.currentValue then
			self.currentValue = maxTimer

			self:OnShootBtnUp()
		elseif self.currentValue < 0 then
			self.currentValue = 0
		end

		self.progressValue = self.currentValue / maxTimer
		self.bindData.progress = self.progressValue
	end, 0.1, -1):Start()
end

M.OnAccelerateBtnDown = function(self)
	local param2 = LTConfig.ABPCCCEventConfig.DashPress

	if gFootBallManager.isShowFootBallPanel then
		param2 = LTConfig.ABPCCCEventConfig.FootballRushPress

		print_debug("FootballRushPress")
	else
		print_debug("DashPress")
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, param2)
end

M.OnAccelerateBtnUp = function(self)
	local param2 = LTConfig.ABPCCCEventConfig.DashRelease

	if gFootBallManager.isShowFootBallPanel then
		param2 = LTConfig.ABPCCCEventConfig.FootballRushRelease

		print_debug("FootballRushRelease")
	else
		print_debug("DashRelease")
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballRushRelease)
end

M.OnPrecisionBallBearingBtnDown = function(self)
	self.isCtrlPressed = true

	print_debug("FootballCtrlPress")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCtrlPress)
end

M.OnPrecisionBallBearingBtnUp = function(self)
	self.isCtrlPressed = false

	print_debug("FootballCtrlRelease")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCtrlRelease)
end

M.OnCPressBtnClick = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCPress)
end

M.OnPassingBtnDown = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballPassPress)
end

M.OnPassingBtnUp = function(self)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballPassRelease)
end

M.OnSpaceLongPress = function(self)
	print_debug("OnSpaceBeginLongPress")

	if self.isCtrlPressed then
		self.isFancySkill = true

		print_debug("FootballFancySkill")
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballFancySkill)
	end
end

M.OnSpaceBeginLongPress = function(self)
	print_debug("OnSpaceLongPress")

	if self.isCtrlPressed then
		print_debug("FootballFancyPress")
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballFancyPress)

		return
	end

	print_debug("FootballChaseballPress")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballChaseballPress)
end

M.OnSpaceEndLongPress = function(self)
	print_debug("OnSpaceEndLongPress")

	if self.isFancySkill then
		self.FancySkillRelease(self)
	end
end

M.FancySkillRelease = function(self)
	print_debug("FootballFancySkillRelease")
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballFancySkillRelease)

	self.isFancySkill = false
end

M.OnRightControllerMove = function(self, context)
	if self.isPressed then
		local vector2 = context.ReadValueVector2(context)

		self.SetballRect(self, vector2 * self.ShootGamepadUIMouseSensitivity)

		return
	end

	local value = context.ReadValueVector2(context)

	if context.started or context.performed then
		self.needUpdateCamera = true
		self.rightStickValue.x = value.x
		self.rightStickValue.y = value.y
	else
		self.needUpdateCamera = false
		self.rightStickValue.x = 0
		self.rightStickValue.y = 0

		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

M.OnUpdate = function(self)
	self.UpdateGamepadCamera(self)
end

M.UpdateGamepadCamera = function(self)
	if self.needUpdateCamera then
		gCameraUtils:DoRotateCameraByGamePad(1, self.rightStickValue.x, self.rightStickValue.y)
	end
end
