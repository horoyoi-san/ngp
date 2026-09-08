-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\MonitorAdjustPanelStore.lua
-- Decompiled from: 01054_MonitorAdjustPanelStore.lua_8e2092d009d2.luajit

C_MonitorAdjustPanelStore = DefClass("C_MonitorAdjustPanelStore", C_MonitorAdjustPanelStore, C_StoreGroup)
GroupName2Class.MonitorAdjustPanelStore = C_MonitorAdjustPanelStore
local M = C_MonitorAdjustPanelStore
local AtmosphereManager = LX6.Manager.AtmosphereManager
local ImageConfig = LTConfig.SguiImageConfig
local ScrollUV = LX6.Share.MonitorScrollUV
local MonitorConfig = {
	["\\xfd\\xd2\t6\\xe5"] = "\\xeeV\\x9f\\xf1,\\xbb1t\\xdc1.\\xe2_\\xf0\\xb9\\xad\\\\xa0p[\\xa3\\xdf",
	["\\x8a\\xbf\\xa6D?\\xf36"] = "\\xef\\x88\\xb4\\xfcP\\xb6܏N\\xdc\\xf5\\xb6\\xb3N\\xb2\\x8c%G\\xbe\\xe3'\\x9b\\x8f\\xd3^\\xbbޤN\\xdeѼ",
	["\\xcd\\xda1*\\xf4"] = 0,
	["\\xf4\\xda*!\\xe9"] = "\\x94\\x9c\\xa2d\n\\xfb+",
	["PR˾\\x8f$\\xb1\t\\xc0\\xfc"] = 0.08,
	["\\xbf\\xb0\\x85e7\\xed6"] = 0
}
local leftDeltaPos, rightDeltaPos, deltaNum = nil

M.ctor = function(self)
	self.msgEvents = {}
end

M.OnAwake = function(self)
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
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
	self.msgEvents = {}

	self:RegisterMessageEvents(self.msgEvents)
	self:RegisterEvents()

	if JoystickMgr.Instance.isSGUI then
		gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(false)
	else
		gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(false)
	end
end

M.OnDestroy = function(self)
	self.loadTexOp = gResourceManager:UnloadAssetLoadOp(self.loadTexOp)
end

