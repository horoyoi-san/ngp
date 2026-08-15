local M = {
	TagNames = {
		"BodyTag",
		"StyleTag",
		"JobTag"
	},
	itemId2Info = {}
}

function M:GetChatId(npcId, itemId)
	if self.itemId2Info[itemId] then
		return self.itemId2Info[itemId].chatId
	end

	local npcCfg = self:GetNpcCfg(npcId)
	local chatList = self:GetChatListByNpcCfg(npcCfg)
	local chatItem = self:GetRandomItem(chatList)

	if chatItem == nil then
		print_error("RandomChatManager: GetRandomItem failed, npcId=" .. tostring(npcId))

		return nil
	end

	local chatId = chatItem.id
	self.lastShowChatId = chatId
	self.itemId2Info[itemId] = {
		chatId = chatId
	}

	return chatId
end

function M:MakePhoneCfgByChatId(chatId)
	local npcsPhoneCfg = {
		ChatBg = 0,
		BackToListAfterDialog = false,
		Owner = LTConfig.NPCChatConfig.DefaultAtmosphereNpcId,
		ChatList = {
			chatId
		},
		Dialog = {}
	}

	return npcsPhoneCfg
end

function M:TriggerFakeChat(chatId)
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)
	local npcsPhoneCfg = {
		BackToListAfterDialog = false,
		Owner = LTConfig.NPCChatConfig.DefaultAtmosphereNpcId
	}

	gChatUtils.OpenChatPanel({
		chatCfg = chatCfg,
		npcsPhoneCfg = npcsPhoneCfg
	})
end

function M:GetSubChannelId(chatCfg)
	if chatCfg == nil then
		print_error("RandomChatManager: GetSubChannelId failed, chatCfg is nil")

		return nil
	end

	if chatCfg.ChatGroup > 0 then
		return chatCfg.ChatGroup
	end

	while chatCfg.ShowAsReceiver do
		local nextMessage = chatCfg.NextMessage[1]

		if nextMessage then
			chatCfg = LTConfig.NPCChatConfig.GetConfig(nextMessage)
		else
			print_error("RandomChatManager: GetSubChannelId failed！这段短信配置全是我方发的，没法关联到对方的资料，请策划检查, chatId=" .. tostring(chatCfg.Id))

			return nil
		end
	end

	return chatCfg.NPCid
end

function M:GetNpcCfg(id)
	local cfg = LTConfig.AgentConfig.GetConfig(id)

	if cfg == nil then
		print_error("AgentConfig not found, id:", id)
	end

	return cfg
end

function M:IsMatchAllTags(npcCfg, targetChatSet)
	for _, tagName in ipairs(self.TagNames) do
		local npcTag = npcCfg[tagName]
		local targetTags = targetChatSet[tagName]

		if not self:IsMatchTag(npcTag, targetTags) then
			return false
		end
	end

	return true
end

function M:IsMatchTag(npcTag, targetTags)
	if table.isNilOrEmpty(targetTags) then
		return true
	end

	return table.contains(targetTags, npcTag)
end

function M:GetChatListByNpcCfg(npcCfg)
	local chatList = {}
	local count = LTConfig.NPCChatAtmosphereNewConfig.count

	for i = 0, count - 1 do
		local chatSetCfg = LTConfig.NPCChatAtmosphereNewConfig.LoadAt(i)

		if self:IsMatchAllTags(npcCfg, chatSetCfg) then
			M:InsertChatSetToList(chatList, chatSetCfg)
		end
	end

	return chatList
end

function M:InsertChatSetToList(chatList, chatSetCfg)
	if chatSetCfg.Weight == 0 then
		print_error("RandomChatManager: NPCChat_Atmosphere 表的 Weight 不能为 0!!!, id=" .. tostring(chatSetCfg.Id))
	end

	local weight = 60 / chatSetCfg.Weight

	for _, chatId in ipairs(chatSetCfg.ChatList) do
		if chatId ~= self.lastShowChatId then
			table.insert(chatList, {
				id = chatId,
				weight = weight
			})
		end
	end
end

function M:GetRandomItem(list)
	local totalWeight = 0

	for _, item in ipairs(list) do
		totalWeight = totalWeight + item.weight
	end

	local randomValue = math.random() * totalWeight
	local eps = 0.0001

	for _, item in ipairs(list) do
		randomValue = randomValue - item.weight

		if eps >= randomValue then
			return item
		end
	end

	print_error_without_stack("RandomChatManager: GetRandomItem failed, randomValue=" .. tostring(randomValue))

	for _, item in ipairs(list) do
		print_error_without_stack("RandomChatManager: GetRandomItem failed, id=" .. tostring(item.id) .. ", weight=" .. tostring(item.weight))
	end
end

function M:GetRandomImageId(config, itemId)
	local info = self.itemId2Info[itemId]

	if info.imageId then
		return info.imageId
	end

	local p = math.random()

	for _, v in ipairs(config) do
		p = p - v.Probability

		if p <= 0 then
			info.imageId = v.NpcsPhoneImageId

			return v.NpcsPhoneImageId
		end
	end

	info.imageId = 0

	return 0
end

gRandomChatManager = M
