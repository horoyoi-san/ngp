C_FryTeaPanelStore = DefClass("C_FryTeaPanelStore", C_FryTeaPanelStore, C_StoreGroup)
GroupName2Class.FryTeaPanelStore = C_FryTeaPanelStore
local M = C_FryTeaPanelStore
local Input = UnityEngine.Input
local Screen = UnityEngine.Screen
local InputActionBind = SGUI.InputActionBind
local GameInputManager = LX6.Manager.GameInputManager
local GameDevice = SGUI.GameDevice
local AudioManager = LX6.Audio.AudioManager
local curSecond = 0
local rightSecond = 0
local notMoveSecond = 0

function M:ctor()
	self.levelDefine = {
		high = 2,
		mid = 1,
		low = 0
	}
	self.canInput = false
	self.isDragging = false
	self.lastInputPosition = nil
	self.lastMoveSpeed = 0
	self.maxRightSpeed = 300
	self.minEffectiveSpeed = 10
	self.deltaTime = 0
	self.followSmoothness = 10
	self.maxRightSpeed = 300
	self.gamepadAccelerationScale = 3
	self.returnSpeed = -100
	self.currentVelocity = 0
	self.dragAcceleration = 500
	self.friction = 0.95
	self.maxVelocity = 800
	self.widthChangeTimer = 0
	self.widthChangeInterval = 10
	self.widthChangeCount = 0
	self.maxWidthChanges = 3
	self.minWidthRange = 50
	self.maxWidthRange = 100
	self.joyStickMoveSpeed = 100
	self.curSmokeRate = 20
	self.curHeatRate = 20
	self.initLightIntensity = 20
	self.curLevel = self.levelDefine.low
	self.dragThreshold = 10
	self.lastEndDragTime = nil
	self.tipCloseAnimName = "S_Vx_FryTea_PC_PCTips_close"
	self.hintAnimName = "S_Vx_FryTea_Slider_FlashHint"
	self.isPlayTipAnim = false
	self.canStartCountAnim = false
	self.needUpdateJoyStick = false
	self.rightStickCurVector = nil
	self.isPlayHintAnim = false
	self.hasPlayedHintAnim = false
	self.initialSimulatorPos = Vector3.zero
	self.initialPadAngleX = 0
	self.initialPadAngleZ = 0
	self.positionSensitivity = 0.05
	self.deadZone = 1
	self.offsetNormalizeRange = 100
	self.mouseSmoothFactor = 0.2
	self.lastMouseOffsetVector = Vector2.zero
end

function M:OnAwake()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.interactBtn.luaBeginDrag = self:CreateAction("OnBeginDrag")
		self.bindData.interactBtn.luaDrag = self:CreateAction("OnDrag")
		self.bindData.interactBtn.luaEndDrag = self:CreateAction("OnEndDrag")
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.joyStick.luaGamePadInputChanged = self:CreateAction("OnRightStickControl")
		self.bindData.joyStickShake.luaGamePadInputChanged = self:CreateAction("OnRightStickShakeControl")
	end

	self.tipCloseAnimTime = gClientUtils.GetAnimationClipLength(self.bindData.tipAnim, self.tipCloseAnimName)
end

function M:ClosePanel()
	gCS.MyPlayerManager.SwitchCameraBlock(true)
	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_FARM_PANEL, false)
	GameInputManager.RemoveCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt)
end

