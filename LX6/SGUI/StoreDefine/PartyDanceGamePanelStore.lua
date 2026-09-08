-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\PartyDanceGamePanelStore.lua
-- Decompiled from: 01072_PartyDanceGamePanelStore.lua_9d4c6eada805.luajit

local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local gMusicGameManager = gMusicGameManager
local Mathf = UnityEngine.Mathf
local Vector3 = UnityEngine.Vector3
C_PartyDanceGamePanelStore = DefClass("C_PartyDanceGamePanelStore", C_PartyDanceGamePanelStore, C_StoreGroup)
GroupName2Class.PartyDanceGamePanelStore = C_PartyDanceGamePanelStore
local M = C_PartyDanceGamePanelStore
local SELECT_TYPE = {
	["NH~"] = 0,
	["k\\x8f\\x8e\\x9c\\x93"] = 1
}
local TRACK_COUNT = 4
local NoteState = {
	["\\x99\\xb4\\xa4f(\\xfb7"] = 3,
	["Cy\\xa2p|\\xa0\\xf7TyspK"] = 2,
	["S&q^"] = 0,
	["pO~`@?"] = 1
}
local EvaluatePage = {
	["\\xe9\\xde'\\xe5"] = "\\xc9\\xde'\\xe5",
	["W+nH"] = "w+nH",
	["]-r_"] = "}-r_",
	["T-s^"] = "t-s^"
}
local TapPage = {
	["lI`pm3"] = "LI`pm3",
	["\\xb3;.8H\\x8fD\\xca$\\xaf\\xbd"] = "\\x93;.8H\\x8fD\\xca$\\xaf\\xbd"
}
local PressStatePage = {
	["vI|{K\r<"] = "VI|{K\r<",
	["\\xe9\\xc9\r!\\xf5"] = "\\xc9\\xc9\r!\\xf5"
}

M.ctor = function(self)
end

M.DefineAllVariables = function(self)
	self.trackWidget = {}
	self.danceBtnWidget = {}
	self.danceBtnGo = {}
	self.danceBtnAnim = {}
	self.danceTemplateAnim = {}
	self.circleGo = {}
	self.circleAnim = {}
	self.circleWidget = {}
	self.outCircleRT = {}
	self.circleAddRT = {}
	self.innerCircleRT = {}
	self.progress = {}
	self.templateAnim = {}
	self.activeNotes = {}
	self.pressNote = {}
	self.pressUp = {}
	self.musicInfo = {}
	self.recordMusicCount = {}
	self.gridId = 0
	self.lastCheckedGridId = -1
	self.combNum = 0
	self.score = 0
	self.generateGridTime = 0
	self.hitGridPerfectBeforeWidth = 3
	self.hitGridPerfectBehindWidth = 2
	self.hitGridGreatBeforeWidth = 5
	self.hitGridGreatBehindWidth = 4
	self.hitPerfectBeforeTime = 0
	self.hitPerfectBehindTime = 0
	self.hitGreatBeforeTime = 0
	self.hitGreatBehindTime = 0
	self.waitGridToCheckHit = 16
	self.isPlay = false
	self.isMusicStarting = false
	self.musicUuid = nil
	self.hasAcceptedPlayShow = false
	self.hasAcceptedPlayStart = false
	self.hasLivehouseGameEnded = false
	self.hasShownEndPanel = false
	self.liveHouseMusicId = nil
	self.liveHouseId = nil
	self.difficulty = 1
	self.playLiveHouseId = nil
	self.liveHouseMusicCfg = nil
	self.gameplayTimelineName = nil
	self.onInterrupt = nil
	self.hasEditNote = false
	self.resetTimers = {}
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.LIVEHOUSE_PLAY_START] = self.CreateAction(self, "PlayStart"),
		[gEventConstants.LIVEHOUSE_PLAY_SHOW] = self.CreateAction(self, "PlayShow"),
		[gEventConstants.LIVEHOUSE_SHOW_END_PANEL] = self.CreateAction(self, "ShowEndPanel"),
		[gEventConstants.LIVEHOUSE_CLOSE_END_PANEL] = self.CreateAction(self, "CloseEndPanel")
	}
end

M.RegisterWidget = function(self)
	for i = 1, TRACK_COUNT do
		self.bindData["button" .. i].luaPress = self.CreateActionWithArgs(self, "OnPressBtnClick", i)
		self.bindData["button" .. i].luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtnClick", i)
	end
