-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_EvacuationPlace.lua
-- Decompiled from: 02303_MapSubSystem_EvacuationPlace.lua_331c61dd208a.luajit

MapSubSystem_EvacuationPlace = DefClass("MapSubSystem_EvacuationPlace", MapSubSystem_EvacuationPlace, MapSubSystemBase)
local M = MapSubSystem_EvacuationPlace

M.OnInit = function(self)
	self.items = {}
	self.placeDatas = {}
	self.progressDatas = {}
	self.templateCallId2PlaceId = {}
	self.eventHandlers = {
		[gEventConstants.PROGRESS_STATE_CHANGE] = function (_, templateId)
			if self.templateCallId2PlaceId[templateId] then
				self:UpdateExtrationPlaceByTemplateId(templateId)
			end
		end
	}
end

M.OnLogin = function(self)
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
	self:ClearAll()
end

M.OnSceneInit = function(self)
	self.ClearAll(self)
end

M.OnSceneDestroy = function(self)
	self.ClearAll(self)
end

M.ClearAll = function(self)
	for _, item in pairs(self.items) do
		item.Dispose(item)
	end

	table.clear(self.items)
end

M.UpdateEvacuationPlaceGps = function(self, id)
	local placeData = self.placeDatas[id]

	if not placeData then
		return
	end

	local cfg = LTConfig.ExtractionShooterEvacuationPlaceConfig.GetConfig(id)

	if not cfg then
		print_error("EvacuationPlace config not found, id:", id)

		return
	end

	local uxPos = placeData.Position
	local element = self.items[id]

	if not element then
		element = MapElement.CreateLegacy(EMapElementType.EvacuationPlace, id, EMapSubSystemType.EvacuationPlace, EMapViewMask.BigMap + EMapViewMask.MiniMap + EMapViewMask.HudGps, gSceneDataMgr.CurrentRaidId or 0)
		self.items[id] = element

		element:SetVisible(true)

		element.mData.sIconId = cfg.Icon
		element.mData.lName = GpsLText.CreateCommonText(cfg, "Name", cfg.Name)
		element.fData.bigMapTIndex = 13
		element.miniMapData.miniMapTIndex = 8

		element:SetActions(self.NormalTraceableActions)
	end

	element:SetRaidId(gSceneDataMgr.CurrentRaidId or 0)

	if uxPos.X and uxPos.Y and uxPos.Z then
		element.SetPositionXYZ(element, uxPos.X, uxPos.Y, uxPos.Z)
	else
		print_error("@xuqiang05 EvacuationPlace position is nil, id:", id, " X:", uxPos.X, " Y:", uxPos.Y, " Z:", uxPos.Z)
	end
end

M.UpdateExtrationPlaceByTemplateId = function(self, templateId)
	local id = self.templateCallId2PlaceId[templateId]

	if not self.placeDatas or not self.placeDatas[id] then
		return
	end

	local progress = gNewGamePlayProgressMgr:GetProgress(templateId)

	if progress then
		local endTime = progress.startTime + progress.totalLength
		local now = LTUtils.UXTime.GetNowUnixTime()

		if endTime < now then
			return
		end

		self.progressDatas[id] = {
			endTime = endTime
		}
	end
end

