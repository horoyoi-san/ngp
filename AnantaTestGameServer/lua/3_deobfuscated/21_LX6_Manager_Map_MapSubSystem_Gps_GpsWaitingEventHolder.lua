GpsWaitingEventHolder = DefClass("GpsWaitingEventHolder", GpsWaitingEventHolder)
local M = GpsWaitingEventHolder

function M:ctor(gpsData, eventKeys)
	self._gpsId = gpsData.gpsId
	self._gpsData = gpsData
	self._eventKeys = eventKeys
	self._scanShowGpsDelayTimer = nil
	self._scanShowGpsDurationTimer = nil
end

function M:GetAllGpsEventKeys()
	return self._eventKeys
end

function M:_HandleScanGps(data)
	local pos = GpsHelper.GetGpsPositionByGpsInfo(self._gpsData)
	local delay = 0

	if pos then
		delay = gHackManager:GetPosScanDelay(pos)
	end

	local dur = self._gpsData.durationWhenScan

	if delay <= 0 then
		self:_ShowGps()

		self._scanShowGpsDurationTimer = gLuaTimeMgrUtils.Delay(function ()
			self:_HideGps()

			self._scanShowGpsDurationTimer = nil
		end, dur, nil, nil, true)
	else
		self._scanShowGpsDelayTimer = gLuaTimeMgrUtils.Delay(function ()
			self:_ShowGps()

			self._scanShowGpsDelayTimer = nil
			self._scanShowGpsDurationTimer = gLuaTimeMgrUtils.Delay(function ()
				self:_HideGps()

				self._scanShowGpsDurationTimer = nil
			end, dur, nil, nil, true)
		end, delay, nil, nil, true)
	end
end

function M:_ShowGps()
	local element = self._gpsData.element
	local traceType = self._gpsData.traceType

	element:SetVisible(true)

	if self._gpsData.defaultTrace then
		element:SetTraceInfo(traceType, 0)
	end

	local pos = GpsHelper.GetGpsPositionByGpsInfo(self._gpsData)

	if pos then
		element:SetPosition(pos)
	end
end

function M:_HideGps()
	local element = self._gpsData.element

	element:SetVisible(false)
	element:ClearTraceInfo()
end

function M:HandleGpsEvent(eventId, data)
	if eventId == gEventConstants.SCAN_START then
		self:_HandleScanGps(data)
	end
end

function M:Dispose()
	for _, v in ipairs(self._eventKeys) do
		gMessageManager:RemoveMessageListener(v, self.HandleGpsEvent)
	end

	if not self._scanShowGpsDelayTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self._scanShowGpsDelayTimer)

		self._scanShowGpsDelayTimer = nil
	end

	if not self._scanShowGpsDurationTimer then
		gLuaTimeMgrUtils.CancelUnitDelay(self._scanShowGpsDurationTimer)

		self._scanShowGpsDurationTimer = nil
	end
end

return M
