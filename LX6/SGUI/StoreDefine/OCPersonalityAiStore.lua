-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\OCPersonalityAiStore.lua
-- Decompiled from: 00952_OCPersonalityAiStore.lua_b99ea36ddfc5.luajit

C_OCPersonalityAiStore = DefClass("C_OCPersonalityAiStore", C_OCPersonalityAiStore, C_StoreGroup)
GroupName2Class.OCPersonalityAiStore = C_OCPersonalityAiStore
local M = C_OCPersonalityAiStore
local PersonalityQuestionConfig = LTConfig.OriginalCharacterPersonalityQuestionConfig

M.ctor = function(self)
	self.mgr = gOCMgr
end

M.DefineAllVariables = function(self)
	self.questionDataList = nil
	self.unlockedCount = 1
	self.savedPersonalityInput = ""
	self.isGenerating = false
	self.questionAnswers = {}
end

M.DefineAllEnumsAutoGen = function(self)
	self.finishCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
	self.generateCtrlEnum = {
		["#N\\x90\\x82\\x90D"] = 0,
		["r\\xba\\xb0\\xba\\xb3"] = 1
	}
end

M.ClearAllEnumsAutoGen = function(self)
	self.finishCtrlEnum = nil
	self.generateCtrlEnum = nil
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
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, panelId, data)
	self.BuildQuestionList(self)
end

M.OnClose = function(self)
	self.questionDataList = nil
	self.unlockedCount = 1
	self.savedPersonalityInput = ""
	self.isGenerating = false
	self.questionAnswers = {}
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.genBtn.luaClick = self.CreateAction(self, self.OnClickGenBtn)
	self.bindData.applyBtn.luaClick = self.CreateAction(self, self.OnClickApplyBtn)
	self.bindData.retryBtn.luaClick = self.CreateAction(self, self.OnClickRetryBtn)
	self.bindData.refreshBtn.luaClick = self.CreateAction(self, self.OnClickRefreshBtn)
	self.bindData.backToMainBtn.luaClick = self.CreateAction(self, self.OnClickBackToMainBtn)
	self.bindData.questionList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderQuestionListItem)
	self.bindData.finishList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderFinishListItem)
	self.bindData.questionList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickQuestionList)
	self.bindData.finishList.luaSimpleClick = self.CreateAction(self, self.OnSimpleClickFinishList)
	self.bindData.personalityInput.luaValueChanged = self.CreateAction(self, self.OnPersonalityInputInputValueChanged)
end

M.OnClickBackToMainBtn = function(self)
	if self.parentStore then
		self.parentStore.bindData.tabRect.selectedIndex = self.parentStore.tabCtrlEnum.personalityMain
	end
end

M.OnClickGenBtn = function(self)
	self.savedPersonalityInput = self.bindData.personalityInput.text

	self.DoGenerate(self)
end

M.OnClickApplyBtn = function(self)
	if self.mgr.personalityAndStory then
		self.mgr.personalityAndStory.story = self.bindData.personalityInput.text
	end

	gMessageManager:SendMessage(gEventConstants.OC_DATA_REFRESH)
	self:ResetAiGenerateState()

	if self.parentStore then
		self.parentStore.bindData.tabRect.selectedIndex = self.parentStore.tabCtrlEnum.personalityMain
	end
end

M.OnClickRetryBtn = function(self)
	self.bindData.finishCtrl = 0
	self.bindData.personalityInput.text = self.savedPersonalityInput
end

M.OnClickRefreshBtn = function(self)
	self.DoGenerate(self)
end

M.DoGenerate = function(self)
	local qaRecords = {}
	slot2 = ipairs
	slot4 = self.questionDataList or {}

	for _, data in slot2(slot4) do
		local answer = self.GetQuestionAnswer(self, data.Type)

		if not string.is_null_or_empty(answer) then
			table.insert(qaRecords, {
				Question = data.Context,
				Answer = answer
			})
		end
	end

	if #qaRecords ~= 0 then
		return
	end

	local introduction = self.mgr.personalityAndStory and self.mgr.personalityAndStory.desc or ""

	self:SetGenerating(true)
	self.mgr:ComposePersonaBackgroundFromQARecords(introduction, qaRecords, function (data)
		if not self.bindData then
			return
		end

		if not self.isGenerating then
			return
		end

		if data and not string.is_null_or_empty(data.Background) then
			self.bindData.personalityInput.text = data.Background
			self.bindData.finishCtrl = 1
		end

		self:SetGenerating(false)
	end)
end

