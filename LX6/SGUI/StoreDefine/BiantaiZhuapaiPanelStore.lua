-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BiantaiZhuapaiPanelStore.lua
-- Decompiled from: 01676_BiantaiZhuapaiPanelStore.lua_b7b11a50d2e4.luajit

C_BiantaiZhuapaiPanelStore = DefClass("C_BiantaiZhuapaiPanelStore", C_BiantaiZhuapaiPanelStore, C_StoreGroup)
GroupName2Class.BiantaiZhuapaiPanelStore = C_BiantaiZhuapaiPanelStore
local M = C_BiantaiZhuapaiPanelStore
local PoiGameConfig = LTConfig.PoiGameConfig
local MainCamera = gCS.CameraDataMgr.MainCamera
local PhotoUtils = LX6.Utils.PhotoUtils
local Screen = UnityEngine.Screen
local MessageConfig = LTConfig.MessageConfig

M.ctor = function(self)
	self.preIsZoomIn = false
	self.OnPhotoTakenHandler = self.CreateAction(self, self.OnPhotoTaken)
	self.spoonLoadGameObjectHandler = self.CreateAction(self, self.SpoonLoadGameObject)
	self.msgEvents = {
		[gEventConstants.PHOTO_TEXTURE_GENERATED] = self.OnPhotoTakenHandler,
		[gEventConstants.SPOON_LOAD_GAME_OBJECT] = self.spoonLoadGameObjectHandler
	}
	self.isRotatingCamera = false
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.focusBtn.luaPress = self.CreateAction(self, self.OnFocusBtnPress)
	self.bindData.focusBtn.luaRelease = self.CreateAction(self, self.OnFocusBtnRelease)
	self.bindData.takingPhotoBtn.luaBeginLongPress = self.CreateAction(self, self.OnFocusBtnPress)
	self.bindData.takingPhotoBtn.luaEndLongPress = self.CreateAction(self, self.OnTakingPhotoBtnPressEnd)
	self.bindData.takingPhotoBtn.luaClick = self.CreateAction(self, self.OnTakingPhotoBtnClick)
	self.bindData.enterBtn.luaClick = self.CreateAction(self, self.OnTakingPhotoBtnClick)
	self.bindData.customNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRotateCameraInput")
	self.bindData.joyStick.luaValueChanged = self.CreateAction(self, self.OnJoyStickValueChanged)
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self:InitConfig()
	self:InitBigPhotoSize()

	self.createdTargets = {}
	self.leftFilm = self.maxFilmCount
	self.curScore = 0
	self.bindData.filmNum = self.leftFilm .. "/" .. self.maxFilmCount
	self.bindData.curScore = self.curScore

	gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonCamera(true, false)
	gCS.CameraDataMgr.cinemachineManager:SetFov(self.maxFov, 0, 0, false)

	if data == nil then
		if data.cameraX ~= nil or data.cameraY ~= nil then
			print_error("Please add cameraX and cameraY in the CheckShow node to represent the current camera angle.")
		else
			gCS.CameraDataMgr.cinemachineManager:SetLocalXRange(data.cameraX + self.cameraMinX, data.cameraX + self.cameraMaxX)
			gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(data.cameraY + self.cameraMinY, data.cameraY + self.cameraMaxY)
		end
	end

	gCS.MyPlayerManager.SwitchCameraBlock(false)

	self.isPCPlatform = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive()

	if self.isPCPlatform then
		self.bindData.gamePadTips.gameObject:SetActive(true)

		self.bindData.takingPhotoBtn.renderOpacity = 0
	else
		self.bindData.gamePadTips.gameObject:SetActive(false)
	end

	self.bindData.joyStick.renderOpacity = 0
	self.bindData.focusBtn.renderOpacity = 0
	self.isRotatingCamera = false
	self.rotateParam = nil
	self.lastGo = nil
	self.isFocus = false
	self.isAdsorbent = false
	self.isGamePadAdsorbent = false
	self.gamePadHitGoInfo = nil
	self.increaseRate = 5
end

M.OnClose = function(self)
	gCS.MyPlayerManager.SwitchCameraBlock(true)
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5)
	gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonCamera(false, false)
	gMessageManager:SendMessage(gEventConstants.BIANTAI_PANEL_CLOSE, {
		score = self.curScore,
		leftFilm = self.leftFilm
	})

	self.createdTargets = nil
	self.isRotatingCamera = false
	self.rotateParam = nil