end

M.InitPanelInfo = function(self)
	for i = 1, TRACK_COUNT do
		local trackBind = self.bindData["Track" .. i]
		local trackTrans = trackBind.transform
		self.trackWidget[i] = trackBind
		self.templateAnim[i] = trackBind:GetComponent(typeof(UnityEngine.Animation))
		local widgetTrans = trackTrans:Find("Widget")
		local danceBtnTrans = widgetTrans and widgetTrans:Find("S_danceBtn")

		if danceBtnTrans then
			self.danceBtnWidget[i] = danceBtnTrans.GetComponent(danceBtnTrans, typeof(SGUI.UComponent))
			self.danceBtnGo[i] = danceBtnTrans.gameObject
			self.danceBtnAnim[i] = danceBtnTrans.GetComponent(danceBtnTrans, typeof(UnityEngine.Animation))
		end

		local circleTrans = danceBtnTrans and danceBtnTrans:Find("ClickOffset/btn/Cicrle")

		if circleTrans then
			self.circleGo[i] = circleTrans.gameObject
			self.circleAnim[i] = circleTrans.GetComponent(circleTrans, typeof(UnityEngine.Animation))
			self.circleWidget[i] = circleTrans.GetComponent(circleTrans, typeof(SGUI.UWidget))
			local innerTargetTrans = circleTrans.Find(circleTrans, "Cicrle2")

			if innerTargetTrans then
				self.innerCircleRT[i] = innerTargetTrans.GetComponent(innerTargetTrans, typeof(UnityEngine.RectTransform))
				local outTrans = circleTrans.Find(circleTrans, "Cicrle/Cicrle (1)")

				if outTrans then
					self.outCircleRT[i] = outTrans.GetComponent(outTrans, typeof(UnityEngine.RectTransform))
					local addTrans = outTrans.Find(outTrans, "Cicrleadd")

					if addTrans then
						self.circleAddRT[i] = addTrans.GetComponent(addTrans, typeof(UnityEngine.RectTransform))
					end
				end
			end
		end

		local progressTrans = widgetTrans and widgetTrans:Find("Progress")

		if progressTrans then
			self.progress[i] = progressTrans.GetComponent(progressTrans, typeof(SGUI.UProgress))
		end
	end
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	data = data or {}
	self.isPlay = false
	self.isMusicStarting = false
	self.musicUuid = nil
	self.gridId = 0
	self.lastCheckedGridId = -1
	self.combNum = 0
	self.score = 0
	self.hasAcceptedPlayShow = false
	self.hasAcceptedPlayStart = false
	self.hasLivehouseGameEnded = false
	self.hasShownEndPanel = false
	self.activeNotes = {}
	self.pressNote = {}
	self.pressUp = {}
	self.resetTimers = {}
	self.liveHouseMusicId = data.liveHouseMusicId
	self.difficulty = data.difficulty or 1
	self.liveHouseId = data.liveHouseId
	self.hasEditNote = data.hasEditNote or false
	self.gameplayTimelineName = data.gameplayTimelineName or nil
	self.onInterrupt = data.onInterrupt or nil

	self:InitPanelInfo()
	self:InitMusicInfo(self.liveHouseMusicId)
	self:ResetAllTracks()

	self.bindData.combNum = "0"
	self.bindData.scoreNum = "0"
end

M.OnUpdate = function(self)
	self.GameMainUpdate(self)
end

M.OnClose = function(self)
	self:ClearAllResetTimers()

	self.onInterrupt = nil

	gSoundMgr:OnLeaveStateArea("UIPause")
end

M.OnDestroy = function(self)
	self.trackWidget = nil
	self.danceBtnWidget = nil
	self.danceBtnGo = nil
	self.danceBtnAnim = nil
	self.templateAnim = nil
	self.circleGo = nil
	self.circleAnim = nil
	self.circleWidget = nil
	self.outCircleRT = nil
	self.circleAddRT = nil
	self.innerCircleRT = nil
	self.progress = nil

	self.ClearAllResetTimers(self)
end

M.ResetAllTracks = function(self)
	for i = 1, TRACK_COUNT do
		self.ResetTrack(self, i)
	end
end

