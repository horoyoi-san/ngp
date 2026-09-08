-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\NiuRouWanPanelStore.lua
-- Decompiled from: 00933_NiuRouWanPanelStore.lua_ddd9d3287e52.luajit

local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local GameObject = UnityEngine.GameObject
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local gMusicGameManager = gMusicGameManager
C_NiuRouWanPanelStore = DefClass("C_NiuRouWanPanelStore", C_NiuRouWanPanelStore, C_StoreGroup)
GroupName2Class.NiuRouWanPanelStore = C_NiuRouWanPanelStore
local M = C_NiuRouWanPanelStore

M.ctor = function(self)
end

local LineType = {
	["^-jU"] = 2,
	["5"] = 1
}
local SELECT_TYPE = {
	["NH~"] = 0,
	["k\\x8f\\x8e\\x9c\\x93"] = 1
}
local TrackList = {
	1,
	3,
	4,
	6
}
M.SignalType = {
	["a\\xab\\xa4\\xbb\\xe5"] = 55115,
	["\\xabfb"] = 55112,
	[".A\\x96\\x86\\x97"] = 55113,
	["a\\xab\\xa4\\xbb\\xe7"] = 55116,
	["~\\xba\\xa3\\xbd\\xa2"] = 55111,
	[".A\\x96\\x86\\x97"] = 55114
}

M.DefineAllEnumsAutoGen = function(self)
	self.hasNpcPlayEnum = {
		["\\x86iu"] = 0,
		[""] = 1
	}
	self.isShowCountDownEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowQteSlot1Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowQteSlot2Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowQteSlot3Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowQteSlot4Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isPauseEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.isShowCombEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowPanelEnum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowPart1Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.isShowPart2Enum = {
		["r+y^"] = 1,
		["i*rL"] = 0
	}
	self.ShowCombTypeEnum = {
		["Y\\xb7\\xb2\\xaa\\xe6"] = 0,
		["Y\\xb7\\xb2\\xaa\\xe4"] = 2,
		["Y\\xb7\\xb2\\xaa\\xe7"] = 1,
		["Y\\xb7\\xb2\\xaa\\xe5"] = 3
	}
	self.useGoldFingerEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.isShowGmToolEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.hasNpcPlayEnum = nil
	self.isShowCountDownEnum = nil
	self.isShowQteSlot1Enum = nil
	self.isShowQteSlot2Enum = nil
	self.isShowQteSlot3Enum = nil
	self.isShowQteSlot4Enum = nil
	self.isPauseEnum = nil
	self.isShowCombEnum = nil
	self.isShowPanelEnum = nil
	self.isShowPart1Enum = nil
	self.isShowPart2Enum = nil
	self.ShowCombTypeEnum = nil
	self.useGoldFingerEnum = nil
	self.isShowGmToolEnum = nil
end

