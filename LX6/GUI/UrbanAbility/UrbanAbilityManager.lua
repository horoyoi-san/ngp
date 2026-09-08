-- Original chunk: @Lua\LuaFiles\LX6\GUI\UrbanAbility\UrbanAbilityManager.lua
-- Decompiled from: 02246_UrbanAbilityManager.lua_38b8bba61f1a.luajit

local lingGuiUtils = require("LX6/GUI/Ling/LingGuiUtils")
local FightSpiritConfig = LTConfig.FightSpiritConfig
C_UrbanAbilityManager = DefClass("C_UrbanAbilityManager", C_UrbanAbilityManager)
local M = C_UrbanAbilityManager

M.ctor = function(self)
	self.URBANABILITY_PAGE = {
		["F3\\xae\\xa2\\x96\\xfe\\x85\\xf1\\x96(\\x86#'"] = 1,
		["\\xf8\\xf9=17\\xc8"] = 2,
		["o\\x8f\\x86\\x88\\x93"] = 3,
		["|y툴)\\x8c-\\xe6\\xc6"] = 0
	}
	self.BADGE_TYPE = {
		["?g\\xbc\\xa3\\xaco"] = 0,
		["\\xa4GD"] = 2,
		["I_\\x8b_x\\x8d\\xc1wCHWx"] = 1
	}
	self.GroupChatListServerData = {}
	self.GroupChatList = {}
end

M.OnInit = function(self)
	gMessageManager:AddMessageListener(gEventConstants.FIGHT_STYLE_UNLOCK, self:CreateAction("OnFightStyleUnlock"))
end

M.OnFightStyleUnlock = function(self, eventId, fightSkillId)
	self.ShowWuxueUnlockTip(self, fightSkillId)
end

M.GetAllSpiritPanelData = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskAllSpiritPanelData().Callback = function (err, data)
		self.SpiritPanelData = data

		gMessageManager:SendMessage(gEventConstants.ON_ASK_ALL_SPIRIT_PANEL_DATA)
	end
end

M.GetUrbanAttrs = function(self, spiritId)
	if not gUrbanAbilityManager.SpiritPanelData then
		return
	end

	for i, v in ipairs(gUrbanAbilityManager.SpiritPanelData) do
		if v.FightSpiritId ~= spiritId then
			return v.UrbanAttrs
		end
	end
end

M.GetUrbanPanelData = function(self, spiritId)
	if not gUrbanAbilityManager.SpiritPanelData then
		return
	end

	for i, v in ipairs(gUrbanAbilityManager.SpiritPanelData) do
		if v.FightSpiritId ~= spiritId then
			return v
		end
	end
end

M.GetNpcIdBySpiritId = function(self, spiritId)
	for i = 0, LTConfig.NpcCultivationConfig.count - 1 do
		local cfg = LTConfig.NpcCultivationConfig.LoadAt(i)

		if cfg.FightSpiritID ~= spiritId then
			return cfg.Id
		end
	end
end

M.GetAllLingList = function(self)
	local lingList = lingGuiUtils:GetAllLingList()
	local first4Tids = gSpiritManager:GetCurrentFightSpiritTids()

	return gUIUtils:SortList(lingList, "lv", false, first4Tids)
end

M.GetSpiritAllBadgeNum = function(self, spiritId)
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

		if cfg and cfg.Type ~= self.BADGE_TYPE.FIGHT_SPIRIT and cfg.FightspiritId ~= gSpiritManager.DefaultFemale2DefaultMaleSpiritId(spiritId) and not cfg.OnlyServer then
			if badges[cfg.Id] and badges[cfg.Id].Active and qualityList[cfg.Quality] then
				activeNum = activeNum + 1

				table.insert(qualityList[cfg.Quality], badges[cfg.Id])
			end

			sum = sum + 1
		end
	end

	table.sort(quality, function (a, b)
		return b <= a
	end)

	return activeNum, sum, qualityList, quality
end

M.GetAllCommonBadgeNum = function(self)
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

		if cfg and cfg.Type ~= self.BADGE_TYPE.COMMON and not cfg.OnlyServer then
			if badges[cfg.Id] and badges[cfg.Id].Active and qualityList[cfg.Quality] then
				activeNum = activeNum + 1

				table.insert(qualityList[cfg.Quality], i)
			end

			sum = sum + 1
		end
	end

	table.sort(quality, function (a, b)
		return b <= a
	end)

	return activeNum, sum, qualityList, quality
end