M.ResetTrack = function(self, track)
	if self.danceBtnWidget[track] then
		self.danceBtnWidget[track]:TryChangePage("Evaluate", EvaluatePage.None, true, false)
	end

	if self.trackWidget[track] then
		self.trackWidget[track]:TryChangePage("PressState", PressStatePage.Unpressed, true, false)
		self.trackWidget[track]:TryChangePage("Tap", TapPage.OnlyClick, true, false)
	end

	if self.danceBtnWidget[track] then
		self.danceBtnWidget[track]:SetActive(false)
	end

	if self.circleWidget[track] then
		self.circleWidget[track]:SetActive(false)
	end

	if self.outCircleRT[track] then
		self.outCircleRT[track].localScale = Vector3.New(1, 1, 1)
	end

	if self.circleAddRT[track] then
		self.circleAddRT[track].localScale = Vector3.New(1, 1, 1)
	end

	if self.progress[track] then
		self.progress[track]:SetActive(false)

		self.progress[track].value = 0
	end

	self.activeNotes[track] = nil
end

M.InitMusicInfo = function(self, liveHouseMusicId)
	gMusicGameManager:SetMusicInfo(liveHouseMusicId)

	self.liveHouseMusicCfg = LivehouseMusicConfig.GetConfig(liveHouseMusicId)
	self.liveHouseMusicId = liveHouseMusicId

	self:SetGenerateTime()
	self:CheckMusicInfoList()
end

M.SetGenerateTime = function(self)
	self.generateGridTime = gMusicGameManager.generateGridTime
	self.QTE_APPEAR_TIME = LivehouseConfig.PartyDanceAppearTime or 1.5
	self.CIRCLE_ANIM_DURATION = LivehouseConfig.PartyDanceShrinkDelay or 0.5
	self.RESET_DELAY = LivehouseConfig.PartyDanceResetDelay or 0.8
	local NoteSensitivity, NoteSensitivityTime = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		NoteSensitivity = LivehouseConfig.NoteSensitivity
		NoteSensitivityTime = LivehouseConfig.NoteSensitivityTime
	else
		NoteSensitivity = LivehouseConfig.MobileNoteSensitivity
		NoteSensitivityTime = LivehouseConfig.MobileNoteSensitivityTime
	end

	if NoteSensitivity then
		self.hitGridPerfectBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(gBattleSpiritMgr.currentSpiritTemplateId, NoteSensitivity.hitGridPerfectBeforeWidth)
		self.hitGridPerfectBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(gBattleSpiritMgr.currentSpiritTemplateId, NoteSensitivity.hitGridPerfectBehindWidth)
		self.hitGridGreatBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(gBattleSpiritMgr.currentSpiritTemplateId, NoteSensitivity.hitGridGreatBeforeWidth)
		self.hitGridGreatBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(gBattleSpiritMgr.currentSpiritTemplateId, NoteSensitivity.hitGridGreatBehindWidth)
	end

	self.hitPerfectBeforeTime = self:GetJudgeTimeValue(NoteSensitivityTime and NoteSensitivityTime.PerfectBeforeTime, self.hitGridPerfectBeforeWidth)
	self.hitPerfectBehindTime = self:GetJudgeTimeValue(NoteSensitivityTime and NoteSensitivityTime.PerfectBehindTime, self.hitGridPerfectBehindWidth)
	self.hitGreatBeforeTime = self:GetJudgeTimeValue(NoteSensitivityTime and NoteSensitivityTime.GreatBeforeTime, self.hitGridGreatBeforeWidth)
	self.hitGreatBehindTime = self:GetJudgeTimeValue(NoteSensitivityTime and NoteSensitivityTime.GreatBehindTime, self.hitGridGreatBehindWidth)
	self.waitGridToCheckHit = self.generateGridTime * 0.6
end

M.GetGridTime = function(self, gridValue)
	if not gMusicGameManager.gridCountPerSecond or gMusicGameManager.gridCountPerSecond < 0 then
		return 0
	end

	return gridValue / gMusicGameManager.gridCountPerSecond
end

M.GetJudgeTimeValue = function(self, noteSensitivityTime, fallbackGridWidth)
	if noteSensitivityTime == nil then
		local judgeTime = gMusicGameManager:GetLivehouseNoteSensitivity(gBattleSpiritMgr.currentSpiritTemplateId, noteSensitivityTime)

		if judgeTime and judgeTime > 0 then
			return judgeTime
		end
	end

	return self.GetGridTime(self, fallbackGridWidth)
