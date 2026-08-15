local TaskTitle = require("LX6/Manager/Task/TaskTitle")
MapSubSystem_TaskGps = DefClass("MapSubSystem_TaskGps", MapSubSystem_TaskGps, MapSubSystemBase)
local M = MapSubSystem_TaskGps

function M:OnInit()
	self.gpsInfos = {}
	self.Actions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.Trace
		},
		[gMapSystem_Element_State.Tracing] = {
			gMapSystemElementAction.Untrace
		}
	}
	self.ProfessionalActions = {
		[gMapSystem_Element_State.Normal] = {
			gMapSystemElementAction.TraceTask
		},
		[gMapSystem_Element_State.Tracing] = {}
	}
end

function M:AddDynamicGpsElement(instanceId, unitInfo, params)
	if not self.gpsInfos[instanceId] then
		self.gpsInfos[instanceId] = {}
	end

	local element = self:CreateGenericSpoonElement(instanceId, params)
	local gpsInfo = {
		enable = true,
		gpsId = instanceId,
		tooltipImageId = params.tooltipImageId,
		tooltipDesc = params.tooltipDesc,
		element = element,
		taskId = params.taskId,
		defaultHideUtilScan = params.defaultHideUtilScan,
		durationWhenScan = params.durationWhenScan
	}

	if not params.dontTrace then
		gpsInfo.defaultTrace = true
		gpsInfo.traceType = EMapGTraceType.Main
	end

	table.insert(self.gpsInfos[instanceId], gpsInfo)

	if unitInfo.unitPid then
		element:BindUnit(unitInfo.unitPid)
	elseif unitInfo.vehicleUnitId then
		element:BindVehicle(unitInfo.vehicleUnitId, unitInfo.vehiclePartNodeName, nil, nil, true)
	elseif unitInfo.slotId then
		element:BindSlotInfo(unitInfo.slotId, unitInfo.refId)
	end

	if not GpsHelper.TryRegisterGpsHandler(gpsInfo) then
		gpsInfo.enable = true

		element:SetVisible(true)

		if not params.dontTrace then
			element:SetTraceInfo(EMapGTraceType.Main, 0)
		end
	else
		gpsInfo.enable = false
	end
end

function M:AddMultiGpsElement(groupId, targetList, params)
	if not self.gpsInfos[groupId] then
		self.gpsInfos[groupId] = {}
	end

	for i = 1, #targetList do
		local worldPos = targetList[i].TargetPos
		local instanceId = groupId .. (targetList[i].CounterIndex or i)

		if params.cargoGpsLTexts ~= nil then
			params.gpsLText = params.cargoGpsLTexts[i]
		end

		local element = self:CreateGenericSpoonElement(instanceId, params)
		local gpsInfo = {
			enable = true,
			gpsId = instanceId,
			tooltipImageId = params.tooltipImageId,
			tooltipDesc = params.tooltipDesc,
			element = element,
			worldPos = worldPos,
			taskId = params.taskId,
			defaultHideUtilScan = params.defaultHideUtilScan,
			durationWhenScan = params.durationWhenScan
		}

		if not params.dontTrace then
			gpsInfo.defaultTrace = true
			gpsInfo.traceType = EMapGTraceType.Main
		end

		if targetList[i].DestructibleInstanceId then
			element:BindDestructible(targetList[i].DestructibleInstanceId)
		end

		table.insert(self.gpsInfos[groupId], gpsInfo)

		if not GpsHelper.TryRegisterGpsHandler(gpsInfo) then
			gpsInfo.enable = true

			element:SetPosition(worldPos)
			element:SetVisible(true)

			if not params.dontTrace then
				element:SetTraceInfo(EMapGTraceType.Main, 0)
			end
		else
			gpsInfo.enable = false
		end
	end
end

