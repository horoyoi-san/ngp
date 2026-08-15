C_YanjieNewDetailPagePanel = DefClass("C_YanjieNewDetailPagePanel", C_YanjieNewDetailPagePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewDetailPagePanel = C_YanjieNewDetailPagePanel
local M = C_YanjieNewDetailPagePanel
local IdKey = "id"
local TemplateType = {
	Task = 2,
	Comment = 1,
	Detail = 0
}
local ShowModeControl = {
	Edit = 1,
	Normal = 0
}
local ShowTypeControl = {
	VideoW = 0,
	VideoH = 1
}
local PlayStatusControl = {
	NotVideo = 2,
	Play = 0,
	Pause = 1
}
local PlayState = Live.Engine.CCPlayer.CCPlayerCore.PlayState

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderItem")
	self.bindData.inputField.luaValueChanged = self:CreateAction("OnInputFieldValueChange")
	self.bindData.sendButton.luaClick = self:CreateAction("OnSendCommentClick")
	self.bindData.playVideoButton.luaClick = self:CreateAction("OnPlayVideoClick")
	self.bindData.videoDisplayButton.luaClick = self:CreateAction("OnVideoDisplayClick")
	self.bindData.videoSlider.luaValueChanged = self:CreateAction("OnVideoProgressChange")
	self.bindData.videoSlider.luaPress = self:CreateAction("OnBeginDragProgress")
	self.bindData.videoSlider.luaRelease = self:CreateAction("OnEndDragProgress")
	self.bindData.playButton.luaClick = self:CreateAction("OnPlayClick")
	self.bindData.pauseButton.luaClick = self:CreateAction("OnPauseClick")
	self.bindData.maskButton.luaClick = self:CreateAction("OnMaskClick")
	self.bindData.gamePadPlayButton.luaClick = self:CreateAction("OnPlayClick")
	self.bindData.gamePadPauseButton.luaClick = self:CreateAction("OnPauseClick")
	self.bindData.playBarHoverAreaButton.luaHover = self:CreateAction("OnPlayBarHover")
	self.bindData.playBarHoverAreaButton.luaUnhover = self:CreateAction("OnPlayBarUnHover")
end

function M:OnStart()
	gSocialNetworkUtils.DynamicLoadList(self.bindData.list, self:CreateAction("OnScroll"), self:CreateAction("OnScrollEnd"))
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, data)
			self.socialNetworkData = data

			self:GetRequestCommentList()
			self:RefreshPanelView()
			self:RefreshDisplayView()

			local effectiveId = gSocialNetworkUtils.GetEffectiveId(data)

			gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.DetailPage, IdKey, effectiveId)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			if args.id == self.socialNetworkData.id then
				self.socialNetworkData.isLike = args.isLike
				self.socialNetworkData.likeCount = args.likeCount

				self:RefreshPanelView()
			end
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
			if args.id == self.socialNetworkData.id then
				self.socialNetworkData.playCollectionAnimation = args.isCollect
				self.socialNetworkData.isCollect = args.isCollect

				self:RefreshPanelView()
			end
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
			self:OnFollowSuccess(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COMMENT_LIST] = function (_, requestData)
			self:RefreshCommentListView(requestData)

			if self.socialNetworkData.commentCount ~= self.commentListPageEntity.totalCount then
				self.socialNetworkData.commentCount = self.commentListPageEntity.totalCount

				self:RefreshPanelView()
			end

			if requestData and requestData.page == 1 then
				self:CheckCommentBottom()
			end
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COMMENT_LIKE] = function (_, args)
			self:OnCommentLikeSuccess(args)
		end,
		[gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK] = function (_, args)
			self:OnCommentSuccess(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
			self:OnFollowSuccess(args)
		end,
		[gEventConstants.ON_COMMON_REQUEST_FAIL] = function (_, args)
			if args.request == gCommonRequestUtils.RequestMap.MomentDetail then
				local failTips = LTConfig.TuiteConfig.RequestFailTips

				gDisplayMessageMgr:ShowMessageContent(failTips)

				return
			end
		end,
		[gEventConstants.ON_SHOW_YANJIE_DETAIL_INPUT_COMMENT] = function (_, id)
			if self.socialNetworkData and self.socialNetworkData.id == id then
				self:OnCommentClick()
			end
		end
	}
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.videoPlayer = nil
	self.hasPlayVideoClick = nil
	self.socialNetworkData = args.data
	self.isScrolling = nil
	self.showModel = 0
	self.currentMaxCsIndex = nil
	self.commentListPageEntity = gListPageEntity.new()
	local id = args.id or args.data and args.data.id

	if id then
		gSocialNetworkUtils.GetSocialNetworkDetail(id)
	end
