-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\ChooseDanceMusicPanelStore.lua
-- Decompiled from: 01428_ChooseDanceMusicPanelStore.lua_a4ba5aa185a4.luajit

local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local RadioSongsConfig = LTConfig.RadioSongsConfig
local PartyConfig = LTConfig.PartyConfig
local FightSpiritConfig = LTConfig.FightSpiritConfig
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local MessageConfig = LTConfig.MessageConfig
local PartyDanceSpotConfig = LTConfig.PartyDanceSpotConfig
C_ChooseDanceMusicPanelStore = DefClass("C_ChooseDanceMusicPanelStore", C_ChooseDanceMusicPanelStore, C_StoreGroup)
GroupName2Class.ChooseDanceMusicPanelStore = C_ChooseDanceMusicPanelStore
local M = C_ChooseDanceMusicPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.musicList = {}
	self.selectedMusicId = 0
	self.selectedLiveHouseId = 0
	self.selectedDifficulty = 1
	self.currentTabIndex = 0
	self.inviteNpcId = 0
	self.inviteNpcPid = 0
	self.isOnline = false
	self.isLocalMode = false
	self.partyHudHiddenByTimeline = false
	self.recommendMusicId = 0
end

M.DefineAllEnumsAutoGen = function(self)
	self.viewCtrlEnum = {
		["\\xd0\\xd5\n!\\xf4"] = 1,
		["\\xd0\\xd5\n!\\xe3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.viewCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.inviteNpcPid = data.inviteNpcPid or 0
	self.inviteNpcId = self:GetInviteNpcIdByPid(self.inviteNpcPid)
	self.isOnline = gClientUtils.CheckIsLinkMode()
	self.isLocalMode = data.isLocalMode or false
	self.viewCtrl = data.viewCtrl or self.viewCtrlEnum.inviter
	self.selectedMusicId = 0
	self.selectedLiveHouseId = 0
	self.currentTabIndex = 0
	self.recommendMusicId = 0

	self:RefreshViewCtrl()
	self:RefreshTabData()
	gMusicGameManager:AskLiveHouseMusicList(function ()
		self:InitMusicList()
	end)
end

M.OnClose = function(self)
	self.RestorePartyHudAfterTimeline(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_SYNC_PARTY_DANCE_SONG_RECOMMEND] = self.CreateAction(self, self.OnSyncPartyDanceSongRecommend),
		[gEventConstants.ON_SYNC_PARTY_DANCE_START] = self.CreateAction(self, self.OnSyncPartyDanceStart),
		[gEventConstants.ON_SYNC_PARTY_DANCE_END] = self.CreateAction(self, self.OnSyncPartyDanceEnd)
	}
end

M.RegisterWidget = function(self)
	self.bindData.startBtn.luaClick = self.CreateAction(self, self.OnClickStartBtn)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.list.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderListItem)
	self.bindData.list.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickList)
	self.bindData.list.luaSelectedChanged = self.CreateAction(self, self.OnSelectedChangedList)
end

M.OnClickStartBtn = function(self)
	if self.selectedMusicId ~= 0 then
		print_error("ChooseDanceMusic: 未选择曲目")

		return
	end

	self.RequestStartPartyDance(self)
end

M.OnClickBackBtn = function(self)
	self.AskLeavePartyDance(self)
	self.ClosePanel(self)
end

M.OnClickWantBtn = function(self)
	if self.selectedMusicId ~= 0 then
		return
	end

	if self.isOnline then
		slot1 = gClientToGameDelegate

		slot1:AskSelectPartyDanceSong(self.selectedMusicId).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)
			end
		end
	end
end

M.OnSimpleRenderListItem = function(self, btn, index)
	local luaIndex = index + 1
	local data = self.musicList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.name = data.name
	store.cover = data.iconId
	store.typeCtrl = self.currentTabIndex
	store.showRecommendCtrl = self.isOnline and data.musicId ~= self.recommendMusicId and 0 or 1
	store.difficultyName = data.difficultyName or ""
	store.difficultyCtrl = data.difficulty
	store.typeName = data.typeName or ""
end

M.OnSimpleClickList = function(self, btn, index)
	local luaIndex = index + 1
	local data = self.musicList[luaIndex]

	if not data then
		return
	end

	self.selectedMusicId = data.musicId
	self.selectedLiveHouseId = data.liveHouseId
	self.selectedDifficulty = data.difficulty
end

M.OnSelectedChangedList = function(self, uList)
	self.OnSimpleClickList(self, nil, uList.selectedIndex)
end

M.RefreshTabData = function(self)
	local tabGroup = self.SubGroup.CommonTabSingleStore

	if not tabGroup then
		return
	end

	local tabList = {}
	local danceTab = PartyConfig.DanceTab or {}

	for i = 1, #danceTab do
		table.insert(tabList, {
			id = i - 1,
			title = danceTab[i]
		})
	end

	tabGroup.SetData(tabGroup, tabList, nil, self.currentTabIndex, nil, self.CreateAction(self, "OnTabChanged"))
