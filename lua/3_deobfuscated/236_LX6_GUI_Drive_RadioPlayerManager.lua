local VehicleRadioConfig = LTConfig.VehicleRadioConfig
local NeteaseCloudMusicManager = LX6.Audio.NeteaseCloudMusic.NeteaseCloudMusicManager
local RadioSongsConfig = LTConfig.RadioSongsConfig
local M = {
	MotorRiderId = -100,
	isPause = false,
	curRadioIndex = 0,
	preRadioVolume = 61.8,
	radioVolume = 61.8,
	openRadioSound = true,
	SwitchRadioCD = 1,
	preSwitchTime = 0,
	curSoundPause = false,
	radioCount = 0,
	VehicleToRadioInfoDic = {},
	radioMapList = {},
	specialRadioDic = {},
	OnInit = function (self)
		for i, v in pairs(self.EventHandler) do
			gMessageManager:AddMessageListener(i, v)
		end

		self:RefreshRadioChannel()
	end,
	OnBeforeSwitchScene = function (self, switchType)
		if switchType <= gSwitchSceneType.Reconnect then
			return
		end

		for vehicleId, info in pairs(self.VehicleToRadioInfoDic) do
			self:StopRadio(vehicleId)
		end

		self.VehicleToRadioInfoDic = {}
	end,
	RefreshRadioChannel = function (self, channel)
		if type(channel) == "userdata" then
			channel = channel:ToTable()
		end

		table.clear(self.radioMapList)

		local isLogin = self:GetLogin()

		if channel and #channel > 0 then
			for i = 1, #channel do
				if isLogin or not self:IsCloudLoginRadio(channel[i]) then
					table.insert(self.radioMapList, channel[i])
				end
			end
		else
			for i = 0, VehicleRadioConfig.count - 1 do
				local config = VehicleRadioConfig.LoadAt(i)

				if isLogin or not self:IsCloudLoginRadio(config.Id) then
					table.insert(self.radioMapList, config.Id)
				end
			end
		end

		self.radioCount = #self.radioMapList
		self.isPause = false
		self.radioVolume = 61.8
		self.preRadioVolume = 61.8
	end
}

function M:RefreshLoginChannel()
	local isLogin = self:GetLogin()

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
		if not isLogin and self:IsCloudLoginRadio(v.curRadioId) then
			self:PlayRadio(v.vehicleId)
		else
			v.curRadioIndex = self:GetRadioIndexById(v.curRadioId)
		end
	end
end

function M:InsertSpecialRadio(id, followGo)
	if self.specialRadioDic[id] then
		print_error("RadioPlayerManager specialRadioDic 已经存在id :", tostring(id))

		return
	end

	self.specialRadioDic[id] = followGo
end

function M:RemoveSpecialRadio(id)
	self.specialRadioDic[id] = nil
end

function M:GetRadioIdByIndex(index)
	return self.radioMapList[index] or 0
end

function M:GetRadioIndexById(radioId)
	for i = 1, #self.radioMapList do
		if self.radioMapList[i] == radioId then
			return i
		end
	end

	return 0
end

function M:GetRadioInfoByVehicleId(vehicleId)
	if not vehicleId or vehicleId == 0 then
		return
	end

	return self.VehicleToRadioInfoDic[vehicleId]
end

function M:GetTotalRadioCount(vehicleId)
	return self.radioCount
end

function M:GetRadioNameNumberAndIconById(id)
	local config = VehicleRadioConfig.GetConfig(id)

	if config and config.RadioName and config.RadioNumber then
		return config.RadioName, config.RadioNumber, config.RadioIcon
	end

	print_error("RadioPlayerManager GetRadioNameNumberAndIconByIndex index is invalid,index is " .. tostring(id) .. ",VehicleRadioConfig length is " .. VehicleRadioConfig.count)

	return ""
end

function M:GetRadioCurIndex(vehicleId)
	local radioInfo = self:GetRadioInfoByVehicleId(vehicleId)

	if radioInfo and radioInfo.songIndex <= #radioInfo.songList then
		return radioInfo.curRadioIndex
	end

	return 0
end

function M:GetRadioCurSongNameById(vehicleId)
	local radioInfo = self:GetRadioInfoByVehicleId(vehicleId)

	if radioInfo then
		if radioInfo.isCloudMusic then
			if radioInfo.cloudSongList and radioInfo.songIndex <= table.count(radioInfo.cloudSongList) then
				return radioInfo.cloudSongList[radioInfo.songIndex].name
			end
		elseif radioInfo.songIndex <= #radioInfo.songList then
			local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

			if radioSongsCfg then
				return radioSongsCfg.RadioSong
			end
		end
	end

	return ""
