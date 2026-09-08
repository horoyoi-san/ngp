-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HackerCameraPanelStore.lua
-- Decompiled from: 01698_HackerCameraPanelStore.lua_5e4326945385.luajit

C_HackerCameraPanelStore = DefClass("C_HackerCameraPanelStore", C_HackerCameraPanelStore, C_StoreGroup)
GroupName2Class.HackerCameraPanelStore = C_HackerCameraPanelStore
local M = C_HackerCameraPanelStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.HACKER_CAMERA_PANEL_FOLLOW_TARGET] = self.CreateAction(self, self.BeginCameraFollowTarget),
		[gEventConstants.HACKER_CAMERA_PANEL_SET_EXIT_BTN] = self.CreateAction(self, self.SetExitBtnHandler),
		[gEventConstants.HACKER_CAMERA_PANEL_EXIT_ANIM] = self.CreateAction(self, self.PlayExitAnim)
	}
end

M.OnAwake = function(self)
	self.bindData.exitBtnMobile.luaClick = self.CreateAction(self, "OnClickExit")
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnClickExit")
	self.bindData.hackBtnMobile.luaClick = self.CreateAction(self, "OnClickHack")

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.zoomRespond.luaGamePadInputChanged = self.CreateAction(self, "OnZoomChanged")
		self.bindData.cameraControl.luaGamePadInputChanged = self.CreateAction(self, "OnCameraChanged")
		self.bindData.smallZoom.luaPress = self.CreateAction(self, "OnPressSmallZoom")
		self.bindData.smallZoom.luaRelease = self.CreateAction(self, "OnReleaseSmallZoom")
		self.bindData.bigZoom.luaPress = self.CreateAction(self, "OnPressBigZoom")
		self.bindData.bigZoom.luaRelease = self.CreateAction(self, "OnReleaseBigZoom")
		self.bindData.switchControls.luaClick = self.CreateAction(self, "OnSwitchToControlsBtnClick")
	else
		local gestureListener = self.bindData.cameraControl.transform:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
		gestureListener.onZoom = self:CreateAction("OnGestureZoom")
		self.bindData.roomSlider.luaValueChanged = self:CreateAction("OnRoomSliderValueChanged")
	end
end

M.OnStart = function(self)
end

M.OnShow = function(self, panelId, data)
	self.isOpen = true

	if data.ToTable then
		data = data.ToTable(data)

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

	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self.enterSceneAction)
	gMessageManager:AddMessageListener(gEventConstants.PHOTO_CONTROLLER_NEW, function ()
		self.isInVideo = true
	end)
	gMessageManager:AddMessageListener(gEventConstants.PHOTO_CONTROLLER_DESTROY, function ()
		self.isInVideo = false
	end)

	self.switchControlAction = self:CreateAction(self.RefreshSwitchToControlsBtnState)

	gMessageManager:AddMessageListener(gEventConstants.SUMMON_STATE_SWITCH, self.switchControlAction)

	self.registerOperationId = gStoreButtonMgr:RegisterOperation({
		["\\xca\\xcf\t\r\\xf5"] = 5,
		["O\\xba\\xac\\x86\\xb2"] = 0,
		["\\xbb\\xa3\\xa4x7\\xea*"] = 1,
		groupId = LTConfig.HudDescGroupConfig.HACKERCAMERA
	})

	gMessageManager:SendMessage(gEventConstants.HACK_CAMERA_ENTER, gGadgetManager.curHackCameraEntityId)
	LX6.GUI.GuiMgr.Instance:AddHUDJoystickControl(false, gBanId.HACK_CAMERA_PANEL)
	self.bindData.anim:Play("S_vx_HackerCameraPanel_open")

	if not self.data.useTelescope then
		gCS.EffectMgr:PlayEffectsForUnitId(gCS.MyPlayerManager.PlayerUnit.Pid, 53100914, LX6.Effect.EffectPlayTag.Gameplay)
	end

	self.bindData.soundNid = gSoundMgr:PlaySoundByTid(70250186)
end

