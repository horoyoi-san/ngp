-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentsGuitarPanelMode1Store.lua
-- Decompiled from: 01823_InstrumentsGuitarPanelMode1Store.lua_5057ec13ef23.luajit

C_InstrumentsGuitarPanelMode1Store = DefClass("C_InstrumentsGuitarPanelMode1Store", C_InstrumentsGuitarPanelMode1Store, C_StoreGroup)
GroupName2Class.InstrumentsGuitarPanelMode1Store = C_InstrumentsGuitarPanelMode1Store
local M = C_InstrumentsGuitarPanelMode1Store

require("LX6/Gameplay/Instruments/GuitarSoundController")
require("LX6/Gameplay/Instruments/GuitarGamepadControllerUI")
require("LX6/Gameplay/Instruments/GuitarManager")

local InstrumentSingleConfig = LTConfig.InstrumentSingleConfig
local GuitarSingleNotePressRightHand = LTConfig.GameplaySignalInwardConfig.GuitarSingleNotePressRightHand
local GuitarSingleNotePressLeftHandHighFret = LTConfig.GameplaySignalInwardConfig.GuitarSingleNotePressLeftHandHighFret
local GuitarSingleNotePressLeftHandMidFret = LTConfig.GameplaySignalInwardConfig.GuitarSingleNotePressLeftHandMidFret
local GuitarSingleNotePressLeftHandLowFret = LTConfig.GameplaySignalInwardConfig.GuitarSingleNotePressLeftHandLowFret
local LOW_FRET_MAX_PITCH = 7
local MID_FRET_MAX_PITCH = 14

local GetFretSignalByPitchIndex = function(pitchIndex)
	if pitchIndex < LOW_FRET_MAX_PITCH then
		return GuitarSingleNotePressLeftHandLowFret
	elseif pitchIndex < MID_FRET_MAX_PITCH then
		return GuitarSingleNotePressLeftHandMidFret
	else
		return GuitarSingleNotePressLeftHandHighFret
	end
end

M.OnAwake = function(self)
	local panelStore = gStoreManager:GetStoreGroup("InstrumentsGuitarPanelStore")
	self.instance = {
		["\\xc9\\xda\r\\xf5"] = 0,
		noteList = {},
		hasPCKey = gCS.LuaUtils.IsPCPlatformOrEditorAdaptive(),
		panelStore = panelStore,
		soundCtrl = panelStore.soundCtrl,
		noteChannelKeys = {}
	}
	self.bindData.list.luaSimpleRenderItem = self:CreateAction(self.OnRenderNoteItem)
	self.bindData.list.luaSimplePress = self:CreateAction(self.OnPressNote)
	self.bindData.list.luaSimpleRelease = self:CreateAction(self.OnReleaseNote)
end

M.OnStart = function(self)
	self.InitNoteList(self)

	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.InitGamepadControllers(self)
	end
end

M.OnDestroy = function(self)
	if self.instance ~= nil then
		return
	end

	self.StopAllNoteChannels(self)

	self.instance = nil
end

M.InitNoteList = function(self)
	local listData = {}
	local channelKeys = {}
	local count = InstrumentSingleConfig.count

	for i = 0, count - 1 do
		local cfg = InstrumentSingleConfig.LoadAt(i)
		local view = {
			NoteIndex = i + 1,
			MusicalNote = cfg.MusicalNote,
			PCKeyId = cfg.PCKeyId,
			SoundId = cfg.AudioID
		}

		table.insert(listData, view)

		channelKeys[view.NoteIndex] = {}
	end

	self.instance.noteList = listData
	self.instance.noteChannelKeys = channelKeys

	self.bindData.list:SetSimpleList(#listData)
end

M.OnRenderNoteItem = function(self, btn, index)
	local data = self.instance.noteList[index + 1]
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)
	local cfg = LTConfig.InputSGUIPCKeyConfig.GetConfig(data.PCKeyId)

	if cfg then
		store.PCKey = cfg.Name

		btn.SetPCKeyInfoWithOutTip(btn, data.PCKeyId)
		btn.SetPCKeyTipShowTip(btn, false)
	end
end

M.OnPressNote = function(self, btn, csIndex)
	local data = self.instance.noteList[csIndex + 1]
	local channelKey = self.instance.noteChannelKeys[data.NoteIndex]

	if data.SoundId and data.SoundId <= 0 then
		local soundId = self.instance.soundCtrl:GetSingleNoteSoundId(data.NoteIndex, data.SoundId)

		self.instance.soundCtrl:PlaySoundId(channelKey, soundId)
	end

	self.SetInt_Right(self, GuitarSingleNotePressRightHand)
	self.SetInt_Left(self, GetFretSignalByPitchIndex(data.NoteIndex))
end

