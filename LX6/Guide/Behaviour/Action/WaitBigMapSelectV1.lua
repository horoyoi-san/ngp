-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitBigMapSelectV1.lua
-- Decompiled from: 00442_WaitBigMapSelectV1.lua_20a85c79e1cc.luajit

C_GuideBT_WaitBigMapSelectV1 = DefClass("C_GuideBT_WaitBigMapSelectV1", C_GuideBT_WaitBigMapSelectV1, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitBigMapSelectV1

M.OnTick = function(self)
	if not self._selected then
		return gGuideNodeState.Running
	else
		self._selected = nil

		return gGuideNodeState.Success
	end
end

M.OnEnterRunning = function(self)
	self._selected = nil

	self.AddHandler(self)
end

M.OnExitRunning = function(self)
	self.ClearHandler(self)
end

M.AddHandler = function(self)
	if self._handler then
		return
	end

	self._handler = function(eventId, param)
		if param and param.gpsId ~= self.gpsId then
			self._selected = true
		end
	end

	gMessageManager:AddMessageListener(gEventConstants.ON_BIG_MAP_SELECT, self._handler)
end

M.ClearHandler = function(self)
	if not self._handler then
		return
	end

	gMessageManager:RemoveMessageListener(gEventConstants.ON_BIG_MAP_SELECT, self._handler)

	self._handler = nil
end
