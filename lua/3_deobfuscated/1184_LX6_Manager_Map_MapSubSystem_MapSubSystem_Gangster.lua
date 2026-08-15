require("LX6/Manager/Map/Utils/GangsterAreaHelper/GangsterAreaHelper")

local FactionConfig = LTConfig.FactionConfig
local InfluenceEventConfig = LTConfig.FactionInfluenceEventConfig
local InfluenceAreaConfig = LTConfig.FactionInfluenceAreaConfig
local TaskEventConfig = LTConfig.TaskEventConfig
local Vector3 = Vector3
local actionHelper = require("LX6/Manager/Map/MapSubSystem/MapSubSystemActionHelper")
local MY_GANGSTER = FactionConfig.JiaMuFaction
MapSubSystem_Gangster = DefClass("MapSubSystem_Gangster", MapSubSystem_Gangster, MapSubSystemBase)
local M = MapSubSystem_Gangster
local EGangsterEventType = {
	BattleCamp = 2,
	RandomEvent = 5,
	Elite = 4,
	ConqueredCamp = 3,
	Center = 1
}

function M:OnInit()
	self:InitType2Icon()

	function self._tracingGangsterPrediction(element)
		return element.subSystemType == EMapSubSystemType.Gangster
	end

	self.gangsterInfluenceEventsMap = {}
end

function M:InitEventHandlers()
	self.eventHandlers = {
		[gEventConstants.CURRENT_TASK_CHANGE] = function ()
			self:FlushData("CurrentTaskChange")
		end,
		[gEventConstants.TASK_STATE_CHANGED] = function ()
			self:FlushData("TaskStateChanged")
		end,
		[gEventConstants.TASK_EVENT_CHANGE] = function ()
			self:FlushData("TaskEventChange")
		end,
		[gEventConstants.ON_EVENT_STATE_CHANGE] = function ()
			self:FlushData("EventStateChange")
		end
	}
end

function M:InitType2Icon()
	self._type2IconDict = {}
	local pics = FactionConfig.EventPic

	for _, p in ipairs(pics) do
		self._type2IconDict[p.EventType] = p.SguiId
	end
end

function M:OnLogin()
	self:InitEventHandlers()
	self:FlushData("Init")
	gMessageManager:RegisterEventHandlers(self.eventHandlers)

	if self.helper then
		self.helper:Clear()
	end

	self.helper = GangsterAreaHelper.New()

	self.helper:OnLogin()
end

function M:OnLogout()
	gMessageManager:UnregisterEventHandlers(self.eventHandlers)

	if self.helper then
		self.helper:Clear()

		self.helper = nil
	end
end

function M:OnLoadData()
	if self.influenceEventElements then
		for _, info in pairs(self.influenceEventElements) do
			info.element:Dispose()
		end
	end

	self.gangsters = {}

	for i = 0, FactionConfig.count - 1 do
		local factionCfg = FactionConfig.LoadAt(i)
		local id = factionCfg.Id

		if factionCfg.BaseCampLocation then
			if #factionCfg.BaseCampLocation > 0 then
				local info = {
					id = id,
					influenceEventIds = {}
				}
				self.gangsters[id] = info
			end
		end
	end

	self.influenceEventElements = {}

	for i = 0, InfluenceEventConfig.count - 1 do
		local cfg = InfluenceEventConfig.LoadAt(i)
		local id = cfg.Id
		local relatedId = cfg.RelatedEventId
		local gangsterId = self:GetInfluenceEventGangsterId(id)

		if cfg.Type == EGangsterEventType.RandomEvent then
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

			element:SetPosition(self:GetTaskEventPosition(cfg.RelatedEventId))
			element:SetVisible(false)
			element:SetActions(self.NormalTraceableActions)

			if cfg.Type == EGangsterEventType.RandomEvent then
				gMapSubSystemUtils:SetupScaleLevel(element, 2, 28001287)
			elseif cfg.Type == EGangsterEventType.BattleCamp then
				gMapSubSystemUtils:SetupScaleLevel(element, 2, nil)
			else
				gMapSubSystemUtils:SetupScaleLevel(element, 1, nil)
			end

			local info = {
				gangsterId = gangsterId,
				influenceId = id,
				element = element
			}
			self.influenceEventElements[id] = info
		end

		local gangsterInfo = self.gangsters[gangsterId]

		if gangsterInfo then
			table.insert(gangsterInfo.influenceEventIds, id)
		end
	end

	self:FlushData()
