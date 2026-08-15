C_ToiletOstrichGamePanelStore = DefClass("C_ToiletOstrichGamePanelStore", C_ToiletOstrichGamePanelStore, C_StoreGroup)
GroupName2Class.ToiletOstrichGamePanelStore = C_ToiletOstrichGamePanelStore
local M = C_ToiletOstrichGamePanelStore
local LivehouseConfig = LTConfig.LivehouseConfig
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

	self.bindData.button1.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 1)
	self.bindData.button1.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 1)
	self.bindData.button2.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 2)
	self.bindData.button2.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 2)
	self.bindData.button3.luaPress = self:CreateActionWithArgs("OnPressBtnClick", 3)
	self.bindData.button3.luaRelease = self:CreateActionWithArgs("OnReleaseBtnClick", 3)
end

function M:OnShow(panelId, data)
	self.npcPid = data.npcPid
	self.currentScore = 0
	self.unit = gCS.SceneDataMgr.GetUnit(data.npcPid)

	self:InitPanelInfo()
	self:InitMusicInfo()
	self:UnActiveNoteTemplate()
end

function M:InitPanelInfo()
	self.buttonGo[gMusicGameManager.PointType.Single] = self.bindData.BtnNormal.gameObject
	self.buttonGo[gMusicGameManager.PointType.LongPress] = self.bindData.BtnPress.gameObject
	self.buttonGo[gMusicGameManager.PointType.Double] = self.bindData.BtnDouble.gameObject
	self.effectGo[gMusicGameManager.EffectType.Miss] = self.bindData.Miss.gameObject
	self.effectGo[gMusicGameManager.EffectType.Great] = self.bindData.Great.gameObject
	self.effectGo[gMusicGameManager.EffectType.Perfect] = self.bindData.Perfect.gameObject
	self.effectGo[gMusicGameManager.EffectType.LongPress] = self.bindData.LongPress.gameObject
	self.trackTrans = {}

	for i = 1, 3 do
		self.trackTrans[i] = self.bindData["Track" .. i]
	end

	self.trackPoint = {}

	for i = 1, 3 do
		self.trackPoint[i] = {
			startPos = self.bindData["trackStart" .. i].localPosition,
			endPos = self.bindData["trackEnd" .. i].localPosition,
			longPressTemplate = self.bindData["LongPressLine" .. i].gameObject,
			longPressInitLocalRot = self.bindData["LongPressLine" .. i].gameObject.transform.localRotation
		}
		self.trackPoint[i].distance = gUtils:GetDistance(self.trackPoint[i].startPos, self.trackPoint[i].endPos)
	end
end

function M:InitMusicInfo()
	self:SetMusicInfo()
	self:SetGenerateTime()

	self.musicInfo = {}
end

function M:SetMusicInfo()
	self.Bpm = 125
	self.bgmTotalBar = 166
	self.bpmPerBar = 4
	self.perBarTime = self.bpmPerBar * 60 / self.Bpm
	self.gridCountPerBar = 24
	self.gridCountPerSecond = self.gridCountPerBar / self.perBarTime
	self.gridCountPerBpm = self.gridCountPerBar / 4
	self.noteSpeed = 900
	self.generateGridTime = 48
end

function M:SetGenerateTime()
	local length = gUtils:GetDistance(self.trackPoint[1].startPos, self.trackPoint[1].endPos)
	local generateGridTime = math.floor(self.bpmPerBar * self.gridCountPerBpm * length / self.noteSpeed) + 1

	if self.generateGridTime < generateGridTime then
		print_error("移动时间超过生成时间")
	end

	self.generateGridTime = generateGridTime < self.generateGridTime and generateGridTime or self.generateGridTime
	local NoteSensitivity = nil

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		NoteSensitivity = LivehouseConfig.NoteSensitivity
	else
		NoteSensitivity = LivehouseConfig.MobileNoteSensitivity
	end

	if NoteSensitivity then
		self.hitGridPerfectBeforeWidth = NoteSensitivity.hitGridPerfectBeforeWidth
		self.hitGridPerfectBehindWidth = NoteSensitivity.hitGridPerfectBehindWidth
		self.hitGridGreatBeforeWidth = NoteSensitivity.hitGridGreatBeforeWidth
		self.hitGridGreatBehindWidth = NoteSensitivity.hitGridGreatBehindWidth
	end

	self.waitGridToCheckHit = self.generateGridTime * 0.6