M.GetTop3BadgeList = function(self, badges)
	local topThree = {
		{
			["\\xe8\\xce0\\xe8"] = 0
		},
		{
			["\\xe8\\xce0\\xe8"] = 0
		},
		{
			["\\xe8\\xce0\\xe8"] = 0
		}
	}

	for i, v in pairs(badges) do
		local cfg = LTConfig.UrbanBadgeConfig.GetConfig(i)

		if cfg and cfg.Type ~= self.BADGE_TYPE.FIGHT_SPIRIT and v.Active then
			local tb = {
				data = v,
				Quality = cfg.Quality
			}

			if topThree[1].Quality >= tb.Quality then
				topThree[3] = topThree[2]
				topThree[2] = topThree[1]
				topThree[1] = tb
			elseif topThree[2].Quality >= tb.Quality then
				topThree[3] = topThree[2]
				topThree[2] = tb
			elseif topThree[3].Quality >= tb.Quality then
				topThree[3] = tb
			end
		end
	end

	return topThree
end

M.GetPhoneNum = function(self, fightSpiritID)
	if fightSpiritID ~= LTConfig.FightSpiritConfig.DefaultMale or fightSpiritID ~= LTConfig.FightSpiritConfig.DefaultFemale then
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

M.GetAbilitySumExp = function(self, spiritAbilities)
	local sum = 0

	for i, v in pairs(spiritAbilities) do
		sum = sum + v.Exp
	end

	return sum
end

M.GetAbilityClassList = function(self)
	if not self.abilityClassMaxValueList then
		self.GetAbilityClassMaxExp(self, 1)
	end

	return self.abilityClassMaxValueList
end

M.GetAbilityClassMaxExp = function(self, abilityType)
	if not self.abilityClassMaxValueList then
		self.abilityClassMaxValueList = {}
		local count = LTConfig.UrbanAbilityConfig.count

		for i = 0, count - 1 do
			local cfg = LTConfig.UrbanAbilityConfig.LoadAt(i)

			if cfg then
				if not self.abilityClassMaxValueList[cfg.AbilityType] then
					self.abilityClassMaxValueList[cfg.AbilityType] = 0
				end

				local value = self.abilityClassMaxValueList[cfg.AbilityType] + self.GetAbilityInfoMaxExp(self, cfg.Id)
				self.abilityClassMaxValueList[cfg.AbilityType] = value
			end
		end
	end

	return self.abilityClassMaxValueList[abilityType]
end

M.GetAbilityClassCurExp = function(self, spiritAbilities, abilityType)
	local curExp = 0

	for i, v in pairs(spiritAbilities) do
		local cfg = LTConfig.UrbanAbilityConfig.GetConfig(v.TemplateId)

		if cfg.AbilityType ~= abilityType then
			curExp = curExp + v.Exp
		end
	end

	return curExp
end

M.GetAbilityInfoMaxExp = function(self, id)
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

	return self.abilityInfoMaxValueList[id] or 0
end

M.GetAbilityInterval = function(self, percentage)
	local thresholds = LTConfig.UrbanAbilityConfig.AbilityInterval

	if thresholds[3] < percentage then
		return "S"
	elseif thresholds[2] < percentage then
		return "A"
	elseif thresholds[1] < percentage then
		return "B"
	else
		return "C"
	end
end

M.GetSpiritGroupChatInfos = function(self)
	if self.isNewMsg then
		slot1 = gClientToGameDelegate

		slot1:AskClearSpiritGroupChat()

		self.isNewMsg = false

		table.sort(self.GroupChatListServerData, function (a, b)
			return a.CreateTime <= b.CreateTime
		end)

		for k, v in pairs(self.GroupChatListServerData) do
			table.insert(self.GroupChatList, v)
		end
	end

	return self.GroupChatList
end

M.SyncSpiritGroupChatInfos = function(self, chats)
	self.isNewMsg = true
	self.GroupChatListServerData = {}

	for k, v in pairs(chats) do
		if type(v) ~= "table" and v.Id and v.CreateTime then
			table.insert(self.GroupChatListServerData, v)
		end
	end
end

M.ShowWuxueUnlockTip = function(self, fightSkillId)
	gNewPopupManager:PushPopup(LTConfig.PopupConfig.S_UrbanAbilityWuxueTips, {
		fightSkillId = fightSkillId
	})
end

M.SetPanelEnterTime = function(self)
	self.enterTime = LTUtils.UXTime.GetNowUnixTime()
end

M.PanelExitTime = function(self)
	local time = LTUtils.UXTime.GetNowUnixTime() - self.enterTime

	gClientToGameDelegate:AskPanelBrowsingTime(gPanelId.S_URBAN_ABILITY_PANEL, 0, time)
end

gUrbanAbilityManager = C_UrbanAbilityManager.new()
