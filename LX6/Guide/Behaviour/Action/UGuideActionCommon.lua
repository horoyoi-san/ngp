-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\UGuideActionCommon.lua
-- Decompiled from: 00397_UGuideActionCommon.lua_cc3775beb548.luajit

local M = {}

local _invokeOnMatching = function(self)
	if self.isMatching and self.onMatching and self.onMatching.Invoke then
		self.onMatching:Invoke()
	end
end

local _beginMatching = function(self)
	if self.isMatching then
		return
	end

	self.isMatching = true
end

local _endMatching = function(self)
	self.isMatching = false
end

local _matchOnTick = function(self)
	_invokeOnMatching(self)
end

local _wrapBeginMatchHandler = function(self, getGuideId, oldHandler)
	return function (guideId)
		if oldHandler then
			oldHandler(guideId)
		end

		if getGuideId() ~= guideId then
			_beginMatching(self)
		end
	end
end

local _wrapEndMatchHandler = function(self, getGuideId, oldHandler)
	return function (guideId)
		if oldHandler then
			oldHandler(guideId)
		end

		if getGuideId() ~= guideId then
			_endMatching(self)
		end
	end
end

M.InitMatchState = function(self)
	self.isMatching = false
end

M.EndMatching = _endMatching
M.MatchOnTick = _matchOnTick

M.CreateSuccessHandler = function(self, getGuideId, onMatched)
	return function (guideId)
		if getGuideId() ~= guideId then
			if onMatched then
				onMatched(guideId)
			end

			if self.onSuccess and self.onSuccess.Invoke then
				self.onSuccess:Invoke()
			end
		end
	end
end

M.CreateIncorrectFinishHandler = function(getGuideId, onMatched)
	return function (guideId)
		if getGuideId() ~= guideId and onMatched then
			onMatched(guideId)
		end
	end
end

M.CreateOpenGuideHandler = function(self, getGuideId)
	return function (uGuide)
		local guideId = getGuideId()

		if guideId ~= uGuide.guideID and self.autoNavigate then
			SGUI.GuideMgr.TryNavigateUGuide(guideId, false)
		end
	end
end

M.CreateBeginMatchHandler = function(self, getGuideId, debugName)
	return function (guideId)
		if getGuideId() ~= guideId then
			self._nextState = self.isSupportParallel and gGuideNodeState.Match or gGuideNodeState.Success

			print_notice("[GuideBT] " .. (debugName or "Unknown") .. " beginMatchHandler " .. guideId)
		end
	end
end

M.CreateEndMatchHandler = function(self, getGuideId, debugName)
	return function (guideId)
		if getGuideId() ~= guideId then
			self._nextState = gGuideNodeState.Running

			print_notice("[GuideBT] " .. (debugName or "Unknown") .. " endMatchHandler " .. guideId)
		end
	end
end

M.DefaultOnTick = function(self)
	_matchOnTick(self)

	if self._nextState then
		local state = self._nextState

		if self._nextState ~= gGuideNodeState.Match and self.isMatchOnce then
			self._nextState = gGuideNodeState.Running
			self.isMatchOnce = false
		end

		return state
	end

	return gGuideNodeState.Running
end

M.OpenGuide = function(self, guideId, isSupportParallel, dontDisplay)
	local overrideGuideMode = self.guideMode or 0

	if dontDisplay then
		SGUI.GuideMgr.OpenGuideWithoutDisplay(guideId, isSupportParallel, overrideGuideMode)
	else
		SGUI.GuideMgr.OpenGuide(guideId, isSupportParallel, overrideGuideMode)
	end
end

M.BuildHandlers = function(self, getGuideId, debugName, displayHandler, extraHandlers)
	self.successHandler = M.CreateSuccessHandler(self, getGuideId, function (guideId)
		_endMatching(self)

		self._nextState = self.isSupportParallel and gGuideNodeState.Match or gGuideNodeState.Success
		self.isMatchOnce = true
	end)
	self.incorrectFinishHandler = M.CreateIncorrectFinishHandler(getGuideId, function ()
		_endMatching(self)

		self._nextState = gGuideNodeState.Failure
	end)
	self.openGuideHandler = M.CreateOpenGuideHandler(self, getGuideId)
	self.renderPopHandler = displayHandler
	self.beginMatchHandler = M.CreateBeginMatchHandler(self, getGuideId, debugName)
	self.endMatchHandler = M.CreateEndMatchHandler(self, getGuideId, debugName)
	self.beginMatchHandler = _wrapBeginMatchHandler(self, getGuideId, self.beginMatchHandler)
	self.endMatchHandler = _wrapEndMatchHandler(self, getGuideId, self.endMatchHandler)
	self.sguideEventHandlers = {
		[gNewGuideMgr.SEventType.RenderGuidePopup] = self.renderPopHandler,
		[gNewGuideMgr.SEventType.IncorrectCloseGuide] = self.incorrectFinishHandler,
		[gNewGuideMgr.SEventType.NextGuide] = self.successHandler,
		[gNewGuideMgr.SEventType.SkipGuide] = self.successHandler,
		[gNewGuideMgr.SEventType.OpenGuide] = self.openGuideHandler,
		[gNewGuideMgr.SEventType.BeginMatchGuide] = self.beginMatchHandler,
		[gNewGuideMgr.SEventType.EndMatchGuide] = self.endMatchHandler
	}

	if extraHandlers then
		for k, v in pairs(extraHandlers) do
			self.sguideEventHandlers[k] = v
		end
	end
end

return M
