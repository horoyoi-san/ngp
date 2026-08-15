gMapSystem_DataUtils = gMapSystem_DataUtils or {}
local M = gMapSystem_DataUtils

function M:OnLogin()
	self:ClearTableCache()
	self:ClearPlayerCache()
end

function M:OnLogout()
	self:ClearTableCache()
	self:ClearPlayerCache()
end

function M:ClearPlayerCache()
	return
end

function M:ClearTableCache()
	self._agentId2AgentTag = nil
end

function M:GetAgentIdByAgentTag(agentTag)
	if not self._agentId2AgentTag then
		self._agentId2AgentTag = {}

		for i = 0, LTConfig.AgentConfig.count - 1 do
			local cfg = LTConfig.AgentConfig.LoadAt(i)
			local agentTag = cfg.AgentSpecificType
			self._agentId2AgentTag[agentTag] = cfg.Id
		end
	end

	return self._agentId2AgentTag[agentTag]
end

return M
