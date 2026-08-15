local ChatType = LTConfig.NPCChatConfig.ChatTypeType
C_NpcChatManager = DefClass("C_NpcChatManager", C_NpcChatManager)
local M = C_NpcChatManager

function M:ctor()
	self:oldCtor()
	self:Init_Channel()
	self:Init_Story()

	self.m_init = false
end

function M:oldCtor()
	self.currentNpcChatType = ChatType.Normal
	self.CHAT_HISTORY_AES_KEY = nil
	self.CHAT_HISTORY_AES_VECTOR = nil
	self.currentTopChannel = nil
	self.currentSubChannelId = nil
	self.checkSwitchShowEndTimer = nil
	self.LastTopChannel = nil
	self.LastSubChannel = nil
	self.playerInfoOver = false
	self.friendIsLoadOver = false
	self.isSceneLoading = true
	self.loadFriendHistory = false
	self.lastId = ulong.zero
	self.waitSceneLoadCallBack = {}
	self.groupInviteList = {}
	self.PZHeadInfoDict = {}
	self.pendingDialogData = nil
	self.rollToCfgId = nil
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.BEFORE_SWITCH_SCENE, self:CreateAction("OnBeforeSwitchScene"))

	self.CHAT_HISTORY_AES_KEY = gCS.IMManager.CHAT_HISTORY_AES_KEY

	gMessageManager:AddMessageListener(gEventConstants.LOADING_PANEL_CLOSED, self:CreateAction("OnLoadingFinished"))
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction("OnChangeMyUnit"))
	gMessageManager:AddMessageListener(gEventConstants.PLAYER_FIGHT_STATUS_CHANGE, self:CreateAction("OnPlayerFightStatusChange"))
	self:LoadClientChannel()

	self.friendIsLoadOver = false
	self.playerInfoOver = false
end

function M:SyncPlayerInfo(playerInfo)
	self:OnSyncPlayerInfo(playerInfo)

	self.m_init = true

	self:LoadChatChannelPlayerInfo()
	self:ClearUncompletedInvite()
end

function M:OnBeforeSwitchScene(switchType)
	self.isSceneLoading = true

	self:UpdateCurrentChannel(nil)

	self.rollToCfgId = nil

	if switchType == gSwitchSceneType.KickToLogin then
		self.m_init = false
		self.currentTopChannel = nil
		self.currentSubChannelId = nil
		self.playerInfoOver = false
		self.friendIsLoadOver = false
		self.loadFriendHistory = false
		self.lastId = 0
		self.waitSceneLoadCallBack = {}
		self.groupInviteList = {}
		self.pendingDialogData = nil

		gNpcChatManager:LoadClientChannel()
	end
end

function M:OnLoadingFinished(switchType)
	self.isSceneLoading = false

	while #self.waitSceneLoadCallBack > 0 do
		local cb = table.remove(self.waitSceneLoadCallBack)

		cb()
	end

	if gNpcChatUtils.CheckSwitchTimelineEnd() then
		gNpcChatManager:CheckUncompletedChatAndDialog()
	else
		local afterSwitchShowEnd = false

		if self.checkSwitchShowEndTimer then
			self.checkSwitchShowEndTimer:Stop()

			self.checkSwitchShowEndTimer = nil
		end

		self.checkSwitchShowEndTimer = Timer.New(function ()
			afterSwitchShowEnd = gNpcChatUtils.CheckSwitchTimelineEnd()

			if afterSwitchShowEnd then
				gNpcChatManager:CheckUncompletedChatAndDialog()
				self.checkSwitchShowEndTimer:Stop()

				self.checkSwitchShowEndTimer = nil
			end
		end, 1, -1):Start()
	end
end

function M:ClearNpcDialogChat(subId, isGroup)
	if isGroup then
		if self.m_npcGroupChatsDict[subId] and self.m_npcGroupChatsDict[subId].DialogChatListDict then
			self.m_npcGroupChatsDict[subId].DialogChatListDict = {}
		end
	elseif self.m_npcChatsDict[subId] and self.m_npcChatsDict[subId].DialogChatListDict then
		self.m_npcChatsDict[subId].DialogChatListDict = {}
	end
end

