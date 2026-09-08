-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\Utils\MapCsApi.lua
-- Decompiled from: 00181_MapCsApi.lua_7c11c159d8e7.luajit

gMapCsApi = gMapCsApi or {}
local M = gMapCsApi
local TaskTitle = require("LX6/Manager/Task/TaskTitle")

M.GetAllDirtySwap = function(self)
	return gMapSystem.container._dirtyInstanceIds
end

M.GetBoundsDirtySwap = function(self)
	return gMapSystem.container._boundsDirtySwap
end

EBigMapSpoonOpenMode = {
	["`\\xab\\xb6\\xbd\\xb9"] = 1,
	["2G\\x83\\x83\\x82M"] = 0
}

M.SpoonShowBigMap = function(self, mode, metroEntranceId)
	if not gPanelManager:CheckCanPanelShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL) then
		print("ShowBigMap Fail, panel not ready")

		return
	end

	if mode ~= EBigMapSpoonOpenMode.Metro then
		gMainPageManager:LockMainPage(LTConfig.PanelConfig.S_NEW_MAP_PANEL)
		gPanelManager:CheckShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL, {
			["NBx{A3="] = true,
			curMetroEntranceId = metroEntranceId
		})
	elseif mode ~= EBigMapSpoonOpenMode.Normal then
		gPanelManager:CheckShow(LTConfig.PanelConfig.S_NEW_MAP_PANEL)
	else
		print_error("SpoonShowBigMap Error, unknown mode: ", mode)

		return
	end
end

M.Legacy_DoFightMapEntrance = function(self, mapEntranceId)
	gClientToGameDelegate:AskTouchMapEntrance(gRaidDataManager.RaidId, mapEntranceId)
end

M.ShowMiniMapMessage = function(self)
	gMessageManager:SendMessage(gEventConstants.MAP_SHOW_MESSAGE)
end

M.SpoonCallHideWorkActionGps = function(self, value)
	gMapSystem:SetSwitch(EMapSwitchType.HideWorkActionGps, value)
end

M.SpoonCallAddVehicleGps = function(self, taskId, GpsType, isHideSceneIcon, vehicleUid)
	local traceLayerSelf = 0
	local sIconId = nil

	if taskId then
		local cfg = gTaskManager:GetTaskConfigInfo(taskId)
		sIconId = gTaskManager.TaskSIconId[cfg.Title]

		if cfg.Title ~= TaskTitle.Situational then
			traceLayerSelf = 1
		end
	else
		sIconId = gTaskManager.TaskSIconId[gSpoonCommonData.gpsTypeToTaskType[GpsType]]
	end

	gMapSubSystem_Vehicle:AddTaskChaseCar(vehicleUid, gRaidDataManager.RaidId, sIconId, isHideSceneIcon and EMapViewMask.MiniMap or EMapViewMask.MiniMap + EMapViewMask.HudGps, traceLayerSelf)
end

M.SpoonCallRemoveVehicleGps = function(self, vehicleUid)
	gMapSubSystem_Vehicle:RemoveTaskChaseCar(vehicleUid)
end

M.SpoonCallRemoveGps = function(self, instanceId, paramGpsType)
	gMapSubSystem_TaskGps:DeleteGpsElement(instanceId)
end

local BuildTaskInteractTargetInfo = function(bindType, targetId)
	if not bindType or not targetId then
		return nil
	end

	return {
		bindType = bindType,
		targetId = targetId
	}
end

local SetTaskInteractTargetInfo = function(target, bindType, targetId)
	if not target then
		return
	end

	target.taskInteractTargetInfo = BuildTaskInteractTargetInfo(bindType, targetId)
end

M.SetHudGpsHide = function(self, reason, hide)
	gMapSystem.ui:SetHudGpsHideReason(reason, hide)
end

