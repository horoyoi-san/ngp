C_YanjieNewSearchPanel = DefClass("C_YanjieNewSearchPanel", C_YanjieNewSearchPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewSearchPanel = C_YanjieNewSearchPanel
local M = C_YanjieNewSearchPanel
local MaxSearchCount = 5
local ShowTypeControl = {
	Trend = 0,
	Moment = 1
}

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.maskButton.luaClick = self:CreateAction("OnMaskClick")
	self.bindData.searchButton.luaRelease = self:CreateAction("OnSearchClick")
	self.bindData.adList.luaRenderItem = self:CreateAction("OnAdRenderItem")
	self.bindData.adList.luaClick = self:CreateAction("OnAdImageClick")
	self.bindData.adList.luaSelectedChanged = self:CreateAction("OnAdImageChanged")
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction("OnTabRenderItem")
	self.bindData.tabList.luaSelectedChanged = self:CreateAction("OnTabListChange")
	self.bindData.tabContentList.luaSimpleRenderItem = self:CreateAction("OnTabContentRenderItem")
	self.bindData.tabContentList.luaLayoutSet = self:CreateAction("OnTabContentListLayoutSet")
	self.bindData.leftBtn.luaClick = self:CreateActionWithArgs("OnStep", -1)
	self.bindData.rightBtn.luaClick = self:CreateActionWithArgs("OnStep", 1)
	self.bindData.searchExitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.tabContentList.onGetTIndex = self:CreateAction("OnTabContentGetTIndex")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST] = function (_, info)
			self:RefreshTrendListView(info)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_AREA_CATEGORY_LIST] = function (_, dataList)
			self:RefreshAreaCategoryListView(dataList)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_RANDOM] = function (_, info)
			self:RefreshAreaCategoryListView(info)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_CATEGORY_DETAIL_LIST] = function (_, info)
			self.socialNetworkScrollView.RefreshContentListView(info)
		end
	}
end

function M:PlayPanelAnimation()
	if self.panelArgs then
		if self.panelArgs.lastShowType == gClientConst.YanJieShowType.Detail then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotINbackDetail")
		end

		self.panelArgs.lastShowType = nil
	end
end

function M:InitModel(args)
	M.base.InitModel(self, args)

	self.TAB_TYPE = {
		HOT = 1,
		RECOMMEND = 2
	}
	self.TAB_CONTENT_LIST_TEMPLATE = {
		HOT = 0,
		REFRESH = 2,
		RECOMMEND = 1
	}

	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.SearchPage)

	self.trendListPageEntity = gListPageEntity.new()
	local trendData = args and args.trendData

	self.trendListPageEntity:UpdateDataList(trendData)
	self:GetTrendList()
	self:GetAreaTrendList()
end

function M:InitView(args)
	self.bindData.searchKeyword = LTConfig.TextScriptTextConfig.GetConfig(89900991).Text

	self:SetTrendNodeActive(true)

	self.bindData.showTypeCtrl = ShowTypeControl.Trend
	self.momentList = args.momentList or self.SubGroup.CommonYanjieListTemplate

	function self.momentList.GetList(pageIndex, pageCount, callback)
		gSocialNetworkUtils.GetSocialNetworkListByTopicId(self.trendId, pageIndex, pageCount, callback)
	end

	function self.momentList.itemClickCallback()
		local animationName = "S_Vx_S_YanjieSearchPanel_HotINtoDetail"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

		self.bindData.rootWidget.activeCtrlDelay = clipTime
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_open")
	self:RefreshAdListView()
	self:RefreshTabListView()
end

