C_ChatEditGroupMemberStore = DefClass("C_ChatEditGroupMemberStore", C_ChatEditGroupMemberStore, C_AppFragmentStore)
GroupName2Class.ChatEditGroupMemberStore = C_ChatEditGroupMemberStore
local M = C_ChatEditGroupMemberStore

function M:ctor()
	self.EDIT_TYPE = {
		ADD = 0,
		DELETE = 1
	}
	self.maxCount = 10
end

function M:OnAwake()
	self.bindData.deleteBtn.luaClick = self:CreateAction("OnDeleteBtnClick")
	self.bindData.addBtn.luaClick = self:CreateAction("OnAddBtnClick")
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
end

function M:OnShow(panelId, data)
	self.data = data.data
	self.editType = data.editType

	self:SetFriendList()
end

function M:SetFriendList()
	self.selectList = {}
	local friendList = {}
	self.bindData.EditType = self.editType

	if self.editType == self.EDIT_TYPE.ADD then
		friendList = gChatGroupManager:GetAddFriendList(self.data.Id)
	else
		friendList = gChatGroupManager:GetDelectFriendList(self.data.Id)
	end

	if not friendList or #friendList == 0 then
		self.bindData.empty = 1

		return
	end

	self.bindData.empty = 0

	gFriendManager:GetSimplePlayerInfoByPidList(friendList, function (infoList)
		local items = {}

		for i, v in ipairs(infoList) do
			local item = {
				tIndex = 0,
				id = v.Pid,
				data = v
			}

			table.insert(items, item)
		end

		self.bindData.list:SetList(items)
	end)

	self.canSelectCount = self:GetCanSelectCount()
	self.bindData.num1 = self.canSelectCount
	self.bindData.num2 = self.canSelectCount
end

function M:OnRenderItem(btn, _, data)
	local store = gStoreManager:GetStoreGroup("ChatBaseCardTemplateStore"):GetStoreByWidget(btn)
	local args = {
		btn = btn,
		data = data
	}
	btn.luaClick = self:CreateActionWithArgs("OnItemClick", args)
	store.typeCtrl = 0
	store.name = data.data.Name
	store.message = ""

	gChatUtils.GetPlayerSignature(data.id, function (sign)
		store.message = sign
	end)
	gChatAvatarUtils:SetChannelAvatar(gChatTopChannel.Friend, data.id, store.avatar)
end

function M:OnItemClick(data)
	local isSelect = false

	for i, v in pairs(self.selectList) do
		if v == data.data.id then
			isSelect = true

			table.remove(self.selectList, i)
			data.btn:SetSelected(false)

			break
		end
	end

	if not isSelect then
		table.insert(self.selectList, data.data.id)
		data.btn:SetSelected(true)
	end

	self:SetSelectNum(isSelect)
end

function M:SetSelectNum(isSelect)
	if isSelect then
		self.canSelectCount = self.canSelectCount + 1
	else
		self.canSelectCount = self.canSelectCount - 1
	end

	self.bindData.num1 = self.canSelectCount
	self.bindData.num2 = self.canSelectCount
end

function M:GetCanSelectCount()
	local curCount = gChatGroupManager:GetGroupHeadCount(self.data.Id)

	return gChatGroupManager.maxGroupCount - curCount
end

function M:OnDeleteBtnClick()
	gChatGroupManager:AskRemoveMemberFromChatGroup(self.data.Id, self.selectList)
	self.activity:CloseCurrentFragment()
end

function M:OnAddBtnClick()
	gChatGroupManager:AskInviteToJoinChatGroup(self.data.Id, self.selectList)
	self.activity:CloseCurrentFragment()
end
