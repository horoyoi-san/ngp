-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CommonInfo\SoundRecordPanelStore.lua
-- Decompiled from: 01982_SoundRecordPanelStore.lua_e809fb7aa8f4.luajit

C_SoundRecordPanelStore = DefClass("C_SoundRecordPanelStore", C_SoundRecordPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.SoundRecordPanelStore = C_SoundRecordPanelStore
local M = C_SoundRecordPanelStore

dofile("LX6/SGUI/StoreDefine/CommonInfo/SoundRecordPanelStore_Subtitle")

M.OnAwake = function(self)
	self.bindData.exitButton.luaClick = self.CreateAction(self, self.ClosePanel)
	self.bindData.slider.luaPress = self.CreateAction(self, self.OnPressDownSlider)
	self.bindData.slider.luaRelease = self.CreateAction(self, self.OnReleaseSlider)
	self.bindData.slider.luaValueChanged = self.CreateActionWithArgs(self, self.OnSliderValueChanged)
	self.bindData.backgroundButton.luaClick = self.CreateActionWithArgs(self, self.CheckSwitchShowType, true)
	self.lastInputTime = Time.unscaledTime
	self.lastPointerPos = Vector2.New()
	self.gamePadDragSlider = self.bindData.gamePadDragSlider

	if self.gamePadDragSlider then
		self.gamePadDragSlider.onBeginDrag = self.CreateAction(self, self.OnPressDownSlider)
		self.gamePadDragSlider.onEndDrag = self.CreateAction(self, self.OnReleaseSlider)
	end
end

M.InitOnShow = function(self, data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	local musicCfg = LTConfig.InformationMusicConfig.GetConfig(cfg.MusicId)
	self.soundId = musicCfg.SoundId

	self.InitSubtitle(self, musicCfg)

	self.totalTime = 0
	self.bindData.totalTime = gClientUtils.FormatTimeToMMSS(0)

	self.UpdatePlayStateView(self, 0)
	self.Play(self, self.soundId)
end

M.IsPlaying = function(self)
	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt then
		return self.soundData.soundEvt.SoundState ~= 1
	end

	return false
end

M.OnUpdate = function(self)
	if not self.soundData then
		self.soundData = gSoundMgr:GetSoundData(self.uuId)
	end

	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt and self.IsPlaying(self) and self.NotGamepadDragging(self) then
		local currentTime = self.soundData.soundEvt:GetPlayPosition()

		self:UpdatePlayStateView(currentTime)
	end

	self.CheckSwitchShowType(self)
end

M.ClearOnClose = function(self)
	if self.soundData then
		gSoundMgr:StopSoundByData(self.soundData)

		self.soundData = nil
	end

	self.uuId = nil
	self.totalTime = nil
	self.lastInputTime = nil
	self.lastPointerPos = nil
	self.ignoreOnValueChangedOnce = nil
end

M.Play = function(self, soundId, seekToTime)
	local postEndCb = function(uuid)
		self.uuId = uuid
	end

	local startCb = function(uuid, soundData)
		if not soundData then
			print_warn("M:Play endCb soundData is nil, soundId=", soundId, " uuid=", uuid, "查看一下soundId是否配置正确")

			return
		end

		self.totalTime = soundData.soundEvt:GetLength()
		self.soundData = gSoundMgr:GetSoundData(uuid)
		self.bindData.totalTime = gClientUtils.FormatTimeToMMSS(self.totalTime)
		self.playing = true

		if seekToTime then
			soundData.soundEvt:SeekToTime(seekToTime)
		end
	end

	local endCb = function(uuid)
		if not self.soundData then
			return
		end

		if uuid ~= self.soundData.UUId then
			self.playing = false
		end
	end

	gSoundMgr:PlaySoundByTid(soundId, nil, postEndCb, startCb, endCb)
end

M.UpdatePlayStateView = function(self, currentTime)
	if self.delayUpdateViewCount and self.delayUpdateViewCount <= 0 then
		self.delayUpdateViewCount = self.delayUpdateViewCount - 1

		return
	end

	local totalTime = self.totalTime

	self.SetSliderValueNoCallback(self, currentTime / totalTime)

	self.bindData.currentTime = gClientUtils.FormatTimeToMMSS(currentTime)

	self.UpdateSubtitle(self, currentTime)
end

M.CheckSwitchShowType = function(self, inputTriggered)
	self.updateCount = (self.updateCount or 5) - 1

	if self.updateCount <= 0 and not inputTriggered then
		return
	end

	self.updateCount = 5
	local currentTime = Time.unscaledTime

	if not inputTriggered then
		local currentPointerPos = gCS.LuaUtils.GetPointerPosition()

		if (currentPointerPos - self.lastPointerPos).sqrMagnitude <= 1 then
			inputTriggered = true
			self.lastPointerPos = currentPointerPos
		end
	end

	if inputTriggered then
		self.lastInputTime = currentTime
	end

	local hide = currentTime >= self.lastInputTime + 3
	self.bindData.showTypeCtrl = hide and 1 or 0
end

M.SetSliderValueNoCallback = function(self, value)
	if UnityEngine.Mathf.IsNan(value) then
		return
	end

	self.ignoreOnValueChangedOnce = true
	self.bindData.slider.value = value
end

M.OnPressDownSlider = function(self)
	self.sliderPressed = true

	if self.NotGamepadDragging(self) then
		self.Pause(self)
	end
end

M.OnReleaseSlider = function(self)
	self.sliderPressed = false

	self.ResumeAndSeek(self)
end

M.OnSliderValueChanged = function(self, value)
	if self.ignoreOnValueChangedOnce then
		self.ignoreOnValueChangedOnce = false

		return
	end

	self.CheckSwitchShowType(self, true)
end

M.Pause = function(self)
	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt then
		self.soundData.soundEvt:Pause()
	end
end

M.ResumeAndSeek = function(self)
	local currentTime = self.bindData.slider.value * self.totalTime

	if self.soundData and self.soundData:IsValid() then
		self.soundData.soundEvt:SeekToTime(currentTime)
		self.soundData.soundEvt:Resume()

		self.delayUpdateViewCount = 1
	else
		self.Play(self, self.soundId, currentTime)
	end
end

M.NotGamepadDragging = function(self)
	return not self.gamePadDragSlider or not self.gamePadDragSlider.IsDragging
end
