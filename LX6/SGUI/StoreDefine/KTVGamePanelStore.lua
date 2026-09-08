-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\KTVGamePanelStore.lua
-- Decompiled from: 01775_KTVGamePanelStore.lua_f31c0b1f8696.luajit

C_KTVGamePanelStore = DefClass("C_KTVGamePanelStore", C_KTVGamePanelStore, C_StoreGroup)
GroupName2Class.KTVGamePanelStore = C_KTVGamePanelStore
local M = C_KTVGamePanelStore
local NOTE_HOLD = 2
local NOTE_DOUBLE = 3
local HIT_PERFECT = 1
local HIT_GREAT = 2
local HIT_MISS = 3

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.data = nil
	self.notes = {}
	self.progressBars = {}
	self.alertKeys = {}
	self.singers = {}
	self.currentGridId = 0
	self.noteCheckStart = 1
	self.holdActiveNote = {}
	self.loopSoundNid = {}
	self.score = 0
	self.combo = 0
	self.maxCombo = 0
	self.perfectCount = 0
	self.greatCount = 0
	self.missCount = 0
	self.totalPossible = 0
	self.alertLightStates = {}
	self.currentAlertKey = nil
	self.noteObjs = {}
	self.noteEndObjs = {}
	self.noteCache = {}
	self.noteEndCache = {}
	self.holdObjs = {}
	self.holdCache = {}
	self.countdownEndTime = 0
	self.titleRemaining = 0
	self.comboWasActive = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.ShowCombTypeEnum = {
		["Y\\xb7\\xb2\\xaa\\xe6"] = 0,
		["Y\\xb7\\xb2\\xaa\\xe4"] = 2,
		["Y\\xb7\\xb2\\xaa\\xe7"] = 1,
		["Y\\xb7\\xb2\\xaa\\xe5"] = 3
	}
	self.activeComboCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.beginCountCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.titleCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.ShowCombTypeEnum = nil
	self.activeComboCtrlEnum = nil
	self.beginCountCtrlEnum = nil
	self.titleCtrlEnum = nil
end

