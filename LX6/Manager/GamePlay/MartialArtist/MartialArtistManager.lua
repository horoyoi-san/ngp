-- Original chunk: @Lua\LuaFiles\LX6\Manager\GamePlay\MartialArtist\MartialArtistManager.lua
-- Decompiled from: 00762_MartialArtistManager.lua_9c9cf0577359.luajit

C_MartialArtistManager = DefClass("C_MartialArtistManager", C_MartialArtistManager)
local M = C_MartialArtistManager
local MartialArtistRumorConfig = LTConfig.MartialArtistRumorConfig
local WuxueMapConfig = LTConfig.WuxueMapConfig

M.ctor = function(self)
	self.rumorBackpack = {}
	self.slottedRumors = {}
	self.finishedWuxueIds = {}
	self.completedQuests = {}
	self.unlockedQuests = {}
	self.FIGHT_SKILL_WUXUE_MAP_UNLOCK_TYPE = {
		["\\xefs\\xad\\xd1\\x96f\\xe8\t\\xdc~\\xf8\\x87\\x86l\\x80O}\\x94\\xed"] = 2,
		["S#\\x8d\\xd2U/\\x99_6D\\x84\\xc1\\xf8\\xd7"] = 0,
		["=\\x98\\xc14;D<\\xa3ཥ\\xb5\\xb8\\xea\\xa5"] = 1
	}
end

M.InitPlayerInfo = function(self, playerInfo)
	local info = playerInfo and playerInfo.InfoMinor and playerInfo.InfoMinor.playerMartialArtistInfo

	if not info then
		return
	end

	self.rumorBackpack = info.RumorBackpack or {}
	self.slottedRumors = info.SlottedRumors or {}
	self.finishedWuxueIds = info.FinishedWuxueId or {}
	self.completedQuests = info.CompletedQuests or {}
	self.unlockedQuests = info.UnlockedQuests or {}
end

M.OnSyncRumorSlotInfo = function(self, wuxueId, slotInfo)
	self.slottedRumors[wuxueId] = slotInfo

	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_SINGLE_RUMOR_SLOT_INFO_CHANGED, wuxueId)
	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncAddRumorInBackpack = function(self, rumorId)
	self.rumorBackpack[rumorId] = true
	local msg = {
		rumorId = rumorId
	}

	gNewPopupManager:PushPopup(LTConfig.PopupConfig.MARumor, msg)
	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_RUMOR_BACKPACK_CHANGED, rumorId)
	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncRemoveRumorInBackpack = function(self, rumorId)
	self.rumorBackpack[rumorId] = nil

	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_RUMOR_BACKPACK_CHANGED, rumorId)
	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncFinishedWuxueId = function(self, wuxueId)
	self.finishedWuxueIds[wuxueId] = true

	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncAddCompletedQuest = function(self, questId)
	self.completedQuests[questId] = true

	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncAddUnlockedQuests = function(self, questIds)
	if not questIds then
		return
	end

	for i = 1, questIds.Length do
		self.unlockedQuests[questIds[i]] = true
	end

	gMessageManager:SendMessage(gEventConstants.ON_MARTIAL_ARTIST_INFO_CHANGED)
end

M.OnSyncMartialArtistTouTingResult = function(self, startDialogId, rumorIds)
	local toutingPanel = gStoreManager:GetStoreGroup("TouTingPanelStore")

	if toutingPanel and toutingPanel.isShow then
		toutingPanel:RefreshClueDialog(startDialogId, rumorIds)
	end
end

M.IsRumorInBackpack = function(self, rumorId)
	return self.rumorBackpack[rumorId] ~= true
end

M.GetSlotInfo = function(self, profileId)
	return self.slottedRumors[profileId]
end

M.GetSlotRumor = function(self, profileId, slotType)
	local slotInfo = self.slottedRumors[profileId]

	if slotInfo and slotInfo.Slots then
		return slotInfo.Slots[slotType]
	end

	return nil
end

M.IsRumorEquipped = function(self, rumorId)
	for profileId, slottedRumor in pairs(self.slottedRumors) do
		if slottedRumor and slottedRumor.Slots then
			for slotType, equippedRumorId in pairs(slottedRumor.Slots) do
				if equippedRumorId ~= rumorId then
					return true
				end
			end
		end
	end

	return false
end

M.IsAgentFinished = function(self, wuxueId)
	return self.finishedWuxueIds[wuxueId] ~= true
end

M.IsQuestCompleted = function(self, questId)
	return self.completedQuests[questId] ~= true
end

M.IsQuestUnlocked = function(self, questId)
	return self.unlockedQuests[questId] ~= true
end