end

M.OnLateUpdate = function(self)
	if self.isFocus ~= false then
		self.isAdsorbent = false
	else
		self.CameraAdsorbent(self)
	end
end

M.CameraAdsorbent = function(self)
	if not self.isGamePadMode and self.isPCPlatform then
		return
	end

	local isHit, hitGoInfo = self:CheckIsAdsorbent()
	local gamePadHitGo = self.gamePadHitGoInfo and self.gamePadHitGoInfo.go or nil
	local hitGo = hitGoInfo and hitGoInfo.go or nil

	if (self.isGamePadAdsorbent ~= false or gamePadHitGo == hitGo) and self.isPCPlatform and self.isGamePadMode then
		return
	end

	if isHit then
		self.CrosshairAdsorbent(self, hitGoInfo.go, hitGoInfo.speed)
	else
		self.isAdsorbent = false
	end
end

M.OnUpdate = function(self)
	self:CalBiantaiSpeed()
	self:OnRotateCameraUpdate()

	self.isGamePadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()

	self:AddGameObjectExistTime()

	local isHit, _ = self:CheckUnitInPhoto()

	if self.isFocus ~= false then
		self.bindData.blurFrameState = isHit and 1 or 0
	else
		self.bindData.photoFocusState = isHit and 1 or 0
	end
end

M.CrosshairAdsorbent = function(self, hitGo, speed)
	speed = speed or 0
	local adsorbentFactor = self:CalAdsorbentCoefficient(hitGo, speed)
	local weighRotateSpeedHandle = adsorbentFactor * self.rotateSpeedHandle
	local weighMinXOffsetHandle = adsorbentFactor * self.minXOffsetHandle
	local weighMaxXOffsetHandle = adsorbentFactor * self.maxXOffsetHandle
	local weighMinYOffsetHandle = adsorbentFactor * self.minYOffsetHandle
	local weightMaxYOffsetHandle = adsorbentFactor * self.maxYOffsetHandle
	local weighRotateSpeed = adsorbentFactor * self.rotateSpeed
	local weighMinXOffset = adsorbentFactor * self.minXOffset
	local weighMaxXOffset = adsorbentFactor * self.maxXOffset
	local weighMinYOffset = adsorbentFactor * self.minYOffset
	local weightMaxYOffset = adsorbentFactor * self.maxYOffset

	if self.isGamePadMode then
		self.CrosshairAdsorbentHelper(self, hitGo, weighRotateSpeedHandle, weighMinXOffsetHandle, weighMaxXOffsetHandle, weighMinYOffsetHandle, weightMaxYOffsetHandle)
	else
		self.CrosshairAdsorbentHelper(self, hitGo, weighRotateSpeed, weighMinXOffset, weighMaxXOffset, weighMinYOffset, weightMaxYOffset)
	end
end

M.CalAdsorbentCoefficient = function(self, hitGo, speed)
	local vehicleVelocity = gCS.LuaUtils.GetCurVehicleAngularVelocity()
	local cameraPos = MainCamera.transform.position
	local hitPos = hitGo.transform.position
	local distance = Mathf.Clamp(Vector3.Distance(cameraPos, hitPos), self.minDistance, self.standardDistance)
	local adsorbentFactor = Mathf.Clamp(vehicleVelocity / self.angleSpeedFactor, 0, self.maxAngleSpeedFactor) + Mathf.Clamp(speed / self.speedFactor, 0, self.maxSpeedFactor) + self.standardDistance / distance

	return adsorbentFactor
end

M.CrosshairAdsorbentHelper = function(self, hitGo, rotateSpeed, minXOffset, maxXOffset, minYOffset, maxYOffset)
	if not self.isAdsorbent or hitGo == self.lastGo then
		self.isAdsorbent = gCS.LuaUtils.BiantaiCrosshairAdsorbent(hitGo, rotateSpeed, minXOffset, maxXOffset, minYOffset, maxYOffset)
	else
		self.isAdsorbent = gCS.LuaUtils.BiantaiCrosshairAdsorbent(hitGo, rotateSpeed, self.increaseRate * rotateSpeed, minXOffset * self.increaseRate, minYOffset * self.increaseRate, maxYOffset * self.increaseRate)
	end
end

