-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineInvitePanelStore.lua
-- Decompiled from: 01127_OnlineInvitePanelStore.lua_1bf545af9967.luajit

C_OnlineInvitePanelStore = DefClass("C_OnlineInvitePanelStore", C_OnlineInvitePanelStore, C_StoreGroup, StaticProps)
GroupName2Class.OnlineInvitePanelStore = C_OnlineInvitePanelStore
local M = C_OnlineInvitePanelStore

M.ctor = function(self)
	self.msgEvents = {
		[gEventConstants.LINK_MEMBER_CHANGE] = self.CreateAction(self, self.RefreshPage)
	}
end

M.OnAwake = function(self)
	self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	self.bindData.searchBtn.luaClick = self.CreateAction(self, self.OnSearchBtnClick)
	self.bindData.searchList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderFriendItem)
	self.bindData.inputBtn.luaClick = self.CreateAction(self, self.OnSwitchInputState)
	self.bindData.searchInput.onActivateAction = self.CreateAction(self, self.OnInputActivate)
	self.bindData.searchInput.onDeActivateAction = self.CreateAction(self, self.OnInputDeactivate)
	self.friendList = {}
	self.searchList = {}
	self.inputActive = false
end

M.OnShow = function(self, panelId, data)
	self.mode = data.mode
	self.filter = nil

	self.RefreshPage(self)
end

M.OnClose = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnSwitchInputState = function(self)
	if self.inputActive then
		self.inputActive = false

		self.bindData.searchInput:DeactivateInputField()
	else
		self.bindData.searchInput:ActivateInputField()
	end
end

M.OnInputActivate = function(self)
	self.inputActive = true
end

M.OnInputDeactivate = function(self)
	self.inputActive = false
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_INVITE_PANEL)
end

M.OnSearchBtnClick = function(self)
	if self.filter ~= self.bindData.searchInput.text then
		return
	end

	self.filter = self.bindData.searchInput.text

	self.RefreshListByFilter(self)
end

M.OnRenderFriendItem = function(self, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not store then
		return
	end

	local data = self.searchList[index + 1]
	store.userInfo.pid = data.Pid

	if data.OnlineState ~= UX.Game.PlayerState.Offline then
		store.stateCtl = 2
	else
		store.stateCtl = gLinkManager:GetPlayerInLink(data.Pid, self.mode) and 1 or 0
	end

	store.inviteBtn.luaClick = self.CreateActionWithArgs(self, self.OnInviteBtnClick, data.Pid)
end

M.OnInviteBtnClick = function(self, pid)
	gLinkManager:InviteFriendToLink(pid, self.mode)
end

M.RefreshPage = function(self)
	slot1 = gLinkManager

	slot1:GetFriendLinkInfo(function (data)
		self.friendList = data

		self:RefreshListByFilter()
	end)
end

M.RefreshListByFilter = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	local data = self.friendList
	local filter = self.filter
	local list = {}

	for _, v in ipairs(data) do
		if filter and not string.find(v.Name, filter) then
			-- Nothing
		elseif v.OnlineState ~= UX.Game.PlayerState.Online then
			if v.LinkMode == UX.Game.LinkMode.Private then
				local ele = {
					Pid = v.Pid,
					Name = gSocialFriendManager:GetPlayerDisplayName(v.Pid, v.Name),
					LinkMode = v.LinkMode,
					OnlineState = v.OnlineState
				}

				table.insert(list, ele)
			end
		end
	end

	self.searchList = list

	self.bindData.searchList:SetSimpleList(#self.searchList)
end
