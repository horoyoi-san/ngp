local ExercisesConfig = LTConfig.GymExercisesConfig
local GymConfig = LTConfig.GymConfig
local ProfileManager = LX6.Engine.ProfileManager
local GameplayEvent = MuGenStates.Logic.GameplayEvent
local MyPlayerManager = gCS.MyPlayerManager
local StaticProps = {
	EXERCISE_STAGE = {
		EXERCISE = 2,
		SELECT = 1,
		ENDING = 3,
		NONE = 0
	},
	EXERCISE_TYPE = {
		SQUAT = 2,
		OLD_SITUP = 99,
		BENCH_PRESS = 3,
		SITUP = 1,
		RUN = 4
	},
	EXERCISE_RATING = {
		BAD = 3,
		GREAT = 2,
		GOOD = 1,
		NONE = 0
	}
}
C_GymManager = DefClass("C_GymManager", C_GymManager, nil, StaticProps)
local M = C_GymManager

function M:ctor()
	self.exerciseStage = M.EXERCISE_STAGE.NONE
	self.curGymId = nil
	self.curExerciseId = nil
	self.curExerciseCfg = nil
	self.curExerciseType = nil
	self.curExerciseTimeline = nil
	self.curGamePlayTransitionType = nil
	self.curGamePanel = nil
	self.isSetFreeLook = false
	self.endCameraId = 0
	self.beginPanelDuration = 0.7
	self.type2mode = {
		[M.EXERCISE_TYPE.OLD_SITUP] = 5,
		[M.EXERCISE_TYPE.SQUAT] = 6,
		[M.EXERCISE_TYPE.SITUP] = 5
	}
	self.exercise2profileList = {
		[87003502.0] = "GymSitupPlayedPidList",
		[87003504.0] = "GymSquatPlayedPidList",
		[87003505.0] = "GymRunPlayedPidList",
		[87003506.0] = "GymBenchPressPlayedPidList"
	}
	self.signals = {
		SU_DownNormal = false,
		SU_Up = false,
		SU_DownBreak = false,
		Exit = false,
		SQ_DoAction = false,
		SU_DownOver = false,
		Settle = false
	}
	self.freeLookTimer = nil
	self.preStartTimer = nil
	self.endWaitTimer = nil
	self.STATE_TREE_EVENT = {
		EXIT_SQUAT = 6,
		ENTER_BENCH_PRESS_END = 1,
		ENTER_RUN_END = 7,
		ENTER_SQUAT_LOOP = 5,
		EXIT_BENCH_PRESS = 3,
		ENTER_BENCH_PRESS_LOOP = 2,
		ENTER_RUN_LOOP = 10,
		EXIT_RUN = 12,
		ENTER_RUN_OTHER_LOOP = 9,
		ENTER_SQUAT_END = 4,
		EXIT_RUN_LOOP = 11,
		ENTER_RUN_FIRST_LOOP = 8,
		NONE = 0
	}
end

function M:Exercise1p(gymId)
	return
end

function M:Exercise2p(gymId)
	return
end

function M:ExerciseDirectly(gymId, exerciseId, cameraIds, endCameraId, hideExitBtn)
	if type(cameraIds) == "string" then
		if not string.is_null_or_empty(cameraIds) then
			cameraIds = string.split(cameraIds, ",")

			for i = 1, #cameraIds do
				cameraIds[i] = tonumber(cameraIds[i])
			end
		else
			cameraIds = {}
		end

		gymId = tonumber(gymId)
		exerciseId = tonumber(exerciseId)
		endCameraId = tonumber(endCameraId)
	elseif type(cameraIds) ~= "table" then
		cameraIds = cameraIds:ToTable()
	end

	self:PreStartExerciseCheck(gymId, exerciseId, cameraIds, endCameraId, hideExitBtn)
end

function M:ClearSignals()
	for k, _ in pairs(self.signals) do
		self.signals[k] = false
	end
end

function M:GetSignal(key)
	local keys = table.keys(self.signals)

	if table.contains(keys, key) then
		if self.signals[key] then
			self.signals[key] = false

			return true
		end

		return false
	else
		print_error("GymManager没有相应动作信号，key=", key)
	end

	return false
end

function M:SetSignal(key)
	local keys = table.keys(self.signals)

	if table.contains(keys, key) then
		if self.signals[key] then
			print_warn("重复设置GymManager动作信号，key=", key)

			return
		end

		self.signals[key] = true
	else
		print_error("GymManager没有相应动作信号，key=", key)
	end
