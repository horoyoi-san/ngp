local NPCChatConfig = LTConfig.NPCChatConfig
local M = {
	_InitData = function (self)
		self.isNpcsPhone = false
		self.subChannelId = nil
		self.phoneCfg = nil
		self.dialogCfg = nil
		self.chatCfg = nil
		self.currentChatCfg = nil
		self.npcName = nil
		self.playerSign = nil
		self.mainDialog = nil
		self.logViewFinished = false
		self.subChannelId2DialogCfg = {}
		self.dialogPlayed = {}
		self.atmosphereNpcInfo = nil
		self.isAtmosphereNpc = nil
	end
}

M:_InitData()

function M:Init(npcPhoneCfg, chatCfg, chatPanelParams)
	self.isNpcsPhone = true
	self.phoneCfg = npcPhoneCfg
	self.chatCfg = chatCfg
	self.dialogCfg = {}

	for i, cfg in ipairs(self.phoneCfg.Dialog) do
		self.dialogCfg[i] = gUtils:ShallowCopy(cfg)
	end

	M:GetPlayerSign()

	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(self.phoneCfg.Owner)
	self.npcName = npcChatInfo:GetName()
	self.npcIcon = npcChatInfo:GetIcon()
	self.subChannelId = chatCfg.ChatGroup > 0 and chatCfg.ChatGroup or chatCfg.NPCid
	self.atmosphereNpcInfo = chatPanelParams.atmosphereNpcInfo

	if self.atmosphereNpcInfo then
		self.isAtmosphereNpc = self.atmosphereNpcInfo.isAtmosphereNpc
	end
end

function M:GetPlayerSign()
	gChatUtils.GetPlayerSignature(gPlayerManager.infoLogin.bindData.pid, function (sign)
		self.playerSign = sign
	end)
end

function M:MakeChannelView(chatCfg)
	if chatCfg.ChatGroup and chatCfg.ChatGroup ~= 0 then
		return {
			topChannelId = 4,
			subChannelId = chatCfg.ChatGroup,
			cfg = chatCfg
		}
	else
		return {
			topChannelId = 2,
			subChannelId = chatCfg.NPCid,
			cfg = chatCfg
		}
	end
end

function M:NoticeIsNpcsPhone()
	local message = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89900986).Text, self.npcName)

	gDisplayMessageMgr:ShowMessageContent(message)
end

function M:GetLastMessage(chatCfg)
	local visited = {
		[chatCfg.Id] = true
	}

	while not table.isNilOrEmpty(chatCfg.NextMessage) do
		chatCfg = NPCChatConfig.GetConfig(chatCfg.NextMessage[1])

		if visited[chatCfg.Id] then
			print_error_without_stack("NPCChat 有循环引用, NPCChatConfig=" .. tostring(chatCfg.Id))

			return nil
		end

		visited[chatCfg.Id] = true
	end

	local chatItem = {
		NextChatId = 0,
		Timestamp = 0,
		ChatId = chatCfg.Id
	}
	local msg = C_NpcChatMessage.New(chatItem)

	return msg
end

function M:AddFakeChatChannelMessages(sub)
	for _, firstChatId in pairs(self.phoneCfg.ChatList) do
		local cfg = NPCChatConfig.GetConfig(firstChatId)

		if cfg.NPCid == sub or cfg.ChatGroup == sub then
			while cfg do
				if cfg.FakeChatAutoPlay then
					cfg = nil

					return
				end

				local chatItem = UX.Game.NpcChatItem.New()
				chatItem.ChatId = cfg.Id

				gNpcChatManager:AddNewNpcChatItem(chatItem)

				if cfg.NextMessage and #cfg.NextMessage > 0 and cfg.NextMessage[1] ~= 0 then
					cfg = NPCChatConfig.GetConfig(cfg.NextMessage[1])
				else
					cfg = nil
				end
			end
		end
	end
end

function M:Reset()
	self:_InitData()
	gChatManager:LoadChatChannelPlayerInfo()
end

function M:OpenFakePhoneChatPanel(params)
	local npcId = params.npcId
	local cfg = nil

	if params.isAtmosphereNpc then
		local itemId = ulong.tostring(params.destructibleInstanceId)
		local chatId = gRandomChatManager:GetChatId(npcId, itemId)
		cfg = gRandomChatManager:MakePhoneCfgByChatId(chatId)
	else
		local count = LTConfig.NPCChatNpcsPhoneConfig.count

		for i = 0, count - 1 do
			local cfgi = LTConfig.NPCChatNpcsPhoneConfig.LoadAt(i)

			if cfgi.Owner == npcId then
				cfg = cfgi

				break
			end
		end
	end

	if cfg == nil then
		print_error("没有找到对应的 NPC 手机配置")

		return
	end

	local chatId = cfg.ChatList[1]
	local chatCfg = LTConfig.NPCChatConfig.GetConfig(chatId)

	if chatCfg == nil then
		print_error("没有找到对应的 NPC 聊天配置! chatId", chatId, "params", params)

		return
	end

	local panelParams = {
		isNpcPhone = true,
		backMainCube = true,
		chatCfg = chatCfg,
		atmosphereNpcInfo = params,
		npcsPhoneCfg = cfg
	}

	if params.chatPanelParams then
		for k, v in pairs(params.chatPanelParams) do
			panelParams[k] = v
		end
	end

	self:SetInstanceId2Args(params.destructibleInstanceId, panelParams)

	self.currentShowArgs = panelParams

	if chatCfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		gChatUtils.OpenChatPanel(panelParams)
	elseif chatCfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Dialog then
		self:TriggerDialogAndOpenChatPanel(chatCfg)
	else
		print_error("@liulijun04 NPC 假手机还不支持的聊天类型！NPCChat 表 ID = " .. chatId .. ", 聊天类型 = " .. chatCfg.ChatType)
	end
