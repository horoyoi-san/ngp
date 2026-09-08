-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OnlineCommonInvitingTipListStore.lua
-- Decompiled from: 01101_OnlineCommonInvitingTipListStore.lua_2cd6af8a0250.luajit

C_OnlineCommonInvitingTipListStore = DefClass("C_OnlineCommonInvitingTipListStore", C_OnlineCommonInvitingTipListStore, C_StoreGroup)
GroupName2Class.OnlineCommonInvitingTipListStore = C_OnlineCommonInvitingTipListStore
local M = C_OnlineCommonInvitingTipListStore
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}

M.ctor = function(self)
	self.callback = nil
	self.showList = {}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.bindData.list.onGetTIndex = function(_)
		return 0
	end

	self.bindData.backBtn.luaClick = self.CreateAction(self, "OnBackBtnClick")
end

M.OnBackBtnClick = function(self)
	gPanelManager:Close(gPanelId.S_ONLINE_COMMON_INVITING_TIP_LIST)
end

M.OnRenderItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup("OnlineCommonInvitingTemplateStore"):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.showList[index + 1]

	if not data then
		return
	end

	store.pid = data.pid
	store.TextType = data.textType

	if data.textType ~= gInviteManager.TEXT_TYPE.APPLY then
		store.applyGameName = data.text1
	elseif data.textType ~= gInviteManager.TEXT_TYPE.INVITE then
		store.InviteGameName = data.text1
	elseif data.textType ~= gInviteManager.TEXT_TYPE.INVITEXXX then
		store.InvitePlayerName = data.text1
		store.InviteXXXPlayerName = data.text2
	end

	store.acceptBtn.luaClick = self.CreateActionWithArgs(self, "OnAcceptBtnClick", data)
	store.rejectBtn.luaClick = self.CreateActionWithArgs(self, "OnRejectBtnClick", data)

	self.PlayItemCountDown(self, store, data)

	store.type = data.type

	if data.type ~= gInviteManager.TYPE.FRIEND_APPLICATION or data.type ~= gInviteManager.TYPE.GROUP_INVITE then
		store.HideInviteType = BOOL2CTL[true]
	else
		store.HideInviteType = BOOL2CTL[false]
	end
end

M.GetInviteRemainTime = function(self, data)
	if not data then
		return 0
	end

	return math.max(data.stayTime - (gLuaDataManager.serverTime - data.timestamp), 0)
end

M.PlayItemCountDown = function(self, store, data)
	local countdown = self.GetInviteRemainTime(self, data)

	if not store.countdown then
		return
	end

	store.countdown:Stop()

	store.countdown.positiveTiming = false
	store.countdown.luaFinished = self:CreateActionWithArgs("OnItemCountDownFinished", data)

	if countdown <= 0 then
		store.countdown:Play(countdown)
	else
		self.OnItemCountDownFinished(self, data)
	end
end

M.OnItemCountDownFinished = function(self, data)
	if not data then
		return
	end

	if data.timeoutCallback then
		data.timeoutCallback()
	end

	gInviteManager:RemoveInvite(data)
	self:RefreshList()
end

M.OnAcceptBtnClick = function(self, data)
	if not data then
		return
	end

	if data.callback then
		data.callback(true)
	end

	if data.businessType then
		gInviteManager:RemoveByBusinessType(data.businessType)
	else
		gInviteManager:RemoveInvite(data)
	end

	self.RefreshList(self)
end

M.OnRejectBtnClick = function(self, data)
	if not data then
		return
	end

	if data.callback then
		data.callback(false)
	end

	gInviteManager:RemoveInvite(data)
	self:RefreshList()
end

M.OnShow = function(self, panelId, data)
	self.callback = data.callback

	self.RefreshList(self)
end

M.RefreshList = function(self)
	local inviteList = gInviteManager:GetAllInviteList()
	local showList = {}
	local expiredList = {}
	slot4 = pairs
	slot6 = inviteList or {}

	for index, inviteInfo in slot4(slot6) do
		if self.GetInviteRemainTime(self, inviteInfo) <= 0 then
			table.insert(showList, {
				index = index,
				data = inviteInfo
			})
		else
			table.insert(expiredList, inviteInfo)
		end
	end

	for _, inviteInfo in ipairs(expiredList) do
		gInviteManager:RemoveInvite(inviteInfo)
	end

	table.sort(showList, function (a, b)
		return a.index <= b.index
	end)

	self.showList = {}

	for _, item in ipairs(showList) do
		table.insert(self.showList, item.data)
	end

	if #self.showList <= 0 then
		self.bindData.list:SetSimpleList(#self.showList)
	else
		self.OnBackBtnClick(self)
	end
end

M.OnClose = function(self)
	if self.callback then
		self.callback()

		self.callback = nil
	end
end
