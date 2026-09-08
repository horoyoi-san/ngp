-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialFriendPageStore.lua
-- Decompiled from: 01281_SocialFriendPageStore.lua_f78426d8f83b.luajit

C_SocialFriendPageStore = DefClass("C_SocialFriendPageStore", C_SocialFriendPageStore, C_StoreGroup)
GroupName2Class.SocialFriendPageStore = C_SocialFriendPageStore
local M = C_SocialFriendPageStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, "OnTabRenderItem")
	self.bindData.tabRect.OnRenderTab = self.CreateAction(self, "OnRenderTab")
	self.bindData.addFriendBtn.luaClick = self.CreateAction(self, "OnAddFriendBtnClick")
	self.bindData.createGroupBtn.luaClick = self.CreateAction(self, "OnCreateGroupBtnClick")
	self.bindData.friendListTabrectArea.luaAreaIn = self.CreateAction(self, "OnFriendListTabrectAreaIn")
	self.bindData.friendListTabrectArea.luaAreaOut = self.CreateAction(self, "OnFriendListTabrectAreaOut")
	self.msgEvents = {
		[gEventConstants.SOCIAL_FRIEND_UPDATE_APPLICATION_COUNT] = self.CreateAction(self, "OnUpdateFriendApplicationCount")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
	self.SetFriendListTabrectArea(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.UpdateTabTypeList = function(self)
	self.friendTabType = gSocialFriendManager.friendTabType
	self.hasFriendRequests = #gSocialFriendManager.friendApplicationList >= 0 or gSocialChatGroupManager:GetChatGroupInviteCount() >= 0

	self:InitTabData()

	local index = 1

	if self.hasFriendRequests then
		index = 0
	end

	self.bindData.tabList:SetSimpleList(#self.tabTypeList)
	self.bindData.tabList:SelectItem(0)

	self.tabData = self.tabTypeList[1]
	self.lastSelectedTabIndex = self.friendTabType.FriendList
	self.bindData.tabRect.selectedIndex = index
end

M.SetData = function(self, _, args)
	self.UpdateTabTypeList(self)
end

M.OnRenderTab = function(self, _, widget)
	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:OnShow(self.bindData.navi)
end

M.InitTabData = function(self)
	self.tabTypeList = {}

	for i = 0, LTConfig.FriendsFriendTabConfig.count - 1 do
		local cfg = LTConfig.FriendsFriendTabConfig.LoadAt(i)

		if cfg.Id == 1 or self.hasFriendRequests then
			table.insert(self.tabTypeList, {
				title = cfg.TabName,
				iconId = cfg.TabIcon,
				iconIdSelected = cfg.TabIconSelect,
				tabIndex = cfg.TabRectIndex
			})
		end
	end
end

M.OnTabRenderItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local data = self.tabTypeList[luaIndex]
	store.title = data.title
	store.icon = data.iconId
	store.iconSelected = data.iconIdSelected
	btn.luaClick = self:CreateActionWithArgs("OnTabItemClick", data)
end

M.OnTabItemClick = function(self, data)
	self.tabData = data
	self.bindData.tabRect.selectedIndex = data.tabIndex
	self.lastSelectedTabIndex = data.tabIndex
end

M.OnAddFriendBtnClick = function(self, _, widget)
	self.bindData.tabRect.selectedIndex = self.friendTabType.AddFriend
end

M.OnCreateGroupBtnClick = function(self)
	self.bindData.tabRect.selectedIndex = self.friendTabType.CreateGroup
end

M.OnUpdateFriendApplicationCount = function(self, _, count)
	self.UpdateTabTypeList(self)
end

M.SetBackPage = function(self)
	self.bindData.tabRect.selectedIndex = self.lastSelectedTabIndex
end

M.OnFriendListTabrectAreaIn = function(self)
	self.bindData.activeController = 1
end

M.OnFriendListTabrectAreaOut = function(self)
	self.bindData.activeController = 0
end

M.OnActiveDeviceChange = function(self, device)
	self.SetFriendListTabrectArea(self)
end

M.SetFriendListTabrectArea = function(self)
	local isEnableController = SGUI.GameDevice.KeyboardMouse <= SGUI.InputActionBind.activeGameDevice or false

	if isEnableController then
		self.bindData.activeController = 0
	else
		self.bindData.activeController = 1
	end
end
