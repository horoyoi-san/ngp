-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\HouseFurniturePageStore.lua
-- Decompiled from: 01805_HouseFurniturePageStore.lua_62f7145f7aad.luajit

local HouseConfig = LTConfig.HouseConfig
local HouseBuildConfig = LTConfig.HouseBuildConfig
local HouseFurnitureTemplateConfig = LTConfig.HouseFurnitureTemplateConfig
local HouseFurnitureConfig = LTConfig.HouseFurnitureConfig
local FenestrationDataConfig = LTConfig.HouseWallDataFenestrationDataConfig
local EdgeTexDataConfig = LTConfig.HouseWallDataEdgeTexDataConfig
local FloorTexDataConfig = LTConfig.HouseWallDataFloorTexDataConfig
local ConsumableConfig = LTConfig.ConsumableConfig
C_HouseFurniturePageStore = DefClass("C_HouseFurniturePageStore", C_HouseFurniturePageStore, C_StoreGroup)
GroupName2Class.HouseFurniturePageStore = C_HouseFurniturePageStore
local M = C_HouseFurniturePageStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.houseId = nil
	self.houseCfg = nil
	self.itemRenderList = nil
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.parent = gStoreManager:GetStoreGroup("HousePropertyPanelStore")
end

M.OnGroupEnable = function(self)
end

M.OnEnable = function(self)
	self.houseId = self.parent and self.parent.selectedHouseId
	self.houseCfg = self.houseId and HouseConfig.GetConfig(self.houseId)

	self:RefreshView()
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItemListItem)
	self.bindData.itemList.luaDynamicRenderItem = self.CreateAction(self, self.OnRenderItemListItem)
end

M.OnClickBackBtn = function(self)
	if self.parent and self.parent.GoBackToDetailPage then
		self.parent:GoBackToDetailPage()
	end
end

