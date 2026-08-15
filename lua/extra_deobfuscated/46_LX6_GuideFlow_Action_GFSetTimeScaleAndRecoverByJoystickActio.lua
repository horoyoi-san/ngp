local gGFConstant = require("LX6/GuideFlow/GFConstant")
C_GFSetTimeScaleAndRecoverByJoystickAction = DefClass("C_GFSetTimeScaleAndRecoverByJoystickAction", C_GFSetTimeScaleAndRecoverByJoystickAction, C_GFWaitActionBase)
local C_GFSetTimeScaleAndRecoverByJoystickAction = C_GFSetTimeScaleAndRecoverByJoystickAction

function C_GFSetTimeScaleAndRecoverByJoystickAction:ctor(id, isMonitor, params)
	self.timeScale = params.timeScale
	self.joystickDir = params.joystickDir
	self.countDownTime = params.countDownTime and (params.countDownTime < 0 and -1 or params.countDownTime) or -1
	self.recordTimeScale = false
	self.mNodeName = "C_GFSetTimeScaleAndRecoverByJoystickAction"
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:OnStartAction()
	self.recordTimeScale = Time.timeScale
	Time.timeScale = self.timeScale
	self.timeRecord = Time.unscaledTime
	self.mStartAction = true
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:OnUpdate()
	if self.finishDirectly then
		self:FinishNode(true)
	elseif self.mSelfFinished then
		self:FinishNode(true)
	end
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:OnUpdateForce()
	if not self.mSelfFinished and self.recordTimeScale and (self:CheckJoystickInput() or self:CheckCountDownTime()) then
		Time.timeScale = self.recordTimeScale
		self.recordTimeScale = false
		self.mSelfFinished = true
	end
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:CheckJoystickInput()
	local dir = gLuaDataManager.guiMgr.sguiJoystick:GetJoystickDragPos()

	if self.joystickDir == gGFConstant.JoystickDir.Up then
		return dir.y > 0
	end

	if self.joystickDir == gGFConstant.JoystickDir.Down then
		return dir.y < 0
	end

	if self.joystickDir == gGFConstant.JoystickDir.Left then
		return dir.x < 0
	end

	if self.joystickDir == gGFConstant.JoystickDir.Right then
		return dir.x > 0
	end

	return false
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:CheckCountDownTime()
	if self.countDownTime < 0 then
		return false
	else
		return self.countDownTime < Time.unscaledTime - self.timeRecord
	end
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:OnStopNode()
	if not self.mSelfFinished then
		if self.recordTimeScale then
			Time.timeScale = self.recordTimeScale
			self.recordTimeScale = false
		end

		self.mStartAction = false
	end
end

function C_GFSetTimeScaleAndRecoverByJoystickAction:OnReset()
	self.mSelfFinished = false
end

return C_GFSetTimeScaleAndRecoverByJoystickAction