function M:AddGpsElement(instanceId, worldPos, params)
	if not self.gpsInfos[instanceId] then
		self.gpsInfos[instanceId] = {}
	end

	local element = self:CreateGenericSpoonElement(instanceId, params)
	local gpsInfo = {
		enable = true,
		gpsId = instanceId,
		tooltipImageId = params.tooltipImageId,
		tooltipDesc = params.tooltipDesc,
		element = element,
		worldPos = worldPos,
		taskId = params.taskId,
		defaultHideUtilScan = params.defaultHideUtilScan,
		durationWhenScan = params.durationWhenScan
	}

	if not params.dontTrace then
		gpsInfo.defaultTrace = true
		gpsInfo.traceType = EMapGTraceType.Main
	end

	table.insert(self.gpsInfos[instanceId], gpsInfo)

	if not GpsHelper.TryRegisterGpsHandler(gpsInfo) then
		gpsInfo.enable = true

		element:SetPosition(worldPos)
		element:SetVisible(true)

		if not params.dontTrace then
			element:SetTraceInfo(EMapGTraceType.Main, 0)
		end
	else
		gpsInfo.enable = false
	end

	return element
end

function M:CreateGenericSpoonElement(instanceId, params)
	local viewMask = EMapViewMask.MiniMap + EMapViewMask.HudGps + EMapViewMask.FocusMode

	if params.visibleOnBigMap then
		viewMask = viewMask + EMapViewMask.BigMap
	end

	if params.hideInHUD then
		viewMask = viewMask - EMapViewMask.HudGps
	end

	local element = MapElement.CreateLegacy(EMapElementType.TaskGps, instanceId, EMapSubSystemType.TaskGps, viewMask, gRaidDataManager.RaidId)
	element.gpsData.disableVehicleNav = not params.showVehicleNav or nil
	element.gpsData.relocatePosByNav = params.relocatedByVehicleNav or nil
	element.bigMapData.unselectable = params.unselectable or nil
	element.miniMapData.color = params.color or nil
	element.gpsData.ignoreIndoorPenetration = params.ignoreIndoorPenetration or false

	if params.hudTIndex then
		element.fData.hudTIndex = params.hudTIndex
	end

	if params.isProgress then
		element.fData.hudTIndex = 5
		element.gpsData.progressData = {
			progressFinishIconId = params.progressFinishIconId,
			progressNormalIconId = params.progressNormalIconId,
			progressId = params.progressId
		}
	end

	if params.gpsLText then
		element.mData.lName = params.gpsLText
	else
		element.mData.name = params.gpsName
	end

	element.mData.sIconId = params.sIconId
	local cfg = gTaskManager:GetTaskConfigInfo(params.taskId)

	if cfg.Title == TaskTitle.ProfessionalTask then
		element:SetActions(self.ProfessionalActions)
	else
		element:SetActions(self.Actions)
	end

	return element
end

function M:DeleteGpsElement(groupId)
	local gpsGroup = self.gpsInfos[groupId]

	if not gpsGroup then
		return
	end

	for _, gpsInfo in ipairs(gpsGroup) do
		gpsInfo.element:Dispose()
		GpsHelper.UnregisterGpsHandler(gpsInfo.gpsId)
	end

	self.gpsInfos[groupId] = nil
end

function M:SGetTooltipInfo(id, element)
	local targetGpsInfo = nil

	for _, gpsList in pairs(self.gpsInfos) do
		for _, gpsInfo in ipairs(gpsList) do
			if gpsInfo.element == element then
				targetGpsInfo = gpsInfo
			end
		end
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(targetGpsInfo.taskId)
	local imageId = targetGpsInfo.tooltipImageId

	if not imageId or imageId == 0 then
		local taskLineCfg = taskLineInfo and LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
		imageId = taskLineCfg and taskLineCfg.SMapPhoto or 0
	end

	local desc = targetGpsInfo.tooltipDesc

	if not desc or string.is_null_or_empty(desc) then
		desc = taskLineInfo and gUtils:GetSpecialDescription(taskLineInfo.EventDescription) or ""
	end

	local taskCfg = LTConfig.TaskConfig.GetConfig(taskLineInfo.StartTask)
	local titleCfg = taskCfg and LTConfig.TaskTitleConfig.GetConfig(taskCfg.Title) or nil
	local tooltipInfo = {
		type = EMapTooltipType.Task,
		header = {
			name = element:GetName(),
			imageId = imageId,
			subtitle = titleCfg and titleCfg.Name or ""
		},
		taskInfo = {
			title = taskCfg.Title,
			desc = desc
		}
	}

	return tooltipInfo
end

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.Trace then
		element:SetTraceInfo(EMapGTraceType.Main, 0)
	elseif action == gMapSystemElementAction.Untrace then
		element:ClearTraceInfo()
	end
end

return M