end

function M:TriggerDialogAndOpenChatPanel(chatCfg)
	local chatId = chatCfg.Id
	local npcId = chatCfg.NPCid
	local gm = require("LuaGen/AutoGen/GmToGamePlayerDelegate")

	if gm == nil or gm.GmNpcChat == nil then
		print_error("GmToGamePlayerDelegate.GmNpcChat 不存在, 无法拉起短信")

		return
	end

	gm:GmNpcChat(chatId)
	print_warn("用 gm 指令拉起了短信")

	local function RequestNpcChatListCallback(err)
		if err ~= LTConfig.MessageConfig.Ok then
			return
		end

		local params = {
			backMainCube = true,
			chatCfg = chatCfg
		}

		gChatUtils.OpenChatPanel(params)
	end

	local isGroup = chatCfg.ChatGroup and chatCfg.ChatGroup ~= 0

	gDialogMainChatManager:RequestNpcChatList(npcId, chatId, isGroup, RequestNpcChatListCallback)
end

function M:ShowNpcFakeChat(cfgId, instanceId)
	local cfg = LTConfig.NPCChatConfig.GetConfig(cfgId)

	if cfg and cfg.ChatType == LTConfig.NPCChatConfig.ChatTypeType.Fake then
		self.uncompletedFakeChat = cfgId
		local panelParams = {
			chatCfg = cfg,
			atmosphereNpcInfo = {
				actionFalling = false,
				npcId = 0,
				isAtmosphereNpc = true,
				destructibleInstanceId = instanceId or 0
			},
			npcsPhoneCfg = gRandomChatManager:MakePhoneCfgByChatId(cfgId)
		}

		self:SetInstanceId2Args(instanceId, panelParams)

		self.currentShowArgs = panelParams

		gChatUtils.OpenChatPanel(panelParams)
	else
		print_error("找不到对应的配置 " .. cfgId)
	end
end

function M:ShowNpcFakeChatNextTime(cfgId)
	self.showNpcFakeChatNextTime = cfgId
end

function M:SetInstanceId2Args(instanceId, args)
	if instanceId == nil then
		return
	end

	self._instanceId2Args = self._instanceId2Args or {}
	local item = {
		id = instanceId,
		args = args
	}
	local cap = 10

	if #self._instanceId2Args == cap then
		self._instanceId2Args[self._instanceId2Args_pos] = args
		self._instanceId2Args_pos = self._instanceId2Args_pos % cap + 1
	else
		table.insert(self._instanceId2Args, item)

		self._instanceId2Args_pos = 1
	end
end

function M:GetInstanceId2Args(instanceId)
	if self._instanceId2Args then
		local v, _ = array.find_if(self._instanceId2Args, function (v)
			return v.id == instanceId
		end)

		return v and v.args
	end
end

function M:OnPanelVisibleChange()
	if gPlayerManager.infoLogin.bindData.pid == nil or self.uncompletedFakeCha == nil then
		return
	end

	Timer.New(function ()
		if (gBlackScreenManager.blackPanel == nil or gBlackScreenManager.blackPanel.state == 0) and not gTimelineManager.isTimelinePlaying and gPanelManager:VisibleModeAll() and self.uncompletedFakeChat then
			self:ShowNpcFakeChat(self.uncompletedFakeChat)
		end
	end, 0.1):Start()
end

function M.OnPanelShow(_, msg)
	local self = M

	if self.uncompletedFakeChat == nil then
		return
	end

	if not gClientUtils.CheckIsMainPhonePanelId(msg.panelId) then
		return
	end

	local data = gPanelManager.panelData[msg.panelId]
	local chatCfg = data and data.chatCfg

	if chatCfg and chatCfg.Id == self.uncompletedFakeChat then
		self.uncompletedFakeChat = nil
	end
end

gMessageManager:AddMessageListener(gEventConstants.PANEL_SHOW, M.OnPanelShow)

function M:CheckShowChatPanel(data)
	if gGmUtils and gGmUtils.stealPhoneMode == 1 then
		return false
	end

	local instanceId = data.destructibleInstanceId
	local store = gStoreManager:GetStoreGroup("NpcChattingToNpcPanelStore")

	if store.STATE_EnableOnce then
		self:SetInstanceId2Args(instanceId, self.currentShowArgs)

		return true
	end

	if self.showNpcFakeChatNextTime then
		self.showNpcFakeChatNextTime = nil

		self:ShowNpcFakeChat(self.showNpcFakeChatNextTime, instanceId)

		return true
	end

	if self.uncompletedFakeChat then
		self:ShowNpcFakeChat(self.uncompletedFakeChat, instanceId)

		return true
	end

	local lastArgs = self:GetInstanceId2Args(instanceId)

	if lastArgs then
		gChatUtils.OpenChatPanel(lastArgs)

		return true
	end

	local npcId = data.npcId
	local agent = LTConfig.AgentConfig.GetConfig(npcId)

	if npcId and agent then
		data.isAtmosphereNpc = true
		data.chatPanelParams = {
			isAtmosphereNpc = true,
			mainHomeType = -1
		}

		self:OpenFakePhoneChatPanel(data)

		return true
	end

	return false
end

gChatNpcsPhoneManager = M
