-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCSoundFirstStore.lua
-- Decompiled from: 00957_OCSoundFirstStore.lua_ff64b8e92cfb.luajit

local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
local MessageConfig = LTConfig.MessageConfig
C_OCSoundFirstStore = DefClass("C_OCSoundFirstStore", C_OCSoundFirstStore, C_StoreGroup)
GroupName2Class.OCSoundFirstStore = C_OCSoundFirstStore
local M = C_OCSoundFirstStore

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
	self.curMixVoice = nil
	self.prevMixCount = 0
	self.customTestText = nil
	self.accentTipBtn = nil
	self.selectedAccent = nil
	self.hasUserEverHadVoices = false
end

M.DefineAllEnumsAutoGen = function(self)
	self.haveVoiceCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.haveVoiceCtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
	self.curMixVoice = nil

	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.curMixVoice = nil
	self.bindData.testSoundInput.text = self.customTestText or self.mgr:GetTestTextForPlayerTone()

	if not self.hasUserEverHadVoices then
		self.TryAutoLoadRecommendVoice(self)
	end

	self.prevMixCount = #self.mgr.mixVoiceList

	if self.prevMixCount <= 0 then
		self.hasUserEverHadVoices = true
	end

	self.RefreshMixVoiceList(self)
	self.RefreshTuneSliders(self)

	if not self.selectedAccent and #OriginalCharacterConfig.AccentList <= 0 then
		self.selectedAccent = OriginalCharacterConfig.AccentList[1]
		self.bindData.accentText = self.selectedAccent.name or ""
	end
end

M.OnClose = function(self)
	self.curMixVoice = nil

	if self._timer then
		self._timer:Stop()

		self._timer = nil
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_OC_VOICE_MIX_CHANGE] = self.CreateAction(self, "OnMixChange"),
		[gEventConstants.ON_OC_VOICE_PLAY_VOICE] = self.CreateAction(self, "OnPlayVoice"),
		[gEventConstants.ON_OC_VOICE_WAITING] = self.CreateAction(self, "OnVoiceWaiting"),
		[gEventConstants.ON_OC_VOICE_LIBRARY_CHANGE] = self.CreateAction(self, "OnVoiceLibraryChange")
	}
end

M.RegisterWidget = function(self)
	self.bindData.addMixBtn.luaClick = self.CreateAction(self, "OnClickAddMixBtn")
	self.bindData.addTuneBtn.luaRenderTooltip = self.CreateAction(self, "OnRenderAccentTooltip")
	self.bindData.confirmBtn.luaClick = self.CreateAction(self, "OnClickConfirmBtn")
	self.bindData.shareBtn.luaClick = self.CreateAction(self, "OnClickShareBtn")
	self.bindData.saveBtn.luaClick = self.CreateAction(self, "OnClickSaveBtn")
	self.bindData.testSoundBtn.luaClick = self.CreateAction(self, "OnClickTestSoundBtn")
	self.bindData.speedSlider.luaValueChanged = self.CreateAction(self, "OnSpeedSliderValueChanged")
	self.bindData.temperSlider.luaValueChanged = self.CreateAction(self, "OnTemperSliderValueChanged")
	self.bindData.powerSlider.luaValueChanged = self.CreateAction(self, "OnPowerSliderValueChanged")
	self.bindData.magnetSlider.luaValueChanged = self.CreateAction(self, "OnMagnetSliderValueChanged")
	self.bindData.testSoundInput.luaValueChanged = self.CreateAction(self, "OnTestSoundInputValueChanged")
	self.bindData.mixSoundList.luaSimpleRenderItem = self.CreateAction(self, "OnRenderMixSoundItem")
end

M.OnClickAddMixBtn = function(self)
	if self.parentStore then
		self.parentStore:OpenLibrary()
	end
end

