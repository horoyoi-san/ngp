local M = {}
local RequestMap = gCommonRequestUtils.RequestMap

function M.GetRecommendList(page, pageSize, successCallback)
	gCommonRequestUtils.Start(RequestMap.MomentRecommendList, {
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			successCallback(info)
		end
	})
end

function M.GetMyRelatedMomentList(page, pageSize, successCallback)
	gCommonRequestUtils.Start(RequestMap.MomentRecommendList, {
		menuTuiteType = 1,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			successCallback(info)
		end
	})
end

function M.GetMyReleaseMomentList(page, pageSize, successCallback)
	gCommonRequestUtils.Start(RequestMap.MomentRecommendList, {
		menuTuiteType = 2,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			successCallback(info)
		end
	})
end

function M.GetFollowList(page, pageSize, successCallback)
	gCommonRequestUtils.Start(RequestMap.MomentFollowList, {
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			successCallback(info)
		end
	})
end

function M.GetSocialNetworkListByTopicId(topicId, page, pageSize, successCallback)
	gCommonRequestUtils.Start(RequestMap.MomentListByTopic, {
		topicId = topicId,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			successCallback(info)
		end
	})
end

function M.LikeSocialNetwork(socialNetworkData, callback)
	local id = socialNetworkData.id
	local isLike = not socialNetworkData.isLike
	local request = isLike and RequestMap.MomentLike or RequestMap.MomentCancelLike

	gCommonRequestUtils.Start(request, {
		momentId = id,
		successCallback = function (info)
			local effectiveId = M.GetEffectiveId(socialNetworkData)

			if isLike then
				M.AskInteractTuite(effectiveId, UX.Game.TuiteState.Like)
			else
				M.AskCancelInteractTuite(effectiveId, UX.Game.TuiteState.Like)
			end

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE, {
				id = id,
				isLike = isLike,
				likeCount = info.likeCount
			})

			if callback then
				callback(isLike)
			end
		end
	})
end

function M.CollectionSocialNetwork(socialNetworkData, successCallback)
	local isCollect = socialNetworkData.isCollect
	isCollect = not isCollect
	local id = socialNetworkData.id
	local request = isCollect and RequestMap.MomentCollect or RequestMap.MomentCancelCollect

	gCommonRequestUtils.Start(request, {
		momentId = id,
		successCallback = function ()
			local effectiveId = M.GetEffectiveId(socialNetworkData)

			if isCollect then
				M.AskInteractTuite(effectiveId, UX.Game.TuiteState.Favorite)
			else
				M.AskCancelInteractTuite(effectiveId, UX.Game.TuiteState.Favorite)
			end

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION, {
				id = id,
				isCollect = isCollect
			})

			if successCallback then
				successCallback(isCollect)
			end
		end
	})
end

function M.AskInteractTuite(interactId, interactType)
	if LTConfig.TuiteConfig.GetConfig(interactId) then
		gClientToGameDelegate:AskInteractTuite(interactId, interactType).Callback = function (_)
			return
		end
	end
end

function M.AskCancelInteractTuite(interactId, interactType)
	if LTConfig.TuiteConfig.GetConfig(interactId) then
		gClientToGameDelegate:AskCancelInteractTuite(interactId, interactType).Callback = function (_)
			return
		end
	end
end

function M.FollowRole(socialNetworkData)
	local roleInfo = socialNetworkData.roleInfo
	local roleId = roleInfo.roleId
	local roleName = M.GetRoleName(roleInfo)
	local targetId = roleInfo.roleId

	gCommonRequestUtils.Start(RequestMap.MomentFollow, {
		targetId = targetId,
		successCallback = function ()
			M.ShowPopUp({
				isFollow = true,
				roleName = roleName
			})
			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW, {
				isFollow = true,
				roleId = roleId,
				name = roleName
			})
		end
	})
end

function M.GetSocialNetworkDetail(id)
	gCommonRequestUtils.Start(RequestMap.MomentDetail, {
		momentId = id,
		successCallback = function (info)
			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL, info)
		end
	})
end

function M.GetCommentList(id, templateId, page, pageSize)
	gCommonRequestUtils.Start(RequestMap.CommentList, {
		momentId = id,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			if info.list then
				for _, data in ipairs(info.list) do
					data.momentId = id
					data.momentTemplateId = templateId
				end
			end

			info.page = page

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COMMENT_LIST, info)
		end
	})
end

function M.LikeSocialNetworkComment(id, isLike, callback)
	local request = isLike and RequestMap.CommentLike or RequestMap.CommentCancelLike

	gCommonRequestUtils.Start(request, {
		commentId = id,
		successCallback = function (info)
			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COMMENT_LIKE, {
				id = id,
				isLike = isLike,
				likeCount = info.likeCount
			})

			if callback then
				callback(isLike)
			end
		end
	})
end

function M.CommentSocialNetwork(socialNetworkData, content)
	local id = socialNetworkData.id

	gCommonRequestUtils.Start(RequestMap.CommentAdd, {
		momentId = id,
		text = content,
		successCallback = function (info)
			info.text = content
			info.createTime = info.updateTime
			info.roleInfo = {
				roleId = gCommonRequestUtils.GetNumberRoleId()
			}
			info.likeCount = 0
			info.isLike = false
			info.momentId = id

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK, {
				id = id,
				commentCount = socialNetworkData.commentCount + 1,
				info = info
			})

			local effectiveId = M.GetEffectiveId(socialNetworkData)

			M.AskInteractTuite(effectiveId, UX.Game.TuiteState.Comment)
		end
	})
end

