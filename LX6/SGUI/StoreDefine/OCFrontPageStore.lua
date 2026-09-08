-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCFrontPageStore.lua
-- Decompiled from: 00946_OCFrontPageStore.lua_0f004e2acca6.luajit

local OCTemplateConfig = LTConfig.OriginalCharacterTemplateConfig
local OCConfig = LTConfig.OriginalCharacterConfig
local TemplateIPConfig = LTConfig.OriginalCharacterTemplateIPConfig
local OCPersonalityTemplateConfig = LTConfig.OriginalCharacterPersonalityTemplateConfig
local BOOL2CTL = {
	[true] = 1,
	[false] = 0
}
C_OCFrontPageStore = DefClass("C_OCFrontPageStore", C_OCFrontPageStore, C_StoreGroup)
GroupName2Class.OCFrontPageStore = C_OCFrontPageStore
local M = C_OCFrontPageStore

local RefreshSimpleSelector = function(selector, optionList, selectedIndex)
	selector.SetSimpleOptions(selector, #optionList)

	for i = 1, #optionList do
		selector.SetItemLabel(selector, i - 1, optionList[i].label)
	end

	selector.SelectOption(selector, selectedIndex, false)
end

M.ctor = function(self)
	self.mgr = gOCMgr
	self.parentStore = nil
end

M.DefineAllVariables = function(self)
	self.currentStep = 1
	self.currentTemplateId = nil
	self.CtrlZSteps = {}
	self.currentPointIndex = 0
	self.showChatEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isPresetModified = false
	self.isRefreshing = false
	self.isFirstShow = true
end

M.DefineAllEnumsAutoGen = function(self)
	self.showStepCtlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.progressCtrlEnum = {
		["r+y^"] = 0,
		["i*rL"] = 1
	}
	self.showEditNameCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.inputNameCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.showMBTICtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.stageCtrlEnum = {
		["["] = 1,
		["X"] = 0
	}
	self.haveNameCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.soundPlayCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.isAICtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.showStepCtlEnum = nil
	self.progressCtrlEnum = nil
	self.showEditNameCtrlEnum = nil
	self.inputNameCtrlEnum = nil
	self.showMBTICtrlEnum = nil
	self.stageCtrlEnum = nil
	self.haveNameCtrlEnum = nil
	self.soundPlayCtrlEnum = nil
	self.isAICtrlEnum = nil
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
	self.RegisterPersonalityTagTooltip(self)
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_OC_MBTI_CHANGE] = self.CreateAction(self, "OnMBTIChange"),
		[gEventConstants.ON_OC_VOICE_PLAY_VOICE] = self.CreateAction(self, "OnVoicePlayChange")
	}
end

M.OnShow = function(self, panelId, data)
	self.currentStep = 1

	if self.isFirstShow then
		self.isFirstShow = false
		self.isFirstTemplateRefresh = true

		self.OnRefreshTemplate(self)
	else
		self.RefreshTemplateListForStep(self)
	end

	self:RefreshGenderList()
	self:RefreshAgeList()
	self:RefreshMBTIDisplay()
	self.mgr:OnChangeTemplate(self.currentTemplateId)

	self.CtrlZSteps = {}
	self.currentPointIndex = 0
	self.bindData.stageCtrl = self.currentStep ~= 1 and 0 or 1
	self.bindData.soundPlayCtrl = 0
	self.bindData.haveNameCtrl = BOOL2CTL[not string.is_null_or_empty(self.mgr.baseData.name)]
	self.bindData.inputNameCtrl = BOOL2CTL[false]

	self:OnDataRefresh()
	self:PushSnapshot()
end

M.RefreshGenderList = function(self)
	self.genderList = self.mgr:GetSexList()
	local selectedIndex = 0

	for i, item in ipairs(self.genderList) do
		if item.id ~= self.mgr.baseData.sex then
			selectedIndex = i - 1

			break
		end
	end

	RefreshSimpleSelector(self.bindData.genderSelector, self.genderList, selectedIndex)
end

M.RefreshAgeList = function(self)
	self.ageList = self.mgr:GetAgeList()
	local selectedIndex = 0

	for i, item in ipairs(self.ageList) do
		if item.id ~= self.mgr.baseData.age then
			selectedIndex = i - 1

			break
		end
	end

	RefreshSimpleSelector(self.bindData.ageSelector, self.ageList, selectedIndex)
