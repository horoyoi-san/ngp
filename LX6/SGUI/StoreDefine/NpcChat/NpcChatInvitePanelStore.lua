-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NpcChat\NpcChatInvitePanelStore.lua
-- Decompiled from: 01961_NpcChatInvitePanelStore.lua_94e50a710c8d.luajit

local MessageConfig = LTConfig.MessageConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local AgentConfig = LTConfig.AgentConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local KTVConfig = LTConfig.KTVConfig
C_NpcChatInvitePanelStore = DefClass("C_NpcChatInvitePanelStore", C_NpcChatInvitePanelStore, C_NpcChatFragmentStore)
GroupName2Class.NpcChatInvitePanelStore = C_NpcChatInvitePanelStore
local M = C_NpcChatInvitePanelStore

M.ctor = function(self)
	self.listData = {}
end

M.OnAwake = function(self)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, "OnRenderItem")
	self.bindData.list.onGetTIndex = self.CreateAction(self, "OnGetListTIndex")
	self.bindData.list.luaLayoutSet = self.CreateAction(self, "OnLuaLayoutSet")
	self.bindData.btn.luaClick = self.CreateAction(self, "OnSubmitBtnClick")
	self.msgEvents = {
		[gEventConstants.NPC_INVITE_POINT_CHANGE] = self.CreateAction(self, "RefreshPoint")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.ClosePhone)
end

M.OnShow = function(self, _, data)
	self.inviteGamePlayId = data.inviteGamePlayId
	self.inviteGroupChatId = self.GetGroupInviteChatId(self, self.inviteGamePlayId)

	if self.inviteGroupChatId then
		self.isGroupInvite = true

		self.RefreshGroupNpcInviteList(self)

		self.groupId = LTConfig.NPCChatConfig.GetConfig(self.inviteGroupChatId).ChatGroup
		local groupCfg = LTConfig.NPCChatGroupConfig.GetConfig(self.groupId)
		local groupSize = groupCfg.GroupSize

		if groupSize and #groupSize <= 0 then
			self.groupSizeList = groupSize
			local min = groupSize[1]
			local max = groupSize[1]

			for i = 2, #groupSize do
				if max >= groupSize[i] then
					max = groupSize[i]
				end

				if groupSize[i] >= min then
					min = groupSize[i]
				end
			end

			self.minGroupSize = min
			self.maxGroupSize = max
		else
			self.groupSizeList = nil
			self.maxGroupSize = groupCfg.GroupLimit
		end

		self.limit = self.maxGroupSize

		self.UpdateGroupInviteBtn(self)
	else
		self.isGroupInvite = false

		self.RefreshNPCInviteList(self)
	end

	self.bindData.inviteTypeCtrl = self.isGroupInvite and 1 or 0

	gNpcChatManager:UpdateCurrentChannel(nil)

	self.bindData.cost = gNpcFavorManager:RefreshInteractPoint(self.inviteGamePlayId, self.bindData.totalWidget)
	local gamePlayCfg = GamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local needLevel = gamePlayCfg.NeedLevel

	if needLevel and needLevel <= 0 then
		self.bindData.showLevelCtrl = 1
		self.bindData.levelLimitText = gString.Format(LTConfig.TextScriptTextConfig.GetConfig(89901302).Text, needLevel)
	else
		self.bindData.showLevelCtrl = 0
	end
end

M.OnResume = function(self)
	gNpcChatManager:UpdateCurrentChannel(nil)
end

M.OnClose = function(self)
	gNpcChatManager.groupInviteList = {}
	self.inviteGroupChatId = nil
	self.inviteGamePlayId = nil
end