M.OnShow = function(self, panelId, data)
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
		if self.vId == 0 and self.vId and self.vId <= 0 then
			self.bindData.CCUIPlayer:Init(1)
			self.bindData.CCUIPlayer:PlayVideo(self.vId, true, nil)
		end
	elseif self.vId == 0 then
		local config = ImageConfig.GetConfig(self.vId)

		if config then
			local path = config.ImgPath
			slot5 = gResourceManager
			self.loadTexOp = slot5:LoadAssetWithCallBack(path, typeof(UnityEngine.Texture), function (loadOp)
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

	self.SetLeftShaderValue(self, self.org1)
end

M.OnStart = function(self)
	self.leftValue = 0
	self.rightValue = 0
	self.totalValue = 0
end

M.RegisterEvents = function(self)
	self.bindData.BtnLControl.luaBeginDrag = self.CreateAction(self, "OnLeftBeginDrag")
	self.bindData.BtnLControl.luaDrag = self.CreateAction(self, "OnLeftDrag")
	self.bindData.BtnLControl.luaEndDrag = self.CreateAction(self, "OnLeftEndDrag")
	self.bindData.BtnRControl.luaBeginDrag = self.CreateAction(self, "OnRightBeginDrag")
	self.bindData.BtnRControl.luaDrag = self.CreateAction(self, "OnRightDrag")
	self.bindData.BtnRControl.luaEndDrag = self.CreateAction(self, "OnRightEndDrag")
	self.winHandler = self.CreateAction(self, "OnWin")
	self.bindData.closeButton.luaClick = self.CreateAction(self, "ClickClose")
	self.bindData.leftNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnLeftRotation")
	self.bindData.rightNavRespond.luaGamePadInputChanged = self.CreateAction(self, "OnRightRotation")
end

local curSecond = 0
local totalSecond = 0

M.OnUpdate = function(self)
	local gameTime = AtmosphereManager.Instance:GetGameTime()
	self.bindData.gameTime = tostring(gTimeUtils:FormatTimeHMS(gameTime))
	self.totalValue = Mathf.Floor(self.totalValue)
	self.bindData.speedText = tostring(self.totalValue)
	curSecond = curSecond + Time.deltaTime

	if curSecond > 1 then
		totalSecond = totalSecond + 1
		self.bindData.recordText = tostring(gTimeUtils:FormatTimeHMS(totalSecond))
		curSecond = 0
	end

	if self.leftUpdateSelect or self.rightUpdateSelect then
		self.UpdateSmoothMoveVector(self)

		if self.padRightRotate then
			rightDeltaPos = Vector3.New(self.rightMoveVector.x, self.rightMoveVector.y, 0)
			rightDeltaPos = Vector3.Normalize(rightDeltaPos)

			self.RefreshRightPoint(self, true)
		end

		if self.padLeftRotate then
			leftDeltaPos = Vector3.New(self.leftMoveVector.x, self.leftMoveVector.y, 0)
			leftDeltaPos = Vector3.Normalize(leftDeltaPos)

			self.RefreshLeftPoint(self, true)
		end
	end

	if not self.isWin then
		self.CheckWin(self)
	end
end

M.ClickClose = function(self)
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true

	if JoystickMgr.Instance.isSGUI then
		gLuaDataManager.guiMgr.sguiJoystick.gameObject:SetActive(true)
	else
		gLuaDataManager.guiMgr.nguiJoystick.gameObject:SetActive(true)
	end

	gPanelManager:Close(gPanelId.S_MONITOR_ADJUST_PANEL)
end

M.OnWin = function(self)
	self.bindData.closeButton:SetActive(false)

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

		gSpoonClientMgr:ReleaseContextEvent(self.entityInstanceId, L50.Spoon.SpoonRunTime.ClientGraphType.GADGET, gSpoonEventType.OnReceiveSignal, {
			signalKey = self.signalName,
			entityInstanceId = self.entityInstanceId
		})
	end, 3)
end

M.GetPointerUIPos = function(self)
	return gCS.LuaUtils.TransformScreenPointToUI(self.bindData.rootRT, UnityEngine.Input.mousePosition)
end

M.OnLeftBeginDrag = function(self)
end

M.OnLeftDrag = function(self)
	if self.isWin then
		return
	end

	leftDeltaPos = self.GetPointerUIPos(self) - self.bindData.BtnLControl.localPosition
	leftDeltaPos = Vector3.Normalize(leftDeltaPos)

	self.RefreshLeftPoint(self, false)
	self.CheckWin(self)
end

M.OnLeftEndDrag = function(self)
	self.leftTouchId = nil
	self.leftLastAngle = nil
end

M.OnRightBeginDrag = function(self)
end

M.OnRightDrag = function(self)
	if self.isWin then
		return
	end

	rightDeltaPos = self.GetPointerUIPos(self) - self.bindData.BtnRControl.localPosition
	rightDeltaPos = Vector3.Normalize(rightDeltaPos)

	self.RefreshRightPoint(self, false)
	self.CheckWin(self)
end

M.OnRightEndDrag = function(self)
	self.rightTouchId = nil
	self.rightLastAngle = nil
end

