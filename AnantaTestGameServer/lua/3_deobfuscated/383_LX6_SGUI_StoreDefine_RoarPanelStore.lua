C_RoarPanelStore = DefClass("C_RoarPanelStore", C_RoarPanelStore, C_StoreGroup)
GroupName2Class.RoarPanelStore = C_RoarPanelStore
local M = C_RoarPanelStore
local RadioSongsRoarConfig = LTConfig.RadioSongsRoarConfig
local SguiImageConfig = LTConfig.SguiImageConfig
local PLAYING_TYPE = {
	FALSE = 1,
	TRUE = 0
}

function M:OnAwake()
	self.bindData.radioList.luaRenderItem = self:CreateAction("OnRadioListItem")
	self.bindData.radioList.luaClick = self:CreateAction("OnRadioListClick")
	self.bindData.btnPlay.luaClick = self:CreateAction("OnPlayRadioClick")
	self.bindData.btnNext.luaClick = self:CreateAction("OnNextRadioClick")
	self.bindData.btnPre.luaClick = self:CreateAction("OnPreRadioClick")
	self.bindData.btnExit.luaClick = self:CreateAction("OnCloseRadioClick")
	self.EventHandler = {
		[gEventConstants.ROAR_RADIO_SONG_PLAY] = function (eventId, roarRadioId)
			if roarRadioId == self.radioId then
				self:RefreshMusicTitle()
			end
		end
	}
	self.radioId = nil
	self.panelId = gPanelId.S_ROAR_PANEL
	self.curRadioIndex = 0
	self.tabInfos = {}
	self.coverTitle = ""
	self.scrollSpeed = 1
	self.scrollLoopCheckpoint = 50
	self.IsShow = false
	self.cutAnimeName = "S_Vx_RadioPlayerPanel_cut"
	self.closeAnimeName = "S_Vx_RadioPlayerPanel_close"
end

function M:InitRadios()
	self.tabInfos = {}

	for i = 0, RadioSongsRoarConfig.count - 1 do
		local cfg = RadioSongsRoarConfig.LoadAt(i)
		local view = {
			title = cfg.RadioName,
			coverId = cfg.RadioCover,
			iconId = cfg.RadioIcon,
			index = i + 1
		}

		table.insert(self.tabInfos, view)
	end

	self.bindData.isPlaying = PLAYING_TYPE.TRUE

	self.bindData.radioList:SetList(self.tabInfos)

	for i, v in pairs(self.EventHandler) do
		gMessageManager:AddMessageListener(i, v)
	end

	self.coverTitle = ""
end

function M:OnShow(panelId, data)
	self.radioId = gRoarPlayerManager.curHandWeaponId

	self:InitRadios()

	local radioInfo = gRoarPlayerManager:GetRadioInfoById(self.radioId)

	if not radioInfo then
		print_error("RoarPanelStore 当前武器没有播放电台")

		return
	end

	local index = radioInfo.curRadioIndex

	if radioInfo.isPause then
		self.bindData.isPlaying = PLAYING_TYPE.FALSE
	else
		self.bindData.isPlaying = PLAYING_TYPE.TRUE
	end

	self.bindData.radioList:SelectItem(index - 1)
	self:RefreshMusicContent(index)
	self:RefreshMusicTitle()

	self.IsShow = true
end

function M:OnUpdate()
	if self.IsShow and self.bindData.coverTitle then
		if self.needScroll then
			if self.xTime <= -self.scrollLoopCheckpoint then
				self.xTime = 0
			end

			self.xTime = self.xTime - self.scrollSpeed
			self.bindData.coverTitle.content.localPosition = Vector3.New(self.xTime, 0, 0)
		else
			self.xTime = 0
		end
	end
end

function M:OnClose()
	for i, v in pairs(self.EventHandler) do
		gMessageManager:RemoveMessageListener(i, v)
	end

	self.IsShow = false
end

