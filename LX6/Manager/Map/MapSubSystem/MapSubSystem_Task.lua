-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Task.lua
-- Decompiled from: 02307_MapSubSystem_Task.lua_24b7cbcff408.luajit

local TaskRoleConfig = LTConfig.TaskRoleConfig
local TaskTitle = require("LX6/Manager/Task/TaskTitle")
local TaskEventConfig = LTConfig.TaskEventConfig
local TaskTitleConfig = LTConfig.TaskTitleConfig
local TaskConfig = LTConfig.TaskConfig
local TIME_LIMIT_TEXT_ID = 89901330
local BIG_MAP_TASK_TINDEX = 11
local BIG_MAP_TASK_NORMAL_TINDEX = 12
MapSubSystem_Task = DefClass("MapSubSystem_Task", MapSubSystem_Task, MapSubSystemBase)
local M = MapSubSystem_Task

M.SetupTaskMapIconStyle = function(self, element, titleCfg, iconId)
	local useSelectedAnim = iconId and iconId == 0 and iconId ~= titleCfg.SQuestIcon and titleCfg.SelectedAnim ~= true

	if useSelectedAnim then
		element.fData.bigMapTIndex = BIG_MAP_TASK_TINDEX
		element.mData.selectedIcon = titleCfg.SelectedIcon
		element.mData.ShadowIcon = titleCfg.ShadowIcon or 0
		element.bigMapData.openAnim = "S_vx_MapIcon_Task_open"
		element.bigMapData.loopAnim = "S_vx_MapIcon_Task_loop"
		element.bigMapData.closeAnim = "S_vx_MapIcon_Task_close"
	else
		element.fData.bigMapTIndex = BIG_MAP_TASK_NORMAL_TINDEX
		element.mData.selectedIcon = nil
		element.mData.ShadowIcon = 0
		element.bigMapData.openAnim = nil
		element.bigMapData.loopAnim = nil
		element.bigMapData.closeAnim = nil
	end
end

M.OnInit = function(self)
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
	self.UnderWayTaskAction = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.ContinueTask
		}
	}
	self.taskInfos = {}
	self.subGpsLists = {}
	self.unacceptTask = {}
	self.visibleUnacceptMainTask = {}
	self.redDotSpiritInfos = {}
	self.spiritToTaskEventMap = {}
	self._otherRaidWorkActionsCache = {}

	self.InitRedDotTaskTitles(self)
	self.InitHackableUnacceptGpsInfos(self)

	self.filterCharacterTid = nil
	self.implicitTraceAgentTags = {}
end

M.Tick = function(self)
	local hideWorkActionGps = self.env:CheckSwitch(EMapSwitchType.HideWorkActionGps)

	for _, v in pairs(self.taskInfos) do
		for _, info in pairs(v) do
			local taskGpsInfo = info

			if hideWorkActionGps then
				self:Tmp_Untrace(taskGpsInfo.element)
				taskGpsInfo.element:SetVisible(false)
			elseif taskGpsInfo.platformType and taskGpsInfo.platformType == gLuaEnum.MovingPlatformType.None then
				local position = GpsHelper.GetGpsTargetPosition(taskGpsInfo.worldPos, taskGpsInfo.platformType, taskGpsInfo.platformId, taskGpsInfo.platformPartId)

				if position then
					taskGpsInfo.element:SetPosition(position)
					taskGpsInfo.element:SetVisible(true)

					if not taskGpsInfo.isBranch then
						self.Tmp_Trace(self, taskGpsInfo.element)
					elseif taskGpsInfo.counterIndex ~= gTaskManager.curBranchIndex then
						self.Tmp_Trace(self, taskGpsInfo.element)
					end
				else
					taskGpsInfo.element:SetVisible(false)
					self:Tmp_Untrace(taskGpsInfo.element)
				end
			elseif not taskGpsInfo.element:IsVisible() then
				taskGpsInfo.element:SetPosition(taskGpsInfo.worldPos)
				taskGpsInfo.element:SetVisible(true)

				if not taskGpsInfo.isBranch then
					self.Tmp_Trace(self, taskGpsInfo.element)
				elseif taskGpsInfo.counterIndex ~= gTaskManager.curBranchIndex then
					self.Tmp_Trace(self, taskGpsInfo.element)
				end
			end
		end
	end

	self.UpdateTaskGuiding(self)
end

M.HudHasOpenBigMapTip = function(self)
	return not not self._hudDisplayOpenBigMap
end

M.OnChangeGps = function(self, data)
	if not data or not data.TaskId then
		return
	end

	local taskGpsInfo = self.taskInfos[data.TaskId]

	if taskGpsInfo and data.GpsPos then
		local idx = data.TaskId .. "_" .. tostring(data.taskCountIndex + 1)
		local element = taskGpsInfo[idx].element

		element.SetPosition(element, data.GpsPos)

		taskGpsInfo[idx].worldPos = data.GpsPos

		element.SetVisible(element, true)
		self.Tmp_Untrace(self, element)
		self.Tmp_Trace(self, element)

		taskGpsInfo[idx].isOverridePos = true
	end
end

M.OnLogin = function(self)
	self.guidingUnacceptTask = {}
	self._loginScope = {}

	self:ResetSomeData()
	self:InitEventHandlers()
	gMessageManager:RegisterEventHandlers(self.eventHandlers)
end

M.OnLogout = function(self)
	self._hudDisplayOpenBigMap = false
	self._loginScope = nil

	self:ResetSomeData()

	self.guidingUnacceptTask = nil

	gMessageManager:UnregisterEventHandlers(self.eventHandlers)
end

M.ResetSomeData = function(self)
	self.availableImportantTaskEvent = {
		currentTask = {},
		unacceptTask = {}
	}
	self.spirit2TaskTitleSet = {}
end

M.SetAvailableImportantTask = function(self, eventIdHashSet, isCurrentTask)
	local targetSet = nil

	if isCurrentTask then
		targetSet = self.availableImportantTaskEvent.currentTask
	else
		targetSet = self.availableImportantTaskEvent.unacceptTask
	end

	if gGpsTools.TrySetHashDict(targetSet, eventIdHashSet) then
		self.UpdateSpiritToTaskTitleList(self)
	end
end

