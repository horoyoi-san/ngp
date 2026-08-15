local FerrisWheelConfig = LTConfig.FerrisWheelConfig
local FerrisCameraFirstPersonConfig = LTConfig.FerrisWheelFerrisCameraFirstPersonConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local CameraFreeLookActionStatusConfig = LTConfig.CameraFreeLookActionStatusConfig
local ParkourStateConfig = LTConfig.ParkourStateConfig
C_FerrisPanelStore = DefClass("C_FerrisPanelStore", C_FerrisPanelStore, C_StoreGroup)
GroupName2Class.FerrisPanelStore = C_FerrisPanelStore
local M = C_FerrisPanelStore
local ViewMode = {
	Third = 1,
	Far = 2,
	First = 0
}
local PlayerState = {
	Standing = 1,
	Sitting = 0,
	JiaoHu = 2
}
local clickCD = 0.5
local lastClickTime = 0

function M:InClickCD()
	if gLogicTime.time - lastClickTime < clickCD then
		return true
	end

	lastClickTime = gLogicTime.time

	return false
end

function M:ctor()
	self.msgEvents = {
		[gEventConstants.FERRIS_SIT] = function ()
			self:OnPlayerSit()
		end,
		[gEventConstants.FERRIS_STAND] = function ()
			self:OnPlayerStand()
		end
	}
	self.isRotatingCamera = false
	self.npcBodyType = 0
	self.isEnterWindow = false
end

function M:OnAwake()
	self.bindData.switchBtnMobile.luaClick = self:CreateAction(self.OnClickSwitch)
	self.bindData.switchBtn.luaClick = self:CreateAction(self.OnClickSwitch)
	self.bindData.exitBtnMobile.luaClick = self:CreateAction(self.ClickClose)
	self.bindData.exitBtn.luaClick = self:CreateAction(self.ClickClose)
	self.bindData.enterWindowMobileBtn.luaClick = self:CreateAction(self.ClickEnterWindow)
	self.bindData.enterWindowBtn.luaClick = self:CreateAction(self.ClickEnterWindow)
	self.bindData.exitWindowMobileBtn.luaClick = self:CreateAction(self.ClickExitWindow)
	self.bindData.exitWindowBtn.luaClick = self:CreateAction(self.ClickExitWindow)
	self.bindData.customNavRespond.luaGamePadInputChanged = self:CreateAction("OnRotateCameraInput")
end

function M:OnStart()
	return
end

function M:OnShow(panelId, data)
	self.isClose = false

	gFerrisMgr:SetFerrisPanelOpen(true)
	gMapUtils:CloseMiniMap()
	self:SetViewMode(ViewMode.Far)

	self.prePlayerState = PlayerState.Sitting
	self.curPlayerState = PlayerState.Sitting
end

function M:CheckPlayerThirdCameraState()
	if gMainMenuMgr:CheckHasClientState(ParkourStateConfig.Sit) then
		if self.curPlayerState == PlayerState.Sitting then
			-- Nothing
		elseif self.curPlayerState == PlayerState.Standing then
			self.prePlayerState = self.curPlayerState
			self.curPlayerState = PlayerState.Sitting

			return true, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0
		elseif self.curPlayerState == PlayerState.JiaoHu then
			if self.prePlayerState == PlayerState.Sitting then
				self.curPlayerState = PlayerState.Sitting

				return true, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0.5
			elseif self.prePlayerState == PlayerState.Standing then
				self.prePlayerState = self.curPlayerState
				self.curPlayerState = PlayerState.Sitting
			elseif self.prePlayerState == PlayerState.JiaoHu then
				self.prePlayerState = PlayerState.Sitting
				self.curPlayerState = PlayerState.Sitting
			end
		end
	elseif gMainMenuMgr:CheckHasClientState(ParkourStateConfig.JiaoHu) then
		if self.curPlayerState == PlayerState.Sitting then
			self.prePlayerState = self.curPlayerState
			self.curPlayerState = PlayerState.JiaoHu

			return true, CameraFreeLookActionStatusConfig.InFerrisBox, 1, 1
		elseif self.curPlayerState == PlayerState.Standing then
			self.prePlayerState = self.curPlayerState
			self.curPlayerState = PlayerState.JiaoHu

			return true, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0.5
		elseif self.curPlayerState == PlayerState.JiaoHu then
			-- Nothing
		end
	elseif self.curPlayerState == PlayerState.Sitting then
		self.prePlayerState = self.curPlayerState
		self.curPlayerState = PlayerState.Standing

		return true, CameraFreeLookActionStatusConfig.InFerrisBox, 0.3
	elseif self.curPlayerState == PlayerState.Standing then
		-- Nothing
	elseif self.curPlayerState == PlayerState.JiaoHu then
		if self.prePlayerState == PlayerState.Sitting then
			self.prePlayerState = self.curPlayerState
			self.curPlayerState = PlayerState.Standing
		elseif self.prePlayerState == PlayerState.Standing then
			self.prePlayerState = self.curPlayerState
			self.curPlayerState = PlayerState.Standing

			return true, CameraFreeLookActionStatusConfig.InFerrisBox, 0.3
		elseif self.prePlayerState == PlayerState.JiaoHu then
			self.prePlayerState = PlayerState.Standing
			self.curPlayerState = PlayerState.Standing
		end
	end

	return false
