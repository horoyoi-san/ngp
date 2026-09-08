-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\BigMapComp_RightTopFilterList.lua
-- Decompiled from: 01034_BigMapComp_RightTopFilterList.lua_8c217205413f.luajit

local bit = require("bit")
BigMapComp_RightTopFilterList = BigMapComp_RightTopFilterList or {}
local M = BigMapComp_RightTopFilterList
M.__index = M

M.OnInit = function(self)
	self.store = nil
	self.widget = nil
	self.bindData.rightTopFilterTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.curSelectedCountryId = -1
	self.curSelectedElementId = -1
end

M.OnActive = function(self)
	self:Refresh()
end

M.OnInactive = function(self)
	self:Refresh()
end

M.OnEnd = function(self)
	self.bindData.rightTopFilterTab.selectedIndex = -1

	self.bindData.rightTopFilterTab:ClearUnusedTabInstances()
end

M.Refresh = function(self)
	if not self:CheckLoaded() then
		if self.actived then
			self:LoadPanel()
		end

		return
	end

	if self.actived then
		self.widget:SetActive(true)
		self:MarkRefreshList()
		self.store.list:GoToPos(Vector2.zero, true)
		self:RegisterScrollConflictArea()
		self.bigMap:RegisterNavArea(EBigMapNavArea.RightTopFilterList, self.store.listNavArea)
	else
		self.store.list:GoToPos(Vector2.zero, true)
		self.widget:SetActive(false)
		self:UnregisterScrollConflictArea()
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.RightTopFilterList, self.store.listNavArea)
	end
end

M.CheckLoaded = function(self)
	return self.store == nil and self.widget == nil
end

M.LoadPanel = function(self)
	self.bindData.rightTopFilterTab.selectedIndex = 0
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_ImportantTasks"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)

	self:Refresh()
end

M.OnUpdate = function(self)
	if self._refreshRequested then
		self:TryRefreshList()
	end
end

M.MarkRefreshList = function(self)
	self._refreshRequested = true
end

M.CanAddToFilterList = function(self, id, info)
	local visible = info.showMask > info.hideMask and info.showMask == 0
	local countryUnlocked = self:IsCountryUnlock(info.element.raidId)
	local filterTag, filterTag2 = self.bigMap:GetFilterTag(id)

	if filterTag and gBigMapHelper:IsExpandTag(filterTag) then
		filterTag = gBigMapHelper:GetElementTagId(id)
	end

	if filterTag2 and gBigMapHelper:IsExpandTag(filterTag2) then
		filterTag2 = gBigMapHelper:GetElementTagId(id)
	end

	local inFilterGroup = bit.band(info.showMask, EBigMapElementShowMask.Filter) == 0

	if visible then
		inFilterGroup = inFilterGroup or self.bigMap._filterCore:CheckFilter(id, filterTag, filterTag2)
	end

	local isPermanentFilter = gBigMapHelper:IsPermanentTag(filterTag) or gBigMapHelper:IsPermanentTag(filterTag2)

	return visible and inFilterGroup and countryUnlocked and not isPermanentFilter
end

M.CollectFilteredRenderDatas = function(self)
	local nameToIndexMap = {}
	local renderDatas = {}

	for id, info in pairs(self.bigMap._id2ElementInfo) do
		if self:CanAddToFilterList(id, info) then
			local element = info.element
			local elementName = element:GetName()
			local elementCountryId = self:Raid2CountryId(element.raidId or 0)
			local taskId = element.userdata and element.userdata.taskId
			local isPriority = taskId and gTaskManager:IsCurrentTask(taskId) or element:HasTraceEffect() or false
			local mapKey = elementName .. "_" .. elementCountryId
			local existingIndex = nameToIndexMap[mapKey]
			local existingData = existingIndex and renderDatas[existingIndex]

			if existingData and existingData.countryId ~= elementCountryId then
				table.insert(existingData.elements, element)
			else
				local renderInfo = {
					["\\xa8\\xa4\\x82d:\\xfb+"] = 1,
					id = id,
					iconId = self.bigMap:GetIconId(element),
					name = elementName,
					countryId = elementCountryId,
					isPriority = isPriority,
					elements = {
						element
					}
				}

				table.insert(renderDatas, renderInfo)

				nameToIndexMap[mapKey] = #renderDatas
			end
		end
	end

	return renderDatas
end