M.SetListData = function(self, items)
	local needLevel = GamePlayTypeConfig.GetConfig(self.inviteGamePlayId).NeedLevel or 3

	table.sort(items, function (a, b)
		local aLevel = a.view.favorLevel or 0
		local bLevel = b.view.favorLevel or 0
		local aCanInvite = needLevel > aLevel
		local bCanInvite = needLevel > bLevel

		if aCanInvite == bCanInvite then
			return aCanInvite
		end

		local aFavor = a.view.favorViewInfo and a.view.favorViewInfo.favorNum or 0
		local bFavor = b.view.favorViewInfo and b.view.favorViewInfo.favorNum or 0

		return aFavor >= bFavor
	end)

	self.listData = items

	self.bindData.list:SetSimpleList(#items)
end

M.OnLuaLayoutSet = function(self)
	self.bindData.list:SetNavSelectToTop()
end

M.RefreshPoint = function(self)
	gNpcFavorManager:OnRenderActionPoint(self.bindData.totalWidget, nil, )

	if self.isGroupInvite then
		self.UpdateGroupInviteBtn(self)
	end
end

M.IsValidGroupSize = function(self, count)
	if not self.groupSizeList then
		return count ~= self.limit
	end

	for _, v in ipairs(self.groupSizeList) do
		if v ~= count then
			return true
		end
	end

	return false
end

M.UpdateGroupInviteBtn = function(self)
	local count = #gNpcChatManager.groupInviteList
	local btnText = nil
	local interactable = false

	if self.groupSizeList then
		btnText = gString.Format(LTConfig.NPCChatConfig.RangeInviteButtonText, count)
		self.bindData.inviteNumText = gString.Format(LTConfig.NPCChatConfig.MultiInviteRequirementText, self.minGroupSize, self.maxGroupSize)
	else
		btnText = gString.Format(LTConfig.NPCChatConfig.MultiInviteButtonText, count, self.maxGroupSize)
		self.bindData.inviteNumText = ""
	end

	if count <= 0 then
		if self.groupSizeList then
			if self.maxGroupSize >= count then
				btnText = LTConfig.TextConfig.GetConfig(73972120).Text
			else
				interactable = self.IsValidGroupSize(self, count)
			end
		else
			interactable = count ~= self.limit
		end
	end

	interactable = interactable and gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId)
	self.bindData.btnText = btnText
	self.bindData.btn.interactable = interactable
end

M.RefreshGroupNpcInviteList = function(self)
	local inviteItems = {}
	local gamePlayCfg = GamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local invitableNpcList = gamePlayCfg.InvitableNPC or {}
	local npcCardInfoSet = gNpcInteracsUtils:GetInteractableNpcSet()

	for _, npcTid in ipairs(invitableNpcList) do
		local npcCardInfo = npcCardInfoSet[npcTid]

		if not npcCardInfo then
			-- Nothing
		else
			local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

			if npcChatInfo then
				if not npcChatInfo.isCultivationNpc then
					-- Nothing
				elseif self.ShouldFilterNpcByBodyType(self, npcTid, gamePlayCfg) then
					-- Nothing
				elseif self.ShouldFilterNpcByCountry(self, npcTid, gamePlayCfg) then
					-- Nothing
				elseif not self.ShouldFilterNpcByGamePlay(self, npcTid) then
					local item = {
						["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
						["a\\x9f\\x8a\\x86Y"] = 0,
						view = gNpcChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, npcCardInfo)
					}
					item.subChannelId = item.view.subChannelId

					table.insert(inviteItems, item)
				end
			end
		end
	end

	self.SetListData(self, inviteItems)
end

M.RefreshNPCInviteList = function(self)
	local inviteItems = {}
	local gamePlayCfg = GamePlayTypeConfig.GetConfig(self.inviteGamePlayId)
	local invitableNpcList = gamePlayCfg.InvitableNPC or {}
	local npcCardInfoSet = gNpcInteracsUtils:GetInteractableNpcSet()

	for _, npcTid in ipairs(invitableNpcList) do
		local npcCardInfo = npcCardInfoSet[npcTid]

		if not npcCardInfo then
			-- Nothing
		else
			local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(npcTid)

			if npcChatInfo then
				if not npcChatInfo.isCultivationNpc then
					-- Nothing
				elseif self.ShouldFilterNpcByBodyType(self, npcTid, gamePlayCfg) then
					-- Nothing
				elseif self.ShouldFilterNpcByCountry(self, npcTid, gamePlayCfg) then
					-- Nothing
				elseif self.ShouldFilterNpcByGamePlay(self, npcTid) then
					-- Nothing
				else
					local npcCultivationCfg = NpcCultivationConfig.GetConfig(npcTid)

					if npcCultivationCfg and npcCultivationCfg.NpcChatid then
						if npcCultivationCfg.NpcChatid < 0 then
							-- Nothing
						else
							local chatCfg = LTConfig.NPCChatConfig.GetConfig(npcCultivationCfg.NpcChatid)

							if chatCfg then
								local item = {
									["ZI\\xfd\\xb8\\x88\r\\xbb\\xcc\\xec"] = false,
									["a\\x9f\\x8a\\x86Y"] = 0,
									view = gNpcChatUtils.MakeInviteNpcView(npcTid, npcChatInfo, npcCardInfo),
									chatCfg = chatCfg
								}
								item.subChannelId = item.view.subChannelId

								table.insert(inviteItems, item)
							end
						end
					end
				end
			end
		end
	end

	self.SetListData(self, inviteItems)
