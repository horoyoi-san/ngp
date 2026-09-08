-- Original chunk: @Lua\LuaFiles\LX6\Manager\NpcChat\NpcChatManager.lua
-- Decompiled from: 00302_NpcChatManager.lua_77ece3d7f45b.luajit

local ChatType = LTConfig.NPCChatConfig.ChatTypeType
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
C_NpcChatManager = DefClass("C_NpcChatManager", C_NpcChatManager)
local M = C_NpcChatManager

M.ctor = function(self)
	self.oldCtor(self)
	self.Init_Channel(self)
	self.Init_Story(self)

	self.m_init = false
end

M.oldCtor = function(self)
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
	self.checkUncompletedChatTimer = nil
	self.lastSpiritTemplateId = nil
	self.pendingPopupKeys = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.L50_BEFORE_SWITCH_SCENE, self:CreateAction("Event_BeforeSwitchScene"))

	self.CHAT_HISTORY_AES_KEY = gCS.IMManager.CHAT_HISTORY_AES_KEY

	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, self:CreateAction("OnPanelClose"))
	gMessageManager:AddMessageListener(gEventConstants.SYNC_CURRENT_SPIRIT, self:CreateAction("OnChangeMyUnit"))
	gMessageManager:AddMessageListener(gEventConstants.PLAYER_FIGHT_STATUS_CHANGE, self:CreateAction("OnPlayerFightStatusChange"))
	self:LoadClientChannel()

	self.friendIsLoadOver = false
	self.playerInfoOver = false
	self.pendingPopupKeys = {}
end

M.SyncPlayerInfo = function(self, playerInfo)
	self.OnSyncPlayerInfo(self, playerInfo)

	self.m_init = true

	self.LoadChatChannelPlayerInfo(self)
	self.ClearUncompletedInvite(self)
end

M.Event_BeforeSwitchScene = function(self, _, switchSceneEventParams)
	local switchType = switchSceneEventParams.switchSceneType

	self.OnBeforeSwitchScene(self, switchType)
end

M.OnBeforeSwitchScene = function(self, switchType)
	self.isSceneLoading = true

	self.UpdateCurrentChannel(self, nil)

	self.rollToCfgId = nil
	self.openingChatPanelLock = false

	if switchType ~= gSwitchSceneType.KickToLogin then
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
		self.lastSpiritTemplateId = nil
		self.pendingPopupKeys = {}
		self.needClickChatIds = {}
		self.clickedChatIds = {}

		gNpcChatManager:LoadClientChannel()
	elseif switchType ~= gSwitchSceneType.Reconnect then
		self.lastSpiritTemplateId = nil
		self.pendingPopupKeys = {}
	elseif switchType ~= gSwitchSceneType.SameImage then
		self.playerInfoOver = false
	end
end

M.OnLoadingFinished = function(self, switchType)
	self.isSceneLoading = false

	while #self.waitSceneLoadCallBack <= 0 do
		local cb = table.remove(self.waitSceneLoadCallBack)

		cb()
	end

	if gNpcChatUtils.CheckSwitchTimelineEnd() then
		self.ScheduleCheckUncompletedChatAndDialog(self)
	else
		local afterSwitchShowEnd = false

		if self.checkSwitchShowEndTimer then
			self.checkSwitchShowEndTimer:Stop()

			self.checkSwitchShowEndTimer = nil
		end

		self.checkSwitchShowEndTimer = Timer.New(function ()
			afterSwitchShowEnd = gNpcChatUtils.CheckSwitchTimelineEnd()

			if afterSwitchShowEnd then
				self:ScheduleCheckUncompletedChatAndDialog()
				self.checkSwitchShowEndTimer:Stop()

				self.checkSwitchShowEndTimer = nil
			end
		end, 1, -1):Start()
	end
end

M.ClearNpcDialogChat = function(self, subId, isGroup)
	if isGroup then
		if self.m_npcGroupChatsDict[subId] and self.m_npcGroupChatsDict[subId].DialogChatListDict then
			self.m_npcGroupChatsDict[subId].DialogChatListDict = {}
		end
	elseif self.m_npcChatsDict[subId] and self.m_npcChatsDict[subId].DialogChatListDict then
		self.m_npcChatsDict[subId].DialogChatListDict = {}
	end
end