M.OnAwake = function(self)
	self:InitDefaultInfo()
	self:InitPanelInfo()

	local gestureListener = self.bindData.simpleBtn:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	gestureListener.onFingerStateChange = self:CreateAction("SimpleClick")
	self.mainGestureListener = gestureListener
	self.bindData.pauseBtnClick.luaClick = self:CreateAction("OnPauseBtnClick")
	self.bindData.slot1BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 1)
	self.bindData.slot2BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 2)
	self.bindData.slot3BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 3)
	self.bindData.slot4BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 4)

	if gCS.LuaUtils.IsDebug then
		self.bindData.btnSettle.luaClick = self.CreateAction(self, "OnSettleBtnClick")
		self.bindData.btnGoldFinger.luaClick = self.CreateAction(self, "OnGoldFingerBtnClick")
		self.bindData.btnGoSuccess.luaClick = self.CreateAction(self, "GMToSuccess")
	end

	self.bindData.button1.luaPress = self.CreateActionWithArgs(self, "OnPressBtnClick", 1)
	self.bindData.button1.luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtnClick", 1)
	self.bindData.button3.luaPress = self.CreateActionWithArgs(self, "OnPressBtnClick", 3)
	self.bindData.button3.luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtnClick", 3)
	self.bindData.button4.luaPress = self.CreateActionWithArgs(self, "OnPressBtnClick", 4)
	self.bindData.button4.luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtnClick", 4)
	self.bindData.button6.luaPress = self.CreateActionWithArgs(self, "OnPressBtnClick", 6)
	self.bindData.button6.luaRelease = self.CreateActionWithArgs(self, "OnReleaseBtnClick", 6)
	self.msgEvents = {
		[gEventConstants.LIVEHOUSE_SHOW_PART] = self.CreateAction(self, "ShowPart"),
		[gEventConstants.LIVEHOUSE_GAME_END] = self.CreateAction(self, "GameEnd"),
		[gEventConstants.LIVEHOUSE_PLAY_HIDE] = self.CreateAction(self, "PlayHide"),
		[gEventConstants.LIVEHOUSE_PLAY_DIALOG] = self.CreateAction(self, "PlayDialog"),
		[gEventConstants.LIVEHOUSE_SHOW_QTE_SLOT] = self.CreateAction(self, "ShowQteSlot"),
		[gEventConstants.LIVEHOUSE_HIDE_QTE_SLOT] = self.CreateAction(self, "HideQteSlot"),
		[gEventConstants.LIVEHOUSE_SHOW_END_PANEL] = self.CreateAction(self, "ShowEndPanel"),
		[gEventConstants.LIVEHOUSE_CLOSE_END_PANEL] = self.CreateAction(self, "CloseEndPanel"),
		[gEventConstants.LIVEHOUSE_SHOW_GM_TOOL] = self.CreateAction(self, "ShowGMTool")
	}

	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.isInPanel = false
	self.mainGestureListener = nil

	self.ClearMessageEvents(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.bindData.isShowGmTool = SELECT_TYPE.FALSE
	self.bindData.isShowPanel = SELECT_TYPE.FALSE
	self.bindData.hasNpcPlay = SELECT_TYPE.FALSE
	self.bindData.isPause = SELECT_TYPE.FALSE
	self.bindData.useGoldFinger = SELECT_TYPE.FALSE
	self.combNum = 0
	self.isPause = false
	self.isPlay = false
	self.readyToPlay = false
	self.isMusicStarting = false
	self.musicUuid = nil
	self.hasAcceptedPlayShow = false
	self.hasAcceptedPlayStart = false
	self.hasLivehouseGameEnded = false
	self.isSettingLivehouseResult = false
	self.waitShowEndPanel = false
	self.hasShownEndPanel = false
	self.endPanelMusicUuid = nil
	self.hasEditNote = true
	self.ComboEffectSounds = LivehouseConfig.ComboEffect

	self.InitMusicInfo(self, data)
	self.UnActiveNoteTemplate(self)
	self.SendSignal(self, self.SignalType.Start)
	self.PlayShow(self)
	gLuaTimeMgrUtils.Delay(function ()
		self:PlayStart()
	end, 3, nil, , true)
end

local addTime = 3

M.OnUpdate = function(self)
	if self.readyToPlay then
		addTime = addTime - Time.deltaTime

		if addTime < 0 then
			self.readyToPlay = false
			self.bindData.isShowCountDown = SELECT_TYPE.FALSE
			self.bindData.isShowPanel = SELECT_TYPE.TRUE
			addTime = 3
		end
	end
end

M.StartReadyCountdown = function(self)
	addTime = 3
	self.readyToPlay = true
	self.bindData.isShowCountDown = SELECT_TYPE.TRUE
	self.bindData.isPause = SELECT_TYPE.FALSE
end

M.OnClose = function(self)
	self.ReleaseAllLongPressEffects(self)

	self.onInterrupt = nil

	if self.mUpdateHandler then
		FixedUpdateBeat:RemoveListener(self.mUpdateHandler)
	end

	gLuaUIMgr.ui_panel_Livehouse_GamePanel = nil

	gSoundMgr:OnLeaveStateArea("UIPause")
end

M.OnActiveDeviceChange = function(self, device)
end

M.InitDefaultInfo = function(self)
	self.isInPanel = true
	self.buttonGo = {}
	self.effectGo = {}
	self.trackTrans = {}
	self.playingNote = {}
	self.playingEffect = {}
	self.playingQteEffect = {}
	self.playingLongPress = {}
	self.playingLongPressEffect = {}
	self.noteOverList = {}
	self.cacheListDict = {}
	self.cacheLineListDict = {}
	self.cacheEffectDict = {}
	self.pressNote = {}
	self.pressUp = {}
	self.longPressNote = {}
	self.recordMusicCount = {}
	self.musicInfo = {}
	self.PointAttr = {
		["\\xa6\\xb0\\x98i?\\xf26"] = 1,
		["\\xa6\\xb8\\x98i?\\xf26"] = 0.7
	}
	self.gridId = 0
	self.curGrid = 0
	self.hitGridPerfectBeforeWidth = 3
	self.hitGridPerfectBehindWidth = 2
	self.hitGridGreatBeforeWidth = 5
	self.hitGridGreatBehindWidth = 4
	self.hitPerfectBeforeTime = 0
	self.hitPerfectBehindTime = 0
	self.hitGreatBeforeTime = 0
	self.hitGreatBehindTime = 0
	self.waitGridToCheckHit = 16
	self.readyToPlay = false
	self.isPlay = false
	self.isMusicStarting = false
	self.hasAcceptedPlayShow = false
	self.hasAcceptedPlayStart = false
	self.hasLivehouseGameEnded = false
	self.isSettingLivehouseResult = false
	self.waitShowEndPanel = false
	self.hasShownEndPanel = false
	self.endPanelMusicUuid = nil
	self.mUpdateHandler = nil
	self.TopKeyTrack = {
		1,
		6
	}
end

M.InitPanelInfo = function(self)
	local PointType = gMusicGameManager.PointType
	self.buttonGo[PointType.Single] = self.bindData.BtnNormal.gameObject
	self.buttonGo[PointType.LongPress] = self.bindData.BtnPress.gameObject
	self.buttonGo[PointType.Double] = self.bindData.BtnDouble.gameObject
	local EffectType = gMusicGameManager.EffectType
	self.effectGo[EffectType.Miss] = self.bindData.Miss.gameObject
	self.effectGo[EffectType.Great] = self.bindData.Great.gameObject
	self.effectGo[EffectType.Perfect] = self.bindData.Perfect.gameObject
	self.effectGo[EffectType.LongPress] = self.bindData.LongPress.gameObject
	self.effectGo[EffectType.QteClick] = self.bindData.QteClick.gameObject
	self.effectGo[EffectType.QteMiss] = self.bindData.QteMiss.gameObject
	self.effectGo[EffectType.Click] = self.bindData.SimpleClick.gameObject
	self.trackTrans = {}

	for _, i in ipairs(TrackList) do
		self.trackTrans[i] = self.bindData["Track" .. i]
	end

	self.trackPoint = {}

	for _, i in ipairs(TrackList) do
		self.trackPoint[i] = {
			startPos = self.bindData["trackStart" .. i].localPosition,
			endPos = self.bindData["trackEnd" .. i].localPosition,
			longPressTemplate = self.bindData["LongPressLine" .. i].gameObject
		}
		self.trackPoint[i].distance = gUtils:GetDistance(self.trackPoint[i].startPos, self.trackPoint[i].endPos)
	end
end

M.UnActiveNoteTemplate = function(self)
	self.bindData.BtnNormal.gameObject:SetActive(false)
	self.bindData.BtnPress.gameObject:SetActive(false)
	self.bindData.BtnDouble.gameObject:SetActive(false)
	self.bindData.Miss.gameObject:SetActive(false)
	self.bindData.Great.gameObject:SetActive(false)
	self.bindData.Perfect.gameObject:SetActive(false)
	self.bindData.LongPress.gameObject:SetActive(false)

	for _, i in ipairs(TrackList) do
		self.trackPoint[i].longPressTemplate:SetActive(false)
	end

	for i = 1, 4 do
		self.bindData["isShowQteSlot" .. i] = SELECT_TYPE.FALSE
	end
end

M.InitMusicInfo = function(self, liveHouseMusicId)
	gMusicGameManager:SetMusicInfo(liveHouseMusicId)

	self.inviteNpcTid = gBattleSpiritMgr.currentSpiritTemplateId

	if gMusicGameManager.InviteNpcId and gMusicGameManager.InviteNpcId <= 0 then
		local npcCfg = gMusicGameManager.NpcDailyList[gMusicGameManager.InviteNpcId]

		if npcCfg then
			self.bindData.hasNpcPlay = SELECT_TYPE.TRUE
			local fsCfg = NpcCultivationConfig.GetConfig(gMusicGameManager.InviteNpcId)

			if fsCfg then
				self.inviteNpcTid = fsCfg.FightSpiritID
			end
		end
	end

	self.liveHouseMusicCfg = LivehouseMusicConfig.GetConfig(liveHouseMusicId)
	self.liveHouseMusicId = liveHouseMusicId
	self.bindData.combNum1 = 0
	self.bindData.combNum2 = 0
	self.bindData.combNum3 = 0
	self.bindData.isShowComb = SELECT_TYPE.FALSE

	self.SetGenerateTime(self)
	self.CheckMusicInfoList(self)
end

M.SetGenerateTime = function(self)
	local length = gUtils:GetDistance(self.trackPoint[1].startPos, self.trackPoint[1].endPos)
	local generateGridTime = math.floor(gMusicGameManager.bpmPerBar * gMusicGameManager.gridCountPerBpm * length / gMusicGameManager.noteSpeed) + 1

	if gMusicGameManager.generateGridTime >= generateGridTime then
		print_error("移动时间已经超过了生成时间，可能会出现问题，联系策划和程序修改规则！！！ generateGridTime = " .. generateGridTime .. "  gMusicGameManager.generateGridTime = " .. gMusicGameManager.generateGridTime)
	end

	self.generateGridTime = generateGridTime >= gMusicGameManager.generateGridTime and generateGridTime or gMusicGameManager.generateGridTime
	local NoteSensitivity, NoteSensitivityTime = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		NoteSensitivity = LivehouseConfig.NoteSensitivity
		NoteSensitivityTime = LivehouseConfig.NoteSensitivityTime
	else
		NoteSensitivity = LivehouseConfig.MobileNoteSensitivity
		NoteSensitivityTime = LivehouseConfig.MobileNoteSensitivityTime
	end

	if NoteSensitivity then
		self.hitGridPerfectBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridPerfectBeforeWidth)
		self.hitGridPerfectBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridPerfectBehindWidth)
		self.hitGridGreatBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridGreatBeforeWidth)
		self.hitGridGreatBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridGreatBehindWidth)

		print_debug("22 hitGridPerfectBeforeWidth :" .. self.hitGridPerfectBeforeWidth .. "  hitGridPerfectBehindWidth :" .. self.hitGridPerfectBehindWidth .. "  hitGridGreatBeforeWidth :" .. self.hitGridGreatBeforeWidth .. "  hitGridGreatBehindWidth :" .. self.hitGridGreatBehindWidth)
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
		local judgeTime = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, noteSensitivityTime)

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
		print_error("[LivehouseGamePanelStore] liveHouseMusicCfg.BeatMap is null, LivehouseMusicConfig=" .. tonumber(self.liveHouseMusicId))

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
		print_error("[LivehouseGamePanelStore] read file error ", filePath)
	end

	return nil
