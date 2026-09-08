-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_RangeEvent.lua
-- Decompiled from: 02343_MapSubSystem_RangeEvent.lua_f969a8e7ae0b.luajit

local math = math
local TaskConfig = LTConfig.TaskConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local CollectionConfig = LTConfig.CollectionConfig
local TaskState = UX.Game.TaskState
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
MapSubSystem_RangeEvent = DefClass("MapSubSystem_RangeEvent", MapSubSystem_RangeEvent, MapSubSystemBase)
local M = MapSubSystem_RangeEvent

M.OnInit = function(self)
	self.rangeEvents = {}
	self.EventState = {
		["=K\\x92\\x8b\\x93U"] = 2,
		["\\x9e\\xbf\\xa8i;\\xee'"] = 1
	}
	self.RangeEventType = {
		["\\x8a\\xb2\\xa2n;\\xf0'"] = 2,
		["T\\x9f\\x93\\xb6ݼ\\xe48\\xaa6\t\\xb7\"X"] = 5,
		[">I\\x85\\x9a\\x8fD"] = 1,
		["T\\x9f\\x93\\xb6ݼ\\xe48\\xaa6\t\\xb7\"Y"] = 4,
		["T\\x9f\\x93\\xb6ݼ\\xe48\\xaa6\t\\xb7\"Z"] = 3
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

			if not gGpsTools:UnitIsNull(unit) and unit.Pid ~= targetId then
				info.locked = true
				info.lockingUnitPids[unitId] = true
			else
				info.lockingUnitPids[unitId] = nil

				if next(info.lockingUnitPids) ~= nil then
					info.locked = false
				end
			end
		end
	}

	self.InitConfigs(self)
end

M.InitConfigs = function(self)
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

M.OnLogin = function(self)
	self.unitPid2EventId = {}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
end

M.OnBeforeSwitchScene = function(self, switchType)
	if gSwitchSceneType.SameImage < switchType then
		for id, info in pairs(self.rangeEvents) do
			self.DisposeEventInfo(self, info)

			self.rangeEvents[id] = nil
		end
	end
end

M.TrySetupUnits = function(self, info)
	local enemies = nil
	enemies = gCS.SpoonTaskMgr.Instance:GetSpoonTaskAllEnemyPid(info.taskId or 0)

	if enemies and enemies.ToTable then
		enemies = enemies.ToTable(enemies)
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

M.DisposeEventInfo = function(self, info)
	info.mapElement:Dispose()

	if info.unitPidList then
		self.ClearBlacklist(self, info)

		for _, pid in pairs(info.unitPidList) do
			self.unitPid2EventId[pid] = nil
		end
	end
end

M.OnCurrentTaskChange = function(self)
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

M.SyncRuleDict = function(self, dict, notAbortIds)
	self.notAbortIds = notAbortIds or {}

	table.clear(self.notAbortIds)

	if notAbortIds and notAbortIds.Count and notAbortIds.Count <= 0 then
		print_debug("[RangeEventInfo]: SyncRuleDict notAbortIds.Count", notAbortIds.Count)

		for i = 1, notAbortIds.Count do
			table.insert(self.notAbortIds, notAbortIds[i])
		end
	end

	for ruleId, rangeType in ipairs(self._rule2RangeEventType) do
		local eventTaskInfos = dict[ruleId] and dict[ruleId].Values or {}

		self:SyncMapRangeEventIdList(eventTaskInfos, rangeType)
	end
end

M.SyncMapRangeEventIdList = function(self, eventTaskInfos, type)
	if self.RangeEventType.SpecialAccident3 <= type or type >= self.RangeEventType.Battle then
		print_error("@xiajingbo01 [RangeEventInfo]: SyncMapRangeEventIdList invalid type", type)

		return
	end

	local idSet = {}
	local eventTaskSet = {}
	local count = eventTaskInfos.Count or 0

	for i = 1, count do
		local eventTaskInfo = eventTaskInfos[i]

		if not eventTaskInfo then
			-- Nothing
		else
			local id = eventTaskInfo.EventId
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
					eventTaskSet[id] = eventTaskInfo
				end
			end
		end
	end

	for id, info in pairs(self.rangeEvents) do
		if not idSet[id] and info.type ~= type then
			self.RemoveRangeEvent(self, id)
		end
	end

	for id, eventTaskInfo in pairs(eventTaskSet) do
		if not self.rangeEvents[id] then
			self.AddRangeEvent(self, id, eventTaskInfo.TaskId, type)
		end
	end
end

