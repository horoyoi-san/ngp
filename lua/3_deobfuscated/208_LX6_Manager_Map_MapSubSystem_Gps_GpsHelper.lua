GpsHelper = GpsHelper or {}
local M = GpsHelper

function M.GetGpsPositionByGpsInfo(gpsInfo)
	local position = nil

	if gpsInfo.worldPos then
		position = GpsHelper.GetGpsTargetPosition(gpsInfo.worldPos, gpsInfo.metroLineId, gpsInfo.metroCarriageId)
	else
		gpsInfo.element:ForceUpdateBinding()

		return gpsInfo.element:GetWorldPos()
	end

	return position
end

function M.GetGpsTargetPosition(targetPos, metroLineId, metroCarriageId)
	if not metroLineId or metroLineId == 0 or not metroCarriageId or metroCarriageId <= 0 then
		return targetPos
	end

	return MassAI.Metro.MetroManager.Instance:GetGlobalPositionByLineCarriageAndRelativePosition(metroLineId, metroCarriageId, targetPos)
end

function M.GetUnitGpsPosition(unitPid, useFeiSuoPoint, vec)
	local spawnInfo = nil
	local agentId = 0
	local unit = nil

	if not ulong.check(unitPid) then
		spawnInfo = gCS.SpoonAgentMgr:GetSpawnBySpoonId(unitPid)

		if not spawnInfo then
			return
		end

		agentId = spawnInfo.pid

		if spawnInfo.metroLineId ~= 0 and not gCS.BaseUnitUtils.SpoonAgentIsReallyOnMetro(agentId) then
			local pos = MassAI.Metro.MetroManager.Instance:GetGlobalPositionByLineCarriageAndRelativePosition(spawnInfo.metroLineId, spawnInfo.metroCarriageId, spawnInfo.position)

			vec:Set(pos.x, pos.y, pos.z)

			return
		end
	else
		agentId = unitPid
	end

	if agentId ~= 0 then
		unit = gCS.SceneDataMgr.GetUnit(agentId)
	end

	if unit and unit.CanUseRes then
		local tran = nil

		if useFeiSuoPoint then
			if not unit.ModelSlot or not unit.ModelSlot.feisuoPoint then
				print_error("@shenrui 策划配置有误，飞索点没有配ModelSlot或者feisuoPoint！", " Pid:", unit.Pid, " npcId", unit.ClientData.SubType, " objName", unit.PlayerObj.name)

				return
			end

			tran = unit.ModelSlot.feisuoPoint

			gUtils:GetTransformPosition(vec, tran)
		else
			tran = unit.ModelSlot.headSlot

			gUtils:GetTransformPosition(vec, tran)

			local offsetY = spawnInfo and spawnInfo.gpsOffsetY or 0

			if offsetY == 0 then
				local cfg = LTConfig.AgentConfig.GetConfig(unit.ClientData.SubType)
				local interactCfg = gInteractionManager:GetAgentInteractConfig(cfg)
				offsetY = interactCfg and interactCfg.BtnOffsetY or 0
			end

			vec:Set(vec.x, vec.y + offsetY, vec.z)
		end

		return
	end

	if spawnInfo then
		local pos = spawnInfo.position

		vec:Set(pos.x, pos.y, pos.z)

		return
	end
end

function M.GetSlotGpsPosition(slotPid, slotRefId, slotRefName, vec)
	local slotInstance = gGadgetManager:GetEntitySearchByInstanceId(slotPid)

	if slotInstance then
		if slotRefId and slotRefId ~= 0 then
			local go = slotInstance.gameObjectMap[slotRefId]
			local tran = go and go.transform

			if tran then
				gUtils:GetTransformPosition(vec, tran)
			end
		elseif slotRefName and not string.is_null_or_empty(slotRefName) then
			local gameObjectMap = slotInstance:GetGameObjectMap()
			local go = nil

			for i, v in pairs(gameObjectMap) do
				if not gCS.LuaUtils.IsNull(v) and v.name == slotRefName then
					go = v

					break
				end
			end

			if not gCS.LuaUtils.IsNull(go) then
				gUtils:GetTransformPosition(vec, go.transform)
			else
				gUtils:GetTransformPosition(vec, slotInstance.gameObject.transform)
			end
		else
			local tran = gGadgetManager:GetInteractPosByPid(slotPid)

			gUtils:GetTransformPosition(vec, tran)
		end
	end