M.OnRenderAccentTooltip = function(self, btn, widget)
	self.accentTipBtn = btn
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	store.list.luaSimpleRenderItem = self:CreateAction("OnRenderAccentListItem")

	store.list:SetSimpleList(#OriginalCharacterConfig.AccentList)
end

M.OnRenderAccentListItem = function(self, btn, index)
	local data = OriginalCharacterConfig.AccentList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = data.name
	btn.luaClick = self.CreateActionWithArgs(self, "OnClickAccentListItem", data)
end

M.OnClickAccentListItem = function(self, data)
	if self.accentTipBtn then
		self.accentTipBtn:CloseTooltip()

		self.accentTipBtn = nil
	end

	self.selectedAccent = data
	self.bindData.accentText = data and data.name or ""
end

M.OnClickShareBtn = function(self)
end

M.IsMineVoiceNameExist = function(self, name)
	if string.is_null_or_empty(name) then
		return false
	end

	slot2 = ipairs
	slot4 = self.mgr.mineVoiceList or {}

	for _, voice in slot2(slot4) do
		if voice.name ~= name then
			return true
		end
	end

	return false
end

M.TrySaveVoiceToMine = function(self, voiceInfo)
	if not voiceInfo then
		return
	end

	slot2 = gDisplayMessageMgr

	slot2:ShowInputBox(MessageConfig.OCChangeVoiceName, nil, function (inputText)
		if string.is_null_or_empty(inputText) then
			return
		end

		local limit = OriginalCharacterConfig.MyVoiceStoreLimit or 10

		if limit < #(self.mgr.mineVoiceList or {}) then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OCVoiceStoreLimit, nil, , limit)

			return
		end

		if self:IsMineVoiceNameExist(inputText) then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OCSpeechNameConflict)

			return
		end

		voiceInfo.name = inputText
		self.curMixVoice = voiceInfo

		self.mgr:AddToMineTone(voiceInfo)

		if self.parentStore and self.parentStore.OpenLibraryAndSwitchToMine then
			self.parentStore:OpenLibraryAndSwitchToMine()
		end
	end, nil, voiceInfo.name)
end

M.OnClickSaveBtn = function(self)
	local limit = OriginalCharacterConfig.MyVoiceStoreLimit or 10

	if limit < #self.mgr.mineVoiceList then
		gDisplayMessageMgr:ShowMessage(MessageConfig.OCVoiceStoreLimit, nil, , limit)

		return
	end

	local doSave = function(voiceInfo)
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)

		if not voiceInfo then
			return
		end

		self.curMixVoice = voiceInfo

		self:TrySaveVoiceToMine(voiceInfo)
	end

	if self.curMixVoice then
		doSave(self.curMixVoice)
	elseif #self.mgr.mixVoiceList <= 0 then
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, true)
		self.mgr:MixVoice(doSave)
	end
end

M.OnClickConfirmBtn = function(self)
	local limit = OriginalCharacterConfig.MyVoiceStoreLimit or 10

	if limit < #self.mgr.mineVoiceList then
		gDisplayMessageMgr:ShowMessage(MessageConfig.OCVoiceStoreLimit, nil, , limit)

		return
	end

	local doConfirm = function(voiceInfo)
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)

		if not voiceInfo then
			return
		end

		self.curMixVoice = voiceInfo

		self.mgr:AddToMineTone(voiceInfo)

		self.mgr.confirmVoice = voiceInfo
		self._timer = Timer.New(function ()
			self._timer = nil

			if self.parentStore and self.parentStore.parentStore then
				self.parentStore.parentStore:GoToNext()
			end
		end, 1):Start()
	end

	if self.curMixVoice then
		doConfirm(self.curMixVoice)
	else
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, true)
		self.mgr:MixVoice(doConfirm)
	end
end

M.OnClickTestSoundBtn = function(self)
	self.bindData.testSoundBtn.interactable = false

	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)
	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, true)

	local testText = self.mgr:GetTestTextForPlayerTone()

	if self.bindData.testSoundInput.text == "" then
		testText = self.bindData.testSoundInput.text
	end

	slot2 = self.mgr

	slot2:MixVoice(function (voiceInfo)
		if not voiceInfo then
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)

			self.bindData.testSoundBtn.interactable = true

			return
		end

		self.curMixVoice = voiceInfo

		local withByteCallback = function(byteData)
			slot1 = gMessageManager

			slot1:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)

			slot1 = LX6.Audio.AIOCVoiceManager.Instance
			slot5 = self.mgr

			slot1:PlayAIVoiceSound(voiceInfo.name .. slot5:TestVoiceName(), byteData, function ()
				gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)

				self.bindData.testSoundBtn.interactable = true
			end)
		end

		local onDownloaded = function(speechUrl)
			if speechUrl then
				gAliOssManager:DownloadFileFromUrl(speechUrl, withByteCallback)
			else
				gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
				gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)

				self.bindData.testSoundBtn.interactable = true
			end
		end

		slot3 = self.mgr
		slot8 = self.mgr
		slot9 = self.mgr
		slot10 = self.mgr
		slot11 = self.mgr
		slot12 = self

		slot3:TextToSpeechForLua(testText, voiceInfo.speechId, slot8:GetMixTunePart(1), slot9:GetMixTunePart(2), slot10:GetMixTunePart(3), slot11:GetMixTunePart(4), slot12:GetSelectedAccentTemplate(), function (data)
			if data then
				onDownloaded(data.SpeechUrl)
			else
				gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)
				gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)

				self.bindData.testSoundBtn.interactable = true
			end
		end)
	end)