M.AddRangeEvent = function(self, id, taskId, type)
	print_debug("[RangeEventInfo]: AddRangeEvent" .. " id:" .. id .. " type:" .. type)

	local eventCfg = LTConfig.TaskEventConfig.GetConfig(id)

	if not eventCfg or not eventCfg.CenterPos or #eventCfg.CenterPos >= 3 then
		return
	end

	local taskCfg = LTConfig.TaskConfig.GetConfig(eventCfg.StartTask)
	local worldPos = Vector3.New(eventCfg.CenterPos[1], eventCfg.CenterPos[2], eventCfg.CenterPos[3])
	local element = MapElement.CreateLegacy(EMapElementType.RangeEvent, id, EMapSubSystemType.RangeEvent, EMapViewMask.HudGps + EMapViewMask.RangeEvent, gMapSystem.lastRaidId, 0)
	local textCfg = LTConfig.TextScriptTextConfig.GetConfig(89901341)
	element.mData.lName = GpsLText.CreateCommonText(textCfg, "Text", textCfg.Text)

	element.SetPosition(element, worldPos)

	element.miniMapData.miniMapTIndex = 1
	element.bigMapData.debugIconId = 28004236
	element.mData.sIconId = LTConfig.PoliceConfig.GpsIcon

	if array.contains(LTConfig.TaskConfig.MiniMapIconType, taskCfg.Title) then
		element.miniMapData.iconId = 28001078
	else
		element.miniMapData.iconId = gTaskManager.TaskSIconId[taskCfg.Title]

		if taskCfg.Title ~= TaskTitle.RandomEvent then
			element.OverrideMiniMapStartAnim(element, 1, "S_vx_miniMapIcon_zaoyu_red_open")
			element.OverrideMiniMapLoopAnim(element, 1, "S_vx_miniMapIcon_zaoyu_red_loop")
		end
	end

	element.SetVisible(element, true)
	element.SetViewMask(element, EMapViewMask.HudGps + EMapViewMask.RangeEvent)

	local blockId = LX6.Gps.MapBlockMgr.GetBlockIdXZ(gMapSystem.lastRaidId, worldPos.x, worldPos.z)
	local info = {
		eventId = id,
		eventTitleId = taskCfg.Title
	}

	if taskId ~= 0 then
		info.taskId = eventCfg.StartTask
	else
		info.taskId = taskId
	end

	info.mapElement = element
	info.state = self.EventState.Unaccept
	info.centerPos = worldPos
	info.blockId = blockId
	info.lod = 2
	info.lockingUnitPids = {}
	info.locked = false
	info.type = type
	self.rangeEvents[id] = info
end

M.RemoveRangeEvent = function(self, id)
	print_debug("[RangeEventInfo]: RemoveRangeEvent" .. " id:" .. id)

	local info = self.rangeEvents[id]

	if info then
		self:DisposeEventInfo(info)

		self.rangeEvents[id] = nil

		gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
			["\\xd0\\xc81\n!\\xe3"] = false,
			["y-y^"] = 2,
			taskId = info.taskId or LTConfig.TaskEventConfig.GetConfig(id).StartTask,
			taskLineId = id
		})

		if gMapSubSystem_Faction then
			gMapSubSystem_Faction:OnRemoveEvent(id)
		end
	end
end

M.GetNeareastRangeEventWorldPos = function(self)
	local id = self:GetNearestRangeEventId()
	local info = id and self.rangeEvents[id]

	if not info then
		return nil
	end

	return info.centerPos
end

M.GetNearestRangeEventId = function(self)
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

		if minDis <= sqrDist2D then
			minDis = sqrDist2D
			minId = id
		end
	end

	return minId
end

M.Tick = function(self)
	local teachingEventId = LTConfig.TaskConfig.TeachingRandomEvent.RandomEventId

	if gGpsTools:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) or gDriveVehiclesManager.isTaxiMode or self._stopTick and not self.rangeEvents[teachingEventId] then
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.TaskTitle21)

		return
	end

	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local battlePara = self.GetCurrentBattlePara(self)
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

