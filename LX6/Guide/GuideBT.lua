-- Original chunk: @Lua\LuaFiles\LX6\Guide\GuideBT.lua
-- Decompiled from: 00364_GuideBT.lua_9684ef702c8e.luajit

C_GuideBT = DefClass("C_GuideBT", C_GuideBT)
local M = C_GuideBT

M.ctor = function(self)
	self.behaviours = {}
	self.root = nil
	self.nodes = {}
	self.allResNode = {}
	self.allPanelNode = {}
	self.lastRunningActions = {}
	self.runningActions = {}
	self.finishByBT = false
	self.blackboard = {}
	self.debugCounterDirty = false
end

M._RegisterNode = function(self, node)
	if not node or self.nodes[node.guid] then
		return
	end

	self.nodes[node.guid] = node
	node.tree = self

	node.OnCreate(node)
end

M.RegisterBehaviourNode = function(self, node)
	self._RegisterNode(self, node)
end

M.RegisterResourceNode = function(self, node)
	self._RegisterNode(self, node)

	if node then
		self.allResNode[node.guid] = node
	end
end

M.RegisterPanelNode = function(self, node)
	if not node then
		return
	end

	self.allPanelNode[node.guid] = node
end

M.SetRoot = function(self, root)
	self.root = root
end

M.DoTick = function(self)
	if self.isExit then
		return
	end

	local enableDebug = gNewGuideMgr.enableDebug
	local t = self.lastRunningActions
	self.lastRunningActions = self.runningActions
	self.runningActions = t

	table.clear(self.runningActions)

	local debugInfo = nil

	if enableDebug then
		debugInfo = {
			id = self.guideId,
			counterId = self.counterId,
			executingNodes = {}
		}
	end

	self.root:DoTick()

	for guid, node in pairs(self.lastRunningActions) do
		if not self.runningActions[guid] then
			node.OnExitRunning(node)
		end
	end

	for guid, node in pairs(self.runningActions) do
		if not self.lastRunningActions[guid] then
			node.OnEnterRunning(node)
		end
	end

	for guid, node in pairs(self.runningActions) do
		node.Run(node)
	end

	if enableDebug then
		if not self.debugNodeCache then
			self.debugNodeCache = self.BuildDebugNodeCache(self, self.root)

			for _, resNode in pairs(self.allResNode) do
				table.insert(self.debugNodeCache, resNode)
			end
		end

		if self.debugNodeCache then
			for _, node in ipairs(self.debugNodeCache) do
				local state = node.cachedState or gGuideNodeState.Ready
				local debugText = nil

				if node.GetDebugLabel then
					local ok, res = xpcall(node.GetDebugLabel, tolua.traceback, node)

					if ok and res == nil then
						debugText = tostring(res)
					end
				end

				if string.is_null_or_empty(debugText) then
					table.insert(debugInfo.executingNodes, {
						guid = node.guid,
						state = state
					})
				else
					table.insert(debugInfo.executingNodes, {
						guid = node.guid,
						state = state,
						debugText = debugText
					})
				end
			end
		else
			debugInfo.executingNodes = {}
		end

		self:TryAppendCounterDebugInfo(debugInfo)
		gNewGuideMgr:UpdateDebugInfo(debugInfo)
	end
end

M.RunNode = function(self, node)
	self.runningActions[node.guid] = node
end

M.MarkCounterDirty = function(self)
	self.debugCounterDirty = true
end

M.GetOrCreateCounterDic = function(self)
	local blackboard = self.blackboard

	if not blackboard then
		blackboard = {}
		self.blackboard = blackboard
	end

	local counterDic = blackboard.counterDic

	if not counterDic then
		counterDic = {}
		blackboard.counterDic = counterDic
	end

	return counterDic
end

M.GetCounterValue = function(self, counterId)
	if string.is_null_or_empty(counterId) then
		return 0
	end

	local counterDic = self.blackboard and self.blackboard.counterDic

	if not counterDic then
		return 0
	end

	return counterDic[counterId] or 0
end

M.SetCounterValue = function(self, counterId, value)
	if string.is_null_or_empty(counterId) then
		return 0
	end

	local counterDic = self.GetOrCreateCounterDic(self)
	counterDic[counterId] = value

	self.MarkCounterDirty(self)

	return value
end

M.AddCounterValue = function(self, counterId, delta)
	if string.is_null_or_empty(counterId) then
		return 0
	end

	local nextValue = self.GetCounterValue(self, counterId) + delta

	return self.SetCounterValue(self, counterId, nextValue)
end

M.TryAppendCounterDebugInfo = function(self, debugInfo)
	if not debugInfo or not self.debugCounterDirty then
		return
	end

	self.debugCounterDirty = false
	local counterDic = self.blackboard and self.blackboard.counterDic

	if not counterDic then
		debugInfo.counterInfo = {}

		return
	end

	local snapshot = {}

	for key, value in pairs(counterDic) do
		snapshot[key] = value
	end

	debugInfo.counterInfo = snapshot
end

M.PerformQuit = function(self)
	self.finishByBT = true
end

M.Exit = function(self)
	self.isExit = true

	for _, node in pairs(self.runningActions) do
		node.OnExitRunning(node)
	end

	for _, node in pairs(self.nodes) do
		node.OnDestroy(node)
	end

	table.clear(self.nodes)
	table.clear(self.allResNode)
	table.clear(self.allPanelNode)
end

M.BuildDebugNodeCache = function(self, cur, nodes)
	nodes = nodes or {}

	if not cur then
		return nodes
	end

	table.insert(nodes, cur)

	if cur.children then
		for _, child in ipairs(cur.children) do
			self.BuildDebugNodeCache(self, child, nodes)
		end
	end

	return nodes
end