end

M.GetCurrentMusicPlayTime = function(self)
	if self.musicUuid then
		local soundData = gSoundMgr:GetSoundData(self.musicUuid)

		if soundData then
			local playTime = soundData.GetPlayPosition(soundData)

			if type(playTime) ~= "number" and playTime > 0 then
				return playTime
			end
		end
	end

	return self.GetGridTime(self, self.gridId)
end

M.GetNoteTargetTime = function(self, gridId)
	return self.GetGridTime(self, gridId)
end

M.GetCurrentMusicGridValue = function(self, currentMusicTime)
	local musicTime = currentMusicTime

	if musicTime ~= nil then
		musicTime = self.GetCurrentMusicPlayTime(self)
	end

	return musicTime * (gMusicGameManager.gridCountPerSecond or 0)
end

M.GetNoteVisualProgressByGrid = function(self, currentMusicGridValue, targetGridId)
	local generateGridTime = self.generateGridTime or 0

	if generateGridTime < 0 then
		return targetGridId < currentMusicGridValue and 1 or 0
	end

	local visualProgress = 1 - (targetGridId - currentMusicGridValue) / generateGridTime

	return Mathf.Clamp01(visualProgress)
end

M.IsTimeInJudgeWindow = function(self, inputTime, targetTime, beforeTime, behindTime)
	if inputTime ~= nil then
		return false
	end

	local deltaTime = inputTime - targetTime

	return behindTime > deltaTime and deltaTime < -beforeTime
end

M.ReadMusicNoteList = function(self)
	local beatMapName = self.liveHouseMusicCfg and self.liveHouseMusicCfg.BeatMap

	if string.is_null_or_empty(beatMapName) then
		print_error("[PartyDanceGamePanelStore] liveHouseMusicCfg.BeatMap is null, LivehouseMusicConfig=" .. tostring(self.liveHouseMusicId))

		return nil
	end

	local filePath = "GameRes/MusicGame/" .. beatMapName
	local data = gResourceManager.Manager:ReadRawFileAllText(filePath)

	if data then
		local json = require("cjson/json")
		local content = json.decode(data)

		if content.notes then
			return content.notes
		else
			return content
		end
	else
		print_error("[PartyDanceGamePanelStore] read file error ", filePath)
	end

	return nil
end

M.CheckMusicInfoList = function(self)
	local musicInfo = {}
	local musicNoteList = self.ReadMusicNoteList(self)

	if not musicNoteList then
		self.musicInfo = {}

		return
	end

	local count = 0

	for _, info in ipairs(musicNoteList) do
		local gridData = musicInfo[info.gridId]

		if gridData ~= nil then
			musicInfo[info.gridId] = {
				info
			}
		else
			table.insert(gridData, info)
		end

		count = count + 1
	end

	if gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] ~= nil then
		gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] = {}
	end

	gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] = {
		["\\f\\xa9tE\\xb3\\xfedeopX"] = 0,
		["nNzm,"] = 0,
		["_s\\xbeqI\\xb1\\xe6deopX"] = 0,
		["tH˼\\x90+\\xb7\\xc7\\xfc"] = 0,
		allCount = count
	}
	self.musicInfo = table.clone(musicInfo)
end

