-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSystem_DataUtils.lua
-- Decompiled from: 02293_MapSystem_DataUtils.lua_b8c5f9f35966.luajit

gMapSystem_DataUtils = gMapSystem_DataUtils or {}
local M = gMapSystem_DataUtils

M.OnLogin = function(self)
	self:ClearTableCache()
	self:ClearPlayerCache()
end

M.OnLogout = function(self)
	self:ClearTableCache()
	self:ClearPlayerCache()
end

M.ClearPlayerCache = function(self)
end

M.ClearTableCache = function(self)
	self._agentId2AgentTag = nil
end

M.GetAgentIdByAgentTag = function(self, agentTag)
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