M.RefreshLeftPoint = function(self, mobile)
	if self.isWin then
		return
	end

	self.leftCurAngle = self.Angle(Vector3.New(0, 1, 0), leftDeltaPos)

	if mobile then
		if self.leftIsStart ~= true or self.leftIsStart ~= nil then
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

	if deltaNum <= 180 then
		deltaNum = deltaNum - 360
	end

	if deltaNum >= -180 then
		deltaNum = deltaNum + 360
	end

	if self.leftDir then
		deltaNum = -deltaNum
	end

	if deltaNum ~= 0 then
		return
	end

	deltaNum = deltaNum * self.v1
	local curVL = self.bindData.video.material:GetFloat(MonitorConfig.Distort)
	curVL = curVL + deltaNum

	if self.maxOrg1 >= curVL then
		curVL = self.maxOrg1
		self.leftDir = not self.leftDir
	end

	if curVL >= 0 then
		curVL = 0
		self.leftDir = not self.leftDir
	end

	self.SetLeftShaderValue(self, curVL)

	self.curOrg1 = curVL
	self.leftLastAngle = self.leftCurAngle

	self.UpdateWarningText(self)
end

M.UpdateLeftValue = function(self, value)
	self.leftValue = self.leftValue + value

	if self.leftValue >= 0 then
		self.leftValue = 0
	elseif self.CheckLeftSuccess(self) or self.leftValue > 50 then
		self.leftValue = 50
	end
end

M.UpdateRightValue = function(self, value)
	self.rightValue = self.rightValue + value

	if self.rightValue >= 0 then
		self.rightValue = 0
	elseif self.CheckRightSuccess(self) or self.rightValue > 50 then
		self.rightValue = 50
	end
end

M.RefreshRightPoint = function(self, mobile)
	if self.isWin then
		return
	end

	self.rightCurAngle = self.Angle(Vector3.New(0, 1, 0), rightDeltaPos)

	if mobile then
		if self.rightIsStart ~= true or self.rightIsStart ~= nil then
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

	if deltaNum <= 180 then
		deltaNum = deltaNum - 360
	end

	if deltaNum >= -180 then
		deltaNum = deltaNum + 360
	end

	if self.rightDir then
		deltaNum = -deltaNum
	end

	if deltaNum ~= 0 then
		return
	end

	deltaNum = deltaNum * self.v2
	self.scrollUV.scrollSpeed = self.scrollUV.scrollSpeed + deltaNum

	if self.maxOrg2 >= self.scrollUV.scrollSpeed then
		self.scrollUV.scrollSpeed = self.maxOrg2
		self.rightDir = not self.rightDir
	end

	if self.scrollUV.scrollSpeed >= 0 then
		self.scrollUV.scrollSpeed = 0
		self.rightDir = not self.rightDir
	end

	self.rightLastAngle = self.rightCurAngle

	self.UpdateWarningText(self)
end

M.CheckWin = function(self)
	if not MonitorConfig.tarLine or not self.curOrg1 or not MonitorConfig.tarNoise or not self.scrollUV.scrollSpeed then
		return false
	end

	if self.CheckLeftSuccess(self) and self.CheckRightSuccess(self) then
		self.isWin = true
	end

	if self.isWin then
		self.OnWin(self)
	end
end

M.UpdateTotalValue = function(self)
	self.totalValue = self.leftValue + self.rightValue

	if self.totalValue >= 0 then
		self.totalValue = 0
	elseif self.totalValue > 100 then
		self.totalValue = 100
	end
end

M.CheckLeftSuccess = function(self)
	local id = self.bindData.BtnLControl.content.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if math.abs(MonitorConfig.tarLine - self.curOrg1) < self.target1 then
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

