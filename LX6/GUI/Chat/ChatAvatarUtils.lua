-- Original chunk: @Lua\LuaFiles\LX6\GUI\Chat\ChatAvatarUtils.lua
-- Decompiled from: 00296_ChatAvatarUtils.lua_4cd2441b308b.luajit

local M = {
	DefaultPlayerAvatar = LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH),
	PathIdList = {
		1,
		2,
		3,
		4
	}
}

M.SetChannelAvatar = function(self, topChannelId, subChannelId, chatHeadWidget, chatHeadStore)
	local bindData = chatHeadStore or self:GetChatHeadStoreByWidget(chatHeadWidget)
	subChannelId = gChatManager:TranslateSubChannelType(topChannelId, subChannelId)

	self:SetIcon(bindData, topChannelId, subChannelId)
end

M.SetSingleAvatar = function(self, senderId, chatHeadWidget, chatHeadStore)
	local bindData = chatHeadStore or self:GetChatHeadStoreByWidget(chatHeadWidget)

	bindData.container:SetUrlByID(self.PathIdList[1], function (content)
		bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

		self:SetIconBySenderId(bindData, "singleIcon", senderId)
	end)
end

M.GetStoreGroup = function(self)
	if self.storeGroup ~= nil then
		self.storeGroup = gStoreManager:GetStoreGroup("ChatHeadStore")
	end

	return self.storeGroup
end

M.GetChatHeadStoreByWidget = function(self, chatHeadWidget)
	local storeProxy = self:GetStoreGroup():GetStoreByWidget(chatHeadWidget)

	return storeProxy
end

M.GetIconIdByNpcId = function(self, npcId)
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

M.SetIcon = function(self, bindData, topChannelId, subChannelId)
	if topChannelId ~= gChatTopChannel.Npc then
		slot4 = bindData.container

		slot4:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = self:GetIconIdByNpcId(subChannelId)
		end)
	elseif topChannelId ~= gChatTopChannel.NpcGroup then
		self.SetGroupIconsBySubChannelId(self, bindData, subChannelId)
	elseif topChannelId ~= gChatTopChannel.Friend then
		slot4 = bindData.container

		slot4:SetUrlByID(self.PathIdList[1], function (content)
			bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

			self:SetIconByPid(bindData, "singleIcon", subChannelId)
		end)
	elseif topChannelId ~= gChatTopChannel.Group then
		slot4 = bindData.container

		slot4:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = 28002104
		end)
	elseif topChannelId ~= gChatTopChannel.Channels then
		slot4 = bindData.container

		slot4:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = self:GetStoreGroup():GetStoreByWidget(content)
			contentStore.singleIcon = 28002142
		end)
	end
end

M.SetIconBySenderId = function(self, bindData, fieldName, senderId)
	if senderId.pid then
		self.SetIconByPid(self, bindData, fieldName, senderId.pid)
	else
		bindData.contentStore[fieldName] = self.GetIconIdByNpcId(self, senderId.npcId)
	end
end

M.SetIconByPid = function(self, bindData, fieldName, pid)
	slot4 = gChatManager

	slot4:GetImageAvatarConfigByPidWithCallback(pid, function (success, avatarConfig)
		bindData.contentStore[fieldName] = (avatarConfig or self.DefaultPlayerAvatar).SguiImageId
	end)
end

M.SetGroupIconsBySubChannelId = function(self, bindData, subChannelId)
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannelId)

	self.SetGroupIconsByGroupConfig(self, bindData, cfg)
end

M.SetGroupIconsByGroupConfig = function(self, bindData, cfg)
	if cfg.SIcon <= 0 then
		slot3 = bindData.container

		slot3:SetUrlByID(self.PathIdList[1], function (content)
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
	elseif cfg.AsNpcCultivation == L50.Chat.ChatManager.PlayerSelf then
		table.insert(groupMember, ChatSenderId.NewNpc(cfg.AsNpcCultivation))
	else
		table.insert(groupMember, ChatSenderId.NewPlayer())
	end

	local groupMemberCount = #groupMember
	local avatarCount = groupMemberCount
	local loadIndex = nil

	if groupMemberCount <= 4 then
		loadIndex = 4
		avatarCount = 3
	else
		loadIndex = groupMemberCount
	end

	slot7 = bindData.container

	slot7:SetUrlByID(self.PathIdList[loadIndex], function (content)
		bindData.contentStore = self:GetStoreGroup():GetStoreByWidget(content)

		if groupMemberCount <= 4 then
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