M.InitViewByData = function(self, data)
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

	self.EnterFirstPerson(self, data.fov, self.telescopeData, true)

	gGadgetManager.hackCameraPanelStore = self
	L50.L50App.Scene.GamePlayUtils.hackCameraPanelStoreShow = true
	gLuaDataManager.guiMgr.sguiJoystick.Visible = false

	if gGadgetManager.hackCameraPanelExitBtn ~= nil then
		gGadgetManager.hackCameraPanelExitBtn = true
	end

	if not data.keepExitBtnState then
		gGadgetManager.hackCameraPanelExitBtn = true
	end

	self.SetExitBtn(self, gGadgetManager.hackCameraPanelExitBtn)
	self.RefreshSwitchToControlsBtnState(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnClickExit = function(self)
	self.PlayExitAnim(self)
end

M.OnClickHack = function(self)
end

M.SetExitBtn = function(self, open)
	gGadgetManager.hackCameraPanelExitBtn = open

	self.bindData.exitBtn.gameObject:SetActive(open)
	self.bindData.exitBtnMobile.gameObject:SetActive(open)
end

M.SetExitBtnHandler = function(self, eventId, open)
	self.SetExitBtn(self, open)
end

M.PlayExitAnim = function(self)
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
	gSoundMgr:PlaySoundByTid(70250185)
end

M.OnClose = function(self)
	gSoundMgr:StopSoundByNid(self.bindData.soundNid)

	self.isOpen = false

	gStoreButtonMgr:UnRegisterOperation(self.registerOperationId)
	gMessageManager:RemoveMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self.enterSceneAction)
	gMessageManager:RemoveMessageListener(gEventConstants.SUMMON_STATE_SWITCH, self.switchControlAction)
	gMessageManager:SendMessage(gEventConstants.HACK_CAMERA_EXIT, gGadgetManager.curHackCameraEntityId)

	gGadgetManager.curHackCameraEntityId = nil
	gGadgetManager.curHackCameraPos = nil

	gCS.FeiSuoCrouchManager.SetHideUI(LX6.Units.FeiSuoCrouchManager.HideUIReason.GadgetHackCamera, false)

	gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	gGadgetManager.hackCameraPanelStore = nil
	L50.L50App.Scene.GamePlayUtils.hackCameraPanelStoreShow = false

	self:OnCloseHelper()
	LX6.GUI.GuiMgr.Instance:RemoveHUDJoystickControl(gBanId.HACK_CAMERA_PANEL)

	if not self.data.useTelescope then
		gCS.EffectMgr:PlayEffectsForUnitId(gCS.MyPlayerManager.PlayerUnit.Pid, 53100914, LX6.Effect.EffectPlayTag.Gameplay)
	end
end

M.OnCloseHelper = function(self)
	gCS.CameraDataMgr.cinemachineManager:DisableFirstPersonCamera(false, 1)
	self:SetFov(50)

	gLuaDataManager.guiMgr.sguiJoystick.Visible = true

	self:SaveTelescopePanelData()
end

M.SaveTelescopePanelData = function(self)
	if self.isSave and self.bindData.mode == 0 then
		self.lastFov = gCS.CameraDataMgr.MainCamera.fieldOfView
		self.lastPosition = gCS.CameraDataMgr.MainCamera.transform.position
		self.lastRotation = gCS.CameraDataMgr.MainCamera.transform.eulerAngles
	end

	self.ExitFirstPerson(self)
end

M.OnUpdate = function(self)
	if self.isFocus then
		return
	end

	if self.smallZoomPressed and not self.bigZoomPressed then
		self.SetFovByFocus(self, false, 0.4)
	elseif self.bigZoomPressed and not self.smallZoomPressed then
		self.SetFovByFocus(self, false, -0.4)
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
		self.CameraFollowTarget(self)
	end
end

M.OnZoomChanged = function(self, context)
	if self.isFocus then
		return
	end

	if context.phase == 2 then
		return
	end

	local delta = -context.ReadValueVector2(context).y / 20

	self.SetFovByFocus(self, true, delta)
end

M.roomRate = 1

M.OnGestureZoom = function(self, zoom)
	if self.isFocus then
		return
	end

	print_notice("OnGestureZoom", zoom)
	self.SetFovByFocus(self, true, -zoom * self.roomRate)
end

M.OnRoomSliderValueChanged = function(self, value)
	if self.isFocus then
		return
	end

	local curFOV = self.maxFieldOfView + value * 0.01 * (self.minFieldOfView - self.maxFieldOfView)

	self.SetFov(self, curFOV, false)
end

M.SetFovByFocus = function(self, isMouse, delta)
	if self.isFocus then
		return
	end

	local curFOV = gCS.CameraDataMgr.MainCamera.fieldOfView + delta

	if self.maxFieldOfView >= curFOV then
		curFOV = self.maxFieldOfView

		if self.shakeId then
			gSoundMgr:StopSoundByNid(self.shakeId)

			self.shakeId = nil
		end
	end

	if curFOV >= self.minFieldOfView then
		curFOV = self.minFieldOfView

		if self.shakeId then
			gSoundMgr:StopSoundByNid(self.shakeId)

			self.shakeId = nil
		end
	end

	self:SetFov(curFOV, true, isMouse and 0.2 or 0)
end

M.SetFov = function(self, curFOV, changeSlider, blendTime)
	blendTime = blendTime or 0

	gCS.CameraDataMgr.cinemachineManager:SetFov(curFOV, blendTime, 0, false)

	if changeSlider then
		self.bindData.roomSlider.value = (curFOV - self.maxFieldOfView) / (self.minFieldOfView - self.maxFieldOfView) * 100
	end

	local soundData = gSoundMgr:GetSoundDataByNid(self.bindData.soundNid)

	if soundData then
		soundData.SetRTPCValue(soundData, "LP_Camera_Zoom", curFOV)
	end
