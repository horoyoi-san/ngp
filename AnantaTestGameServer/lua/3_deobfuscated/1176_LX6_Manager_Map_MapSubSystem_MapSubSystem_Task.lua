local TaskRoleConfig = LTConfig.TaskRoleConfig
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local TaskConfig = LTConfig.TaskConfig
local TIME_LIMIT_TEXT_ID = 89901330
MapSubSystem_Task = DefClass("MapSubSystem_Task", MapSubSystem_Task, MapSubSystemBase)
local M = MapSubSystem_Task

function M:OnInit()
	self._gameScope = {}
	self.Actions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.TraceTask
		},
		[gMapSystem_Element_State.Tracing] = {
			gMapSystemElementAction.UntraceTask
		}
	}
	self.ProfessionalActions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.TraceTask
		},
		[gMapSystem_Element_State.Tracing] = {}
	}
	self.YanjieTaskActions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.TraceTask,
			gMapSystemElementAction.Yanjie
		},
		[gMapSystem_Element_State.Tracing] = {
			gMapSystemElementAction.UntraceTask,
			gMapSystemElementAction.Yanjie
		}
	}
	self.taskInfos = {}
	self.subGpsLists = {}
	self.unacceptTask = {}
	self.visibleUnacceptMainTask = {}
	self.redDotSpiritInfos = {}
	self.spiritToTaskEventMap = {}
	self._otherRaidWorkActionsCache = {}

	self:InitRedDotTaskTitles()
	self:InitHackableUnacceptGpsInfos()
end

function M:Tick()
	local hideWorkActionGps = self.env:CheckSwitch(EMapSwitchType.HideWorkActionGps)

	for _, v in pairs(self.taskInfos) do
		for _, info in pairs(v) do
			local taskGpsInfo = info

			if hideWorkActionGps then
				self:Tmp_Untrace(taskGpsInfo.element)
				taskGpsInfo.element:SetVisible(false)
			elseif taskGpsInfo.metroLineId and taskGpsInfo.metroLineId > 0 and taskGpsInfo.metroCarriageId and taskGpsInfo.metroCarriageId > 0 then
				local position = GpsHelper.GetGpsTargetPosition(taskGpsInfo.worldPos, taskGpsInfo.metroLineId, taskGpsInfo.metroCarriageId)

				if position then
					taskGpsInfo.element:SetPosition(position)
					taskGpsInfo.element:SetVisible(true)

					if not taskGpsInfo.isBranch then
						self:Tmp_Trace(taskGpsInfo.element)
					elseif taskGpsInfo.counterIndex == gTaskManager.curBranchIndex then
						self:Tmp_Trace(taskGpsInfo.element)
					end
				else
					taskGpsInfo.element:SetVisible(false)
					self:Tmp_Untrace(taskGpsInfo.element)
				end
			elseif not taskGpsInfo.element:IsVisible() then
				taskGpsInfo.element:SetPosition(taskGpsInfo.worldPos)
				taskGpsInfo.element:SetVisible(true)

				if not taskGpsInfo.isBranch then
					self:Tmp_Trace(taskGpsInfo.element)
				elseif taskGpsInfo.counterIndex == gTaskManager.curBranchIndex then
					self:Tmp_Trace(taskGpsInfo.element)
				end
			end
		end
	end

	self:UpdateTaskGuiding()
end

function M:HudHasOpenBigMapTip()
	return not not self._hudDisplayOpenBigMap
end

function M:OnChangeGps(data)
	if not data or not data.TaskId then
		return
	end

	local taskGpsInfo = self.taskInfos[data.TaskId]

	if taskGpsInfo and data.GpsPos then
		local idx = data.TaskId .. "_" .. tostring(data.taskCountIndex + 1)
		local element = taskGpsInfo[idx].element

		element:SetPosition(data.GpsPos)

		taskGpsInfo[idx].worldPos = data.GpsPos

		element:SetVisible(true)
		self:Tmp_Untrace(element)
		self:Tmp_Trace(element)

		taskGpsInfo[idx].isOverridePos = true
	end
end

function M:OnLogin()
	self.guidingUnacceptTask = {}
	self._loginScope = {}

	self:ResetSomeData()
	self:InitEventHandlers()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

function M:OnLogout()
	self._hudDisplayOpenBigMap = false
	self._loginScope = nil

	self:ResetSomeData()

	self.guidingUnacceptTask = nil

	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
end

function M:ResetSomeData()
	self.availableImportantTaskEvent = {
		currentTask = {},
		unacceptTask = {}
	}
	self.spirit2TaskTitleSet = {}
end

function M:SetAvailableImportantTask(eventIdHashSet, isCurrentTask)
	local targetSet = nil

	if isCurrentTask then
		targetSet = self.availableImportantTaskEvent.currentTask
	else
		targetSet = self.availableImportantTaskEvent.unacceptTask
	end

	if gGpsTools.TrySetHashDict(targetSet, eventIdHashSet) then
		self:UpdateSpiritToTaskTitleList()
	end
end

