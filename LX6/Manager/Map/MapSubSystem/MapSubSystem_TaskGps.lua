-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_TaskGps.lua
-- Decompiled from: 02342_MapSubSystem_TaskGps.lua_99211224974e.luajit

local TaskTitle = require("LX6/Manager/Task/TaskTitle")
MapSubSystem_TaskGps = DefClass("MapSubSystem_TaskGps", MapSubSystem_TaskGps, MapSubSystemBase)
local M = MapSubSystem_TaskGps

local CopyTaskInteractTargetInfo = function(source, targetInfo)
	if not source then
		return nil
	end

	local copiedTargetInfo = {
		bindType = source.bindType,
		targetId = source.targetId
	}

	if targetInfo and targetInfo.DestructibleInstanceId then
		copiedTargetInfo.targetId = targetInfo.DestructibleInstanceId
	end

	return copiedTargetInfo
end

M.OnInit = function(self)
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

M.AddDynamicGpsElement = function(self, gpsGroupId, unitInfo, params)
	local created = false

	if self.gpsInfos[gpsGroupId] and params.dontRepeatCreate then
		created = true
	else
		self.DeleteGpsElement(self, gpsGroupId)

		self.gpsInfos[gpsGroupId] = {}
	end

	local gpsInfo = nil

	if created then
		gpsInfo = self.gpsInfos[gpsGroupId][1]
	else
		gpsInfo = {}
		self.gpsInfos[gpsGroupId][1] = gpsInfo
	end

	gpsInfo.enable = true

	self.CreateGenericSpoonElement(self, gpsGroupId, params, gpsInfo)

	if unitInfo.unitPid then
		gpsInfo.element:BindUnit(unitInfo.unitPid)
	elseif unitInfo.vehicleUnitId then
		gpsInfo.element:BindVehicle(unitInfo.vehicleUnitId, unitInfo.vehiclePartNodeName, nil, , true)
	elseif unitInfo.slotId then
		gpsInfo.element:BindSlotInfo(unitInfo.slotId, unitInfo.refId)
	end

	self.SetupTaskInteractTargetInfo(self, gpsInfo.element, params)

	if not created then
		self.AfterGpsInfoCreated(self, gpsInfo, params)
	end
end

M.AddMultiGpsElement = function(self, gpsGroupId, targetList, params)
	local created = false

	if self.gpsInfos[gpsGroupId] and params.dontRepeatCreate then
		created = true
	else
		self.DeleteGpsElement(self, gpsGroupId)

		self.gpsInfos[gpsGroupId] = {}
	end

	for i = 1, #targetList do
		local worldPos = targetList[i].TargetPos
		local gpsId = gpsGroupId .. (targetList[i].CounterIndex or i)

		if params.cargoGpsLTexts == nil then
			params.gpsLText = params.cargoGpsLTexts[i]
		end

		local gpsInfo = nil

		if created then
			gpsInfo = self.gpsInfos[gpsGroupId][i]
		else
			gpsInfo = {}
			self.gpsInfos[gpsGroupId][i] = gpsInfo
		end

		gpsInfo.enable = true
		gpsInfo.worldPos = worldPos

		self.CreateGenericSpoonElement(self, gpsId, params, gpsInfo)

		if targetList[i].DestructibleInstanceId then
			gpsInfo.element:BindDestructible(targetList[i].DestructibleInstanceId)
		end

		self.SetupTaskInteractTargetInfo(self, gpsInfo.element, params, targetList[i])

		if not created then
			self.AfterGpsInfoCreated(self, gpsInfo, params)
		end
	end
end

M.AddGpsElement = function(self, gpsGroupId, worldPos, params)
	local created = false

	if self.gpsInfos[gpsGroupId] and params.dontRepeatCreate then
		created = true
	else
		self.DeleteGpsElement(self, gpsGroupId)

		self.gpsInfos[gpsGroupId] = {}
	end

	local gpsInfo = nil

	if created then
		gpsInfo = self.gpsInfos[gpsGroupId][1]
	else
		gpsInfo = {}
		self.gpsInfos[gpsGroupId][1] = gpsInfo
	end

	gpsInfo.enable = true
	gpsInfo.worldPos = worldPos

	self.CreateGenericSpoonElement(self, gpsGroupId, params, gpsInfo)
	self.SetupTaskInteractTargetInfo(self, gpsInfo.element, params)

	if not created then
		self.AfterGpsInfoCreated(self, gpsInfo, params)
	end
end

M.SetupTaskInteractTargetInfo = function(self, element, params, targetInfo)
	if not element then
		return
	end

	local targetSource = targetInfo and targetInfo.taskInteractTargetInfo or params and params.taskInteractTargetInfo
	element.gpsData.taskInteractTargetInfo = CopyTaskInteractTargetInfo(targetSource, targetInfo)
	local hudGpsStore = gStoreManager and gStoreManager:GetStoreGroup("HudGpsPanelStore")

	if hudGpsStore and hudGpsStore.OnTaskInteractTargetInfoChange then
		hudGpsStore.OnTaskInteractTargetInfoChange(hudGpsStore, element.instanceId)
	end
