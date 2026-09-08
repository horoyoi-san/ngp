-- Original chunk: @Lua\LuaFiles\LX6\Gameplay\Instruments\GuitarSoundController.lua
-- Decompiled from: 01819_GuitarSoundController.lua_95a1b1e4cb36.luajit

local ToneType = {
	["n\\xa2\\xa7\\xae\\xb8"] = 0,
	["\\xa3i~"] = 2,
	["lQi{J="] = 1
}
local static_props = {
	ToneType = ToneType
}
local DefaultSwitch = "Default"
C_GuitarSoundController = DefClass("GuitarSoundController", C_GuitarSoundController, nil, static_props)
local M = C_GuitarSoundController

M.ctor = function(self)
	self.toneType = M.ToneType.Clean
	self.isPalmMuteActive = false
	self.isMuteActive = false
	self.channelNidMap = {}
	self.strumSwitchNid = 0
end

M.SetToneType = function(self, toneType)
	local normalizedToneType = self.NormalizeToneType(self, toneType)

	if self.toneType == normalizedToneType then
		self.StopStrumSwitchSound(self)
	end

	self.toneType = normalizedToneType

	self.GetStrumSwitchSoundData(self)
end

M.SetPalmMuteActive = function(self, isActive)
	self.isPalmMuteActive = isActive and true or false
end

M.SetMuteActive = function(self, isActive)
	self.isMuteActive = isActive and true or false
end

M.IsSendLinkSync = function(self)
	return gLinkManager.LinkMode == UX.Game.LinkMode.None
end

M.GetFretBaseSoundIdStart = function(self)
	if self.isPalmMuteActive then
		return LTConfig.InstrumentConfig.GuitarPalmMuteSoundIdStart
	end

	if self.toneType ~= M.ToneType.Overdrive then
		local overdriveStart = LTConfig.InstrumentConfig.GuitarMode1SoundIdStart_Overdrive

		if overdriveStart and overdriveStart <= 0 then
			return overdriveStart
		end
	end

	return LTConfig.InstrumentConfig.GuitarSoundIdStart
end

M.NormalizeToneType = function(self, toneType)
	if toneType ~= M.ToneType.Overdrive then
		return M.ToneType.Overdrive
	end

	return M.ToneType.Clean
end

M.GetStrumEventId = function(self)
	if self.toneType ~= M.ToneType.Overdrive then
		return LTConfig.InstrumentConfig.Guitar_Overdrive
	end

	return LTConfig.InstrumentConfig.Guitar_Clean
end

M.GetStrumChordSwitchName = function(self, chordCfg)
	local chordStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumChord
	local musicalNote = chordCfg and chordCfg.MusicalNote

	if not musicalNote or musicalNote ~= "" then
		return DefaultSwitch
	end

	local fieldName = "Chord" .. musicalNote

	return chordStateGroup[fieldName] or musicalNote
end

M.SetStrumSwitchValue = function(self, soundData, chordSwitchName, rhythmSwitchName)
	if not soundData or not soundData.soundEvt then
		return false
	end

	local chordStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumChord
	local rhythmStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumRhy

	soundData.soundEvt:SetSwitchValue(chordStateGroup.StateName, chordSwitchName or DefaultSwitch)
	soundData.soundEvt:SetSwitchValue(rhythmStateGroup.StateName, rhythmSwitchName or DefaultSwitch)

	return true
end

M.ResetStrumRhythmSwitch = function(self)
	local soundData = gSoundMgr:GetSoundDataByNid(self.strumSwitchNid)

	if not soundData or not soundData.soundEvt then
		return false
	end

	soundData.soundEvt:SetSwitchValue(gSoundMgr.GameStateGroup.EGuitarStrumRhy.StateName, DefaultSwitch)

	return true
end

