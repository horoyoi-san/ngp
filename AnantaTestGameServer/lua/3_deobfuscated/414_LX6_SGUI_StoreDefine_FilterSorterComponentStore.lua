local InputButtonNameConfig = LTConfig.InputButtonNameConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_FilterSorterComponentStore = DefClass("C_FilterSorterComponentStore", C_FilterSorterComponentStore, C_StoreGroup)
GroupName2Class.FilterSorterComponentStore = C_FilterSorterComponentStore
local M = C_FilterSorterComponentStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}
local ASCENDING = {
	DOWN = 552,
	UP = 551
}

function M:ctor()
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

function M:OnAwake()
	self.bindData.dropSelector.luaSelectedChanged = self:CreateAction(self.OnDropSelectorSelectedChange)
	self.bindData.dropSelector.luaClick = self:CreateAction(self.OnDropSelectorClick)
	self.bindData.dropSelector.luaRenderPopup = self:CreateAction(self.OnDropSelectorRenderPopup)
	self.bindData.sortBtn.luaClick = self:CreateAction(self.OnSortBtnClick)
	self.bindData.filterBtn.luaClick = self:CreateAction(self.OnFilterBtnClick)
	self.bindData.filterCloseBtn.luaClick = self:CreateAction(self.OnFilterCloseBtnClick)
	self.bindData.filterList.luaSimpleRenderItem = self:CreateAction(self.OnFilterListRenderItem)
	self.bindData.vSorterBtn.luaClick = self:CreateAction(self.OnVSortBtnClick)
end

function M:OnStart()
	self.filterList = self.filterList or {}
end

function M:OnDestroy()
	self.onSortChanged = nil
	self.onFilterBtnClick = nil
	self.onFilterMenuClose = nil
	self.onFilterMenuShow = nil
	self.onDropSelectorClick = nil
	self.onFilterChanged = nil
	self.filterList = nil
end

function M:OnDropSelectorRenderPopup(popup, list)
	list.luaRenderItem = self:CreateAction(self.OnRenderPopupListItem)
end

function M:OnRenderPopupListItem(btn, index)
	local store = gStoreManager:GetStoreGroup("FilterSorterComponentStore"):GetStoreByWidget(btn)
	local data = self.sortList[index + 1]

	if store and data then
		store.title = InputButtonNameConfig.GetConfig(data.title).Name
	end
end

function M:OnDropSelectorSelectedChange()
	local selectIndex = self.bindData.dropSelector.selectedIndex + 1
	local data = self.sortList[selectIndex]

	self:SetDropTitle(data.title)
	self.bindData.dropSelector:ClosePopUp()

	self.sortId = data.id

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

function M:OnDropSelectorClick()
	if self.bindData.dropSelector.isPopup then
		self:SetFilterMenuShow(false)
	end

	if self.onDropSelectorClick then
		self.onDropSelectorClick()
	end
end

function M:OnSortBtnClick()
	self:SetAscending(not self.isAscending)
	self.bindData.dropSelector:ClosePopUp()

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

function M:OnVSortBtnClick()
	local selectIndex = self.bindData.dropSelector.selectedIndex + 1

	if selectIndex >= #self.sortList then
		selectIndex = 0
	end

	self.bindData.dropSelector:SelectOption(selectIndex)
end

function M:OnFilterBtnClick()
	if self.onFilterBtnClick then
		self.onFilterBtnClick(self.bindData.showFilterMenuCtrl == BOOL2CTL[true])
	else
		self:SetFilterMenuShow(self.bindData.showFilterMenuCtrl ~= BOOL2CTL[true])
	end
end

function M:OnFilterCloseBtnClick()
	self:SetFilterMenuShow(false)
end

function M:SetFilterMenuShow(show)
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

function M:OnFilterListRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup("FilterSorterComponentStore"):GetStoreByWidget(btn)
	local data = self.filterList[index + 1]

	if store and data then
		store.title = data.title
		store.list.groupType = data.type or 1
		store.list.luaSimpleRenderItem = self:CreateActionWithArgs("OnFilterSubListRenderItem", index + 1)

		store.list:SetSimpleList(#data.subList)
	end
end

function M:OnFilterSubListRenderItem(filterIndex, btn, index)
	local store = gStoreManager:GetStoreGroup("FilterSorterComponentStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.filterList[filterIndex].subList[index + 1]
	store.title = data.title
	btn.luaSelectChanged = self:CreateActionWithArgs("OnSubListSelectedChanged", {
		self.filterList[filterIndex].id,
		data.id,
		self.filterList[filterIndex].type
	})
end

function M:OnSubListSelectedChanged(args, selected)
	if selected then
		if args[3] == 2 then
			self.filterSelect[args[1]][args[2]] = selected
		else
			table.clear(self.filterSelect[args[1]])

			self.filterSelect[args[1]][args[2]] = selected
		end
	else
		self.filterSelect[args[1]][args[2]] = nil
	end

	if self.onFilterChanged then
		self.onFilterChanged(self.filterSelect)
	end
end

function M:SetData(data)
	if not data then
		return
	end

	self.onSortChanged = data.onSortChanged
	self.onFilterBtnClick = data.onFilterBtnClick
	self.onFilterMenuClose = data.onFilterMenuClose
	self.onFilterMenuShow = data.onFilterMenuShow
	self.onDropSelectorClick = data.onDropSelectorClick
	self.isAscending = data.isAscending

	if self.isAscending == nil then
		self.isAscending = true
	end

	self:SetAscending(self.isAscending)

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

		self.bindData.dropSelector:SetOptions(self.sortList)
		self.bindData.dropSelector:SelectOption(selectedIndex, false)

		self.sortId = selectedItem.id

		self:SetDropTitle(selectedItem.title)
	end

	local hasFilterList = not table.isNilOrEmpty(data.filterList)
	local hasFilterBtn = data.onFilterBtnClick ~= nil
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

function M:SelectOption(index, sendCallback)
	self.bindData.dropSelector:SelectOption(index, sendCallback)
end

function M:GetSelectedItem()
	return self.bindData.dropSelector.selectedItem
end

function M:SetDropTitle(title)
	self.bindData.droptitle = InputButtonNameConfig.GetConfig(title).Name

	self.bindData.navigationArea:SetButtonInfoTipNameId(title, 1)
end

function M:SetAscending(isAscending)
	self.isAscending = isAscending
	self.bindData.sortCtrl = BOOL2CTL[self.isAscending]

	self:SetFilterMenuShow(false)
	self.bindData.navigationArea:SetButtonInfoTipNameId(isAscending and ASCENDING.UP or ASCENDING.DOWN, 0)
end

function M:SetFilterMenuState(hasFilter)
	if hasFilter then
		self.bindData.filterMenuActive = BOOL2CTL[false]
		self.bindData.showFilterMenuCtrl = BOOL2CTL[true]
	else
		self.bindData.filterMenuActive = BOOL2CTL[true]
		self.bindData.showFilterMenuCtrl = BOOL2CTL[false]
	end
end

function M:ResetFilter(sendCallback)
	self.filterSelect = self.filterSelect or {}

	table.clear(self.filterSelect)

	if not table.isNilOrEmpty(self.filterList) then
		for i = 1, #self.filterList do
			self.filterSelect[self.filterList[i].id] = {}
		end

		self.bindData.filterList:SetSimpleList(#self.filterList)
	end

	self:SetFilterMenuShow(false)

	if sendCallback and self.onFilterChanged then
		self.onFilterChanged(self.filterSelect)
	end
end