end

M.RefreshTuneSliders = function(self)
	self.isRefreshingSliders = true
	local tempoSetting = OriginalCharacterConfig.TuneTempoSetting
	self.bindData.speedSlider.minValue = not table.isNilOrEmpty(tempoSetting) and tempoSetting.minValue or 0.7
	self.bindData.speedSlider.maxValue = not table.isNilOrEmpty(tempoSetting) and tempoSetting.maxValue or 1.5
	self.bindData.speedSlider.stepSize = not table.isNilOrEmpty(tempoSetting) and tempoSetting.stepValue or 0.1
	self.bindData.speedSlider.value = self.mgr:GetMixTunePart(1)
	self.bindData.temperSlider.minValue = -2
	self.bindData.temperSlider.maxValue = 2
	self.bindData.temperSlider.stepSize = 0.1
	self.bindData.temperSlider.formatText = "{0:0.0}"
	self.bindData.temperSlider.value = self.mgr:GetMixTunePart(2)
	self.bindData.powerSlider.minValue = -2
	self.bindData.powerSlider.maxValue = 2
	self.bindData.powerSlider.stepSize = 0.1
	self.bindData.powerSlider.formatText = "{0:0.0}"
	self.bindData.powerSlider.value = self.mgr:GetMixTunePart(3)
	self.bindData.magnetSlider.minValue = -2
	self.bindData.magnetSlider.maxValue = 2
	self.bindData.magnetSlider.stepSize = 0.1
	self.bindData.magnetSlider.formatText = "{0:0.0}"
	self.bindData.magnetSlider.value = self.mgr:GetMixTunePart(4)
	self.isRefreshingSliders = false
end

M.OnSpeedSliderValueChanged = function(self, value)
	if self.isRefreshingSliders then
		return
	end

	self.mgr:SetMixTunePart(1, value)

	self.curMixVoice = nil
end

M.OnTemperSliderValueChanged = function(self, value)
	if self.isRefreshingSliders then
		return
	end

	self.mgr:SetMixTunePart(2, value)

	self.curMixVoice = nil
end

M.OnPowerSliderValueChanged = function(self, value)
	if self.isRefreshingSliders then
		return
	end

	self.mgr:SetMixTunePart(3, value)

	self.curMixVoice = nil
end

M.OnMagnetSliderValueChanged = function(self, value)
	if self.isRefreshingSliders then
		return
	end

	self.mgr:SetMixTunePart(4, value)

	self.curMixVoice = nil
end

M.OnTestSoundInputValueChanged = function(self, text)
	self.customTestText = not string.is_null_or_empty(text) and text or nil
end

