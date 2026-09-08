-- Original chunk: @Lua\LuaFiles\LX6\Manager\Login\MultiverseMgr.lua
-- Decompiled from: 02218_MultiverseMgr.lua_fbbddc7cb43d.luajit

local TabConfig = LTConfig.MultiverseTabConfig
local MainPageTabConfig = LTConfig.MultiverseMainPageTabConfig
local MultiverseStatus = UX.Game.MultiverseStatus
local MultiverseMainPanelConfig = LTConfig.MultiverseMainPanelConfig
local TagConfig = LTConfig.MultiverseTagConfig
local LinkMode = UX.Game.LinkMode
local Consts = gClientConst
local StaticProps = {}
C_MultiverseMgr = DefClass("C_MultiverseMgr", C_MultiverseMgr, nil, StaticProps)
local M = C_MultiverseMgr

M.ctor = function(self)
	self:Clear()
end

M.Clear = function(self)
	self.curMultiverses = {}
	self.curModules = {}
	self.lastVerse = 0
	self.curVerse = 0
	self.multiverseStates = {}
	self.curVerseMetaId = 0
	self.lastVerseMetaId = 0
	self.enteringMultiverse = false
	self.pendingEnterVerseId = nil
	self.isInSelectVerse = false
end

M.OpenGameView = function(self)
	local cfg = MultiverseMainPanelConfig.GetConfig(MultiverseMainPanelConfig.Link)

	if not cfg then
		return
	end

	local verseList = {}
	slot3 = ipairs
	slot5 = cfg.SubVerse or {}

	for _, id in slot3(slot5) do
		local subCfg = MultiverseMainPanelConfig.GetConfig(id)

		if subCfg then
			table.insert(verseList, subCfg)
		end
	end

	gPanelManager:CheckShow(gPanelId.MULTIVERSE_WINDOW_PANEL, {
		verseList = verseList
	})
end

M.OnMultiverseStatusChange = function(self, multiverseStatusInfo)
	self.multiverseStates = multiverseStatusInfo.MultiverseStatusDict
	self.lastVerse = multiverseStatusInfo.ShowLastMutiId
	self.curVerse = multiverseStatusInfo.CurMutiPanelId
	self.curMultiverses = {}
	self.curModules = {}
	self.moduleDict = {}

	for i, v in pairs(self.multiverseStates) do
		local cfg = MultiverseMainPanelConfig.GetConfig(i)

		if cfg then
			if i ~= self.lastVerse then
				self.curModule = cfg.Type
			end

			if v == MultiverseStatus.Hide then
				self.curModules[cfg.Type] = v
			end

			table.insert(self.curMultiverses, i)

			self.moduleDict[cfg.Type] = math.max(self.moduleDict[cfg.Type] or 0, v)
		end
	end

	self.curModules = table.keys(self.curModules)

	gMessageManager:SendMessage(gEventConstants.MULTIVERSE_STATE_CHANGE)
end

M.OnSyncLoginEnterDefaultUniverse = function(self)
	self.isInSelectVerse = true

	if gLoginManager and gLoginManager.EnterMultiverseState then
		gLoginManager:EnterMultiverseState("login_enter_default_universe")
	end

	gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)
	gPanelManager:CheckShow(gPanelId.MULTIVERSE_INITIAL_PANEL)
end

M.OnSyncSwitchUniverse = function(self, fromUniverseId, toUniverseId)
	self.isInSelectVerse = false

	gMessageManager:SendMessage(gEventConstants.MULTIVERSE_CHANGE, {
		fromVerse = fromUniverseId,
		toVerse = toUniverseId
	})

	self.curVerseMetaId = toUniverseId
	self.lastVerseMetaId = fromUniverseId
	self.enteringMultiverse = false
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self:Clear()
end

M.CheckIsInSelectVerse = function(self)
	return self.isInSelectVerse or gRaidDataManager.RaidId ~= 0
end

