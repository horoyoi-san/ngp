-- Original chunk: @Lua\LuaFiles\LX6\SpoonClient\Runtime\Manager\SpoonClientMgr.lua
-- Decompiled from: 00277_SpoonClientMgr.lua_71c268268d25.luajit

local M = {}

M.ReleaseDestructibleEvent = function(self, instanceId, eventType)
	if not self.CheckSpoonClient(self) then
		return
	end

	gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnDestructibleEvent, {
		instanceId = instanceId,
		eventType = eventType
	})
end

M.ReleaseContextEvent = function(self, instanceId, clientGraphType, eventType, params)
	if not self.CheckSpoonClient(self) then
		return
	end

	L50.L50App.Scene.SpoonClientMgr:ReleaseContextEvent(instanceId, clientGraphType, eventType, params)
end

M.ReleaseContextEventMessageTrigger = function(self, instanceId, clientGraphType, event)
	if not self.CheckSpoonClient(self) then
		return
	end

	self.ReleaseContextEvent(self, instanceId, clientGraphType, gSpoonEventType.MessageTrigger, {
		message = event
	})
end

M.TryCallInnerSignal = function(self, instanceId, clientGraphType, signal)
	if not instanceId or not self.CheckSpoonClient(self) then
		return
	end

	self.ReleaseContextEvent(self, instanceId, clientGraphType, gSpoonEventType.OnReceiveSignal, {
		signalKey = signal,
		entityInstanceId = instanceId
	})
end

M.ReleaseEventGlobal = function(self, eventType, params)
	if self.CheckSpoonClient(self) then
		L50.L50App.Scene.SpoonClientMgr:ReleaseEventGlobal(eventType, params)
	end
end

M.CheckSpoonClient = function(self)
	return L50.L50App.Scene == nil and L50.L50App.Scene.SpoonClientMgr == nil
end

gSpoonClientMgr = M