M.AddGpsNodeAddGps = function(self, gpsId, taskId, gpsType, data)
	local iconType = data.iconType
	local paramSIconId = data.paramSIconId
	local hideGpsRange = data.HideGpsRange or 0
	local WayPoint = data.WayPoint
	local WayPointIds = data.WayPointIds
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
	local useVehicleGpsNode = data.UseVehicleGpsNode or false

	if useVehicleGpsNode and data.VehicleGpsNode then
		VehiclePartNodeName = GpsHelper.TranslateVehicleNodeEnumToNodeName(data.VehicleGpsNode) or ""
	end

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
	local cargoOrderId = data.cargoOrderId
	local autoCargoOrder = data.autoCargoOrder
	local isChasingVehicleTarget = data.isChasingVehicleTarget
	local isProgress = data.isProgress
	local progressNormalIcon = data.progressNormalIcon
	local progressFinishIcon = data.progressFinishIcon
	local progressId = data.progressId
	local hideInHUDAndDontTrace = data.hideInHUDAndDontTrace
	local hudDistRiseUp = data.hudDistRiseUp
	local hudDistRiseFactor = data.hudDistRiseFactor
	local ignoreIndoorPenetration = data.ignoreIndoorPenetration
	local hideInHUD = false
	local dontTrace = false
	local gpsName = nil
	local tooltipDesc = ""
	local taskConfig = LTConfig.TaskConfig.GetConfig(taskId)

	if autoBindToolTipId then
		local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(taskId)
		local taskLineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
		local firstIndex = gTaskNodeManager:FindFirstCounterIndex(taskId)
		gpsName = gTaskUtils:FormatTaskDesByEventId(taskConfig.EventObjective[firstIndex] or "", taskLineInfo.TaskLineId)
		tooltipImageId = taskLineCfg.SMapPhoto
		tooltipDesc = gUtils:GetSpecialDescription(taskLineInfo.EventDescription)
	elseif autoCargoOrder then
		if cargoOrderId == nil then
			local uberOrderCfg = LTConfig.UberSimOrderConfig
			local targetUberOrderCfg = nil

			for i = 0, uberOrderCfg.count - 1 do
				local cfg = uberOrderCfg.LoadAt(i)

				if cfg.EventId ~= cargoOrderId then
					targetUberOrderCfg = cfg

					break
				end
			end

			if gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.Cargo then
				local randomGoodsCfg = LTConfig.UberSimRandomGoodsConfig
				gpsName = randomGoodsCfg.GetConfig(targetUberOrderCfg.RandomGoods).information
			elseif gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.CargoPickup then
				local pickupCfg = LTConfig.UberSimPickupConfig
				gpsName = pickupCfg.GetConfig(targetUberOrderCfg.Pickup).information
			elseif gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.CargoTarget then
				local deliveryCfg = LTConfig.UberSimDeliveryConfig
				gpsName = deliveryCfg.GetConfig(targetUberOrderCfg.Delivery).information
			end
		end
	else
		local InvokerTextConfig = LTConfig.TextCommonTextConfig.GetConfig

		if gpsNameId == nil then
			local gpsTextConfig = InvokerTextConfig(gpsNameId)
			gpsName = gpsTextConfig and gpsTextConfig.Text or nil
		end

		if tooltipDescId == nil then
			local tooltipDescTextConfig = InvokerTextConfig(tooltipDescId)
			tooltipDesc = tooltipDescTextConfig and tooltipDescTextConfig.Text or ""
		end
	end

	local taskTitle = nil

	if taskConfig then
		taskTitle = taskConfig.Title
	end

	if hideInHUDAndDontTrace then
		hideInHUD = true
		dontTrace = true
	end

	local gpsLText = nil

	if gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.CargoPickup or gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.Cargo then
		if targetType == gSpoonCommonData.GpsTargetType.Destructible then
			print_error("@策划 GpsNameSourceType为Cargo/CargoPickUp时，targetType必须为Destructible，否则会导致货车类gps无法显示", gpsNameSourceType, targetType, self.nodeId)
		end
	elseif gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.CargoTarget then
		local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
		gpsLText = GpsLText.CreateCargoDeliveryText(eventId)
	else
		local firstIndex = gTaskNodeManager:FindFirstCounterIndex(taskId)
		gpsName = gpsName or taskConfig and taskConfig.EventObjective[firstIndex] or ""
		gpsName = gTaskUtils:FormatTaskDes(gpsName, taskId)
		gpsLText = GpsLText.CreateString(gpsName)
	end

	local sIconId = nil

	if iconType ~= 1 and paramSIconId and paramSIconId == 0 then
		sIconId = paramSIconId
	elseif taskTitle and taskTitle <= 0 then
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
		hideInHUD = hideInHUD,
		dontTrace = dontTrace,
		hideGpsRange = hideGpsRange,
		ignoreIndoorPenetration = ignoreIndoorPenetration,
		range = data.range,
		dontRepeatCreate = data.dontRepeatCreate,
		preferMainRoadNavigation = data.preferMainRoadNavigation or false,
		hudDistRiseUp = hudDistRiseUp,
		hudDistRiseFactor = hudDistRiseFactor
	}

	if isChasingVehicleTarget then
		params.hudTIndex = 1
	end

	if (targetType ~= nil or targetType ~= gSpoonCommonData.GpsTargetType.WayPoint) and WayPoint then
		local targetList = {}

		for i = 1, #WayPoint do
			targetList[i] = {
				TargetPos = WayPoint[i],
				CounterIndex = i
			}
			local wayPointId = WayPointIds and WayPointIds[i]

			SetTaskInteractTargetInfo(targetList[i], "WayPoint", wayPointId)
		end

		if not table.isNilOrEmpty(targetList) then
			gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
		end
	elseif targetType ~= gSpoonCommonData.GpsTargetType.Destructible and DestructiblePointUniqueIds then
		if #DestructiblePointUniqueIds < 0 then
			return
		end

		local eventId = gTaskNodeManager:GetTaskLineByTask(taskId).TaskLineId
		local targetList = {}

		for i = 1, #DestructiblePointUniqueIds do
			targetList[i] = {}
			local pointId = DestructiblePointUniqueIds[i]
			local cargoGpsLText = nil

			if gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.CargoPickup then
				cargoGpsLText = GpsLText.CreateCargoPickupText(eventId, pointId)
			elseif gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.Cargo then
				cargoGpsLText = GpsLText.CreateCargoText(eventId, pointId)
			end

			if cargoGpsLText == nil then
				if params.cargoGpsLTexts ~= nil then
					params.cargoGpsLTexts = {}
				end

				params.cargoGpsLTexts[i] = cargoGpsLText
			end

			if autoCargoOrder then
				params.cargoGpsLTexts = nil
			end

			targetList[i].TargetPos = DestructiblePointPoss[i]
			targetList[i].CounterIndex = i

			if refDestructible then
				targetList[i].DestructibleInstanceId = pointId

				SetTaskInteractTargetInfo(targetList[i], "Destructible", pointId)
			end
		end

		gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
	elseif targetType ~= gSpoonCommonData.GpsTargetType.Enemy and Enemy then
		SetTaskInteractTargetInfo(params, "Enemy", Enemy)
		gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
			unitPid = Enemy
		}, params)
	elseif targetType ~= gSpoonCommonData.GpsTargetType.EnemyGroup and EnemyGroup then
		-- Nothing
	elseif targetType ~= gSpoonCommonData.GpsTargetType.DestructibleGroup and DestructibleGroup and DestructibleGroupPoss then
		if DestructibleGroup then
			local targetList = {}

			for i = 1, #DestructibleGroup do
				local pointId = DestructibleGroup[i]
				local pos = DestructibleGroupPoss[i]
				targetList[i] = {
					TargetPos = DestructibleGroupPoss[i],
					CounterIndex = i
				}

				if refDestructible then
					targetList[i].DestructibleInstanceId = pointId

					SetTaskInteractTargetInfo(targetList[i], "Destructible", pointId)
				end
			end

			gMapSubSystem_TaskGps:AddMultiGpsElement(gpsId, targetList, params)
		end
	elseif targetType ~= gSpoonCommonData.GpsTargetType.LuaSlot then
		if gpsNameSourceType ~= gSpoonCommonData.GpsNameSourceType.Cleaner then
			gpsLText = GpsLText.CreateWasherTaskText()
			params.gpsLText = gpsLText
			params.tooltipLText = GpsLText.CreateDynamicText(function ()
				return gWasherManager:GetCurrentRandomTaskDescription()
			end)
		end

		SetTaskInteractTargetInfo(params, "LuaSlot", GadgetUniqueId)
		gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
			slotId = GadgetUniqueId,
			refId = GadgetNodeId
		}, params)
	elseif targetType ~= gSpoonCommonData.GpsTargetType.Vehicle and Vehicle then
		if Vehicle then
			SetTaskInteractTargetInfo(params, "Vehicle", Vehicle)
			gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
				vehicleUnitId = Vehicle,
				vehiclePartNodeName = VehiclePartNodeName
			}, params)
		end
	elseif targetType ~= gSpoonCommonData.GpsTargetType.CarChallenge and Vehicle then
		SetTaskInteractTargetInfo(params, "Vehicle", Vehicle)
		gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
			vehicleUnitId = Vehicle
		}, params)
	elseif targetType ~= gSpoonCommonData.GpsTargetType.NearestMetro then
		if gGpsTools:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
			return
		end

		local poss = gMapSubSystem_Entrance:GetCurrentRaidAllMetroPosition()

		if not poss or #poss < 0 then
			return
		end

		local targetPos = poss[1]
		local temp = 99999999
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		for _, v in ipairs(poss) do
			local sqrDis = gUtils:SqrDistanceXZ(playerPos.x, playerPos.z, v.x, v.z)

			if sqrDis >= temp then
				temp = sqrDis
				targetPos = v
			end
		end

		gMapSubSystem_TaskGps:AddGpsElement(gpsId, targetPos, params)
	end
