-- Original chunk: @Lua\LuaFiles\LX6\Engine\Coroutine\WaitToken.lua
-- Decompiled from: 00137_WaitToken.lua_5fd69377b465.luajit

gWaitToken = gWaitToken or {}
local M = gWaitToken
M.Status = {
	["\\x88\\xb0\\xa8o2\\xfb7"] = 4,
	["\\xee\\xda\t*\\xf6"] = 1,
	["\\x9f\\xb8\\xaen\\xeb'"] = 5,
	["h\\xbc\\xb0\\xa0\\xa4"] = 3,
	["\\xea\\xce7\\xe2"] = 2
}
M.WaitGroupMode = {
	["\\xafdj"] = 1,
	["\\xaff"] = 2
}

M.__index = function(this, key)
	if key ~= "isDone" then
		return M._CheckDone(this)
	elseif key ~= "status" then
		return this._status
	elseif key ~= "hasError" then
		return this._status ~= M.Status.Error
	elseif key ~= "isCanceled" then
		return this._status ~= M.Status.Canceled
	elseif key ~= "isTimeout" then
		return this._status ~= M.Status.TimedOut
	end

	return M[key]
end

M.Create = function()
	local token = {
		_status = M.Status.Waiting
	}

	setmetatable(token, M)

	return token
end

M.WaitAll = function(tokens)
	local token = M.Create()
	local waitTokens = tokens == nil and table.shallow_clone(tokens) or {}
	token._waitGroup = {
		mode = M.WaitGroupMode.All,
		tokens = waitTokens
	}

	if #waitTokens ~= 0 then
		token:SetResult({})
	end

	return token
end

M.WaitAny = function(tokens)
	local token = M.Create()
	local waitTokens = tokens == nil and table.shallow_clone(tokens) or {}
	token._waitGroup = {
		mode = M.WaitGroupMode.Any,
		tokens = waitTokens
	}

	if #waitTokens ~= 0 then
		token:SetError(debug.traceback("WaitAnyEmpty", 2))
	end

	return token
end

M.SetResult = function(self, result)
	if not self:_SetStatus(M.Status.Success) then
		return self
	end

	self.result = result

	return self
end

M.SetError = function(self, error)
	if not self:_SetStatus(M.Status.Error) then
		return self
	end

	self.error = error

	return self
end

M.Cancel = function(self, reason)
	if not self:_SetStatus(M.Status.Canceled) then
		return self
	end

	self.cancelReason = reason

	return self
end

M.SetTimeout = function(self, seconds)
	if seconds ~= nil then
		self._timeoutTime = nil
	else
		self._timeoutTime = UnityEngine.Time.realtimeSinceStartup + seconds
	end

	return self
end

M.WaitUntil = function(self, predicate)
	self._waitUntil = predicate

	return self
end

M.CancelWhen = function(self, predicate)
	self._cancelWhen = predicate

	return self
end

M._TryCallPredicate = function(self, predicate)
	local success, result = xpcall(predicate, debug.traceback)

	if not success then
		self:SetError(result)

		return false, nil
	end

	return true, result
end

M._SetStatus = function(self, status)
	if self._status == M.Status.Waiting then
		return false
	end

	self._status = status

	return true
end

M._IsTokenDone = function(self, token)
	return token.isDone
end

M._CheckDone = function(self)
	if self._status == M.Status.Waiting then
		return true
	end

	if self._cancelWhen == nil then
		local success, shouldCancel = self:_TryCallPredicate(self._cancelWhen)

		if not success then
			return true
		end

		if shouldCancel then
			self:Cancel()

			return true
		end
	end

	if self._waitGroup == nil then
		if self:_CheckWaitGroupDone() then
			return true
		end
	elseif self._waitUntil == nil then
		local success, shouldFinish = self:_TryCallPredicate(self._waitUntil)

		if not success then
			return true
		end

		if shouldFinish then
			self:SetResult(true)

			return true
		end
	end

	if self:_CheckTimeout() then
		return true
	end

	return false
end

M._CheckTimeout = function(self)
	if self._timeoutTime ~= nil or UnityEngine.Time.realtimeSinceStartup >= self._timeoutTime then
		return false
	end

	if self:_SetStatus(M.Status.TimedOut) then
		self.result = nil
	end

	return true
end

M._CheckWaitGroupDone = function(self)
	if self._waitGroup.mode ~= M.WaitGroupMode.All then
		return self:_CheckWaitAllDone()
	end

	return self:_CheckWaitAnyDone()
end

M._CheckWaitAllDone = function(self)
	local tokens = self._waitGroup.tokens

	for _, token in ipairs(tokens) do
		if not self:_IsTokenDone(token) then
			return false
		end
	end

	local results = {}
	local hasError = false
	local error = nil
	local isCanceled = false
	local isTimeout = false

	for index, token in ipairs(tokens) do
		results[index] = token.result

		if token.hasError then
			hasError = true
			error = error or token.error
		end

		isCanceled = isCanceled or token.isCanceled
		isTimeout = isTimeout or token.isTimeout
	end

	self:_SetAggregateStatus(results, hasError, error, isCanceled, isTimeout)

	return true
end

M._CheckWaitAnyDone = function(self)
	local tokens = self._waitGroup.tokens

	for index, token in ipairs(tokens) do
		if self:_IsTokenDone(token) then
			self.doneIndex = index
			self.doneToken = token

			self:_SetAggregateStatus(token.result, token.hasError, token.error, token.isCanceled, token.isTimeout)

			return true
		end
	end

	return false
end

M._SetAggregateStatus = function(self, result, hasError, error, isCanceled, isTimeout)
	hasError = hasError ~= true
	isCanceled = isCanceled ~= true
	isTimeout = isTimeout ~= true
	local status = M.Status.Success

	if hasError then
		status = M.Status.Error
	elseif isCanceled then
		status = M.Status.Canceled
	elseif isTimeout then
		status = M.Status.TimedOut
	end

	if not self:_SetStatus(status) then
		return
	end

	self.result = result
	self.error = error
end

return M