function M:SetHeadIcon(headRoot, pid, pzHeadInfo, systemIcon, npcGroupIcons, groupLimit)
	local isMe = pid and ulong.equals(pid, gPlayerManager.infoLogin.bindData.pid) or false

	if npcGroupIcons then
		gNpcChatUtils.ShowNpcGroupIcons(headRoot, npcGroupIcons, groupLimit)
	elseif systemIcon then
		gNpcChatUtils.ShowSystemIcon(headRoot, systemIcon)
	elseif pzHeadInfo then
		gNpcChatUtils.ShowPZHeadInfoHead(headRoot, pzHeadInfo, isMe)
	elseif pid then
		if isMe then
			gNpcChatUtils.ShowPZHeadInfoHead(headRoot, gPlayerManager.infoLogin.bindData.infoPzHeadInfo, isMe)
		elseif self.PZHeadInfoDict[pid] then
			gNpcChatUtils.ShowPZHeadInfoHead(headRoot, self.PZHeadInfoDict[pid], isMe)
		else
			gRpcUtils:SafeQueueAsk(gClientToAvatarDelegate, "GetSimplePlayerInfoByPidList", nil, {
				canCombine = true
			}, {
				pid
			}).Callback = function (err, datas)
				if err == LTConfig.MessageConfig.Ok and datas[1] then
					local headInfo = datas[1].PzHeadInfo
					self.PZHeadInfoDict[pid] = headInfo

					gNpcChatUtils.ShowPZHeadInfoHead(headRoot, headInfo, isMe)
				end
			end
		end
	end
end

function M:OnSyncNpcChatLeaveGameplay(npcId, gameplay)
	local gamePlayType = LTConfig.NPCChatGamePlayTypeConfig
	local multiNpcTidList = gNpcChatManager.groupInviteList

	Timer.New(function ()
		gClientUtils.CloseMainPhonePanel()

		if gameplay == gamePlayType.Restaurant or gameplay == gamePlayType.MaidHouse or gameplay == gamePlayType.FastFood or gameplay == gamePlayType.MaidTea then
			gMessageManager:SendMessage(gEventConstants.RESTAURANT_INVITE_NPC, {
				npcId = npcId,
				gameplayId = gameplay
			})
		elseif gameplay == gamePlayType.Cinema then
			gMessageManager:SendMessage(gEventConstants.CINEMA_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.Firework then
			gMessageManager:SendMessage(gEventConstants.FIREWORK_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.ClawMachine then
			gMessageManager:SendMessage(gEventConstants.CLAWMACHINE_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.LiveHouse then
			gMessageManager:SendMessage(gEventConstants.LIVEHOUSE_INVITE_NPC, npcId)
		elseif gameplay == gamePlayType.Mahjong then
			gMaJiangManager:AskInviteNpcFromChat(multiNpcTidList)
		elseif gameplay == gamePlayType.FerriswheelCity or gameplay == gamePlayType.FerriswheelPark then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnFerrisInviteNpc, {
				isSkip = false,
				npcId = npcId
			})
		elseif gameplay == gamePlayType.Sunbath then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnSunbathInviteNpc, {
				isSkip = false,
				npcId = npcId
			})
		elseif gameplay == gamePlayType.Dart then
			gMessageManager:SendMessage(gEventConstants.DO_INVITE_NPC_DART_GAME, npcId)
		elseif gameplay == gamePlayType.Dance808 then
			local agentId = gClientUtils.GetNpcCultivationAgentId(npcId)
			local npcCultivationCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
			local newAgentId = npcCultivationCfg.BengdiNpcid and npcCultivationCfg.BengdiNpcid > 0 and npcCultivationCfg.BengdiNpcid or agentId

			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnInviteNpcFinish, {
				npcId = npcId,
				agentId = newAgentId
			})
		elseif gameplay == gamePlayType.Party then
			gMessageManager:SendMessage(gEventConstants.ON_PARTY_INVITE_SUCCESS, multiNpcTidList)
		end
	end, LTConfig.NPCChatConfig.InviteWaitTime):Start()
end

