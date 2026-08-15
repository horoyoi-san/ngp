local M = C_MiniMapPanelStore

function M:InitDetectRangeInfo()
	self._detectRangeInfos = {}
	self._detectRangeVisible = false
end

function M:TryAddOrRemoveDetectRange(id, info)
	local store = info.store
	self._detectRangeInfos[id] = nil
	store.showDetectRange = 0
	local element = info.mapElement
	local detectRangeInfo = element.miniMapData.detectRangeInfo

	if detectRangeInfo then
		self._detectRangeInfos[id] = {
			unit = detectRangeInfo.unit,
			type = detectRangeInfo.type,
			vehicle = detectRangeInfo.vehicle,
			store = store
		}

		if detectRangeInfo.type == 1 then
			store.showDetectRange = 1
		else
			store.showDetectRange = self._detectRangeVisible and 1 or 0
		end

		local detectRangeRT = store.detectRangeRT

		if detectRangeRT then
			if detectRangeInfo.type == 0 then
				detectRangeRT:SetLocalScaleXY(1, 1)
			elseif detectRangeInfo.type == 1 then
				local scale = LTConfig.GpsConfig.CbtChasingCarDetectRangeScale

				detectRangeRT:SetLocalScaleXY(scale, scale)
			end
		end

		local leftLine = store.leftLine
		local rightLine = store.rightLine
		local circle = store.circleRT

		if not leftLine then
			print_error("@xiajingbo01 MiniMapPanelStore TryAddOrRemoveDetectRange leftLine nil tIndex:" .. element.miniMapData.miniMapTIndex .. " gpsId:" .. element.gpsId)

			self._detectRangeInfos[id] = nil
			store.showDetectRange = 0

			return
		end

		local angle = detectRangeInfo.angle
		store.circleFill = angle / 360

		circle:SetLocalEulerAnglesZ(-angle / 2 - 45)
		leftLine:SetLocalEulerAnglesZ(angle / 2)
		rightLine:SetLocalEulerAnglesZ(-angle / 2)
	end
end

function M:TryRemoveDetectRange(id)
	self._detectRangeInfos[id] = nil
end

function M:TickDetectRanges()
	local gameplayUtils = L50.L50App.Scene.GamePlayUtils
	local toRemove = {}

	for id, info in pairs(self._detectRangeInfos) do
		if info.type == 0 and gameplayUtils:UnitIsNull(info.unit) or info.type == 1 and not info.vehicle then
			table.insert(toRemove, id)
		elseif info.store then
			if info.store.rotateRT then
				local eulerZ = 0

				if info.type == 0 then
					eulerZ = info.unit.EulerY
				elseif info.type == 1 then
					eulerZ = 0
				end

				info.store.rotateRT:SetLocalEulerAnglesZ(-eulerZ)
			end
		end
	end

	for _, id in ipairs(toRemove) do
		self._detectRangeInfos[id] = nil
		local info = self._id2ElementInfo[id]

		if info then
			info.store.showDetectRange = 0
		end
	end
end

function M:UpdateDetectRangeVisibility(eventId, isProwling)
	self._detectRangeVisible = isProwling

	for _, info in pairs(self._detectRangeInfos) do
		if info.store then
			info.store.showDetectRange = self._detectRangeVisible and 1 or 0
		end
	end
end
