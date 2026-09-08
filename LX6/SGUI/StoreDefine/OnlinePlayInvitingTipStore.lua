-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePlayInvitingTipStore.lua
-- Decompiled from: 01117_OnlinePlayInvitingTipStore.lua_3f38f7653cc5.luajit

local RedDotMgr = SGUI.RedDotMgr
local LinkProgressConfig = LTConfig.LinkProgressConfig
C_OnlinePlayInvitingTipStore = DefClass("C_OnlinePlayInvitingTipStore", C_OnlinePlayInvitingTipStore, C_StoreGroup)
GroupName2Class.OnlinePlayInvitingTipStore = C_OnlinePlayInvitingTipStore
local M = C_OnlinePlayInvitingTipStore

M.ctor = function(self)
	self.timer = 0
	self.currentTime = 0
	self.currentRoomId = 0
	self.mgr = gLinkProgressMgr
	self.mgsEvents = {
		[gEventConstants.LINK_PROGRESS_STATE_CHANGE] = self.CreateAction(self, self.RefreshShowTip)
	}
end

M.OnAwake = function(self)
	self.bindData.backGround.luaClick = self:CreateAction("OnBackGroundClick")
	self.bindData.confirmBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", true)
	self.bindData.rejectBtn.luaClick = self:CreateActionWithArgs("OnReplayInvite", false)
	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot - self.mgr.redDotAction or nil

	self:RegisterMessageEvents(self.mgsEvents)
end

M.OnBackGroundClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_ROOM_INVITE_MESG)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_INVITE_PANEL, {
		groupId = self.groupId
	})
end

M.OnReplayInvite = function(self, agree)
	if agree then
		self.mgr:OnProgressConfirm(self.groupId, 1, true)
	else
		self.mgr:OnProgressCancel(self.groupId, 1, true)
	end
end

M.OnShow = function(self, panelId, data)
	self.groupId = data.groupId or 0
	self.cfg = LinkProgressConfig.GetConfig(self.groupId)

	if self.cfg and not string.is_null_or_empty(self.cfg.TitleLabel) then
		self.bindData.titleLabel = self.cfg.TitleLabel
	end

	self.mgr:OnRenderProgress(self.groupId, self, self.bindData.countdown)
	self:RefreshShowTip()
end

M.RefreshShowTip = function(self)
	local count = #(self.mgr.progressInfo[self.groupId] or {})
	self.bindData.showTip = count <= 1 and 1 or 0
	self.bindData.addNumLabel = "+" .. count - 1
end

M.OnClose = function(self)
	self.bindData.countdown:Stop()

	RedDotMgr.onRenderRedDot = RedDotMgr.onRenderRedDot and RedDotMgr.onRenderRedDot - self.mgr.redDotAction or nil

	self.mgr:ChangeProgressState(self.groupId, false)
	self:ClearMessageEvents()
end