function M:OnActiveDeviceChange(device)
	self.currentDevice = InputActionBind.activeGameDevice
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:OnShow(panelId, data)
	self.angularSpeedAccumulator = 0
	self.lastAngularVelocity = Vector3.zero
	self.lastStickValue = Vector2.zero
	self.lastInputPosition = nil
	self.lastMouseOffsetVector = Vector2.zero
	self.lastPadMode = -1
	self.calibrated = false
	self.bindData.flashActive = false
	self.accumulatedPitch = 0
	self.accumulatedYaw = 0
	self.isPlayHintAnim = false
	self.hasPlayedHintAnim = false
	curSecond = 0
	self.canInput = false
	self.needUpdateJoyStick = false
	self.allowShake = false
	self.joyStickMoveSpeed = self.joyStickMoveSpeed or 500
	self.isDragging = false
	self.canStartCountAnim = false
	notMoveSecond = 0
	self.lastEndDragTime = nil
	self.isPlayTipAnim = false
	self.curLevel = self.levelDefine.low

	gCS.MyPlayerManager.SwitchCameraBlock(false)

	self.currentDevice = InputActionBind.activeGameDevice

	gCS.GuiUtils.SetPanelHideCursor(gPanelId.S_FARM_PANEL, true)
	GameInputManager.AddCursorControl(LX6.Manager.GameInputManager.ControlType.GameplayAlt, false, UnityEngine.CursorLockMode.None)

	self.camera = gCS.CameraDataMgr.MainCamera
	self.simulator = data.data.simulator
	self.modelControl = data.data.modelControl
	self.simulatorInitTrans = data.data.simulatorInitTrans
	self.bindData.slider.maxValue = data.data.sliderMaxValue
	self.maxChangeSeconds = data.data.totalSecond
	self.maxWidthChanges = data.data.maxChanges
	self.addValue = data.data.addValue
	self.bgWidth = self.bindData.bgRect.rect.width
	self.bgHalfWidth = self.bgWidth / 2

	self.bindData.progress:ProgressToValue(0)

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.widthChangeTimer = 0
	self.widthChangeCount = 0
	self.returnSpeed = data.data.returnSpeed
	self.dragAcceleration = data.data.acceleration
	self.lastMoveSpeed = self.returnSpeed
	self.currentVelocity = self.returnSpeed
	self.lowPosRange = data.data.lowPosRange
	self.midPosRange = data.data.midPosRange
	self.highPosRange = data.data.highPosRange
	self.curInstanceId = data.data.instanceId
	self.initLightIntensity = 5
	self.Smoke = data.data.Smoke
	self.Heat = data.data.Heat

	self:RandomLocateRectWidth()

	self.potLightComp = data.data.potLight.gameObject:GetComponent(typeof(UnityEngine.Light))
	self.potLightComp.intensity = self.initLightIntensity

	gCS.SimulatorGameUtils.SetSimulatorParticleRateOverTime(self.Smoke, self.curSmokeRate)
	gCS.SimulatorGameUtils.SetSimulatorParticleRateOverTime(self.Heat, self.curHeatRate)

	self.bindData.tipsActive = false
	self.bindData.padType = 2

	Timer.New(function ()
		self.bindData.tipsActive = true
		self.bindData.padType = 0
		self.lastPadMode = 0

		self:ResetMousePosition()

		self.canInput = true

		Timer.New(function ()
			self.bindData.tipAnim:Play(self.tipCloseAnimName)
			Timer.New(function ()
				if self.simulator then
					self.initialSimulatorPos = self.simulator.transform.position
				end

				gClientUtils.ResetAnimation(self.bindData.tipAnim, self.tipCloseAnimName)

				self.initialPadAngleX = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationX()
				self.initialPadAngleZ = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationZ()
				self.bindData.tipsActive = false
				self.bindData.padType = 2
				self.lastEndDragTime = Time.deltaTime
				self.canStartCountAnim = true

				SGUI.UNavigationMgrEx.Inst:ResetCurrentPadOrientation()

				local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
				self.lastYVector = motionData.orientation
				self.calibrated = true
				self.lastDualSenseInput = Vector2.zero
			end, self.tipCloseAnimTime):Start()
		end, 2):Start()
	end, 0.8):Start()
end

function M:ResetMousePosition()
	if self.currentDevice == GameDevice.KeyboardMouse and gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		local initScreenPos = self.camera:WorldToScreenPoint(self.simulator.transform.position)

		LX6.Manager.GameInputManager.SetCursorPositionInPC(initScreenPos.x, initScreenPos.y)
	end
end

