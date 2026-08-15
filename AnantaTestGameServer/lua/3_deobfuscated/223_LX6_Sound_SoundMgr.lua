local LuaSoundData = require("LX6/Sound/LuaSoundData")
local SoundEventConfig = LTConfig.SoundEventConfig
local SoundConfig = LTConfig.SoundConfig
local SoundStateAreaMgr = LX6.Audio.SoundStateAreaMgr
local AudioManager = LX6.Audio.AudioManager
local SoundType = LX6.Audio.SoundType
local VehicleSoundMgr = LX6.Audio.VehicleSoundMgr
local SoundWeatherConfig = LTConfig.SoundWeatherConfig
local SoundSpoonEventConfig = LTConfig.SoundSpoonEventConfig
local C_CutsceneManager = LX6.TimelineScript.CutsceneManager.Instance
local M = {
	StopAllEvent = false,
	OpenDebug = false,
	_soundList = {},
	NidToSound = {},
	SoundDataPool = {},
	SoundDataPoolCapacity = 100,
	INVALID_PLAYING_ID = 0,
	NO_DESTROY_MAX_TIME = 999,
	SupportedCallbackType = {
		AK_MusicSyncGrid = 4096,
		AK_MusicSyncBeat = 256,
		AK_MusicSyncUserCue = 8192,
		AK_Marker = 4,
		AK_EndOfEvent = 1
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
		PlayerElevator = LX6.Constants.SoundConstants.SoundStateGroup.PlayerElevator
	},
	RTPCGroup = LX6.Constants.SoundConstants.SoundRtpcName,
	SwitchGroupName = LX6.Constants.SoundConstants.SoundSwitchGroupName,
	WeatherType = {
		Rain = "Rain",
		Cloudy = "Cloudy",
		Storm = "Storm",
		Sunny = "Sunny"
	},
	INF = 5000000,
	eps = 0.0001,
	NodeIndex = 1,
	SetDebugOpen = function (self, open)
		self.OpenDebug = open
	end,
	StopSendEvent = function (self, soundType, isStop)
		soundType = soundType or SoundType.All

		if isStop == nil then
			isStop = true
		end

		if soundType == SoundType.All then
			self.StopAllEvent = isStop
		elseif soundType == SoundType.Background then
			self.StopBgmEvent = isStop
		elseif soundType == SoundType.Effect then
			self.StopEffectEvent = isStop
		elseif soundType == SoundType.Voice then
			self.StopVoiceEvent = isStop
		end
	end,
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		gSoundMgr:SetStateValue(self.GameStateGroup.MotionGrade.StateName, self.GameStateGroup.MotionGrade.All)
	end,
	OnBeforeSwitchScene = function (self, switchType)
		return
	end,
	PlaySoundByTid = function (self, soundId, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		if not soundId or soundId == 0 then
			return
		end

		local soundData = self:CreateSoundData(soundId, soundPos)

		if soundData then
			return self:PlaySoundByData(soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		end
	end,
	PlaySoundByExternalSource = function (self, externalSource, externalType, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		local soundData = self:CreateSoundData(0, soundPos, nil, externalSource, nil, externalType)

		if soundData then
			return self:PlaySoundByData(soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		end
	end,
	PlaySoundByExternalSourceId = function (self, externalId, externalType, soundPos, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
		local soundData = self:CreateSoundData(0, soundPos, nil, nil, externalId, externalType)

		if soundData then
			return self:PlaySoundByData(soundData, postEndCb, startCallBack, endCallBack, beforeBankCallBack, markCallBack, musicCueCallBack)
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

		if (soundData.templateId == nil or soundData.templateId == 0) and not soundData.externalSource and (soundData.externalId == nil or soundData.externalId == 0) then
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
			soundCallbackData:AddDurationCallback(function (uuid)
				local playingID = uuid
				local curSoundData = self:GetSoundData(playingID)

				if playingID > 0 and not curSoundData and self.OpenDebug then
					print_warn("SoundMgr PlayLuaSound DurationCallBack SoundData is nil,templateId is " .. curTemplateId .. ",ExternalSource is " .. tostring(curExternalSource))
				end

				startCallBack(playingID, curSoundData)
			end)
		end

		if endCallBack then
			local function AK_EndOfEvent_CallBack(callbackInfo)
				if callbackInfo then
					endCallBack(callbackInfo.playingID)
				else
					endCallBack()
				end
			end

			soundCallbackData:AddCallback(self.SupportedCallbackType.AK_EndOfEvent, AK_EndOfEvent_CallBack)
		end

		if beforeBankCallBack then
			soundCallbackData:AddBeforeLoadBankCallback(beforeBankCallBack)
		end

		if markCallBack then
			soundCallbackData:AddCallback(self.SupportedCallbackType.AK_Marker, function (markerCallbackInfo)
				local playingID = markerCallbackInfo.playingID
				local markTag = markerCallbackInfo.strLabel

				markCallBack(playingID, markTag)
			end)
		end

		if musicCueCallBack then
			soundCallbackData:AddCallback(self.SupportedCallbackType.AK_MusicSyncUserCue, function (musicCallbackInfo)
				local playingID = musicCallbackInfo.playingID
				local cueName = musicCallbackInfo.userCueName

				musicCueCallBack(playingID, cueName)
			end)
		end

		local function bankLoaded(uuid)
			soundData.UUId = uuid

			if uuid > 0 and not soundData.soundEvt then
				soundData.soundEvt = AudioManager.Instance:GetSoundInstance(uuid)
			end

			if postEndCb then
				postEndCb(uuid, soundData)
			end

			if uuid <= 0 then
				if not gCS.LuaUtils.IsOnAndroid and self.OpenDebug then
					print_warn("UUId is " .. soundData.UUId .. ",templateId is " .. soundData.templateId .. ",ExternalSource is " .. tostring(curExternalSource) .. ",声音播放失败,具体报错请看c#的提示日志")
				end

				if startCallBack then
					startCallBack(0)
				end
			end
		end

		soundCallbackData:AddDestroyCallback(function (sid)
			if soundData.Sid == sid then
				self:DestroyData(soundData)
			end
		end)

		if soundData.externalId then
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
		elseif soundData.followGo then
			soundData.Sid = AudioManager.Instance:PlaySound(soundData.templateId, soundData.followGo, soundCallbackData, bankLoaded)
		else
			soundData.Sid = AudioManager.Instance:PlaySound(soundData.templateId, soundData.position, soundData.eulerAngles, soundCallbackData, bankLoaded)
		end

		if soundData.Sid <= 0 then
			self:DestroyData(soundData)
		elseif soundData.Sid > 0 and not soundData.soundEvt then
			soundData.soundEvt = AudioManager.Instance:GetSoundBySid(soundData.Sid)
		end

		return soundData.NodeId
	end,
	GetSoundDataByNid = function (self, nodeId)
		if not nodeId or nodeId == 0 then
			return nil
		end

		return self.NidToSound[nodeId]
	end,
	GetSoundDataListByTid = function (self, soundId)
		local soundList = {}
		local ln = #self._soundList

		for i = ln, 1, -1 do
			local data = self._soundList[i]

			if data.templateId == soundId then
				table.insert(soundList, data)
			end
		end

		return soundList
	end,
	GetSoundData = function (self, uuid)
		if not uuid or uuid == 0 then
			return nil
		end

		local ln = #self._soundList

		for i = ln, 1, -1 do
			local data = self._soundList[i]

			if data.UUId == uuid then
				return data
			end
		end

		return nil
	end,
	StopSound = function (self, uuid)
		if not uuid then
			return
		end

		local soundData = self:GetSoundData(uuid)

		self:StopSoundByData(soundData)
	end,
	StopSoundByNid = function (self, nodeId)
		if not nodeId then
			return
		end

		local soundData = self:GetSoundDataByNid(nodeId)

		self:StopSoundByData(soundData)
	end,
	StopSoundByTid = function (self, soundId)
		if not soundId then
			return
		end

		local soundDataList = self:GetSoundDataListByTid(soundId)

		for i = 1, #soundDataList do
			self:StopSoundByData(soundDataList[i])
		end
	end,
	StopSoundByData = function (self, soundData)
		if not soundData then
			return
		end

		soundData:StopSoundEvt()
		self:DestroyData(soundData)
	end,
	StopAllSound = function (self)
		for i = 1, #self._soundList do
			if self._soundList[i] ~= nil then
				self._soundList[i]:StopSoundEvt()

				self._soundList[i].isDestroy = true

				self:RecycleLuaSoundData(self._soundList[i])
			end
		end

		table.clear(self._soundList)
		table.clear(self.NidToSound)

		self.NodeIndex = 0
	end,
	Pause = function (self, uuid)
		local soundData = self:GetSoundData(uuid)

		if soundData then
			soundData:Pause()
		end
	end,
	SetSpeed = function (self, uuid, speed)
		local soundData = self:GetSoundData(uuid)

		if soundData then
			soundData:SetSpeed(speed)
		end
	end,
	Resume = function (self, uuid)
		local soundData = self:GetSoundData(uuid)

		if soundData then
			soundData:Resume()
		end
	end,
	SetStateValue = function (self, key, value, taskEventState)
		taskEventState = taskEventState or false

		if self.OpenDebug then
			print_notice("SoundMgr SetStateValue key is " .. tostring(key) .. ",value is :" .. tostring(value) .. ",taskEventState is :" .. tostring(taskEventState))
		end

		if key and value then
			SoundStateAreaMgr.Instance:SetState(key, value, taskEventState)
		else
			print_error("SoundMgr key or value is nil")
		end
	end,
	SetGlobalRTPC = function (self, key, value)
		AudioManager.Instance:SetGlobalRTPCValue(key, value)
	end,
	OnEnterStateArea = function (self, key, stateNameList, stateValueList, priority)
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
	end,
	OnLeaveStateArea = function (self, key)
		if self.OpenDebug then
			print_notice("SoundMgr OnLeaveStateArea : key is" .. tostring(key))
		end

		SoundStateAreaMgr.Instance:OnLeave(key)
	end,
	SetVoiceLanguage = function (self, language)
		if self.OpenDebug then
			print_notice("SoundMgr SetVoiceLanguage language is " .. tostring(language))
		end

		if language then
			C_CutsceneManager:SetVoiceLanguage(language)
		else
			print_error("SoundMgr language is nil")
		end
	end,
	DestroyData = function (self, data)
		if not data then
			return
		end

		if self.OpenDebug then
			print_notice("SoundMgr DestroyData soundId is :", data.templateId, ",nodeId is:", tostring(data.NodeId), ",sid is :", tostring(data.Sid))
		end

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.BeginSample("SoundMgr DestroyData")
		end

		data.isDestroy = true

		table.removeEx(self._soundList, data)

		self.NidToSound[data.NodeId] = nil

		self:RecycleLuaSoundData(data)

		if gGameManager.Env.IsENABLE_PROFILER then
			gCS.LuaUtils.EndSample()
		end
	end,
	PlayModelSwitchSoundByModelId = function (self, soundId, modelId, position)
		gSoundMgr:PlaySoundByTid(soundId, position, nil, nil, nil, function (C_data)
			local switchName = AudioManager.Instance:GetModelSwtich(modelId)
			local switchGroup = AudioManager.Instance:GetModelSwtichGroup(modelId)

			if switchGroup and switchName then
				C_data:SetSwitchValue(switchGroup, switchName)
			end
		end)
	end,
	PlayCharacterCombineExternalVoice = function (self, baseStr, agentId)
		if self.OpenDebug then
			print_notice("SoundMgr PlayCharacterCombineExternalVoice baseStr is :" .. tostring(baseStr) .. ",agentId is :" .. tostring(agentId))
		end

		agentId = agentId or 0

		AudioManager.Instance:PlayCharacterCombineExternalVoice(baseStr, agentId)
	end,
	SyncSpoonClientSoundTrigger = function (self, soundTriggerTiming, nodeId, context)
		local cfg = SoundSpoonEventConfig.GetConfig(nodeId)

		if not cfg then
			return
		end

		local playEventList, stateList, rtpcList = nil
		local stateDelayTime = 0

		if soundTriggerTiming == UX.Game.SoundTriggerTiming.Start then
			playEventList = cfg.StartPlaySounds
			stateList = cfg.StartStateList
			rtpcList = cfg.StartRtpcList
			stateDelayTime = cfg.StartStateDelayTime
		elseif soundTriggerTiming == UX.Game.SoundTriggerTiming.Complete or soundTriggerTiming == UX.Game.SoundTriggerTiming.Error then
			playEventList = cfg.EndPlaySounds
			stateList = cfg.EndStateList
			rtpcList = cfg.EndRtpcList
			stateDelayTime = cfg.EndStateDelayTime
		end

		if playEventList and #playEventList > 0 then
			for i = 1, #playEventList do
				local soundId = playEventList[i].soundId

				self:PlaySoundByTid(soundId)
			end
		end

		if stateList and #stateList > 0 then
			if stateDelayTime and stateDelayTime > 0.01 then
				Timer.New(function ()
					for i = 1, #stateList do
						self:SetStateValue(stateList[i].stateName, stateList[i].stateValue, true)
					end
				end, stateDelayTime):Start()
			else
				for i = 1, #stateList do
					self:SetStateValue(stateList[i].stateName, stateList[i].stateValue, true)
				end
			end
		end

		if rtpcList and #rtpcList > 0 then
			for i = 1, #rtpcList do
				self:SetGlobalRTPC(rtpcList[i].rtpcName, rtpcList[i].rtpcValue)
			end
		end
	end,
	CreateSoundData = function (self, soundId, soundPos, eulerAngles, externalSource, externalId, externalType)
		local cfg = SoundEventConfig.GetConfig(soundId)

		if not cfg and not externalSource and not externalId then
			if self.OpenDebug then
				print_warn("SoundMgr 此处配置有误[PlaySound] not have cfg SoundId", soundId, ",externalSource : " .. tostring(externalSource) .. ",externalId :" .. tostring(externalId))
			end

			return
		end

		local soundData = self:GetLuaSoundDataFromPool()
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

			if count >= 200 then
				print_error("SoundMgr CreateSoundData NidToSoundDic count is ", tostring(count), ",lua 音频节点过多")
			end
		end

		return soundData
	end,
	GetLuaSoundDataFromPool = function (self)
		local count = #self.SoundDataPool
		local luaSoundData = nil

		if count > 0 then
			luaSoundData = self.SoundDataPool[count]

			table.remove(self.SoundDataPool, count)
		else
			luaSoundData = LuaSoundData.New()
		end

		luaSoundData:ResetData()

		luaSoundData.UUId = self.INVALID_PLAYING_ID

		return luaSoundData
	end,
	RecycleLuaSoundData = function (self, soundData)
		if soundData.recycle then
			return
		end

		soundData.recycle = true
		local count = #self.SoundDataPool

		if count < self.SoundDataPoolCapacity then
			table.insert(self.SoundDataPool, soundData)
		end
	end,
	EventHandler = {
		[gEventConstants.ENTER_VEHICLE_START] = function (eventId, vehicleId)
			VehicleSoundMgr.Instance:PlayerEnterVehicle(vehicleId)
			gSoundMgr:OnEnterStateArea("VehicleDrive", {
				gSoundMgr.GameStateGroup.MovementState.StateName
			}, {
				gSoundMgr.GameStateGroup.MovementState.Drive
			})
		end,
		[gEventConstants.EXIT_VEHICLE_FINISH] = function (eventId, data)
			gSoundMgr:OnLeaveStateArea("VehicleDrive")
		end
	}
}
gSoundMgr = M