M.OnExitBtnClick = function(self)
	gDisplayMessageMgr:ShowMessage(MessageConfig.ChallengeGiveUp, self.OnExit)
end

M.OnExit = function()
	gPanelManager:Close(gPanelId.S_BIANTAI_ZHUAPAI_PANEL)
end

M.OnJoyStickValueChanged = function(self, x, y, intensity)
	local rotateParam = Vector2.New(x, y) * intensity

	gCameraUtils:DoRotateCameraByGamePad(5, rotateParam.x, rotateParam.y)
end

M.OnFocusBtnPress = function(self)
	if self.isGamePadMode then
		local isHit, hitGo = self.CheckIsAdsorbent(self)
		self.isGamePadAdsorbent = isHit
		self.gamePadHitGoInfo = hitGo
	end

	self.isFocus = true
	self.bindData.blurFrameState = 0

	self.bindData.rootComponent.anim:Stop()
	self.bindData.rootComponent.anim:Play(self.focusAnim)
	gCS.CameraDataMgr.cinemachineManager:SetFov(self.minFov, self.zoomSpeed, 0, true)
end

M.OnFocusBtnRelease = function(self)
	self.isGamePadAdsorbent = false
	self.isFocus = false
	self.bindData.photoFocusState = 0

	self.bindData.rootComponent.anim:Stop()
	self.bindData.rootComponent.anim:Play(self.focusOutAnim)
	gCS.CameraDataMgr.cinemachineManager:SetFov(self.maxFov, self.zoomSpeed, 0, true)
end

M.OnPhotoTaken = function(self)
	self.ShowDialogPanelIsShow(self)

	self.bindData.rootComponent.renderOpacity = 1
	self.bindData.bigPhoto = PhotoUtils.writeCameraImage
	self.bindData.smallPhoto = PhotoUtils.writeCameraImage
	self.bindData.filmNum = self.leftFilm .. "/" .. self.maxFilmCount
	self.bindData.curScore = self.curScore
end

M.OnTakingPhotoBtnPressEnd = function(self)
	self.OnTakingPhotoBtnClick(self)
	self.OnFocusBtnRelease(self)
end

M.HideDialogPanelIsShow = function(self)
	gPanelManager:SetActiveById(gPanelId.S_DIALOG_10N_PANEL, false)
end

M.ShowDialogPanelIsShow = function(self)
	gPanelManager:SetActiveById(gPanelId.S_DIALOG_10N_PANEL, true)
end

M.OnTakingPhotoBtnClick = function(self)
	self.FilmCost(self)

	self.lastGo = nil
	self.bindData.rootComponent.renderOpacity = 0

	self.HideDialogPanelIsShow(self)

	if self.pauseUUid then
		local uuid = gCS.PauseManager.Instance:GetUuidMultiKey(self.pauseUUid)

		gCS.PauseManager.Instance:RemoveGlobalPause(uuid)

		self.pauseUUid = nil
	end

	PhotoUtils.TakePhoto()

	local isHit, curTarget = self.CheckUnitInPhoto(self)

	if isHit then
		self.AddScore(self, curTarget)
		array.remove(self.createdTargets, curTarget)
	else
		self.RefreshScore(self, 0, 0, 0)
	end
end

M.OnRotateCameraInput = function(self, context)
	if context.started then
		self.isRotatingCamera = true
		self.rotateParam = context.ReadValueVector2(context)
	end

	if context.performed then
		self.rotateParam = context.ReadValueVector2(context)
	end

	if context.canceled then
		self.isRotatingCamera = false
		self.rotateParam = nil

		gCameraUtils:DoRotateCameraByGamePad(5, 0, 0)
	end
end

M.OnRotateCameraUpdate = function(self)
	if self.isRotatingCamera then
		gCameraUtils:DoRotateCameraByGamePad(5, self.rotateParam.x, self.rotateParam.y)
	end
end

M.OcclusionMonitoring = function(self, hitGo)
	if gCS.LuaUtils.BiantaiOcclusionMonitoring(hitGo.go, self.detectionMaxDistance) then
		return true, hitGo
	else
		return false
	end
end