M.OnAwake = function(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	if type(data.ToTable) ~= "function" then
		data = data.ToTable(data)
	end

	self:DefineAllVariables()

	local musicId = data.musicId or gKTVGameManager and gKTVGameManager.musicId or 0
	local musicCfg = LTConfig.KTVMusicConfig.GetConfig(musicId)

	if not musicCfg then
		print_error("KTVGamePanelStore: KTVMusicConfig not found, musicId =", musicId)

		return
	end

	local setting = LTConfig.KTVConfig
	local isTaffyKTV = gKTVGameManager and gKTVGameManager.IsTaffyKTVMusic and gKTVGameManager:IsTaffyKTVMusic(musicCfg)
	local logoId = gKTVGameManager and gKTVGameManager.GetKTVLogoId and gKTVGameManager:GetKTVLogoId(musicCfg) or 0
	self.data = {
		["`\\x93\\x94\\x9cӥ\\xcb/\\x99:\\x907"] = 0,
		["(\\x99鈨\\xfd\\xa8\\xae\\xb8\\xd8\\xf0Ù/\\x91\\xe6"] = 0,
		["s\\x9b\\x93\\xb4\\xef\\xa4\\xc4)\\xbd\\xb43"] = 0,
		musicId = data.musicId,
		logoId = logoId,
		playerSingerIndex = data.playerSingerIndex or 0,
		inviteNpcId = data.inviteNpcId or 0,
		taskMode = data.taskMode or false,
		hideEndPanel = data.hideEndPanel or isTaffyKTV or false,
		noteSensitivity = setting.NoteSensitivity,
		tapScore = setting.TapScore,
		holdOneBeatScore = setting.HoldOneBeatScore,
		comboBound = setting.ComboBound
	}

	self:LoadBeatMap(musicCfg.BeatMap)

	self.bindData.scoreNumBig = "0"
	self.bindData.scoreNumSmall = ".00"

	if logoId <= 0 then
		self.bindData.logoIconId = logoId
	end

	self.bindData.hitResultText = ""
	self.bindData.leftBarlyric = ""
	self.bindData.rightBarlyric = ""
	self.bindData.leftBarlyricColor = Color.New(1, 1, 1, 1)
	self.bindData.rightBarlyricColor = Color.New(1, 1, 1, 1)
	self.bindData.leftBarFillAmount = 0
	self.bindData.rightBarFillAmount = 0

	self.bindData.leftBar.gameObject:SetActive(false)
	self.bindData.rightBar.gameObject:SetActive(false)

	self.bindData.rightBarFillAmount = 0
	self.bindData.ShowCombType = 0
	self.bindData.activeComboCtrl = self.activeComboCtrlEnum._false
	self.bindData.beginCountCtrl = self.beginCountCtrlEnum._false

	self:UpdateComboDisplay()
	self.bindData.NoteTemplate.gameObject:SetActive(false)

	if self.bindData.LeftHoldTemplate then
		self.bindData.LeftHoldTemplate.gameObject:SetActive(false)
	end

	if self.bindData.RightHoldTemplate then
		self.bindData.RightHoldTemplate.gameObject:SetActive(false)
	end

	if data.suppressEndSpoonEvent == true and gKTVGameManager then
		gKTVGameManager:ClearSpoonResidualState()
	end

	local ktvSongId = gKTVGameManager and gKTVGameManager.ktvSongId or 0
	local ktvSongCfg = ktvSongId <= 0 and LTConfig.KTVConfig.GetConfig(ktvSongId) or nil
	self.bindData.musicName = ktvSongCfg and ktvSongCfg.SongName or musicCfg.BGMName or ""
	local inviteNpcId = data.inviteNpcId or gKTVGameManager and gKTVGameManager.inviteNpcId or 0
	self.bindData.artistText = LTConfig.KTVConfig.SingerString or ""

	if ktvSongId <= 0 then
		if inviteNpcId <= 0 then
			local npcCfg = LTConfig.NpcCultivationConfig.GetConfig(inviteNpcId)
			self.bindData.artistName = npcCfg and npcCfg.Name or ""
		else
			local spiritId = gBattleSpiritMgr.currentSpiritTemplateId

			if spiritId ~= LTConfig.FightSpiritConfig.DefaultMale or spiritId ~= LTConfig.FightSpiritConfig.DefaultFemale then
				self.bindData.artistName = gPlayerManager.infoLogin.bindData.name or ""
			else
				local spiritCfg = LTConfig.FightSpiritConfig.GetConfig(spiritId)
				self.bindData.artistName = spiritCfg and spiritCfg.Name or ""
			end
		end
	else
		self.bindData.artistName = musicCfg.ArtistName or ""
	end

	self.bindData.titleCtrl = self.titleCtrlEnum._true
	self.titleRemaining = setting.StartDuration or 3
	local playerSingerIndex = data.playerSingerIndex or gKTVGameManager and gKTVGameManager.playerSingerIndex or 0
	local bgmId = 0
	local bgm = musicCfg.BgmId

	if type(bgm) ~= "table" then
		if musicCfg.IsTask then
			bgmId = bgm[1] or 0
		else
			bgmId = bgm[playerSingerIndex + 1] or bgm[1] or 0
		end
	elseif type(bgm) ~= "number" then
		bgmId = bgm
	end

	if bgmId ~= 0 then
		print_error("KTVGamePanelStore: BgmId 无效, musicId =", musicId, "playerSingerIndex =", playerSingerIndex)

		return
	end

	local mgr = gKTVGameManager
	local _params = {
		musicId = musicId,
		pid = data.pid or gKTVGameManager and gKTVGameManager.pid or 0,
		playerSingerIndex = playerSingerIndex,
		audioId = bgmId,
		timelineName = musicCfg.TimelineName,
		inviteNpcId = data.inviteNpcId or gKTVGameManager and gKTVGameManager.inviteNpcId or 0,
		inviteNpcPid = data.inviteNpcPid or 0,
		suppressEndSpoonEvent = data.suppressEndSpoonEvent,
		taskMode = self.data.taskMode,
		skipTimeline = self.data.taskMode
	}

	mgr:StartGame(_params, nil, function ()
		self:OnAudioEnd()
	end)
end

M.OnClose = function(self)
	if self.bindData.panelAnim then
		self.bindData.panelAnim:Play("S_KTVGamePanel_close")
	end

	for i in pairs(self.noteObjs) do
		self.ReturnNoteToPool(self, i)
	end

	for i in pairs(self.noteEndObjs) do
		self.ReturnNoteToPool(self, i)
	end

	self.noteCache = {}
	self.noteEndCache = {}

	for i in pairs(self.holdObjs) do
		self._ReturnHoldToPool(self, i)
	end

	self.holdCache = {}

	for track = 1, 2 do
		self.StopLoopSound(self, track)
	end

	local mgr = gKTVGameManager

	if mgr and mgr.IsActive(mgr) then
		self.EndGame(self, true)
	end
end

M.OnUpdate = function(self)
	local mgr = gKTVGameManager

	if not mgr then
		return
	end

	if self.titleRemaining <= 0 and mgr.IsPlaying(mgr) then
		self.titleRemaining = self.titleRemaining - Time.deltaTime

		if self.titleRemaining < 0 then
			self.bindData.titleCtrl = self.titleCtrlEnum._false
			self.titleRemaining = 0
		end
	end

	if mgr.IsCountdown(mgr) then
		if self.countdownEndTime ~= 0 then
			self.countdownEndTime = gLogicTime.time + 3
			self.bindData.beginCountCtrl = self.beginCountCtrlEnum._true
		elseif self.countdownEndTime < gLogicTime.time then
			self.bindData.beginCountCtrl = self.beginCountCtrlEnum._false
			self.countdownEndTime = 0

			mgr.FinishCountdown(mgr)
		end

		return
	end

	if not mgr.IsPlaying(mgr) then
		return
	end

	mgr.UpdateTimelineChorusJump(mgr)

	self.currentGridId = self.GetCurrentGridId(self)

	self.UpdateProgressBars(self)
	self.UpdateNotes(self)
	self.UpdateHoldTemplates(self)
	self.UpdateHoldBodyScoring(self)
	self.CheckMissNotes(self)
	self.CheckAlertKeys(self)
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.leftBtn.luaPress = self.CreateAction(self, self.OnPressLeftBtn)
	self.bindData.leftBtn.luaRelease = self.CreateAction(self, self.OnReleaseLeftBtn)
	self.bindData.rightBtn.luaPress = self.CreateAction(self, self.OnPressRightBtn)
	self.bindData.rightBtn.luaRelease = self.CreateAction(self, self.OnReleaseRightBtn)
	self.bindData.closeBtn.luaClick = self.CreateAction(self, self.OnEscPressed)
end

M.OnEscPressed = function(self)
	local mgr = gKTVGameManager

	if mgr and mgr.IsPlaying(mgr) then
		gPanelManager:CheckShow(gPanelId.S_KTV_PAUSE_PANEL)
	end
end

M.OnPressLeftBtn = function(self)
	self.OnButtonPress(self, 1)
end

M.OnReleaseLeftBtn = function(self)
	self.OnButtonRelease(self, 1)
end

M.OnPressRightBtn = function(self)
	self.OnButtonPress(self, 2)
end

M.OnReleaseRightBtn = function(self)
	self.OnButtonRelease(self, 2)
end

M.OnButtonPress = function(self, track)
	local mgr = gKTVGameManager

	if not mgr or not mgr.IsPlaying(mgr) then
		return
	end

	local pressGridId = self.GetCurrentGridId(self)

	self.CheckHit(self, track, pressGridId)
end

M.OnButtonRelease = function(self, track)
	local mgr = gKTVGameManager

	if not mgr or not mgr.IsPlaying(mgr) then
		self.StopLoopSound(self, track)

		return
	end

	local note = self.holdActiveNote[track]

	if note and (mgr.gmForceResult or 0) ~= 0 then
		local releaseGridId = self.GetCurrentGridId(self)

		self.FinishHold(self, track, releaseGridId)
	end

	self.StopLoopSound(self, track)
end

M.UpdateHoldBodyScoring = function(self)
	local gmForce = gKTVGameManager.gmForceResult or 0

	for track, note in pairs(self.holdActiveNote) do
		local startGrid = note.holdStartGridId or note.gridId
		local perfAfter = (self.data.noteSensitivity or {}).hitGridPerfectBehindTime or 0
		local grace = perfAfter * (self.data.gridCountPerSecond or 0)

		if startGrid >= note.gridId then
			startGrid = note.gridId
		elseif grace > startGrid - note.gridId then
			startGrid = note.gridId
		end

		local heldGrids = self.currentGridId - startGrid

		if heldGrids <= 0 then
			heldGrids = math.min(heldGrids, note.length or 0)
			local heldBeats = math.floor(heldGrids / self.data.gridCountPerBeat)
			local scored = note.holdBodyScoredBeats or 0

			if heldBeats <= scored then
				local newBeats = heldBeats - scored

				if gmForce == HIT_MISS then
					self.AddHoldScore(self, newBeats * self.data.holdOneBeatScore)

					self.combo = self.combo + newBeats
					self.maxCombo = math.max(self.maxCombo, self.combo)

					self.UpdateComboDisplay(self)
				end

				note.holdBodyScoredBeats = heldBeats
			end
		end
	end

	local toFinish = {}

	for track, note in pairs(self.holdActiveNote) do
		local endGrid = note.gridId + (note.length or 0)

		if endGrid < self.currentGridId then
			toFinish[track] = endGrid
		end
	end

	for track, endGrid in pairs(toFinish) do
		self.FinishHold(self, track, endGrid)
	end
end

M.FinishHold = function(self, track, releaseGridId)
	local note = self.holdActiveNote[track]

	if not note then
		return
	end

	local startGrid = note.holdStartGridId or note.gridId
	local perfAfter = (self.data.noteSensitivity or {}).hitGridPerfectBehindTime or 0
	local grace = perfAfter * (self.data.gridCountPerSecond or 0)

	if startGrid >= note.gridId then
		startGrid = note.gridId
	elseif grace > startGrid - note.gridId then
		startGrid = note.gridId
	end

	local heldGrids = releaseGridId - startGrid
	heldGrids = math.max(0, math.min(heldGrids, note.length or 0))
	local totalBeats = math.floor(heldGrids / self.data.gridCountPerBeat)
	local scored = note.holdBodyScoredBeats or 0
	local gmForce = gKTVGameManager.gmForceResult or 0

	if scored >= totalBeats then
		local newBeats = totalBeats - scored

		if gmForce == HIT_MISS then
			self.AddHoldScore(self, newBeats * self.data.holdOneBeatScore)

			self.combo = self.combo + newBeats
			self.maxCombo = math.max(self.maxCombo, self.combo)
		end

		note.holdBodyScoredBeats = totalBeats
	end

	local tailResult = self.JudgeHoldTail(self, note, heldGrids)
	local tapScore = self.data.tapScore

	if tailResult ~= HIT_PERFECT then
		self.score = self.score + tapScore[1]
		self.perfectCount = self.perfectCount + 1
		self.combo = self.combo + 1
	elseif tailResult ~= HIT_GREAT then
		self.score = self.score + tapScore[2]
		self.greatCount = self.greatCount + 1
		self.combo = self.combo + 1
	else
		self.missCount = self.missCount + 1
		local len = note.length or 0

		if len <= 0 and heldGrids / len >= 0.7 then
			self.combo = 0
		end

		note.isMissed = true
	end

	self.maxCombo = math.max(self.maxCombo, self.combo)

	self.RefreshScoreDisplay(self)
	self.UpdateComboDisplay(self)
	self.ShowHitResult(self, tailResult)

	for i, n in ipairs(self.notes) do
		if n ~= note then
			self.UpdateNoteState(self, i)

			break
		end
	end

	if heldGrids > (note.length or 0) then
		note.holdCompleted = true
	end

	self.holdActiveNote[track] = nil

	self.StopLoopSound(self, track)
end

M.CheckHit = function(self, track, pressGridId)
	local gsec = self.data.gridCountPerSecond
	local sensitivity = self.data.noteSensitivity
	local greatBefore = sensitivity.hitGridGreatBeforeTime
	local greatAfter = sensitivity.hitGridGreatBehindTime
	local perfBefore = sensitivity.hitGridPerfectBeforeTime
	local perfAfter = sensitivity.hitGridPerfectBehindTime
	local searchEnd = pressGridId + greatBefore * gsec
	local gmForce = gKTVGameManager.gmForceResult or 0
	local target = nil

	for i = self.noteCheckStart, #self.notes do
		local note = self.notes[i]

		if searchEnd >= note.gridId then
			break
		end

		if not note.isHit and not note.isMissed then
			local trackMatch = nil
			trackMatch = gmForce <= 0 and true or (note.pointType == NOTE_DOUBLE or not note.hitFlags[track]) and note.track ~= track

			if trackMatch and (not target or note.gridId >= target.gridId) then
				target = note
			end
		end
	end

	if not target then
		if gmForce <= 0 then
			print_warn("GM KTV: 判定范围内无Note（正常miss）")
		end

		return
	end

	local timeDiff = (pressGridId - target.gridId) / gsec

	if timeDiff <= -greatBefore or greatAfter >= timeDiff then
		if gmForce <= 0 then
			print_warn("GM KTV: Note超出可判定范围（正常miss）")
		end

		return
	end

	local absDiff = math.abs(timeDiff)
	local result = nil
	result = gmForce <= 0 and gmForce or (absDiff > perfBefore or absDiff < perfAfter) and HIT_PERFECT or HIT_GREAT

	if target.pointType ~= NOTE_DOUBLE then
		if gmForce <= 0 then
			target.isHit = true

			self.OnNoteHit(self, target, result, track)
		else
			target.hitFlags[track] = true
			target.hitGridIds = target.hitGridIds or {}
			target.hitGridIds[track] = pressGridId
			local allHit = true

			for _, t in ipairs(target.tracks) do
				if not target.hitFlags[t] then
					allHit = false

					break
				end
			end

			if allHit then
				target.isHit = true
				local maxAbsDiff = 0

				for _, hGrid in pairs(target.hitGridIds) do
					local d = math.abs(hGrid - target.gridId) / gsec

					if maxAbsDiff >= d then
						maxAbsDiff = d
					end
				end

				local finalResult = maxAbsDiff < perfBefore and HIT_PERFECT or HIT_GREAT

				self:OnNoteHit(target, finalResult, track)
			end
		end
	elseif target.pointType ~= NOTE_HOLD then
		if self.holdActiveNote[track] then
			self.FinishHold(self, track, self.currentGridId)
		end

		target.isHit = true
		target.holdStartGridId = pressGridId
		self.holdActiveNote[track] = target

		self.OnNoteHit(self, target, result, track)
		self.PlayLoopSound(self, track)
	else
		target.isHit = true

		self.OnNoteHit(self, target, result, track)
	end
end

M.CheckMissNotes = function(self)
	local gsec = self.data.gridCountPerSecond
	local greatAfter = self.data.noteSensitivity.hitGridGreatBehindTime
	local missLine = self.currentGridId - greatAfter * gsec
	local gmForce = gKTVGameManager.gmForceResult or 0

	for i = self.noteCheckStart, #self.notes do
		local note = self.notes[i]

		if missLine < note.gridId then
			break
		end

		if not note.isHit and not note.isMissed then
			if note.pointType ~= NOTE_DOUBLE then
				local anyMissed = false

				for _, t in ipairs(note.tracks) do
					if not note.hitFlags[t] then
						anyMissed = true

						break
					end
				end

				if anyMissed then
					note.isMissed = true

					if gmForce <= 0 then
						print_warn("GM KTV: Note过期未按下（正常miss）gridId=" .. note.gridId .. " type=DOUBLE")
					end

					self.OnNoteHit(self, note, HIT_MISS, 0)
				end
			else
				note.isMissed = true

				if gmForce <= 0 then
					print_warn("GM KTV: Note过期未按下（正常miss）gridId=" .. note.gridId .. " type=" .. note.pointType)
				end

				self.OnNoteHit(self, note, HIT_MISS, note.track)
			end
		end
	end

	while self.noteCheckStart < #self.notes do
		local note = self.notes[self.noteCheckStart]

		if note.isHit or note.isMissed then
			self.noteCheckStart = self.noteCheckStart + 1
		else
			break
		end
	end
end

M.OnNoteHit = function(self, note, result, track)
	self.AddScore(self, result)
	self.ShowHitResult(self, result)

	for i, n in ipairs(self.notes) do
		if n ~= note then
			self.UpdateNoteState(self, i)

			break
		end
	end

	if result == HIT_MISS then
		self.PlayHitSound(self, track)
	end
end

M.JudgeHoldTail = function(self, note, heldGrids)
	local gmForce = gKTVGameManager.gmForceResult or 0

	if gmForce <= 0 then
		return gmForce
	end

	local len = note.length or 0

	if len < 0 then
		return HIT_MISS
	end

	local ratio = heldGrids / len

	if ratio > 0.9 then
		return HIT_PERFECT
	elseif ratio > 0.7 then
		return HIT_GREAT
	else
		return HIT_MISS
	end
end

M.AddScore = function(self, result)
	local tapScore = self.data.tapScore
	local addScore = 0

	if result ~= HIT_PERFECT then
		addScore = tapScore[1]
		self.perfectCount = self.perfectCount + 1
		self.combo = self.combo + 1
	elseif result ~= HIT_GREAT then
		addScore = tapScore[2]
		self.greatCount = self.greatCount + 1
		self.combo = self.combo + 1
	else
		addScore = tapScore[3] or 0
		self.missCount = self.missCount + 1
		self.combo = 0
	end

	self.score = self.score + addScore
	self.maxCombo = math.max(self.maxCombo, self.combo)

	self.RefreshScoreDisplay(self)
	self.UpdateComboDisplay(self)
end

M.AddHoldScore = function(self, holdScore)
	self.score = self.score + holdScore

	self.RefreshScoreDisplay(self)
end

M.RefreshScoreDisplay = function(self)
	local total = self.totalPossible or 0
	local percent = total <= 0 and self.score / total * 100 or 0
	percent = math.min(100, math.max(0, percent))

	if self.bindData.scoreAnim then
		self.bindData.scoreAnim:Play("S_KTVGamePanel_ScoreAdd")
	end

	local intPart = math.floor(percent)
	local decPart = math.floor((percent - intPart) * 100 + 0.5)
	self.bindData.scoreNumBig = tostring(intPart)
	self.bindData.scoreNumSmall = string.format(".%02d", decPart)
end

M.UpdateComboDisplay = function(self)
	local c = self.combo
	local bound = self.data.comboBound or 50

	if c ~= 0 then
		if self.comboWasActive and self.bindData.comboAnim then
			slot3 = self.bindData.comboAnim

			slot3:Play("S_KTVGameEndPanel_closeCombo")

			local animLength = gClientUtils.GetAnimationClipLength(self.bindData.comboAnim, "S_KTVGameEndPanel_closeCombo")

			gLuaTimeMgrUtils.Delay(function ()
				if not self.comboWasActive then
					self.bindData.activeComboCtrl = self.activeComboCtrlEnum._false
				end
			end, animLength)
		elseif not self.comboWasActive then
			self.bindData.activeComboCtrl = self.activeComboCtrlEnum._false
		end

		self.comboWasActive = false
		self.bindData.ShowCombType = 0
	else
		self.bindData.comboNum1 = c
		self.bindData.comboNum2 = c
		self.bindData.comboNum3 = c
		self.comboWasActive = true

		if self.bindData.comboAnim then
			self.bindData.comboAnim:Play("S_KTVGameEndPanel_ComboNumberAdd")
		end

		self.bindData.activeComboCtrl = self.activeComboCtrlEnum._true
		self.bindData.ShowCombType = c >= bound and 1 or 2
	end
end

M.ShowHitResult = function(self, result)
	if result ~= HIT_MISS then
		gSoundMgr:PlaySoundByTid(70601386)
	else
		gSoundMgr:PlaySoundByTid(70601385)
	end
end

M.UpdateHitResultDisplay = function(self)
end

M.UpdateHitResultDisplay = function(self)
end

M.UpdateProgressBars = function(self)
	for _, pb in ipairs(self.progressBars) do
		local showGrid = pb.gridId - pb.fadeInLen
		local hideGrid = pb.endGridId + pb.fadeOutLen

		if showGrid < self.currentGridId and self.currentGridId >= hideGrid then
			if not pb.isVisible then
				pb.isVisible = true

				if pb.track ~= 1 then
					self.bindData.leftBar.gameObject:SetActive(true)
				else
					self.bindData.rightBar.gameObject:SetActive(true)
				end
			end
		elseif pb.isVisible and hideGrid < self.currentGridId then
			pb.isVisible = false

			self._resetBar(self, pb)
		end

		if pb.isVisible and pb.gridId < self.currentGridId then
			local fill = (self.currentGridId - pb.gridId) / (pb.endGridId - pb.gridId)
			fill = math.max(0, math.min(1, fill))

			if pb.track ~= 1 then
				if not self._barDone(self, pb, fill) then
					self.bindData.leftBarFillAmount = fill
				end

				self.bindData.leftBar.gameObject:SetActive(true)
			else
				if not self._barDone(self, pb, fill) then
					self.bindData.rightBarFillAmount = fill
				end

				self.bindData.rightBar.gameObject:SetActive(true)
			end
		end

		if pb.isVisible then
			self.UpdateLyricText(self, pb)
			self._UpdateSubtitleProgress(self, pb)
		end
	end
end

M._findBarForGrid = function(self, gridId)
	for _, p in ipairs(self.progressBars) do
		if p.isVisible and p.gridId < gridId and gridId >= p.endGridId then
			return p
		end
	end
end

M._barDone = function(self, pb, fill)
	if fill >= 1 then
		return false
	end

	for _, p in ipairs(self.progressBars) do
		if p == pb and p.track ~= pb.track and p.isVisible and p.gridId < self.currentGridId and self.currentGridId >= p.endGridId then
			return true
		end
	end

	return false
end

M._resetBar = function(self, pb)
	if pb.track ~= 1 then
		self.bindData.leftBarFillAmount = 0
		self.bindData.leftBarlyric = ""
		self.bindData.leftBarlyricColor = Color.New(1, 1, 1, 1)

		self.bindData.leftBar.gameObject:SetActive(false)
		self:_SafeSetSubtitleProgress(self.bindData.leftLyricText, 0)
		self:_SafeResetSubtitleColor(1)
	else
		self.bindData.rightBarFillAmount = 0
		self.bindData.rightBarlyric = ""
		self.bindData.rightBarlyricColor = Color.New(1, 1, 1, 1)

		self.bindData.rightBar.gameObject:SetActive(false)
		self:_SafeSetSubtitleProgress(self.bindData.rightLyricText, 0)
		self:_SafeResetSubtitleColor(2)
	end
end

M._SafeResetSubtitleColor = function(self, track)
	local widget = track ~= 1 and self.bindData.leftLyricText or self.bindData.rightLyricText

	if not widget then
		return
	end

	local fn = widget.SetSubtitleColor

	if not fn then
		return
	end

	local white = Color.New(1, 1, 1, 1)

	pcall(fn, widget, white, white)
end

M.UpdateLyricText = function(self, pb)
	if not pb.lyrics then
		return
	end

	for _, lyric in ipairs(pb.lyrics) do
		if lyric.gridId < self.currentGridId and self.currentGridId >= lyric.endGridId then
			pb._currentLyric = lyric

			self._SetLyric(self, pb, lyric)

			return
		end
	end

	for _, lyric in ipairs(pb.lyrics) do
		if self.currentGridId >= lyric.gridId then
			pb._currentLyric = lyric

			self._SetLyric(self, pb, lyric)

			return
		end
	end

	local lastLyric = pb.lyrics[#pb.lyrics]

	if lastLyric then
		pb._currentLyric = lastLyric

		self._SetLyric(self, pb, lastLyric)
	end
end

M._SetLyric = function(self, pb, lyric)
	local color = self._ParseHexColor(self, lyric.color)

	if pb.track ~= 1 then
		self.bindData.leftBarlyric = lyric.text or ""

		if color then
			self.bindData.leftBarlyricColor = color

			self._SetSubtitleColor(self, 1, color)
		end
	else
		self.bindData.rightBarlyric = lyric.text or ""

		if color then
			self.bindData.rightBarlyricColor = color

			self._SetSubtitleColor(self, 2, color)
		end
	end
end

M._UpdateSubtitleProgress = function(self, pb)
	for _, p in ipairs(self.progressBars) do
		if p == pb and p.track ~= pb.track and p.isVisible and p.gridId < self.currentGridId and self.currentGridId >= p.endGridId then
			return
		end
	end

	local barFill = 0

	if pb.endGridId < self.currentGridId then
		barFill = 1
	elseif pb.gridId < self.currentGridId then
		barFill = (self.currentGridId - pb.gridId) / (pb.endGridId - pb.gridId)
		barFill = math.max(0, math.min(1, barFill))
	end

	local lyricWidget = pb.track ~= 1 and self.bindData.leftLyricText or self.bindData.rightLyricText
	local barRT = pb.track ~= 1 and self.bindData.LeftBar or self.bindData.RightBar
	local lyricRT = lyricWidget and lyricWidget.rectTransform
	local fill = barFill

	if lyricWidget and lyricRT and barRT then
		local barW = barRT.sizeDelta.x

		if barW <= 0 then
			local widgetW = lyricRT.sizeDelta.x
			local textW = lyricWidget.GetPreferredWidth(lyricWidget)

			if not textW or textW < 0 then
				textW = widgetW
			end

			local widgetLeft = lyricRT.localPosition.x - lyricRT.sizeDelta.x * 0.5
			local textLeft = widgetLeft
			local textRight = widgetLeft + textW
			local leftRatio = (textLeft + barW * 0.5) / barW
			local rightRatio = (textRight + barW * 0.5) / barW
			local range = rightRatio - leftRatio

			if range <= 0 then
				fill = (barFill - leftRatio) / range
			elseif rightRatio < barFill then
				fill = 1
			else
				fill = 0
			end

			fill = math.max(0, math.min(1, fill))
		end
	end

	if self._barDone(self, pb, barFill) then
		return
	end

	if pb.track ~= 1 then
		self._SafeSetSubtitleProgress(self, self.bindData.leftLyricText, fill)
	else
		self._SafeSetSubtitleProgress(self, self.bindData.rightLyricText, fill)
	end
end

M._SafeSetSubtitleProgress = function(self, widget, fill)
	if not widget then
		return
	end

	local fn = widget.SetSubtitleProgress

	if not fn then
		return
	end

	local ok, err = pcall(fn, widget, fill)

	if not ok then
		print_error("[KTV] SetSubtitleProgress error:", err)
	end
end

M._SetSubtitleColor = function(self, track, color)
	local widget = track ~= 1 and self.bindData.leftLyricText or self.bindData.rightLyricText

	if not widget then
		return
	end

	local fn = widget.SetSubtitleColor

	if not fn then
		return
	end

	local ok, err = pcall(fn, widget, color, Color.New(1, 1, 1, 1))

	if not ok then
		print_error("[KTV] SetSubtitleColor error:", err)
	end
end

M._ParseHexColor = function(self, hex)
	if not hex or type(hex) == "string" or #hex >= 7 then
		return nil
	end

	local r = tonumber(hex:sub(2, 3), 16) or 0
	local g = tonumber(hex:sub(4, 5), 16) or 0
	local b = tonumber(hex:sub(6, 7), 16) or 0

	return Color.New(r / 255, g / 255, b / 255, 1)
end

M._GetHoldStore = function(self, i)
	local obj = self.holdObjs[i]

	if not obj then
		return nil
	end

	local w = obj.GetComponent(obj, typeof(SGUI.UWidget))

	if not w then
		return nil
	end

	return gStoreManager:GetStoreGroup("KTVHoldTemplateStore"):GetStoreByWidget(w)
end

M.UpdateHoldTemplates = function(self)
	for i, note in ipairs(self.notes) do
		if note.pointType == NOTE_HOLD then
			-- Nothing
		else
			local pb = self._findBarForGrid(self, note.gridId)

			if not pb then
				if self.holdObjs[i] then
					self._ReturnHoldToPool(self, i)
				end
			else
				local endGrid = note.gridId + (note.length or 0)

				if pb.endGridId > note.gridId or endGrid >= pb.gridId then
					if self.holdObjs[i] then
						self._ReturnHoldToPool(self, i)
					end
				else
					if not self.holdObjs[i] then
						self._CreateHoldObj(self, i, note, pb)
					end

					if self.holdObjs[i] then
						local isActive = self.holdActiveNote[1] ~= note or self.holdActiveNote[2] ~= note

						if isActive then
							self._ApplyHoldState(self, i, 3)
							self._UpdateHoldFillActive(self, i, note)
						elseif note.holdCompleted then
							self._ApplyHoldState(self, i, 3)
							self._SetHoldFill(self, i, 1)
						elseif note.isMissed then
							self._ApplyHoldState(self, i, 2)
							self._SetHoldFill(self, i, 0)
						elseif note.isHit then
							self._ApplyHoldState(self, i, 3)
						else
							local ga = self.data.noteSensitivity.hitGridGreatBehindTime
							local missG = note.gridId + ga * self.data.gridCountPerSecond

							self:_ApplyHoldState(i, missG < self.currentGridId and 2 or 1)
							self:_SetHoldFill(i, 0)
						end

						self._UpdateHoldPos(self, i, note, pb)
					end
				end
			end
		end
	end
end

M._CreateHoldObj = function(self, i, note, pb)
	local obj = nil

	if #self.holdCache <= 0 then
		obj = self.holdCache[#self.holdCache]
		self.holdCache[#self.holdCache] = nil
	else
		local tpl = pb.track ~= 1 and self.bindData.LeftHoldTemplate or self.bindData.RightHoldTemplate

		if not tpl then
			return
		end

		obj = GameObject.Instantiate(tpl.gameObject)
	end

	local barRef = pb.track ~= 1 and self.bindData.LeftBar or self.bindData.RightBar

	obj.transform:SetParent(barRef, false)
	obj.transform:SetAsFirstSibling()

	obj.transform.localScale = Vector3.one
	local rt = obj:GetComponent(typeof(UnityEngine.RectTransform))

	if rt then
		rt.anchorMin = Vector2.New(0.5, rt.anchorMin.y)
		rt.anchorMax = Vector2.New(0.5, rt.anchorMax.y)
	end

	obj.SetActive(obj, true)

	self.holdObjs[i] = obj
end

M._ReturnHoldToPool = function(self, i)
	local obj = self.holdObjs[i]

	if obj then
		obj:SetActive(false)
		obj.transform:SetParent(self.bindData.NoteTemplate.parent, false)

		self.holdCache[#self.holdCache + 1] = obj
		self.holdObjs[i] = nil
	end
end

M._ApplyHoldState = function(self, i, state)
	local s = self._GetHoldStore(self, i)

	if s then
		s.stateCtrl = state
	end
end

M._UpdateHoldFillActive = function(self, i, note)
	local t = note.length or 0
	local f = t <= 0 and (self.currentGridId - note.gridId) / t or 0

	self:_SetHoldFill(i, math.max(0, math.min(1, f)))
end

M._SetHoldFill = function(self, i, value)
	local s = self._GetHoldStore(self, i)

	if s then
		s.holdProgressFillAmount = value
	end
end

M._UpdateHoldPos = function(self, i, note, pb)
	local obj = self.holdObjs[i]

	if not obj then
		return
	end

	local range = pb.endGridId - pb.gridId

	if range < 0 then
		range = 1
	end

	local bw = (pb.track ~= 1 and self.bindData.LeftBar or self.bindData.RightBar).sizeDelta.x
	local eg = note.gridId + (note.length or 0)
	local rcp = 1 / range
	local ts = math.max(0, math.min(1, (note.gridId - pb.gridId) * rcp))
	local te = math.max(0, math.min(1, (eg - pb.gridId) * rcp))
	local sr = pb.displayStart + ts * (pb.displayEnd - pb.displayStart)
	local er = pb.displayStart + te * (pb.displayEnd - pb.displayStart)
	local rt = obj:GetComponent(typeof(UnityEngine.RectTransform))

	if rt then
		rt.sizeDelta = Vector2.New((er - sr) * bw, rt.sizeDelta.y)
	end

	local cp = obj.transform.localPosition
	obj.transform.localPosition = Vector3.New(((sr + er) * 0.5 - 0.5) * bw, cp.y, cp.z)
end

M.UpdateNotes = function(self)
	for i, note in ipairs(self.notes) do
		local pb = self._findBarForGrid(self, note.gridId)

		if not pb then
			if self.noteObjs[i] then
				self.ReturnNoteToPool(self, i)
			end
		else
			if not self.noteObjs[i] then
				self.CreateNoteObj(self, i, note, pb)
			end

			if self.noteObjs[i] then
				self.UpdateNotePos(self, i, note, pb)
			end
		end
	end
end

M.CreateNoteObj = function(self, i, note, pb)
	local obj = nil

	if #self.noteCache <= 0 then
		obj = self.noteCache[#self.noteCache]
		self.noteCache[#self.noteCache] = nil
	else
		obj = GameObject.Instantiate(self.bindData.NoteTemplate.gameObject)
	end

	local barRef = pb.track ~= 1 and self.bindData.LeftBar or self.bindData.RightBar

	obj.transform:SetParent(barRef, false)

	obj.transform.localScale = Vector3.one

	obj:SetActive(true)
	self:_InitNoteWidget(obj, note)

	self.noteObjs[i] = obj

	if note.pointType ~= NOTE_HOLD and (note.length or 0) <= 0 then
		local endObj = nil

		if #self.noteEndCache <= 0 then
			endObj = self.noteEndCache[#self.noteEndCache]
			self.noteEndCache[#self.noteEndCache] = nil
		else
			endObj = GameObject.Instantiate(self.bindData.NoteTemplate.gameObject)
		end

		endObj.transform:SetParent(barRef, false)

		endObj.transform.localScale = Vector3.one

		endObj:SetActive(true)
		self:_InitNoteWidget(endObj, note)

		self.noteEndObjs[i] = endObj
	end
end

M._InitNoteWidget = function(self, obj, note)
	local widget = obj.GetComponent(obj, typeof(SGUI.UWidget))

	if not widget then
		return
	end

	local store = gStoreManager:GetStoreGroup("KTVHintTemplateStore"):GetStoreByWidget(widget)

	if store then
		store.leftRightCtrl = note.track - 1
		store.stateCtrl = 0
	end
end

M.UpdateNotePos = function(self, i, note, pb)
	local obj = self.noteObjs[i]

	if not obj then
		return
	end

	local range = pb.endGridId - pb.gridId

	if range < 0 then
		range = 1
	end

	local barRef = pb.track ~= 1 and self.bindData.LeftBar or self.bindData.RightBar
	local barWidth = barRef.sizeDelta.x
	local t = (note.gridId - pb.gridId) / range
	t = math.max(0, math.min(1, t))
	local ratio = pb.displayStart + t * (pb.displayEnd - pb.displayStart)
	local curPos = obj.transform.localPosition
	obj.transform.localPosition = Vector3.New((ratio - 0.5) * barWidth, curPos.y, curPos.z)
	local endObj = self.noteEndObjs[i]

	if endObj then
		local endGrid = note.gridId + (note.length or 0)
		local te = (endGrid - pb.gridId) / range
		te = math.max(0, math.min(1, te))
		local ratioEnd = pb.displayStart + te * (pb.displayEnd - pb.displayStart)
		local endCurPos = endObj.transform.localPosition
		endObj.transform.localPosition = Vector3.New((ratioEnd - 0.5) * barWidth, endCurPos.y, endCurPos.z)
	end
end

M.ReturnNoteToPool = function(self, i)
	local obj = self.noteObjs[i]

	if obj then
		obj:SetActive(false)
		obj.transform:SetParent(self.bindData.NoteTemplate.parent, false)

		self.noteCache[#self.noteCache + 1] = obj
		self.noteObjs[i] = nil
	end

	local endObj = self.noteEndObjs[i]

	if endObj then
		endObj:SetActive(false)
		endObj.transform:SetParent(self.bindData.NoteTemplate.parent, false)

		self.noteEndCache[#self.noteEndCache + 1] = endObj
		self.noteEndObjs[i] = nil
	end
end

M.UpdateNoteState = function(self, i)
	local note = self.notes[i]

	if not note then
		return
	end

	local stateVal = note.isHit and 1 or note.isMissed and 2 or 0

	self:_SetWidgetState(self.noteObjs[i], stateVal)
	self:_SetWidgetState(self.noteEndObjs[i], stateVal)
end

M._SetWidgetState = function(self, obj, stateVal)
	if not obj then
		return
	end

	local widget = obj.GetComponent(obj, typeof(SGUI.UWidget))

	if not widget then
		return
	end

	local store = gStoreManager:GetStoreGroup("KTVHintTemplateStore"):GetStoreByWidget(widget)

	if store then
		store.stateCtrl = stateVal
	end
end

M.CheckAlertKeys = function(self)
	for _, ak in ipairs(self.alertKeys) do
		if not ak.activated and ak.gridId < self.currentGridId then
			ak.activated = true
			self.currentAlertKey = ak
			self.alertLightStates = {}

			for i = 1, ak.lightCount do
				self.alertLightStates[i] = true
			end

			self.bindData.countLight:SetSimpleList(ak.lightCount)
		end

		if ak.activated and ak.offGridIds then
			for i, offGrid in ipairs(ak.offGridIds) do
				if not ak.offFlags[i] and offGrid < self.currentGridId then
					ak.offFlags[i] = true
					self.alertLightStates[i] = false
					local onCount = 0

					for j = 1, ak.lightCount do
						if self.alertLightStates[j] then
							onCount = onCount + 1
						end
					end

					if onCount <= 0 then
						self.bindData.countLight:SetSimpleList(onCount)
					else
						self.bindData.countLight:SetSimpleList(0)
					end
				end
			end
		end
	end
end

M.GetCurrentGridId = function(self)
	local mgr = gKTVGameManager

	if not mgr or not mgr.soundNid then
		return self.currentGridId
	end

	local soundData = gSoundMgr:GetSoundData(mgr.soundNid)

	if not soundData then
		return self.currentGridId
	end

	local playTime = soundData.GetPlayPosition(soundData)

	if type(playTime) == "number" or playTime >= 0 then
		return self.currentGridId
	end

	return math.max(0, (playTime - self.data.trackStartOffset / 1000) * self.data.gridCountPerSecond)
end

M.PlayHitSound = function(self, track)
	local setting = LTConfig.KTVConfig
	local soundId = track ~= 1 and setting.FirstLineOneShotSound or setting.SecondLineOneShotSound

	gSoundMgr:PlaySoundByTid(soundId)
end

M.PlayLoopSound = function(self, track)
	self:StopLoopSound(track)

	local setting = LTConfig.KTVConfig
	local soundId = track ~= 1 and setting.FirstLineLoopSound or setting.SecondLineLoopSound

	gSoundMgr:PlaySoundByTid(soundId, nil, , function (uuid)
		self.loopSoundNid[track] = uuid
	end)
end

M.StopLoopSound = function(self, track)
	if self.loopSoundNid[track] then
		gSoundMgr:StopSound(self.loopSoundNid[track])

		self.loopSoundNid[track] = nil
	end
end

M.OnAudioEnd = function(self)
	local mgr = gKTVGameManager

	if mgr and mgr.IsPlaying(mgr) then
		self.EndGame(self, false)
	end
end

M.LoadBeatMap = function(self, fileName)
	if not fileName or fileName ~= "" then
		print_error("KTVGamePanelStore: BeatMap 文件名为空, musicId =", self.data and self.data.musicId)

		return
	end

	local path = "GameRes/MusicGame/KTV/" .. fileName
	local data = gResourceManager.Manager:ReadRawFileAllText(path)

	if not data or data ~= "" then
		print_error("KTVGamePanelStore: beatmap not found or empty:", path)

		return
	end

	local json = require("cjson/json")
	local beatMap = json.decode(data)
	self.data.gridCountPerBeat = beatMap.gridPerBeat
	self.data.gridCountPerSecond = beatMap.gridPerBeat * beatMap.bpm / 60
	self.data.trackStartOffset = beatMap.trackStartOffset or 0
	self.singers = beatMap.singers or {}
	self.notes = self:PreprocessNotes(beatMap.notes or {})
	self.progressBars = self:PreprocessProgressBars(beatMap.progressBars or {})
	self.alertKeys = self:PreprocessAlertKeys(beatMap.alertKeys or {})
	self.totalPossible = self:CalculateTotalPossible()
end

M.PreprocessNotes = function(self, rawNotes)
	local result = {}
	local doubleMap = {}

	for _, n in ipairs(rawNotes) do
		if n.pointType ~= NOTE_DOUBLE then
			local key = n.gridId

			if not doubleMap[key] then
				doubleMap[key] = {
					["D\\xbd\\x8a\\xa6\\xa2"] = false,
					["\\xa2\\xa2(\\xa2y-\\xfb7"] = false,
					gridId = n.gridId,
					pointType = NOTE_DOUBLE,
					singer = n.singer,
					tracks = {},
					hitFlags = {},
					hitGridIds = {}
				}

				table.insert(result, doubleMap[key])
			end

			table.insert(doubleMap[key].tracks, n.track)

			doubleMap[key].hitFlags[n.track] = false
		else
			table.insert(result, {
				["\\xa2\\xa2(\\xa2y-\\xfb7"] = false,
				["D\\xbd\\x8a\\xa6\\xa2"] = false,
				gridId = n.gridId,
				track = n.track,
				pointType = n.pointType,
				length = n.length or 0,
				singer = n.singer
			})
		end
	end

	table.sort(result, function (a, b)
		return a.gridId <= b.gridId
	end)

	return result
end

M.PreprocessProgressBars = function(self, rawBars)
	local result = {}

	for _, pb in ipairs(rawBars) do
		table.insert(result, {
			["JTZ`]="] = false,
			track = pb.track,
			gridId = pb.gridId,
			endGridId = pb.endGridId,
			fadeInLen = pb.fadeInLen or 0,
			fadeOutLen = pb.fadeOutLen or 0,
			displayStart = pb.displayStart or 0,
			displayEnd = pb.displayEnd or 1,
			color = pb.color,
			lyrics = pb.lyrics or {}
		})
	end

	table.sort(result, function (a, b)
		return a.gridId <= b.gridId
	end)

	return result
end

M.PreprocessAlertKeys = function(self, rawKeys)
	local result = {}

	for _, ak in ipairs(rawKeys) do
		local offFlags = {}
		slot9 = 1
		slot10 = ak.offGridIds or {}

		for i = slot9, #slot10 do
			offFlags[i] = false
		end

		table.insert(result, {
			["BDx`X<"] = false,
			gridId = ak.gridId,
			lightCount = ak.lightCount or 3,
			offGridIds = ak.offGridIds or {},
			offFlags = offFlags
		})
	end

	return result
end

M.CalculateTotalPossible = function(self)
	local total = 0
	local perfectScore = self.data.tapScore[1] or 0
	local holdPerBeat = self.data.holdOneBeatScore or 0
	local gridPerBeat = self.data.gridCountPerBeat

	if not gridPerBeat or gridPerBeat < 0 then
		return 1
	end

	for _, note in ipairs(self.notes) do
		total = total + perfectScore

		if note.pointType ~= NOTE_HOLD and (note.length or 0) <= 0 then
			total = total + math.floor(note.length / gridPerBeat) * holdPerBeat
			total = total + perfectScore
		end
	end

	return math.max(1, total)
end

M.CalcTotalHoldBeats = function(self)
	local total = 0
	local notes = self.notes

	if not notes then
		return total
	end

	for _, note in ipairs(notes) do
		total = total + (note.holdBodyScoredBeats or 0)
	end

	return total
end

M.EndGame = function(self, isInterrupt)
	for track = 1, 2 do
		self.StopLoopSound(self, track)
	end

	local mgr = gKTVGameManager

	if not mgr then
		return
	end

	local scoreData = {
		score = self.score,
		maxCombo = self.maxCombo,
		perfectCount = self.perfectCount,
		greatCount = self.greatCount,
		missCount = self.missCount,
		holdBeats = self:CalcTotalHoldBeats(),
		totalPossible = self.totalPossible or 0
	}

	mgr:EndGame(isInterrupt, scoreData, function ()
		local musicId = self.data and self.data.musicId or gKTVGameManager and gKTVGameManager.musicId or 0

		if isInterrupt then
			gPanelManager:Close(gPanelId.S_KTV_GAME_PANEL)
		elseif self.data and self.data.hideEndPanel then
			if not mgr.skipTimeline then
				gTimelineManager:Timeline_Stop(mgr.timelineName)
			end

			gPanelManager:Close(gPanelId.S_KTV_GAME_PANEL)
		else
			gPanelManager:SetActiveById(gPanelId.S_KTV_GAME_PANEL, false)
			gPanelManager:CheckShow(gPanelId.S_KTV_GAME_END_PANEL, {
				musicId = musicId,
				score = self.score,
				maxCombo = self.maxCombo,
				perfectCount = self.perfectCount,
				greatCount = self.greatCount,
				missCount = self.missCount,
				totalPossible = self.totalPossible or self:CalculateTotalPossible()
			})
		end
	end)
end
