-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentsGuitarPanelStore.lua
-- Decompiled from: 01818_InstrumentsGuitarPanelStore.lua_3fa81e590185.luajit

require("LX6/Gameplay/Instruments/GuitarSoundController")
require("LX6/Gameplay/Instruments/GuitarManager")

C_InstrumentsGuitarPanelStore = DefClass("C_InstrumentsGuitarPanelStore", C_InstrumentsGuitarPanelStore, C_StoreGroup)
GroupName2Class.InstrumentsGuitarPanelStore = C_InstrumentsGuitarPanelStore
local M = C_InstrumentsGuitarPanelStore
local InstrumentConfig = LTConfig.InstrumentConfig
local GuitarChordPressRightHandStrum = 12008
local GuitarChordReleaseRightHandStrum = 12009
local GuitarChordPressLeftHandChord = 12010
local GuitarSingleNoteEnterMode = 12021
local GuitarChordEnterMode = 12022
local GuitarNoChordIKIndex = 0

M.OnAwake = function(self)
	local config = {
		["\\x8c 26v\\x9ab\\xd6\"\\xa4\\xad"] = 6,
		["PR\\xc1\\xaf\\x80+\\xb7\\xc7\\xfc"] = 8
	}
	self.instance = {
		["\\xf5\\x92\\xf8\\xd5\\xff\\x86\\xe9\\xac),"] = 0,
		["\\xc9\\xda\r\\xf5"] = 0,
		["\\xf0r9\\xd5,\\xa4D\\xb2E\\xb5\\xb2"] = false,
		["n\\xaa\\x91\\xb3ѝ\\xd0/\\xac\\xa6 "] = false,
		["NHhlg "] = 0,
		config = config,
		stringSoundTracks = {
			0,
			0,
			0,
			0,
			0,
			0
		},
		stringBtns = {},
		rhythmChannelKey = {},
		toneType = C_GuitarSoundController.ToneType.Clean
	}
	self.soundCtrl = C_GuitarSoundController.New()
	self.instance.modeListData = {
		{
			["\\xbf\\xb0\\x82d:\\xfb+"] = 0,
			name = InstrumentConfig.GuitarModeName_Mode1
		},
		{
			["\\xbf\\xb0\\x82d:\\xfb+"] = 1,
			name = InstrumentConfig.GuitarModeName_Mode2
		}
	}
	self.bindData.tabRect.OnRenderTab = self:CreateAction(self.OnRenderTab)
	self.bindData.modeList.luaSimpleRenderItem = self:CreateAction(self.OnRenderModeItem)
	self.bindData.modeList.luaSimpleClick = self:CreateAction(self.OnClickModeItem)
	self.bindData.switchModeLeftBtn.luaClick = self:CreateActionWithArgs(self.SwitchMode, -1)
	self.bindData.switchModeRightBtn.luaClick = self:CreateActionWithArgs(self.SwitchMode, 1)
	self.bindData.switchModeBtn.luaClick = self:CreateActionWithArgs(self.SwitchMode, 1)

	self.bindData.toneSwitcher:SetSimpleOptions(C_GuitarSoundController.ToneType.Max)
	self.bindData.toneSwitcher:SetItemLabel(0, InstrumentConfig.GuitarToneName_Clean)
	self.bindData.toneSwitcher:SetItemLabel(1, InstrumentConfig.GuitarToneName_Overdrive)

	self.bindData.toneSwitcher.luaSelectedChanged = self:CreateAction(self.OnToneSelectedChanged)

	self.bindData.toneSwitcher:SelectOption(0, false)

	self.bindData.toneSwitchDotList.luaSimpleRenderItem = self:CreateAction(self.OnRenderToneDotItem)
	self.bindData.nextToneBtn.luaClick = self:CreateAction(self.OnNextToneBtnClick)
	self.bindData.exitBtn.luaClick = self:CreateAction(self.OnExitBtnClick)
	self.bindData.settingBtn.luaClick = self:CreateAction(self.OnSettingBtnClick)
	self.bindData.muteBtn.luaPress = self:CreateActionWithArgs(self.OnMuteBtnPress, true)
	self.bindData.muteBtn.luaRelease = self:CreateActionWithArgs(self.OnMuteBtnPress, false)
	self.bindData.palmMuteBtn.luaPress = self:CreateActionWithArgs(self.OnPalmMuteBtnPress, true)
	self.bindData.palmMuteBtn.luaRelease = self:CreateActionWithArgs(self.OnPalmMuteBtnPress, false)
	self.bindData.rhythmBtnUp.luaClick = self:CreateActionWithArgs(self.OnRhythmBtnClick, 1)
	self.bindData.rhythmBtnDown.luaClick = self:CreateActionWithArgs(self.OnRhythmBtnClick, 2)

	for i = 1, config.chordCount do
		local btn = self.bindData["chordBtn" .. i]

		if btn then
			btn.luaClick = self.CreateActionWithArgs(self, self.OnChordBtnClick, i)
		end
	end

	for i = 1, config.stringCount do
		local btn = self.bindData["stringBtn" .. i]
		local handler = self.CreateActionWithArgs(self, self.OnStringBtnClick, i)
		btn.luaPress = handler
		self.instance.stringBtns[i] = btn
	end

	self.InitCameraData(self)