M.CheckUnitInPhoto = function(self)
	local hitGO = gCS.LuaUtils.BiantaiCheckUnitInPhoto(self.detectionMaxDistance, self.boxCastScale)

	if gCS.LuaUtils.IsNull(hitGO) then
		return false
	end

	for i = #self.createdTargets, 1, -1 do
		if self.createdTargets[i].go ~= hitGO then
			if hitGO == self.lastGo then
				if self.isGamePadMode then
					gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
				end

				self.lastGo = hitGO
			end

			return self.OcclusionMonitoring(self, self.createdTargets[i])
		end
	end

	return false
end

M.CheckIsAdsorbent = function(self)
	local hitGO = gCS.LuaUtils.BiantaiCheckUnitInPhoto(self.detectionMaxDistance, self.adsorbentBoxCastScale)

	if gCS.LuaUtils.IsNull(hitGO) then
		return false
	end

	for i = #self.createdTargets, 1, -1 do
		if self.createdTargets[i].go ~= hitGO then
			return self.OcclusionMonitoring(self, self.createdTargets[i])
		end
	end

	return false
end

M.AddScore = function(self, createdTarget)
	local totalScore = createdTarget.baseScore

	if MainCamera.fieldOfView < self.excellentScoreFovRequire then
		totalScore = totalScore + createdTarget.zoomScore
	end

	if createdTarget.startTime <= 0 and createdTarget.endTime <= 0 and createdTarget.startTime >= createdTarget.existTime and createdTarget.existTime >= createdTarget.endTime then
		totalScore = totalScore + createdTarget.excellentScore
	end

	self:RefreshScore(totalScore, createdTarget.scoreColor, createdTarget.baseScore >= totalScore and self.qualityColor.perfect or self.qualityColor.normal)

	self.curScore = self.curScore + totalScore
end

M.RefreshScore = function(self, score, scoreColor, qualityColor)
	self.bindData.score = score
	self.bindData.scoreColor = scoreColor
	self.bindData.qualityColor = qualityColor

	self.bindData.photoWidget.anim:Stop()
	self.bindData.photoWidget.anim:Play(self.photoAnimClip[qualityColor])
end

M.SpoonLoadGameObject = function(self, _, go)
	if gPanelManager:IsPanelShowing(gPanelId.S_BIANTAI_ZHUAPAI_PANEL) then
		self.OnTargetCreated(self, go)
	end
end

M.OnTargetCreated = function(self, go)
	local targetData = go.GetComponent(go, typeof("L18.SnapChallenge.SnapChallengeTargetData"))

	if not gCS.LuaUtils.IsNull(targetData) then
		local info = {
			["^\\xbe\\xa7\\xaa\\xb2"] = 0,
			["F_ezZ*="] = 0,
			go = go,
			baseScore = targetData.baseScore,
			excellentScore = targetData.excellentScore,
			scoreColor = targetData.targetColorLevel,
			disableTime = targetData.disableTime,
			zoomScore = targetData.zoomScore,
			startTime = targetData.startTime,
			endTime = targetData.endTime,
			lastPosition = go.transform.position
		}

		table.insert(self.createdTargets, info)
	end
end

M.CalBiantaiSpeed = function(self)
	for i = #self.createdTargets, 1, -1 do
		self.createdTargets[i].speed = Vector3.Distance(self.createdTargets[i].go.transform.position, self.createdTargets[i].lastPosition) / Time.deltaTime
		self.createdTargets[i].lastPosition = self.createdTargets[i].go.transform.position
	end
end

M.FilmCost = function(self)
	self.leftFilm = self.leftFilm - 1

	if self.leftFilm < 0 then
		self.bindData.takingPhotoBtn.enabled = false

		gMessageManager:SendMessage(gEventConstants.BIANTAI_FILM_USE_UP, {
			score = self.curScore
		})
	end
end

M.AddGameObjectExistTime = function(self)
	if not self.createdTargets then
		return
	end

	local removeIndexArr = {}

	for i = 1, #self.createdTargets do
		local disableTime = self.createdTargets[i].disableTime
		self.createdTargets[i].existTime = self.createdTargets[i].existTime + Time.deltaTime

		if disableTime <= 0 and disableTime >= self.createdTargets[i].existTime then
			table.insert(removeIndexArr, i)
		end
	end

	for _, removeIndex in ipairs(removeIndexArr) do
		table.remove(self.createdTargets, removeIndex)
	end
end

