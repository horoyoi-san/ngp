local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
C_LivehouseGameEndPanelStore = DefClass("C_LivehouseGameEndPanelStore", C_LivehouseGameEndPanelStore, C_StoreGroup)
GroupName2Class.LivehouseGameEndPanelStore = C_LivehouseGameEndPanelStore
local M = C_LivehouseGameEndPanelStore

function M:ctor()
	return
end

function M:OnAwake()
	self.msgEvents = {
		[gEventConstants.LIVEHOUSE_CLOSE_END_PANEL] = self:CreateAction("EndPanel"),
		[gEventConstants.LIVEHOUSE_SHOW_GM_TOOL] = self:CreateAction("EndPanel")
	}

	self:RegisterMessageEvents(self.msgEvents)

	local EffectType = gMusicGameManager.EffectType
	self.ResultName = {
		[EffectType.Perfect] = LTConfig.TextScriptTextConfig.GetConfig(89900820).Text,
		[EffectType.Great] = LTConfig.TextScriptTextConfig.GetConfig(89900298).Text,
		[EffectType.Miss] = "Miss"
	}
end

function M:OnEnable()
	return
end

function M:OnStart()
	return
end

function M:OnDisable()
	return
end

function M:OnDestroy()
	self:ClearMessageEvents()
	self:ClearDataSetEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.liveHouseMusicId = data and data.id
	self.liveHouseId = data and data.liveHouseId
	local difficulty = data and data.difficulty
	self.bindData.difficultyType = (difficulty or 1) - 1
	self.musicUuid = data and data.musicUuid
	local cfg = LivehouseMusicConfig.GetConfig(self.liveHouseMusicId)

	if cfg then
		self.bindData.bgmName = cfg.Name
	end

	self:SetScoreList()
	self:ScoreResult(self.liveHouseMusicId)

	self.npcInfo = gMusicGameManager.NpcDailyList[gMusicGameManager.InviteNpcId]
end

function M:OnClose()
	return
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:SetScoreList()
	local EffectType = gMusicGameManager.EffectType
	self.bindData.perfectName = self.ResultName[EffectType.Perfect]
	self.bindData.greatName = self.ResultName[EffectType.Great]
	self.bindData.missName = self.ResultName[EffectType.Miss]
	self.bindData.perfectCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Perfect)
	self.bindData.greatCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Great)
	self.bindData.missCount = gMusicGameManager:GetRecordMusicCountByType(self.liveHouseMusicId, EffectType.Miss)
	self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(self.liveHouseMusicId)
end

function M:ScoreResult(liveHouseMusicId)
	self.bindData.rankLevel = gMusicGameManager:GetScoreLevel(liveHouseMusicId)
	self.bindData.isFullCombo = gMusicGameManager:IsFullCombo(liveHouseMusicId)
	self.bindData.isShowReward = self.bindData.rankLevel < 3
	self.bindData.finishPercent = gMusicGameManager:GetMusicPercent(liveHouseMusicId)
end

function M:EndPanel()
	local cfg = LivehouseMusicConfig.GetConfig(self.liveHouseMusicId)

	if cfg then
		local curScore = gMusicGameManager:GetScoreById(self.liveHouseMusicId)
		local clipName = nil

		if cfg.EndJumpTimelineClip then
			for i = 1, #cfg.EndJumpTimelineClip do
				if cfg.EndJumpTimelineClip[i].score <= curScore then
					clipName = cfg.EndJumpTimelineClip[i].ClipName
				end
			end
		end

		if clipName then
			gTimelineManager:Timeline_JumpTo(cfg.TimeineName, clipName)
		else
			print_error("curScore can not get timeline clip， curScore = " .. curScore)
		end

		gMusicGameManager.InviteNpcId = 0

		if self.musicUuid and self.musicUuid > 0 then
			gSoundMgr:StopSound(self.musicUuid)
		end

		gPanelManager:Close(gPanelId.LIVEHOUSE_GAME_END_PANEL)
	end
end
