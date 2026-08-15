local RailLineConfig = LTConfig.RailLineConfig
local RailStationConfig = LTConfig.RailStationConfig
C_RailwayLCDPanelStore = DefClass("C_RailwayLCDPanelStore", C_RailwayLCDPanelStore, C_StoreGroup)
GroupName2Class.RailwayLCDPanelStore = C_RailwayLCDPanelStore
local M = C_RailwayLCDPanelStore

function M:ctor()
	self.metroDataList = {}
	self.instanceId2MetroId = {}
	self.metroInstanceDict = {}
	self.prepared = false
	self.Status = {
		Next = 0,
		Arrived = 1
	}
	self.LineType = {
		Loop = 1,
		Line = 0
	}
	self.DoorType = {
		This = 0,
		Both = 2,
		Opposite = 1
	}
	self.StationViewType = {
		MoveTo04 = 3,
		MoveTo02 = 1,
		MoveTo03 = 2,
		MoveTo01 = 0,
		MoveTo06 = 5,
		MoveTo05 = 4
	}
	self.PathNameDict = {
		"Bay",
		"Bay",
		"Center",
		"East"
	}
	self.candidatesCache = {}
end

function M:OnEnable(widget)
	local customData = widget.CustomBindData
	local id = widget.gameObject:GetInstanceID()
	self.metroInstanceDict[id] = widget
	self.instanceId2MetroId[id] = customData.MetroId

	self:AddMetroData(customData.MetroId, id)
	self:RefreshData(widget)
end

function M:OnDisable(widget)
	local customData = widget.CustomBindData
	local id = widget.gameObject:GetInstanceID()
	self.metroInstanceDict[id] = nil
	self.instanceId2MetroId[id] = nil

	self:RemoveMetroData(customData.MetroId, id)
end

function M:OnCustomBindDataChange(widget)
	local customData = widget.CustomBindData
	local id = widget.gameObject:GetInstanceID()

	if self.metroInstanceDict[id] then
		local preMetroId = self.instanceId2MetroId[id]

		if preMetroId then
			self:RemoveMetroData(preMetroId, id)
		end

		self:AddMetroData(customData.MetroId, id)

		self.instanceId2MetroId[id] = customData.MetroId

		self:RefreshData(widget)
	end
end

function M:OnLogOut()
	self:ClearCache()
end

function M:AddMetroData(metroId, instanceId)
	if not self.metroDataList[metroId] then
		self.metroDataList[metroId] = {}
	end

	self.metroDataList[metroId][instanceId] = true
end

function M:RemoveMetroData(metroId, instanceId)
	if self.metroDataList[metroId] then
		self.metroDataList[metroId][instanceId] = nil
	end
end

function M:OnMetroBoardInfoChange(metroId)
	self:ClearCache()

	local dataList = self.metroDataList[metroId]

	if dataList then
		for id, _ in pairs(dataList) do
			self:RefreshData(self.metroInstanceDict[id])
		end
	end
end

function M:RefreshData(widget)
	if not widget then
		return
	end

	local store = self:GetStoreByWidget(widget)
	local customData = widget.CustomBindData
	local metro = customData.Metro
	local metroId = customData.MetroId
	local pathId = customData.PathId
	local carriageId = customData.CarriageId
	local gateSide = customData.GateSide

	if metroId < 0 or pathId <= 0 or carriageId < 0 or metro == nil then
		return
	end

	local cfg = RailLineConfig.GetConfig(pathId)

	if not cfg then
		print_error("RailLineConfig cfg is nil, pathId = ", pathId)

		return
	end

	local arrived = metro:IsMetroAboutToArrive()
	local nextId = metro:NextStationId()
	local nextIndex = metro:NextStationIndex() + 1

	if nextId == 0 then
		store.stationCtrl = self.StationViewType.MoveTo06

		return
	end

	local nextCfg = RailStationConfig.GetConfig(nextId)
	store.lineCtrl = pathId
	store.lineTypeCtrl = cfg.RingLine and self.LineType.Loop or self.LineType.Line
	store.destination = nextCfg.StationChineseName
	store.carNum = carriageId + 1

	if arrived then
		store.statusCtrl = self.Status.Arrived
		local gateOpenSideType = metro:GetCurrentWaitingStationDoorOpenSide()

		if gateOpenSideType == 2 then
			store.doorCtrl = self.DoorType.Both
		else
			store.doorCtrl = gateOpenSideType == gateSide and self.DoorType.This or self.DoorType.Opposite
		end
	else
		store.statusCtrl = self.Status.Next
		local info = self:GetCandidateStations(pathId, nextIndex)

		if info then
			local stations = info.candidates
			local viewType = info.viewType
			local inters = info.inters
			local indexes = info.indexes

			for i = 1, #stations do
				local stationCfg = RailStationConfig.GetConfig(stations[i])
				store["s" .. i .. "CN"] = stationCfg.StationChineseName
				store["s" .. i .. "EN"] = stationCfg.StationEnglishName
			end

			for i = 1, #inters do
				local inter = inters[i]
				local bay = inter[1] or inter[2] or false
				store["s" .. i .. "Bay"] = bay

				for k = 3, 4 do
					store["s" .. i .. self.PathNameDict[k]] = inter[k] or false
				end
			end

			for i = 1, #indexes do
				local idx = indexes[i]
				store["s" .. i .. "Index"] = idx
			end

			store.stationCtrl = viewType
		end
	end