M.UpdateSpiritToTaskTitleList = function(self)
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

			if not playRoleTeam or #playRoleTeam ~= 0 then
				playRoleTeam = taskLineCfg.PlayRoleTeam
			end

			if playRoleTeam then
				if #playRoleTeam == 0 then
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

M.GetFightSpiritAvailableTaskTitles = function(self, spiritId)
	return self.spirit2TaskTitleSet[spiritId]
end

M.OnSceneInit = function(self)
end

M.OnFlushData = function(self)
	self.UpdateCurrentTask(self)
	self.UpdateAllUnacceptTask(self)
end

local _cacheTbl = {}

M.UpdateAllUnacceptTask = function(self)
	local taskEvents = gTaskManager.taskEvents
	local validEvents = _cacheTbl

	table.clear(validEvents)

	local redDotEvents = {}
	slot4 = pairs
	slot6 = taskEvents or {}

	for taskLineId, v in slot4(slot6) do
		local eventData = v
		local lineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)

		if lineCfg then
			if eventData and eventData.Acceptable and eventData.RedPoint and not lineCfg.ShowRedPointWhenShowInMap then
				table.insert(redDotEvents, taskLineId)
			end

			if eventData and eventData.HasAccepted then
				-- Nothing
			else
				local taskId = lineCfg.StartTask
				local taskCfg = gTaskManager:GetTaskConfigInfo(taskId)

				if not taskCfg then
					print_error("配表错误 TaskEventConfig=" .. taskLineId .. " : 没有配置有效的StartTask")
				else
					local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)

					if not titleCfg then
						print_error("配表错误 TaskEventConfig=" .. taskCfg.Id .. " : 没有配置TaskTitle")
					elseif titleCfg.PoiLevel < 2 then
						if titleCfg.PoiLevel < 0 then
							-- Nothing
						elseif lineCfg.UnacceptGpsPostion then
							if #lineCfg.UnacceptGpsPostion >= 3 then
								-- Nothing
							elseif gLinkManager.LinkMode ~= UX.Game.LinkMode.None or not titleCfg.IsLinkShield then
								if eventData and eventData.Acceptable and eventData.RedPoint and lineCfg.ShowRedPointWhenShowInMap then
									table.insert(redDotEvents, taskLineId)
								end

								validEvents[taskLineId] = true
								local info = nil

								if self.unacceptTask[taskLineId] then
									info = self.unacceptTask[taskLineId]
								else
									local viewMask = nil

									if titleCfg.PoiLevel ~= 1 then
										viewMask = EMapViewMask.AllSgui + EMapViewMask.FocusMode
									else
										viewMask = EMapViewMask.MiniMap + EMapViewMask.HudGps + EMapViewMask.FocusMode
									end

									local element = MapElement.CreateLegacy(EMapElementType.Task, "UnacceptTask_" .. taskId, EMapSubSystemType.Task, viewMask, taskCfg.RaidId or taskCfg.RelatedRaid, 0)

									if titleCfg.IsAboveFog then
										element.fData.ignoreFog = true
									end

									element.bigMapData.iconSizeType = titleCfg.IconSizeType
									element.userdata = {
										["VImjM,"] = true,
										taskLineId = taskLineId
									}
									element.gpsData.vehicleNavPriority = 1
									element.gpsData.vehicleNavResType = 1
									element.gpsData.sceneEffectInfo = {
										effectId = gTaskUtils.GetTaskEffectId(taskId),
										showDistance = LTConfig.GameConfig.TraceLightDisappearRange
									}
									element.gpsData.taskTitle = taskCfg.Title
									element.fData.showInBigWorld = true
									local worldPos = Vector3.New(lineCfg.UnacceptGpsPostion[1], lineCfg.UnacceptGpsPostion[2], lineCfg.UnacceptGpsPostion[3])

									element.SetPosition(element, worldPos)

									if lineCfg.UnacceptGpsInfo and lineCfg.UnacceptGpsInfo.IndoorId == 0 then
										element.gpsData.preferredGateInfo = {
											gBoundId = self.env.area:GetGBoundId(taskCfg.RaidId, lineCfg.UnacceptGpsInfo.IndoorId, lineCfg.UnacceptGpsInfo.BoundId),
											localGateId = lineCfg.UnacceptGpsInfo.GadteId
										}
									end

									if titleCfg.RemoveGpsRadius <= 0 then
										element.gpsData.removeGpsRange = titleCfg.RemoveGpsRadius
									end

									if titleCfg.HideGpsRadius and titleCfg.HideGpsRadius <= 0 then
										element.gpsData.tmp_HudAutoHideDistance = titleCfg.HideGpsRadius
									end

									element.mData.lName = GpsLText.CreateCommonText(lineCfg, "EventName")

									if titleCfg.PoiLevel ~= 1 then
										gMapSubSystemUtils:SetupScaleLevel(element, titleCfg.ShowType, titleCfg.SQuestIcon2)
									end

									if array.contains(lineCfg.EventTag, LTConfig.TaskEventConfig.EventTagType.HackerCat) then
										element.mData.hideWhenUnitNotExist = true
									end

									self:SetupTaskMapIconStyle(element, titleCfg, titleCfg.SQuestIcon)

									info = {
										mapElement = element,
										ignoreBlock = titleCfg.IgnoreBlock,
										blockId = lineCfg.BlockId,
										title = titleCfg.Id,
										poiLevel = titleCfg.PoiLevel
									}
									self.unacceptTask[taskLineId] = info
									local limitSpirits = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(lineCfg)

									if limitSpirits and #limitSpirits <= 0 then
										element.fData.bigMapLimitSpirits = limitSpirits
									end

									if lineCfg.ProfileId and lineCfg.ProfileId == 0 then
										element.mData.linkSpecificAgentId = gMapSubSystemUtils:GetSpecificAgentIdByProfileId(lineCfg.ProfileId)
									end

									self.SetUnacceptTaskIcon(self, element, taskLineId, false)
								end

								local isFactionValid = self.env.taskUtils:CheckFactionDisposition(lineCfg)
								info.acceptable = (not eventData or eventData.Acceptable) and isFactionValid
								local element = info.mapElement

								if not info.acceptable then
									element.CbtClearWeakGuideInfo(element)
									self.Tmp_Untrace(self, element)

									if not isFactionValid then
										local cfg = LTConfig.TextCommonTextConfig.GetConfig(LTConfig.TextCommonTextConfig.TaskLowReputation)

										element.SetActions(element, self.Actions, cfg.Text)
									elseif lineCfg.TimeConditionInfo and lineCfg.TimeConditionInfo.startTimeId == 0 and lineCfg.TimeConditionInfo.endTimeId == 0 then
										local startTime = LTConfig.WeatherTimeOfDayConfig.GetConfig(lineCfg.TimeConditionInfo.startTimeId).BaseTime
										local endTime = LTConfig.WeatherTimeOfDayConfig.GetConfig(lineCfg.TimeConditionInfo.endTimeId).BaseTime
										local cfg = LTConfig.TextScriptTextConfig.GetConfig(TIME_LIMIT_TEXT_ID)
										local timeText = string.format("%2d:00-%2d:00", startTime, endTime)
										local timeBlockReason = string.gsub(cfg.Text, "%[time%]", timeText)
										element.userdata.timeLimitTooltipText = timeText

										element.SetActions(element, self.Actions, timeBlockReason)
									elseif not string.is_null_or_empty(lineCfg.UnlockDescription) then
										element.SetActions(element, self.Actions, lineCfg.UnlockDescription)
									else
										element.SetActions(element, self.Actions)
									end
								else
									if lineCfg.TargetNpcPid and lineCfg.TargetNpcPid <= 0 then
										element.BindUnit(element, lineCfg.TargetNpcPid)
										element.CbtSetWeakGuideInfo(element, 10)
									end

									if gSocialNetworkUtils.CheckIsTuiteEvent(taskLineId) then
										element.SetActions(element, self.YanjieTaskActions)
									elseif eventData.IsUnderway then
										element.SetActions(element, self.UnderWayTaskAction)
									else
										element.SetActions(element, self.Actions)
									end
								end

								if self.IsImportantTitle(self, taskCfg.Title) then
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
	self.UpdateUnacceptTaskVisibility(self)
	self.UpdateSpiritFilterRedDot(self, redDotEvents)
