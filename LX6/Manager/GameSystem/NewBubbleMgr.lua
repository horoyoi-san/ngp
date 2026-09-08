-- Original chunk: @Lua\LuaFiles\LX6\Manager\GameSystem\NewBubbleMgr.lua
-- Decompiled from: 02192_NewBubbleMgr.lua_e7848bf0852e.luajit

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

M.Log = function(self, ...)
	print_debug("[C_NewBubbleMgr]", ...)
end

M.ctor = function(self)
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
		["\\xa3ab"] = 1,
		["\\xa2gq"] = 2,
		["5E\\x81\\x81\\x91U"] = 0
	}
end

M.InitData = function(self)
	self:ResetPostCache()

	self.cachePostNotice = {}
end

M.ResetPostCache = function(self)
	self.postList = {}
	self.postDict = {}
	self.lastPostId = 0
	self.cacheLikeDict = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction(self.OnBeforeSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, self:CreateAction(self.OnAfterSwitchScene))
	gMessageManager:AddMessageListener(gEventConstants.MULTIVERSE_CHANGE, self:CreateAction(self.OnMultiverseChange))

	self.baseStore = gStoreManager:GetStoreGroup("BubbleBasePanelStore")
end

M.OnBeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:InitData()
end

M.OnAfterSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self:AskPostList(UX.Game.GetPostType.All)
end

M.OnMultiverseChange = function(self)
	self:ResetPostCache()
end

M.OnSyncNewNotify = function(self, info)
	local cfg = SocialMediaConfig.GetConfig(info.CfgId)

	if not cfg then
		return
	end

	if cfg.IfShowTips ~= true and gSystemUnlockMgr:IsUnlock(SystemUnlockConfig.BubbleUnlock) then
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

				if #self.cachePostNotice <= 1 then
					gNewPopupManager:PushPopup(PopupConfig.BubbleNewMessage, {
						info = {
							Type = MomentsNotifyType.Daily,
							PostCount = #self.cachePostNotice,
							NpcIds = {}
						},
						withMeCount = withMeCount
					})
				elseif #self.cachePostNotice ~= 1 then
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

