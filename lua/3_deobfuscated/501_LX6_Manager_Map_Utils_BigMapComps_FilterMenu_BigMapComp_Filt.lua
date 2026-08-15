BigMapComp_FilterMenu_MobileView = BigMapComp_FilterMenu_MobileView or {}
local M = BigMapComp_FilterMenu_MobileView
M.__index = M
local ScriptTextConfig = LTConfig.TextScriptTextConfig

function M.new(core, bigMap)
	local self = setmetatable({}, M)
	self.core = core
	self.bigMap = bigMap
	self.bindData = bigMap.bindData
	self.groupViewItems = {}
	self.showJiaMuViewEntry = false
	self.activeJiaMuView = false
	self.expandedGroupId = nil

	return self
end

function M:Refresh()
	if self.active then
		if self.widget == nil then
			self.bindData.filterMenuTab.OnRenderTab = self.bigMap:CreateAction("OnPanelLoaded", self)
			self.bindData.filterMenuTab.selectedIndex = 1

			return
		end

		self.store.showFilter = 1
	elseif self.store then
		self.store.showFilter = 0
	end
end

function M:OnUpdate()
	if not self.store then
		return
	end

	if self._markRefreshGroupList then
		self:RefreshList()
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
	self.store = gStoreManager:GetStoreGroup("BigMapStore_Filter_Mobile"):GetStoreByWidget(self.widget)
	self.store.list.luaSimpleRenderItem = self.bigMap:CreateAction("OnRenderItem", self)
	self.store.list.onGetTIndex = self.bigMap:CreateAction("OnGetTIndex", self)
	self.store.list.luaSimpleClick = self.bigMap:CreateAction("OnClickItem", self)
	self.store.clickCancel = self.bigMap:CreateAction("OnCancelFilterBtn", self)
	self.store.clickClose = self.bigMap:CreateAction("HideMainPage", self)
	self.store.clickEntry = self.bigMap:CreateAction("ShowMainPage", self)

	self.core:SetView(self)
	self.bigMap:EnableJiaMuView(self.activeJiaMuView)
	self:Refresh()
	self:HideMainPage()
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

local SELECT_ALL = 0
local SELECT_PART = 1
local SELECT_NONE = 2