function M.GetTrendRandomByAreaId(areaId)
	gCommonRequestUtils.Start(RequestMap.TrendRandom, {
		areaId = areaId,
		successCallback = function (info)
			if table.isNilOrEmpty(info) or table.isNilOrEmpty(info.list) then
				M.GetTrendRandom()
			else
				gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_RANDOM, info)
			end
		end
	})
end

function M.GetTrendList(page, pageSize)
	gCommonRequestUtils.Start(RequestMap.TrendList, {
		areaId = 0,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST, info)
		end
	})
end

function M.GetTrendRandom()
	gCommonRequestUtils.Start(RequestMap.TrendRandom, {
		areaId = 0,
		successCallback = function (info)
			info.list = M.ShuffleTable(info.list or {})

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_RANDOM, info)
		end
	})
end

function M.ShuffleTable(t)
	local rtn = {}

	for i = 1, #t do
		local r = math.random(i)

		if r ~= i then
			rtn[i] = rtn[r]
		end

		rtn[r] = t[i]
	end

	return rtn
end

function M.GetPlayerInfo(roleId)
	roleId = roleId or gCommonRequestUtils.GetPlayerRoleId()

	gCommonRequestUtils.Start(RequestMap.UserProfile, {
		viewRoleId = roleId,
		successCallback = function (info)
			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_PLAYER_INFO, info)
		end
	})
end

function M.GetCollectionList(categoryId, page, pageSize, callback)
	gCommonRequestUtils.Start(RequestMap.MomentCollectList, {
		categoryId = categoryId,
		page = page,
		pageSize = pageSize,
		successCallback = function (info)
			info.page = page

			if callback then
				callback(info)
			end

			gMessageManager:SendMessage(gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION_LIST, {
				categoryId = categoryId,
				info = info
			})
		end
	})
end

function M.GetCollectionCategoryIdList()
	local count = LTConfig.TuiteTypeConfig.count
	local categoryIdList = {}

	for i = 0, count - 1 do
		local typeCfg = LTConfig.TuiteTypeConfig.LoadAt(i)

		table.insert(categoryIdList, typeCfg.Id)
	end

	table.sort(categoryIdList)

	return categoryIdList
end

function M.GetRoleName(roleInfo)
	local roleId = roleInfo.roleId
	local isPlayerSelf = M.CheckIsPlayerSelf(roleId)

	if isPlayerSelf then
		return gSocialNetworkUtils.GetPlayerAccountName()
	else
		local tuiteNpcCfg = LTConfig.TuiteNPCConfig.GetConfig(roleInfo.roleId)
		local roleName = tuiteNpcCfg and tuiteNpcCfg.Name or roleInfo.name

		return roleName
	end
end

function M.GetPlayerAccountName()
	if gSocialNetworkUtils.CheckAccountChangeTaskCompleted() then
		return LTConfig.TuiteConfig.PlayerAccountName
	end

	return LTConfig.TuiteConfig.PlayerAccountName_Original
end

function M.CheckAccountChangeTaskCompleted()
	local taskId = LTConfig.TuiteConfig.PlayerAccountChangeTask
	local taskState = gTaskManager:GetTaskState(taskId)

	return taskState == UX.Game.TaskState.Submited
end

function M.SetRoleInfo(roleInfo, dataSet)
	local roleId = roleInfo.roleId
	dataSet.name = M.GetRoleName(roleInfo)
	local isPlayerSelf = M.CheckIsPlayerSelf(roleId)
	dataSet.head.isOnline = true

	if isPlayerSelf then
		gChatManager:SetHeadIcon(dataSet.head, gPlayerManager.infoLogin.bindData.pid)
	else
		local tuiteNpcCfg = LTConfig.TuiteNPCConfig.GetConfig(roleId)
		local avatarId = tuiteNpcCfg and tuiteNpcCfg.Image

		if not avatarId then
			local imageCfg = LTConfig.ImageAvatarConfig.GetConfig(roleInfo.avatarId)
			avatarId = imageCfg and imageCfg.ImageId or roleInfo.avatarId
		end

		gChatManager:SetHeadIcon(dataSet.head, nil, nil, avatarId)
	end
end

function M.GetSCommentAvatarId(data)
	local templateId = data.momentTemplateId
	local roleId = data.roleInfo.roleId
	local isPlayerSelf = M.CheckIsPlayerSelf(roleId)

	if templateId and templateId > 0 and isPlayerSelf then
		return gSocialNetworkUtils.GetPlayerSGuiAvatarId()
	else
		return M.GetSGuiAvatarId(data.roleInfo)
	end
end

function M.GetSGuiAvatarId(roleInfo)
	local roleId = roleInfo.roleId
	local isPlayerSelf = M.CheckIsPlayerSelf(roleId)

	if isPlayerSelf then
		return M.GetPlayerSGuiAvatarId()
	else
		local tuiteNpcCfg = LTConfig.TuiteNPCConfig.GetConfig(roleId)
		local avatarId = tuiteNpcCfg and tuiteNpcCfg.SImage

		if not avatarId then
			local imageCfg = LTConfig.ImageAvatarConfig.GetConfig(roleInfo.avatarId)
			avatarId = imageCfg and imageCfg.SguiImageId
		end

		return avatarId
	end
end

function M.GetPlayerSGuiAvatarId()
	if gSocialNetworkUtils.CheckAccountChangeTaskCompleted() then
		return LTConfig.TuiteConfig.SPlayerAccountImage
	end

	return LTConfig.TuiteConfig.PlayerAccountImage_Original
end

function M.GetCountFormat(count)
	local languageId = gClientUtils.GetCurrentLanguageId()

	if languageId == LTConfig.ShezhiPanelLanguagesConfig.CN then
		count = count or 0

		if count >= 10000 then
			count = count / 10000
			count = gString.Format("%.1f", count)
			count = LTConfig.TextScriptTextConfig.GetConfig(89900990).Text:format(count)
		end

		return count
	else
		return M.NumberToKFormat(count)
	end
