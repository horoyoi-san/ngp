local TaskConfig = LTConfig.TaskConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local TaskTabPanelConfig = LTConfig.TaskTabPanelConfig
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local M = {
	CanTaskShowInPanel = function (self, taskId, visible, hasAccept, isUnderWay, taskLineCfg)
		local cfg = TaskConfig.GetConfig(taskId)

		if cfg == nil then
			return
		end

		local titleCfg = TaskTitleConfig.GetConfig(cfg.Title)
		local inLinkMode = gLinkManager:CheckInLinkMode()

		if inLinkMode then
			if not titleCfg.IsLinkShield then
				return false
			end
		elseif titleCfg.TabType == TaskTitleConfig.TabTypeType.online then
			return false
		end

		if titleCfg.TabType == TaskTitleConfig.TabTypeType.none then
			return false
		end

		if hasAccept or isUnderWay then
			return true
		end

		return visible and not string.is_null_or_empty(taskLineCfg.UnlockDescription)
	end,
	EMPTYMODE = {
		WAIT_UNLOCK = 1,
		WAIT_ACCEPT = 0,
		NONE = 2
	},
	CanTaskShowInSearch = function (self, titleId, targetType)
		local titleCfg = TaskTitleConfig.GetConfig(titleId)
		local inLink = gLinkManager:CheckInLinkMode()

		if inLink and not titleCfg.IsLinkShield then
			return false
		end

		local tabType = titleCfg and titleCfg.TabType or -1

		if tabType == TaskTitleConfig.TabTypeType.online and not inLink then
			return false
		end

		if tabType == TaskTitleConfig.TabTypeType.none or tabType ~= targetType and targetType ~= -1 then
			return false
		end

		return true
	end
}

function M:GetMobileDefaultTemplateHeight(tabIndex, panelType)
	local panelIndex = 1
	panelIndex = not panelType and 1 or panelType + 1
	tabIndex = tabIndex + 1
	local cfg = TaskTabPanelConfig.GetConfig(tabIndex)

	if not cfg or not cfg.Title or #cfg.Title == 0 or panelIndex > #cfg.Title then
		return 0
	end

	local panelCfg = cfg.Title[panelIndex]

	if not panelCfg then
		return 0
	end

	return panelCfg.template
end

function M:GetMobileTaskPaneDefaultHeight(tabIndex, panelType)
	local panelIndex = 1
	panelIndex = not panelType and 1 or panelType + 1
	tabIndex = tabIndex + 1
	local cfg = TaskTabPanelConfig.GetConfig(tabIndex)

	if not cfg or not cfg.Title or #cfg.Title == 0 or panelIndex > #cfg.Title then
		return 0
	end

	local panelCfg = cfg.Title[panelIndex]
	local titleHeight = panelCfg.titleHeight
	local templateHeight = panelCfg.template
	local defaultTotalHeight = templateHeight * panelCfg.defaultCnt + titleHeight

	return defaultTotalHeight
end

function M:SendMobileTaskPanelChange(totalHeight)
	if gCS.LuaUtils.IsNonMobileAdaptive() then
		return
	end

	gMessageManager:SendMessage(gEventConstants.TASK_GUIDE_HEIGHT_CHANGE, 214)
end

function M:CanDoTask(taskId)
	return true
end

M.TaskGuideSubPanel = {
	Normal = 0,
	Delivery = 5,
	Cleaner = 4,
	Police = 2,
	Switch = 1,
	MapGuide = 3,
	None = -1
}

function M:OpenTaskGuideCurTab(type, data)
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):OpenTaskPanel(type, data)
end

function M:GetTaskGuideCurType()
	return gStoreManager:GetStoreGroup("CoreHudTaskGuideStore").curType
end

function M:CloseTaskGuideCurTab()
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):CloseTaskPanel()
end

function M:OpenNormalTaskPanel()
	self:OpenTaskGuideCurTab(self.TaskGuideSubPanel.Normal)
end

function M:HandleTaskGuideClose()
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):HandlePanelClose()
end

function M.CheckIsOnJobTask()
	if gPoliceJobManager:IsPanelShow() then
		return false
	end

	if gDeliveryTaskManager.isDeliveryJob then
		return false
	end

	return true
end

function M.TryShowNewestMainTaskGuide()
	gStoreManager:GetStoreGroup("CoreHudTaskGuideStore"):TryShowNewestMainTaskGuide()
end

function M.GetTaskEffectId(id)
	local cfg = TaskConfig.GetConfig(id)

	if cfg and gTaskManager.TaskEffectId[cfg.Title] then
		return gTaskManager.TaskEffectId[cfg.Title]
	end

	return gTaskManager.TaskEffectId[TaskTitle.Branch]
end

function M:CheckShowDeadPanel()
	local currentTask = gTaskManager:GetCurTask()
	local cfg = TaskConfig.GetConfig(currentTask)

	if not cfg then
		return true
	end

	if array.contains(cfg.Tags, TaskConfig.TagsType.DieNoFail) then
		return true
	end

	return false
end

gTaskUtils = M
