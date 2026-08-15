local DanceConfig = LTConfig.DanceConfig
local AnimationCurveConfig = LTConfig.AnimationCurveConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local static_prop = {
	haveDiscoAreaTrigger = false,
	discoStopHigh = false,
	curDiscoTime = 0,
	leaveDiscoAreaTime = 0,
	discoHigh = false,
	discoIndoorId = -1,
	discoEndLongPressHigh = false,
	lostBeatChecked = false,
	closePanelChecked = false,
	discoEndTime = 0,
	discoStartTime = 0,
	MyDanceState = -1,
	lostBeat = true,
	lostPressLargeBeat = -1,
	clickTime = -1,
	noBeatChecked = false,
	isLongPress = false,
	discoUp = false,
	isPlaying = false,
	discoActionGroup = 0,
	timeBetweenBeats = 0.6,
	curBeatNum = 0,
	beatTime = -2,
	enterDiscoAreaTime = 0,
	discoPlayTime = 0,
	discoDown = false,
	musicHigh = false,
	isInLongPressEndCheck = false,
	DanceState = {
		Hot = 3,
		Enter = 1,
		Light = 2,
		Max = 4
	},
	timeRadiusFront = DanceConfig.HitMsDeviation.hitmstBefore / 1000,
	timeRadiusBelow = DanceConfig.HitMsDeviation.hitmsBehind / 1000,
	fitBeatAddPoint = DanceConfig.BitProgressChange.beatAddProgress,
	lostBeatSubtractPoint = DanceConfig.BitProgressChange.bitLostProgress * -1
}
C_BengdiActionManager = DefClass("C_BengdiActionManager", C_BengdiActionManager)
local M = C_BengdiActionManager

function M:ctor()
	for key, value in pairs(static_prop) do
		self[key] = value
	end

	gMessageManager:AddMessageListener(gEventConstants.SPIRIT_ENTER_DISCO_AREA, self.OnSpiritEnterDiscoArea)
	gMessageManager:AddMessageListener(gEventConstants.SPIRIT_LEAVE_DISCO_AREA, self.OnSpiritLeaveDiscoArea)
	gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY, self.OnChangeIndoorMap)
	gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.OnDialogEnd)
	gMessageManager:AddMessageListener(gEventConstants.ON_INVITE_NPC_SUCCESS, self.OnBengDiCrateNpcSuccess)
end

function M.OnSpiritEnterDiscoArea()
	if gBengdiActionManager.haveDiscoAreaTrigger then
		return
	end

	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceStyle, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceState, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceUpperLayer, 0)
	print_debug("Disco-OnSpiritEnterDiscoArea进入蹦迪区域")

	gBengdiActionManager.haveDiscoAreaTrigger = true
	gBengdiActionManager.enterDiscoAreaTime = gCS.TimeManager.ServerUnixTime
	gBengdiActionManager.discoIndoorId = gMapManager.IndoorId
end

function M.OnSpiritLeaveDiscoArea()
	if gBengdiActionManager.haveDiscoAreaTrigger then
		print_debug("Disco-OnSpiritLeaveDiscoArea离开蹦迪区域")

		gBengdiActionManager.leaveDiscoAreaTime = gCS.TimeManager.ServerUnixTime
		local standInDiscoAreaTime = gBengdiActionManager.leaveDiscoAreaTime - gBengdiActionManager.enterDiscoAreaTime

		if gBengdiActionManager.enterDiscoAreaTime <= 0 then
			standInDiscoAreaTime = gBengdiActionManager.discoPlayTime
		end

		gBengdiActionManager:SettleDiscoReward(standInDiscoAreaTime, gBengdiActionManager.discoPlayTime)

		local min = math.floor(standInDiscoAreaTime / 60)
		local sec = standInDiscoAreaTime % 60

		print_debug("Disco-在蹦迪区域停留的时长:", gString.Format("%02d:%02d", min, sec))

		gBengdiActionManager.leaveDiscoAreaTime = 0
		gBengdiActionManager.enterDiscoAreaTime = 0
		gBengdiActionManager.discoPlayTime = 0
		gBengdiActionManager.haveDiscoAreaTrigger = false
		gBengdiActionManager.inviteNpcPid = nil
	end
end

function M.OnBengDiCrateNpcSuccess(_, pid)
	if gBengdiActionManager.haveDiscoAreaTrigger then
		gBengdiActionManager.inviteNpcPid = pid
	end
end

function M.OnChangeIndoorMap()
	if gMapManager.IndoorId ~= gBengdiActionManager.discoIndoorId then
		gBengdiActionManager.OnSpiritLeaveDiscoArea()
	end
end