end

function M.NumberToKFormat(number)
	if number >= 1000000000 then
		return string.format("%.1fB", number / 1000000000)
	elseif number >= 1000000 then
		return string.format("%.1fM", number / 1000000)
	elseif number >= 1000 then
		return string.format("%.1fK", number / 1000)
	else
		return tostring(number)
	end
end

function M.GetFormatTime(createTime)
	local currentYear = os.date("%Y", gCS.TimeManager.ServerUnixTime)
	createTime = createTime / 1000
	local dataYear = os.date("%Y", createTime)
	local time = os.date(LTConfig.TextScriptTextConfig.GetConfig(89900989).Text, createTime)
	time = currentYear == dataYear and time or ("%d/%s"):format(dataYear, time)

	return time
end

function M.GetSocialNetworkImageList(data)
	local viewImageList = {}

	if gLoginManager:CheckIsTgsPack() then
		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
		local isVideo = tuiteCfg and #tuiteCfg.tgsVideoIdList > 0
		local baseUrl = gCS.LuaUtils.GetTGSFilePickerBaseUrl()
		local currentLangId = gClientUtils.GetCurrentLanguageId()
		local languageCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(currentLangId)
		local abbreviation = languageCfg.Abbreviation

		if isVideo then
			local dataImageList = tuiteCfg and tuiteCfg.tgsImageList or {}

			for index, imageUrl in ipairs(dataImageList) do
				local newUrl = imageUrl:gsub("([^/]+)%.(%w+)$", function (name, ext)
					return name .. "_" .. abbreviation .. "." .. ext
				end)

				table.insert(viewImageList, {
					isVideo = true,
					imageURL = {
						("%s/%s"):format(baseUrl, newUrl)
					},
					videoId = tuiteCfg and tuiteCfg.tgsVideoIdList[index],
					id = index
				})
			end

			return viewImageList, true
		else
			local dataImageList = tuiteCfg and tuiteCfg.tgsImageList or {}
			local hasImageList = #dataImageList > 0

			if hasImageList then
				for index, imageUrl in ipairs(dataImageList) do
					local newUrl = imageUrl:gsub("([^/]+)%.(%w+)$", function (name, ext)
						return name .. "_" .. abbreviation .. "." .. ext
					end)

					table.insert(viewImageList, {
						imageURL = {
							("%s/%s"):format(baseUrl, newUrl)
						},
						id = index,
						selected = index == 1
					})
				end
			end

			return viewImageList, false
		end

		return
	end

	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
	local isVideo = tuiteCfg and #tuiteCfg.VideoIdList > 0
	local currentLangId = gClientUtils.GetCurrentLanguageId()
	local languageCfg = LTConfig.ShezhiPanelLanguagesConfig.GetConfig(currentLangId)
	local abbreviation = languageCfg.Abbreviation
	local imageField = ("ImageList_%s"):format(abbreviation)
	local dataImageList = nil
	dataImageList = tuiteCfg and tuiteCfg[imageField] and #tuiteCfg[imageField] > 0 and tuiteCfg[imageField] or tuiteCfg and tuiteCfg.ImageList or {}

	if isVideo then
		for index, imageUrl in ipairs(dataImageList) do
			table.insert(viewImageList, {
				isVideo = true,
				imageURL = {
					imageUrl
				},
				videoId = tuiteCfg and tuiteCfg.VideoIdList[index],
				id = index
			})
		end

		return viewImageList, true
	else
		local hasImageList = #dataImageList > 0

		if hasImageList then
			for index, imageUrl in ipairs(dataImageList) do
				table.insert(viewImageList, {
					imageURL = {
						imageUrl
					},
					id = index,
					selected = index == 1
				})
			end
		end

		return viewImageList, false
	end
end

function M.GetTuiteConfigId(data)
	return data.templateId and data.templateId > 0 and data.templateId or data.id
end

function M.GetTuiteConfig(data)
	local tuiteId = gSocialNetworkUtils.GetTuiteConfigId(data)

	return tuiteId and LTConfig.TuiteConfig.GetConfig(tuiteId)
end

function M.GetMomentFormatContent(data)
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
	local content = tuiteCfg and tuiteCfg.Txt or data.text
	content = string.gsub(content, "<a socialHot=%d+>(#[^#]+#)</a>", "#c3674E5%1##z")
	local replaceName = nil

	if gSocialNetworkUtils.CheckAccountChangeTaskCompleted() then
		replaceName = LTConfig.TuiteConfig.PlayerAccountName
	else
		replaceName = LTConfig.TuiteConfig.PlayerAccountName_Personal
	end

	return content:gsub("<PlayerAccount>", replaceName)
end

function M.CheckIsPlayerSelf(roleId)
	return roleId == LTConfig.TuiteNPCConfig.Player or tostring(roleId) == ulong.tostring(gPlayerManager.infoLogin.bindData.pid)
end

function M.ShowPopUp(data)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_SHOW_POP_UP_TIPS, data)
end

function M.GetEffectiveId(socialNetworkData)
	local templateId = socialNetworkData.templateId and socialNetworkData.templateId > 0 and socialNetworkData.templateId or nil

	return templateId or socialNetworkData.id
end

function M.AskTwitterPageOpen(pageType, key, value)
	key = key or ""
	value = value or 0

	gClientToGameDelegate:AskTwitterPageOpen(pageType, key, value)
end

function M.AskTwitterPageClose(closePageType)
	gClientToGameDelegate:AskTwitterPageClose(closePageType)
end

