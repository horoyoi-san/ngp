-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RadioPlayerPanelStore.lua
-- Decompiled from: 01907_RadioPlayerPanelStore.lua_d51d2e675bca.luajit

C_RadioPlayerPanelStore = DefClass("C_RadioPlayerPanelStore", C_RadioPlayerPanelStore, C_BaseRadioPanelStore)
GroupName2Class.RadioPlayerPanelStore = C_RadioPlayerPanelStore
local M = C_RadioPlayerPanelStore
local VehicleRadioConfig = LTConfig.VehicleRadioConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local NeteaseCloudMusicManager = LX6.Audio.NeteaseCloudMusic.NeteaseCloudMusicManager
local base = C_RadioPlayerPanelStore.base
M.LikeBtnType = {
	["R+y^"] = 1,
	["I*rL"] = 0
}
M.SongLikeState = {
	[")F\\xbd\\x87\\x88D"] = 0,
	["V+v^"] = 1
}

M.OnAwake = function(self)
	base.OnAwake(self)

	self.radioType = base.RadioType.Vehicle
	self.panelId = gPanelId.S_RADIO_PLAYER_PANEL
	self.vehicleId = nil
	self.radioInfo = nil
	self.EventHandler = {
		[gEventConstants.PLAYER_RADIO_SONG_PLAY] = function (eventId, data)
			if data.vehicleId ~= self.vehicleId then
				self:RefreshMusicContent(data.radioIndex)

				if gRadioPlayerManager.isPause then
					self.bindData.isPlaying = self.PLAYING_TYPE.FALSE
				else
					self.bindData.isPlaying = self.PLAYING_TYPE.TRUE
				end

				self.bindData.Rotator.IsPause = gRadioPlayerManager.isPause
			end
		end
	}

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end
end

M.InitRadios = function(self)
	self.tabInfos = {}
	self.rightTabInfos = {}

	for i = 1, gRadioPlayerManager.radioCount do
		local id = gRadioPlayerManager:GetRadioIdByIndex(i)
		local cfg = VehicleRadioConfig.GetConfig(id)
		local tagType = 0

		if id ~= VehicleRadioConfig.DailyRecommendation then
			tagType = 1
		elseif id ~= VehicleRadioConfig.Like then
			tagType = 2
		end

		local view = {
			title = cfg.RadioName,
			radioNumber = cfg.RadioNumber,
			tagType = tagType,
			isWebCover = (id ~= VehicleRadioConfig.DailyRecommendation or id ~= VehicleRadioConfig.Like) and base.ImageType.Web or base.ImageType.Local,
			webUrl = id ~= VehicleRadioConfig.DailyRecommendation and NeteaseCloudMusicManager.Instance.dailyRecommendationCoverUrl or NeteaseCloudMusicManager.Instance.ILikeCoverUrl,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			index = i,
			radioId = id
		}

		table.insert(self.tabInfos, view)
	end

	if not gRadioPlayerManager.openCloudMusic or gRadioPlayerManager:GetLogin() then
		self.rightTabInfos = self.tabInfos
	else
		local id = VehicleRadioConfig.DailyRecommendation
		local cfg = VehicleRadioConfig.GetConfig(id)
		local view = {
			["D\\xa0\\xa6\\xaa\\xae"] = 1,
			title = cfg.RadioName,
			radioNumber = cfg.RadioNumber,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			radioId = id
		}

		table.insert(self.rightTabInfos, view)

		id = VehicleRadioConfig.Like
		cfg = VehicleRadioConfig.GetConfig(id)
		view = {
			["D\\xa0\\xa6\\xaa\\xae"] = 2,
			title = cfg.RadioName,
			radioNumber = cfg.RadioNumber,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			radioId = id
		}

		table.insert(self.rightTabInfos, view)

		for i = 1, gRadioPlayerManager.radioCount do
			id = gRadioPlayerManager:GetRadioIdByIndex(i)
			cfg = VehicleRadioConfig.GetConfig(id)
			view = {
				title = cfg.RadioName,
				radioNumber = cfg.RadioNumber,
				isWebCover = (id ~= VehicleRadioConfig.DailyRecommendation or id ~= VehicleRadioConfig.Like) and base.ImageType.Web or base.ImageType.Local,
				webUrl = id ~= VehicleRadioConfig.DailyRecommendation and NeteaseCloudMusicManager.Instance.dailyRecommendationCoverUrl or NeteaseCloudMusicManager.Instance.ILikeCoverUrl,
				coverId = cfg.RadioCover,
				iconId = cfg.RadioIcon,
				index = i + 2,
				radioId = id
			}

			table.insert(self.rightTabInfos, view)
		end
	end

	gRadioPlayerManager.radioPanel = self

	base.InitRadios(self)
