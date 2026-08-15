C_DropMenuTemplateStore = DefClass("C_DropMenuTemplateStore", C_DropMenuTemplateStore, C_StoreGroup)
GroupName2Class.DropMenuTemplateStore = C_DropMenuTemplateStore
local M = C_DropMenuTemplateStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

function M:ctor()
	self.onSortChanged = nil
	self.onFilterBtnClick = nil
	self.isAscending = false
	self.sortId = 0
	self.onFilterChanged = nil
	self.filterList = {}
	self.sortList = {}
end

function M:OnAwake()
	self.bindData.dropSelector.luaSelectedChanged = self:CreateAction("OnDropSelectorSelectedChange")
	self.bindData.sortBtn.luaClick = self:CreateAction("OnSortBtnClick")
	self.bindData.filterBtn.luaClick = self:CreateAction("OnFilterBtnClick")

	if self.bindData.controllerDropBtn then
		self.bindData.controllerDropBtn.luaClick = self:CreateAction("OnSortChangeClick")
	end

	if self.bindData.filterList then
		self.bindData.filterList.luaSimpleRenderItem = self:CreateAction(self.OnFilterListRenderItem)
	end
end

function M:OnStart()
	self.filterList = {}
end

function M:OnDestroy()
	return
end

function M:OnDropSelectorSelectedChange(selector)
	self.sortId = selector.selectedItem.id
	self.bindData.droptitle = selector.selectedItem.label

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

function M:OnSortBtnClick()
	self.isAscending = not self.isAscending
	self.bindData.isAscending = BOOL2CTL[self.isAscending]

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

function M:OnSortChangeClick()
	local index = self.bindData.dropSelector.selectedIndex + 1

	if index >= #self.sortList then
		index = 0
	end

	self.bindData.dropSelector:SelectOption(index)
end

function M:OnFilterBtnClick()
	if self.onFilterBtnClick then
		self.onFilterBtnClick(self.bindData.showFilterMenu)
	end
end

function M:SetFilterMenuState(flag)
	self.bindData.showFilterMenu = BOOL2CTL[flag]
end

function M:OnFilterListRenderItem(btn, index)
	local data = self.filterList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.subTitle = data.title
	store.subList.groupType = data.type
	store.subList.luaSelectedChanged = self:CreateActionWithArgs("OnSubListSelectedChanged", data.id)

	store.subList:InitSimpleList()

	for i = 1, #data.subList do
		store.subList:AddSimpleLabel(0, data.subList[i].label, i, data.subList[i].selected)
	end

	store.subList:RefreshList()
end

function M:OnSubListSelectedChanged(uList, index)
	local ret = {}

	for i = 1, #self.filterList do
		ret[i] = {}

		for j = 1, #self.filterList[i].subList do
			if self.filterList[i].subList[j].selected then
				table.insert(ret[i], self.filterList[i].subList[j].id)
			end
		end
	end

	if self.onFilterChanged then
		self.onFilterChanged(ret)
	end
end

function M:SetData(data)
	if not data then
		return
	end

	self.onSortChanged = data.onSortChanged
	self.onFilterBtnClick = data.onFilterBtnClick
	self.isAscending = data.isAscending

	if self.isAscending == nil then
		self.isAscending = true
	end

	self.bindData.isAscending = BOOL2CTL[self.isAscending]

	if not table.isNilOrEmpty(data.sortList) then
		local selectedIndex = 0

		for i = 1, #data.sortList do
			if data.sortList[i].selected then
				selectedIndex = i - 1

				break
			end
		end

		self.sortList = data.sortList

		self.bindData.dropSelector:SetOptions(data.sortList)

		self.bindData.dropSelector.selectedIndex = selectedIndex
	end

	if self.bindData.filterList then
		self.onFilterChanged = data.onFilterChanged

		if not table.isNilOrEmpty(data.filterList) then
			self.filterList = data.filterList

			self.bindData.filterList:SetSimpleList(#self.filterList)
		end
	end
end

function M:SelectOption(index, sendCallback)
	self.bindData.dropSelector:SelectOption(index, sendCallback)
end

function M:GetSelectedItem()
	return self.bindData.dropSelector.selectedItem
end