end

M.UpdateUnacceptTaskVisibility = function(self)
	local changed = false

	for eventId, info in pairs(self.unacceptTask) do
		if not info.acceptable and info.poiLevel ~= 2 then
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
		self.SetAvailableImportantTask(self, self.visibleUnacceptMainTask, false)
	end
end

M.ShouldSkipOccupiedBattleCampGps = function(self, workActionData)
	local tooltipInfo = workActionData.overrideTooltipInfo

	if not tooltipInfo or tooltipInfo.TooltipInfoName == "gangsterSmallCampInfo" then
		return false
	end

	local fields = tooltipInfo.Fields

	return gMapSubSystem_Gangster == nil and gMapSubSystem_Gangster:IsBattleCampOccupiedByOtherFaction(fields and fields.influenceId) or false
end

M.UpdateCurrentTask = function(self)
	table.clear(self.implicitTraceAgentTags)

	local curShowTasks = gTaskManager:GetAllCurrentShowHudAcceptedTask()
	local validTaskIds = {}

	self:RemoveAllSubGpsLists()

	local miniMapScale = nil
	local visibleImportantTaskEventSet = gGpsTools.GetTable()
	local blockPoiPopup = false

	for _, taskData in pairs(curShowTasks) do
		local taskId = taskData.TaskId
		local cfg = gTaskManager:GetTaskConfigInfo(taskId)

		if cfg.Title == TaskTitle.RandomEvent and cfg.Title == TaskTitle.Situational then
			if cfg.Title == TaskTitle.Hide then
				local raidId = cfg.RaidId or cfg.RelatedRaid
				local currentTask, allTasks, nowTargetIndex = nil

				if raidId == gRaidDataManager.RaidId then
					currentTask = self.GetWorkactionFromOtherRaid(self, taskId)
				else
					currentTask, allTasks, nowTargetIndex = gTaskNodeManager:GetTaskCounterInfo(taskId)
				end

				local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)

				if taskLineCfg ~= nil then
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

					if cfg.TaskMiniMapScale and cfg.TaskMiniMapScale <= 0 then
						miniMapScale = cfg.TaskMiniMapScale
					end

					if cfg.BlockPoiPopup then
						blockPoiPopup = true
					end

					local isCurrentTask = gTaskManager:IsCurrentTask(taskId)
					local validWorkActionIds = {}
					local taskInfo = self.taskInfos[taskId]

					if not taskInfo then
						taskInfo = {}
						self.taskInfos[taskId] = taskInfo
					end

					for _, workActionData in ipairs(traceWorkActions) do
						if not self.ShouldSkipOccupiedBattleCampGps(self, workActionData) then
							local agentTagList = workActionData.ImplicitGpsTargetAgentTagList

							if agentTagList then
								for i = 1, #agentTagList do
									self.implicitTraceAgentTags[agentTagList[i]] = true
								end
							end

							if workActionData.actionType ~= 0 then
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
									self.DisposeWorkActionGpsInfo(self, taskInfo[workActionId])
								end

								taskInfo[workActionId] = self.GetWorkActionGpsInfo(self, workActionId, taskLineCfg, cfg, isCurrentTask, workActionData, taskId)
							end
						end
					end

					for k, workActionInfo in pairs(taskInfo) do
						if not validWorkActionIds[k] then
							taskInfo[k] = nil

							self.DisposeWorkActionGpsInfo(self, workActionInfo)
						end
					end

					if not table.isNilOrEmpty(taskInfo) then
						if self.IsImportantTitle(self, cfg.Title) then
							visibleImportantTaskEventSet[taskLineCfg.Id] = true
						end

						validTaskIds[taskId] = true
					end

					if isCurrentTask then
						local subGpsList = self.CreateSubGpsList(self, currentTask, taskId)

						if subGpsList then
							table.insert(self.subGpsLists, subGpsList)
						end
					end
				end
			end
		end
	end

	gMapSystem.poi:SetBlockPoiPopup(blockPoiPopup)
	self:SetAvailableImportantTask(visibleImportantTaskEventSet, true)
	gGpsTools.ReleaseTable(visibleImportantTaskEventSet)

	if miniMapScale then
		gMapManager:SetMiniMapScale(miniMapScale, gMapScaleType.Task)
	else
		gMapManager:RemoveMiniMapScaleType(gMapScaleType.Task)
	end

	self.RemoveTaskInvalid(self, validTaskIds)
