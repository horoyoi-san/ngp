-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\BigMapTooltips\BigMapTooltip_MartialArtist.lua
-- Decompiled from: 01019_BigMapTooltip_MartialArtist.lua_994df8fe74c3.luajit

C_BigMapTooltip_MartialArtist = DefClass("C_BigMapTooltip_MartialArtist", C_BigMapTooltip_MartialArtist, C_BigMapTooltipBase)
local M = C_BigMapTooltip_MartialArtist
local AgentProfileConfig = LTConfig.ProfileAgentProfileConfig
local AgentConfig = LTConfig.AgentConfig
local FactionConfig = LTConfig.FactionConfig
local TYPE_UNKNOW = 0
local TYPE_KNOW = 1

M.SetUpInfo = function(self)
	self:GetStore("MapMartialArtistTooltipStore")

	local wuxueMapId = self.tooltipInfo.martialArtistInfo.wuxueMapId
	local maType = self.tooltipInfo.martialArtistInfo.maType
	self.scrollStore = gStoreManager:GetStoreGroup("MartialArtistScrollStore"):GetStoreByWidget(self.store.maScroll.content)

	if maType ~= 0 then
		self.store.typeCtrl = TYPE_UNKNOW
		self.scrollStore.typeCtrl = TYPE_UNKNOW
	elseif maType ~= 1 then
		self.store.typeCtrl = TYPE_UNKNOW
		self.scrollStore.typeCtrl = TYPE_UNKNOW
	elseif maType ~= 2 then
		self.store.typeCtrl = TYPE_UNKNOW
		self.scrollStore.typeCtrl = TYPE_UNKNOW
	elseif maType ~= 3 then
		self.store.typeCtrl = TYPE_KNOW
		self.scrollStore.typeCtrl = TYPE_KNOW
	elseif maType ~= 4 then
		self.store.typeCtrl = TYPE_KNOW
		self.scrollStore.typeCtrl = TYPE_KNOW
	end

	local rumors = self.tooltipInfo.martialArtistInfo.rumors or {}
	local agentProfileId = self.tooltipInfo.martialArtistInfo.agentProfileId
	local cfg = LTConfig.WuxueMapConfig.GetConfig(wuxueMapId)
	local profileCfg = LTConfig.ProfileAgentProfileConfig.GetConfig(agentProfileId)
	local npcName = profileCfg and profileCfg.Name or ""
	local npcIconId = cfg and cfg.HeadIcon or 0
	local fightSkillId = cfg.FightSkill
	local fightSkillIconId = LTConfig.FightSkillConfig.GetConfig(fightSkillId).IconId
	local fightSkillName = LTConfig.FightSkillConfig.GetConfig(fightSkillId).Name
	local titles = {
		[LTConfig.MartialArtistRumorConfig.SlotTypeType.who] = LTConfig.MartialArtistConfig.MapToolTipWhoTitle,
		[LTConfig.MartialArtistRumorConfig.SlotTypeType.where] = LTConfig.MartialArtistConfig.MapToolTipWhereTitle,
		[LTConfig.MartialArtistRumorConfig.SlotTypeType.what] = LTConfig.MartialArtistConfig.MapToolTipWhatTitle
	}
	self.clueList = {}
	local isFinished = gMartialArtistManager:IsAgentFinished(wuxueMapId)
	local isAllGot = true
	local gotCount = 0

	for _, id in pairs(rumors) do
		local rumorCfg = LTConfig.MartialArtistRumorConfig.GetConfig(id)

		if rumorCfg then
			local equippedRumor = gMartialArtistManager:GetSlotRumor(rumorCfg.WuXueId, rumorCfg.SlotType)
			local isUnlocked = equippedRumor ~= id or false
			local isGot = gMartialArtistManager:IsRumorInBackpack(id)

			if isGot then
				gotCount = gotCount + 1
			else
				isAllGot = false
			end

			local clueInfo = {
				type = rumorCfg.SlotType,
				title = titles[rumorCfg.SlotType] or "",
				clue = rumorCfg.Title,
				iconId = fightSkillIconId,
				name = fightSkillName,
				isUnlocked = isUnlocked,
				isFinished = isFinished
			}

			table.insert(self.clueList, clueInfo)
		end
	end

	if isFinished then
		self.scrollStore.showtextCtrl = 1
		self.scrollStore.showText = cfg.LockedPosDes
	else
		self.scrollStore.showtextCtrl = 0
	end

	if isAllGot or isFinished then
		self.store.unknownTip = ""
	elseif gotCount <= 0 then
		self.store.unknownTip = LTConfig.MartialArtistConfig.MapToolTipNotEnoughClue
	else
		self.store.unknownTip = LTConfig.MartialArtistConfig.MapToolTipNoClue
	end

	if isFinished then
		self.store.unknownTitle = npcName
	else
		self.store.unknownTitle = cfg.LockedDes
	end

	self.store.subTitle = npcName
	self.store.name = fightSkillName
	self.scrollStore.iconId = npcIconId
	self.scrollStore.location = self.tooltipInfo.martialArtistInfo.location

	self.store.clueBtn.luaRenderTooltip = function(_, comp, _)
		local popStore = gStoreManager:GetStoreGroup(comp.Store):GetStoreByWidget(comp)

		popStore.list.luaSimpleRenderItem = function(btn, index)
			local info = self.clueList[index + 1]
			local store = gStoreManager:GetStoreGroup("MAclueListStore"):GetStoreByWidget(btn)
			store.title = info.title
			store.typeCtrl = 1
			store.answerCtrl = 0
			store.clue = info.clue
		end

		popStore.list:SetSimpleList(#self.clueList)
	end

	slot17 = self.bigMap
	self.scrollStore.clueList.luaSimpleRenderItem = slot17:CreateAction("OnRenderClueListItem", self)
	slot16 = self.scrollStore.clueList

	slot16:SetSimpleList(#self.clueList)

	self.tabList = {
		{
			pathType = LTConfig.MartialArtistQuestConfig.QuestPathType.Apprentice,
			tab = LTConfig.MartialArtistConfig.MapToolTipQuestApprenticeTab,
			title = LTConfig.MartialArtistConfig.MapToolTipQuestApprenticeTitle
		},
		{
			pathType = LTConfig.MartialArtistQuestConfig.QuestPathType.Challenge,
			tab = LTConfig.MartialArtistConfig.MapToolTipQuestChallengeTab,
			title = LTConfig.MartialArtistConfig.MapToolTipQuestApprenticeTitle
		}
	}

	self.scrollStore.tabList.luaSimpleRenderItem = function(btn, index)
		local info = self.tabList[index + 1]
		local store = gStoreManager:GetStoreGroup("MATabStore"):GetStoreByWidget(btn)
		store.title = info.tab
	end

	self.scrollStore.tabList.luaSelectedChanged = function()
		local index = self.scrollStore.tabList.selectedIndex
		self.curTabIndex = index + 1

		self:RefreshTaskList()
	end

	self.taskList = {}

	self.scrollStore.taskList.luaSimpleRenderItem = function(btn, index)
		local info = self.taskList[index + 1]
		local store = gStoreManager:GetStoreGroup("NewAgentProfileTargetTemplate"):GetStoreByWidget(btn)

		if info.isFinished then
			store.finishCtrl = 0
		elseif info.isUnlocked then
			store.finishCtrl = 1
		else
			store.finishCtrl = 2
		end

		store.titleText = ""
		store.targetText = info.target
	end

	self.scrollStore.tabList:SetSimpleList(#self.tabList)
	self.scrollStore.tabList:SetItemSelected(0, true)

	self.curTabIndex = 1

	self:RefreshTaskList()

	self.scrollStore.controllerLButton.luaClick = function()
		if self.curTabIndex <= 1 then
			self.curTabIndex = self.curTabIndex - 1

			self.scrollStore.tabList:SetItemSelected(self.curTabIndex - 1, true)
			self:RefreshTaskList()
		end
	end

	self.scrollStore.controllerRButton.luaClick = function()
		if self.curTabIndex >= #self.tabList then
			self.curTabIndex = self.curTabIndex + 1

			self.scrollStore.tabList:SetItemSelected(self.curTabIndex - 1, true)
			self:RefreshTaskList()
		end
	end

	self:RefreshUrbanAttribute()
end

M.RefreshUrbanAttribute = function(self)
	local config = AgentProfileConfig.GetConfig(self.tooltipInfo.martialArtistInfo.agentProfileId)
	local urbanAttrs = config.UrbanAttribute

	for i = 1, #urbanAttrs do
		self.store.radarChart:SetVertexValue(i - 1, urbanAttrs[i])

		self.store["radarTitle" .. i] = urbanAttrs[i]
	end

	self.scrollStore.talentLevel = config.TalentLevel
	local agentId = config.AgentId
	local agentCfg = AgentConfig.GetConfig(agentId)
	local factionId = agentCfg and agentCfg.Faction
	local factionCfg = FactionConfig.GetConfig(factionId)
	local factionName = factionCfg and factionCfg.name
	local factionIconId = factionCfg and factionCfg.imageId
	self.scrollStore.factionName = factionName
	self.scrollStore.factionIconId = factionIconId
end

M.OnRenderClueListItem = function(self, btn, index)
	local info = self.clueList[index + 1]
	local store = gStoreManager:GetStoreGroup("MAclueListStore"):GetStoreByWidget(btn)
	store.title = info.title

	if info.isUnlocked then
		store.typeCtrl = 1
	else
		store.typeCtrl = 0
	end

	local isFinal = index + 1 ~= #self.clueList

	if info.isFinished and isFinal then
		store.answerCtrl = 1
	else
		store.answerCtrl = 0
	end

	store.clue = info.clue
	store.iconId = info.iconId
	store.name = info.name
end

M.RefreshTaskList = function(self)
	self.store.taskTitle = self.tabList[self.curTabIndex].title
	self.taskList = {}
	local questIds = self.tooltipInfo.martialArtistInfo.questIds or {}

	for _, questId in ipairs(questIds) do
		local questCfg = LTConfig.MartialArtistQuestConfig.GetConfig(questId)

		if questCfg and questCfg.QuestPath ~= self.tabList[self.curTabIndex].pathType then
			local taskInfo = {
				target = questCfg.QuestName,
				isFinished = gMartialArtistManager:IsQuestCompleted(questId),
				isUnlocked = gMartialArtistManager:IsQuestUnlocked(questId)
			}

			table.insert(self.taskList, taskInfo)
		end
	end

	self.scrollStore.taskList:SetSimpleList(#self.taskList)
end

M.SetUpActions = function(self, store, actions, blockReason)
	if not actions or #actions ~= 0 then
		store.showMainBtn = self.HIDE_BTN

		return
	end

	store.showMainBtn = self.SHOW_BTN

	if blockReason then
		store.mainBtnText = blockReason
		store.mainBtnInteractable = false

		return
	end

	store.mainBtnInteractable = true
	store.clickMain = self.bigMap:CreateActionWithArgs("OnPerformAction", actions[1], self)
	store.mainBtnText = gMapUIUtils.GetElementActionName(actions[1])
end
