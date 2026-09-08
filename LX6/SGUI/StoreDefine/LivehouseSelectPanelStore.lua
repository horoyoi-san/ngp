-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LivehouseSelectPanelStore.lua
-- Decompiled from: 01784_LivehouseSelectPanelStore.lua_53c7e494ecd7.luajit

local MessageConfig = LTConfig.MessageConfig
local LivehouseConfig = LTConfig.LivehouseConfig
local RadioSongsConfig = LTConfig.RadioSongsConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local ConsumableConfig = LTConfig.ConsumableConfig
local PoiGameDartNpcConfig = LTConfig.PoiGameDartNpcConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local WorldLifeConfig = LTConfig.WorldLifeConfig
C_LivehouseSelectPanelStore = DefClass("C_LivehouseSelectPanelStore", C_LivehouseSelectPanelStore, C_StoreGroup)
GroupName2Class.LivehouseSelectPanelStore = C_LivehouseSelectPanelStore
local M = C_LivehouseSelectPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnBackBtnClick)
	self.bindData.playBtn.luaClick = self.CreateAction(self, self.OnPlayBtn)
	self.bindData.checkBtn.luaClick = self.CreateAction(self, self.OnCheckBtn)
	self.bindData.inviteNpcGoBtn.luaClick = self.CreateAction(self, self.OnInviteNpcGoBtn)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRefreshTabList)
	self.bindData.tabList.luaSelectedChanged = self.CreateAction(self, self.OnSelectTab)
	self.bindData.diffcultyTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnRefreshDiffcultyTabList)
	self.bindData.diffcultyTabList.luaSelectedChanged = self.CreateAction(self, self.OnSelectDiffcultyTabList)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnRenderItem)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.bindData.leftDiffcTabBtn.luaClick = self.CreateAction(self, self.OnLeftSelectTab)
		self.bindData.rightDiffcTabBtn.luaClick = self.CreateAction(self, self.OnRightSelectTab)
	end

	self.msgEvents = {
		[gEventConstants.DIALOG_END] = self.CreateAction(self, self.DialogEnd),
		[gEventConstants.LIVEHOUSE_INVITE_NPC] = self.CreateAction(self, self.OnNpcChatInviteV2)
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.difficulty = 1
	self.tabIndex = 1
	self.musicId = 0
	gMusicGameManager.InviteNpcId = 0
	self.bindData.useGoldFinger = 1

	gMusicGameManager:AskLiveHouseMusicList(function ()
		self:InitInfos()
	end)
	self:CheckEnterFixedInviteNpcMode()
end

M.CheckEnterFixedInviteNpcMode = function(self)
	self.isFixedInviteNpcMode = false

	if not gNpcFavorManager:CheckIsInRide() then
		return
	end

	local cultivationId = gNpcFavorManager:GetInviteRideNpcCultivationId()
	local unit = gNpcFavorManager:GetRideNpcInst()

	if cultivationId ~= 0 or unit ~= nil then
		return
	end

	self.isFixedInviteNpcMode = true
	gMusicGameManager.InviteNpcId = cultivationId
	self.inviteNpcPid = unit.Pid

	if self.bindData.inviteNpcGoBtn then
		self.bindData.inviteNpcGoBtn.gameObject:SetActive(false)
	end

	self.bindData.backBtn.gameObject:SetActive(false)

	local title = LivehouseConfig.InvitationTaskPlayButtonName

	if title and title == "" then
		self.bindData.playBtnTitle = title
	end
end

M.InitInfos = function(self)
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

		if cfg == nil then
			if cfg.Use ~= LivehouseConfig.UseType.Normal then
				local view = {
					id = cfg.Id
				}
				local radioSongsCfg = RadioSongsConfig.GetConfig(cfg.RadioSongsID)
				view.name = radioSongsCfg and radioSongsCfg.RadioSong or ""
				view.Difficulty = cfg.Difficulty
				view.bgmName = cfg.BGMName
				view.iconId = cfg.SImage
				view.tabIndex = index + 1

				if not table.isNilOrEmpty(cfg.Difficulty) then
					local scorelevel = 10

					for i = 1, #cfg.Difficulty do
						local scoreL = gMusicGameManager:GetScoreLevel(cfg.Difficulty[i].MusicConfigID)
						scorelevel = scorelevel >= scoreL and scorelevel or scoreL
					end

					view.scoreLevel = scorelevel
				end

				table.insert(self.tabList, view)
			end
		end
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	self.bindData.isUseFingerGold = false
	gMusicGameManager.GMFullPerfect = self.bindData.isUseFingerGold
	self.bindData.ArtistTitle = LivehouseConfig.ArtistText
	self.bindData.GenreTitle = LivehouseConfig.MusicGenreText
end

M.OnRefreshTabList = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabList[luaIndex]
	local store = gStoreManager:GetStoreGroup("LivehouseSelectTabStore"):GetStoreByWidget(btn)

	if store then
		store.iconId = data.iconId
		store.rankLevel = data.scoreLevel or 0
		btn.isSelected = data.tabIndex ~= self.tabIndex

		if btn.isSelected then
			store.selectAnim:Play("S_Vx_LivehouseSelectTemplate_Select")

			self.liveHouseId = data.id

			self:CheckSelectDiffculty()
		end
	end
end

M.OnSelectTab = function(self, data)
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

M.OnRefreshDiffcultyTabList = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.diffcultyTabList[luaIndex]
	local store = gStoreManager:GetStoreGroup("LivehouseTabStore"):GetStoreByWidget(btn)

	if store then
		store.title = data.title
		btn.isSelected = data.tabIndex ~= self.difficulty

		if btn.isSelected then
			self.CheckSelectDiffculty(self)
		end
	end
end

M.OnSelectDiffcultyTabList = function(self, data)
	self.difficulty = data.selectedIndex + 1

	self.CheckSelectDiffculty(self)
end

M.CheckSelectDiffculty = function(self)
	local cfg = LivehouseConfig.GetConfig(self.liveHouseId)

	if cfg ~= nil then
		return
	end

	self.rewardItemList = {}
	self.bindData.bgmName = cfg.BGMName
	local radioSongsCfg = RadioSongsConfig.GetConfig(cfg.RadioSongsID)
	self.bindData.title = radioSongsCfg and radioSongsCfg.RadioSong or ""
	self.bindData.imageId = cfg.SImage
	self.bindData.Artist = cfg.Artist
	self.bindData.Genre = cfg.MusicGenre
	local difficulty = cfg.Difficulty

	for i = 1, #difficulty do
		if self.difficulty == difficulty[i].Difficulty then
			-- Nothing
		else
			self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(difficulty[self.difficulty].MusicConfigID)
			local musicConfigID = difficulty[i].MusicConfigID
			local diffCfg = LivehouseMusicConfig.GetConfig(musicConfigID)

			if diffCfg == nil then
				local dropList = {}

				for _, entry in ipairs(diffCfg.Drop_Worldlife) do
					local worldLifeId = entry.WorldlifeID

					if worldLifeId and worldLifeId <= 0 then
						local worldLifeCfg = WorldLifeConfig.GetConfig(worldLifeId)

						if worldLifeCfg and worldLifeCfg.Drop and worldLifeCfg.Drop <= 0 then
							table.insert(dropList, {
								["N\\xa1\\xb7\\xa1\\xa2"] = 1,
								dropId = worldLifeCfg.Drop
							})
						end
					end
				end

				local items = gCommonItemManager:GetItemSortedListByDropList(dropList, true)

				for j = 1, #items do
					local view = {
						itemId = items[j].Id,
						itemNum = items[j].Count
					}

					table.insert(self.rewardItemList, gCommonItemManager:GetItemRenderData(view))
				end

				self.bindData.itemList:SetSimpleList(#self.rewardItemList)

				self.musicId = musicConfigID
			end
		end
	end
end

M.PlayLiveHouseV2 = function(self)
	local params = {
		["\\xed\\x8e5<\\xc7K'\\xbf\\x907E\\x94Q\\xa9v/\\x8c\r\\xe3\\x8b,\\xcb"] = false,
		musicId = self.musicId,
		liveHouseId = self.liveHouseId,
		difficulty = self.difficulty,
		inviteNpcId = gMusicGameManager.InviteNpcId,
		inviteNpcPid = self.inviteNpcPid or gMusicGameManager.InviteNpcUnitPid,
		gameplayTimelineName = gMusicGameManager:GetLivehouseGameplayTimelineName(),
		isFixedInviteNpcMode = self.isFixedInviteNpcMode,
		onAfterStart = function ()
			self:ClosePanel()
		end
	}

	gMusicGameManager:PlayLiveHouseV2(params)
end

M.OnBackBtnClick = function(self)
	self.ClosePanel(self)
end

M.ClosePanel = function(self)
	gPanelManager:Close(gPanelId.LIVEHOUSE_SELECT_PANEL)
end

M.OnPlayBtn = function(self)
	if self.isFixedInviteNpcMode then
		self.PlayLiveHouseV2(self)

		return
	end

	for i = 1, #LivehouseConfig.DialogBeforeTimelineSingle do
		if LivehouseConfig.DialogBeforeTimelineSingle[i].LivehouseID ~= self.liveHouseId then
			self.playDialogId = LivehouseConfig.DialogBeforeTimelineSingle[i].DialogID

			gDialogManager:ShowGeneralDialog(self.playDialogId, gDialogSource.LiveHouse)
			gPanelManager:SetActiveById(gPanelId.LIVEHOUSE_SELECT_PANEL, false)
		end
	end
end

M.OnInviteNpcGoBtn = function(self)
	if self.isFixedInviteNpcMode then
		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskSimulationInviteNpc(GamePlayTypeConfig.LiveHouse).Callback = function (err)
		gDisplayMessageMgr:DisplayServerMessageId(err)
	end
end

M.OnUseGoldFingerBtn = function(self)
	if gCommonItemManager:GetPackItemNum(ConsumableConfig.LivehouseGoldFinger) <= 0 then
		self.bindData.isUseFingerGold = not self.bindData.isUseFingerGold
		gMusicGameManager.GMFullPerfect = self.bindData.isUseFingerGold
	else
		gDisplayMessageMgr:ShowMessage(MessageConfig.LivehouseGoldFinger)
	end
end

M.OnCheckBtn = function(self)
	if self.bindData.useGoldFinger ~= 0 then
		self.bindData.useGoldFinger = 1
	else
		self.bindData.useGoldFinger = 0
	end
end

M.DialogEnd = function(self, _, FirstDialogId)
	if self.playDialogId and FirstDialogId ~= self.playDialogId then
		self.PlayLiveHouseV2(self)
	end
end

M.OnNpcChatInvite = function(self, _, npcId)
	if npcId ~= nil then
		return
	end

	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	if npcCfg ~= nil then
		print_error("当前npc没有配置，请排查错误   npcId = " .. npcId)

		return
	end

	local enterDialog = npcCfg.EnterTimelineDialog

	if enterDialog and enterDialog == 0 then
		self.playDialogId = enterDialog
		gMusicGameManager.InviteNpcId = npcId

		self.DoInviteNpcDartGame(self, npcId)
	end
end

M.OnNpcChatInviteV2 = function(self, _, npcId)
	if self.isFixedInviteNpcMode then
		return
	end

	local inviteNpcCfg = npcId and NpcCultivationConfig.GetConfig(npcId)

	if inviteNpcCfg ~= nil then
		print_error("当前 npc 没有配置 NpcCultivationConfig ，请排查错误 npcId = " .. tostring(npcId))

		return
	end

	gMusicGameManager.InviteNpcId = npcId
	local enterDialog = inviteNpcCfg.EnterTimelineDialog
	self.playDialogId = enterDialog and enterDialog == 0 and enterDialog or nil
	local spiritId = inviteNpcCfg.FightSpiritID

	if spiritId ~= nil or spiritId ~= 0 then
		print_error("livehouse 当前邀请的npc没有配战灵！,NpcCultivationConfig=" .. npcId)

		return
	end

	slot6 = gClientToGameDelegate

	slot6:AskGetNpcRandomWearFashions(spiritId).Callback = function (err, fashionIdList)
		if err ~= MessageConfig.Ok then
			if fashionIdList ~= nil or #fashionIdList ~= 0 then
				self:PlayInviteNpcTimeline(npcId, 0)
			else
				self:PlayInviteNpcTimeline(npcId, fashionIdList)
			end
		else
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnLeftSelectTab = function(self)
	self.tabDiffcIndex = self.bindData.diffcultyTabList.selectedIndex > 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if self.tabDiffcIndex <= 0 then
		self.bindData.diffcultyTabList:SelectItem(self.tabDiffcIndex - 1, true)
	end
end

M.OnRightSelectTab = function(self)
	self.tabDiffcIndex = self.bindData.diffcultyTabList.selectedIndex > 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if self.tabDiffcIndex + 1 >= #self.diffcultyTabList then
		self.bindData.diffcultyTabList:SelectItem(self.tabDiffcIndex + 1, true)
	end
end

M.CreateNpc = function(self, npcId, fashionIdList, position)
	gMusicGameManager:DestroyInviteNpcUnit()

	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)
	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)
	local agentCfgId = spiritCfg.AgentId
	local npc = gCS.LuaUtils.CreateClientAgentByCfg(agentCfgId, position, Vector3.zero, nil, fashionIdList or 0)
	gMusicGameManager.InviteNpcUnit = npc
	gMusicGameManager.InviteNpcUnitPid = npc.Pid

	return npc
