-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_NearByMisc.lua
-- Decompiled from: 02335_MapSubSystem_NearByMisc.lua_c2f06930d8f0.luajit

local MainViewUtils = LX6.Gps.MainViewUtils
MapSubSystem_NearByMisc = DefClass("MapSubSystem_NearByMisc", MapSubSystem_NearByMisc, MapSubSystemBase)
local M = MapSubSystem_NearByMisc

M.OnInit = function(self)
	slot1 = gMessageManager

	slot1:AddMessageListener(gEventConstants.TASK_SWITCH_NEAR_PHOTO_GPS, function (eventId, data)
		self:OnSwitchNearPhotoGps(data)
	end)

	self._commonFeisuoElem = nil
end

M.OnLogin = function(self)
	self._takeAPhotoInfo = {}
	self._taskFeiSuoElem = nil
	self._taskFeiSuoData = nil
	self.canUseTaskFeiSuo = false
	self._taskFeiSuoVisible = false
end

M.OnLogout = function(self)
	if self._commonFeisuoElem then
		self._commonFeisuoElem:Dispose()

		self._commonFeisuoElem = nil
	end
end

M.DisposeTaskFeiSuoElem = function(self)
	if self._taskFeiSuoElem then
		self._taskFeiSuoElem:Dispose()

		self._taskFeiSuoElem = nil
	end
end

