-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoMinorData.lua
-- Decompiled from: 00099_PlayerInfoMinorData.lua_bcd938f99f69.luajit

C_PlayerInfoMinorData = DefClass("C_PlayerInfoMinorData", C_PlayerInfoMinorData, C_PlayerDataBase)
local M = C_PlayerInfoMinorData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	t.fan123 = info.InfoMinor.Fan123
	t.fan12 = info.InfoMinor.Fan12
	t.yesterdayFan = self.ConvertToNumber(self, info.InfoMinor.YesterdayFan)
	t.growthStageId = info.InfoMinor.StageLv
	t.weeklyFanGrowth = info.InfoMinor.WeeklyFanGrowth
	t.receivedStageLvRewards = info.InfoMinor.ReceivedStageLvRewards
	t.level = self.ConvertToNumber(self, info.InfoMinor.Level)
	t.levelRewardList = info.InfoMinor.LevelRewards
	t.popularityInfo = info.InfoMinor.PopularityInfoNew
	t.computerUnlockInfo = info.InfoMinor.ComputerUnlockInfo
	t.playerInteractionActionInfo = info.InfoMinor.PlayerInteractionActionInfo
	t.Questionnaire = info.InfoMinor.Questionnaire
	t.planningBoardInfo = info.InfoMinor.PlanningBoardInfo
	t.ChargeInfo = info.InfoMinor.ChargeInfo
	t.extractionShooterInfo = info.InfoMinor.PlayerExtractionShooterInfo
	t.playerLinkPlanningBoardInfo = info.InfoMinor.PlayerLinkPlanningBoardInfo
	t.playerTuiteInfo = info.InfoMinor.PlayerTuiteInfo
	t.playerInfoAtmosphereGameplay = info.InfoMinor.PlayerInfoAtmosphereGameplay
	t.ChefUnlockInfo = info.InfoMinor.ChefUnlockInfo
	t.MapPins = {
		["n\\xa1\\xb7\\xa1\\xa2"] = 0
	}

	if info.InfoMinor.MapPins then
		for i, v in pairs(info.InfoMinor.MapPins) do
			local mapPin = v

			if t.MapPins[mapPin.RaidId] ~= nil then
				t.MapPins[mapPin.RaidId] = {}
			end

			table.insert(t.MapPins[mapPin.RaidId], {
				Position = Vector3.New(mapPin.Position.X, mapPin.Position.Y, mapPin.Position.Z),
				PinType = mapPin.Type,
				Id = i
			})

			t.MapPins.Count = t.MapPins.Count + 1
		end
	end

	t.beginnerInfo = {}
	t.NgpushSetting = info.InfoMinor.NgpushSetting
	t.MiniGame = info.InfoMinor.MiniGame
	t.DownloadApartReward = info.InfoMinor.DownloadApartReward
	t.housesInfo = info.InfoMinor.housesInfo
	t.spiritPhoneInfos = info.InfoMinor.PlayerPhoneInfo.SpiritPhoneInfos
	t.playerInteractionActionInfo = info.InfoMinor.PlayerInteractionActionInfo
	t.playerCityPediaInfos = info.InfoMinor.PlayerCityPediaInfos
	t.downLoadAppIds = info.InfoMinor.PlayerPhoneInfo.DownLoadAppIds
	t.VehicleInfo = info.InfoMinor.VehicleInfo
	t.PlayerRadioSongsData = info.InfoMinor.PlayerRadioSongsData
	t.PlayerInterActionInfo = info.InfoMinor.PlayerInterActionInfo
	local playerInfoGuide = info.InfoMinor.PlayerInfoGuide
	t.NewGuideTeachInfos = {}

	for i = 1, playerInfoGuide.NewGuideTeachInfos.Length do
		t.NewGuideTeachInfos[playerInfoGuide.NewGuideTeachInfos[i]] = true
	end

	t.NewGuideTeachInfos.Count = playerInfoGuide.NewGuideTeachInfos.Length
	t.RewardedGuideTeachInfos = {}

	for i = 1, playerInfoGuide.RewardedGuideTeachInfos.Length do
		t.RewardedGuideTeachInfos[playerInfoGuide.RewardedGuideTeachInfos[i]] = true
	end

	t.RewardedGuideTeachInfos.Count = playerInfoGuide.RewardedGuideTeachInfos.Length
	t.FinishedGuides = {}

	for i = 1, playerInfoGuide.FinishedGuides.Length do
		t.FinishedGuides[playerInfoGuide.FinishedGuides[i]] = true
	end

	t.UnlockSystems = {}

	for i = 1, playerInfoGuide.UnlockSystems.Length do
		t.UnlockSystems[playerInfoGuide.UnlockSystems[i]] = true
	end

	t.playerTakeAwayInfo = info.InfoMinor.TakeawayInfo
	t.PlayerFashionsInfo = info.InfoMinor.PlayerFashionsInfo
	t.PlayerWeaponSkinInfo = info.InfoMinor.PlayerWeaponSkinInfo
	t.ModuleEventProgressInfoDict = info.InfoMinor.ModuleEventProgressInfoDict
	t.UniverseModuleEventProgressInfoDict = info.InfoMinor.UniverseModuleEventProgressInfoDict
	t.Badges = gSpiritManager:FilterBadge(info.InfoMinor.Badges)
	t.MallInfo = info.InfoMinor.MallInfo
	t.PlayerGiftInfo = info.InfoMinor.PlayerGiftInfo
	t.PlayerGachaInfos = info.InfoMinor.PlayerGachaInfos
	t.PlayerOCInfo = info.InfoMinor.PlayerOCInfo
	t.PlayerMeccaGrandpaPartsInfo = info.InfoMinor.PlayerMeccaGrandpaPartsInfo
	t.PlayerScenarioInfos = info.InfoMinor.PlayerScenarioInfos
	t.submitItemDataDict = info.InfoMinor.InfoSubmitItem and info.InfoMinor.InfoSubmitItem.SubmitItemDataDict or {}
	t.FishingInfo = info.InfoMinor.FishingInfo
	t.ChatInfo = info.InfoMinor.ChatInfo
	local playerLikeInfo = info.InfoMinor.PlayerLikeInfo
	t.PlayerLikeInfo = {
		LastResetTime = playerLikeInfo and self:ConvertToNumber(playerLikeInfo.LastResetTime) or 0,
		HomepageLikes = {}
	}

	if playerLikeInfo and playerLikeInfo.HomepageLikes then
		for pid in pairs(playerLikeInfo.HomepageLikes) do
			t.PlayerLikeInfo.HomepageLikes[ulong.tostring(pid)] = true
		end
	end

	self.bindData:RefreshData(t)

	if info.InfoMinor.SettingInfo and info.InfoMinor.SettingInfo.SettingDict and gSettingServerManager then
		gSettingServerManager:InitFromServer(info.InfoMinor.SettingInfo.SettingDict)
	end

	gMessageManager:SendMessage(gEventConstants.DAILY_SCHEDULE_INFO_REFRESH)
	gLinkManager:OnGetMatchInfo(info.InfoMinor.MatchInfo)
	gNpcDaliyManager:OnSyncNpcTimeTableInfos(info.InfoMinor.FavorNpcDailyScheduleInfos)
	gDropManager:OnSyncDropLimitInfo(info.InfoMinor.DropLimitCount)
	gOCMgr:OnInitOCInfo(info.InfoMinor.PlayerOCInfo)
	gMainMenuMgr:SetUnLockSystems()
	gHudRecommendMgr:SyncAllRecommend(info.InfoMinor.HUDRecommendDict)
end

M.ConvertToNumber = function(self, value)
	value = value or 0

	if type(value) ~= "userdata" then
		value = tostring(value)
		value = tonumber(value)
	end

	return value
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
