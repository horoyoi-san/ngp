local math = math
local TaskConfig = LTConfig.TaskConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local CollectionConfig = LTConfig.CollectionConfig
local TaskState = UX.Game.TaskState
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
MapSubSystem_RangeEvent = DefClass("MapSubSystem_RangeEvent", MapSubSystem_RangeEvent, MapSubSystemBase)
local M = MapSubSystem_RangeEvent

function M:OnInit()
	self.rangeEvents = {}
	self.EventState = {
		Accept = 2,
		Unaccept = 1
	}
	self.RangeEventType = {
		Accident = 2,
		SpecialAccident3 = 5,
		Battle = 1,
		SpecialAccident2 = 4,
		SpecialAccident1 = 3
	}
	self.includeTitles = {
		TaskTitle.RandomEvent,
		TaskTitle.ACCIDENT
	}
	self.unitPid2EventId = {}
	self._runningTaskEvent = {}
	self.notAbortIds = {}
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:OnCurrentTaskChange()
		end,
		[gEventConstants.UNIT_LOCK_TARGET] = function (eventId, param)
			local unitId = param.triggerId
			local targetId = param.targetId
			local eventId = self.unitPid2EventId[unitId]

			if not eventId then
				return
			end

			local info = self.rangeEvents[eventId]

			if not info then
				return
			end

			local unit = gCS.MyPlayerManager.PlayerUnit

			if not L50.L50App.Scene.GamePlayUtils:UnitIsNull(unit) and unit.Pid == targetId then
				info.locked = true
				info.lockingUnitPids[unitId] = true
			else
				info.lockingUnitPids[unitId] = nil

				if next(info.lockingUnitPids) == nil then
					info.locked = false
				end
			end
		end
	}

	self:InitConfigs()
end

function M:InitConfigs()
	self._rule2RangeEventType = {
		self.RangeEventType.Battle,
		self.RangeEventType.Accident,
		self.RangeEventType.SpecialAccident1,
		self.RangeEventType.SpecialAccident2,
		self.RangeEventType.SpecialAccident3
	}
	self.eventTypeConfigs = {}

	for i = 0, LTConfig.RandomEventRuleConfig.count - 1 do
		local ruleCfg = LTConfig.RandomEventRuleConfig.LoadAt(i)
		local rangeType = self._rule2RangeEventType[ruleCfg.Id]
		self.eventTypeConfigs[rangeType] = {
			AcceptRangeSqr = ruleCfg.AcceptRange * ruleCfg.AcceptRange,
			GiveUpRangeSqr = ruleCfg.AbandonRange * ruleCfg.AbandonRange,
			CloseHideRadiusSqr = ruleCfg.MapRange[1] * ruleCfg.MapRange[1],
			CloseHideHeight = ruleCfg.MapRange[2]
		}
	end
end

function M:OnLogin()
	self.unitPid2EventId = {}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
end

function M:OnBeforeSwitchScene(switchType)
	if gSwitchSceneType.Image <= switchType then
		for id, info in pairs(self.rangeEvents) do
			self:DisposeEventInfo(info)

			self.rangeEvents[id] = nil
		end
	end
end

