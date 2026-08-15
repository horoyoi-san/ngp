local StaticProps = {
	DISPLAY_TYPE = {
		NAME = 2,
		BIRTHDAY = 1,
		SIGN = 0
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

function M:OnAwake()
	self.nowMonthDay = 0
	self.nowMonth = 0
	self.selectDay = 0
	self.dayDataList = {}
	self.bindData.monthList.luaRenderItem = self:CreateAction("OnDateListRenderItem")
	self.bindData.monthList.luaSelectedChanged = self:CreateAction("OnDateListSelectedChanged")
	self.bindData.dayList.luaRenderItem = self:CreateAction("OnDateListRenderItem")
	self.bindData.dayList.luaSelectedChanged = self:CreateAction("OnDayListSelectedChanged")
	self.bindData.confirmBtn.luaClick = self:CreateAction("OnConfirmBtnClick")
	self.bindData.cancelBtn.luaClick = self:CreateAction("OnCloseBtnClick")
	self.bindData.closeBtn.luaClick = self:CreateAction("OnCloseBtnClick")
end

function M:OnDestroy()
	return
end

function M:OnStart()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.confirmBtn.interactable = true

	self:RefreshMonthList()

	local selectedDay = math.max(gHunLunManager.birthdayCode % 100, 1)
	self.selectDay = selectedDay - 1

	self:RefreshDayList(true)

	if gHunLunManager.birthdayCode > 0 then
		self.bindData.confirmBtn.interactable = false
	end
end

function M:OnClose()
	return
end

function M:OnDateListRenderItem(btn, index, data)
	local id = btn.gameObject:GetInstanceID()
	local store = self:GetStoreById(id)

	if not store then
		return
	end

	store.label = data.labelText
end

function M:OnDateListSelectedChanged(list)
	self:RefreshDayList()

	self.nowMonth = list.selectedItem.labelText
end

function M:OnDayListSelectedChanged(list)
	self.selectDay = list.selectedItem.labelText
end

function M:OnConfirmBtnClick()
	local month = self.bindData.monthList.selectedItem.labelText
	local day = self.bindData.dayList.selectedItem.labelText

	gHunLunManager:ChangeBirth(month, day, self:CreateAction("OnCloseBtnClick"))
end

function M:OnCloseBtnClick()
	gPanelManager:Close(gPanelId.S_BUBBLE_TIPS_EDIT_PANEL)
end

function M:RefreshMonthList()
	local list = {}
	local selectedMonth = math.max(1, math.floor(gHunLunManager.birthdayCode / 100))
	self.nowMonth = selectedMonth - 1

	for i = 1, 12 do
		table.insert(list, {
			labelText = i,
			selected = selectedMonth == i
		})
	end

	self.bindData.monthList:SetList(list)
end

function M:RefreshDayList(isFirst)
	local month = self.bindData.monthList.selectedItem.labelText

	if month == self.nowMonth and isFirst ~= true then
		return
	end

	local month = month
	local selectedDay = math.min(self.selectDay, MonthLength[month] - 1)

	if isFirst == true then
		for i = 1, MonthLength[month] do
			table.insert(self.dayDataList, {
				labelText = i,
				selected = selectedDay == i - 1
			})
		end

		self.bindData.dayList:SetList(self.dayDataList)
	end

	if self.nowMonthDay < MonthLength[month] then
		for i = self.nowMonthDay + 1, MonthLength[month] do
			local element = {
				labelText = i
			}

			table.insert(self.dayDataList, element)
			self.bindData.dayList:AddData(element)
		end
	elseif MonthLength[month] < self.nowMonthDay then
		self.dayDataList = {}

		for i = 1, MonthLength[month] do
			table.insert(self.dayDataList, {
				labelText = i,
				selected = selectedDay == i - 1
			})
		end

		self.bindData.dayList:SetList(self.dayDataList)
	end

	self.bindData.dayList:RefreshList()
	self.bindData.dayList:GoToIndex(self.bindData.dayList.selectedIndex, true)

	self.nowMonthDay = MonthLength[month]
end
