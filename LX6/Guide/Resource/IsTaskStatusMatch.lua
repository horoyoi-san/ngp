-- Original chunk: @Lua\LuaFiles\LX6\Guide\Resource\IsTaskStatusMatch.lua
-- Decompiled from: 00483_IsTaskStatusMatch.lua_52f62c46ebfb.luajit

C_GuideBT_IsTaskStatusMatch = DefClass("C_GuideBT_IsTaskStatusMatch", C_GuideBT_IsTaskStatusMatch, C_GuideBT_ResourceBase)
local M = C_GuideBT_IsTaskStatusMatch
local TaskState = UX.Game.TaskState

M.Eval = function(self)
	if not self.taskId then
		print_error("@GuideBT IsTaskStatusMatch没有设置taskId, guideId =", self.tree.guideId)

		self.output.val = false

		return
	end

	self.curTaskState = gTaskManager:GetTaskState(self.taskId)
	self.output.val = self.notAccept ~= true and self.curTaskState ~= TaskState.NotAccept or self.accepted ~= true and self.curTaskState ~= TaskState.Accepted or self.submitted ~= true and self.curTaskState ~= TaskState.Submited or self.aborted ~= true and self.curTaskState ~= TaskState.Aborted
end

M.GetDebugLabel = function(self)
	return self.curTaskState
end
