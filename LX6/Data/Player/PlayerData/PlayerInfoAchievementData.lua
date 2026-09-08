-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerInfoAchievementData.lua
-- Decompiled from: 00094_PlayerInfoAchievementData.lua_a4a5c7fff269.luajit

C_PlayerInfoAchievementData = DefClass("C_PlayerInfoAchievementData", C_PlayerInfoAchievementData, C_PlayerDataBase)
local M = C_PlayerInfoAchievementData

M.InitPlayerInfo = function(self, info)
	local t = self.DataSet_Template
	t.UnlockedCountryList = info.InfoAchievement.UnlockedCountryList
	t.UnlockedQuestList = info.InfoAchievement.UnlockedQuestList
	t.CompletedSubQuestCnt = info.InfoAchievement.CompletedSubQuestCnt
	t.ChallengeRecordInfo = info.InfoAchievement.ChallengeRecordInfo
	t.NewChallengeRecordInfo = info.InfoAchievement.NewChallengeRecordInfo
	t.FirstKillEnemyRecord = info.InfoAchievement.FirstKillEnemyRecord
	t.UnlockInvestigateGalleryList = info.InfoAchievement.UnlockInvestigateGalleryList
	t.CountryReputationInfo = info.InfoAchievement.CountryReputationInfo
	t.FactionInfoDic = info.InfoAchievement.FactionInfoDic
	t.OccupiedInfluenceArea = info.InfoAchievement.OccupiedInfluenceArea
	t.ClientFactionInfo = info.InfoAchievement.ClientFactionInfo
	t.SceneFogMapPoiIds = info.InfoAchievement.SceneFogMapPoiIds
	t.AchievementInfos = info.InfoAchievement.AchievementInfos

	self.bindData:RefreshData(t)
end

M.OnLogOut = function(self)
	self.bindData:Clear()
end