M.GetAllFinishedWuxueIds = function(self)
	local result = {}

	for wuxueId, _ in pairs(self.finishedWuxueIds) do
		result[#result + 1] = wuxueId
	end

	return result
end

M.GetAllRumorsInBackpack = function(self, containEquipped)
	local result = {}

	if containEquipped then
		local existRumors = {}

		for rumorId, exist in pairs(self.rumorBackpack) do
			if exist then
				table.insert(result, rumorId)

				existRumors[rumorId] = true
			end
		end

		for profileId, slottedRumor in pairs(self.slottedRumors) do
			if slottedRumor and slottedRumor.Slots then
				for slotType, equippedRumorId in pairs(slottedRumor.Slots) do
					if not existRumors[equippedRumorId] then
						table.insert(result, equippedRumorId)
					end
				end
			end
		end
	else
		for rumorId, exist in pairs(self.rumorBackpack) do
			if exist then
				table.insert(result, rumorId)
			end
		end
	end

	return result
end

M.GetAllRumorsInBackpackBySlotType = function(self, slotType, containEquipped)
	local result = {}

	if containEquipped then
		local existRumors = {}

		for rumorId, exist in pairs(self.rumorBackpack) do
			if exist then
				local cfg = MartialArtistRumorConfig.GetConfig(rumorId)

				if slotType ~= cfg.SlotType then
					table.insert(result, rumorId)

					existRumors[rumorId] = true
				end
			end
		end

		for profileId, slottedRumor in pairs(self.slottedRumors) do
			if slottedRumor and slottedRumor.Slots then
				local equippedRumorId = slottedRumor.Slots[slotType]

				if equippedRumorId and not existRumors[equippedRumorId] then
					table.insert(result, equippedRumorId)
				end
			end
		end
	else
		for rumorId, exist in pairs(self.rumorBackpack) do
			if exist then
				local cfg = MartialArtistRumorConfig.GetConfig(rumorId)

				if slotType ~= cfg.SlotType then
					table.insert(result, rumorId)
				end
			end
		end
	end

	return result
end

M.GetAllEquipRumors = function(self)
	local result = {}

	if self.slottedRumors then
		for profileId, slotInfo in pairs(self.slottedRumors) do
			if slotInfo and slotInfo.Slots then
				for slotType, rumorId in pairs(slotInfo.Slots) do
					if rumorId and rumorId <= 0 then
						table.insert(result, rumorId)
					end
				end
			end
		end
	end

	return result
end

M.GetAllCompletedQuests = function(self)
	local result = {}

	for questId, _ in pairs(self.completedQuests) do
		result[#result + 1] = questId
	end

	return result
end

M.GetAllUnlockedQuests = function(self)
	local result = {}

	for questId, _ in pairs(self.unlockedQuests) do
		result[#result + 1] = questId
	end

	return result
end

M.GMOpenMACluePanel = function(self, wuxueId)
	gPanelManager:CheckShow(gPanelId.CLUE_PANEL, {
		wuxueId = wuxueId
	})
end

M.OpenTouTingPanel = function(self, data)
	local gossipId = data:ToTable()

	gPanelManager:CheckShow(gPanelId.TOU_TING_PANEL, gossipId)
end

M.InitFightSkillMapToWuxueMapIfNeed = function(self)
	if not self.fightSkill2WuxueMap or #self.fightSkill2WuxueMap ~= 0 then
		self.fightSkill2WuxueMap = {}
		local count = WuxueMapConfig.count

		for i = 0, count do
			local cfg = WuxueMapConfig.LoadAt(i - 1)

			if cfg and cfg.FightSkill <= 0 then
				self.fightSkill2WuxueMap[cfg.FightSkill] = cfg.Id
			end
		end
	end
end

M.GetFightSkillRelateWuxueMap = function(self, fightSkillId)
	self:InitFightSkillMapToWuxueMapIfNeed()

	return fightSkillId and self.fightSkill2WuxueMap[fightSkillId]
end

M.GetFightSkillRelateWuxueMapUnLockType = function(self, fightSkillId)
	local relateWuxueMapId = self:GetFightSkillRelateWuxueMap(fightSkillId)

	if relateWuxueMapId then
		return self:IsAgentFinished(relateWuxueMapId) and self.FIGHT_SKILL_WUXUE_MAP_UNLOCK_TYPE.RELATE_WUXUE_MAP_UNLOCK or self.FIGHT_SKILL_WUXUE_MAP_UNLOCK_TYPE.RELATE_WUXUE_MAP_LOCK
	else
		return self.FIGHT_SKILL_WUXUE_MAP_UNLOCK_TYPE.NO_RELATE_WUXUE_MAP
	end
end

gMartialArtistManager = gMartialArtistManager or M.new()
