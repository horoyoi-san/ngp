local MessageConfig = LTConfig.MessageConfig
local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local GeneralModelConfig = LTConfig.GeneralModelConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local PoiGameDartNpcConfig = LTConfig.PoiGameDartNpcConfig
local NPCChatGamePlayTypeConfig = LTConfig.NPCChatGamePlayTypeConfig
C_LivehouseSelectPanelStore = DefClass("C_LivehouseSelectPanelStore", C_LivehouseSelectPanelStore, C_StoreGroup)
GroupName2Class.LivehouseSelectPanelStore = C_LivehouseSelectPanelStore
local M = C_LivehouseSelectPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.bindData.backBtn.luaClick = self:CreateAction(self.OnBackBtnClick)
	self.bindData.playBtn.luaClick = self:CreateAction(self.OnPlayBtn)
	self.bindData.checkBtn.luaClick = self:CreateAction(self.OnCheckBtn)
	self.bindData.inviteNpcGoBtn.luaClick = self:CreateAction(self.OnInviteNpcGoBtn)
	self.bindData.tabList.luaSimpleRenderItem = self:CreateAction(self.OnRefreshTabList)
	self.bindData.tabList.luaSelectedChanged = self:CreateAction(self.OnSelectTab)
	self.bindData.diffcultyTabList.luaSimpleRenderItem = self:CreateAction(self.OnRefreshDiffcultyTabList)
	self.bindData.diffcultyTabList.luaSelectedChanged = self:CreateAction(self.OnSelectDiffcultyTabList)
	self.bindData.itemList.luaSimpleRenderItem = self:CreateAction(self.OnRenderItem)
	self.bindData.showAllRewardBtn.luaClick = self:CreateAction(self.OnShowAllRewardItem)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftDiffcTabBtn.luaClick = self:CreateAction(self.OnLeftSelectTab)
		self.bindData.rightDiffcTabBtn.luaClick = self:CreateAction(self.OnRightSelectTab)
	end

	self.msgEvents = {
		[gEventConstants.DIALOG_END] = self:CreateAction(self.DialogEnd),
		[gEventConstants.LIVEHOUSE_INVITE_NPC] = self:CreateAction(self.OnNpcChatInviteV2)
	}

	self:RegisterMessageEvents(self.msgEvents)
end

function M:OnStart()
	gMusicGameEditManager:LoadGamePlayProperty()
	gMusicGameEditManager:LoadDefaultGamePlayNoteList()
end

function M:OnDestroy()
	self:ClearMessageEvents()
end

function M:OnShow(panelId, data)
	self.difficulty = 1
	self.tabIndex = 1
	self.musicId = 0
	gMusicGameManager.InviteNpcId = 0
	self.bindData.useGoldFinger = 1

	gMusicGameManager:AskLiveHouseMusicList(function ()
		self:InitInfos()
	end)
end