function M:UpdateSpiritToTaskTitleList()
	local allTaskEvent = gGpsTools.GetTable()
	local newSpirit2TaskTitleSet = gGpsTools.GetTable()

	for eventId, _ in pairs(self.availableImportantTaskEvent.currentTask) do
		allTaskEvent[eventId] = true
	end

	for eventId, _ in pairs(self.availableImportantTaskEvent.unacceptTask) do
		allTaskEvent[eventId] = true
	end

	for eventId, _ in pairs(allTaskEvent) do
		local taskLineCfg = gTaskNodeManager:GetTaskLineById(eventId)

		if taskLineCfg then
			local playRoleTeam = taskLineCfg.AcceptRoleTeam

			if not playRoleTeam or #playRoleTeam == 0 then
				playRoleTeam = taskLineCfg.PlayRoleTeam
			end

			if playRoleTeam then
				if #playRoleTeam ~= 0 then
					local title = TaskConfig.GetConfig(taskLineCfg.StartTask).Title

					for _, roleId in ipairs(playRoleTeam) do
						local roleCfg = TaskRoleConfig.GetConfig(roleId)

						if roleCfg then
							if roleCfg.IsDefault then
								local fightSpiritId = LTConfig.FightSpiritConfig.DefaultMale

								if not newSpirit2TaskTitleSet[fightSpiritId] then
									newSpirit2TaskTitleSet[fightSpiritId] = gGpsTools.GetTable()
								end

								newSpirit2TaskTitleSet[fightSpiritId][title] = true
								fightSpiritId = LTConfig.FightSpiritConfig.DefaultFemale

								if not newSpirit2TaskTitleSet[fightSpiritId] then
									newSpirit2TaskTitleSet[fightSpiritId] = gGpsTools.GetTable()
								end

								newSpirit2TaskTitleSet[fightSpiritId][title] = true
							elseif roleCfg.FightSpiritId then
								local fightSpiritId = roleCfg.FightSpiritId

								if not newSpirit2TaskTitleSet[fightSpiritId] then
									newSpirit2TaskTitleSet[fightSpiritId] = gGpsTools.GetTable()
								end

								newSpirit2TaskTitleSet[fightSpiritId][title] = true
							end
						end
					end
				end
			end
		end
	end

	gGpsTools.ReleaseTable(allTaskEvent)

	local changed = false

	for spiritId, newTitleSet in pairs(newSpirit2TaskTitleSet) do
		local oldTitleSet = self.spirit2TaskTitleSet[spiritId]

		if not oldTitleSet then
			oldTitleSet = {}
			self.spirit2TaskTitleSet[spiritId] = oldTitleSet
		end

		if gGpsTools.TrySetHashDict(oldTitleSet, newTitleSet) then
			changed = true
		end

		gGpsTools.ReleaseTable(newTitleSet)
	end

	for spiritId, _ in pairs(self.spirit2TaskTitleSet) do
		if not newSpirit2TaskTitleSet[spiritId] then
			self.spirit2TaskTitleSet[spiritId] = nil
			changed = true
		end
	end

	gGpsTools.ReleaseTable(newSpirit2TaskTitleSet)

	if changed then
		gMessageManager:SendMessage(gEventConstants.SPIRIT_AVAILABLE_TASK_TITLES_UPDATE)
	end
end

function M:GetFightSpiritAvailableTaskTitles(spiritId)
	return self.spirit2TaskTitleSet[spiritId]
end

function M:OnFlushData()
	self:UpdateCurrentTask()
	self:UpdateAllUnacceptTask()
end

local _cacheTbl = {}

function M:UpdateAllUnacceptTask()
	local taskEvents = gTaskManager.taskEvents
	local validEvents = _cacheTbl

	table.clear(validEvents)

	local redDotEvents = {}

	for taskLineId, v in pairs(taskEvents or {}) do
		local eventData = v
		local lineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

		if lineCfg then
			if eventData and eventData.Acceptable and eventData.RedPoint then
				table.insert(redDotEvents, taskLineId)
			end

			if eventData then
				if not eventData.HasAccepted then
					-- Nothing
				end
			else
				local taskId = lineCfg.StartTask
				local taskCfg = gTaskManager:GetTaskConfigInfo(taskId)

				if not taskCfg then
					print_error("配表错误 TaskEventConfig=" .. taskLineId .. " : 没有配置有效的StartTask")
				else
					local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)

					if not titleCfg then
						print_error("配表错误 TaskEventConfig=" .. taskCfg.Id .. " : 没有配置TaskTitle")
					elseif titleCfg.PoiLevel <= 2 then
						if titleCfg.PoiLevel <= 0 then
							-- Nothing
						elseif lineCfg.UnacceptGpsPostion then
							if #lineCfg.UnacceptGpsPostion < 3 then
								-- Nothing
							elseif gLinkManager.LinkMode == UX.Game.LinkMode.None or not titleCfg.IsLinkShield then
								validEvents[taskLineId] = true
								local info = nil

								if self.unacceptTask[taskLineId] then
									info = self.unacceptTask[taskLineId]
								else
									local viewMask = nil

									if titleCfg.PoiLevel == 1 then
										viewMask = EMapViewMask.AllSgui + EMapViewMask.FocusMode
									else
										viewMask = EMapViewMask.MiniMap + EMapViewMask.HudGps + EMapViewMask.FocusMode
									end

									local element = MapElement.CreateLegacy(EMapElementType.Task, "UnacceptTask_" .. taskId, EMapSubSystemType.Task, viewMask, taskCfg.RaidId or taskCfg.RelatedRaid, 0)

									if titleCfg.IsAboveFog then
										element.fData.ignoreFog = true
									end

									if taskCfg.Title == TaskTitle.Main or taskCfg.Title == TaskTitle.Legend then
										element.bigMapData.iconSizeType = 0
									elseif taskCfg.Title == TaskTitle.Branch or taskCfg.Title == TaskTitle.Date then
										element.bigMapData.iconSizeType = 1
									end

									element.userdata = {
										unaccpect = true,
										taskLineId = taskLineId
									}
									element.gpsData.vehicleNavPriority = 1
									element.gpsData.vehicleNavResType = 1
									element.gpsData.sceneEffectInfo = {
										effectId = gTaskUtils.GetTaskEffectId(taskId),
										showDistance = LTConfig.GameConfig.TraceLightDisappearRange
									}
									element.fData.showInBigWorld = true
									local worldPos = Vector3.New(lineCfg.UnacceptGpsPostion[1], lineCfg.UnacceptGpsPostion[2], lineCfg.UnacceptGpsPostion[3])

									element:SetPosition(worldPos)

									if lineCfg.UnacceptGpsInfo and lineCfg.UnacceptGpsInfo.IndoorId ~= 0 then
										element.gpsData.preferredGateInfo = {
											gBoundId = self.env.area:GetGBoundId(taskCfg.RaidId, lineCfg.UnacceptGpsInfo.IndoorId, lineCfg.UnacceptGpsInfo.BoundId),
											localGateId = lineCfg.UnacceptGpsInfo.GadteId
										}
									end

									if titleCfg.RemoveGpsRadius > 0 then
										element.gpsData.removeGpsRange = titleCfg.RemoveGpsRadius
									end

									if titleCfg.HideGpsRadius and titleCfg.HideGpsRadius > 0 then
										element.gpsData.tmp_HudAutoHideDistance = titleCfg.HideGpsRadius
									end

									element.mData.lName = GpsLText.CreateCommonText(lineCfg, "EventName")

									if titleCfg.PoiLevel == 1 then
										gMapSubSystemUtils:SetupScaleLevel(element, titleCfg.ShowType, titleCfg.SQuestIcon2)
									end

									info = {
										mapElement = element,
										ignoreBlock = titleCfg.IgnoreBlock,
										blockId = lineCfg.BlockId,
										title = titleCfg.Id,
										poiLevel = titleCfg.PoiLevel
									}
									self.unacceptTask[taskLineId] = info
									local limitSpirits = gMapSubSystemUtils:GetSingleTaskSpiritList(lineCfg)

									if limitSpirits and #limitSpirits > 0 then
										element.fData.bigMapLimitSpirits = limitSpirits
									end

									if lineCfg.ProfileId and lineCfg.ProfileId ~= 0 then
										element.mData.linkSpecificAgentId = gMapSubSystemUtils:GetSpecificAgentIdByProfileId(lineCfg.ProfileId)
									end

									self:SetUnacceptTaskIcon(element, taskLineId, false)
								end

								local isFactionValid = self.env.taskUtils:CheckFactionDisposition(lineCfg)
								info.acceptable = (not eventData or eventData.Acceptable) and isFactionValid
								local element = info.mapElement

								if not info.acceptable then
									element:CbtClearWeakGuideInfo()
									self:Tmp_Untrace(element)

									if not isFactionValid then
										local cfg = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.TaskLowReputation)

										element:SetActions(self.Actions, cfg.Text)
									elseif lineCfg.TimeConditionInfo and lineCfg.TimeConditionInfo.startTimeId ~= 0 and lineCfg.TimeConditionInfo.endTimeId ~= 0 then
										local startTime = LTConfig.WeatherTimeOfDayConfig.GetConfig(lineCfg.TimeConditionInfo.startTimeId).BaseTime
										local endTime = LTConfig.WeatherTimeOfDayConfig.GetConfig(lineCfg.TimeConditionInfo.endTimeId).BaseTime
										local cfg = LTConfig.TextScriptTextConfig.GetConfig(TIME_LIMIT_TEXT_ID)
										local timeText = string.format("%2d:00-%2d:00", startTime, endTime)
										local timeBlockReason = string.gsub(cfg.Text, "%[time%]", timeText)
										element.userdata.timeLimitTooltipText = timeText

										element:SetActions(self.Actions, timeBlockReason)
									elseif not string.is_null_or_empty(lineCfg.UnlockDescription) then
										element:SetActions(self.Actions, lineCfg.UnlockDescription)
									else
										element:SetActions(nil)
									end
								else
									if lineCfg.TargetNpcPid and lineCfg.TargetNpcPid > 0 then
										element:BindUnit(lineCfg.TargetNpcPid)
										element:CbtSetWeakGuideInfo(10)
									end

									if gSocialNetworkUtils.CheckIsTuiteEvent(taskLineId) then
										element:SetActions(self.YanjieTaskActions)
									else
										element:SetActions(self.Actions)
									end
								end

								if self:IsImportantTitle(taskCfg.Title) then
									info.isImportantTask = true
								end
							end
						end
					end
				end
			end
		end
	end

	for taskLineId, info in pairs(self.unacceptTask) do
		if not validEvents[taskLineId] then
			self:Tmp_Untrace(info.mapElement)
			info.mapElement:Dispose()

			self.unacceptTask[taskLineId] = nil
		end
	end

	table.clear(validEvents)
	self:UpdateUnacceptTaskVisibility()
	self:UpdateSpiritFilterRedDot(redDotEvents)
