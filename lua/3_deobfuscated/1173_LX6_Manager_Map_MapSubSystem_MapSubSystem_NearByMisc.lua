local MainViewUtils = LX6.Gps.MainViewUtils
MapSubSystem_NearByMisc = DefClass("MapSubSystem_NearByMisc", MapSubSystem_NearByMisc, MapSubSystemBase)
local M = MapSubSystem_NearByMisc

function M:OnInit()
	gMessageManager:AddMessageListener(gEventConstants.TASK_SWITCH_NEAR_PHOTO_GPS, function (eventId, data)
		self:OnSwitchNearPhotoGps(data)
	end)

	self._commonFeisuoElem = nil
end

function M:OnLogin()
	self._takeAPhotoInfo = {}
	self._taskFeiSuoElem = nil
	self._taskFeiSuoData = nil
	self.canUseTaskFeiSuo = false
	self._taskFeiSuoVisible = false
end

function M:OnLogout()
	if self._commonFeisuoElem then
		self._commonFeisuoElem:Dispose()

		self._commonFeisuoElem = nil
	end
end

function M:DisposeTaskFeiSuoElem()
	if self._taskFeiSuoElem then
		self._taskFeiSuoElem:Dispose()

		self._taskFeiSuoElem = nil
	end
end

function M:TickTaskFeiSuo()
	if self._taskFeiSuoData == nil or self._taskFeiSuoData.ForceHide or gDriveVehiclesManager.cs_manager.isDriveMode then
		self:DisposeTaskFeiSuoElem()

		return
	end

	local targetTransform, tmp_checkInfo = nil
	self.canUseTaskFeiSuo = false
	local position = Vector3.zero

	if self._taskFeiSuoData.UnitPid then
		tmp_checkInfo = {
			id = self._taskFeiSuoData.UnitPid,
			type = gTaskGpsTargetType.Npc
		}

		GpsHelper.GetUnitGpsPosition(self._taskFeiSuoData.UnitPid, true, position)

		if gUtils:IsPositionZero(position) then
			position = nil
		end

		self._taskFeiSuoData.TargetPos = position
	elseif self._taskFeiSuoData.VehicleUid then
		tmp_checkInfo = {
			id = self._taskFeiSuoData.VehicleUid,
			type = gTaskGpsTargetType.Vehicle
		}
		local vehicleUnit = gDriveVehiclesManager:GetBaseVehicle(self._taskFeiSuoData.VehicleUid)

		if vehicleUnit then
			targetTransform = vehicleUnit:GetFeiSuoPoint()
		end
	elseif self._taskFeiSuoData.SlotPid then
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
						if not gCS.LuaUtils.IsNull(v) and v.name == slotRefName then
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
		self:DisposeTaskFeiSuoElem()

		return
	end

	if not self._taskFeiSuoElem then
		self._taskFeiSuoElem = MapElement.CreateLegacy(EMapElementType.TaskFeiSuo, "UniqueTaskFeiSuo", EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
	end

	local targetPos = targetTransform and targetTransform.position or self._taskFeiSuoData.TargetPos
	local feisuoVisible = true
	local clamped, _, _ = MainViewUtils.TryEllipseClampWorldPos2UIWorldPos(targetPos, gMapSystem.ui.hudEllipseRT, nil, nil)

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

function M:Tick()
	self:TickTaskFeiSuo()
end

function M:IsTaskFeiSuoVisible()
	return self._taskFeiSuoElem and self._taskFeiSuoVisible
end

function M:OnSwitchNearPhotoGps(data)
	local npcId = data.npcId

	if not npcId then
		return
	end

	if not data.isChange then
		local element = self._takeAPhotoInfo[npcId]

		if element then
			element:Dispose()

			self._takeAPhotoInfo[npcId] = nil
		end
	else
		local element = self._takeAPhotoInfo[npcId]

		if not element then
			element = MapElement.CreateLegacy(EMapElementType.TakeAPhoto, npcId, EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
			element.fData.hudTIndex = 3

			element:BindUnit(npcId)
			element:SetPosition(Vector3.zero)
			element:SetTraceInfo(EMapGTraceType.Main, 1, true)
			element:SetVisible(true)

			element.gpsData.ignoreIndoorPenetration = true
			self._takeAPhotoInfo[npcId] = element
		end
	end
end

function M:AddTaskFeiSuo(legacyTaskFeiSuoData)
	self._taskFeiSuoData = legacyTaskFeiSuoData
end

function M:RemoveTaskFeiSuo()
	self._taskFeiSuoData = nil
	self._taskFeiSuoVisible = false
end

function M:AddCommonFeisuo(x, y, z)
	if not self._commonFeisuoElem then
		self._commonFeisuoElem = MapElement.CreateLegacy(EMapElementType.CommonFeisuo, "CommonFeisuo", EMapSubSystemType.NearByMisc, EMapViewMask.NearBy, gMapSystem.lastRaidId)
		self._commonFeisuoElem.fData.hudTIndex = 6
		self._commonFeisuoElem.gpsData.ignoreIndoorPenetration = true

		self._commonFeisuoElem:SetTraceInfo(EMapGTraceType.NearBy, 0)
	end

	self._commonFeisuoElem:SetRaidId(gMapSystem.lastRaidId)
	self._commonFeisuoElem:SetVisible(true)
	self._commonFeisuoElem:SetPositionXYZ(x, y, z)
end

function M:RemoveCommonFeisuo()
	if not self._commonFeisuoElem then
		return
	end

	self._commonFeisuoElem:SetVisible(false)
end

function M:CheckHasTaskFeisuo(feisuoId)
	return feisuoId ~= 0 and self._taskFeiSuoData and self._taskFeiSuoData.TaskFeiSuoId == feisuoId
end

return M
