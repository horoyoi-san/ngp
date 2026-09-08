-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatBlackListPageStore.lua
-- Decompiled from: 01928_ChatBlackListPageStore.lua_7dad8239f0f0.luajit

C_ChatBlackListPageStore = DefClass("C_ChatBlackListPageStore", C_ChatBlackListPageStore, C_AppFragmentStore)
GroupName2Class.ChatBlackListPageStore = C_ChatBlackListPageStore
local M = C_ChatBlackListPageStore

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)

	self.bindData.list.onGetTIndex = function(csIndex)
		return self._listData[csIndex + 1].tIndex
	end
end

M.OnShow = function(self, _, data)
	self._listData = {}

	self.bindData.list:SetSimpleList(0)
	self:RefreshBlackList()
end

M.RefreshBlackList = function(self)
	local blackList = gFriendManager:GetBlackList()

	if not blackList or #blackList ~= 0 then
		self.bindData.empty = 1

		return
	end

	self.bindData.empty = 0
	slot2 = gFriendManager

	slot2:GetSimplePlayerInfoByPidList(blackList, function (infoList)
		local items = {}

		for i, info in ipairs(infoList) do
			local item = {
				["a\\x9f\\x8a\\x86Y"] = 0,
				topChannelId = gChatTopChannel.Friend,
				subChannelId = info.Pid,
				info = info
			}

			table.insert(items, item)
		end

		self._listData = items

		self.bindData.list:SetSimpleList(#items)
	end)
end

M.OnRenderItem = function(self, btn, csIndex)
	local data = self._listData[csIndex + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	gChatAvatarUtils:SetChannelAvatar(data.topChannelId, data.subChannelId, store.avatar)

	store.name = data.info.Name

	store.deleteBtn.luaClick = function()
		gFriendManager:RemoveFromBlackList(data.info.Pid, function (err)
			if err ~= LTConfig.MessageConfig.Ok then
				self:RefreshBlackList()
			end
		end)
	end

	btn.luaClick = self:CreateActionWithArgs("OpenPersonalPage", data)
end

M.OpenPersonalPage = function(self, data)
	gChatUtils.OpenPersonalPage(data.info.Pid)
end
