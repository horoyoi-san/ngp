local lingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local FightSpiritConfig = LTConfig.FightSpiritConfig
C_UrbanAbilityManager = DefClass("C_UrbanAbilityManager", C_UrbanAbilityManager)
local M = C_UrbanAbilityManager

function M:ctor()
	self.URBANABILITY_PAGE = {
		BADGE = 3,
		BASIC_FEATURE = 1,
		HOME = 0,
		OCCUPATION = 2
	}
	self.BADGE_TYPE = {
		COMMON = 0,
		JOB = 2,
		FIGHT_SPIRIT = 1
	}
	self.GroupChatListServerData = {}
	self.GroupChatList = {}
end

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.FIGHT_STYLE_UNLOCK, self:CreateAction("OnFightStyleUnlock"))
end

function M:OnFightStyleUnlock(eventId, fightSkillId)
	self:ShowWuxueUnlockTip(fightSkillId)
end

function M:GetAllSpiritPanelData()
	gClientToGameDelegate:AskAllSpiritPanelData().Callback = function (err, data)
		self.SpiritPanelData = data

		gMessageManager:SendMessage(gEventConstants.ON_ASK_ALL_SPIRIT_PANEL_DATA)
	end
end

function M:GetUrbanAttrs(spiritId)
	if not gUrbanAbilityManager.SpiritPanelData then
		return
	end

	for i, v in ipairs(gUrbanAbilityManager.SpiritPanelData) do
		if v.FightSpiritId == spiritId then
			return v.UrbanAttrs
		end
	end
end

function M:GetUrbanPanelData(spiritId)
	if not gUrbanAbilityManager.SpiritPanelData then
		return
	end

	for i, v in ipairs(gUrbanAbilityManager.SpiritPanelData) do
		if v.FightSpiritId == spiritId then
			return v
		end
	end
end

function M:GetCharacteristic(spiritId)
	local list = {}

	for i = 0, LTConfig.FightSpiritCharacteristicConfig.count - 1 do
		local cfg = LTConfig.FightSpiritCharacteristicConfig.LoadAt(i)

		for i, v in ipairs(cfg.FightSpiritId) do
			if spiritId == v then
				table.insert(list, cfg)
			end
		end
	end

	return list
end

function M:GetNpcIdBySpiritId(spiritId)
	for i = 0, LTConfig.NpcCultivationConfig.count - 1 do
		local cfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if cfg.FightSpiritID == spiritId then
			return cfg.Id
		end
	end
end

function M:GetAllLingList()
	local lingList = lingGuiUtils:GetAllLingList()
	local first4Tids = gSpiritManager:GetCurrentFightSpiritTids()

	return gUIUtils:SortList(lingList, "lv", false, first4Tids)
end

function M:GetSpiritAllBadgeNum(spiritId)
	local activeNum = 0
	local sum = 0
	local qualityList = {
		{},
		{},
		{},
		{}
	}
	local quality = {
		1,
		2,
		3,
		4
	}
	local badges = gSpiritManager:GetSpirit(spiritId).SpiritInfo.InfoBadge.Badges

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and cfg.Type == self.BADGE_TYPE.FIGHT_SPIRIT and cfg.FightspiritId == spiritId and not cfg.OnlyServer then
			if badges[cfg.Id] and badges[cfg.Id].Active and qualityList[cfg.Quality] then
				activeNum = activeNum + 1

				table.insert(qualityList[cfg.Quality], badges[cfg.Id])
			end

			sum = sum + 1
		end
	end

	table.sort(quality, function (a, b)
		return b < a
	end)

	return activeNum, sum, qualityList, quality
end

function M:GetAllCommonBadgeNum()
	local activeNum = 0
	local sum = 0
	local qualityList = {
		{},
		{},
		{},
		{}
	}
	local quality = {
		1,
		2,
		3,
		4
	}
	local badges = gPlayerManager.infoMinor.bindData.Badges

	for i = 0, LTConfig.UrbanBadgeConfig.count - 1 do
		local cfg = LTConfig.UrbanBadgeConfig.LoadAt(i)

		if cfg and cfg.Type == self.BADGE_TYPE.COMMON and not cfg.OnlyServer then
			if badges[cfg.Id] and badges[cfg.Id].Active and qualityList[cfg.Quality] then
				activeNum = activeNum + 1

				table.insert(qualityList[cfg.Quality], i)
			end

			sum = sum + 1
		end
	end

	table.sort(quality, function (a, b)
		return b < a
	end)

	return activeNum, sum, qualityList, quality
end

function M:GetSpiritAbilityLevelSum(spiritAbilities)
	local num = 0

	for i, v in pairs(spiritAbilities) do
		num = num + v.Level
	end

	return num
end

