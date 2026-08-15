local LivehouseConfig = LTConfig.LivehouseConfig
local LivehouseMusicConfig = LTConfig.LivehouseMusicConfig
local GameObject = UnityEngine.GameObject
local NoteInfo_Demo_Bgm1 = require("LX6/Manager/GamePlay/LiveHouse/NoteInfo_Demo_Bgm1")
local NoteInfo_Demo_Bgm2 = require("LX6/Manager/GamePlay/LiveHouse/NoteInfo_Demo_Bgm2")
local NoteInfo_Demo_Bgm3 = require("LX6/Manager/GamePlay/LiveHouse/NoteInfo_Demo_Bgm3")
local NpcCultivationConfig = LTConfig.NpcCultivationConfig
local gMusicGameManager = gMusicGameManager
C_LivehouseGamePanelStore = DefClass("C_LivehouseGamePanelStore", C_LivehouseGamePanelStore, C_StoreGroup)
GroupName2Class.LivehouseGamePanelStore = C_LivehouseGamePanelStore
local M = C_LivehouseGamePanelStore

function M:ctor()
	return
end

local LineType = {
	Down = 2,
	Up = 1
}
local SELECT_TYPE = {
	TRUE = 0,
	FALSE = 1
}

function M:OnAwake()
	self:InitDefaultInfo()
	self:InitPanelInfo()

	local gestureListener = self.bindData.simpleBtn:GetComponent(typeof(SGUI.EventSystems.GestureEventListener))
	gestureListener.onFingerStateChange = self:CreateAction("SimpleClick")
	self.mainGestureListener = gestureListener
	self.bindData.backBtnClick.luaClick = self:CreateAction("OnBackBtnClick")
	self.bindData.pauseBtnClick.luaClick = self:CreateAction("OnPauseBtnClick")
	self.bindData.playBtnClick.luaClick = self:CreateAction("OnPlayBtnClick")
	self.bindData.slot1BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 1)
	self.bindData.slot2BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 2)
	self.bindData.slot3BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 3)
	self.bindData.slot4BtnClick.luaClick = self:CreateActionWithArgs("OnSlotBtnClick", 4)

	if gCS.LuaUtils.IsDebug then
		self.bindData.btnSettle.luaClick = self:CreateAction("OnSettleBtnClick")
		self.bindData.btnGoldFinger.luaClick = self:CreateAction("OnGoldFingerBtnClick")
		self.bindData.btnGoSuccess.luaClick = self:CreateAction("GMToSuccess")
	end

	self.bindData.button1.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 1)
	self.bindData.button1.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 1)
	self.bindData.button2.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 2)
	self.bindData.button2.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 2)
	self.bindData.button3.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 3)
	self.bindData.button3.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 3)
	self.bindData.button4.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 4)
	self.bindData.button4.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 4)
	self.bindData.button5.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 5)
	self.bindData.button5.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 5)
	self.bindData.button6.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 6)
	self.bindData.button6.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 6)
	self.msgEvents = {
		[gEventConstants.LIVEHOUSE_PLAY_START] = self:CreateAction("PlayStart"),
		[gEventConstants.LIVEHOUSE_SHOW_PART] = self:CreateAction("ShowPart"),
		[gEventConstants.LIVEHOUSE_GAME_END] = self:CreateAction("GameEnd"),
		[gEventConstants.LIVEHOUSE_PLAY_SHOW] = self:CreateAction("PlayShow"),
		[gEventConstants.LIVEHOUSE_PLAY_HIDE] = self:CreateAction("PlayHide"),
		[gEventConstants.LIVEHOUSE_PLAY_DIALOG] = self:CreateAction("PlayDialog"),
		[gEventConstants.LIVEHOUSE_SHOW_QTE_SLOT] = self:CreateAction("ShowQteSlot"),
		[gEventConstants.LIVEHOUSE_HIDE_QTE_SLOT] = self:CreateAction("HideQteSlot"),
		[gEventConstants.LIVEHOUSE_SHOW_END_PANEL] = self:CreateAction("GameEnd"),
		[gEventConstants.LIVEHOUSE_SHOW_GM_TOOL] = self:CreateAction("ShowGMTool")
	}

	self:RegisterMessageEvents(self.msgEvents)
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
	self.isInPanel = false
	self.mainGestureListener = nil

	self:ClearMessageEvents()
end

function M:OnGroupEnable()
	return
end

function M:OnGroupDisable()
	return
end

function M:OnShow(panelId, data)
	self.bindData.isShowGmTool = SELECT_TYPE.FALSE
	self.bindData.isShowPanel = SELECT_TYPE.FALSE
	self.bindData.hasNpcPlay = SELECT_TYPE.FALSE
	self.bindData.isPause = SELECT_TYPE.FALSE
	self.bindData.useGoldFinger = SELECT_TYPE.FALSE
	self.combNum = 0
	self.isPause = false
	local liveHouseMusicId = data and data.liveHouseMusicId or 91131000
	self.difficulty = data and data.difficulty or 1
	self.bindData.difficultyType = self.difficulty - 1
	self.liveHouseId = data and data.liveHouseId or 91130000
	self.hasEditNote = data and data.hasEditNote or false
	self.ComboEffectSounds = LivehouseConfig.ComboEffect

	self:InitMusicInfo(self.liveHouseId, liveHouseMusicId)
	self:UnActiveNoteTemplate()
