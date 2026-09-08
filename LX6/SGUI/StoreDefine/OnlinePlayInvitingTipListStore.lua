-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePlayInvitingTipListStore.lua
-- Decompiled from: 01118_OnlinePlayInvitingTipListStore.lua_928591012502.luajit

C_OnlinePlayInvitingTipListStore = DefClass("C_OnlinePlayInvitingTipListStore", C_OnlinePlayInvitingTipListStore, C_StoreGroup)
GroupName2Class.OnlinePlayInvitingTipListStore = C_OnlinePlayInvitingTipListStore
local M = C_OnlinePlayInvitingTipListStore

M.ctor = function(self)
	self.tick = 0
	self.callback = nil
	self.mgr = gLinkProgressMgr
	self.mgsEvents = {
		[gEventConstants.LINK_PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshPage)
	}
end

M.OnAwake = function(self)
	self.bindData.friendList.luaSimpleRenderItem = self.CreateAction(self, self.OnFriendRenderItem)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)

	self.RegisterMessageEvents(self, self.mgsEvents)
end

M.OnAcceptBtnClick = function(self, id)
	self.mgr:OnProgressConfirm(self.groupId, id, true)
end

M.OnRejectBtnClick = function(self, id)
	self.mgr:OnProgressCancel(self.groupId, id, true)
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_INVITE_PANEL)
end

M.OnFriendRenderItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local id = self.showList[index + 1]
	local progress = self.mgr.progressInfo[self.groupId][id]
	local data = progress.data
	store.pid = data.pid
	store.titleLabel = data.gameId and gLinkManager:GetPlayModeName(data.gameId) or gLinkProgressMgr:GetProgressTitle(self.groupId)
	store.acceptBtn.luaClick = self:CreateActionWithArgs(self.OnAcceptBtnClick, id)
	store.rejectBtn.luaClick = self:CreateActionWithArgs(self.OnRejectBtnClick, id)

	self.mgr:PlayCountDown(progress, store.countdown, self.groupId, id, false)
end

M.OnShow = function(self, panelId, data)
	self.groupId = data.groupId or 0

	self:RefreshPage()
end

M.RefreshPage = function(self)
	self.showList = {}

	for i, progress in pairs(self.mgr.progressInfo[self.groupId]) do
		if not progress.isFinish then
			table.insert(self.showList, i)
		end
	end

	self.bindData.friendList:SetSimpleList(#self.showList)
end

M.OnClose = function(self)
	self.mgr:RunProgress(self.groupId)
	self:ClearMessageEvents()
end

M.OnActiveDeviceChange = function(self, device)
end
