C_CommonYanjieListTemplate = DefClass("C_CommonYanjieListTemplate", C_CommonYanjieListTemplate, C_StoreGroup)
GroupName2Class.CommonYanjieListTemplate = C_CommonYanjieListTemplate
local M = C_CommonYanjieListTemplate
local ShowTypeControl = {
	Content = 0,
	Empty = 1
}

function M:ctor()
	return
end

function M:OnAwake()
	self:InitModel()
	self:InitView()
	self:InitMessageEvents()
end

function M:InitMessageEvents()
	local msgEvents = {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_LIKE] = function (_, args)
			self:RefreshItemView(args)
		end
	}

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_COLLECTION] = function (_, args)
		args.playCollectionAnimation = args.isCollect

		self:OnCollectionSuccess(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_COMMENT_SOCIAL_NETWORK] = function (_, args)
		self:RefreshItemView(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_DETAIL] = function (_, args)
		self:RefreshItemView(args)
	end

	msgEvents[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_FOLLOW] = function (_, args)
		self:FollowItemSuccess(args)
	end

	self:RegisterMessageEvents(msgEvents)
end

function M:OnStart()
	gSocialNetworkUtils.DynamicLoadList(self.bindData.list, self:CreateAction("OnScroll"), self:CreateAction("OnScrollEnd"))
end

function M:OnDestroy()
	self.hasDestroy = true

	self:ClearMessageEvents()
end

function M:OnShow(_, _)
	return
end

function M:StartRequest()
	self:GetRequestDataList()
end

function M:InitModel()
	self.buttonMap = {}
	self.hasDestroy = nil
	self.listPageEntity = gListPageEntity.new()
	self.listPageEntity.pageSize = 20
end

function M:InitView()
	if self:CheckIsUList() then
		self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")
		self.bindData.list.luaSimpleDynamicRenderItem = self:CreateAction("OnDynamicRenderItem")
	else
		self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
		self.bindData.list.luaDynamicRenderItem = self:CreateAction("OnDynamicRenderItem")
	end

	self.bindData.list.luaDrag = self:CreateAction("OnDrag")
	self.bindData.list.luaEndDrag = self:CreateAction("OnDragEnd")

	self.bindData.list:RegisterToScrollEndEvent(self:CreateAction("OnScrollEnd"))
end

function M:CheckIsUList()
	return self.bindData.list:GetTypeName() == "UList"
end

function M:OnScroll(isPullUpToRefresh)
	self.isScrolling = true

	if self.triggerLoading then
		return
	end

	if isPullUpToRefresh and self.listPageEntity:CheckLoadMore() then
		self.triggerLoading = true
	end
end

function M:OnScrollEnd()
	self.isScrolling = nil

	if self.triggerLoading then
		self:GetRequestDataList()

		self.triggerLoading = nil
	end
end

function M:CheckItemVisible()
	if self.currentMaxCsIndex then
		local result, csMaxIndex = nil
		local startCsIndex = self.currentMaxCsIndex - 2
		local endCsIndex = self.currentMaxCsIndex + 1
		result, csMaxIndex = self.bindData.list:GetBottomVisibleMaxIndex(startCsIndex, endCsIndex, csMaxIndex)

		if result then
			local luaMaxIndex = csMaxIndex + 1
			local beginIndex = luaMaxIndex - 2
			beginIndex = math.max(beginIndex, 1)

			for index = beginIndex, luaMaxIndex do
				local data = self.listPageEntity:GetDataByIndex(index)

				if data then
					local tuiteConfigId = gSocialNetworkUtils.GetTuiteConfigId(data)

					gSocialNetworkUtils.AskTwitterBehaviorFinish(tuiteConfigId, UX.Game.TwitterBehavior.ItemVisible)
				end
			end
		end
	end
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.listPageEntity:GetDataByIndex(luaIndex)
	data.isLastOne = luaIndex == self.listPageEntity.totalCount
	data.itemClickCallback = self.itemClickCallback

	gSocialNetworkUtils.RefreshMomentItem(btn, data)

	self.buttonMap[data.id] = btn

	if csIndex == 0 and not self.ignoreNavigate then
		local activeArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea

		if activeArea and activeArea.CurrentActiveContent and activeArea.CurrentActiveContent.transform then
			if activeArea.CurrentActiveContent.transform:GetComponentInParent(typeof(SGUI.UListWithMultiContent)) ~= btn.transform:GetComponentInParent(typeof(SGUI.UListWithMultiContent)) then
				btn:Navigate(btn)
			end

			if activeArea.CurrentActiveContent.transform:GetComponentInParent(typeof(SGUI.UList)) ~= btn.transform:GetComponentInParent(typeof(SGUI.UList)) then
				btn:Navigate(btn)
			end
		else
			btn:Navigate(btn)
		end
	end

	self.currentMaxCsIndex = csIndex