M.SetGenerating = function(self, isGen)
	self.isGenerating = isGen
	self.bindData.genBtn.interactable = not isGen
	self.bindData.refreshBtn.interactable = not isGen

	self.bindData.questionList:SetSimpleList(#(self.questionDataList or {}))

	self.bindData.generateCtrl = isGen and 1 or 0
end

M.ResetAiGenerateState = function(self)
	self.questionAnswers = {}
	self.savedPersonalityInput = ""
	self.unlockedCount = 1

	if self.bindData then
		self.bindData.personalityInput.text = ""
		self.bindData.finishCtrl = 0

		self.bindData.questionList:SetSimpleList(#(self.questionDataList or {}))
		self.bindData.finishList:SetSimpleList(#self.questionDataList)
		self:RefreshGenBtn()
	end
end

M.OnSimpleRenderQuestionListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.questionDataList and self.questionDataList[index + 1]

	if not data then
		return
	end

	store.questionText = data.Context

	if store.input then
		store.input.text = self:GetQuestionAnswer(data.Type)
		store.input.interactable = index >= self.unlockedCount and not self.isGenerating
		store.input.luaEndEdit = self:CreateActionWithArgs(self.OnEndEditQuestionInput, {
			input = store.input,
			index = index,
			questionType = data.Type
		})
	end

	if store.randomBtn then
		store.randomBtn.luaClick = self.CreateActionWithArgs(self, self.OnClickRandomBtn, index)
	end

	if store.questionBtn then
		store.questionBtn.interactable = index >= self.unlockedCount and not self.isGenerating
	end
end

M.OnSimpleClickQuestionList = function(self, btn, index)
end

M.OnSimpleRenderFinishListItem = function(self, btn, index)
	local store = gStoreManager:GetStoreGroup(btn.Store):GetStoreByWidget(btn)

	if not store then
		return
	end

	local data = self.questionDataList and self.questionDataList[index + 1]

	if not data then
		return
	end

	local isFinished = not string.is_null_or_empty(self:GetQuestionAnswer(data.Type))
	store.finishCtrl = isFinished and 1 or 0
end

M.OnSimpleClickFinishList = function(self, btn, index)
end

M.GetQuestionAnswer = function(self, questionType)
	return self.questionAnswers[questionType] or ""
end

M.OnEndEditQuestionInput = function(self, context)
	local text = context.input and context.input.text or ""

	if string.is_null_or_empty(text) then
		self.questionAnswers[context.questionType] = nil
	else
		self.questionAnswers[context.questionType] = text
	end

	if not string.is_null_or_empty(text) and self.unlockedCount < context.index + 1 then
		self.unlockedCount = context.index + 2

		self.bindData.questionList:SetSimpleList(#self.questionDataList)
	end

	self.bindData.finishList:SetSimpleList(#self.questionDataList)
	self:RefreshGenBtn()
end

M.OnClickRandomBtn = function(self, index)
	local data = self.questionDataList and self.questionDataList[index + 1]

	if not data then
		return
	end

	local pool = {}

	for i = 0, PersonalityQuestionConfig.count - 1 do
		local cfg = PersonalityQuestionConfig.LoadAt(i)

		if cfg and cfg.Type ~= data.Type and cfg.Id == data.Id then
			table.insert(pool, cfg)
		end
	end

	if #pool ~= 0 then
		return
	end

	self.questionDataList[index + 1] = pool[math.random(#pool)]

	self.bindData.questionList:SetSimpleList(#self.questionDataList)
end

M.BuildQuestionList = function(self)
	local typeGroups = {}

	for i = 0, PersonalityQuestionConfig.count - 1 do
		local cfg = PersonalityQuestionConfig.LoadAt(i)

		if cfg then
			local t = cfg.Type

			if not typeGroups[t] then
				typeGroups[t] = {}
			end

			table.insert(typeGroups[t], cfg)
		end
	end

	local types = {}

	for t in pairs(typeGroups) do
		table.insert(types, t)
	end

	table.sort(types)

	self.questionDataList = {}

	for _, t in ipairs(types) do
		if #self.questionDataList > 3 then
			break
		end

		local pool = typeGroups[t]

		table.insert(self.questionDataList, pool[math.random(#pool)])
	end

	self:UpdateUnlockedCount()
	self.bindData.questionList:SetSimpleList(#self.questionDataList)
	self.bindData.finishList:SetSimpleList(#self.questionDataList)
	self:RefreshGenBtn()
end

M.RefreshGenBtn = function(self)
	local allDone = true
	slot2 = ipairs
	slot4 = self.questionDataList or {}

	for _, data in slot2(slot4) do
		if string.is_null_or_empty(self.GetQuestionAnswer(self, data.Type)) then
			allDone = false

			break
		end
	end

	self.bindData.genBtn.interactable = allDone
end

M.UpdateUnlockedCount = function(self)
	self.unlockedCount = 1

	for i, data in ipairs(self.questionDataList) do
		if not string.is_null_or_empty(self.GetQuestionAnswer(self, data.Type)) then
			self.unlockedCount = math.min(i + 1, #self.questionDataList)
		else
			break
		end
	end
end

M.OnPersonalityInputInputValueChanged = function(self, text)
end
