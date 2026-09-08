-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\FilterMenu\BigMapComp_FilterMenu_PCView.lua
-- Decompiled from: 01030_BigMapComp_FilterMenu_PCView.lua_c789d1d02939.luajit

BigMapComp_FilterMenu_PCView = BigMapComp_FilterMenu_PCView or {}
local M = BigMapComp_FilterMenu_PCView
M.__index = M
local NavMgr = SGUI.UNavigationMgr
local ScriptTextConfig = LTConfig.TextScriptTextConfig
local FilterGroupConfig = LTConfig.GpsFilterGroupConfig
local DEFAULT_FOCUS_GROUP_ID = 1

M.new = function(core, bigMap)
	local self = setmetatable({}, M)
	self.core = core
	self.bigMap = bigMap
	self.bindData = bigMap.bindData
	self.groupViewItems = {}
	self.activeJiaMuView = false
	self.showJiaMuViewEntry = false
	self.activeWuxueMode = false
	self.showWuxueModeEntry = false

	return self
end

M.BindLegendGroupRedDot = function(self, btn, bigMapModeId)
	if bigMapModeId ~= LTConfig.GpsBigMapModeConfig.Legend then
		gMapSystem.redDot:BindRoot(btn, "Legend")
	else
		gMapSystem.redDot:ClearWidget(btn)
	end
end

M.Refresh = function(self)
	if self.active then
		if self.widget ~= nil then
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

M.TryActive = function(self)
	self.active = true

	self:Refresh()
	self:RefreshGroupList()
end

M.TryDeactive = function(self)
	self.active = false

	self:Refresh()
	self:RefreshGroupList()
end

M.OnEnd = function(self)
	self.bindData.filterMenuTab.selectedIndex = -1

	self.bindData.filterMenuTab:ClearUnusedTabInstances()
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMapStore_Filter"):GetStoreByWidget(self.widget)
	self.store.groupList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderGroup", self)
	self.store.groupList.luaSimpleClick = self.bigMap:CreateAction("OnClickGroup", self)
	self.store.clickReturn = self.bigMap:CreateAction("OnReturn", self)
	self.store.clickCancel = self.bigMap:CreateAction("OnCancelFilterBtn", self)
	self.store.clickQuit = self.bigMap:CreateAction("OnCancelFilterBtn", self)

	self.core:SetView(self)
	self:Refresh()
end

M.OnUpdate = function(self)
	if not self.store then
		return
	end

	if self._markRefreshGroupList then
		self:RefreshGroupList()
	end
end

M.OnGroupToggle = function(self, groupId, active)
	self._markRefreshGroupList = true
end

M.OnTagToggle = function(self, groupId, tagId, enabled)
	self._markRefreshGroupList = true
end

M.OnTagListDirty = function(self, groupId)
	self._markRefreshGroupList = true
end

M.OnRefreshAllRequest = function(self)
	self._markRefreshGroupList = true
end

M.OnFilterStateChange = function(self, isFiltering)
	self.store.isFiltering = isFiltering and 0 or 1
	self.store.showCancelBtn = isFiltering and 1 or 0
end

M.OnBigMapModeChange = function(self, isActive)
	self.store.showQuitBtn = isActive and 1 or 0

	if not isActive then
		self:RequestDefaultGroupFocus()
	end
end

M.IsGroupListNavigationActive = function(self)
	return self.store and self.store.listNavArea and NavMgr.Inst.CurrentActiveArea ~= self.store.listNavArea
end

M.TrySetDefaultGroupFocus = function(self)
	if not self:IsGroupListNavigationActive() then
		return false
	end

	local viewItem = self.groupViewItems and self.groupViewItems[DEFAULT_FOCUS_GROUP_ID]
	local store = viewItem and viewItem.store
	local widget = store and store.m_Store and store.m_Store.bindWidget

	if not widget then
		return false
	end

	self.store.listNavArea.CurrentActiveContent = widget

	return true
end

M.RequestDefaultGroupFocus = function(self)
	if not self:IsGroupListNavigationActive() then
		self._pendingDefaultGroupFocus = false

		return
	end

	self._pendingDefaultGroupFocus = true

	if self.store.groupList then
		self.store.groupList:GoToPos(Vector2.zero, true)
	end

	if not self._markRefreshGroupList and self:TrySetDefaultGroupFocus() then
		self._pendingDefaultGroupFocus = false
	end
end