end

M.CanaleMapTargetsFlickerScaleCoroutine = function(self)
	if self.CanaleMapTargetsFlickerScaleCoroutineCoInternal then
		gCoroutineManager:CancelCoroutine(self.CanaleMapTargetsFlickerScaleCoroutineCoInternal)

		self.CanaleMapTargetsFlickerScaleCoroutineCoInternal = nil
	end
end

M.DoMapTargetsFlickerScaleCoroutine = function(self, targets, minDistance, maxDistance, maxScale, minScale)
	local MapScaleChange = function()
		local dis = -1
		local playerpos = gCS.MyPlayerManager.PlayerUnit.LocalPosition

		if #targets ~= 0 then
			return
		end

		for _, target in ipairs(targets) do
			local Id = 0
			local position = Vector3.zero

			if target.TargetType ~= 0 then
				Id = target.VehicleComponent
				local Info = LX6.Drive.DriveManager.GetBaseVehicle(Id)

				GpsHelper.GetVehiclePosition(Info.uid, nil, false, position)
			elseif target.TargetType ~= 1 then
				Id = target.LuaSlot
				local Info = gGadgetManager:GetEntitySearchByInstanceId(Id, true)

				GpsHelper.GetSlotGpsPosition(Info.slotPid, Info.slotRefId, Info.slotRefName, position)
			elseif target.TargetType ~= 2 then
				Id = target.DestructibleSpawn.uniqueId
			elseif target.TargetType ~= 3 then
				Id = target.NpcSpawn
				local Info = gCS.SpoonAgentMgr:GetSpawnBySpoonId(Id)

				GpsHelper.GetUnitGpsPosition(Info.pid, false, position)
			end

			if position.x == 0 or position.y == 0 or position.z == 0 then
				local dx = playerpos.x - position.x
				local dy = playerpos.z - position.z

				if dis ~= -1 then
					dis = dx * dx + dy * dy
				else
					local temp = dx * dx + dy * dy

					if temp >= dis * dis then
						dis = temp
					end
				end
			end
		end

		if dis <= 0 then
			dis = math.sqrt(dis)
		end

		if dis >= maxDistance and minDistance >= dis then
			local scale_size = (dis - minDistance) / (maxDistance - minDistance)
			scale_size = UnityEngine.Mathf.Lerp(maxScale, minScale, scale_size)

			gMapManager:SetMiniMapScale(scale_size, gMapScaleType.SubTask)
		elseif dis >= minDistance and dis <= 0 then
			gMapManager:SetMiniMapScale(maxScale, gMapScaleType.SubTask)
		end
	end

	local coFunc = function()
		while true do
			coroutine.yield(gWaitableUtils.WaitTime(0.02))
			MapScaleChange()
		end
	end

	M:CanaleMapTargetsFlickerScaleCoroutine()

	local coInternal = gCoroutineManager:StartCoroutine(coFunc)
	self.CanaleMapTargetsFlickerScaleCoroutineCoInternal = coInternal
