-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ActivitySignInPanelStore.lua
-- Decompiled from: 01594_ActivitySignInPanelStore.lua_9730aae53e38.luajit

local AwardActivityConfig = LTConfig.AwardActivityConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_ActivitySignInPanelStore = DefClass("C_ActivitySignInPanelStore", C_ActivitySignInPanelStore, C_StoreGroup)
GroupName2Class.ActivitySignInPanelStore = C_ActivitySignInPanelStore
local M = C_ActivitySignInPanelStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
local ITEM_TEMPLATE_TINDEX = {
	["k\\xa1\\xa1\\xba\\xa5"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}

M.ctor = function(self)
	self.mgr = gAwardActivityManager
end

M.OnAwake = function(self)
	self.activityId = 0
	self.cfg = nil
	self.activityInfo = nil
	self.itemList = {}
	self.refreshNav = false
	self.currentSelectItem = nil
	self.mgr = gAwardActivityManager
	self.bindData.infoList.onGetTIndex = self.CreateAction(self, self.OnGetItemTIndex)
	self.bindData.infoList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItemList)
	self.bindData.infoList.luaSimpleClick = self.CreateAction(self, self.OnClickItemList)
	self.bindData.countDown.luaOnMatchedIndexChanged = self.CreateAction(self, self.RefreshFocusDayAndNavigation)
	self.bindData.countDown.luaFinished = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self.CreateAction(self, self.RefreshPage)
	}
	self.backToBaseCb = self.CreateAction(self, self.BackToBase)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnClickItemList = function(self, btn, index)
	local info = self.itemList[index + 1]

	if not info then
		return
	end

	if info.state ~= self.mgr.AWARD_STATE.UNRECEIVED then
		self.mgr:AskTakeReward(self.activityId, index + 1)
	else
		self.bindData.day = index
	end
end

M.OnGetItemTIndex = function(self, index)
	local info = self.itemList[index + 1]

	return info and info.isFocus and ITEM_TEMPLATE_TINDEX.Focus or ITEM_TEMPLATE_TINDEX.Normal
end

M.OnRenderItemList = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local info = self.itemList[index + 1] or {}
	store.dayText = index + 1
	store.stateCtrl = info.state
	local items = gCommonItemManager:GetItemSortedListByDropList({
		{
			["N\\xa1\\xb7\\xa1\\xa2"] = 1,
			dropId = info.dropId
		}
	}, true)

	if not table.isNilOrEmpty(items) then
		local count = items[1].Count

		for i = 2, #items do
			count = math.min(count, items[i].Count)
		end

		local showData = gCommonItemManager:GetItemRenderData({
			itemId = info.itemId,
			itemNum = count,
			IsOwned = info.state ~= self.mgr.AWARD_STATE.RECEIVED
		})

		gCommonItemManager:OnCommonItemRender(store.item, 0, showData)

		if self.bindData.day ~= index and self.refreshNav then
			self.refreshNav = false

			btn.Navigate(btn, btn)
		end
	end
end

M.OnBackBtnClick = function(self)
	if self.parent then
		self.parent:OnBackBtnClick()
	end
end

M.BackToBase = function(self)
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
end

M.OnShow = function(self, panelId, activityId)
	self.m_Id = panelId
	self.activityId = activityId
	self.cfg = AwardActivityConfig.GetConfig(activityId)

	self.RefreshPage(self)
	self.RefreshFocusDayAndNavigation(self)
end

M.RefreshPage = function(self)
	if not self.cfg then
		return
	end

	local isPermanent = self.mgr:CheckIsPermanentActivity(self.activityId)
	local duration = self.mgr:GetActivityEndDuration(self.activityId)

	if not isPermanent and duration < 0 and self.m_Id then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.countdownCtrl = BOOL2CTL[isPermanent]

	if not isPermanent then
		self.bindData.countDown:Play(duration)
	end

	self.bindData.titleLabel = self.cfg.Title
	self.bindData.descLabel = self.cfg.Desc
	self.bindData.bgImageId = self.cfg.BgImage
	self.itemList = self.mgr:GetAwaradList(self.activityId)

	if table.isNilOrEmpty(self.itemList) then
		return
	end

	self.bindData.infoList:SetSimpleList(#self.itemList)
end

M.OnClose = function(self)
end

M.RefreshFocusDayAndNavigation = function(self)
	if table.isNilOrEmpty(self.itemList) then
		return
	end

	local focusDay = self.mgr:GetSignInFocusDay(self.activityId)
	local focusIndex = focusDay - 1
	self.bindData.day = focusIndex

	self.bindData.infoList:GoToIndex(focusIndex, true)

	self.refreshNav = true
end
