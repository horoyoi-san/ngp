local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local SocialMediaConfig = LTConfig.SocialMediaConfig
local SocialMediaTabConfig = LTConfig.SocialMediaTabConfig
local MessageConfig = LTConfig.MessageConfig
local SocialMediaNPCConfig = LTConfig.SocialMediaNPCConfig
local SocialMediaCommentConfig = LTConfig.SocialMediaCommentConfig
local SystemUnlockConfig = LTConfig.SystemUnlockConfig
local MomentsNotifyType = UX.Game.MomentsNotifyType
local PopupConfig = LTConfig.PopupConfig
local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local AgentSpecificTypeConfig = LTConfig.AgentAgentSpecificTypeConfig
local StaticProps = {}
C_NewBubbleMgr = DefClass("C_NewBubbleMgr", C_NewBubbleMgr, nil, StaticProps)
local M = C_NewBubbleMgr

function M:Log(...)
	print_debug("[C_NewBubbleMgr]", ...)
end

function M:ctor()
	self.blockDict = {}
	local blockList = SocialMediaConfig.NotBestieID

	for i = 1, #blockList do
		self.blockDict[blockList[i]] = true
	end

	self.SocialId2AgentType = {}
	self.AgentType2SocialId = {}

	for i = 0, SocialMediaNPCConfig.count - 1 do
		local cfg = SocialMediaNPCConfig.LoadAt(i)
		local npcCfg = NpcCultivationConfig.GetConfig(cfg.NpcCultivation)

		if npcCfg then
			self.SocialId2AgentType[cfg.Id] = npcCfg.AgentTag
			self.AgentType2SocialId[npcCfg.AgentTag] = cfg.Id

			for j = 1, #cfg.SamePublishers do
				self.SocialId2AgentType[cfg.SamePublishers[j]] = npcCfg.AgentTag
			end
		end
	end

	self:InitData()

	self.BOOL2CTL = gClientConst.BOOL2CTL
	self.FavorLevel = {
		Mid = 1,
		Low = 2,
		Import = 0
	}
end

function M:InitData()
	self.postList = {}
	self.postDict = {}
	self.lastPostId = 0
	self.cacheLikeDict = {}
	self.cachePostNotice = {}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwitchScene))

	self.baseStore = gStoreManager:GetStoreGroup("BubbleBasePanelStore")
end