function M:RefreshList()
	if not self.store then
		return
	end

	local allGroups = self.core:GetAllGroups()
	self.renderDatas = {}
	local rds = self.renderDatas

	for _, group in pairs(allGroups) do
		if group.visible then
			local expand = group.id == self.expandedGroupId
			local groupRd = {
				tIndex = 0,
				id = group.id,
				name = group.name,
				expand = expand
			}

			table.insert(rds, groupRd)

			local allDisable = true
			local allEnable = true

			for _, tag in pairs(group.tags) do
				if expand then
					table.insert(rds, {
						tIndex = 1,
						groupId = group.id,
						name = tag.name,
						enabled = tag.enabled,
						tagId = tag.id,
						isExpandedTag = tag.isExpandedTag,
						elementId = tag.elementId
					})
				end

				if tag.enabled then
					allDisable = false
				else
					allEnable = false
				end
			end

			groupRd.selectState = allEnable and SELECT_ALL or allDisable and SELECT_NONE or SELECT_PART
		end
	end

	if self.bigMap:NeedAddJiaMuViewEntry() then
		table.insert(rds, {
			tIndex = 0,
			isJiaMuEntry = true,
			expand = self.showJiaMuViewEntry
		})

		if self.showJiaMuViewEntry then
			table.insert(rds, {
				tIndex = 1,
				isJiaMuSwitch = true
			})
		end
	end

	self.store.list:SetSimpleList(#rds)

	self._markRefreshGroupList = false
end

function M:OnAttachElement(id, info)
	self:HideMainPage()
end

function M:OnGetTIndex(index)
	local rd = self.renderDatas[index + 1]

	return rd.tIndex
end

function M:OnRenderItem(btn, index)
	local rd = self.renderDatas[index + 1]

	if rd.isJiaMuEntry then
		return self:OnRenderJiaMuViewEntry(rd, btn, index)
	elseif rd.isJiaMuSwitch then
		return self:OnRenderJiaMuViewSwitch(rd, btn, index)
	end

	if rd.tIndex == 0 then
		self:OnRenderGroup(rd, btn, index)
	elseif rd.tIndex == 1 then
		self:OnRenderTagItem(rd, btn, index)
	end
end

function M:OnRenderTagItem(rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
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

local EXPAND_BTN_STATE = 0
local COLLAPSE_BTN_STATE = 1

function M:OnRenderGroup(rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	store.selectState = rd.selectState
	store.name = rd.name
	store.expand = rd.expand and EXPAND_BTN_STATE or COLLAPSE_BTN_STATE
	store.checkBtn.luaClick = self.bigMap:CreateActionWithArgs("OnToggleGroup", rd, self)
end

function M:OnClickItem(btn, index)
	index = index + 1
	local rd = self.renderDatas[index]

	if rd.isJiaMuEntry then
		return self:OnClickJiaMuViewEntry(btn)
	elseif rd.isJiaMuSwitch then
		return self:OnClickJiaMuViewSwitch(btn)
	end

	if rd.tIndex == 0 then
		self:OnExpandGroup(rd)
	elseif rd.tIndex == 1 then
		self:OnToggleTag(rd)
	elseif rd.tIndex == 2 then
		self:OnToggleAll(rd)
	end
end

function M:OnExpandGroup(rd)
	if self.expandedGroupId == rd.id then
		self.expandedGroupId = nil
	else
		self.expandedGroupId = rd.id
	end

	self._markRefreshGroupList = true
end

function M:OnToggleGroup(rd)
	if rd.selectState == SELECT_NONE then
		self.core:ToggleAllTags(rd.id, true)
	else
		self.core:ToggleAllTags(rd.id, false)
	end
end

function M:OnToggleTag(rd)
	self.core:ToggleTag(rd.groupId, rd.tagId)
end

function M:OnToggleAll(rd)
	local allEnabled = self.core:CheckAllTagsInGroup(rd.groupId)

	self.core:ToggleAllTags(rd.groupId, not allEnabled)
end

function M:OnCancelFilterBtn()
	self.expandedGroupId = nil
	self._markRefreshGroupList = true

	self.core:CancelAllFilters()
	self.store.list:GoToPos(Vector2.zero, true)
end

function M:ShowMainPage()
	self.store.showMainPage = 0

	self.bigMap:SetSelected(nil)

	self._hideMainPage = true

	gMainPageManager:SetMainPageHide(true)

	self.bigMap._isShowingMobileFilter = true

	self.bigMap:RefreshCloseBtnState()
end

function M:HideMainPage()
	self.store.showMainPage = 1

	if self._hideMainPage then
		gMainPageManager:SetMainPageHide(false)

		self._hideMainPage = false
	end

	self.bigMap._isShowingMobileFilter = false

	self.bigMap:RefreshCloseBtnState()
end

local JIAMU_VIEW_TEXT_ID = 89901288
local ENABLE_TEXT_ID = 89901289

function M:OnRenderJiaMuViewEntry(rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterGroupItem"):GetStoreByWidget(btn)
	local jiamuTxtCfg = ScriptTextConfig.GetConfig(JIAMU_VIEW_TEXT_ID)
	store.name = jiamuTxtCfg and jiamuTxtCfg.Text or ""
	store.isSelected = self.showJiaMuViewEntry and 1 or 0
	store.selectState = self.activeJiaMuView and SELECT_ALL or SELECT_NONE
	store.expand = self.showJiaMuViewEntry and EXPAND_BTN_STATE or COLLAPSE_BTN_STATE
	store.checkBtn.luaClick = self.bigMap:CreateActionWithArgs("OnClickJiaMuViewCheckBtn", btn, self)
end

function M:OnRenderJiaMuViewSwitch(rd, btn, index)
	local store = gStoreManager:GetStoreGroup("BigMapStore_FilterTagItem"):GetStoreByWidget(btn)
	local enableTxtCfg = ScriptTextConfig.GetConfig(ENABLE_TEXT_ID)
	store.name = enableTxtCfg and enableTxtCfg.Text or ""
	store.isSelected = self.activeJiaMuView and 1 or 0
end

function M:OnClickJiaMuViewEntry(btn, index)
	self.showJiaMuViewEntry = not self.showJiaMuViewEntry

	self:OnRefreshAllRequest()
end

function M:OnClickJiaMuViewSwitch(btn)
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

	if entryIndex ~= -1 then
		self.store.list:SetSimpleElement(entryIndex - 1, 0, false, false)
	end
end

function M:OnClickJiaMuViewCheckBtn(btn)
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

	if switchIndex ~= -1 then
		self.store.list:SetSimpleElement(switchIndex - 1, 1, false, false)
	end
end

function M:OnFilterSpiritChange(tid)
	self.activeJiaMuView = self.bigMap:NeedAddJiaMuViewEntry()

	self.bigMap:EnableJiaMuView(self.activeJiaMuView)

	self._markRefreshGroupList = true
end

return M
