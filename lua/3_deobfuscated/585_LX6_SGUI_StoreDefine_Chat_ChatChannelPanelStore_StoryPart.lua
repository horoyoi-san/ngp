local M = C_ChatChannelPanelStore

function M:RefreshStoryList(isContactPage)
	local topChannelId = gChatTopChannel.Npc
	local items = {}

	if isContactPage then
		local infoDict = gNpcInteracsUtils:GetInteractableNpcSet()

		for channelId, _ in pairs(infoDict) do
			local cfg = LTConfig.NpcCultivationConfig.GetConfig(channelId)

			if not gSpiritManager.CheckIsDefaultSpiritId(cfg.FightSpiritID) then
				table.insert(items, self:CreateSubChannelItem(topChannelId, channelId, true))
			end
		end
	else
		local baseTopChannel = gChatManager:GetChannel(gChatTopChannel.Npc)
		local topChannels = {
			[topChannelId] = baseTopChannel.subChannels,
			[gChatTopChannel.NpcGroup] = gChatManager:GetChannel(gChatTopChannel.NpcGroup).subChannels
		}

		for iTopChannelId, topChannel in pairs(topChannels) do
			for channelId, channelInfo in pairs(topChannel:ToTable()) do
				if not table.isNilOrEmpty(gChatManager:FilterStoryMessages(channelInfo.messages:ToTable())) then
					table.insert(items, self:CreateSubChannelItem(iTopChannelId, channelId))
				end
			end
		end
	end

	gChatUtils.SortSubChannelItems(items)

	self.subChannelItems = items

	self:SetSubChannelList()
end

function M:OnRenderNpcItem(_, _, itemData, store)
	local npcTid = itemData.subChannelId
	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

	if npcChatInfo == nil then
		return
	end

	store.name = npcChatInfo:GetName()
	store.showOnline = true
	store.playerStateCtrl = 0
end

function M:OnRenderNpcGroupItem(_, _, itemData, store)
	local groupId = itemData.subChannelId
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(groupId)
	store.name = cfg.GroupName
	store.showOnline = false
	store.playerStateCtrl = 0
end

function M:OnClickStorySubChannelItem(btn, itemData)
	gChatUtils.OpenNpcPersonalPage(itemData.subChannelId)
end

function M:RefreshGroupList()
	local groupChats = gChatGroupManager:GetChatGroups()
	local list = {}

	if gChatGroupManager:GetChatGroupInviteCount() > 0 then
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
			subChannelId = self:SetCurLinkChannel(),
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

	self:SetSubChannelList()
end

function M:SetCurLinkChannel()
	local subChannelId = 0

	if gLinkManager.LinkMode == UX.Game.LinkMode.Private then
		subChannelId = UX.Game.MessageChannel.PrivateLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Public then
		subChannelId = UX.Game.MessageChannel.PublicLink
	elseif gLinkManager.LinkMode == UX.Game.LinkMode.Match then
		subChannelId = UX.Game.MessageChannel.MatchLink
	end

	return subChannelId
end

function M:OnRenderGroupItem(btn, _, itemData, store)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not itemData.value then
		return
	end

	store.name = itemData.value.Name
	store.message = ""
end

function M:OnGroupItemBtnClick(btn, itemData)
	if itemData.tIndex == 1 then
		self.activity:ShowFragment(gChatConst.TabShowType.NewRequest, {
			isGroup = true
		})
	else
		if itemData.id == -2 then
			gChatManager:GetOrAddSubChannel(gChatTopChannel.Team, UX.Game.MessageChannel.Team)
			gChatManager:UpdateCurrentChannel(gChatTopChannel.Team, UX.Game.MessageChannel.Team)

			return
		end

		if itemData.id == -3 then
			gChatManager:GetOrAddSubChannel(gChatTopChannel.Channels, itemData.subChannelId)
			gChatManager:UpdateCurrentChannel(gChatTopChannel.Channels, itemData.subChannelId)

			return
		end

		gChatManager:GetOrAddSubChannel(gChatTopChannel.Group, itemData.subChannelId)
		gChatManager:UpdateCurrentChannel(gChatTopChannel.Group, itemData.subChannelId)
	end
end
