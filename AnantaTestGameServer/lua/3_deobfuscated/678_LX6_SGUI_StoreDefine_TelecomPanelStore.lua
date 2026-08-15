local DragEventListener = SGUI.EventSystems.DragEventListener
C_TelecomPanelStore = DefClass("C_TelecomPanelStore", C_TelecomPanelStore, C_StoreGroup)
GroupName2Class.TelecomPanelStore = C_TelecomPanelStore
local M = C_TelecomPanelStore

function M:ctor()
	self.Mode = {
		PC = 2,
		Gamepad = 3,
		Mobile = 1,
		None = 0
	}
	self.openAni = "S_TelecomPanel_open"
	self.loopAni = "S_TelecomPanel_loop"
	self.lockAni = "S_TelecomPanel_lock"
end

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnBtnClose")
	self.speed = 100
	self.bindData.controllerMoveRespond.luaGamePadInputChanged = self:CreateAction("OnControllerMove")
	self.controllerMoveDelta = false
	self.updateMonitor = false
end

function M:OnShow(panelId, data)
	self.isSuccess = false
	self.bindData.MonitorCameraRotate.enabled = true

	self:PlayAni()

	self.currentMode = self.Mode.None

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentMode = SGUI.GameDevice.KeyboardMouse < gCS.LuaUtils.GetActiveDevice() and self.Mode.Gamepad or self.Mode.PC
	else
		self.currentMode = self.Mode.Mobile
	end

	self.curPos = data[1]
	self.cameraOpenPos = self.curPos + Vector3.up
	self.cameraOpenFacing = data[2]
	self.targetPos = data[3]
	self.xRotateNode = data[4]
	self.yRotateNode = data[5]
	self.updateMonitor = true
	self.cameraOpenKey = data[0]

	self.bindData.MonitorCameraTrans:SetPosition(self.cameraOpenPos.x, self.cameraOpenPos.y, self.cameraOpenPos.z)

	self.bindData.MonitorCameraTrans.forward = data[2]
	self.bindData.MonitorCameraTrans.parent = nil
	self.percent = Vector2.New(0, 0)
end

function M:OnClose()
	UnityEngine.GameObject.Destroy(self.bindData.MonitorCameraTrans.gameObject)

	self.currentMode = self.Mode.None
	self.cameraOpenKey = nil
	self.displayMonitor = nil
	self.percent = nil
	self.cameraOpenPos = nil
	self.cameraOpenFacing = nil

	gCS.CameraDataMgr:RevertMainCameraCullingMask(gPanelId.S_TELECOM_PANEL)
end

M.isSuccess = false

function M:OnUpdate()
	if self.isSuccess then
		return
	end

	if self.currentMode == self.Mode.Gamepad and self.controllerMoveDelta then
		gCameraUtils:DoRotateCameraByGamePad(7, self.controllerMoveDelta.x, self.controllerMoveDelta.y)
	end
end

function M:OnCameraUpdate()
	if self.isSuccess then
		self.bindData.MonitorCameraVirtualTrans.forward = self.targetPos - self.curPos

		return
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(self.targetPos)

	if screenPos.z > 0 then
		local UIPos = gUtils:ScreenToUIPosition(screenPos)

		if Mathf.Abs(UIPos.x) < 15 and Mathf.Abs(UIPos.y) < 15 then
			self:OnSuccess()
		end
	end

	self:RefreshModelRotate()
end

function M:OnActiveDeviceChange(device)
	self.currentMode = self.Mode.None

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentMode = SGUI.GameDevice.KeyboardMouse < device and self.Mode.Gamepad or self.Mode.PC
	else
		self.currentMode = self.Mode.Mobile
	end
end

function M:OnDrag(delta)
	return
end

function M:OnBtnClose()
	if self.closeTimer then
		return
	end

	gPanelManager:Close(gPanelId.S_TELECOM_PANEL)
end

function M:OnControllerMove(context)
	if self.isSuccess then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context:ReadValueVector2() * 5
	elseif context.canceled then
		self.controllerMoveDelta = false
	end
end

function M:PlayAni()
	local duration = gCS.LuaUtils.PlayAnimationByName(self.bindData.telecomPanelAni, self.openAni)

	if self.aniTimer then
		self.aniTimer:Stop()
	end

	self.aniTimer = Timer.New(function ()
		if self.bindData.telecomPanelAni then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.telecomPanelAni, self.loopAni)
		end
	end, duration):Start()
end

function M:OnSuccess()
	self.bindData.MonitorCameraVirtualTrans.forward = self.targetPos - self.curPos
	self.bindData.MonitorCameraRotate.enabled = false
	self.isSuccess = true

	L50.L50App.Scene.GamePlayUtils:OnTriggerLightPath(self.cameraOpenKey)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.telecomPanelAni, self.lockAni)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_TELECOM_PANEL)
	end, 2.5)
end

function M:RefreshModelRotate()
	local angle = self.bindData.MonitorCameraVirtualTrans.localEulerAngles
	local angle2 = self.yRotateNode.localEulerAngles
	angle2.z = angle.x + 90
	self.yRotateNode.localEulerAngles = angle2
	local angle1 = self.xRotateNode.localEulerAngles
	angle1.y = angle.y + 90
	self.xRotateNode.localEulerAngles = angle1
end
