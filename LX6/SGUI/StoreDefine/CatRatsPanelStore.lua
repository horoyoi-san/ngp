-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\CatRatsPanelStore.lua
-- Decompiled from: 01643_CatRatsPanelStore.lua_9f50a8c2ef70.luajit

C_CatRatsPanelStore = DefClass("C_CatRatsPanelStore", C_CatRatsPanelStore, C_StoreGroup)
GroupName2Class.CatRatsPanelStore = C_CatRatsPanelStore
local M = C_CatRatsPanelStore
local TextCommonTextConfig = LTConfig.TextCommonTextConfig

M.ctor = function(self)
	self.p = nil
	self.isStart = false
	self.isInitialized = false
end

M.DefineAllVariables = function(self)
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
end

M.DefineAllEnumsAutoGen = function(self)
end

M.ClearAllEnumsAutoGen = function(self)
end

M.OnAwake = function(self)
	self.DefineAllVariables(self)
	self.GenMessageEvents(self)
	self.RegisterWidget(self)
end

M.OnEnable = function(self)
	self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
end

M.OnStart = function(self)
	self.isStart = true

	if self.isStartCb then
		self.isStartCb()

		self.isStartCb = nil
	end
end

M.Init = function(self)
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	self.bindData.Online = 1

	self.SetAllRats(self)
	self.RefreshTaskInfo(self)
end

M.OnDisable = function(self)
end

M.OnDestroy = function(self)
end

M.OnGroupEnable = function(self)
end

M.OnGroupDisable = function(self)
end

M.OnShow = function(self, data)
	if not gHideAndSeekManager.panelIsRegister then
		gHideAndSeekManager.panelIsRegister = true
	end

	gHideAndSeekManager:ExecuteCallback()

	if not self.isStart then
		self.isStartCb = function()
			self:Init()
		end
	else
		self.Init(self)
	end
end

M.RefreshTaskInfo = function(self)
	self.RefreshCurrentTaskDes(self)

	self.bindData.HideDes = 1
end

M.RefreshCurrentTaskDes = function(self)
	if not self.p then
		self.p = gStoreManager:GetStoreGroup("CoreHudTaskGuideStore")
	end

	if not self.p.curTaskInfo then
		return
	end

	local des = ""

	if self.p.curTaskInfo.CounterDesId == 0 then
		local textCfg = TextCommonTextConfig.GetConfig(self.p.curTaskInfo.CounterDesId)

		if textCfg then
			des = textCfg.Text
		end
	else
		des = self.p.curTaskInfo.WorkDescription or ""
	end

	if self.p.isInTaskRaid then
		self.SwitchTaskInfo(self, des .. self.GetTaskCounter(self))
	else
		self:SwitchTaskInfo(self.p.curTaskInfo.EventObjective or "")
	end

	if gTaskManager:IsTaskInRiskControl(self.p.curTaskInfo.TaskId) then
		self.SwitchTaskInfo(self, LTConfig.TextScriptTextConfig.GetConfig(89900961).Text)
	end
end

M.SwitchTaskInfo = function(self, taskInfo)
	self.bindData.nTaskInfo = taskInfo
end

M.GetTaskCounter = function(self, watchingTaskInfo)
	local taskInfo = self.p.curTaskInfo

	if watchingTaskInfo then
		taskInfo = watchingTaskInfo
	end

	local taskCounter = ""

	if self.p.isShowTaskCounter and taskInfo then
		local nowCounterValue = taskInfo.CounterValue
		local allCounterValue = 0
		local cfg = gTaskManager:GetTaskConfigInfo(self.p.curTaskId)
		local isShowAllCounter = array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllCounter)

		if taskInfo.totalValue and not isShowAllCounter then
			allCounterValue = taskInfo.totalValue
		else
			for i = 1, #cfg.Counter do
				local couterNum = cfg.Counter[i]
				allCounterValue = allCounterValue + couterNum
			end
		end

		if isShowAllCounter then
			local tasks = gTaskManager:GetTaskInfo(self.p.curTaskId)
			nowCounterValue = 0

			for i = 1, #tasks.Counters do
				nowCounterValue = tasks.Counters[i].Value + nowCounterValue
			end
		end

		if not taskInfo.NotShowProgress or not not isShowAllCounter then
			taskCounter = "[" .. nowCounterValue .. "/" .. allCounterValue .. "]"
		end
	end

	return taskCounter
end

M.SetAllRats = function(self)
	self.bindData.ratsList:SetActive(true)
	self.bindData.ratsList:SetSimpleList(#gHideAndSeekManager.ratsData)
end

M.OnClose = function(self)
	gHideAndSeekManager.panelIsRegister = false
end

M.OnActiveDeviceChange = function(self, device)
end

M.GenMessageEvents = function(self)
end

M.RegisterWidget = function(self)
	self.bindData.ratsList.luaSimpleRenderItem = self.CreateAction(self, "OnSimpleRenderRatsList")
end

M.OnSimpleRenderRatsList = function(self, btn, index)
	local data = gHideAndSeekManager.ratsData[index + 1]
	local store = self.GetStoreByWidget(self, btn)

	if store and data then
		store.type = gHideAndSeekManager.isCat and 0 or 1
		store.mode = data.alive and 0 or 1
	end
end
