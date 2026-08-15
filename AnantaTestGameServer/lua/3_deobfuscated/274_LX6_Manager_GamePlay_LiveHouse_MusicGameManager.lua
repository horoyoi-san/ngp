local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local LivehouseNPCdailyConfig = LTConfig.LivehouseNPCdailyConfig
local Formula_cs = require("LuaGen/AutoGen/Formula_cs")
local FightSpiritConfig = LTConfig.FightSpiritConfig

if not gMusicGameManager then
	local M = {
		gridCountPerBpm = 0,
		TrackCount = 6,
		gridCountPerSecond = 0,
		gridCountPerBar = 24,
		perBarTime = 0,
		generateGridTime = 0,
		InviteNpcId = 0,
		GMFullPerfect = false,
		noteSpeed = 400,
		Bpm = 60,
		MusicPlayState = {
			Stop = 2,
			Play = 0,
			Pause = 1
		},
		PointType = {
			Double = 3,
			Single = 1,
			LongPress = 2
		},
		musicInfo = {
			gridLength = 0
		},
		EffectType = {
			Miss = 3,
			LongPress = 4,
			Great = 2,
			Perfect = 1,
			QteMiss = 6,
			Click = 0,
			QteClick = 5
		},
		SoundType = {
			Miss = 3,
			Special = 4,
			Great = 2,
			Perfect = 1
		},
		RecordMusicInfo = {},
		NpcDailyList = {},
		EditNoteList = {},
		RecordNoteList = {},
		DeleteNoteList = {}
	}
end

function M:OnInit()
	self:InitNpcDailyList()
end

function M:OnBeforeSwitchScene(switchType)
	if switchType ~= gSwitchSceneType.KickToLogin then
		return
	end

	self.RecordMusicInfo = {}
	self.InviteNpcId = 0
end

function M:InitNpcDailyList()
	self.NpcDailyList = {}

	for index = 0, LivehouseNPCdailyConfig.count - 1 do
		local cfg = LivehouseNPCdailyConfig.LoadAt(index)
		self.NpcDailyList[cfg.Npcid] = cfg
	end
end

function M:GetRecordMusicCountByType(id, type)
	if table.isNilOrEmpty(self.RecordMusicInfo[id]) then
		return 0
	end

	if type == self.EffectType.Perfect then
		return self.RecordMusicInfo[id].PerfectCount or 0
	elseif type == self.EffectType.Great then
		return self.RecordMusicInfo[id].GreatCount or 0
	elseif type == self.EffectType.Miss then
		return self.RecordMusicInfo[id].MissCount or 0
	end
end

function M:GetScoreById(id)
	if table.isNilOrEmpty(self.RecordMusicInfo[id]) then
		return 0
	end

	local tapScore = LivehouseConfig.TapScore
	local score = 0
	score = score + self.RecordMusicInfo[id].PerfectCount * tapScore.perfecttapscore
	score = score + self.RecordMusicInfo[id].GreatCount * tapScore.successtapscore
	score = score + self.RecordMusicInfo[id].MissCount * tapScore.misstapscore
	score = score + self.RecordMusicInfo[id].SpecialCount * tapScore.specialtapscore

	return score
end

function M:GetMusicPercent(liveHouseMusicId)
	local playerScore = gMusicGameManager:GetScoreById(liveHouseMusicId)

	if self.RecordMusicInfo[liveHouseMusicId] then
		local allCount = self.RecordMusicInfo[liveHouseMusicId].PerfectCount + self.RecordMusicInfo[liveHouseMusicId].GreatCount + self.RecordMusicInfo[liveHouseMusicId].MissCount

		if self.RecordMusicInfo[liveHouseMusicId].allCount and self.RecordMusicInfo[liveHouseMusicId].allCount > 0 and allCount < self.RecordMusicInfo[liveHouseMusicId].allCount then
			allCount = self.RecordMusicInfo[liveHouseMusicId].allCount
		end

		local percent = playerScore / (allCount * LivehouseConfig.TapScore.perfecttapscore) * 100

		return percent < 100 and gString.Format("%.1f", percent < 100 and percent) or "100"
	end

	return ""
end

function M:GetScoreLevel(liveHouseMusicId)
	local score = self:GetScoreById(liveHouseMusicId)
	local cfg = LivehouseMusicConfig.GetConfig(liveHouseMusicId)
	local scoreLevel = 0

	if not self:IsFinishMusic(liveHouseMusicId) then
		return #cfg.finalscore - 1
	end

	for i = 1, #cfg.finalscore do
		if cfg.finalscore[i].score <= score and (scoreLevel == 0 or i < scoreLevel) then
			scoreLevel = i
		end
	end

	return scoreLevel - 1
end

function M:IsFullCombo(id)
	if table.isNilOrEmpty(self.RecordMusicInfo[id]) then
		return false
	end

	return self.RecordMusicInfo[id].MissCount == 0 and self:IsFinishMusic(id)
end

