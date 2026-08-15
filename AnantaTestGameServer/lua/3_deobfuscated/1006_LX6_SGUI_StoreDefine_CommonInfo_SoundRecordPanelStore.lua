C_SoundRecordPanelStore = DefClass("C_SoundRecordPanelStore", C_SoundRecordPanelStore, C_CommonInfoPanelsBaseStore)
GroupName2Class.SoundRecordPanelStore = C_SoundRecordPanelStore
local M = C_SoundRecordPanelStore

dofile("LX6/SGUI/StoreDefine/CommonInfo/SoundRecordPanelStore_Subtitle")

function M:OnAwake()
	self.bindData.exitButton.luaClick = self:CreateAction(self.ClosePanel)
	self.bindData.slider.luaPress = self:CreateAction(self.OnPressDownSlider)
	self.bindData.slider.luaRelease = self:CreateAction(self.OnReleaseSlider)
	self.bindData.slider.luaValueChanged = self:CreateActionWithArgs(self.OnSliderValueChanged)
	self.bindData.backgroundButton.luaClick = self:CreateActionWithArgs(self.CheckSwitchShowType, true)
	self.lastInputTime = Time.unscaledTime
	self.lastPointerPos = Vector2.New()
	self.gamePadDragSlider = self.bindData.gamePadDragSlider

	if self.gamePadDragSlider then
		self.gamePadDragSlider.onBeginDrag = self:CreateAction(self.OnPressDownSlider)
		self.gamePadDragSlider.onEndDrag = self:CreateAction(self.OnReleaseSlider)
	end
end

function M:InitOnShow(data, panelTypeCfg)
	local cfg = LTConfig.InformationConfig.GetConfig(data[1].id)
	local musicCfg = LTConfig.InformationMusicConfig.GetConfig(cfg.MusicId)
	self.soundId = musicCfg.SoundId

	self:InitSubtitle(musicCfg)

	self.totalTime = 0
	self.bindData.totalTime = gClientUtils.FormatTimeToMMSS(0)

	self:UpdatePlayStateView(0)
	self:Play(self.soundId)
end

function M:IsPlaying()
	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt then
		return self.soundData.soundEvt.SoundState == 1
	end

	return false
end

function M:OnUpdate()
	if not self.soundData then
		self.soundData = gSoundMgr:GetSoundData(self.uuId)
	end

	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt and self:IsPlaying() and self:NotGamepadDragging() then
		local currentTime = self.soundData.soundEvt:GetPlayPosition()

		self:UpdatePlayStateView(currentTime)
	end

	self:CheckSwitchShowType()
end

function M:ClearOnClose()
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

function M:Play(soundId, seekToTime)
	local function postEndCb(uuid)
		self.uuId = uuid
	end

	local function startCb(uuid, soundData)
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

	local function endCb(uuid)
		if not self.soundData then
			return
		end

		if uuid == self.soundData.UUId then
			self.playing = false
		end
	end

	gSoundMgr:PlaySoundByTid(soundId, nil, postEndCb, startCb, endCb)
end

function M:UpdatePlayStateView(currentTime)
	if self.delayUpdateViewCount and self.delayUpdateViewCount > 0 then
		self.delayUpdateViewCount = self.delayUpdateViewCount - 1

		return
	end

	local totalTime = self.totalTime

	self:SetSliderValueNoCallback(currentTime / totalTime)

	self.bindData.currentTime = gClientUtils.FormatTimeToMMSS(currentTime)

	self:UpdateSubtitle(currentTime)
end

function M:CheckSwitchShowType(inputTriggered)
	self.updateCount = (self.updateCount or 5) - 1

	if self.updateCount > 0 and not inputTriggered then
		return
	end

	self.updateCount = 5
	local currentTime = Time.unscaledTime

	if not inputTriggered then
		local currentPointerPos = gCS.LuaUtils.GetPointerPosition()

		if (currentPointerPos - self.lastPointerPos).sqrMagnitude > 1 then
			inputTriggered = true
			self.lastPointerPos = currentPointerPos
		end
	end

	if inputTriggered then
		self.lastInputTime = currentTime
	end

	local hide = currentTime > self.lastInputTime + 3
	self.bindData.showTypeCtrl = hide and 1 or 0
end

function M:SetSliderValueNoCallback(value)
	if UnityEngine.Mathf.IsNan(value) then
		return
	end

	self.ignoreOnValueChangedOnce = true
	self.bindData.slider.value = value
end

function M:OnPressDownSlider()
	self.sliderPressed = true

	if self:NotGamepadDragging() then
		self:Pause()
	end
end

function M:OnReleaseSlider()
	self.sliderPressed = false

	self:ResumeAndSeek()
end

function M:OnSliderValueChanged(value)
	if self.ignoreOnValueChangedOnce then
		self.ignoreOnValueChangedOnce = false

		return
	end

	self:CheckSwitchShowType(true)
end

function M:Pause()
	if self.soundData and self.soundData:IsValid() and self.soundData.soundEvt then
		self.soundData.soundEvt:Pause()
	end
end

function M:ResumeAndSeek()
	local currentTime = self.bindData.slider.value * self.totalTime

	if self.soundData and self.soundData:IsValid() then
		self.soundData.soundEvt:SeekToTime(currentTime)
		self.soundData.soundEvt:Resume()

		self.delayUpdateViewCount = 1
	else
		self:Play(self.soundId, currentTime)
	end
end

function M:NotGamepadDragging()
	return not self.gamePadDragSlider or not self.gamePadDragSlider.IsDragging
end