end

M.CheckMusicInfoList = function(self)
	local musicInfo = {}
	local musicNoteList = self.ReadMusicNoteList(self)

	if self.hasEditNote then
		self.bindData.isShowPanel = SELECT_TYPE.TRUE

		for i = 1, 3 do
			self.bindData["isShowPart" .. i] = SELECT_TYPE.TRUE
		end

		self.readyToPlay = true
		self.bindData.isShowCountDown = SELECT_TYPE.TRUE
	else
		for i = 1, 3 do
			self.bindData["isShowPart" .. i] = SELECT_TYPE.FALSE
		end
	end

	local count = 0
	local doubleNoteCount = 0

	for _, info in ipairs(musicNoteList) do
		if info.track == 2 then
			if info.track == 5 then
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
		end
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

	for i, gridNoteList in pairs(musicInfo) do
		if #gridNoteList <= 1 then
			local count = 0

			for p, info in pairs(gridNoteList) do
				if info.pointType ~= gMusicGameManager.PointType.Single then
					count = count + 1
				end
			end

			if count > 2 then
				local isDouble = false

				for t, info in pairs(gridNoteList) do
					if info.pointType ~= gMusicGameManager.PointType.Single then
						isDouble = true
						info.pointType = gMusicGameManager.PointType.Double
					end
				end

				if isDouble then
					doubleNoteCount = doubleNoteCount + 1
				end
			end
		end
	end

	gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].allCount = count - doubleNoteCount
	self.musicInfo = table.clone(musicInfo)
end

M.GameEndNotFinish = function(self)
	self.SendSignal(self, self.SignalType.End)
	self.StopMusic(self)
	self.StopCurrentLivehouseTimeline(self)

	if self.onInterrupt then
		self.onInterrupt()
	end

	gMusicGameManager:DestroyInviteNpcUnit()

	gMusicGameManager.InviteNpcId = 0

	gPanelManager:Close(gPanelId.LIVEHOUSE_GAME_PANEL)
end

M.StopCurrentLivehouseTimeline = function(self)
end

M.GameEnd = function(self)
	self.FinishGameplay(self, false)
end

M.FinishGameplay = function(self, showEndPanelAfterSettle)
	if self.isInPanel ~= false then
		return
	end

	if showEndPanelAfterSettle then
		self.waitShowEndPanel = true
	end

	if self.hasLivehouseGameEnded then
		if self.waitShowEndPanel and not self.isSettingLivehouseResult then
			self.ShowEndPanel(self)
		end

		return
	end

	self.hasLivehouseGameEnded = true
	self.isPlay = false
	self.readyToPlay = false
	self.bindData.isShowCountDown = SELECT_TYPE.FALSE
	self.bindData.isShowPanel = SELECT_TYPE.FALSE
	self.endPanelMusicUuid = self.musicUuid

	self:SendSignal(self.SignalType.End)

	if gMusicGameManager:IsFinishMusic(self.playLiveHouseId) then
		if self.hasEditNote then
			self:StopMusic()
			self:StopCurrentLivehouseTimeline()
			gPanelManager:Close(gPanelId.NIU_ROU_WAN_PANEL)
		else
			self.StopMusic(self)

			self.isSettingLivehouseResult = true
		end
	else
		self:StopMusic()
		self:StopCurrentLivehouseTimeline()

		local endTimelineParams = {
			liveHouseId = self.liveHouseId,
			musicId = self.playLiveHouseId,
			inviteNpcId = gMusicGameManager.InviteNpcId,
			inviteNpcPid = gMusicGameManager.InviteNpcUnitPid
		}
		slot3 = gPartyManager
		endTimelineParams.skipLivehouseEndTimeline = slot3:ShouldSkipLivehouseEndTimeline(self.playLiveHouseId)
		slot3 = gPanelManager

		slot3:Close(gPanelId.LIVEHOUSE_GAME_PANEL)

		slot3 = gMusicGameManager
		local isWin = slot3:IsLivehouseMusicWin(self.playLiveHouseId)
		slot4 = gMusicGameManager

		if not slot4:PlayLivehouseEndTimeline(endTimelineParams, isWin, function ()
			gMusicGameManager.InviteNpcId = 0
		end) then
			gMusicGameManager:DestroyInviteNpcUnit()

			gMusicGameManager.InviteNpcId = 0
		end
	end
end

M.ShowEndPanel = function(self)
	if self.isInPanel ~= false then
		return
	end

	if not self.hasLivehouseGameEnded then
		self.FinishGameplay(self, true)

		return
	end

	if self.isSettingLivehouseResult then
		self.waitShowEndPanel = true

		return
	end

	if self.hasShownEndPanel then
		return
	end

	self.hasShownEndPanel = true

	gPanelManager:CheckShow(gPanelId.LIVEHOUSE_GAME_END_PANEL, {
		id = self.playLiveHouseId,
		liveHouseId = self.liveHouseId,
		difficulty = self.difficulty,
		musicUuid = self.endPanelMusicUuid
	})
