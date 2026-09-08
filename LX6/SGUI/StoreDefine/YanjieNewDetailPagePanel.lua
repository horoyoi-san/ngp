-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewDetailPagePanel.lua
-- Decompiled from: 02000_YanjieNewDetailPagePanel.lua_2f5a2fbd843d.luajit

C_YanjieNewDetailPagePanel = DefClass("C_YanjieNewDetailPagePanel", C_YanjieNewDetailPagePanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewDetailPagePanel = C_YanjieNewDetailPagePanel
local M = C_YanjieNewDetailPagePanel
local IdKey = "id"
local TemplateType = {
	["'\\xfbO-\\xd4?\\xb9L\\xacS\\xbe\\xa2"] = 4,
	["N#nP"] = 2,
	["I\\xbedX\\x91\\xfdJgpX"] = 1,
	["1\\xe6\\#\\xd4?\\xb9L\\xacS\\xbe\\xa2"] = 3,
	["8M\\x85\\x8f\\x8aM"] = 0
}
local ShowModeControl = {
	["_&tO"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}
local ShowTypeControl = {
	["*A\\x95\\x8b\\x8cv"] = 0,
	["*A\\x95\\x8b\\x8ci"] = 1
}
local PlayStatusControl = {
	["\\x85\\xbe\\x9dc:\\xfb<"] = 2,
	["J.|B"] = 0,
	["}\\xaf\\xb7\\xbc\\xb3"] = 1
}
local PlayState = Live.Engine.CCPlayer.CCPlayerCore.PlayState
local VideoSeekStep = 5
local VideoSeekLongPressThreshold = 0.5
local VideoSeekRepeatInterval = 0.3
local VideoSeekLandGrace = 0.4

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItem")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldValueChange")
	self.bindData.sendButton.luaClick = self.CreateAction(self, "OnSendCommentClick")
	self.bindData.playVideoButton.luaClick = self.CreateAction(self, "OnPlayVideoClick")
	self.bindData.videoDisplayButton.luaClick = self.CreateAction(self, "OnVideoDisplayClick")
	self.bindData.videoSlider.luaValueChanged = self.CreateAction(self, "OnVideoProgressChange")
	self.bindData.videoSlider.luaPress = self.CreateAction(self, "OnBeginDragProgress")
	self.bindData.videoSlider.luaRelease = self.CreateAction(self, "OnEndDragProgress")
	self.bindData.playButton.luaClick = self.CreateAction(self, "OnPlayClick")
	self.bindData.pauseButton.luaClick = self.CreateAction(self, "OnPauseClick")
	self.bindData.maskButton.luaClick = self.CreateAction(self, "OnMaskClick")
	self.bindData.gamePadPlayButton.luaClick = self.CreateAction(self, "OnPlayClick")
	self.bindData.gamePadPauseButton.luaClick = self.CreateAction(self, "OnPauseClick")
	self.bindData.playBarHoverAreaButton.luaHover = self.CreateAction(self, "OnPlayBarHover")
	self.bindData.playBarHoverAreaButton.luaUnhover = self.CreateAction(self, "OnPlayBarUnHover")

	if self.bindData.seekBackwardButton then
		self.bindData.seekBackwardButton.luaPress = self.CreateActionWithArgs(self, "OnSeekButtonPress", -1)
		self.bindData.seekBackwardButton.luaRelease = self.CreateAction(self, "OnSeekButtonRelease")
	end

	if self.bindData.seekForwardButton then
		self.bindData.seekForwardButton.luaPress = self.CreateActionWithArgs(self, "OnSeekButtonPress", 1)
		self.bindData.seekForwardButton.luaRelease = self.CreateAction(self, "OnSeekButtonRelease")
	end

	if self.bindData.livestreamBtn then
		self.bindData.livestreamBtn.luaClick = self.CreateAction(self, "OnClickLivestreamBtn")
	end
end

M.OnStart = function(self)
	gSocialNetworkUtils.DynamicLoadList(self.bindData.list, self.CreateAction(self, "OnScroll"), self.CreateAction(self, "OnScrollEnd"))
end

M.GetMessageEvents = function(self)
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
			if args.id ~= self.socialNetworkData.id then
				self.socialNetworkData.isLike = args.isLike
				self.socialNetworkData.likeCount = args.likeCount

				self:RefreshPanelView()
			end
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
			if args.id ~= self.socialNetworkData.id then
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

			local total = requestData and requestData.total or #self.commentDataList

			if self.socialNetworkData.commentCount == total then
				self.socialNetworkData.commentCount = total

				self:RefreshPanelView()
			end

			self:CheckCommentBottom()
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
		[gEventConstants.ON_SHOW_YANJIE_DETAIL_INPUT_COMMENT] = function (_, id)
			if self.socialNetworkData and self.socialNetworkData.id ~= id then
				self:OnCommentClick()
			end
		end,
		[gEventConstants.ON_YANJIE_GET_REWARD_SUCCESS] = function (_)
			self:RefreshPanelView()
		end,
		[gEventConstants.ON_YANJIE_CONTENT_SHOW] = function (_, args)
			if args and args.secondShowType == gClientConst.YanJieShowType.Detail and self.videoPlayer then
				self:OnPauseClick()
			end
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.videoPlayer = nil
	self.hasPlayVideoClick = nil
	self.seekTargetTime = nil
	self.seekReleaseElapsed = nil
	self.seekHoldDir = nil
	self.socialNetworkData = args.data
	self.isScrolling = nil
	self.showModel = 0
	self.currentMaxCsIndex = nil
	self.commentDataList = {}
	self.expandedMap = {}
	self.replyTarget = nil
	local id = args.id or args.data and args.data.id

	if id then
		gSocialNetworkUtils.GetSocialNetworkDetail(id)

		slot3 = gClientToGameDelegate

		slot3:AskReportTuiteDetailOpened(id).Callback = function (errorId)
			if errorId == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(errorId)

				return
			end
		end
	end
end

M.InitView = function(self, args)
	self.bindData.inputField.characterLimit = LTConfig.TuiteConfig.CommentMaxLength

	if args and args.disableDetailOffsetAnim then
		self.bindData.list.enableOffsetAnimation = false
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieDetailPagePanel_open")
	self.RefreshPanelView(self)
	self.RefreshCommentListView(self)

	if args and args.showComment then
		self.openCommentOnly = true

		self.OnCommentClick(self)
	else
		self.SetInputFieldActive(self, false)
	end

	self.RefreshDisplayView(self)
	self.RefreshLivestreamBtn(self, args.id)
end

M.GetRequestCommentList = function(self)
	local id = self.socialNetworkData.id
	local templateId = self.socialNetworkData.templateId

	gSocialNetworkUtils.GetCommentList(id, templateId)
end

M.RefreshPanelView = function(self)
	self.viewDataList = self:GetViewDataList()

	self.bindData.list.onGetTIndex = function(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.list:SetSimpleList(#self.viewDataList)
end

M.GetViewDataList = function(self)
	local viewDataList = {}

	if self.socialNetworkData then
		local data = self.socialNetworkData
		local isTaskTemplate = data.templateId and data.templateId >= 0
		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
		isTaskTemplate = isTaskTemplate and tuiteCfg and tuiteCfg.TaskEvent and tuiteCfg.TaskEvent >= 0

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

	local commentViewDataList = self.commentDataList

	for index, comment in ipairs(commentViewDataList) do
		table.insert(viewDataList, {
			tIndex = TemplateType.FirstComment,
			index = index
		})

		local replies = comment.replies

		if replies and #replies <= 0 then
			if self.expandedMap[comment.id] then
				for replyIndex = 1, #replies do
					table.insert(viewDataList, {
						tIndex = TemplateType.SecondComment,
						parentIndex = index,
						replyIndex = replyIndex
					})
				end
			else
				table.insert(viewDataList, {
					tIndex = TemplateType.ExpandComment,
					parentIndex = index,
					count = #replies
				})
			end
		end
	end

	return viewDataList
end

M.RefreshCommentListView = function(self, requestData)
	self.commentDataList = requestData and requestData.list or self.commentDataList or {}

	self:RefreshPanelView()
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if data.tIndex ~= TemplateType.Detail then
		self.RefreshTuiteiItemView(self, btn)
	elseif data.tIndex ~= TemplateType.Task then
		self.RefreshTaskView(self, btn)
	elseif data.tIndex ~= TemplateType.FirstComment then
		self.RefreshFirstCommentItem(self, btn, csIndex)
	elseif data.tIndex ~= TemplateType.SecondComment then
		self.RefreshSecondCommentItem(self, btn, csIndex)
	elseif data.tIndex ~= TemplateType.ExpandComment then
		self.RefreshExpandCommentItem(self, btn, csIndex)
	end

	self.currentMaxCsIndex = csIndex
end

M.RefreshExpandCommentItem = function(self, btn, csIndex)
	local data = self.viewDataList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	slot5 = LTConfig.TuiteConfig.ExpandTips
	store.content = slot5:format(data.count or 0)
	local parent = self.commentDataList[data.parentIndex]
	local parentId = parent and parent.id

	btn.luaClick = function()
		if parentId then
			self.expandedMap[parentId] = true

			self:RefreshPanelView()
		end
	end
end

M.RefreshSecondCommentItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local parent = self.commentDataList[data.parentIndex]
	local reply = parent and parent.replies and parent.replies[data.replyIndex]

	if reply then
		self.RefreshCommentItem(self, store, reply, parent)

		store.commentCount = ""
	end

	store.layout:ForceRebuildLayoutImmediate()
end

M.RefreshFirstCommentItem = function(self, btn, index)
	local data = self.viewDataList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local comment = self.commentDataList[data.index]

	self:RefreshCommentItem(store, comment, nil)

	local replyCount = comment.replies and #comment.replies or 0
	store.commentCount = replyCount <= 0 and gSocialNetworkUtils.GetCountFormat(replyCount) or ""

	store.layout:ForceRebuildLayoutImmediate()
end

M.RefreshTaskView = function(self, btn)
	self:RefreshTuiteiItemView(btn)

	local id = self.socialNetworkData.id
	local tuiteCfg = LTConfig.TuiteConfig.GetConfig(id)
	local hasReward = tuiteCfg.TaskEvent >= 0

	if hasReward then
		local dropDataList = gClientUtils.GetTaskRewardList(tuiteCfg.TaskEvent)
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local rewardTemplateButton = store.rewardTemplateButton
		local rewardStore = gStoreManager:GetStoreGroup(rewardTemplateButton.Store):GetStoreByWidget(rewardTemplateButton)

		rewardStore.rewardList.luaSimpleRenderItem = function(childBtn, childIndex)
			local dropData = dropDataList[childIndex + 1]

			gCommonItemManager:OnCommonItemRender(childBtn, nil, dropData)
		end

		rewardStore.rewardList:SetSimpleList(#dropDataList)
	end
end

M.RefreshTuiteiItemView = function(self, btn)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	gSocialNetworkUtils.RefreshCommonMomentItem(store, self.socialNetworkData)

	store.isShowImageList = false
	store.isVideoActive = false
	store.commentButton.luaClick = self:CreateAction(self.OnCommentClick)
	store.gamepadShowDetailButton.luaClick = self:CreateActionWithArgs(self.OnShowDetailClick, store)

	store.layout:ForceRebuildLayoutImmediate()

	local activeContent = self.bindData.panelNavArea.CurrentActiveContent

	if self.showModel ~= ShowModeControl.Normal and (activeContent ~= nil or activeContent.transform.parent == btn.transform.parent) then
		self.bindData.panelNavArea.CurrentActiveContent = btn
	end
end

M.RefreshDisplayView = function(self)
	if self.socialNetworkData then
		self.RefreshTextContainerView(self)

		local imageViewDataList, isVideo = gSocialNetworkUtils.GetSocialNetworkImageList(self.socialNetworkData)

		if #imageViewDataList <= 0 then
			self.bindData.contentShowModeControl = 1
			self.bindData.imageList.luaSimpleRenderItem = self.CreateAction(self, self.OnImageRenderItem)
			local dotViewDataList = {}

			if #imageViewDataList <= 1 then
				for index, _ in ipairs(imageViewDataList) do
					table.insert(dotViewDataList, {
						id = index,
						selected = index ~= 1
					})
				end
			end

			self.bindData.roundList:SetSimpleList(#dotViewDataList)

			self.imageViewDataList = imageViewDataList

			self.bindData.imageList:SetSimpleList(#imageViewDataList)

			self.bindData.imageList.luaTargetPageChange = function(dotIndex)
				self.bindData.roundList:SelectItem(dotIndex)
			end

			self.bindData.playVideoButton:SetActive(isVideo)

			return
		end
	end

	self.bindData.contentShowModeControl = 0
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

M.OnPlayVideoClick = function(self)
	if self.hasPlayVideoClick then
		return
	end

	self.hasPlayVideoClick = true
	local imageData = self.imageViewDataList[1]
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(self.socialNetworkData)
	local showType = tuiteCfg and tuiteCfg.VideoTypeControl ~= 1 and ShowTypeControl.VideoW or ShowTypeControl.VideoH
	self.bindData.showTypeCtrl = showType
	local targetVideoPlayer = showType ~= ShowTypeControl.VideoW and self.bindData.videoPlayerW or self.bindData.videoPlayerH

	if table.find(LTConfig.TuiteConfig.TimelineVideoTuiteIdList, self.socialNetworkData.id) then
		self.videoPlayer = self.bindData.multiVideoController
		self.videoPlayer.currentPlayer = targetVideoPlayer
		self.videoPlayer.enabled = true

		self.PlayTimelineVideo(self, self.socialNetworkData.id)
	else
		targetVideoPlayer.Init(targetVideoPlayer)

		local rootGo = self.rootGo

		local onVideoPlayComplete = function()
			if gClientUtils.NotNil(rootGo) then
				self.bindData.playVideoButton:SetActive(false)

				self.bindData.contentShowModeControl = 2

				self.bindData.videoDisplayButton.gameObject:SetActive(true)

				self.videoPlayer = targetVideoPlayer
				self.videoTotalTime = self.videoPlayer:GetDuration()
				self.bindData.playStatus = PlayStatusControl.Pause

				self:RefreshVideoProgressView()
			end
		end

		targetVideoPlayer.PlayVideo(targetVideoPlayer, imageData.videoId, true, nil, onVideoPlayComplete)
	end
end

M.RefreshVideoProgressView = function(self, overrideTime)
	local totalTimeFormat = self:FormatTime(self.videoTotalTime)
	local currentTime = overrideTime or self.videoPlayer:GetCurrentTime()
	local currentTimeFormat = self:FormatTime(currentTime)
	self.bindData.videoProgress = ("%s/%s"):format(currentTimeFormat, totalTimeFormat)
end

M.FormatTime = function(self, time)
	local minutes = math.floor(time / gClientConst.SECONDS_PER_MINUTE)
	local seconds = math.floor(time - minutes * gClientConst.SECONDS_PER_MINUTE)

	return gString.Format("%02d:%02d", minutes, seconds)
end

M.OnImageRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.imageViewDataList[luaIndex]
	slot5 = gStoreManager
	slot5 = slot5:GetStoreGroup(btn.Store)
	local store = slot5:GetStoreByWidget(btn)
	local bucketName = unpack(data.imageURL)
	store.imageType = gSocialNetworkUtils.GetImageType(self.socialNetworkData.id)
	slot7 = store.imageW

	slot7:SetOssObjectWithCallback(bucketName, function (texture, _)
		if self.hasDestroy or not texture then
			return
		end

		if texture.height < texture.width then
			store.showTypeControl = 0
		else
			store.showTypeControl = 1
			store.imageH.commonBucketName = bucketName
		end

		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(self.socialNetworkData)

		if tuiteCfg and tuiteCfg.AgentId <= 0 then
			store.showTextControl = 1
			store.textColorControl = tuiteCfg.NameTextColorControl or 0
			local agentCfg = LTConfig.AgentConfig.GetConfig(tuiteCfg.AgentId)
			store.name = agentCfg and agentCfg.Name or ""
		else
			store.showTextControl = 0
		end
	end)
end

M.OnDPadSelect = function(self, args)
	local indexNew = args.imageList.selectedIndex + args.delta

	if indexNew <= 0 or indexNew <= args.imageList.itemData.Count - 1 then
		return
	end

	args.imageList:GoToIndex(indexNew, false)
end

M.OnLeftJoyStickMoveX = function(self, store, ctx)
	if ctx.started then
		if store.lastJoyStickMoveTime and ctx.startTime < store.lastJoyStickMoveTime + 0.5 then
			return
		end

		local dir = ctx.ReadValueVector2(ctx)

		if math.abs(dir.x) >= math.abs(dir.y) then
			return
		end

		local delta = dir.x <= 0 and 1 or -1

		self:OnDPadSelect({
			imageList = store.imageList,
			delta = delta
		})

		store.lastJoyStickMoveTime = ctx.startTime
	end
end

M.OnDynamicRenderItem = function(self, btn, csIndex)
	self.OnRenderItem(self, btn, csIndex)
end

M.RefreshCommentItem = function(self, store, data, parentFirstLevel)
	local roleInfo = data.roleInfo or {}
	store.content = gSocialNetworkUtils.GetCommentText(data)
	store.time = gSocialNetworkUtils.GetFormatTime(data.createTime)
	store.likeButton.isSelected = data.isLike
	store.likeButtonCtrl = data.isLike and 1 or 0
	store.likeCount = data.likeCount or 0
	store.commentButton.luaClick = self:CreateActionWithArgs("OnSecondCommentClick", data)
	local animationName = gSocialNetworkUtils.GetLikeAnimationName(data.isLike)

	gClientUtils.FinishAnimation(store.likeAnimation, animationName)

	local avatarStore = gStoreManager:GetStoreGroup(store.avatar.Store):GetStoreByWidget(store.avatar)
	local templateId = data.momentTemplateId
	local roleId = roleInfo.roleId
	local isPlayerSelf = roleId == nil and gSocialNetworkUtils.CheckIsPlayerSelf(roleId)
	local displayName = nil

	if templateId and templateId <= 0 and isPlayerSelf then
		displayName = gSocialNetworkUtils.GetPlayerAccountName()
		store.isOfficial = true
		store.officialName = LTConfig.TuiteConfig.PlayerAccountID
		avatarStore.headIcon = gSocialNetworkUtils.GetSCommentAvatarId(data)
	elseif roleId == nil then
		store.isOfficial = roleInfo.isCertified ~= true
		store.officialName = not string.is_null_or_empty(roleInfo.account) and ("@%s"):format(roleInfo.account) or ""
		displayName = gSocialNetworkUtils.GetRoleName(roleInfo)
		avatarStore.headIcon = gSocialNetworkUtils.GetSCommentAvatarId(data)
	else
		store.isOfficial = false
		store.officialName = ""
		displayName = roleInfo.name or ""
		avatarStore.headIcon = nil
	end

	if data.parentId and data.replyToName and parentFirstLevel and data.replyToRoleId == parentFirstLevel.roleId and LTConfig.TuiteConfig.ReplyCommentName then
		store.name = LTConfig.TuiteConfig.ReplyCommentName:format(displayName, data.replyToName)
	else
		store.name = displayName
	end

	store.likeButton.luaClick = function()
		self:OnCommentLikeClick(store, data)
	end
end

M.OnCommentLikeClick = function(self, store, data)
	local isLike = not data.isLike

	gSocialNetworkUtils.LikeSocialNetworkComment(data.id, isLike, function ()
		if self.hasDestroy then
			return
		end

		local animationName = gSocialNetworkUtils.GetLikeAnimationName(isLike)

		gCS.LuaUtils.PlayAnimationByName(store.likeAnimation, animationName)
	end, data.momentId)
end

M.OnImageItemClick = function(self, data)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Display,
		momentData = self.socialNetworkData,
		imageData = data
	})
end

M.OnShowDetailClick = function(self, detailInsideTemplateStore)
	local index = detailInsideTemplateStore.imageList.selectedIndex

	if index ~= -1 then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
		secondShowType = gClientConst.YanJieShowType.Display,
		momentData = self.socialNetworkData,
		imageData = detailInsideTemplateStore.imageList.itemData[index]
	})
end

M.SwitchShowMode = function(self, showMode)
	if self.showModel ~= showMode then
		return
	end

	if showMode ~= ShowModeControl.Normal then
		self.SetInputFieldActive(self, false)
	elseif showMode ~= ShowModeControl.Edit then
		self.SetInputFieldActive(self, true)
	end
end

M.SetInputFieldActive = function(self, isActive)
	self.showModel = isActive and ShowModeControl.Edit or ShowModeControl.Normal

	self.bindData.maskButton:SetActive(isActive)
	self.bindData.inputFieldAnimation.gameObject:SetActive(isActive)

	if isActive then
		self.bindData.inputField:ActivateInputField()
	end
end

M.OnCommentClick = function(self)
	if not self.CheckCanComment(self) then
		return
	end

	self.replyTarget = nil

	self:SwitchShowMode(ShowModeControl.Edit)

	self.bindData.inputField.text = ""
	self.bindData.inputField.placeHolder.text = LTConfig.TuiteConfig.FirstCommentHintTips
	self.bindData.inputTips = ("%d/%d"):format(0, LTConfig.TuiteConfig.CommentMaxLength)
end

M.OnSecondCommentClick = function(self, data)
	if not self.CheckCanComment(self) then
		return
	end

	local parentId = data.parentId or data.id
	local roleInfo = data.roleInfo or {}
	local replyToRoleId = roleInfo.roleId or data.roleId
	local replyToName = gSocialNetworkUtils.GetCommentDisplayName(data)

	self:StartReply(parentId, replyToRoleId, replyToName)
end

M.CheckCanComment = function(self)
	local tuiteId = self.socialNetworkData and self.socialNetworkData.id

	if not tuiteId then
		return false
	end

	local canComment, limitReason = gSocialNetworkUtils.CheckCanPlayerYanjieComment(tuiteId)

	if canComment then
		return true
	end

	if limitReason ~= "daily" then
		self.ShowCommentLimitTips(self, LTConfig.TuiteConfig.PlayerCommentDailyLimitTips, gSocialNetworkUtils.GetYanjiePlayerCommentDailyMaxCount())
	else
		self.ShowCommentLimitTips(self, LTConfig.TuiteConfig.PlayerCommentTuiteLimitTips, gSocialNetworkUtils.GetYanjiePlayerCommentMaxCount())
	end

	return false
end

M.ShowCommentLimitTips = function(self, tipsFormat, maxCount)
	if tipsFormat ~= nil or tipsFormat ~= "" then
		print_error("[Yanjie] 评论上限提示文案未配置, maxCount=", maxCount)

		return
	end

	gDisplayMessageMgr:ShowMessageContent(tipsFormat:format(maxCount))
end

M.StartReply = function(self, parentId, replyToRoleId, replyToName)
	self.replyTarget = {
		parentId = parentId,
		replyToRoleId = replyToRoleId,
		replyToName = replyToName
	}

	self:SwitchShowMode(ShowModeControl.Edit)

	self.bindData.inputField.text = ""
	self.bindData.inputTips = ("%d/%d"):format(0, LTConfig.TuiteConfig.CommentMaxLength)
	self.bindData.inputField.placeHolder.text = LTConfig.TuiteConfig.SecondCommentHintTips:format(replyToName or "")
end

M.OnInputFieldValueChange = function(self)
	local inputContent = self.bindData.inputField.text:gsub("[\r\n]", "")

	if inputContent == self.bindData.inputField.text then
		self.bindData.inputField.text = inputContent
	end

	local inputLength = System.String(inputContent).Length
	self.bindData.inputTips = ("%d/%d"):format(inputLength, LTConfig.TuiteConfig.CommentMaxLength)
end

M.OnSendCommentClick = function(self)
	local commentContent = self.bindData.inputField.text

	if string.is_null_or_empty(commentContent) then
		gDisplayMessageMgr:ShowMessageContent(LTConfig.TextScriptTextConfig.GetConfig(89900987).Text)

		return
	end

	self.SwitchShowMode(self, ShowModeControl.Normal)

	local replyTarget = self.replyTarget
	self.replyTarget = nil

	gClientUtils.EnvSdkReviewWords(commentContent, function ()
		if self.hasDestroy then
			return
		end

		if replyTarget and replyTarget.parentId then
			self.expandedMap[replyTarget.parentId] = true

			gSocialNetworkUtils.CommentSocialNetwork(self.socialNetworkData, commentContent, replyTarget.parentId, replyTarget.replyToRoleId, replyTarget.replyToName)
		else
			gSocialNetworkUtils.CommentSocialNetwork(self.socialNetworkData, commentContent)
		end
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SNSCheckFail)
	end, "SocialNetWork")
end

M.OnCommentSuccess = function(self, args)
end

M.OnCommentLikeSuccess = function(self, args)
	local id = args.id
	local data = nil

	for _, c in ipairs(self.commentDataList) do
		if c.id ~= id then
			data = c

			break
		end

		if c.replies then
			for _, r in ipairs(c.replies) do
				if r.id ~= id then
					data = r

					break
				end
			end

			if data then
				break
			end
		end
	end

	if data then
		data.isLike = args.isLike
		data.likeCount = args.likeCount

		self.RefreshPanelView(self)
	end
end

M.OnScroll = function(self, isPullUpToRefresh)
	self.isScrolling = true
end

M.OnScrollEnd = function(self)
	self.isScrolling = nil
end

M.OnUpdate = function(self)
	if self.isScrolling then
		self.timer = self.timer or 0
		self.timer = self.timer + Time.deltaTime

		if gClientConst.YanJieScrollIngCheckInterval < self.timer then
			self.CheckCommentBottom(self)

			self.timer = 0
		end
	else
		self.timer = nil
	end

	local playStatus = self.videoPlayer and self.videoPlayer.CurPlayState

	if playStatus ~= PlayState.Playing and self.videoTotalTime and not self.isSetVideoTime then
		local currentTime = self.videoPlayer:GetCurrentTime()
		local diffTime = self.videoTotalTime - currentTime

		if diffTime < gClientConst.VideoPlayFinishThresholdTime then
			local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.socialNetworkData)

			gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.VideoFinished)
		end

		if self.seekTargetTime then
			if self.seekHoldDir then
				self.bindData.videoSliderValue = self.seekTargetTime / self.videoTotalTime
			else
				self.seekReleaseElapsed = (self.seekReleaseElapsed or 0) + Time.deltaTime

				if VideoSeekLandGrace < self.seekReleaseElapsed then
					self.seekTargetTime = nil
					self.seekReleaseElapsed = nil
					self.bindData.videoSliderValue = currentTime / self.videoTotalTime
				else
					self.bindData.videoSliderValue = self.seekTargetTime / self.videoTotalTime
				end
			end
		else
			self.bindData.videoSliderValue = currentTime / self.videoTotalTime
		end
	end

	if self.seekHoldDir then
		local atBoundary = self.seekHoldDir <= 0 and self.seekTargetTime and self.videoTotalTime > self.seekTargetTime or self.seekHoldDir >= 0 and self.seekTargetTime and self.seekTargetTime > 0

		if atBoundary then
			self.seekHoldDir = nil
		else
			self.seekHoldElapsed = self.seekHoldElapsed + Time.deltaTime

			if VideoSeekLongPressThreshold < self.seekHoldElapsed then
				self.seekRepeatTimer = self.seekRepeatTimer + Time.deltaTime

				if VideoSeekRepeatInterval < self.seekRepeatTimer then
					self.seekRepeatTimer = self.seekRepeatTimer - VideoSeekRepeatInterval

					self.SeekByDelta(self, self.seekHoldDir * VideoSeekStep, false)
				end
			end
		end
	end