end

M.OnShow = function(self, panelId, data)
	if data and type(data) ~= "userdata" then
		data = data.ToTable(data)
	end

	if data and data.vehicleId then
		self.vehicleId = data.vehicleId
	else
		self.vehicleId = gRadioPlayerManager.curDriveVehicleId
	end

	self:RefreshLogin()

	if gRadioPlayerManager:GetLogin() then
		slot3 = NeteaseCloudMusicManager.Instance

		slot3:GetRadioCoverUrls(function ()
			if not gPanelManager:IsPanelShowing(self.panelId) then
				return
			end

			self:RefreshRadioUI()
		end)
	else
		self.RefreshRadioUI(self)
	end
end

M.OnClose = function(self)
	base.RefreshQRCode(self)

	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

M.RefreshRadioUI = function(self)
	self:InitRadios()

	self.radioInfo = gRadioPlayerManager:GetRadioInfoByVehicleId(self.vehicleId)

	if not self.radioInfo then
		return
	end

	local index = self.radioInfo.curRadioIndex

	base.RefreshRadioUI(self, index, gRadioPlayerManager.isPause)
end

M.RefreshLogin = function(self)
	if gRadioPlayerManager.openCloudMusic then
		local isVip = NeteaseCloudMusicManager.Instance.isVip
		local privilegeType = isVip and base.PrivilegeType.Vip or base.PrivilegeType.Free30m

		if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
			if gRadioPlayerManager:GetLogin() then
				self.bindData.loginState = base.LoginState.Login
				self.bindData.privilegeType = privilegeType
			else
				self.bindData.loginState = base.LoginState.Logout
				self.bindData.privilegeType = base.PrivilegeType.None
			end
		elseif gCS.PanelManager.Instance.IsMobileMode then
			if gRadioPlayerManager:GetLogin() then
				self.bindData.loginState = base.LoginState.Login
				self.bindData.privilegeType = privilegeType
			else
				self.bindData.loginState = base.LoginState.Logout
				self.bindData.privilegeType = base.PrivilegeType.None
			end
		else
			self.bindData.loginState = base.LoginState.Hide
			self.bindData.privilegeType = base.PrivilegeType.None
		end
	else
		self.bindData.loginState = base.LoginState.Hide
		self.bindData.privilegeType = base.PrivilegeType.None
	end

	self.RefreshQRCode(self, false)
end

M.RefreshArtistName = function(self)
	self.bindData.songArtistName = gRadioPlayerManager:GetRadioCurArtistNameById(self.vehicleId)
end

M.RefreshNeteaseILike = function(self)
	if self.radioInfo and self.radioInfo.isCloudMusic then
		self.bindData.likeBtnType = self.LikeBtnType.Show
		local index = self.radioInfo.songIndex

		if self.radioInfo.cloudSongList and index > 0 and index < #self.radioInfo.cloudSongList then
			self.bindData.songLikeState = self.radioInfo.cloudSongList[index].liked and self.SongLikeState.Like or self.SongLikeState.UnLike
		else
			self.bindData.songLikeState = self.SongLikeState.UnLike
		end
	else
		self.bindData.likeBtnType = self.LikeBtnType.Hide
	end
end

M.PauseRadio = function(self, pause)
	gRadioPlayerManager:SetPauseState(pause, self.radioInfo)

	self.bindData.Rotator.IsPause = gRadioPlayerManager.isPause

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

M.SelectRadioChannel = function(self, index, syncLoopList)
	if not self.radioInfo then
		return
	end

	if index ~= self.radioInfo.curRadioIndex then
		return
	end

	local success = gRadioPlayerManager:SwitchTargetRadio(self.vehicleId, index)

	if not success then
		base.RefreshRadioListSelect(self, self.radioInfo.curRadioIndex)

		return
	end

	self.radioInfo = gRadioPlayerManager:GetRadioInfoByVehicleId(self.vehicleId)

	if not self.radioInfo then
		return
	end

	base.SelectRadioChannel(self, index, syncLoopList)
end