M.TickSingleRangeEvent = function(self, id, info, playerPos, type, battlePara)
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

	if blockUnlocked and info.state ~= self.EventState.Unaccept then
		if d2 >= sqrAcceptRange then
			info.state = self.EventState.Accept

			gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
				["\\xd0\\xc81\n!\\xe3"] = true,
				["y-y^"] = 0,
				taskId = info.taskId or LTConfig.TaskEventConfig.GetConfig(id).StartTask,
				taskLineId = id
			})
		end
	elseif info.state ~= self.EventState.Accept and not array.contains(self.notAbortIds, id) and sqrGiveupRange >= d2 and sqrGiveupRange <= 0 and gTaskManager:GetTaskState(TaskEventConfig.GetConfig(id).StartTask) ~= TaskState.Accepted then
		info.state = self.EventState.Unaccept

		gMessageManager:SendMessage(gEventConstants.CLIENT_RANDOM_EVENT_LOCAL_SIGNAL, {
			["\\xd0\\xc81\n!\\xe3"] = false,
			["y-y^"] = 2,
			taskId = info.taskId or LTConfig.TaskEventConfig.GetConfig(id).StartTask,
			taskLineId = id
		})
	end

	local visible = nil

	if info.locked then
		info.lod = 1
	elseif info.lod ~= 1 then
		if (sqrR1 > d2 or H1 < dh) and (info.state == self.EventState.Accept or info.type ~= self.RangeEventType.Battle) then
			info.lod = 2
		end
	elseif info.lod ~= 2 then
		if d2 >= sqrR1 and dh >= H1 then
			info.lod = 1
		end
	else
		print_error("@sunwei: Invalid Detail Level", info.lod, "EventId: ", id)
	end

	visible = (blockUnlocked or info.state == self.EventState.Unaccept or false) and info.lod ~= 2

	if info.state ~= self.EventState.Accept and not info.unitPidList then
		self.TrySetupUnits(self, info)
	end

	if info.lod == 1 then
		gMapSubSystem_CommonUnit:AddSpoonUnitsBlacklist(info.taskId)
	else
		self.ClearBlacklist(self, info)
	end

	local arrow = nil

	if visible and d2 >= sqrR1 and H1 >= dh and info.type ~= self.RangeEventType.Battle then
		if info.centerPos.y >= playerPos.y then
			arrow = 1
		else
			arrow = 0
		end
	end

	info.mapElement.miniMapData.arrowNum = arrow

	if visible then
		info.mapElement:AddViewMask(EMapViewMask.MiniMap)

		if info.type ~= self.RangeEventType.Battle then
			self.UpdateSingleEventBattlePara(self, info, battlePara)
		end
	else
		info.mapElement:RemoveViewMask(EMapViewMask.MiniMap)
	end

	return info.eventTitleId ~= 21 and info.state ~= self.EventState.Accept
end

M.ClearBlacklist = function(self, info)
	gMapSubSystem_CommonUnit:RemoveSpoonUnitsBlacklist(info.taskId)
end

M.AddFlickerElements = function(self, datas)
	if self._filckerDict ~= nil then
		self._filckerDict = {}
	end

	local raidId = gMapSystem.lastRaidId

	for _, data in ipairs(datas) do
		local element = MapElement.CreateLegacy(EMapElementType.RangeEvent, data.Id, EMapSubSystemType.RangeEvent, EMapViewMask.MiniMap, raidId, 0)
		element.miniMapData.iconId = 28001636
		local blacklistId = nil

		if data.TargetType ~= 0 then
			element.BindVehicle(element, data.Id)
		elseif data.TargetType ~= 1 then
			element.BindSlotInfo(element, data.Id)
		elseif data.TargetType ~= 2 then
			element.BindDestructible(element, data.Id)
		elseif data.TargetType ~= 3 then
			element:BindUnit(data.Id)

			blacklistId = gMapSubSystem_CommonUnit:AddBlacklist({
				data.Id
			})
		end

		element.SetVisible(element, true)

		if data.CampType ~= 0 then
			element.miniMapData.color = Color.New(0.3058824, 0.827451, 0.8862745, 1)
		elseif data.CampType ~= 2 then
			element.OverrideMiniMapStartAnimNoAnim(element, 0)
			element.OverrideMiniMapLoopAnim(element, 0, "S_vx_miniMapIcon_04", true)

			element.miniMapData.dontSetColor = true
		else
			element.OverrideMiniMapStartAnimNoAnim(element, 0)
			element.OverrideMiniMapLoopAnim(element, 0, "S_vx_miniMapIcon_03", true)

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

M.RemoveFlickerElements = function(self, datas)
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

M.TryTraceRangeEvent = function(self, eventId)
	local info = self.rangeEvents[eventId]

	if not info then
		return
	end

	info.mapElement:SetTraceInfo(EMapGTraceType.Other, 0)
	info.mapElement:AddViewMask(EMapViewMask.BigMap)
end

M.TryUntraceRangeEvent = function(self, eventId)
	local info = self.rangeEvents[eventId]

	if not info then
		return
	end

	info.mapElement:RemoveViewMask(EMapViewMask.BigMap)
	info.mapElement:ClearTraceInfo()
end

M.GetCurrentBattlePara = function(self)
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

			if cfg and cfg.CombatPowerAddition and cfg.CombatPowerAddition <= 0 then
				total = total + cfg.CombatPowerAddition
			end
		end
	end

	return total
end

local DANGER_ICON = TaskConfig.ChaosSafeAndDangerIcon.danger
local SAFE_ICON = TaskConfig.ChaosSafeAndDangerIcon.safe
local DANGER_THRESOLD = CollectionConfig.DangerousBattleThreshold

M.UpdateSingleEventBattlePara = function(self, info, battlePara)
	local element = info.mapElement
	local eventId = info.eventId
	local cfg = TaskEventConfig.GetConfig(eventId)

	if not cfg then
		return
	end

	local difficulty = cfg.BattleDifficulty or 0
	local danger = DANGER_THRESOLD <= difficulty - battlePara
	local iconId = danger and DANGER_ICON or SAFE_ICON

	if element.miniMapData.iconId == iconId then
		element.miniMapData.iconId = iconId
	end
end

M.SGetTooltipInfo = function(self, id, element)
	return nil
end

return M
