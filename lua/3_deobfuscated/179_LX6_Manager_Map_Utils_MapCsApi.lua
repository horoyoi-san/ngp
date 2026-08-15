gMapCsApi = gMapCsApi or {}
local M = gMapCsApi
local TaskTitle = require("LX6/Manager/Task/TaskTitle")

function M:GetAllDirtySwap()
	return gMapSystem.container._dirtyInstanceIds
end

function M:GetBoundsDirtySwap()
	return gMapSystem.container._boundsDirtySwap
end

EBigMapSpoonOpenMode = {
	Metro = 1,
	Normal = 0
}

function M:SpoonShowBigMap(mode, metroEntranceId)
	if not gPanelManager:CheckCanPanelShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL) then
		print("ShowBigMap Fail, panel not ready")

		return
	end

	if mode == EBigMapSpoonOpenMode.Metro then
		gMainPageManager:LockMainPage(LTConfig.PanelConfig.S_NEW_MAP_PANEL)
		gPanelManager:CheckShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL, {
			metroMode = true,
			curMetroEntranceId = metroEntranceId
		})
	elseif mode == EBigMapSpoonOpenMode.Normal then
		gPanelManager:CheckShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL)
	else
		print_error("SpoonShowBigMap Error, unknown mode: ", mode)

		return
	end
end

function M:Legacy_DoFightMapEntrance(mapEntranceId)
	gClientToGameDelegate:AskTouchMapEntrance(gRaidDataManager.RaidId, mapEntranceId)
end

function M:ShowMiniMapMessage()
	gMessageManager:SendMessage(gEventConstants.MAP_SHOW_MESSAGE)
end

function M:SpoonCallHideWorkActionGps(value)
	gMapSystem:SetSwitch(EMapSwitchType.HideWorkActionGps, value)
end

function M:SpoonCallAddVehicleGps(taskId, GpsType, isHideSceneIcon, vehicleUid)
	local traceLayerSelf = 0
	local sIconId = nil

	if taskId then
		local cfg = gTaskManager:GetTaskConfigInfo(taskId)
		sIconId = gTaskManager.TaskSIconId[cfg.Title]

		if cfg.Title == TaskTitle.Situational then
			traceLayerSelf = 1
		end
	else
		sIconId = gTaskManager.TaskSIconId[gSpoonCommonData.gpsTypeToTaskType[GpsType]]
	end

	gMapSubSystem_Vehicle:AddTaskChaseCar(vehicleUid, gRaidDataManager.RaidId, sIconId, isHideSceneIcon and EMapViewMask.MiniMap or EMapViewMask.MiniMap + EMapViewMask.HudGps, traceLayerSelf)
end

function M:SpoonCallRemoveVehicleGps(vehicleUid)
	gMapSubSystem_Vehicle:RemoveTaskChaseCar(vehicleUid)
end

function M:SpoonCallRemoveGps(instanceId, paramGpsType)
	gMapSubSystem_TaskGps:DeleteGpsElement(instanceId)

	local gpsType = paramGpsType or gTaskGpsType.WeakGuide

	gGpsManager:RemoveGPSById(instanceId, gpsType or gTaskGpsType.WeakGuide)
	gMapSubSystem_LegacyGps:RemoveGps(instanceId)
end

function M:SetHudGpsHide(reason, hide)
	gMapSystem.ui:SetHudGpsHideReason(reason, hide)
end

local DOT_ICON_ID = 28001636

