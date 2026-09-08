-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\InstrumentsGuitarPanelMode2Store.lua
-- Decompiled from: 01821_InstrumentsGuitarPanelMode2Store.lua_531024bc9edb.luajit

C_InstrumentsGuitarPanelMode2Store = DefClass("C_InstrumentsGuitarPanelMode2Store", C_InstrumentsGuitarPanelMode2Store, C_StoreGroup)
GroupName2Class.InstrumentsGuitarPanelMode2Store = C_InstrumentsGuitarPanelMode2Store
local M = C_InstrumentsGuitarPanelMode2Store

require("LX6/Gameplay/Instruments/GuitarSoundController")
require("LX6/Gameplay/Instruments/GuitarGamepadControllerUI")
require("LX6/Gameplay/Instruments/GuitarManager")

local GuitarChordPressRightHandStrum = LTConfig.GameplaySignalInwardConfig.GuitarChordPressRightHandStrum
local GuitarChordReleaseRightHandStrum = LTConfig.GameplaySignalInwardConfig.GuitarChordReleaseRightHandStrum
local GuitarChordPressLeftHandChord = LTConfig.GameplaySignalInwardConfig.GuitarChordPressLeftHandChord
local GuitarNoChordIKIndex = 0

M.OnAwake = function(self)
	local panelStore = gStoreManager:GetStoreGroup("InstrumentsGuitarPanelStore")
	local config = {
		["PR\\xc1\\xaf\\x80+\\xb7\\xc7\\xfc"] = 8
	}
	self.instance = {
		["\\xc9\\xda\r\\xf5"] = 0,
		["\\xf4\\x8d\\xf8\\xd5\\xff\\x86\\xe9\\xac),"] = 0,
		["\\xf5\\x92\\xf8\\xd5\\xff\\x86\\xe9\\xac),"] = 0,
		["\\x96'+j\\x88L\\xd4>\\xa4\\xbe"] = false,
		config = config,
		panelStore = panelStore,
		soundCtrl = panelStore and panelStore.soundCtrl or nil
	}

	if self.bindData.exitBtn then
		self.bindData.exitBtn.luaClick = self.CreateAction(self, self.OnExitBtnClick)
	end

	for i = 1, config.chordCount do
		local btn = self.bindData["chordBtn" .. i]

		if btn then
			btn.luaClick = self.CreateActionWithArgs(self, self.OnChordBtnClick, i)

			btn.SetSelected(btn, false)
		end
	end

	self.RefreshChordButtons(self)

	self.bindData.beatsBtn1.luaPress = self.CreateActionWithArgs(self, self.OnStrokeBtnPress, false)
	self.bindData.beatsBtn1.luaRelease = self.CreateActionWithArgs(self, self.OnStrokeBtnRelease, false)
	self.bindData.beatsBtn2.luaPress = self.CreateActionWithArgs(self, self.OnStrokeBtnPress, true)
	self.bindData.beatsBtn2.luaRelease = self.CreateActionWithArgs(self, self.OnStrokeBtnRelease, true)
end

M.OnStart = function(self)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		self.InitGamepadController(self)
	end
end

M.OnShow = function(self, panelId, data)
	self.instance.panelId = panelId
	self.instance.data = data

	self:RefreshChordButtons()
	self:RefreshBeatButtons()
	self:ResetChordSelectionUI()
	self:SetChordSelection(nil, false)
	self.instance.soundCtrl:GetStrumSwitchSoundData()
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
			local chordCfg = self:GetChordCfgBySlot(i)
			btn.title.text = chordCfg and chordCfg.MusicalNote or ""

			btn:SetSelected(false)
			self:SetChordBtnPlayingVfx(i, false)
		end
	end
end

M.SetChordBtnPlayingVfx = function(self, index, isPlaying)
	local btn = self.bindData["chordBtn" .. index]

	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.playingVfxCtrl = isPlaying and 1 or 0
	end
end

M.RefreshBeatButtons = function(self)
	if not self.instance then
		return
	end

	self.RenderBeatButton(self, self.bindData.beatsBtn1, 1)
	self.RenderBeatButton(self, self.bindData.beatsBtn2, 2)
	self.SetBeatBtnPlayingVfx(self, self.bindData.beatsBtn1, false)
	self.SetBeatBtnPlayingVfx(self, self.bindData.beatsBtn2, false)
end

M.SetBeatBtnPlayingVfx = function(self, btn, isPlaying)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if store then
		store.playingVfxCtrl = isPlaying and 1 or 0
	end
end

M.RenderBeatButton = function(self, btn, slot)
	if not btn then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local beatId = gGuitarManager and gGuitarManager.GetCustomBeatId and gGuitarManager:GetCustomBeatId(slot) or 0
	store.beatName = self:GetBeatName(beatId)
end

M.GetBeatName = function(self, beatId)
	if not beatId or beatId ~= 0 then
		return ""
	end

	return LTConfig.InstrumentConfig["Guitar_RhythmName_" .. beatId]
end