end

M.OnTabChanged = function(self, uList)
	self.currentTabIndex = uList.selectedIndex

	self.bindData.list:RefreshList()
end

M.InitMusicList = function(self)
	self.musicList = {}

	for index = 0, LivehouseConfig.count - 1 do
		local cfg = LivehouseConfig.LoadAt(index)

		if cfg == nil and cfg.Use ~= LivehouseConfig.UseType.Party and not table.isNilOrEmpty(cfg.Difficulty) then
			local radioCfg = RadioSongsConfig.GetConfig(cfg.RadioSongsID)
			local songName = radioCfg and radioCfg.RadioSong or ""

			for i = 1, #cfg.Difficulty do
				local diff = cfg.Difficulty[i]
				local musicCfg = LivehouseMusicConfig.GetConfig(diff.MusicConfigID)

				if musicCfg == nil then
					local view = {
						liveHouseId = cfg.Id,
						musicId = diff.MusicConfigID,
						difficulty = diff.Difficulty,
						name = songName,
						iconId = cfg.SImage or 0,
						difficultyName = LivehouseConfig.DifficultyName and LivehouseConfig.DifficultyName[diff.Difficulty] or ""
					}

					table.insert(self.musicList, view)
				end
			end
		end
	end

	self.bindData.list:SetSimpleList(#self.musicList)

	if #self.musicList <= 0 then
		self.bindData.list:SelectItem(0, true)
	end
end

M.RefreshViewCtrl = function(self)
	self.bindData.viewCtrl = self.viewCtrl

	if self.isOnline and self.viewCtrl ~= self.viewCtrlEnum.invitee then
		self.bindData.startBtn.gameObject:SetActive(false)
	end
end

M.GetSelectedPartyDanceMode = function(self)
	return self.currentTabIndex ~= 0 and UX.Game.PartyDanceMode.Hot or UX.Game.PartyDanceMode.Enjoy
end

M.GetInviteNpcIdByPid = function(self, pid)
	local inviteNpcId = gSpiritAcquisitionManager:GetTemplateIdByPid(pid)

	if inviteNpcId and inviteNpcId <= 0 then
		return inviteNpcId
	end

	local units = {}

	gCS.SceneDataMgr.UnitsManager:LuaGetAllUnits(units)

	for _, unit in ipairs(units) do
		if unit.Pid ~= pid then
			return self.GetInviteNpcIdByUnit(self, unit)
		end
	end

	return 0
end

M.GetInviteNpcIdByUnit = function(self, unit)
	local clientData = unit.ClientData

	if not clientData then
		return 0
	end

	local cardId = clientData.cardId or 0

	if cardId == 0 then
		local spiritCfg = FightSpiritConfig.GetConfig(cardId)

		if spiritCfg and spiritCfg.NpcCultivationRelatedId and spiritCfg.NpcCultivationRelatedId <= 0 then
			return spiritCfg.NpcCultivationRelatedId
		end
	end

	local agentId = clientData.AgentId

	if not agentId or agentId ~= 0 then
		agentId = clientData.SubType
	end

	if not agentId or agentId ~= 0 then
		return 0
	end

	local npcIdList = gPartyManager:GetPartyNpcInfoList()

	for _, npcId in ipairs(npcIdList) do
		local npcCfg = NpcCultivationConfig.GetConfig(npcId)
		local spiritCfg = npcCfg and FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)

		if spiritCfg and spiritCfg.AgentId ~= agentId then
			return npcId
		end
	end

	return 0
end

M.GetPartyDanceTimelineTransform = function(self, musicId)
	local partyInfo = self.isOnline and gCustomRoomMgr:GetPartyInfo() or nil
	local partyId = partyInfo and partyInfo.PartyConfigId or gPartyManager.singlePartyId

	for i = 0, PartyDanceSpotConfig.count - 1 do
		local cfg = PartyDanceSpotConfig.LoadAt(i)

		if cfg.PartyId ~= partyId and cfg.MusicId ~= musicId then
			return Vector3.New(cfg.DanceSpot[1], cfg.DanceSpot[2], cfg.DanceSpot[3]), Vector3.New(0, cfg.DanceRotation, 0)
		end
	end

	print_error("ChooseDanceMusic: PartyDance spot config missing, partyId = " .. tostring(partyId) .. ", musicId = " .. tostring(musicId))
end

M.FillPartyLiveHouseTimelineParams = function(self, params)
	local gameCfg = LivehouseMusicConfig.GetConfig(params.musicId)
	params.gameplayTimelineName = gPartyManager:GetPartyLivehouseGameplayTimelineName(gameCfg, params.musicId)
	params.skipLivehouseIntroTimeline = true
	params.skipLivehouseEndTimeline = true

	return params
