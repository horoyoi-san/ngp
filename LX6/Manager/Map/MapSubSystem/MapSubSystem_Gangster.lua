-- Original chunk: @Lua\LuaFiles\LX6\Manager\Map\MapSubSystem\MapSubSystem_Gangster.lua
-- Decompiled from: 02330_MapSubSystem_Gangster.lua_a62233afc2d3.luajit

require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaHelper")
require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaClientState")

local FactionConfig = LTConfig.FactionConfig
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local InfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local MessageConfig = LTConfig.MessageConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local Vector3 = Vector3
local MY_GANGSTER = FactionConfig.JiaMuFaction
MapSubSystem_Gangster = DefClass("MapSubSystem_Gangster", MapSubSystem_Gangster, MapSubSystemBase)
local M = MapSubSystem_Gangster
local EGangsterEventType = {
	["q[ک\\x88\r\\x9b\\xc4\\xf8"] = 2,
	["\\xad5.;w\\x90d\\xcf2\\xa4\\xad"] = 5,
	["h\\xa2\\xab\\xbb\\xb3"] = 4,
	["!\\xecQ=\\xd5\\xb3E\\x82W\\xbd\\xa6"] = 3,
	["?M\\x9f\\x9a\\x86S"] = 1
}

M.OnInit = function(self)
	self.InitType2Icon(self)

	self._tracingGangsterPrediction = function(element)
		return element.subSystemType ~= EMapSubSystemType.Gangster
	end

	self.gangsterInfluenceEventsMap = {}
	self.battleCampTaskCounterMap = {}
	self.battleCampScannedTaskIds = {}
	self.factionInfluenceClientState = GangsterAreaClientState.New()
end

M.InitEventHandlers = function(self)
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:FlushData("CurrentTaskChange")
		end,
		[gEventConstants.TASK_STATE_CHANGED] = function (_, taskInfo)
			local taskId = taskInfo and taskInfo[1]

			if taskId then
				self:CacheBattleCampTaskCounters(taskId, taskInfo[2])
			end

			self:FlushData("TaskStateChanged")
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			self:FlushData("TaskEventChange")
		end,
		[gEventConstants.ON_EVENT_STATE_CHANGE] = function (_, eventData)
			local state = eventData and eventData.state

			if state ~= UX.Game.TaskEventState.Locked or state ~= UX.Game.TaskEventState.Submited then
				self.factionInfluenceClientState:RemoveCounterAttackEvent(eventData.eventId)
			end

			self:FlushData("EventStateChange")
		end,
		[gEventConstants.CHANGE_MY_UNIT] = function (eventId, pid)
			for _, v in pairs(self.influenceEventElements) do
				local info = v

				info.element:ClearTraceInfo()
			end
		end
	}
end

M.InitType2Icon = function(self)
	self._type2IconDict = {}
	local pics = FactionConfig.EventPic

	for _, p in ipairs(pics) do
		self._type2IconDict[p.EventType] = p.SguiId
	end
end

M.OnLogin = function(self)
	self:InitEventHandlers()
	self:FlushData("Init")
	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	if self.helper then
		self.helper:Clear()
	end

	local achievementData = gPlayerManager.infoAchievement and gPlayerManager.infoAchievement.bindData

	self.factionInfluenceClientState:ApplyClientFactionInfo(achievementData and achievementData.ClientFactionInfo, achievementData and achievementData.OccupiedInfluenceArea)

	self.helper = GangsterAreaHelper.New()

	self.helper:OnLogin(self.factionInfluenceClientState)
	self:RefreshInfluenceEventOwners()
end

M.OnLogout = function(self)
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	self.battleCampTaskCounterMap = {}
	self.battleCampScannedTaskIds = {}

	if self.helper then
		self.helper:Clear()

		self.helper = nil
	end

	self.factionInfluenceClientState:ApplyClientFactionInfo(nil)
end