end

function M:GetRequestDataList(pageIndex)
	pageIndex = pageIndex or self.listPageEntity:GetCurrentPageIndex() + 1
	local pageSize = self.listPageEntity.pageSize

	self.GetList(pageIndex, pageSize, function (data)
		if self.hasDestroy then
			return
		end

		self:RefreshContentListView(data)
	end)
end

function M:RefreshContentListView(requestData)
	local isRequestFirstPage = requestData and requestData.page == 1

	if isRequestFirstPage then
		self.listPageEntity:Reset()
	end

	self.listPageEntity:UpdateDataList(requestData)

	self.viewDataList = self.listPageEntity:GetViewDataList()

	for _, viewData in ipairs(self.viewDataList) do
		local data = viewData.listPageDataKeyValuePair
		local isTaskTemplate = data.templateId and data.templateId > 0
		local tuiteCfg = gSocialNetworkUtils.GetTuiteConfig(data)
		isTaskTemplate = isTaskTemplate and tuiteCfg and tuiteCfg.TaskEvent and tuiteCfg.TaskEvent > 0
		local isFullScreen = gMainPhoneUtils.CheckYanJieIsFullScreen()

		if isFullScreen then
			viewData.tIndex = isTaskTemplate and 1 or 0
		end
	end

	self.firstBtn = nil

	if self:CheckIsUList() then
		function self.bindData.list.onGetTIndex(csIndex)
			local luaIndex = csIndex + 1
			local data = self.viewDataList[luaIndex]

			return data.tIndex
		end

		self.bindData.list:SetSimpleList(#self.viewDataList)
	else
		self.bindData.list:SetList(self.viewDataList)
	end

	local showTypeCtrl = table.count(self.viewDataList) == 0 and ShowTypeControl.Empty or ShowTypeControl.Content
	self.bindData.showTypeCtrl = showTypeCtrl

	if isRequestFirstPage then
		self:CheckItemVisible()
	end
end

function M:RefreshItemView(args)
	self.listPageEntity:UpdateData(args)

	local button = self.buttonMap[args.id]

	if button then
		local data = self.listPageEntity:GetDataById(args.id)

		gSocialNetworkUtils.RefreshMomentItem(button, data)
	end
end

function M:FollowItemSuccess(roleInfo)
	local roleId = roleInfo.roleId
	local dataMap = self.listPageEntity:GetDataMap()

	for _, data in pairs(dataMap) do
		if data.roleInfo.roleId == roleId then
			data.roleInfo.isFollow = roleInfo.isFollow
		end
	end

	self:RefreshContentListView()
end

function M:OnDynamicRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.listPageEntity:GetDataByIndex(luaIndex)
	data.isLastOne = luaIndex == self.listPageEntity.totalCount

	gSocialNetworkUtils.RefreshMomentItem(btn, data, true)

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	store.layout:ForceRebuildLayoutImmediate()
end

function M:OnCollectionSuccess(args)
	self:RefreshItemView(args)
end

function M:ClearAndRefreshData()
	self:GetRequestDataList(1)
end

function M:OnUpdate()
	if self.isScrolling then
		self.timer = self.timer or 0
		self.timer = self.timer + Time.deltaTime

		if gClientConst.YanJieScrollIngCheckInterval <= self.timer then
			self:CheckItemVisible()

			self.timer = 0
		end
	else
		self.timer = nil
	end
end

function M:OnClose()
	self.buttonMap = nil
	self.isScrolling = nil
	self.currentMaxCsIndex = nil
end
