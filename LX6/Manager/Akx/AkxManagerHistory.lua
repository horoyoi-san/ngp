-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxManagerHistory.lua
-- Decompiled from: 02278_AkxManagerHistory.lua_09d470255b18.luajit

local M = C_AkxManager
local json = require("cjson/json")

M.InitHistory = function(self)
	self.ServerMinimumMessageIdx = 1
	self.SessionMessageFetchLimit = 1
end

M.OnLoginToGame_History = function(self)
	self.LoadHistory(self)
end

M.LoadHistory = function(self)
	slot1 = gClientToGameDelegate

	slot1:AskAkxSessionList().Callback = function (err, response)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		self.sessions = {}

		if response then
			for _, serverSession in ipairs(response) do
				local session = self:ConvertServerSessionToLocal(serverSession)
				self.sessions[session.id] = session
			end
		end
	end
end

M.CreateSession = function(self, title, callback)
	title = title or "Thinking..."
	local session = self:CreateEmptyLocalSession()
	session.title = title
	local constData = self:ConvertLocalSessionToServerConstData(session)
	local mutableData = self:ConvertLocalSessionToServerMutableData(session)

	gClientToGameDelegate:AskCreateAISession(UX.Game.AISessionType.Akx, json.encode(constData), json.encode(mutableData)).Callback = function (err, response)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		if response then
			local session = self:ConvertServerSessionToLocal(response)
			self.sessions[session.id] = session

			gMessageManager:SendMessage(gEventConstants.AKX_SESSION_UPDATED, {
				["\\xda\\xc9\n!\\xf5"] = true,
				sessionid = session.id
			})

			if callback then
				callback(session.id)
			end
		end
	end
end

M.UpdateSessionToServer = function(self, sessionid, callback)
	local session = self.GetSession(self, sessionid)

	if not session then
		self.PrintDebug(self, "UpdateSessionToServer: sessionid is nil")

		return
	end

	local bDirtyMutableData = false

	if not session.lastFetchedBasicInfo then
		bDirtyMutableData = true
	else
		local mutableData = json.decode(session.lastFetchedBasicInfo.MutableData or "{}")

		if mutableData.props == session.props then
			bDirtyMutableData = true
		end
	end

	local mutableData = self.ConvertLocalSessionToServerMutableData(self, session)

	if bDirtyMutableData then
		slot6 = gClientToGameDelegate

		slot6:AskUpdateAISession(UX.Game.AISessionType.Akx, tonumber(sessionid), json.encode(mutableData)).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self:PrintDebug("UpdateSessionToServer: Failed to update session ", sessionid, err)
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:PrintDebug("UpdateSessionToServer: Updated session ", sessionid)

			if callback then
				callback()
			end
		end
	else
		self.PrintDebug(self, "UpdateSessionToServer: No need to update session ", sessionid)

		if callback then
			callback()
		end
	end
end

M.UpdateSessionMessageToServer = function(self, sessionid, messageid, callback)
	local session = self.GetSession(self, sessionid)

	if not session then
		self.PrintDebug(self, "UpdateSessionMessageToServer: session is not found", sessionid)

		return
	end

	local message, messageIdx = self.GetMessage(self, sessionid, messageid)

	if not message then
		self.PrintDebug(self, "UpdateSessionMessageToServer: message is not found", messageid)

		return
	end

	local bDirtyMutableData = false

	if not message.lastFetchedMessageInfo then
		bDirtyMutableData = true
	else
		local mutableData = json.decode(message.lastFetchedMessageInfo.MutableData or "{}")

		if mutableData.evaluatedLike == message.evaluatedLike or mutableData.evaluatedUnlike == message.evaluatedUnlike or mutableData.props == message.props then
			bDirtyMutableData = true
		end
	end

	if bDirtyMutableData then
		local mutableData = self:ConvertLocalMessageToServerMutableData(message)
		slot9 = gClientToGameDelegate

		slot9:AskUpdateAISessionMessage(UX.Game.AISessionType.Akx, tonumber(sessionid), tonumber(messageid), json.encode(mutableData)).Callback = function (err)
			if err == LTConfig.MessageConfig.Ok then
				self:PrintDebug("UpdateSessionMessageToServer: Failed to update message", messageid, "for session", sessionid, err)
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			self:PrintDebug("UpdateSessionMessageToServer: Updated message", messageid, "for session", sessionid)
		end
	else
		self.PrintDebug(self, "UpdateSessionMessageToServer: No need to update message", messageid, "for session", sessionid)

		if callback then
			callback()
		end
	end