end

M.AddGpsNodeClear = function(self, gpsId)
	gMapSubSystem_TaskGps:DeleteGpsElement(gpsId)
end

M.AddNpcGpsNodeAddGps = function(self, taskId, data)
	local gpsId = data.gpsId
	local instanceId = data.spoonId
	gpsId = gpsId or instanceId
	local gpsType = data.gpsType
	local isBanSelect = data.isBanSelect
	local sIconId = data.sIconId
	local isChasingNpcTarget = data.isChasingNpcTarget
	local isFriend = data.isFriend
	local friendId = data.friendId
	local hideGpsRange = data.HideGpsRange or 0
	local ignoreIndoorPenetration = data.ignoreIndoorPenetration
	local hudDistRiseUp = data.hudDistRiseUp or false
	local hudDistRiseFactor = data.hudDistRiseFactor
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

	if not sIconId or sIconId ~= 0 then
		sIconId = taskSIconId
	end

	local gpsLText, hudTIndex = nil

	if isFriend then
		if data.useServerFriendId then
			local Id = gTaskUtils:GetRideCultivationId()

			if Id then
				local friendCfg = LTConfig.NpcCultivationConfig.GetConfig(Id)

				if friendCfg then
					gpsName = nil
					gpsLText = GpsLText.CreateCommonText(friendCfg, "Name")
					sIconId = friendCfg.QImageId or 0
				end
			end
		else
			local friendCfg = LTConfig.NpcCultivationConfig.GetConfig(friendId)

			if friendCfg then
				gpsName = nil
				gpsLText = GpsLText.CreateCommonText(friendCfg, "Name")
				sIconId = friendCfg.QImageId or 0
			end
		end
	elseif isChasingNpcTarget then
		hudTIndex = 1
	end

	local params = {
		sIconId = sIconId,
		gpsName = gpsName,
		taskId = taskId,
		visibleOnBigMap = true,
		unselectable = isBanSelect,
		gpsLText = gpsLText,
		hudTIndex = hudTIndex,
		ignoreIndoorPenetration = ignoreIndoorPenetration,
		hideGpsRange = hideGpsRange,
		hudDistRiseUp = hudDistRiseUp,
		hudDistRiseFactor = hudDistRiseFactor
	}

	SetTaskInteractTargetInfo(params, "Npc", instanceId)
	gMapSubSystem_TaskGps:AddDynamicGpsElement(gpsId, {
		unitPid = instanceId
	}, params)
