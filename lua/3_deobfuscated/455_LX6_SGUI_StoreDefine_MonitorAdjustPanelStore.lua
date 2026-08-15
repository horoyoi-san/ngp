C_MonitorAdjustPanelStore = DefClass("C_MonitorAdjustPanelStore", C_MonitorAdjustPanelStore, C_StoreGroup)
GroupName2Class.MonitorAdjustPanelStore = C_MonitorAdjustPanelStore
local M = C_MonitorAdjustPanelStore
local AtmosphereManager = LX6.Manager.AtmosphereManager
local ImageConfig = LTConfig.SguiImageConfig
local ScrollUV = LX6.Share.MonitorScrollUV
local MonitorConfig = {
	Distort = "_DistortGlobalIntensity",
	AnimName = "S_vx_MonitorAdjustPanel_feedback_open",
	tarLine = 0,
	MainTex = "_MainTex",
	checkLimit = 0.08,
	tarNoise = 0
}
local leftDeltaPos, rightDeltaPos, deltaNum = nil

function M:ctor()
	self.msgEvents = {}
end

function M:OnAwake()
	self.moveVector = Vector2.New(0, 1)
	self.leftMoveVector = Vector2.New(0, 1)
	self.rightMoveVector = Vector2.New(0, 1)
	self.isWin = false
	self.leftCurZ = 0
	self.rightCurZ = 0
	self.leftDir = true
	self.rightDir = true
	self.leftTouchId = nil
	self.rightTouchId = nil
	self.isLeftSuccess = false
	self.isRightSuccess = false
	self.leftShowFeedback = false
	self.rightShowFeedback = false
	self.isLerping = false
	self.playWinSound = false
	self.scrollUV = self.bindData.video.gameObject:GetComponent(typeof(ScrollUV))
	self.leftSuccess = 50
	self.rightSuccess = 50
	self.bindData.feedBack = 1
	self.bindData.warning = 2
	self.padLeftRotate = false
	self.padRightRotate = false
	self.SMOOTH_TIME = 0.4
	self.leftSmoothStartTime = 0
	self.leftSmoothStartVector = Vector2.New(0, 0)
	self.leftSmoothEndVector = Vector2.New(0, 0)
	self.rightSmoothStartTime = 0
	self.rightSmoothStartVector = Vector2.New(0, 0)
	self.rightSmoothEndVector = Vector2.New(0, 0)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice()
	self.msgEvents = {}

	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterEvents()

	if JoystickMgr.Instance.isSGUI then
		gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(false)
	else
		gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(false)
	end
end

function M:OnDestroy()
	self.loadTexOp = gResourceManager:UnloadAssetLoadOp(self.loadTexOp)
end

function M:OnShow(panelId, data)
	if data then
		for i, v in pairs(data) do
			if data[i] then
				self[i] = data[i]
			end
		end
	end

	if self.smoothTime then
		self.SMOOTH_TIME = self.smoothTime
	else
		self.SMOOTH_TIME = 0.4
	end

	if self.isVideo then
		if self.vId ~= 0 and self.vId and self.vId > 0 then
			self.bindData.CCUIPlayer:Init(1)
			self.bindData.CCUIPlayer:PlayVideo(self.vId, true, nil)
		end
	elseif self.vId ~= 0 then
		local config = ImageConfig.GetConfig(self.vId)

		if config then
			local path = config.ImgPath
			self.loadTexOp = gResourceManager:LoadAssetWithCallBack(path, typeof(UnityEngine.Texture), function (loadOp)
				local tex = loadOp.asset
				self.bindData.video.texture = tex
			end)
		else
			print_error("没找到这个背景图的id")
		end
	end

	self.curOrg1 = self.org1
	self.scrollUV.scrollSpeed = self.org2
	self.scrollUV.frequency = self.frequency
	self.bindData.warning = 2

	self:SetLeftShaderValue(self.org1)
end

function M:OnStart()
	self.leftValue = 0
	self.rightValue = 0
	self.totalValue = 0
end

function M:RegisterEvents()
	self.bindData.BtnLControl.luaBeginDrag = self:CreateAction("OnLeftBeginDrag")
	self.bindData.BtnLControl.luaDrag = self:CreateAction("OnLeftDrag")
	self.bindData.BtnLControl.luaEndDrag = self:CreateAction("OnLeftEndDrag")
	self.bindData.BtnRControl.luaBeginDrag = self:CreateAction("OnRightBeginDrag")
	self.bindData.BtnRControl.luaDrag = self:CreateAction("OnRightDrag")
	self.bindData.BtnRControl.luaEndDrag = self:CreateAction("OnRightEndDrag")
	self.winHandler = self:CreateAction("OnWin")
	self.bindData.closeButton.luaClick = self:CreateAction("ClickClose")
	self.bindData.leftNavRespond.luaGamePadInputChanged = self:CreateAction("OnLeftRotation")
	self.bindData.rightNavRespond.luaGamePadInputChanged = self:CreateAction("OnRightRotation")