end

function M:OnUpdate()
	self:RefreshWindowMode()
	self:OnRotateCameraUpdate()
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:ClickClose()
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "CloseFerrisFarCam"
	})
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "CloseFerrisDoubleCam"
	})
	gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false, false)
	self:SendFerrisEndSignal()
	gStoreManager:GetStoreGroup("CoreHudGameplayControlStore"):StopGameplayByName("Ferris")

	L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode = -1
end

function M:ClickEnterWindow()
	if self:InClickCD() then
		return
	end

	self:SetEnterWindow(true)
end

function M:ClickExitWindow()
	if self:InClickCD() then
		return
	end

	self:SetEnterWindow(false)
end

function M:OnClose()
	self:SetEnterWindow(false)
	gFerrisMgr:SetFerrisPanelOpen(false)
	gMapUtils:ShowMiniMap()
	gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0)

	self.npcBodyType = 0
	self.isClose = true

	CTT3.Occlusion.GpuOcclusionManager.instance:SetTemoralActive(true)
	CTT3.Occlusion.GpuOcclusionManager.instance:SetLongTermActive(true)

	gLuaDataManager.guiMgr.sguiJoystick.Visible = true
end

function M:OnClickSwitch()
	if self:InClickCD() then
		return
	end

	CTT3.Occlusion.GpuOcclusionManager.instance:SetTemoralActive(false)
	CTT3.Occlusion.GpuOcclusionManager.instance:SetLongTermActive(false)
	FrameTimer.New(function ()
		if M.isClose then
			return
		end

		CTT3.Occlusion.GpuOcclusionManager.instance:SetTemoralActive(true)
	end, 2):Start()

	if L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == -1 then
		return
	end

	local mode = L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode + 1

	if mode > 2 then
		mode = 0
	end

	if gFerrisMgr.curIsDouble then
		self:SetViewMode(mode)

		return
	end

	if mode == ViewMode.First then
		if gMainMenuMgr:CheckHasClientState(ParkourStateConfig.Sit) then
			self.prePlayerState = PlayerState.Sitting
			self.curPlayerState = PlayerState.Sitting

			self:SetViewMode(mode)
		elseif gMainMenuMgr:CheckHasClientState(ParkourStateConfig.JiaoHu) then
			self.curPlayerState = PlayerState.JiaoHu

			if self.prePlayerState == PlayerState.Sitting then
				self:SetViewMode(ViewMode.Third, CameraFreeLookActionStatusConfig.InFerrisBox, 0, true)
			elseif self.prePlayerState == PlayerState.Standing then
				self:SetViewMode(mode)
			elseif self.prePlayerState == PlayerState.JiaoHu then
				self:SetViewMode(mode)
			end
		else
			self.prePlayerState = PlayerState.Standing
			self.curPlayerState = PlayerState.Standing

			self:SetViewMode(ViewMode.Third, CameraFreeLookActionStatusConfig.InFerrisBox, 0, true)
		end
	elseif mode == ViewMode.Third then
		if gMainMenuMgr:CheckHasClientState(ParkourStateConfig.Sit) then
			self.prePlayerState = PlayerState.Sitting
			self.curPlayerState = PlayerState.Sitting

			self:SetViewMode(mode, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0)
		elseif gMainMenuMgr:CheckHasClientState(ParkourStateConfig.JiaoHu) then
			self.curPlayerState = PlayerState.JiaoHu

			if self.prePlayerState == PlayerState.Sitting then
				self:SetViewMode(mode, CameraFreeLookActionStatusConfig.InFerrisBox, 0)
			elseif self.prePlayerState == PlayerState.Standing then
				self:SetViewMode(mode, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0)
			elseif self.prePlayerState == PlayerState.JiaoHu then
				self:SetViewMode(mode)
			end
		else
			self.prePlayerState = PlayerState.Standing
			self.curPlayerState = PlayerState.Standing

			self:SetViewMode(mode, CameraFreeLookActionStatusConfig.InFerrisBox, 0)
		end
	elseif mode == ViewMode.Far then
		self:SetViewMode(mode)
	end
end

