local ImageAvatar = LTConfig.ImageAvatarConfig
local M = {
	DefaultPlayerAvatar = LTConfig.ImageAvatarConfig.GetConfig(LTConfig.ImageAvatarConfig.AdultMH),
	PathIdList = {
		5,
		6,
		7,
		8
	},
	SetChannelAvatar = function (self, topChannelId, subChannelId, chatHeadWidget)
		local bindData = self:GetNpcChatHeadStoreByWidget(chatHeadWidget)

		self:SetIcon(bindData, topChannelId, subChannelId)
	end,
	SetSingleAvatar = function (self, senderId, chatHeadWidget)
		local bindData = self:GetNpcChatHeadStoreByWidget(chatHeadWidget)

		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			bindData.contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

			self:SetIconBySenderId(bindData, "singleIcon", senderId)
		end)
	end,
	GetStoreGroup = function (self)
		if self.storeGroup == nil then
			self.storeGroup = gStoreManager:GetStoreGroup("NpcChatHeadStore")
		end

		return self.storeGroup
	end
}

function M:GetNpcChatHeadStoreByWidget(chatHeadWidget)
	local storeProxy = gStoreManager:GetStoreGroup(chatHeadWidget.Store):GetStoreByWidget(chatHeadWidget)

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
	if topChannelId == gNpcChatConst.ChatTopChannel.Npc then
		if subChannelId == gNpcChatConst.PlayerSelfIndex then
			bindData.container:SetUrlByID(self.PathIdList[1], function (content)
				local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
				local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
				local cfg = ImageAvatar.GetConfig(path)
				contentStore.singleIcon = (cfg or self.DefaultPlayerAvatar).SguiImageId
			end)

			return
		else
			bindData.container:SetUrlByID(self.PathIdList[1], function (content)
				local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
				contentStore.singleIcon = self:GetIconIdByNpcId(subChannelId)
			end)
		end
	elseif topChannelId == gNpcChatConst.ChatTopChannel.NpcGroup then
		self:SetGroupIconsBySubChannelId(bindData, subChannelId)
	end
end

function M:SetIconBySenderId(bindData, fieldName, senderId)
	local npcId = senderId and senderId.npcId or 1
	local asNpc = npcId ~= 0 and npcId or gNpcChatUtils.GetCurrentNpcId()

	if asNpc ~= 1 then
		bindData.contentStore[fieldName] = self:GetIconIdByNpcId(asNpc)
	else
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
		local cfg = ImageAvatar.GetConfig(path)
		bindData.contentStore[fieldName] = (cfg or self.DefaultPlayerAvatar).SguiImageId
	end
end

function M:SetIconBySenderIdNew(bindData, fieldName, senderId)
	if senderId.pid then
		local isMe = true
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)
		bindData[fieldName] = (cfg or self.DefaultPlayerAvatar).SguiImageId
	else
		bindData[fieldName] = self:GetIconIdByNpcId(senderId.npcId)
	end
end

function M:SetGroupIconsBySubChannelId(bindData, subChannelId)
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannelId)

	self:SetGroupIconsByGroupConfig(bindData, cfg)
end

function M:GetGroupMembersFromCfg(cfg)
	local groupMember = {}

	for _, npcId in ipairs(cfg.GroupMember) do
		table.insert(groupMember, NpcChatSenderId.NewNpc(npcId))
	end

	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		table.insert(groupMember, NpcChatSenderId.NewNpc(gNpcChatNpcsPhoneManager.phoneCfg.Owner))
	elseif cfg.AsNpcCultivation ~= gNpcChatConst.PlayerSelfIndex then
		table.insert(groupMember, NpcChatSenderId.NewNpc(cfg.AsNpcCultivation))
	else
		table.insert(groupMember, NpcChatSenderId.NewPlayer())
	end

	return groupMember
end

function M:SetGroupIconsByGroupConfig(bindData, cfg)
	if cfg.SIcon > 0 then
		bindData.container:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
			contentStore.singleIcon = cfg.SIcon
		end)

		return
	end

	local groupMember = self:GetGroupMembersFromCfg(cfg)
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
		bindData.contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

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

gNpcChatAvatarUtils = M