function M:InitInfos()
	self.diffcultyTabList = {}

	for i = 1, #LivehouseConfig.DifficultyName do
		local view = {
			tabIndex = i,
			title = LivehouseConfig.DifficultyName[i]
		}

		table.insert(self.diffcultyTabList, view)
	end

	self.bindData.diffcultyTabList:SetSimpleList(#self.diffcultyTabList)

	self.tabList = {}

	for index = 0, LivehouseConfig.count - 1 do
		local cfg = LivehouseConfig.LoadAt(index)
		local view = {
			id = cfg.Id,
			name = cfg.StoryName,
			Difficulty = cfg.Difficulty,
			bgmName = cfg.BGMName,
			iconId = cfg.SImage,
			tabIndex = index + 1
		}

		if not table.isNilOrEmpty(cfg.Difficulty) then
			local scorelevel = 10

			for i = 1, #cfg.Difficulty do
				local scoreL = gMusicGameManager:GetScoreLevel(cfg.Difficulty[i].MusicConfigID)
				scorelevel = scorelevel < scoreL and scorelevel or scoreL
			end

			view.scoreLevel = scorelevel
		end

		table.insert(self.tabList, view)
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	self.bindData.isUseFingerGold = false
	gMusicGameManager.GMFullPerfect = self.bindData.isUseFingerGold
end

function M:OnRefreshTabList(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabList[luaIndex]
	local store = gStoreManager:GetStoreGroup("LivehouseSelectTabStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		store.rankLevel = data.scoreLevel or 0
		btn.isSelected = data.tabIndex == self.tabIndex

		if btn.isSelected then
			store.selectAnim:Play("S_Vx_LivehouseSelectTemplate_Select")

			self.liveHouseId = data.id

			self:CheckSelectDiffculty()
		end
	end
end

function M:OnSelectTab(data)
	self.tabIndex = data.selectedIndex + 1
	local tabInfo = self.tabList[self.tabIndex]

	if table.isNilOrEmpty(tabInfo) then
		print_error("当前选择没有数据，tabindex = " .. self.tabIndex)

		return
	end

	self.liveHouseId = tabInfo.id
	self.bindData.rankLevel = tabInfo.scoreLevel or 0

	self:CheckSelectDiffculty()
end

function M:OnRefreshDiffcultyTabList(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.diffcultyTabList[luaIndex]
	local store = gStoreManager:GetStoreGroup("LivehouseTabStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = data.tabIndex == self.difficulty

		if btn.isSelected then
			self:CheckSelectDiffculty()
		end
	end
end

function M:OnSelectDiffcultyTabList(data)
	self.difficulty = data.selectedIndex + 1

	self:CheckSelectDiffculty()
end

function M:CheckSelectDiffculty()
	local cfg = LivehouseConfig.GetConfig(self.liveHouseId)

	if cfg == nil then
		return
	end

	self.rewardItemList = {}
	self.bindData.bgmName = cfg.BGMName
	self.bindData.title = cfg.StoryName
	self.bindData.des = cfg.StoryIntro
	self.bindData.imageId = cfg.SImage
	local difficulty = cfg.Difficulty

	for i = 1, #difficulty do
		if self.difficulty ~= difficulty[i].Difficulty then
			-- Nothing
		else
			self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(difficulty[self.difficulty].MusicConfigID)
			local musicConfigID = difficulty[i].MusicConfigID
			local diffCfg = LivehouseMusicConfig.GetConfig(musicConfigID)

			if diffCfg ~= nil then
				local items = gCommonItemManager:GetItemSortedListByDropList({
					{
						count = 1,
						dropId = diffCfg.Drop.DropID
					}
				}, true)

				for j = 1, #items do
					local view = {
						itemId = items[j].Id,
						itemNum = items[j].Count,
						countCtl = C_CommonItemManager.CommonItemRenderCountCtl.UP
					}

					table.insert(self.rewardItemList, gCommonItemManager:GetItemRenderData(view))
				end

				self.bindData.itemList:SetSimpleList(#self.rewardItemList)

				self.bindData.hasGetReward = gMusicGameManager.RecordMusicInfo[musicConfigID] and gMusicGameManager.RecordMusicInfo[musicConfigID].alreadyReward or false
				self.musicId = musicConfigID
			end
		end
	end
end

function M:PlayLiveHouseV2()
	local gameCfg = LivehouseMusicConfig.GetConfig(self.musicId)

	if gameCfg == nil then
		print_error("当前没有选择music，请排查错误   musicId = " .. self.musicId)

		return
	end

	if gMusicGameManager.GMFullPerfect then
		gClientToGameDelegate:AskLiveHouseUseItem(self.musicId).Callback = function (err)
			if err == MessageConfig.Ok then
				self:StartGame()
			else
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	else
		self:StartGame()
	end
end

function M:StartGame()
	gClientToGameDelegate:LiveHouseMusicStart(self.musicId, gMusicGameManager.InviteNpcId, self.difficulty)
	gPanelManager:CheckShow(gPanelId.LIVEHOUSE_GAME_PANEL, {
		liveHouseMusicId = self.musicId,
		liveHouseId = self.liveHouseId,
		difficulty = self.difficulty
	})
	self:PlayGameMainTimeline()
	self:ClosePanel()
end

function M:PlayGameMainTimeline()
	local gameCfg = LivehouseMusicConfig.GetConfig(self.musicId)
	local srcSubTimelines = {}
	local destSubTimelines = {}
	local bindInfos = nil
	local mainActorTimeline = gPlayerManager.infoLogin.bindData.sexType == UX.Game.SexType.Female and "Livehouse_Tm02_MainF" or "Livehouse_Tm02_MainM"

	table.insert(srcSubTimelines, "主角")
	table.insert(destSubTimelines, mainActorTimeline)

	local npcInfo = gMusicGameManager.InviteNpcId and gMusicGameManager.NpcDailyList[gMusicGameManager.InviteNpcId]

	if npcInfo then
		local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteNpcPid, "被邀请角色", nil)
		bindInfos = {
			c_bindInfo
		}
		local modelCfg = GeneralModelConfig.GetConfig(npcInfo.timelineModelID)
		local bodyDes = GeneralModelConfig.BodyEnglistDetail[modelCfg.BodyType]

		if bodyDes == nil then
			print_error(" BodyEnglistDetail 没有找到对应的描述 BodyType = " .. modelCfg.BodyType .. "  timelineModelID = " .. npcInfo.timelineModelID)

			bodyDes = ""
		end

		local danceTypeDes = GeneralModelConfig.DanceTypeDesc[modelCfg.DanceType]

		if danceTypeDes == nil then
			print_error(" DanceTypeDesc 没有找到对应的描述 DanceType = " .. modelCfg.DanceType .. "  timelineModelID = " .. npcInfo.timelineModelID)

			danceTypeDes = ""
		end

		local invitedActorTimeline = "Livehouse_Tm02_" .. bodyDes .. "_" .. danceTypeDes
		local endingTimeline = "Livehouse_Tm02_Ending_" .. npcInfo.EndingClipName

		table.insert(srcSubTimelines, "被邀请角色")
		table.insert(destSubTimelines, invitedActorTimeline)
		table.insert(srcSubTimelines, "Ending")
		table.insert(destSubTimelines, endingTimeline)
	else
		table.insert(srcSubTimelines, "被邀请角色")
		table.insert(destSubTimelines, "Livehouse_Tm02_Solo")
		table.insert(srcSubTimelines, "Ending")
		table.insert(destSubTimelines, "Livehouse_Tm02_Ending_Solo")
	end

	local tlData = gTimelineManager:Timeline_CreateTimelineData()
	tlData.loadWithBlackScreen = true
	tlData.srcSubTimelines = srcSubTimelines
	tlData.destSubTimelines = destSubTimelines
	tlData.bindUnitInfos = bindInfos
	tlData.canJump = true

	function tlData.onFinishCb()
		gMusicGameManager:DestroyInviteNpcUnit()
	end

	gTimelineManager:Timeline_LoadAndPlay(gameCfg.TimeineName, tlData)
end

function M:OnBackBtnClick()
	self:ClosePanel()
end

function M:ClosePanel()
	gPanelManager:Close(gPanelId.LIVEHOUSE_SELECT_PANEL)
end

function M:OnPlayBtn()
	for i = 1, #LivehouseConfig.DialogBeforeTimelineSingle do
		if LivehouseConfig.DialogBeforeTimelineSingle[i].LivehouseID == self.liveHouseId then
			self.playDialogId = LivehouseConfig.DialogBeforeTimelineSingle[i].DialogID

			gDialogManager:ShowGeneralDialog(self.playDialogId, gDialogSource.LiveHouse)
			gPanelManager:SetActiveById(gPanelId.LIVEHOUSE_SELECT_PANEL, false)
		end
	end
end

function M:OnInviteNpcGoBtn()
	gClientToGameDelegate:AskSimulationInviteNpc(NPCChatGamePlayTypeConfig.LiveHouse).Callback = function (err)
		gDisplayMessageMgr:DisplayServerMessageId(err)
	end
end

function M:OnUseGoldFingerBtn()
	if gPlayerItemManager:GetPackItemNum(ConsumableConfig.LivehouseGoldFinger) > 0 then
		self.bindData.isUseFingerGold = not self.bindData.isUseFingerGold
		gMusicGameManager.GMFullPerfect = self.bindData.isUseFingerGold
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.LivehouseGoldFinger)
	end
end

function M:OnCheckBtn()
	if self.bindData.useGoldFinger == 0 then
		self.bindData.useGoldFinger = 1
	else
		self.bindData.useGoldFinger = 0
	end
end

function M:DialogEnd(_, FirstDialogId)
	if self.playDialogId and FirstDialogId == self.playDialogId then
		self:PlayLiveHouseV2()
	end
end

function M:OnNpcChatInvite(_, npcId)
	if npcId == nil then
		return
	end

	local npcCfg = gMusicGameManager.NpcDailyList[npcId]

	if npcCfg == nil then
		print_error("当前npc没有配置，请排查错误   npcId = " .. npcId)

		return
	end

	if table.isNilOrEmpty(npcCfg.dialogbeforetimeline) then
		return
	end

	for i = 1, #npcCfg.dialogbeforetimeline do
		if npcCfg.dialogbeforetimeline[i].LivehouseID == self.liveHouseId then
			self.playDialogId = npcCfg.dialogbeforetimeline[i].DialogID
			gMusicGameManager.InviteNpcId = npcId

			self:DoInviteNpcDartGame(npcId)

			break
		end
	end
end

function M:OnNpcChatInviteV2(_, npcId)
	local npcCfg = npcId and gMusicGameManager.NpcDailyList[npcId]

	if npcCfg == nil or table.isNilOrEmpty(npcCfg.dialogbeforetimeline) then
		print_error("当前 npc 没有配置 LivehouseNPCdailyConfig ，请排查错误 npcId = " .. npcId)

		return
	end

	gMusicGameManager.InviteNpcId = npcId

	for k, v in ipairs(npcCfg.dialogbeforetimeline) do
		if v.LivehouseID == self.liveHouseId then
			self.playDialogId = v.DialogID

			break
		end
	end

	local inviteNpcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
	local spiritId = (inviteNpcCfg or {}).FightSpiritID

	if spiritId == nil or spiritId == 0 then
		print_error("livehouse 当前邀请的npc没有配战灵！,NpcCultivationConfig=" .. npcId)

		return
	end

	gClientToGameDelegate:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, fashionIdList)
		if err == MessageConfig.Ok then
			if #fashionIdList == 0 then
				self:PlayInviteNpcTimeline(npcId, 0)
			else
				self:PlayInviteNpcTimeline(npcId, fashionIdList)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

function M:OnLeftSelectTab()
	self.tabDiffcIndex = self.bindData.diffcultyTabList.selectedIndex >= 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if self.tabDiffcIndex > 0 then
		self.bindData.diffcultyTabList:SelectItem(self.tabDiffcIndex - 1, true)
	end
end

function M:OnRightSelectTab()
	self.tabDiffcIndex = self.bindData.diffcultyTabList.selectedIndex >= 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if self.tabDiffcIndex + 1 < #self.diffcultyTabList then
		self.bindData.diffcultyTabList:SelectItem(self.tabDiffcIndex + 1, true)
	end
end

function M:OnShowAllRewardItem()
	if table.isNilOrEmpty(self.rewardItemList) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_ITEM_INFO_PANEL, {
		itemList = self.rewardItemList
	})
end

function M:CreateNpc(npcId, fashionIdList, position)
	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)
	local agentCfgId = spiritCfg.AgentId
	local npc = gCS.LuaUtils.CreateClientAgentByCfg(agentCfgId, position, Vector3.zero, nil, fashionIdList or 0)
	gMusicGameManager.InviteNpcUnit = npc
	gMusicGameManager.InviteNpcUnitPid = npc.Pid

	return npc
end

function M:PlayInviteNpcTimeline(npcId, fashionIdList)
	local timelineData = gTimelineManager:Timeline_CreateTimelineData()
	local transformCfg = LivehouseConfig.LivehouseInviteTL_Transform[1]
	local position = Vector3.Fetch(transformCfg.transformx, transformCfg.transformy, transformCfg.transformz)
	local npc = self:CreateNpc(npcId, fashionIdList, position)
	self.inviteNpcPid = npc.Pid
	local c_bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteNpcPid, LivehouseConfig.LivehouseInviteTL_ActorName, nil)
	timelineData.bindUnitInfos = {
		c_bindInfo
	}
	timelineData.pos = position
	timelineData.rot = Vector3.Fetch(0, transformCfg.rotationy, 0)
	local dartNpcCfg = self:FindPoiGameDartNpcConfig(npcId)

	if dartNpcCfg then
		timelineData.dynamicPersonalityTypes = {
			dartNpcCfg.Personality
		}
	end

	local dialogId = self:FindInviteNpcDialog(npcId)

	if dialogId then
		timelineData.dynamicDialogIds = {
			dialogId
		}
	end

	function timelineData.onFinishCb()
		if self.playDialogId then
			self:PlayLiveHouseV2()
		end
	end

	gTimelineManager:Timeline_LoadAndPlay(LivehouseConfig.LivehouseInviteTL, timelineData)
	self:ClosePanel()
end

function M:FindInviteNpcDialog(npcId)
	local npcDailyCfg = gMusicGameManager.NpcDailyList[npcId]

	if npcDailyCfg == nil then
		return nil
	end

	local v, k = array.find_if(npcDailyCfg.dialogbeforetimeline, function (v)
		return v.LivehouseID == self.liveHouseId
	end)

	return v and v.DialogID
end

function M:OnRenderItem(btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.rewardItemList[luaIndex]

	gCommonItemManager:OnCommonItemRender(btn, _, data)
end

function M:FindPoiGameDartNpcConfig(npcId)
	for index = 0, PoiGameDartNpcConfig.count - 1 do
		local cfg = PoiGameDartNpcConfig.LoadAt(index)

		if cfg and cfg.NpcId == npcId then
			return cfg
		end
	end

	return nil
end