function M:GetChatAesVector(pid)
	local str = ulong.tostring(pid)
	local length = string.len(str)

	if length > 16 then
		return string.sub(str, length - 16 + 1)
	elseif length == 16 then
		return str
	end

	return string.rep("0", 16 - length) .. str
end

function M:OnPanelClose(eventId, panelId)
	if gLuaDataManager.gameStage == gGFConstant.GameStage.Loading then
		return
	end

	self.checkPanelCloseCo = coroutine.stop(self.checkPanelCloseCo)
	self.checkPanelCloseCo = coroutine.start(function ()
		coroutine.step()
		gDialogMainChatManager:OnPanelVisibleChange()
		gNpcChatNpcsPhoneManager:OnPanelVisibleChange()
	end)
end

function M:LoadChatChannelPlayerInfo()
	self.CHAT_HISTORY_AES_VECTOR = self:GetChatAesVector(gPlayerManager.infoLogin.bindData.pid)

	if self.playerInfoOver then
		return
	end

	self.playerInfoOver = true

	self:TryLoadNpcChatMsgList()
end

function M:OnChangeMyUnit()
	if not self.m_init then
		return
	end

	self:TryLoadNpcChatMsgList()

	if self.onChangeMyUnitTimer then
		self.onChangeMyUnitTimer:Stop()

		self.onChangeMyUnitTimer = nil
	end

	self.onChangeMyUnitTimer = Timer.New(function ()
		local uncompletedNormalChats = self:GetUncompletedNormalChatList()

		self:CheckAndNotifyUncompletedNormalChats(uncompletedNormalChats)
		gNpcChatManager:CheckUncompletedChatAndDialog()
	end, 0.1):Start()
end

function M:TryLoadNpcChatMsgList()
	self:LoadNpcChatMsgList()
end

function M:NextId()
	self.lastId = ulong.add(self.lastId, 1)

	return self.lastId
end

function M:UpdateCurrentChannel(topChannelId, subChannelId, cfg)
	if topChannelId and subChannelId == nil then
		local topChannelInfo = NpcChatTabs.topChannelInfo

		if topChannelInfo[topChannelId] == nil then
			return
		end

		if topChannelInfo[topChannelId].redirectChannel ~= 0 then
			topChannelId = topChannelInfo[topChannelId].redirectChannel
		end
	end

	local top, sub = self:GetCurrentChannel()

	if top == topChannelId and sub == subChannelId then
		return
	end

	if topChannelId == nil then
		self.currentTopChannel = nil
		self.currentSubChannelId = nil
	elseif gNpcChatManager:GetChannel(topChannelId, subChannelId) then
		self.currentTopChannel = topChannelId
		self.currentSubChannelId = subChannelId

		self:RecordCurrentChannel()
	else
		print_error("UpdateCurrentChannel Error 没有该频道，不能更新当前频道", topChannelId, subChannelId)

		return
	end

	gMessageManager:SendMessage(gEventConstants.NPC_CHAT_CHANNEL_CHANGED, {
		topChannelId = topChannelId,
		subChannelId = subChannelId,
		cfg = cfg
	})
end

function M:RecordCurrentChannel()
	self.LastTopChannel = self.currentTopChannel
	self.LastSubChannel = self.currentSubChannelId
end

function M:GetRecordChannel()
	return self.LastTopChannel, self.LastSubChannels
end

function M:IsCurrentChannel(topChannelId, subChannelId)
	return topChannelId == self.currentTopChannel and subChannelId == self.currentSubChannelId
end

function M:GetCurrentChannel()
	return self.currentTopChannel, self.currentSubChannelId
end

function M:CheckFightState()
	return gCS.MyPlayerManager.PlayerUnit and gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS)
end

function M:SavePendingDialog(data)
	self.pendingDialogData = data
end

function M:TryShowPendingDialog()
	if self.pendingDialogData then
		local data = self.pendingDialogData
		self.pendingDialogData = nil

		self:ShowNpcChatDialogPanel(data.topChannelId, data.subChannelId, data.chatCfg)
	end
end

function M:OnPlayerFightStatusChange(_, isInFight)
	if isInFight then
		if gNpcChatUtils.IsChatPanelShowing() then
			gClientUtils.CloseMainPhonePanel()
		end
	else
		self:TryShowPendingDialog()
	end
end
