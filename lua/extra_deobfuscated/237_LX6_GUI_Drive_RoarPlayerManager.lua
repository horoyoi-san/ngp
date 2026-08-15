local RadioSongsRoarConfig = LTConfig.RadioSongsRoarConfig
local M = {
	curSoundPause = false,
	curRadioIndex = 0,
	RadioInfoDic = {},
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType <= gSwitchSceneType.Reconnect then
			return
		end

		for id, info in pairs(self.RadioInfoDic) do
			self:StopRadio(id)
		end

		self.RadioInfoDic = {}
	end,
	GetRadioInfoById = function (self, Id)
		if not Id or Id == 0 then
			return
		end

		return self.RadioInfoDic[Id]
	end,
	GetRadioCurMusicBPMById = function (self, Id)
		local radioInfo = self:GetRadioInfoById(Id)

		if radioInfo and radioInfo.songIndex <= #radioInfo.songList then
			return radioInfo.songList[radioInfo.songIndex].MusicBPM
		end

		return 0
	end,
	GetRadioCurIndex = function (self, Id)
		local radioInfo = self:GetRadioInfoById(Id)

		if radioInfo and radioInfo.songIndex <= #radioInfo.songList then
			return radioInfo.curRadioIndex
		end

		return 0
	end,
	GetRadioCurTitleNameById = function (self, Id)
		local radioInfo = self:GetRadioInfoById(Id)

		if radioInfo and radioInfo.songIndex <= #radioInfo.songList then
			return radioInfo.songList[radioInfo.songIndex].TitleName
		end

		return ""
	end,
	GetTotalRadioCount = function (self)
		return RadioSongsRoarConfig.count
	end,
	GetRadioNameAndIconHudByIndex = function (self, index)
		local config = RadioSongsRoarConfig.LoadAt(index - 1)

		if config and config.RadioNameHud then
			return config.RadioNameHud, config.RadioIcon
		end

		print_error("RoarPlayerManager GetRadioNameHud index is invalid,index is " .. tostring(index) .. ",VehicleRadioConfig length is " .. RadioSongsRoarConfig.count)

		return ""
	end,
	PlayRadio = function (self, id, followGo, radioIndex, songIndex, songTime)
		self:StopRadio(id, true)

		for i = 1, 50 do
			if not radioIndex then
				math.randomseed(tostring(os.time()):reverse():sub(1, 6))

				local index = math.random(1, RadioSongsRoarConfig.count)
				local cfg = RadioSongsRoarConfig.LoadAt(index - 1)

				if cfg and not cfg.IsRoarRadio then
					radioIndex = index

					break
				end
			end
		end

		if not radioIndex then
			for i = 0, RadioSongsRoarConfig.count - 1 do
				local config = RadioSongsRoarConfig.LoadAt(i)

				if not config.IsRoarRadio then
					radioIndex = i + 1
				end
			end
		end

		if not radioIndex then
			print_error("RoarPlayerManager RadioSongs Roar 表没有配置非咆哮电台")

			return
		end

		local radioCfg = RadioSongsRoarConfig.LoadAt(radioIndex - 1)
		local radioInfo = {
			isEnd = false,
			isPause = false,
			Id = id,
			followGo = followGo,
			curRadioIndex = radioIndex,
			songList = radioCfg.SoundDataList,
			songIndex = songIndex or 1
		}
		self.RadioInfoDic[id] = radioInfo
		self.curRadioIndex = radioIndex

		self:PlaySong(radioInfo, songTime)
	end
}

function M:PlaySong(radioInfo, seekTime)
	if not radioInfo or not radioInfo.songList or radioInfo.songIndex > #radioInfo.songList then
		return
	end

	local soundData = gSoundMgr:CreateSoundData(radioInfo.songList[radioInfo.songIndex].soundId)

	if soundData then
		local startCallBack = nil

		if seekTime then
			function startCallBack(uuid, data)
				if data then
					data:SeekToTime(seekTime)
				end
			end
		end

		soundData.followGo = radioInfo.followGo
		radioInfo.Nid = gSoundMgr:PlaySoundByData(soundData, nil, startCallBack, function (uuid, soundData)
			if not radioInfo.isEnd then
				local nextIndex = radioInfo.songIndex + 1

				if nextIndex > #radioInfo.songList then
					nextIndex = 1
				end

				self:PlaySong(radioInfo, nextIndex)
			end
		end)

		gMessageManager:SendMessage(gEventConstants.ROAR_RADIO_SONG_PLAY, radioInfo.Id)
	end

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

function M:StopRadio(id, isFromPlay)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	info.isEnd = true
	local Nid = info.Nid

	gSoundMgr:StopSoundByNid(Nid)

	self.RadioInfoDic[id] = nil
end

function M:PauseRadio(id, pause)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	local Nid = info.Nid
	local soundData = gSoundMgr:GetSoundDataByNid(Nid)

	if soundData then
		if pause then
			info.isPause = true

			soundData:SetRTPCValue(gSoundMgr.RTPCGroup.RadioVolume, 0)
		else
			info.isPause = false

			soundData:SetRTPCValue(gSoundMgr.RTPCGroup.RadioVolume, 100)
		end
	end
end

function M:SwitchRadio(id, addValue)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	local targetIndex = info.curRadioIndex + addValue

	if RadioSongsRoarConfig.count < targetIndex then
		targetIndex = 1
	elseif targetIndex <= 0 then
		targetIndex = RadioSongsRoarConfig.count
	end

	self:PlayRadio(info.Id, info.followGo, targetIndex)
end

function M:SwitchTargetRadio(id, targetIndex)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	self:PlayRadio(info.Id, info.followGo, targetIndex)
end

M.EventHandler = {}

function M:SwitchRadioSeamless(oldId, newId)
	local info = self.RadioInfoDic[oldId]

	if info == nil then
		return false
	end

	info.Id = newId
	self.RadioInfoDic[oldId] = nil
	self.RadioInfoDic[newId] = info

	return true
end

function M:IsCurrentRoarRadio(id)
	local radioInfo = self.RadioInfoDic[id]

	if radioInfo == nil then
		return false
	end

	local cfg = RadioSongsRoarConfig.LoadAt(radioInfo.curRadioIndex - 1)

	return cfg and cfg.IsRoarRadio
end

gRoarPlayerManager = M

return gRoarPlayerManager
