-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\TrainingComboStore.lua
-- Decompiled from: 01275_TrainingComboStore.lua_58fe479ea789.luajit

C_TrainingComboStore = DefClass("C_TrainingComboStore", C_TrainingComboStore, C_StoreGroup)
GroupName2Class.TrainingComboStore = C_TrainingComboStore
local M = C_TrainingComboStore
local TrainingConfig = LTConfig.CombatTrainingTrainWorkactionConfig
local ComboConfig = LTConfig.CombatTrainingComboConfig
local SGUIPCKeyConfig = LTConfig.InputSGUIPCKeyConfig
local SGUIGamepadConfig = LTConfig.InputSGUIGamepadConfig
local COMBO_FINISH_ANIM_TIME = 1.2

M.ctor = function(self)
	self.InitData(self)

	self.buttonNamePCDic = {}

	for i = 0, LTConfig.InputKeyboardConfig.count - 1 do
		local cfg = LTConfig.InputKeyboardConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNamePCDic[cfg.ButtonName] = cfg
		end
	end

	self.buttonNameGamepadDic = {}

	for i = 0, LTConfig.InputGamepadConfig.count - 1 do
		local cfg = LTConfig.InputGamepadConfig.LoadAt(i)

		if cfg and not string.is_null_or_empty(cfg.ButtonName) then
			self.buttonNameGamepadDic[cfg.ButtonName] = cfg
		end
	end
end

M.DefineAllVariables = function(self)
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self:DefineAllVariables()
	self:GenMessageEvents()
	self:RegisterWidget()

	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= gCS.LuaUtils.GetActiveDevice()
end

M.OnEnable = function(self)
end

M.OnStart = function(self)
end

M.OnDisable = function(self)
end

M.NoTask = function(self)
	self.NotifyComboState(self, false)

	self.curTaskId = 0
	self.curTaskInfo = nil
end

M.OnDestroy = function(self)
	self.isDestroy = true

	self.NotifyComboState(self, false)

	if gTaskManager.TaskGamePlay then
		gTaskManager.TaskGamePlay:ClearSinglePanel(self.m_Id)
	end
end

M.OnGroupEnable = function(self)
	self.RegisterMessageEvents(self, self.msgEvents)
end

M.OnGroupDisable = function(self)
	self.ClearMessageEvents(self)
end

M.OnShow = function(self, panelId, data)
	self.InitData(self)

	self.currentTaskType = gTaskManager.CurrentTaskType.Task1
	local localData = {
		IsFirstTime = true,
		CurrentTaskType = self.currentTaskType
	}

	self.SetCurrentTaskData(self, localData)

	if gTaskManager.TaskGamePlay then
		gTaskManager.TaskGamePlay:CheckSinglePanel(self.m_Id)
	end

	if not self.curTaskInfo then
		print_error("@buyifan TrainingComboStore，找不到当前的taskInfo")

		return
	end

	self.RefreshTask(self)
end