function M:RandomLocateRectWidth()
	local targetValue = 0

	if self.curLevel == self.levelDefine.low then
		targetValue = math.random(self.lowPosRange.x, self.lowPosRange.y)
	elseif self.curLevel == self.levelDefine.mid then
		targetValue = math.random(self.midPosRange.x, self.midPosRange.y)
	else
		targetValue = math.random(self.highPosRange.x, self.highPosRange.y)
	end

	targetValue = targetValue / 100
	local maxHalfWidth = nil

	if targetValue <= 0.5 then
		maxHalfWidth = targetValue * self.bgWidth
	else
		maxHalfWidth = (1 - targetValue) * self.bgWidth
	end

	local minHalfWidth = maxHalfWidth * 0.8
	local randomHalfWidth = math.random(minHalfWidth, maxHalfWidth)
	local randomWidth = 2 * randomHalfWidth

	if randomWidth >= self.bgWidth * 0.5 then
		randomWidth = randomWidth * 0.6
	end

	local bgLeft = -self.bgHalfWidth
	local bgRight = self.bgHalfWidth
	local uiPositionX = bgLeft + targetValue * (bgRight - bgLeft)
	uiPositionX = math.max(bgLeft + randomHalfWidth, math.min(uiPositionX, bgRight - randomWidth))
	self.bindData.locateRect.localPosition = Vector3.New(uiPositionX, 0, 0)
	local size = self.bindData.locateRect.sizeDelta
	size.x = randomWidth
	self.bindData.locateRect.sizeDelta = size
	self.currentLocateWidth = randomWidth
	self.currentLocatePosX = uiPositionX
	self.currentLocateLeft = uiPositionX - randomWidth
	self.currentLocateRight = uiPositionX + randomWidth
end

function M:GameEnd()
	self.canInput = false
	gStoreManager:GetStoreGroup("FarmPanelStore").bindData.btnBack.interactable = false

	Timer.New(function ()
		gSpoonClientMgr:ReleaseContextEvent(self.curInstanceId, gSpoonEventType.ReceiveFryTeaResult, {
			fryTeaResult = rightSecond / self.maxChangeSeconds
		})
		gStoreManager:GetStoreGroup("FarmPanelStore"):ClosePanel()
	end, 1):Start()
end

function M:OnDisable()
	if not gCS.LuaUtils.IsNull(self.simulatorInitTrans) then
		self.simulator.transform.position = self.simulatorInitTrans.position
		self.simulator.transform.rotation = Quaternion.Euler(self.simulatorInitTrans.rotation.x, self.simulatorInitTrans.rotation.y, self.simulatorInitTrans.rotation.z)
	end
end

function M:OnUpdate()
	if not self.canInput then
		return
	end

	gCS.SimulatorGameUtils.UpdateModelChanges(self.modelControl)

	self.deltaTime = Time.deltaTime
	curSecond = curSecond + Time.deltaTime
	self.bindData.timeText = self:GetFormatCountDownTime(math.floor(self.maxChangeSeconds - curSecond))
	self.bindData.timeFill = (self.maxChangeSeconds - curSecond) / self.maxChangeSeconds

	if self.maxChangeSeconds <= curSecond then
		self.bindData.timeText = 0

		self:GameEnd()
	end

	if self.lastEndDragTime and not self.isDragging and not self.isPlayTipAnim then
		notMoveSecond = notMoveSecond + Time.deltaTime

		if notMoveSecond >= 2 then
			self.bindData.tipsActive = true
			self.isPlayTipAnim = true
			self.bindData.padType = 0

			Timer.New(function ()
				if not self.canInput then
					return
				end

				if not self.bindData.tipAnim then
					return
				end

				self.bindData.tipAnim:Play(self.tipCloseAnimName)
				Timer.New(function ()
					self.isPlayTipAnim = false

					if not self.bindData.tipAnim then
						return
					end

					gClientUtils.ResetAnimation(self.bindData.tipAnim, self.tipCloseAnimName)

					self.bindData.tipsActive = false
					self.bindData.padType = 2
					self.lastEndDragTime = Time.deltaTime
					notMoveSecond = 0
				end, self.tipCloseAnimTime):Start()
			end, 2):Start()
		end
	end

	self:UpdateSimulatorMove()
	self:UpdateSmokeAndHeat()
	self:UpdatePotLight()

	local curPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, Input.mousePosition)

	self.bindData.mouseRect:SetLocalPositionXY(curPos.x, curPos.y)
	self:UpdateWidthChangeWidthTimer()
	self:UpdateVelocity()
	self:UpdateHandlePosition()
	self:ClampHandlePosition()
	self:UpdateSliderValue()
	self:UpdateProgress()
end