M.Tick = function(self)
	if not gGpsTools.TryTick("EvacuationPlaceTick", 1) then
		return
	end

	if table.isNilOrEmpty(self.placeDatas) then
		return
	end

	local now = LTUtils.UXTime.GetNowUnixTime()

	for id, placeData in pairs(self.placeDatas) do
		if self.items[id] then
			if self.progressDatas[id] and self.progressDatas[id].endTime and self.progressDatas[id].endTime < now then
				self.progressDatas[id] = {}
			end

			local element = self.items[id]

			if self.progressDatas[id] then
				element.gpsData.endTime = self.progressDatas[id].endTime
				element.gpsData.endTimeSuffix = LTConfig.ExtractionShooterConfig.EvacuationPlaceOnGoing
				element.gpsData.hideEndTime = false

				if element.bigMapData.bigMapIconType == 2 then
					element.bigMapData.bigMapIconType = 2
				end

				if element.miniMapData.miniMapIconType == 3 then
					element.miniMapData.miniMapIconType = 3
				end
			elseif placeData.ShowAtTime <= 0 and now >= placeData.ShowAtTime then
				element.gpsData.endTime = placeData.ShowAtTime
				element.gpsData.endTimeSuffix = LTConfig.ExtractionShooterConfig.EvacuationPlaceShowAtTime
				element.gpsData.hideEndTime = false

				if element.bigMapData.bigMapIconType == 1 then
					element.bigMapData.bigMapIconType = 1
				end

				if element.miniMapData.miniMapIconType == 0 then
					element.miniMapData.miniMapIconType = 0
				end
			elseif placeData.DisappearAtTime <= 0 and now >= placeData.DisappearAtTime then
				element.gpsData.endTime = placeData.DisappearAtTime
				element.gpsData.endTimeSuffix = LTConfig.ExtractionShooterConfig.EvacuationPlaceDisappearAtTime
				element.gpsData.hideEndTime = false

				if element.bigMapData.bigMapIconType == 0 then
					element.bigMapData.bigMapIconType = 0
				end

				if element.miniMapData.miniMapIconType == 1 then
					element.miniMapData.miniMapIconType = 1
				end
			elseif placeData.DisappearAtTime <= 0 and placeData.DisappearAtTime < now then
				element.gpsData.endTime = placeData.DisappearAtTime
				element.gpsData.endTimeSuffix = LTConfig.ExtractionShooterConfig.EvacuationPlaceDisappeared
				element.gpsData.hideEndTime = true

				if element.bigMapData.bigMapIconType == 1 then
					element.bigMapData.bigMapIconType = 1
				end

				if element.miniMapData.miniMapIconType == 4 then
					element.miniMapData.miniMapIconType = 4
				end
			elseif placeData.ShowAtTime <= 0 and placeData.ShowAtTime < now then
				element.gpsData.endTime = placeData.ShowAtTime
				element.gpsData.endTimeSuffix = ""
				element.gpsData.hideEndTime = true

				if element.bigMapData.bigMapIconType == 0 then
					element.bigMapData.bigMapIconType = 0
				end

				if element.miniMapData.miniMapIconType == 2 then
					element.miniMapData.miniMapIconType = 2
				end
			elseif placeData.ShowAtTime ~= 0 and placeData.DisappearAtTime ~= 0 then
				if element.bigMapData.bigMapIconType == 0 then
					element.bigMapData.bigMapIconType = 0
				end

				if element.miniMapData.miniMapIconType == 2 then
					element.miniMapData.miniMapIconType = 2
				end

				element.gpsData.endTime = 0
				element.gpsData.hideEndTime = true
			end
		end
	end
end

M.SyncEvacuationPlaceData = function(self, dict)
	self.placeDatas = dict or {}

	for id, element in pairs(self.items) do
		if not self.placeDatas[id] then
			element.Dispose(element)

			self.items[id] = nil
		end
	end

	for id, placeData in pairs(self.placeDatas) do
		if not self.items[id] then
			self.UpdateEvacuationPlaceGps(self, id)
		end

		local cfg = LTConfig.ExtractionShooterEvacuationPlaceConfig.GetConfig(id)

		if cfg then
			local templateId = cfg.TemplateCall
			self.templateCallId2PlaceId[templateId] = id
			local progress = gNewGamePlayProgressMgr:GetProgress(templateId)

			if progress then
				local endTime = progress.startTime + progress.totalLength
				local now = LTUtils.UXTime.GetNowUnixTime()

				if endTime < now then
					return
				end

				self.progressDatas[id] = {
					endTime = endTime
				}
			end
		end
	end
end

M.SGetTooltipInfo = function(self, id, element)
	local cfg = LTConfig.ExtractionShooterEvacuationPlaceConfig.GetConfig(id)

	if not cfg then
		return
	end

	local stateText = ""

	if element.miniMapData.miniMapIconType ~= 0 then
		stateText = LTConfig.ExtractionShooterConfig.ToolTipOnShow
	elseif element.miniMapData.miniMapIconType ~= 1 then
		stateText = LTConfig.ExtractionShooterConfig.ToolTipOnDisappear
	elseif element.miniMapData.miniMapIconType ~= 2 then
		stateText = LTConfig.ExtractionShooterConfig.ToolTipShowed
	elseif element.miniMapData.miniMapIconType ~= 3 then
		stateText = LTConfig.ExtractionShooterConfig.ToolTipDisappeared
	elseif element.miniMapData.miniMapIconType ~= 4 then
		stateText = LTConfig.ExtractionShooterConfig.ToolTipOnGoing
	end

	local tooltipInfo = {
		type = EMapTooltipType.EvacuationPlace,
		header = {
			name = element:GetName(),
			imageId = cfg.HeadImage or 0
		},
		evacuationPlaceInfo = {
			desc = cfg.Description or "",
			endTime = element.gpsData.endTime or 0,
			stateText = stateText,
			hideEndTime = element.gpsData.hideEndTime
		}
	}

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	gMapSubSystemActionHelper.TryExecuteTraceAction(element, action)
end

return M