function M:TrySetupUnits(info)
	local enemies = nil
	enemies = gCS.SpoonTaskMgr.Instance:GetSpoonTaskAllEnemyPid(info.taskId or 0)

	if enemies and enemies.ToTable then
		enemies = enemies:ToTable()
	end

	if enemies then
		local pids = {}

		for _, pid in pairs(enemies) do
			pids[#pids + 1] = pid
		end

		info.unitPidList = pids

		table.clear(info.lockingUnitPids)

		info.locked = false

		for _, pid in pairs(pids) do
			self.unitPid2EventId[pid] = info.eventId
		end
	end
end

function M:DisposeEventInfo(info)
	info.mapElement:Dispose()

	if info.unitPidList then
		self:ClearBlacklist(info)

		for _, pid in pairs(info.unitPidList) do
			self.unitPid2EventId[pid] = nil
		end
	end
end

function M:OnCurrentTaskChange()
	self._stopTick = false
	local curTaskList = gTaskManager:GetAllAcceptedTask()

	if curTaskList then
		for taskId, _ in pairs(curTaskList) do
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

			if table.contains(taskCfg.Tags, LTConfig.TaskConfig.TagsType.NoMapRandomTask) then
				self._stopTick = true
			end
		end
	end
end

function M:SyncRuleDict(dict, notAbortIds)
	self.notAbortIds = notAbortIds or {}

	table.clear(self.notAbortIds)

	if notAbortIds and notAbortIds.Count and notAbortIds.Count > 0 then
		print_debug("[RangeEventInfo]: SyncRuleDict notAbortIds.Count", notAbortIds.Count)

		for i = 1, notAbortIds.Count do
			table.insert(self.notAbortIds, notAbortIds[i])
		end
	end

	for ruleId, rangeType in ipairs(self._rule2RangeEventType) do
		local ids = dict[ruleId] and dict[ruleId].Value or {}

		self:SyncMapRangeEventIdList(ids, rangeType)
	end
end

function M:SyncMapRangeEventIdList(ids, type)
	if self.RangeEventType.SpecialAccident3 < type or type < self.RangeEventType.Battle then
		print_error("@xiajingbo01 [RangeEventInfo]: SyncMapRangeEventIdList invalid type", type)

		return
	end

	local idSet = {}

	for _, id in ipairs(ids) do
		local taskEventCfg = LTConfig.TaskEventConfig.GetConfig(id)

		if not taskEventCfg then
			-- Nothing
		else
			local startTaskCfg = LTConfig.TaskConfig.GetConfig(taskEventCfg.StartTask)

			if not startTaskCfg or not array.contains(self.includeTitles, startTaskCfg.Title) then
				if startTaskCfg then
					print_error("@songyiqun01 RandomEvent: 不应该出现在 SyncMapRandomEventsList的TaskTitle: " .. startTaskCfg.Title .. ", id = " .. id, " type = " .. type)
				end
			else
				idSet[id] = true
			end
		end
	end

	for id, info in pairs(self.rangeEvents) do
		if not idSet[id] and info.type == type then
			self:RemoveRangeEvent(id)
		end
	end

	for id, _ in pairs(idSet) do
		if not self.rangeEvents[id] then
			self:AddRangeEvent(id, type)
		end
	end
end

function M:AddRangeEvent(id, type)
	print_debug("[RangeEventInfo]: AddRangeEvent" .. " id:" .. id .. " type:" .. type)

	local eventCfg = LTConfig.TaskEventConfig.GetConfig(id)

	if not eventCfg or not eventCfg.CenterPos or #eventCfg.CenterPos < 3 then
		return
	end

	local taskCfg = LTConfig.TaskConfig.GetConfig(eventCfg.StartTask)
	local worldPos = Vector3.New(eventCfg.CenterPos[1], eventCfg.CenterPos[2], eventCfg.CenterPos[3])
	local element = MapElement.CreateLegacy(EMapElementType.RangeEvent, id, EMapSubSystemType.RangeEvent, EMapViewMask.HudGps + EMapViewMask.RangeEvent, LTConfig.RaidConfig.WorldMap, 0)
	local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89901341)
	element.mData.lName = GpsLText.CreateCommonText(textCfg, "Text", textCfg.Text)

	element:SetPosition(worldPos)

	element.miniMapData.miniMapTIndex = 1
	element.mData.sIconId = LTConfig.PoliceConfig.GpsIcon

	if array.contains(LTConfig.TaskConfig.MiniMapIconType, taskCfg.Title) then
		element.miniMapData.iconId = 28001078
	else
		element.miniMapData.iconId = gTaskManager.TaskSIconId[taskCfg.Title]

		if taskCfg.Title == TaskTitle.RandomEvent then
			element:OverrideMiniMapStartAnim(1, "S_vx_miniMapIcon_zaoyu_red_open")
			element:OverrideMiniMapLoopAnim(1, "S_vx_miniMapIcon_zaoyu_red_loop")
		end
	end

	element:SetVisible(true)
	element:SetViewMask(EMapViewMask.HudGps + EMapViewMask.RangeEvent)

	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(LTConfig.RaidConfig.WorldMap, worldPos.x, worldPos.z)
	local info = {
		eventId = id,
		eventTitleId = taskCfg.Title,
		taskId = eventCfg.StartTask,
		mapElement = element,
		state = self.EventState.Unaccept,
		centerPos = worldPos,
		blockId = blockId,
		lod = 2,
		lockingUnitPids = {},
		locked = false,
		type = type
	}
	self.rangeEvents[id] = info
end

function M:RemoveRangeEvent(id)
	print_debug("[RangeEventInfo]: RemoveRangeEvent" .. " id:" .. id)

	local info = self.rangeEvents[id]

	if info then
		self:DisposeEventInfo(info)

		self.rangeEvents[id] = nil

		gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
			isEnter = false,
			code = 2,
			taskId = LTConfig.TaskEventConfig.GetConfig(id).StartTask,
			taskLineId = id
		})

		if gMapSubSystem_Faction then
			gMapSubSystem_Faction:OnRemoveEvent(id)
		end
	end
end

function M:GetNeareastRangeEventWorldPos()
	local id = self:GetNearestRangeEventId()
	local info = id and self.rangeEvents[id]

	if not info then
		return nil
	end

	return info.centerPos
end

