-- Original chunk: @Lua\LuaFiles\LX6\Data\Player\PlayerData\PlayerCacheInfoData.lua
-- Decompiled from: 00093_PlayerCacheInfoData.lua_6b21bbccc0c9.luajit

C_PlayerCacheInfoData = DefClass("C_PlayerCacheInfoData", C_PlayerCacheInfoData, C_PlayerDataBase)
local M = C_PlayerCacheInfoData

M.OnInit = function(self)
	self.bindData.recommendationPlayers = nil
	self.bindData.dontShowPanelAgainKey = {}
	self.bindData.lastRecommendationTime = 0
	self.bindData.ignoreFavorChangeShow = false
end

M.OnLogOut = function(self)
	self.bindData.recommendationPlayers = nil
	self.bindData.dontShowPanelAgainKey = {}
	self.bindData.lastRecommendationTime = 0
	self.bindData.ignoreFavorChangeShow = false
end