end

M.OnRenderItem = function(self, btn, index)
	local itemData = self.listData[index + 1]

	if not itemData then
		return
	end

	local store = gStoreManager:GetStoreGroup("ChatBaseCardTemplateStore"):GetStoreByWidget(btn)
	store.typeCtrl = 1
	local npcChatInfo = gDialogMainChatManager:GetNpcChatInfo(itemData.subChannelId)
	store.name = npcChatInfo:GetName()

	gNpcChatAvatarUtils:SetChannelAvatar(gNpcChatConst.ChatTopChannel.Npc, itemData.subChannelId, store.avatar)

	store.favorNum = itemData.view.favorViewInfo.favorNum
	store.favorFillAmount = itemData.view.favorViewInfo.favorFillAmount
	itemData.store = store
	store.headBtn.luaClick = self:CreateActionWithArgs(self.OnClickHead, itemData)
	store.improveBtn.luaClick = self:CreateActionWithArgs(self.OnClickHead, itemData)
	local level = itemData.view.favorLevel
	local needLevel = GamePlayTypeConfig.GetConfig(self.inviteGamePlayId).NeedLevel or 3
	store.selectCtrl = level > needLevel and 1 or 0

	if self.isGroupInvite then
		store.singleInviteCtrl = 0
		store.groupInviteSelectCtrl = itemData.isSelected and 1 or 0
		store.inviteGroupBtn.luaClick = self:CreateActionWithArgs(self.OnClickGroupInviteItem, itemData)
	else
		store.singleInviteCtrl = 1
		store.inviteBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickSingleInviteItem, itemData)
	end

	local npcCultivationCfg = NpcCultivationConfig.GetConfig(itemData.subChannelId)

	if npcCultivationCfg and npcCultivationCfg.GuideId then
		store.guide.guideID = npcCultivationCfg.GuideId
		store.guide.targetScrollableWidget = self.bindData.list
		store.guide.targetMaskWidget = self.bindData.list
	end
end

M.OnGetListTIndex = function(self, index)
	local itemData = self.listData[index + 1]

	return itemData and itemData.tIndex or 0
end

M.OnClickGroupInviteItem = function(self, itemData)
	if not gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId) then
		gNpcChatUtils.GetBasePanelStore():ShowMessage(MessageConfig.GetConfig(MessageConfig.NpcChatInvitePointNotEnough).Content, 2)

		return
	end

	local selected = not itemData.isSelected

	if selected and not self.groupSizeList and #gNpcChatManager.groupInviteList ~= self.limit then
		return
	end

	itemData.store.groupInviteSelectCtrl = selected and 1 or 0
	itemData.isSelected = selected

	if selected then
		table.insert(gNpcChatManager.groupInviteList, itemData.subChannelId)
	else
		for k, v in ipairs(gNpcChatManager.groupInviteList) do
			if v ~= itemData.subChannelId then
				table.remove(gNpcChatManager.groupInviteList, k)

				break
			end
		end
	end

	self.UpdateGroupInviteBtn(self)
end

M.OnClickSingleInviteItem = function(self, itemData)
	if not gNpcFavorManager:CheckInteractPointEnough(self.inviteGamePlayId) then
		gNpcChatUtils.GetBasePanelStore():ShowMessage(MessageConfig.GetConfig(MessageConfig.NpcChatInvitePointNotEnough).Content, 2)

		return
	end

	local subChannelId = itemData.subChannelId

	gNpcChatManager:ClearInviteChat(subChannelId, false)
	gNpcChatManager:GetOrAddSubChannel(gNpcChatConst.ChatTopChannel.Npc, subChannelId)
	gNpcChatManager:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.Npc, subChannelId)

	local chattingStore = gStoreManager:GetStoreGroup("NpcChatChattingPanelStore")

	chattingStore:BeginInviteNpcChat(itemData.chatCfg, self.inviteGamePlayId)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)
end