end

function M:OnFlushData()
	for id, info in pairs(self.influenceEventElements) do
		local element = info.element

		if element and element.userdata then
			if not element.userdata.influenceId then
				-- Nothing
			else
				local type = element.userdata.type
				local influenceId = element.userdata.influenceId

				if self:IsInfluenceEventUnlock(influenceId) and not self:IsInfluenceEventConquered(influenceId) then
					element:SetVisible(true)

					element.mData.sIconId = self._type2IconDict[type] or 0
				else
					element:SetVisible(false)
				end
			end
		end
	end
end

function M:ExecuteAction(element, action, ctx)
	if action == gMapSystemElementAction.Trace then
		actionHelper.Trace(element)
		element:SetTraceInfoV2(EMapGTraceType.Main, 1, 0)
	elseif action == gMapSystemElementAction.Untrace then
		actionHelper.Untrace(element)
	end
end

function M:GetTaskEventPosition(eventId)
	local eventCfg = TaskEventConfig.GetConfig(eventId)

	if not eventCfg then
		return Vector3.zero
	end

	local pos = eventCfg.CenterPos

	return Vector3.New(pos[1], pos[2], pos[3])
end

function M:IsInfluenceEventUnlock(influenceId)
	local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
	local eventId = influenceCfg and influenceCfg.RelatedEventId
	local state = gTaskManager:GetTaskEventState(eventId)
	local selfUnlocked = state ~= UX.Game.TaskEventState.Locked

	if not influenceCfg.TaskLimit or #influenceCfg.TaskLimit == 0 then
		return selfUnlocked
	end

	for _, taskId in ipairs(influenceCfg.TaskLimit) do
		local taskState = gTaskManager:GetTaskState(taskId)

		if taskState ~= UX.Game.TaskState.Submited then
			return false
		end
	end

	return selfUnlocked
end

function M:IsInfluenceEventConquered(influenceId)
	local influenceCfg = InfluenceEventConfig.GetConfig(influenceId)
	local eventId = influenceCfg and influenceCfg.RelatedEventId or 0
	local state = gTaskManager:GetTaskEventState(eventId)

	return state == UX.Game.TaskEventState.Submited
end

function M:GetInfluenceEventGangsterId(eventId)
	local influenceCfg = InfluenceEventConfig.GetConfig(eventId)
	local belongArea = influenceCfg and influenceCfg.InfluenceAreaId

	if not belongArea or belongArea == 0 then
		return nil
	end

	local areaCfg = InfluenceAreaConfig.GetConfig(belongArea)

	if not areaCfg or areaCfg.FactionId == 0 then
		return nil
	end

	return areaCfg.FactionId
end

function M:GetGangsterInfluence(gangsterId)
	local factionInfo = gClientUtils.GetFactionInfo(gangsterId)

	if not factionInfo then
		print_error("MapSubSystem_Gangster:GetGangsterInfluence", "No faction info for gangsterId:", gangsterId)

		return 0
	end

	return factionInfo.Influence
end

function M:GetCampIconId()
	return self._type2IconDict[EGangsterEventType.BattleCamp] or 0
end

function M:GetRandomEventIconId()
	return self._type2IconDict[EGangsterEventType.RandomEvent] or 0
end

function M:GetEliteIconId()
	return self._type2IconDict[EGangsterEventType.Elite] or 0
