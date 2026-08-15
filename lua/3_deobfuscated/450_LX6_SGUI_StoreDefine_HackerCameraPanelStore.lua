C_HackerCameraPanelStore = DefClass("C_HackerCameraPanelStore", C_HackerCameraPanelStore, C_StoreGroup)
GroupName2Class.HackerCameraPanelStore = C_HackerCameraPanelStore
local M = C_HackerCameraPanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.HACKER_CAMERA_PANEL_FOLLOW_TARGET] = self:CreateAction(self.BeginCameraFollowTarget),
		[gEventConstants.HACKER_CAMERA_PANEL_SET_EXIT_BTN] = self:CreateAction(self.SetExitBtnHandler),
		[gEventConstants.HACKER_CAMERA_PANEL_EXIT_ANIM] = self:CreateAction(self.PlayExitAnim)
	}
end

function M:OnAwake()
	self.bindData.exitBtnMobile.luaClick = self:CreateAction("OnClickExit")
	self.bindData.exitBtn.luaClick = self:CreateAction("OnClickExit")
	self.bindData.hackBtnMobile.luaClick = self:CreateAction("OnClickHack")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.zoomRespond.luaGamePadInputChanged = self:CreateAction("OnZoomChanged")
		self.bindData.cameraControl.luaGamePadInputChanged = self:CreateAction("OnCameraChanged")
		self.bindData.smallZoom.luaPress = self:CreateAction("OnPressSmallZoom")
		self.bindData.smallZoom.luaRelease = self:CreateAction("OnReleaseSmallZoom")
		self.bindData.bigZoom.luaPress = self:CreateAction("OnPressBigZoom")
		self.bindData.bigZoom.luaRelease = self:CreateAction("OnReleaseBigZoom")
		self.bindData.switchControls.luaClick = self:CreateAction("OnSwitchToControlsBtnClick")
	else
		local gestureListener = self.bindData.cameraControl.transform:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		self.bindData.roomSlider.luaValueChanged = self:CreateAction("OnRoomSliderValueChanged")
	end
end

function M:OnStart()
	return
end

function M:OnShow(panelId, data)
	self.isOpen = true

	if data.ToTable then
		data = data:ToTable()

		if data.telescopeData and data.telescopeData.ToTable then
			data.telescopeData = data.telescopeData:ToTable()
		end
	end

	if data.showWarnOnce then
		self.bindData.warn = 1

		gLuaTimeMgrUtils.Delay(function ()
			self.bindData.warn = 0
		end, 3)
	end

	if not data.keepPaoKuState and not gDriveVehiclesManager.cs_manager.isDriveMode then
		gClientUtils:ClearPaoKuState()
		gUnitStateMgr:DoEnterIdleSpeed(false, false, true)
	end

	self:InitViewByData(data)

	self.enterSceneAction = self:CreateAction("OnAfterSwitchScene")

	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self.enterSceneAction)
	gMessageManager:AddMessageListener(gEventConstants.PHOTO_CONTROLLER_NEW, function ()
		self.isInVideo = true
	end)
	gMessageManager:AddMessageListener(gEventConstants.PHOTO_CONTROLLER_DESTROY, function ()
		self.isInVideo = false
	end)

	self.switchControlAction = self:CreateAction(self.RefreshSwitchToControlsBtnState)

	gMessageManager:AddMessageListener(gEventConstants.SUMMON_STATE_SWITCH, self.switchControlAction)

	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		stateId = 5,
		btnId = 0,
		priority = 1,
		groupId = LTConfig.HudDescGroupConfig.HACKERCAMERA
	})

	gMessageManager:SendMessage(gEventConstants.HACK_CAMERA_ENTER, gGadgetManager.curHackCameraEntityId)
	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.HACK_CAMERA_PANEL)
	self.bindData.anim:Play("S_vx_HackerCameraPanel_open")
end

function M:InitViewByData(data)
	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	self.isFocus = false
	self.data = data
	self.maxFieldOfView = data.minFov and data.maxFov or 50
	self.minFieldOfView = data.minFov and data.minFov or 10
	self.isSave = data.isSave
	self.telescopeData = data.telescopeData

	self:SetFov(data.fov, true)

	if data.useTelescope then
		self.bindData.mode = data.telescopePanelType and data.telescopePanelType or 1
	else
		self.bindData.mode = 0
	end

	self:EnterFirstPerson(data.fov, self.telescopeData, true)

	gGadgetManager.hackCameraPanelStore = self
	L50.L50App.Scene.GamePlayUtils.hackCameraPanelStoreShow = true
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false

	if gGadgetManager.hackCameraPanelExitBtn == nil then
		gGadgetManager.hackCameraPanelExitBtn = true
	end

	self:SetExitBtn(gGadgetManager.hackCameraPanelExitBtn)
	self:RefreshSwitchToControlsBtnState()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnClickExit()
	self:PlayExitAnim()
