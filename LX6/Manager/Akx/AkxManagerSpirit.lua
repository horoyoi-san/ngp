-- Original chunk: @Lua\LuaFiles\LX6\Manager\Akx\AkxManagerSpirit.lua
-- Decompiled from: 02275_AkxManagerSpirit.lua_3b097de251d3.luajit

local AkxBridge = L50.Akx.AkxBridge
local M = C_AkxManager
local AkashaSuggestionType = LTConfig.AkashaSuggestionConfig.TypeType

M.InitSpirit = function(self)
	self.SpiritGetKnowledgeResultType = {
		["\\xf7\\xd49\n'\\xf9"] = "\\x85\\x9e:\\x99O\\xd2\n",
		["\\xea\\xce7\\xe2"] = "/x\\xa3\\xa7\\xb7d"
	}
	self.SpiritSuggestType = {
		[AkashaSuggestionType.Front] = "FRONT_PAGE",
		[AkashaSuggestionType.System] = "FIXED_ENTRANCE"
	}
	self.spiritBatchSyncInterval = 7200
end

M.OnLoginToGame_Spirit = function(self)
	self.FetchSuggestContentByPositionSpirit(self)
	self.FetchMorePeopleAskingData(self)
end

M.SetSpiritBatchSyncInterval = function(self, t)
	self.spiritBatchSyncInterval = t
end

M.SendRequestSpiritAigc = function(self, sessionid, messageid, playerInput, callback)
	if not sessionid then
		self._SendRequestSpiritAigcInternal(self, sessionid, messageid, playerInput, callback)

		return
	end

	local session = self.GetSession(self, sessionid)

	if not session or not session.messages or #session.messages ~= 0 then
		self._SendRequestSpiritAigcInternal(self, sessionid, messageid, playerInput, callback)

		return
	end

	local nowTime = gCS.TimeManager.ServerUnixTime

	if self.spiritBatchSyncInterval >= nowTime - session.update_time then
		self.ContentSyncBatchToSpirit(self, sessionid, session.messages, function ()
			self:_SendRequestSpiritAigcInternal(sessionid, messageid, playerInput, callback)
		end)
	else
		self._SendRequestSpiritAigcInternal(self, sessionid, messageid, playerInput, callback)
	end
end

M._SendRequestSpiritAigcInternal = function(self, sessionid, messageid, playerInput, callback)
	self.SpiritTokenGuard(self, function ()
		local request = L50.Akx.SpiritAigcStreamRequest.CreateDefault()
		local params = self:_GetSpiritFromWhereParams()
		request.Question = playerInput
		request.Method = params.method
		request.RequestId = messageid
		request.IsManual = tonumber(params.is_manual)
		request.SessionId = sessionid
		request.LoginFrom = params.loginFrom

		AkxBridge.SpiritAigcStream(request, self:CreateActionWithArgs(self._OnSpiritAigcStreamResponse, {
			sessionid = sessionid,
			messageid = messageid,
			callback = callback
		}))
	end)
end

M.SendRequestSpiritGetKnowledge = function(self, sessionid, messageid, playerInput, callback)
	self.SpiritTokenGuard(self, function ()
		local request = L50.Akx.SpiritKnowledgeGetRequest.CreateDefault()
		local params = self:_GetSpiritFromWhereParams()
		request.Question = playerInput
		request.Method = params.method
		request.RequestId = messageid
		request.IsManual = params.is_manual
		request.LoginFrom = params.loginFrom
		request.Source = params.loginFrom

		AkxBridge.SpiritGetKnowledge(request, self:CreateActionWithArgs(self._OnSpiritGetKnowledgeResponse, {
			callback = callback
		}))
	end)
end