end

function M:InitView(args)
	self.bindData.inputField.characterLimit = LTConfig.TuiteConfig.CommentMaxLength

	if args and args.disableDetailOffsetAnim then
		self.bindData.list.enableOffsetAnimation = false
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieDetailPagePanel_open")
	self:RefreshPanelView()
	self:RefreshCommentListView()

	if args and args.showComment then
		self.openCommentOnly = true

		self:OnCommentClick()
	else
		self:SetInputFieldActive(false)
	end

	self:RefreshDisplayView()
end

function M:GetRequestCommentList()
	local listPageEntity = self.commentListPageEntity
	local pageIndex = listPageEntity:GetCurrentPageIndex() + 1
	local id = self.socialNetworkData.id
	local templateId = self.socialNetworkData.templateId
	local pageSize = listPageEntity.pageSize

	gSocialNetworkUtils.GetCommentList(id, templateId, pageIndex, pageSize)
end

function M:RefreshPanelView()
	self.viewDataList = self:GetViewDataList()

	function self.bindData.list.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

function M:GetViewDataList()
	local viewDataList = {}

	if self.socialNetworkData then
		local data = self.socialNetworkData
		local isTaskTemplate = data.templateId and data.templateId > 0
		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
		isTaskTemplate = isTaskTemplate and tuiteCfg and tuiteCfg.TaskEvent and tuiteCfg.TaskEvent > 0

		if isTaskTemplate then
			table.insert(viewDataList, {
				tIndex = TemplateType.Task
			})
		else
			table.insert(viewDataList, {
				tIndex = TemplateType.Detail
			})
		end
	end

	local commentViewDataList = self.commentListPageEntity:GetViewDataList()

	for index, _ in ipairs(commentViewDataList) do
		table.insert(viewDataList, {
			tIndex = TemplateType.Comment,
			index = index
		})
	end

	return viewDataList
end

function M:RefreshCommentListView(requestData)
	local listPageEntity = self.commentListPageEntity

	if requestData and requestData.page == 1 then
		listPageEntity:Reset()
	end

	listPageEntity:UpdateDataList(requestData)
	self:RefreshPanelView()
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if data.tIndex == TemplateType.Detail or data.tIndex == TemplateType.Task then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		gSocialNetworkUtils.RefreshCommonMomentItem(store, self.socialNetworkData)

		store.isShowImageList = false
		store.isVideoActive = false
		store.commentButton.luaClick = self:CreateAction(self.OnCommentClick)
		store.gamepadShowDetailButton.luaClick = self:CreateActionWithArgs(self.OnShowDetailClick, store)

		store.layout:ForceRebuildLayoutImmediate()

		local activeContent = self.bindData.panelNavArea.CurrentActiveContent

		if self.showModel == ShowModeControl.Normal and (activeContent == nil or activeContent.transform.parent ~= btn.transform.parent) then
			self.bindData.panelNavArea.CurrentActiveContent = btn
		end
	elseif data.tIndex == TemplateType.Comment then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		self:RefreshCommentItem(store, data.index)
		store.layout:ForceRebuildLayoutImmediate()
	end

	self.currentMaxCsIndex = csIndex
end

