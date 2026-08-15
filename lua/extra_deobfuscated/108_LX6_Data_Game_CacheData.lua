local GameConfig = LTConfig.GameConfig
C_CacheData = DefClass("C_CacheData", C_CacheData, C_BaseData)
local CacheData = C_CacheData

function CacheData:DefineData()
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

function CacheData:DefineEvents()
	self.EventHandler = {}
end

function CacheData:OnDispose()
	return
end

function CacheData:ReportIllegalityRateLimitHit(pid)
	local nowTimeStamp = gCS.TimeManager.ServerUnixTime
	self.lastReportIllegalityList[pid] = nowTimeStamp
end

function CacheData:IsReportIllegalityRateLimitOverflow(pid)
	local lastTime = self.lastReportIllegalityList[pid]

	if not lastTime then
		return false
	end

	local nowTimeStamp = gCS.TimeManager.ServerUnixTime
	local limit = GameConfig.ReportInterval

	return limit > nowTimeStamp - lastTime
end

function CacheData:LeaveStuckPositionSetCd()
	local count = GameConfig.LeaveStuckPositionCoolDown
	self.nextLeaveStuckPositionTimestamp = gCS.TimeManager.ServerUnixTime + count

	return count
end

function CacheData:LeaveStuckPositionCDTime()
	if self.nextLeaveStuckPositionTimestamp == nil or self.nextLeaveStuckPositionTimestamp <= gCS.TimeManager.ServerUnixTime then
		return 0
	end

	return self.nextLeaveStuckPositionTimestamp - gCS.TimeManager.ServerUnixTime
end