end

local addTime = 3

function M:OnUpdate()
	if self.readyToPlay then
		addTime = addTime - Time.deltaTime

		if addTime <= 0 then
			self.readyToPlay = false
			self.bindData.isShowCountDown = SELECT_TYPE.FALSE

			if self.isPlay == false then
				self.isPlay = true

				self:PlayMusic(self.liveHouseMusicId)
			end

			addTime = 3
		end
	end
end

function M:OnClose()
	if self.mUpdateHandler then
		FixedUpdateBeat:RemoveListener(self.mUpdateHandler)
	end

	gLuaUIMgr.ui_panel_Livehouse_GamePanel = nil

	gSoundMgr:OnLeaveStateArea("UIPause")
end

function M:OnLanguageChange(lang)
	return
end

function M:OnActiveDeviceChange(device)
	return
end

function M:InitDefaultInfo()
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
	self.waitLongPressMinNoteMove = {}
	self.musicInfo = {}
	self.PointAttr = {
		maxScale = 1,
		minScale = 0.7
	}
	self.gridId = 0
	self.curGrid = 0
	self.hitGridPerfectBeforeWidth = 3
	self.hitGridPerfectBehindWidth = 2
	self.hitGridGreatBeforeWidth = 5
	self.hitGridGreatBehindWidth = 4
	self.waitGridToCheckHit = 16
	self.readyToPlay = false
	self.isPlay = false
	self.mUpdateHandler = nil
	self.TopKeyTrack = {
		1,
		6
	}
end

function M:InitPanelInfo()
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

	for i = 1, gMusicGameManager.TrackCount do
		self.trackTrans[i] = self.bindData["Track" .. i]
	end

	self.trackPoint = {}

	for i = 1, gMusicGameManager.TrackCount do
		self.trackPoint[i] = {
			startPos = self.bindData["trackStart" .. i].localPosition,
			endPos = self.bindData["trackEnd" .. i].localPosition,
			longPressTemplate = self.bindData["LongPressLine" .. i].gameObject
		}
		self.trackPoint[i].distance = gUtils:GetDistance(self.trackPoint[i].startPos, self.trackPoint[i].endPos)
	end
end

function M:UnActiveNoteTemplate()
	self.bindData.BtnNormal.gameObject:SetActive(false)
	self.bindData.BtnPress.gameObject:SetActive(false)
	self.bindData.BtnDouble.gameObject:SetActive(false)
	self.bindData.Miss.gameObject:SetActive(false)
	self.bindData.Great.gameObject:SetActive(false)
	self.bindData.Perfect.gameObject:SetActive(false)
	self.bindData.LongPress.gameObject:SetActive(false)

	for i = 1, gMusicGameManager.TrackCount do
		self.trackPoint[i].longPressTemplate:SetActive(false)
	end

	for i = 1, 4 do
		self.bindData["isShowQteSlot" .. i] = SELECT_TYPE.FALSE
	end
end

function M:InitMusicInfo(liveHouseId, liveHouseMusicId)
	gMusicGameManager:SetMusicInfo(liveHouseMusicId)

	local cfg = LivehouseConfig.GetConfig(liveHouseId)

	if cfg then
		self.bindData.musicName = cfg.StoryName
	end

	self.inviteNpcTid = gBattleSpiritMgr.currentSpiritTemplateId

	if gMusicGameManager.InviteNpcId and gMusicGameManager.InviteNpcId > 0 then
		local npcCfg = gMusicGameManager.NpcDailyList[gMusicGameManager.InviteNpcId]

		if npcCfg then
			self.bindData.leftIcon = npcCfg.imageid
			self.bindData.rightIcon = npcCfg.imageid
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

	self:SetGenerateTime()
	self:CheckMusicInfoList()
end

function M:SetGenerateTime()
	local length = gUtils:GetDistance(self.trackPoint[1].startPos, self.trackPoint[1].endPos)
	local generateGridTime = math.floor(gMusicGameManager.bpmPerBar * gMusicGameManager.gridCountPerBpm * length / gMusicGameManager.noteSpeed) + 1

	if gMusicGameManager.generateGridTime < generateGridTime then
		print_error("移动时间已经超过了生成时间，可能会出现问题，联系策划和程序修改规则！！！ generateGridTime = " .. generateGridTime .. "  gMusicGameManager.generateGridTime = " .. gMusicGameManager.generateGridTime)
	end

	self.generateGridTime = generateGridTime < gMusicGameManager.generateGridTime and generateGridTime or gMusicGameManager.generateGridTime
	local NoteSensitivity = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		NoteSensitivity = LivehouseConfig.NoteSensitivity
	else
		NoteSensitivity = LivehouseConfig.MobileNoteSensitivity
	end

	if NoteSensitivity then
		self.hitGridPerfectBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridPerfectBeforeWidth)
		self.hitGridPerfectBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridPerfectBehindWidth)
		self.hitGridGreatBeforeWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridGreatBeforeWidth)
		self.hitGridGreatBehindWidth = gMusicGameManager:GetLivehouseNoteSensitivity(self.inviteNpcTid, NoteSensitivity.hitGridGreatBehindWidth)

		print("22 hitGridPerfectBeforeWidth :" .. self.hitGridPerfectBeforeWidth .. "  hitGridPerfectBehindWidth :" .. self.hitGridPerfectBehindWidth .. "  hitGridGreatBeforeWidth :" .. self.hitGridGreatBeforeWidth .. "  hitGridGreatBehindWidth :" .. self.hitGridGreatBehindWidth)
	end

	self.waitGridToCheckHit = self.generateGridTime * 0.6
