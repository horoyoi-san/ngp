-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapComps\FilterMenu\BigMapComp_FilterMenu_MobileView.lua
-- Decompiled from: 01031_BigMapComp_FilterMenu_MobileView.lua_1dc7752ff4ca.luajit

BigMapComp_FilterMenu_MobileView = BigMapComp_FilterMenu_MobileView or {}
local M = BigMapComp_FilterMenu_MobileView
M.__index = M
local ScriptTextConfig = LTConfig.TextScriptTextConfig
local FilterGroupConfig = LTConfig.GpsFilterGroupConfig

M.new = function(core, bigMap)
	local self = setmetatable({}, M)
	self.core = core
	self.bigMap = bigMap
	self.bindData = bigMap.bindData
	self.groupViewItems = {}
	self.showJiaMuViewEntry = false
	self.activeJiaMuView = false
	self.showWuxueModeEntry = false
	self.activeWuxueMode = false
	self.expandedGroupId = nil

	return self
end

M.Refresh = function(self)
	if self.active then
		if self.widget ~= nil then
			self.bindData.filterMenuTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
			self.bindData.filterMenuTab.selectedIndex = 1

			return
		end

		self.store.showFilter = 1

		self:RefreshList()
	elseif self.store then
		self.store.showFilter = 0
	end
end

M.OnUpdate = function(self)
	if not self.store then
		return
	end

	if self._markRefreshGroupList then
		self:RefreshList()
	end
end

M.TryActive = function(self)
	self.active = true

	self:Refresh()
end

M.TryDeactive = function(self)
	self.active = false

	self:Refresh()
end

M.OnEnd = function(self)
	self.bindData.filterMenuTab.selectedIndex = -1

	self.bindData.filterMenuTab:ClearUnusedTabInstances()
end

M.OnPanelLoaded = function(self, index, tab)
	self.widget = tab
	self.store = gStoreManager:GetStoreGroup("BigMapStore_Filter_Mobile"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.clickCancel = self.bigMap:CreateAction("OnCancelFilterBtn", self)
	self.store.clickQuit = self.bigMap:CreateAction("OnCancelFilterBtn", self)
	self.store.clickClose = self.bigMap:CreateAction("HideMainPage", self)
	self.store.clickEntry = self.bigMap:CreateAction("ShowMainPage", self)

	self.core:SetView(self)
	self:Refresh()
	self:HideMainPage()
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
end

local SELECT_ALL = 0
local SELECT_PART = 1
local SELECT_NONE = 2

M.RefreshList = function(self)
	if not self.store then
		return
	end

	local allGroups = self.core:GetAllGroups()
	self.renderDatas = {}
	local rds = self.renderDatas

	for _, group in pairs(allGroups) do
		if self.core:IsGroupAvailable(group) then
			local expand = group.id ~= self.expandedGroupId
			local groupRd = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = group.id,
				name = group.name,
				expand = expand,
				bigMapModeId = group.BigMapModeId
			}

			table.insert(rds, groupRd)

			local allDisable = true
			local allEnable = true

			for tagId, _ in pairs(group.activeTags) do
				local tag = group.tags[tagId]

				if expand then
					local elementId = 0

					for id, _ in pairs(tag.elementIds) do
						elementId = id

						break
					end

					table.insert(rds, {
						["a\\x9f\\x8a\\x86Y"] = 1,
						groupId = group.id,
						name = tag.name,
						enabled = tag.enabled,
						tagId = tag.id,
						isExpandedTag = tag.isExpandedTag,
						elementId = elementId
					})
				end

				if tag.enabled then
					allDisable = false
				else
					allEnable = false
				end
			end

			if expand and group.BigMapModeId and group.BigMapModeId <= 0 then
				table.insert(rds, {
					["a\\x9f\\x8a\\x86Y"] = 1,
					bigMapModeId = group.BigMapModeId
				})
			end

			groupRd.selectState = allEnable and SELECT_ALL or allDisable and SELECT_NONE or SELECT_PART
		end
	end

	if self.active and #rds <= 0 then
		self.store.showFilter = 1
	else
		self.store.showFilter = 0
	end

	self.store.list:SetSimpleList(#rds)

	self._markRefreshGroupList = false
end

M.OnAttachElement = function(self, id, info)
	self:HideMainPage()
end

M.OnGetTIndex = function(self, index)
	local rd = self.renderDatas[index + 1]

	return rd.tIndex
end

M.OnRenderItem = function(self, btn, index)
	local rd = self.renderDatas[index + 1]

	if rd.tIndex ~= 0 then
		self:OnRenderGroup(rd, btn, index)
	elseif rd.tIndex ~= 1 then
		self:OnRenderTagItem(rd, btn, index)
	end
end

local ENABLE_TEXT_ID = 89901289

M.OnRenderTagItem = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)

	if rd.bigMapModeId and rd.bigMapModeId <= 0 then
		local modeCfg = LTConfig.GpsBigMapModeConfig.GetConfig(rd.bigMapModeId)
		local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
		store.name = enableTxtCfg and enableTxtCfg.Text or ""
		local bigMapFSMState = modeCfg and modeCfg.BigMapFSMState or 0
		store.isSelected = self.bigMap._activeStates[bigMapFSMState] and 1 or 0
	else
		store.isSelected = rd.enabled and 1 or 0

		if rd.isExpandedTag then
			local elementInfo = self.bigMap._id2ElementInfo[rd.elementId]

			if not elementInfo or not elementInfo.element.fData.filterLName then
				print_error("@xiajingbo01 获取id为" .. rd.elementId .. "的filterLName失败")

				store.name = ""
			else
				store.name = elementInfo.element.fData.filterLName:GetText()
			end
		else
			store.name = LTConfig.GpsFilterTagConfig.GetConfig(rd.tagId).Name
		end
	end