M.StopStrumSwitchSound = function(self)
	if self.strumSwitchNid and self.strumSwitchNid == 0 then
		gSoundMgr:StopSoundByNid(self.strumSwitchNid)

		self.strumSwitchNid = 0
	end
end

M.GetStrumSwitchSoundData = function(self)
	local soundId = self.GetStrumEventId(self)

	if not soundId or soundId ~= 0 then
		return nil
	end

	local soundData = gSoundMgr:GetSoundDataByNid(self.strumSwitchNid)

	if soundData and soundData.templateId ~= soundId then
		return soundData
	end

	local newSoundData = gSoundMgr:CreateSoundData(soundId)

	if newSoundData then
		if self.IsSendLinkSync(self) then
			newSoundData.isSyncSender = true
		end

		self.strumSwitchNid = gSoundMgr:PlaySoundByData(newSoundData, nil, , , function (CS_Data)
			CS_Data:SetSwitchValue(gSoundMgr.GameStateGroup.EGuitarStrumChord.StateName, DefaultSwitch)
			CS_Data:SetSwitchValue(gSoundMgr.GameStateGroup.EGuitarStrumRhy.StateName, DefaultSwitch)
			CS_Data:SetSwitchValue(LX6.Constants.SoundConstants.SoundRtpcName.SoundOwner, 1)
		end) or 0
	else
		self.strumSwitchNid = 0
	end

	return gSoundMgr:GetSoundDataByNid(self.strumSwitchNid)
end

M.PlayStrumSound = function(self, chordCfg, rhySwitchName)
	if self.isMuteActive then
		return 0
	end

	local soundData = self.GetStrumSwitchSoundData(self)

	if not soundData or not soundData.soundEvt then
		return 0
	end

	local chordStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumChord
	local rhythmStateGroup = gSoundMgr.GameStateGroup.EGuitarStrumRhy

	soundData.soundEvt:SetSwitchValue(chordStateGroup.StateName, self:GetStrumChordSwitchName(chordCfg))
	soundData.soundEvt:SetSwitchValue(rhythmStateGroup.StateName, rhySwitchName or rhythmStateGroup.Rhy1)

	return self.strumSwitchNid
end

M.GetSingleNoteSoundId = function(self, noteIndex, cleanSoundId)
	return cleanSoundId
end

M.CalcFretSoundId = function(self, stringIndex, fretIndex)
	local baseSoundId = self.GetFretBaseSoundIdStart(self)

	return baseSoundId + (stringIndex - 1) * 25 + fretIndex
end

M.StopChannel = function(self, channelKey)
	local nid = self.channelNidMap[channelKey]

	if nid and nid == 0 then
		gSoundMgr:StopSoundByNid(nid)

		self.channelNidMap[channelKey] = 0
	end
end

M.StopAll = function(self)
	for key, nid in pairs(self.channelNidMap) do
		if nid and nid == 0 then
			gSoundMgr:StopSoundByNid(nid)
		end

		self.channelNidMap[key] = 0
	end

	self.StopStrumSwitchSound(self)
end

M.PlaySoundId = function(self, channelKey, soundId)
	if self.isMuteActive then
		return 0
	end

	self:StopChannel(channelKey)

	local toneSwitch = self.toneType ~= M.ToneType.Overdrive and "Crunch" or "Clean"
	local soundData = gSoundMgr:CreateSoundData(soundId)

	if soundData and self.IsSendLinkSync(self) then
		soundData.isSyncSender = true
	end

	local nid = gSoundMgr:PlaySoundByData(soundData, nil, , , function (CS_Data)
		CS_Data:SetSwitchValue("SW_EGuitarStrum_Sound", toneSwitch)
		CS_Data:SetSwitchValue("SW_EGuitarStrum_Sound", toneSwitch)
		CS_Data:SetSwitchValue(LX6.Constants.SoundConstants.SoundRtpcName.SoundOwner, 1)
	end) or 0
	self.channelNidMap[channelKey] = nid

	return nid
end