M.TickTaskFeiSuo = function(self)
	if self._taskFeiSuoData ~= nil or self._taskFeiSuoData.ForceHide or gDriveVehiclesManager.cs_manager.isDriveMode then
		self.DisposeTaskFeiSuoElem(self)

		return
	end

	local targetTransform, tmp_checkInfo = nil
	self.canUseTaskFeiSuo = false
	local position = Vector3.zero

	if self._taskFeiSuoData.UnitPid and not ulong.equals(self._taskFeiSuoData.UnitPid, 0) then
		tmp_checkInfo = {
			id = self._taskFeiSuoData.UnitPid,
			type = gTaskGpsTargetType.Npc
		}

		GpsHelper.GetUnitGpsPosition(self._taskFeiSuoData.UnitPid, true, position)

		if gUtils:IsPositionZero(position) then
			position = nil
		end

		self._taskFeiSuoData.TargetPos = position
	elseif self._taskFeiSuoData.VehicleUid and not ulong.equals(self._taskFeiSuoData.VehicleUid, 0) then
		tmp_checkInfo = {
			id = self._taskFeiSuoData.VehicleUid,
			type = gTaskGpsTargetType.Vehicle
		}
		local vehicleUnit = gDriveVehiclesManager:GetBaseVehicle(self._taskFeiSuoData.VehicleUid)

		if vehicleUnit then
			targetTransform = vehicleUnit.GetFeiSuoPoint(vehicleUnit)
		end
	elseif self._taskFeiSuoData.SlotPid and not ulong.equals(self._taskFeiSuoData.SlotPid, 0) then
		tmp_checkInfo = {
			id = self._taskFeiSuoData.SlotPid,
			type = gTaskGpsTargetType.LuaSlot
		}
		local unit = gGadgetManager:GetEntitySearchByInstanceId(self._taskFeiSuoData.SlotPid)

		if unit then
			targetTransform = unit.gameObject.transform
			local slotRefName = self._taskFeiSuoData.SlotRefName

			if slotRefName then
				if unit.GetGameObjectById then
					local gameObjectMap = unit:GetGameObjectMap():ToTable()
					local go = nil

					for i, v in pairs(gameObjectMap) do
						if not gCS.LuaUtils.IsNull(v) and v.name ~= slotRefName then
							go = v

							break
						end
					end

					if not gCS.LuaUtils.IsNull(go) then
						targetTransform = go.transform
					end
				elseif not unit.gameObjectRoot[slotRefName] then
					targetTransform = unit.gameObject.transform
				else
					local trans = unit.gameObjectRoot[slotRefName][0].transform
					targetTransform = trans
				end
			end
		end
	end

	if not targetTransform and not self._taskFeiSuoData.TargetPos then
		self.DisposeTaskFeiSuoElem(self)

		return
	end

	if not self._taskFeiSuoElem then
		self._taskFeiSuoElem = MapElement.CreateLegacy(EMapElementType.TaskFeiSuo, "UniqueTaskFeiSuo", EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
	end

	local targetPos = targetTransform and targetTransform.position or self._taskFeiSuoData.TargetPos
	local feisuoVisible = true
	local clamped, _, _ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(targetPos, gMapSystem.ui.hudEllipseRT, nil, )

	if clamped then
		feisuoVisible = false
	end

	self._taskFeiSuoVisible = feisuoVisible

	self._taskFeiSuoElem:SetVisible(feisuoVisible)

	if feisuoVisible then
		self.canUseTaskFeiSuo = true

		self._taskFeiSuoElem:SetPosition(targetPos)
		self._taskFeiSuoElem:SetTraceInfo(EMapGTraceType.Other, 0)
	else
		self._taskFeiSuoElem:ClearTraceInfo()
	end

	self._taskFeiSuoElem.fData.hudTIndex = 4
end

M.Tick = function(self)
end

M.IsTaskFeiSuoVisible = function(self)
	return self._taskFeiSuoElem and self._taskFeiSuoVisible
end

M.OnSwitchNearPhotoGps = function(self, data)
	local npcId = data.npcId

	if not npcId then
		return
	end

	if not data.isChange then
		local element = self._takeAPhotoInfo[npcId]

		if element then
			element.Dispose(element)

			self._takeAPhotoInfo[npcId] = nil
		end
	else
		local element = self._takeAPhotoInfo[npcId]

		if not element then
			element = MapElement.CreateLegacy(EMapElementType.TakeAPhoto, npcId, EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
			element.fData.hudTIndex = 3

			if data.centerPosition then
				element.SetPosition(element, data.centerPosition)
			else
				element.BindUnit(element, npcId)
				element.SetPosition(element, Vector3.zero)
			end

			element.SetTraceInfo(element, EMapGTraceType.Main, 1, true)
			element.SetVisible(element, true)

			element.mData.ignoreIndoorPenetration = true
			self._takeAPhotoInfo[npcId] = element
		end
	end
end

M.AddTaskFeiSuo = function(self, legacyTaskFeiSuoData)
	self._taskFeiSuoData = legacyTaskFeiSuoData
end

M.RemoveTaskFeiSuo = function(self)
	self._taskFeiSuoData = nil
	self._taskFeiSuoVisible = false
end

M.CS_ShowOrHideTaskFeiSuo = function(self, enable, targetPos)
	self._taskFeiSuoVisible = enable

	if enable then
		if not self._taskFeiSuoElem then
			self._taskFeiSuoElem = MapElement.CreateLegacy(EMapElementType.TaskFeiSuo, "UniqueTaskFeiSuo", EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
		end

		self._taskFeiSuoElem:SetVisible(true)
		self._taskFeiSuoElem:SetPosition(targetPos)
		self._taskFeiSuoElem:SetTraceInfo(EMapGTraceType.Other, 0)

		self._taskFeiSuoElem.fData.hudTIndex = 4
	elseif self._taskFeiSuoElem then
		self._taskFeiSuoElem:SetVisible(false)
		self._taskFeiSuoElem:ClearTraceInfo()
	end
end

M.CS_RemoveTaskFeiSuo = function(self)
	self._taskFeiSuoVisible = false

	self.DisposeTaskFeiSuoElem(self)
end

M.AddCommonFeisuo = function(self, x, y, z)
	if not self._commonFeisuoElem then
		self._commonFeisuoElem = MapElement.CreateLegacy(EMapElementType.CommonFeisuo, "CommonFeisuo", EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
		self._commonFeisuoElem.fData.hudTIndex = 6
		self._commonFeisuoElem.mData.ignoreIndoorPenetration = true

		self._commonFeisuoElem:SetTraceInfo(EMapGTraceType.NearBy, 0)
		self._commonFeisuoElem:SetVisible(true)
	end

	self._commonFeisuoElem:SetRaidId(gMapSystem.lastRaidId)

	self._commonFeisuoElem.gpsData.tmp_Hide = self._commonFeisuoForceHide ~= true

	self._commonFeisuoElem:SetPositionXYZ(x, y, z)
end

M.RemoveCommonFeisuo = function(self)
	if not self._commonFeisuoElem then
		return
	end

	self._commonFeisuoElem.gpsData.tmp_Hide = true
end

M.SetCommonFeisuoHide = function(self, hide)
	self._commonFeisuoForceHide = hide ~= true

	if not self._commonFeisuoElem then
		return
	end

	self._commonFeisuoElem.gpsData.tmp_Hide = hide ~= true
end

M.CheckHasTaskFeisuo = function(self, feisuoId)
	return feisuoId == 0 and self._taskFeiSuoData and self._taskFeiSuoData.TaskFeiSuoId ~= feisuoId
end

return M
