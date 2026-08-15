MapSubSystem_LegacyGps = DefClass("MapSubSystem_LegacyGps", MapSubSystem_LegacyGps, MapSubSystemBase)
local M = MapSubSystem_LegacyGps

function M:OnInit()
	self.gpsInfos = {}
	self.eventHandlers = {
		[gEventConstants.Add_GPS] = function (eventId, data)
			self:AddGps(data)
		end,
		[gEventConstants.REMOVE_GPS] = function (eventId, data)
			self:RemoveGps(data.instanceId)
		end,
		[gEventConstants.UPDATE_GPS] = function (eventId, data)
			self:AddGps(data)
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:AddGps(data)
	if table.isNilOrEmpty(data) then
		return
	end

	if type(data) ~= "table" then
		data = data:ToTable()
	end

	if data.legacyOnly or data.GpsType == gTaskGpsType.Forward or data.ForceHide then
		return
	end

	local viewMask = EMapViewMask.MiniMap + EMapViewMask.HudGps

	if data.viewMask then
		viewMask = data.viewMask
	elseif not table.contains(gMapManager.ShowGpsTypeInMap, data.GpsType) then
		viewMask = EMapViewMask.HudGps
	elseif data.mask and not table.contains(data.mask, gGpsMaskType.MINIMAP) then
		viewMask = EMapViewMask.HudGps
	end

	if data.InstanceId == 0 then
		return
	end

	local gpsId = data.InstanceId
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element then
		return
	end

	if not data.SIconId then
		if gGameManager.Env.isEditor then
			print_warn("AddGps调用处缺少SGUI IconId!")
		end

		return
	end

	if not data.TargetPos and not data.UnitPid and not data.SlotPid and not data.VehicleUid and not data.DestructibleInstanceId then
		print_warn("AddGps data.TargetPos is nil, id = ", data.InstanceId)

		return
	end

	local worldPos = data.TargetPos
	local indoorId = data.IndoorId or 0
	local info = self.gpsInfos[gpsId]

	if not info then
		info = {}
		self.gpsInfos[gpsId] = info
		info.element = MapElement.CreateLegacy(EMapElementType.Gps, gpsId, EMapSubSystemType.LegacyGps, viewMask, data.RaidId, indoorId)
	end

	element = info.element
	element.mData.sIconId = data.SIconId
	element.gpsData.tmp_HudAutoHideDistance = data.AutoHideDistance
	element.gpsData.tmp_HudAutoShowDistance = data.AutoShowDistance
	element.gpsData.isHudHideDistanceText = data.HideDistance or false
	element.gpsData.ignoreIndoorPenetration = data.HudIgnoreAreaDiff or false
	element.gpsData.tmp_HideIfClamped = data.HideIfClamped

	if data.OverrideIndoorId or data.OverrideLocalBoundId then
		element:SetOverrideBoundInfo(data.OverrideIndoorId or 0, data.OverrideLocalBoundId or 0)
	end

	if data.AsEntryOfIndoorId then
		element:SetRelatedIndoorId(data.AsEntryOfIndoorId)
	end

	if data.RepresentGBoundId then
		element.fData.representGBoundId = data.RepresentGBoundId
	end

	if data.HasTargetEffect ~= nil then
		element.gpsData.tmp_IsHudDisableHintAnim = not data.HasTargetEffect
	else
		element.gpsData.tmp_IsHudDisableHintAnim = false
	end

	if data.isProgress then
		element.fData.hudTIndex = 5
	end

	info.gpsId = gpsId
	info.worldPos = worldPos
	info.enable = true
	info.traceType = EMapGTraceType.Other
	info.defaultTrace = true
	info.defaultHideUtilScan = data.DefaultHideUtilScan or false
	info.durationWhenScan = data.DurationWhenScan or 0
	info.systemLockId = data.SystemLockId or 0

	if data.SlotPid and data.SlotPid ~= 0 then
		element.gpsData.hudInteractionConflictInfo = {
			id = data.SlotPid,
			type = gTaskGpsTargetType.LuaSlot
		}
	end

	if data.UnitId or data.UnitPid then
		element:BindUnit(data.UnitId or data.UnitPid)
	elseif data.VehicleUid then
		element:BindVehicle(data.VehicleUid, data.VehiclePartNodeName)
	elseif data.SlotPid then
		element:BindSlotInfo(data.SlotPid, data.SlotRefId, data.SlotRefName)
	elseif data.DestructibleInstanceId then
		element:BindDestructible(data.DestructibleInstanceId)
	end

	if data.lName then
		element.mData.lName = data.lName
	end

	if not GpsHelper.TryRegisterGpsHandler(info) then
		if worldPos then
			element:SetPosition(worldPos)
		end

		info.enable = true

		element:SetVisible(true)
		element:SetTraceInfo(data.traceType or EMapGTraceType.Other, data.traceLayer or 0)
	else
		info.enable = false
	end

	return element
end

function M:RemoveGps(gpsId)
	local info = self.gpsInfos[gpsId]

	if not info then
		return
	end

	local element = info.element

	if element then
		element:ClearTraceInfo()
		element:Dispose()
	end

	GpsHelper.UnregisterGpsHandler(gpsId)

	self.gpsInfos[gpsId] = nil
end

function M:Tick()
	for _, gpsInfo in pairs(self.gpsInfos) do
		if gpsInfo.systemLockId and gpsInfo.systemLockId ~= 0 then
			local element = gpsInfo.element

			if gSystemUnlockMgr:IsUnlock(gpsInfo.systemLockId) then
				element:SetVisible(true)
				element:SetTraceInfo(EMapGTraceType.Other, 0)
			else
				element:SetVisible(false)
				element:ClearTraceInfo()
			end
		end
	end
end

return M