end

function M:IsGymStartGame()
	return self.exerciseStage == M.EXERCISE_STAGE.EXERCISE or self.curGamePanel ~= nil
end

function M:IsGymInGame()
	return self.exerciseStage == M.EXERCISE_STAGE.EXERCISE and self.curGamePanel ~= nil
end

function M:IsGymSquat()
	return self:IsGymInGame() and self.curExerciseType == M.EXERCISE_TYPE.SQUAT
end

function M:IsGymNewSitup()
	return self:IsGymInGame() and self.curExerciseType == M.EXERCISE_TYPE.SITUP
end

function M:IsGymSitupBeginUp()
	return self:IsGymNewSitup() and self:GetSignal("SU_Up")
end

function M:IsGymSitupDownBreak()
	return self:IsGymNewSitup() and self:GetSignal("SU_DownBreak")
end

function M:IsGymSitupDownNormal()
	return self:IsGymNewSitup() and self:GetSignal("SU_DownNormal")
end

function M:IsGymSitupDownOver()
	return self:IsGymNewSitup() and self:GetSignal("SU_DownOver")
end

function M:IsGymSquatDoAction()
	return self:IsGymSquat() and self:GetSignal("SQ_DoAction")
end

function M:IsGymSettleExercise()
	return self:GetSignal("Settle")
end

function M:IsGymExitExercise()
	return self:GetSignal("Exit")
end

function M:OnBeforeSwitchScene(switchType)
	if self.exerciseStage ~= M.EXERCISE_STAGE.NONE then
		self:InterruptExercise()
	end
end

function M:OnActionChange(actionKey)
	local actionTime = gCS.AnimationManager.AnimatorGetAnimationTime(gCS.MyPlayerManager.PlayerUnit, actionKey, false, true)

	if self.curGamePanel ~= nil and self.curExerciseType == M.EXERCISE_TYPE.SITUP then
		self.curGamePanel:OnActionChange(actionTime)
	end
end

function M:ClearCurData()
	self.curGamePanel = nil
	self.curGymId = nil
	self.curGymCfg = nil
	self.curExerciseId = nil
	self.curExerciseCfg = nil
	self.curExerciseType = nil
	self.curExerciseTimeline = nil
	self.curGamePlayTransitionType = nil
	self.isSetFreeLook = false
	self.endCameraId = 0
end

function M:PreStartExerciseCheck(gymId, exerciseId, cameraIds, endCameraId, hideExitBtn)
	if self:IsGymStartGame() then
		return
	end

	if self.endWaitTimer then
		self.endWaitTimer:Stop()

		self.endWaitTimer = nil
	end

	self:ClearSignals()
	self:ClearCurData()

	if gymId == nil or exerciseId == nil then
		print_error("传入的gymId或exerciseId为空")

		return
	end

	if type(gymId) ~= "number" or type(exerciseId) ~= "number" then
		print_error("传入的gymId或exerciseId不是number类型")

		return
	end

	if exerciseId == 87003501 then
		print_error("旧版深蹲已经不支持！")

		return
	end

	self.curGymId = gymId
	self.curGymCfg = GymConfig.GetConfig(gymId)

	if not self.curGymCfg then
		print_error("找不到对应的GymCfg，gymId=", gymId)

		return
	end

	self.curExerciseId = exerciseId
	self.curExerciseCfg = ExercisesConfig.GetConfig(exerciseId)

	if not self.curExerciseCfg then
		print_error("找不到对应的ExerciseCfg，exerciseId=", exerciseId)

		return
	end

	self.curExerciseType = self:GetExerciseTypeByCfg(self.curExerciseCfg)
	self.exerciseStage = M.EXERCISE_STAGE.EXERCISE

	gPanelManager:SetVisibleMode(LX6.Manager.VisibleControlType.Gameplay, LX6.Manager.VisibleMode.Front)

	if self.curExerciseType == M.EXERCISE_TYPE.SITUP then
		if self.freeLookTimer then
			self.freeLookTimer:Stop()
		end

		self.freeLookTimer = Timer.New(function ()
			if self.exerciseStage == M.EXERCISE_STAGE.EXERCISE and not self.curGamePanel then
				gCS.CameraDataMgr.cinemachineManager:SetFreeLookDataByPose(34, 2, nil)

				self.isSetFreeLook = true
			end
		end, 1, nil, true):Start()
	end

	if self.preStartTimer then
		self.preStartTimer:Stop()
	end

	local deltaTime = self.curExerciseType == M.EXERCISE_TYPE.RUN and 1 or 2
	self.preStartTimer = Timer.New(function ()
		if self.exerciseStage == M.EXERCISE_STAGE.EXERCISE and not self.curGamePanel then
			gPanelManager:RemoveVisibleMode(LX6.Manager.VisibleControlType.Gameplay)
			self:StartExercise(gymId, exerciseId, cameraIds, endCameraId, hideExitBtn)
		end
	end, deltaTime, nil, true):Start()