function M:AddGpsNodeAddGps(gpsId, taskId, gpsType, data)
	local iconType = data.iconType
	local paramSIconId = data.paramSIconId
	local WayPoint = data.WayPoint
	local DestructiblePointUniqueIds = data.DestructiblePointUniqueIds
	local DestructiblePointPoss = data.DestructiblePointPoss
	local Enemy = data.Enemy
	local EnemyGroup = data.EnemyGroup
	local DestructibleGroup = data.DestructibleGroup
	local DestructibleGroupPoss = data.DestructibleGroupPoss
	local GadgetNodeId = data.GadgetNodeId
	local GadgetUniqueId = data.GadgetUniqueId
	local targetType = data.targetType
	local Vehicle = data.Vehicle
	local VehiclePartNodeName = data.VehiclePartNodeName
	local visibleOnBigMap = data.visibleOnBigMap
	local defaultHideUtilScan = data.defaultHideUtilScan
	local durationWhenScan = data.durationWhenScan
	local refDestructible = data.refDestructible
	local gpsNameId = data.gpsNameId
	local tooltipImageId = data.tooltipImageId
	local tooltipDescId = data.tooltipDescId
	local showVehicleNav = data.showVehicleNav
	local relocatedByVehicleNavDest = data.relocatedByVehicleNavDest
	local autoBindToolTipId = data.autoBindToolTipId
	local gpsNameSourceType = data.gpsNameSourceType
	local isChasingVehicleTarget = data.isChasingVehicleTarget
	local isProgress = data.isProgress
	local progressNormalIcon = data.progressNormalIcon
	local progressFinishIcon = data.progressFinishIcon
	local progressId = data.progressId
	local showAsDot = data.showAsDot
	local ignoreIndoorPenetration = data.ignoreIndoorPenetration
	local hideInHUD = false
	local color = nil
	local dontTrace = false
	local gpsName = nil
	local tooltipDesc = ""
	local taskConfig = LTConfig.TaskConfig.GetConfig(taskId)

	if autoBindToolTipId then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)
		local taskLineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
		gpsName = taskConfig.Name
		tooltipImageId = taskLineCfg.SMapPhoto
		tooltipDesc = gUtils:GetSpecialDescription(taskLineInfo.EventDescription)
	else
		local InvokerTextConfig = LTConfig.TextCommonTextConfig.GetConfig

		if gpsNameId ~= nil then
			local gpsTextConfig = InvokerTextConfig(gpsNameId)
			gpsName = gpsTextConfig and gpsTextConfig.Text or nil
		end

		if tooltipDescId ~= nil then
			local tooltipDescTextConfig = InvokerTextConfig(tooltipDescId)
			tooltipDesc = tooltipDescTextConfig and tooltipDescTextConfig.Text or ""
		end
	end

	local taskTitle = nil

	if taskConfig then
		taskTitle = taskConfig.Title
	end

	if showAsDot then
		visibleOnBigMap = false
		iconType = 1
		paramSIconId = DOT_ICON_ID
		hideInHUD = true
		color = Color.NewByStr(gTaskManager.TaskColor[taskTitle] or "FFFFFF")
		dontTrace = true
	end

	local gpsLText = nil

	if gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoPickup or gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.Cargo then
		if targetType ~= gSpoonCommonData.GpsTargetType.Destructible then
			print_error("@策划 GpsNameSourceType为Cargo/CargoPickUp时，targetType必须为Destructible，否则会导致货车类gps无法显示", gpsNameSourceType, targetType, self.nodeId)
		end
	elseif gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoTarget then
		local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
		gpsLText = GpsLText.CreateCargoDeliveryText(eventId)
	else
		gpsName = gpsName or taskConfig and taskConfig.Name or ""
		gpsLText = GpsLText.CreateString(gpsName)
	end

	local sIconId = nil

	if iconType == 1 and paramSIconId and paramSIconId ~= 0 then
		sIconId = paramSIconId
	elseif taskTitle and taskTitle > 0 then
		sIconId = gTaskManager.TaskSIconId[taskTitle]
	else
		print_error("@策划  当前AddGps未传任何<color=cyan>[SGUI]</color>iconid!!!，默认使用委托任务图标咯", taskId, self.nodeId)

		sIconId = gTaskManager.TaskSIconId[17]
	end

	local params = {
		sIconId = sIconId,
		gpsLText = gpsLText,
		gpsName = gpsName,
		tooltipImageId = tooltipImageId,
		tooltipDesc = tooltipDesc,
		showVehicleNav = showVehicleNav,
		relocatedByVehicleNav = relocatedByVehicleNavDest,
		visibleOnBigMap = visibleOnBigMap,
		unselectable = nil,
		taskId = taskId,
		defaultHideUtilScan = defaultHideUtilScan,
		durationWhenScan = durationWhenScan,
		isProgress = isProgress,
		progressNormalIconId = progressNormalIcon,
		progressFinishIconId = progressFinishIcon,
		progressId = progressId,
		color = color,
		hideInHUD = hideInHUD,
		dontTrace = dontTrace,
		ignoreIndoorPenetration = ignoreIndoorPenetration
	}

	if isChasingVehicleTarget then
		params.hudTIndex = 1
	end

	if (targetType == nil or targetType == gSpoonCommonData.GpsTargetType.WayPoint) and WayPoint then
		local targetList = {}

		for i = 1, #WayPoint do
			targetList[i] = {
				TargetPos = WayPoint[i],
				CounterIndex = i
			}
		end

		if not table.isNilOrEmpty(targetList) then
			gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
		end
	elseif targetType == gSpoonCommonData.GpsTargetType.Destructible and DestructiblePointUniqueIds then
		local DestructibleManager = LX6.Item.DestructibleMgr

		if #DestructiblePointUniqueIds <= 0 then
			return
		end

		local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
		local targetList = {}

		for i = 1, #DestructiblePointUniqueIds do
			targetList[i] = {}
			local pointId = DestructiblePointUniqueIds[i]
			local cargoGpsLText = nil

			if gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.CargoPickup then
				cargoGpsLText = GpsLText.CreateCargoPickupText(eventId, pointId)
			elseif gpsNameSourceType == gSpoonCommonData.GpsNameSourceType.Cargo then
				cargoGpsLText = GpsLText.CreateCargoText(eventId, pointId)
			end

			if cargoGpsLText ~= nil then
				if params.cargoGpsLTexts == nil then
					params.cargoGpsLTexts = {}
				end

				params.cargoGpsLTexts[i] = cargoGpsLText
			end

			local isLoaded, gameObjectOffsetPosition = DestructibleManager.Instance:SetDestructibleGpsWaitingLoadByUniqueId(pointId, gpsId .. "@" .. i, Vector3.zero)

			if isLoaded then
				targetList[i].TargetPos = gameObjectOffsetPosition
			else
				targetList[i].TargetPos = DestructiblePointPoss[i]
			end

			targetList[i].CounterIndex = i

			if refDestructible then
				targetList[i].DestructibleInstanceId = pointId
			end
		end

		gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
	elseif targetType == gSpoonCommonData.GpsTargetType.Enemy and Enemy then
		gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
			unitPid = Enemy
		}, params)
	elseif targetType == gSpoonCommonData.GpsTargetType.EnemyGroup and EnemyGroup then
		for i = 1, #EnemyGroup do
			local enemyPid = EnemyGroup[i]

			gGpsManager:AddGPS({
				InstanceId = enemyPid,
				UnitPid = enemyPid,
				GpsType = gpsType,
				SIconId = sIconId,
				Source = gGpsSource.Task,
				DefaultHideUtilScan = defaultHideUtilScan,
				DurationWhenScan = durationWhenScan,
				isProgress = isProgress
			})
		end
	elseif targetType == gSpoonCommonData.GpsTargetType.DestructibleGroup and DestructibleGroup and DestructibleGroupPoss then
		if DestructibleGroup then
			local DestructibleManager = LX6.Item.DestructibleMgr
			local targetList = {}

			for i = 1, #DestructibleGroup do
				local pointId = DestructibleGroup[i]
				local pos = DestructibleGroupPoss[i]
				targetList[i] = {}
				local isLoaded, gameObjectOffsetPosition = DestructibleManager.Instance:SetDestructibleGpsWaitingLoadByUniqueId(pointId, gpsId .. "@" .. i, Vector3.zero)

				if isLoaded then
					targetList[i].TargetPos = gameObjectOffsetPosition
				else
					targetList[i].TargetPos = Vector3.NewT(pos)
				end

				targetList[i].CounterIndex = i

				if refDestructible then
					targetList[i].DestructibleInstanceId = pointId
				end
			end

			gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
		end
	elseif targetType == gSpoonCommonData.GpsTargetType.LuaSlot then
		gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
			slotId = GadgetUniqueId,
			refId = GadgetNodeId
		}, params)
	elseif targetType == gSpoonCommonData.GpsTargetType.Vehicle and Vehicle then
		local vehicleUid = gDriveVehiclesManager:GetVehicleUid(Vehicle)

		gDriveVehiclesManager:TryGetVehicleWithCallback(vehicleUid, function (_vehicle)
			if _vehicle then
				gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
					vehicleUnitId = _vehicle.uId,
					vehiclePartNodeName = VehiclePartNodeName
				}, params)
			end
		end)
	elseif targetType == gSpoonCommonData.GpsTargetType.CarChallenge and Vehicle then
		local vehicle = gDriveVehiclesManager:GetVehicleInScene(Vehicle)

		if vehicle then
			gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
				vehicleUnitId = vehicle.uId
			}, params)
		end
	elseif targetType == gSpoonCommonData.GpsTargetType.NearestMetro then
		if L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
			return
		end

		local poss = gMapSubSystem_Entrance:GetCurrentRaidAllMetroPosition()

		if not poss or #poss <= 0 then
			return
		end

		local targetPos = poss[1]
		local temp = 99999999
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		for _, v in ipairs(poss) do
			local sqrDis = gUtils:SqrDistanceXZ(playerPos.x, playerPos.z, v.x, v.z)

			if sqrDis < temp then
				temp = sqrDis
				targetPos = v
			end
		end

		gMapSubSystem_TaskGps:AddGpsElement(gpsId, targetPos, params)
	end
