local TextScriptTextConfig = LTConfig.TextScriptTextConfig
local StaticProps = {}
C_OnlineMainPanelStore = DefClass("C_OnlineMainPanelStore", C_OnlineMainPanelStore, C_StoreGroup, StaticProps)
GroupName2Class.OnlineMainPanelStore = C_OnlineMainPanelStore
local M = C_OnlineMainPanelStore
local ONLINE_STATE = {
	OUT = 0,
	NONE = 1,
	SWITCH = 3,
	IN = 2
}

function M:ctor()
	self.mgr = gLinkManager
	self.msgEvents = {
		[gEventConstants.LINK_MEMBER_CHANGE] = self:CreateAction(self.OnLinkMemberInfoChange)
	}
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.publicBtn.luaClick = self:CreateAction("OnPublicBtnClick")
	self.bindData.privateBtn.luaClick = self:CreateAction("OnPrivateBtnClick")
	self.bindData.switchBtn.luaClick = self:CreateAction("OnPrivateBtnClick")
	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.createBtn.luaClick = self:CreateAction("OnPrivateBtnClick")
	self.bindData.privateList.onGetTIndex = self:CreateActionWithArgs(self.OnGetTIndex, UX.Game.LinkMode.Private)
	self.bindData.privateList.luaSimpleRenderItem = self:CreateActionWithArgs("OnListRenderItem", UX.Game.LinkMode.Private)
	self.bindData.publicList.onGetTIndex = self:CreateActionWithArgs(self.OnGetTIndex, UX.Game.LinkMode.Public)
	self.bindData.publicList.luaSimpleRenderItem = self:CreateActionWithArgs("OnListRenderItem", UX.Game.LinkMode.Public)
	self.linkList = {
		[UX.Game.LinkMode.Public] = {},
		[UX.Game.LinkMode.Private] = {}
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnShow(panelId, data)
	self:RefreshPage()
end

function M:OnClose()
	self:ClearMessageEvents()
end

function M:OnDestroy()
	return
end

function M:OnGetTIndex(linkMode, index)
	return self.linkList[linkMode][index + 1].tIndex
end

function M:OnExitBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_MAIN_PANEL)
end

function M:OnPublicBtnClick()
	self.mgr:EnterLink(UX.Game.LinkMode.Public)
	self:OnExitBtnClick()
end

function M:OnPrivateBtnClick()
	self.mgr:EnterLink(UX.Game.LinkMode.Private)
	self:OnExitBtnClick()
end

function M:OnBackBtnClick()
	self.mgr:EnterLink(UX.Game.LinkMode.None)
end

function M:OnListRenderItem(mode, btn, index)
	local store = self:GetStoreByWidget(btn)

	if store then
		local data = self.linkList[mode][index + 1]

		if data.tIndex == 1 then
			store.inviteBtn.luaClick = self:CreateAction("OnInviteBtnClick")

			return
		end

		store.userInfo.luaInfoUpdate = self:CreateActionWithArgs("OnUserInfoUpdate", store)
		store.userInfo.pid = data.playerId
		store.userBtn.luaClick = self:CreateActionWithArgs("OnUserBtnClick", {
			pid = data.playerId,
			isSelf = data.isSelf,
			mode = data.mode
		})
	end
end

function M:OnUserInfoUpdate(store, content, info)
	local timeInfo = info.LastDetachTime == 0 and 0 or math.floor((gCS.TimeManager.ServerUnixTime - info.LastDetachTime) / gClientConst.SECONDS_PER_DAY)

	if timeInfo > 0 then
		store.leaveTimeLabel = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900958).Text, timeInfo)
	else
		store.leaveTimeLabel = LTConfig.TextScriptTextConfig.GetConfig(89900981).Text
	end

	store.stateCtl = self.mgr:GetLinkState(info.OnlineState, info.Pid == gPlayerManager.infoLogin.bindData.pid, info.LinkMode, self.mgr.LinkMode)
end

function M:OnInviteBtnClick()
	self.mgr:ShowInvitePanel(self.mgr.LinkMode)
end

function M:OnUserBtnClick(data)
	local pid = data and data.pid
	local isSelf = data and data.isSelf

	if pid == 0 then
		return
	end

	local function callback()
		self.mgr:ShowLinkPanel(function ()
			self:RefreshPage()
		end)
	end

	if isSelf then
		self.mgr:LeaveLinkRoom(data.mode, callback)
	else
		self.mgr:LinkKickOut(pid, callback)
	end
end

function M:ChangeCtlByLinkMode(mode, ctl, list, label)
	if self.mgr:CheckInOut(mode) then
		self.bindData[ctl] = ONLINE_STATE.OUT
	elseif self.mgr.LinkMode == mode then
		self.bindData[ctl] = ONLINE_STATE.IN
	elseif self.mgr:CheckInSwitch(mode) then
		self.bindData[ctl] = ONLINE_STATE.SWITCH
	else
		self.bindData[ctl] = ONLINE_STATE.NONE
	end

	if self.bindData[ctl] ~= ONLINE_STATE.NONE then
		self.linkList[mode] = self.mgr:GetLinkMemberList(mode)

		self.bindData[list]:SetSimpleList(#self.linkList[mode])

		if self.bindData[ctl] == ONLINE_STATE.IN then
			self.bindData[list]:SetNavSelectToTop()
		end
	end
end

function M:OnLinkMemberInfoChange()
	if self.bindData.linkMode == UX.Game.LinkMode.None then
		return
	end

	self:RefreshPage()
end

function M:RefreshPage()
	self.bindData.linkMode = self.mgr.LinkMode

	self:ChangeCtlByLinkMode(UX.Game.LinkMode.Public, "publicCtl", "publicList", "publicLabel")
	self:ChangeCtlByLinkMode(UX.Game.LinkMode.Private, "privateCtl", "privateList", "privateLabel")

	if self.bindData.linkMode == UX.Game.LinkMode.None then
		return
	end

	self.bindData.memberLabel = gString.Format(TextScriptTextConfig.GetConfig(89900988).Text, self.mgr:GetCurrentLinkPlayerNumber(), self.mgr:GetMaxPlayerNum(self.mgr.LinkMode))
end