function M:SetViewMode(mode, freeLookId, switchTime, isCloseFerrisFarCam)
	freeLookId = freeLookId or CameraFreeLookActionStatusConfig.InFerrisBoxSit
	switchTime = switchTime or 0
	isCloseFerrisFarCam = isCloseFerrisFarCam or false

	if mode > 2 then
		mode = 0
	end

	L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode = mode
	self.bindData.view = L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode
	gLuaDataManager.guiMgr.sguiJoystick.Visible = L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode ~= ViewMode.Far

	if L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.First then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "CloseFerrisFarCam"
		})

		local face = gCS.MyPlayerManager.PlayerUnit.FacingDirection

		if gFerrisMgr.curIsDouble then
			local yaw, pitch, fov = self:GetFirstPersonCameraDefaultValue()

			FrameTimer.New(function ()
				gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(face + yaw, pitch, 0)
				gCS.CameraDataMgr.cinemachineManager:SetFov(fov, 0, 0, true)
			end, 1):Start()
		else
			FrameTimer.New(function ()
				gCS.CameraDataMgr.cinemachineManager:SetCameraXYAxisValue(face, 0.5, 0)
				gCS.CameraDataMgr.cinemachineManager:SetFov(50, 0, 0, true)
			end, 1):Start()
		end

		local xRange = FerrisWheelConfig.CameraAngleX

		gCS.CameraDataMgr.cinemachineManager:SetLocalXRange(face - xRange, face + xRange)
		gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(FerrisWheelConfig.CameraAngleYmin, FerrisWheelConfig.CameraAngleYmax)
		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(true, false, false, switchTime)

		return
	end

	if L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.Third then
		if isCloseFerrisFarCam then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				signalKey = "CloseFerrisFarCam"
			})
		end

		if gFerrisMgr.curIsDouble then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				signalKey = "OpenFerrisDoubleCam"
			})
		else
			gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false, false, switchTime)
			gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(freeLookId, switchTime)
		end
	elseif L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.Far then
		if gFerrisMgr.curIsDouble then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				signalKey = "CloseFerrisDoubleCam"
			})
		end

		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "OpenFerrisFarCam"
		})
	end
end

function M:GetFirstPersonCameraDefaultValue()
	if gFerrisMgr.npcPid == 0 then
		return 90, 0.5, 50
	end

	if self.npcBodyType == 0 then
		local unit = gCS.SceneDataMgr.GetUnit(gFerrisMgr.npcPid)

		if not unit then
			return 90, 0.5, 50
		end

		local modelCfg = GeneralModelConfig.GetConfig(unit.CurrentModelId)

		if modelCfg then
			local bodyType = modelCfg.CameraBodyType

			if bodyType == 0 then
				bodyType = modelCfg.BodyType
			end

			self.npcBodyType = bodyType
		end
	end

	if self.npcBodyType == 0 then
		return 90, 0.5, 50
	end

	local cameraCfg = FerrisCameraFirstPersonConfig.GetConfig(self.npcBodyType)

	return cameraCfg.CameraYaw, cameraCfg.CameraPitch / 180 + 0.5, cameraCfg.CameraFov
end

function M:SendFerrisEndSignal()
	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
		signalKey = "FerrisEnd"
	})
end

function M:OnRotateCameraInput(context)
	if context.started then
		self.isRotatingCamera = true
		self.rotateParam = context:ReadValueVector2() * 20
	end

	if context.performed then
		self.rotateParam = context:ReadValueVector2() * 20
	end

	if context.canceled then
		self.isRotatingCamera = false
		self.rotateParam = nil
	end
end

function M:OnRotateCameraUpdate()
	if self.isRotatingCamera then
		gMessageManager:SendMessage(gEventConstants.GAMEPAD_CAMERA_ROTATE, self.rotateParam)
	end
end

function M:RefreshWindowMode()
	if self.isEnterWindow and not gInteractionManager.isInteractSitting or L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode ~= ViewMode.Third then
		self:SetEnterWindow(false)
	end

	if self.isEnterWindow then
		self.bindData.windowMode = 0
	elseif not gFerrisMgr.curIsDouble and gInteractionManager.isInteractSitting and L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.Third then
		self.bindData.windowMode = 1
	else
		self.bindData.windowMode = 2
	end
end

function M:SetEnterWindow(isEnter)
	if isEnter == self.isEnterWindow then
		return
	end

	self.isEnterWindow = isEnter
	gLuaDataManager.guiMgr.sguiJoystick.Visible = not isEnter

	if isEnter then
		print_notice("FerrisEnterWindow")
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FerrisEnterWindow"
		})
	else
		print_notice("FerrisExitWindow")
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "FerrisExitWindow"
		})
	end
end

function M:OnPlayerSit()
	if gFerrisMgr.curIsDouble or L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.Far then
		return
	end

	self:SetViewMode(ViewMode.Third, CameraFreeLookActionStatusConfig.InFerrisBoxSit, 0.5)
end

function M:OnPlayerStand()
	if gFerrisMgr.curIsDouble or L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.Far then
		return
	end

	if L50.L50App.Scene.GamePlayUtils.ferrisPlayViewMode == ViewMode.First then
		gCS.MyPlayerManager.PlayerUnit.forceDisableStippleAlpha = false

		Timer.New(function ()
			self:SetViewMode(ViewMode.Third, CameraFreeLookActionStatusConfig.InFerrisBox, 0.5)
		end, 0.3):Start()
	else
		self:SetViewMode(ViewMode.Third, CameraFreeLookActionStatusConfig.InFerrisBox, 0.5)
	end
end
