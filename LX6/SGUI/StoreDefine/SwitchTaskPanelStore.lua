-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\SwitchTaskPanelStore.lua
-- Decompiled from: 01346_SwitchTaskPanelStore.lua_e34b81550f3c.luajit

C_SwitchTaskPanelStore = DefClass("C_SwitchTaskPanelStore", C_SwitchTaskPanelStore, C_StoreGroup)
GroupName2Class.SwitchTaskPanelStore = C_SwitchTaskPanelStore
local M = C_SwitchTaskPanelStore
local TaskConfig = LTConfig.TaskConfig
local GameConfig = LTConfig.GameConfig
local TaskEventConfig = LTConfig.TaskEventConfig

M.ctor = function(self)
end

M.OnAwake = function(self)
	if self.bindData.sToTaskBtn then
		self.bindData.sToTaskBtn.luaClick = self.CreateAction(self, "OnToSetCurrentTask")
	end

	if self.bindData.heightBox then
		self.bindData.heightBox.luaSizeChanged = self.CreateAction(self, "OnSizeChanged")
	end
end

M.OnSizeChanged = function(self)
	self.CalculateHeightBox(self)
end

M.CalculateHeightBox = function(self)
	if not self.bindData.heightBox then
		return
	end

	local height = self.bindData.heightBox:GetTargetHeight()
	local heightBoxOffsetY = math.abs(self.bindData.heightBox.rectTransform.anchoredPosition.y)

	gTaskUtils:SetBloodBarPosition(heightBoxOffsetY + height)
	gTaskUtils:SendMobileTaskPanelChange(height + gTaskUtils:GetGameBarPanelHeight())
end

M.OnShow = function(self, data)
	self.taskId = data.taskId

	self.SetSwitchInfo(self)

	if not gCS.LuaUtils.IsNonMobileAdaptive() then
		self.CalculateHeightBox(self)
	end

	Timer.New(function ()
		gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):HandlePanelClose()
	end, GameConfig.HideTemporaryTaskTime):Start()
end

M.OnEnable = function(self)
end

M.OnDisable = function(self)
	self.taskId = nil

	gTaskUtils:SendMobileTaskPanelChange(0)
end

M.OnToSetCurrentTask = function(self)
	self.ToSetCurrentTask(self, self.taskId)
end

M.ToSetCurrentTask = function(self, taskId)
	slot2 = gTaskManager

	slot2:SetCurrentTask(taskId, function ()
		local cfg = TaskConfig.GetConfig(taskId)

		if cfg and cfg.RelatedRaid == gRaidDataManager.RaidId then
			gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TargetNotCurrentScene)
		end
	end)
end

M.SetSwitchInfo = function(self)
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

M.LanguageChange = function(self)
	self.SetSwitchInfo(self)
end