end

M.OnVideoProgressChange = function(self, value)
	if self.isSetVideoTime then
		local targetTime = value * self.videoTotalTime

		self.videoPlayer:Seek(targetTime)

		self.seekTargetTime = nil
		self.seekReleaseElapsed = nil
	end

	self.RefreshVideoProgressView(self)
end

M.OnSeekButtonPress = function(self, dir)
	if not self.videoPlayer or not self.videoTotalTime or self.videoTotalTime < 0 then
		return
	end

	self.seekHoldDir = dir
	self.seekHoldElapsed = 0
	self.seekRepeatTimer = 0

	if self.videoPlayer.CurPlayState ~= PlayState.Pause or self.videoPlayer.CurPlayState ~= PlayState.Stop then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end

	self.OnPlayBarHover(self)
	self.SeekByDelta(self, dir * VideoSeekStep, false)
end

M.OnSeekButtonRelease = function(self)
	if not self.seekHoldDir then
		return
	end

	self.seekHoldDir = nil

	if self.seekTargetTime and self.videoPlayer == self.bindData.multiVideoController then
		self.videoPlayer:Seek(self.seekTargetTime, true)
	end

	self.OnPlayBarUnHover(self)
end

M.SeekByDelta = function(self, deltaSeconds, containSound)
	if not self.videoPlayer or not self.videoTotalTime or self.videoTotalTime < 0 then
		return
	end

	local baseTime = self.seekTargetTime or self.videoPlayer:GetCurrentTime()
	local targetTime = math.max(0, math.min(self.videoTotalTime, baseTime + deltaSeconds))
	self.seekTargetTime = targetTime
	self.seekReleaseElapsed = nil

	if self.videoPlayer ~= self.bindData.multiVideoController then
		self.videoPlayer:Seek(targetTime)
	else
		self.videoPlayer:Seek(targetTime, containSound ~= true)
	end

	self.bindData.videoSliderValue = targetTime / self.videoTotalTime

	self.RefreshVideoProgressView(self, targetTime)