end

M.smallZoomPressed = false
M.bigZoomPressed = false
M.isFocus = false
M.shakeId = nil

M.OnPressSmallZoom = function(self)
	self.smallZoomPressed = true

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end

	self.shakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
end

M.OnReleaseSmallZoom = function(self)
	self.smallZoomPressed = false

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end
end

M.OnPressBigZoom = function(self)
	self.bigZoomPressed = true

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end

	self.shakeId = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)
end

M.OnReleaseBigZoom = function(self)
	self.bigZoomPressed = false

	if self.shakeId then
		gSoundMgr:StopSoundByNid(self.shakeId)

		self.shakeId = nil
	end
end

M.OnCameraChanged = function(self, context)
	if self.isFocus then
		return
	end

	if context.performed then
		self.controllerMoveDelta = context:ReadValueVector2()
		local value = self.controllerMoveDelta.x + self.controllerMoveDelta.y
		local soundData = gSoundMgr:GetSoundDataByNid(self.bindData.soundNid)

		if soundData then
			soundData.SetRTPCValue(soundData, "LP_Camera_Move", value)
		end
	elseif context.canceled then
		self.controllerMoveDelta = nil
	end
end

M.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	if not self.data then
		return
	end

	if self.data.xRange and self.data.yRange then
		gCS.CameraDataMgr.cinemachineManager:EnableFirstPersonCamera(self.data.target, Vector3.zero, self.data.xRange, self.data.yRange, self.data.defaultAngle, 0, false)
	end

	self.InitViewByData(self, self.data)
end

M.SetFocus = function(self, open, target, duration)
	self.isFocus = open

	if open then
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = false
		local cameraDirection = target.position - self.data.target.position

		gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotate(cameraDirection, duration)
	else
		gCS.CameraDataMgr.cameraControllerManager.IsRotateEnabled = true
	end
end

M.BeginCameraFollowTarget = function(self, _, telescopeUnitData)
	self.SetFov(self, self.minFieldOfView, true, 0.5)

	if telescopeUnitData.gazeTime < 0 then
		self.telescopeUnitData = nil

		return
	end

	self.existTime = 0
	self.telescopeUnitData = telescopeUnitData
end

M.CameraFollowTarget = function(self)
	self.existTime = self.existTime + Time.deltaTime

	if self.telescopeUnitData.gazeTime < self.existTime then
		self.existTime = 0
		self.telescopeUnitData = nil

		return
	end

	local cameraTrans = gCS.CameraDataMgr.MainCamera.transform
	local trans = self.telescopeUnitData.trans
	local pos = self.telescopeUnitData.pos

	if type(trans) ~= "table" or not gCS.LuaUtils.IsNull(trans) then
		pos = trans.position
	end

	local lookAtDir = (pos - cameraTrans.position).normalized
	local camDir = cameraTrans.forward.normalized
	local finalDir = Vector3.Lerp(camDir, lookAtDir, 0.5)

	gCS.CameraDataMgr.cinemachineManager:SetCurrentFreelookRotate(finalDir, 0, 9999)
end

M.RefreshSwitchToControlsBtnState = function(self)
	self.bindData.switchControls:SetWidgetFaraway(not self.data or not self.data.useTelescope or not ulong.Greater(gBattleMgr.SummonAgentId, 0))
end

M.OnSwitchToControlsBtnClick = function(self)
	if gBattleMgr.SummonAgentId and ulong.Greater(gBattleMgr.SummonAgentId, 0) then
		gClientToGameSceneDelegate:AskControlAgent(gBattleMgr.SummonAgentId, UX.Game.SwitchControlReason.Client)
	end
end

M.ExitFirstPerson = function(self)
	if self.bindData.mode == 0 then
		gCS.ShootModule.EnableTelescopeMode(gCS.MyPlayerManager.PlayerUnit, false)
		gCS.MyPlayerManager.SwitchCameraBlock(true)
		gCS.LuaUtils.SetCameraNearPlaneOffset(0)
		gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5)
		gCS.CameraDataMgr.cinemachineManager:DisableFirstPersonCamera(true)
	end
end

M.EnterFirstPerson = function(self, fov, data, isFirst)
	if self.bindData.mode == 0 and data then
		gLuaDataManager.guiMgr.sguiJoystick.Visible = false

		self.SetFov(self, fov, true, 0)

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

M.OnStackHide = function(self)
	self.OnCloseHelper(self)
end

M.OnStackShow = function(self)
	self.EnterFirstPerson(self, self.lastFov, self.telescopeData, false)
end