end

function M:UnActiveNoteTemplate()
	self.bindData.BtnNormal.gameObject:SetActive(false)
	self.bindData.BtnPress.gameObject:SetActive(false)
	self.bindData.BtnDouble.gameObject:SetActive(false)
	self.bindData.Miss.gameObject:SetActive(false)
	self.bindData.Great.gameObject:SetActive(false)
	self.bindData.Perfect.gameObject:SetActive(false)
	self.bindData.LongPress.gameObject:SetActive(false)

	for i = 1, 3 do
		self.trackPoint[i].longPressTemplate:SetActive(false)
	end
end

function M:OnClose()
	self.npcPid = nil

	if self.mUpdateHandler then
		FixedUpdateBeat:RemoveListener(self.mUpdateHandler)
	end
end

local addTime = 0.5
local generateNoteTime = 2
local totalMusicTime = 0

function M:OnUpdate()
	if self.isPlay == false then
		addTime = addTime - Time.deltaTime

		if addTime <= 0 then
			self.isPlay = true

			self:PlayBeat()
			self:CreateNewGrid()

			addTime = 0.5
		end
	else
		generateNoteTime = generateNoteTime - Time.deltaTime
		totalMusicTime = totalMusicTime + Time.deltaTime
		self.gridId = math.floor(totalMusicTime * self.gridCountPerSecond)

		if generateNoteTime <= 0 then
			if self.musicInfo then
				self:CreateNewGrid()
			end

			generateNoteTime = 2
		end

		if self.unit then
			local screenPos = gCS.CameraDataMgr.MainCamera:WorldToScreenPoint(self.unit.UpBodyPosition)
			self.bindData.barRoot.localPosition = gUtils:ScreenToUIPosition(screenPos)
		end
	end
end

function M:CreateNewGrid()
	local randomTrack = math.random(1, 3)
	local length = 1
	local pointType = 1

	if randomTrack == 2 then
		length = math.random(4, 6)
		pointType = 2
	end

	local curMusicInfo = {
		length = length,
		pointType = pointType,
		gridId = self.gridId + self.generateGridTime,
		track = randomTrack
	}
	self.musicInfo[self.gridId + self.generateGridTime] = curMusicInfo
end

function M:InitDefaultInfo()
	self.PointType = {
		LongPress = 2,
		Single = 1
	}
	self.buttonGo = {}
	self.effectGo = {}
	self.trackTrans = {}
	self.playingNote = {}
	self.playingEffect = {}
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
	self.isPlay = false
	self.mUpdateHandler = nil
	self.fullPoints = 100
	self.normalPerfectPoint = 20
end

function M:OnPressBtnClick(track)
	if self.isPlay then
		self.pressNote[track] = self.gridId
		local key = 901 + track * 2

		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, key)
	end
end

function M:OnReleaseBtnClick(track)
	if self.isPlay then
		if self.pressNote[track] then
			self.pressNote[track] = nil
		end

		self.pressUp[track] = self.gridId
		local key = 902 + track * 2

		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, key)
	end
end

function M:PlayBeat()
	if not self.mUpdateHandler then
		self.mUpdateHandler = FixedUpdateBeat:CreateListener(self.FixedUpdate, self)

		FixedUpdateBeat:AddListener(self.mUpdateHandler)
	end
end

