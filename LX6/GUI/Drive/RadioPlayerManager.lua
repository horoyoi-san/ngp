-- Original chunk: @Lua\LuaFiles\LX6\GUI\Drive\RadioPlayerManager.lua
-- Decompiled from: 00241_RadioPlayerManager.lua_376435a8cdec.luajit

local VehicleRadioConfig = LTConfig.VehicleRadioConfig
local NeteaseCloudMusicManager = LX6.Audio.NeteaseCloudMusic.NeteaseCloudMusicManager
local RadioSongsConfig = LTConfig.RadioSongsConfig
local SoundEventConfig = LTConfig.SoundEventConfig
local AudioManager = LX6.Audio.AudioManager
local CS_RadioManager = LX6.Audio.RadioManager
local DJNameType = LTConfig.VehicleRadioConfig.DJNameType
local RadioContentType = UX.Game.RadioContentType
local RadioContentDJs = LTConfig.RadioContentDJsConfig
local RadioContentAds = LTConfig.RadioContentAdsConfig
local RadioContentNews = LTConfig.RadioContentNewsConfig
local RadioContentSpecialNews = LTConfig.RadioContentSpecialNewsConfig
local M = {
	["By\\xb8x^\\x80\\xfbCohWH"] = -100,
	["\\xd0\\xc8$7\\xf4"] = false,
	["\\xf6M\\xd4\\xb9h\\xafR\\xb5\\xae"] = 0,
	["\\xf7\\x88\\xde\\xef܇\\xe1\\x97--"] = 100,
	["\\xf1Z\\xd1\\x80N\\xadC\\xbd\\xb3"] = -100,
	["\\x8d5$6w\\xabN\\xd5\"\\xa7\\xbc"] = 100,
	["\\xe8\\x8a\\xe2.\\xe2\\xe5\\xbb\\xe2\\x97.,"] = true,
	["1\\xf4V8\t\\xd8.\\xb7E\\xa8Y\\x93\\x92"] = 1,
	["\\xf1Z\\xd9\\xb5I\\x95_\\xbd\\xb3"] = 0,
	["\\xf6M\\xc5\\xb2q\\xa0C\\xa3\\xb3"] = false,
	["A[ʴ\\x8b+\\xb7\\xc7\\xfc"] = 0,
	["\\xe8\\x8a\\xe2?\\xe9\\xee\\xa5\\xf8\\x91)+"] = false,
	VehicleToRadioInfoDic = {},
	radioMapList = {},
	specialRadioDic = {},
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self.RefreshRadioChannel(self)
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType < gSwitchSceneType.Reconnect then
			return
		end

		for vehicleId, info in pairs(self.VehicleToRadioInfoDic) do
			self.StopRadio(self, vehicleId)
		end

		self.VehicleToRadioInfoDic = {}
	end,
	RefreshRadioChannel = function (self, channel)
		self.openCloudMusic = not UniSDKManager.isOversea

		if type(channel) ~= "userdata" then
			channel = channel.ToTable(channel)
		end

		table.clear(self.radioMapList)

		if channel and #channel <= 0 then
			for i = 1, #channel do
				if not self.IsCloudLoginRadio(self, channel[i]) and self.HasAnyUnlockedSong(self, channel[i]) then
					table.insert(self.radioMapList, channel[i])
				end
			end
		else
			for i = 0, VehicleRadioConfig.count - 1 do
				local config = VehicleRadioConfig.LoadAt(i)

				if not self.IsCloudLoginRadio(self, config.Id) and self.HasAnyUnlockedSong(self, config.Id) then
					table.insert(self.radioMapList, config.Id)
				end
			end
		end

		if self.openCloudMusic then
			self.RefreshLoginChannel(self)
		end

		self.radioCount = #self.radioMapList
		self.isPause = false
		self.radioVolume = 100
		self.preRadioVolume = 100

		gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, self.radioVolume)

		for vehicleId, info in pairs(self.VehicleToRadioInfoDic) do
			local newIndex = self.GetRadioIndexById(self, info.curRadioId)

			if newIndex ~= 0 then
				self.PlayRadio(self, vehicleId)
			else
				info.curRadioIndex = newIndex

				if not info.isCloudMusic then
					local radioCfg = VehicleRadioConfig.GetConfig(info.curRadioId)

					if radioCfg and radioCfg.SoundDataList then
						local filteredList = self.FilterUnlockedSongs(self, radioCfg.SoundDataList)
						info.songList = filteredList

						if #filteredList <= 0 then
							if info.songIndex >= #filteredList or info.songIndex < 0 then
								info.songIndex = 1
							end
						else
							self.PlayRadio(self, vehicleId)
						end
					end
				end
			end
		end
	end
}