M.OnLoadData = function(self)
	if self.influenceEventElements then
		for _, info in pairs(self.influenceEventElements) do
			info.element:Dispose()
		end
	end

	self.battleCampTaskCounterMap = {}
	self.battleCampScannedTaskIds = {}
	self.gangsters = {}

	for i = 0, FactionConfig.count - 1 do
		local factionCfg = FactionConfig.LoadAt(i)
		local id = factionCfg.Id

		if factionCfg.BaseCampLocation then
			if #factionCfg.BaseCampLocation >= 0 then
				local info = {
					id = id,
					influenceEventIds = {},
					displayConfigByType = {}
				}
				self.gangsters[id] = info
			end
		end
	end

	self.BuildInfluenceEventDisplayConfigs(self)

	self.influenceEventElements = {}

	for i = 0, InfluenceEventConfig.count - 1 do
		local cfg = InfluenceEventConfig.LoadAt(i)
		local id = cfg.Id
		local relatedId = cfg.RelatedEventId
		local gangsterId = self.GetCurrentInfluenceEventGangsterId(self, id)

		if cfg.Type ~= EGangsterEventType.RandomEvent or cfg.Type ~= EGangsterEventType.BattleCamp then
			local gpsId = "InfluenceEvent_" .. id
			local element = MapElement.CreateLegacy(EMapElementType.Gangster, gpsId, EMapSubSystemType.Gangster, EMapViewMask.Gangster + EMapViewMask.HudGps, 23300888)
			element.fData.ignoreFog = false
			element.mData.lName = GpsLText.CreateCommonText(cfg, "Name", cfg.Name)
			element.mData.sIconId = self._type2IconDict[cfg.Type] or 0
			element.userdata = {
				gangsterId = gangsterId,
				influenceId = id,
				relatedId = relatedId,
				type = cfg.Type
			}
			element.gpsData.removeGpsRange = cfg.RemoveGpsRadius

			element:SetPosition(self:GetTaskEventPosition(relatedId))
			element:SetVisible(false)
			element:SetActions(self.NormalTraceableActions)

			if cfg.Type ~= EGangsterEventType.RandomEvent then
				gMapSubSystemUtils:SetupScaleLevel(element, 2, 28001287)
			else
				gMapSubSystemUtils:SetupScaleLevel(element, 2, nil)
			end

			local info = {
				gangsterId = gangsterId,
				influenceId = id,
				element = element
			}
			self.influenceEventElements[id] = info
		end
	end

	for taskId, taskInfo in pairs(gTaskManager.tasks) do
		self.CacheBattleCampTaskCounters(self, taskId, taskInfo.State)
	end

	for taskId in pairs(gTaskManager.submitTasks) do
		self.CacheBattleCampTaskCounters(self, taskId, UX.Game.TaskState.Submited)
	end

	self.RefreshInfluenceEventOwners(self)
	self.FlushData(self)
end

M.CacheBattleCampTaskCounters = function(self, taskId, taskState)
	if self.battleCampScannedTaskIds[taskId] then
		return
	end

	if taskState == UX.Game.TaskState.Accepted and taskState == UX.Game.TaskState.Submited then
		return
	end

	local workActions = gTaskNodeManager:GetTaskWorkAction(taskId)

	if #workActions ~= 0 then
		return
	end

	self.battleCampScannedTaskIds[taskId] = true

	for _, workAction in ipairs(workActions) do
		local tooltipInfo = workAction.OverrideTooltipInfo

		if tooltipInfo then
			if tooltipInfo.TooltipInfoName == "gangsterSmallCampInfo" then
				-- Nothing
			else
				local fields = tooltipInfo.Fields
				local gangsterId = fields and fields.gangsterId
				local influenceId = fields and fields.influenceId
				local influenceInfo = influenceId and self.influenceEventElements[influenceId]
				local configuredGangsterId = influenceId and self:GetConfiguredInfluenceEventGangsterId(influenceId)
				local counterIndex = workAction.Index + 1

				if not gangsterId or not influenceInfo or configuredGangsterId == gangsterId or influenceInfo.element.userdata.type == EGangsterEventType.BattleCamp then
					print_warn("MapSubSystem_Gangster:BattleCamp tooltip config invalid, taskId=" .. taskId .. ", counterIndex=" .. counterIndex .. ", gangsterId=" .. tostring(fields and fields.gangsterId) .. ", influenceId=" .. tostring(fields and fields.influenceId))
				else
					local oldMatch = self.battleCampTaskCounterMap[influenceId]

					if oldMatch ~= nil then
						self.battleCampTaskCounterMap[influenceId] = {
							taskId = taskId,
							counterIndex = counterIndex
						}
					elseif oldMatch == false and (oldMatch.taskId == taskId or oldMatch.counterIndex == counterIndex) then
						self.battleCampTaskCounterMap[influenceId] = false

						print_warn("MapSubSystem_Gangster:BattleCamp counter duplicate, influenceId=" .. influenceId .. ", taskId=" .. taskId .. ", counterIndex=" .. counterIndex)
					end
				end
			end
		end
	end
