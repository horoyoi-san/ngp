-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BaseRadioPanelStore.lua
-- Decompiled from: 01653_BaseRadioPanelStore.lua_ea279e5a802a.luajit

C_BaseRadioPanelStore = DefClass("C_BaseRadioPanelStore", C_BaseRadioPanelStore, C_StoreGroup)
GroupName2Class.BaseRadioPanelStore = C_BaseRadioPanelStore
local M = C_BaseRadioPanelStore
local InputActionBind = SGUI.InputActionBind
local GameDevice = SGUI.GameDevice
local NeteaseCloudMusicManager = LX6.Audio.NeteaseCloudMusic.NeteaseCloudMusicManager
local SLIDER_LONG_PRESS_TYPE = {
	["^-jU"] = 2,
	["5"] = 1,
	["T-s^"] = 0
}
M.PLAYING_TYPE = {
	["NH~"] = 0,
	["k\\x8f\\x8e\\x9c\\x93"] = 1
}
M.ImageType = {
	["\\xb9md"] = 1,
	["a\\xa1\\xa1\\xae\\xba"] = 0
}
M.RadioType = {
	["H-|I"] = 2,
	["\\xef\\xde(\\xf4"] = 1,
	["T-s^"] = 0
}
M.VOLUME_BAR_STATE = {
	["RY~"] = 0,
	["I\nRl"] = 1
}
M.LoginState = {
	["a\\xa1\\xa5\\xa6\\xb8"] = 2,
	["R+y^"] = 0,
	["0G\\x96\\x81\\x96U"] = 1
}
M.PrivilegeType = {
	["\\xff\\xc9Mt\\xfc"] = 1,
	["\\xb8av"] = 2,
	["T-s^"] = 0
}

