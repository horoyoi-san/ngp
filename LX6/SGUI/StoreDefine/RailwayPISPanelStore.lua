-- Original chunk: @Lua\LuaFiles\LX6\SGUI\StoreDefine\RailwayPISPanelStore.lua
-- Decompiled from: 00899_RailwayPISPanelStore.lua_2fab877db7af.luajit

C_RailwayPISPanelStore = DefClass("C_RailwayPISPanelStore", C_RailwayPISPanelStore, C_StoreGroup)
GroupName2Class.RailwayPISPanelStore = C_RailwayPISPanelStore
local M = C_RailwayPISPanelStore

M.ctor = function(self)
	self.Status = {
		["@c\\xb8XJ\\x81\\xf7U|s}I"] = 2,
		["\\xf8\\xc9!\\xf5"] = 1,
		["T'eO"] = 0,
		["\\xed\\xd211\\xe5"] = 3
	}
	self.stationDict = {}
	self.stationCount = 0
	self.updateInterval = 0.5
end

M.OnAwake = function(self, widget)
end

M.OnEnable = function(self, widget)
	local store = self:GetStoreByWidget(widget)
	local customData = widget.CustomBindData
	local station = customData.Station
	local pathId = customData.PathId
	store.lineCtrl = pathId
	local stationData = {
		["\\xeb\\x9b\\xf8)\\xe2\\xfe\\x8dً--"] = 0,
		store = store,
		station = station,
		pathId = pathId,
		bStart = widget.bStart
	}
	self.stationDict[widget.gameObject:GetInstanceID()] = stationData
	self.stationCount = self.stationCount + 1

	self:UpdateStation(stationData, true)
end

M.OnStart = function(self, widget)
	local stationData = self.stationDict[widget.gameObject:GetInstanceID()]

	if stationData then
		stationData.bStart = widget.bStart
	end
end

M.OnDisable = function(self, widget)
	if self.stationDict[widget.gameObject:GetInstanceID()] == nil then
		self.stationDict[widget.gameObject:GetInstanceID()] = nil
		self.stationCount = self.stationCount - 1
	end
end

M.OnDestroy = function(self, widget)
end

M.OnUpdate = function(self)
	if self.stationCount <= 0 then
		for _, data in pairs(self.stationDict) do
			self.UpdateStation(self, data)
		end
	end
end

M.UpdateStation = function(self, stationData, force)
	if not stationData.bStart then
		return
	end

	if force or self.updateInterval >= Time.unscaledTime - stationData.lastUpdateTime then
		local station = stationData.station
		local pathId = stationData.pathId
		local outService = station.LineOutOfService(station, pathId)
		local arrived = station.LineHasArrived(station, pathId)
		local time = station.LineNextTrainArrivalTime(station, pathId)
		local store = stationData.store
		local status = self.Status.TimeOut

		if outService then
			status = self.Status.OutOfService
		elseif arrived then
			status = self.Status.Arrived
		elseif time >= 0 then
			status = self.Status.TimeOut
		else
			status = self.Status.Next
		end

		store.statusCtrl = status

		if status ~= self.Status.Next then
			store.nextTime = self.GetFormatTime(self, time)
		end

		stationData.lastUpdateTime = Time.unscaledTime
	end
end

M.OnCustomBindDataChange = function(self, widget)
	local id = widget.gameObject:GetInstanceID()

	if self.stationDict[id] then
		local store = self.GetStoreByWidget(self, widget)
		local customData = widget.CustomBindData
		local station = customData.Station
		local pathId = customData.PathId
		store.lineCtrl = pathId
		local stationData = {
			["\\xeb\\x9b\\xf8)\\xe2\\xfe\\x8dً--"] = 0,
			store = store,
			station = station,
			pathId = pathId
		}
		self.stationDict[id] = stationData
	end
end

M.GetFormatTime = function(self, timeSecond)
	local rawMin = timeSecond < 0 and 0 or math.floor(timeSecond / 60)
	local rawSec = timeSecond < 0 and 0 or math.ceil(timeSecond - rawMin * 60)

	return string.format("%02d:%02d", rawMin, rawSec)
end