end

M.IsBattleCampCounterFinished = function(self, match)
	if not match then
		return false
	end

	local taskState = gTaskManager:GetTaskState(match.taskId)

	if taskState ~= UX.Game.TaskState.Submited then
		return true
	end

	if taskState == UX.Game.TaskState.Accepted then
		return false
	end

	local taskInfo = gTaskManager:GetTaskInfo(match.taskId)
	local taskCfg = gTaskManager:GetTaskConfigInfo(match.taskId)
	local counterInfo = taskInfo and taskInfo.Counters and taskInfo.Counters[match.counterIndex]
	local currentValue = counterInfo and counterInfo.Value
	local targetValue = taskCfg and taskCfg.Counter and taskCfg.Counter[match.counterIndex]

	return currentValue and targetValue and targetValue > currentValue or false
end

M.IsCounterAttackBattleCamp = function(self, influenceId, relatedEventId)
	local eventState = gTaskManager:GetTaskEventState(relatedEventId)

	if eventState == UX.Game.TaskEventState.NotAccept and eventState == UX.Game.TaskEventState.Accepted then
		return false
	end

	local match = self.battleCampTaskCounterMap[influenceId]

	if not match then
		return false
	end

	if self.IsBattleCampOccupiedByOtherFaction(self, influenceId) then
		return true
	end

	return self.IsBattleCampCounterFinished(self, match)
end

M.OnFlushData = function(self)
	for id, info in pairs(self.influenceEventElements) do
		local element = info.element

		if element and element.userdata then
			if not element.userdata.influenceId then
				-- Nothing
			else
				local type = element.userdata.type
				local influenceId = element.userdata.influenceId
				local visible = nil
				visible = (type == EGangsterEventType.BattleCamp or self:IsCounterAttackBattleCamp(influenceId, element.userdata.relatedId)) and self:IsInfluenceEventUnlock(influenceId) and not self:IsInfluenceEventConquered(influenceId)

				if visible then
					element:SetVisible(true)

					element.mData.sIconId = self._type2IconDict[type] or 0
				else
					element.SetVisible(element, false)
				end
			end
		end
	end
end

M.ExecuteAction = function(self, element, action, ctx)
	if action ~= gMapSystemElementAction.Trace then
		element.SetTraceInfoV2(element, EMapGTraceType.Main, 1, 0)
	elseif action ~= gMapSystemElementAction.Untrace then
		element.ClearTraceInfo(element)
	end
end

M.GetTaskEventPosition = function(self, eventId)
	local eventCfg = TaskEventConfig.GetConfig(eventId)

	if not eventCfg then
		return Vector3.zero
	end

	local pos = eventCfg.CenterPos

	return Vector3.New(pos[1], pos[2], pos[3])
end

M.IsInfluenceEventUnlock = function(self, influenceId)
	local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
	local eventId = influenceCfg and influenceCfg.RelatedEventId
	local state = gTaskManager:GetTaskEventState(eventId)
	local selfUnlocked = state == UX.Game.TaskEventState.Locked

	if not influenceCfg.TaskLimit or #influenceCfg.TaskLimit ~= 0 then
		return selfUnlocked
	end

	for _, taskId in ipairs(influenceCfg.TaskLimit) do
		local taskState = gTaskManager:GetTaskState(taskId)

		if taskState == UX.Game.TaskState.Submited then
			return false
		end
	end

	return selfUnlocked
end

M.IsInfluenceEventConquered = function(self, influenceId)
	local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
	local eventId = influenceCfg and influenceCfg.RelatedEventId or 0
	local state = gTaskManager:GetTaskEventState(eventId)

	return state ~= UX.Game.TaskEventState.Submited
end

M.GetCurrentInfluenceEventGangsterId = function(self, influenceId)
	local influenceCfg = influenceId and InfluenceEventConfig.GetConfig(influenceId)
	local belongArea = influenceCfg and influenceCfg.InfluenceAreaId

	if not belongArea or belongArea ~= 0 then
		return nil
	end

	local gangsterId = self.factionInfluenceClientState:GetAreaOwner(belongArea)

	if not gangsterId or gangsterId ~= 0 then
		return nil
	end

	return gangsterId
