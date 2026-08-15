C_InstrumentsGuitarPanelStore = DefClass("C_InstrumentsGuitarPanelStore", C_InstrumentsGuitarPanelStore, C_StoreGroup)
GroupName2Class.InstrumentsGuitarPanelStore = C_InstrumentsGuitarPanelStore
local M = C_InstrumentsGuitarPanelStore

function M:OnAwake()
	local config = {
		stringCount = 6,
		chordCount = 6
	}
	self.instance = {
		panelId = 0,
		isMutePressed = false,
		isPalmMuteActive = false,
		config = config,
		stringSoundTracks = {
			0,
			0,
			0,
			0,
			0,
			0
		},
		stringBtns = {}
	}
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.muteBtn.luaPress = self:CreateActionWithArgs(self.OnMuteBtnPress, true)
	self.bindData.muteBtn.luaRelease = self:CreateActionWithArgs(self.OnMuteBtnPress, false)
	self.bindData.palmMuteBtn.luaPress = self:CreateActionWithArgs(self.OnPalmMuteBtnPress, true)
	self.bindData.palmMuteBtn.luaRelease = self:CreateActionWithArgs(self.OnPalmMuteBtnPress, false)

	for i = 1, config.chordCount do
		local btn = self.bindData["chordBtn" .. i]
		btn.luaClick = self:CreateActionWithArgs(self.OnChordBtnClick, i)
	end

	for i = 1, config.stringCount do
		local btn = self.bindData["stringBtn" .. i]
		local handler = self:CreateActionWithArgs(self.OnStringBtnClick, i)
		btn.luaPress = handler
		self.instance.stringBtns[i] = btn
	end
end