end

M.OnClose = function(self)
	if self.testSoundTimer then
		self.testSoundTimer:Stop()

		if self.bindData.randomSoundBtn then
			self.bindData.randomSoundBtn.interactable = true
		end

		if self.bindData.soundBtn then
			self.bindData.soundBtn.interactable = true
		end

		self.testSoundTimer = nil
	end
end

M.RegisterWidget = function(self)
	self.bindData.changeBtn.luaClick = self.CreateAction(self, self.OnRefreshTemplate)
	self.bindData.goBtn.luaClick = self.CreateAction(self, self.OnClickGoBtn)
	self.bindData.nextBtn.luaClick = self.CreateAction(self, self.OnClickNextBtn)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, self.OnClickRefreshBtn)
	self.bindData.undoBtn.luaClick = self.CreateAction(self, self.OnClickUndoBtn)
	self.bindData.redoBtn.luaClick = self.CreateAction(self, self.OnClickRedoBtn)
	self.bindData.soundBtn.luaClick = self.CreateAction(self, self.OnClickSoundBtn)
	self.bindData.randomSoundBtn.luaClick = self.CreateAction(self, self.OnClickRandomSoundBtn)
	self.bindData.quitSoundBtn.luaClick = self.CreateAction(self, self.OnClickQuitSoundBtn)
	self.bindData.mbtiBtn.luaClick = self.CreateAction(self, self.OnClickMBTIBtn)
	self.bindData.nameAIBtn.luaClick = self.CreateAction(self, self.OnClickNameAiBtn)
	self.bindData.descAIBtn.luaClick = self.CreateAction(self, self.OnClickDescAiBtn)
	self.bindData.resetBtn.luaClick = self.CreateAction(self, self.OnClickResetBtn)
	self.bindData.nameInput.luaClick = self.CreateAction(self, self.OnClickNameInput)
	self.bindData.nameInput.luaEndEdit = self.CreateAction(self, self.OnEndEditName)
	self.bindData.nameInput.luaValueChanged = self.CreateAction(self, self.OnChangeName)
	self.bindData.ageSelector.luaSelectedChanged = self.CreateAction(self, self.OnSelectedAge)
	self.bindData.genderSelector.luaSelectedChanged = self.CreateAction(self, self.OnSelectedSex)
	self.bindData.descInput.luaValueChanged = self.CreateAction(self, self.OnChangeDesc)

	self.bindData.headFreeList.onGetTIndex = function(_)
		return self.currentStep ~= 2 and 1 or 0
	end

	self.bindData.headFreeList.luaRenderItem = self.CreateAction(self, self.OnRenderHeadListItem)
	self.bindData.headFreeList.luaClick = self.CreateAction(self, self.OnClickHeadListItem)
end

M.RegisterPersonalityTagTooltip = function(self)
	local tagWidgets = {
		self.bindData.tag1,
		self.bindData.tag2,
		self.bindData.tag3
	}

	for i = 1, 3 do
		local widget = tagWidgets[i]

		if widget then
			self.mgr:InitPersonalityTagTooltip(widget, self, i)
		end
	end
end

M.OnClickAiBtn = function(self)
	self.bindData.showChat = self.bindData.showChat ~= 0 and 1 or 0

	if self.bindData.showChat ~= self.showChatEnum._true then
		self.GetAIPromptView(self)
	end
end