end

function M:CheckMusicInfoList()
	local musicInfo = {}
	local recordNoteList = nil

	if self.hasEditNote then
		recordNoteList = gMusicGameEditManager.AllMusicNoteList[self.liveHouseMusicId]
	else
		recordNoteList = gMusicGameEditManager.DefaultMusicNoteList[self.liveHouseMusicId]
	end

	local musicNoteList = {}

	if not table.isNilOrEmpty(recordNoteList) then
		musicNoteList = recordNoteList
	elseif table.isNilOrEmpty(musicNoteList) then
		if self.difficulty == 1 then
			musicNoteList = NoteInfo_Demo_Bgm1
		elseif self.difficulty == 2 then
			musicNoteList = NoteInfo_Demo_Bgm2
		else
			musicNoteList = NoteInfo_Demo_Bgm3
		end
	end

	if self.hasEditNote then
		musicNoteList = gMusicGameEditManager.RecordNoteList
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

	for i, v in pairs(musicNoteList) do
		local info = v

		if table.isNilOrEmpty(musicInfo[info.gridId]) then
			musicInfo[info.gridId] = {}
		end

		count = count + 1

		table.insert(musicInfo[info.gridId], musicNoteList[i])
	end

	if gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] == nil then
		gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] = {}
	end

	gMusicGameManager.RecordMusicInfo[self.liveHouseMusicId] = {
		SpecialCount = 0,
		MissCount = 0,
		PerfectCount = 0,
		GreatCount = 0,
		allCount = count
	}

	for i, gridNoteList in pairs(musicInfo) do
		if #gridNoteList > 1 then
			local count = 0

			for p, info in pairs(gridNoteList) do
				if info.pointType == gMusicGameManager.PointType.Single then
					count = count + 1
				end
			end

			if count >= 2 then
				local isDouble = false

				for t, info in pairs(gridNoteList) do
					if info.pointType == gMusicGameManager.PointType.Single then
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

function M:GameEndNotFinish()
	self:StopMusic()

	if self.liveHouseMusicCfg and gTimelineManager:Timeline_IsPlaying() then
		gTimelineManager:Timeline_Stop(self.liveHouseMusicCfg.TimeineName)
	end

	gClientToGameDelegate:LiveHouseMusicInterrupt(self.liveHouseMusicId, gMusicGameManager.InviteNpcId)
	gPanelManager:Close(gPanelId.LIVEHOUSE_GAME_PANEL)
end

function M:GameEnd()
	if self.isInPanel == false then
		return
	end

	self.isPlay = false

	if gMusicGameManager:IsFinishMusic(self.playLiveHouseId) then
		if self.hasEditNote then
			self:StopMusic()
		else
			gMusicGameManager:SetLiveHouseMusicResult(self.playLiveHouseId, function ()
				gPanelManager:CheckShow(gPanelId.LIVEHOUSE_GAME_END_PANEL, {
					id = self.playLiveHouseId,
					liveHouseId = self.liveHouseId,
					difficulty = self.difficulty,
					musicUuid = self.musicUuid
				})
			end)
		end
	else
		self:StopMusic()

		if self.liveHouseMusicCfg and gTimelineManager:Timeline_IsPlaying() then
			gTimelineManager:Timeline_Stop(self.liveHouseMusicCfg.TimeineName)
		end
	end

	gPanelManager:Close(gPanelId.LIVEHOUSE_GAME_PANEL)
end

function M:PlayMusic(liveHouseMusicId)
	if self.isPause then
		self:ReplayMusic()

		self.isPause = false
		self.bindData.isPause = SELECT_TYPE.FALSE

		return
	end

	gSoundMgr:PlaySoundByTid(self.liveHouseMusicCfg.BgmId, nil, nil, function (data)
		self.musicUuid = data
		self.playLiveHouseId = liveHouseMusicId
		self.recordMusicCount = gMusicGameManager:SetRecordMusicInfo(liveHouseMusicId)
		gMusicGameManager.musicState = false

		if not self.mUpdateHandler then
			self.mUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

			FixedUpdateBeat:AddListener(self.mUpdateHandler)
		end
	end, nil, nil, nil, function (uuid, name)
		local gridId = name

		if type(gridId) ~= "number" then
			gridId = tonumber(name)
		end

		self.gridId = gridId
	end)
end

function M:PlayNoteSound(soundType)
	if soundType == gMusicGameManager.SoundType.Perfect then
		self:PlayControllerVibration("ExHandle_QTECommon2")
	elseif soundType == gMusicGameManager.SoundType.Great then
		self:PlayControllerVibration("ExHandle_QTECommon1")
	end

	local noteSound = LivehouseConfig.NoteSound[soundType]

	if noteSound then
		gSoundMgr:PlaySoundByTid(noteSound.soundID)
	else
		print_error("noteSound is nil  soundType = " .. soundType)
	end
end

function M:PauseMusic()
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

		if self.liveHouseMusicCfg then
			gTimelineManager:Timeline_Pause(self.liveHouseMusicCfg.TimeineName, true)
		end
	else
		print_error("music的 uuid为空  livehouseId = " .. self.liveHouseMusicId)
	end
