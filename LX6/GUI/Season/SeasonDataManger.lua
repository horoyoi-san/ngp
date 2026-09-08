-- Original chunk: @Lua\LuaFiles\LX6\GUI\Season\SeasonDataManger.lua
-- Decompiled from: 02172_SeasonDataManger.lua_3ef8f94f8447.luajit

local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local SeasonDataManager = {
	["PRϲ\\x97$\\xbd\\xcc\\xe4"] = 0,
	["w\\xf0.\\xe9'#\\xd1n7\\xc0[\\xafC\\xc9\\xf5"] = false,
	["PRϲ\\x97>\\xb9\\xdc\\xed"] = 0,
	["\\xf6M>\\xde\\x97S\\xa4W\\x99\\xb2"] = 0,
	buffIds = {},
	itemIds = {}
}
slot2 = list
SeasonDataManager.pendingToChooseItemGroups = slot2:new()
SeasonDataManager.currentAreaTargetCounters = {}
SeasonDataManager.talentData = {
	["}\\xa1\\xab\\xa1\\xa2"] = 0,
	Talents = {}
}

SeasonDataManager.OnInit = function(self)
	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, function (eventId, panelId)
		if panelId == gPanelId.S_CHOOSE_BUFF_PANEL then
			return
		end

		SeasonDataManager:CheckShowRecordChoosePanel()
	end)
end

SeasonDataManager.OnBeforeSwitchScene = function(self, switchType)
	print("SeasonDataManager:OnBeforeSwitchScene, " .. tostring(switchType))
	self:Cleanup()
end

SeasonDataManager.Cleanup = function(self)
	self:ClearDatas()

	self.chaosLevel = 0
	self.chaosValue = 0
	self.currentAreaId = 0

	table.clear(self.currentAreaTargetCounters)

	slot1 = self.pendingToChooseItemGroups

	slot1:clear()

	self.talentData = {
		["}\\xa1\\xab\\xa1\\xa2"] = 0,
		Talents = {}
	}
end

SeasonDataManager.ClearDatas = function(self)
	table.clear(self.buffIds)
	table.clear(self.itemIds)
end

SeasonDataManager.AppendData = function(self, buffIds, itemIds)
	if buffIds then
		for _, id in ipairs(buffIds) do
			table.insert(self.buffIds, id)
		end
	end

	if itemIds then
		for _, id in ipairs(itemIds) do
			table.insert(self.itemIds, id)
		end
	end
end

SeasonDataManager.GetFightSpiritIds = function(self)
	return gBattleSpiritMgr:GetBattleSpiritList()
end

SeasonDataManager.UpdateChaosValueFromServer = function(self, value, timestamp)
	local previousValue = self.chaosValue
	local previousLevel = self.chaosLevel
	self.chaosValue = value
	self.chaosLevel = math.floor(value / SeasonRaidConfig.ChaosLevelMaxValue)
	local eventParams = {
		value = self.chaosValue,
		level = self.chaosLevel,
		hasValueChanged = self.chaosValue == previousValue,
		hasLevelChanged = self.chaosLevel == previousLevel
	}

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_CHAOS_CHANGED, eventParams)
end

SeasonDataManager.OnUpdate = function(self)
	if self.clientGrowupChaos then
		self:UpdateChaosValueFromServer(self.chaosValue + 5 * SeasonRaidConfig.ChaosAutoAddPerSecond * Time.deltaTime)
	end
end

SeasonDataManager.CheckShowRecordChoosePanel = function(self)
	if self.pendingToChooseItemGroups:head() ~= nil then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_CHOOSE_BUFF_PANEL) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_CHOOSE_BUFF_PANEL, {
		itemIds = self.pendingToChooseItemGroups:shift()
	})
end

SeasonDataManager.UpdateCurrentArea = function(self, areaId)
	print(gString.Format("UpdateCurrentArea: %d", areaId))

	self.currentAreaId = areaId

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_AREA_TARGETS_CHANGED)
end

SeasonDataManager.UpdateAreaTargetCounterDatas = function(self, data)
	print(gString.Format("UpdateAreaTargetCounterDatas: count%d", #table.keys(data)))

	for targetId, count in pairs(data) do
		self.currentAreaTargetCounters[targetId] = count
	end

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_AREA_TARGETS_CHANGED)
end

SeasonDataManager.GetTargetCount = function(self, areaTargetId)
	return self.currentAreaTargetCounters[areaTargetId] or 0
end

SeasonDataManager.AskEnableTalent = function(self, id, cb)
	if self.talentData and self.talentData.Talents and table.contains(self.talentData.Talents, id) then
		cb(0)

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskEnableTalent(id).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			if cb then
				cb(err)
			end

			return
		end

		local talentConfig = LTConfig.SeasonRaidTalentConfig.GetConfig(id)

		if talentConfig then
			self.talentData.Point = self.talentData.Point - talentConfig.CostPoint
		end

		table.insert(self.talentData.Talents, id)
		gMessageManager:SendMessage(gEventConstants.SEASON_RAID_TALENT_DATA_CHANGED)
		cb(0)
	end
end

gSeasonDataMgr = SeasonDataManager
