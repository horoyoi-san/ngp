C_OnlineBeInvitePanelStore = DefClass("C_OnlineBeInvitePanelStore", C_OnlineBeInvitePanelStore, C_StoreGroup)
GroupName2Class.OnlineBeInvitePanelStore = C_OnlineBeInvitePanelStore
local M = C_OnlineBeInvitePanelStore

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExit")
	self.bindData.friendList.luaSimpleRenderItem = self:CreateAction(self.OnRenderFriendItem)
	self.inviteList = {}
end

function M:OnShow(panelId, data)
	self.focusPlayerId = data and data.playerId

	self:RefreshPage()
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_ONLINE_BE_INVITE_PANEL)
end

function M:OnRenderFriendItem(btn, index)
	local data = self.inviteList[index + 1]
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	store.userInfo.pid = data.playerId
	store.rejectBtn.luaClick = self:CreateActionWithArgs("OnRejectBtnClick", data.playerId)
	store.acceptBtn.luaClick = self:CreateActionWithArgs("OnAcceptBtnClick", data.playerId)
end

function M:OnRejectBtnClick(playerId)
	gLinkManager:LinkReplyInvite(playerId, false, self:CreateAction("RefreshPage"))
end

function M:OnAcceptBtnClick(playerId)
	gLinkManager:LinkReplyInvite(playerId, true, self:CreateAction("RefreshPage"))
end

function M:RefreshPage()
	self.inviteList = gLinkManager:GetInviteList()

	self.bindData.friendList:SetSimpleList(#self.inviteList)
end