end

function M:CanaleMapTargetsFlickerScaleCoroutine()
	if self.CanaleMapTargetsFlickerScaleCoroutineCoInternal then
		gCoroutineManager:CancelCoroutine(self.CanaleMapTargetsFlickerScaleCoroutineCoInternal)

		self.CanaleMapTargetsFlickerScaleCoroutineCoInternal = nil
	end
end

function M:DoMapTargetsFlickerScaleCoroutine(targets, minDistance, maxDistance, maxScale, minScale)
	local function MapScaleChange()
		local dis = -1
		local playerpos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		if #targets == 0 then
			return
		end

		for _, target in ipairs(targets) do
			local Id = 0
			local position = Vector3.zero

			if target.TargetType == 0 then
				Id = target.VehicleComponent
				local Info = LX6.Drive.DriveUtils.GetVehicleInScene(Id)

				GpsHelper.GetVehiclePosition(Info.vehicleUnitId, nil, false, position)
			elseif target.TargetType == 1 then
				Id = target.LuaSlot
				local Info = gGadgetManager:GetEntitySearchByInstanceId(Id, true)

				GpsHelper.GetSlotGpsPosition(Info.slotPid, Info.slotRefId, Info.slotRefName, position)
			elseif target.TargetType == 2 then
				Id = target.DestructibleSpawn.uniqueId
				local Info = gCS.DestructibleMgr:GetDestructibleByUniqueId(Id)

				GpsHelper.GetDestructiblePosition(Info.DestructibleInstanceId, position)
			elseif target.TargetType == 3 then
				Id = target.NpcSpawn
				local Info = gCS.SpoonAgentMgr:GetSpawnBySpoonId(Id)

				GpsHelper.GetUnitGpsPosition(Info.pid, false, position)
			end

			if position.x ~= 0 or position.y ~= 0 or position.z ~= 0 then
				local dx = playerpos.x - position.x
				local dy = playerpos.z - position.z

				if dis == -1 then
					dis = dx * dx + dy * dy
				else
					local temp = dx * dx + dy * dy

					if temp < dis * dis then
						dis = temp
					end
				end
			end
		end

		if dis > 0 then
			dis = math.sqrt(dis)
		end

		if dis < maxDistance and minDistance < dis then
			local scale_size = (dis - minDistance) / (maxDistance - minDistance)
			scale_size = UnityEngine.Mathf.Lerp(maxScale, minScale, scale_size)

			gMapManager:SetMiniMapScale(scale_size, gMapScaleType.SubTask)
		elseif dis < minDistance and dis > 0 then
			gMapManager:SetMiniMapScale(maxScale, gMapScaleType.SubTask)
		end
	end

	local function coFunc()
		while true do
			coroutine.yield(gWaitableUtils.WaitTime(0.02))
			MapScaleChange()
		end
	end

	M:CanaleMapTargetsFlickerScaleCoroutine()

	local coInternal = gCoroutineManager:StartCoroutine(coFunc)
	self.CanaleMapTargetsFlickerScaleCoroutineCoInternal = coInternal
