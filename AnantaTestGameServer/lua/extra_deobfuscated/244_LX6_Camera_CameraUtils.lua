local M = gCameraUtils or {}
M.cameraUpdatedEvent = {}
M.gamePadRotateCamStartTime = -1

function M:OnInit()
	self.enableMainCamera = false

	gMessageManager:AddMessageListener(gEventConstants.ENABLE_MAIN_CAMERA, self.EnableMainCamera)
end

function M.EnableMainCamera(eventId, data)
	gCameraUtils.enableMainCamera = data
end

function M.OnCameraUpdate()
	if not M.cameraUpdatedEvent then
		return
	end

	for _, v in pairs(M.cameraUpdatedEvent) do
		if v then
			v()
		end
	end
end

function M.AddCameraUpdateEvent(key, event)
	if not key or not event then
		return
	end

	if not M.cameraUpdatedEvent then
		M.cameraUpdatedEvent = {}
	end

	M.cameraUpdatedEvent[key] = event
end

function M.RemoveCameraUpdateEvent(key)
	if not key then
		return
	end

	if not M.cameraUpdatedEvent then
		M.cameraUpdatedEvent = {}
	end

	M.cameraUpdatedEvent[key] = nil
end

function M:SetCameraYawAndPitchByTime(yaw, pitch, time)
	if time == nil then
		time = 0.5
	end

	gCS.CameraDataMgr.cinemachineManager:SetCameraYawAndPitchByTime(yaw, pitch, time)
end

function M:UnitReborn()
	local yaw = gCS.MyPlayerManager.PlayerUnit.WorldEulerY

	self:SetCameraYawAndPitchByTime(yaw, 0.5, 0)
end

function M:SetCameraXYAxisValue(x, y, time, priority)
	if gCS.CameraDataMgr.cinemachineManager then
		gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(x, y, time or 0, priority or 3)
	end
end

function M:DoRotateCameraByGamePad(context, inputX, inputY)
	local pressedTime = self.gamePadRotateCamStartTime < 0 and 0 or gLogicTime.time - self.gamePadRotateCamStartTime
	local rotated = gCS.CameraDataMgr.cameraControllerManager:DoRotateCameraByGamePad(context, inputX, inputY, pressedTime)

	if not rotated then
		self.gamePadRotateCamStartTime = -1
	elseif self.gamePadRotateCamStartTime < 0 then
		self.gamePadRotateCamStartTime = gLogicTime.time
	end
end

gCameraUtils = M
