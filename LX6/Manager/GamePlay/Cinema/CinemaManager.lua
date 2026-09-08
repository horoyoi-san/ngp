-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Cinema\CinemaManager.lua
-- Decompiled from: 00540_CinemaManager.lua_fb0e8c4a8f7c.luajit

local MessageConfig = LTConfig.MessageConfig
local CS_CinemaManager = LX6.CinemaManager
local GameplayHudDescGroupConfig = LTConfig.GameplayHudDescGroupConfig
local CinemaCameraConfig = LTConfig.CinemaCameraConfig
local CinemaConfig = LTConfig.CinemaConfig
local GameplaySignalInwardConfig = LTConfig.GameplaySignalInwardConfig
gCinemaManager = gCinemaManager or {}
local M = {
	CameraMode = {
		["y\\xa6\\xab\\xbd\\xb2"] = 0,
		["k\\xa7\\xba\\xaa\\xb2"] = 2,
		["k\\xa7\\xb0\\xbc\\xa2"] = 1
	},
	OnInit = function (self)
		self.cameraMode = self.CameraMode.Third

		gMessageManager:AddMessageListener(gEventConstants.CINEMA_WATCH_START, function ()
			self:OnStartWatch()
		end)
		gMessageManager:AddMessageListener(gEventConstants.CINEMA_WATCH_END_START, function ()
			self:ClearPhotoState()
		end)
		gMessageManager:AddMessageListener(gEventConstants.CINEMA_TASK_WATCH_END_START, function ()
			self:ClearPhotoState()
			self:OnTaskMovieEnd()
		end)
		gMessageManager:AddMessageListener(gEventConstants.PHOTO_CONTROLLER_DESTROY, function ()
			self:OnPhotoClosed()
		end)
	end,
	HasTaskMovieAgentPid = function (self)
		return self.taskMovieAgentPid and not ulong.equals(self.taskMovieAgentPid, 0)
	end,
	ClearTaskMovieInfo = function (self)
		self.taskMovieAgentPid = nil
	end,
	DoTaskPlayMovie = function (self, locationId, movieId, agentPid)
		if not agentPid or ulong.equals(agentPid, 0) then
			return
		end

		self.taskMovieAgentPid = agentPid

		CS_CinemaManager.Instance:DoTaskPlayMovie(locationId, movieId)
	end,
	DoEndTaskWatch = function (self)
		if not self:HasTaskMovieAgentPid() then
			return false
		end

		local currentInfo = CS_CinemaManager.Instance.CurrentInfo
		local locationId = currentInfo and currentInfo.cinemaComponent.locationId or 0

		self:ClearTaskMovieInfo()
		CS_CinemaManager.Instance:DoEndTaskWatch(locationId)

		return true
	end,
	OnTaskMovieEnd = function (self)
		self:DoEndTaskWatch()
	end,
	ClearPhotoState = function (self)
		self:OnPhotoClosed()
		gPanelManager:Close(gPanelId.S_PHOTO_PANEL)
	end,
	GetCinemaNpcUnit = function (self)
		local currentInfo = CS_CinemaManager.Instance.CurrentInfo

		if currentInfo and currentInfo.uid == 0 then
			return gCS.SceneDataMgr.GetUnit(currentInfo.uid)
		end
	end,
	SendGameplayInwardSignalToCinemaNpc = function (self, signal, signalName, param)
		if not signal then
			print_debug("[CinemaManager] SendGameplayInwardSignalToCinemaNpc signal is nil", signalName)

			return
		end

		local unit = self:GetCinemaNpcUnit()

		if not unit or L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
			print_debug("[CinemaManager] SendGameplayInwardSignalToCinemaNpc unit is nil", signalName, signal)

			return
		end

		print_debug("[CinemaManager] SendGameplayInwardSignalToCinemaNpc", signalName, signal, "pid:", unit.Pid)

		if param ~= nil then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
		else
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal, param)
		end
	end,
	UpdateNpcInCameraState = function (self)
		local unit = self:GetCinemaNpcUnit()

		if not unit or L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) then
			return
		end

		local mainCamera = gCS.CameraDataMgr.MainCamera
		local x, y, z = gCS.LuaUtils.WorldToScreenPointProjected(unit.UpBodyPosition, mainCamera, 0, 0, 0)

		if z > 0 and x > 0 and x < UnityEngine.Screen.width and y > 0 and y < UnityEngine.Screen.height then
			self:SendGameplayInwardSignalToCinemaNpc(GameplaySignalInwardConfig.CinemaNpcInCamera, "CinemaNpcInCamera")
		end
	end,
	StartNpcInCameraTimer = function (self)
		if self.npcInCameraTimer then
			self.npcInCameraTimer:Stop()

			self.npcInCameraTimer = nil
		end

		self.npcInCameraTimer = Timer.New(function ()
			self:UpdateNpcInCameraState()
		end, 1, -1)

		self.npcInCameraTimer:Start()
		self:UpdateNpcInCameraState()
	end,
	OnPhotoClosed = function (self)
		if not self.isPhotoOpen then
			return
		end

		self.isPhotoOpen = false

		if self.npcInCameraTimer then
			self.npcInCameraTimer:Stop()

			self.npcInCameraTimer = nil
		end

		self:SendGameplayInwardSignalToCinemaNpc(GameplaySignalInwardConfig.CinemaPhotoClose, "CinemaPhotoClose")
	end,
	OnStartWatch = function (self)
		local currentInfo = CS_CinemaManager.Instance.CurrentInfo

		if currentInfo and currentInfo.uid == 0 then
			local unit = gCS.SceneDataMgr.GetUnit(currentInfo.uid)

			if unit then
				unit.forceDisableStippleAlpha = true
			end
		end

		gPanelManager:CheckShow(gPanelId.GAMEPLAY_HUD_PRO_PANEL, {
			groupId = GameplayHudDescGroupConfig.CINEMA,
			backCallback = function ()
				gPanelManager:Close(gPanelId.GAMEPLAY_HUD_PRO_PANEL)
				self:ExitCinema()
			end,
			switchViewCallback = function ()
				self:SwitchCameraMode()
			end
		})
	end,
	SwitchToThirdCameraMode = function (self)
		self:StopCheckStareNpc()
		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(false, Vector3.zero, Vector3.zero, 0, 0, 0)
		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false, false)
	end,
	SwitchToFirstCameraMode = function (self)
		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(false, Vector3.zero, Vector3.zero, 0, 0, 0)

		local face = gCS.MyPlayerManager.PlayerUnit.FacingDirection
		local xRange = CinemaConfig.CameraAngleX

		gCS.CameraDataMgr.cinemachineManager:SetLocalXRange(face - xRange, face + xRange)
		gCS.CameraDataMgr.cinemachineManager:SetLocalYRange(CinemaConfig.CameraAngleYmin, CinemaConfig.CameraAngleYmax)
		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(true, false, false)
		self:TryStartStareCheck()
	end,
	SwitchToFixedCameraMode = function (self)
		self:StopCheckStareNpc()

		local currentInfo = CS_CinemaManager.Instance.CurrentInfo

		if not currentInfo then
			return
		end

		local cinemaId = currentInfo.cinemaComponent.cinemaId
		local cinemaCfg = CinemaConfig.GetConfig(cinemaId)
		local cameraId = cinemaCfg.CameraSets ~= 0 and 1 or cinemaCfg.CameraSets
		local cameraCfg = CinemaCameraConfig.GetConfig(cameraId)
		local pos = Vector3(cameraCfg.PositionX, cameraCfg.PositionY, cameraCfg.PositionZ)
		local euler = Vector3(cameraCfg.RotationX, cameraCfg.RotationY, cameraCfg.RotationZ)

		gCS.CameraDataMgr.cinemachineManager:EnableFixCamera(true, pos, euler, cameraCfg.CameraFov, LX6.Cinemachine.EVcamPriority.GamePlay, 0)
		gCS.CameraDataMgr.cinemachineManager:SwitchFirstPersonWithBodyCamera(false, false, false)
	end,
	SwitchCameraMode = function (self)
		self.cameraMode = (self.cameraMode + 1) % (self.CameraMode.Fixed + 1)

		if self.cameraMode ~= self.CameraMode.Third then
			self:SwitchToThirdCameraMode()
		elseif self.cameraMode ~= self.CameraMode.First then
			self:SwitchToFirstCameraMode()
		else
			self:SwitchToFixedCameraMode()
		end
	end,
	ExitCinema = function (self)
		local currentInfo = CS_CinemaManager.Instance.CurrentInfo

		if currentInfo and currentInfo.uid == 0 then
			local unit = gCS.SceneDataMgr.GetUnit(currentInfo.uid)

			if unit then
				unit.forceDisableStippleAlpha = false
			end
		end

		self:SwitchToThirdCameraMode()

		if not self:DoEndTaskWatch() then
			CS_CinemaManager.Instance:DoEndWatch()
		end
	end,
	TryStartStareCheck = function (self)
		if self.cameraMode == self.CameraMode.First then
			print_debug("[CinemaManager] TryStartStareCheck 跳过: 非第一人称模式")

			return
		end

		if self.stareUnitId then
			print_debug("[CinemaManager] TryStartStareCheck 跳过: 已在检测中")

			return
		end

		if self.stareCDEndTime and gLogicTime.time >= self.stareCDEndTime then
			print_debug("[CinemaManager] TryStartStareCheck 跳过: CD中, 剩余", self.stareCDEndTime - gLogicTime.time)

			return
		end

		local currentInfo = CS_CinemaManager.Instance.CurrentInfo
		local unitId = currentInfo and currentInfo.uid

		if not unitId or unitId ~= 0 then
			print_debug("[CinemaManager] TryStartStareCheck 跳过: 没有邀请的NPC")

			return
		end

		print_debug("[CinemaManager] TryStartStareCheck 开始检测, 注视时长:", CinemaConfig.StareTime)
		self:StartCheckStareNpc(unitId, CinemaConfig.StareTime, function ()
			print_debug("[CinemaManager] 注视完成, 进入CD:", CinemaConfig.StareTimeCD)
			self:OnStareSuc()

			self.stareCDEndTime = gLogicTime.time + CinemaConfig.StareTimeCD
			self.stareCDDelay = gLuaTimeMgrUtils.Delay(function ()
				self.stareCDDelay = nil

				print_debug("[CinemaManager] CD结束, 尝试重新检测")
				self:TryStartStareCheck()
			end, CinemaConfig.StareTimeCD)
		end)
	end,
	StartCheckStareNpc = function (self, unitId, duration, callback)
		self:StopCheckStareNpc()

		self.stareUnitId = unitId
		self.stareDuration = duration
		self.stareCallback = callback
		self.stareStartTime = nil

		print_debug("[CinemaManager] StartCheckStareNpc npcId:", unitId, "时长:", duration)
		gLuaClient:RegisterDynamicUpdate("gCinemaManager", self)
	end,
	OnUpdate = function (self)
		if not self.stareUnitId then
			return
		end

		local unit = gCS.SceneDataMgr.GetUnit(self.stareUnitId)

		if not unit then
			return
		end

		local mainCamera = gCS.CameraDataMgr.MainCamera
		local upBodyPos = unit.UpBodyPosition
		local headPos = unit.HeadPos

		if gCS.LuaUtils.IsInCameraView(mainCamera, upBodyPos) or gCS.LuaUtils.IsInCameraView(mainCamera, headPos) then
			if not self.stareStartTime then
				self.stareStartTime = gLogicTime.time
			elseif self.stareDuration < gLogicTime.time - self.stareStartTime then
				local cb = self.stareCallback

				self:StopCheckStareNpc()
				print_debug("[CinemaManager] 注视成功")

				if cb then
					cb()
				end
			end
		else
			self.stareStartTime = nil
		end
	end,
	StopCheckStareNpc = function (self)
		self.stareUnitId = nil
		self.stareDuration = nil
		self.stareCallback = nil
		self.stareStartTime = nil

		if self.stareCDDelay then
			gLuaTimeMgrUtils.CancelUnitDelay(self.stareCDDelay)

			self.stareCDDelay = nil
		end

		gLuaClient:UnregisterDynamicUpdate("gCinemaManager")
	end,
	OnStareSuc = function (self)
		gReliableRpcManager:RegisterRPC(gClientToGameSceneDelegate.AskCinemaTriggerGazeNpc, function (err)
			if err == MessageConfig.Ok then
				print_error("[CinemaManager] AskCinemaTriggerGazeNpc 失败, err:", err)
			end
		end)
	end,
	InteractionPanel_OnClickBtnPhoto = function (self)
		self.isPhotoOpen = true

		self:StartNpcInCameraTimer()
		gTakePhotoUtils.TryTakePhoto(nil, {
			["\\xd0\\xc82'\\xf4"] = true
		})
		gLuaTimeMgrUtils.Delay(function ()
			self:SendGameplayInwardSignalToCinemaNpc(GameplaySignalInwardConfig.CinemaTakePhoto, "CinemaTakePhoto")
		end, 0.5)
	end
}
gCinemaManager = M