function M:UpdateSimulatorMove()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	if self.simulator and not self.cameraHeight then
		self.cameraHeight = math.abs(self.camera.transform.position.y - self.simulator.transform.position.y)
		self.mouseMoveScale = 0.0015 * 1 / (self.cameraHeight * 0.5)
	end

	self.isDragging = false

	if not self.gamepadMode then
		self:HandleMouseInput()
	elseif self.needUpdateJoyStick then
		self:HandleJoyStickInput()
	end

	if self.isDragging and self.canStartCountAnim then
		self.lastEndDragTime = Time.time
		notMoveSecond = 0
	end
end

function M:HandleMouseInput()
	local curInputPosition = Input.mousePosition
	local curInputUIPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, curInputPosition)
	local lastInputUIPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, self.lastInputPosition)
	local delta = curInputUIPos - lastInputUIPos
	local deltaLength = math.sqrt(delta.x * delta.x + delta.y * delta.y)
	self.lastMoveSpeed = deltaLength / Time.deltaTime * 0.3
	self.lastInputPosition = curInputPosition

	if self.simulator then
		self.isDragging = true

		if not self.cameraHeight then
			self.cameraHeight = math.abs(self.camera.transform.position.y - self.simulator.transform.position.y)
		end

		local mouseX = curInputPosition.x
		local mouseY = curInputPosition.y
		local screenSpace = Vector3.New(mouseX, mouseY, self.cameraHeight)
		local cursorWorldPos = self.camera:ScreenToWorldPoint(screenSpace)
		local validTargetPos = gCS.SimulatorGameUtils.GetValidFitterPosition(self.simulator.gameObject, cursorWorldPos)
		self.simulator.transform.position = Vector3.Lerp(self.simulator.transform.position, validTargetPos, 20 * Time.deltaTime)
		local fitterRot = gCS.SimulatorGameUtils.GetFitRotationAngle(self.simulator.gameObject, self.simulator.transform.position)
		self.simulator.transform.rotation = Quaternion.Lerp(self.simulator.transform.rotation, fitterRot, 8 * Time.deltaTime)
	end
end

function M:HandleJoyStickInput()
	if not self.needUpdateJoyStick or not self.rightStickCurVector then
		self.lastMoveSpeed = 0

		return
	end

	local stickValue = self.rightStickCurVector
	local deltaStick = stickValue - self.lastStickValue
	self.lastStickValue = stickValue

	if deltaStick.magnitude < 0.01 then
		self.lastMoveSpeed = 0

		return
	end

	self.isDragging = true
	local angle = Mathf.Atan2(stickValue.y, stickValue.x) * Mathf.Rad2Deg

	self:HandleShakeSound(angle)

	self.lastMoveSpeed = deltaStick.magnitude / Time.deltaTime * self.joyStickMoveSpeed * 0.3
	local cameraForward = self.camera.transform.forward
	local cameraRight = self.camera.transform.right
	cameraForward.y = 0
	cameraRight.y = 0
	cameraForward = cameraForward.normalized
	cameraRight = cameraRight.normalized
	local moveDir = cameraForward * stickValue.y + cameraRight * stickValue.x
	moveDir = moveDir.normalized
	local moveDelta = moveDir * 5 * Time.deltaTime
	local curSimPos = self.simulator.transform.position
	local targetWorldPos = curSimPos + moveDelta
	local validTargetPos = gCS.SimulatorGameUtils.GetValidFitterPosition(self.simulator.gameObject, targetWorldPos)
	self.simulator.transform.position = Vector3.Lerp(self.simulator.transform.position, validTargetPos, self.followSmoothness * Time.deltaTime)
	local fitterRot = gCS.SimulatorGameUtils.GetFitRotationAngle(self.simulator.gameObject, self.simulator.transform.position)
	self.simulator.transform.rotation = Quaternion.Lerp(self.simulator.transform.rotation, fitterRot, 8 * Time.deltaTime)
end

function M:CalculateHandlePoseVector()
	local rotX = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationX()
	local rotY = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationY()
	local rotZ = SGUI.UNavigationMgrEx.Inst:GetCurrentPadOrientationZ()
	local radX = math.rad(rotX)
	local radY = math.rad(rotY)
	local radZ = math.rad(rotZ)
	local quatX = Quaternion.AngleAxis(radX, Vector3.right)
	local quatY = Quaternion.AngleAxis(radY, Vector3.up)
	local quatZ = Quaternion.AngleAxis(radZ, Vector3.forward)
	local finalRot = quatX * quatY * quatZ
	local poseVector = finalRot * Vector3.up

	return poseVector