M.CheckRightSuccess = function(self)
	local id = self.bindData.BtnRControl.content.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if math.abs(self.scrollUV.scrollSpeed) < self.target2 then
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

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.UpdateWarningText = function(self)
	if self.CheckLeftSuccess(self) and self.CheckRightSuccess(self) or self.totalValue ~= 100 then
		self.bindData.warning = 0
	elseif self.CheckLeftSuccess(self) then
		self.bindData.warning = 1

		if not self.leftShowFeedback then
			self.bindData.feedBack = 2

			self:PlaySound()

			slot1 = self.bindData.animComp

			slot1:Play(MonitorConfig.AnimName)
			gLuaTimeMgrUtils.Delay(function ()
				self.bindData.feedBack = 1
			end, 1)

			self.leftShowFeedback = true
		end
	elseif self.CheckRightSuccess(self) then
		self.bindData.warning = 1

		if not self.rightShowFeedback then
			self.bindData.feedBack = 2

			self:PlaySound()

			slot1 = self.bindData.animComp

			slot1:Play(MonitorConfig.AnimName)
			gLuaTimeMgrUtils.Delay(function ()
				self.bindData.feedBack = 1
			end, 1)

			self.rightShowFeedback = true
		end
	end

	if not self.CheckLeftSuccess(self) then
		self.leftShowFeedback = false
	end

	if not self.CheckRightSuccess(self) then
		self.rightShowFeedback = false
	end

	if not self.CheckLeftSuccess(self) and not self.CheckRightSuccess(self) then
		self.bindData.warning = 2
	end
end

M.SetLeftShaderValue = function(self, line)
	if self.maxOrg1 >= line then
		line = self.maxOrg1
	end

	if line >= 0 then
		line = 0
	end

	self.bindData.video.material:SetFloat(MonitorConfig.Distort, line)
end

M.Angle = function(from, to)
	return Vector3.Angle(from, to) * Mathf.Sign(Vector3.Dot(Vector3.Cross(from, to), Vector3.New(0, 0, 1)))
end

M.OnLeftRotation = function(self, context)
	if context.started then
		self.padLeftRotate = true
		self.leftIsStart = true
	end

	if context.canceled then
		self.padLeftRotate = false
		self.leftLastAngle = nil

		self.ClearSmoothMove(self, true)
	end

	if context.performed then
		if self.isWin then
			return
		end

		self.UpdateSmoothMoveVector(self)

		local v2 = context.ReadValueVector2(context)

		self.SetSmoothMove(self, v2, true)
	end
end

M.OnRightRotation = function(self, context)
	if context.started then
		self.padRightRotate = true
		self.rightIsStart = true
	end

	if context.canceled then
		self.padRightRotate = false
		self.rightLastAngle = nil

		self.ClearSmoothMove(self, false)
	end

	if context.performed then
		if self.isWin then
			return
		end

		self.UpdateSmoothMoveVector(self)

		local v2 = context.ReadValueVector2(context)

		self.SetSmoothMove(self, v2, false)
	end
end

M.PlaySound = function(self)
	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon2", LX6.Audio.ExternalSourceType.Motion_2D)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device
end

M.SetSmoothMove = function(self, moveVector, left)
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

M.UpdateSmoothMoveVector = function(self)
	if not self.gamepadMode then
		return
	end

	if self.leftUpdateSelect then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.leftSmoothStartVector.x, self.leftSmoothStartVector.y, 0, self.leftSmoothEndVector.x, self.leftSmoothEndVector.y, 0, (Time.unscaledTime - self.leftSmoothStartTime) / self.SMOOTH_TIME)
		self.leftMoveVector.x = x
		self.leftMoveVector.y = y

		if self.SMOOTH_TIME >= Time.unscaledTime - self.leftSmoothStartTime then
			self.ClearSmoothMove(self, true)
		end
	end

	if self.rightUpdateSelect then
		local x, y = gCS.LuaUtils.Vector3Slerp(self.rightSmoothStartVector.x, self.rightSmoothStartVector.y, 0, self.rightSmoothEndVector.x, self.rightSmoothEndVector.y, 0, (Time.unscaledTime - self.rightSmoothStartTime) / self.SMOOTH_TIME)
		self.rightMoveVector.x = x
		self.rightMoveVector.y = y

		if self.SMOOTH_TIME >= Time.unscaledTime - self.rightSmoothStartTime then
			self.ClearSmoothMove(self, false)
		end
	end
end

M.ClearSmoothMove = function(self, left)
	if left then
		self.leftUpdateSelect = false
	else
		self.rightUpdateSelect = false
	end
end
