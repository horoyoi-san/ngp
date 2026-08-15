C_OnlinePlayerDetailsStore = DefClass("C_OnlinePlayerDetailsStore", C_OnlinePlayerDetailsStore, C_StoreGroup)
GroupName2Class.OnlinePlayerDetailsStore = C_OnlinePlayerDetailsStore
local M = C_OnlinePlayerDetailsStore

function M:ctor()
	self.callback = nil
end

function M:OnAwake()
	self.bindData.closeBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.detailBtn.luaClick = self:CreateAction("OnDetailBtnClick")
	self.bindData.removeBtn.luaClick = self:CreateAction("OnRemoveBtnClick")
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_PLAYER_DETAILS_PANEL)
end

function M:OnRemoveBtnClick()
	gLinkManager:AskKickFriendFromRoom(self.targetPid)
	self:OnBackBtnClick()
end

function M:OnDetailBtnClick()
	return
end

function M:OnShow(panelId, data)
	self.targetPid = data.pid
	self.bindData.removeBtn.interactable = gLinkManager:CheckIsRoomLeader() and data.pid ~= gPlayerManager.infoLogin.bindData.pid
end

function M:OnClose()
	gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end
