-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\Bengdi\BengdiActionManager.lua
-- Decompiled from: 00694_BengdiActionManager.lua_578b2c3ec7b4.luajit

local DanceConfig = LTConfig.DanceConfig
local AnimationCurveConfig = LTConfig.AnimationCurveConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local static_prop = {
	["\\x8a.\\xfb\\xb9w!\\xd5X\\xe9\\xfc&cN\\xc3&\\xbb\\xce"] = false,
	["\\xeaL/\\xe3\\xb9Q\\x89_\\xb7\\xbe"] = false,
	["lc\\xbeSE\\xa1\\xf1H^ssI"] = 0,
	["\n?\\x91\\xfb\\xae\\x83ᵹ\\x87\\xfc\\xf07Ǯ)\\x92\\xe7"] = 0,
	["GNjA60"] = false,
	["\\xeaL/\\xf9\\xb2N\\xaeD\\x99\\xb2"] = -1,
	["?\\xa7\\xe304\nw%0\\x983ߙ\\x86 \\xb1\\x9eΆ"] = false,
	["/%3\\xf0Q\\x9d\\xf6 \\x8b'\\xe3\\xf1\\xedq\\xff"] = false,
	["w\\xf0(\\xff,.\\xcdd,\\xf6C\\x89I\\xc3\\xe2"] = false,
	["k\\xbftC\\x97\\xfcC^ssI"] = 0,
	["\\xe3\\x93\\xef\"\\xf2\\xf8\\x9cً--"] = 0,
	["Bo\\x88vB\\xb1\\xf7t~{jI"] = -1,
	["\\xa7\\xbe\\xbfH;\\xff'"] = true,
	["\n5\\x83\\xf9\\x9b\\xb5\\xed\\xb5\\xa9\\xa4\\xdc\\xf05ø%\\x9e\\xf6"] = -1,
	["@KejE*="] = -1,
	["\\xec})\\xc4?\\xbeD\\xa2]\\xb5\\xb2"] = false,
	["\\x96'0v\\x9aq\\xcb2\\xb9\\xaa"] = false,
	["\\xdd\\xd2\\xe1"] = false,
	["JT\\eO?"] = false,
	["c\\x89\\x93\\xb0\\xfd\\xb3\\xd12\\xa61*\\xa0\r#"] = 0,
	["s\\x97\\x95\\x9d٤\\xd2>\\xac1/\\xb7\""] = 0.6,
	["POܟ\\x81\t\\xac*\\xdc\\xe5"] = 0,
	["\\xa9\\xb4\\xbf^7\\xf36"] = -2,
	["4\\x84蹃ᵹ\\x87\\xfc\\xf07Ǯ)\\x92\\xe7"] = 0,
	["\\xeaL/\\xe0\\xb7X\\x95_\\xbd\\xb3"] = 0,
	["GNjA:6"] = false,
	["NR`M60"] = false,
	["%\\x9d\\xee\nt9-\\x93':蒑\\x91\\x92ʅ"] = false,
	DanceState = {
		["\\xa6gr"] = 3,
		["h\\xa0\\xb6\\xaa\\xa4"] = 1,
		["a\\xa7\\xa5\\xa7\\xa2"] = 2,
		["\\xa3i~"] = 4
	},
	timeRadiusFront = DanceConfig.HitMsDeviation.hitmstBefore / 1000,
	timeRadiusBelow = DanceConfig.HitMsDeviation.hitmsBehind / 1000,
	fitBeatAddPoint = DanceConfig.BitProgressChange.beatAddProgress,
	lostBeatSubtractPoint = DanceConfig.BitProgressChange.bitLostProgress * -1
}
C_BengdiActionManager = DefClass("C_BengdiActionManager", C_BengdiActionManager)
local M = C_BengdiActionManager

M.ctor = function(self)
	for key, value in pairs(static_prop) do
		self[key] = value
	end

	gMessageManager:AddMessageListener(gEventConstants.SPIRIT_ENTER_DISCO_AREA, self.OnSpiritEnterDiscoArea)
	gMessageManager:AddMessageListener(gEventConstants.SPIRIT_LEAVE_DISCO_AREA, self.OnSpiritLeaveDiscoArea)
	gMessageManager:AddMessageListener(gEventConstants.MAP_CHANGE_TO_INDOOR_MAP_EARLY, self.OnChangeIndoorMap)
	gMessageManager:AddMessageListener(gEventConstants.DIALOG_END, self.OnDialogEnd)
	gMessageManager:AddMessageListener(gEventConstants.ON_INVITE_NPC_SUCCESS, self.OnBengDiCrateNpcSuccess)
	gMessageManager:AddMessageListener(gEventConstants.ON_GAMEPLAY_HUD_PANEL_EXIT_CLICK, self.OnPanelHudExitClick)
