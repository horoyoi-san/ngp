-- Original chunk: @Lua\LuaFiles\LX6\Manager\Shop\MallCameraManager.lua
-- Decompiled from: 01312_MallCameraManager.lua_775f3133bda6.luajit

local DragEventListener = SGUI.EventSystems.DragEventListener
local CityPediaConfig = LTConfig.CityPediaConfig
local MallConfig = LTConfig.MallConfig
gMallCameraManager = gMallCameraManager or {}
local M = gMallCameraManager
local EInputButton = {
	["V'{O"] = 0,
	["1A\\x95\\x8a\\x8fD"] = 2,
	["\\xa7\\xa5\\xa7\\xa2"] = 1
}
local EAccelCurveType = {
	[","] = 3,
	I3oO = 4,
	["rRmm\\;"] = 2,
	["0A\\x9f\\x8b\\x82S"] = 1
}
local accelCurveFuncs = {
	[EAccelCurveType.Linear] = function (pixels, k)
		return 1 + k * pixels
	end,
	[EAccelCurveType.Quadratic] = function (pixels, k)
		return 1 + k * pixels * pixels
	end,
	[EAccelCurveType.Ln] = function (pixels, k)
		return 1 + k * math.log(1 + pixels)
	end,
	[EAccelCurveType.Sqrt] = function (pixels, k)
		return 1 + k * math.sqrt(pixels)
	end
}
M.EAccelCurveType = EAccelCurveType
local panelStack = {}
local panelDict = {}

local UPDATE_DICT = function()
	table.clear(panelDict)

	for index, t in ipairs(panelStack) do
		local id = t.panelId
		panelDict[id] = index
	end
end

M.SetMallPanelCamera = function(self, panelId, enable, params)
	if not enable then
		if panelDict[panelId] ~= nil then
			return
		end

		local index = panelDict[panelId]

		table.remove(panelStack, index)
		UPDATE_DICT()
	elseif panelDict[panelId] ~= nil then
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

	self:UpdateMallPanelCamera()
end

M.UpdateMallPanelCamera = function(self)
	if #panelStack < 0 then
		self:RemoveEvent()
	else
		local top = panelStack[1]
		local params = top.params

		self:InitCamera(params)
		self:RegisterEvent()
	end
end

M.RegisterEvent = function(self)
	if self.isRegister then
		self.countFinish = true

		return
	end

	self.handler = function(eventId, data)
		self:SetBanMove(data)
	end

	gMessageManager:AddMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)

	self.updateHandler = UpdateBeat:CreateListener(self:CreateAction("Update"), self)

	UpdateBeat:AddListener(self.updateHandler)
	self:AfterInitCamera()

	self.isRegister = true
end

M.RemoveEvent = function(self)
	if not self.isRegister then
		return
	end

	UpdateBeat:RemoveListener(self.updateHandler)
	gMessageManager:RemoveMessageListener(gEventConstants.CAMERA_DISTANCE_MIN, self.handler)

	self.isRegister = false
end

local GetDefaultCameraConfig = function()
	return {
		rotateSpeed = CityPediaConfig.FashionCameraRotateSpeed,
		mouseOffsetDPI = CityPediaConfig.FashionChangeCameraOffsetMouseDPI,
		rotateMouseDPI = CityPediaConfig.FashionCameraRotateMouseDPI,
		zoomSpeed = CityPediaConfig.FashionCameraZoomSpeed,
		zoomRange = {
			CityPediaConfig.FashionCameraZoomMinLimit,
			CityPediaConfig.FashionCameraZoomMaxLimit
		}
	}
end