function M:FixedUpdate()
	if not self.isPlay then
		return
	end

	local gridIndex = self.gridId + self.generateGridTime
	local pointInfo = self.musicInfo[gridIndex]

	if pointInfo and pointInfo and not self:IsNotePlaying(pointInfo.track, gridIndex) then
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

				if pointInfo.leftMoveGrid - Time.fixedDeltaTime * self.gridCountPerSecond > 0 then
					pointInfo.leftMoveGrid = pointInfo.leftMoveGrid - Time.fixedDeltaTime * self.gridCountPerSecond
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

					if pointInfo.leftMoveGrid2 + pointInfo.length - Time.fixedDeltaTime * self.gridCountPerSecond > 0 then
						pointInfo.leftMoveGrid2 = pointInfo.leftMoveGrid2 - Time.fixedDeltaTime * self.gridCountPerSecond
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
					self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
					self:PlayNoteSound(gMusicGameManager.SoundType.Miss)
					gMiniGameDataManager:DecreaseCurrentToiletGameScore(self.npcPid, self.normalPerfectPoint)

					self.bindData.fillAmount = gMiniGameDataManager:GetToiletNpcPoints(self.npcPid) / 100 or 0

					if self:CheckFail(gMiniGameDataManager:GetToiletNpcPoints(self.npcPid)) then
						self:GameEnd(false)
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
		if not table.isNilOrEmpty(effectInfo) and self.gridId >= effectInfo.gridId + self.gridCountPerSecond / 2 then
			self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

			self.playingEffect[track] = {}
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
			elseif self.gridId >= effectInfo.gridId + self.gridCountPerSecond / 2 then
				self:ReleaseEffectTemplate(effectInfo.obj, effectInfo.type)

				self.playingLongPressEffect[track] = {}
			end
		end
	end
end

function M:CheckNoteHit(track, gridId, pointInfo)
	if gridId <= self.gridId + self.waitGridToCheckHit and not table.isNilOrEmpty(self.pressNote) then
		for pressTrack, gridTime in pairs(self.pressNote) do
			if track == pressTrack then
				if gridTime <= gridId + self.hitGridGreatBehindWidth and gridTime >= gridId - self.hitGridGreatBeforeWidth then
					if not self.playingLongPress[track] then
						-- Nothing
					end

					if gridTime <= gridId + self.hitGridPerfectBehindWidth and gridTime >= gridId - self.hitGridPerfectBeforeWidth then
						if not self.playingLongPress[track] then
							self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
							self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
							gMiniGameDataManager:AddCurrentToiletGameScore(self.npcPid, self.normalPerfectPoint)

							self.bindData.fillAmount = gMiniGameDataManager:GetToiletNpcPoints(self.npcPid) / 100 or 0

							if self:CheckSuccess(gMiniGameDataManager:GetToiletNpcPoints(self.npcPid)) then
								self:GameEnd(true)
							end
						end
					elseif not self.playingLongPress[track] then
						self:PlayEffect(gMusicGameManager.EffectType.Great, track)
						self:PlayNoteSound(gMusicGameManager.SoundType.Great)
						gMiniGameDataManager:AddCurrentToiletGameScore(self.npcPid, self.normalPerfectPoint)

						self.bindData.fillAmount = gMiniGameDataManager:GetToiletNpcPoints(self.npcPid) / 100 or 0

						if self:CheckSuccess(gMiniGameDataManager:GetToiletNpcPoints(self.npcPid)) then
							self:GameEnd(true)
						end
					end

					if pointInfo.pointType == gMusicGameManager.PointType.LongPress then
						self.playingLongPress[track] = pointInfo

						self:PlayEffect(gMusicGameManager.EffectType.LongPress, track)
					end
				else
					self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
					self:PlayNoteSound(gMusicGameManager.SoundType.Miss)
					gMiniGameDataManager:DecreaseCurrentToiletGameScore(self.npcPid, self.normalPerfectPoint)

					self.bindData.fillAmount = gMiniGameDataManager:GetToiletNpcPoints(self.npcPid) / 100 or 0

					if self:CheckFail(gMiniGameDataManager:GetToiletNpcPoints(self.npcPid)) then
						self:GameEnd(false)
					end
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
		end
	end

	return false
end