end

M.PlayInviteNpcTimeline = function(self, npcId, fashionIdList)
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

	local dialogId = self.FindInviteNpcDialog(self, npcId)

	if dialogId then
		timelineData.dynamicDialogIds = {
			dialogId
		}
	end

	timelineData.onFinishCallback = function(t)
		if self.playDialogId then
			self:PlayLiveHouseV2()
		end
	end

	gTimelineManager:Timeline_LoadAndPlay(LivehouseConfig.LivehouseInviteTL, timelineData)
	self:ClosePanel()
end

M.FindInviteNpcDialog = function(self, npcId)
	local npcCfg = NpcCultivationConfig.GetConfig(npcId)

	if npcCfg ~= nil then
		return nil
	end

	local dialogId = npcCfg.EnterTimelineDialog

	if dialogId and dialogId == 0 then
		return dialogId
	end

	return nil
end

M.OnRenderItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.rewardItemList[luaIndex]

	gCommonItemManager:OnCommonItemRender(btn, _, data)
end

M.FindPoiGameDartNpcConfig = function(self, npcId)
	for index = 0, PoiGameDartNpcConfig.count - 1 do
		local cfg = PoiGameDartNpcConfig.LoadAt(index)

		if cfg and cfg.NpcId ~= npcId then
			return cfg
		end
	end

	return nil
end