end

M.AddNpcGpsNodeClear = function(self, npcSpawn, gpsType)
	gMapSubSystem_TaskGps:DeleteGpsElement(npcSpawn)
end

M.GetCurHackCameraEntityId = function(self)
	return gGadgetManager.curHackCameraEntityId or ulong.zero
end

M.AddCommonHudGps = function(self, id, raidId, worldPos, iconId)
	gMapSubSystem_CommonGps:TryAddCommonHudGps(id, raidId, worldPos, iconId)
end

M.AddCommonHudGpsByAgentPid = function(self, id, raidId, iconId, agentPid)
	gMapSubSystem_CommonGps:TryAddCommonHudGpsByAgentPid(id, raidId, iconId, agentPid)
end

M.AddCommonHudGpsByVehiclePid = function(self, id, raidId, iconId, vehiclePid)
	gMapSubSystem_CommonGps:TryAddCommonHudGpsByVehiclePid(id, raidId, iconId, vehiclePid)
end

M.AddTaskPlayerVehicleGps = function(self, iconId, vehicleUid)
	gMapSubSystem_Vehicle:AddTaskPlayerVehicleGps(vehicleUid, gRaidDataManager.RaidId, iconId)
end

M.RemoveTaskPlayerVehicleGps = function(self, vehicleUid)
	gMapSubSystem_Vehicle:RemoveTaskPlayerVehicleGps(vehicleUid)