function M:CheckNoteUp(track, gridId, pointInfo)
	if self.longPressNote[track] == nil or self.longPressNote[track] and self.longPressNote[track].gridId ~= gridId or self.playingLongPress[track] == nil then
		return false
	end

	if gridId <= self.gridId + self.waitGridToCheckHit and pointInfo.pointType == gMusicGameManager.PointType.LongPress and not table.isNilOrEmpty(self.pressUp) then
		for pressTrack, gridTime in pairs(self.pressUp) do
			if track == pressTrack then
				if gridTime <= gridId + pointInfo.length + self.hitGridGreatBehindWidth and gridTime >= gridId + pointInfo.length - self.hitGridGreatBeforeWidth then
					if gridTime <= gridId + pointInfo.length + self.hitGridPerfectBeforeWidth and gridTime >= gridId + pointInfo.length - self.hitGridPerfectBeforeWidth then
						self:PlayEffect(gMusicGameManager.EffectType.Perfect, track)
						self:PlayNoteSound(gMusicGameManager.SoundType.Perfect)
					else
						self:PlayEffect(gMusicGameManager.EffectType.Great, track)
						self:PlayNoteSound(gMusicGameManager.SoundType.Great)
					end
				else
					self:PlayEffect(gMusicGameManager.EffectType.Miss, track)
					self:PlayNoteSound(gMusicGameManager.SoundType.Miss)
					gMiniGameDataManager:DecreaseCurrentToiletGameScore(self.npcPid, self.normalPerfectPoint)

					self.bindData.fillAmount = gMiniGameDataManager:GetToiletNpcPoints(self.npcPid) / 100 or 0

					if self:CheckFail(gMiniGameDataManager:GetToiletNpcPoints(self.npcPid)) then
						self:GameEnd(false)
					end
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

function M:PlayNoteSound(soundType)
	if soundType == gMusicGameManager.SoundType.Perfect then
		gSoundMgr:PlaySoundByExternalSource("ExHandle_QTECommon1", LX6.Audio.ExternalSourceType.Motion_2D)
	end

	local noteSound = LivehouseConfig.NoteSound[soundType]

	if noteSound then
		gSoundMgr:PlaySoundByTid(noteSound.soundID)
	end
end

function M:GameEnd(isSuccess)
	self.isPlay = false

	gMiniGameDataManager:SetToiletNpcResult(self.npcPid, isSuccess)

	if isSuccess then
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, 901)
	else
		gCS.BaseUnitUtils.Dismount()
		gCS.LogicStateMachineManager.SendGameplayEvent(gCS.MyPlayerManager.PlayerUnit, 902)
	end

	gPanelManager:Close(gPanelId.TOILET_OSTRICH_GAME_PANEL)
end

function M:CheckSuccess(points)
	return points >= 100
end

function M:CheckFail(points)
	return points > -99999 and points <= 0
end

function M:AddNoteInTrack(pointInfo)
	local template = self:GetNewTemplateByType(pointInfo.pointType, pointInfo.track)

	template:SetParent(self.trackTrans[pointInfo.track])
	template:SetLocalPosition(self.trackPoint[pointInfo.track].startPos.x, self.trackPoint[pointInfo.track].startPos.y, self.trackPoint[pointInfo.track].startPos.z)
	template:SetLocalScale(self.PointAttr.minScale)
	template:SetActive(true)

	return template
end

function M:GetNewTemplateByType(pointType, track)
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

	templateLineUp.transform.localRotation = self.trackPoint[2].longPressInitLocalRot

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

function M:IsNotePlaying(track, gridId)
	if not self.playingNote[track] then
		return false
	end

	return self.playingNote[track][gridId] ~= nil
end

function M:PlayEffect(effectType, track)
	if self.lastGridId == nil then
		self.lastGridId = 0
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
		-- Nothing
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
	if obj == nil then
		return
	end

	obj.transform:SetParent(self.bindData.EffectPool)
	obj:SetActive(false)

	if self.cacheEffectDict[effectType] == nil then
		self.cacheEffectDict[effectType] = {}
	end

	table.insert(self.cacheEffectDict[effectType], obj)
end

function M:AddScore(points)
	self.currentScore = self.currentScore + points
end

function M:DecreaseScore(points)
	return
end
