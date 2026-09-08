-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCSoundCopyStore.lua
-- Decompiled from: 00956_OCSoundCopyStore.lua_981d36696022.luajit

local OriginalCharacterConfig = LTConfig.OriginalCharacterConfig
local CCVoiceManager = LX6.Audio.CCMini.CCVoiceManager.Instance
local MessageConfig = LTConfig.MessageConfig
C_OCSoundCopyStore = DefClass("C_OCSoundCopyStore", C_OCSoundCopyStore, C_StoreGroup)
GroupName2Class.OCSoundCopyStore = C_OCSoundCopyStore
local M = C_OCSoundCopyStore

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
	self.cloneVoice = nil
	self.isRecording = false
	self.isWaiting = false
	self.recordText = nil
	self.stopRecordTimer = nil
	self.waitingTimeoutTimer = nil
end

M.DefineAllEnumsAutoGen = function(self)
	self.recordBtnCtrlEnum = {
		i6rK = 1,
		["^\\xba\\xa3\\xbd\\xa2"] = 0
	}
	self.finshCtrlEnum = {
		["\\xac\\xb4\\xaex?\\xea6"] = 2,
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
	self.successCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 1,
		["r\\xba\\xb0\\xba\\xb3"] = 0
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.recordBtnCtrlEnum = nil
	self.finshCtrlEnum = nil
	self.successCtrlEnum = nil
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
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.cloneVoice = nil
	self.isRecording = false
	self.isWaiting = false
	self.recordText = OriginalCharacterConfig.VoiceCloneText
	self.bindData.recordInput.text = self.recordText
	self.bindData.finshCtrl = self.finshCtrlEnum._false
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.start

	CCVoiceManager:ActivateRecordSelf()
end

M.OnClose = function(self)
	CCVoiceManager:DeactivateRecordSelf()

	if self.stopRecordTimer then
		self.stopRecordTimer:Stop()

		self.stopRecordTimer = nil
	end

	if self.waitingTimeoutTimer then
		self.waitingTimeoutTimer:Stop()

		self.waitingTimeoutTimer = nil
	end

	if self.isWaiting then
		self.isWaiting = false

		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
	end
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_OC_VOICE_PLAY_VOICE] = self.CreateAction(self, "OnVoicePlaying"),
		[gEventConstants.ON_OC_VOICE_WAITING] = self.CreateAction(self, "OnVoiceWaiting")
	}
end

M.RegisterWidget = function(self)
	self.bindData.addLibraryBtn.luaClick = self.CreateAction(self, "OnClickAddLibraryBtn")
	self.bindData.addMixBtn.luaClick = self.CreateAction(self, "OnClickAddMixBtn")
	self.bindData.testVoiceBtn.luaClick = self.CreateAction(self, "OnClickTestVoiceBtn")
	self.bindData.deleteVoiceBtn.luaClick = self.CreateAction(self, "OnClickDeleteVoiceBtn")
	self.bindData.reGenVoiceBtn.luaClick = self.CreateAction(self, "OnClickReGenVoiceBtn")
	self.bindData.startRecordBtn.luaClick = self.CreateAction(self, "OnClickStartRecordBtn")
	self.bindData.stopRecordBtn.luaClick = self.CreateAction(self, "OnClickStopRecordBtn")
	self.bindData.genCloseBtn.luaClick = self.CreateAction(self, "OnClickGenCloseBtn")
	self.bindData.closeBtn.luaClick = self.CreateAction(self, "OnClickCloseBtn")
	self.bindData.recordInput.luaValueChanged = self.CreateAction(self, "OnRecordInputValueChanged")
end

M.OnClickStartRecordBtn = function(self)
	self.isRecording = true
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.stop
	local recordFilePath = "tempOCVoice.wav"
	local filePath = gCS.LuaUtils.GetFullPath(recordFilePath)

	CCVoiceManager:StartRecordSelf(filePath)

	self.stopRecordTimer = Timer.New(function ()
		self:StopRecordingProcess()
	end, 10):Start()

	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_RECORD, true)
end

M.OnClickStopRecordBtn = function(self)
	self.StopRecordingProcess(self)
end