end

M.RemoveCommonHudGps = function(self, id)
	gMapSubSystem_CommonGps:RemoveCommonGps(id)
end

local _vec3 = Vector3.zero

M.TryGetHudTaskOriginPos = function(self, taskId)
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

M.CreateOrGetRawCommonGps = function(self, gpsId, raidId, iconId)
	if gMapSubSystem_CommonGps then
		local element = gMapSubSystem_CommonGps:CreateOrGetRawGps(gpsId, raidId)
		element.mData.sIconId = iconId

		return element, element.instanceId
	else
		return nil, 
	end
end

M.SetTeamMemberGpsAlphaController = function(self, enable)
	gMapSubSystem_Player:SetPlayerTeamAlphaController(enable)
end

M.ShowMiniMapBoundaryAlert = function(self, show)
	local store = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if store then
		store:ShowBoundaryAlert(show)
	end
end

M.PreUpdateMiniMapPanel = function(self)
	local store = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if store then
		store:PreUpdatePanel()
	end
end

M.UpdateMiniMapPanel = function(self)
	local store = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if store then
		store:UpdatePanel()
	end
end

M.PostUpdateMiniMapPanel = function(self)
	local store = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if store then
		store:PostUpdatePanel()
	end
end

M.ChangeMiniMapBaseMapBuildingVisibility = function(self, visible)
	local minimapStore = gStoreManager:GetStoreGroup("MiniMapPanelStore")

	if minimapStore then
		minimapStore:ChangeBaseMapBuildingVisibility(visible)
	end
end

M.SyncChangeSafeArea = function(self, index)
	gClientToGameDelegate:SyncChangeSafeArea(index)
end

M.SetPidToCarRacingVehicleIds = function(self, gameStart, pidToCarRacingVehicleIds)
	gMapSubSystem_Player:SetPidToCarRacingVehicleIds(gameStart, pidToCarRacingVehicleIds)
end

M.RevealEnemyOnMinimap = function(self, reveal, spoonId)
	if gMapSubSystem_CommonUnit then
		gMapSubSystem_CommonUnit:SpoonRevealEnemy(spoonId, reveal)
	end
end

M.OnCarRaceStart = function(self)
	gMapSubSystem_CarRace:OnCarRaceStart()
end

M.OnCarRaceEnd = function(self)
	gMapSubSystem_CarRace:OnCarRaceEnd()
end

M.StartRowBoat = function(self, posList)
	gMapSubSystem_Rowboat:StartRowBoat(posList)
end

M.EndRowBoat = function(self)
	gMapSubSystem_Rowboat:EndRowBoat()
end

M.SetRowBoatDone = function(self, id)
	gMapSubSystem_Rowboat:SetRowBoatDone(id)
end