M.GameMainUpdate = function(self)
	if not self.isPlay or table.isNilOrEmpty(self.musicInfo) then
		return
	end

	local currentMusicTime = self:GetCurrentMusicPlayTime()
	local currentMusicGridValue = self:GetCurrentMusicGridValue(currentMusicTime)
	local lastChecked = self.lastCheckedGridId
	local appearGridOffset = math.floor(self.QTE_APPEAR_TIME * (gMusicGameManager.gridCountPerSecond or 0))

	for gId = lastChecked + 1, self.gridId do
		local triggerGridId = gId + appearGridOffset
		local curData = self.musicInfo[triggerGridId]
		slot11 = pairs
		slot13 = curData or {}

		for _, pointInfo in slot11(slot13) do
			self.TriggerNote(self, pointInfo, triggerGridId)
		end
	end

	self.lastCheckedGridId = self.gridId

	for track, noteInfo in pairs(self.activeNotes) do
		if noteInfo.state ~= NoteState.Shrinking then
			self.UpdateCircleScale(self, track, noteInfo, currentMusicTime)
			self.CheckNoteHit(self, track, noteInfo, currentMusicTime, currentMusicGridValue)

			if noteInfo.state ~= NoteState.Shrinking then
				local noteEndGridId = noteInfo.gridId

				if currentMusicTime <= self.GetNoteTargetTime(self, noteEndGridId) + self.hitGreatBehindTime then
					self.OnNoteMiss(self, track)
				end
			end
		elseif noteInfo.state ~= NoteState.LongPressing then
			local noteEndGridId = noteInfo.gridId + (noteInfo.length or 0)
			local noteStartTime = self:GetNoteTargetTime(noteInfo.gridId)
			local noteEndTime = self:GetNoteTargetTime(noteEndGridId)
			local totalDuration = noteEndTime - noteStartTime

			if totalDuration <= 0 then
				local elapsed = currentMusicTime - noteStartTime
				local t = Mathf.Clamp01(elapsed / totalDuration)

				if self.progress[track] then
					self.progress[track].value = 1 - t

					if t > 1 then
						self.progress[track]:SetActive(false)
					end
				end
			end

			self.CheckNoteUp(self, track, noteInfo, currentMusicTime)

			if noteInfo.state ~= NoteState.LongPressing then
				if noteEndTime < currentMusicTime then
					self.OnNoteHit(self, track, gMusicGameManager.EffectType.Perfect)
				elseif currentMusicTime <= noteEndTime + self.hitGreatBehindTime then
					self.OnNoteMiss(self, track)
				end
			end
		end
	end

	for track, pressTime in pairs(self.pressUp) do
		if pressTime >= currentMusicTime - 1 then
			self.pressUp[track] = nil
		end
	end
end

M.TriggerNote = function(self, pointInfo, gridIndex)
	if pointInfo ~= nil then
		return
	end

	local track = pointInfo.track

	if track ~= nil or track <= 1 or TRACK_COUNT >= track then
		return
	end

	if self.activeNotes[track] then
		local prevNote = self.activeNotes[track]

		if prevNote.state == NoteState.Resolved then
			self.OnNoteMiss(self, track)
		end
	end

	if self.resetTimers[track] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.resetTimers[track])

		self.resetTimers[track] = nil
	end

	local noteInfo = {
		gridId = gridIndex,
		track = track,
		pointType = pointInfo.pointType,
		length = pointInfo.length or 1,
		state = NoteState.Shrinking
	}
	self.activeNotes[track] = noteInfo
	local trackWidget = self.trackWidget[track]

	if trackWidget then
		if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
			trackWidget.TryChangePage(trackWidget, "Tap", TapPage.LongPressed, true, false)

			if self.progress[track] then
				self.progress[track].value = 1
			end
		else
			trackWidget.TryChangePage(trackWidget, "Tap", TapPage.OnlyClick, true, false)
		end
	end

	if self.danceBtnWidget[track] then
		self.danceBtnWidget[track]:TryChangePage("Evaluate", EvaluatePage.None, true, false)
	end

	if self.danceBtnWidget[track] then
		self.danceBtnWidget[track]:SetActive(true)
	end

	if self.danceBtnAnim[track] then
		self.danceBtnAnim[track]:Play()
	end

	if self.circleWidget[track] then
		self.circleWidget[track]:SetActive(true)
	end
end

M.UpdateCircleScale = function(self, track, noteInfo, currentMusicTime)
	local outRT = self.outCircleRT[track]
	local innerRT = self.innerCircleRT[track]

	if not outRT or not innerRT then
		return
	end

	local noteTime = self.GetNoteTargetTime(self, noteInfo.gridId)
	local shrinkStartTime = noteTime - (self.QTE_APPEAR_TIME - self.CIRCLE_ANIM_DURATION)

	if currentMusicTime >= shrinkStartTime then
		return
	end

	local totalDuration = self.QTE_APPEAR_TIME - self.CIRCLE_ANIM_DURATION

	if totalDuration < 0 then
		return
	end

	local elapsed = currentMusicTime - shrinkStartTime
	local progress = Mathf.Clamp01(elapsed / totalDuration)
	local outerWidth = outRT.rect.width
	local innerWidth = innerRT.rect.width

	if outerWidth <= 0 then
		local targetScale = innerWidth / outerWidth
		local scale = Vector3.Lerp(Vector3.New(1, 1, 1), Vector3.New(targetScale, targetScale, 1), progress)
		outRT.localScale = scale
	end
