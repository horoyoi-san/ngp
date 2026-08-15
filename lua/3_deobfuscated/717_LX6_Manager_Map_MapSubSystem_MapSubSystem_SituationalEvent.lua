local MapBlockMgr = LX6.Gps.MapBlockMgr
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
MapSubSystem_SituationalEvent = DefClass("MapSubSystem_SituationalEvent", MapSubSystem_SituationalEvent, MapSubSystemBase)
local M = MapSubSystem_SituationalEvent

function M:OnInit()
	self.questInfos = {}
	self.EventState = {
		Finish = 3,
		Doing = 2,
		Locked = 4,
		Unaccept = 1
	}
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:OnCurrentTaskChange()
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function (eventId)
			self:OnCurrentTaskChange()
			self:MarkAsDirty()
		end,
		[gEventConstants.TASK_STATE_CHANGED] = function ()
			self:MarkAsDirty()
		end,
		[gEventConstants.SYNC_COLLECTION_GET] = function ()
			self:MarkAsDirty()
		end,
		[gEventConstants.SYNC_COLLECTION_UNLOCK] = function (eventId, params)
			self:MarkAsDirty()
		end,
		[gEventConstants.PALYER_LEVEL_UP] = function ()
			self:MarkAsDirty()
		end,
		[gEventConstants.SYSTEM_UNLOCK_STATE_CHANGE] = function (eventId, systemId)
			if systemId == LTConfig.SystemUnlockConfig.MapSituationEvent then
				self:MarkAsDirty()
			end
		end
	}

	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnCurrentTaskChange()
	self._ignoreEvent = false
	local curTaskList = gTaskManager:GetAllAcceptedTask()

	if curTaskList then
		for taskId, _ in pairs(curTaskList) do
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

			if table.contains(taskCfg.Tags, LTConfig.TaskConfig.TagsType.NoMapSituationTask) then
				self._ignoreEvent = true
			end
		end
	end
end

function M:OnLoadData()
	self:LoadConfig()

	for id, info in pairs(self.questInfos) do
		info.questElement:Dispose()

		if info.workActionElements then
			for _, element in pairs(info.workActionElements) do
				element:Dispose()
			end
		end
	end

	self.questInfos = {}

	for i = 0, LTConfig.CollectionSubQuestConfig.count - 1 do
		local subQuestCfg = LTConfig.CollectionSubQuestConfig.LoadAt(i)
		local questCfg = LTConfig.CollectionQuestConfig.GetConfig(subQuestCfg.QuestCategory)

		if questCfg and questCfg.PoiLevel == 2 and questCfg.SQuestIcon then
			if questCfg.SQuestIcon <= 0 then
				-- Nothing
			elseif not subQuestCfg.TaskId then
				-- Nothing
			else
				local taskCfg = LTConfig.TaskConfig.GetConfig(subQuestCfg.TaskId)

				if not taskCfg then
					print_error("#NoCreateIssue @策划 Collection.SubQuest-" .. subQuestCfg.Id .. " 对应的Task不存在-" .. subQuestCfg.TaskId)
				elseif taskCfg.Title ~= TaskTitle.Situational then
					-- Nothing
				else
					local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(subQuestCfg.TaskId)

					if not taskLineInfo then
						-- Nothing
					else
						local eventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)

						if eventCfg then
							if eventCfg.CenterPos then
								local info = {
									taskId = subQuestCfg.TaskId,
									taskEventId = taskLineInfo.TaskLineId,
									centerPos = Vector3.New(eventCfg.CenterPos[1], eventCfg.CenterPos[2], eventCfg.CenterPos[3]),
									state = self.EventState.Finish
								}
								info.geoCenter = info.centerPos
								info.cfg = subQuestCfg
								info.lod = 3
								self.questInfos[subQuestCfg.Id] = info
								local raidId = subQuestCfg.RaidId

								if not raidId or raidId <= 0 then
									raidId = LTConfig.RaidConfig.WorldMap
								end

								local element = MapElement.CreateLegacy(EMapElementType.Collection, subQuestCfg.Id, EMapSubSystemType.SituationalEvent, EMapViewMask.MiniMap, raidId, 0)
								element.bigMapData.scaleLevel = 0

								element:SetPosition(info.centerPos)

								element.mData.lName = GpsLText.CreateCommonText(subQuestCfg, "SubQuestName")
								element.mData.sIconId = questCfg.Id == 27 and questCfg.SQuestIcon or 28001078
								element.miniMapData.miniMapTIndex = 1

								element:SetVisible(false)

								info.questElement = element
								info.raidId = raidId
								info.blockId = MapBlockMgr.GetBlockIdXZ(raidId, info.centerPos.x, info.centerPos.z)
							end
						end
					end
				end
			end
		end
	end

	self._dirty = true