M.RefreshView = function(self)
	if not self.houseCfg then
		return
	end

	self.bindData.houseNameText = self.houseCfg.Name or ""
	self.bindData.bgImageId = self.houseCfg.FurnitureListImage or 0

	self:BuildItemRenderList()
	self.bindData.itemList:SetSimpleList(#self.itemRenderList)
end

M.BuildItemRenderList = function(self)
	self.itemRenderList = {}
	local buildCfg = self.houseCfg.BuildId and HouseBuildConfig.GetConfig(self.houseCfg.BuildId)

	if not buildCfg then
		return
	end

	local mainTypeTitleList = HouseConfig.FurnitureMainType
	local groupsByMainType = {}

	local appendItem = function(furnitureId, count, showCount)
		local hfCfg = HouseFurnitureConfig.GetConfig(furnitureId)

		if hfCfg and hfCfg.IsHide then
			return
		end

		local consumableId = gHouseManager:GetConsumableIdByFurnitureId(furnitureId)

		if not consumableId then
			print_warn("HouseFurniturePageStore: 找不到 furnitureId 对应的 ConsumableId, 跳过, furnitureId=", furnitureId)

			return
		end

		local consumableCfg = ConsumableConfig.GetConfig(consumableId)
		local mainType = hfCfg and hfCfg.MainType or 0
		local group = groupsByMainType[mainType]

		if not group then
			local title = ""

			if mainTypeTitleList and mainTypeTitleList[mainType] then
				title = mainTypeTitleList[mainType].Name or ""
			end

			group = {
				mainType = mainType,
				title = title,
				furnitureList = {}
			}
			groupsByMainType[mainType] = group
		end

		table.insert(group.furnitureList, {
			consumableId = consumableId,
			bindId = furnitureId,
			count = count,
			showCount = showCount,
			quality = consumableCfg and consumableCfg.Quality or 0
		})
	end

	local furnitureCount = {}
	local visited = {}

	local collectTemplate = function(templateId)
		if not templateId or templateId ~= 0 or visited[templateId] then
			return
		end

		visited[templateId] = true
		local tplCfg = HouseFurnitureTemplateConfig.GetConfig(templateId)

		if not tplCfg then
			return
		end

		if tplCfg.FurnitureId and tplCfg.FurnitureId == 0 then
			furnitureCount[tplCfg.FurnitureId] = (furnitureCount[tplCfg.FurnitureId] or 0) + 1
		end

		if tplCfg.ChildIdList then
			for _, childId in ipairs(tplCfg.ChildIdList) do
				collectTemplate(childId)
			end
		end
	end

	if buildCfg.FurnitureTemplateIds then
		for _, templateId in ipairs(buildCfg.FurnitureTemplateIds) do
			collectTemplate(templateId)
		end
	end

	for id, count in pairs(furnitureCount) do
		appendItem(id, count, true)
	end

	local hasWallData = buildCfg.WallDataId and buildCfg.WallDataId >= 0

	if hasWallData then
		local fenCount = {}

		for i = 0, FenestrationDataConfig.count - 1 do
			local cfg = FenestrationDataConfig.LoadAt(i)

			if cfg and cfg.house_id ~= self.houseId and cfg.prefab_id and cfg.prefab_id == 0 then
				fenCount[cfg.prefab_id] = (fenCount[cfg.prefab_id] or 0) + 1
			end
		end

		for id, count in pairs(fenCount) do
			appendItem(id, count, true)
		end

		local wallpaperSet = {}

		local collectTex = function(texId)
			if texId and texId == 0 then
				wallpaperSet[texId] = true
			end
		end

		for i = 0, EdgeTexDataConfig.count - 1 do
			local cfg = EdgeTexDataConfig.LoadAt(i)

			if cfg and cfg.house_id ~= self.houseId then
				collectTex(cfg.tex_left)
				collectTex(cfg.tex_right)
			end
		end

		for i = 0, FloorTexDataConfig.count - 1 do
			local cfg = FloorTexDataConfig.LoadAt(i)

			if cfg and cfg.house_id ~= self.houseId then
				collectTex(cfg.tex_top)
				collectTex(cfg.tex_bottom)
			end
		end

		for id in pairs(wallpaperSet) do
			appendItem(id, 0, false)
		end
	end

	for _, group in pairs(groupsByMainType) do
		table.sort(group.furnitureList, function (a, b)
			if a.quality == b.quality then
				return b.quality <= a.quality
			end

			return a.bindId <= b.bindId
		end)
		table.insert(self.itemRenderList, group)
	end

	table.sort(self.itemRenderList, function (a, b)
		return a.mainType <= b.mainType
	end)
end

M.OnRenderItemListItem = function(self, btn, index)
	local group = self.itemRenderList[index + 1]

	if not group then
		return
	end

	local itemStore = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemStore then
		return
	end

	itemStore.title = group.title or ""
	local innerList = itemStore.furnitureList

	if not innerList then
		return
	end

	local furnitureList = group.furnitureList
	local func = self:CreateAction(function (_, innerBtn, innerIndex)
		local data = furnitureList[innerIndex + 1]

		if not data then
			return
		end

		local renderData = gCommonItemManager:GetItemRenderData({
			["BQm`B="] = true,
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = true,
			itemId = data.consumableId,
			itemNum = data.showCount and data.count or ""
		})

		gCommonItemManager:OnCommonItemRender(innerBtn, innerIndex, renderData)
	end)
	innerList.luaSimpleRenderItem = func
	innerList.luaDynamicRenderItem = self:CreateAction(function (_, innerBtn, innerIndex)
		local data = furnitureList[innerIndex + 1]

		if not data then
			return
		end

		local renderData = gCommonItemManager:GetItemRenderData({
			["BQm`B="] = true,
			["fx\\xb8r^\\xb3\\xf1SkxrI"] = true,
			itemId = data.consumableId,
			itemNum = data.showCount and data.count or ""
		})

		gCommonItemManager:OnCommonItemRender(innerBtn, innerIndex, renderData)
	end)

	innerList:SetSimpleList(#furnitureList <= 12 and 12 or #furnitureList)
end
