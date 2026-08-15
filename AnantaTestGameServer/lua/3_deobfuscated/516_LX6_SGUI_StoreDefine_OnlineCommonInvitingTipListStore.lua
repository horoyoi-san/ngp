C_OnlineCommonInvitingTipListStore = DefClass("C_OnlineCommonInvitingTipListStore", C_OnlineCommonInvitingTipListStore, C_StoreGroup)
GroupName2Class.OnlineCommonInvitingTipListStore = C_OnlineCommonInvitingTipListStore
local M = C_OnlineCommonInvitingTipListStore

function M:ctor()
	self.tick = 0
	self.callback = nil
end

function M:OnAwake()
	self.bindData.list.luaSimpleRenderItem = self:CreateAction("OnRenderItem")

	function self.bindData.list.onGetTIndex(_)
		return 0
	end

	self.bindData.backBtn.luaClick = self:CreateAction("OnBackBtnClick")
end

function M:OnBackBtnClick()
	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP_LIST)
end

function M:OnRenderItem(btn, index)
	local store = gStoreManager:GetStoreGroup("OnlineCommonInvitingTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local list = gInviteManager:GetAllInviteList()
	local data = list[index + 1]
	store.pid = data.pid
	store.TextType = data.textType

	if data.textType == gInviteManager.TEXT_TYPE.APPLY then
		store.applyGameName = data.text1
	elseif data.textType == gInviteManager.TEXT_TYPE.INVITE then
		store.InviteGameName = data.text1
	elseif data.textType == gInviteManager.TEXT_TYPE.INVITEXXX then
		store.InvitePlayerName = data.text1
		store.InviteXXXPlayerName = data.text2
	end

	store.acceptBtn.luaClick = self:CreateActionWithArgs("OnAcceptBtnClick", data)
	store.rejectBtn.luaClick = self:CreateActionWithArgs("OnRejectBtnClick", data)
	local countdown = data.stayTime - (gLuaDataManager.serverTime - data.timestamp)
	store.timeLabel = gString.Format("(%ds)", countdown)
	store.type = data.type
end

function M:OnAcceptBtnClick(data)
	if not data then
		return
	end

	if data.callback then
		data.callback(true)
	end

	gInviteManager:RemoveInvite(data)
end

function M:OnRejectBtnClick(data)
	if not data then
		return
	end

	if data.callback then
		data.callback(false)
	end

	gInviteManager:RemoveInvite(data)
end

function M:OnShow(panelId, data)
	self.callback = data.callback

	self:RefreshList()
end

function M:RefreshList()
	local inviteList = gInviteManager:GetAllInviteList()

	if inviteList and #inviteList > 0 then
		self.bindData.list:SetSimpleList(#inviteList)
	else
		self:OnBackBtnClick()
	end
end

local TICK_RATE = 10

function M:OnUpdate()
	self.tick = self.tick + 1

	if TICK_RATE <= self.tick then
		self.tick = 0

		self:RefreshList()
	end
end

function M:OnClose()
	if self.callback then
		self.callback()

		self.callback = nil
	end
end