function M:RefreshDisplayView()
	if self.socialNetworkData then
		local imageViewDataList, isVideo = gSocialNetworkUtils.GetSocialNetworkImageList(self.socialNetworkData)

		if #imageViewDataList > 0 then
			self.bindData.contentShowModeControl = 1
			self.bindData.imageList.luaSimpleRenderItem = self:CreateAction(self.OnImageRenderItem)
			local dotViewDataList = {}

			if #imageViewDataList > 1 then
				for index, _ in ipairs(imageViewDataList) do
					table.insert(dotViewDataList, {
						id = index,
						selected = index == 1
					})
				end
			end

			self.bindData.roundList:SetSimpleList(#dotViewDataList)
			self.bindData.imageList:SetSimpleList(#imageViewDataList)

			self.imageViewDataList = imageViewDataList

			function self.bindData.imageList.luaTargetPageChange(dotIndex)
				self.bindData.roundList:SelectItem(dotIndex)
			end

			self.bindData.playVideoButton:SetActive(isVideo)

			return
		end
	end

	self.bindData.contentShowModeControl = 0
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

function M:OnPlayVideoClick()
	if self.hasPlayVideoClick then
		return
	end

	self.hasPlayVideoClick = true
	local imageData = self.imageViewDataList[1]
	local videoUrl = imageData.videoURL
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(self.socialNetworkData)
	local showType = tuiteCfg and tuiteCfg.VideoTypeControl == 1 and ShowTypeControl.VideoW or ShowTypeControl.VideoH
	self.bindData.showTypeCtrl = showType
	local videoPlayer = showType == ShowTypeControl.VideoW and self.bindData.videoPlayerW or self.bindData.videoPlayerH

	videoPlayer:Init()

	local rootGo = self.rootGo

	local function onVideoPlayComplete()
		if gClientUtils.NotNil(rootGo) then
			self.bindData.playVideoButton.gameObject:SetActive(false)

			self.bindData.contentShowModeControl = 2

			self.bindData.videoDisplayButton.gameObject:SetActive(true)

			self.videoPlayer = videoPlayer
			self.videoTotalTime = self.videoPlayer:GetDuration()
			self.bindData.playStatus = PlayStatusControl.Pause

			self:RefreshVideoProgressView()
		end
	end

	if imageData.videoId then
		videoPlayer:PlayVideo(imageData.videoId, true, nil, onVideoPlayComplete)
	else
		videoPlayer:PlayVideoUrl(videoUrl, true, nil, onVideoPlayComplete)
	end
end

function M:RefreshVideoProgressView()
	local totalTimeFormat = self:FormatTime(self.videoTotalTime)
	local currentTime = self.videoPlayer:GetCurrentTime()
	local currentTimeFormat = self:FormatTime(currentTime)
	self.bindData.videoProgress = ("%s/%s"):format(currentTimeFormat, totalTimeFormat)
end

function M:FormatTime(time)
	local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)
	local seconds = math.floor(time - minutes * gClientConst.SECONDS_PER_MINUTE)

	return gString.Format("%02d:%02d", minutes, seconds)
end

function M:OnImageRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.imageViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local imageUrl = unpack(data.imageURL)
	local isTaskTemplate = data.templateId and data.templateId > 0
	store.imageType = isTaskTemplate and gClientConst.YanJieImageType.Task or gClientConst.YanJieImageType.Normal
	imageUrl = gClientUtils.GetFilePickerImageUrl(imageUrl)

	store.imageW:SetUrlWithCallback(imageUrl, function (texture, url)
		if self.hasDestroy or imageUrl ~= url then
			return
		end

		if texture.height <= texture.width then
			store.showTypeControl = 0
		else
			store.showTypeControl = 1
			store.imageH.url = url
		end

		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(self.socialNetworkData)

		if tuiteCfg and tuiteCfg.AgentId > 0 then
			store.showTextControl = 1
			store.textColorControl = tuiteCfg.NameTextColorControl or 0
			local agentCfg = LTConfig.AgentConfig.GetConfig(tuiteCfg.AgentId)
			store.name = agentCfg.Name
		else
			store.showTextControl = 0
		end
	end)
end

function M:OnDPadSelect(args)
	local indexNew = args.imageList.selectedIndex + args.delta

	if indexNew < 0 or indexNew > args.imageList.itemData.Count - 1 then
		return
	end

	args.imageList:GoToIndex(indexNew, false)
end

function M:OnLeftJoyStickMoveX(store, ctx)
	if ctx.started then
		if store.lastJoyStickMoveTime and ctx.startTime <= store.lastJoyStickMoveTime + 0.5 then
			return
		end

		local dir = ctx:ReadValueVector2()

		if math.abs(dir.x) < math.abs(dir.y) then
			return
		end

		local delta = dir.x > 0 and 1 or -1

		self:OnDPadSelect({
			imageList = store.imageList,
			delta = delta
		})

		store.lastJoyStickMoveTime = ctx.startTime
	end
end

function M:OnDynamicRenderItem(btn, csIndex)
	self:OnRenderItem(btn, csIndex)
end

function M:RefreshCommentItem(store, index)
	local data = self.commentListPageEntity:GetDataByIndex(index)
	local tuiteCommentConfig = LTConfig.TuiteCommentConfig.GetConfig(data.id)
	local content = tuiteCommentConfig and tuiteCommentConfig.Txt or data.text
	store.content = content
	store.isOfficial = data.roleInfo.isCertified == true
	store.officialName = not string.is_null_or_empty(data.roleInfo.account) and ("@%s"):format(data.roleInfo.account) or ""
	store.time = gSocialNetworkUtils.GetFormatTime(data.createTime)
	store.likeButton.isSelected = data.isLike
	store.likeButtonCtrl = data.isLike and 1 or 0
	store.likeCount = data.likeCount
	local animationName = gSocialNetworkUtils.GetLikeAnimationName(data.isLike)

	gClientUtils.FinishAnimation(store.likeAnimation, animationName)

	local avatarStore = gStoreManager:GetStoreGroup(store.avatar.Store):GetStoreByWidget(store.avatar)
	avatarStore.headIcon = gSocialNetworkUtils.GetSCommentAvatarId(data)
	local templateId = data.momentTemplateId
	local roleId = data.roleInfo.roleId
	local isPlayerSelf = gSocialNetworkUtils.CheckIsPlayerSelf(roleId)

	if templateId and templateId > 0 and isPlayerSelf then
		store.name = gSocialNetworkUtils.GetPlayerAccountName()
		store.isOfficial = true
		store.officialName = LTConfig.TuiteConfig.PlayerAccountID
	else
		store.isOfficial = false
		store.name = gSocialNetworkUtils.GetRoleName(data.roleInfo)
	end

	function store.likeButton.luaClick()
		self:OnCommentLikeClick(store, data)
	end
end

function M:OnCommentLikeClick(store, data)
	local isLike = not data.isLike

	gSocialNetworkUtils.LikeSocialNetworkComment(data.id, isLike, function ()
		if self.hasDestroy then
			return
		end

		local animationName = gSocialNetworkUtils.GetLikeAnimationName(isLike)

		gCS.LuaUtils.PlayAnimationByName(store.likeAnimation, animationName)
	end)
end

function M:OnImageItemClick(data)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Display,
		momentData = self.socialNetworkData,
		imageData = data
	})