end

M.CreateGenericSpoonElement = function(self, gpsId, params, gpsInfo)
	gpsInfo.gpsId = gpsId
	gpsInfo.tooltipImageId = params.tooltipImageId
	gpsInfo.tooltipDesc = params.tooltipDesc
	gpsInfo.tooltipLText = params.tooltipLText
	gpsInfo.taskId = params.taskId
	gpsInfo.defaultHideUtilScan = params.defaultHideUtilScan
	gpsInfo.durationWhenScan = params.durationWhenScan
	local viewMask = EMapViewMask.MiniMap + EMapViewMask.HudGps + EMapViewMask.FocusMode

	if params.visibleOnBigMap then
		viewMask = viewMask + EMapViewMask.BigMap
	end

	if params.hideInHUD then
		viewMask = viewMask - EMapViewMask.HudGps
	end

	local element = gpsInfo.element

	if not element then
		element = MapElement.CreateLegacy(EMapElementType.TaskGps, gpsId, EMapSubSystemType.TaskGps, viewMask, gRaidDataManager.RaidId)
		gpsInfo.element = element
	else
		element.SetViewMask(element, viewMask)
		element.SetRaidId(element, gRaidDataManager.RaidId)
	end

	element.gpsData.disableVehicleNav = not params.showVehicleNav or nil
	element.gpsData.relocatePosByNav = params.relocatedByVehicleNav or nil
	element.gpsData.preferMainRoadNavigation = params.preferMainRoadNavigation or false
	element.gpsData.hudDistRiseUp = params.hudDistRiseUp or false
	element.gpsData.hudDistRiseFactor = params.hudDistRiseFactor or nil
	element.bigMapData.unselectable = params.unselectable or nil
	element.miniMapData.color = params.color or nil
	element.mData.ignoreIndoorPenetration = params.ignoreIndoorPenetration or false

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

	if params.range and params.range <= 0 then
		element.mData.rangeInfo = {
			radius = params.range,
			color = Color.NewByStr(gTaskManager.TaskColor[cfg.Title])
		}
	end

	if params.hideGpsRange and params.hideGpsRange == 0 then
		local hideGpsRange = params.hideGpsRange

		if hideGpsRange >= 0 then
			element.gpsData.tmp_HudAutoShowDistance = -hideGpsRange
		else
			element.gpsData.tmp_HudAutoHideDistance = hideGpsRange
		end
	end

	if cfg.Title ~= TaskTitle.ProfessionalTask or cfg.Title ~= TaskTitle.MultiPlayerScene then
		element.SetActions(element, self.ProfessionalActions)
	else
		element.SetActions(element, self.Actions)
	end

	return element
end

M.AfterGpsInfoCreated = function(self, gpsInfo, params)
	if not GpsHelper.TryRegisterGpsHandler(gpsInfo) then
		gpsInfo.enable = true

		gpsInfo.element:SetPosition(gpsInfo.worldPos)
		gpsInfo.element:SetVisible(true)

		if not params.dontTrace then
			gpsInfo.element:SetTraceInfo(EMapGTraceType.Main, 0)
		end
	else
		gpsInfo.enable = false
	end
end

M.DeleteGpsElement = function(self, groupId)
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

M.SGetTooltipInfo = function(self, id, element)
	local targetGpsInfo = nil

	for _, gpsList in pairs(self.gpsInfos) do
		for _, gpsInfo in ipairs(gpsList) do
			if gpsInfo.element ~= element then
				targetGpsInfo = gpsInfo
			end
		end
	end

	local taskLineInfo = gTaskNodeManager:GetTaskLineByTask(targetGpsInfo.taskId)
	local taskLineCfg = taskLineInfo and LTConfig.TaskEventConfig.GetConfig(taskLineInfo.TaskLineId)
	local imageId = targetGpsInfo.tooltipImageId

	if not imageId or imageId ~= 0 then
		imageId = taskLineCfg and taskLineCfg.SMapPhoto or 0
	end

	local desc = targetGpsInfo.tooltipDesc

	if targetGpsInfo.tooltipLText then
		local dynamicDesc = targetGpsInfo.tooltipLText:GetText()

		if not string.is_null_or_empty(dynamicDesc) then
			desc = dynamicDesc
		end
	end

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
			desc = desc,
			fightScore = taskLineCfg and taskLineCfg.FightScore or 0
		}
	}

	return tooltipInfo
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Trace then
		element.SetTraceInfo(element, EMapGTraceType.Main, 0)
	elseif action ~= gMapSystemElementAction.Untrace then
		element.ClearTraceInfo(element)
	end
end

return M
