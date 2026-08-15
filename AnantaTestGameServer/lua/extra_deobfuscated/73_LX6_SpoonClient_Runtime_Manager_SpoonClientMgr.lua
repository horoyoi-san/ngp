local M = {
	ReleaseDestructibleEvent = function (self, instanceId, eventType)
		gSpoonClientMgr:ReleaseEventGlobal(gSpoonEventType.OnDestructibleEvent, {
			instanceId = instanceId,
			eventType = eventType
		})
	end,
	ReleaseContextEvent = function (self, instanceId, eventType, params)
		L50.L50App.Scene.SpoonClientMgr:ReleaseContextEvent(instanceId, eventType, params)
	end
}

function M:ReleaseContextEventMessageTrigger(instanceId, event)
	M:ReleaseContextEvent(instanceId, gSpoonEventType.MessageTrigger, {
		message = event
	})
end

function M:TryCallInnerSignal(instanceId, signal)
	self:ReleaseContextEvent(instanceId, gSpoonEventType.OnReceiveSignal, {
		signalKey = signal,
		entityInstanceId = instanceId
	})
end

function M:ReleaseEventGlobal(eventType, params)
	L50.L50App.Scene.SpoonClientMgr:ReleaseEventGlobal(eventType, params)
end

gSpoonClientMgr = M
