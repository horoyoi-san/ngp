local DragEventListener = SGUI.EventSystems.DragEventListener
local CityPediaConfig = LTConfig.CityPediaConfig
gBaikeCameraManager = gBaikeCameraManager or {}
local M = gBaikeCameraManager
M.CameraType = {
	Vehicle = 2,
	Fashion = 1
}
local panelStack = {}
local panelDict = {}
local camTempVec3 = Vector3.New(0, 0, 0)

local function UPDATE_DICT()
	table.clear(panelDict)

	for index, t in ipairs(panelStack) do
		local id = t.panelId
		panelDict[id] = index
	end
end

local function GetCameraConfigByCameraType(cameraType)
	local config = {}

	if cameraType == M.CameraType.Fashion then
		config.rotateSpeed = CityPediaConfig.FashionCameraRotateSpeed
		config.mouseOffsetDPI = CityPediaConfig.FashionChangeCameraOffsetMouseDPI
		config.rotateMouseDPI = CityPediaConfig.FashionCameraRotateMouseDPI
		config.zoomSpeed = CityPediaConfig.FashionCameraZoomSpeed
		config.zoomRange = {
			CityPediaConfig.FashionCameraZoomMinLimit,
			CityPediaConfig.FashionCameraZoomMaxLimit
		}
	elseif cameraType == M.CameraType.Vehicle then
		config.rotateSpeed = CityPediaConfig.VehicleCameraRotateSpeed
		config.mouseOffsetDPI = CityPediaConfig.VehicleChangeCameraOffsetMouseDPI
		config.rotateMouseDPI = CityPediaConfig.VehicleCameraRotateMouseDPI
		config.zoomSpeed = CityPediaConfig.VehicleCameraZoomSpeed
		config.zoomRange = {
			CityPediaConfig.VehicleCameraZoomMinLimit,
			CityPediaConfig.VehicleCameraZoomMaxLimit
		}
	end

	return config
end

function M:SetBaikePanelCamera(panelId, enable, params)
	if not enable then
		if panelDict[panelId] == nil then
			return
		end

		local index = panelDict[panelId]

		table.remove(panelStack, index)
		UPDATE_DICT()
	elseif panelDict[panelId] == nil then
		local t = {
			panelId = panelId,
			params = params
		}

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	else
		local index = panelDict[panelId]
		local t = table.remove(panelStack, index)
		t.params = params

		table.insert(panelStack, 1, t)
		UPDATE_DICT()
	end

	self:UpdateBaikePanelCamera()
end

function M:UpdateBaikePanelCamera()
	if #panelStack <= 0 then
		self:RemoveEvent()
	else
		local top = panelStack[1]
		local params = top.params

		self:InitCamera(params.verticalButton, params.basePanel, params.rightStickCustomNavRespond, params.L2CustomNavRespond, params.R2CustomNavRespond, params.camera, params.modelRoot, params.cameraOffsetRange, params.banRotate, params.cameraType, params.cameraOffset, params.cameraEuler, params.fov)
		self:RegisterEvent()
	end
end

function M:RegisterEvent()
	if self.isRegister then
		self.countFinish = true

		return
	end

	function self.handler(eventId, data)
		self:SetBanMove(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)

	self.updateHandler = UpdateBeat:CreateListener(self:CreateAction("Update"), self)

	UpdateBeat:AddListener(self.updateHandler)
	self:AfterInitCamera()

	self.isRegister = true
end

function M:RemoveEvent()
	if not self.isRegister then
		return
	end

	UpdateBeat:RemoveListener(self.updateHandler)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)

	self.isRegister = false
end

function M:InitCamera(verticalButton, basePanel, rightStickCustomNavRespond, L2CustomNavRespond, R2CustomNavRespond, camera, modelRoot, cameraOffsetRange, banRotate, cameraType, cameraOffset, cameraEuler, fov)
	if verticalButton then
		local gestureListener = SGUI.EventSystems.GestureEventListener.Get(verticalButton.gameObject)
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		local baseUpdownButton = DragEventListener.Get(verticalButton.gameObject)
		baseUpdownButton.onBeginDrag = self:CreateAction("OnBaseUpDownBtnPress")
		baseUpdownButton.onEndDrag = self:CreateAction("OnBasUpDowneBtnRelease")
	end

	if rightStickCustomNavRespond then
		rightStickCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
	end

	if L2CustomNavRespond then
		L2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnL2RespondInput")
	end

	if R2CustomNavRespond then
		R2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnR2RespondInput")
	end

	local cameraConfig = GetCameraConfigByCameraType(cameraType or M.CameraType.Fashion)
	self.basePanel = basePanel
	self.camera = camera
	self.modelRoot = modelRoot
	self.banMove = false
	self.countFinish = false
	self.CameraRotateSpeed = cameraConfig.rotateSpeed
	self.mouseOffsetDPI = cameraConfig.mouseOffsetDPI
	self.rotateMouseDPI = cameraConfig.rotateMouseDPI
	self.zoomSpeed = cameraConfig.zoomSpeed
	self.zoomRange = cameraConfig.zoomRange
	self.banRotate = banRotate
	self.cameraOffset = cameraOffsetRange or {
		-0.5,
		0.5
	}
	self.targetCameraPos = nil
	self.zoomLerpSpeed = 10

	if camera then
		if cameraOffset then
			camera.transform.localPosition = cameraOffset
		end

		if cameraEuler then
			camera.transform.localEulerAngles = cameraEuler
		end

		if fov then
			camera.fieldOfView = fov
		end
	end