end

M.CloseEndPanel = function(self)
	if self.isInPanel ~= false then
		return
	end

	self.waitShowEndPanel = false
	self.hasShownEndPanel = true
	local endTimelineParams = {
		liveHouseId = self.liveHouseId,
		musicId = self.playLiveHouseId,
		inviteNpcId = gMusicGameManager.InviteNpcId,
		inviteNpcPid = gMusicGameManager.InviteNpcUnitPid
	}
	slot2 = gPartyManager
	endTimelineParams.skipLivehouseEndTimeline = slot2:ShouldSkipLivehouseEndTimeline(self.playLiveHouseId)
	slot2 = gPanelManager

	slot2:Close(gPanelId.LIVEHOUSE_GAME_END_PANEL)
	self:StopCurrentLivehouseTimeline()

	slot2 = gPanelManager

	slot2:Close(gPanelId.LIVEHOUSE_GAME_PANEL)

	slot2 = gMusicGameManager
	local isWin = slot2:IsLivehouseMusicWin(self.playLiveHouseId)
	slot3 = gMusicGameManager

	if not slot3:PlayLivehouseEndTimeline(endTimelineParams, isWin, function ()
		gMusicGameManager.InviteNpcId = 0
	end) then
		gMusicGameManager:DestroyInviteNpcUnit()

		gMusicGameManager.InviteNpcId = 0
	end
end

M.PlayMusic = function(self, liveHouseMusicId)
	if self.isPause then
		self.ReplayMusic(self)

		self.isPause = false
		self.bindData.isPause = SELECT_TYPE.FALSE

		return
	end

	if self.isMusicStarting or self.musicUuid then
		return
	end

	self.isMusicStarting = true
	slot2 = gSoundMgr

	slot2:PlaySoundByTid(self.liveHouseMusicCfg.BgmId, nil, , function (data)
		self.musicUuid = data
		self.isMusicStarting = false
		self.playLiveHouseId = liveHouseMusicId
		self.recordMusicCount = gMusicGameManager:SetRecordMusicInfo(liveHouseMusicId)
		gMusicGameManager.musicState = false

		if not self.mUpdateHandler then
			self.mUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

			FixedUpdateBeat:AddListener(self.mUpdateHandler)
		end
	end, function ()
		gPanelManager:Close(gPanelId.NIU_ROU_WAN_PANEL)
	end, nil, , function (uuid, name)
		local gridId = name

		if type(gridId) == "number" then
			gridId = tonumber(name)
		end

		self.gridId = gridId
	end)
end

M.PlayNoteSound = function(self, soundType)
	if soundType ~= gMusicGameManager.SoundType.Perfect then
		self.PlayControllerVibration(self, "ExHandle_QTECommon2")
	elseif soundType ~= gMusicGameManager.SoundType.Great then
		self.PlayControllerVibration(self, "ExHandle_QTECommon1")
	end

	local noteSound = LivehouseConfig.NoteSound[soundType]

	if noteSound then
		gSoundMgr:PlaySoundByTid(noteSound.soundID)
	else
		print_error("noteSound is nil  soundType = " .. soundType)
	end
end

M.PauseMusic = function(self)
	if self.musicUuid then
		gSoundMgr:OnEnterStateArea("UIPause", {
			gSoundMgr.GameStateGroup.PanelType.StateName
		}, {
			gSoundMgr.GameStateGroup.PanelType.MenuPause
		}, gSoundMgr.GameStatePriority.Normal)
		gSoundMgr:Pause(self.musicUuid)

		self.isPause = true
		self.bindData.isPause = SELECT_TYPE.TRUE
		self.isPlay = false
		local timelineName = gMusicGameManager:GetCurrentLivehouseTimelineName() or self.liveHouseMusicCfg and self.liveHouseMusicCfg.TimeineName

		if timelineName then
			gTimelineManager:Timeline_Pause(timelineName, true)
		end
	end
end

M.StopMusic = function(self)
	self.ReleaseAllLongPressEffects(self)

	self.isMusicStarting = false

	if self.musicUuid then
		print_notice("StopMusic   musicUuid" .. self.musicUuid)
		gSoundMgr:StopSound(self.musicUuid)

		self.musicUuid = nil
		self.isPlay = false

		if self.mUpdateHandler then
			FixedUpdateBeat:RemoveListener(self.mUpdateHandler)

			self.mUpdateHandler = nil
		end
	end
end

M.ReplayMusic = function(self)
	if self.musicUuid then
		gSoundMgr:Resume(self.musicUuid)

		self.isPlay = true
		self.bindData.isShowCountDown = SELECT_TYPE.FALSE
		local timelineName = gMusicGameManager:GetCurrentLivehouseTimelineName() or self.liveHouseMusicCfg and self.liveHouseMusicCfg.TimeineName

		if timelineName then
			gTimelineManager:Timeline_Pause(timelineName, false)
		end

		gSoundMgr:OnLeaveStateArea("UIPause")
	end
end

