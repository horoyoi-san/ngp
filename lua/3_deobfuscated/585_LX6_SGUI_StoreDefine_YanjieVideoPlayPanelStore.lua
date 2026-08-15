C_YanjieVideoPlayPanelStore = DefClass("C_YanjieVideoPlayPanelStore", C_YanjieVideoPlayPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieVideoPlayPanelStore = C_YanjieVideoPlayPanelStore
local M = C_YanjieVideoPlayPanelStore
local ShowTypeControl = {
	VideoW = 2,
	ImageW = 0,
	VideoH = 3,
	ImageH = 1
}
local PlayStatusControl = {
	NotVideo = 2,
	Play = 0,
	Pause = 1
}
local PlayState = Live.Engine.CCPlayer.CCPlayerCore.PlayState

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.likeButton.luaClick = self:CreateAction("OnLikeClick")
	self.bindData.collectButton.luaClick = self:CreateAction("OnCollectClick")
	self.bindData.playButton.luaClick = self:CreateAction("OnPlayClick")
	self.bindData.gamepadPlayButton.luaClick = self:CreateAction("OnPlayClick")
	self.bindData.pauseButton.luaClick = self:CreateAction("OnPauseClick")
	self.bindData.gamepadPauseButton.luaClick = self:CreateAction("OnPauseClick")
	self.bindData.videoSlider.luaValueChanged = self:CreateAction("OnVideoProgressChange")
	self.bindData.videoSlider.luaPress = self:CreateAction("OnBeginDragProgress")
	self.bindData.videoSlider.luaRelease = self:CreateAction("OnEndDragProgress")
	self.bindData.commentButton.luaClick = self:CreateAction("OnCommentClick")
	self.bindData.videoDisplayButton.luaClick = self:CreateAction("OnVideoDisplayClick")
	self.bindData.gamePadDragSlider.onEndDrag = self:CreateAction("OnGamePadEndDrag")
	self.bindData.playBarHoverAreaButton.luaHover = self:CreateAction("OnPlayBarHover")
	self.bindData.playBarHoverAreaButton.luaUnhover = self:CreateAction("OnPlayBarUnHover")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, data)
			self.momentData = data
			local imageViewDataList = gSocialNetworkUtils.GetSocialNetworkImageList(data)
			self.imageData = imageViewDataList and imageViewDataList[1]

			self:RefreshPanelView()
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.VideoPlayPage, "id", args.id)

	self.imageData = args.imageData
	self.momentData = args.momentData
	self.canExit = true

	if args.id then
		self.canExit = false

		self.bindData.exitButton:SetActive(false)

		local rootGo = self.rootGo
		self.checkCanExitCo = coroutine.start(function ()
			coroutine.wait(LTConfig.TuiteConfig.CanExitDurationTime)

			if gClientUtils.NotNil(rootGo) then
				self.canExit = true

				self.bindData.exitButton:SetActive(true)
			end
		end)

		gSocialNetworkUtils.GetSocialNetworkDetail(args.id)
	end
end

function M:InitView(args)
	M.base.InitView(self, args)
	self:RefreshPanelView()
end

function M:RefreshPanelView()
	if self.momentData then
		self.bindData.videoPlayBarActive = false

		self.bindData.videoDisplayButton.gameObject:SetActive(false)

		local isVideo = self.imageData.isVideo

		if isVideo then
			self:RefreshVideoView()
		else
			self:RefreshImageView()
		end

		self:RefreshBottomView()
	end
end

function M:RefreshBottomView()
	local data = self.momentData
	self.bindData.hotCount = gSocialNetworkUtils.GetCountFormat(data.viewCount)
	self.bindData.likeCount = gSocialNetworkUtils.GetCountFormat(data.likeCount)
	self.bindData.commentCount = gSocialNetworkUtils.GetCountFormat(data.commentCount)
	self.bindData.likeButton.isSelected = data.isLike
	self.bindData.likeButtonCtrl = data.isLike and 1 or 0
	local animationName = gSocialNetworkUtils.GetLikeAnimationName(data.isLike)

	gClientUtils.FinishAnimation(self.bindData.likeAnimation, animationName)

	self.bindData.collectButton.isSelected = data.isCollect
	self.bindData.collectButtonCtrl = data.isCollect and 1 or 0
end

function M:RefreshImageView()
	local imageUrl = unpack(self.imageData.imageURL)

	self.bindData.imageW:SetUrlWithCallback(imageUrl, function (texture, url)
		if self.hasDestroy or imageUrl ~= url then
			return
		end

		if texture.height <= texture.width then
			self.bindData.showTypeCtrl = ShowTypeControl.ImageW
		else
			self.bindData.imageH.url = url
			self.bindData.showTypeCtrl = ShowTypeControl.ImageH
		end
	end)
end

function M:RefreshItemView(args)
	for k, v in pairs(args) do
		self.momentData[k] = v
	end

	self:RefreshBottomView()
end

function M:OnLikeClick()
	gSocialNetworkUtils.LikeSocialNetwork(self.momentData, function (isLike)
		if self.hasDestroy then
			return
		end

		local animationName = gSocialNetworkUtils.GetLikeAnimationName(isLike)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.likeAnimation, animationName)
	end)
