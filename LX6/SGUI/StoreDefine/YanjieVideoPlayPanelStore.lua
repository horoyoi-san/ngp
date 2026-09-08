-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieVideoPlayPanelStore.lua
-- Decompiled from: 01922_YanjieVideoPlayPanelStore.lua_da64e0115664.luajit

C_YanjieVideoPlayPanelStore = DefClass("C_YanjieVideoPlayPanelStore", C_YanjieVideoPlayPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieVideoPlayPanelStore = C_YanjieVideoPlayPanelStore
local M = C_YanjieVideoPlayPanelStore
local ShowTypeControl = {
	["*A\\x95\\x8b\\x8cv"] = 2,
	["5E\\x90\\x89\\x86v"] = 0,
	["*A\\x95\\x8b\\x8ci"] = 3,
	["5E\\x90\\x89\\x86i"] = 1
}
local PlayStatusControl = {
	["\\x85\\xbe\\x9dc:\\xfb<"] = 2,
	["J.|B"] = 0,
	["}\\xaf\\xb7\\xbc\\xb3"] = 1
}
local PlayState = Live.Engine.CCPlayer.CCPlayerCore.PlayState

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.likeButton.luaClick = self.CreateAction(self, "OnLikeClick")
	self.bindData.collectButton.luaClick = self.CreateAction(self, "OnCollectClick")
	self.bindData.playButton.luaClick = self.CreateAction(self, "OnPlayClick")
	self.bindData.gamepadPlayButton.luaClick = self.CreateAction(self, "OnPlayClick")
	self.bindData.pauseButton.luaClick = self.CreateAction(self, "OnPauseClick")
	self.bindData.gamepadPauseButton.luaClick = self.CreateAction(self, "OnPauseClick")
	self.bindData.videoSlider.luaValueChanged = self.CreateAction(self, "OnVideoProgressChange")
	self.bindData.videoSlider.luaPress = self.CreateAction(self, "OnBeginDragProgress")
	self.bindData.videoSlider.luaRelease = self.CreateAction(self, "OnEndDragProgress")
	self.bindData.commentButton.luaClick = self.CreateAction(self, "OnCommentClick")
	self.bindData.videoDisplayButton.luaClick = self.CreateAction(self, "OnVideoDisplayClick")
	self.bindData.gamePadDragSlider.onEndDrag = self.CreateAction(self, "OnGamePadEndDrag")
	self.bindData.playBarHoverAreaButton.luaHover = self.CreateAction(self, "OnPlayBarHover")
	self.bindData.playBarHoverAreaButton.luaUnhover = self.CreateAction(self, "OnPlayBarUnHover")
end

M.GetMessageEvents = function(self)
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

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.hasInit = nil

	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.VideoPlayPage, "id", args.id)

	self.imageData = args.imageData
	self.momentData = args.momentData
	self.canExit = true

	if args.id then
		self.canExit = false
		slot2 = self.bindData.exitButton

		slot2:SetActive(false)

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

M.InitView = function(self, args)
	M.base.InitView(self, args)
	self.RefreshPanelView(self)
end

M.RefreshPanelView = function(self)
	if self.momentData then
		self.bindData.videoPlayBarActive = false

		self.bindData.videoDisplayButton.gameObject:SetActive(false)

		if not self.hasInit then
			local isVideo = self.imageData.isVideo

			if isVideo then
				self.RefreshVideoView(self)
			else
				self.RefreshImageView(self)
			end

			self.hasInit = true
		end

		self.RefreshBottomView(self)
	end
end

M.RefreshBottomView = function(self)
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

M.RefreshImageView = function(self)
	local bucketName = unpack(self.imageData.imageURL)
	slot2 = self.bindData.imageW

	slot2:SetOssObjectWithCallback(bucketName, function (texture)
		if self.hasDestroy or not texture then
			return
		end

		if texture.height < texture.width then
			self.bindData.showTypeCtrl = ShowTypeControl.ImageW
		else
			self.bindData.imageH.commonBucketName = bucketName
			self.bindData.showTypeCtrl = ShowTypeControl.ImageH
		end
	end)
end

M.RefreshItemView = function(self, args)
	for k, v in pairs(args) do
		self.momentData[k] = v
	end

	self.RefreshBottomView(self)
end

M.OnLikeClick = function(self)
	gSocialNetworkUtils.LikeSocialNetwork(self.momentData, function (isLike)
		if self.hasDestroy then
			return
		end

		local animationName = gSocialNetworkUtils.GetLikeAnimationName(isLike)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.likeAnimation, animationName)
	end)
end

M.OnCollectClick = function(self)
	gSocialNetworkUtils.CollectionSocialNetwork(self.momentData)
end

