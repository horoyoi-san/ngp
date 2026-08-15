local M = {
	RunCode = function (self, code, funcScript)
		local f = assert(load(code, nil, "t", funcScript))

		if f then
			local status, err = xpcall(f, tolua.traceback)

			return status, err
		end

		return false
	end
}

function M:RunCodeByTask(code, taskId)
	gDialogScriptFunc.currentTaskId = taskId
	local status, err = self:RunCode(code, gDialogScriptFunc)

	if not status then
		print_error("M.RunTaskFunc ", code, "Failed: ", err, "Status:", status, "taskId: ", taskId)
	end

	gDialogScriptFunc.currentTaskId = 0
end

function M:RunFunc(code, dialogId, npc, isNextAction, isClick, data)
	gDialogScriptFunc.currentNpc = npc
	gDialogScriptFunc.currentDialogId = dialogId
	gDialogScriptFunc.isNextAction = isNextAction
	gDialogScriptFunc.isClick = isClick or false
	gDialogScriptFunc.Data = data
	local status, result = self:RunCode(code, gDialogScriptFunc)

	if not status then
		print_error("M.RunFunc ", code, "Failed: ", tostring(result), "dialogId: ", tostring(dialogId))
	end

	gDialogScriptFunc.currentNpc = nil

	return result
end

function M:RunInteractFunc(str, dialogId, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		print_error("RunInteractFunc unit not exist", str, pid, gRaidDataManager.RaidId, gCS.MyPlayerManager.PlayerUnit.LocalPosition, gTaskNodeManager.NowDoingTask and gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] or "")

		return
	end

	if string.starts_with(str, "#") then
		str = string.sub(str, 2)
	end

	self:RunFunc(str, dialogId, unit)
end

gDialogAction = M