M.RefreshLoginChannel = function(self)
	local isLogin = self.GetLogin(self)

	if isLogin then
		if not table.contains(self.radioMapList, VehicleRadioConfig.Like) then
			table.insert(self.radioMapList, 1, VehicleRadioConfig.Like)
		end

		if not table.contains(self.radioMapList, VehicleRadioConfig.DailyRecommendation) then
			table.insert(self.radioMapList, 1, VehicleRadioConfig.DailyRecommendation)
		end
	else
		if table.contains(self.radioMapList, VehicleRadioConfig.DailyRecommendation) then
			array.remove(self.radioMapList, VehicleRadioConfig.DailyRecommendation)
		end

		if table.contains(self.radioMapList, VehicleRadioConfig.Like) then
			array.remove(self.radioMapList, VehicleRadioConfig.Like)
		end
	end

	self.radioCount = #self.radioMapList

	for k, v in pairs(M.VehicleToRadioInfoDic) do
		if not isLogin and self.IsCloudLoginRadio(self, v.curRadioId) then
			self.PlayRadio(self, v.vehicleId)
		else
			v.curRadioIndex = self.GetRadioIndexById(self, v.curRadioId)
		end
	end
end

M.InsertSpecialRadio = function(self, id, followGo)
	if self.specialRadioDic[id] then
		print_error("RadioPlayerManager specialRadioDic 已经存在id :", tostring(id))

		return
	end

	self.specialRadioDic[id] = followGo
end

M.RemoveSpecialRadio = function(self, id)
	self.specialRadioDic[id] = nil
end

M.GetRadioIdByIndex = function(self, index)
	return self.radioMapList[index] or 0
end

M.GetRadioIndexById = function(self, radioId)
	for i = 1, #self.radioMapList do
		if self.radioMapList[i] ~= radioId then
			return i
		end
	end

	return 0
end

M.GetRadioInfoByVehicleId = function(self, vehicleId)
	if not vehicleId or vehicleId ~= 0 then
		return
	end

	return self.VehicleToRadioInfoDic[vehicleId]
end

M.GetFirstRadioInfo = function(self)
	for k, v in pairs(M.VehicleToRadioInfoDic) do
		return v
	end
end

M.GetTotalRadioCount = function(self, vehicleId)
	return self.radioCount
end

M.GetRadioNameNumberAndIconById = function(self, radioInfo)
	if not radioInfo then
		return
	end

	local config = VehicleRadioConfig.GetConfig(radioInfo.curRadioId)

	if not radioInfo.isCloudMusic then
		if config and config.RadioName and config.RadioNumber then
			return config.RadioName, config.RadioNumber, config.RadioIcon, false
		end
	else
		local webUrl = radioInfo.curRadioId ~= VehicleRadioConfig.DailyRecommendation and NeteaseCloudMusicManager.Instance.dailyRecommendationCoverUrl or NeteaseCloudMusicManager.Instance.ILikeCoverUrl

		return config.RadioName, config.RadioNumber, webUrl, true
	end

	print_error("RadioPlayerManager GetRadioNameNumberAndIconByIndex index is invalid,index is " .. tostring(id) .. ",VehicleRadioConfig length is " .. VehicleRadioConfig.count)

	return ""
end

M.GetRadioCurIndex = function(self, vehicleId)
	local radioInfo = self.GetRadioInfoByVehicleId(self, vehicleId)

	if radioInfo and radioInfo.songIndex < #radioInfo.songList then
		return radioInfo.curRadioIndex
	end

	return 0