end

function M:UpdateUnacceptTaskVisibility()
	local changed = false

	for eventId, info in pairs(self.unacceptTask) do
		if not info.acceptable and info.poiLevel == 2 then
			if info.isImportantTask and self.visibleUnacceptMainTask[eventId] then
				self.visibleUnacceptMainTask[eventId] = nil
				changed = true
			end

			info.mapElement:SetVisible(false)
		else
			if info.isImportantTask and not self.visibleUnacceptMainTask[eventId] then
				self.visibleUnacceptMainTask[eventId] = true
				changed = true
			end

			info.mapElement:SetVisible(true)
		end
	end

	if self.visibleUnacceptMainTask then
		for eventId, _ in pairs(self.visibleUnacceptMainTask) do
			if not self.unacceptTask[eventId] or not self.unacceptTask[eventId].isImportantTask then
				self.visibleUnacceptMainTask[eventId] = nil
				changed = true
			end
		end
	end

	if changed then
		self:SetAvailableImportantTask(self.visibleUnacceptMainTask, false)
	end
end

function M:UpdateCurrentTask()
	local curShowTasks = gTaskManager:GetAllCurrentShowHudAcceptedTask()
	local validTaskIds = {}

	self:RemoveAllSubGpsLists()

	local miniMapScale = nil
	local visibleImportantTaskEventSet = gGpsTools.GetTable()

	for _, taskData in pairs(curShowTasks) do
		local taskId = taskData.TaskId
		local cfg = gTaskManager:GetTaskConfigInfo(taskId)

		if cfg.Title ~= TaskTitle.RandomEvent and cfg.Title ~= TaskTitle.Situational then
			if cfg.Title ~= TaskTitle.Hide then
				local raidId = cfg.RaidId or cfg.RelatedRaid
				local currentTask, allTasks, nowTargetIndex = nil

				if raidId ~= gRaidDataManager.RaidId then
					currentTask = self:GetWorkactionFromOtherRaid(taskId)
				else
					currentTask, allTasks, nowTargetIndex = gTaskNodeManager:GetTaskCounterInfo(taskId)
				end

				local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)

				if taskLineCfg == nil then
					print_warn("TaskId=" .. taskId .. " 未找到对应的TaskLine")
				else
					local traceWorkActions = nil

					if (array.contains(cfg.Tags, TaskConfig.TagsType.ShowAllGps) or cfg.ShowAllGps or array.contains(cfg.Tags, TaskConfig.TagsType.TrueBranch)) and allTasks then
						traceWorkActions = allTasks
					else
						traceWorkActions = {
							currentTask
						}
					end

					if cfg.TaskMiniMapScale and cfg.TaskMiniMapScale > 0 then
						miniMapScale = cfg.TaskMiniMapScale
					end

					local isCurrentTask = gTaskManager:IsCurrentTask(taskId)
					local validWorkActionIds = {}
					local taskInfo = self.taskInfos[taskId]

					if not taskInfo then
						taskInfo = {}
						self.taskInfos[taskId] = taskInfo
					end

					for _, workActionData in ipairs(traceWorkActions) do
						if workActionData.actionType == 0 then
							-- Nothing
						elseif workActionData.isHideGps then
							-- Nothing
						elseif workActionData.TargetPos or workActionData.NpcId or workActionData.SlotPid or workActionData.VehicleId then
							local workActionId = nil

							if workActionData.CounterIndex then
								workActionId = taskId .. "_" .. workActionData.CounterIndex
							else
								workActionId = taskId
							end

							validWorkActionIds[workActionId] = true

							if taskInfo[workActionId] then
								self:DisposeWorkActionGpsInfo(taskInfo[workActionId])
							end

							taskInfo[workActionId] = self:GetWorkActionGpsInfo(workActionId, taskLineCfg, cfg, isCurrentTask, workActionData, taskId)
						end
					end

					for k, workActionInfo in pairs(taskInfo) do
						if not validWorkActionIds[k] then
							taskInfo[k] = nil

							self:DisposeWorkActionGpsInfo(workActionInfo)
						end
					end

					if not table.isNilOrEmpty(taskInfo) then
						if self:IsImportantTitle(cfg.Title) then
							visibleImportantTaskEventSet[taskLineCfg.Id] = true
						end

						validTaskIds[taskId] = true
					end

					if isCurrentTask then
						local subGpsList = self:CreateSubGpsList(currentTask, taskId)

						if subGpsList then
							table.insert(self.subGpsLists, subGpsList)
						end
					end
				end
			end
		end
	end

	self:SetAvailableImportantTask(visibleImportantTaskEventSet, true)
	gGpsTools.ReleaseTable(visibleImportantTaskEventSet)

	if miniMapScale then
		gMapManager:SetMiniMapScale(miniMapScale, gMapScaleType.Task)
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Task)
	end

	self:RemoveTaskInvalid(validTaskIds)