M.OnReleaseNote = function(self, btn, csIndex)
	local data = self.instance.noteList[csIndex + 1]
	local channelKey = self.instance.noteChannelKeys[data.NoteIndex]

	self.instance.soundCtrl:StopChannel(channelKey)
end

M.StopAllNoteChannels = function(self)
	for i = 1, #self.instance.noteList do
		local data = self.instance.noteList[i]

		if data then
			local channelKey = self.instance.noteChannelKeys[data.NoteIndex]

			self.instance.soundCtrl:StopChannel(channelKey)
		end
	end
end

M.OnGamepadChordPress = function(self, index)
	local panelStore = self.instance.panelStore

	if panelStore and panelStore.OnChordBtnClick then
		panelStore.OnChordBtnClick(panelStore, index)
	end
end

M.OnGamepadChordRelease = function(self, index)
end

M.OnGamepadNotePress = function(self, index)
	local noteIndex = self.GamepadKeyToNoteIndex(self, index)

	if noteIndex <= 0 and noteIndex < #self.instance.noteList then
		self.OnPressNote(self, nil, noteIndex - 1)
	end
end

M.OnGamepadNoteRelease = function(self, index)
	local noteIndex = self.GamepadKeyToNoteIndex(self, index)

	if noteIndex <= 0 and noteIndex < #self.instance.noteList then
		self.OnReleaseNote(self, nil, noteIndex - 1)
	end
end

M.GamepadKeyToNoteIndex = function(self, index)
	local page = self.instance.gamepadOctavePage or 0
	local noteIndex = page * 7 + index
	local count = #self.instance.noteList

	if noteIndex <= count then
		noteIndex = noteIndex - count
	end

	return noteIndex
end

M.BuildGamepadNoteLabels = function(self)
	local labels = {}

	for i = 1, 8 do
		local data = self.instance.noteList[self:GamepadKeyToNoteIndex(i)]
		labels[i] = data and data.MusicalNote or ""
	end

	return labels
end

M.OnGamepadPageChange = function(self, delta)
	local page = (self.instance.gamepadOctavePage or 0) + delta

	if page <= 2 then
		page = 0
	end

	if page >= 0 then
		page = 2
	end

	self.SetGamepadOctavePage(self, page)
end

M.SetGamepadOctavePage = function(self, page)
	self.instance.gamepadOctavePage = page
	self.instance.gamepadControllerL.store.pianoPageCtrl = page
	self.bindData.octavePageCtrl = page + 1

	self.instance.gamepadControllerL:RefreshButtonLabels(self:BuildGamepadNoteLabels())
end

M.OnGamepadTouchStrum = function(self, context)
	if context.started then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.instance.touchStrumStartY = touchData.touch0.y
	end

	if context.canceled and self.instance.touchStrumStartY then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		local isUpStroke = self.instance.touchStrumStartY <= touchData.touch0.y
		self.instance.touchStrumStartY = nil
		local panelStore = self.instance.panelStore

		if panelStore then
			panelStore:OnRhythmBtnClick(isUpStroke and 1 or 2)
		end
	end
end

M.InitGamepadControllers = function(self)
	local chordLabels = {}

	for i = 1, 8 do
		local cfg = LTConfig.InstrumentGuitarConfig.GetConfig(i)
		chordLabels[i] = cfg and cfg.MusicalNote or ""
	end

	self.instance.gamepadControllerL = C_GuitarGamepadControllerUI.new(self.bindData.controllerL, {
		["\n\\xe2L\\xd7\\x85V\\xa8B\\xb3\\xbe"] = true,
		["\\x9d!4+w\\x93b\\xd6\"\\xa4\\xad"] = 8,
		buttonLabels = {},
		onButtonPress = self.CreateAction(self, self.OnGamepadNotePress),
		onButtonRelease = self.CreateAction(self, self.OnGamepadNoteRelease),
		onPageChange = self.CreateAction(self, self.OnGamepadPageChange)
	})
	self.instance.gamepadOctavePage = 0

	self.SetGamepadOctavePage(self, 0)

	self.bindData.touchCustomNavRespond.luaGamePadInputChanged = self.CreateAction(self, self.OnGamepadTouchStrum)
end

M.SetGamepadConsoleVisible = function(self, visible)
	if self.bindData.controllerL then
		self.bindData.controllerL.gameObjectActive = visible
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

M.SetInt_Left = function(self, value)
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Mode1.Left", "ABP", unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
	SendGuitarInwardSignal("Mode1.Left", unit, value)
end

M.SetInt_Right = function(self, value)
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Mode1.Right", "ABP", unit, LTConfig.ABPVarConfig.GuitarRightType, value)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarRightType, value)
	SendGuitarInwardSignal("Mode1.Right", unit, value)
end