end

function M:Tick()
	if self._dirty then
		self._dirty = false

		self:FlushData()
	end

	self:TickRange()
end

local vec3 = Vector3.zero

function M:TickRange()
	if not L50.L50App.Scene.GamePlayUtils or L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		return
	end

	local hasLod1 = false
	local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
	local x = playerPos.x
	local y = playerPos.y
	local z = playerPos.z

	for id, info in pairs(self.questInfos) do
		local lod1 = self:TickElementRange(x, y, z, info)
		hasLod1 = hasLod1 or lod1
	end

	if hasLod1 then
		gMapManager:SetMiniMapScale(LTConfig.CollectionConfig.PoiIIMiniMapScale, gMapScaleType.TaskTitle8)
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.TaskTitle8)
	end
end

function M:TickElementRange(x, y, z, info)
	if info.raidId ~= gMapSystem.lastRaidId or self.EventState.Finish <= info.state then
		return false
	end

	local lod1Ret = false

	if info.state == self.EventState.Unaccept and (info.raidId == LTConfig.RaidConfig.WorldMap or info.raidId == LTConfig.RaidConfig.Chongxiao) and not gBlockMgr:IsBlockUnlocked(info.blockId) then
		info.lod = 3
	else
		if info.isDynamic and info.workActionElements then
			vec3:Set(0, 0, 0)

			local count = 0

			for _, element in pairs(info.workActionElements) do
				local worldPos = element:GetWorldPos()

				if worldPos then
					vec3:Add(worldPos)

					count = count + 1
				end
			end

			if count > 0 then
				vec3:Div(count)
				info.geoCenter:Set(vec3.x, vec3.y, vec3.z)
				info.questElement:SetPosition(info.geoCenter)
			end
		end

		local dx = x - info.geoCenter.x
		local dy = y - info.geoCenter.y
		local dz = z - info.geoCenter.z
		local sqrtXZ = dx * dx + dz * dz
		local sqrtY = dy * dy

		if info.lod == 3 then
			if sqrtXZ < self.sqrt.detailRangeXZ and sqrtY < self.sqrt.detailRangeY then
				info.lod = 1
			elseif sqrtXZ < self.sqrt.showRangeXZ and sqrtY < self.sqrt.showRangeY then
				info.lod = 2
			end
		elseif info.lod == 2 then
			if self.sqrt.hideRangeXZ < sqrtXZ or self.sqrt.hideRangeY < sqrtY then
				info.lod = 3
			elseif sqrtXZ < self.sqrt.detailRangeXZ and sqrtY < self.sqrt.detailRangeY then
				info.lod = 1
			end
		elseif self.sqrt.hideRangeXZ < sqrtXZ or self.sqrt.hideRangeY < sqrtY then
			info.lod = 3
		elseif self.sqrt.lowRangeXZ < sqrtXZ or self.sqrt.lowRangeY < sqrtY then
			info.lod = 2
		end
	end

	if info.lod == 1 then
		lod1Ret = true
	end

	if info.lod == 3 and (gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.PoiIILodMax2) or info.cfg.QuestCategory == 27) then
		info.lod = 2
	end

	if self._ignoreEvent then
		info.lod = 3
	end

	if info.state == self.EventState.Doing and not info.degraded then
		if info.lod == 2 then
			info.questElement:SetVisible(true)
		else
			info.questElement:SetVisible(false)
		end

		if info.lod == 1 then
			for _, element in pairs(info.workActionElements) do
				element:SetVisible(true)
			end
		else
			for _, element in pairs(info.workActionElements) do
				element:SetVisible(false)
			end
		end
	else
		if info.lod <= 2 then
			info.questElement:SetVisible(true)
		else
			info.questElement:SetVisible(false)
		end

		if info.workActionElements then
			for _, element in pairs(info.workActionElements) do
				element:SetVisible(false)
			end
		end
	end

	return lod1Ret