end

function M:CheckIsPlayed(exerciseId)
	ProfileManager.LoadGamePlayProperty()

	local GamePlayProfile = ProfileManager.gamePlayProfile
	local pid = ulong.tostring(gPlayerManager.infoLogin.pid)
	local listName = self.exercise2profileList[exerciseId]
	local pidList = GamePlayProfile[listName] or {}
	pidList = not string.is_null_or_empty(pidList) and string.split(pidList, ",") or {}
	local isPlayed = pidList and table.contains(pidList, pid)

	if not isPlayed then
		table.insert(pidList, pid)

		local str = table.concat(pidList, ",")
		GamePlayProfile[listName] = str

		ProfileManager.SaveGamePlayProperty()
	end

	return isPlayed
end

function M:StartExercise(gymId, exerciseId, cameraIds, endCameraId, hideExitBtn)
	self.endCameraId = endCameraId

	if self.curExerciseType == M.EXERCISE_TYPE.OLD_SITUP then
		self:InvokeTimeline(self.curGymId, self.curExerciseCfg)
	end

	gClientToGameDelegate:AskStartGymExercise(exerciseId)

	local exerciseType2gameplayType = {
		[M.EXERCISE_TYPE.SITUP] = gGamePlayTransitionMgr.GamePlayType.Situp
	}
	self.curGamePlayTransitionType = exerciseType2gameplayType[self.curExerciseType]

	if self.curGamePlayTransitionType then
		gGamePlayTransitionMgr:EnterGamePlay(self.curGamePlayTransitionType)
	end

	gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
		gameplayType = "Fitness",
		params = {
			type = self.curExerciseType,
			cfg = self.curExerciseCfg,
			cameraIds = cameraIds,
			duration = self.curExerciseCfg.GamePlayTime or 30,
			hideExitBtn = hideExitBtn
		}
	})
end

function M:SettleExercise(data, waitTime)
	self.exerciseStage = M.EXERCISE_STAGE.ENDING

	gPanelManager:Close(gPanelId.S_GAMEPLAY_HUD_PANEL)

	if self.curExerciseType == M.EXERCISE_TYPE.OLD_SITUP then
		gTimelineManager:Timeline_JumpTo(self.curExerciseTimeline, "endClip")
	end

	self:ExitExercise(data, waitTime)
end

function M:ExitExercise(data, waitTime)
	if data then
		local score = self:CalcTotalScore(data.result, self.curExerciseCfg)
		local level = self:CalcLevelEnum(score, self.curExerciseCfg)
		local playResult = {
			PlayType = UX.Game.UrbanGamePlayType.Gym,
			GymPlayResult = {
				Level = level,
				ExerciseId = self.curExerciseId,
				Score = score
			}
		}

		gClientToGameDelegate:AskCompleteUrbanPlay(playResult)
	end

	if self.isSetFreeLook then
		gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5, nil)

		self.isSetFreeLook = false
	end

	self.exerciseStage = M.EXERCISE_STAGE.NONE

	self:ClearSignals()
	self:SetSignal("Exit")

	local type = self.curGamePlayTransitionType

	local function endWaitFunc()
		if type then
			gGamePlayTransitionMgr:EndGamePlay(type)
		end
	end

	if self.curExerciseType == M.EXERCISE_TYPE.SITUP then
		if waitTime then
			self.endWaitTimer = Timer.New(function ()
				gGamePlayTransitionMgr:CheckSwitchAction()
				endWaitFunc()
			end, waitTime):Start()
		else
			endWaitFunc()
		end
	else
		local exerciseType2GameEventType = {
			[M.EXERCISE_TYPE.BENCH_PRESS] = GameplayEvent.GymExitBenchPress,
			[M.EXERCISE_TYPE.SQUAT] = GameplayEvent.GymExitSquat,
			[M.EXERCISE_TYPE.RUN] = GameplayEvent.GymExitRun
		}
		local exitEvent = data and data.exitGameplayEvent
		local exitGamePlayGameplayEvent = exitEvent or self.curExerciseType and exerciseType2GameEventType[self.curExerciseType]

		if exitGamePlayGameplayEvent then
			gCS.LogicStateMachineManager.SendGameplayEvent(MyPlayerManager.PlayerUnit, exitGamePlayGameplayEvent)
		end
	end