end

M.DisposeWorkActionGpsInfo = function(self, gpsInfo)
	if gpsInfo.element then
		self:Tmp_Untrace(gpsInfo.element)
		gpsInfo.element:Dispose()

		gpsInfo.element = nil
	end
end

M.GetWorkActionGpsInfo = function(self, workActionId, taskLineCfg, cfg, isCurrentTask, workActionData, taskId)
	local agentTag = workActionData.SpiritAgentTag and workActionData.SpiritAgentTag == 0 and workActionData.SpiritAgentTag or nil
	local npcId = workActionData.NpcId and workActionData.NpcId == 0 and workActionData.NpcId or nil
	local slotPid = workActionData.SlotPid and ulong.tostring(workActionData.SlotPid) == "0" and workActionData.SlotPid or nil
	local vehicleSpoonId = workActionData.VehicleId and workActionData.VehicleId == 0 and workActionData.VehicleId or nil
	local destructibleId = workActionData.DestructibleId and ulong.tostring(workActionData.DestructibleId) == "0" and workActionData.DestructibleId or nil

	if vehicleSpoonId then
		local playerVehicleId = gTaskUtils:GetPlayerVehicleId(taskLineCfg.Id, vehicleSpoonId)

		if playerVehicleId and playerVehicleId == 0 then
			vehicleSpoonId = playerVehicleId
		end
	end

	local worldPos = workActionData.TargetPos
	local gpsInfo = {
		counterIndex = workActionData.CounterIndex,
		gpsId = workActionId,
		enable = true,
		traceType = EMapGTraceType.Main,
		platformId = workActionData.platformId,
		platformPartId = workActionData.platformPartId,
		platformType = workActionData.platformType,
		taskId = taskId,
		isBranch = workActionData.IsBranchTarget
	}

	if not npcId and not slotPid and not worldPos and not vehicleSpoonId and not agentTag then
		return nil
	end

	if cfg.Title ~= LTConfig.TaskTitleConfig.PublicEvent then
		return nil
	end

	local element = MapElement.CreateLegacy(EMapElementType.Task, workActionId, EMapSubSystemType.Task, EMapViewMask.AllSgui + EMapViewMask.FocusMode, cfg.RaidId or cfg.RelatedRaid, workActionData.IndoorId)
	element.fData.ignoreFog = true
	element.gpsData.taskTitle = cfg.Title

	if cfg.Title ~= TaskTitle.ProfessionalTask or cfg.Title ~= TaskTitle.MultiPlayerScene then
		element.SetActions(element, self.ProfessionalActions)
	elseif gSocialNetworkUtils.CheckIsTuiteEvent(taskLineCfg.Id) then
		element.SetActions(element, self.YanjieTaskActions)
	else
		element.SetActions(element, self.Actions)
	end

	if cfg.Title ~= TaskTitle.Main or cfg.Title ~= TaskTitle.Legend or cfg.Title ~= LTConfig.TaskTitleConfig.Monetization then
		element.bigMapData.iconSizeType = 0
	elseif cfg.Title ~= TaskTitle.Branch or cfg.Title ~= TaskTitle.Date then
		element.bigMapData.iconSizeType = 1
	end

	element.userdata = {
		taskLineId = taskLineCfg.Id,
		taskId = taskId
	}

	if workActionData.HideGpsRange and workActionData.HideGpsRange == 0 then
		local hideGpsRange = workActionData.HideGpsRange

		if hideGpsRange >= 0 then
			element.gpsData.tmp_HudAutoShowDistance = -hideGpsRange
		else
			element.gpsData.tmp_HudAutoHideDistance = hideGpsRange
		end
	end

	local iconId = workActionData.TargetIconId

	if not iconId or iconId ~= 0 then
		iconId = gTaskManager.TaskSIconId[cfg.Title]
	end

	if workActionData.IsChasingVehicleOrUnit then
		element.fData.hudTIndex = 1
	end

	element.mData.ignoreIndoorPenetration = workActionData.IgnoreIndoorPenetration
	element.mData.sIconId = iconId

	if workActionData.IsBranchTarget then
		element.mData.lName = GpsLText.CreateIndexedText(cfg, "EventObjective", workActionData.CounterIndex, taskLineCfg.Id)
	else
		element.mData.lName = GpsLText.CreateCommonText(taskLineCfg, "EventName")
	end

	element.mData.polygonRangeInfo = nil
	element.mData.gpsCustomAreaRangeInfo = nil
	element.mData.rangeInfo = nil
	local rangeColor = Color.NewByStr(gTaskManager.TaskColor[cfg.Title])

	if workActionData.gpsCustomAreas and #workActionData.gpsCustomAreas <= 0 then
		element.mData.gpsCustomAreaRangeInfo = {
			areas = workActionData.gpsCustomAreas,
			color = rangeColor,
			isLeaveRange = workActionData.IsLeaveMapRange
		}
	elseif workActionData.specialAreaPoints and #workActionData.specialAreaPoints <= 0 then
		element.mData.polygonRangeInfo = {
			points = workActionData.specialAreaPoints,
			color = rangeColor,
			isLeaveRange = workActionData.IsLeaveMapRange
		}
	elseif workActionData.TaskRange and workActionData.TaskRange <= 0 then
		local isLeaveRange = workActionData.IsLeaveMapRange
		element.mData.rangeInfo = {
			radius = workActionData.TaskRange,
			color = rangeColor,
			isLeaveRange = isLeaveRange
		}
	end

	element.gpsData.isGpsTargetItem = workActionData.IsGpsTargetItem
	element.gpsData.targetItemGpsIconId = workActionData.TargetItemGpsIconId
	element.gpsData.taskFeisuoId = workActionData.TaskFeiSuoId

	if workActionData.preferredGateInfo then
		element.SetPreferredGateInfo(element, workActionData.preferredGateInfo.gBoundId, workActionData.preferredGateInfo.localGateId)
	end

	local titleCfg = LTConfig.TaskTitleConfig.GetConfig(cfg.Title)

	if titleCfg then
		self.SetupTaskMapIconStyle(self, element, titleCfg, iconId)
	end

	element.SetVisible(element, true)

	gpsInfo.element = element
	local gpsData = element.gpsData
	local effectId = gTaskUtils.GetTaskEffectId(cfg.Id)

	if effectId and not workActionData.IsChasingVehicleOrUnit then
		local effectShowDistance = workActionData.HideHintPillarRange and workActionData.HideHintPillarRange <= 0 and workActionData.HideHintPillarRange or LTConfig.GameConfig.TraceLightDisappearRange
		gpsData.sceneEffectInfo = {
			effectId = effectId,
			showDistance = effectShowDistance
		}
	end

	gpsInfo.worldPos = worldPos

	if agentTag then
		gpsInfo.element:BindAgentTag(agentTag)
	elseif npcId then
		slot20 = gpsInfo.element

		slot20:BindUnit(npcId)

		gpsData.hudInteractionConflictInfo = {
			id = workActionData.NpcId,
			type = gTaskGpsTargetType.Npc
		}
	elseif slotPid then
		slot20 = gpsInfo.element

		slot20:BindSlotInfo(slotPid, workActionData.SlotRefId, nil)

		gpsData.hudInteractionConflictInfo = {
			id = workActionData.SlotPid,
			type = gTaskGpsTargetType.LuaSlot
		}
	elseif vehicleSpoonId then
		local vehiclePartNodeName = GpsHelper.TranslateVehicleNodeEnumToNodeName(workActionData.VehicleGpsNode)
		slot21 = gpsInfo.element

		slot21:BindVehicle(vehicleSpoonId, vehiclePartNodeName, nil, , true)

		gpsData.hudInteractionConflictInfo = {
			id = vehicleSpoonId,
			type = gTaskGpsTargetType.Vehicle
		}
	elseif destructibleId then
		slot20 = gpsInfo.element

		slot20:BindDestructible(destructibleId)

		gpsData.hudInteractionConflictInfo = {
			id = destructibleId,
			type = gTaskGpsTargetType.Destructible
		}
	end

	if not destructibleId then
		gpsInfo.element:SetPosition(worldPos)
	end

	gpsData.vehicleNavPriority = 1
	gpsData.vehicleNavResType = 1
	gpsData.preferMainRoadNavigation = workActionData.PreferMainRoadNavigation or false

	if workActionData.DontShowVehicleTrace and workActionData.DontShowVehicleTrace <= 0 then
		gpsData.disableVehicleNav = true
	elseif workActionData.DontShowVehicleTraceOnGround and workActionData.DontShowVehicleTraceOnGround <= 0 then
		gpsData.vehicleNavHideGroundEffect = true
	end

	if workActionData.IsShowMapGuide and workActionData.IsShowMapGuide ~= 1 then
		gpsData.showWalkNav = true
		gpsData.walkNavPriority = 1
	end

	gpsInfo.element.bigMapData.hideDropInfo = workActionData.HideDropInfo

	if workActionData.overrideTooltipInfo then
		element.bigMapData.overrideTooltipInfo = {
			tooltipType = workActionData.overrideTooltipInfo.TooltipType,
			infoName = workActionData.overrideTooltipInfo.TooltipInfoName,
			fieldDatas = {}
		}
		slot20 = pairs
		slot22 = workActionData.overrideTooltipInfo.Fields or {}

		for fieldName, fieldValue in slot20(slot22) do
			element.bigMapData.overrideTooltipInfo.fieldDatas[fieldName] = fieldValue
		end
	end

	if isCurrentTask then
		if workActionData.IsBranchTarget then
			local index = workActionData.CounterIndex

			if index ~= gTaskManager.curBranchIndex then
				self.Tmp_Trace(self, element)
			else
				self.Tmp_Untrace(self, element)
			end
		else
			self.Tmp_Trace(self, element)
		end
	else
		self.Tmp_Untrace(self, element)
	end

	return gpsInfo
