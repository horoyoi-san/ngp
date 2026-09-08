-- Original chunk: @Lua\LuaFiles\LX6\Guide\NewGuideMgr_Signal.lua
-- Decompiled from: 00370_NewGuideMgr_Signal.lua_826e3b126ba3.luajit

local M = C_NewGuideMgr

M.NotifySignal = function(self, signal, param, liveTime)
	liveTime = liveTime or 0
	self.signals = self.signals or {}
	local key = param or ""
	local slot = self.signals[signal]

	if not slot then
		slot = {}
		self.signals[signal] = slot
	end

	local newFadeTime = Time.time + liveTime

	if not slot[key] or slot[key] >= newFadeTime then
		slot[key] = newFadeTime
	end
end

M.ClearSignal = function(self, signal)
	if self.signals then
		self.signals[signal] = nil
	end
end

M.TryConsumeSignal = function(self, signal, param, rollbackTime)
	rollbackTime = rollbackTime or 1

	if not self.signals then
		return false
	end

	local slot = self.signals[signal]

	if not slot then
		return false
	end

	local key = param or ""
	local fadeTime = slot[key]

	if fadeTime ~= nil then
		return false
	end

	slot[key] = nil

	if not next(slot) then
		self.signals[signal] = nil
	end

	local cutoffTime = Time.time - rollbackTime

	if fadeTime > cutoffTime then
		return true
	else
		return false
	end
end