end

function M:OnClickHack()
	return
end

function M:SetExitBtn(open)
	gGadgetManager.hackCameraPanelExitBtn = open

	self.bindData.exitBtn.gameObject:SetActive(open)
	self.bindData.exitBtnMobile.gameObject:SetActive(open)
end

function M:SetExitBtnHandler(eventId, open)
	self:SetExitBtn(open)
end

function M:PlayExitAnim()
	if not self.isOpen then
		return
	end

	self.isOpen = false

	if self.bindData.anim then
		self.bindData.anim:Play("S_vx_HackerCameraPanel_close")
	end

	gLuaTimeMgrUtils.Delay(function ()
		gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("HackInteract")
	end, self.bindData.anim:GetClip("S_vx_HackerCameraPanel_close").length)
end

function M:OnClose()
	self.isOpen = false

	gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)
	gMessageManager:RemoveMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self.enterSceneAction)
	gMessageManager:RemoveMessageListener(gEventConstants.SUMMON_STATE_SWITCH, self.switchControlAction)
	gMessageManager:SendMessage(gEventConstants.HACK_CAMERA_EXIT, gGadgetManager.curHackCameraEntityId)

	gGadgetManager.curHackCameraEntityId = nil

	gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetHackCamera, false)

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	gGadgetManager.hackCameraPanelStore = nil
	L50.L50App.Scene.GamePlayUtils.hackCameraPanelStoreShow = false
	gGadgetManager.hackCameraPanelExitBtn = nil

	self:OnCloseHelper()
	LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.HACK_CAMERA_PANEL)
end

function M:OnCloseHelper()
	gCS.CameraDataMgr.cinemachineManager:DisableFirstPersonCamera(false, 1)
	self:SetFov(50)

	gLuaDataManager.guiMgr.sguiJoystick.Visible = true

	self:SaveTelescopePanelData()
end

function M:SaveTelescopePanelData()
	if self.isSave and self.bindData.mode ~= 0 then
		self.lastFov = gCS.CameraDataMgr.MainCamera.fieldOfView
		self.lastPosition = gCS.CameraDataMgr.MainCamera.transform.position
		self.lastRotation = gCS.CameraDataMgr.MainCamera.transform.eulerAngles
	end

	self:ExitFirstPerson()
end

function M:OnUpdate()
	if self.isFocus then
		return
	end

	if self.smallZoomPressed and not self.bigZoomPressed then
		self:SetFovByFocus(false, 0.4)
	elseif self.bigZoomPressed and not self.smallZoomPressed then
		self:SetFovByFocus(false, -0.4)
	end

	if not self.isInVideo then
		local context = self.data.useTelescope and 9 or 8

		if self.controllerMoveDelta then
			gCameraUtils:DoRotateCameraByGamePad(context, self.controllerMoveDelta.x, self.controllerMoveDelta.y)
		else
			gCameraUtils:DoRotateCameraByGamePad(context, 0, 0)
		end
	end

	if self.telescopeUnitData then
		self:CameraFollowTarget()
	end
end

function M:OnZoomChanged(context)
	if self.isFocus then
		return
	end

	if context.phase ~= 2 then
		return
	end

	local delta = -context:ReadValueVector2().y / 20

	self:SetFovByFocus(true, delta)
end

M.roomRate = 1

function M:OnGestureZoom(zoom)
	if self.isFocus then
		return
	end

	print_notice("OnGestureZoom", zoom)
	self:SetFovByFocus(true, -zoom * self.roomRate)
end

function M:OnRoomSliderValueChanged(value)
	if self.isFocus then
		return
	end

	local curFOV = self.maxFieldOfView + value * 0.01 * (self.minFieldOfView - self.maxFieldOfView)

	self:SetFov(curFOV, false)
end

function M:SetFovByFocus(isMouse, delta)
	if self.isFocus then
		return
	end

	local curFOV = gCS.CameraDataMgr.MainCamera.fieldOfView + delta

	if self.maxFieldOfView < curFOV then
		curFOV = self.maxFieldOfView
	end

	if curFOV < self.minFieldOfView then
		curFOV = self.minFieldOfView
	end

	self:SetFov(curFOV, true, isMouse and 0.2 or 0)
end

function M:SetFov(curFOV, changeSlider, blendTime)
	blendTime = blendTime or 0

	gCS.CameraDataMgr.cinemachineManager:SetFov(curFOV, blendTime, 0, false)

	if changeSlider then
		self.bindData.roomSlider.value = (curFOV - self.maxFieldOfView) / (self.minFieldOfView - self.maxFieldOfView) * 100
	end
end

M.smallZoomPressed = false
M.bigZoomPressed = false
M.isFocus = false
M.shakeId = nil

function M:OnPressSmallZoom()
	self.smallZoomPressed = true

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end

	self.shakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
end

function M:OnReleaseSmallZoom()
	self.smallZoomPressed = false

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end
end