function M:OnDiscoStart(soundId)
	self.finishDialogId = nil
	local AudioManager = LX6.Audio.AudioManager.Instance
	self.MyDanceState = -1
	self.discoPlayInitSuccess = false

	function self.musicBitCallBack(info)
		self.timeBetweenBeats = info.segmentInfo_fBeatDuration
		self.lostBeatChecked = false
		self.beatTime = self.curDiscoTime

		if self.MyDanceState ~= self.DanceState.Max then
			gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_BEAT, info)
		end

		self.curBeatNum = self.curBeatNum + 1

		if self.isInLongPressEndCheck and math.floor(self.curBeatNum / 4) - self.lostPressLargeBeat >= 2 and self.isLongPress == false then
			self:OnPressButtonEndAndLargeBeatEnd()
		end
	end

	function self.musicHighCallBack(info)
		gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_HIGH_STATUS_CHANGE, info)
	end

	local C_SoundDataList = AudioManager:GetSoundInstanceByTid(soundId)

	if C_SoundDataList then
		local list = C_SoundDataList:ToTable()

		if list and #list >= 1 then
			self.C_SoundData = list[1]

			self.C_SoundData:AddMusicBeatFun(self.musicBitCallBack)
			self.C_SoundData:AddMusicCueFun(self.musicHighCallBack)
			print_debug("Disco- 绑定鼓点消息")
		else
			print_error("Disco- BengdiActionManager-没有音乐，故理论上打不开页面！soundId : ", soundId)
			gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_LISTENER_ADDED, false)
		end
	end

	self:StartRecordDiscoPlayTime()
	gBengdiActionManager.OnSpiritEnterDiscoArea()
	self:UpdateDiscoSensitivity()

	self.discoPlayInitSuccess = true
end

function M:StartRecordDiscoPlayTime()
	self.discoStartTime = gCS.TimeManager.ServerUnixTime
end

function M:OnPlayerClick()
	self.clickTime = self.curDiscoTime

	if self.curDiscoTime - self.beatTime < self.timeRadiusBelow and self.curDiscoTime - self.beatTime > 0 and self.lostBeat then
		self.lostBeat = false

		return true
	elseif self.beatTime - self.clickTime < 0 and self.beatTime - self.clickTime + self.timeBetweenBeats <= self.timeRadiusFront and self.beatTime - self.clickTime + self.timeBetweenBeats >= 0 then
		self.lostBeat = false

		return true
	end

	return false
end

function M:OnPressButtonEndAndLargeBeatEnd()
	print("OnPressButtonEndAndLargeBeatEnd ")

	self.discoStopHigh = true
	self.isInLongPressEndCheck = false

	if self.closePanelChecked then
		self.MyDanceState = self.DanceState.Hot

		self:OnDiscoEnd()
	end
end

function M:OnHighPressEnd()
	self.isInLongPressEndCheck = true

	if math.floor(self.curBeatNum / 4) - self.lostPressLargeBeat >= 2 or self.lostPressLargeBeat < 0 then
		self.lostPressLargeBeat = math.floor(self.curBeatNum / 4)
	end

	self.isLongPress = false
end

function M:OnDiscoEnd()
	if self.isLongPress then
		self:OnHighPressEnd()
	end

	if self.MyDanceState ~= self.DanceState.Max then
		gBengdiActionManager.isPlaying = false

		gMessageManager:SendMessage(gEventConstants.DISCO_PLAY_FINISH)

		self.discoStopHigh = false
		self.isPlaying = false
		self.discoActionGroup = 0

		if self.C_SoundData then
			self.C_SoundData:RemoveMusicBeatFun(self.musicBitCallBack)
			self.C_SoundData:RemoveMusicCueFun(self.musicHighCallBack)
		end

		self.MyDanceState = self.DanceState.Enter
		self.clickTime = -1

		gCS.CameraDataMgr.cinemachineManager:SetNormalFreeLookData(0.5, nil, 5)
		gCS.CameraDataMgr.cinemachineManager:SmoothNoDampFollowBall(gCurveUtils.GetCacheCurve(AnimationCurveConfig.LookAtIKWeightFadeInCurve), 0.7)

		self.discoEndTime = gCS.TimeManager.ServerUnixTime
		local curPlayTime = self.discoEndTime - self.discoStartTime

		if not self.discoPlayInitSuccess then
			curPlayTime = 0
		end

		print("disco-在蹦迪区域游玩的新增时长:", gString.Format("%02d:%02d", curPlayTime / 60, curPlayTime % 60))

		self.discoPlayTime = self.discoPlayTime + curPlayTime

		print("disco-在蹦迪区域游玩的累计时长:", gString.Format("%02d:%02d", self.discoPlayTime / 60, self.discoPlayTime % 60))

		if not self.haveDiscoAreaTrigger then
			self.OnSpiritLeaveDiscoArea()
		end
	end

	self.closePanelChecked = true
	self.isLongPress = false

	print_notice("蹦迪BengDi 结束  ")
