-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SocialFriendBlackListStore.lua
-- Decompiled from: 01279_SocialFriendBlackListStore.lua_83e340c98497.luajit

C_SocialFriendBlackListStore = DefClass("C_SocialFriendBlackListStore", C_SocialFriendBlackListStore, C_StoreGroup)
GroupName2Class.SocialFriendBlackListStore = C_SocialFriendBlackListStore
local M = C_SocialFriendBlackListStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderFriendItem")

	self.InitMessageEvents(self)
end

M.InitMessageEvents = function(self)
	local msgEvents = {
		[gEventConstants.SOCIAL_FRIEND_INFO_CHANGE] = self.CreateAction(self, "RefreshBlackList")
	}

	self.RegisterMessageEvents(self, msgEvents)
end

M.OnEnable = function(self)
	self.RefreshBlackList(self)
end

M.OnShow = function(self, data)
	self.parentNavi = data
	self.bindData.navi.leftNav = self.parentNavi
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.RefreshBlackList = function(self)
	self.bindData.list:SetSimpleList(#gSocialFriendManager.blackList)

	self.bindData.isEmpty = #gSocialFriendManager.blackList < 0 and 1 or 0
end

M.OnRenderFriendItem = function(self, btn, csIndex)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local luaIndex = csIndex + 1
	local friendPid = gSocialFriendManager.blackList[luaIndex]

	if friendPid then
		store.userInfo.pid = friendPid
		store.deleteBtn.luaClick = self.CreateActionWithArgs(self, "OnDeleteBtnClick", friendPid)
		store.headBtn.luaRenderTooltip = self.CreateActionWithArgs(self, "OnRenderToolTips", friendPid)
	end
end

M.OnRenderToolTips = function(self, pid, btn, PopUp, _)
	local store = gStoreManager:GetStoreGroup("SocialPalyerTooltipStore"):GetStoreByWidget(PopUp)

	if not store then
		return
	end

	gSocialPalyerTooltipManager:OnRenderToolTips(pid, btn, PopUp, _)
end

M.OnDeleteBtnClick = function(self, friendPid)
	slot2 = gFriendManager

	slot2:GetSimplePlayerInfo(friendPid, function (info)
		self:RemoveFromBlackList(friendPid, info)
	end)
end

M.RemoveFromBlackList = function(self, pid, info)
	slot3 = gDisplayMessageMgr

	slot3:ShowMessage(LTConfig.MessageConfig.SocialRemoveFromBlacklist, function ()
		gSocialFriendManager:RemoveFromBlackList(pid)
	end, nil, info.Name)
end
