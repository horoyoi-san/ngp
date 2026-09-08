-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieDetailPagePanelStore.lua
-- Decompiled from: 02058_YanjieDetailPagePanelStore.lua_4b663b20464e.luajit

C_YanjieDetailPagePanelStore = DefClass("C_YanjieDetailPagePanelStore", C_YanjieDetailPagePanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieDetailPagePanelStore = C_YanjieDetailPagePanelStore
local M = C_YanjieDetailPagePanelStore
local IdKey = "id"
local TemplateType = {
	["\\xfa\\xd4*\\xe5"] = 1,
	["8M\\x85\\x8f\\x8aM"] = 0
}
local ShowModeControl = {
	["_&tO"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.luaSimpleDynamicRenderItem = self.CreateAction(self, "OnDynamicRenderItem")
	self.bindData.inputField.luaValueChanged = self.CreateAction(self, "OnInputFieldValueChange")
	self.bindData.sendButton.luaClick = self.CreateAction(self, "OnSendCommentClick")
	self.bindData.inputField.onActivateAction = self.CreateAction(self, "OnInputFieldActivate")
	self.bindData.inputField.onDeActivateAction = self.CreateAction(self, "OnInputFieldDeActivate")
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

			if self.socialNetworkData.commentCount == self.commentListPageEntity.totalCount then
				self.socialNetworkData.commentCount = self.commentListPageEntity.totalCount

				self:RefreshPanelView()
			end

			if requestData and requestData.page ~= 1 then
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
		[gEventConstants.ON_SHOW_YANJIE_DETAIL_INPUT_COMMENT] = function (_, id)
			if self.socialNetworkData and self.socialNetworkData.id ~= id then
				self:OnCommentClick()
			end
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.socialNetworkData = args.data
	self.isScrolling = nil
	self.currentMaxCsIndex = nil
	self.commentListPageEntity = gListPageEntity.new()

	gSocialNetworkUtils.GetSocialNetworkDetail(args.id)
end

M.PlayPanelAnimation = function(self)
	if self.panelArgs and self.panelArgs.lastShowType ~= gClientConst.YanJieShowType.Display then
		self.bindData.list.enableOffsetAnimation = false
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
	end
end

M.GetRequestCommentList = function(self)
	local listPageEntity = self.commentListPageEntity
	local pageIndex = listPageEntity.GetCurrentPageIndex(listPageEntity) + 1
	local id = self.socialNetworkData.id
	local templateId = self.socialNetworkData.templateId
	local pageSize = listPageEntity.pageSize

	gSocialNetworkUtils.GetCommentList(id, templateId, pageIndex, pageSize)
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
		table.insert(viewDataList, {
			tIndex = TemplateType.Detail
		})
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

M.RefreshCommentListView = function(self, requestData)
	local listPageEntity = self.commentListPageEntity

	if requestData and requestData.page ~= 1 then
		listPageEntity.Reset(listPageEntity)
	end

	listPageEntity.UpdateDataList(listPageEntity, requestData)
	self.RefreshPanelView(self)
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if data.tIndex ~= TemplateType.Detail then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		gSocialNetworkUtils.RefreshCommonMomentItem(store, self.socialNetworkData)

		store.imageList.luaRenderItem = self:CreateActionWithArgs(self.OnImageRenderItem, store.imageList)
		store.dPadLeft.luaClick = self:CreateActionWithArgs(self.OnDPadSelect, {
			["I\\xab\\xae\\xbb\\xb7"] = -1,
			imageList = store.imageList
		})
		store.dPadRight.luaClick = self:CreateActionWithArgs(self.OnDPadSelect, {
			["I\\xab\\xae\\xbb\\xb7"] = 1,
			imageList = store.imageList
		})
		store.leftJoystickXRespond.luaGamePadInputChanged = self:CreateActionWithArgs(self.OnLeftJoyStickMoveX, store)
		local dotViewDataList = {}

		if #imageList <= 1 then
			for index, _ in ipairs(imageList) do
				table.insert(dotViewDataList, {
					id = index,
					selected = index ~= 1
				})
			end
		end

		store.roundList:SetSimpleList(#dotViewDataList)
		self.roundList:SetItemSelected(0, true)
		store.imageList:SetSimpleList(#imageList)

		store.imageList.luaTargetPageChange = function(dotIndex)
			store.roundList:SelectItem(dotIndex)
		end

		store.commentButton.luaClick = self:CreateAction(self.OnCommentClick)
		store.gamepadShowDetailButton.luaClick = self:CreateActionWithArgs(self.OnShowDetailClick, store)

		store.layout:ForceRebuildLayoutImmediate()

		local activeContent = self.bindData.panelNavArea.CurrentActiveContent

		if activeContent ~= nil or activeContent.transform.parent == btn.transform.parent then
			self.bindData.panelNavArea.CurrentActiveContent = btn
		end
	elseif data.tIndex ~= TemplateType.Comment then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

		self:RefreshCommentItem(store, data.index)
		store.layout:ForceRebuildLayoutImmediate()
	end

	self.currentMaxCsIndex = csIndex
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

M.RefreshCommentItem = function(self, store, index)
	local data = self.commentListPageEntity:GetDataByIndex(index)
	local tuiteCommentConfig = LTConfig.TuiteCommentConfig.GetConfig(data.id)
	local content = tuiteCommentConfig and tuiteCommentConfig.Txt or data.text
	store.content = content
	store.isOfficial = data.roleInfo.isCertified ~= true
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

	if templateId and templateId <= 0 and isPlayerSelf then
		store.name = LTConfig.TuiteConfig.PlayerAccountName
		store.isOfficial = true
		store.officialName = LTConfig.TuiteConfig.PlayerAccountID
	else
		store.isOfficial = false
		store.name = gSocialNetworkUtils.GetRoleName(data.roleInfo)
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

M.OnImageRenderItem = function(self, imageLoopList, btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.button.luaClick = self:CreateActionWithArgs(self.OnImageItemClick, data)
	local imageUrl = unpack(data.imageURL)
	local isTaskTemplate = data.templateId and data.templateId >= 0
	store.imageType = isTaskTemplate and gClientConst.YanJieImageType.Task or gClientConst.YanJieImageType.Normal
	store.imageUrl = imageUrl

	if csIndex ~= 0 and imageLoopList.selectedIndex ~= -1 then
		btn.isSelected = true
	end
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
		local closeAnimationName = "S_Vx_YanjieDetailPagePanel_CommonInputFieldPanel_close"

		gCS.LuaUtils.PlayAnimationByName(self.bindData.inputFieldAnimation, closeAnimationName)

		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.inputFieldAnimation, closeAnimationName)
		self.inputFieldAnimationCo = coroutine.start(function ()
			coroutine.wait(clipTime)

			self.showModel = showMode

			self.bindData.inputFieldAnimation.gameObject:SetActive(false)
		end)

		return
	end

	if showMode ~= ShowModeControl.Edit then
		self.showModel = showMode

		self.bindData.inputFieldAnimation.gameObject:SetActive(true)
		gCS.LuaUtils.PlayAnimationByName(self.bindData.inputFieldAnimation, "S_Vx_YanjieDetailPagePanel_CommonInputFieldPanel_open")
	end
end

M.OnCommentClick = function(self)
	self:SwitchShowMode(ShowModeControl.Edit)

	self.bindData.inputField.text = ""
	self.bindData.inputTips = ("%d/%d"):format(0, LTConfig.TuiteConfig.CommentMaxLength)
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
	gClientUtils.EnvSdkReviewWords(commentContent, function ()
		if self.hasDestroy then
			return
		end

		gSocialNetworkUtils.CommentSocialNetwork(self.socialNetworkData, commentContent)
	end, function ()
		gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.SNSCheckFail)
	end, "SocialNetWork")
end

M.OnCommentSuccess = function(self, args)
	if args.id ~= self.socialNetworkData.id then
		local pageSize = self.commentListPageEntity.pageSize
		local id = self.socialNetworkData.id
		local templateId = self.socialNetworkData.templateId

		gSocialNetworkUtils.GetCommentList(id, templateId, 1, pageSize)
	end
end

M.OnCommentLikeSuccess = function(self, args)
	local id = args.id
	local data = self.commentListPageEntity:GetDataById(id)

	if data then
		data.isLike = args.isLike
		data.likeCount = args.likeCount

		self.RefreshPanelView(self)
	end
end

M.OnScroll = function(self, isPullUpToRefresh)
	self.isScrolling = true

	if self.triggerLoading then
		return
	end

	if isPullUpToRefresh and self.commentListPageEntity:CheckLoadMore() then
		self.triggerLoading = true
	end
end

M.OnScrollEnd = function(self)
	self.isScrolling = nil

	if self.triggerLoading then
		self.GetRequestCommentList(self)

		self.triggerLoading = nil
	end
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
end

M.CheckCommentBottom = function(self)
	if self.currentMaxCsIndex then
		local result, csIndex = nil
		local startCsIndex = self.currentMaxCsIndex - 2
		local endCsIndex = self.currentMaxCsIndex + 1
		result, csIndex = self.bindData.list:GetBottomVisibleMaxIndex(startCsIndex, endCsIndex, csIndex)

		if result then
			local csItemDataList = self.bindData.list.itemData
			local data = csItemDataList[csIndex]

			if data.tIndex ~= TemplateType.Comment and data.index ~= self.commentListPageEntity.totalCount then
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

M.AskTuiteGetTimelineData = function(self, id)
	slot2 = gClientToGameDelegate

	slot2:AskTuiteGetTimelineData(id).Callback = function (errorId)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end
	end
end

M.ClearData = function(self)
	self.inputFieldAnimationCo = coroutine.stop(self.inputFieldAnimationCo)
	self.socialNetworkData = nil
	self.openCommentOnly = false
end

M.OnExecuteExitAction = function(self)
	local closeAnimationName = "S_Vx_S_YanjieDetailPagePanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