end

function M:AfterInitCamera()
	self.timer = Timer.New(function ()
		self.countFinish = true
		self.timer = nil
	end, 1, -1):Start()
end

function M:OnlyRemoveListener()
	UpdateBeat:RemoveListener(self.updateHandler)
end

function M:DestroyCamera()
	UpdateBeat:RemoveListener(self.updateHandler)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)

	self.banMove = false
	self.countFinish = false
	self.basePanel = nil
	self.camera = nil
	self.modelRoot = nil
	self.handler = nil
	self.banRotate = false
	self.cameraOffset = nil
	self.CameraRotateSpeed = nil
	self.mouseOffsetDPI = nil
	self.rotateMouseDPI = nil
	self.zoomSpeed = nil
	self.zoomRange = nil
	self.targetCameraPos = nil
	self.zoomLerpSpeed = nil
end

function M:SetBanMove(data)
	self.banMove = data == 0
end

function M:Update()
	if not self.countFinish or self.banRotate then
		return
	end

	if self.targetCameraPos and self.camera then
		local currentPos = self.camera.transform.localPosition
		local newPos = Vector3.Lerp(currentPos, self.targetCameraPos, Time.deltaTime * self.zoomLerpSpeed)
		self.camera.transform.localPosition = newPos

		if Vector3.Distance(currentPos, self.targetCameraPos) < 0.001 then
			self.camera.transform.localPosition = self.targetCameraPos
			self.targetCameraPos = nil
		end
	end

	if self.zoomFrame == Time.frameCount then
		return
	end

	if (self.dragging or self.draggingUpDown) and self.lastPos and self.lastPos.x and self.lastPos.y then
		local curPos = gUtils:GetTouchPosition()
		local deltaX = self.lastPos.x - curPos.x
		local deltaY = self.lastPos.y - curPos.y
		local absDeltaX = math.abs(deltaX)
		local absDeltaY = math.abs(deltaY)

		if absDeltaX > 2 or absDeltaY > 2 then
			if self.draggingUpDown then
				if not gCS.LuaUtils.IsNonMobileAdaptive() then
					if absDeltaY < absDeltaX then
						self:ChangeCameraOffset(deltaX > 0 and self.CameraRotateSpeed or -self.CameraRotateSpeed, 0)
					else
						self:ChangeCameraOffset(0, deltaY * self.rotateMouseDPI)
					end
				else
					self:ChangeCameraOffset(deltaX > 0 and self.CameraRotateSpeed or -self.CameraRotateSpeed, 0)
				end
			else
				self:ChangeCameraOffset(0, deltaY * self.rotateMouseDPI)
			end
		end

		self.lastPos = curPos
	end

	if self.dragGamePad and self.gamePadPos and self.gamePadPos ~= Vector2.zero then
		if math.abs(self.gamePadPos.x) > 3 then
			self:ChangeCameraOffset(self.gamePadPos.x > 0 and self.CameraRotateSpeed * 0.3 or -self.CameraRotateSpeed * 0.3, 0)
		end

		if math.abs(self.gamePadPos.y) > 3 then
			self:ChangeCameraOffset(0, -self.gamePadPos.y * self.rotateMouseDPI)
		end
	end

	if self.isL2RespondInput then
		self:ZoomCamera(1)
	end

	if self.isR2RespondInput then
		self:ZoomCamera(-1)
	end
end