end

function M:DisposeWorkActionGpsInfo(gpsInfo)
	if gpsInfo.element then
		self:Tmp_Untrace(gpsInfo.element)
		gpsInfo.element:Dispose()

		gpsInfo.element = nil
	end
end

function M:GetWorkActionGpsInfo(workActionId, taskLineCfg, cfg, isCurrentTask, workActionData, taskId)
	local agentTag = workActionData.SpiritAgentTag and workActionData.SpiritAgentTag ~= 0 and workActionData.SpiritAgentTag or nil
	local npcId = workActionData.NpcId and workActionData.NpcId ~= 0 and workActionData.NpcId or nil
	local slotPid = workActionData.SlotPid and ulong.tostring(workActionData.SlotPid) ~= "0" and workActionData.SlotPid or nil
	local vehicleSpoonId = workActionData.VehicleId and workActionData.VehicleId ~= 0 and workActionData.VehicleId or nil
	local worldPos = workActionData.TargetPos
	local gpsInfo = {
		counterIndex = workActionData.CounterIndex,
		gpsId = workActionId,
		enable = true,
		traceType = EMapGTraceType.Main,
		metroLineId = workActionData.metroLineId,
		metroCarriageId = workActionData.metroCarriageId,
		taskId = taskId,
		isBranch = workActionData.IsBranchTarget
	}

	if not npcId and not slotPid and not worldPos and not vehicleSpoonId and not agentTag then
		return nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.Task, workActionId, EMapSubSystemType.Task, EMapViewMask.AllSgui + EMapViewMask.FocusMode, cfg.RaidId or cfg.RelatedRaid, workActionData.IndoorId)
	element.fData.ignoreFog = true

	if cfg.Title == TaskTitle.ProfessionalTask then
		element:SetActions(self.ProfessionalActions)
	elseif gSocialNetworkUtils.CheckIsTuiteEvent(taskLineCfg.Id) then
		element:SetActions(self.YanjieTaskActions)
	else
		element:SetActions(self.Actions)
	end

	if cfg.Title == TaskTitle.Main or cfg.Title == TaskTitle.Legend then
		element.bigMapData.iconSizeType = 0
	elseif cfg.Title == TaskTitle.Branch or cfg.Title == TaskTitle.Date then
		element.bigMapData.iconSizeType = 1
	end

	element.userdata = {
		taskLineId = taskLineCfg.Id,
		taskId = taskId
	}

	if workActionData.HideGpsRange and workActionData.HideGpsRange ~= 0 then
		local hideGpsRange = workActionData.HideGpsRange

		if hideGpsRange < 0 then
			element.gpsData.tmp_HudAutoShowDistance = -hideGpsRange
		else
			element.gpsData.tmp_HudAutoHideDistance = hideGpsRange
		end
	end

	local iconId = workActionData.TargetIconId

	if not iconId or iconId == 0 then
		iconId = gTaskManager.TaskSIconId[cfg.Title]
	end

	if workActionData.IsChasingVehicleOrUnit then
		element.fData.hudTIndex = 1
	end

	element.gpsData.ignoreIndoorPenetration = workActionData.IgnoreIndoorPenetration
	element.mData.sIconId = iconId

	if workActionData.IsBranchTarget then
		element.mData.lName = GpsLText.CreateIndexedText(cfg, "EventObjective", workActionData.CounterIndex)
	else
		element.mData.lName = GpsLText.CreateCommonText(taskLineCfg, "EventName")
	end

	if workActionData.specialAreaPoints and #workActionData.specialAreaPoints > 0 then
		element.mData.polygonRangeInfo = {
			points = workActionData.specialAreaPoints,
			color = Color.NewByStr(gTaskManager.TaskColor[cfg.Title]),
			isLeaveRange = workActionData.IsLeaveMapRange
		}
	elseif workActionData.TaskRange and workActionData.TaskRange > 0 then
		local isLeaveRange = workActionData.IsLeaveMapRange
		element.mData.rangeInfo = {
			radius = workActionData.TaskRange,
			color = Color.NewByStr(gTaskManager.TaskColor[cfg.Title]),
			isLeaveRange = isLeaveRange
		}
	else
		element.mData.rangeInfo = nil
	end

	element.gpsData.isGpsTargetItem = workActionData.IsGpsTargetItem
	element.gpsData.targetItemGpsIconId = workActionData.TargetItemGpsIconId
	element.gpsData.taskFeisuoId = workActionData.TaskFeiSuoId

	if workActionData.preferredGateInfo then
		element:SetPreferredGateInfo(workActionData.preferredGateInfo.gBoundId, workActionData.preferredGateInfo.localGateId)
	end

	element:SetVisible(true)

	gpsInfo.element = element
	local effectId = gTaskUtils.GetTaskEffectId(cfg.Id)

	if effectId and not workActionData.IsChasingVehicleOrUnit then
		local effectShowDistance = workActionData.HideHintPillarRange and workActionData.HideHintPillarRange > 0 and workActionData.HideHintPillarRange or LTConfig.GameConfig.TraceLightDisappearRange
		gpsInfo.element.gpsData.sceneEffectInfo = {
			effectId = effectId,
			showDistance = effectShowDistance
		}
	end

	gpsInfo.worldPos = worldPos

	if agentTag then
		gpsInfo.element:BindAgentTag(agentTag)
	elseif npcId then
		gpsInfo.element:BindUnit(npcId)

		gpsInfo.element.gpsData.hudInteractionConflictInfo = {
			id = workActionData.NpcId,
			type = gTaskGpsTargetType.Npc
		}
	elseif slotPid then
		gpsInfo.element:BindSlotInfo(slotPid, workActionData.SlotRefId, nil)

		gpsInfo.element.gpsData.hudInteractionConflictInfo = {
			id = workActionData.SlotPid,
			type = gTaskGpsTargetType.LuaSlot
		}
	elseif vehicleSpoonId then
		local vehiclePartNodeName = GpsHelper.TranslateVehicleNodeEnumToNodeName(workActionData.VehicleGpsNode)

		gpsInfo.element:BindVehicle(vehicleSpoonId, vehiclePartNodeName, nil, nil, true)

		gpsInfo.element.gpsData.hudInteractionConflictInfo = {
			id = vehicleSpoonId,
			type = gTaskGpsTargetType.Vehicle
		}
	end

	gpsInfo.element:SetPosition(worldPos)

	gpsInfo.element.gpsData.vehicleNavPriority = 1
	gpsInfo.element.gpsData.vehicleNavResType = 1

	if workActionData.DontShowVehicleTrace and workActionData.DontShowVehicleTrace > 0 then
		gpsInfo.element.gpsData.disableVehicleNav = true
	elseif workActionData.DontShowVehicleTraceOnGround and workActionData.DontShowVehicleTraceOnGround > 0 then
		gpsInfo.element.gpsData.vehicleNavHideGroundEffect = true
	end

	if workActionData.IsShowMapGuide and workActionData.IsShowMapGuide == 1 then
		gpsInfo.element.gpsData.showWalkNav = true
		gpsInfo.element.gpsData.walkNavPriority = 1
	end

	gpsInfo.element.bigMapData.hideDropInfo = workActionData.HideDropInfo

	if workActionData.overrideTooltipInfo then
		element.bigMapData.overrideTooltipInfo = {
			tooltipType = workActionData.overrideTooltipInfo.TooltipType,
			infoName = workActionData.overrideTooltipInfo.TooltipInfoName,
			fieldDatas = {}
		}

		for fieldName, fieldValue in pairs(workActionData.overrideTooltipInfo.Fields or {}) do
			element.bigMapData.overrideTooltipInfo.fieldDatas[fieldName] = fieldValue
		end
	end

	if isCurrentTask then
		if workActionData.IsBranchTarget then
			local index = workActionData.CounterIndex

			if index == gTaskManager.curBranchIndex then
				self:Tmp_Trace(element)
			else
				self:Tmp_Untrace(element)
			end
		else
			self:Tmp_Trace(element)
		end
	else
		self:Tmp_Untrace(element)
	end

	return gpsInfo
