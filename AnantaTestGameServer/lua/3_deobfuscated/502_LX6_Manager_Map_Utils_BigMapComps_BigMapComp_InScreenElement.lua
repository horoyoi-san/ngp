BigMapComp_InScreenElementsList = BigMapComp_InScreenElementsList or {}
local FilterConfig = LTConfig.GpsFilterTagConfig
local FilterGroupConfig = LTConfig.GpsFilterGroupConfig
local type = type
local table = table
local M = BigMapComp_InScreenElementsList
M.__index = M

function M:OnInit()
	self.store = nil
	self.widget = nil
	self.bindData.taskListTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
	self.elementList = {}
	self.renderListDatas = {}
end

function M:OnActive()
	self:Refresh()

	self._lastMapPos = self.bigMap.mapPos
	self._lastMapScale = self.bigMap.scale
	self._lastFilterState = self.bigMap.fsms[5].currentState

	self:RefreshElementList()
end

function M:OnInactive()
	self:Refresh()
end

function M:OnEnd()
	self.bindData.taskListTab.selectedIndex = -1

	self.bindData.taskListTab:ClearUnusedTabInstances()
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
		self.bigMap:RegisterNavArea(EBigMapNavArea.InScreenElementsList, self.store.listNavArea)
		self:RegisterScrollConflictArea()
	else
		self.store.list:GoToPos(Vector2.zero, true)
		self.widget:SetActive(false)
		self:UnregisterScrollConflictArea()
		self.bigMap:UnRegisterNavArea(EBigMapNavArea.InScreenElementsList, self.store.listNavArea)
	end
end

function M:CheckLoaded()
	return self.store ~= nil and self.widget ~= nil
end

function M:LoadPanel()
	self.bindData.taskListTab.selectedIndex = 0
end