end

function M:StopMusic()
	if self.musicUuid then
		print_notice("StopMusic   musicUuid" .. self.musicUuid)
		gSoundMgr:StopSound(self.musicUuid)

		self.isPlay = false

		if self.mUpdateHandler then
			FixedUpdateBeat:RemoveListener(self.mUpdateHandler)

			self.mUpdateHandler = nil
		end
	end
end

function M:ReplayMusic()
	if self.musicUuid then
		gSoundMgr:Resume(self.musicUuid)

		self.isPlay = true
		self.bindData.isShowCountDown = SELECT_TYPE.FALSE

		if self.liveHouseMusicCfg then
			gTimelineManager:Timeline_Pause(self.liveHouseMusicCfg.TimeineName, false)
		end

		gSoundMgr:OnLeaveStateArea("UIPause")
	end
end

function M:FixedUpdate()
	if self.isPlay and not table.isNilOrEmpty(self.musicInfo) then
		local gridIndex = self.gridId + self.generateGridTime
		local curData = self.musicInfo[gridIndex]

		if curData then
			for index, pointInfo in pairs(curData) do
				if pointInfo and not self:IsNotePlaying(pointInfo.track, gridIndex) then
					if self.playingNote[pointInfo.track] == nil then
						self.playingNote[pointInfo.track] = {}
					end

					if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
						local view = {
							track = pointInfo.track,
							gridIndex = gridIndex,
							addMinGridIndex = self.gridId + pointInfo.length
						}
						self.waitLongPressMinNoteMove[self.gridId .. pointInfo.track] = view
						pointInfo.templateLineUp = self:AddLineByTemplate(pointInfo.track)
						pointInfo.template2 = self:AddNoteInTrack(pointInfo)
						pointInfo.template2Move = false
					end

					pointInfo.template = self:AddNoteInTrack(pointInfo)
					self.playingNote[pointInfo.track][gridIndex] = pointInfo
				end
			end
		end

		for i, waitInfo in pairs(self.waitLongPressMinNoteMove) do
			if waitInfo and waitInfo.addMinGridIndex == self.gridId then
				if self.playingNote[waitInfo.track] and self.playingNote[waitInfo.track][waitInfo.gridIndex] then
					self.playingNote[waitInfo.track][waitInfo.gridIndex].template2Move = true
				end

				self.waitLongPressMinNoteMove[i] = nil
			end
		end

		for track, pointList in pairs(self.playingNote) do
			if not table.isNilOrEmpty(pointList) then
				local minGridId = 0

				for gridId, v in pairs(pointList) do
					if minGridId == 0 then
						minGridId = gridId
					end

					minGridId = minGridId < gridId and minGridId or gridId
				end

				for gridId, pointInfo in pairs(pointList) do
					if pointInfo.leftMoveGrid == nil then
						pointInfo.leftMoveGrid = self.generateGridTime
					end

					local t = 1 - pointInfo.leftMoveGrid / self.generateGridTime

					if pointInfo.leftMoveGrid - Time.fixedDeltaTime * gMusicGameManager.gridCountPerSecond > 0 then
						pointInfo.leftMoveGrid = pointInfo.leftMoveGrid - Time.fixedDeltaTime * gMusicGameManager.gridCountPerSecond
					else
						pointInfo.leftMoveGrid = 0
					end

					local nowTemplatePos = Vector3.Lerp(self.trackPoint[track].startPos, self.trackPoint[track].endPos, t)
					pointInfo.template.transform.localPosition = nowTemplatePos
					local tempScale = Mathf.Clamp(self.PointAttr.minScale + (self.PointAttr.maxScale - self.PointAttr.minScale) * t, self.PointAttr.minScale, self.PointAttr.maxScale)

					pointInfo.template:SetLocalScale(tempScale)

					if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
						local radScale = self.PointAttr.minScale

						if pointInfo.leftMoveGrid2 == nil then
							pointInfo.leftMoveGrid2 = self.generateGridTime + pointInfo.length
						end

						if pointInfo.leftMoveGrid2 + pointInfo.length - Time.fixedDeltaTime * gMusicGameManager.gridCountPerSecond > 0 then
							pointInfo.leftMoveGrid2 = pointInfo.leftMoveGrid2 - Time.fixedDeltaTime * gMusicGameManager.gridCountPerSecond
						else
							pointInfo.leftMoveGrid2 = 0
						end

						local t2 = 1 - pointInfo.leftMoveGrid2 / self.generateGridTime

						if pointInfo.template2 and pointInfo.template2Move then
							local nowTemplate2Pos = Vector3.Lerp(self.trackPoint[track].startPos, self.trackPoint[track].endPos, t2)
							pointInfo.template2.transform.localPosition = nowTemplate2Pos
							local tempScale2 = Mathf.Clamp(self.PointAttr.minScale + (self.PointAttr.maxScale - self.PointAttr.minScale) * t2, self.PointAttr.minScale, self.PointAttr.maxScale)

							pointInfo.template2:SetLocalScale(tempScale2)

							radScale = tempScale2
						end

						if pointInfo.templateLineUp then
							local distance = gUtils:GetDistance(pointInfo.template.transform.localPosition, pointInfo.template2.transform.localPosition)
							local upPos = Vector3.Lerp(self.trackPoint[track].startPos, self.trackPoint[track].endPos, t2)

							pointInfo.templateLineUp:SetLocalPosition(upPos)

							pointInfo.templateLineUp:GetComponent(typeof(SGUI.UImage)).fillAmount = distance / self.trackPoint[track].distance
						end

						if (gMusicGameManager.GMFullPerfect or self:IsNpcHelpPerferct(track)) and pointInfo.leftMoveGrid == 0 and not pointInfo.hasPressNote1 then
							pointInfo.hasPressNote1 = true
							self.pressNote[track] = self.gridId
						end
					end

					local isHasRemoveNote = false

					if minGridId == gridId then
						if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
							self:CheckNoteHit(track, gridId, pointInfo)

							isHasRemoveNote = self:CheckNoteUp(track, gridId, pointInfo)
						else
							isHasRemoveNote = self:CheckNoteHit(track, gridId, pointInfo)
						end
					end

					if self.gridId > gridId + pointInfo.length and not isHasRemoveNote then
						if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
							self:RemoveNoteInTrack(pointInfo.template2, pointInfo.pointType, gridId, track)
							self:ReleaseLineTemplate(pointInfo.templateLineUp, track)
						end

						self:RemoveNoteInTrack(pointInfo.template, pointInfo.pointType, gridId, track)

						if gMusicGameManager.GMFullPerfect or self:IsNpcHelpPerferct(track) then
							self:CheckCombNumPlayAnim()

							self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

							self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
							self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
						else
							self.combNum = 0

							if self.bindData.isShowComb == SELECT_TYPE.TRUE then
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

							self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
							self:PlayNoteSound(gMusicGameManager.SoundType.Miss)
						end

						self.pressNote[track] = nil
					end
				end
			end
		end

		for track, pointInfo in pairs(self.playingLongPress) do
			if self.pressUp[track] then
				self:PlayEffect(gMusicGameManager.EffectType.LongPress, track)
			end

			if self.gridId > pointInfo.gridId + pointInfo.length then
				self.playingLongPress[track] = nil
			end
		end

		for k, v in pairs(self.noteOverList) do
			self.playingNote[v.track][v.gridId] = nil
		end

		if not table.isNilOrEmpty(self.noteOverList) then
			table.clear(self.noteOverList)
		end

		for track, gridId in pairs(self.pressUp) do
			if gridId < self.gridId then
				self.pressUp[track] = nil
				self.pressNote[track] = nil
			end
		end

		for track, effectInfo in pairs(self.playingEffect) do
			if not table.isNilOrEmpty(effectInfo) and self.gridId >= effectInfo.gridId + gMusicGameManager.gridCountPerSecond / 2 then
				self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

				self.playingEffect[track] = {}
			end
		end

		for track, effectInfo in pairs(self.playingQteEffect) do
			if not table.isNilOrEmpty(effectInfo) and self.gridId >= effectInfo.gridId + gMusicGameManager.gridCountPerSecond / 2 then
				self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

				self.playingQteEffect[track] = {}
			end
		end

		for track, effectInfo in pairs(self.playingLongPressEffect) do
			if not table.isNilOrEmpty(effectInfo) then
				local isInPress = false

				for i, v in pairs(self.playingLongPress) do
					if v == effectInfo.gridId then
						isInPress = true
					end
				end

				if isInPress then
					self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

					self.playingLongPressEffect[track] = {}
				elseif self.gridId >= effectInfo.gridId + gMusicGameManager.gridCountPerSecond / 2 then
					self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

					self.playingLongPressEffect[track] = {}
				end
			end
		end
	end