end

M.RequestStartPartyDance = function(self)
	local selectedMode = self.GetSelectedPartyDanceMode(self)

	if self.isLocalMode then
		self.OnSyncPartyDanceStart(self, nil, {
			MusicId = self.selectedMusicId,
			Mode = selectedMode
		})

		return
	end

	slot2 = gClientToGameDelegate

	slot2:AskSelectPartyDanceSong(self.selectedMusicId).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		slot1 = gClientToGameDelegate

		slot1:AskSelectPartyDanceMode(selectedMode).Callback = function (err)
			if err == MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			slot1 = gClientToGameDelegate

			slot1:AskStartPartyDance().Callback = function (err)
				if err == MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)

					return
				end
			end
		end
	end
end

M.PlayLiveHouseV2 = function(self)
	local timelinePos, timelineRot = self.GetPartyDanceTimelineTransform(self, self.selectedMusicId)

	if not timelinePos then
		return
	end

	local params = self:FillPartyLiveHouseTimelineParams({
		musicId = self.selectedMusicId,
		liveHouseId = self.selectedLiveHouseId,
		difficulty = self.selectedDifficulty,
		inviteNpcId = self.inviteNpcId,
		inviteNpcPid = self.inviteNpcPid,
		timelinePos = timelinePos,
		timelineRot = timelineRot,
		onAfterStart = function ()
			self:ClosePanel()
		end
	})

	gMusicGameManager:PlayLiveHouseV2(params)
end

M.GetPartyDanceLiveHouseParams = function(self, info)
	local playInfo = gPartyManager:GetPartyDanceLiveHouseParams(info.MusicId)

	if not playInfo then
		print_error("ChooseDanceMusic: PartyDance music config missing, musicId = " .. tostring(info.MusicId))

		return nil
	end

	local timelinePos, timelineRot = self.GetPartyDanceTimelineTransform(self, playInfo.musicId)

	if not timelinePos then
		return nil
	end

	local inviteNpcPid = self.inviteNpcPid or 0
	local inviteNpcId = self.inviteNpcId or 0

	if inviteNpcId ~= 0 and inviteNpcPid == 0 then
		inviteNpcId = self.GetInviteNpcIdByPid(self, inviteNpcPid)
		self.inviteNpcId = inviteNpcId
	end

	return self.FillPartyLiveHouseTimelineParams(self, {
		musicId = playInfo.musicId,
		liveHouseId = playInfo.liveHouseId,
		difficulty = playInfo.difficulty,
		inviteNpcId = inviteNpcId,
		inviteNpcPid = inviteNpcPid,
		panelId = gPanelId.PARTY_DANCE_GAME_PANEL,
		timelinePos = timelinePos,
		timelineRot = timelineRot,
		onTimelineFinish = function ()
			self:FinishPartyDanceTimeline()
			gPanelManager:Close(gPanelId.PARTY_DANCE_GAME_PANEL)
			gPanelManager:Close(gPanelId.LIVEHOUSE_GAME_END_PANEL)
		end
	})
end

M.HidePartyHudForTimeline = function(self)
	self.partyHudHiddenByTimeline = true

	gPanelManager:SetActiveById(gPanelId.PARTY_HUD_PANEL, false)
end

M.RestorePartyHudAfterTimeline = function(self)
	if self.partyHudHiddenByTimeline then
		gPanelManager:SetActiveById(gPanelId.PARTY_HUD_PANEL, true)

		self.partyHudHiddenByTimeline = false
	end
end

M.FinishPartyDanceTimeline = function(self)
	self.RestorePartyHudAfterTimeline(self)

	if not self.isLocalMode then
		self.AskLeavePartyDance(self)
	end
end

M.PlayPartyDanceTimeline = function(self, info)
	local params = self.GetPartyDanceLiveHouseParams(self, info)

	if not params then
		self.ClosePanel(self)

		return
	end

	params.onAfterStart = function()
		self:ClosePanel()
		self:HidePartyHudForTimeline()
	end

	params.onInterrupt = function()
		self:FinishPartyDanceTimeline()
	end

	gMusicGameManager:PlayLiveHouseV2(params)
end

M.ClosePanel = function(self)
	gPanelManager:Close(self.m_Id)
end

M.AskLeavePartyDance = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskLeavePartyDance().Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnSyncPartyDanceSongRecommend = function(self, _, musicId)
	self.recommendMusicId = musicId or 0

	self.bindData.list:RefreshList()
end

M.OnSyncPartyDanceStart = function(self, _, info)
	self.PlayPartyDanceTimeline(self, info)
end

M.OnSyncPartyDanceEnd = function(self, _, zoneGadgetUId)
	self.ClosePanel(self)
end
