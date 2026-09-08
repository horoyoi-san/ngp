-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChatEditGroupMemberStore.lua
-- Decompiled from: 02027_ChatEditGroupMemberStore.lua_619bf18e10f1.luajit

C_ChatEditGroupMemberStore = DefClass("C_ChatEditGroupMemberStore", C_ChatEditGroupMemberStore, C_AppFragmentStore)
GroupName2Class.ChatEditGroupMemberStore = C_ChatEditGroupMemberStore
local M = C_ChatEditGroupMemberStore

M.ctor = function(self)
	self.EDIT_TYPE = {
		["\\xafLB"] = 0,
		["8m\\xbd\\xab\\xb7d"] = 1
	}
	self.maxCount = 10
end

M.OnAwake = function(self)
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnDeleteBtnClick")
	self.bindData.addBtn.luaClick = self.CreateAction(self, "OnAddBtnClick")
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.bindData.list.onGetTIndex = function(csIndex)
		return self._listData[csIndex + 1].tIndex
	end
end

M.OnShow = function(self, panelId, data)
	self.data = data.data
	self.editType = data.editType

	self.SetFriendList(self)
end

M.SetFriendList = function(self)
	self.selectList = {}
	local friendList = {}
	self.bindData.EditType = self.editType

	if self.editType ~= self.EDIT_TYPE.ADD then
		friendList = gChatGroupManager:GetAddFriendList(self.data.Id)
	else
		friendList = gChatGroupManager:GetDelectFriendList(self.data.Id)
	end

	if not friendList or #friendList ~= 0 then
		self.bindData.empty = 1

		return
	end

	self.bindData.empty = 0

	gFriendManager:GetSimplePlayerInfoByPidList(friendList, function (infoList)
		local items = {}

		for i, v in ipairs(infoList) do
			local item = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = v.Pid,
				data = v
			}

			table.insert(items, item)
		end

		self._listData = items

		self.bindData.list:SetSimpleList(#items)
	end)

	self.canSelectCount = self:GetCanSelectCount()
	self.bindData.num1 = self.canSelectCount
	self.bindData.num2 = self.canSelectCount
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
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

M.OnItemClick = function(self, data)
	local isSelect = false

	for i, v in pairs(self.selectList) do
		if v ~= data.data.id then
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

	self.SetSelectNum(self, isSelect)
end

M.SetSelectNum = function(self, isSelect)
	if isSelect then
		self.canSelectCount = self.canSelectCount + 1
	else
		self.canSelectCount = self.canSelectCount - 1
	end

	self.bindData.num1 = self.canSelectCount
	self.bindData.num2 = self.canSelectCount
end

M.GetCanSelectCount = function(self)
	local curCount = gChatGroupManager:GetGroupHeadCount(self.data.Id)

	return gChatGroupManager.maxGroupCount - curCount
end

M.OnDeleteBtnClick = function(self)
	gChatGroupManager:AskRemoveMemberFromChatGroup(self.data.Id, self.selectList)
	self.activity:CloseCurrentFragment()
end

M.OnAddBtnClick = function(self)
	gChatGroupManager:AskInviteToJoinChatGroup(self.data.Id, self.selectList)
	self.activity:CloseCurrentFragment()
end
