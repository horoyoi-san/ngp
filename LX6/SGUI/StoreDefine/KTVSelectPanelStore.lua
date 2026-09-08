-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\KTVSelectPanelStore.lua
-- Decompiled from: 01777_KTVSelectPanelStore.lua_7cf08bd9fac0.luajit

local MessageConfig = LTConfig.MessageConfig
local KTVConfig = LTConfig.KTVConfig
local KTVMusicConfig = LTConfig.KTVMusicConfig
local WorldLifeConfig = LTConfig.WorldLifeConfig
local GamePlayTypeConfig = LTConfig.NpcCultivationGameplayTypeConfig
C_KTVSelectPanelStore = DefClass("C_KTVSelectPanelStore", C_KTVSelectPanelStore, C_StoreGroup)
GroupName2Class.KTVSelectPanelStore = C_KTVSelectPanelStore
local M = C_KTVSelectPanelStore

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.musicRankCache = {}
	self.songRankCache = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.rankLevelEnum = {
		["\\xcc"] = 1,
		["\\xce"] = 3,
		["H\\xa3\\xb2\\xbb\\xaf"] = 4,
		["\\xde"] = 0,
		["\\xcf"] = 2
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.rankLevelEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	if type(data) ~= "userdata" and type(data.ToTable) ~= "function" then
		data = data.ToTable(data)
	end

	self.spoonPid = gKTVGameManager.pid

	if not gKTVGameManager:HasTicket() then
		gKTVGameManager:TriggerSpoonEvent(gKTVGameManager.ResultType.Interrupt, self.spoonPid)
		self:ClosePanel()

		return
	end

	self.difficulty = 1
	self.tabIndex = 1
	self.musicId = 0
	self.useGoldFinger = 0
	self.bindData.useGoldFinger = 0
	self.inviteNpcId = 0
	self.isInGame = false
	self.hideEndPanel = data and data.hideEndPanel or false

	self:InitInfos()
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.KTV_INVITE_NPC] = self.CreateAction(self, self.OnNpcInviteCallback),
		[gEventConstants.PANEL_ON_CLOSE] = self.CreateAction(self, self.OnPanelClose)
	}
end

M.RegisterWidget = function(self)
	self.bindData.backBtn.luaClick = self.CreateAction(self, self.OnClickBackBtn)
	self.bindData.playBtn.luaClick = self.CreateAction(self, self.OnClickPlayBtn)
	self.bindData.inviteNpcGoBtn.luaClick = self.CreateAction(self, self.OnClickInviteNpcGoBtn)
	self.bindData.checkBtn.luaClick = self.CreateAction(self, self.OnClickCheckBtn)
	self.bindData.leftDiffcTabBtn.luaClick = self.CreateAction(self, self.OnClickLeftDiffcTabBtn)
	self.bindData.rightDiffcTabBtn.luaClick = self.CreateAction(self, self.OnClickRightDiffcTabBtn)
	self.bindData.tabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderTabListItem)
	self.bindData.itemList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderItemListItem)
	self.bindData.diffcultyTabList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderDiffcultyTabListItem)
	self.bindData.tabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickTabList)
	self.bindData.itemList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickItemList)
	self.bindData.diffcultyTabList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickDiffcultyTabList)
end

