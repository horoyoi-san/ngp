C_OnlineBeInviteListStore = DefClass("C_OnlineBeInviteListStore", C_OnlineBeInviteListStore, C_StoreGroup)
GroupName2Class.OnlineBeInviteListStore = C_OnlineBeInviteListStore
local M = C_OnlineBeInviteListStore

function M:OnAwake()
	self.bindData.viewBtn.luaClick = self:CreateAction("OnViewBtnClick")
end

function M:OnShow(panelId, data)
	Timer.New(function ()
		self:OnExit()
	end, 30):Start()

	self.bindData.userInfo.pid = data and data.playerId
	self.playerId = data and data.playerId
end

function M:OnClose()
	return
end

function M:OnDestroy()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnGroupEnable()
	return
end

function M:OnExit()
	gPanelManager:Close(gPanelId.S_ONLINE_BE_INVITE_LIST)
end

function M:OnViewBtnClick()
	self:OnExit()
	gPanelManager:CheckShow(gPanelId.S_ONLINE_BE_INVITE_PANEL, {
		playerId = self.playerId
	})
end
