C_CommonRewardPanelStore = DefClass("C_CommonRewardPanelStore", C_CommonRewardPanelStore, C_StoreGroup)
GroupName2Class.CommonRewardPanelStore = C_CommonRewardPanelStore
local M = C_CommonRewardPanelStore
local delayScrollTime = 0.8

function M:ctor()
	return
end

function M:OnAwake()
	self.callBacks = {}
	self.itemList = {}
	self.bindData.sItemList.luaSimpleRenderItem = self:CreateAction(self.OnCommonItemRender)
	self.bindData.gItemList.luaSimpleRenderItem = self:CreateAction(self.OnCommonItemRender)
	self.bindData.detailBtn.luaClick = self:CreateAction(self.OnDetailBtnClick)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnExit)
end

function M:OnCommonItemRender(btn, index)
	local data = self.itemList[index + 1]

	gCommonItemManager:OnCommonItemRender(btn, index, data)
end

function M:OnShow(panelId, data)
	local param = data.Param
	self.itemList = gCommonItemManager:GetSingleSortedListRenderDataByList(param)
	self.bindData.listNumber = #self.itemList > 7 and 1 or 0
	local currentList = nil

	if self.bindData.listNumber == 1 then
		currentList = self.bindData.gItemList

		self.bindData.gItemList:SetSimpleList(#self.itemList)

		self.initTime = Time.time
		self.needScroll = true

		self.bindData.gItemList:GoToIndex(0, true)
	else
		currentList = self.bindData.sItemList

		self.bindData.sItemList:SetSimpleList(#self.itemList)
	end

	currentList:SetNavSelectToTop()
end

function M:OnUpdate()
	if self.bindData.listNumber == 1 and self.needScroll and delayScrollTime <= Time.time - self.initTime then
		self.needScroll = false

		self.bindData.gItemList:GoToIndex(#self.itemList - 1, false)
	end
end

function M:OnClose()
	gPopupPauseManager:ResumePopup(gPopupPauseManager.PAUSE_REASON.COMMON_REWARD_OPEN)
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_COMMON_REWARD_WINDOW)
end

function M:OnDetailBtnClick()
	if self.bindData.listNumber == 1 then
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.overNavigationArea
	else
		SGUI.UNavigationMgr.Inst.CurrentActiveArea = self.bindData.lessNavigationArea
	end
end