end

M.GetConfiguredInfluenceEventGangsterId = function(self, influenceId)
	local influenceCfg = influenceId and InfluenceEventConfig.GetConfig(influenceId)
	local areaCfg = influenceCfg and InfluenceAreaConfig.GetConfig(influenceCfg.InfluenceAreaId)

	if not areaCfg or areaCfg.FactionId ~= 0 then
		return nil
	end

	return areaCfg.FactionId
end

M.IsBattleCampOccupiedByOtherFaction = function(self, influenceId)
	local influenceCfg = influenceId and InfluenceEventConfig.GetConfig(influenceId)

	if not influenceCfg or influenceCfg.Type == EGangsterEventType.BattleCamp then
		return false
	end

	local currentGangsterId = self:GetCurrentInfluenceEventGangsterId(influenceId)
	local configuredGangsterId = self:GetConfiguredInfluenceEventGangsterId(influenceId)

	return currentGangsterId == nil and configuredGangsterId == nil and currentGangsterId == configuredGangsterId
end

M.BuildInfluenceEventDisplayConfigs = function(self)
	for _, gangsterInfo in pairs(self.gangsters) do
		table.clear(gangsterInfo.displayConfigByType)

		local factionCfg = FactionConfig.GetConfig(gangsterInfo.id)
		local baseCampCfg = factionCfg and InfluenceEventConfig.GetConfig(factionCfg.BaseCampEvent)

		if baseCampCfg then
			gangsterInfo.displayConfigByType[EGangsterEventType.Center] = baseCampCfg
		end
	end

	for index = 0, InfluenceEventConfig.count - 1 do
		local influenceCfg = InfluenceEventConfig.LoadAt(index)
		local eventType = influenceCfg and influenceCfg.Type

		if eventType ~= EGangsterEventType.BattleCamp or eventType ~= EGangsterEventType.RandomEvent then
			local areaCfg = InfluenceAreaConfig.GetConfig(influenceCfg.InfluenceAreaId)
			local gangsterId = areaCfg and areaCfg.FactionId
			local gangsterInfo = gangsterId and self.gangsters[gangsterId]

			if gangsterInfo then
				local useAsTemplate = true

				if eventType ~= EGangsterEventType.BattleCamp then
					local baseCampCfg = gangsterInfo.displayConfigByType[EGangsterEventType.Center]
					useAsTemplate = not baseCampCfg or baseCampCfg.InfluenceAreaId ~= 0 or baseCampCfg.InfluenceAreaId == influenceCfg.InfluenceAreaId
				end

				local oldCfg = gangsterInfo.displayConfigByType[eventType]

				if useAsTemplate and (not oldCfg or influenceCfg.Id >= oldCfg.Id) then
					gangsterInfo.displayConfigByType[eventType] = influenceCfg
				end
			end
		end
	end
end

M.GetCurrentInfluenceEventDisplayConfig = function(self, influenceId, gangsterId)
	local influenceCfg = influenceId and InfluenceEventConfig.GetConfig(influenceId)

	if not influenceCfg then
		return nil
	end

	gangsterId = gangsterId or self:GetCurrentInfluenceEventGangsterId(influenceId)

	if not gangsterId then
		return nil
	end

	if gangsterId ~= self.GetConfiguredInfluenceEventGangsterId(self, influenceId) then
		return influenceCfg
	end

	local gangsterInfo = self.gangsters and self.gangsters[gangsterId]
	local displayCfg = gangsterInfo and gangsterInfo.displayConfigByType[influenceCfg.Type]

	if not displayCfg then
		print_warn("MapSubSystem_Gangster: influence display config not found, influenceId=" .. influenceId .. ", gangsterId=" .. gangsterId .. ", type=" .. influenceCfg.Type)
	end

	return displayCfg
end