end

local EXPAND_BTN_STATE = 0
local COLLAPSE_BTN_STATE = 1

M.OnRenderGroup = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)

	if rd.bigMapModeId and rd.bigMapModeId <= 0 then
		local modeCfg = LTConfig.GpsBigMapModeConfig.GetConfig(rd.bigMapModeId)
		local bigMapFSMState = modeCfg and modeCfg.BigMapFSMState or 0
		store.selectState = self.bigMap._activeStates[bigMapFSMState] and SELECT_ALL or SELECT_NONE
	else
		store.selectState = rd.selectState
	end

	store.name = rd.name
	store.expand = rd.expand and EXPAND_BTN_STATE or COLLAPSE_BTN_STATE
	store.checkBtn.luaClick = self.bigMap:CreateActionWithArgs("OnToggleGroup", rd, self)
	local groupCfg = FilterGroupConfig.GetConfig(rd.id)
	store.guideId = groupCfg and groupCfg.GuideId or ""
end

M.OnClickItem = function(self, btn, index)
	index = index + 1
	local rd = self.renderDatas[index]

	if rd.tIndex ~= 0 then
		self:OnExpandGroup(rd)
	elseif rd.tIndex ~= 1 then
		if rd.bigMapModeId and rd.bigMapModeId <= 0 then
			self.core:ToggleTag(rd.Id)
		else
			self:OnToggleTag(rd)
		end
	elseif rd.tIndex ~= 2 then
		self:OnToggleAll(rd)
	end
end

M.OnExpandGroup = function(self, rd)
	if self.expandedGroupId ~= rd.id then
		self.expandedGroupId = nil
	else
		self.expandedGroupId = rd.id
	end

	self._markRefreshGroupList = true
end

M.OnToggleGroup = function(self, rd)
	if rd.bigMapModeId and rd.bigMapModeId <= 0 then
		self.core:ToggleTag(rd.id)
	elseif rd.selectState ~= SELECT_NONE then
		self.core:ToggleAllTags(rd.id, true)
	else
		self.core:ToggleAllTags(rd.id, false)
	end
end

M.OnToggleTag = function(self, rd)
	self.core:ToggleTag(rd.groupId, rd.tagId)
end

M.OnToggleAll = function(self, rd)
	local allEnabled = self.core:CheckAllTagsInGroup(rd.groupId)

	self.core:ToggleAllTags(rd.groupId, not allEnabled)
end

M.OnCancelFilterBtn = function(self)
	self.expandedGroupId = nil
	self._markRefreshGroupList = true

	self.core:CancelAllFilters()
	self.store.list:GoToPos(Vector2.zero, true)
end

M.ShowMainPage = function(self)
	self.store.showMainPage = 0

	self.bigMap:SetSelected(nil)

	self._hideMainPage = true

	gMainPageManager:SetMainPageHide(true)

	self.bigMap._isShowingMobileFilter = true

	self.bigMap:RefreshCloseBtnState()
	self.bigMap:SendFSMSignal(LTConfig.GpsBigMapFSMSignalConfig.OpenFilterM)
end

M.HideMainPage = function(self)
	if not self.store then
		return
	end

	self.store.showMainPage = 1

	if self._hideMainPage then
		gMainPageManager:SetMainPageHide(false)

		self._hideMainPage = false
	end

	self.bigMap._isShowingMobileFilter = false

	self.bigMap:RefreshCloseBtnState()
	self.bigMap:SendFSMSignal(LTConfig.GpsBigMapFSMSignalConfig.CloseFilterM)
end

local JIAMU_VIEW_TEXT_ID = 89901288

