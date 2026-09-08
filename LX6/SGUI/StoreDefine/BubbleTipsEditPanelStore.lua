-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\BubbleTipsEditPanelStore.lua
-- Decompiled from: 01630_BubbleTipsEditPanelStore.lua_6a31a8b14e6a.luajit

local StaticProps = {
	DISPLAY_TYPE = {
		["TP~"] = 2,
		["\\x89\\x987\\x9fB\\xdf\n"] = 1,
		["IZu"] = 0
	}
}
C_BubbleTipsEditPanelStore = DefClass("C_BubbleTipsEditPanelStore", C_BubbleTipsEditPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.BubbleTipsEditPanelStore = C_BubbleTipsEditPanelStore
local M = C_BubbleTipsEditPanelStore
local MonthLength = {
	31,
	29,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31
}

M.OnAwake = function(self)
	self.nowMonthDay = 0
	self.nowMonth = 0
	self.selectDay = 0
	self.dayDataList = {}
	self.monthList = {}
	self.bindData.monthList.luaSimpleRenderItem = self.CreateAction(self, self.OnMonthListRenderItem)
	self.bindData.monthList.luaSelectedChanged = self.CreateAction(self, "OnDateListSelectedChanged")
	self.bindData.dayList.luaSimpleRenderItem = self.CreateAction(self, self.OnDayListRenderItem)
	self.bindData.dayList.luaSelectedChanged = self.CreateAction(self, "OnDayListSelectedChanged")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnConfirmBtnClick")
	self.bindData.cancelBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnCloseBtnClick")
end

M.OnDestroy = function(self)
end

M.OnStart = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.confirmBtn.interactable = true

	self.RefreshMonthList(self)

	local selectedDay = math.max(gHunLunManager.birthdayCode % 100, 1)
	self.selectDay = selectedDay - 1

	self.RefreshDayList(self, true)

	if gHunLunManager.birthdayCode <= 0 then
		self.bindData.confirmBtn.interactable = false
	end
end

M.OnClose = function(self)
end

M.OnMonthListRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.monthList[index + 1]

	if not data then
		print_warn("[C_BubbleTipsEditPanelStore] OnDateListRenderItem data is nil", index)

		return
	end

	store.label = data.labelText
end

M.OnDayListRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.dayDataList[index + 1]

	if not data then
		print_warn("[C_BubbleTipsEditPanelStore] OnDateListRenderItem data is nil", index)

		return
	end

	store.label = data.labelText
end

M.OnDateListSelectedChanged = function(self, list)
	self.RefreshDayList(self)
end

M.OnDayListSelectedChanged = function(self, list)
	self.selectDay = list.selectedIndex
end

M.OnConfirmBtnClick = function(self)
	local month = self.monthList[self.bindData.monthList.selectedIndex + 1].labelText
	local day = self.dayDataList[self.bindData.dayList.selectedIndex + 1].labelText

	gHunLunManager:ChangeBirth(month, day, self:CreateAction("OnCloseBtnClick"))
end

M.OnCloseBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_BUBBLE_TIPS_EDIT_PANEL)
end

M.RefreshMonthList = function(self)
	local list = {}
	local selectedMonth = math.max(1, math.floor(gHunLunManager.birthdayCode / 100))
	self.nowMonth = selectedMonth - 1

	for i = 1, 12 do
		table.insert(list, {
			labelText = i,
			selected = selectedMonth ~= i
		})
	end

	self.monthList = list

	self.bindData.monthList:SetSimpleList(#self.monthList)
	self.bindData.monthList:SelectItem(selectedMonth - 1)
end

M.RefreshDayList = function(self, isFirst)
	if self.bindData.monthList.selectedIndex ~= -1 then
		return
	end

	local month = self.monthList[self.bindData.monthList.selectedIndex + 1].labelText

	if month ~= self.nowMonth and isFirst == true then
		return
	end

	self.nowMonth = month
	local selectedDay = math.min(self.selectDay, MonthLength[month] - 1)
	self.dayDataList = {}

	for i = 1, MonthLength[month] do
		table.insert(self.dayDataList, {
			labelText = i,
			selected = selectedDay ~= i - 1
		})
	end

	self.bindData.dayList:SetSimpleList(#self.dayDataList)
	self.bindData.dayList:SelectItem(selectedDay)
end
