C_RadioPlayerPanelStore = DefClass("C_RadioPlayerPanelStore", C_RadioPlayerPanelStore, C_StoreGroup)
GroupName2Class.RadioPlayerPanelStore = C_RadioPlayerPanelStore
local M = C_RadioPlayerPanelStore
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local VehicleRadioConfig = LTConfig.VehicleRadioConfig
local NeteaseCloudMusicManager = LX6.Audio.NeteaseCloudMusic.NeteaseCloudMusicManager
local LoginState = {
	Login = 2,
	Hide = 0,
	Logout = 1
}
local PLAYING_TYPE = {
	TRUE = 0,
	FALSE = 1
}
local VOLUME_BAR_STATE = {
	HIDE = 0,
	SHOW = 1
}
local SLIDER_LONG_PRESS_TYPE = {
	Down = 2,
	Up = 1,
	None = 0
}

function M:OnAwake()
	self.bindData.RadioList.luaSimpleRenderItem = self:CreateAction("OnRadioListItem")
	self.bindData.RadioLoopList.luaRenderItem = self:CreateAction(self.OnRadioLoopListItem)
	self.bindData.RadioLoopList.luaSelectedChanged = self:CreateAction(self.OnRadioLoopListSelectedChanged)
	self.bindData.songNameRect.luaInitContent = self:CreateAction(self.OnSongNameChange)
	self.bindData.RadioList.luaSimpleClick = self:CreateAction("OnRadioListClick")
	self.bindData.RadioLoopList.luaClick = self:CreateAction("OnRadioLoopListClick")
	self.bindData.BtnPlay.luaClick = self:CreateAction("OnPlayRadioClick")
	self.bindData.BtnNext.luaClick = self:CreateAction("OnNextRadioClick")
	self.bindData.BtnPre.luaClick = self:CreateAction("OnPreRadioClick")
	self.bindData.BtnExit.luaClick = self:CreateAction("OnCloseRadioClick")
	self.bindData.FullBtnExit.luaClick = self:CreateAction("OnCloseRadioClick")
	self.bindData.QRCodeBtnExit.luaClick = self:CreateAction("OnCloseRadioClick")
	self.bindData.ShowListBtn.luaClick = self:CreateAction("OnShowRadioListClick")
	self.bindData.VolumeBtn.luaHover = self:CreateAction("OnVolumeBtnHover")
	self.bindData.VolumeBtn.luaUnhover = self:CreateAction("OnVolumeBtnUnhover")
	self.bindData.VolumeBtn.luaClick = self:CreateAction("OnVolumeBtnClick")
	self.bindData.VolumeBarBg.luaHover = self:CreateAction("OnVolumeBarBgHover")
	self.bindData.VolumeBarBg.luaUnhover = self:CreateAction("OnVolumeBarBgUnhover")
	self.bindData.VolumeSlider.luaHover = self:CreateAction("OnVolumeSliderHover")
	self.bindData.VolumeSlider.luaUnhover = self:CreateAction("OnVolumeSliderUnhover")
	self.bindData.VolumeSlider.luaValueChanged = self:CreateAction("OnVolumeSliderChange")
	self.bindData.LoginButton.luaClick = self:CreateAction("OnLoginBtnClick")
	self.bindData.LogoutButton.luaClick = self:CreateAction("OnLogoutBtnClick")
	self.bindData.ControllerCloseBtn.luaClick = self:CreateAction("OnControllerCloseBtnClick")
	self.bindData.ControllerUpBtn.luaClick = self:CreateActionWithArgs("OnVolumeSliderStep", 1)
	self.bindData.ControllerUpLongBtn.luaBeginLongPress = self:CreateActionWithArgs("OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.Up)
	self.bindData.ControllerUpLongBtn.luaEndLongPress = self:CreateActionWithArgs("OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.None)
	self.bindData.ControllerDownBtn.luaClick = self:CreateActionWithArgs("OnVolumeSliderStep", -1)
	self.bindData.ControllerDownLongBtn.luaBeginLongPress = self:CreateActionWithArgs("OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.Down)
	self.bindData.ControllerDownLongBtn.luaEndLongPress = self:CreateActionWithArgs("OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.None)
	self.EventHandler = {
		[gEventConstants.PLAYER_RADIO_SONG_PLAY] = function (eventId, data)
			if data.vehicleId == self.vehicleId then
				self:RefreshMusicContent(data.radioIndex)

				if gRadioPlayerManager.isPause then
					self.bindData.isPlaying = PLAYING_TYPE.FALSE
				else
					self.bindData.isPlaying = PLAYING_TYPE.TRUE
				end

				self.bindData.Rotator.IsPause = gRadioPlayerManager.isPause
			end
		end
	}
	self.panelId = gPanelId.S_RADIO_PLAYER_PANEL
	self.vehicleId = nil
	self.radioInfo = nil
	self.tabInfos = {}
	self.volumeBtnHover = false
	self.volumeBarBgHover = false
	self.volumeSliderHover = false
	self.sliderLongPressType = SLIDER_LONG_PRESS_TYPE.None
	self.sliderLongPressMultiple = 30
	self.cutAnimeName = "S_Vx_RadioPlayerPanel_cut"
	self.closeAnimeName = "S_Vx_RadioPlayerPanel_close"

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end
end

function M:InitRadios()
	self.tabInfos = {}

	for i = 1, gRadioPlayerManager.radioCount do
		local id = gRadioPlayerManager:GetRadioIdByIndex(i)
		local cfg = VehicleRadioConfig.GetConfig(id)
		local view = {
			title = cfg.RadioName,
			radioNumber = cfg.RadioNumber,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			index = i,
			radioId = id
		}

		table.insert(self.tabInfos, view)
	end

	self.bindData.isPlaying = PLAYING_TYPE.TRUE

	self.bindData.RadioList:SetSimpleList(#self.tabInfos)
	self.bindData.RadioLoopList:SetList(self.tabInfos)

	gRadioPlayerManager.radioPanel = self
	self.coverTitle = ""
end

function M:OnShow(panelId, data)
	if data and type(data) == "userdata" then
		data = data:ToTable()
	end

	if data and data.vehicleId then
		self.vehicleId = data.vehicleId
	else
		self.vehicleId = gRadioPlayerManager.curDriveVehicleId
	end

	self:RefreshRadioUI()
end

function M:OnUpdate()
	if self.sliderLongPressType == SLIDER_LONG_PRESS_TYPE.None then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and GameDevice.KeyboardMouse < InputActionBind.activeGameDevice then
		if self.sliderLongPressType == SLIDER_LONG_PRESS_TYPE.Up then
			self:OnVolumeSliderStep(Time.deltaTime * self.sliderLongPressMultiple)
		elseif self.sliderLongPressType == SLIDER_LONG_PRESS_TYPE.Down then
			self:OnVolumeSliderStep(-1 * Time.deltaTime * self.sliderLongPressMultiple)
		end
	end
end

function M:OnClose()
	self:RefreshQRCode(false)

	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

function M:RefreshRadioUI()
	self:InitRadios()

	self.radioInfo = gRadioPlayerManager:GetRadioInfoByVehicleId(self.vehicleId)

	if not self.radioInfo then
		return
	end

	local index = self.radioInfo.curRadioIndex

	if gRadioPlayerManager.isPause then
		self.bindData.isPlaying = PLAYING_TYPE.FALSE
	else
		self.bindData.isPlaying = PLAYING_TYPE.TRUE
	end

	self.bindData.Rotator.IsPause = gRadioPlayerManager.isPause

	self.bindData.RadioList:SetItemSelected(index - 1, true)
	self.bindData.RadioLoopList:SelectItem(index - 1)
	self:RefreshMusicContent(index)
	self:RefreshVolumeBar()
	self:RefreshLogin()
end

function M:RefreshMusicContent(index)
	self.bindData.coverTitle = self.tabInfos[index].title
	self.bindData.coverIndex = self.tabInfos[index].radioNumber
	self.bindData.songArtistName = gRadioPlayerManager:GetRadioCurArtistNameById(self.vehicleId)

	self.bindData.songNameRect:SetContentDirty()

	self.bindData.coverImageId = self.tabInfos[index].coverId
end

function M:RefreshVolumeBar()
	if gCS.LuaUtils.IsNonMobileAdaptive() and InputActionBind.activeGameDevice <= GameDevice.KeyboardMouse then
		if self.volumeBtnHover or self.volumeBarBgHover or self.volumeSliderHover then
			self.bindData.showVolumeBar = VOLUME_BAR_STATE.SHOW
			self.bindData.VolumeSlider.value = gRadioPlayerManager.radioVolume / 100
		else
			self.bindData.showVolumeBar = VOLUME_BAR_STATE.HIDE
		end
	elseif self.bindData.showVolumeBar == VOLUME_BAR_STATE.SHOW then
		self.bindData.VolumeSlider.value = gRadioPlayerManager.radioVolume / 100
	end

	self.bindData.volumeState = self.bindData.VolumeSlider.value < 0.03 and 0 or 1
end

function M:RefreshLogin()
	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		self:RefreshQRCode(false)

		if gRadioPlayerManager:GetLogin() then
			self.bindData.loginState = LoginState.Login
		else
			self.bindData.loginState = LoginState.Logout
		end
	else
		self.bindData.loginState = LoginState.Hide
	end
end

function M:RefreshRadioList(isShow)
	if self.showRadioList == isShow then
		return
	end

	self.showRadioList = isShow

	if isShow then
		self.bindData.showRadioListType = 1
		self.bindData.showListBtnType = 5
	else
		self.bindData.showRadioListType = 0
		self.bindData.showListBtnType = 0
	end
end

function M:RefreshQRCode(isShow)
	if self.bindData.showQRCode ~= isShow then
		self.bindData.showQRCode = isShow

		if not isShow then
			NeteaseCloudMusicManager.Instance:StopQrcodeKeyPolling()
		end
	end
end

function M:PauseRadio(pause)
	gRadioPlayerManager:SetPauseState(pause, self.radioInfo)

	self.bindData.Rotator.IsPause = gRadioPlayerManager.isPause

	gMessageManager:SendMessage(gEventConstants.RADIO_STATE_CHANGE)
end

function M:SwitchRadio(addValue)
	if self.tabInfos then
		local targetIndex = self.radioInfo.curRadioIndex + addValue

		if targetIndex > #self.tabInfos then
			self:SelectRadioChannel(1)
		elseif targetIndex <= 0 then
			self:SelectRadioChannel(#self.tabInfos)
		else
			self:SelectRadioChannel(targetIndex)
		end
	end
end

function M:SelectRadioChannel(index, syncUI)
	if not self.radioInfo then
		return
	end

	if index == self.radioInfo.curRadioIndex then
		return
	end

	local success = gRadioPlayerManager:SwitchTargetRadio(self.vehicleId, index)

	if not success then
		return
	end

	self.radioInfo = gRadioPlayerManager:GetRadioInfoByVehicleId(self.vehicleId)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.RadioPlayerPanelAnimation, self.cutAnimeName)
	self.bindData.RadioList:SetItemSelected(index - 1, true)
	self.bindData.RadioList:RefreshList()
	self.bindData.RadioLoopList:SelectItem(index - 1)
	self:RefreshMusicContent(self.radioInfo.curRadioIndex)
end

function M:OnRadioListItem(btn, index)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and self.tabInfos and index <= #self.tabInfos then
		store.iconUrl = self.tabInfos[index].iconId
		store.radioNum = self.tabInfos[index].radioNumber
		store.radioName = self.tabInfos[index].title

		if index == self.radioInfo.curRadioIndex then
			store.buttonState = 5
			store.playState = gRadioPlayerManager.isPause and 1 or 0
		else
			store.buttonState = 0
			store.playState = 0
		end
	end
end

function M:OnRadioListClick(btn, index)
	index = index + 1

	if index ~= self.radioInfo.curRadioIndex then
		self:SelectRadioChannel(index)
	else
		self:OnPlayRadioClick()
	end
end

function M:OnRadioLoopListItem(btn, index, data)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and self.tabInfos and index <= #self.tabInfos then
		store.iconUrl = self.tabInfos[index].coverId
	end
end

function M:OnRadioLoopListClick(btn, data)
	self:SelectRadioChannel(data.index)
end

function M:OnRadioLoopListSelectedChanged()
	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)

		local selectedItem = self.bindData.RadioLoopList.selectedItem

		self:SelectRadioChannel(selectedItem.index)

		self.timer = nil
	end, 0.5):Start()
end

function M:OnSongNameChange(widget)
	local store = self:GetStoreByWidget(widget)
	store.songName = gRadioPlayerManager:GetRadioCurSongNameById(self.vehicleId)
end

function M:OnPlayRadioClick()
	if self.bindData.isPlaying == PLAYING_TYPE.TRUE then
		self.bindData.isPlaying = PLAYING_TYPE.FALSE

		self:PauseRadio(true)
	else
		self.bindData.isPlaying = PLAYING_TYPE.TRUE

		self:PauseRadio(false)
	end

	self.bindData.RadioList:RefreshList()
end

function M:OnNextRadioClick()
	self:SwitchRadio(1)
end

function M:OnPreRadioClick()
	self:SwitchRadio(-1)
end

function M:OnCloseRadioClick()
	if self.bindData.showQRCode then
		self:RefreshQRCode(false)
	elseif self.showRadioList then
		self:RefreshRadioList(false)
	else
		local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.RadioPlayerPanelAnimation, self.closeAnimeName)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.RadioPlayerPanelAnimation, self.closeAnimeName)
		Timer.New(function ()
			gPanelManager:Close(gPanelId.S_RADIO_PLAYER_PANEL)
		end, duration):Start()
	end
end

function M:OnShowRadioListClick()
	self:RefreshRadioList(not self.showRadioList)
end

function M:OnVolumeBtnHover()
	if self.volumeBtnUnhoverTimer then
		self.volumeBtnUnhoverTimer:Stop()
	end

	self.volumeBtnHover = true

	self:RefreshVolumeBar()
end

function M:OnVolumeBtnUnhover()
	self.volumeBtnUnhoverTimer = FrameTimer.New(function ()
		self.volumeBtnUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeBtnHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

function M:OnVolumeBtnClick()
	if gCS.LuaUtils.IsNonMobileAdaptive() and InputActionBind.activeGameDevice <= GameDevice.KeyboardMouse then
		if gRadioPlayerManager.radioVolume > 0 then
			gRadioPlayerManager:SetRadioVolume(self.radioInfo, 0)
		else
			gRadioPlayerManager:SetRadioVolume(self.radioInfo, gRadioPlayerManager.preRadioVolume)
		end
	else
		self.bindData.showVolumeBar = self.bindData.showVolumeBar == VOLUME_BAR_STATE.SHOW and VOLUME_BAR_STATE.HIDE or VOLUME_BAR_STATE.SHOW
	end

	self:RefreshVolumeBar()
end

function M:OnVolumeBarBgHover()
	if self.volumeBarBgUnhoverTimer then
		self.volumeBarBgUnhoverTimer:Stop()
	end

	self.volumeBarBgHover = true

	self:RefreshVolumeBar()
end

function M:OnVolumeBarBgUnhover()
	self.volumeBarBgUnhoverTimer = FrameTimer.New(function ()
		self.volumeBarBgUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeBarBgHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

function M:OnVolumeSliderHover()
	if self.volumeSliderUnhoverTimer then
		self.volumeSliderUnhoverTimer:Stop()
	end

	self.volumeSliderHover = true

	self:RefreshVolumeBar()
end

function M:OnVolumeSliderUnhover()
	self.volumeSliderUnhoverTimer = FrameTimer.New(function ()
		self.volumeSliderUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeSliderHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

function M:OnVolumeSliderChange(value)
	gRadioPlayerManager:SetRadioVolume(self.radioInfo, value * 100)
end

function M:OnLoginBtnClick()
	self:RefreshQRCode(true)
	NeteaseCloudMusicManager.Instance:GetQrcodeKey(function (qrcodeKey)
		if qrcodeKey then
			self.bindData.QRCodeImage:GenerateQRCode(qrcodeKey.qrCodeUrl)
			NeteaseCloudMusicManager.Instance:RequestQrcodeKeyPolling(qrcodeKey.uniKey, function (success)
				if success then
					gRadioPlayerManager:RefreshLoginChannel()
					self:RefreshRadioUI()
				else
					self:RefreshLogin()
					gDisplayMessageMgr:ShowMessageContent("登录失败")
					print_error("RequestQrcodeKeyPolling fail,具体原因请看c#报错")
				end
			end)
		end
	end)
end

function M:OnLogoutBtnClick()
	NeteaseCloudMusicManager.Instance:QuitLogin()
	gRadioPlayerManager:RefreshLoginChannel()
	self:RefreshRadioUI()
end

function M:OnControllerCloseBtnClick()
	if GameDevice.KeyboardMouse < InputActionBind.activeGameDevice then
		self.bindData.showVolumeBar = VOLUME_BAR_STATE.HIDE
	end
end

function M:OnVolumeSliderStep(step)
	if gRadioPlayerManager.radioVolume >= 100 and step > 0 or gRadioPlayerManager.radioVolume <= 0 and step < 0 then
		return
	end

	gRadioPlayerManager:SetRadioVolume(self.radioInfo, gRadioPlayerManager.radioVolume + step)
	self:RefreshVolumeBar()
end

function M:OnControllerUpLongChange(longPressType)
	self.sliderLongPressType = longPressType
end
