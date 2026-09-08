-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\FilterSorterComponentStore.lua
-- Decompiled from: 01857_FilterSorterComponentStore.lua_eabcf9ac74a9.luajit

local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local UNavigationMgr = SGUI.UNavigationMgr
local Consts = gClientConst
C_FilterSorterComponentStore = DefClass("C_FilterSorterComponentStore", C_FilterSorterComponentStore, C_StoreGroup)
GroupName2Class.FilterSorterComponentStore = C_FilterSorterComponentStore
GroupName2Class.SuitFilterSorterComponentStore = C_FilterSorterComponentStore
local M = C_FilterSorterComponentStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local ASCENDING = {
	["^\rJu"] = 552,
	["59"] = 551
}

M.ctor = function(self)
	self.onSortChanged = nil
	self.onFilterBtnClick = nil
	self.onFilterMenuClose = nil
	self.onFilterMenuShow = nil
	self.onDropSelectorClick = nil
	self.isAscending = false
	self.sortId = 0
	self.onFilterChanged = nil
	self.filterList = self.filterList or {}
end

M.OnAwake = function(self)
	self.bindData.dropSelector.luaSelectedChanged = self.CreateAction(self, self.OnDropSelectorSelectedChange)
	self.bindData.dropSelector.luaClick = self.CreateAction(self, self.OnDropSelectorClick)
	self.bindData.dropSelector.luaRenderPopup = self.CreateAction(self, self.OnDropSelectorRenderPopup)
	self.bindData.sortBtn.luaClick = self.CreateAction(self, self.OnSortBtnClick)
	self.bindData.sortBtnLong.luaLongPress = self.CreateAction(self, self.OnSortBtnClick)
	self.bindData.filterBtn.luaClick = self.CreateAction(self, self.OnFilterBtnClick)
	self.bindData.filterBtnLong.luaLongPress = self.CreateAction(self, self.OnFilterBtnClick)
	self.bindData.filterCloseBtn.luaClick = self.CreateAction(self, self.OnFilterCloseBtnClick)
	self.bindData.filterList.luaSimpleRenderItem = self.CreateAction(self, self.OnFilterListRenderItem)
	self.bindData.vSorterBtn.luaClick = self.CreateAction(self, self.OnVSortBtnClick)
	self.bindData.vSorterBtnLong.luaLongPress = self.CreateAction(self, self.OnVSortBtnClick)
end

M.OnStart = function(self)
	self.filterList = self.filterList or {}
end

M.OnDestroy = function(self)
	self.onSortChanged = nil
	self.onFilterBtnClick = nil
	self.onFilterMenuClose = nil
	self.onFilterMenuShow = nil
	self.onDropSelectorClick = nil
	self.onFilterChanged = nil
	self.filterList = nil
end

M.OnDropSelectorRenderPopup = function(self, popup, list)
	list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderPopupListItem)
end

M.OnRenderPopupListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = self.sortList[index + 1]

	if store and data then
		store.title = InputButtonNameConfig.GetConfig(data.title).Name
	end
end

M.OnDropSelectorSelectedChange = function(self)
	local selectIndex = self.bindData.dropSelector.selectedIndex + 1
	local data = self.sortList[selectIndex]

	self:SetDropTitle(data.title)
	self.bindData.dropSelector:ClosePopUp()

	self.sortId = data.id

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

M.OnDropSelectorClick = function(self)
	if self.bindData.dropSelector.isPopup then
		self.SetFilterMenuShow(self, false)
	end

	if self.onDropSelectorClick then
		self.onDropSelectorClick()
	end
end

M.OnSortBtnClick = function(self)
	self:SetAscending(not self.isAscending)
	self.bindData.dropSelector:ClosePopUp()

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

M.OnVSortBtnClick = function(self)
	local selectIndex = self.bindData.dropSelector.selectedIndex + 1

	if selectIndex > #self.sortList then
		selectIndex = 0
	end

	self.bindData.dropSelector:SelectOption(selectIndex)
	self:SetFilterMenuShow(false)
end

M.OnFilterBtnClick = function(self)
	if self.onFilterBtnClick then
		self.onFilterBtnClick(self.bindData.showFilterMenuCtrl ~= BOOL2CTL[true])
	else
		self:SetFilterMenuShow(self.bindData.showFilterMenuCtrl == BOOL2CTL[true])
	end
end

M.OnFilterCloseBtnClick = function(self)
	self.SetFilterMenuShow(self, false)
end

M.SetFilterMenuShow = function(self, show)
	self.bindData.showFilterMenuCtrl = show and BOOL2CTL[true] or BOOL2CTL[false]

	if show then
		UNavigationMgr.Inst.CurrentActiveArea = self.bindData.filterNavigationArea

		if self.onFilterMenuShow then
			self.onFilterMenuShow()
		end
	else
		UNavigationMgr.Inst:UnRegisterArea(self.bindData.filterNavigationArea)

		if self.onFilterMenuClose then
			self.onFilterMenuClose()
		end
	end
end