end

function M:HandleDualSenseShake()
	if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation then
		return
	end

	if self.lastPadMode ~= -1 and self.lastPadMode ~= 1 then
		self.bindData.padType = 1
		self.lastPadMode = 1
		self.isPlayTipAnim = true
		notMoveSecond = 0

		Timer.New(function ()
			if not self.bindData.tipAnim then
				return
			end

			self.bindData.tipAnim:Play(self.tipCloseAnimName)
			Timer.New(function ()
				if self.bindData.padType == 1 then
					self.isPlayTipAnim = false
					self.bindData.padType = 2
				end

				gClientUtils.ResetAnimation(self.bindData.tipAnim, self.tipCloseAnimName)
			end, self.tipCloseAnimTime):Start()
		end, 2):Start()
	end

	local motionData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadMotionData()
	local angularVelocity = motionData.angularVelocity

	if math.abs(angularVelocity.x) < 3 and math.abs(angularVelocity.z) < 3 then
		self.lastMoveSpeed = 0
		self.lastDualSenseInput = Vector2.zero

		return
	end

	local currentAngularSpeed = angularVelocity.magnitude
	local angularAcceleration = (currentAngularSpeed - self.lastAngularVelocity.magnitude) / Time.deltaTime

	if currentAngularSpeed > 0.5 then
		local accelerationBonus = math.max(0, angularAcceleration) * 0.1
		self.angularSpeedAccumulator = self.angularSpeedAccumulator + (currentAngularSpeed + accelerationBonus) * Time.deltaTime
		self.angularSpeedAccumulator = self.angularSpeedAccumulator * (1 - 0.3 * Time.deltaTime)
	else
		self.angularSpeedAccumulator = self.angularSpeedAccumulator * (1 - 0.8 * Time.deltaTime)
	end

	self.angularSpeedAccumulator = math.min(self.angularSpeedAccumulator, 10)
	self.isDragging = true
	local rawInputX = -angularVelocity.z * 1.2
	local rawInputY = -angularVelocity.x * 1.2
	rawInputX = Mathf.Clamp(rawInputX, -1, 1)
	rawInputY = Mathf.Clamp(rawInputY, -1, 1)
	local inputVector = Vector2.New(rawInputX, rawInputY)
	local smoothedInput = Vector2.Lerp(self.lastDualSenseInput or Vector2.zero, inputVector, 5 * Time.deltaTime)

	if smoothedInput.magnitude > 0.001 then
		smoothedInput = smoothedInput.normalized * math.min(smoothedInput.magnitude, inputVector.magnitude)
	end

	self.lastDualSenseInput = smoothedInput
	local baseSpeed = self.joyStickMoveSpeed * 2
	local accumulatedBoost = 1 + self.angularSpeedAccumulator * 0.1
	self.lastMoveSpeed = baseSpeed * accumulatedBoost
	self.lastMoveSpeed = angularVelocity.magnitude / Time.deltaTime * self.joyStickMoveSpeed * 0.04
	self.lastAngularVelocity = angularVelocity
	local cameraRight = self.camera.transform.right
	local cameraForward = self.camera.transform.forward
	cameraRight.y = 0
	cameraForward.y = 0
	cameraRight = cameraRight.normalized
	cameraForward = cameraForward.normalized
	local moveVector = cameraRight * smoothedInput.x + cameraForward * smoothedInput.y

	if moveVector.magnitude > 0.001 then
		moveVector = moveVector.normalized
	end

	local moveDelta = moveVector * 2 * Time.deltaTime
	local curSimPos = self.simulator.transform.position
	local targetWorldPos = curSimPos + moveDelta
	local validTargetPos = gCS.SimulatorGameUtils.GetValidFitterPosition(self.simulator.gameObject, targetWorldPos)
	self.simulator.transform.position = Vector3.Lerp(curSimPos, validTargetPos, 22 * Time.deltaTime)
	local fitterRot = gCS.SimulatorGameUtils.GetFitRotationAngle(self.simulator.gameObject, self.simulator.transform.position)
	self.simulator.transform.rotation = Quaternion.Lerp(self.simulator.transform.rotation, fitterRot, 8 * Time.deltaTime)
	local angle = Mathf.Atan2(inputVector.y, inputVector.x) * Mathf.Rad2Deg

	self:HandleShakeSound(angle)