function M:OnPressBigZoom()
	self.bigZoomPressed = true

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end

	self.shakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
end

function M:OnReleaseBigZoom()
	self.bigZoomPressed = false

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end
end

function M:OnCameraChanged(context)
	if self.isFocus then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context:ReadValueVector2()
	elseif context.canceled then
		self.controllerMoveDelta = nil
	end
end

function M:OnAfterSwitchScene(switchType)
	if not self.data then
		return
	end

	if self.data.xRange and self.data.yRange then
		gCS.CameraDataMgr.cinemachineManager:EnableFirstPersonCamera(self.data.target, Vector3.zero, self.data.xRange, self.data.yRange, self.data.defaultAngle, 0, false)
	end

	self:InitViewByData(self.data)
end

function M:SetFocus(open, target, duration)
	self.isFocus = open

	if open then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
		local cameraDirection = target.position - self.data.target.position

		gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotate(cameraDirection, duration)
	else
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

function M:BeginCameraFollowTarget(_, telescopeUnitData)
	self:SetFov(self.minFieldOfView, true, 0.5)

	if telescopeUnitData.gazeTime <= 0 then
		self.telescopeUnitData = nil

		return
	end

	self.existTime = 0
	self.telescopeUnitData = telescopeUnitData
end

function M:CameraFollowTarget()
	self.existTime = self.existTime + Time.deltaTime

	if self.telescopeUnitData.gazeTime <= self.existTime then
		self.existTime = 0
		self.telescopeUnitData = nil

		return
	end

	local cameraTrans = gCS.CameraDataMgr.MainCamera.transform
	local trans = self.telescopeUnitData.trans
	local pos = self.telescopeUnitData.pos

	if type(trans) == "table" or not gCS.LuaUtils.IsNull(trans) then
		pos = trans.position
	end

	local lookAtDir = (pos - cameraTrans.position).normalized
	local camDir = cameraTrans.forward.normalized
	local finalDir = Vector3.Lerp(camDir, lookAtDir, 0.5)

	gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotate(finalDir, 0, 9999)
end

function M:RefreshSwitchToControlsBtnState()
	self.bindData.switchControls:SetWidgetFaraway(not self.data or not self.data.useTelescope or not ulong.Greater(gBattleMgr.SummonAgentId, 0))
end

function M:OnSwitchToControlsBtnClick()
	if gBattleMgr.SummonAgentId and ulong.Greater(gBattleMgr.SummonAgentId, 0) then
		gClientToGameSceneDelegate:AskControlAgent(gBattleMgr.SummonAgentId, UX.Game.SwitchControlReason.Client)
	end
end

function M:ExitFirstPerson()
	if self.bindData.mode ~= 0 then
		gCS.ShootModule.EnableTelescopeMode(gCS.MyPlayerManager.PlayerUnit, false)
		gCS.MyPlayerManager.SwitchCameraBlock(true)
		gCS.LuaUtils.SetCameraNearPlaneOffset(0)
		gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5)
		gCS.CameraDataMgr.cinemachineManager:DisableFirstPersonCamera(true)
	end
end

function M:EnterFirstPerson(fov, data, isFirst)
	if self.bindData.mode ~= 0 and data then
		gLuaDataManager.guiMgr.sguiJoystick.Visible = false

		self:SetFov(fov, true, 0)

		local cameraTargetPos = data.cameraTargetPos

		if isFirst then
			gCS.CameraDataMgr.cinemachineManager:SetFirstPersonCameraToTargetAndRange(cameraTargetPos, data.targetPos, data.leftAgent, data.rightAgent, data.topAgent, data.bottomAgent)
		elseif self.isSave then
			local defaultAngle = Vector2.New(self.lastRotation.y, self.lastRotation.x)
			local xRange = Vector2.New(defaultAngle.x - data.leftAgent, defaultAngle.x + data.rightAgent)
			local yAngle = (defaultAngle.y + 90) / 180
			local yRange = Vector2.New(math.max(yAngle - data.topAgent, 0), math.min(yAngle + data.bottomAgent, 1))

			gCS.CameraDataMgr.cinemachineManager:EnableFirstPersonCamera(cameraTargetPos, Vector3.zero, xRange, yRange, defaultAngle, 0, true)
		end

		gCS.MyPlayerManager.SwitchCameraBlock(false)
		gCS.LuaUtils.SetCameraNearPlaneOffset(50)
	end
end

function M:OnStackHide()
	self:OnCloseHelper()
end

function M:OnStackShow()
	self:EnterFirstPerson(self.lastFov, self.telescopeData, false)
end

function M:IsHackCameraOpen()
	if not self.isOpen then
		return false
	end

	if not self.data then
		return false
	end

	local mode = 0

	if self.data.useTelescope then
		mode = self.data.telescopePanelType and self.data.telescopePanelType or 1
	end

	return mode == 0
end