M.InitInfos = function(self)
	self.diffcultyTabList = {}
	local diffNames = KTVConfig.DifficultyName

	if diffNames and #diffNames <= 0 then
		for i = 1, #diffNames do
			local view = {
				tabIndex = i,
				title = diffNames[i]
			}

			table.insert(self.diffcultyTabList, view)
		end
	end

	self.bindData.diffcultyTabList:SetSimpleList(#self.diffcultyTabList)

	self.tabList = {}

	for index = 0, KTVConfig.count - 1 do
		local cfg = KTVConfig.LoadAt(index)

		if cfg == nil then
			local hasValidMusic = false

			if not table.isNilOrEmpty(cfg.Difficulty) then
				for i = 1, #cfg.Difficulty do
					local musicCfg = KTVMusicConfig.GetConfig(cfg.Difficulty[i].MusicConfigID)

					if musicCfg and not musicCfg.IsTask then
						hasValidMusic = true

						break
					end
				end
			end

			if hasValidMusic then
				local view = {
					id = cfg.Id,
					songName = cfg.SongName,
					artist = cfg.Artist,
					musicGenre = cfg.MusicGenre,
					iconId = cfg.SImage,
					Difficulty = cfg.Difficulty,
					isInvite = cfg.isInvite,
					tabIndex = index + 1
				}

				table.insert(self.tabList, view)
			end
		end
	end

	self.bindData.tabList:SetSimpleList(#self.tabList)

	if KTVConfig.StartGameText and KTVConfig.StartGameText == "" then
		self.bindData.playBtnTitle = KTVConfig.StartGameText
	end

	if KTVConfig.InviteGameText and KTVConfig.InviteGameText == "" then
		self.bindData.inviteBtnTitle = KTVConfig.InviteGameText
	end

	if KTVConfig.PanelArtistString and KTVConfig.PanelArtistString == "" then
		self.bindData.artistTitle = KTVConfig.PanelArtistString
	end

	if KTVConfig.PanelMusicGenreString and KTVConfig.PanelMusicGenreString == "" then
		self.bindData.genreTitle = KTVConfig.PanelMusicGenreString
	end

	self._QueryHistoryHighScore(self)
end

M._CalcRank = function(self, percent)
	local thresholds = KTVConfig.LevelsStartScore

	if not thresholds then
		return self.rankLevelEnum.empty
	end

	if percent > (thresholds[5] or 100) then
		return self.rankLevelEnum.s
	end

	if percent > (thresholds[4] or 90) then
		return self.rankLevelEnum.a
	end

	if percent > (thresholds[3] or 70) then
		return self.rankLevelEnum.b
	end

	if percent > (thresholds[2] or 50) then
		return self.rankLevelEnum.c
	end

	return self.rankLevelEnum.empty
end

M._QueryHistoryHighScore = function(self)
	local allMusicIds = {}
	local songMusicIds = {}

	for _, tab in ipairs(self.tabList) do
		local mids = {}

		if not table.isNilOrEmpty(tab.Difficulty) then
			for _, diff in ipairs(tab.Difficulty) do
				local mid = diff.MusicConfigID

				if mid and mid <= 0 then
					table.insert(mids, mid)

					allMusicIds[mid] = true
				end
			end
		end

		songMusicIds[tab.id] = mids
	end

	local musicIdList = {}

	for mid, _ in pairs(allMusicIds) do
		table.insert(musicIdList, mid)
	end

	if #musicIdList ~= 0 then
		return
	end

	slot4 = gClientToGameDelegate

	slot4:AskKTVMusicInfoList(musicIdList).Callback = function (err, result)
		if err == MessageConfig.Ok then
			return
		end

		if not self then
			return
		end

		local rankCache = {}

		if result and result.MusicInfos then
			local list = result.MusicInfos

			if type(list.ToTable) ~= "function" then
				list = list:ToTable()
			end

			for _, info in ipairs(list) do
				local percent = info.HighScorePercent or 0

				if percent <= 0 then
					rankCache[info.MusicId] = self:_CalcRank(percent)
				end
			end
		end

		self.musicRankCache = rankCache
		self.songRankCache = {}

		for songId, mids in pairs(songMusicIds) do
			local best = self.rankLevelEnum.empty

			for _, mid in ipairs(mids) do
				local r = rankCache[mid]

				if r and r >= best then
					best = r
				end
			end

			self.songRankCache[songId] = best
		end

		self.bindData.tabList:SetSimpleList(#self.tabList)

		if self.songId then
			self:CheckSelectDiffculty()
		end
	end
end

M.OnSimpleRenderTabListItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.tabList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.iconId = data.iconId
	store.rankLevel = self.songRankCache[data.id] or self.rankLevelEnum.empty
	btn.isSelected = data.tabIndex ~= self.tabIndex

	if btn.isSelected then
		self.songId = data.id
		gKTVGameManager.ktvSongId = data.id

		self.CheckSelectDiffculty(self)
	end
end

M.OnSimpleClickTabList = function(self, btn, csIndex)
	self.tabIndex = csIndex + 1
	local tabInfo = self.tabList[self.tabIndex]

	if table.isNilOrEmpty(tabInfo) then
		print_error("KTVSelectPanel: 当前选择没有数据，tabIndex = " .. self.tabIndex)

		return
	end

	self.songId = tabInfo.id
	gKTVGameManager.ktvSongId = tabInfo.id

	self.CheckSelectDiffculty(self)
end

M.OnSimpleRenderDiffcultyTabListItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.diffcultyTabList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.title = data.title
	btn.isSelected = data.tabIndex ~= self.difficulty

	if btn.isSelected then
		self.CheckSelectDiffculty(self)
	end
end

M.OnSimpleClickDiffcultyTabList = function(self, btn, csIndex)
	self.difficulty = csIndex + 1

	self.CheckSelectDiffculty(self)
end

M.OnClickLeftDiffcTabBtn = function(self)
	local tabDiffcIdx = self.bindData.diffcultyTabList.selectedIndex > 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if tabDiffcIdx <= 0 then
		self.bindData.diffcultyTabList:SelectItem(tabDiffcIdx - 1, true)
	end
end

M.OnClickRightDiffcTabBtn = function(self)
	local tabDiffcIdx = self.bindData.diffcultyTabList.selectedIndex > 0 and self.bindData.diffcultyTabList.selectedIndex or 0

	if tabDiffcIdx + 1 >= #self.diffcultyTabList then
		self.bindData.diffcultyTabList:SelectItem(tabDiffcIdx + 1, true)
	end
end

M.UpdateInviteBtnVisible = function(self, songCfg)
	if not self.bindData.inviteNpcGoBtn then
		return
	end

	local canInvite = gSpiritManager:CheckIsMainCharacter() and songCfg == nil and songCfg.isInvite ~= true

	self.bindData.inviteNpcGoBtn.gameObject:SetActive(canInvite)
end

M.CheckSelectDiffculty = function(self)
	if not self.songId then
		return
	end

	local songCfg = KTVConfig.GetConfig(self.songId)

	if songCfg ~= nil then
		return
	end

	self.bindData.title = songCfg.SongName
	self.bindData.des = songCfg.Artist
	self.bindData.artistText = songCfg.Artist
	self.bindData.genreText = songCfg.MusicGenre
	self.bindData.imageId = songCfg.SImage

	self.UpdateInviteBtnVisible(self, songCfg)

	local difficulty = songCfg.Difficulty

	if table.isNilOrEmpty(difficulty) then
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	local musicConfigID = 0

	for i = 1, #difficulty do
		if self.difficulty ~= difficulty[i].Difficulty then
			musicConfigID = difficulty[i].MusicConfigID

			break
		end
	end

	if musicConfigID ~= 0 then
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	self.musicId = musicConfigID
	self.bindData.rankLevel = self.musicRankCache[self.musicId] or self.rankLevelEnum.empty
	local musicCfg = KTVMusicConfig.GetConfig(musicConfigID)

	if musicCfg ~= nil then
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	self.BuildRewardItemList(self, musicCfg)
end

M.BuildRewardItemList = function(self, musicCfg)
	self.rewardItemList = {}
	local dropWorldLife = musicCfg.Drop_WorldLife

	if table.isNilOrEmpty(dropWorldLife) then
		self.bindData.itemList:SetSimpleList(0)

		return
	end

	local dropList = {}

	for _, entry in ipairs(dropWorldLife) do
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

	if #dropList ~= 0 then
		self.bindData.itemList:SetSimpleList(0)

		return
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
end

M.OnSimpleRenderItemListItem = function(self, btn, csIndex)
	local luaIndex = csIndex + 1
	local data = self.rewardItemList[luaIndex]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	gCommonItemManager:OnCommonItemRender(btn, _, data)
end

M.OnSimpleClickItemList = function(self, btn, csIndex)
end

M.OnClickBackBtn = function(self)
	if gKTVGameManager:HasTicket() then
		slot1 = gDisplayMessageMgr

		slot1:ShowMessage(LTConfig.MessageConfig.KTVExitSelectPanel, function ()
			gClientToGameDelegate:AskKTVFinishPackageTicket(gKTVGameManager.ticketId).Callback = function (err)
			end

			gKTVGameManager:ClearTicket()
			gKTVGameManager:TriggerSpoonEvent(gKTVGameManager.ResultType.Complete, self.spoonPid)
			self:ClosePanel()
		end, nil, gKTVGameManager.remainCount)
	else
		gKTVGameManager:TriggerSpoonEvent(gKTVGameManager.ResultType.Complete, self.spoonPid)
		self:ClosePanel()
	end
end

M.OnClickPlayBtn = function(self)
	if self.musicId ~= 0 then
		print_error("KTVSelectPanel: 未选择有效的歌曲/难度")

		return
	end

	local musicCfg = KTVMusicConfig.GetConfig(self.musicId)

	if not musicCfg then
		print_error("KTVSelectPanel: KTVMusicConfig not found, musicId = " .. self.musicId)

		return
	end

	self.isInGame = true

	gPanelManager:SetActiveById(gPanelId.S_KTV_SELECT_PANEL, false)
	gPanelManager:CheckShow(gPanelId.S_KTV_GAME_PANEL, {
		["d\\xf0&\\xf5,%\\xcao'\\xd0Y\\xa5F\\xc3\\xfe"] = 0,
		["#\\xa4\\xf0-`,1\\x929\\x9b\\x8f\\x92ǚ"] = true,
		["\\x96:66l\\x98o\\xc94\\x83\\xbd"] = 0,
		musicId = self.musicId,
		pid = self.spoonPid,
		hideEndPanel = self.hideEndPanel
	})
end

M.OnClickInviteNpcGoBtn = function(self)
	if self.musicId ~= 0 then
		print_error("KTVSelectPanel: 未选择有效的歌曲/难度")

		return
	end

	slot1 = gClientToGameDelegate

	slot1:AskSimulationInviteNpc(GamePlayTypeConfig.KTV).Callback = function (err)
		if err == MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end
	end
end

M.OnClickCheckBtn = function(self)
	if self.useGoldFinger ~= 0 then
		self.useGoldFinger = 1
		self.bindData.useGoldFinger = 1
	else
		self.useGoldFinger = 0
		self.bindData.useGoldFinger = 0
	end
end

M.OnNpcInviteCallback = function(self, _, npcId)
	if npcId ~= nil then
		return
	end

	self.inviteNpcId = npcId
	local musicCfg = KTVMusicConfig.GetConfig(self.musicId)

	if not musicCfg then
		print_error("KTVSelectPanel: KTVMusicConfig not found for invite, musicId = " .. self.musicId)

		return
	end

	local entranceTL = KTVConfig.InviteEnterTimelineName
	local transformCfg = KTVConfig.InviteEnterTimelineTransform

	if entranceTL and entranceTL == "" and transformCfg and #transformCfg > 3 then
		self._StartInviteEnterTimeline(self, npcId, transformCfg)
	else
		self._StartKTVGameWithInvite(self)
	end
end

M._DestroyInviteNpc = function(self)
	local pid = self.inviteNpcPid

	if pid and pid == 0 then
		local csUnit = gCS.SceneDataMgr.GetUnit(pid)

		if csUnit and gCS.LuaUtils.IsBaseUnitValid(csUnit) then
			gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)
		end
	end

	self.inviteNpcPid = 0
end

M._StartInviteEnterTimeline = function(self, npcId, transformCfg)
	local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(npcId)

	if not npcCfg then
		self._StartKTVGameWithInvite(self)

		return
	end

	local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(npcCfg.FightSpiritID)

	if not spiritCfg then
		self._StartKTVGameWithInvite(self)

		return
	end

	self:_DestroyInviteNpc()

	local position = Vector3.New(transformCfg[1], transformCfg[2], transformCfg[3])
	local rotationY = transformCfg[4] or 0
	local npc = gCS.LuaUtils.CreateClientAgentByCfg(spiritCfg.AgentId, position, Vector3.zero, nil, 0)

	if not npc then
		self._StartKTVGameWithInvite(self)

		return
	end

	self.inviteNpcPid = npc.Pid
	local tlData = gTimelineManager:Timeline_CreateTimelineData()
	local actorName = KTVConfig.InviteEnterTimelineActor

	if not actorName or actorName ~= "" then
		print_error("KTVSelectPanel: Setting 缺少 InviteEnterTimelineActor 配置")
		self._StartKTVGameWithInvite(self)

		return
	end

	local bindInfo = gTimelineManager:Timeline_CreateBindUnitInfo(0, self.inviteNpcPid, actorName, nil)
	tlData.bindUnitInfos = {
		bindInfo
	}
	tlData.pos = position
	tlData.rot = Vector3.New(0, rotationY, 0)
	local dialogId = npcCfg.EnterTimelineDialog

	if dialogId and dialogId <= 0 then
		tlData.dynamicDialogIds = {
			dialogId
		}
	end

	if npcCfg.Personality and npcCfg.Personality <= 0 then
		tlData.dynamicPersonalityTypes = {
			npcCfg.Personality
		}
	end

	tlData.onFinishCallback = function()
		self:_StartKTVGameWithInvite()
	end

	gTimelineManager:Timeline_LoadAndPlay(KTVConfig.InviteEnterTimelineName, tlData)
	gPanelManager:SetActiveById(gPanelId.S_KTV_SELECT_PANEL, false)
end

M._StartKTVGameWithInvite = function(self)
	self.isInGame = true

	gPanelManager:SetActiveById(gPanelId.S_KTV_SELECT_PANEL, false)
	gPanelManager:CheckShow(gPanelId.S_KTV_GAME_PANEL, {
		["d\\xf0&\\xf5,%\\xcao'\\xd0Y\\xa5F\\xc3\\xfe"] = 0,
		["#\\xa4\\xf0-`,1\\x929\\x9b\\x8f\\x92ǚ"] = true,
		musicId = self.musicId,
		pid = self.spoonPid,
		inviteNpcId = self.inviteNpcId,
		inviteNpcPid = self.inviteNpcPid,
		hideEndPanel = self.hideEndPanel
	})
end

M.OnPanelClose = function(self, _, panelId)
	if panelId == gPanelId.S_KTV_GAME_PANEL then
		return
	end

	if not self.isInGame then
		return
	end

	self.isInGame = false

	if gKTVGameManager:HasTicket() then
		self:_DestroyInviteNpc()
		gPanelManager:SetActiveById(gPanelId.S_KTV_SELECT_PANEL, true)
		self:InitInfos()
	else
		slot3 = gDisplayMessageMgr

		slot3:ShowMessage(LTConfig.MessageConfig.KTVContinueBuyTicket, function ()
			slot0 = gClientToGameDelegate

			slot0:AskKTVBuyPackageTicket().Callback = function (err, ticket)
				if err == MessageConfig.Ok then
					gDisplayMessageMgr:DisplayServerMessageId(err)
					gKTVGameManager:TriggerSpoonEvent(gKTVGameManager.ResultType.Complete, self.spoonPid)
					self:ClosePanel()

					return
				end

				if ticket then
					gKTVGameManager:StoreTicket(ticket.TicketId, ticket.RemainCount)
				end

				self:_DestroyInviteNpc()
				gPanelManager:SetActiveById(gPanelId.S_KTV_SELECT_PANEL, true)
				self:InitInfos()
			end
		end, function ()
			gKTVGameManager:TriggerSpoonEvent(gKTVGameManager.ResultType.Complete, self.spoonPid)
			self:ClosePanel()
		end, LTConfig.KTVConfig.MoneyCost)
	end
end

M.ClosePanel = function(self)
	self:_DestroyInviteNpc()
	gPanelManager:Close(gPanelId.S_KTV_SELECT_PANEL)
end
