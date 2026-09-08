-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\TaskMapPrefabResolver.lua
-- Decompiled from: 00977_TaskMapPrefabResolver.lua_c52a8b77d271.luajit

local M = {
	Resolve = function (raidId, indoorId)
		if indoorId == 0 then
			return "", ""
		end

		local taskId = gTaskManager:GetCurTask()

		if taskId ~= 0 then
			return "", ""
		end

		local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

		if not taskCfg or taskCfg.RelatedRaid == raidId then
			return "", ""
		end

		return taskCfg.MiniMapPath, taskCfg.BigMapPath
	end
}

return M