end

M.OnSpiritEnterDiscoArea = function()
	if gBengdiActionManager.haveDiscoAreaTrigger then
		return
	end

	MuGenStates.Logic.LogicStateMachineManager.RegisterSpecialTick(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPTickConfig.Disco)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceStyle, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceGroup, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceState, 0)
	MuGenStates.Logic.ABPVarManager.SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.DanceUpperLayer, 0)
	print_debug("Disco-OnSpiritEnterDiscoArea进入蹦迪区域")

	gBengdiActionManager.haveDiscoAreaTrigger = true
	gBengdiActionManager.enterDiscoAreaTime = gCS.TimeManager.ServerUnixTime
	gBengdiActionManager.discoIndoorId = gMapManager.IndoorId
end

M.OnSpiritLeaveDiscoArea = function()
	if gBengdiActionManager.haveDiscoAreaTrigger then
		MuGenStates.Logic.LogicStateMachineManager.UnregisterSpecialTick(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPTickConfig.Disco)
		print_debug("Disco-OnSpiritLeaveDiscoArea离开蹦迪区域")

		gBengdiActionManager.leaveDiscoAreaTime = gCS.TimeManager.ServerUnixTime
		local standInDiscoAreaTime = gBengdiActionManager.leaveDiscoAreaTime - gBengdiActionManager.enterDiscoAreaTime

		if gBengdiActionManager.enterDiscoAreaTime < 0 then
			standInDiscoAreaTime = gBengdiActionManager.discoPlayTime
		end

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

M.OnBengDiCrateNpcSuccess = function(_, pid)
	if gBengdiActionManager.haveDiscoAreaTrigger then
		gBengdiActionManager.inviteNpcPid = pid
	end
end

M.OnPanelHudExitClick = function(self)
	if gBengdiActionManager.haveDiscoAreaTrigger and gBengdiActionManager.discoStartTime and gBengdiActionManager.enterDiscoAreaTime then
		local discoEndTime = gCS.TimeManager.ServerUnixTime
		local discoPlayTime = discoEndTime - gBengdiActionManager.discoStartTime
		local standInDiscoAreaTime = gCS.TimeManager.ServerUnixTime - gBengdiActionManager.enterDiscoAreaTime

		gBengdiActionManager:SettleDiscoReward(standInDiscoAreaTime, discoPlayTime)
	end
end

M.OnChangeIndoorMap = function()
	if gMapManager.IndoorId == gBengdiActionManager.discoIndoorId then
		gBengdiActionManager.OnSpiritLeaveDiscoArea()
	end
end

M.OnDiscoStart = function(self, soundId)
	self.finishDialogId = nil
	local AudioManager = LX6.Audio.AudioManager.Instance
	self.MyDanceState = -1
	self.discoPlayInitSuccess = false

	self.musicBitCallBack = function(info)
		self.timeBetweenBeats = info.segmentInfo_fBeatDuration
		self.lostBeatChecked = false
		self.beatTime = self.curDiscoTime

		if self.MyDanceState == self.DanceState.Max then
			gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_BEAT, info)
		end

		self.curBeatNum = self.curBeatNum + 1

		if self.isInLongPressEndCheck and math.floor(self.curBeatNum / 4) - self.lostPressLargeBeat > 2 and self.isLongPress ~= false then
			self:OnPressButtonEndAndLargeBeatEnd()
		end
	end

	self.musicHighCallBack = function(info)
		gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_HIGH_STATUS_CHANGE, info)
	end

	local C_SoundDataList = AudioManager:GetSoundInstanceByTid(soundId)

	if C_SoundDataList then
		local list = C_SoundDataList:ToTable()

		if list and #list > 1 then
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

M.StartRecordDiscoPlayTime = function(self)
	self.discoStartTime = gCS.TimeManager.ServerUnixTime
end

M.OnPlayerClick = function(self)
	self.clickTime = self.curDiscoTime

	if self.curDiscoTime - self.beatTime >= self.timeRadiusBelow and self.curDiscoTime - self.beatTime <= 0 and self.lostBeat then
		self.lostBeat = false

		return true
	elseif self.beatTime - self.clickTime >= 0 and self.beatTime - self.clickTime + self.timeBetweenBeats < self.timeRadiusFront and self.beatTime - self.clickTime + self.timeBetweenBeats > 0 then
		self.lostBeat = false

		return true
	end

	return false
end