M.InitCamera = function(self, params)
	local verticalButton = params.verticalButton

	if verticalButton then
		local gestureListener = SGUI.EventSystems.GestureEventListener.Get(verticalButton.gameObject)
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		local dragListener = DragEventListener.Get(verticalButton.gameObject)
		dragListener.onBeginDrag = self:CreateAction("OnBeginDrag")
		dragListener.onDrag = self:CreateAction("OnDrag")
		dragListener.onEndDrag = self:CreateAction("OnEndDrag")
		verticalButton.luaPress = self:CreateAction("OnVerticalBtnPress")
		verticalButton.luaRelease = self:CreateAction("OnVerticalBtnRelease")
	end

	if params.rightStickCustomNavRespond then
		params.rightStickCustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightStickRespondInput")
	end

	if params.L2CustomNavRespond then
		params.L2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnL2RespondInput")
	end

	if params.R2CustomNavRespond then
		params.R2CustomNavRespond.luaGamePadInputChanged = self:CreateAction("OnR2RespondInput")
	end

	local cfg = GetDefaultCameraConfig()
	local override = params.cameraControlConfig

	if override then
		cfg.rotateSpeed = override.rotateSpeed or cfg.rotateSpeed
		cfg.mouseOffsetDPI = override.moveMouseDPI or cfg.mouseOffsetDPI
		cfg.rotateMouseDPI = override.rotateMouseDPI or cfg.rotateMouseDPI
		cfg.zoomSpeed = override.zoomSpeed or cfg.zoomSpeed
		cfg.zoomRange = override.zoomRange or cfg.zoomRange
		cfg.maxRotateDragPixel = override.maxRotateDragPixel or cfg.maxRotateDragPixel
	end

	local cameraOffsetRange = params.cameraOffsetRange

	if not cameraOffsetRange and override and override.yOffsetRange then
		cameraOffsetRange = override.yOffsetRange
	end

	self.basePanel = params.basePanel
	self.camera = params.camera
	self.modelRoot = params.modelRoot
	self.banMove = false
	self.countFinish = false
	self.CameraRotateSpeed = cfg.rotateSpeed or 1
	self.mouseOffsetDPI = cfg.mouseOffsetDPI or 1
	self.rotateMouseDPI = cfg.rotateMouseDPI or 1
	self.zoomSpeed = cfg.zoomSpeed or 0.1
	self.zoomRange = cfg.zoomRange or {
		-10,
		-1
	}
	self.maxRotateDragPixel = cfg.maxRotateDragPixel or 12
	self.banRotate = params.banRotate
	self.cameraOffset = cameraOffsetRange or {
		-0.5,
		0.5
	}
	self.checkButtonEnabled = params.checkButtonEnabled
	self.rotateCenter = params.rotateCenter
	self.autoRotateRecenter = params.autoRotateRecenter
	self.allowRotateModelAroundAllAxis = params.allowRotateModelAroundAllAxis
	self.accelCurveType = MallConfig.MallCameraVehicleAccFuncType or EAccelCurveType.Sqrt
	self.accelK = MallConfig.MallCameraVehicleAccFuncK or 0.08
	self.accelDeadzone = MallConfig.MallCameraVehicleAccFuncDeadZone or 300

	self:ResetRotateAccel()

	self.targetCameraPos = nil
	self.zoomLerpSpeed = 10

	if not gCS.LuaUtils.IsNull(self.camera) then
		if params.cameraOffset then
			self.camera.transform.localPosition = params.cameraOffset
		end

		if params.cameraEuler then
			self.camera.transform.localEulerAngles = params.cameraEuler
		end

		if params.fov then
			self.camera.fieldOfView = params.fov
		end
	end

	self.homeRotation = self.modelRoot.rotation

	if self.rotateCenter then
		self.homePosition = self.modelRoot.position
	end
end

M.AfterInitCamera = function(self)
	self.timer = Timer.New(function ()
		self.countFinish = true
		self.timer = nil
	end, 1, -1):Start()
end

M.SetBanMove = function(self, data)
	self.banMove = data ~= 0
end

M.Update = function(self)
	if not self.countFinish or self.banRotate then
		return
	end

	if self.targetCameraPos and self.camera then
		local currentPos = self.camera.transform.localPosition
		local newPos = Vector3.Lerp(currentPos, self.targetCameraPos, Time.deltaTime * self.zoomLerpSpeed)
		self.camera.transform.localPosition = newPos

		if Vector3.Distance(currentPos, self.targetCameraPos) >= 0.001 then
			self.camera.transform.localPosition = self.targetCameraPos
			self.targetCameraPos = nil
		end
	end

	if self.zoomFrame ~= Time.frameCount then
		return
	end

	local gamePadDragging = false

	if self.dragGamePad and self.gamePadPos and self.gamePadPos == Vector2.zero then
		if math.abs(self.gamePadPos.x) <= 3 then
			local dir = self.gamePadPos.x <= 0 and 1 or -1
			local accelMul = 1

			if self:IsVehicleRotateAccelEnabled() then
				self:UpdateRotateAccel(self.gamePadPos.x)

				accelMul = self:GetRotateAccelMultiplier()

				print_debug(string.format("[RotateAccel-Pad] dir=%d pixels=%.1f mul=%.3f curve=%d", self.accelDir, self.accelAccumPixels, accelMul, self.accelCurveType or 1))
			end

			self:RotateMallModel(dir * self.CameraRotateSpeed * 0.003 * accelMul)

			gamePadDragging = true
		end

		if math.abs(self.gamePadPos.y) <= 3 then
			self:VerticalMoveMallCamera(-self.gamePadPos.y * self.mouseOffsetDPI * 10)
		end
	end

	if self.autoRotateRecenter and not self.dragging and not gamePadDragging and self.homeRotation then
		local cur = self.modelRoot.rotation

		if Quaternion.Angle(cur, self.homeRotation) <= 0.2 then
			local t = 0.1
			self.modelRoot.rotation = Quaternion.Slerp(cur, self.homeRotation, t)

			if self.rotateCenter and self.homePosition then
				self.modelRoot.position = Vector3.Lerp(self.modelRoot.position, self.homePosition, t)
			end
		end
	end

	if self.isL2RespondInput then
		if not self.checkButtonEnabled or self.checkButtonEnabled() then
			self:ZoomCamera(1)
		else
			self.isL2RespondInput = false
		end
	end

	if self.isR2RespondInput then
		if not self.checkButtonEnabled or self.checkButtonEnabled() then
			self:ZoomCamera(-1)
		else
			self.isR2RespondInput = false
		end
	end