M.OnRefreshTemplate = function(self)
	local posCount = #OCConfig.TemplatePosList

	if self.currentStep ~= 2 then
		local templateCount = posCount
		local charPersonalityId = nil

		if self.currentTemplateId then
			local cfg = OCTemplateConfig.GetConfig(self.currentTemplateId)

			if cfg then
				charPersonalityId = cfg.PersonalityTemplate
			end
		end

		local preserveId = nil

		if not self.isPresetModified and self.currentPersonalityTemplateId then
			preserveId = self.currentPersonalityTemplateId
		else
			preserveId = charPersonalityId
		end

		self.templateList = self.mgr:GetPersonalityTemplateListByCondition(self.mgr.baseData.sex, self.mgr.baseData.age, preserveId, templateCount)

		if preserveId then
			self.currentPersonalityTemplateId = preserveId
		elseif self.templateList[1] then
			self.currentPersonalityTemplateId = self.templateList[1]
		end

		self.bindData.headFreeList:SetList(#self.templateList)
	else
		local templateCount = posCount - 1
		local isInitial = self.isFirstTemplateRefresh
		self.isFirstTemplateRefresh = false

		if isInitial then
			self.templateList = self.mgr:GetTemplateList(templateCount)
		else
			self.templateList = self.mgr:GetTemplateListByCondition(self.mgr.baseData.sex, self.mgr.baseData.age, templateCount)
		end

		if self.templateList[1] then
			self.currentTemplateId = self.templateList[math.random(1, #self.templateList)]
			self.isPresetModified = false

			self.ApplyPersonalityFromCharacterTemplate(self, self.currentTemplateId)

			local voiceCfg = OCTemplateConfig.GetConfig(self.currentTemplateId)

			if voiceCfg and voiceCfg.VoiceFiles and not string.is_null_or_empty(voiceCfg.VoiceFiles) then
				self.mgr:AddRecommend(voiceCfg.VoiceFiles)
			end
		end

		self.bindData.headFreeList:SetList(#self.templateList + 1)
	end
end

M.OnClickRefreshBtn = function(self)
	self.PushSnapshot(self)
	self.OnRefreshTemplate(self)
end

M.OnClickGoBtn = function(self)
	local hasName = not string.is_null_or_empty(self.mgr.baseData.name)
	self.bindData.haveNameCtrl = BOOL2CTL[hasName]

	if not hasName then
		return
	end

	local ok, errMsg = self.mgr:CheckOCName(self.mgr.baseData.name)

	if not ok then
		if errMsg and errMsg == "" then
			gDisplayMessageMgr:ShowMessageContent(errMsg)
		end

		return
	end

	self.PushSnapshot(self)

	self.currentStep = 2
	self.bindData.stageCtrl = 1

	self.OnRefreshTemplate(self)
end

M.OnBack = function(self)
	if self.currentStep == 2 then
		return false
	end

	self.currentStep = 1
	self.bindData.stageCtrl = 0

	if self.isPresetModified then
		self.OnRefreshTemplate(self)
	else
		local posCount = #OCConfig.TemplatePosList
		local templateCount = posCount - 1
		self.templateList = self.mgr:GetTemplateListByCondition(self.mgr.baseData.sex, self.mgr.baseData.age, templateCount)

		if self.templateList[1] and not self.currentTemplateId then
			self.currentTemplateId = self.templateList[math.random(1, #self.templateList)]
		end

		self.bindData.headFreeList:SetList(#self.templateList + 1)
	end

	self.PushSnapshot(self)
	self.OnDataRefresh(self)

	return true
end

M.OnClickNextBtn = function(self)
	self.mgr:UpLoadBaseData()

	if self.isPresetModified then
		self.mgr:GetRecommendVoice()
	end

	if self.parentStore then
		self.parentStore:GoToNext()
	end
end

M.ApplyPersonalityFromCharacterTemplate = function(self, characterTemplateId)
	print_debug("[OC] ApplyPersonalityFromCharacterTemplate", characterTemplateId)

	local templateCfg = OCTemplateConfig.GetConfig(characterTemplateId)

	if not templateCfg then
		return
	end

	self.ApplyPersonalityTemplate(self, templateCfg.PersonalityTemplate)
end

M.ApplyPersonalityTemplate = function(self, personalityTemplateId)
	self.currentPersonalityTemplateId = personalityTemplateId
	local pCfg = OCPersonalityTemplateConfig.GetConfig(personalityTemplateId)

	print_debug("[OC] ApplyPersonalityTemplate", personalityTemplateId, pCfg and pCfg.PersonalityTitle)

	if not pCfg then
		return
	end

	self.mgr.personalityAndStory.desc = pCfg.Desc or ""

	if pCfg.PersonalityTag then
		local tags = string.split(pCfg.PersonalityTag, ";")
		self.mgr.personalityAndStory.labels = tags or {}
	else
		self.mgr.personalityAndStory.labels = {}
	end

	if pCfg.MBTI then
		local mbtiCfg = LTConfig.OriginalCharacterMBTIConfig

		for i = 0, mbtiCfg.count - 1 do
			local item = mbtiCfg.LoadAt(i)

			if item.MBTI ~= pCfg.MBTI then
				self.mgr:SetMBTIId(item.Id)

				break
			end
		end
	end
end

M.OnRenderHeadListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local id = index + 1
	local pos = OCConfig.TemplatePosList[id]

	btn.SetLocalPos(btn, Vector3.New(pos.x, pos.y, 0))

	local templateId = self.templateList[id]

	if self.currentStep ~= 1 then
		local isAI = id >= #self.templateList
		store.isAICtrl = isAI and self.isAICtrlEnum._true or self.isAICtrlEnum._false

		if isAI then
			return
		end

		local cfg = OCTemplateConfig.GetConfig(templateId)

		if not cfg then
			return
		end

		store.headIcon = cfg.Image

		btn:SetSelected(templateId ~= self.currentTemplateId)
	else
		local pCfg = OCPersonalityTemplateConfig.GetConfig(templateId)

		if not pCfg then
			return
		end

		store.label = pCfg.PersonalityTitle or ""

		btn:SetSelected(templateId ~= self.currentPersonalityTemplateId)
	end
end

M.OnClickHeadListItem = function(self, btn, index)
	local id = index + 1

	if id <= #self.templateList then
		self.OnClickAiBtn(self)

		return
	end

	local templateId = self.templateList[id]

	if self.currentStep ~= 1 then
		self.PushSnapshot(self)

		self.currentTemplateId = templateId
		self.isPresetModified = false

		self.ApplyPersonalityFromCharacterTemplate(self, templateId)

		local voiceCfg = OCTemplateConfig.GetConfig(templateId)

		if voiceCfg and voiceCfg.VoiceFiles and not string.is_null_or_empty(voiceCfg.VoiceFiles) then
			self.mgr:AddRecommend(voiceCfg.VoiceFiles)
		end

		self.mgr:OnChangeTemplate(templateId)
		self.mgr:RequestNewOCId()
		self.bindData.headFreeList:SetList(#self.templateList + 1)
	else
		self:PushSnapshot()
		self:ApplyPersonalityTemplate(templateId)
		self.mgr:RequestNewOCId()
		self:OnDataRefresh()
		self.bindData.headFreeList:SetList(#self.templateList)
	end
end

M.OnClickNameAiBtn = function(self)
	self.bindData.nameAIBtn.interactable = false
	slot1 = self.mgr

	slot1:GetNameByGen(function (name)
		if name then
			local ok, errMsg = self.mgr:CheckOCName(name)

			if ok then
				self.bindData.nameInput.text = name
				self.mgr.baseData.name = name

				self:PushSnapshot()
			elseif errMsg and errMsg == "" then
				gDisplayMessageMgr:ShowMessageContent(errMsg)
			end
		end

		self.bindData.nameAIBtn.interactable = true
	end)
end

M.OnClickDescAiBtn = function(self)
	self.bindData.descAIBtn.interactable = false
	slot1 = self.mgr

	slot1:GetDescByGen(function (desc)
		if not string.is_null_or_empty(desc) then
			self.isRefreshing = true
			self.bindData.descInput.text = desc
			self.isRefreshing = false

			self:OnChangeDesc(desc)
			self:PushSnapshot()
		end

		self.bindData.descAIBtn.interactable = true
	end)
end

M.OnClickSoundBtn = function(self)
	if self.bindData.soundPlayCtrl ~= 0 then
		self.bindData.soundPlayCtrl = 1
	end

	self.bindData.soundBtn.interactable = false
	self.bindData.randomSoundBtn.interactable = false
	local recommendItem = nil

	for _, v in ipairs(self.mgr.officialVoiceList) do
		if v.index ~= -1 then
			recommendItem = v

			break
		end
	end

	local doPlay = function(speechId)
		self.mgr:Log("OnClickSoundBtn templateId=", self.currentTemplateId, " speechId=", speechId)

		if not speechId then
			self.bindData.randomSoundBtn.interactable = true
			self.bindData.soundBtn.interactable = true

			return
		end

		gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)
		self.mgr:PlayAIVoice(speechId, speechId)
	end

	if recommendItem then
		doPlay(recommendItem.speechId)
	else
		slot3 = self.mgr

		slot3:GetRecommendVoice(function (speechId)
			doPlay(speechId)
		end)
	end
end

M.OnClickRandomSoundBtn = function(self)
	self.bindData.randomSoundBtn.interactable = false
	self.bindData.soundBtn.interactable = false
	slot1 = self.mgr

	slot1:MarkRecommendDirty()

	slot1 = self.mgr

	slot1:GetRecommendVoice(function (speechId)
		self.mgr:Log("OnClickRandomSoundBtn templateId=", self.currentTemplateId, " speechId=", speechId)

		if speechId then
			gMessageManager:SendMessage(gEventConstants.ON_OC_VOICE_PLAY_VOICE, true)
			self.mgr:PlayAIVoice(speechId, speechId)
		else
			self.bindData.randomSoundBtn.interactable = true
			self.bindData.soundBtn.interactable = true
		end
	end)
end

M.OnClickQuitSoundBtn = function(self)
	self.bindData.soundPlayCtrl = 0
end

M.OnVoicePlayChange = function(self, eventId, isPlaying)
	if isPlaying then
		self.bindData.soundBtn.interactable = false
		self.bindData.randomSoundBtn.interactable = false

		if self.testSoundTimer then
			self.testSoundTimer:Stop()
		end

		self.testSoundTimer = Timer.New(function ()
			self.testSoundTimer = nil

			if self.bindData.randomSoundBtn then
				self.bindData.randomSoundBtn.interactable = true
			end

			if self.bindData.soundBtn then
				self.bindData.soundBtn.interactable = true
			end
		end, OCConfig.VoiceTestCooldownSec):Start()

		gCS.LuaUtils.PlayAnimationByName(self.bindData.soundPlayAnim, "S_Vx_Sound_OCtest_loop")
	else
		gCS.LuaUtils.StopCurrentAnimation(self.bindData.soundPlayAnim)
	end
end

M.OnSelectedAge = function(self)
	local id = self.ageList[self.bindData.ageSelector.selectedIndex + 1].id

	if self.mgr.baseData.age ~= id then
		return
	end

	local currentCfg = OCTemplateConfig.GetConfig(self.currentTemplateId)

	if currentCfg and currentCfg.Age == id then
		local currentIndex = 0

		for i, item in ipairs(self.ageList) do
			if item.id ~= self.mgr.baseData.age then
				currentIndex = i - 1

				break
			end
		end

		slot4 = self.bindData.ageSelector

		slot4:SelectOption(currentIndex, false)

		slot4 = gDisplayMessageMgr

		slot4:ShowMessage(LTConfig.MessageConfig.OCConfigChangeSecConfirm, function ()
			self:PushSnapshot()

			self.bindData.soundPlayCtrl = 0
			self.isPresetModified = true

			self.mgr:MarkRecommendDirty()

			self.mgr.baseData.age = id
			local newTemplateId = self:FindTemplateByCondition(self.mgr.baseData.sex, id)

			if newTemplateId then
				self.currentTemplateId = newTemplateId

				self:ApplyPersonalityFromCharacterTemplate(newTemplateId)
				self.mgr:OnChangeTemplate(newTemplateId)

				local voiceCfg = OCTemplateConfig.GetConfig(newTemplateId)

				if voiceCfg and voiceCfg.VoiceFiles and not string.is_null_or_empty(voiceCfg.VoiceFiles) then
					self.mgr:AddRecommend(voiceCfg.VoiceFiles)
				else
					self.mgr:GetRecommendVoice()
				end
			else
				self.mgr:SwitchModel()
				self.mgr:GetRecommendVoice()
			end

			self:RefreshTemplateListForStep()
			self:OnDataRefresh()
		end)
	else
		self:PushSnapshot()

		self.bindData.soundPlayCtrl = 0
		self.isPresetModified = true

		self.mgr:MarkRecommendDirty()

		self.mgr.baseData.age = id

		self.mgr:SwitchModel()
		self:RefreshTemplateListForStep()
		self:OnDataRefresh()
	end
end

M.OnSelectedSex = function(self)
	local id = self.genderList[self.bindData.genderSelector.selectedIndex + 1].id

	if self.mgr.baseData.sex ~= id then
		return
	end

	local currentCfg = OCTemplateConfig.GetConfig(self.currentTemplateId)

	if currentCfg and currentCfg.Sex == id then
		local currentIndex = 0

		for i, item in ipairs(self.genderList) do
			if item.id ~= self.mgr.baseData.sex then
				currentIndex = i - 1

				break
			end
		end

		slot4 = self.bindData.genderSelector

		slot4:SelectOption(currentIndex, false)

		slot4 = gDisplayMessageMgr

		slot4:ShowMessage(LTConfig.MessageConfig.OCConfigChangeSecConfirm, function ()
			self:PushSnapshot()

			self.bindData.soundPlayCtrl = 0
			self.isPresetModified = true

			self.mgr:MarkRecommendDirty()

			self.mgr.baseData.sex = id
			local newTemplateId = self:FindTemplateByCondition(id, self.mgr.baseData.age)

			if newTemplateId then
				self.currentTemplateId = newTemplateId

				self:ApplyPersonalityFromCharacterTemplate(newTemplateId)
				self.mgr:OnChangeTemplate(newTemplateId)

				local voiceCfg = OCTemplateConfig.GetConfig(newTemplateId)

				if voiceCfg and voiceCfg.VoiceFiles and not string.is_null_or_empty(voiceCfg.VoiceFiles) then
					self.mgr:AddRecommend(voiceCfg.VoiceFiles)
				else
					self.mgr:GetRecommendVoice()
				end
			else
				self.mgr:SwitchModel()
				self.mgr:GetRecommendVoice()
			end

			self:RefreshTemplateListForStep()
			self:OnDataRefresh()
		end)
	else
		self:PushSnapshot()

		self.bindData.soundPlayCtrl = 0
		self.isPresetModified = true

		self.mgr:MarkRecommendDirty()

		self.mgr.baseData.sex = id

		self.mgr:SwitchModel()
		self:RefreshTemplateListForStep()
		self:OnDataRefresh()
	end
end

M.FindTemplateByCondition = function(self, sex, age)
	local totalCount = OCTemplateConfig.count
	local candidates = {}

	for i = 0, totalCount - 1 do
		local cfg = OCTemplateConfig.LoadAt(i)

		if cfg.Sex ~= sex and cfg.Age ~= age then
			table.insert(candidates, cfg.Id)
		end
	end

	if #candidates ~= 0 then
		return nil
	end

	return candidates[math.random(1, #candidates)]
end

M.RefreshTemplateListForStep = function(self)
	if self.currentStep ~= 2 then
		self.OnRefreshTemplate(self)
	else
		self.templateList = self.mgr:GetTemplateListByCondition(self.mgr.baseData.sex, self.mgr.baseData.age, #OCConfig.TemplatePosList - 1)

		if self.templateList[1] and not self.currentTemplateId then
			self.currentTemplateId = self.templateList[1]
		end

		self.bindData.headFreeList:SetList(#self.templateList + 1)
	end
end

M.OnClickMBTIBtn = function(self)
	if self.bindData.showMBTICtrl == 1 then
		self.bindData.showMBTICtrl = 1

		self.SubGroup.OCMBTIPanelStore:OnShow()
	end
end

M.OnMBTIChange = function(self)
	self.PushSnapshot(self)

	self.bindData.showMBTICtrl = 0

	self.OnDataRefresh(self)
end

M.RefreshMBTIDisplay = function(self)
	local widget = self.bindData.mbtiBtn
	local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

	if not store then
		return
	end

	local cfg = self.mgr:GetMBTI()

	if not cfg then
		store.text = ""
		store.icon = 0

		return
	end

	store.text = cfg.MBTI or cfg.Title or ""
	store.icon = cfg.Image or 0
end

M.OnClickTag = function(self, slotIndex)
	local labels = self.mgr.personalityAndStory.labels

	if labels[slotIndex] then
		self.PushSnapshot(self)
		table.remove(labels, slotIndex)
		self.RefreshTags(self)
	end
end

M.RefreshTags = function(self)
	local labels = self.mgr.personalityAndStory.labels
	local tagWidgets = {
		self.bindData.tag1,
		self.bindData.tag2,
		self.bindData.tag3
	}

	for i = 1, 3 do
		local widget = tagWidgets[i]
		local store = gStoreManager:GetStoreGroup(widget.Store):GetStoreByWidget(widget)

		if store then
			if labels[i] then
				store.emptyCtrl = 1
				store.text = labels[i]
				store.colorCtrl = i

				if store.closeBtn then
					store.closeBtn.luaClick = self.CreateAction(self, function ()
						self:OnClickTag(i)
					end)
				end

				widget.SetEnabledTooltip(widget, false)
			else
				store.emptyCtrl = 0
				store.text = ""

				widget.SetEnabledTooltip(widget, true)
			end
		end
	end
end

M.OnChangeName = function(self, str)
	if self.isRefreshing then
		return
	end

	local visualLength = LX6.Utils.TextUtils.GetVisualLength(str)

	if LTConfig.GameConfig.PlayerNameMaxLength >= visualLength then
		self.isRefreshing = true
		self.bindData.nameInput.text = self.mgr.baseData.name
		self.isRefreshing = false

		return
	end

	self.mgr.baseData.name = str
	self.bindData.haveNameCtrl = BOOL2CTL[not string.is_null_or_empty(str)]
end

M.OnClickNameInput = function(self)
	if self.currentStep ~= 1 then
		self.bindData.showEditNameCtrl = 1
	end

	self.bindData.inputNameCtrl = BOOL2CTL[true]
end

M.OnEndEditName = function(self, str)
	local ok, errMsg = self.mgr:CheckOCName(str)

	if not ok then
		if errMsg and errMsg == "" then
			gDisplayMessageMgr:ShowMessageContent(errMsg)
		end

		local snapshot = self.CtrlZSteps[self.currentPointIndex]
		local validName = snapshot and snapshot.name or ""
		self.isRefreshing = true
		self.bindData.nameInput.text = validName
		self.isRefreshing = false
		self.mgr.baseData.name = validName
		self.bindData.haveNameCtrl = BOOL2CTL[not string.is_null_or_empty(validName)]
		self.bindData.showEditNameCtrl = 0
		self.bindData.inputNameCtrl = BOOL2CTL[false]

		return
	end

	self.PushSnapshot(self)

	self.mgr.baseData.name = str
	self.bindData.haveNameCtrl = BOOL2CTL[not string.is_null_or_empty(str)]
	self.bindData.showEditNameCtrl = 0
	self.bindData.inputNameCtrl = BOOL2CTL[false]
end

M.OnChangeDesc = function(self, str)
	if self.isRefreshing then
		return
	end

	if self.currentStep ~= 2 then
		self.mgr.personalityAndStory.desc = str
	else
		self.mgr.personalityAndStory.desc = str

		if self.mgr.IpId and str == TemplateIPConfig.GetConfig(self.mgr.IpId).Desc then
			self.mgr.IpId = nil
		end

		self.isPresetModified = true

		self.mgr:MarkRecommendDirty()
	end
end

M.OnClickConfirmBtn = function(self)
	local text = self.bindData.chatInput.text
	self.bindData.chatConfirmBtn.interactable = false
	slot2 = self.mgr

	slot2:GetPersonaByInstruction(text, function (persona)
		self.bindData.chatConfirmBtn.interactable = true

		self:PushSnapshot()
		self.mgr:ConvertPersonaToData(persona)
	end)
end

M.TakeSnapshot = function(self)
	return {
		templateId = self.currentTemplateId,
		name = self.mgr.baseData.name,
		sex = self.mgr.baseData.sex,
		age = self.mgr.baseData.age,
		personalityDesc = self.mgr.personalityAndStory.desc,
		labels = table.clone(self.mgr.personalityAndStory.labels),
		mbtiId = self.mgr.MBTIId,
		currentStep = self.currentStep,
		personalityTemplateId = self.currentPersonalityTemplateId,
		ipId = self.mgr.IpId,
		templateList = table.clone(self.templateList)
	}
end

M.PushSnapshot = function(self)
	if self.currentPointIndex >= #self.CtrlZSteps then
		for i = #self.CtrlZSteps, self.currentPointIndex + 1, -1 do
			table.remove(self.CtrlZSteps, i)
		end
	end

	table.insert(self.CtrlZSteps, self:TakeSnapshot())

	local maxSteps = OCConfig.UndoMaxSteps or 10

	if maxSteps >= #self.CtrlZSteps then
		table.remove(self.CtrlZSteps, 1)
	end

	self.currentPointIndex = #self.CtrlZSteps

	self.UpdateUndoRedoButtons(self)
end

M.ApplySnapshot = function(self, snapshot)
	if not snapshot then
		return
	end

	self.currentTemplateId = snapshot.templateId
	self.currentPersonalityTemplateId = snapshot.personalityTemplateId
	self.mgr.baseData.name = snapshot.name
	self.mgr.baseData.sex = snapshot.sex
	self.mgr.baseData.age = snapshot.age
	self.mgr.personalityAndStory.desc = snapshot.personalityDesc
	self.mgr.personalityAndStory.labels = table.clone(snapshot.labels)

	self.mgr:SetMBTIId(snapshot.mbtiId)

	self.mgr.IpId = snapshot.ipId
	self.templateList = table.clone(snapshot.templateList)

	if snapshot.currentStep == self.currentStep then
		self.currentStep = snapshot.currentStep
		self.bindData.stageCtrl = self.currentStep ~= 2 and 1 or 0
	end

	self.mgr:OnChangeTemplate(self.currentTemplateId)

	if self.currentStep ~= 2 then
		self.bindData.headFreeList:SetList(#self.templateList)
	else
		self.bindData.headFreeList:SetList(#self.templateList + 1)
	end

	self.OnDataRefresh(self)
end

M.HasLastStep = function(self)
	return self.currentPointIndex >= 1
end

M.HasNextStep = function(self)
	return self.currentPointIndex <= #self.CtrlZSteps
end

M.OnClickUndoBtn = function(self)
	if not self.HasLastStep(self) then
		return
	end

	self.currentPointIndex = self.currentPointIndex - 1

	self.ApplySnapshot(self, self.CtrlZSteps[self.currentPointIndex])
	self.UpdateUndoRedoButtons(self)
end

M.OnClickRedoBtn = function(self)
	if not self.HasNextStep(self) then
		return
	end

	self.currentPointIndex = self.currentPointIndex + 1

	self.ApplySnapshot(self, self.CtrlZSteps[self.currentPointIndex])
	self.UpdateUndoRedoButtons(self)
end

M.UpdateUndoRedoButtons = function(self)
	self.bindData.undoBtn.interactable = self.HasLastStep(self)
	self.bindData.redoBtn.interactable = self.HasNextStep(self)
end

M.OnClickResetBtn = function(self)
	if #self.CtrlZSteps ~= 0 then
		return
	end

	self.currentPointIndex = 1

	self.ApplySnapshot(self, self.CtrlZSteps[1])
	self.UpdateUndoRedoButtons(self)
end

M.OnDataRefresh = function(self)
	local genderIndex = 0

	for i, item in ipairs(self.genderList) do
		if item.id ~= self.mgr.baseData.sex then
			genderIndex = i - 1

			break
		end
	end

	self.bindData.genderSelector:SelectOption(genderIndex, false)

	local ageIndex = 0

	for i, item in ipairs(self.ageList) do
		if item.id ~= self.mgr.baseData.age then
			ageIndex = i - 1

			break
		end
	end

	self.bindData.ageSelector:SelectOption(ageIndex, false)

	self.isRefreshing = true

	if self.currentStep ~= 2 then
		self.bindData.descInput.text = self.mgr.personalityAndStory.desc or ""
	else
		self.bindData.descInput.text = self.mgr.personalityAndStory.desc
	end

	self.bindData.nameInput.text = self.mgr.baseData.name
	self.isRefreshing = false
	self.bindData.haveNameCtrl = BOOL2CTL[not string.is_null_or_empty(self.mgr.baseData.name)]

	self.RefreshMBTIDisplay(self)
	self.RefreshTags(self)
	self.UpdateUndoRedoButtons(self)
end

M.GetAIPromptView = function(self)
end