M.RefreshMixVoiceList = function(self)
	self.bindData:Commit("haveVoiceCtrl", #self.mgr.mixVoiceList <= 0 and 0 or 1, COMMIT_IMMEDIATELY)

	self.bindData.confirmBtn.interactable = #self.mgr.mixVoiceList >= 0

	self.bindData.mixSoundList:SetSimpleList(#self.mgr.mixVoiceList)

	self.bindData.mixVoiceCountText = #self.mgr.mixVoiceList .. "/" .. self:GetMixVoiceMaxCount()
end

M.OnRenderMixSoundItem = function(self, btn, index)
	local data = self.mgr.mixVoiceList[index + 1]

	if not data then
		return
	end

	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	store.text = data.name
	local stepInfos = OriginalCharacterConfig.TuneVoiceSetValue
	store.sliderComp.formatText = "{0}%"
	store.sliderComp.stepSize = not table.isNilOrEmpty(stepInfos) and stepInfos.stepValue or 1
	store.sliderComp.maxValue = not table.isNilOrEmpty(stepInfos) and stepInfos.maxValue or 100
	store.sliderComp.minValue = not table.isNilOrEmpty(stepInfos) and stepInfos.minValue or 0
	store.slider.value = (data.part or 0.5) * 100
	store.slider.luaValueChanged = self:CreateActionWithArgs("OnVoiceSliderValueChanged", index + 1)
	store.closeBtn.luaClick = self:CreateActionWithArgs("OnClickCloseMixVoiceBtn", index + 1)
	store.playBtn.luaClick = self:CreateActionWithArgs("OnClickPlayVoiceBtn", index + 1)
end

M.OnVoiceSliderValueChanged = function(self, index, value)
	self.mgr:SetMixVoicePart(index, value / 100)

	self.curMixVoice = nil
end

M.OnClickCloseMixVoiceBtn = function(self, index)
	self.mgr:RemoveMixVoice(index)

	self.curMixVoice = nil

	self:RefreshMixVoiceList()
	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_MIX_CHANGE)
end

M.OnClickPlayVoiceBtn = function(self, index)
	local data = self.mgr.mixVoiceList[index]

	if not data then
		return
	end

	slot3 = gMessageManager

	slot3:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)

	slot3 = gMessageManager

	slot3:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, true)

	slot3 = self.mgr
	local testText = slot3:GetAuditionText(data.speechId, data.tags)

	local withByteCallback = function(byteData)
		slot1 = gMessageManager

		slot1:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)

		slot1 = LX6.Audio.AIOCVoiceManager.Instance
		slot5 = self.mgr

		slot1:PlayAIVoiceSound(data.name .. slot5:TestVoiceName(), byteData, function ()
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)
		end)
	end

	local onDownloaded = function(speechUrl)
		if speechUrl then
			gAliOssManager:DownloadFileFromUrl(speechUrl, withByteCallback)
		else
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)
		end
	end

	slot6 = self.mgr
	slot11 = self.mgr
	slot12 = self.mgr
	slot13 = self.mgr
	slot14 = self.mgr

	slot6:TextToSpeechForLua(testText, data.speechId, slot11:GetMixTunePart(1), slot12:GetMixTunePart(2), slot13:GetMixTunePart(3), slot14:GetMixTunePart(4), self:GetSelectedAccentTemplate(), function (ttsData)
		if ttsData then
			onDownloaded(ttsData.SpeechUrl)
		else
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, false)
		end
	end)
end

M.OnMixChange = function(self, eventId)
	self.curMixVoice = nil
	local count = #self.mgr.mixVoiceList

	if count ~= 1 then
		self.bindData:Commit("haveVoiceCtrl", self.haveVoiceCtrlEnum._true, COMMIT_IMMEDIATELY)
	end

	if self.prevMixCount >= count then
		self.TryApplyVoiceTune(self)
	end

	self.prevMixCount = count

	if count <= 0 then
		self.hasUserEverHadVoices = true
	end

	self.bindData.confirmBtn.interactable = count >= 0

	self.bindData.mixSoundList:SetSimpleList(count)

	self.bindData.mixVoiceCountText = count .. "/" .. self:GetMixVoiceMaxCount()
end

M.TryApplyVoiceTune = function(self)
	self.RefreshTuneSliders(self)
end

M.TryAutoLoadRecommendVoice = function(self)
	if #self.mgr.mixVoiceList <= 0 then
		return
	end

	for _, v in ipairs(self.mgr.officialVoiceList) do
		if v.index ~= -1 then
			self.mgr:AddToMixVoice(v)

			return
		end
	end
end

M.OnVoiceLibraryChange = function(self, eventId, tabIndex)
	if tabIndex == self.mgr.toneTab.official then
		return
	end

	if #self.mgr.mixVoiceList <= 0 then
		return
	end

	self.TryAutoLoadRecommendVoice(self)

	self.prevMixCount = #self.mgr.mixVoiceList

	if self.prevMixCount <= 0 then
		self.hasUserEverHadVoices = true
	end

	self.RefreshMixVoiceList(self)
	self.RefreshTuneSliders(self)
end

M.OnPlayVoice = function(self, eventId, isPlaying)
	self.bindData.testSoundBtn.interactable = not isPlaying
end

M.OnVoiceWaiting = function(self, eventId, isWaiting)
	self.bindData.testSoundBtn.interactable = not isWaiting
	self.bindData.saveBtn.interactable = not isWaiting
	self.bindData.confirmBtn.interactable = not isWaiting and #self.mgr.mixVoiceList >= 0
end

M.GetMixVoiceMaxCount = function(self)
	local maxCount = OriginalCharacterConfig.MixVoiceMaxCount

	if not maxCount or maxCount < 0 then
		return 4
	end

	return maxCount
end

M.GetSelectedAccentTemplate = function(self)
	if not self.selectedAccent then
		return nil
	end

	local t = self.selectedAccent.template

	if string.is_null_or_empty(t) or t ~= "null" then
		return nil
	end

	return t
end