end

M.AppeadSessionMessageToServer = function(self, sessionid, messageid, callback)
	local session = self.GetSession(self, sessionid)

	if not session then
		self.PrintDebug(self, "AppeadSessionMessageToServer: session is not found", sessionid)

		return
	end

	local message, messageIdx = self:GetMessage(sessionid, messageid)
	local serverMaxMessageIdx = session.lastFetchedBasicInfo and session.lastFetchedBasicInfo.MaxMessageId or 0

	if messageIdx < serverMaxMessageIdx then
		self.PrintDebug(self, "AppeadSessionMessageToServer: message is already in server", messageid)

		return
	end

	local constData = self:ConvertLocalMessageToServerConstData(message)
	local mutableData = self:ConvertLocalMessageToServerMutableData(message)
	slot10 = gClientToGameDelegate

	slot10:AskAppendAISessionMessage(UX.Game.AISessionType.Akx, tonumber(sessionid), json.encode(constData), json.encode(mutableData)).Callback = function (err, messageId)
		if err == LTConfig.MessageConfig.Ok then
			self:PrintDebug("AppeadSessionMessageToServer: Failed to append message", messageid, "for session", sessionid, err)
			gDisplayMessageMgr:DisplayServerMessageId(err)

			return
		end

		message.id = tostring(messageId)
		message.bSyncedToServer = true

		if messageIdx ~= #session.messages then
			session.bLastMessageSynced = true
		end

		session.messages[messageIdx] = message
		self.sessions[sessionid] = session

		if callback then
			callback(messageid)
		end
	end
end

M.RequestFetchSession = function(self, sessionid, callback)
	local session = self.GetSession(self, sessionid)

	if not session then
		return
	end

	if session.nextFetchTime and gCS.TimeManager.ServerUnixTime >= session.nextFetchTime and session.messages == nil then
		callback()

		return
	end

	session.nextFetchTime = gCS.TimeManager.ServerUnixTime + self.SessionMessageFetchLimit

	self.RequestFetchSessionBasicInfo(self, sessionid, function ()
		self.sessions[sessionid] = session
		local fetchFromIdx = self.ServerMinimumMessageIdx
		local localLatestMessage = session.messages and session.messages[#session.messages]

		if localLatestMessage and localLatestMessage.id and localLatestMessage.id == 0 then
			local latestMsgIdx = tonumber(localLatestMessage.id)

			if latestMsgIdx then
				fetchFromIdx = latestMsgIdx + 1
			end
		end

		local fetchToIdx = session.lastFetchedBasicInfo and session.lastFetchedBasicInfo.MaxMessageId or 0

		if fetchFromIdx <= fetchToIdx then
			self:PrintDebug("RequestFetchSession: No Messages to fetch!", sessionid, "fetchToIdx < fetchFromIdx")

			if callback then
				callback()
			end

			return
		end

		slot3 = gClientToGameDelegate

		slot3:AskGetAISessionMessageInfo(UX.Game.AISessionType.Akx, tonumber(sessionid), fetchFromIdx, fetchToIdx).Callback = function (err, response)
			if err == LTConfig.MessageConfig.Ok then
				gDisplayMessageMgr:DisplayServerMessageId(err)

				return
			end

			session.messages = session.messages or {}

			for _, serverMessage in ipairs(response) do
				local message = self:ConvertServerMessageToLocal(serverMessage)

				table.insert(session.messages, message)
				self:DownloadImagesFromMessage(sessionid, message.id)
			end

			if callback then
				callback()
			end
		end
	end)
end

M.RequestFetchSessionBasicInfo = function(self, sessionid, callback)
	if not sessionid then
		self.PrintDebug(self, "RequestFetchSessionBasicInfo: sessionid is nil")

		return
	end

	slot3 = gClientToGameDelegate

	slot3:AskGetAISessionBasicInfo(UX.Game.AISessionType.Akx, tonumber(sessionid)).Callback = function (err, response)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)

			if callback then
				callback()
			end

			return
		end

		local session = self:ConvertServerSessionToLocal(response)
		self.sessions[session.id] = session

		if callback then
			callback()
		end
	end
