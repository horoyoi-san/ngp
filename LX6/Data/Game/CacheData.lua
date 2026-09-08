-- Original chunk: @Lua\LuaFiles\LX6\Data\Game\CacheData.lua
-- Decompiled from: 00110_CacheData.lua_1e312821feb9.luajit

local GameConfig = LTConfig.GameConfig
C_CacheData = DefClass("C_CacheData", C_CacheData, C_BaseData)
local CacheData = C_CacheData

CacheData.DefineData = function(self)
	self.lastReportIllegalityList = {}
	self.nextLeaveStuckPositionTimestamp = nil
	self.isFirstShowLoginPanel = true
	self.simplePanelTopBtnsIsOpen = true
	self.lastSendPixelPaintTime = nil
	self.simpleCutscene_CameraName = ""
	self.simpleCutscene_DialogId = 0
	self.transformDummyPid = nil
	self.muteAllGameSound = false
	self.isShowFullScreen = false
end

CacheData.DefineEvents = function(self)
	self.EventHandler = {}
end

CacheData.OnDispose = function(self)
end

CacheData.ReportIllegalityRateLimitHit = function(self, pid)
	local nowTimeStamp = gCS.TimeManager.ServerUnixTime
	self.lastReportIllegalityList[pid] = nowTimeStamp
end

CacheData.IsReportIllegalityRateLimitOverflow = function(self, pid)
	local lastTime = self.lastReportIllegalityList[pid]

	if not lastTime then
		return false
	end

	local nowTimeStamp = gCS.TimeManager.ServerUnixTime
	local limit = GameConfig.ReportInterval

	return limit >= nowTimeStamp - lastTime
end

CacheData.LeaveStuckPositionSetCd = function(self)
	local count = GameConfig.LeaveStuckPositionCoolDown
	self.nextLeaveStuckPositionTimestamp = gCS.TimeManager.ServerUnixTime + count

	return count
end

CacheData.LeaveStuckPositionCDTime = function(self)
	if self.nextLeaveStuckPositionTimestamp ~= nil or self.nextLeaveStuckPositionTimestamp < gCS.TimeManager.ServerUnixTime then
		return 0
	end

	return self.nextLeaveStuckPositionTimestamp - gCS.TimeManager.ServerUnixTime
end