end

function M:InterruptExercise()
	if self.freeLookTimer then
		self.freeLookTimer:Stop()

		self.freeLookTimer = nil
	end

	if self.preStartTimer then
		self.preStartTimer:Stop()

		self.preStartTimer = nil
	end

	self:SettleExercise(nil)
end

function M:CalcTotalScore(result, exerciseCfg)
	local totalScore = 0

	for k, v in pairs(result) do
		if k == M.EXERCISE_RATING.BAD then
			totalScore = totalScore + v * exerciseCfg.BadPoints
		elseif k == M.EXERCISE_RATING.GOOD then
			totalScore = totalScore + v * exerciseCfg.GoodPoints
		elseif k == M.EXERCISE_RATING.GREAT then
			totalScore = totalScore + v * exerciseCfg.GreatPoints
		end
	end

	return totalScore
end

function M:CalcLevelStr(score, exerciseCfg)
	if exerciseCfg.SlevelPoint <= score then
		return "S"
	elseif exerciseCfg.AlevelPoint <= score then
		return "A"
	else
		return "B"
	end
end

function M:CalcLevelEnum(score, exerciseCfg)
	local table = {
		S = 2,
		A = 1,
		B = 0
	}

	return table[self:CalcLevelStr(score, exerciseCfg)]
end

function M:GetExerciseTypeByCfg(cfg)
	if cfg.Id == 87003500 then
		return M.EXERCISE_TYPE.OLD_SITUP
	end

	if cfg.ExerciseType == ExercisesConfig.ExerciseTypeType.Unknown then
		print_error("exerciseType未unknown， id=", cfg.Id)

		return -1
	end

	return cfg.ExerciseType
end

function M:InvokeTimeline(gymId, exerciseCfg)
	if not string.is_null_or_empty(self.curExerciseTimeline) then
		print_error("健身房已经有timeline在播放或者未清除遗留数据")

		return
	end

	local timelineName = exerciseCfg.ExerciseTimeline

	if string.is_null_or_empty(timelineName) then
		print_error("健身房找不到需要播放的timeline，exerciseId=", exerciseCfg.Id)

		return
	end

	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	timelineData.startClip = "idleLoopClip"

	gTimelineManager:Timeline_LoadAndPlay(timelineName, timelineData)

	self.curExerciseTimeline = timelineName
end

function M:HandleStateTreeAnimEvent(EventType)
	if EventType == self.STATE_TREE_EVENT.ENTER_BENCH_PRESS_LOOP then
		if self.curGamePanel and self.curGamePanel.isShow then
			self.curGamePanel:StateTreeEnterBenchPressWaitLoop()
		end
	elseif EventType == self.STATE_TREE_EVENT.EXIT_BENCH_PRESS then
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "GYM_BENCH_PRESS_EXIT")
	elseif EventType == self.STATE_TREE_EVENT.ENTER_SQUAT_LOOP then
		if self.curGamePanel and self.curGamePanel.isShow then
			self.curGamePanel:StateTreeEnterSquatWaitLoop()
		end
	elseif EventType == self.STATE_TREE_EVENT.EXIT_SQUAT then
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "GYM_SQUAT_EXIT")
	elseif EventType == self.STATE_TREE_EVENT.ENTER_RUN_FIRST_LOOP or EventType == self.STATE_TREE_EVENT.ENTER_RUN_OTHER_LOOP then
		if self.curGamePanel and self.curGamePanel.isShow then
			self.curGamePanel:StateTreeEnterRunPrepareLoop()
		end
	elseif EventType == self.STATE_TREE_EVENT.EXIT_RUN then
		gMessageManager:SendMessage(gEventConstants.SLOT_ENTITY_BROAD_CAST_SIGNAL_IN, "GYM_TREADMILL_EXIT")
	end
end

function M:GetRunStage()
	if self.curGamePanel and self.curGamePanel.isShow then
		return self.curGamePanel.runAnimSpeed
	end

	return 0
end

gGymManager = gGymManager or C_GymManager.new()