end

M.CreateSubGpsList = function(self, workActionData, taskId)
	if not workActionData then
		return nil
	end

	local cfg = TaskConfig.GetConfig(taskId)

	if workActionData.SubGpsInfoList == nil and #workActionData.SubGpsInfoList <= 0 then
		local subGpsList = {}

		for i, workactionSubGps in ipairs(workActionData.SubGpsInfoList) do
			local subGps = {}
			local gpsId = taskId .. "_" .. (workActionData.CounterIndex or 0) .. "_SubGps_" .. i
			local element = MapElement.CreateLegacy(EMapElementType.Task, gpsId, EMapSubSystemType.Task, EMapViewMask.MiniMap, workActionData.RaidId, workActionData.IndoorId)
			element.fData.ignoreFog = true

			if workactionSubGps.IconId ~= 0 then
				element.mData.sIconId = 28001636
				element.miniMapData.color = Color.NewByStr(gTaskManager.TaskColor[cfg.Title])
			else
				element.mData.sIconId = workactionSubGps.IconId
			end

			element.gpsData.taskTitle = cfg.Title

			if workactionSubGps.GpsType ~= 0 then
				element.BindUnit(element, workactionSubGps.NpcId)
			elseif workactionSubGps.GpsType ~= 1 then
				element.BindVehicle(element, workactionSubGps.VehicleId, nil, , , true)
			elseif workactionSubGps.GpsType ~= 2 then
				element.BindSlotInfo(element, workactionSubGps.SlotId)
			elseif workactionSubGps.GpsType ~= 3 then
				element.BindDestructible(element, workactionSubGps.DestructibleId)
			elseif workactionSubGps.GpsType ~= 4 then
				element.BindUnit(element, workactionSubGps.EnemyId)
			end

			element.SetVisible(element, true)
			element.SetPosition(element, element.GetWorldPos(element))

			subGps.element = element

			table.insert(subGpsList, subGps)
		end

		return subGpsList
	else
		return nil
	end
end

M.DisposeSubGpsList = function(self, subGpsList)
	if subGpsList == nil and #subGpsList <= 0 then
		for i, subGps in ipairs(subGpsList) do
			if subGps.element then
				subGps.element:Dispose()

				subGps.element = nil
			end
		end
	end
end