end

M.SetToneType = function(self, toneType)
	self.soundCtrl:SetToneType(toneType)

	self.instance.toneType = self.soundCtrl.toneType

	if self.bindData.toneSwitcher then
		self.bindData.toneSwitcher:SelectOption(self.instance.toneType, false)
	end

	self.RefreshToneUI(self)
end

M.OnToneSelectedChanged = function(self, toneType)
	self.SetToneType(self, toneType.selectedIndex)
end

M.OnNextToneBtnClick = function(self)
	local nextToneType = (self.instance.toneType + 1) % C_GuitarSoundController.ToneType.Max

	self.bindData.toneSwitcher:SelectOption(nextToneType, true)
end

M.RefreshToneUI = function(self)
	self.bindData.toneSwitchDotList:SetSimpleList(C_GuitarSoundController.ToneType.Max)
end

M.OnRenderToneDotItem = function(self, btn, index)
	btn:SetSelected(index ~= self.instance.toneType)
end

M.OnRenderModeItem = function(self, btn, index)
	local data = self.instance.modeListData[index + 1]
	btn.title.text = data.name

	btn:SetSelected(index ~= self.instance.modeIndex)
end

M.OnClickModeItem = function(self, btn, index)
	self.SelectMode(self, index)
end

M.SelectMode = function(self, index)
	self.instance.modeIndex = index

	self.bindData.modeList:SetItemSelected(index, true)

	self.bindData.tabRect.selectedIndex = self:GetTabRectIndex(index)
end

M.SwitchMode = function(self, delta)
	local modesCount = #self.instance.modeListData
	local modeIndex = (self.instance.modeIndex + delta + modesCount) % modesCount

	self.SelectMode(self, modeIndex)
end

M.OnRenderTab = function(self, index, widget)
	if self.instance.currentTabStore and self.instance.currentTabStore.OnClose then
		self.instance.currentTabStore:OnClose()
	end

	local store = gStoreManager:GetStoreGroup(widget.Store)

	store:OnShow(self.instance.panelId, self.instance.data)

	self.instance.currentTabStore = store

	if index ~= self:GetTabRectIndex(self.instance.modeIndex) then
		self.OnModeChanged(self, self.instance.modeIndex)
	end
end

