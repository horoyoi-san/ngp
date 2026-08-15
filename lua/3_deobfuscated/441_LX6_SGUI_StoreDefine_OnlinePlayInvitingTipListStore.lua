C_OnlinePlayInvitingTipListStore = DefClass("C_OnlinePlayInvitingTipListStore", C_OnlinePlayInvitingTipListStore, C_StoreGroup)
GroupName2Class.OnlinePlayInvitingTipListStore = C_OnlinePlayInvitingTipListStore
local M = C_OnlinePlayInvitingTipListStore

function M:ctor()
	self.tick = 0
	self.callback = nil
	self.mgr = gLinkProgressMgr
	self.mgsEvents = {
		[gEventConstants.LINK_PROGRESS_STATE_CHANGE] = self:CreateAction(self.RefreshPage)
	}
end

function M:OnAwake()
	self.bindData.friendList.luaSimpleRenderItem = self:CreateAction(self.OnFriendRenderItem)
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)

	self:RegisterMessageEvents(self.mgsEvents)
end

function M:OnAcceptBtnClick(id)
	self.mgr:OnProgressConfirm(self.groupId, id, true)
end

function M:OnRejectBtnClick(id)
	self.mgr:OnProgressCancel(self.groupId, id, true)
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_INVITE_PANEL)
end

function M:OnFriendRenderItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = self.showList[index + 1]
	local progress = self.mgr.progressInfo[self.groupId][id]
	local data = progress.data
	store.pid = data.pid
	store.titleLabel = gLinkManager:GetPlayModeName(data.gameId)
	store.acceptBtn.luaClick = self:CreateActionWithArgs(self.OnAcceptBtnClick, id)
	store.rejectBtn.luaClick = self:CreateActionWithArgs(self.OnRejectBtnClick, id)

	self.mgr:PlayCountDown(progress, store.countdown, self.groupId, id, false)
end

function M:OnShow(panelId, data)
	self.groupId = data.groupId or 0

	self:RefreshPage()
end

function M:RefreshPage()
	self.showList = {}

	for i, progress in pairs(self.mgr.progressInfo[self.groupId]) do
		if not progress.isFinish then
			table.insert(self.showList, i)
		end
	end

	self.bindData.friendList:SetSimpleList(#self.showList)
end

function M:OnClose()
	self.mgr:RunProgress(self.groupId)
	self:ClearMessageEvents()
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