end

function M:CheckNoteHit(track, gridId, pointInfo)
	if gridId > self.gridId + self.waitGridToCheckHit or table.isNilOrEmpty(self.pressNote) then
		return false
	end

	local gridTime = self.pressNote[track]

	if gridTime == nil then
		return false
	end

	if gridTime <= gridId + self.hitGridGreatBehindWidth and gridTime >= gridId - self.hitGridGreatBeforeWidth then
		if not self.playingLongPress[track] then
			self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_open")
			self:CheckCombNumPlayAnim()
		end

		if gridTime <= gridId + self.hitGridPerfectBehindWidth and gridTime >= gridId - self.hitGridPerfectBeforeWidth then
			if not self.playingLongPress[track] then
				self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

				self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
				self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
			end
		elseif not self.playingLongPress[track] then
			self.recordMusicCount.GreatCount = self.recordMusicCount.GreatCount + 1

			self:PlayEffect(gMusicGameManager.EffectType.Great, track)
			self:PlayNoteSound(gMusicGameManager.SoundType.Great)
		end

		if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
			self.playingLongPress[track] = pointInfo

			self:PlayEffect(gMusicGameManager.EffectType.LongPress, track)
		end
	elseif gMusicGameManager.GMFullPerfect or self:IsNpcHelpPerferct(track) then
		self:CheckCombNumPlayAnim()

		self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

		self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
		self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
	else
		self.combNum = 0

		if self.bindData.isShowComb == SELECT_TYPE.TRUE then
			self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_close")

			if self.combTimer then
				self.combTimer:Stop()
			end

			self.combTimer = Timer.New(function ()
				self.combTimer = nil
				self.bindData.isShowComb = SELECT_TYPE.FALSE
			end, 0.2):Start()
		end

		self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
		self:PlayNoteSound(gMusicGameManager.SoundType.Miss)

		self.recordMusicCount.MissCount = self.recordMusicCount.MissCount + 1
	end

	if pointInfo.pointType ~= gMusicGameManager.PointType.LongPress then
		self:RemoveNoteInTrack(pointInfo.template, pointInfo.pointType, gridId, track)
	else
		if self.longPressNote[track] == nil then
			self.longPressNote[track] = {}
		end

		self.longPressNote[track].pressGridId = self.pressNote[track]
		self.longPressNote[track].gridId = gridId
	end

	self.pressNote[track] = nil

	return true