M.RefreshTask = function(self)
	if self.curTaskInfo.BattleTrainingType == 3 then
		return
	end

	self.SkillId = self.curTaskInfo.SkillId
	local combatCfg = TrainingConfig.GetConfig(self.SkillId)

	if not combatCfg then
		return
	end

	local textCfg = LTConfig.TextCommonTextConfig.GetConfig(combatCfg.StateDesId)

	if textCfg then
		self.bindData.stateDes = textCfg.Text
	else
		print_error("#NoCreateIssue 战斗训练状态描述Id不存在", combatCfg.StateDesId)
	end

	local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)

	if not cfg then
		return
	end

	local counterIndex = gTaskNodeManager:FindFirstCounterIndex(self.curTaskId)
	self.totalCounterValue = cfg.Counter[counterIndex]
	self.curCounterValue = gTaskManager:GetTaskCounterValue(self.curTaskId, counterIndex)
	self.bindData.progressText = "[" .. self.curCounterValue .. "/" .. self.totalCounterValue .. "]"
	local comboList = combatCfg.ComboIDList

	if comboList then
		for i, v in ipairs(comboList) do
			local comboCfg = ComboConfig.GetConfig(v)

			if comboCfg then
				local data = {
					Id = v,
					comboName = comboCfg.ComboName
				}
				local pcList = comboCfg.InputidList
				local padList = comboCfg.PadInputidList
				local mobileList = comboCfg.MobileIconList
				self.targetList[i] = {
					pc = pcList,
					pad = padList,
					mobile = mobileList
				}

				if pcList then
					for j = 1, #pcList do
						self.inputMap[pcList[j]] = {
							pad = padList and padList[j],
							mobile = mobileList and mobileList[j]
						}
					end
				end

				data.finished = false

				table.insert(self.comboListData, data)
			else
				print_error("#NoCreateIssue 连招配置Id不存在", v)
			end
		end
	end

	self.bindData.comboList:SetSimpleList(#self.comboListData)
	self:NotifyComboState(true)
end

M.SetCurrentTaskData = function(self, data)
	local currentTaskType = self.currentTaskType

	if data then
		currentTaskType = data.CurrentTaskType
		self.curTaskIsFirst = data.IsFirstTime or false
	end

	if gTaskNodeManager.NowDoingTask[currentTaskType] ~= nil or gTaskNodeManager.NowDoingTaskLine[currentTaskType] ~= nil then
		self.NoTask(self)

		return
	end

	local tempTaskId = gTaskNodeManager.NowDoingTask[currentTaskType]
	self.curTaskId = tempTaskId
	self.currentTaskType = currentTaskType
	self.curTaskInfo, self.taskTargetList = gTaskNodeManager:GetTaskCounterInfo(self.curTaskId)
end

M.NotifyComboState = function(self, enable)
	if enable then
		local comboIdList = nil

		if self.curTaskInfo and self.curTaskInfo.SkillId then
			local cfg = TrainingConfig.GetConfig(self.curTaskInfo.SkillId)

			if cfg then
				comboIdList = cfg.ComboIDList
			end
		end

		gMessageManager:SendMessage(gEventConstants.ON_TASK_LISTEN_COMBO_STATE_CHANGE, {
			["F\\x90\\x8c\\x8fD"] = true,
			comboIdList = comboIdList
		})
	else
		gMessageManager:SendMessage(gEventConstants.ON_TASK_LISTEN_COMBO_STATE_CHANGE, {
			["F\\x90\\x8c\\x8fD"] = false
		})
	end
end

M.InitData = function(self)
	self.isDestroy = false
	self.curTaskId = 0
	self.curTaskInfo = nil
	self.totalCounterValue = 0
	self.curCounterValue = 0
	self.comboListData = {}
	self.targetList = {}
	self.inputMap = {}
	self.curComboSequence = {}
	self.hasCombo = false
	self.clearToken = 0
	self.pendingClear = false
end

M.OnClose = function(self)
end

M.OnActiveDeviceChange = function(self, device)
	self.gamepadMode = SGUI.GameDevice.KeyboardMouse <= device

	if self.bindData then
		self.bindData.comboList:SetSimpleList(#self.comboListData)
		self.bindData.inputList:SetSimpleList(#self.curComboSequence)
	end
end

M.GenMessageEvents = function(self)
	self.msgEvents = {
		[gEventConstants.ON_TASK_COMBO_PROGRESS_UPDATE] = self.CreateAction(self, "OnComboProgressUpdate"),
		[gEventConstants.ON_TASK_COMBO_PROGRESS_RESET] = self.CreateAction(self, "OnComboProgressReset"),
		[gEventConstants.CURRENT_TASK_CHANGE] = self.CreateAction(self, "OnCurrentChange")
	}
end

M.OnComboProgressUpdate = function(self, eventId, data)
	print_debug("Training combo OnComboProgressUpdate", data)

	if self.pendingClear then
		self.clearToken = self.clearToken + 1
		self.pendingClear = false
		self.hasCombo = false
	end

	if not self.hasCombo then
		self.hasCombo = true
		self.curComboSequence = {}

		self.bindData.inputList:SetSimpleList(0)
	end

	table.insert(self.curComboSequence, data)
	self.bindData.inputList:SetSimpleList(#self.curComboSequence)
end

M.OnComboProgressReset = function(self, eventId, data)
	print_debug("Training combo OnComboProgressReset", data)

	self.hasCombo = false

	if data ~= true then
		self.MarkMatchedComboFinished(self)
		self.ScheduleClearInputList(self)

		return
	end

	if self.pendingClear then
		return
	end

	self.ClearInputList(self)
end

M.ClearInputList = function(self)
	self.curComboSequence = {}
	self.pendingClear = false

	self.bindData.inputList:SetSimpleList(0)
end

M.ScheduleClearInputList = function(self)
	self.pendingClear = true
	self.clearToken = self.clearToken + 1
	local token = self.clearToken

	Timer.New(function ()
		if self.isDestroy then
			return
		end

		if self.clearToken == token then
			return
		end

		self.pendingClear = false
		self.curComboSequence = {}

		self.bindData.inputList:SetSimpleList(0)
	end, COMBO_FINISH_ANIM_TIME):Start()
end

M.MarkMatchedComboFinished = function(self)
	for i, target in pairs(self.targetList) do
		local item = self.comboListData[i]

		if item and not item.finished and self.IsSequenceMatch(self, self.curComboSequence, target.pc) then
			item.finished = true

			self.bindData.comboList:SetSimpleElement(i - 1, 0)

			return
		end
	end
end

M.IsSequenceMatch = function(self, seq, target)
	if not seq or not target or #seq == #target then
		return false
	end

	for i = 1, #target do
		if seq[i] == target[i] then
			return false
		end
	end

	return true
end

M.OnCurrentChange = function(self, eventId, data)
	if self.isDestroy then
		return
	end

	local taskInfo = gTaskManager:GetTaskInfo(self.curTaskId)

	if not taskInfo then
		return
	end

	local cfg = gTaskManager:GetTaskConfigInfo(self.curTaskId)
	local counterIndex = gTaskNodeManager:FindFirstCounterIndex(self.curTaskId)

	if cfg and counterIndex then
		self.totalCounterValue = cfg.Counter[counterIndex]
		self.curCounterValue = gTaskManager:GetTaskCounterValue(self.curTaskId, counterIndex)
		self.bindData.progressText = "[" .. self.curCounterValue .. "/" .. self.totalCounterValue .. "]"
	end

	if self.totalCounterValue <= 0 and self.totalCounterValue < self.curCounterValue then
		self:NoTask()
		gPanelManager:Close(gPanelId.TRAINING_COMBO_PANEL)
	end
end

M.RegisterWidget = function(self)
	self.bindData.comboList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderComboListItem)
	self.bindData.inputList.luaSimpleRenderItem = self.CreateAction(self, self.OnSimpleRenderInputListItem)
end

M.OnSimpleRenderInputListItem = function(self, btn, index)
	local store = self:GetStoreByWidget(btn)
	local pcInputId = self.curComboSequence[index + 1]
	local map = pcInputId and self.inputMap[pcInputId]

	self:SetInputIcon(store, pcInputId, map and map.pad, map and map.mobile)
end

M.SetInputIcon = function(self, store, pcInputId, padInputId, mobileIcon)
	if not store then
		return
	end

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		store.iconId = mobileIcon

		return
	end

	if self.gamepadMode then
		if not padInputId then
			return
		end

		local config = SGUIGamepadConfig.GetConfig(padInputId)

		if not config then
			return
		end

		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(config.ActionMap, config.ActionName)
		local buttonName = pathList.Count <= 0 and pathList[0] or nil

		if not string.is_null_or_empty(buttonName) then
			local gamepadCfg = self.buttonNameGamepadDic[buttonName]

			if gamepadCfg then
				local iconList = nil

				if gCS.LuaUtils.GetActiveDevice() ~= SGUI.GameDevice.PlayStation then
					iconList = gamepadCfg.PSButtonIcon
				else
					iconList = gamepadCfg.XBoxButtonIcon
				end

				store.iconId = iconList
			end
		end
	else
		if not pcInputId then
			return
		end

		local config = SGUIPCKeyConfig.GetConfig(pcInputId)

		if not config then
			return
		end

		local pathList = gCS.RebindMgr:GetBindingDisplayStrings(config.ActionMap, config.ActionName)
		local buttonName = pathList.Count <= 0 and pathList[0] or nil

		if not string.is_null_or_empty(buttonName) then
			local keyboardConfig = self.buttonNamePCDic[buttonName]

			if keyboardConfig then
				local iconList = keyboardConfig.GuideIcon
				store.iconId = iconList
			end
		end
	end
end

M.OnSimpleRenderComboListItem = function(self, btn, index)
	local data = self.comboListData[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		local target = self.targetList[index + 1]
		store.comboTargetList.luaSimpleRenderItem = self:CreateActionWithArgs(self.OnRenderComboTargetList, target)
		local count = target and target.pc and #target.pc or 0

		store.comboTargetList:SetSimpleList(count)

		store.modeCtrl = data.finished and 1 or 0
		store.title = data.comboName

		if data.finished then
			store.colorCtrl = 1
		else
			store.colorCtrl = 0
		end
	end
end

M.OnRenderComboTargetList = function(self, target, btn, index)
	local store = self.GetStoreByWidget(self, btn)

	if not target then
		return
	end

	local i = index + 1
	local pcInputId = target.pc and target.pc[i]
	local padInputId = target.pad and target.pad[i]
	local mobileIcon = target.mobile and target.mobile[i]

	self:SetInputIcon(store, pcInputId, padInputId, mobileIcon)
end