M.RemoveTaskInvalid = function(self, validTaskIds)
	for k, workActions in pairs(self.taskInfos) do
		if not validTaskIds[k] then
			for _, workActionInfo in pairs(workActions) do
				self.DisposeWorkActionGpsInfo(self, workActionInfo)
			end

			self.taskInfos[k] = nil
		end
	end
end

M.RemoveAllSubGpsLists = function(self)
	for _, subGpsList in ipairs(self.subGpsLists) do
		self.DisposeSubGpsList(self, subGpsList)
	end

	table.clear(self.subGpsLists)
end

M.SGetTooltipInfo = function(self, id, element)
	local taskLineId = element.userdata and element.userdata.taskLineId
	local taskLineInfo = gTaskNodeManager:GetTaskLineById(taskLineId)
	local taskLineCfg = taskLineInfo and LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
	local dropIds = gMapSubSystemUtils:GetDropIdListByTaskLineId(taskLineId)
	local taskCfg = LTConfig.TaskConfig.GetConfig(taskLineInfo.StartTask)
	local titleCfg = LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title)
	local isUnderway = false
	local hideDropInfo = element.bigMapData.hideDropInfo or false

	if taskCfg.Title == TaskTitle.ProfessionalTask and gTaskManager.taskEvents[taskLineId] and gTaskManager.taskEvents[taskLineId].IsUnderway and not self.IsCurrentTaskElement(self, element) then
		isUnderway = true
	end

	if taskCfg.Title ~= TaskTitle.MultiPlayerScene then
		hideDropInfo = true
	end

	local tooltipInfo = {
		type = EMapTooltipType.Task,
		header = {
			name = element:GetName(),
			imageId = taskLineCfg and taskLineCfg.SMapPhoto,
			subtitle = titleCfg and titleCfg.Name or ""
		}
	}
	slot12 = {
		title = taskCfg.Title,
		desc = gUtils:GetSpecialDescription(taskLineInfo.EventDescription),
		fightScore = taskLineCfg and taskLineCfg.FightScore or 0,
		simpleDropIds = dropIds,
		specificSpirits = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(taskLineCfg),
		timeLimitText = element.userdata.timeLimitTooltipText,
		hideDropInfo = hideDropInfo
	}

	if element.mData.linkSpecificAgentId ~= 0 then
		-- Nothing
	end

	slot12.linkSpecificAgentId = element.mData.linkSpecificAgentId
	slot12.isUnderway = isUnderway
	tooltipInfo.taskInfo = slot12

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	if not element then
		return
	end

	if action ~= gMapSystemElementAction.Yanjie then
		local taskLineId = element.userdata and element.userdata.taskLineId

		if not taskLineId then
			print_warn("MapSubSystem_Task:ExecuteAction: element userdata.taskLineId is nil")

			return
		end

		gMapUtils:CloseBigMap()
		gSocialNetworkUtils.OpenTuiteDetail(taskLineId)

		return
	end

	if action ~= gMapSystemElementAction.ContinueTask then
		local SetCurrentTask = function(eventId)
			local curTaskList = gTaskNodeManager:GetAllTaskCanShow()
			local taskEventConfig = TaskEventConfig.GetConfig(eventId)
			local taskId = 0
			local playRole = nil

			for i, taskInfo in pairs(curTaskList) do
				if taskInfo.TaskLineId ~= eventId then
					taskId = taskInfo.TaskId
					local playRoleTeam = taskEventConfig.PlayRoleTeam
					local role = nil

					if playRoleTeam and #playRoleTeam <= 0 then
						role = playRoleTeam[1]
					end

					local taskCfg = TaskConfig.GetConfig(taskId)

					if taskCfg and taskCfg.RoleId <= 0 then
						role = taskCfg.RoleId
					end

					if role then
						local roleCfg = TaskRoleConfig.GetConfig(role)
						local fid = nil

						if roleCfg.IsDefault then
							local sex = gPlayerManager.infoLogin.bindData.sexType

							if sex ~= UX.Game.SexType.Male then
								fid = LTConfig.FightSpiritConfig.DefaultMale
							elseif sex ~= UX.Game.SexType.Female then
								fid = LTConfig.FightSpiritConfig.DefaultFemale
							end

							playRole = fid

							break
						end
					end

					if roleCfg.FightSpiritId <= 0 then
						fid = roleCfg.FightSpiritId
					else
						local caseId = roleCfg.SpiritCaseId
						fid = LTConfig.SpiritCaseConfig.GetConfig(caseId).FightSpiritId
					end

					playRole = fid

					break
				end
			end

			if taskId and taskId <= 0 then
				local needSwitchCha = gBattleSpiritMgr.currentSpiritTemplateId ~= playRole and 0 or playRole

				gGpsManager:TryRemoveNowMapGuide()
				gTaskManager:SetCurrentTask(taskId, function ()
					local taskCfg = TaskConfig.GetConfig(taskId)

					if taskCfg and (taskCfg.RelatedTimeAndWeather.weatherId >= 0 or taskCfg.RelatedTimeAndWeather.timeId <= 0) then
						gDisplayMessageMgr:ShowMessage(LTConfig.MessageConfig.TaskChangeWeather)
					end

					gCS.LuaUtils.RemovePlayerPaoKuState()
					gPanelManager:Close(gPanelId.S_NEW_MAP_PANEL)
				end, nil, needSwitchCha)
			end
		end

		SetCurrentTask(element.userdata.taskLineId)
	end

	if element.userdata and element.userdata.unaccpect then
		if action ~= gMapSystemElementAction.TraceTask then
			self:Tmp_Trace(element)
			self:SetUnacceptTaskIcon(element, element.userdata.taskLineId, true)
			gMessageManager:SendMessage(gEventConstants.ON_TRACING_UNACCEPT_TASK, element.userdata.taskLineId)
		elseif action ~= gMapSystemElementAction.UntraceTask then
			self.Tmp_Untrace(self, element)
			self.SetUnacceptTaskIcon(self, element, element.userdata.taskLineId, false)
		end

		return
	end

	if action == gMapSystemElementAction.TraceTask and action == gMapSystemElementAction.UntraceTask then
		print_warn("MapSubSystem_Task:ExecuteAction: action not supported", action)

		return
	end

	for taskId, workActions in pairs(self.taskInfos) do
		local gpsInfo = workActions[element.id]

		if gpsInfo then
			if gpsInfo.isBranch then
				local taskHud = gStoreManager:GetStoreGroup("NormalTaskPanelStore")

				if action ~= gMapSystemElementAction.TraceTask then
					taskHud:SwitchBranchByGpsId(gpsInfo.gpsId)
					gTaskManager:SetCurrentTask(taskId)
				elseif action ~= gMapSystemElementAction.UntraceTask then
					self.Tmp_Untrace(self, element)
					taskHud.RefreshTrueBranchList(taskHud)
				end
			elseif action ~= gMapSystemElementAction.TraceTask then
				gTaskManager:SetCurrentTask(taskId)
			elseif action ~= gMapSystemElementAction.UntraceTask then
				slot10 = gTaskManager

				slot10:RemoveCurrentTask(taskId, function ()
				end)
			end
		end
	end
