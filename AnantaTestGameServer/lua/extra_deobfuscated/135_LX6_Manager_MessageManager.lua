gMessageManager = {
	msgHandlerBudget = 512,
	msgIds = {},
	msgHandlers = {},
	AddMessageListener = function (self, eventId, handler)
		local link = self.msgHandlers[eventId]

		if link == nil then
			link = list:new()
			self.msgHandlers[eventId] = link

			gCS.LuaUtils.SetLuaEvent(eventId, true)
		end

		link:push(handler)

		if not gCS.LuaUtils.IsPublish and self.msgHandlerBudget < link.length then
			print_error(string.format("AddMessageListener(lua) eventId:%s too many listeners :%d", tostring(eventId), link.length))
		end
	end,
	RemoveMessageListener = function (self, eventId, handler)
		if handler == nil then
			print_error("[Fatal Error]: RemoveMessageListener nil handler")

			return
		end

		local link = self.msgHandlers[eventId]

		if link ~= nil then
			link:erase(handler)

			if link.length == 0 then
				self.msgHandlers[eventId] = nil

				gCS.LuaUtils.SetLuaEvent(eventId, false)
			end
		end
	end,
	AddMessageID = function (self, eventId)
		self.msgIds[eventId] = true

		return true
	end,
	RemoveMessageId = function (self, eventId)
		self.msgIds[eventId] = nil
	end,
	ProcessMessage = function (self, eventId, param)
		local link = self.msgHandlers[eventId]

		if link ~= nil then
			local traceback = tolua.traceback

			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.BeginSample("ProcessMessage_" .. eventId)
			end

			for _, value in ilist(link) do
				if gGameManager.Env.IsENABLE_PROFILER then
					local info = debug.getinfo(value)

					gCS.LuaUtils.BeginSample(info and info.source or "UnknownFunc")
				end

				local status, err = xpcall(value, traceback, eventId, param)

				if gGameManager.Env.IsENABLE_PROFILER then
					gCS.LuaUtils.EndSample()
				end

				if not status then
					print_error("ProcessMessage Failed, eventId:", eventId, " param", param, "\n", err)
				end
			end

			if gGameManager.Env.IsENABLE_PROFILER then
				gCS.LuaUtils.EndSample()
			end
		end
	end,
	SendMessage = function (self, eventId, param)
		if eventId == nil then
			print_error("SendMessage nil event ")

			return
		end

		self:ProcessMessage(eventId, param)

		if self.msgIds[eventId] then
			gCS.LuaUtils.SendEventFromLua(eventId, param)
		end
	end,
	RegisterEventHandlers = function (self, eventHandlers)
		for k, v in pairs(eventHandlers) do
			self:AddMessageListener(k, v)
		end
	end,
	UnregisterEventHandlers = function (self, eventHandlers)
		for k, v in pairs(eventHandlers) do
			self:RemoveMessageListener(k, v)
		end
	end,
	SetMessageHandlerBudget = function (self, budget)
		self.msgHandlerBudget = budget
	end
}