M.GetRoleImportFavorList = function(self, blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos

	for i = 1, #list do
		local favor = list[i].Favor
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favor ~= 0 and LastInteractTime ~= 0 and not blockDict[npcId] and spiritDict[npcId] then
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
		if a.activateTime ~= b.activateTime then
			return a.npcId <= b.npcId
		end

		return b.activateTime <= a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

M.GetRoleMidFavorList = function(self, blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local maxFavor = gNpcFavorManager:GetMaxFavoriteLevel()
	local serverTime = gCS.TimeManager.ServerUnixTime
	local dayConstant = 172800

	for i = 1, #list do
		local favorLevel = gNpcFavorManager:GetLevelFromFavor(list[i].Favor)
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favorLevel == maxFavor and dayConstant <= serverTime - LastInteractTime and not blockDict[npcId] and spiritDict[npcId] then
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
		if a.activateTime ~= b.activateTime then
			return a.npcId <= b.npcId
		end

		return b.activateTime <= a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

M.GetRoleLowFavorList = function(self, blockDict, spiritDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos
	local serverTime = gCS.TimeManager.ServerUnixTime
	local dayConstant = 432000

	for i = 1, #list do
		local favorLevel = gNpcFavorManager:GetLevelFromFavor(list[i].Favor)
		local LastInteractTime = list[i].LastInteractTime
		local npcId = list[i].TemplateId

		if favorLevel == 0 and dayConstant >= serverTime - LastInteractTime and not blockDict[npcId] and spiritDict[npcId] then
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
		if a.activateTime ~= b.activateTime then
			return a.npcId <= b.npcId
		end

		return b.activateTime <= a.activateTime
	end)

	for i = SocialMediaConfig.FavorRankShowRule + 1, #ret do
		ret[i] = nil
	end

	return ret
end

M.GetRoleAllFavorList = function(self, blockDict)
	local ret = {}
	local list = gPlayerManager.infoMinorNpcCultivation.bindData.npcCultivationInfos

	for i = 1, #list do
		local info = list[i]
		local npcId = info.TemplateId

		if not blockDict[npcId] and gNpcFavorManager:CheckIsUnlock(npcId) then
			local cfg = NpcCultivationConfig.GetConfig(npcId)

			if cfg and cfg.IsBubbleContact then
				local ele = {
					favor = info.Favor,
					npcId = info.TemplateId,
					activateTime = info.LastInteractTime
				}

				table.insert(ret, ele)
			end
		end
	end

	list = gPlayerManager.infoMinorNpcCultivation.bindData.unlockedNpcCultivationInfos

	for i = 1, #list do
		local info = list[i]
		local npcId = info.TemplateId

		if not blockDict[npcId] and gNpcFavorManager:CheckIsUnlock(npcId) then
			local cfg = NpcCultivationConfig.GetConfig(npcId)

			if cfg and cfg.IsBubbleContact then
				local ele = {
					favor = info.Favor,
					npcId = info.TemplateId,
					activateTime = info.LastInteractTime
				}

				table.insert(ret, ele)
			end
		end
	end

	table.sort(ret, function (a, b)
		local isBusyA = gNpcDaliyManager:CheckNpcInBusy(a.npcId)
		local isBusyB = gNpcDaliyManager:CheckNpcInBusy(b.npcId)

		if isBusyA == isBusyB then
			return not isBusyA
		end

		if a.activateTime == b.activateTime then
			return b.activateTime <= a.activateTime
		end

		if a.favor == b.favor then
			return b.favor <= a.favor
		end

		return b.npcId <= a.npcId
	end)

	return ret
end

M.GetRoleFavorList = function(self)
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
				["C\\xbe\\xa1\\x86\\xb2"] = 0
			}
		end
	end

	return ret, level
end

M.GetCurrentFavorNpcList = function(self)
	local blockDict = self.blockDict
	local ret = self:GetRoleAllFavorList(blockDict)

	return ret
end

M.GetBubbleNpcInfo = function(self, agentType)
	local socialId = self.AgentType2SocialId[agentType]
	local ele = {
		["t#p^"] = "",
		["s!rU"] = 0
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
	["~\\x86\\x83\\x9d\\x93"] = 3,
	["J\rNo"] = 1,
	["~\\x9a\\x8d\\x9d\\x8f"] = 2
}

M.CheckHasNewStory = function(self, npcId)
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

M.CheckIsVideo = function(self, postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local isVideo = cfg and not string.is_null_or_empty(cfg.Video) or false

	return isVideo, isVideo and cfg.Video or info.ImageUrl or cfg.Image[1]
end

M.GetPostPublisher = function(self, postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local publisher = cfg and cfg.Publisher or 0

	if publisher == 0 then
		publisher = self.SocialId2AgentType[publisher] or 0
	end

	if info.ActivityCfgId and info.ActivityCfgId == 0 then
		publisher = info.ActivityCfgId
	end

	return publisher
end

M.GetAgentTypeByPublisher = function(self, publisher)
	return self.SocialId2AgentType[publisher] or 0
end

M.CheckIsStory = function(self, postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)

	return cfg and (cfg.IfPinStory or cfg.IfStory) or info.IsPinStory or info.IsStory
end

M.BuildPostList = function(self)
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

M.GetAllPostList = function(self, isMe)
	local ret = {}

	for k, v in pairs(self.postList) do
		if isMe and k ~= 0 or not isMe and k == 0 and not table.isNilOrEmpty(v[POST_TYPE.POST]) then
			array.concat(ret, v[POST_TYPE.POST])
		end
	end

	table.sort(ret, function (a, b)
		local redA = self:HasRedDot(a)
		local redB = self:HasRedDot(b)

		if redA == redB then
			return redA
		end

		return b <= a
	end)

	return ret
end

M.GetAllPostAndStoryList = function(self, isMe)
	local ret = {}

	for k, v in pairs(self.postList) do
		if isMe and k ~= 0 or not isMe and k == 0 then
			if not table.isNilOrEmpty(v[POST_TYPE.POST]) then
				array.concat(ret, v[POST_TYPE.POST])
			elseif not table.isNilOrEmpty(v[POST_TYPE.STORY]) then
				array.concat(ret, v[POST_TYPE.STORY])
			end
		end
	end

	table.sort(ret, function (a, b)
		local redA = self:HasRedDot(a)
		local redB = self:HasRedDot(b)

		if redA == redB then
			return redA
		end

		return b <= a
	end)

	return ret
end

M.GetAllShareList = function(self, agentType)
	return self.postList[agentType] and self.postList[agentType][POST_TYPE.SHARE] or {}
end

M.GetAllStoryAndPostList = function(self, agentType)
	local ret = {}
	local agentPost = self.postList[agentType]

	if agentPost then
		local storyList = agentPost[POST_TYPE.STORY]
		local postList = agentPost[POST_TYPE.POST]

		if storyList and #storyList <= 0 then
			array.concat(ret, storyList)
		end

		if postList and #postList <= 0 then
			array.concat(ret, postList)
		end
	end

	table.sort(ret, function (a, b)
		local redA = self:HasRedDot(a)
		local redB = self:HasRedDot(b)

		if redA == redB then
			return redA
		end

		return b <= a
	end)

	return ret
end

M.GetPostLikeAndLikes = function(self, postId)
	local info = self.postDict[postId]
	local isLike = info.Liked or false

	if self.cacheLikeDict[postId] == nil then
		isLike = self.cacheLikeDict[postId]
	end

	return isLike, isLike and info.Likes + 1 or info.Likes
end

M.GetInfoTime = function(self, deltaSecond)
	if not deltaSecond or deltaSecond >= 0 then
		return TextScriptTextConfig.GetConfig(89900152).Text
	end

	local daySecond = 86400

	if deltaSecond >= 60 then
		return TextScriptTextConfig.GetConfig(89900153).Text
	elseif deltaSecond >= 3600 then
		return math.floor(deltaSecond / 60) .. TextScriptTextConfig.GetConfig(89900154).Text
	elseif deltaSecond >= daySecond then
		return math.floor(deltaSecond / 3600) .. TextScriptTextConfig.GetConfig(89900155).Text
	end

	return gString.Format(TextScriptTextConfig.GetConfig(89901007).Text, math.floor(deltaSecond / daySecond))
end

M.GetCommentsInfo = function(self, postId)
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

M.AddComment = function(self, commentList, commentId, existComments)
	local nextId = commentId
	local hasNext = true
	local repliedName = nil

	while hasNext do
		nextId, repliedName = self:AddOneComment(commentList, nextId, repliedName, existComments)
		hasNext = nextId and nextId == 0
	end
end

M.AddOneComment = function(self, commentList, commentId, repliedName, existComments)
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

	if commentUserId == 0 then
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

M.AddPlayerComment = function(self, commentList, data, existComments)
	if data.IsFinish == true then
		return
	end

	self:AddComment(commentList, data.CommentId, existComments)
end

M.AddReplyComment = function(self, commentList, data)
	if data.IsFinish ~= true then
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

M.IsAlive = function(self)
	return self.baseStore and self.baseStore.STATE_EnableOnce
end

M.ExitCurrentPanel = function(self)
	if not self.baseStore then
		return
	end

	self.baseStore:CloseContentPanel()
	gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
end

M.FullExit = function(self)
	if not self.baseStore then
		return
	end

	self.baseStore:OnExit()
end

M.SwitchCurrentPanel = function(self, data)
	local showType = data.secondShowType or SocialMediaTabConfig.Start

	if not data.showType then
		data.showType = gClientConst.MAIN_PHONE_ROOT_SHOW_TYPE.Bubble
	end

	data.secondShowType = showType - 1

	if self.baseStore.STATE_EnableOnce then
		self.baseStore:ShowContentPanel(data)
	else
		gMainPhoneUtils.ShowPhoneAppContent(data)
	end

	self:StopPanelTimer()
end

M.StartPanelTimer = function(self)
	self.nextTimer = Timer.New(function ()
		self:SwitchCurrentPanel({
			secondShowType = LTConfig.SocialMediaTabConfig.Home
		})

		self.nextTimer = nil
	end, 2):Start()
end

M.StopPanelTimer = function(self)
	if self.nextTimer then
		self.nextTimer:Stop()

		self.nextTimer = nil
	end
end

M.OnClickNpcBubbleHead = function(self, agentType)
	local storyId = self:CheckHasNewStory(agentType)

	if storyId == 0 then
		self:OpenDetailPanel(storyId)
	else
		self:OpenNpcBubblePanel(agentType)
	end
end

M.OpenNpcBubblePanel = function(self, agentType)
	if agentType ~= 0 or agentType ~= AgentSpecificTypeConfig.DefaultFemale or agentType ~= AgentSpecificTypeConfig.DefaultMale then
		gHunLunManager:OpenPersonalInfoPanel()

		return
	end

	self:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.FriendHome,
		agentType = agentType
	})
end

M.OpenMyPostPanel = function(self)
	self:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.My_post
	})