function M:IsFinishMusic(liveHouseMusicId)
	local isFinish = false

	if self.RecordMusicInfo[liveHouseMusicId] and self.RecordMusicInfo[liveHouseMusicId].allCount and self.RecordMusicInfo[liveHouseMusicId].allCount > 0 then
		local totalCount = self.RecordMusicInfo[liveHouseMusicId].PerfectCount + self.RecordMusicInfo[liveHouseMusicId].GreatCount + self.RecordMusicInfo[liveHouseMusicId].MissCount

		if totalCount >= self.RecordMusicInfo[liveHouseMusicId].allCount * 0.8 then
			isFinish = true
		end
	end

	return isFinish
end

function M:SetRecordMusicInfo(id, perfectCount, greateCount, missCount)
	if not self.RecordMusicInfo[id] then
		self.RecordMusicInfo[id] = {}
	end

	self.RecordMusicInfo[id].PerfectCount = perfectCount or 0
	self.RecordMusicInfo[id].GreatCount = greateCount or 0
	self.RecordMusicInfo[id].MissCount = missCount or 0

	return self.RecordMusicInfo[id]
end

function M:SetMusicInfo(liveHouseId)
	local cfg = LivehouseMusicConfig.GetConfig(liveHouseId)

	if cfg then
		self.Bpm = cfg.Bpm
		self.bgmTotalBar = cfg.BgmTotalBar
		self.bpmPerBar = cfg.TimeSignature[1]
		self.perBarTime = self.bpmPerBar * 60 / self.Bpm
		self.gridCountPerSecond = self.gridCountPerBar / self.perBarTime
		self.gridCountPerBpm = self.gridCountPerBar / cfg.TimeSignature[1]
		self.noteSpeed = LivehouseConfig.NoteSpeed or 400
		self.generateGridTime = 48
	else
		print_error("SetMusicInfo failed:cfg is nil   livehouseId = " .. liveHouseId)
	end
end

function M:GetLivehouseNoteSensitivity(tid, NoteSensitivity)
	local attr = nil

	if gSpiritManager.spiritViewDatas[tid] then
		attr = gSpiritManager:GetUrbanAttr(tid)
	else
		local cfg = FightSpiritConfig.GetConfig(tid)

		if cfg then
			attr = cfg.UrbanAttribute
		end
	end

	if table.isNilOrEmpty(attr) then
		print_error("@yuanzhuochun GetLivehouseNoteSensitivity failed:attr is nil ,FightSpiritID = " .. tid)

		return -1
	end

	return Formula_cs:CalLivehouseNoteSensitivity(attr, NoteSensitivity) or NoteSensitivity
end

function M:SetLiveHouseMusicResult(liveHouseMusicId, cb)
	if self.RecordMusicInfo[liveHouseMusicId] then
		local musicInfo = {
			self.RecordMusicInfo[liveHouseMusicId].PerfectCount or 0,
			self.RecordMusicInfo[liveHouseMusicId].GreatCount or 0,
			self.RecordMusicInfo[liveHouseMusicId].MissCount or 0,
			self.RecordMusicInfo[liveHouseMusicId].SpecialCount or 0
		}

		gClientToGameDelegate:SetLiveHouseMusicResult(liveHouseMusicId, musicInfo, self.InviteNpcId).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				cb()
			else
				print_error("ChallengeResultAction:Start failed:", err)
			end
		end
	else
		print_error("SetLiveHouseMusicResult failed:RecordMusicInfo is nil")
	end
end

function M:AskLiveHouseMusicList(cb)
	gClientToGameDelegate:AskLiveHouseMusicList().Callback = function (err, data)
		if err == LTConfig.MessageConfig.Ok then
			for i = 1, data.Count do
				if table.isNilOrEmpty(data[i].RecordInfo) then
					print_notice("AskLivehouseMusicList请求成功，但服务器返回的data RecordInfo数据为空，联系服务器排查")
				else
					if table.isNilOrEmpty(self.RecordMusicInfo[data[i].MusicId]) then
						self.RecordMusicInfo[data[i].MusicId] = {}
					end

					self.RecordMusicInfo[data[i].MusicId].PerfectCount = data[i].RecordInfo[1] or 0
					self.RecordMusicInfo[data[i].MusicId].GreatCount = data[i].RecordInfo[2] or 0
					self.RecordMusicInfo[data[i].MusicId].MissCount = data[i].RecordInfo[3] or 0
					self.RecordMusicInfo[data[i].MusicId].SpecialCount = data[i].RecordInfo[4] or 0
					self.RecordMusicInfo[data[i].MusicId].allCount = (data[i].RecordInfo[1] or 0) + (data[i].RecordInfo[2] or 0) + (data[i].RecordInfo[3] or 0)
					self.RecordMusicInfo[data[i].MusicId].alreadyReward = data[i].AlreadyReward
				end
			end

			cb()
		else
			print_error("AskLiveHouseMusicList failed:", err)
		end
	end
end

function M:DestroyInviteNpcUnit()
	local csUnit = self.InviteNpcUnit

	if csUnit and gDataSetManager:GetUnitData(self.InviteNpcUnitPid) and csUnit.CanUseRes then
		gCS.BaseUnitUtils.DestroyAgentUnit(csUnit, true, true, true)

		csUnit = nil
	end
end

gMusicGameManager = M