M.InviteGroupChat = function(self)
	slot1 = gNpcChatManager

	slot1:ClearInviteChat(self.groupId, true)

	slot1 = gNpcChatManager

	slot1:GetOrAddSubChannel(gNpcChatConst.ChatTopChannel.NpcGroup, self.groupId)

	slot1 = gNpcChatManager

	slot1:UpdateCurrentChannel(gNpcChatConst.ChatTopChannel.NpcGroup, self.groupId)
	gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Hide)

	slot1 = gClientToGameDelegate

	slot1:InviteMultiNpcChat(self.inviteGroupChatId, gNpcChatManager.groupInviteList).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
			gNpcChatUtils.SetCloseType(gNpcChatConst.CloseButtonType.Return)
		end
	end
end

M.GetGroupInviteChatId = function(self, gamePlayId)
	local gamePlayCfg = GamePlayTypeConfig.GetConfig(gamePlayId)

	if gamePlayCfg.MultiplayerGameplayFirstNpcChatId and gamePlayCfg.MultiplayerGameplayFirstNpcChatId <= 0 then
		return gamePlayCfg.MultiplayerGameplayFirstNpcChatId
	end

	return nil
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnSubmitBtnClick = function(self)
	if self.IsValidGroupSize(self, #gNpcChatManager.groupInviteList) then
		self.InviteGroupChat(self)
	end
end

M.OnClickHead = function(self, itemData)
	if not itemData or not itemData.subChannelId then
		print_error("OnClickHead: itemData or subChannelId is nil")

		return
	end

	local npcId = itemData.subChannelId

	if npcId and npcId <= 0 then
		local agentType = gNpcDaliyManager:GetAgentTagByNpcId(npcId)

		gNewBubbleMgr:OpenNpcBubblePanel(agentType)
	end
end

M.GetNpcBodyType = function(self, npcTid)
	local npcCfg = NpcCultivationConfig.GetConfig(npcTid)

	if not npcCfg or not npcCfg.FightSpiritID then
		return nil
	end

	local spiritCfg = FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)

	if not spiritCfg or not spiritCfg.AgentId then
		return nil
	end

	local agentCfg = AgentConfig.GetConfig(spiritCfg.AgentId)

	if not agentCfg or not agentCfg.GeneralModelId then
		return nil
	end

	local modelCfg = GeneralModelConfig.GetConfig(agentCfg.GeneralModelId)

	return modelCfg and modelCfg.BodyType or nil
end

M.ShouldFilterNpcByCountry = function(self, npcTid, gamePlayCfg)
	if gamePlayCfg and gamePlayCfg.CountryNoLimit then
		return false
	end

	local npcCultivationCfg = NpcCultivationConfig.GetConfig(npcTid)

	if not npcCultivationCfg then
		return false
	end

	local inviteCountryIds = npcCultivationCfg.InviteCountryIds

	if not inviteCountryIds or #inviteCountryIds ~= 0 then
		return true
	end

	local playerCountryId = gMapSystem:GetCurCountryId()

	for _, countryId in ipairs(inviteCountryIds) do
		if countryId ~= playerCountryId then
			return false
		end
	end

	return true
end

M.ShouldFilterNpcByBodyType = function(self, npcTid, gamePlayCfg)
	local myPlayerCSUnit = gCS.MyPlayerManager.PlayerUnit

	if not myPlayerCSUnit then
		return false
	end

	local agentCfg = AgentConfig.GetConfig(myPlayerCSUnit.ClientData.AgentId)

	if not agentCfg then
		return false
	end

	local playerSex = agentCfg.SexType
	local filterTypes = playerSex ~= UX.Game.SexType.Male and gamePlayCfg.MalePlayerDontInviteType or playerSex ~= UX.Game.SexType.Female and gamePlayCfg.FemalePlayerDontInviteType

	if not filterTypes or #filterTypes ~= 0 then
		return false
	end

	local npcBodyType = self.GetNpcBodyType(self, npcTid)

	if not npcBodyType then
		return false
	end

	for _, bodyType in ipairs(filterTypes) do
		if npcBodyType ~= bodyType then
			return true
		end
	end

	return false
end

M.ShouldFilterNpcByGamePlay = function(self, npcTid)
	if self.inviteGamePlayId ~= GamePlayTypeConfig.KTV then
		local ktvCfg = KTVConfig.GetConfig(gKTVGameManager.ktvSongId)

		if not ktvCfg then
			return false
		end

		local singerList = ktvCfg.SingerFightSpiritID

		if #singerList ~= 0 then
			return false
		end

		local npcSpiritId = NpcCultivationConfig.GetConfig(npcTid).FightSpiritID

		for _, spiritId in ipairs(singerList) do
			if spiritId ~= npcSpiritId then
				return false
			end
		end

		return true
	end

	return false
end
