C_PlayerCacheInfoData = DefClass("C_PlayerCacheInfoData", C_PlayerCacheInfoData, C_PlayerDataBase)
local M = C_PlayerCacheInfoData

function M:OnInit()
	self.bindData.recommendationPlayers = nil
	self.bindData.dontShowPanelAgainKey = {}
	self.bindData.lastRecommendationTime = 0
	self.bindData.ignoreFavorChangeShow = false
end

function M:OnLogOut()
	self.bindData.recommendationPlayers = nil
	self.bindData.dontShowPanelAgainKey = {}
	self.bindData.lastRecommendationTime = 0
	self.bindData.ignoreFavorChangeShow = false
end
