-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\LivehouseGameEndPanelStore.lua
-- Decompiled from: 01782_LivehouseGameEndPanelStore.lua_33dfd21d020b.luajit

local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local LivehouseConfig = LTConfig.LivehouseConfig
local RadioSongsConfig = LTConfig.RadioSongsConfig
C_LivehouseGameEndPanelStore = DefClass("C_LivehouseGameEndPanelStore", C_LivehouseGameEndPanelStore, C_StoreGroup)
GroupName2Class.LivehouseGameEndPanelStore = C_LivehouseGameEndPanelStore
local M = C_LivehouseGameEndPanelStore

M.ctor = function(self)
end

M.OnAwake = function(self)
	self.RegisterMessageEvents(self, {})

	local EffectType = gMusicGameManager.EffectType
	self.ResultName = {
		[EffectType.Perfect] = LTConfig.TextScriptTextConfig.GetConfig(89900820).Text,
		[EffectType.Great] = LTConfig.TextScriptTextConfig.GetConfig(89900298).Text,
		[EffectType.Miss] = "Miss"
	}
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.ClearMessageEvents(self)
	self.ClearDataSetEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.liveHouseMusicId = data and data.id
	self.liveHouseId = data and data.liveHouseId
	local difficulty = data and data.difficulty
	self.bindData.difficultyType = (difficulty or 1) - 1
	self.musicUuid = data and data.musicUuid
	local livehouseCfg = LivehouseConfig.GetConfig(self.liveHouseId)
	local radioSongsCfg = livehouseCfg and RadioSongsConfig.GetConfig(livehouseCfg.RadioSongsID)
	self.bindData.bgmName = radioSongsCfg and radioSongsCfg.RadioSong or ""

	self:SetScoreList()
	self:ScoreResult(self.liveHouseMusicId)

	self.npcInfo = gMusicGameManager.NpcDailyList[gMusicGameManager.InviteNpcId]
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.SetScoreList = function(self)
	local EffectType = gMusicGameManager.EffectType
	self.bindData.perfectName = self.ResultName[EffectType.Perfect]
	self.bindData.greatName = self.ResultName[EffectType.Great]
	self.bindData.missName = self.ResultName[EffectType.Miss]
	self.bindData.perfectCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Perfect)
	self.bindData.greatCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Great)
	self.bindData.missCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Miss)
	self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(self.liveHouseMusicId)
end

M.ScoreResult = function(self, liveHouseMusicId)
	self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(liveHouseMusicId)
	self.bindData.isFullCombo = gMusicGameManager:IsFullCombo(liveHouseMusicId)
	self.bindData.isShowReward = self.bindData.rankLevel <= 3
	self.bindData.finishPercent = gMusicGameManager:GetMusicPercent(liveHouseMusicId)
end