end

function M:HandleShakeSound(angle)
	local sid = AudioManager.Instance:PlaySound(70350034)
	local soundData = AudioManager.Instance:GetSoundBySid(sid)

	if not soundData or not angle then
		return
	end

	local adjustedAngle = angle

	if adjustedAngle > 180 then
		adjustedAngle = adjustedAngle - 360
	elseif adjustedAngle < -180 then
		adjustedAngle = adjustedAngle + 360
	end

	adjustedAngle = adjustedAngle + (adjustedAngle > 0 and -180 or 180)

	soundData:SetRTPCValue(gSoundMgr.RTPCGroup.ObjectAngular, adjustedAngle)
end

function M:UpdatePotLight()
	if self.canInput then
		self.potLightComp.intensity = self.potLightComp.intensity + Time.deltaTime
	end
end

function M:UpdateSmokeAndHeat()
	if self.canInput then
		self.curSmokeRate = self.curSmokeRate + Time.deltaTime
		self.curHeatRate = self.curHeatRate + Time.deltaTime

		gCS.SimulatorGameUtils.SetSimulatorParticleRateOverTime(self.Smoke, self.curSmokeRate)
		gCS.SimulatorGameUtils.SetSimulatorParticleRateOverTime(self.Heat, self.curHeatRate)
	end
end

function M:UpdateVelocity()
	if self.isDragging then
		if self.minEffectiveSpeed < self.lastMoveSpeed then
			local acceleration = 0

			if self.gamepadMode then
				acceleration = self.lastMoveSpeed * self.gamepadAccelerationScale
			else
				acceleration = self.dragAcceleration * self.lastMoveSpeed / self.maxRightSpeed
			end

			self.currentVelocity = self.currentVelocity + acceleration * self.deltaTime
		else
			self.currentVelocity = Mathf.Lerp(self.currentVelocity, self.returnSpeed, 5 * self.deltaTime)
		end
	else
		self.currentVelocity = Mathf.Lerp(self.currentVelocity, self.returnSpeed, 5 * self.deltaTime)
	end

	self.currentVelocity = self.currentVelocity * self.friction
end

function M:UpdateHandlePosition()
	local handlePos = self.bindData.handleRect.localPosition
	handlePos.x = handlePos.x + self.currentVelocity * self.deltaTime
	self.bindData.handleRect.localPosition = handlePos
end

function M:UpdateWidthChangeWidthTimer()
	if self.maxWidthChanges <= self.widthChangeCount then
		return
	end

	self.widthChangeTimer = self.widthChangeTimer + Time.deltaTime

	if self.widthChangeInterval <= self.widthChangeTimer then
		self.curLevel = (self.curLevel + 1) % 3

		self:RandomLocateRectWidth()

		self.widthChangeTimer = 0
		self.widthChangeCount = self.widthChangeCount + 1
	end
end

function M:ClampHandlePosition()
	local handlePos = self.bindData.handleRect.localPosition
	local clampedX = Mathf.Clamp(handlePos.x, -self.bgHalfWidth, self.bgHalfWidth)
	handlePos.x = clampedX
	self.bindData.handleRect.localPosition = handlePos
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
	self.bindData.padType = 0
	self.bindData.tipsActive = true
	self.isPlayTipAnim = true

	Timer.New(function ()
		if not self.bindData.tipAnim then
			return
		end

		self.bindData.tipAnim:Play(self.tipCloseAnimName)
		Timer.New(function ()
			self.isPlayTipAnim = false

			if not self.bindData.tipAnim then
				return
			end

			gClientUtils.ResetAnimation(self.bindData.tipAnim, self.tipCloseAnimName)
		end, self.tipCloseAnimTime):Start()
	end, 2):Start()
end

function M:UpdateSliderValue()
	local handlePos = self.bindData.handleRect.localPosition
	local normalizedPos = (handlePos.x + self.bgHalfWidth) / self.bgWidth
	self.bindData.slider.value = Mathf.Clamp01(normalizedPos)
end