end

local curSecond = 0
local totalSecond = 0

function M:OnUpdate()
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	self.bindData.gameTime = tostring(gTimeUtils:FormatTimeHMS(gameTime))
	self.totalValue = Mathf.Floor(self.totalValue)
	self.bindData.speedText = tostring(self.totalValue)
	curSecond = curSecond + Time.deltaTime

	if curSecond >= 1 then
		totalSecond = totalSecond + 1
		self.bindData.recordText = tostring(gTimeUtils:FormatTimeHMS(totalSecond))
		curSecond = 0
	end

	if self.leftUpdateSelect or self.rightUpdateSelect then
		self:UpdateSmoothMoveVector()

		if self.padRightRotate then
			rightDeltaPos = Vector3.New(self.rightMoveVector.x, self.rightMoveVector.y, 0)
			rightDeltaPos = Vector3.Normalize(rightDeltaPos)

			self:RefreshRightPoint(true)
		end

		if self.padLeftRotate then
			leftDeltaPos = Vector3.New(self.leftMoveVector.x, self.leftMoveVector.y, 0)
			leftDeltaPos = Vector3.Normalize(leftDeltaPos)

			self:RefreshLeftPoint(true)
		end
	end

	if not self.isWin then
		self:CheckWin()
	end
end

function M:ClickClose()
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	if JoystickMgr.Instance.isSGUI then
		gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(true)
	else
		gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(true)
	end

	gPanelManager:Close(gPanelId.S_MONITOR_ADJUST_PANEL)
end

function M:OnWin()
	self.bindData.feedBack = 0

	self:PlaySound()
	self.bindData.animComp:Play(MonitorConfig.AnimName)

	self.bindData.warning = 0

	if not self.playWinSound then
		gSoundMgr:PlaySoundByTid(15000089)

		self.playWinSound = true
	end

	gLuaTimeMgrUtils.Delay(function ()
		if JoystickMgr.Instance.isSGUI then
			gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(true)
		else
			gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(true)
		end

		gPanelManager:Close(gPanelId.S_MONITOR_ADJUST_PANEL)

		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

		gSpoonClientMgr:ReleaseContextEvent(self.entityInstanceId, gSpoonEventType.OnReceiveSignal, {
			signalKey = self.signalName,
			entityInstanceId = self.entityInstanceId
		})
	end, 3)
end

function M:GetPointerUIPos()
	return gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, UnityEngine.Input.mousePosition)
end

function M:OnLeftBeginDrag()
	return
end

function M:OnLeftDrag()
	if self.isWin then
		return
	end

	leftDeltaPos = self:GetPointerUIPos() - self.bindData.BtnLControl.localPosition
	leftDeltaPos = Vector3.Normalize(leftDeltaPos)

	self:RefreshLeftPoint(false)
	self:CheckWin()
end

function M:OnLeftEndDrag()
	self.leftTouchId = nil
	self.leftLastAngle = nil
end

function M:OnRightBeginDrag()
	return
end

function M:OnRightDrag()
	if self.isWin then
		return
	end

	rightDeltaPos = self:GetPointerUIPos() - self.bindData.BtnRControl.localPosition
	rightDeltaPos = Vector3.Normalize(rightDeltaPos)

	self:RefreshRightPoint(false)
	self:CheckWin()
end

function M:OnRightEndDrag()
	self.rightTouchId = nil
	self.rightLastAngle = nil
end

function M:RefreshLeftPoint(mobile)
	if self.isWin then
		return
	end

	self.leftCurAngle = self.Angle(Vector3.New(0, 1, 0), leftDeltaPos)

	if mobile then
		if self.leftIsStart == true or self.leftIsStart == nil then
			self.leftStartAngle = self.bindData.BtnLControl.gameObject:GetLocalEulerAnglesZ()
			self.leftDeltaAngle = self.leftCurAngle
			self.leftIsStart = false
		end

		self.bindData.BtnLControl.gameObject:SetLocalEulerAngles(Vector3.New(0, 0, self.leftStartAngle + self.leftCurAngle - self.leftDeltaAngle))
	end

	if not self.leftLastAngle then
		self.leftLastAngle = self.leftCurAngle

		return
	end

	deltaNum = self.leftCurAngle - self.leftLastAngle

	if deltaNum > 180 then
		deltaNum = deltaNum - 360
	end

	if deltaNum < -180 then
		deltaNum = deltaNum + 360
	end

	if self.leftDir then
		deltaNum = -deltaNum
	end

	if deltaNum == 0 then
		return
	end

	deltaNum = deltaNum * self.v1
	local curVL = self.bindData.video.material:GetFloat(MonitorConfig.Distort)
	curVL = curVL + deltaNum

	if self.maxOrg1 < curVL then
		curVL = self.maxOrg1
		self.leftDir = not self.leftDir
	end

	if curVL < 0 then
		curVL = 0
		self.leftDir = not self.leftDir
	end

	self:SetLeftShaderValue(curVL)

	self.curOrg1 = curVL
	self.leftLastAngle = self.leftCurAngle

	self:UpdateWarningText()
