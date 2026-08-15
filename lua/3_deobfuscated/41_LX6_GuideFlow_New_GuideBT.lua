C_GuideBT = DefClass("C_GuideBT", C_GuideBT)
local M = C_GuideBT

function M:ctor()
	self.behaviours = {}
	self.root = nil
	self.lastRunningActions = {}
	self.runningActions = {}
	self.finishByBT = false
	self.blackboard = {}
end

function M:SetRoot(root)
	self.root = root
end

function M:DoTick()
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
			node:OnExitRunning()
		end
	end

	for guid, node in pairs(self.runningActions) do
		if not self.lastRunningActions[guid] then
			node:OnEnterRunning()
		end
	end

	for guid, node in pairs(self.runningActions) do
		node:Run()
	end

	if enableDebug then
		if not self.debugNodeCache then
			self.debugNodeCache = self:BuildDebugNodeCache(self.root)
		end

		if self.debugNodeCache then
			for _, node in ipairs(self.debugNodeCache) do
				local state = node.cachedState or gGuideNodeState.Ready

				table.insert(debugInfo.executingNodes, {
					guid = node.guid,
					state = state
				})
			end
		else
			debugInfo.executingNodes = {}
		end

		gNewGuideMgr:UpdateDebugInfo(debugInfo)
	end
end

function M:RunNode(node)
	self.runningActions[node.guid] = node
end

function M:PerformQuit()
	self.finishByBT = true
end

function M:Exit()
	self.isExit = true

	for _, node in pairs(self.runningActions) do
		node:OnExitRunning()
	end
end

function M:BuildDebugNodeCache(cur, nodes)
	nodes = nodes or {}

	if not cur then
		return nodes
	end

	table.insert(nodes, cur)

	if cur.children then
		for _, child in ipairs(cur.children) do
			self:BuildDebugNodeCache(child, nodes)
		end
	end

	return nodes
end