M.FixedUpdate = function(self)
	if self.isPlay and not table.isNilOrEmpty(self.musicInfo) then
		local currentMusicTime = self.GetCurrentMusicPlayTime(self)
		local currentMusicGridValue = self.GetCurrentMusicGridValue(self, currentMusicTime)
		local gridIndex = self.gridId + self.generateGridTime
		local curData = self.musicInfo[gridIndex]

		if curData then
			for index, pointInfo in pairs(curData) do
				if pointInfo and not self.IsNotePlaying(self, pointInfo.track, gridIndex) then
					if self.playingNote[pointInfo.track] ~= nil then
						self.playingNote[pointInfo.track] = {}
					end

					if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
						pointInfo.templateLineUp = self.AddLineByTemplate(self, pointInfo.track)
						pointInfo.template2 = self.AddNoteInTrack(self, pointInfo)
					end

					pointInfo.template = self.AddNoteInTrack(self, pointInfo)
					self.playingNote[pointInfo.track][gridIndex] = pointInfo
				end
			end
		end

		for track, pointList in pairs(self.playingNote) do
			if not table.isNilOrEmpty(pointList) then
				local minGridId = 0

				for gridId, v in pairs(pointList) do
					if minGridId ~= 0 then
						minGridId = gridId
					end

					minGridId = minGridId >= gridId and minGridId or gridId
				end

				for gridId, pointInfo in pairs(pointList) do
					local t = self:GetNoteVisualProgressByGrid(currentMusicGridValue, gridId)
					local nowTemplatePos = Vector3.Lerp(self.trackPoint[track].startPos, self.trackPoint[track].endPos, t)
					pointInfo.template.transform.localPosition = nowTemplatePos
					local tempScale = Mathf.Clamp(self.PointAttr.minScale + (self.PointAttr.maxScale - self.PointAttr.minScale) * t, self.PointAttr.minScale, self.PointAttr.maxScale)

					pointInfo.template:SetLocalScale(tempScale)

					if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
						local noteUpGridId = gridId + (pointInfo.length or 0)
						local t2 = self:GetNoteVisualProgressByGrid(currentMusicGridValue, noteUpGridId)
						local tailPos = self.trackPoint[track].startPos

						if pointInfo.template2 then
							local nowTemplate2Pos = Vector3.Lerp(self.trackPoint[track].startPos, self.trackPoint[track].endPos, t2)
							pointInfo.template2.transform.localPosition = nowTemplate2Pos
							local tempScale2 = Mathf.Clamp(self.PointAttr.minScale + (self.PointAttr.maxScale - self.PointAttr.minScale) * t2, self.PointAttr.minScale, self.PointAttr.maxScale)

							pointInfo.template2:SetLocalScale(tempScale2)

							tailPos = nowTemplate2Pos
						end

						if pointInfo.templateLineUp then
							local distance = gUtils:GetDistance(pointInfo.template.transform.localPosition, tailPos)

							pointInfo.templateLineUp:SetLocalPosition(tailPos)

							pointInfo.templateLineUp:GetComponent(typeof(SGUI.UImage)).fillAmount = distance / self.trackPoint[track].distance
						end

						if (gMusicGameManager.GMFullPerfect or self.IsNpcHelpPerferct(self, track)) and gridId < currentMusicGridValue and not pointInfo.hasPressNote1 then
							pointInfo.hasPressNote1 = true
							self.pressNote[track] = currentMusicTime
						end
					end

					local isHasRemoveNote = false

					if minGridId ~= gridId then
						if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
							self.CheckNoteHit(self, track, gridId, pointInfo)

							isHasRemoveNote = self.CheckNoteUp(self, track, gridId, pointInfo)
						else
							isHasRemoveNote = self.CheckNoteHit(self, track, gridId, pointInfo)
						end
					end

					local noteEndGridId = gridId + (pointInfo.length or 0)

					if currentMusicTime <= self:GetNoteTargetTime(noteEndGridId) + self.hitGreatBehindTime and not isHasRemoveNote then
						if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
							self.RemoveNoteInTrack(self, pointInfo.template2, pointInfo.pointType, gridId, track)
							self.ReleaseLineTemplate(self, pointInfo.templateLineUp, track)
						end

						self.RemoveNoteInTrack(self, pointInfo.template, pointInfo.pointType, gridId, track)

						if gMusicGameManager.GMFullPerfect or self.IsNpcHelpPerferct(self, track) then
							self.CheckCombNumPlayAnim(self)

							self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

							self.PlayEffect(self, gMusicGameManager.EffectType.Perfect, track)
							self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
						else
							self.combNum = 0

							if self.bindData.isShowComb ~= SELECT_TYPE.TRUE then
								self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_close")

								if self.combTimer then
									self.combTimer:Stop()
								end

								self.combTimer = Timer.New(function ()
									self.combTimer = nil
									self.bindData.isShowComb = SELECT_TYPE.FALSE
								end, 0.2):Start()
							end

							self.recordMusicCount.MissCount = self.recordMusicCount.MissCount + 1

							self.PlayEffect(self, gMusicGameManager.EffectType.Miss, track)
							self.PlayNoteSound(self, gMusicGameManager.SoundType.Miss)
						end

						self.pressNote[track] = nil
					end
				end
			end
		end

		for track, pointInfo in pairs(self.playingLongPress) do
			if self.gridId <= pointInfo.gridId + pointInfo.length then
				self.ReleaseLongPressEffect(self, track)

				self.longPressNote[track] = nil
				self.playingLongPress[track] = nil
			end
		end

		for k, v in pairs(self.noteOverList) do
			self.playingNote[v.track][v.gridId] = nil
		end

		if not table.isNilOrEmpty(self.noteOverList) then
			table.clear(self.noteOverList)
		end

		for track, pressTime in pairs(self.pressUp) do
			if pressTime >= currentMusicTime then
				self.pressUp[track] = nil
				self.pressNote[track] = nil
			end
		end

		for track, effectInfo in pairs(self.playingEffect) do
			if not table.isNilOrEmpty(effectInfo) and self.gridId > effectInfo.gridId + gMusicGameManager.gridCountPerSecond / 2 then
				self.ReleaseEffectTemplate(self, effectInfo.obj, effectInfo.type)

				self.playingEffect[track] = {}
			end
		end

		for track, effectInfo in pairs(self.playingQteEffect) do
			if not table.isNilOrEmpty(effectInfo) and self.gridId > effectInfo.gridId + gMusicGameManager.gridCountPerSecond / 2 then
				self.ReleaseEffectTemplate(self, effectInfo.obj, effectInfo.type)

				self.playingQteEffect[track] = {}
			end
		end

		for track, effectInfo in pairs(self.playingLongPressEffect) do
			if not table.isNilOrEmpty(effectInfo) and table.isNilOrEmpty(self.playingLongPress[track]) then
				self.ReleaseLongPressEffect(self, track)
			end
		end
	end
end

M.CheckNoteHit = function(self, track, gridId, pointInfo)
	if gridId >= self.gridId + self.waitGridToCheckHit or table.isNilOrEmpty(self.pressNote) then
		return false
	end

	local pressTime = self.pressNote[track]

	if pressTime ~= nil then
		return false
	end

	local noteTime = self.GetNoteTargetTime(self, gridId)

	if self.IsTimeInJudgeWindow(self, pressTime, noteTime, self.hitGreatBeforeTime, self.hitGreatBehindTime) then
		if not self.playingLongPress[track] then
			self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_open")
			self:CheckCombNumPlayAnim()
		end

		if self.IsTimeInJudgeWindow(self, pressTime, noteTime, self.hitPerfectBeforeTime, self.hitPerfectBehindTime) then
			if not self.playingLongPress[track] then
				self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

				self.PlayEffect(self, gMusicGameManager.EffectType.Perfect, track)
				self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
			end
		elseif not self.playingLongPress[track] then
			self.recordMusicCount.GreatCount = self.recordMusicCount.GreatCount + 1

			self.PlayEffect(self, gMusicGameManager.EffectType.Great, track)
			self.PlayNoteSound(self, gMusicGameManager.SoundType.Great)
		end

		if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
			self.playingLongPress[track] = pointInfo

			self.PlayEffect(self, gMusicGameManager.EffectType.LongPress, track)
		end
	elseif gMusicGameManager.GMFullPerfect or self.IsNpcHelpPerferct(self, track) then
		self.CheckCombNumPlayAnim(self)

		self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

		self.PlayEffect(self, gMusicGameManager.EffectType.Perfect, track)
		self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
	else
		self.combNum = 0

		if self.bindData.isShowComb ~= SELECT_TYPE.TRUE then
			self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_close")

			if self.combTimer then
				self.combTimer:Stop()
			end

			self.combTimer = Timer.New(function ()
				self.combTimer = nil
				self.bindData.isShowComb = SELECT_TYPE.FALSE
			end, 0.2):Start()
		end

		self.PlayEffect(self, gMusicGameManager.EffectType.Miss, track)
		self.PlayNoteSound(self, gMusicGameManager.SoundType.Miss)

		self.recordMusicCount.MissCount = self.recordMusicCount.MissCount + 1
	end

	if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
		self.RemoveNoteInTrack(self, pointInfo.template, pointInfo.pointType, gridId, track)
	else
		if self.longPressNote[track] ~= nil then
			self.longPressNote[track] = {}
		end

		self.longPressNote[track].pressGridId = self.pressNote[track]
		self.longPressNote[track].gridId = gridId
	end

	self.pressNote[track] = nil

	return true