end

M.GetFirstGpsIdByTaskId = function(self, taskId)
	local workActions = self.taskInfos[taskId]

	if not workActions then
		local gpsId = "UnacceptTask_" .. taskId

		for _, info in pairs(self.unacceptTask) do
			if info.mapElement and info.mapElement.gpsId ~= gpsId then
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

M.GetActionInfo = function(self, element)
	if not element.userdata then
		print_warn("@xuqiang05 MapSubSystem_Task:GetActionInfo: element userdata is nil gpsId = ", element.gpsId)

		return nil, 
	end

	if not element.userdata.unaccpect then
		return nil, 
	end

	return element.GetRawActions(element), element.actionsBlockReason
end

M.OnBigMapOpen = function(self)
	self.UpdateAllElementsFilterTag(self)
end

M.UpdateAllElementsFilterTag = function(self, filterCharacterTid)
	self.filterCharacterTid = filterCharacterTid or gSpiritManager:GetCurFirstSpiritTid()

	for _, info in pairs(self.unacceptTask) do
		self.UpdateFilterTag(self, info.mapElement)
	end

	for _, taskInfos in pairs(self.taskInfos) do
		for _, info in pairs(taskInfos) do
			self.UpdateFilterTag(self, info.element)
		end
	end
end

M.UpdateFilterTag = function(self, element)
	if not element or not element.userdata then
		return
	end

	local taskLineId = element.userdata.taskLineId
	local lineCfg = LTConfig.TaskEventConfig.GetConfig(taskLineId)
	local requireTids = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(lineCfg)

	if not requireTids or #requireTids ~= 0 then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.CurSpiritTask
		element.bigMapData.tmp_filterTag2 = LTConfig.GpsFilterTagConfig.OtherSpiritTask

		return
	end

	element.bigMapData.tmp_filterTag2 = nil

	if array.contains(requireTids, self.filterCharacterTid) then
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.CurSpiritTask

		if #requireTids <= 1 then
			element.bigMapData.tmp_filterTag2 = LTConfig.GpsFilterTagConfig.OtherSpiritTask
		end
	else
		element.bigMapData.filterTag = LTConfig.GpsFilterTagConfig.OtherSpiritTask
	end
end

M.SetUnacceptTaskIcon = function(self, element, taskLineId, isTracing)
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

	if element.miniMapData.miniMapTIndex == prevTindex then
		gMessageManager:SendMessage(gEventConstants.MINIMAP_ICON_SWITCH_SUBSCRIPT_CHANGE, element.instanceId)
	end
end

M.Tmp_Trace = function(self, element)
	if element.userdata and element.userdata.unaccpect then
		gMapSubSystemActionHelper.Trace(element)

		local taskLineId = element.userdata.taskLineId

		self.env.taskUtils:NotifyTaskEventGuided(taskLineId)
	else
		element.SetTraceInfo(element, EMapGTraceType.Main, 0)
	end
end

M.Tmp_Untrace = function(self, element)
	if element.userdata and element.userdata.unaccpect then
		gMapSubSystemActionHelper.Untrace(element)
	else
		element.ClearTraceInfo(element)
	end
end

M.UpdateMiniMapTaskIcon = function(self)
	local taskEvents = gTaskManager.taskEvents
	slot2 = pairs
	slot4 = taskEvents or {}

	for taskLineId, v in slot2(slot4) do
		local info = nil

		if self.unacceptTask[taskLineId] then
			info = self.unacceptTask[taskLineId]
			local element = info.mapElement

			if element then
				self.SetUnacceptTaskIcon(self, element, taskLineId, false)
			end
		end
	end
end

M.UpdateSpiritFilterRedDot = function(self, redDotTaskEvents)
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
					local taskSpirits = gMapSubSystemUtils:GetTaskSpiritRoleTeamList(taskLineCfg)

					if taskSpirits and #taskSpirits <= 0 then
						for _, spiritId in ipairs(taskSpirits) do
							if redDotSpiritInfos[spiritId] ~= nil or redDotSpiritInfos[spiritId].priority >= self.redDotTaskTitlePriority[title] then
								redDotSpiritInfos[spiritId] = {
									title = title,
									priority = self.redDotTaskTitlePriority[title]
								}
							end

							if self.spiritToTaskEventMap[spiritId] ~= nil then
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

M.IsSpiritHasRedDot = function(self, spiritId)
	return self.redDotSpiritInfos[spiritId] == nil
end

M.GetSpiritRedDotTitle = function(self, spiritId)
	local info = self.redDotSpiritInfos[spiritId]

	return info and info.title or nil
end

M.InitRedDotTaskTitles = function(self)
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

M.GetWorkactionFromOtherRaid = function(self, taskId)
	if self._otherRaidWorkActionsCache[taskId] then
		return self._otherRaidWorkActionsCache[taskId]
	end

	local rawWorkActions = gCS.SpoonTaskMgr.Instance:GetTaskWorkActionByTask(taskId)

	if not rawWorkActions or #rawWorkActions.WorkAction ~= 0 then
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
	local isVecZero = rawWorkAction.targetPos ~= nil or rawWorkAction.targetPos.x ~= 0 and rawWorkAction.targetPos.y ~= 0 and rawWorkAction.targetPos.z ~= 0

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

