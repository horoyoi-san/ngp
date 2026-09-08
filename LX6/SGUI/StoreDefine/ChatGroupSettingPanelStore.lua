-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChatGroupSettingPanelStore.lua
-- Decompiled from: 02029_ChatGroupSettingPanelStore.lua_2af78d8b98e4.luajit

local TextConfig = LTConfig.TextConfig
C_ChatGroupSettingPanelStore = DefClass("C_ChatGroupSettingPanelStore", C_ChatGroupSettingPanelStore, C_AppFragmentStore)
GroupName2Class.ChatGroupSettingPanelStore = C_ChatGroupSettingPanelStore
local M = C_ChatGroupSettingPanelStore

M.ctor = function(self)
	self.EDIT_TYPE = {
		["\\xafLB"] = 0,
		["8m\\xbd\\xab\\xb7d"] = 1
	}
	self.GROUP_OWNER = {
		["k\\x8f\\x8e\\x9c\\x93"] = 0,
		["NH~"] = 1
	}
end

M.OnAwake = function(self)
	self.bindData.exitGroup.luaClick = self.CreateAction(self, "OnExitBtnClick")
	self.bindData.editBtn.luaClick = self.CreateAction(self, "OnEditBtnClick")
	self.bindData.addBtn.luaClick = self.CreateAction(self, "OnAddBtnClick")
	self.bindData.deleteBtn.luaClick = self.CreateAction(self, "OnDeleteBtnClick")
	self.bindData.moreBtn.luaClick = self.CreateAction(self, "OnMoreBtnClick")
	self.bindData.muteMessageBtn.luaClick = self.CreateAction(self, "OnMuteMessageBtnClick")
	self.bindData.deleteMessage.luaClick = self.CreateAction(self, "OnDeleteMessageBtnClick")
	self.bindData.deleteGroup.luaClick = self.CreateAction(self, "OnDeleteGroupBtnClick")
	self.bindData.groupList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.bindData.groupList.onGetTIndex = function(csIndex)
		return self._groupListData[csIndex + 1].tIndex
	end
end

M.OnShow = function(self, panelId, data)
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

M.SetGroupList = function(self)
	slot1 = gFriendManager

	slot1:GetSimplePlayerInfoByPidList(self.groupData.Members, function (infoList)
		local items = {}

		for i, v in ipairs(infoList) do
			local item = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				id = v.Pid,
				data = v
			}

			table.insert(items, item)
		end

		self._groupListData = items

		self.bindData.groupList:SetSimpleList(#items)
	end)
end

M.SetData = function(self)
	self.bindData.groupName = self.groupData.Name
	self.owner = gPlayerManager.infoLogin.bindData.pid ~= self.groupData.Owner

	if self.owner then
		self.bindData.groupOwner = self.GROUP_OWNER.TRUE
	else
		self.bindData.groupOwner = self.GROUP_OWNER.FALSE
	end

	self.bindData.groupName = self.groupData.Name
end

M.OnRenderItem = function(self, btn, index)
	local data = self._groupListData[index + 1]
	local store = gStoreManager:GetStoreGroup("ChatGroupHead"):GetStoreByWidget(btn)
	store.title = data.data.Name
end

M.OnExitBtnClick = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:AskQuitChatGroup(self.groupId).Callback = function (errorId, msg)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		self.activity:CloseFragment()
	end
end

M.OnEditBtnClick = function(self)
end

M.OnAddBtnClick = function(self)
	gChatUtils.OpenGroupPage(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.ADD
	})
end

M.OnDeleteBtnClick = function(self)
	gChatUtils.OpenGroupPage(gChatConst.TabShowType.EditGroupMember, {
		data = self.groupData,
		editType = self.EDIT_TYPE.DELETE
	})
end

M.OnMoreBtnClick = function(self)
	self.activity:ShowFragment(gChatConst.TabShowType.GroupMemberPage, self.groupData)
end

M.OnDeleteGroupBtnClick = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:AskDismissChatGroup(self.groupId).Callback = function (errorId, msg)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.DismissChatGroup).Text)
		self.activity:CloseCurrentFragment()
	end
end

M.OnMuteMessageBtnClick = function(self)
	slot1 = gClientToAvatarDelegate

	slot1:AskChatGroupSetRecvMsg(self.groupId, true).Callback = function (errorId, msg)
		if errorId == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(errorId)

			return
		end

		gChatUtils.ShowPhoneAppTip(TextConfig.GetConfig(TextConfig.ChatGroupSetRecvMsgFalse).Text)
	end
end

M.OnDeleteMessageBtnClick = function(self)
end