end

function M:UpdateLeftValue(value)
	self.leftValue = self.leftValue + value

	if self.leftValue < 0 then
		self.leftValue = 0
	elseif self:CheckLeftSuccess() or self.leftValue >= 50 then
		self.leftValue = 50
	end
end

function M:UpdateRightValue(value)
	self.rightValue = self.rightValue + value

	if self.rightValue < 0 then
		self.rightValue = 0
	elseif self:CheckRightSuccess() or self.rightValue >= 50 then
		self.rightValue = 50
	end
end

function M:RefreshRightPoint(mobile)
	if self.isWin then
		return
	end

	self.rightCurAngle = self.Angle(Vector3.New(0, 1, 0), rightDeltaPos)

	if mobile then
		if self.rightIsStart == true or self.rightIsStart == nil then
			self.rightStartAngle = self.bindData.BtnRControl.gameObject:GetLocalEulerAnglesZ()
			self.rightDeltaAngle = self.rightCurAngle
			self.rightIsStart = false
		end

		self.bindData.BtnRControl.gameObject:SetLocalEulerAngles(Vector3.New(0, 0, self.rightStartAngle + self.rightCurAngle - self.rightDeltaAngle))
	end

	if not self.rightLastAngle then
		self.rightLastAngle = self.rightCurAngle

		return
	end

	deltaNum = self.rightCurAngle - self.rightLastAngle

	if deltaNum > 180 then
		deltaNum = deltaNum - 360
	end

	if deltaNum < -180 then
		deltaNum = deltaNum + 360
	end

	if self.rightDir then
		deltaNum = -deltaNum
	end

	if deltaNum == 0 then
		return
	end

	deltaNum = deltaNum * self.v2
	self.scrollUV.scrollSpeed = self.scrollUV.scrollSpeed + deltaNum

	if self.maxOrg2 < self.scrollUV.scrollSpeed then
		self.scrollUV.scrollSpeed = self.maxOrg2
		self.rightDir = not self.rightDir
	end

	if self.scrollUV.scrollSpeed < 0 then
		self.scrollUV.scrollSpeed = 0
		self.rightDir = not self.rightDir
	end

	self.rightLastAngle = self.rightCurAngle

	self:UpdateWarningText()
end

function M:CheckWin()
	if not MonitorConfig.tarLine or not self.curOrg1 or not MonitorConfig.tarNoise or not self.scrollUV.scrollSpeed then
		return false
	end

	if self:CheckLeftSuccess() and self:CheckRightSuccess() then
		self.isWin = true
	end

	if self.isWin then
		self:OnWin()
	end
end

function M:UpdateTotalValue()
	self.totalValue = self.leftValue + self.rightValue

	if self.totalValue < 0 then
		self.totalValue = 0
	elseif self.totalValue >= 100 then
		self.totalValue = 100
	end
end

function M:CheckLeftSuccess()
	local id = self.bindData.BtnLControl.content.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if math.abs(MonitorConfig.tarLine - self.curOrg1) <= self.target1 then
		if not self.isLeftSuccess then
			gSoundMgr:PlaySoundByTid(70850168)
		end

		self.isLeftSuccess = true
		store.c1 = 1

		return true
	else
		self.isLeftSuccess = false
		store.c1 = 0

		return false
	end
end