end

M.ResetRotateAccel = function(self)
	self.accelDir = 0
	self.accelAccumPixels = 0
end

M.SetAccelCurveType = function(self, curveType, k, deadzone)
	self.accelCurveType = curveType

	if k then
		self.accelK = k
	end

	if deadzone then
		self.accelDeadzone = deadzone
	end
end

M.GetRotateAccelMultiplier = function(self)
	local pixels = self.accelAccumPixels
	local deadzone = self.accelDeadzone or 0

	if pixels < deadzone then
		return 1
	end

	local fn = accelCurveFuncs[self.accelCurveType] or accelCurveFuncs[EAccelCurveType.Linear]

	return fn(pixels - deadzone, self.accelK)
end

M.UpdateRotateAccel = function(self, deltaX)
	local dir = deltaX <= 0 and 1 or -1

	if dir == self.accelDir then
		self.accelDir = dir
		self.accelAccumPixels = math.abs(deltaX)
	else
		self.accelAccumPixels = self.accelAccumPixels + math.abs(deltaX)
	end
end

M.IsVehicleRotateAccelEnabled = function(self)
	local sceneManager = gMallSceneManager

	return sceneManager and sceneManager.currentLoadingType ~= sceneManager.LoadingType.Vehicle
end

M.OnBeginDrag = function(self)
	self.dragGamePad = false
	self.gamePadPos = nil

	self:ResetRotateAccel()

	self.dragging = true
end

M.OnEndDrag = function(self)
	self:ResetRotateAccel()

	self.dragging = false
end

local VEHICLE_TAP_THRESHOLD_SQR = 100

M.OnVerticalBtnPress = function(self)
	local pos = gUtils:GetTouchPosition()
	self._vehiclePressPos = pos and Vector3.New(pos.x, pos.y, 0) or nil
end

M.OnVerticalBtnRelease = function(self)
	local pressPos = self._vehiclePressPos
	self._vehiclePressPos = nil

	if not pressPos then
		return
	end

	if self.dragging then
		return
	end

	local releasePos = gUtils:GetTouchPosition()

	if not releasePos then
		return
	end

	local delta = releasePos - pressPos

	if VEHICLE_TAP_THRESHOLD_SQR >= delta.sqrMagnitude then
		return
	end

	gMallSceneManager:TryToggleVehiclePartByScreenPos(releasePos)
end