end

function M:AddGpsNodeClear(gpsId)
	gMapSubSystem_TaskGps:DeleteGpsElement(gpsId)
end

function M:AddNpcGpsNodeAddGps(taskId, data)
	local instanceId = data.spoonId
	local pid = data.pid
	local gpsType = data.gpsType
	local targetPos = data.targetPos
	local isBanSelect = data.isBanSelect
	local sIconId = data.sIconId
	local isChasingNpcTarget = data.isChasingNpcTarget
	local isFriend = data.isFriend
	local friendId = data.friendId
	local ignoreIndoorPenetration = data.ignoreIndoorPenetration

	if pid and not ulong.equals(pid, 0) then
		instanceId = pid
	end

	local taskSIconId, traceEffectType = nil
	local gpsName = ""

	if taskId then
		local cfg = gTaskManager:GetTaskConfigInfo(taskId)
		taskSIconId = gTaskManager.TaskSIconId[cfg.Title]
		traceEffectType = gGpsTools.GetEffectType(EMapElementType.Task)
		local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)
		gpsName = taskLineCfg.EventName or ""
	else
		taskSIconId = gTaskManager.TaskSIconId[gSpoonCommonData.gpsTypeToTaskType[gpsType]]
	end

	if not sIconId or sIconId == 0 then
		sIconId = taskSIconId
	end

	local gpsLText, hudTIndex = nil

	if isFriend then
		local friendCfg = LTConfig.NpcCultivationConfig.GetConfig(friendId)

		if friendCfg then
			gpsName = nil
			gpsLText = GpsLText.CreateCommonText(friendCfg, "Name")
			sIconId = friendCfg.QImageId or 0
		end
	elseif isChasingNpcTarget then
		hudTIndex = 1
	end

	gGpsManager:AddGPS({
		legacyOnly = true,
		InstanceId = instanceId,
		TargetPos = targetPos,
		UnitPid = pid,
		GpsType = gpsType,
		RaidId = gRaidDataManager.RaidId,
		sIconId = sIconId,
		BanSelect = isBanSelect,
		traceEffectType = traceEffectType,
		Source = gGpsSource.Task
	})

	local params = {
		sIconId = sIconId,
		gpsName = gpsName,
		taskId = taskId,
		visibleOnBigMap = true,
		unselectable = isBanSelect,
		gpsLText = gpsLText,
		hudTIndex = hudTIndex,
		ignoreIndoorPenetration = ignoreIndoorPenetration
	}

	gMapSubSystem_TaskGps:AddDynamicGpsElement(instanceId, {
		unitPid = pid
	}, params)