M.OnFilterListRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("FilterSorterComponentStore"):GetStoreByWidget(btn)
	local data = self.filterList[index + 1]

	if store and data then
		store.title = data.title
		store.list.groupType = data.type or 1
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnFilterSubListRenderItem", index + 1)

		store.list:SetSimpleList(#data.subList)
	end
end

M.OnFilterSubListRenderItem = function(self, filterIndex, btn, index)
	local store = gStoreManager:GetStoreGroup("FilterSorterComponentStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.filterList[filterIndex].subList[index + 1]
	store.title = data.title
	btn.luaSelectChanged = self.CreateActionWithArgs(self, "OnSubListSelectedChanged", {
		self.filterList[filterIndex].id,
		data.id,
		self.filterList[filterIndex].type
	})
end

M.OnSubListSelectedChanged = function(self, args, selected)
	if selected then
		if args[3] ~= 2 then
			self.filterSelect[args[1]][args[2]] = selected
		else
			table.clear(self.filterSelect[args[1]])

			self.filterSelect[args[1]][args[2]] = selected
		end
	else
		self.filterSelect[args[1]][args[2]] = nil
	end

	local inFilter = false

	for k, v in pairs(self.filterSelect) do
		if not table.isNilOrEmpty(v) then
			for k1, v1 in pairs(v) do
				inFilter = v1 ~= true

				if inFilter then
					break
				end
			end
		end

		if inFilter then
			break
		end
	end

	self.bindData.inFilter = Consts.BOOL2CTL[inFilter]

	self.SetControllerState(self, inFilter)

	if self.onFilterChanged then
		self.onFilterChanged(self.filterSelect)
	end
end

M.SetData = function(self, data)
	if not data then
		return
	end

	self.onSortChanged = data.onSortChanged
	self.onFilterBtnClick = data.onFilterBtnClick
	self.onFilterMenuClose = data.onFilterMenuClose
	self.onFilterMenuShow = data.onFilterMenuShow
	self.onDropSelectorClick = data.onDropSelectorClick
	self.isAscending = data.isAscending

	if self.isAscending ~= nil then
		self.isAscending = true
	end

	self.SetAscending(self, self.isAscending)

	self.sortList = data.sortList
	local hasSort = not table.isNilOrEmpty(self.sortList)
	self.bindData.showSorter = BOOL2CTL[hasSort]
	self.bindData.showAscending = BOOL2CTL[hasSort]

	if hasSort then
		local selectedIndex = 0

		for i = 1, #self.sortList do
			if self.sortList[i].selected then
				selectedIndex = i - 1

				break
			end
		end

		local selectedItem = self.sortList[selectedIndex + 1]

		self.bindData.dropSelector:SetSimpleOptions(#self.sortList)
		self.bindData.dropSelector:SelectOption(selectedIndex, false)

		self.sortId = selectedItem.id

		self:SetDropTitle(selectedItem.title)

		if #self.sortList < 1 then
			self.bindData.showSorter = BOOL2CTL[false]
		end
	end

	local hasFilterList = not table.isNilOrEmpty(data.filterList)
	local hasFilterBtn = data.onFilterBtnClick == nil
	self.bindData.showFilter = BOOL2CTL[hasFilterList or hasFilterBtn]

	if hasFilterList then
		self.onFilterChanged = data.onFilterChanged
		self.filterSelect = self.filterSelect or {}

		table.clear(self.filterSelect)

		if not table.isNilOrEmpty(data.filterList) then
			for i = 1, #data.filterList do
				self.filterSelect[data.filterList[i].id] = {}
			end

			self.filterList = data.filterList

			self.bindData.filterList:SetSimpleList(#data.filterList)
		end
	end
end

M.SelectOption = function(self, index, sendCallback)
	self.bindData.dropSelector:SelectOption(index, sendCallback)
end

M.GetSelectedItem = function(self)
	local selectIndex = self.bindData.dropSelector.selectedIndex + 1

	return self.sortList and self.sortList[selectIndex]
end

M.SetDropTitle = function(self, title)
	self.bindData.droptitle = InputButtonNameConfig.GetConfig(title).Name

	self.bindData.navigationArea:SetButtonInfoTipNameId(title, 1)
end

M.SetAscending = function(self, isAscending)
	self.isAscending = isAscending
	self.bindData.sortCtrl = BOOL2CTL[self.isAscending]

	self:SetFilterMenuShow(false)
	self.bindData.navigationArea:SetButtonInfoTipNameId(isAscending and ASCENDING.UP or ASCENDING.DOWN, 0)
end

M.SetFilterMenuState = function(self, hasFilter)
	if hasFilter then
		self.bindData.filterMenuActive = BOOL2CTL[false]
		self.bindData.showFilterMenuCtrl = BOOL2CTL[true]
	else
		self.bindData.filterMenuActive = BOOL2CTL[true]
		self.bindData.showFilterMenuCtrl = BOOL2CTL[false]
	end
end

M.ResetFilter = function(self, sendCallback)
	self.filterSelect = self.filterSelect or {}

	table.clear(self.filterSelect)

	if not table.isNilOrEmpty(self.filterList) then
		for i = 1, #self.filterList do
			self.filterSelect[self.filterList[i].id] = {}
		end

		self.bindData.filterList:SetSimpleList(#self.filterList)
	end

	self.SetFilterMenuShow(self, false)
	self.SetControllerState(self, false)

	if sendCallback and self.onFilterChanged then
		self.onFilterChanged(self.filterSelect)
	end
end

local SELECTED_STYLE = 4
local NOT_SELECTED_STYLE = 2

M.SetControllerState = function(self, hasFilter)
	local fliterComponent = self.bindData.navigationArea

	if not fliterComponent then
		return
	end

	if hasFilter then
		fliterComponent.ChangeButtonTipInfoByActionId(fliterComponent, 10, 0, SELECTED_STYLE, 0, true, false)
	else
		fliterComponent.ChangeButtonTipInfoByActionId(fliterComponent, 10, 0, NOT_SELECTED_STYLE, 0, true, false)
	end
end