end

function M:CheckNoteUp(track, gridId, pointInfo)
	if self.longPressNote[track] == nil or self.longPressNote[track] and self.longPressNote[track].gridId ~= gridId or self.playingLongPress[track] == nil then
		return false
	end

	if gridId <= self.gridId + self.waitGridToCheckHit and pointInfo.pointType == gMusicGameManager.PointType.LongPress and not table.isNilOrEmpty(self.pressUp) then
		for pressTrack, gridTime in pairs(self.pressUp) do
			if track == pressTrack then
				if gridTime <= gridId + pointInfo.length + self.hitGridGreatBehindWidth and gridTime >= gridId + pointInfo.length - self.hitGridGreatBeforeWidth then
					self:CheckCombNumPlayAnim()
					self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_open")

					if gridTime <= gridId + pointInfo.length + self.hitGridPerfectBeforeWidth and gridTime >= gridId + pointInfo.length - self.hitGridPerfectBeforeWidth then
						self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

						self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
						self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
					else
						self.recordMusicCount.GreatCount = self.recordMusicCount.GreatCount + 1

						self:PlayEffect(gMusicGameManager.EffectType.Great, track)
						self:PlayNoteSound(gMusicGameManager.SoundType.Great)
					end
				elseif gMusicGameManager.GMFullPerfect or self:IsNpcHelpPerferct(track) then
					self:CheckCombNumPlayAnim()

					self.recordMusicCount.PerfectCount = self.recordMusicCount.PerfectCount + 1

					self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
					self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
				else
					self.combNum = 0

					if self.bindData.isShowComb == SELECT_TYPE.TRUE then
						self.bindData.ComboAnim:Play("S_Vx_Livehouse_Combo_close")

						if self.combTimer then
							self.combTimer:Stop()
						end

						self.combTimer = Timer.New(function ()
							self.combTimer = nil
							self.bindData.isShowComb = SELECT_TYPE.FALSE
						end, 1):Start()
					end

					self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
					self:PlayNoteSound(gMusicGameManager.SoundType.Miss)

					self.recordMusicCount.MissCount = self.recordMusicCount.MissCount + 1
				end

				self.pressUp[track] = nil
				self.longPressNote[track] = nil
				self.playingLongPress[track] = nil

				self:RemoveNoteInTrack(pointInfo.template, pointInfo.pointType, gridId, track)
				self:RemoveNoteInTrack(pointInfo.template2, pointInfo.pointType, gridId, track)
				self:ReleaseLineTemplate(pointInfo.templateLineUp, track)

				return true
			end
		end
	end

	return false
end

function M:AddNoteInTrack(pointInfo)
	local template = self:GetNewTemplateByType(pointInfo.pointType)

	template:SetParent(self.trackTrans[pointInfo.track])
	template:SetLocalPosition(self.trackPoint[pointInfo.track].startPos.x, self.trackPoint[pointInfo.track].startPos.y, self.trackPoint[pointInfo.track].startPos.z)
	template:SetLocalScale(self.PointAttr.minScale)
	template:SetActive(true)

	return template
end

function M:GetNewTemplateByType(pointType)
	local template = nil

	if self.cacheListDict[pointType] ~= nil and #self.cacheListDict[pointType] > 0 then
		template = self.cacheListDict[pointType][1]

		table.remove(self.cacheListDict[pointType], 1)
	else
		template = GameObject.Instantiate(self.buttonGo[pointType])

		template:GetComponent(typeof(SGUI.UWidget)):TryInit()
	end

	return template
end

function M:RemoveNoteInTrack(obj, pointType, gridId, track)
	obj.transform:SetParent(self.bindData.pointPool)
	obj:SetActive(false)

	if self.cacheListDict[pointType] == nil then
		self.cacheListDict[pointType] = {}
	end

	table.insert(self.cacheListDict[pointType], obj)

	local note = {
		gridId = gridId,
		track = track
	}

	table.insert(self.noteOverList, note)
end

function M:AddLineByTemplate(track)
	local templateLineUp = self:GetNewLineTemplateByTrack(track)

	templateLineUp:SetParent(self.trackTrans[track])
	templateLineUp:SetLocalScale(1)
	templateLineUp:SetActive(true)

	return templateLineUp
end

function M:GetNewLineTemplateByTrack(track)
	if self.cacheLineListDict[track] == nil then
		self.cacheLineListDict[track] = {}
	end

	local templateLineUp = nil

	if self.cacheLineListDict[track][LineType.Up] ~= nil and #self.cacheLineListDict[track][LineType.Up] > 0 then
		templateLineUp = self.cacheLineListDict[track][LineType.Up][1]

		table.remove(self.cacheLineListDict[track][LineType.Up], 1)
	else
		templateLineUp = GameObject.Instantiate(self.trackPoint[track].longPressTemplate)

		templateLineUp:GetComponent(typeof(SGUI.UWidget)):TryInit()
	end

	return templateLineUp