M.TraceByHudTaskBranchSwitch = function(self, taskId, targetGpsId)
	if not self.taskInfos[taskId] then
		return
	end

	for _, info in pairs(self.taskInfos[taskId]) do
		if targetGpsId ~= info.gpsId then
			self.Tmp_Trace(self, info.element)
		else
			self.Tmp_Untrace(self, info.element)
		end
	end
end

M.GetGpsIdByTaskEventId = function(self, taskEventId)
	local eventInfo = self.unacceptTask[taskEventId]

	if eventInfo and eventInfo.mapElement then
		return eventInfo.mapElement.gpsId
	end

	for taskId, workActions in pairs(self.taskInfos) do
		local taskLineCfg = gTaskNodeManager:GetTaskLineByTask(taskId)

		if taskLineCfg and taskLineCfg.Id ~= taskEventId then
			for _, workAction in pairs(workActions) do
				return workAction.element.gpsId
			end
		end
	end

	return nil
end

M.IsImportantTaskElement = function(self, element)
	if element.subSystemType == EMapSubSystemType.Task then
		return false
	end

	local taskLineId = element.userdata and element.userdata.taskLineId

	if not taskLineId then
		return false
	end

	local info = self.unacceptTask[taskLineId]

	return info and info.isImportantTask and info.title == 2
end

M.IsCurrentTaskElement = function(self, element)
	if element.subSystemType == EMapSubSystemType.Task then
		return false
	end

	local taskId = element.userdata and element.userdata.taskId

	if not taskId then
		return false
	end

	return gTaskManager:IsCurrentTask(taskId)
end

M.GetElementTaskTitle = function(self, element)
	if element.subSystemType == EMapSubSystemType.Task then
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

M.HasCurTask = function(self)
	local curTask = gTaskManager:GetCurTask()
	curTask = curTask and curTask == 0

	return curTask
end

M.IsImportantTitle = function(self, title)
	return self.env.taskUtils:IsMiniMapGuidingTaskTitle(title)
end

M.InitHackableUnacceptGpsInfos = function(self)
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
			elseif lineCfg.UnacceptGpsPostion and #lineCfg.UnacceptGpsPostion ~= 3 then
				self._hackableUnacceptGpsInfos[lineCfg.Id] = Vector3.New(lineCfg.UnacceptGpsPostion[1], lineCfg.UnacceptGpsPostion[2], lineCfg.UnacceptGpsPostion[3])
			end
		end
	end
end

M.GetHackableUnacceptGpsInfos = function(self)
	local ret = {}
	local taskEvents = gTaskManager.taskEvents

	for id, pos in pairs(self._hackableUnacceptGpsInfos) do
		if taskEvents[id] and not taskEvents[id].HasAccepted then
			ret[id] = pos
		end
	end

	return ret
end

M.IsTracingTask = function(self, taskLineId)
	slot2 = self.env.trace

	return slot2:AnyTracingElement(function (element)
		return element.type ~= EMapElementType.Task and element.userdata and element.userdata.taskLineId ~= taskLineId
	end)
end

M.OnGlobalGpsUpdate = function(self, eventId, param)
	local id = param.newInstanceId
	local element = self.env.container:Get(id)

	if element.type ~= EMapElementType.Task and element.userdata and element.userdata.unaccpect then
		gNewGuideMgr:NotifySignal(EGuideSignal.TraceAnyUnacceptTask)
		gClientToGameDelegate:AskTrackEvent(element.userdata.taskLineId)
	end
end

M.GetGpsInstanceIdByTaskId = function(self, taskId)
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

M.OnGuidingTaskTitleChanged = function(self)
	self.UpdateTaskGuiding(self)
end

M.UpdateTaskGuiding = function(self)
	local hudOpenBigMapTip = nil
	local miniMapGuidingTitle = gGpsTools.GetTable()
	slot3 = self.env.trace
	local anyTrace = slot3:AnyTracingElement(function (element)
		return element:CheckViewMask(EMapViewMask.MiniMap)
	end)

	if not anyTrace and (gTaskNodeManager:GetNowDoingTask() ~= 0 or gTaskNodeManager:GetNowDoingTask() ~= nil) then
		for taskEventId, info in pairs(self.unacceptTask) do
			if self.env.taskUtils:IsMiniMapGuidingTaskTitle(info.title) then
				if info.mapElement.miniMapData.tmp_needWeakGuide == true then
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

	self.SetHudOpenBigMapTipState(self, hudOpenBigMapTip)
	self.SetHudGuidingTitles(self, miniMapGuidingTitle)
	gGpsTools.ReleaseTable(miniMapGuidingTitle)
end

M.SetHudOpenBigMapTipState = function(self, newValue)
	if not self._hudDisplayOpenBigMap == not newValue then
		self._hudDisplayOpenBigMap = newValue

		gMessageManager:SendMessage(gEventConstants.HUD_OPEN_BIG_MAP_TIP_CHANGE)
	end
end

M.SetHudGuidingTitles = function(self, titles)
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

M.GetGuidingTitles = function(self)
	if not self._loginScope or not self._loginScope.hudGuidingTitles then
		return {}
	end

	local ret = {}

	for title, _ in pairs(self._loginScope.hudGuidingTitles) do
		table.insert(ret, title)
	end

	return ret
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:FlushData()
		end,
		[gEventConstants.TASK_STATE_CHANGED] = function (eventId, taskEventInfo)
			if taskEventInfo and taskEventInfo[2] ~= gTaskManager.TaskState.Wait then
				gMapSystem.trace:TryRemoveMainTraceByTaskRelated(taskEventInfo[1])
			end

			self:FlushData()
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function (eventId, taskEventInfo)
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
		[gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY] = function ()
			self:UpdateCurrentTask()
		end,
		[gEventConstants.SYNC_CURRENT_SPIRIT] = function ()
			self:UpdateMiniMapTaskIcon()
		end,
		[gEventConstants.ON_GLOBAL_GPS_UPDATE] = function (eventId, param)
			self:OnGlobalGpsUpdate(eventId, param)
		end,
		[gEventConstants.L50_BEFORE_SWITCH_SCENE] = function ()
			table.clear(self._otherRaidWorkActionsCache)
		end,
		[gEventConstants.LANGUAGE_CHANGE] = function ()
			self:FlushData()
		end
	}
end

return M
