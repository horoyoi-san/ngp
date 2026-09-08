-- Original chunk: @Lua\LuaFiles\LX6\GUI\Clue\ClueManager.lua
-- Decompiled from: 00566_ClueManager.lua_10bafe8171aa.luajit

local TaskState = UX.Game.TaskState
local M = {
	["$2\\xe1r\\x9c\\xd9!\\xa5\\xe8\\xc0\\xe7}\\xff"] = 0,
	["N\\xa8\\x95\\xb8գ\\xd1>\\xbb\\xb7\""] = false
}

local FindPreTask = function(Graph, searchId, rawId)
end

M.OnInit = function(self)
	if not self.IsRegisterEvents then
		slot1 = gMessageManager

		slot1:AddMessageListener(gEventConstants.TASK_STATE_CHANGED, self.OnTaskSubmitted)

		slot1 = gMessageManager

		slot1:AddMessageListener(gEventConstants.L50_AFTER_SWITCH_SCENE, function ()
			self:OnSwitchScenes()
		end)

		self.IsRegisterEvents = true
	end

	self.InitTaskInfo(self)
end

M.InitTaskInfo = function(self)
	self.RaidTaskInfo = {}
	self.TaskIdToClueConfig = {}
	local tempGraph = {}
	local queue = {}
	local index = 1

	for raidId, Graph in pairs(tempGraph) do
		local taskInfo = {}

		table.clear(queue)

		index = 1

		for id, v in pairs(Graph) do
			FindPreTask(Graph, id, id)

			if v.ind ~= 0 then
				table.insert(queue, {
					["G\\x83\\x9a\\xaaE"] = 0,
					id = id
				})
			end
		end

		while index < #queue do
			local now = queue[index]

			for _, nextId in ipairs(Graph[now.id].edge) do
				Graph[nextId].ind = Graph[nextId].ind - 1

				if Graph[nextId].ind ~= 0 then
					table.insert(queue, {
						id = nextId,
						sortId = now.sortId + 1
					})
				end
			end

			table.insert(taskInfo, {
				id = now.id,
				cfg = Graph[now.id].cfg,
				sortId = now.sortId
			})

			index = index + 1
		end

		table.sort(taskInfo, function (a, b)
			if a.sortId ~= b.sortId then
				return b.id <= a.id
			end

			return b.sortId <= a.sortId
		end)

		self.RaidTaskInfo[raidId] = taskInfo
	end
end

M.GetTaskInfoByRaidId = function(self, raidId)
	return self.RaidTaskInfo[raidId] or {}
end

M.OnTaskSubmitted = function(_, data)
	if data[2] ~= TaskState.Submited and M.TaskIdToClueConfig[data[1]] then
		local clueCfg = M.TaskIdToClueConfig[data[1]]

		if gRaidDataManager.RaidId ~= clueCfg.RaidId then
			M.UnreadNumInRaid = M.UnreadNumInRaid + 1
		end
	end
end

M.OnLogin = function(self)
	self.ClueReadInfo = gUIUtils:LoadJsonToLuaTableWithPid("ClueReadInfo")

	if not self.ClueReadInfo then
		self.ClueReadInfo = {}

		gUIUtils:SaveLuaTableToJsonWithPid("ClueReadInfo", self.ClueReadInfo)
	end
end

M.OnSwitchScenes = function(self)
	local raidId = gRaidDataManager.RaidId

	if self.lastRaidId ~= raidId then
		return
	end

	self.lastRaidId = raidId
	self.UnreadNumInRaid = 0
	local taskInfo = self.GetTaskInfoByRaidId(self, raidId)

	for _, v in ipairs(taskInfo) do
		local cfg = v.cfg

		if not self.ClueReadInfo[tostring(cfg.Id)] and gTaskManager:IsTaskSubmitted(cfg.TaskId) then
			self.UnreadNumInRaid = self.UnreadNumInRaid + 1
		end
	end
end

M.OnBeforeSwitchScene = function(self, switchType)
	if switchType == gSwitchSceneType.KickToLogin then
		return
	end

	self.ClueReadInfo = nil
	self.UnreadNumInRaid = 0
end

gClueManager = M