function M.RefreshCommonMomentItem(store, data)
	if store.playCollectionAnimationId and store.playCollectionAnimationId ~= data.id then
		store.playCollectionAnimCo = coroutine.stop(store.playCollectionAnimCo)
		store.playCollectionAnimation = false
		store.playCollectionAnimationId = nil
	end

	store.likeButton.isSelected = data.isLike
	store.likeButtonCtrl = data.isLike and 1 or 0
	store.collectButtonCtrl = data.isCollect and 1 or 0
	store.content = M.GetMomentFormatContent(data)
	store.content = M.GetMomentFormatContent(data)
	store.time = M.GetFormatTime(data.publicTime)
	store.hotCount = M.GetCountFormat(data.viewCount)
	store.commentCount = M.GetCountFormat(data.commentCount)
	store.likeCount = M.GetCountFormat(data.likeCount)
	store.isOfficial = data.roleInfo.isCertified == true
	store.officialName = not string.is_null_or_empty(data.roleInfo.account) and ("@%s"):format(data.roleInfo.account) or ""
	local avatarStore = gStoreManager:GetStoreGroup(store.avatar.Store):GetStoreByWidget(store.avatar)
	avatarStore.headIcon = M.GetSGuiAvatarId(data.roleInfo)
	local imageList, isVideo = M.GetSocialNetworkImageList(data)
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
	store.imageSizeControl = tuiteCfg and tuiteCfg.ImageSizeControl or 0
	store.isShowImageList = #imageList > 0
	store.isVideoActive = isVideo
	store.name = M.GetRoleName(data.roleInfo)
	store.hasFollow = not data.roleInfo.isFollow
	store.hasFollowCtrl = data.roleInfo.isFollow and 0 or 1
	local animationName = M.GetLikeAnimationName(data.isLike)

	gClientUtils.FinishAnimation(store.likeAnimation, animationName)

	function store.likeButton.luaClick()
		M.LikeSocialNetwork(data, function (isLike)
			local targetAnimationName = M.GetLikeAnimationName(isLike)

			if gClientUtils.NotNil(store.likeButton) then
				gCS.LuaUtils.PlayAnimationByName(store.likeAnimation, targetAnimationName)
			end
		end)
	end

	local isPlayerSend = tuiteCfg and (tuiteCfg.MenuTuiteType == 1 or tuiteCfg.MenuTuiteType == 2)

	if isPlayerSend and gSocialNetworkUtils.CheckIsNewRelease(data) then
		store.newReleaseControl = 1
	else
		store.newReleaseControl = 0
	end

	store.followButton:SetActive(not isPlayerSend)

	function store.followButton.luaClick()
		M.FollowRole(data)
	end

	store.gamepadFollowButton.luaClick = store.followButton.luaClick

	if store.collectButton then
		store.collectButton.isSelected = data.isCollect

		local function executeCollectionFunc()
			M.CollectionSocialNetwork(data, function (isCollect)
				if isCollect and not store.playCollectionAnimationId then
					store.playCollectionAnimation = true
					local animationName = "S_Vx_YanjieDetailTemplate_CollectEffect_open"
					store.playCollectionAnimationId = data.id
					local time = gCS.LuaUtils.PlayAnimationByName(store.collectAnimation, animationName)
					store.playCollectionAnimCo = coroutine.stop(store.playCollectionAnimCo)
					store.playCollectionAnimCo = coroutine.start(function ()
						coroutine.wait(time)

						store.playCollectionAnimationId = nil
						store.playCollectionAnimCo = nil
						store.playCollectionAnimation = false
					end)
				end
			end)
		end

		function store.collectButton.luaClick()
			executeCollectionFunc()
		end
	end

	store.guideId = M.GetMomentGuideId(data)

	if store.taskCollectionButton then
		local taskId = gSocialNetworkUtils.GetTuiteTaskId(data)
		store.taskIconId = gSocialNetworkUtils.GetTaskEventIconId(data)
		store.taskStateControl = M.GetTuiteTaskControlValue(taskId)

		function store.taskCollectionButton.luaClick()
			if store.taskStateControl == 0 then
				gSocialNetworkUtils.jumpMapTaskId = taskId

				gMapUtils:CheckRaidCanOpenMap({
					AutoSelectTaskId = taskId
				})
			end
		end
	end
end

function M.CheckIsNewRelease(data)
	local diffTime = gLuaDataManager.serverTime - data.publicTime / 1000

	return diffTime < LTConfig.TuiteConfig.NewReleaseLimitTime * gClientConst.SECONDS_PER_MINUTE
end

function M.GetTuiteTaskControlValue(taskId)
	local taskState = gTaskManager:GetTaskState(taskId)

	if taskState == UX.Game.TaskState.Accepted then
		return 1
	end

	if taskState == UX.Game.TaskState.NotAccept or taskState == UX.Game.TaskState.Aborted then
		return gMapSubSystem_Task:IsTracingTask(taskId) and 1 or 0
	elseif taskState == UX.Game.TaskState.Submited then
		return 2
	end
end

function M.GetTaskEventIconId(data)
	local taskId = gSocialNetworkUtils.GetTuiteTaskId(data)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)
	local titleId = taskCfg and taskCfg.Title
	local taskTitleCfg = LTConfig.TaskTitleConfig.GetConfig(titleId)

	return taskTitleCfg and taskTitleCfg.SQuestIcon or 0
end

function M.GetTuiteTaskId(data)
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
	local eventId = tuiteCfg.TaskEvent
	local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(eventId)

	return taskEventCfg and taskEventCfg.StartTask
end

function M.GetMomentGuideId(data)
	local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)

	return tuiteCfg and tuiteCfg.GuideId or ""
end

function M.GetLikeAnimationName(isLike)
	return isLike and "S_Vx_Yanjie_LikePress" or "S_Vx_Yanjie_disLikePress"