M.RefreshGroupList = function(self)
	if not self.store then
		return
	end

	self.groupRenderDatas = {}
	self.groupViewItems = {}
	local allGroups = self.core:GetAllGroups()

	for _, group in pairs(allGroups) do
		if self.core:IsGroupAvailable(group) then
			table.insert(self.groupRenderDatas, group)

			local viewItem = {
				group = group
			}
			self.groupViewItems[group.id] = viewItem
		end
	end

	if self.active and #self.groupRenderDatas <= 0 then
		self.store.showFilter = 1
	else
		self.store.showFilter = 0
	end

	self.store.navArea.downNav = nil

	self.store.groupList:SetSimpleList(#self.groupRenderDatas)
	self.store.groupList:SetNavSelectToTop()

	self._markRefreshGroupList = false
end

M.OnRenderGroup = function(self, btn, index)
	index = index + 1
	local groupData = self.groupRenderDatas[index]
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	local group = groupData

	self:BindLegendGroupRedDot(btn, group.BigMapModeId)

	self.groupViewItems[group.id].store = store

	if self._pendingDefaultGroupFocus and group.id ~= DEFAULT_FOCUS_GROUP_ID and self:TrySetDefaultGroupFocus() then
		self._pendingDefaultGroupFocus = false
	end

	store.name = group.name
	store.showSub = group.active and 1 or 0
	local scrollStore = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItemScroll"):GetStoreByWidget(store.tagListScroll.content)
	local groupCfg = FilterGroupConfig.GetConfig(group.id)
	store.guideId = groupCfg.GuideId or ""

	if groupData.BigMapModeId and groupData.BigMapModeId <= 0 then
		scrollStore.tagList.luaSimpleClick = self.bigMap:CreateActionWithArgs("OnToggleBigMapMode", group.id, self)
		scrollStore.tagList.luaSimpleRenderItem = self.bigMap:CreateActionWithArgs("OnRenderBigMapModeItem", group.id, self)

		if group.active then
			self.bigMap:RegisterNavArea(EBigMapNavArea.FilterMenu, scrollStore.navArea)

			self.store.navArea.downNav = scrollStore.navArea
			scrollStore.navArea.upNav = self.store.navArea

			scrollStore.tagList:SetSimpleList(1)

			store.iconId = groupCfg.SeletedIcon or 0
		else
			self.bigMap:UnRegisterNavArea(EBigMapNavArea.FilterMenu, scrollStore.navArea)
			scrollStore.tagList:SetSimpleList(0)

			store.iconId = groupCfg.FilterIcon or 0
		end
	else
		scrollStore.tagList.luaSimpleClick = self.bigMap:CreateActionWithArgs("OnToggleTag", group.id, self)
		scrollStore.tagList.luaSimpleRenderItem = self.bigMap:CreateActionWithArgs("OnRenderTag", group.id, self)
		scrollStore.tagList.luaSimpleDynamicRenderItem = self.bigMap:CreateActionWithArgs("OnRenderTag", group.id, self)

		if group.active then
			self.bigMap:RegisterNavArea(EBigMapNavArea.FilterMenu, scrollStore.navArea)

			self.store.navArea.downNav = scrollStore.navArea
			scrollStore.navArea.upNav = self.store.navArea

			scrollStore.tagList:SetSimpleList(table.count(group.activeTags) + 1)

			store.iconId = groupCfg.SeletedIcon or 0
		else
			self.bigMap:UnRegisterNavArea(EBigMapNavArea.FilterMenu, scrollStore.navArea)
			scrollStore.tagList:SetSimpleList(0)

			store.iconId = groupCfg.FilterIcon or 0
		end
	end
end

M.OnRenderTag = function(self, groupId, btn, index)
	local group = self.core:GetGroup(groupId)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)

	if index ~= 0 then
		local allEnabled = self.core:CheckAllTagsInGroup(groupId)
		store.isSelected = allEnabled and 1 or 0
		store.name = LTConfig.TextConfig.GetConfig(73970614).Text
	else
		local tagIndex = 0
		local targetTag = nil

		for tagId, _ in pairs(group.activeTags) do
			tagIndex = tagIndex + 1

			if tagIndex ~= index then
				targetTag = group.tags[tagId]

				break
			end
		end

		store.isSelected = targetTag.enabled and 1 or 0
		store.name = targetTag.name
	end
end

M.OnNavAreaChange = function(self, oldArea, newArea)
	if not self.store then
		return
	end

	if self.bigMap._navArea2Type[newArea] ~= EBigMapNavArea.FilterMenu then
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.FilterPanel, true)
	else
		self.bigMap:SetControllerMouseHideMask(EControllerPointerHideMask.FilterPanel, false)
	end
end

M.OnClickGroup = function(self, btn, index)
	index = index + 1
	local data = self.groupRenderDatas[index]

	self.core:ToggleGroup(data.id)
