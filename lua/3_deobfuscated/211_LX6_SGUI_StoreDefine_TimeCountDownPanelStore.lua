C_TimeCountDownPanelStore = DefClass("C_TimeCountDownPanelStore", C_TimeCountDownPanelStore, C_StoreGroup)
GroupName2Class.TimeCountDownPanelStore = C_TimeCountDownPanelStore
local M = C_TimeCountDownPanelStore
local WeatherConfig = LTConfig.WeatherConfig
local SoundConfig = LTConfig.SoundConfig
local AnimationName = {
	FadeOut = "vx_S_TimeCountDownPanel_Fadeout",
	Close = "vx_S_TimeCountDownPanel_AllClose",
	FadeIn = "vx_S_TimeCountDownPanel_Fadein"
}

function M:ctor()
	return
end

function M:OnAwake()
	return
end

function M:OnDestroy()
	gSoundMgr:StopSoundByNid(self.playVibrateSoundNid)
	gSoundMgr:StopSoundByTid(WeatherConfig.CountdownStopSoundId)

	self.videoPlayer = self.videoPlayer and self.videoPlayer:Stop()
	self.playVideoCo = coroutine.stop(self.playVideoCo)
	self.askPassingTimeCo = coroutine.stop(self.askPassingTimeCo)
	self.playAnimationCo = coroutine.stop(self.playAnimationCo)
	self.hasDestroy = true
	self.callbacks = nil
	self.hour = nil
	self.minute = nil
	self.startGameTime = nil
end

function M:OnShow(panelId, args)
	self.panelId = panelId

	self:InitModel(args)
	self:InitView()
end

function M:InitModel(args)
	self.hasDestroy = nil
	self.ignoreAskPassingTimeRpc = args.ignoreAskPassingTimeRpc
	self.startGameTime = args.startGameTime
	self.callback = args.callback
	self.hour = args.hour
	self.minute = args.minute
	self.targetGameTime = self.hour * gClientConst.SECONDS_PER_HOUR + self.minute * gClientConst.SECONDS_PER_MINUTE
	self.gameVideoId = args.gameVideoId and args.gameVideoId > 0 and args.gameVideoId
end

function M:InitView()
	self.bindData.isShowCountdown = false

	self:PlayVideo()
	gMessageManager:SendMessage(gEventConstants.START_REST, self.hour * 60 + self.minute)
end

function M:PlayVideo()
	self:PlayAnimationWithCallback(AnimationName.FadeOut, function ()
		if self.hasDestroy then
			return
		end

		if gBlackScreenManager:IsOccupied() then
			gBlackScreenManager:ClearTransition(gBlackScreenManager.setId, true)
		end

		local endCallback = self:CreateAction("OnVideoEndCallback")
		local loadedCallback = self:CreateAction("OnVideoLoadedCallback")
		local gameVideoId = self:GetTimeVideoPath()

		self.bindData.videoPlayer:PlayVideo(gameVideoId, true, endCallback, loadedCallback)
	end)
	self.bindData.videoPlayer:Init()
end

function M:GetTimeVideoPath()
	if self.gameVideoId then
		return self.gameVideoId
	end

	if gSunbathManager.isInGame then
		return WeatherConfig.TimeVideoPath_SunBath
	end

	local currentBlockId = gMapSystem:GetCurBlockId()

	if currentBlockId then
		local blockCfg = LTConfig.CollectionBlockConfig.GetConfig(currentBlockId)

		if blockCfg and blockCfg.BlockSwitchTimeVideoName > 0 then
			return blockCfg.BlockSwitchTimeVideoName
		end
	end

	return WeatherConfig.TimeVideoPath
end

function M:PlayAnimationWithCallback(animationName, callback)
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.animation, animationName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.animation, animationName)

	self.playAnimationCo = coroutine.stop(self.playAnimationCo)
	self.playAnimationCo = coroutine.start(function ()
		coroutine.wait(clipTime)

		if callback then
			callback()
		end
	end)
end

function M:OnVideoEndCallback(isPlaySuccess)
	if isPlaySuccess then
		return
	end

	self:FinishRestTime()
end

function M:OnVideoLoadedCallback()
	self:PlayVibrateSound()
	gSoundMgr:PlaySoundByTid(WeatherConfig.VideoSoundId)

	self.bindData.isShowCountdown = true

	self:PlayAnimationWithCallback(AnimationName.FadeIn)

	local totalTime = self.bindData.videoPlayer:GetDuration()
	local startGameTime = self.startGameTime
	local targetGameTime = self.targetGameTime
	local startTimeRate = startGameTime / gClientConst.SECONDS_PER_DAY
	local targetTimeRate = targetGameTime / gClientConst.SECONDS_PER_DAY
	local durationRate = (targetTimeRate + 1 - startTimeRate) % 1
	local playTime = math.max(WeatherConfig.MaxMovieTime * durationRate, WeatherConfig.MinMovieTime)
	local playTimeDelay = WeatherConfig.StayTime
	local duration = durationRate * totalTime

	self.bindData.videoPlayer:Seek(startTimeRate * totalTime)

	local speed = duration / playTime
	speed = math.max(WeatherConfig.PlayVideoMinSpeed, math.min(speed, WeatherConfig.PlayVideoMaxSpeed))

	self.bindData.videoPlayer:SetSpeed(speed)
	self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, playTime, true)
	Timer.New(function ()
		if not self.hasDestroy then
			self.SubGroup.TimeWheelScrollV2Store:StartWheel(self.startGameTime, self.targetGameTime, playTime, false)
		end
	end, 0.5):Start()

	self.autoCloseCo = coroutine.start(function ()
		coroutine.wait(playTime)
		coroutine.stop(self.playVibrateSoundCo)
		gSoundMgr:StopSoundByNid(self.playVibrateSoundNid)
		gSoundMgr:StopSoundByTid(WeatherConfig.VideoSoundId)
		gSoundMgr:PlaySoundByTid(WeatherConfig.CountdownStopSoundId)
		coroutine.wait(playTimeDelay)
		gCS.CameraDataMgr:SetMainCameraEnable(true, gPanelId.S_TIME_COUNT_DOWN_PANEL)
		self:FinishRestTime()
		Timer.New(function ()
			gSoundMgr:PlayCharacterCombineExternalVoice(SoundConfig.Char_RTC)
		end, 1.5):Start()
		coroutine.wait(1.5)
	end)

	self:CheckPlayVideoEnd(startTimeRate, targetTimeRate, totalTime)
	self:AskPassingTime(playTime)