M.OnPressButtonEndAndLargeBeatEnd = function(self)
	print("OnPressButtonEndAndLargeBeatEnd ")

	self.discoStopHigh = true
	self.isInLongPressEndCheck = false

	if self.closePanelChecked then
		self.MyDanceState = self.DanceState.Hot

		self:OnDiscoEnd()
	end
end

M.OnHighPressEnd = function(self)
	self.isInLongPressEndCheck = true

	if math.floor(self.curBeatNum / 4) - self.lostPressLargeBeat < 2 or self.lostPressLargeBeat >= 0 then
		self.lostPressLargeBeat = math.floor(self.curBeatNum / 4)
	end

	self.isLongPress = false
end

M.OnDiscoEnd = function(self)
	if self.isLongPress then
		self:OnHighPressEnd()
	end

	if self.MyDanceState == self.DanceState.Max then
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

M.PlayFinishDialog = function(self, isTiredFinish)
	local danceNpcId = self:GetInviteDanceNpcId()

	if danceNpcId then
		local danceNpcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)

		if isTiredFinish then
			self.finishDialogId = danceNpcCfg and danceNpcCfg.Dialog_TiredOverBye[1]
		else
			self.finishDialogId = danceNpcCfg and danceNpcCfg.Dialog_DanceOverBye[1]
		end

		if self.finishDialogId and self.discoPlayInitSuccess then
			gDialogManager:ShowGeneralDialog(self.finishDialogId, gDialogSource.BengDi, nil, )
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				["PNkgO:!"] = "+?\\xa7\\xe30!r\\x9f: ޔ\\xb1:\\x98\\x9bƉ"
			})
		else
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
				["PNkgO:!"] = "+?\\xa7\\xe305}\n:\\xbb!%ٕ\\xb3:\\x97\\x9eچ"
			})
			gBengdiActionManager:ClearInviteClientNpc()
		end
	end
end

M.SettleDiscoReward = function(self, stayTime, danceTime)
	local playResult = {
		PlayType = UX.Game.UrbanGamePlayType.Dance,
		DancePlayResult = {
			StayElapsedTime = stayTime,
			PlayElapsedTime = danceTime
		}
	}

	gClientToGameDelegate:AskCompleteUrbanPlay(playResult)
end

M.UpdateDiscoSensitivity = function(self)
	local tid = gBattleSpiritMgr.currentSpiritTemplateId
	local spiritUrbanAttr = gSpiritManager:GetUrbanAttr(tid)
	self.fitBeatAddPoint = Formula_cs:CalLivehouseNoteSensitivity(spiritUrbanAttr, DanceConfig.BitProgressChange.beatAddProgress)
end

M.OnActionEnd = function(self, unit, cfg)
	if self.discoEndLongPressHigh and cfg.discoType ~= 1 then
		self.discoEndLongPressHigh = false

		gMessageManager:SendMessage(gEventConstants.DISCO_MUSIC_STATE_HIGH_END)
	end
end

M.GetInviteAgentId = function(self)
	local npcUnit = self.inviteCsUnitPid and gCS.SceneDataMgr.GetUnit(self.inviteCsUnitPid)
	local agentId = npcUnit and npcUnit.NpcId

	return agentId
end

M.GetInviteDanceNpcId = function(self)
	local agentId = self:GetInviteAgentId()
	local count = LTConfig.DanceDanceNPCConfig.count

	for i = 0, count - 1 do
		local npcCfg = LTConfig.DanceDanceNPCConfig.LoadAt(i)
		local npcId = npcCfg.Npcid
		local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

		if agentId ~= npcCultivationCfg.BengdiNpcid then
			return npcCfg.Id
		end
	end
end

M.SetAnimationSpeed = function(self, unit, layerIndex, clipLength)
	local speed = clipLength / (60 / LTConfig.DanceConfig.DanceBPM * 4 * 8)

	gCS.AnimationManager.SetStateSpeed(unit, layerIndex, speed)
end

M.OnDialogEnd = function(_, dialogId)
	if gBengdiActionManager.haveDiscoAreaTrigger and dialogId ~= gBengdiActionManager.finishDialogId then
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnReceiveSignal, {
			["PNkgO:!"] = "+?\\xa7\\xe305}\n:\\xbb!%ٕ\\xb3:\\x97\\x9eچ"
		})

		gBengdiActionManager.finishDialogId = nil

		gBengdiActionManager:ClearInviteClientNpc()
	end
end