function M:GetNearestRangeEventId()
	if not self.rangeEvents then
		return 0
	end

	local minDis = math.huge
	local minId = 0

	for id, eventInfo in pairs(self.rangeEvents) do
		local worldPos = eventInfo.centerPos
		local myPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		local dx = worldPos.x - myPos.x
		local dz = worldPos.z - myPos.z
		local sqrDist2D = dx * dx + dz * dz

		if minDis > sqrDist2D then
			minDis = sqrDist2D
			minId = id
		end
	end

	return minId
end

function M:Tick()
	local teachingEventId = LTConfig.TaskConfig.TeachingRandomEvent.RandomEventId

	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) or gDriveVehiclesManager.isTaxiMode or self._stopTick and not self.rangeEvents[teachingEventId] then
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.TaskTitle21)

		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local battlePara = self:GetCurrentBattlePara()
	local needMiniMapScale = false

	if self._stopTick then
		local ret = self:TickSingleRangeEvent(teachingEventId, self.rangeEvents[teachingEventId], playerPos, self.RangeEventType.Battle, battlePara)
		needMiniMapScale = needMiniMapScale or ret
	else
		for id, info in pairs(self.rangeEvents) do
			local ret = self:TickSingleRangeEvent(id, info, playerPos, info.type, battlePara)
			needMiniMapScale = needMiniMapScale or ret
		end
	end

	if needMiniMapScale then
		gMapManager:SetMiniMapScale(LTConfig.CollectionConfig.PoiIIMiniMapScale, gMapScaleType.TaskTitle21)
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.TaskTitle21)
	end
end

function M:TickSingleRangeEvent(id, info, playerPos, type, battlePara)
	if not type or not self.eventTypeConfigs[type] then
		return
	end

	local sqrAcceptRange = self.eventTypeConfigs[type].AcceptRangeSqr
	local sqrGiveupRange = self.eventTypeConfigs[type].GiveUpRangeSqr
	local sqrR1 = self.eventTypeConfigs[type].CloseHideRadiusSqr
	local H1 = self.eventTypeConfigs[type].CloseHideHeight
	local dx = info.centerPos.x - playerPos.x
	local dy = info.centerPos.z - playerPos.z
	local d2 = dx * dx + dy * dy
	local dh = math.abs(playerPos.y - info.centerPos.y)
	local blockUnlocked = gBlockMgr:IsBlockUnlocked(info.blockId)

	if blockUnlocked and info.state == self.EventState.Unaccept then
		if d2 < sqrAcceptRange then
			info.state = self.EventState.Accept

			gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
				isEnter = true,
				code = 0,
				taskId = LTConfig.TaskEventConfig.GetConfig(id).StartTask,
				taskLineId = id
			})
		end
	elseif info.state == self.EventState.Accept and not array.contains(self.notAbortIds, id) and sqrGiveupRange < d2 and sqrGiveupRange > 0 and gTaskManager:GetTaskState(TaskEventConfig.GetConfig(id).StartTask) == TaskState.Accepted then
		info.state = self.EventState.Unaccept

		gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
			isEnter = false,
			code = 2,
			taskId = LTConfig.TaskEventConfig.GetConfig(id).StartTask,
			taskLineId = id
		})
	end

	local visible = nil

	if info.locked then
		info.lod = 1
	elseif info.lod == 1 then
		if (sqrR1 <= d2 or H1 <= dh) and (info.state ~= self.EventState.Accept or info.type == self.RangeEventType.Battle) then
			info.lod = 2
		end
	elseif info.lod == 2 then
		if d2 < sqrR1 and dh < H1 then
			info.lod = 1
		end
	else
		print_error("@sunwei: Invalid Detail Level", info.lod, "EventId: ", id)
	end

	visible = (blockUnlocked or info.state ~= self.EventState.Unaccept or false) and info.lod == 2

	if info.state == self.EventState.Accept and not info.unitPidList then
		self:TrySetupUnits(info)
	end

	if info.lod ~= 1 then
		gMapSubSystem_CommonUnit:AddSpoonUnitsBlacklist(info.taskId)
	else
		self:ClearBlacklist(info)
	end

	local arrow = nil

	if visible and d2 < sqrR1 and H1 < dh and info.type == self.RangeEventType.Battle then
		if info.centerPos.y < playerPos.y then
			arrow = 1
		else
			arrow = 0
		end
	end

	info.mapElement.miniMapData.arrowNum = arrow

	if visible then
		info.mapElement:AddViewMask(EMapViewMask.MiniMap)

		if info.type == self.RangeEventType.Battle then
			self:UpdateSingleEventBattlePara(info, battlePara)
		end
	else
		info.mapElement:RemoveViewMask(EMapViewMask.MiniMap)
	end

	return info.eventTitleId == 21 and info.state == self.EventState.Accept
