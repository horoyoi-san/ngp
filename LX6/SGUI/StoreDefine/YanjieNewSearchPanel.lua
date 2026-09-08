-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\YanjieNewSearchPanel.lua
-- Decompiled from: 01916_YanjieNewSearchPanel.lua_16950317acb8.luajit

C_YanjieNewSearchPanel = DefClass("C_YanjieNewSearchPanel", C_YanjieNewSearchPanel, C_PhoneAppBaseStoreGroup)
GroupName2Class.YanjieNewSearchPanel = C_YanjieNewSearchPanel
local M = C_YanjieNewSearchPanel
local ShowTypeControl = {
	["y\\xbc\\xa7\\xa1\\xb2"] = 0,
	["1G\\x9c\\x8b\\x8dU"] = 1
}

M.OnAwake = function(self)
	self.bindData.fullScreenButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.exitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.maskButton.luaClick = self.CreateAction(self, "OnMaskClick")
	self.bindData.searchButton.luaRelease = self.CreateAction(self, "OnSearchClick")
	self.bindData.adList.luaSimpleRenderItem = self.CreateAction(self, "OnAdRenderItem")
	self.bindData.adList.luaSimpleClick = self.CreateAction(self, "OnAdImageClick")
	self.bindData.adList.luaSelectedChanged = self.CreateAction(self, "OnAdImageChanged")
	self.bindData.searchExitButton.luaClick = self.CreateAction(self, "OnExitClick")
	self.bindData.tabContentList.luaSimpleRenderItem = self.CreateAction(self, "OnTabContentRenderItem")
end

M.GetMessageEvents = function(self)
	return {
		[gEventConstants.ON_YANJIE_CONTENT_CLOSE] = function ()
			if self.panelArgs then
				gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_HotINbackDetail")
			end
		end
	}
end

M.InitModel = function(self, args)
	M.base.InitModel(self, args)

	self.backToShowType = args and args.backToShowType
	self.recommendTuiteIdList = args.recommendTuiteIdList
	self.TAB_CONTENT_LIST_TEMPLATE = {
		["\\xa6GR"] = 0,
		["\\xeb\\xfe2/;\\xd9"] = 2,
		["qbOFc34<"] = 1
	}

	gSocialNetworkUtils.AskTwitterPageOpen(UX.Game.TwitterPageType.SearchPage)

	self.trendListPageEntity = gListPageEntity.new()
	local trendData = args and args.trendData

	self.trendListPageEntity:UpdateDataList(trendData)
end