M.InviteNpc = function(self, args)
	local gamePlayId = args.gamePlayId
	self.invitePos = args.invitePos
	self.inviteTimelinePos = args.timelinePos
	self.playerPos = args.playerPos
	self.inviteTimeline = args.timelineName

	if gamePlayId and gamePlayId <= 0 then
		gClientToGameDelegate:AskSimulationInviteNpc(gamePlayId).Callback = function (err)
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.StartInviteAction = function(self, npcCultivationId, gameplayId)
	local clientNpcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)

	self:ClearInviteClientNpc()
	self:GetRandomFashionList(npcCultivationId, function (fashionList)
		local inviteCsUnit = gNpcInviteManager:InviteClientNpcForGamePlayWithPos(clientNpcCultivationCfg.BengdiNpcid, gameplayId, self, self.invitePos, nil, fashionList)
		self.inviteCsUnitPid = inviteCsUnit and inviteCsUnit.Pid

		self:PlayInviteInviteTimeline()
	end)
end

M.StartSpoonInviteAction = function(self, _, agentId)
	self:ClearInviteClientNpc()

	self.inviteCsUnitPid = agentId

	self:PlayInviteInviteTimeline()
end

M.PlayInviteInviteTimeline = function(self)
	local danceNpcId = self:GetInviteDanceNpcId()
	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	timelineData.pos = self.inviteTimelinePos.position
	timelineData.rot = self.inviteTimelinePos.eulerAngles
	local npcCfg = LTConfig.DanceDanceNPCConfig.GetConfig(danceNpcId)
	local dialogIdList = npcCfg.Dialog_tl
	local modelName = npcCfg.TimelineModelName
	timelineData.dynamicActorInfos = {
		modelName
	}
	timelineData.dynamicDialogIds = dialogIdList
	local bindInfoList = {}
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteCsUnitPid, modelName, nil)

	table.insert(bindInfoList, c_bindInfo)

	timelineData.bindUnitInfos = bindInfoList

	if npcCfg.TLPersonality <= 0 then
		timelineData.dynamicPersonalityTypes = {
			npcCfg.TLPersonality
		}
	end

	local inviteCsUnit = gCS.SceneDataMgr.GetUnit(self.inviteCsUnitPid)

	gCS.BaseUnitUtils.SetUnitLogicalHidden(inviteCsUnit, true, LX6.Units.LogicalHiddenCause.GamePlay)

	timelineData.onPlayCallback = function(_)
		if gCS.LuaUtils.IsBaseUnitValid(inviteCsUnit) then
			gCS.BaseUnitUtils.SetUnitLogicalHidden(inviteCsUnit, false, LX6.Units.LogicalHiddenCause.GamePlay)
		end
	end

	timelineData.onFinishCallback = function(_)
		local npcUnit = self:GetInviteNpcUnit()

		if gCS.LuaUtils.IsBaseUnitValid(npcUnit) then
			npcUnit.LocalPosition = self.invitePos.position
			local dir = self.invitePos.rotation:Forward()

			npcUnit:SetFacing(dir)
		end

		if gCS.LuaUtils.IsBaseUnitValid(gCS.MyPlayerManager.PlayerUnit) then
			gCS.MyPlayerManager.PlayerUnit.LocalPosition = self.playerPos.position
			local dir = self.playerPos.rotation:Forward()

			gCS.MyPlayerManager.PlayerUnit:SetFacing(dir)
		end

		gPanelManager:CheckShow(gPanelId.S_GAMEPLAY_HUD_PANEL, {
			["\\x9c5-:j\\x9cr\\xdc#\\x83\\xbd"] = 1,
			["I\\x83\\x8f\\x8eR"] = "5\\x85㯮\\xec\\xe6\\xe7Ȍ\\xb7b\\x96\\xcauͱ",
			["hw\\xa1r\\\\xbe\\xf3^^cnI"] = ">M\\x9f\\x89\\xa7H"
		})
	end

	gTimelineManager:Timeline_LoadAndPlay(self.inviteTimeline, timelineData)
end

M.ClearInviteClientNpc = function(self)
	local inviteCsUnit = self.inviteCsUnitPid and gCS.SceneDataMgr.GetUnit(self.inviteCsUnitPid)

	if inviteCsUnit then
		gNpcInviteManager:RemoveClientInviteNpc(inviteCsUnit)
	end

	self.inviteCsUnitPid = nil
end

M.GetRandomFashionList = function(self, npcCultivationId, callback)
	local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcCultivationId)
	local spiritId = npcCultivationCfg.FightSpiritID

	gClientToGameDelegate:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, list)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			callback(0)
		else
			callback(list)
		end
	end
end

M.GetInviteNpcUnit = function(self)
	return self.inviteCsUnitPid and gCS.SceneDataMgr.GetUnit(self.inviteCsUnitPid)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		self:OnSpiritLeaveDiscoArea()
	end
end

gBengdiActionManager = gBengdiActionManager or C_BengdiActionManager.new()
