local TextConfig = LTConfig.TextConfig
C_ChatNewRequestPanelStore = DefClass("C_ChatNewRequestPanelStore", C_ChatNewRequestPanelStore, C_AppFragmentStore)
GroupName2Class.ChatNewRequestPanelStore = C_ChatNewRequestPanelStore
local M = C_ChatNewRequestPanelStore

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.agreeAllBtn.luaClick = self:CreateAction(self.OnAgreeAllBtnClick)
	self.bindData.ignoreAllBtn.luaClick = self:CreateAction(self.OnIgnoreAllBtnClick)

	self:RegisterSingleEvent(gEventConstants.Update_Friend_Apply, self:CreateAction(self.UpdateFriendApply))
	self:RegisterSingleEvent(gEventConstants.ADD_CHAT_FRIEND, self:CreateAction(self.OnAddFriend))

	self.lastBatchedRejectDelayTime = 0
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnShow(_, data)
	self.data = data

	self:SetData()
end

function M:SetData()
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

function M:SetFriendData()
	self.applyIds = nil

	self:ResetUI()
	self:UpdateFriendApply()
end

function M:UpdateFriendApply()
	gClientToAvatarDelegate:GetFriendApplicationListToMe().Callback = function (err, applyIds)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		local lastBatchedRejectList = Time.unscaledTime < self.lastBatchedRejectDelayTime and self.lastBatchedRejectList
		local i = 1

		while i <= #applyIds do
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

function M:SetListByPidList(pidList)
	gFriendManager:GetSimplePlayerInfoByPidList(pidList, function (data)
		local listData = {}

		for i, v in ipairs(data) do
			listData[i] = {
				tIndex = 0,
				data = v
			}
		end

		self.bindData.list:SetList(listData)

		self.curListData = listData
		self.bindData.resultCtrl = #data > 0 and 0 or 1
	end)
end

function M:OnAddFriend(_, pid)
	local _, k = table.find(self.applyIds, pid)

	if k then
		table.remove(self.applyIds, k)
		self:SetListByPidList(self.applyIds)
		self:UpdateFriendApply()
	end
end

function M:ResetUI()
	self:SetListByPidList()
end

function M:OnRenderItem(btn, _, itemData)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local data = itemData.data
	local pid = data.Pid
	store.showOnline = true

	if self.data.isGroup then
		store.name = self.groupFriendData[itemData.Pid].Name
		store.groupName = data.groupName
		store.typeCtrl = 6

		gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, itemData.Pid)

		store.agreeBtn.luaClick = self:CreateActionWithArgs(self.OnAgreeBtnClick, itemData)
		store.ignoreBtn.luaClick = self:CreateActionWithArgs(self.OnIgnoreBtnClick, itemData)
	else
		store.name = data.Name
		store.playerStateCtrl = data.OnlineState
		store.typeCtrl = 4

		gChatUtils.SetChatChannelCardBaseView(btn, gChatTopChannel.Friend, pid)

		store.agreeBtn.luaClick = self:CreateActionWithArgs(self.OnAgreeBtnClick, data)
		store.ignoreBtn.luaClick = self:CreateActionWithArgs(self.OnIgnoreBtnClick, data)
	end
end

function M:OnAgreeBtnClick(itemData)
	if self.data.isGroup then
		gClientToAvatarDelegate:ResponseChatGroupInvite(itemData.Pid, itemData.id, true).Callback = function (err)
			if err ~= LTConfig.MessageConfig.Ok then
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

function M:OnIgnoreBtnClick(itemData)
	if self.data.isGroup then
		self:OnIgnoreGroupInvite(itemData)
	else
		self:OnIgnoreApplyFriend(itemData)
	end
end

function M:OnIgnoreGroupInvite(itemData)
	gClientToAvatarDelegate:ResponseChatGroupInvite(itemData.Pid, itemData.id, false).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:ClearGroupListData(itemData)
		gChatGroupManager:PushChatGroupInviteReject(itemData.Pid, itemData.id)
		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.IgnoreGroupInvite).Text)
	end
end

function M:ClearGroupListData(itemData)
	local index = nil

	for i, v in pairs(self.grouplist) do
		if v.id == itemData.id then
			index = i
		end
	end

	if index then
		table.remove(self.grouplist, index)
	end

	self.bindData.list:SetList(self.grouplist)
end

function M:OnIgnoreApplyFriend(itemData)
	gFriendManager:AskApplyFriendResponse(itemData.Pid, false, itemData.Name)

	local index = nil

	for i, v in pairs(self.curListData) do
		if v.data.Pid == itemData.Pid then
			index = i
		end
	end

	if index then
		table.remove(self.curListData, index)
	end

	self.bindData.list:SetList(self.curListData)

	local _, k = table.find(self.applyIds, itemData.Pid)

	if k then
		table.remove(self.applyIds, k)
	end

	self.bindData.resultCtrl = #self.applyIds > 0 and 0 or 1

	gMessageManager:SendMessage(gEventConstants.UPDATE_FRIEND_APPLICATION_COUNT, #self.applyIds)
end

function M:OnAgreeAllBtnClick()
	gFriendManager:ApplyFriendResponseList(self.applyIds, true)
end

function M:OnIgnoreAllBtnClick()
	gClientToAvatarDelegate:ResponseAllFriendApplication(self.applyIds, false).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			self.lastBatchedRejectList = self.applyIds
			self.lastBatchedRejectDelayTime = Time.unscaledTime + 1

			self:UpdateFriendApply()
			gChatUtils.ShowPhoneAppTip(LTConfig.TextScriptTextConfig.GetConfig(89900743).Text)
		end
	end
end

function M:SetGroupData()
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

	gFriendManager:GetSimplePlayerInfoByPidList(friendList, function (data)
		self.groupFriendData = {}

		for i, v in pairs(data) do
			self.groupFriendData[v.Pid] = v
		end

		self.bindData.list:SetList(self.grouplist)
	end)
end
