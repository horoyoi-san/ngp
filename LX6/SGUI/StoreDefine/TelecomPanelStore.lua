-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TelecomPanelStore.lua
-- Decompiled from: 01400_TelecomPanelStore.lua_872c5a4cb005.luajit

C_TelecomPanelStore = DefClass("C_TelecomPanelStore", C_TelecomPanelStore, C_StoreGroup)
GroupName2Class.TelecomPanelStore = C_TelecomPanelStore
local M = C_TelecomPanelStore

M.ctor = function(self)
	self.Mode = {
		["0*"] = 2,
		["\\xfe\\xda%\\xf5"] = 3,
		["1G\\x93\\x87\\x8fD"] = 1,
		["T-s^"] = 0
	}
	self.openAni = "S_TelecomPanel_open"
	self.loopAni = "S_TelecomPanel_loop"
	self.lockAni = "S_TelecomPanel_lock"
end

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnBtnClose")
	self.speed = 100
	self.bindData.controllerMoveRespond.luaGamePadInputChanged = self.CreateAction(self, "OnControllerMove")
	self.controllerMoveDelta = false
	self.updateMonitor = false
end

M.OnShow = function(self, panelId, data)
	self.isSuccess = false
	self.bindData.MonitorCameraRotate.enabled = true

	self.PlayAni(self)

	self.currentMode = self.Mode.None

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentMode = SGUI.GameDevice.KeyboardMouse >= gCS.LuaUtils.GetActiveDevice() and self.Mode.Gamepad or self.Mode.PC
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

M.OnClose = function(self)
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

M.OnUpdate = function(self)
	if self.isSuccess then
		return
	end

	if self.currentMode ~= self.Mode.Gamepad and self.controllerMoveDelta then
		gCameraUtils:DoRotateCameraByGamePad(7, self.controllerMoveDelta.x, self.controllerMoveDelta.y)
	end
end

M.OnCameraUpdate = function(self)
	if self.isSuccess then
		self.bindData.MonitorCameraVirtualTrans.forward = self.targetPos - self.curPos

		return
	end

	local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(self.targetPos)

	if screenPos.z <= 0 then
		local UIPos = gUtils:ScreenToUIPosition(screenPos)

		if Mathf.Abs(UIPos.x) >= 15 and Mathf.Abs(UIPos.y) >= 15 then
			self.OnSuccess(self)
		end
	end

	self.RefreshModelRotate(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.currentMode = self.Mode.None

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.currentMode = SGUI.GameDevice.KeyboardMouse >= device and self.Mode.Gamepad or self.Mode.PC
	else
		self.currentMode = self.Mode.Mobile
	end
end

M.OnDrag = function(self, delta)
end

M.OnBtnClose = function(self)
	if self.closeTimer then
		return
	end

	gPanelManager:Close(gPanelId.S_TELECOM_PANEL)
end

M.OnControllerMove = function(self, context)
	if self.isSuccess then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context.ReadValueVector2(context) * 5
	elseif context.canceled then
		self.controllerMoveDelta = false
	end
end

M.PlayAni = function(self)
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

M.OnSuccess = function(self)
	self.bindData.MonitorCameraVirtualTrans.forward = self.targetPos - self.curPos
	self.bindData.MonitorCameraRotate.enabled = false
	self.isSuccess = true
	slot1 = L50.L50App.Scene.GamePlayUtils

	slot1:OnTriggerLightPath(self.cameraOpenKey)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.telecomPanelAni, self.lockAni)
	gLuaTimeMgrUtils.Delay(function ()
		gPanelManager:Close(gPanelId.S_TELECOM_PANEL)
	end, 2.5)
end

M.RefreshModelRotate = function(self)
	local angle = self.bindData.MonitorCameraVirtualTrans.localEulerAngles
	local angle2 = self.yRotateNode.localEulerAngles
	angle2.z = angle.x + 90
	self.yRotateNode.localEulerAngles = angle2
	local angle1 = self.xRotateNode.localEulerAngles
	angle1.y = angle.y + 90
	self.xRotateNode.localEulerAngles = angle1
end