end

function M:CreateSubGpsList(workActionData, taskId)
	if not workActionData then
		return nil
	end

	local cfg = TaskConfig.GetConfig(taskId)

	if workActionData.SubGpsInfoList ~= nil and #workActionData.SubGpsInfoList > 0 then
		local subGpsList = {}

		for i, workactionSubGps in ipairs(workActionData.SubGpsInfoList) do
			local subGps = {}
			local gpsId = taskId .. "_" .. (workActionData.CounterIndex or 0) .. "_SubGps_" .. i
			local element = MapElement.CreateLegacy(EMapElementType.Task, gpsId, EMapSubSystemType.Task, EMapViewMask.MiniMap, workActionData.RaidId, workActionData.IndoorId)
			element.fData.ignoreFog = true

			if workactionSubGps.IconId == 0 then
				element.mData.sIconId = 28001636
				element.miniMapData.color = Color.NewByStr(gTaskManager.TaskColor[cfg.Title])
			else
				element.mData.sIconId = workactionSubGps.IconId
			end

			if workactionSubGps.GpsType == 0 then
				element:BindUnit(workactionSubGps.NpcId)
			elseif workactionSubGps.GpsType == 1 then
				element:BindVehicle(workactionSubGps.VehicleId, nil, nil, nil, true)
			elseif workactionSubGps.GpsType == 2 then
				element:BindSlotInfo(workactionSubGps.SlotId)
			elseif workactionSubGps.GpsType == 3 then
				element:BindDestructible(workactionSubGps.DestructibleId)
			elseif workactionSubGps.GpsType == 4 then
				element:BindUnit(workactionSubGps.EnemyId)
			end

			element:SetVisible(true)
			element:SetPosition(element:GetWorldPos())

			subGps.element = element

			table.insert(subGpsList, subGps)
		end

		return subGpsList
	else
		return nil
	end
end

function M:DisposeSubGpsList(subGpsList)
	if subGpsList ~= nil and #subGpsList > 0 then
		for i, subGps in ipairs(subGpsList) do
			if subGps.element then
				subGps.element:Dispose()

				subGps.element = nil
			end
		end
	end
end

function M:RemoveTaskInvalid(validTaskIds)
	for k, workActions in pairs(self.taskInfos) do
		if not validTaskIds[k] then
			for _, workActionInfo in pairs(workActions) do
				self:DisposeWorkActionGpsInfo(workActionInfo)
			end

			self.taskInfos[k] = nil
		end
	end
end

function M:RemoveAllSubGpsLists()
	for _, subGpsList in ipairs(self.subGpsLists) do
		self:DisposeSubGpsList(subGpsList)
	end

	table.clear(self.subGpsLists)
end