end

M.CheckNoteHit = function(self, track, noteInfo, currentMusicTime, currentMusicGridValue)
	if noteInfo.state == NoteState.Shrinking then
		return
	end

	if self.gridId + self.waitGridToCheckHit >= noteInfo.gridId then
		return
	end

	if table.isNilOrEmpty(self.pressNote) then
		return
	end

	local pressTime = self.pressNote[track]

	if pressTime ~= nil then
		return
	end

	local noteTime = self.GetNoteTargetTime(self, noteInfo.gridId)

	if self.IsTimeInJudgeWindow(self, pressTime, noteTime, self.hitGreatBeforeTime, self.hitGreatBehindTime) then
		if noteInfo.pointType ~= gMusicGameManager.PointType.LongPress then
			noteInfo.state = NoteState.LongPressing

			if self.circleWidget[track] then
				self.circleWidget[track]:SetActive(false)
			end

			if self.trackWidget[track] then
				self.trackWidget[track]:TryChangePage("PressState", PressStatePage.Pressed, true, false)
			end

			if self.progress[track] then
				self.progress[track].value = 1
			end
		elseif self.IsTimeInJudgeWindow(self, pressTime, noteTime, self.hitPerfectBeforeTime, self.hitPerfectBehindTime) then
			self.OnNoteHit(self, track, gMusicGameManager.EffectType.Perfect)
		else
			self.OnNoteHit(self, track, gMusicGameManager.EffectType.Great)
		end
	end

	self.pressNote[track] = nil
end

M.CheckNoteUp = function(self, track, noteInfo, currentMusicTime)
	if noteInfo.state == NoteState.LongPressing then
		return
	end

	if table.isNilOrEmpty(self.pressUp) then
		return
	end

	local releaseTime = self.pressUp[track]

	if releaseTime ~= nil then
		return
	end

	local noteUpTime = self:GetNoteTargetTime(noteInfo.gridId + (noteInfo.length or 0))

	if self:IsTimeInJudgeWindow(releaseTime, noteUpTime, self.hitGreatBeforeTime, self.hitGreatBehindTime) then
		if self.IsTimeInJudgeWindow(self, releaseTime, noteUpTime, self.hitPerfectBeforeTime, self.hitPerfectBehindTime) then
			self.OnNoteHit(self, track, gMusicGameManager.EffectType.Perfect)
		else
			self.OnNoteHit(self, track, gMusicGameManager.EffectType.Great)
		end

		self.pressUp[track] = nil
	else
		self.OnNoteMiss(self, track)
	end
end

M.OnNoteHit = function(self, track, effectType)
	local noteInfo = self.activeNotes[track]

	if not noteInfo then
		return
	end

	noteInfo.state = NoteState.Resolved

	self.PlayEffect(self, effectType, track)
	self.PlayNoteSound(self, effectType)

	if self.circleWidget[track] then
		self.circleWidget[track]:SetActive(false)
	end

	if noteInfo.pointType ~= gMusicGameManager.PointType.LongPress and self.progress[track] then
		self.progress[track]:SetActive(false)
	end

	if effectType ~= gMusicGameManager.EffectType.Perfect then
		self.recordMusicCount.PerfectCount = (self.recordMusicCount.PerfectCount or 0) + 1
		self.combNum = self.combNum + 1
	elseif effectType ~= gMusicGameManager.EffectType.Great then
		self.recordMusicCount.GreatCount = (self.recordMusicCount.GreatCount or 0) + 1
		self.combNum = self.combNum + 1
	end

	self.UpdateCombo(self)
	self.UpdateScore(self)

	if noteInfo.pointType ~= gMusicGameManager.PointType.LongPress and self.trackWidget[track] then
		self.trackWidget[track]:TryChangePage("PressState", PressStatePage.Unpressed, true, false)
		self.trackWidget[track]:TryChangePage("Tap", TapPage.OnlyClick, true, false)
	end

	self.pressNote[track] = nil
	self.pressUp[track] = nil

	self.StartResetTimer(self, track)
end