end

function M:OnFlushData()
	local unlockedQuestList = gPlayerManager.infoAchievement.bindData.UnlockedQuestList
	local x = 0
	local y = 0
	local z = 0

	if not L50.L50App.Scene.GamePlayUtils:UnitIsNull(gCS.MyPlayerManager.PlayerUnit) then
		local playerPos = gCS.MyPlayerManager.PlayerUnit.LocalPosition
		z = playerPos.z
		y = playerPos.y
		x = playerPos.x
	end

	for id, info in pairs(self.questInfos) do
		if info.raidId ~= gMapSystem.lastRaidId then
			info.state = self.EventState.Locked
		else
			local state = gTaskNodeManager:GetTaskLineState(info.taskEventId)

			if state == gTaskLineState.Doing then
				info.state = self.EventState.Doing
				info.taskId = gTaskNodeManager:GetEventNowDoTaskId(info.taskEventId)
			elseif not gSystemUnlockMgr:IsUnlock(LTConfig.SystemUnlockConfig.MapSituationEvent) or not table.contains(unlockedQuestList, info.cfg.QuestCategory) or not self:TaskEventLaunchCheck(info.taskEventId) then
				info.state = self.EventState.Locked
			elseif state == gTaskLineState.Finish then
				info.state = self.EventState.Finish
			else
				info.state = self.EventState.Unaccept
			end
		end

		if info.state == self.EventState.Finish or info.state == self.EventState.Locked then
			info.questElement:SetVisible(false)
			info.questElement:SetPosition(info.centerPos)

			info.lod = 3

			self:TryRemoveAllWorkActions(info)
		elseif info.state == self.EventState.Unaccept then
			info.questElement:SetVisible(true)
			info.questElement:SetPosition(info.centerPos)
			self:TryRemoveAllWorkActions(info)
			self:TickElementRange(x, y, z, info)
		elseif info.state == self.EventState.Doing then
			self:ActiveWorkctions(info)
		else
			print_error("@sunwei: 未知状态")
		end
	end
end

function M:MarkAsDirty()
	self._dirty = true
end