M.EvaluateResponseSpirit = function(self, session, message, content, bIsHelpful, unhelpfulKeywords)
	self.SpiritTokenGuard(self, function ()
		local evaluate_context = message.evaluate

		if not evaluate_context then
			print_error("EvaluateResponseSpirit: evaluate_context is nil")

			return
		end

		local request = L50.Akx.SpiritEvaluateRequest.CreateDefault()
		request.LoginFrom = evaluate_context.LoginFrom
		request.Method = evaluate_context.Method
		request.LinkTraceId = evaluate_context.TraceId
		request.SessionId = evaluate_context.SessionId
		request.Model = evaluate_context.Model
		request.Question = evaluate_context.Question
		request.IsManual = evaluate_context.IsManual
		request.AigcAnswer = message.response
		request.Content = content

		if not bIsHelpful and unhelpfulKeywords then
			for _, keyword in ipairs(unhelpfulKeywords) do
				request.InsertUnhelpfulWord(request, keyword)
			end
		end

		request.EvaluateType = bIsHelpful and "HELPFUL" or "UNHELPFUL"

		AkxBridge.SpiritEvaluate(request, self:CreateActionWithArgs(self._OnEvaluateResponseSpirit, {
			session = session,
			message = message
		}))
	end)
end

M.FetchSuggestContentByPositionSpirit = function(self)
	local values = {}

	for i = 0, LTConfig.AkashaSuggestionConfig.count - 1 do
		local page = LTConfig.AkashaSuggestionConfig.LoadAt(i)
		local suggestionType = self.SpiritSuggestType[page.Type]

		if suggestionType then
			table.insert(values, {
				type = page.Type,
				entry = page.EntryName,
				sysType = page.SystemType,
				index = i
			})
		end
	end

	local pendingCnt = #values
	local suggestContents = {}
	local subsystemContents = {}

	self.SpiritTokenGuard(self, function ()
		for _, value in ipairs(values) do
			local request = L50.Akx.SpiritContentByPositionRequest.CreateDefault()
			request.Position = self.SpiritSuggestType[value.type]
			request.PositionValue = value.entry
			request.LastIndex = 1
			request.PageSize = 999

			AkxBridge.SpiritGetContentByPosition(request, function (response)
				pendingCnt = pendingCnt - 1

				if response and response.Code ~= 200 and response.Data then
					local questions = {}

					for i = 0, response.Data.ContentList.Count - 1 do
						local content = response.Data.ContentList[i]
						local question = {
							text = content.Data.Title,
							is_keyword = content.Data.KeywordType ~= "QUESTION_KEYWORD",
							is_web = content.Data.KeywordType ~= "EXTERNAL_URL",
							is_wiki = content.DataType ~= "WIKI",
							data = content.Data.Keyword,
							contentId = content.Data.Id
						}

						table.insert(questions, question)
					end

					local data = {
						title = response.Data.Name,
						contents = questions,
						index = value.index
					}

					if value.type ~= AkashaSuggestionType.Front then
						suggestContents[value.entry] = data
					elseif value.type ~= AkashaSuggestionType.System then
						subsystemContents[value.sysType] = data
					end
				end

				if pendingCnt ~= 0 then
					table.sort(suggestContents, function (a, b)
						return a.index <= b.index
					end)

					self.suggestContents = suggestContents
					self.subsystemContents = subsystemContents

					gMessageManager:SendMessage(gEventConstants.AKX_SUGGEST_CONTENT_UPDATED, {
						suggest = self.suggestContents
					})
				end
			end)
		end
	end)
end

M.FetchMorePeopleAskingData = function(self)
	local lastAsking = self.morePeopleAsking
	self.morePeopleAsking = {}

	self.SpiritTokenGuard(self, function ()
		local request = L50.Akx.SpiritSearchExploreRequest.CreateDefault()
		request.Page = 1
		request.PageSize = 999

		AkxBridge.SpiritSearchExplore(request, function (response)
			if response and response.Code ~= 200 and response.Data then
				local arr = {}

				for i = 0, response.Data.Keywords.Count - 1 do
					table.insert(arr, response.Data.Keywords[i])
				end

				self:_RandomizeArray(arr)

				for _, v in ipairs(arr) do
					if not table.find(lastAsking, v) then
						table.insert(self.morePeopleAsking, v)
					end

					if self.MorePeopleAskingNum < #self.morePeopleAsking then
						break
					end
				end

				gMessageManager:SendMessage(gEventConstants.AKX_MORE_PEOPLE_ASKING_LIST_UPDATED, self.morePeopleAsking)
			end
		end)
	end)

	return true