function M:ChangeCameraOffset(x, y)
	if self.cameraOffset == nil then
		return
	end

	self.targetCameraPos = nil
	local mouseOffsetDPI = self.mouseOffsetDPI

	if y ~= 0 and self.camera then
		local currentCamY = self.camera.transform.localPosition.y

		if camTempVec3.y == 0 then
			camTempVec3.y = currentCamY
		end

		local camY = camTempVec3.y + y * mouseOffsetDPI

		if camY < self.cameraOffset[1] then
			camY = self.cameraOffset[1]
		end

		if self.cameraOffset[2] < camY then
			camY = self.cameraOffset[2]
		end

		camTempVec3:Set(0, camY, 0)

		local cameraPos = self.camera.transform.localPosition
		cameraPos.y = camY
		self.camera.transform.localPosition = cameraPos
	end

	if x ~= 0 and self.modelRoot then
		local rotation = self.modelRoot.localEulerAngles
		rotation.y = rotation.y + mouseOffsetDPI * x
		self.modelRoot.localEulerAngles = rotation
	end
end

function M:ZoomCamera(zoomValue)
	if not self.camera or not self.modelRoot then
		return
	end

	local zoomSpeed = self.zoomSpeed
	local camera = self.camera
	local cameraTransform = camera.transform
	local mousePos = gUtils:GetTouchPosition()
	local currentPos = self.targetCameraPos or cameraTransform.localPosition
	local oldZ = currentPos.z
	local newZ = oldZ + zoomValue * zoomSpeed
	local minDistance = self.zoomRange and self.zoomRange[1] or -10
	local maxDistance = self.zoomRange and self.zoomRange[2] or -1

	if newZ < minDistance then
		newZ = minDistance
	end

	if maxDistance < newZ then
		newZ = maxDistance
	end

	if math.abs(newZ - oldZ) < 0.001 then
		return
	end

	local oldCameraPos = cameraTransform.localPosition
	local tempPos = Vector3.New(currentPos.x, currentPos.y, currentPos.z)
	cameraTransform.localPosition = tempPos
	local screenPoint = Vector3.New(mousePos.x, mousePos.y, math.abs(oldZ))
	local worldPointBefore = camera:ScreenToWorldPoint(screenPoint)
	local localPointBefore = self.modelRoot:InverseTransformPoint(worldPointBefore)
	local newCameraPos = Vector3.New(currentPos.x, currentPos.y, newZ)
	cameraTransform.localPosition = newCameraPos
	screenPoint.z = math.abs(newZ)
	local worldPointAfter = camera:ScreenToWorldPoint(screenPoint)
	local localPointAfter = self.modelRoot:InverseTransformPoint(worldPointAfter)
	cameraTransform.localPosition = oldCameraPos
	local localOffset = localPointBefore - localPointAfter
	newCameraPos.y = newCameraPos.y + localOffset.y

	if self.cameraOffset then
		if newCameraPos.y < self.cameraOffset[1] then
			newCameraPos.y = self.cameraOffset[1]
		elseif self.cameraOffset[2] < newCameraPos.y then
			newCameraPos.y = self.cameraOffset[2]
		end
	end

	camTempVec3.y = newCameraPos.y
	self.targetCameraPos = newCameraPos
end

function M:OnGestureZoom(zoom)
	self.zoomFrame = Time.frameCount

	if not self.countFinish then
		return
	end

	if self.basePanel and gCS.LuaUtils.GetCurrentHoverGo() == self.basePanel.gameObject then
		if zoom > 0 then
			self:ZoomCamera(1)
		else
			self:ZoomCamera(-1)
		end
	end
end

function M:OnBaseUpDownBtnPress(eventData)
	if eventData.button == 0 then
		self.draggingUpDown = true
		self.lastPos = gUtils:GetTouchPosition()
	elseif eventData.button == 2 and not self.banMove then
		self.dragging = true
		self.lastPos = gUtils:GetTouchPosition()
		camTempVec3.y = self.camera.transform.localPosition.y
	end
end

function M:OnBasUpDowneBtnRelease(eventData)
	if eventData.button == 0 then
		self.draggingUpDown = false
		self.lastPos = nil
	elseif eventData.button == 2 then
		self.dragging = false
		self.lastPos = nil
	end
end

function M:OnRightStickRespondInput(context)
	if context.started then
		self.dragGamePad = true
		camTempVec3.y = self.camera.transform.localPosition.y
	end

	if context.performed then
		local rotateParam = context:ReadValueVector2()
		self.gamePadPos = rotateParam * Time.deltaTime * 300 * -1
	end

	if context.canceled then
		self.dragGamePad = false
		self.gamePadPos = nil
	end
end

function M:OnL2RespondInput(context)
	if context.started then
		self.isL2RespondInput = true
	end

	if context.canceled then
		self.isL2RespondInput = false
	end
end

function M:OnR2RespondInput(context)
	if context.started then
		self.isR2RespondInput = true
	end

	if context.canceled then
		self.isR2RespondInput = false
	end
end

function M:CreateAction(action, target)
	return function (...)
		target = target or M

		if type(action) == "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

gBaikeCameraManager = M