end

M.CheckCommentBottom = function(self)
	if self.currentMaxCsIndex then
		local result, csIndex = nil
		local startCsIndex = self.currentMaxCsIndex - 2
		local endCsIndex = self.currentMaxCsIndex + 1
		result, csIndex = self.bindData.list:GetBottomVisibleMaxIndex(startCsIndex, endCsIndex, csIndex)

		if result then
			local data = self.viewDataList[csIndex + 1]

			if data.tIndex ~= TemplateType.FirstComment and data.index ~= #self.commentDataList then
				local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(self.socialNetworkData)

				gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.CommentBottom)
			end
		end
	end
end

M.OnFollowSuccess = function(self, roleInfo)
	if self.socialNetworkData.roleInfo.roleId ~= roleInfo.roleId then
		self.socialNetworkData.isFollow = roleInfo.isFollow
		self.socialNetworkData.roleInfo.isFollow = roleInfo.isFollow

		self.RefreshPanelView(self)
	end
end

M.OnExitClick = function(self)
	if self.showModel ~= ShowModeControl.Edit then
		self.SwitchShowMode(self, ShowModeControl.Normal)

		if not self.openCommentOnly then
			return
		end
	end

	M.base.OnExitClick(self)
end

M.ClearData = function(self)
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)
	self.inputFieldAnimationCo = coroutine.stop(self.inputFieldAnimationCo)
	self.socialNetworkData = nil
	self.openCommentOnly = false
	self.expandedMap = {}
	self.replyTarget = nil
	self.videoPlayer = self.videoPlayer and self.videoPlayer:Stop()
	self.bindData.contentShowModeControl = 0
