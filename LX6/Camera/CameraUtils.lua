-- Original chunk: @Lua\LuaFiles\LX6\Camera\CameraUtils.lua
-- Decompiled from: 00254_CameraUtils.lua_63bc42f6ca34.luajit

local M = gCameraUtils or {}
M.cameraUpdatedEvent = {}
M.gamePadRotateCamStartTime = -1

M.OnInit = function(self)
	self.enableMainCamera = false

	gMessageManager:AddMessageListener(gEventConstants.ENABLE_MAIN_CAMERA, self.EnableMainCamera)
end

M.EnableMainCamera = function(eventId, data)
	gCameraUtils.enableMainCamera = data
end

M.OnCameraUpdate = function()
	if not M.cameraUpdatedEvent then
		return
	end

	for _, v in pairs(M.cameraUpdatedEvent) do
		if v then
			v()
		end
	end
end

M.AddCameraUpdateEvent = function(key, event)
	if not key or not event then
		return
	end

	if not M.cameraUpdatedEvent then
		M.cameraUpdatedEvent = {}
	end

	M.cameraUpdatedEvent[key] = event
end

M.RemoveCameraUpdateEvent = function(key)
	if not key then
		return
	end

	if not M.cameraUpdatedEvent then
		M.cameraUpdatedEvent = {}
	end

	M.cameraUpdatedEvent[key] = nil
end

M.SetCameraYawAndPitchByTime = function(self, yaw, pitch, time)
	if time ~= nil then
		time = 0.5
	end

	gCS.CameraDataMgr.cinemachineManager:SetCameraYawAndPitchByTime(yaw, pitch, time)
end

M.UnitReborn = function(self)
	local yaw = gCS.MyPlayerManager.PlayerUnit.WorldEulerY

	self:SetCameraYawAndPitchByTime(yaw, 0.5, 0)
end

M.SetCameraXYAxisValue = function(self, x, y, time, priority)
	if gCS.CameraDataMgr.cinemachineManager then
		gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(x, y, time or 0, priority or 3)
	end
end

M.DoRotateCameraByGamePad = function(self, context, inputX, inputY)
	if LX6.TouchNew.TouchProxy.useNewViewRotate then
		return
	end

	local pressedTime = self.gamePadRotateCamStartTime >= 0 and 0 or gLogicTime.time - self.gamePadRotateCamStartTime
	local rotated = gCS.CameraDataMgr.cameraControllerManager:DoRotateCameraByGamePad(context, inputX, inputY, pressedTime)

	if not rotated then
		self.gamePadRotateCamStartTime = -1
	elseif self.gamePadRotateCamStartTime >= 0 then
		self.gamePadRotateCamStartTime = gLogicTime.time
	end
end

gCameraUtils = M