end

function M:AddNpcGpsNodeClear(npcSpawn, gpsType)
	gGpsManager:RemoveGPSById(npcSpawn, gpsType)
	gMapSubSystem_TaskGps:DeleteGpsElement(npcSpawn)
end

function M:GetCurHackCameraEntityId()
	return gGadgetManager.curHackCameraEntityId or ulong.zero
end

function M:AddCommonHudGps(id, raidId, worldPos, iconId)
	gMapSubSystem_CommonGps:TryAddCommonHudGps(id, raidId, worldPos, iconId)
end

function M:AddCommonHudGpsByAgentPid(id, raidId, iconId, agentPid)
	gMapSubSystem_CommonGps:TryAddCommonHudGpsByAgentPid(id, raidId, iconId, agentPid)
end

function M:AddCommonHudGpsByVehiclePid(id, raidId, iconId, vehiclePid)
	gMapSubSystem_CommonGps:TryAddCommonHudGpsByVehiclePid(id, raidId, iconId, vehiclePid)
end

function M:RemoveCommonHudGps(id)
	gMapSubSystem_CommonGps:RemoveCommonGps(id)
end

local _vec3 = Vector3.zero

function M:TryGetHudTaskOriginPos(taskId)
	if not gMapSubSystem_Task then
		return nil
	end

	local instanceId = gMapSubSystem_Task:GetGpsInstanceIdByTaskId(taskId)
	local element = instanceId and gMapSystem.container:Get(instanceId)

	if element then
		return element:GetWorldPos(_vec3)
	else
		return nil
	end
end

function M:CreateOrGetRawCommonGps(gpsId, raidId, iconId)
	if gMapSubSystem_CommonGps then
		local element = gMapSubSystem_CommonGps:CreateOrGetRawGps(gpsId, raidId)
		element.mData.sIconId = iconId

		return element, element.instanceId
	else
		return nil, nil
	end
end