end

function M:ReleaseLineTemplate(templateLineUp, track)
	templateLineUp.transform:SetParent(self.bindData.LinePool)
	templateLineUp:SetActive(false)

	if self.cacheLineListDict[track] == nil then
		self.cacheLineListDict[track] = {}
	end

	if self.cacheLineListDict[track][LineType.Up] == nil then
		self.cacheLineListDict[track][LineType.Up] = {}
	end

	table.insert(self.cacheLineListDict[track][LineType.Up], templateLineUp)
end

function M:PlayEffect(effectType, track)
	if self.lastGridId == nil then
		self.lastGridId = 0
	end

	if self.bindData.isShowGmTool == SELECT_TYPE.TRUE then
		self.bindData.GMNoteCount = "Perfect :" .. self.recordMusicCount.PerfectCount .. "   Great:" .. self.recordMusicCount.GreatCount .. "  Miss:" .. self.recordMusicCount.MissCount
	end

	self.lastGridId = self.gridId
	local template = self:GetEffectTemplateByType(effectType)

	template:SetParent(self.trackTrans[track])
	template:SetLocalPosition(self.trackPoint[track].endPos.x, self.trackPoint[track].endPos.y, self.trackPoint[track].endPos.z)
	template:SetLocalScale(self.PointAttr.maxScale)
	template:SetActive(true)

	if effectType == gMusicGameManager.EffectType.LongPress then
		if not table.isNilOrEmpty(self.playingLongPressEffect[track]) then
			self:ReleaseEffectTemplate(self.playingLongPressEffect[track].obj, effectType)

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
			self:ReleaseEffectTemplate(self.playingEffect[track].obj, self.playingEffect[track].type)

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

function M:PlayEffectToPos(effectType, pos)
	local template = self:GetEffectTemplateByType(effectType)

	template:SetLocalPosition(pos)
	template:SetLocalScale(self.PointAttr.maxScale)
	template:SetActive(true)
	template:SetParent(self.bindData.ClickEffectList)
	Timer.New(function ()
		self:ReleaseEffectTemplate(template, effectType)
	end, 1):Start()
end

function M:PlayQteEffect(effectType, QteTrack)
	local template = self:GetEffectTemplateByType(effectType)
	local trackTrans = self.bindData["slot" .. QteTrack .. "BtnClick"].transform

	template:SetParent(self.bindData.QTEslot)
	template:SetLocalPosition(trackTrans.localPosition.x, trackTrans.localPosition.y, trackTrans.localPosition.z)
	template:SetLocalScale(self.PointAttr.maxScale)
	template:SetActive(true)

	if not table.isNilOrEmpty(self.playingQteEffect[QteTrack]) then
		self:ReleaseEffectTemplate(self.playingQteEffect[QteTrack].obj, self.playingQteEffect[QteTrack].type)

		self.playingQteEffect[QteTrack] = {}
	end

	if table.isNilOrEmpty(self.playingQteEffect[QteTrack]) then
		self.playingQteEffect[QteTrack] = {}
	end

	self.playingQteEffect[QteTrack].obj = template
	self.playingQteEffect[QteTrack].type = effectType
	self.playingQteEffect[QteTrack].gridId = self.gridId
end

function M:GetEffectTemplateByType(effectType)
	local template = nil

	if self.cacheEffectDict[effectType] ~= nil and #self.cacheEffectDict[effectType] > 0 then
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

function M:ReleaseEffectTemplate(obj, effectType)
	if gCS.LuaUtils.IsNull(obj) then
		return
	end

	if obj == nil or obj.transform == nil then
		LX6.Utils.LogUtilsLua.SendToPopo("音游ReleaseEffectTemplate 失败， obj 为null effectType= " .. effectType, "leilei03")
		print_error("音游ReleaseEffectTemplate 失败， obj 为null effectType= " .. effectType)

		return
	end

	obj.transform:SetParent(self.bindData.EffectPool)
	obj:SetActive(false)

	if self.cacheEffectDict[effectType] == nil then
		self.cacheEffectDict[effectType] = {}
	end

	table.insert(self.cacheEffectDict[effectType], obj)
end

function M:IsNotePlaying(track, gridId)
	if not self.playingNote[track] then
		return false
	end

	return self.playingNote[track][gridId] ~= nil
end

function M:IsNpcHelpPerferct(track)
	if self.bindData.hasNpcPlay == SELECT_TYPE.TRUE and table.contains(self.TopKeyTrack, track) then
		return true
	end

	return false
end

function M:CheckCombNumPlayAnim()
	self.combNum = self.combNum + 1
	self.bindData.combNum1 = self.combNum
	self.bindData.combNum2 = self.combNum
	self.bindData.combNum3 = self.combNum

	if self.combTimer then
		self.combTimer:Stop()
	end

	if self.bindData.isShowComb == SELECT_TYPE.FALSE then
		self.bindData.isShowComb = SELECT_TYPE.TRUE
	end

	if self.combNum < 50 then
		self.bindData.ShowCombType = 1
	elseif self.combNum >= 50 and self.combNum < 100 then
		self.bindData.ShowCombType = 2
	else
		self.bindData.ShowCombType = 3
	end

	for i = 1, #self.ComboEffectSounds do
		if self.combNum == self.ComboEffectSounds[i].combo then
			gSoundMgr:PlaySoundByTid(self.ComboEffectSounds[i].soundID)
		end
	end
