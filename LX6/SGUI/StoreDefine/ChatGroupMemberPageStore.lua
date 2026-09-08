-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChatGroupMemberPageStore.lua
-- Decompiled from: 02028_ChatGroupMemberPageStore.lua_75ed15012e6a.luajit

C_ChatGroupMemberPageStore = DefClass("C_ChatGroupMemberPageStore", C_ChatGroupMemberPageStore, C_AppFragmentStore)
GroupName2Class.ChatGroupMemberPageStore = C_ChatGroupMemberPageStore
local M = C_ChatGroupMemberPageStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")

	self.bindData.list.onGetTIndex = function(csIndex)
		return self._listData[csIndex + 1].tIndex
	end
end

M.OnShow = function(self, panelId, data)
	self.groupData = data

	self.SetGroupList(self)
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

		self._listData = items

		self.bindData.list:SetSimpleList(#items)
	end)
end

M.OnRenderItem = function(self, btn, index)
	local data = self._listData[index + 1]
	local store = gStoreManager:GetStoreGroup("ChatGroupHead"):GetStoreByWidget(btn)
	store.title = data.data.Name
end
