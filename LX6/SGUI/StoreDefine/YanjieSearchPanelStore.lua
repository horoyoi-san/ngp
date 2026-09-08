-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieSearchPanelStore.lua
-- Decompiled from: 01920_YanjieSearchPanelStore.lua_8deef110f585.luajit

C_YanjieSearchPanelStore = DefClass("C_YanjieSearchPanelStore", C_YanjieSearchPanelStore, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieSearchPanelStore = C_YanjieSearchPanelStore
local M = C_YanjieSearchPanelStore
local MaxSearchCount = 5
local ShowTypeControl = {
	["y\\xbc\\xa7\\xa1\\xb2"] = 0,
	["1G\\x9c\\x8b\\x8dU"] = 1
}
local TemplateType = {
	["\\xeb\\xde7\\xf9"] = 1,
	["3X\\x85\\x87\\x8cO"] = 0
}
local PopUpShowType = {
	["R+y^"] = 0,
	["I*rL"] = 1
}

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.trendList.luaSimpleRenderItem = self.CreateAction(self, "OnTrendRenderItem")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.maskButton.luaClick = self.CreateAction(self, "OnMaskClick")
	self.bindData.searchButton.luaRelease = self.CreateAction(self, "OnSearchClick")
	self.bindData.adList.luaRenderItem = self.CreateAction(self, "OnAdRenderItem")
	self.bindData.adList.luaClick = self.CreateAction(self, "OnAdImageClick")
	self.bindData.adList.luaSelectedChanged = self.CreateAction(self, "OnAdImageChanged")
end

M.GetMessageEvents = function(self)
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

M.PlayPanelAnimation = function(self)
	if self.panelArgs then
		if self.panelArgs.lastShowType ~= gClientConst.YanJieShowType.Detail then
			gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotINbackDetail")
		end

		self.panelArgs.lastShowType = nil
	end
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)
	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.SearchPage)

	self.trendListPageEntity = gListPageEntity.new()

	self:GetTrendList()
	self:GetAreaTrendList()

	local trendData = args and args.trendData

	self:RefreshTrendListView(trendData)
end

M.InitView = function(self, _)
	self.bindData.showTypeCtrl = ShowTypeControl.Trend
	self.momentList = self.SubGroup.CommonYanjieListTemplate

	self.momentList.itemClickCallback = function()
		local animationName = "S_Vx_S_YanjieSearchPanel_HotINtoDetail"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

		self.bindData.rootWidget.activeCtrlDelay = clipTime
	end

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_open")
	self.RefreshAdListView(self)
end

M.GetTrendList = function(self)
	local pageIndex = self.trendListPageEntity:GetCurrentPageIndex() + 1
	local pageSize = self.trendListPageEntity.pageSize

	gSocialNetworkUtils.GetTrendList(pageIndex, pageSize)
end

M.RefreshTrendListView = function(self, info)
	self.trendListPageEntity:UpdateDataList(info)

	local viewDataList = self.trendListPageEntity:GetViewDataList()

	self.bindData.trendList:SetSimpleList(#viewDataList)
end

M.GetAreaTrendList = function(self)
end

M.OnTrendRenderItem = function(self, btn, csIndex)
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

	store.button.luaClick = function()
		self:ShowMomentList(trendData.id, keyword)
	end
end

M.RefreshAreaCategoryListView = function(self, info)
	self.hasGetAreaCategorySuccess = true
	local videDataList = {}
	local dataList = info.list

	for index, data in ipairs(dataList) do
		if index < MaxSearchCount then
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

M.OnSearchClick = function(self)
	if self.hasGetAreaCategorySuccess then
		self.bindData.showPopUpCtrl = PopUpShowType.Show
	else
		self.GetAreaTrendList(self)
	end
end

M.OnTrendOptionRenderItem = function(self, btn, csIndex, data)
	if csIndex ~= 0 then
		btn.Navigate(btn, btn)

		btn.luaTryChangePage = function()
			local currentActiveArea = SGUI.UNavigationMgr.Inst.CurrentActiveArea
			local currentActiveContent = currentActiveArea and currentActiveArea.CurrentActiveContent

			if gClientUtils.IsNil(currentActiveContent) or currentActiveContent.transform.parent == btn.transform.parent then
				btn:Navigate(btn)
			end
		end
	end

	if data.tIndex ~= TemplateType.Option then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(data.trendId)
		store.title = tuiteTopicCfg and tuiteTopicCfg.TypeName or data.keyword
		store.button.luaClick = self:CreateActionWithArgs(self.OnOptionClick, data)
	elseif data.tIndex ~= TemplateType.Refresh then
		local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
		store.button.luaClick = self:CreateAction(self.OnRefreshClick)
	end
end

M.OnRefreshClick = function(self)
	gSocialNetworkUtils.GetTrendRandom()
end

M.OnOptionClick = function(self, data)
	local trendId = data.trendId
	local keyword = data.keyword

	self.ShowMomentList(self, trendId, keyword)

	self.bindData.showPopUpCtrl = PopUpShowType.Hide
end

M.ShowMomentList = function(self, trendId, keyword)
	if self.bindData.showTypeCtrl == ShowTypeControl.Moment then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotIN")
	end

	self.trendId = trendId
	self.bindData.searchKeyword = keyword
	self.bindData.showTypeCtrl = ShowTypeControl.Moment

	self.momentList:ClearAndRefreshData()
end

M.RefreshAdListView = function(self)
	local imageId = LTConfig.TuiteConfig.SAdvertisement
	local imageList = {}

	table.insert(imageList, {
		imageId = imageId
	})
end

M.OnAdRenderItem = function(self, btn, _, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.imageId = data.imageId
end

M.OnAdImageClick = function(self)
end

M.OnAdImageChanged = function(self)
	self.bindData.adRoundList:SelectItem(self.bindData.adList.selectedIndex)
end

M.OnMaskClick = function(self)
	self.bindData.showPopUpCtrl = PopUpShowType.Hide
end

M.OnExitClick = function(self)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea.CurrentActiveContent = self.bindData.searchButton

	if self.bindData.showPopUpCtrl ~= PopUpShowType.Show then
		self.bindData.showPopUpCtrl = PopUpShowType.Hide

		return
	end

	if self.bindData.showTypeCtrl ~= ShowTypeControl.Moment then
		self.bindData.showTypeCtrl = ShowTypeControl.Trend

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotOut")

		self.bindData.searchKeyword = LTConfig.TextScriptTextConfig.GetConfig(89900991).Text

		return
	end

	M.base.OnExitClick(self)
end

M.OnExecuteExitAction = function(self)
	local closeAnimationName = "S_Vx_S_YanjieSearchPanel_close"
	local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, closeAnimationName)
	self.bindData.rootWidget.activeCtrlDelay = clipTime

	gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, closeAnimationName)
	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_CONTENT_CLOSE)
end
