local M = {
	isJumpKeyUp = false,
	isOnJoystickMove = false,
	swingYaw = 0,
	isJumpKeyDown = false,
	IsJumpSwingEnd = false,
	joyStickPercent = 0,
	isJumpSwing = false,
	swingNeedCheckAngle = false,
	isMagnetKeyDown = false,
	isPressingJumpDown = false,
	swingLeft = false,
	jumpKeyDownStartTime = 0
}

function M:ResetParam()
	self.joyStickPercent = 0
	self.jumpKeyDownStartTime = 0

	if self.isJumpKeyDown then
		gCS.TransitionMgr.isJumpKeyDown = false
	end

	self.isJumpKeyDown = false
	self.isPressingJumpDown = false

	if self.isJumpKeyUp then
		gCS.TransitionMgr.isJumpKeyUp = false
	end

	self.isJumpKeyUp = false
	self.swingYaw = 0
	self.swingLeft = false
	self.isJumpSwing = false
	self.IsJumpSwingEnd = false
	self.swingNeedCheckAngle = false
	self.isMagnetKeyDown = false

	if gCS.MyPlayerManager.PlayerUnit then
		gCS.JumpModuleMgr.JumpKeyUp(gCS.MyPlayerManager.PlayerUnit)
	end

	gCS.TransitionMgr.isMagnetKeyDown = false
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		self:ResetParam()
	end
end

function M:SetIsMagnetKeyDownFromCS(enable)
	self.isMagnetKeyDown = enable
end

gUnitOperateManager = M