M.OnClose = function(self)
	self.ResetChordSelectionUI(self)
	self.SetChordSelection(self, nil, false)
	self.StopAllCurrentSounds(self)
end

M.OnDestroy = function(self)
	if self.instance ~= nil then
		return
	end

	self.ResetChordSelectionUI(self)
	self.SetChordSelection(self, nil, false)
	self.StopAllCurrentSounds(self)

	self.instance = nil

	self.ClearMessageEvents(self)
end

M.ResetChordSelectionUI = function(self)
	for i = 1, self.instance.config.chordCount do
		local btn = self.bindData["chordBtn" .. i]

		if btn then
			btn.SetSelected(btn, false)
			self.SetChordBtnPlayingVfx(self, i, false)
		end
	end
end

M.UpdateLeftHandIK = function(self, chordIndex)
	local unit = gCS.MyPlayerManager.PlayerUnit

	if not unit or not gGuitarManager then
		return
	end

	if gGuitarManager.SetChordIK then
		gGuitarManager:SetChordIK(unit.Pid, chordIndex or GuitarNoChordIKIndex)
	end
end

M.OnChordBtnClick = function(self, index)
	if self.instance.currentChordIndex ~= index then
		self:SetChordSelection(nil, false)

		local soundData = self.instance.soundCtrl:GetStrumSwitchSoundData()

		if soundData and soundData.soundEvt then
			soundData.soundEvt:SetSwitchValue(gSoundMgr.GameStateGroup.EGuitarStrumChord.StateName, "Default")
		end

		self.SendGameplayInwardSignal(self, "Mode2.Left", GuitarChordPressLeftHandChord)

		return
	end

	if not self.GetChordCfgBySlot(self, index) then
		return
	end

	local soundData = self.instance.soundCtrl:GetStrumSwitchSoundData()

	if soundData and soundData.soundEvt then
		local chordCfg = self:GetChordCfgBySlot(index)
		local chordSwitch = self.instance.soundCtrl:GetStrumChordSwitchName(chordCfg)

		soundData.soundEvt:SetSwitchValue(gSoundMgr.GameStateGroup.EGuitarStrumChord.StateName, chordSwitch)
	end

	self.SetChordSelection(self, index, false)
	self.SendGameplayInwardSignal(self, "Mode2.Left", GuitarChordPressLeftHandChord)
end

M.OnChordBtnPress = function(self, index)
	self.OnChordBtnClick(self, index)
end

M.OnChordBtnRelease = function(self, index)
end

M.SetChordSelection = function(self, index, playSwitchSound)
	if self.instance.currentChordIndex then
		local prevBtn = self.bindData["chordBtn" .. self.instance.currentChordIndex]

		if prevBtn then
			prevBtn.SetSelected(prevBtn, false)
		end

		self.SetChordBtnPlayingVfx(self, self.instance.currentChordIndex, false)
	end

	self.instance.currentChordIndex = index
	local chordCfg = nil
	local chordId = GuitarNoChordIKIndex

	if index then
		chordCfg, chordId = self.GetChordCfgBySlot(self, index)
	end

	self:UpdateLeftHandIK(index and chordId or GuitarNoChordIKIndex)

	if index then
		self.SetChordBtnPlayingVfx(self, index, true)

		if chordCfg and chordCfg.StateTreeVar then
			self.SetInt_Left(self, chordCfg.StateTreeVar)
		end

		if playSwitchSound then
			self.PlayChordSwitchSound(self, index)
		end

		return
	end

	self.SetInt_Left(self, LTConfig.InstrumentConfig.Guitar_StateTreeVar_NoChord)
end

M.OnStrokeBtnPress = function(self, isBeatB)
	if self.IsMuteActive(self) then
		return
	end

	local strumEventId = self.instance.soundCtrl:GetStrumEventId()

	if not strumEventId or strumEventId < 0 then
		return
	end

	self:SetInt_Right(isBeatB)

	self.instance.isStrumming = true

	self:SetBeatBtnPlayingVfx(self.bindData.beatsBtn1, false)
	self:SetBeatBtnPlayingVfx(self.bindData.beatsBtn2, false)
	self:SetBeatBtnPlayingVfx(isBeatB and self.bindData.beatsBtn2 or self.bindData.beatsBtn1, true)

	self.instance.activeStrokeIsSlotB = isBeatB

	self:SendGameplayInwardSignal("Mode2.Right", GuitarChordPressRightHandStrum)
	self:PlayStrokeSound(isBeatB)
end

M.OnStrokeBtnClick = function(self, isBeatB)
	self.OnStrokeBtnPress(self, isBeatB)
	self.OnStrokeBtnRelease(self, isBeatB)
end

