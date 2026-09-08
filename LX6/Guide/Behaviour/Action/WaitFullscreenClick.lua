-- Original chunk: @Lua\LuaFiles\LX6\Guide\Behaviour\Action\WaitFullscreenClick.lua
-- Decompiled from: 00444_WaitFullscreenClick.lua_89205099c6ad.luajit

C_GuideBT_WaitFullscreenClick = DefClass("C_GuideBT_WaitFullscreenClick", C_GuideBT_WaitFullscreenClick, C_GuideBT_ActionBase)
local M = C_GuideBT_WaitFullscreenClick

M.OnEnterRunning = function(self)
	local delay = self.listenFullscreenClickDelay or 0

	if delay <= 0 then
		self._fsBlockHandle = SGUI.GuideMgr.ActiveFullScreenListener(nil)
		self._delayTimer = Timer.New(function ()
			self._delayTimer = nil

			SGUI.GuideMgr.InactiveFullScreenListener(self._fsBlockHandle)

			self._fsBlockHandle = nil

			self:_SetupClickCallback()
		end, delay):Start()
	else
		self._SetupClickCallback(self)
	end
end

M._SetupClickCallback = function(self)
	self._fsHandle = SGUI.GuideMgr.ActiveFullScreenListener(function ()
		print_debug("[Guide]全屏点击成功")

		self._nextState = gGuideNodeState.Success
	end)
end

M.OnExitRunning = function(self)
	if self._delayTimer then
		self._delayTimer:Stop()

		self._delayTimer = nil
	end

	if self._fsBlockHandle then
		SGUI.GuideMgr.InactiveFullScreenListener(self._fsBlockHandle)

		self._fsBlockHandle = nil
	end

	if self._fsHandle then
		SGUI.GuideMgr.InactiveFullScreenListener(self._fsHandle)

		self._fsHandle = nil
	end

	self._nextState = nil
end

M.OnTick = function(self)
	local state = self._nextState

	if state then
		self._nextState = nil

		return state
	end

	return gGuideNodeState.Running
end
