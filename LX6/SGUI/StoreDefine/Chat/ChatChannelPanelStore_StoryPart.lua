-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\Chat\ChatChannelPanelStore_StoryPart.lua
-- Decompiled from: 01932_ChatChannelPanelStore_StoryPart.lua_f46ffb6c3b0a.luajit

local M = C_ChatChannelPanelStore

M.RefreshStoryList = function(self, isContactPage)
	local topChannelId = gChatTopChannel.Npc
	local items = {}

	if isContactPage then
		local infoDict = gNpcInteracsUtils:GetInteractableNpcSet()

		for channelId, _ in pairs(infoDict) do
			local cfg = LTConfig.NpcCultivationConfig.GetConfig(channelId)

			if not gSpiritManager.CheckIsDefaultSpiritId(cfg.FightSpiritID) then
				table.insert(items, self.CreateSubChannelItem(self, topChannelId, channelId, true))
			end
		end
	else
		local baseTopChannel = gChatManager:GetChannel(gChatTopChannel.Npc)
		local topChannels = {
			[topChannelId] = baseTopChannel.subChannels,
			[gChatTopChannel.NpcGroup] = gChatManager:GetChannel(gChatTopChannel.NpcGroup).subChannels
		}

		for iTopChannelId, topChannel in pairs(topChannels) do
			for channelId, channelInfo in pairs(topChannel.ToTable(topChannel)) do
				if not table.isNilOrEmpty(gChatManager:FilterStoryMessages(channelInfo.messages:ToTable())) then
					table.insert(items, self.CreateSubChannelItem(self, iTopChannelId, channelId))
				end
			end
		end
	end

	gChatUtils.SortSubChannelItems(items)

	self.subChannelItems = items

	self.SetSubChannelList(self)
end

M.OnRenderNpcItem = function(self, _, _, itemData, store)
	local npcTid = itemData.subChannelId
	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

	if npcChatInfo ~= nil then
		return
	end

	store.name = npcChatInfo.GetName(npcChatInfo)
	store.showOnline = true
	store.playerStateCtrl = 0
end

M.OnRenderNpcGroupItem = function(self, _, _, itemData, store)
	local groupId = itemData.subChannelId
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(groupId)
	store.name = cfg.GroupName
	store.showOnline = false
	store.playerStateCtrl = 0
end

M.OnClickStorySubChannelItem = function(self, btn, itemData)
	gChatUtils.OpenNpcPersonalPage(itemData.subChannelId)
end

M.RefreshGroupList = function(self)
	local groupChats = gChatGroupManager:GetChatGroups()
	local list = {}

	if gChatGroupManager:GetChatGroupInviteCount() <= 0 then
		local data = {
			id = -1,
			tIndex = 1,
			topChannelId = gChatTopChannel.Group
		}

		table.insert(list, 1, data)
	end

	if gTeamManager:IsInTeam() then
		local data = {
			id = -2,
			tindex = 0,
			topChannelId = gChatTopChannel.Group,
			subChannelId = gTeamManager.teamId,
			value = {}
		}
		data.value.Name = LTConfig.TextScriptTextConfig.GetConfig(89900116).Text

		table.insert(list, data)
	end

	if gLinkManager:CheckInLinkMode() then
		local data = {
			id = -3,
			tindex = 0,
			topChannelId = gChatTopChannel.Group,
			subChannelId = self.SetCurLinkChannel(self),
			value = {}
		}
		data.value.Name = LTConfig.TextScriptTextConfig.GetConfig(89901092).Text

		table.insert(list, data)
	end

	for i, v in pairs(groupChats) do
		local data = {
			id = i,
			tindex = 0,
			topChannelId = gChatTopChannel.Group,
			subChannelId = i,
			value = v
		}

		table.insert(list, data)
	end

	self.subChannelItems = list

	self.SetSubChannelList(self)
end

M.SetCurLinkChannel = function(self)
	local subChannelId = 0

	if gLinkManager.LinkMode ~= UX.Game.LinkMode.Private then
		subChannelId = UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Public then
		subChannelId = UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.Match then
		subChannelId = UX.Game.MessageChannel.MatchLink
	end

	return subChannelId
end

M.OnRenderGroupItem = function(self, btn, _, itemData, store)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemData.value then
		return
	end

	store.name = itemData.value.Name
	store.message = ""
end

M.OnGroupItemBtnClick = function(self, btn, itemData)
	if itemData.tIndex ~= 1 then
		self.activity:ShowFragment(gChatConst.TabShowType.NewRequest, {
			["\\xd0\\xc831\\xe1"] = true
		})
	else
		if itemData.id ~= -2 then
			gChatManager:GetOrAddSubChannel(gChatTopChannel.Team, UX.Game.MessageChannel.Team)
			gChatManager:UpdateCurrentChannel(gChatTopChannel.Team, UX.Game.MessageChannel.Team)

			return
		end

		if itemData.id ~= -3 then
			gChatManager:GetOrAddSubChannel(gChatTopChannel.Channels, itemData.subChannelId)
			gChatManager:UpdateCurrentChannel(gChatTopChannel.Channels, itemData.subChannelId)

			return
		end

		gChatManager:GetOrAddSubChannel(gChatTopChannel.Group, itemData.subChannelId)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Group, itemData.subChannelId)
	end
end
