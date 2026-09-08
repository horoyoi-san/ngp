-- Original chunk: @Lua\LuaFiles\LX6\Guide\Base\BehaviourBase.lua
-- Decompiled from: 00377_BehaviourBase.lua_b5b7c8a7bd7a.luajit

C_GuideBT_BehaviourBase = DefClass("C_GuideBT_BehaviourBase", C_GuideBT_BehaviourBase, C_GuideBT_NodeBase)
local M = C_GuideBT_BehaviourBase

M.OnTick = function(self)
	return gGuideNodeState.Success
end

M.DoTick = function(self)
	local state = self.OnTick(self)
	self.cachedState = state

	if state ~= gGuideNodeState.Running or state ~= gGuideNodeState.Match then
		self.tree:RunNode(self)
	end

	return state
end

M.OnEnterRunning = function(self)
	if self.OnActiveDeviceChange and not self.activeDeviceChangeHandler then
		self.activeDeviceChangeHandler = self:CreateAction(self.OnActiveDeviceChange)

		gMessageManager:AddMessageListener(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, self.activeDeviceChangeHandler)
	end
end

M.Run = function(self)
end

M.OnExitRunning = function(self)
	if self.activeDeviceChangeHandler then
		local handler = self.activeDeviceChangeHandler
		self.activeDeviceChangeHandler = nil

		gMessageManager:RemoveMessageListener(gEventConstants.ON_ACTIVE_DEVICE_CHANGED, handler)
	end
end