M.InitView = function(self, args)
	self.bindData.searchKeyword = LTConfig.TextScriptTextConfig.GetConfig(89900991).Text

	self:SetTrendNodeActive(true)

	self.bindData.showTypeCtrl = ShowTypeControl.Trend
	self.momentList = args.momentList or self.SubGroup.CommonYanjieListTemplate
	self.momentList.enableContentShowType = true

	self.momentList.itemClickCallback = function()
		local animationName = "S_Vx_S_YanjieSearchPanel_HotINtoDetail"
		local clipTime = gClientUtils.GetAnimationClipLength(self.bindData.panelAnimation, animationName)

		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, animationName)

		self.bindData.rootWidget.activeCtrlDelay = clipTime
	end

	self.momentList.GetList = self:CreateAction("GetMomentList")

	if args.playAnimation then
		gCS.LuaUtils.PlayAnimationByName(self.bindData.panelAnimation, "S_Vx_S_YanjieSearchPanel_open")
	end

	self:RefreshAdListView()

	self.topicIdList = gSocialNetworkUtils.GetTopIdList(self.recommendTuiteIdList)

	self.bindData.tabContentList.onGetTIndex = function(_)
		return 1
	end

	self.bindData.tabContentList:SetSimpleList(#self.topicIdList)

	if args and args.openTopicId then
		self.SetTrendNodeActive(self, false)

		local keyword = args.openTopicName

		if not keyword or keyword ~= "" then
			local topicCfg = LTConfig.TuiteTopicConfig.GetConfig(args.openTopicId)
			keyword = topicCfg and topicCfg.TypeName or ""
		end

		self:ShowMomentList(args.openTopicId, keyword)
	end
end

M.GetMomentList = function(self)
	return gSocialNetworkUtils.GetSocialNetworkListByTopicId(self.trendId)
end

M.OnSearchClick = function(self)
	self.SetTrendNodeActive(self, not self.bindData.trendNodeActive)
end

M.OnRefreshClick = function(self)
	gSocialNetworkUtils.GetTrendRandom()
end

M.OnOptionClick = function(self, data)
	local trendId = data.trendId
	local keyword = data.keyword

	self.ShowMomentList(self, trendId, keyword)
	self.SetTrendNodeActive(self, false)
end

M.ShowMomentList = function(self, trendId, keyword)
	self.trendId = trendId
	self.bindData.searchKeyword = keyword
	self.bindData.showTypeCtrl = ShowTypeControl.Moment
	self.bindData.showResultControl = 1

	self.momentList:ClearAndRefreshData()
	gMessageManager:SendMessage(gEventConstants.ON_YAN_JIE_SEARCH_RESULT_SHOW)
end

M.RefreshAdListView = function(self)
	local imageId = LTConfig.TuiteConfig.SAdvertisement
	local imageList = {}

	table.insert(imageList, {
		imageId = imageId
	})

	self._adListData = imageList

	self.bindData.adList:SetSimpleList(#self._adListData)
	self.bindData.adRoundList:SetSimpleList(#self._adListData)
	self.bindData.adRoundList:SelectItem(0)
end

M.OnAdRenderItem = function(self, btn, index)
	local data = self._adListData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.imageId = data.imageId
end

M.OnAdImageClick = function(self)
end

M.OnAdImageChanged = function(self)
	self.bindData.adRoundList:SelectItem(self.bindData.adList.selectedIndex)
end

M.OnMaskClick = function(self)
end

M.OnStep = function(self, step)
	local index = self.bindData.tabList.selectedIndex + step
	local itemCount = self.bindData.tabList.itemData.Count

	if index >= 0 then
		index = itemCount - 1
	elseif itemCount < index then
		index = 0
	end

	self.bindData.tabList:SelectItem(index)
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabViewDataList[luaIndex]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	store.name = LTConfig.TextScriptTextConfig.GetConfig(data.textId).Text
end

M.SetTrendNodeActive = function(self, isActive)
	SGUI.UNavigationMgr.Inst.CurrentActiveArea = isActive and self.bindData.trendArea or self.bindData.rootArea
	self.bindData.trendNodeActive = isActive

	self.bindData.fullScreenButton:SetActive(isActive)
end

M.OnRefreshClick = function(self)
	gSocialNetworkUtils.GetTrendRandom()
end

M.OnTabContentRenderItem = function(self, btn, csIndex)
	local topicId = self.topicIdList[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local tuiteTopicCfg = LTConfig.TuiteTopicConfig.GetConfig(topicId)

	if tuiteTopicCfg then
		store.title = tuiteTopicCfg.TypeName
		local keyword = tuiteTopicCfg.TypeName

		store.button.luaClick = function()
			self:SetTrendNodeActive(false)
			self:ShowMomentList(topicId, keyword)
		end

		return
	end

	print_error("@linminghe --- 眼界话题配置不存在", topicId)
end

M.OnExitClick = function(self)
	if self.bindData.trendNodeActive and self.bindData.showResultControl ~= 1 then
		self.SetTrendNodeActive(self, false)

		return
	end

	local backToShowType = self.backToShowType
	self.backToShowType = nil

	gMessageManager:SendMessage(gEventConstants.ON_YANJIE_NEW_SEARCH_PANEL_CLOSE, {
		backToShowType = backToShowType
	})

	self.panelArgs = nil
	self.bindData.showResultControl = 0
end

M.ClearData = function(self)
	self.backToShowType = nil
end