M.OnVolumeBtnClick = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() and InputActionBind.activeGameDevice < GameDevice.KeyboardMouse then
		if gRadioPlayerManager.radioVolume <= 0 then
			gRadioPlayerManager:SetRadioVolume(self.radioInfo, 0)
		else
			gRadioPlayerManager:SetRadioVolume(self.radioInfo, gRadioPlayerManager.preRadioVolume)
		end
	else
		self.bindData.showVolumeBar = self.bindData.showVolumeBar ~= base.VOLUME_BAR_STATE.SHOW and base.VOLUME_BAR_STATE.HIDE or base.VOLUME_BAR_STATE.SHOW
	end

	self.RefreshVolumeBar(self)
end

M.OnVolumeSliderChange = function(self, value)
	gRadioPlayerManager:SetRadioVolume(self.radioInfo, value * 100)
end

M.OnLoginBtnClick = function(self)
	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self:RefreshQRCode(true)

		slot1 = NeteaseCloudMusicManager.Instance

		slot1:GetQrcodeKey(function (qrcodeKey)
			if qrcodeKey then
				slot1 = self.bindData.QRCodeImage

				slot1:GenerateQRCode(qrcodeKey.qrCodeUrl)

				slot1 = NeteaseCloudMusicManager.Instance

				slot1:RequestQrcodeKeyPolling(qrcodeKey.uniKey, function (success)
					if success then
						slot1 = gRadioPlayerManager

						slot1:RefreshLoginChannel()

						slot1 = NeteaseCloudMusicManager.Instance

						slot1:GetRadioCoverUrls(function ()
							if not gPanelManager:IsPanelShowing(self.panelId) then
								return
							end

							self:RefreshRadioUI()
						end)
					else
						self:RefreshLogin()
						gDisplayMessageMgr:ShowMessageContent("登录失败")
						print_warn("RequestQrcodeKeyPolling fail,具体原因请看c#报错")
					end
				end)
			end
		end)
	elseif gCS.PanelManager.Instance.IsMobileMode then
		slot1 = NeteaseCloudMusicManager.Instance

		slot1:SendNeteaseOrpheusEvent(function (success)
			if success then
				slot1 = gRadioPlayerManager

				slot1:RefreshLoginChannel()

				slot1 = NeteaseCloudMusicManager.Instance

				slot1:GetRadioCoverUrls(function ()
					if not gPanelManager:IsPanelShowing(self.panelId) then
						return
					end

					self:RefreshRadioUI()
				end)
			else
				self:RefreshLogin()
				gDisplayMessageMgr:ShowMessageContent("登录失败")
				print_warn("SendNeteaseOrpheusEvent fail,具体原因请看c#报错")
			end
		end)
	end
end

M.OnLogoutBtnClick = function(self)
	NeteaseCloudMusicManager.Instance:QuitLogin()
	gRadioPlayerManager:RefreshLoginChannel()
	self:RefreshRadioUI()
end

M.OnSongLikeBtnClick = function(self)
	if not gRadioPlayerManager:GetLogin() then
		self.OnLoginBtnClick(self)

		return
	end

	if not self.radioInfo or not self.radioInfo.cloudSongList then
		return
	end

	local index = self.radioInfo.songIndex
	local songInfo = self.radioInfo.cloudSongList[index]
	local isLike = self.bindData.songLikeState ~= self.SongLikeState.Like

	NeteaseCloudMusicManager.Instance:SetSongLike(songInfo.id, not isLike, function (success)
		if success then
			songInfo.liked = not isLike

			self:RefreshNeteaseILike()

			local textId = songInfo.liked and 89901403 or 89901404

			gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(textId).Text)
		else
			print_error("OnSongLikeBtnClick fail,收藏喜欢歌曲失败,具体原因请看c#报错")
		end
	end)
end

M.OnVolumeSliderStep = function(self, step)
	if gRadioPlayerManager.radioVolume > 100 and step >= 0 or gRadioPlayerManager.radioVolume < 0 and step >= 0 then
		return
	end

	gRadioPlayerManager:SetRadioVolume(self.radioInfo, gRadioPlayerManager.radioVolume + step)
	self:RefreshVolumeBar()
end

M.GetRadioVolume = function(self)
	return gRadioPlayerManager.radioVolume
end

M.GetIsPause = function(self)
	return gRadioPlayerManager.isPause
end

M.GetRadioCurSongName = function(self)
	return gRadioPlayerManager:GetRadioCurSongNameById(self.vehicleId)
end

M.GetDataIconId = function(self)
	local dt = System.DateTime.Now
	local day = dt.Day

	if day > 1 and day < 3 then
		return 28021568 + day
	else
		return 28021572 + day
	end
end