end

function M:GetCoreCampIconId()
	return self._type2IconDict[EGangsterEventType.Center] or 0
end

function M:GetRemainingCampCount(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingCampCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.BattleCamp then
			totalCnt = totalCnt + 1

			if self:IsInfluenceEventConquered(id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

function M:GetRemainingRandomEventCount(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingRandomEventCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.RandomEvent then
			totalCnt = totalCnt + 1

			if self:IsInfluenceEventConquered(id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

function M:GetRemainingEliteCount(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingEliteCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.Elite then
			totalCnt = totalCnt + 1

			if self:IsInfluenceEventConquered(id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

function M:GetRemainingCoreCampCount(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:GetRemainingCoreCampCount", "Gangster Info not found:", gangsterId)

		return 0
	end

	local totalCnt = 0
	local conqueredCnt = 0

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.Center then
			totalCnt = totalCnt + 1

			if self:IsInfluenceEventConquered(id) then
				conqueredCnt = conqueredCnt + 1
			end
		end
	end

	return totalCnt - conqueredCnt
end

function M:HasFoundElite(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:HasFoundElite", "Gangster Info not found:", gangsterId)

		return false
	end

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.Elite and self:IsInfluenceEventUnlock(id) then
			return true
		end
	end

	return false
end

function M:HasFoundCoreCamp(gangsterId)
	local gangsterInfo = self.gangsters[gangsterId]

	if not gangsterInfo then
		print_error("MapSubSystem_Gangster:HasFoundCoreCamp", "Gangster Info not found:", gangsterId)

		return false
	end

	for _, id in ipairs(gangsterInfo.influenceEventIds) do
		local influenceCfg = InfluenceEventConfig.GetConfig(id)

		if influenceCfg.Type == EGangsterEventType.Center and self:IsInfluenceEventUnlock(id) then
			return true
		end
	end

	return false
end

function M:GetGangsterRenderHandler(gangsterId)
	return self.helper and self.helper:GetRenderHandler(gangsterId)
end

function M:OnOccupyArea(areaId, occupy)
	if self.helper then
		self.helper:OnOccupyArea(areaId, occupy)
		gMessageManager:SendMessage(gEventConstants.ON_MAP_GANGSTER_AREA_DIRTY)
	end
end

function M:SGetTooltipInfo(id, element)
	local gangsterId = element.userdata.gangsterId
	local gangsterCfg = FactionConfig.GetConfig(gangsterId)

	if not gangsterCfg then
		-- Nothing
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
	elseif element.userdata.type == EGangsterEventType.Center and gangsterId == MY_GANGSTER then
		tooltipInfo.type = EMapTooltipType.GangsterSelf
		tooltipInfo.gangsterSelfInfo = {
			gangsterId = gangsterId
		}
	elseif element.userdata.type == EGangsterEventType.Center then
		tooltipInfo.type = EMapTooltipType.GangsterCoreCamp
		tooltipInfo.gangsterCoreCampInfo = {
			locked = true,
			gangsterId = gangsterId,
			influenceId = element.userdata.influenceId
		}
	elseif element.userdata.type == EGangsterEventType.RandomEvent then
		tooltipInfo.type = EMapTooltipType.GangsterRandomEvent
		tooltipInfo.gangsterRandomEventInfo = {
			gangsterId = gangsterId,
			influenceId = element.userdata.influenceId
		}
	else
		tooltipInfo.type = EMapTooltipType.GangsterSmallCamp
		tooltipInfo.gangsterSmallCampInfo = {
			gangsterId = gangsterId,
			influenceId = element.userdata.influenceId
		}
	end

	return tooltipInfo
end

function M:IsGangsterElement(gpsId)
	local element = gMapSystem.container:GetByGpsId(gpsId)

	if element and element.subSystemType == EMapSubSystemType.Gangster then
		return true
	end

	return false
end

return M