function M:UpdateProgress()
	local handleCenterX = self.bindData.handleRect.localPosition.x
	local locatePos = self.bindData.locateRect.localPosition
	local locateWidth = self.bindData.locateRect.rect.width * self.bindData.locateRect.localScale.x
	local locateLeft = locatePos.x - locateWidth / 2
	local locateRight = locatePos.x + locateWidth / 2

	if locateLeft <= handleCenterX and handleCenterX <= locateRight then
		if self.hasPlayedHintAnim then
			self.hasPlayedHintAnim = false
		end

		local addDelta = self.addValue or 5
		local addValue = addDelta * Time.deltaTime
		rightSecond = rightSecond + Time.deltaTime
		self.bindData.progress.value = math.min(100, self:RoundToTwoDecimals(self.bindData.progress.value + addValue))

		if self.bindData.progress.value >= 100 then
			self:GameEnd()
		end
	elseif not self.hasPlayedHintAnim and not self.isPlayHintAnim then
		self.bindData.flashActive = true
		self.hasPlayedHintAnim = true
		self.isPlayHintAnim = true

		Timer.New(function ()
			self.bindData.flashActive = false
			self.isPlayHintAnim = false
		end, 1):Start()
	end
end

function M:RoundToTwoDecimals(num)
	return math.floor(num * 100 + 0.5) / 100
end

function M:OnBeginDrag()
	if not self.canInput or gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.isDragging = true

	if not self.gamepadMode then
		self.lastInputPosition = Input.mousePosition
		self.lastMoveSpeed = 0
	end
end

function M:OnDrag()
	if not self.canInput or gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	local curInputPosition = Input.mousePosition
	local curInputUIPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, curInputPosition)
	local lastInputUIPos = gCS.LuaUtils.ScreenPointUI(self.bindData.rootRect, self.lastInputPosition)
	local delta = curInputUIPos - lastInputUIPos
	local deltaLength = math.sqrt(delta.x * delta.x + delta.y * delta.y)
	self.lastMoveSpeed = deltaLength / Time.deltaTime
	self.lastInputPosition = curInputPosition

	if self.simulator then
		if not self.cameraHeight then
			self.cameraHeight = math.abs(self.camera.transform.position.y - self.simulator.transform.position.y)
		end

		local mouseX = curInputPosition.x
		local mouseY = curInputPosition.y
		local screenSpace = Vector3.New(mouseX, mouseY, self.cameraHeight)
		local cursorWorldPos = self.camera:ScreenToWorldPoint(screenSpace)
		local validTargetPos = gCS.SimulatorGameUtils.GetValidFitterPosition(self.simulator.gameObject, cursorWorldPos)
		self.simulator.transform.position = Vector3.Lerp(self.simulator.transform.position, validTargetPos, self.followSmoothness * Time.deltaTime)
		local fitterRot = gCS.SimulatorGameUtils.GetFitRotationAngle(self.simulator.gameObject, self.simulator.transform.position)
		self.simulator.transform.rotation = Quaternion.Lerp(self.simulator.transform.rotation, fitterRot, 8 * Time.deltaTime)
	end
end

function M:OnRightStickControl(context)
	if not self.canInput then
		return
	end

	local value = context:ReadValueVector2()

	if context.started or context.performed then
		self.needUpdateJoyStick = true
		self.rightStickCurVector = value
	end

	if context.canceled then
		self.needUpdateJoyStick = false
		self.rightStickCurVector = nil
		self.lastStickValue = Vector2.zero
	end
end

function M:OnRightStickShakeControl(context)
	if not self.canInput then
		return
	end

	if context.started or context.performed then
		self.allowShake = true
	end

	if context.canceled then
		self.allowShake = false
	end
end

function M:OnEndDrag()
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self.isDragging = false
	self.lastMoveSpeed = 0

	if self.canStartCountAnim then
		self.lastEndDragTime = Time.time
	end
end

function M:GetFormatCountDownTime(time)
	local rawMin = time <= 0 and 0 or math.floor(time / 60)
	local rawSec = 0
	local rawMs = 0

	if self.showMillisecond then
		local sec = time <= 0 and 0 or (time - rawMin * 60) % 60
		rawSec = math.floor(sec)
		rawMs = (sec - rawSec) * 1000

		return gString.Format("%02d:%02d.%03d", rawMin, rawSec, rawMs), rawMin, rawSec, rawMs
	else
		if time <= 0 then
			rawSec = 0
		else
			rawSec = math.floor((time - rawMin * 60) % 60)
		end

		return gString.Format("%02d:%02d", rawMin, rawSec), rawMin, rawSec
	end
end
