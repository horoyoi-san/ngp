-- Original chunk: @Lua\LuaFiles\LX6\Sound\SoundMgr.lua
-- Decompiled from: 00225_SoundMgr.lua_fa680b7296ed.luajit

local LuaSoundData = require("LX6/Sound/LuaSoundData")
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundStateAreaMgr = LX6.Audio.SoundStateAreaMgr
local AudioManager = LX6.Audio.AudioManager
local SoundType = LX6.Audio.SoundType
local VehicleSoundMgr = LX6.Audio.VehicleSoundMgr
local SoundSpoonEventConfig = LTConfig.SoundSpoonEventConfig
local M = {
	["\\b\\xa3gm\\xbe\\xfeb|pX"] = false,
	["lWigj?"] = false,
	_soundList = {},
	NidToSound = {},
	SoundDataPool = {},
	SoundDataPoolCapacity = 100,
	INVALID_PLAYING_ID = 0,
	NO_DESTROY_MAX_TIME = 999,
	SupportedCallbackType = {
		["F,\\xa5\\xbd\\xaaϹ\\xc6\\xb01\\x95?"] = 4096,
		["F,\\xa5\\xbd\\xaaϹ\\xc6\\xb01\\x907"] = 256,
		["\\'\\x8d\\xe2j\\xaeI84b\\xa4\\xec\\xcc\\xe2"] = 8192,
		["blSDO*"] = 4,
		["#\\xc8`\t\\xd43\\xb0d\\xb7S\\xbe\\xa2"] = 1
	},
	GameStatePriority = LX6.Constants.SoundConstants.SoundStatePriority,
	GameStateGroup = {
		GameState = LX6.Constants.SoundConstants.SoundStateGroup.GameState,
		GamePlay_Mix = LX6.Constants.SoundConstants.SoundStateGroup.GamePlay_Mix,
		PanelType = LX6.Constants.SoundConstants.SoundStateGroup.PanelType,
		MonsterTypes = LX6.Constants.SoundConstants.SoundStateGroup.MonsterTypes,
		MovementState = LX6.Constants.SoundConstants.SoundStateGroup.MovementState,
		MusicState = LX6.Constants.SoundConstants.SoundStateGroup.MusicState,
		MotionGrade = LX6.Constants.SoundConstants.SoundStateGroup.MotionGrade,
		WorldRegion = LX6.Constants.SoundConstants.SoundStateGroup.WorldRegion,
		Cinematics = LX6.Constants.SoundConstants.SoundStateGroup.Cinematics,
		PlayerElevator = LX6.Constants.SoundConstants.SoundStateGroup.PlayerElevator,
		EGuitarStrumChord = LX6.Constants.SoundConstants.SoundStateGroup.EGuitarStrumChord,
		EGuitarStrumRhy = LX6.Constants.SoundConstants.SoundStateGroup.EGuitarStrumRhy,
		MusicChoirBoys = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirBoys,
		MusicChoirGirls = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirGirls,
		MusicChoirPlayer = LX6.Constants.SoundConstants.SoundStateGroup.MusicChoirPlayer
	},
	RTPCGroup = LX6.Constants.SoundConstants.SoundRtpcName,
	SwitchGroupName = LX6.Constants.SoundConstants.SoundSwitchGroupName,
	SwitchGroupValue = LX6.Constants.SoundConstants.SoundSwitchGroupValue,
	WeatherType = {
		["H#tU"] = "H#tU",
		["?D\\x9e\\x9b\\x87X"] = "?D\\x9e\\x9b\\x87X",
		["~\\xba\\xad\\xbd\\xbb"] = "~\\xba\\xad\\xbd\\xbb",
		["~\\xbb\\xac\\xa1\\xaf"] = "~\\xbb\\xac\\xa1\\xaf"
	},
	INF = 5000000,
	eps = 0.0001,
	NodeIndex = 1,
	SetDebugOpen = function (self, open)
		self.OpenDebug = open
	end,
	StopSendEvent = function (self, soundType, isStop)
		soundType = soundType or SoundType.All

		if isStop ~= nil then
			isStop = true
		end

		if soundType ~= SoundType.All then
			self.StopAllEvent = isStop
		elseif soundType ~= SoundType.Background then
			self.StopBgmEvent = isStop
		elseif soundType ~= SoundType.Effect then
			self.StopEffectEvent = isStop
		elseif soundType ~= SoundType.Voice then
			self.StopVoiceEvent = isStop
		end
	end,
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end
	end,
	OnBeforeSwitchScene = function (self, switchType)
	end,
	PlaySoundByTid = function (self, soundId, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		if not soundId or soundId ~= 0 then
			return
		end

		local soundData = self.CreateSoundData(self, soundId, soundPos)

		if soundData then
			return self.PlaySoundByData(self, soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		end
	end,
	PlaySoundByExternalSource = function (self, externalSource, externalType, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		local soundData = self.CreateSoundData(self, 0, soundPos, nil, externalSource, nil, externalType)

		if soundData then
			return self.PlaySoundByData(self, soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		end
	end,
	PlaySoundByExternalSourceId = function (self, externalId, externalType, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		local soundData = self.CreateSoundData(self, 0, soundPos, nil, , externalId, externalType)

		if soundData then
			return self.PlaySoundByData(self, soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		end
	end,
	PlaySoundByData = function (self, soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		if AudioManager.Instance.closeAudio then
			if self.OpenDebug then
				print_notice("SoundMgr PlayLuaSound closeAudio is true,关闭声音 ")
			end

			return 0
		end

		if self.OpenDebug then
			print_notice("SoundMgr PlayLuaSound templateId is " .. soundData.templateId .. ",externalSource :" .. tostring(soundData.externalSource) .. ",externalId is:" .. tostring(soundData.externalId), "nodeId is:", soundData.NodeId)
		end

		if (soundData.templateId ~= nil or soundData.templateId ~= 0) and not soundData.externalSource and (soundData.externalId ~= nil or soundData.externalId ~= 0) then
			return 0
		end

		if self.StopAllEvent then
			if self.OpenDebug then
				print_notice("SoundMgr PlayLuaSound StopAllEvent is true,停止发送所有声音事件 ")
			end

			return 0
		end

		local soundCallbackData = AudioManager.Instance:CreateCallbackData()
		local curTemplateId = soundData.templateId
		local curExternalSource = soundData.externalSource

		if startCallBack then
			soundCallbackData.AddDurationCallback(soundCallbackData, function (uuid)
				local playingID = uuid
				local curSoundData = self:GetSoundData(playingID)

				if playingID <= 0 and not curSoundData and self.OpenDebug then
					print_warn("SoundMgr PlayLuaSound DurationCallBack SoundData is nil,templateId is " .. curTemplateId .. ",ExternalSource is " .. tostring(curExternalSource))
				end

				startCallBack(playingID, curSoundData)
			end)
		end

		if endCallBack then
			local AK_EndOfEvent_CallBack = function(callbackInfo)
				if callbackInfo then
					endCallBack(callbackInfo.playingID)
				else
					endCallBack()
				end
			end

			soundCallbackData.AddCallback(soundCallbackData, self.SupportedCallbackType.AK_EndOfEvent, AK_EndOfEvent_CallBack)
		end

		if beforeBankCallBack then
			soundCallbackData.AddBeforeLoadBankCallback(soundCallbackData, beforeBankCallBack)
		end

		if markCallBack then
			soundCallbackData.AddCallback(soundCallbackData, self.SupportedCallbackType.AK_Marker, function (markerCallbackInfo)
				local playingID = markerCallbackInfo.playingID
				local markTag = markerCallbackInfo.strLabel

				markCallBack(playingID, markTag)
			end)
		end

		if musicCueCallBack then
			soundCallbackData.AddCallback(soundCallbackData, self.SupportedCallbackType.AK_MusicSyncUserCue, function (musicCallbackInfo)
				local playingID = musicCallbackInfo.playingID
				local cueName = musicCallbackInfo.userCueName

				musicCueCallBack(playingID, cueName)
			end)
		end

		local bankLoaded = function(uuid)
			soundData.UUId = uuid

			if uuid <= 0 and not soundData.soundEvt then
				soundData.soundEvt = AudioManager.Instance:GetSoundInstance(uuid)
			end

			if postEndCb then
				postEndCb(uuid, soundData)
			end

			if uuid < 0 then
				if not gCS.LuaUtils.IsOnAndroid and self.OpenDebug then
					print_warn("UUId is " .. soundData.UUId .. ",templateId is " .. soundData.templateId .. ",ExternalSource is " .. tostring(curExternalSource) .. ",声音播放失败,具体报错请看c#的提示日志")
				end

				if startCallBack then
					startCallBack(0)
				end
			end
		end

		soundCallbackData.AddDestroyCallback(soundCallbackData, function (sid)
			if soundData.Sid ~= sid then
				self:DestroyData(soundData)
			end
		end)

		if soundData.isSyncSender and soundData.externalId and soundData.externalId <= 0 then
			if soundData.followGo then
				soundData.Sid = AudioManager.Instance:PlaySoundLinkSenderByExternalSource(soundData.externalId, soundData.followGo, soundData.externalType, soundCallbackData, bankLoaded, soundData.isSyncPosUpdate)
			else
				soundData.Sid = AudioManager.Instance:PlaySoundLinkSenderByExternalSource(soundData.externalId, soundData.position, soundData.eulerAngles, soundData.externalType, soundCallbackData, bankLoaded, soundData.isSyncPosUpdate)
			end
		elseif soundData.externalId then
			if soundData.followGo then
				soundData.Sid = AudioManager.Instance:PlaySoundByExternalSource(soundData.externalId, soundData.followGo, soundData.externalType, soundCallbackData, bankLoaded)
			else
				soundData.Sid = AudioManager.Instance:PlaySoundByExternalSource(soundData.externalId, soundData.position, soundData.eulerAngles, soundData.externalType, soundCallbackData, bankLoaded)
			end
		elseif soundData.externalSource then
			if soundData.followGo then
				soundData.Sid = AudioManager.Instance:PlaySoundByExternalSource(soundData.externalSource, soundData.followGo, soundData.externalType, soundCallbackData, bankLoaded)
			else
				soundData.Sid = AudioManager.Instance:PlaySoundByExternalSource(soundData.externalSource, soundData.position, soundData.eulerAngles, soundData.externalType, soundCallbackData, bankLoaded)
			end
		elseif soundData.isSyncSender and soundData.templateId and soundData.templateId <= 0 then
			if soundData.followGo then
				soundData.Sid = AudioManager.Instance:PlaySoundLinkSender(soundData.templateId, soundData.followGo, soundCallbackData, bankLoaded, soundData.isSyncPosUpdate)
			else
				soundData.Sid = AudioManager.Instance:PlaySoundLinkSender(soundData.templateId, soundData.position, soundData.eulerAngles, soundCallbackData, bankLoaded, soundData.isSyncPosUpdate)
			end
		elseif soundData.followGo then
			soundData.Sid = AudioManager.Instance:PlaySound(soundData.templateId, soundData.followGo, soundCallbackData, bankLoaded)
		else
			soundData.Sid = AudioManager.Instance:PlaySound(soundData.templateId, soundData.position, soundData.eulerAngles, soundCallbackData, bankLoaded)
		end

		if soundData.Sid < 0 then
			self.DestroyData(self, soundData)
		elseif soundData.Sid <= 0 and not soundData.soundEvt then
			soundData.soundEvt = AudioManager.Instance:GetSoundBySid(soundData.Sid)
		end

		return soundData.NodeId
	end,
	GetSoundDataByNid = function (self, nodeId)
		if not nodeId or nodeId ~= 0 then
			return nil
		end

		return self.NidToSound[nodeId]
	end,
	GetSoundDataListByTid = function (self, soundId)
		local soundList = {}
		local ln = #self._soundList

		for i = ln, 1, -1 do
			local data = self._soundList[i]

			if data.templateId ~= soundId then
				table.insert(soundList, data)
			end
		end

		return soundList
	end
}

M.GetSoundData = function(self, uuid)
	if not uuid or uuid ~= 0 then
		return nil
	end

	local ln = #self._soundList

	for i = ln, 1, -1 do
		local data = self._soundList[i]

		if data.UUId ~= uuid then
			return data
		end
	end

	return nil
end

M.StopSound = function(self, uuid)
	if not uuid then
		return
	end

	local soundData = self.GetSoundData(self, uuid)

	self.StopSoundByData(self, soundData)
end

M.StopSoundByNid = function(self, nodeId)
	if not nodeId then
		return
	end

	local soundData = self.GetSoundDataByNid(self, nodeId)

	self.StopSoundByData(self, soundData)
end

M.StopSoundByTid = function(self, soundId)
	if not soundId then
		return
	end

	local soundDataList = self.GetSoundDataListByTid(self, soundId)

	for i = 1, #soundDataList do
		self.StopSoundByData(self, soundDataList[i])
	end
end

M.StopSoundByData = function(self, soundData)
	if not soundData then
		return
	end

	soundData.StopSoundEvt(soundData)
	self.DestroyData(self, soundData)
end

M.StopAllSound = function(self)
	for i = 1, #self._soundList do
		if self._soundList[i] == nil then
			self._soundList[i]:StopSoundEvt()

			self._soundList[i].isDestroy = true

			self:RecycleLuaSoundData(self._soundList[i])
		end
	end

	table.clear(self._soundList)
	table.clear(self.NidToSound)

	self.NodeIndex = 0
end

M.Pause = function(self, uuid)
	local soundData = self.GetSoundData(self, uuid)

	if soundData then
		soundData.Pause(soundData)
	end
end

M.SetSpeed = function(self, uuid, speed)
	local soundData = self.GetSoundData(self, uuid)

	if soundData then
		soundData.SetSpeed(soundData, speed)
	end
end

M.Resume = function(self, uuid)
	local soundData = self.GetSoundData(self, uuid)

	if soundData then
		soundData.Resume(soundData)
	end
end

M.SetStateValue = function(self, key, value, taskEventState)
	taskEventState = taskEventState or false

	if self.OpenDebug then
		print_notice("SoundMgr SetStateValue key is " .. tostring(key) .. ",value is :" .. tostring(value) .. ",taskEventState is :" .. tostring(taskEventState))
	end

	if key and value then
		SoundStateAreaMgr.Instance:SetState(key, value, taskEventState)
	else
		print_error("SoundMgr key or value is nil")
	end
end

M.SetGlobalRTPC = function(self, key, value)
	AudioManager.Instance:SetGlobalRTPCValue(key, value)
end

M.OnEnterStateArea = function(self, key, stateNameList, stateValueList, priority)
	priority = priority or 0

	if self.OpenDebug then
		print_notice("SoundMgr OnEnterStateArea : key is" .. tostring(key) .. ",priority:" .. priority)

		local length = math.min(#stateNameList, #stateValueList)

		for i = 1, length do
			print_notice("i=" .. i .. ",state Name is:" .. stateNameList[i])
			print_notice("i=" .. i .. ",state Value is:" .. stateValueList[i])
		end
	end

	SoundStateAreaMgr.Instance:OnEnter(key, stateNameList, stateValueList, priority)
end

M.OnLeaveStateArea = function(self, key)
	if self.OpenDebug then
		print_notice("SoundMgr OnLeaveStateArea : key is" .. tostring(key))
	end

	SoundStateAreaMgr.Instance:OnLeave(key)
end

M.SetVoiceLanguage = function(self, language)
	if self.OpenDebug then
		print_notice("SoundMgr SetVoiceLanguage language is " .. tostring(language))
	end

	if language then
		if L50.L50App.L50Game then
			L50.L50App.L50Game.CutsceneManager:SetVoiceLanguage(language)
		else
			AudioManager.Instance:SetVoiceLanguage(language)
		end
	else
		print_error("SoundMgr language is nil")
	end
end

M.DestroyData = function(self, data)
	if not data then
		return
	end

	if self.OpenDebug then
		print_notice("SoundMgr DestroyData soundId is :", data.templateId, ",nodeId is:", tostring(data.NodeId), ",sid is :", tostring(data.Sid))
	end

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:BeginSample("SoundMgr DestroyData")
	end

	data.isDestroy = true

	table.removeEx(self._soundList, data)

	self.NidToSound[data.NodeId] = nil

	self.RecycleLuaSoundData(self, data)

	if gGameManager.Env.IsENABLE_PROFILER then
		gGameManager:EndSample()
	end
end

M.PlayModelSwitchSoundByModelId = function(self, soundId, modelId, position, startCallback, endCallback)
	slot6 = gSoundMgr

	slot6:PlaySoundByTid(soundId, position, nil, startCallback, endCallback, function (C_data)
		local switchName = AudioManager.Instance:GetModelSwtich(modelId)
		local switchGroup = AudioManager.Instance:GetModelSwtichGroup(modelId)

		if switchGroup and switchName then
			C_data:SetSwitchValue(switchGroup, switchName)
		end
	end)
end

M.PlayBattleSettingVoice = function(self, battleVoiceId, unitPid)
	if self.OpenDebug then
		print_notice("SoundMgr PlayBattleSettingVoice battleVoiceId is :" .. tostring(battleVoiceId) .. ",unitPid is :" .. tostring(unitPid))
	end

	unitPid = unitPid or 0

	AudioManager.Instance:PlayBattleSettingVoice(battleVoiceId, unitPid)
end

M.SyncSpoonClientSoundTrigger = function(self, soundTriggerTiming, nodeId, context)
	local cfg = SoundSpoonEventConfig.GetConfig(nodeId)

	if not cfg then
		return
	end

	local playEventList, stateList, rtpcList = nil
	local stateDelayTime = 0

	if soundTriggerTiming ~= UX.Game.SoundTriggerTiming.Start then
		playEventList = cfg.StartPlaySounds
		stateList = cfg.StartStateList
		rtpcList = cfg.StartRtpcList
		stateDelayTime = cfg.StartStateDelayTime
	elseif soundTriggerTiming ~= UX.Game.SoundTriggerTiming.Complete or soundTriggerTiming ~= UX.Game.SoundTriggerTiming.Error then
		playEventList = cfg.EndPlaySounds
		stateList = cfg.EndStateList
		rtpcList = cfg.EndRtpcList
		stateDelayTime = cfg.EndStateDelayTime
	end

	if playEventList and #playEventList <= 0 then
		for i = 1, #playEventList do
			local soundId = playEventList[i].soundId

			self.PlaySoundByTid(self, soundId)
		end
	end

	if stateList and #stateList <= 0 then
		if stateDelayTime and stateDelayTime <= 0.01 then
			Timer.New(function ()
				for i = 1, #stateList do
					self:SetStateValue(stateList[i].stateName, stateList[i].stateValue, true)
				end
			end, stateDelayTime):Start()
		else
			for i = 1, #stateList do
				self.SetStateValue(self, stateList[i].stateName, stateList[i].stateValue, true)
			end
		end
	end

	if rtpcList and #rtpcList <= 0 then
		for i = 1, #rtpcList do
			self.SetGlobalRTPC(self, rtpcList[i].rtpcName, rtpcList[i].rtpcValue)
		end
	end
end

M.CreateSoundData = function(self, soundId, soundPos, eulerAngles, externalSource, externalId, externalType)
	local cfg = SoundEventConfig.GetConfig(soundId)

	if not cfg and not externalSource and not externalId then
		if self.OpenDebug then
			print_warn("SoundMgr 此处配置有误[PlaySound] not have cfg SoundId", soundId, ",externalSource : " .. tostring(externalSource) .. ",externalId :" .. tostring(externalId))
		end

		return
	end

	local soundData = self.GetLuaSoundDataFromPool(self)
	self.NodeIndex = self.NodeIndex + 1
	soundData.NodeId = self.NodeIndex
	soundData.position = Vector3.zero
	soundData.eulerAngles = Vector3.zero

	if soundPos then
		gUtils:Vector3Copy(soundData.position, soundPos)
	end

	if eulerAngles then
		gUtils:Vector3Copy(soundData.eulerAngles, eulerAngles)
	end

	soundData.templateId = soundId or 0
	soundData.externalSource = externalSource
	soundData.externalId = externalId
	soundData.externalType = externalType or 0

	table.insert(self._soundList, soundData)

	self.NidToSound[soundData.NodeId] = soundData

	if self.OpenDebug then
		local count = table.count(self.NidToSound)

		if count > 200 then
			print_error("SoundMgr CreateSoundData NidToSoundDic count is ", tostring(count), ",lua 音频节点过多")
		end
	end

	return soundData
end

M.GetLuaSoundDataFromPool = function(self)
	local count = #self.SoundDataPool
	local luaSoundData = nil

	if count <= 0 then
		luaSoundData = self.SoundDataPool[count]

		table.remove(self.SoundDataPool, count)
	else
		luaSoundData = LuaSoundData.New()
	end

	luaSoundData.ResetData(luaSoundData)

	luaSoundData.UUId = self.INVALID_PLAYING_ID

	return luaSoundData
end

M.RecycleLuaSoundData = function(self, soundData)
	if soundData.recycle then
		return
	end

	soundData.recycle = true
	local count = #self.SoundDataPool

	if count >= self.SoundDataPoolCapacity then
		table.insert(self.SoundDataPool, soundData)
	end
end

M.EventHandler = {
	[gEventConstants.ENTER_BASE_VEHICLE_START] = function (eventId, vehicleId)
		VehicleSoundMgr.Instance:PlayerEnterVehicle(vehicleId)
		gSoundMgr:OnEnterStateArea("VehicleDrive", {
			gSoundMgr.GameStateGroup.MovementState.StateName
		}, {
			gSoundMgr.GameStateGroup.MovementState.Drive
		})
	end,
	[gEventConstants.EXIT_BASE_VEHICLE_FINISH] = function (eventId, data)
		gSoundMgr:OnLeaveStateArea("VehicleDrive")
	end
}
gSoundMgr = M
