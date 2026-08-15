C_FootballGamePlayPanelStore = DefClass("C_FootballGamePlayPanelStore", C_FootballGamePlayPanelStore, C_StoreGroup)
GroupName2Class.FootballGamePlayPanelStore = C_FootballGamePlayPanelStore
local M = C_FootballGamePlayPanelStore

function M:ctor()
	self.ShootJoystickCtrl = {
		BeginDrag = 1,
		EndDrag = 0
	}
	self.ShootGamepadUIMouseSensitivity = 50
end

function M:OnAwake()
	self.bindData.shootBtn.luaPress = self:CreateAction("OnShootBtnDown")
	self.bindData.shootBtn.luaRelease = self:CreateAction("OnShootBtnUp")
	self.bindData.precisionBallBearingBtn.luaPress = self:CreateAction("OnPrecisionBallBearingBtnDown")
	self.bindData.precisionBallBearingBtn.luaRelease = self:CreateAction("OnPrecisionBallBearingBtnUp")
	self.bindData.accelerateBtn.luaPress = self:CreateAction("OnAccelerateBtnDown")
	self.bindData.accelerateBtn.luaRelease = self:CreateAction("OnAccelerateBtnUp")
	self.bindData.cPressBtn.luaClick = self:CreateAction("OnCPressBtnClick")
	self.bindData.dribbleBtn.luaClick = self:CreateAction("OnDribbleBtnClick")
	self.bindData.dribbleBtn.luaPress = self:CreateAction("OnDribbleBtnDown")
	self.bindData.dribbleBtn.luaRelease = self:CreateAction("OnDribbleBtnUp")
	self.bindData.passingBtn.luaRelease = self:CreateAction("OnPassingBtnDown")
	self.bindData.passingBtn.luaRelease = self:CreateAction("OnPassingBtnUp")
	self.bindData.mouseMoveRespond.luaGamePadInputChanged = self:CreateAction("OnMouseMove")
	self.bindData.joystick.luaValueChanged = self:CreateAction("OnJoyStickValueChange")
	self.bindData.joystick.luaBeginDrag = self:CreateAction("OnJoyStickBeginDrag")
	self.bindData.joystick.luaEndDrag = self:CreateAction("OnJoyStickEndDrag")
	self.bindData.rightControllerMoveRespond.luaGamePadInputChanged = self:CreateAction("OnRightControllerMove")
	self.bindData.leftControllerMoveRespond.luaGamePadInputChanged = self:CreateAction("OnLeftControllerMove")
end

function M:OnJoyStickBeginDrag()
	self.bindData.shootJoystickCtrl = self.ShootJoystickCtrl.BeginDrag

	self:OnShootBtnDown()
end

function M:OnJoyStickEndDrag()
	self.bindData.shootJoystickCtrl = self.ShootJoystickCtrl.EndDrag

	self:OnShootBtnUp()
end

function M:OnJoyStickValueChange(x, y, size)
	self:SetballRect(Vector2.New(x, y))
end

function M:OnShow()
	self:ResetData()
end

function M:OnClose()
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
end

function M:ResetData()
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
end

function M:OnShootBtnDown()
	if self.isPressed then
		return
	end

	self.bindData.crossHairStatus = 0
	self.isPressed = true
	self.canShootBtnDown = true

	self:PlayProgress()

	self.forward = gCS.CameraDataMgr.MainCamera.transform.forward
	self.bindData.showBarCtrl = 1
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false

	gCS.LuaUtils.FootballShootRelease(Vector2.New(0, 0), 0, self.forward)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballShootPress)
end

function M:OnShootBtnUp()
	self.canShootBtnDown = false

	if self.progressTimer then
		self.progressTimer:Stop()

		self.progressTimer = nil
	end

	gCS.LuaUtils.FootballShootRelease(self.shootdirection, self.progressValue, self.forward)
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballShootRelease)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.ani, "S_Vx_Football_circleRect")
end

function M:OnMouseMove(context)
	if not self.canShootBtnDown then
		return
	end

	local screenDelta = context:ReadValueVector2()

	self:SetballRect(screenDelta)
end

function M:SetballRect(screenDelta)
	print_debug(screenDelta)

	local size = self.bindData.circleRect.rect.size
	local r = math.min(size.x, size.y) * 0.5
	local localDelta = screenDelta / gCS.LuaUtils.GetFootballUIMouseSensitivity()

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		localDelta = localDelta * 50
	end

	self.offset = self.offset or Vector2.New(0, 0)
	self.offset = self.offset + localDelta
	local mag = self.offset.magnitude

	if r < mag then
		self.offset = self.offset / mag * r
	end

	self.shootdirection = self.offset / mag
	self.bindData.ballRect.anchoredPosition = self.offset
end

function M:PlayProgress()
	self.currentValue = 0
	local maxTimer = gCS.LuaUtils.GetFootballUIForceMaxTimer()
	self.progressTimer = Timer.New(function ()
		self.currentValue = self.currentValue + 0.1

		if maxTimer <= self.currentValue then
			self.currentValue = maxTimer

			self:OnShootBtnUp()
		elseif self.currentValue <= 0 then
			self.currentValue = 0
		end

		self.progressValue = self.currentValue / maxTimer
		self.bindData.progress = self.progressValue
	end, 0.1, -1):Start()
end

function M:OnAccelerateBtnDown()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballRushPress)
end

function M:OnAccelerateBtnUp()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballRushRelease)
end

function M:OnPrecisionBallBearingBtnDown()
	self.isCtrlPressed = true

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCtrlPress)
end

function M:OnPrecisionBallBearingBtnUp()
	self.isCtrlPressed = false

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCtrlRelease)
end

function M:OnCPressBtnClick()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballCPress)
end

function M:OnDribbleBtnClick()
	if self.isCtrlPressed then
		gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballFancyPress)

		return
	end

	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballChaseballPress)
end

function M:OnPassingBtnDown()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballPassPress)
end

function M:OnPassingBtnUp()
	gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballPassRelease)
end

function M:OnDribbleBtnDown()
	self.isSpacePressed = true

	Timer.New(function ()
		if self.isSpacePressed and self.isCtrlPressed then
			gCS.LogicStateMachineManager.Send3CEvent(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPCCCEventConfig.FootballFancySkill)
		end
	end, 0.3):Start()
end

function M:OnDribbleBtnUp()
	self.isSpacePressed = false
end

function M:OnRightControllerMove(context)
	local value = context:ReadValueVector2()

	if context.started or context.performed then
		gCameraUtils:DoRotateCameraByGamePad(1, value.x, value.y)
	end

	if context.canceled then
		gCameraUtils:DoRotateCameraByGamePad(1, 0, 0)
	end
end

function M:OnLeftControllerMove(context)
	if not self.isPressed then
		return
	end

	local vector2 = context:ReadValueVector2()

	self:SetballRect(vector2 * self.ShootGamepadUIMouseSensitivity)
end
