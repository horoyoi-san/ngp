C_YanjieCollectionPanelStore = DefClass("C_YanjieCollectionPanelStore", C_YanjieCollectionPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieCollectionPanelStore = C_YanjieCollectionPanelStore
local M = C_YanjieCollectionPanelStore
local TemplateType = {
	Category = 1,
	Detail = 0
}
local ArrowControl = {
	UnFold = 1,
	Fold = 0
}

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.collectList.luaRenderItem = self:CreateAction("OnRenderItem")
	self.bindData.gamepadShowLessButton.luaClick = self:CreateAction("OnShowLessClick")
end

function M:OnStart()
	gSocialNetworkUtils.DynamicLoadList(self.bindData.collectList, self:CreateAction("OnScroll"), self:CreateAction("OnScrollEnd"))
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION_LIST] = function (_, args)
			self:RefreshListView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
			self:FollowItemSuccess(args)
		end,
		[gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK] = function (_, args)
			self:RefreshItemView(args)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, args)
			self:RefreshItemView(args)
		end
	}
end

function M:PlayPanelAnimation()
	if self.panelArgs and self.panelArgs.lastShowType == gClientConst.YanJieShowType.Detail then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieCollectionPanel_BackDetail")

		self.panelArgs.lastShowType = nil
	end
end

function M:InitModel(args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.CollectPage)

	self.categoryIdList = gSocialNetworkUtils.GetCollectionCategoryIdList()
	self.currentCategoryId = self.categoryIdList[1]
	self.categoryListPageEntities = {}

	for _, id in ipairs(self.categoryIdList) do
		self.categoryListPageEntities[id] = gListPageEntity.new()
	end

	self:GetCollectionList()
end

function M:InitView(_)
	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieCollectionPanel_open")
	self:RefreshPanelView()
end

function M:RefreshPanelView()
	self.viewDataList = {}

	for _, categoryId in ipairs(self.categoryIdList) do
		table.insert(self.viewDataList, {
			tIndex = TemplateType.Category,
			categoryId = categoryId
		})

		if categoryId == self.currentCategoryId then
			local listPageEntity = self.categoryListPageEntities[categoryId]
			local momentViewDataList = listPageEntity:GetViewDataList()

			for index, _ in ipairs(momentViewDataList) do
				local momentData = listPageEntity:GetDataByIndex(index)

				table.insert(self.viewDataList, {
					categoryId = categoryId,
					tIndex = TemplateType.Detail,
					momentId = momentData.id
				})
			end
		end
	end

	function self.bindData.collectList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.viewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.collectList:SetSimpleList(#self.viewDataList)
end

function M:GetListPageEntityById(categoryId)
	local listPageEntity = self.categoryListPageEntities[categoryId]

	return listPageEntity
end

function M:GetCollectionList()
	local listPageEntity = self:GetListPageEntityById(self.currentCategoryId)

	if listPageEntity then
		local pageIndex = listPageEntity:GetCurrentPageIndex() + 1
		local pageSize = listPageEntity.pageSize

		gSocialNetworkUtils.GetCollectionList(self.currentCategoryId, pageIndex, pageSize)
	end
end

function M:RefreshListView(args)
	local categoryId = args.categoryId
	local listPageEntity = self:GetListPageEntityById(categoryId)

	listPageEntity:UpdateDataList(args.info)
	self:RefreshPanelView()
end

function M:RefreshItemView(args)
	for _, categoryId in ipairs(self.categoryIdList) do
		local listPageEntity = self:GetListPageEntityById(categoryId)

		listPageEntity:UpdateData(args)
	end

	self:RefreshPanelView()
end

function M:FollowItemSuccess(roleInfo)
	for _, categoryId in ipairs(self.categoryIdList) do
		local listPageEntity = self:GetListPageEntityById(categoryId)
		local roleId = roleInfo.roleId
		local dataMap = listPageEntity:GetDataMap()

		for _, data in pairs(dataMap) do
			if data.roleInfo.roleId == roleId then
				data.roleInfo.isFollow = roleInfo.isFollow
			end
		end
	end

	self:RefreshPanelView()
end

function M:OnExecuteExitAction()
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end

function M:OnShowLessClick()
	self.currentCategoryId = nil

	self:RefreshPanelView()
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.viewDataList[luaIndex]

	if data.tIndex == TemplateType.Category then
		local store = gStoreManager:GetStoreGroup("YanjieCollectionTemplateStore"):GetStoreByWidget(btn)
		local categoryId = data.categoryId
		local tuiteTyepCfg = LTConfig.TuiteTypeConfig.GetConfig(categoryId)
		store.categoryName = tuiteTyepCfg.TypeName
		store.arrowCtrl = categoryId == self.currentCategoryId and ArrowControl.UnFold or ArrowControl.Fold
		store.button.luaRelease = self:CreateActionWithArgs("OnCategoryClick", data.categoryId)
		self.lastTemplateIsCategory = true

		if self.currentCategoryId == nil and csIndex == 0 then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
		end
	elseif data.tIndex == TemplateType.Detail then
		local categoryId = data.categoryId
		local listPageEntity = self:GetListPageEntityById(categoryId)
		local momentData = listPageEntity:GetDataById(data.momentId)
		local lastMomentData = listPageEntity:GetDataByIndex(listPageEntity.totalCount)
		momentData.isLastOne = lastMomentData.id == momentData.id

		gSocialNetworkUtils.RefreshMomentItem(btn, momentData)

		local store = gStoreManager:GetStoreGroup("YanjieDetailTemplateStore"):GetStoreByWidget(btn)

		function store.button.luaClick()
			local animationName = "S_Vx_S_YanjieCollectionPanel_toDetail"

			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

			local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)
			self.bindData.rootWidget.activeCtrlDelay = clipTime

			gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_SHOW, {
				secondShowType = gClientConst.YanJieShowType.Detail,
				id = momentData.id,
				data = momentData
			})
		end

		if self.lastTemplateIsCategory then
			SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = btn
			self.lastTemplateIsCategory = false
		end
	end
end

function M:OnScroll(isPullUpToRefresh)
	if self.triggerLoading then
		return
	end

	local listPageEntity = self:GetListPageEntityById(self.currentCategoryId)

	if isPullUpToRefresh and listPageEntity and listPageEntity:CheckLoadMore() then
		self.triggerLoading = true
	end
end

function M:OnScrollEnd()
	if self.triggerLoading then
		self:GetCollectionList()

		self.triggerLoading = nil
	end
end

function M:ClearData()
	self.playAnimationCo = coroutine.stop(self.playAnimationCo)
end

function M:OnCategoryClick(categoryId)
	self.currentCategoryId = self.currentCategoryId ~= categoryId and categoryId or nil
	local listPageEntity = self:GetListPageEntityById(self.currentCategoryId)

	if listPageEntity and listPageEntity:GetViewDataCount() == 0 then
		self:GetCollectionList()
	end

	self:RefreshPanelView()
end