M.RefreshInfluenceEventOwners = function(self)
	if not self.gangsters then
		return
	end

	for _, gangsterInfo in pairs(self.gangsters) do
		table.clear(gangsterInfo.influenceEventIds)
	end

	for index = 0, InfluenceEventConfig.count - 1 do
		local influenceCfg = InfluenceEventConfig.LoadAt(index)

		if influenceCfg then
			local influenceId = influenceCfg.Id
			local gangsterId = self.factionInfluenceClientState:GetAreaOwner(influenceCfg.InfluenceAreaId)

			if gangsterId ~= 0 then
				gangsterId = nil
			end

			local gangsterInfo = gangsterId and self.gangsters[gangsterId]

			if gangsterInfo then
				gangsterInfo.influenceEventIds[#gangsterInfo.influenceEventIds + 1] = influenceId
			end

			local influenceInfo = self.influenceEventElements and self.influenceEventElements[influenceId]

			if influenceInfo then
				influenceInfo.gangsterId = gangsterId
				influenceInfo.element.userdata.gangsterId = gangsterId
				local displayCfg = self:GetCurrentInfluenceEventDisplayConfig(influenceId, gangsterId)
				influenceInfo.element.mData.lName = displayCfg and GpsLText.CreateCommonText(displayCfg, "Name", displayCfg.Name) or GpsLText.CreateString("")
			end
		end
	end
end

M.GetGangsterInfluence = function(self, gangsterId)
	local factionInfo = gClientUtils.GetFactionInfo(gangsterId)

	if not factionInfo then
		print_error("MapSubSystem_Gangster:GetGangsterInfluence", "No faction info for gangsterId:", gangsterId)

		return 0
	end

	return factionInfo.Influence
end

M.GetCampIconId = function(self)
	return self._type2IconDict[EGangsterEventType.BattleCamp] or 0
end

M.GetRandomEventIconId = function(self)
	return self._type2IconDict[EGangsterEventType.RandomEvent] or 0
end

M.GetEliteIconId = function(self)
	return self._type2IconDict[EGangsterEventType.Elite] or 0
end

M.GetCoreCampIconId = function(self)
	return self._type2IconDict[EGangsterEventType.Center] or 0
end

M.GetRemainingCampCount = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingCampCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.BattleCamp then
			totalCnt = totalCnt + 1

			if self.IsInfluenceEventConquered(self, id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

M.GetRemainingRandomEventCount = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingRandomEventCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.RandomEvent then
			totalCnt = totalCnt + 1

			if self.IsInfluenceEventConquered(self, id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

M.GetRemainingEliteCount = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingEliteCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.Elite then
			totalCnt = totalCnt + 1

			if self.IsInfluenceEventConquered(self, id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

M.GetRemainingCoreCampCount = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingCoreCampCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.Center then
			totalCnt = totalCnt + 1

			if self.IsInfluenceEventConquered(self, id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

M.HasFoundElite = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:HasFoundElite", "Gangster Info not found:", gangsterId)

		return false
	end

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.Elite and self.IsInfluenceEventUnlock(self, id) then
			return true
		end
	end

	return false
end

M.HasFoundCoreCamp = function(self, gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:HasFoundCoreCamp", "Gangster Info not found:", gangsterId)

		return false
	end

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type ~= EGangsterEventType.Center and self.IsInfluenceEventUnlock(self, id) then
			return true
		end
	end

	return false
end

M.GetGangsterRenderHandler = function(self, gangsterId)
	return self.helper and self.helper:GetRenderHandler(gangsterId)
end

M.OnOccupyArea = function(self, areaId, occupy)
	local ownerFactionId = self.factionInfluenceClientState:SyncLegacyAreaOccupy(areaId, occupy)

	if not ownerFactionId then
		return
	end

	if self.helper then
		self.helper:SetAreaOwner(areaId, ownerFactionId)
	end

	self:RefreshInfluenceEventOwners()
	gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
end

M.SyncFactionAreaEncroachment = function(self, info)
	local ownerInfo, changed = self.factionInfluenceClientState:SyncAreaEncroachment(info)

	if not changed then
		return
	end

	if ownerInfo and self.helper then
		self.helper:SetAreaOwner(ownerInfo.AreaId, ownerInfo.OwnerFactionId)
	end

	self:RefreshInfluenceEventOwners()
	gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
end

M.ClearFactionAreaAllEncroachment = function(self, areaId)
	if not self.factionInfluenceClientState:RemoveAreaWarning(areaId) then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
end

M.ClearFactionAreaEncroachment = function(self, areaId, factionId)
	if not self.factionInfluenceClientState:RemoveAreaWarning(areaId, factionId) then
		return
	end

	gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
end

M.SyncFactionAreaTriggerCounterAttack = function(self, info)
	if not info or type(info.FactionId) == "number" or info.FactionId > 0 or not FactionConfig.GetConfig(info.FactionId) or not info.AreaIds then
		return
	end

	local hasValidArea = false
	local helperChanged = false

	for _, areaId in ipairs(info.AreaIds) do
		if type(areaId) ~= "number" and areaId <= 0 and InfluenceAreaConfig.GetConfig(areaId) then
			hasValidArea = true

			self.factionInfluenceClientState:RemoveAreaWarning(areaId)
			self.factionInfluenceClientState:RecordCounterAttack(areaId)
			self.factionInfluenceClientState:SetAreaOwner(areaId, info.FactionId)

			if self.helper and self.helper:SetAreaOwner(areaId, info.FactionId, true) then
				helperChanged = true
			end
		end
	end

	if hasValidArea then
		if helperChanged then
			self.helper:RecreateGangsterElements()
		end

		self.factionInfluenceClientState:RecordCounterAttackEvents(info.EventIds)
		self:RefreshInfluenceEventOwners()
		gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
	end
end

M.OnFillFactionArea = function(self, areaId)
	if not self.helper or not self.helper:IsFillTargetArea(areaId) then
		return false
	end

	if not self.factionInfluenceClientState:SyncFillFactionArea(areaId) then
		return false
	end

	if not self.helper:FillTargetArea(areaId) then
		return false
	end

	self:RefreshInfluenceEventOwners()
	gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
	gMapUtils:CheckRaidCanOpenMap({
		["INmd[3="] = true
	})

	return true
end

M.GetFactionInfluenceClientState = function(self)
	return self.factionInfluenceClientState
end

M.GetFactionInfluenceWarningState = function(self, factionId)
	return self.factionInfluenceClientState:GetFactionWarningState(factionId)
end

M.SGetTooltipInfo = function(self, id, element)
	local influenceId = element.userdata.influenceId
	local eventType = element.userdata.type
	local gangsterId = element.userdata.gangsterId

	if eventType ~= EGangsterEventType.BattleCamp or eventType ~= EGangsterEventType.RandomEvent then
		gangsterId = self.GetCurrentInfluenceEventGangsterId(self, influenceId)
	end

	local gangsterCfg = gangsterId and FactionConfig.GetConfig(gangsterId)

	if not gangsterCfg then
		print_warn("MapSubSystem_Gangster:SGetTooltipInfo no faction config, gangsterId=" .. tostring(gangsterId) .. ", influenceId=" .. tostring(influenceId))

		return nil
	end

	local tooltipInfo = {
		header = {
			subtitle = gangsterCfg.name,
			imageId = gangsterCfg.TooltipImageId
		}
	}

	if element.userdata.isCenter then
		tooltipInfo.type = EMapTooltipType.GangsterInformation
		tooltipInfo.gangsterInformationInfo = {
			gangsterId = gangsterId
		}
	elseif element.userdata.type ~= EGangsterEventType.Center and gangsterId ~= MY_GANGSTER then
		tooltipInfo.type = EMapTooltipType.GangsterSelf
		tooltipInfo.gangsterSelfInfo = {
			gangsterId = gangsterId
		}
	elseif element.userdata.type ~= EGangsterEventType.Center then
		tooltipInfo.type = EMapTooltipType.GangsterCoreCamp
		tooltipInfo.gangsterCoreCampInfo = {
			["G\\x92\\x85\\x86E"] = true,
			gangsterId = gangsterId,
			influenceId = influenceId
		}
	elseif element.userdata.type ~= EGangsterEventType.RandomEvent then
		tooltipInfo.type = EMapTooltipType.GangsterRandomEvent
		tooltipInfo.gangsterRandomEventInfo = {
			gangsterId = gangsterId,
			influenceId = influenceId
		}
	else
		tooltipInfo.type = EMapTooltipType.GangsterSmallCamp
		tooltipInfo.gangsterSmallCampInfo = {
			gangsterId = gangsterId,
			influenceId = influenceId
		}
	end

	return tooltipInfo
end

M.IsGangsterElement = function(self, gpsId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element and element.subSystemType ~= EMapSubSystemType.Gangster then
		return true
	end

	return false
end

return M