function M:GetTop3BadgeList(badges)
	local topThree = {
		{
			Quality = 0
		},
		{
			Quality = 0
		},
		{
			Quality = 0
		}
	}

	for i, v in pairs(badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(i)

		if cfg and cfg.Type == self.BADGE_TYPE.FIGHT_SPIRIT and v.Active then
			local tb = {
				data = v,
				Quality = cfg.Quality
			}

			if topThree[1].Quality < tb.Quality then
				topThree[3] = topThree[2]
				topThree[2] = topThree[1]
				topThree[1] = tb
			elseif topThree[2].Quality < tb.Quality then
				topThree[3] = topThree[2]
				topThree[2] = tb
			elseif topThree[3].Quality < tb.Quality then
				topThree[3] = tb
			end
		end
	end

	return topThree
end

function M:GetPhoneNum(fightSpiritID)
	if fightSpiritID == LTConfig.FightSpiritConfig.DefaultMale or fightSpiritID == LTConfig.FightSpiritConfig.DefaultFemale then
		local cfg = LTConfig.PhoneContactConfig.GetConfig(LTConfig.PhoneContactConfig.Player)

		if cfg then
			return cfg.PhoneNumber
		end

		return
	end

	if self.spiritPhoneNumList then
		return self.spiritPhoneNumList[fightSpiritID]
	end

	self.spiritPhoneNumList = {}
	local count = LTConfig.PhoneContactConfig.count

	for i = 0, count - 1 do
		local phoneCfg = LTConfig.PhoneContactConfig.LoadAt(i)

		if phoneCfg.RelatedNpcId then
			local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(phoneCfg.RelatedNpcId)

			if npcCfg then
				self.spiritPhoneNumList[npcCfg.FightSpiritID] = phoneCfg.PhoneNumber
			end
		end
	end

	return self.spiritPhoneNumList[fightSpiritID]
end

function M:GetAbilitySumExp(spiritAbilities)
	local sum = 0

	for i, v in pairs(spiritAbilities) do
		sum = sum + v.Exp
	end

	return sum
end

function M:GetAbilityClassList()
	if not self.abilityClassMaxValueList then
		self:GetAbilityClassMaxExp(1)
	end

	return self.abilityClassMaxValueList
end

function M:GetAbilityClassMaxExp(abilityType)
	if not self.abilityClassMaxValueList then
		self.abilityClassMaxValueList = {}
		local count = LTConfig.UrbanAbilityConfig.count

		for i = 0, count - 1 do
			local cfg = LTConfig.UrbanAbilityConfig.LoadAt(i)

			if cfg then
				if not self.abilityClassMaxValueList[cfg.AbilityType] then
					self.abilityClassMaxValueList[cfg.AbilityType] = 0
				end

				local value = self.abilityClassMaxValueList[cfg.AbilityType] + self:GetAbilityInfoMaxExp(cfg.Id)
				self.abilityClassMaxValueList[cfg.AbilityType] = value
			end
		end
	end

	return self.abilityClassMaxValueList[abilityType]
end

function M:GetAbilityClassCurExp(spiritAbilities, abilityType)
	local curExp = 0

	for i, v in pairs(spiritAbilities) do
		local cfg = LTConfig.UrbanAbilityConfig.GetConfig(v.TemplateId)

		if cfg.AbilityType == abilityType then
			curExp = curExp + v.Exp
		end
	end

	return curExp
end

function M:GetAbilityInfoMaxExp(id)
	if not self.abilityInfoMaxValueList then
		self.abilityInfoMaxValueList = {}
		local count = LTConfig.UrbanAbilityLevelUpExpConfig.count

		for i = 0, count - 1 do
			local cfg = LTConfig.UrbanAbilityLevelUpExpConfig.LoadAt(i)

			if cfg then
				local sumExp = 0
				local index = 1

				while cfg["Exp" .. index] do
					sumExp = sumExp + cfg["Exp" .. index]
					index = index + 1
				end

				self.abilityInfoMaxValueList[cfg.Id] = sumExp
			end
		end
	end

	return self.abilityInfoMaxValueList[id]
end

function M:GetAbilityInterval(percentage)
	local thresholds = LTConfig.UrbanAbilityConfig.AbilityInterval

	if thresholds[3] <= percentage then
		return "S"
	elseif thresholds[2] <= percentage then
		return "A"
	elseif thresholds[1] <= percentage then
		return "B"
	else
		return "C"
	end
end

function M:GetSpiritGroupChatInfos()
	if self.isNewMsg then
		gClientToGameDelegate:AskClearSpiritGroupChat()

		self.isNewMsg = false

		table.sort(self.GroupChatListServerData, function (a, b)
			return a.CreateTime < b.CreateTime
		end)

		for k, v in pairs(self.GroupChatListServerData) do
			table.insert(self.GroupChatList, v)
		end
	end

	return self.GroupChatList
end

function M:SyncSpiritGroupChatInfos(chats)
	self.isNewMsg = true
	self.GroupChatListServerData = {}

	for k, v in pairs(chats) do
		if type(v) == "table" and v.Id and v.CreateTime then
			table.insert(self.GroupChatListServerData, v)
		end
	end
end

function M:ShowWuxueUnlockTip(fightSkillId)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityWuxueTips, {
		fightSkillId = fightSkillId
	})
end

function M:SetPanelEnterTime()
	self.enterTime = LTUtils.UXTime.GetNowUnixTime()
end

function M:PanelExitTime()
	local time = LTUtils.UXTime.GetNowUnixTime() - self.enterTime

	gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.S_URBAN_ABILITY_PANEL, 0, time)
end

gUrbanAbilityManager = C_UrbanAbilityManager.new()
