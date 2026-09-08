-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineMainPanelStore.lua
-- Decompiled from: 01126_OnlineMainPanelStore.lua_d3ee63931198.luajit

local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local StaticProps = {}
C_OnlineMainPanelStore = DefClass("C_OnlineMainPanelStore", C_OnlineMainPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.OnlineMainPanelStore = C_OnlineMainPanelStore
local M = C_OnlineMainPanelStore
local ONLINE_STATE = {
	["\\xa1]R"] = 0,
	["T\rS~"] = 1,
	["/\\xb8\\xba\\xa0i"] = 3,
	[")'"] = 2
}

M.ctor = function(self)
	self.mgr = gLinkManager
	self.msgEvents = {
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.OnLinkMemberInfoChange)
	}
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.publicBtn.luaClick = self.CreateAction(self, "OnPublicBtnClick")
	self.bindData.privateBtn.luaClick = self.CreateAction(self, "OnPrivateBtnClick")
	self.bindData.switchBtn.luaClick = self.CreateAction(self, "OnPrivateBtnClick")
	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
	self.bindData.createBtn.luaClick = self.CreateAction(self, "OnPrivateBtnClick")
	self.bindData.privateList.onGetTIndex = self.CreateActionWithArgs(self, self.OnGetTIndex, UX.Game.LinkMode.Private)
	self.bindData.privateList.luaSimpleRenderItem = self.CreateActionWithArgs(self, "OnListRenderItem", UX.Game.LinkMode.Private)
	self.bindData.publicList.onGetTIndex = self.CreateActionWithArgs(self, self.OnGetTIndex, UX.Game.LinkMode.Public)
	self.bindData.publicList.luaSimpleRenderItem = self.CreateActionWithArgs(self, "OnListRenderItem", UX.Game.LinkMode.Public)
	self.linkList = {
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {}
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnShow = function(self, panelId, data)
	self.RefreshPage(self)
end

M.OnClose = function(self)
	self.ClearMessageEvents(self)
end

M.OnDestroy = function(self)
end

M.OnGetTIndex = function(self, linkMode, index)
	return self.linkList[linkMode][index + 1].tIndex
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_MAIN_PANEL)
end

M.OnPublicBtnClick = function(self)
	self.mgr:EnterLink(UX.Game.LinkMode.Public)
	self:OnExitBtnClick()
end

M.OnPrivateBtnClick = function(self)
	self.mgr:EnterLink(UX.Game.LinkMode.Private)
	self:OnExitBtnClick()
end

M.OnBackBtnClick = function(self)
	self.mgr:EnterLink(UX.Game.LinkMode.None)
end

M.OnListRenderItem = function(self, mode, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if store then
		local data = self.linkList[mode][index + 1]

		if data.tIndex ~= 1 then
			store.inviteBtn.luaClick = self.CreateAction(self, "OnInviteBtnClick")

			return
		end

		store.userInfo.luaInfoUpdate = self.CreateActionWithArgs(self, "OnUserInfoUpdate", store)
		store.userInfo.pid = data.playerId
		store.userBtn.luaClick = self.CreateActionWithArgs(self, "OnUserBtnClick", {
			pid = data.playerId,
			isSelf = data.isSelf,
			mode = data.mode
		})
	end
end

M.OnUserInfoUpdate = function(self, store, content, info)
	local timeInfo = info.LastDetachTime ~= 0 and 0 or math.floor((gCS.TimeManager.ServerUnixTime - info.LastDetachTime) / gClientConst.SECONDS_PER_DAY)

	if timeInfo <= 0 then
		store.leaveTimeLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900958).Text, timeInfo)
	else
		store.leaveTimeLabel = LTConfig.TextScriptTextConfig.GetConfig(89900981).Text
	end

	store.stateCtl = self.mgr:GetLinkState(info.OnlineState, info.Pid ~= gPlayerManager.infoLogin.bindData.pid, info.LinkMode, self.mgr.LinkMode)
end

M.OnInviteBtnClick = function(self)
	self.mgr:ShowInvitePanel(self.mgr.LinkMode)
end

M.OnUserBtnClick = function(self, data)
	local pid = data and data.pid
	local isSelf = data and data.isSelf

	if pid ~= 0 then
		return
	end

	local callback = function()
		slot0 = self.mgr

		slot0:ShowLinkPanel(function ()
			self:RefreshPage()
		end)
	end

	if isSelf then
		self.mgr:LeaveLinkRoom(data.mode, callback)
	else
		self.mgr:LinkKickOut(pid, callback)
	end
end

M.ChangeCtlByLinkMode = function(self, mode, ctl, list, label)
	if self.mgr:CheckInOut(mode) then
		self.bindData[ctl] = ONLINE_STATE.OUT
	elseif self.mgr.LinkMode ~= mode then
		self.bindData[ctl] = ONLINE_STATE.IN
	elseif self.mgr:CheckInSwitch(mode) then
		self.bindData[ctl] = ONLINE_STATE.SWITCH
	else
		self.bindData[ctl] = ONLINE_STATE.NONE
	end

	if self.bindData[ctl] == ONLINE_STATE.NONE then
		self.linkList[mode] = self.mgr:GetLinkMemberList(mode)

		self.bindData[list]:SetSimpleList(#self.linkList[mode])

		if self.bindData[ctl] ~= ONLINE_STATE.IN then
			self.bindData[list]:SetNavSelectToTop()
		end
	end
end

M.OnLinkMemberInfoChange = function(self)
	if self.bindData.linkMode ~= UX.Game.LinkMode.None then
		return
	end

	self.RefreshPage(self)
end

M.RefreshPage = function(self)
	self.bindData.linkMode = self.mgr.LinkMode

	self.ChangeCtlByLinkMode(self, UX.Game.LinkMode.Public, "publicCtl", "publicList", "publicLabel")
	self.ChangeCtlByLinkMode(self, UX.Game.LinkMode.Private, "privateCtl", "privateList", "privateLabel")

	if self.bindData.linkMode ~= UX.Game.LinkMode.None then
		return
	end

	self.bindData.memberLabel = gString.Format(TextScriptTextConfig.GetConfig(89900988).Text, self.mgr:GetCurrentLinkPlayerNumber(), self.mgr:GetMaxPlayerNum(self.mgr.LinkMode))
end