end

function M:OnShowDetailClick(detailInsideTemplateStore)
	local index = detailInsideTemplateStore.imageList.selectedIndex

	if index == -1 then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Display,
		momentData = self.socialNetworkData,
		imageData = detailInsideTemplateStore.imageList.itemData[index]
	})
end

function M:SwitchShowMode(showMode)
	if self.showModel == showMode then
		return
	end

	if showMode == ShowModeControl.Normal then
		self:SetInputFieldActive(false)
	elseif showMode == ShowModeControl.Edit then
		self:SetInputFieldActive(true)
	end
end

function M:SetInputFieldActive(isActive)
	self.showModel = isActive and ShowModeControl.Edit or ShowModeControl.Normal

	self.bindData.maskButton:SetActive(isActive)
	self.bindData.inputFieldAnimation.gameObject:SetActive(isActive)

	if isActive then
		self.bindData.inputField:ActivateInputField()
	end
end

function M:OnCommentClick()
	self:SwitchShowMode(ShowModeControl.Edit)

	self.bindData.inputField.text = ""
	self.bindData.inputTips = ("%d/%d"):format(0, LTConfig.TuiteConfig.CommentMaxLength)
end

function M:OnInputFieldValueChange()
	local inputContent = self.bindData.inputField.text:gsub("[\r\n]", "")

	if inputContent ~= self.bindData.inputField.text then
		self.bindData.inputField.text = inputContent
	end

	local inputLength = System.String(inputContent).Length
	self.bindData.inputTips = ("%d/%d"):format(inputLength, LTConfig.TuiteConfig.CommentMaxLength)
end

function M:OnSendCommentClick()
	local commentContent = self.bindData.inputField.text

	if string.is_null_or_empty(commentContent) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900987).Text)

		return
	end

	self:SwitchShowMode(ShowModeControl.Normal)
	gClientUtils.EnvSdkReviewWords(commentContent, function ()
		if self.hasDestroy then
			return
		end

		gSocialNetworkUtils.CommentSocialNetwork(self.socialNetworkData, commentContent)
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SNSCheckFail)
	end, "SocialNetWork")
end