M.OnNoteMiss = function(self, track)
	local noteInfo = self.activeNotes[track]

	if not noteInfo then
		return
	end

	noteInfo.state = NoteState.Resolved

	self.PlayEffect(self, gMusicGameManager.EffectType.Miss, track)
	self.PlayNoteSound(self, gMusicGameManager.SoundType.Miss)

	if self.circleWidget[track] then
		self.circleWidget[track]:SetActive(false)
	end

	if noteInfo.pointType ~= gMusicGameManager.PointType.LongPress and self.progress[track] then
		self.progress[track]:SetActive(false)
	end

	self.recordMusicCount.MissCount = (self.recordMusicCount.MissCount or 0) + 1
	self.combNum = 0

	self:UpdateCombo()
	self:UpdateScore()

	if noteInfo.pointType ~= gMusicGameManager.PointType.LongPress and self.trackWidget[track] then
		self.trackWidget[track]:TryChangePage("PressState", PressStatePage.Unpressed, true, false)
		self.trackWidget[track]:TryChangePage("Tap", TapPage.OnlyClick, true, false)
	end

	self.pressNote[track] = nil
	self.pressUp[track] = nil

	self.StartResetTimer(self, track)
end

M.StartResetTimer = function(self, track)
	if self.resetTimers[track] then
		gLuaTimeMgrUtils.CancelUnitDelay(self.resetTimers[track])
	end

	self.resetTimers[track] = gLuaTimeMgrUtils.Delay(function ()
		if not gPanelManager:IsPanelShowing(self.m_Id) then
			return
		end

		self.resetTimers[track] = nil

		self:ResetTrack(track)
	end, self.RESET_DELAY)
end

M.ClearAllResetTimers = function(self)
	if self.resetTimers then
		for track, timerId in pairs(self.resetTimers) do
			if timerId then
				gLuaTimeMgrUtils.CancelUnitDelay(timerId)
			end
		end

		self.resetTimers = {}
	end
end

M.PlayEffect = function(self, effectType, track)
	local danceBtnWidget = self.danceBtnWidget[track]

	if not danceBtnWidget then
		return
	end

	if effectType ~= gMusicGameManager.EffectType.Perfect then
		danceBtnWidget.TryChangePage(danceBtnWidget, "Evaluate", EvaluatePage.Perfect, true, false)
		self.PlayControllerVibration(self, "ExHandle_QTECommon2")
	elseif effectType ~= gMusicGameManager.EffectType.Great then
		danceBtnWidget.TryChangePage(danceBtnWidget, "Evaluate", EvaluatePage.Good, true, false)
		self.PlayControllerVibration(self, "ExHandle_QTECommon1")
	elseif effectType ~= gMusicGameManager.EffectType.Miss then
		danceBtnWidget.TryChangePage(danceBtnWidget, "Evaluate", EvaluatePage.Miss, true, false)
	end

	if self.danceBtnAnim[track] then
		self.danceBtnAnim[track]:Play("S_danceBtn_close")
	end
end

M.PlayNoteSound = function(self, soundType)
	if soundType ~= gMusicGameManager.SoundType.Perfect then
		self.PlayControllerVibration(self, "ExHandle_QTECommon2")
	elseif soundType ~= gMusicGameManager.SoundType.Great then
		self.PlayControllerVibration(self, "ExHandle_QTECommon1")
	end

	local noteSound = LivehouseConfig.NoteSound and LivehouseConfig.NoteSound[soundType]

	if noteSound then
		gSoundMgr:PlaySoundByTid(noteSound.soundID)
	end
end

M.UpdateCombo = function(self)
	self.bindData.combNum = tostring(self.combNum)
end

M.UpdateScore = function(self)
	local tapScore = LivehouseConfig.TapScore

	if not tapScore then
		return
	end

	local score = 0
	score = score + (self.recordMusicCount.PerfectCount or 0) * tapScore.perfecttapscore
	score = score + (self.recordMusicCount.GreatCount or 0) * tapScore.successtapscore
	score = score + (self.recordMusicCount.MissCount or 0) * tapScore.misstapscore
	self.score = score
	self.bindData.scoreNum = tostring(score)
end