function M:SGetTooltipInfo(id, element)
	local taskLineId = element.userdata and element.userdata.taskLineId
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskLineId)
	local taskLineCfg = taskLineInfo and LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
	local dropIds = gMapSubSystemUtils:GetDropIdListByTaskLineId(taskLineId)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskLineInfo.StartTask)
	local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)
	local tooltipInfo = {
		type = EMapTooltipType.Task,
		header = {
			name = element:GetName(),
			imageId = taskLineCfg and taskLineCfg.SMapPhoto,
			subtitle = titleCfg and titleCfg.Name or ""
		}
	}

	if element.mData.linkSpecificAgentId == 0 then
		-- Nothing
	end

	tooltipInfo.taskInfo = {
		title = taskCfg.Title,
		desc = gUtils:GetSpecialDescription(taskLineInfo.EventDescription),
		simpleDropIds = dropIds,
		specificSpirits = gMapSubSystemUtils:GetSingleTaskSpiritList(taskLineCfg),
		timeLimitText = element.userdata.timeLimitTooltipText,
		hideDropInfo = element.bigMapData.hideDropInfo or false,
		linkSpecificAgentId = element.mData.linkSpecificAgentId
	}

	return tooltipInfo
end

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.Yanjie then
		local taskLineId = element.userdata and element.userdata.taskLineId

		if not taskLineId then
			print_warn("MapSubSystem_Task:ExecuteAction: element userdata.taskLineId is nil")

			return
		end

		gMapUtils:CloseBigMap()
		gSocialNetworkUtils.OpenTuiteDetail(taskLineId)

		return
	end

	if element.userdata and element.userdata.unaccpect then
		if action == gMapSystemElementAction.TraceTask then
			self:Tmp_Trace(element)
			self:SetUnacceptTaskIcon(element, element.userdata.taskLineId, true)
			gMessageManager:SendMessage(gEventConstants.ON_TRACING_UNACCEPT_TASK, element.userdata.taskLineId)
		elseif action == gMapSystemElementAction.UntraceTask then
			self:Tmp_Untrace(element)
			self:SetUnacceptTaskIcon(element, element.userdata.taskLineId, false)
		end

		return
	end

	if action ~= gMapSystemElementAction.TraceTask and action ~= gMapSystemElementAction.UntraceTask then
		print_warn("MapSubSystem_Task:ExecuteAction: action not supported", action)

		return
	end

	for taskId, workActions in pairs(self.taskInfos) do
		local gpsInfo = workActions[element.id]

		if gpsInfo then
			if gpsInfo.isBranch then
				local taskHud = gStoreManager:GetStoreGroup("NormalTaskPanelStore")

				if action == gMapSystemElementAction.TraceTask then
					taskHud:SwitchBranchByGpsId(gpsInfo.gpsId)
					gTaskManager:SetCurrentTask(taskId)
				elseif action == gMapSystemElementAction.UntraceTask then
					self:Tmp_Untrace(element)
					taskHud:RefreshTrueBranchList()
				end
			elseif action == gMapSystemElementAction.TraceTask then
				gTaskManager:SetCurrentTask(taskId)
			elseif action == gMapSystemElementAction.UntraceTask then
				gTaskManager:RemoveCurrentTask(taskId, function ()
					gGpsManager:RemoveGPSById(element.gpsId, gTaskGpsType.Forward)
				end)
			end
		end
	end
end

function M:GetFirstGpsIdByTaskId(taskId)
	local workActions = self.taskInfos[taskId]

	if not workActions then
		local gpsId = "UnacceptTask_" .. taskId

		for _, info in pairs(self.unacceptTask) do
			if info.mapElement and info.mapElement.gpsId == gpsId then
				return gpsId
			end
		end

		return nil
	end

	local firstWorkActionElement = nil

	for _, workAction in pairs(workActions) do
		firstWorkActionElement = workAction

		break
	end

	if not firstWorkActionElement then
		return nil
	end

	return firstWorkActionElement.element.gpsId
end

function M:GetActionInfo(element)
	if not element.userdata.unaccpect then
		return nil, nil
	end

	return element:GetRawActions(), element.actionsBlockReason
end

function M:OnBigMapOpen()
	for _, info in pairs(self.unacceptTask) do
		self:UpdateFilterTag(info.mapElement)
	end

	for _, taskInfos in pairs(self.taskInfos) do
		for _, info in pairs(taskInfos) do
			self:UpdateFilterTag(info.element)
		end
	end
end

function M:UpdateFilterTag(element)
	if not element or not element.userdata then
		return
	end

	local taskLineId = element.userdata.taskLineId
	local lineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)
	local requireTids = gMapSubSystemUtils:GetSingleTaskSpiritList(lineCfg)

	if not requireTids or #requireTids == 0 then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.CurSpiritTask
		element.bigMapData.tmp_filterTag2 = LTConfig.GpsFilterTagConfig.OtherSpiritTask

		return
	end

	local curTid = gSpiritManager:GetCurFirstSpiritTid()
	element.bigMapData.tmp_filterTag2 = nil

	if array.contains(requireTids, curTid) then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.CurSpiritTask
	else
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.OtherSpiritTask
	end
end

function M:SetUnacceptTaskIcon(element, taskLineId, isTracing)
	local info = self.unacceptTask[taskLineId]
	local titleCfg = LTConfig.TaskTitleConfig.GetConfig(info.title)
	local iconId = titleCfg.SQuestIcon
	element.mData.sIconId = iconId
	element.miniMapData.iconId = iconId
	local prevTindex = element.miniMapData.miniMapTIndex

	if self.env.taskUtils:IsCurSpiritNotMatch(taskLineId) then
		element.miniMapData.miniMapTIndex = 2
	else
		element.miniMapData.miniMapTIndex = nil
	end

	if element.miniMapData.miniMapTIndex ~= prevTindex then
		gMessageManager:SendMessage(gEventConstants.MINIMAP_ICON_SWITCH_SUBSCRIPT_CHANGE, element.instanceId)
	end
end

function M:Tmp_Trace(element)
	if element.userdata and element.userdata.unaccpect then
		gMapSubSystemActionHelper.Trace(element)

		local taskLineId = element.userdata.taskLineId

		self.env.taskUtils:NotifyTaskEventGuided(taskLineId)
	else
		element:SetTraceInfo(EMapGTraceType.Main, 0)
	end
end

function M:Tmp_Untrace(element)
	if element.userdata and element.userdata.unaccpect then
		gMapSubSystemActionHelper.Untrace(element)
	else
		element:ClearTraceInfo()
	end
end

