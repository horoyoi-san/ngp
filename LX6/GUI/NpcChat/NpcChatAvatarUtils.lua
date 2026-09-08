-- Original chunk: @Lua\LuaFiles\LX6\GUI\NpcChat\NpcChatAvatarUtils.lua
-- Decompiled from: 00309_NpcChatAvatarUtils.lua_dc12d78da6f0.luajit

local ImageAvatar = LTConfig.ImageNewAvatarConfig
local M = {
	DefaultPlayerAvatar = LTConfig.ImageNewAvatarConfig.GetConfig(LTConfig.ImageNewAvatarConfig.AdultMH),
	PathIdList = {
		5,
		6,
		7,
		8
	},
	SetChannelAvatar = function (self, topChannelId, subChannelId, chatHeadWidget)
		local bindData = self.GetNpcChatHeadStoreByWidget(self, chatHeadWidget)

		self.SetIcon(self, bindData, topChannelId, subChannelId)
	end,
	SetSingleAvatar = function (self, senderId, chatHeadWidget)
		local bindData = self:GetNpcChatHeadStoreByWidget(chatHeadWidget)
		slot4 = bindData.container

		slot4:SetUrlByID(self.PathIdList[1], function (content)
			bindData.contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

			self:SetIconBySenderId(bindData, "singleIcon", senderId)
		end)
	end,
	GetStoreGroup = function (self)
		if self.storeGroup ~= nil then
			self.storeGroup = gStoreManager:GetStoreGroup("NpcChatHeadStore")
		end

		return self.storeGroup
	end
}

M.GetNpcChatHeadStoreByWidget = function(self, chatHeadWidget)
	local storeProxy = gStoreManager:GetStoreGroup(chatHeadWidget.Store):GetStoreByWidget(chatHeadWidget)

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
	if topChannelId ~= gNpcChatConst.ChatTopChannel.Npc then
		if subChannelId ~= gNpcChatConst.PlayerSelfIndex then
			slot4 = bindData.container

			slot4:SetUrlByID(self.PathIdList[1], function (content)
				local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
				local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
				local cfg = ImageAvatar.GetConfig(path)
				contentStore.singleIcon = (cfg or self.DefaultPlayerAvatar).SguiImageId
			end)

			return
		else
			slot4 = bindData.container

			slot4:SetUrlByID(self.PathIdList[1], function (content)
				local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
				contentStore.singleIcon = self:GetIconIdByNpcId(subChannelId)
			end)
		end
	elseif topChannelId ~= gNpcChatConst.ChatTopChannel.NpcGroup then
		self.SetGroupIconsBySubChannelId(self, bindData, subChannelId)
	end
end

M.SetIconBySenderId = function(self, bindData, fieldName, senderId)
	local npcId = senderId and senderId.npcId or 1
	local asNpc = npcId == 0 and npcId or gNpcChatUtils.GetCurrentNpcId()

	if asNpc == 1 then
		bindData.contentStore[fieldName] = self.GetIconIdByNpcId(self, asNpc)
	else
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, true)
		local cfg = ImageAvatar.GetConfig(path)
		bindData.contentStore[fieldName] = (cfg or self.DefaultPlayerAvatar).SguiImageId
	end
end

M.SetIconBySenderIdNew = function(self, bindData, fieldName, senderId)
	if senderId.pid then
		local isMe = true
		local _, path = gImageManager:GetHeadIconByHeadIconInfo(gPlayerManager.infoLogin.bindData.infoPzHeadInfo, gPlayerManager.infoLogin.bindData.sexType, isMe)
		local iconId = path
		local cfg = ImageAvatar.GetConfig(iconId)
		bindData[fieldName] = (cfg or self.DefaultPlayerAvatar).SguiImageId
	else
		bindData[fieldName] = self.GetIconIdByNpcId(self, senderId.npcId)
	end
end

M.SetGroupIconsBySubChannelId = function(self, bindData, subChannelId)
	local cfg = LTConfig.NPCChatGroupConfig.GetConfig(subChannelId)

	self.SetGroupIconsByGroupConfig(self, bindData, cfg)
end

M.GetGroupMembersFromCfg = function(self, cfg)
	local groupMember = {}

	for _, npcId in ipairs(cfg.GroupMember) do
		table.insert(groupMember, NpcChatSenderId.NewNpc(npcId))
	end

	if gNpcChatNpcsPhoneManager.isNpcsPhone then
		table.insert(groupMember, NpcChatSenderId.NewNpc(gNpcChatNpcsPhoneManager.phoneCfg.Owner))
	elseif cfg.AsNpcCultivation == gNpcChatConst.PlayerSelfIndex then
		table.insert(groupMember, NpcChatSenderId.NewNpc(cfg.AsNpcCultivation))
	else
		table.insert(groupMember, NpcChatSenderId.NewPlayer())
	end

	return groupMember
end

M.SetGroupIconsByGroupConfig = function(self, bindData, cfg)
	if cfg.SIcon <= 0 then
		slot3 = bindData.container

		slot3:SetUrlByID(self.PathIdList[1], function (content)
			local contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)
			contentStore.singleIcon = cfg.SIcon
		end)

		return
	end

	local groupMember = self.GetGroupMembersFromCfg(self, cfg)
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
		bindData.contentStore = gStoreManager:GetStoreGroup(content.Store):GetStoreByWidget(content)

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

gNpcChatAvatarUtils = M