M.SetHeadIcon = function(self, headRoot, pid, pzHeadInfo, systemIcon, npcGroupIcons, groupLimit)
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
			slot8 = gRpcUtils

			slot8:SafeQueueAsk(gClientToAvatarDelegate, "GetSimplePlayerInfoByPidList", nil, {
				["P[\\xc0\\x9e\\x8b\\xba\r\\xc7\\xed"] = true
			}, {
				pid
			}).Callback = function (err, datas)
				if err ~= LTConfig.MessageConfig.Ok and datas[1] then
					local headInfo = datas[1].PzHeadInfo
					self.PZHeadInfoDict[pid] = headInfo

					gNpcChatUtils.ShowPZHeadInfoHead(headRoot, headInfo, isMe)
				end
			end
		end
	end
end

M.OnSyncNpcChatLeaveGameplay = function(self, npcId, gameplay)
	local gamePlayType = GamePlayTypeConfig
	local multiNpcTidList = gNpcChatManager.groupInviteList

	Timer.New(function ()
		gClientUtils.CloseMainPhonePanel()

		if gRestaurantManager:IsRestaurantGameplayType(gameplay) then
			gRestaurantManager:InviteClientNpc(npcId, gameplay)
		elseif gameplay ~= gamePlayType.Cinema then
			gMessageManager:SendMessage(gEventConstants.CINEMA_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.Firework then
			gMessageManager:SendMessage(gEventConstants.FIREWORK_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.ClawMachine then
			gMessageManager:SendMessage(gEventConstants.CLAWMACHINE_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.LiveHouse then
			gMessageManager:SendMessage(gEventConstants.LIVEHOUSE_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.KTV then
			gMessageManager:SendMessage(gEventConstants.KTV_INVITE_NPC, npcId)
		elseif gameplay ~= gamePlayType.Mahjong or gameplay ~= gamePlayType.ReachMahjong then
			gMaJiangManager:AskInviteNpcFromChat(multiNpcTidList, gameplay)
		elseif gameplay ~= gamePlayType.FerriswheelCity or gameplay ~= gamePlayType.FerriswheelPark then
			gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnFerrisInviteNpc, {
				["[\\xa2\\x85\\x8aQ"] = false,
				npcId = npcId
			})
			L50.L50App.Scene.FerrisMgr:OnInviteSuccess(npcId, false)
		elseif gameplay ~= gamePlayType.Sunbath then
			gSunbathManager:ReleaseEventSignal({
				["[\\xa2\\x85\\x8aQ"] = false,
				npcId = npcId
			})
		elseif gameplay ~= gamePlayType.Dart then
			gMessageManager:SendMessage(gEventConstants.DO_INVITE_NPC_DART_GAME, npcId)
		elseif gameplay ~= gamePlayType.Dance808 then
			gBengdiActionManager:StartInviteAction(npcId, gamePlayType.Dance808)
		elseif gameplay ~= gamePlayType.Party or gameplay ~= gamePlayType.PartyGuide or gameplay ~= gamePlayType.DanceParty then
			gPartyManager:StartSingleParty(gPartyManager.singlePartyId, multiNpcTidList)
		elseif gameplay ~= gamePlayType.Bowling then
			gBowlingGameManager:OnNpcInvited(npcId)
		elseif gameplay ~= gamePlayType.Rowboat then
			L50.Spoon.RowingGamePlayModule.Instance:AskBuyRowBoatTicketDouble(npcId)
		end
	end, LTConfig.NPCChatConfig.InviteWaitTime):Start()
end

M.GetChatAesVector = function(self, pid)
	local str = ulong.tostring(pid)
	local length = string.len(str)

	if length <= 16 then
		return string.sub(str, length - 16 + 1)
	elseif length ~= 16 then
		return str
	end

	return string.rep("0", 16 - length) .. str
end

M.OnPanelClose = function(self, eventId, panelId)
	if panelId ~= gPanelId.PVP_LOADING_PANEL then
		self.OnLoadingFinished(self)
	end

	if gLuaDataManager.gameStage ~= gGFConstant.GameStage.Loading then
		return
	end

	self.checkPanelCloseCo = coroutine.stop(self.checkPanelCloseCo)
	self.checkPanelCloseCo = coroutine.start(function ()
		coroutine.step()
		gDialogMainChatManager:OnPanelVisibleChange()
		gNpcChatNpcsPhoneManager:OnPanelVisibleChange()
	end)
end

M.LoadChatChannelPlayerInfo = function(self)
	self.CHAT_HISTORY_AES_VECTOR = self.GetChatAesVector(self, gPlayerManager.infoLogin.bindData.pid)

	if self.playerInfoOver then
		return
	end

	self.playerInfoOver = true

	self.TryLoadNpcChatMsgList(self)
end

M.OnChangeMyUnit = function(self, _, templateId)
	if not self.m_init then
		return
	end

	if templateId and templateId ~= self.lastSpiritTemplateId then
		return
	end

	self.lastSpiritTemplateId = templateId

	self.TryLoadNpcChatMsgList(self)

	if self.onChangeMyUnitTimer then
		self.onChangeMyUnitTimer:Stop()

		self.onChangeMyUnitTimer = nil
	end

	self.onChangeMyUnitTimer = Timer.New(function ()
		local uncompletedNormalChats = self:GetUncompletedNormalChatList()

		self:CheckAndNotifyUncompletedNormalChats(uncompletedNormalChats)
		self:ScheduleCheckUncompletedChatAndDialog()
	end, 0.1):Start()
end

M.TryLoadNpcChatMsgList = function(self)
	self.LoadNpcChatMsgList(self)
end

M.ScheduleCheckUncompletedChatAndDialog = function(self)
	if self.checkUncompletedChatTimer then
		self.checkUncompletedChatTimer:Stop()

		self.checkUncompletedChatTimer = nil
	end

	self.checkUncompletedChatTimer = Timer.New(function ()
		self:CheckUncompletedChatAndDialog()

		self.checkUncompletedChatTimer = nil
	end, 0.2):Start()
end

M.NextId = function(self)
	self.lastId = ulong.add(self.lastId, 1)

	return self.lastId
end

M.UpdateCurrentChannel = function(self, topChannelId, subChannelId, cfg)
	if topChannelId and subChannelId ~= nil then
		local topChannelInfo = NpcChatTabs.topChannelInfo

		if topChannelInfo[topChannelId] ~= nil then
			return
		end

		if topChannelInfo[topChannelId].redirectChannel == 0 then
			topChannelId = topChannelInfo[topChannelId].redirectChannel
		end
	end

	local top, sub = self.GetCurrentChannel(self)

	if top ~= topChannelId and sub ~= subChannelId then
		return
	end

	if topChannelId ~= nil then
		self.currentTopChannel = nil
		self.currentSubChannelId = nil
	elseif gNpcChatManager:GetChannel(topChannelId, subChannelId) then
		self.currentTopChannel = topChannelId
		self.currentSubChannelId = subChannelId

		self.RecordCurrentChannel(self)
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

M.RecordCurrentChannel = function(self)
	self.LastTopChannel = self.currentTopChannel
	self.LastSubChannel = self.currentSubChannelId
end

M.GetRecordChannel = function(self)
	return self.LastTopChannel, self.LastSubChannels
end

M.IsCurrentChannel = function(self, topChannelId, subChannelId)
	return topChannelId ~= self.currentTopChannel and subChannelId ~= self.currentSubChannelId
end

M.GetCurrentChannel = function(self)
	return self.currentTopChannel, self.currentSubChannelId
end

M.CheckFightState = function(self)
	return gCS.MyPlayerManager.PlayerUnit and gCS.UnitStateMgr:HasState(gCS.MyPlayerManager.PlayerUnit, LTConfig.UnitStateConfig.FightS)
end

M.SavePendingDialog = function(self, data)
	self.pendingDialogData = data
end

M.TryShowPendingDialog = function(self)
	if self.pendingDialogData then
		local data = self.pendingDialogData
		self.pendingDialogData = nil

		self._LockClosePhoneForOpeningChat(self)

		if not self.ShowNpcChatDialogPanel(self, data.topChannelId, data.subChannelId, data.chatCfg) then
			self._UnlockClosePhoneForOpeningChat(self)
		end
	end
end

M.OnPlayerFightStatusChange = function(self, _, isInFight)
	if isInFight then
		if gNpcChatUtils.IsChatPanelShowing() then
			gClientUtils.CloseMainPhonePanel()
		end
	else
		self.TryShowPendingDialog(self)
	end
end