M.InitConfig = function(self)
	self.maxFilmCount = PoiGameConfig.Hentai_FilmCount
	self.maxFov = PoiGameConfig.Hentai_MaxFov
	self.minFov = PoiGameConfig.Hentai_MinFov or 20
	self.excellentScoreFovRequire = self.minFov * 1.1
	self.preIsZoomIn = false
	self.cameraMinX = PoiGameConfig.Hentai_CameraMinX
	self.cameraMaxX = PoiGameConfig.Hentai_CameraMaxX
	self.cameraMinY = PoiGameConfig.Hentai_CameraMinY
	self.cameraMaxY = PoiGameConfig.Hentai_CameraMaxY
	self.zoomSpeed = PoiGameConfig.Hentai_ZoomSpeed
	self.detectionMaxDistance = PoiGameConfig.Hentai_DetectionMaxDistance
	self.adsorbentBoxCastScale = PoiGameConfig.Hentai_AdsorbentBoxCastScale
	self.rotateSpeed = PoiGameConfig.Hentai_RotateSpeed_Mobile
	self.minXOffset = PoiGameConfig.Hentai_MinXOffset_Mobile
	self.maxXOffset = PoiGameConfig.Hentai_MaxXOffset_Mobile
	self.minYOffset = PoiGameConfig.Hentai_MinYOffset_Mobile / 180
	self.maxYOffset = PoiGameConfig.Hentai_MaxYOffset_Mobile / 180
	self.rotateSpeedHandle = PoiGameConfig.Hentai_RotateSpeed_Handle
	self.minXOffsetHandle = PoiGameConfig.Hentai_MinXOffset_Handle
	self.maxXOffsetHandle = PoiGameConfig.Hentai_MaxXOffset_Handle
	self.minYOffsetHandle = PoiGameConfig.Hentai_MinYOffset_Handle / 180
	self.maxYOffsetHandle = PoiGameConfig.Hentai_MaxYOffset_Handle / 180
	self.standardDistance = PoiGameConfig.StandardDistance
	self.minDistance = PoiGameConfig.MinDistance
	self.angleSpeedFactor = PoiGameConfig.AngleSpeedFactor
	self.maxAngleSpeedFactor = PoiGameConfig.MaxAngleSpeedFactor
	self.speedFactor = PoiGameConfig.SpeedFactor
	self.maxSpeedFactor = PoiGameConfig.MaxSpeedFactor
	self.timeScale = PoiGameConfig.Hentai_TimeScale
	self.timeScaleLength = PoiGameConfig.Hentai_TimeScaleLength
	self.boxCastScale = PoiGameConfig.Hentai_BoxCastScale
	self.taskTipMode = 9
	self.photoAnimClip = {
		[0] = "h/UJ\\x9f20rt\\x92\\xaa\\xa4\\xbf3\\xa0\\xe9?\\xab#\\xc68\\xa6w\\x8f%\\xadc\\x9d=ɶm\\x99\\xab",
		"\\xc1\\xfeG\\xeb\\xfd\\xf5[\\xa56W\\xedW\\xe8\\xec\\x9bS\\x84\\xd7\\xc4x\\xeb\\xeb\\xfdQ\\xae^\\xeb4P\\xd3\\xe2\\x99_\t\\xb8",
		"\\x9f\\xc5Q(:gc\\xa8/`n\\x99?\\xab\\x9e3A\\xa8\\xaf\\x8c\\x9b\\xaf\r\\x96탓9\\x82\\xe87k\t'"
	}
	self.focusAnim = "vx_S_BiantaiZhuapaiPanel_Focus"
	self.focusOutAnim = "vx_S_BiantaiZhuapaiPanel_FocusOut"
	self.qualityColor = {
		["G\\x83\\x83\\x82M"] = 1,
		["\\xc9\\xde'\\xe5"] = 2,
		["w+nH"] = 0
	}
end

M.InitBigPhotoSize = function(self)
	local screenRatio = Screen.width / Screen.height
	local bigPhotoHeight = self.bindData.bigPhotoRawImage:GetTargetHeight()
	local smallPhotoHeight = self.bindData.smallPhotoRawImage:GetTargetHeight()
	self.bindData.bigPhotoRawImage.rectTransform.sizeDelta = Vector2.New(bigPhotoHeight * screenRatio, bigPhotoHeight)
	self.bindData.smallPhotoRawImage.rectTransform.sizeDelta = Vector2.New(smallPhotoHeight * screenRatio, smallPhotoHeight)
end