end

function M:GetCandidateStations(pathId, luaIndex)
	local key = pathId .. "/" .. luaIndex

	if self.candidatesCache[key] then
		self.candidatesCache[key].time = Time.unscaledTime

		return self.candidatesCache[key]
	end

	local cfg = RailLineConfig.GetConfig(pathId)

	if not cfg then
		return
	end

	local stations = cfg.Stations
	local ignoreNum = 1
	local candidates = {}
	local candidateIndex = {}

	if cfg.RingLine and luaIndex > #stations - ignoreNum then
		luaIndex = ignoreNum
	end

	local curIndex = luaIndex
	local candidate = nil
	local viewType = self.StationViewType.MoveTo03

	if cfg.RingLine then
		local count = 2

		for i = 1, count do
			candidate, curIndex = self:GetCandidate(stations, curIndex, -1, ignoreNum)

			table.insert(candidates, 1, candidate)
			table.insert(candidateIndex, 1, string.format("%02d", curIndex))
		end

		curIndex = luaIndex

		table.insert(candidates, stations[curIndex])
		table.insert(candidateIndex, string.format("%02d", curIndex))

		for i = 1, count do
			candidate, curIndex = self:GetCandidate(stations, curIndex, 1, ignoreNum)

			table.insert(candidates, candidate)
			table.insert(candidateIndex, string.format("%02d", curIndex))
		end
	else
		local mid = #stations / 2

		if luaIndex <= mid then
			local count = 2

			if luaIndex == 1 then
				viewType = self.StationViewType.MoveTo01
				count = 4
				luaIndex = 2
			else
				for i = 1, count do
					candidate, curIndex = self:GetCandidate(stations, curIndex, -1, ignoreNum)

					if luaIndex < curIndex then
						count = 5 - i
						viewType = i == 1 and self.StationViewType.MoveTo01 or self.StationViewType.MoveTo02

						break
					end

					table.insert(candidates, 1, candidate)
					table.insert(candidateIndex, 1, string.format("%02d", curIndex - 1))
				end
			end

			curIndex = luaIndex

			table.insert(candidates, stations[curIndex])
			table.insert(candidateIndex, string.format("%02d", curIndex - 1))

			for i = 1, count do
				candidate, curIndex = self:GetCandidate(stations, curIndex, 1, ignoreNum)

				table.insert(candidates, candidate)
				table.insert(candidateIndex, string.format("%02d", curIndex - 1))
			end
		else
			local count = 2

			if luaIndex == #stations then
				viewType = self.StationViewType.MoveTo06
				count = 4
				luaIndex = #stations - 1
			else
				for i = 1, count do
					candidate, curIndex = self:GetCandidate(stations, curIndex, 1, ignoreNum)

					if curIndex < luaIndex then
						count = 5 - i
						viewType = i == 1 and self.StationViewType.MoveTo05 or self.StationViewType.MoveTo04

						break
					end

					table.insert(candidates, candidate)
					table.insert(candidateIndex, string.format("%02d", curIndex - 1))
				end
			end

			curIndex = luaIndex

			table.insert(candidates, 1, stations[curIndex])
			table.insert(candidateIndex, 1, string.format("%02d", curIndex - 1))

			for i = 1, count do
				candidate, curIndex = self:GetCandidate(stations, curIndex, -1, ignoreNum)

				table.insert(candidates, 1, candidate)
				table.insert(candidateIndex, 1, string.format("%02d", curIndex - 1))
			end
		end
	end

	local inters = {}

	for i = 1, #candidates do
		local stationCfg = RailStationConfig.GetConfig(candidates[i])

		if not stationCfg then
			print_error("RailStationConfig is nil. key=", key, "stationId=", candidates[i])
		end

		local interchanges = stationCfg.Lines
		local inter = {}

		for j = 1, #interchanges do
			if not self:CheckSamePath(interchanges[j], pathId) then
				inter[interchanges[j]] = true
			end
		end

		table.insert(inters, inter)
	end

	self.candidatesCache[key] = {
		candidates = candidates,
		indexes = candidateIndex,
		viewType = viewType,
		inters = inters,
		time = Time.unscaledTime
	}

	return self.candidatesCache[key]
end

function M:ClearCache(clearAll)
	if clearAll then
		self.candidatesCache = {}
	else
		for k, v in pairs(self.candidatesCache) do
			if Time.unscaledTime - v.time > 1800 then
				self.candidatesCache[k] = nil
			end
		end
	end
end

function M:GetCandidate(stations, index, step, ignoreNum)
	local leftLimit = ignoreNum
	local rightLimit = #stations - ignoreNum
	index = index + step

	if rightLimit < index then
		index = leftLimit
	elseif index < leftLimit then
		index = rightLimit
	end

	while stations[index] == 0 do
		index = index + step

		if rightLimit < index then
			index = leftLimit
		elseif index < leftLimit then
			index = rightLimit
		end
	end

	return stations[index], index
end

function M:CheckSamePath(pathA, pathB)
	if pathA <= 2 and pathB <= 2 then
		return true
	end

	return pathA == pathB
end
