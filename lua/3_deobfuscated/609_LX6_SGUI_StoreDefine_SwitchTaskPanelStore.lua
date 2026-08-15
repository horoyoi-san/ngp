C_SwitchTaskPanelStore = DefClass("C_SwitchTaskPanelStore", C_SwitchTaskPanelStore, C_StoreGroup)
GroupName2Class.SwitchTaskPanelStore = C_SwitchTaskPanelStore
local M = C_SwitchTaskPanelStore
local TaskConfig = LTConfig.TaskConfig
local GameConfig = LTConfig.GameConfig
local TaskEventConfig = LTConfig.TaskEventConfig

function M:ctor()
	self.templateHeight = gTaskUtils:GetMobileDefaultTemplateHeight(gTaskUtils.TaskGuideSubPanel.Switch)
	self.defaultHeight = gTaskUtils:GetMobileTaskPaneDefaultHeight(gTaskUtils.TaskGuideSubPanel.Switch)
end

function M:OnAwake()
	if self.bindData.sToTaskBtn then
		self.bindData.sToTaskBtn.luaClick = self:CreateAction("OnToSetCurrentTask")
	end
end

function M:OnShow(data)
	self.taskId = data.taskId

	self:SetSwitchInfo()
	gTaskUtils:SendMobileTaskPanelChange(self.defaultHeight)
	Timer.New(function ()
		gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):HandlePanelClose()
	end, GameConfig.HideTemporaryTaskTime):Start()
end

function M:OnEnable()
	return
end

function M:OnDisable()
	self.taskId = nil

	gTaskUtils:SendMobileTaskPanelChange(0)
end

function M:OnToSetCurrentTask()
	self:ToSetCurrentTask(self.taskId)
end

function M:ToSetCurrentTask(taskId)
	gTaskManager:SetCurrentTask(taskId, function ()
		local cfg = TaskConfig.GetConfig(taskId)

		if cfg and cfg.RelatedRaid ~= gRaidDataManager.RaidId then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TargetNotCurrentScene)
		end
	end)
end

function M:SetSwitchInfo()
	local tempTaskCfg = TaskConfig.GetConfig(self.taskId)

	if tempTaskCfg then
		self.bindData.cSwitch = gTaskManager.TaskColor[tempTaskCfg.Title] and Color.NewByStr(gTaskManager.TaskColor[tempTaskCfg.Title])
	end

	local eventInfo = gTaskNodeManager:GetTaskLineByTask(self.taskId)

	if table.isNilOrEmpty(eventInfo) then
		print_error("当前临时弹出任务找不到任何taskEvent据信息  taskId = " .. self.taskId)

		return
	end

	local cfg = TaskEventConfig.GetConfig(eventInfo.TaskLineId)
	local des = gUtils:GetSpecialDescription(cfg.NewTaskInfo, true) or ""
	local eventName = cfg.EventName
	des = des or ""
	self.bindData.sTaskInfo = des
	self.bindData.sEventName = eventName
end

function M:LanguageChange()
	self:SetSwitchInfo()
end
