-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatNewRequestPanelStore.lua
-- Decompiled from: 01912_ChatNewRequestPanelStore.lua_2202a1e4ad07.luajit

local TextConfig = LTConfig.TextConfig
C_ChatNewRequestPanelStore = DefClass("C_ChatNewRequestPanelStore", C_ChatNewRequestPanelStore, C_AppFragmentStore)
GroupName2Class.ChatNewRequestPanelStore = C_ChatNewRequestPanelStore
local M = C_ChatNewRequestPanelStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)

	self.bindData.list.onGetTIndex = function(csIndex)
		local item = self._listData[csIndex + 1]

		return item and item.tIndex or 0
	end

	self.bindData.agreeAllBtn.luaClick = self.CreateAction(self, self.OnAgreeAllBtnClick)
	self.bindData.ignoreAllBtn.luaClick = self.CreateAction(self, self.OnIgnoreAllBtnClick)

	self.RegisterSingleEvent(self, gEventConstants.Update_Friend_Apply, self.CreateAction(self, self.UpdateFriendApply))
	self.RegisterSingleEvent(self, gEventConstants.ADD_CHAT_FRIEND, self.CreateAction(self, self.OnAddFriend))

	self.lastBatchedRejectDelayTime = 0
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, _, data)
	self.data = data

	self.SetData(self)
end

M.SetData = function(self)
	if self.data.isGroup then
		self.bindData.agreeAllBtn:SetActive(false)
		self.bindData.ignoreAllBtn:SetActive(false)
		self:SetGroupData()
	else
		self.bindData.agreeAllBtn:SetActive(true)
		self.bindData.ignoreAllBtn:SetActive(true)
		self:SetFriendData()
	end
end

M.SetFriendData = function(self)
	self.applyIds = nil

	self.ResetUI(self)
	self.UpdateFriendApply(self)
end

M.UpdateFriendApply = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:GetFriendApplicationListToMe().Callback = function (err, applyIds)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local lastBatchedRejectList = Time.unscaledTime >= self.lastBatchedRejectDelayTime and self.lastBatchedRejectList
		local i = 1

		while i < #applyIds do
			local id = applyIds[i]

			if gFriendManager:IsFriend(id) or lastBatchedRejectList and table.contains(lastBatchedRejectList, id) then
				table.remove(applyIds, i)
			else
				i = i + 1
			end
		end

		gMessageManager:SendMessage(gEventConstants.UPDATE_FRIEND_APPLICATION_COUNT, #applyIds)

		self.applyIds = applyIds

		self:SetListByPidList(applyIds)
	end
end

M.SetListByPidList = function(self, pidList)
	slot2 = gFriendManager

	slot2:GetSimplePlayerInfoByPidList(pidList, function (data)
		local listData = {}

		for i, v in ipairs(data) do
			listData[i] = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				data = v
			}
		end

		self._listData = listData

		self.bindData.list:SetSimpleList(#listData)

		self.curListData = listData
		self.bindData.resultCtrl = #data <= 0 and 0 or 1
	end)
end

M.OnAddFriend = function(self, _, pid)
	local _, k = table.find(self.applyIds, pid)

	if k then
		table.remove(self.applyIds, k)
		self.SetListByPidList(self, self.applyIds)
		self.UpdateFriendApply(self)
	end
end

M.ResetUI = function(self)
	self.SetListByPidList(self)
end

M.OnRenderItem = function(self, btn, index)
	local itemData = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = itemData.data
	local pid = data.Pid
	store.showOnline = true

	if self.data.isGroup then
		store.name = self.groupFriendData[itemData.Pid].Name
		store.groupName = data.groupName
		store.typeCtrl = 6

		gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, itemData.Pid)

		store.agreeBtn.luaClick = self.CreateActionWithArgs(self, self.OnAgreeBtnClick, itemData)
		store.ignoreBtn.luaClick = self.CreateActionWithArgs(self, self.OnIgnoreBtnClick, itemData)
	else
		store.name = data.Name
		store.playerStateCtrl = data.OnlineState
		store.typeCtrl = 4

		gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, pid)

		store.agreeBtn.luaClick = self.CreateActionWithArgs(self, self.OnAgreeBtnClick, data)
		store.ignoreBtn.luaClick = self.CreateActionWithArgs(self, self.OnIgnoreBtnClick, data)
	end