end

M.OnToggleTag = function(self, groupId, btn, index)
	local group = self.core:GetGroup(groupId)

	if index ~= 0 then
		local allEnabled = self.core:CheckAllTagsInGroup(groupId)

		self.core:ToggleAllTags(groupId, not allEnabled)
	else
		local tagIndex = 0
		local targetTag = nil

		for tagId, _ in pairs(group.activeTags) do
			tagIndex = tagIndex + 1

			if tagIndex ~= index then
				targetTag = group.tags[tagId]

				break
			end
		end

		self.core:ToggleTag(groupId, targetTag.id)
	end
end

M.OnCancelFilterBtn = function(self)
	self.core:CancelAllFilters()

	NavMgr.Inst.CurrentActiveArea = self.store.navArea
end

M.OnReturn = function(self)
	NavMgr.Inst.CurrentActiveArea = self.bigMap.bindData.mainNavArea
end

local JIAMU_VIEW_TEXT_ID = 89901288
local ENABLE_TEXT_ID = 89901289

M.OnRenderJiaMuViewEntry = function(self, btn, store)
	local jiamuTxtCfg = ScriptTextConfig.GetConfig(JIAMU_VIEW_TEXT_ID)
	store.name = jiamuTxtCfg and jiamuTxtCfg.Text or ""
	store.showSub = self.showJiaMuViewEntry and 1 or 0
	local scrollStore = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItemScroll"):GetStoreByWidget(store.tagListScroll.content)
	scrollStore.tagList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderJiaMuViewItem", self)

	scrollStore.tagList:SetSimpleList(1)

	scrollStore.tagList.luaSimpleClick = self.bigMap:CreateAction("ToggleJiaMuView", self)
end

M.OnRenderJiaMuViewItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeJiaMuView and 1 or 0
end

M.OnClickJiaMuViewEntry = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.showJiaMuViewEntry = not self.showJiaMuViewEntry
	store.showSub = self.showJiaMuViewEntry and 1 or 0
end

M.ToggleJiaMuView = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	self.activeJiaMuView = not self.activeJiaMuView
	store.isSelected = self.activeJiaMuView and 1 or 0
end

M.OnFilterSpiritChange = function(self, tid)
	self.activeJiaMuView = self.bigMap:NeedAddJiaMuViewEntry()
	self._markRefreshGroupList = true
end

M.OnRenderWuxueModeEntry = function(self, btn, store)
	local wuxueModeId = LTConfig.GpsBigMapModeConfig.Wuxue
	local wuxueCfg = LTConfig.GpsBigMapModeConfig.GetConfig(wuxueModeId)
	store.name = wuxueCfg and wuxueCfg.Name or ""
	store.showSub = self.showWuxueModeEntry and 1 or 0
	local scrollStore = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItemScroll"):GetStoreByWidget(store.tagListScroll.content)
	scrollStore.tagList.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderWuxueModeItem", self)

	scrollStore.tagList:SetSimpleList(1)

	scrollStore.tagList.luaSimpleClick = self.bigMap:CreateAction("ToggleWuxueMode", self)
end

M.OnRenderWuxueModeItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeWuxueMode and 1 or 0
end

M.OnClickWuxueModeEntry = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.showWuxueModeEntry = not self.showWuxueModeEntry
	store.showSub = self.showWuxueModeEntry and 1 or 0
end

M.ToggleWuxueMode = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	self.activeWuxueMode = not self.activeWuxueMode
	store.isSelected = self.activeWuxueMode and 1 or 0

	if self.activeWuxueMode then
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeWuxue)
	else
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeCommon)
	end
end

M.NeedShowWuxueMode = function(self)
	local availableJobClass = LTConfig.UrbanJobJobClassConfig.Wuxue

	if availableJobClass and availableJobClass == 0 and not gSpiritJobManager:CheckContainJobClassId(availableJobClass) then
		return false
	end

	return true
end

M.OnRenderBigMapModeItem = function(self, groupId, btn, index)
	local group = self.core:GetGroup(groupId)
	local modeId = group.BigMapModeId
	local modeCfg = LTConfig.GpsBigMapModeConfig.GetConfig(modeId)
	local bigMapFSMState = modeCfg and modeCfg.BigMapFSMState or 0
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.bigMap._activeStates[bigMapFSMState] and 1 or 0
end

M.OnClickWuxueModeEntry = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.showWuxueModeEntry = not self.showWuxueModeEntry
	store.showSub = self.showWuxueModeEntry and 1 or 0
end

M.OnToggleBigMapMode = function(self, groupId, btn, index)
	self.core:ToggleTag(groupId)
end

return M