function M:OnShow(panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data

	for i = 1, self.instance.config.chordCount do
		local btn = self.bindData["chordBtn" .. i]
		local store = self:GetStoreByWidget(btn)
		store.text = LTConfig.InstrumentGuitarConfig.GetConfig(i).MusicalNote
	end

	self.rootWidget:SetActive(false)

	local timer = Timer.New(function ()
		self.rootWidget:SetActive(true)
		print_error("#NoCreateIssue 吉他等 StateTree 信号 GuitarNotifyInteractionEnd 超时了！")
	end, 8.5)

	timer:Start()
	self:RegisterSingleEvent(gEventConstants.GUITAR_INTERACTION_END, function ()
		self.rootWidget:SetActive(true)
		timer:Stop()
	end)
end

function M:OnClose()
	gInteractionManager:SetCommonInteractEnd(15)

	for i = 1, self.instance.config.stringCount do
		if self.instance.stringSoundTracks[i] and self.instance.stringSoundTracks[i] ~= 0 then
			local soundData = gSoundMgr:GetSoundData(self.instance.stringSoundTracks[i])

			if soundData then
				gSoundMgr:StopSoundByNid(self.instance.stringSoundTracks[i])
			end

			self.instance.stringSoundTracks[i] = 0
		end
	end
end

function M:OnUpdate()
	if not gCS.LuaUtils.IsPointerPressed() then
		self.instance.previousMousePosition = nil
		self.instance.lastTriggeredStringIndex = nil

		return
	end

	local currentMousePosition = gCS.LuaUtils.GetPointerPosition()

	if self.instance.previousMousePosition == nil then
		self.instance.previousMousePosition = currentMousePosition

		self:CheckStringIntersections(currentMousePosition, currentMousePosition)

		return
	end

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	self:CheckStringIntersections(self.instance.previousMousePosition, currentMousePosition)

	self.instance.previousMousePosition = currentMousePosition
end

function M:CheckStringIntersections(startPoint, endPoint)
	for i = 1, self.instance.config.stringCount do
		if self:IsLineIntersectingButton(startPoint, endPoint, i) and self.instance.lastTriggeredStringIndex ~= i then
			self.instance.lastTriggeredStringIndex = i
			local isUpStroke = startPoint.y < endPoint.y

			self:OnStringBtnHover(i, isUpStroke)
		end
	end
end

function M:IsLineIntersectingButton(startPoint, endPoint, stringIndex)
	local rectTransform = self.bindData["stringBtn" .. stringIndex].rectTransform:GetChild(0)

	if rectTransform == nil then
		return false
	end

	local rect = rectTransform.rect
	local pivot = rectTransform.pivot
	local anchoredPosition = rectTransform.anchoredPosition
	local minX = anchoredPosition.x - rect.width * pivot.x
	local maxX = minX + rect.width
	local minY = anchoredPosition.y - rect.height * pivot.y
	local maxY = minY + rect.height
	local startInside = gCS.LuaUtils.RectangleContainsScreenPoint(rectTransform, startPoint)
	local endInside = gCS.LuaUtils.RectangleContainsScreenPoint(rectTransform, endPoint)

	if startInside or endInside then
		return true
	end

	if math.min(startPoint.x, endPoint.x) <= minX and minX <= math.max(startPoint.x, endPoint.x) then
		local denominator = endPoint.x - startPoint.x

		if denominator ~= 0 then
			local y = startPoint.y + (endPoint.y - startPoint.y) * (minX - startPoint.x) / denominator

			if minY <= y and y <= maxY then
				return true
			end
		end
	end

	if math.min(startPoint.x, endPoint.x) <= maxX and maxX <= math.max(startPoint.x, endPoint.x) then
		local denominator = endPoint.x - startPoint.x

		if denominator ~= 0 then
			local y = startPoint.y + (endPoint.y - startPoint.y) * (maxX - startPoint.x) / denominator

			if minY <= y and y <= maxY then
				return true
			end
		end
	end

	if math.min(startPoint.y, endPoint.y) <= minY and minY <= math.max(startPoint.y, endPoint.y) then
		local denominator = endPoint.y - startPoint.y

		if denominator ~= 0 then
			local x = startPoint.x + (endPoint.x - startPoint.x) * (minY - startPoint.y) / denominator

			if minX <= x and x <= maxX then
				return true
			end
		end
	end

	if math.min(startPoint.y, endPoint.y) <= maxY and maxY <= math.max(startPoint.y, endPoint.y) then
		local denominator = endPoint.y - startPoint.y

		if denominator ~= 0 then
			local x = startPoint.x + (endPoint.x - startPoint.x) * (maxY - startPoint.y) / denominator

			if minX <= x and x <= maxX then
				return true
			end
		end
	end

	return false
end

function M:OnDestroy()
	if self.instance == nil then
		return
	end

	self:StopAllStringSounds()

	self.instance = nil

	self:ClearMessageEvents()
end

function M:StopAllStringSounds()
	for i = 1, self.instance.config.stringCount do
		self:StopStringSound(i)
	end
end

function M:StopStringSound(stringIndex)
	if self.instance.stringSoundTracks[stringIndex] ~= 0 then
		gSoundMgr:StopSoundByNid(self.instance.stringSoundTracks[stringIndex])

		self.instance.stringSoundTracks[stringIndex] = 0
	end
end

function M:OnExitBtnClick()
	gPanelManager:Close(self.instance.panelId)
end

function M:OnMuteBtnPress(isPress)
	self.instance.isMuteActive = isPress

	if isPress then
		self:StopAllStringSounds()
	end
end

function M:OnPalmMuteBtnPress(isPress)
	self.instance.isPalmMuteActive = isPress

	if isPress then
		self:StopAllStringSounds()
	end
end

function M:OnChordBtnClick(index)
	local btn = self.bindData["chordBtn" .. index]

	if self.instance.currentChordIndex == index then
		self.instance.currentChordIndex = nil

		btn:SetSelected(false)
		self:PlayChordSwitchSound(nil)
		self:SetInt_Left(LTConfig.InstrumentConfig.Guitar_StateTreeVar_NoChord)
	else
		if self.instance.currentChordIndex then
			local prevBtn = self.bindData["chordBtn" .. self.instance.currentChordIndex]

			prevBtn:SetSelected(false)
		end

		self.instance.currentChordIndex = index

		btn:SetSelected(true)
		self:PlayChordSwitchSound(index)

		local chordCfg = LTConfig.InstrumentGuitarConfig.GetConfig(index)

		if chordCfg and chordCfg.StateTreeVar then
			self:SetInt_Left(chordCfg.StateTreeVar)
		end
	end
end

function M:PlayChordSwitchSound(chordIndex)
	return
end

function M:OnStringBtnClick(index)
	if self.instance.isMuteActive then
		return
	end

	local fretIndex = 0

	if self.instance.currentChordIndex then
		local chordCfg = LTConfig.InstrumentGuitarConfig.GetConfig(self.instance.currentChordIndex)

		if chordCfg then
			fretIndex = chordCfg.ChordFrets[index] or 0
		end
	end

	self:SetInt_Right(index, false)
	self:PlayStringSound(index, fretIndex)
end

function M:OnStringBtnHover(index, isUpStroke)
	if not gCS.LuaUtils.IsPointerPressed() then
		return
	end

	local fretIndex = 0

	if self.instance.currentChordIndex then
		local chordCfg = LTConfig.InstrumentGuitarConfig.GetConfig(self.instance.currentChordIndex)

		if chordCfg then
			fretIndex = chordCfg.ChordFrets[index] or 0
		end
	end

	self:SetInt_Right(index, isUpStroke)
	self:PlayStringSound(index, fretIndex)
end

function M:PlayStringSound(stringIndex, fretIndex)
	self:StopStringSound(stringIndex)

	if fretIndex < 0 then
		return
	end

	local baseSoundId = nil

	if self.instance.isPalmMuteActive then
		baseSoundId = LTConfig.InstrumentConfig.GuitarPalmMuteSoundIdStart
	else
		baseSoundId = LTConfig.InstrumentConfig.GuitarSoundIdStart
	end

	local soundId = baseSoundId + (stringIndex - 1) * 25 + fretIndex
	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData then
		local nid = gSoundMgr:PlaySoundByData(soundData)
		self.instance.stringSoundTracks[stringIndex] = nid
	else
		self.instance.stringSoundTracks[stringIndex] = 0
	end
end

function M:SetChordPCKey(pcKeyList)
	for i, key in ipairs(pcKeyList) do
		local btn = self.instance.stringBtns[i]

		btn:SetPCKeyInfoWithOutTip(key)
	end
end

local SetInt = MuGenStates.Logic.ABPVarManager.SetInt

function M:SetInt_Left(value)
	SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.GuitarLeftType, value)
end

function M:SetInt_Right(stringIndex, isUpStroke)
	local baseValue = LTConfig.InstrumentConfig.Guitar_StateTreeVar_Down_String1 + (stringIndex - 1) * 2
	local finalValue = isUpStroke and baseValue + 1 or baseValue

	SetInt(gCS.MyPlayerManager.PlayerUnit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
end