M.OnAwake = function(self)
	self.bindData.RadioList.luaSimpleRenderItem = self.CreateAction(self, "OnRadioListItem")
	self.bindData.RadioLoopList.luaSimpleRenderItem = self.CreateAction(self, "OnRadioLoopListItem")
	self.bindData.RadioLoopList.luaSelectedChanged = self.CreateAction(self, "OnRadioLoopListSelectedChanged")
	self.bindData.songNameRect.luaInitContent = self.CreateAction(self, "OnSongNameChange")
	self.bindData.RadioList.luaSimpleClick = self.CreateAction(self, "OnRadioListClick")
	self.bindData.RadioLoopList.luaSimpleClick = self.CreateAction(self, "OnRadioLoopListClick")
	self.bindData.BtnPlay.luaClick = self.CreateAction(self, "OnPlayRadioClick")
	self.bindData.BtnNext.luaClick = self.CreateAction(self, "OnNextRadioClick")
	self.bindData.BtnPre.luaClick = self.CreateAction(self, "OnPreRadioClick")
	self.bindData.BtnExit.luaClick = self.CreateAction(self, "OnCloseRadioClick")
	self.bindData.FullBtnExit.luaClick = self.CreateAction(self, "OnCloseRadioClick")
	self.bindData.QRCodeBtnExit.luaClick = self.CreateAction(self, "OnCloseRadioClick")
	self.bindData.ShowListBtn.luaClick = self.CreateAction(self, "OnShowRadioListClick")
	self.bindData.VolumeBtn.luaHover = self.CreateAction(self, "OnVolumeBtnHover")
	self.bindData.VolumeBtn.luaUnhover = self.CreateAction(self, "OnVolumeBtnUnhover")
	self.bindData.VolumeBtn.luaClick = self.CreateAction(self, "OnVolumeBtnClick")
	self.bindData.VolumeBarBg.luaHover = self.CreateAction(self, "OnVolumeBarBgHover")
	self.bindData.VolumeBarBg.luaUnhover = self.CreateAction(self, "OnVolumeBarBgUnhover")
	self.bindData.VolumeSlider.luaHover = self.CreateAction(self, "OnVolumeSliderHover")
	self.bindData.VolumeSlider.luaUnhover = self.CreateAction(self, "OnVolumeSliderUnhover")
	self.bindData.VolumeSlider.luaValueChanged = self.CreateAction(self, "OnVolumeSliderChange")
	self.bindData.LoginButton.luaClick = self.CreateAction(self, "OnLoginBtnClick")
	self.bindData.LogoutButton.luaClick = self.CreateAction(self, "OnLogoutBtnClick")
	self.bindData.SongLikeBtn.luaClick = self.CreateAction(self, "OnSongLikeBtnClick")
	self.bindData.ControllerCloseBtn.luaClick = self.CreateAction(self, "OnControllerCloseBtnClick")
	self.bindData.ControllerUpBtn.luaClick = self.CreateActionWithArgs(self, "OnVolumeSliderStep", 1)
	self.bindData.ControllerUpLongBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.Up)
	self.bindData.ControllerUpLongBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.None)
	self.bindData.ControllerDownBtn.luaClick = self.CreateActionWithArgs(self, "OnVolumeSliderStep", -1)
	self.bindData.ControllerDownLongBtn.luaBeginLongPress = self.CreateActionWithArgs(self, "OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.Down)
	self.bindData.ControllerDownLongBtn.luaEndLongPress = self.CreateActionWithArgs(self, "OnControllerUpLongChange", SLIDER_LONG_PRESS_TYPE.None)
	self.tabInfos = {}
	self.rightTabInfos = {}
	self.volumeBtnHover = false
	self.volumeBarBgHover = false
	self.volumeSliderHover = false
	self.sliderLongPressType = SLIDER_LONG_PRESS_TYPE.None
	self.sliderLongPressMultiple = 30
	self.cutAnimeName = "S_Vx_RadioPlayerPanel_cut"
	self.closeAnimeName = "S_Vx_RadioPlayerPanel_close"
	self.radioType = self.RadioType.None
	self.firstLoopListSelectedChanged = true
end

M.InitRadios = function(self)
	self.bindData.isPlaying = self.PLAYING_TYPE.TRUE

	self.bindData.RadioList:SetSimpleList(#self.rightTabInfos)
	self.bindData.RadioLoopList:SetSimpleList(#self.tabInfos)

	self.coverTitle = ""
end

M.OnUpdate = function(self)
	if self.sliderLongPressType ~= SLIDER_LONG_PRESS_TYPE.None then
		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() and GameDevice.KeyboardMouse >= InputActionBind.activeGameDevice then
		if self.sliderLongPressType ~= SLIDER_LONG_PRESS_TYPE.Up then
			self.OnVolumeSliderStep(self, Time.deltaTime * self.sliderLongPressMultiple)
		elseif self.sliderLongPressType ~= SLIDER_LONG_PRESS_TYPE.Down then
			self.OnVolumeSliderStep(self, -1 * Time.deltaTime * self.sliderLongPressMultiple)
		end
	end
end

M.RefreshRadioUI = function(self, index, isPause)
	if isPause then
		self.bindData.isPlaying = self.PLAYING_TYPE.FALSE
	else
		self.bindData.isPlaying = self.PLAYING_TYPE.TRUE
	end

	self.bindData.Rotator.IsPause = isPause

	self.bindData.RadioList:SetItemSelected(index - 1, true)
	self.bindData.RadioLoopList:SetItemSelected(index - 1, true)
	self:RefreshMusicContent(index)
	self:RefreshVolumeBar()
	self:RefreshLogin()
end

M.RefreshMusicContent = function(self, index)
	self.bindData.coverTitle = self.tabInfos[index].title
	self.bindData.coverIndex = self.tabInfos[index].radioNumber

	self.bindData.songNameRect:SetContentDirty()

	self.bindData.isWebCover = self.tabInfos[index].isWebCover or self.ImageType.Local
	self.bindData.coverImageId = self.tabInfos[index].coverId
	self.bindData.webCoverUrl = self.tabInfos[index].webUrl

	self:RefreshArtistName()
	self:RefreshNeteaseILike()
end

M.RefreshVolumeBar = function(self)
	local volume = self.GetRadioVolume(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() and InputActionBind.activeGameDevice < GameDevice.KeyboardMouse then
		if self.volumeBtnHover or self.volumeBarBgHover or self.volumeSliderHover then
			self.bindData.showVolumeBar = self.VOLUME_BAR_STATE.SHOW
			self.bindData.VolumeSlider.value = volume / 100
		else
			self.bindData.showVolumeBar = self.VOLUME_BAR_STATE.HIDE
		end
	elseif self.bindData.showVolumeBar ~= self.VOLUME_BAR_STATE.SHOW then
		self.bindData.VolumeSlider.value = volume / 100
	end

	self.bindData.volumeState = self.bindData.VolumeSlider.value >= 0.03 and 0 or 1
end

M.RefreshRadioList = function(self, isShow)
	if self.showRadioList ~= isShow then
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

M.RefreshQRCode = function(self, isShow)
	if self.bindData.showQRCode == isShow then
		self.bindData.showQRCode = isShow

		if not isShow then
			NeteaseCloudMusicManager.Instance:StopQrcodeKeyPolling()
		end
	end
end

M.RefreshArtistName = function(self)
end

M.RefreshNeteaseILike = function(self)
end

M.RefreshLogin = function(self)
	self.bindData.loginState = self.LoginState.Hide
	self.bindData.privilegeType = self.PrivilegeType.None

	self.RefreshQRCode(self, false)
end

M.SwitchRadio = function(self, addValue)
	if self.tabInfos then
		local targetIndex = self.radioInfo.curRadioIndex + addValue

		if targetIndex <= #self.tabInfos then
			self.SelectRadioChannel(self, 1)
		elseif targetIndex < 0 then
			self.SelectRadioChannel(self, #self.tabInfos)
		else
			self.SelectRadioChannel(self, targetIndex)
		end
	end
end

M.SelectRadioChannel = function(self, index, syncLoopList)
	if syncLoopList ~= nil then
		syncLoopList = true
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.RadioPlayerPanelAnimation, self.cutAnimeName)

	local rightTabIndex = #self.tabInfos ~= #self.rightTabInfos and index or index + 2

	self.bindData.RadioList:SetItemSelected(rightTabIndex - 1, true)
	self.bindData.RadioList:RefreshList()

	if syncLoopList then
		self.bindData.RadioLoopList:SetItemSelected(index - 1, true)
		self.bindData.RadioLoopList:RefreshList()
	end

	self.RefreshMusicContent(self, self.radioInfo.curRadioIndex)
end

M.RefreshRadioListSelect = function(self, index)
	local rightTabIndex = #self.tabInfos ~= #self.rightTabInfos and index or index + 2

	self.bindData.RadioList:SetItemSelected(rightTabIndex - 1, true)
	self.bindData.RadioList:RefreshList()
	self.bindData.RadioLoopList:SetItemSelected(index - 1, true)
	self.bindData.RadioLoopList:RefreshList()
end

M.OnRadioListItem = function(self, btn, index)
	index = index + 1
	local realIndex = #self.tabInfos ~= #self.rightTabInfos and index or index - 2
	local isPause = self:GetIsPause()
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and self.rightTabInfos and index < #self.rightTabInfos then
		if index < 2 then
			store.loginState = #self.rightTabInfos ~= #self.tabInfos and 1 or 0
			store.isWebCover = #self.rightTabInfos ~= #self.tabInfos and self.rightTabInfos[index].isWebCover or 0
		else
			store.loginState = 1
			store.isWebCover = self.rightTabInfos[index].isWebCover
		end

		store.iconUrl = self.rightTabInfos[index].coverId
		store.webUrl = self.rightTabInfos[index].webUrl
		store.radioNum = self.rightTabInfos[index].radioNumber
		store.radioName = self.rightTabInfos[index].title

		if realIndex ~= self.radioInfo.curRadioIndex then
			store.buttonState = 5
			store.playState = isPause and 1 or 0
		else
			store.buttonState = 0
			store.playState = 0
		end
	end
end

M.OnRadioListClick = function(self, btn, index)
	index = index + 1
	local realIndex = #self.tabInfos ~= #self.rightTabInfos and index or index - 2

	if #self.tabInfos == #self.rightTabInfos and index < 2 then
		self.OnLoginBtnClick(self)
	elseif realIndex == self.radioInfo.curRadioIndex then
		self.SelectRadioChannel(self, realIndex)
	else
		self.OnPlayRadioClick(self)
	end
end

M.OnRadioLoopListItem = function(self, btn, index, data)
	index = index + 1
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store and self.tabInfos and index < #self.tabInfos then
		store.isWebCover = self.tabInfos[index].isWebCover
		store.iconUrl = self.tabInfos[index].coverId
		store.webUrl = self.tabInfos[index].webUrl

		if self.tabInfos[index].tagType then
			store.tagType = self.tabInfos[index].tagType
			store.dateIconId = self.GetDataIconId(self)
		end
	end
end

M.OnRadioLoopListClick = function(self, btn, index)
	index = index + 1

	self.SelectRadioChannel(self, index, false)
end

M.OnRadioLoopListSelectedChanged = function(self)
	if self.firstLoopListSelectedChanged then
		self.firstLoopListSelectedChanged = false

		return
	end

	if self.timer then
		self.timer:Stop()
	end

	self.timer = Timer.New(function ()
		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		gSoundMgr:PlaySoundByExternalSource("ExHandle_click_03", LX6.Audio.ExternalSourceType.Motion_2D)

		local selectedIndex = self.bindData.RadioLoopList.selectedIndex + 1

		self:SelectRadioChannel(selectedIndex)

		self.timer = nil
	end, 0.5):Start()
end

M.OnSongNameChange = function(self, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	store.songName = self:GetRadioCurSongName()
end

M.OnPlayRadioClick = function(self)
	if self.bindData.isPlaying ~= self.PLAYING_TYPE.TRUE then
		self.bindData.isPlaying = self.PLAYING_TYPE.FALSE

		self.PauseRadio(self, true)
	else
		self.bindData.isPlaying = self.PLAYING_TYPE.TRUE

		self.PauseRadio(self, false)
	end

	self.bindData.RadioList:RefreshList()
end

M.OnNextRadioClick = function(self)
	self.SwitchRadio(self, 1)
end

M.OnPreRadioClick = function(self)
	self.SwitchRadio(self, -1)
end

M.OnCloseRadioClick = function(self)
	if self.bindData.showQRCode then
		self.RefreshQRCode(self, false)
	elseif self.showRadioList then
		self.RefreshRadioList(self, false)
	else
		local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.RadioPlayerPanelAnimation, self.closeAnimeName)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.RadioPlayerPanelAnimation, self.closeAnimeName)
		Timer.New(function ()
			gPanelManager:Close(self.panelId)
		end, duration):Start()
	end
end

M.OnShowRadioListClick = function(self)
	self.RefreshRadioList(self, not self.showRadioList)
end

M.OnVolumeBtnHover = function(self)
	if self.volumeBtnUnhoverTimer then
		self.volumeBtnUnhoverTimer:Stop()
	end

	self.volumeBtnHover = true

	self.RefreshVolumeBar(self)
end

M.OnVolumeBtnUnhover = function(self)
	self.volumeBtnUnhoverTimer = FrameTimer.New(function ()
		self.volumeBtnUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeBtnHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

M.OnVolumeBarBgHover = function(self)
	if self.volumeBarBgUnhoverTimer then
		self.volumeBarBgUnhoverTimer:Stop()
	end

	self.volumeBarBgHover = true

	self.RefreshVolumeBar(self)
end

M.OnVolumeBarBgUnhover = function(self)
	self.volumeBarBgUnhoverTimer = FrameTimer.New(function ()
		self.volumeBarBgUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeBarBgHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

M.OnVolumeSliderHover = function(self)
	if self.volumeSliderUnhoverTimer then
		self.volumeSliderUnhoverTimer:Stop()
	end

	self.volumeSliderHover = true

	self.RefreshVolumeBar(self)
end

M.OnVolumeSliderUnhover = function(self)
	self.volumeSliderUnhoverTimer = FrameTimer.New(function ()
		self.volumeSliderUnhoverTimer = nil

		if not gPanelManager:IsPanelShowing(self.panelId) then
			return
		end

		self.volumeSliderHover = false

		self:RefreshVolumeBar()
	end, 3):Start()
end

M.OnControllerCloseBtnClick = function(self)
	if GameDevice.KeyboardMouse >= InputActionBind.activeGameDevice then
		self.bindData.showVolumeBar = self.VOLUME_BAR_STATE.HIDE
	end
end

M.OnControllerUpLongChange = function(self, longPressType)
	self.sliderLongPressType = longPressType
end

M.OnVolumeBtnClick = function(self)
end

M.OnVolumeSliderChange = function(self, value)
end

M.OnLoginBtnClick = function(self)
end

M.OnSongLikeBtnClick = function(self)
end

M.OnLogoutBtnClick = function(self)
end

M.OnVolumeSliderStep = function(self, step)
end

M.GetRadioVolume = function(self)
end

M.GetIsPause = function(self)
end

M.GetRadioCurSongName = function(self)
end

M.GetDataIconId = function(self)
end