end

function M.RefreshMomentItem(widget, data, ignoreLoadImage)
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	M.RefreshCommonMomentItem(store, data)

	if store.isShowImageList then
		local isTaskTemplate = data.templateId and data.templateId > 0
		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
		isTaskTemplate = isTaskTemplate and tuiteCfg and tuiteCfg.TaskEvent and tuiteCfg.TaskEvent > 0
		store.imageType = gClientConst.YanJieImageType.Normal

		if not ignoreLoadImage then
			local imageList = M.GetSocialNetworkImageList(data)
			local imageUrl = unpack(imageList[1].imageURL)
			local rect = store.imageRectTransform.rect
			local size = {
				x = rect.width,
				y = rect.height
			}
			local url = gClientUtils.GetFilePickerImageUrl(imageUrl, size, false)
			store.imageUrl = url
		end
	end

	function store.button.luaClick()
		if data.itemClickCallback then
			data.itemClickCallback()
		end

		local yanJieAppHomePanel = gStoreManager:GetStoreGroup("YanjieAppHomePanel")
		local showType = yanJieAppHomePanel:GetCurrentShowType()
		local disableDetailOffsetAnim = showType == gClientConst.YanJieShowType.Search

		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
			secondShowType = gClientConst.YanJieShowType.Detail,
			id = data.id,
			data = data,
			disableDetailOffsetAnim = disableDetailOffsetAnim
		})
	end

	function store.commentButton.luaClick()
		gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
			showComment = true,
			secondShowType = gClientConst.YanJieShowType.Detail,
			id = data.id
		})
	end
end

function M.SyncTwitterMonitoredBehaviors(behaviorList)
	gPlayerManager.infoMinor.bindData.socialNetworkMonitoredBehaviorList = behaviorList
end

function M.AskTwitterBehaviorFinish(id, behavior)
	local socialNetworkMonitoredBehaviorList = gPlayerManager.infoMinor.bindData.socialNetworkMonitoredBehaviorList

	if socialNetworkMonitoredBehaviorList then
		for _, serverBehaviorInfo in ipairs(socialNetworkMonitoredBehaviorList) do
			if serverBehaviorInfo.Id == id and serverBehaviorInfo.Behavior == behavior then
				if not serverBehaviorInfo.hasRequest then
					serverBehaviorInfo.hasRequest = true

					gClientToGameDelegate:AskTwitterBehaviorFinish(behavior, id).Callback = function (errId)
						if errId ~= LTConfig.MessageConfig.Ok then
							serverBehaviorInfo.hasRequest = false
						end
					end
				end

				return
			end
		end

		gClientToGameDelegate:AskTwitterBehaviorFinish(behavior, id).Callback = function (errId)
			if errId == LTConfig.MessageConfig.Ok then
				table.insert(socialNetworkMonitoredBehaviorList, {
					hasRequest = true,
					Id = id,
					Behavior = behavior
				})
			end
		end
	end
end

function M.DynamicLoadList(list, onScrollCb, onScrollEndCb)
	local function OnScroll(normalizedPosition)
		local isControllerMode = gClientUtils.IsControllerMode()
		local normalizedY = normalizedPosition.y
		local isPullUpToRefresh = nil

		if isControllerMode then
			isPullUpToRefresh = normalizedY <= gClientConst.PULL_UP_REFRESH_DISTANCE_GAMEPAD
		else
			isPullUpToRefresh = normalizedY <= gClientConst.PULL_UP_REFRESH_DISTANCE
		end

		onScrollCb(isPullUpToRefresh)

		if isControllerMode then
			onScrollEndCb()
		end
	end

	list:RegisterToScrollEvent(OnScroll)
	list:RegisterToScrollEndEvent(onScrollEndCb)
end

function M.GetHistoryXAxisList()
	local _, xAxisList = M.GetHistoryXAxisMax()

	return xAxisList
end

function M.MapXChartAxisValue(x, oriBegin, oriEnd, targetBegin, targetEnd)
	return targetBegin + (x - oriBegin) * (targetEnd - targetBegin) / (oriEnd - oriBegin)
end

function M.GetMapHistoryLineRendererPositionArray(width, height)
	local yList = LTConfig.TuiteConfig.PopularityChartY
	local historyDataArray = M.GetPopularHistoryDataArray()
	local yAxisCount = #yList
	local pCellX = width / 1
	local pCellY = height / (yAxisCount - 1)
	local historyXAxisMax = M.GetHistoryXAxisMax()
	local targetDataArray = {}
	local targetIndex = 1

	for _, data in pairs(historyDataArray) do
		local targetBeginX = 0
		local targetEndX = pCellX
		local originalBeginX = 0
		local originalEndX = historyXAxisMax
		data.x = M.MapXChartAxisValue(data.x, originalBeginX, originalEndX, targetBeginX, targetEndX)

		for i = 1, yAxisCount - 1 do
			if yList[i] <= data.y and data.y <= yList[i + 1] then
				local targetBegin = pCellY * (i - 1)
				local targetEnd = pCellY * i
				local originalBegin = yList[i]
				local originalEnd = yList[i + 1]
				data.y = M.MapXChartAxisValue(data.y, originalBegin, originalEnd, targetBegin, targetEnd)

				break
			end
		end

		if data.x >= 0 and data.x <= width then
			targetDataArray[targetIndex] = data
			targetIndex = targetIndex + 1
		end
	end

	return targetDataArray
end

