-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterScrollStore.lua
-- Decompiled from: 01799_HotCenterScrollStore.lua_4310189259ec.luajit

C_HotCenterScrollStore = DefClass("C_HotCenterScrollStore", C_HotCenterScrollStore, C_StoreGroup)
GroupName2Class.HotCenterScrollStore = C_HotCenterScrollStore
local M = C_HotCenterScrollStore
local CollectionCountryConfig = LTConfig.CollectionCountryConfig
local InspireHubConfig = LTConfig.InspireHubConfig

local SetWidgetActive = function(widget, isActive)
	if widget and widget.SetActive then
		widget.SetActive(widget, isActive)
	end
end

local GetRankColorCtrl = function(rank)
	if rank ~= 1 then
		return 0
	end

	if rank ~= 2 then
		return 1
	end

	if rank ~= 3 then
		return 2
	end

	return 3
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curCountryId = nil
	self.mainType = gClientConst.HotCenterType.Main
	self.recommendListData = {}
	self.rankColumnData = {}
	self.bigCategoryData = nil
	self.smallCategoryData = nil
	self.unfoldRecommendId = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SYNC_PLAYER_FAN_INFO] = self.CreateAction(self, "RefreshCommonWidget"),
		[gEventConstants.ON_HOT_CENTER_HOME_DYNAMIC_DATA_REFRESH] = self.CreateAction(self, "OnHomeDynamicDataRefresh"),
		[gEventConstants.ON_HOT_CENTER_RECOMMEND_ITEM_CLICK] = self.CreateAction(self, "OnRecommendItemClick")
	}
end

M.RegisterWidget = function(self)
	self.bindData.recommendList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRecommendItem")
	self.bindData.rankColumnList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRankColumnItem")
	self.bindData.bigTab.luaClick = self.CreateActionWithArgs(self, "OnStandaloneCardClick", true)
	self.bindData.smallTab.luaClick = self.CreateActionWithArgs(self, "OnStandaloneCardClick", false)

	if self.bindData.changeBtn then
		self.bindData.changeBtn.luaClick = self.CreateAction(self, "OnChangeBtnClick")
	end
end

M.ShowPanel = function(self, data)
	self.mainType = data and data.mainType or gClientConst.HotCenterType.Main

	self:RefreshPage(data)
end

M.RefreshPage = function(self, data)
	self.RefreshCountry(self, data)
	self.RefreshBaseInfo(self)
	self.RefreshStandaloneCards(self)
	self.RefreshCommonWidget(self)
	self.RefreshRecommendList(self)
	self.RefreshRankColumnList(self)
end

M.RefreshCountry = function(self, data)
	local targetCountryId = data and data.countryId or nil

	if targetCountryId and CollectionCountryConfig.GetConfig(targetCountryId) then
		self.curCountryId = targetCountryId

		return
	end

	if self.curCountryId and CollectionCountryConfig.GetConfig(self.curCountryId) then
		return
	end

	self.curCountryId = self.GetDefaultCountryId(self)
end

M.GetDefaultCountryId = function(self)
	return gHotCenterManager:GetDefaultHomeCountryId()
end

M.RefreshBaseInfo = function(self)
	local cfg = self.curCountryId and CollectionCountryConfig.GetConfig(self.curCountryId)

	if not cfg then
		self.bindData.cityTitle = ""
		self.bindData.cityDesc = ""

		return
	end

	self.bindData.cityTitle = cfg.Name or ""
	self.bindData.cityDesc = cfg.InspireHubDes or ""
end

M.RefreshStandaloneCards = function(self)
	local list = gHotCenterManager:GetStandaloneCategoryList(self.curCountryId, true) or {}
	local bigData, smallData = nil

	for _, data in ipairs(list) do
		if not bigData and data.tIndex ~= 0 then
			bigData = data
		elseif not smallData and data.tIndex ~= 1 then
			smallData = data
		end
	end

	for _, data in ipairs(list) do
		if not bigData then
			bigData = data
		elseif not smallData and (not bigData or data.id == bigData.id) then
			smallData = data
		end
	end

	self.bigCategoryData = bigData
	self.smallCategoryData = smallData

	self:RefreshStandaloneCard(self.bindData.bigTab, bigData)
	self:RefreshStandaloneCard(self.bindData.smallTab, smallData)
	SetWidgetActive(self.bindData.guideRoot, bigData == nil or smallData == nil)
end