end

M.GetRadioCurSongNameById = function(self, vehicleId)
	local radioInfo = self.GetRadioInfoByVehicleId(self, vehicleId)

	if radioInfo then
		if radioInfo.isCloudMusic then
			if radioInfo.cloudSongList and radioInfo.songIndex < table.count(radioInfo.cloudSongList) then
				return radioInfo.cloudSongList[radioInfo.songIndex].name
			end
		elseif radioInfo.songIndex < #radioInfo.songList then
			local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

			if radioSongsCfg then
				return radioSongsCfg.RadioSong
			end
		end
	end

	return ""
end

M.GetRadioCurArtistNameById = function(self, vehicleId)
	local radioInfo = self.GetRadioInfoByVehicleId(self, vehicleId)

	if radioInfo then
		if radioInfo.isCloudMusic then
			if radioInfo.cloudSongList and radioInfo.songIndex < table.count(radioInfo.cloudSongList) then
				return radioInfo.cloudSongList[radioInfo.songIndex].artistName
			end
		elseif radioInfo.songIndex < #radioInfo.songList then
			local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

			if radioSongsCfg then
				return radioSongsCfg.RadioSinger
			end
		end
	end

	return ""
end

M.PlayRadio = function(self, vehicleId, radioIndex, songIndex, songTime)
	local vehicleGo = nil

	if vehicleId ~= self.MotorRiderId then
		vehicleGo = gCS.MyPlayerManager.PlayerUnit.PlayerObj.gameObject
	elseif self.specialRadioDic[vehicleId] then
		vehicleGo = self.specialRadioDic[vehicleId]
	else
		local vehicleUnit = gDriveVehiclesManager.cs_manager:GetBaseVehicle(vehicleId)

		if not vehicleUnit then
			print_warn("RadioPlayerManager PlayRadio vehicleId is :" .. ulong.tostring(vehicleId) .. ",vehicleUnit is null")

			return
		end

		vehicleGo = vehicleUnit.gameObject
	end

	self.StopRadio(self, vehicleId)

	if self.radioCount < 0 then
		return
	end

	if not radioIndex then
		math.randomseed(tostring(os.time()):reverse():sub(1, 6))

		radioIndex = math.random(1, self.radioCount)

		if self.preSwitchRadio and self.preSwitchRadio < self.radioCount then
			radioIndex = self.preSwitchRadio
			songIndex = self.preSwitchSongIndex
		end
	end

	if self.radioCount >= radioIndex then
		print_error("RadioPlayerManager 电台的播放序号超过总电台数目 radioIndex is :", tostring(radioIndex), ",total count is :", tostring(self.radioCount))

		return
	end

	local radioId = self:GetRadioIdByIndex(radioIndex)
	self.preSwitchRadio = nil
	self.preSwitchSongIndex = nil
	local radioCfg = VehicleRadioConfig.GetConfig(radioId)
	local radioInfo = {
		["\\xe6N9\\xc3\\x90H\\xaf_\\xa3\\xbe"] = false,
		["\\xd0\\xc8$7\\xf4"] = false,
		["3/.\\xe0z\\x96\\xf0\\xad7\\xf2\\xc1\\xe9z\\xfc"] = false,
		["j\\x88\\x9b\\x89ӹ\\xc6>\\xba\\xa6 "] = false,
		["D\\xbd\\x87\\xa1\\xb2"] = false,
		["bw\\xbe|z\\xbd\\xfbDoTwH"] = 0,
		vehicleId = vehicleId,
		followGo = vehicleGo,
		curRadioIndex = radioIndex,
		curRadioId = radioId,
		songList = self:FilterUnlockedSongs(radioCfg.SoundDataList) or {},
		isCloudMusic = radioCfg.PlaylistId == nil or self:IsCloudLoginRadio(radioId),
		cloudPlaylistId = radioCfg.PlaylistId,
		songIndex = songIndex or 0,
		supportRandomContent = radioCfg.DJName == DJNameType.None,
		markVoiceQueue = {}
	}
	self.VehicleToRadioInfoDic[vehicleId] = radioInfo
	self.curRadioIndex = radioIndex

	if not gRadioPlayerManager.openRadioSound then
		gRadioPlayerManager:SetRadioVolume(radioInfo, 0)
	end

	if radioInfo.isCloudMusic then
		radioInfo.songIndex = 0

		if radioId ~= VehicleRadioConfig.DailyRecommendation then
			slot9 = NeteaseCloudMusicManager.Instance

			slot9:GetDailyRecommendationSongIds(function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		elseif radioId ~= VehicleRadioConfig.Like then
			slot9 = NeteaseCloudMusicManager.Instance

			slot9:GetILikeSongIds(function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		else
			slot9 = NeteaseCloudMusicManager.Instance

			slot9:GetSongIdsByListId(radioInfo.cloudPlaylistId, function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		end
	else
		if radioInfo.songIndex < 0 then
			radioInfo.songIndex = math.random(1, #radioInfo.songList)
		end

		songTime = songTime or self:GetRandomSeekTime(radioInfo)

		self:PlaySong(radioInfo, songTime, true)
	end
end

M.GetRandomSeekTime = function(self, radioInfo)
	local randomSeekTime = nil

	if radioInfo.songList and radioInfo.songIndex < #radioInfo.songList then
		local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

		if radioSongsCfg then
			local soundId = radioSongsCfg.SoundId
			local soundConfig = SoundEventConfig.GetConfig(soundId)

			if soundConfig and not soundConfig.IsContinuousWithSpecialTransition then
				local curLanguageIndex = AudioManager.Instance:GetAudioLengthIndex() + 1

				if curLanguageIndex < #soundConfig.MaxLength then
					local randomData = math.random() * 0.2
					randomSeekTime = randomData * soundConfig.MaxLength[curLanguageIndex]
				end
			end
		end
	end

	return randomSeekTime
end

M.RequestCloundCallBack = function(self, radioInfo, playlistId, songTime)
	radioInfo.cloudSongList = playlistId.ToTable(playlistId)

	if radioInfo.songIndex < 0 then
		radioInfo.songIndex = math.random(1, #radioInfo.cloudSongList)
	end

	radioInfo.requestFinish = true

	if gSoundMgr.OpenDebug then
		local count = radioInfo and #radioInfo.cloudSongList or 0

		print_notice("======RadioPlayerManager 电台 id:", tostring(radioInfo.curRadioId), "，电台序号 index:", tostring(radioInfo.curRadioIndex), ",总歌曲数目:", count)

		for i = 1, count do
			print_notice("==RadioPlayerManager i:", i, ",songName is :", radioInfo.cloudSongList[i].name)
		end

		print_notice("======")
	end

	if not radioInfo.isEnd then
		self.PlaySong(self, radioInfo, songTime)
	end
end

M.PlaySong = function(self, radioInfo, seekTime, isFadeIn)
	if not radioInfo then
		return
	end

	local GetSoundDataCb = function(soundData, startCb, endCb)
		if soundData then
			local startCallBack = nil

			if seekTime then
				startCallBack = function(uuid, data)
					if data and seekTime then
						if isFadeIn then
							data.Pause(data, 0)
						end

						data.SeekToTime(data, seekTime)

						if isFadeIn then
							data.Resume(data, 300, 7)
						end
					end

					if startCb then
						startCb()
					end
				end
			end

			local beforeCallBack = function(CS_data)
				if CS_data then
					CS_data.Level = 100
				end
			end

			soundData.followGo = radioInfo.followGo
			local onlineSound = soundData.externalId >= 0
			local markCallBack = nil
			radioInfo.Nid = gSoundMgr:PlaySoundByData(soundData, nil, startCallBack, function (uuid, soundData)
				self:OnRadioSongEnd(radioInfo)

				if endCb then
					endCb()
				end
			end, beforeCallBack, nil, markCallBack)

			if radioInfo.supportRandomContent and onlineSound then
				local data = gSoundMgr:GetSoundDataByNid(radioInfo.Nid)

				if data then
					data.AddOnlineMarkFun(data, function (mark)
						self:OnRadioMusicMark(radioInfo, mark)
					end)
				end
			end

			if self:IsSendLinkSync(radioInfo) then
				local id = soundData.externalId
				id = id or soundData.templateId

				CS_RadioManager.Instance:SendRadioSync_PlaySong(radioInfo.vehicleId, radioInfo.curRadioIndex, radioInfo.songIndex, id, soundData.externalSource)

				local volume = self:GetRealRadioVolume()

				CS_RadioManager.Instance:SendRadioSync_SetVolume(radioInfo.vehicleId, volume)
			end

			gMessageManager:SendMessage(gEventConstants.PLAYER_RADIO_SONG_PLAY, {
				vehicleId = radioInfo.vehicleId,
				radioIndex = radioInfo.curRadioIndex
			})
		end

		gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
	end

	local soundData = nil

	if radioInfo.isCloudMusic then
		if not radioInfo.cloudSongList or table.count(radioInfo.cloudSongList) >= radioInfo.songIndex then
			return
		end

		local songId = radioInfo.cloudSongList[radioInfo.songIndex].id
		seekTime = nil
		slot7 = NeteaseCloudMusicManager.Instance

		slot7:GetPlaySongUrlById(songId, function (songUrl)
			if songUrl then
				soundData = gSoundMgr:CreateSoundData(nil, , , songUrl, nil, LX6.Audio.ExternalSourceType.Audio_Source_Mp3_Url)
			end

			GetSoundDataCb(soundData, function ()
				if songUrl then
					NeteaseCloudMusicManager.Instance:SendStartPlayRecord(songId)
				end
			end, function ()
				if songUrl then
					NeteaseCloudMusicManager.Instance:SendEndPlayRecord(songId)
				end
			end)
		end)

		return
	end

	if not radioInfo.songList or radioInfo.songIndex <= #radioInfo.songList then
		return
	end

	self.GetRadioVoiceData(self, radioInfo)

	local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

	if radioSongsCfg then
		if radioSongsCfg.OnlineUrlId <= 0 then
			seekTime = nil
			soundData = gSoundMgr:CreateSoundData(nil, , , , radioSongsCfg.OnlineUrlId, LX6.Audio.ExternalSourceType.Audio_Source_Mp3_UrlId)
		elseif radioSongsCfg.SoundId <= 0 then
			soundData = gSoundMgr:CreateSoundData(radioSongsCfg.SoundId)
		end
	end

	GetSoundDataCb(soundData)
end

M.GetRadioVoiceData = function(self, radioInfo)
	if not radioInfo.supportRandomContent then
		return
	end

	local curRadioId = radioInfo.curRadioId
	local curSongIndex = radioInfo.songIndex
	slot4 = gClientToGameSceneDelegate

	slot4:AskGetVehicleRadioContent(curRadioId, curSongIndex).Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if not radioInfo or radioInfo.isEnd then
			return
		end

		if radioInfo.curRadioId == curRadioId or radioInfo.songIndex == curSongIndex then
			print_warn("RadioPlayerManager GetRadioVoiceData radioId 或者 songIndex不匹配 request radioId", curRadioId, ",request songIndex", curSongIndex, ",radioInfo.curRadioId", radioInfo.curRadioId, ",radioInfo.songIndex", radioInfo.songIndex)

			return
		end

		radioInfo.randomContent = data
	end
end

M.StopRadio = function(self, vehicleId)
	local info = self.VehicleToRadioInfoDic[vehicleId]

	if not info then
		return
	end

	self:StopMarkVoices(info)

	info.isEnd = true
	local Nid = info.Nid

	gSoundMgr:StopSoundByNid(Nid)

	if self:IsSendLinkSync(info) then
		CS_RadioManager.Instance:SendRadioSync_Stop(vehicleId)
	end

	self.VehicleToRadioInfoDic[vehicleId] = nil
end

M.SwitchRadio = function(self, vehicleId, addValue)
	if not vehicleId then
		return false
	end

	if Time.realtimeSinceStartup - self.preSwitchTime < self.SwitchRadioCD then
		return false
	end

	local radioInfo = M:GetRadioInfoByVehicleId(vehicleId)

	if not radioInfo then
		return false
	end

	local targetIndex = radioInfo.curRadioIndex + addValue

	if self.radioCount >= targetIndex then
		targetIndex = 1
	elseif targetIndex < 0 then
		targetIndex = self.radioCount
	end

	self:PlayRadio(radioInfo.vehicleId, targetIndex)

	self.preSwitchTime = Time.realtimeSinceStartup

	gClientToGameSceneDelegate:AskSwitchVehicleRadio(targetIndex)

	return true
end

M.SwitchTargetRadio = function(self, vehicleId, radioIndex, songIndex)
	if not radioIndex then
		return false
	end

	if Time.realtimeSinceStartup - self.preSwitchTime < self.SwitchRadioCD then
		return false
	end

	local radioInfo = nil

	if type(vehicleId) ~= "number" and vehicleId >= 0 then
		radioInfo = M:GetFirstRadioInfo()
	else
		radioInfo = M:GetRadioInfoByVehicleId(vehicleId)
	end

	if radioInfo then
		self:PlayRadio(radioInfo.vehicleId, radioIndex, songIndex)

		self.preSwitchTime = Time.realtimeSinceStartup

		gClientToGameSceneDelegate:AskSwitchVehicleRadio(radioIndex)
		gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE, radioIndex)
	else
		self.preSwitchRadio = radioIndex
		self.preSwitchSongIndex = songIndex
	end

	return true
end

M.SetRadioVolume = function(self, radioInfo, volume)
	if self.radioVolume ~= volume then
		return
	end

	volume = math.min(volume, 100)
	volume = math.max(volume, 0)
	self.preRadioVolume = self.radioVolume
	self.radioVolume = volume
	local realVolume = self:GetRealRadioVolume()

	gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, realVolume)

	if (math.abs(realVolume - self.preRealVolume) >= 7 or realVolume <= 97) and self.IsSendLinkSync(self, radioInfo) then
		CS_RadioManager.Instance:SendRadioSync_SetVolume(radioInfo.vehicleId, realVolume)
	end

	self.preRealVolume = realVolume
end

M.GetRealRadioVolume = function(self)
	return (self.isPause or not self.openRadioSound) and 0 or self.radioVolume
end

M.SetPauseState = function(self, isPause, radioInfo)
	if isPause == self.isPause then
		self.isPause = isPause

		if radioInfo then
			local volume = self:GetRealRadioVolume()

			gSoundMgr:SetGlobalRTPC(gSoundMgr.RTPCGroup.RadioVolume, volume)

			if self:IsSendLinkSync(radioInfo) then
				CS_RadioManager.Instance:SendRadioSync_SetVolume(radioInfo.vehicleId, volume)
			end
		end
	end
end

M.GetLogin = function(self)
	return NeteaseCloudMusicManager.Instance.IsLogin
end

M.IsCloudLoginRadio = function(self, radioId)
	if not radioId then
		return false
	end

	return radioId ~= VehicleRadioConfig.DailyRecommendation or radioId ~= VehicleRadioConfig.Like
end

M.IsSendLinkSync = function(self, radioInfo)
	if gLinkManager.LinkMode ~= UX.Game.LinkMode.None then
		return false
	elseif radioInfo and radioInfo.vehicleId == self.MotorRiderId then
		return true
	end

	return false
end

M.IsSongDefault = function(self, radioSongsId)
	local radioSongsCfg = RadioSongsConfig.GetConfig(radioSongsId)

	if not radioSongsCfg then
		return true
	end

	return radioSongsCfg.IsDefaultGain ~= true
end

M.IsSongUnlocked = function(self, radioSongsId)
	if self.IsSongDefault(self, radioSongsId) then
		return true
	end

	local songInfoDict = gPlayerManager.infoMinor.bindData.PlayerRadioSongsData and gPlayerManager.infoMinor.bindData.PlayerRadioSongsData.SongInfoDict

	if songInfoDict and songInfoDict[radioSongsId] then
		return true
	end

	return false
end

M.FilterUnlockedSongs = function(self, songList)
	if not songList then
		return {}
	end

	local filtered = {}

	for i = 1, #songList do
		if self.IsSongUnlocked(self, songList[i]) then
			table.insert(filtered, songList[i])
		end
	end

	return filtered
end

M.HasAnyUnlockedSong = function(self, radioId)
	local radioCfg = VehicleRadioConfig.GetConfig(radioId)

	if not radioCfg then
		return false
	end

	if radioCfg.PlaylistId then
		return true
	end

	local songList = radioCfg.SoundDataList

	if not songList then
		return false
	end

	for i = 1, #songList do
		if self.IsSongUnlocked(self, songList[i]) then
			return true
		end
	end

	return false
end

M.SyncAddRadioSong = function(self)
	self.RefreshRadioChannel(self)
end

M.StopMarkVoices = function(self, radioInfo)
	if radioInfo.markVoiceNid and radioInfo.markVoiceNid <= 0 then
		gSoundMgr:StopSoundByNid(radioInfo.markVoiceNid)

		radioInfo.markVoiceNid = 0
	end

	radioInfo.markVoiceQueue = {}
	radioInfo.randomContent = nil
	radioInfo.markVoicesActive = false
	radioInfo.pendingNextSong = false
end

M.OnRadioMusicMark = function(self, radioInfo, cue)
	if string.is_null_or_empty(cue) then
		return
	end

	if not radioInfo or not radioInfo.randomContent then
		return
	end

	local playRandomContent = false

	if radioInfo.randomContent.MarkType ~= UX.Game.RadioMarkType.Middle and string.starts_with(cue, "Radio_Voice_Mid") then
		playRandomContent = true
	elseif radioInfo.randomContent.MarkType ~= UX.Game.RadioMarkType.End and string.starts_with(cue, "Radio_Voice_End") then
		playRandomContent = true
	end

	if playRandomContent then
		self.OnMarkVoicesReady(self, radioInfo)
	end
end

M.OnMarkVoicesReady = function(self, radioInfo)
	if not radioInfo or not radioInfo.randomContent then
		return
	end

	if radioInfo.isEnd then
		return
	end

	local voices = self.GetVoicesByContent(self, radioInfo.randomContent)

	if not voices then
		return
	end

	radioInfo.markVoicesActive = true
	radioInfo.markVoiceQueue = voices

	self.PlayNextMarkVoice(self, radioInfo)
end

M.PlayNextMarkVoice = function(self, radioInfo)
	if radioInfo.isEnd then
		return
	end

	local soundId = table.remove(radioInfo.markVoiceQueue, 1)

	if not soundId then
		self.OnAllMarkVoicesEnd(self, radioInfo)

		return
	end

	local soundData = gSoundMgr:CreateSoundData(soundId)

	if not soundData then
		self.PlayNextMarkVoice(self, radioInfo)

		return
	end

	slot4 = gSoundMgr
	local nid = slot4:PlaySoundByData(soundData, nil, , function (uuid, sd)
		radioInfo.markVoiceNid = 0

		self:PlayNextMarkVoice(radioInfo)
	end)

	if nid and nid <= 0 then
		radioInfo.markVoiceNid = nid
	else
		self.PlayNextMarkVoice(self, radioInfo)
	end
end

M.OnAllMarkVoicesEnd = function(self, radioInfo)
	radioInfo.markVoicesActive = false
	radioInfo.markVoiceNid = 0

	if radioInfo.pendingNextSong then
		radioInfo.pendingNextSong = false

		self.AdvanceToNextSong(self, radioInfo)
	end
end

M.OnRadioSongEnd = function(self, radioInfo)
	if radioInfo.isEnd then
		return
	end

	if radioInfo.markVoicesActive then
		radioInfo.pendingNextSong = true
	else
		self.AdvanceToNextSong(self, radioInfo)
	end
end

M.AdvanceToNextSong = function(self, radioInfo)
	local nextIndex = radioInfo.songIndex + 1

	if radioInfo.isCloudMusic and nextIndex >= #radioInfo.cloudSongList or not radioInfo.isCloudMusic and nextIndex <= #radioInfo.songList then
		nextIndex = 1
	end

	radioInfo.Nid = nil
	radioInfo.songIndex = nextIndex

	self.PlaySong(self, radioInfo)
end

M.GetVoicesByContent = function(self, randomContent)
	local cfgStart = RadioContentDJs.GetConfig(randomContent.StartContentId)
	local startSoundId = cfgStart and cfgStart.SoundId or 0

	if not cfgStart and randomContent.StartContentId <= 0 then
		print_warn("RadioPlayerManager GetVoicesByContent DJ StartContentId:" .. tostring(randomContent.StartContentId) .. " cfg is nil, 配表找不到")
	end

	local cfgEnd = RadioContentDJs.GetConfig(randomContent.EndContentId)
	local endSoundId = cfgEnd and cfgEnd.SoundId or 0

	if not cfgEnd and randomContent.EndContentId <= 0 then
		print_warn("RadioPlayerManager GetVoicesByContent DJ EndContentId:" .. tostring(randomContent.EndContentId) .. " cfg is nil, 配表找不到")
	end

	local soundId = 0

	if randomContent.ContentType ~= RadioContentType.Ad then
		local cfg = RadioContentAds.GetConfig(randomContent.ContentId)
		soundId = cfg and cfg.SoundId or 0

		if not cfg and randomContent.ContentId <= 0 then
			print_warn("RadioPlayerManager GetVoicesByContent Ad ContentId:" .. tostring(randomContent.ContentId) .. " cfg is nil, 配表找不到")
		end
	elseif randomContent.ContentType ~= RadioContentType.News then
		local cfg = RadioContentNews.GetConfig(randomContent.ContentId)
		soundId = cfg and cfg.SoundId or 0

		if not cfg and randomContent.ContentId <= 0 then
			print_warn("RadioPlayerManager GetVoicesByContent News ContentId:" .. tostring(randomContent.ContentId) .. " cfg is nil, 配表找不到")
		end
	elseif randomContent.ContentType ~= RadioContentType.Chat or randomContent.ContentType ~= RadioContentType.Comment then
		local cfg = RadioContentDJs.GetConfig(randomContent.ContentId)
		soundId = cfg and cfg.SoundId or 0

		if not cfg and randomContent.ContentId <= 0 then
			print_warn("RadioPlayerManager GetVoicesByContent DJ ContentId:" .. tostring(randomContent.ContentId) .. " cfg is nil, 配表找不到")
		end
	elseif randomContent.ContentType ~= RadioContentType.SpecialNews then
		local cfg = RadioContentSpecialNews.GetConfig(randomContent.ContentId)
		soundId = cfg and cfg.SoundId or 0

		if not cfg and randomContent.ContentId <= 0 then
			print_warn("RadioPlayerManager GetVoicesByContent SpecialNews ContentId:" .. tostring(randomContent.ContentId) .. " cfg is nil, 配表找不到")
		end
	end

	return {
		startSoundId,
		soundId,
		endSoundId
	}
end

M.EventHandler = {
	[gEventConstants.OPEN_VEHICLE_RADIO] = function (eventId, data)
		if gRadioPlayerManager.openRadioSound ~= true then
			return
		end

		gRadioPlayerManager.openRadioSound = true

		for k, v in pairs(M.VehicleToRadioInfoDic) do
			gRadioPlayerManager:SetRadioVolume(v, gRadioPlayerManager.preRadioVolume)
		end
	end,
	[gEventConstants.CLOSE_VEHICLE_RADIO] = function (eventId, data)
		if gRadioPlayerManager.openRadioSound ~= false then
			return
		end

		gRadioPlayerManager.openRadioSound = false

		for k, v in pairs(M.VehicleToRadioInfoDic) do
			gRadioPlayerManager:SetRadioVolume(v, 0)
		end
	end
}
gRadioPlayerManager = M

return gRadioPlayerManager