function M:ActiveWorkctions(info)
	info.questElement:SetVisible(true)

	local cfg = gTaskManager:GetTaskConfigInfo(info.taskId)
	local curWorkAction, allWorkActions, _ = gTaskNodeManager:GetTaskCounterInfo(info.taskId)

	if not info.workActionElements then
		info.workActionElements = {}
	end

	local workActions = nil

	if array.contains(cfg.Tags, LTConfig.TaskConfig.TagsType.ShowAllGps) or cfg.ShowAllGps then
		workActions = allWorkActions
	else
		workActions = {
			curWorkAction
		}
	end

	for _, element in pairs(info.workActionElements) do
		element:Dispose()
	end

	info.workActionElements = {}
	info.geoCenter = info.centerPos

	if not workActions then
		return
	end

	local taskCfg = LTConfig.TaskConfig.GetConfig(info.taskId)
	local vec3 = Vector3.zero
	local validWorkActionCount = 0
	local pointWorkActionCount = 0
	local isDynamic = false

	for _, workActionData in ipairs(workActions) do
		if workActionData.actionType == 0 then
			-- Nothing
		else
			local counterIndex = workActionData.CounterIndex
			local idWithCounter = info.questElement.id .. "_" .. info.taskId .. "_" .. counterIndex
			local npcId = workActionData.NpcId and workActionData.NpcId ~= 0 and workActionData.NpcId or nil
			local slotPid = workActionData.SlotPid and ulong.tostring(workActionData.SlotPid) ~= "0" and workActionData.SlotPid or nil
			local vehicleSpoonId = workActionData.VehicleId and workActionData.VehicleId or nil
			local target = workActionData.Target
			local worldPos = workActionData.TargetPos

			if npcId or slotPid or vehicleSpoonId or worldPos then
				local element = MapElement.CreateLegacy(EMapElementType.Collection, idWithCounter, EMapSubSystemType.SituationalEvent, EMapViewMask.MiniMap, workActionData.RaidId, workActionData.IndoorId)
				info.workActionElements[counterIndex] = element
				element.bigMapData.scaleLevel = 0
				element.mData.lName = GpsLText.CreateCommonText(taskCfg, "Name")
				element.miniMapData.miniMapTIndex = 1

				if target then
					element.userdata = {
						target = target
					}
				end

				if npcId then
					element:BindUnit(npcId)

					isDynamic = true
				elseif slotPid then
					element:BindSlotInfo(slotPid)

					isDynamic = true
				elseif vehicleSpoonId then
					element:BindVehicle(vehicleSpoonId, nil, nil, nil, true)

					isDynamic = true
				end

				if worldPos then
					vec3:Add(worldPos)

					validWorkActionCount = validWorkActionCount + 1

					element:SetPosition(worldPos)
				end

				local range = workActionData.TaskRange

				if range and range > 0 then
					element.mData.sIconId = 0
					element.mData.rangeInfo = {
						radius = range,
						color = Color.NewByStr(gTaskManager.TaskColor[taskCfg.Title])
					}
				else
					pointWorkActionCount = pointWorkActionCount + 1
					element.mData.sIconId = 28001078
					element.mData.rangeInfo = nil
				end
			end
		end
	end

	info.isDynamic = isDynamic

	if validWorkActionCount > 0 then
		vec3:Div(validWorkActionCount)

		info.geoCenter = vec3

		if validWorkActionCount == 1 and pointWorkActionCount == 1 then
			info.degraded = true
		else
			info.degraded = false
		end
	else
		info.geoCenter = info.centerPos
		info.degraded = true
	end

	info.questElement:SetPosition(info.geoCenter)
end

function M:TaskEventLaunchCheck(taskEventId)
	if gMapSystem:CheckDebugSwitch(EMapSystemDebugKey.IgnoreCollectionTaskAvailableCheck) then
		return true
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskEventId)

	if taskLineInfo and taskLineInfo.TaskLineId then
		local eventCfg = LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)

		if eventCfg and gTaskManager:IsSpoonEventAcceptable(taskLineInfo.TaskLineId) then
			return true
		end
	end

	return false
end

function M:TryRemoveAllWorkActions(info)
	if info.workActionElements then
		for _, element in pairs(info.workActionElements) do
			element:Dispose()
		end
	end

	info.workActionElements = nil
end

function M:LoadConfig()
	self.range = {
		showRangeXZ = LTConfig.CollectionConfig.PoiIIShowDistance[1],
		showRangeY = LTConfig.CollectionConfig.PoiIIShowDistance[2],
		hideRangeXZ = LTConfig.CollectionConfig.PoiIIHideDistance[1],
		hideRangeY = LTConfig.CollectionConfig.PoiIIHideDistance[2],
		detailRangeXZ = LTConfig.CollectionConfig.PoiIIGpsShowDistance[1],
		detailRangeY = LTConfig.CollectionConfig.PoiIIGpsShowDistance[2],
		lowRangeXZ = LTConfig.CollectionConfig.PoiIIGpsHideDistance[1],
		lowRangeY = LTConfig.CollectionConfig.PoiIIGpsHideDistance[2]
	}
	self.sqrt = {
		showRangeXZ = self.range.showRangeXZ * self.range.showRangeXZ,
		showRangeY = self.range.showRangeY * self.range.showRangeY,
		hideRangeXZ = self.range.hideRangeXZ * self.range.hideRangeXZ,
		hideRangeY = self.range.hideRangeY * self.range.hideRangeY,
		detailRangeXZ = self.range.detailRangeXZ * self.range.detailRangeXZ,
		detailRangeY = self.range.detailRangeY * self.range.detailRangeY,
		lowRangeXZ = self.range.lowRangeXZ * self.range.lowRangeXZ,
		lowRangeY = self.range.lowRangeY * self.range.lowRangeY
	}
end

return M