M.OnDrag = function(self, eventData)
	if not self.countFinish or self.banRotate then
		self:ResetRotateAccel()

		return
	end

	local delta = eventData.delta

	if delta:SqrMagnitude() >= 3 then
		return
	end

	local rotateSpeed = self.CameraRotateSpeed or 1
	local rotateDPI = self.rotateMouseDPI or 1
	local moveDPI = self.mouseOffsetDPI or 1
	local rotateDeltaX = delta.x
	local rotateDeltaY = delta.y
	local maxPixel = self.maxRotateDragPixel

	if maxPixel and maxPixel <= 0 then
		rotateDeltaX = Mathf.Clamp(rotateDeltaX, -maxPixel, maxPixel)
		rotateDeltaY = Mathf.Clamp(rotateDeltaY, -maxPixel, maxPixel)
	end

	local accelMulX = 1
	local accelMulY = 1

	if self:IsVehicleRotateAccelEnabled() then
		if math.abs(delta.x) <= 0.5 then
			self:UpdateRotateAccel(delta.x)

			accelMulY = self:GetRotateAccelMultiplier()
		else
			self:ResetRotateAccel()
		end

		print_debug(string.format("[RotateAccel] dir=%d pixels=%.1f mul=%.3f curve=%d", self.accelDir, self.accelAccumPixels, accelMulY, self.accelCurveType or 1))
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		if eventData.button ~= EInputButton.Left then
			local y = -rotateDeltaX * rotateSpeed * 0.0005 * rotateDPI * accelMulY
			local x = -rotateDeltaY * rotateSpeed * 0.0005 * rotateDPI * accelMulX

			self:RotateMallModel(y, x)
		elseif eventData.button ~= EInputButton.Middle and not self.banMove then
			self:VerticalMoveMallCamera(-delta.y * moveDPI * 0.8)
		end
	else
		if math.abs(delta.x) <= 4 then
			self:RotateMallModel(-rotateDeltaX * rotateSpeed * 0.0005 * rotateDPI * accelMulY)
		end

		if math.abs(delta.y) <= 4 and not self.banMove then
			self:VerticalMoveMallCamera(-delta.y * moveDPI * 0.8)
		end
	end
end

M.GetLiveModelRoot = function(self)
	local root = self.modelRoot

	if root and not gCS.LuaUtils.IsNull(root) then
		return root
	end

	local vehicle = gMallSceneManager.currentVehicle

	if vehicle and vehicle.gameObject and not gCS.LuaUtils.IsNull(vehicle.gameObject) then
		root = vehicle.gameObject.transform
		self.modelRoot = root

		return root
	end

	local unit = gMallSceneManager.currentModelUnit

	if unit and unit.PlayerObj and not gCS.LuaUtils.IsNull(unit.PlayerObj) then
		root = unit.PlayerObj.transform
		self.modelRoot = root

		return root
	end

	local weaponGo = gMallSceneManager.currentWeaponGo

	if weaponGo and not gCS.LuaUtils.IsNull(weaponGo) then
		root = weaponGo.transform
		self.modelRoot = root

		return root
	end

	return nil
end

M.RotateMallModel = function(self, y, x, z)
	y = y or 0
	x = x or 0

	if y ~= 0 and x ~= 0 and z ~= 0 or not self.modelRoot then
		return
	end

	local rotation = self.modelRoot.localEulerAngles

	if not rotation or rotation.y ~= nil then
		print_warn("[MallCameraManager] RotateMallModel: model not found")

		return
	end

	if self.rotateCenter then
		self.modelRoot:RotateAround(self.rotateCenter, self.modelRoot.forward, -y)

		if self.allowRotateModelAroundAllAxis then
			self.modelRoot:RotateAround(self.rotateCenter, self.modelRoot.up, x)
		end

		return
	end

	rotation.y = rotation.y + y

	if self.allowRotateModelAroundAllAxis then
		rotation.x = rotation.x + x
	end

	self.modelRoot.localEulerAngles = rotation
end

M.GetDynamicYRange = function(self, z)
	local minZ = self.zoomRange and self.zoomRange[1] or -10
	local maxZ = self.zoomRange and self.zoomRange[2] or -1
	local baseMin = self.cameraOffset[1]
	local baseMax = self.cameraOffset[2]
	local deltaMin = MallConfig.MallCameraYOffsetMinLimitDelta or 0.8
	local deltaMax = MallConfig.MallCameraYOffsetMaxLimitDelta or 0.4
	local range = maxZ - minZ
	local t = 0

	if math.abs(range) <= 0.001 then
		t = Mathf.Clamp01((z - minZ) / range)
	end

	return baseMin - t * deltaMin, baseMax + t * deltaMax
end

M.VerticalMoveMallCamera = function(self, y)
	if y ~= 0 or not self.camera or not self.cameraOffset then
		return
	end

	self.targetCameraPos = nil
	local pos = self.camera.transform.localPosition
	local yMin, yMax = self:GetDynamicYRange(pos.z)
	local newY = Mathf.Clamp(pos.y + y, yMin, yMax)
	pos.y = newY
	self.camera.transform.localPosition = pos
end