M.OnStrokeBtnRelease = function(self, isBeatB)
	if not self.instance.isStrumming then
		return
	end

	if isBeatB == nil and self.instance.activeStrokeIsSlotB == nil and isBeatB == self.instance.activeStrokeIsSlotB then
		return
	end

	self.instance.isStrumming = false
	self.instance.activeStrokeIsSlotB = nil

	self:SetBeatBtnPlayingVfx(self.bindData.beatsBtn1, false)
	self:SetBeatBtnPlayingVfx(self.bindData.beatsBtn2, false)
	self.instance.soundCtrl:ResetStrumRhythmSwitch()
	self:SendGameplayInwardSignal("Mode2.Right", GuitarChordReleaseRightHandStrum)
end

M.StopAllCurrentSounds = function(self)
	self:OnStrokeBtnRelease()
	self.instance.soundCtrl:StopAll()

	self.instance.rhythmSoundNid = 0

	if self.instance.switchSoundNid and self.instance.switchSoundNid <= 0 then
		gSoundMgr:StopSoundByNid(self.instance.switchSoundNid)

		self.instance.switchSoundNid = 0
	end
end

M.PlayStrokeSound = function(self, isBeatB)
	local chordCfg = nil

	if self.instance.currentChordIndex then
		chordCfg = self.GetChordCfgBySlot(self, self.instance.currentChordIndex)
	end

	local rhySwitchName = self:GetRhySwitchName(isBeatB)
	self.instance.rhythmSoundNid = self.instance.soundCtrl:PlayStrumSound(chordCfg, rhySwitchName) or 0
end

M.GetRhySwitchName = function(self, isBeatB)
	local slot = isBeatB and 2 or 1
	local beatId = gGuitarManager and gGuitarManager.GetCustomBeatId and gGuitarManager:GetCustomBeatId(slot) or 0

	if not beatId or beatId < 0 then
		return nil
	end

	local rhythmStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumRhy

	return rhythmStateGroup["Rhy" .. beatId]
end

M.IsMuteActive = function(self)
	return self.instance.soundCtrl.isMuteActive
end

M.PlayChordSwitchSound = function(self, chordIndex)
	if self.instance.switchSoundNid and self.instance.switchSoundNid <= 0 then
		gSoundMgr:StopSoundByNid(self.instance.switchSoundNid)

		self.instance.switchSoundNid = 0
	end

	self.instance.switchSoundNid = self.PlaySound(self, LTConfig.InstrumentConfig.GuitarSwitchChord)
end

M.PlaySound = function(self, soundId)
	if self.instance ~= nil or self.IsMuteActive(self) then
		return 0
	end

	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData then
		gCS.LuaUtils.NetcodeSendPlaySound(soundId)

		local nid = gSoundMgr:PlaySoundByData(soundData)

		return nid
	end

	return 0
end

M.OnExitBtnClick = function(self)
	gPanelManager:Close(self.instance.panelId)
end

M.OnGamepadChordPress = function(self, index)
	self.OnChordBtnClick(self, index)
end

M.OnGamepadChordRelease = function(self, index)
end

M.OnGamepadTouchStrum = function(self, context)
	if context.started then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		self.instance.touchStrumStartY = touchData.touch0.y
	end

	if context.canceled and self.instance.touchStrumStartY then
		local touchData = SGUI.UNavigationMgrEx.Inst:GetCurrentPadTouchData()
		local isBeatB = self.instance.touchStrumStartY <= touchData.touch0.y
		self.instance.touchStrumStartY = nil

		self:OnStrokeBtnClick(isBeatB)
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

M.SendGameplayInwardSignal = function(self, source, signal)
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal(source, "Inward", unit, signal)
	gCS.LogicStateMachineManager.SendGameplayInwardSignal(unit, signal)
end

M.SetInt_Left = function(self, value)
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Mode2.Left", "ABP", unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarLeftType, value)
end

M.SetInt_Right = function(self, isUpStroke)
	local finalValue = isUpStroke and LTConfig.InstrumentConfig.Guitar_StateTreeVar_StrumUp or LTConfig.InstrumentConfig.Guitar_StateTreeVar_StrumDown
	local unit = gCS.MyPlayerManager.PlayerUnit

	DebugGuitarSignal("Mode2.Right", "ABP", unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
	SetInt(unit, LTConfig.ABPVarConfig.GuitarRightType, finalValue)
end

M.InitGamepadController = function(self)
	local chordLabels = {}

	for i = 1, 8 do
		local cfg = self:GetChordCfgBySlot(i)
		chordLabels[i] = cfg and cfg.MusicalNote or ""
	end

	self.instance.gamepadControllerL = C_GuitarGamepadControllerUI.new(self.bindData.controllerL, {
		["ds\\xa9g\\xb7\\xfeBin{H"] = true,
		["\\x9d!4+w\\x93b\\xd6\"\\xa4\\xad"] = 8,
		buttonLabels = chordLabels,
		onButtonPress = self.CreateAction(self, self.OnGamepadChordPress),
		onButtonRelease = self.CreateAction(self, self.OnGamepadChordRelease)
	})
end

M.SetGamepadConsoleVisible = function(self, visible)
	local controller = self.bindData.controllerL

	if controller and controller.rectTransform and controller.rectTransform.parent then
		controller.rectTransform.parent.gameObject:SetActive(visible)
	end
end
