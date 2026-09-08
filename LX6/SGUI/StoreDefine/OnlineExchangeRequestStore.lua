-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineExchangeRequestStore.lua
-- Decompiled from: 01107_OnlineExchangeRequestStore.lua_8657629e5108.luajit

C_OnlineExchangeRequestStore = DefClass("C_OnlineExchangeRequestStore", C_OnlineExchangeRequestStore, C_StoreGroup)
GroupName2Class.OnlineExchangeRequestStore = C_OnlineExchangeRequestStore
local M = C_OnlineExchangeRequestStore

M.ctor = function(self)
	self.currentRequest = {}
end

M.OnAwake = function(self)
	self.bindData.cancelBtn.luaClick = self.CreateActionWithArgs(self, "OnReplyRequest", false)
	self.bindData.confirmBtn.luaClick = self.CreateActionWithArgs(self, "OnReplyRequest", true)
end

M.OnReplyRequest = function(self, isAgree)
	slot2 = gLinkManager

	slot2:AskReplyDutySwap(self.currentRequest.SourcePid, isAgree, function ()
		self:OnExit()
	end)
end

M.OnExit = function(self)
	self.currentRequest = gLinkManager:GetRequestDuty()

	if not self.currentRequest then
		gPanelManager:Close(gPanelId.ONLINE_EXCHANGE_REQUEST)

		return
	end

	self.RefreshPage(self)
end

M.OnShow = function(self, panelId, data)
	self.playOneStore = self.GetStoreByWidget(self, self.bindData.player1Widget)
	self.playTwoStore = self.GetStoreByWidget(self, self.bindData.player2Widget)

	self.OnExit(self)
end

M.OnClose = function(self)
end

M.RefreshPage = function(self)
	self.RefreshStoreByPid(self, self.playOneStore, self.currentRequest.SourcePid, self.currentRequest.SourceDuty)
	self.RefreshStoreByPid(self, self.playTwoStore, self.currentRequest.TargetPid, self.currentRequest.TargetDuty)
end

M.RefreshStoreByPid = function(self, store, pid, dutyId)
	if not store then
		return
	end

	local memeberInfo = gLinkManager:GetRequestMemberInfo(pid, dutyId)

	if not memeberInfo then
		return
	end

	store.userInfo.pid = memeberInfo.pid
	store.indexLabel = memeberInfo.index
	store.color = gLinkManager:GetColorInfo(pid)
	store.resNameLabel = memeberInfo.dutyName
	store.resIconId = memeberInfo.dutyIcon
end

M.OnActiveDeviceChange = function(self, device)
end
