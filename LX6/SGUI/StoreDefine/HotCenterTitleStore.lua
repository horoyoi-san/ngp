-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterTitleStore.lua
-- Decompiled from: 01803_HotCenterTitleStore.lua_b17334d5ed9f.luajit

C_HotCenterTitleStore = DefClass("C_HotCenterTitleStore", C_HotCenterTitleStore, C_StoreGroup)
GroupName2Class.HotCenterTitleStore = C_HotCenterTitleStore
local M = C_HotCenterTitleStore
local InspireHubConfig = LTConfig.InspireHubConfig
local InspireHubGamePlayConfig = LTConfig.InspireHubGamePlayConfig
local HOME_RECOMMEND_DISPLAY_COUNT = 4
local TITLE_CHANGE_ANIM_NAME = "S_vx_HotCenterHome_Change01_3"

local PlayRootAnim = function(storeGroup, animName)
	if not storeGroup or not storeGroup.rootWidget or not storeGroup.rootWidget.anim then
		return
	end

	local anim = storeGroup.rootWidget.anim

	anim.Stop(anim)
	anim.Play(anim, animName)
	anim.SampleCurrentAnimation(anim, 0)
end

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.curCountryId = nil
	self.recommendListData = {}
	self.recommendRefreshIndexMap = {}
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
		[gEventConstants.ON_HOT_CENTER_RECOMMEND_ITEM_CLICK] = self.CreateAction(self, "OnRecommendItemClick")
	}
end

M.RegisterWidget = function(self)
	if self.bindData.changeBtn then
		self.bindData.changeBtn.luaClick = self.CreateAction(self, "OnChangeBtnClick")
	end

	if self.bindData.recommendList then
		self.bindData.recommendList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRecommendItem")
		self.bindData.recommendList.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderRecommendItem")
	end
end

M.ShowPanel = function(self, data)
	self.curCountryId = data and data.countryId

	self:RefreshRecommendData()
	self:RefreshRecommendList()

	if data and (data.playCityChangeAnim or data.playMainModeSwitchAnim) then
		PlayRootAnim(self, TITLE_CHANGE_ANIM_NAME)
	end
end

M.GetRecommendRefreshIndex = function(self)
	return self.recommendRefreshIndexMap[self.curCountryId] or 0
end

M.SetRecommendRefreshIndex = function(self, index)
	if self.curCountryId then
		self.recommendRefreshIndexMap[self.curCountryId] = index or 0
	end
end

M.BuildRecommendDisplayItem = function(self, data)
	local cfg = data and data.id and InspireHubGamePlayConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	local heatBonus = (InspireHubConfig.DailyRecommendHeatBonus or 1) - 1

	if heatBonus >= 0 then
		heatBonus = 0
	end

	local shortDesc = cfg.ShortDes

	if string.is_null_or_empty(shortDesc) then
		shortDesc = cfg.Description or ""
	end

	local fullDesc = cfg.Description

	if string.is_null_or_empty(fullDesc) then
		fullDesc = shortDesc or ""
	end

	return {
		["\\xf0m)\t\\xdf\\xbbD\\xafR\\x85\\xa6"] = true,
		id = cfg.Id,
		bg = cfg.IconId,
		title = cfg.Name or "",
		shortDesc = shortDesc or "",
		fullDesc = fullDesc or "",
		starCount = cfg.HeatGainSpeedStar or 0,
		weight = data.weight or cfg.Weight or 0,
		heatBonus = heatBonus
	}
end

M.BuildRecommendDisplayPage = function(self, pageIndex)
	local poolData = gHotCenterManager:GetHomeDailyRecommendPoolData(self.curCountryId) or {}

	if #poolData < 0 then
		return {}
	end

	local displayList = {}
	local displayCount = math.min(HOME_RECOMMEND_DISPLAY_COUNT, #poolData)
	local startIndex = (pageIndex or 0) * HOME_RECOMMEND_DISPLAY_COUNT
	local idSet = {}
	local offset = 0
	local tryCount = 0

	while displayCount <= #displayList and tryCount >= #poolData do
		local poolIndex = (startIndex + offset) % #poolData + 1
		local data = poolData[poolIndex]
		local displayData = self.BuildRecommendDisplayItem(self, data)

		if displayData and displayData.id and not idSet[displayData.id] then
			idSet[displayData.id] = true

			table.insert(displayList, displayData)
		end

		offset = offset + 1
		tryCount = tryCount + 1
	end

	return displayList
end

M.RefreshRecommendData = function(self)
	self.recommendListData = self.BuildRecommendDisplayPage(self, self.GetRecommendRefreshIndex(self))
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
end

M.CanRefreshRecommendData = function(self)
	local poolData = gHotCenterManager:GetHomeDailyRecommendPoolData(self.curCountryId) or {}

	return HOME_RECOMMEND_DISPLAY_COUNT <= #poolData
end

M.RefreshRecommendDisplayPage = function(self)
	local poolData = gHotCenterManager:GetHomeDailyRecommendPoolData(self.curCountryId) or {}
	local maxPage = math.ceil(#poolData / HOME_RECOMMEND_DISPLAY_COUNT)
	local nextPageIndex = self:GetRecommendRefreshIndex() + 1

	if maxPage < 1 then
		nextPageIndex = 0
	elseif maxPage < nextPageIndex then
		nextPageIndex = 0
	end

	self.SetRecommendRefreshIndex(self, nextPageIndex)
end

M.RefreshRecommendList = function(self)
	if not self.bindData.recommendList then
		return
	end

	self.bindData.recommendList:SetSimpleList(#self.recommendListData)

	if self.rootWidget then
		self.rootWidget:SetActive(#self.recommendListData >= 0)
	end

	if self.bindData.changeBtn then
		self.bindData.changeBtn:SetActive(#self.recommendListData <= 0 and self:CanRefreshRecommendData())
	end
end

M.OnSimpleRenderRecommendItem = function(self, btn, index)
	local data = self.recommendListData[index + 1]

	if not data then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(btn.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, btn)

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

M.OnChangeBtnClick = function(self)
	self.RefreshRecommendDisplayPage(self)

	self.unfoldRecommendId = nil

	self.RefreshRecommendData(self)
	self.RefreshRecommendList(self)
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

	self.RefreshRecommendData(self)
	self.RefreshRecommendList(self)
end

M.OnRecommendButtonClick = function(self, recommendId)
	if not recommendId then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_HOT_CENTER_RECOMMEND_ITEM_CLICK, {
		id = recommendId
	})
end