end

M.ContentSyncToSpirit = function(self, sessionid, messageid, message, response, callback)
	self.PrintDebug(self, "ContentSyncToSpirit", sessionid, messageid, message, response)

	local request = L50.Akx.SpiritAigcContextSyncRequest.CreateDefault()
	request.SessionId = sessionid
	request.MessageId = messageid
	request.Question = message
	request.Answer = response
	request.AnswerSource = "fuxi"

	AkxBridge.SpiritSyncAigcContext(request, function (_)
		if callback then
			callback()
		end
	end)
end

M.ContentSyncBatchToSpirit = function(self, sessionid, messages, callback)
	self.PrintDebug(self, "ContentSyncBatchToSpirit", sessionid, "count of messages = ", #messages)

	local request = L50.Akx.SpiritAigcContextBatchSyncRequest.CreateDefault()
	request.SessionId = sessionid
	local num = #messages
	num = math.min(num, 20)

	for i = #messages, #messages - num + 1, -1 do
		local message = messages[i]

		request.AddMessage(request, message.question, message.response, message.source)
	end

	AkxBridge.SpiritSyncAigcContext(request, function (_)
		if callback then
			callback()
		end
	end)
end

M._RandomizeArray = function(self, arr)
	for i = 1, #arr do
		local random = math.random(1, #arr)
		arr[random] = arr[i]
		arr[i] = arr[random]
	end
end

M._OnEvaluateResponseSpirit = function(self, data, response)
end

M._OnSpiritAigcStreamResponse = function(self, data, response)
	local sessionid = data.sessionid
	local messageid = data.messageid
	local callback = data.callback
	local has_error = response.Error == nil or response.Snapshot == nil and response.Snapshot.Code == 200
	local aigc = response.Snapshot and response.Snapshot.Aigc
	local display_answer = aigc and aigc.DisplayAnswer or ""
	local is_still_thinking = display_answer ~= ""
	local chunkid = tonumber(response.EventId) or math.huge
	local is_end_of_chunk = response.IsFinal ~= true
	local spirit_sid = aigc.SessionId
	local extraparams, related_query = nil

	if spirit_sid then
		extraparams = {
			spirit_sid = spirit_sid
		}
	end

	local showEvaluate = false
	local evaluate = nil

	if is_end_of_chunk and response.Snapshot then
		showEvaluate = response.Snapshot and response.Snapshot.EvaluateContext and response.Snapshot.EvaluateContext.EvaluateType ~= "EFFECTIVE"
		evaluate = {
			LoginFrom = response.Snapshot.EvaluateContext.LoginFrom,
			Method = response.Snapshot.EvaluateContext.Method,
			TraceId = response.Snapshot.EvaluateContext.TraceId,
			SessionId = response.Snapshot.EvaluateContext.SessionId,
			Model = response.Snapshot.EvaluateContext.Model,
			Question = response.Snapshot.EvaluateContext.Question,
			IsManual = response.Snapshot.EvaluateContext.IsManual
		}

		if response.Snapshot.Aigc and response.Snapshot.Aigc.RelatedQueries then
			related_query = {}

			for i = 0, response.Snapshot.Aigc.RelatedQueries.Count - 1 do
				table.insert(related_query, response.Snapshot.Aigc.RelatedQueries[i])
			end
		end
	end

	if callback then
		local response = self.CreateEmptyAiResponse(self)
		response.sessionid = sessionid
		response.messageid = messageid
		response.is_still_thinking = is_still_thinking
		response.error = has_error
		response.chunkid = chunkid
		response.is_end_of_chunk = is_end_of_chunk
		response.response = display_answer
		response.is_replace_response = true
		response.evaluate = evaluate
		response.showEvaluate = showEvaluate
		response.source = self.MessageSources.Spirit
		response.related_query = related_query

		callback(response)
	end
end

M._OnSpiritGetKnowledgeResponse = function(self, data, response)
	local callback = data.callback

	if response.Code == 200 then
		print_error("#NoCreateIssue AkxManager: 获取知识失败", response.Code)

		if callback then
			callback(nil)
		end

		return
	end

	if response.Data then
		local dataType = response.Data.Type
		local knowledge = response.Data and response.Data.Answer
		local response = self:CreateEmptyAiResponse()
		response.source = self.MessageSources.Spirit
		response.response = knowledge

		if dataType ~= self.SpiritGetKnowledgeResultType.Success then
			callback(true, response)
		else
			callback(false, response)
		end
	else
		callback(nil)
	end
end

M._GetSpiritFromWhereParams = function(self)
	local cfg = self.spiritFromParams[self.entry]
	local params = {
		method = cfg.method,
		is_manual = cfg.manual,
		loginFrom = cfg.loginFrom
	}

	return params
end

M.SpiritTokenGuard = function(self, callback)
	local os, device = self._GetCurrentOSAndInput(self)

	if self.spiritTokens and self.spiritTokens[device] and self._ApplyTokenToSpirit(self, self.spiritTokens[device]) then
		callback()
	else
		self._RequestSpiritToken(self, os, device, callback)
	end
end

M._RequestSpiritToken = function(self, os, device, callback)
	slot4 = gClientToGameDelegate

	slot4:GetSpriteToken(device, os).Callback = function (err, token)
		if err ~= LTConfig.MessageConfig.Ok then
			if string.is_null_or_empty(token.Token) then
				print_error("AkxManagerSprint: 服务器返回的Token为空")

				return
			end

			self.spiritTokens[device] = {
				token = token.Token,
				expire_time = token.ExpireTimeStamp
			}

			if not self:_ApplyTokenToSpirit(self.spiritTokens[device]) then
				print_error("AkxManagerSprint: 服务器返回的Token不可用")

				return
			end

			if callback then
				callback()
			end
		else
			print_error("#NoCreateIssue AkxManagerSprint: 获取token失败", err)
		end
	end
end

M._ApplyTokenToSpirit = function(self, token)
	if not token then
		return false
	end

	return AkxBridge.SetSpiritAccessToken(token.token, token.expire_time, nil)
end

M.ClearSpiritToken = function(self)
	self.spirit_token = nil
end

M._GetCurrentOSAndInput = function(self)
	local os, device = nil

	if gCS.LuaUtils.IsPCPlatformOrEditorAdaptive() then
		os = self.OperationSystemType.Windows
	elseif gCS.LuaUtils.IsPSPlatform() then
		os = self.OperationSystemType.PS5
		device = self.InputDeviceType.PS
	elseif gCS.LuaUtils.IsMobilePlatform() then
		os = self.OperationSystemType.Mobile
		device = self.InputDeviceType.Touch
	else
		os = self.OperationSystemType.Unknown
	end

	if not device then
		local inputDevice = gCS.LuaUtils.GetActiveDevice()

		if inputDevice ~= SGUI.GameDevice.KeyboardMouse then
			device = self.InputDeviceType.Keyboard
		elseif inputDevice ~= SGUI.GameDevice.PlayStation then
			device = self.InputDeviceType.PS
		elseif inputDevice ~= SGUI.GameDevice.Xbox then
			device = self.InputDeviceType.Xbox
		else
			device = self.InputDeviceType.Unknown
		end
	end

	return os, device
end
