-- Original chunk: @Lua\LuaFiles\LX6\Manager\SkyCountManager.lua
-- Decompiled from: 00613_SkyCountManager.lua_826e54262f36.luajit

C_SkyCountManager = DefClass("C_SkyCountManager", C_SkyCountManager)
local M = C_SkyCountManager
local SkyCountDownMode = UX.Game.SkyCountdownMode

M.ctor = function(self)
	self.mode = nil
	self.updateHandler = nil
	self.flashlightEnabled = false
	self.isAngleValid = false
	self.isPanelOpen = false
	self.endTime = 0
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.UNIT_CLIENT_STATE_CHANGE, self:CreateAction("OnUnitClientStateChange"))
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction("OnAfterSwitchScene"))
end

M.OnUnitClientStateChange = function(self, eventId, pid, stateId, isActive)
	if stateId ~= LTConfig.UnitStateClientStateConfig.OpenFlashLight then
		self.flashlightEnabled = isActive

		if self.mode ~= SkyCountDownMode.Unlock then
			if isActive then
				print_debug("skyCountDown: 手电筒打开，注册update")
				self:RegisterUpdate()
			else
				print_debug("skyCountDown: 手电筒关闭，注销update")
				self:UnRegisterUpdate()
				self:ClosePanelImmediately()
			end
		end
	end
end

M.SyncSetSkyCountdownMode = function(self, mode, endTime)
	print_debug("SyncSetSkyCountdownMode", mode)

	self.mode = mode
	self.endTime = endTime

	self:OnModeChange(mode)
end

M.OnModeChange = function(self, mode)
	if mode ~= SkyCountDownMode.Locked then
		self:ClosePanelImmediately()
		self:UnRegisterUpdate()
	elseif mode ~= SkyCountDownMode.Unlock then
		if self.flashlightEnabled then
			self:RegisterUpdate()
		end
	elseif mode ~= SkyCountDownMode.UnlockAndVisible then
		print_debug("skyCountDown: 解锁后常驻常显，直接显示")
		self:UnRegisterUpdate()
		self:UpdatePanelState()
	end
end

M.RegisterUpdate = function(self)
	if self.updateHandler then
		return
	end

	self.updateHandler = UpdateBeat:CreateListener(self.Update, self)

	UpdateBeat:AddListener(self.updateHandler)
end

M.UnRegisterUpdate = function(self)
	if self.updateHandler then
		UpdateBeat:RemoveListener(self.updateHandler)

		self.updateHandler = nil
	end
end

M.Update = function(self)
	self:UpdateCameraAngle()
	self:UpdatePanelState()
end

M.CalculateLookUpAngle = function(self)
	if not gCS.CameraDataMgr or not gCS.CameraDataMgr.MainCamera then
		return 0
	end

	local cameraForward = gCS.CameraDataMgr.MainCamera.transform.forward
	local upVector = Vector3.up
	local dotProduct = Vector3.Dot(cameraForward, upVector)
	dotProduct = math.max(-1, math.min(1, dotProduct))
	local angleInRadians = math.acos(dotProduct)
	local angleInDegrees = angleInRadians * 180 / math.pi

	return angleInDegrees
end

M.UpdateCameraAngle = function(self)
	local lookUpAngle = self:CalculateLookUpAngle()
	local newAngleValid = lookUpAngle > LTConfig.TaskConfig.SkyCountDownPitch

	if self.isAngleValid == newAngleValid then
		self.isAngleValid = newAngleValid
	end
end

M.UpdatePanelState = function(self)
	if not self.mode then
		return
	end

	local shouldShowPanel = false

	if self.mode ~= SkyCountDownMode.Locked then
		shouldShowPanel = false
	elseif self.mode ~= SkyCountDownMode.UnlockAndVisible then
		shouldShowPanel = true
	elseif self.mode ~= SkyCountDownMode.Unlock then
		shouldShowPanel = self.isAngleValid and self.flashlightEnabled
	end

	local currentlyShowing = gPanelManager:IsPanelShowing(gPanelId.S_SKY_COUNT_DOWN_PANEL)

	if shouldShowPanel and not currentlyShowing then
		local x = LTConfig.TaskConfig.SkyCountDownPos[1]
		local y = LTConfig.TaskConfig.SkyCountDownPos[2]
		local z = LTConfig.TaskConfig.SkyCountDownPos[3]
		local dirX = LTConfig.TaskConfig.SkyCountDownDir[1]
		local dirY = LTConfig.TaskConfig.SkyCountDownDir[2]
		local dirZ = LTConfig.TaskConfig.SkyCountDownDir[3]

		if dirX ~= 0 and dirY ~= 0 and dirZ ~= 0 or dirX == dirX or dirY == dirY or dirZ == dirZ then
			dirZ = 0
			dirY = 0
			dirX = 90
		end

		gPanelManager:CheckShow(gPanelId.S_SKY_COUNT_DOWN_PANEL, nil, Vector3.New(x, y, z), Vector3.New(dirX, dirY, dirZ), LTConfig.TaskConfig.SkyCountDownWidthHeight[1], LTConfig.TaskConfig.SkyCountDownWidthHeight[2])

		self.isPanelOpen = true
	elseif not shouldShowPanel and currentlyShowing then
		gPanelManager:Close(gPanelId.S_SKY_COUNT_DOWN_PANEL)

		self.isPanelOpen = false
	end
end

M.ClosePanelImmediately = function(self)
	if gPanelManager:IsPanelShowing(gPanelId.S_SKY_COUNT_DOWN_PANEL) then
		gPanelManager:Close(gPanelId.S_SKY_COUNT_DOWN_PANEL)

		self.isPanelOpen = false
	end
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	self:ClosePanelImmediately()
	self:UnRegisterUpdate()

	self.flashlightEnabled = false
	self.isAngleValid = false
end

M.OnAfterSwitchScene = function(self)
	if self.mode then
		self:OnModeChange(self.mode)
	end
end

M.GetUnixEndTime = function(self)
	return self.endTime
end

gSkyCountManager = gSkyCountManager or C_SkyCountManager.new()
