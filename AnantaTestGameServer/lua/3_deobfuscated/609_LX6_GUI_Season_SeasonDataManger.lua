local SeasonRaidConfig = LTConfig.SeasonRaidConfig
local SeasonDataManager = {
	chaosLevel = 0,
	clientGrowupChaos = false,
	chaosValue = 0,
	currentAreaId = 0,
	buffIds = {},
	itemIds = {},
	pendingToChooseItemGroups = list:new(),
	currentAreaTargetCounters = {},
	talentData = {
		Point = 0,
		Talents = {}
	}
}

function SeasonDataManager:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.PANEL_ON_CLOSE, function (eventId, panelId)
		if panelId ~= gPanelId.S_CHOOSE_BUFF_PANEL then
			return
		end

		SeasonDataManager:CheckShowRecordChoosePanel()
	end)
end

function SeasonDataManager:OnBeforeSwitchScene(switchType)
	print("SeasonDataManager:OnBeforeSwitchScene, " .. tostring(switchType))
	self:Cleanup()
end

function SeasonDataManager:Cleanup()
	self:ClearDatas()

	self.chaosLevel = 0
	self.chaosValue = 0
	self.currentAreaId = 0

	table.clear(self.currentAreaTargetCounters)
	self.pendingToChooseItemGroups:clear()

	self.talentData = {
		Point = 0,
		Talents = {}
	}
end

function SeasonDataManager:ClearDatas()
	table.clear(self.buffIds)
	table.clear(self.itemIds)
end

function SeasonDataManager:AppendData(buffIds, itemIds)
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

function SeasonDataManager:GetFightSpiritIds()
	return gBattleSpiritMgr:GetBattleSpiritList()
end

function SeasonDataManager:UpdateChaosValueFromServer(value, timestamp)
	local previousValue = self.chaosValue
	local previousLevel = self.chaosLevel
	self.chaosValue = value
	self.chaosLevel = math.floor(value / SeasonRaidConfig.ChaosLevelMaxValue)
	local eventParams = {
		value = self.chaosValue,
		level = self.chaosLevel,
		hasValueChanged = self.chaosValue ~= previousValue,
		hasLevelChanged = self.chaosLevel ~= previousLevel
	}

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_CHAOS_CHANGED, eventParams)
end

function SeasonDataManager:OnUpdate()
	if self.clientGrowupChaos then
		self:UpdateChaosValueFromServer(self.chaosValue + 5 * SeasonRaidConfig.ChaosAutoAddPerSecond * Time.deltaTime)
	end
end

function SeasonDataManager:CheckShowRecordChoosePanel()
	if self.pendingToChooseItemGroups:head() == nil then
		return
	end

	if gPanelManager:IsPanelShowing(gPanelId.S_CHOOSE_BUFF_PANEL) then
		return
	end

	gPanelManager:CheckShow(gPanelId.S_CHOOSE_BUFF_PANEL, {
		itemIds = self.pendingToChooseItemGroups:shift()
	})
end

function SeasonDataManager:UpdateCurrentArea(areaId)
	print(gString.Format("UpdateCurrentArea: %d", areaId))

	self.currentAreaId = areaId

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_AREA_TARGETS_CHANGED)
end

function SeasonDataManager:UpdateAreaTargetCounterDatas(data)
	print(gString.Format("UpdateAreaTargetCounterDatas: count%d", #table.keys(data)))

	for targetId, count in pairs(data) do
		self.currentAreaTargetCounters[targetId] = count
	end

	gMessageManager:SendMessage(gEventConstants.SEASON_RAID_AREA_TARGETS_CHANGED)
end

function SeasonDataManager:GetTargetCount(areaTargetId)
	return self.currentAreaTargetCounters[areaTargetId] or 0
end

function SeasonDataManager:AskEnableTalent(id, cb)
	if self.talentData and self.talentData.Talents and table.contains(self.talentData.Talents, id) then
		cb(0)

		return
	end

	gClientToGameDelegate:AskEnableTalent(id).Callback = function (err)
		if err ~= LTConfig.MessageConfig.Ok then
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
