C_YanjieSearchPanelStore = DefClass("C_YanjieSearchPanelStore", C_YanjieSearchPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieSearchPanelStore = C_YanjieSearchPanelStore
local M = C_YanjieSearchPanelStore
local MaxSearchCount = 5
local ShowTypeControl = {
	Trend = 0,
	Moment = 1
}
local TemplateType = {
	Refresh = 1,
	Option = 0
}
local PopUpShowType = {
	Hide = 0,
	Show = 1
}

function M:OnAwake()
	self.bindData.fullScreenButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.trendList.luaSimpleRenderItem = self:CreateAction("OnTrendRenderItem")
	self.bindData.exitButton.luaClick = self:CreateAction("OnExitClick")
	self.bindData.maskButton.luaClick = self:CreateAction("OnMaskClick")
	self.bindData.searchButton.luaRelease = self:CreateAction("OnSearchClick")
	self.bindData.adList.luaRenderItem = self:CreateAction("OnAdRenderItem")
	self.bindData.adList.luaClick = self:CreateAction("OnAdImageClick")
	self.bindData.adList.luaSelectedChanged = self:CreateAction("OnAdImageChanged")
end

function M:GetMessageEvents()
	return {
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_LIST] = function (_, info)
			self:RefreshTrendListView(info)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_AREA_CATEGORY_LIST] = function (_, dataList)
			self:RefreshAreaCategoryListView(dataList)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_CATEGORY_DETAIL_LIST] = function (_, info)
			self.socialNetworkScrollView.RefreshContentListView(info)
		end,
		[gEventConstants.ON_REQUEST_SOCIAL_NETWORK_TREAD_RANDOM] = function (_, info)
			self:RefreshAreaCategoryListView(info)
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
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.SearchPage)

	self.trendListPageEntity = gListPageEntity.new()

	self:GetTrendList()
	self:GetAreaTrendList()

	local trendData = args and args.trendData

	self:RefreshTrendListView(trendData)
end

function M:InitView(_)
	self.bindData.showTypeCtrl = ShowTypeControl.Trend
	self.momentList = self.SubGroup.CommonYanjieListTemplate

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
end

function M:GetTrendList()
	local pageIndex = self.trendListPageEntity:GetCurrentPageIndex() + 1
	local pageSize = self.trendListPageEntity.pageSize

	gSocialNetworkUtils.GetTrendList(pageIndex, pageSize)
end

function M:RefreshTrendListView(info)
	self.trendListPageEntity:UpdateDataList(info)

	local viewDataList = self.trendListPageEntity:GetViewDataList()

	self.bindData.trendList:SetSimpleList(#viewDataList)
end

function M:GetAreaTrendList()
	local areaId = gClientUtils.GetPlayerAreaId()

	gSocialNetworkUtils.GetTrendRandomByAreaId(areaId)
end

function M:OnTrendRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.trendListPageEntity:GetDataByIndex(luaIndex)
	local trendData = data.listPageDataKeyValuePair
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(trendData.id)
	store.name = tuiteTopicCfg and tuiteTopicCfg.TypeName or trendData.name
	store.hotCount = gSocialNetworkUtils.GetCountFormat(trendData.hot)
	local areaId = trendData.areaId
	local collectionCfg = LTConfig.CollectionBlockConfig.GetConfig(areaId)
	local areaName = collectionCfg and collectionCfg.BlockName or ""
	store.areaName = areaName
	local keyword = tuiteTopicCfg and tuiteTopicCfg.TypeName or data.keyword

	function store.button.luaClick()
		self:ShowMomentList(trendData.id, keyword)
	end
end

function M:RefreshAreaCategoryListView(info)
	self.hasGetAreaCategorySuccess = true
	local videDataList = {}
	local dataList = info.list

	for index, data in ipairs(dataList) do
		if index <= MaxSearchCount then
			table.insert(videDataList, {
				tIndex = TemplateType.Option,
				keyword = data.name,
				trendId = data.id
			})
		end
	end

	table.insert(videDataList, {
		tIndex = TemplateType.Refresh
	})

	local popUpStore = gStoreManager:GetStoreGroup(self.bindData.popUp.Store):GetStoreByWidget(self.bindData.popUp)
	popUpStore.list.luaSimpleRenderItem = self:CreateAction(self.OnTrendOptionRenderItem)

	popUpStore.list:SetSimpleList(#videDataList)
end

function M:OnSearchClick()
	if self.hasGetAreaCategorySuccess then
		self.bindData.showPopUpCtrl = PopUpShowType.Show
	else
		self:GetAreaTrendList()
	end
end

function M:OnTrendOptionRenderItem(btn, csIndex, data)
	if csIndex == 0 then
		btn:Navigate(btn)

		function btn.luaTryChangePage()
			local currentActiveArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea
			local currentActiveContent = currentActiveArea and currentActiveArea.CurrentActiveContent

			if gClientUtils.IsNil(currentActiveContent) or currentActiveContent.transform.parent ~= btn.transform.parent then
				btn:Navigate(btn)
			end
		end
	end

	if data.tIndex == TemplateType.Option then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(data.trendId)
		store.title = tuiteTopicCfg and tuiteTopicCfg.TypeName or data.keyword
		store.button.luaClick = self:CreateActionWithArgs(self.OnOptionClick, data)
	elseif data.tIndex == TemplateType.Refresh then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.button.luaClick = self:CreateAction(self.OnRefreshClick)
	end
end

function M:OnRefreshClick()
	gSocialNetworkUtils.GetTrendRandom()
end

function M:OnOptionClick(data)
	local trendId = data.trendId
	local keyword = data.keyword

	self:ShowMomentList(trendId, keyword)

	self.bindData.showPopUpCtrl = PopUpShowType.Hide
end

function M:ShowMomentList(trendId, keyword)
	if self.bindData.showTypeCtrl ~= ShowTypeControl.Moment then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotIN")
	end

	self.trendId = trendId
	self.bindData.searchKeyword = keyword
	self.bindData.showTypeCtrl = ShowTypeControl.Moment

	self.momentList:ClearAndRefreshData()
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
	self.bindData.showPopUpCtrl = PopUpShowType.Hide
end

function M:OnExitClick()
	SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.bindData.searchButton

	if self.bindData.showPopUpCtrl == PopUpShowType.Show then
		self.bindData.showPopUpCtrl = PopUpShowType.Hide

		return
	end

	if self.bindData.showTypeCtrl == ShowTypeControl.Moment then
		self.bindData.showTypeCtrl = ShowTypeControl.Trend

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotOut")

		self.bindData.searchKeyword = LTConfig.TextScriptTextConfig.GetConfig(89900991).Text

		return
	end

	M.base.OnExitClick(self)
end

function M:OnExecuteExitAction()
	local closeAnimationName = "S_Vx_S_YanjieSearchPanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