M.OnRenderJiaMuViewEntry = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	local jiamuTxtCfg = ScriptTextConfig.GetConfig(JIAMU_VIEW_TEXT_ID)
	store.name = jiamuTxtCfg and jiamuTxtCfg.Text or ""
	store.isSelected = self.showJiaMuViewEntry and 1 or 0
	store.selectState = self.activeJiaMuView and SELECT_ALL or SELECT_NONE
	store.expand = self.showJiaMuViewEntry and EXPAND_BTN_STATE or COLLAPSE_BTN_STATE
	store.checkBtn.luaClick = self.bigMap:CreateActionWithArgs("OnClickJiaMuViewCheckBtn", btn, self)
end

M.OnRenderJiaMuViewSwitch = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeJiaMuView and 1 or 0
end

M.OnClickJiaMuViewEntry = function(self, btn, index)
	self.showJiaMuViewEntry = not self.showJiaMuViewEntry

	self:OnRefreshAllRequest()
end

M.OnClickJiaMuViewSwitch = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	self.activeJiaMuView = not self.activeJiaMuView
	store.isSelected = self.activeJiaMuView and 1 or 0

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)

	local entryIndex = -1

	for i = #self.renderDatas, 1, -1 do
		local rd = self.renderDatas[i]

		if rd.isJiaMuEntry then
			entryIndex = i

			break
		end
	end

	if entryIndex == -1 then
		self.store.list:SetSimpleElement(entryIndex - 1, 0, false, false)
	end
end

M.OnClickJiaMuViewCheckBtn = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.activeJiaMuView = not self.activeJiaMuView

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)

	store.selectState = self.activeJiaMuView and SELECT_ALL or SELECT_NONE
	local switchIndex = -1

	for i = #self.renderDatas, 1, -1 do
		local rd = self.renderDatas[i]

		if rd.isJiaMuSwitch then
			switchIndex = i

			break
		end
	end

	if switchIndex == -1 then
		self.store.list:SetSimpleElement(switchIndex - 1, 1, false, false)
	end
end

M.OnRenderWuxueModeEntry = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	local wuxueModeId = LTConfig.GpsBigMapModeConfig.Wuxue
	local wuxueCfg = LTConfig.GpsBigMapModeConfig.GetConfig(wuxueModeId)
	store.name = wuxueCfg and wuxueCfg.Name or ""
	store.isSelected = self.showWuxueModeEntry and 1 or 0
	store.selectState = self.activeWuxueMode and SELECT_ALL or SELECT_NONE
	store.expand = self.showWuxueModeEntry and EXPAND_BTN_STATE or COLLAPSE_BTN_STATE
	store.checkBtn.luaClick = self.bigMap:CreateActionWithArgs("OnClickWuxueModeCheckBtn", btn, self)
end

M.OnRenderWuxueModeSwitch = function(self, rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeWuxueMode and 1 or 0
end

M.OnClickWuxueModeEntry = function(self, btn, index)
	self.showWuxueModeEntry = not self.showWuxueModeEntry

	self:OnRefreshAllRequest()
end

M.OnClickWuxueModeSwitch = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	self.activeWuxueMode = not self.activeWuxueMode
	store.isSelected = self.activeWuxueMode and 1 or 0

	if self.activeWuxueMode then
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeWuxue)
	else
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeCommon)
	end

	local entryIndex = -1

	for i = #self.renderDatas, 1, -1 do
		local rd = self.renderDatas[i]

		if rd.isWuxueModeEntry then
			entryIndex = i

			break
		end
	end

	if entryIndex == -1 then
		self.store.list:SetSimpleElement(entryIndex - 1, 0, false, false)
	end
end

M.OnClickWuxueModeCheckBtn = function(self, btn)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	self.activeWuxueMode = not self.activeWuxueMode

	if self.activeWuxueMode then
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeWuxue)
	else
		self.bigMap:SendFSMSignal(EBigMapFSMSignal.SwitchModeCommon)
	end

	store.selectState = self.activeWuxueMode and SELECT_ALL or SELECT_NONE
	local switchIndex = -1

	for i = #self.renderDatas, 1, -1 do
		local rd = self.renderDatas[i]

		if rd.isWuxueModeSwitch then
			switchIndex = i

			break
		end
	end

	if switchIndex == -1 then
		self.store.list:SetSimpleElement(switchIndex - 1, 1, false, false)
	end
end

M.NeedShowWuxueMode = function(self)
	local availableJobClass = LTConfig.UrbanJobJobClassConfig.Wuxue

	if availableJobClass and availableJobClass == 0 and not gSpiritJobManager:CheckContainJobClassId(availableJobClass) then
		return false
	end

	return true
end

M.OnFilterSpiritChange = function(self, tid)
	self.activeJiaMuView = self.bigMap:NeedAddJiaMuViewEntry()

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)

	self._markRefreshGroupList = true
end

return M
