-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlinePlayerDetailsStore.lua
-- Decompiled from: 01119_OnlinePlayerDetailsStore.lua_7d36c2242a6c.luajit

C_OnlinePlayerDetailsStore = DefClass("C_OnlinePlayerDetailsStore", C_OnlinePlayerDetailsStore, C_StoreGroup)
GroupName2Class.OnlinePlayerDetailsStore = C_OnlinePlayerDetailsStore
local M = C_OnlinePlayerDetailsStore

M.ctor = function(self)
	self.callback = nil
end

M.OnAwake = function(self)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.detailBtn.luaClick = self.CreateAction(self, "OnDetailBtnClick")
	self.bindData.removeBtn.luaClick = self.CreateAction(self, "OnRemoveBtnClick")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_PLAYER_DETAILS_PANEL)
end

M.OnRemoveBtnClick = function(self)
	gLinkManager:AskKickFriendFromRoom(self.targetPid)
	self:OnBackBtnClick()
end

M.OnDetailBtnClick = function(self)
end

M.OnShow = function(self, panelId, data)
	self.targetPid = data.pid
	self.bindData.removeBtn.interactable = gLinkManager:CheckIsRoomLeader() and data.pid == gPlayerManager.infoLogin.bindData.pid
end

M.OnClose = function(self)
	gPanelManager:CheckShow(gPanelId.S_ONLINE_ROOM_PANEL)
end

M.OnActiveDeviceChange = function(self, device)
end
