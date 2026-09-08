-- Original chunk: @Lua\LuaFiles\LX6\GUI\Dialog\DialogAction.lua
-- Decompiled from: 00508_DialogAction.lua_afa7057426b7.luajit

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

M.RunCodeByTask = function(self, code, taskId)
	gDialogScriptFunc.currentTaskId = taskId
	local status, err = self.RunCode(self, code, gDialogScriptFunc)

	if not status then
		print_error("M.RunTaskFunc ", code, "Failed: ", err, "Status:", status, "taskId: ", taskId)
	end

	gDialogScriptFunc.currentTaskId = 0
end

M.RunFunc = function(self, code, dialogId, npc, isNextAction, isClick, data)
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

M.RunInteractFunc = function(self, str, dialogId, pid)
	local unit = gCS.SceneDataMgr.GetUnit(pid)

	if not unit then
		print_error("RunInteractFunc unit not exist", str, pid, gRaidDataManager.RaidId, gCS.MyPlayerManager.PlayerUnit.LocalPosition, gTaskNodeManager.NowDoingTask and gTaskNodeManager.NowDoingTask[gTaskManager.CurrentTaskType.Task1] or "")

		return
	end

	if string.starts_with(str, "#") then
		str = string.sub(str, 2)
	end

	self.RunFunc(self, str, dialogId, unit)
end

M.FireLifeSchedulePanelStart = function(self, pid)
	LifeScheduleInteract:FirePanelStart(nil, pid)
end

M.FireLifeSchedulePanelEnd = function(self, pid, reason)
	LifeScheduleInteract:FirePanelEnd(nil, reason, pid)
end

M.FireLifeSchedulePanelTransfer = function(self, pid)
	LifeScheduleInteract:FirePanelTransfer(nil, pid)
end

gDialogAction = M
