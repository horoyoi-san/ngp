C_ChatBlackListPageStore = DefClass("C_ChatBlackListPageStore", C_ChatBlackListPageStore, C_AppFragmentStore)
GroupName2Class.ChatBlackListPageStore = C_ChatBlackListPageStore
local M = C_ChatBlackListPageStore

function M:OnAwake()
	self.bindData.list.luaRenderItem = self:CreateAction(self.OnRenderItem)
end

function M:OnShow(_, data)
	self.bindData.list:SetList({})
	self:RefreshBlackList()
end

function M:RefreshBlackList()
	local blackList = gFriendManager:GetBlackList()

	if not blackList or #blackList == 0 then
		self.bindData.empty = 1

		return
	end

	self.bindData.empty = 0

	gFriendManager:GetSimplePlayerInfoByPidList(blackList, function (infoList)
		local items = {}

		for i, info in ipairs(infoList) do
			local item = {
				tIndex = 0,
				topChannelId = gChatTopChannel.Friend,
				subChannelId = info.Pid,
				info = info
			}

			table.insert(items, item)
		end

		self.bindData.list:SetList(items)
	end)
end

function M:OnRenderItem(btn, csIndex, data)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	gChatAvatarUtils:SetChannelAvatar(data.topChannelId, data.subChannelId, store.avatar)

	store.name = data.info.Name

	function store.deleteBtn.luaClick()
		gFriendManager:RemoveFromBlackList(data.info.Pid, function (err)
			if err == LTConfig.MessageConfig.Ok then
				self:RefreshBlackList()
			end
		end)
	end

	btn.luaClick = self:CreateActionWithArgs("OpenPersonalPage", data)
end

function M:OpenPersonalPage(data)
	gChatUtils.OpenPersonalPage(data.info.Pid)
end
