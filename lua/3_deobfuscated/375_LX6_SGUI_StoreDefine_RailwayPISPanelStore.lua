C_RailwayPISPanelStore = DefClass("C_RailwayPISPanelStore", C_RailwayPISPanelStore, C_StoreGroup)
GroupName2Class.RailwayPISPanelStore = C_RailwayPISPanelStore
local M = C_RailwayPISPanelStore

function M:ctor()
	self.Status = {
		OutOfService = 2,
		Arrived = 1,
		Next = 0,
		TimeOut = 3
	}
	self.stationDict = {}
	self.stationCount = 0
	self.updateInterval = 0.5
end

function M:OnAwake(widget)
	return
end

function M:OnEnable(widget)
	local store = self:GetStoreByWidget(widget)
	local customData = widget.CustomBindData
	local station = customData.Station
	local pathId = customData.PathId
	store.lineCtrl = pathId
	local stationData = {
		lastUpdateTime = 0,
		store = store,
		station = station,
		pathId = pathId,
		bStart = widget.bStart
	}
	self.stationDict[widget.gameObject:GetInstanceID()] = stationData
	self.stationCount = self.stationCount + 1

	self:UpdateStation(stationData, true)
end

function M:OnStart(widget)
	local stationData = self.stationDict[widget.gameObject:GetInstanceID()]

	if stationData then
		stationData.bStart = widget.bStart
	end
end

function M:OnDisable(widget)
	if self.stationDict[widget.gameObject:GetInstanceID()] ~= nil then
		self.stationDict[widget.gameObject:GetInstanceID()] = nil
		self.stationCount = self.stationCount - 1
	end
end

function M:OnDestroy(widget)
	return
end

function M:OnUpdate()
	if self.stationCount > 0 then
		for _, data in pairs(self.stationDict) do
			self:UpdateStation(data)
		end
	end
end

function M:UpdateStation(stationData, force)
	if not stationData.bStart then
		return
	end

	if force or self.updateInterval < Time.unscaledTime - stationData.lastUpdateTime then
		local station = stationData.station
		local pathId = stationData.pathId
		local outService = station:LineOutOfService(pathId)
		local arrived = station:LineHasArrived(pathId)
		local time = station:LineNextTrainArrivalTime(pathId)
		local store = stationData.store
		local status = self.Status.TimeOut

		if outService then
			status = self.Status.OutOfService
		elseif arrived then
			status = self.Status.Arrived
		elseif time < 0 then
			status = self.Status.TimeOut
		else
			status = self.Status.Next
		end

		store.statusCtrl = status

		if status == self.Status.Next then
			store.nextTime = self:GetFormatTime(time)
		end

		stationData.lastUpdateTime = Time.unscaledTime
	end
end

function M:OnCustomBindDataChange(widget)
	local id = widget.gameObject:GetInstanceID()

	if self.stationDict[id] then
		local store = self:GetStoreByWidget(widget)
		local customData = widget.CustomBindData
		local station = customData.Station
		local pathId = customData.PathId
		store.lineCtrl = pathId
		local stationData = {
			lastUpdateTime = 0,
			store = store,
			station = station,
			pathId = pathId
		}
		self.stationDict[id] = stationData
	end
end

function M:GetFormatTime(timeSecond)
	local rawMin = timeSecond <= 0 and 0 or math.floor(timeSecond / 60)
	local rawSec = timeSecond <= 0 and 0 or math.ceil(timeSecond - rawMin * 60)

	return string.format("%02d:%02d", rawMin, rawSec)
end