end

M.RequestDeleteSession = function(self, sessionid, callback)
	sessionid = sessionid or "0"

	gClientToGameDelegate:AskDeleteAISession(UX.Game.AISessionType.Akx, tonumber(sessionid)).Callback = function (err)
		if err == LTConfig.MessageConfig.Ok then
			gDisplayMessageMgr:DisplayServerMessageId(err)
		end

		if callback then
			callback()
		end
	end
end

M.CreateEmptyLocalSession = function(self)
	return {}
end

M.CreateEmptyLocalMessage = function(self)
	return {
		["!9\\xeap\\x9d\\xf3 \\xa7\\xe3\\xe0\\xf0q\\xe9"] = false
	}
end

M.ConvertServerSessionToLocal = function(self, serverSession)
	local constData = json.decode(serverSession.ConstData or "{}")
	local mutableData = json.decode(serverSession.MutableData or "{}")
	local session = {
		["\\x91\\xfe\\xbf\\x8a\\xed\\xb5\\xa9\\x89\\xda\\xe7ߔ#\\x9a\\xe6"] = true,
		id = tostring(serverSession.Id),
		create_time = serverSession.CreateTime,
		update_time = serverSession.UpdateTime,
		title = constData.title or "NO NAME",
		lastFetchedBasicInfo = serverSession,
		props = mutableData.props or {}
	}

	if serverSession.MaxMessageId ~= 0 then
		session.messages = {}
	end

	return session
end

M.ConvertServerMessageToLocal = function(self, serverMessage)
	local constData = json.decode(serverMessage.ConstData or "{}")
	local mutableData = json.decode(serverMessage.MutableData or "{}")
	local message = {
		["\\xe2L85\\xd3\\xa3O\\xaai\\xb9\\xb2"] = 0,
		["!9\\xeap\\x9d\\xf3 \\xa7\\xe3\\xe0\\xf0q\\xe9"] = true,
		["\\xaa\\xbf\\xbco,\\xfb7"] = true,
		["\\xbf\\xb9\\xa5a7\\xf04"] = false,
		["H\\xbc\\xb0\\xa0\\xa4"] = false,
		id = tostring(serverMessage.Id),
		source = constData.source,
		question = constData.question,
		response = constData.response,
		items = constData.items,
		images = constData.images,
		showEvaluate = constData.showEvaluate,
		location = constData.location,
		evaluatedLike = mutableData.evaluatedLike,
		evaluatedUnlike = mutableData.evaluatedUnlike,
		evaluate = constData.evaluate,
		auto_open_link = constData.auto_open_link,
		props = mutableData.props,
		lastFetchedMessageInfo = serverMessage
	}

	return message
end

M.ConvertLocalSessionToServerConstData = function(self, session)
	local constData = {
		title = session.title
	}

	return constData
end

M.ConvertLocalSessionToServerMutableData = function(self, session)
	local mutableData = {
		props = session.props
	}

	return mutableData
end

M.ConvertLocalMessageToServerMutableData = function(self, message)
	local mutableData = {
		evaluatedLike = message.evaluatedLike,
		evaluatedUnlike = message.evaluatedUnlike,
		props = message.props
	}

	return mutableData
end

M.ConvertLocalMessageToServerConstData = function(self, message)
	local images = {}

	if message.images then
		for _, image in ipairs(message.images) do
			table.insert(images, {
				url = image.url,
				width = image.width,
				height = image.height
			})
		end
	end

	local constData = {
		source = message.source,
		question = message.question,
		response = message.response,
		items = message.items or nil,
		images = images,
		showEvaluate = message.showEvaluate or false,
		location = message.location or nil,
		auto_open_link = message.auto_open_link or nil,
		evaluate = message.evaluate or nil
	}

	return constData
end