end

function M:PlayVibrateSound()
	self.playVibrateSoundCo = coroutine.start(function ()
		while true do
			gSoundMgr:StopSoundByNid(self.playVibrateSoundNid)

			self.playVibrateSoundNid = gSoundMgr:PlaySoundByExternalSource("ExHandle_PressLong", LX6.Audio.ExternalSourceType.Motion_2D)

			coroutine.wait(2)
		end
	end)
end

function M:CheckPlayVideoEnd(startTimeRate, targetTimeRate, totalTime)
	local startTime = startTimeRate * totalTime
	local targetTime = targetTimeRate * totalTime
	local isCross = startTime > targetTime
	local threshold = WeatherConfig.ReachTimeThreshold
	self.playVideoCo = coroutine.start(function ()
		while true do
			local currentTime = self.bindData.videoPlayer:GetCurrentTime()
			local hasSeekSuccess = math.abs(currentTime - startTimeRate * totalTime) < threshold

			if hasSeekSuccess then
				break
			else
				coroutine.step()
			end
		end

		if isCross and startTime - targetTime < threshold then
			coroutine.wait(1)
		end

		while true do
			local currentTime = self.bindData.videoPlayer:GetCurrentTime()
			local reachedTarget = math.abs(currentTime - targetTime) <= threshold

			if not isCross then
				if reachedTarget then
					print_debug(("TimeCountdown IsCross False StartTime:%s, currentTime:%s, targetTime:%s"):format(self.startGameTime, currentTime, self.targetGameTime))
					self.bindData.videoPlayer:Pause()

					break
				end
			elseif currentTime < startTime and reachedTarget then
				print_debug(("TimeCountdown IsCross True StartTime:%s, currentTime:%s, targetTime:%s"):format(self.startGameTime, currentTime, self.targetGameTime))
				self.bindData.videoPlayer:Pause()

				break
			end

			coroutine.step()
		end
	end)
end

function M:AskPassingTime(playTime)
	self.askPassingTimeCo = coroutine.start(function ()
		local waitTime = playTime - 2
		waitTime = waitTime > 0 and waitTime or 0

		coroutine.wait(waitTime)

		if not self.ignoreAskPassingTimeRpc then
			if gLuaDataManager.gameStage ~= gGFConstant.GameStage.GameScene or not gCS.NetworkManager.Instance:IsServerConnected() then
				return
			end

			gClientToGameDelegate:AskPassingTime(self.hour, self.minute).Callback = function (err)
				if err ~= LTConfig.MessageConfig.Ok then
					gDisplayMessageMgr:ShowServerMessage(err)
				end

				gMessageManager:SendMessage(gEventConstants.FINISH_REST, {
					pastTime = self.targetGameTime - self.startGameTime
				})
			end
		else
			gMessageManager:SendMessage(gEventConstants.FINISH_REST, {
				pastTime = self.targetGameTime - self.startGameTime
			})
		end
	end)
end

function M:FinishRestTime()
	self.bindData.videoPlayer:Stop()

	local offsetTime = self.targetGameTime + gClientConst.SECONDS_PER_DAY - self.startGameTime
	local pastTime = 0

	if self.targetGameTime < self.startGameTime then
		pastTime = offsetTime
	else
		pastTime = self.targetGameTime - self.startGameTime
	end

	gMessageManager:SendMessage(gEventConstants.TIME_END_REST, {
		pastTime = pastTime
	})

	if WeatherConfig.ActionTime <= offsetTime % gClientConst.SECONDS_PER_DAY / 60 then
		gSoundMgr:PlaySoundByTid(WeatherConfig.AlarmMusic, nil, nil)

		if not gPlayerManager.main.bindData.isFreeClimbing and table.contains(WeatherConfig.CanTimerRestActionType, gCS.MyPlayerManager.PlayerUnit.State.nowInteractiveAction) and not gCS.MyPlayerManager.isMotorRider then
			gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, LTConfig.GameplaySignalInwardConfig.ResetTimeReaction)
		end
	end

	if type(self.callback) == "function" then
		self.callback()
	elseif type(self.callback) == "userdata" then
		self.callback:DynamicInvoke()
	end

	self:PlayAnimationWithCallback(AnimationName.Close, function ()
		gMainPhoneUtils.CloseMainPhonePanel(true)
		gCS.LuaUtils.SetStylizedHDRISkyForceUpdateAtOnce()
		gPanelManager:Close(self.panelId)
	end)
end

function M:OnClose()
	self.autoCloseCo = coroutine.stop(self.autoCloseCo)
end