function M:OnBeforeSwitchScene(_, switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:InitData()
end

function M:OnAfterSwitchScene(_, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:AskPostList(UX.Game.GetPostType.All)
end

function M:OnSyncNewNotify(info)
	local cfg = SocialMediaConfig.GetConfig(info.CfgId)

	if not cfg then
		return
	end

	if cfg.IfShowTips == true and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BubbleUnlock) then
		self.cachePostNotice[#self.cachePostNotice + 1] = info

		if not self.timer then
			self.timer = Timer.New(function ()
				local withMeCount = 0

				for i = 1, #self.cachePostNotice do
					local id = self.cachePostNotice[i].CfgId
					local cfg = SocialMediaConfig.GetConfig(id)

					if cfg.WithMe then
						withMeCount = withMeCount + 1
					end
				end

				if #self.cachePostNotice > 1 then
					gNewPopupManager:PushPopup(PopupConfig.BubbleNewMessage, {
						info = {
							Type = MomentsNotifyType.Daily,
							PostCount = #self.cachePostNotice,
							NpcIds = {}
						},
						withMeCount = withMeCount
					})
				elseif #self.cachePostNotice == 1 then
					for i = 1, #self.cachePostNotice[1].NpcIds do
						self.cachePostNotice[1].NpcIds[i] = self.SocialId2AgentType[self.cachePostNotice[1].NpcIds[i]]
					end

					gNewPopupManager:PushPopup(PopupConfig.BubbleNewMessage, {
						info = self.cachePostNotice[1],
						withMeCount = withMeCount
					})
				end

				self.cachePostNotice = {}
				self.timer = nil
			end, PopupConfig.PopUpCombineDuration):Start()
		end
	end

	self:AskPostList(UX.Game.GetPostType.All)
end

function M:GetRoleImportFavorList(blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos

	for i = 1, #list do
		local favor = list[i].Favor
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favor == 0 and LastInteractTime == 0 and not blockDict[npcId] and spiritDict[npcId] then
			local cfg = NpcCultivationConfig.GetConfig(npcId)
			local ele = {
				favor = list[i].Favor,
				npcId = cfg.AgentTag,
				activateTime = list[i].ActivateTimestamp
			}

			table.insert(ret, ele)
		end
	end

	table.sort(ret, function (a, b)
		if a.activateTime == b.activateTime then
			return a.npcId < b.npcId
		end

		return b.activateTime < a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

function M:GetRoleMidFavorList(blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local maxFavor = gNpcFavorManager:GetMaxFavoriteLevel()
	local serverTime = gCS.TimeManager.ServerUnixTime
	local dayConstant = 172800

	for i = 1, #list do
		local favorLevel = gNpcFavorManager:GetLevelFromFavor(list[i].Favor)
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favorLevel ~= maxFavor and dayConstant > serverTime - LastInteractTime and not blockDict[npcId] and spiritDict[npcId] then
			local cfg = NpcCultivationConfig.GetConfig(npcId)
			local ele = {
				favor = list[i].Favor,
				npcId = cfg.AgentTag,
				activateTime = list[i].ActivateTimestamp
			}

			table.insert(ret, ele)
		end
	end

	table.sort(ret, function (a, b)
		if a.activateTime == b.activateTime then
			return a.npcId < b.npcId
		end

		return b.activateTime < a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

function M:GetRoleLowFavorList(blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local serverTime = gCS.TimeManager.ServerUnixTime
	local dayConstant = 432000

	for i = 1, #list do
		local favorLevel = gNpcFavorManager:GetLevelFromFavor(list[i].Favor)
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favorLevel ~= 0 and dayConstant < serverTime - LastInteractTime and not blockDict[npcId] and spiritDict[npcId] then
			local cfg = NpcCultivationConfig.GetConfig(npcId)
			local ele = {
				favor = list[i].Favor,
				npcId = cfg.AgentTag,
				activateTime = list[i].ActivateTimestamp
			}

			table.insert(ret, ele)
		end
	end

	table.sort(ret, function (a, b)
		if a.activateTime == b.activateTime then
			return a.npcId < b.npcId
		end

		return b.activateTime < a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

function M:GetRoleAllFavorList(blockDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos

	for i = 1, #list do
		local info = list[i]
		local npcId = info.TemplateId

		if not blockDict[npcId] and gNpcFavorManager:CheckIsUnlock(npcId) then
			local ele = {
				favor = info.Favor,
				npcId = info.TemplateId,
				activateTime = info.LastInteractTime
			}

			table.insert(ret, ele)
		end
	end

	list = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos

	for i = 1, #list do
		local info = list[i]
		local npcId = info.TemplateId

		if not blockDict[npcId] and gNpcFavorManager:CheckIsUnlock(npcId) then
			local ele = {
				favor = info.Favor,
				npcId = info.TemplateId,
				activateTime = info.LastInteractTime
			}

			table.insert(ret, ele)
		end
	end

	table.sort(ret, function (a, b)
		local isBusyA = gNpcDaliyManager:CheckNpcInBusy(a.npcId)
		local isBusyB = gNpcDaliyManager:CheckNpcInBusy(b.npcId)

		if isBusyA ~= isBusyB then
			return not isBusyA
		end

		if a.activateTime ~= b.activateTime then
			return b.activateTime < a.activateTime
		end

		if a.favor ~= b.favor then
			return b.favor < a.favor
		end

		return b.npcId < a.npcId
	end)

	return ret
end

function M:GetRoleFavorList()
	local blockDict = self.blockDict
	local spiritDict = gNpcDaliyManager:GetAllHaveSpiritIds()
	local ret = self:GetRoleImportFavorList(blockDict, spiritDict)
	local level = self.FavorLevel.Import

	if table.isNilOrEmpty(ret) then
		ret = self:GetRoleMidFavorList(blockDict, spiritDict)
		level = self.FavorLevel.Mid
	end

	if table.isNilOrEmpty(ret) then
		ret = self:GetRoleLowFavorList(blockDict, spiritDict)
		level = self.FavorLevel.Low
	end

	if table.isNilOrEmpty(ret) then
		return ret, level
	end

	for i = 1, SocialMediaConfig.FavorRankShowRule do
		if not ret[i] then
			ret[i] = {
				npcId = 0
			}
		end
	end

	return ret, level
end

function M:GetCurrentFavorNpcList()
	local blockDict = self.blockDict
	local ret = self:GetRoleAllFavorList(blockDict)

	return ret
end

function M:GetBubbleNpcInfo(agentType)
	local socialId = self.AgentType2SocialId[agentType]
	local ele = {
		name = "",
		icon = 0
	}

	if not socialId then
		return ele
	end

	local cfg = SocialMediaNPCConfig.GetConfig(socialId)

	if not cfg then
		return ele
	end

	ele.icon = cfg.Simage
	ele.name = cfg.Name

	return ele
end

local POST_TYPE = {
	SHARE = 3,
	POST = 1,
	STORY = 2
}

function M:CheckHasNewStory(npcId)
	if table.isNilOrEmpty(self.postList[npcId]) then
		return 0
	end

	local targetList = array.concat_new(self.postList[npcId][POST_TYPE.STORY] or {}, self.postList[npcId][POST_TYPE.SHARE] or {})

	for i = 1, #targetList do
		local info = self.postDict[targetList[i]]

		if not info.IsRead then
			return info.Id
		end
	end

	return 0
end

function M:CheckIsVideo(postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local isVideo = cfg and not string.is_null_or_empty(cfg.Video) or false

	return isVideo, isVideo and cfg.Video or info.ImageUrl or cfg.Image[1]
end

function M:GetPostPublisher(postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local publisher = cfg and cfg.Publisher or 0

	if publisher ~= 0 then
		publisher = self.SocialId2AgentType[publisher] or 0
	end

	if info.ActivityCfgId and info.ActivityCfgId ~= 0 then
		publisher = info.ActivityCfgId
	end

	return publisher
end

function M:CheckIsStory(postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)

	return cfg and (cfg.IfPinStory or cfg.IfStory) or info.IsPinStory or info.IsStory
end

function M:BuildPostList()
	self.postList = {}

	for k, v in pairs(self.postDict) do
		local publisher = self:GetPostPublisher(k)
		self.postList[publisher] = self.postList[publisher] or {}
		local cfg = SocialMediaConfig.GetConfig(v.PostConfigId)
		local info = v

		if cfg then
			gRedPointMgr:RegisterRedDot(self:HasRedDot(info.Id), self:GetRedDot(info.Id))
		end

		if cfg and cfg.IfPinStory or info.IsPinStory then
			self.postList[publisher][POST_TYPE.SHARE] = self.postList[publisher][POST_TYPE.SHARE] or {}

			table.insert(self.postList[publisher][POST_TYPE.SHARE], info.Id)
		elseif cfg and cfg.IfStory or info.IsStory then
			self.postList[publisher][POST_TYPE.STORY] = self.postList[publisher][POST_TYPE.STORY] or {}

			table.insert(self.postList[publisher][POST_TYPE.STORY], info.Id)
		else
			self.postList[publisher][POST_TYPE.POST] = self.postList[publisher][POST_TYPE.POST] or {}

			table.insert(self.postList[publisher][POST_TYPE.POST], info.Id)
		end
	end
end

function M:GetAllPostList(isMe)
	local ret = {}

	for k, v in pairs(self.postList) do
		if isMe and k == 0 or not isMe and k ~= 0 and not table.isNilOrEmpty(v[POST_TYPE.POST]) then
			array.concat(ret, v[POST_TYPE.POST])
		end
	end

	table.sort(ret, function (a, b)
		local redA = self:HasRedDot(a)
		local redB = self:HasRedDot(b)

		if redA ~= redB then
			return redA
		end

		return b < a
	end)

	return ret
end

function M:GetAllShareList(agentType)
	return self.postList[agentType] and self.postList[agentType][POST_TYPE.SHARE] or {}
end

function M:GetPostLikeAndLikes(postId)
	local info = self.postDict[postId]
	local isLike = info.Liked or false

	if self.cacheLikeDict[postId] ~= nil then
		isLike = self.cacheLikeDict[postId]
	end

	return isLike, isLike and info.Likes + 1 or info.Likes
end

function M:GetInfoTime(deltaSecond)
	if not deltaSecond or deltaSecond < 0 then
		return TextScriptTextConfig.GetConfig(89900152).Text
	end

	local daySecond = 86400

	if deltaSecond < 60 then
		return TextScriptTextConfig.GetConfig(89900153).Text
	elseif deltaSecond < 3600 then
		return math.floor(deltaSecond / 60) .. TextScriptTextConfig.GetConfig(89900154).Text
	elseif deltaSecond < daySecond then
		return math.floor(deltaSecond / 3600) .. TextScriptTextConfig.GetConfig(89900155).Text
	end

	return gString.Format(TextScriptTextConfig.GetConfig(89901007).Text, math.floor(deltaSecond / daySecond))
end

function M:GetCommentsInfo(postId)
	local commentDict = {}
	local commentsList = {}
	local playerNoUseComments = {}
	local post = self.postDict[postId]
	local comments = post.Comments

	for i = 1, #comments do
		self:AddComment(commentsList, comments[i], commentDict)
	end

	local nPlayerComment = post.PlayerComments and #post.PlayerComments or 0

	for i = 1, nPlayerComment do
		self:AddReplyComment(playerNoUseComments, post.PlayerComments[i])
		self:AddPlayerComment(commentsList, post.PlayerComments[i], commentDict)
	end

	return commentsList, playerNoUseComments
end

function M:AddComment(commentList, commentId, existComments)
	local nextId = commentId
	local hasNext = true
	local repliedName = nil

	while hasNext do
		nextId, repliedName = self:AddOneComment(commentList, nextId, repliedName, existComments)
		hasNext = nextId and nextId ~= 0
	end
end

function M:AddOneComment(commentList, commentId, repliedName, existComments)
	local commentCfg = SocialMediaCommentConfig.GetConfig(commentId)

	if not commentCfg then
		print_error("[NewBubbleMgr]【配置错误】 策划未配置评论", commentId)

		return
	end

	if existComments[commentId] then
		return
	end

	local commentName = LTConfig.TextScriptTextConfig.GetConfig(89900141).Text
	local commentText = commentCfg.Txt
	local commentUserId = self.SocialId2AgentType[commentCfg.Publisher] or 0

	if commentUserId ~= 0 then
		commentName = gNpcFavorManager:GetAgentName(commentUserId)
	end

	if repliedName then
		commentText = TextScriptTextConfig.GetConfig(89900619).Text .. repliedName .. "：" .. commentText
	end

	local ret = {
		label = commentText,
		commentUserId = commentUserId
	}

	table.insert(commentList, ret)

	existComments[commentId] = true

	return commentCfg.NextId, commentName
end

function M:AddPlayerComment(commentList, data, existComments)
	if data.IsFinish ~= true then
		return
	end

	self:AddComment(commentList, data.CommentId, existComments)
end

function M:AddReplyComment(commentList, data)
	if data.IsFinish == true then
		return
	end

	local commentCfg = SocialMediaCommentConfig.GetConfig(data.CommentId)

	if not commentCfg then
		print_error("[NewBubbleMgr]【配置错误】 策划未配置评论", data.CommentId)

		return
	end

	table.insert(commentList, {
		commentId = data.CommentId,
		label = commentCfg.Txt
	})
end

function M:IsAlive()
	return self.baseStore and self.baseStore.STATE_EnableOnce
end

function M:ExitCurrentPanel()
	if not self.baseStore then
		return
	end

	self.baseStore:CloseContentPanel()
	gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
end

function M:FullExit()
	if not self.baseStore then
		return
	end

	self.baseStore:OnExit()
end

function M:SwitchCurrentPanel(data)
	local showType = data.secondShowType or 1

	if not data.showType then
		data.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Bubble
	end

	data.secondShowType = showType - 1

	if self.baseStore.STATE_EnableOnce then
		self.baseStore:ShowContentPanel(data)
	else
		gMainPhoneUtils.ShowPhoneAppContent(data)
	end
end

function M:OnClickNpcBubbleHead(agentType)
	local storyId = self:CheckHasNewStory(agentType)

	if storyId ~= 0 then
		self:OpenDetailPanel(storyId)
	else
		self:OpenNpcBubblePanel(agentType)
	end
end

function M:OpenNpcBubblePanel(agentType)
	if agentType == 0 or agentType == AgentSpecificTypeConfig.DefaultFemale or agentType == AgentSpecificTypeConfig.DefaultMale then
		gHunLunManager:OpenPersonalInfoPanel()

		return
	end

	self:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.FriendHome,
		agentType = agentType
	})
end

function M:OpenMyPostPanel()
	self:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.My_post
	})
end

function M:OpenDetailPanel(postId)
	self:AskReadPost({
		postId
	})

	if self:CheckIsStory(postId) then
		self:SwitchCurrentPanel({
			secondShowType = SocialMediaTabConfig.Film,
			postId = postId
		})
	else
		self:SwitchCurrentPanel({
			secondShowType = SocialMediaTabConfig.Detail,
			postId = postId
		})
	end
end

function M:OnRenderBubbleCommonAvatar(btn, index, agentType, style)
	if not agentType or agentType == 0 then
		agentType = gNpcFavorManager:GetCurrentAgentType()
	end

	local store = gStoreManager:GetStoreGroup("BubbleCommonAvatar"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local cfg = AgentSpecificTypeConfig.GetConfig(agentType)

	if not cfg then
		return
	end

	store.hasNew = self.BOOL2CTL[self:CheckHasNewStory(agentType) ~= 0]
	store.nameLabel = gNpcFavorManager:GetAgentName(agentType)
	local headStore = gNpcFavorManager:OnRenderHeadAvatar(store.headAvatar, agentType, style)

	gNpcFavorManager:OnRenderFavorTemplate(store.favorWidget, agentType)

	if headStore then
		headStore.button.luaClick = self:CreateActionWithArgs(self.OnClickNpcBubbleHead, agentType)
	end
end

function M:OnRenderBubbleFriendTempalate(btn, index, data)
	local store = gStoreManager:GetStoreGroup("BubbleFriendTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local npcId = data and data.npcId or 0
	local cfg = NpcCultivationConfig.GetConfig(npcId)
	local info = self:GetBubbleNpcInfo(cfg.AgentTag)

	self:OnRenderBubbleCommonAvatar(store.avatar, index, cfg.AgentTag)

	store.nameLabel = cfg and cfg.Name or ""
	store.otherNameLabel = info.name
	local hasNotice = false

	if not data.behaviorId then
		hasNotice = gNpcDaliyManager:CheckNpcInBusy(npcId)

		if not hasNotice then
			store.hasNotice = self.BOOL2CTL[false]
			local tag = gNpcDaliyManager:GetAgentTagByNpcId(npcId)
			local timeTable = gNpcDaliyManager:GetCurrentSchedule(tag)

			gNpcDaliyManager:OnRenderActivtyBySchedule(store.schedule, timeTable)

			return
		end
	end

	store.hasNotice = self.BOOL2CTL[hasNotice]

	if hasNotice then
		store.descLabel = SocialMediaConfig.BusyTitle
		store.dateLabel = ""
	end
end

function M:OnRenderDynamicItem(btn, postId, hasReply)
	local store = gStoreManager:GetStoreGroup("BubbleDetailStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	btn.redKey = "Bubble:" .. postId
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)

	local function RefreshLike()
		store.likeBtn.isSelected, store.numLabel = self:GetPostLikeAndLikes(postId)
		store.isLike = self.BOOL2CTL[store.likeBtn.isSelected]
	end

	local agentType = self:GetPostPublisher(postId)
	local npcInfo = self:GetBubbleNpcInfo(agentType)

	self:OnRenderBubbleCommonAvatar(store.headAvatar, 0, agentType)

	store.dateLabel = os.date(TextScriptTextConfig.GetConfig(89900618).Text, info.Date)
	store.titleLabel = cfg and cfg.Txt or info.Title
	store.withMe = self.BOOL2CTL[cfg and cfg.WithMe or false]
	store.nameLabel = npcInfo.name
	local image = cfg and cfg.Image or {}
	store.url = table.isNilOrEmpty(image) and info.ImageUrl or image[1]

	function store.likeBtn.luaClick()
		local isLike, _ = self:GetPostLikeAndLikes(postId)

		self:AskDoPostLike(postId, not isLike, function ()
			RefreshLike()
		end)
	end

	RefreshLike()

	store.hasReply = self.BOOL2CTL[hasReply or false]

	return store
end

function M:OnFriendListRenderItem(btn, index, data)
	if data.hide == true then
		return
	end

	local store = gStoreManager:GetStoreGroup("BubbleCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.selectedIndex and data.selectedIndex > 0 then
		store.selectedIndex = data.selectedIndex - 1
	end

	store:Commit("iconId", data.headIcon, COMMIT_IMMEDIATELY)

	store.favorLabel = data.favorLevel
	store.favorAmount = data.favorAmount
	store.hotLabel = data.totTime
	store.showFavorLevel = data.showFavorLevel and 0 or 1
	store.showFavorTime = data.showFavorTime and 0 or 1

	if store.favorBtn then
		function store.favorBtn.luaClick()
			data.showFavorLevel = not data.showFavorLevel

			if data.showFavorTime then
				data.showFavorTime = false
				store.showFavorTime = 1
			end

			store.showFavorLevel = data.showFavorLevel and 0 or 1
		end
	end

	if store.hotBtn then
		function store.hotBtn.luaClick()
			data.showFavorTime = not data.showFavorTime

			if data.showFavorLevel then
				data.showFavorLevel = false
				store.showFavorLevel = 1
			end

			store.showFavorTime = data.showFavorTime and 0 or 1
		end
	end

	if store.offsetTrans then
		local cfg = NpcCultivationConfig.GetConfig(data.id)

		if not cfg then
			return
		end

		local offset = cfg.BubbleOffset or {
			0,
			0
		}

		store.offsetTrans:SetLocalPosition(offset[1] or 0, offset[2] or 0, 0)
	end
end

function M:OnRenderBubbleCover(btn, index, agentType)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local isEmpty = agentType == 0
	store.index = index

	if not isEmpty then
		local info = self:GetBubbleNpcInfo(agentType)
		store.hasNew = self.BOOL2CTL[self:CheckHasNewStory(agentType) ~= 0]
		store.nameLabel = info.name
		store.headIcon = info.icon

		gNpcFavorManager:OnRenderFavorTemplate(store.favorWidget, agentType)
	end
end

function M:AskPostList(getPostType)
	self:Log("AskPostList", getPostType, gLuaDataManager.isNetworkAvailable)

	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	getPostType = getPostType or UX.Game.GetPostType.All

	gClientToGameDelegate:AskMomentsPostSimpleInfos(self.lastPostId, getPostType).Callback = function (err, data)
		self.inAsk = false

		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		for i = 1, #data do
			local post = data[i]
			self.lastPostId = math.max(self.lastPostId, post.Id)
			self.postDict[post.Id] = post
		end

		if not table.isNilOrEmpty(data) then
			self:BuildPostList()
		end

		gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
	end
end

function M:AskDoPostLike(postId, isLike, callback)
	self.cacheLikeDict[postId] = isLike
	self.likeTimer = self.likeTimer or Timer.New(function ()
		self.likeTimer = nil

		for k, v in pairs(self.cacheLikeDict) do
			self:_RealDoPostLike(k, v)
		end
	end, 1):Start()

	if callback then
		callback()
	end
end

function M:_RealDoPostLike(postId, isLike)
	gClientToGameDelegate:AskMomentsLikePost(postId, isLike).Callback = function (err)
		if err ~= MessageConfig.Ok then
			print_error("[NewBubbleMgr] 服务器错误", gCS.Error.GetNameById(err))
		else
			self.postDict[postId].Liked = isLike
		end
	end
end

function M:AskReadPost(postIds, successCb)
	local targetIds = {}

	for i = 1, #postIds do
		if not self.postDict[postIds[i]].IsRead then
			table.insert(targetIds, postIds[i])

			self.postDict[postIds[i]].IsRead = true
		end
	end

	if table.isNilOrEmpty(targetIds) then
		return
	end

	gClientToGameDelegate:AskMomentsMarkRead(targetIds).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			for i = 1, #targetIds do
				self.postDict[targetIds[i]].IsRead = false
			end
		else
			for i = 1, #targetIds do
				gRedPointMgr:RegisterRedDot(false, self:GetRedDot(targetIds[i]))
			end

			if successCb then
				successCb()
			end
		end
	end
end

function M:AskMomentsTapPost(postId, postList)
	gClientToGameDelegate:AskMomentsTapPostWithCount(postId, postList).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print_error("[NewBubbleMgr] AskMomentsTapPost 服务器错误", gCS.Error.GetNameById(err))
		end
	end
end

function M:AskPostComment(postId, commentId)
	gClientToGameDelegate:AskMomentsSendCommentWithId(postId, commentId).Callback = function (err, data)
		if err ~= MessageConfig.Ok then
			print_error("[NewBubbleMgr] 服务器错误", gCS.Error.GetNameById(err))
		else
			if not self.postDict[postId].PlayerComments then
				self.postDict[postId].PlayerComments = {}
			end

			for i = 1, #self.postDict[postId].PlayerComments do
				if self.postDict[postId].PlayerComments[i].CommentId == commentId then
					self.postDict[postId].PlayerComments[i].IsFinish = true

					break
				end
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end
	end
end

function M:EnvSdkTextFilter(text, successCb, failCb)
	gClientUtils.EnvSdkReviewWords(text, successCb, failCb, "SocialMedia")
end

function M:GetRedDot(id)
	return "Bubble/Bubble.Post/Bubble:" .. id
end

function M:HasRedDot(id)
	local info = self.postDict[id]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)

	if not cfg then
		return false
	end

	return cfg.WithMe and not info.IsRead
end

gNewBubbleMgr = gNewBubbleMgr or C_NewBubbleMgr.new()