M.ZoomCamera = function(self, zoomValue)
	if not self.camera then
		return
	end

	local cameraTransform = self.camera.transform
	local currentPos = self.targetCameraPos or cameraTransform.localPosition
	local oldZ = currentPos.z
	local newZ = oldZ + zoomValue * self.zoomSpeed
	local minZ = self.zoomRange and self.zoomRange[1] or -10
	local maxZ = self.zoomRange and self.zoomRange[2] or -1

	if newZ >= minZ then
		newZ = minZ
	end

	if maxZ >= newZ then
		newZ = maxZ
	end

	if math.abs(newZ - oldZ) >= 0.001 then
		return
	end

	local targetY = currentPos.y

	if self.cameraOffset then
		local yMin, yMax = self:GetDynamicYRange(newZ)
		targetY = Mathf.Clamp(targetY, yMin, yMax)
	end

	self.targetCameraPos = Vector3.New(currentPos.x, targetY, newZ)
end

M.OnGestureZoom = function(self, zoom)
	self.zoomFrame = Time.frameCount

	if not self.countFinish then
		return
	end

	if self.basePanel and gCS.LuaUtils.GetCurrentHoverGo() ~= self.basePanel.gameObject then
		if zoom <= 0 then
			self:ZoomCamera(1)
		else
			self:ZoomCamera(-1)
		end
	end
end

M.OnRightStickRespondInput = function(self, context)
	if context.started then
		self.dragGamePad = true

		self:ResetRotateAccel()
	end

	if context.performed then
		local rotateParam = context:ReadValueVector2()
		self.gamePadPos = rotateParam * Time.deltaTime * 300 * -1
	end

	if context.canceled then
		self.dragGamePad = false
		self.gamePadPos = nil

		self:ResetRotateAccel()
	end
end

M.OnL2RespondInput = function(self, context)
	if context.started then
		if self.checkButtonEnabled and not self.checkButtonEnabled() then
			self.isL2RespondInput = false

			return
		end

		self.isL2RespondInput = true
	end

	if context.canceled then
		self.isL2RespondInput = false
	end
end

M.OnR2RespondInput = function(self, context)
	if context.started then
		if self.checkButtonEnabled and not self.checkButtonEnabled() then
			self.isR2RespondInput = false

			return
		end

		self.isR2RespondInput = true
	end

	if context.canceled then
		self.isR2RespondInput = false
	end
end

M.BuildMallCameraControlConfig = function(self, kind)
	local rotateSpeed, maxRotateDragPixel = nil
	local LoadingType = gMallSceneManager.LoadingType

	if kind ~= LoadingType.Vehicle then
		rotateSpeed = MallConfig.MallCameraRotateSpeedVehicle
		maxRotateDragPixel = MallConfig.MallCameraMaxRotateDragPixelVehicle
	elseif kind ~= LoadingType.Weapon then
		rotateSpeed = MallConfig.MallCameraRotateSpeedWeapon
		maxRotateDragPixel = MallConfig.MallCameraMaxRotateDragPixelWeapon
	else
		rotateSpeed = MallConfig.MallCameraRotateSpeedFashion
		maxRotateDragPixel = MallConfig.MallCameraMaxRotateDragPixelFashion
	end

	return {
		rotateSpeed = rotateSpeed or MallConfig.MallCameraRotateSpeed or 1,
		maxRotateDragPixel = maxRotateDragPixel,
		rotateMouseDPI = MallConfig.MallCameraRotateMouseDPI or 1,
		moveMouseDPI = MallConfig.MallCameraMoveMouseDPI or 1,
		zoomSpeed = MallConfig.MallCameraZoomSpeed or 0.1,
		zoomRange = {
			MallConfig.MallCameraZoomMinLimit or -10,
			MallConfig.MallCameraZoomMaxLimit or -1
		},
		yOffsetRange = {
			MallConfig.MallCameraYOffsetMinLimit or -0.5,
			MallConfig.MallCameraYOffsetMaxLimit or 0.5
		}
	}
end

M.RefreshConfig = function(self)
	if #panelStack < 0 then
		return
	end

	local top = panelStack[1]
	local params = top.params

	if params and params.cameraControlConfig then
		local kind = gMallSceneManager and gMallSceneManager.currentLoadingType
		local newCfg = self:BuildMallCameraControlConfig(kind)
		params.cameraControlConfig = newCfg
		params.cameraOffsetRange = newCfg.yOffsetRange
	end

	self:InitCamera(params)
end

M.CreateAction = function(self, action, target)
	return function (...)
		target = target or M

		if type(action) ~= "string" then
			if target[action] then
				return target[action](target, ...)
			end
		else
			return action(target, ...)
		end
	end
end

if gMallCameraManager then
	gMallCameraManager:RefreshConfig()
end

gMallCameraManager = M
