-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialGroupListStore.lua
-- Decompiled from: 01282_SocialGroupListStore.lua_1b3bc3ac5f11.luajit

C_SocialGroupListStore = DefClass("C_SocialGroupListStore", C_SocialGroupListStore, C_StoreGroup)
GroupName2Class.SocialGroupListStore = C_SocialGroupListStore
local M = C_SocialGroupListStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderGroupItem")
end

M.BindEvent = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_CHAT_GROUP_MEMBER_CHANGE] = self.CreateAction(self, "RefreshGroupList"),
		[gEventConstants.SOCIAL_GROUP_NAME_CHANGED] = self.CreateAction(self, "RefreshGroupList")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.RemoveEvent = function(self)
	self.ClearMessageEvents(self)
end

M.OnEnable = function(self)
	self.BindEvent(self)
	self.RefreshGroupList(self)
end

M.OnDisable = function(self)
	self.RemoveEvent(self)
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi
end

M.RefreshGroupList = function(self)
	self.groupList = gSocialChatGroupManager:GetGroupList()

	self.bindData.list:SetSimpleList(#self.groupList)

	self.bindData.num = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901366).Text, #self.groupList, LTConfig.FriendsConfig.ChatGroupMax)
	self.bindData.isEmpty = #self.groupList < 0 and 1 or 0
end

M.OnRenderGroupItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local group = self.groupList[luaIndex]

	if group then
		store.title = group.Name
		store.num = #group.Members
		btn.luaClick = self.CreateActionWithArgs(self, "OnGroupItemClick", group.groupId)
	end
end

M.OnGroupItemClick = function(self, groupId)
	gSocialChatManager:JumpToChat(gSocialChatManager.ChatTopChannel.Group, groupId)
end