function M:UpdateMiniMapTaskIcon()
	local taskEvents = gTaskManager.taskEvents

	for taskLineId, v in pairs(taskEvents or {}) do
		local info = nil

		if self.unacceptTask[taskLineId] then
			info = self.unacceptTask[taskLineId]
			local element = info.mapElement

			if element then
				self:SetUnacceptTaskIcon(element, taskLineId, false)
			end
		end
	end
end

function M:UpdateSpiritFilterRedDot(redDotTaskEvents)
	local redDotSpiritInfos = {}

	table.clear(self.spiritToTaskEventMap)

	for _, taskLineId in ipairs(redDotTaskEvents) do
		local taskLineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

		if taskLineCfg then
			local taskId = taskLineCfg.StartTask
			local taskCfg = TaskConfig.GetConfig(taskId)

			if not taskCfg then
				-- Nothing
			else
				local title = taskCfg.Title

				if not self.redDotTaskTitlePriority[title] then
					-- Nothing
				else
					local taskSpirits = gMapSubSystemUtils:GetSingleTaskSpiritList(taskLineCfg)

					if taskSpirits and #taskSpirits > 0 then
						for _, spiritId in ipairs(taskSpirits) do
							if redDotSpiritInfos[spiritId] == nil or redDotSpiritInfos[spiritId].priority < self.redDotTaskTitlePriority[title] then
								redDotSpiritInfos[spiritId] = {
									title = title,
									priority = self.redDotTaskTitlePriority[title]
								}
							end

							if self.spiritToTaskEventMap[spiritId] == nil then
								self.spiritToTaskEventMap[spiritId] = {}
							end

							table.insert(self.spiritToTaskEventMap[spiritId], taskLineId)
						end
					end
				end
			end
		end
	end

	self.redDotSpiritInfos = redDotSpiritInfos
end

function M:IsSpiritHasRedDot(spiritId)
	return self.redDotSpiritInfos[spiritId] ~= nil
end

function M:GetSpiritRedDotTitle(spiritId)
	local info = self.redDotSpiritInfos[spiritId]

	return info and info.title or nil
end

function M:InitRedDotTaskTitles()
	self.redDotTaskTitlePriority = {}

	for _, title in ipairs(LTConfig.TaskConfig.AcceptTaskType) do
		self.redDotTaskTitlePriority[title] = -1
	end

	for priority, title in ipairs(LTConfig.TaskConfig.MapRedDotType) do
		if self.redDotTaskTitlePriority[title] then
			self.redDotTaskTitlePriority[title] = 50 - priority
		end
	end
end

function M:GetWorkactionFromOtherRaid(taskId)
	if self._otherRaidWorkActionsCache[taskId] then
		return self._otherRaidWorkActionsCache[taskId]
	end

	local rawWorkActions = gCS.SpoonTaskMgr.Instance:GetTaskWorkActionByTask(taskId)

	if not rawWorkActions or #rawWorkActions.WorkAction == 0 then
		return nil
	end

	local rawWorkAction = rawWorkActions.WorkAction[1]
	local cfg = gTaskManager:GetTaskConfigInfo(taskId)
	local taskValue = {
		TaskId = taskId,
		RaidId = cfg.RaidId or cfg.RelatedRaid,
		isHideGps = rawWorkAction.IsHideGps or false,
		NpcId = rawWorkAction.NpcId or 0,
		SlotPid = rawWorkAction.GadgetId or 0,
		SlotRefId = rawWorkAction.ButtonPosId or 0,
		VehicleGpsNode = rawWorkAction.VehicleGpsNode,
		VehicleId = rawWorkAction.VehicleId or 0
	}
	local isVecZero = rawWorkAction.targetPos == nil or rawWorkAction.targetPos.x == 0 and rawWorkAction.targetPos.y == 0 and rawWorkAction.targetPos.z == 0

	if isVecZero then
		taskValue.TargetPos = nil
	else
		taskValue.TargetPos = rawWorkAction.targetPos:Clone()
	end

	taskValue.actionType = rawWorkAction.actionType
	taskValue.isHideGps = rawWorkAction.IsHideGps
	taskValue.IndoorId = rawWorkAction.IndoorId or 0
	self._otherRaidWorkActionsCache[taskId] = taskValue

	return taskValue
end

function M:TraceByHudTaskBranchSwitch(taskId, targetGpsId)
	if not self.taskInfos[taskId] then
		return
	end

	for _, info in pairs(self.taskInfos[taskId]) do
		if targetGpsId == info.gpsId then
			self:Tmp_Trace(info.element)
		else
			self:Tmp_Untrace(info.element)
		end
	end
end

function M:GetGpsIdByTaskEventId(taskEventId)
	local eventInfo = self.unacceptTask[taskEventId]

	if eventInfo and eventInfo.mapElement then
		return eventInfo.mapElement.gpsId
	end

	for taskId, workActions in pairs(self.taskInfos) do
		local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)

		if taskLineCfg and taskLineCfg.Id == taskEventId then
			for _, workAction in pairs(workActions) do
				return workAction.element.gpsId
			end
		end
	end

	return nil
end

function M:IsImportantTaskElement(element)
	if element.subSystemType ~= EMapSubSystemType.Task then
		return false
	end

	local taskLineId = element.userdata and element.userdata.taskLineId

	if not taskLineId then
		return false
	end

	local info = self.unacceptTask[taskLineId]

	return info and info.isImportantTask and info.title ~= 2
end

function M:IsCurrentTaskElement(element)
	if element.subSystemType ~= EMapSubSystemType.Task then
		return false
	end

	local taskId = element.userdata and element.userdata.taskId

	if not taskId then
		return false
	end

	return gTaskManager:IsCurrentTask(taskId)
end

function M:GetElementTaskTitle(element)
	if element.subSystemType ~= EMapSubSystemType.Task then
		return nil
	end

	local taskId = element.userdata and element.userdata.taskId

	if taskId then
		local cfg = TaskConfig.GetConfig(taskId)

		return cfg and cfg.Title
	end

	local taskLineId = element.userdata and element.userdata.taskLineId

	if not taskLineId then
		return nil
	end

	local info = self.unacceptTask[taskLineId]

	if not info then
		return nil
	end

	return info.title
end

function M:HasCurTask()
	local curTask = gTaskManager:GetCurTask()
	curTask = curTask and curTask ~= 0

	return curTask
end

function M:IsImportantTitle(title)
	return self.env.taskUtils:IsMiniMapGuidingTaskTitle(title)
end