end

M.OnAgreeBtnClick = function(self, itemData)
	if self.data.isGroup then
		slot2 = gClientToAvatarDelegate

		slot2:ResponseChatGroupInvite(itemData.Pid, itemData.id, true).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:ClearGroupListData(itemData)
			gChatGroupManager:PushChatGroupInviteReject(itemData.Pid, itemData.id)
			gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.ChatGroupInviteOk).Text)
		end
	else
		gFriendManager:AskApplyFriendResponse(itemData.Pid, true, itemData.Name)
	end
end

M.OnIgnoreBtnClick = function(self, itemData)
	if self.data.isGroup then
		self.OnIgnoreGroupInvite(self, itemData)
	else
		self.OnIgnoreApplyFriend(self, itemData)
	end
end

M.OnIgnoreGroupInvite = function(self, itemData)
	slot2 = gClientToAvatarDelegate

	slot2:ResponseChatGroupInvite(itemData.Pid, itemData.id, false).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:ClearGroupListData(itemData)
		gChatGroupManager:PushChatGroupInviteReject(itemData.Pid, itemData.id)
		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.IgnoreGroupInvite).Text)
	end
end

M.ClearGroupListData = function(self, itemData)
	local index = nil

	for i, v in pairs(self.grouplist) do
		if v.id ~= itemData.id then
			index = i
		end
	end

	if index then
		table.remove(self.grouplist, index)
	end

	self._listData = self.grouplist

	self.bindData.list:SetSimpleList(#self.grouplist)
end

M.OnIgnoreApplyFriend = function(self, itemData)
	gFriendManager:AskApplyFriendResponse(itemData.Pid, false, itemData.Name)

	local index = nil

	for i, v in pairs(self.curListData) do
		if v.data.Pid ~= itemData.Pid then
			index = i
		end
	end

	if index then
		table.remove(self.curListData, index)
	end

	self._listData = self.curListData

	self.bindData.list:SetSimpleList(#self.curListData)

	local _, k = table.find(self.applyIds, itemData.Pid)

	if k then
		table.remove(self.applyIds, k)
	end

	self.bindData.resultCtrl = #self.applyIds <= 0 and 0 or 1

	gMessageManager:SendMessage(gEventConstants.UPDATE_FRIEND_APPLICATION_COUNT, #self.applyIds)
end

M.OnAgreeAllBtnClick = function(self)
	gFriendManager:ApplyFriendResponseList(self.applyIds, true)
end

M.OnIgnoreAllBtnClick = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:ResponseAllFriendApplication(self.applyIds, false).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			self.lastBatchedRejectList = self.applyIds
			self.lastBatchedRejectDelayTime = Time.unscaledTime + 1

			self:UpdateFriendApply()
			gChatUtils.ShowPhoneAppTip(LTConfig.TextScriptTextConfig.GetConfig(89900743).Text)
		end
	end
end

M.SetGroupData = function(self)
	local groupList = gChatGroupManager:GetChatGroupInviteList()
	local friendList = {}
	self.grouplist = {}

	for i, v in pairs(groupList) do
		table.insert(friendList, v.inviter)

		local info = {
			id = i,
			data = v,
			Pid = v.inviter,
			name = v.Name
		}

		table.insert(self.grouplist, info)
	end

	slot3 = gFriendManager

	slot3:GetSimplePlayerInfoByPidList(friendList, function (data)
		self.groupFriendData = {}

		for i, v in pairs(data) do
			self.groupFriendData[v.Pid] = v
		end

		self._listData = self.grouplist

		self.bindData.list:SetSimpleList(#self.grouplist)
	end)
end