function M:OnCommentSuccess(args)
	if args.id == self.socialNetworkData.id then
		local pageSize = self.commentListPageEntity.pageSize
		local id = self.socialNetworkData.id
		local templateId = self.socialNetworkData.templateId

		gSocialNetworkUtils.GetCommentList(id, templateId, 1, pageSize)
	end
end

function M:OnCommentLikeSuccess(args)
	local id = args.id
	local data = self.commentListPageEntity:GetDataById(id)

	if data then
		data.isLike = args.isLike
		data.likeCount = args.likeCount

		self:RefreshPanelView()
	end
end

function M:OnScroll(isPullUpToRefresh)
	self.isScrolling = true

	if self.triggerLoading then
		return
	end

	if isPullUpToRefresh and self.commentListPageEntity:CheckLoadMore() then
		self.triggerLoading = true
	end
end

function M:OnScrollEnd()
	self.isScrolling = nil

	if self.triggerLoading then
		self:GetRequestCommentList()

		self.triggerLoading = nil
	end
end

function M:OnUpdate()
	if self.isScrolling then
		self.timer = self.timer or 0
		self.timer = self.timer + Time.deltaTime

		if gClientConst.YanJieScrollIngCheckInterval <= self.timer then
			self:CheckCommentBottom()

			self.timer = 0
		end
	else
		self.timer = nil
	end

	local playStatus = self.videoPlayer and self.videoPlayer.CurPlayState

	if playStatus == PlayState.Playing and self.videoTotalTime and not self.isSetVideoTime then
		local currentTime = self.videoPlayer:GetCurrentTime()
		local progress = currentTime / self.videoTotalTime
		local diffTime = self.videoTotalTime - currentTime

		if diffTime <= gClientConst.VideoPlayFinishThresholdTime then
			local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.socialNetworkData)

			gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.VideoFinished)
		end

		self.bindData.videoSliderValue = progress
	end
end

function M:OnVideoProgressChange(value)
	if self.isSetVideoTime then
		local targetTime = value * self.videoTotalTime

		self.videoPlayer:Seek(targetTime)
	end

	self:RefreshVideoProgressView()
end

function M:CheckCommentBottom()
	if self.currentMaxCsIndex then
		local result, csIndex = nil
		local startCsIndex = self.currentMaxCsIndex - 2
		local endCsIndex = self.currentMaxCsIndex + 1
		result, csIndex = self.bindData.list:GetBottomVisibleMaxIndex(startCsIndex, endCsIndex, csIndex)

		if result then
			local data = self.viewDataList[csIndex + 1]

			if data.tIndex == TemplateType.Comment and data.index == self.commentListPageEntity.totalCount then
				local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.socialNetworkData)

				gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.CommentBottom)
			end
		end
	end
end

function M:OnFollowSuccess(roleInfo)
	if self.socialNetworkData.roleInfo.roleId == roleInfo.roleId then
		self.socialNetworkData.isFollow = roleInfo.isFollow
		self.socialNetworkData.roleInfo.isFollow = roleInfo.isFollow

		self:RefreshPanelView()
	end
end

function M:OnExitClick()
	if self.showModel == ShowModeControl.Edit then
		self:SwitchShowMode(ShowModeControl.Normal)

		if not self.openCommentOnly then
			return
		end
	end

	M.base.OnExitClick(self)
end

function M:ClearData()
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)
	self.inputFieldAnimationCo = coroutine.stop(self.inputFieldAnimationCo)
	self.socialNetworkData = nil
	self.openCommentOnly = false
	self.videoPlayer = self.videoPlayer and self.videoPlayer:Stop()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

function M:OnPauseClick()
	self.videoPlayer:Pause()

	self.bindData.playStatus = PlayStatusControl.Play
end

function M:OnMaskClick()
	self:SetInputFieldActive(false)
end

function M:OnPlayClick()
	if self.videoPlayer.CurPlayState == PlayState.Pause or self.videoPlayer.CurPlayState == PlayState.Stop then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	elseif self.videoPlayer.CurPlayState == PlayState.Playing then
		self:OnPauseClick()
	end
end

function M:OnBeginDragProgress()
	self.isSetVideoTime = true

	if self.videoPlayer.CurPlayState == PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
end

function M:OnEndDragProgress()
	self.isSetVideoTime = false

	if self.videoPlayer.CurPlayState == PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
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
