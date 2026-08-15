local bit = require("bit")
BigMapComp_RightTopFilterList = BigMapComp_RightTopFilterList or {}
local M = BigMapComp_RightTopFilterList
M.__index = M

function M:OnInit()
	self.store = nil
	self.widget = nil
	self.bindData.rightTopFilterTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.curSelectedCountryId = -1
	self.curSelectedElementId = -1
end

function M:OnActive()
	self:Refresh()
end

function M:OnInactive()
	self:Refresh()
end

function M:OnEnd()
	self.bindData.rightTopFilterTab.selectedIndex = -1

	self.bindData.rightTopFilterTab:ClearUnusedTabInstances()
end

function M:Refresh()
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

function M:CheckLoaded()
	return self.store ~= nil and self.widget ~= nil
end

function M:LoadPanel()
	self.bindData.rightTopFilterTab.selectedIndex = 0
end

function M:OnPanelLoaded(index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_ImportantTasks"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)

	self:Refresh()
end

function M:OnUpdate()
	if self._refreshRequested then
		self:TryRefreshList()
	end
end

function M:MarkRefreshList()
	self._refreshRequested = true
end

function M:TryRefreshList()
	if not self:CheckLoaded() or not self.actived then
		return
	end

	self.renderListDatas = self.renderListDatas or {}

	table.clear(self.renderListDatas)

	local nameToIndexMap = {}
	local firstPassRenderData = {}

	for id, info in pairs(self.bigMap._id2ElementInfo) do
		local element = info.element
		local visible = info.showMask >= info.hideMask and info.showMask ~= 0
		local countryUnlock = self:IsCountryUnlock(element.raidId)
		local filterTag, filterTag2 = self.bigMap:GetFilterTag(id)

		if filterTag and gBigMapHelper:IsExpandTag(filterTag) then
			filterTag = gBigMapHelper:GetElementTagId(id)
		end

		if filterTag2 and gBigMapHelper:IsExpandTag(filterTag2) then
			filterTag2 = gBigMapHelper:GetElementTagId(id)
		end

		local inFilterGroup = bit.band(info.showMask, EBigMapElementShowMask.Filter) ~= 0

		if visible and bit.band(info.showMask, EBigMapElementShowMask.Filter) == 0 then
			inFilterGroup = self.bigMap._filterCore:CheckFilter(id, filterTag, filterTag2)
		end

		local isPermanentFilter = gBigMapHelper:IsPermanentTag(filterTag) or gBigMapHelper:IsPermanentTag(filterTag2)

		if visible and inFilterGroup and countryUnlock and not isPermanentFilter then
			local elementName = element:GetName()
			local elementCountryId = self:Raid2CountryId(element.raidId or 0)
			local mapKey = elementName .. "_" .. elementCountryId
			local existingIndex = nameToIndexMap[mapKey]

			if existingIndex and firstPassRenderData[existingIndex] and firstPassRenderData[existingIndex].countryId == elementCountryId then
				local existingData = firstPassRenderData[existingIndex]

				table.insert(existingData.elements, element)
			else
				local renderInfo = {
					curIndex = 1,
					id = id,
					iconId = self.bigMap:GetIconId(element),
					name = elementName,
					countryId = elementCountryId,
					elements = {
						element
					}
				}

				table.insert(firstPassRenderData, renderInfo)

				nameToIndexMap[mapKey] = #firstPassRenderData
			end
		end
	end

	local currentCountryId = self:Raid2CountryId(self.bigMap.raidId)

	table.sort(firstPassRenderData, function (a, b)
		local aIsCurrent = a.countryId == currentCountryId
		local bIsCurrent = b.countryId == currentCountryId

		if aIsCurrent ~= bIsCurrent then
			return aIsCurrent
		end

		if a.countryId ~= b.countryId then
			return a.countryId < b.countryId
		end

		return a.id < b.id
	end)

	local finalPassRenderData = {}
	local lastCountryId = nil
	local currentGroupExpanded = true

	for i, renderInfo in ipairs(firstPassRenderData) do
		if lastCountryId ~= renderInfo.countryId then
			currentGroupExpanded = gBigMapHelper:LoadRightTopGroupExpand(renderInfo.countryId)
			local separatorInfo = {
				isCity = true,
				countryId = renderInfo.countryId,
				isExpand = currentGroupExpanded
			}

			table.insert(finalPassRenderData, separatorInfo)

			lastCountryId = renderInfo.countryId
		end

		if currentGroupExpanded then
			table.insert(finalPassRenderData, renderInfo)
		end
	end

	self.renderListDatas = finalPassRenderData

	self.store.list:SetSimpleList(#self.renderListDatas)

	if #self.renderListDatas == 0 then
		self.store.AreaEmptyCtrl = 1
	else
		self.store.AreaEmptyCtrl = 0
	end

	self._refreshRequested = false
end

local COLOR_BLUE = 1
local COLOR_NORMAL = 0

function M:OnRenderItem(btn, index)
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
	else
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
		store.iconId = info.iconId
		store.color = self.curSelectedCountryId == info.countryId and self.curSelectedElementId == info.id and COLOR_BLUE or COLOR_NORMAL
		local totalElements = #info.elements

		if totalElements > 1 then
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

function M:OnClickItem(btn, index)
	index = index + 1
	local info = self.renderListDatas[index]

	if not info.isCity then
		local prevSelectedCountryId = self.curSelectedCountryId
		local prevSelectedElementId = self.curSelectedElementId
		self.curSelectedCountryId = info.countryId
		self.curSelectedElementId = info.id
		local isCurrent = prevSelectedCountryId == info.countryId and prevSelectedElementId == info.id
		local targetElement = nil

		if isCurrent then
			info.curIndex = info.curIndex % #info.elements + 1
			targetElement = info.elements[info.curIndex]
		else
			targetElement = info.elements[info.curIndex]
		end

		for k, v in ipairs(self.renderListDatas) do
			if v.countryId == prevSelectedCountryId and v.id == prevSelectedElementId then
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

		gBigMapHelper:SaveRightTopGroupExpand(info.countryId, info.isExpand)
		self:MarkRefreshList()
	end
end

function M:OnGetTIndex(index)
	index = index + 1
	local data = self.renderListDatas[index]

	if data.isCity then
		return 0
	end

	return 1
end

function M:Raid2CountryId(raidId)
	local raidCfg = LTConfig.RaidConfig.GetConfig(raidId)

	if not raidCfg then
		print_error("地图筛选列表:Raid To CountryId 未知 raidId:" .. raidId .. " 已使用新启兜底")

		return LTConfig.CollectionCountryConfig.XinQi
	end

	if raidCfg.RaidType == 2 then
		return gMapSubSystem_FunctionPoint:Plan3RaidIdToCountryId(raidId)
	end

	return raidCfg.CountryId
end

function M:IsCountryUnlock(raidId)
	local countryId = self:Raid2CountryId(raidId)

	return gMapSystem_Region:IsCountryUnlocked(countryId)
end

function M:OnAddElement(id, info)
	local visible = info.showMask >= info.hideMask and info.showMask ~= 0

	if visible then
		self:MarkRefreshList()
	end
end

function M:OnRemoveElement(id, info)
	local visible = info.showMask >= info.hideMask and info.showMask ~= 0

	if not visible then
		self:MarkRefreshList()
	end
end

function M:RegisterScrollConflictArea()
	self.bigMap:RegisterScrollConflictArea("RightTopFilterList", function ()
		return self:ScrollConflictAreaGetter()
	end)
end

function M:UnregisterScrollConflictArea()
	self.bigMap:UnregisterScrollConflictArea("RightTopFilterList")
end

function M:ScrollConflictAreaGetter()
	if self.store and self.store.list then
		return self.store.list.rectTransform
	end

	return nil
end

function M:OnNavAreaChange(oldArea, newArea)
	if not self.store then
		return
	end

	if newArea == self.store.listNavArea then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.RightTopFilterList, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.RightTopFilterList, false)
	end
end