function M:PauseRadio(pause)
	gRoarPlayerManager:PauseRadio(self.radioId, pause)

	local radioInfo = gRoarPlayerManager:GetRadioInfoById(self.radioId)

	if radioInfo and radioInfo.isPause then
		self.bindData.isPlaying = PLAYING_TYPE.FALSE
	else
		self.bindData.isPlaying = PLAYING_TYPE.TRUE
	end
end

function M:SwitchRadio(addValue)
	gRoarPlayerManager:SwitchRadio(self.radioId, addValue)

	local radioInfo = gRoarPlayerManager:GetRadioInfoById(self.radioId)

	if radioInfo then
		self:SelectRadioChannel(radioInfo.curRadioIndex)
	end
end

function M:SelectRadioChannel(index)
	if index == self.curRadioIndex then
		return
	end

	self.curRadioIndex = index

	gCS.LuaUtils.PlayAnimationByName(self.bindData.RoarPanelAnimation, self.cutAnimeName)
	self.bindData.radioList:SelectItem(index - 1)
	self:RefreshMusicContent(self.curRadioIndex)
end

function M:OnRadioListItem(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if store then
		local cfg = SguiImageConfig.GetConfig(data.iconId)

		if cfg then
			store.iconUrl = cfg.ImgPath
		else
			print_error("[RoarPanelStore] 找不到图片,请策划检查配表！！！ID:", data.iconId)
		end

		store.radioNum = gUIUtils:NumberTo2String(data.index)
		store.radioName = data.title
	end
end

function M:OnRadioListClick(btn, data)
	gRoarPlayerManager:SwitchTargetRadio(self.radioId, data.index)
	self:SelectRadioChannel(data.index)
end

function M:OnPlayRadioClick()
	if self.bindData.isPlaying == PLAYING_TYPE.TRUE then
		self.bindData.isPlaying = PLAYING_TYPE.FALSE

		self:PauseRadio(true)
	else
		self.bindData.isPlaying = PLAYING_TYPE.TRUE

		self:PauseRadio(false)
	end
end

function M:OnNextRadioClick()
	self:SwitchRadio(1)
end

function M:OnPreRadioClick()
	self:SwitchRadio(-1)
end

function M:RefreshMusicContent(index)
	self.bindData.coverTitle.content.text = " "
	local cfg = SguiImageConfig.GetConfig(self.tabInfos[index].coverId)

	if cfg then
		self.bindData.coverImage = cfg.ImgPath
	else
		print_error("[RoarPanelStore] 找不到图片,请策划检查配表！！！ID:", self.tabInfos[index].coverId)
	end
end

function M:RefreshMusicTitle()
	local titleName = gRoarPlayerManager:GetRadioCurTitleNameById(self.radioId)

	if not self.coverTitle or not titleName then
		return
	end

	if self.coverTitle ~= titleName .. "   " then
		self.needScroll = false

		self:ChangeMusicTitle(titleName)
	end
end

function M:ChangeMusicTitle(title)
	if not title or not self.bindData.coverTitle then
		return
	end

	title = title .. "   "
	self.coverTitle = title
	self.xTime = 0
	self.bindData.coverTitle.content.text = title
	local ContentWidth = 480
	local TargetWidth = self.bindData.coverTitle:GetPreferredWidth(-1)

	if TargetWidth < ContentWidth * 0.7 then
		self.needScroll = false

		self.bindData.coverTitle:SetScrollDisabled(true)

		local posX = (ContentWidth - TargetWidth) / 2

		self.bindData.coverTitle.content.rectTransform:SetLocalPositionX(posX)
	else
		self.needScroll = true
		self.bindData.coverTitle.content.text = title .. title .. title

		self.bindData.coverTitle:SetScrollDisabled(true)

		self.scrollLoopCheckpoint = 0.333333 * self.bindData.coverTitle:GetPreferredWidth(-1)
	end
end

function M:OnCloseRadioClick()
	local duration = gCS.LuaUtils.GetAnimationTime(self.bindData.RoarPanelAnimation, self.closeAnimeName)

	gCS.LuaUtils.PlayAnimationByName(self.bindData.RoarPanelAnimation, self.closeAnimeName)
	Timer.New(function ()
		gPanelManager:Close(self.panelId)
	end, duration):Start()
end