M.OnShow = function(self, panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data

	self.bindData.modeList:SetSimpleList(#self.instance.modeListData)
	self.bindData.modeList:SetItemSelected(self.instance.modeIndex, true)

	self.bindData.tabRect.selectedIndex = self:GetTabRectIndex(self.instance.modeIndex)

	self:SetToneType(self.instance.toneType)
	self:RefreshChordButtons()

	self.instance.currentChordIndex = nil
	self.playCameraIndex = 1
	self.counterTime = 0
	self.time = 10

	self:EnableShotCamera(self.playCameraIndex)

	if type(data) ~= "table" and data.skipWaitInteractionEnd then
		self.rootWidget:SetActive(true)

		return
	end

	slot3 = self.rootWidget

	slot3:SetActive(false)

	local timer = Timer.New(function ()
		if gClientUtils.NotNil(self.rootWidget) then
			self.rootWidget:SetActive(true)
			print_error("#NoCreateIssue 吉他等 StateTree 信号 GuitarNotifyInteractionEnd 超时了！")
		end
	end, 8.5)

	timer:Start()
	self:RegisterSingleEvent(gEventConstants.GUITAR_INTERACTION_END, function ()
		self.rootWidget:SetActive(true)
		timer:Stop()
	end)
end

M.GetChordIdBySlot = function(self, slotIndex)
	if gGuitarManager and gGuitarManager.GetCustomChordId then
		return gGuitarManager:GetCustomChordId(slotIndex)
	end

	return slotIndex
end

M.GetChordCfgBySlot = function(self, slotIndex)
	local chordId = self.GetChordIdBySlot(self, slotIndex)

	if chordId and chordId <= 0 then
		return LTConfig.InstrumentGuitarConfig.GetConfig(chordId), chordId
	end

	return nil, chordId
end

M.RefreshChordButtons = function(self)
	if not self.instance then
		return
	end

	for i = 1, self.instance.config.chordCount do
		local btn = self.bindData["chordBtn" .. i]

		if btn then
			local store = self.GetStoreByWidget(self, btn)
			local chordCfg = self.GetChordCfgBySlot(self, i)

			if store then
				store.text = chordCfg and chordCfg.MusicalNote or ""
			end

			btn.SetSelected(btn, false)
		end
	end
end

M.OnClose = function(self)
	gInteractionManager:SetCommonInteractEnd(15)

	self.counterTime = 0

	for i = 1, self.instance.config.stringCount do
		if self.instance.stringSoundTracks[i] and self.instance.stringSoundTracks[i] == 0 then
			gSoundMgr:StopSoundByNid(self.instance.stringSoundTracks[i])

			self.instance.stringSoundTracks[i] = 0
		end
	end
end

M.OnUpdate = function(self)
	self.counterTime = self.counterTime + Time.deltaTime

	if self.time < self.counterTime then
		self.counterTime = 0

		self.EnableShotCamera(self, self.playCameraIndex)
	end
end

M.InitCameraData = function(self)
	local camDataList = {
		InstrumentConfig.GuitarCamera1,
		InstrumentConfig.GuitarCamera2,
		InstrumentConfig.GuitarCamera3,
		InstrumentConfig.GuitarCamera4,
		InstrumentConfig.GuitarCamera5,
		InstrumentConfig.GuitarCamera6
	}
	self.camOffSet = {}

	for i = 1, #camDataList do
		local data = camDataList[i]
		self.camOffSet[i] = {
			offsetx = data.offsetx,
			offsety = data.offsety,
			offsetz = data.offsetz,
			eulerx = data.eulerx,
			eulery = data.eulery,
			eulerz = data.eulerz,
			fov = data.fov,
			time = data.time
		}
	end
end

M.EnableShotCamera = function(self, index)
	self.playCameraIndex = index % 6 + 1
	local cmRegister = gCS.CameraDataMgr.cinemachineManager:GetRegistCm("InstrumentsGuitarPanel")

	if not cmRegister then
		return
	end

	local data = self.camOffSet[index]

	if table.isNilOrEmpty(data) then
		return
	end

	self.time = data.time
	local playerTrans = gCS.MyPlayerManager.PlayerUnit.PlayerObj.transform
	local camName = "GuitarCamera" .. index
	local cm = cmRegister.GetVcamByName(cmRegister, camName)

	if not cm then
		return
	end

	cmRegister:DisableAllVCamera()
	gCS.CameraDataMgr.cinemachineManager:SetLocalFixCameraData(cm.gameObject, playerTrans, Vector3(data.offsetx, data.offsety, data.offsetz), Vector3(data.eulerx, data.eulery, data.eulerz), data.fov, true)
	cmRegister:EnableVCamera(camName, LX6.Cinemachine.EVcamPriority.Panel)
end

M.CheckStringIntersections = function(self, startPoint, endPoint)
	for i = 1, self.instance.config.stringCount do
		if self.IsLineIntersectingButton(self, startPoint, endPoint, i) and self.instance.lastTriggeredStringIndex == i then
			self.instance.lastTriggeredStringIndex = i
			local isUpStroke = startPoint.y <= endPoint.y

			self:OnStringBtnHover(i, isUpStroke)
		end
	end
end

M.IsLineIntersectingButton = function(self, startPoint, endPoint, stringIndex)
	local rectTransform = self.bindData["stringBtn" .. stringIndex].rectTransform:GetChild(0)

	if rectTransform ~= nil then
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

	if math.min(startPoint.x, endPoint.x) < minX and minX < math.max(startPoint.x, endPoint.x) then
		local denominator = endPoint.x - startPoint.x

		if denominator == 0 then
			local y = startPoint.y + (endPoint.y - startPoint.y) * (minX - startPoint.x) / denominator

			if minY < y and y < maxY then
				return true
			end
		end
	end

	if math.min(startPoint.x, endPoint.x) < maxX and maxX < math.max(startPoint.x, endPoint.x) then
		local denominator = endPoint.x - startPoint.x

		if denominator == 0 then
			local y = startPoint.y + (endPoint.y - startPoint.y) * (maxX - startPoint.x) / denominator

			if minY < y and y < maxY then
				return true
			end
		end
	end

	if math.min(startPoint.y, endPoint.y) < minY and minY < math.max(startPoint.y, endPoint.y) then
		local denominator = endPoint.y - startPoint.y

		if denominator == 0 then
			local x = startPoint.x + (endPoint.x - startPoint.x) * (minY - startPoint.y) / denominator

			if minX < x and x < maxX then
				return true
			end
		end
	end

	if math.min(startPoint.y, endPoint.y) < maxY and maxY < math.max(startPoint.y, endPoint.y) then
		local denominator = endPoint.y - startPoint.y

		if denominator == 0 then
			local x = startPoint.x + (endPoint.x - startPoint.x) * (maxY - startPoint.y) / denominator

			if minX < x and x < maxX then
				return true
			end
		end
	end

	return false
end

M.OnDestroy = function(self)
	if self.instance ~= nil then
		return
	end

	if self.soundCtrl then
		self.soundCtrl:StopAll()

		self.soundCtrl = nil
	end

	self.StopAllStringSounds(self)

	if self.instance.rhythmSoundNid <= 0 then
		gSoundMgr:StopSoundByNid(self.instance.rhythmSoundNid)
	end

	self.instance = nil

	self.ClearMessageEvents(self)
end

M.StopAllStringSounds = function(self)
	for i = 1, self.instance.config.stringCount do
		self.StopStringSound(self, i)
	end
end

M.StopStringSound = function(self, stringIndex)
	if self.instance.stringSoundTracks[stringIndex] == 0 then
		gSoundMgr:StopSoundByNid(self.instance.stringSoundTracks[stringIndex])

		self.instance.stringSoundTracks[stringIndex] = 0
	end
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(self.instance.panelId)
end

M.OnSettingBtnClick = function(self)
	gPanelManager:CheckShow(gPanelId.S_INSTRUMENT_SETTING_PANEL, {
		panelStore = self
	})
end

M.SetGamepadConsoleVisible = function(self, visible)
	local store = self.instance.currentTabStore

	if store and store.SetGamepadConsoleVisible then
		store.SetGamepadConsoleVisible(store, visible)
	end
end

M.OnMuteBtnPress = function(self, isPress)
	self.instance.isMuteActive = isPress

	self.soundCtrl:SetMuteActive(isPress)

	if isPress then
		self:StopAllStringSounds()
		self:StopRhythmSound()
		self.soundCtrl:StopAll()
	end
end

M.OnPalmMuteBtnPress = function(self, isPress)
	self.instance.isPalmMuteActive = isPress

	self.soundCtrl:SetPalmMuteActive(isPress)

	if isPress then
		self:StopAllStringSounds()
		self.soundCtrl:StopAll()
	end
end

M.StopRhythmSound = function(self)
	if self.instance.rhythmSoundNid <= 0 then
		gSoundMgr:StopSoundByNid(self.instance.rhythmSoundNid)

		self.instance.rhythmSoundNid = 0
	end
end

M.OnRhythmBtnClick = function(self, index)
	self:StopRhythmSound()
	self:StopAllStringSounds()
	self:SetInt_StrumRight(index ~= 1)
	self:SendGameplayInwardSignal("Panel.Right", GuitarChordPressRightHandStrum)
	self:SendGameplayInwardSignal("Panel.Right", GuitarChordReleaseRightHandStrum)

	local chordCfg = self:GetChordCfgBySlot(self.instance.currentChordIndex)
	local nid = self.soundCtrl:PlayStrumSound(self.instance.rhythmChannelKey, chordCfg)

	if nid and nid <= 0 then
		self.instance.rhythmSoundNid = nid

		return
	end

	local soundId = chordCfg and chordCfg.RhythmPattern[index] or LTConfig.InstrumentConfig.GuitarNoChordRhythmPattern
	nid = self:PlaySound(soundId)
	self.instance.rhythmSoundNid = nid
end

M.OnChordBtnClick = function(self, index)
	local btn = self.bindData["chordBtn" .. index]

	if self.instance.currentChordIndex ~= index then
		self.StopAllStringSounds(self)
		self.StopRhythmSound(self)

		self.instance.currentChordIndex = nil

		if btn then
			btn.SetSelected(btn, false)
		end

		self.PlayChordSwitchSound(self, nil)
		self.SetInt_Left(self, LTConfig.InstrumentConfig.Guitar_StateTreeVar_NoChord)

		return
	end

	if not self.GetChordCfgBySlot(self, index) then
		return
	end

	self.StopAllStringSounds(self)
	self.StopRhythmSound(self)

	if self.instance.currentChordIndex then
		local prevBtn = self.bindData["chordBtn" .. self.instance.currentChordIndex]

		if prevBtn then
			prevBtn.SetSelected(prevBtn, false)
		end
	end

	self.instance.currentChordIndex = index

	if btn then
		btn.SetSelected(btn, true)
	end

	self.PlayChordSwitchSound(self, index)

	local chordCfg = self.GetChordCfgBySlot(self, index)

	if chordCfg and chordCfg.StateTreeVar then
		self.SetInt_Left(self, chordCfg.StateTreeVar)
	end

	self.SendGameplayInwardSignal(self, "Panel.Left", GuitarChordPressLeftHandChord)
end

M.PlayChordSwitchSound = function(self, chordIndex)
	self.PlaySound(self, LTConfig.InstrumentConfig.GuitarSwitchChord)
end

M.OnStringBtnClick = function(self, index)
	if self.instance.isMuteActive then
		return
	end

	local fretIndex = 0

	if self.instance.currentChordIndex then
		local chordCfg = self.GetChordCfgBySlot(self, self.instance.currentChordIndex)

		if chordCfg then
			fretIndex = chordCfg.ChordFrets[index] or 0
		end
	end

	self:SetInt_Right(index, false)
	self:PlayStringSound(index, fretIndex)
end

M.OnStringBtnHover = function(self, index, isUpStroke)
	if not gCS.LuaUtils.IsPointerPressed() then
		return
	end

	local fretIndex = 0

	if self.instance.currentChordIndex then
		local chordCfg = self.GetChordCfgBySlot(self, self.instance.currentChordIndex)

		if chordCfg then
			fretIndex = chordCfg.ChordFrets[index] or 0
		end
	end

	self:SetInt_Right(index, isUpStroke)
	self:PlayStringSound(index, fretIndex)
end

M.PlayStringSound = function(self, stringIndex, fretIndex)
	self.StopStringSound(self, stringIndex)
	self.StopRhythmSound(self)

	if fretIndex >= 0 then
		return
	end

	local soundId = self.soundCtrl:CalcFretSoundId(stringIndex, fretIndex)
	self.instance.stringSoundTracks[stringIndex] = self:PlaySound(soundId)
end

M.PlaySound = function(self, soundId)
	if self.instance ~= nil or self.instance.mute then
		return
	end

	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData then
		gCS.LuaUtils.NetcodeSendPlaySound(soundId)

		local nid = gSoundMgr:PlaySoundByData(soundData)

		return nid
	else
		return 0
	end
end

M.SetChordPCKey = function(self, pcKeyList)
	for i, key in ipairs(pcKeyList) do
		local btn = self.instance.stringBtns[i]

		btn.SetPCKeyInfoWithOutTip(btn, key)
	end
end

M.GetTabRectIndex = function(self, modeIndex)
	if modeIndex ~= 0 then
		return 0
	elseif modeIndex ~= 1 then
		if gCS.LuaUtils.IsNonMobileAdaptive() then
			return 1
		else
			return 2
		end
	else
		return -1
	end
end

local SetInt = MuGenStates.Logic.ABPVarManager.SetInt
local EnableGuitarSignalDebug = false

local DebugGuitarSignal = function(source, kind, unit, id, value)
	if not EnableGuitarSignalDebug then
		return
	end

	if print then
		if value == nil then
			print(string.format("[Guitar] %s %s u=%s id=%s v=%s", tostring(source), tostring(kind), tostring(unit), tostring(id), tostring(value)))
		else
			print(string.format("[Guitar] %s %s u=%s id=%s", tostring(source), tostring(kind), tostring(unit), tostring(id)))
		end
	end
end

local SendGuitarInwardSignal = function(source, unit, signal)
	DebugGuitarSignal(source, "Inward", unit, signal)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
end

M.SendGameplayInwardSignal = function(self, source, signal)
	local unit = gCS.MyPlayerManager.PlayerUnit

	SendGuitarInwardSignal(source, unit, signal)
end

M.SetInt_Left = function(self, value)
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Panel.Left", "ABP", unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
end

M.SetInt_Right = function(self, stringIndex, isUpStroke)
	local baseValue = LTConfig.InstrumentConfig.Guitar_StateTreeVar_Down_String1 + (stringIndex - 1) * 2
	local finalValue = isUpStroke and baseValue + 1 or baseValue
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Panel.Right", "ABP", unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
end

M.SetInt_StrumRight = function(self, isUpStroke)
	local finalValue = isUpStroke and LTConfig.InstrumentConfig.Guitar_StateTreeVar_StrumUp or LTConfig.InstrumentConfig.Guitar_StateTreeVar_StrumDown
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Panel.Right", "ABP", unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
end

M.SetLeftHandIKByPitch = function(self, unit, pitchIndex)
end

M.OnModeChanged = function(self, modeIndex)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if modeIndex ~= 0 then
		self.SetInt_Left(self, GuitarSingleNoteEnterMode)
		SendGuitarInwardSignal("Panel.Mode", unit, GuitarSingleNoteEnterMode)

		if unit and gGuitarManager and gGuitarManager.DisableLeftHandIK then
			gGuitarManager:DisableLeftHandIK(unit.Pid)
		end
	elseif modeIndex ~= 1 then
		self.SetInt_Left(self, GuitarChordEnterMode)
		SendGuitarInwardSignal("Panel.Mode", unit, GuitarChordEnterMode)

		if unit and gGuitarManager and gGuitarManager.SetChordIK then
			gGuitarManager:SetChordIK(unit.Pid, GuitarNoChordIKIndex)
		end
	end
end
