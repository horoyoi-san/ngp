local TextConfig = LTConfig.TextConfig
C_ChatGroupSettingPanelStore = DefClass("C_ChatGroupSettingPanelStore", C_ChatGroupSettingPanelStore, C_AppFragmentStore)
GroupName2Class.ChatGroupSettingPanelStore = C_ChatGroupSettingPanelStore
local M = C_ChatGroupSettingPanelStore

function M:ctor()
	self.EDIT_TYPE = {
		ADD = 0,
		DELETE = 1
	}
	self.GROUP_OWNER = {
		FALSE = 0,
		TRUE = 1
	}
end

function M:OnAwake()
	self.bindData.exitGroup.luaClick = self:CreateAction("OnExitBtnClick")
	self.bindData.editBtn.luaClick = self:CreateAction("OnEditBtnClick")
	self.bindData.addBtn.luaClick = self:CreateAction("OnAddBtnClick")
	self.bindData.deleteBtn.luaClick = self:CreateAction("OnDeleteBtnClick")
	self.bindData.moreBtn.luaClick = self:CreateAction("OnMoreBtnClick")
	self.bindData.muteMessageBtn.luaClick = self:CreateAction("OnMuteMessageBtnClick")
	self.bindData.deleteMessage.luaClick = self:CreateAction("OnDeleteMessageBtnClick")
	self.bindData.deleteGroup.luaClick = self:CreateAction("OnDeleteGroupBtnClick")
	self.bindData.groupList.luaRenderItem = self:CreateAction("OnRenderItem")
end

function M:OnShow(panelId, data)
	self.groupData = data
	self.groupId = data.Id
	self.groupOwner = data.Owner

	if not self.groupOwner then
		self.bindData.addBtn:SetActive(false)
		self.bindData.deleteBtn:SetActive(false)
		self.bindData.exitGroup:SetActive(false)
	else
		self.bindData.addBtn:SetActive(true)
		self.bindData.deleteBtn:SetActive(true)
		self.bindData.exitGroup:SetActive(true)
		self:SetData()
		self:SetGroupList()
	end
end

function M:SetGroupList()
	gFriendManager:GetSimplePlayerInfoByPidList(self.groupData.Members, function (infoList)
		local items = {}

		for i, v in ipairs(infoList) do
			local item = {
				tIndex = 0,
				id = v.Pid,
				data = v
			}

			table.insert(items, item)
		end

		self.bindData.groupList:SetList(items)
	end)
end

function M:SetData()
	self.bindData.groupName = self.groupData.Name
	self.owner = gPlayerManager.infoLogin.bindData.pid == self.groupData.Owner

	if self.owner then
		self.bindData.groupOwner = self.GROUP_OWNER.TRUE
	else
		self.bindData.groupOwner = self.GROUP_OWNER.FALSE
	end

	self.bindData.groupName = self.groupData.Name
end

function M:OnRenderItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ChatGroupHead"):GetStoreByWidget(btn)
	store.title = data.data.Name
end

function M:OnExitBtnClick()
	gClientToAvatarDelegate:AskQuitChatGroup(self.groupId).Callback = function (errorId, msg)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.activity:CloseFragment()
	end
end

function M:OnEditBtnClick()
	return
end

function M:OnAddBtnClick()
	gChatUtils.OpenGroupPage(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.ADD
	})
end

function M:OnDeleteBtnClick()
	gChatUtils.OpenGroupPage(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.DELETE
	})
end

function M:OnMoreBtnClick()
	self.activity:ShowFragment(gChatConst.TabShowType.GroupMemberPage, self.groupData)
end

function M:OnDeleteGroupBtnClick()
	gClientToAvatarDelegate:AskDismissChatGroup(self.groupId).Callback = function (errorId, msg)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.DismissChatGroup).Text)
		self.activity:CloseCurrentFragment()
	end
end

function M:OnMuteMessageBtnClick()
	gClientToAvatarDelegate:AskChatGroupSetRecvMsg(self.groupId, true).Callback = function (errorId, msg)
		if errorId ~= LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.ChatGroupSetRecvMsgFalse).Text)
	end
end

function M:OnDeleteMessageBtnClick()
	return
end