end

function M:CheckPlayDialog(str)
	if self.liveHouseMusicId and self.liveHouseMusicCfg then
		local scoreInfo = self.liveHouseMusicCfg.JumpTimelineClip
		local info = {}

		for i = 1, #scoreInfo do
			if scoreInfo[i].EventSenderClipName == str then
				table.insert(info, scoreInfo[i])
			end
		end

		local curScore = gMusicGameManager:GetScoreById(self.liveHouseMusicId)

		if info[1] and info[2] then
			local clipName = info[1].ClipName

			if info[2].score < curScore then
				clipName = info[2].ClipName
			end

			gTimelineManager:Timeline_JumpTo(self.liveHouseMusicCfg.TimeineName, clipName)
		else
			print_error("@yuanzhuochun@corp.netease.com livehouse scoreInfo error，EventSenderClipName与LIVEHOUSE_PLAY_DIALOG发来的string对不上 ，请策划查看配置  livehouseMusicId = " .. self.liveHouseMusicId .. "  str = " .. str)
		end
	end
end

function M:SimpleClick()
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

function M:OnBackBtnClick()
	self:GameEndNotFinish()
end

function M:OnPauseBtnClick()
	self:PauseMusic()
end

function M:OnPlayBtnClick()
	addTime = 3
	self.readyToPlay = true
	self.bindData.isShowCountDown = SELECT_TYPE.TRUE
	self.bindData.isPause = SELECT_TYPE.FALSE
end

function M:OnSlotBtnClick(index)
	if self.bindData["isShowQteSlot" .. index] == SELECT_TYPE.TRUE then
		self.bindData["isShowQteSlot" .. index] = SELECT_TYPE.FALSE
		self.recordMusicCount.SpecialCount = self.recordMusicCount.SpecialCount + 1

		self:PlayQteEffect(gMusicGameManager.EffectType.QteClick, index)
		self:PlayControllerVibration("ExHandle_QTECommon2")
	end
end

function M:OnPressBtnClick(track)
	if self.isPlay then
		print("PressDown " .. track .. " GridId = " .. self.gridId)

		self.pressNote[track] = self.gridId
	end
end

function M:OnReleaseBtnClick(track)
	if self.isPlay then
		print("PressUp " .. track .. " GridId = " .. self.gridId)

		if self.pressNote[track] then
			self.pressNote[track] = nil
		end

		self.pressUp[track] = self.gridId
	end
end

function M:OnSettleBtnClick()
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

		self:GameEnd()
	end
end

function M:OnGoldFingerBtnClick()
	if not gCS.LuaUtils.IsPublish then
		if self.bindData.useGoldFinger == SELECT_TYPE.TRUE then
			self.bindData.useGoldFinger = SELECT_TYPE.FALSE
			gMusicGameManager.GMFullPerfect = false
		else
			self.bindData.useGoldFinger = SELECT_TYPE.TRUE
			gMusicGameManager.GMFullPerfect = true
		end
	end
end

function M:GMToSuccess()
	if not gCS.LuaUtils.IsPublish then
		self.isGMJumpToSuccess = not self.isGMJumpToSuccess
	end
end

function M:PlayStart()
	if self.isInPanel == false then
		return
	end

	addTime = 0
	self.readyToPlay = true

	gPanelManager:Preload(gPanelId.LIVEHOUSE_GAME_END_PANEL)
end

function M:ShowPart(_, part)
	if self.isInPanel == false then
		return
	end

	self.bindData["isShowPart" .. part[0]] = SELECT_TYPE.TRUE
end

function M:PlayShow()
	if self.isInPanel == false then
		return
	end

	addTime = 3
	self.readyToPlay = true
	self.bindData.isShowCountDown = SELECT_TYPE.TRUE
	self.bindData.isShowPanel = SELECT_TYPE.TRUE
end

function M:PlayHide()
	if self.isInPanel == false then
		return
	end

	self.bindData.isShowPanel = SELECT_TYPE.FALSE
end

function M:PlayDialog(_, data)
	if self.isInPanel == false then
		return
	end

	self:CheckPlayDialog(data[0])
end

function M:ShowQteSlot(_, data)
	if self.isInPanel == false then
		return
	end

	self.bindData["isShowQteSlot" .. data[0]] = SELECT_TYPE.TRUE
end

function M:HideQteSlot(_, data)
	if self.isInPanel == false then
		return
	end

	if self.bindData["isShowQteSlot" .. data[0]] == SELECT_TYPE.TRUE then
		self.bindData["isShowQteSlot" .. data[0]] = SELECT_TYPE.FALSE

		self:PlayQteEffect(gMusicGameManager.EffectType.QteMiss, data[0])
	end
end

function M:ShowGMTool()
	if self.isInPanel == false then
		return
	end

	if not gCS.LuaUtils.IsPublish then
		self.bindData.isShowGmTool = SELECT_TYPE.TRUE
	end
end

function M:PlayControllerVibration(soundName)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		gSoundMgr:PlaySoundByExternalSource(soundName, LX6.Audio.ExternalSourceType.Motion_2D)
	end
end
