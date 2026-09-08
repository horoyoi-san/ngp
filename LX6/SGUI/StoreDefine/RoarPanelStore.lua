-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RoarPanelStore.lua
-- Decompiled from: 01949_RoarPanelStore.lua_b9023b16d8af.luajit

C_RoarPanelStore = DefClass("C_RoarPanelStore", C_RoarPanelStore, C_BaseRadioPanelStore)
GroupName2Class.RoarPanelStore = C_RoarPanelStore
local M = C_RoarPanelStore
local RadioSongsRoarConfig = LTConfig.RadioSongsRoarConfig
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local RadioSongsConfig = LTConfig.RadioSongsConfig
local base = C_RoarPanelStore.base

M.OnAwake = function(self)
	base.OnAwake(self)

	self.radioType = base.RadioType.Roar
	self.instanceId = nil
	self.panelId = gPanelId.S_ROAR_PANEL
	self.radioInfo = nil
	self.EventHandler = {
		[gEventConstants.ROAR_RADIO_SONG_PLAY] = function (eventId, data)
			if data.instanceId ~= self.instanceId then
				self:RefreshMusicContent(data.radioIndex)
			end

			if gRoarPlayerManager.isPause then
				self.bindData.isPlaying = self.PLAYING_TYPE.FALSE
			else
				self.bindData.isPlaying = self.PLAYING_TYPE.TRUE
			end

			self.bindData.Rotator.IsPause = gRoarPlayerManager.isPause
		end
	}

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end
end

M.InitRadios = function(self)
	self.tabInfos = {}
	self.rightTabInfos = {}

	for i = 0, RadioSongsRoarConfig.count - 1 do
		local cfg = RadioSongsRoarConfig.LoadAt(i)
		local view = {
			title = cfg.RadioName,
			radioNumber = i + 1,
			isWebCover = base.ImageType.Local,
			webUrl = base.ImageType.Local,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			index = i + 1,
			radioId = i + 1
		}

		table.insert(self.tabInfos, view)
	end

	self.rightTabInfos = self.tabInfos

	base.InitRadios(self)
end

M.OnShow = function(self, panelId, data)
	self.instanceId = gRoarPlayerManager.curHandWeaponId

	self.RefreshRadioUI(self)
end

M.OnClose = function(self)
	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end
end

M.RefreshRadioUI = function(self)
	self:InitRadios()

	self.radioInfo = gRoarPlayerManager:GetRadioInfoById(self.instanceId)

	if not self.radioInfo then
		return
	end

	local index = self.radioInfo.curRadioIndex

	base.RefreshRadioUI(self, index, gRoarPlayerManager.isPause)
end

M.RefreshArtistName = function(self)
	if self.radioInfo.songIndex < #self.radioInfo.songList then
		local radioSongsCfg = RadioSongsConfig.GetConfig(self.radioInfo.songList[self.radioInfo.songIndex])

		if radioSongsCfg then
			self.bindData.songArtistName = radioSongsCfg.RadioSinger
		end
	end
end

M.PauseRadio = function(self, pause)
	gRoarPlayerManager:SetPauseState(pause, self.radioInfo)

	self.bindData.Rotator.IsPause = gRoarPlayerManager.isPause
end

M.SelectRadioChannel = function(self, index, syncLoopList)
	if not self.radioInfo then
		return
	end

	if index ~= self.radioInfo.curRadioIndex then
		return
	end

	local success = gRoarPlayerManager:SwitchTargetRadio(self.instanceId, index)

	if not success then
		base.RefreshRadioListSelect(self, self.radioInfo.curRadioIndex)

		return
	end

	self.radioInfo = gRoarPlayerManager:GetRadioInfoById(self.instanceId)

	if not self.radioInfo then
		return
	end

	base.SelectRadioChannel(self, index, syncLoopList)
end

M.OnVolumeBtnClick = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() and InputActionBind.activeGameDevice < GameDevice.KeyboardMouse then
		if gRoarPlayerManager.radioVolume <= 0 then
			gRoarPlayerManager:SetRadioVolume(self.radioInfo, 0)
		else
			gRoarPlayerManager:SetRadioVolume(self.radioInfo, gRoarPlayerManager.preRadioVolume)
		end
	else
		self.bindData.showVolumeBar = self.bindData.showVolumeBar ~= base.VOLUME_BAR_STATE.SHOW and base.VOLUME_BAR_STATE.HIDE or base.VOLUME_BAR_STATE.SHOW
	end

	self.RefreshVolumeBar(self)
end

M.OnVolumeSliderChange = function(self, value)
	gRoarPlayerManager:SetRadioVolume(self.radioInfo, value * 100)
end

M.OnVolumeSliderStep = function(self, step)
	if gRoarPlayerManager.radioVolume > 100 and step >= 0 or gRoarPlayerManager.radioVolume < 0 and step >= 0 then
		return
	end

	gRoarPlayerManager:SetRadioVolume(self.radioInfo, gRoarPlayerManager.radioVolume + step)
	self:RefreshVolumeBar()
end

M.GetRadioVolume = function(self)
	return gRoarPlayerManager.radioVolume
end

M.GetIsPause = function(self)
	return gRoarPlayerManager.isPause
end

M.GetRadioCurSongName = function(self)
	if self.radioInfo and self.radioInfo.songIndex < #self.radioInfo.songList then
		local radioSongsCfg = RadioSongsConfig.GetConfig(self.radioInfo.songList[self.radioInfo.songIndex])

		if radioSongsCfg then
			return radioSongsCfg.RadioSong
		end
	end
end