M.StopRecordingProcess = function(self)
	if self.stopRecordTimer then
		self.stopRecordTimer:Stop()

		self.stopRecordTimer = nil
	end

	self.isRecording = false
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.start
	self.bindData.startRecordBtn.interactable = false
	self.bindData.finshCtrl = self.finshCtrlEnum.generate
	self.isWaiting = true
	slot1 = gMessageManager

	slot1:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, true)

	slot1 = Timer.New(function ()
		self.waitingTimeoutTimer = nil

		if self.isWaiting then
			print_error("OCSoundCopyStore: waiting timeout, force re-enable")
			self:FinishWaiting(false)
		end
	end, 30)
	self.waitingTimeoutTimer = slot1:Start()
	slot1 = CCVoiceManager

	slot1:StopRecordSelf(function ()
		if not self.isWaiting then
			return
		end

		local recordFilePath = "tempOCVoice.wav"
		local wavBytes = gCS.LuaUtils.ReadBytes(recordFilePath)

		if wavBytes then
			local objectName = string.format("%s_%s_%s.wav", gClientConst.OssSourceType.OcVoice, os.time(), math.random(1000, 9999))
			slot3 = gAliOssManager

			slot3:UploadFile(objectName, wavBytes, nil, true, function (isSuccess, objectKey)
				if not self.isWaiting then
					return
				end

				if isSuccess then
					local serverUrl = LX6.Utils.AliOssManager.Instance:GetDownloadUrl(objectKey)
					local cloneText = self.recordText or self.mgr:GetTestTextForPlayerTone()

					self.mgr.api.CreateClonedSpeechForLua(serverUrl, cloneText, function (data)
						if not self.isWaiting then
							return
						end

						if data then
							self.cloneVoice = {
								speechId = data.SpeechId,
								name = self.mgr:CopyVoiceName()
							}
							self.bindData.myVoiceName = self.cloneVoice.name
							self.bindData.myVoiceTime = ""

							self:FinishWaiting(true)
						else
							self:FinishWaiting(false)
						end
					end)
				else
					print_error("OCSoundCopyStore: upload failed")
					self:FinishWaiting(false)
				end
			end)
		else
			print_error("OCSoundCopyStore: read wav file failed")
			self:FinishWaiting(false)
		end
	end)
end

M.FinishWaiting = function(self, success)
	if self.waitingTimeoutTimer then
		self.waitingTimeoutTimer:Stop()

		self.waitingTimeoutTimer = nil
	end

	self.isWaiting = false
	self.bindData.startRecordBtn.interactable = true
	self.bindData.finshCtrl = self.finshCtrlEnum._true
	self.bindData.successCtrl = success and self.successCtrlEnum._true or self.successCtrlEnum._false

	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
end

M.OnClickTestVoiceBtn = function(self)
	if self.cloneVoice then
		self.mgr:PlayAIVoice(self.cloneVoice.speechId, self.cloneVoice.name)
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)
	end
end

M.OnClickDeleteVoiceBtn = function(self)
	self.cloneVoice = nil
	self.bindData.finshCtrl = self.finshCtrlEnum._false
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.start
end

M.OnClickReGenVoiceBtn = function(self)
	self.cloneVoice = nil
	self.bindData.finshCtrl = self.finshCtrlEnum._false
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.start
end

M.OnClickAddLibraryBtn = function(self)
	if self.cloneVoice then
		self.mgr:AddToMineTone(self.cloneVoice)

		if self.parentStore then
			self.parentStore:OpenLibraryAndSwitchToMine()
		end
	end
end

M.OnClickAddMixBtn = function(self)
	if self.cloneVoice then
		if #self.mgr.mixVoiceList > 4 then
			gDisplayMessageMgr:ShowMessage(MessageConfig.OCMixReachLimit)

			return
		end

		self.mgr:AddToMixVoice(self.cloneVoice)
		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_MIX_CHANGE)
	end
end

M.OnClickGenCloseBtn = function(self)
	if not self.isWaiting then
		return
	end

	self.isWaiting = false
	self.bindData.finshCtrl = self.finshCtrlEnum._false
	self.bindData.recordBtnCtrl = self.recordBtnCtrlEnum.start

	gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_WAITING, false)
end

M.OnClickCloseBtn = function(self)
	if self.parentStore then
		self.parentStore:SwitchToFirst()
	end
end

M.OnRecordInputValueChanged = function(self, text)
	self.recordText = not string.is_null_or_empty(text) and text or nil
end

M.OnVoicePlaying = function(self, eventId, isPlaying)
	local canAct = not isPlaying
	self.bindData.testVoiceBtn.interactable = canAct
	self.bindData.addLibraryBtn.interactable = canAct
	self.bindData.addMixBtn.interactable = canAct
	self.bindData.deleteVoiceBtn.interactable = canAct
	self.bindData.reGenVoiceBtn.interactable = canAct

	if not self.isRecording then
		self.bindData.startRecordBtn.interactable = canAct
	end
end

M.OnVoiceWaiting = function(self, eventId, isWaiting)
	local canAct = not isWaiting
	self.bindData.testVoiceBtn.interactable = canAct
	self.bindData.addLibraryBtn.interactable = canAct
	self.bindData.addMixBtn.interactable = canAct
	self.bindData.deleteVoiceBtn.interactable = canAct
	self.bindData.reGenVoiceBtn.interactable = canAct

	if not self.isRecording then
		self.bindData.startRecordBtn.interactable = canAct
	end
end