M.RefreshStandaloneCard = function(self, widget, data)
	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, widget)

	if not store then
		return
	end

	if not data then
		store.label = ""

		return
	end

	local cfg = InspireHubConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	store.label = data.label or ""
	store.lockCtrl = data.unlocked and 0 or 1
	store.bg = cfg.PlayImage
	store.guideID = cfg.GuideId
end

M.RefreshCommonWidget = function(self)
	gHotCenterManager.RenderFansData(self.bindData.fansWidget)
	gHotCenterManager:RenderPopularityData(self.bindData.popularityWidget)
	gHotCenterManager:RenderMainPhoneSevenDaysPopularityData(self.bindData.popularityWidget)
	gHotCenterManager.RenderRewardData(self.bindData.rewardWidget)
end

M.RefreshRecommendList = function(self)
	self.recommendListData = gHotCenterManager:GetHomeDailyRecommendDisplayData(self.curCountryId) or {}
	local hasUnfoldItem = false

	for _, data in ipairs(self.recommendListData) do
		if self.unfoldRecommendId and data.id ~= self.unfoldRecommendId then
			hasUnfoldItem = true
		end
	end

	if not hasUnfoldItem then
		self.unfoldRecommendId = nil
	end

	for _, data in ipairs(self.recommendListData) do
		data.isFold = data.id == self.unfoldRecommendId
	end

	self.bindData.recommendList:SetSimpleList(#self.recommendListData)
	SetWidgetActive(self.bindData.dailyRoot, #self.recommendListData >= 0)
	SetWidgetActive(self.bindData.changeBtn, #self.recommendListData <= 0 and gHotCenterManager:CanRefreshHomeDailyRecommendDisplayData(self.curCountryId))
end

M.RefreshRankColumnList = function(self)
	self.rankColumnData = gHotCenterManager:GetHomeRankDisplayData(self.curCountryId) or {}

	self.bindData.rankColumnList:SetSimpleList(#self.rankColumnData)
end

M.OnSimpleRenderRecommendItem = function(self, btn, index)
	local data = self.recommendListData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local isFold = data.isFold == false
	store.bg = data.bg
	store.title = data.title
	store.desc = isFold and (data.shortDesc or "") or data.fullDesc or ""
	store.foldCtrl = isFold and 1 or 0

	if store.button then
		store.button.luaClick = self.CreateActionWithArgs(self, "OnRecommendButtonClick", data.id)
	end

	if store.starList then
		store.starList:SetSimpleList(data.starCount or 0)
	end
end

M.OnSimpleRenderRankColumnItem = function(self, btn, index)
	local data = self.rankColumnData[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local rankList = data.rankList or {}
	store.title = data.title or ""

	if not store.rankItemList then
		return
	end

	store.rankItemList.luaSimpleRenderItem = function(item, itemIndex)
		self:OnSimpleRenderRankItem(rankList, item, itemIndex)
	end

	store.rankItemList:SetSimpleList(#rankList)
end

M.OnSimpleRenderRankItem = function(self, rankList, btn, index)
	local data = rankList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.rank = tostring(data.rank or "")
	store.name = data.name or ""
	store.playCount = data.playCount or ""
	store.colorCtrl = GetRankColorCtrl(data.rank or 0)
end

M.OnStandaloneCardClick = function(self, isBigCard)
	local data = isBigCard and self.bigCategoryData or self.smallCategoryData

	if not data or not data.unlocked then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_SWITCH_SUB_PANEL, {
		mainType = gClientConst.HotCenterType.Main,
		subType = gClientConst.HotCenterSubType.Main,
		selectTab = data.id
	})
end

M.OnRecommendButtonClick = function(self, recommendId)
	if not recommendId then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_RECOMMEND_ITEM_CLICK, {
		id = recommendId
	})
end

M.OnChangeBtnClick = function(self)
	gHotCenterManager:RefreshHomeDailyRecommendDisplayData(self.curCountryId)

	self.unfoldRecommendId = nil

	self:RefreshRecommendList()
end

M.OnHomeDynamicDataRefresh = function(self, eventId, args)
	if args and args.countryId and args.countryId == self.curCountryId then
		return
	end

	self.RefreshRecommendList(self)
	self.RefreshRankColumnList(self)
end

M.OnRecommendItemClick = function(self, eventId, args)
	local recommendId = args and args.id or nil

	if not recommendId then
		return
	end

	if self.unfoldRecommendId ~= recommendId then
		self.unfoldRecommendId = nil
	else
		self.unfoldRecommendId = recommendId
	end

	self.RefreshRecommendList(self)
end