end

function M:GetRadioCurArtistNameById(vehicleId)
	local radioInfo = self:GetRadioInfoByVehicleId(vehicleId)

	if radioInfo then
		if radioInfo.isCloudMusic then
			if radioInfo.cloudSongList and radioInfo.songIndex <= table.count(radioInfo.cloudSongList) then
				return radioInfo.cloudSongList[radioInfo.songIndex].artistName
			end
		elseif radioInfo.songIndex <= #radioInfo.songList then
			local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

			if radioSongsCfg then
				return radioSongsCfg.RadioSinger
			end
		end
	end

	return ""
end

function M:PlayRadio(vehicleId, radioIndex, songIndex, songTime)
	local vehicleGo = nil

	if vehicleId == self.MotorRiderId then
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

	self:StopRadio(vehicleId)

	if not radioIndex then
		math.randomseed(tostring(os.time()):reverse():sub(1, 6))

		radioIndex = math.random(1, self.radioCount)

		if self.preSwitchRadio and self.preSwitchRadio <= self.radioCount then
			radioIndex = self.preSwitchRadio
		end
	end

	if self.radioCount < radioIndex then
		print_error("RadioPlayerManager 电台的播放序号超过总电台数目 radioIndex is :", tostring(radioIndex), ",total count is :", tostring(self.radioCount))

		return
	end

	local radioId = self:GetRadioIdByIndex(radioIndex)
	self.preSwitchRadio = nil
	local radioCfg = VehicleRadioConfig.GetConfig(radioId)
	local radioInfo = {
		requestFinish = false,
		isPause = false,
		isEnd = false,
		vehicleId = vehicleId,
		followGo = vehicleGo,
		curRadioIndex = radioIndex,
		curRadioId = radioId,
		songList = radioCfg.SoundDataList or {},
		isCloudMusic = radioCfg.PlaylistId ~= nil or self:IsCloudLoginRadio(radioId),
		cloudPlaylistId = radioCfg.PlaylistId,
		songIndex = songIndex or 0
	}
	self.VehicleToRadioInfoDic[vehicleId] = radioInfo
	self.curRadioIndex = radioIndex

	if radioInfo.isCloudMusic then
		if radioId == VehicleRadioConfig.DailyRecommendation then
			NeteaseCloudMusicManager.Instance:GetDailyRecommendationSongIds(function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		elseif radioId == VehicleRadioConfig.Like then
			NeteaseCloudMusicManager.Instance:GetILikeSongIds(function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		else
			NeteaseCloudMusicManager.Instance:GetSongIdsByListId(radioInfo.cloudPlaylistId, function (playlistId)
				self:RequestCloundCallBack(radioInfo, playlistId, songTime)
			end)
		end
	else
		if radioInfo.songIndex <= 0 then
			radioInfo.songIndex = math.random(1, #radioInfo.songList)
		end

		self:PlaySong(radioInfo, songTime)
	end
end

function M:RequestCloundCallBack(radioInfo, playlistId, songTime)
	radioInfo.cloudSongList = playlistId:ToTable()

	if radioInfo.songIndex <= 0 then
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
		self:PlaySong(radioInfo, songTime)
	end
end

function M:PlaySong(radioInfo, seekTime)
	if not radioInfo then
		return
	end

	local soundData = nil

	if radioInfo.isCloudMusic then
		if not radioInfo.cloudSongList or table.count(radioInfo.cloudSongList) < radioInfo.songIndex then
			return
		end

		soundData = gSoundMgr:CreateSoundData(nil, nil, nil, radioInfo.cloudSongList[radioInfo.songIndex].id, nil, LX6.Audio.ExternalSourceType.Audio_Source_Netease_Cloud)
	else
		if not radioInfo.songList or radioInfo.songIndex > #radioInfo.songList then
			return
		end

		local soundId = 0
		local radioSongsCfg = RadioSongsConfig.GetConfig(radioInfo.songList[radioInfo.songIndex])

		if radioSongsCfg then
			soundId = radioSongsCfg.SoundId
		end

		soundData = gSoundMgr:CreateSoundData(soundId)
	end

	if soundData then
		local startCallBack = nil

		if seekTime then
			function startCallBack(uuid, data)
				if data and seekTime then
					data:SeekToTime(seekTime)
				end
			end
		end

		local function beforeCallBack(CS_data)
			if CS_data then
				local volume = self:GetRealRadioVolume()

				CS_data:SetRTPCValue(gSoundMgr.RTPCGroup.RadioVolume, volume)

				CS_data.Level = 100
			end
		end

		soundData.followGo = radioInfo.followGo
		radioInfo.Nid = gSoundMgr:PlaySoundByData(soundData, nil, startCallBack, function (uuid, soundData)
			if not radioInfo.isEnd then
				local nextIndex = radioInfo.songIndex + 1

				if radioInfo.isCloudMusic and nextIndex > #radioInfo.cloudSongList or not radioInfo.isCloudMusic and nextIndex > #radioInfo.songList then
					nextIndex = 1
				end

				radioInfo.Nid = nil
				radioInfo.songIndex = nextIndex

				self:PlaySong(radioInfo)
			end
		end, beforeCallBack)

		gMessageManager:SendMessage(gEventConstants.PLAYER_RADIO_SONG_PLAY, {
			vehicleId = radioInfo.vehicleId,
			radioIndex = radioInfo.curRadioIndex
		})
	end

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

function M:StopRadio(vehicleId)
	local info = self.VehicleToRadioInfoDic[vehicleId]

	if not info then
		return
	end

	info.isEnd = true
	local Nid = info.Nid

	gSoundMgr:StopSoundByNid(Nid)

	self.VehicleToRadioInfoDic[vehicleId] = nil
end

function M:SwitchRadio(vehicleId, addValue)
	if not vehicleId then
		return false
	end

	if Time.realtimeSinceStartup - self.preSwitchTime <= self.SwitchRadioCD then
		return false
	end

	local radioInfo = M:GetRadioInfoByVehicleId(vehicleId)

	if not radioInfo then
		return false
	end

	local targetIndex = radioInfo.curRadioIndex + addValue

	if self.radioCount < targetIndex then
		targetIndex = 1
	elseif targetIndex <= 0 then
		targetIndex = self.radioCount
	end

	self:PlayRadio(radioInfo.vehicleId, targetIndex)

	self.preSwitchTime = Time.realtimeSinceStartup

	gClientToGameSceneDelegate:AskSwitchVehicleRadio(targetIndex)

	return true
end

function M:SwitchTargetRadio(vehicleId, radioIndex)
	if not radioIndex then
		return false
	end

	if Time.realtimeSinceStartup - self.preSwitchTime <= self.SwitchRadioCD then
		return false
	end

	local radioInfo = M:GetRadioInfoByVehicleId(vehicleId)

	if radioInfo then
		self:PlayRadio(radioInfo.vehicleId, radioIndex)

		self.preSwitchTime = Time.realtimeSinceStartup

		gClientToGameSceneDelegate:AskSwitchVehicleRadio(radioIndex)
		gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE, radioIndex)
	else
		self.preSwitchRadio = radioIndex
	end

	return true
end

function M:SetRadioVolume(radioInfo, volume)
	volume = math.min(volume, 100)
	volume = math.max(volume, 0)
	self.preRadioVolume = self.radioVolume
	self.radioVolume = volume
	local soundData = gSoundMgr:GetSoundDataByNid(radioInfo.Nid)
	local realVolume = self:GetRealRadioVolume()

	if soundData then
		soundData:SetRTPCValue(gSoundMgr.RTPCGroup.RadioVolume, realVolume)
	end
end

function M:GetRealRadioVolume()
	return (self.isPause or not self.openRadioSound) and 0 or self.radioVolume
end

function M:SetPauseState(isPause, radioInfo)
	if isPause ~= self.isPause then
		self.isPause = isPause

		if radioInfo then
			local soundData = gSoundMgr:GetSoundDataByNid(radioInfo.Nid)
			local volume = self:GetRealRadioVolume()

			if soundData then
				soundData:SetRTPCValue(gSoundMgr.RTPCGroup.RadioVolume, volume)
			end
		end
	end
end

function M:GetLogin()
	return NeteaseCloudMusicManager.Instance.IsLogin
end

function M:IsCloudLoginRadio(radioId)
	if not radioId then
		return false
	end

	return radioId == VehicleRadioConfig.DailyRecommendation or radioId == VehicleRadioConfig.Like
end

M.EventHandler = {
	[gEventConstants.OPEN_VEHICLE_RADIO] = function (eventId, data)
		if gRadioPlayerManager.openRadioSound == true then
			return
		end

		gRadioPlayerManager.openRadioSound = true

		for k, v in pairs(M.VehicleToRadioInfoDic) do
			gRadioPlayerManager:SetRadioVolume(v, 100)
		end
	end,
	[gEventConstants.CLOSE_VEHICLE_RADIO] = function (eventId, data)
		if gRadioPlayerManager.openRadioSound == false then
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