end

M.OnExecuteExitAction = function(self)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

M.OnPauseClick = function(self)
	self.videoPlayer:Pause()

	self.bindData.playStatus = PlayStatusControl.Play
end

M.OnMaskClick = function(self)
	self.SetInputFieldActive(self, false)
end

M.OnPlayClick = function(self)
	if self.videoPlayer.CurPlayState ~= PlayState.Pause or self.videoPlayer.CurPlayState ~= PlayState.Stop then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	elseif self.videoPlayer.CurPlayState ~= PlayState.Playing then
		self.OnPauseClick(self)
	end
end

M.OnBeginDragProgress = function(self)
	self.isSetVideoTime = true

	if self.videoPlayer.CurPlayState ~= PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
end

M.OnEndDragProgress = function(self)
	self.isSetVideoTime = false

	if self.videoPlayer.CurPlayState ~= PlayState.Pause then
		self.videoPlayer:Resume()

		self.bindData.playStatus = PlayStatusControl.Pause
	end
end

M.OnPlayBarHover = function(self)
	self.autoHidePlayBarCo = coroutine.stop(self.autoHidePlayBarCo)

	self.bindData.playBar:SetActive(true)
end

M.PlayTimelineVideo = function(self, id)
	slot2 = gClientToGameDelegate

	slot2:AskTuiteGetTimelineData(id).Callback = function (errorId, data)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.videoPlayer = self.bindData.multiVideoController

		self.bindData.multiVideoController:PlayMultiVideo(data.TimelineData)
		self.bindData.playVideoButton:SetActive(false)

		self.bindData.contentShowModeControl = 2

		self.bindData.videoDisplayButton:SetActive(true)

		self.videoTotalTime = self.videoPlayer:GetDuration()
		self.bindData.playStatus = PlayStatusControl.Pause

		self:RefreshVideoProgressView()
	end
end

M.OnPlayBarUnHover = function(self)
	self.autoHidePlayBarCo = coroutine.start(function ()
		coroutine.wait(3)
		self.bindData.playBar:SetActive(false)
	end)
end

M.RefreshTextContainerView = function(self)
	local id = self.socialNetworkData.id
	local tutieCfg = LTConfig.TuiteConfig.GetConfig(id)
	slot3 = self.bindData.textContainer

	slot3:SetUrlWithCallback(self.bindData.textContainer.defaultUrl, function (widget)
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
		store.richText = tutieCfg.RichText or ""
	end)
end

M.RefreshLivestreamBtn = function(self, id)
	if id ~= LTConfig.TuiteConfig.DivinerLive and gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.DivinerLive) then
		self.bindData.showLivestreamCtrl = 1
	else
		self.bindData.showLivestreamCtrl = 0
	end
end

M.OnClickLivestreamBtn = function(self)
	gDivinerManager.needOpenLivestream = true

	self.OnExitClick(self)
end
