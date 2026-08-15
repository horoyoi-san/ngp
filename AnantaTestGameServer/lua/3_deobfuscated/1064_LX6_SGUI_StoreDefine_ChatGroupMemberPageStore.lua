C_ChatGroupMemberPageStore = DefClass("C_ChatGroupMemberPageStore", C_ChatGroupMemberPageStore, C_AppFragmentStore)
GroupName2Class.ChatGroupMemberPageStore = C_ChatGroupMemberPageStore
local M = C_ChatGroupMemberPageStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction("OnRenderItem")
end

function M:OnShow(panelId, data)
	self.groupData = data

	self:SetGroupList()
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

		self.bindData.list:SetList(items)
	end)
end

function M:OnRenderItem(btn, index, data)
	local store = gStoreManager:GetStoreGroup("ChatGroupHead"):GetStoreByWidget(btn)
	store.title = data.data.Name
end