function M.GetPopularHistoryDataArray()
	local currentServerTime = gCS.TimeManager.ServerUnixTime
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local historyPopularityList = popularityInfo.HistoryPopularityList
	local targetDataMap = {}
	local xAxisMax, _ = M.GetHistoryXAxisMax()
	local targetDataIndex = 1
	historyPopularityList = M.FilterHistoryPoint(historyPopularityList)
	historyPopularityList.Count = #historyPopularityList

	table.insert(historyPopularityList, {
		Time = currentServerTime,
		Value = M.GetCurrentPopularityValue()
	})

	local calHistoryPopularityList = M.CalcPlayerPopularityGeneratePoints(historyPopularityList, currentServerTime, xAxisMax)

	table.remove(historyPopularityList, #historyPopularityList)

	local minTime = historyPopularityList[1].Time
	local maxTime = historyPopularityList[#historyPopularityList].Time
	local postHistoryPopularityList = {}

	for _, calPopularityInfo in ipairs(calHistoryPopularityList) do
		if minTime <= calPopularityInfo.Time and calPopularityInfo.Time <= maxTime then
			table.insert(postHistoryPopularityList, calPopularityInfo)
		end
	end

	local count = #postHistoryPopularityList

	if xAxisMax <= 4 then
		local firstHistoryPopularity = postHistoryPopularityList[1]

		if firstHistoryPopularity then
			local startXMax = (currentServerTime - firstHistoryPopularity.Time) / gClientConst.SECONDS_PER_HOUR

			for i = count, 1, -1 do
				local historyPopularityData = postHistoryPopularityList[i]
				local axisTime = startXMax - (currentServerTime - historyPopularityData.Time) / gClientConst.SECONDS_PER_HOUR

				if axisTime >= 0 then
					targetDataMap[targetDataIndex] = Vector3.New(axisTime, historyPopularityData.Value, 0)
					targetDataIndex = targetDataIndex + 1
				end
			end
		end
	else
		for i = count, 1, -1 do
			local historyPopularityData = postHistoryPopularityList[i]
			local axisTime = xAxisMax - (currentServerTime - historyPopularityData.Time) / gClientConst.SECONDS_PER_HOUR

			if axisTime >= 0 then
				targetDataMap[targetDataIndex] = Vector3.New(axisTime, historyPopularityData.Value, 0)
				targetDataIndex = targetDataIndex + 1
			end
		end
	end

	table.sort(targetDataMap, function (vector1, vector2)
		return vector1.x < vector2.x
	end)

	return targetDataMap
end

function M.FilterHistoryPoint(historyPopularityList)
	if historyPopularityList then
		local timeMap = {}

		for _, point in ipairs(historyPopularityList) do
			local time = point.Time
			local value = point.Value

			if not timeMap[time] or timeMap[time].Value < value then
				timeMap[time] = {
					Time = time,
					Value = value
				}
			end
		end

		local result = {}

		for _, point in pairs(timeMap) do
			table.insert(result, point)
		end

		table.sort(result, function (a, b)
			return a.Time < b.Time
		end)

		return result
	else
		return historyPopularityList
	end
end

function M.CalcPlayerPopularityGeneratePoints(inputPointList, currentServerTime, xAxisMax)
	local outPoints = {}

	if #inputPointList == 0 then
		return outPoints
	end

	local totalHours = xAxisMax
	local intervalMinutes = LTConfig.TuiteConfig.PopularityIntervalMinutes
	local PointNum = totalHours * 60 / intervalMinutes
	local smoothingFactor = LTConfig.TuiteConfig.PopularitySmoothingFactor

	for j = 0, PointNum - 1 do
		table.insert(outPoints, {
			Value = 0,
			Time = currentServerTime - intervalMinutes * 60 * (PointNum - j)
		})
	end

	local lastInputValue = inputPointList[#inputPointList].Value

	for i = 1, #outPoints do
		local outTime = outPoints[i].Time

		if i == #outPoints then
			outPoints[i].Value = lastInputValue
		else
			local p0, p1 = nil

			for j = 1, #inputPointList do
				if outTime <= inputPointList[j].Time then
					p1 = inputPointList[j]
					p0 = j > 1 and inputPointList[j - 1] or p1

					break
				end
			end

			if not p1 then
				p1 = inputPointList[#inputPointList]
				p0 = #inputPointList > 1 and inputPointList[#inputPointList - 1] or p1
			end

			if p0.Time == p1.Time then
				outPoints[i].Value = p1.Value
			else
				local t = (outTime - p0.Time) / (p1.Time - p0.Time)
				t = math.max(0, math.min(1, t))
				local m0 = 0
				local m1 = 0

				if #inputPointList >= 2 then
					local alpha = 0
					local beta = 0

					if i > 1 then
						alpha = (p1.Value - p0.Value) / (p1.Time - p0.Time)
					end

					if i < #inputPointList then
						beta = (inputPointList[i + 1].Value - p1.Value) / (inputPointList[i + 1].Time - p1.Time)
					end

					if alpha * beta <= 0 then
						m0 = 0
						m1 = 0
					else
						m0 = 3 * (alpha + beta) / ((2 * alpha + beta) / alpha + (alpha + 2 * beta) / beta)
						m1 = m0
					end
				end

				local h00 = 2 * t^3 - 3 * t^2 + 1
				local h10 = t^3 - 2 * t^2 + t
				local h01 = -2 * t^3 + 3 * t^2
				local h11 = t^3 - t^2
				local calValue = math.max(0, h00 * p0.Value + h10 * (p1.Time - p0.Time) * m0 + h01 * p1.Value + h11 * (p1.Time - p0.Time) * m1)
				outPoints[i].Value = UnityEngine.Mathf.IsNan(calValue) and 0 or calValue
			end
		end
	end

	local smoothedPoints = {}
	local prevSmoothed = outPoints[1].Value

	for i = 1, #outPoints do
		if i == #outPoints then
			prevSmoothed = lastInputValue
		else
			prevSmoothed = smoothingFactor * outPoints[i].Value + (1 - smoothingFactor) * prevSmoothed
		end

		table.insert(smoothedPoints, {
			Time = outPoints[i].Time,
			Value = math.max(0, prevSmoothed)
		})
	end

	prevSmoothed = smoothedPoints[#smoothedPoints].Value

	for i = #smoothedPoints - 1, 1, -1 do
		prevSmoothed = smoothingFactor * smoothedPoints[i].Value + (1 - smoothingFactor) * prevSmoothed
		smoothedPoints[i].Value = math.max(0, prevSmoothed)
	end

	return smoothedPoints
end

function M.GetHistoryXAxisMax()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local historyPopularityList = popularityInfo.HistoryPopularityList
	local colCount = 4
	local rowCount = 6
	local popularityHistoryTimeList = {}

	for i = 1, rowCount do
		local rowDataList = {}

		for j = colCount, 1, -1 do
			table.insert(rowDataList, i * j)
		end

		table.insert(popularityHistoryTimeList, rowDataList)
	end

	if #historyPopularityList > 0 then
		local diffTimeSecond = gCS.TimeManager.ServerUnixTime - historyPopularityList[1].Time
		local diffTimeHour = diffTimeSecond / gClientConst.SECONDS_PER_HOUR

		if diffTimeHour >= rowCount * colCount then
			return rowCount * colCount, popularityHistoryTimeList[rowCount]
		else
			for i = 1, #popularityHistoryTimeList do
				local rowDataList = popularityHistoryTimeList[i]

				if diffTimeHour <= rowDataList[1] then
					return rowDataList[1], rowDataList
				end
			end
		end
	end

	local rowDataList = popularityHistoryTimeList[1]

	return rowDataList[1], rowDataList
end

function M.RefreshPopularityView(widget)
	if gClientUtils.IsNil(widget) then
		return
	end

	local storeName = widget.Store
	local store = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(widget)

	M.RefreshPopularityAxisView(store)

	local historyXAxisWidth = store.historyLineNode.rect.width
	local historyYAxisHeight = store.historyLineNode.rect.height
	local splitYAxisHeight = store.splitLineNode.sizeDelta.y
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo
	local historyPopularityList = popularityInfo.HistoryPopularityList
	local count = 0

	for _, _ in ipairs(historyPopularityList) do
		count = count + 1

		if count > 2 then
			break
		end
	end

	local historyPositionArray = nil

	if not store.uSplineLineRender then
		return
	end

	if count > 2 then
		store.smoothCurveClipper.gameObject:SetActive(false)

		historyPositionArray = M.GetMapHistoryLineRendererPositionArray(historyXAxisWidth, historyYAxisHeight)

		store.uSplineLineRender:SetPositions(historyPositionArray)
		store.smoothCurveClipper:SetCurvePoint(historyPositionArray)

		local spiltLineHeight = M.GetSplitLineHeight(splitYAxisHeight)
		store.dotNode.localPosition = Vector3.Fetch(0, spiltLineHeight)
	else
		store.uSplineLineRender:SetPositions({
			Vector3.zero
		})
		store.smoothCurveClipper.gameObject:SetActive(false)

		store.dotNode.localPosition = Vector3.zero
	end

	return historyPositionArray
end

function M.RefreshPopularityAxisView(store)
	if gClientUtils.IsNil(store.axisXList) then
		return
	end

	local yList = LTConfig.TuiteConfig.PopularityChartY
	local yAxisViewDataList = {}

	for i = #yList, 1, -1 do
		table.insert(yAxisViewDataList, {
			axisValue = yList[i]
		})
	end

	local xList = M.GetHistoryXAxisList()
	local xAxisViewDataList = {}

	if xList[1] <= 4 then
		table.insert(xAxisViewDataList, {
			axisValue = 0,
			tIndex = 0
		})

		for i = #xList, 1, -1 do
			table.insert(xAxisViewDataList, {
				tIndex = 0,
				axisValue = xList[i]
			})
		end
	else
		store.nowNode.gameObject:SetActive(false)

		for _, xAxisValue in ipairs(xList) do
			table.insert(xAxisViewDataList, {
				tIndex = 0,
				axisValue = xAxisValue
			})
		end

		table.insert(xAxisViewDataList, {
			tIndex = 1
		})
	end

	function store.axisXList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = xAxisViewDataList[luaIndex]

		return data.tIndex
	end

	function store.axisXList.luaSimpleRenderItem(btn, csIndex)
		local luaIndex = csIndex + 1
		local data = xAxisViewDataList[luaIndex]

		if data.tIndex == 0 then
			local storeName = btn.Store
			local axisStore = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
			axisStore.axisValue = data.axisValue
		end
	end

	function store.axisYList.luaSimpleRenderItem(btn, csIndex)
		local luaIndex = csIndex + 1
		local storeName = btn.Store
		local data = yAxisViewDataList[luaIndex]
		local axisStore = gStoreManager:GetStoreGroup(storeName):GetStoreByWidget(btn)
		axisStore.axisValue = data.axisValue
	end

	store.axisXList:SetSimpleList(#xAxisViewDataList)
	store.axisYList:SetSimpleList(#yAxisViewDataList)
end

function M.GetSplitLineHeight(height)
	local currentPopularityValue = M.GetCurrentPopularityValue()
	local yList = LTConfig.TuiteConfig.PopularityChartY
	local yAxisCount = #yList
	local pCellY = height / (yAxisCount - 1)

	for i = 1, yAxisCount - 1 do
		if yList[i] <= currentPopularityValue and currentPopularityValue <= yList[i + 1] then
			local targetBegin = pCellY * (i - 1)
			local targetEnd = pCellY * i
			local originalBegin = yList[i]
			local originalEnd = yList[i + 1]
			currentPopularityValue = M.MapXChartAxisValue(currentPopularityValue, originalBegin, originalEnd, targetBegin, targetEnd)

			break
		end
	end

	return currentPopularityValue
end

function M.GetCurrentPopularityValue()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	return popularityInfo and math.floor(popularityInfo.Popularity) or 0
end

function M.RefreshPlayerExpProgressView(widget, targetLevel, targetExp)
	targetLevel = targetLevel or gPlayerManager.infoMinor.bindData.level
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)
	targetExp = targetExp or gPlayerManager.infoMinor.bindData.fan123
	local nextLevel = targetLevel + 1
	nextLevel = math.min(LTConfig.GameConfig.PlayerMaxLevel, nextLevel)
	local nextLevelExp = gClientUtils.GetTargetLevelExp(nextLevel)
	local formatTargetExp = gClientUtils.FormatWithThousandsSeparator(targetExp)
	local formatNextLevelExp = gClientUtils.FormatWithThousandsSeparator(nextLevelExp)
	store.progressText = ("%s/%s"):format(formatTargetExp, formatNextLevelExp)
	local progressValue = 0
	progressValue = targetExp / nextLevelExp
	store.progress.value = progressValue
end

function M.GetTotalLeftMoney()
	local popularityInfo = gPlayerManager.infoMinor.bindData.popularityInfo

	return popularityInfo.TotalLeftMoney
end

function M.CheckIsTuiteEvent(eventId)
	return gSocialNetworkUtils.GetTuiteIdByEventId(eventId) ~= nil
end

function M.GetTuiteIdByEventId(eventId)
	local count = LTConfig.TuiteConfig.count

	for i = 0, count - 1 do
		local tuiteCfg = LTConfig.TuiteConfig.LoadAt(i)

		if tuiteCfg.TaskEvent == eventId then
			return tuiteCfg.Id
		end
	end
end

function M.OpenTuiteDetail(eventId)
	local tuiteId = gSocialNetworkUtils.GetTuiteIdByEventId(eventId)

	gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
		secondShowType = gClientConst.YanJieShowType.Detail,
		id = tuiteId
	})
end

function M:FansChangeRecord(preFan)
	if self.recordPreFan then
		return
	end

	self.recordPreFan = preFan
	self.recordFansChangeCo = coroutine.start(function ()
		coroutine.wait(LTConfig.TuiteConfig.FansChangeValidTime * gClientConst.SECONDS_PER_MINUTE)

		self.recordPreFan = nil
	end)
end

function M:ClearFansChangeRecord()
	self.recordFansChangeCo = coroutine.stop(self.recordFansChangeCo)
	self.recordPreFan = nil
end

function M:OnBeforeSwitchScene(switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		self:ClearFansChangeRecord()

		if self.asyncList then
			self.asyncList:Stop()
		end

		self.sendTuiteCo = coroutine.stop(self.sendTuiteCo)
	end
end

function M:SyncPlayerTwitterButton(tuiteId, isOpen, secondShowType, showInteractionButton)
	if showInteractionButton then
		local pid = gCS.MyPlayerManager.PlayerUnit.Pid
		local info = LX6.Interact.UnitBtnInfo.New(1, pid, 0, function ()
			L50.L50App.L50Game.InteractBtnMgr:RemoveBtnByType(pid, LX6.Interact.BtnTargetType.Unit)

			if gCS.MyPlayerManager.PlayerUnit then
				if self.asyncList then
					self.asyncList:Stop()
				end

				self.asyncList = gAsyncActionList.new()

				self.asyncList:Add(function (onFinish)
					gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8008)
					LX6.GUI.HUDNew.HUDManager.AddHUDTemplateSync(LX6.GUI.HUDNew.HUDTemplateType.TopText, gCS.MyPlayerManager.PlayerUnit.Pid)
					gHudMgr:SetTopText(pid, LTConfig.TuiteConfig.PostUpdateGoing)

					self.sendTuiteCo = coroutine.start(function ()
						coroutine.wait(2)
						onFinish()
					end)
				end)
				self.asyncList:Add(function (onFinish)
					gClientToGameSceneDelegate:AskClickPlayerTwitterButton(tuiteId).Callback = function (errorId)
						gHudMgr:RemoveTopText(pid)

						if gCS.MyPlayerManager.PlayerUnit then
							gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, 8009)
						end

						if errorId ~= LTConfig.MessageConfig.Ok then
							gDisplayMessageMgr:DisplayServerMessageId(errorId)
							onFinish()

							return
						end

						LX6.GUI.HUDNew.HUDManager.AddHUDTemplateSync(LX6.GUI.HUDNew.HUDTemplateType.TopText, pid)
						gHudMgr:SetTopText(pid, LTConfig.TuiteConfig.PostUpdateCompleted)

						self.sendTuiteCo = coroutine.start(function ()
							coroutine.wait(2)
							gHudMgr:RemoveTopText(pid)

							if isOpen then
								gPanelManager:CheckShow(gPanelId.YANJIE_APP_HOME_PANEL, {
									id = tuiteId,
									secondShowType = secondShowType
								})
							end

							onFinish()
						end)
					end
				end)
				self.asyncList:Start()
			end
		end, nil, 89901335)

		L50.L50App.L50Game.InteractBtnMgr:AddBtn(info)

		return
	end

	if gCS.MyPlayerManager.PlayerUnit then
		local pid = gCS.MyPlayerManager.PlayerUnit.Pid

		L50.L50App.L50Game.InteractBtnMgr:RemoveBtnByType(pid, LX6.Interact.BtnTargetType.Unit)
	end
end

gSocialNetworkUtils = M