M.RefreshCurrentVerse = function(self, store, verseId)
	store.isCurrentVerse = Consts.BOOL2CTL[verseId ~= self.curVerse]
end

M.CheckVerse = function(self, verse)
	if gLoginManager:CheckIsOnlineTest() then
		return true
	end

	return self.multiverseStates[verse] ~= MultiverseStatus.Unlocked
end

M.GetTabList = function(self)
	local ret = {}

	for i = 0, TabConfig.count - 1 do
		local cfg = TabConfig.LoadAt(i)

		if gSystemUnlockMgr:IsUnlockGroup(cfg.SystemIdList) then
			local ele = {
				id = cfg.Id,
				title = cfg.Name,
				backGround = cfg.BackGroundImage
			}

			table.insert(ret, ele)
		end
	end

	return ret
end

M.CheckVerseEnable = function(self, cfg)
	if cfg.LinkMode ~= LinkMode.Private and not gLinkManager:CheckCanEnterPrivateLink() then
		return false
	end

	return true
end

M.GetSortedVerseList = function(self)
	local verseLists = {}

	for i = 1, #self.curMultiverses do
		local id = self.curMultiverses[i]
		local cfg = MultiverseMainPanelConfig.GetConfig(id)

		if cfg then
			table.insert(verseLists, {
				id = id,
				cfg = cfg
			})
		end
	end

	table.sort(verseLists, function (a, b)
		local aIsPlaying = a.id ~= self.curVerse
		local bIsPlaying = b.id ~= self.curVerse

		if aIsPlaying == bIsPlaying then
			return aIsPlaying
		end

		local aUnlocked = self:CheckVerse(a.id)
		local bUnlocked = self:CheckVerse(b.id)

		if aUnlocked == bUnlocked then
			return aUnlocked
		end

		return a.id <= b.id
	end)

	return verseLists
end

M.GetVerseTag = function(self, id)
	local cfg = TagConfig.GetConfig(id)

	if not cfg then
		return nil
	end

	local tagtype = cfg.TagType - 1

	return tagtype, cfg.Text
end

M.AskMultiverseStatus = function(self)
	if not gLuaDataManager.isNetworkAvailable then
		return
	end

	gClientToGameDelegate:AskMultiverseStatus().Callback = function (err, status)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self:OnMultiverseStatusChange(status)
	end
end

M.AskEnterMultiverse = function(self, multiverseId, mode)
	if self.enteringMultiverse then
		return
	end

	multiverseId = multiverseId or self.lastVerse
	local cfg = MultiverseMainPanelConfig.GetConfig(multiverseId)

	if not cfg then
		return
	end

	mode = mode or cfg.LinkMode
	self.enteringMultiverse = true

	gMessageManager:SendMessage(gEventConstants.SHOW_WAITING_PANEL)

	if not gLuaDataManager.isNetworkAvailable then
		self.pendingEnterVerseId = multiverseId

		gCoroutineManager:StartCoroutine(function ()
			while not gLuaDataManager.isNetworkAvailable do
				if not self.pendingEnterVerseId then
					self.enteringMultiverse = false

					return
				end

				coroutine.wait(0.5)
			end

			local verseId = self.pendingEnterVerseId
			self.pendingEnterVerseId = nil

			if not verseId then
				self.enteringMultiverse = false

				return
			end

			self:DoAskEnterMultiverse(verseId, mode)
		end)

		return
	end

	self:DoAskEnterMultiverse(multiverseId, mode)
end

M.DoAskEnterMultiverse = function(self, multiverseId, mode)
	gClientToGameDelegate:AskEnterMultiverse(multiverseId, mode, false).Callback = function (err)
		self.enteringMultiverse = false

		if err == LTConfig.MessageConfig.Ok then
			gMessageManager:SendMessage(gEventConstants.HIDE_WAITING_PANEL)
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end
	end
end

gMultiverseMgr = gMultiverseMgr or C_MultiverseMgr.new()