end

function M.GetDestructiblePosition(DestructibleInstanceId, vec)
	local desItem = gCS.DestructibleMgr:GetDestructibleByUniqueId(DestructibleInstanceId)

	if desItem then
		gUtils:GetTransformPosition(vec, desItem.transform)
	end
end

function M.GetVehiclePosition(vehicleUnitId, vehiclePartNodeName, needEulerY, vec)
	local vehicleUnit = LX6.Drive.DriveUtils.GetVehicleInScene(vehicleUnitId)

	if vehicleUnit then
		local eulerY = nil

		if needEulerY then
			eulerY = vehicleUnit.transform.eulerAngles.y
		end

		if not string.is_null_or_empty(vehiclePartNodeName) then
			local partGo = gCS.DriveManager:GetVehiclePart(vehicleUnitId, vehiclePartNodeName)

			if partGo then
				gUtils:GetTransformPosition(vec, partGo.transform)

				return eulerY
			end
		end

		gUtils:GetTransformPosition(vec, vehicleUnit.transform)

		return eulerY
	end

	return nil
end

M._static_Vehicle_PartNode_Enum_To_Name = {
	"LFDoor",
	"RFDoor",
	"LBDoor",
	"RBDoor",
	"Top",
	"FreePos1",
	"FreePos2"
}

function M.TranslateVehicleNodeEnumToNodeName(vehicleGpsNodeEnum)
	return M._static_Vehicle_PartNode_Enum_To_Name[vehicleGpsNodeEnum + 1]
end

M._static_WaitEvent_Cache = {}
M._static_GpsWaitingEventHolder_Cache = {}

function M.TryRegisterGpsHandler(gpsInfo)
	local keys = GpsHelper._ParseEventKeys(gpsInfo)

	if not keys or #keys <= 0 then
		return false
	end

	local gpsId = gpsInfo.gpsId
	local gpsEventHolder = GpsWaitingEventHolder.New(gpsInfo, keys)
	M._static_GpsWaitingEventHolder_Cache[gpsId] = gpsEventHolder

	for _, v in ipairs(keys) do
		local messageKey = v

		if not M._static_WaitEvent_Cache[messageKey] then
			gMessageManager:AddMessageListener(messageKey, M._HandleGpsEvent)

			M._static_WaitEvent_Cache[messageKey] = {}
		end

		local l = M._static_WaitEvent_Cache[messageKey]

		table.insert(l, gpsId)
	end

	return true
end

function M.UnregisterGpsHandler(gpsId)
	local holder = M._static_GpsWaitingEventHolder_Cache[gpsId]

	if not holder then
		return
	end

	M._static_GpsWaitingEventHolder_Cache[gpsId] = nil
	local keys = holder:GetAllGpsEventKeys()

	holder:Dispose()

	local remove_l = {}

	for _, v in ipairs(keys) do
		local messageKey = v
		local l = M._static_WaitEvent_Cache[messageKey]

		if l then
			table.removeEx(l, gpsId)
		end

		if #l <= 0 then
			table.insert(remove_l, messageKey)
		end
	end

	if #remove_l > 0 then
		for _, v in ipairs(remove_l) do
			gMessageManager:RemoveMessageListener(v, M._HandleGpsEvent)

			M._static_WaitEvent_Cache[v] = nil
		end
	end
end

function M._HandleGpsEvent(eventId, data)
	local key = eventId
	local holderIds = M._static_WaitEvent_Cache[key]

	if not holderIds then
		return
	end

	for _, holderId in ipairs(holderIds) do
		local holder = M._static_GpsWaitingEventHolder_Cache[holderId]

		if holder then
			holder:HandleGpsEvent(key, data)
		end
	end
end

function M._ParseEventKeys(gpsData)
	local eventKeys = {}

	if gpsData.defaultHideUtilScan then
		table.insert(eventKeys, gEventConstants.SCAN_START)
	end

	return eventKeys
end

function M.CheckHasSlotGPSTarget(slotPid)
	if gGpsBindingMgr:PidHasHudGps(slotPid) then
		return true
	else
		return false
	end
end

GpsHelper = M
