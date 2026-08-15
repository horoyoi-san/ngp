local RedDotMgr = SGUI.RedDotMgr
C_OnlinePlayInvitingTipStore = DefClass("C_OnlinePlayInvitingTipStore", C_OnlinePlayInvitingTipStore, C_StoreGroup)
GroupName2Class.OnlinePlayInvitingTipStore = C_OnlinePlayInvitingTipStore
local M = C_OnlinePlayInvitingTipStore

function M:ctor()
	self.timer = 0
	self.currentTime = 0
	self.currentRoomId = 0
	self.mgr = gLinkProgressMgr
end

function M:OnAwake()
	self.bindData.backGround.luaClick = self:CreateAction("OnBackGroundClick")
	self.bindData.confirmBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", true)
	self.bindData.rejectBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", false)
	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot - self.mgr.redDotAction or nil
end

function M:OnBackGroundClick()
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_INVITE_MESG)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_INVITE_PANEL, {
		groupId = self.groupId
	})
end

function M:OnReplayInvite(agree)
	if agree then
		self.mgr:OnProgressConfirm(self.groupId, 1, true)
	else
		self.mgr:OnProgressCancel(self.groupId, 1, true)
	end
end

function M:OnShow(panelId, data)
	self.groupId = data.groupId or 0

	self.mgr:OnRenderProgress(self.groupId, self, self.bindData.countdown)
end

function M:OnClose()
	self.bindData.countdown:Stop()

	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot - self.mgr.redDotAction or nil

	self.mgr:ChangeProgressState(self.groupId, false)
end
