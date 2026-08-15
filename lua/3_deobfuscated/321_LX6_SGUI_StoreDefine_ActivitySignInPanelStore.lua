local AwardActivityConfig = LTConfig.AwardActivityConfig
local UNavigationMgr = SGUI.UNavigationMgr
C_ActivitySignInPanelStore = DefClass("C_ActivitySignInPanelStore", C_ActivitySignInPanelStore, C_StoreGroup)
GroupName2Class.ActivitySignInPanelStore = C_ActivitySignInPanelStore
local M = C_ActivitySignInPanelStore

function M:ctor()
	self.mgr = gAwardActivityManager
end

function M:OnAwake()
	self.activityId = 0
	self.cfg = nil
	self.activityInfo = nil
	self.itemList = {}
	self.refreshNav = false
	self.mgr = gAwardActivityManager
	self.bindData.infoList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItemList)
	self.bindData.infoList.luaSimpleClick = self:CreateAction(self.OnClickItemList)
	self.bindData.countDown.luaOnMatchedIndexChanged = self:CreateAction(self.OnChangeDuration)
	self.msgEvents = {
		[gEventConstants.ON_ACTIVITY_STATE_CHANGE] = self:CreateAction(self.RefreshPage)
	}
	self.backToBaseCb = self:CreateAction(self.BackToBase)
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnClickItemList(btn, index)
	local info = self.itemList[index + 1]

	if not info then
		return
	end

	if info.state == self.mgr.AWARD_STATE.UNRECEIVED then
		self.mgr:AskTakeReward(self.activityId, index + 1)
	else
		self.bindData.day = index
	end
end

function M:OnRenderItemList(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local info = self.itemList[index + 1] or {}
	store.day = index
	store.state = info.state
	local items = gCommonItemManager:GetItemSortedListByDropList({
		{
			count = 1,
			dropId = info.dropId
		}
	}, true)

	if not table.isNilOrEmpty(items) then
		local showData = gCommonItemManager:GetItemRenderData({
			itemId = info.itemId,
			itemNum = items[1].Count,
			IsOwned = info.state == self.mgr.AWARD_STATE.RECEIVED
		})

		gCommonItemManager:OnCommonItemRender(store.item, _, showData)

		function store.item.luaClick()
			self:OnClickItemList(btn, index)
		end

		if self.bindData.day == index and self.refreshNav then
			self.refreshNav = false

			btn:Navigate(btn)
		end

		store.vBackBtn.luaClick = self.backToBaseCb
	end
end

function M:BackToBase()
	UNavigationMgr.Inst.CurrentActiveArea = self.bindData.baseNavigationArea
end

function M:OnShow(panelId, activityId)
	self.activityId = activityId
	self.cfg = AwardActivityConfig.GetConfig(activityId)

	self:RefreshPage()
	self:OnChangeDuration()
end

function M:RefreshPage()
	local duration = self.mgr:GetActivityEndDuration(self.activityId)

	if not self.cfg or duration < 0 then
		gPanelManager:Close(self.m_Id)

		return
	end

	self.bindData.titleLabel = self.cfg.Title
	self.bindData.descLabel = self.cfg.Desc

	self.bindData.countDown:Play(duration)

	self.itemList = self.mgr:GetAwaradList(self.activityId)

	if table.isNilOrEmpty(self.itemList) then
		return
	end

	self.bindData.infoList:SetSimpleList(#self.itemList)
end

function M:OnClose()
	return
end

function M:OnChangeDuration()
	if table.isNilOrEmpty(self.itemList) then
		return
	end

	local dayIndex = self.mgr:GetFinalSignIn(self.activityId) - 1
	self.bindData.day = dayIndex
	self.refreshNav = true
end