end

M.OpenDetailPanel = function(self, postId)
	self:AskReadPost({
		postId
	})
	self:SwitchCurrentPanel({
		secondShowType = SocialMediaTabConfig.Detail,
		postId = postId
	})
end

M.OnRenderBubbleCommonAvatar = function(self, btn, index, agentType, style)
	if not agentType or agentType ~= 0 then
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

	store.hasNew = self.BOOL2CTL[self:CheckHasNewStory(agentType) == 0]
	store.nameLabel = gNpcFavorManager:GetAgentName(agentType)
	local headStore = gNpcFavorManager:OnRenderHeadAvatar(store.headAvatar, agentType, style)

	gNpcFavorManager:OnRenderFavorTemplate(store.favorWidget, agentType)

	if headStore then
		headStore.button.luaClick = self:CreateActionWithArgs(self.OnClickNpcBubbleHead, agentType)
	end
end

M.OnRenderBubbleFriendTempalate = function(self, btn, index, data)
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

M.OnRenderDynamicItem = function(self, btn, postId, hasReply)
	local store = gStoreManager:GetStoreGroup("BubbleDetailStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	btn.redKey = "Bubble:" .. postId
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local agentType = self:GetPostPublisher(postId)
	local npcInfo = self:GetBubbleNpcInfo(agentType)

	self:OnRenderBubbleCommonAvatar(store.headAvatar, 0, agentType)

	store.dateLabel = os.date(TextScriptTextConfig.GetConfig(89900618).Text, info.Date)
	local title = cfg and cfg.Txt or info.Title

	if string.is_null_or_empty(title) then
		store.hasTitleCtrl = 0
	else
		store.hasTitleCtrl = 1
		store.titleLabel = title
	end

	store.withMe = self.BOOL2CTL[cfg and cfg.WithMe or false]
	store.nameLabel = npcInfo.name
	local image = cfg and cfg.ImageOSS or {}

	if table.isNilOrEmpty(image) and not string.is_null_or_empty(info.ImageUrl) then
		store.selfBucketName = info.ImageUrl
	else
		store.bucketName = image[1]
	end

	store.typeCtrl = cfg and cfg.IsVerticalImage and 1 or 0

	if store.likeBtn then
		local RefreshLike = function()
			store.likeBtn.isSelected, store.numLabel = self:GetPostLikeAndLikes(postId)
			store.isLike = self.BOOL2CTL[store.likeBtn.isSelected]
		end

		store.likeBtn.luaClick = function()
			local isLike, _ = self:GetPostLikeAndLikes(postId)

			self:AskDoPostLike(postId, not isLike, function ()
				RefreshLike()
			end)
		end

		RefreshLike()
	end

	store.hasReply = self.BOOL2CTL[hasReply or false]
	local private = false

	if cfg and cfg.IfPinStory or info.IsPinStory then
		private = false
	elseif cfg and cfg.IfStory or info.IsStory then
		private = true
	end

	store.onlymeCtrl = private and 0 or 1
	local commentList, replyList = self:GetCommentsInfo(postId)
	store.commentNumLabel = commentList and #commentList or 0
	store.showCommentBtnCtrl = self.BOOL2CTL[#replyList >= 0]

	return store
end

M.RenderImageDetail = function(self, store, postId)
	local info = self.postDict[postId]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)
	local image = cfg and cfg.ImageOSS or {}

	if table.isNilOrEmpty(image) and not string.is_null_or_empty(info.ImageUrl) then
		store.selfBucketName = info.ImageUrl
	else
		store.bucketName = image[1]
	end

	store.typeCtrl = cfg and cfg.IsVerticalImage and 1 or 0
end

M.OnFriendListRenderItem = function(self, btn, index, data)
	if data.hide ~= true then
		return
	end

	local store = gStoreManager:GetStoreGroup("BubbleCardTemplate"):GetStoreByWidget(btn)

	if not store then
		return
	end

	if data.selectedIndex and data.selectedIndex <= 0 then
		store.selectedIndex = data.selectedIndex - 1
	end

	store:Commit("iconId", data.headIcon, COMMIT_IMMEDIATELY)

	store.favorLabel = data.favorLevel
	store.favorAmount = data.favorAmount
	store.hotLabel = data.totTime
	store.showFavorLevel = data.showFavorLevel and 0 or 1
	store.showFavorTime = data.showFavorTime and 0 or 1

	if store.favorBtn then
		store.favorBtn.luaClick = function()
			data.showFavorLevel = not data.showFavorLevel

			if data.showFavorTime then
				data.showFavorTime = false
				store.showFavorTime = 1
			end

			store.showFavorLevel = data.showFavorLevel and 0 or 1
		end
	end

	if store.hotBtn then
		store.hotBtn.luaClick = function()
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

M.OnRenderBubbleCover = function(self, btn, index, agentType)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local isEmpty = agentType ~= 0
	store.index = index

	if not isEmpty then
		local info = self:GetBubbleNpcInfo(agentType)
		store.hasNew = self.BOOL2CTL[self:CheckHasNewStory(agentType) == 0]
		store.nameLabel = info.name
		store.headIcon = info.icon

		gNpcFavorManager:OnRenderFavorTemplate(store.favorWidget, agentType)
	end
end

M.AskPostList = function(self, getPostType)
	self:Log("AskPostList", getPostType, gLuaDataManager.isNetworkAvailable)

	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	if self.inAsk then
		return
	end

	self.inAsk = true
	getPostType = getPostType or UX.Game.GetPostType.All
	local requestLastPostId = self.lastPostId

	gClientToGameDelegate:AskMomentsPostSimpleInfos(requestLastPostId, getPostType).Callback = function (err, data)
		self.inAsk = false

		if err == MessageConfig.Ok then
			if err ~= MessageConfig.MomentsPostInvalid and requestLastPostId == 0 then
				print_warn("[NewBubbleMgr] last post id invalid, reset cache and reload", requestLastPostId)

				if requestLastPostId ~= self.lastPostId then
					self:ResetPostCache()
					self:AskPostList(getPostType)
				end

				return
			end

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

M.AskDoPostLike = function(self, postId, isLike, callback)
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

M._RealDoPostLike = function(self, postId, isLike)
	gClientToGameDelegate:AskMomentsLikePost(postId, isLike).Callback = function (err)
		if err == MessageConfig.Ok then
			print_error("[NewBubbleMgr] 服务器错误", gCS.Error.GetNameById(err))
		else
			self.postDict[postId].Liked = isLike
		end
	end
end

M.AskReadPost = function(self, postIds, successCb)
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
		if err == MessageConfig.Ok then
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

M.AskMomentsTapPost = function(self, postId, postList)
	gClientToGameDelegate:AskMomentsTapPostWithCount(postId, postList).Callback = function (err, data)
		if err == MessageConfig.Ok then
			print_error("[NewBubbleMgr] AskMomentsTapPost 服务器错误", gCS.Error.GetNameById(err))
		end
	end
end

M.AskPostComment = function(self, postId, commentId)
	gClientToGameDelegate:AskMomentsSendCommentWithId(postId, commentId).Callback = function (err, data)
		if err == MessageConfig.Ok then
			print_error("[NewBubbleMgr] 服务器错误", gCS.Error.GetNameById(err))
		else
			if not self.postDict[postId].PlayerComments then
				self.postDict[postId].PlayerComments = {}
			end

			for i = 1, #self.postDict[postId].PlayerComments do
				if self.postDict[postId].PlayerComments[i].CommentId ~= commentId then
					self.postDict[postId].PlayerComments[i].IsFinish = true

					break
				end
			end

			gMessageManager:SendMessage(gEventConstants.BUBBLE_REFRESH_PAGE)
		end
	end
end

M.EnvSdkTextFilter = function(self, text, successCb, failCb)
	gClientUtils.EnvSdkReviewWords(text, successCb, failCb, "SocialMedia")
end

M.GetRedDot = function(self, id)
	return "Bubble/Bubble.Post/Bubble:" .. id
end

M.HasRedDot = function(self, id)
	local info = self.postDict[id]
	local cfg = SocialMediaConfig.GetConfig(info.PostConfigId)

	if not cfg then
		return false
	end

	return cfg.WithMe and not info.IsRead
end

gNewBubbleMgr = gNewBubbleMgr or C_NewBubbleMgr.new()