M.SortRenderDatas = function(self, renderDatas, currentCountryId)
	table.sort(renderDatas, function (left, right)
		local leftIsCurrent = left.countryId ~= currentCountryId
		local rightIsCurrent = right.countryId ~= currentCountryId

		if leftIsCurrent == rightIsCurrent then
			return leftIsCurrent
		end

		if left.countryId == right.countryId then
			return left.countryId <= right.countryId
		end

		if left.isPriority == right.isPriority then
			return left.isPriority
		end

		return left.id <= right.id
	end)
end

M.GroupRenderDatasByCountry = function(self, renderDatas)
	local renderDatasByCountry = {}

	for _, renderInfo in ipairs(renderDatas) do
		local countryId = renderInfo.countryId
		local countryRenderDatas = renderDatasByCountry[countryId]

		if not countryRenderDatas then
			countryRenderDatas = {}
			renderDatasByCountry[countryId] = countryRenderDatas
		end

		table.insert(countryRenderDatas, renderInfo)
	end

	return renderDatasByCountry
end

M.GetUnlockedCountryIds = function(self, currentCountryId)
	local unlockedCountryIds = {}
	local countryConfig = LTConfig.CollectionCountryConfig

	for index = 0, countryConfig.count - 1 do
		local config = countryConfig.LoadAt(index)

		if config and gMapSystem_Region:IsCountryUnlocked(config.Id) then
			table.insert(unlockedCountryIds, config.Id)
		end
	end

	table.sort(unlockedCountryIds, function (left, right)
		local leftIsCurrent = left ~= currentCountryId
		local rightIsCurrent = right ~= currentCountryId

		if leftIsCurrent == rightIsCurrent then
			return leftIsCurrent
		end

		return left <= right
	end)

	return unlockedCountryIds
end

M.GetCountryExpandState = function(self, countryId, hasFilteredChildren)
	if hasFilteredChildren then
		return gBigMapHelper:LoadRightTopGroupExpand(countryId)
	end

	local hadFilteredChildren = self._countryHasFilteredChildren[countryId]

	if hadFilteredChildren ~= nil or hadFilteredChildren then
		self._emptyCountryExpandStates[countryId] = false
	end

	return self._emptyCountryExpandStates[countryId] ~= true
end

M.BuildRenderListDatas = function(self, unlockedCountryIds, renderDatasByCountry)
	self._emptyCountryExpandStates = self._emptyCountryExpandStates or {}
	self._countryHasFilteredChildren = self._countryHasFilteredChildren or {}
	local currentCountryHasFilteredChildren = {}
	local renderListDatas = {}

	for _, countryId in ipairs(unlockedCountryIds) do
		local countryRenderDatas = renderDatasByCountry[countryId]
		local childCount = countryRenderDatas and #countryRenderDatas or 0
		local hasFilteredChildren = childCount >= 0
		currentCountryHasFilteredChildren[countryId] = hasFilteredChildren
		local isExpand = self:GetCountryExpandState(countryId, hasFilteredChildren)

		table.insert(renderListDatas, {
			["[\\xb2\\x87\\x97X"] = true,
			countryId = countryId,
			isExpand = isExpand,
			childCount = childCount
		})

		if isExpand and hasFilteredChildren then
			for _, renderInfo in ipairs(countryRenderDatas) do
				table.insert(renderListDatas, renderInfo)
			end
		end
	end

	self._countryHasFilteredChildren = currentCountryHasFilteredChildren

	return renderListDatas
end