end

M.CheckNoteUp = function(self, track, gridId, pointInfo)
	if self.longPressNote[track] ~= nil or self.longPressNote[track] and self.longPressNote[track].gridId == gridId or self.playingLongPress[track] ~= nil then
		return false
	end

	if gridId < self.gridId + self.waitGridToCheckHit and pointInfo.pointType ~= gMusicGameManager.PointType.LongPress and not table.isNilOrEmpty(self.pressUp) then
		local noteUpTime = self:GetNoteTargetTime(gridId + (pointInfo.length or 0))

		for pressTrack, releaseTime in pairs(self.pressUp) do
			if track ~= pressTrack then
				if self.IsTimeInJudgeWindow(self, releaseTime, noteUpTime, self.hitGreatBeforeTime, self.hitGreatBehindTime) then
					self:CheckCombNumPlayAnim()
					self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_open")

					if self:IsTimeInJudgeWindow(releaseTime, noteUpTime, self.hitPerfectBeforeTime, self.hitPerfectBehindTime) then
						self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

						self.PlayEffect(self, gMusicGameManager.EffectType.Perfect, track)
						self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
					else
						self.recordMusicCount.GreatCount = self.recordMusicCount.GreatCount + 1

						self.PlayEffect(self, gMusicGameManager.EffectType.Great, track)
						self.PlayNoteSound(self, gMusicGameManager.SoundType.Great)
					end
				elseif gMusicGameManager.GMFullPerfect or self.IsNpcHelpPerferct(self, track) then
					self.CheckCombNumPlayAnim(self)

					self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

					self.PlayEffect(self, gMusicGameManager.EffectType.Perfect, track)
					self.PlayNoteSound(self, gMusicGameManager.SoundType.Perfect)
				else
					self.combNum = 0

					if self.bindData.isShowComb ~= SELECT_TYPE.TRUE then
						self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_close")

						if self.combTimer then
							self.combTimer:Stop()
						end

						self.combTimer = Timer.New(function ()
							self.combTimer = nil
							self.bindData.isShowComb = SELECT_TYPE.FALSE
						end, 1):Start()
					end

					self.PlayEffect(self, gMusicGameManager.EffectType.Miss, track)
					self.PlayNoteSound(self, gMusicGameManager.SoundType.Miss)

					self.recordMusicCount.MissCount = self.recordMusicCount.MissCount + 1
				end

				self.pressUp[track] = nil
				self.longPressNote[track] = nil

				self.ReleaseLongPressEffect(self, track)

				self.playingLongPress[track] = nil

				self.RemoveNoteInTrack(self, pointInfo.template, pointInfo.pointType, gridId, track)
				self.RemoveNoteInTrack(self, pointInfo.template2, pointInfo.pointType, gridId, track)
				self.ReleaseLineTemplate(self, pointInfo.templateLineUp, track)

				return true
			end
		end
	end

	return false
end

M.AddNoteInTrack = function(self, pointInfo)
	local template = self.GetNewTemplateByType(self, pointInfo.pointType)

	template.SetParent(template, self.trackTrans[pointInfo.track])
	template.SetLocalPosition(template, self.trackPoint[pointInfo.track].startPos.x, self.trackPoint[pointInfo.track].startPos.y, self.trackPoint[pointInfo.track].startPos.z)
	template.SetLocalScale(template, self.PointAttr.minScale)
	template.SetActive(template, true)

	return template
end

M.GetNewTemplateByType = function(self, pointType)
	local template = nil

	if self.cacheListDict[pointType] == nil and #self.cacheListDict[pointType] <= 0 then
		template = self.cacheListDict[pointType][1]

		table.remove(self.cacheListDict[pointType], 1)
	else
		template = GameObject.Instantiate(self.buttonGo[pointType])

		template:GetComponent(typeof(SGUI.UWidget)):TryInit()
	end

	return template
end

M.RemoveNoteInTrack = function(self, obj, pointType, gridId, track)
	obj.transform:SetParent(self.bindData.pointPool)
	obj:SetActive(false)

	if self.cacheListDict[pointType] ~= nil then
		self.cacheListDict[pointType] = {}
	end

	table.insert(self.cacheListDict[pointType], obj)

	local note = {
		gridId = gridId,
		track = track
	}

	table.insert(self.noteOverList, note)
end

M.AddLineByTemplate = function(self, track)
	local templateLineUp = self.GetNewLineTemplateByTrack(self, track)

	templateLineUp.SetParent(templateLineUp, self.trackTrans[track])
	templateLineUp.SetLocalScale(templateLineUp, 1)
	templateLineUp.SetActive(templateLineUp, true)

	return templateLineUp
end

M.GetNewLineTemplateByTrack = function(self, track)
	if self.cacheLineListDict[track] ~= nil then
		self.cacheLineListDict[track] = {}
	end

	local templateLineUp = nil

	if self.cacheLineListDict[track][LineType.Up] == nil and #self.cacheLineListDict[track][LineType.Up] <= 0 then
		templateLineUp = self.cacheLineListDict[track][LineType.Up][1]

		table.remove(self.cacheLineListDict[track][LineType.Up], 1)
	else
		templateLineUp = GameObject.Instantiate(self.trackPoint[track].longPressTemplate)

		templateLineUp:GetComponent(typeof(SGUI.UWidget)):TryInit()
	end

	return templateLineUp
end

M.ReleaseLineTemplate = function(self, templateLineUp, track)
	templateLineUp.transform:SetParent(self.bindData.LinePool)
	templateLineUp:SetActive(false)

	if self.cacheLineListDict[track] ~= nil then
		self.cacheLineListDict[track] = {}
	end

	if self.cacheLineListDict[track][LineType.Up] ~= nil then
		self.cacheLineListDict[track][LineType.Up] = {}
	end

	table.insert(self.cacheLineListDict[track][LineType.Up], templateLineUp)
