-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\DropMenuTemplateStore.lua
-- Decompiled from: 01836_DropMenuTemplateStore.lua_95c38bf0b37b.luajit

C_DropMenuTemplateStore = DefClass("C_DropMenuTemplateStore", C_DropMenuTemplateStore, C_StoreGroup)
GroupName2Class.DropMenuTemplateStore = C_DropMenuTemplateStore
local M = C_DropMenuTemplateStore
local BOOL2CTL = {
	[true] = 0,
	[false] = 1
}

M.ctor = function(self)
	self.onSortChanged = nil
	self.onFilterBtnClick = nil
	self.isAscending = false
	self.sortId = 0
	self.onFilterChanged = nil
	self.filterList = {}
	self.sortList = {}
end

M.OnAwake = function(self)
	self.bindData.dropSelector.luaSimpleOptionClick = self.CreateAction(self, "OnDropSelectorSelectedChange")
	self.bindData.sortBtn.luaClick = self.CreateAction(self, "OnSortBtnClick")
	self.bindData.filterBtn.luaClick = self.CreateAction(self, "OnFilterBtnClick")

	if self.bindData.controllerDropBtn then
		self.bindData.controllerDropBtn.luaClick = self.CreateAction(self, "OnSortChangeClick")
	end

	if self.bindData.filterList then
		self.bindData.filterList.luaSimpleRenderItem = self.CreateAction(self, self.OnFilterListRenderItem)
	end
end

M.OnStart = function(self)
	self.filterList = {}
end

M.OnDestroy = function(self)
end

M.OnDropSelectorSelectedChange = function(self, btn, index)
	local selectedItem = self.sortList[index + 1]

	if not selectedItem then
		return
	end

	self.sortId = selectedItem.id
	self.bindData.droptitle = selectedItem.label

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

M.OnSortBtnClick = function(self)
	self.isAscending = not self.isAscending
	self.bindData.isAscending = BOOL2CTL[self.isAscending]

	if self.onSortChanged then
		self.onSortChanged(self.sortId, self.isAscending)
	end
end

M.OnSortChangeClick = function(self)
	local index = self.bindData.dropSelector.selectedIndex + 1

	if index > #self.sortList then
		index = 0
	end

	self.bindData.dropSelector:SelectOption(index)
end

M.OnFilterBtnClick = function(self)
	if self.onFilterBtnClick then
		self.onFilterBtnClick(self.bindData.showFilterMenu)
	end
end

M.SetFilterMenuState = function(self, flag)
	self.bindData.showFilterMenu = BOOL2CTL[flag]
end

M.OnFilterListRenderItem = function(self, btn, index)
	local data = self.filterList[index + 1]
	local store = self.GetStoreByWidget(self, btn)

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

M.OnSubListSelectedChanged = function(self, uList, index)
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

M.SetData = function(self, data)
	if not data then
		return
	end

	self.onSortChanged = data.onSortChanged
	self.onFilterBtnClick = data.onFilterBtnClick
	self.isAscending = data.isAscending

	if self.isAscending ~= nil then
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

		self.bindData.dropSelector:SetSimpleOptions(#data.sortList)

		for i = 1, #data.sortList do
			self.bindData.dropSelector:SetItemLabel(i - 1, data.sortList[i].label)
			self.bindData.dropSelector:SetItemDisabled(i - 1, data.sortList[i].disabled ~= true)
		end

		self.bindData.dropSelector:SelectOption(selectedIndex, false)

		self.bindData.droptitle = data.sortList[selectedIndex + 1] and data.sortList[selectedIndex + 1].label or ""
		self.sortId = data.sortList[selectedIndex + 1] and data.sortList[selectedIndex + 1].id or 0
	end

	if self.bindData.filterList then
		self.onFilterChanged = data.onFilterChanged

		if not table.isNilOrEmpty(data.filterList) then
			self.filterList = data.filterList

			self.bindData.filterList:SetSimpleList(#self.filterList)
		end
	end
end

M.SelectOption = function(self, index, sendCallback)
	self.bindData.dropSelector:SelectOption(index, sendCallback)
end

M.GetSelectedItem = function(self)
	return self.sortList[self.bindData.dropSelector.selectedIndex + 1]
end