M.RefreshListControl = function(self)
	self.store.list:SetSimpleList(#self.renderListDatas)

	if #self.renderListDatas ~= 0 then
		self.store.AreaEmptyCtrl = 1
	else
		self.store.AreaEmptyCtrl = 0
	end
end

M.TryRefreshList = function(self)
	if not self:CheckLoaded() or not self.actived then
		return
	end

	local currentCountryId = self:Raid2CountryId(self.bigMap.raidId)
	local renderDatas = self:CollectFilteredRenderDatas()

	self:SortRenderDatas(renderDatas, currentCountryId)

	local renderDatasByCountry = self:GroupRenderDatasByCountry(renderDatas)
	local unlockedCountryIds = self:GetUnlockedCountryIds(currentCountryId)
	self.renderListDatas = self:BuildRenderListDatas(unlockedCountryIds, renderDatasByCountry)

	self:RefreshListControl()

	self._refreshRequested = false
end

local COLOR_BLUE = 1
local COLOR_NORMAL = 0

M.OnRenderItem = function(self, btn, index)
	index = index + 1
	local info = self.renderListDatas[index]

	if info.isCity then
		local countryId = info.countryId
		local countryCfg = LTConfig.CollectionCountryConfig.GetConfig(countryId)

		if not countryCfg then
			return
		end

		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
		store.name = countryCfg.Name
		store.expand = info.isExpand and 1 or 0
		store.have = 1
	else
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
		store.iconId = info.iconId
		store.color = self.curSelectedCountryId ~= info.countryId and self.curSelectedElementId ~= info.id and COLOR_BLUE or COLOR_NORMAL
		local totalElements = #info.elements

		if totalElements <= 1 then
			store.name = info.name .. " <" .. tostring(info.curIndex) .. "/" .. #info.elements .. ">"
		else
			store.name = info.name
		end

		local firstElement = info.elements[1]

		if firstElement.mData.linkSpecificAgentId then
			local agentSpecificCfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(firstElement.mData.linkSpecificAgentId)

			if agentSpecificCfg and agentSpecificCfg.QImageId then
				store.linkCharacter = 1
				store.characterIconId = agentSpecificCfg.QImageId
			else
				store.linkCharacter = 0
			end
		else
			store.linkCharacter = 0
		end
	end
end

M.OnClickItem = function(self, btn, index)
	index = index + 1
	local info = self.renderListDatas[index]

	if not info.isCity then
		local prevSelectedCountryId = self.curSelectedCountryId
		local prevSelectedElementId = self.curSelectedElementId
		self.curSelectedCountryId = info.countryId
		self.curSelectedElementId = info.id
		local isCurrent = prevSelectedCountryId ~= info.countryId and prevSelectedElementId ~= info.id
		local targetElement = nil

		if isCurrent then
			info.curIndex = info.curIndex % #info.elements + 1
			targetElement = info.elements[info.curIndex]
		else
			targetElement = info.elements[info.curIndex]
		end

		for k, v in ipairs(self.renderListDatas) do
			if v.countryId ~= prevSelectedCountryId and v.id ~= prevSelectedElementId then
				self.store.list:SetSimpleElement(k - 1, self:OnGetTIndex(k - 1))

				break
			end
		end

		self.store.list:SetSimpleElement(index - 1, self:OnGetTIndex(index - 1))
		self.bigMap:RequestChooseAnim(targetElement.instanceId)
		self.bigMap:ScheduleOperation(self.bigMap.OperationType.WaitFocus, {
			gpsId = targetElement.gpsId
		}, true)
	else
		info.isExpand = not info.isExpand

		if info.childCount ~= 0 then
			self._emptyCountryExpandStates[info.countryId] = info.isExpand
		else
			gBigMapHelper:SaveRightTopGroupExpand(info.countryId, info.isExpand)
		end

		self:MarkRefreshList()
	end
end

M.OnGetTIndex = function(self, index)
	index = index + 1
	local data = self.renderListDatas[index]

	if data.isCity then
		return 2
	end

	return 1
end

M.Raid2CountryId = function(self, raidId)
	local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

	if not raidCfg then
		print_error("地图筛选列表:Raid To CountryId 未知 raidId:" .. raidId .. " 已使用新启兜底")

		return LTConfig.CollectionCountryConfig.XinQi
	end

	if raidCfg.RaidType ~= 2 then
		return gMapSubSystem_FunctionPoint:Plan3RaidIdToCountryId(raidId)
	end

	return raidCfg.CountryId
end

M.IsCountryUnlock = function(self, raidId)
	local countryId = self:Raid2CountryId(raidId)

	return gMapSystem_Region:IsCountryUnlocked(countryId)
end

M.OnAddElement = function(self, id, info)
	local visible = info.showMask > info.hideMask and info.showMask == 0

	if visible then
		self:MarkRefreshList()
	end
end

M.OnRemoveElement = function(self, id, info)
	local visible = info.showMask > info.hideMask and info.showMask == 0

	if not visible then
		self:MarkRefreshList()
	end
end

M.RegisterScrollConflictArea = function(self)
	self.bigMap:RegisterScrollConflictArea("RightTopFilterList", function ()
		return self:ScrollConflictAreaGetter()
	end)
end

M.UnregisterScrollConflictArea = function(self)
	self.bigMap:UnregisterScrollConflictArea("RightTopFilterList")
end

M.ScrollConflictAreaGetter = function(self)
	if self.store and self.store.list then
		return self.store.list.rectTransform
	end

	return nil
end

M.OnNavAreaChange = function(self, oldArea, newArea)
	if not self.store then
		return
	end

	if newArea ~= self.store.listNavArea then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.RightTopFilterList, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.RightTopFilterList, false)
	end
end