end

M.PlayEffect = function(self, effectType, track)
	if self.lastGridId ~= nil then
		self.lastGridId = 0
	end

	if self.bindData.isShowGmTool ~= SELECT_TYPE.TRUE then
		self.bindData.GMNoteCount = "Perfect :" .. self.recordMusicCount.PerfectCount .. "   Great:" .. self.recordMusicCount.GreatCount .. "  Miss:" .. self.recordMusicCount.MissCount
	end

	self.lastGridId = self.gridId
	local template = self.GetEffectTemplateByType(self, effectType)

	template.SetParent(template, self.trackTrans[track])
	template.SetLocalPosition(template, self.trackPoint[track].endPos.x, self.trackPoint[track].endPos.y, self.trackPoint[track].endPos.z)
	template.SetLocalScale(template, self.PointAttr.maxScale)
	template.SetActive(template, true)

	if effectType ~= gMusicGameManager.EffectType.LongPress then
		if not table.isNilOrEmpty(self.playingLongPressEffect[track]) then
			self.ReleaseEffectTemplate(self, self.playingLongPressEffect[track].obj, effectType)

			self.playingLongPressEffect[track] = {}
		end

		if not self.playingLongPressEffect[track] then
			self.playingLongPressEffect[track] = {}
		end

		self.playingLongPressEffect[track].obj = template
		self.playingLongPressEffect[track].type = effectType
		self.playingLongPressEffect[track].gridId = self.gridId
	else
		if not table.isNilOrEmpty(self.playingEffect[track]) then
			self.ReleaseEffectTemplate(self, self.playingEffect[track].obj, self.playingEffect[track].type)

			self.playingEffect[track] = {}
		end

		if not self.playingEffect[track] then
			self.playingEffect[track] = {}
		end

		self.playingEffect[track].obj = template
		self.playingEffect[track].type = effectType
		self.playingEffect[track].gridId = self.gridId
	end

	if table.isNilOrEmpty(self.playingNote[track]) then
		print_error("当前track = " .. track .. "  gridId = " .. self.gridId .. "  effectType = " .. effectType)
	end
end

M.PlayEffectToPos = function(self, effectType, pos)
	local template = self:GetEffectTemplateByType(effectType)

	template:SetLocalPosition(pos)
	template:SetLocalScale(self.PointAttr.maxScale)
	template:SetActive(true)
	template:SetParent(self.bindData.ClickEffectList)
	Timer.New(function ()
		self:ReleaseEffectTemplate(template, effectType)
	end, 1):Start()
end

M.PlayQteEffect = function(self, effectType, QteTrack)
	local template = self.GetEffectTemplateByType(self, effectType)
	local trackTrans = self.bindData["slot" .. QteTrack .. "BtnClick"].transform

	template.SetParent(template, self.bindData.QTEslot)
	template.SetLocalPosition(template, trackTrans.localPosition.x, trackTrans.localPosition.y, trackTrans.localPosition.z)
	template.SetLocalScale(template, self.PointAttr.maxScale)
	template.SetActive(template, true)

	if not table.isNilOrEmpty(self.playingQteEffect[QteTrack]) then
		self.ReleaseEffectTemplate(self, self.playingQteEffect[QteTrack].obj, self.playingQteEffect[QteTrack].type)

		self.playingQteEffect[QteTrack] = {}
	end

	if table.isNilOrEmpty(self.playingQteEffect[QteTrack]) then
		self.playingQteEffect[QteTrack] = {}
	end

	self.playingQteEffect[QteTrack].obj = template
	self.playingQteEffect[QteTrack].type = effectType
	self.playingQteEffect[QteTrack].gridId = self.gridId
end

M.GetEffectTemplateByType = function(self, effectType)
	local template = nil

	if self.cacheEffectDict[effectType] == nil and #self.cacheEffectDict[effectType] <= 0 then
		template = self.cacheEffectDict[effectType][1]

		table.remove(self.cacheEffectDict[effectType], 1)
	elseif effectType and self.effectGo[effectType] then
		template = GameObject.Instantiate(self.effectGo[effectType])

		if template then
			template:GetComponent(typeof(SGUI.UWidget)):TryInit()
		end
	end

	return template
end

M.ReleaseEffectTemplate = function(self, obj, effectType)
	if gCS.LuaUtils.IsNull(obj) then
		return
	end

	if obj ~= nil or obj.transform ~= nil then
		LX6.Utils.LogUtilsLua.SendToPopo("音游ReleaseEffectTemplate 失败， obj 为null effectType= " .. effectType, "leilei03")
		print_error("音游ReleaseEffectTemplate 失败， obj 为null effectType= " .. effectType)

		return
	end

	obj.transform:SetParent(self.bindData.EffectPool)
	obj:SetActive(false)

	if self.cacheEffectDict[effectType] ~= nil then
		self.cacheEffectDict[effectType] = {}
	end

	table.insert(self.cacheEffectDict[effectType], obj)
end

M.ReleaseLongPressEffect = function(self, track)
	local effectInfo = self.playingLongPressEffect[track]

	if table.isNilOrEmpty(effectInfo) then
		return
	end

	self.ReleaseEffectTemplate(self, effectInfo.obj, effectInfo.type)

	self.playingLongPressEffect[track] = {}
end

M.ReleaseAllLongPressEffects = function(self)
	for track, _ in pairs(self.playingLongPressEffect) do
		self.ReleaseLongPressEffect(self, track)
	end
end

M.IsNotePlaying = function(self, track, gridId)
	if not self.playingNote[track] then
		return false
	end

	return self.playingNote[track][gridId] == nil
end

M.IsNpcHelpPerferct = function(self, track)
	if self.bindData.hasNpcPlay ~= SELECT_TYPE.TRUE and table.contains(self.TopKeyTrack, track) then
		return true
	end

	return false
end

M.GetGameplayTimelineName = function(self)
	return self.gameplayTimelineName or gMusicGameManager:GetLivehouseGameplayTimelineName()
end

M.IsGameplayTimelineActive = function(self)
	return true
end

M.CheckCombNumPlayAnim = function(self)
	self.combNum = self.combNum + 1
	self.bindData.combNum1 = self.combNum
	self.bindData.combNum2 = self.combNum
	self.bindData.combNum3 = self.combNum

	if self.combTimer then
		self.combTimer:Stop()
	end

	if self.bindData.isShowComb ~= SELECT_TYPE.FALSE then
		self.bindData.isShowComb = SELECT_TYPE.TRUE
	end

	if self.combNum >= 50 then
		self.bindData.ShowCombType = 1
	elseif self.combNum > 50 and self.combNum >= 100 then
		self.bindData.ShowCombType = 2
	else
		self.bindData.ShowCombType = 3
	end

	for i = 1, #self.ComboEffectSounds do
		if self.combNum ~= self.ComboEffectSounds[i].combo then
			gSoundMgr:PlaySoundByTid(self.ComboEffectSounds[i].soundID)
		end
	end