M.RefreshVideoView = function(self)
	local videoUrl = self.imageData.videoURL
	local showType = ShowTypeControl.VideoH
	self.bindData.showTypeCtrl = showType
	local videoPlayer = showType ~= ShowTypeControl.VideoW and self.bindData.videoPlayerW or self.bindData.videoPlayerH

	videoPlayer:Init()

	local onVideoPlayComplete = function()
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
		videoPlayer.PlayVideo(videoPlayer, self.imageData.videoId, true, nil, onVideoPlayComplete)
	else
		videoPlayer.PlayVideoUrl(videoPlayer, videoUrl, true, nil, onVideoPlayComplete)
	end
end

M.OnUpdate = function(self)
	local playStatus = self.videoPlayer and self.videoPlayer.CurPlayState

	if playStatus ~= PlayState.Playing and self.videoTotalTime and not self.isSetVideoTime then
		local currentTime = self.videoPlayer:GetCurrentTime()
		local progress = currentTime / self.videoTotalTime
		local diffTime = self.videoTotalTime - currentTime

		if diffTime < gClientConst.VideoPlayFinishThresholdTime then
			local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.momentData)

			gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.VideoFinished)
		end

		if not self.bindData.gamePadDragSlider.IsDragging then
			self.bindData.videoSliderValue = progress
		end
	end
end

M.OnPlayClick = function(self)
	if self.videoPlayer and self.videoPlayer.CurPlayState ~= PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
end

M.OnPauseClick = function(self)
	if self.videoPlayer then
		self.videoPlayer:Pause()

		self.bindData.playStatus = PlayStatusControl.Play
	end
end

M.OnBeginDragProgress = function(self)
	if self.videoPlayer then
		self.isSetVideoTime = true

		if self.videoPlayer.CurPlayState ~= PlayState.Pause then
			self.videoPlayer:Resume()

			self.bindData.playStatus = PlayStatusControl.Pause
		end
	end
end

M.OnEndDragProgress = function(self)
	if self.videoPlayer then
		self.isSetVideoTime = false

		if self.videoPlayer.CurPlayState ~= PlayState.Pause then
			self.videoPlayer:Resume()

			self.bindData.playStatus = PlayStatusControl.Pause
		end
	end
end

M.OnVideoProgressChange = function(self, value)
	if self.bindData.gamePadDragSlider.IsDragging then
		return
	end

	if self.isSetVideoTime then
		local targetTime = value * self.videoTotalTime * 1000

		self.videoPlayer:Seek(targetTime)
	end

	self.RefreshVideoProgressView(self)
end

M.RefreshVideoProgressView = function(self)
	local totalTimeFormat = self:FormatTime(self.videoTotalTime)
	local currentTime = self.videoPlayer:GetCurrentTime()
	local currentTimeFormat = self:FormatTime(currentTime)
	self.bindData.videoProgress = ("%s/%s"):format(currentTimeFormat, totalTimeFormat)
end

M.FormatTime = function(self, time)
	if time then
		local minutes = math.floor(time / 60)
		local seconds = math.floor(time - minutes * 60)

		return gString.Format("%02d:%02d", minutes, seconds)
	else
		return ""
	end
end

M.OnCommentClick = function(self)
	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
		showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.YanJie,
		secondShowType = gClientConst.YanJieShowType.Detail,
		data = self.momentData
	})
end

M.OnVideoDisplayClick = function(self)
	if self.videoPlayer then
		if self.bindData.playStatus ~= PlayStatusControl.Play then
			self.OnPlayClick(self)
		elseif self.bindData.playStatus ~= PlayStatusControl.Pause then
			self.OnPauseClick(self)
		end
	end
end

M.OnGamePadEndDrag = function(self)
	if self.videoPlayer ~= nil then
		return
	end

	local value = self.bindData.videoSlider.value
	self.isSetVideoTime = true

	self.OnVideoProgressChange(self, value)

	self.isSetVideoTime = false
end

M.ClearData = function(self)
	self.hasInit = true
	self.checkCanExitCo = coroutine.stop(self.checkCanExitCo)
	self.videoPlayer = self.videoPlayer and self.videoPlayer:Stop()
	self.imageData = nil
	self.momentData = nil
	self.autoHideBarCo = coroutine.stop(self.autoHideBarCo)
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)
end

M.OnExitClick = function(self)
	if not self.canExit then
		return
	end

	M.base.OnExit(self)
end

M.OnPlayBarHover = function(self)
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)

	self.bindData.playBar:SetActive(true)
end

M.OnPlayBarUnHover = function(self)
	self.autoHidePlayBarCo = coroutine.start(function ()
		coroutine.wait(3)
		self.bindData.playBar:SetActive(false)
	end)
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
	gNpcChatUtils.ResumeChatAutoClick()
end