function M:OnPanelLoaded(index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMap_ImportantTasks"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)

	self:Refresh()
	self:RefreshElementList()
end

function M:OnUpdate()
	if not self:CheckLoaded() then
		return
	end

	if self._markRefreshRenderData then
		self:RefreshRenderDatas()

		self._markRefreshRenderData = false
	end

	if self._lastMapPos ~= self.bigMap.mapPos or self._lastMapScale ~= self.bigMap.scale or self._lastFilterState ~= self.bigMap.fsms[5].currentState then
		self._lastMapPos = self.bigMap.mapPos
		self._lastMapScale = self.bigMap.scale
		self._lastFilterState = self.bigMap.fsms[5].currentState

		self:RefreshElementList()
	end

	self:TickElementsTracingState()
end

function M:TickElementsTracingState()
	if not self:CheckLoaded() then
		return
	end

	local success, min, max = self.store.list:TryGetVisualRange(0, 0)

	if success then
		for i = min + 1, max + 1 do
			local data = self.renderListDatas[i]

			if data and not data.isGroupHeader then
				local info = self.bigMap._id2ElementInfo[data.id]

				if info and info.element then
					local isTracing = info.element:HasTraceEffect()

					if data.isTracing ~= isTracing then
						data.isTracing = isTracing

						self.store.list:SetSimpleElement(i - 1, 1, false, false)
					end
				end
			end
		end
	end
end

function M:RefreshElementList()
	if not self:CheckLoaded() then
		return
	end

	local viewportSize, yOffset = self:GetViewport()
	local halfWidth = viewportSize.x / 2
	local halfHeight = viewportSize.y / 2

	table.clear(self.elementList)

	for id, info in pairs(self.bigMap._id2ElementInfo) do
		if self:CanElementAddToList(id, info, halfWidth, halfHeight, yOffset / 2) then
			self.elementList[id] = true
		end
	end

	self._markRefreshRenderData = true
end

function M:CanElementAddToList(id, info, halfWidth, halfHeight, halfYOffset)
	local filterTag1, filterTag2 = self.bigMap:GetFilterTag(id)

	if not filterTag1 and not filterTag2 then
		return false
	end

	local visible = info.showMask >= info.hideMask

	if not visible then
		return false
	end

	local uiX, uiY = self.bigMap:TransformTexToUIXY(info.texPos.x, info.texPos.y)

	if uiX >= -halfWidth and uiX <= halfWidth and uiY >= -halfHeight - halfYOffset and uiY <= halfHeight - halfYOffset then
		return true
	end
end

function M:RefreshRenderDatas()
	table.clear(self.renderListDatas)

	local elementsWithGroup = {}

	for id, _ in pairs(self.elementList) do
		local filterTag1, filterTag2 = self.bigMap:GetFilterTag(id)
		local filterTag = filterTag1 or filterTag2

		if filterTag then
			local element = self.bigMap._id2ElementInfo[id].element
			local cfg = FilterConfig.GetConfig(filterTag)

			if cfg then
				table.insert(elementsWithGroup, {
					id = id,
					groupId = cfg.Group,
					isTracing = element and element:HasTraceEffect() or nil
				})
			end
		end
	end

	table.sort(elementsWithGroup, function (a, b)
		if a.groupId == b.groupId then
			return a.id < b.id
		end

		return a.groupId < b.groupId
	end)

	local lastGroupId, groupIsExpand = nil

	for i = 1, #elementsWithGroup do
		local info = elementsWithGroup[i]

		if info.groupId ~= lastGroupId then
			groupIsExpand = gBigMapHelper:LoadInScreenGroupExpand(info.groupId)

			table.insert(self.renderListDatas, {
				isGroupHeader = true,
				groupId = info.groupId,
				isExpand = groupIsExpand
			})

			lastGroupId = info.groupId
		end

		if groupIsExpand then
			table.insert(self.renderListDatas, info)
		end
	end

	self.store.list:SetSimpleList(#self.renderListDatas)

	if #self.renderListDatas == 0 then
		self.store.AreaEmptyCtrl = 1
	else
		self.store.AreaEmptyCtrl = 0
	end
end

function M:OnAddElement(id, info)
	if not self:CheckLoaded() then
		return
	end

	local viewportSize, yOffset = self:GetViewport()
	local halfWidth = viewportSize.x / 2
	local halfHeight = viewportSize.y / 2

	if self:CanElementAddToList(id, info, halfWidth, halfHeight, yOffset / 2) then
		self.elementList[info.id] = true
		self._markRefreshRenderData = true
	end
end

function M:OnRemoveElement(id, info)
	if not self:CheckLoaded() then
		return
	end

	if self.elementList[info.id] then
		self.elementList[info.id] = nil
		self._markRefreshRenderData = true
	end
end

local COLOR_BLUE = 1
local COLOR_NORMAL = 0

function M:OnRenderItem(btn, index)
	index = index + 1
	local data = self.renderListDatas[index]

	if data.isGroupHeader then
		local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
		local groupCfg = FilterGroupConfig.GetConfig(data.groupId)
		store.name = groupCfg.Name
		store.expand = data.isExpand and 1 or 0
	else
		local id = data.id
		local info = self.bigMap._id2ElementInfo[id]
		local element = info.element

		if info then
			local store = gStoreManager:GetStoreGroup("MapAnonymousStore"):GetStoreByWidget(btn)
			store.iconId = self.bigMap:GetIconId(element)
			store.name = element:GetName()
			store.guideId = "RT_" .. element.gpsId
			store.color = data.isTracing and COLOR_BLUE or COLOR_NORMAL

			if element.mData.linkSpecificAgentId then
				local agentSpecificCfg = LTConfig.AgentAgentSpecificTypeConfig.GetConfig(element.mData.linkSpecificAgentId)

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
end

function M:OnClickItem(btn, index)
	index = index + 1

	if index <= 0 or index > #self.renderListDatas then
		return
	end

	local data = self.renderListDatas[index]

	if data.isGroupHeader then
		data.isExpand = not data.isExpand

		gBigMapHelper:SaveInScreenGroupExpand(data.groupId, data.isExpand)

		self._markRefreshRenderData = true
	else
		local info = self.bigMap._id2ElementInfo[data.id]

		if info and info.element then
			self.bigMap:ScheduleOperation(self.bigMap.OperationType.Select, {
				gpsId = info.element.gpsId
			}, true)
		end
	end
end

function M:OnGetTIndex(index)
	index = index + 1
	local data = self.renderListDatas[index]

	if data.isGroupHeader then
		return 0
	else
		return 1
	end
end

function M:RegisterScrollConflictArea()
	self.bigMap:RegisterScrollConflictArea("InScreenElements", function ()
		return self:ScrollConflictAreaGetter()
	end)
end

function M:UnregisterScrollConflictArea()
	self.bigMap:UnregisterScrollConflictArea("InScreenElements")
end

function M:ScrollConflictAreaGetter()
	if self.store and self.store.list then
		return self.store.list.rectTransform
	end

	return nil
end

local LuaUtils = gCS.LuaUtils
local JH_Y_OFFSET = 0.075

function M:GetViewport()
	local viewportSize = self.bigMap:GetViewRangeSize()
	local yOffset = 0

	if LuaUtils.IsNonMobileAdaptive() and self.bindData.ShowMainPageCtrl == 1 then
		viewportSize.x = viewportSize.x
		yOffset = viewportSize.y * JH_Y_OFFSET
		viewportSize.y = viewportSize.y * (1 - JH_Y_OFFSET)
	end

	return viewportSize, yOffset
end