end

function M:PlayFinishDialog()
	local danceNpcId = self:GetInviteDanceNpcId()

	if danceNpcId then
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
		self.finishDialogId = danceNpcCfg and danceNpcCfg.Dialog_DanceOverBye[1]

		if self.finishDialogId and self.discoPlayInitSuccess then
			gDialogManager:ShowGeneralDialog(self.finishDialogId, gDialogSource.BengDi, nil, nil)
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				signalKey = "DiscoPlayFinishDialog"
			})
		else
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				signalKey = "DiscoDanceMultiFinish"
			})
		end
	end
end

function M:SettleDiscoReward(stayTime, danceTime)
	local playResult = {
		PlayType = UX.Game.UrbanGamePlayType.Dance,
		DancePlayResult = {
			StayElapsedTime = stayTime,
			PlayElapsedTime = danceTime
		}
	}

	gClientToGameDelegate:AskCompleteUrbanPlay(playResult)
end

function M:UpdateDiscoSensitivity()
	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local spiritUrbanAttr = gSpiritManager:GetUrbanAttr(tid)
	self.fitBeatAddPoint = Formula_cs:CalLivehouseNoteSensitivity(spiritUrbanAttr, DanceConfig.BitProgressChange.beatAddProgress)
end

function M:OnActionEnd(unit, cfg)
	if self.discoEndLongPressHigh and cfg.discoType == 1 then
		self.discoEndLongPressHigh = false

		gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_STATE_HIGH_END)
	end
end

function M:PlayInviteTimeline(timelineName, transform, callback)
	local danceNpcId = self:GetInviteDanceNpcId()
	local timelineData = gTimelineManager:Timeline_CreateTimelineData()

	if transform then
		timelineData.pos = transform.position
		timelineData.rot = transform.eulerAngles
	end

	local npcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
	local dialogIdList = npcCfg.Dialog_tl
	local modelName = npcCfg.TimelineModelName
	timelineData.dynamicActorInfos = {
		modelName
	}
	timelineData.dynamicDialogIds = dialogIdList
	local bindInfoList = {}
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteNpcPid, modelName, nil)

	table.insert(bindInfoList, c_bindInfo)

	timelineData.bindUnitInfos = bindInfoList

	if npcCfg.TLPersonality > 0 then
		timelineData.dynamicPersonalityTypes = {
			npcCfg.TLPersonality
		}
	end

	gTimelineManager:Timeline_LoadAndPlay(timelineName, timelineData)

	function timelineData.onFinishCb()
		if callback then
			callback:DynamicInvoke()
		end
	end
end

function M:GetInviteAgentId()
	local npcUnit = self.inviteNpcPid and gCS.SceneDataMgr.GetUnit(self.inviteNpcPid)
	local agentId = npcUnit and npcUnit.NpcId

	return agentId
end

function M:GetInviteDanceNpcId()
	local agentId = self:GetInviteAgentId()
	local count = LTConfig.DanceDanceNPCConfig.count

	for i = 0, count - 1 do
		local npcCfg = LTConfig.DanceDanceNPCConfig.LoadAt(i)
		local npcId = npcCfg.Npcid
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

		if agentId == npcCultivationCfg.BengdiNpcid then
			return npcCfg.Id
		end
	end
end

function M:GetDanceNpcId(npcCultivationId)
	local count = LTConfig.DanceDanceNPCConfig.count

	for i = 0, count - 1 do
		local npcCfg = LTConfig.DanceDanceNPCConfig.LoadAt(i)
		local npcId = npcCfg.Npcid

		if npcId == npcCultivationId then
			return npcCfg.Id
		end
	end
end

function M:SetAnimationSpeed(unit, layerIndex, clipLength)
	local speed = clipLength / (60 / LTConfig.DanceConfig.DanceBPM * 4 * 8)

	gCS.AnimationManager.SetStateSpeed(unit, layerIndex, speed)
end

function M.OnDialogEnd(_, dialogId)
	if gBengdiActionManager.haveDiscoAreaTrigger and dialogId == gBengdiActionManager.finishDialogId then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			signalKey = "DiscoDanceMultiFinish"
		})

		gBengdiActionManager.finishDialogId = nil
	end
end

function M:GetInviteNpcUnit()
	return self.inviteNpcPid and gCS.SceneDataMgr.GetUnit(self.inviteNpcPid)
end

gBengdiActionManager = gBengdiActionManager or C_BengdiActionManager.new()
