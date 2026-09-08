-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\Gps\GpsWaitingEventHolder.lua
-- Decompiled from: 00212_GpsWaitingEventHolder.lua_67c7ba1b8825.luajit

GpsWaitingEventHolder = DefClass("GpsWaitingEventHolder", GpsWaitingEventHolder)
local M = GpsWaitingEventHolder

M.ctor = function(self, gpsData, eventKeys)
	self._gpsId = gpsData.gpsId
	self._gpsData = gpsData
	self._eventKeys = eventKeys
	self._scanShowGpsDelayTimer = nil
	self._scanShowGpsDurationTimer = nil
end

M.GetAllGpsEventKeys = function(self)
	return self._eventKeys
end

M._HandleScanGps = function(self, data)
	local pos = GpsHelper.GetGpsPositionByGpsInfo(self._gpsData)
	local delay = 0

	if pos then
		delay = gHackManager:GetPosScanDelay(pos)
	end

	local dur = self._gpsData.durationWhenScan

	if delay < 0 then
		self._ShowGps(self)

		self._scanShowGpsDurationTimer = gLuaTimeMgrUtils.Delay(function ()
			self:_HideGps()

			self._scanShowGpsDurationTimer = nil
		end, dur, nil, , true)
	else
		self._scanShowGpsDelayTimer = gLuaTimeMgrUtils.Delay(function ()
			slot0 = self

			slot0:_ShowGps()

			self._scanShowGpsDelayTimer = nil
			self._scanShowGpsDurationTimer = gLuaTimeMgrUtils.Delay(function ()
				self:_HideGps()

				self._scanShowGpsDurationTimer = nil
			end, dur, nil, , true)
		end, delay, nil, , true)
	end
end

M._ShowGps = function(self)
	local element = self._gpsData.element
	local traceType = self._gpsData.traceType

	element.SetVisible(element, true)

	if self._gpsData.defaultTrace then
		element.SetTraceInfo(element, traceType, 0)
	end

	local pos = GpsHelper.GetGpsPositionByGpsInfo(self._gpsData)

	if pos then
		element.SetPosition(element, pos)
	end
end

M._HideGps = function(self)
	local element = self._gpsData.element

	element.SetVisible(element, false)
	element.ClearTraceInfo(element)
end

M.HandleGpsEvent = function(self, eventId, data)
	if eventId ~= gEventConstants.SCAN_START then
		self._HandleScanGps(self, data)
	end
end

M.Dispose = function(self)
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
