local TaskConfig = LTConfig.TaskConfig
local TaskChapterConfig = LTConfig.TaskChapterConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
C_TaskTriggerPanelStore = DefClass("C_TaskTriggerPanelStore", C_TaskTriggerPanelStore, C_StoreGroup)
GroupName2Class.TaskTriggerPanelStore = C_TaskTriggerPanelStore
local M = C_TaskTriggerPanelStore
local WaitTipAnimName = "S_vx_TaskTipPanel_Open02"

function M:ctor()
	return
end

function M:Show(pData, widget)
	local data = pData.Param
	local taskId = data.taskId
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)

	if not cfg then
		print_error("该弹窗唤起来源未传入taskId或是taskId存在但找不到TaskConfig， taskId为：", taskId)
		gPanelManager:Close(gPanelId.S_HUD_TIPS)

		return
	end

	local sIconId = gTaskManager.TaskSIconId[cfg.Title]
	local eventInfo = gTaskNodeManager:GetTaskLineByTask(taskId)
	local taskName = eventInfo.EventName
	local chapterConfig = TaskChapterConfig.GetConfig(eventInfo.Chapter)
	local chapterName = chapterConfig and chapterConfig.ChapterName or TaskConfig.TaskStartInfo
	local taskTitle = TaskConfig.GetConfig(taskId).Title
	local taskRecordIcon = TaskTitleConfig.GetConfig(taskTitle).SQuestIcon
	local taskTabType = TaskTitleConfig.GetConfig(taskTitle).TabType
	local tabNames = TaskConfig.TaskListTabName
	local tabName = ""

	for _, pair in ipairs(tabNames) do
		if pair.TabType == taskTabType then
			tabName = pair.TabName

			break
		end
	end

	local store = self:GetStoreByWidget(widget)
	store.taskIcon = sIconId
	store.taskName = taskName
	store.taskCtrl = data.taskState - 1
	store.taskType = tabName
	store.taskChapter = chapterName
	store.taskRecordIcon = taskRecordIcon

	if data.taskState == gTaskManager.TaskState.Wait then
		store.openAnim:Stop()
		store.openAnim:Play(WaitTipAnimName)
	end
end
