BigMapComp_FilterMenu_PCView = BigMapComp_FilterMenu_PCView or {}
local M = BigMapComp_FilterMenu_PCView
M.__index = M
local NavMgr = SGUI.UNavigationMgr
local ScriptTextConfig = LTConfig.TextScriptTextConfig

function M.new(core, bigMap)
	local self = setmetatable({}, M)
	self.core = core
	self.bigMap = bigMap
	self.bindData = bigMap.bindData
	self.groupViewItems = {}
	self.activeJiaMuView = false
	self.showJiaMuViewEntry = false

	return self
end

function M:Refresh()
	if self.active then
		if self.widget == nil then
			self.bindData.filterMenuTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
			self.bindData.filterMenuTab.selectedIndex = 0

			return
		end

		self.store.showFilter = 1

		self.bigMap:RegisterNavArea(EBigMapNavArea.FilterMenu, self.store.navArea)
	elseif self.store then
		self.store.showFilter = 0

		self.bigMap:UnRegisterNavArea(EBigMapNavArea.FilterMenu, self.store.navArea)
	end
end

function M:TryActive()
	self.active = true

	self:Refresh()
end

function M:TryDeactive()
	self.active = false

	self:Refresh()
end

function M:OnEnd()
	self.bindData.filterMenuTab.selectedIndex = -1

	self.bindData.filterMenuTab:ClearUnusedTabInstances()
end

function M:OnPanelLoaded(index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMapStore_Filter"):GetStoreByWidget(self.widget)
	self.store.groupList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderGroup", self)
	self.store.groupList.luaSimpleClick = self.bigMap:CreateAction("OnClickGroup", self)
	self.store.clickReturn = self.bigMap:CreateAction("OnReturn", self)
	self.store.clickCancel = self.bigMap:CreateAction("OnCancelFilterBtn", self)

	self.core:SetView(self)
	self.bigMap:EnableJiaMuView(self.activeJiaMuView)
	self:Refresh()
end

function M:OnUpdate()
	if not self.store then
		return
	end

	if self._markRefreshGroupList then
		self:RefreshGroupList()
	end
end

function M:OnGroupToggle(groupId, active)
	self._markRefreshGroupList = true
end

function M:OnTagToggle(groupId, tagId, enabled)
	self._markRefreshGroupList = true
end

function M:OnTagListDirty(groupId)
	self._markRefreshGroupList = true
end

function M:OnRefreshAllRequest()
	self._markRefreshGroupList = true
end

function M:OnFilterStateChange(isFiltering)
	self.store.isFiltering = isFiltering and 0 or 1
	self.store.showCancelBtn = isFiltering and 1 or 0
end

function M:RefreshGroupList()
	if not self.store then
		return
	end

	self.groupRenderDatas = {}
	self.groupViewItems = {}
	local allGroups = self.core:GetAllGroups()

	for _, group in pairs(allGroups) do
		if group.visible then
			table.insert(self.groupRenderDatas, group)

			local viewItem = {
				group = group
			}
			self.groupViewItems[group.id] = viewItem
		end
	end

	if self.bigMap:NeedAddJiaMuViewEntry() then
		table.insert(self.groupRenderDatas, {
			isJiaMu = true
		})
	end

	self.store.groupList:SetSimpleList(#self.groupRenderDatas)

	self._markRefreshGroupList = false
end

function M:RefreshTagList(groupId)
	local viewItem = self.groupViewItems[groupId]
	local store = viewItem.store
	local group = viewItem.group

	store.tagList:SetSimpleList(table.count(group.tags) + 1)
end

function M:OnRenderGroup(btn, index)
	index = index + 1
	local groupData = self.groupRenderDatas[index]
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)

	if groupData.isJiaMu then
		self:OnRenderJiaMuViewEntry(btn, store)
	else
		local group = groupData
		self.groupViewItems[group.id].store = store
		store.name = group.name
		store.showSub = group.active and 1 or 0
		store.tagList.luaSimpleClick = self.bigMap:CreateActionWithArgs("OnToggleTag", group.id, self)
		store.tagList.luaSimpleRenderItem = self.bigMap:CreateActionWithArgs("OnRenderTag", group.id, self)
		store.tagList.luaSimpleDynamicRenderItem = self.bigMap:CreateActionWithArgs("OnRenderTag", group.id, self)

		if group.active then
			self:RefreshTagList(group.id)
		end
	end
end

function M:OnRenderTag(groupId, btn, index)
	local group = self.core:GetGroup(groupId)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)

	if index == 0 then
		local allEnabled = self.core:CheckAllTagsInGroup(groupId)
		store.isSelected = allEnabled and 1 or 0
		store.name = LTConfig.TextConfig.GetConfig(73970614).Text
	else
		local tagIndex = 0
		local targetTag = nil

		for _, tag in pairs(group.tags) do
			tagIndex = tagIndex + 1

			if tagIndex == index then
				targetTag = tag

				break
			end
		end

		store.isSelected = targetTag.enabled and 1 or 0
		store.name = targetTag.name
	end
end

function M:OnNavAreaChange(oldArea, newArea)
	if not self.store then
		return
	end

	if newArea == self.store.listNavArea then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.FilterPanel, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.FilterPanel, false)
	end
end

function M:OnClickGroup(btn, index)
	index = index + 1
	local data = self.groupRenderDatas[index]

	if data.isJiaMu then
		self:OnClickJiaMuViewEntry(btn)
	else
		self.core:ToggleGroup(data.id)
	end
end

function M:OnToggleTag(groupId, btn, index)
	local group = self.core:GetGroup(groupId)

	if index == 0 then
		local allEnabled = self.core:CheckAllTagsInGroup(groupId)

		self.core:ToggleAllTags(groupId, not allEnabled)
	else
		local tagIndex = 0
		local targetTag = nil

		for _, tag in pairs(group.tags) do
			tagIndex = tagIndex + 1

			if tagIndex == index then
				targetTag = tag

				break
			end
		end

		self.core:ToggleTag(groupId, targetTag.id)
	end
end

function M:OnCancelFilterBtn()
	self.core:CancelAllFilters()
end

function M:OnReturn()
	NavMgr.Inst.CurrentActiveArea = self.bigMap.bindData.mainNavArea
end

local JIAMU_VIEW_TEXT_ID = 89901288
local ENABLE_TEXT_ID = 89901289

function M:OnRenderJiaMuViewEntry(btn, store)
	local jiamuTxtCfg = ScriptTextConfig.GetConfig(JIAMU_VIEW_TEXT_ID)
	store.name = jiamuTxtCfg and jiamuTxtCfg.Text or ""
	store.showSub = self.showJiaMuViewEntry and 1 or 0
	store.tagList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderJiaMuViewItem", self)

	store.tagList:SetSimpleList(1)

	store.tagList.luaSimpleClick = self.bigMap:CreateAction("ToggleJiaMuView", self)
end

function M:OnRenderJiaMuViewItem(btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeJiaMuView and 1 or 0
end

function M:OnClickJiaMuViewEntry(btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.showJiaMuViewEntry = not self.showJiaMuViewEntry
	store.showSub = self.showJiaMuViewEntry and 1 or 0
end

function M:ToggleJiaMuView(btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	self.activeJiaMuView = not self.activeJiaMuView
	store.isSelected = self.activeJiaMuView and 1 or 0

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)
end

function M:OnFilterSpiritChange(tid)
	self.activeJiaMuView = self.bigMap:NeedAddJiaMuViewEntry()

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)

	self._markRefreshGroupList = true
end

return M
