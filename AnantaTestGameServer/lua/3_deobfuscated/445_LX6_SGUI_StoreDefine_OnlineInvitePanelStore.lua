C_OnlineInvitePanelStore = DefClass("C_OnlineInvitePanelStore", C_OnlineInvitePanelStore, C_StoreGroup, StaticProps)
GroupName2Class.OnlineInvitePanelStore = C_OnlineInvitePanelStore
local M = C_OnlineInvitePanelStore

function M:ctor()
	self.msgEvents = {
		[gEventConstants.LINK_MEMBER_CHANGE] = self:CreateAction(self.RefreshPage)
	}
end

function M:OnAwake()
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.searchBtn.luaClick = self:CreateAction(self.OnSearchBtnClick)
	self.bindData.searchList.luaSimpleRenderItem = self:CreateAction(self.OnRenderFriendItem)
	self.bindData.inputBtn.luaClick = self:CreateAction(self.OnSwitchInputState)
	self.bindData.searchInput.onActivateAction = self:CreateAction(self.OnInputActivate)
	self.bindData.searchInput.onDeActivateAction = self:CreateAction(self.OnInputDeactivate)
	self.friendList = {}
	self.searchList = {}
	self.inputActive = false
end

function M:OnShow(panelId, data)
	self.mode = data.mode
	self.filter = nil

	self:RefreshPage()
end

function M:OnClose()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupEnable()
	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnGroupDisable()
	self:ClearMessageEvents()
end

function M:OnSwitchInputState()
	if self.inputActive then
		self.inputActive = false

		self.bindData.searchInput:DeactivateInputField()
	else
		self.bindData.searchInput:ActivateInputField()
	end
end

function M:OnInputActivate()
	self.inputActive = true
end

function M:OnInputDeactivate()
	self.inputActive = false
end

function M:OnExitBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_INVITE_PANEL)
end

function M:OnSearchBtnClick()
	if self.filter == self.bindData.searchInput.text then
		return
	end

	self.filter = self.bindData.searchInput.text

	self:RefreshListByFilter()
end

function M:OnRenderFriendItem(btn, index)
	local store = self:GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.searchList[index + 1]
	store.userInfo.pid = data.Pid

	if data.OnlineState == UX.Game.PlayerState.Offline then
		store.stateCtl = 2
	else
		store.stateCtl = gLinkManager:GetPlayerInLink(data.Pid, self.mode) and 1 or 0
	end

	store.inviteBtn.luaClick = self:CreateActionWithArgs(self.OnInviteBtnClick, data.Pid)
end

function M:OnInviteBtnClick(pid)
	gLinkManager:InviteFriendToLink(pid, self.mode)
end

function M:RefreshPage()
	gLinkManager:GetFriendLinkInfo(function (data)
		self.friendList = data

		self:RefreshListByFilter()
	end)
end

function M:RefreshListByFilter()
	if not self.STATE_EnableOnce then
		return
	end

	local data = self.friendList
	local filter = self.filter
	local list = {}

	for _, v in ipairs(data) do
		if filter and not string.find(v.Name, filter) then
			-- Nothing
		elseif v.OnlineState == UX.Game.PlayerState.Online then
			if v.LinkMode ~= self.mode then
				local ele = {
					Pid = v.Pid,
					Name = v.Name,
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