function M:RefreshTabListView()
	self.tabViewDataList = self:GetTabViewDataList()

	self.bindData.tabList:SetSimpleList(#self.tabViewDataList)
	self.bindData.tabList:SetItemSelected(0, true)
	self.bindData.tabList:SelectItem(0, true)
end

function M:GetTabViewDataList()
	return {
		{
			selected = true,
			textId = 89901183,
			typeId = self.TAB_TYPE.HOT
		},
		{
			textId = 89900983,
			typeId = self.TAB_TYPE.RECOMMEND
		}
	}
end

function M:GetTrendList()
	if self.trendListPageEntity:GetViewDataCount() > 0 then
		return
	end

	local pageIndex = 1
	local pageSize = self.trendListPageEntity.pageSize

	gSocialNetworkUtils.GetTrendList(pageIndex, pageSize)
end

function M:RefreshTrendListView(info)
	self.trendListPageEntity:UpdateDataList(info)
	self:OnTabListChange()
end

function M:GetAreaTrendList()
	local areaId = gClientUtils.GetPlayerAreaId()

	gSocialNetworkUtils.GetTrendRandomByAreaId(areaId)
end

function M:OnSearchClick()
	self:SetTrendNodeActive(not self.bindData.trendNodeActive)
end

function M:OnRefreshClick()
	gSocialNetworkUtils.GetTrendRandom()
end

function M:OnOptionClick(data)
	local trendId = data.trendId
	local keyword = data.keyword

	self:ShowMomentList(trendId, keyword)
	self:SetTrendNodeActive(false)
end

function M:ShowMomentList(trendId, keyword)
	self.trendId = trendId
	self.bindData.searchKeyword = keyword
	self.bindData.showTypeCtrl = ShowTypeControl.Moment
	self.bindData.showResultControl = 1

	self.momentList:ClearAndRefreshData()
	gMessageManager:SendMessage(gEventConstants.ON_YAN_JIE_SEARCH_RESULT_SHOW)
end

function M:RefreshAdListView()
	local imageId = LTConfig.TuiteConfig.SAdvertisement
	local imageList = {}

	table.insert(imageList, {
		imageId = imageId
	})
	self.bindData.adList:SetList(imageList)
	self.bindData.adRoundList:SetList(imageList)
	self.bindData.adRoundList:SelectItem(0)
end

function M:OnAdRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.imageId = data.imageId
end

function M:OnAdImageClick()
	return
end

function M:OnAdImageChanged()
	self.bindData.adRoundList:SelectItem(self.bindData.adList.selectedIndex)
end

function M:OnMaskClick()
	return
end

function M:OnStep(step)
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = self.bindData.tabList.itemData.Count

	if index < 0 then
		index = itemCount - 1
	elseif itemCount <= index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

function M:OnTabRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.name = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
end

function M:OnTabListChange()
	local itemData = self.tabViewDataList[self.bindData.tabList.selectedIndex + 1]
	self.contentViewDataList = self:GetTabContentViewDataList(itemData.typeId)

	function self.bindData.tabContentList.onGetTIndex(csIndex)
		local luaIndex = csIndex + 1
		local data = self.contentViewDataList[luaIndex]

		return data.tIndex
	end

	self.bindData.tabContentList:SetSimpleList(#self.contentViewDataList)
end

function M:GetTabContentViewDataList(typeId)
	local viewDataList = {}

	if typeId == self.TAB_TYPE.HOT then
		viewDataList = self.trendListPageEntity:GetViewDataList()

		for _, viewData in ipairs(viewDataList) do
			viewData.tIndex = self.TAB_CONTENT_LIST_TEMPLATE.HOT
		end
	elseif typeId == self.TAB_TYPE.RECOMMEND then
		local dataList = self.searchDataList or {}

		for index, data in ipairs(dataList) do
			if index <= MaxSearchCount then
				table.insert(viewDataList, {
					tIndex = self.TAB_CONTENT_LIST_TEMPLATE.RECOMMEND,
					keyword = data.name,
					trendId = data.id
				})
			end
		end

		table.insert(viewDataList, {
			tIndex = self.TAB_CONTENT_LIST_TEMPLATE.REFRESH
		})
	end

	return viewDataList
end

function M:OnTabContentListLayoutSet()
	self.bindData.tabContentList:SetNavSelectToTop()
end

function M:OnTabContentRenderItem(btn, csIndex)
	local data = self.contentViewDataList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if data.tIndex == self.TAB_CONTENT_LIST_TEMPLATE.HOT then
		local trendData = data.listPageDataKeyValuePair
		local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(trendData.id)
		store.name = tuiteTopicCfg and tuiteTopicCfg.TypeName or trendData.name
		store.hotCount = gSocialNetworkUtils.GetCountFormat(trendData.hot)
		local areaId = tuiteTopicCfg.areaId
		local collectionCfg = LTConfig.CollectionBlockConfig.GetConfig(areaId)
		local areaName = collectionCfg and collectionCfg.BlockName or ""
		store.areaName = areaName
		local keyword = tuiteTopicCfg and tuiteTopicCfg.TypeName or data.keyword

		function store.button.luaClick()
			self:SetTrendNodeActive(false)
			self:ShowMomentList(trendData.id, keyword)
		end

		return
	end

	if data.tIndex == self.TAB_CONTENT_LIST_TEMPLATE.RECOMMEND then
		local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(data.trendId)
		store.title = tuiteTopicCfg and tuiteTopicCfg.TypeName or data.keyword
		store.button.luaClick = self:CreateActionWithArgs(self.OnOptionClick, data)
	elseif data.tIndex == self.TAB_CONTENT_LIST_TEMPLATE.REFRESH then
		store.button.luaClick = self:CreateAction(self.OnRefreshClick)
	end
end

function M:SetTrendNodeActive(isActive)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = isActive and self.bindData.trendArea or self.bindData.rootArea
	self.bindData.trendNodeActive = isActive

	self.bindData.fullScreenButton:SetActive(isActive)
end

function M:OnRefreshClick()
	gSocialNetworkUtils.GetTrendRandom()
end

function M:RefreshAreaCategoryListView(info)
	self.searchDataList = info.list
	local selectedItem = self.tabViewDataList[self.bindData.tabList.selectedIndex + 1]

	if selectedItem.typeId == self.TAB_TYPE.RECOMMEND then
		self.contentViewDataList = self:GetTabContentViewDataList(selectedItem.typeId)

		self.bindData.tabContentList:SetSimpleList(#self.contentViewDataList)
	end
end

function M:OnTabContentGetTIndex(csIndex)
	local luaIndex = csIndex + 1
	local data = self.contentViewDataList[luaIndex]

	return data.tIndex
end

function M:OnExitClick()
	if self.bindData.trendNodeActive and self.bindData.showResultControl == 1 then
		self:SetTrendNodeActive(false)

		return
	end

	self.panelArgs = nil
	self.bindData.showResultControl = 0

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_NEW_SEARCH_PANEL_CLOSE)
end