M.PlayControllerVibration = function(self, soundName)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gSoundMgr:PlaySoundByExternalSource(soundName, LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

M.PlayMusic = function(self, liveHouseMusicId)
	if self.isMusicStarting or self.musicUuid then
		return
	end

	self.isMusicStarting = true
	slot2 = gSoundMgr

	slot2:PlaySoundByTid(self.liveHouseMusicCfg.BgmId, nil, , function (data)
		self.musicUuid = data
		self.isMusicStarting = false
		self.playLiveHouseId = liveHouseMusicId
		self.recordMusicCount = gMusicGameManager:SetRecordMusicInfo(liveHouseMusicId, 0, 0, 0)
		self.recordMusicCount.allCount = gMusicGameManager.RecordMusicInfo[liveHouseMusicId].allCount
		gMusicGameManager.musicState = false
	end, nil, , , function (uuid, name)
		local gridId = name

		if type(gridId) == "number" then
			gridId = tonumber(name)
		end

		self.gridId = gridId
	end)
end

M.StopMusic = function(self)
	self.isMusicStarting = false

	if self.musicUuid then
		gSoundMgr:StopSound(self.musicUuid)

		self.musicUuid = nil
		self.isPlay = false
	end
end

M.StopCurrentLivehouseTimeline = function(self)
	local timelineName = gMusicGameManager:GetCurrentLivehouseTimelineName() or self.liveHouseMusicCfg and self.liveHouseMusicCfg.TimeineName

	if timelineName and gTimelineManager:Timeline_IsPlaying() then
		gTimelineManager:Timeline_Stop(timelineName)
	end

	gMusicGameManager:SetCurrentLivehouseTimelineName(nil)
end

M.GetGameplayTimelineName = function(self)
	return self.gameplayTimelineName or gMusicGameManager:GetLivehouseGameplayTimelineName()
end

M.IsGameplayTimelineActive = function(self)
	local currentTimelineName = gMusicGameManager:GetCurrentLivehouseTimelineName()
	local gameplayTimelineName = self:GetGameplayTimelineName()

	return not string.is_null_or_empty(currentTimelineName) and currentTimelineName ~= gameplayTimelineName
end

M.PlayStart = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	local isGameplayTimelineActive = self.IsGameplayTimelineActive(self)

	if not isGameplayTimelineActive then
		return
	end

	if self.hasAcceptedPlayStart then
		return
	end

	if self.isPlay or self.isMusicStarting or self.musicUuid then
		return
	end

	self.hasAcceptedPlayStart = true
	self.isPlay = true

	self.PlayMusic(self, self.liveHouseMusicId)
end

M.PlayShow = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.hasAcceptedPlayShow = true
end

M.ShowEndPanel = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	self.isPlay = false

	self.StopMusic(self)

	self.hasLivehouseGameEnded = true

	if self.hasShownEndPanel then
		return
	end

	self.hasShownEndPanel = true

	if gMusicGameManager.RecordMusicInfo[self.playLiveHouseId] then
		gMusicGameManager.RecordMusicInfo[self.playLiveHouseId].PerfectCount = self.recordMusicCount.PerfectCount or 0
		gMusicGameManager.RecordMusicInfo[self.playLiveHouseId].GreatCount = self.recordMusicCount.GreatCount or 0
		gMusicGameManager.RecordMusicInfo[self.playLiveHouseId].MissCount = self.recordMusicCount.MissCount or 0
	end

	gPanelManager:CheckShow(gPanelId.PARTY_DANCE_END_PANEL, {
		id = self.playLiveHouseId,
		liveHouseId = self.liveHouseId,
		difficulty = self.difficulty,
		musicUuid = self.musicUuid,
		score = self.score,
		perfectCount = self.recordMusicCount.PerfectCount or 0,
		goodCount = self.recordMusicCount.GreatCount or 0,
		missCount = self.recordMusicCount.MissCount or 0,
		rankLevel = gMusicGameManager:GetScoreLevel(self.playLiveHouseId)
	})
end

M.CloseEndPanel = function(self)
	if not self.STATE_EnableOnce then
		return
	end

	gPanelManager:Close(gPanelId.PARTY_DANCE_END_PANEL)
	self:StopCurrentLivehouseTimeline()
	gPanelManager:Close(gPanelId.PARTY_DANCE_GAME_PANEL)
end

M.OnPressBtnClick = function(self, track)
	if self.isPlay then
		local pressTime = self.GetCurrentMusicPlayTime(self)
		self.pressNote[track] = pressTime
	end
end

M.OnReleaseBtnClick = function(self, track)
	if self.isPlay then
		local releaseTime = self.GetCurrentMusicPlayTime(self)

		if self.pressNote[track] then
			self.pressNote[track] = nil
		end

		self.pressUp[track] = releaseTime
	end
end