end

function M:ClearBlacklist(info)
	gMapSubSystem_CommonUnit:RemoveSpoonUnitsBlacklist(info.taskId)
end

function M:AddFlickerElements(datas)
	if self._filckerDict == nil then
		self._filckerDict = {}
	end

	local raidId = gMapSystem.lastRaidId

	for _, data in ipairs(datas) do
		local element = MapElement.CreateLegacy(EMapElementType.RangeEvent, data.Id, EMapSubSystemType.RangeEvent, EMapViewMask.MiniMap, raidId, 0)
		element.miniMapData.iconId = 28001636
		local blacklistId = nil

		if data.TargetType == 0 then
			element:BindVehicle(data.Id)
		elseif data.TargetType == 1 then
			element:BindSlotInfo(data.Id)
		elseif data.TargetType == 2 then
			element:BindDestructible(data.Id)
		elseif data.TargetType == 3 then
			element:BindUnit(data.Id)

			blacklistId = gMapSubSystem_CommonUnit:AddBlacklist({
				data.Id
			})
		end

		element:SetVisible(true)

		if data.CampType == 0 then
			element.miniMapData.color = Color.New(0.3058824, 0.827451, 0.8862745, 1)
		elseif data.CampType == 2 then
			element:OverrideMiniMapStartAnimNoAnim(0)
			element:OverrideMiniMapLoopAnim(0, "S_vx_miniMapIcon_04", true)

			element.miniMapData.dontSetColor = true
		else
			element:OverrideMiniMapStartAnimNoAnim(0)
			element:OverrideMiniMapLoopAnim(0, "S_vx_miniMapIcon_03", true)

			element.miniMapData.dontSetColor = true
		end

		if self._filckerDict[data.Id] then
			local info = self._filckerDict[data.Id]

			if info.element then
				info.element:Dispose()
			end

			if info.blacklistId then
				gMapSubSystem_CommonUnit:RemoveBlacklist(info.blacklistId)
			end
		end

		self._filckerDict[data.Id] = {
			blacklistId = blacklistId,
			element = element
		}
	end
end

function M:RemoveFlickerElements(datas)
	if not self._filckerDict then
		return
	end

	for _, data in ipairs(datas) do
		local info = self._filckerDict[data.Id]

		if info then
			if info.element then
				info.element:Dispose()
			end

			if info.blacklistId then
				gMapSubSystem_CommonUnit:RemoveBlacklist(info.blacklistId)
			end

			self._filckerDict[data.Id] = nil
		end
	end
end

function M:TryTraceRangeEvent(eventId)
	print("TryTraceRangeEvent", eventId)

	local info = self.rangeEvents[eventId]

	if not info then
		return
	end

	info.mapElement:SetTraceInfo(EMapGTraceType.Other, 0)
	info.mapElement:AddViewMask(EMapViewMask.BigMap)
end

function M:TryUntraceRangeEvent(eventId)
	print("TryUntraceRangeEvent", eventId)

	local info = self.rangeEvents[eventId]

	if not info then
		return
	end

	info.mapElement:RemoveViewMask(EMapViewMask.BigMap)
	info.mapElement:ClearTraceInfo()
end

function M:GetCurrentBattlePara()
	local spiritId = gSpiritManager:GetCurFirstSpiritTid()
	local spiritInfo = gSpiritManager:GetSpirit(spiritId)

	if not spiritInfo then
		return 0
	end

	local badges = spiritInfo.SpiritInfo.InfoBadge.Badges

	if table.isNilOrEmpty(badges) then
		return 0
	end

	local total = 0

	for i, v in pairs(badges) do
		if not v.Active then
			-- Nothing
		else
			local cfg = LTConfig.UrbanBadgeConfig.GetConfig(i)

			if cfg and cfg.BattlePara and cfg.BattlePara > 0 then
				total = total + cfg.BattlePara
			end
		end
	end

	return total
end

local DANGER_ICON = TaskConfig.ChaosSafeAndDangerIcon.danger
local SAFE_ICON = TaskConfig.ChaosSafeAndDangerIcon.safe
local DANGER_THRESOLD = CollectionConfig.DangerousBattleThreshold

function M:UpdateSingleEventBattlePara(info, battlePara)
	local element = info.mapElement
	local eventId = info.eventId
	local cfg = TaskEventConfig.GetConfig(eventId)

	if not cfg then
		return
	end

	local difficulty = cfg.BattleDifficulty or 0
	local danger = DANGER_THRESOLD < difficulty - battlePara
	local iconId = danger and DANGER_ICON or SAFE_ICON

	if element.miniMapData.iconId ~= iconId then
		element.miniMapData.iconId = iconId
	end
end

function M:SGetTooltipInfo(id, element)
	return nil
end

return M