end

M.CheckPlayDialog = function(self, str)
	if self.liveHouseMusicId and self.liveHouseMusicCfg then
		local scoreInfo = self.liveHouseMusicCfg.JumpTimelineClip
		local info = {}

		for i = 1, #scoreInfo do
			if scoreInfo[i].EventSenderClipName ~= str then
				table.insert(info, scoreInfo[i])
			end
		end

		local curScore = gMusicGameManager:GetScoreById(self.liveHouseMusicId)

		if info[1] and info[2] then
			local clipName = info[1].ClipName

			if info[2].score >= curScore then
				clipName = info[2].ClipName
			end

			local timelineName = gMusicGameManager:GetCurrentLivehouseTimelineName() or self.liveHouseMusicCfg.TimeineName

			gTimelineManager:Timeline_JumpTo(timelineName, clipName)
		else
			print_error("@yuanzhuochun@corp.netease.com livehouse scoreInfo error，EventSenderClipName与LIVEHOUSE_PLAY_DIALOG发来的string对不上 ，请策划查看配置  livehouseMusicId = " .. self.liveHouseMusicId .. "  str = " .. str)
		end
	end
end

M.SimpleClick = function(self)
	local pos = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		pos = gUtils:GetTouchPosition()
	else
		local suc = nil
		suc, pos = self.mainGestureListener:TryGetFinger1ScreenPos(nil)

		if not suc then
			return
		end
	end

	local uiPos = gUtils:ScreenToUIPosition(pos)

	self:PlayEffectToPos(gMusicGameManager.EffectType.Click, uiPos)
end

M.OnPauseBtnClick = function(self)
	self.PauseMusic(self)
end

M.OnSlotBtnClick = function(self, index)
	if self.bindData["isShowQteSlot" .. index] ~= SELECT_TYPE.TRUE then
		self.bindData["isShowQteSlot" .. index] = SELECT_TYPE.FALSE
		self.recordMusicCount.SpecialCount = self.recordMusicCount.SpecialCount + 1

		self.PlayQteEffect(self, gMusicGameManager.EffectType.QteClick, index)
		self.PlayControllerVibration(self, "ExHandle_QTECommon2")
	end
end

M.OnPressBtnClick = function(self, track)
	if self.isPlay then
		local pressTime = self.GetCurrentMusicPlayTime(self)
		self.pressNote[track] = pressTime
		local trackToSignal = {
			self.SignalType.Left1,
			[3] = self.SignalType.Left3,
			[4] = self.SignalType.Right1,
			[6] = self.SignalType.Right3
		}
		local signal = trackToSignal[track]

		if signal then
			self.SendSignal(self, signal)
		end
	end
end

M.OnReleaseBtnClick = function(self, track)
	if self.isPlay then
		local releaseTime = self.GetCurrentMusicPlayTime(self)

		if self.pressNote[track] then
			self.pressNote[track] = nil
		end

		self.pressUp[track] = releaseTime

		if not table.isNilOrEmpty(self.playingLongPress[track]) then
			self.ReleaseLongPressEffect(self, track)
		end
	end
end

M.OnSettleBtnClick = function(self)
	if not gCS.LuaUtils.IsPublish then
		if self.isGMJumpToSuccess then
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].PerfectCount = gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].allCount
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].GreatCount = 0
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].MissCount = 0
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].SpecialCount = 0
		else
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].PerfectCount = 0
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].GreatCount = 0
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].MissCount = gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].allCount
			gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId].SpecialCount = 0
		end

		self.GameEnd(self)
	end
end

M.OnGoldFingerBtnClick = function(self)
	if not gCS.LuaUtils.IsPublish then
		if self.bindData.useGoldFinger ~= SELECT_TYPE.TRUE then
			self.bindData.useGoldFinger = SELECT_TYPE.FALSE
			gMusicGameManager.GMFullPerfect = false
		else
			self.bindData.useGoldFinger = SELECT_TYPE.TRUE
			gMusicGameManager.GMFullPerfect = true
		end
	end
end

M.GMToSuccess = function(self)
	if not gCS.LuaUtils.IsPublish then
		self.isGMJumpToSuccess = not self.isGMJumpToSuccess
	end
end

M.PlayStart = function(self)
	if self.isInPanel ~= false then
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

M.ShowPart = function(self, _, part)
	if self.isInPanel ~= false then
		return
	end

	local partId = part and part[0] or nil

	if partId ~= nil then
		return
	end

	self.bindData["isShowPart" .. partId] = SELECT_TYPE.TRUE
end

M.PlayShow = function(self)
	if self.isInPanel ~= false then
		return
	end

	if self.hasAcceptedPlayShow then
		return
	end

	self.hasAcceptedPlayShow = true
	self.bindData.isShowPanel = SELECT_TYPE.TRUE

	self.StartReadyCountdown(self)
end

M.PlayHide = function(self)
	if self.isInPanel ~= false then
		return
	end

	self.bindData.isShowPanel = SELECT_TYPE.FALSE
	self.hasAcceptedPlayShow = false
end

M.PlayDialog = function(self, _, data)
	if self.isInPanel ~= false then
		return
	end

	self.CheckPlayDialog(self, data[0])
end

M.ShowQteSlot = function(self, _, data)
	if self.isInPanel ~= false then
		return
	end

	self.bindData["isShowQteSlot" .. data[0]] = SELECT_TYPE.TRUE
end

M.HideQteSlot = function(self, _, data)
	if self.isInPanel ~= false then
		return
	end

	if self.bindData["isShowQteSlot" .. data[0]] ~= SELECT_TYPE.TRUE then
		self.bindData["isShowQteSlot" .. data[0]] = SELECT_TYPE.FALSE

		self.PlayQteEffect(self, gMusicGameManager.EffectType.QteMiss, data[0])
	end
end

M.ShowGMTool = function(self)
	if self.isInPanel ~= false then
		return
	end

	if not gCS.LuaUtils.IsPublish then
		self.bindData.isShowGmTool = SELECT_TYPE.TRUE
	end
end

M.PlayControllerVibration = function(self, soundName)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gSoundMgr:PlaySoundByExternalSource(soundName, LX6.Audio.ExternalSourceType.Motion_2D)
	end
end

M.debugLog = true

M.SendSignal = function(self, signalType)
	if self.debugLog then
		print_debug("NiuRouWan SendSignal", signalType)
	end

	gCS.LogicStateMachineManager.SendGameplayInwardSignal(gCS.MyPlayerManager.PlayerUnit, signalType)
end