end

function M:OnCollectClick()
	gSocialNetworkUtils.CollectionSocialNetwork(self.momentData)
end

function M:RefreshVideoView()
	local videoUrl = self.imageData.videoURL
	local showType = ShowTypeControl.VideoH
	self.bindData.showTypeCtrl = showType
	local videoPlayer = showType == ShowTypeControl.VideoW and self.bindData.videoPlayerW or self.bindData.videoPlayerH

	videoPlayer:Init()

	local function onVideoPlayComplete()
		if gClientUtils.NotNil(self.rootGo) then
			self.bindData.videoPlayBarActive = true

			self.bindData.videoDisplayButton.gameObject:SetActive(true)

			self.videoPlayer = videoPlayer
			self.videoTotalTime = self.videoPlayer:GetDuration()
			self.bindData.playStatus = PlayStatusControl.Pause

			self:RefreshVideoProgressView()
		end
	end

	if self.imageData.videoId then
		videoPlayer:PlayVideo(self.imageData.videoId, true, nil, onVideoPlayComplete)
	else
		videoPlayer:PlayVideoUrl(videoUrl, true, nil, onVideoPlayComplete)
	end
end

function M:OnUpdate()
	local playStatus = self.videoPlayer and self.videoPlayer.CurPlayState

	if playStatus == PlayState.Playing and self.videoTotalTime and not self.isSetVideoTime then
		local currentTime = self.videoPlayer:GetCurrentTime()
		local progress = currentTime / self.videoTotalTime
		local diffTime = self.videoTotalTime - currentTime

		if diffTime <= gClientConst.VideoPlayFinishThresholdTime then
			local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.momentData)

			gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.VideoFinished)
		end

		if not self.bindData.gamePadDragSlider.IsDragging then
			self.bindData.videoSliderValue = progress
		end
	end
end

function M:OnPlayClick()
	if self.videoPlayer and self.videoPlayer.CurPlayState == PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
end

function M:OnPauseClick()
	if self.videoPlayer then
		self.videoPlayer:Pause()

		self.bindData.playStatus = PlayStatusControl.Play
	end
end

function M:OnBeginDragProgress()
	if self.videoPlayer then
		self.isSetVideoTime = true

		if self.videoPlayer.CurPlayState == PlayState.Pause then
			self.videoPlayer:Resume()

			self.bindData.playStatus = PlayStatusControl.Pause
		end
	end
end

function M:OnEndDragProgress()
	if self.videoPlayer then
		self.isSetVideoTime = false

		if self.videoPlayer.CurPlayState == PlayState.Pause then
			self.videoPlayer:Resume()

			self.bindData.playStatus = PlayStatusControl.Pause
		end
	end
end

function M:OnVideoProgressChange(value)
	if self.bindData.gamePadDragSlider.IsDragging then
		return
	end

	if self.isSetVideoTime then
		local targetTime = value * self.videoTotalTime * 1000

		self.videoPlayer:Seek(targetTime)
	end

	self:RefreshVideoProgressView()
end

function M:RefreshVideoProgressView()
	local totalTimeFormat = self:FormatTime(self.videoTotalTime)
	local currentTime = self.videoPlayer:GetCurrentTime()
	local currentTimeFormat = self:FormatTime(currentTime)
	self.bindData.videoProgress = ("%s/%s"):format(currentTimeFormat, totalTimeFormat)
end

function M:FormatTime(time)
	if time then
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time - minutes * 60)

		return gString.Format("%02d:%02d", minutes, seconds)
	else
		return ""
	end
end

function M:OnCommentClick()
	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie,
		secondShowType = gClientConst.YanJieShowType.Detail,
		data = self.momentData
	})
end

function M:OnVideoDisplayClick()
	if self.videoPlayer then
		if self.bindData.playStatus == PlayStatusControl.Play then
			self:OnPlayClick()
		elseif self.bindData.playStatus == PlayStatusControl.Pause then
			self:OnPauseClick()
		end
	end
end

function M:OnGamePadEndDrag()
	if self.videoPlayer == nil then
		return
	end

	local value = self.bindData.videoSlider.value
	self.isSetVideoTime = true

	self:OnVideoProgressChange(value)

	self.isSetVideoTime = false
end

function M:ClearData()
	self.checkCanExitCo = coroutine.stop(self.checkCanExitCo)
	self.videoPlayer = self.videoPlayer and self.videoPlayer:Stop()
	self.imageData = nil
	self.momentData = nil
	self.autoHideBarCo = coroutine.stop(self.autoHideBarCo)
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)
end

function M:OnExitClick()
	if not self.canExit then
		return
	end

	M.base.OnExit(self)
end

function M:OnPlayBarHover()
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)

	self.bindData.playBar:SetActive(true)
end

function M:OnPlayBarUnHover()
	self.autoHidePlayBarCo = coroutine.start(function ()
		coroutine.wait(3)
		self.bindData.playBar:SetActive(false)
	end)
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