function M:CheckRightSuccess()
	local id = self.bindData.BtnRControl.content.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if math.abs(self.scrollUV.scrollSpeed) <= self.target2 then
		if not self.isRightSuccess then
			gSoundMgr:PlaySoundByTid(70850168)
		end

		self.isRightSuccess = true
		self.scrollUV.isRightSuccess = true
		store.c1 = 1

		return true
	else
		self.isRightSuccess = false
		self.scrollUV.isRightSuccess = false
		store.c1 = 0

		return false
	end
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:UpdateWarningText()
	if self:CheckLeftSuccess() and self:CheckRightSuccess() or self.totalValue == 100 then
		self.bindData.warning = 0
	elseif self:CheckLeftSuccess() then
		self.bindData.warning = 1

		if not self.leftShowFeedback then
			self.bindData.feedBack = 2

			self:PlaySound()
			self.bindData.animComp:Play(MonitorConfig.AnimName)
			gLuaTimeMgrUtils.Delay(function ()
				self.bindData.feedBack = 1
			end, 1)

			self.leftShowFeedback = true
		end
	elseif self:CheckRightSuccess() then
		self.bindData.warning = 1

		if not self.rightShowFeedback then
			self.bindData.feedBack = 2

			self:PlaySound()
			self.bindData.animComp:Play(MonitorConfig.AnimName)
			gLuaTimeMgrUtils.Delay(function ()
				self.bindData.feedBack = 1
			end, 1)

			self.rightShowFeedback = true
		end
	end

	if not self:CheckLeftSuccess() then
		self.leftShowFeedback = false
	end

	if not self:CheckRightSuccess() then
		self.rightShowFeedback = false
	end

	if not self:CheckLeftSuccess() and not self:CheckRightSuccess() then
		self.bindData.warning = 2
	end
end

function M:SetLeftShaderValue(line)
	if self.maxOrg1 < line then
		line = self.maxOrg1
	end

	if line < 0 then
		line = 0
	end

	self.bindData.video.material:SetFloat(MonitorConfig.Distort, line)
end

function M.Angle(from, to)
	return Vector3.Angle(from, to) * Mathf.Sign(Vector3.Dot(Vector3.Cross(from, to), Vector3.New(0, 0, 1)))
end

function M:OnLeftRotation(context)
	if context.started then
		self.padLeftRotate = true
		self.leftIsStart = true
	end

	if context.canceled then
		self.padLeftRotate = false
		self.leftLastAngle = nil

		self:ClearSmoothMove(true)
	end

	if context.performed then
		if self.isWin then
			return
		end

		self:UpdateSmoothMoveVector()

		local v2 = context:ReadValueVector2()

		self:SetSmoothMove(v2, true)
	end
end

function M:OnRightRotation(context)
	if context.started then
		self.padRightRotate = true
		self.rightIsStart = true
	end

	if context.canceled then
		self.padRightRotate = false
		self.rightLastAngle = nil

		self:ClearSmoothMove(false)
	end

	if context.performed then
		if self.isWin then
			return
		end

		self:UpdateSmoothMoveVector()

		local v2 = context:ReadValueVector2()

		self:SetSmoothMove(v2, false)
	end
end

function M:PlaySound()
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
end

function M:OnActiveDeviceChange(device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse < device
end

function M:SetSmoothMove(moveVector, left)
	if left then
		self.leftUpdateSelect = true
		self.leftSmoothStartTime = Time.unscaledTime
		self.leftSmoothStartVector.x = self.leftMoveVector.x
		self.leftSmoothStartVector.y = self.leftMoveVector.y
		self.leftSmoothEndVector.x = moveVector.x
		self.leftSmoothEndVector.y = moveVector.y
	else
		self.rightUpdateSelect = true
		self.rightSmoothStartTime = Time.unscaledTime
		self.rightSmoothStartVector.x = self.rightMoveVector.x
		self.rightSmoothStartVector.y = self.rightMoveVector.y
		self.rightSmoothEndVector.x = moveVector.x
		self.rightSmoothEndVector.y = moveVector.y
	end
end

function M:UpdateSmoothMoveVector()
	if not self.gamepadMode then
		return
	end

	if self.leftUpdateSelect then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.leftSmoothStartVector.x, self.leftSmoothStartVector.y, 0, self.leftSmoothEndVector.x, self.leftSmoothEndVector.y, 0, (Time.unscaledTime - self.leftSmoothStartTime) / self.SMOOTH_TIME)
		self.leftMoveVector.x = x
		self.leftMoveVector.y = y

		if self.SMOOTH_TIME < Time.unscaledTime - self.leftSmoothStartTime then
			self:ClearSmoothMove(true)
		end
	end

	if self.rightUpdateSelect then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.rightSmoothStartVector.x, self.rightSmoothStartVector.y, 0, self.rightSmoothEndVector.x, self.rightSmoothEndVector.y, 0, (Time.unscaledTime - self.rightSmoothStartTime) / self.SMOOTH_TIME)
		self.rightMoveVector.x = x
		self.rightMoveVector.y = y

		if self.SMOOTH_TIME < Time.unscaledTime - self.rightSmoothStartTime then
			self:ClearSmoothMove(false)
		end
	end
end

function M:ClearSmoothMove(left)
	if left then
		self.leftUpdateSelect = false
	else
		self.rightUpdateSelect = false
	end
end