function M:InitHackableUnacceptGpsInfos()
	self._hackableUnacceptGpsInfos = {}

	for i = 1, LTConfig.TaskEventConfig.count do
		local lineCfg = LTConfig.TaskEventConfig.GetConfig(i)

		if not lineCfg then
			-- Nothing
		else
			local taskId = lineCfg.StartTask
			local taskCfg = LTConfig.TaskConfig.GetConfig(taskId)

			if not taskCfg then
				-- Nothing
			elseif not array.contains(LTConfig.TaskConfig.HackableTaskTitles, taskCfg.Title) then
				-- Nothing
			elseif lineCfg.UnacceptGpsPostion and #lineCfg.UnacceptGpsPostion == 3 then
				self._hackableUnacceptGpsInfos[lineCfg.Id] = Vector3.New(lineCfg.UnacceptGpsPostion[1], lineCfg.UnacceptGpsPostion[2], lineCfg.UnacceptGpsPostion[3])
			end
		end
	end
end

function M:GetHackableUnacceptGpsInfos()
	local ret = {}
	local taskEvents = gTaskManager.taskEvents

	for id, pos in pairs(self._hackableUnacceptGpsInfos) do
		if taskEvents[id] and not taskEvents[id].HasAccepted then
			ret[id] = pos
		end
	end

	return ret
end

function M:IsTracingTask(taskLineId)
	return self.env.trace:AnyTracingElement(function (element)
		return element.type == EMapElementType.Task and element.userdata and element.userdata.taskLineId == taskLineId
	end)
end

function M:OnGlobalGpsUpdate(eventId, param)
	local id = param.newInstanceId
	local element = self.env.container:Get(id)

	if element.type == EMapElementType.Task and element.userdata and element.userdata.unaccpect then
		gNewGuideMgr:NotifySignal(EGuideSignal.TraceAnyUnacceptTask)
		gClientToGameDelegate:AskTrackEvent(element.userdata.taskLineId)
	end
end

function M:GetGpsInstanceIdByTaskId(taskId)
	local currentTaskInfo = self.taskInfos[taskId]

	if currentTaskInfo then
		local firstKey = next(currentTaskInfo)

		if firstKey then
			local workActionInfo = currentTaskInfo[firstKey]

			return workActionInfo.element.instanceId
		end
	end

	local eventId = gTaskNodeManager:GetEventIdByTask(taskId)
	local unacceptTaskInfo = self.unacceptTask[eventId]

	if unacceptTaskInfo then
		return unacceptTaskInfo.mapElement.instanceId
	end

	return nil
end

function M:OnGuidingTaskTitleChanged()
	self:UpdateTaskGuiding()
end

function M:UpdateTaskGuiding()
	local hudOpenBigMapTip = nil
	local miniMapGuidingTitle = gGpsTools.GetTable()
	local anyTrace = self.env.trace:AnyTracingElement(function (element)
		return element:CheckViewMask(EMapViewMask.MiniMap)
	end)

	if not anyTrace and (gTaskNodeManager:GetNowDoingTask() == 0 or gTaskNodeManager:GetNowDoingTask() == nil) then
		for taskEventId, info in pairs(self.unacceptTask) do
			if self.env.taskUtils:IsMiniMapGuidingTaskTitle(info.title) then
				if info.mapElement.miniMapData.tmp_needWeakGuide ~= true then
					info.mapElement.miniMapData.tmp_needWeakGuide = true

					self.env.container:RestageItem(info.mapElement.instanceId)
				end

				miniMapGuidingTitle[info.title] = true
				hudOpenBigMapTip = true
			elseif info.mapElement.miniMapData.tmp_needWeakGuide then
				info.mapElement.miniMapData.tmp_needWeakGuide = nil

				self.env.container:RestageItem(info.mapElement.instanceId)
			end
		end
	else
		for taskEventId, info in pairs(self.unacceptTask) do
			if info.mapElement.miniMapData.tmp_needWeakGuide then
				info.mapElement.miniMapData.tmp_needWeakGuide = nil

				self.env.container:RestageItem(info.mapElement.instanceId)
			end
		end
	end

	self:SetHudOpenBigMapTipState(hudOpenBigMapTip)
	self:SetHudGuidingTitles(miniMapGuidingTitle)
	gGpsTools.ReleaseTable(miniMapGuidingTitle)
end

function M:SetHudOpenBigMapTipState(newValue)
	if not self._hudDisplayOpenBigMap ~= not newValue then
		self._hudDisplayOpenBigMap = newValue

		gMessageManager:SendMessage(gEventConstants.HUD_OPEN_BIG_MAP_TIP_CHANGE)
	end
end

function M:SetHudGuidingTitles(titles)
	if not self._loginScope then
		return
	end

	if not self._loginScope.hudGuidingTitles then
		self._loginScope.hudGuidingTitles = {}
	end

	for title, _ in pairs(titles) do
		if self.env.taskUtils:IsHudGuidingTaskTitle(title) then
			titles[title] = nil
		end
	end

	local changed = gGpsTools.TrySetHashDict(self._loginScope.hudGuidingTitles, titles)

	if changed then
		gMessageManager:SendMessage(gEventConstants.MINI_MAP_GUIDING_TASK_TITLES_UPDATE)
	end
end

function M:GetGuidingTitles()
	if not self._loginScope or not self._loginScope.hudGuidingTitles then
		return {}
	end

	local ret = {}

	for title, _ in pairs(self._loginScope.hudGuidingTitles) do
		table.insert(ret, title)
	end

	return ret
end

function M:InitEventHandlers()
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.TASK_STATE_CHANGED] = function ()
			self:FlushData()
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.MAP_INFO_UPDATE] = function ()
			self:FlushData()
		end,
		[gEventConstants.PALYER_LEVEL_UP] = function ()
			self:FlushData()
		end,
		[gEventConstants.CHANGE_COUNTER_DES_GPS] = function (eventId, data)
			self:OnChangeGps(data)
		end,
		[gEventConstants.LINK_MODE_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.ON_EVENT_STATE_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.SYNC_CURRENT_SPIRIT] = function ()
			self:UpdateMiniMapTaskIcon()
		end,
		[gEventConstants.ON_GLOBAL_GPS_UPDATE] = function (eventId, param)
			self:OnGlobalGpsUpdate(eventId, param)
		end,
		[gEventConstants.BEFORE_SWITCH_SCENE] = function ()
			table.clear(self._otherRaidWorkActionsCache)
		end
	}
end

return M
