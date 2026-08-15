local M = {
	DefaultPlayerAvatar = LTConfig.ImageAvatarConfig.GetConfig(LTConfig.ImageAvatarConfig.AdultMH),
	PathIdList = {
		1,
		2,
		3,
		4
	}
}

function M:SetChannelAvatar(topChannelId, subChannelId, chatHeadWidget, chatHeadStore)
	local bindData = chatHeadStore or self:GetChatHeadStoreByWidget(chatHeadWidget)
	subChannelId = gChatManager:TranslateSubChannelType(topChannelId, subChannelId)

	self:SetIcon(bindData, topChannelId, subChannelId)
end

function M:SetSingleAvatar(senderId, chatHeadWidget, chatHeadStore)
	local bindData = chatHeadStore or self:GetChatHeadStoreByWidget(chatHeadWidget)

	bindData.container:SetUrlByID(self.PathIdList[1], function (content)
		bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

		self:SetIconBySenderId(bindData, "singleIcon", senderId)
	end)
end

function M:GetStoreGroup()
	if self.storeGroup == nil then
		self.storeGroup = gStoreManager:GetStoreGroup("ChatHeadStore")
	end

	return self.storeGroup
end

function M:GetChatHeadStoreByWidget(chatHeadWidget)
	local storeProxy = self:GetStoreGroup():GetStoreByWidget(chatHeadWidget)

	return storeProxy
end

function M:GetIconIdByNpcId(npcId)
	local npcCfg = LTConfig.NPCChatNpcConfig.GetConfig(npcId)

	if npcCfg then
		return npcCfg.SIcon
	end

	npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

	if npcCfg then
		return npcCfg.SChatHeadId
	end

	return nil
end

function M:SetIcon(bindData, topChannelId, subChannelId)
	if topChannelId == gChatTopChannel.Npc then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = self:GetIconIdByNpcId(subChannelId)
		end)
	elseif topChannelId == gChatTopChannel.NpcGroup then
		self:SetGroupIconsBySubChannelId(bindData, subChannelId)
	elseif topChannelId == gChatTopChannel.Friend then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

			self:SetIconByPid(bindData, "singleIcon", subChannelId)
		end)
	elseif topChannelId == gChatTopChannel.Group then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = 28002104
		end)
	elseif topChannelId == gChatTopChannel.Channels then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = 28002142
		end)
	end
end

function M:SetIconBySenderId(bindData, fieldName, senderId)
	if senderId.pid then
		self:SetIconByPid(bindData, fieldName, senderId.pid)
	else
		bindData.contentStore[fieldName] = self:GetIconIdByNpcId(senderId.npcId)
	end
end

function M:SetIconByPid(bindData, fieldName, pid)
	gChatManager:GetImageAvatarConfigByPidWithCallback(pid, function (success, avatarConfig)
		bindData.contentStore[fieldName] = (avatarConfig or self.DefaultPlayerAvatar).SguiImageId
	end)
end

function M:SetGroupIconsBySubChannelId(bindData, subChannelId)
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannelId)

	self:SetGroupIconsByGroupConfig(bindData, cfg)
end

function M:SetGroupIconsByGroupConfig(bindData, cfg)
	if cfg.SIcon > 0 then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = cfg.SIcon
		end)

		return
	end

	local groupMember = {}

	for _, npcId in ipairs(cfg.GroupMember) do
		table.insert(groupMember, ChatSenderId.NewNpc(npcId))
	end

	if gChatNpcsPhoneManager.isNpcsPhone then
		table.insert(groupMember, ChatSenderId.NewNpc(gChatNpcsPhoneManager.phoneCfg.Owner))
	elseif cfg.AsNpcCultivation ~= L50.Chat.ChatManager.PlayerSelf then
		table.insert(groupMember, ChatSenderId.NewNpc(cfg.AsNpcCultivation))
	else
		table.insert(groupMember, ChatSenderId.NewPlayer())
	end

	local groupMemberCount = #groupMember
	local avatarCount = groupMemberCount
	local loadIndex = nil

	if groupMemberCount > 4 then
		loadIndex = 4
		avatarCount = 3
	else
		loadIndex = groupMemberCount
	end

	bindData.container:SetUrlByID(self.PathIdList[loadIndex], function (content)
		bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

		if groupMemberCount > 4 then
			bindData.contentStore.groupCount = groupMemberCount
			bindData.contentStore.type = 1
		else
			bindData.contentStore.type = 0
		end

		for i = 1, avatarCount do
			local senderId = groupMember[i]

			self:SetIconBySenderId(bindData, "groupIcon" .. i, senderId)
		end
	end)
end

gChatAvatarUtils = M
