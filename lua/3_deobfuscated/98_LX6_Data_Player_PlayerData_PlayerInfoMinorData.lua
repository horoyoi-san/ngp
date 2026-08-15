C_PlayerInfoMinorData = DefClass("C_PlayerInfoMinorData", C_PlayerInfoMinorData, C_PlayerDataBase)
local M = C_PlayerInfoMinorData

function M:InitPlayerInfo(info)
	local t = self.DataSet_Template
	t.fan123 = info.InfoMinor.Fan123
	t.fan12 = info.InfoMinor.Fan12
	t.yesterdayFan = self:ConvertToNumber(info.InfoMinor.YesterdayFan)
	t.level = self:ConvertToNumber(info.InfoMinor.Level)
	t.levelRewardList = info.InfoMinor.LevelRewards
	t.popularityInfo = info.InfoMinor.PopularityInfoNew
	t.computerUnlockInfo = info.InfoMinor.ComputerUnlockInfo
	t.playerInteractionActionInfo = info.InfoMinor.PlayerInteractionActionInfo
	t.Questionnaire = info.InfoMinor.Questionnaire
	t.planningBoardInfo = info.InfoMinor.PlanningBoardInfo
	t.hasShouChong = info.InfoMinor.ChargeInfo.HasFirstCharge
	t.hasShouChongReward = info.InfoMinor.ChargeInfo.HasFirstChargeReward
	t.MapPins = {
		Count = 0
	}

	if info.InfoMinor.MapPins then
		for i, v in pairs(info.InfoMinor.MapPins) do
			local mapPin = v

			if t.MapPins[mapPin.RaidId] == nil then
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
	t.PlayerInterActionInfo = info.InfoMinor.PlayerInterActionInfo
	t.NewGuideTeachInfos = {}

	for i = 1, info.InfoMinor.PlayerInfoGuide.NewGuideTeachInfos.Length do
		t.NewGuideTeachInfos[info.InfoMinor.PlayerInfoGuide.NewGuideTeachInfos[i]] = true
	end

	t.NewGuideTeachInfos.Count = info.InfoMinor.PlayerInfoGuide.NewGuideTeachInfos.Length
	t.RewardedGuideTeachInfos = {}

	for i = 1, info.InfoMinor.PlayerInfoGuide.RewardedGuideTeachInfos.Length do
		t.RewardedGuideTeachInfos[info.InfoMinor.PlayerInfoGuide.RewardedGuideTeachInfos[i]] = true
	end

	t.RewardedGuideTeachInfos.Count = info.InfoMinor.PlayerInfoGuide.RewardedGuideTeachInfos.Length
	t.FinishedGuides = {}

	for i = 1, info.InfoMinor.PlayerInfoGuide.FinishedGuides.Length do
		t.FinishedGuides[info.InfoMinor.PlayerInfoGuide.FinishedGuides[i]] = true
	end

	t.UnlockSystems = {}

	for i = 1, info.InfoMinor.PlayerInfoGuide.UnlockSystems.Length do
		t.UnlockSystems[info.InfoMinor.PlayerInfoGuide.UnlockSystems[i]] = true
	end

	t.playerTakeAwayInfo = info.InfoMinor.TakeawayInfo
	t.PlayerFashionsInfo = info.InfoMinor.PlayerFashionsInfo
	t.ModuleEventProgressInfoDict = info.InfoMinor.ModuleEventProgressInfoDict
	t.Badges = gSpiritManager:FilterBadge(info.InfoMinor.Badges)

	self.bindData:RefreshData(t)
	gMessageManager:SendMessage(gEventConstants.DAILY_SCHEDULE_INFO_REFRESH)
	gLinkManager:OnGetMatchInfo(info.InfoMinor.MatchInfo)
	gNpcDaliyManager:OnSyncNpcTimeTableInfos(info.InfoMinor.FavorNpcDailyScheduleInfos)
	gGFManager:RemoveGuideTriggers(t.FinishedGuides)
	gDropManager:OnSyncDropLimitInfo(info.InfoMinor.DropLimitCount)
	gMainMenuMgr:SetUnLockSystems()
end

function M:ConvertToNumber(value)
	value = value or 0

	if type(value) == "userdata" then
		value = tostring(value)
		value = tonumber(value)
	end

	return value
end

function M:OnLogOut()
	self.bindData:Clear()
end
