-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HotCenterDailyTotalStore.lua
-- Decompiled from: 01722_HotCenterDailyTotalStore.lua_27fcd68fcef6.luajit

C_HotCenterDailyTotalStore = DefClass("C_HotCenterDailyTotalStore", C_HotCenterDailyTotalStore, C_StoreGroup)
GroupName2Class.HotCenterDailyTotalStore = C_HotCenterDailyTotalStore
local M = C_HotCenterDailyTotalStore
local InspireHubConfig = LTConfig.InspireHubConfig
local InspireHubGamePlayConfig = LTConfig.InspireHubGamePlayConfig
local DEFAULT_HOME_RANK_DISPLAY_COUNT = 10

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
	self.rankColumnData = {}
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.RegisterWidget(self)
end

M.RegisterWidget = function(self)
	if not self.bindData.list then
		return
	end

	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRankColumnItem")
	self.bindData.list.luaDynamicRenderItem = self.CreateAction(self, "OnSimpleRenderRankColumnItem")
end

M.ShowPanel = function(self, data)
	self.curCountryId = data and data.countryId

	self:RefreshRankColumnData()

	if self.bindData.list then
		self.bindData.list:SetSimpleList(#self.rankColumnData)
	end
end

M.GetRankCategoryTitle = function(self, category)
	local names = InspireHubConfig.RankTabNames

	if names then
		return names[category] or ""
	end

	return ""
end

M.BuildRankItemData = function(self, data)
	local cfg = data and data.id and InspireHubGamePlayConfig.GetConfig(data.id)

	if not cfg then
		return
	end

	local rank = data.rank or 0

	return {
		id = data.id,
		rank = rank,
		name = cfg.Name or "",
		playCount = tostring(data.score or 0),
		rankCategory = data.rankCategory,
		isUp = data.isUp,
		score = data.score,
		baseScore = data.baseScore
	}
end

M.BuildRankColumnData = function(self, data, defaultCategory)
	local category = data and data.category or defaultCategory
	local result = {
		category = category,
		title = self:GetRankCategoryTitle(category),
		rankList = {}
	}
	slot5 = ipairs
	slot7 = data and data.rankList or {}

	for _, itemData in slot5(slot7) do
		local item = self.BuildRankItemData(self, itemData)

		if item then
			table.insert(result.rankList, item)
		end
	end

	return result
end

M.RefreshRankColumnData = function(self)
	local rawColumnData = gHotCenterManager:GetHomeRankDisplayData(self.curCountryId) or {}
	self.rankColumnData = {}

	for category = 1, 3 do
		table.insert(self.rankColumnData, self.BuildRankColumnData(self, rawColumnData[category], category))
	end
end

M.OnSimpleRenderRankColumnItem = function(self, widget, index)
	local data = self.rankColumnData[index + 1]

	if not data then
		return
	end

	local storeGroup = gStoreManager:GetStoreGroup(widget.Store)

	if not storeGroup then
		return
	end

	local store = storeGroup.GetStoreByWidget(storeGroup, widget)

	if not store then
		return
	end

	local rankList = data.rankList or {}
	local displayCount = math.min(#rankList, DEFAULT_HOME_RANK_DISPLAY_COUNT)
	store.title = data.title or ""

	if not store.rankItemList then
		return
	end

	store.rankItemList.luaSimpleRenderItem = self:CreateActionWithArgs("OnSimpleRenderRankItem", rankList)
	store.rankItemList.luaDynamicRenderItem = self:CreateActionWithArgs("OnSimpleRenderRankItem", rankList)

	store.rankItemList:SetSimpleList(displayCount)
end

M.OnSimpleRenderRankItem = function(self, rankList, btn, index)
	local data = rankList[index + 1]

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

	store.rank = tostring(data.rank or "")
	store.name = data.name or ""
	store.playCount = data.playCount or ""
	store.colorCtrl = GetRankColorCtrl(data.rank or 0)
end
