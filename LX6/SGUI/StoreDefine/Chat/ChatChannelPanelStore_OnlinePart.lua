-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChannelPanelStore_OnlinePart.lua
-- Decompiled from: 01931_ChatChannelPanelStore_OnlinePart.lua_5511b560c281.luajit

local M = C_ChatChannelPanelStore

M.RefreshFriendList = function(self, isContactPage)
	if not isContactPage then
		return
	end

	slot2 = gFriendManager.cs

	slot2:GetOrderedFriendList(function (pidList)
		local items = {}

		if #gFriendManager.friendApplicationList <= 0 then
			local applyItem = {
				["a\\x9f\\x8a\\x86Y"] = 1
			}

			table.insert(items, 1, applyItem)
		end

		pidList = pidList:ToTable()
		local topChannelId = gChatTopChannel.Friend

		for _, pid in ipairs(pidList) do
			local data = self:CreateSubChannelItem(topChannelId, pid, true)

			if data then
				table.insert(items, data)
			end
		end

		slot3 = gFriendManager

		slot3:GetSimplePlayerInfoByPidList(pidList, function (data)
			if self.STATE_EnableOnce and data then
				for i, v in ipairs(data) do
					items[i].info = v
				end

				self.subChannelItems = items

				self:SetSubChannelList()
			end
		end)
	end)
end

M.RefreshFriendMessage = function(self)
	local items = {}
	local baseTopChannel = gChatManager:GetChannel(gChatTopChannel.Friend)
	local topChannels = {
		[gChatTopChannel.Friend] = baseTopChannel.subChannels
	}

	for iTopChannelId, topChannel in pairs(topChannels) do
		for channelId, channelInfo in pairs(topChannel.ToTable(topChannel)) do
			table.insert(items, self.CreateSubChannelItem(self, iTopChannelId, channelId))
		end
	end

	if items and #items <= 0 then
		gChatUtils.SortSubChannelItems(items)
		print_debug(items)
	end

	self.subChannelItems = items

	self.SetSubChannelList(self)
end

M.OnRenderFriendListItem = function(self, _, _, itemData, store)
	local pid = itemData.subChannelId
	local remarkName = gFriendManager:GetFriendRemarkName(pid)
	store.name = remarkName or (itemData.info or {}).Name
	store.isSpecialCtrl = gFriendManager:IsSpecialFriend(pid) and 1 or 0

	gFriendManager:GetSimplePlayerInfo(pid, function (data)
		if data then
			local lastLogoutTime = data.LastLogoutTime
			local onlineState = data.OnlineState

			if onlineState ~= UX.Game.PlayerState.Online then
				store.playerStateCtrl = 0
			elseif onlineState ~= UX.Game.PlayerState.Detached then
				store.playerStateCtrl = 1
			else
				store.playerStateCtrl = 2
				store.lastLogoutTime = gCS.LuaUtils.FormatLastLogoutTime(lastLogoutTime)
			end
		end
	end)
end

M.OnRenderFriendItem = function(self, _, _, itemData, store)
	local pid = itemData.subChannelId
	store.isSpecialCtrl = gFriendManager:IsSpecialFriend(pid) and 1 or 0
	local remarkName = gFriendManager:GetFriendRemarkName(pid)
	store.name = remarkName or gSocialFriendManager:GetPlayerDisplayName(pid, (itemData.info or {}).Name or "")
	store.message = itemData.content

	gFriendManager:GetSimplePlayerInfo(pid, function (data)
		if data then
			local lastLogoutTime = data.LastLogoutTime
			local onlineState = data.OnlineState

			if onlineState ~= UX.Game.PlayerState.Online then
				store.playerStateCtrl = 0
			elseif onlineState ~= UX.Game.PlayerState.Detached then
				store.playerStateCtrl = 1
			else
				store.playerStateCtrl = 2
				store.lastLogoutTime = gCS.LuaUtils.FormatLastLogoutTime(lastLogoutTime)
			end
		end
	end)
end

M.OnFriendItemBtnClick = function(self, btn, itemData)
	gChatManager:GetOrAddSubChannel(gChatTopChannel.Friend, tonumber(itemData.id))
	gChatManager:UpdateCurrentChannel(gChatTopChannel.Friend, tonumber(itemData.id))
end

M.OnClickOnlineSubChannelItem = function(self, btn, itemData)
	if itemData.tIndex ~= 1 then
		self.activity:ShowFragment(gChatConst.TabShowType.NewRequest)
	else
		gChatUtils.OpenPersonalPage(itemData.subChannelId)
	end
end

M.UpdateCount = function(self, count)
	local lastCount = self.friendApplyCount

	if lastCount ~= count then
		return
	end

	self.friendApplyCount = count
	self.bindData.friendApplyCount = count
	self.bindData.friendApplyCountCtrl = count <= 0 and 1 or 0

	if not self.selectedTopChannelId ~= gChatTopChannel.Friend then
		return
	end

	local redKey = self:GetChatTopBarBtnFriendRedDotKey()

	SGUI.RedDotMgr.LuaSetRedDot(self.friendApplyCount >= 0, redKey)

	if self:IsCurrentListShowFriendApplyBanner() then
		if count ~= 0 then
			self.RefreshSubChannelList(self, self.selectedTopChannelId)
		else
			self.list:RefreshElement(0)
		end
	elseif count <= 0 then
		self.RefreshSubChannelList(self, self.selectedTopChannelId)
	end
end

M.RefreshFriendData = function(self, count)
	self:UpdateCount(count)

	slot2 = gClientToAvatarDelegate

	slot2:GetFriendApplicationListToMe().Callback = function (err, applyIds)
		if err ~= LTConfig.MessageConfig.Ok then
			gFriendManager:GetSimplePlayerInfoByPidList(applyIds)
		end
	end
end

M.OnAddFriend = function(self, _, pid)
	if self.currentTabCsIndex ~= self.TabDefine.ContactPageCs and self.selectedTopChannelId ~= gChatTopChannel.Friend then
		self.RefreshSubChannelList(self, self.selectedTopChannelId)
	end
end

M.OnUpdateFriendApplicationCount = function(self, _, count)
	self.RefreshFriendData(self, count)
end

M.InitFriend = function(self)
	gFriendManager:AskFriendRed()
end
