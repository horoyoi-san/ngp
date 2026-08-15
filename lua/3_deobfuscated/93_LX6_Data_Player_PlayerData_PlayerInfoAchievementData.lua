C_PlayerInfoAchievementData = DefClass("C_PlayerInfoAchievementData", C_PlayerInfoAchievementData, C_PlayerDataBase)
local M = C_PlayerInfoAchievementData

function M:InitPlayerInfo(info)
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
	t.SceneFogMapPoiIds = info.InfoAchievement.SceneFogMapPoiIds

	self.bindData:RefreshData(t)
end

function M:OnLogOut()
	self.bindData:Clear()
end
