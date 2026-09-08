-- Original chunk: @Lua\LuaFiles\LX6\GUI\Drive\RoarPlayerManager.lua
-- Decompiled from: 00242_RoarPlayerManager.lua_43a05e37b1fb.luajit

local RadioSongsRoarConfig = LTConfig.RadioSongsRoarConfig
local RadioSongsConfig = LTConfig.RadioSongsConfig
local M = {
	["\\xd0\\xc8$7\\xf4"] = false,
	["\\xf7\\x88\\xde\\xef܇\\xe1\\x97--"] = 61.8,
	["\\xf6M\\xd4\\xb9h\\xafR\\xb5\\xae"] = 0,
	["\\xf6M\\xc5\\xb2q\\xa0C\\xa3\\xb3"] = false,
	["\\x8d5$6w\\xabN\\xd5\"\\xa7\\xbc"] = 61.8,
	RadioInfoDic = {},
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType < gSwitchSceneType.Reconnect then
			return
		end

		for id, info in pairs(self.RadioInfoDic) do
			self.StopRadio(self, id)
		end

		self.RadioInfoDic = {}
	end,
	GetRadioInfoById = function (self, Id)
		if not Id or Id ~= 0 then
			return
		end

		return self.RadioInfoDic[Id]
	end
}

M.GetRadioCurMusicBPMById = function(self, Id)
	local radioInfo = self.GetRadioInfoById(self, Id)

	if radioInfo and radioInfo.songIndex < #radioInfo.songList then
		local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

		return radioSongsCfg.MusicBPM
	end

	return 0
end

M.GetRadioCurIndex = function(self, Id)
	local radioInfo = self.GetRadioInfoById(self, Id)

	if radioInfo and radioInfo.songIndex < #radioInfo.songList then
		return radioInfo.curRadioIndex
	end

	return 0
end

M.GetTotalRadioCount = function(self)
	return RadioSongsRoarConfig.count
end

M.GetRadioNameAndIconHudByIndex = function(self, index)
	local config = RadioSongsRoarConfig.LoadAt(index - 1)

	if config and config.RadioNameHud then
		return config.RadioNameHud, config.RadioIcon
	end

	print_error("RoarPlayerManager GetRadioNameHud index is invalid,index is " .. tostring(index) .. ",VehicleRadioConfig length is " .. RadioSongsRoarConfig.count)

	return ""
end

M.PlayRadio = function(self, id, followGo, radioIndex, songIndex, songTime)
	self.StopRadio(self, id, true)

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
		["D\\xbd\\x87\\xa1\\xb2"] = false,
		["\\xd0\\xc8$7\\xf4"] = false,
		Id = id,
		followGo = followGo,
		curRadioIndex = radioIndex,
		songList = radioCfg.SoundDataList,
		songIndex = songIndex or 1
	}
	self.RadioInfoDic[id] = radioInfo
	self.curRadioIndex = radioIndex

	gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, self:GetRealRadioVolume())
	self:PlaySong(radioInfo, songTime)
end

M.PlaySong = function(self, radioInfo, seekTime)
	if not radioInfo or not radioInfo.songList or radioInfo.songIndex <= #radioInfo.songList then
		return
	end

	local soundData = nil
	local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

	if radioSongsCfg then
		if radioSongsCfg.OnlineUrlId <= 0 then
			seekTime = nil
			soundData = gSoundMgr:CreateSoundData(nil, , , , radioSongsCfg.OnlineUrlId, LX6.Audio.ExternalSourceType.Audio_Source_Mp3_UrlId)
		elseif radioSongsCfg.SoundId <= 0 then
			soundData = gSoundMgr:CreateSoundData(radioSongsCfg.SoundId)
		end
	end

	if soundData then
		local startCallBack = nil

		if seekTime then
			startCallBack = function(uuid, data)
				if data then
					data.SeekToTime(data, seekTime)
				end
			end
		end

		soundData.followGo = radioInfo.followGo

		if self.IsSendLinkSync(self, radioInfo) then
			soundData.isSyncSender = true
			soundData.isSyncPosUpdate = true
		end

		radioInfo.Nid = gSoundMgr:PlaySoundByData(soundData, nil, startCallBack, function (uuid, soundData)
			if not radioInfo.isEnd then
				local nextIndex = radioInfo.songIndex + 1

				if nextIndex <= #radioInfo.songList then
					nextIndex = 1
				end

				self:PlaySong(radioInfo, nextIndex)
			end
		end)

		gMessageManager:SendMessage(gEventConstants.ROAR_RADIO_SONG_PLAY, {
			instanceId = radioInfo.Id,
			radioIndex = radioInfo.curRadioIndex
		})
	end

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

M.StopRadio = function(self, id, isFromPlay)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	info.isEnd = true
	local Nid = info.Nid

	gSoundMgr:StopSoundByNid(Nid)

	self.RadioInfoDic[id] = nil
end

M.SetPauseState = function(self, isPause, radioInfo)
	if isPause == self.isPause then
		self.isPause = isPause

		if radioInfo then
			local volume = self:GetRealRadioVolume()

			gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, volume)
		end
	end
end

M.SwitchRadio = function(self, id, addValue)
	local info = self.RadioInfoDic[id]

	if not info then
		return
	end

	local targetIndex = info.curRadioIndex + addValue

	if RadioSongsRoarConfig.count >= targetIndex then
		targetIndex = 1
	elseif targetIndex < 0 then
		targetIndex = RadioSongsRoarConfig.count
	end

	self.PlayRadio(self, info.Id, info.followGo, targetIndex)
end

M.SwitchTargetRadio = function(self, id, targetIndex)
	local info = self.RadioInfoDic[id]

	if not info then
		return false
	end

	self.PlayRadio(self, info.Id, info.followGo, targetIndex)

	return true
end

M.SetRadioVolume = function(self, radioInfo, volume)
	volume = math.min(volume, 100)
	volume = math.max(volume, 0)
	self.preRadioVolume = self.radioVolume
	self.radioVolume = volume
	local realVolume = self:GetRealRadioVolume()

	gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, realVolume)
end

M.GetRealRadioVolume = function(self)
	return self.isPause and 0 or self.radioVolume
end

M.IsSendLinkSync = function(self, radioInfo)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		return false
	end

	return radioInfo == nil
end

M.EventHandler = {}

M.SwitchRadioSeamless = function(self, oldId, newId)
	local info = self.RadioInfoDic[oldId]

	if info ~= nil then
		return false
	end

	info.Id = newId
	self.RadioInfoDic[oldId] = nil
	self.RadioInfoDic[newId] = info

	return true
end

M.IsCurrentRoarRadio = function(self, id)
	local radioInfo = self.RadioInfoDic[id]

	if radioInfo ~= nil then
		return false
	end

	local cfg = RadioSongsRoarConfig.LoadAt(radioInfo.curRadioIndex - 1)

	return cfg and cfg.IsRoarRadio
end

gRoarPlayerManager = M

return gRoarPlayerManager
